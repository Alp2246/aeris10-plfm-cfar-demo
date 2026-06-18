# AERIS-10 PLFM Radar — CFAR Demos (MATLAB + Verilog)

[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![Icarus Verilog](https://img.shields.io/badge/Icarus-Verilog-orange.svg)](https://steveicarus.github.io/iverilog/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Radar: X-band](https://img.shields.io/badge/Radar-10.5%20GHz-green.svg)]()

Open-source **CA-CFAR detection demos** for the [AERIS-10 PLFM phased-array radar](https://github.com/NawfalMotii79/PLFM_RADAR). Includes **committed run outputs** (figures, logs, summaries) under MIT license — see [NOTICE.md](NOTICE.md) for upstream hardware licensing.

Same scenario everywhere: 3 synthetic targets at bins **8 / 22 / 45** (192 m / 528 m / 1080 m), LFSR noise seed `0xA5A51234`, CA-CFAR **G=2, T=8, α=5/16**.

---

## Demo outputs (included in repo)

### MATLAB figures

| Output | Preview |
|--------|---------|
| 4-panel dashboard | ![cfar_demo](output/cfar_demo.png) |
| PPI scope | ![cfar_ppi](output/cfar_ppi.png) |
| Detection table | [`output/cfar_results.txt`](output/cfar_results.txt) |

### Icarus Verilog figures and logs

| Output | Description |
|--------|-------------|
| Range profile plot | ![iverilog_range](output/iverilog_range_profile.png) |
| ASCII scope | [`output/iverilog_range_scope.txt`](output/iverilog_range_scope.txt) |
| CFAR detections | [`output/iverilog_cfar_detections.txt`](output/iverilog_cfar_detections.txt) |
| Full sim log | [`output/iverilog_cfar_demo_log.txt`](output/iverilog_cfar_demo_log.txt) |
| 11-module test pack | [`output/iverilog_module_tests_summary.txt`](output/iverilog_module_tests_summary.txt) |

### Cross-check

| Output | Description |
|--------|-------------|
| MATLAB vs Verilog | [`output/matlab_vs_verilog_comparison.txt`](output/matlab_vs_verilog_comparison.txt) |

**Verilog result:** 3/3 targets, 0 false alarms — **PASS**  
**MATLAB result:** 3/3 targets — bins match (threshold math differs slightly: float vs fixed-point)

---

## Quick start

### Regenerate everything

```powershell
.\scripts\export_outputs.ps1
```

### MATLAB only

```matlab
cd matlab
radar_cfar_demo
```

```bat
matlab\run_demo.bat
```

### Icarus Verilog CFAR demo

```powershell
cd iverilog_demo
.\demo.ps1 -NoWave
```

### Full RTL module pack (11 tests)

Requires full PLFM_RADAR clone:

```powershell
$env:PLFM_RADAR_ROOT = "C:\path\to\PLFM_RADAR-main"
cd iverilog_demo
.\sim.ps1 -Radar
```

---

## Repository layout

```
matlab/                 MATLAB scripts + batch runner
iverilog_demo/          demo.ps1, radar_demo_tb.v, bundled rtl/cfar_ca.v
output/                 Committed demo artifacts (PNG, TXT, logs)
scripts/                export_outputs.ps1, plot_range_profile.py
LICENSE                 MIT (this repo's original work + outputs)
NOTICE.md               MIT vs CERN-OHL-P upstream split
```

---

## Radar parameters

| Parameter | Value |
|-----------|-------|
| Carrier | 10.5 GHz (X-band) |
| Baseband fs | 100 MHz |
| Range bin | 24 m (16× decimation) |
| Max range | 1536 m (64 bins) |
| CFAR | CA-CFAR, G=2, T=8, α=5/16 |

---

## Related projects

- [PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) — full AERIS-10 hardware and firmware (CERN-OHL-P)
- [matlab-fmcw-isac-examples](https://github.com/Alp2246/matlab-fmcw-isac-examples) — FMCW / ISAC MATLAB demos

---

## License

**MIT** — scripts, wrappers, and committed `output/` artifacts in this repository ([LICENSE](LICENSE)).

Upstream AERIS-10 FPGA RTL and hardware: **CERN-OHL-P** in PLFM_RADAR ([NOTICE.md](NOTICE.md)).
