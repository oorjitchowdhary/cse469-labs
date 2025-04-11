module decoder_5to32 (
    input  logic [4:0] in,
    input  logic       enable,
    output logic [31:0] RegNo
);

    // Internal wire for XNOR results
    logic [4:0] match [0:30]; // 31 lines with 5 bits each
    logic [30:0] eq_match;    // Result of all XNOR & ANDs

    genvar i, j;
    generate
        for (i = 0; i < 31; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                assign match[i][j] = ~(in[j] ^ i[j]);
            end

            assign eq_match[i] = match[i][0] & match[i][1] & match[i][2] & match[i][3] & match[i][4];
            assign RegNo[i] = enable & eq_match[i];
        end
    endgenerate

    assign RegNo[31] = 1'b0;

endmodule

//how it works: if input is 22 (5'b10110), and each bit of input XNOR i from 0-30, if XNOR with itself, it becomes 1. When ANDed,
//it becomes 1, showing decoder works from 5:32
