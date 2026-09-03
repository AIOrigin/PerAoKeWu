#!/usr/bin/env python3
"""Patch mission obstacle JSON track/junction layouts for variety (skip reservoir_w1)."""
import json
from pathlib import Path

DATA = Path(__file__).resolve().parents[1] / "assets/maps/route_levels/planets/data"

# Each entry: layout_id -> {track_segments, junction_zones, side_runway_zones?}
LAYOUTS = {
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
    },
    "mission_reservoir_w2": {
        "note": "W2 超重双击跳 · 长直→直角弯→中段分叉+侧墙",
        "track_segments": [
            {"length": 280.0, "turn": 0.0},
            {"length": 52.0, "turn": 1.5707963267948966},
            {"length": 270.0, "turn": 0.0},
            {"length": 48.0, "turn": -1.5707963267948966},
            {"length": 260.0, "turn": 0.0},
            {"length": 160.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 268.0,
                "length": 88.0,
                "spread": 17.0,
                "lane_a": 0,
                "label_a": "安全岔路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "速通岔路",
                "effect_b": "fast",
            }
        ],
    },
    "mission_reservoir_w3": {
        "note": "W3 长途 · 超长直道→三连弯→双晚段分叉",
        "track_segments": [
            {"length": 420.0, "turn": 0.0},
            {"length": 46.0, "turn": 0.7853981633974483},
            {"length": 190.0, "turn": 0.0},
            {"length": 46.0, "turn": -1.5707963267948966},
            {"length": 190.0, "turn": 0.0},
            {"length": 46.0, "turn": 0.7853981633974483},
            {"length": 190.0, "turn": 0.0},
            {"length": 46.0, "turn": -0.7853981633974483},
            {"length": 54.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 248.0,
                "length": 88.0,
                "spread": 17.0,
                "lane_a": 0,
                "label_a": "修复岔路",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "速通岔路",
                "effect_b": "fast",
            },
            {
                "distance": 520.0,
                "length": 88.0,
                "spread": 21.0,
                "lane_a": 0,
                "label_a": "左支缓冲",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "右支奖励",
                "effect_b": "bonus",
            },
        ],
    },
    "mission_reservoir_w4": {
        "note": "W4 紧急限时 · 蛇形弯+晚段奖励分叉（无早段分叉）",
        "track_segments": [
            {"length": 240.0, "turn": 0.0},
            {"length": 38.0, "turn": 0.6981317007977318},
            {"length": 110.0, "turn": 0.0},
            {"length": 38.0, "turn": -0.6981317007977318},
            {"length": 110.0, "turn": 0.0},
            {"length": 38.0, "turn": 0.6981317007977318},
            {"length": 110.0, "turn": 0.0},
            {"length": 38.0, "turn": -0.6981317007977318},
            {"length": 140.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 380.0,
                "length": 86.0,
                "spread": 18.0,
                "lane_a": 0,
                "label_a": "安全岔路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "奖励岔路",
                "effect_b": "bonus",
            }
        ],
    },
    "mission_medical_m1": {
        "note": "M1 医疗补给 · 长直热身→晚段分叉+侧墙抬升",
        "track_segments": [
            {"length": 360.0, "turn": 0.0},
            {"length": 40.0, "turn": 0.785},
            {"length": 200.0, "turn": 0.0},
            {"length": 40.0, "turn": -0.785},
            {"length": 180.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 380.0,
                "length": 86.0,
                "spread": 18.0,
                "lane_a": 0,
                "label_a": "薄雾支路",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "速通支路",
                "effect_b": "fast",
            }
        ],
        "side_runway_zones": [
            {
                "start": 520.0,
                "length": 76.0,
                "side": "outer",
                "fallback_side": 1,
                "lateral_offset": 7.2,
                "layer": 1,
                "entry_window": 11.0,
                "speed_mult": 1.05,
            }
        ],
    },
    "mission_medical_m2": {
        "note": "M2 极限护送 · 连续蛇形弯+侧墙（无车道分叉）",
        "track_segments": [
            {"length": 160.0, "turn": 0.0},
            {"length": 36.0, "turn": 0.872},
            {"length": 160.0, "turn": 0.0},
            {"length": 36.0, "turn": -0.872},
            {"length": 160.0, "turn": 0.0},
            {"length": 36.0, "turn": 0.698},
            {"length": 120.0, "turn": 0.0},
        ],
        "junction_zones": [],
        "side_runway_zones": [
            {
                "start": 280.0,
                "length": 72.0,
                "side": "outer",
                "fallback_side": -1,
                "lateral_offset": 7.0,
                "layer": 1,
                "entry_window": 10.0,
                "speed_mult": 1.04,
            }
        ],
    },
    "mission_medical_m3": {
        "note": "M3 长途毒雾 · 早弯→中段 Y 岔→双分叉",
        "track_segments": [
            {"length": 220.0, "turn": 0.0},
            {"length": 44.0, "turn": 0.785},
            {"length": 180.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 46.0, "angle_deg": 36.0},
            {"length": 200.0, "turn": 0.0},
            {"length": 44.0, "turn": -0.785},
            {"length": 200.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 228.0,
                "length": 90.0,
                "spread": 19.0,
                "lane_a": 0,
                "label_a": "薄雾支路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "速通支路",
                "effect_b": "fast",
            },
            {
                "distance": 480.0,
                "length": 88.0,
                "spread": 20.0,
                "lane_a": 0,
                "label_a": "左支缓冲",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "右支奖励",
                "effect_b": "bonus",
            },
        ],
    },
    "mission_medical_m4": {
        "note": "M4 双货紧急 · 长直→晚段 safe/bonus 分叉",
        "track_segments": [
            {"length": 260.0, "turn": 0.0},
            {"length": 38.0, "turn": 0.698},
            {"length": 200.0, "turn": 0.0},
            {"length": 38.0, "turn": -0.698},
            {"length": 180.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 300.0,
                "length": 82.0,
                "spread": 18.0,
                "lane_a": 0,
                "label_a": "安全岔路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "奖励岔路",
                "effect_b": "bonus",
            }
        ],
    },
    "mission_gate_d1": {
        "note": "D1 强行突破 · 超长直道+双弯（纯火力区，无分叉）",
        "track_segments": [
            {"length": 320.0, "turn": 0.0},
            {"length": 42.0, "turn": 0.785},
            {"length": 280.0, "turn": 0.0},
            {"length": 42.0, "turn": -0.785},
            {"length": 240.0, "turn": 0.0},
        ],
        "junction_zones": [],
    },
    "mission_gate_d2": {
        "note": "D2 侧墙突击 · 直角弯后中段分叉+侧墙",
        "track_segments": [
            {"length": 200.0, "turn": 0.0},
            {"length": 48.0, "turn": 1.047},
            {"length": 360.0, "turn": 0.0},
            {"length": 48.0, "turn": -1.047},
            {"length": 340.0, "turn": 0.0},
            {"length": 160.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 248.0,
                "length": 90.0,
                "spread": 18.0,
                "lane_a": 0,
                "label_a": "掩体支路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "突击支路",
                "effect_b": "fast",
            }
        ],
    },
    "mission_gate_d3": {
        "note": "D3 迷宫突破 · 早弯+中段 Y 岔+双分叉",
        "track_segments": [
            {"length": 180.0, "turn": 0.0},
            {"length": 46.0, "turn": 0.785},
            {"length": 220.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 50.0, "angle_deg": 40.0},
            {"length": 240.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 320.0,
                "length": 88.0,
                "spread": 19.0,
                "lane_a": 0,
                "label_a": "修复岔路",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "速通岔路",
                "effect_b": "fast",
            },
            {
                "distance": 560.0,
                "length": 86.0,
                "spread": 20.0,
                "lane_a": 0,
                "label_a": "左支缓冲",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "右支奖励",
                "effect_b": "bonus",
            },
        ],
    },
    "mission_gate_d4": {
        "note": "D4 限时清场 · 蛇形弯+侧墙（无早段分叉）",
        "track_segments": [
            {"length": 140.0, "turn": 0.0},
            {"length": 36.0, "turn": 0.698},
            {"length": 120.0, "turn": 0.0},
            {"length": 36.0, "turn": -0.698},
            {"length": 120.0, "turn": 0.0},
            {"length": 36.0, "turn": 0.698},
            {"length": 130.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 340.0,
                "length": 82.0,
                "spread": 17.0,
                "lane_a": 0,
                "label_a": "掩体岔路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "速通岔路",
                "effect_b": "fast",
            }
        ],
    },
    "mission_relay_e1": {
        "note": "E1 危机降临 · 超长直道+晚段分叉（无早段套路）",
        "track_segments": [
            {"length": 520.0, "turn": 0.0},
            {"length": 44.0, "turn": 0.785},
            {"length": 420.0, "turn": 0.0},
            {"length": 44.0, "turn": -0.785},
            {"length": 480.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 680.0,
                "length": 88.0,
                "spread": 20.0,
                "lane_a": 0,
                "label_a": "沙暴外缘",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "直穿核心",
                "effect_b": "fast",
            }
        ],
    },
    "mission_relay_e2": {
        "note": "E2 炼狱迷宫 · 中段分叉+Y 岔+末段双弯",
        "track_segments": [
            {"length": 240.0, "turn": 0.0},
            {"length": 44.0, "turn": 0.785},
            {"length": 220.0, "turn": 0.0},
            {"type": "y_fork", "branch_length": 52.0, "angle_deg": 40.0},
            {"length": 240.0, "turn": 0.0},
            {"length": 44.0, "turn": -0.698},
            {"length": 220.0, "turn": 0.0},
            {"length": 44.0, "turn": 0.698},
            {"length": 240.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 280.0,
                "length": 92.0,
                "spread": 19.0,
                "lane_a": 0,
                "label_a": "散热支路",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "速通支路",
                "effect_b": "fast",
            },
            {
                "distance": 720.0,
                "length": 88.0,
                "spread": 20.0,
                "lane_a": 0,
                "label_a": "冷却岔路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "高温直穿",
                "effect_b": "bonus",
            },
        ],
    },
    "mission_relay_e3": {
        "note": "E3 紧急运输 · 短程蛇形+中段安全分叉",
        "track_segments": [
            {"length": 110.0, "turn": 0.0},
            {"length": 36.0, "turn": 0.872},
            {"length": 110.0, "turn": 0.0},
            {"length": 36.0, "turn": -0.872},
            {"length": 110.0, "turn": 0.0},
            {"length": 36.0, "turn": 0.698},
            {"length": 120.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 380.0,
                "length": 78.0,
                "spread": 16.0,
                "lane_a": 0,
                "label_a": "安全支路",
                "effect_a": "safe",
                "lane_b": 2,
                "label_b": "速通支路",
                "effect_b": "fast",
            }
        ],
    },
    "mission_relay_e4": {
        "note": "E4 黎明线 · 长直+三连弯+晚段分叉",
        "track_segments": [
            {"length": 440.0, "turn": 0.0},
            {"length": 44.0, "turn": 0.785},
            {"length": 380.0, "turn": 0.0},
            {"length": 44.0, "turn": -0.785},
            {"length": 380.0, "turn": 0.0},
            {"length": 44.0, "turn": 0.785},
            {"length": 280.0, "turn": 0.0},
        ],
        "junction_zones": [
            {
                "distance": 560.0,
                "length": 86.0,
                "spread": 20.0,
                "lane_a": 0,
                "label_a": "风暴外缘",
                "effect_a": "repair",
                "lane_b": 2,
                "label_b": "风暴眼直穿",
                "effect_b": "fast",
            }
        ],
    },
}


def main() -> None:
    updated = []
    for layout_id, patch in LAYOUTS.items():
        path = DATA / f"{layout_id}_obstacles.json"
        if not path.exists():
            print(f"SKIP missing {path.name}")
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        if patch.get("note"):
            data["note"] = patch["note"]
        data["track_segments"] = patch["track_segments"]
        data["junction_zones"] = patch["junction_zones"]
        if "side_runway_zones" in patch:
            data["side_runway_zones"] = patch["side_runway_zones"]
        data["version"] = int(data.get("version", 1)) + 1
        path.write_text(json.dumps(data, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
        updated.append(layout_id)
    print(f"Updated {len(updated)} layouts: {', '.join(updated)}")


if __name__ == "__main__":
    main()
