
`timescale 1ns/1ps

module StoreForwardingUnit (
    input  wire        mem_mem_write,
    input  wire        wb_reg_write,
    input  wire [4:0]  wb_rd,
    input  wire [4:0]  mem_rs2,
    input  wire [31:0] mem_read_data_2,
    input  wire [31:0] wb_data,

    output wire [31:0] mem_store_data
);

    // Comparators from Logisim
    wire rd_not_zero = (wb_rd != 5'd0);
    wire rd_matches_rs2 = (wb_rd == mem_rs2);

    // Four-input AND gate
    wire forward_store;

    assign forward_store = mem_mem_write &
                           wb_reg_write &
                           rd_not_zero &
                           rd_matches_rs2;

    // Store-data multiplexer
    assign mem_store_data = forward_store
                          ? wb_data
                          : mem_read_data_2;

endmodule
