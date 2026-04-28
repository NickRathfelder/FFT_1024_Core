`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2025 11:07:41 PM
// Design Name: 
// Module Name: addr_gen
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


module addr_gen(
    input loading,
    input computing,
    input reading,
    
    input [3:0] stage,
    input [9:0] pair,
    input [9:0] sample_cntr,
    
    output reg [9:0] addr_a,
    output reg [9:0] addr_b,
    output reg [9:0] addr_w
    );
    
    reg [9:0] sample_cntr_br;
    
    wire [9:0] w_msk;
    
    always @(*)
    begin
        if (loading)
        begin
            addr_a = sample_cntr_br;
            addr_b = 10'b0;
            addr_w = 10'b0;
        end
        else if (computing)
        begin
            addr_a = ((pair << 1) << stage) | (((pair) << 1) >> (10-stage));
            addr_b = (((pair << 1) + 1) << stage) | ((((pair) << 1) + 1) >> (10-stage));
            addr_w = pair & w_msk;
            
        end
        else if (reading)
        begin
            addr_a = sample_cntr;
            addr_b = 10'b0;
            addr_w = 10'b0;
        end
        else
        begin
            addr_a = 10'b0;
            addr_b = 10'b0;
            addr_w = 10'b0;
        end
    end
    
    
    genvar i;
    generate
        for (i = 0; i < 10; i = i + 1) begin : bit_reversal
        always @(*) sample_cntr_br[i] = sample_cntr[9-i];
        end
    endgenerate
    
    assign w_msk = (10'b1111111111 << (9-stage));
    
endmodule
