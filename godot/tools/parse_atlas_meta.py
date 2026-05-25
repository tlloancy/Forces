#!/usr/bin/env python3
"""Parse Unity FORCE-AD-13a.png.meta -> data/atlas_sprites.json (Godot top-left coords)."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
META = ROOT.parent / "Assets" / "Textures" / "FORCE-AD-13a.png.meta"
OUT = ROOT / "data" / "atlas_sprites.json"
IMG_H = 2048

text = META.read_text(encoding="utf-8", errors="replace")
pattern = re.compile(
    r"- name: (FORCE-AD-13a_\d+)\s+rect:\s+serializedVersion: 2\s+"
    r"x: (\d+)\s+y: (\d+)\s+width: (\d+)\s+height: (\d+)"
)
sprites: dict = {}
for name, x, y, w, h in pattern.findall(text):
    x, y, w, h = int(x), int(y), int(w), int(h)
    area = w * h
    entry = {"x": x, "y": IMG_H - y - h, "w": w, "h": h}
    if name not in sprites or area > sprites[name]["w"] * sprites[name]["h"]:
        sprites[name] = entry

# Key sprites used by the Godot board renderer.
highlights = {
    "board_reference": "FORCE-AD-13a_13",
    "board_strip": "FORCE-AD-13a_114",
}
for key, sid in highlights.items():
    if sid in sprites:
        highlights[key] = {"id": sid, **sprites[sid]}

# Best-effort tile picks by size (octagonal land/HQ/connector tiles).
by_size: dict = {}
for sid, rect in sprites.items():
    key = f"{rect['w']}x{rect['h']}"
    by_size.setdefault(key, []).append(sid)

tile_defaults = {
    "hq": by_size.get("74x74", ["FORCE-AD-13a_67"])[0],
    "land": by_size.get("70x70", ["FORCE-AD-13a_73"])[0],
    "connector_h": by_size.get("210x70", ["FORCE-AD-13a_105"])[0],
    "connector_v": by_size.get("70x210", ["FORCE-AD-13a_83"])[0],
    "sea": by_size.get("70x70", ["FORCE-AD-13a_106"])[0],
    "neutral": by_size.get("70x70", ["FORCE-AD-13a_77"])[0],
}

# Grille 3×3 ContainsPlace (Unity filtre_case_name) + connecteurs mer Sp1–Sp12.
tile_shapes = {
    "HQ": "FORCE-AD-13a_67",
    "NW": "FORCE-AD-13a_81",
    "N": "FORCE-AD-13a_80",
    "NE": "FORCE-AD-13a_79",
    "W": "FORCE-AD-13a_76",
    "CE": "FORCE-AD-13a_77",
    "E": "FORCE-AD-13a_78",
    "SW": "FORCE-AD-13a_75",
    "S": "FORCE-AD-13a_74",
    "SE": "FORCE-AD-13a_73",
    "Sp1": "FORCE-AD-13a_100",
    "Sp2": "FORCE-AD-13a_101",
    "Sp3": "FORCE-AD-13a_102",
    "Sp4": "FORCE-AD-13a_107",
    # Couloirs mer (barres grises) — pas les losanges 70×70 (_106/_118).
    "Sp5": "FORCE-AD-13a_105",
    "Sp8": "FORCE-AD-13a_108",
    "Sp10": "FORCE-AD-13a_105",
    "Sp12": "FORCE-AD-13a_108",
    "Sp6": "FORCE-AD-13a_83",
    "Sp7": "FORCE-AD-13a_83",
    "Sp9": "FORCE-AD-13a_83",
    "Sp11": "FORCE-AD-13a_83",
}

# UI / pièces — IDs vérifiés sur le PNG (les noms Unity .meta sont trompeurs :
# _18 = lettre F, _23 = lettre H, _16/_21 = losange contour/rempli).
piece_icons = {
    "circle_outline": "FORCE-AD-13a_14",
    "square_outline": "FORCE-AD-13a_15",
    "triangle_outline": "FORCE-AD-13a_17",
    "diamond_outline": "FORCE-AD-13a_16",
    "circle_filled": "FORCE-AD-13a_19",
    "square_filled": "FORCE-AD-13a_15",
    "triangle_filled": "FORCE-AD-13a_22",
    "diamond_filled": "FORCE-AD-13a_21",
    "power_f": "FORCE-AD-13a_18",
    "hbomb_h": "FORCE-AD-13a_23",
    "soldier": "FORCE-AD-13a_11",
    "raider": "FORCE-AD-13a_12",
    "hunter": "FORCE-AD-13a_27",
    "cruiser": "FORCE-AD-13a_24",
    "commando": "FORCE-AD-13a_25",
    "bomber": "FORCE-AD-13a_24",
    "fighter": "FORCE-AD-13a_25",
    "destroyer": "FORCE-AD-13a_24",
    "hbomb": "FORCE-AD-13a_23",
    "hq": "FORCE-AD-13a_67",
    "flag": "FORCE-AD-13a_30",
}

out = {
    "image_height": IMG_H,
    "texture": "res://assets/textures/FORCE-AD-13a.png",
    "sprites": sprites,
    "highlights": highlights,
    "tile_defaults": tile_defaults,
    "tile_shapes": tile_shapes,
    "piece_icons": piece_icons,
}
OUT.write_text(json.dumps(out, indent=2), encoding="utf-8")
print(f"Wrote {len(sprites)} sprites -> {OUT}")
