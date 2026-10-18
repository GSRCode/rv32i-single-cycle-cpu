`timescale 1ns/1ps
module cpu_tb;
 reg clk=0,reset=1;
 wire [31:0] debug_pc;
 wire stall,flush;
 cpu dut(.clock(clk),.reset(reset),.debug_pc(debug_pc),.stall(stall),.flush(flush));
 always #5 clk=~clk;
 integer cycles=0,stalls=0,flushes=0,errors=0;
 task check_reg(input integer r,input [31:0] expected);
 begin
   if(dut.IDecode1.regs[r] !== expected) begin
     $display("FAIL x%0d expected=%h actual=%h",r,expected,dut.IDecode1.regs[r]);errors=errors+1;
   end else $display("PASS x%0d=%h",r,expected);
 end endtask
 task check_mem(input integer a,input [31:0] expected);
 begin
   if(dut.Memory1.dmem[a] !== expected) begin
     $display("FAIL memory[%0d] expected=%h actual=%h",a,expected,dut.Memory1.dmem[a]);errors=errors+1;
   end else $display("PASS memory[%0d]=%h",a,expected);
 end endtask
 always @(posedge clk) if(!reset) begin
   cycles=cycles+1;
   if(stall) stalls=stalls+1;
   if(flush) flushes=flushes+1;
 end
 always @(posedge clk) begin
    if (!reset && dut.br_taken) begin
        $display(
            "REDIRECT: PC=%08h target=%08h JAL=%b JALR=%b BEQ=%b",
            dut.ex_pc,
            dut.br_target,
            dut.ex_jal,
            dut.ex_jalr,
            dut.ex_beq
        );
    end
end
 initial begin
   $dumpfile("cpu_wave.vcd");$dumpvars(0,cpu_tb);
   $readmemh("program.hex",dut.IFetch1.imem,0,27);
   repeat(3) @(negedge clk);
   reset=0;
   repeat(65) @(negedge clk);
   check_reg(1,5); check_reg(2,8);check_reg(3,13);
   check_reg(4,13);check_reg(5,13);check_reg(6,18);
   check_reg(7,0);check_reg(8,40);check_reg(9,68);
   check_reg(10,52);check_reg(11,44);check_reg(12,0);   
   check_reg(13,32'h00001007);check_reg(14,9);check_reg(15,13);check_reg(16,13);check_reg(17,13);
   check_mem(0,13);check_mem(1,18);check_mem(2,13);
   if(stalls<1) begin $display("FAIL expected load-use stall");errors=errors+1;end
   if(flushes<3) begin $display("FAIL expected BEQ/JAL/JALR flushes");errors=errors+1;end
   $display("cycles=%0d stalls=%0d redirects=%0d errors=%0d",cycles,stalls,flushes,errors);
   if(errors==0) $display("PASS: FULL PIPELINE REGRESSION");
   else $display("FAIL: FULL PIPELINE REGRESSION");
   $finish;
 end
endmodule
