# -*- coding: utf-8 -*-
"""Remove duplicate top-level func definitions; keep the last (most patched) version."""
from __future__ import annotations

import re
from pathlib import Path

GD = Path(__file__).resolve().parent.parent / "assets/maps/route_levels/runner_60s/runner_60s.gd"
text = GD.read_text(encoding="utf-8")
lines = text.splitlines(keepends=True)

# Split into segments: preamble + func blocks
func_pat = re.compile(r"^func \w+")
indices = [i for i, line in enumerate(lines) if func_pat.match(line)]

segments: list[tuple[str | None, list[str]]] = []
if indices[0] > 0:
    segments.append((None, lines[: indices[0]]))

for j, start in enumerate(indices):
    end = indices[j + 1] if j + 1 < len(indices) else len(lines)
    block = lines[start:end]
    m = re.match(r"^func (\w+)", block[0])
    name = m.group(1) if m else f"anon_{start}"
    segments.append((name, block))

# Keep last occurrence per func name
seen: set[str] = set()
keep = [True] * len(segments)
for i in range(len(segments) - 1, -1, -1):
    name, _ = segments[i]
    if name is None:
        continue
    if name in seen:
        keep[i] = False
    else:
        seen.add(name)

out: list[str] = []
removed = 0
for i, (name, block) in enumerate(segments):
    if keep[i]:
        out.extend(block)
    else:
        removed += 1
        print("removed duplicate:", name)

# Fix accidental duplicated single lines (e.g. two identical func headers in a row)
fixed: list[str] = []
prev = ""
for line in out:
    if line == prev and line.startswith("func "):
        continue
    fixed.append(line)
    prev = line

GD.write_text("".join(fixed), encoding="utf-8")
print(f"removed {removed} duplicate func blocks; lines {len(fixed)}")
