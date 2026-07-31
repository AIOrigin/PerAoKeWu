class_name CustomLevels
extends RefCounted

## 关卡编辑器导出的自定义关卡：注册表 + 障碍 JSON

const DATA_DIR := "res://assets/maps/route_levels/planets/data/"
const INDEX_PATH := DATA_DIR + "custom_levels_index.json"


static func list_levels() -> Array:
	var root := _read_index()
	var levels: Array = root.get("levels", [])
	var out: Array = []
	for raw in levels:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append((raw as Dictionary).duplicate(true))
	return out


static func has_level(level_id: String) -> bool:
	if level_id.is_empty() or not level_id.begins_with("custom_"):
		return false
	for level in list_levels():
		if String(level.get("id", "")) == level_id:
			return true
	# 注册表缺失时，仍以障碍文件为准（容错）
	return ObstacleLayout.has_layout(level_id)


static func get_level(level_id: String) -> Dictionary:
	for level in list_levels():
		if String(level.get("id", "")) == level_id:
			return (level as Dictionary).duplicate(true)
	if ObstacleLayout.has_layout(level_id):
		return {
			"id": level_id,
			"name": level_id,
			"planet_id": "glass_desert",
			"duration": 65.0,
			"task_type": "Supply Run",
		}
	return {}


static func next_sequence() -> int:
	var max_n := 0
	for level in list_levels():
		var id := String(level.get("id", ""))
		if not id.begins_with("custom_"):
			continue
		var suffix := id.substr("custom_".length())
		if suffix.is_valid_int():
			max_n = maxi(max_n, int(suffix))
	# 扫描磁盘上已有障碍文件，避免注册表不同步时撞名
	var abs_dir := ProjectSettings.globalize_path(DATA_DIR)
	var dir := DirAccess.open(abs_dir)
	if dir:
		dir.list_dir_begin()
		var fname := dir.get_next()
		while fname != "":
			if fname.begins_with("custom_") and fname.ends_with("_obstacles.json"):
				var mid := fname.trim_prefix("custom_").trim_suffix("_obstacles.json")
				if mid.is_valid_int():
					max_n = maxi(max_n, int(mid))
			fname = dir.get_next()
		dir.list_dir_end()
	return max_n + 1


static func format_id(seq: int) -> String:
	return "custom_%02d" % seq


static func format_name(seq: int) -> String:
	return "自定义%02d" % seq


static func create_level(planet_id: String, obstacles: Array, meta: Dictionary = {}) -> Dictionary:
	var seq := next_sequence()
	var level_id := format_id(seq)
	var display_name := String(meta.get("name", format_name(seq)))
	var duration := float(meta.get("duration", 65.0))
	var task_type := String(meta.get("task_type", "Supply Run"))
	var side_zones: Array = meta.get("side_runway_zones", [])
	var sand_zones: Array = meta.get("sandstorm_zones", [])
	var track_segments: Array = meta.get("track_segments", [])
	var junction_zones: Array = meta.get("junction_zones", [])
	var road_style := String(meta.get("road_style", "holographic"))
	var entry := {
		"id": level_id,
		"name": display_name,
		"planet_id": planet_id,
		"duration": duration,
		"task_type": task_type,
		"created_at": Time.get_datetime_string_from_system(true),
		"obstacle_count": obstacles.size(),
		"side_runway_count": side_zones.size(),
		"sandstorm_count": sand_zones.size(),
		"track_segment_count": track_segments.size(),
		"junction_count": junction_zones.size(),
		"road_style": road_style,
	}
	for k in meta.keys():
		if k in ["name", "duration", "task_type", "side_runway_zones", "sandstorm_zones", "track_segments", "junction_zones", "road_style"]:
			continue
		entry[k] = meta[k]
	var seg_out: Array = []
	for raw in track_segments:
		if typeof(raw) == TYPE_DICTIONARY:
			seg_out.append(ObstacleLayout.normalize_track_segment(raw))
	var ok := ObstacleLayout.save_items(level_id, obstacles, {
		"level_id": level_id,
		"level_name": display_name,
		"base_planet_id": planet_id,
		"note": "Custom level from runner level editor",
		"side_runway_zones": ObstacleLayout.sort_side_zones(side_zones),
		"sandstorm_zones": ObstacleLayout.sort_sandstorm_zones(sand_zones),
		"track_segments": seg_out,
		"junction_zones": ObstacleLayout.sort_junction_zones(junction_zones),
		"road_style": road_style,
	})
	if not ok:
		return {}
	var root := _read_index()
	var levels: Array = root.get("levels", [])
	levels.append(entry)
	root["levels"] = levels
	root["version"] = 1
	root["updated_at"] = Time.get_datetime_string_from_system(true)
	if not _write_index(root):
		return {}
	return entry


static func load_side_runway_zones(level_id: String) -> Array:
	return ObstacleLayout.load_side_runway_zones(level_id)


static func get_side_runway_zones(level_id: String) -> Array:
	return load_side_runway_zones(level_id)


static func load_sandstorm_zones(level_id: String) -> Array:
	return ObstacleLayout.load_sandstorm_zones(level_id)


static func get_sandstorm_zones(level_id: String) -> Array:
	return load_sandstorm_zones(level_id)


static func load_track_segments(level_id: String) -> Array:
	return ObstacleLayout.load_track_segments(level_id)


static func get_track_segments(level_id: String) -> Array:
	return load_track_segments(level_id)


static func load_junction_zones(level_id: String) -> Array:
	return ObstacleLayout.load_junction_zones(level_id)


static func get_junction_zones(level_id: String) -> Array:
	return load_junction_zones(level_id)


static func has_custom_track(level_id: String) -> bool:
	var root := ObstacleLayout.load_root(level_id)
	return root.has("track_segments") and not (root.get("track_segments", []) as Array).is_empty()


static func has_custom_junctions(level_id: String) -> bool:
	return ObstacleLayout.load_root(level_id).has("junction_zones")


static func load_road_style(level_id: String) -> String:
	var root := ObstacleLayout.load_root(level_id)
	return String(root.get("road_style", ""))


static func get_road_style(level_id: String) -> String:
	return load_road_style(level_id)


static func load_obstacles(level_id: String) -> Array:
	return ObstacleLayout.sort_items(ObstacleLayout.load_items(level_id))


static func load_obstacles_for_run(level_id: String, level_config: Script = null) -> Array:
	# 不在这里用星球 SIDE_RUNWAY 常量过滤：自定义关卡的侧墙区可能不同。
	# runner 会在 adapt 后再按本关 _side_runway_zones() 过滤。
	return load_obstacles(level_id)


static func make_mission(level_id: String) -> Dictionary:
	var level := get_level(level_id)
	if level.is_empty():
		return {}
	var display_name := String(level.get("name", level_id))
	var raw := {
		"location_id": level_id,
		"runner_code": "Elsa",
		"cargo_name": display_name,
		"cargo_icon": "自定义",
		"cargo_load": 100,
		"source_hearth": "关卡编辑器",
		"target_hearth": display_name,
		"task_type": String(level.get("task_type", "Supply Run")),
		"duration": float(level.get("duration", 65.0)),
		"order": 900,
		"difficulty": int(level.get("difficulty", 1)),
		"story": "编辑器导出的自定义跑酷关卡。",
		"is_custom_level": true,
	}
	return MissionTypes.enrich_mission(raw)


static func _read_index() -> Dictionary:
	if not FileAccess.file_exists(INDEX_PATH):
		return {"version": 1, "levels": []}
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	if file == null:
		return {"version": 1, "levels": []}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"version": 1, "levels": []}
	var root: Dictionary = parsed
	if not root.has("levels"):
		root["levels"] = []
	return root


static func _write_index(root: Dictionary) -> bool:
	var abs_dir := ProjectSettings.globalize_path(DATA_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var file := FileAccess.open(INDEX_PATH, FileAccess.WRITE)
	if file == null:
		push_error("CustomLevels: cannot write %s" % INDEX_PATH)
		return false
	file.store_string(JSON.stringify(root, "\t"))
	file.close()
	return true
