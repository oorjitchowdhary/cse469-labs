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
  logic [63:0] reg_out[31:0]; // 32 outputs of 64 bit registers

  decoder_5to32 decoder (
    .out(write_enable),
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

  mux32_1_64bit read_mux1 (
    .out(ReadData1),
    .i0(reg_out[0]),  .i1(reg_out[1]),  .i2(reg_out[2]),  .i3(reg_out[3]),
    .i4(reg_out[4]),  .i5(reg_out[5]),  .i6(reg_out[6]),  .i7(reg_out[7]),
    .i8(reg_out[8]),  .i9(reg_out[9]),  .i10(reg_out[10]),.i11(reg_out[11]),
    .i12(reg_out[12]),.i13(reg_out[13]),.i14(reg_out[14]),.i15(reg_out[15]),
    .i16(reg_out[16]),.i17(reg_out[17]),.i18(reg_out[18]),.i19(reg_out[19]),
    .i20(reg_out[20]),.i21(reg_out[21]),.i22(reg_out[22]),.i23(reg_out[23]),
    .i24(reg_out[24]),.i25(reg_out[25]),.i26(reg_out[26]),.i27(reg_out[27]),
    .i28(reg_out[28]),.i29(reg_out[29]),.i30(reg_out[30]),.i31(reg_out[31]),
    .sel(ReadRegister1)
  );

  mux32_1_64bit read_mux2 (
    .out(ReadData2),
    .i0(reg_out[0]),  .i1(reg_out[1]),  .i2(reg_out[2]),  .i3(reg_out[3]),
    .i4(reg_out[4]),  .i5(reg_out[5]),  .i6(reg_out[6]),  .i7(reg_out[7]),
    .i8(reg_out[8]),  .i9(reg_out[9]),  .i10(reg_out[10]),.i11(reg_out[11]),
    .i12(reg_out[12]),.i13(reg_out[13]),.i14(reg_out[14]),.i15(reg_out[15]),
    .i16(reg_out[16]),.i17(reg_out[17]),.i18(reg_out[18]),.i19(reg_out[19]),
    .i20(reg_out[20]),.i21(reg_out[21]),.i22(reg_out[22]),.i23(reg_out[23]),
    .i24(reg_out[24]),.i25(reg_out[25]),.i26(reg_out[26]),.i27(reg_out[27]),
    .i28(reg_out[28]),.i29(reg_out[29]),.i30(reg_out[30]),.i31(reg_out[31]),
    .sel(ReadRegister2)
  );

endmodule
