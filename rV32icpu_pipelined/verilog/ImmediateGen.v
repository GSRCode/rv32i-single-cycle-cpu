
`timescale 1ns/1ps

module ImmediateGen (
    input  wire [31:0] instruction,
    output reg  [31:0] immediate
);

    wire cmp_6f = (instruction[6:0] == 7'h6F);
    wire cmp_63 = (instruction[6:0] == 7'h63);
    wire cmp_37 = (instruction[6:0] == 7'h37);
    wire cmp_23 = (instruction[6:0] == 7'h23);

    wire [2:0] mux_select;

    assign mux_select[0] = cmp_37 | cmp_23;
    assign mux_select[1] = cmp_63 | cmp_37;
    assign mux_select[2] = cmp_6f;

    always @(*) begin
        case (mux_select)

            3'd0: immediate = {
                {20{instruction[31]}},
                instruction[31:20]
            };

            3'd1: immediate = {
                {20{instruction[31]}},
                instruction[31:25],
                instruction[11:7]
            };

            3'd2: immediate = {
                {19{instruction[31]}},
                instruction[31],
                instruction[7],
                instruction[30:25],
                instruction[11:8],
                1'b0
            };

            3'd3: immediate = {
                instruction[31:12],
                12'b0
            };

            3'd4: immediate = {
                {11{instruction[31]}},
                instruction[31],
                instruction[19:12],
                instruction[20],
                instruction[30:21],
                1'b0
            };

            default: immediate = 32'b0;

        endcase
    end

endmodule
