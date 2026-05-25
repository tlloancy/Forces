#!/usr/bin/env python3
"""Generate sector_layout.json — grilles 3×3 ancrées sur chaque QG (coin extérieur)."""
import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "data" / "sector_layout.json"
W, H = 280.0, 280.0

LAND_STEP = 88.0 / 3.0
# Décalage QG → première case terrain (Plains NW validé : HQ 18,18 → 28.7,28.7).
LAND_INSET = 10.67

LAND_SUFFIX = {
    "NW": (0, 0),
    "N": (1, 0),
    "NE": (2, 0),
    "W": (0, 1),
    "C": (1, 1),
    "E": (2, 1),
    "SW": (0, 2),
    "S": (1, 2),
    "SE": (2, 2),
}

HQ_POS = {
    "HQ_Green": (18.0, 18.0),
    "HQ_Blue": (262.0, 18.0),
    "HQ_Red": (18.0, 262.0),
    "HQ_Yellow": (262.0, 262.0),
}

# Case du coin extérieur de chaque quadrant + direction depuis le QG vers la grille.
QUAD_LAND = {
    "Plains": {"hq": "HQ_Green", "corner": "NW", "toward": (1.0, 1.0)},
    "Ice": {"hq": "HQ_Blue", "corner": "NE", "toward": (-1.0, 1.0)},
    "Jungle": {"hq": "HQ_Red", "corner": "SW", "toward": (1.0, -1.0)},
    "Desert": {"hq": "HQ_Yellow", "corner": "SE", "toward": (-1.0, -1.0)},
}

# Centre : Sun + Moons + couloirs mer (Space_*). Bras en croix + couloirs latéraux visibles.
CENTER = {
    "Sun": (140.0, 140.0),
    "Moon_N": (140.0, 100.0),
    "Moon_S": (140.0, 180.0),
    "Moon_W": (100.0, 140.0),
    "Moon_E": (180.0, 140.0),
    "Space_5": (74.0, 140.0),
    "Space_8": (206.0, 140.0),
    "Space_12": (74.0, 198.0),
    "Space_10": (206.0, 198.0),
    "Space_6": (108.0, 116.0),
    "Space_7": (172.0, 116.0),
    "Space_11": (108.0, 164.0),
    "Space_9": (172.0, 164.0),
    "Space_1": (140.0, 122.0),
    "Space_2": (158.0, 140.0),
    "Space_4": (140.0, 158.0),
    "Space_3": (122.0, 140.0),
}

layout: dict = {}

for sid, (x, y) in HQ_POS.items():
    layout[sid] = {"x": x, "y": y, "r": 17}

for prefix, cfg in QUAD_LAND.items():
    hq_x, hq_y = HQ_POS[cfg["hq"]]
    tx, ty = cfg["toward"]
    corner_col, corner_row = LAND_SUFFIX[cfg["corner"]]
    corner_x = hq_x + tx * LAND_INSET
    corner_y = hq_y + ty * LAND_INSET
    for suffix, (col, row) in LAND_SUFFIX.items():
        dc = col - corner_col
        dr = row - corner_row
        layout[f"{prefix}_{suffix}"] = {
            "x": round(corner_x + dc * LAND_STEP, 1),
            "y": round(corner_y + dr * LAND_STEP, 1),
            "r": 14,
        }

for sid, (x, y) in CENTER.items():
    if sid == "Sun":
        r = 18
    elif sid.startswith("Moon"):
        r = 11
    else:
        r = 8
    layout[sid] = {"x": x, "y": y, "r": r}

layout["_meta"] = {
    "design_width": W,
    "design_height": H,
    "land_step": LAND_STEP,
    "land_inset": LAND_INSET,
    "source": "generate_sector_layout.py",
    "tile_mode": "atlas_individual",
}
OUT.write_text(json.dumps(layout, indent=2), encoding="utf-8")
print(f"Wrote {len(layout) - 1} sectors -> {OUT}")
