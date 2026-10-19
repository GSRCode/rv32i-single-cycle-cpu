
module HazardDetectionUnit (
    input  wire [4:0] ex_rd,
    input  wire [4:0] rs1,
    input  wire [4:0] rs2,
    input  wire       ex_mem_read,

    output wire       stall
);

    assign stall =
        ex_mem_read &&
        (ex_rd != 5'b00000) &&
        ((ex_rd == rs1) || (ex_rd == rs2));

endmodule
