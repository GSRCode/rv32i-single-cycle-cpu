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

        // BEQ taken: x1 == x2, skip x3 = 99
        memory[0] = 32'h00500093; // addi x1, x0, 5
        memory[1] = 32'h00500113; // addi x2, x0, 5
        memory[2] = 32'h00208463; // beq  x1, x2, 8
        memory[3] = 32'h06300193; // addi x3, x0, 99 (skipped)
        memory[4] = 32'h02a00193; // addi x3, x0, 42

    end

    // Asynchronous instruction read
    assign instruction = memory[address];

endmodule