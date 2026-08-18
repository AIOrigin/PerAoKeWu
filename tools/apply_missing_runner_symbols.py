#!/usr/bin/env python3
"""Insert missing vars/funcs into runner_60s.gd from extracted transcript snippets."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "assets/maps/route_levels/runner_60s/runner_60s.gd"
EXTRACTED1 = ROOT / "tools/extracted_funcs.gd"
EXTRACTED2 = ROOT / "tools/extracted_funcs2.gd"


def extract_func(text: str, name: str) -> str | None:
    m = re.search(rf"func {re.escape(name)}\(.*?(?=\nfunc |\Z)", text, re.S)
    return m.group(0).strip() if m else None


def main() -> None:
    content = RUNNER.read_text(encoding="utf-8")
    e1 = EXTRACTED1.read_text(encoding="utf-8")
    e2 = EXTRACTED2.read_text(encoding="utf-8")

    # --- constants / vars ---
    if "const FINISH_GATE_BEFORE_END" not in content:
        content = content.replace(
            "const FINISH_SPRINT_DURATION := 7.5",
            "const FINISH_SPRINT_DURATION := 7.5\nconst FINISH_GATE_BEFORE_END := 14.0\nconst FINISH_PORTAL_DEPTH := 4.0",
        )

    var_block = """var _hit_fov_punch := 0.0
var _speed_feel_punch := 0.0
var _run_body_pitch := 0.0
var _speed_rumble := 0.0"""
    if "_speed_feel_punch" not in content:
        content = content.replace(
            "var _wall_boost_fx_timer := 0.0",
            f"{var_block}\nvar _wall_boost_fx_timer := 0.0",
        )

    if "_finish_line_distance" not in content:
        content = content.replace(
            "var _track_length := DEFAULT_TRACK_LENGTH",
            "var _track_length := DEFAULT_TRACK_LENGTH\nvar _finish_line_distance := 0.0",
        )

    for ow_var in (
        "var _overweight_intro_pending := false",
        "var _overweight_run_tip_shown := false",
        "var _overweight_jump_armed := false",
        "var _overweight_short_jump_timer := 0.0",
    ):
        name = ow_var.split()[1]
        if name not in content:
            content = content.replace(
                "var _finish_line_distance := 0.0",
                f"var _finish_line_distance := 0.0\n{ow_var}",
                1,
            )

    # --- _make_trail_particles: assign _trail_process_mat ---
    content = content.replace(
        "\tmaterial.color = Color(1.0, 0.62, 0.18, 0.55)\n\tparticles.process_material = material\n\treturn particles\n\nfunc _make_landing_particles",
        "\tmaterial.color = Color(1.0, 0.62, 0.18, 0.55)\n\tparticles.process_material = material\n\t_trail_process_mat = material\n\treturn particles\n\nfunc _make_landing_particles",
    )

    # --- dedupe _build_runner particle init (keep first block only) ---
    dup_block = """
\tfoot_spark_particles = _make_foot_spark_particles()
\tplayer.add_child(foot_spark_particles)
\tbody_spark_particles = _make_body_spark_particles()
\tplayer.add_child(body_spark_particles)
\t_build_ember_flame_aura()
\tjump_streak_particles = _make_jump_streak_particles()
\tplayer.add_child(jump_streak_particles)
\twall_boost_particles = _make_wall_boost_particles()
\tplayer.add_child(wall_boost_particles)"""
    while content.count(dup_block) > 1:
        content = content.replace(dup_block, "", 1)

    # --- set finish line in _build_finish_gate ---
    if "_finish_line_distance = maxf" not in content:
        content = content.replace(
            "func _build_finish_gate() -> void:\n\tvar hearth_placed",
            "func _build_finish_gate() -> void:\n\t_finish_line_distance = maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)\n\tvar hearth_placed",
        )

    # --- insert missing functions ---
    func_names = [
        "_is_overweight_cargo",
        "_coin_collectible_y",
        "_collectible_pickup_fx_config",
        "_finish_arrival_distance",
        "_finish_outpost_title_en",
        "_spawn_pickup_particle_burst",
        "_make_pickup_particle_mesh",
        "_execute_jump",
        "_emit_jump_takeoff_fx",
        "_set_trail_color",
        "_pulse_wall_boost_particles",
        "_make_jump_streak_particles",
        "_make_wall_boost_particles",
        "_wall_entry_jump_ready",
        "_apply_mission_environment",
        "_apply_settlement_button_style",
        "_attach_wall_edge_soft_glow",
        "_make_wall_guide_arrow",
        "_shield_crystal_allowed_at",
        "_add_train_wave_blade",
        "_update_train_blade_gates",
        "_pre_run_briefing_text",
        "_update_meteor_fall_roll",
        "_try_start_emergency_dash",
        "_style_buff_label",
        "_try_attach_gate_boosts_for_train",
        "_resolve_runner_road_style",
        "_update_shield_energy_drain",
        "_update_midground_visibility",
    ]

    coin_y = """func _coin_collectible_y(air: bool, layer: int, wall_lane: int = 0) -> float:
\tif layer == WALL_RUN_LAYER:
\t\tvar base_y := _wall_lane_height_for_lane_value(wall_lane)
\t\treturn base_y + (0.92 if air else 0.0)
\treturn _layer_height(layer) + (COIN_AIR_Y_OFFSET if air else COIN_GROUND_Y_OFFSET)"""

    execute_jump = """func _execute_jump(jump_speed: float) -> void:
\tvertical_velocity = jump_speed
\t_end_slide()
\tbody_squash_timer = 0.16
\tcamera_shake = maxf(camera_shake, 0.12)
\t_jump_fx_timer = 0.45
\t_emit_landing_particles()
\t_emit_jump_takeoff_fx()
\t_notify_coach_action("jump")
\tif _coach_tip_key == "overweight_jump" and _is_overweight_cargo() and jump_speed >= JUMP_SPEED * 0.9:
\t\t_complete_coach_tip("overweight_jump")"""

    blocks: list[str] = []
    defined = set(re.findall(r"^func (\w+)\(", content, re.M))
    for name in func_names:
        if name in defined:
            continue
        if name == "_coin_collectible_y":
            blocks.append(coin_y)
            continue
        if name == "_execute_jump":
            blocks.append(execute_jump)
            continue
        src = extract_func(e1, name) or extract_func(e2, name)
        if src:
            blocks.append(src)
        else:
            print(f"WARN: could not find {name}")

    if blocks:
        anchor = "func _emit_landing_particles"
        idx = content.find(anchor)
        if idx == -1:
            raise SystemExit("anchor _emit_landing_particles not found")
        insert = "\n\n\n".join(blocks) + "\n\n\n"
        content = content[:idx] + insert + content[idx:]

    RUNNER.write_text(content, encoding="utf-8")
    lines = content.count("\n") + 1
    defined_after = set(re.findall(r"^func (\w+)\(", content, re.M))
    called = set(re.findall(r"\b(_\w+)\(", content))
    missing = sorted(n for n in called if n.startswith("_") and n not in defined_after)
    print(f"Patched {RUNNER.name} ({lines} lines)")
    print(f"Inserted {len(blocks)} functions")
    print(f"Still missing funcs: {len(missing)}")
    for n in missing:
        print(f"  {n}")


if __name__ == "__main__":
    main()
