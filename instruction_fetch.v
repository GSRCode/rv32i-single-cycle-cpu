module instruction_fetch (
    input wire clk,
    input wire reset,
    output wire [31:0] pc,
    output wire [31:0] instruction
);

    reg [31:0] pc_reg;

    // Program counter
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 32'h00000000;
        else
            pc_reg <= pc_reg + 32'd4;
    end

    assign pc = pc_reg;

    // Instruction memory
    instruction_memory imem (
        .address(pc_reg[9:2]),
        .instruction(instruction)
    );

endmodule