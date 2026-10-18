`timescale 1ns/1ps

module EX_MEM (input clock,
reset, ex_valid, ex_add, ex_addi, ex_lw, ex_sw, ex_lui, ex_jal, ex_jalr,
input [4: 0] ex_rd,
ex_rs2, input [31: 0] ex_result,
ex_addr, store_data, output reg mem_valid,
mem_regwrite, mem_load, mem_store, output reg [4: 0] mem_rd,
mem_store_rs2, output reg [31: 0] mem_result,
mem_addr, mem_store_data);
always @ (posedge clock) if (reset) begin
    mem_valid <= 0;
    mem_regwrite <= 0;
    mem_load <= 0;
    mem_store <= 0;
    mem_rd <= 0;
    mem_store_rs2 <= 0;
    mem_result <= 0;
    mem_addr <= 0;
    mem_store_data <= 0;
end
else begin
    mem_valid <= ex_valid;
    mem_regwrite <= ex_add | ex_addi | ex_lw | ex_lui | ex_jal | ex_jalr;
    mem_load <= ex_lw;
    mem_store <= ex_sw;
    mem_rd <= ex_rd;
    mem_store_rs2 <= ex_rs2;
    mem_result <= ex_result;
    mem_addr <= ex_addr;
    mem_store_data <= store_data;
end
endmodule
