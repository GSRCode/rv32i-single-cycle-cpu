
`timescale 1ns/1ps

module ControlUnit (
    input  wire [6:0] opcode,

    output wire [1:0] result_src,
    output wire       alu_src,
    output wire       mem_read,
    output wire       reg_write,
    output wire       branch,
    output wire       mem_write,
    output wire       alu_sub,
    output wire       jump,
    output wire       jalr
);

    // Opcode comparators from Logisim

    wire cmp_33 = (opcode == 7'h33); // ADD
    wire cmp_13 = (opcode == 7'h13); // ADDI
    wire cmp_03 = (opcode == 7'h03); // LW
    wire cmp_23 = (opcode == 7'h23); // SW
    wire cmp_63 = (opcode == 7'h63); // BEQ
    wire cmp_37 = (opcode == 7'h37); // LUI
    wire cmp_6f = (opcode == 7'h6F); // JAL
    wire cmp_67 = (opcode == 7'h67); // JALR

    // OR gates and direct connections
    assign jump = cmp_6f | cmp_67;
    
    assign result_src[0] = cmp_03 | jump;
    assign result_src[1] = cmp_37 | jump;

    assign alu_src = cmp_13 | cmp_03 | cmp_23 | cmp_67;

    assign mem_read = cmp_03;

    assign reg_write = cmp_33 | cmp_13 | cmp_03 |
                       cmp_37 | cmp_6f | cmp_67;

    assign branch = cmp_63;

    assign mem_write = cmp_23;

    assign alu_sub = cmp_63;

    assign jalr = cmp_67;

endmodule
