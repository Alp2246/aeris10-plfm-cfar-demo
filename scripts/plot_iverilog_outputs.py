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

# VCD symbol IDs at radar_demo_tb top scope (from iverilog dump)
SIG = {
    "det_flag": "%",
    "cfar_busy": ")",
    "det_valid": "!",
    "det_range": "#",
    "det_mag": "$",
    "det_thr": '"',
    "clk": "2",
}


def parse_vcd_signals(path: Path, end_time: int = 110_000_000) -> dict:
    """Lightweight VCD parser for selected radar_demo_tb signals."""
    state: dict[str, int | str] = {k: 0 for k in SIG}
    series: dict[str, list[tuple[int, float]]] = {k: [] for k in SIG}

    def sample(t: int) -> None:
        if t > end_time:
            return
        for name in SIG:
            v = state[name]
            if isinstance(v, str):
                try:
                    v = int(v, 2)
                except ValueError:
                    v = 0
            series[name].append((t, float(v)))

    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith("#"):
                t = int(line[1:])
                sample(t)
                continue
            if line[0] in "01":
                sid = line[1:]
                if sid in SIG.values():
                    for name, sym in SIG.items():
                        if sym == sid:
                            state[name] = int(line[0])
                            break
            elif line[0] == "b":
                parts = line[1:].split()
                if len(parts) == 2:
                    val, sid = parts[0], parts[1]
                    for name, sym in SIG.items():
                        if sym == sid:
                            state[name] = val
                            break
    return series


def parse_log_range_profile(path: Path) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, list[int]]:
    """Parse ASCII range table from iverilog demo log."""
    bins, mag, thr, det = [], [], [], []
    pat = re.compile(
        r"^\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([.*])\s*\|"
    )
    text = path.read_text(encoding="utf-8", errors="ignore")
    for line in text.splitlines():
        # strip ANSI
        line = re.sub(r"\x1b\[[0-9;]*m", "", line)
        m = pat.match(line)
        if m:
            b, _, mval, tval, d = m.groups()
            bins.append(int(b))
            mag.append(int(mval))
            thr.append(int(tval))
            det.append(b if d == "*" else -1)
    det_bins = [b for b in det if b >= 0]
    return (
        np.array(bins),
        np.array(mag, dtype=float),
        np.array(thr, dtype=float),
        np.array([1 if b in det_bins else 0 for b in bins]),
        det_bins,
    )


def plot_waveforms(series: dict) -> Path:
    """GTKWave-style detection waveform (CFAR phase zoom)."""
    t = np.array([p[0] for p in series["cfar_busy"]]) / 1000.0  # ns -> us scale label
    busy = np.array([p[1] for p in series["cfar_busy"]])
    flag = np.array([p[1] for p in series["det_flag"]])
    valid = np.array([p[1] for p in series["det_valid"]])
    rng = np.array([p[1] for p in series["det_range"]])

    # Zoom to CFAR active region
    mask = (t >= 15) & (t <= 35)
    t, busy, flag, valid, rng = t[mask], busy[mask], flag[mask], valid[mask], rng[mask]

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

    style_ax(axes[0], "cfar_busy", "busy")
    axes[0].fill_between(t, 0, busy, color="#4af", alpha=0.5, step="post")
    axes[0].plot(t, busy, color="#6cf", drawstyle="steps-post", linewidth=1)

    style_ax(axes[1], "det_valid", "valid")
    axes[1].plot(t, valid, color="#fa0", drawstyle="steps-post", linewidth=1.2)

    style_ax(axes[2], "det_flag (detection pulse)", "flag")
    axes[2].fill_between(t, 0, flag, color="#f44", alpha=0.6, step="post")
    axes[2].plot(t, flag, color="#f66", drawstyle="steps-post", linewidth=1.5)

    style_ax(axes[3], "det_range[5:0] when valid", "bin")
    axes[3].plot(t, rng, color="#5f5", drawstyle="steps-post", linewidth=1.2)
    axes[3].set_xlabel("Time (µs from VCD timescale)", color="#aaa")

    out = OUT / "01_cfar_waveforms.png"
    fig.tight_layout()
    fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    return out


def plot_range_from_log(bins, mag, thr, det_bins) -> Path:
    """Range profile with real Verilog magnitudes + thresholds from sim log."""
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
    """ASCII scope as graphic — 64 bins, targets marked."""
    fig, ax = plt.subplots(figsize=(14, 2.2), facecolor="#0a120a")
    ax.set_facecolor("#0a120a")
    x = np.arange(64)
    y = np.zeros(64)
    colors = ["#2a4a2a"] * 64
    for b in det_bins:
        colors[b] = "#ff3333" if b == 45 else "#ff9933" if b == 8 else "#ffcc00"
        y[b] = 1

    ax.bar(x, y, color=colors, width=0.85, edgecolor="#1a3a1a")
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
    """Terminal-style PNG from key sim lines."""
    raw = path.read_text(encoding="utf-8", errors="ignore")
    raw = re.sub(r"\x1b\[[0-9;]*m", "", raw)
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
            )
        ):
            keep.append(line.strip()[:100])
    if not keep:
        keep = ["(no log lines — run demo.ps1 first)"]

    fig, ax = plt.subplots(figsize=(12, 6), facecolor="#0c0c0c")
    ax.set_facecolor("#0c0c0c")
    ax.axis("off")
    ax.text(
        0.02,
        0.98,
        "Icarus Verilog + vvp — CFAR demo console",
        transform=ax.transAxes,
        color="#0ff",
        fontsize=13,
        fontweight="bold",
        va="top",
        family="monospace",
    )
    body = "\n".join(keep[:18])
    ax.text(
        0.02,
        0.88,
        body,
        transform=ax.transAxes,
        color="#cfc",
        fontsize=9.5,
        va="top",
        family="Consolas",
        linespacing=1.45,
    )
    ax.add_patch(
        mpatches.FancyBboxPatch(
            (0.01, 0.02),
            0.98,
            0.96,
            boxstyle="round,pad=0.01",
            linewidth=1,
            edgecolor="#333",
            facecolor="none",
        )
    )

    out = OUT / "04_console_pass.png"
    fig.savefig(out, dpi=150, facecolor=fig.get_facecolor(), bbox_inches="tight")
    plt.close(fig)
    return out


def plot_detection_timeline(series: dict) -> Path:
    """Scatter: detection time vs range bin."""
    times, bins, mags = [], [], []
    t_prev, rng_prev, mag_prev, flag_prev = 0, 0, 0, 0
    for i in range(len(series["det_flag"])):
        t = series["det_flag"][i][0] / 1000.0
        flag = series["det_flag"][i][1]
        if flag == 1 and flag_prev == 0:
            times.append(t)
            bins.append(series["det_range"][i][1])
            mags.append(series["det_mag"][i][1])
        flag_prev = flag
        t_prev = t

    fig, ax = plt.subplots(figsize=(10, 5), facecolor="#101018")
    ax.set_facecolor("#101018")
    if times:
        sc = ax.scatter(
            times,
            bins,
            c=mags,
            s=[80 + m / 400 for m in mags],
            cmap="hot",
            edgecolors="white",
            linewidths=1,
        )
        plt.colorbar(sc, ax=ax, label="det_mag")
        for t, b, m in zip(times, bins, mags):
            ax.annotate(
                f"{int(b)*24}m",
                (t, b),
                textcoords="offset points",
                xytext=(6, 6),
                color="#ff9",
                fontsize=9,
            )
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
    if not LOG.exists():
        raise SystemExit(f"Missing {LOG} — run demo.ps1 first")

    print("Parsing VCD...")
    series = parse_vcd_signals(VCD)
    print("Parsing log...")
    bins, mag, thr, _, det_bins = parse_log_range_profile(LOG)

    outputs = [
        plot_waveforms(series),
        plot_range_from_log(bins, mag, thr, det_bins),
        plot_radar_scope(det_bins),
        plot_console_summary(LOG),
        plot_detection_timeline(series),
    ]

    # Legacy path + README index
    legacy = REPO / "output" / "iverilog_range_profile.png"
    import shutil

    shutil.copy2(outputs[1], legacy)

    for p in outputs:
        print(f"Wrote {p}")
    print(f"Legacy copy: {legacy}")


if __name__ == "__main__":
    main()
