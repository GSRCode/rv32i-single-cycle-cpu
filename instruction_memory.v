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

        // Same instructions as Logisim
        memory[0] = 32'h20050093;
        memory[1] = 32'h00A00113;
        memory[2] = 32'h002081B3;
    end

    // Asynchronous instruction read
    assign instruction = memory[address];

endmodule