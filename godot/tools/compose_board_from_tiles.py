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
    "Plains": (232, 72, 98),        # → bordeaux Unity #8b3040 (compensé multiply)
    "Ice": (118, 82, 245),          # → violet Unity #4a3578 (compensé multiply)
    "Jungle": (60, 165, 158),       # → teal Unity #2a6e6a (compensé multiply)
    "Desert": (230, 170, 62),       # → doré Unity #8a6a30 (compensé multiply)
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


def _draw_grid(draw: ImageDraw.ImageDraw) -> None:
    """Grille 3×3 uniquement à l'intérieur de chaque île (comme Unity)."""
    for x0, y0, x1, y1 in ISLAND_BOXES.values():
        cx = (x0 + x1) // 2
        cy = (y0 + y1) // 2
        for col in range(-1, 2):
            lx = cx + col * TILE_STEP
            if x0 <= lx <= x1:
                draw.line((lx, y0, lx, y1), fill=GRID_LINE, width=1)
        for row in range(-1, 2):
            ly = cy + row * TILE_STEP
            if y0 <= ly <= y1:
                draw.line((x0, ly, x1, ly), fill=GRID_LINE, width=1)


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

    # 1. Grille de fond.
    _draw_grid(draw)

    # 2. Couloirs gris (bandes extérieures + croix centrale).
    _draw_edge_couloirs(draw)
    _draw_central_cross(draw)

    # 3. Îles 3×3 (tuiles octogonales teintées).
    for prefix, tint in CAMP_TINT.items():
        for suffix in ["NW", "N", "NE", "W", "C", "E", "SW", "S", "SE"]:
            sid = f"{prefix}_{suffix}"
            if sid not in layout:
                continue
            sprite_id = shapes.get(suffix, defaults["land"])
            tile = _sprite(atlas, sprites, sprite_id)
            if tile is None:
                continue
            tile = _tint(tile, tint)
            pos = layout[sid]
            _paste_at(board, tile, pos["x"], pos["y"], 33, 33)

    # 4. HQ tiles aux 4 coins (teintés par camp adverse au CE des îles).
    hq_tints = {
        "HQ_Green": CAMP_TINT["Plains"],
        "HQ_Blue": CAMP_TINT["Ice"],
        "HQ_Red": CAMP_TINT["Jungle"],
        "HQ_Yellow": CAMP_TINT["Desert"],
    }
    hq_sprite_id = shapes.get("HQ", defaults["hq"])
    hq_tile = _sprite(atlas, sprites, hq_sprite_id)
    if hq_tile is not None:
        for sid, tint in hq_tints.items():
            if sid not in layout:
                continue
            pos = layout[sid]
            tinted = _tint(hq_tile, tint)
            # Assombrir le HQ (drapeau coloré dans fond plus sombre).
            dark_overlay = Image.new("RGBA", tinted.size, (50, 50, 60, 255))
            tinted = ImageChops.multiply(tinted, dark_overlay)
            _paste_at(board, tinted, pos["x"], pos["y"], 32, 32)

    # 5. Moons + Sun + Space connectors (octogones gris).
    moon_sprite_id = shapes.get("CE", defaults["neutral"])
    moon_tile = _sprite(atlas, sprites, moon_sprite_id)
    if moon_tile is not None:
        for sid in ["Moon_N", "Moon_S", "Moon_W", "Moon_E"]:
            if sid not in layout:
                continue
            pos = layout[sid]
            tinted = _tint(moon_tile, MOON_GREY[:3])
            _paste_at(board, tinted, pos["x"], pos["y"], 26, 26)
        if "Sun" in layout:
            pos = layout["Sun"]
            tinted = _tint(moon_tile, SUN_GREY[:3])
            _paste_at(board, tinted, pos["x"], pos["y"], 28, 28)
        for n in range(1, 13):
            sid = f"Space_{n}"
            if sid not in layout:
                continue
            pos = layout[sid]
            tinted = _tint(moon_tile, SEA_OCTAGON[:3])
            _paste_at(board, tinted, pos["x"], pos["y"], 16, 16)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
