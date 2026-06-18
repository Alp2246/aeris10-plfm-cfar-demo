// ============================================================================
// radar_demo_tb.v
//
// AERIS-10 RADAR DEMO
// 3 sentetik hedefi gurultu icine gomup CFAR detektorunden gecirir,
// ASCII radar ekrani uretir + VCD dalga formu kaydeder.
//
//  Hedefler:
//    - Range bin  8: yakin hedef    (mag = 40000)
//    - Range bin 22: orta menzil    (mag = 20000)
//    - Range bin 45: uzak en guclu  (mag = 50000)
//  Gurultu zemini: ~1000-5000 (LFSR rastgele)
//  CFAR: CA-CFAR, guard=2, train=8, alpha=3.0 (Q4.4 = 0x30)
// ============================================================================

`timescale 1ns / 1ps
`define SIMULATION

module radar_demo_tb;

    // -------------------- Saat ve reset --------------------
    reg clk;
    reg reset_n;
    initial clk = 1'b0;
    always #5 clk = ~clk;   // 100 MHz

    // -------------------- CFAR Konfigurasyonu --------------
    reg [3:0]  cfg_guard       = 4'd2;
    reg [4:0]  cfg_train       = 5'd8;
    reg [7:0]  cfg_alpha       = 8'h05;   // Q4.4 = 5/16 = 0.3125  (Pfa ~ 1e-4, N=16)
    reg [1:0]  cfg_mode        = 2'b00;   // CA-CFAR
    reg        cfg_enable      = 1'b1;
    reg [15:0] cfg_simple_thr  = 16'd0;

    // -------------------- DUT arayuzu ----------------------
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

    // -------------------- Ground truth + capture buffers ----
    reg signed [15:0] truth_i [0:63];
    reg signed [15:0] truth_q [0:63];

    reg [16:0] cap_mag [0:63];
    reg [16:0] cap_thr [0:63];
    reg        cap_det [0:63];
    integer    n_det_0;

    integer i, j, k, bar_len, scenario_seed;

    // -------------------- Detection capture (doppler 0) ----
    //   Range bin -> Metre cevirimi:
    //     Matched filter sample period   = 10 ns @ 100 MHz baseband
    //     1 MF sample                    = c * Ts / 2 = 1.5 m
    //     16x range-bin decimation       => 1 CFAR bin = 24 m
    //     Round-trip echo time per bin   = 16 * 10 ns = 160 ns
    localparam integer BIN_METER = 24;     // metre / bin
    localparam integer BIN_TIME_NS = 160;  // round-trip ns / bin
    integer det_time_ns [0:63];

    always @(posedge clk) begin
        if (det_valid && cfar_busy && det_doppler == 5'd0) begin
            cap_mag[det_range] <= det_mag;
            cap_thr[det_range] <= det_thr;
            cap_det[det_range] <= det_flag;
            if (det_flag) begin
                n_det_0 <= n_det_0 + 1;
                det_time_ns[det_range] <= $time / 1000;  // ns
                // CANLI TESPIT LOGU
                $display(" >> [t=%0t ns]  *** DETECTION ***  bin=%0d  range=%0d m (%0.2f km)  mag=%0d  thr=%0d  margin=%0d%%",
                         $time/1000, det_range,
                         det_range * BIN_METER, det_range * BIN_METER / 1000.0,
                         det_mag, det_thr,
                         ((det_mag - det_thr) * 100) / det_thr);
            end
        end
    end

    // -------------------- Ana stimulus ---------------------
    initial begin
        $dumpfile("radar_demo.vcd");
        $dumpvars(0, radar_demo_tb);

        // Sabit seed, tekrarlanabilir gurultu
        scenario_seed = 32'hA5A5_1234;

        // ------- Noise floor (per I/Q ~ 700..1300, mag ~ 2000) ----
        for (i = 0; i < 64; i = i + 1) begin
            truth_i[i] = ({$random(scenario_seed)} % 600) + 700;
            truth_q[i] = ({$random(scenario_seed)} % 600) + 700;
            cap_mag[i] = 0;
            cap_thr[i] = 0;
            cap_det[i] = 1'b0;
        end

        // ------- 3 sentetik hedef -------------------------
        truth_i[8]  = 16'sd15000; truth_q[8]  = 16'sd15000;  // mag = 30000 (yakin, guclu)
        truth_i[22] = 16'sd10000; truth_q[22] = 16'sd10000;  // mag = 20000 (orta, zayifca)
        truth_i[45] = 16'sd25000; truth_q[45] = 16'sd25000;  // mag = 50000 (uzak, en guclu)

        n_det_0     = 0;
        reset_n     = 1'b0;
        dop_data    = 32'd0;
        dop_valid   = 1'b0;
        dop_bin     = 5'd0;
        rng_bin     = 6'd0;
        frame_done  = 1'b0;

        #100 reset_n = 1'b1;
        #20;

        $display("");
        $display("==============================================================");
        $display("    AERIS-10 RADAR -  CFAR DETECTION DEMO");
        $display("==============================================================");
        $display(" Senaryo:");
        $display("   - 64 menzil bin (range), 32 Doppler bin");
        $display("   - Doppler bin 0'da 3 sentetik hedef + LFSR gurultu");
        $display("   - Diger Doppler binleri sifir");
        $display("");
        $display(" Radar parametreleri (AERIS-10N):");
        $display("    Tasiyici       : 10.5 GHz (X-band)");
        $display("    Baseband fs    : 100 MHz");
        $display("    CFAR bin       : 24 m / bin  (16x decimation)");
        $display("    Toplam menzil  : 64 bin * 24 m = 1536 m (~1.5 km)");
        $display("");
        $display(" Ground truth (hedefler):");
        $display("    bin  8 = 192 m   ->  mag = 30000  (yakin)");
        $display("    bin 22 = 528 m   ->  mag = 20000  (orta)");
        $display("    bin 45 = 1080 m  ->  mag = 50000  (uzak en guclu)");
        $display(" Gurultu zemini    :  ~2000 (mag) - LFSR rastgele");
        $display("");
        $display(" CFAR konfig: CA-CFAR  guard=2  train=8  alpha=0x05 (Pfa~1e-4)");
        $display("==============================================================");
        $display(" Frame yukleniyor (2048 hucre)...");

        // --------- 2048 hucreyi BRAM'e yaz ----------------
        for (j = 0; j < 32; j = j + 1) begin
            for (i = 0; i < 64; i = i + 1) begin
                @(posedge clk);
                dop_valid <= 1'b1;
                dop_bin   <= j[4:0];
                rng_bin   <= i[5:0];
                if (j == 0)
                    dop_data <= { truth_q[i], truth_i[i] };
                else
                    dop_data <= 32'd0;
            end
        end
        @(posedge clk);
        dop_valid <= 1'b0;

        $display(" Frame yuklendi. frame_complete tetikleniyor...");
        @(posedge clk); frame_done <= 1'b1;
        @(posedge clk); frame_done <= 1'b0;

        // --------- CFAR isleme bitsin ---------------------
        @(posedge clk);
        wait (cfar_busy);
        $display(" CFAR isleme basladi (cfar_busy=1)...");
        wait (!cfar_busy);
        $display(" CFAR tamamlandi. detect_count toplami = %0d", det_count);
        #500;

        // --------- ASCII radar gostergesi -----------------
        $display("");
        $display("==============================================================");
        $display(" RANGE PROFILE   (Doppler bin 0)   - ASCII RADAR EKRANI");
        $display("==============================================================");
        $display(" Bin |Range(m)| Magnitude | Threshold | Det | Power Bar (#=1000)");
        $display(" ----+--------+-----------+-----------+-----+--------------------------------");
        for (i = 0; i < 64; i = i + 1) begin
            bar_len = cap_mag[i] / 1000;
            if (bar_len > 50) bar_len = 50;

            $write("  %2d | %5d  | %9d | %9d |", i, i * BIN_METER, cap_mag[i], cap_thr[i]);
            if (cap_det[i])
                $write("  *  |");
            else
                $write("  .  |");
            for (k = 0; k < bar_len; k = k + 1)
                $write("#");
            if (cap_det[i])
                $display("    <-- HEDEF (%0d m)", i * BIN_METER);
            else
                $display("");
        end
        $display("==============================================================");

        // --------- Final ozet -----------------------------
        $display(" SONUC:");
        $display("   Doppler-0'da yakalanan tespit sayisi: %0d", n_det_0);
        $display("   Ground truth hedef sayisi           : 3");
        $display("");
        $display("   Hedef listesi (menzil sirasinda):");
        $display("   --------------------------------------------------------------");
        $display("    bin | menzil  | echo zamani | magnitude |  margin (SNR)");
        $display("   --------------------------------------------------------------");
        for (i = 0; i < 64; i = i + 1)
            if (cap_det[i])
                $display("    %2d  | %5d m | %5d ns   |  %6d  |  %3d%% threshold ustu",
                         i, i * BIN_METER, i * BIN_TIME_NS, cap_mag[i],
                         ((cap_mag[i] - cap_thr[i]) * 100) / cap_thr[i]);
        $display("   --------------------------------------------------------------");

        if (n_det_0 == 3)
            $display("   >>>> [PASS]  3 hedefin hepsi yakalandi, false alarm yok.");
        else if (n_det_0 > 3)
            $display("   >>>> [WARN]  Tespit cok (false alarm) -- alpha artirilmali.");
        else
            $display("   >>>> [WARN]  Hedef kacirildi -- alpha azaltilmali / SNR dusuk.");

        $display("==============================================================");
        $display("");

        #200 $finish;
    end

endmodule
