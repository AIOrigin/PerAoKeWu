#!/usr/bin/env bash
set -euo pipefail
# 水果道具：西瓜切片 / 香蕉 / 菠萝 / 榴莲（统一 Capybara Rush 粉彩风格）
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export HTTPS_PROXY="${HTTPS_PROXY:-$https_proxy}"
export HTTP_PROXY="${HTTP_PROXY:-$http_proxy}"
export NODE_USE_ENV_PROXY=1

CONCEPTS="$(cd "$(dirname "$0")" && pwd)"
ROUTE="$(cd "$CONCEPTS/../../.." && pwd)"
RAW="$ROUTE/_inbox/tripo_raw/capybara_stack"
MODELS="$ROUTE/capybara_rush/models"
mkdir -p "$RAW/props" "$MODELS/props"

if [[ -f ~/.nvm/nvm.sh ]]; then
  # shellcheck disable=SC1090
  source ~/.nvm/nvm.sh
  nvm use 22 >/dev/null || nvm use default >/dev/null
fi

STYLE='Low-poly stylized 3D game asset, soft pastel colors, rounded forms, minimal detail, clean silhouette, mobile game style like Capybara Rush, same toy-like pastel art style family, no realism, no PBR metal, no text, no UI, isolated object, centered, solid colors, soft lighting'

echo "Balance before:"
tripo balance

gen_text() {
  local name="$1" prompt_tail="$2"
  # 强制重生成西瓜；其它已有可跳过
  if [[ "$name" != "watermelon_slice" && -f "$MODELS/props/$name.glb" ]]; then
    echo "=== skip existing $name ==="
    return 0
  fi
  echo "=== text→3D: $name ==="
  rm -rf "$RAW/$name"
  tripo make "${STYLE}: ${prompt_tail}" \
    --for game-mobile \
    --then texture \
    --name "capy_$name" \
    -o "$RAW/$name" \
    --yes --no-open
  local glb
  glb="$(find "$RAW/$name" -name 'model.glb' | head -1)"
  mkdir -p "$MODELS/props"
  cp "$glb" "$MODELS/props/$name.glb"
  local prev
  prev="$(find "$RAW/$name" -name 'preview.png' | head -1 || true)"
  if [[ -n "${prev:-}" ]]; then
    cp "$prev" "$MODELS/props/${name}_preview.png"
  fi
  echo "installed $MODELS/props/$name.glb"
}

gen_text watermelon_slice \
  "cute watermelon slice fruit prop, thick triangular wedge, dark green striped rind, white pith rim, bright pink-red flesh with a few black seeds, soft rounded edges, toy food"

gen_text banana \
  "cute yellow banana fruit prop, gentle curve, soft pastel yellow peel, tiny brown tip, rounded low-poly toy food"

gen_text pineapple \
  "cute pineapple fruit prop, oval body with diamond pattern, warm yellow-orange body, short green leafy crown on top, rounded toy food"

gen_text durian \
  "cute durian fruit prop, round spiky pastel yellow-green shell with soft stubby spikes, toy-like not scary, low-poly mobile game food"

gen_text apple \
  "cute red apple fruit prop, slightly flattened sphere with a short brown stem and one green leaf on top, soft pastel toy food, NOT a plain ball"

gen_text orange \
  "cute orange citrus fruit prop, bumpy peel texture suggestion, soft warm orange color, tiny green leaf stem, rounded toy food, NOT a plain smooth ball"

echo "Done fruits."
tripo balance
