`timescale 1ns/1ps
module cpu_tb;
    reg clk = 0;
    reg reset = 0;
    integer errors = 0;
    cpu dut (.clk(clk), .reset(reset));

    task pulse;
        begin
            #5 clk = 1;
            #5 clk = 0;
        end
    endtask

    task check_pc;
        input [31:0] expected;
        begin
            #1;
            if (dut.pc !== expected) begin
                $display("FAIL: PC expected %08h got %08h", expected, dut.pc);
                errors = errors + 1;
            end else $display("PASS: PC = %08h", dut.pc);
        end
    endtask

    task check_reg;
        input [4:0] number;
        input [31:0] expected;
        begin
            #1;
            if (dut.regs.registers[number] !== expected) begin
                $display("FAIL: x%0d expected %08h got %08h", number, expected, dut.regs.registers[number]);
                errors = errors + 1;
            end else $display("PASS: x%0d = %08h", number, expected);
        end
    endtask

    task do_reset;
        begin
            reset = 0;
            #2 reset = 1;
            #2 reset = 0;
        end
    endtask

    initial begin
        // BEQ taken program already in instruction_memory.v
        $display("--- BEQ taken ---");
        do_reset();
        check_pc(0);
        pulse(); check_pc(4);
        pulse(); check_pc(8);
        pulse(); check_pc(16);
        pulse(); check_pc(20);
        check_reg(3, 42);

        // Load the LUI program without changing instruction_memory.v
        $display("--- LUI followed by ADDI ---");
        dut.ifetch.imem.memory[0] = 32'h123451b7;
        dut.ifetch.imem.memory[1] = 32'h00700213;
        dut.ifetch.imem.memory[2] = 32'h00000000;
        do_reset();
        check_pc(0);
        pulse(); check_pc(4); check_reg(3, 32'h12345000);
        pulse(); check_pc(8); check_reg(4, 7);

        if (errors == 0) $display("ALL BEQ AND LUI TESTS PASSED");
        else $display("TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
