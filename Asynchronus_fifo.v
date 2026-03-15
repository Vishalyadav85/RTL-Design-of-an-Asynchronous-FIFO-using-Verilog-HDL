`timescale 1ns / 1ps


module Asynchronus_fifo(data_in,w_en,wclk,r_en,rclk,data_out,full,empty,wrst_n,rst_n);
parameter data_width=8, address_width=4;
input [data_width-1:0]data_in;
input w_en;
input wclk;
input r_en;
input rclk;      
input wrst_n;
input rst_n;
output reg [data_width-1:0] data_out;
output full,empty; 
reg [data_width-1:0] memory [0:(1<<address_width-1)-1];
wire [address_width-1:0] b_wptr;
wire [address_width-1:0]b_rptr;
wire [address_width-1:0]g_wptr;
wire [address_width-1:0]g_rptr;
wire [address_width-1:0]g_rptr_sync;
wire [address_width-1:0]g_wptr_sync;

fifo_write  dut(.wclk(wclk),.wrst_n(wrst_n),.w_en(w_en),.full(full),.b_wptr(b_wptr),.g_wptr(g_wptr),.g_rptr_sync(g_rptr_sync));
fifo_read d1 (.rclk(rclk),.g_wptr_sync(g_wptr_sync),.r_en(r_en),.g_rptr(g_rptr),.rst_n(rst_n),.empty(empty),.b_rptr(b_rptr));
ff_write_sync d2(.wrst_n(wrst_n),.wclk(wclk),.g_rptr(g_rptr),.g_rptr_sync(g_rptr_sync));
ff_read_sync d3(.rst_n(rst_n),.rclk(rclk),.g_wptr(g_wptr),.g_wptr_sync(g_wptr_sync));
always@(posedge wclk or posedge w_en)
begin
if(w_en && !full)
begin
memory[b_wptr]<=data_in;
end
end
always@(posedge rclk or posedge r_en)
begin
if(r_en && !empty)
data_out<=memory[b_rptr];
end
endmodule
///////////////**** Write Module of FIFO *********/////////////////
module fifo_write #(parameter address_width=4)(input wclk,
input wrst_n,
input w_en,
input [address_width-1:0]g_rptr_sync,
output reg full,
output reg [address_width-1:0]g_wptr,
output reg [address_width-1:0]b_wptr);
wire [address_width-1:0]b_wptr_next;
wire [address_width-1:0]g_wptr_next;
wire w_full;
assign b_wptr_next= b_wptr +(w_en & ~full);
assign g_wptr_next=(b_wptr_next>>1)^b_wptr_next;
assign w_full=(g_wptr_next =={~(g_rptr_sync[address_width-1:address_width-2]),(g_rptr_sync[address_width-3:0])});
always@(posedge wclk or negedge wrst_n)
begin
if(wrst_n==1'b0)
begin
full<=0;
b_wptr<=0;
g_wptr<=0;
end
else 
begin
b_wptr<=b_wptr_next;
g_wptr<=g_wptr_next;
full<=w_full;
end
end
endmodule 
/////////////**** Read Module of FIFO*********///////////////////////////////
module fifo_read #(parameter address_width=4)(input rclk,
input rst_n,
input r_en,
input [address_width-1:0] g_wptr_sync,
output reg  [address_width-1:0] g_rptr,
output reg [address_width-1:0] b_rptr,
output reg empty
);
wire [address_width-1:0] b_rptr_next;
wire [address_width-1:0] g_rptr_next;
wire rempty;
assign b_rptr_next=b_rptr+(r_en & ~empty);
assign g_rptr_next=(b_rptr_next>>1)^b_rptr_next;
assign rempty=(g_wptr_sync==g_rptr_next);
always@(posedge rclk or negedge rst_n)
begin
if(!rst_n)
begin
b_rptr<=0;
g_rptr<=0;
empty<=1'b1;
end
else
begin
b_rptr<=b_rptr_next;
g_rptr<=g_rptr_next;
empty<=rempty;
end
end
endmodule

///////////******** Synchronise Flip Flop Write Module***********///////////////////

module ff_write_sync #(parameter address_width=4)(input wrst_n,
input wclk,
input [address_width-1:0]g_rptr,
output reg [address_width-1:0]g_rptr_sync);
reg [address_width-1:0] d1;
always@(posedge wclk or negedge wrst_n)
begin
if(!wrst_n)
begin
d1<=0;
g_rptr_sync<=0;
end
else
begin
d1<=g_rptr;
g_rptr_sync<=d1;
end
end
endmodule

//////////********** Synchronise Flip Flop Read Module ***********//////////////////

module ff_read_sync #(parameter address_width=4)(input rst_n,
input rclk,
input [address_width-1:0]g_wptr,
output reg [address_width-1:0]g_wptr_sync);
reg [address_width-1:0] d2;
always@(posedge rclk or negedge rst_n)
begin
if(!rst_n)
begin
d2<=0;
g_wptr_sync<=0;
end
else
begin
d2<=g_wptr;
g_wptr_sync<=d2;
end
end
endmodule