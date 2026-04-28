`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2025 12:16:11 PM
// Design Name: 
// Module Name: digital_oscilloscope_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module butterfly_single_tb();
// Test Inputs
reg clk_100mhz_t;
reg rst_n_i_t;
reg en_i_t;
reg signed [15:0] a_r;
reg signed [15:0] a_i;
reg signed [15:0] b_r;
reg signed [15:0] b_i;
reg signed [15:0] w_r;
reg signed [15:0] w_i;
// Test Outputs
wire signed [15:0] c_r;
wire signed [15:0] c_i;
wire signed [15:0] d_r;
wire signed [15:0] d_i;
wire valid_t;

always #(5) clk_100mhz_t= ~clk_100mhz_t;

initial
begin
    clk_100mhz_t = 0;
    rst_n_i_t = 0;
    en_i_t = 0;
    shift_i_t = 0;

    
    @(posedge clk_100mhz_t);
    en_i_t <= 1;
    repeat(5) @(posedge clk_100mhz_t);
    en_i_t <= 0;
    @(posedge clk_100mhz_t);
    rst_n_i_t <= 1;
    
    //Not Shifted
    @(posedge clk_100mhz_t);
    w_r <= 16'h1000; //+1.0
    w_i <= 16'h0000; //+0.0
    a_r <= 16'h1000; //+1.0
    a_i <= 16'h0000; //+0.0
    b_r <= 16'h1000; //+1.0
    b_i <= 16'h0000; //+0.0

    en_i_t <= 1;
    @(posedge clk_100mhz_t); 
    a_r <= 16'h1000; //+1.0
    a_i <= 16'h0000; //+0.0
    b_r <= 16'hf000; //-1.0
    b_i <= 16'h0000; //+0.0
    @(posedge clk_100mhz_t); 
    a_r <= 16'h1000; //+1.0
    a_i <= 16'h1000; //+1.0
    b_r <= 16'hf000; //-1.0
    b_i <= 16'h1000; //+1.0
    @(posedge clk_100mhz_t); 
    a_r <= 16'h1400; //+1.25
    a_i <= 16'h0800; //+0.5
    b_r <= 16'h0c00; //+0.75
    b_i <= 16'he800; //-1.5
    
    @(posedge clk_100mhz_t); 
    en_i_t <= 0;
end



butterfly_single dut(
    .clk(clk_100mhz_t),
    .rst_n(rst_n_i_t),
    .en(en_i_t),
    
    .din_1_r(a_r),
    .din_1_i(a_i),
    .din_2_r(b_r),
    .din_2_i(b_i),
    .twid_r(w_r),
    .twid_i(w_i),
    
    .dout_1_r(c_r),
    .dout_1_i(c_i),
    .dout_2_r(d_r),
    .dout_2_i(d_i),
    .valid(valid_t)
);


endmodule
