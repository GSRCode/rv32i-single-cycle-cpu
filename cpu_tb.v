`timescale 1ns/1ps

module cpu_tb;
    reg clk;
    reg reset;

    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);

        clk = 0;
        reset = 1;
        #2;
        reset = 0;

        @(posedge clk);
        #1;
        $display("Clock 1: PC=%h x1=%h", uut.pc, uut.regs.registers[1]);
        if (uut.pc !== 32'd4 || uut.regs.registers[1] !== 32'd10)
            $display("FAIL: ADDI x1");
        else
            $display("PASS: ADDI x1");

        @(posedge clk);
        #1;
        $display("Clock 2: PC=%h x2=%h", uut.pc, uut.regs.registers[2]);
        if (uut.pc !== 32'd8 || uut.regs.registers[2] !== 32'd20)
            $display("FAIL: ADDI x2");
        else
            $display("PASS: ADDI x2");

        @(posedge clk);
        #1;
        $display("Clock 3: PC=%h x3=%h", uut.pc, uut.regs.registers[3]);
        if (uut.pc !== 32'd12 || uut.regs.registers[3] !== 32'd30)
            $display("FAIL: ADD x3");
        else
            $display("PASS: ADD x3");

        @(posedge clk);
        #1;
        $display("Clock 4: PC=%h x4=%h", uut.pc, uut.regs.registers[4]);
        if (uut.pc !== 32'd16 || uut.regs.registers[4] !== 32'd30)
            $display("FAIL: LW x4");
        else
            $display("PASS: LW x4");

        $finish;
    end
endmodule
