#!/usr/bin/env bash
set -uo pipefail
# 竞速模式资产：飞船 / 开飞船卡皮巴拉 / 加速包
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

run_make() {
  local name="$1"
  shift
  local out_dir="$RAW/$name"
  mkdir -p "$out_dir"
  echo "=== $name ==="
  (
    tripo make "$@" --for game-mobile --then texture --name "capy_$name" -o "$out_dir" --yes --no-open
  ) >"$out_dir/_tripo_log.txt" 2>&1 &
  local pid=$!
  local waited=0
  local max_wait=480
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
      if [[ "$stable" -ge 20 ]] && grep -q "texture_model · success" "$out_dir/_tripo_log.txt" 2>/dev/null; then
        sleep 3
        if grep -q "downloading artifacts" "$out_dir/_tripo_log.txt" 2>/dev/null \
          && ! grep -qE "artifacts saved|artifact download failed|terminated" "$out_dir/_tripo_log.txt" 2>/dev/null; then
          echo "stopping hung download for $name"
          pkill -P "$pid" 2>/dev/null || true
          kill "$pid" 2>/dev/null || true
          wait "$pid" 2>/dev/null || true
          break
        fi
      fi
    fi
    if [[ "$waited" -ge "$max_wait" ]]; then
      echo "timeout ${max_wait}s for $name"
      pkill -P "$pid" 2>/dev/null || true
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      break
    fi
  done
  wait "$pid" 2>/dev/null || true
  tail -12 "$out_dir/_tripo_log.txt" || true
}

echo "Balance before:"; tripo balance

run_make spaceship "$CONCEPTS/concept_spaceship.png"
install_glb spaceship props || true

run_make capybara_pilot "$CONCEPTS/concept_capybara_pilot.png"
install_glb capybara_pilot characters || true

run_make boost_pack "$CONCEPTS/concept_boost_pack.png"
install_glb boost_pack props || true

echo "Balance after:"; tripo balance
echo "Done race assets."
ls -la "$MODELS/props/spaceship.glb" "$MODELS/characters/capybara_pilot.glb" "$MODELS/props/boost_pack.glb" 2>&1 || true
