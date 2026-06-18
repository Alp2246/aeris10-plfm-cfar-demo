//==============================================================================
// hello_tb.v — Icarus Verilog toolchain smoke test
//
// Author:  Alperen Bugra Ozer  (https://github.com/Alp2246)
// License: MIT
//==============================================================================

`timescale 1ns / 1ps

module hello_tb;
    reg        clk;
    reg        rst_n;
    reg [7:0]  counter;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("hello.vcd");
        $dumpvars(0, hello_tb);
        rst_n   = 1'b0;
        counter = 8'd0;
        #25 rst_n = 1'b1;
        $display("Icarus Verilog smoke test — @Alp2246");
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 8'd0;
        else
            counter <= counter + 8'd1;
    end

    always @(posedge clk) begin
        if (counter == 8'd10) begin
            $display("[t=%0t ns] counter=%0d — PASS", $time, counter);
            #20 $finish;
        end
    end
endmodule
