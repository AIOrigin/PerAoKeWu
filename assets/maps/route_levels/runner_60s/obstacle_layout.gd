class_name ObstacleLayout
extends RefCounted

## 跑酷障碍布局：JSON 读写，供正式关卡与关卡编辑器共用

const DATA_DIR := "res://assets/maps/route_levels/planets/data/"


static func layout_path(planet_id: String) -> String:
	return DATA_DIR + String(planet_id) + "_obstacles.json"


static func has_layout(planet_id: String) -> bool:
	return FileAccess.file_exists(layout_path(planet_id))


static func load_items(planet_id: String) -> Array:
	var root := load_root(planet_id)
	var items: Array = root.get("obstacles", [])
	var out: Array = []
	for raw in items:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append((raw as Dictionary).duplicate(true))
	return out


static func load_root(layout_id: String) -> Dictionary:
	var path := layout_path(layout_id)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("ObstacleLayout: cannot read %s" % path)
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("ObstacleLayout: invalid JSON root in %s" % path)
		return {}
	return parsed


static func load_side_runway_zones(layout_id: String) -> Array:
	var root := load_root(layout_id)
	var zones: Array = root.get("side_runway_zones", [])
	var out: Array = []
	for raw in zones:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(normalize_side_zone(raw))
	return out


static func normalize_side_zone(raw: Dictionary) -> Dictionary:
	var zone := {
		"start": float(raw.get("start", 0.0)),
		"length": float(raw.get("length", 55.0)),
		"side": String(raw.get("side", "outer")),
		"fallback_side": int(raw.get("fallback_side", 1)),
		"lateral_offset": float(raw.get("lateral_offset", 7.2)),
		"layer": int(raw.get("layer", 1)),
		"entry_window": float(raw.get("entry_window", 10.0)),
	}
	if zone["side"] != "outer" and zone["side"] != "left" and zone["side"] != "right":
		# 兼容数值 side：1 / -1
		var side_v := int(raw.get("side", zone["fallback_side"]))
		zone["side"] = "right" if side_v >= 0 else "left"
		zone["fallback_side"] = 1 if side_v >= 0 else -1
	elif zone["side"] == "left":
		zone["fallback_side"] = -1
	elif zone["side"] == "right":
		zone["fallback_side"] = 1
	return zone


static func sort_side_zones(zones: Array) -> Array:
	var copy: Array = []
	for raw in zones:
		if typeof(raw) == TYPE_DICTIONARY:
			copy.append(normalize_side_zone(raw))
	copy.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("start", 0.0)) < float(b.get("start", 0.0))
	)
	return copy


static func load_sandstorm_zones(layout_id: String) -> Array:
	var root := load_root(layout_id)
	var zones: Array = root.get("sandstorm_zones", [])
	var out: Array = []
	for raw in zones:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(normalize_sandstorm_zone(raw))
	return out


static func sandstorm_covered_lanes(lane_count: int, lane_anchor: int) -> Array:
	var count := clampi(lane_count, 1, 3)
	match count:
		1:
			return [clampi(lane_anchor, -1, 1)]
		2:
			var left := clampi(lane_anchor, -1, 0)
			return [left, left + 1]
		_:
			return [-1, 0, 1]


static func normalize_sandstorm_zone(raw: Dictionary) -> Dictionary:
	# 旧数据无 lane_count 时默认占满三列
	var lane_count := 3
	if raw.has("lane_count"):
		lane_count = int(raw["lane_count"])
	elif raw.has("lanes") and typeof(raw["lanes"]) == TYPE_INT:
		lane_count = int(raw["lanes"])
	lane_count = clampi(lane_count, 1, 3)
	var lane_anchor := int(raw.get("lane", raw.get("lane_anchor", 0)))
	if raw.has("covered_lanes") and typeof(raw["covered_lanes"]) == TYPE_ARRAY:
		var covered_raw: Array = raw["covered_lanes"]
		var covered: Array = []
		for v in covered_raw:
			covered.append(clampi(int(v), -1, 1))
		if covered.size() >= 1:
			lane_count = clampi(covered.size(), 1, 3)
			covered.sort()
			lane_anchor = int(covered[0])
			return {
				"start": float(raw.get("start", 0.0)),
				"length": float(raw.get("length", 40.0)),
				"dps": float(raw.get("dps", 9.0)),
				"label": String(raw.get("label", "沙尘暴")),
				"lane_count": lane_count,
				"lane": lane_anchor,
				"covered_lanes": covered,
			}
	var covered2: Array = sandstorm_covered_lanes(lane_count, lane_anchor)
	return {
		"start": float(raw.get("start", 0.0)),
		"length": float(raw.get("length", 40.0)),
		"dps": float(raw.get("dps", 9.0)),
		"label": String(raw.get("label", "沙尘暴" if lane_count < 3 else "沙尘暴")),
		"lane_count": lane_count,
		"lane": int(covered2[0]) if lane_count < 3 else lane_anchor,
		"covered_lanes": covered2,
	}


static func sort_sandstorm_zones(zones: Array) -> Array:
	var copy: Array = []
	for raw in zones:
		if typeof(raw) == TYPE_DICTIONARY:
			copy.append(normalize_sandstorm_zone(raw))
	copy.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("start", 0.0)) < float(b.get("start", 0.0))
	)
	return copy


## 由 main_block 反推侧墙区：使坑段覆盖封堵判定带
static func side_zone_from_main_block(main_block: Dictionary, side_hint: Dictionary = {}) -> Dictionary:
	var center := float(main_block.get("distance", 0.0))
	var half := maxf(float(main_block.get("half_depth", 26.0)), 8.0)
	# pit_s = start + 5, pit_e = start + length - 2  → 覆盖 [center-half, center+half]
	var start := center - half - 5.0
	var length := half * 2.0 + 7.0
	var side := String(side_hint.get("side", "outer"))
	var fallback := int(side_hint.get("fallback_side", 1))
	return normalize_side_zone({
		"start": snappedf(start, 1.0),
		"length": snappedf(length, 1.0),
		"side": side,
		"fallback_side": fallback,
		"lateral_offset": float(side_hint.get("lateral_offset", 7.2)),
		"layer": 1,
		"entry_window": float(side_hint.get("entry_window", 10.0)),
	})


static func side_zone_covers_main_block(zone: Dictionary, main_block: Dictionary) -> bool:
	var center := float(main_block.get("distance", 0.0))
	var half := maxf(float(main_block.get("half_depth", 26.0)), 8.0)
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 55.0))
	var entry := float(zone.get("entry_window", 10.0))
	# 封堵中心落在侧墙走廊（含入口窗）内即视为已配套
	return center >= start - entry and center <= start + length


static func ramp_distance_for_side_zone(zone: Dictionary) -> float:
	var start := float(zone.get("start", 0.0))
	var entry := float(zone.get("entry_window", 10.0))
	return snappedf(start - entry + 2.0, 1.0)


static func normalize_track_segment(raw: Dictionary) -> Dictionary:
	var seg_type := String(raw.get("type", ""))
	if seg_type == "y_fork" or bool(raw.get("y_fork", false)):
		var branch := float(raw.get("branch_length", 0.0))
		if branch <= 0.001:
			branch = maxf(float(raw.get("length", 100.0)) * 0.5, 10.0)
		else:
			branch = maxf(branch, 10.0)
		var angle := deg_to_rad(45.0)
		if raw.has("angle_deg"):
			angle = deg_to_rad(float(raw.get("angle_deg", 45.0)))
		elif raw.has("angle"):
			angle = float(raw.get("angle"))
			if absf(angle) > PI + 0.01:
				angle = deg_to_rad(angle)
		return {
			"type": "y_fork",
			"branch_length": branch,
			"angle": angle,
			# 沿一条可跑支路的路程：斜出 + 斜回收
			"length": branch * 2.0,
			"turn": 0.0,
		}
	return {
		"type": "arc",
		"length": maxf(float(raw.get("length", 40.0)), 1.0),
		"turn": float(raw.get("turn", 0.0)),
	}


static func is_y_fork_segment(seg: Dictionary) -> bool:
	return String(seg.get("type", "arc")) == "y_fork"


## 从路段列表烘焙中心采样。Y 分叉主路径走左侧支路再汇合。
## 返回 { samples: Array[{d,pos,yaw}], length: float, end_pos: Vector3, end_yaw: float }
static func bake_path_from_segments(segments: Array, step: float = 2.0) -> Dictionary:
	var samples: Array = []
	var pos := Vector3.ZERO
	var yaw := 0.0
	var dist := 0.0
	samples.append({"d": 0.0, "pos": pos, "yaw": yaw})
	var segs: Array = segments
	if segs.is_empty():
		segs = [normalize_track_segment({"length": 80.0, "turn": 0.0})]
	for raw in segs:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = normalize_track_segment(raw)
		if is_y_fork_segment(seg):
			var branch := float(seg.get("branch_length", 50.0))
			var ang := float(seg.get("angle", deg_to_rad(45.0)))
			var state := _bake_append_y_fork_side(samples, pos, yaw, dist, branch, ang, 1.0, step)
			pos = state["pos"]
			yaw = state["yaw"]
			dist = state["dist"]
		else:
			var length := float(seg.get("length", 0.0))
			var turn := float(seg.get("turn", 0.0))
			if length <= 0.001:
				continue
			var state2 := _bake_append_arc(samples, pos, yaw, dist, length, turn, step)
			pos = state2["pos"]
			yaw = state2["yaw"]
			dist = state2["dist"]
	return {
		"samples": samples,
		"length": dist,
		"end_pos": pos,
		"end_yaw": yaw,
	}


## side_sign: +1 左岔（主路径），-1 右岔。从分叉口走完再回到原航向汇合点。
static func bake_y_fork_branch_polyline(
	start_pos: Vector3,
	start_yaw: float,
	branch_length: float,
	angle: float,
	side_sign: float,
	step: float = 2.0
) -> Array:
	var samples: Array = []
	var pos := start_pos
	var yaw := start_yaw
	var dist := 0.0
	samples.append({"d": 0.0, "pos": pos, "yaw": yaw})
	_bake_append_y_fork_side(samples, pos, yaw, dist, branch_length, angle, side_sign, step)
	return samples


## 返回 Y 分叉区间：主路径已含左岔；另附右岔绝对距离采样，供运行时按 _fork_side 切换。
## [{ d_start, d_end, branch_length, angle, right: Array[{d,pos,yaw}] }]
static func bake_y_fork_regions(segments: Array, step: float = 2.0) -> Array:
	var regions: Array = []
	for entry in segment_start_poses(segments, step):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = entry.get("segment", {})
		if not is_y_fork_segment(seg):
			continue
		var d_start := float(entry.get("dist", 0.0))
		var branch := float(seg.get("branch_length", 50.0))
		var ang := float(seg.get("angle", deg_to_rad(45.0)))
		var local_right: Array = bake_y_fork_branch_polyline(
			entry.get("pos", Vector3.ZERO),
			float(entry.get("yaw", 0.0)),
			branch,
			ang,
			-1.0,
			step
		)
		var abs_right: Array = []
		for s in local_right:
			if typeof(s) != TYPE_DICTIONARY:
				continue
			abs_right.append({
				"d": d_start + float(s.get("d", 0.0)),
				"pos": s.get("pos", Vector3.ZERO),
				"yaw": float(s.get("yaw", 0.0)),
			})
		regions.append({
			"d_start": d_start,
			"d_end": d_start + branch * 2.0,
			"branch_length": branch,
			"angle": ang,
			"right": abs_right,
		})
	return regions


static func _bake_append_y_fork_side(
	samples: Array,
	pos: Vector3,
	yaw: float,
	dist: float,
	branch_length: float,
	angle: float,
	side_sign: float,
	step: float
) -> Dictionary:
	var y0 := yaw
	var sign := 1.0 if side_sign >= 0.0 else -1.0
	# 斜出：航向 = 原航向 ± angle
	yaw = y0 + sign * angle
	var s1 := _bake_append_straight(samples, pos, yaw, dist, branch_length, step)
	pos = s1["pos"]
	dist = s1["dist"]
	# 斜回收：航向 = 原航向 ∓ angle，终点落在原中心线延长线上
	yaw = y0 - sign * angle
	var s2 := _bake_append_straight(samples, pos, yaw, dist, branch_length, step)
	pos = s2["pos"]
	dist = s2["dist"]
	yaw = y0
	if not samples.is_empty():
		var last: Dictionary = samples[samples.size() - 1]
		samples[samples.size() - 1] = {"d": last["d"], "pos": last["pos"], "yaw": yaw}
	return {"pos": pos, "yaw": yaw, "dist": dist}


static func _bake_append_straight(
	samples: Array,
	pos: Vector3,
	yaw: float,
	dist: float,
	length: float,
	step: float
) -> Dictionary:
	if length <= 0.001:
		return {"pos": pos, "yaw": yaw, "dist": dist}
	var steps := maxi(1, int(ceil(length / maxf(step, 0.5))))
	var ds := length / float(steps)
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	for _i in steps:
		pos += forward * ds
		dist += ds
		samples.append({"d": dist, "pos": pos, "yaw": yaw})
	return {"pos": pos, "yaw": yaw, "dist": dist}


## 恒定曲率圆弧（圆角）。比逐步「先拧 yaw 再走」更贴真实弯道，急弯自动加密采样。
static func _bake_append_arc(
	samples: Array,
	pos: Vector3,
	yaw: float,
	dist: float,
	length: float,
	turn: float,
	step: float
) -> Dictionary:
	if length <= 0.001:
		return {"pos": pos, "yaw": yaw, "dist": dist}
	if absf(turn) < 0.00015:
		return _bake_append_straight(samples, pos, yaw, dist, length, step)

	# 至少约每 6° 一个点，且不超过 step 米；上限防止超长弯爆炸
	var steps_by_angle := maxi(1, int(ceil(absf(turn) / deg_to_rad(6.0))))
	var steps_by_len := maxi(1, int(ceil(length / maxf(step, 0.5))))
	var steps := clampi(maxi(steps_by_angle, steps_by_len), 2, 320)

	var kappa := turn / length
	var yaw0 := yaw
	var x0 := pos.x
	var z0 := pos.z
	var dist0 := dist
	for i in range(1, steps + 1):
		var s := length * (float(i) / float(steps))
		var yaw_s := yaw0 + kappa * s
		# ∫ forward：forward=(-sin(yaw),0,-cos(yaw))
		var x := x0 + (cos(yaw0 + kappa * s) - cos(yaw0)) / kappa
		var z := z0 - (sin(yaw0 + kappa * s) - sin(yaw0)) / kappa
		pos = Vector3(x, 0.0, z)
		yaw = yaw_s
		dist = dist0 + s
		samples.append({"d": dist, "pos": pos, "yaw": yaw})
	return {"pos": pos, "yaw": yaw, "dist": dist0 + length}


## 沿路段推进，返回每个路段起点的位姿（用于画 Y 右岔等）
static func segment_start_poses(segments: Array, step: float = 2.0) -> Array:
	var out: Array = []
	var pos := Vector3.ZERO
	var yaw := 0.0
	var dist := 0.0
	for raw in segments:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = normalize_track_segment(raw)
		out.append({"pos": pos, "yaw": yaw, "dist": dist, "segment": seg})
		var scratch: Array = [{"d": dist, "pos": pos, "yaw": yaw}]
		if is_y_fork_segment(seg):
			var state := _bake_append_y_fork_side(
				scratch, pos, yaw, dist,
				float(seg.get("branch_length", 50.0)),
				float(seg.get("angle", deg_to_rad(45.0))),
				1.0,
				step
			)
			pos = state["pos"]
			yaw = state["yaw"]
			dist = state["dist"]
		else:
			var state2 := _bake_append_arc(
				scratch, pos, yaw, dist,
				float(seg.get("length", 0.0)),
				float(seg.get("turn", 0.0)),
				step
			)
			pos = state2["pos"]
			yaw = state2["yaw"]
			dist = state2["dist"]
	return out


static func load_track_segments(layout_id: String) -> Array:
	var root := load_root(layout_id)
	if not root.has("track_segments"):
		return []
	var out: Array = []
	for raw in root.get("track_segments", []):
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(normalize_track_segment(raw))
	return out


static func normalize_junction_zone(raw: Dictionary) -> Dictionary:
	return {
		"distance": float(raw.get("distance", 0.0)),
		"length": maxf(float(raw.get("length", 100.0)), 20.0),
		"spread": maxf(float(raw.get("spread", 20.0)), 4.0),
		"lane_a": int(raw.get("lane_a", 0)),
		"label_a": String(raw.get("label_a", "安全岔路")),
		"effect_a": String(raw.get("effect_a", "repair")),
		"lane_b": int(raw.get("lane_b", 2)),
		"label_b": String(raw.get("label_b", "速通岔路")),
		"effect_b": String(raw.get("effect_b", "fast")),
	}


static func load_junction_zones(layout_id: String) -> Array:
	var root := load_root(layout_id)
	if not root.has("junction_zones"):
		return []
	var out: Array = []
	for raw in root.get("junction_zones", []):
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(normalize_junction_zone(raw))
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	return out


static func sort_junction_zones(zones: Array) -> Array:
	var copy: Array = []
	for raw in zones:
		if typeof(raw) == TYPE_DICTIONARY:
			copy.append(normalize_junction_zone(raw))
	copy.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	return copy


static func save_items(planet_id: String, items: Array, meta: Dictionary = {}) -> bool:
	var payload := {
		"planet_id": planet_id,
		"version": 1,
		"updated_at": Time.get_datetime_string_from_system(true),
		"obstacles": items,
	}
	for k in meta.keys():
		payload[k] = meta[k]
	var json := JSON.stringify(payload, "\t")
	var path := layout_path(planet_id)
	# 确保目录存在（导出/编辑器写入）
	var abs_dir := ProjectSettings.globalize_path(DATA_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("ObstacleLayout: cannot write %s (%s)" % [path, FileAccess.get_open_error()])
		return false
	file.store_string(json)
	file.close()
	return true


static func normalize_item(raw: Dictionary) -> Dictionary:
	var item := {
		"type": String(raw.get("type", "jump")),
		"lane": int(raw.get("lane", 0)),
		"distance": float(raw.get("distance", 0.0)),
	}
	if raw.has("layer"):
		item["layer"] = int(raw["layer"])
	if raw.has("half_depth"):
		item["half_depth"] = float(raw["half_depth"])
	if raw.has("target_layer"):
		item["target_layer"] = int(raw["target_layer"])
	if raw.has("move_speed"):
		item["move_speed"] = float(raw["move_speed"])
	if raw.has("y_offset"):
		item["y_offset"] = float(raw["y_offset"])
	return item


static func sort_items(items: Array) -> Array:
	var copy: Array = []
	for raw in items:
		if typeof(raw) == TYPE_DICTIONARY:
			copy.append(normalize_item(raw))
	copy.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	return copy


static func type_color(obstacle_type: String) -> Color:
	match obstacle_type:
		"jump", "low_barrier":
			return Color(0.35, 0.85, 1.0)
		"slide", "high_bar":
			return Color(0.95, 0.45, 1.0)
		"train", "train_moving":
			return Color(1.0, 0.55, 0.2)
		"block_left", "block_right":
			return Color(1.0, 0.3, 0.35)
		"ramp":
			return Color(0.4, 1.0, 0.55)
		"main_block":
			return Color(1.0, 0.2, 0.15)
		"turn_left", "turn_right":
			return Color(0.95, 0.9, 0.3)
		_:
			return Color(0.75, 0.75, 0.8)
