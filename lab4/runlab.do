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
vlog "./muxes/mux2_1_2bit.sv"
vlog "./muxes/mux2_1_3bit.sv"
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

vlog "./utils/comparator_5bit.sv"
vlog "./utils/dff.sv"
vlog "./utils/dff_en.sv"
vlog "./utils/register_3bit.sv"
vlog "./utils/register_5bit.sv"
vlog "./utils/register_32bit.sv"
vlog "./utils/register_64bit.sv"

vlog "./adders/adder.sv"
vlog "./adders/adder_32bit.sv"
vlog "./adders/adder_64bit.sv"
vlog "./utils/subtractor_64bit.sv"

vlog "./utils/immediate_extenders.sv"
vlog "./utils/left_shifter.sv"
vlog "./utils/zero_64bits.sv"

vlog "./regfile.sv"
vlog "./alu.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./program_counter.sv"
vlog "./control_unit.sv"
vlog "./forwarding_unit.sv"
vlog "./hazard_detection_unit.sv"
vlog "./if_id_pipeline_reg.sv"
vlog "./id_ex_pipeline_reg.sv"
vlog "./ex_mem_pipeline_reg.sv"
vlog "./mem_wb_pipeline_reg.sv"
vlog "./cpu.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpustim

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
