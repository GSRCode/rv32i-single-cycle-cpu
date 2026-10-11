module control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        reg_write,
    output reg  [1:0] operation,
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        branch,
    output reg        lui,
    output reg        jal,
    output reg        jalr,
    output reg        mem_write
);

    always @(*) begin
        // Default values
        reg_write = 1'b0;
        operation = 2'b00;
        alu_src   = 1'b0;
        mem_to_reg = 1'b0;
        mem_write = 1'b0;
        branch = 1'b0;
        lui = 1'b0;
        jal = 1'b0;
        jalr = 1'b0;

        // ADD
        if (opcode == 7'h33 &&
            funct3 == 3'b000 &&
            funct7 == 7'b0000000) begin

            reg_write = 1'b1;
            operation = 2'b00;
            alu_src   = 1'b0;
        end

        // ADDI
        else if (opcode == 7'h13 &&
                 funct3 == 3'b000) begin

            reg_write = 1'b1;
            operation = 2'b00;
            alu_src   = 1'b1;
        end

        else if (opcode == 7'h03 &&
         funct3 == 3'b010) begin

            reg_write  = 1'b1;
            operation  = 2'b00;
            alu_src    = 1'b1;
            mem_to_reg = 1'b1;
        end
        // SW: store rs2 at address rs1 + S-type immediate
        else if (opcode == 7'h23 && funct3 == 3'b010) begin
            reg_write = 1'b0;
            operation = 2'b00;
            alu_src = 1'b1;
            mem_write = 1'b1;
        end
        // LUI
        else if (opcode == 7'h37) begin
            reg_write = 1'b1;
            lui = 1'b1;
        end
        // JAL
        else if (opcode == 7'h6f) begin
            reg_write = 1'b1;
            jal = 1'b1;
        end
        // JALR
        else if (opcode == 7'h67 && funct3 == 3'b000) begin
            reg_write = 1'b1;
            alu_src = 1'b1;
            operation = 2'b00;
            jalr = 1'b1;
        end
        // BEQ
        else if (opcode == 7'h63 && funct3 == 3'b000) begin
            branch = 1'b1;
        end
    end

endmodule