
module cpu (
    input  wire clock,
    input  wire reset,
    input  wire        imem_write_enable,
    input  wire [7:0]  imem_write_address,
    input  wire [31:0] imem_write_data,
    output wire stall,
    output wire [7:0] debug_pc,
    output wire [7:0] debug_wb_data,
    output wire [4:0] debug_wb_rd
);

    // ============================================
    // 1. Instruction Fetch (IF)
    // ============================================

    wire not_stall = ~stall;

    wire [31:0] if_pc;
    wire [31:0] if_instruction;
    wire [31:0] ifid_pc;
    wire [31:0] ifid_instruction;

    wire [31:0] br_target;
    wire br_taken;

    IFetch Ifetch1 (
        .clock(clock),
        .reset(reset),
        .not_stall(not_stall),
        .br_taken(br_taken),
        .br_target(br_target),
        .imem_write_enable(imem_write_enable),
        .imem_write_address(imem_write_address),
        .imem_write_data(imem_write_data),
        .pc(if_pc),
        .instruction(if_instruction)
    );


    // ============================================
    // 2. IF/ID Pipeline Registers
    // ============================================

    reg [31:0] ifid_instruction_reg;
    reg [31:0] ifid_pc_reg;

    assign ifid_instruction = ifid_instruction_reg;
    assign ifid_pc = ifid_pc_reg;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            ifid_instruction_reg <= 0;
            ifid_pc_reg <= 0;
        end
        else if (not_stall) begin
            ifid_instruction_reg <= br_taken
                ? 32'h00000013
                : if_instruction;

            ifid_pc_reg <= br_taken
                ? 32'b0
                : if_pc;
        end
    end


    // ============================================
    // 3. Instruction Decode (ID)
    // ============================================

    wire [6:0] opcode;
    wire [6:0] funct7;

    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;

    wire [2:0] funct3;
    wire [1:0] result_src;

    wire alu_src;
    wire mem_read;
    wire mem_write;
    wire reg_write;
    wire branch;
    wire alu_sub;
    wire jump;
    wire jalr;

    wire [31:0] id_data1;
    wire [31:0] id_data2;
    wire [31:0] id_imm;
    wire [31:0] id_pc;

    wire [31:0] wb_data;
    wire [4:0] wb_rd;
    wire wb_reg_write;

    // Synthesis-visible debug outputs (no datapath changes)
    assign debug_pc      = if_pc[7:0];
    assign debug_wb_data = wb_data[7:0];
    assign debug_wb_rd   = wb_rd;

    IDecode IDecode1 (
        .instruction(ifid_instruction),
        .pc(ifid_pc),
        .reset(reset),
        .clock(clock),

        .wb_reg_write(wb_reg_write),
        .wb_data(wb_data),
        .wb_rd(wb_rd),

        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),

        .result_src(result_src),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .branch(branch),
        .alu_sub(alu_sub),
        .jump(jump),
        .jalr(jalr),

        .read_data_1(id_data1),
        .read_data_2(id_data2),
        .immediate(id_imm),
        .pc_op(id_pc)
    );


    // ============================================
    // 4. Bubble Control
    // ============================================

    wire flush_enable = ~br_taken;

    wire b_jalr;
    wire b_reg_write;
    wire b_mem_read;
    wire b_mem_write;
    wire b_branch;
    wire b_jump;

    BubbleControl BubbleCtrl1 (
        .jalr(jalr & flush_enable),
        .reg_write(reg_write & flush_enable),
        .mem_read(mem_read & flush_enable),
        .mem_write(mem_write & flush_enable),
        .branch(branch & flush_enable),
        .jump(jump & flush_enable),

        .not_stall(not_stall),

        .jalr_op(b_jalr),
        .reg_write_op(b_reg_write),
        .mem_read_op(b_mem_read),
        .mem_write_op(b_mem_write),
        .branch_op(b_branch),
        .jump_op(b_jump)
    );


    // ============================================
    // 5. ID/EX Pipeline Register
    // ============================================

    wire ex_jalr;
    wire ex_jump;
    wire ex_branch;
    wire ex_reg_write;
    wire ex_mem_read;
    wire ex_mem_write;
    wire ex_alu_src;
    wire ex_alu_sub;

    wire [31:0] ex_pc;
    wire [31:0] ex_data1;
    wire [31:0] ex_data2;
    wire [31:0] ex_imm;

    wire [4:0] ex_rd;
    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;

    wire [1:0] ex_result_src;
    wire [2:0] ex_funct3;
    wire [6:0] ex_funct7;

    ID_EX ID_ex1 (
        .clock(clock),
        .reset(reset),
        .enable(1'b1),

        .pc(id_pc),
        .read_data_1(id_data1),
        .read_data_2(id_data2),
        .immediate(id_imm),

        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),

        .result_src(result_src),
        .alu_src(alu_src),
        .mem_read(b_mem_read),
        .mem_write(b_mem_write),
        .reg_write(b_reg_write),
        .branch(b_branch),
        .alu_sub(alu_sub),
        .jump(b_jump),
        .jalr(b_jalr),

        .ex_pc(ex_pc),
        .ex_read_data_1(ex_data1),
        .ex_read_data_2(ex_data2),
        .ex_immediate(ex_imm),

        .ex_rd(ex_rd),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_funct3(ex_funct3),
        .ex_funct7(ex_funct7),

        .ex_result_src(ex_result_src),
        .ex_alu_src(ex_alu_src),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_reg_write(ex_reg_write),
        .ex_branch(ex_branch),
        .ex_alu_sub(ex_alu_sub),
        .ex_jump(ex_jump),
        .ex_jalr(ex_jalr)
    );


    // ============================================
    // 6. Hazard Detection
    // ============================================

    HazardDetectionUnit HazardDetectUnit1 (
        .ex_rd(ex_rd),
        .rs1(rs1),
        .rs2(rs2),
        .ex_mem_read(ex_mem_read),
        .stall(stall)
    );


    // ============================================
    // 7. Data Forwarding
    // ============================================

    wire [31:0] fwd_data1;
    wire [31:0] fwd_data2;
    wire [31:0] alu_result;

    wire [4:0] ex_rs2_op;

    wire [31:0] mem_pc;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_read_data2;
    wire [31:0] mem_imm;

    wire [4:0] mem_rd;
    wire [4:0] mem_rs2;

    wire [1:0] mem_result_src;

    wire mem_mem_read;
    wire mem_mem_write;
    wire mem_reg_write;
    wire mem_jump;

    ForwardingUnit ForwardingUnit1 (
        .ex_read_data_1(ex_data1),
        .ex_read_data_2(ex_data2),

        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),

        .mem_rd(mem_rd),
        .mem_alu_result(mem_alu_result),
        .mem_reg_write(mem_reg_write),
        .mem_mem_read(mem_mem_read),

        .wb_rd(wb_rd),
        .wb_data(wb_data),
        .wb_reg_write(wb_reg_write),

        .read_data_1(fwd_data1),
        .read_data_2(fwd_data2),
        .ex_rs2_op(ex_rs2_op)
    );


    // ============================================
    // 8. Execute Stage (EX)
    // ============================================

    wire zero;

    Execute Execute1 (
        .pc(ex_pc),

        .read_data_1(fwd_data1),
        .read_data_2(fwd_data2),
        .immediate(ex_imm),

        .alu_src(ex_alu_src),
        .alu_sub(ex_alu_sub),

        .branch(ex_branch),
        .jump(ex_jump),
        .jalr(ex_jalr),

        .result(alu_result),
        .zero(zero),

        .br_target(br_target),
        .br_taken(br_taken)
    );


    // ============================================
    // 9. EX/MEM Pipeline Register
    // ============================================

    EX_MEM EX_MEM1 (
        .clock(clock),
        .reset(reset),
        .enable(1'b1),

        .pc(ex_pc),
        .alu_result(alu_result),
        .read_data_2(fwd_data2),

        .rd(ex_rd),
        .immediate(ex_imm),
        .result_src(ex_result_src),

        .mem_read(ex_mem_read),
        .mem_write(ex_mem_write),
        .reg_write(ex_reg_write),
        .jump(ex_jump),

        .ex_rs2(ex_rs2_op),

        .mem_pc(mem_pc),
        .mem_alu_result(mem_alu_result),
        .mem_read_data_2(mem_read_data2),

        .mem_rd(mem_rd),
        .mem_immediate(mem_imm),
        .mem_result_src(mem_result_src),

        .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write),
        .mem_reg_write(mem_reg_write),
        .mem_jump(mem_jump),
        .mem_rs2(mem_rs2)
    );


    // ============================================
    // 10. Store Data Forwarding
    // ============================================

    wire [31:0] mem_store_data;
    wire [31:0] mem_read_data;

    StoreForwardingUnit StoreFwd1 (
        .mem_mem_write(mem_mem_write),
        .wb_reg_write(wb_reg_write),

        .wb_rd(wb_rd),
        .mem_rs2(mem_rs2),

        .mem_read_data_2(mem_read_data2),
        .wb_data(wb_data),

        .mem_store_data(mem_store_data)
    );


    // ============================================
    // 11. Memory Stage (MEM)
    // ============================================

    Memory Mem1 (
        .clock(clock),

        .mem_write(mem_mem_write),
        .mem_read(mem_mem_read),

        .address(mem_alu_result),
        .write_data(mem_store_data),

        .read_data(mem_read_data)
    );


    // ============================================
    // 12. MEM/WB Pipeline Register
    // ============================================

    wire [31:0] wb_pc;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_read_data;
    wire [31:0] wb_imm;

    wire [1:0] wb_result_src;

    MEM_WB Mem_wb1 (
        .clock(clock),
        .reset(reset),
        .enable(1'b1),

        .pc(mem_pc),
        .alu_result(mem_alu_result),
        .read_data(mem_read_data),

        .rd(mem_rd),
        .immediate(mem_imm),
        .result_src(mem_result_src),
        .reg_write(mem_reg_write),

        .wb_pc(wb_pc),
        .wb_alu_result(wb_alu_result),
        .wb_read_data(wb_read_data),

        .wb_rd(wb_rd),
        .wb_immediate(wb_imm),
        .wb_result_src(wb_result_src),
        .wb_reg_write(wb_reg_write),
        .wb_data(wb_data)
    );

endmodule
