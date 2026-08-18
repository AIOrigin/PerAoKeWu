#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Audit runner road_style for all missions and layout JSON files."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets/maps/route_levels/planets/data"
PGD = ROOT / "assets/maps/route_levels/planets/planet_glass_desert.gd"


def parse_missions() -> list[dict]:
    text = PGD.read_text(encoding="utf-8")
    out: list[dict] = []
    for m in re.finditer(r'"mission_id":\s*"([^"]+)"', text):
        chunk = text[m.start() : m.start() + 1200]
        layout = re.search(r'"layout_id":\s*"([^"]+)"', chunk)
        textured = '"textured_ground": true' in chunk
        ef = re.search(r'"environment_factor":\s*"([^"]+)"', chunk)
        out.append(
            {
                "mission_id": m.group(1),
                "layout_id": layout.group(1) if layout else "",
                "textured_ground": textured,
                "environment_factor": ef.group(1) if ef else "",
            }
        )
    return out


def main() -> None:
    print("=== Official missions (planet_glass_desert.gd) ===")
    missing_json: list[tuple[str, str]] = []
    non_holo: list[tuple[str, str, str]] = []
    for item in parse_missions():
        mid = item["mission_id"]
        layout = item["layout_id"]
        jf = DATA / f"{layout}_obstacles.json"
        rs = "(no json)"
        if jf.exists():
            root = json.loads(jf.read_text(encoding="utf-8"))
            rs = str(root.get("road_style", "MISSING"))
            if rs != "holographic":
                non_holo.append((mid, layout, rs))
        else:
            missing_json.append((mid, layout))
        tex = "yes" if item["textured_ground"] else "no"
        print(f"  {mid:24} {layout:22} json={rs:12} side_sand={tex}")

    print("\nMissing layout JSON:", missing_json or "none")
    print("Non-holographic layouts:", non_holo or "none")

    print("\n=== All *_obstacles.json ===")
    for jf in sorted(DATA.glob("*_obstacles.json")):
        root = json.loads(jf.read_text(encoding="utf-8"))
        rs = str(root.get("road_style", "MISSING"))
        lid = str(root.get("layout_id", jf.stem.replace("_obstacles", "")))
        mark = "" if rs == "holographic" else " ***"
        print(f"  {jf.name:40} {lid:24} {rs}{mark}")


if __name__ == "__main__":
    main()
