`timescale 1ns/10ps
module cpu_tb;

    logic clk, reset;
    cpu DUT (.clk(clk), .reset(reset));

    initial begin
        clk = 0;
        forever #50 clk = ~clk;  // 100 ns period
    end

    initial begin
        reset = 1;
        #100;
        reset = 0;

        // Run for enough cycles (adjust if needed)
        repeat (200) @(posedge clk);
        $stop;
    end

endmodule
