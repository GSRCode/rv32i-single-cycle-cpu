
`timescale 1ns/1ps

module alu_tb;

    reg [31:0] a;
    reg [31:0] b;
    reg [1:0] operation;

    wire [31:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .operation(operation),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        // Test 1: ADD
        a = 32'h0000000A;
        b = 32'h00000014;
        operation = 2'b00;
        #10;
        $display("ADD: result = %h, zero = %b", result, zero);

        // Test 2: ADD
        a = 32'h00000064;
        b = 32'h00000032;
        operation = 2'b00;
        #10;
        $display("ADD: result = %h, zero = %b", result, zero);

        // Test 3: ADD overflow
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        operation = 2'b00;
        #10;
        $display("ADD overflow: result = %h, zero = %b",
                 result, zero);

        // Test 4: SUB
        a = 32'h00000014;
        b = 32'h0000000A;
        operation = 2'b01;
        #10;
        $display("SUB: result = %h, zero = %b", result, zero);

        // Test 5: AND
        a = 32'h0000000F;
        b = 32'h00000003;
        operation = 2'b10;
        #10;
        $display("AND: result = %h, zero = %b", result, zero);

        // Test 6: OR
        a = 32'h0000000C;
        b = 32'h00000003;
        operation = 2'b11;
        #10;
        $display("OR: result = %h, zero = %b", result, zero);

        $finish;
    end

endmodule
