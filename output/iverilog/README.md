# Icarus Verilog simulation figures

Generated from `iverilog_demo/radar_demo.vcd` and `output/iverilog_cfar_demo_log.txt`  
**Script:** `scripts/plot_iverilog_outputs.py` · **Licence:** MIT

| File | Description |
|------|-------------|
| `01_cfar_waveforms.png` | GTKWave-style: cfar_busy, det_valid, det_flag, det_range |
| `02_range_profile_log.png` | Range bars + CFAR threshold (parsed from sim log) |
| `03_radar_scope.png` | 64-bin scope with 3 target markers |
| `04_console_pass.png` | Terminal output — DETECTION lines + PASS |
| `05_detection_timeline.png` | Detection time vs range bin (from VCD) |

Regenerate:

```powershell
cd iverilog_demo
.\demo.ps1 -NoWave
cd ..
python scripts/plot_iverilog_outputs.py
```

Open interactive waveforms: `gtkwave iverilog_demo/radar_demo.gtkw`
