`timescale 1ps/1ps

module regfile (
  output logic [63:0] reg_out [31:0],
  output logic [63:0] ReadData1,
  output logic [63:0] ReadData2,
  input  logic [63:0] WriteData,
  input  logic [4:0] ReadRegister1,
  input  logic [4:0] ReadRegister2,
  input  logic [4:0] WriteRegister,
  input  logic RegWrite,
  input  logic clk,
  input logic reset
);

  logic [31:0] raw_write_enable, write_enable;
  decoder_5to32 decoder (
    .out(raw_write_enable),
    .in(WriteRegister),
    .enable(RegWrite)
  );

  // don't allow writes to X31/XZR
  logic [63:0] forced_write_enable;
  and_64bit and_force_xzr (.A({32'b0, raw_write_enable}), .B(64'h7FFFFFFF), .out(forced_write_enable));
  assign write_enable = forced_write_enable[31:0];
  
  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : regfile_gen
      register_64bit reg_i (
        .q(reg_out[i]),
        .d(WriteData),
        .clk(clk),
        .reset(reset),
        .enable(write_enable[i])
      );
    end
  endgenerate

  logic [63:0] read_raw1;
  mux32_1_64bit read_mux1 (
    .out(read_raw1),
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

  logic [63:0] read_raw2;
  mux32_1_64bit read_mux2 (
    .out(read_raw2),
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

  // synchronization logic for read-after-write hazard prevention
  logic wr_eq_rd1, wr_eq_rd2, is_xzr, not_xzr;
  logic bypass1, bypass2;

  // check if WriteRegister == ReadRegister
  comparator_5bit cmp_wr_rd1 (.a(WriteRegister), .b(ReadRegister1), .equal(wr_eq_rd1));
  comparator_5bit cmp_wr_rd2 (.a(WriteRegister), .b(ReadRegister2), .equal(wr_eq_rd2));

  // don't bypass if WriteRegister is XZR
  comparator_5bit cmp_wr_xzr (.a(WriteRegister), .b(5'd31), .equal(is_xzr));
  not #50 inv_xzr (not_xzr, is_xzr);

  // bypass = RegWrite & match (WriteRegister != 31)
  and #50 by1 (bypass1, RegWrite, wr_eq_rd1, not_xzr);
  and #50 by2 (bypass2, RegWrite, wr_eq_rd2, not_xzr);

  // if bypass, use data just written. else, use array value
  mux2_1_64bit bypass_mux1 (.out(ReadData1), .i0(read_raw1), .i1(WriteData), .sel(bypass1));
  mux2_1_64bit bypass_mux2 (.out(ReadData2), .i0(read_raw2), .i1(WriteData), .sel(bypass2));

endmodule
