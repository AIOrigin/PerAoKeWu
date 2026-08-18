class_name CapybaraLevelLayout
extends RefCounted

## 卡皮巴拉关卡布局：setpiece / 三连跳 / 断崖 的 JSON 读写与规范化

const CUSTOM_DIR := "res://assets/maps/route_levels/capybara_rush/levels/custom/"

const PLACE_TYPES: Array[String] = [
	"stair_weave",
	"stair_ascend",
	"hurdle_single",
	"hurdle_wide",
	"stripe_single",
	"combo_stair_hurdle",
	"sweeper_single",
	"sweeper_duel",
	"pendulum_triple",
	"swing_hoop",
	"spin_ring",
	"l_gate",
	"fire_gate",
	"cross_rotator",
]

const PLACE_TYPE_LABELS := {
	"stair_weave": "阶梯交错",
	"stair_ascend": "阶梯上升",
	"stair_wave": "阶梯波浪",
	"hurdle_single": "单道栏",
	"hurdle_wide": "宽栏",
	"stripe_single": "单道柱",
	"combo_stair_hurdle": "阶梯+栏",
	"sweeper_single": "单扫臂",
	"sweeper_duel": "双扫臂",
	"pendulum_triple": "三连摆锤",
	"swing_hoop": "摆环",
	"spin_ring": "旋转环",
	"l_gate": "L 门",
	"fire_gate": "滑动冰闸",
	"cross_rotator": "十字转杆",
	"jump_challenge": "水池三连跳",
	"cliff": "断崖",
}

const THEME_IDS: Array[String] = [
	"lake_clear",
	"honey_pasture",
	"sakura_cloud",
	"dusk_neon",
	"tropical_beach",
	"onsen_volcano",
	"frost_snow",
]


static func place_type_label(type_id: String) -> String:
	return String(PLACE_TYPE_LABELS.get(type_id, type_id))


static func normalize_setpiece(raw: Variant) -> Dictionary:
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	var d: Dictionary = raw
	var out := {
		"type": String(d.get("type", "")),
		"dist": snappedf(float(d.get("dist", 0.0)), 0.5),
	}
	var lane := int(d.get("lane", -1))
	if lane >= 0 and lane < 3:
		out["lane"] = lane
	return out


static func sort_setpieces(items: Array) -> Array:
	var out: Array = []
	for raw in items:
		var it := normalize_setpiece(raw)
		if String(it.get("type", "")).is_empty():
			continue
		out.append(it)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("dist", 0.0)) < float(b.get("dist", 0.0))
	)
	return out


static func normalize_jump_challenge(raw: Variant) -> Dictionary:
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	var d: Dictionary = raw
	return {
		"dist": snappedf(float(d.get("dist", 40.0)), 0.5),
		"spacing": maxf(float(d.get("spacing", 8.8)), 6.0),
		"pad_count": clampi(int(d.get("pad_count", 3)), 2, 5),
		"pad_half_len": maxf(float(d.get("pad_half_len", 1.6)), 0.8),
		"pad_half_lat": maxf(float(d.get("pad_half_lat", 0.75)), 0.4),
		"lane": clampi(int(d.get("lane", 1)), 0, 2),
	}


static func sort_jump_challenges(items: Array) -> Array:
	var out: Array = []
	for raw in items:
		out.append(normalize_jump_challenge(raw))
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("dist", 0.0)) < float(b.get("dist", 0.0))
	)
	return out


static func default_level_cfg() -> Dictionary:
	return {
		"id": 0,
		"name": "新关卡",
		"theme_id": "lake_clear",
		"track_length": 288.0,
		"run_speed": 12.0,
		"time_limit_sec": 0,
		"cliffs": 0,
		"cliff_gap_len": 11.0,
		"hazard_seed": int(Time.get_unix_time_from_system()) % 100000,
		"hazard_pattern": "manual",
		"max_stair_rows": 3,
		"allow_full_row_blocks": true,
		"full_row_max_rows": 1,
		"pickup_spacing": [10, 14],
		"fruit_spacing": [16, 22],
		"finish_stairs": true,
		"difficulty": 3,
		"placed_setpieces": [],
		"jump_challenges": [],
		"note": "Custom level from capybara level editor",
	}


static func build_level_cfg(meta: Dictionary, setpieces: Array, jump_challenges: Array = []) -> Dictionary:
	var cfg := default_level_cfg()
	for k in meta.keys():
		cfg[k] = meta[k]
	cfg["hazard_pattern"] = "manual"
	cfg["placed_setpieces"] = sort_setpieces(setpieces)
	cfg["jump_challenges"] = sort_jump_challenges(jump_challenges)
	return cfg


static func load_level_file(level_id: String) -> Dictionary:
	var path := CUSTOM_DIR + level_id + ".json"
	if not FileAccess.file_exists(path):
		push_warning("CapybaraLevelLayout missing: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var data = JSON.parse_string(f.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	var cfg: Dictionary = data
	if cfg.has("placed_setpieces"):
		cfg["placed_setpieces"] = sort_setpieces(cfg["placed_setpieces"])
	if cfg.has("jump_challenges"):
		cfg["jump_challenges"] = sort_jump_challenges(cfg["jump_challenges"])
	cfg["hazard_pattern"] = "manual"
	return cfg


static func save_level_file(level_id: String, cfg: Dictionary) -> bool:
	var path := CUSTOM_DIR + level_id + ".json"
	var abs := ProjectSettings.globalize_path(CUSTOM_DIR)
	DirAccess.make_dir_recursive_absolute(abs)
	var out := cfg.duplicate(true)
	out["hazard_pattern"] = "manual"
	out["updated_at"] = Time.get_datetime_string_from_system(true)
	if out.has("placed_setpieces"):
		out["placed_setpieces"] = sort_setpieces(out["placed_setpieces"])
	if out.has("jump_challenges"):
		out["jump_challenges"] = sort_jump_challenges(out["jump_challenges"])
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("CapybaraLevelLayout cannot write: %s" % path)
		return false
	f.store_string(JSON.stringify(out, "\t"))
	return true
