module cpu (
    input logic clk,
    input logic reset
);

    // === PC wires ===
    logic [63:0] pc, next_pc, pc_plus_4, branch_target;

    // === Instruction ===
    logic [31:0] instr;

    // === Register fields ===
    logic [4:0] rd, rn, rm;
    assign rd = instr[4:0];
    assign rn = instr[9:5];
    assign rm = instr[20:16];

    // === Regfile wires ===
    logic [63:0] rf_rdata1, rf_rdata2, rf_wdata;

    // === Immediate ===
    logic is_d_type;
    assign is_d_type = (instr[31:21] == 11'b11111000010 || instr[31:21] == 11'b11111000000); // LDUR / STUR
    logic [63:0] imm;

    // === ALU ===
    logic [63:0] alu_in2, alu_result;
    logic zero, negative, overflow, carry_out;
    logic [2:0] alu_cntrl;

    // === Control signals ===
    logic reg_write, alu_src, mem_read, mem_write, mem_to_reg;
    logic flag_write, branch, branch_cond, link;
    logic [1:0] pc_src;

    // === Data memory ===
    logic [63:0] mem_rdata;

    // === PC Module ===
    pc_64bit PC (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    // === Instruction Memory ===
    instructmem IMEM (
        .address(pc),
        .instruction(instr),
        .clk(clk)
    );

    // === Control Unit ===
    control_unit CU (
        .instruction(instr),
        .reg_write,
        .alu_src,
        .alu_cntrl,
        .mem_read,
        .mem_write,
        .mem_to_reg,
        .flag_write,
        .branch,
        .branch_cond,
        .pc_src,
        .link
    );

    // === Register File ===
    regfile RF (
        .ReadData1(rf_rdata1),
        .ReadData2(rf_rdata2),
        .WriteData(rf_wdata),
        .ReadRegister1(rn),
        .ReadRegister2(rm),
        .WriteRegister(rd),
        .RegWrite(reg_write),
        .clk(clk)
    );

    // === Immediate Generator ===
    immediate_gen IMMGEN (
        .instruction(instr),
        .is_d_type(is_d_type),
        .imm_out(imm)
    );

    // === ALU Input Mux (64-bit mux via mux2_1) ===
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : alu_mux
            mux2_1 m (.out(alu_in2[i]), .i0(rf_rdata2[i]), .i1(imm[i]), .sel(alu_src));
        end
    endgenerate

    // === ALU ===
    alu ALU (
        .A(rf_rdata1),
        .B(alu_in2),
        .cntrl(alu_cntrl),
        .result(alu_result),
        .negative(negative),
        .zero(zero),
        .overflow(overflow),
        .carry_out(carry_out)
    );

    // === Data Memory ===
    datamem DMEM (
        .address(alu_result),
        .write_enable(mem_write),
        .read_enable(mem_read),
        .write_data(rf_rdata2),
        .clk(clk),
        .xfer_size(4'd8),
        .read_data(mem_rdata)
    );

    // === Writeback Mux (ALU vs Mem) ===
    generate
        for (i = 0; i < 64; i++) begin : wbmux
            mux2_1 m (.out(rf_wdata[i]), .i0(alu_result[i]), .i1(mem_rdata[i]), .sel(mem_to_reg));
        end
    endgenerate

    // === PC + 4 and Branch Target ===
    assign pc_plus_4 = pc + 64'd4;
    assign branch_target = pc + (imm << 2);

    // === PC MUX (4-way using 2-bit pc_src and mux2_1s) ===
    logic [63:0] pc_mux_lo, pc_mux_hi;
    logic [63:0] reg_target;
	 assign reg_target = rf_rdata1;


    generate
        for (i = 0; i < 64; i++) begin : pc_mux_layer1
            mux2_1 m0 (.out(pc_mux_lo[i]), .i0(pc_plus_4[i]), .i1(branch_target[i]), .sel(pc_src[0]));
            mux2_1 m1 (.out(pc_mux_hi[i]), .i0(reg_target[i]), .i1(1'b0), .sel(pc_src[0]));
        end
        for (i = 0; i < 64; i++) begin : pc_mux_layer2
            mux2_1 m2 (.out(next_pc[i]), .i0(pc_mux_lo[i]), .i1(pc_mux_hi[i]), .sel(pc_src[1]));
        end
    endgenerate

endmodule
