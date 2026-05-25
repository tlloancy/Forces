#!/usr/bin/env python3
"""Compose a full 4-quadrant board PNG from atlas tiles (dark theme, tinted camps)."""
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageChops
except ImportError:
    raise SystemExit("pip install Pillow")

ROOT = Path(__file__).resolve().parents[1]
ATLAS = ROOT / "assets" / "textures" / "FORCE-AD-13a.png"
OUT = ROOT / "assets" / "textures" / "board_reference.png"
W, H = 280, 280

LAND_BOX = (878, 534, 948, 604)
HQ_BOX = (948, 40, 1022, 114)
NEUTRAL_BOX = (738, 464, 808, 534)

# Teintes camps (Unity color_red / purple / green / yellow).
CAMP_TINTS = {
    "Plains": (235, 95, 90),
    "Ice": (155, 115, 215),
    "Jungle": (75, 175, 155),
    "Desert": (225, 185, 75),
}


def _tint_tile(base: Image.Image, rgb: tuple) -> Image.Image:
    tile = base.copy().convert("RGBA")
    overlay = Image.new("RGBA", tile.size, rgb + (255,))
    # Multiplier la teinte sur les pixels visibles.
    tinted = ImageChops.multiply(tile, overlay)
    alpha = tile.split()[3]
    tinted.putalpha(alpha)
    return tinted


def _load_tile(box: tuple, size: int) -> Image.Image:
    atlas = Image.open(ATLAS).convert("RGBA")
    return atlas.crop(box).resize((size, size), Image.LANCZOS)


def main() -> None:
    land = _load_tile(LAND_BOX, 88)
    hq = _load_tile(HQ_BOX, 36)
    neutral = _load_tile(NEUTRAL_BOX, 52)

    board = Image.new("RGBA", (W, H), (22, 24, 36, 255))
    draw = ImageDraw.Draw(board)
    draw.rectangle((6, 6, W - 6, H - 6), fill=(32, 34, 48, 255))

    quadrants = {
        "Plains": (14, 14),
        "Ice": (150, 14),
        "Jungle": (14, 150),
        "Desert": (150, 150),
    }
    for prefix, pos in quadrants.items():
        tile = _tint_tile(land, CAMP_TINTS[prefix])
        board.paste(tile, pos, tile)

    center = _tint_tile(neutral, (120, 125, 135))
    board.paste(center, (114, 114), center)

    for pos in [(8, 8), (W - 44, 8), (8, H - 44), (W - 44, H - 44)]:
        board.paste(hq, pos, hq)

    board.convert("RGB").save(OUT)
    print(f"Wrote {OUT} ({W}x{H})")


if __name__ == "__main__":
    main()
