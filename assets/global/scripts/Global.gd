#class_name Global Code
extends Node

signal main_player_ready
signal global_scenes_ready
signal sky_limit_ready

const explod_max_speed: float = 100.0 ## m
const default_gravity: float = 9.8
const Hl = preload("res://assets/global/scripts/HL.gd")
const MOBILE_PROGRESS_SAVE_PATH := "user://mobile_progress.json"
const MOBILE_PROGRESS_VERSION := 5
const CharacterProgression = preload("res://assets/maps/route_levels/character_progression.gd")
const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")
const DEFAULT_OUTPOST_REPAIR_TOTAL := 400


###
# 旧 FPS 全局场景已移除；跑酷只依赖下方进度字段
###
var GLOBAL_SCENES_LIST_START = "GLOBAL_SCENES_LIST_START"
var GLOBAL_SCENES_LIST_END = "GLOBAL_SCENES_LIST_END"
###
var global_scenes_list: Array = []


# 其他
var main_player = null
var main_player_camera = null
var sky_limit = null
var runner_planet_id: String = "glass_desert"
var exploration_planet_id: String = "glass_desert"
var runner_location_id: String = "dome"
## 跑酷结束后回到的场景；空则回探索地图
var runner_return_scene: String = ""
## 跑酷跑道外观（进关前选择，与背景独立）
var runner_road_style: String = "holographic"
## 跑酷场景背景（天空 + 两侧地形，与跑道独立）
var runner_background_style: String = "desert_crystal"
var selected_ship_id: String = "spark_moth"
var selected_character_id: String = "elsa"
var mobile_home_tab: String = "home"
var pending_location_showcase_id: String = ""
var first_launch_story_seen: bool = false
var home_guide_seen: bool = false
## 跑酷新手引导总开关（设置里可关）
var runner_tutorial_enabled: bool = true
## 分项：jump / slide / lane / shield / fork / sandstorm / wall_run
var runner_tutorial_seen: Dictionary = {}
## 兼容旧字段
var runner_wall_run_tutorial_seen: bool = false
var ember_coins: int = 0
var gold_coins: int = 1280
var runner_energy: int = 86
var runner_energy_max: int = 120
var messenger_xp: int = 0
var messenger_cargo_guard_level: int = 0
var messenger_coin_bonus_level: int = 0
var messenger_mobility_level: int = 0
var messenger_unlocked_stories: Array[String] = []
var exploration_revealed_locations_by_planet: Dictionary = {}
var completed_runner_locations_by_planet: Dictionary = {}
# planet_id -> { location_id: int }  据点运输累计进度（装载量×完整度%）
var runner_outpost_progress_by_planet: Dictionary = {}
# planet_id -> Array[String]  任务板 3 槽（location_id）
var mission_board_slots_by_planet: Dictionary = {}
# planet_id -> int  已解锁到第几批（1/2/3）
var unlocked_mission_batch_by_planet: Dictionary = {}
# planet_id -> { "location_id": String }  当前指派/进行中的运输任务
var active_missions_by_planet: Dictionary = {}

var paused_time_process: float = 0.0
var paused_time_physics_process: float = 0.0

var gravity_value: float
var gravity_vector: Vector3
var gravity: Vector3:
	get():
		return gravity_vector * gravity_value


func _ready() -> void:
	load_mobile_progress()
	ensure_mission_dispatch_ready("glass_desert")
	gravity_value = ProjectSettings.get_setting("physics/3d/default_gravity")
	gravity_vector = ProjectSettings.get_setting("physics/3d/default_gravity_vector")




func _process(_delta: float) -> void:
	if not get_tree().paused:
		paused_time_process += _delta


func _physics_process(_delta: float) -> void:
	if not get_tree().paused:
		paused_time_physics_process += _delta


func _global_scenes_ready() -> void:
	paused_time_process = 0.0
	paused_time_physics_process = 0.0
	global_scenes_ready.emit()


func ready_global_scenes() -> void:
	# 旧 FPS 全局场景装配已移除
	pass


func reload_current_scene() -> void:
	get_tree().reload_current_scene()


func change_game_scene(scene_path: String) -> void:
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to change scene: %s error=%s" % [scene_path, error])
		return
	call_deferred("_ready_global_scenes_after_scene_change")


func get_revealed_exploration_locations(planet_id: String, fallback_ids: Array[String]) -> Array[String]:
	var stored: Array = exploration_revealed_locations_by_planet.get(planet_id, fallback_ids.duplicate())
	var result: Array[String] = []
	for id in stored:
		var location_id := String(id)
		if location_id != "" and not result.has(location_id):
			result.append(location_id)
	return result


func set_revealed_exploration_locations(planet_id: String, location_ids: Array[String]) -> void:
	var stored: Array[String] = []
	for location_id in location_ids:
		if location_id != "" and not stored.has(location_id):
			stored.append(location_id)
	exploration_revealed_locations_by_planet[planet_id] = stored
	save_mobile_progress()


func mark_runner_location_completed(planet_id: String, location_id: String) -> bool:
	if planet_id == "" or location_id == "":
		return false
	var completed: Array = completed_runner_locations_by_planet.get(planet_id, [])
	if completed.has(location_id):
		return false
	completed.append(location_id)
	completed_runner_locations_by_planet[planet_id] = completed
	var repair_total := get_outpost_repair_total(planet_id, location_id)
	_set_outpost_progress_value(planet_id, location_id, repair_total)
	var active: Dictionary = get_active_mission(planet_id)
	if String(active.get("location_id", "")) == location_id:
		# 先清任务再同步派发，避免 sync 存盘时仍带着旧 active
		if active_missions_by_planet.has(planet_id):
			active_missions_by_planet.erase(planet_id)
	sync_mission_dispatch(planet_id)
	return true


func get_outpost_progress(planet_id: String, location_id: String) -> int:
	if planet_id == "" or location_id == "":
		return 0
	if get_completed_runner_locations(planet_id).has(location_id):
		return get_outpost_repair_total(planet_id, location_id)
	var planet_progress: Dictionary = runner_outpost_progress_by_planet.get(planet_id, {})
	return maxi(0, int(planet_progress.get(location_id, 0)))


func get_outpost_repair_total(planet_id: String, location_id: String) -> int:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_outpost_meta"):
		var meta: Dictionary = cfg.get_outpost_meta(location_id)
		if not meta.is_empty():
			return maxi(1, int(meta.get("repair_total", DEFAULT_OUTPOST_REPAIR_TOTAL)))
	return DEFAULT_OUTPOST_REPAIR_TOTAL


## 结算写入据点进度。贡献 = round(装载量 × 完整度%)。满额才点亮。
## 返回：contribution / progress_before / progress_after / repair_total / newly_lit / already_lit / unlocked_batch / batch_just_unlocked
func apply_runner_delivery_progress(
	planet_id: String,
	location_id: String,
	cargo_load: int,
	integrity_percent: float,
	repair_total: int = -1
) -> Dictionary:
	var total := repair_total if repair_total > 0 else get_outpost_repair_total(planet_id, location_id)
	total = maxi(1, total)
	var contribution := int(round(float(maxi(cargo_load, 0)) * clampf(integrity_percent, 0.0, 100.0) * 0.01))
	var already_lit := get_completed_runner_locations(planet_id).has(location_id)
	var before := get_outpost_progress(planet_id, location_id)
	var previous_batch := get_unlocked_mission_batch(planet_id)
	if already_lit:
		var dispatch_lit := sync_mission_dispatch(planet_id)
		return {
			"contribution": 0,
			"progress_before": before,
			"progress_after": total,
			"repair_total": total,
			"newly_lit": false,
			"already_lit": true,
			"unlocked_batch": int(dispatch_lit.get("unlocked_batch", previous_batch)),
			"batch_just_unlocked": false,
			"board_slots": dispatch_lit.get("board_slots", []),
		}
	var after := mini(before + maxi(contribution, 0), total)
	_set_outpost_progress_value(planet_id, location_id, after)
	var newly_lit := after >= total
	if newly_lit:
		mark_runner_location_completed(planet_id, location_id)
	else:
		sync_mission_dispatch(planet_id)
	var unlocked_batch := get_unlocked_mission_batch(planet_id)
	return {
		"contribution": contribution,
		"progress_before": before,
		"progress_after": after if not newly_lit else total,
		"repair_total": total,
		"newly_lit": newly_lit,
		"already_lit": false,
		"unlocked_batch": unlocked_batch,
		"batch_just_unlocked": unlocked_batch > previous_batch,
		"board_slots": get_mission_board_slots(planet_id),
	}


func _set_outpost_progress_value(planet_id: String, location_id: String, value: int) -> void:
	if planet_id == "" or location_id == "":
		return
	var planet_progress: Dictionary = runner_outpost_progress_by_planet.get(planet_id, {}).duplicate()
	planet_progress[location_id] = maxi(0, value)
	runner_outpost_progress_by_planet[planet_id] = planet_progress


func get_unlocked_mission_batch(planet_id: String) -> int:
	if planet_id == "":
		return 1
	if unlocked_mission_batch_by_planet.has(planet_id):
		return clampi(int(unlocked_mission_batch_by_planet[planet_id]), 1, 3)
	return MissionDispatch.compute_unlocked_batch(planet_id)


func get_mission_board_slots(planet_id: String) -> Array[String]:
	var result: Array[String] = []
	if planet_id == "":
		return result
	var raw: Variant = mission_board_slots_by_planet.get(planet_id, [])
	if raw is Array:
		for value in raw:
			var location_id := String(value)
			if location_id != "" and not result.has(location_id):
				result.append(location_id)
	return result


func is_mission_on_board(planet_id: String, location_id: String) -> bool:
	return get_mission_board_slots(planet_id).has(location_id)


## 同步批次解锁、地图揭示与 3 槽任务板。返回 unlocked_batch / batch_just_unlocked / board_slots / revealed_added
func sync_mission_dispatch(planet_id: String) -> Dictionary:
	if planet_id == "":
		return {
			"unlocked_batch": 1,
			"batch_just_unlocked": false,
			"board_slots": [],
			"revealed_added": [],
		}
	var previous_batch := int(unlocked_mission_batch_by_planet.get(planet_id, 0))
	var unlocked_batch := MissionDispatch.compute_unlocked_batch(planet_id)
	unlocked_mission_batch_by_planet[planet_id] = unlocked_batch
	var batch_just_unlocked := previous_batch > 0 and unlocked_batch > previous_batch

	var revealed := get_revealed_exploration_locations(planet_id, MissionDispatch.get_batch1_location_ids(planet_id))
	var revealed_added: Array[String] = []
	for location_id in MissionDispatch.get_batch_location_ids(planet_id, unlocked_batch):
		if not revealed.has(location_id):
			revealed.append(location_id)
			revealed_added.append(location_id)
	# 直接写揭示表，避免 set_revealed 再触发一次额外存盘
	exploration_revealed_locations_by_planet[planet_id] = revealed

	var board := MissionDispatch.fill_board_slots(
		planet_id,
		get_mission_board_slots(planet_id),
		unlocked_batch
	)
	mission_board_slots_by_planet[planet_id] = board
	save_mobile_progress()
	return {
		"unlocked_batch": unlocked_batch,
		"batch_just_unlocked": batch_just_unlocked,
		"board_slots": board,
		"revealed_added": revealed_added,
	}


func ensure_mission_dispatch_ready(planet_id: String = "glass_desert") -> void:
	if planet_id == "":
		planet_id = "glass_desert"
	sync_mission_dispatch(planet_id)


func get_active_mission(planet_id: String) -> Dictionary:
	var raw: Variant = active_missions_by_planet.get(planet_id, {})
	if raw is Dictionary:
		var location_id := String(raw.get("location_id", ""))
		if location_id != "":
			return {"location_id": location_id}
	return {}


func set_active_mission(planet_id: String, location_id: String) -> void:
	if planet_id == "" or location_id == "":
		return
	if get_completed_runner_locations(planet_id).has(location_id):
		return
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		return
	active_missions_by_planet[planet_id] = {"location_id": location_id}
	save_mobile_progress()


func clear_active_mission(planet_id: String) -> void:
	if planet_id == "":
		return
	if active_missions_by_planet.has(planet_id):
		active_missions_by_planet.erase(planet_id)
		save_mobile_progress()


func is_active_mission(planet_id: String, location_id: String) -> bool:
	return String(get_active_mission(planet_id).get("location_id", "")) == location_id


## 校验进行中任务：已完成或未点亮则清除。返回仍有效的任务（可能为空）。
func validate_active_mission(planet_id: String) -> Dictionary:
	var current := get_active_mission(planet_id)
	var location_id := String(current.get("location_id", ""))
	if location_id == "":
		return {}
	if get_completed_runner_locations(planet_id).has(location_id):
		clear_active_mission(planet_id)
		return {}
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		clear_active_mission(planet_id)
		return {}
	if not get_revealed_exploration_locations(planet_id, MissionDispatch.get_batch1_location_ids(planet_id)).has(location_id):
		clear_active_mission(planet_id)
		return {}
	return current


func add_ember_coins(amount: int) -> void:
	ember_coins = max(0, ember_coins + amount)
	save_mobile_progress()


func get_messenger_snapshot() -> Dictionary:
	return CharacterProgression.build_snapshot(
		CharacterProgression.level_from_xp(messenger_xp),
		messenger_xp,
		messenger_cargo_guard_level,
		messenger_coin_bonus_level,
		messenger_mobility_level,
		ember_coins,
		messenger_unlocked_stories
	)


func get_cargo_damage_multiplier() -> float:
	return CharacterProgression.cargo_damage_multiplier(messenger_cargo_guard_level)


func get_coin_yield_multiplier() -> float:
	return CharacterProgression.coin_yield_multiplier(messenger_coin_bonus_level)


func get_lane_change_ease_bonus() -> float:
	return CharacterProgression.lane_change_ease_bonus(messenger_mobility_level)


func grant_messenger_runner_rewards(grade: String, difficulty: int, first_clear: bool) -> Dictionary:
	var xp_gain := CharacterProgression.runner_xp_reward(grade, difficulty, first_clear)
	var old_level := CharacterProgression.level_from_xp(messenger_xp)
	messenger_xp = maxi(messenger_xp + xp_gain, 0)
	var new_level := CharacterProgression.level_from_xp(messenger_xp)
	if first_clear and Global.runner_location_id == "dome" and Global.runner_planet_id == "glass_desert":
		_unlock_messenger_story("dome_resident")
	save_mobile_progress()
	return {
		"xp_gain": xp_gain,
		"level_up": new_level > old_level,
		"old_level": old_level,
		"new_level": new_level,
	}


func try_upgrade_messenger_stat(stat_id: String) -> bool:
	var current_level := _get_messenger_stat_level(stat_id)
	if not CharacterProgression.can_upgrade(stat_id, current_level, ember_coins):
		return false
	var cost := CharacterProgression.upgrade_cost(stat_id, current_level)
	ember_coins -= cost
	_set_messenger_stat_level(stat_id, current_level + 1)
	save_mobile_progress()
	return true


func _get_messenger_stat_level(stat_id: String) -> int:
	match stat_id:
		CharacterProgression.STAT_CARGO_GUARD:
			return messenger_cargo_guard_level
		CharacterProgression.STAT_COIN_BONUS:
			return messenger_coin_bonus_level
		CharacterProgression.STAT_MOBILITY:
			return messenger_mobility_level
	return 0


func _set_messenger_stat_level(stat_id: String, level: int) -> void:
	var clamped := clampi(level, 0, CharacterProgression.MAX_STAT_LEVEL)
	match stat_id:
		CharacterProgression.STAT_CARGO_GUARD:
			messenger_cargo_guard_level = clamped
		CharacterProgression.STAT_COIN_BONUS:
			messenger_coin_bonus_level = clamped
		CharacterProgression.STAT_MOBILITY:
			messenger_mobility_level = clamped


func _unlock_messenger_story(story_id: String) -> void:
	if story_id == "" or messenger_unlocked_stories.has(story_id):
		return
	messenger_unlocked_stories.append(story_id)


func mark_first_launch_story_seen() -> void:
	first_launch_story_seen = true
	save_mobile_progress()


func mark_home_guide_seen() -> void:
	home_guide_seen = true
	save_mobile_progress()


func mark_runner_wall_run_tutorial_seen() -> void:
	mark_runner_tutorial_seen("wall_run")


func is_runner_tutorial_enabled() -> bool:
	return runner_tutorial_enabled


func set_runner_tutorial_enabled(enabled: bool) -> void:
	runner_tutorial_enabled = enabled
	save_mobile_progress()


func has_seen_runner_tutorial(key: String) -> bool:
	if key == "wall_run" and runner_wall_run_tutorial_seen:
		return true
	return bool(runner_tutorial_seen.get(key, false))


func mark_runner_tutorial_seen(key: String) -> void:
	if key == "":
		return
	if bool(runner_tutorial_seen.get(key, false)):
		if key == "wall_run":
			runner_wall_run_tutorial_seen = true
		return
	runner_tutorial_seen[key] = true
	if key == "wall_run":
		runner_wall_run_tutorial_seen = true
	save_mobile_progress()


func reset_runner_tutorials() -> void:
	runner_tutorial_seen.clear()
	runner_wall_run_tutorial_seen = false
	save_mobile_progress()


func should_show_runner_tutorial(key: String) -> bool:
	return runner_tutorial_enabled and not has_seen_runner_tutorial(key)


func set_selected_ship(ship_id: String) -> void:
	if ship_id == "":
		return
	selected_ship_id = ship_id
	save_mobile_progress()


func set_selected_character(character_id: String) -> void:
	if character_id == "":
		return
	selected_character_id = character_id
	save_mobile_progress()


func get_selected_character_id() -> String:
	return selected_character_id


const RUNNER_ROAD_STYLE_ORDER: Array[String] = ["holographic", "alien_energy", "energy_neon", "planet", "coarse_desert", "rust_metal", "void_crystal"]
const RUNNER_ROAD_STYLE_LABELS := {
	"holographic": "全息能量轨",
	"alien_energy": "异星能量轨",
	"energy_neon": "能量霓虹",
	"planet": "星球默认",
	"coarse_desert": "粗粝沙漠",
	"rust_metal": "锈蚀金属",
	"void_crystal": "虚空晶体",
}


func get_runner_road_style() -> String:
	return normalize_runner_road_style(runner_road_style)


func get_runner_road_style_label(style_id: String = "") -> String:
	var id := normalize_runner_road_style(style_id if style_id != "" else runner_road_style)
	return String(RUNNER_ROAD_STYLE_LABELS.get(id, id))


func normalize_runner_road_style(style_id: String) -> String:
	if RUNNER_ROAD_STYLE_ORDER.has(style_id):
		return style_id
	return "holographic"


func set_runner_road_style(style_id: String) -> void:
	runner_road_style = normalize_runner_road_style(style_id)
	save_mobile_progress()


func cycle_runner_road_style() -> String:
	var current := get_runner_road_style()
	var idx := RUNNER_ROAD_STYLE_ORDER.find(current)
	if idx < 0:
		idx = 0
	runner_road_style = RUNNER_ROAD_STYLE_ORDER[(idx + 1) % RUNNER_ROAD_STYLE_ORDER.size()]
	save_mobile_progress()
	return runner_road_style


const RUNNER_BACKGROUND_STYLE_ORDER: Array[String] = [
	"void_dark",
	"desert_crystal",
	"industrial_ruin",
	"savanna",
	"starfield",
]
const RUNNER_BACKGROUND_STYLE_LABELS := {
	"void_dark": "虚空暗域",
	"desert_crystal": "晶砂荒漠",
	"industrial_ruin": "工业废墟",
	"savanna": "稀树草原",
	"starfield": "深空星野",
}


func get_runner_background_style() -> String:
	return normalize_runner_background_style(runner_background_style)


func get_runner_background_style_label(style_id: String = "") -> String:
	var id := normalize_runner_background_style(style_id if style_id != "" else runner_background_style)
	return String(RUNNER_BACKGROUND_STYLE_LABELS.get(id, id))


func normalize_runner_background_style(style_id: String) -> String:
	if RUNNER_BACKGROUND_STYLE_ORDER.has(style_id):
		return style_id
	return "desert_crystal"


func set_runner_background_style(style_id: String) -> void:
	runner_background_style = normalize_runner_background_style(style_id)
	save_mobile_progress()


func populate_runner_road_style_option(option: OptionButton) -> void:
	option.clear()
	for style_id in RUNNER_ROAD_STYLE_ORDER:
		option.add_item(get_runner_road_style_label(style_id))
	var idx := RUNNER_ROAD_STYLE_ORDER.find(get_runner_road_style())
	option.select(maxi(idx, 0))


func populate_runner_background_style_option(option: OptionButton) -> void:
	option.clear()
	for style_id in RUNNER_BACKGROUND_STYLE_ORDER:
		option.add_item(get_runner_background_style_label(style_id))
	var idx := RUNNER_BACKGROUND_STYLE_ORDER.find(get_runner_background_style())
	option.select(maxi(idx, 0))


func save_mobile_progress() -> void:
	var data := {
		"version": MOBILE_PROGRESS_VERSION,
		"first_launch_story_seen": first_launch_story_seen,
		"home_guide_seen": home_guide_seen,
		"runner_tutorial_enabled": runner_tutorial_enabled,
		"runner_tutorial_seen": runner_tutorial_seen.duplicate(true),
		"runner_wall_run_tutorial_seen": runner_wall_run_tutorial_seen or bool(runner_tutorial_seen.get("wall_run", false)),
		"ember_coins": ember_coins,
		"gold_coins": gold_coins,
		"runner_energy": runner_energy,
		"runner_energy_max": runner_energy_max,
		"messenger_xp": messenger_xp,
		"messenger_cargo_guard_level": messenger_cargo_guard_level,
		"messenger_coin_bonus_level": messenger_coin_bonus_level,
		"messenger_mobility_level": messenger_mobility_level,
		"messenger_unlocked_stories": messenger_unlocked_stories.duplicate(),
		"selected_ship_id": selected_ship_id,
		"selected_character_id": selected_character_id,
		"runner_road_style": get_runner_road_style(),
		"runner_background_style": get_runner_background_style(),
		"exploration_revealed_locations_by_planet": _string_array_dict_to_save_data(exploration_revealed_locations_by_planet),
		"completed_runner_locations_by_planet": _string_array_dict_to_save_data(completed_runner_locations_by_planet),
		"runner_outpost_progress_by_planet": _int_dict_dict_to_save_data(runner_outpost_progress_by_planet),
		"mission_board_slots_by_planet": _string_array_dict_to_save_data(mission_board_slots_by_planet),
		"unlocked_mission_batch_by_planet": _int_dict_to_save_data(unlocked_mission_batch_by_planet),
		"active_missions_by_planet": active_missions_by_planet.duplicate(true),
	}
	var file := FileAccess.open(MOBILE_PROGRESS_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Failed to save mobile progress: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data, "\t"))


func load_mobile_progress() -> void:
	if not FileAccess.file_exists(MOBILE_PROGRESS_SAVE_PATH):
		return
	var file := FileAccess.open(MOBILE_PROGRESS_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Failed to load mobile progress: %s" % FileAccess.get_open_error())
		return
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or not (json.data is Dictionary):
		push_warning("Failed to parse mobile progress save.")
		return
	var data: Dictionary = json.data
	first_launch_story_seen = bool(data.get("first_launch_story_seen", first_launch_story_seen))
	home_guide_seen = bool(data.get("home_guide_seen", home_guide_seen))
	runner_tutorial_enabled = bool(data.get("runner_tutorial_enabled", true))
	runner_tutorial_seen = {}
	var seen_raw: Variant = data.get("runner_tutorial_seen", {})
	if typeof(seen_raw) == TYPE_DICTIONARY:
		for k in (seen_raw as Dictionary).keys():
			runner_tutorial_seen[String(k)] = bool((seen_raw as Dictionary)[k])
	runner_wall_run_tutorial_seen = bool(data.get("runner_wall_run_tutorial_seen", runner_wall_run_tutorial_seen))
	if runner_wall_run_tutorial_seen:
		runner_tutorial_seen["wall_run"] = true
	ember_coins = max(0, int(data.get("ember_coins", ember_coins)))
	gold_coins = max(0, int(data.get("gold_coins", gold_coins)))
	runner_energy_max = maxi(1, int(data.get("runner_energy_max", runner_energy_max)))
	runner_energy = clampi(int(data.get("runner_energy", runner_energy)), 0, runner_energy_max)
	messenger_xp = maxi(0, int(data.get("messenger_xp", messenger_xp)))
	messenger_cargo_guard_level = clampi(int(data.get("messenger_cargo_guard_level", messenger_cargo_guard_level)), 0, CharacterProgression.MAX_STAT_LEVEL)
	messenger_coin_bonus_level = clampi(int(data.get("messenger_coin_bonus_level", messenger_coin_bonus_level)), 0, CharacterProgression.MAX_STAT_LEVEL)
	messenger_mobility_level = clampi(int(data.get("messenger_mobility_level", messenger_mobility_level)), 0, CharacterProgression.MAX_STAT_LEVEL)
	messenger_unlocked_stories = _load_string_array(data.get("messenger_unlocked_stories", []))
	selected_ship_id = String(data.get("selected_ship_id", selected_ship_id))
	selected_character_id = String(data.get("selected_character_id", selected_character_id))
	runner_road_style = normalize_runner_road_style(String(data.get("runner_road_style", runner_road_style)))
	runner_background_style = normalize_runner_background_style(
		String(data.get("runner_background_style", runner_background_style))
	)
	exploration_revealed_locations_by_planet = _save_data_to_string_array_dict(data.get("exploration_revealed_locations_by_planet", {}))
	completed_runner_locations_by_planet = _save_data_to_string_array_dict(data.get("completed_runner_locations_by_planet", {}))
	runner_outpost_progress_by_planet = _save_data_to_int_dict_dict(data.get("runner_outpost_progress_by_planet", {}))
	mission_board_slots_by_planet = _save_data_to_string_array_dict(data.get("mission_board_slots_by_planet", {}))
	unlocked_mission_batch_by_planet = _save_data_to_int_dict(data.get("unlocked_mission_batch_by_planet", {}))
	active_missions_by_planet = _save_data_to_active_missions_dict(data.get("active_missions_by_planet", {}))
	_sync_completed_outpost_progress()
	_sync_messenger_story_unlocks()


func _sync_messenger_story_unlocks() -> void:
	if get_completed_runner_locations("glass_desert").has("dome"):
		_unlock_messenger_story("dome_resident")


func _sync_completed_outpost_progress() -> void:
	# 旧存档：已点亮据点补满进度条，避免显示 0/400
	for planet_id in completed_runner_locations_by_planet.keys():
		var planet_key := String(planet_id)
		for location_id in get_completed_runner_locations(planet_key):
			var total := get_outpost_repair_total(planet_key, location_id)
			var planet_progress: Dictionary = runner_outpost_progress_by_planet.get(planet_key, {})
			if int(planet_progress.get(location_id, 0)) < total:
				_set_outpost_progress_value(planet_key, location_id, total)


func reset_mobile_progress() -> void:
	first_launch_story_seen = false
	home_guide_seen = false
	runner_tutorial_enabled = true
	runner_tutorial_seen.clear()
	runner_wall_run_tutorial_seen = false
	ember_coins = 0
	gold_coins = 1280
	runner_energy = 86
	runner_energy_max = 120
	messenger_xp = 0
	messenger_cargo_guard_level = 0
	messenger_coin_bonus_level = 0
	messenger_mobility_level = 0
	messenger_unlocked_stories.clear()
	selected_ship_id = "spark_moth"
	selected_character_id = "elsa"
	runner_road_style = "holographic"
	runner_background_style = "desert_crystal"
	exploration_revealed_locations_by_planet.clear()
	completed_runner_locations_by_planet.clear()
	runner_outpost_progress_by_planet.clear()
	mission_board_slots_by_planet.clear()
	unlocked_mission_batch_by_planet.clear()
	active_missions_by_planet.clear()
	if FileAccess.file_exists(MOBILE_PROGRESS_SAVE_PATH):
		DirAccess.remove_absolute(MOBILE_PROGRESS_SAVE_PATH)


func _string_array_dict_to_save_data(source: Dictionary) -> Dictionary:
	var result := {}
	for key in source.keys():
		var values: Array = source[key]
		var stored: Array[String] = []
		for value in values:
			var text := String(value)
			if text != "" and not stored.has(text):
				stored.append(text)
		result[String(key)] = stored
	return result


func _int_dict_dict_to_save_data(source: Dictionary) -> Dictionary:
	var result := {}
	for planet_key in source.keys():
		var raw: Variant = source[planet_key]
		if not (raw is Dictionary):
			continue
		var stored := {}
		for location_key in raw.keys():
			stored[String(location_key)] = maxi(0, int(raw[location_key]))
		result[String(planet_key)] = stored
	return result


func _int_dict_to_save_data(source: Dictionary) -> Dictionary:
	var result := {}
	for key in source.keys():
		result[String(key)] = maxi(0, int(source[key]))
	return result


func _save_data_to_int_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for key in source.keys():
		result[String(key)] = maxi(0, int(source[key]))
	return result


func _save_data_to_int_dict_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for planet_key in source.keys():
		var raw: Variant = source[planet_key]
		if not (raw is Dictionary):
			continue
		var stored := {}
		for location_key in raw.keys():
			stored[String(location_key)] = maxi(0, int(raw[location_key]))
		result[String(planet_key)] = stored
	return result


func _load_string_array(source_variant: Variant) -> Array[String]:
	var result: Array[String] = []
	if source_variant is Array:
		for value in source_variant:
			var text := String(value)
			if text != "" and not result.has(text):
				result.append(text)
	return result


func _save_data_to_string_array_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for key in source.keys():
		var stored: Array[String] = []
		var values: Variant = source[key]
		if values is Array:
			for value in values:
				var text := String(value)
				if text != "" and not stored.has(text):
					stored.append(text)
		result[String(key)] = stored
	return result


func _save_data_to_active_missions_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for key in source.keys():
		var entry: Variant = source[key]
		if entry is Dictionary:
			var location_id := String(entry.get("location_id", ""))
			if location_id != "":
				result[String(key)] = {"location_id": location_id}
		elif typeof(entry) == TYPE_STRING:
			var location_id := String(entry)
			if location_id != "":
				result[String(key)] = {"location_id": location_id}
	return result


func get_completed_runner_locations(planet_id: String) -> Array[String]:
	var completed: Array = completed_runner_locations_by_planet.get(planet_id, [])
	var result: Array[String] = []
	for id in completed:
		var location_id := String(id)
		if location_id != "" and not result.has(location_id):
			result.append(location_id)
	return result


func _ready_global_scenes_after_scene_change() -> void:
	await get_tree().process_frame
	if not get_tree().current_scene:
		return
	if get_tree().current_scene.is_in_group("RunnerGameScene"):
		ready_runner_global_scenes()
		return
	if get_tree().current_scene.is_in_group("GalaxyMapScene"):
		set_mouse_mode()
		return
	set_mouse_mode()


func ready_runner_global_scenes() -> void:
	set_mouse_mode()


func get_delta_time() -> float:
	if Engine.is_in_physics_frame():
		return get_physics_process_delta_time()
	return get_process_delta_time()


# Global.set_mouse_mode()
func set_mouse_mode() -> void:
	# 竖屏手游：默认可见光标；桌面跑酷也保持可见（暂停/UI 可点）
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func is_tool_ui_move_camera() -> bool:
	return false


func tool_ui_visible() -> bool:
	return false




# 返回两个标识名称(键"name"为"START"和"END")中间字典的数组
static func get_dicts_between_start_end(dict_array: Array, start: String = "START", end: String = "END") -> Array:
	var result := []
	var started := false

	for dict in dict_array:
		if dict.name == start:
			started = true
			continue
		if dict.name == end:
			break
		if started:
			result.append(dict)

	return result


"""
下边是弃用的 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
"""


# 获取指定文件夹下特定类型的随机资源
# folder_path: 文件夹路径（如"res://assets/sounds"）
# allowed_types: 允许的资源类型数组（如["PackedScene", "Texture2D"]），留空则允许所有类型
func get_random_resource(folder_path: String, allowed_types: Array = []) -> Resource:
	# 用于存储符合条件的资源路径
	var valid_resources := []

	# 检查文件夹是否存在
	if not DirAccess.dir_exists_absolute(folder_path):
		push_error("Folder does not exist: " + folder_path)
		return null

	# 遍历目录
	var dir := DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			# 跳过目录和隐藏文件
			if not dir.current_is_dir() and not file_name.begins_with("."):
				var full_path := folder_path.path_join(file_name)
				# 检查文件扩展名是否是资源类型
				if ResourceLoader.exists(full_path):
					# 如果指定了类型限制，则检查类型
					if allowed_types.is_empty():
						valid_resources.append(full_path)
					else:
						var rfl := ResourceFormatLoader.new()
						var resource_type := rfl._get_resource_type(full_path) # buggggggg
						if resource_type in allowed_types:
							valid_resources.append(full_path)
			file_name = dir.get_next()
	else:
		push_error("Failed to open directory: " + folder_path)
		return null

	# 如果没有找到符合条件的资源
	if valid_resources.is_empty():
		push_error("No valid resources found in: " + folder_path)
		return null

	# 随机选择一个资源并加载
	var random_index := randi() % valid_resources.size()
	var selected_resource := ResourceLoader.load(valid_resources[random_index])

	return selected_resource





#func





"""
update
calculate
create
process
global
start
end
position
count

# await get_tree().physics_frame

	#var time_start = Time.get_ticks_usec()
	#var time_end = Time.get_ticks_usec()
	#print("took %d microseconds" % (time_end - time_start))

#ProjectSettings.get_setting("")



"""






pass
