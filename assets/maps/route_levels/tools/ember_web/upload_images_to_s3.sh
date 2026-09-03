#!/usr/bin/env bash
# 将星火信使 UI/天空/地图等栅格图同步到 S3。不要加 --delete。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

: "${EMBER_S3_BUCKET:=elser-elseland-s3-prod-uses1}"
: "${EMBER_S3_REGION:=us-east-1}"
: "${EMBER_S3_PREFIX:=public/games/ember-runner/images}"
DRY_RUN="${DRY_RUN:-0}"

if ! command -v aws >/dev/null 2>&1; then
	echo "未找到 aws CLI" >&2
	exit 1
fi

if ! aws sts get-caller-identity --region "$EMBER_S3_REGION" >/dev/null 2>&1; then
	echo "AWS 凭证无效或已过期。请刷新后再跑（不要把密钥写进仓库）。" >&2
	exit 1
fi

STAGE="$(mktemp -d)"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

python3 - "$ROOT" "$STAGE" <<'PY'
import shutil, sys
from pathlib import Path

root = Path(sys.argv[1])
stage = Path(sys.argv[2])
sys.path.insert(0, str(root / "assets/maps/route_levels/tools/ember_web"))
import collect_cdn_images as collect

files = collect.iter_images(root)
bytes_sum = 0
for src in files:
    rel = src.relative_to(root)
    dst = stage / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    if not dst.exists() or dst.stat().st_size != src.stat().st_size:
        shutil.copy2(src, dst)
    bytes_sum += src.stat().st_size
    print(rel.as_posix())
print(f"# files={len(files)} mb={bytes_sum/1024/1024:.1f}", file=sys.stderr)
collect.write_manifest(root)
PY

DEST="s3://${EMBER_S3_BUCKET}/${EMBER_S3_PREFIX}"
echo "同步图片 -> ${DEST}"

sync_ext() {
	local pattern="$1"
	local ctype="$2"
	local extra=(s3 sync "$STAGE" "$DEST"
		--region "$EMBER_S3_REGION"
		--exclude "*"
		--include "$pattern"
		--include "**/$pattern"
		--content-type "$ctype"
		--cache-control "public, max-age=31536000, immutable"
	)
	if [[ "$DRY_RUN" == "1" ]]; then
		extra+=(--dryrun)
	fi
	aws "${extra[@]}"
}

sync_ext "*.png" "image/png"
sync_ext "*.webp" "image/webp"
sync_ext "*.jpg" "image/jpeg"
sync_ext "*.jpeg" "image/jpeg"

echo ""
echo "完成。CloudFront："
echo "  https://de0csn75w3vhy.cloudfront.net/games/ember-runner/images"
