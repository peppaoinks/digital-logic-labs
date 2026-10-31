`timescale 1ns/1ps
module dff_verify;
reg clk=0, clr=0, en=0, d=0;
wire q;
reg expected=0;
integer cycle, checks=0;
reg [31:0] rng=32'h1ab2c3d4;
dff u_dff(.clk(clk),.clr(clr),.en(en),.d(d),.q(q));
always #5 clk=~clk;
task check;
begin
 if(q !== expected) $fatal(1,"DFF mismatch at %t",$time);
 checks=checks+1;
end
endtask
initial begin
 #2; clr=1; #1; check; #1; clr=0;
 for(cycle=0;cycle<1000;cycle=cycle+1) begin
  @(negedge clk);
  rng=rng^(rng<<13); rng=rng^(rng>>17); rng=rng^(rng<<5);
  en=rng[0]; d=rng[1];
  #1; check;
  if(rng[4:2]==0) begin
   clr=1; expected=0; #0.1; check;
  end
  @(posedge clk);
  if(clr) expected=0;
  else if(en) expected=d;
  #0.1; check;
  #1; clr=0;
 end
 $display("PASS independent dff: %0d checks; 1000 mixed cycles",checks);
 $finish;
end
endmodule
