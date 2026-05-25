#!/usr/bin/env python3
"""sector_layout.json — positions reproduites de la capture Unity 216.

Structure :
- 4 HQs aux 4 coins
- 4 Moons au MILIEU de chaque bordure extérieure (pas autour du Sun)
- Sun au centre
- 4 îles 3×3 dans les quadrants (entre HQ et croix centrale)
- Space_1–4 autour du Sun
- Space_5–12 sur les bordures près des HQs (2 par HQ)
"""
from __future__ import annotations

import json
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "data" / "sector_layout.json"
W, H = 280.0, 280.0

# QGs aux 4 coins (taille HQ ≈ 30 px design).
HQ_POS = {
    "HQ_Green": (23.0, 23.0),
    "HQ_Blue": (257.0, 23.0),
    "HQ_Red": (23.0, 257.0),
    "HQ_Yellow": (257.0, 257.0),
}

# 4 îles 3×3 entre HQ et bras de la croix centrale.
# Quadrant utile : (46, 46) → (124, 124) pour Plains, 78 px de côté, cellule 26.
QUAD_BOXES = {
    "Plains": (46.0, 46.0, 124.0, 124.0),
    "Ice": (156.0, 46.0, 234.0, 124.0),
    "Jungle": (46.0, 156.0, 124.0, 234.0),
    "Desert": (156.0, 156.0, 234.0, 234.0),
}
LAND_SUFFIX = ["NW", "N", "NE", "W", "C", "E", "SW", "S", "SE"]

# Hub central + Moons sur bordures extérieures.
SEA_FIXED = {
    "Sun": (140.0, 140.0, 12),
    # Moons au milieu de chaque bord extérieur (Unity capture 216).
    "Moon_N": (140.0, 23.0, 11),
    "Moon_S": (140.0, 257.0, 11),
    "Moon_W": (23.0, 140.0, 11),
    "Moon_E": (257.0, 140.0, 11),
    # Space_1–4 : petits octogones autour du Sun (coins de la croix centrale).
    "Space_1": (125.0, 125.0, 6),
    "Space_2": (155.0, 125.0, 6),
    "Space_3": (155.0, 155.0, 6),
    "Space_4": (125.0, 155.0, 6),
    # Space_5/6 : près de HQ_Green (top-left corner).
    "Space_5": (23.0, 75.0, 6),   # bord gauche, sous HQ_Green
    "Space_6": (75.0, 23.0, 6),   # bord haut, à droite de HQ_Green
    # Space_7/8 : près de HQ_Blue (top-right corner).
    "Space_7": (205.0, 23.0, 6),  # bord haut, à gauche de HQ_Blue
    "Space_8": (257.0, 75.0, 6),  # bord droit, sous HQ_Blue
    # Space_9/10 : près de HQ_Yellow (bottom-right corner).
    "Space_9": (205.0, 257.0, 6), # bord bas, à gauche de HQ_Yellow
    "Space_10": (257.0, 205.0, 6),# bord droit, au-dessus de HQ_Yellow
    # Space_11/12 : près de HQ_Red (bottom-left corner).
    "Space_11": (75.0, 257.0, 6), # bord bas, à droite de HQ_Red
    "Space_12": (23.0, 205.0, 6), # bord gauche, au-dessus de HQ_Red
}


def _grid_centers(box: tuple) -> list[tuple[float, float]]:
    x0, y0, x1, y1 = box
    out: list[tuple[float, float]] = []
    for row in range(3):
        for col in range(3):
            cx = x0 + (col + 0.5) * (x1 - x0) / 3.0
            cy = y0 + (row + 0.5) * (y1 - y0) / 3.0
            out.append((round(cx, 1), round(cy, 1)))
    return out


def main() -> None:
    layout: dict = {}
    for sid, (x, y) in HQ_POS.items():
        layout[sid] = {"x": x, "y": y, "r": 14}
    for prefix, box in QUAD_BOXES.items():
        for suffix, (x, y) in zip(LAND_SUFFIX, _grid_centers(box)):
            layout[f"{prefix}_{suffix}"] = {"x": x, "y": y, "r": 11}
    for sid, (x, y, r) in SEA_FIXED.items():
        layout[sid] = {"x": x, "y": y, "r": r}
    layout["_meta"] = {
        "design_width": W,
        "design_height": H,
        "source": "unity_capture_216_with_edge_moons",
        "quad_boxes": {k: list(v) for k, v in QUAD_BOXES.items()},
        "hq_pos": {k: list(v) for k, v in HQ_POS.items()},
    }
    OUT.write_text(json.dumps(layout, indent=2), encoding="utf-8")
    print(f"Wrote {len(layout) - 1} sectors -> {OUT}")


if __name__ == "__main__":
    main()
