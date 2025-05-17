`timescale 1ps/1ps

module decoder_3to8 (
    input  logic [2:0] in,
    input  logic enable,
    output logic [7:0] out
);

    logic n0, n1, n2;

    not #50 g0(n0, in[0]);
    not #50 g1(n1, in[1]);
    not #50 g2(n2, in[2]);

    and #50 g3 (out[0], enable, n2, n1, n0);       // 000
    and #50 g4 (out[1], enable, n2, n1,  in[0]);   // 001
    and #50 g5 (out[2], enable, n2,  in[1], n0);   // 010
    and #50 g6 (out[3], enable, n2,  in[1],  in[0]); // 011
    and #50 g7 (out[4], enable,  in[2], n1, n0);   // 100
    and #50 g8 (out[5], enable,  in[2], n1,  in[0]); // 101
    and #50 g9 (out[6], enable,  in[2],  in[1], n0); // 110
    and #50 g10 (out[7], enable,  in[2],  in[1],  in[0]); // 111

endmodule
