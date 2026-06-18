# Committed demo outputs

Pre-generated artifacts from MATLAB, Icarus Verilog, and Python export scripts.  
**License:** MIT (same as original work in this repo) — see [NOTICE.md §4](../NOTICE.md#4-committed-output-artifacts).

| File | Generator | Description |
|------|-----------|-------------|
| `cfar_demo.png` | MATLAB | 4-panel CFAR dashboard |
| `cfar_ppi.png` | MATLAB | PPI radar scope |
| `cfar_results.txt` | MATLAB | Detection table |
| `iverilog_range_profile.png` | Python | Range profile plot (Verilog scenario) |
| `iverilog_cfar_demo_log.txt` | Icarus `vvp` | Full CFAR simulation log |
| `iverilog_cfar_detections.txt` | Derived | 3-target detection summary |
| `iverilog_module_tests_summary.txt` | `sim.ps1 -Radar` | 11/11 module PASS |
| `iverilog_module_tests_log.txt` | `sim.ps1 -Radar` | Raw test log |
| `iverilog_range_scope.txt` | Derived | ASCII range scope |
| `matlab_vs_verilog_comparison.txt` | Manual | Cross-tool bin/margin check |

Regenerate: `.\scripts\export_outputs.ps1` from repo root.

**Attribution snippet:**

```
Figures/logs from aeris10-plfm-cfar-demo (MIT)
https://github.com/Alp2246/aeris10-plfm-cfar-demo
```
