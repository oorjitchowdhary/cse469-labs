`timescale 1ns/10ps

module regfile (
  output logic [63:0] ReadData1,
  output logic [63:0] ReadData2,
  input  logic [63:0] WriteData,
  input  logic [4:0] ReadRegister1,
  input  logic [4:0] ReadRegister2,
  input  logic [4:0] WriteRegister,
  input  logic RegWrite,
  input  logic clk
);

  logic [31:0] write_enable;
  logic [63:0] reg_out[31:0]; // 32 outputs of Register64s

  decoder_5to32 decoder (
    .RegNo(write_enable),
    .in(WriteRegister),
    .enable(RegWrite)
  );

  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : regfile_gen
      register_64bit reg_i (
        .q(reg_out[i]),
        .d(WriteData),
        .clk(clk),
        .reset(1'b0),
        .enable(write_enable[i])
      );
    end
  endgenerate

  assign reg_out[31] = 64'b0;

  mux32_64bit read_mux1 (
    .out(ReadData1),
    .in0(reg_out[0]),  .in1(reg_out[1]),  .in2(reg_out[2]),  .in3(reg_out[3]),
    .in4(reg_out[4]),  .in5(reg_out[5]),  .in6(reg_out[6]),  .in7(reg_out[7]),
    .in8(reg_out[8]),  .in9(reg_out[9]),  .in10(reg_out[10]),.in11(reg_out[11]),
    .in12(reg_out[12]),.in13(reg_out[13]),.in14(reg_out[14]),.in15(reg_out[15]),
    .in16(reg_out[16]),.in17(reg_out[17]),.in18(reg_out[18]),.in19(reg_out[19]),
    .in20(reg_out[20]),.in21(reg_out[21]),.in22(reg_out[22]),.in23(reg_out[23]),
    .in24(reg_out[24]),.in25(reg_out[25]),.in26(reg_out[26]),.in27(reg_out[27]),
    .in28(reg_out[28]),.in29(reg_out[29]),.in30(reg_out[30]),.in31(reg_out[31]),
    .sel(ReadRegister1)
  );

  mux32_64bit read_mux2 (
    .out(ReadData2),
    .in0(reg_out[0]),  .in1(reg_out[1]),  .in2(reg_out[2]),  .in3(reg_out[3]),
    .in4(reg_out[4]),  .in5(reg_out[5]),  .in6(reg_out[6]),  .in7(reg_out[7]),
    .in8(reg_out[8]),  .in9(reg_out[9]),  .in10(reg_out[10]),.in11(reg_out[11]),
    .in12(reg_out[12]),.in13(reg_out[13]),.in14(reg_out[14]),.in15(reg_out[15]),
    .in16(reg_out[16]),.in17(reg_out[17]),.in18(reg_out[18]),.in19(reg_out[19]),
    .in20(reg_out[20]),.in21(reg_out[21]),.in22(reg_out[22]),.in23(reg_out[23]),
    .in24(reg_out[24]),.in25(reg_out[25]),.in26(reg_out[26]),.in27(reg_out[27]),
    .in28(reg_out[28]),.in29(reg_out[29]),.in30(reg_out[30]),.in31(reg_out[31]),
    .sel(ReadRegister2)
  );

endmodule
