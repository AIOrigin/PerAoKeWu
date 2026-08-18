class_name CapybaraCustomLevels
extends RefCounted

## 卡皮巴拉自定义关卡：注册表 + JSON（供编辑器保存 / 游戏试玩加载）

const CUSTOM_DIR := CapybaraLevelLayout.CUSTOM_DIR
const INDEX_PATH := CUSTOM_DIR + "custom_levels_index.json"
const PLAYTEST_ID := "custom_playtest"
const PLAYTEST_NAME := "试玩草稿"
const EDITOR_SCENE := "res://assets/maps/route_levels/capybara_rush/level_editor/capybara_level_editor.tscn"
const GAME_SCENE := "res://assets/maps/route_levels/capybara_rush/capybara_rush.tscn"


static func list_levels(include_playtest: bool = false) -> Array:
	var root := _read_index()
	var levels: Array = root.get("levels", [])
	var out: Array = []
	for raw in levels:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var level: Dictionary = (raw as Dictionary).duplicate(true)
		if not include_playtest and String(level.get("id", "")) == PLAYTEST_ID:
			continue
		out.append(level)
	return out


static func has_level(level_id: String) -> bool:
	if level_id.is_empty():
		return false
	if FileAccess.file_exists(CUSTOM_DIR + level_id + ".json"):
		return true
	for level in list_levels(true):
		if String(level.get("id", "")) == level_id:
			return true
	return false


static func get_level_meta(level_id: String) -> Dictionary:
	for level in list_levels(true):
		if String(level.get("id", "")) == level_id:
			return (level as Dictionary).duplicate(true)
	if has_level(level_id):
		return {"id": level_id, "name": level_id, "theme_id": "lake_clear"}
	return {}


static func load_level_config(level_id: String) -> Dictionary:
	return CapybaraLevelLayout.load_level_file(level_id)


static func next_sequence() -> int:
	var max_n := 0
	for level in list_levels():
		var id := String(level.get("id", ""))
		if not id.begins_with("custom_"):
			continue
		var suffix := id.substr("custom_".length())
		if suffix.is_valid_int():
			max_n = maxi(max_n, int(suffix))
	var abs_dir := ProjectSettings.globalize_path(CUSTOM_DIR)
	var dir := DirAccess.open(abs_dir)
	if dir:
		dir.list_dir_begin()
		var fname := dir.get_next()
		while fname != "":
			if fname.begins_with("custom_") and fname.ends_with(".json"):
				var mid := fname.trim_prefix("custom_").trim_suffix(".json")
				if mid.is_valid_int():
					max_n = maxi(max_n, int(mid))
			fname = dir.get_next()
		dir.list_dir_end()
	return max_n + 1


static func format_id(seq: int) -> String:
	return "custom_%02d" % seq


static func format_name(seq: int) -> String:
	return "自定义%02d" % seq


static func create_level(cfg: Dictionary) -> Dictionary:
	var seq := next_sequence()
	var level_id := format_id(seq)
	var display_name := String(cfg.get("name", format_name(seq)))
	var entry := {
		"id": level_id,
		"name": display_name,
		"theme_id": String(cfg.get("theme_id", "lake_clear")),
		"track_length": float(cfg.get("track_length", 288.0)),
		"run_speed": float(cfg.get("run_speed", 12.0)),
		"created_at": Time.get_datetime_string_from_system(true),
		"setpiece_count": (cfg.get("placed_setpieces", []) as Array).size(),
		"jump_count": (cfg.get("jump_challenges", []) as Array).size(),
	}
	var out_cfg := cfg.duplicate(true)
	out_cfg["name"] = display_name
	out_cfg["custom_id"] = level_id
	if not CapybaraLevelLayout.save_level_file(level_id, out_cfg):
		return {}
	if not _upsert_index_entry(entry):
		return {}
	return entry


static func upsert_level(level_id: String, cfg: Dictionary) -> Dictionary:
	if level_id.is_empty():
		return {}
	var display_name := String(cfg.get("name", level_id))
	var entry := {
		"id": level_id,
		"name": display_name,
		"theme_id": String(cfg.get("theme_id", "lake_clear")),
		"track_length": float(cfg.get("track_length", 288.0)),
		"run_speed": float(cfg.get("run_speed", 12.0)),
		"updated_at": Time.get_datetime_string_from_system(true),
		"setpiece_count": (cfg.get("placed_setpieces", []) as Array).size(),
		"jump_count": (cfg.get("jump_challenges", []) as Array).size(),
	}
	var out_cfg := cfg.duplicate(true)
	out_cfg["custom_id"] = level_id
	if not CapybaraLevelLayout.save_level_file(level_id, out_cfg):
		return {}
	if not _upsert_index_entry(entry):
		return {}
	return entry


static func save_playtest(cfg: Dictionary) -> Dictionary:
	var out_cfg := cfg.duplicate(true)
	out_cfg["name"] = PLAYTEST_NAME
	out_cfg["custom_id"] = PLAYTEST_ID
	out_cfg["test_level"] = true
	if not CapybaraLevelLayout.save_level_file(PLAYTEST_ID, out_cfg):
		return {}
	return {"id": PLAYTEST_ID, "name": PLAYTEST_NAME}


static func _upsert_index_entry(entry: Dictionary) -> bool:
	var root := _read_index()
	var levels: Array = root.get("levels", [])
	var level_id := String(entry.get("id", ""))
	var found := false
	for i in levels.size():
		if typeof(levels[i]) != TYPE_DICTIONARY:
			continue
		if String((levels[i] as Dictionary).get("id", "")) == level_id:
			if (levels[i] as Dictionary).has("created_at") and not entry.has("created_at"):
				entry["created_at"] = (levels[i] as Dictionary).get("created_at")
			levels[i] = entry
			found = true
			break
	if not found:
		if not entry.has("created_at"):
			entry["created_at"] = Time.get_datetime_string_from_system(true)
		levels.append(entry)
	root["levels"] = levels
	root["version"] = 1
	root["updated_at"] = Time.get_datetime_string_from_system(true)
	return _write_index(root)


static func _read_index() -> Dictionary:
	if not FileAccess.file_exists(INDEX_PATH):
		return {"version": 1, "levels": [], "note": "Filled by capybara level editor"}
	var f := FileAccess.open(INDEX_PATH, FileAccess.READ)
	if f == null:
		return {"version": 1, "levels": []}
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return {"version": 1, "levels": []}
	return data as Dictionary


static func _write_index(root: Dictionary) -> bool:
	var abs := ProjectSettings.globalize_path(CUSTOM_DIR)
	DirAccess.make_dir_recursive_absolute(abs)
	var f := FileAccess.open(INDEX_PATH, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(root, "\t"))
	return true
