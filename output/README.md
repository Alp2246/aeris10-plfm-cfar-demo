# Committed demo outputs

Pre-generated artifacts from MATLAB, Icarus Verilog, and Python.  
**License:** MIT — see [NOTICE.md §4](../NOTICE.md#4-committed-output-artifacts).

## Verilog / Python (`output/` root)

| File | Generator |
|------|-----------|
| `iverilog_range_profile.png` | Python `plot_range_profile.py` |
| `iverilog_cfar_demo_log.txt` | Icarus `demo.ps1` |
| `iverilog_cfar_detections.txt` | Derived |
| `iverilog_module_tests_summary.txt` | `sim.ps1 -Radar` |
| `matlab_vs_verilog_comparison.txt` | Cross-check |

## MATLAB (`output/matlab/`)

| Folder | Contents |
|--------|----------|
| [`matlab/cfar/`](matlab/cfar/) | 5 panel PNGs + 4-panel + `cfar_results.txt` |
| [`matlab/gallery/`](matlab/gallery/) | FMCW, wireless, GNSS figures from sibling repos |

Legacy symlinks at root: `cfar_demo.png`, `cfar_ppi.png`, `cfar_results.txt` (same CFAR run).

Regenerate:

```powershell
.\scripts\export_outputs.ps1
.\scripts\fetch_matlab_gallery.ps1
```

Full index: [matlab/README.md](matlab/README.md)
