
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

        // Our test program
        RAM1[0] = 32'h00500093;  // addi x1, x0, 5
        RAM1[1] = 32'h00300113;  // addi x2, x0, 3
        RAM1[2] = 32'h002081B3;  // add  x3, x1, x2
    end

endmodule
