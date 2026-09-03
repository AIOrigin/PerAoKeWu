#!/usr/bin/env python3
"""Mild shrink for shipping sky/panorama PNGs. Backs up originals first."""
from __future__ import annotations

import shutil
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BACKUP = ROOT / "release" / "h5_handoff" / "_panorama_high_backup"
MAX_EDGE = 1280
MIN_BYTES = 700_000


def main() -> None:
	BACKUP.mkdir(parents=True, exist_ok=True)
	roots = [
		ROOT / "assets/maps/route_levels/runner_60s/backgrounds/panoramas",
		ROOT / "assets/maps/route_levels/models/backgrounds/panoramas",
	]
	n = 0
	for base in roots:
		if not base.is_dir():
			continue
		for path in sorted(base.glob("*.png")):
			if path.stat().st_size < MIN_BYTES:
				continue
			rel = path.relative_to(ROOT / "assets/maps/route_levels")
			bak = BACKUP / rel
			bak.parent.mkdir(parents=True, exist_ok=True)
			if not bak.is_file():
				shutil.copy2(path, bak)
			before = path.stat().st_size
			with Image.open(path) as im:
				im = im.convert("RGB") if im.mode not in ("RGB", "L") else im
				w, h = im.size
				m = max(w, h)
				if m > MAX_EDGE:
					scale = MAX_EDGE / float(m)
					nw, nh = max(1, int(round(w * scale))), max(1, int(round(h * scale)))
					im = im.resize((nw, nh), Image.Resampling.LANCZOS)
				else:
					nw, nh = w, h
				im.save(path, format="PNG", optimize=True, compress_level=9)
			after = path.stat().st_size
			print(f"OK {rel.as_posix()} | {w}x{h}->{nw}x{nh} | {before/1024/1024:.2f}->{after/1024/1024:.2f} MB")
			n += 1
	print(f"done {n} panoramas")


if __name__ == "__main__":
	try:
		main()
	except Exception as e:
		print(f"FAIL: {e}", file=sys.stderr)
		sys.exit(1)
