`timescale 1ns/1ps
module rv32i_regression_tb;
  reg clk = 0, reset = 0;
  integer errors = 0, checks = 0, i;
  cpu dut(.clk(clk), .reset(reset));

  function [31:0] addi;
    input [4:0] rd, rs1; input [11:0] imm;
    begin addi = {imm, rs1, 3'b000, rd, 7'h13}; end
  endfunction
  function [31:0] add;
    input [4:0] rd, rs1, rs2;
    begin add = {7'b0, rs2, rs1, 3'b000, rd, 7'h33}; end
  endfunction
  function [31:0] lw;
    input [4:0] rd, rs1; input [11:0] imm;
    begin lw = {imm, rs1, 3'b010, rd, 7'h03}; end
  endfunction
  function [31:0] sw;
    input [4:0] rs2, rs1; input [11:0] imm;
    begin sw = {imm[11:5], rs2, rs1, 3'b010, imm[4:0], 7'h23}; end
  endfunction
  function [31:0] beq;
    input [4:0] rs1, rs2; input [12:0] imm;
    begin beq = {imm[12],imm[10:5],rs2,rs1,3'b000,imm[4:1],imm[11],7'h63}; end
  endfunction
  function [31:0] lui;
    input [4:0] rd; input [19:0] imm;
    begin lui = {imm, rd, 7'h37}; end
  endfunction
  function [31:0] jal;
    input [4:0] rd; input [20:0] imm;
    begin jal = {imm[20],imm[10:1],imm[11],imm[19:12],rd,7'h6f}; end
  endfunction
  function [31:0] jalr;
    input [4:0] rd, rs1; input [11:0] imm;
    begin jalr = {imm,rs1,3'b000,rd,7'h67}; end
  endfunction

  task check;
    input [8*48-1:0] name;
    input [31:0] actual, expected;
    begin
      checks = checks + 1;
      if (actual !== expected) begin
        errors = errors + 1;
        $display("FAIL %-48s expected=%08h actual=%08h", name, expected, actual);
      end else $display("PASS %-48s %08h", name, actual);
    end
  endtask
  task step;
    begin #5 clk = 1; #2 clk = 0; #3; end
  endtask
  initial begin
    // Build one self-contained test program. All offsets are byte offsets.
    for (i=0; i<256; i=i+1) dut.ifetch.imem.memory[i] = 32'h00000013; // nop
    dut.ifetch.imem.memory[0]  = addi(5'd1,5'd0,12'd10);        // x1=10
    dut.ifetch.imem.memory[1]  = addi(5'd2,5'd0,12'd20);        // x2=20
    dut.ifetch.imem.memory[2]  = add(5'd3,5'd1,5'd2);          // x3=30
    dut.ifetch.imem.memory[3]  = sw(5'd3,5'd0,12'd16);         // mem[4]=30
    dut.ifetch.imem.memory[4]  = lw(5'd4,5'd0,12'd16);         // x4=30
    dut.ifetch.imem.memory[5]  = beq(5'd3,5'd4,13'd8);         // taken, skip 6
    dut.ifetch.imem.memory[6]  = addi(5'd5,5'd0,12'd99);       // skipped
    dut.ifetch.imem.memory[7]  = beq(5'd1,5'd2,13'd8);         // not taken
    dut.ifetch.imem.memory[8]  = lui(5'd6,20'h12345);          // x6=12345000
    dut.ifetch.imem.memory[9]  = jal(5'd7,21'd8);              // x7=40, skip 10
    dut.ifetch.imem.memory[10] = addi(5'd8,5'd0,12'd99);       // skipped
    dut.ifetch.imem.memory[11] = addi(5'd9,5'd0,12'd53);       // JALR target: 52
    dut.ifetch.imem.memory[12] = jalr(5'd10,5'd9,12'd0);       // x10=52; target 52
    dut.ifetch.imem.memory[13] = addi(5'd11,5'd0,12'hfff);     // x11=-1
    dut.ifetch.imem.memory[14] = addi(5'd0,5'd0,12'd123);      // x0 remains zero
    dut.ifetch.imem.memory[15] = beq(5'd0,5'd0,13'h1ffc);      // -4: back to 56

    reset=1; #2; check("reset PC",dut.pc,0); reset=0;
    step; check("ADDI x1",dut.regs.registers[1],10); check("PC after ADDI",dut.pc,4);
    step; check("ADDI x2",dut.regs.registers[2],20);
    step; check("ADD x3",dut.regs.registers[3],30);
    step; check("SW memory[4]",dut.dmem.memory[4],30);
    step; check("LW x4",dut.regs.registers[4],30);
    step; check("BEQ taken PC",dut.pc,28); check("BEQ skip x5",dut.regs.registers[5],0);
    step; check("BEQ not taken PC",dut.pc,32);
    step; check("LUI x6",dut.regs.registers[6],32'h12345000);
    step; check("JAL link x7",dut.regs.registers[7],40); check("JAL target PC",dut.pc,44);
    step; check("JAL skip x8",dut.regs.registers[8],0); check("ADDI x9",dut.regs.registers[9],53);
    step; check("JALR link x10",dut.regs.registers[10],52); check("JALR clears bit zero",dut.pc,52);
    step; check("negative ADDI sign extension",dut.regs.registers[11],32'hffffffff);
    step; check("x0 hardwired zero",dut.regs.registers[0],0);
    step; check("negative BEQ offset",dut.pc,56);
    $display("REGRESSION: %0d checks, %0d errors",checks,errors);
    if(errors==0) $display("ALL RV32I REGRESSION CHECKS PASSED");
    else $display("RV32I REGRESSION FAILED");
    $finish;
  end
endmodule
