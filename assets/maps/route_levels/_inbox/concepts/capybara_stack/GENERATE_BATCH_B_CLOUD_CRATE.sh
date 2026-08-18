#!/usr/bin/env bash
set -euo pipefail
# 补生成：云朵 + 木箱（需 Tripo 余额，每个约 60 credits）
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export HTTPS_PROXY="${HTTPS_PROXY:-$https_proxy}"
export HTTP_PROXY="${HTTP_PROXY:-$http_proxy}"
export NODE_USE_ENV_PROXY=1

CONCEPTS="$(cd "$(dirname "$0")" && pwd)"
ROUTE="$(cd "$CONCEPTS/../../.." && pwd)"
RAW="$ROUTE/_inbox/tripo_raw/capybara_stack"
MODELS="$ROUTE/capybara_rush/models"

if [[ -f ~/.nvm/nvm.sh ]]; then
  # shellcheck disable=SC1090
  source ~/.nvm/nvm.sh
  nvm use 22 >/dev/null || true
fi

tripo balance

gen_one() {
  local name="$1" img="$2" sub="$3"
  echo "=== $name ==="
  tripo make "$img" --for game-mobile --then texture --name "capy_$name" -o "$RAW/$name" --yes --no-open
  local glb; glb="$(find "$RAW/$name" -name 'model.glb' | head -1)"
  mkdir -p "$MODELS/$sub"
  cp "$glb" "$MODELS/$sub/$name.glb"
  echo "installed $MODELS/$sub/$name.glb"
}

gen_one cloud_fluffy "$CONCEPTS/concept_cloud_fluffy.png" environment
gen_one wood_crate "$CONCEPTS/concept_wood_crate.png" obstacles
tripo balance
