#!/usr/bin/env bash
# 把 GDAI MCP 插件 zip 装进本工程，并启用 plugin.cfg
# 用法:
#   ./tools/install_gdai_mcp.sh ~/Downloads/gdai-mcp-plugin-godot.zip
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ZIP="${1:-}"
if [[ -z "$ZIP" || ! -f "$ZIP" ]]; then
  echo "用法: $0 /path/to/gdai-mcp-*.zip"
  echo "请先从 https://gdaimcp.com 下载插件 zip。"
  exit 1
fi
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
unzip -q "$ZIP" -d "$TMP"
SRC=""
if [[ -d "$TMP/addons/gdai-mcp-plugin-godot" ]]; then
  SRC="$TMP/addons/gdai-mcp-plugin-godot"
elif [[ -d "$TMP/gdai-mcp-plugin-godot" ]]; then
  SRC="$TMP/gdai-mcp-plugin-godot"
elif [[ -d "$TMP/addons/gdai-mcp-server-godot" ]]; then
  SRC="$TMP/addons/gdai-mcp-server-godot"
else
  echo "zip 里找不到 gdai-mcp-plugin-godot 目录，内容如下："
  find "$TMP" -maxdepth 3 -type d
  exit 1
fi
NAME="$(basename "$SRC")"
DEST="$ROOT/addons/$NAME"
rm -rf "$DEST"
mkdir -p "$ROOT/addons"
cp -R "$SRC" "$DEST"
echo "已安装到: $DEST"
CFG="$DEST/plugin.cfg"
if [[ -f "$CFG" ]]; then
  echo "请在 Godot: Project → Project Settings → Plugins 启用 GDAI MCP"
  echo "或把下面路径加入 project.godot 的 editor_plugins.enabled："
  echo "  res://addons/$NAME/plugin.cfg"
fi
echo
echo "Cursor MCP 已写在 .cursor/mcp.json"
echo "若脚本路径不同，打开 Godot 底部 GDAI MCP 面板复制 JSON 覆盖即可。"
echo
echo "使用顺序："
echo "  1) 打开 Godot 工程并启用插件，确认底部 GDAI MCP 状态为运行中"
echo "  2) Cursor Settings → MCP 刷新 gdai-mcp"
echo "  3) 对话里让 AI 读写场景/脚本/错误日志"
