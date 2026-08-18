#!/usr/bin/env bash
set -euo pipefail
# Elser 概念图已就绪后：Tripo 图生 3D（Batch A）并入库到 capybara_rush 地图
# 用法：在任意目录执行本脚本；需 tripo login；默认走本地代理 7890
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export HTTPS_PROXY="${HTTPS_PROXY:-$https_proxy}"
export HTTP_PROXY="${HTTP_PROXY:-$http_proxy}"
export NODE_USE_ENV_PROXY=1

CONCEPTS="$(cd "$(dirname "$0")" && pwd)"
ROUTE="$(cd "$CONCEPTS/../../.." && pwd)"
RAW="$ROUTE/_inbox/tripo_raw/capybara_stack"
MODELS="$ROUTE/capybara_rush/models"
mkdir -p "$RAW"

if [[ -f ~/.nvm/nvm.sh ]]; then
  # shellcheck disable=SC1090
  source ~/.nvm/nvm.sh
  nvm use 22 >/dev/null || nvm use default >/dev/null
fi

echo "Balance before:"
tripo balance

gen() {
  local name="$1" img="$2"
  echo "=== Generating $name ==="
  tripo make "$img" \
    --for game-mobile \
    --then texture \
    --name "capy_$name" \
    -o "$RAW/$name" \
    --yes --no-open
}

gen capybara_base "$CONCEPTS/concept_capybara_base.png"
gen fence_picket "$CONCEPTS/concept_fence_picket.png"
gen rock_edge "$CONCEPTS/concept_rock_edge.png"
gen tree_lollipop "$CONCEPTS/concept_tree_lollipop.png"
gen finish_arch "$CONCEPTS/concept_finish_arch.png"

install_one() {
  local name="$1" sub="$2" dest="$3"
  local glb
  glb="$(find "$RAW/$name" -name 'model.glb' | head -1)"
  mkdir -p "$MODELS/$sub"
  cp "$glb" "$MODELS/$sub/$dest.glb"
  local prev
  prev="$(find "$RAW/$name" -name 'preview.png' | head -1 || true)"
  if [[ -n "${prev:-}" ]]; then
    cp "$prev" "$MODELS/$sub/${dest}_preview.png"
  fi
  echo "installed $MODELS/$sub/$dest.glb"
}

install_one capybara_base characters capybara_base
install_one fence_picket obstacles fence_picket
install_one rock_edge environment rock_edge
install_one tree_lollipop environment tree_lollipop
install_one finish_arch props finish_arch

echo "Done. Models under: $MODELS"
tripo balance
