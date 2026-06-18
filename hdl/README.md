# HDL — original Verilog

| File | Lines | Role |
|------|-------|------|
| [`radar_demo_tb.v`](radar_demo_tb.v) | ~200 | **Main portfolio piece** — CFAR system testbench |
| [`hello_tb.v`](hello_tb.v) | ~40 | Toolchain smoke test |

The device under test (`cfar_ca`) lives in [`../third_party/`](../third_party/) — FPGA IP from the AERIS-10 project, included here so the bench runs standalone.

**Compile (from repo root):**

```bash
iverilog -g2012 -DSIMULATION -o sim.vvp -s radar_demo_tb \
  hdl/radar_demo_tb.v third_party/cfar_ca.v
vvp sim.vvp
```

Or use `iverilog_demo/demo.ps1` for the full coloured console demo.
