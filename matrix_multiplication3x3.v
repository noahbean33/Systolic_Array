`timescale 1ns / 1ps

module matrix_mul3x3(clk,reset,start
    );

input  clk,reset,start;
wire [15:0] t1,t2,t3,t4,t5,t6;
wire [15:0] x1,x2,x3,x4,x5,x6,x7,x8,x9;
wire [15:0] y1,y2,y3,y4,y5,y6,y7,y8,y9;
wire [15:0] a1,a2,a3,b1,b2,b3;
wire [1:0] ad;

mem_dpr1 m1(clk,ad,a1);
mem_dpr2 m2(clk,ad,a2);
mem_dpr3 m3(clk,ad,a3);
mem_dpr4 m4(clk,ad,b1);
mem_dpr5 m5(clk,ad,b2);
mem_dpr6 m6(clk,ad,b3);
count2 cnt(ad,2'b00,tc,en,clk,reset,tc,2'b11);
pg pg(start,tc,en,clk,reset);


MAC mc1(clk,reset,a1,b1,x1,y1);

reg16 rg1(t1,clk,reset,b2);
MAC mc2(clk,reset,x1,t1,x2,y2);

reg16 rg2(t2,clk,reset,b3);
reg16 rg3(t3,clk,reset,t2);
MAC mc3(clk,reset,x2,t3,x3,y3);

reg16 rg4(t4,clk,reset,a2);
MAC mc4(clk,reset,t4,y1,x4,y4);
MAC mc5(clk,reset,x4,y2,x5,y5);
MAC mc6(clk,reset,x5,y3,x6,y6);

reg16 rg5(t5,clk,reset,a3);
reg16 rg6(t6,clk,reset,t5);
MAC mc7(clk,reset,t6,y4,x7,y7);
MAC mc8(clk,reset,x7,y5,x8,y8);
MAC mc9(clk,reset,x8,y6,x9,y9);

endmodule

module MAC(clk,reset,a,b,a1,b1);
input [15:0] a,b;
output [15:0] a1,b1;
input clk,reset;
wire [15:0] p,p1,p2;

mult m1(a, b, p);
adsub ad1(1'b0,p2,p,p1);
reg16 rg1(p2,clk,reset,p1);
reg16 rg2(a1,clk,reset,a);
reg16 rg3(b1,clk,reset,b);
endmodule

module reg16(y,clk,reset,a);
    input [15:0] a;
    output [15:0] y;
    input clk,reset;
 
DFF d1(y[0],clk,reset,a[0]);
DFF d2(y[1],clk,reset,a[1]);
DFF d3(y[2],clk,reset,a[2]);
DFF d4(y[3],clk,reset,a[3]);
DFF d5(y[4],clk,reset,a[4]);
DFF d6(y[5],clk,reset,a[5]);
DFF d7(y[6],clk,reset,a[6]);
DFF d8(y[7],clk,reset,a[7]);
DFF d9(y[8],clk,reset,a[8]);
DFF d10(y[9],clk,reset,a[9]);
DFF d11(y[10],clk,reset,a[10]);
DFF d12(y[11],clk,reset,a[11]);
DFF d13(y[12],clk,reset,a[12]);
DFF d14(y[13],clk,reset,a[13]);
DFF d15(y[14],clk,reset,a[14]);
DFF d16(y[15],clk,reset,a[15]);
endmodule

module DFF(q,clk,reset,d);
    input d,clk,reset;
    output reg q;
//initial begin q=0; end
always @ (posedge (clk)) begin
 if (reset)
  q <= 0;
 else  
 q<= d ;
end
endmodule


module adsub (sel,c,a,p);
  input sel;
  input [15:0] a,c;
  output [15:0] p;
 assign p = (sel)?(c-a):(c+a);
endmodule

module mult (a, b, p);
  input signed [15:0] a,b;
  output [15:0] p;
  wire [31:0] p1;
  assign p1 = a*b;
  assign p = p1[25:10];
endmodule

module mem_dpr1(clk,a,y);
input clk; input [1:0] a; output reg [15:0] y;
initial begin y = 0; end
always @ (a)
case (a)
'd0 : y = 'd2048;
'd1 : y = 'd1024;
'd2 : y = 'd2048;
endcase

endmodule

module mem_dpr2(clk,a,y);
input clk; input [1:0] a; output reg [15:0] y;
initial begin y = 0; end
always @ (a)
case (a)
'd0 : y = 'd3072;
'd1 : y = 'd2048;
'd2 : y = 'd1024;
endcase
endmodule

module mem_dpr3(clk,a,y);
input clk; input [1:0] a; output reg [15:0] y;
always @ (a)
case (a)
'd0 : y = 'd1024;
'd1 : y = 'd3072;
'd2 : y = 'd1024;
endcase
endmodule

module mem_dpr4(clk,a,y);
input clk; input [1:0] a; output reg [15:0] y;
initial begin y = 0; end
always @ (a)
case (a)
'd0 : y = 'd1024;
'd1 : y = 'd2048;
'd2 : y = 'd4096;
endcase

endmodule

module mem_dpr5(clk,a,y);
input clk; input [1:0] a; output reg [15:0] y;
initial begin y = 0; end
always @ (a)
case (a)
'd0 : y = 'd4096;
'd1 : y = 'd1024;
'd2 : y = 'd2048;
endcase
endmodule

module mem_dpr6(clk,a,y);
input clk; input [1:0] a; output reg [15:0] y;
initial begin y = 0; end
always @ (a)
case (a)
'd0 : y = 'd1024;
'd1 : y = 'd3072;
'd2 : y = 'd4096;
endcase
endmodule

module count2(out,data,load,en,clk,reset,tc,lmt);
output [1:0] out;
output reg tc;
input [1:0] data,lmt;
input load, en, clk,reset;
reg [1:0] out;
//parameter reset=0;

//initial begin out=3'b000; tc =0;end
always @(posedge clk)
if (reset) begin
  out <= 2'b00 ;
end else if (load) begin
  out <= data;
end else if (en)
  out <= out + 2'b01;
else out <= out;
always @(posedge clk)
if (out ==lmt)
tc=1;
else tc=0;
endmodule

module pg(start,tc,q,clk,reset);
	 input start,tc,clk,reset;
	 output  q;
	 
	 wire t1,t2;
	 parameter vdd=1'b1;
	 parameter gnd=1'b0;
    mux M1(t2,vdd,start,q);
	 mux M2(q,gnd,tc,t1);
	 DFF d2(t2,clk,reset,t1);
//    assign  s1 = (start|tc);
endmodule

module mux(A,B,S,Y);

    input  A,B;
    output  Y;
    input S;
 

assign Y = (S)? B : A;
endmodule
