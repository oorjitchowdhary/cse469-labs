# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./gates/and_64bit.sv"
vlog "./gates/not_64bit.sv"
vlog "./gates/or_64bit.sv"
vlog "./gates/xor_64bit.sv"

vlog "./muxes/mux2_1.sv"
vlog "./muxes/mux2_1_5bit.sv"
vlog "./muxes/mux2_1_64bit.sv"
vlog "./muxes/mux4_1.sv"
vlog "./muxes/mux4_1_64bit.sv"
vlog "./muxes/mux8_1.sv"
vlog "./muxes/mux16_1.sv"
vlog "./muxes/mux32_1.sv"
vlog "./muxes/mux32_1_64bit.sv"

vlog "./decoders/decoder_3to8.sv"
vlog "./decoders/decoder_5to32.sv"

vlog "./dff.sv"
vlog "./register_64bit.sv"
vlog "./regfile.sv"

vlog "./adders/adder.sv"
vlog "./adders/adder_32bit.sv"
vlog "./adders/adder_64bit.sv"
vlog "./subtractor_64bit.sv"

vlog "./alu.sv"
vlog "./alustim.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work alustim

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do alustim_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
