#!/usr/bin/env bash
# 按 Elseland deploy-s3-ugc 规则上传星火信使网页包
#   games → s3://<bucket>/public/games/<gameId>/index.html
# 不会删除已上传的 models/。禁止 s3 sync --delete。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
CONFIG="$SCRIPT_DIR/deploy.s3.json"
COMPRESS="$SCRIPT_DIR/wire_compress.py"

: "${AWS_DEFAULT_REGION:=us-east-1}"
: "${COMPRESS_CODEC:=br}"

DEPLOY_ENV="$(python3 -c "import json,os; c=json.load(open('$CONFIG')); print((os.environ.get('DEPLOY_ENV') or c.get('env') or 'prod').lower())")"
case "$DEPLOY_ENV" in
	dev)
		: "${S3_BUCKET:=elser-elseland-s3-dev-uses1}"
		PUBLIC_BASE="${S3_PUBLIC_BASE_URL:-https://assets.dev.elseland.elser.ai}"
		;;
	prod)
		: "${S3_BUCKET:=elser-elseland-s3-prod-uses1}"
		PUBLIC_BASE="${S3_PUBLIC_BASE_URL:-https://assets.elseland.elser.ai}"
		;;
	*)
		echo "DEPLOY_ENV 只能是 dev 或 prod（当前：$DEPLOY_ENV）" >&2
		exit 1
		;;
esac

GAME_ID="$(python3 -c "import json; print(json.load(open('$CONFIG'))['gameId'])")"
SOURCE="$ROOT/$(python3 -c "import json; print(json.load(open('$CONFIG'))['sourceDir'])")"
PREFIX="public/games/${GAME_ID}"
DEST="s3://${S3_BUCKET}/${PREFIX}/"
PUBLIC_URL="${PUBLIC_BASE%/}/games/${GAME_ID}/index.html"
CF_URL="https://de0csn75w3vhy.cloudfront.net/games/${GAME_ID}/index.html"

if [[ ! -f "$SOURCE/index.html" ]]; then
	echo "找不到 $SOURCE/index.html，请先导出 Web：" >&2
	echo "  assets/maps/route_levels/tools/ember_web/export_ember_runner_web.sh" >&2
	exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1; then
	echo "AWS 凭证无效。请在当前 shell export AWS_ACCESS_KEY_ID / SECRET / SESSION_TOKEN 后再跑。" >&2
	exit 1
fi

if ! python3 -c "import brotli" 2>/dev/null && [[ "$COMPRESS_CODEC" == "br" ]]; then
	echo "缺少 brotli。请先执行：python3 -m pip install brotli" >&2
	echo "或改用 gzip：COMPRESS_CODEC=gzip bash $0" >&2
	exit 1
fi

case "$COMPRESS_CODEC" in
	br) CONTENT_ENCODING="br" ;;
	gzip) CONTENT_ENCODING="gzip" ;;
	*)
		echo "COMPRESS_CODEC 只能是 br 或 gzip（当前：$COMPRESS_CODEC）" >&2
		exit 1
		;;
esac

echo "[deploy] env:    $DEPLOY_ENV"
echo "[deploy] bucket: $S3_BUCKET"
echo "[deploy] dest:   $DEST"
echo "[deploy] source: $SOURCE"
echo "[deploy] codec:  $COMPRESS_CODEC ($CONTENT_ENCODING)"
echo "[deploy] next Register Game Catalog MUST use env=$DEPLOY_ENV gameId=$GAME_ID"

WASM_ALIAS="$SOURCE/godot.web.template_release.wasm32.nothreads.wasm"
if [[ -f "$SOURCE/index.wasm" && ! -f "$WASM_ALIAS" ]]; then
	cp "$SOURCE/index.wasm" "$WASM_ALIAS"
	echo "[deploy] wasm alias -> $(basename "$WASM_ALIAS")"
fi

WIRE_TMP="$(mktemp -d)"
cleanup() { rm -rf "$WIRE_TMP"; }
trap cleanup EXIT

compress_upload() {
	local src="$1"
	local key="$2"
	local ctype="$3"
	local out="$WIRE_TMP/$(basename "$key")"
	python3 "$COMPRESS" encode "$src" "$out" "$COMPRESS_CODEC"
	aws s3 cp "$out" "${DEST}${key}" \
		--content-encoding "$CONTENT_ENCODING" \
		--content-type "$ctype" \
		--cache-control "public, max-age=31536000, immutable"
}

aws s3 sync "$SOURCE" "$DEST" \
	--exclude "index.html" \
	--exclude "manifest.json" \
	--exclude "index.wasm" \
	--exclude "index.pck" \
	--exclude "godot.web.template*.wasm" \
	--exclude "*.import" \
	--exclude ".DS_Store" \
	--exclude "models/*" \
	--exclude "models/**" \
	--cache-control "public, max-age=31536000, immutable"

echo "[deploy] compress index.wasm ..."
compress_upload "$SOURCE/index.wasm" "index.wasm" "application/wasm"
echo "[deploy] compress index.pck ..."
compress_upload "$SOURCE/index.pck" "index.pck" "application/octet-stream"

aws s3 cp "$SOURCE/index.html" "${DEST}index.html" \
	--cache-control "no-cache" \
	--content-type "text/html; charset=utf-8"

aws s3 cp "$SCRIPT_DIR/manifest.json" "${DEST}manifest.json" \
	--cache-control "no-cache" \
	--content-type "application/json; charset=utf-8"

PUBLIC_BASE_DIR="${PUBLIC_URL%/index.html}"
curl -sS -o /dev/null --max-time 120 \
	-H "Accept-Encoding: ${CONTENT_ENCODING}" \
	-H 'Origin: https://assets.elseland.elser.ai' \
	"${PUBLIC_BASE_DIR}/index.wasm" || true

echo "[deploy] done"
echo "  $PUBLIC_URL"
echo "  $CF_URL"
echo "[deploy] env=${DEPLOY_ENV} wasm/pck compressed with ${COMPRESS_CODEC}"
echo "[deploy] Register Game Catalog env=${DEPLOY_ENV} gameId=${GAME_ID}"
