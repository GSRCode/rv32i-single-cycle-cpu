`timescale 1ns/1ps

module instruction_fetch_tb;

    reg clk;
    reg reset;

    wire [31:0] pc;
    wire [31:0] instruction;

    instruction_fetch dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction(instruction)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("instruction_fetch.vcd");
        $dumpvars(0, instruction_fetch_tb);

        clk = 0;
        reset = 1;

        #2;
        reset = 0;

        #1;
        $display("PC = %h, Instruction = %h", pc, instruction);

        #10;
        $display("PC = %h, Instruction = %h", pc, instruction);

        #10;
        $display("PC = %h, Instruction = %h", pc, instruction);

        #10;
        $display("PC = %h, Instruction = %h", pc, instruction);

        $finish;
    end

endmodule