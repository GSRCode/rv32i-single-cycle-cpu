
`timescale 1ns/1ps

module MEM_WB (
    input  wire        clock,
    input  wire        reset,
    input  wire        enable,

    input  wire [31:0] pc,
    input  wire [31:0] alu_result,
    input  wire [31:0] read_data,
    input  wire [4:0]  rd,
    input  wire [31:0] immediate,
    input  wire [1:0]  result_src,
    input  wire        reg_write,

    output reg  [31:0] wb_pc,
    output reg  [31:0] wb_alu_result,
    output reg  [31:0] wb_read_data,
    output reg  [4:0]  wb_rd,
    output reg  [31:0] wb_immediate,
    output reg  [1:0]  wb_result_src,
    output reg         wb_reg_write,

    output reg  [31:0] wb_data
);

    // Seven pipeline registers
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            wb_pc         <= 0;
            wb_alu_result <= 0;
            wb_read_data  <= 0;
            wb_rd         <= 0;
            wb_immediate  <= 0;
            wb_result_src <= 0;
            wb_reg_write  <= 0;
        end
        else if (enable) begin
            wb_pc         <= pc;
            wb_alu_result <= alu_result;
            wb_read_data  <= read_data;
            wb_rd         <= rd;
            wb_immediate  <= immediate;
            wb_result_src <= result_src;
            wb_reg_write  <= reg_write;
        end
    end

    // PC + 4 adder and four-input multiplexer
    always @(*) begin
        case (wb_result_src)
            2'b00: wb_data = wb_alu_result;
            2'b01: wb_data = wb_read_data;
            2'b10: wb_data = wb_immediate;
            2'b11: wb_data = wb_pc + 32'd4;
        endcase
    end

endmodule
