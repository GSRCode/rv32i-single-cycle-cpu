`timescale 1ns/1ps

module ID_EX (input clock,
reset, valid_in, input [31: 0] pc_in,
a_in, b_in, imm_in, input [4: 0] rs1_in,
rs2_in, rd_in, input add_in,
addi_in, lw_in, sw_in, beq_in, lui_in, jal_in, jalr_in, output reg valid,
output reg [31: 0] pc,
a, b, imm, output reg [4: 0] rs1,
rs2, rd, output reg is_add,
is_addi, is_lw, is_sw, is_beq, is_lui, is_jal, is_jalr);
always @ (posedge clock) if (reset) begin
    valid <= 0;
    pc <= 0;
    a <= 0;
    b <= 0;
    imm <= 0;
    rs1 <= 0;
    rs2 <= 0;
    rd <= 0;
    is_add <= 0;
    is_addi <= 0;
    is_lw <= 0;
    is_sw <= 0;
    is_beq <= 0;
    is_lui <= 0;
    is_jal <= 0;
    is_jalr <= 0;
end
else begin
    valid <= valid_in;
    pc <= pc_in;
    a <= a_in;
    b <= b_in;
    imm <= imm_in;
    rs1 <= rs1_in;
    rs2 <= rs2_in;
    rd <= rd_in;
    is_add <= add_in;
    is_addi <= addi_in;
    is_lw <= lw_in;
    is_sw <= sw_in;
    is_beq <= beq_in;
    is_lui <= lui_in;
    is_jal <= jal_in;
    is_jalr <= jalr_in;
end
endmodule
