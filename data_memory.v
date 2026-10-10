module data_memory (
    input  wire clk,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    input  wire mem_write,
    output wire [31:0] read_data
);

    reg [31:0] memory [0:255];

    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000000;

        memory[0] = 32'h0000000A;
        memory[1] = 32'h00000014;
        memory[2] = 32'h0000001E;
        memory[3] = 32'h00000028;
    end

    // Convert byte address to word index
    assign read_data = memory[address[9:2]];

    always @(posedge clk) begin
        if (mem_write)
            memory[address[9:2]] <= write_data;
    end

endmodule