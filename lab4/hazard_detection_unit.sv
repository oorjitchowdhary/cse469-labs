`timescale 1ps/1ps

module hazard_detection_unit (
    input logic [4:0] id_ex_rd,
    input logic id_ex_mem_read,
    input logic [4:0] if_id_r1, // R1 (Rn vs Rd) selected using is_cb_type mux
    input logic [4:0] if_id_r2, // R2 (Rm vs Rd) selected using reg2loc
    output logic stall
);
    // look for a match
    logic match_r1, match_r2;
    comparator_5bit cmp_rn (.a(if_id_r1), .b(id_ex_rd), .equal(match_r1));
    comparator_5bit cmp_rm (.a(if_id_r2), .b(id_ex_rd), .equal(match_r2));

    // look for hazards
    logic hazard_on_r1, hazard_on_r2;
    and #50 and_rn (hazard_on_r1, id_ex_mem_read, match_r1);
    and #50 and_rm (hazard_on_r2, id_ex_mem_read, match_r2);

    // stall decision
    or #50 or_stall (stall, hazard_on_r1, hazard_on_r2);
endmodule
