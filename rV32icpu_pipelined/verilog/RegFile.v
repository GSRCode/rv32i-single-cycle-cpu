
`timescale 1ns/1ps

module RegFile (
    input  wire        reset,
    input  wire        clock,
    input  wire        reg_write,
    input  wire [4:0]  rd,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [31:0] write_data,

    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2
);

    // 31 physical registers: x1 through x31.
    // x0 is supplied as a constant zero.

    reg [31:0] registers [1:31];

    integer i;

    // Decoder and register write-enable gates.
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 1; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (reg_write && rd != 5'd0) begin
            registers[rd] <= write_data;
        end
    end

    // Two asynchronous 32-to-1 multiplexers.
    assign read_data_1 =
        (rs1 == 5'd0) ? 32'b0 : registers[rs1];

    assign read_data_2 =
        (rs2 == 5'd0) ? 32'b0 : registers[rs2];

endmodule
