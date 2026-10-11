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

        // JAL -> function -> JALR -> return
        memory[0] = 32'h008000ef; // jal x1, 8
        memory[1] = 32'h02a00213; // addi x4, x0, 42
        memory[2] = 32'h00500193; // addi x3, x0, 5
        memory[3] = 32'h00008067; // jalr x0, 0(x1)

    end

    // Asynchronous instruction read
    assign instruction = memory[address];

endmodule