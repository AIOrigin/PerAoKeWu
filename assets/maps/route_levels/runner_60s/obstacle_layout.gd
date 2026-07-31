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
