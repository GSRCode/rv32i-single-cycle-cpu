`timescale 1ns/1ps

module ForwardingUnit (input [31: 0] ex_a,
ex_b, input [4: 0] ex_rs1,
ex_rs2, input mem_valid,
mem_regwrite, mem_load, input [4: 0] mem_rd,
input [31: 0] mem_result,
input wb_valid,
wb_regwrite, input [4: 0] wb_rd,
input [31: 0] wb_data,
output [31: 0] fwd_a,
fwd_b);
wire mf = mem_valid && mem_regwrite && ! mem_load && mem_rd != 0;
wire wf = wb_valid && wb_regwrite && wb_rd != 0;
assign fwd_a = (mf && mem_rd == ex_rs1) ? mem_result : (wf && wb_rd == ex_rs1) ? wb_data : ex_a;
assign fwd_b = (mf && mem_rd == ex_rs2) ? mem_result : (wf && wb_rd == ex_rs2) ? wb_data : ex_b;
endmodule
