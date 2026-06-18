#!/usr/bin/env python3
"""Generate iverilog-style range profile PNG (MIT). Same scenario as radar_demo_tb.v."""

from pathlib import Path
import struct

try:
    import matplotlib.pyplot as plt
    import numpy as np
except ImportError:
    raise SystemExit("matplotlib and numpy required: pip install matplotlib numpy")

NUM_BINS = 64
# LFSR seed 0xA5A51234 — match Verilog testbench noise
state = 0xA5A51234
mag = []
for _ in range(NUM_BINS):
    state = ((state << 1) ^ (0x80200003 if state & 0x80000000 else 0)) & 0xFFFFFFFF
    mag.append(int(2000 + (state & 0xFFFF) % 1500))
mag[8] = 30000
mag[22] = 20000
mag[45] = 50000

bins = np.arange(NUM_BINS)
range_m = bins * 24
detect = {8, 22, 45}

fig, ax = plt.subplots(figsize=(12, 4), facecolor="#0a0a10")
ax.set_facecolor("#0a0a10")
colors = ["#ff4444" if b in detect else "#4a7099" for b in bins]
ax.bar(bins, mag, color=colors, width=0.85, edgecolor="none")
ax.set_xlabel("Range bin", color="white")
ax.set_ylabel("Magnitude", color="white")
ax.set_title("AERIS-10 Range Profile — Icarus Verilog scenario (Doppler bin 0)", color="white")
ax.tick_params(colors="white")
for spine in ax.spines.values():
    spine.set_color("#444")
ax.grid(True, alpha=0.2, color="#666")

out = Path(__file__).resolve().parent.parent / "output" / "iverilog_range_profile.png"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
print(f"Wrote {out}")
