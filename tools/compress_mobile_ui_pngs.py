#!/usr/bin/env python3
"""Mild mobile UI PNG shrink for shipping. Backs up originals first."""
from __future__ import annotations

import shutil
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
HOME = ROOT / "assets" / "maps" / "route_levels" / "mobile_home"
BACKUP = ROOT / "release" / "h5_handoff" / "_ui_png_high_backup"

# path-relative-to-mobile_home -> max long edge
RULES: list[tuple[str, int]] = [
	("ui_home/background.png", 1280),
	("ui_cargo_icons/", 512),
	("ui_character/", 1024),
	("story_intro/", 1280),
]


def max_edge_for(rel: str) -> int | None:
	rel_posix = rel.replace("\\", "/")
	for prefix, edge in RULES:
		if prefix.endswith("/") and rel_posix.startswith(prefix):
			return edge
		if rel_posix == prefix:
			return edge
	return None


def shrink(path: Path, max_edge: int) -> tuple[int, int, int, int]:
	with Image.open(path) as im:
		im = im.convert("RGBA") if im.mode in ("P", "LA") else im
		w, h = im.size
		m = max(w, h)
		if m <= max_edge and path.stat().st_size < 1_500_000:
			return w, h, w, h
		scale = min(1.0, max_edge / float(m))
		nw, nh = max(1, int(round(w * scale))), max(1, int(round(h * scale)))
		if (nw, nh) != (w, h):
			im = im.resize((nw, nh), Image.Resampling.LANCZOS)
		# Flatten huge transparent icons to RGB+A still, optimize
		im.save(path, format="PNG", optimize=True, compress_level=9)
		return w, h, nw, nh


def main() -> None:
	BACKUP.mkdir(parents=True, exist_ok=True)
	targets: list[tuple[Path, int]] = []
	for p in HOME.rglob("*.png"):
		rel = str(p.relative_to(HOME))
		edge = max_edge_for(rel)
		if edge is None:
			continue
		if p.stat().st_size < 800_000 and max(Image.open(p).size) <= edge:
			continue
		targets.append((p, edge))

	print(f"UI compress candidates: {len(targets)}")
	for path, edge in targets:
		rel = path.relative_to(HOME)
		bak = BACKUP / rel
		bak.parent.mkdir(parents=True, exist_ok=True)
		if not bak.is_file():
			shutil.copy2(path, bak)
		before = path.stat().st_size
		ow, oh, nw, nh = shrink(path, edge)
		after = path.stat().st_size
		print(
			f"OK {rel.as_posix()} | {ow}x{oh}->{nw}x{nh} | "
			f"{before/1024/1024:.2f}->{after/1024/1024:.2f} MB"
		)


if __name__ == "__main__":
	try:
		main()
	except Exception as e:
		print(f"FAIL: {e}", file=sys.stderr)
		sys.exit(1)
