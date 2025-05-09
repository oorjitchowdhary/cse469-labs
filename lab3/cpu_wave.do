onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /cpu_tb/DUT/clk
add wave -noupdate -radix binary /cpu_tb/DUT/reset
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/pc_inst/curr_pc
add wave -noupdate -radix hexadecimal /cpu_tb/DUT/ctrl/instruction
add wave -noupdate /cpu_tb/DUT/ctrl/reg_write
add wave -noupdate /cpu_tb/DUT/ctrl/alu_src
add wave -noupdate -radix unsigned /cpu_tb/DUT/ctrl/alu_op
add wave -noupdate /cpu_tb/DUT/ctrl/mem_read
add wave -noupdate /cpu_tb/DUT/ctrl/mem_write
add wave -noupdate /cpu_tb/DUT/ctrl/mem_to_reg
add wave -noupdate /cpu_tb/DUT/ctrl/flag_write
add wave -noupdate -radix unsigned /cpu_tb/DUT/regs/ReadData1
add wave -noupdate -radix unsigned /cpu_tb/DUT/regs/ReadData2
add wave -noupdate -radix unsigned /cpu_tb/DUT/regs/WriteData
add wave -noupdate -radix unsigned /cpu_tb/DUT/regs/ReadRegister1
add wave -noupdate -radix unsigned /cpu_tb/DUT/regs/ReadRegister2
add wave -noupdate -radix unsigned /cpu_tb/DUT/regs/WriteRegister
add wave -noupdate -radix binary /cpu_tb/DUT/regs/RegWrite
add wave -noupdate -radix unsigned /cpu_tb/DUT/alu_inst/A
add wave -noupdate -radix unsigned /cpu_tb/DUT/alu_inst/B
add wave -noupdate -radix unsigned /cpu_tb/DUT/alu_inst/result
add wave -noupdate -radix binary /cpu_tb/DUT/alu_inst/negative
add wave -noupdate -radix binary /cpu_tb/DUT/alu_inst/zero
add wave -noupdate -radix binary /cpu_tb/DUT/alu_inst/overflow
add wave -noupdate -radix binary /cpu_tb/DUT/alu_inst/carry_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1027684 ps}
