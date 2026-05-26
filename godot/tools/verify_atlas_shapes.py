#!/usr/bin/env python3
"""Vérifie piece_icons vs contenu réel du PNG (évite F/H/losange inversés)."""
import json
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    raise SystemExit("pip install Pillow")

ROOT = Path(__file__).resolve().parents[1]
ATLAS = ROOT / "assets" / "textures" / "FORCE-AD-13a.png"
DATA = ROOT / "data" / "atlas_sprites.json"

# Mapping validé par inspection visuelle du PNG (pas les noms Unity .meta).
EXPECTED = {
    "circle_outline": "FORCE-AD-13a_14",
    "square_outline": "FORCE-AD-13a_15",
    "triangle_outline": "FORCE-AD-13a_17",
    "diamond_outline": "FORCE-AD-13a_16",
    "circle_filled": "FORCE-AD-13a_19",
    "square_filled": "FORCE-AD-13a_20",   # _20 = carré plein (ligne en dessous de _15 outline)
    "triangle_filled": "FORCE-AD-13a_22",
    "diamond_filled": "FORCE-AD-13a_21",
    "power_f": "FORCE-AD-13a_18",
    "hbomb_h": "FORCE-AD-13a_23",
    "hbomb": "FORCE-AD-13a_23",
}

# Anciennes erreurs à rejeter.
FORBIDDEN = {
    "diamond_outline": {"FORCE-AD-13a_18"},
    "diamond_filled": {"FORCE-AD-13a_23", "FORCE-AD-13a_18"},
    "square_filled": {"FORCE-AD-13a_15", "FORCE-AD-13a_21", "FORCE-AD-13a_23"},  # _15 = outline (était fautif)
    "hbomb_h": {"FORCE-AD-13a_20", "FORCE-AD-13a_18"},
}


def main() -> int:
    data = json.loads(DATA.read_text(encoding="utf-8"))
    icons: dict = data.get("piece_icons", {})
    errors: list[str] = []
    for key, sid in EXPECTED.items():
        got = icons.get(key)
        if got != sid:
            errors.append(f"{key}: attendu {sid}, trouvé {got}")
        if key in FORBIDDEN and got in FORBIDDEN[key]:
            errors.append(f"{key}: sprite interdit {got}")
    if errors:
        for e in errors:
            print("ERREUR", e)
        return 1
    print("OK — piece_icons conformes au PNG")
    return 0


if __name__ == "__main__":
    sys.exit(main())
