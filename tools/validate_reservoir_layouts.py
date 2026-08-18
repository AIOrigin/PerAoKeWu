#!/usr/bin/env python3
from __future__ import annotations
import json
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / "assets/maps/route_levels/planets/data"


def fork_gap(z: dict) -> tuple[float, float]:
    s, L = float(z["distance"]), float(z.get("length", 88))
    return s + max(L * 0.25, 20.0), s + L - max(L * 0.06, 4.5)


def validate(name: str) -> list[str]:
    p = DATA / f"{name}_obstacles.json"
    d = json.loads(p.read_text(encoding="utf-8"))
    zones = d.get("junction_zones", [])
    segs = d.get("track_segments", [])
    issues: list[str] = []
    for o in d.get("obstacles", []):
        dist = float(o["distance"])
        for z in zones:
            gs, ge = fork_gap(z)
            if gs < dist < ge:
                issues.append(f"obstacle in fork gap: {dist}m {o.get('type')}")
    cum = 0.0
    for i, seg in enumerate(segs):
        seg_len = float(seg["length"])
        turn = float(seg.get("turn", 0))
        start = cum
        cum += seg_len
        if turn == 0.0:
            continue
        for z in zones:
            zs = float(z["distance"])
            ze = zs + float(z.get("length", 88))
            if ze > start and zs < cum:
                issues.append(f"fork {zs}-{ze:.0f} overlaps turn {start:.0f}-{cum:.0f}")
    obs = d.get("obstacles", [])
    if obs:
        first = obs[0]
        if float(first["distance"]) > 40:
            issues.append("first obstacle too far")
        types = [o.get("type") for o in obs[:3]]
        if name.endswith("w1") and types[:2] != ["jump", "slide"]:
            issues.append(f"W1 opening expected jump/slide, got {types[:2]}")
        if name.endswith("w2") and types[:2] != ["jump", "slide"]:
            issues.append(f"W2 opening expected jump/slide, got {types[:2]}")
    return issues


def main() -> None:
    ok = True
    for n in ["mission_reservoir_w1", "mission_reservoir_w2", "mission_reservoir_w3", "mission_reservoir_w4"]:
        issues = validate(n)
        status = "OK" if not issues else "FAIL"
        print(f"{n}: {status}")
        for i in issues:
            print(f"  - {i}")
            ok = False
    raise SystemExit(0 if ok else 1)


if __name__ == "__main__":
    main()
