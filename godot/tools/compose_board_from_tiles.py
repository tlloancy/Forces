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
BG_DARK = (28, 30, 52, 255)
GRID_LINE = (60, 65, 90, 255)
COULOIR_GREY = (68, 72, 84, 255)
SEA_OCTAGON = (110, 115, 128, 255)
MOON_GREY = (135, 140, 150, 255)
SUN_GREY = (110, 115, 128, 255)
CAMP_TINT = {
    "Plains": (190, 90, 95),
    "Ice": (135, 105, 185),
    "Jungle": (80, 155, 145),
    "Desert": (190, 155, 80),
}

# Bandes couloir (zones grises sur les bords extérieurs entre HQs).
EDGE_BAND = 12  # demi-épaisseur de la bande couloir en design units
EDGE_INSET = 50  # marge depuis les coins HQ avant la bande

# Croix centrale (Moons → Sun).
CROSS_HALF = 12  # demi-largeur des bras de la croix


def _tint(img: Image.Image, rgb: tuple) -> Image.Image:
    base = img.convert("RGBA")
    overlay = Image.new("RGBA", base.size, rgb + (255,))
    out = ImageChops.multiply(base, overlay)
    out.putalpha(base.split()[3])
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


def _draw_grid(draw: ImageDraw.ImageDraw) -> None:
    """Grille fine pour rappeler la structure Unity."""
    for i in range(0, W + 1, 23):
        draw.line((i, 0, i, H), fill=GRID_LINE, width=1)
        draw.line((0, i, W, i), fill=GRID_LINE, width=1)


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
            _paste_at(board, tile, pos["x"], pos["y"], 27, 27)

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
            _paste_at(board, tinted, pos["x"], pos["y"], 28, 28)

    # 5. Moons + Sun + Space connectors (octogones gris).
    moon_sprite_id = shapes.get("CE", defaults["neutral"])
    moon_tile = _sprite(atlas, sprites, moon_sprite_id)
    if moon_tile is not None:
        for sid in ["Moon_N", "Moon_S", "Moon_W", "Moon_E"]:
            if sid not in layout:
                continue
            pos = layout[sid]
            tinted = _tint(moon_tile, MOON_GREY[:3])
            _paste_at(board, tinted, pos["x"], pos["y"], 22, 22)
        if "Sun" in layout:
            pos = layout["Sun"]
            tinted = _tint(moon_tile, SUN_GREY[:3])
            _paste_at(board, tinted, pos["x"], pos["y"], 24, 24)
        for n in range(1, 13):
            sid = f"Space_{n}"
            if sid not in layout:
                continue
            pos = layout[sid]
            tinted = _tint(moon_tile, SEA_OCTAGON[:3])
            _paste_at(board, tinted, pos["x"], pos["y"], 14, 14)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    board.convert("RGB").save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
