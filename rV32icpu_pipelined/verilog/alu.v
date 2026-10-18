
`timescale 1ns/1ps

module ALU (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [1:0]  Operation,

    output reg  [31:0] result,
    output wire        zero
);

    // Four operations selected by the Logisim MUX

    always @(*) begin
        case (Operation)
            2'b00: result = A + B;
            2'b01: result = A - B;
            2'b10: result = A & B;
            2'b11: result = A | B;
        endcase
    end

    // Comparator connected to the ALU result
    assign zero = (result == 32'b0);

endmodule
