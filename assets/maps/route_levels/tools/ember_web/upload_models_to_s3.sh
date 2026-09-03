#!/usr/bin/env bash
# 将星火信使跑酷 GLB 同步到 S3（Web CDN 源）
# 不要加 --delete。
#
# 用法：先 aws sts get-caller-identity 成功，然后：
#   ./upload_models_to_s3.sh
#
# 可选：
#   EMBER_S3_BUCKET / EMBER_S3_PREFIX / EMBER_S3_REGION
#   DRY_RUN=1
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

: "${EMBER_S3_BUCKET:=elser-elseland-s3-prod-uses1}"
: "${EMBER_S3_REGION:=us-east-1}"
: "${EMBER_S3_PREFIX:=public/games/ember-runner/models}"
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
import os, shutil, sys
from pathlib import Path
root = Path(sys.argv[1])
stage = Path(sys.argv[2])
pairs = []
models = root / "assets/maps/route_levels/models"
runner = root / "assets/maps/route_levels/runner_60s"
mvp = root / "mvp素材第二批"
if models.is_dir():
    for glb in models.rglob("*.glb"):
        if ".bak" in glb.name:
            continue
        rel = glb.relative_to(models).as_posix()
        pairs.append((glb, stage / rel))
if runner.is_dir():
    for glb in runner.rglob("*.glb"):
        if ".bak" in glb.name:
            continue
        rel = "runner_60s/" + glb.relative_to(runner).as_posix()
        pairs.append((glb, stage / rel))
if mvp.is_dir():
    for glb in mvp.rglob("*.glb"):
        if ".bak" in glb.name:
            continue
        rel = "mvp/" + glb.relative_to(mvp).as_posix()
        pairs.append((glb, stage / rel))
bytes_sum = 0
for src, dst in pairs:
    dst.parent.mkdir(parents=True, exist_ok=True)
    if not dst.exists() or dst.stat().st_size != src.stat().st_size:
        shutil.copy2(src, dst)
    bytes_sum += src.stat().st_size
    print(dst.relative_to(stage).as_posix())
print(f"# files={len(pairs)} mb={bytes_sum/1024/1024:.1f}", file=sys.stderr)
PY

DEST="s3://${EMBER_S3_BUCKET}/${EMBER_S3_PREFIX}"
echo "同步 GLB -> ${DEST}"

SYNC_ARGS=(s3 sync "$STAGE" "$DEST"
	--region "$EMBER_S3_REGION"
	--content-type "model/gltf-binary"
	--cache-control "public, max-age=31536000, immutable"
	--exclude "*.DS_Store"
)
if [[ "$DRY_RUN" == "1" ]]; then
	SYNC_ARGS+=(--dryrun)
fi

aws "${SYNC_ARGS[@]}"

echo ""
echo "完成。CloudFront："
echo "  https://de0csn75w3vhy.cloudfront.net/games/ember-runner/models"
echo "若网页跨域失败："
echo "  aws s3api put-bucket-cors --bucket ${EMBER_S3_BUCKET} --cors-configuration file://${SCRIPT_DIR}/s3-cors.json"
