#!/usr/bin/env bash
set -euo pipefail
# Batch B 障碍/道具：图生 3D + 文生拾取垫，入库到 capybara_rush/models
# 用法：bash GENERATE_BATCH_B_OBSTACLES.sh
# 需：nvm Node 22、tripo login、代理 7890（可改）
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

gen_img() {
  local name="$1" img="$2" sub="$3"
  echo "=== image→3D: $name ==="
  tripo make "$img" \
    --for game-mobile \
    --then texture \
    --name "capy_$name" \
    -o "$RAW/$name" \
    --yes --no-open
  local glb
  glb="$(find "$RAW/$name" -name 'model.glb' | head -1)"
  mkdir -p "$MODELS/$sub"
  cp "$glb" "$MODELS/$sub/$name.glb"
  local prev
  prev="$(find "$RAW/$name" -name 'preview.png' | head -1 || true)"
  if [[ -n "${prev:-}" ]]; then
    cp "$prev" "$MODELS/$sub/${name}_preview.png"
  fi
  echo "installed $MODELS/$sub/$name.glb"
}

gen_text() {
  local name="$1" prompt="$2" sub="$3"
  echo "=== text→3D: $name ==="
  tripo make "$prompt" \
    --for game-mobile \
    --then texture \
    --name "capy_$name" \
    -o "$RAW/$name" \
    --yes --no-open
  local glb
  glb="$(find "$RAW/$name" -name 'model.glb' | head -1)"
  mkdir -p "$MODELS/$sub"
  cp "$glb" "$MODELS/$sub/$name.glb"
  local prev
  prev="$(find "$RAW/$name" -name 'preview.png' | head -1 || true)"
  if [[ -n "${prev:-}" ]]; then
    cp "$prev" "$MODELS/$sub/${name}_preview.png"
  fi
  echo "installed $MODELS/$sub/$name.glb"
}

# Batch B 规划 + 展示用障碍
gen_img fence_half "$CONCEPTS/concept_fence_half.png" obstacles
gen_img low_wall "$CONCEPTS/concept_low_wall.png" obstacles
gen_img gap_edge "$CONCEPTS/concept_gap_edge.png" obstacles
gen_img bush_round "$CONCEPTS/concept_bush_round.png" environment
gen_img traffic_cone "$CONCEPTS/concept_traffic_cone.png" obstacles

gen_text pickup_glow_pad \
  "Low-poly stylized 3D game asset, soft pastel colors, rounded forms, minimal detail, clean silhouette, mobile game style like Capybara Rush, no realism, no text, no UI, isolated object, centered: flat circular pastel glow pad on ground, mint green outer ring, pale yellow middle, cream center, gentle raised rim, soft matte, soft lighting" \
  props

echo "Done. Models under: $MODELS"
tripo balance
