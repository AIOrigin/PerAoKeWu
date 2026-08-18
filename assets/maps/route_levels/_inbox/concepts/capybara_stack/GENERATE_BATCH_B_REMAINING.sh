#!/usr/bin/env bash
set -uo pipefail
# 剩余 Batch B：生成后只要有 model.glb 就入库；下载卡住可跳过预览图
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

install_glb() {
  local name="$1" sub="$2"
  local glb
  glb="$(find "$RAW/$name" -name 'model.glb' 2>/dev/null | head -1 || true)"
  if [[ -z "${glb:-}" ]]; then
    echo "MISSING model.glb for $name" >&2
    return 1
  fi
  mkdir -p "$MODELS/$sub"
  cp "$glb" "$MODELS/$sub/$name.glb"
  local prev
  prev="$(find "$RAW/$name" -name 'preview.png' 2>/dev/null | head -1 || true)"
  if [[ -n "${prev:-}" ]]; then
    cp "$prev" "$MODELS/$sub/${name}_preview.png" || true
  fi
  echo "installed $MODELS/$sub/$name.glb ($(wc -c < "$MODELS/$sub/$name.glb") bytes)"
}

# 后台跑 tripo；轮询 model.glb；超时则杀进程但仍尝试入库
run_make() {
  local name="$1"
  shift
  local out_dir="$RAW/$name"
  mkdir -p "$out_dir"
  echo "=== $name ==="
  # 清掉旧 unfinished 进程相关输出目录中不完整文件？保留已有成功 glb
  (
    tripo make "$@" --for game-mobile --then texture --name "capy_$name" -o "$out_dir" --yes --no-open
  ) >"$out_dir/_tripo_log.txt" 2>&1 &
  local pid=$!
  local waited=0
  local max_wait=420  # 7 min
  local last_size=0
  local stable=0
  while kill -0 "$pid" 2>/dev/null; do
    sleep 5
    waited=$((waited + 5))
    local glb
    glb="$(find "$out_dir" -name 'model.glb' 2>/dev/null | head -1 || true)"
    if [[ -n "${glb:-}" ]]; then
      local sz
      sz=$(wc -c < "$glb" | tr -d ' ')
      if [[ "$sz" -gt 100000 && "$sz" -eq "$last_size" ]]; then
        stable=$((stable + 5))
      else
        stable=0
        last_size=$sz
      fi
      # glb 体积稳定 20s 且日志已写到 texture success → 可提前结束下载挂起
      if [[ "$stable" -ge 20 ]] && grep -q "texture_model · success" "$out_dir/_tripo_log.txt" 2>/dev/null; then
        echo "model.glb stable after texture success; stopping hung download if any"
        # 给一点时间写完
        sleep 3
        if kill -0 "$pid" 2>/dev/null; then
          # 若仍停在 downloading，杀掉子进程树
          if grep -q "downloading artifacts" "$out_dir/_tripo_log.txt" 2>/dev/null && ! grep -q "installed\|Done\|artifact download failed\|terminated" "$out_dir/_tripo_log.txt" 2>/dev/null; then
            pkill -P "$pid" 2>/dev/null || true
            kill "$pid" 2>/dev/null || true
            wait "$pid" 2>/dev/null || true
            break
          fi
        fi
      fi
    fi
    if [[ "$waited" -ge "$max_wait" ]]; then
      echo "timeout ${max_wait}s for $name — killing"
      pkill -P "$pid" 2>/dev/null || true
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      break
    fi
  done
  wait "$pid" 2>/dev/null || true
  tail -15 "$out_dir/_tripo_log.txt" || true
}

echo "Balance before:"; tripo balance

# gap_edge
run_make gap_edge "$CONCEPTS/concept_gap_edge.png"
install_glb gap_edge obstacles || true

# bush_round
run_make bush_round "$CONCEPTS/concept_bush_round.png"
install_glb bush_round environment || true

# traffic_cone
run_make traffic_cone "$CONCEPTS/concept_traffic_cone.png"
install_glb traffic_cone obstacles || true

# pickup_glow_pad (text)
run_make pickup_glow_pad \
  "Low-poly stylized 3D game asset, soft pastel colors, rounded forms, minimal detail, clean silhouette, mobile game style like Capybara Rush, no realism, no text, no UI, isolated object, centered: flat circular pastel glow pad on ground, mint green outer ring, pale yellow middle, cream center, gentle raised rim, soft matte, soft lighting"
install_glb pickup_glow_pad props || true

echo "Balance after:"; tripo balance
echo "Done remaining batch."
ls -la "$MODELS/obstacles"/*.glb "$MODELS/environment"/bush_round.glb "$MODELS/props"/pickup_glow_pad.glb 2>&1 || true
