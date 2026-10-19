
module ForwardingUnit (
    input  [31:0] ex_read_data_1,
    input  [31:0] ex_read_data_2,
    input  [4:0]  ex_rs1,
    input  [4:0]  ex_rs2,

    input  [4:0]  mem_rd,
    input  [31:0] mem_alu_result,
    input         mem_reg_write,
    input         mem_mem_read,

    input  [4:0]  wb_rd,
    input  [31:0] wb_data,
    input         wb_reg_write,

    output [31:0] read_data_1,
    output [31:0] read_data_2,
    output [4:0]  ex_rs2_op
);

    wire wb_forward_rs1;
    wire wb_forward_rs2;
    wire mem_forward_rs1;
    wire mem_forward_rs2;

    assign wb_forward_rs1 =
        wb_reg_write &&
        (wb_rd != 5'b00000) &&
        (wb_rd == ex_rs1);

    assign wb_forward_rs2 =
        wb_reg_write &&
        (wb_rd != 5'b00000) &&
        (wb_rd == ex_rs2);

    assign mem_forward_rs1 =
        mem_reg_write &&
        !mem_mem_read &&
        (mem_rd != 5'b00000) &&
        (mem_rd == ex_rs1);

    assign mem_forward_rs2 =
        mem_reg_write &&
        !mem_mem_read &&
        (mem_rd != 5'b00000) &&
        (mem_rd == ex_rs2);

    assign read_data_1 =
        mem_forward_rs1 ? mem_alu_result :
        wb_forward_rs1  ? wb_data :
                          ex_read_data_1;

    assign read_data_2 =
        mem_forward_rs2 ? mem_alu_result :
        wb_forward_rs2  ? wb_data :
                          ex_read_data_2;

    assign ex_rs2_op = ex_rs2;

endmodule
