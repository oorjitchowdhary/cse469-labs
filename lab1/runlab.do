# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./mux2_1.sv"
vlog "./mux4_1.sv"
vlog "./mux8_1.sv"
vlog "./mux16_1.sv"
vlog "./mux32_1.sv"
vlog "./mux32_64bit.sv"
vlog "./dff.sv"
vlog "./register_64bit.sv"
vlog "./decoder_5to32.sv"
vlog "./regfile.sv"
vlog "./regstim.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work regstim
# vsim -voptargs="+acc" -t 1ps -lib work mux2_1_testbench
# vsim -voptargs="+acc" -t 1ps -lib work mux4_1_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do regstim_wave.do
# do mux2_1_wave.do
# do mux4_1_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
