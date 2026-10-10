module cpu (
    input wire clk,
    input wire reset
);

    wire [31:0] pc;
    wire [31:0] instruction;

    // Instruction fields
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;

    // Immediate
    wire [11:0] immediate;
    wire [31:0] immediate_extended;

    // Register file
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    // ALU
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire [31:0] memory_read_data;
    wire [31:0] writeback_data;
    wire zero;

    // Control
    wire reg_write;
    wire [1:0] operation;
    wire alu_src;
    wire mem_to_reg;
    wire mem_write;

    // Instruction Fetch
    instruction_fetch ifetch (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction(instruction)
    );

    // Extract instruction fields
    assign opcode    = instruction[6:0];
    assign rd        = instruction[11:7];
    assign funct3    = instruction[14:12];
    assign rs1       = instruction[19:15];
    assign rs2       = instruction[24:20];
    assign funct7    = instruction[31:25];

    // Extract and sign-extend immediate
    assign immediate = (opcode == 7'h23)
                     ? {instruction[31:25], instruction[11:7]}
                     : instruction[31:20];

    assign immediate_extended = {{20{immediate[11]}}, immediate};

    // Control Unit
    control ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .operation(operation),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write)
    );

    // Register File
    register_file regs (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(writeback_data),
        .reg_write(reg_write),
        .read_data1(read_data_1),
        .read_data2(read_data_2)
    );

    // ALU input multiplexer
    assign alu_operand_b = alu_src ? immediate_extended : read_data_2;

    // ALU
    alu alu_unit (
        .a(read_data_1),
        .b(alu_operand_b),
        .operation(operation),
        .result(alu_result),
        .zero(zero)
    );

    data_memory dmem (
        .clk(clk),
        .address(alu_result),
        .write_data(read_data_2),
        .mem_write(mem_write),
        .read_data(memory_read_data)
    );

    assign writeback_data =
        mem_to_reg ? memory_read_data : alu_result;

endmodule