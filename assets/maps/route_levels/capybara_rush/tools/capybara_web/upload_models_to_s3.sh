#!/usr/bin/env bash
# 将卡皮巴拉跑酷正式 GLB 同步到 S3（Web CDN 源）
#
# 用法：
#   先确保 aws sts get-caller-identity 成功，然后：
#   ./upload_models_to_s3.sh
#
# 可选环境变量：
#   CAPYBARA_S3_BUCKET   默认 elser-elseland-s3-prod-uses1
#   CAPYBARA_S3_PREFIX   默认 public/games/capybara-rush/capybara/models
#   CAPYBARA_S3_REGION   默认 us-east-1
#   DRY_RUN=1            只打印、不上传
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
MODELS_DIR="$ROOT/assets/maps/route_levels/capybara_rush/models"

: "${CAPYBARA_S3_BUCKET:=elser-elseland-s3-prod-uses1}"
: "${CAPYBARA_S3_REGION:=us-east-1}"
: "${CAPYBARA_S3_PREFIX:=public/games/capybara-rush/capybara/models}"
DRY_RUN="${DRY_RUN:-0}"

if [[ ! -d "$MODELS_DIR" ]]; then
	echo "找不到 models 目录：$MODELS_DIR" >&2
	exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
	echo "未找到 aws CLI" >&2
	exit 1
fi

if ! aws sts get-caller-identity --region "$CAPYBARA_S3_REGION" >/dev/null 2>&1; then
	echo "AWS 凭证无效或已过期。请刷新后再跑（不要把密钥写进仓库）。" >&2
	echo "  aws sts get-caller-identity" >&2
	exit 1
fi

LIST="$(python3 - "$ROOT" <<'PY'
import os, re, sys
from pathlib import Path
root = Path(sys.argv[1])
capy = root / "assets/maps/route_levels/capybara_rush"
models = capy / "models"
text = (capy / "model_paths.gd").read_text()
names = set(re.findall(r'[\w]+\.glb', text))
for p in (capy / "levels").rglob("*.json"):
    names.update(os.path.basename(x) for x in re.findall(r'[\w./]+\.glb', p.read_text()))
rigged = {n for n in names if n.endswith("_rigged.glb")}
names -= {n.replace("_rigged.glb", ".glb") for n in rigged}
junk = {
    "palm_tree_high.glb",
    "little_monster_cleaned_attempt.glb",
    "little_monster_hollow_cutout.glb",
    "little_monster_with_desk.glb",
    "little_monster_with_props.glb",
    "little_rabbit_tripo_backup.glb",
    "qingqing_unrigged_backup.glb",
    "gap_edge.glb",
    "low_wall.glb",
    "wood_crate.glb",
    "golden_bell_shield.glb",
    "speed_lane.glb",
}
names -= junk
for glb in sorted(models.rglob("*.glb")):
    if ".bak" in glb.name or glb.name not in names:
        continue
    # 同名只保留 model_paths 指向的那份（environment/hay_bale 优先于 obstacles/）
    rel = glb.relative_to(models).as_posix()
    print(rel)
PY
)"

if [[ -z "$LIST" ]]; then
	echo "没有可上传的 GLB" >&2
	exit 1
fi

DEST="s3://${CAPYBARA_S3_BUCKET}/${CAPYBARA_S3_PREFIX}"
echo "同步正式 GLB -> ${DEST}"
echo "$LIST" | sed 's/^/  /'
BYTES="$(echo "$LIST" | while read -r rel; do stat -f%z "$MODELS_DIR/$rel"; done | python3 -c 'import sys; print("%.1f" % (sum(int(x) for x in sys.stdin)/1024/1024))')"
echo "合计约 ${BYTES} MB"

SYNC_ARGS=(s3 sync "$MODELS_DIR" "$DEST"
	--region "$CAPYBARA_S3_REGION"
	--exclude "*"
	--content-type "model/gltf-binary"
	--cache-control "public, max-age=31536000, immutable"
)
while IFS= read -r rel; do
	[[ -n "$rel" ]] || continue
	SYNC_ARGS+=(--include "$rel")
done <<< "$LIST"

if [[ "$DRY_RUN" == "1" ]]; then
	SYNC_ARGS+=(--dryrun)
fi

aws "${SYNC_ARGS[@]}"

echo ""
echo "完成。CloudFront："
echo "  https://de0csn75w3vhy.cloudfront.net/games/capybara-rush/capybara/models"
echo "若网页跨域失败："
echo "  aws s3api put-bucket-cors --bucket ${CAPYBARA_S3_BUCKET} --cors-configuration file://${SCRIPT_DIR}/s3-cors.json"
