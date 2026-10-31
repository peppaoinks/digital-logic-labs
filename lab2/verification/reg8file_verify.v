`timescale 1ns/1ps
module reg8file_verify;
reg clk = 0;
reg clr = 0;
reg en = 0;
reg [7:0] d = 0;
reg [2:0] wsel = 0;
reg [2:0] rsel = 0;
wire [7:0] q;
reg [7:0] model [0:7];
integer addr, value, read_addr, cycle;
integer checks = 0;
reg [31:0] rng = 32'h197ab321;
reg [31:0] bits;
reg8file u_reg8file(.clk(clk),.clr(clr),.en(en),.d(d),.wsel(wsel),.rsel(rsel),.q(q));
always #5 clk = ~clk;
task check;
begin
 if(q !== model[rsel]) $fatal(1,"Mismatch time=%t addr=%d expected=%h actual=%h",$time,rsel,model[rsel],q);
 checks = checks+1;
end
endtask
task clear_model;
integer k;
begin for(k=0;k<8;k=k+1) model[k]=0; end
endtask
initial begin
 #2; clr=1; clear_model;
 #1; check;
 #1; clr=0;
 for(addr=0;addr<8;addr=addr+1) begin
  for(value=0;value<256;value=value+1) begin
   @(negedge clk); en=1; wsel=addr; d=value;
   #1; check;
   @(posedge clk); model[addr]=value;
   #0.1;
   for(read_addr=0;read_addr<8;read_addr=read_addr+1) begin
    rsel=read_addr; #0.1; check;
   end
  end
 end
 for(cycle=0;cycle<1000;cycle=cycle+1) begin
  @(negedge clk);
  rng=rng^(rng<<13); rng=rng^(rng>>17); rng=rng^(rng<<5); bits=rng;
  en=bits[0]; wsel=bits[3:1]; rsel=bits[6:4]; d=bits[14:7];
  #1; check;
  if(bits[18:15]==0) begin
   clr=1; clear_model;
   #0.1; check;
  end
  @(posedge clk);
  if(clr) clear_model;
  else if(en) model[wsel]=d;
  #0.1; check;
  #1; clr=0;
 end
 @(negedge clk); en=0; #2; clr=1; clear_model;
 for(read_addr=0;read_addr<8;read_addr=read_addr+1) begin
  rsel=read_addr; #0.1; check;
 end
 $display("PASS independent reg8file: %0d checks; 2048 address/data writes + 1000 mixed cycles",checks);
 $finish;
end
endmodule
