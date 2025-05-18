// 64 bit program counter

`timescale 1ps/1ps

module program_counter (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [63:0] reg_data, // for BR
    input logic [63:0] se_shifted_brAddr, // sign extended, left shifted brAddr26
    input logic [63:0] se_shifted_condAddr, // sign extended, left shifted condAddr19
    input logic [1:0] pc_src, // 00: pc+4, 01: uncond branch, 10: cond branch, 11: reg
    output logic [63:0] pc
);
    logic [63:0] pc_plus_4, pc_plus_uncond, pc_plus_cond;
    logic [63:0] next_pc;

    // sequential: pc + 4
    adder_64bit pc_seq_increment (.a(pc), .b(64'd4), .cin(1'b0), .sum(pc_plus_4), .cout(), .overflow());

    // unconditional offset: pc + SE(brAddr26) << 2
    adder_64bit pc_uncond_increment (.a(pc), .b(se_shifted_brAddr), .cin(1'b0), .sum(pc_plus_uncond), .cout(), .overflow());

    // conditional offset: pc + SE(condAddr19) << 2
    adder_64bit pc_cond_increment (.a(pc), .b(se_shifted_condAddr), .cin(1'b0), .sum(pc_plus_cond), .cout(), .overflow());

    // next pc selection
    mux4_1_64bit pc_mux (
        .i0(pc_plus_4), // 00: sequential
        .i1(pc_plus_uncond), // 01: uncond offset
        .i2(pc_plus_cond), // 10: cond offset
        .i3(reg_data), // 11: register jump
        .sel(pc_src),
        .out(next_pc)
    );

    // PC DFFs
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : pc_ff
            D_FF_en dff_en_i (.clk(clk), .reset(reset), .enable(enable), .d(next_pc[i]), .q(pc[i]));
        end
    endgenerate
endmodule


module tb_program_counter();

    logic clk, reset, enable;
    logic [1:0] pc_src;
    logic [63:0] reg_data;
    logic [63:0] se_shifted_imm;
    logic [63:0] pc;

    // Instantiate the program counter
    program_counter uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .reg_data(reg_data),
        .se_shifted_imm(se_shifted_imm),
        .pc_src(pc_src),
        .pc(pc)
    );

    // Clock generation: 2000ps period (to accommodate delays)
    always #1000 clk = ~clk;

    // Internal debug monitoring
    always_ff @(posedge clk) begin
        $display("TB DEBUG @ %0t | pc_src = %b | enable = %b | pc = %h", 
                 $time, pc_src, enable, pc);
    end

    initial begin
        $display("=== Starting Program Counter Test ===");
        clk = 1;
        reset = 1;
        enable = 0;

        reg_data = 64'hDEADBEEF00000000;
        se_shifted_imm = 64'h10;
        pc_src = 2'b00;

        #2000; // allow reset to propagate
        reset = 0;
        enable = 1;

        // Sequential updates
        pc_src = 2'b00; #2000;
        pc_src = 2'b00; #2000;

        // Branch offset mode
        se_shifted_imm = 64'h20; // +32
        pc_src = 2'b01; #2000;

        se_shifted_imm = 64'hFFFFFFF0; // -16 (two's complement)
        pc_src = 2'b01; #2000;

        // Register-based jump
        reg_data = 64'h00000000CAFEBABE;
        pc_src = 2'b10; #2000;

        reg_data = 64'h00000000ABCD1234;
        pc_src = 2'b10; #2000;

        // Hold (no-op)
        pc_src = 2'b11; #2000;
        pc_src = 2'b11; #2000;

        // Disable updates
        enable = 0;
        pc_src = 2'b00; #2000;
        pc_src = 2'b01; #2000;
        pc_src = 2'b10; #2000;

        // Re-enable and continue
        enable = 1;
        pc_src = 2'b00; #2000;
        pc_src = 2'b01; se_shifted_imm = 64'h8; #2000;
        pc_src = 2'b10; reg_data = 64'h1122334455667788; #2000;

        $display("=== End of Program Counter Test ===");
        $finish;
    end

endmodule
