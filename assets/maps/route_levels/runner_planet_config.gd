class_name RunnerPlanetConfig
extends RefCounted

## 跑酷星球配置基类 — 各星球脚本需实现同名 static API

static func get_planet_id() -> String:
	return ""

static func get_theme() -> Dictionary:
	return {}

static func get_assets() -> Dictionary:
	return {}


static func get_mission_for_location(_location_id: String) -> Dictionary:
	return {}


static func get_location_missions() -> Array:
	return []
