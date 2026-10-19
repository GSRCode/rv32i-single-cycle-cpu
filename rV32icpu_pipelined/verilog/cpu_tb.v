`timescale 1ns/1ps

module cpu_tb;
    reg clock = 0;
    reg reset = 1;
    wire stall;
    cpu uut (.clock(clock), .reset(reset), .stall(stall));
    always #5 clock = ~clock;

    integer i, tests = 0, failures = 0, stalls = 0;
    integer cycles;
    reg [255:0] test_name;

    // Standard RV32I encoders, to avoid hand-encoding mistakes.
    function [31:0] addi;
        input [4:0] d, a;
        input [11:0] imm;
        begin addi = {imm,a,3'b000,d,7'h13}; end
    endfunction
    function [31:0] add;
        input [4:0] d, a, b;
        begin add = {7'b0,b,a,3'b000,d,7'h33}; end
    endfunction
    function [31:0] lw;
        input [4:0] d, a;
        input [11:0] imm;
        begin lw = {imm,a,3'b010,d,7'h03}; end
    endfunction
    function [31:0] sw;
        input [4:0] b, a;
        input [11:0] imm;
        begin sw = {imm[11:5],b,a,3'b010,imm[4:0],7'h23}; end
    endfunction
    function [31:0] beq;
        input [4:0] a,b;
        input [12:0] off;
        begin beq = {off[12],off[10:5],b,a,3'b000,off[4:1],off[11],7'h63}; end
    endfunction
    function [31:0] lui;
        input [4:0] d;
        input [19:0] imm;
        begin lui = {imm,d,7'h37}; end
    endfunction
    function [31:0] jal;
        input [4:0] d;
        input [20:0] off;
        begin jal = {off[20],off[10:1],off[11],off[19:12],d,7'h6f}; end
    endfunction
    function [31:0] jalr;
        input [4:0] d,a;
        input [11:0] imm;
        begin jalr = {imm,a,3'b000,d,7'h67}; end
    endfunction

    // Prepare the next test. Do not edit CPU internals except the
    // instruction/data memories used to load programs and test fixtures.
    task prepare;
        input [255:0] name;
        begin
            @(negedge clock);
            reset = 1;
            test_name = name;
            stalls = 0;
            for (i=0; i<256; i=i+1) begin
                uut.Ifetch1.RAM1[i] = 32'h00000013;
                uut.Mem1.DataRam1[i] = 32'b0;
            end
            $display("\n--- %0s ---", test_name);
        end
    endtask

    task run_cycles;
        input integer count;
        begin
            // Reset is held across at least one rising clock edge.
            repeat (2) @(posedge clock);
            @(negedge clock);
            reset = 0;
            for (cycles=0; cycles<count; cycles=cycles+1) begin
                @(negedge clock);
                if (stall === 1'b1) stalls = stalls + 1;
                else if (stall !== 1'b0) begin
                    $display("FAIL %0s: stall is X/Z", test_name);
                    failures = failures + 1;
                end
            end
            #1;
        end
    endtask

    task check_reg;
        input [4:0] r;
        input [31:0] expected;
        reg [31:0] actual;
        begin
            tests = tests + 1;
            actual = (r==0) ? 32'b0 : uut.IDecode1.RegFile1.registers[r];
            if (actual === expected)
                $display("PASS x%0d = %h", r, actual);
            else begin
                $display("FAIL x%0d expected=%h actual=%h",r,expected,actual);
                failures = failures + 1;
            end
        end
    endtask

    task check_mem;
        input integer idx;
        input [31:0] expected;
        reg [31:0] actual;
        begin
            tests = tests + 1;
            actual = uut.Mem1.DataRam1[idx];
            if (actual === expected)
                $display("PASS RAM[%0d] = %h",idx,actual);
            else begin
                $display("FAIL RAM[%0d] expected=%h actual=%h",idx,expected,actual);
                failures = failures + 1;
            end
        end
    endtask

    task check_stalls;
        input integer expected;
        begin
            tests = tests + 1;
            if (stalls == expected)
                $display("PASS stalls = %0d",stalls);
            else begin
                $display("FAIL stalls expected=%0d actual=%0d",expected,stalls);
                failures = failures + 1;
            end
        end
    endtask

    initial begin
        // 1. Basic arithmetic and EX/MEM + MEM/WB forwarding.
        prepare("ADD/ADDI and forwarding");
        uut.Ifetch1.RAM1[0] = addi(1,0,12'd5);
        uut.Ifetch1.RAM1[1] = addi(2,0,12'd3);
        uut.Ifetch1.RAM1[2] = add(3,1,2);
        run_cycles(15);
        check_reg(1,5); check_reg(2,3); check_reg(3,8);
        check_stalls(0);

        // 2. Both forwarding stages may match; newest value must win.
        prepare("EX/MEM forwarding precedence");
        uut.Ifetch1.RAM1[0] = addi(1,0,12'd5);
        uut.Ifetch1.RAM1[1] = addi(1,1,12'd3);
        uut.Ifetch1.RAM1[2] = addi(1,1,12'd2);
        uut.Ifetch1.RAM1[3] = add(2,1,1);
        run_cycles(16);
        check_reg(1,10); check_reg(2,20); check_stalls(0);

        // 3. LW followed immediately by dependent ADD: exactly one stall.
        prepare("LW to ADD load-use hazard");
        uut.Mem1.DataRam1[0] = 32'd7;
        uut.Ifetch1.RAM1[0] = lw(1,0,12'd0);
        uut.Ifetch1.RAM1[1] = add(2,1,1);
        run_cycles(16);
        check_reg(1,7); check_reg(2,14); check_stalls(1);

        // 4. Store data from preceding arithmetic instruction.
        prepare("SW store data forwarding");
        uut.Ifetch1.RAM1[0] = addi(1,0,12'd21);
        uut.Ifetch1.RAM1[1] = sw(1,0,12'd16);
        uut.Ifetch1.RAM1[2] = lw(2,0,12'd16);
        run_cycles(17);
        check_mem(4,21); check_reg(2,21);

        // 5. LW followed immediately by SW of the loaded register.
        prepare("LW to SW store forwarding");
        uut.Mem1.DataRam1[0] = 32'd33;
        uut.Ifetch1.RAM1[0] = lw(1,0,12'd0);
        uut.Ifetch1.RAM1[1] = sw(1,0,12'd20);
        uut.Ifetch1.RAM1[2] = lw(2,0,12'd20);
        run_cycles(18);
        check_mem(5,33); check_reg(2,33);
        // Stall count intentionally not asserted: this checks the existing
        // hazard detector's behavior without assuming a specific optimization.

        // 6. Branch not taken: both subsequent instructions execute.
        prepare("BEQ not taken");
        uut.Ifetch1.RAM1[0] = addi(1,0,12'd1);
        uut.Ifetch1.RAM1[1] = addi(2,0,12'd2);
        uut.Ifetch1.RAM1[2] = beq(1,2,13'd12);
        uut.Ifetch1.RAM1[3] = addi(3,0,12'd7);
        uut.Ifetch1.RAM1[4] = addi(4,0,12'd9);
        run_cycles(18);
        check_reg(3,7); check_reg(4,9);

        // 7. Branch taken: squash wrong-path instructions.
        prepare("BEQ taken and flush");
        uut.Ifetch1.RAM1[0] = addi(1,0,12'd4);
        uut.Ifetch1.RAM1[1] = addi(2,0,12'd4);
        uut.Ifetch1.RAM1[2] = beq(1,2,13'd16); // PC 8 -> PC 24
        uut.Ifetch1.RAM1[3] = addi(3,0,12'd99);
        uut.Ifetch1.RAM1[4] = addi(4,0,12'd88);
        uut.Ifetch1.RAM1[5] = addi(5,0,12'd77);
        uut.Ifetch1.RAM1[6] = addi(6,0,12'd42);
        run_cycles(20);
        check_reg(3,0); check_reg(4,0); check_reg(5,0);
        check_reg(6,42);

        // 8. LUI upper immediate writeback.
        prepare("LUI");
        uut.Ifetch1.RAM1[0] = lui(7,20'h12345);
        run_cycles(12);
        check_reg(7,32'h12345000);

        // 9. JAL return address and wrong-path flush.
        prepare("JAL link and flush");
        uut.Ifetch1.RAM1[0] = jal(1,21'd16); // PC 0 -> PC 16
        uut.Ifetch1.RAM1[1] = addi(3,0,12'd99);
        uut.Ifetch1.RAM1[2] = addi(4,0,12'd88);
        uut.Ifetch1.RAM1[3] = addi(5,0,12'd77);
        uut.Ifetch1.RAM1[4] = addi(2,0,12'd42);
        run_cycles(17);
        check_reg(1,4); check_reg(2,42);
        check_reg(3,0); check_reg(4,0); check_reg(5,0);

        // 10. JALR target and link. Target has bit 0 cleared.
        prepare("JALR target and link");
        uut.Ifetch1.RAM1[0] = addi(1,0,12'd25);
        uut.Ifetch1.RAM1[1] = jalr(5,1,12'd0); // PC 4 -> PC 24
        uut.Ifetch1.RAM1[2] = addi(3,0,12'd99);
        uut.Ifetch1.RAM1[3] = addi(4,0,12'd88);
        uut.Ifetch1.RAM1[4] = addi(6,0,12'd77);
        uut.Ifetch1.RAM1[5] = 32'h00000013;
        uut.Ifetch1.RAM1[6] = addi(2,0,12'd17);
        run_cycles(19);
        check_reg(5,8); check_reg(2,17);
        check_reg(3,0); check_reg(4,0); check_reg(6,0);

        $display("\n========================================");
        $display("RV32I REGRESSION SUMMARY");
        $display("Checks: %0d  Passed: %0d  Failed: %0d",
                 tests, tests-failures, failures);
        if (failures == 0)
            $display("ALL REGRESSION CHECKS PASSED");
        else
            $display("REGRESSION FAILURES - investigate before FPGA");
        $display("========================================");
        if (failures != 0) $fatal(1,"Regression failed");
        $finish;
    end

    initial begin
        #100000;
        $fatal(1,"Regression timeout");
    end
endmodule
