`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2025 11:17:23 PM
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input clk,
    input rst_n,
    input load_v,
    input read_r,
    input valid,
    
    output reg computing,
    output reg load_output,
    
    output reg load_r,
    output reg read_v,
    
    output reg [3:0] stage,
    output reg [9:0] pair,
    output reg [9:0] sample_cntr,
    
    output reg bf_execute

    );
    // State Definitions
    parameter RST = 3'b000;
    parameter READY = 3'b001;
    parameter COMP = 3'b011;
    parameter LOAD_OUT = 3'b110;
    parameter PREFETCH = 3'b010;
    parameter DONE = 3'b100;
    
    reg [2:0] state;
    reg [9:0] output_cntr;
    
   always @(posedge clk)
   begin
    if(~rst_n)
    begin
        state <= RST;
        
        computing <= 1'b0;
        load_output <= 1'b0;
        
        load_r <= 1'b0;
        read_v <= 1'b0;
        
        stage <= 4'd0;
        pair <= 10'd0;
        sample_cntr <= 10'd0;
        output_cntr <= 10'd0;
        
        bf_execute <= 1'b0;
    end
    else
    begin
        case(state)
            RST:
            begin
                state <= READY;
                load_r <= 1'b1;
                
            end
            READY:
            begin
                if(sample_cntr == 10'd1023)
                begin
                    state <= COMP;
                    load_r <= 1'b0;
                    computing <= 1'b1;
                    bf_execute <= 1'b1;
                end
                else if (load_v && load_r) sample_cntr <= sample_cntr + 1;
            end            
            COMP:
            begin
                if (bf_execute)
                begin
                    if(pair == 10'd511)
                    begin
                        bf_execute <= 1'b0;
                        pair <= 10'd0;
                    end
                    else pair <= pair + 1;
                end
                else
                begin
                    if(!valid)
                    begin
                        if(stage == 10'd9)
                        begin
                            state <= PREFETCH;
                            computing <= 1'b0;
                            stage <= 10'd0;
                            sample_cntr <= sample_cntr + 1;
                        end
                        else 
                        begin
                            stage <= stage + 1;
                            bf_execute <= 1'b1;
                        end
                    end
                end
            end
            PREFETCH:
            begin
                state <= LOAD_OUT;
                sample_cntr <= sample_cntr + 1;
                load_output <= 1'b1;
            end
            LOAD_OUT:
            begin
                state <= DONE;
                sample_cntr <= sample_cntr + 1;
                load_output <= 1'b0;
                read_v <= 1'b1;
                
            end
            DONE:
            begin
                if (read_r && read_v) 
                begin
                    if(sample_cntr < 10'd1023) sample_cntr <= sample_cntr + 1;
                    if(output_cntr == 10'd1023)
                    begin
                        state <= READY;
                        read_v <= 1'b0;
                        load_r <= 1'b1;
                        sample_cntr <= sample_cntr +1;
                    end
                    output_cntr <= output_cntr + 1;
                end
            end
            default:
            begin
                state <= RST;
        
                computing <= 1'b0;
                load_output <= 1'b0;
        
                load_r <= 1'b0;
                read_v <= 1'b0;
        
                stage <= 4'd0;
                pair <= 10'd0;
                sample_cntr <= 10'd0;
                output_cntr <= 10'd0;
        
                bf_execute <= 1'b0;
            end
        endcase
    end
   end
    
endmodule
