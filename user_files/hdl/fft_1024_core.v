`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2025 01:51:58 PM
// Design Name: 
// Module Name: fft_1024_core
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


module fft_1024_core(
    input wire clk_core,
    input wire rst_n_core,
    
    input wire load_tvalid,
    input wire read_tready,
    
    input wire signed [15:0] sample,
    
    output wire load_tready,
    output wire read_tvalid,
    
    output wire signed [15:0] fft_out_r,
    output wire signed [15:0] fft_out_i

    );
    
    // Memory Instatiation
    reg [31:0] ram_block0 [1023:0];
    reg [31:0] ram_block1 [1023:0];
    reg [31:0] rom_twiddle [511:0];
    
    initial begin
        $readmemb("ram_1024x32_binary.mem", ram_block0, 0, 1023);
        $readmemb("ram_1024x32_binary.mem", ram_block1, 0, 1023);
        $readmemb("twiddle_512x32_binary.mem", rom_twiddle, 0, 511);
    end
    
    // Memory Addresses
    wire [9:0] a_addr_cur;
    wire [9:0] b_addr_cur;
    
    reg [9:0] _a_addr_cur;
    reg [9:0] _b_addr_cur;
    
    reg [9:0] __a_addr_cur;
    reg [9:0] __b_addr_cur;
    
    reg [9:0] ___a_addr_cur;
    reg [9:0] ___b_addr_cur;
    
    wire [9:0] b0_port_a_addr;
    wire [9:0] b0_port_b_addr;
    
    wire [9:0] b1_port_a_addr;
    wire [9:0] b1_port_b_addr;
    
    wire [9:0] twiddle_addr;
    
    // Memory Data
    wire [31:0] b0_port_a_din;
    wire [31:0] b0_port_b_din;
    
    wire [31:0] b1_port_a_din;
    wire [31:0] b1_port_b_din;
    
    reg [31:0] b0_port_a_dout;
    reg [31:0] b0_port_b_dout;
    
    reg [31:0] b1_port_a_dout;
    reg [31:0] b1_port_b_dout;
    
    /// Control Block Signals
    
    // Core States
    wire fft_loading;
    wire fft_computing;
    wire fft_reading;
    
    // Stage Control
    wire [3:0] fft_stage;
    wire [9:0] fft_pair;
    wire fft_stage_even;
    
    // Intermediate RAM Control
    wire b0_port_a_wr;
    wire b0_port_b_wr;
    wire b1_port_a_wr;
    wire b1_port_b_wr;

    /// BFU Signals
    
    // Butterfly Operands
    wire signed [15:0] a_r;
    wire signed [15:0] a_i;
    wire signed [15:0] b_r;
    wire signed [15:0] b_i;
    
    // Twiddle Factor
    reg signed [31:0] w;
    
    // Butterfly Output Samples
    wire signed [15:0] c_r;
    wire signed [15:0] c_i;
    wire signed [15:0] d_r;
    wire signed [15:0] d_i;
    
    //Butterfly Control Signals
    wire bfu_valid;
    wire bfu_execute;
    
    reg bfu_enable;
    
    // Frame Loading/Reading
    wire [9:0] fft_sample_cntr;
    
    reg [31:0] fft_out_reg;
    wire out_reg_ld;

    /// RAM Block 0
    
    always @(posedge clk_core)
    begin
        if (rst_n_core)
        begin
            if (b0_port_a_wr) ram_block0[b0_port_a_addr] <=  b0_port_a_din;
            b0_port_a_dout <= ram_block0[b0_port_a_addr];
        end
    end
    
    always @(posedge clk_core)
    begin
        if (rst_n_core)
        begin
            if (b0_port_b_wr) ram_block0[b0_port_b_addr] <= b0_port_b_din;
            b0_port_b_dout <= ram_block0[b0_port_b_addr];
        end
    end
    
    /// RAM Block 1
    always @(posedge clk_core)
    begin
        if (rst_n_core)
        begin
            if (b1_port_a_wr) ram_block1[b1_port_a_addr] <= b1_port_a_din;
            b1_port_a_dout <= ram_block1[b1_port_a_addr];
        end
    end
   
    always @(posedge clk_core)
    begin
        if (rst_n_core)
        begin
            if (b1_port_b_wr) ram_block1[b1_port_b_addr] <= b1_port_b_din;
            b1_port_b_dout <= ram_block1[b1_port_b_addr];
        end
    end
    
    /// Twiddle ROM
    always @(posedge clk_core)
    begin
       if (rst_n_core)
        begin
            w <= rom_twiddle[twiddle_addr];
        end
    end
    
    /// Fetching/Prefetching Output Registers
    always @(posedge clk_core)
    begin
        if (rst_n_core)
        begin
            if (out_reg_ld) fft_out_reg <= b0_port_a_dout;
            else if (read_tvalid && read_tready) fft_out_reg <= b0_port_a_dout;
        end
    end
    //Main Control Unit
    
    control_unit control_unit_inst(
        .clk(clk_core),
        .rst_n(rst_n_core),
        .load_v(load_tvalid),
        .read_r(read_tready),
        .valid(bfu_valid),
        
        .computing(fft_computing),
        .load_output(out_reg_ld),
        
        .load_r(load_tready),
        .read_v(read_tvalid),
        
        .stage(fft_stage),
        .pair(fft_pair),
        .sample_cntr(fft_sample_cntr),
        
        .bf_execute(bfu_execute)
    );
    
    //Pipelining
    
    // Address Generation Unit
    addr_gen addr_gen_inst(
        .loading(fft_loading),
        .computing(fft_computing),
        .reading(fft_reading),
        
        .stage(fft_stage),
        .pair(fft_pair),
        .sample_cntr(fft_sample_cntr),
        
        .addr_a(a_addr_cur),
        .addr_b(b_addr_cur),
        .addr_w(twiddle_addr)
    );
    
    // Memory Address Pipelining
    always @(posedge clk_core)
    begin   
        // Pipelines the read address coming from the read memory block
        // to the write address using for the write memory block
        _a_addr_cur <= a_addr_cur;
        _b_addr_cur <= b_addr_cur;
        __a_addr_cur <= _a_addr_cur;
        __b_addr_cur <= _b_addr_cur;
        ___a_addr_cur <= __a_addr_cur;
        ___b_addr_cur <= __b_addr_cur;
        
    end
    
    // Read from Bank 0 during even stages
    // Write to Bank 0 during odd stages
    assign b0_port_a_addr = fft_stage_even ? (a_addr_cur) : (___a_addr_cur);
    assign b0_port_b_addr = fft_stage_even ? (b_addr_cur) : (___b_addr_cur);
    // Read from Bank 1 during odd stages
    // Write to Bank 1 during even stages                    
    assign b1_port_a_addr = !fft_stage_even ? (a_addr_cur) : (___a_addr_cur);
    assign b1_port_b_addr = !fft_stage_even ? (b_addr_cur) : (___b_addr_cur);
    
    butterfly_single bfu(
        .clk(clk_core),
        .rst_n(rst_n_core),
        .en(bfu_enable),
    
        .din_1_r(a_r),
        .din_1_i(a_i),
        .din_2_r(b_r),
        .din_2_i(b_i),
        .twid_r(w[31:16]),
        .twid_i(w[15:0]),

        .dout_1_r(c_r),
        .dout_1_i(c_i),
        .dout_2_r(d_r),
        .dout_2_i(d_i),
    
        .valid(bfu_valid)
    );
    
    always @(posedge clk_core)
    begin
        bfu_enable <= bfu_execute;
    end
    
    assign fft_loading = load_tready & load_tvalid;
    assign fft_reading = out_reg_ld | (read_tvalid & read_tready);
    
    assign fft_out_r = fft_out_reg[31:16];
    assign fft_out_i = fft_out_reg[15:0];
    
    assign fft_stage_even = !(fft_stage[0]);
    
    assign b0_port_a_wr = fft_loading ? 1'b1 : (!fft_stage_even ? bfu_valid : 1'b0);
    assign b0_port_b_wr = !fft_stage_even ? bfu_valid : 1'b0;
    assign b1_port_a_wr = fft_stage_even ? bfu_valid : 1'b0;
    assign b1_port_b_wr = fft_stage_even ? bfu_valid : 1'b0;
    
    assign b0_port_a_din = fft_loading ? {sample, 16'b0} : {c_r,c_i};
    assign b0_port_b_din = {d_r,d_i};
    assign b1_port_a_din = {c_r,c_i};
    assign b1_port_b_din = {d_r,d_i};
    
    assign a_r = fft_stage_even ? b0_port_a_dout[31:16]:b1_port_a_dout[31:16];
    assign a_i = fft_stage_even ? b0_port_a_dout[15:0]:b1_port_a_dout[15:0];
    assign b_r = fft_stage_even ? b0_port_b_dout[31:16]:b1_port_b_dout[31:16];
    assign b_i = fft_stage_even ? b0_port_b_dout[15:0]:b1_port_b_dout[15:0];
        
        
    

    
endmodule
