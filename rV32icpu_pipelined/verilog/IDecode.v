
`timescale 1ns/1ps

module IDecode (
    input  wire [31:0] instruction,
    input  wire [31:0] pc,
    input  wire        reset,
    input  wire        clock,
    input  wire        wb_reg_write,
    input  wire [31:0] wb_data,
    input  wire [4:0]  wb_rd,

    output wire [6:0]  opcode,
    output wire [4:0]  rd,
    output wire [2:0]  funct3,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [6:0]  funct7,

    output wire [1:0]  result_src,
    output wire        alu_src,
    output wire        mem_read,
    output wire        mem_write,
    output wire        reg_write,
    output wire        branch,
    output wire        alu_sub,
    output wire        jump,
    output wire        jalr,

    output wire [31:0] read_data_1,
    output wire [31:0] read_data_2,
    output wire [31:0] immediate,
    output wire [31:0] pc_op
);

    // Instruction splitter in Logisim
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // Direct PC connection
    assign pc_op = pc;

    // Control Unit
    ControlUnit ControlUnit1 (
        .opcode     (opcode),
        .result_src (result_src),
        .alu_src    (alu_src),
        .mem_read   (mem_read),
        .reg_write  (reg_write),
        .branch     (branch),
        .mem_write  (mem_write),
        .alu_sub    (alu_sub),
        .jump       (jump),
        .jalr       (jalr)
    );

    // Register File
    RegFile RegFile1 (
        .reset       (reset),
        .clock       (clock),
        .reg_write   (wb_reg_write),
        .rd          (wb_rd),
        .rs1         (rs1),
        .rs2         (rs2),
        .write_data  (wb_data),
        .read_data_1 (read_data_1),
        .read_data_2 (read_data_2)
    );

    // Immediate Generator
    ImmediateGen ImmGen1 (
        .instruction (instruction),
        .immediate   (immediate)
    );

endmodule
