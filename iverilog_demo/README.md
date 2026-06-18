# Icarus Verilog CFAR Demo

Self-contained **CFAR detection demo** (`demo.ps1` + bundled `rtl/cfar_ca.v`).

Full **11-module radar test pack** (`sim.ps1 -Radar`) needs a local [PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) checkout:

```powershell
# Optional: point to full RTL tree
$env:PLFM_RADAR_ROOT = "C:\fpga_work\PLFM_RADAR-main\PLFM_RADAR-main"
cd iverilog_demo
.\sim.ps1 -Radar
```

## Quick run (CFAR only)

```powershell
cd iverilog_demo
.\demo.ps1 -NoWave
```

Outputs are saved under `../output/` when using `scripts/export_outputs.ps1` from repo root.

## Requirements

- [Icarus Verilog](https://steveicarus.github.io/iverilog/) (`iverilog`, `vvp`)
- Optional: GTKWave for `radar_demo.vcd`

## License

MIT for scripts in this folder. `rtl/cfar_ca.v` is upstream FPGA RTL (CERN-OHL-P) — see [NOTICE.md](../NOTICE.md).
