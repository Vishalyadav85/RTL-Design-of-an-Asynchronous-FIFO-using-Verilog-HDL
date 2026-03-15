`timescale 1ns/1ps

module async_fifo_tb;

parameter data_width = 8;
parameter address_width = 4;

reg [data_width-1:0] data_in;
reg w_en;
reg r_en;
reg wclk;
reg rclk;
reg wrst_n;
reg rst_n;

wire [data_width-1:0] data_out;
wire full;
wire empty;

Asynchronus_fifo DUT (
    .data_in(data_in),
    .w_en(w_en),
    .wclk(wclk),
    .r_en(r_en),
    .rclk(rclk),
    .data_out(data_out),
    .full(full),
    .empty(empty),
    .wrst_n(wrst_n),
    .rst_n(rst_n)
);

////////////////////////////////////////////////
// Write Clock (10ns)
////////////////////////////////////////////////
always #5 wclk = ~wclk;

////////////////////////////////////////////////
// Read Clock (14ns)
////////////////////////////////////////////////
always #7 rclk = ~rclk;

////////////////////////////////////////////////
// Test Procedure
////////////////////////////////////////////////
initial
begin

$dumpfile("fifo.vcd");
$dumpvars(0,async_fifo_tb);

wclk = 0;
rclk = 0;
w_en = 0;
r_en = 0;
data_in = 0;
wrst_n = 0;
rst_n = 0;

#20;
wrst_n = 1;
rst_n = 1;

////////////////////////////////////////////////
// Write Data
////////////////////////////////////////////////

#10;
repeat(10)
begin
@(posedge wclk);
w_en = 1;
data_in = $random;
end

@(posedge wclk);
w_en = 0;

////////////////////////////////////////////////
// Read Data
////////////////////////////////////////////////

#50;

repeat(10)
begin
@(posedge rclk);
r_en = 1;
end

@(posedge rclk);
r_en = 0;

#100;
$finish;

end

endmodule
