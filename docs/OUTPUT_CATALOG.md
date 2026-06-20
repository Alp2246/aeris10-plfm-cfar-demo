# Output catalog — every committed artifact

**Regenerate:** `.\scripts\export_outputs.ps1` · **Gallery refresh:** `.\scripts\fetch_matlab_gallery.ps1`  
**Licence:** MIT for CFAR/Verilog outputs; gallery per source repo — [NOTICE.md](../NOTICE.md)

---

## AERIS-10 CFAR — MATLAB (`output/matlab/cfar/`)

| File | Description |
|------|-------------|
| `01_range_profile.png` | Magnitude vs range + CFAR threshold |
| `02_ppi_scope.png` | PPI (subplot) |
| `03_time_domain.png` | Echo vs round-trip time |
| `04_cfar_window.png` | CA-CFAR sliding window at CUT=22 |
| `05_ppi_full.png` | Full-page PPI with sweep line |
| `cfar_demo_4panel.png` | Combined dashboard |
| `cfar_results.txt` | bin / range / mag / thr / margin |

**Script:** `matlab/radar_cfar_demo.m`

---

## AERIS-10 CFAR — legacy root copies

| File | Same as |
|------|---------|
| `output/cfar_demo.png` | `matlab/cfar/cfar_demo_4panel.png` |
| `output/cfar_ppi.png` | `matlab/cfar/05_ppi_full.png` |
| `output/cfar_results.txt` | `matlab/cfar/cfar_results.txt` |

---

## Verilog / Python (`output/` root + `output/iverilog/`)

| File | Generator |
|------|-----------|
| `iverilog/01_cfar_waveforms.png` | VCD — cfar_busy, det_valid, det_flag, det_range |
| `iverilog/02_range_profile_log.png` | Sim log — magnitude + threshold bars |
| `iverilog/03_radar_scope.png` | 64-bin scope graphic |
| `iverilog/04_console_pass.png` | Terminal DETECTION + PASS excerpt |
| `iverilog/05_detection_timeline.png` | VCD — detection time vs bin |
| `iverilog_range_profile.png` | Legacy copy of `02_range_profile_log.png` |
| `iverilog_cfar_demo_log.txt` | `iverilog_demo/demo.ps1` |
| `iverilog_cfar_detections.txt` | Parsed 3-target summary |
| `iverilog_module_tests_log.txt` | `sim.ps1 -Radar` |
| `iverilog_module_tests_summary.txt` | 11-module PASS table |
| `iverilog_range_scope.txt` | ASCII scope |
| `matlab_vs_verilog_comparison.txt` | Bin-level cross-check |

---

## MATLAB gallery (`output/matlab/gallery/`)

| File | Source repository | Topic |
|------|-------------------|-------|
| `fmcw_range_doppler.png` | [matlab-fmcw-isac-examples](https://github.com/Alp2246/matlab-fmcw-isac-examples) | FMCW range–Doppler |
| `fmcw_mimo_animasyon.png` | same | MIMO animation frame |
| `fmcw_kalman_tracker.png` | same | Kalman tracking |
| `isac_ofdm_sensing.png` | same | ISAC / OFDM sensing |
| `bpsk_ber_awgn.png` | [matlab-wireless-comm-examples](https://github.com/Alp2246/matlab-wireless-comm-examples) | BPSK BER curve |
| `pseudorange_prn_bias_fig1.png` | [gnss-spoofing-research](https://github.com/Alp2246/gnss-spoofing-research) | PRN bias (fig 1) |
| `pseudorange_prn_bias_fig2.png` | same | PRN bias (fig 2) |
| `pseudorange_ramp_bias.png` | same | Ramp bias |
| `residual_spoof_detect.png` | same | Residual spoof detector |
| `softgnss_track_metrics.png` | same | SoftGNSS metrics |

All gallery sources: **MIT** (Alp2246 repos).
