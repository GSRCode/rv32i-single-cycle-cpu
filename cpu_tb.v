`timescale 1ns/1ps
module cpu_tb;
    reg clk = 0;
    reg reset = 1;
    integer errors = 0;
    cpu dut(.clk(clk), .reset(reset));
    task check_pc(input [31:0] expected);
    begin
        if (dut.pc !== expected) begin
            $display("FAIL: PC expected %08h got %08h", expected, dut.pc);
            errors = errors + 1;
        end else $display("PASS: PC = %08h", dut.pc);
    end
    endtask
    task step;
    begin
        #5 clk = 1;
        #1;
        #4 clk = 0;
        #1;
    end
    endtask
    initial begin
        #2; reset = 0;
        #2; reset = 1;
        #2; reset = 0;
        #1; check_pc(0);
        step(); check_pc(4);
        if (dut.regs.registers[2] !== 32'd5) begin
            $display("FAIL: x2"); errors = errors + 1;
        end else $display("PASS: x2 = 5");
        step(); check_pc(12);
        if (dut.regs.registers[1] !== 32'd8) begin
            $display("FAIL: x1 link = %08h", dut.regs.registers[1]); errors = errors + 1;
        end else $display("PASS: x1 = 8 (return address)");
        if (dut.regs.registers[3] !== 0) begin
            $display("FAIL: skipped x3 was written"); errors = errors + 1;
        end else $display("PASS: x3 = 0 (instruction skipped)");
        step(); check_pc(16);
        if (dut.regs.registers[4] !== 32'd42) begin
            $display("FAIL: x4 = %08h", dut.regs.registers[4]); errors = errors + 1;
        end else $display("PASS: x4 = 42");
        if (errors == 0) $display("ALL JAL TESTS PASSED");
        else $display("JAL TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
