import os
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

from cachesim import load_trace, run

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SIZE, LINE, WAYS, POLICY = 128, 16, 2, "wt"
INK, MUTED, SERIES, SURFACE = "#0b0b0b", "#52514e", "#2a78d6", "#fcfcfb"


def sweep(trace):
    mapping = []
    for name, w in (("Direct", 1), ("2-way", 2), ("4-way", 4), ("Fully assoc.", 0)):
        c = run(trace, SIZE, LINE, w, POLICY)[0]
        mapping.append((name, c.hits, c.misses, c.ratio))
    lines = []
    for ln in (8, 16, 32, 64):
        c = run(trace, SIZE, ln, WAYS, POLICY)[0]
        lines.append((f"{ln} B", c.hits, c.misses, c.ratio))
    return mapping, lines


def panel(ax, rows, title, own):
    labels = [r[0] for r in rows]
    h = [r[3] for r in rows]
    x = range(len(labels))
    ax.plot(x, h, color=SERIES, linewidth=2, marker="o", markersize=8,
            markeredgecolor=SURFACE, markeredgewidth=2, zorder=3)
    ax.set_xticks(list(x), labels)
    for i, v in enumerate(h):
        txt = f"{v:.4f}" + (" (kişiye özel)" if i == own else "")
        ax.annotate(txt, (i, v), xytext=(0, -16 if v > 0.95 else 10), textcoords="offset points",
                    ha="center", fontsize=9, color=INK)
    ax.set_xlim(-0.4, len(labels) - 0.6)
    ax.set_ylim(0.78, 1.0)
    ax.set_title(title, fontsize=11, color=INK, loc="left")
    ax.set_ylabel("Hit ratio H", color=MUTED)
    ax.grid(axis="y", color="#e4e3df", linewidth=0.8)
    ax.set_axisbelow(True)
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    for s in ("left", "bottom"):
        ax.spines[s].set_color(MUTED)
    ax.tick_params(colors=MUTED)


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "build", "trace_O0.csv")
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.join(ROOT, "screenshots", "m4_design_space.png")
    trace = load_trace(path)
    mapping, lines = sweep(trace)
    for name, rows in (("Mapping (line = 16 B)", mapping), ("Line boyu (2-way)", lines)):
        print(name)
        for r in rows:
            print(f"  {r[0]:13} hit={r[1]} miss={r[2]} H={r[3]:.4f}")
    fig, axes = plt.subplots(1, 2, figsize=(10, 4), facecolor=SURFACE)
    for ax in axes:
        ax.set_facecolor(SURFACE)
    panel(axes[0], mapping, "Mapping serisi (128 B, line 16 B)", 1)
    panel(axes[1], lines, "Line boyu serisi (128 B, 2-way)", 1)
    fig.suptitle(f"-O0 data izi, {len(trace)} referans, LRU, write-through", fontsize=10, color=MUTED, x=0.01, ha="left")
    fig.tight_layout()
    fig.savefig(out, dpi=150, facecolor=SURFACE)
    print("saved", out)


if __name__ == "__main__":
    main()
