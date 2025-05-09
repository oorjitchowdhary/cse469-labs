# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./dff.sv"
vlog "./adder.sv"
vlog "./or_64bit.sv"
vlog "./and_64bit.sv"
vlog "./xor_64bit.sv"
vlog "./not_64bit.sv"
vlog "./adder_64bit.sv"
vlog "./subtractor_64bit.sv"
vlog "./alu.sv"
vlog "./decoder_3to8.sv"
vlog "./decoder_5to32.sv"
vlog "./mux2_1.sv"
vlog "./mux4_1.sv"
vlog "./mux8_1.sv"
vlog "./mux16_1.sv"
vlog "./mux32_64bit.sv"
vlog "./mux32_1.sv"
vlog "./register_64bit.sv"
vlog "./regfile.sv"
vlog "./pc.sv"
vlog "./immediate_gen.sv"
vlog "./control_unit.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./cpu.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpu_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do cpu_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
