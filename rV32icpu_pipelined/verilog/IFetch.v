
`timescale 1ns/1ps

module IFetch (
    input  wire        clock,
    input  wire        reset,
    input  wire        not_stall,
    input  wire        br_taken,
    input  wire [31:0] br_target,
    input  wire        imem_write_enable,
    input  wire [7:0]  imem_write_address,
    input  wire [31:0] imem_write_data,
    output wire [31:0] pc,
    output wire [31:0] instruction
);

    reg [31:0] pc_register = 32'b0;

    wire [31:0] pc_plus_4;
    wire [31:0] next_pc;

    assign pc_plus_4 = pc_register + 32'd4;
    assign next_pc   = br_taken ? br_target : pc_plus_4;
    assign pc        = pc_register;

    always @(posedge clock or posedge reset) begin
        if (reset)
            pc_register <= 32'b0;
        else if (not_stall)
            pc_register <= next_pc;
    end

    // RAM1: 256 x 32, asynchronous read
    reg [31:0] RAM1 [0:255];

    assign instruction = RAM1[pc_register[9:2]];

    always @(posedge clock) begin
        if (imem_write_enable)
            RAM1[imem_write_address] <= imem_write_data;
    end

    integer i;

    initial begin
        // Initialize all locations to NOP
        for (i = 0; i < 256; i = i + 1)
            RAM1[i] = 32'h00000013;

        // Eight-instruction test program; inspect architectural state for PASS.
        RAM1[ 0] = 32'h00500093;  // addi x1,x0,5
        RAM1[ 1] = 32'h00300113;  // addi x2,x0,3
        RAM1[ 2] = 32'h002081B3;  // add x3,x1,x2
        RAM1[ 3] = 32'h00302023;  // sw x3,0(x0)
        RAM1[ 4] = 32'h00002203;  // lw x4,0(x0)
        RAM1[ 5] = 32'h001202B3;  // add x5,x4,x1
        RAM1[ 6] = 32'h00001337;  // lui x6,0x1
        RAM1[ 7] = 32'h00528463;  // beq x5,x5,+8 (skip failure)
        RAM1[ 8] = 32'h06300393;  // addi x7,x0,99 (skip)
        RAM1[ 9] = 32'h0080046F;  // jal x8,+8 (skip failure)
        RAM1[10] = 32'h06300393;  // addi x7,x0,99 (skip)
        RAM1[11] = 32'h03800493;  // addi x9,x0,56
        RAM1[12] = 32'h00048567;  // jalr x10,0(x9)
        RAM1[13] = 32'h06300393;  // addi x7,x0,99 (skip)
        RAM1[14] = 32'h00100593;  // addi x11,x0,1 (success marker)
        RAM1[15] = 32'h0000006F;  // jal x0,0 (hold)
    end

endmodule
