
`timescale 1ns/1ps

module control_tb;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire reg_write;
    wire [1:0] operation;

    control uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .operation(operation)
    );

    initial begin
        $dumpfile("control.vcd");
        $dumpvars(0, control_tb);

        // Test 1: ADD instruction
        opcode = 7'h33;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        $display("ADD: reg_write = %b, operation = %b",
                 reg_write, operation);

        // Test 2: SUB instruction (not supported yet)
        opcode = 7'h33;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #10;

        $display("SUB: reg_write = %b, operation = %b",
                 reg_write, operation);

        // Test 3: Unsupported opcode
        opcode = 7'h00;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        $display("Invalid opcode: reg_write = %b, operation = %b",
                 reg_write, operation);

        // Test 4: Unsupported funct3
        opcode = 7'h33;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        #10;

        $display("Invalid funct3: reg_write = %b, operation = %b",
                 reg_write, operation);

        $finish;
    end

endmodule
