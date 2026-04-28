# build.tcl
# Command - vivado -mode batch -source build.tcl
# Open project

set proj_name "FFT_1024_Core"
open_project ../../$proj_name/${proj_name}.xpr

# Run synthesis (includes IPs automatically)
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_runs synth_1

close_project
