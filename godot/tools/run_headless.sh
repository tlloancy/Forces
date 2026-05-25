#!/usr/bin/env bash
# Forces — tests headless Godot 4
# GODOT_BIN=/path/to/godot ./tools/run_headless.sh [smoke|compile|import]
set -euo pipefail
MODE="${1:-smoke}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

find_godot() {
  if [[ -n "${GODOT_BIN:-}" && -x "$GODOT_BIN" ]]; then
    echo "$GODOT_BIN"
    return
  fi
  if command -v godot4 &>/dev/null; then command -v godot4; return; fi
  if command -v godot &>/dev/null; then command -v godot; return; fi
  return 1
}

GODOT="$(find_godot)" || {
  echo "Godot introuvable. Exporte GODOT_BIN ou installe godot4 dans le PATH." >&2
  exit 2
}

echo "Godot: $GODOT"
echo "Projet: $ROOT"
echo "Mode: $MODE"

case "$MODE" in
  smoke)
    "$GODOT" --headless --path "$ROOT" "res://scenes/headless_test.tscn"
    ;;
  compile)
    "$GODOT" --headless --path "$ROOT" "res://scenes/menu/main_menu.tscn" --quit-after 2
    ;;
  import)
    "$GODOT" --headless --path "$ROOT" --import --quit
    ;;
  *)
    echo "Mode inconnu: $MODE (smoke|compile|import)" >&2
    exit 2
    ;;
esac
