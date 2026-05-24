#!/usr/bin/env python3
"""Extract adjacency lists from Unity Dep_*.js -> data/*.json"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = {
    "land": ("Dep_terre.js", "land_adjacency.json", True),
    "sea": ("Dep_mer.js", "sea_adjacency.json", False),
    "air": ("Dep_air.js", "air_adjacency.json", False),
}


def parse_file(src: Path, split_move3: bool) -> dict:
    text = src.read_text(encoding="utf-8", errors="replace")
    text = text.replace("if (case_name == ", "else if (case_name == ", 1)
    blocks = re.split(r"else if \(case_name == ", text)
    out: dict = {}
    for block in blocks[1:]:
        m = re.match(r'"([^"]+)"\)', block)
        if not m:
            continue
        case = m.group(1)
        if split_move3:
            parts = re.split(r"nbmove == 3", block, maxsplit=1)
            n1 = sorted(set(re.findall(r'mov\.name == "([^"]+)"', parts[0])))
            n3 = sorted(set(re.findall(r'mov\.name == "([^"]+)"', parts[1]))) if len(parts) > 1 else []
            out[case] = {"move_1": n1, "move_3": n3}
        else:
            neighbors = sorted(set(re.findall(r'mov\.name == "([^"]+)"', block)))
            out[case] = neighbors
    return out


def main() -> None:
    kind = sys.argv[1] if len(sys.argv) > 1 else "all"
    targets = [kind] if kind != "all" else list(SOURCES.keys())
    for name in targets:
        js_name, json_name, split_move3 = SOURCES[name]
        src = ROOT.parent / "Assets" / "Scripts" / "ScriptBattle" / js_name
        out = ROOT / "data" / json_name
        data = parse_file(src, split_move3)
        out.write_text(json.dumps(data, indent=2), encoding="utf-8")
        print(f"{name}: {len(data)} sectors -> {out}")


if __name__ == "__main__":
    main()
