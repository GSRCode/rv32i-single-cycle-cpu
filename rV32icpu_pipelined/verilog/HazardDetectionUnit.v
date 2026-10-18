`timescale 1ns/1ps

module HazardDetectionUnit (input if_valid,
ex_valid, ex_lw, input [4: 0] ex_rd,
rs1, rs2, input uses_rs1,
uses_rs2, output stall);
assign stall = if_valid && ex_valid && ex_lw && ex_rd != 0 && ((uses_rs1 && rs1 == ex_rd) || (uses_rs2 && rs2 == ex_rd));
endmodule
