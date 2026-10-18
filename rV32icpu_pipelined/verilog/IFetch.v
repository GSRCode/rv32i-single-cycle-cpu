`timescale 1ns/1ps

module IFetch #(
    parameter WORDS = 256
)(
    input wire clock,
    input wire reset,
    input wire not_stall,
    input wire br_taken,
    input wire [31:0] br_target,
    output reg [31:0] pc,
    output reg if_valid,
    output reg [31:0] if_pc,
    output reg [31:0] if_insn
);
    localparam NOP = 32'h00000013;
    reg [31:0] imem [0:WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1) begin
            imem[i] = NOP;
        end
    end

    wire [31:0] fetched;
    assign fetched = (pc[31:2] < WORDS) ? imem[pc[31:2]] : NOP;

    always @(posedge clock) begin
        if (reset) begin
            pc <= 0;
            if_valid <= 0;
            if_pc <= 0;
            if_insn <= NOP;
        end
        else if (br_taken) begin
            pc <= br_target;
            if_valid <= 0;
            if_insn <= NOP;
        end
        else if (not_stall) begin
            if_valid <= 1;
            if_pc <= pc;
            if_insn <= fetched;
            pc <= pc + 4;
        end
    end
endmodule
