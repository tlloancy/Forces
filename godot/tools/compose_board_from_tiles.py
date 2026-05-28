#!/usr/bin/env python3
"""Compose board_composed.png — reproduction Unity capture 216.

Étapes :
1. Fond bleu nuit + grille
2. Couloirs gris : 4 bandes extérieures (entre HQs) + croix centrale (Moons → Sun)
3. Tuiles île 3×3 par camp (atlas NW/N/NE/W/CE/E/SW/S/SE teintées)
4. HQ tiles aux 4 coins
5. Moons + Sun + Space_* (petits octogones gris)
"""
from __future__ import annotations

import json
from pathlib import Path

try:
    from PIL import Image, ImageChops, ImageDraw
except ImportError:
    raise SystemExit("pip install Pillow")

ROOT = Path(__file__).resolve().parents[1]
ATLAS = ROOT / "assets" / "textures" / "FORCE-AD-13a.png"
DATA = ROOT / "data" / "atlas_sprites.json"
LAYOUT = ROOT / "data" / "sector_layout.json"
OUT = ROOT / "assets" / "textures" / "board_composed.png"
W, H = 280, 280

# Couleurs Unity (capture 216 prélevée pixel).
BG_DARK = (43, 45, 74, 255)        # #2b2d4a — slate Unity exact
GRID_LINE = (58, 62, 90, 255)
COULOIR_GREY = (72, 76, 95, 255)
SEA_OCTAGON = (100, 105, 120, 255)
MOON_GREY = (120, 126, 142, 255)
SUN_GREY = (100, 105, 120, 255)
CAMP_TINT = {
    "Plains": (61, 158, 87),   # Green camp
    "Ice":    (64, 115, 217),  # Blue camp
    "Jungle": (209, 56, 56),   # Red camp
    "Desert": (235, 199, 46),  # Yellow camp
}

# Bandes couloir (zones grises sur les bords extérieurs entre HQs).
EDGE_BAND = 12  # demi-épaisseur de la bande couloir en design units
EDGE_INSET = 50  # marge depuis les coins HQ avant la bande

# Croix centrale (Moons → Sun).
CROSS_HALF = 12  # demi-largeur des bras de la croix


def _tint(img: Image.Image, rgb: tuple) -> Image.Image:
    """Colorie l'image avec rgb en préservant la forme mais évitant le noir total.
    Luminance remappée sur [0.55, 1.0] : les pixels sombres gardent la teinte cible."""
    base = img.convert("RGBA")
    alpha = base.split()[3]
    from PIL import ImageOps
    gray = ImageOps.grayscale(base)
    # Remap luminance → [MIN_LUM, 1.0] pour éviter que multiply → noir
    MIN_LUM = 0.55
    scaled = gray.point(lambda p: int(255 * (MIN_LUM + (1.0 - MIN_LUM) * p / 255)))
    color_fill = Image.new("RGBA", base.size, rgb + (255,))
    lum_rgba = scaled.convert("RGBA")
    out = ImageChops.multiply(color_fill, lum_rgba)
    out.putalpha(alpha)
    return out


def _sprite(atlas: Image.Image, sprites: dict, sprite_id: str) -> Image.Image | None:
    if sprite_id not in sprites:
        return None
    r = sprites[sprite_id]
    return atlas.crop((r["x"], r["y"], r["x"] + r["w"], r["y"] + r["h"]))


def _paste_at(board: Image.Image, tile: Image.Image, cx: float, cy: float, w: int, h: int) -> None:
    tile = tile.resize((w, h), Image.LANCZOS)
    x0 = int(round(cx - w / 2))
    y0 = int(round(cy - h / 2))
    board.paste(tile, (x0, y0), tile if tile.mode == "RGBA" else None)


def _draw_edge_couloirs(draw: ImageDraw.ImageDraw) -> None:
    """4 bandes grises sur les bords extérieurs entre les HQs."""
    a = EDGE_INSET
    b = W - EDGE_INSET
    e = EDGE_BAND
    # Top edge
    draw.rectangle((a, 23 - e, b, 23 + e), fill=COULOIR_GREY)
    # Bottom edge
    draw.rectangle((a, 257 - e, b, 257 + e), fill=COULOIR_GREY)
    # Left edge
    draw.rectangle((23 - e, a, 23 + e, b), fill=COULOIR_GREY)
    # Right edge
    draw.rectangle((257 - e, a, 257 + e, b), fill=COULOIR_GREY)


def _draw_central_cross(draw: ImageDraw.ImageDraw) -> None:
    """Croix centrale : Moon_W → Sun → Moon_E (horiz) + Moon_N → Sun → Moon_S (vert)."""
    c = CROSS_HALF
    # Horizontal arm
    draw.rectangle((23, 140 - c, 257, 140 + c), fill=COULOIR_GREY)
    # Vertical arm
    draw.rectangle((140 - c, 23, 140 + c, 257), fill=COULOIR_GREY)


ISLAND_BOXES = {
    "Plains":  (46, 46, 124, 124),
    "Ice":     (156, 46, 234, 124),
    "Jungle":  (46, 156, 124, 234),
    "Desert":  (156, 156, 234, 234),
}
TILE_STEP = 26


def _octagon_pts(x0: float, y0: float, x1: float, y1: float, cut_frac: float = 0.28) -> list:
    """8 sommets d'un octogone taillé dans le rectangle (x0,y0)-(x1,y1)."""
    cx = (x0 + x1) / 2
    H = (x1 - x0) / 2
    cut = H * cut_frac
    return [
        (x0 + cut, y0), (x1 - cut, y0),
        (x1, y0 + cut), (x1, y1 - cut),
        (x1 - cut, y1), (x0 + cut, y1),
        (x0, y1 - cut), (x0, y0 + cut),
    ]


def _draw_island_flat(
    draw: ImageDraw.ImageDraw,
    prefix: str,
    tint_rgb: tuple,
) -> None:
    """Île comme un octogone plein avec grille 3×3 claire (style Unity)."""
    x0, y0, x1, y1 = ISLAND_BOXES[prefix]
    cx = (x0 + x1) / 2
    cy = (y0 + y1) / 2

    # Octogone rempli avec la couleur de camp
    pts = _octagon_pts(x0, y0, x1, y1)
    draw.polygon(pts, fill=tint_rgb + (255,))

    # Grille 3×3 intérieure claire (teinte island + blanc 30%)
    gl = tuple(min(255, int(c * 1.35)) for c in tint_rgb)
    for col in range(-1, 2):
        lx = cx + col * TILE_STEP
        if x0 < lx < x1:
            draw.line((lx, y0, lx, y1), fill=gl + (200,), width=1)
    for row in range(-1, 2):
        ly = cy + row * TILE_STEP
        if y0 < ly < y1:
            draw.line((x0, ly, x1, ly), fill=gl + (200,), width=1)


def main() -> None:
    atlas_data = json.loads(DATA.read_text(encoding="utf-8"))
    sprites = atlas_data["sprites"]
    shapes = atlas_data["tile_shapes"]
    defaults = atlas_data["tile_defaults"]
    layout = json.loads(LAYOUT.read_text(encoding="utf-8"))
    layout.pop("_meta", None)

    atlas = Image.open(ATLAS).convert("RGBA")
    board = Image.new("RGBA", (W, H), BG_DARK)
    draw = ImageDraw.Draw(board)

    # 1. Couloirs gris (bandes extérieures + croix centrale).
    _draw_edge_couloirs(draw)
    _draw_central_cross(draw)

    # 2. Îles — octogones plats solides avec grille 3×3 claire (style Unity flat).
    for prefix, tint in CAMP_TINT.items():
        _draw_island_flat(draw, prefix, tint)

    # 3. HQ corners — petit carré foncé teinté camp (comme Unity).
    hq_camp_tints = {
        "HQ_Green": CAMP_TINT["Plains"],
        "HQ_Blue":  CAMP_TINT["Ice"],
        "HQ_Red":   CAMP_TINT["Jungle"],
        "HQ_Yellow": CAMP_TINT["Desert"],
    }
    for hq_sid, tint in hq_camp_tints.items():
        if hq_sid not in layout:
            continue
        pos = layout[hq_sid]
        dark = tuple(int(c * 0.55) for c in tint)
        cx_h, cy_h = int(round(pos["x"])), int(round(pos["y"]))
        r = 14
        pts = _octagon_pts(cx_h - r, cy_h - r, cx_h + r, cy_h + r, 0.25)
        draw.polygon(pts, fill=dark + (255,))

    # 4. Connecteurs — petits octogones plats (pas de sprites atlas superposés).
    for sid in ["Moon_N", "Moon_S", "Moon_W", "Moon_E"]:
        if sid not in layout:
            continue
        pos = layout[sid]
        cx_m, cy_m = int(round(pos["x"])), int(round(pos["y"]))
        pts = _octagon_pts(cx_m - 13, cy_m - 13, cx_m + 13, cy_m + 13, 0.25)
        draw.polygon(pts, fill=MOON_GREY)
    if "Sun" in layout:
        pos = layout["Sun"]
        cx_s, cy_s = int(round(pos["x"])), int(round(pos["y"]))
        pts = _octagon_pts(cx_s - 14, cy_s - 14, cx_s + 14, cy_s + 14, 0.25)
        draw.polygon(pts, fill=SUN_GREY)
    for n in range(1, 13):
        sid = f"Space_{n}"
        if sid not in layout:
            continue
        pos = layout[sid]
        cx_sp, cy_sp = int(round(pos["x"])), int(round(pos["y"]))
        pts = _octagon_pts(cx_sp - 8, cy_sp - 8, cx_sp + 8, cy_sp + 8, 0.25)
        draw.polygon(pts, fill=SEA_OCTAGON)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
