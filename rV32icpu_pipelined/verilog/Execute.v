`timescale 1ns/1ps

module Execute (input ex_valid,
ex_addi, ex_lw, ex_sw, ex_beq, ex_lui, ex_jal, ex_jalr, input [31: 0] ex_pc,
ex_imm, fwd_a, fwd_b, output [31: 0] ex_result,
mem_addr, br_target, output br_taken);
assign ex_result = ex_lui ? ex_imm : (ex_jal || ex_jalr) ? ex_pc + 4 : fwd_a + (ex_addi || ex_lw || ex_sw ? ex_imm : fwd_b);
assign mem_addr = fwd_a + ex_imm;
assign br_taken = ex_valid && (ex_jal || ex_jalr || (ex_beq && fwd_a == fwd_b));
assign br_target = ex_jalr ? ((fwd_a + ex_imm) & 32'hfffffffe) : ex_pc + ex_imm;
endmodule
