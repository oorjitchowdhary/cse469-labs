`timescale 1ps/1ps

module forwarding_unit (
    input  logic [4:0] id_ex_rn,
    input  logic [4:0] id_ex_rm,
    input  logic [4:0] ex_mem_rd,
    input  logic       ex_mem_reg_write,
    input  logic [4:0] mem_wb_rd,
    input  logic       mem_wb_reg_write,
    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);

    // check if match
    logic ex_mem_rn_equal, ex_mem_rm_equal, mem_wb_rn_equal, mem_wb_rm_equal;
    comparator_5bit cmp_exmem_rn (.a(ex_mem_rd), .b(id_ex_rn), .equal(ex_mem_rn_equal));
    comparator_5bit cmp_exmem_rm (.a(ex_mem_rd), .b(id_ex_rm), .equal(ex_mem_rm_equal));
    comparator_5bit cmp_memwb_rn (.a(mem_wb_rd), .b(id_ex_rn), .equal(mem_wb_rn_equal));
    comparator_5bit cmp_memwb_rm (.a(mem_wb_rd), .b(id_ex_rm), .equal(mem_wb_rm_equal));

    // not equal to XZR
    logic not_exmem_zero, not_memwb_zero;
    comparator_5bit cmp_exmem_zero (.a(ex_mem_rd), .b(5'd31), .equal(not_exmem_zero_tmp));
    not #50 inv_exmem_zero (not_exmem_zero, not_exmem_zero_tmp);
    comparator_5bit cmp_memwb_zero (.a(mem_wb_rd), .b(5'd31), .equal(not_memwb_zero_tmp));
    not #50 inv_memwb_zero (not_memwb_zero, not_memwb_zero_tmp);

    // hazard validation
    logic valid_exmem_rn, valid_exmem_rm, valid_memwb_rn, valid_memwb_rm;
    and #50 a1 (valid_exmem_rn, ex_mem_reg_write, ex_mem_rn_equal, not_exmem_zero);
    and #50 a2 (valid_exmem_rm, ex_mem_reg_write, ex_mem_rm_equal, not_exmem_zero);
    and #50 a3 (valid_memwb_rn, mem_wb_reg_write, mem_wb_rn_equal, not_memwb_zero);
    and #50 a4 (valid_memwb_rm, mem_wb_reg_write, mem_wb_rm_equal, not_memwb_zero);

    // forwardA mux validation
    logic [1:0] forwardA_stage1;
    mux2_1_2bit fwdA_mem (
        .i0(2'b00), .i1(2'b01), .sel(valid_memwb_rn), .out(forwardA_stage1)
    );
    mux2_1_2bit fwdA_ex (
        .i0(forwardA_stage1), .i1(2'b10), .sel(valid_exmem_rn), .out(forwardA)
    );

    // forwardB mux validation
    logic [1:0] forwardB_stage1;
    mux2_1_2bit fwdB_mem (
        .i0(2'b00), .i1(2'b01), .sel(valid_memwb_rm), .out(forwardB_stage1)
    );
    mux2_1_2bit fwdB_ex (
        .i0(forwardB_stage1), .i1(2'b10), .sel(valid_exmem_rm), .out(forwardB)
    );

endmodule
