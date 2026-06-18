# License notice

This repository combines **original work** (MIT) with **third-party open hardware** (CERN-OHL-P). Read this file before redistributing, forking, or using figures in a thesis or report.

---

## 1. Original work — MIT License

Copyright (c) 2026 **Alperen Bugra Ozer** ([Alp2246](https://github.com/Alp2246))

Licensed under the [MIT License](LICENSE). You may use, copy, modify, merge, publish, distribute, sublicense, and sell copies, provided the copyright notice and permission notice are included.

### Files covered (original)

| Path | Description |
|------|-------------|
| `hdl/radar_demo_tb.v` | Verilog system testbench — stimulus, checker, ASCII display |
| `hdl/hello_tb.v` | Icarus Verilog toolchain smoke test |
| `hdl/README.md` | HDL documentation |
| `matlab/radar_cfar_demo.m` | MATLAB CA-CFAR visualization (same scenario as TB) |
| `matlab/run_demo.bat` | Windows batch runner |
| `matlab/README.txt` | MATLAB usage notes |
| `iverilog_demo/demo.ps1` | Coloured console demo + GTKWave launcher |
| `iverilog_demo/sim.ps1` | Multi-module Icarus test runner |
| `iverilog_demo/radar_demo.gtkw` | GTKWave signal layout |
| `iverilog_demo/KOMUTLAR.txt` | Command reference (Turkish) |
| `iverilog_demo/README.md` | Runner documentation |
| `scripts/export_outputs.ps1` | Regenerate all committed artifacts |
| `scripts/plot_range_profile.py` | Range-profile PNG export |
| `scripts/requirements.txt` | Python dependencies |
| `output/*` | Committed simulation logs, PNG figures, summary tables |
| `docs/VERILOG_WALKTHROUGH.md` | Technical walkthrough |
| `README.md`, `CREDITS.md`, `NOTICE.md`, `.gitignore` | Repository documentation |

### Suggested attribution (copy-paste)

```
Radar CFAR verification demo — Verilog testbench and MATLAB figures
by Alperen Bugra Ozer (https://github.com/Alp2246)
Licensed under MIT: https://github.com/Alp2246/aeris10-plfm-cfar-demo
```

---

## 2. Third-party hardware RTL — CERN-OHL-P

The **device under test** and related FPGA IP are from the open-source **AERIS-10 / PLFM_RADAR** project:

| Path | Upstream | License |
|------|----------|---------|
| `third_party/cfar_ca.v` | [NawfalMotii79/PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) | [CERN-OHL-P v2](https://ohwr.org/cern_ohl_p_v2.txt) |

This demo repo **bundles a copy** of `cfar_ca.v` so the testbench runs standalone. It does **not** re-license the full AERIS-10 hardware design, schematics, PCB layouts, or complete firmware tree.

**If you redistribute `third_party/cfar_ca.v`**, comply with CERN-OHL-P (preserve notices, document modifications, etc.). For the complete radar platform, clone the upstream repository.

### Upstream attribution

```
CFAR detector RTL from AERIS-10 PLFM Radar (PLFM_RADAR)
https://github.com/NawfalMotii79/PLFM_RADAR
Hardware license: CERN Open Hardware Licence v2 — Permissive
```

---

## 3. Relationship between components

```
┌─────────────────────────────────────────────────────────────┐
│  MIT (this repo)                                            │
│  hdl/radar_demo_tb.v  ──drives──►  third_party/cfar_ca.v    │
│  matlab/, scripts/, output/          (CERN-OHL-P upstream)  │
└─────────────────────────────────────────────────────────────┘
```

- **Your portfolio / coursework citation:** cite this repo for the testbench, scripts, and figures.
- **Hardware / FPGA IP citation:** cite PLFM_RADAR and CERN-OHL-P for `cfar_ca.v` and full AERIS-10 design.

---

## 4. Committed `output/` artifacts

All files under `output/` are **generated results** from running the demos. They are committed under **MIT** as documentation and portfolio evidence (PNG plots, text logs, detection tables). You may reuse them in reports with attribution to this repository.

| File | Source tool |
|------|-------------|
| `cfar_demo.png`, `cfar_ppi.png`, `cfar_results.txt` | MATLAB `radar_cfar_demo.m` |
| `iverilog_range_profile.png` | Python `plot_range_profile.py` |
| `iverilog_cfar_demo_log.txt`, `iverilog_cfar_detections.txt` | Icarus `demo.ps1` / `vvp` |
| `iverilog_module_tests_summary.txt` | Icarus `sim.ps1 -Radar` |
| `iverilog_range_scope.txt` | Derived ASCII scope |
| `matlab_vs_verilog_comparison.txt` | Cross-check summary |

---

## 5. Third-party tools (not included)

| Tool | License | Notes |
|------|---------|-------|
| [MATLAB](https://www.mathworks.com/products/matlab.html) | Commercial | Required to run `.m` scripts; not shipped |
| [Icarus Verilog](https://steveicarus.github.io/iverilog/) | GPL | `iverilog`, `vvp` — compile and simulate |
| [GTKWave](http://gtkwave.sourceforge.net/) | GPL | Optional waveform viewer |

Running simulations does not convey a license on MathWorks or GPL tools themselves.

---

## 6. Disclaimer

Radar and FPGA demos are for **education, verification, and portfolio** purposes. They are not certified for safety-critical, defence, or production radar deployment. Simulation results do not replace calibrated hardware measurements.

---

## Quick reference

| What | License | Where |
|------|---------|-------|
| My Verilog TB, scripts, MATLAB, docs, outputs | **MIT** | [LICENSE](LICENSE) |
| `cfar_ca.v` (DUT) | **CERN-OHL-P** | [third_party/](third_party/) |
| Full AERIS-10 hardware | **CERN-OHL-P** | [PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) |

See also [CREDITS.md](CREDITS.md) for author and upstream credits.
