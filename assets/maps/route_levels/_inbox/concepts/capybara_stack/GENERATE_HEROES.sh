#!/usr/bin/env bash
set -euo pipefail
# 新主角：小怪兽（参考图）+ 小兔子（同风格文生）
# 用法：bash GENERATE_HEROES.sh
# 可选：bash GENERATE_HEROES.sh --rig   # 额外尝试 biped/quad 绑定
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export HTTPS_PROXY="${HTTPS_PROXY:-$https_proxy}"
export HTTP_PROXY="${HTTP_PROXY:-$http_proxy}"
export NODE_USE_ENV_PROXY=1

DO_RIG=0
for a in "$@"; do
  [[ "$a" == "--rig" ]] && DO_RIG=1
done

CONCEPTS="$(cd "$(dirname "$0")" && pwd)"
ROUTE="$(cd "$CONCEPTS/../../.." && pwd)"
RAW="$ROUTE/_inbox/tripo_raw/capybara_stack"
MODELS="$ROUTE/capybara_rush/models/characters"
MONSTER_IMG="$CONCEPTS/concept_little_monster.png"
mkdir -p "$RAW" "$MODELS"

if [[ -f ~/.nvm/nvm.sh ]]; then
  # shellcheck disable=SC1090
  source ~/.nvm/nvm.sh
  nvm use 22 >/dev/null || nvm use default >/dev/null
fi

STYLE='Low-poly stylized 3D game character, soft pastel colors, rounded toy-like forms, amigurumi crochet plush look, clean silhouette, mobile runner game hero, same pastel art family as Capybara Rush, no realism, no photoreal fabric pores, no text, no UI, isolated character, centered, T-pose or neutral standing, soft lighting'

echo "Balance before:"
tripo balance

install_char() {
  local name="$1"
  local glb
  glb="$(find "$RAW/$name" -name 'model.glb' | head -1)"
  if [[ -z "${glb:-}" ]]; then
    echo "No model.glb for $name" >&2
    return 1
  fi
  cp "$glb" "$MODELS/$name.glb"
  local prev
  prev="$(find "$RAW/$name" -name 'preview.png' | head -1 || true)"
  if [[ -n "${prev:-}" ]]; then
    cp "$prev" "$MODELS/${name}_preview.png"
  fi
  echo "installed $MODELS/$name.glb"
}

# --- 小怪兽：用户钩织参考图 → 3D ---
if [[ ! -f "$MONSTER_IMG" ]]; then
  echo "Missing monster concept: $MONSTER_IMG" >&2
  exit 1
fi

if [[ -f "$MODELS/little_monster.glb" ]]; then
  echo "=== skip existing little_monster ==="
else
  echo "=== image→3D: little_monster ==="
  tripo make "$MONSTER_IMG" \
    --for game-mobile \
    --then texture \
    --name "capy-little-monster" \
    -o "$RAW/little_monster" \
    --yes --no-open
  install_char little_monster
fi

# --- 小兔子：同钩织/粉彩玩具风文生 ---
if [[ -f "$MODELS/little_rabbit.glb" ]]; then
  echo "=== skip existing little_rabbit ==="
else
  echo "=== text→3D: little_rabbit ==="
  tripo make "${STYLE}: cute little rabbit hero, chubby round crochet amigurumi bunny, soft cream and pastel pink body, long floppy ears, tiny black bead eyes, small pink nose, short grey yarn limbs thin like string, standing upright facing camera, whimsical ugly-cute plush toy, single character" \
    --for game-mobile \
    --then texture \
    --name "capy-little-rabbit" \
    -o "$RAW/little_rabbit" \
    --yes --no-open
  install_char little_rabbit
fi

if [[ "$DO_RIG" -eq 1 ]]; then
  for name in little_monster little_rabbit; do
    GLB="$MODELS/$name.glb"
    [[ -f "$GLB" ]] || continue
    echo "=== anim check + biped rig: $name ==="
    tripo anim check "$GLB" --yes --no-open || true
    tripo anim rig "$GLB" --rig-type biped \
      --name "capy-${name}-rig" \
      -o "$RAW/${name}_rig" \
      --yes --no-open || {
        echo "Rig failed for $name; unrigged glb still usable." >&2
        continue
      }
    RIG_GLB="$(find "$RAW/${name}_rig" -name 'model.glb' | head -1 || true)"
    if [[ -n "${RIG_GLB:-}" ]]; then
      cp "$RIG_GLB" "$MODELS/${name}_rigged.glb"
      echo "installed $MODELS/${name}_rigged.glb"
    fi
  done
fi

echo "Done. Heroes under: $MODELS"
tripo balance
