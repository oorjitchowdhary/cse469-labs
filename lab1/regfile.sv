module regfile (
    output logic [63:0] ReadData1, ReadData2,
    input  logic [63:0] WriteData,
    input  logic [4:0]  ReadRegister1, ReadRegister2, WriteRegister,
    input  logic        RegWrite, clk
);

    logic [63:0] registers [0:30]; // 31 registers (0–30), 64-bit wide
    logic [31:0] decoder_out;

    // Instantiate 5-to-32 decoder
    decoder_5to32 decoder (
        .input(WriteRegister),
        .enable(RegWrite),
        .RegNo(decoder_out)
    );

    genvar i;
    generate
        for (i = 0; i < 31; i = i + 1) begin : reg_block
            register_64bit reg_i (
                .q(registers[i]),
                .d(WriteData),
                .clk(clk),
                .enable(decoder_out[i]),
                .reset(1'b0) // no external reset for now
            );
        end
    endgenerate

    // Tie register 31 to constant 0s
    logic [63:0] zero;
    assign zero = 64'h0000000000000000;

    // Output multiplexer for ReadData1 and ReadData2
    mux32_64bit readmux1 (
        .out(ReadData1),
        .in0(registers[0]),  .in1(registers[1]),  .in2(registers[2]),  .in3(registers[3]),
        .in4(registers[4]),  .in5(registers[5]),  .in6(registers[6]),  .in7(registers[7]),
        .in8(registers[8]),  .in9(registers[9]),  .in10(registers[10]),.in11(registers[11]),
        .in12(registers[12]),.in13(registers[13]),.in14(registers[14]),.in15(registers[15]),
        .in16(registers[16]),.in17(registers[17]),.in18(registers[18]),.in19(registers[19]),
        .in20(registers[20]),.in21(registers[21]),.in22(registers[22]),.in23(registers[23]),
        .in24(registers[24]),.in25(registers[25]),.in26(registers[26]),.in27(registers[27]),
        .in28(registers[28]),.in29(registers[29]),.in30(registers[30]),.in31(zero),
        .sel(ReadRegister1)
    );

    mux32_64bit readmux2 (
        .out(ReadData2),
        .in0(registers[0]),  .in1(registers[1]),  .in2(registers[2]),  .in3(registers[3]),
        .in4(registers[4]),  .in5(registers[5]),  .in6(registers[6]),  .in7(registers[7]),
        .in8(registers[8]),  .in9(registers[9]),  .in10(registers[10]),.in11(registers[11]),
        .in12(registers[12]),.in13(registers[13]),.in14(registers[14]),.in15(registers[15]),
        .in16(registers[16]),.in17(registers[17]),.in18(registers[18]),.in19(registers[19]),
        .in20(registers[20]),.in21(registers[21]),.in22(registers[22]),.in23(registers[23]),
        .in24(registers[24]),.in25(registers[25]),.in26(registers[26]),.in27(registers[27]),
        .in28(registers[28]),.in29(registers[29]),.in30(registers[30]),.in31(zero),
        .sel(ReadRegister2)
    );

endmodule
