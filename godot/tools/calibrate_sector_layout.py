#!/usr/bin/env python3
"""Calibrate sector_layout.json from FORCE-AD-13a_13 board diagram (325×244)."""
import json
from pathlib import Path
from typing import List, Tuple

try:
    from PIL import Image
except ImportError:
    raise SystemExit("pip install Pillow")

ROOT = Path(__file__).resolve().parents[1]
ATLAS = ROOT / "assets" / "textures" / "FORCE-AD-13a.png"
OUT = ROOT / "data" / "sector_layout.json"
# Mini-plateau — export_board_image.py compose les tuiles ; fallback atlas preview.
W, H = 280.0, 280.0
BOARD_ORIGIN = (410, 50)


def _refine_peak(img, cx: float, cy: float, radius: int = 10, inner_margin: int = 0) -> Tuple[float, float]:
    px = img.load()
    best = (cx, cy)
    best_l = -1
    x0 = max(inner_margin, int(cx - radius))
    x1 = min(img.width - 1 - inner_margin, int(cx + radius))
    y0 = max(inner_margin, int(cy - radius))
    y1 = min(img.height - 1 - inner_margin, int(cy + radius))
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            r, g, b = px[x, y]
            lum = r + g + b
            if lum > best_l:
                best_l = lum
                best = (float(x), float(y))
    return best


def _center_of_bright_box(img, box: Tuple[int, int, int, int]) -> Tuple[float, float]:
    """Centre de masse des pixels clairs dans une zone (évite les bords du sprite)."""
    px = img.load()
    x0, y0, x1, y1 = box
    sx = sy = count = 0.0
    for y in range(y0, y1):
        for x in range(x0, x1):
            r, g, b = px[x, y]
            if r + g + b > 120:
                sx += x
                sy += y
                count += 1.0
    if count < 1.0:
        return ((x0 + x1) * 0.5, (y0 + y1) * 0.5)
    return (sx / count, sy / count)


def _grid_centers(img, box: tuple, rows: int, cols: int) -> List[Tuple[float, float]]:
    x0, y0, x1, y1 = box
    out: List[Tuple[float, float]] = []
    for row in range(rows):
        for col in range(cols):
            cx = x0 + (col + 0.5) * (x1 - x0) / cols
            cy = y0 + (row + 0.5) * (y1 - y0) / rows
            out.append(_refine_peak(img, cx, cy, 12))
    return out


def main() -> None:
    export_script = ROOT / "tools" / "export_board_image.py"
    if export_script.exists():
        import subprocess
        subprocess.run(["python", str(export_script)], check=True)

    board_path = ROOT / "assets" / "textures" / "board_reference.png"
    if not board_path.exists():
        raise SystemExit(f"Missing {board_path} — run export_board_image.py")
    img = Image.open(board_path).convert("RGB")
    bw, bh = img.size
    if abs(bw - W) > 2 or abs(bh - H) > 2:
        img = img.resize((int(W), int(H)), Image.LANCZOS)

    layout: dict = {}

    # Corner HQs — centre de masse dans chaque octogone QG.
    hq_boxes = {
        "HQ_Green": (8, 8, 38, 38),
        "HQ_Blue": (242, 8, 272, 38),
        "HQ_Red": (8, 242, 38, 272),
        "HQ_Yellow": (242, 242, 272, 272),
    }
    for sid, box in hq_boxes.items():
        x, y = _center_of_bright_box(img, box)
        layout[sid] = {"x": round(x, 1), "y": round(y, 1), "r": 13}

    # 3×3 land grids inside each colored octagon (bbox on reference sprite).
    quad_boxes = {
        "Plains": (30, 48, 122, 118),
        "Ice": (158, 48, 250, 118),
        "Jungle": (30, 158, 122, 228),
        "Desert": (158, 158, 250, 228),
    }
    suffixes = ["NW", "N", "NE", "W", "C", "E", "SW", "S", "SE"]
    for prefix, box in quad_boxes.items():
        centers = _grid_centers(img, box, 3, 3)
        for suffix, (x, y) in zip(suffixes, centers):
            layout[f"{prefix}_{suffix}"] = {"x": round(x, 1), "y": round(y, 1), "r": 11}

    # Center neutral / sea ring.
    center_seeds = {
        "Sun": (140, 140),
        "Moon_N": (140, 106),
        "Moon_S": (140, 174),
        "Moon_W": (106, 140),
        "Moon_E": (174, 140),
        "Space_1": (126, 122),
        "Space_2": (154, 122),
        "Space_3": (154, 158),
        "Space_4": (126, 158),
        "Space_5": (96, 140),
        "Space_6": (106, 110),
        "Space_7": (174, 110),
        "Space_8": (194, 140),
        "Space_9": (174, 170),
        "Space_10": (194, 170),
        "Space_11": (106, 170),
        "Space_12": (96, 170),
    }
    # Positions mer fixes (diagramme Unity) — ne pas affiner sur board synthétique.
    sea_fixed = {
        "Sun": (140, 140, 18),
        "Moon_N": (140, 106, 11),
        "Moon_S": (140, 174, 11),
        "Moon_W": (106, 140, 11),
        "Moon_E": (174, 140, 11),
        "Space_1": (126, 122, 8),
        "Space_2": (154, 122, 8),
        "Space_3": (154, 158, 8),
        "Space_4": (126, 158, 8),
        "Space_5": (96, 140, 8),
        "Space_6": (106, 110, 8),
        "Space_7": (174, 110, 8),
        "Space_8": (194, 140, 8),
        "Space_9": (174, 170, 8),
        "Space_10": (194, 170, 8),
        "Space_11": (106, 170, 8),
        "Space_12": (96, 170, 8),
    }
    for sid, (x, y, r) in sea_fixed.items():
        layout[sid] = {"x": float(x), "y": float(y), "r": r}

    layout["_meta"] = {
        "design_width": W,
        "design_height": H,
        "board_sprite": "board_preview",
        "board_origin_x": BOARD_ORIGIN[0],
        "board_origin_y": BOARD_ORIGIN[1],
        "source": "calibrate_sector_layout.py",
    }
    OUT.write_text(json.dumps(layout, indent=2), encoding="utf-8")
    print(f"Wrote {len(layout) - 1} sectors -> {OUT}")


if __name__ == "__main__":
    main()
