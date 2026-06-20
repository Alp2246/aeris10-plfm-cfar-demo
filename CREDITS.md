# Credits & attribution

## Author

**Alperen Bugra Ozer** — [GitHub @Alp2246](https://github.com/Alp2246)

| Contribution | Location |
|--------------|----------|
| Verilog system testbench (CFAR demo) | [`hdl/radar_demo_tb.v`](hdl/radar_demo_tb.v) |
| Icarus simulation harness | [`iverilog_demo/demo.ps1`](iverilog_demo/demo.ps1), [`sim.ps1`](iverilog_demo/sim.ps1) |
| MATLAB twin demo + figures | [`matlab/radar_cfar_demo.m`](matlab/radar_cfar_demo.m) |
| Documentation & walkthrough | [`docs/VERILOG_WALKTHROUGH.md`](docs/VERILOG_WALKTHROUGH.md) |
| Committed run outputs | [`output/`](output/) |

---

## Upstream — AERIS-10 / PLFM_RADAR

| Component | Credit |
|-----------|--------|
| `cfar_ca.v` (CA-CFAR FPGA module) | [NawfalMotii79/PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) — AERIS-10 open-hardware team |
| Radar system concept & full RTL tree | Same repository — see upstream for complete design |

---

## Licenses (summary)

| Scope | License | Full text |
|-------|---------|-----------|
| Original work in this repo | **MIT** | [LICENSE](LICENSE) |
| `third_party/cfar_ca.v` | **CERN-OHL-P v2** | [ohwr.org/cern_ohl_p_v2.txt](https://ohwr.org/cern_ohl_p_v2.txt) |
| File-by-file breakdown | — | [NOTICE.md](NOTICE.md) |

**For thesis / report footnote (MIT part):**

> Ozer, A. B. (2026). *AERIS-10 PLFM Radar CFAR Verification Demo* (Verilog testbench & MATLAB). GitHub. https://github.com/Alp2246/aeris10-plfm-cfar-demo — MIT License.

**For DUT / hardware citation:**

> Nawfal Motii et al., *AERIS-10 PLFM Radar* (open-source hardware). https://github.com/NawfalMotii79/PLFM_RADAR — CERN-OHL-P.

---

## Citation file

| Machine-readable metadata | [`CITATION.cff`](CITATION.cff) (if present in repo root).

### Upstream platform (reference only — not bundled)

| Asset | Source | Licence |
|-------|--------|---------|
| System photos, block diagram, GUI GIF | [PLFM_RADAR / 8_Utils](https://github.com/NawfalMotii79/PLFM_RADAR/tree/main/8_Utils) | CERN-OHL-P |
| Full FPGA firmware tree | same repo `9_Firmware/` | CERN-OHL-P + MIT (software) per upstream |

Link to upstream images in reports; do not claim ownership. See [docs/RADAR_SYSTEM.md](docs/RADAR_SYSTEM.md).
