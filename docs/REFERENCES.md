# References & further reading

## Open-source platform

| Resource | URL |
|----------|-----|
| AERIS-10 / PLFM_RADAR (hardware + firmware) | https://github.com/NawfalMotii79/PLFM_RADAR |
| This verification demo | https://github.com/Alp2246/aeris10-plfm-cfar-demo |
| FMCW / ISAC MATLAB demos | https://github.com/Alp2246/matlab-fmcw-isac-examples |
| Wireless comm MATLAB demos | https://github.com/Alp2246/matlab-wireless-comm-examples |
| GNSS spoofing research demos | https://github.com/Alp2246/gnss-spoofing-research |

## CFAR detection

- Richards, M. A. *Fundamentals of Radar Signal Processing* — CA-CFAR, guard/training cells.
- Rohling, H. "Radar CFAR thresholding in clutter and multiple target situations" — classic CFAR survey context.

## Pulse-LFM / chirp radar

- Skolnik, M. I. *Radar Handbook* — LFM waveform and pulse compression.
- AERIS-10 implements matched-filter pulse compression on FPGA before Doppler / CFAR (see upstream `README`).

## Simulation tools

| Tool | Link |
|------|------|
| Icarus Verilog | https://steveicarus.github.io/iverilog/ |
| GTKWave | http://gtkwave.sourceforge.net/ |

## Licences

| Licence | Text |
|---------|------|
| MIT | [LICENSE](../LICENSE) |
| CERN-OHL-P v2 | https://ohwr.org/cern_ohl_p_v2.txt |

## Citation (this repo)

```bibtex
@software{ozer_aeris10_cfar_demo_2026,
  author  = {Ozer, Alperen Bugra},
  title   = {AERIS-10 PLFM Radar CA-CFAR Verification Demo},
  year    = {2026},
  url     = {https://github.com/Alp2246/aeris10-plfm-cfar-demo},
  license = {MIT}
}
```
