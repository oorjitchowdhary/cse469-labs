`timescale 1ps/1ps

module decoder_5to32 (
    input  logic [4:0] in,
    input  logic enable,
    output logic [31:0] out
);

    logic n0, n1, n2, n3, n4;

    not #50 g0 (n0, in[0]);
    not #50 g1 (n1, in[1]);
    not #50 g2 (n2, in[2]);
    not #50 g3 (n3, in[3]);
    not #50 g4 (n4, in[4]);

    and #50 g5 (out[0],  enable, n4, n3, n2, n1, n0);
    and #50 g6 (out[1],  enable, n4, n3, n2, n1, in[0]);
    and #50 g7 (out[2],  enable, n4, n3, n2, in[1], n0);
    and #50 g8 (out[3],  enable, n4, n3, n2, in[1], in[0]);
    and #50 g9 (out[4],  enable, n4, n3, in[2], n1, n0);
    and #50 g10 (out[5],  enable, n4, n3, in[2], n1, in[0]);
    and #50 g11 (out[6],  enable, n4, n3, in[2], in[1], n0);
    and #50 g12 (out[7],  enable, n4, n3, in[2], in[1], in[0]);
    and #50 g13 (out[8],  enable, n4, in[3], n2, n1, n0);
    and #50 g14 (out[9],  enable, n4, in[3], n2, n1, in[0]);
    and #50 g15 (out[10], enable, n4, in[3], n2, in[1], n0);
    and #50 g16 (out[11], enable, n4, in[3], n2, in[1], in[0]);
    and #50 g17 (out[12], enable, n4, in[3], in[2], n1, n0);
    and #50 g18 (out[13], enable, n4, in[3], in[2], n1, in[0]);
    and #50 g19 (out[14], enable, n4, in[3], in[2], in[1], n0);
    and #50 g20 (out[15], enable, n4, in[3], in[2], in[1], in[0]);
    and #50 g21 (out[16], enable, in[4], n3, n2, n1, n0);
    and #50 g22 (out[17], enable, in[4], n3, n2, n1, in[0]);
    and #50 g23 (out[18], enable, in[4], n3, n2, in[1], n0);
    and #50 g24 (out[19], enable, in[4], n3, n2, in[1], in[0]);
    and #50 g25 (out[20], enable, in[4], n3, in[2], n1, n0);
    and #50 g26 (out[21], enable, in[4], n3, in[2], n1, in[0]);
    and #50 g27 (out[22], enable, in[4], n3, in[2], in[1], n0);
    and #50 g28 (out[23], enable, in[4], n3, in[2], in[1], in[0]);
    and #50 g29 (out[24], enable, in[4], in[3], n2, n1, n0);
    and #50 g30 (out[25], enable, in[4], in[3], n2, n1, in[0]);
    and #50 g31 (out[26], enable, in[4], in[3], n2, in[1], n0);
    and #50 g32 (out[27], enable, in[4], in[3], n2, in[1], in[0]);
    and #50 g33 (out[28], enable, in[4], in[3], in[2], n1, n0);
    and #50 g34 (out[29], enable, in[4], in[3], in[2], n1, in[0]);
    and #50 g35 (out[30], enable, in[4], in[3], in[2], in[1], n0);
    and #50 g36 (out[31], enable, in[4], in[3], in[2], in[1], in[0]);

endmodule
