`timescale 1ns/1ps

module BubbleControl (input if_valid,
supported, stall, br_taken, output ex_next_valid);
assign ex_next_valid = if_valid && supported && ! stall && ! br_taken;
endmodule
