`timescale 1ns/1ps

module StoreForwardingUnit (input mem_store,
input [4: 0] mem_store_rs2,
input [31: 0] mem_store_data,
input wb_valid,
wb_regwrite, input [4: 0] wb_rd,
input [31: 0] wb_data,
output [31: 0] store_value);
assign store_value = (mem_store && wb_valid && wb_regwrite && wb_rd != 0 && wb_rd == mem_store_rs2) ? wb_data : mem_store_data;
endmodule
