`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2025 08:33:05 PM
// Design Name: 
// Module Name: butterfly_single
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


module butterfly_single(
    input wire clk,
    input wire rst_n,
    input wire en,
    
    input wire signed [15:0] din_1_r,
    input wire signed [15:0] din_1_i,
    input wire signed [15:0] din_2_r,
    input wire signed [15:0] din_2_i,
    input wire signed [15:0] twid_r,
    input wire signed [15:0] twid_i,

    output wire signed [15:0] dout_1_r,
    output wire signed [15:0] dout_1_i,
    output wire signed [15:0] dout_2_r,
    output wire signed [15:0] dout_2_i,
    
    output reg valid
    
    );

    //Pipeline Registers
    reg _en;
    
    reg signed [15:0] a_r;
    reg signed [15:0] a_i;
    
    //CM Register
    reg signed [31:0] b_r_full;
    reg signed [31:0] b_i_full;
    
    //Raw Output Registers
    reg signed [16:0] dout_1_r_full;
    reg signed [16:0] dout_1_i_full;
    reg signed [16:0] dout_2_r_full;
    reg signed [16:0] dout_2_i_full;
    
    //Shifted/Truncated CM Output
    wire signed [15:0] b_r;
    wire signed [15:0] b_i;
    
    always @(posedge clk)
    begin
       if(!rst_n)
       begin
            _en <= 1'b0;
            valid <= 1'b0; 
       end
       else
       begin
            _en <= en;
            valid <= _en; 
       end
    end
    //Stage 1: Complex Multiplication
    always @(posedge clk)
    begin
        if(!rst_n)
        begin
            a_r <= 16'b0;
            a_i <= 16'b0;
            b_r_full <= 32'b0;
            b_i_full <= 32'b0;
        end
        else
        begin
            if(en)
            begin
                a_r <= din_1_r;
                a_i <= din_1_i;
                b_r_full <= din_2_r*twid_r - din_2_i*twid_i;
                b_i_full <= din_2_r*twid_i + din_2_i*twid_r ;   
            end
        end
    end
    
    assign b_r = b_r_full >>> 12;
    assign b_i = b_i_full >>> 12;
    
    //Stage 2: Complex Addition/Subtraction
    always @(posedge clk)
    begin
        if(!rst_n)
        begin
            dout_1_r_full <= 17'b0;
            dout_1_i_full <= 17'b0;
            dout_2_r_full <= 17'b0;
            dout_2_i_full <= 17'b0;
        end
        else
        begin
            if(_en)
            begin
                dout_1_r_full <= a_r + b_r;
                dout_1_i_full <= a_i + b_i; 
                dout_2_r_full <= a_r - b_r;
                dout_2_i_full <= a_i - b_i; 
            end
        end                                                                                                            
    end
    
    assign dout_1_r = dout_1_r_full >>> 1;
    assign dout_1_i = dout_1_i_full >>> 1;
    assign dout_2_r = dout_2_r_full >>> 1;
    assign dout_2_i = dout_2_i_full >>> 1;
    
endmodule


