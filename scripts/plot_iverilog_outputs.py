#!/usr/bin/env python3
"""
Export Icarus Verilog simulation figures from radar_demo.vcd + demo log.
MIT — Alp2246 / aeris10-plfm-cfar-demo
"""

from __future__ import annotations

import re
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

REPO = Path(__file__).resolve().parent.parent
VCD = REPO / "iverilog_demo" / "radar_demo.vcd"
LOG = REPO / "output" / "iverilog_cfar_demo_log.txt"
OUT = REPO / "output" / "iverilog"
OUT.mkdir(parents=True, exist_ok=True)

# radar_demo_tb top-level VCD symbol IDs (iverilog dump)
SIG = {
    "det_flag": "%",
    "cfar_busy": ")",
    "det_valid": "!",
    "det_range": "#",
    "det_mag": "$",
    "det_thr": '"',
}


def _apply_line(state: dict, line: str) -> None:
    line = line.strip()
    if not line or line.startswith("$"):
        return
    if line[0] in "01":
        sid = line[1:]
        val = int(line[0])
    elif line[0] == "b":
        parts = line[1:].split()
        if len(parts) != 2:
            return
        val, sid = parts[0], parts[1]
    elif line[0] in "r":
        return
    else:
        return
    for name, sym in SIG.items():
        if sym == sid:
            state[name] = int(val, 2) if isinstance(val, str) else val
            break


def parse_vcd_signals(path: Path) -> dict:
    """
    VCD rule: '#' timestamp applies to value changes listed AFTER it.
    """
    state: dict[str, int] = {k: 0 for k in SIG}
    series: dict[str, list[tuple[int, float]]] = {k: [] for k in SIG}
    current_time = 0

    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            if line.startswith("#"):
                current_time = int(line[1:])
                continue
            _apply_line(state, line)
            for name in SIG:
                series[name].append((current_time, float(state[name])))

    return series


def strip_ansi(text: str) -> str:
    return re.sub(r"\x1b\[[0-9;]*m", "", text)


def parse_log_range_profile(path: Path) -> tuple[np.ndarray, np.ndarray, np.ndarray, list[int]]:
    if not path.exists() or path.stat().st_size == 0:
        raise ValueError(f"Log empty or missing: {path}")

    text = strip_ansi(path.read_text(encoding="utf-8", errors="ignore"))
    bins, mag, thr, det_bins = [], [], [], []
    pat = re.compile(
        r"^\s*(\d+)\s*\|\s*\d+\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([.*])\s*\|"
    )
    for line in text.splitlines():
        m = pat.match(line)
        if m:
            b, mval, tval, d = m.groups()
            b = int(b)
            bins.append(b)
            mag.append(int(mval))
            thr.append(int(tval))
            if d == "*":
                det_bins.append(b)

    if not bins:
        raise ValueError("No range rows parsed from log — re-run demo.ps1 -NoWave")

    return np.array(bins), np.array(mag, dtype=float), np.array(thr, dtype=float), det_bins


def plot_waveforms(series: dict) -> Path:
    """CFAR phase — time in microseconds (VCD timescale = 1 ps)."""
    def to_us(key: str) -> tuple[np.ndarray, np.ndarray]:
        t = np.array([p[0] for p in series[key]], dtype=float) / 1e6
        v = np.array([p[1] for p in series[key]], dtype=float)
        return t, v

    t_busy, busy = to_us("cfar_busy")
    t_flag, flag = to_us("det_flag")
    t_valid, valid = to_us("det_valid")
    t_rng, rng = to_us("det_range")

    # CFAR activity ~20–23 µs (detections at 21–22 µs)
    tmin, tmax = 19.5, 23.5

    fig, axes = plt.subplots(4, 1, figsize=(14, 8), sharex=True, facecolor="#1a1a22")
    fig.suptitle(
        "Icarus Verilog — CFAR waveforms (radar_demo.vcd)",
        color="white",
        fontsize=14,
        fontweight="bold",
    )

    def style_ax(ax, title, ylabel):
        ax.set_facecolor("#12121a")
        ax.set_title(title, color="#8cf", fontsize=11, loc="left")
        ax.set_ylabel(ylabel, color="#aaa")
        ax.tick_params(colors="#888")
        for sp in ax.spines.values():
            sp.set_color("#444")
        ax.grid(True, alpha=0.2, color="#555")
        ax.set_xlim(tmin, tmax)

    style_ax(axes[0], "cfar_busy", "busy")
    axes[0].plot(t_busy, busy, color="#6cf", drawstyle="steps-post", linewidth=1.5)
    axes[0].fill_between(t_busy, 0, busy, color="#4af", alpha=0.35, step="post")

    style_ax(axes[1], "det_valid", "valid")
    axes[1].plot(t_valid, valid, color="#fa0", drawstyle="steps-post", linewidth=1.2)

    style_ax(axes[2], "det_flag (detection pulse)", "flag")
    axes[2].plot(t_flag, flag, color="#f66", drawstyle="steps-post", linewidth=2)
    axes[2].fill_between(t_flag, 0, flag, color="#f44", alpha=0.5, step="post")

    style_ax(axes[3], "det_range[5:0] when valid", "bin")
    axes[3].plot(t_rng, rng, color="#5f5", drawstyle="steps-post", linewidth=1.5)
    axes[3].set_xlabel("Time (µs)  [VCD timescale 1 ps]", color="#aaa")

    out = OUT / "01_cfar_waveforms.png"
    fig.tight_layout()
    fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    return out


def plot_range_from_log(bins, mag, thr, det_bins) -> Path:
    range_m = bins * 24
    colors = ["#ff4444" if b in det_bins else "#4a7099" for b in bins]

    fig, ax = plt.subplots(figsize=(13, 4.5), facecolor="#0a0a10")
    ax.set_facecolor("#0a0a10")
    ax.bar(range_m, mag, width=18, color=colors, edgecolor="none", label="Magnitude")
    ax.plot(range_m, thr, color="#ffd700", linewidth=2, label="CFAR threshold")
    for b in det_bins:
        ax.annotate(
            f"bin {b}\n{b*24} m",
            (b * 24, mag[b]),
            textcoords="offset points",
            xytext=(0, 12),
            ha="center",
            color="#ff6",
            fontsize=9,
            fontweight="bold",
        )
    ax.set_xlabel("Range (m)", color="white")
    ax.set_ylabel("Magnitude", color="white")
    ax.set_title(
        "Icarus Verilog — Range profile + CFAR (from simulation log)",
        color="white",
        fontweight="bold",
    )
    ax.tick_params(colors="white")
    ax.legend(facecolor="#222", edgecolor="#444", labelcolor="white")
    for sp in ax.spines.values():
        sp.set_color("#444")
    ax.grid(True, alpha=0.2, color="#666")

    out = OUT / "02_range_profile_log.png"
    fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    return out


def plot_radar_scope(det_bins: list[int]) -> Path:
    fig, ax = plt.subplots(figsize=(14, 2.2), facecolor="#0a120a")
    ax.set_facecolor("#0a120a")
    colors = ["#2a4a2a"] * 64
    for b in det_bins:
        colors[b] = "#ff3333" if b == 45 else "#ff9933" if b == 8 else "#ffcc00"
    ax.bar(range(64), [1 if c != "#2a4a2a" else 0.15 for c in colors], color=colors, width=0.85)
    ax.set_xlim(-0.5, 63.5)
    ax.set_ylim(0, 1.35)
    ax.set_xlabel("Range bin (×24 m)", color="#6c6")
    ax.set_yticks([])
    for tick in range(0, 64, 8):
        ax.text(tick, -0.15, f"{tick*24}m", ha="center", color="#5a5", fontsize=8)
    for b in det_bins:
        ax.text(b, 1.08, "*", ha="center", color="#ff6", fontsize=16, fontweight="bold")
    ax.set_title(
        "Icarus Verilog — Radar scope (3 detections @ bins 8, 22, 45)",
        color="#6f6",
        fontweight="bold",
    )
    for sp in ax.spines.values():
        sp.set_color("#2a4a2a")

    out = OUT / "03_radar_scope.png"
    fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    return out


def plot_console_summary(path: Path) -> Path:
    raw = strip_ansi(path.read_text(encoding="utf-8", errors="ignore"))
    keep = []
    for line in raw.splitlines():
        if any(
            k in line
            for k in (
                "DETECTION",
                "PASS",
                "CFAR DEMO",
                "Author",
                "Ground truth",
                "Frame complete",
                "SONUC",
                "TARGET",
            )
        ):
            keep.append(line.strip()[:110])
    if not keep:
        keep = ["(log empty — run: cd iverilog_demo && .\\demo.ps1 -NoWave)"]

    fig, ax = plt.subplots(figsize=(12, 6), facecolor="#0c0c0c")
    ax.set_facecolor("#0c0c0c")
    ax.axis("off")
    ax.text(
        0.02, 0.98, "Icarus Verilog + vvp — CFAR demo console",
        transform=ax.transAxes, color="#0ff", fontsize=13, fontweight="bold",
        va="top", family="monospace",
    )
    ax.text(
        0.02, 0.88, "\n".join(keep[:20]),
        transform=ax.transAxes, color="#cfc", fontsize=9,
        va="top", family="Consolas", linespacing=1.45,
    )
    ax.add_patch(mpatches.FancyBboxPatch(
        (0.01, 0.02), 0.98, 0.96, boxstyle="round,pad=0.01",
        linewidth=1, edgecolor="#333", facecolor="none",
    ))

    out = OUT / "04_console_pass.png"
    fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    return out


def plot_detection_timeline(series: dict) -> Path:
    events = []
    prev_flag = 0.0
    for i, (t_ps, flag) in enumerate(series["det_flag"]):
        if flag == 1 and prev_flag == 0:
            t_us = t_ps / 1e6
            rng = series["det_range"][i][1] if i < len(series["det_range"]) else 0
            mag = series["det_mag"][i][1] if i < len(series["det_mag"]) else 0
            events.append((t_us, rng, mag))
        prev_flag = flag

    fig, ax = plt.subplots(figsize=(10, 5), facecolor="#101018")
    ax.set_facecolor("#101018")
    if events:
        times, bins, mags = zip(*events)
        sc = ax.scatter(times, bins, c=mags, s=[80 + m / 400 for m in mags],
                        cmap="hot", edgecolors="white", linewidths=1)
        plt.colorbar(sc, ax=ax, label="det_mag")
        for t, b, m in zip(times, bins, mags):
            ax.annotate(f"{int(b)*24}m", (t, b), textcoords="offset points",
                        xytext=(6, 6), color="#ff9", fontsize=9)
    ax.set_xlabel("Time (µs)", color="#ccc")
    ax.set_ylabel("Range bin", color="#ccc")
    ax.set_title("Icarus Verilog — Detection events (VCD)", color="white", fontweight="bold")
    ax.tick_params(colors="#aaa")
    for sp in ax.spines.values():
        sp.set_color("#444")
    ax.grid(True, alpha=0.25, color="#555")

    out = OUT / "05_detection_timeline.png"
    fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    return out


def main() -> None:
    if not VCD.exists():
        raise SystemExit(f"Missing {VCD} — run: cd iverilog_demo && .\\demo.ps1 -NoWave")

    print("Parsing VCD...")
    series = parse_vcd_signals(VCD)
    print(f"  det_flag pulses: {int(sum(1 for _, v in series['det_flag'] if v == 1))}")

    print("Parsing log...")
    bins, mag, thr, det_bins = parse_log_range_profile(LOG)
    print(f"  range rows: {len(bins)}, detections: {det_bins}")

    outputs = [
        plot_waveforms(series),
        plot_range_from_log(bins, mag, thr, det_bins),
        plot_radar_scope(det_bins),
        plot_console_summary(LOG),
        plot_detection_timeline(series),
    ]

    import shutil
    legacy = REPO / "output" / "iverilog_range_profile.png"
    shutil.copy2(outputs[1], legacy)

    for p in outputs:
        print(f"Wrote {p}")
    print(f"Legacy copy: {legacy}")


if __name__ == "__main__":
    main()
