`timescale 1ns/1ps

module Memory # (parameter WORDS = 256) (input clock,
input mem_valid,
mem_store, input [31: 0] mem_addr,
store_value, output [31: 0] load_value);
reg [31: 0] dmem[0: WORDS - 1];
integer i;
initial for (i = 0; i < WORDS; i = i + 1) dmem[i] = 0;
assign load_value = (mem_addr[31 : 2] < WORDS) ? dmem[mem_addr[31 : 2]] : 32'b0;
always @ (posedge clock) if (mem_valid && mem_store && mem_addr[31: 2] < WORDS) dmem[mem_addr[31: 2]] <= store_value;
endmodule
