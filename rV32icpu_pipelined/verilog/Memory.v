
`timescale 1ns/1ps

module Memory (
    input  wire        clock,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [31:0] address,
    input  wire [31:0] write_data,

    output wire [31:0] read_data
);

    // Logisim RAM: 256 words, each 32 bits wide
    reg [31:0] DataRam1 [0:255];

    // Address splitter: bits 9 through 2
    wire [7:0] ram_address;
    assign ram_address = address[9:2];

    // Synchronous write
    always @(posedge clock) begin
        if (mem_write)
            DataRam1[ram_address] <= write_data;
    end

    // Asynchronous read with output enable
    assign read_data = mem_read
                     ? DataRam1[ram_address]
                     : 32'bz;

endmodule
