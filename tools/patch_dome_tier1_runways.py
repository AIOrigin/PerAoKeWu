#!/usr/bin/env python3
"""Patch 居民穹顶 H1–H4：混合第一档四类跑道（断裂/错位/坍塌压迫/弯道+侧墙）。"""
import json
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / "assets/maps/route_levels/planets/data"

# 四类跑道标签（写入 note，便于关卡编辑对照）
# A 断裂 static gap (main_block + jump)
# B 错位 y_fork + junction + side_runway
# C 坍塌压迫 speed_boost + 大 main_block
# D 弯道链 arc chain + side_runway

DOME_PATCHES = {
    "mission_dome_h1": {
        "note": "H1 能源补给 · A小断层→D弯道侧墙绕弧→B Y岔错位→C末段坍塌冲刺",
        "track_segments": [
            {"length": 200.0, "turn": 0.0},
            {"length": 38.0, "turn": 0.610865238198753},
            {"length": 110.0, "turn": 0.0},
            {"length": 38.0, "turn": -0.610865238198753},
            {"length": 130.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 50.0, "angle_deg": 38.0},
            {"length": 200.0, "turn": 0.0},
            {"length": 42.0, "turn": 0.7853981633974483},
            {"length": 160.0, "turn": 0.0},
            {"length": 42.0, "turn": -0.7853981633974483},
            {"length": 140.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 362.0,
                "length": 92.0,
                "spread": 20.0,
                "lane_a": 0,
                "label_a": "缓冲岔路",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "奖励岔路",
                "effect_b": "bonus",
            }
        ],
        "side_runway_zones": [
            {
                "start": 118.0,
                "length": 72.0,
                "side": "outer",
                "fallback_side": -1,
                "lateral_offset": 6.8,
                "layer": 1,
                "entry_window": 12.0,
                "speed_mult": 1.04,
            },
            {
                "start": 388.0,
                "length": 78.0,
                "side": "outer",
                "fallback_side": 1,
                "lateral_offset": 7.2,
                "layer": 1,
                "entry_window": 11.0,
                "speed_mult": 1.05,
            },
        ],
        "speed_boosts": [
            {"distance": 582.0, "lane": 0, "layer": 0},
            {"distance": 622.0, "lane": 1, "layer": 0},
        ],
        "obstacle_patches": [
            {"distance": 108.0, "lane": 0, "layer": 0, "target_layer": 1, "type": "ramp"},
            {"distance": 152.0, "lane": -1, "type": "jump"},
            {"distance": 168.0, "half_depth": 13.0, "lane": 0, "type": "main_block"},
            {"distance": 184.0, "lane": 1, "type": "jump"},
            {"distance": 648.0, "half_depth": 22.0, "lane": 0, "type": "main_block"},
        ],
        "remove_obstacle_distances": {228.0, 236.0, 242.0, 248.0, 254.0, 260.0, 266.0, 272.0, 278.0, 284.0, 290.0, 296.0, 302.0, 308.0, 314.0, 320.0, 326.0, 332.0},
    },
    "mission_dome_h2": {
        "note": "H2 防御抢修 · D双弯侧墙绕坑→A双断层→B速通分叉错位→C坑前加速",
        "track_segments": [
            {"length": 180.0, "turn": 0.0},
            {"length": 48.0, "turn": 0.8726646259971648},
            {"length": 200.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 46.0, "angle_deg": 36.0},
            {"length": 180.0, "turn": 0.0},
            {"length": 48.0, "turn": -0.8726646259971648},
            {"length": 240.0, "turn": 0.0},
            {"length": 160.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 278.0,
                "length": 94.0,
                "spread": 21.0,
                "lane_a": 0,
                "label_a": "安全岔路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "速通岔路",
                "effect_b": "fast",
            }
        ],
        "side_runway_zones": [
            {
                "start": 228.0,
                "length": 92.0,
                "side": "outer",
                "fallback_side": 1,
                "lateral_offset": 7.4,
                "layer": 1,
                "entry_window": 12.0,
                "speed_mult": 1.06,
            },
            {
                "start": 508.0,
                "length": 76.0,
                "side": "outer",
                "fallback_side": -1,
                "lateral_offset": 7.0,
                "layer": 1,
                "entry_window": 11.0,
                "speed_mult": 1.04,
            },
        ],
        "speed_boosts": [
            {"distance": 232.0, "lane": 0, "layer": 0},
            {"distance": 478.0, "lane": 1, "layer": 0},
        ],
        "obstacle_patches": [
            {"distance": 148.0, "lane": 0, "type": "jump"},
            {"distance": 162.0, "half_depth": 12.0, "lane": 0, "type": "main_block"},
            {"distance": 178.0, "lane": -1, "type": "jump"},
            {"distance": 192.0, "half_depth": 11.0, "lane": 0, "type": "main_block"},
            {"distance": 208.0, "lane": 1, "type": "jump"},
            {"distance": 218.0, "lane": 0, "layer": 0, "target_layer": 1, "type": "ramp"},
            {"distance": 492.0, "lane": 0, "type": "jump"},
            {"distance": 508.0, "half_depth": 14.0, "lane": 0, "type": "main_block"},
            {"distance": 528.0, "lane": -1, "type": "jump"},
        ],
        "remove_obstacle_distances": {228.0},
    },
    "mission_dome_h3": {
        "note": "H3 长途能源 · B双Y岔+双分叉错位→A三连断层→D末段侧墙弧→C冲刺过坑",
        "track_segments": [
            {"length": 180.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 48.0, "angle_deg": 36.0},
            {"length": 150.0, "turn": 0.0},
            {"length": 40.0, "turn": 0.7853981633974483},
            {"length": 170.0, "turn": 0.0},
            {"length": 40.0, "turn": -0.7853981633974483},
            {"length": 170.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 44.0, "angle_deg": 34.0},
            {"length": 190.0, "turn": 0.0},
            {"length": 36.0, "turn": 0.6981317007977318},
            {"length": 120.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 168.0,
                "length": 90.0,
                "spread": 19.0,
                "lane_a": 0,
                "label_a": "修复岔路",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "速通岔路",
                "effect_b": "fast",
            },
            {
                "distance": 508.0,
                "length": 88.0,
                "spread": 22.0,
                "lane_a": 0,
                "label_a": "左支缓冲",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "右支奖励",
                "effect_b": "bonus",
            },
        ],
        "side_runway_zones": [
            {
                "start": 238.0,
                "length": 68.0,
                "side": "outer",
                "fallback_side": 1,
                "lateral_offset": 7.2,
                "layer": 1,
                "entry_window": 14.0,
                "blocker_profile": "light",
            },
            {
                "start": 518.0,
                "length": 68.0,
                "side": "outer",
                "fallback_side": -1,
                "lateral_offset": 7.2,
                "layer": 1,
                "entry_window": 14.0,
                "blocker_profile": "light",
            },
            {
                "start": 668.0,
                "length": 72.0,
                "side": "outer",
                "fallback_side": 1,
                "lateral_offset": 7.0,
                "layer": 1,
                "entry_window": 12.0,
                "speed_mult": 1.05,
            },
        ],
        "speed_boosts": [
            {"distance": 688.0, "lane": 0, "layer": 0},
            {"distance": 712.0, "lane": -1, "layer": 0},
        ],
        "obstacle_patches": [
            {"distance": 228.0, "lane": 0, "layer": 0, "target_layer": 1, "type": "ramp"},
            {"distance": 382.0, "lane": -1, "type": "jump"},
            {"distance": 396.0, "half_depth": 11.0, "lane": 0, "type": "main_block"},
            {"distance": 412.0, "lane": 1, "type": "jump"},
            {"distance": 426.0, "half_depth": 10.0, "lane": 0, "type": "main_block"},
            {"distance": 442.0, "lane": -1, "type": "jump"},
            {"distance": 728.0, "half_depth": 24.0, "lane": 0, "type": "main_block"},
        ],
        "remove_obstacle_distances": {452.0, 478.0, 504.0},
    },
    "mission_dome_h4": {
        "note": "H4 限时冲刺 · D蛇形弯链→A弯中双断层→B Y岔+分叉错位→C加速闯坍塌",
        "track_segments": [
            {"length": 150.0, "turn": 0.0},
            {"length": 34.0, "turn": 0.6981317007977318},
            {"length": 110.0, "turn": 0.0},
            {"length": 34.0, "turn": -0.6981317007977318},
            {"length": 110.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 42.0, "angle_deg": 32.0},
            {"length": 120.0, "turn": 0.0},
            {"length": 34.0, "turn": 0.6981317007977318},
            {"length": 110.0, "turn": 0.0},
            {"length": 34.0, "turn": -0.6981317007977318},
            {"length": 120.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 308.0,
                "length": 86.0,
                "spread": 18.0,
                "lane_a": 0,
                "label_a": "缓冲岔路",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "速通岔路",
                "effect_b": "fast",
            }
        ],
        "side_runway_zones": [
            {
                "start": 168.0,
                "length": 58.0,
                "side": "outer",
                "fallback_side": -1,
                "lateral_offset": 6.6,
                "layer": 1,
                "entry_window": 10.0,
                "speed_mult": 1.07,
            },
            {
                "start": 298.0,
                "length": 68.0,
                "side": "outer",
                "fallback_side": 1,
                "lateral_offset": 6.8,
                "layer": 1,
                "entry_window": 10.0,
                "speed_mult": 1.08,
            },
        ],
        "speed_boosts": [
            {"distance": 18.0, "lane": 0, "layer": 0},
            {"distance": 96.0, "lane": 1, "layer": 0},
            {"distance": 172.0, "lane": 0, "layer": 0},
            {"distance": 252.0, "lane": -1, "layer": 0},
            {"distance": 348.0, "lane": 1, "layer": 0},
            {"distance": 420.0, "lane": 0, "layer": 0},
            {"distance": 496.0, "lane": -1, "layer": 0},
            {"distance": 528.0, "lane": 0, "layer": 0},
            {"distance": 568.0, "lane": 1, "layer": 0},
            {"distance": 628.0, "lane": 0, "layer": 0},
        ],
        "obstacle_patches": [
            {"distance": 158.0, "lane": 0, "layer": 0, "target_layer": 1, "type": "ramp"},
            {"distance": 198.0, "lane": 0, "type": "jump", "overweight_tutorial": True},
            {"distance": 212.0, "half_depth": 10.0, "lane": 0, "type": "main_block"},
            {"distance": 228.0, "lane": 1, "type": "jump", "overweight_tutorial": True},
            {"distance": 268.0, "lane": -1, "type": "jump", "overweight_tutorial": True},
            {"distance": 282.0, "half_depth": 11.0, "lane": 0, "type": "main_block"},
            {"distance": 298.0, "lane": 0, "layer": 0, "target_layer": 1, "type": "ramp"},
            {"distance": 542.0, "half_depth": 18.0, "lane": 0, "type": "main_block"},
        ],
        "remove_obstacle_distances": set(),
    },
}


def merge_obstacles(existing: list, patches: list, remove_dist: set) -> list:
    patch_main_dists = {
        round(float(p.get("distance", 0)), 2)
        for p in patches
        if p.get("type") == "main_block"
    }
    filtered = []
    for o in existing:
        d = round(float(o.get("distance", 0.0)), 2)
        if d in remove_dist:
            continue
        if o.get("type") == "main_block" and d in patch_main_dists:
            continue
        filtered.append(o)
    merged = filtered + patches
    merged.sort(key=lambda x: float(x.get("distance", 0.0)))
    return merged


def main() -> None:
    updated = []
    for layout_id, patch in DOME_PATCHES.items():
        path = DATA / f"{layout_id}_obstacles.json"
        if not path.exists():
            print(f"SKIP missing {path.name}")
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        data["note"] = patch["note"]
        data["track_segments"] = patch["track_segments"]
        data["junction_zones"] = patch["junction_zones"]
        data["side_runway_zones"] = patch["side_runway_zones"]
        if patch.get("speed_boosts"):
            data["speed_boosts"] = patch["speed_boosts"]
        data["obstacles"] = merge_obstacles(
            data.get("obstacles", []),
            patch.get("obstacle_patches", []),
            patch.get("remove_obstacle_distances", set()),
        )
        data["version"] = int(data.get("version", 1)) + 1
        path.write_text(json.dumps(data, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
        updated.append(layout_id)
    print(f"Patched dome tier-1 runways: {', '.join(updated)}")


if __name__ == "__main__":
    main()
