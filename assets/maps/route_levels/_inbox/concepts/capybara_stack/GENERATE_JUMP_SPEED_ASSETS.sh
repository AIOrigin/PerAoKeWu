#!/usr/bin/env bash
set -uo pipefail
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
  [[ -z "${glb:-}" ]] && { echo "MISSING $name"; return 1; }
  mkdir -p "$MODELS/$sub"
  cp "$glb" "$MODELS/$sub/$name.glb"
  local prev; prev="$(find "$RAW/$name" -name 'preview.png' 2>/dev/null | head -1 || true)"
  [[ -n "${prev:-}" ]] && cp "$prev" "$MODELS/$sub/${name}_preview.png" || true
  echo "installed $MODELS/$sub/$name.glb"
}

run_make() {
  local name="$1"; shift
  local out_dir="$RAW/$name"
  mkdir -p "$out_dir"
  echo "=== $name ==="
  ( tripo make "$@" --for game-mobile --then texture --name "capy_$name" -o "$out_dir" --yes --no-open ) \
    >"$out_dir/_tripo_log.txt" 2>&1 &
  local pid=$! waited=0 last_size=0 stable=0
  while kill -0 "$pid" 2>/dev/null; do
    sleep 5; waited=$((waited+5))
    local glb; glb="$(find "$out_dir" -name 'model.glb' 2>/dev/null | head -1 || true)"
    if [[ -n "${glb:-}" ]]; then
      local sz; sz=$(wc -c < "$glb" | tr -d ' ')
      if [[ "$sz" -gt 100000 && "$sz" -eq "$last_size" ]]; then stable=$((stable+5)); else stable=0; last_size=$sz; fi
      if [[ "$stable" -ge 20 ]] && grep -q "texture_model · success" "$out_dir/_tripo_log.txt" 2>/dev/null; then
        sleep 3
        if grep -q "downloading artifacts" "$out_dir/_tripo_log.txt" 2>/dev/null \
          && ! grep -qE "artifacts saved|artifact download failed|terminated" "$out_dir/_tripo_log.txt" 2>/dev/null; then
          pkill -P "$pid" 2>/dev/null || true; kill "$pid" 2>/dev/null || true; break
        fi
      fi
    fi
    if [[ "$waited" -ge 480 ]]; then
      pkill -P "$pid" 2>/dev/null || true; kill "$pid" 2>/dev/null || true; break
    fi
  done
  wait "$pid" 2>/dev/null || true
  tail -8 "$out_dir/_tripo_log.txt" || true
}

echo "Balance before:"; tripo balance
run_make step_platform "$CONCEPTS/concept_step_platform.png"
install_glb step_platform environment || true
run_make speed_orb "$CONCEPTS/concept_speed_orb.png"
install_glb speed_orb props || true
# speed_lane 用程序化条带更适合沿弯道铺；概念图保留备查
echo "Balance after:"; tripo balance
ls -la "$MODELS/environment/step_platform.glb" "$MODELS/props/speed_orb.glb" 2>&1 || true
