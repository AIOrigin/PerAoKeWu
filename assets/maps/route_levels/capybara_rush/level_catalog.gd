class_name CapybaraLevelCatalog
extends RefCounted

## 读取 capybara_rush/levels 下的关卡与主题配置

const LEVELS_DIR := "res://assets/maps/route_levels/capybara_rush/levels/"
const THEMES_DIR := LEVELS_DIR + "themes/"
const PROGRESS_PATH := "user://capybara_rush_progress.cfg"
const LEVEL_COUNT := 18


static func level_path(level_id: int) -> String:
	return LEVELS_DIR + "level_%02d.json" % level_id


static func theme_path(theme_id: String) -> String:
	return THEMES_DIR + "%s.json" % theme_id


static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("CapybaraLevelCatalog missing: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	return data as Dictionary


static func load_level(level_id: int) -> Dictionary:
	var id := clampi(level_id, 1, LEVEL_COUNT)
	var cfg := load_json(level_path(id))
	if cfg.is_empty():
		cfg = {
			"id": id,
			"name": "关卡 %d" % id,
			"theme_id": "lake_clear",
			"track_length": 288.0,
			"run_speed": 12.0,
			"cliffs": 1,
			"cliff_gap_len": 11.0,
			"hazard_pattern": "theme_exam",
			"max_stair_rows": 3,
			"full_row_max_rows": 1,
			"pickup_spacing": [10, 14],
			"fruit_spacing": [16, 22],
			"finish_stairs": true,
		}
	cfg["id"] = id
	return cfg


static func load_theme(theme_id: String) -> Dictionary:
	var cfg := load_json(theme_path(theme_id))
	if cfg.is_empty():
		cfg = load_json(theme_path("lake_clear"))
	return cfg


static func load_theme_for_level(level_cfg: Dictionary) -> Dictionary:
	return load_theme(String(level_cfg.get("theme_id", "lake_clear")))


static func color3(arr: Variant, fallback: Color) -> Color:
	if typeof(arr) != TYPE_ARRAY:
		return fallback
	var a: Array = arr
	if a.size() < 3:
		return fallback
	var alpha := 1.0
	if a.size() >= 4:
		alpha = float(a[3])
	return Color(float(a[0]), float(a[1]), float(a[2]), alpha)


static func get_unlocked_max() -> int:
	var cf := ConfigFile.new()
	if cf.load(PROGRESS_PATH) != OK:
		return 1
	return clampi(int(cf.get_value("progress", "unlocked", 1)), 1, LEVEL_COUNT)


static func unlock_through(level_id: int) -> void:
	var want := clampi(level_id, 1, LEVEL_COUNT)
	var cur := get_unlocked_max()
	if want <= cur:
		return
	var cf := ConfigFile.new()
	cf.load(PROGRESS_PATH)
	cf.set_value("progress", "unlocked", want)
	cf.save(PROGRESS_PATH)


static func mark_cleared(level_id: int) -> void:
	var id := clampi(level_id, 1, LEVEL_COUNT)
	unlock_through(mini(id + 1, LEVEL_COUNT))
	var cf := ConfigFile.new()
	cf.load(PROGRESS_PATH)
	cf.set_value("cleared", "lv_%02d" % id, true)
	cf.save(PROGRESS_PATH)


static func is_cleared(level_id: int) -> bool:
	var cf := ConfigFile.new()
	if cf.load(PROGRESS_PATH) != OK:
		return false
	return bool(cf.get_value("cleared", "lv_%02d" % level_id, false))
