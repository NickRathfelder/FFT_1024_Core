`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2025 09:24:30 PM
// Design Name: 
// Module Name: fft_1024_core_tb
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


module fft_1024_core_tb();

logic clk_100mhz_t;
logic rst_n_i_t;
logic load_frame_t;
logic read_frame_t;
logic signed [15:0] sample_t;

wire signed [15:0] result_r_t;
logic signed [15:0] frame_bin_r [0:1023];
wire signed [15:0] result_i_t;
logic signed [15:0] frame_bin_i [0:1023];
//wire fft_busy_t;
//wire fft_ready_t;
//wire fft_done_t;

always #(5) clk_100mhz_t= ~clk_100mhz_t;

initial 
begin
    clk_100mhz_t = 0;
    rst_n_i_t = 0;
    load_frame_t = 0;
    read_frame_t = 0;
    sample_t = 0;
    reset_core();
    test_dc();
    test_nyquist();
    test_cosine_bink(23);
end
task automatic reset_core();
    begin
    rst_n_i_t <= 1;
    repeat(5) @(posedge clk_100mhz_t);
    rst_n_i_t <= 1;
    repeat(5) @(posedge clk_100mhz_t);
    end
endtask

task automatic test_dc();
    begin
        wait(load_ready_t == 1);
        @(posedge clk_100mhz_t);
        sample_t <= 16'h1000;
        load_frame_t <= 1'b1;
        repeat (1024) @(posedge clk_100mhz_t);
        load_frame_t <= 1'b0;
        sample_t <= 16'h0;
        read_output();
    end
endtask

task automatic test_nyquist();
    begin
        wait(load_ready_t == 1);
        @(posedge clk_100mhz_t);
        load_frame_t <= 1'b1;
        for (int i = 0; i < 1024; i++) begin
            if(i%2 == 0) sample_t <= 16'h1000;
            else sample_t <= 16'hf000;
            @(posedge clk_100mhz_t);
        end
        load_frame_t <= 1'b0;
        sample_t <= 16'h0;
        read_output();
    end
endtask

task automatic test_cosine_bink(int k);
    begin
        real    sample_real;
        integer sample_fixed;
        
        wait(load_ready_t == 1);
        @(posedge clk_100mhz_t);
        load_frame_t <= 1'b1;
        for (int i = 0; i < 1024; i++) begin
            sample_real  = $cos(2.0 * 3.1415926535 * k * i / 1024);
            sample_fixed = integer'($rtoi($floor(sample_real * 4096.0 + 0.5)));
            sample_t <= sample_fixed[15:0];
            @(posedge clk_100mhz_t);
        end
        load_frame_t <= 1'b0;
        sample_t <= 16'h0;
        read_output();
    end
endtask
task automatic read_output();
    begin
        read_frame_t <= 1'b1;          
        
        @(posedge clk_100mhz_t);
        
        for (int i = 0; i < 1024; i++) begin
            do @(posedge clk_100mhz_t);
            while (!(read_ready_t && read_frame_t)); 
            
            frame_bin_r[i] <= result_r_t;
            frame_bin_i[i] <= result_i_t;
        end
        
        read_frame_t <= 1'b0;
        @(posedge clk_100mhz_t);
    end
endtask
    
fft_1024_core dut(
    .clk_core(clk_100mhz_t),
    .rst_n_core(rst_n_i_t),
    
    .load_tvalid(load_frame_t),
    .read_tready(read_frame_t),
    
    .sample(sample_t),
    
    .load_tready(load_ready_t),
    .read_tvalid(read_ready_t),
    
    .fft_out_r(result_r_t),
    .fft_out_i(result_i_t)
    //.fft_busy(fft_busy_t),
    //.fft_ready(fft_ready_t),
    //.fft_done(fft_done_t)

    );
endmodule
