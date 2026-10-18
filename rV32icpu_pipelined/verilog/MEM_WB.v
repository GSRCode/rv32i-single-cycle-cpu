`timescale 1ns/1ps

module MEM_WB (input clock,
reset, mem_valid, mem_regwrite, mem_load, input [4: 0] mem_rd,
input [31: 0] mem_result,
load_value, output reg wb_valid,
wb_regwrite, output reg [4: 0] wb_rd,
output reg [31: 0] wb_data);
always @ (posedge clock) if (reset) begin
    wb_valid <= 0;
    wb_regwrite <= 0;
    wb_rd <= 0;
    wb_data <= 0;
end
else begin
    wb_valid <= mem_valid;
    wb_regwrite <= mem_regwrite;
    wb_rd <= mem_rd;
    wb_data <= mem_load ? load_value : mem_result;
end
endmodule
