#class_name Global Code
extends Node

signal main_player_ready
signal global_scenes_ready
signal sky_limit_ready
signal danmaku_manager_ready

const explod_max_speed: float = 100.0 ## m
const default_gravity: float = 9.8
const Hl = preload("res://assets/global/scripts/HL.gd")
const MOBILE_PROGRESS_SAVE_PATH := "user://mobile_progress.json"
const MOBILE_PROGRESS_VERSION := 3
const CharacterProgression = preload("res://assets/maps/route_levels/character_progression.gd")


###
# 自动场景初始化
# 注意大小写对应
#const SETTINGS_CONFIG_MANAGER = preload("res://assets/global/settings_config_manager.tscn")
const EFFECTS = preload("res://assets/global/Effects.tscn")
const POST_PROCESSING = preload("res://assets/global/post-processing.tscn")
const FLUID_MECHANICS_MANAGER = preload("res://assets/systems/water_physics/fluid_mechanics_manager.tscn")
const WAR_FOG = preload("res://assets/systems/marching_cubes/war_fog.tscn")
const CHUNK_MANAGER = preload("res://assets/systems/spatial_partition/chunk_manager.tscn")

const DEBUG_MENU = preload("res://assets/arts_graphic/ui/debug_menu/debug_menu.tscn")
const PLAYER_FP_UI = preload("res://assets/arts_graphic/ui/player_ui/PlayerFP_UI.tscn")
const MAIN_MENUS = preload("res://assets/arts_graphic/ui/menu/main_menus.tscn")

const DANMAKU_MANAGER = preload("res://assets/danmaku/danmaku_manager.tscn")



###
var GLOBAL_SCENES_LIST_START = "GLOBAL_SCENES_LIST_START"
#
#var settings_config_manager: HL.SettingsConfigManager
var effects: Node3D
var fluid_mechanics_manager: HL.FluidMechanicsManager
var war_fog: Node3D
var chunk_manager: HL.ChunkManager
# ui
var post_processing: CanvasLayer
var debug_menu: HL.DebugMenu
var player_fp_ui: HL.PlayerFP_UI
var main_menus: HL.MainMenus
#弹幕
var danmaku_manager: HL.DanmakuManager
#
var GLOBAL_SCENES_LIST_END = "GLOBAL_SCENES_LIST_END"
###
var global_scenes_list: Array = []


# 其他
#var global_nodes: Array = []

var main_player: HL.Player = null
var main_player_camera: HL.Camera = null
var sky_limit: HL.SkyLimit = null
var runner_planet_id: String = "glass_desert"
var exploration_planet_id: String = "glass_desert"
var runner_location_id: String = "dome"
## 跑酷跑道外观（在主界面/地图外切换，进关读取）
var runner_road_style: String = "alien_energy"
var selected_ship_id: String = "spark_moth"
var mobile_home_tab: String = "home"
var pending_location_showcase_id: String = ""
var first_launch_story_seen: bool = false
var home_guide_seen: bool = false
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
	gravity_value = ProjectSettings.get_setting("physics/3d/default_gravity")
	gravity_vector = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

	if not get_tree().current_scene.is_in_group("Normal3DGameScene") : # 防止其他节点
		return
	var _list = get_property_list()
	global_scenes_list = get_dicts_between_start_end(_list, GLOBAL_SCENES_LIST_START, GLOBAL_SCENES_LIST_END)

	ready_global_scenes()
	add_child(GetReady.new(func(): return get_tree().current_scene, _global_scenes_ready))




func _process(_delta: float) -> void:
	if not get_tree().paused:
		paused_time_process += _delta


func _physics_process(_delta: float) -> void:
	if not get_tree().paused:
		paused_time_physics_process += _delta


func _global_scenes_ready() -> void:
	for scene_dir in global_scenes_list:
		var scene_name: String = scene_dir["name"]
		var scene = self.get(scene_name)
		get_tree().current_scene.add_child(scene)
	paused_time_process = 0.0
	paused_time_physics_process = 0.0
	global_scenes_ready.emit()


func ready_global_scenes() -> void:
	for scene_dir in global_scenes_list:
		var scene_name: String = scene_dir["name"]
		var old_scene: Node = self.get(scene_name)
		if old_scene:
			old_scene.queue_free()

		var SCENE: PackedScene = self.get(scene_name.to_upper())
		self.set(scene_name, SCENE.instantiate())
		var new_scene: Node = self.get(scene_name)
		if new_scene.has_method("_ready_process_mode"):
			new_scene.process_mode = new_scene._ready_process_mode()
		else:
			new_scene.process_mode = Node.PROCESS_MODE_PAUSABLE


func reload_current_scene() -> void:
	get_tree().reload_current_scene()
	#await get_tree().current_scene.ready
	ready_global_scenes()
	add_child(GetReady.new(func(): return get_tree().current_scene, _global_scenes_ready))


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
	var active: Dictionary = get_active_mission(planet_id)
	if String(active.get("location_id", "")) == location_id:
		clear_active_mission(planet_id)
	else:
		save_mobile_progress()
	return true


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
	if not get_revealed_exploration_locations(planet_id, ["dome"]).has(location_id):
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


func set_selected_ship(ship_id: String) -> void:
	if ship_id == "":
		return
	selected_ship_id = ship_id
	save_mobile_progress()


const RUNNER_ROAD_STYLE_ORDER: Array[String] = ["alien_energy", "energy_neon", "planet", "rust_metal", "void_crystal"]
const RUNNER_ROAD_STYLE_LABELS := {
	"alien_energy": "异星能量轨",
	"energy_neon": "能量霓虹",
	"planet": "星球默认",
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
	return "alien_energy"


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


func save_mobile_progress() -> void:
	var data := {
		"version": MOBILE_PROGRESS_VERSION,
		"first_launch_story_seen": first_launch_story_seen,
		"home_guide_seen": home_guide_seen,
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
		"runner_road_style": get_runner_road_style(),
		"exploration_revealed_locations_by_planet": _string_array_dict_to_save_data(exploration_revealed_locations_by_planet),
		"completed_runner_locations_by_planet": _string_array_dict_to_save_data(completed_runner_locations_by_planet),
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
	runner_road_style = normalize_runner_road_style(String(data.get("runner_road_style", runner_road_style)))
	exploration_revealed_locations_by_planet = _save_data_to_string_array_dict(data.get("exploration_revealed_locations_by_planet", {}))
	completed_runner_locations_by_planet = _save_data_to_string_array_dict(data.get("completed_runner_locations_by_planet", {}))
	active_missions_by_planet = _save_data_to_active_missions_dict(data.get("active_missions_by_planet", {}))
	_sync_messenger_story_unlocks()


func _sync_messenger_story_unlocks() -> void:
	if get_completed_runner_locations("glass_desert").has("dome"):
		_unlock_messenger_story("dome_resident")


func reset_mobile_progress() -> void:
	first_launch_story_seen = false
	home_guide_seen = false
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
	runner_road_style = "alien_energy"
	exploration_revealed_locations_by_planet.clear()
	completed_runner_locations_by_planet.clear()
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
		if main_menus:
			main_menus.queue_free()
			main_menus = null
		set_mouse_mode()
		return
	if not get_tree().current_scene.is_in_group("Normal3DGameScene"):
		return
	ready_global_scenes()
	add_child(GetReady.new(func(): return get_tree().current_scene, _global_scenes_ready))


func ready_runner_global_scenes() -> void:
	if main_menus:
		main_menus.queue_free()
	main_menus = MAIN_MENUS.instantiate()
	main_menus.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(main_menus)
	main_menus.visible = false
	set_mouse_mode()



func get_delta_time() -> float:
	if Engine.is_in_physics_frame():
		return get_physics_process_delta_time()
	return get_process_delta_time()


# Global.set_mouse_mode()
# 鼠标模式控制逻辑
func set_mouse_mode() -> void:
	if tool_ui_visible():  # 如果工具UI可见
		if player_fp_ui.tool_ui.is_mouse_wheel_pressed:  # 且鼠标滚轮被按下
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED  # 限制鼠标在窗口内
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # 否则显示自由鼠标

	elif main_player and not main_menus.visible:  # 如果主角色存在且主菜单不可见
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # 捕获鼠标(通常用于第一人称视角)

	else:  # 其他所有情况
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # 显示自由鼠标


func is_tool_ui_move_camera() -> bool:
	return tool_ui_visible() and player_fp_ui.tool_ui.is_mouse_wheel_pressed


func tool_ui_visible() -> bool:
	return player_fp_ui and player_fp_ui.tool_ui and player_fp_ui.tool_ui.visible




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
