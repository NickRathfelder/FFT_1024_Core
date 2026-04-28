set_property -dict {PACKAGE_PIN R2 IOSTANDARD SSTL135} [get_ports clk_100mhz]
create_clock -period 10.000 -name sys_clk_100mhz -waveform {0.000 5.000} -add [get_ports clk_100mhz]

