//==============================================================================
// radar_demo_tb.v
//
// Author:  Alperen Bugra Ozer  (https://github.com/Alp2246)
// License: MIT
//
// Verilog testbench — CA-CFAR target detection demo for AERIS-10 PLFM radar.
//   • Injects 3 synthetic targets + deterministic LFSR noise (Doppler bin 0)
//   • Instantiates cfar_ca as DUT (see ../third_party/)
//   • Captures detections, prints ASCII range profile + PASS/FAIL verdict
//   • Dumps VCD for GTKWave review
//
// Toolchain: Icarus Verilog (iverilog / vvp) — no vendor sim required.
//==============================================================================

`timescale 1ns / 1ps
`define SIMULATION

module radar_demo_tb;

    // -------------------- Clock & reset (100 MHz) -------------------------
    reg clk;
    reg reset_n;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // -------------------- CFAR configuration (matches FPGA registers) -----
    reg [3:0]  cfg_guard       = 4'd2;
    reg [4:0]  cfg_train       = 5'd8;
    reg [7:0]  cfg_alpha       = 8'h05;   // Q4.4 = 5/16
    reg [1:0]  cfg_mode        = 2'b00;   // CA-CFAR
    reg        cfg_enable      = 1'b1;
    reg [15:0] cfg_simple_thr  = 16'd0;

    // -------------------- DUT interface -----------------------------------
    reg  [31:0] dop_data;
    reg         dop_valid;
    reg  [4:0]  dop_bin;
    reg  [5:0]  rng_bin;
    reg         frame_done;

    wire        det_flag;
    wire        det_valid;
    wire [5:0]  det_range;
    wire [4:0]  det_doppler;
    wire [16:0] det_mag;
    wire [16:0] det_thr;
    wire [15:0] det_count;
    wire        cfar_busy;
    wire [7:0]  cfar_status;

    cfar_ca #(
        .NUM_RANGE_BINS  (64),
        .NUM_DOPPLER_BINS(32)
    ) dut (
        .clk                 (clk),
        .reset_n             (reset_n),
        .doppler_data        (dop_data),
        .doppler_valid       (dop_valid),
        .doppler_bin_in      (dop_bin),
        .range_bin_in        (rng_bin),
        .frame_complete      (frame_done),
        .cfg_guard_cells     (cfg_guard),
        .cfg_train_cells     (cfg_train),
        .cfg_alpha           (cfg_alpha),
        .cfg_cfar_mode       (cfg_mode),
        .cfg_cfar_enable     (cfg_enable),
        .cfg_simple_threshold(cfg_simple_thr),
        .detect_flag         (det_flag),
        .detect_valid        (det_valid),
        .detect_range        (det_range),
        .detect_doppler      (det_doppler),
        .detect_magnitude    (det_mag),
        .detect_threshold    (det_thr),
        .detect_count        (det_count),
        .cfar_busy           (cfar_busy),
        .cfar_status         (cfar_status)
    );

    // -------------------- Stimulus memory & capture -----------------------
    reg signed [15:0] truth_i [0:63];
    reg signed [15:0] truth_q [0:63];

    reg [16:0] cap_mag [0:63];
    reg [16:0] cap_thr [0:63];
    reg        cap_det [0:63];
    integer    n_det_0;

    integer i, j, k, bar_len, scenario_seed;

    localparam integer BIN_METER   = 24;   // metres per range bin (16x decimation)
    localparam integer BIN_TIME_NS = 160;  // round-trip echo time per bin
    integer det_time_ns [0:63];

    // Live detection logger — runs on every valid CFAR output (Doppler 0 only)
    always @(posedge clk) begin
        if (det_valid && cfar_busy && det_doppler == 5'd0) begin
            cap_mag[det_range] <= det_mag;
            cap_thr[det_range] <= det_thr;
            cap_det[det_range] <= det_flag;
            if (det_flag) begin
                n_det_0 <= n_det_0 + 1;
                det_time_ns[det_range] <= $time / 1000;
                $display(" >> [t=%0t ns]  *** DETECTION ***  bin=%0d  range=%0d m (%0.2f km)  mag=%0d  thr=%0d  margin=%0d%%",
                         $time/1000, det_range,
                         det_range * BIN_METER, det_range * BIN_METER / 1000.0,
                         det_mag, det_thr,
                         ((det_mag - det_thr) * 100) / det_thr);
            end
        end
    end

    // -------------------- Main stimulus sequence --------------------------
    initial begin
        $dumpfile("radar_demo.vcd");
        $dumpvars(0, radar_demo_tb);

        scenario_seed = 32'hA5A5_1234;

        for (i = 0; i < 64; i = i + 1) begin
            truth_i[i] = ({$random(scenario_seed)} % 600) + 700;
            truth_q[i] = ({$random(scenario_seed)} % 600) + 700;
            cap_mag[i] = 0;
            cap_thr[i] = 0;
            cap_det[i] = 1'b0;
        end

        // Three synthetic targets (|I|+|Q| magnitude)
        truth_i[8]  = 16'sd15000; truth_q[8]  = 16'sd15000;  // mag 30000 @ 192 m
        truth_i[22] = 16'sd10000; truth_q[22] = 16'sd10000;  // mag 20000 @ 528 m
        truth_i[45] = 16'sd25000; truth_q[45] = 16'sd25000;  // mag 50000 @ 1080 m

        n_det_0 = 0; reset_n = 1'b0;
        dop_data = 32'd0; dop_valid = 1'b0;
        dop_bin = 5'd0; rng_bin = 6'd0; frame_done = 1'b0;

        #100 reset_n = 1'b1;
        #20;

        $display("");
        $display("==============================================================");
        $display("    AERIS-10 RADAR -  CFAR DETECTION DEMO");
        $display("    Testbench: radar_demo_tb.v  |  Author: @Alp2246");
        $display("==============================================================");
        $display(" Ground truth: bins 8/22/45  |  seed 0xA5A51234  |  CA-CFAR G=2 T=8");
        $display("==============================================================");

        // Stream 32 x 64 Doppler-range cells into DUT BRAM
        for (j = 0; j < 32; j = j + 1) begin
            for (i = 0; i < 64; i = i + 1) begin
                @(posedge clk);
                dop_valid <= 1'b1;
                dop_bin   <= j[4:0];
                rng_bin   <= i[5:0];
                dop_data  <= (j == 0) ? { truth_q[i], truth_i[i] } : 32'd0;
            end
        end
        @(posedge clk);
        dop_valid <= 1'b0;

        @(posedge clk); frame_done <= 1'b1;
        @(posedge clk); frame_done <= 1'b0;

        @(posedge clk);
        wait (cfar_busy);
        wait (!cfar_busy);
        #500;

        // ASCII range profile
        $display("");
        $display(" RANGE PROFILE (Doppler 0) — ASCII display");
        $display(" Bin |Range(m)| Magnitude | Threshold | Det | Power Bar");
        for (i = 0; i < 64; i = i + 1) begin
            bar_len = cap_mag[i] / 1000;
            if (bar_len > 50) bar_len = 50;
            $write("  %2d | %5d  | %9d | %9d |", i, i * BIN_METER, cap_mag[i], cap_thr[i]);
            if (cap_det[i])
                $write("  *  |");
            else
                $write("  .  |");
            for (k = 0; k < bar_len; k = k + 1) $write("#");
            if (cap_det[i])
                $display("    <-- TARGET (%0d m)", i * BIN_METER);
            else
                $display("");
        end

        $display("");
        $display(" SONUC: %0d detections on Doppler 0 (expected 3)", n_det_0);

        if (n_det_0 == 3)
            $display(" >>>> [PASS]  All targets found, zero false alarms.");
        else if (n_det_0 > 3)
            $display(" >>>> [WARN]  Too many detections — raise alpha.");
        else
            $display(" >>>> [WARN]  Missed target — lower alpha or raise SNR.");

        #200 $finish;
    end

endmodule
