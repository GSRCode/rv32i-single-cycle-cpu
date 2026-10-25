module RV32I_FPGA_Top (
    input  wire clk,
    input  wire key,
    output wire led,
    output wire uart_tx_pin
);
    wire reset = ~key;
    wire [7:0] debug_pc;
    wire [7:0] debug_wb_data;
    wire [31:0] debug_wb_data_full;
    wire [4:0] debug_wb_rd;
    wire stall;
    wire debug_wb_reg_write;

    reg success = 1'b0;
    reg failure = 1'b0;
    reg [6:0] checks = 7'b0;
    // x3, x4, x5, x6, x8, x9, x10 must all commit correctly.
    // x11 is the final success marker; x7 must never be written.
    reg [7:0] stall_count = 8'd0;

    always @(posedge clk or posedge reset) begin
        if (reset)
            stall_count <= 8'd0;
        else if (stall && stall_count != 8'hFF)
            stall_count <= stall_count + 1'b1;
    end


    cpu cpu1 (
        .clock(clk),
        .reset(reset),
        .imem_write_enable(1'b0),
        .imem_write_address(8'b0),
        .imem_write_data(32'b0),
        .stall(stall),
        .debug_pc(debug_pc),
        .debug_wb_data(debug_wb_data),
        .debug_wb_data_full(debug_wb_data_full),
        .debug_wb_rd(debug_wb_rd),
        .debug_wb_reg_write(debug_wb_reg_write)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            success <= 1'b0;
            failure <= 1'b0;
            checks <= 7'b0;
        end else if (!success && !failure && debug_wb_reg_write) begin
            case (debug_wb_rd)
                5'd3:  if (debug_wb_data_full == 32'd8)    checks[0] <= 1'b1;
                       else failure <= 1'b1;
                5'd4:  if (debug_wb_data_full == 32'd8)    checks[1] <= 1'b1;
                       else failure <= 1'b1;
                5'd5:  if (debug_wb_data_full == 32'd13)   checks[2] <= 1'b1;
                       else failure <= 1'b1;
                5'd6:  if (debug_wb_data_full == 32'd4096) checks[3] <= 1'b1;
                       else failure <= 1'b1;
                5'd7:  failure <= 1'b1; // Branch/jump-skipped write
                5'd8:  if (debug_wb_data_full == 32'd40)   checks[4] <= 1'b1;
                       else failure <= 1'b1;
                5'd9:  if (debug_wb_data_full == 32'd56)   checks[5] <= 1'b1;
                       else failure <= 1'b1;
                5'd10: if (debug_wb_data_full == 32'd52)   checks[6] <= 1'b1;
                       else failure <= 1'b1;
                5'd11: if (debug_wb_data_full == 32'd1 && &checks && stall_count != 0) success <= 1'b1;
                       else failure <= 1'b1;
                default: ;
            endcase
        end
    end

    assign led = success;

    // Send exactly one line after the CPU test passes.
    localparam WAIT_PASS = 3'd0;
    localparam WAIT_READY = 3'd1;
    localparam SEND_PULSE = 3'd2;
    localparam WAIT_BUSY = 3'd3;
    localparam WAIT_COMPLETE = 3'd4;
    localparam FINISHED = 3'd5;

    reg [2:0] tx_state = WAIT_PASS;
    reg [4:0] char_index = 5'd0;
    reg tx_data_valid = 1'b0;
    wire tx_data_ready;
    wire [7:0] tx_data;

    function [7:0] message_char;
        input [4:0] index;
        begin
            case (index)
                5'd0:  message_char = "R";
                5'd1:  message_char = "V";
                5'd2:  message_char = "3";
                5'd3:  message_char = "2";
                5'd4:  message_char = "I";
                5'd5:  message_char = " ";
                5'd6:  message_char = "T";
                5'd7:  message_char = "E";
                5'd8:  message_char = "S";
                5'd9:  message_char = "T";
                5'd10: message_char = " ";
                5'd11: message_char = "P";
                5'd12: message_char = "A";
                5'd13: message_char = "S";
                5'd14: message_char = "S";
                5'd15: message_char = 8'h0D;
                5'd16: message_char = 8'h0A;
                default: message_char = 8'h00;
            endcase
        end
    endfunction

    assign tx_data = message_char(char_index);

    uart_tx #(
        .CLK_FRE(50),
        .BAUD_RATE(115200)
    ) uart_tx_inst (
        .clk(clk),
        .rst_n(~reset),
        .tx_data(tx_data),
        .tx_data_valid(tx_data_valid),
        .tx_data_ready(tx_data_ready),
        .tx_pin(uart_tx_pin)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_state <= WAIT_PASS;
            char_index <= 5'd0;
            tx_data_valid <= 1'b0;
        end else begin
            case (tx_state)
                WAIT_PASS:
                    if (success)
                        tx_state <= WAIT_READY;
                WAIT_READY:
                    if (tx_data_ready)
                        tx_state <= SEND_PULSE;
                SEND_PULSE: begin
                    tx_data_valid <= 1'b1;
                    tx_state <= WAIT_BUSY;
                end
                WAIT_BUSY:
                    if (!tx_data_ready) begin
                        tx_data_valid <= 1'b0;
                        tx_state <= WAIT_COMPLETE;
                    end
                WAIT_COMPLETE:
                    if (tx_data_ready) begin
                        if (char_index == 5'd16)
                            tx_state <= FINISHED;
                        else begin
                            char_index <= char_index + 5'd1;
                            tx_state <= WAIT_READY;
                        end
                    end
                FINISHED:
                    tx_data_valid <= 1'b0;
                default:
                    tx_state <= WAIT_PASS;
            endcase
        end
    end
endmodule
