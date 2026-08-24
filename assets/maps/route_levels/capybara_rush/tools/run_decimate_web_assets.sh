#!/usr/bin/env bash
# 批量瘦身 Web CDN 用 GLB（原文件备份到 models/_decimate_backup/）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLENDER="${BLENDER:-/Applications/Blender.app/Contents/MacOS/Blender}"

if [[ ! -x "$BLENDER" ]]; then
	echo "找不到 Blender：$BLENDER" >&2
	exit 1
fi

CATS="${*:-props environment obstacles characters}"
echo "Blender: $BLENDER"
echo "Categories: $CATS"

"$BLENDER" --background --python "$SCRIPT_DIR/blender_decimate_web_assets.py" -- --in-place $CATS

echo "完成。请重新上传模型 CDN（upload_models_to_s3.sh）并 bump ASSET_VERSION。"
