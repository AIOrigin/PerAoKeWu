#!/usr/bin/env bash
set -euo pipefail
# 五基调差异化资产（统一 Capybara Rush 粉彩低多边形风格）
# 用法：bash GENERATE_THEME_ASSETS.sh
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

STYLE='Low-poly stylized 3D game asset, soft pastel colors, rounded forms, minimal detail, clean silhouette, mobile game style like Capybara Rush, same toy-like pastel art style family, no realism, no PBR metal, no text, no UI, isolated object, centered, solid colors, soft lighting'

echo "Balance before:"
tripo balance

gen_text() {
  local name="$1" prompt_tail="$2" sub="$3"
  if [[ -f "$MODELS/$sub/$name.glb" ]]; then
    echo "=== skip existing $name ==="
    return 0
  fi
  echo "=== text→3D: $name ==="
  tripo make "${STYLE}: ${prompt_tail}" \
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

# T2 蜜糖牧场
gen_text hay_bale \
  "round pastel hay bale prop, warm honey yellow and cream bands, soft cylinder shape, farm toy prop" \
  environment

gen_text fence_pasture \
  "short wooden pasture fence segment obstacle, warm brown vertical posts, two horizontal rails, about player-waist height, soft rounded edges" \
  obstacles

# T3 粉樱云谷
gen_text tree_sakura \
  "stylized lollipop sakura tree, thin brown trunk, one round pink blossom canopy ball, pastel cherry blossom pink, soft matte" \
  environment

gen_text lantern_barrier \
  "cute pastel paper lantern barrier obstacle on a short stand, soft pink and cream lantern, low-poly festival prop blocking a lane" \
  obstacles

# T4 暮色霓虹
gen_text neon_cone \
  "stylized neon traffic cone obstacle, cyan and magenta pastel glow stripes, rounded cone, toy-like, soft matte not shiny chrome" \
  obstacles

gen_text neon_sign_post \
  "cute neon sign post environment prop, short pole with rounded glowing pastel cyan magenta rectangle sign, no readable text, soft toy style" \
  environment

# T5 温泉火山
gen_text volcanic_block \
  "low-poly volcanic rock cube block obstacle, dark grey with soft orange cracks, rounded corners, same scale as pastel block toys" \
  obstacles

gen_text stone_lantern_barrier \
  "stylized stone lantern barrier obstacle, soft grey stone with warm orange glow windows, rounded onsen shrine toy style" \
  obstacles

gen_text steam_vent \
  "stylized onsen steam vent prop, low rock base with soft white steam puff shapes stacked, pastel hot-spring toy prop" \
  environment

echo "Done. Models under: $MODELS"
tripo balance
