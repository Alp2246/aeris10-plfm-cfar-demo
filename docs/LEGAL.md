# Legal notice — AERIS-10 CFAR verification demo

**Last updated:** June 2026  
**Repository:** [Alp2246/aeris10-plfm-cfar-demo](https://github.com/Alp2246/aeris10-plfm-cfar-demo)  
**Owner:** Alperen Bugra Ozer ([@Alp2246](https://github.com/Alp2246))

---

## English

### 1. Purpose & disclaimer

This repository provides **educational verification demos** (Verilog testbench, Icarus simulation, MATLAB figures) for the CA-CFAR stage of the open-source AERIS-10 PLFM radar. It is **not** a certified radar product, export-controlled system, or substitute for calibrated field measurements. Do not use simulation outputs alone for safety-critical, defence, or air-traffic applications.

### 2. Two licences in one repository

| Material | Licence | Who owns it |
|----------|---------|-------------|
| `hdl/`, `matlab/`, `iverilog_demo/` scripts, `scripts/`, `docs/`, committed `output/` from this repo | **MIT** | Alperen Bugra Ozer |
| `third_party/cfar_ca.v` | **CERN-OHL-P v2** | AERIS-10 / PLFM_RADAR upstream |
| `output/matlab/gallery/*.png` | **MIT** (sibling repos) | Alp2246 — fetched for portfolio index |
| Full AERIS-10 schematics, PCBs, firmware tree | **CERN-OHL-P** | Not included — clone [PLFM_RADAR](https://github.com/NawfalMotii79/PLFM_RADAR) |

**You may not** imply that CERN, the AERIS-10 team, or MathWorks endorses this portfolio repo unless they say so explicitly.

### 3. MIT — what you can do

Under [LICENSE](../LICENSE) you may use, copy, modify, merge, publish, distribute, sublicense, and sell **original work in this repo**, provided you include the MIT copyright notice.

**Suggested figure caption (thesis / report):**

> Figure: AERIS-10 CA-CFAR detection demo. Verilog testbench and MATLAB visualization by A. B. Ozer (2026). MIT License. https://github.com/Alp2246/aeris10-plfm-cfar-demo

### 4. CERN-OHL-P — obligations for `cfar_ca.v`

When you **redistribute or modify** `third_party/cfar_ca.v`:

1. Keep [CERN-OHL-P-NOTICE.txt](../third_party/CERN-OHL-P-NOTICE.txt) and the [full licence text](https://ohwr.org/cern_ohl_p_v2.txt).
2. **Document modifications** (changelog or header comment).
3. **Preserve notices** in source files you received.
4. Do **not** remove copyright or licence statements from upstream.

Read the complete CERN-OHL-P text — the summary above is not legal advice.

### 5. Thesis, YÖK, and academic use (Turkey)

For **graduate / undergraduate reports** submitted to Turkish universities (YÖK framework):

- **Your contribution** (testbench, simulation harness, MATLAB scripts, written analysis): cite this repo + MIT licence.
- **Upstream FPGA IP**: cite PLFM_RADAR + CERN-OHL-P; state that `cfar_ca.v` is third-party open hardware.
- **Gallery figures** from FMCW/wireless/GNSS repos: cite each source repo (links in [OUTPUT_CATALOG.md](OUTPUT_CATALOG.md)).
- **Do not** present upstream AERIS-10 hardware photos or diagrams as your own design — link to PLFM_RADAR with attribution.

Example bibliography entry (IEEE style):

```
A. B. Ozer, "AERIS-10 PLFM radar CA-CFAR verification demo," GitHub, 2026. [Online].
Available: https://github.com/Alp2246/aeris10-plfm-cfar-demo
```

```
N. Motii et al., "AERIS-10: Open source PLFM phased array radar," GitHub, 2024. [Online].
Available: https://github.com/NawfalMotii79/PLFM_RADAR
```

### 6. Trademarks

AERIS-10, Xilinx, MATLAB, MathWorks, STM32, and other names are trademarks of their respective owners. This demo is a **community verification project**, not an official AERIS-10 release.

### 7. Third-party tools

| Tool | Your obligation |
|------|-----------------|
| MATLAB | Valid MathWorks licence to run `.m` files |
| Icarus Verilog / GTKWave | GPL — comply if you distribute modified toolchain |
| GitHub-hosted gallery PNGs | MIT — keep attribution when reusing figures |

### 8. Privacy & secrets

Do not commit API keys, student licence files, or personal data. `.gitignore` excludes simulation waveforms (`*.vcd`, `*.vvp`).

### 9. Contact

IP or licence questions: open a GitHub issue on this repository.

---

## Türkçe

### 1. Amaç ve sorumluluk reddi

Bu depo, açık kaynak **AERIS-10 PLFM** radarının CA-CFAR aşaması için **eğitim ve doğrulama** amaçlı Verilog testbench, Icarus simülasyonu ve MATLAB görselleri sunar. Gerçek saha ölçümünün veya sertifikalı radar ürününün yerini tutmaz. Savunma, hava trafiği veya can güvenliği kritik uygulamalarda yalnızca simülasyon çıktısına güvenmeyin.

### 2. İki lisans

| İçerik | Lisans | Sahip |
|--------|--------|-------|
| `hdl/`, `matlab/`, scriptler, `docs/`, bu repodan üretilen `output/` | **MIT** | Alperen Bugra Ozer |
| `third_party/cfar_ca.v` | **CERN-OHL-P** | PLFM_RADAR / AERIS-10 |
| `output/matlab/gallery/` görselleri | **MIT** | Kardeş repolar (Alp2246) |
| Tam donanım (şema, PCB, firmware) | **CERN-OHL-P** | Bu repoda yok — upstream klonlayın |

### 3. Tez / bitirme projesi / YÖK

- **Kendi katkınız** (testbench, simülasyon, MATLAB, rapor metni): bu repoyu ve MIT lisansını belirtin.
- **cfar_ca.v**: üçüncü taraf açık donanım; PLFM_RADAR + CERN-OHL-P atıfı zorunlu.
- **Galeri görselleri**: her biri için kaynak repo linki ([OUTPUT_CATALOG.md](OUTPUT_CATALOG.md)).
- AERIS-10 sistem fotoğraflarını **kendi tasarımınız gibi** sunmayın; upstream link verin.

**Örnek şekil alt yazısı:**

> Şekil: AERIS-10 CA-CFAR tespit demosu. Verilog testbench ve MATLAB görselleştirme: A. B. Ozer (2026). MIT Lisansı.

### 4. CERN-OHL-P yükümlülükleri (özet)

`cfar_ca.v` dosyasını dağıtırken veya değiştirirken: lisans metnini koruyun, değişiklikleri belgeleyin, upstream telif bildirimlerini silmeyin. Tam metin: [ohwr.org/cern_ohl_p_v2.txt](https://ohwr.org/cern_ohl_p_v2.txt)

### 5. İletişim

Lisans soruları için GitHub issue açın.

---

## Document index

| File | Role |
|------|------|
| [LICENSE](../LICENSE) | Full MIT text |
| [NOTICE.md](../NOTICE.md) | File-by-file licence map |
| [CREDITS.md](../CREDITS.md) | Author & upstream credits |
| [CITATION.cff](../CITATION.cff) | Machine-readable metadata |
| [third_party/CERN-OHL-P-NOTICE.txt](../third_party/CERN-OHL-P-NOTICE.txt) | Hardware redistribution notice |
