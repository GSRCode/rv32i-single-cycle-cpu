`timescale 1ns/1ps
module sw_tb;
  reg clk = 0;
  reg reset = 1;
  cpu dut(.clk(clk), .reset(reset));
  task tick;
    begin
      #5 clk = 1;
      #1;
      clk = 0;
      #4;
    end
  endtask
  initial begin
    #2 reset = 0;
    tick(); // ADDI
    if (dut.regs.registers[1] !== 32'd40) $fatal(1,"FAIL ADDI");
    $display("PASS ADDI x1=40");
    tick(); // SW
    if (dut.dmem.memory[2] !== 32'd40) $fatal(1,"FAIL SW");
    $display("PASS SW memory[2]=40");
    tick(); // LW
    if (dut.regs.registers[2] !== 32'd40) $fatal(1,"FAIL LW");
    $display("PASS LW x2=40");
    $finish;
  end
endmodule
