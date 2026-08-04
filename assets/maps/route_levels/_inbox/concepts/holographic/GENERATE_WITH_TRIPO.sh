#!/usr/bin/env bash
set -euo pipefail
# Tripo image→3D for holographic runway obstacles (needs API credits + proxy for .ai)
export https_proxy="${https_proxy:-http://127.0.0.1:7890}"
export http_proxy="${http_proxy:-http://127.0.0.1:7890}"
export HTTPS_PROXY="${HTTPS_PROXY:-$https_proxy}"
export HTTP_PROXY="${HTTP_PROXY:-$http_proxy}"
export NODE_USE_ENV_PROXY=1

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONCEPTS="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/holographic_tripo"
mkdir -p "$OUT"

source ~/.nvm/nvm.sh
nvm use 22 >/dev/null

echo "Balance before:"
tripo balance

gen() {
  local name="$1" img="$2"
  echo "=== Generating $name ==="
  tripo make "$img" \
    --for game-mobile \
    --then texture \
    --name "holo_$name" \
    -o "$OUT/$name" \
    --yes --no-open
}

gen jump  "$CONCEPTS/obstacle_concept_jump.png"
gen slide "$CONCEPTS/obstacle_concept_slide.png"
gen dodge "$CONCEPTS/obstacle_concept_dodge.png"

echo "Done. Outputs under: $OUT"
tripo balance
