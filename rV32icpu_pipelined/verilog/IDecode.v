`timescale 1ns/1ps

module IDecode (input clock,
reset, input [31: 0] insn,
input wb_valid,
wb_regwrite, input [4: 0] wb_rd,
input [31: 0] wb_data,
output [4: 0] rs1,
rs2, rd, output [31: 0] a,
b, imm, output is_add,
is_addi, is_lw, is_sw, is_beq, is_lui, is_jal, is_jalr, supported, uses_rs1,
uses_rs2);
reg [31: 0] regs[0: 31];
integer i;
initial for (i = 0; i < 32; i = i + 1) regs[i] = 0;
wire wb_can_forward = wb_valid && wb_regwrite && wb_rd != 0;
always @ (posedge clock) if (! reset) begin
    if (wb_can_forward) regs[wb_rd] <= wb_data;
    regs[0] <= 0;
end
assign rs1 = insn[19: 15];
assign rs2 = insn[24: 20];
assign rd = insn[11: 7];
assign a = (wb_can_forward && wb_rd == rs1) ? wb_data : regs[rs1];
assign b = (wb_can_forward && wb_rd == rs2) ? wb_data : regs[rs2];
wire [6: 0] op = insn[6: 0];
wire [2: 0] funct3 = insn[14: 12];
wire [6: 0] funct7 = insn[31: 25];
assign is_add = (op == 7'b0110011 && funct3 == 0 && funct7 == 0);
assign is_addi = (op == 7'b0010011 && funct3 == 0);
assign is_lw = (op == 7'b0000011 && funct3 == 3'b010);
assign is_sw = (op == 7'b0100011 && funct3 == 3'b010);
assign is_beq = (op == 7'b1100011 && funct3 == 0);
assign is_lui = (op == 7'b0110111);
assign is_jal = (op == 7'b1101111);
assign is_jalr = (op == 7'b1100111 && funct3 == 0);
assign supported = is_add | is_addi | is_lw | is_sw | is_beq | is_lui | is_jal | is_jalr;
assign uses_rs1 = is_add | is_addi | is_lw | is_sw | is_beq | is_jalr;
assign uses_rs2 = is_add | is_sw | is_beq;
wire [31: 0] imm_i = { { 20 { insn[31] } }, insn[31: 20] };
wire [31: 0] imm_s = { { 20 { insn[31] } }, insn[31: 25], insn[11: 7] };
wire [31: 0] imm_b = { { 19 { insn[31] } }, insn[31], insn[7], insn[30: 25], insn[11: 8], 1'b0 };
wire [31: 0] imm_j = { { 11 { insn[31] } }, insn[31], insn[19: 12], insn[20], insn[30: 21], 1'b0 };
assign imm = is_sw ? imm_s : is_beq ? imm_b : is_jal ? imm_j : is_lui ? { insn[31 : 12], 12'b0 } : imm_i;
endmodule
