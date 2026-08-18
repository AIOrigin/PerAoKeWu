#!/usr/bin/env bash
set -euo pipefail
# 参考 TikTok/截图风格：趴着 loaf 卡皮巴拉 → Tripo 建模+贴图+四足绑定
# 用法：./GENERATE_CAPY_PRONE.sh
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export HTTPS_PROXY="${HTTPS_PROXY:-$https_proxy}"
export HTTP_PROXY="${HTTP_PROXY:-$http_proxy}"
export NODE_USE_ENV_PROXY=1

CONCEPTS="$(cd "$(dirname "$0")" && pwd)"
ROUTE="$(cd "$CONCEPTS/../../.." && pwd)"
RAW="$ROUTE/_inbox/tripo_raw/capybara_stack/capybara_prone"
RIG_OUT="$ROUTE/_inbox/tripo_raw/capybara_stack/capybara_prone_rig"
MODELS="$ROUTE/capybara_rush/models/characters"
CONCEPT="$CONCEPTS/concept_capybara_prone.png"

mkdir -p "$RAW" "$RIG_OUT" "$MODELS"
if [[ -f ~/.nvm/nvm.sh ]]; then
  # shellcheck disable=SC1090
  source ~/.nvm/nvm.sh
  nvm use 22 >/dev/null || nvm use default >/dev/null
fi

[[ -f "$CONCEPT" ]] || { echo "Missing $CONCEPT" >&2; exit 1; }

tripo balance
tripo make "$CONCEPT" --for game-mobile --then texture --name "capy-prone" -o "$RAW" --yes --no-open
GLB="$(find "$RAW" -name 'model.glb' | head -1)"
cp "$GLB" "$MODELS/capybara_base.glb"
PREV="$(find "$RAW" -name 'preview.png' | head -1 || true)"
[[ -n "${PREV:-}" ]] && cp "$PREV" "$MODELS/capybara_base_preview.png"

tripo anim rig "$GLB" --rig-type quadruped --name "capy-prone-rig" -o "$RIG_OUT" --yes --no-open
RIG="$(find "$RIG_OUT" -name 'model.glb' | head -1)"
cp "$RIG" "$MODELS/capybara_base_rigged.glb"
RPREV="$(find "$RIG_OUT" -name 'preview.png' | head -1 || true)"
[[ -n "${RPREV:-}" ]] && cp "$RPREV" "$MODELS/capybara_base_rigged_preview.png"

echo "Installed prone + rigged under $MODELS"
tripo balance
