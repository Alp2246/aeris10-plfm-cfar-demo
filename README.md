# AERIS-10 Radar — Full verification portfolio

**Author:** [Alperen Bugra Ozer](https://github.com/Alp2246)  
**Verilog testbench · Icarus simulation · MATLAB figures · related radar/GNSS demos**

[![Verilog](https://img.shields.io/badge/Verilog-Icarus-orange.svg)](hdl/radar_demo_tb.v)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-blue.svg)](matlab/radar_cfar_demo.m)
[![License: MIT](https://img.shields.io/badge/Original-MIT-yellow.svg)](LICENSE)
[![DUT: CERN-OHL-P](https://img.shields.io/badge/DUT-CERN--OHL--P-blue.svg)](third_party/CERN-OHL-P-NOTICE.txt)
[![Sim: PASS](https://img.shields.io/badge/CFAR-3%2F3%20PASS-brightgreen.svg)](output/iverilog_cfar_detections.txt)

> **Complete radar picture:** CFAR stage verified in Verilog + MATLAB, mapped onto the AERIS-10 FPGA chain, with committed outputs and detailed licensing for thesis / portfolio use.

📘 **System context:** [docs/RADAR_SYSTEM.md](docs/RADAR_SYSTEM.md) · **All outputs:** [docs/OUTPUT_CATALOG.md](docs/OUTPUT_CATALOG.md) · **Legal (EN/TR):** [docs/LEGAL.md](docs/LEGAL.md)

![Verilog range profile](output/iverilog/02_range_profile_log.png)

### Icarus Verilog — simulation figures (`output/iverilog/`)

| Waveforms (VCD) | Range + CFAR (log) | Radar scope | Console PASS |
|:---:|:---:|:---:|:---:|
| ![wf](output/iverilog/01_cfar_waveforms.png) | ![rp](output/iverilog/02_range_profile_log.png) | ![sc](output/iverilog/03_radar_scope.png) | ![con](output/iverilog/04_console_pass.png) |
| det_flag / cfar_busy | Real mag + threshold | bins 8, 22, 45 | `>>>> [PASS]` |

Detection timeline (VCD): [05_detection_timeline.png](output/iverilog/05_detection_timeline.png)  
Regenerate: `python scripts/plot_iverilog_outputs.py` after `iverilog_demo\demo.ps1 -NoWave`  
Interactive: `gtkwave iverilog_demo/radar_demo.gtkw`

---

## Full radar signal chain (where this demo sits)

```mermaid
flowchart LR
    A[LFM chirp] --> B[Pulse compression]
    B --> C[Doppler FFT]
    C --> D[MTI]
    D --> E[CA-CFAR]
    E --> F[Targets / GUI]
    TB[My Verilog TB] -.verifies.-> E
    ML[My MATLAB] -.same scenario.-> E
```

Upstream platform: [AERIS-10 PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) (10.5 GHz phased array, CERN-OHL-P).  
This repo verifies **step E** and documents the full context in [RADAR_SYSTEM.md](docs/RADAR_SYSTEM.md).

---

## What I built

| Component | Path | Description |
|-----------|------|-------------|
| **Verilog testbench** | [`hdl/radar_demo_tb.v`](hdl/radar_demo_tb.v) | Stimulus, DUT hookup, detection capture, ASCII range plot, auto PASS/FAIL |
| Simulation runner | [`iverilog_demo/demo.ps1`](iverilog_demo/demo.ps1) | One-click compile + coloured console demo |
| MATLAB twin | [`matlab/radar_cfar_demo.m`](matlab/radar_cfar_demo.m) | Same scenario — figures for reports |
| Walkthrough | [`docs/VERILOG_WALKTHROUGH.md`](docs/VERILOG_WALKTHROUGH.md) | Architecture + annotated code |

**DUT (upstream IP):** [`third_party/cfar_ca.v`](third_party/cfar_ca.v) — CA-CFAR block from [AERIS-10 PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) (CERN-OHL-P). License details: [NOTICE.md](NOTICE.md).

---

## Verilog highlight — DUT + checker

```verilog
// hdl/radar_demo_tb.v — @Alp2246
cfar_ca #(.NUM_RANGE_BINS(64), .NUM_DOPPLER_BINS(32)) dut ( ... );

always @(posedge clk)
    if (det_valid && cfar_busy && det_doppler == 5'd0 && det_flag)
        $display("*** DETECTION *** bin=%0d range=%0d m", det_range, det_range * 24);

// ...
if (n_det_0 == 3)
    $display(">>>> [PASS]  All targets found, zero false alarms.");
```

Full walkthrough: [**docs/VERILOG_WALKTHROUGH.md**](docs/VERILOG_WALKTHROUGH.md)

---

## Results (committed)

| | Verilog | MATLAB |
|---|---------|--------|
| Targets found | 3/3 @ bins 8, 22, 45 | 3/3 — same bins |
| False alarms | 0 | 0 |
| Verdict | **PASS** | match |

| Artifact | Link |
|----------|------|
| Range profile (plot) | [output/iverilog_range_profile.png](output/iverilog_range_profile.png) |
| MATLAB 4-panel | [output/cfar_demo.png](output/cfar_demo.png) |
| MATLAB panels (×5) | [output/matlab/cfar/](output/matlab/cfar/) |
| Other MATLAB demos | [output/matlab/gallery/](output/matlab/gallery/) |
| Sim log | [output/iverilog_cfar_demo_log.txt](output/iverilog_cfar_demo_log.txt) |
| Cross-check | [output/matlab_vs_verilog_comparison.txt](output/matlab_vs_verilog_comparison.txt) |

### MATLAB — CFAR panels

| | | |
|:---:|:---:|:---:|
| ![range](output/matlab/cfar/01_range_profile.png) | ![ppi](output/matlab/cfar/02_ppi_scope.png) | ![time](output/matlab/cfar/03_time_domain.png) |
| Range + CFAR | PPI scope | Time domain |
| ![window](output/matlab/cfar/04_cfar_window.png) | ![ppi full](output/matlab/cfar/05_ppi_full.png) | |
| Sliding window | Full PPI | |

### MATLAB — related demos (gallery)

| FMCW RD | FMCW MIMO | Kalman | ISAC OFDM |
|:---:|:---:|:---:|:---:|
| ![rd](output/matlab/gallery/fmcw_range_doppler.png) | ![mimo](output/matlab/gallery/fmcw_mimo_animasyon.png) | ![kalman](output/matlab/gallery/fmcw_kalman_tracker.png) | ![isac](output/matlab/gallery/isac_ofdm_sensing.png) |

| BPSK BER | PRN bias 1 | PRN bias 2 | Ramp bias |
|:---:|:---:|:---:|:---:|
| ![bpsk](output/matlab/gallery/bpsk_ber_awgn.png) | ![prn1](output/matlab/gallery/pseudorange_prn_bias_fig1.png) | ![prn2](output/matlab/gallery/pseudorange_prn_bias_fig2.png) | ![ramp](output/matlab/gallery/pseudorange_ramp_bias.png) |

| Spoof residual | Track metrics |
|:---:|:---:|
| ![res](output/matlab/gallery/residual_spoof_detect.png) | ![track](output/matlab/gallery/softgnss_track_metrics.png) |

Sources: [matlab-fmcw-isac-examples](https://github.com/Alp2246/matlab-fmcw-isac-examples) · [matlab-wireless-comm-examples](https://github.com/Alp2246/matlab-wireless-comm-examples) · [gnss-spoofing-research](https://github.com/Alp2246/gnss-spoofing-research)

---

## Run it

```powershell
git clone https://github.com/Alp2246/aeris10-plfm-cfar-demo.git
cd aeris10-plfm-cfar-demo\iverilog_demo
.\demo.ps1 -NoWave
```

```bash
iverilog -g2012 -DSIMULATION -o sim.vvp -s radar_demo_tb \
  hdl/radar_demo_tb.v third_party/cfar_ca.v
vvp sim.vvp
```

```matlab
cd matlab; radar_cfar_demo
```

Regenerate all outputs: `.\scripts\export_outputs.ps1`

---

## Repo layout

```
hdl/                    ← my Verilog (start here for code review)
  radar_demo_tb.v
  hello_tb.v
third_party/            ← AERIS-10 CFAR IP (DUT)
iverilog_demo/          ← demo.ps1, GTKWave config
matlab/                 ← MATLAB figures
output/                 ← all committed artifacts (see OUTPUT_CATALOG.md)
docs/
  RADAR_SYSTEM.md       ← full chain + upstream links
  OUTPUT_CATALOG.md       ← every PNG/TXT indexed
  LEGAL.md              ← detailed licence (EN + TR, YÖK)
  REFERENCES.md         ← BibTeX & reading list
  VERILOG_WALKTHROUGH.md
LICENSE                  MIT — original work
NOTICE.md                File-by-file licence map
CREDITS.md               Author + citations
CITATION.cff
third_party/CERN-OHL-P-NOTICE.txt
```

---

## Scenario

- **Radar:** 10.5 GHz X-band, 100 MHz baseband, 24 m/bin, 1536 m max range  
- **CFAR:** CA-CFAR, guard=2, train=8, α=5/16  
- **Targets:** 192 m / 528 m / 1080 m — seed `0xA5A51234`

---

## License & credits

This repo uses **two licenses** — original demo work vs upstream FPGA IP.

| Component | Author | License | Details |
|-----------|--------|---------|---------|
| `hdl/`, `matlab/`, `scripts/`, `output/`, docs | [Alperen Bugra Ozer](https://github.com/Alp2246) | **MIT** | [LICENSE](LICENSE) |
| `third_party/cfar_ca.v` (DUT) | [AERIS-10 / PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) | **CERN-OHL-P** | [third_party/](third_party/) |

**Full legal pack** (thesis / YÖK / portfolio):

- [docs/LEGAL.md](docs/LEGAL.md) — English + Türkçe, figure captions, CERN-OHL-P duties  
- [NOTICE.md](NOTICE.md) — file-by-file MIT vs CERN-OHL-P map + gallery table  
- [docs/OUTPUT_CATALOG.md](docs/OUTPUT_CATALOG.md) — every committed output  
- [CREDITS.md](CREDITS.md) — author + BibTeX-style citations  
- [docs/REFERENCES.md](docs/REFERENCES.md) — further reading  
- [third_party/CERN-OHL-P-NOTICE.txt](third_party/CERN-OHL-P-NOTICE.txt) — hardware redistribution  

[![License: MIT](https://img.shields.io/badge/Original%20work-MIT-yellow.svg)](LICENSE)
[![Hardware: CERN-OHL-P](https://img.shields.io/badge/DUT-CERN--OHL--P-blue.svg)](https://ohwr.org/cern_ohl_p_v2.txt)
[![Legal: EN+TR](https://img.shields.io/badge/Legal-EN%2BTR-lightgrey.svg)](docs/LEGAL.md)
