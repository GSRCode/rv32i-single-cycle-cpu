
`timescale 1ns/1ps

module Execute (
    input  wire [31:0] pc,
    input  wire [31:0] read_data_1,
    input  wire [31:0] read_data_2,
    input  wire [31:0] immediate,

    input  wire        alu_src,
    input  wire        alu_sub,
    input  wire        branch,
    input  wire        jump,
    input  wire        jalr,

    output wire [31:0] result,
    output wire        zero,
    output wire [31:0] br_target,
    output wire        br_taken
);

    // ALU operand multiplexer
    wire [31:0] alu_operand_b;

    assign alu_operand_b = alu_src ? immediate : read_data_2;

    // ALU operation: 00 = ADD, 01 = SUB
    wire [1:0] Operation;

    assign Operation = {1'b0, alu_sub};

    ALU Alu1 (
        .A         (read_data_1),
        .B         (alu_operand_b),
        .Operation (Operation),
        .result    (result),
        .zero      (zero)
    );

    // Branch and jump target adders
    wire [31:0] pc_target;
    wire [31:0] jalr_target;

    assign pc_target   = pc + immediate;
    assign jalr_target = (read_data_1 + immediate) & 32'hFFFFFFFE;

    // Branch target multiplexer
    assign br_target = jalr ? jalr_target : pc_target;

    // Branch decision
    assign br_taken = jump | (branch & zero);

endmodule
