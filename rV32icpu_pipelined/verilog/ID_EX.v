
`timescale 1ns/1ps

module ID_EX (
    input wire clock,
    input wire reset,
    input wire enable,

    input wire [31:0] pc,
    input wire [31:0] read_data_1,
    input wire [31:0] read_data_2,
    input wire [31:0] immediate,
    input wire [4:0] rd,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [1:0] result_src,
    input wire alu_src,
    input wire mem_read,
    input wire mem_write,
    input wire reg_write,
    input wire branch,
    input wire alu_sub,
    input wire jump,
    input wire jalr,

    output reg [31:0] ex_pc,
    output reg [31:0] ex_read_data_1,
    output reg [31:0] ex_read_data_2,
    output reg [31:0] ex_immediate,
    output reg [4:0] ex_rd,
    output reg [4:0] ex_rs1,
    output reg [4:0] ex_rs2,
    output reg [2:0] ex_funct3,
    output reg [6:0] ex_funct7,
    output reg [1:0] ex_result_src,
    output reg ex_alu_src,
    output reg ex_mem_read,
    output reg ex_mem_write,
    output reg ex_reg_write,
    output reg ex_branch,
    output reg ex_alu_sub,
    output reg ex_jump,
    output reg ex_jalr
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            ex_pc          <= 0;
            ex_read_data_1 <= 0;
            ex_read_data_2 <= 0;
            ex_immediate   <= 0;
            ex_rd          <= 0;
            ex_rs1         <= 0;
            ex_rs2         <= 0;
            ex_funct3      <= 0;
            ex_funct7      <= 0;
            ex_result_src  <= 0;
            ex_alu_src     <= 0;
            ex_mem_read    <= 0;
            ex_mem_write   <= 0;
            ex_reg_write   <= 0;
            ex_branch      <= 0;
            ex_alu_sub     <= 0;
            ex_jump        <= 0;
            ex_jalr        <= 0;
        end
        else if (enable) begin
            ex_pc          <= pc;
            ex_read_data_1 <= read_data_1;
            ex_read_data_2 <= read_data_2;
            ex_immediate   <= immediate;
            ex_rd          <= rd;
            ex_rs1         <= rs1;
            ex_rs2         <= rs2;
            ex_funct3      <= funct3;
            ex_funct7      <= funct7;
            ex_result_src  <= result_src;
            ex_alu_src     <= alu_src;
            ex_mem_read    <= mem_read;
            ex_mem_write   <= mem_write;
            ex_reg_write   <= reg_write;
            ex_branch      <= branch;
            ex_alu_sub     <= alu_sub;
            ex_jump        <= jump;
            ex_jalr        <= jalr;
        end
    end

endmodule
