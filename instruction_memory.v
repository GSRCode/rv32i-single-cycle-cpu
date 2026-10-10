module instruction_memory (
    input wire [7:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];

    integer i;

    initial begin
        // Initialize memory
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000000;

        // ADDI x1, x0, 40; SW x1, 8(x0); LW x2, 8(x0)
        memory[0] = 32'h02800093;
        memory[1] = 32'h00102423;
        memory[2] = 32'h00802103;

    end

    // Asynchronous instruction read
    assign instruction = memory[address];

endmodule