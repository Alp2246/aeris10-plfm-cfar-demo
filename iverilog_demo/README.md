# Icarus Verilog runner

Runs the testbench in [`../hdl/radar_demo_tb.v`](../hdl/radar_demo_tb.v) against [`../third_party/cfar_ca.v`](../third_party/cfar_ca.v).

```powershell
.\demo.ps1 -NoWave      # coloured console + PASS/FAIL
.\demo.ps1              # + GTKWave waveform viewer
```

Full 11-module FPGA test pack (`sim.ps1 -Radar`) needs a local PLFM_RADAR clone — set `$env:PLFM_RADAR_ROOT`.
