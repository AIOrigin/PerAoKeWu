#!/usr/bin/env python3
"""Align W1-W4 reservoir layouts with fork-on-straight design rules."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets/maps/route_levels/planets/data"


def fork_main_gap(zone: dict) -> tuple[float, float]:
    start = float(zone["distance"])
    length = float(zone.get("length", 88.0))
    decision_lead = max(length * 0.25, 20.0)
    keep_end = max(length * 0.06, 4.5)
    cut_s = start + decision_lead
    cut_e = start + length - keep_end
    return cut_s, cut_e


def in_any_fork_gap(dist: float, zones: list) -> bool:
    for z in zones:
        gs, ge = fork_main_gap(z)
        if gs < dist < ge:
            return True
    return False


def save(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
    print(f"  wrote {path.name}")


def fix_w1() -> None:
    path = DATA / "mission_reservoir_w1_obstacles.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    zones = data["junction_zones"]
    obs = []
    for o in data["obstacles"]:
        d = float(o["distance"])
        if in_any_fork_gap(d, zones):
            continue
        obs.append(o)
    # post-fork rhythm after gap (~200m)
    obs.extend([
        {"distance": 200.0, "lane": -1, "type": "jump"},
        {"distance": 214.0, "lane": 0, "type": "orb", "orb_size": "small"},
    ])
    obs.sort(key=lambda x: float(x["distance"]))
    data["obstacles"] = obs
    data["version"] = 2
    save(path, data)


def fix_w2() -> None:
    path = DATA / "mission_reservoir_w2_obstacles.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["track_segments"] = [
        {"length": 220.0, "turn": 0.0},
        {"length": 52.0, "turn": 1.5707963267948966},
        {"length": 270.0, "turn": 0.0},
        {"length": 48.0, "turn": -1.5707963267948966},
        {"length": 340.0, "turn": 0.0},
        {"length": 160.0, "turn": 0.0},
    ]
    data["junction_zones"] = [{
        "distance": 100.0,
        "length": 88.0,
        "spread": 17.0,
        "lane_a": 0,
        "label_a": "安全岔路",
        "effect_a": "repair",
        "lane_b": 2,
        "label_b": "速通岔路",
        "effect_b": "fast",
    }]
    data["sandstorm_zones"] = [
        {"start": 215.0, "length": 42.0, "dps": 9.0, "label": "沙尘暴", "lane_count": 3},
        {"start": 458.0, "length": 48.0, "dps": 10.5, "label": "沙尘暴", "lane_count": 3},
    ]
    zones = data["junction_zones"]
    kept = []
    for o in data["obstacles"]:
        d = float(o["distance"])
        if d < 95.0 or not in_any_fork_gap(d, zones):
            kept.append(o)
    # W1-style opening + construction kit teaching
    opening = [
        {"distance": 32.0, "lane": 0, "type": "jump", "overweight_tutorial": True},
        {"distance": 72.0, "lane": -1, "type": "slide"},
    ]
    # drop old crowded pre-fork set
    kept = [o for o in kept if float(o["distance"]) >= 200.0 or float(o["distance"]) in (32.0, 72.0)]
    post_fork = [
        {"distance": 210.0, "lane": 0, "type": "jump", "overweight_tutorial": True},
        {"distance": 232.0, "lane": -1, "type": "slide"},
    ]
    merged = opening + kept + post_fork
    seen = set()
    unique = []
    for o in sorted(merged, key=lambda x: (float(x["distance"]), x.get("type", ""))):
        key = (float(o["distance"]), o.get("lane", 0), o.get("type", ""))
        if key in seen:
            continue
        seen.add(key)
        unique.append(o)
    data["obstacles"] = unique
    # mark teaching jumps
    for o in data["obstacles"]:
        if o.get("type") == "jump" and float(o["distance"]) in (32.0, 64.0, 210.0, 410.0):
            o["overweight_tutorial"] = True
    data["version"] = 17
    save(path, data)


def fix_w3() -> None:
    path = DATA / "mission_reservoir_w3_obstacles.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["track_segments"] = [
        {"length": 340.0, "turn": 0.0},
        {"length": 46.0, "turn": 0.7853981633974483},
        {"length": 190.0, "turn": 0.0},
        {"length": 46.0, "turn": -1.5707963267948966},
        {"length": 190.0, "turn": 0.0},
        {"length": 46.0, "turn": 0.7853981633974483},
        {"length": 190.0, "turn": 0.0},
        {"length": 46.0, "turn": -0.7853981633974483},
        {"length": 54.0, "turn": 0.0},
    ]
    data["junction_zones"][0]["distance"] = 100.0
    data["junction_zones"][0]["length"] = 88.0
    data["junction_zones"][0]["spread"] = 17.0
    data["junction_zones"][1]["distance"] = 420.0
    data["junction_zones"][1]["length"] = 88.0
    data["junction_zones"][2]["length"] = 88.0
    data["sandstorm_zones"][0]["start"] = 215.0
    zones = data["junction_zones"]
    kept = []
    for o in data["obstacles"]:
        d = float(o["distance"])
        if in_any_fork_gap(d, zones):
            continue
        kept.append(o)
    # replace opening with construction-kit rhythm
    kept = [o for o in kept if float(o["distance"]) >= 255.0]
    opening = [
        {"distance": 32.0, "lane": 0, "type": "jump", "overweight_tutorial": True},
        {"distance": 72.0, "lane": -1, "type": "slide"},
    ]
    post = [
        {"distance": 210.0, "lane": 0, "type": "jump", "overweight_tutorial": True},
        {"distance": 248.0, "lane": -1, "type": "slide"},
    ]
    data["obstacles"] = sorted(opening + post + kept, key=lambda x: float(x["distance"]))
    data["side_runway_zones"][0]["start"] = 285.0
    data["side_runway_zones"][0]["length"] = 55.0
    data["version"] = 12
    save(path, data)


def fix_w4() -> None:
    path = DATA / "mission_reservoir_w4_obstacles.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["track_segments"] = [
        {"length": 200.0, "turn": 0.0},
        {"length": 38.0, "turn": 0.6981317007977318},
        {"length": 110.0, "turn": 0.0},
        {"length": 38.0, "turn": -0.6981317007977318},
        {"length": 110.0, "turn": 0.0},
        {"length": 38.0, "turn": 0.6981317007977318},
        {"length": 110.0, "turn": 0.0},
        {"length": 38.0, "turn": -0.6981317007977318},
        {"length": 140.0, "turn": 0.0},
    ]
    data["junction_zones"][0]["distance"] = 100.0
    data["junction_zones"][0]["length"] = 88.0
    data["junction_zones"][0]["spread"] = 17.0
    zones = data["junction_zones"]
    obs = []
    for o in data["obstacles"]:
        if o.get("type") in ("turn_left", "turn_right"):
            continue
        d = float(o["distance"])
        if in_any_fork_gap(d, zones):
            continue
        obs.append(o)
    opening = [
        {"distance": 32.0, "lane": 0, "type": "jump"},
        {"distance": 72.0, "lane": -1, "type": "slide"},
    ]
    post = [
        {"distance": 200.0, "lane": 0, "type": "slide"},
        {"distance": 228.0, "lane": 1, "type": "jump"},
        {"distance": 256.0, "lane": -1, "type": "train"},
    ]
    obs = [o for o in obs if float(o["distance"]) >= 200.0]
    data["obstacles"] = sorted(opening + post + obs, key=lambda x: float(x["distance"]))
    boosts = []
    for b in data.get("speed_boosts", []):
        d = float(b["distance"])
        if in_any_fork_gap(d, zones) or d < 115.0:
            continue
        boosts.append(b)
    boosts.append({"distance": 118.0, "lane": 1, "layer": 0})
    data["speed_boosts"] = sorted(boosts, key=lambda x: float(x["distance"]))
    data["version"] = 5
    save(path, data)


def main() -> None:
    print("Fixing reservoir layouts...")
    fix_w1()
    fix_w2()
    fix_w3()
    fix_w4()
    print("Done.")


if __name__ == "__main__":
    main()
