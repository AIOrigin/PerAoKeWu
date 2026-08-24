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

python3 - "$ROOT/export_presets.cfg" "$ROOT" <<'PY'
# Godot 选场景导出不会打包 preload() 的脚本，必须把 .gd 写进 export_files。
from pathlib import Path
import re
cfg_path = Path(__import__("sys").argv[1])
root = Path(__import__("sys").argv[2])
rush = root / "assets/maps/route_levels/capybara_rush"
files = ["res://assets/maps/route_levels/capybara_rush/capybara_rush.tscn"]
# Web 没有系统中文字体，必须把工程 GUI 字体打进 pck
files += [
    "res://assets/arts_graphic/font/LiberationMono-Regular-变体.tres",
    "res://assets/arts_graphic/font/smiley-sans-v2.0.1/SmileySans-Oblique-变体.tres",
    "res://assets/arts_graphic/font/smiley-sans-v2.0.1/SmileySans-Oblique.ttf",
    "res://assets/arts_graphic/font/liberation-fonts-ttf-2.00.1/LiberationMono-Regular.ttf",
    # Autoload Global 的 preload 链（否则网页解析 Global.gd 失败）
    "res://assets/maps/route_levels/character_progression.gd",
    "res://assets/maps/route_levels/planet_database.gd",
    "res://assets/maps/route_levels/mission_dispatch.gd",
    "res://assets/maps/route_levels/mission_types.gd",
    "res://assets/maps/route_levels/runner_planet_config.gd",
    "res://assets/maps/route_levels/runner_60s/obstacle_layout.gd",
    "res://assets/maps/route_levels/planets/planet_glass_desert.gd",
    "res://assets/maps/route_levels/planets/planet_rust_belt.gd",
    "res://assets/maps/route_levels/planets/planet_savanna_ring.gd",
]
for p in sorted(rush.rglob("*.gd")):
    rel = p.relative_to(root).as_posix()
    if "/tools/" in f"/{rel}/":
        continue
    if rel.endswith("level_editor/capybara_level_editor.gd"):
        continue
    if rel.endswith("level_editor/capybara_editor_visual.gd"):
        continue
    files.append(f"res://{rel}")
packed = "PackedStringArray(" + ", ".join(f'"{f}"' for f in files) + ")"
text = cfg_path.read_text()
marker = 'name="Capybara Rush Web"'
idx = text.find(marker)
if idx < 0:
    raise SystemExit("export_presets.cfg 没有 Capybara Rush Web 预设")
chunk_end = text.find("\n[preset.", idx + 1)
chunk = text[idx:] if chunk_end < 0 else text[idx:chunk_end]
chunk2 = re.sub(r'export_filter="[^"]*"', 'export_filter="resources"', chunk, count=1)
chunk2 = re.sub(r'export_files=PackedStringArray\([^)]*\)', f"export_files={packed}", chunk2, count=1)
if chunk2 == chunk and "export_filter=\"resources\"" not in chunk:
    raise SystemExit("未能改写 Web 导出预设的 export_files")
cfg_path.write_text(text[:idx] + chunk2 + (text[chunk_end:] if chunk_end >= 0 else ""))
print("Web 导出将包含 %d 个资源：" % len(files))
for f in files:
    print(" ", f)
PY

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

PATCH="$ROOT/assets/maps/route_levels/capybara_rush/tools/capybara_web/patch_web_cache_bust.py"
VER="$(python3 "$PATCH" version)"
python3 "$PATCH" dir "$OUT_DIR"
echo "ASSET_VERSION=${VER} (CDN dir, user cache, pck/js query)"

echo "导出完成：$OUT_DIR"
du -sh "$OUT_DIR"/* 2>/dev/null | sort -hr || true
