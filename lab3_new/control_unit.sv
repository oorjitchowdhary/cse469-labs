module control_unit (
    input logic [31:0] instruction,
    output logic mem_read,
    output logic mem_write,
    output logic reg_write,
    output logic mem_to_reg, // 1: write dmem data to reg; 0: write ALU result to reg
    output logic reg2loc, // 1: ReadReg2 = Rd; 0: ReadReg2 = Rm
    output logic flag_write,
    output logic link_write, // 1 = BL
    output logic alu_src, // 1: ALU B = SE(imm); 0: ALU B = Reg2 data
    output logic imm_is_dtype, // 1 = D-type, 0 = I-type
    output logic [2:0] alu_op,
    output logic take_branch, // 1 = B, BL, BR, CBZ, B.LT
    output logic uncond_branch, // 1 = B, BL
    output logic reg_branch // 1 = BR
);
    logic [10:0] opcode_RD;
	logic [9:0] opcode_I;
	logic [5:0] opcode_B;
	logic [7:0] opcode_CB;
	assign opcode_RD = instruction[31:21];
	assign opcode_I = instruction[31:22];
    assign opcode_CB = instruction[31:24];
	assign opcode_B  = instruction[31:26];

    always_comb begin
        // defaults
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        mem_to_reg = 1'b0;
        reg2loc = 1'b0;
        flag_write = 1'b0;
        link_write = 1'b0;
        alu_src = 1'b0;
        imm_is_dtype = 1'b0;
        alu_op = 3'b000;
        take_branch = 1'b0;
        uncond_branch = 1'b0;
        reg_branch = 1'b0;

        // R-type or D-type
        case (opcode_RD)
            // ADDS (R)
            11'b10101011000: begin
                reg_write = 1'b1;
                flag_write = 1'b1;
                alu_op = 3'b010; // ALU ADD
            end

            // SUBS (R)
            11'b11101011000: begin
                reg_write = 1'b1;
                flag_write = 1'b1;
                alu_op = 3'b011; // ALU SUB
            end

            // BR (R)
            11'b11010110000: begin
                take_branch = 1'b1;
                reg_branch = 1'b1;
                reg2loc = 1'b1;
            end

            // LDUR (D)
            11'b11111000010: begin
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                reg_write = 1'b1;
                alu_op = 3'b010; // ALU ADD
                alu_src = 1'b1;
                imm_is_dtype = 1'b1;
            end

            // STUR (D)
            11'b11111000000: begin
                mem_write = 1'b1;
                alu_op = 3'b010; // ALU ADD
                alu_src = 1'b1;
                reg2loc = 1'b1;
                imm_is_dtype = 1'b1;
            end
        endcase

        // I-type
        case (opcode_I)
            // ADDI
            10'b1001000100: begin
                alu_op = 3'b010; // ALU ADD
                alu_src = 1'b1;
                reg2loc = 1'b1;
                reg_write = 1'b1;
            end
        endcase

        // CB-type
        case (opcode_CB)
            // CBZ (checks Reg[Rd] - 0 == 0)
            8'b10110100: begin
                take_branch = 1'b1;
                reg2loc = 1'b1;
                alu_op = 3'b011; // ALU SUB
            end

            // B.LT (relies on previous instruction's flags)
            8'b01010100: if (instruction[4:0] == 5'b01011) begin
                take_branch = 1'b1;
            end
        endcase

        // B-type
        case (opcode_B)
            // B
            6'b000101: begin
                take_branch = 1'b1;
                uncond_branch = 1'b1;
            end

            // BL
            6'b100101: begin
                take_branch = 1'b1;
                uncond_branch = 1'b1;
                reg_write = 1'b1;
                link_write = 1'b1;
            end
        endcase
    end
endmodule
