
`timescale 1ns/1ps

module cpu_tb;

    reg clk;
    reg reset;

    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock period = 10 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);

        clk = 0;
        reset = 1;

        // Reset PC
        #2;
        reset = 0;

        // Clock 1: ADDI x1, x0, 10
        @(posedge clk);
        #1;

        $display("Clock 1: PC=%h x1=%h",
                 uut.pc,
                 uut.regs.registers[1]);

        if (uut.pc !== 32'd4 ||
            uut.regs.registers[1] !== 32'd10)
            $display("FAIL: Clock 1");
        else
            $display("PASS: Clock 1");

        // Clock 2: ADDI x2, x0, 20
        @(posedge clk);
        #1;

        $display("Clock 2: PC=%h x2=%h",
                 uut.pc,
                 uut.regs.registers[2]);

        if (uut.pc !== 32'd8 ||
            uut.regs.registers[2] !== 32'd20)
            $display("FAIL: Clock 2");
        else
            $display("PASS: Clock 2");

        // Clock 3: ADD x3, x1, x2
        @(posedge clk);
        #1;

        $display("Clock 3: PC=%h x3=%h",
                 uut.pc,
                 uut.regs.registers[3]);

        if (uut.pc !== 32'd12 ||
            uut.regs.registers[3] !== 32'd30)
            $display("FAIL: Clock 3");
        else
            $display("PASS: Clock 3");

        $finish;
    end

endmodule
