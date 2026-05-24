#!/usr/bin/env python3
"""Extract land adjacency from Unity Dep_terre.js -> data/land_adjacency.json"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT.parent / "Assets" / "Scripts" / "ScriptBattle" / "Dep_terre.js"
OUT = ROOT / "data" / "land_adjacency.json"

text = SRC.read_text(encoding="utf-8", errors="replace")
# First block uses "if (case_name == ...)" not "else if"
text = text.replace('if (case_name == ', 'else if (case_name == ', 1)
blocks = re.split(r"else if \(case_name == ", text)
out: dict = {}
for block in blocks[1:]:
    m = re.match(r'"([^"]+)"\)', block)
    if not m:
        continue
    case = m.group(1)
    parts = re.split(r"nbmove == 3", block, maxsplit=1)
    n1 = sorted(set(re.findall(r'mov\.name == "([^"]+)"', parts[0])))
    n3 = sorted(set(re.findall(r'mov\.name == "([^"]+)"', parts[1]))) if len(parts) > 1 else []
    out[case] = {"move_1": n1, "move_3": n3}

OUT.write_text(json.dumps(out, indent=2), encoding="utf-8")
print(f"Wrote {len(out)} sectors -> {OUT}")
