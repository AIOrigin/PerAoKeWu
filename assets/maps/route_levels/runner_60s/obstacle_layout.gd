class_name ObstacleLayout
extends RefCounted

## 跑酷障碍布局：JSON 读写，供正式关卡与关卡编辑器共用

const DATA_DIR := "res://assets/maps/route_levels/planets/data/"

## 三套视觉素材 + 独立跑道 JSON：
## 视觉素材分据点：dome=EARLY_VISUAL_KIT / reservoir=RESERVOIR_VISUAL_KIT / crisis / relay
## layout_set_* 为编辑器/旧引用保留；正式关卡直接用 mission_* layout_id
const LAYOUT_FILE_ALIASES := {
	"layout_set_early_1": "mission_dome_h1",
	"layout_set_early_2": "mission_dome_h2",
	"layout_set_early_3": "mission_dome_h3",
	"layout_set_early_4": "mission_dome_h4",
	"layout_set_crisis_1": "mission_medical_m1",
	"layout_set_crisis_2": "mission_medical_m2",
	"layout_set_crisis_3": "mission_medical_m3",
	"layout_set_crisis_4": "mission_medical_m4",
	"layout_set_relay_1": "mission_relay_e1",
	"layout_set_relay_2": "mission_relay_e2",
	"layout_set_relay_3": "mission_relay_e3",
	"layout_set_relay_4": "mission_relay_e4",
	"mission_relay_01": "mission_relay_e1",
}

static var _root_cache: Dictionary = {}


static func resolve_file_id(layout_id: String) -> String:
	var id := String(layout_id).strip_edges()
	if id == "":
		return ""
	return String(LAYOUT_FILE_ALIASES.get(id, id))


static func layout_path(planet_id: String) -> String:
	var file_id := resolve_file_id(planet_id)
	if file_id == "":
		return ""
	return DATA_DIR + file_id + "_obstacles.json"


static func has_layout(planet_id: String) -> bool:
	var path := layout_path(planet_id)
	return path != "" and FileAccess.file_exists(path)


static func load_items(planet_id: String) -> Array:
	var root := load_root(planet_id)
	var items: Array = root.get("obstacles", [])
	var out: Array = []
	for raw in items:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append((raw as Dictionary).duplicate(true))
	return out


static func layout_has_section(layout_id: String, key: String) -> bool:
	return load_root(layout_id).has(key)


static func clear_root_cache(layout_id: String = "") -> void:
	if layout_id == "":
		_root_cache.clear()
	else:
		_root_cache.erase(layout_id)


static func load_root(layout_id: String) -> Dictionary:
	var id := String(layout_id).strip_edges()
	if id == "":
		return {}
	var file_id := resolve_file_id(id)
	if _root_cache.has(file_id):
		return _root_cache[file_id]
	var path := layout_path(id)
	if path == "" or not FileAccess.file_exists(path):
		_root_cache[file_id] = {}
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("ObstacleLayout: cannot read %s" % path)
		_root_cache[file_id] = {}
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("ObstacleLayout: invalid JSON root in %s" % path)
		_root_cache[file_id] = {}
		return {}
	_root_cache[file_id] = parsed
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
		"lateral_offset": float(raw.get("lateral_offset", 6.25)),
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


static func load_rain_zones(layout_id: String) -> Array:
	var root := load_root(layout_id)
	var zones: Array = root.get("rain_zones", [])
	var out: Array = []
	for raw in zones:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(normalize_rain_zone(raw))
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("start", 0.0)) < float(b.get("start", 0.0))
	)
	return out


static func normalize_rain_zone(raw: Dictionary) -> Dictionary:
	var start := float(raw.get("start", 0.0))
	var length := maxf(float(raw.get("length", 60.0)), 12.0)
	var intensity := clampf(float(raw.get("intensity", 1.0)), 0.35, 1.6)
	var label := String(raw.get("label", "毒雨段")).strip_edges()
	if label == "":
		label = "毒雨段"
	return {
		"start": start,
		"length": length,
		"intensity": intensity,
		"label": label,
		"rain_kind": String(raw.get("rain_kind", "toxic")).to_lower(),
	}


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
	var base: Dictionary
	if raw.has("covered_lanes") and typeof(raw["covered_lanes"]) == TYPE_ARRAY:
		var covered_raw: Array = raw["covered_lanes"]
		var covered: Array = []
		for v in covered_raw:
			covered.append(clampi(int(v), -1, 1))
		if covered.size() >= 1:
			lane_count = clampi(covered.size(), 1, 3)
			covered.sort()
			lane_anchor = int(covered[0])
			var hazard_kind := String(raw.get("hazard_kind", raw.get("variant", "sand")))
			if hazard_kind not in ["sand", "poison"]:
				hazard_kind = "sand"
			base = {
				"start": float(raw.get("start", 0.0)),
				"length": float(raw.get("length", 40.0)),
				"dps": float(raw.get("dps", 9.0)),
				"label": String(raw.get("label", "毒雾" if hazard_kind == "poison" else "沙尘暴")),
				"hazard_kind": hazard_kind,
				"lane_count": lane_count,
				"lane": lane_anchor,
				"covered_lanes": covered,
			}
	else:
		var covered2: Array = sandstorm_covered_lanes(lane_count, lane_anchor)
		var hazard_kind2 := String(raw.get("hazard_kind", raw.get("variant", "sand")))
		if hazard_kind2 not in ["sand", "poison"]:
			hazard_kind2 = "sand"
		base = {
			"start": float(raw.get("start", 0.0)),
			"length": float(raw.get("length", 40.0)),
			"dps": float(raw.get("dps", 9.0)),
			"label": String(raw.get("label", "毒雾" if hazard_kind2 == "poison" else "沙尘暴")),
			"hazard_kind": hazard_kind2,
			"lane_count": lane_count,
			"lane": int(covered2[0]) if lane_count < 3 else lane_anchor,
			"covered_lanes": covered2,
		}
	return _merge_side_emit_fields(base, raw)


static func _merge_side_emit_fields(base: Dictionary, raw: Dictionary) -> Dictionary:
	var out := base.duplicate(true)
	var emit_style := String(raw.get("emit_style", "volume"))
	if emit_style not in ["volume", "side_cave"]:
		emit_style = "volume"
	out["emit_style"] = emit_style
	if emit_style != "side_cave":
		return out
	out["emit_pattern"] = String(raw.get("emit_pattern", "alternate"))
	out["burst_interval"] = maxf(0.35, float(raw.get("burst_interval", 0.82)))
	out["burst_duration"] = maxf(0.2, float(raw.get("burst_duration", 0.55)))
	if raw.has("left_cover_lanes") and typeof(raw["left_cover_lanes"]) == TYPE_ARRAY:
		var left: Array = []
		for v in raw["left_cover_lanes"]:
			left.append(clampi(int(v), -1, 1))
		out["left_cover_lanes"] = left
	else:
		out["left_cover_lanes"] = [-1, 0]
	if raw.has("right_cover_lanes") and typeof(raw["right_cover_lanes"]) == TYPE_ARRAY:
		var right: Array = []
		for v in raw["right_cover_lanes"]:
			right.append(clampi(int(v), -1, 1))
		out["right_cover_lanes"] = right
	else:
		out["right_cover_lanes"] = [0, 1]
	return out


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
		"lateral_offset": float(side_hint.get("lateral_offset", 6.25)),
		"layer": 1,
		"entry_window": float(side_hint.get("entry_window", 10.0)),
	})


static func side_zone_covers_main_block(zone: Dictionary, main_block: Dictionary) -> bool:
	var center := float(main_block.get("distance", 0.0))
	var half := maxf(float(main_block.get("half_depth", 26.0)), 8.0)
	var pit_s := center - half
	var pit_e := center + half
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 55.0))
	var end := start + length
	# 侧墙必须完整盖住坍塌坑，并留一点下墙缓冲，否则会「墙一结束就坠坑」
	return start <= pit_s + 1.0 and end >= pit_e + 6.0


## 若侧墙与 main_block 重叠但未盖满坑，拉长/前移区间直到可安全绕过
static func extend_side_zone_to_cover_main_block(zone: Dictionary, main_block: Dictionary) -> Dictionary:
	var out := zone.duplicate(true)
	var center := float(main_block.get("distance", 0.0))
	var half := maxf(float(main_block.get("half_depth", 26.0)), 8.0)
	var pit_s := center - half
	var pit_e := center + half
	var start := float(out.get("start", 0.0))
	var length := float(out.get("length", 55.0))
	var end := start + length
	var entry := float(out.get("entry_window", 10.0))
	# 与坑有交集或中心落在入口窗内，才视为「配套侧墙」可被拉伸
	if end < pit_s - 2.0 or start - entry > pit_e + 2.0:
		return out
	var need_start := pit_s - 2.0
	var need_end := pit_e + 8.0
	if start > need_start:
		length += start - need_start
		start = need_start
	if start + length < need_end:
		length = need_end - start
	out["start"] = snappedf(start, 1.0)
	out["length"] = snappedf(length, 1.0)
	return normalize_side_zone(out)


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


static func load_shield_crystals(layout_id: String) -> Array:
	var root := load_root(layout_id)
	var out: Array = []
	for raw in root.get("shield_crystals", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		out.append({
			"lane": int(raw.get("lane", 0)),
			"distance": float(raw.get("distance", 0.0)),
			"layer": int(raw.get("layer", 0)),
		})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	return out


static func load_speed_boosts(layout_id: String) -> Array:
	var root := load_root(layout_id)
	var out: Array = []
	for raw in root.get("speed_boosts", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		out.append({
			"lane": int(raw.get("lane", 0)),
			"distance": float(raw.get("distance", 0.0)),
			"layer": int(raw.get("layer", 0)),
		})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	return out


static func load_finish_sprints(layout_id: String) -> Array:
	var root := load_root(layout_id)
	var out: Array = []
	for raw in root.get("finish_sprints", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		out.append({
			"distance": float(raw.get("distance", 0.0)),
			"lane": int(raw.get("lane", 0)),
			"width_ratio": float(raw.get("width_ratio", 1.0 / 3.0)),
		})
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("distance", 0.0)) < float(b.get("distance", 0.0))
	)
	return out


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
	clear_root_cache(planet_id)
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
	if raw.has("overweight_tutorial"):
		item["overweight_tutorial"] = bool(raw["overweight_tutorial"])
	if raw.has("orb_size"):
		item["orb_size"] = String(raw["orb_size"])
	if raw.has("orb_tint"):
		item["orb_tint"] = String(raw["orb_tint"])
	if raw.has("purple"):
		item["purple"] = bool(raw["purple"])
	if raw.has("drift_speed"):
		item["drift_speed"] = float(raw["drift_speed"])
	if raw.has("float_speed"):
		item["float_speed"] = float(raw["float_speed"])
	if raw.has("float_amp"):
		item["float_amp"] = float(raw["float_amp"])
	if raw.has("static"):
		item["static"] = bool(raw["static"])
	if raw.has("span"):
		item["span"] = float(raw["span"])
	if raw.has("height"):
		item["height"] = float(raw["height"])
	if raw.has("low_slide"):
		item["low_slide"] = bool(raw["low_slide"])
	if raw.has("jump_style"):
		item["jump_style"] = String(raw["jump_style"])
	if raw.has("fall_roll"):
		item["fall_roll"] = bool(raw["fall_roll"])
	if raw.has("fall_height"):
		item["fall_height"] = float(raw["fall_height"])
	if raw.has("roll_speed"):
		item["roll_speed"] = float(raw["roll_speed"])
	if raw.has("meteor_state"):
		item["meteor_state"] = String(raw["meteor_state"])
	if raw.has("meteor_air_y"):
		item["meteor_air_y"] = float(raw["meteor_air_y"])
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
		"orb":
			return Color(1.0, 0.82, 0.25)
		"meteorite":
			return Color(0.55, 0.78, 1.0)
		"meteorite_gate":
			return Color(1.0, 0.48, 0.18)
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
