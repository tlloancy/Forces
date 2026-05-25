#!/usr/bin/env python3
"""Alias — délègue à extract_layout_from_board_atlas.py (diagramme FORCE-AD-13a_13)."""
import subprocess
import sys
from pathlib import Path

subprocess.run([sys.executable, str(Path(__file__).resolve().parent / "extract_layout_from_board_atlas.py")], check=True)
from __future__ import annotations

import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "data" / "sector_layout.json"
W, H = 280.0, 280.0

# Boîtes 3×3 dans l'octogone (calibrate_sector_layout / capture Unity 216).
QUAD_BOXES = {
    "Plains": (30, 48, 122, 118),
    "Ice": (158, 48, 250, 118),
    "Jungle": (30, 158, 122, 228),
    "Desert": (158, 158, 250, 228),
}
LAND_SUFFIX = ["NW", "N", "NE", "W", "C", "E", "SW", "S", "SE"]

HQ_BOXES = {
    "HQ_Green": (8, 8, 38, 38),
    "HQ_Blue": (242, 8, 272, 38),
    "HQ_Red": (8, 242, 38, 272),
    "HQ_Yellow": (242, 242, 272, 272),
}

# Positions mer — diagramme Unity (ne pas « affiner » au pic du board synthétique).
SEA_POSITIONS = {
    "Sun": (140.0, 140.0, 18),
    "Moon_N": (140.0, 106.0, 11),
    "Moon_S": (140.0, 174.0, 11),
    "Moon_W": (106.0, 140.0, 11),
    "Moon_E": (174.0, 140.0, 11),
    "Space_1": (126.0, 122.0, 8),
    "Space_2": (154.0, 122.0, 8),
    "Space_3": (154.0, 158.0, 8),
    "Space_4": (126.0, 158.0, 8),
    "Space_5": (96.0, 140.0, 8),
    "Space_6": (106.0, 110.0, 8),
    "Space_7": (174.0, 110.0, 8),
    "Space_8": (194.0, 140.0, 8),
    "Space_9": (174.0, 170.0, 8),
    "Space_10": (194.0, 170.0, 8),
    "Space_11": (106.0, 170.0, 8),
    "Space_12": (96.0, 170.0, 8),
}


def _box_center(box: tuple) -> tuple[float, float]:
    x0, y0, x1, y1 = box
    return ((x0 + x1) * 0.5, (y0 + y1) * 0.5)


def _grid_centers(box: tuple, rows: int, cols: int) -> list[tuple[float, float]]:
    x0, y0, x1, y1 = box
    out: list[tuple[float, float]] = []
    for row in range(rows):
        for col in range(cols):
            cx = x0 + (col + 0.5) * (x1 - x0) / cols
            cy = y0 + (row + 0.5) * (y1 - y0) / rows
            out.append((round(cx, 1), round(cy, 1)))
    return out


layout: dict = {}

for sid, box in HQ_BOXES.items():
    cx, cy = _box_center(box)
    layout[sid] = {"x": round(cx, 1), "y": round(cy, 1), "r": 13}

for prefix, box in QUAD_BOXES.items():
    for suffix, (x, y) in zip(LAND_SUFFIX, _grid_centers(box, 3, 3)):
        layout[f"{prefix}_{suffix}"] = {"x": x, "y": y, "r": 11}

for sid, (x, y, r) in SEA_POSITIONS.items():
    layout[sid] = {"x": x, "y": y, "r": r}

layout["_meta"] = {
    "design_width": W,
    "design_height": H,
    "source": "unity_quad_boxes + sea_diagram_fixed",
    "quad_boxes": {k: list(v) for k, v in QUAD_BOXES.items()},
}
OUT.write_text(json.dumps(layout, indent=2), encoding="utf-8")
print(f"Wrote {len(layout) - 1} sectors -> {OUT}")
