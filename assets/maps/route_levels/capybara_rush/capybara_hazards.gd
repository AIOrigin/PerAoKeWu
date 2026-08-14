class_name CapybaraHazards
extends RefCounted

## 障碍生成、运动更新与碰撞检测（从 capybara_rush.gd 拆出）
## Host 为 capybara_rush 根节点，需提供 _world、_path_place、关卡配置等。

const LANE_COUNT := 3
const LANE_WIDTH := 1.08
const ROAD_HALF_W := 2.05
const ROAD_THICKNESS := 0.18
const ROAD_SURFACE_Y := ROAD_THICKNESS * 0.5
const RUN_SPEED := 12.0
const JUMP_CLEAR_Y := 0.55
const BLOCK_SIZE := 0.95
const BLOCK_GAP := 0.06
const ROTATOR_PILLAR_CELL := BLOCK_SIZE
const ROTATOR_PILLAR_ROWS := 4
const ROTATOR_PILLAR_COUNT := 4
const ROTATOR_CENTER_FRUIT_COUNT := 4
const HAZARD_CROSS_TYPE_GAP := 16.0
const PACING_BEAT_SEC_MIN := 1.25
const PACING_BEAT_SEC_MAX := 1.62
const PACING_RECOVERY_SEC_MIN := 1.85
const PACING_RECOVERY_SEC_MAX := 2.25
const PENDULUM_TRIPLE_COUNT := 3
const PENDULUM_TRIPLE_SPACING := 4.6
const PENDULUM_TRIPLE_HANG := 3.6
const PENDULUM_TRIPLE_PIVOT_Y := 4.4
const FIRE_GATE_GAP_WIDTH := LANE_WIDTH * 1.02
const FIRE_GATE_SLIDE_AMP := LANE_WIDTH * 1.05
const FIRE_GATE_WALL_H := 1.08
const FIRE_GATE_HALF_LEN := 0.88
const FIRE_GATE_SLIDE_SPEED := 1.65
const ROTATOR_ARENA_RADIUS := 3.2
const ROTATOR_ANG_SPEED := 1.05
const TRAMPOLINE_APPROACH_MARGIN := 24.0
const PICKUP_RADIUS_X := 1.15

var items: Array[Dictionary] = []
var _host: Node


func _init(host: Node) -> void:
	_host = host


func clear() -> void:
	items.clear()


func spawn_all() -> void:
	_spawn_hazards()


func spawn_center_rotators() -> void:
	_spawn_center_rotators()


func update(delta: float) -> void:
	_update_moving_hazards(delta)


static func hit_top(h: Dictionary) -> float:
	return float(h.get("hit_top", h.get("clear_y", JUMP_CLEAR_Y)))


func overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	return _hazard_overlap(h, progress, lane_x, air_y)


func clear_near_cliff_approach(tramp_dist: float, lane: int) -> void:
	var lateral := _host._lane_to_x(lane)
	var keep: Array[Dictionary] = []
	for h in items:
		var hd := float(h.get("dist", -999.0))
		var hl := float(h.get("lateral", 0.0))
		if absf(hd - tramp_dist) <= TRAMPOLINE_APPROACH_MARGIN:
			if absf(hl - lateral) <= LANE_WIDTH * 1.35:
				var node: Node3D = h.get("node")
				if node != null and is_instance_valid(node):
					node.queue_free()
				continue
		keep.append(h)
	items = keep


func _hazard_rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_host._level_cfg.get("hazard_seed", 1))
	return rng


func _run_speed_for_pacing() -> float:
	return maxf(float(_host._level_cfg.get("run_speed", RUN_SPEED)), 5.0)


func _pacing_spacing(rng: RandomNumberGenerator, recovery: bool = false, after_hard: bool = false) -> float:
	var spd := _run_speed_for_pacing()
	var sec_lo := float(_host._level_cfg.get("pacing_beat_sec_min", PACING_BEAT_SEC_MIN))
	var sec_hi := float(_host._level_cfg.get("pacing_beat_sec_max", PACING_BEAT_SEC_MAX))
	if recovery:
		sec_lo = float(_host._level_cfg.get("pacing_recovery_sec_min", PACING_RECOVERY_SEC_MIN))
		sec_hi = float(_host._level_cfg.get("pacing_recovery_sec_max", PACING_RECOVERY_SEC_MAX))
	elif after_hard:
		sec_lo = maxf(sec_lo, PACING_BEAT_SEC_MIN + 0.12)
		sec_hi = maxf(sec_hi, PACING_BEAT_SEC_MAX + 0.18)
	var d := _level_difficulty()
	var scale := 1.0 - float(maxi(d - 3, 0)) * 0.035
	scale = maxf(scale, 0.88)
	return rng.randf_range(sec_lo, sec_hi) * spd * scale


func _pacing_spacing_from_cfg(rng: RandomNumberGenerator, spacing_cfg: Variant, recovery: bool = false) -> float:
	if typeof(spacing_cfg) == TYPE_ARRAY:
		var a: Array = spacing_cfg
		if a.size() >= 2:
			var lo := float(a[0])
			var hi := float(a[1])
			if recovery:
				lo *= 1.28
				hi *= 1.35
			return rng.randf_range(lo, hi) * _run_speed_for_pacing()
	if typeof(spacing_cfg) == TYPE_FLOAT or typeof(spacing_cfg) == TYPE_INT:
		var sec := float(spacing_cfg)
		if recovery:
			sec *= 1.3
		return sec * _run_speed_for_pacing()
	return _pacing_spacing(rng, recovery, false)


func _sync_swing_phase(dist: float, swing_speed: float, offset: float = 0.0) -> float:
	## 按跑速预估到达时刻，让摆锤/扫臂在过点时偏向可通行相位
	var t := maxf(dist - 28.0, 0.0) / _run_speed_for_pacing()
	var raw := swing_speed * t + offset
	return round(raw / PI) * PI + offset * 0.25


func _resolve_hazard_spawn_z(z: float, kind: String, half_len: float) -> float:
	var pos := z
	for _attempt in 12:
		if _host._near_cliff_zone(pos, TRAMPOLINE_APPROACH_MARGIN):
			pos += 8.0
			continue
		if not _hazard_zone_conflicts(pos, kind, half_len):
			return pos
		pos = _next_gap_after_conflict(pos, kind, half_len)
	return pos


func _next_gap_after_conflict(z: float, kind: String, half_len: float) -> float:
	var best := z + 8.0
	var group := _hazard_kind_group(kind)
	for h in items:
		var other_kind := String(h.get("kind", ""))
		if _hazard_kind_group(other_kind) == group:
			continue
		var hd := float(h.get("dist", -9999.0))
		var other_half := float(h.get("half_len", 1.0))
		var need := HAZARD_CROSS_TYPE_GAP + half_len + other_half
		if absf(z - hd) < need:
			best = maxf(best, hd + need)
	return best


func _setpiece_meta(setpiece_id: String) -> Dictionary:
	match setpiece_id:
		"recovery", "rest":
			return {"kind": "stack", "half_len": 0.0, "hard": false}
		"stair_weave", "stair_ascend", "stair_wave":
			return {"kind": "stack", "half_len": 1.25, "hard": false}
		"hurdle_single", "hurdle_wide", "stripe_single":
			return {"kind": "stack", "half_len": 0.55, "hard": false}
		"combo_stair_hurdle":
			return {"kind": "stack", "half_len": 5.8, "hard": false}
		"sweeper_single":
			return {"kind": "moving", "half_len": 3.8, "hard": true}
		"sweeper_duel":
			return {"kind": "moving", "half_len": 4.4, "hard": true}
		"pendulum_triple":
			return {"kind": "moving", "half_len": PENDULUM_TRIPLE_SPACING + 1.5, "hard": true}
		"swing_hoop", "spin_ring":
			return {"kind": "moving", "half_len": 1.05, "hard": true}
		"l_gate":
			return {"kind": "moving", "half_len": 2.6, "hard": true}
		"fire_gate":
			return {"kind": "moving", "half_len": FIRE_GATE_HALF_LEN, "hard": true}
		_:
			return {"kind": "stack", "half_len": 1.25, "hard": false}


func _difficulty_setpiece_pool() -> Array[String]:
	var d := _level_difficulty()
	match d:
		1:
			return ["stair_weave", "hurdle_single", "stair_weave", "stripe_single", "combo_stair_hurdle"]
		2:
			return ["stair_ascend", "hurdle_wide", "combo_stair_hurdle", "sweeper_single", "stair_weave"]
		3:
			return ["stair_weave", "sweeper_duel", "fire_gate", "pendulum_triple", "combo_stair_hurdle", "spin_ring"]
		4:
			return ["pendulum_triple", "fire_gate", "swing_hoop", "sweeper_duel", "l_gate", "stair_ascend"]
		_:
			return ["fire_gate", "pendulum_triple", "sweeper_duel", "l_gate", "swing_hoop", "combo_stair_hurdle"]


func _spawn_setpiece(setpiece_id: String, z: float, rng: RandomNumberGenerator) -> Dictionary:
	var meta := _setpiece_meta(setpiece_id)
	if setpiece_id in ["recovery", "rest"]:
		return meta
	var max_rows := int(_host._level_cfg.get("max_stair_rows", 3))
	var d := _level_difficulty()
	var spd := 1.35 + float(d) * 0.26
	var swing := float(_host._level_cfg.get("showcase_swing_speed", 0.9))
	match setpiece_id:
		"stair_weave":
			_spawn_stair_hazard_row(z, [1, 2, 1], rng)
		"stair_ascend":
			_spawn_stair_hazard_row(z, [1, 2, mini(3, max_rows)], rng)
		"stair_wave":
			_spawn_stair_hazard_row(z, [2, 1, 2], rng)
		"hurdle_single":
			_spawn_hurdle_bar_at(z, 1, 0.95)
		"hurdle_wide":
			_spawn_hurdle_bar_at(z, 2, 1.05)
		"stripe_single":
			_spawn_stripe_barrier(z, rng.randi_range(0, LANE_COUNT - 1))
		"combo_stair_hurdle":
			_spawn_stair_hazard_row(z, [1, 2, 1], rng)
			_spawn_hurdle_bar_at(z + 9.0, 2, 1.0)
		"sweeper_single":
			_spawn_sweeper_at(
				z,
				-1.0 if rng.randf() > 0.5 else 1.0,
				spd * 0.9,
				_sync_swing_phase(z, spd * 0.9, float(rng.randi_range(0, 3)) * 0.4),
				true
			)
		"sweeper_duel":
			_spawn_sweeper_pair(z, spd, _sync_swing_phase(z, spd, 0.0), rng)
		"pendulum_triple":
			_spawn_pendulum_triple_at(z, _sync_swing_phase(z, spd * 0.85, 0.0), spd * 0.85, 0.72)
		"swing_hoop":
			_spawn_swing_hoop_at(z, _sync_swing_phase(z, spd * 0.8, 0.5), spd * 0.8, 0.65)
		"spin_ring":
			_spawn_spin_ring_at(z, rng.randi_range(0, LANE_COUNT - 1), spd)
		"l_gate":
			_spawn_l_gate_at(
				z,
				-1.0 if rng.randf() > 0.5 else 1.0,
				spd * 0.78,
				_sync_swing_phase(z, spd * 0.78, 0.0)
			)
		"fire_gate":
			_spawn_fire_sliding_gate_at(
				z,
				spd * 0.72,
				_sync_swing_phase(z, spd * 0.72, float(rng.randi_range(0, 2)) * PI * 0.33)
			)
		_:
			_spawn_stair_hazard_row(z, [1, 2, 1], rng)
	return meta


func _spawn_segmented_hazards() -> void:
	var segments: Variant = _host._level_cfg.get("hazard_segments", [])
	if typeof(segments) != TYPE_ARRAY or (segments as Array).is_empty():
		push_warning("segmented level missing hazard_segments: %s" % _host._level_cfg.get("id", 0))
		return
	var rng := _hazard_rng()
	var z := 28.0
	var track_end := _host._track_len() - 36.0
	var need_recovery := false
	var beat_i := 0
	for seg_v in segments as Array:
		var seg: Dictionary = seg_v if typeof(seg_v) == TYPE_DICTIONARY else {}
		var seg_len := float(seg.get("length", 90.0))
		var seg_end := minf(z + seg_len, track_end)
		var beats: Array = seg.get("beats", ["stair_weave"])
		if beats.is_empty():
			beats = ["stair_weave"]
		var spacing_cfg: Variant = seg.get("spacing_sec", 1.45)
		var b_idx := 0
		while z < seg_end - 12.0:
			if _host._near_cliff_zone(z, TRAMPOLINE_APPROACH_MARGIN):
				z += 8.0
				continue
			if need_recovery:
				z += _pacing_spacing_from_cfg(rng, spacing_cfg, true)
				need_recovery = false
				beat_i += 1
				continue
			var sid := String(beats[b_idx % beats.size()])
			b_idx += 1
			if sid in ["recovery", "rest"]:
				z += _pacing_spacing_from_cfg(rng, spacing_cfg, true)
				beat_i += 1
				continue
			var meta := _setpiece_meta(sid)
			z = _resolve_hazard_spawn_z(z, String(meta.get("kind", "stack")), float(meta.get("half_len", 1.25)))
			var info := _spawn_setpiece(sid, z, rng)
			if bool(info.get("hard", false)):
				need_recovery = true
			z += _pacing_spacing_from_cfg(rng, spacing_cfg, false)
			beat_i += 1
		z = maxf(z, seg_end)


func _spawn_hazards() -> void:
	## 按关卡 hazard_pattern / max_stair_rows 刷怪；断崖附近留空
	var pattern := String(_host._level_cfg.get("hazard_pattern", "theme_exam"))
	if pattern == "segmented":
		_spawn_segmented_hazards()
		_spawn_extra_stair_hazards(_hazard_rng())
		return
	var z := 28.0
	var i := 0
	var track_len := _host._track_len()
	var max_rows := int(_host._level_cfg.get("max_stair_rows", 3))
	var rng := _hazard_rng()
	var spawn_kind := "moving" if pattern == "sweeper_gauntlet" else "stack"
	var need_recovery := false
	while z < track_len - 36.0:
		if _host._near_cliff_zone(z, TRAMPOLINE_APPROACH_MARGIN):
			z += 8.0
			continue
		if pattern == "difficulty_mix" and need_recovery:
			z += _pacing_spacing(rng, true, false)
			need_recovery = false
			i += 1
			continue
		var beat_info := {"half_len": 1.25, "kind": spawn_kind, "hard": false}
		if pattern == "difficulty_mix":
			var pools := _difficulty_setpiece_pool()
			var sid := String(pools[i % pools.size()])
			var meta := _setpiece_meta(sid)
			z = _resolve_hazard_spawn_z(z, String(meta.get("kind", spawn_kind)), float(meta.get("half_len", 1.25)))
			beat_info = _spawn_setpiece(sid, z, rng)
			if bool(beat_info.get("hard", false)):
				need_recovery = true
		else:
			if _hazard_zone_conflicts(z, spawn_kind, 1.25):
				z = _resolve_hazard_spawn_z(z, spawn_kind, 1.25)
				continue
		match pattern:
			"tutorial":
				if i % 2 == 0:
					_spawn_stripe_barrier(z, i % LANE_COUNT)
				else:
					_spawn_stair_hazard_row(z, [1, 2, 1], rng, "dice")
				z += rng.randf_range(30.0, 38.0)
			"stripe_weave":
				_spawn_stair_hazard_row(
					z,
					[1, 2, 1] if i % 2 == 0 else [2, 1, 2],
					rng
				)
				z += rng.randf_range(26.0, 34.0)
			"stair_intro":
				var asc := i % 2 == 0
				var hi := mini(max_rows, 3)
				var heights: Array = [1, 2, hi] if asc else [hi, 2, 1]
				_spawn_stair_hazard_row(z, heights, rng)
				z += rng.randf_range(26.0, 32.0)
			"full_row_low":
				_spawn_stack_lane_wall(z, 1, rng)
				z += rng.randf_range(28.0, 34.0)
			"ice_stair":
				var hi_i := mini(maxi(max_rows, 2), 4)
				var heights_i: Array = [1, 2, hi_i] if i % 2 == 0 else [hi_i, 2, 1]
				_spawn_stair_hazard_row(z, heights_i, rng, "ice")
				if i % 3 == 2:
					_spawn_stack_lane_wall(z + 10.0, 1, rng, "ice")
				z += rng.randf_range(24.0, 32.0)
			"dice_weave":
				# 换道阶梯：矮→高或高→矮，整组堆在一起
				var hi_w := mini(maxi(max_rows, 2), 4)
				var heights_w: Array = [1, 2, hi_w] if i % 2 == 0 else [hi_w, 2, 1]
				_spawn_stair_hazard_row(z, heights_w, rng, "dice")
				z += rng.randf_range(26.0, 34.0)
			"dice_wall":
				_spawn_stack_lane_wall(z, clampi(maxi(max_rows - 1, 1), 1, 3), rng, "dice")
				z += rng.randf_range(26.0, 34.0)
			"intro_cliff", "theme_exam":
				_spawn_mixed_hazard_beat(z, i, max_rows, rng)
				z += rng.randf_range(24.0, 32.0)
			"pasture_weave":
				_spawn_stripe_barrier(z, 0)
				_spawn_stripe_barrier(z + 6.0, 2)
				if i % 2 == 0:
					_spawn_stair_hazard_row(z + 12.0, [1, 2, 1], rng)
				z += rng.randf_range(26.0, 32.0)
			"pasture_dense":
				_spawn_stripe_barrier(z, 1)
				_spawn_stripe_barrier(z + 5.0, 0)
				_spawn_stripe_barrier(z + 5.0, 2)
				z += rng.randf_range(22.0, 28.0)
			"sakura_pickups":
				_spawn_mixed_hazard_beat(z, i, max_rows, rng)
				z += rng.randf_range(22.0, 28.0)
			"sakura_tall":
				var tall := maxi(max_rows, 4)
				var heights2: Array = [1, 2, tall] if i % 2 == 0 else [tall, 2, 1]
				_spawn_stair_hazard_row(z, heights2, rng)
				z += rng.randf_range(24.0, 30.0)
			"neon_dense":
				_spawn_stripe_barrier(z, i % LANE_COUNT)
				_spawn_stripe_barrier(z + 5.0, (i + 1) % LANE_COUNT)
				_spawn_stripe_barrier(z + 10.0, (i + 2) % LANE_COUNT)
				z += rng.randf_range(20.0, 26.0)
			"double_cliff", "neon_gauntlet", "volcano_gauntlet":
				_spawn_mixed_hazard_beat(z, i, max_rows, rng)
				z += rng.randf_range(20.0, 26.0)
			"volcano_intro":
				_spawn_stair_hazard_row(z, [1, 2, mini(3, max_rows)], rng)
				z += rng.randf_range(24.0, 30.0)
			"sweeper_gauntlet":
				# Tall Man Run 式旋转扫臂：左右交替 / 对打，夹少量阶梯加压
				var ang_spd := float(_host._level_cfg.get("sweeper_speed", 2.15))
				if i % 3 == 2:
					_spawn_sweeper_pair(z, ang_spd, i * 0.55, rng)
					if i % 6 == 5:
						_spawn_stair_hazard_row(z + 11.0, [1, 2, 1], rng)
				elif i % 2 == 0:
					_spawn_sweeper_at(z, -1, ang_spd, float(i) * 0.7, true)
				else:
					_spawn_sweeper_at(z, 1, ang_spd, float(i) * 0.7 + PI * 0.35, true)
				z += rng.randf_range(18.0, 24.0)
			"difficulty_mix":
				pass  # 已在 match 外处理
			"showcase":
				_spawn_showcase_beat(z, i, rng)
				z += _pacing_spacing(rng, false, false)
			"test_all":
				_spawn_test_all_beat(z, i, rng)
				z += _pacing_spacing(rng, false, false) * 1.12
			_:
				_spawn_mixed_hazard_beat(z, i, max_rows, rng)
				z += _pacing_spacing(rng, false, false)
		if pattern == "difficulty_mix":
			z += _pacing_spacing(rng, false, bool(beat_info.get("hard", false)))
		i += 1
	# 不再散落刷胡萝卜/骰子；统一用阶梯组补充
	_spawn_extra_stair_hazards(rng)


func _spawn_mixed_hazard_beat(z: float, i: int, max_rows: int, rng: RandomNumberGenerator) -> void:
	match i % 4:
		0:
			var asc := (i / 4) % 2 == 0
			var hi := clampi(max_rows, 2, 4)
			var heights: Array = [1, 2, hi] if asc else [hi, 2, 1]
			_spawn_stair_hazard_row(z, heights, rng)
		1:
			# 交错矮柱阶梯（同距不同高），而不是散落单件
			_spawn_stair_hazard_row(z, [2, 1, 2], rng)
		2:
			if i % 8 < 4:
				_spawn_stripe_barrier(z, 0)
				_spawn_stripe_barrier(z, 2)
				_spawn_stack_column(z, 1, 1, _pick_stack_kind(rng), rng)
			else:
				_spawn_stair_hazard_row(z, [1, 3, 1], rng)
		3:
			_spawn_stair_hazard_row(z, _pick_stair_heights(clampi(int(_host._level_cfg.get("full_row_max_rows", 1)) + 1, 2, 3), i), rng)


func _spawn_center_rotators() -> void:
	## 圆形平台：倒 L 双锤 / 四立柱交替出现
	_host._rotator_arenas.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_host._level_cfg.get("hazard_seed", 1)) + 80331
	var spd := float(_host._level_cfg.get("rotator_speed", ROTATOR_ANG_SPEED))
	spd = clampf(spd, 0.65, 1.45)
	var z := 52.0
	var i := 0
	var track_len := _host._track_len()
	while z < track_len - 30.0:
		if _host._near_cliff_zone(z, TRAMPOLINE_APPROACH_MARGIN):
			z += 10.0
			continue
		var arena_half := ROTATOR_ARENA_RADIUS * 0.98
		z = _resolve_hazard_spawn_z(z, "center_rotator", arena_half)
		var dir := 1.0 if i % 2 == 0 else -1.0
		if i % 2 == 0:
			_spawn_center_rotator_l_at(z, spd * dir, float(i) * 0.85)
		else:
			_spawn_center_rotator_pillars_at(z, spd * dir, float(i) * 0.85, rng)
		z += rng.randf_range(56.0, 68.0)
		i += 1


func _block_lane_cell_w() -> float:
	## 一列占满车道宽，相邻列只留 BLOCK_GAP，视觉贴合
	return LANE_WIDTH - BLOCK_GAP


func _spawn_stair_hazard_row(
	dist: float,
	heights: Array,
	rng: RandomNumberGenerator = null,
	kind_override: String = ""
) -> void:
	## 三车道阶梯：每车道堆叠若干层骰子/胡萝卜/方块
	var local_rng := rng
	if local_rng == null:
		local_rng = RandomNumberGenerator.new()
		local_rng.seed = int(_host._level_cfg.get("hazard_seed", 1)) + int(dist * 17.0)
	var kind := kind_override if not kind_override.is_empty() else _pick_stack_kind(local_rng)
	for lane in mini(heights.size(), LANE_COUNT):
		var rows := maxi(int(heights[lane]), 1)
		_spawn_stack_column(dist, lane, rows, kind, local_rng)


func _pick_stack_kind(rng: RandomNumberGenerator) -> String:
	var forced := String(_host._level_cfg.get("stair_kind", ""))
	if forced in ["dice", "carrot", "blocks", "ice"]:
		return forced
	if _host._is_frost_theme():
		return "ice"
	if bool(_host._level_cfg.get("dice_hazards", true)) or _level_uses_dice():
		return "dice"
	return "dice" if rng.randf() > 0.2 else "carrot"


func _spawn_stack_lane_wall(dist: float, rows: int, rng: RandomNumberGenerator, kind_override: String = "") -> void:
	## 不再刷 [n,n,n] 封死墙：改成高低交错，至少一道可绕/可跳矮柱
	var h := clampi(rows, 1, 4)
	var gap_lane := int(dist * 0.13) % LANE_COUNT
	var heights: Array = []
	for lane in LANE_COUNT:
		if lane == gap_lane:
			heights.append(1)
		elif (lane + gap_lane) % 2 == 0:
			heights.append(h)
		else:
			heights.append(maxi(h - 1, 1))
	_spawn_stair_hazard_row(dist, heights, rng, kind_override)


func _pick_stair_heights(max_rows: int, style: int = 0) -> Array:
	## 经典阶梯：一头高一头矮，中间过渡，避免三列同高
	var hi := clampi(max_rows, 2, 4)
	match style % 4:
		0:
			return [1, 2, hi]
		1:
			return [hi, 2, 1]
		2:
			return [2, 1, hi]
		_:
			return [1, hi, 2]


func _spawn_stack_column(
	dist: float,
	lane: int,
	rows: int,
	kind: String,
	rng: RandomNumberGenerator
) -> void:
	## 单车道垂直堆叠；整柱算一个障碍，撞到按层数掉叠
	rows = clampi(rows, 1, 6)
	match kind:
		"dice":
			_spawn_dice_stack_column(dist, lane, rows, rng)
		"ice":
			_spawn_ice_stack_column(dist, lane, rows, rng)
		"blocks":
			_spawn_block_hazard_at(dist, lane, 1, rows, _block_lane_cell_w())
		_:
			_spawn_carrot_stack_column(dist, lane, rows, rng)


func _spawn_extra_stair_hazards(rng: RandomNumberGenerator) -> void:
	## 在主 pattern 空隙补少量阶梯组（不再散落单件）
	var pattern := String(_host._level_cfg.get("hazard_pattern", ""))
	# 已是密集阶梯的 pattern 不再追加，避免过挤
	if pattern in ["tutorial", "stair_intro", "dice_weave", "dice_wall", "sakura_tall", "volcano_intro", "ice_stair", "sweeper_gauntlet", "difficulty_mix", "showcase", "test_all", "segmented"]:
		return
	var track_len := _host._track_len()
	var max_rows := int(_host._level_cfg.get("max_stair_rows", 3))
	var z := 52.0
	var n := 0
	var limit := 5 if _level_uses_dice() else 3
	while z < track_len - 52.0 and n < limit:
		if _host._near_cliff_zone(z, TRAMPOLINE_APPROACH_MARGIN) or _hazard_zone_conflicts(z, "stack", 1.25):
			z += 8.0
			continue
		var hi := clampi(maxi(max_rows, 2), 2, 4)
		var heights: Array = [1, 2, hi] if n % 2 == 0 else [hi, 2, 1]
		_spawn_stair_hazard_row(z, heights, rng)
		z += rng.randf_range(42.0, 56.0)
		n += 1


func _spawn_block_hazard_at(dist: float, lane: int, cols: int, rows: int, cell_w: float = -1.0) -> void:
	# 整排三列方块墙 → 改成堆叠横墙（胡萝卜/骰子）
	if cols >= LANE_COUNT:
		var rng := RandomNumberGenerator.new()
		rng.seed = int(_host._level_cfg.get("hazard_seed", 1)) + int(dist * 10.0)
		_spawn_stack_lane_wall(dist, maxi(rows, 1), rng)
		return
	var cw := BLOCK_SIZE if cell_w < 0.0 else cell_w
	var lateral := _host._lane_to_x(lane)
	var visual := _make_clean_block_hazard(cols, rows, cw)
	var holder := Node3D.new()
	_host._world.add_child(holder)
	_host._path_place(holder, dist, lateral, ROAD_SURFACE_Y, 0.0)
	holder.add_child(visual)
	var clear_y := float(rows) * (BLOCK_SIZE + BLOCK_GAP) - 0.15 + ROAD_SURFACE_Y
	var hit_top := float(rows) * (BLOCK_SIZE + BLOCK_GAP) + ROAD_SURFACE_Y
	var half_lat := (float(cols) * cw + float(maxi(cols - 1, 0)) * BLOCK_GAP) * 0.5 + 0.04
	items.append({
		"node": holder,
		"lane": lane,
		"dist": dist,
		"lateral": lateral,
		"half_lat": half_lat,
		"half_len": 0.85,
		"clear_y": maxf(clear_y, JUMP_CLEAR_Y + ROAD_SURFACE_Y),
		"hit_top": hit_top,
		"rows": rows,
		"hit": false,
		"kind": "blocks",
	})


func _spawn_carrot_lane_wall(dist: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_host._level_cfg.get("hazard_seed", 1)) + int(dist * 10.0)
	_spawn_stack_lane_wall(dist, 1, rng, "carrot")


func _spawn_stripe_barrier(dist: float, lane: int) -> void:
	var lateral := _host._lane_to_x(lane)
	var visual := _make_stripe_barrier()
	var holder := Node3D.new()
	_host._world.add_child(holder)
	_host._path_place(holder, dist, lateral, ROAD_SURFACE_Y, 0.0)
	holder.add_child(visual)
	items.append({
		"node": holder,
		"lane": lane,
		"dist": dist,
		"lateral": lateral,
		"half_lat": 0.95,
		"half_len": 0.55,
		"clear_y": 0.85 + ROAD_SURFACE_Y,
		"hit_top": 1.05 + ROAD_SURFACE_Y,
		"rows": 1,
		"hit": false,
		"kind": "stripe",
	})


func _spawn_sweeper_pair(dist: float, ang_speed: float, phase: float, rng: RandomNumberGenerator) -> void:
	## 左右柱同时扫：相位错开，留出穿行窗口
	var spd := ang_speed * rng.randf_range(0.92, 1.08)
	_spawn_sweeper_at(dist, -1, spd, phase, true)
	_spawn_sweeper_at(dist, 1, spd, phase + PI * 0.55, true)


func _rotator_pillar_stack_h() -> float:
	return float(ROTATOR_PILLAR_ROWS) * (ROTATOR_PILLAR_CELL + BLOCK_GAP) - BLOCK_GAP


func _rotator_pillar_radius(cell: float) -> float:
	## 立柱贴圆形平台外圈，中间留出可自由走位的大空区
	return maxf(ROTATOR_ARENA_RADIUS - cell * 0.55 - 0.28, ROAD_HALF_W * 0.92)


func _rotator_arm_radius(cap_w: float) -> float:
	return maxf(ROTATOR_ARENA_RADIUS - cap_w * 0.38 - 0.2, ROAD_HALF_W * 0.9)


func _spawn_center_rotator_l_at(dist: float, ang_speed: float, phase: float) -> void:
	## 倒 L 双锤：竖杆 + 顶块向圆心伸出，绕圆形平台中心旋转
	var pole_h := 2.85
	var cap_w := 1.36
	var cap_h := 0.58
	var cap_d := 0.46
	var pole_r := 0.14
	var arm_r := _rotator_arm_radius(cap_w)
	var arena_half := ROTATOR_ARENA_RADIUS * 0.98
	var holder := Node3D.new()
	holder.name = "CenterRotatorL"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, 0.0, ROAD_SURFACE_Y, 0.0)

	_spawn_rotator_arena_platform(holder)
	_host._rotator_arenas.append({
		"dist": dist,
		"half_len": arena_half,
		"radius": ROTATOR_ARENA_RADIUS,
	})

	var yellow := StandardMaterial3D.new()
	yellow.albedo_color = Color(1.0, 0.78, 0.12)
	yellow.roughness = 0.45
	yellow.metallic = 0.12
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.92, 0.16, 0.18)
	red.roughness = 0.35
	red.metallic = 0.08
	red.emission_enabled = true
	red.emission = Color(0.75, 0.08, 0.1)
	red.emission_energy_multiplier = 0.35

	var pivot := Node3D.new()
	pivot.name = "RotPivot"
	pivot.position = Vector3.ZERO
	pivot.rotation.y = phase
	holder.add_child(pivot)

	for side: float in [-1.0, 1.0]:
		var mount := Node3D.new()
		mount.name = "HammerMount"
		mount.position = Vector3(side * arm_r, 0.0, 0.0)
		pivot.add_child(mount)
		_add_rotator_hammer(mount, side, pole_h, cap_w, cap_h, cap_d, pole_r, yellow, red)

	_host._disable_subtree_shadows(holder)
	var hit_top := pole_h + cap_h + 0.12 + ROAD_SURFACE_Y
	var cap_inset := cap_w * 0.5
	items.append({
		"node": holder,
		"pivot": pivot,
		"lane": 1,
		"dist": dist,
		"lateral": 0.0,
		"rotator_style": "l_hammer",
		"arm_radius": arm_r,
		"cap_inset": cap_inset,
		"pole_hit_r": pole_r + 0.12,
		"cap_hit_r": cap_w * 0.55,
		"half_lat": ROTATOR_ARENA_RADIUS + 0.15,
		"half_len": arena_half,
		"clear_y": hit_top - 0.12,
		"hit_top": hit_top,
		"rows": 1,
		"hit": false,
		"kind": "center_rotator",
		"ang_speed": ang_speed,
	})


func _spawn_center_rotator_pillars_at(dist: float, ang_speed: float, phase: float, rng: RandomNumberGenerator) -> void:
	## 圆形底台 + 四根双格矩形立柱绕 Y 旋转，柱间放水果
	var cell := ROTATOR_PILLAR_CELL
	var rows := ROTATOR_PILLAR_ROWS
	var pillar_r := _rotator_pillar_radius(cell)
	var stack_h := _rotator_pillar_stack_h()
	var arena_half := ROTATOR_ARENA_RADIUS * 0.98
	var holder := Node3D.new()
	holder.name = "CenterRotator"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, 0.0, ROAD_SURFACE_Y, 0.0)

	_spawn_rotator_arena_platform(holder)
	_host._rotator_arenas.append({
		"dist": dist,
		"half_len": arena_half,
		"radius": ROTATOR_ARENA_RADIUS,
	})

	var yellow := StandardMaterial3D.new()
	yellow.albedo_color = Color(1.0, 0.78, 0.12)
	yellow.roughness = 0.45
	yellow.metallic = 0.12
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.92, 0.16, 0.18)
	red.roughness = 0.35
	red.metallic = 0.08
	red.emission_enabled = true
	red.emission = Color(0.75, 0.08, 0.1)
	red.emission_energy_multiplier = 0.35

	var pivot := Node3D.new()
	pivot.name = "RotPivot"
	pivot.position = Vector3.ZERO
	pivot.rotation.y = phase
	holder.add_child(pivot)

	for i in ROTATOR_PILLAR_COUNT:
		var base_ang := float(i) * TAU / float(ROTATOR_PILLAR_COUNT)
		var mount := Node3D.new()
		mount.name = "PillarMount_%d" % i
		mount.position = Vector3(cos(base_ang) * pillar_r, 0.0, -sin(base_ang) * pillar_r)
		pivot.add_child(mount)
		_add_rotator_pillar(mount, cell, rows, yellow, red)

	_spawn_rotator_center_fruits(dist, pillar_r, rng)

	_host._disable_subtree_shadows(holder)
	var hit_top := stack_h + 0.12 + ROAD_SURFACE_Y
	var hit_half := cell * 0.5
	items.append({
		"node": holder,
		"pivot": pivot,
		"lane": 1,
		"dist": dist,
		"lateral": 0.0,
		"pillar_radius": pillar_r,
		"pillar_count": ROTATOR_PILLAR_COUNT,
		"pillar_hit_half": hit_half,
		"half_lat": ROTATOR_ARENA_RADIUS + 0.15,
		"half_len": arena_half,
		"clear_y": hit_top - 0.12,
		"hit_top": hit_top,
		"rows": 1,
		"hit": false,
		"kind": "center_rotator",
		"rotator_style": "pillars",
		"ang_speed": ang_speed,
	})


func _spawn_rotator_center_fruits(dist: float, pillar_r: float, rng: RandomNumberGenerator) -> void:
	var pool := _host._fruit_pool_for_level()
	if pool.is_empty():
		return
	var count := clampi(int(_host._level_cfg.get("rotator_fruit_count", ROTATOR_CENTER_FRUIT_COUNT)), 1, 5)
	var fruit_r := pillar_r * 0.38
	for i in count:
		var kind: String = pool[rng.randi() % pool.size()]
		var slot := float(i % ROTATOR_PILLAR_COUNT)
		var ang := slot * TAU / float(ROTATOR_PILLAR_COUNT) + TAU / float(ROTATOR_PILLAR_COUNT) * 0.5
		ang += rng.randf_range(-0.12, 0.12)
		var lateral := cos(ang) * fruit_r
		var dist_off := sin(ang) * fruit_r * 0.32
		var visual := _host._make_fruit_visual(kind)
		var holder := Node3D.new()
		holder.name = "RotatorFruit"
		_host._world.add_child(holder)
		_host._path_place(holder, dist + dist_off, lateral, 0.55, 0.0)
		holder.add_child(visual)
		_host._fruits.append({
			"node": holder,
			"visual": visual,
			"dist": dist + dist_off,
			"lateral": lateral,
			"kind": kind,
			"coins": _host._fruit_coin_value(kind),
			"phase": rng.randf() * TAU + float(i) * 0.9,
			"taken": false,
		})


func _spawn_rotator_arena_platform(parent: Node3D) -> void:
	## 圆形加宽跑道（比普通道宽，中心无障碍）
	var road_col := CapybaraLevelCatalog.color3(
		_host._theme_cfg.get("road_color"), Color(0.86, 0.82, 0.94)
	)
	var rim_col := Color(1.0, 0.82, 0.15)
	var plat := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = ROTATOR_ARENA_RADIUS
	cyl.bottom_radius = ROTATOR_ARENA_RADIUS * 0.97
	cyl.height = ROAD_THICKNESS
	plat.mesh = cyl
	var pm := StandardMaterial3D.new()
	pm.albedo_color = road_col.lightened(0.06)
	pm.roughness = 0.82
	plat.material_override = pm
	plat.position.y = -ROAD_THICKNESS * 0.5
	parent.add_child(plat)
	var rim := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = ROTATOR_ARENA_RADIUS - 0.1
	torus.outer_radius = ROTATOR_ARENA_RADIUS + 0.06
	torus.ring_segments = 40
	rim.mesh = torus
	var rm := StandardMaterial3D.new()
	rm.albedo_color = rim_col
	rm.roughness = 0.5
	rm.emission_enabled = true
	rm.emission = rim_col * 0.35
	rm.emission_energy_multiplier = 0.25
	rim.material_override = rm
	rim.rotation.x = PI * 0.5
	rim.position.y = 0.02
	parent.add_child(rim)


func _add_rotator_pillar(
	mount: Node3D,
	cell: float,
	rows: int,
	bottom_mat: StandardMaterial3D,
	top_mat: StandardMaterial3D,
) -> void:
	## 双格矩形立柱：下层黄、上层红
	for row in rows:
		var cube := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(cell * 0.96, cell * 0.96, cell * 0.96)
		cube.mesh = bm
		cube.material_override = bottom_mat if row == 0 else top_mat
		cube.position.y = cell * 0.5 + float(row) * (cell + BLOCK_GAP)
		mount.add_child(cube)


func _add_rotator_hammer(
	mount: Node3D,
	mount_side: float,
	pole_h: float,
	cap_w: float,
	cap_h: float,
	cap_d: float,
	pole_r: float,
	pole_mat: StandardMaterial3D,
	cap_mat: StandardMaterial3D,
) -> void:
	## 倒 L：顶块从杆顶向圆心方向伸出（非 T 形居中）
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = pole_r
	pole_mesh.bottom_radius = pole_r * 1.08
	pole_mesh.height = pole_h
	pole.mesh = pole_mesh
	pole.material_override = pole_mat
	pole.position.y = pole_h * 0.5
	mount.add_child(pole)
	var cap := MeshInstance3D.new()
	var cap_mesh := BoxMesh.new()
	cap_mesh.size = Vector3(cap_w, cap_h, cap_d)
	cap.mesh = cap_mesh
	cap.material_override = cap_mat
	cap.position.y = pole_h + cap_h * 0.5
	cap.position.x = -mount_side * cap_w * 0.5
	mount.add_child(cap)


func _spawn_sweeper_at(
	dist: float,
	side: int,
	ang_speed: float,
	phase: float,
	inward_bias: bool = true
) -> void:
	## Tall Man Run 式：道外黄柱 + 红臂绕 Y 旋转扫过赛道
	var side_f := -1.0 if side < 0 else 1.0
	var pole_x := side_f * (ROAD_HALF_W + 0.38)
	var arm_len := ROAD_HALF_W * 1.9 + 0.35
	var arm_y := 0.72
	var arm_r := 0.16
	var holder := Node3D.new()
	holder.name = "Sweeper"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, 0.0, ROAD_SURFACE_Y, 0.0)

	var yellow := StandardMaterial3D.new()
	yellow.albedo_color = Color(1.0, 0.78, 0.12)
	yellow.roughness = 0.45
	yellow.metallic = 0.15
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.92, 0.16, 0.18)
	red.roughness = 0.35
	red.metallic = 0.08
	red.emission_enabled = true
	red.emission = Color(0.75, 0.08, 0.1)
	red.emission_energy_multiplier = 0.35

	# 黄柱底座
	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.28
	base_mesh.bottom_radius = 0.34
	base_mesh.height = 0.12
	base.mesh = base_mesh
	base.material_override = yellow
	base.position = Vector3(pole_x, 0.06, 0.0)
	holder.add_child(base)

	# 黄立柱
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.11
	pole_mesh.bottom_radius = 0.13
	pole_mesh.height = 1.35
	pole.mesh = pole_mesh
	pole.material_override = yellow
	pole.position = Vector3(pole_x, 0.72, 0.0)
	holder.add_child(pole)

	# 旋转枢轴（红臂）
	var pivot := Node3D.new()
	pivot.name = "ArmPivot"
	pivot.position = Vector3(pole_x, arm_y, 0.0)
	# 左柱默认朝 +X（向内），右柱朝 -X（向内）
	var face_in := 0.0 if side_f < 0.0 else PI
	if not inward_bias:
		face_in += PI
	pivot.rotation.y = face_in + phase
	holder.add_child(pivot)

	var hub := MeshInstance3D.new()
	var hub_mesh := SphereMesh.new()
	hub_mesh.radius = 0.18
	hub_mesh.height = 0.36
	hub.mesh = hub_mesh
	hub.material_override = yellow
	pivot.add_child(hub)

	var arm := MeshInstance3D.new()
	var arm_mesh := CylinderMesh.new()
	arm_mesh.top_radius = arm_r
	arm_mesh.bottom_radius = arm_r * 1.05
	arm_mesh.height = arm_len
	arm.mesh = arm_mesh
	arm.material_override = red
	# Cylinder 默认沿 Y → 转到沿局部 +X
	arm.rotation.z = -PI * 0.5
	arm.position = Vector3(arm_len * 0.5, 0.0, 0.0)
	pivot.add_child(arm)

	# 臂尖警示球
	var tip := MeshInstance3D.new()
	var tip_mesh := SphereMesh.new()
	tip_mesh.radius = arm_r * 1.15
	tip_mesh.height = arm_r * 2.3
	tip.mesh = tip_mesh
	tip.material_override = red
	tip.position = Vector3(arm_len, 0.0, 0.0)
	pivot.add_child(tip)

	_host._disable_subtree_shadows(holder)
	var hit_top := arm_y + arm_r + 0.28 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"pivot": pivot,
		"lane": -1,
		"dist": dist,
		"lateral": 0.0,
		"pole_x": pole_x,
		"arm_len": arm_len,
		"hit_radius": arm_r + 0.22,
		"half_lat": ROAD_HALF_W + 0.6,
		"half_len": arm_len + 0.35,
		"clear_y": hit_top - 0.12,
		"hit_top": hit_top,
		"rows": 1,
		"hit": false,
		"kind": "sweeper",
		"ang_speed": ang_speed if side_f < 0.0 else -ang_speed,
	})


func _update_moving_hazards(delta: float) -> void:
	for h in items:
		var kind := String(h.get("kind", ""))
		if kind == "pendulum_triple":
			h["phase"] = float(h.get("phase", 0.0)) + float(h.get("swing_speed", 1.2)) * delta
			var ph := float(h["phase"])
			var a := float(h.get("amp", 0.72))
			for m in h.get("members", []):
				var mp: Node3D = m.get("pivot") as Node3D
				if mp != null and is_instance_valid(mp):
					mp.rotation.z = sin(ph + float(m.get("phase_off", 0.0))) * a
			continue
		if kind == "fire_gate":
			h["phase"] = float(h.get("phase", 0.0)) + float(h.get("slide_speed", FIRE_GATE_SLIDE_SPEED)) * delta
			var slider_fg: Node3D = h.get("slider") as Node3D
			if slider_fg != null and is_instance_valid(slider_fg):
				slider_fg.position.x = sin(float(h["phase"])) * float(h.get("slide_amp", FIRE_GATE_SLIDE_AMP))
			var flick := 0.82 + 0.18 * sin(float(h["phase"]) * 5.3)
			for mat in h.get("fire_mats", []):
				if mat is StandardMaterial3D:
					(mat as StandardMaterial3D).emission_energy_multiplier = float(h.get("em_base", 1.0)) * flick
			continue
		var pivot: Node3D = h.get("pivot") as Node3D
		if pivot == null or not is_instance_valid(pivot):
			continue
		match kind:
			"sweeper", "l_gate", "center_rotator":
				pivot.rotation.y += float(h.get("ang_speed", 2.0)) * delta
			"pendulum", "swing_hoop":
				h["phase"] = float(h.get("phase", 0.0)) + float(h.get("swing_speed", 1.6)) * delta
				pivot.rotation.z = sin(float(h["phase"])) * float(h.get("amp", 0.85))
			"spin_ring":
				pivot.rotation.z += float(h.get("ang_speed", 2.4)) * delta
			_:
				pass


func _level_difficulty() -> int:
	if _host._level_cfg.has("difficulty"):
		return clampi(int(_host._level_cfg.get("difficulty", 1)), 1, 5)
	var id := int(_host._level_cfg.get("id", 1))
	if id <= 6:
		return 1
	if id <= 12:
		return 2
	if id <= 18:
		return 3
	if id <= 24:
		return 4
	return 5


func _difficulty_spacing(rng: RandomNumberGenerator) -> float:
	return _pacing_spacing(rng, false, false)


func _spawn_test_all_beat(z: float, i: int, rng: RandomNumberGenerator) -> void:
	## 测试关：按固定顺序依次出现全部障碍类型（含方块墙 / 整排墙 / 组合）
	var sweep := float(_host._level_cfg.get("sweeper_speed", 1.0))
	var swing := float(_host._level_cfg.get("showcase_swing_speed", 0.85))
	var ring := float(_host._level_cfg.get("showcase_ring_speed", 1.15))
	match i % 17:
		0:
			_spawn_stair_hazard_row(z, [1, 2, 1], rng, "dice")
		1:
			_spawn_stair_hazard_row(z, [1, 2, 1], rng, "carrot")
		2:
			_spawn_stair_hazard_row(z, [1, 2, 1], rng, "ice")
		3:
			_spawn_stair_hazard_row(z, [2, 1, 2], rng, "blocks")
		4:
			_spawn_stack_lane_wall(z, 2, rng, "dice")
		5:
			_spawn_stripe_barrier(z, 0)
			_spawn_stripe_barrier(z, 2)
		6:
			_spawn_hurdle_bar_at(z, 3, 1.0)
		7:
			_spawn_hurdle_bar_at(z, 1, 0.95)
		8:
			_spawn_sweeper_at(z, -1, sweep, float(i) * 0.55, true)
		9:
			_spawn_sweeper_pair(z, sweep, float(i) * 0.4, rng)
		10:
			_spawn_pendulum_triple_at(z, float(i) * 0.65, swing, 0.72)
		11:
			_spawn_swing_hoop_at(z, float(i) * 0.5, swing * 0.95, 0.5)
		12:
			_spawn_spin_ring_at(z, 0, ring)
			_spawn_spin_ring_at(z + 4.0, 2, ring * 1.05)
		13:
			_spawn_l_gate_at(z, -1, sweep * 0.85, float(i) * 0.35)
		14:
			_spawn_fire_sliding_gate_at(z, sweep * 0.72, float(i) * 0.45)
		15:
			_spawn_stair_hazard_row(z, [1, 3, 2], rng, "dice")
		_:
			_spawn_hurdle_bar_at(z, 2, 1.05)
			_spawn_stair_hazard_row(z + 10.0, [2, 1, 3], rng, "carrot")


func _spawn_showcase_beat(z: float, i: int, rng: RandomNumberGenerator) -> void:
	## 慢速博览关：按固定顺序各刷一种障碍，便于认路与练习
	var sweep := float(_host._level_cfg.get("sweeper_speed", 1.15))
	var swing := float(_host._level_cfg.get("showcase_swing_speed", 0.9))
	var ring := float(_host._level_cfg.get("showcase_ring_speed", 1.35))
	match i % 13:
		0:
			_spawn_stair_hazard_row(z, [1, 2, 1], rng, "dice")
		1:
			_spawn_stair_hazard_row(z, [1, 2, 1], rng, "carrot")
		2:
			_spawn_stair_hazard_row(z, [1, 2, 1], rng, "ice")
		3:
			_spawn_stripe_barrier(z, 1)
		4:
			_spawn_hurdle_bar_at(z, 2, 1.0)
		5:
			_spawn_sweeper_at(z, -1, sweep, float(i) * 0.55, true)
		6:
			_spawn_sweeper_pair(z, sweep, float(i) * 0.4, rng)
		7:
			_spawn_pendulum_triple_at(z, float(i) * 0.65, swing, 0.72)
		8:
			_spawn_swing_hoop_at(z, float(i) * 0.5, swing * 0.95, 0.5)
		9:
			_spawn_spin_ring_at(z, 1, ring)
		10:
			_spawn_l_gate_at(z, -1, sweep * 0.85, float(i) * 0.35)
		11:
			_spawn_fire_sliding_gate_at(z, sweep * 0.72, float(i) * 0.45)
		_:
			_spawn_stair_hazard_row(z, [2, 1, 2], rng, "dice")


func _spawn_hurdle_bar_at(dist: float, lane_span: int, bar_y: float) -> void:
	## 红色跨栏横杆：跳过去；lane_span=1~3
	lane_span = clampi(lane_span, 1, LANE_COUNT)
	var mid_lane := 1
	if lane_span == 1:
		mid_lane = 1
	elif lane_span == 2:
		mid_lane = 0 if int(dist) % 2 == 0 else 1
	var lateral := 0.0 if lane_span >= 3 else _host._lane_to_x(mid_lane)
	if lane_span == 2:
		lateral = (_host._lane_to_x(mid_lane) + _host._lane_to_x(mini(mid_lane + 1, 2))) * 0.5
	var width := float(lane_span) * LANE_WIDTH * 0.95
	var holder := Node3D.new()
	holder.name = "HurdleBar"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, lateral, ROAD_SURFACE_Y, 0.0)

	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.9, 0.18, 0.2)
	red.roughness = 0.4
	red.emission_enabled = true
	red.emission = Color(0.7, 0.1, 0.1)
	red.emission_energy_multiplier = 0.25
	var yellow := StandardMaterial3D.new()
	yellow.albedo_color = Color(1.0, 0.82, 0.15)
	yellow.roughness = 0.5

	var post_h := bar_y + 0.15
	for side in [-1.0, 1.0]:
		var post := MeshInstance3D.new()
		var pm := CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.07
		pm.height = post_h
		post.mesh = pm
		post.material_override = yellow
		post.position = Vector3(side * width * 0.48, post_h * 0.5, 0.0)
		holder.add_child(post)

	var bar := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(width * 0.92, 0.12, 0.12)
	bar.mesh = bm
	bar.material_override = red
	bar.position = Vector3(0.0, bar_y, 0.0)
	holder.add_child(bar)

	_host._disable_subtree_shadows(holder)
	var hit_top := bar_y + 0.2 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"lane": mid_lane,
		"dist": dist,
		"lateral": lateral,
		"half_lat": width * 0.5 + 0.08,
		"half_len": 0.35,
		"clear_y": hit_top - 0.08,
		"hit_top": hit_top,
		"rows": 1,
		"hit": false,
		"kind": "hurdle",
	})


func _spawn_pendulum_at(dist: float, phase: float, swing_speed: float, amp: float) -> void:
	## 紫色水晶摆锤：左右横扫赛道（高架横梁，锤体约胸口高度）
	var hang := 4.2
	var pivot_y := 5.6
	var holder := Node3D.new()
	holder.name = "Pendulum"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, 0.0, ROAD_SURFACE_Y, 0.0)

	var pink := StandardMaterial3D.new()
	pink.albedo_color = Color(0.95, 0.45, 0.75)
	pink.roughness = 0.35
	var crystal := StandardMaterial3D.new()
	crystal.albedo_color = Color(0.55, 0.35, 0.95, 0.92)
	crystal.roughness = 0.15
	crystal.metallic = 0.2
	crystal.emission_enabled = true
	crystal.emission = Color(0.45, 0.25, 0.9)
	crystal.emission_energy_multiplier = 0.55
	crystal.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var beam := MeshInstance3D.new()
	var beam_m := BoxMesh.new()
	beam_m.size = Vector3(ROAD_HALF_W * 2.2, 0.1, 0.12)
	beam.mesh = beam_m
	beam.material_override = pink
	beam.position = Vector3(0.0, pivot_y + 0.15, 0.0)
	holder.add_child(beam)

	var pivot := Node3D.new()
	pivot.name = "PendPivot"
	pivot.position = Vector3(0.0, pivot_y, 0.0)
	pivot.rotation.z = sin(phase) * amp
	holder.add_child(pivot)

	var rod := MeshInstance3D.new()
	var rod_m := CylinderMesh.new()
	rod_m.top_radius = 0.035
	rod_m.bottom_radius = 0.035
	rod_m.height = hang
	rod.mesh = rod_m
	rod.material_override = pink
	rod.position = Vector3(0.0, -hang * 0.5, 0.0)
	pivot.add_child(rod)

	var weight := MeshInstance3D.new()
	var wm := SphereMesh.new()
	wm.radius = 0.38
	wm.height = 0.76
	weight.mesh = wm
	weight.material_override = crystal
	weight.position = Vector3(0.0, -hang, 0.0)
	weight.scale = Vector3(1.0, 1.25, 1.0)
	pivot.add_child(weight)

	_host._disable_subtree_shadows(holder)
	var hit_top := pivot_y - hang * cos(amp) + 0.45 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"pivot": pivot,
		"lane": -1,
		"dist": dist,
		"lateral": 0.0,
		"hang_len": hang,
		"pivot_y": pivot_y,
		"hit_radius": 0.48,
		"half_lat": ROAD_HALF_W + 0.4,
		"half_len": 0.55,
		"clear_y": hit_top,
		"hit_top": hit_top,
		"rows": 2,
		"hit": false,
		"kind": "pendulum",
		"phase": phase,
		"swing_speed": swing_speed,
		"amp": amp,
	})


func _spawn_pendulum_triple_at(dist: float, phase: float, swing_speed: float, amp: float = 0.72) -> void:
	## 录屏式三连大摆锤：橙柱 + 红锤，沿赛道连续三个为一组
	amp = clampf(amp, 0.45, 1.05)
	var hang := PENDULUM_TRIPLE_HANG
	var pivot_y := PENDULUM_TRIPLE_PIVOT_Y
	var spacing := PENDULUM_TRIPLE_SPACING

	var orange := StandardMaterial3D.new()
	orange.albedo_color = Color(1.0, 0.52, 0.10)
	orange.roughness = 0.55
	var orange_dark := StandardMaterial3D.new()
	orange_dark.albedo_color = Color(0.92, 0.42, 0.08)
	orange_dark.roughness = 0.62
	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.92, 0.16, 0.20)
	red.roughness = 0.42
	red.emission_enabled = true
	red.emission = Color(0.55, 0.08, 0.10)
	red.emission_energy_multiplier = 0.2

	var members: Array = []
	for i in PENDULUM_TRIPLE_COUNT:
		var d := dist + float(i) * spacing
		var phase_off := float(i) * 1.08
		var holder := Node3D.new()
		holder.name = "PendulumTriple_%d" % i
		_host._world.add_child(holder)
		_host._path_place(holder, d, 0.0, ROAD_SURFACE_Y, 0.0)

		var post := MeshInstance3D.new()
		var pm := CylinderMesh.new()
		pm.top_radius = 0.09
		pm.bottom_radius = 0.11
		pm.height = pivot_y + 0.15
		post.mesh = pm
		post.material_override = orange
		post.position = Vector3(0.0, (pivot_y + 0.15) * 0.5, 0.0)
		holder.add_child(post)

		var base_bar := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(ROAD_HALF_W * 1.85, 0.16, 0.16)
		base_bar.mesh = bm
		base_bar.material_override = red
		base_bar.position = Vector3(0.0, 0.42, 0.0)
		holder.add_child(base_bar)

		var cap := MeshInstance3D.new()
		var cap_m := CylinderMesh.new()
		cap_m.top_radius = 0.14
		cap_m.bottom_radius = 0.14
		cap_m.height = 0.12
		cap.mesh = cap_m
		cap.material_override = orange_dark
		cap.position = Vector3(0.0, pivot_y + 0.18, 0.0)
		holder.add_child(cap)

		var pivot := Node3D.new()
		pivot.name = "PendPivot"
		pivot.position = Vector3(0.0, pivot_y, 0.0)
		pivot.rotation.z = sin(phase + phase_off) * amp
		holder.add_child(pivot)

		var rod := MeshInstance3D.new()
		var rod_m := CylinderMesh.new()
		rod_m.top_radius = 0.045
		rod_m.bottom_radius = 0.05
		rod_m.height = hang
		rod.mesh = rod_m
		rod.material_override = orange_dark
		rod.position = Vector3(0.0, -hang * 0.5, 0.0)
		pivot.add_child(rod)

		var weight := MeshInstance3D.new()
		var wm := BoxMesh.new()
		wm.size = Vector3(0.82, 1.05, 0.62)
		weight.mesh = wm
		weight.material_override = red
		weight.position = Vector3(0.0, -hang, 0.0)
		pivot.add_child(weight)

		_host._disable_subtree_shadows(holder)
		members.append({
			"node": holder,
			"dist": d,
			"pivot": pivot,
			"hang_len": hang,
			"hit_radius": 0.54,
			"half_len": 0.7,
			"phase_off": phase_off,
		})

	var center_dist := dist + spacing
	var hit_top := pivot_y - hang * cos(amp) + 0.65 + ROAD_SURFACE_Y
	items.append({
		"kind": "pendulum_triple",
		"dist": center_dist,
		"lateral": 0.0,
		"half_lat": ROAD_HALF_W + 0.45,
		"half_len": spacing * float(PENDULUM_TRIPLE_COUNT - 1) * 0.5 + 1.4,
		"members": members,
		"hang_len": hang,
		"hit_radius": 0.54,
		"clear_y": hit_top,
		"hit_top": hit_top,
		"rows": 2,
		"hit": false,
		"phase": phase,
		"swing_speed": swing_speed,
		"amp": amp,
	})


func _spawn_swing_hoop_at(dist: float, phase: float, swing_speed: float, amp: float) -> void:
	## 紫色秋千圈：可穿心躲避，撞到圈缘掉层（高架，圈心约 1.5m）
	var hang := 4.0
	var pivot_y := 5.5
	var hoop_r := 0.85
	var tube_r := 0.11
	var holder := Node3D.new()
	holder.name = "SwingHoop"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, 0.0, ROAD_SURFACE_Y, 0.0)

	var yellow := StandardMaterial3D.new()
	yellow.albedo_color = Color(1.0, 0.8, 0.15)
	yellow.roughness = 0.45
	var purple := StandardMaterial3D.new()
	purple.albedo_color = Color(0.62, 0.28, 0.95)
	purple.roughness = 0.25
	purple.emission_enabled = true
	purple.emission = Color(0.5, 0.2, 0.9)
	purple.emission_energy_multiplier = 0.45

	var bar := MeshInstance3D.new()
	var bar_m := BoxMesh.new()
	bar_m.size = Vector3(ROAD_HALF_W * 2.0, 0.1, 0.1)
	bar.mesh = bar_m
	bar.material_override = yellow
	bar.position = Vector3(0.0, pivot_y + 0.12, 0.0)
	holder.add_child(bar)

	var pivot := Node3D.new()
	pivot.position = Vector3(0.0, pivot_y, 0.0)
	pivot.rotation.z = sin(phase) * amp
	holder.add_child(pivot)

	for side in [-1.0, 1.0]:
		var cord := MeshInstance3D.new()
		var cm := CylinderMesh.new()
		cm.top_radius = 0.025
		cm.bottom_radius = 0.025
		cm.height = hang
		cord.mesh = cm
		cord.material_override = purple
		cord.position = Vector3(side * hoop_r * 0.55, -hang * 0.5, 0.0)
		pivot.add_child(cord)

	var hoop := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = tube_r
	tm.outer_radius = hoop_r
	hoop.mesh = tm
	hoop.material_override = purple
	hoop.position = Vector3(0.0, -hang, 0.0)
	hoop.rotation.x = PI * 0.5
	pivot.add_child(hoop)

	_host._disable_subtree_shadows(holder)
	var hit_top := pivot_y - hang * cos(amp) + hoop_r + 0.2 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"pivot": pivot,
		"lane": -1,
		"dist": dist,
		"lateral": 0.0,
		"hang_len": hang,
		"pivot_y": pivot_y,
		"hoop_r": hoop_r,
		"tube_r": tube_r + 0.12,
		"half_lat": ROAD_HALF_W + 0.5,
		"half_len": hoop_r + 0.35,
		"clear_y": hit_top,
		"hit_top": hit_top,
		"rows": 1,
		"hit": false,
		"kind": "swing_hoop",
		"phase": phase,
		"swing_speed": swing_speed,
		"amp": amp,
	})


func _spawn_spin_ring_at(dist: float, lane: int, ang_speed: float) -> void:
	## 橙色立式旋转环：占一道，跳或换道
	var lateral := _host._lane_to_x(lane)
	var holder := Node3D.new()
	holder.name = "SpinRing"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, lateral, ROAD_SURFACE_Y, 0.0)

	var orange := StandardMaterial3D.new()
	orange.albedo_color = Color(1.0, 0.45, 0.12)
	orange.roughness = 0.35
	orange.emission_enabled = true
	orange.emission = Color(0.95, 0.4, 0.1)
	orange.emission_energy_multiplier = 0.3

	var stand := MeshInstance3D.new()
	var sm := CylinderMesh.new()
	sm.top_radius = 0.08
	sm.bottom_radius = 0.1
	sm.height = 0.55
	stand.mesh = sm
	stand.material_override = orange
	stand.position = Vector3(0.0, 0.28, 0.0)
	holder.add_child(stand)

	var pivot := Node3D.new()
	pivot.position = Vector3(0.0, 0.95, 0.0)
	holder.add_child(pivot)

	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.08
	tm.outer_radius = 0.55
	ring.mesh = tm
	ring.material_override = orange
	ring.rotation.y = PI * 0.5
	pivot.add_child(ring)

	_host._disable_subtree_shadows(holder)
	var hit_top := 0.95 + 0.55 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"pivot": pivot,
		"lane": lane,
		"dist": dist,
		"lateral": lateral,
		"half_lat": 0.55,
		"half_len": 0.45,
		"clear_y": hit_top - 0.1,
		"hit_top": hit_top,
		"rows": 1,
		"hit": false,
		"kind": "spin_ring",
		"ang_speed": ang_speed,
	})


func _spawn_l_gate_at(dist: float, side: int, ang_speed: float, phase: float) -> void:
	## 红色方块 L 型旋转门（扫臂进阶）
	var side_f := -1.0 if side < 0 else 1.0
	var pole_x := side_f * (ROAD_HALF_W + 0.25)
	var arm_len := ROAD_HALF_W * 1.65
	var holder := Node3D.new()
	holder.name = "LGate"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, 0.0, ROAD_SURFACE_Y, 0.0)

	var red := StandardMaterial3D.new()
	red.albedo_color = Color(0.88, 0.2, 0.22)
	red.roughness = 0.4
	var cell := 0.55

	var pivot := Node3D.new()
	pivot.position = Vector3(pole_x, cell * 0.5, 0.0)
	var face_in := 0.0 if side_f < 0.0 else PI
	pivot.rotation.y = face_in + phase
	holder.add_child(pivot)

	# 水平臂 4 块
	for i in 4:
		var b := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(cell * 0.92, cell * 0.92, cell * 0.92)
		b.mesh = bm
		b.material_override = red
		b.position = Vector3(cell * (0.5 + float(i)), 0.0, 0.0)
		pivot.add_child(b)
	# 竖直端 2 块（L）
	for j in 2:
		var b2 := MeshInstance3D.new()
		var bm2 := BoxMesh.new()
		bm2.size = Vector3(cell * 0.92, cell * 0.92, cell * 0.92)
		b2.mesh = bm2
		b2.material_override = red
		b2.position = Vector3(cell * 3.5, cell * (1.0 + float(j)), 0.0)
		pivot.add_child(b2)

	_host._disable_subtree_shadows(holder)
	var hit_top := cell * 2.8 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"pivot": pivot,
		"lane": -1,
		"dist": dist,
		"lateral": 0.0,
		"pole_x": pole_x,
		"arm_len": arm_len,
		"hit_radius": cell * 0.65,
		"half_lat": ROAD_HALF_W + 0.7,
		"half_len": arm_len + 0.5,
		"clear_y": hit_top - 0.2,
		"hit_top": hit_top,
		"rows": 2,
		"hit": false,
		"kind": "l_gate",
		"ang_speed": ang_speed if side_f < 0.0 else -ang_speed,
	})


func _make_fire_gate_material(em_base: float = 1.15) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.78, 0.18, 0.04)
	mat.roughness = 0.38
	mat.metallic = 0.05
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.42, 0.06)
	mat.emission_energy_multiplier = em_base
	return mat


func _make_fire_gate_panel(width: float, height: float, mat: StandardMaterial3D) -> Node3D:
	var root := Node3D.new()
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(maxf(width, 0.08), height, 0.34)
	body.mesh = bm
	body.material_override = mat
	body.position.y = height * 0.5
	root.add_child(body)
	var crest := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(maxf(width * 0.94, 0.06), height * 0.16, 0.26)
	crest.mesh = cm
	var crest_mat := mat.duplicate() as StandardMaterial3D
	crest_mat.emission = Color(1.0, 0.72, 0.12)
	crest_mat.emission_energy_multiplier = mat.emission_energy_multiplier * 1.35
	crest.material_override = crest_mat
	crest.position.y = height + height * 0.06
	root.add_child(crest)
	return root


func _spawn_fire_sliding_gate_at(dist: float, slide_speed: float, phase: float) -> void:
	## 左右循环滑动火焰墙：中间留一车道宽缺口，其余为火焰不可通过
	var gap_half := FIRE_GATE_GAP_WIDTH * 0.5
	var panel_w := maxf(ROAD_HALF_W - gap_half, 0.35)
	var holder := Node3D.new()
	holder.name = "FireSlidingGate"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, 0.0, ROAD_SURFACE_Y, 0.0)

	var slider := Node3D.new()
	slider.name = "Slider"
	slider.position.x = sin(phase) * FIRE_GATE_SLIDE_AMP
	holder.add_child(slider)

	var fire_mats: Array = []
	var em_base := 1.15
	var left_mat := _make_fire_gate_material(em_base)
	var right_mat := _make_fire_gate_material(em_base)
	fire_mats.append(left_mat)
	fire_mats.append(right_mat)

	var left := _make_fire_gate_panel(panel_w, FIRE_GATE_WALL_H, left_mat)
	left.position.x = -(gap_half + panel_w * 0.5)
	slider.add_child(left)

	var right := _make_fire_gate_panel(panel_w, FIRE_GATE_WALL_H, right_mat)
	right.position.x = gap_half + panel_w * 0.5
	slider.add_child(right)

	# 缺口标记：暗色安全框（非碰撞，仅提示）
	var safe := MeshInstance3D.new()
	var safe_mesh := BoxMesh.new()
	safe_mesh.size = Vector3(FIRE_GATE_GAP_WIDTH * 0.92, 0.06, 0.42)
	safe.mesh = safe_mesh
	var safe_mat := StandardMaterial3D.new()
	safe_mat.albedo_color = Color(0.18, 0.72, 0.95, 0.55)
	safe_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	safe_mat.emission_enabled = true
	safe_mat.emission = Color(0.2, 0.85, 1.0)
	safe_mat.emission_energy_multiplier = 0.35
	safe.material_override = safe_mat
	safe.position.y = 0.03
	slider.add_child(safe)

	_host._disable_subtree_shadows(holder)
	var hit_top := FIRE_GATE_WALL_H + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"slider": slider,
		"lane": -1,
		"dist": dist,
		"lateral": 0.0,
		"gap_width": FIRE_GATE_GAP_WIDTH,
		"slide_amp": FIRE_GATE_SLIDE_AMP,
		"half_lat": ROAD_HALF_W + 0.2,
		"half_len": FIRE_GATE_HALF_LEN,
		"clear_y": hit_top - 0.08,
		"hit_top": hit_top,
		"rows": 2,
		"hit": false,
		"kind": "fire_gate",
		"slide_speed": slide_speed,
		"phase": phase,
		"fire_mats": fire_mats,
		"em_base": em_base,
	})

func _make_stripe_barrier() -> Node3D:
	## 主题色斜纹路障；有主题模型则优先用
	var model_path := _theme_obstacle_path("stripe_model")
	if not model_path.is_empty():
		var fitted := _instance_fitted(model_path, 1.15, 0.0)
		if fitted != null:
			return fitted
	var root := Node3D.new()
	var cols: Array = _host._theme_cfg.get("stripe_colors", [[1.0, 0.55, 0.12], [0.98, 0.98, 0.98]])
	var c0 := CapybaraLevelCatalog.color3(cols[0] if cols.size() > 0 else null, Color(1.0, 0.55, 0.12))
	var c1 := CapybaraLevelCatalog.color3(cols[1] if cols.size() > 1 else null, Color(0.98, 0.98, 0.98))
	var board := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.7, 0.28, 0.16)
	board.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = c0
	mat.roughness = 0.55
	board.material_override = mat
	board.position.y = 0.55
	root.add_child(board)
	for s in 4:
		var stripe := MeshInstance3D.new()
		var sb := BoxMesh.new()
		sb.size = Vector3(0.22, 0.3, 0.18)
		stripe.mesh = sb
		var sm := StandardMaterial3D.new()
		sm.albedo_color = c1
		stripe.material_override = sm
		stripe.position = Vector3(-0.6 + float(s) * 0.4, 0.55, 0.0)
		stripe.rotation.z = deg_to_rad(-35.0)
		root.add_child(stripe)
	var leg_mat := StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.35, 0.35, 0.38)
	for side in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var lc := BoxMesh.new()
		lc.size = Vector3(0.08, 0.55, 0.08)
		leg.mesh = lc
		leg.material_override = leg_mat
		leg.position = Vector3(side * 0.55, 0.28, 0.0)
		leg.rotation.z = side * 0.35
		root.add_child(leg)
	return root


func _make_clean_block_hazard(cols: int, rows: int, cell_w: float = -1.0) -> Node3D:
	var root := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = CapybaraLevelCatalog.color3(_host._theme_cfg.get("block_albedo"), Color(0.62, 0.82, 0.95))
	mat.roughness = 0.55
	var edge := StandardMaterial3D.new()
	edge.albedo_color = Color(0.92, 0.96, 1.0)
	edge.roughness = 0.4
	var size_y := BLOCK_SIZE
	var size_z := BLOCK_SIZE
	var size_x := BLOCK_SIZE if cell_w < 0.0 else cell_w
	var gap := BLOCK_GAP
	for r in rows:
		for c in cols:
			var cell := Node3D.new()
			var body := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(size_x, size_y, size_z)
			body.mesh = box
			body.material_override = mat
			cell.add_child(body)
			var frame := MeshInstance3D.new()
			var fb := BoxMesh.new()
			fb.size = Vector3(size_x + 0.04, size_y + 0.04, size_z + 0.04)
			frame.mesh = fb
			var fm := edge.duplicate() as StandardMaterial3D
			fm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			fm.albedo_color = Color(1.0, 1.0, 1.0, 0.22)
			frame.material_override = fm
			cell.add_child(frame)
			var ox := (float(c) - float(cols - 1) * 0.5) * (size_x + gap)
			cell.position = Vector3(ox, size_y * 0.5 + float(r) * (size_y + gap), 0.0)
			root.add_child(cell)
	return root


func _make_stub_hazard(as_crate: bool) -> Node3D:
	return _make_clean_block_hazard(2 if as_crate else 1, 1)

func _hazard_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	var kind := String(h.get("kind", ""))
	match kind:
		"sweeper", "l_gate":
			return _sweeper_overlap(h, progress, lane_x, air_y)
		"center_rotator":
			return _center_rotator_overlap(h, progress, lane_x, air_y)
		"pendulum":
			return _pendulum_overlap(h, progress, lane_x, air_y)
		"pendulum_triple":
			return _pendulum_triple_overlap(h, progress, lane_x, air_y)
		"swing_hoop":
			return _swing_hoop_overlap(h, progress, lane_x, air_y)
		"fire_gate":
			return _fire_gate_overlap(h, progress, lane_x, air_y)
		_:
			pass
	var dist: float = float(h.get("dist", -9999.0))
	var lateral: float = float(h.get("lateral", 0.0))
	var half_len := float(h.get("half_len", 1.35))
	var half_lat := float(h.get("half_lat", PICKUP_RADIUS_X * 1.05))
	if absf(dist - progress) > half_len:
		return false
	if absf(lateral - lane_x) > half_lat:
		return false
	return true


func _sweeper_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	## 红臂为枢轴→臂尖线段；玩家到线段距离 ≤ 半径则命中
	var dist := float(h.get("dist", -9999.0))
	var arm_len := float(h.get("arm_len", 3.5))
	var hit_r := float(h.get("hit_radius", 0.35))
	var pole_x := float(h.get("pole_x", 0.0))
	var half_len := float(h.get("half_len", arm_len + 0.35))
	if absf(dist - progress) > half_len:
		return false
	var pivot: Node3D = h.get("pivot") as Node3D
	var yaw := 0.0
	if pivot != null and is_instance_valid(pivot):
		yaw = pivot.rotation.y
	var c := cos(yaw)
	var s := sin(yaw)
	# 局部 +X 臂：世界相对 holder → (cos*t, -sin*t) 对应 (lateral, progress-delta)
	var ax := pole_x
	var az := 0.0
	var bx := pole_x + c * arm_len
	var bz := -s * arm_len
	var px := lane_x
	var pz := progress - dist
	var abx := bx - ax
	var abz := bz - az
	var apx := px - ax
	var apz := pz - az
	var ab2 := abx * abx + abz * abz
	var t := 0.0
	if ab2 > 0.0001:
		t = clampf((apx * abx + apz * abz) / ab2, 0.0, 1.0)
	var cx := ax + abx * t
	var cz := az + abz * t
	var dx := px - cx
	var dz := pz - cz
	return dx * dx + dz * dz <= hit_r * hit_r


func _fire_gate_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	## 左右滑动火焰门：仅缺口内可过；火焰区命中
	var dist := float(h.get("dist", -9999.0))
	var half_len := float(h.get("half_len", FIRE_GATE_HALF_LEN))
	if absf(dist - progress) > half_len:
		return false
	var slider: Node3D = h.get("slider") as Node3D
	var gap_center := slider.position.x if slider != null and is_instance_valid(slider) else 0.0
	var gap_half := float(h.get("gap_width", FIRE_GATE_GAP_WIDTH)) * 0.5
	var margin := LANE_WIDTH * 0.08
	if lane_x >= gap_center - gap_half - margin and lane_x <= gap_center + gap_half + margin:
		return false
	return true


func _center_rotator_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	if String(h.get("rotator_style", "pillars")) == "l_hammer":
		return _center_rotator_l_overlap(h, progress, lane_x, air_y)
	## 四根双格立柱绕圆心旋转；玩家与任一柱体 AABB 重叠则命中
	var dist := float(h.get("dist", -9999.0))
	var half_len := float(h.get("half_len", 2.0))
	if absf(dist - progress) > half_len:
		return false
	var pivot: Node3D = h.get("pivot") as Node3D
	var yaw := pivot.rotation.y if pivot != null and is_instance_valid(pivot) else 0.0
	var pillar_r := float(h.get("pillar_radius", _rotator_pillar_radius(ROTATOR_PILLAR_CELL)))
	var pillar_count := int(h.get("pillar_count", ROTATOR_PILLAR_COUNT))
	var hit_half := float(h.get("pillar_hit_half", ROTATOR_PILLAR_CELL * 0.52))
	var px := lane_x
	var pz := progress - dist
	for i in pillar_count:
		var ang := yaw + float(i) * TAU / float(pillar_count)
		var bx := cos(ang) * pillar_r
		var bz := -sin(ang) * pillar_r
		if absf(px - bx) <= hit_half and absf(pz - bz) <= hit_half:
			return true
	return false


func _center_rotator_l_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	## 倒 L 双锤：杆心沿圆形平台轨道；顶块在杆顶朝圆心方向
	var dist := float(h.get("dist", -9999.0))
	var half_len := float(h.get("half_len", 2.0))
	if absf(dist - progress) > half_len:
		return false
	var pivot: Node3D = h.get("pivot") as Node3D
	var yaw := pivot.rotation.y if pivot != null and is_instance_valid(pivot) else 0.0
	var arm_r := float(h.get("arm_radius", _rotator_arm_radius(1.32)))
	if arm_r < 0.01:
		return false
	var cap_inset := float(h.get("cap_inset", 0.66))
	var pole_r := float(h.get("pole_hit_r", 0.25))
	var cap_r := float(h.get("cap_hit_r", 0.72))
	var px := lane_x
	var pz := progress - dist
	var c := cos(yaw)
	var s := sin(yaw)
	for side: float in [-1.0, 1.0]:
		var bx := side * arm_r * c
		var bz := -side * arm_r * s
		var pdx := px - bx
		var pdz := pz - bz
		if pdx * pdx + pdz * pdz <= pole_r * pole_r:
			return true
		var cap_bx := bx * (1.0 - cap_inset / arm_r)
		var cap_bz := bz * (1.0 - cap_inset / arm_r)
		var cdx := px - cap_bx
		var cdz := pz - cap_bz
		if cdx * cdx + cdz * cdz <= cap_r * cap_r:
			return true
	return false


func _pendulum_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	var dist := float(h.get("dist", -9999.0))
	var half_len := float(h.get("half_len", 0.55))
	if absf(dist - progress) > half_len:
		return false
	var pivot: Node3D = h.get("pivot") as Node3D
	var ang := 0.0
	if pivot != null and is_instance_valid(pivot):
		ang = pivot.rotation.z
	var hang := float(h.get("hang_len", 2.0))
	var weight_x := sin(ang) * hang
	var hit_r := float(h.get("hit_radius", 0.48))
	return absf(weight_x - lane_x) <= hit_r


func _pendulum_triple_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	for m in h.get("members", []):
		var item: Dictionary = m
		var dist := float(item.get("dist", -9999.0))
		var half_len := float(item.get("half_len", 0.7))
		if absf(dist - progress) > half_len:
			continue
		var pivot: Node3D = item.get("pivot") as Node3D
		var ang := 0.0
		if pivot != null and is_instance_valid(pivot):
			ang = pivot.rotation.z
		var hang := float(item.get("hang_len", PENDULUM_TRIPLE_HANG))
		var weight_x := sin(ang) * hang
		var hit_r := float(item.get("hit_radius", 0.54))
		if absf(weight_x - lane_x) <= hit_r:
			return true
	return false


func _swing_hoop_overlap(h: Dictionary, progress: float, lane_x: float, air_y: float) -> bool:
	## 撞圈缘；穿心安全（到圆心距离在 inner~outer）
	var dist := float(h.get("dist", -9999.0))
	var half_len := float(h.get("half_len", 1.0))
	if absf(dist - progress) > half_len:
		return false
	var pivot: Node3D = h.get("pivot") as Node3D
	var ang := 0.0
	if pivot != null and is_instance_valid(pivot):
		ang = pivot.rotation.z
	var hang := float(h.get("hang_len", 1.8))
	var hoop_r := float(h.get("hoop_r", 0.7))
	var tube_r := float(h.get("tube_r", 0.2))
	var cx := sin(ang) * hang
	var cy := float(h.get("pivot_y", 2.4)) - cos(ang) * hang
	# 玩家用脚下附近高度近似身体中段
	var px := lane_x
	var py := air_y + 0.55
	var dx := px - cx
	var dy := py - cy
	var radial := sqrt(dx * dx + dy * dy)
	return absf(radial - hoop_r) <= tube_r and absf(progress - dist) <= tube_r + 0.25

func _hazard_kind_group(kind: String) -> String:
	match kind:
		"center_rotator":
			return "rotator"
		"sweeper", "l_gate", "pendulum", "pendulum_triple", "swing_hoop", "spin_ring", "fire_gate":
			return "moving"
		_:
			return "stack"


func _hazard_zone_conflicts(dist: float, kind: String, self_half_len: float = 1.2) -> bool:
	## 不同类型障碍之间留空，避免骰子/旋转台等叠在同一段
	var group := _hazard_kind_group(kind)
	for h in items:
		var other_kind := String(h.get("kind", ""))
		if _hazard_kind_group(other_kind) == group:
			continue
		var hd := float(h.get("dist", -9999.0))
		var other_half := float(h.get("half_len", 1.0))
		if absf(dist - hd) < HAZARD_CROSS_TYPE_GAP + self_half_len + other_half:
			return true
	return false


func _hazard_near_dist(dist: float, margin: float) -> bool:
	for h in items:
		if absf(float(h.get("dist", 0.0)) - dist) < margin:
			return true
	return false
func _spawn_carrot_stack_column(
	dist: float,
	lane: int,
	rows: int,
	rng: RandomNumberGenerator
) -> void:
	## 胡萝卜竖堆：层距压紧，几乎无缝
	rows = clampi(rows, 1, 6)
	var scl := 1.12
	var step_y := 0.58
	var bury := 0.12
	var lateral := _host._lane_to_x(lane)
	var holder := Node3D.new()
	holder.name = "CarrotStack"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, lateral, ROAD_SURFACE_Y, 0.0)
	for i in rows:
		var carrot := _make_ground_carrot(scl)
		carrot.position = Vector3(0.0, -bury + float(i) * step_y, 0.0)
		carrot.rotation = Vector3(deg_to_rad(4.0), float(i) * 0.2 + rng.randf() * 0.1, 0.0)
		holder.add_child(carrot)
	_host._disable_subtree_shadows(holder)
	var hit_h := -bury + float(rows) * step_y + 0.5 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"lane": lane,
		"dist": dist,
		"lateral": lateral,
		"half_lat": LANE_WIDTH * 0.48,
		"half_len": 0.55,
		"clear_y": hit_h - 0.15,
		"hit_top": hit_h,
		"rows": rows,
		"hit": false,
		"kind": "carrot",
		"spin": false,
	})


func _spawn_ice_stack_column(
	dist: float,
	lane: int,
	rows: int,
	rng: RandomNumberGenerator
) -> void:
	## 冰块阶梯柱：半透明冰砖，贴车道宽堆叠
	rows = clampi(rows, 1, 6)
	var cell := LANE_WIDTH - 0.06
	var step := cell - 0.01
	var lateral := _host._lane_to_x(lane)
	var holder := Node3D.new()
	holder.name = "IceStack"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, lateral, ROAD_SURFACE_Y, 0.0)
	for i in rows:
		var ice := _make_ice_block(cell, rng)
		ice.position = Vector3(0.0, cell * 0.5 + float(i) * step, 0.0)
		ice.rotation = Vector3(
			deg_to_rad(rng.randf_range(-3.0, 3.0)),
			deg_to_rad(rng.randf_range(-12.0, 12.0)),
			deg_to_rad(rng.randf_range(-3.0, 3.0))
		)
		holder.add_child(ice)
	_host._disable_subtree_shadows(holder)
	var hit_h := cell * 0.5 + float(rows - 1) * step + cell * 0.5 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"lane": lane,
		"dist": dist,
		"lateral": lateral,
		"half_lat": cell * 0.5 + 0.02,
		"half_len": cell * 0.52,
		"clear_y": hit_h - 0.1,
		"hit_top": hit_h,
		"rows": rows,
		"hit": false,
		"kind": "ice",
		"spin": false,
	})


func _make_ice_block(size: float = 1.0, rng: RandomNumberGenerator = null) -> Node3D:
	## 更真实的冰块：不规则外形 + 冰面着色器（菲涅尔/霜/裂纹/气泡）
	var local_rng := rng
	if local_rng == null:
		local_rng = RandomNumberGenerator.new()
		local_rng.randomize()
	var root := Node3D.new()
	root.name = "IceBlock"

	var ice_col := CapybaraLevelCatalog.color3(
		_host._theme_cfg.get("ice_albedo"), Color(0.58, 0.86, 1.0, 0.78)
	)
	var deep := Color(
		clampf(ice_col.r * 0.35, 0.0, 1.0),
		clampf(ice_col.g * 0.55, 0.0, 1.0),
		clampf(ice_col.b * 0.75, 0.0, 1.0),
		0.92
	)

	# 略不规则，避免完美正方体
	var sx := size * local_rng.randf_range(0.92, 1.04)
	var sy := size * local_rng.randf_range(0.88, 1.02)
	var sz := size * local_rng.randf_range(0.92, 1.04)

	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(sx, sy, sz)
	body.mesh = box
	body.material_override = _make_ice_shader_material(ice_col, deep, local_rng.randf() * 40.0)
	root.add_child(body)

	# 切角碎冰：边角小块，打破塑料感
	var chip_mat := _make_ice_shader_material(
		Color(ice_col.r + 0.08, ice_col.g + 0.05, ice_col.b, 0.7),
		deep,
		local_rng.randf() * 40.0 + 11.0
	)
	for _k in local_rng.randi_range(2, 4):
		var chip := MeshInstance3D.new()
		var cb := BoxMesh.new()
		var cs := local_rng.randf_range(0.12, 0.22) * size
		cb.size = Vector3(cs, cs * local_rng.randf_range(0.5, 1.1), cs * local_rng.randf_range(0.4, 0.9))
		chip.mesh = cb
		chip.material_override = chip_mat
		var side := 1.0 if local_rng.randf() > 0.5 else -1.0
		chip.position = Vector3(
			side * sx * local_rng.randf_range(0.32, 0.48),
			sy * local_rng.randf_range(-0.35, 0.4),
			(1.0 if local_rng.randf() > 0.5 else -1.0) * sz * local_rng.randf_range(0.3, 0.48)
		)
		chip.rotation = Vector3(
			deg_to_rad(local_rng.randf_range(-40.0, 40.0)),
			deg_to_rad(local_rng.randf_range(0.0, 360.0)),
			deg_to_rad(local_rng.randf_range(-40.0, 40.0))
		)
		root.add_child(chip)

	# 内部气泡
	var bubble_mat := StandardMaterial3D.new()
	bubble_mat.albedo_color = Color(0.9, 0.97, 1.0, 0.35)
	bubble_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bubble_mat.roughness = 0.05
	bubble_mat.emission_enabled = true
	bubble_mat.emission = Color(0.7, 0.9, 1.0)
	bubble_mat.emission_energy_multiplier = 0.2
	for _b in local_rng.randi_range(3, 6):
		var bubble := MeshInstance3D.new()
		var sph := SphereMesh.new()
		var br := size * local_rng.randf_range(0.03, 0.07)
		sph.radius = br
		sph.height = br * 2.0
		sph.radial_segments = 8
		sph.rings = 4
		bubble.mesh = sph
		bubble.material_override = bubble_mat
		bubble.position = Vector3(
			local_rng.randf_range(-sx, sx) * 0.28,
			local_rng.randf_range(-sy, sy) * 0.28,
			local_rng.randf_range(-sz, sz) * 0.28
		)
		root.add_child(bubble)

	# 表层霜斑（不透明白噪声片）
	var frost_mat := StandardMaterial3D.new()
	frost_mat.albedo_color = Color(0.96, 0.99, 1.0, 0.42)
	frost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	frost_mat.roughness = 0.85
	frost_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for _f in local_rng.randi_range(1, 3):
		var frost := MeshInstance3D.new()
		var fb := BoxMesh.new()
		fb.size = Vector3(
			size * local_rng.randf_range(0.25, 0.55),
			0.012,
			size * local_rng.randf_range(0.18, 0.4)
		)
		frost.mesh = fb
		frost.material_override = frost_mat
		var face := local_rng.randi() % 3
		match face:
			0:
				frost.position = Vector3(0.0, sy * 0.5 + 0.006, sz * local_rng.randf_range(-0.2, 0.2))
			1:
				frost.position = Vector3(sx * 0.5 + 0.006, sy * local_rng.randf_range(-0.2, 0.2), 0.0)
				frost.rotation.z = PI * 0.5
			_:
				frost.position = Vector3(sx * local_rng.randf_range(-0.2, 0.2), sy * local_rng.randf_range(-0.15, 0.2), sz * 0.5 + 0.006)
				frost.rotation.x = PI * 0.5
		frost.rotation.y += deg_to_rad(local_rng.randf_range(-25.0, 25.0))
		root.add_child(frost)

	return root


func _make_ice_shader_material(ice_col: Color, deep_col: Color, seed_v: float) -> Material:
	## 基于 nekotogd/Godot_Parallax_Ice_3D（CC0）的视差冰面
	## https://github.com/nekotogd/Godot_Parallax_Ice_3D
	var sh: Shader = load("res://assets/maps/route_levels/capybara_rush/shaders/ice_block.gdshader") as Shader
	if sh == null:
		var fb := StandardMaterial3D.new()
		fb.albedo_color = ice_col
		fb.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fb.roughness = 0.1
		fb.metallic = 0.05
		fb.emission_enabled = true
		fb.emission = ice_col
		fb.emission_energy_multiplier = 0.2
		return fb
	_host._ensure_ice_parallax_textures()
	var sm := ShaderMaterial.new()
	sm.shader = sh
	sm.set_shader_parameter("over_texture", _host._ice_tex_over)
	sm.set_shader_parameter("under_texture", _host._ice_tex_under)
	sm.set_shader_parameter("surface_normalmap", _host._ice_tex_normal)
	sm.set_shader_parameter("top_color", Color(ice_col.r, ice_col.g, ice_col.b, 1.0))
	sm.set_shader_parameter("deep_tint", Color(deep_col.r, deep_col.g, deep_col.b, 1.0))
	sm.set_shader_parameter("depth", 0.11 + fmod(seed_v, 7.0) * 0.004)
	sm.set_shader_parameter("normal_depth", 1.2)
	sm.set_shader_parameter("roughness", 0.06)
	sm.set_shader_parameter("metallic", 0.32)
	sm.set_shader_parameter("refractive_index", 0.12)
	sm.set_shader_parameter("fresnel_power", 2.7)
	sm.set_shader_parameter("alpha_base", clampf(ice_col.a, 0.55, 0.9))
	sm.set_shader_parameter("emission_mul", 0.3)
	sm.set_shader_parameter("uv_scale", 1.2 + fmod(seed_v, 5.0) * 0.08)
	return sm


func _spawn_dice_stack_column(
	dist: float,
	lane: int,
	rows: int,
	rng: RandomNumberGenerator
) -> void:
	## 正方体骰子竖叠：边长贴近车道宽，三列几乎无缝
	rows = clampi(rows, 1, 6)
	var cell := LANE_WIDTH - 0.06
	var step := cell - 0.01
	var lateral := _host._lane_to_x(lane)
	var holder := Node3D.new()
	holder.name = "DiceStack"
	_host._world.add_child(holder)
	_host._path_place(holder, dist, lateral, ROAD_SURFACE_Y, 0.0)
	for i in rows:
		var face_up := ((i + lane + int(dist)) % 6) + 1
		var dice := _make_dice_obstacle(face_up, Vector3(cell, cell, cell), true, false, i > 0)
		dice.position = Vector3(0.0, cell * 0.5 + float(i) * step, 0.0)
		dice.rotation = Vector3(0.0, deg_to_rad(float((i + lane) % 4) * 90.0), 0.0)
		holder.add_child(dice)
	_host._disable_subtree_shadows(holder)
	var hit_h := cell * 0.5 + float(rows - 1) * step + cell * 0.5 + ROAD_SURFACE_Y
	items.append({
		"node": holder,
		"lane": lane,
		"dist": dist,
		"lateral": lateral,
		"half_lat": cell * 0.5 + 0.02,
		"half_len": cell * 0.52,
		"clear_y": hit_h - 0.1,
		"hit_top": hit_h,
		"rows": rows,
		"hit": false,
		"kind": "dice",
		"spin": false,
	})


func _level_uses_dice() -> bool:
	return bool(_host._level_cfg.get("dice_hazards", false)) \
		or String(_host._level_cfg.get("hazard_pattern", "")).begins_with("dice_") \
		or String(_host._level_cfg.get("stair_kind", "")) == "dice"


func _spawn_carrot_hazard_at(dist: float, lane: int, rng: RandomNumberGenerator, scale_override: float = -1.0) -> void:
	_spawn_carrot_stack_column(dist, lane, 1, rng)


func _spawn_dice_hazard_at(dist: float, lane: int, rng: RandomNumberGenerator, scale_mul: float = -1.0) -> void:
	_spawn_dice_stack_column(dist, lane, 1, rng)


func _spawn_dice_lane_wall(dist: float, rng: RandomNumberGenerator) -> void:
	_spawn_stack_lane_wall(dist, 1, rng, "dice")


func _make_dice_obstacle(
	face_up: int = 1,
	extents: Vector3 = Vector3.ZERO,
	_tight: bool = false,
	skip_top_pips: bool = false,
	skip_bottom_pips: bool = false
) -> Node3D:
	## 可靠可见的🎲：奶油色立方体 + 黑球点数（不用逐面贴图，避免生成失败/卡死）
	var root := Node3D.new()
	root.name = "Dice"
	var s := 0.95
	if extents != Vector3.ZERO:
		s = mini(extents.x, mini(extents.y, extents.z))
	var half := s * 0.5

	var body_col := Color(1.0, 0.92, 0.78)
	var theme_body := CapybaraLevelCatalog.color3(_host._theme_cfg.get("dice_albedo"), body_col)
	if theme_body.get_luminance() < 0.93:
		body_col = theme_body
	var pip_col := Color(0.06, 0.05, 0.07)

	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3.ONE * s
	body.mesh = box
	var bm := StandardMaterial3D.new()
	bm.albedo_color = body_col
	bm.roughness = 0.5
	body.material_override = bm
	root.add_child(body)

	# 深色细线框（略大一圈的空心感用更深描边盒透明度很低）
	var rim := MeshInstance3D.new()
	var rb := BoxMesh.new()
	rb.size = Vector3.ONE * (s + 0.01)
	rim.mesh = rb
	var rm := StandardMaterial3D.new()
	rm.albedo_color = Color(0.25, 0.18, 0.12, 0.18)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.roughness = 0.8
	rim.material_override = rm
	root.add_child(rim)

	var pip_mat := StandardMaterial3D.new()
	pip_mat.albedo_color = pip_col
	pip_mat.roughness = 0.55

	var top := clampi(face_up, 1, 6)
	var bottom := 7 - top
	var front := 2
	var right := 3
	var pairs: Array = [[1, 6], [2, 5], [3, 4]]
	var rem: Array = []
	for pair in pairs:
		if int(pair[0]) == top or int(pair[1]) == top:
			continue
		rem.append(pair)
	if rem.size() >= 2:
		front = int(rem[0][0])
		right = int(rem[1][0])
	var back := 7 - front
	var left := 7 - right

	var pip_r := s * 0.09
	if not skip_top_pips:
		_add_dice_sphere_pips(root, Vector3(0, half, 0), Vector3.RIGHT, Vector3.FORWARD, top, half, pip_mat, pip_r)
	if not skip_bottom_pips:
		_add_dice_sphere_pips(root, Vector3(0, -half, 0), Vector3.RIGHT, Vector3.BACK, bottom, half, pip_mat, pip_r)
	_add_dice_sphere_pips(root, Vector3(0, 0, half), Vector3.RIGHT, Vector3.UP, front, half, pip_mat, pip_r)
	_add_dice_sphere_pips(root, Vector3(0, 0, -half), Vector3.LEFT, Vector3.UP, back, half, pip_mat, pip_r)
	_add_dice_sphere_pips(root, Vector3(half, 0, 0), Vector3.BACK, Vector3.UP, right, half, pip_mat, pip_r)
	_add_dice_sphere_pips(root, Vector3(-half, 0, 0), Vector3.FORWARD, Vector3.UP, left, half, pip_mat, pip_r)
	return root


func _add_dice_sphere_pips(
	root: Node3D,
	center: Vector3,
	axis_u: Vector3,
	axis_v: Vector3,
	pips: int,
	half: float,
	mat: Material,
	r: float
) -> void:
	var u := axis_u.normalized()
	var v := axis_v.normalized()
	var n := center.normalized()
	if center.length_squared() < 0.0001:
		n = Vector3.UP
	var span := half * 0.55
	for uv in _dice_pip_uvs(pips):
		var pip := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = r
		sph.height = r * 2.0
		sph.radial_segments = 12
		sph.rings = 6
		pip.mesh = sph
		pip.material_override = mat
		# 点数半埋进表面，清晰可见又不大幅撑开层缝
		pip.position = center + u * (uv.x * span) + v * (uv.y * span) + n * (r * 0.45)
		root.add_child(pip)


func _dice_pip_uvs(n: int) -> Array[Vector2]:
	var out: Array[Vector2] = []
	match clampi(n, 1, 6):
		1:
			out = [Vector2(0, 0)]
		2:
			out = [Vector2(-1, -1), Vector2(1, 1)]
		3:
			out = [Vector2(-1, -1), Vector2(0, 0), Vector2(1, 1)]
		4:
			out = [Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1), Vector2(1, 1)]
		5:
			out = [Vector2(-1, -1), Vector2(-1, 1), Vector2(0, 0), Vector2(1, -1), Vector2(1, 1)]
		_:
			out = [
				Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1),
				Vector2(1, -1), Vector2(1, 0), Vector2(1, 1),
			]
	return out


func _make_ground_carrot(scale_mul: float = 1.0) -> Node3D:
	## 程序化胡萝卜：橙身+环纹+绿叶；原点在尖端，朝 +Y
	var root := Node3D.new()
	root.name = "Carrot"
	root.scale = Vector3.ONE * scale_mul

	var orange := StandardMaterial3D.new()
	orange.albedo_color = Color(1.0, 0.48, 0.12)
	orange.roughness = 0.72
	var orange_deep := StandardMaterial3D.new()
	orange_deep.albedo_color = Color(0.92, 0.38, 0.08)
	orange_deep.roughness = 0.78
	var leaf_mat := StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.34, 0.78, 0.28)
	leaf_mat.roughness = 0.55
	var stem_mat := StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.22, 0.55, 0.18)
	stem_mat.roughness = 0.6

	var body_h := 0.95
	var body := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.20
	cyl.bottom_radius = 0.02
	cyl.height = body_h
	cyl.radial_segments = 10
	body.mesh = cyl
	body.material_override = orange
	body.position.y = body_h * 0.5
	root.add_child(body)

	# 环纹：略鼓的扁环，贴近参考图横纹
	for i in 4:
		var ring := MeshInstance3D.new()
		var rc := CylinderMesh.new()
		var t := (float(i) + 1.0) / 5.0
		var rad := lerpf(0.04, 0.21, t)
		rc.top_radius = rad * 1.08
		rc.bottom_radius = rad * 1.08
		rc.height = 0.045
		rc.radial_segments = 10
		ring.mesh = rc
		ring.material_override = orange_deep
		ring.position.y = body_h * t
		root.add_child(ring)

	# 叶柄
	var stem := MeshInstance3D.new()
	var sc := CylinderMesh.new()
	sc.top_radius = 0.025
	sc.bottom_radius = 0.04
	sc.height = 0.18
	stem.mesh = sc
	stem.material_override = stem_mat
	stem.position.y = body_h + 0.06
	root.add_child(stem)

	# 绿叶：几片扁平叶瓣朝外散开
	for i in 5:
		var leaf := MeshInstance3D.new()
		var lb := BoxMesh.new()
		lb.size = Vector3(0.08, 0.42, 0.02)
		leaf.mesh = lb
		leaf.material_override = leaf_mat
		var ang := float(i) * TAU / 5.0 + randf_range(-0.15, 0.15)
		leaf.position = Vector3(cos(ang) * 0.06, body_h + 0.28, sin(ang) * 0.06)
		leaf.rotation = Vector3(deg_to_rad(randf_range(12.0, 28.0)), ang, deg_to_rad(randf_range(-8.0, 8.0)))
		root.add_child(leaf)
	return root
