#!/usr/bin/env bash
# 导出卡皮巴拉跑酷 Web 包（模型走 CDN，不打进 pck）
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$ROOT"

GODOT="${GODOT:-/Applications/Godot-4.4.1.app/Contents/MacOS/Godot}"
PRESET="Capybara Rush Web"
OUT_DIR="$ROOT/build/capybara_rush_web"
OUT_HTML="$OUT_DIR/index.html"
MAIN_SCENE='res://assets/maps/route_levels/capybara_rush/capybara_rush.tscn'
PROJECT_GODOT="$ROOT/project.godot"

if [[ ! -x "$GODOT" ]]; then
	echo "找不到 Godot：$GODOT"
	echo "请设置 GODOT=/path/to/Godot"
	exit 1
fi

mkdir -p "$OUT_DIR"

restore_main_scene() {
	if [[ -f "$PROJECT_GODOT.bak_web_export" ]]; then
		mv -f "$PROJECT_GODOT.bak_web_export" "$PROJECT_GODOT"
	fi
}
trap restore_main_scene EXIT

cp "$PROJECT_GODOT" "$PROJECT_GODOT.bak_web_export"
python3 - "$PROJECT_GODOT" "$MAIN_SCENE" <<'PY'
import sys
from pathlib import Path
path, scene = Path(sys.argv[1]), sys.argv[2]
text = path.read_text()
old = 'run/main_scene="res://assets/maps/route_levels/mobile_home/mobile_home.tscn"'
new = f'run/main_scene="{scene}"'
if old not in text:
    raise SystemExit("project.godot 未找到默认 main_scene，拒绝改写")
path.write_text(text.replace(old, new, 1))
PY

"$GODOT" --headless --path "$ROOT" --export-release "$PRESET" "$OUT_HTML"

echo "导出完成：$OUT_DIR"
du -sh "$OUT_DIR"/* 2>/dev/null | sort -hr || true
