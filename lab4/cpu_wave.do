onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpustim/clk
add wave -noupdate /cpustim/reset
add wave -noupdate -radix decimal /cpustim/DUT/pc_inst/pc
add wave -noupdate -radix hexadecimal /cpustim/DUT/imem/instruction
add wave -noupdate -label {negative flag} /cpustim/DUT/n_dff/q
add wave -noupdate -label {zero flag} /cpustim/DUT/z_dff/q
add wave -noupdate -label {carry_out flag} /cpustim/DUT/c_dff/q
add wave -noupdate -label {overflow flag} /cpustim/DUT/v_dff/q
add wave -noupdate -radix decimal -childformat {{{/cpustim/DUT/rf_inst/reg_out[31]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[30]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[29]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[28]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[27]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[26]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[25]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[24]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[23]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[22]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[21]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[20]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[19]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[18]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[17]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[16]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[15]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[14]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[13]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[12]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[11]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[10]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[9]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[8]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[7]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[6]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[5]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[4]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[3]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[2]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[1]} -radix decimal} {{/cpustim/DUT/rf_inst/reg_out[0]} -radix decimal}} -subitemconfig {{/cpustim/DUT/rf_inst/reg_out[31]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[30]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[29]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[28]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[27]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[26]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[25]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[24]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[23]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[22]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[21]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[20]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[19]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[18]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[17]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[16]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[15]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[14]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[13]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[12]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[11]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[10]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[9]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[8]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[7]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[6]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[5]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[4]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[3]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[2]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[1]} {-height 15 -radix decimal} {/cpustim/DUT/rf_inst/reg_out[0]} {-height 15 -radix decimal}} /cpustim/DUT/rf_inst/reg_out
add wave -noupdate /cpustim/DUT/dmem/mem
add wave -noupdate /cpustim/DUT/pc_inst/pc_src
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/mem_read
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/mem_write
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/reg_write
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/mem_to_reg
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/reg2loc
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/flag_write
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/link_write
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/alu_src
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/imm_is_dtype
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/alu_op
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/take_branch
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/uncond_branch
add wave -noupdate -group {control unit} /cpustim/DUT/cu_inst/reg_branch
add wave -noupdate -group {IF/ID reg} /cpustim/DUT/if_id_reg/clk
add wave -noupdate -group {IF/ID reg} /cpustim/DUT/if_id_reg/reset
add wave -noupdate -group {IF/ID reg} /cpustim/DUT/if_id_reg/enable
add wave -noupdate -group {IF/ID reg} /cpustim/DUT/if_id_reg/instr_in
add wave -noupdate -group {IF/ID reg} /cpustim/DUT/if_id_reg/pc_plus4_in
add wave -noupdate -group {IF/ID reg} /cpustim/DUT/if_id_reg/instr_out
add wave -noupdate -group {IF/ID reg} /cpustim/DUT/if_id_reg/pc_plus4_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/clk
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/reset
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/enable
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/reg1_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/reg2_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/imm_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/rd_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/pc_plus4_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/reg1_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/reg2_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/imm_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/rd_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/pc_plus4_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_alu_op_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_alu_src_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_flag_write_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_is_cbz_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_is_blt_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_alu_op_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_alu_src_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_flag_write_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_is_cbz_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/ex_is_blt_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_mem_read_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_mem_write_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_take_branch_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_uncond_branch_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_reg_branch_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_mem_read_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_mem_write_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_take_branch_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_uncond_branch_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/mem_reg_branch_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/wb_reg_write_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/wb_mem_to_reg_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/wb_link_write_in
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/wb_reg_write_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/wb_mem_to_reg_out
add wave -noupdate -group {ID/EX reg} /cpustim/DUT/id_ex_reg/wb_link_write_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/clk
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/reset
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/enable
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/alu_result_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/reg2_data_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/rd_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/branch_condition_met_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/pc_plus4_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/alu_result_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/reg2_data_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/rd_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/branch_condition_met_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/pc_plus4_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_mem_read_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_mem_write_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_take_branch_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_uncond_branch_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_reg_branch_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_mem_read_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_mem_write_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_take_branch_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_uncond_branch_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/mem_reg_branch_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/wb_reg_write_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/wb_mem_to_reg_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/wb_link_write_in
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/wb_reg_write_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/wb_mem_to_reg_out
add wave -noupdate -group {EX/MEM reg} /cpustim/DUT/ex_mem_reg/wb_link_write_out
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/clk
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/reset
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/enable
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/alu_result_in
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/mem_data_in
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/pc_plus4_in
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/rd_in
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/alu_result_out
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/mem_data_out
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/rd_out
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/pc_plus4_out
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/wb_reg_write_in
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/wb_mem_to_reg_in
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/wb_link_write_in
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/wb_reg_write_out
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/wb_mem_to_reg_out
add wave -noupdate -group {MEM/WB reg} /cpustim/DUT/mem_wb_reg/wb_link_write_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {353846 ps} 0}
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
WaveRestoreZoom {0 ps} {428324 ps}
