
`timescale 1ns/1ps

module register_file_tb;

    reg clk;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] write_data;
    reg reg_write;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    register_file uut (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, register_file_tb);

        clk = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        write_data = 0;
        reg_write = 0;

        // Write 10 to x1
        @(negedge clk);
        rd = 1;
        write_data = 10;
        reg_write = 1;

        @(negedge clk);
        rd = 2;
        write_data = 20;

        // Disable writing
        @(negedge clk);
        reg_write = 0;

        // Read x1 and x2
        rs1 = 1;
        rs2 = 2;
        #1;
        $display("x1 = %d, x2 = %d",
                 read_data1, read_data2);

        // Attempt to write 99 to x0
        rd = 0;
        write_data = 99;
        reg_write = 1;

        @(negedge clk);
        reg_write = 0;

        rs1 = 0;
        rs2 = 1;
        #1;
        $display("x0 = %d, x1 = %d",
                 read_data1, read_data2);

        if (read_data1 !== 0 ||
            read_data2 !== 10)
            $display("FAIL: x0 test");
        else
            $display("PASS: x0 test");

        $finish;
    end

endmodule
