# -*- coding: utf-8 -*-
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GD = ROOT / "assets/maps/route_levels/runner_60s/runner_60s.gd"
TOOLS = Path(__file__).resolve().parent

text = GD.read_text(encoding="utf-8")

# 1) Fix corrupted _can_smash_obstacle header
text = text.replace(
    "func _can_smash_obstacle(obstacle: Dictionary) -> bool:\n(obstacle: Dictionary) -> bool:\n",
    "func _can_smash_obstacle(obstacle: Dictionary) -> bool:\n",
)

# 2) Insert smash helpers if missing
if "func _uses_smash_collision" not in text:
    block = (TOOLS / "uses_smash_block.txt").read_text(encoding="utf-8")
    block = block.replace(
        "return mid != \"\" and SMASH_MISSION_IDS.has(mid)",
        "if mid != \"\" and SMASH_MISSION_IDS.has(mid):\n\t\treturn true\n\treturn true",
    )
    block += """

func _refresh_smash_budget() -> void:
	_smash_obstacle_total = 0
	if not _uses_smash_collision():
		_smash_cargo_damage = SMASH_CARGO_BASE
		return
	for obstacle in obstacles:
		if typeof(obstacle) != TYPE_DICTIONARY:
			continue
		if _can_smash_obstacle(obstacle):
			_smash_obstacle_total += 1


func _cargo_fragility_mult() -> float:
	var explicit := float(mission.get("cargo_fragility", 0.0))
	if explicit > 0.01:
		return clampf(explicit, 0.65, 2.0)
	if _is_overweight_cargo():
		return 0.78
	return 1.0


func _cargo_damage_for_smash_obstacle(obstacle: Dictionary) -> float:
	var otype := String(obstacle.get("type", ""))
	var tier := float(SMASH_CARGO_TIER.get(otype, 1.0))
	if _is_large_smash_obstacle_entry(obstacle):
		tier *= 1.52
	elif otype == "orb":
		match String(obstacle.get("orb_tier", "")):
			"huge", "colossal":
				tier *= 1.48
			"large":
				tier *= 1.22
			"medium":
				tier *= 1.0
			_:
				tier *= 0.78
	elif otype == "meteorite":
		var radius := float(obstacle.get("meteor_radius", 0.0))
		if radius <= 0.01:
			radius = maxf(float(obstacle.get("span", 2.0)) * 0.5, 0.7)
		if radius >= 1.45:
			tier *= 1.42
		elif radius >= 1.1:
			tier *= 1.18
		elif radius >= 0.85:
			tier *= 1.0
		else:
			tier *= 0.82
	var dmg := SMASH_CARGO_BASE * tier * _cargo_fragility_mult() * Global.get_cargo_damage_multiplier()
	return clampf(dmg, SMASH_CARGO_DAMAGE_MIN, SMASH_CARGO_DAMAGE_MAX)


"""
    sfx = (TOOLS / "fn__smash_sfx_size_key.txt").read_text(encoding="utf-8")
    # only helper funcs before _shatter
    sfx_part = sfx.split("func _shatter_obstacle")[0].strip()
    insert_at = text.find("func _can_smash_obstacle")
    text = text[:insert_at] + block + "\n\n" + sfx_part + "\n\n\n" + text[insert_at:]

# 3) Replace _on_runner_strike with smash-aware version
strike_start = text.find("func _on_runner_strike(reason: String, obstacle: Dictionary = {}) -> void:")
strike_end = text.find("\nfunc _show_strike_warning", strike_start)
new_strike = '''func _on_runner_strike(reason: String, obstacle: Dictionary = {}) -> void:
	var obstacle_type := String(obstacle.get("type", ""))
	if obstacle_type == "main_block":
		_fail_into_pit("冲入主路熔岩坍塌带（需上侧墙绕过）")
		return
	strike_count += 1
	strike_recovery_timer = 0.0
	chaser_distance = maxf(chaser_distance - CHASER_HIT_PENALTY, CHASER_CATCH_DISTANCE)
	var rushing := _is_fork_rushing()
	var smash := _uses_smash_collision() and _can_smash_obstacle(obstacle)
	if smash:
		_smash_hit_count += 1
		_apply_smash_body_impact(_is_large_smash_obstacle_entry(obstacle))
		run_score += 18
		var cargo_dmg := _cargo_damage_for_smash_obstacle(obstacle)
		_apply_cargo_loss(cargo_dmg)
		var hp_lost := Global.apply_runner_hp_loss(SMASH_RUNNER_HP_DAMAGE)
		var impact_pos := player.global_position + Vector3(0.0, 1.7, 0.0) if player else Vector3.ZERO
		if _hit_feedback != null:
			_hit_feedback.apply_impact(
				impact_pos,
				HitFeedback.Intensity.HEAVY,
				cargo_dmg,
				"撞碎 %d/%d" % [_smash_hit_count, maxi(_smash_obstacle_total, 1)]
			)
		_shatter_obstacle(obstacle)
		if is_failed:
			return
		if chaser_distance <= CHASER_CATCH_DISTANCE and _chaser_enabled:
			_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)
			return
		var toast := "撞碎障碍 · 货物 -%0.0f%%（%d/%d）" % [
			cargo_dmg, _smash_hit_count, maxi(_smash_obstacle_total, 1)
		]
		if hp_lost > 0.001:
			toast += " · 体力 -%0.1f" % hp_lost
		_show_strike_warning(toast)
		return
	if rushing:
		speed_penalty_mult = 1.0
		speed_penalty_timer = 0.0
		run_score += 35
		camera_shake = maxf(camera_shake, 0.38)
	else:
		speed_penalty_mult = HIT_SLOW_FACTOR
		speed_penalty_timer = HIT_SLOW_DURATION
		_apply_obstacle_impact_block(obstacle)
	chaser_pulse = 1.0
	var tier := float(STRIKE_DAMAGE_TIER.get(obstacle_type, 1.0))
	var fragility := clampf(float(mission.get("cargo_fragility", 1.0)), 0.5, 2.5)
	var damage: float = float(LevelConfig.CARGO_DAMAGE_PER_HIT) * tier * Global.get_cargo_damage_multiplier() * fragility
	if rushing:
		damage *= FORK_RUSH_DAMAGE_MULT
	var intensity: int = HitFeedback.Intensity.MEDIUM
	if rushing:
		intensity = HitFeedback.Intensity.HEAVY
	elif tier >= 1.35:
		intensity = HitFeedback.Intensity.HEAVY
	elif tier <= 0.9:
		intensity = HitFeedback.Intensity.LIGHT
	_apply_cargo_loss(damage)
	var impact_pos2 := player.global_position + Vector3(0.0, 1.7, 0.0) if player else Vector3.ZERO
	if _hit_feedback != null:
		_hit_feedback.apply_impact(impact_pos2, intensity, damage, "飞驰撞击" if rushing else reason)
	else:
		camera_shake = maxf(camera_shake, 0.32 if rushing else 0.28)
	_pulse_obstacle_hit_visual(obstacle)
	if is_failed:
		return
	if chaser_distance <= CHASER_CATCH_DISTANCE:
		if _chaser_enabled:
			_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)
		return
	_show_strike_warning("飞驰连撞" if rushing else reason)


func _apply_obstacle_impact_block(obstacle: Dictionary) -> void:
	var obs_dist := float(obstacle.get("distance", track_distance)) + float(obstacle.get("move_offset", 0.0))
	var half := float(obstacle.get("half_depth", _obstacle_half_depth(String(obstacle.get("type", "")))))
	track_distance = minf(track_distance, obs_dist - half - HIT_BOUNCE_GAP)
	_hit_stun_timer = HIT_STUN_TIME
	_hitstop_timer = HIT_STOP_TIME
	_hit_recoil_timer = 0.42
	camera_shake = maxf(camera_shake, 0.4)
	if player != null:
		vertical_velocity = minf(vertical_velocity, -1.2)
	_sync_player_position()


func _apply_smash_body_impact(large: bool) -> void:
	speed_penalty_mult = 0.55 if large else 0.68
	speed_penalty_timer = 0.38 if large else 0.26
	_hit_stun_timer = 0.2 if large else 0.14
	_hitstop_timer = 0.1 if large else 0.07
	_hit_recoil_timer = 0.48 if large else 0.36
	body_squash_timer = maxf(body_squash_timer, 0.16 if large else 0.12)
	camera_shake = maxf(camera_shake, 0.58 if large else 0.46)
	if player != null:
		vertical_velocity = minf(vertical_velocity, -2.4 if large else -1.6)
	track_distance = maxf(track_distance - (0.55 if large else 0.32), 0.0)
	if player_body:
		player_body.scale = Vector3(1.18, 0.78, 1.12)
	_sync_player_position()


func _pulse_obstacle_hit_visual(obstacle: Dictionary) -> void:
	var node = obstacle.get("node", null)
	if node == null or not is_instance_valid(node) or not (node is Node3D):
		return
	var n := node as Node3D
	var base_scale := n.scale
	var tw := create_tween()
	tw.tween_property(n, "scale", base_scale * Vector3(1.12, 0.88, 1.12), 0.05)
	tw.tween_property(n, "scale", base_scale, 0.16)
'''
if strike_start >= 0 and strike_end > strike_start:
    text = text[:strike_start] + new_strike + text[strike_end:]

# 4) shatter chunks optional tiny flag
text = text.replace(
    "func _spawn_shatter_chunks(world_pos: Vector3, palette: Dictionary, forward: Vector3, count: int) -> void:",
    "func _spawn_shatter_chunks(world_pos: Vector3, palette: Dictionary, forward: Vector3, count: int, _tiny: bool = false) -> void:",
)

# 5) _build_content: register speed boosts + smash budget
old_tail = "\t_spawn_shield_crystals()\n\ttotal_collectibles = 0\n\tfor c in collectibles:\n\t\tif String(c.get(\"kind\", \"coin\")) == \"coin\":\n\t\t\ttotal_collectibles += 1\n"
new_tail = "\t_spawn_shield_crystals()\n\t_register_speed_boost_data()\n\t_register_bonus_fork_rewards()\n\t_materialize_registered_collectibles()\n\t_refresh_smash_budget()\n\ttotal_collectibles = 0\n\tfor c in collectibles:\n\t\tif String(c.get(\"kind\", \"coin\")) == \"coin\":\n\t\t\ttotal_collectibles += 1\n"
if old_tail in text:
    text = text.replace(old_tail, new_tail, 1)

# 6) speed boost + materialize helpers
if "func _speed_boosts_enabled" not in text:
    helpers = (TOOLS / "fn__register_shield_crystal_data.txt").read_text(encoding="utf-8")
    helpers = helpers.replace("func _register_shield_crystal_data", "func _register_shield_crystal_data_PLACEHOLDER")
    speed_helpers = '''

func _speed_boosts_enabled() -> bool:
	if bool(_mission_profile.get("timed_fail", false)):
		return true
	var mt := String(_mission_profile.get("id", mission.get("mission_type", "")))
	return mt == "emergency"


func _default_speed_boosts() -> Array:
	var out: Array = []
	var step := clampf(_track_length / 7.0, 70.0, 140.0)
	var d := step
	var i := 0
	while d < _track_length - 35.0:
		out.append({"distance": d, "lane": int(LANES[i % LANES.size()]), "layer": 0})
		d += step
		i += 1
	return out


func _speed_boost_collectible_y(boost_index: int, layer: int) -> float:
	return _layer_height(layer) + (BUFF_AIR_Y_OFFSET if boost_index % 2 == 0 else BUFF_GROUND_Y_OFFSET)


func _register_speed_boost_pickup() -> void:
	_speed_boost_timer = SPEED_BOOST_DURATION
	_speed_boost_cycle += 1
	camera_shake = maxf(camera_shake, 0.08)
	_show_gate_toast("加速靴 · 冲刺!")


func _materialize_registered_collectibles() -> void:
	for entry in collectibles:
		if entry.get("node") != null:
			continue
		var kind := String(entry.get("kind", "coin"))
		var lane := int(entry.get("lane", 0))
		var dist := float(entry.get("distance", 0.0))
		var y := float(entry.get("y", _layer_height(0)))
		var layer := int(entry.get("layer", 0))
		var fork_side := int(entry.get("fork_side", 0))
		var node: Node3D = null
		match kind:
			"coin":
				node = _make_collectible(lane, dist, y, layer)
			"speed_boost":
				node = _make_speed_boost(lane, dist, y, layer, fork_side)
			"shield_crystal":
				node = _make_shield_crystal(lane, dist, y, layer, fork_side)
			_:
				node = _make_collectible(lane, dist, y, layer)
		entry["node"] = node


func _world_on_path_forced_fork(distance: float, lateral: float, y: float, layer: int, fork_side: int = 0) -> Dictionary:
	return _world_on_path(distance, lateral, y, layer)


'''
    make_boost = (TOOLS / "L1071_0.txt").read_text(encoding="utf-8")
    insert_at = text.find("func _register_speed_boost_data()")
    if insert_at > 0:
        text = text[:insert_at] + speed_helpers + make_boost + "\n\n\n" + text[insert_at:]

# 7) Update register_speed_boost to use ensure gate boosts when enabled
old_reg = '''\tif items.is_empty():
\t\tif not _speed_boosts_enabled():
\t\t\treturn
\t\titems = _default_speed_boosts()
'''
new_reg = '''\tif items.is_empty():
\t\tif not _speed_boosts_enabled():
\t\t\titems = []
\t\telse:
\t\t\titems = _default_speed_boosts()
\tif _speed_boosts_enabled() and text.find("_ensure_train_gate_speed_boosts") >= 0:
\t\tpass
'''
# skip complex ensure - register via data only

# 8) Guard _process collectible rotation for null nodes
text = text.replace(
    "\t\tvar node := collectible[\"node\"] as Node3D\n\t\tnode.rotate_y(delta * 6.0)",
    "\t\tvar node := collectible[\"node\"] as Node3D\n\t\tif node == null or not is_instance_valid(node):\n\t\t\tcontinue\n\t\tnode.rotate_y(delta * 6.0)",
)

# 9) Guard _check_collectibles null node
text = text.replace(
    "\t\tvar node := collectible[\"node\"] as Node3D\n\t\tif player.global_position.distance_to(node.global_position) > 1.45:",
    "\t\tvar node := collectible[\"node\"] as Node3D\n\t\tif node == null or not is_instance_valid(node):\n\t\t\tcontinue\n\t\tif player.global_position.distance_to(node.global_position) > 1.45:",
)

GD.write_text(text, encoding="utf-8")
print("patched", GD, "lines", text.count("\n") + 1)
for needle in (
    "func _uses_smash_collision",
    "_refresh_smash_budget",
    "func _make_speed_boost",
    "_materialize_registered_collectibles",
    "var smash :=",
):
    print(" ", needle, "yes" if needle in text else "NO")
