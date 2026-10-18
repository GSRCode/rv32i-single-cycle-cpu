
`timescale 1ns/1ps

module EX_MEM (
    input  wire        clock,
    input  wire        reset,
    input  wire        enable,

    input  wire [31:0] pc,
    input  wire [31:0] alu_result,
    input  wire [31:0] read_data_2,
    input  wire [4:0]  rd,
    input  wire [31:0] immediate,
    input  wire [1:0]  result_src,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire        reg_write,
    input  wire        jump,
    input  wire [4:0]  ex_rs2,

    output reg  [31:0] mem_pc,
    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_read_data_2,
    output reg  [4:0]  mem_rd,
    output reg  [31:0] mem_immediate,
    output reg  [1:0]  mem_result_src,
    output reg         mem_mem_read,
    output reg         mem_mem_write,
    output reg         mem_reg_write,
    output reg         mem_jump,
    output reg  [4:0]  mem_rs2
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            mem_pc          <= 0;
            mem_alu_result  <= 0;
            mem_read_data_2 <= 0;
            mem_rd          <= 0;
            mem_immediate   <= 0;
            mem_result_src  <= 0;
            mem_mem_read    <= 0;
            mem_mem_write   <= 0;
            mem_reg_write   <= 0;
            mem_jump        <= 0;
            mem_rs2         <= 0;
        end
        else if (enable) begin
            mem_pc          <= pc;
            mem_alu_result  <= alu_result;
            mem_read_data_2 <= read_data_2;
            mem_rd          <= rd;
            mem_immediate   <= immediate;
            mem_result_src  <= result_src;
            mem_mem_read    <= mem_read;
            mem_mem_write   <= mem_write;
            mem_reg_write   <= reg_write;
            mem_jump        <= jump;
            mem_rs2         <= ex_rs2;
        end
    end

endmodule
