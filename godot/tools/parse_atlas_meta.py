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
    "land": by_size.get("70x70", ["FORCE-AD-13a_68"])[0],
    "connector_h": by_size.get("210x70", ["FORCE-AD-13a_70"])[0] if "210x70" in by_size else by_size.get("70x70", ["FORCE-AD-13a_68"])[0],
    "connector_v": by_size.get("70x210", ["FORCE-AD-13a_71"])[0] if "70x210" in by_size else by_size.get("70x70", ["FORCE-AD-13a_68"])[0],
    "sea": by_size.get("70x70", ["FORCE-AD-13a_68"])[0],
    "neutral": by_size.get("70x70", ["FORCE-AD-13a_68"])[0],
}

out = {
    "image_height": IMG_H,
    "texture": "res://assets/textures/FORCE-AD-13a.png",
    "sprites": sprites,
    "highlights": highlights,
    "tile_defaults": tile_defaults,
}
OUT.write_text(json.dumps(out, indent=2), encoding="utf-8")
print(f"Wrote {len(sprites)} sprites -> {OUT}")
