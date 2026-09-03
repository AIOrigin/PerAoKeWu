#!/usr/bin/env bash
# 按 Elseland deploy-s3-ugc 规则上传卡皮巴拉跑酷网页包
#   games → s3://<bucket>/public/games/<gameId>/index.html
# index.html / manifest.json 不缓存；wasm/pck/js 长期缓存。
# wasm/pck 默认 Brotli 预压缩上传（Content-Encoding: br），首访约 13MB。
# 依赖：python3 -m pip install brotli
# 兼容旧环境可 COMPRESS_CODEC=gzip bash upload_game_to_s3.sh
# 环境：DEPLOY_ENV=dev|prod（默认读 deploy.s3.json 的 env，否则 prod）
#   Register Game Catalog 选哪边，就用对应 DEPLOY_ENV 上传，两边必须一致。
# 不会删除已上传的 capybara/models/。
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
		echo "DEPLOY_ENV must be dev or prod (got: $DEPLOY_ENV)" >&2
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
	echo "Missing $SOURCE/index.html. Export web first:" >&2
	echo "  assets/maps/route_levels/capybara_rush/tools/export_capybara_rush_web.sh" >&2
	exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1; then
	echo "Invalid AWS credentials. Export AWS_ACCESS_KEY_ID / SECRET / SESSION_TOKEN in this shell." >&2
	exit 1
fi

if ! python3 -c "import brotli" 2>/dev/null && [[ "$COMPRESS_CODEC" == "br" ]]; then
	echo "Missing brotli. Run: python3 -m pip install brotli" >&2
	echo "Or use gzip: COMPRESS_CODEC=gzip bash $0" >&2
	exit 1
fi

case "$COMPRESS_CODEC" in
	br) CONTENT_ENCODING="br" ;;
	gzip) CONTENT_ENCODING="gzip" ;;
	*)
		echo "COMPRESS_CODEC must be br or gzip (got: $COMPRESS_CODEC)" >&2
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

# 资源文件：长期缓存。排除 html、大体积 wasm/pck（单独压缩上传）、Godot 模板 wasm 副本。
aws s3 sync "$SOURCE" "$DEST" \
	--exclude "index.html" \
	--exclude "manifest.json" \
	--exclude "index.wasm" \
	--exclude "index.pck" \
	--exclude "godot.web.template*.wasm" \
	--exclude "*.import" \
	--exclude ".DS_Store" \
	--exclude "capybara/*" \
	--exclude "capybara/**" \
	--cache-control "public, max-age=31536000, immutable"

echo "[deploy] compress index.wasm ..."
compress_upload "$SOURCE/index.wasm" "index.wasm" "application/wasm"
echo "[deploy] compress index.pck ..."
compress_upload "$SOURCE/index.pck" "index.pck" "application/octet-stream"

# html 必须 no-cache，刷新才能拿到带新 ?v= 的入口
aws s3 cp "$SOURCE/index.html" "${DEST}index.html" \
	--cache-control "no-cache" \
	--content-type "text/html; charset=utf-8"

aws s3 cp "$SCRIPT_DIR/manifest.json" "${DEST}manifest.json" \
	--cache-control "no-cache" \
	--content-type "application/json; charset=utf-8"

# 预热压缩版 wasm
PUBLIC_BASE="${PUBLIC_URL%/index.html}"
curl -sS -o /dev/null --max-time 120 \
	-H "Accept-Encoding: ${CONTENT_ENCODING}" \
	-H 'Origin: https://assets.elseland.elser.ai' \
	"${PUBLIC_BASE}/index.wasm" || true

echo "[deploy] done"
echo "  $PUBLIC_URL"
echo "  $CF_URL"
echo "[deploy] env=${DEPLOY_ENV} wasm/pck compressed with ${COMPRESS_CODEC}"
echo "[deploy] Register Game Catalog env=${DEPLOY_ENV} gameId=${GAME_ID}"
