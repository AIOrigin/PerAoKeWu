# -*- coding: utf-8 -*-
"""Merge reconstructed2 + transcript patches + manual missing blocks into runner_60s.gd."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/maps/route_levels/runner_60s/runner_60s.gd.reconstructed2"
OUT = ROOT / "assets/maps/route_levels/runner_60s/runner_60s.gd"
TRANSCRIPT = Path(
    r"C:\Users\zy洋芋糍粑\.cursor\projects\c-Users-zy-Documents-PerAoKeWu\agent-transcripts"
    r"\62713607-708f-46bb-adbb-7584279feab9\62713607-708f-46bb-adbb-7584279feab9.jsonl"
)
TOOLS = Path(__file__).resolve().parent

CONST_BLOCK = """
const SLIDE_STAND_BODY_TOP := 1.18
const SLIDE_GATE_OUTER_EXTRA := 0.65
const SLIDE_GATE_INNER_BUFFER := 0.55
const SLIDE_GATE_MAX_OUTER_EXTRA := 2.6
const COIN_AIR_Y_OFFSET := 2.05
const COIN_GROUND_Y_OFFSET := 0.38
const COIN_AIR_PICKUP_MARGIN := 0.25
const COIN_AIR_MIN_JUMP_Y := 0.72
const BUFF_AIR_Y_OFFSET := 1.38
const BUFF_GROUND_Y_OFFSET := 0.72
const SPEED_BOOST_DURATION := 5.0
const SPEED_BOOST_MULT := 1.42
const SPEED_BOOST_SKILL_THRESHOLD := 5
const EMERGENCY_DASH_MULT := 1.55
const EMERGENCY_DASH_DURATION := 2.6
const EMERGENCY_DASH_HOLD := 0.35
# 选择门：右岔加速 / 左岔稳速护航
const FORK_RUSH_DURATION := 5.0
const FORK_RUSH_RAMP := 1.65
const FORK_RUSH_START_MULT := 1.12
const FORK_RUSH_MULT := 1.88
const FORK_SAFE_SPEED_MULT := 0.90
const FORK_RUSH_COIN_RADIUS := 2.4
const FORK_RUSH_HIT_IFRAME := 0.12
const FORK_RUSH_DAMAGE_MULT := 0.72
const WALL_RUN_SPEED_MULT := 1.08
# 终点冲刺路标
const FINISH_SPRINT_MULT := 1.85
const FINISH_SPRINT_DURATION := 7.5
# 普通撞障（非撞碎关）：顿帧 + 弹回
const HIT_STUN_TIME := 0.34
const HIT_STOP_TIME := 0.085
const HIT_BOUNCE_GAP := 0.55
const HIT_STUN_SPEED_MULT := 0.06
const AIR_LANE_CHANGE_MULT := 0.28
const AIR_LANE_CHANGE_RUSH_MULT := 0.12
const OVERWEIGHT_JUMP_SHORT_MULT := 0.50
const JUMP_DOUBLE_TAP_WINDOW := 0.62
const JUMP_DOUBLE_TAP_WINDOW_MOBILE := 0.85
# 全关卡默认：装备硬冲碎障
const SMASH_RUNNER_HP_DAMAGE := 0.45
const SMASH_LAYOUT_IDS := [
\t"mission_reservoir_base",
\t"mission_reservoir_w1",
\t"mission_reservoir_w2",
\t"mission_reservoir_w3",
\t"mission_reservoir_w4",
\t"mission_dome_h1",
\t"mission_dome_h2",
\t"mission_dome_h3",
\t"mission_dome_h4",
\t"mission_medical_m1",
\t"mission_medical_m2",
\t"mission_medical_m3",
\t"mission_medical_m4",
\t"mission_gate_d1",
\t"mission_gate_d2",
\t"mission_gate_d3",
\t"mission_gate_d4",
]
const SMASH_MISSION_IDS := [
\t"mission_reservoir_01",
\t"mission_reservoir_02",
\t"mission_reservoir_03",
\t"mission_reservoir_04",
\t"mission_medical_01",
\t"mission_medical_02",
\t"mission_medical_03",
\t"mission_medical_04",
\t"mission_gate_01",
\t"mission_gate_02",
\t"mission_gate_03",
\t"mission_gate_04",
\t"mission_dome_01",
\t"mission_dome_02",
\t"mission_dome_03",
\t"mission_dome_04",
]
""".strip(
    "\n"
)

VAR_BLOCK = """
var _speed_boost_timer := 0.0
var _speed_boost_cycle := 0
var _fork_rush_timer := 0.0
var _fork_rush_elapsed := 0.0
var _finish_sprint_timer := 0.0
var _finish_sprint_pads: Array = []
var _hit_stun_timer := 0.0
var _hitstop_timer := 0.0
var _hit_recoil_timer := 0.0
var _emergency_dash_charges := 0
var _emergency_dash_timer := 0.0
var _coin_pickup_burst_mesh: Mesh
""".strip(
    "\n"
)


def apply_transcript_patches(content: str) -> tuple[str, int, int]:
    applied = failed = 0
    with TRANSCRIPT.open(encoding="utf-8") as f:
        for line in f:
            if "runner_60s.gd" not in line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            for part in obj.get("message", {}).get("content", []):
                if part.get("type") != "tool_use" or part.get("name") != "StrReplace":
                    continue
                inp = part.get("input", {})
                if not str(inp.get("path", "")).endswith("runner_60s.gd"):
                    continue
                old = inp.get("old_string", "")
                new = inp.get("new_string", "")
                if not old or old == new:
                    continue
                if old in content:
                    content = content.replace(old, new, 1)
                    applied += 1
                else:
                    failed += 1
    return content, applied, failed


def dedupe_lines(content: str) -> str:
    lines = content.splitlines(keepends=True)
    out: list[str] = []
    prev: str | None = None
    for line in lines:
        if line == prev:
            continue
        out.append(line)
        prev = line
    return "".join(out)


def replace_function(content: str, name: str, new_body: str) -> str:
    pattern = rf"^func {re.escape(name)}\("
    m = re.search(pattern, content, re.M)
    if not m:
        raise RuntimeError(f"function not found: {name}")
    start = m.start()
    nxt = re.search(r"^func ", content[m.end() :], re.M)
    end = m.end() + nxt.start() if nxt else len(content)
    return content[:start] + new_body.rstrip() + "\n\n\n" + content[end:].lstrip("\n")


def insert_after_anchor(content: str, anchor: str, block: str, once_key: str) -> str:
    if once_key in content:
        return content
    idx = content.find(anchor)
    if idx == -1:
        raise RuntimeError(f"anchor not found: {anchor!r}")
    pos = idx + len(anchor)
    return content[:pos] + "\n" + block + content[pos:]


def insert_before_function(content: str, func_name: str, block: str) -> str:
    needle = f"func {func_name}"
    idx = content.find(needle)
    if idx == -1:
        raise RuntimeError(f"func not found for insert: {func_name}")
    if block.strip()[:40] in content[:idx]:
        return content
    return content[:idx] + block.rstrip() + "\n\n\n" + content[idx:]


def patch_check_collectibles(content: str) -> str:
    old = """\t\telse:
\t\t\tcollected_count += 1
\t\t\trun_score += int(LevelConfig.EMBER_COIN_VALUE)
"""
    new = """\t\telif kind == "speed_boost":
\t\t\t_register_speed_boost_pickup()
\t\t\t_spawn_collectible_pickup_fx(node.global_position, kind)
\t\telse:
\t\t\tcollected_count += 1
\t\t\trun_score += int(LevelConfig.EMBER_COIN_VALUE)
\t\t\t_spawn_collectible_pickup_fx(node.global_position, kind)
"""
    if old in content and "_spawn_collectible_pickup_fx" not in content.split("_check_collectibles")[1][:800]:
        content = content.replace(old, new, 1)
    return content


def patch_build_content(content: str) -> str:
    old = """\t_spawn_shield_crystals()
\ttotal_collectibles = 0
\tfor c in collectibles:
\t\tif String(c.get("kind", "coin")) == "coin":
\t\t\ttotal_collectibles += 1
"""
    new = """\t_register_shield_crystal_data()
\t_register_speed_boost_data()
\t_register_bonus_fork_rewards()
\ttotal_collectibles = 0
\tfor c in collectibles:
\t\tif String(c.get("kind", "coin")) == "coin":
\t\t\ttotal_collectibles += 1
\t_update_collectible_visibility()
\t_refresh_smash_budget()
"""
    if "_register_speed_boost_data()" not in content:
        if old in content:
            content = content.replace(old, new, 1)
        else:
            # already partially patched
            anchor = "\t_obstacle_scan_index = 0\n"
            extra = "\t_refresh_smash_budget()\n"
            if extra.strip() not in content and anchor in content:
                content = content.replace(anchor, anchor + extra, 1)
    return content


def main() -> None:
    content = SRC.read_text(encoding="utf-8")
    content, applied, failed = apply_transcript_patches(content)
    content = dedupe_lines(content)

    # constants / vars
    if "const SPEED_BOOST_MULT" not in content:
        content = insert_after_anchor(
            content,
            "const SLIDE_GATE_MODEL_BBOX_WIDTH := 1.0\n",
            CONST_BLOCK,
            "const SPEED_BOOST_MULT",
        )

    if "var _speed_boost_timer" not in content:
        content = insert_after_anchor(
            content,
            "var _coin_flash_tween: Tween\n",
            VAR_BLOCK,
            "var _speed_boost_timer",
        )

    if "func _mission_layout_id" not in content:
        alias = "func _mission_layout_id() -> String:\n\treturn _runner_layout_id()\n"
        m = re.search(r"func _runner_layout_id\(\) -> String:.*?\n\treturn layout_id\n", content, re.S)
        if m:
            content = content[: m.end()] + "\n" + alias + content[m.end() :]

    # _make_obstacle full dispatch
    make_obs = (TOOLS / "extracted_runner_snippets/_make_obstacle.txt").read_text(encoding="utf-8")
    if '"meteorite"' not in make_obs:
        make_obs = make_obs.replace(
            '\t\t"jump", "low_barrier":\n\t\t\t_build_jump_bar(root, item)',
            '\t\t"meteorite":\n\t\t\t_build_runway_meteorite(root, item)\n\t\t"jump", "low_barrier":\n\t\t\t_build_jump_bar(root, item)',
        )
    if "func _make_obstacle" in content and '"train":' not in content.split("func _make_obstacle", 1)[1][:1200]:
        make_main, _, make_wall = make_obs.partition("func _build_wall_face_obstacle")
        content = replace_function(content, "_make_obstacle", make_main.rstrip())
        if "func _build_wall_face_obstacle" not in content:
            wall_face = "func _build_wall_face_obstacle" + make_wall
            content = insert_before_function(content, "_build_jump_bar", wall_face)

    # smash + shatter block
    if "func _uses_smash_collision" not in content:
        smash_intro = (TOOLS / "uses_smash_block.txt").read_text(encoding="utf-8")
        smash_intro = smash_intro.replace(
            "return mid != \"\" and SMASH_MISSION_IDS.has(mid)",
            "if mid != \"\" and SMASH_MISSION_IDS.has(mid):\n\t\treturn true\n\treturn true",
        )
        smash_intro += "\n\n\nfunc _refresh_smash_budget() -> void:\n\t_smash_obstacle_total = 0\n\tif not _uses_smash_collision():\n\t\t_smash_cargo_damage = SMASH_CARGO_BASE\n\t\treturn\n\tfor obstacle in obstacles:\n\t\tif typeof(obstacle) != TYPE_DICTIONARY:\n\t\t\tcontinue\n\t\tif _can_smash_obstacle(obstacle):\n\t\t\t_smash_obstacle_total += 1\n"
        content = insert_before_function(content, "_on_runner_strike", smash_intro)

    l1366 = (TOOLS / "extracted_patches/L1366_new_string.txt").read_text(encoding="utf-8")
    l453_tail = (TOOLS / "extracted_patches/L453_new_string.txt").read_text(encoding="utf-8")
    if "func _shatter_obstacle" not in content:
        burst_start = l453_tail.find("func _spawn_shatter_burst")
        smash_block = l1366
        if burst_start >= 0:
            smash_block = l1366.rstrip() + "\n" + l453_tail[burst_start:]
        # ensure _can_smash at start if missing from l1366
        if "func _can_smash_obstacle" not in smash_block:
            can_smash = l453_tail.split("func _can_smash_obstacle")[1].split("func _is_large_smash_obstacle")[0]
            smash_block = "func _can_smash_obstacle(obstacle: Dictionary) -> bool:\n" + can_smash + "\nfunc _is_large_smash_obstacle" + l453_tail.split("func _is_large_smash_obstacle", 1)[1].split("func _shatter_obstacle")[0] + smash_block
        content = insert_before_function(content, "_on_runner_strike", smash_block)

    # coin pickup fx
    coin_patch = (TOOLS / "patch_L1289_4286.txt").read_text(encoding="utf-8")
    if "===NEW===" in coin_patch:
        coin_block = coin_patch.split("===NEW===", 1)[1].lstrip()
    else:
        coin_block = (TOOLS / "extract_L1289_0.txt").read_text(encoding="utf-8") if (TOOLS / "extract_L1289_0.txt").exists() else ""
    if coin_block and "func _spawn_coin_pickup_burst" not in content:
        content = insert_before_function(content, "_try_side_runway_entry", coin_block)

    # speed boost registration helpers
    if "func _register_speed_boost_data" not in content:
        reg = (TOOLS / "patch_L382.txt").read_text(encoding="utf-8")
        fork = (TOOLS / "patch_L1047.txt").read_text(encoding="utf-8")
        # take register_collectible + bonus from L1047
        extra = ""
        if "func _register_collectible_data" in fork:
            extra = fork.split("func _register_collectible_data", 1)[1]
            extra = "func _register_collectible_data" + extra
        helpers = reg + "\n\n\n" + extra
        content = insert_before_function(content, "_spawn_shield_crystals", helpers)

    content = patch_check_collectibles(content)
    content = patch_build_content(content)

    # remove duplicate PIT_LAVA preload line manually
    content = content.replace(
        'const PIT_LAVA_SHADER = preload("res://assets/maps/route_levels/runner_60s/pit_lava.gdshader")\nconst PIT_LAVA_SHADER = preload("res://assets/maps/route_levels/runner_60s/pit_lava.gdshader")\n',
        'const PIT_LAVA_SHADER = preload("res://assets/maps/route_levels/runner_60s/pit_lava.gdshader")\n',
    )

    OUT.write_text(content, encoding="utf-8")
    lines = content.count("\n") + 1
    print(f"Wrote {OUT} ({lines} lines)")
    print(f"Transcript patches: applied={applied}, failed={failed}")
    for needle in (
        "const SPEED_BOOST_MULT",
        "var _speed_boost_timer",
        "func _shatter_obstacle",
        "func _register_speed_boost_data",
        "func _spawn_coin_pickup_burst",
        "func _uses_smash_collision",
        "func _build_wall_face_obstacle",
        '"train":',
        '"meteorite":',
        "_refresh_smash_budget",
        "_spawn_collectible_pickup_fx",
    ):
        print(f"  {needle}: {'yes' if needle in content else 'NO'}")


if __name__ == "__main__":
    main()
