# create_project.tcl
# Command - vivado -mode batch -source create_project.tcl

# Parameters
set proj_name "FFT_1024_Core"
set proj_dir  "../../FFT_1024_Core"
set proj_part "xc7s25csga324-1"    
set top_file  "fft_1024_core"                     

# Directories
set hdl_dir    "../hdl"
set ip_dir     "../ip"
set synth_dir    "../synthesis"
set test_dir    "../test"

# Create Project

file mkdir $proj_dir
create_project -force $proj_name $proj_dir -part $proj_part

# Add Files

# Add RTL
add_files [glob -nocomplain "$hdl_dir/*.v"]

# Add Testbenches
add_files -fileset sim_1 [glob -nocomplain "$test_dir/*.sv"]

# Add Constraints
add_files -fileset constrs_1 [glob -nocomplain "$synth_dir/*.xdc"]

# Set synth and sim top files
set_property top $top_file [get_filesets sources_1]
set_property top ${top_file}_tb [get_filesets sim_1]

