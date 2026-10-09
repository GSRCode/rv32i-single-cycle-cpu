
module alu (
    input [31:0] a,
    input [31:0] b,
    input [1:0] operation,
    output reg [31:0] result,
    output zero
);

    always @(*) begin
        case (operation)
            2'b00: result = a + b;
            2'b01: result = a - b;
            2'b10: result = a & b;
            2'b11: result = a | b;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
