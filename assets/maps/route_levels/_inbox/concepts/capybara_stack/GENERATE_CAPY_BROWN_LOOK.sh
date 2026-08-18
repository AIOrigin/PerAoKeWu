#!/usr/bin/env bash
set -euo pipefail
# 卡皮巴拉：棕色重贴图 +（可选）四足绑定，便于后续骨骼扭头
# 当前余额约 9 时不够跑；请先: tripo topup
# 用法：
#   ./GENERATE_CAPY_BROWN_LOOK.sh          # 仅棕色 image→model+texture
#   ./GENERATE_CAPY_BROWN_LOOK.sh --rig    # 额外 anim check + quadruped rig
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
CONCEPT="$CONCEPTS/concept_capybara_base_brown.png"
NAME="capybara_base_brown"

mkdir -p "$RAW/$NAME" "$MODELS"

if [[ -f ~/.nvm/nvm.sh ]]; then
  # shellcheck disable=SC1090
  source ~/.nvm/nvm.sh
  nvm use 22 >/dev/null || nvm use default >/dev/null
fi

if [[ ! -f "$CONCEPT" ]]; then
  echo "Missing brown concept: $CONCEPT" >&2
  exit 1
fi

echo "Balance before:"
tripo balance

echo "=== $NAME (brown low-poly capybara) ==="
tripo make "$CONCEPT" \
  --for game-mobile \
  --then texture \
  --name "capy-$NAME" \
  -o "$RAW/$NAME" \
  --yes --no-open

GLB="$(find "$RAW/$NAME" -name 'model.glb' | head -1)"
if [[ -z "${GLB:-}" ]]; then
  echo "No model.glb under $RAW/$NAME" >&2
  exit 1
fi

# 入库（覆盖 capybara_base；原件请先自行备份）
cp "$GLB" "$MODELS/capybara_base.glb"
PREV="$(find "$RAW/$NAME" -name 'preview.png' | head -1 || true)"
if [[ -n "${PREV:-}" ]]; then
  cp "$PREV" "$MODELS/capybara_base_preview.png"
fi
# 同步贴图文件（若存在）
while IFS= read -r tex; do
  base="$(basename "$tex")"
  # 保留 tripo 命名，便于 Godot 引用
  cp "$tex" "$MODELS/capybara_base_${base#model_}" 2>/dev/null || cp "$tex" "$MODELS/"
done < <(find "$(dirname "$GLB")" -maxdepth 1 \( -name '*base_color*' -o -name '*normal*' -o -name '*metallic*' -o -name '*roughness*' \) )

echo "Installed brown model → $MODELS/capybara_base.glb"

if [[ "$DO_RIG" -eq 1 ]]; then
  echo "=== anim check + quadruped rig ==="
  tripo anim check "$GLB" --yes --no-open || true
  tripo anim rig "$GLB" --rig-type quadruped \
    --name "capy-${NAME}-rig" \
    -o "$RAW/${NAME}_rig" \
    --yes --no-open || {
      echo "Rig failed or not enough credits; gameplay still uses LookPivot 扭头。" >&2
    }
fi

echo "Done. Balance after:"
tripo balance
echo "Note: 游戏内靠近扭头已由 LookPivot 实现；骨骼扭头需 rig 后再接 AnimationPlayer。"
