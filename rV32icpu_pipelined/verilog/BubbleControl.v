
module BubbleControl (
    input  wire jalr,
    input  wire reg_write,
    input  wire mem_read,
    input  wire mem_write,
    input  wire branch,
    input  wire jump,
    input  wire not_stall,

    output wire jalr_op,
    output wire reg_write_op,
    output wire mem_read_op,
    output wire mem_write_op,
    output wire branch_op,
    output wire jump_op
);

    assign jalr_op      = jalr      & not_stall;
    assign reg_write_op = reg_write & not_stall;
    assign mem_read_op  = mem_read  & not_stall;
    assign mem_write_op = mem_write & not_stall;
    assign branch_op    = branch    & not_stall;
    assign jump_op      = jump      & not_stall;

endmodule
