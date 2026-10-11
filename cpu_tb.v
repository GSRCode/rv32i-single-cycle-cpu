`timescale 1ns/1ps
module cpu_tb;
reg clk=0, reset=1;
cpu dut(.clk(clk),.reset(reset));
integer errors=0;
task check_pc;
 input [31:0] expected;
 begin
  if(dut.pc !== expected) begin $display("FAIL PC expected %h got %h",expected,dut.pc); errors=errors+1; end
  else $display("PASS PC = %h",dut.pc);
 end
endtask
task step;
 begin #5 clk=1; #1; clk=0; #4; end
endtask
initial begin
 #2; reset = 0;
 #2; reset = 1;
 #2; reset = 0;
 #2; check_pc(0); reset=0;
 step; check_pc(8); if(dut.regs.registers[1] !== 4) errors=errors+1;
 step; check_pc(12); if(dut.regs.registers[3] !== 5) errors=errors+1;
 step; check_pc(4);
 step; check_pc(8); if(dut.regs.registers[4] !== 42) errors=errors+1;
 if(errors==0) $display("ALL JALR TESTS PASSED"); else $display("FAIL: %0d errors",errors);
 $finish;
end
endmodule
