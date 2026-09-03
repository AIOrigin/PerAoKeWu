#!/usr/bin/env bash
# 导出星火信使 Web 包（GLB 走 CDN，不打进 pck）
# 主场景保持 mobile_home.tscn，不要改成 capybara。
set -euo pipefail

ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$ROOT"

GODOT="${GODOT:-/Applications/Godot-4.4.1.app/Contents/MacOS/Godot}"
PRESET="Ember Runner Web"
OUT_DIR="$ROOT/build/ember_runner_web"
OUT_HTML="$OUT_DIR/index.html"
PATCH="$ROOT/assets/maps/route_levels/tools/ember_web/patch_web_cache_bust.py"
ENSURE="$ROOT/assets/maps/route_levels/tools/ember_web/ensure_web_preset.py"

if [[ ! -x "$GODOT" ]]; then
	echo "找不到 Godot：$GODOT"
	echo "请设置 GODOT=/path/to/Godot"
	exit 1
fi

python3 "$ENSURE"
python3 "$ROOT/assets/maps/route_levels/tools/ember_web/collect_cdn_images.py"

MAIN_SCENE="$(python3 - <<'PY'
from pathlib import Path
text = Path("project.godot").read_text()
for line in text.splitlines():
    if line.startswith("run/main_scene="):
        print(line.split("=", 1)[1].strip().strip('"'))
        break
PY
)"
EXPECTED='res://assets/maps/route_levels/mobile_home/mobile_home.tscn'
if [[ "$MAIN_SCENE" != "$EXPECTED" ]]; then
	echo "拒绝导出：main_scene 应为 $EXPECTED" >&2
	echo "当前：$MAIN_SCENE" >&2
	exit 1
fi

mkdir -p "$OUT_DIR"
echo "导出预设：$PRESET"
echo "主场景：$MAIN_SCENE"
echo "输出：$OUT_HTML"

"$GODOT" --headless --path "$ROOT" --export-release "$PRESET" "$OUT_HTML"

if [[ ! -f "$OUT_DIR/index.wasm" || ! -f "$OUT_DIR/index.pck" ]]; then
	echo "导出失败：缺少 index.wasm 或 index.pck" >&2
	exit 1
fi

python3 "$PATCH" dir "$OUT_DIR"

echo "导出完成：$OUT_DIR"
du -sh "$OUT_DIR"/* 2>/dev/null | sort -hr || true
echo "下一步（dev）：DEPLOY_ENV=dev bash assets/maps/route_levels/tools/ember_web/upload_game_to_s3.sh"
echo "模型：bash assets/maps/route_levels/tools/ember_web/upload_models_to_s3.sh"
echo "图片：bash assets/maps/route_levels/tools/ember_web/upload_images_to_s3.sh"
