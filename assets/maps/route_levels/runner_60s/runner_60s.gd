extends Node3D

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")
const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const CustomLevels = preload("res://assets/maps/route_levels/runner_60s/custom_levels.gd")
const ObstacleLayout = preload("res://assets/maps/route_levels/runner_60s/obstacle_layout.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const MobilePauseOverlay = preload("res://assets/maps/route_levels/mobile_pause_overlay.gd")
const HitFeedback = preload("res://assets/systems/hit_feedback/hit_feedback.gd")
const ROAD_ENERGY_NEON_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_energy_neon.gdshader")
const ROAD_ALIEN_ENERGY_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_alien_energy.gdshader")
const ROAD_HOLOGRAPHIC_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_holographic.gdshader")

const ROAD_STYLE_ORDER: Array[String] = ["holographic", "alien_energy", "energy_neon", "planet", "coarse_desert", "rust_metal", "void_crystal"]
const ROAD_STYLE_LABELS := {
	"holographic": "全息能量轨",
	"alien_energy": "异星能量轨",
	"planet": "星球默认",
	"coarse_desert": "粗粝沙漠",
	"energy_neon": "能量霓虹",
	"rust_metal": "锈蚀金属",
	"void_crystal": "虚空晶体",
}
# 概念资产 holographic_energy_runway.png → 全息能量轨 / 能量霓虹
# 异星能量轨 = 固态能量 shader；星球默认 = 晶砂实心路；粗粝沙漠 = 砾石沙面 shader

const LANE_WIDTH := 4.0
const LANES := [-1, 0, 1]
const RUN_SPEED := 14.0
const RUN_SPEED_MAX := 24.0
const DEFAULT_RUN_TIME := MissionTypes.BASE_DURATION
const DEFAULT_TRACK_LENGTH := MissionTypes.BASE_TRACK_LENGTH
const LANE_CHANGE_EASE := 12.0
const GRAVITY := 28.0
const JUMP_SPEED := 12.5
const SLIDE_TIME := 0.85
const MAGNET_RADIUS := 5.5
const MAGNET_SPEED := 18.0

# 追逐者：零潮追猎
const CHASER_START_DISTANCE := 28.0
const CHASER_INTRO_START := 42.0
const CHASER_MAX_DISTANCE := 35.0
const CHASER_BASE_CREEP := 0.42
const CHASER_HIT_PENALTY := 7.0
const CHASER_RECOVERY_RATE := 1.8
const CHASER_CATCH_DISTANCE := 0.5
const STRIKE_RECOVERY_TIME := 4.5
const HIT_SLOW_FACTOR := 0.52
const HIT_SLOW_DURATION := 1.35
const HIT_IFRAME_TIME := 0.85
const LANE_HIT_HALF_WIDTH := LANE_WIDTH * 0.52
const LANE_HIT_HALF_WIDTH_JUMP := LANE_WIDTH * 0.42
# 封道时仅最外侧车道可过（左封=右道安全，右封=左道安全）
const LANE_BLOCK_SAFE_EDGE := LANE_WIDTH * 0.35
const OBSTACLE_HALF_DEPTH := {
	"jump": 0.42,
	"low_barrier": 0.55,
	"slide": 0.72,
	"high_bar": 0.72,
	"train": 1.05,
	"train_moving": 1.05,
	"block_left": 0.75,
	"block_right": 0.75,
	"main_block": 8.0,
}
const STRIKE_DAMAGE_TIER := {
	"jump": 0.55,
	"low_barrier": 0.55,
	"slide": 0.7,
	"high_bar": 0.7,
	"block_left": 0.85,
	"block_right": 0.85,
	"main_block": 1.05,
	"train": 1.0,
	"train_moving": 1.15,
}
const HEAT_HAZARD_DPS := 7.0
const HEAT_HAZARD_HALF_LEN := 7.0
const HEAT_HAZARD_TICK := 0.45
const SANDSTORM_TICK := 0.4
const SANDSTORM_DEFAULT_DPS := 9.0
const SHIELD_MAX_ENERGY := 100.0
const SHIELD_START_ENERGY := 45.0
const SHIELD_CRYSTAL_RESTORE := 28.0
const SHIELD_DRAIN_MULT := 1.15
const INTRO_DURATION := 3.0
const PRE_RUN_LOADING_TIME := 0.45
const PRE_RUN_COUNTDOWN_STEP := 1.0
# 追击默认关闭；Ignition Run 等任务类型会在开局打开 _chaser_enabled
const CHASER_ENABLED_DEFAULT := false
const GROUND_Y := 0.85
const CAMERA_BEHIND := 7.8
const CAMERA_HEIGHT := 2.35
const CAMERA_LOOK_AHEAD := 18.0
const CAMERA_FOV := 64.0
const START_PAD_LENGTH := 72.0
const TOUCH_SWIPE_MIN_DISTANCE := 72.0
const TOUCH_TAP_MAX_DISTANCE := 26.0
const MOBILE_VIEWPORT_SIZE := Vector2(1080, 1920)
const ANIMATED_PLAYER_SCENE_PATH := "res://elsa动作/Running.fbx"
const ANIMATED_PLAYER_IDLE_ANIM := "NlaTrack.002"
const ANIMATED_PLAYER_RUN_ANIM := "mixamo_com"
const ANIMATED_PLAYER_CELEBRATE_ANIM := "NlaTrack.001"
const PLAYER_MODEL_SCENE_PATH := "res://elsa动作/elsa正面.glb"
const PLAYER_RUN_LEFT_SCENE_PATH := "res://elsa动作/elsa奔跑左腿前.glb"
const PLAYER_RUN_RIGHT_SCENE_PATH := "res://elsa动作/elsa奔跑右腿前.glb"
const PLAYER_JUMP_START_SCENE_PATH := "res://elsa动作/elsa起跳.glb"
const PLAYER_JUMP_PEAK_SCENE_PATH := "res://elsa动作/elsa跳跃高点.glb"
const PLAYER_LANDING_SCENE_PATH := "res://elsa动作/跳跃落地.glb"
const PLAYER_SLIDE_SCENE_PATH := "res://elsa动作/滑铲.glb"
const PLAYER_MODEL_HEIGHT := 1.65
const PLAYER_MODEL_YAW := -90.0
const PLAYER_INTRO_BODY_YAW := 180.0
const PLAYER_SLIDE_MODEL_HEIGHT := 0.75
const PLAYER_SLIDE_MODEL_YAW := 180.0
const IMPORTED_SCENE_FALLBACKS := {
	"res://3d素材/障碍物-需跳跃.glb": "res://.godot/imported/障碍物-需跳跃.glb-46f57db02e27254a677214f954ab0d83.scn",
	"res://3d素材/障碍物-需跳跃2.glb": "res://.godot/imported/障碍物-需跳跃2.glb-c8c9938e154747024ae7ac221ab7db3a.scn",
	"res://3d素材/居民穹顶据点 3d model.glb": "res://.godot/imported/居民穹顶据点 3d model.glb-f6066a8ae2d51e15aff61146c4296099.scn",
}

# 垂直墙跑（神秘海域式侧墙，与主路成 90°）
const WALL_RUN_LAYER := 1
const WALL_LANE_HEIGHTS: Array[float] = [1.55, 3.05, 4.55] # 墙面上的三列高度：低 / 中 / 高
const WALL_DEFAULT_OFFSET := 7.2
const WALL_THICKNESS := 0.5
const WALL_FACE_HEIGHT := 6.4
# 脚点贴墙面后略朝主路推出，避免 z-fight / 穿模
const WALL_STAND_CLEARANCE := 0.18
const LAYER_HEIGHTS := [GROUND_Y, 3.8, 6.5] # 保留兼容；墙跑不再用抬高层
const LAYER_NAMES := ["地面", "侧墙", "高架"]

var LevelConfig: Script
var _world_panorama: Texture2D
var _jump_obstacle_paths: Array[String] = []
var _slide_obstacle_paths: Array[String] = []
var _side_prop_paths: Array[String] = []
var _landmark_prop_paths: Array[String] = []
var _slide_obstacle_scene: PackedScene
var _hearth_scene_path := ""
var _player_scene_paths: Dictionary = {}
var _scene_cache: Dictionary = {}
var _world_ready := false
var _side_dressing_root: Node3D
var _road_root: Node3D
var _world_environment: WorldEnvironment
var _road_style_id := "holographic"
var _background_style_id := "desert_crystal"
var _path_baked := false
var _road_edge_particles: Array[GPUParticles3D] = []

var player: CharacterBody3D
var player_body: Node3D
var player_pose_root: Node3D
var player_slide_pose_root: Node3D
var player_pose_models: Dictionary = {}
var player_animation_player: AnimationPlayer
var player_animation_name := ""
var _skeletal_run_enabled := false
var camera_pivot: Node3D
var camera: Camera3D
var trail_particles: GPUParticles3D
var landing_particles: GPUParticles3D
var lane_index := 1
var target_lane_x := 0.0
var current_lateral := 0.0
var lane_change_ease := LANE_CHANGE_EASE
var vertical_velocity := 0.0
var slide_timer := 0.0
var elapsed := 0.0
var current_speed := RUN_SPEED
var body_tilt := 0.0
var body_squash_timer := 0.0
var player_pose_name := ""
var camera_shake := 0.0
var was_on_ground := true
var is_finished := false
var is_failed := false
var collected_count := 0
var total_collectibles := 0
var crystal_collected_count := 0
var run_score := 0
var cargo_integrity := 100.0
var shield_energy := SHIELD_START_ENERGY
var shield_active := false
var _shield_mesh: MeshInstance3D
var _shield_warned_empty := false
var mission: Dictionary = {}
var _mission_profile: Dictionary = {}
var _run_time := DEFAULT_RUN_TIME
var _track_length := DEFAULT_TRACK_LENGTH
var _chaser_enabled := CHASER_ENABLED_DEFAULT
var obstacles: Array[Dictionary] = []
var collectibles: Array[Dictionary] = []
var track_distance := 0.0
var track_layer := 0
var current_wall_y := 3.05
var _wall_roll := 0.0
var track_root: Node3D
var passed_junctions: Array[int] = []
var _path_samples: Array[Dictionary] = []
var _path_length := 0.0
var _fork_side := 0
var _active_fork_index := -1
var _path_yaw := 0.0
var _fork_approach_warned: Array[int] = []
var _y_fork_regions: Array = []
var passed_y_forks: Array[int] = []
var _active_y_fork_index := -1
var _y_fork_approach_warned: Array[int] = []

var chaser: Node3D
var chaser_body: MeshInstance3D
var chaser_eye_left: MeshInstance3D
var chaser_eye_right: MeshInstance3D
var chaser_distance := CHASER_START_DISTANCE
var chaser_pulse := 0.0
var strike_count := 0
var strike_recovery_timer := 0.0
var speed_penalty_mult := 1.0
var speed_penalty_timer := 0.0
var is_intro := true
var intro_elapsed := 0.0
var pre_run_phase := "loading"
var countdown_step := 3
var countdown_timer := 0.0
var gameplay_active := false
var touch_active := false
var touch_start_pos := Vector2.ZERO

var time_label: Label
var speed_label: Label
var collectible_label: Label
var layer_label: Label
var phase_label: Label
var score_label: Label
var cargo_label: Label
var cargo_icon: TextureRect
var chase_label: Label
var chase_bar: ProgressBar
var chaser_hint_panel: PanelContainer
var chaser_hint_label: Label
var danger_vignette: ColorRect
var strike_toast_label: Label
var strike_toast_timer := 0.0
var _hit_feedback: HitFeedback
var _cargo_hud_panel: PanelContainer
var _heat_tick_accum := 0.0
var _side_runway_penalty_accum := 0.0
var _sandstorm_tick_accum := 0.0
var _sandstorm_active := false
var _sandstorm_warned_keys: Array = []
var _sandstorm_particles: GPUParticles3D
var _base_fog_density := 0.0022
var _wall_mount_armed := false
var _wall_mount_armed_until_d := -1.0
var _last_wall_side := 1.0
var _hit_iframe_timer := 0.0
var _obstacle_scan_index := 0
var intro_panel: PanelContainer
var intro_title: Label
var intro_body: Label
var state_panel: PanelContainer
var state_title: Label
var state_body: Label
var state_restart_button: Button
var state_back_button: Button
var pause_button: Button
var shield_button: Button
var shield_label: Label
var shield_bar: ProgressBar
var hud_root: Control
var debug_hud_box: VBoxContainer
var settlement_detail_timer := 0.0
var pending_settlement_title := ""
var pending_settlement_body := ""
var _letterbox_left: ColorRect
var _letterbox_right: ColorRect
var _pause_overlay: MobilePauseOverlay


func _ready() -> void:
	LevelConfig = PlanetDatabase.get_runner_config(Global.runner_planet_id)
	if CustomLevels.has_level(Global.runner_location_id):
		mission = CustomLevels.make_mission(Global.runner_location_id).duplicate()
		var custom_meta := CustomLevels.get_level(Global.runner_location_id)
		var base_planet := String(custom_meta.get("planet_id", Global.runner_planet_id))
		if base_planet != "" and base_planet != Global.runner_planet_id:
			# 自定义关卡可绑定底图星球；保持任务 location 不变
			LevelConfig = PlanetDatabase.get_runner_config(base_planet)
	else:
		mission = LevelConfig.get_mission_for_location(Global.runner_location_id).duplicate()
	if mission.is_empty():
		mission = LevelConfig.MISSION.duplicate()
	_apply_mission_type_profile()
	lane_change_ease = LANE_CHANGE_EASE + Global.get_lane_change_ease_bonus()
	cargo_integrity = 100.0
	shield_energy = SHIELD_START_ENERGY
	shield_active = false
	_shield_warned_empty = false
	crystal_collected_count = 0
	track_root = Node3D.new()
	track_root.name = "TrackRoot"
	add_child(track_root)
	_build_ui()
	_setup_pause_overlay()
	intro_panel.visible = true
	pre_run_phase = "loading"
	intro_elapsed = 0.0
	get_viewport().size_changed.connect(_update_runner_letterboxes)
	call_deferred("_update_runner_letterboxes")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if OS.has_feature("mobile") else Input.MOUSE_MODE_CAPTURED
	call_deferred("_bootstrap_runner_world")


func _apply_mission_type_profile() -> void:
	mission = MissionTypes.enrich_mission(mission)
	_mission_profile = MissionTypes.resolve(mission)
	_run_time = float(_mission_profile.get("duration", DEFAULT_RUN_TIME))
	_track_length = MissionTypes.track_length_for(_run_time)
	_chaser_enabled = bool(_mission_profile.get("enable_chaser", false))
	mission["duration"] = _run_time
	mission["task_type"] = String(_mission_profile.get("task_type", "Supply Run"))
	mission["task_type_zh"] = String(_mission_profile.get("name_zh", "补给"))
	mission["task_hint"] = String(_mission_profile.get("hint", ""))
	mission["base_reward"] = int(_mission_profile.get("base_reward", 0))


func _bootstrap_runner_world() -> void:
	_load_planet_assets()
	_build_world()
	await get_tree().process_frame
	_build_runner()
	_apply_road_style_environment()
	_build_chaser()
	await get_tree().process_frame
	_build_content()
	_load_cargo_icon()
	chaser_distance = CHASER_INTRO_START
	current_lateral = 0.0
	target_lane_x = 0.0
	_sync_player_position()
	_sync_chaser_from_track()
	_setup_hit_feedback()
	if _road_style_id == "alien_energy":
		_spawn_alien_energy_edge_particles()
	elif _road_style_id in ["holographic", "energy_neon"]:
		_spawn_holographic_edge_particles()
	_update_hud()
	_world_ready = true


func _setup_hit_feedback() -> void:
	if _hit_feedback != null:
		return
	_hit_feedback = HitFeedback.new()
	_hit_feedback.name = "HitFeedback"
	add_child(_hit_feedback)
	if hud_root == null:
		return
	_hit_feedback.setup(hud_root, track_root if track_root else self, _cargo_hud_panel)
	_hit_feedback.shake_requested.connect(func(amount: float):
		camera_shake = maxf(camera_shake, amount)
	)


func _unhandled_input(event: InputEvent) -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		return

	if _handle_touch_input(event):
		return

	if event.is_action_pressed("ui_cancel"):
		if is_finished or is_failed:
			_return_to_exploration_map()
			return
		if _pause_overlay != null:
			_pause_overlay.open_pause()
			get_viewport().set_input_as_handled()
		return

	if is_finished or is_failed:
		if event.is_action_pressed("jump"):
			_restart_run()
		return

	if is_intro or not gameplay_active:
		return

	if event.is_action_pressed("move_left"):
		_try_lane_change(lane_index - 1)
	elif event.is_action_pressed("move_right"):
		_try_lane_change(lane_index + 1)
	elif event.is_action_pressed("jump") and _is_on_ground():
		_try_jump()
	elif event.is_action_pressed("move_backward") and _is_on_ground():
		_try_slide()
	elif event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F or key.physical_keycode == KEY_F:
			_toggle_shield()
			get_viewport().set_input_as_handled()


func _handle_touch_input(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			touch_active = true
			touch_start_pos = touch_event.position
			return false
		if not touch_active:
			return false
		touch_active = false
		var touch_delta := touch_event.position - touch_start_pos
		if touch_delta.length() <= TOUCH_TAP_MAX_DISTANCE:
			return _handle_mobile_tap()
		return _apply_swipe(touch_delta)

	if event is InputEventScreenDrag and touch_active:
		var drag_event := event as InputEventScreenDrag
		var drag_delta := drag_event.position - touch_start_pos
		if drag_delta.length() >= TOUCH_SWIPE_MIN_DISTANCE:
			touch_active = false
			return _apply_swipe(drag_delta)

	return false


func _handle_mobile_tap() -> bool:
	if is_finished or is_failed:
		_restart_run()
		return true
	if is_intro:
		intro_elapsed = INTRO_DURATION
		return true
	return false


func _apply_swipe(touch_delta: Vector2) -> bool:
	if is_finished or is_failed:
		return false
	if is_intro or not gameplay_active:
		return false
	if touch_delta.length() < TOUCH_SWIPE_MIN_DISTANCE:
		return false

	if absf(touch_delta.x) > absf(touch_delta.y):
		_try_lane_change(lane_index + (1 if touch_delta.x > 0.0 else -1))
	elif touch_delta.y < 0.0:
		_try_jump()
	else:
		_try_slide()
	return true


func _try_jump() -> void:
	if _is_wall_running():
		vertical_velocity = JUMP_SPEED * 0.72
		_end_slide()
		body_squash_timer = 0.1
		return
	if not _is_on_ground():
		return
	vertical_velocity = JUMP_SPEED
	_end_slide()
	body_squash_timer = 0.16
	camera_shake = maxf(camera_shake, 0.05)
	_emit_landing_particles()


func _try_slide() -> void:
	if _is_wall_running():
		# 侧墙上滑铲 = 切到最低列
		_set_lane(0)
		return
	if not _is_on_ground():
		return
	_start_slide()


func _restart_run() -> void:
	get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	if not _world_ready:
		if is_intro:
			_update_pre_run(delta)
		return

	if is_finished or is_failed:
		return

	if is_intro:
		_update_pre_run(delta)
		_sync_player_position()
		_sync_chaser_from_track()
		_update_chaser_visuals(delta)
		_update_camera()
		_update_hud()
		return

	elapsed += delta
	current_speed = lerpf(RUN_SPEED, RUN_SPEED_MAX, clampf(elapsed / _run_time, 0.0, 1.0))
	if speed_penalty_timer > 0.0:
		speed_penalty_timer = maxf(speed_penalty_timer - delta, 0.0)
		if speed_penalty_timer == 0.0:
			speed_penalty_mult = 1.0
	if _hit_iframe_timer > 0.0:
		_hit_iframe_timer = maxf(_hit_iframe_timer - delta, 0.0)
	if slide_timer > 0.0:
		slide_timer = maxf(slide_timer - delta, 0.0)
		if slide_timer == 0.0:
			_end_slide()

	var effective_speed := current_speed * speed_penalty_mult
	# 岔路横向外撇会拉长实际路程；按世界弧长补偿，避免忽快忽慢
	var path_stretch := _path_world_stretch(track_distance, current_lateral)
	var dist_from := track_distance
	track_distance += (effective_speed / path_stretch) * delta
	_update_chaser(delta)
	_check_fork_approach()
	_check_junctions()
	_check_y_fork_approach()
	_check_y_forks()
	if not _is_sliding():
		current_lateral = lerpf(current_lateral, target_lane_x, 1.0 - exp(-lane_change_ease * delta))

	if _is_wall_running():
		var target_wy: float = float(WALL_LANE_HEIGHTS[clampi(lane_index, 0, WALL_LANE_HEIGHTS.size() - 1)])
		current_wall_y = lerpf(current_wall_y, target_wy, 1.0 - exp(-lane_change_ease * delta))
		vertical_velocity -= GRAVITY * 0.42 * delta
		var next_y := player.position.y + vertical_velocity * delta
		var ceiling: float = float(WALL_LANE_HEIGHTS[WALL_LANE_HEIGHTS.size() - 1]) + 1.35
		if next_y <= current_wall_y and vertical_velocity <= 0.0:
			next_y = current_wall_y
			vertical_velocity = 0.0
		player.position.y = minf(next_y, ceiling)
	else:
		vertical_velocity -= GRAVITY * delta
		var ground_y := _layer_height(0)
		var next_y := player.position.y + vertical_velocity * delta
		var over_pit := _is_over_open_pit()
		if over_pit:
			# 坑上无隐形地面：真正往下坠
			if next_y <= ground_y and vertical_velocity >= -0.5:
				# 刚踩到坑口：给一个下坠初速，避免卡在地面高度像「跳起来」
				vertical_velocity = minf(vertical_velocity, -6.5)
				next_y = ground_y - 0.02
			player.position.y = next_y
			if player.position.y < ground_y - 0.55:
				_fail_into_pit()
		elif next_y <= ground_y and vertical_velocity <= 0.0:
			next_y = ground_y
			vertical_velocity = 0.0
			player.position.y = next_y
		else:
			player.position.y = next_y

	_sync_player_position()
	_sync_chaser_from_track()
	_update_moving_obstacles(delta)
	_check_ramps()
	_try_side_runway_entry()
	_enforce_track_layer()
	_update_side_runway_ground_penalty(delta)
	_update_sandstorm_hazard(delta)
	_update_shield_visual(delta)

	var grounded := _is_on_ground()
	if grounded and not was_on_ground:
		body_squash_timer = 0.12
		camera_shake = 0.16
		_emit_landing_particles()
	was_on_ground = grounded

	_update_runner_feedback(delta)
	_update_chaser_visuals(delta)
	_update_collectible_magnet(delta)
	_check_collectibles()
	_check_obstacles(dist_from, track_distance)
	_update_env_hazards(delta)
	_check_chaser_caught()

	if track_distance >= _track_length:
		_finish_run()
	elif elapsed >= _run_time:
		if bool(_mission_profile.get("timed_fail", false)):
			_fail_run("限时到达失败")
		else:
			_finish_run()

	_update_camera()
	_update_hud()


func _process(delta: float) -> void:
	if settlement_detail_timer > 0.0:
		settlement_detail_timer = maxf(settlement_detail_timer - delta, 0.0)
		if settlement_detail_timer == 0.0 and pending_settlement_title != "":
			_show_state(pending_settlement_title, pending_settlement_body)
			pending_settlement_title = ""
			pending_settlement_body = ""
	for collectible in collectibles:
		if collectible["collected"]:
			continue
		var node := collectible["node"] as Node3D
		node.rotate_y(delta * 6.0)
		node.rotate_z(delta * 1.7)


func _set_lane(next_lane_index: int) -> void:
	lane_index = clampi(next_lane_index, 0, LANES.size() - 1)
	target_lane_x = LANES[lane_index] * LANE_WIDTH


func _try_lane_change(next_lane_index: int) -> void:
	if _is_sliding():
		_end_slide()
	# 主路最外道再朝侧墙按一次 = 预备上墙（不自动吸附）
	if track_layer == 0 and _try_arm_wall_mount(next_lane_index):
		return
	if next_lane_index < 0 or next_lane_index >= LANES.size():
		return
	_wall_mount_armed = false
	_set_lane(next_lane_index)


func _wall_edge_lane_index(zone: Dictionary) -> int:
	return 2 if _wall_zone_side(zone) > 0.0 else 0


func _try_arm_wall_mount(requested_lane: int) -> bool:
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		_wall_mount_armed = false
		return false
	var wall_side := _wall_zone_side(zone)
	var edge := _wall_edge_lane_index(zone)
	var toward_wall := (wall_side > 0.0 and requested_lane > lane_index) or (wall_side < 0.0 and requested_lane < lane_index)
	if lane_index != edge or not toward_wall:
		return false
	_wall_mount_armed = true
	_wall_mount_armed_until_d = track_distance + 22.0
	_show_gate_toast("贴墙就绪 · 跳跃上墙")
	return true


func _is_wall_mount_ready(zone: Dictionary) -> bool:
	if not _wall_mount_armed:
		return false
	if track_distance > _wall_mount_armed_until_d:
		_wall_mount_armed = false
		return false
	return lane_index == _wall_edge_lane_index(zone)

func _nearest_lane_index(lateral: float) -> int:
	var best_index := 0
	var best_dist := INF
	for i in LANES.size():
		var lane_x := float(LANES[i]) * LANE_WIDTH
		var dist := absf(lateral - lane_x)
		if dist < best_dist:
			best_dist = dist
			best_index = i
	return best_index


func _layer_height(layer: int) -> float:
	return LAYER_HEIGHTS[clampi(layer, 0, LAYER_HEIGHTS.size() - 1)]


func _is_wall_running() -> bool:
	return track_layer == WALL_RUN_LAYER


func _is_on_ground() -> bool:
	if _is_wall_running():
		return absf(player.position.y - current_wall_y) <= 0.08 and vertical_velocity <= 0.01
	return player.position.y <= _layer_height(0) + 0.02 and vertical_velocity <= 0.01


func _wall_lane_height_for_lane_value(lane: int) -> float:
	var idx := _lane_value_to_index(lane)
	return WALL_LANE_HEIGHTS[clampi(idx, 0, WALL_LANE_HEIGHTS.size() - 1)]


func _distance_to_z(distance: float) -> float:
	# 兼容旧调用：仅直线近似，优先使用 _sample_path
	return _sample_path(distance)["pos"].z


func _active_track_segments() -> Array:
	if CustomLevels.has_level(Global.runner_location_id) and CustomLevels.has_custom_track(Global.runner_location_id):
		return CustomLevels.get_track_segments(Global.runner_location_id)
	if LevelConfig != null and LevelConfig.has_method("get_track_segments"):
		return LevelConfig.get_track_segments()
	return []


func _junction_zones() -> Array:
	if CustomLevels.has_level(Global.runner_location_id) and CustomLevels.has_custom_junctions(Global.runner_location_id):
		return CustomLevels.get_junction_zones(Global.runner_location_id)
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if not constants.has("JUNCTION_ZONES"):
		return []
	var out: Array = []
	for raw in constants["JUNCTION_ZONES"]:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(ObstacleLayout.normalize_junction_zone(raw))
	return out


func _bake_track_path() -> void:
	var segments: Array = _active_track_segments()
	var baked: Dictionary = ObstacleLayout.bake_path_from_segments(segments, 2.0)
	_path_samples.clear()
	for s in baked.get("samples", []):
		if typeof(s) == TYPE_DICTIONARY:
			_path_samples.append(s)
	_path_length = float(baked.get("length", 0.0))
	_y_fork_regions = ObstacleLayout.bake_y_fork_regions(segments, 2.0)
	if _path_length < _track_length:
		# 不足时直线补齐到终点
		var pos: Vector3 = baked.get("end_pos", Vector3.ZERO)
		var yaw := float(baked.get("end_yaw", 0.0))
		var dist := _path_length
		var remain := _track_length + 40.0 - _path_length
		var step := 2.0
		var steps2 := maxi(1, int(ceil(remain / step)))
		var ds2 := remain / float(steps2)
		var forward2 := Vector3(-sin(yaw), 0.0, -cos(yaw))
		for _j in steps2:
			pos += forward2 * ds2
			dist += ds2
			_path_samples.append({"d": dist, "pos": pos, "yaw": yaw})
		_path_length = dist


func _sample_path(distance: float) -> Dictionary:
	if _path_samples.is_empty():
		_bake_track_path()
	var d := clampf(distance, 0.0, maxf(_path_length, 0.0))
	# Y 分叉选右岔时，改采右支几何（左支已烘焙进主路径）
	if _y_fork_side_at(d) > 0:
		var region := _y_fork_region_at(d)
		var right_samples: Array = region.get("right", [])
		if right_samples.size() >= 2:
			return _sample_path_samples(right_samples, d)
	return _sample_path_samples(_path_samples, d)


func _sample_path_samples(samples: Array, distance: float) -> Dictionary:
	if samples.is_empty():
		return _pack_path_sample(Vector3.ZERO, 0.0)
	var d := distance
	if samples.size() == 1:
		var only: Dictionary = samples[0]
		return _pack_path_sample(only["pos"], float(only["yaw"]))
	var lo := 0
	var hi := samples.size() - 1
	while lo < hi - 1:
		var mid := (lo + hi) >> 1
		if float((samples[mid] as Dictionary)["d"]) <= d:
			lo = mid
		else:
			hi = mid
	var a: Dictionary = samples[lo]
	var b: Dictionary = samples[hi]
	var da := float(a["d"])
	var db := float(b["d"])
	var t := 0.0 if db <= da + 0.0001 else clampf((d - da) / (db - da), 0.0, 1.0)
	var pos: Vector3 = (a["pos"] as Vector3).lerp(b["pos"] as Vector3, t)
	var yaw := lerp_angle(float(a["yaw"]), float(b["yaw"]), t)
	return _pack_path_sample(pos, yaw)


func _pack_path_sample(pos: Vector3, yaw: float) -> Dictionary:
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := forward.cross(Vector3.UP).normalized()
	return {"pos": pos, "yaw": yaw, "forward": forward, "right": right}


func _path_world_stretch(distance: float, lateral: float) -> float:
	# |d世界位置 / d track_distance|：平路≈1，岔路外扩/收回时 >1
	if _fork_zone_at(distance).is_empty():
		return 1.0
	var eps := 0.75
	var a: Vector3 = _world_on_path(distance, lateral, GROUND_Y)["pos"]
	var b: Vector3 = _world_on_path(distance + eps, lateral, GROUND_Y)["pos"]
	var world_step := a.distance_to(b)
	return clampf(world_step / eps, 0.55, 2.4)


func _fork_zone_at(distance: float) -> Dictionary:
	for zone in _junction_zones():
		var start := float(zone["distance"])
		var length := float(zone.get("length", 70.0))
		if distance >= start and distance <= start + length:
			return zone
	return {}


func _fork_adjusted_lateral(distance: float, lateral: float) -> float:
	# 岔路仍保留三道：branch_center + (-4/0/+4)；中间空隙禁跑
	var zone := _fork_zone_at(distance)
	if zone.is_empty():
		return lateral
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var envelope := _fork_envelope(t)
	if envelope <= 0.001:
		return lateral
	var spread := float(zone.get("spread", 10.0))
	var side := _resolve_fork_side(lateral)
	var branch_center := float(side) * spread * envelope
	return branch_center + lateral


func _resolve_fork_side(lateral: float) -> int:
	# 始终落到左或右岔；中间不作为可跑路径
	if _fork_side < 0:
		return -1
	if _fork_side > 0:
		return 1
	if absf(lateral) > LANE_WIDTH * 0.2:
		return -1 if lateral < 0.0 else 1
	if lane_index <= 0:
		return -1
	if lane_index >= 2:
		return 1
	return -1 if lateral <= 0.0 else 1


func _fork_yaw_nudge(distance: float, lateral: float) -> float:
	# 岔路朝向跟所在分支，与当前三道中的哪一条无关
	var zone := _fork_zone_at(distance)
	if zone.is_empty():
		return 0.0
	var side := _resolve_fork_side(lateral)
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var spread := float(zone.get("spread", 10.0))
	var step := 4.0
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var t2 := clampf(t + step / maxf(length, 0.001), 0.0, 1.0)
	var offset := spread * _fork_envelope(t)
	var offset2 := spread * _fork_envelope(t2)
	var d_lat := ((offset2 - offset) * float(side)) / maxf(step, 0.001)
	return atan(d_lat) * 0.85


func _side_runway_zones() -> Array:
	var zones: Array = _raw_side_runway_zones()
	return _merge_synthetic_side_zones_for_main_blocks(zones)


func _raw_side_runway_zones() -> Array:
	if CustomLevels.has_level(Global.runner_location_id):
		return CustomLevels.get_side_runway_zones(Global.runner_location_id)
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if constants.has("SIDE_RUNWAY_ZONES"):
		var out: Array = []
		for raw in constants["SIDE_RUNWAY_ZONES"]:
			if typeof(raw) == TYPE_DICTIONARY:
				out.append(ObstacleLayout.normalize_side_zone(raw))
		return out
	return []


func _layout_obstacle_items_raw() -> Array:
	if CustomLevels.has_level(Global.runner_location_id):
		return CustomLevels.load_obstacles(Global.runner_location_id)
	if LevelConfig != null and LevelConfig.has_method("build_obstacles"):
		return LevelConfig.build_obstacles()
	return []


func _merge_synthetic_side_zones_for_main_blocks(zones: Array) -> Array:
	# 孤立 main_block 自动补侧墙，否则主路封堵无法通过
	var merged: Array = []
	for z in zones:
		if typeof(z) == TYPE_DICTIONARY:
			merged.append(ObstacleLayout.normalize_side_zone(z))
	for raw in _layout_obstacle_items_raw():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if int(item.get("layer", 0)) != 0:
			continue
		var covered := false
		for z2 in merged:
			if ObstacleLayout.side_zone_covers_main_block(z2, item):
				covered = true
				break
		if covered:
			continue
		merged.append(ObstacleLayout.side_zone_from_main_block(item, {
			"side": "outer",
			"fallback_side": 1,
		}))
	return ObstacleLayout.sort_side_zones(merged)


func _is_distance_in_side_wall_corridor(distance: float) -> bool:
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		var length := float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 10.0))
		var pad := 22.0
		if distance >= start - entry - pad and distance <= start + length + pad:
			return true
	return false


func _filter_adapted_obstacles_from_wall_corridors(items: Array) -> Array:
	var keep_types := {
		"main_block": true,
		"ramp": true,
		"turn_left": true,
		"turn_right": true,
	}
	var out: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var otype := String(item.get("type", ""))
		var dist := float(item.get("distance", 0.0))
		if _is_distance_in_side_wall_corridor(dist) and not keep_types.has(otype):
			continue
		out.append(item)
	return out


func _side_runway_zone_at(distance: float) -> Dictionary:
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		var length := float(zone.get("length", 70.0))
		if distance >= start and distance <= start + length:
			return zone
	return {}


func _side_runway_entry_zone(distance: float) -> Dictionary:
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		var length := float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 8.0))
		if distance >= start - entry and distance <= start + length:
			return zone
	return {}


func _side_runway_envelope(distance: float, zone: Dictionary) -> float:
	var start := float(zone["start"])
	var length := float(zone.get("length", 70.0))
	var edge := minf(5.0, length * 0.18)
	if edge <= 0.001:
		return 1.0
	var t_in := clampf((distance - start) / edge, 0.0, 1.0)
	var t_out := clampf((start + length - distance) / edge, 0.0, 1.0)
	var t := minf(t_in, t_out)
	return t * t * (3.0 - 2.0 * t)


func _path_curvature_sign(distance: float, window: float = 22.0) -> float:
	# 正=左转（外径在 +right），负=右转（外径在 -right）
	var a := _sample_path(maxf(distance - window * 0.5, 0.0))
	var b := _sample_path(distance + window * 0.5)
	var dyaw := wrapf(float(b["yaw"]) - float(a["yaw"]), -PI, PI)
	if absf(dyaw) < 0.04:
		return 0.0
	return signf(dyaw)


func _wall_zone_side(zone: Dictionary) -> float:
	if zone.is_empty():
		return 1.0
	var raw: Variant = zone.get("side", 1)
	if typeof(raw) == TYPE_STRING and String(raw) == "outer":
		var mid := float(zone["start"]) + float(zone.get("length", 70.0)) * 0.5
		var curv := _path_curvature_sign(mid)
		if absf(curv) < 0.5:
			return float(zone.get("fallback_side", 1))
		return curv
	return float(raw)


func _wall_inner_face_lateral(side: float, offset: float) -> float:
	# 朝向主路的立墙表面
	return side * offset - side * (WALL_THICKNESS * 0.5)


func _wall_stand_lateral(side: float, offset: float) -> float:
	# 脚在墙面外侧（朝主路），给躯干留出站立空间
	return _wall_inner_face_lateral(side, offset) - side * WALL_STAND_CLEARANCE


func _world_on_wall(distance: float, side: float, offset: float, height: float) -> Dictionary:
	var sample := _sample_path(distance)
	var lat := _wall_stand_lateral(side, offset)
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lat
	pos.y = height
	return {
		"pos": pos,
		"yaw": float(sample["yaw"]),
		"forward": sample["forward"],
		"right": sample["right"],
		"side": side,
	}


func _apply_wall_run_body_orientation(side: float) -> void:
	# 只转视觉根：头顶朝主路，脚贴墙；玩家根节点保持直立供相机跟随
	_wall_roll = side * (PI * 0.5)
	if player_body:
		player_body.rotation = Vector3(0.0, 0.0, _wall_roll + body_tilt * 0.15)


func _world_on_path(distance: float, lateral: float, y: float, content_layer: int = -1) -> Dictionary:
	var sample := _sample_path(distance)
	var x := _fork_adjusted_lateral(distance, lateral)
	# 墙跑内容改走 _world_on_wall；此处仅主路
	if content_layer == WALL_RUN_LAYER:
		var zone := _side_runway_zone_at(distance)
		if not zone.is_empty():
			return _world_on_wall(
				distance,
				_wall_zone_side(zone),
				float(zone.get("lateral_offset", WALL_DEFAULT_OFFSET)),
				y
			)
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * x
	pos.y = y
	return {"pos": pos, "yaw": float(sample["yaw"]), "forward": sample["forward"], "right": sample["right"]}


func _sync_player_position() -> void:
	if player == null:
		return
	if _is_wall_running():
		var zone := _side_runway_zone_at(track_distance)
		if zone.is_empty():
			zone = _side_runway_entry_zone(track_distance)
		var side := _wall_zone_side(zone)
		var offset := float(zone.get("lateral_offset", WALL_DEFAULT_OFFSET))
		var keep_y := player.position.y
		var placed := _world_on_wall(track_distance, side, offset, keep_y)
		_path_yaw = float(placed["yaw"])
		# 根节点只跟路径偏航，相机才能稳定锁角色
		player.position = placed["pos"]
		player.rotation = Vector3(0.0, _path_yaw, 0.0)
		_apply_wall_run_body_orientation(side)
		return

	var keep_y := player.position.y if player else GROUND_Y
	var placed := _world_on_path(track_distance, current_lateral, keep_y)
	player.position = placed["pos"]
	_path_yaw = float(placed["yaw"]) + _fork_yaw_nudge(track_distance, current_lateral)
	# 岔路上用前方真实落点推朝向，比单点 yaw nudge 更贴路面
	if not _fork_zone_at(track_distance).is_empty() or not _y_fork_region_at(track_distance).is_empty():
		var ahead := _world_on_path(track_distance + 8.0, current_lateral, keep_y)
		var delta: Vector3 = (ahead["pos"] as Vector3) - (placed["pos"] as Vector3)
		delta.y = 0.0
		if delta.length_squared() > 0.04:
			var face_yaw := atan2(-delta.x, -delta.z)
			_path_yaw = lerp_angle(_path_yaw, face_yaw, 0.72)
	# 离开侧墙后恢复直立朝向
	player.rotation = Vector3(0.0, _path_yaw, 0.0)
	_wall_roll = lerpf(_wall_roll, 0.0, 0.4)
	if player_body:
		player_body.rotation.x = lerpf(player_body.rotation.x, 0.0, 0.4)
		player_body.rotation.y = lerpf(player_body.rotation.y, 0.0, 0.4)
		player_body.rotation.z = lerpf(player_body.rotation.z, body_tilt, 0.4)


func _check_junctions() -> void:
	for junction_index in _junction_zones().size():
		if passed_junctions.has(junction_index):
			continue
		var zone: Dictionary = _junction_zones()[junction_index]
		var at_distance: float = float(zone["distance"])
		if track_distance < at_distance or track_distance > at_distance + 4.0:
			continue
		passed_junctions.append(junction_index)
		_active_fork_index = junction_index
		var lane_a := int(zone.get("lane_a", zone.get("required_lane", 0)))
		var lane_b := int(zone.get("lane_b", 2))
		if lane_index == lane_a or lane_index <= 0:
			_fork_side = -1
			_apply_gate_effect(String(zone.get("effect_a", "repair")))
			_show_gate_toast(String(zone.get("label_a", "左岔路")))
		elif lane_index == lane_b or lane_index >= 2:
			_fork_side = 1
			_apply_gate_effect(String(zone.get("effect_b", "bonus")))
			_show_gate_toast(String(zone.get("label_b", "右岔路")))
		else:
			# 中道禁跑：强制甩入较近一侧，并扣货
			_fork_side = _resolve_fork_side(current_lateral)
			var fork_penalty := 8.0 * Global.get_cargo_damage_multiplier()
			_apply_cargo_loss(fork_penalty)
			if not is_failed:
				if _hit_feedback != null and player != null:
					_hit_feedback.apply_impact(
						player.global_position + Vector3(0.0, 1.7, 0.0),
						HitFeedback.Intensity.LIGHT,
						fork_penalty,
						"中道禁行"
					)
				_show_strike_warning("中间不能跑 · 已转入%s" % ("左岔" if _fork_side < 0 else "右岔"))

	# 分叉段内持续锁定左右支，避免中空浮空
	_enforce_active_fork_side()

	# 离开分叉段后复位
	if _active_fork_index >= 0 and _active_fork_index < _junction_zones().size():
		var active: Dictionary = _junction_zones()[_active_fork_index]
		var end_d := float(active["distance"]) + float(active.get("length", 70.0))
		if track_distance > end_d + 1.0:
			_active_fork_index = -1
			if _y_fork_region_at(track_distance).is_empty():
				_fork_side = 0


func _enforce_active_fork_side() -> void:
	var zone := _fork_zone_at(track_distance)
	if zone.is_empty():
		return
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var t := clampf((track_distance - start) / maxf(length, 0.001), 0.0, 1.0)
	if _fork_envelope(t) < 0.08:
		return
	if _fork_side == 0:
		_fork_side = _resolve_fork_side(current_lateral)
	if _active_fork_index < 0:
		for i in _junction_zones().size():
			var z: Dictionary = _junction_zones()[i]
			if absf(float(z.get("distance", -999.0)) - start) < 0.5:
				_active_fork_index = i
				break


func _check_fork_approach() -> void:
	for junction_index in _junction_zones().size():
		if _fork_approach_warned.has(junction_index) or passed_junctions.has(junction_index):
			continue
		var zone: Dictionary = _junction_zones()[junction_index]
		var at_distance := float(zone["distance"])
		if track_distance < at_distance - 38.0 or track_distance > at_distance - 28.0:
			continue
		_fork_approach_warned.append(junction_index)
		_show_gate_toast("前方分叉 · 左=%s · 右=%s" % [
			String(zone.get("label_a", "左")),
			String(zone.get("label_b", "右")),
		])


func _y_fork_region_at(distance: float) -> Dictionary:
	for region in _y_fork_regions:
		if typeof(region) != TYPE_DICTIONARY:
			continue
		var d0 := float(region.get("d_start", 0.0))
		var d1 := float(region.get("d_end", 0.0))
		if distance >= d0 and distance <= d1:
			return region
	return {}


func _y_fork_side_at(distance: float) -> int:
	if _y_fork_region_at(distance).is_empty():
		return 0
	if _fork_side != 0:
		return _fork_side
	# 尚未锁定时按当前车道预览（铺路/摆障碍时 _fork_side=0 → 走左岔主路径）
	if not gameplay_active:
		return 0
	return _resolve_fork_side(current_lateral)


func _check_y_fork_approach() -> void:
	for i in _y_fork_regions.size():
		if _y_fork_approach_warned.has(i) or passed_y_forks.has(i):
			continue
		var region: Dictionary = _y_fork_regions[i]
		var at_distance := float(region.get("d_start", 0.0))
		if track_distance < at_distance - 38.0 or track_distance > at_distance - 28.0:
			continue
		_y_fork_approach_warned.append(i)
		_show_gate_toast("前方 Y 分叉 · 左道走左岔 · 右道走右岔")


func _check_y_forks() -> void:
	for i in _y_fork_regions.size():
		if passed_y_forks.has(i):
			continue
		var region: Dictionary = _y_fork_regions[i]
		var at_distance := float(region.get("d_start", 0.0))
		if track_distance < at_distance or track_distance > at_distance + 4.0:
			continue
		passed_y_forks.append(i)
		_active_y_fork_index = i
		if lane_index <= 0:
			_fork_side = -1
			_show_gate_toast("左岔路")
		elif lane_index >= 2:
			_fork_side = 1
			_show_gate_toast("右岔路")
		else:
			_fork_side = _resolve_fork_side(current_lateral)
			var fork_penalty := 8.0 * Global.get_cargo_damage_multiplier()
			_apply_cargo_loss(fork_penalty)
			if not is_failed:
				if _hit_feedback != null and player != null:
					_hit_feedback.apply_impact(
						player.global_position + Vector3(0.0, 1.7, 0.0),
						HitFeedback.Intensity.LIGHT,
						fork_penalty,
					)
				_show_strike_warning("中间不能跑 · 已转入%s" % ("左岔" if _fork_side < 0 else "右岔"))
	_enforce_active_y_fork_side()
	if _active_y_fork_index >= 0 and _active_y_fork_index < _y_fork_regions.size():
		var active: Dictionary = _y_fork_regions[_active_y_fork_index]
		var end_d := float(active.get("d_end", 0.0))
		if track_distance > end_d + 1.0:
			_active_y_fork_index = -1
			# 若仍在旧横向分叉区内，保留其 _fork_side
			if _fork_zone_at(track_distance).is_empty():
				_fork_side = 0


func _enforce_active_y_fork_side() -> void:
	var region := _y_fork_region_at(track_distance)
	if region.is_empty():
		return
	if _fork_side == 0:
		_fork_side = _resolve_fork_side(current_lateral)
	if _active_y_fork_index < 0:
		var d0 := float(region.get("d_start", -999.0))
		for i in _y_fork_regions.size():
			var r: Dictionary = _y_fork_regions[i]
			if absf(float(r.get("d_start", -999.0)) - d0) < 0.5:
				_active_y_fork_index = i
				break


func _apply_cargo_loss(amount: float) -> void:
	if amount <= 0.0:
		return
	cargo_integrity = maxf(cargo_integrity - amount, 0.0)
	if _hit_feedback != null:
		_hit_feedback.flash_cargo()
	if cargo_integrity <= 0.0:
		_fail_run("货物完整度归零，%s 损毁" % String(mission.get("cargo_name", "物资")))


func _update_env_hazards(delta: float) -> void:
	if is_finished or is_failed or not gameplay_active:
		return
	var in_heat := false
	for obstacle in obstacles:
		if not bool(obstacle.get("heat_hazard", false)):
			continue
		if int(obstacle.get("layer", 0)) != track_layer:
			continue
		var obs_dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
		if absf(track_distance - obs_dist) > HEAT_HAZARD_HALF_LEN:
			continue
		if not _player_in_obstacle_lateral(obstacle):
			continue
		in_heat = true
		break
	if not in_heat:
		_heat_tick_accum = 0.0
		return
	_heat_tick_accum += delta
	if _heat_tick_accum < HEAT_HAZARD_TICK:
		return
	_heat_tick_accum = 0.0
	var dmg := HEAT_HAZARD_DPS * HEAT_HAZARD_TICK * Global.get_cargo_damage_multiplier()
	_apply_cargo_loss(dmg)
	if is_failed:
		return
	if _hit_feedback != null and player != null:
		_hit_feedback.apply_env_tick_at(player.global_position + Vector3(0.0, 1.7, 0.0), dmg, "热量侵蚀")
	elif strike_toast_label:
		_show_strike_warning("热量侵蚀")


func _sandstorm_zones() -> Array:
	if CustomLevels.has_level(Global.runner_location_id):
		return CustomLevels.get_sandstorm_zones(Global.runner_location_id)
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if constants.has("SANDSTORM_ZONES"):
		var out: Array = []
		for raw in constants["SANDSTORM_ZONES"]:
			if typeof(raw) == TYPE_DICTIONARY:
				out.append(ObstacleLayout.normalize_sandstorm_zone(raw))
		return out
	return []


func _sandstorm_zone_at(distance: float) -> Dictionary:
	var player_lane := int(LANES[clampi(lane_index, 0, LANES.size() - 1)])
	for zone in _sandstorm_zones():
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		if distance < start or distance > start + length:
			continue
		if not _sandstorm_covers_lane(zone, player_lane):
			continue
		return zone
	return {}


func _sandstorm_covers_lane(zone: Dictionary, lane_value: int) -> bool:
	var covered: Array = zone.get("covered_lanes", [-1, 0, 1])
	for v in covered:
		if int(v) == lane_value:
			return true
	return false


func _sandstorm_volume_layout(zone: Dictionary) -> Dictionary:
	var covered: Array = zone.get("covered_lanes", [-1, 0, 1])
	if covered.is_empty():
		covered = [-1, 0, 1]
	var min_lane := int(covered[0])
	var max_lane := int(covered[0])
	for v in covered:
		min_lane = mini(min_lane, int(v))
		max_lane = maxi(max_lane, int(v))
	var center := (float(min_lane) + float(max_lane)) * 0.5
	var span := float(max_lane - min_lane) + 1.0
	return {
		"lateral_bias": center * LANE_WIDTH,
		"half_width": span * LANE_WIDTH * 0.5 + 0.9,
	}


func _update_sandstorm_hazard(delta: float) -> void:
	if is_finished or is_failed or not gameplay_active:
		_set_sandstorm_visual(false)
		return
	var zone := _sandstorm_zone_at(track_distance)
	var active := not zone.is_empty()
	if active and not _sandstorm_active:
		var key := int(float(zone.get("start", 0.0)))
		if not _sandstorm_warned_keys.has(key):
			_sandstorm_warned_keys.append(key)
			if _is_shield_protecting():
				_show_strike_warning("%s来袭 · 防护罩抵挡中" % String(zone.get("label", "沙尘暴")))
			else:
				_show_strike_warning("%s来袭 · 开启防护罩(F)或换道" % String(zone.get("label", "沙尘暴")))
	_sandstorm_active = active
	_set_sandstorm_visual(active)
	if not active:
		_sandstorm_tick_accum = 0.0
		return
	_sandstorm_tick_accum += delta
	if _sandstorm_tick_accum < SANDSTORM_TICK:
		return
	_sandstorm_tick_accum = 0.0
	var dps := float(zone.get("dps", SANDSTORM_DEFAULT_DPS))
	var dmg := dps * SANDSTORM_TICK * Global.get_cargo_damage_multiplier()
	var label := String(zone.get("label", "沙尘暴"))
	if _is_shield_protecting():
		var drain := dmg * SHIELD_DRAIN_MULT
		shield_energy = maxf(shield_energy - drain, 0.0)
		if shield_energy <= 0.001:
			shield_active = false
			_shield_warned_empty = true
			_show_strike_warning("防护罩能量耗尽 · 无法抵御沙尘暴")
		elif _hit_feedback != null and player != null:
			_hit_feedback.apply_env_tick_at(player.global_position + Vector3(0.0, 1.7, 0.0), drain * 0.35, "防护罩")
		return
	_apply_cargo_loss(dmg)
	if is_failed:
		return
	if _hit_feedback != null and player != null:
		_hit_feedback.apply_env_tick_at(player.global_position + Vector3(0.0, 1.7, 0.0), dmg, label)
	elif strike_toast_label:
		_show_strike_warning("%s侵蚀" % label)


func _is_shield_protecting() -> bool:
	return shield_active and shield_energy > 0.001


func _toggle_shield() -> void:
	if is_finished or is_failed or is_intro or not gameplay_active:
		return
	if shield_active:
		shield_active = false
		_show_gate_toast("防护罩关闭")
		return
	if shield_energy <= 0.001:
		_show_strike_warning("防护罩能量不足 · 拾取水晶充能")
		return
	shield_active = true
	_shield_warned_empty = false
	_show_gate_toast("防护罩开启 · 可挡沙尘暴")
	_ensure_shield_mesh()


func _ensure_shield_mesh() -> void:
	if player == null:
		return
	if _shield_mesh != null and is_instance_valid(_shield_mesh):
		return
	_shield_mesh = MeshInstance3D.new()
	_shield_mesh.name = "PlayerShieldBubble"
	var sphere := SphereMesh.new()
	sphere.radius = 1.15
	sphere.height = 2.3
	sphere.radial_segments = 24
	sphere.rings = 12
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.85, 1.0, 0.22)
	mat.emission_enabled = true
	mat.emission = Color(0.25, 0.75, 1.0)
	mat.emission_energy_multiplier = 1.6
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sphere.material = mat
	_shield_mesh.mesh = sphere
	_shield_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	player.add_child(_shield_mesh)
	_shield_mesh.position = Vector3(0.0, 1.05, 0.0)


func _update_shield_visual(_delta: float) -> void:
	_ensure_shield_mesh()
	if _shield_mesh == null:
		return
	var protecting := _is_shield_protecting()
	_shield_mesh.visible = protecting
	if not protecting:
		return
	var mat := _shield_mesh.get_active_material(0) as StandardMaterial3D
	if mat == null and _shield_mesh.mesh:
		mat = _shield_mesh.mesh.surface_get_material(0) as StandardMaterial3D
	if mat:
		var ratio := clampf(shield_energy / SHIELD_MAX_ENERGY, 0.0, 1.0)
		var pulse := 0.18 + 0.08 * sin(Time.get_ticks_msec() * 0.008)
		mat.albedo_color.a = pulse + ratio * 0.12
		mat.emission_energy_multiplier = lerpf(0.8, 2.2, ratio)
		if _sandstorm_active:
			mat.emission = Color(0.45, 0.95, 1.0)
		else:
			mat.emission = Color(0.25, 0.75, 1.0)


func _set_sandstorm_visual(active: bool) -> void:
	if _sandstorm_particles:
		_sandstorm_particles.emitting = active
		if active and player != null:
			_sandstorm_particles.global_position = player.global_position + Vector3(0.0, 1.2, 0.0)
	if danger_vignette:
		if active:
			danger_vignette.modulate.a = maxf(danger_vignette.modulate.a, 0.32)
	if _world_environment and _world_environment.environment:
		var env := _world_environment.environment
		var target := _base_fog_density * (3.4 if active else 1.0)
		env.fog_density = lerpf(env.fog_density, target, 0.18)
		if active:
			env.fog_light_color = env.fog_light_color.lerp(Color(0.92, 0.62, 0.28), 0.12)


func _apply_gate_effect(effect: String) -> void:
	match effect:
		"repair", "safe":
			cargo_integrity = minf(cargo_integrity + 10.0, 100.0)
		"fast":
			run_score += 120
			chaser_distance = maxf(chaser_distance - 2.5, CHASER_CATCH_DISTANCE)
		"bonus":
			run_score += 180
		_:
			run_score += 60


func _show_gate_toast(label: String) -> void:
	strike_toast_label.text = "→ %s" % label
	strike_toast_timer = 1.2
	strike_toast_label.modulate = Color(0.55, 0.95, 0.75, 1.0)


func _check_obstacles(dist_from: float, dist_to: float) -> void:
	if _hit_iframe_timer > 0.0:
		return
	var span_min := minf(dist_from, dist_to)
	var span_max := maxf(dist_from, dist_to)
	# 按速度加厚判定带，高速时避免“穿模漏检”
	var speed_pad := maxf(absf(dist_to - dist_from) * 0.32, 0.08)
	var scan_ahead := span_max + 6.0
	var i := _obstacle_scan_index
	var n := obstacles.size()
	while i < n:
		var obstacle: Dictionary = obstacles[i]
		var obstacle_type := String(obstacle.get("type", ""))
		if obstacle_type in ["ramp", "turn_left", "turn_right"]:
			i += 1
			continue
		if bool(obstacle.get("hit", false)):
			i += 1
			continue
		if int(obstacle.get("layer", 0)) != track_layer:
			i += 1
			continue
		var obs_dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
		var half := float(obstacle.get("half_depth", _obstacle_half_depth(obstacle_type))) + speed_pad
		var moving := bool(obstacle.get("moving", false))
		# 已远抛在身后：静态障碍推进扫描游标；移动障碍仍可能回头
		if obs_dist + half < span_min - 1.25:
			if not moving and i == _obstacle_scan_index:
				_obstacle_scan_index += 1
			i += 1
			continue
		# 静态且还很远：跳过（不 break，以免漏检后方已逼近的移动障碍）
		if not moving and obs_dist - half > scan_ahead:
			i += 1
			continue
		if span_max < obs_dist - half or span_min > obs_dist + half:
			i += 1
			continue
		if not _player_in_obstacle_lateral(obstacle):
			i += 1
			continue
		if _hits_obstacle(obstacle):
			obstacle["hit"] = true
			_hit_iframe_timer = HIT_IFRAME_TIME
			_on_runner_strike(_strike_reason_for_obstacle(obstacle), obstacle)
			return
		i += 1


func _obstacle_half_depth(obstacle_type: String) -> float:
	return float(OBSTACLE_HALF_DEPTH.get(obstacle_type, 0.65))


func _obstacle_hit_window(obstacle: Dictionary) -> float:
	return _obstacle_half_depth(String(obstacle.get("type", ""))) + 0.35


func _lane_value_to_index(lane: int) -> int:
	for i in LANES.size():
		if LANES[i] == lane:
			return i
	return 1


func _player_in_obstacle_lateral(obstacle: Dictionary) -> bool:
	var obstacle_type := String(obstacle["type"])
	# 横跨全路的滑铲/高杆屏障 / 主路封堵 / 跳板
	if obstacle_type in ["slide", "high_bar", "ramp", "main_block"]:
		return true
	# 封左：左道+中道有障，只有右道 (≈+LANE_WIDTH) 可过
	if obstacle_type == "block_left":
		return current_lateral < LANE_WIDTH - LANE_BLOCK_SAFE_EDGE
	# 封右：中道+右道有障，只有左道 (≈-LANE_WIDTH) 可过
	if obstacle_type == "block_right":
		return current_lateral > -LANE_WIDTH + LANE_BLOCK_SAFE_EDGE
	var lane_x := float(obstacle["lane"]) * LANE_WIDTH
	var half_w := LANE_HIT_HALF_WIDTH_JUMP if obstacle_type in ["jump", "low_barrier"] else LANE_HIT_HALF_WIDTH
	if bool(obstacle.get("float_orb", false)):
		half_w = LANE_HIT_HALF_WIDTH_JUMP * 0.92
	return absf(current_lateral - lane_x) <= half_w


func _check_collectibles() -> void:
	for collectible in collectibles:
		if collectible["collected"]:
			continue
		if int(collectible.get("layer", 0)) != track_layer:
			continue
		var node := collectible["node"] as Node3D
		if player.global_position.distance_to(node.global_position) > 1.45:
			continue
		collectible["collected"] = true
		node.visible = false
		var kind := String(collectible.get("kind", "coin"))
		if kind == "shield_crystal":
			crystal_collected_count += 1
			var before := shield_energy
			shield_energy = minf(shield_energy + SHIELD_CRYSTAL_RESTORE, SHIELD_MAX_ENERGY)
			_shield_warned_empty = false
			run_score += 8
			_show_gate_toast("水晶充能 +%d" % int(round(shield_energy - before)))
		else:
			collected_count += 1
			run_score += int(LevelConfig.EMBER_COIN_VALUE)


func _try_side_runway_entry() -> void:
	if track_layer != 0 or player == null:
		return
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		_wall_mount_armed = false
		return
	# 必须：靠墙最外道 → 再朝墙按一次（armed）→ 跳跃，才上墙
	if not _is_wall_mount_ready(zone):
		return
	if player.position.y < GROUND_Y + 0.85:
		return
	if vertical_velocity < -2.0:
		return
	track_layer = WALL_RUN_LAYER
	_wall_mount_armed = false
	_last_wall_side = _wall_zone_side(zone)
	lane_index = 1
	target_lane_x = 0.0
	current_lateral = 0.0
	current_wall_y = WALL_LANE_HEIGHTS[1]
	player.position.y = current_wall_y
	vertical_velocity = 0.0
	camera_shake = maxf(camera_shake, 0.1)
	_sync_player_position()
	_show_gate_toast("侧墙跑 · 上下换高度道")


func _is_over_open_pit() -> bool:
	if track_layer != 0:
		return false
	if _is_in_side_runway_pit(track_distance):
		return true
	return _is_in_main_block_pit(track_distance)


func _is_in_main_block_pit(distance: float) -> bool:
	for obstacle in obstacles:
		if String(obstacle.get("type", "")) != "main_block":
			continue
		if int(obstacle.get("layer", 0)) != 0:
			continue
		var center := float(obstacle.get("distance", 0.0))
		var half := float(obstacle.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		if distance >= center - half and distance <= center + half:
			return true
	return false


func _fail_into_pit(reason: String = "坠入主路坍塌坑") -> void:
	if is_failed or is_finished:
		return
	# 定格成坠入坑中，而不是半空跳跃姿势
	if player != null:
		vertical_velocity = -12.0
		player.position.y = minf(player.position.y, GROUND_Y - 1.6)
		_sync_player_position()
		_set_player_pose("landing")
	camera_shake = maxf(camera_shake, 0.35)
	_fail_run(reason)


func _update_side_runway_ground_penalty(_delta: float) -> void:
	# 坑上改为真实坠落判死；此处只做贴墙提示
	if is_finished or is_failed or not gameplay_active:
		return
	if track_layer != 0:
		return
	if not _is_in_side_runway_pit(track_distance):
		return
	if player != null and player.position.y <= GROUND_Y + 0.15 and strike_toast_label:
		_show_strike_warning("主路坍塌 · 立刻上侧墙！")


func _enforce_track_layer() -> void:
	if player == null:
		return
	if _is_wall_running():
		var zone := _side_runway_zone_at(track_distance)
		if zone.is_empty():
			zone = _side_runway_entry_zone(track_distance)
		if zone.is_empty():
			# 离开侧墙：落回靠墙那一主路车道
			track_layer = 0
			_wall_mount_armed = false
			_wall_roll = 0.0
			player.rotation = Vector3(0.0, _path_yaw, 0.0)
			if player_body:
				player_body.rotation = Vector3(0.0, 0.0, body_tilt)
			vertical_velocity = minf(vertical_velocity, -2.0)
			lane_index = 2 if _last_wall_side > 0.0 else 0
			target_lane_x = float(LANES[lane_index]) * LANE_WIDTH
			current_lateral = target_lane_x
			return
		_last_wall_side = _wall_zone_side(zone)
		if player.position.y <= current_wall_y + 0.05 and vertical_velocity <= 0.01:
			player.position.y = current_wall_y
			vertical_velocity = 0.0
		return
	if _is_on_ground() and not _is_over_open_pit() and absf(player.position.y - _layer_height(0)) > 0.05:
		player.position.y = _layer_height(0)
		vertical_velocity = 0.0


func _check_ramps() -> void:
	for obstacle in obstacles:
		if String(obstacle["type"]) != "ramp":
			continue
		if int(obstacle.get("layer", 0)) != track_layer:
			continue
		var obs_dist: float = float(obstacle["distance"])
		if abs(track_distance - obs_dist) > 1.5:
			continue
		if not _player_in_obstacle_lateral(obstacle):
			continue
		if vertical_velocity > 2.0 or _is_on_ground():
			vertical_velocity = maxf(vertical_velocity, JUMP_SPEED * 1.15)
			camera_shake = maxf(camera_shake, 0.12)


func _update_moving_obstacles(delta: float) -> void:
	for obstacle in obstacles:
		if not bool(obstacle.get("moving", false)):
			continue
		obstacle["move_offset"] = float(obstacle.get("move_offset", 0.0)) + float(obstacle["move_speed"]) * delta
		_place_obstacle_node(obstacle)


func _place_obstacle_node(obstacle: Dictionary) -> void:
	var node := obstacle["node"] as Node3D
	var dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
	var layer: int = int(obstacle.get("layer", 0))
	var y := _layer_height(layer) + float(obstacle.get("y_offset", 0.0))
	var obstacle_type := String(obstacle.get("type", ""))
	# 全路屏障居中放置，贴路面（略低于角色脚底高度，避免「浮空」）
	var lateral := 0.0 if obstacle_type in ["slide", "high_bar", "main_block", "ramp"] else float(obstacle["lane"]) * LANE_WIDTH
	if obstacle_type in ["slide", "high_bar", "main_block"]:
		y -= 0.06
	var placed := _world_on_path(dist, lateral, y, layer)
	node.position = placed["pos"]
	node.rotation.y = float(placed["yaw"])


func _finish_run() -> void:
	is_finished = true
	_play_player_animation("celebrate")
	var cargo_load := int(mission.get("cargo_load", 100))
	# 据点进度贡献按设计固定装载量 100 × 完整度%
	var progress_cargo_load := 100
	var repair_total := Global.DEFAULT_OUTPOST_REPAIR_TOTAL
	var light_reward_coins := 0
	var is_custom := CustomLevels.has_level(Global.runner_location_id)
	var progress_result := {
		"newly_lit": false,
		"already_lit": false,
		"contribution": 0,
		"progress_after": 0,
		"repair_total": repair_total,
	}
	if not is_custom:
		if LevelConfig.has_method("get_outpost_meta"):
			var outpost_meta: Dictionary = LevelConfig.get_outpost_meta(Global.runner_location_id)
			repair_total = maxi(1, int(outpost_meta.get("repair_total", repair_total)))
			light_reward_coins = maxi(0, int(outpost_meta.get("reward_coins", 0)))
		progress_result = Global.apply_runner_delivery_progress(
			Global.runner_planet_id,
			Global.runner_location_id,
			progress_cargo_load,
			cargo_integrity,
			repair_total
		)
	var newly_lit := bool(progress_result.get("newly_lit", false))
	var already_lit := bool(progress_result.get("already_lit", false))
	var contribution := int(progress_result.get("contribution", 0))
	var progress_after := int(progress_result.get("progress_after", 0))
	var progress_total := int(progress_result.get("repair_total", repair_total))
	if newly_lit:
		_apply_mission_unlocks()
		if light_reward_coins > 0:
			Global.add_ember_coins(light_reward_coins)
		Global.pending_location_showcase_id = Global.runner_location_id
	else:
		Global.pending_location_showcase_id = ""
	var delivered := int(float(cargo_load) * cargo_integrity * 0.01)
	var grade: String = LevelConfig.integrity_grade(cargo_integrity)
	var grade_label: String = LevelConfig.integrity_grade_label(cargo_integrity) if LevelConfig.has_method("integrity_grade_label") else grade
	var base_coins := collected_count * int(LevelConfig.EMBER_COIN_VALUE)
	var grade_mult: float = LevelConfig.grade_coin_multiplier(grade) if LevelConfig.has_method("grade_coin_multiplier") else 1.0
	var time_mult := MissionTypes.time_bonus_multiplier(_mission_profile, elapsed, _run_time)
	var type_reward := int(_mission_profile.get("base_reward", mission.get("base_reward", 0)))
	var coin_bonus := int(round(float(base_coins) * Global.get_coin_yield_multiplier() * grade_mult * time_mult))
	var type_reward_paid := int(round(float(type_reward) * time_mult))
	run_score += delivered + coin_bonus + type_reward_paid
	Global.add_ember_coins(coin_bonus + type_reward_paid)
	var xp_result: Dictionary = Global.grant_messenger_runner_rewards(
		grade,
		int(mission.get("difficulty", 1)),
		newly_lit
	)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var level_text := "Lv.%d" % int(xp_result["new_level"])
	if bool(xp_result["level_up"]):
		level_text = "升级！Lv.%d" % int(xp_result["new_level"])
	var progress_line := "据点进度 +%d（%d / %d）" % [contribution, progress_after, progress_total]
	if is_custom:
		progress_line = "自定义关卡通关（不计入据点修复）"
	var unlock_line := "继续运输以点亮据点"
	var batch_just_unlocked := bool(progress_result.get("batch_just_unlocked", false))
	var unlocked_batch := int(progress_result.get("unlocked_batch", 1))
	if newly_lit:
		unlock_line = "据点已点亮！星火币 +%d\n相邻区域已可继续探索" % light_reward_coins
	elif already_lit:
		unlock_line = "据点此前已点亮（复跑结算）"
		progress_line = "据点进度 %d / %d（已满）" % [progress_after, progress_total]
	if batch_just_unlocked:
		unlock_line += "\n新批次解锁：%s" % MissionDispatch.batch_unlock_summary(Global.runner_planet_id, unlocked_batch)
	var type_zh := String(mission.get("task_type_zh", _mission_profile.get("name_zh", "补给")))
	var type_line := "任务类型：%s（%s）· %0.0f 秒" % [
		type_zh,
		String(mission.get("task_type", "Supply Run")),
		_run_time,
	]
	var time_line := ""
	if bool(_mission_profile.get("time_bonus", false)):
		time_line = "\n限时倍率 ×%0.2f（剩余 %0.1f 秒）" % [time_mult, maxf(_run_time - elapsed, 0.0)]
	var settlement_body := "MISSION COMPLETE / 任务完成\n\n%s\n货物完整度：%0.0f%%\n评级：%s\n%s\n%s%s\n\n采集奖励 %d × 评级 %0.2f × 限时 %0.2f = 星火币 +%d\n类型奖励 +%d\n经验 +%d（%s）" % [
		type_line,
		cargo_integrity,
		grade_label,
		progress_line,
		unlock_line,
		time_line,
		base_coins,
		grade_mult,
		time_mult,
		coin_bonus,
		type_reward_paid,
		int(xp_result["xp_gain"]),
		level_text,
	]
	_show_state("MISSION COMPLETE / 任务完成", settlement_body)
	if state_restart_button:
		if newly_lit:
			state_restart_button.visible = false
		else:
			state_restart_button.visible = true
			state_restart_button.text = "再次运输" if already_lit else "继续运输"


func _apply_mission_unlocks() -> void:
	# 点亮后的揭示与任务板由批次派发统一处理
	Global.sync_mission_dispatch(Global.runner_planet_id)
	var revealed := Global.get_revealed_exploration_locations(
		Global.runner_planet_id,
		MissionDispatch.get_batch1_location_ids(Global.runner_planet_id)
	)
	if not revealed.has(Global.runner_location_id):
		revealed.append(Global.runner_location_id)
	for linked_id in mission.get("unlock_ids", []):
		var location_id := String(linked_id)
		# 仅揭示已解锁批次内的相邻点，避免提前开下一批
		if location_id == "":
			continue
		if not MissionDispatch.is_location_batch_unlocked(Global.runner_planet_id, location_id):
			continue
		if not revealed.has(location_id):
			revealed.append(location_id)
	Global.set_revealed_exploration_locations(Global.runner_planet_id, revealed)
	Global.sync_mission_dispatch(Global.runner_planet_id)


func _fail_run(reason: String = "被零潮捕获") -> void:
	is_failed = true
	_play_player_animation("idle")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var fail_reason := reason
	if cargo_integrity <= 0.0:
		fail_reason = "货物损毁"
	elif reason.contains("零潮") and not _chaser_enabled:
		fail_reason = "时间耗尽"
	_show_state(
		"MISSION FAILED / 任务失败",
		"失败原因：%s\n货物完整度：%0.0f%%\n坚持 %0.1f 秒" % [
			fail_reason,
			cargo_integrity,
			elapsed,
		]
	)
	if state_restart_button:
		state_restart_button.visible = true


func _return_to_exploration_map() -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		_pause_overlay.close_pause()
	Global.exploration_planet_id = Global.runner_planet_id
	Global.mobile_home_tab = "map"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.change_game_scene(PlanetDatabase.EXPLORATION_SCENE)


func _setup_pause_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PauseLayer"
	layer.layer = 40
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_pause_overlay = MobilePauseOverlay.new()
	_pause_overlay.configure({
		"quit_text": "返回地图",
		"show_quit": true,
		"show_pause_button": true,
	})
	_pause_overlay.quit_pressed.connect(_return_to_exploration_map)
	layer.add_child(_pause_overlay)


func _strike_reason_for_obstacle(obstacle: Dictionary) -> String:
	var custom := String(obstacle.get("strike_label", ""))
	if custom != "":
		return "撞上%s" % custom
	var obstacle_type := String(obstacle["type"])
	if obstacle_type in LevelConfig.OBSTACLE_TYPES:
		return "撞上%s" % LevelConfig.OBSTACLE_TYPES[obstacle_type]
	return "撞上障碍"


func _on_runner_strike(reason: String, obstacle: Dictionary = {}) -> void:
	var obstacle_type := String(obstacle.get("type", ""))
	if obstacle_type == "main_block":
		_fail_into_pit("冲入主路坍塌带（需上侧墙绕过）")
		return
	strike_count += 1
	strike_recovery_timer = 0.0
	chaser_distance = maxf(chaser_distance - CHASER_HIT_PENALTY, CHASER_CATCH_DISTANCE)
	speed_penalty_mult = HIT_SLOW_FACTOR
	speed_penalty_timer = HIT_SLOW_DURATION
	chaser_pulse = 1.0
	var tier := float(STRIKE_DAMAGE_TIER.get(obstacle_type, 1.0))
	var damage: float = float(LevelConfig.CARGO_DAMAGE_PER_HIT) * tier * Global.get_cargo_damage_multiplier()
	var intensity: int = HitFeedback.Intensity.MEDIUM
	if tier >= 1.35:
		intensity = HitFeedback.Intensity.HEAVY
	elif tier <= 0.9:
		intensity = HitFeedback.Intensity.LIGHT
	_apply_cargo_loss(damage)
	var impact_pos := player.global_position + Vector3(0.0, 1.7, 0.0) if player else Vector3.ZERO
	if _hit_feedback != null:
		_hit_feedback.apply_impact(impact_pos, intensity, damage, reason)
	else:
		camera_shake = maxf(camera_shake, 0.22)
	if is_failed:
		return
	if chaser_distance <= CHASER_CATCH_DISTANCE:
		if _chaser_enabled:
			_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)
		return
	# HitFeedback 飘字 + Toast 完整度，双通道更可读
	_show_strike_warning(reason)


func _show_strike_warning(reason: String) -> void:
	if not gameplay_active:
		return
	intro_panel.visible = false
	if _chaser_enabled:
		strike_toast_label.text = "⚠ %s  |  %s %0.0fm  |  完整度 %0.0f%%" % [
			reason, LevelConfig.CHASER_NAME, chaser_distance, cargo_integrity
		]
	else:
		strike_toast_label.text = "⚠ %s  |  完整度 %0.0f%%" % [reason, cargo_integrity]
	strike_toast_timer = 1.6
	strike_toast_label.modulate = Color(1.0, 0.55, 0.35, 1.0)


func _update_chaser(delta: float) -> void:
	if not _chaser_enabled:
		return
	chaser_distance = maxf(chaser_distance - CHASER_BASE_CREEP * delta, CHASER_CATCH_DISTANCE)
	if strike_count > 0:
		strike_recovery_timer += delta
		if strike_recovery_timer >= STRIKE_RECOVERY_TIME:
			strike_count = 0
			strike_recovery_timer = 0.0
	elif chaser_distance < CHASER_MAX_DISTANCE:
		chaser_distance = minf(chaser_distance + CHASER_RECOVERY_RATE * delta, CHASER_MAX_DISTANCE)


func _check_chaser_caught() -> void:
	if not _chaser_enabled:
		return
	if chaser_distance <= CHASER_CATCH_DISTANCE:
		_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)


func _update_pre_run(delta: float) -> void:
	intro_elapsed += delta
	if pre_run_phase == "loading":
		intro_title.text = "Preparing Route..."
		intro_body.text = "正在规划运输路线…"
		if _world_ready and intro_elapsed >= PRE_RUN_LOADING_TIME:
			pre_run_phase = "countdown"
			countdown_step = 3
			countdown_timer = 0.0
		return

	if pre_run_phase == "countdown":
		countdown_timer += delta
		intro_title.text = str(countdown_step)
		var type_zh := String(mission.get("task_type_zh", "补给"))
		var hint := String(mission.get("task_hint", _mission_profile.get("hint", "")))
		intro_body.text = "%s · %0.0f 秒\n%s" % [type_zh, _run_time, hint]
		if countdown_timer >= PRE_RUN_COUNTDOWN_STEP:
			countdown_timer = 0.0
			countdown_step -= 1
			if countdown_step <= 0:
				is_intro = false
				gameplay_active = true
				intro_panel.visible = false
				_set_player_intro_facing(false)
		return


func _ease_out_cubic(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)


func _sync_chaser_from_track() -> void:
	if not chaser:
		return
	# 第三人称镜头下，3D 追逐者放在身后一定会挡视线；改为 HUD 提示
	chaser.visible = false


func _start_slide() -> void:
	slide_timer = SLIDE_TIME
	# 滑铲期间锁定在当前横向位置，避免换道 lerp 悄悄进行
	lane_index = _nearest_lane_index(current_lateral)
	target_lane_x = current_lateral
	player_body.scale = Vector3.ONE
	player_body.position.y = 0.0
	camera_shake = maxf(camera_shake, 0.06)


func _end_slide() -> void:
	slide_timer = 0.0
	player_body.scale = Vector3.ONE
	player_body.position.y = 0.0


func _is_sliding() -> bool:
	return slide_timer > 0.0


func _hits_obstacle(obstacle: Dictionary) -> bool:
	var obstacle_type := String(obstacle["type"])
	match obstacle_type:
		"slide", "high_bar":
			# 横杆：滑铲钻过，或跳起越过
			return not (_is_sliding() or _player_clears_obstacle(obstacle))
		"jump", "low_barrier":
			return not _player_clears_obstacle(obstacle)
		"train", "train_moving":
			return not (_is_sliding() or _player_clears_obstacle(obstacle))
		"block_left", "block_right", "main_block":
			# 横向已过滤，进窗口即撞；主路封堵不可跳过
			return true
		"ramp", "turn_left", "turn_right":
			return false
	return not _player_clears_obstacle(obstacle)


func _player_clears_obstacle(obstacle: Dictionary) -> bool:
	# clear_height 为绝对世界 Y；略放宽，减少“脚擦到也算撞”
	var clear_y := float(obstacle.get("clear_height", 1.28)) - 0.06
	return player.position.y >= clear_y


func _player_clears_low_obstacle(obstacle: Dictionary) -> bool:
	return _player_clears_obstacle(obstacle)


func _load_planet_assets() -> void:
	var assets: Dictionary = LevelConfig.get_assets()
	_world_panorama = load(String(assets.get("panorama", "res://3d素材/三拼地图.png")))
	_jump_obstacle_paths.clear()
	for path in assets.get("jump_obstacles", []):
		_jump_obstacle_paths.append(String(path))
	_slide_obstacle_paths.clear()
	for path in assets.get("slide_obstacles", []):
		_slide_obstacle_paths.append(String(path))
	if _slide_obstacle_paths.is_empty() and assets.has("slide_obstacle"):
		_slide_obstacle_paths.append(String(assets.get("slide_obstacle")))
	_side_prop_paths.clear()
	for path in assets.get("side_props", []):
		_side_prop_paths.append(String(path))
	if _side_prop_paths.is_empty():
		_side_prop_paths.append_array(_jump_obstacle_paths)
		_side_prop_paths.append_array(_slide_obstacle_paths)
	_landmark_prop_paths.clear()
	for path in assets.get("landmark_props", []):
		_landmark_prop_paths.append(String(path))
	if _landmark_prop_paths.is_empty() and assets.has("hearth"):
		_landmark_prop_paths.append(String(assets.get("hearth")))
	var slide_path := _slide_obstacle_paths[0] if not _slide_obstacle_paths.is_empty() else String(assets.get("slide_obstacle", "res://3d素材/障碍物-需滑铲.glb"))
	_slide_obstacle_scene = _load_runner_scene(slide_path, false)
	_hearth_scene_path = LevelConfig.get_location_hearth_model(Global.runner_location_id) if LevelConfig.has_method("get_location_hearth_model") else String(assets.get("hearth", "res://3d素材/居民穹顶据点 3d model.glb"))
	_player_scene_paths = _resolve_player_scene_paths(assets)


func _resolve_player_scene_paths(assets: Dictionary) -> Dictionary:
	var character_id := Global.get_selected_character_id()
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	if not CharacterRoster.is_unlocked(character_id, unlocked):
		character_id = CharacterRoster.CHAR_ELSA
	if LevelConfig.has_method("get_player_assets"):
		var configured: Variant = LevelConfig.get_player_assets(character_id)
		if configured is Dictionary and not configured.is_empty():
			return configured
	var players: Variant = assets.get("players", {})
	if players is Dictionary and players.has(character_id):
		return (players[character_id] as Dictionary).duplicate(true)
	if assets.get("player") is Dictionary:
		return (assets["player"] as Dictionary).duplicate(true)
	return {}


func _player_asset_path(key: String, fallback: String) -> String:
	var path := String(_player_scene_paths.get(key, ""))
	return path if path != "" else fallback


func _player_run_anim_name() -> String:
	return _player_asset_path("run_anim", ANIMATED_PLAYER_RUN_ANIM)


func _player_run_anim_speed_mult() -> float:
	if _player_scene_paths.has("run_anim_speed"):
		return float(_player_scene_paths["run_anim_speed"])
	return 1.0


func _player_surface_texture_path() -> String:
	return _player_asset_path("surface_texture", "")


func _apply_player_surface_textures(model: Node3D) -> void:
	var tex_path := _player_surface_texture_path()
	if tex_path == "" or not ResourceLoader.exists(tex_path):
		return
	var tex := load(tex_path) as Texture2D
	if tex == null:
		return
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = tex
		mat.albedo_color = Color.WHITE
		mat.metallic = 0.0
		mat.roughness = 0.9
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		mesh_instance.material_override = mat


func _uses_skeletal_run() -> bool:
	return _skeletal_run_enabled and player_animation_player != null


func _hide_air_pose_models() -> void:
	for key in ["jump_start", "jump_peak", "landing", "slide"]:
		var model := player_pose_models.get(key) as Node3D
		if model:
			model.visible = false


func _show_air_pose_model(pose_name: String) -> void:
	_hide_air_pose_models()
	var model := player_pose_models.get(pose_name) as Node3D
	if model:
		model.visible = true


func _apply_skeletal_player_pose(pose_name: String) -> void:
	var logical := pose_name
	if pose_name in ["run_left", "run_right"]:
		logical = "run"
	if player_pose_name == logical:
		return
	player_pose_name = logical

	match logical:
		"slide":
			if player_pose_root:
				player_pose_root.visible = false
			if player_slide_pose_root:
				player_slide_pose_root.visible = true
			_hide_air_pose_models()
		"jump_start", "jump_peak", "landing":
			if player_pose_root:
				player_pose_root.visible = false
			if player_slide_pose_root:
				player_slide_pose_root.visible = false
			_show_air_pose_model(logical)
		_:
			if player_pose_root:
				player_pose_root.visible = true
			if player_slide_pose_root:
				player_slide_pose_root.visible = false
			_hide_air_pose_models()
			_play_player_animation("idle" if logical == "idle" else "run")


func _player_yaw_degrees(key: String, fallback: float) -> float:
	if _player_scene_paths.has(key):
		return float(_player_scene_paths[key])
	return fallback


func _load_cargo_icon() -> void:
	if cargo_icon == null:
		return
	var icon_path := ""
	if LevelConfig.has_method("get_cargo_icon_path"):
		icon_path = String(LevelConfig.get_cargo_icon_path(mission))
	if icon_path != "" and ResourceLoader.exists(icon_path):
		cargo_icon.texture = load(icon_path) as Texture2D
		cargo_icon.visible = true
	else:
		cargo_icon.visible = false


func _build_world() -> void:
	var theme: Dictionary = LevelConfig.get_theme()
	_road_style_id = Global.get_runner_road_style()
	if CustomLevels.has_level(Global.runner_location_id):
		var custom_style := CustomLevels.get_road_style(Global.runner_location_id)
		if custom_style != "":
			_road_style_id = Global.normalize_runner_road_style(custom_style)
	_background_style_id = Global.get_runner_background_style()
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	_configure_runner_sky(environment, theme)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.fog_enabled = true
	environment.glow_enabled = false
	world.environment = environment
	_world_environment = world
	add_child(world)
	if _background_uses_starfield():
		_build_starfield()

	var sun := DirectionalLight3D.new()
	sun.name = "RunnerSun"
	sun.rotation_degrees = Vector3(-52, 35, 0)
	_configure_runner_sun(sun, theme)
	add_child(sun)

	_build_path_track()
	_build_side_runway_tracks()
	_build_sandstorm_zones()
	for zone in _junction_zones():
		_build_choice_gate(float(zone["distance"]), zone)
	_build_planet_surroundings(theme)
	_build_finish_gate()
	_apply_background_environment()
	_apply_road_style_environment()
	if _world_environment and _world_environment.environment:
		_base_fog_density = _world_environment.environment.fog_density


func _background_uses_sky_panorama() -> bool:
	return _background_style_id in ["desert_crystal", "industrial_ruin", "savanna"]


func _background_uses_starfield() -> bool:
	return _background_style_id in ["desert_crystal", "industrial_ruin", "savanna", "starfield"]


func _configure_runner_sky(environment: Environment, theme: Dictionary) -> void:
	if _background_uses_sky_panorama():
		environment.background_mode = Environment.BG_SKY
		environment.background_color = theme.get("background", Color(0.14, 0.09, 0.05))
		var sky := Sky.new()
		if _world_panorama != null:
			var panorama := PanoramaSkyMaterial.new()
			panorama.panorama = _world_panorama
			panorama.energy_multiplier = 1.25
			sky.sky_material = panorama
		else:
			var proc := ProceduralSkyMaterial.new()
			proc.sky_top_color = Color(0.55, 0.42, 0.28)
			proc.sky_horizon_color = Color(0.92, 0.68, 0.42)
			proc.ground_bottom_color = Color(0.28, 0.16, 0.08)
			proc.ground_horizon_color = Color(0.72, 0.48, 0.28)
			proc.sun_angle_max = 30.0
			proc.energy_multiplier = 1.2
			sky.sky_material = proc
		environment.sky = sky
		environment.sky_rotation = Vector3.ZERO
	elif _background_style_id == "starfield":
		environment.background_mode = Environment.BG_COLOR
		environment.background_color = Color(0.006, 0.01, 0.022)
	else:
		environment.background_mode = Environment.BG_COLOR
		environment.background_color = Color(0.01, 0.018, 0.032)


func _configure_runner_sun(sun: DirectionalLight3D, theme: Dictionary) -> void:
	if _background_style_id in ["void_dark", "starfield"]:
		sun.light_color = Color(0.62, 0.82, 1.0)
		sun.light_energy = 0.55
	else:
		sun.light_color = theme.get("sun_color", Color(1.0, 0.82, 0.55))
		sun.light_energy = float(theme.get("sun_energy", 2.4))


func _apply_background_environment() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	var theme: Dictionary = LevelConfig.get_theme()
	match _background_style_id:
		"void_dark":
			env.ambient_light_color = Color(0.14, 0.22, 0.32)
			env.ambient_light_energy = 0.95
			env.fog_light_color = Color(0.08, 0.14, 0.22)
			env.fog_density = 0.0012
			env.fog_aerial_perspective = 0.38
			env.glow_enabled = false
			env.tonemap_exposure = 1.08
			_boost_runner_lights(Color(0.62, 0.82, 1.0), 0.55, 0.95)
		"starfield":
			env.ambient_light_color = Color(0.12, 0.18, 0.28)
			env.ambient_light_energy = 0.82
			env.fog_light_color = Color(0.06, 0.1, 0.18)
			env.fog_density = 0.0008
			env.fog_aerial_perspective = 0.32
			env.glow_enabled = true
			env.glow_intensity = 0.35
			env.glow_strength = 0.9
			env.glow_bloom = 0.18
			env.tonemap_exposure = 1.1
			_boost_runner_lights(Color(0.58, 0.78, 1.0), 0.48, 0.85)
		"industrial_ruin":
			env.ambient_light_color = Color(0.72, 0.68, 0.62)
			env.ambient_light_energy = 1.15
			env.fog_light_color = Color(0.55, 0.48, 0.38)
			env.fog_density = 0.0024
			env.fog_aerial_perspective = 0.5
			env.glow_enabled = false
			env.tonemap_exposure = 1.0
			_boost_runner_lights(Color(0.92, 0.78, 0.55), 2.1, 0.58)
		"savanna":
			env.ambient_light_color = Color(0.94, 0.78, 0.48)
			env.ambient_light_energy = 1.38
			env.fog_light_color = Color(0.86, 0.62, 0.32)
			env.fog_density = 0.0028
			env.fog_aerial_perspective = 0.58
			env.glow_enabled = false
			env.tonemap_exposure = 1.02
			_boost_runner_lights(Color(1.0, 0.82, 0.52), 2.5, 0.6)
		_:
			env.ambient_light_color = theme.get("ambient", Color(0.92, 0.68, 0.44))
			env.ambient_light_energy = float(theme.get("ambient_energy", 1.35))
			env.fog_light_color = theme.get("fog_color", Color(0.82, 0.48, 0.2))
			env.fog_density = float(theme.get("fog_density", 0.0022))
			env.fog_aerial_perspective = 0.55
			env.glow_enabled = false
			env.tonemap_exposure = 1.0
			_boost_runner_lights(
				theme.get("sun_color", Color(1.0, 0.82, 0.55)),
				float(theme.get("sun_energy", 2.4)),
				0.55
			)


func _build_path_track() -> void:
	if not _path_baked:
		_bake_track_path()
		_path_baked = true
	if _road_root == null:
		_road_root = Node3D.new()
		_road_root.name = "RoadRoot"
		track_root.add_child(_road_root)
	else:
		while _road_root.get_child_count() > 0:
			_road_root.get_child(0).free()
	var kit := _make_road_style_kit(_road_style_id)
	var lane_y := GROUND_Y - 0.05
	var track_end := maxf(_path_length, _track_length) + 28.0
	var theme: Dictionary = LevelConfig.get_theme()
	# 全息轨：托底也用暗砂，别用高亮橙沙把赛道「架空」
	var sand_mat: Material = kit.get("island", kit["shoulder"])
	if _road_style_id == "holographic":
		sand_mat = kit["island"]
	elif _road_style_id == "energy_neon":
		sand_mat = kit["island"]
	elif _road_style_id == "coarse_desert":
		sand_mat = kit["shoulder"]
	elif sand_mat == null:
		sand_mat = _make_material(theme.get("sand", Color(0.76, 0.43, 0.16)), Color(1.0, 0.55, 0.18), 0.1)

	# 连续挤出：托底/路肩可贯通；主路面在岔口中段挖空，改由左右岔路承接（中间禁跑）
	if _road_style_id in ["holographic", "energy_neon"]:
		var road_half := 6.4 if _road_style_id == "energy_neon" else 6.0
		var shoulder_half := 1.6
		var shoulder_lat := road_half + shoulder_half
		var apron_half := shoulder_lat + shoulder_half + 0.2
		var underlay := _make_material(Color(0.02, 0.06, 0.1), Color(0.15, 0.45, 0.62), 0.55)
		if _road_style_id == "energy_neon":
			underlay = _make_material(Color(0.01, 0.02, 0.04), Color(0.08, 0.28, 0.42), 0.35)
		# 托底也挖中段，避免中间仍像可跑路面
		_attach_path_strip(0.0, track_end, apron_half, lane_y - 0.018, underlay, 1.75, 0.0, true)
		_attach_path_strip(0.0, track_end, road_half, lane_y, kit["road"], 1.75, 0.0, true)
		_attach_path_strip(0.0, track_end, shoulder_half, lane_y - 0.008, kit["shoulder"], 1.75, -shoulder_lat, true)
		_attach_path_strip(0.0, track_end, shoulder_half, lane_y - 0.008, kit["shoulder"], 1.75, shoulder_lat, true)
		if _road_style_id == "holographic":
			var curb_half := 0.07
			var curb_lat := road_half - 0.02
			_attach_path_strip(0.0, track_end, curb_half, lane_y + 0.012, kit["curb"], 1.75, -curb_lat, true)
			_attach_path_strip(0.0, track_end, curb_half, lane_y + 0.012, kit["curb"], 1.75, curb_lat, true)
			_attach_path_strip(0.0, track_end, 0.055, lane_y + 0.01, kit["line"], 1.75, -(curb_lat + 0.14), true)
			_attach_path_strip(0.0, track_end, 0.055, lane_y + 0.01, kit["line"], 1.75, curb_lat + 0.14, true)
			# 主路三道分隔线（岔口中段同样挖空）
			_attach_path_strip(0.0, track_end, 0.04, lane_y + 0.014, kit["line"], 1.75, -LANE_WIDTH, true)
			_attach_path_strip(0.0, track_end, 0.04, lane_y + 0.014, kit["line"], 1.75, LANE_WIDTH, true)
	else:
		var foundation_half := 14.0 if _road_style_id == "planet" else (16.0 if _road_style_id == "coarse_desert" else 21.0)
		var foundation_mat: Material = kit["island"] if _road_style_id in ["planet", "coarse_desert"] else sand_mat
		var foundation_y := lane_y - 0.012 if _road_style_id in ["planet", "coarse_desert"] else GROUND_Y - 0.14
		_attach_path_strip(0.0, track_end, foundation_half, foundation_y, foundation_mat, 2.5, 0.0, true)
		var shoulder_half := 9.2 if _road_style_id != "coarse_desert" else (foundation_half - 6.5)
		_attach_path_strip(0.0, track_end, shoulder_half, lane_y - 0.012, kit["shoulder"], 2.0, 0.0, true)
		var road_half := 6.0 if _road_style_id == "alien_energy" else (6.5 if _road_style_id == "coarse_desert" else 6.3)
		if _road_style_id in ["alien_energy", "planet", "coarse_desert"]:
			var opaque_road := _make_opaque_road_base_material(_road_style_id)
			_attach_path_strip(0.0, track_end, road_half, lane_y - 0.03 if _road_style_id == "coarse_desert" else lane_y - 0.02, opaque_road, 1.75, 0.0, true)
		_attach_path_strip(0.0, track_end, road_half, lane_y, kit["road"], 1.75, 0.0, true)
		var curb_half := 0.07
		var curb_lat := road_half - 0.02
		_attach_path_strip(0.0, track_end, curb_half, lane_y + 0.012, kit["curb"], 1.75, -curb_lat, true)
		_attach_path_strip(0.0, track_end, curb_half, lane_y + 0.012, kit["curb"], 1.75, curb_lat, true)
		if _road_style_id == "alien_energy":
			_attach_path_strip(0.0, track_end, 0.05, lane_y + 0.008, kit["line"], 1.75, 0.0, true)

	_build_start_pad(kit["road"], kit["shoulder"], kit["curb"], kit["line"], kit["post"], lane_y)
	for zone in _junction_zones():
		_build_fork_branch_roads(zone, kit["road"], kit["shoulder"], kit["curb"], kit["line"], kit["island"], lane_y)
	_build_y_fork_branch_roads(kit, lane_y)


func _build_side_runway_tracks() -> void:
	if LevelConfig == null:
		return
	var kit := _make_road_style_kit(_road_style_id)
	for zone in _side_runway_zones():
		_attach_wall_run_mesh(zone, kit)
		_attach_side_runway_pit(zone, kit)
	# main_block：沿路径挖坑+警示，避免长方体在弯道斜出跑道外
	for gap in _main_block_road_gaps():
		_attach_main_block_path_pit(gap, kit)


func _build_sandstorm_zones() -> void:
	for zone in _sandstorm_zones():
		_attach_sandstorm_volume(zone)
	_sandstorm_particles = _make_sandstorm_particles()
	add_child(_sandstorm_particles)
	_sandstorm_particles.emitting = false


func _attach_sandstorm_volume(zone: Dictionary) -> void:
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 40.0))
	var layout := _sandstorm_volume_layout(zone)
	var half_w: float = float(layout["half_width"])
	var bias: float = float(layout["lateral_bias"])
	var haze_mat := _make_material(Color(0.86, 0.55, 0.22, 0.16), Color(1.0, 0.62, 0.22), 0.55)
	haze_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	haze_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	# 沿路径铺一段半透明沙雾罩（宽度/横向偏移随占据列数变化）
	_attach_path_strip_segment(start, start + length, half_w, GROUND_Y + 1.6, haze_mat, 2.2, bias)
	_attach_path_strip_segment(start, start + length, half_w + 0.8, GROUND_Y + 3.2, haze_mat, 2.4, bias)
	# 入口警示环（对准占据列中心）
	var sample := _sample_path(start + 1.5)
	var ring := MeshInstance3D.new()
	ring.name = "SandstormGate"
	var ring_mesh := TorusMesh.new()
	var ring_r := clampf(half_w * 0.55, 1.6, 5.7)
	ring_mesh.inner_radius = ring_r
	ring_mesh.outer_radius = ring_r + 0.45
	ring_mesh.rings = 12
	ring_mesh.ring_segments = 28
	var ring_mat := _make_material(Color(0.95, 0.55, 0.18, 0.55), Color(1.0, 0.55, 0.12), 1.6)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_mesh.material = ring_mat
	ring.mesh = ring_mesh
	var right: Vector3 = sample["right"]
	ring.position = (sample["pos"] as Vector3) + right * bias + Vector3(0.0, GROUND_Y + 1.8, 0.0)
	ring.rotation = Vector3(PI * 0.5, float(sample["yaw"]), 0.0)
	track_root.add_child(ring)


func _make_sandstorm_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "SandstormDust"
	particles.amount = 96
	particles.lifetime = 1.35
	particles.preprocess = 0.4
	particles.visibility_aabb = AABB(Vector3(-18, -4, -18), Vector3(36, 14, 36))
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1.0, 0.15, 0.35)
	mat.spread = 55.0
	mat.initial_velocity_min = 6.0
	mat.initial_velocity_max = 14.0
	mat.gravity = Vector3(0.0, -0.4, 0.0)
	mat.scale_min = 0.08
	mat.scale_max = 0.22
	mat.color = Color(0.92, 0.68, 0.35, 0.7)
	particles.process_material = mat
	var draw := SphereMesh.new()
	draw.radius = 0.08
	draw.height = 0.16
	var draw_mat := StandardMaterial3D.new()
	draw_mat.albedo_color = Color(0.9, 0.65, 0.32, 0.55)
	draw_mat.emission_enabled = true
	draw_mat.emission = Color(0.85, 0.5, 0.18)
	draw_mat.emission_energy_multiplier = 0.45
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw.material = draw_mat
	particles.draw_pass_1 = draw
	return particles


func _side_runway_pit_range(zone: Dictionary) -> Vector2:
	var start := float(zone["start"])
	var length := float(zone.get("length", 70.0))
	# 入口留几米上墙，中后段挖坑
	var pit_s := start + 5.0
	var pit_e := start + length - 2.0
	return Vector2(pit_s, pit_e)


func _main_block_road_gaps() -> Array:
	# 路网建造早于障碍注册：直接读本关障碍表
	var items: Array = []
	if CustomLevels.has_level(Global.runner_location_id):
		items = CustomLevels.load_obstacles(Global.runner_location_id)
	elif LevelConfig != null and LevelConfig.has_method("build_obstacles"):
		items = LevelConfig.build_obstacles()
	var gaps: Array = []
	var seen: Dictionary = {}
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if int(item.get("layer", 0)) != 0:
			continue
		var center := float(item.get("distance", 0.0))
		var half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		var key := "%d" % int(round(center))
		if seen.has(key):
			continue
		seen[key] = true
		gaps.append(Vector2(center - half, center + half))
	return gaps


func _is_in_side_runway_pit(distance: float) -> bool:
	for zone in _side_runway_zones():
		var pit: Vector2 = _side_runway_pit_range(zone)
		if distance >= pit.x and distance <= pit.y:
			return true
	return false


func _attach_side_runway_pit(zone: Dictionary, kit: Dictionary) -> void:
	var pit: Vector2 = _side_runway_pit_range(zone)
	_attach_path_pit_visual(pit, kit, "SideRunwayPit")


func _attach_main_block_path_pit(pit: Vector2, kit: Dictionary) -> void:
	_attach_path_pit_visual(pit, kit, "MainBlockPathPit")


func _attach_path_pit_visual(pit: Vector2, kit: Dictionary, node_name: String) -> void:
	if pit.y <= pit.x + 2.0:
		return
	var lane_y := GROUND_Y - 0.05
	var curb_mat: Material = kit.get("curb", kit.get("road", null))
	var void_mat := _make_material(Color(0.02, 0.03, 0.05), Color(0.15, 0.45, 0.7), 0.8)
	# 坑底深渊（贴合路径，弯道也不会斜出）
	_attach_path_strip_segment(pit.x, pit.y, 7.2, lane_y - 2.4, void_mat, 2.0, 0.0)
	if curb_mat:
		_attach_path_strip_segment(pit.x - 0.8, pit.x + 0.6, 6.4, lane_y + 0.03, curb_mat, 1.2, 0.0)
		_attach_path_strip_segment(pit.y - 0.6, pit.y + 0.8, 6.4, lane_y + 0.03, curb_mat, 1.2, 0.0)
	# 沿路径的警示带（分段，避免大盒子穿帮）
	var warn_mat := _make_material(Color(0.95, 0.28, 0.1, 0.42), Color(1.0, 0.4, 0.08), 2.0)
	warn_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	warn_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_attach_path_strip_segment(pit.x, pit.y, 6.0, lane_y + 0.06, warn_mat, 2.0, 0.0)
	var mid := (pit.x + pit.y) * 0.5
	var sample := _sample_path(mid)
	var label := Label3D.new()
	label.name = node_name + "Label"
	label.text = "主路坍塌\n上侧墙或绕开"
	label.font_size = 56
	label.modulate = Color(1.0, 0.55, 0.25)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = (sample["pos"] as Vector3) + Vector3(0.0, lane_y + 2.4, 0.0)
	track_root.add_child(label)


func _attach_wall_run_mesh(zone: Dictionary, kit: Dictionary) -> void:
	var start := float(zone["start"])
	var entry := float(zone.get("entry_window", 10.0))
	var end_d := start + float(zone.get("length", 70.0))
	# 入口窗就开始铺墙，和可吸附区间对齐，避免先跳上却看不见墙
	var mesh_start := start - entry
	var side := _wall_zone_side(zone)
	var offset := float(zone.get("lateral_offset", WALL_DEFAULT_OFFSET))
	var step := 1.75
	var slices: Array[Dictionary] = []
	var d := mesh_start
	while d < end_d - 0.001:
		slices.append(_wall_run_slice(d, side, offset))
		d += step
	slices.append(_wall_run_slice(end_d, side, offset))
	if slices.size() < 2:
		return

	var wall_mat: Material = kit.get("road", null)
	if wall_mat == null:
		wall_mat = _make_material(Color(0.08, 0.22, 0.38), Color(0.2, 0.75, 1.0), 1.4)
	var edge_mat: Material = kit.get("curb", wall_mat)
	var line_mat: Material = kit.get("line", edge_mat)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(slices.size() - 1):
		var a: Dictionary = slices[i]
		var b: Dictionary = slices[i + 1]
		# 朝向主路的立面（跑墙面）
		_add_wall_quad(st, a["inner_bottom"], b["inner_bottom"], b["inner_top"], a["inner_top"])
		# 外侧
		_add_wall_quad(st, a["outer_bottom"], a["outer_top"], b["outer_top"], b["outer_bottom"])
		# 顶边
		_add_wall_quad(st, a["inner_top"], b["inner_top"], b["outer_top"], a["outer_top"])
	var mesh := st.commit()
	if mesh != null:
		var mi := MeshInstance3D.new()
		mi.name = "WallRunFace"
		mi.mesh = mesh
		mi.material_override = wall_mat
		_attach_road(mi)

	# 三列高度指示线
	for h in WALL_LANE_HEIGHTS:
		_attach_wall_lane_rail(mesh_start, end_d, side, offset, h, line_mat, step)


func _wall_run_slice(distance: float, side: float, offset: float) -> Dictionary:
	var sample := _sample_path(distance)
	var right: Vector3 = sample["right"]
	var base: Vector3 = sample["pos"] + right * (side * offset)
	var y0 := GROUND_Y - 0.12
	var y1 := y0 + WALL_FACE_HEIGHT
	var half_t := WALL_THICKNESS * 0.5
	# 内侧面更靠近主路
	var inner_lat_shift := -side * half_t
	var outer_lat_shift := side * half_t
	var ib := base + right * inner_lat_shift
	var ob := base + right * outer_lat_shift
	ib.y = y0
	ob.y = y0
	var it := ib + Vector3(0.0, y1 - y0, 0.0)
	var ot := ob + Vector3(0.0, y1 - y0, 0.0)
	return {
		"inner_bottom": ib,
		"inner_top": it,
		"outer_bottom": ob,
		"outer_top": ot,
	}


func _add_wall_quad(st: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3) -> void:
	var n := (v1 - v0).cross(v3 - v0)
	if n.length_squared() < 0.0001:
		n = Vector3.UP
	else:
		n = n.normalized()
	st.set_normal(n)
	st.set_uv(Vector2(0.0, 0.0))
	st.add_vertex(v0)
	st.set_uv(Vector2(1.0, 0.0))
	st.add_vertex(v1)
	st.set_uv(Vector2(1.0, 1.0))
	st.add_vertex(v2)
	st.set_uv(Vector2(0.0, 0.0))
	st.add_vertex(v0)
	st.set_uv(Vector2(1.0, 1.0))
	st.add_vertex(v2)
	st.set_uv(Vector2(0.0, 1.0))
	st.add_vertex(v3)


func _attach_wall_lane_rail(
	start_d: float,
	end_d: float,
	side: float,
	offset: float,
	height: float,
	material: Material,
	step: float
) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_w := 0.07
	var d := start_d
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	var has_prev := false
	while d <= end_d + 0.001:
		var sample := _sample_path(minf(d, end_d))
		var right: Vector3 = sample["right"]
		var inward: Vector3 = right * (-side)
		# 指示线贴在墙面内侧
		var center: Vector3 = sample["pos"] + right * _wall_inner_face_lateral(side, offset)
		center.y = height
		# 贴墙细轨：沿墙法线展开一点厚度
		var l := center + inward * 0.02 - inward * half_w
		var r := center + inward * 0.02 + inward * half_w
		if has_prev:
			_add_wall_quad(st, prev_l, prev_r, r, l)
		prev_l = l
		prev_r = r
		has_prev = true
		if d >= end_d:
			break
		d += step
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.name = "WallLaneRail"
	mi.mesh = mesh
	mi.material_override = material
	_attach_road(mi)


func _attach_road(node: Node) -> void:
	if _road_root != null:
		_road_root.add_child(node)
	else:
		track_root.add_child(node)


func _attach_path_strip(
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float = 2.0,
	lateral_bias: float = 0.0,
	skip_fork_gaps: bool = false
) -> void:
	if end_d <= start_d + 0.05 or material == null:
		return
	if skip_fork_gaps and LevelConfig != null:
		var cursor := start_d
		var gaps: Array = []
		for zone in _junction_zones():
			var gs := float(zone["distance"])
			var glen := float(zone.get("length", 70.0))
			var ge := gs + glen
			# 入口/出口保留主路与岔路重叠衔接；中段挖空形成不可跑空隙
			var keep := maxf(glen * 0.14, 12.0)
			var overlap := 4.0
			var cut_s := gs + keep - overlap
			var cut_e := ge - keep + overlap
			if cut_e > cut_s + 8.0:
				gaps.append(Vector2(cut_s, cut_e))
		# 侧墙段主路挖坍塌坑
		for zone in _side_runway_zones():
			var pit: Vector2 = _side_runway_pit_range(zone)
			if pit.y > pit.x + 4.0:
				gaps.append(pit)
		# main_block 封堵带也挖开主路，避免「看不见坑却判坠入」
		for gap2 in _main_block_road_gaps():
			if gap2.y > gap2.x + 2.0:
				gaps.append(gap2)
		gaps.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
		for gap in gaps:
			var gs: float = gap.x
			var ge: float = gap.y
			if ge <= cursor or gs >= end_d:
				continue
			if cursor < gs:
				_attach_path_strip_segment(cursor, minf(gs, end_d), half_width, y, material, step, lateral_bias)
			cursor = maxf(cursor, ge)
		if cursor < end_d:
			_attach_path_strip_segment(cursor, end_d, half_width, y, material, step, lateral_bias)
		return
	_attach_path_strip_segment(start_d, end_d, half_width, y, material, step, lateral_bias)


func _attach_path_strip_segment(
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	lateral_bias: float
) -> void:
	if end_d <= start_d + 0.05:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start_d
	while d < end_d - 0.001:
		pts.append(_path_strip_point(d, half_width, y, lateral_bias))
		d += step
	pts.append(_path_strip_point(end_d, half_width, y, lateral_bias))
	if pts.size() < 2:
		return
	var uv_scale := 0.14 if _road_style_id == "holographic" else (0.2 if _road_style_id == "energy_neon" else (0.11 if _road_style_id == "coarse_desert" else 0.08))
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		var L0: Vector3 = a["L"]
		var R0: Vector3 = a["R"]
		var L1: Vector3 = b["L"]
		var R1: Vector3 = b["R"]
		# 两三角拼成四边形，UV.x=0/1 表示路宽左右
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(L0)
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(R0)
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(R1)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(L0)
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(R1)
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(L1)
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)


func _path_strip_point(distance: float, half_width: float, y: float, lateral_bias: float) -> Dictionary:
	var sample := _sample_path(distance)
	var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral_bias
	var right: Vector3 = sample["right"]
	var L: Vector3 = origin - right * half_width
	var R: Vector3 = origin + right * half_width
	L.y = y
	R.y = y
	return {"L": L, "R": R, "d": distance}


func _make_road_style_kit(style_id: String) -> Dictionary:
	var theme: Dictionary = LevelConfig.get_theme()
	match style_id:
		"holographic":
			return {
				"road": _make_holographic_road_material(),
				"shoulder": _make_material(Color(0.02, 0.05, 0.08), Color(0.1, 0.4, 0.5), 0.2),
				"curb": _make_material(Color(0.08, 0.04, 0.14), Color(0.75, 0.35, 0.95), 1.6),
				"line": _make_material(Color(0.06, 0.14, 0.18), Color(0.45, 0.92, 1.0), 1.4),
				"post": _make_material(Color(0.03, 0.05, 0.08), Color(0.35, 0.7, 0.85), 0.5),
				"island": _make_material(Color(0.01, 0.03, 0.06), Color(0.06, 0.28, 0.38), 0.25),
			}
		"alien_energy":
			return {
				"road": _make_alien_energy_road_material(),
				"shoulder": _make_material(Color(0.04, 0.09, 0.14), Color(0.28, 0.62, 0.78), 0.28),
				"curb": _make_material(Color(0.06, 0.14, 0.2), Color(0.5, 0.95, 1.0), 2.2),
				"line": _make_material(Color(0.1, 0.22, 0.3), Color(0.45, 0.95, 1.0), 2.4),
				"post": _make_material(Color(0.05, 0.1, 0.15), Color(0.4, 0.85, 1.0), 0.75),
				"island": _make_material(Color(0.03, 0.06, 0.1), Color(0.2, 0.48, 0.62), 0.18),
			}
		"energy_neon":
			return {
				"road": _make_energy_neon_road_material(),
				"shoulder": _make_material(Color(0.01, 0.03, 0.06), Color(0.1, 0.38, 0.52), 0.22),
				"curb": _make_material(Color(0.1, 0.04, 0.18), Color(0.78, 0.32, 0.98), 2.6),
				"line": _make_material(Color(0.08, 0.2, 0.28), Color(0.35, 0.98, 1.0), 3.2),
				"post": _make_material(Color(0.03, 0.05, 0.08), Color(0.35, 0.85, 1.0), 0.55),
				"island": _make_material(Color(0.008, 0.02, 0.04), Color(0.08, 0.32, 0.48), 0.2),
			}
		"rust_metal":
			return {
				"road": _make_material(Color(0.22, 0.16, 0.12), Color(0.55, 0.28, 0.1), 0.2),
				"shoulder": _make_material(Color(0.32, 0.2, 0.12), Color(0.7, 0.35, 0.12), 0.35),
				"curb": _make_material(Color(0.45, 0.26, 0.12), Color(0.95, 0.45, 0.15), 1.1),
				"line": _make_material(Color(0.95, 0.7, 0.25), Color(1.0, 0.7, 0.2), 1.8),
				"post": _make_material(Color(0.16, 0.12, 0.1), Color(0.85, 0.4, 0.15), 0.6),
				"island": _make_material(Color(0.28, 0.18, 0.12), Color(0.55, 0.3, 0.12), 0.15),
			}
		"void_crystal":
			return {
				"road": _make_material(Color(0.06, 0.05, 0.12), Color(0.45, 0.25, 1.0), 0.55),
				"shoulder": _make_material(Color(0.1, 0.08, 0.18), Color(0.55, 0.35, 1.0), 0.7),
				"curb": _make_material(Color(0.12, 0.1, 0.22), Color(0.7, 0.45, 1.0), 2.8),
				"line": _make_material(Color(0.75, 0.55, 1.0), Color(0.85, 0.65, 1.0), 2.6),
				"post": _make_material(Color(0.08, 0.06, 0.14), Color(0.4, 0.9, 1.0), 1.4),
				"island": _make_material(Color(0.07, 0.05, 0.12), Color(0.5, 0.3, 0.9), 0.25),
			}
		"planet":
			return {
				"road": _make_planet_road_material(),
				"shoulder": _make_material(Color(0.34, 0.24, 0.16), Color(0.42, 0.3, 0.18), 0.08),
				"curb": _make_material(Color(0.4, 0.3, 0.18), Color(0.72, 0.52, 0.26), 0.42),
				"line": _make_material(theme.get("lane_line", Color(1.0, 0.86, 0.42)), Color(1.0, 0.78, 0.28), 1.15),
				"post": _make_material(Color(0.18, 0.18, 0.16), Color(0.85, 0.62, 0.34), 0.35),
				"island": _make_material(Color(0.2, 0.14, 0.1), Color(0.32, 0.22, 0.14), 0.06),
			}
		"coarse_desert":
			return {
				"road": _make_coarse_desert_road_material(),
				"shoulder": _make_opaque_desert_surface_material(Color(0.5, 0.32, 0.17)),
				"curb": _make_opaque_desert_surface_material(Color(0.42, 0.27, 0.14)),
				"line": _make_opaque_desert_surface_material(Color(0.72, 0.56, 0.32), Color(0.85, 0.66, 0.36), 0.08),
				"post": _make_opaque_desert_surface_material(Color(0.34, 0.22, 0.13)),
				"island": _make_opaque_desert_surface_material(Color(0.46, 0.3, 0.15)),
			}
		_:
			# 星球默认：路面要能看见；路肩/托底降饱和，避免「悬空橙板」抢戏
			return {
				"road": _make_material(theme.get("road", Color(0.28, 0.26, 0.22)), Color(0.55, 0.48, 0.32), 0.12),
				"shoulder": _make_material(Color(0.28, 0.2, 0.14), Color(0.4, 0.28, 0.16), 0.06),
				"curb": _make_material(Color(0.42, 0.32, 0.18), Color(0.7, 0.5, 0.22), 0.35),
				"line": _make_material(theme.get("lane_line", Color(1.0, 0.86, 0.42)), Color(1.0, 0.78, 0.28), 1.2),
				"post": _make_material(Color(0.18, 0.18, 0.16), Color(0.85, 0.62, 0.34), 0.35),
				"island": _make_material(Color(0.24, 0.17, 0.12), Color(0.35, 0.22, 0.12), 0.04),
			}


func _make_opaque_road_base_material(style_id: String) -> StandardMaterial3D:
	match style_id:
		"alien_energy":
			return _make_material(Color(0.1, 0.16, 0.22), Color(0.22, 0.48, 0.58), 0.12)
		"energy_neon":
			return _make_material(Color(0.04, 0.06, 0.1), Color(0.08, 0.28, 0.38), 0.12)
		"planet":
			return _make_material(Color(0.2, 0.15, 0.11), Color(0.28, 0.2, 0.14), 0.05)
		"coarse_desert":
			return _make_opaque_desert_surface_material(Color(0.38, 0.24, 0.12))
		_:
			return _make_material(Color(0.015, 0.04, 0.08), Color(0.1, 0.38, 0.48), 0.18)


func _make_alien_energy_road_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = ROAD_ALIEN_ENERGY_SHADER
	mat.set_shader_parameter("base_color", Color(0.12, 0.2, 0.28))
	mat.set_shader_parameter("vein_color", Color(0.55, 0.92, 1.0))
	mat.set_shader_parameter("particle_color", Color(0.42, 0.98, 1.0))
	mat.set_shader_parameter("roughness_val", 0.34)
	mat.set_shader_parameter("metallic_val", 0.08)
	mat.set_shader_parameter("vein_energy", 2.35)
	mat.set_shader_parameter("particle_energy", 1.3)
	mat.set_shader_parameter("flow_speed", 0.55)
	mat.set_shader_parameter("detail_scale", 0.12)
	return mat


func _make_planet_road_material() -> StandardMaterial3D:
	# 星球默认：实心晶砂路面，贴地不透明，避免沙漠从下方「透出来」
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.36, 0.3)
	mat.roughness = 0.78
	mat.metallic = 0.06
	mat.emission_enabled = true
	mat.emission = Color(0.48, 0.38, 0.26)
	mat.emission_energy_multiplier = 0.15
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat


func _make_coarse_desert_road_material() -> StandardMaterial3D:
	# 实心沙石路面：与星球默认同样强制不透明，避免沙漠从下方透出
	var mat := StandardMaterial3D.new()
	var tex_path := "res://assets/maps/route_levels/runner_60s/textures/white_sandstone_blocks_02_diff_1k.jpg"
	if ResourceLoader.exists(tex_path):
		mat.albedo_texture = load(tex_path) as Texture2D
	mat.albedo_color = Color(0.78, 0.58, 0.36)
	mat.roughness = 0.94
	mat.metallic = 0.02
	mat.emission_enabled = false
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat


func _make_opaque_desert_surface_material(
	color: Color,
	emission: Color = Color.BLACK,
	emission_energy: float = 0.0
) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	mat.metallic = 0.02
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	if emission_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = emission_energy
	return mat


func _load_holographic_runway_texture(prefer_topdown: bool = true) -> Texture2D:
	# 路径 mesh 用俯视图贴图平铺；透视概念图仅作展示，直接平铺会采到大量黑边
	var tex_paths: Array[String] = []
	if prefer_topdown:
		tex_paths = [
			"res://assets/maps/route_levels/runner_60s/holographic_road_topdown.png",
			"res://assets/maps/route_levels/runner_60s/holographic_energy_runway.png",
		]
	else:
		tex_paths = [
			"res://assets/maps/route_levels/runner_60s/holographic_energy_runway.png",
			"res://assets/maps/route_levels/runner_60s/holographic_road_topdown.png",
		]
	for tex_path in tex_paths:
		if ResourceLoader.exists(tex_path):
			var tex := load(tex_path) as Texture2D
			if tex:
				return tex
	return null


func _make_holographic_road_material() -> StandardMaterial3D:
	# 全息能量轨：俯视图贴图平铺，青绿电路纹理 + 紫边由 curb/line 条带承担
	var mat := StandardMaterial3D.new()
	var tex := _load_holographic_runway_texture(true)
	if tex:
		mat.albedo_texture = tex
		mat.emission_texture = tex
	mat.albedo_color = Color(0.28, 0.68, 0.78)
	mat.emission_enabled = true
	mat.emission = Color(0.38, 0.92, 1.0)
	mat.emission_energy_multiplier = 2.2
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat


func _load_energy_neon_runway_texture() -> Texture2D:
	var tex_path := "res://assets/maps/route_levels/runner_60s/energy_neon_runway.png"
	if ResourceLoader.exists(tex_path):
		return load(tex_path) as Texture2D
	return null


func _make_energy_neon_road_material() -> StandardMaterial3D:
	# 能量霓虹：概念图底图（青裂纹 + 青/橙边轨），unshaded 强发光保证 void 里可见
	var mat := StandardMaterial3D.new()
	var tex := _load_energy_neon_runway_texture()
	if tex:
		mat.albedo_texture = tex
		mat.emission_texture = tex
	mat.albedo_color = Color(0.42, 0.82, 0.92)
	mat.emission_enabled = true
	mat.emission = Color(0.32, 0.95, 1.0)
	mat.emission_energy_multiplier = 3.2
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat


func _apply_road_style_environment() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	match _road_style_id:
		"holographic", "energy_neon", "alien_energy":
			env.glow_enabled = true
			env.glow_intensity = 0.55 if _road_style_id != "alien_energy" else 0.52
			env.glow_strength = 1.1 if _road_style_id != "alien_energy" else 1.05
			env.glow_bloom = 0.22 if _road_style_id != "energy_neon" else 0.28
			env.glow_hdr_threshold = 0.58 if _road_style_id != "alien_energy" else 0.62
			env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
			env.tonemap_exposure = maxf(env.tonemap_exposure, 1.12)
		"void_crystal":
			env.glow_enabled = true
			env.glow_intensity = 0.55
			env.glow_strength = 1.05
			env.glow_bloom = 0.3
			env.glow_hdr_threshold = 0.65
			env.tonemap_exposure = maxf(env.tonemap_exposure, 1.1)
		"coarse_desert":
			env.glow_enabled = false
			env.tonemap_exposure = maxf(env.tonemap_exposure, 1.02)


func _boost_runner_lights(sun_color: Color, sun_energy: float, rim_energy: float) -> void:
	var sun := get_node_or_null("RunnerSun") as DirectionalLight3D
	if sun:
		sun.light_color = sun_color
		sun.light_energy = sun_energy
	if player == null:
		return
	var key := player.get_node_or_null("PlayerKeyLight") as OmniLight3D
	if key:
		key.light_color = sun_color.lerp(Color.WHITE, 0.25)
		key.light_energy = maxf(1.6, sun_energy * 0.65)
	var rim := player.get_node_or_null("PlayerRunwayRim") as OmniLight3D
	if rim:
		rim.light_energy = maxf(rim_energy, 1.0)


func _is_in_fork_main_gap(distance: float) -> bool:
	for zone in _junction_zones():
		var start := float(zone["distance"])
		var length := float(zone.get("length", 70.0))
		if distance < start or distance > start + length:
			continue
		var t := (distance - start) / maxf(length, 0.001)
		# 中段断开主路，两端仍衔接
		if t > 0.12 and t < 0.88:
			return true
	return false


func _fork_envelope(t: float) -> float:
	# 0→1→0，中段最开
	return sin(clampf(t, 0.0, 1.0) * PI)


func _build_path_road_slice(
	distance: float,
	segment_len: float,
	lateral_bias: float,
	road_material: Material,
	shoulder_material: Material,
	curb_material: Material,
	line_material: Material,
	post_material: Material,
	lane_y: float
) -> void:
	var sample := _sample_path(distance)
	var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral_bias
	var yaw := float(sample["yaw"])
	# PlaneMesh 顶面即车道面，不再用厚盒子端面露缝
	var center := origin + Vector3(0.0, lane_y, 0.0)

	var road := MeshInstance3D.new()
	var thin_energy := _road_style_id in ["alien_energy", "holographic", "energy_neon"]
	var neon_edge := _road_style_id in ["energy_neon", "holographic"]
	var road_w := 12.6 if _road_style_id == "energy_neon" else (12.0 if _road_style_id == "holographic" else (11.8 if _road_style_id == "alien_energy" else 12.6))
	var road_mesh := PlaneMesh.new()
	road_mesh.size = Vector2(road_w, segment_len)
	road_mesh.orientation = PlaneMesh.FACE_Y
	road_mesh.material = road_material
	road.mesh = road_mesh
	road.position = center
	road.rotation.y = yaw
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(road)

	for side in [-1.0, 1.0]:
		# 沙色贴边肩：填满紫边外侧与地形之间的空隙
		var shoulder := MeshInstance3D.new()
		var shoulder_mesh := PlaneMesh.new()
		shoulder_mesh.size = Vector2(3.2 if thin_energy else 1.8, segment_len)
		shoulder_mesh.orientation = PlaneMesh.FACE_Y
		shoulder_mesh.material = shoulder_material
		shoulder.mesh = shoulder_mesh
		var shoulder_x := 7.7 if thin_energy else 7.25
		shoulder.position = center + (sample["right"] as Vector3) * (shoulder_x * side)
		shoulder.position.y = lane_y - 0.008
		shoulder.rotation.y = yaw
		shoulder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(shoulder)

		var curb := MeshInstance3D.new()
		var curb_mesh := BoxMesh.new()
		if _road_style_id == "alien_energy":
			curb_mesh.size = Vector3(0.08, 0.03, segment_len)
		elif neon_edge:
			curb_mesh.size = Vector3(0.12, 0.04, segment_len)
		else:
			curb_mesh.size = Vector3(0.16, 0.12, segment_len)
		curb_mesh.material = curb_material
		curb.mesh = curb_mesh
		var curb_x := road_w * 0.5 - 0.02
		if _road_style_id == "energy_neon":
			curb_x = 6.35
		elif not thin_energy and _road_style_id != "holographic":
			curb_x = 6.45
		curb.position = center + (sample["right"] as Vector3) * (curb_x * side)
		curb.position.y = lane_y + (0.02 if thin_energy else 0.06)
		curb.rotation.y = yaw
		curb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(curb)
		if neon_edge:
			var curb2 := MeshInstance3D.new()
			var curb2_mesh := BoxMesh.new()
			curb2_mesh.size = Vector3(0.06, 0.025, segment_len)
			curb2_mesh.material = curb_material
			curb2.mesh = curb2_mesh
			curb2.position = center + (sample["right"] as Vector3) * ((curb_x + 0.14) * side)
			curb2.position.y = lane_y + 0.015
			curb2.rotation.y = yaw
			curb2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(curb2)

	# 中线短划（全息贴图已含能量核，不再叠实体虚线）
	if line_material and not thin_energy and int(distance / segment_len) % 2 == 0:
		var dash := MeshInstance3D.new()
		var dash_mesh := BoxMesh.new()
		dash_mesh.size = Vector3(0.18, 0.04, 2.4)
		dash_mesh.material = line_material
		dash.mesh = dash_mesh
		dash.position = center + Vector3(0.0, 0.04, 0.0)
		dash.rotation.y = yaw
		_attach_road(dash)

	if post_material and not thin_energy and int(distance / segment_len) % 3 == 0:
		for side in [-1.0, 1.0]:
			var post := MeshInstance3D.new()
			var post_mesh := BoxMesh.new()
			post_mesh.size = Vector3(0.18, 0.7, 0.18)
			post_mesh.material = post_material
			post.mesh = post_mesh
			post.position = center + (sample["right"] as Vector3) * (7.9 * side)
			post.position.y = GROUND_Y + 0.34
			post.rotation.y = yaw
			_attach_road(post)


func _build_y_fork_branch_roads(kit: Dictionary, lane_y: float) -> void:
	# 主路径已沿左岔；补画右岔实心路面
	var segments: Array = _active_track_segments()
	for entry in ObstacleLayout.segment_start_poses(segments, 2.0):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = entry.get("segment", {})
		if not ObstacleLayout.is_y_fork_segment(seg):
			continue
		var poly: Array = ObstacleLayout.bake_y_fork_branch_polyline(
			entry.get("pos", Vector3.ZERO),
			float(entry.get("yaw", 0.0)),
			float(seg.get("branch_length", 55.0)),
			float(seg.get("angle", deg_to_rad(45.0))),
			-1.0,
			2.0
		)
		var road_half := 6.0 if _road_style_id == "holographic" else 6.3
		_attach_polyline_strip(poly, road_half + 1.4, lane_y - 0.012, kit.get("island", kit["shoulder"]))
		_attach_polyline_strip(poly, road_half, lane_y, kit["road"])
		if kit.get("line"):
			_attach_polyline_strip(poly, 0.04, lane_y + 0.014, kit["line"], -LANE_WIDTH)
			_attach_polyline_strip(poly, 0.04, lane_y + 0.014, kit["line"], LANE_WIDTH)
		if kit.get("curb"):
			_attach_polyline_strip(poly, 0.07, lane_y + 0.012, kit["curb"], -(road_half - 0.02))
			_attach_polyline_strip(poly, 0.07, lane_y + 0.012, kit["curb"], road_half - 0.02)


func _attach_polyline_strip(
	samples: Array,
	half_width: float,
	y: float,
	material: Material,
	lateral_bias: float = 0.0
) -> void:
	if material == null or samples.size() < 2:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	for i in samples.size():
		var s: Dictionary = samples[i]
		var pos: Vector3 = s.get("pos", Vector3.ZERO)
		var yaw := float(s.get("yaw", 0.0))
		var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
		var right := forward.cross(Vector3.UP).normalized()
		var origin := pos + right * lateral_bias
		var L := origin - right * half_width
		var R := origin + right * half_width
		L.y = y
		R.y = y
		pts.append({"L": L, "R": R, "d": float(s.get("d", float(i) * 2.0))})
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		st.set_normal(Vector3.UP)
		st.add_vertex(a["L"])
		st.add_vertex(a["R"])
		st.add_vertex(b["R"])
		st.add_vertex(a["L"])
		st.add_vertex(b["R"])
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	_attach_road(mi)


func _build_fork_branch_roads(
	zone: Dictionary,
	road_material: Material,
	shoulder_material: Material,
	curb_material: Material,
	line_material: Material,
	island_material: Material,
	lane_y: float
) -> void:
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	# 与主路同宽：左右岔各含完整左中右三道
	var branch_half := 6.3 if _road_style_id == "energy_neon" else (6.0 if _road_style_id == "holographic" else 6.3)
	var lead := 16.0
	# 不铺中间托底：中间故意留空，仅左右岔有路面
	for side_f in [-1.0, 1.0]:
		var side: float = float(side_f)
		_attach_fork_branch_strip(start, length, spread, side, branch_half + 2.6, lane_y - 0.012, shoulder_material, 1.5, 0.0, lead)
		_attach_fork_branch_strip(start, length, spread, side, branch_half, lane_y + 0.01, road_material, 1.5, 0.0, lead)
		# 岔内三道分隔线
		if line_material:
			_attach_fork_branch_strip(start, length, spread, side, 0.045, lane_y + 0.016, line_material, 1.5, LANE_WIDTH, lead)
			_attach_fork_branch_strip(start, length, spread, side, 0.045, lane_y + 0.016, line_material, 1.5, -LANE_WIDTH, lead)
		if _road_style_id == "holographic":
			_attach_fork_branch_strip(start, length, spread, side, 0.07, lane_y + 0.02, curb_material, 1.5, branch_half - 0.05, lead)
			_attach_fork_branch_strip(start, length, spread, side, 0.07, lane_y + 0.02, curb_material, 1.5, -(branch_half - 0.05), lead)
			_attach_fork_branch_strip(start, length, spread, side, 0.055, lane_y + 0.018, line_material, 1.5, branch_half + 0.12, lead)
			_attach_fork_branch_strip(start, length, spread, side, 0.055, lane_y + 0.018, line_material, 1.5, -(branch_half + 0.12), lead)
	_build_fork_entry_wedge(zone, curb_material, lane_y)
	# 入口/出口缝桥：盖住主路切断处
	var keep := maxf(length * 0.14, 12.0)
	var bridge_half := branch_half + 0.4
	_attach_path_strip_segment(start - 3.0, start + keep + 3.0, bridge_half, lane_y + 0.006, road_material, 1.4, 0.0)
	_attach_path_strip_segment(start + length - keep - 3.0, start + length + 3.0, bridge_half, lane_y + 0.006, road_material, 1.4, 0.0)


func _attach_fork_center_island(zone: Dictionary, material: Material, y: float) -> void:
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	var branch_half := 6.3 if _road_style_id == "energy_neon" else (6.0 if _road_style_id == "holographic" else 6.3)
	var step := 2.0
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start
	while d <= start + length + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		# 两岔之间的分隔岛：随 Y 形张开/收拢，全程不断带
		var gap_half := maxf(spread * envelope - branch_half * 1.05, 0.35)
		var half_w := maxf(0.45, gap_half * 0.48)
		pts.append(_path_strip_point(d, half_w, y, 0.0))
		d += step
	if pts.size() < 2:
		return
	var uv_scale := 0.08
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(a["R"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)


func _attach_fork_branch_strip(
	start: float,
	length: float,
	spread: float,
	side: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	extra_lateral: float = 0.0,
	lead: float = 0.0
) -> void:
	if material == null:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start - lead
	var end_d := start + length + lead * 0.35
	while d <= end_d + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		var lateral := side * spread * envelope + extra_lateral * side
		var sample := _sample_path(d)
		var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral
		# 近汇合处跟主路 right 对齐，张开后才逐渐偏航，避免入口锯齿缝
		var t2 := clampf(t + step / maxf(length, 0.001), 0.0, 1.0)
		var offset := spread * envelope
		var offset2 := spread * _fork_envelope(t2)
		var d_lat := ((offset2 - offset) * side) / maxf(step, 0.001)
		var path_right: Vector3 = sample["right"]
		var branch_yaw := float(sample["yaw"]) + atan(d_lat) * 0.85
		var yaw_right := Vector3(cos(branch_yaw), 0.0, -sin(branch_yaw))
		var blend := smoothstep(0.0, 0.22, envelope)
		var branch_right: Vector3 = path_right.lerp(yaw_right, blend)
		if branch_right.length_squared() > 0.0001:
			branch_right = branch_right.normalized()
		else:
			branch_right = path_right
		var L: Vector3 = origin - branch_right * half_width
		var R: Vector3 = origin + branch_right * half_width
		L.y = y
		R.y = y
		pts.append({"L": L, "R": R, "d": d})
		d += step
	if pts.size() < 2:
		return
	var uv_scale := 0.08
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(a["R"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)


func _build_fork_entry_wedge(zone: Dictionary, curb_material: Material, lane_y: float) -> void:
	# 入口导向条：与跑道材质一致，替代突兀的绿/橙方块
	var start := float(zone["distance"])
	var spread := float(zone.get("spread", 22.0))
	var sample := _sample_path(start + 2.0)
	for side_f in [-1.0, 1.0]:
		var side: float = float(side_f)
		var guide := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.12, 0.03, 6.5)
		mesh.material = curb_material
		guide.mesh = mesh
		guide.position = (sample["pos"] as Vector3) + (sample["right"] as Vector3) * (2.8 * side)
		guide.position.y = lane_y + 0.025
		guide.rotation.y = float(sample["yaw"]) + (-0.22 if side < 0.0 else 0.22)
		_attach_road(guide)


func _attach_fork_underlay(zone: Dictionary, material: Material, y: float) -> void:
	# 岔路区暗色托底，填满主路挖空后的空隙
	if material == null:
		return
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	var branch_half := 6.3 if _road_style_id == "energy_neon" else (6.0 if _road_style_id == "holographic" else 6.3)
	var lead := 14.0
	var step := 1.75
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start - lead
	while d <= start + length + lead * 0.35 + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		var outer := spread * envelope + branch_half + 3.2
		outer = maxf(outer, 9.5)
		pts.append(_path_strip_point(d, outer, y, 0.0))
		d += step
	if pts.size() < 2:
		return
	var uv_scale := 0.06
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(a["R"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)


func _build_start_pad(
	road_material: Material,
	shoulder_material: Material,
	curb_material: Material,
	line_material: Material,
	post_material: Material,
	lane_y: float
) -> void:
	var start_center_z := START_PAD_LENGTH * 0.5
	var start_w := 12.6 if _road_style_id == "energy_neon" else (12.0 if _road_style_id == "holographic" else (13.0 if _road_style_id == "coarse_desert" else 12.6))
	var foundation := MeshInstance3D.new()
	foundation.name = "StartSandFoundation"
	var foundation_mesh := BoxMesh.new()
	var theme: Dictionary = LevelConfig.get_theme() if LevelConfig != null and LevelConfig.has_method("get_theme") else {}
	var foundation_mat := (
		_make_material(Color(0.01, 0.03, 0.06), Color(0.08, 0.32, 0.42), 0.22)
		if _road_style_id in ["holographic", "energy_neon"]
		else (
			_make_material(Color(0.02, 0.04, 0.07), Color(0.15, 0.45, 0.6), 0.15)
			if _road_style_id == "alien_energy"
			else (
				_make_opaque_desert_surface_material(Color(0.46, 0.3, 0.15))
				if _road_style_id == "coarse_desert"
				else _make_material(Color(0.62, 0.4, 0.2), Color(0.85, 0.5, 0.2), 0.12)
			)
		)
	)
	foundation_mesh.material = foundation_mat
	foundation.mesh = foundation_mesh
	if _road_style_id in ["holographic", "energy_neon"]:
		foundation_mesh.size = Vector3(start_w + 0.4, 0.04, START_PAD_LENGTH + 1.5)
		foundation.position = Vector3(0.0, lane_y - 0.03, start_center_z)
	elif _road_style_id == "alien_energy":
		foundation_mesh.size = Vector3(start_w + 2.0, 0.08, START_PAD_LENGTH + 2.0)
		foundation.position = Vector3(0.0, lane_y - 0.06, start_center_z)
	else:
		foundation_mesh.size = Vector3(58.0, 0.36, START_PAD_LENGTH + 8.0)
		foundation.position = Vector3(0.0, lane_y - 0.18, start_center_z)
	_attach_road(foundation)

	if _road_style_id in ["alien_energy", "planet", "coarse_desert"]:
		var opaque_apron := MeshInstance3D.new()
		opaque_apron.name = "StartRoadOpaqueBase"
		var opaque_mesh := PlaneMesh.new()
		opaque_mesh.size = Vector2(start_w, START_PAD_LENGTH + 2.0)
		opaque_mesh.orientation = PlaneMesh.FACE_Y
		opaque_mesh.material = _make_opaque_road_base_material(_road_style_id)
		opaque_apron.mesh = opaque_mesh
		opaque_apron.position = Vector3(0.0, lane_y - 0.02, start_center_z)
		opaque_apron.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(opaque_apron)

	var road := MeshInstance3D.new()
	road.name = "StartRoadApron"
	var road_mesh := PlaneMesh.new()
	road_mesh.size = Vector2(start_w, START_PAD_LENGTH + 2.0)
	road_mesh.orientation = PlaneMesh.FACE_Y
	road_mesh.material = road_material
	road.mesh = road_mesh
	road.position = Vector3(0.0, lane_y, start_center_z)
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(road)

	if _road_style_id not in ["holographic", "energy_neon"]:
		# 起点两侧沙肩，与路径托底衔接
		for x in [-7.8, 7.8]:
			var shoulder := MeshInstance3D.new()
			var shoulder_mesh := PlaneMesh.new()
			shoulder_mesh.size = Vector2(3.4, START_PAD_LENGTH + 2.0)
			shoulder_mesh.orientation = PlaneMesh.FACE_Y
			shoulder_mesh.material = shoulder_material
			shoulder.mesh = shoulder_mesh
			shoulder.position = Vector3(x, lane_y - 0.008, start_center_z)
			shoulder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(shoulder)
	else:
		var road_half := 6.4 if _road_style_id == "energy_neon" else 6.0
		var shoulder_half := 1.6
		var shoulder_x := road_half + shoulder_half
		for x in [-shoulder_x, shoulder_x]:
			var shoulder := MeshInstance3D.new()
			var shoulder_mesh := PlaneMesh.new()
			shoulder_mesh.size = Vector2(shoulder_half * 2.0, START_PAD_LENGTH + 2.0)
			shoulder_mesh.orientation = PlaneMesh.FACE_Y
			shoulder_mesh.material = shoulder_material
			shoulder.mesh = shoulder_mesh
			shoulder.position = Vector3(x, lane_y - 0.008, start_center_z)
			shoulder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(shoulder)

	var curb_xs: Array = [-start_w * 0.5, start_w * 0.5]
	if _road_style_id == "holographic":
		for x in curb_xs:
			var curb := MeshInstance3D.new()
			var curb_mesh := BoxMesh.new()
			curb_mesh.size = Vector3(0.12, 0.04, START_PAD_LENGTH + 2.0)
			curb_mesh.material = curb_material
			curb.mesh = curb_mesh
			curb.position = Vector3(x, lane_y + 0.02, start_center_z)
			curb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(curb)

	if _road_style_id != "holographic" and _road_style_id != "alien_energy":
		_build_lane_dashes_segment(start_center_z, line_material)
		_build_side_posts_segment(start_center_z, post_material)


func _build_lane_dashes_segment(seg_z: float, light_material: Material) -> void:
	for x in [-2.0, 2.0]:
		var line := MeshInstance3D.new()
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(0.08, 0.045, 48.5)
		line_mesh.material = light_material
		line.mesh = line_mesh
		line.position = Vector3(x, GROUND_Y + 0.015, seg_z)
		_attach_road(line)

	for step in 4:
		var dash := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.34, 0.05, 1.7)
		mesh.material = light_material
		dash.mesh = mesh
		dash.position = Vector3(0.0, GROUND_Y + 0.025, seg_z + 10.0 - step * 12.0)
		_attach_road(dash)


func _build_side_posts_segment(seg_z: float, post_material: Material) -> void:
	for x in [-7.65, 7.65]:
		for step in 4:
			var post := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.07
			mesh.bottom_radius = 0.07
			mesh.height = 0.82
			mesh.radial_segments = 10
			mesh.material = post_material
			post.mesh = mesh
			post.position = Vector3(x, GROUND_Y + 0.34, seg_z + 12.0 - step * 12.0)
			_attach_road(post)


func _build_planet_surroundings(theme: Dictionary) -> void:
	match _background_style_id:
		"void_dark", "starfield":
			_build_void_surroundings_for_energy_road()
		"industrial_ruin":
			_build_industrial_surroundings(theme)
		"savanna":
			_build_savanna_surroundings(theme)
		_:
			_build_desert_surroundings(theme)
	if _background_style_id in ["desert_crystal", "industrial_ruin", "savanna"]:
		_build_path_side_dressing(theme)


func _build_void_surroundings_for_energy_road() -> void:
	# 极暗地面托底：顶面贴近路肩下沿，避免两侧露出垂直缝
	var mat := _make_material(Color(0.015, 0.02, 0.035), Color(0.05, 0.12, 0.2), 0.05)
	var lane_y := GROUND_Y - 0.05
	var pad_y := lane_y - 0.055
	var d := 0.0
	var track_end := maxf(_path_length, _track_length) + 40.0
	while d < track_end:
		var sample := _sample_path(d)
		var pad := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(56.0, 0.05, 20.0)
		mesh.material = mat
		pad.mesh = mesh
		pad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pad.position = (sample["pos"] as Vector3) + Vector3(0.0, pad_y, 0.0)
		pad.rotation.y = float(sample["yaw"])
		track_root.add_child(pad)
		d += 18.0


func _surroundings_foundation_half() -> float:
	match _road_style_id:
		"coarse_desert":
			return 16.0
		"planet":
			return 14.0
		_:
			return 21.0


func _spawn_alien_energy_edge_particles() -> void:
	_road_edge_particles.clear()
	if player == null:
		return
	for side in [-1.0, 1.0]:
		var fx := GPUParticles3D.new()
		fx.name = "AlienEdgeDust_%s" % ("L" if side < 0.0 else "R")
		fx.amount = 48
		fx.lifetime = 1.4
		fx.explosiveness = 0.0
		fx.randomness = 0.35
		fx.visibility_aabb = AABB(Vector3(-8, -2, -20), Vector3(16, 6, 40))
		var mesh := SphereMesh.new()
		mesh.radius = 0.03
		mesh.height = 0.06
		mesh.radial_segments = 6
		mesh.rings = 3
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.45, 0.92, 1.0, 0.65)
		mat.emission_enabled = true
		mat.emission = Color(0.35, 0.9, 1.0)
		mat.emission_energy_multiplier = 1.2
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh.material = mat
		fx.draw_pass_1 = mesh
		var proc := ParticleProcessMaterial.new()
		proc.direction = Vector3(0, 0.15, -1)
		proc.spread = 12.0
		proc.initial_velocity_min = 0.4
		proc.initial_velocity_max = 1.6
		proc.gravity = Vector3(0, 0.05, 0)
		proc.scale_min = 0.35
		proc.scale_max = 1.0
		proc.color = Color(0.55, 0.95, 1.0, 0.7)
		fx.process_material = proc
		fx.position = Vector3(side * 5.9, 0.15, -2.0)
		player.add_child(fx)
		fx.emitting = true
		_road_edge_particles.append(fx)


func _spawn_holographic_edge_particles() -> void:
	_spawn_alien_energy_edge_particles()


func _build_desert_surroundings(theme: Dictionary = {}) -> void:
	# 环境沙地：能看清沙漠，但不发霓虹橙光
	var sand_material := _make_material(Color(0.58, 0.38, 0.22), Color(0.7, 0.45, 0.22), 0.1)
	var cracked_material := _make_material(Color(0.36, 0.27, 0.18), Color(0.2, 0.7, 0.85), 0.35)
	var silhouette_material := _make_material(Color(0.12, 0.09, 0.07), Color(0.45, 0.25, 0.12), 0.2)
	var crystal_material := _make_crystal_material(theme.get("crystal", Color(0.13, 0.62, 1.0)), Color(0.08, 0.9, 1.0))
	var segment_len := 96.0
	var segment_count := int(ceil((_track_length + 120.0) / segment_len))
	var sand_half_w := 23.0
	var sand_center := _surroundings_foundation_half() + sand_half_w
	var sand_y := GROUND_Y - 0.05 - 0.062

	for segment_index in segment_count:
		# 沿路径铺两侧沙地，不再假设赛道永远沿 -Z
		var d := float(segment_index) * segment_len + segment_len * 0.5
		var sample := _sample_path(minf(d, maxf(_path_length, _track_length)))
		var origin: Vector3 = sample["pos"]
		var right: Vector3 = sample["right"]
		var yaw: float = float(sample["yaw"])
		for side in [-1.0, 1.0]:
			var sand := MeshInstance3D.new()
			var sand_mesh := BoxMesh.new()
			sand_mesh.size = Vector3(sand_half_w * 2.0, 0.08, segment_len + 0.5)
			sand_mesh.material = sand_material
			sand.mesh = sand_mesh
			sand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			sand.position = origin + right * (side * sand_center)
			sand.position.y = sand_y
			sand.rotation.y = yaw
			track_root.add_child(sand)

		var seg_z := float(origin.z)
		if segment_index % 2 == 0:
			_add_background_ruins(seg_z, -22.0, silhouette_material)
		else:
			_add_background_crystals(seg_z, 23.0, crystal_material)

		if segment_index % 3 == 1:
			_add_cracked_glass_patch(seg_z, -13.5, cracked_material)
			_add_cracked_glass_patch(seg_z - 28.0, 14.0, cracked_material)


func _build_path_side_dressing(theme: Dictionary) -> void:
	# 沿路径刷两侧低模道具 + 沙带，贴近地铁跑酷“路旁塞满”观感；不参与碰撞。
	_side_dressing_root = Node3D.new()
	_side_dressing_root.name = "PathSideDressing"
	track_root.add_child(_side_dressing_root)

	var sand_material := _make_material(Color(0.55, 0.36, 0.2), Color(0.65, 0.42, 0.2), 0.08)
	var rng := RandomNumberGenerator.new()
	var planet_key := "runner"
	if LevelConfig.has_method("get_planet_id"):
		planet_key = String(LevelConfig.get_planet_id())
	rng.seed = hash(planet_key + "_side_dressing")

	var track_end := maxf(_path_length, _track_length) + 48.0
	var d := 12.0
	while d < track_end:
		var fork_push := 12.0 if _is_in_fork_main_gap(d) else 0.0
		for side_f in [-1.0, 1.0]:
			var side: float = float(side_f)
			var lateral: float = side * (rng.randf_range(17.5, 24.0) + fork_push)
			_place_path_sand_ribbon(d, lateral, rng.randf_range(10.0, 16.0), 18.0, sand_material)
		d += 28.0

	if not _side_prop_paths.is_empty():
		d = 45.0
		var prop_i := 0
		while d < track_end - 40.0:
			var side: float = 1.0 if prop_i % 2 == 0 else -1.0
			var fork_push := 14.0 if _is_in_fork_main_gap(d) else 0.0
			var lateral: float = side * (rng.randf_range(10.2, 14.8) + fork_push)
			_spawn_path_side_prop(
				d,
				lateral,
				_side_prop_paths,
				rng.randf_range(1.55, 2.85),
				rng
			)
			# 偶尔对侧再放一件，形成“成簇”感
			if prop_i % 4 == 1:
				_spawn_path_side_prop(
					d + rng.randf_range(2.0, 5.0),
					-lateral * rng.randf_range(0.92, 1.08),
					_side_prop_paths,
					rng.randf_range(1.2, 2.2),
					rng
				)
			d += rng.randf_range(22.0, 32.0)
			prop_i += 1

		# 中景稍远一排
		d = 50.0
		prop_i = 0
		while d < track_end - 60.0:
			var side2: float = -1.0 if prop_i % 2 == 0 else 1.0
			var fork_push2 := 16.0 if _is_in_fork_main_gap(d) else 0.0
			_spawn_path_side_prop(
				d,
				side2 * (rng.randf_range(16.5, 22.0) + fork_push2),
				_side_prop_paths,
				rng.randf_range(2.2, 3.6),
				rng
			)
			d += rng.randf_range(38.0, 52.0)
			prop_i += 1

	if not _landmark_prop_paths.is_empty():
		d = 90.0
		var landmark_i := 0
		while d < track_end - 80.0:
			var side3: float = 1.0 if landmark_i % 2 == 0 else -1.0
			_spawn_path_side_prop(
				d,
				side3 * rng.randf_range(28.0, 38.0),
				_landmark_prop_paths,
				rng.randf_range(5.5, 9.0),
				rng
			)
			d += rng.randf_range(130.0, 190.0)
			landmark_i += 1


func _place_path_sand_ribbon(
	distance: float,
	lateral: float,
	width: float,
	length: float,
	material: Material
) -> void:
	var sample := _sample_path(distance)
	var sand := MeshInstance3D.new()
	var sand_mesh := BoxMesh.new()
	sand_mesh.size = Vector3(width, 0.07, length)
	sand_mesh.material = material
	sand.mesh = sand_mesh
	sand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sand.position = (sample["pos"] as Vector3) + (sample["right"] as Vector3) * lateral
	sand.position.y = GROUND_Y - 0.05 - 0.062
	sand.rotation.y = float(sample["yaw"])
	_side_dressing_root.add_child(sand)


func _spawn_path_side_prop(
	distance: float,
	lateral: float,
	paths: Array[String],
	target_height: float,
	rng: RandomNumberGenerator
) -> void:
	if paths.is_empty():
		return
	var asset_path := paths[rng.randi() % paths.size()]
	var scene := _load_runner_scene(asset_path, false)
	var root := Node3D.new()
	root.name = "SideProp_%d" % _side_dressing_root.get_child_count()
	_side_dressing_root.add_child(root)
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	root.position = placed["pos"]
	root.rotation.y = float(placed["yaw"]) + rng.randf_range(-0.55, 0.55)
	_add_scaled_model_visual(
		root,
		scene,
		"SidePropModel",
		target_height,
		rng.randf_range(-25.0, 25.0),
		Vector3.ZERO,
		clampf(target_height * 1.75, 2.5, 8.0)
	)
	_disable_mesh_shadows(root)


func _disable_mesh_shadows(root: Node3D) -> void:
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		(node as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _build_industrial_surroundings(theme: Dictionary) -> void:
	var sand_material := _make_material(theme.get("sand", Color(0.38, 0.24, 0.14)), Color(0.55, 0.32, 0.18), 0.22)
	var rust_material := _make_material(Color(0.28, 0.18, 0.12), theme.get("crystal", Color(0.85, 0.42, 0.12)), 0.45)
	var silhouette_material := _make_material(Color(0.08, 0.07, 0.06), Color(0.35, 0.22, 0.12), 0.18)
	var segment_len := 96.0
	var segment_count := int(ceil((_track_length + 120.0) / segment_len))
	for segment_index in segment_count:
		var seg_z := -segment_index * segment_len - segment_len * 0.5
		for x in [-32.0, 32.0]:
			var sand := MeshInstance3D.new()
			var sand_mesh := BoxMesh.new()
			sand_mesh.size = Vector3(46.0, 0.08, segment_len + 0.5)
			sand_mesh.material = sand_material
			sand.mesh = sand_mesh
			sand.position = Vector3(x, GROUND_Y - 0.18, seg_z)
			track_root.add_child(sand)
		_add_background_ruins(seg_z, -22.0, silhouette_material)
		if segment_index % 2 == 1:
			_add_cracked_glass_patch(seg_z, 22.0, rust_material)


func _build_savanna_surroundings(theme: Dictionary) -> void:
	var sand_material := _make_material(theme.get("sand", Color(0.62, 0.48, 0.22)), Color(0.78, 0.68, 0.32), 0.16)
	var tree_material := _make_material(Color(0.22, 0.34, 0.14), theme.get("crystal", Color(0.35, 0.78, 0.42)), 0.35)
	var bush_material := _make_material(Color(0.18, 0.28, 0.12), Color(0.45, 0.82, 0.28), 0.28)
	var segment_len := 96.0
	var segment_count := int(ceil((_track_length + 120.0) / segment_len))
	for segment_index in segment_count:
		var seg_z := -segment_index * segment_len - segment_len * 0.5
		for x in [-32.0, 32.0]:
			var sand := MeshInstance3D.new()
			var sand_mesh := BoxMesh.new()
			sand_mesh.size = Vector3(46.0, 0.08, segment_len + 0.5)
			sand_mesh.material = sand_material
			sand.mesh = sand_mesh
			sand.position = Vector3(x, GROUND_Y - 0.18, seg_z)
			track_root.add_child(sand)
		if segment_index % 2 == 0:
			_add_background_crystals(seg_z, -21.0, tree_material)
		else:
			for i in 3:
				var bush := MeshInstance3D.new()
				var mesh := SphereMesh.new()
				mesh.radius = randf_range(0.55, 1.1)
				mesh.height = mesh.radius * 2.0
				mesh.material = bush_material
				bush.mesh = mesh
				bush.position = Vector3(23.0 + i * 2.2, GROUND_Y + mesh.radius * 0.5, seg_z + randf_range(-16.0, 16.0))
				track_root.add_child(bush)


func _add_background_ruins(seg_z: float, x_base: float, material: Material) -> void:
	for i in 4:
		var tower := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(randf_range(1.2, 2.6), randf_range(2.5, 7.5), randf_range(1.0, 2.2))
		mesh.material = material
		tower.mesh = mesh
		tower.position = Vector3(
			x_base + i * randf_range(2.6, 4.2),
			GROUND_Y - 0.1 + mesh.size.y * 0.5,
			seg_z + randf_range(-22.0, 22.0)
		)
		tower.rotation_degrees.y = randf_range(-8.0, 8.0)
		track_root.add_child(tower)


func _add_background_crystals(seg_z: float, x_base: float, material: Material) -> void:
	for i in 3:
		var crystal := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(randf_range(0.8, 1.8), randf_range(3.0, 7.0), randf_range(0.8, 1.8))
		mesh.material = material
		crystal.mesh = mesh
		crystal.position = Vector3(
			x_base + i * randf_range(2.0, 4.0),
			GROUND_Y - 0.1 + mesh.size.y * 0.5,
			seg_z + randf_range(-20.0, 20.0)
		)
		crystal.rotation_degrees = Vector3(randf_range(-6.0, 6.0), randf_range(0.0, 180.0), randf_range(-5.0, 5.0))
		track_root.add_child(crystal)


func _add_cracked_glass_patch(seg_z: float, x: float, material: Material) -> void:
	var patch := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(7.0, 0.035, 12.0)
	mesh.material = material
	patch.mesh = mesh
	patch.position = Vector3(x, GROUND_Y - 0.12, seg_z)
	patch.rotation_degrees.y = randf_range(-10.0, 10.0)
	track_root.add_child(patch)


func _build_choice_gate(at_distance: float, zone: Dictionary) -> void:
	var lane_a := int(zone.get("lane_a", 0))
	var lane_b := int(zone.get("lane_b", 2))
	var gate_scene_index := 1 if _jump_obstacle_paths.size() > 1 else 0
	# 门放在岔路入口两侧，横向拉开，避免看起来像主路弯道装饰
	var mouth_lateral := 5.5
	for lane in [lane_a, lane_b]:
		var marker := Node3D.new()
		marker.name = "ChoiceGate"
		var is_left: bool = lane == lane_a
		var side := -1.0 if is_left else 1.0
		var placed := _world_on_path(at_distance + 4.0, mouth_lateral * side, GROUND_Y)
		marker.position = placed["pos"]
		marker.rotation.y = float(placed["yaw"]) + (-0.22 if is_left else 0.22)
		track_root.add_child(marker)

		var accent := Color(0.25, 0.95, 0.55) if is_left else Color(1.0, 0.62, 0.2)
		_add_scaled_model_visual(
			marker,
			_get_jump_obstacle_scene(gate_scene_index),
			"ChoiceGateModel",
			2.55,
			0.0,
			Vector3.ZERO
		)
		var light := OmniLight3D.new()
		light.light_color = accent
		light.light_energy = 3.0
		light.omni_range = 6.0
		light.position = Vector3(0.0, 1.5, 0.35)
		marker.add_child(light)
		var guide := MeshInstance3D.new()
		var guide_mesh := BoxMesh.new()
		guide_mesh.size = Vector3(1.4, 0.06, 3.2)
		guide_mesh.material = _make_material(accent * 0.3, accent, 1.8)
		guide.mesh = guide_mesh
		guide.position = Vector3(0.0, 0.06, -1.4)
		guide.rotation_degrees.y = -28.0 if is_left else 28.0
		marker.add_child(guide)


func _build_junction_marker(at_distance: float, required_lane: int) -> void:
	var marker := Node3D.new()
	marker.name = "JunctionMarker"
	var placed := _world_on_path(at_distance, LANES[required_lane] * LANE_WIDTH, 0.0)
	marker.position = placed["pos"]
	marker.rotation.y = float(placed["yaw"])
	track_root.add_child(marker)

	var is_left := required_lane == 0
	var arrow_color := Color(0.2, 1.0, 0.55) if is_left else Color(1.0, 0.55, 0.15)
	var mat := _make_material(arrow_color * 0.4, arrow_color, 2.0)
	var arrow := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.2, 0.12, 3.6)
	mesh.material = mat
	arrow.mesh = mesh
	arrow.position = Vector3(0, 0.15, 0)
	arrow.rotation_degrees = Vector3(0, -25 if is_left else 25, 0)
	marker.add_child(arrow)


func _build_runner() -> void:
	player = CharacterBody3D.new()
	player.name = "RunnerPlayer"
	player.position = Vector3(0, GROUND_Y, 0)
	add_child(player)

	var body := Node3D.new()
	body.name = "PlayerVisualRoot"
	player.add_child(body)
	player_body = body
	trail_particles = _make_trail_particles()
	player.add_child(trail_particles)
	landing_particles = _make_landing_particles()
	player.add_child(landing_particles)

	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraRig"
	player.add_child(camera_pivot)

	camera = Camera3D.new()
	camera.name = "RunnerCamera"
	camera.current = true
	camera.fov = CAMERA_FOV
	camera.near = 0.08
	camera.far = 400.0
	camera.position = Vector3(0, 0.45, 0)
	camera.rotation_degrees = Vector3(-18, 0, 0)
	camera_pivot.add_child(camera)
	_build_player_visual()
	_add_player_light()
	_update_camera()


func _add_player_light() -> void:
	# 暖光主体 + 跑道反光青边，让角色融入能量轨
	var key := OmniLight3D.new()
	key.name = "PlayerKeyLight"
	key.position = Vector3(0.0, 1.35, -0.2)
	key.light_color = Color(1.0, 0.82, 0.62)
	key.light_energy = 2.0 if _road_style_id in ["holographic", "energy_neon"] else 1.35
	key.omni_range = 6.5
	key.shadow_enabled = false
	player.add_child(key)
	var rim := OmniLight3D.new()
	rim.name = "PlayerRunwayRim"
	rim.position = Vector3(0.0, 0.35, 0.8)
	rim.light_color = Color(0.45, 0.85, 0.95) if _road_style_id in ["holographic", "energy_neon"] else Color(0.7, 0.85, 1.0)
	rim.light_energy = 1.25 if _road_style_id in ["holographic", "energy_neon"] else 0.55
	rim.omni_range = 5.0
	rim.shadow_enabled = false
	player.add_child(rim)


func _add_ground_contact_shadow(parent: Node3D, width: float, depth: float) -> void:
	var shadow := MeshInstance3D.new()
	shadow.name = "ContactShadow"
	var mesh := SphereMesh.new()
	mesh.radius = maxf(width, depth) * 0.28
	mesh.height = 0.04
	mesh.radial_segments = 12
	mesh.rings = 4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.02, 0.015, 0.01, 0.28)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	shadow.mesh = mesh
	shadow.scale = Vector3(1.35, 0.15, maxf(depth / maxf(width, 0.01), 0.55))
	shadow.position = Vector3(0.0, 0.01, 0.0)
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(shadow)


func _build_player_visual() -> void:
	for child in player_body.get_children():
		child.queue_free()

	player_body.scale = Vector3.ONE
	player_body.position = Vector3.ZERO
	player_body.rotation = Vector3.ZERO
	_set_player_intro_facing(true)

	player_pose_name = ""
	player_pose_models.clear()
	player_slide_pose_root = null
	player_animation_player = null
	player_animation_name = ""
	_skeletal_run_enabled = false

	var model_yaw := _player_yaw_degrees("model_yaw", PLAYER_MODEL_YAW)
	var slide_yaw := _player_yaw_degrees("slide_yaw", PLAYER_SLIDE_MODEL_YAW)

	var animated_path := _player_asset_path("animated_model", "")
	if animated_path != "":
		var run_anim := _player_run_anim_name()
		var animated_scene := _load_runner_scene(animated_path, false)
		if animated_scene:
			var skeletal_yaw := _player_yaw_degrees("animated_model_yaw", model_yaw + 180.0)
			player_pose_root = _add_scaled_model_visual(
				player_body,
				animated_scene,
				"MixamoRunner",
				PLAYER_MODEL_HEIGHT,
				skeletal_yaw,
				Vector3.ZERO,
				-1.0,
				-1.0
			)
			_apply_player_surface_textures(player_pose_root)
			player_animation_player = _find_animation_player(player_pose_root)
			if player_animation_player and player_animation_player.has_animation(run_anim):
				_skeletal_run_enabled = true
				_configure_player_animations()
				player_slide_pose_root = _add_scaled_model_visual(
					player_body,
					_load_runner_scene(_player_asset_path("slide", PLAYER_SLIDE_SCENE_PATH)),
					"SlidePoseModel",
					PLAYER_SLIDE_MODEL_HEIGHT,
					slide_yaw
				)
				player_slide_pose_root.visible = false
				_add_player_pose_model("jump_start", _load_runner_scene(_player_asset_path("jump_start", PLAYER_JUMP_START_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
				_add_player_pose_model("jump_peak", _load_runner_scene(_player_asset_path("jump_peak", PLAYER_JUMP_PEAK_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
				_add_player_pose_model("landing", _load_runner_scene(_player_asset_path("landing", PLAYER_LANDING_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
				_set_player_pose("idle")
				return
		push_warning("Mixamo runner is missing animation '%s'; falling back to pose models." % run_anim)
		if player_pose_root:
			player_pose_root.queue_free()
		player_pose_root = null
		player_animation_player = null
		player_animation_name = ""
		_skeletal_run_enabled = false

	var use_config_player := _player_scene_paths.has("model")
	var animated_scene: PackedScene = null
	if not use_config_player:
		animated_scene = _load_runner_scene(ANIMATED_PLAYER_SCENE_PATH, false)
	if animated_scene:
		player_pose_root = _add_scaled_model_visual(
			player_body,
			animated_scene,
			"CyberpunkArmorRunner",
			PLAYER_MODEL_HEIGHT,
			model_yaw
		)
		player_animation_player = _find_animation_player(player_pose_root)
		if player_animation_player and player_animation_player.has_animation(ANIMATED_PLAYER_RUN_ANIM):
			_configure_player_animations()
			player_slide_pose_root = _add_scaled_model_visual(
				player_body,
				_load_runner_scene(_player_asset_path("slide", PLAYER_SLIDE_SCENE_PATH)),
				"SlidePoseModel",
				PLAYER_SLIDE_MODEL_HEIGHT,
				slide_yaw
			)
			player_slide_pose_root.visible = false
			_play_player_animation("idle")
			return

		push_warning("Fallback animated player has no usable run animation; using pose models instead.")
		if player_pose_root:
			player_pose_root.queue_free()
		player_pose_root = null
		player_animation_player = null
		player_animation_name = ""

	_add_player_pose_model("idle", _load_runner_scene(_player_asset_path("model", PLAYER_MODEL_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("run_left", _load_runner_scene(_player_asset_path("run_left", PLAYER_RUN_LEFT_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("run_right", _load_runner_scene(_player_asset_path("run_right", PLAYER_RUN_RIGHT_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("jump_start", _load_runner_scene(_player_asset_path("jump_start", PLAYER_JUMP_START_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("jump_peak", _load_runner_scene(_player_asset_path("jump_peak", PLAYER_JUMP_PEAK_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("landing", _load_runner_scene(_player_asset_path("landing", PLAYER_LANDING_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("slide", _load_runner_scene(_player_asset_path("slide", PLAYER_SLIDE_SCENE_PATH)), PLAYER_SLIDE_MODEL_HEIGHT, slide_yaw)
	_set_player_pose("idle")


func _load_runner_scene(path: String, warn_if_missing: bool = true) -> PackedScene:
	if path == "":
		return null
	# 2.5D PNG 障碍：运行时打成透明 Quad 场景
	if path.ends_with(".png") or path.ends_with(".webp") or path.ends_with(".jpg") or path.ends_with(".jpeg"):
		return _get_or_create_sprite_obstacle_scene(path, warn_if_missing)
	if _scene_cache.has(path):
		return _scene_cache[path] as PackedScene

	var scene := ResourceLoader.load(path) as PackedScene
	if scene:
		_scene_cache[path] = scene
		return scene

	var fallback_path: String = IMPORTED_SCENE_FALLBACKS.get(path, "")
	if not fallback_path.is_empty():
		if _scene_cache.has(fallback_path):
			return _scene_cache[fallback_path] as PackedScene
		scene = ResourceLoader.load(fallback_path) as PackedScene
		if scene:
			_scene_cache[fallback_path] = scene
			_scene_cache[path] = scene
			return scene

	if warn_if_missing:
		push_warning("Runner model is missing: %s" % path)
	return null


func _get_or_create_sprite_obstacle_scene(path: String, warn_if_missing: bool = true) -> PackedScene:
	if _scene_cache.has(path):
		return _scene_cache[path] as PackedScene
	var tex: Texture2D = null
	# 优先从磁盘读最新 PNG，避免编辑器缓存到未抠透明的旧图
	var abs_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(abs_path):
		var img := Image.new()
		if img.load(abs_path) == OK:
			tex = ImageTexture.create_from_image(img)
	if tex == null and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		if warn_if_missing:
			push_warning("Runner sprite obstacle missing: %s" % path)
		return null

	var root := Node3D.new()
	root.name = "SpriteObstacle"
	root.set_meta("sprite_obstacle_path", path)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "SpriteQuad"
	var quad := QuadMesh.new()
	var tw := maxf(float(tex.get_width()), 1.0)
	var th := maxf(float(tex.get_height()), 1.0)
	var aspect := tw / th
	# 单位高度 1，后续再按玩法缩放；光幕用宽扁比例
	if "phase_curtain" in path:
		quad.size = Vector2(1.0, 1.0 / maxf(aspect, 0.01))  # 先按宽度=1，后面拉到路宽
		root.set_meta("sprite_fit", "road_width")
		root.set_meta("sprite_aspect", aspect)
	else:
		quad.size = Vector2(aspect, 1.0)
		root.set_meta("sprite_fit", "height")
		root.set_meta("sprite_aspect", aspect)

	var mat := StandardMaterial3D.new()
	# 刀口透明：棋盘格残留也不会糊成白板
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.12
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = tex
	mat.albedo_color = Color.WHITE
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if "phase_curtain" in path:
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	else:
		# 跳跃/漂浮类 2.5D：始终面向相机，避免侧对玩家时「看不见却判撞」
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	mat.emission_enabled = true
	# 不用 emission_texture：透明区 RGB 残留会「烧」出棋盘格
	if "phase_curtain" in path:
		mat.emission = Color(0.35, 0.75, 1.0)
		mat.emission_energy_multiplier = 0.55
	elif "orb" in path:
		mat.emission = Color(0.45, 0.85, 1.0)
		mat.emission_energy_multiplier = 0.7
	else:
		mat.emission = Color(0.4, 0.7, 0.95)
		mat.emission_energy_multiplier = 0.4
	mat.no_depth_test = false
	quad.material = mat
	mesh_instance.mesh = quad
	mesh_instance.rotation_degrees.y = 180.0 if "phase_curtain" in path else 0.0
	mesh_instance.position.y = 0.0 if "phase_curtain" in path else 0.5
	root.add_child(mesh_instance)
	mesh_instance.owner = root

	var packed := PackedScene.new()
	var err := packed.pack(root)
	root.free()
	if err != OK:
		if warn_if_missing:
			push_warning("Failed to pack sprite obstacle: %s" % path)
		return null
	_scene_cache[path] = packed
	return packed


func _get_slide_obstacle_scene(index: int) -> PackedScene:
	if not _slide_obstacle_paths.is_empty():
		return _load_runner_scene(_slide_obstacle_paths[index % _slide_obstacle_paths.size()])
	return _slide_obstacle_scene


func _get_slide_obstacle_scene_glb_fallback() -> PackedScene:
	# 滑铲横杆：优先锈蚀水管，与封道/列车区分
	return _get_slide_obstacle_scene_by_hint(["锈蚀水管", "rust", "pipe"], 1)


func _get_train_obstacle_scene() -> PackedScene:
	return _get_slide_obstacle_scene_by_hint(["坍塌广告牌", "billboard"], 2)


func _get_lane_block_scene() -> PackedScene:
	return _get_slide_obstacle_scene_by_hint(["闪避柱", "全息闪避", "能量裂缝", "crack"], 1)


func _get_slide_obstacle_scene_by_hint(hints: Array, fallback_index: int) -> PackedScene:
	for path in _slide_obstacle_paths:
		var path_text := String(path)
		if path_text.ends_with(".png") or path_text.ends_with(".webp"):
			continue
		for hint in hints:
			if String(hint) in path_text:
				return _load_runner_scene(path_text)
	if not _slide_obstacle_paths.is_empty():
		return _get_slide_obstacle_scene(fallback_index)
	return _slide_obstacle_scene


func _get_jump_obstacle_scene(index: int) -> PackedScene:
	if _jump_obstacle_paths.is_empty():
		return null
	return _load_runner_scene(_jump_obstacle_paths[index % _jump_obstacle_paths.size()])


func _build_train(root: Node3D, moving: bool) -> void:
	var visual := _add_scaled_model_visual(
		root,
		_get_train_obstacle_scene(),
		"SlideRoadBlockAsset",
		2.35,
		0.0,
		Vector3.ZERO,
		LANE_WIDTH * 3.2
	)
	if moving:
		visual.rotation_degrees.y += 6.0


func _build_lane_block(root: Node3D, side: String) -> void:
	# 左封：左道+中道；右封：中道+右道（须换到外侧车道，滑铲无效）
	var blocked_x := [-LANE_WIDTH, 0.0] if side == "left" else [0.0, LANE_WIDTH]
	for i in blocked_x.size():
		var visual := _add_scaled_model_visual(
			root,
			_get_lane_block_scene(),
			"LaneBlockAsset_%d" % i,
			2.15,
			0.0,
			Vector3(blocked_x[i], 0.0, 0.0),
			LANE_WIDTH * 1.55
		)
		visual.position.z += -0.35 if i == 0 else 0.35


func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root
	for child in root.find_children("*", "AnimationPlayer", true, false):
		return child as AnimationPlayer
	return null


func _configure_player_animations() -> void:
	if not player_animation_player:
		push_warning("Runner skeletal model has no AnimationPlayer.")
		return
	var run_anim := _player_run_anim_name()
	if player_animation_player.has_animation(run_anim):
		player_animation_player.get_animation(run_anim).loop_mode = Animation.LOOP_LINEAR
	for anim_name in [ANIMATED_PLAYER_IDLE_ANIM, ANIMATED_PLAYER_RUN_ANIM]:
		if anim_name == run_anim:
			continue
		if player_animation_player.has_animation(anim_name):
			player_animation_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	if player_animation_player.has_animation(ANIMATED_PLAYER_CELEBRATE_ANIM):
		player_animation_player.get_animation(ANIMATED_PLAYER_CELEBRATE_ANIM).loop_mode = Animation.LOOP_NONE


func _play_player_animation(state_name: String) -> void:
	if not player_animation_player:
		return
	var anim_name := _player_run_anim_name()
	match state_name:
		"run", "slide", "jump", "landing":
			anim_name = _player_run_anim_name()
		"celebrate":
			anim_name = ANIMATED_PLAYER_CELEBRATE_ANIM if player_animation_player.has_animation(ANIMATED_PLAYER_CELEBRATE_ANIM) else _player_run_anim_name()
		"idle":
			anim_name = _player_run_anim_name()
	if player_animation_name == anim_name and state_name != "idle":
		return
	if not player_animation_player.has_animation(anim_name):
		push_warning("Missing player animation: %s" % anim_name)
		return
	player_animation_name = anim_name
	if state_name == "idle":
		player_animation_player.speed_scale = 0.0
	player_animation_player.play(anim_name, 0.12)


func _add_player_pose_model(
	pose_name: String,
	scene: PackedScene,
	target_height: float = PLAYER_MODEL_HEIGHT,
	yaw_degrees: float = PLAYER_MODEL_YAW
) -> void:
	if not scene:
		return
	var model := _add_scaled_model_visual(player_body, scene, "RunnerModel_%s" % pose_name, target_height, yaw_degrees)
	model.visible = false
	player_pose_models[pose_name] = model


func _set_player_pose(pose_name: String) -> void:
	if _uses_skeletal_run():
		_apply_skeletal_player_pose(pose_name)
		return
	if player_animation_player:
		if player_pose_root:
			player_pose_root.visible = pose_name != "slide"
		if player_slide_pose_root:
			player_slide_pose_root.visible = pose_name == "slide"
		match pose_name:
			"slide":
				_play_player_animation("idle")
			"jump_start", "jump_peak":
				_play_player_animation("jump")
			"landing":
				_play_player_animation("landing")
			"run_left", "run_right":
				_play_player_animation("run")
			_:
				_play_player_animation("idle")
		return
	if player_pose_name == pose_name:
		return
	player_pose_name = pose_name

	for model in player_pose_models.values():
		(model as Node3D).visible = false
	player_pose_root = player_pose_models.get(pose_name, player_pose_models.get("idle")) as Node3D
	if player_pose_root:
		player_pose_root.visible = true


func _set_player_intro_facing(intro_active: bool) -> void:
	if player_body == null:
		return
	# Mixamo 骨骼跑：开场与正式跑同向（仅 animated_model_yaw），不再叠 intro_body_yaw
	if _player_asset_path("animated_model", "") != "":
		player_body.rotation_degrees.y = 0.0
		return
	# 静态姿势 GLB：开场 idle 需额外转 body 展示正面
	if intro_active:
		player_body.rotation_degrees.y = _player_yaw_degrees("intro_body_yaw", PLAYER_INTRO_BODY_YAW)
	else:
		player_body.rotation_degrees.y = 0.0


func _add_scaled_model_visual(
	parent: Node3D,
	scene: PackedScene,
	model_name: String,
	target_height: float,
	yaw_degrees: float = 0.0,
	local_position: Vector3 = Vector3.ZERO,
	max_footprint: float = -1.0,
	max_scale_cap: float = 12.0
) -> Node3D:
	if not scene:
		return _add_missing_model_visual(parent, model_name, target_height, yaw_degrees, local_position)

	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees

	var bounds := _compute_node_aabb(model)
	var characteristic := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if characteristic <= 0.001:
		push_warning("%s bounds invalid, using fallback scale." % model_name)
		model.scale = Vector3.ONE * (target_height / 2.0)
	else:
		var scale_factor := target_height / characteristic
		# Mixamo 绑骨后 mesh AABB 常只有几厘米，需要放大；普通道具仍限制上限
		if max_scale_cap > 0.0:
			scale_factor = minf(scale_factor, max_scale_cap)
		model.scale = Vector3.ONE * scale_factor

	bounds = _compute_node_aabb(model)
	if max_footprint > 0.0:
		var footprint := maxf(bounds.size.x, bounds.size.z)
		if footprint > max_footprint and footprint > 0.001:
			model.scale *= max_footprint / footprint
			bounds = _compute_node_aabb(model)

	model.position += Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5),
	)
	return model


func _add_missing_model_visual(
	parent: Node3D,
	model_name: String,
	target_height: float,
	yaw_degrees: float,
	local_position: Vector3
) -> Node3D:
	var model := Node3D.new()
	model.name = "%sMissingFallback" % model_name
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees
	parent.add_child(model)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.75, max(target_height, 0.25), 0.75)
	mesh.material = _make_material(Color(0.18, 0.32, 0.42), Color(0.25, 0.9, 1.0), 0.8)
	mesh_instance.mesh = mesh
	mesh_instance.position.y = max(target_height, 0.25) * 0.5
	model.add_child(mesh_instance)
	return model


func _tint_model(model: Node3D, material: Material) -> void:
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		mesh_instance.material_override = material


func _make_crystal_material(color: Color, glow: Color) -> StandardMaterial3D:
	var material := _make_material(color, glow, 3.4)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material


func _compute_node_aabb(root: Node3D) -> AABB:
	var merged := AABB()
	var first := true
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if not mesh_instance.mesh:
			continue
		var local_box := mesh_instance.mesh.get_aabb()
		for corner in _aabb_corners(local_box):
			var world_point: Vector3 = mesh_instance.global_transform * corner
			var local_point: Vector3 = root.global_transform.affine_inverse() * world_point
			if first:
				merged = AABB(local_point, Vector3.ZERO)
				first = false
			else:
				merged = merged.expand(local_point)
	return merged


func _aabb_corners(box: AABB) -> Array:
	return [
		box.position,
		box.position + Vector3(box.size.x, 0.0, 0.0),
		box.position + Vector3(0.0, box.size.y, 0.0),
		box.position + Vector3(0.0, 0.0, box.size.z),
		box.position + Vector3(box.size.x, box.size.y, 0.0),
		box.position + Vector3(box.size.x, 0.0, box.size.z),
		box.position + Vector3(0.0, box.size.y, box.size.z),
		box.position + box.size,
	]


func _build_chaser() -> void:
	chaser = Node3D.new()
	chaser.name = "NullTideChaser"
	add_child(chaser)

	var shell := MeshInstance3D.new()
	var shell_mesh := BoxMesh.new()
	shell_mesh.size = Vector3(2.6, 2.8, 2.2)
	shell_mesh.material = _make_material(Color(0.12, 0.06, 0.08), Color(0.85, 0.18, 0.12), 0.9)
	shell.mesh = shell_mesh
	shell.position = Vector3(0, 1.4, 0)
	chaser.add_child(shell)
	chaser_body = shell

	var crest := MeshInstance3D.new()
	var crest_mesh := BoxMesh.new()
	crest_mesh.size = Vector3(1.8, 0.35, 1.4)
	crest_mesh.material = _make_material(Color(0.18, 0.08, 0.06), Color(1.0, 0.35, 0.12), 1.6)
	crest.mesh = crest_mesh
	crest.position = Vector3(0, 2.85, 0.1)
	chaser.add_child(crest)

	for x in [-0.55, 0.55]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.22
		eye_mesh.material = _make_material(Color(0.95, 0.22, 0.08), Color(1.0, 0.45, 0.12), 2.8)
		eye.mesh = eye_mesh
		eye.position = Vector3(x, 1.85, 1.15)
		chaser.add_child(eye)
		if x < 0.0:
			chaser_eye_left = eye
		else:
			chaser_eye_right = eye

	for i in 4:
		var spike := MeshInstance3D.new()
		var spike_mesh := BoxMesh.new()
		spike_mesh.size = Vector3(0.12, 0.55, 0.12)
		spike_mesh.material = _make_material(Color(0.15, 0.1, 0.2), Color(0.7, 0.1, 1.0), 1.4)
		spike.mesh = spike_mesh
		spike.position = Vector3(-0.9 + i * 0.6, 3.05, 0.0)
		spike.rotation_degrees = Vector3(0, 0, randf_range(-12, 12))
		chaser.add_child(spike)

	var aura := MeshInstance3D.new()
	var aura_mesh := BoxMesh.new()
	aura_mesh.size = Vector3(3.2, 0.08, 3.2)
	aura_mesh.material = _make_material(Color(0.4, 0.05, 0.6, 0.35), Color(0.9, 0.1, 1.0), 2.2)
	aura.mesh = aura_mesh
	aura.position = Vector3(0, 0.12, 0)
	chaser.add_child(aura)
	chaser.scale = Vector3(0.38, 0.38, 0.38)
	chaser.visible = false


func _update_chaser_visuals(delta: float) -> void:
	if not chaser or not chaser.visible:
		return
	chaser_pulse = maxf(chaser_pulse - delta * 1.8, 0.0)
	var danger := 1.0 - clampf(chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var bob := sin(elapsed * 8.0 + intro_elapsed * 4.0) * 0.08
	chaser_body.position.y = 1.4 + bob + chaser_pulse * 0.35
	var eye_energy := lerpf(1.8, 3.2, danger + chaser_pulse * 0.5)
	for eye in [chaser_eye_left, chaser_eye_right]:
		if not eye:
			continue
		var mat := eye.get_active_material(0) as StandardMaterial3D
		if mat:
			mat.emission_energy_multiplier = eye_energy


func _build_content() -> void:
	var raw_obstacles: Array
	if CustomLevels.has_level(Global.runner_location_id):
		raw_obstacles = CustomLevels.load_obstacles_for_run(Global.runner_location_id, LevelConfig)
	else:
		raw_obstacles = LevelConfig.build_obstacles()
	var obstacle_items: Array = MissionTypes.adapt_obstacles(
		raw_obstacles,
		_mission_profile,
		_track_length
	)
	# adapt 缩放/加密后可能把下滑门等漂进侧墙走廊，再滤一次
	obstacle_items = _filter_adapted_obstacles_from_wall_corridors(obstacle_items)
	for item in obstacle_items:
		_register_obstacle(item)
	obstacles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)
	_obstacle_scan_index = 0

	var coin_index := 0
	if LevelConfig.has_method("build_main_runway_coins"):
		var main_coins: Array = MissionTypes.adapt_main_runway_coins(
			LevelConfig.build_main_runway_coins(),
			_track_length,
			float(_mission_profile.get("obstacle_density", 1.0))
		)
		for raw in main_coins:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = raw
			var lane: int = int(item.get("lane", 0))
			var dist: float = float(item.get("distance", 0.0))
			var layer: int = int(item.get("layer", 0))
			var y_boost := bool(item.get("y_boost", false))
			var y: float = _layer_height(layer) + (1.15 if y_boost else 0.4)
			var collectible := _make_collectible(lane, dist, y, layer)
			collectibles.append({
				"node": collectible,
				"lane": lane,
				"distance": dist,
				"y": y,
				"layer": layer,
				"kind": "coin",
				"collected": false,
			})
			coin_index += 1
	else:
		var coin_dists: Array = MissionTypes.adapt_coin_distances(
			LevelConfig.build_coin_distances(),
			_track_length,
			float(_mission_profile.get("obstacle_density", 1.0))
		)
		for dist in coin_dists:
			var lane: int = int(LANES[coin_index % LANES.size()])
			var layer: int = 0
			var y: float = _layer_height(layer) + (0.35 if coin_index % 5 != 2 else 1.2)
			var collectible := _make_collectible(lane, dist, y, layer)
			collectibles.append({
				"node": collectible,
				"lane": lane,
				"distance": dist,
				"y": y,
				"layer": layer,
				"kind": "coin",
				"collected": false,
			})
			coin_index += 1

	if LevelConfig.has_method("build_side_runway_coins"):
		var side_coins: Array = MissionTypes.adapt_side_runway_coins(
			LevelConfig.build_side_runway_coins(),
			_track_length
		)
		for raw in side_coins:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = raw
			var lane: int = int(item.get("lane", 0))
			var dist: float = float(item.get("distance", 0.0))
			var layer: int = int(item.get("layer", WALL_RUN_LAYER))
			var y_boost := bool(item.get("y_boost", false))
			var y: float = _wall_lane_height_for_lane_value(lane) + (0.55 if y_boost else 0.0)
			var collectible := _make_collectible(lane, dist, y, layer)
			collectibles.append({
				"node": collectible,
				"lane": lane,
				"distance": dist,
				"y": y,
				"layer": layer,
				"kind": "coin",
				"collected": false,
			})

	_spawn_shield_crystals()
	total_collectibles = 0
	for c in collectibles:
		if String(c.get("kind", "coin")) == "coin":
			total_collectibles += 1


func _spawn_shield_crystals() -> void:
	var items: Array = []
	if LevelConfig != null and LevelConfig.has_method("build_shield_crystals") and not CustomLevels.has_level(Global.runner_location_id):
		items = LevelConfig.build_shield_crystals()
	else:
		items = _default_shield_crystals_from_sandstorms()
	var finish_cut := maxf(_track_length - 30.0, _track_length * 0.9)
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var dist := float(item.get("distance", 0.0))
		if dist < 20.0 or dist > finish_cut:
			continue
		var lane := int(item.get("lane", 0))
		var layer := int(item.get("layer", 0))
		var y: float = _layer_height(layer) + 0.85
		var node := _make_shield_crystal(lane, dist, y, layer)
		collectibles.append({
			"node": node,
			"lane": lane,
			"distance": dist,
			"y": y,
			"layer": layer,
			"kind": "shield_crystal",
			"collected": false,
		})


func _default_shield_crystals_from_sandstorms() -> Array:
	var out: Array = []
	var zones := _sandstorm_zones()
	if zones.is_empty():
		# 无沙尘暴时仍沿途投放少量水晶，方便试用防护罩
		for d in [90.0, 210.0, 360.0, 520.0, 700.0, 880.0]:
			out.append({"lane": (int(d) % 3) - 1, "distance": d, "layer": 0})
		return out
	for zone in zones:
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		out.append({"lane": 0, "distance": start - 16.0, "layer": 0})
		out.append({"lane": 1, "distance": start - 8.0, "layer": 0})
		out.append({"lane": -1, "distance": start + length * 0.4, "layer": 0})
		out.append({"lane": 0, "distance": start + length + 12.0, "layer": 0})
	return out


func _register_obstacle(item: Dictionary) -> Node3D:
	var obstacle_type := String(item["type"])
	var lane: int = int(item.get("lane", 0))
	var dist: float = float(item["distance"])
	var layer: int = int(item.get("layer", 0))
	var node := _make_obstacle(lane, dist, obstacle_type, layer, item)
	var asset_path := String(node.get_meta("obstacle_asset_path", ""))
	var is_float_orb := node.has_meta("float_orb") and bool(node.get_meta("float_orb"))
	var default_clear := 1.55 if obstacle_type in ["slide", "high_bar"] else 1.35
	if obstacle_type == "main_block":
		default_clear = _layer_height(layer) + 4.0
	if is_float_orb:
		default_clear = GROUND_Y + 1.02
	elif "energy_sprigs" in asset_path:
		default_clear = GROUND_Y + 0.45
	var strike_label := ""
	if LevelConfig.has_method("get_jump_obstacle_label") and asset_path != "":
		strike_label = LevelConfig.get_jump_obstacle_label(asset_path)
	var entry := {
		"node": node,
		"lane": lane,
		"distance": dist,
		"type": obstacle_type,
		"layer": layer,
		"clear_height": float(item.get("clear_height", default_clear)),
		"half_depth": float(item.get("half_depth", _obstacle_half_depth(obstacle_type))),
		"hit": false,
		"heat_hazard": node.has_meta("heat_hazard") and bool(node.get_meta("heat_hazard")),
		"float_orb": is_float_orb,
		"strike_label": strike_label,
		"moving": obstacle_type == "train_moving",
		"move_speed": float(item.get("move_speed", 0.0)),
		"move_offset": 0.0,
		"y_offset": float(item.get("y_offset", 0.0)),
		"target_layer": int(item.get("target_layer", layer + 1)),
	}
	obstacles.append(entry)
	_place_obstacle_node(entry)
	return node


func _make_obstacle(lane: int, distance: float, obstacle_type: String, layer: int, item: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = "%sObstacle" % obstacle_type.capitalize()
	track_root.add_child(root)

	match obstacle_type:
		"slide", "high_bar":
			_build_high_bar(root)
		"jump", "low_barrier":
			_build_low_barrier(root, item)
		"train", "train_moving":
			_build_train(root, obstacle_type == "train_moving")
		"block_left":
			_build_lane_block(root, "left")
		"block_right":
			_build_lane_block(root, "right")
		"ramp":
			_build_ramp(root, int(item.get("target_layer", layer + 1)))
		"main_block":
			_build_main_block(root, float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0))))
		"turn_left", "turn_right":
			_build_turn_sign(root, obstacle_type)
		_:
			_build_low_barrier(root, item)

	return root


func _build_low_barrier(root: Node3D, item: Dictionary = {}) -> void:
	var path_count := maxi(_jump_obstacle_paths.size(), 1)
	var scene_index := int(item.get("visual_index", -1))
	if scene_index < 0:
		var lane := int(item.get("lane", 0))
		var dist_key := int(float(item.get("distance", 0.0)))
		scene_index = absi(lane * 17 + dist_key) % path_count
	var asset_path := ""
	if not _jump_obstacle_paths.is_empty():
		asset_path = _jump_obstacle_paths[scene_index % _jump_obstacle_paths.size()]
		root.set_meta("obstacle_asset_path", asset_path)
		if "热浪" in asset_path:
			root.set_meta("heat_hazard", true)
	var target_h := 1.15
	if "energy_orb" in asset_path:
		target_h = 1.45
	elif "energy_sprigs" in asset_path:
		target_h = 1.25
	elif "全息跳跃" in asset_path:
		target_h = 1.2
	# 横杆类：按高度轴缩放，避免「最宽边」把模型压成脚踝高
	if "全息跳跃" in asset_path:
		_add_jump_bar_visual(root, _get_jump_obstacle_scene(scene_index), target_h, LANE_WIDTH * 1.55)
	else:
		var visual := _add_scaled_model_visual(
			root,
			_get_jump_obstacle_scene(scene_index),
			"JumpObstacleModel",
			target_h,
			0.0 if asset_path.ends_with(".png") else 180.0,
			Vector3.ZERO,
			LANE_WIDTH * 1.65
		)
		if "energy_orb" in asset_path:
			# 漂浮在胸口高度，换道躲避为主，跳也可蹭过
			visual.position.y += 0.75
			root.set_meta("float_orb", true)
		elif not asset_path.ends_with(".png"):
			visual.rotation_degrees.y += 8.0 if scene_index == 0 else -8.0


func _add_jump_bar_visual(root: Node3D, scene: PackedScene, target_height: float, target_span: float) -> void:
	if scene == null:
		_add_missing_model_visual(root, "JumpObstacleModel", target_height, 0.0, Vector3.ZERO)
		return
	var model := scene.instantiate() as Node3D
	model.name = "JumpObstacleModel"
	root.add_child(model)
	model.position = Vector3.ZERO
	model.rotation_degrees = Vector3.ZERO

	var bounds := _compute_node_aabb(model)
	if bounds.size.y <= 0.001:
		push_warning("JumpObstacleModel bounds invalid")
		return
	# 若模型更宽轴在 Z，转到横跨 X
	if bounds.size.z > bounds.size.x * 1.15:
		model.rotation_degrees.y = 90.0
		bounds = _compute_node_aabb(model)

	var sx := target_span / maxf(bounds.size.x, 0.001)
	var sy := target_height / maxf(bounds.size.y, 0.001)
	# 厚度略跟高度，避免杆子扁成纸片
	var sz := clampf(sy, 0.85, 2.8)
	model.scale = Vector3(sx, sy, sz)
	bounds = _compute_node_aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)
	_add_ground_contact_shadow(root, target_span * 0.85, 0.9)

func _build_high_bar(root: Node3D) -> void:
	var slide_path := _slide_obstacle_paths[0] if not _slide_obstacle_paths.is_empty() else ""
	if slide_path.ends_with(".png") and "phase_curtain" in slide_path:
		# 光幕拉满路宽；高度单独控制，底边贴跑道（根节点已在 GROUND_Y）
		var scene := _get_slide_obstacle_scene(0)
		if scene == null:
			_add_road_span_gate(root, "SlideObstacleModel", null, 1.95, 14.8)
			_add_slide_visibility_curtain(root)
			return
		var model := scene.instantiate() as Node3D
		model.name = "SlideObstacleModel"
		root.add_child(model)
		var target_w := 13.5
		var target_h := 2.05
		var bounds := _compute_node_aabb(model)
		var sx := target_w / maxf(bounds.size.x, 0.001)
		var sy := target_h / maxf(bounds.size.y, 0.001)
		model.scale = Vector3(sx, sy, 1.0)
		bounds = _compute_node_aabb(model)
		model.position = Vector3(
			-(bounds.position.x + bounds.size.x * 0.5),
			-bounds.position.y,
			-(bounds.position.z + bounds.size.z * 0.5)
		)
		_add_ground_contact_shadow(root, 11.0, 1.0)
	elif slide_path.ends_with(".png"):
		var visual := _add_scaled_model_visual(
			root,
			_get_slide_obstacle_scene(0),
			"SlideObstacleModel",
			2.2,
			0.0,
			Vector3.ZERO
		)
		visual.position.y += 0.4
		_add_ground_contact_shadow(root, 10.0, 1.2)
	else:
		_add_road_span_gate(root, "SlideObstacleModel", _get_slide_obstacle_scene(0), 1.95, 14.8)
	# 全息 GLB 半透明时仍保证有可读光幕，避免「撞了却看不见」
	_add_slide_visibility_curtain(root)


func _add_slide_visibility_curtain(root: Node3D) -> void:
	var curtain := MeshInstance3D.new()
	curtain.name = "SlideVisibilityCurtain"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(LANE_WIDTH * 3.15, 1.85, 0.22)
	var mat := _make_material(Color(0.25, 0.85, 1.0, 0.38), Color(0.35, 0.95, 1.0), 2.2)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	curtain.mesh = mesh
	curtain.position = Vector3(0.0, 1.05, 0.0)
	root.add_child(curtain)


func _add_road_span_gate(
	parent: Node3D,
	model_name: String,
	scene: PackedScene,
	target_height: float,
	target_span: float
) -> Node3D:
	# 全路横杆：立柱贴地、宽度略超跑道，视觉上像架在路面上的屏障
	if scene == null:
		return _add_missing_model_visual(parent, model_name, target_height, 0.0, Vector3.ZERO)

	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = Vector3.ZERO
	model.rotation_degrees = Vector3.ZERO

	var bounds := _compute_node_aabb(model)
	if bounds.size.y <= 0.001:
		push_warning("%s gate bounds invalid" % model_name)
		return model

	# 若模型更宽轴在 Z，转到横跨 X（路面横向）
	if bounds.size.z > bounds.size.x * 1.15:
		model.rotation_degrees.y = 90.0
		bounds = _compute_node_aabb(model)

	# X 拉满跨度，Y 控高度；避免均匀缩放被高度夹窄
	var sx := target_span / maxf(bounds.size.x, 0.001)
	var sy := target_height / maxf(bounds.size.y, 0.001)
	var sz := sy
	model.scale = Vector3(sx, sy, sz)
	bounds = _compute_node_aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)
	# 立柱底座微微陷入路面，消除「飘在空中」的缝
	model.position.y -= 0.04
	_add_ground_contact_shadow(parent, bounds.size.x * 0.95, maxf(bounds.size.z, 1.1))
	return model


func _add_slide_obstacle_visual(parent: Node3D, model_name: String, local_position: Vector3, target_height: float) -> Node3D:
	# 列车/封道等仍用单车道道具缩放
	var height := clampf(target_height, 1.6, 2.4)
	var visual := _add_scaled_model_visual(
		parent,
		_get_slide_obstacle_scene(parent.get_index()),
		model_name,
		height,
		0.0,
		local_position
	)
	var bounds := _compute_node_aabb(visual)
	var max_span := LANE_WIDTH * 1.5
	var span := maxf(bounds.size.x, bounds.size.z)
	if span > max_span and span > 0.001:
		visual.scale *= max_span / span
		bounds = _compute_node_aabb(visual)
		visual.position = local_position + Vector3(
			-(bounds.position.x + bounds.size.x * 0.5),
			-bounds.position.y,
			-(bounds.position.z + bounds.size.z * 0.5)
		)
	_add_ground_contact_shadow(visual, minf(span, max_span), 1.0)
	return visual


func _build_ramp(root: Node3D, target_layer: int) -> void:
	var visual := _add_scaled_model_visual(
		root,
		_get_jump_obstacle_scene(1),
		"RampMarkerAsset",
		1.2,
		180.0,
		Vector3(0.0, 0.0, 0.0)
	)
	visual.rotation_degrees.x = -12.0


func _build_main_block(root: Node3D, half_depth: float = 8.0) -> void:
	# 只做入口警示门；长坍塌带由沿路径的挖坑条带展示，避免弯道上长方体斜出跑道
	var _hd := half_depth
	var gate := MeshInstance3D.new()
	gate.name = "MainBlockGate"
	var gate_mesh := BoxMesh.new()
	gate_mesh.size = Vector3(LANE_WIDTH * 3.2, 0.22, 1.8)
	var gate_mat := _make_material(Color(0.95, 0.32, 0.12, 0.7), Color(1.0, 0.4, 0.1), 2.4)
	gate_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gate_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	gate_mesh.material = gate_mat
	gate.mesh = gate_mesh
	gate.position = Vector3(0.0, 0.12, 0.0)
	root.add_child(gate)

	var post_l := MeshInstance3D.new()
	var post_r := MeshInstance3D.new()
	for post in [post_l, post_r]:
		var pm := BoxMesh.new()
		pm.size = Vector3(0.28, 2.4, 0.28)
		var pmat := _make_material(Color(0.9, 0.35, 0.12), Color(1.0, 0.45, 0.15), 1.8)
		pm.material = pmat
		post.mesh = pm
		post.position = Vector3(0.0, 1.2, 0.0)
		root.add_child(post)
	post_l.position.x = -LANE_WIDTH * 1.45
	post_r.position.x = LANE_WIDTH * 1.45

	var beam := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(LANE_WIDTH * 3.0, 0.22, 0.22)
	var bmat := _make_material(Color(1.0, 0.4, 0.15), Color(1.0, 0.5, 0.2), 2.0)
	bm.material = bmat
	beam.mesh = bm
	beam.position = Vector3(0.0, 2.35, 0.0)
	root.add_child(beam)

	var label := Label3D.new()
	label.text = "主路坍塌"
	label.font_size = 56
	label.modulate = Color(1.0, 0.55, 0.25)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 3.0, 0.0)
	root.add_child(label)
	_add_ground_contact_shadow(root, LANE_WIDTH * 3.0, 1.2)

func _build_turn_sign(root: Node3D, turn_type: String) -> void:
	var is_left := turn_type == "turn_left"
	var visual := _add_scaled_model_visual(
		root,
		_get_jump_obstacle_scene(0),
		"TurnMarkerAsset",
		1.05,
		180.0,
		Vector3(-0.45 if is_left else 0.45, 0.0, 0.0)
	)
	visual.rotation_degrees.y += -28.0 if is_left else 28.0


func _make_collectible(lane: int, distance: float, y: float, layer: int) -> Node3D:
	var collectible := Node3D.new()
	collectible.name = "EmberCoin"

	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.22
	ring_mesh.outer_radius = 0.42
	ring_mesh.rings = 16
	ring_mesh.ring_segments = 48
	ring_mesh.material = _make_material(Color(1.0, 0.72, 0.08), Color(1.0, 0.72, 0.04), 1.9)
	ring.mesh = ring_mesh
	ring.rotation_degrees = Vector3(90, 0, 0)
	collectible.add_child(ring)

	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.15
	core_mesh.height = 0.3
	core_mesh.radial_segments = 16
	core_mesh.rings = 8
	core_mesh.material = _make_material(Color(1.0, 0.96, 0.42), Color(1.0, 0.86, 0.12), 1.4)
	core.mesh = core_mesh
	collectible.add_child(core)

	track_root.add_child(collectible)
	var placed: Dictionary
	if layer == WALL_RUN_LAYER:
		placed = _world_on_path(distance, 0.0, y, WALL_RUN_LAYER)
	else:
		placed = _world_on_path(distance, float(lane) * LANE_WIDTH, y, layer)
	collectible.position = placed["pos"]
	collectible.rotation.y = float(placed["yaw"])
	return collectible


func _make_shield_crystal(lane: int, distance: float, y: float, layer: int) -> Node3D:
	var root := Node3D.new()
	root.name = "ShieldCrystal"
	var crystal := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.55, 1.1, 0.55)
	var mat := _make_material(Color(0.45, 0.9, 1.0, 0.85), Color(0.3, 0.85, 1.0), 2.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	prism.material = mat
	crystal.mesh = prism
	crystal.position.y = 0.55
	root.add_child(crystal)
	var glow := MeshInstance3D.new()
	var glow_mesh := SphereMesh.new()
	glow_mesh.radius = 0.22
	glow_mesh.height = 0.44
	glow_mesh.material = _make_material(Color(0.7, 0.95, 1.0, 0.35), Color(0.4, 0.9, 1.0), 1.8)
	glow.mesh = glow_mesh
	glow.position.y = 0.55
	root.add_child(glow)
	track_root.add_child(root)
	var placed: Dictionary = _world_on_path(distance, float(lane) * LANE_WIDTH, y, layer)
	root.position = placed["pos"]
	root.rotation.y = float(placed["yaw"])
	return root


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	_letterbox_left = ColorRect.new()
	_letterbox_left.name = "RunnerLetterboxLeft"
	_letterbox_left.color = Color(0.02, 0.018, 0.014)
	_letterbox_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_letterbox_left.visible = false
	ui.add_child(_letterbox_left)

	_letterbox_right = ColorRect.new()
	_letterbox_right.name = "RunnerLetterboxRight"
	_letterbox_right.color = Color(0.02, 0.018, 0.014)
	_letterbox_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_letterbox_right.visible = false
	ui.add_child(_letterbox_right)

	var frame := AspectRatioContainer.new()
	frame.name = "RunnerMobileFrame"
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.stretch_mode = AspectRatioContainer.STRETCH_FIT
	frame.ratio = MOBILE_VIEWPORT_SIZE.x / MOBILE_VIEWPORT_SIZE.y
	frame.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	frame.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	ui.add_child(frame)

	var shell := Control.new()
	shell.name = "RunnerMobileShell"
	shell.custom_minimum_size = MOBILE_VIEWPORT_SIZE
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(shell)
	hud_root = shell

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	shell.add_child(margin)

	var root := VBoxContainer.new()
	margin.add_child(root)
	debug_hud_box = root
	debug_hud_box.visible = false

	time_label = Label.new()
	speed_label = Label.new()
	collectible_label = Label.new()
	layer_label = Label.new()
	phase_label = Label.new()
	score_label = Label.new()
	cargo_icon = TextureRect.new()
	cargo_icon.custom_minimum_size = Vector2(52, 52)
	cargo_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cargo_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cargo_icon.visible = false
	cargo_label = Label.new()
	cargo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	chase_label = Label.new()
	for label in [time_label, speed_label, phase_label, score_label, layer_label, chase_label, collectible_label]:
		label.add_theme_font_size_override("font_size", 26)
		root.add_child(label)

	chase_bar = ProgressBar.new()
	chase_bar.custom_minimum_size = Vector2(0, 22)
	chase_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chase_bar.max_value = CHASER_MAX_DISTANCE
	chase_bar.value = CHASER_START_DISTANCE
	chase_bar.show_percentage = false
	root.add_child(chase_bar)

	strike_toast_label = Label.new()
	strike_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	strike_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	strike_toast_label.add_theme_font_size_override("font_size", 22)
	strike_toast_label.modulate = Color(1, 1, 1, 0)
	strike_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(strike_toast_label)
	# 横跨画幅顶部居中；勿用 CENTER_TOP 零尺寸锚点（会粘在左上角）
	strike_toast_label.anchor_left = 0.06
	strike_toast_label.anchor_right = 0.94
	strike_toast_label.anchor_top = 0.0
	strike_toast_label.anchor_bottom = 0.0
	strike_toast_label.offset_left = 0.0
	strike_toast_label.offset_right = 0.0
	strike_toast_label.offset_top = 118.0
	strike_toast_label.offset_bottom = 168.0

	danger_vignette = ColorRect.new()
	danger_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	danger_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	danger_vignette.color = Color(0.45, 0.1, 0.04, 0.0)
	danger_vignette.visible = _chaser_enabled
	ui.add_child(danger_vignette)

	var chaser_hint_wrap := MarginContainer.new()
	chaser_hint_wrap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	chaser_hint_wrap.offset_left = -156.0
	chaser_hint_wrap.offset_top = 132.0
	chaser_hint_wrap.offset_right = -28.0
	chaser_hint_wrap.offset_bottom = 248.0
	chaser_hint_wrap.visible = _chaser_enabled
	shell.add_child(chaser_hint_wrap)

	chaser_hint_panel = PanelContainer.new()
	chaser_hint_panel.custom_minimum_size = Vector2(112, 88)
	chaser_hint_wrap.add_child(chaser_hint_panel)

	var hint_box := VBoxContainer.new()
	hint_box.alignment = BoxContainer.ALIGNMENT_CENTER
	chaser_hint_panel.add_child(hint_box)

	chaser_hint_label = Label.new()
	chaser_hint_label.text = LevelConfig.CHASER_NAME
	chaser_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chaser_hint_label.add_theme_font_size_override("font_size", 20)
	hint_box.add_child(chaser_hint_label)

	var hint_dist := Label.new()
	hint_dist.name = "ChaserHintDistance"
	hint_dist.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_dist.add_theme_font_size_override("font_size", 16)
	hint_box.add_child(hint_dist)

	state_panel = PanelContainer.new()
	state_panel.visible = false
	state_panel.custom_minimum_size = Vector2(680, 0)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(center)
	center.add_child(state_panel)

	var state_margin := MarginContainer.new()
	state_margin.add_theme_constant_override("margin_left", 24)
	state_margin.add_theme_constant_override("margin_right", 24)
	state_margin.add_theme_constant_override("margin_top", 20)
	state_margin.add_theme_constant_override("margin_bottom", 20)
	state_panel.add_child(state_margin)

	var state_box := VBoxContainer.new()
	state_box.alignment = BoxContainer.ALIGNMENT_CENTER
	state_box.add_theme_constant_override("separation", 14)
	state_margin.add_child(state_box)

	state_title = Label.new()
	state_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_title.add_theme_font_size_override("font_size", 34)
	state_title.add_theme_color_override("font_color", Color(0.98, 0.82, 0.45))
	state_box.add_child(state_title)

	state_body = Label.new()
	state_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state_body.custom_minimum_size = Vector2(620, 0)
	state_body.add_theme_font_size_override("font_size", 21)
	state_body.add_theme_color_override("font_color", Color(0.86, 0.80, 0.66))
	state_box.add_child(state_body)

	var state_button_row := VBoxContainer.new()
	state_button_row.add_theme_constant_override("separation", 10)
	state_box.add_child(state_button_row)

	state_restart_button = Button.new()
	state_restart_button.text = "重新开始"
	state_restart_button.custom_minimum_size = Vector2(320, 56)
	state_restart_button.add_theme_font_size_override("font_size", 20)
	state_restart_button.pressed.connect(_restart_run)
	state_button_row.add_child(state_restart_button)

	state_back_button = Button.new()
	state_back_button.text = "返回地图"
	state_back_button.custom_minimum_size = Vector2(320, 56)
	state_back_button.add_theme_font_size_override("font_size", 20)
	state_back_button.pressed.connect(_return_to_exploration_map)
	state_button_row.add_child(state_back_button)

	intro_panel = PanelContainer.new()
	intro_panel.custom_minimum_size = Vector2(640, 240)
	center.add_child(intro_panel)

	var intro_box := VBoxContainer.new()
	intro_box.alignment = BoxContainer.ALIGNMENT_CENTER
	intro_panel.add_child(intro_box)

	intro_title = Label.new()
	intro_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_title.add_theme_font_size_override("font_size", 56)
	intro_box.add_child(intro_title)

	intro_body = Label.new()
	intro_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_body.custom_minimum_size = Vector2(580, 0)
	intro_body.add_theme_font_size_override("font_size", 24)
	intro_box.add_child(intro_body)
	intro_panel.visible = true

	pause_button = Button.new()
	pause_button.text = "Ⅱ"
	pause_button.custom_minimum_size = Vector2(72, 72)
	pause_button.add_theme_font_size_override("font_size", 28)
	pause_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	pause_button.offset_left = 24.0
	pause_button.offset_top = 24.0
	pause_button.offset_right = 96.0
	pause_button.offset_bottom = 96.0
	pause_button.pressed.connect(_on_pause_button_pressed)
	shell.add_child(pause_button)

	shield_button = Button.new()
	shield_button.text = "盾"
	shield_button.tooltip_text = "防护罩 (F)"
	shield_button.custom_minimum_size = Vector2(72, 72)
	shield_button.add_theme_font_size_override("font_size", 26)
	shield_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	shield_button.offset_left = 24.0
	shield_button.offset_top = 108.0
	shield_button.offset_right = 96.0
	shield_button.offset_bottom = 180.0
	shield_button.pressed.connect(_toggle_shield)
	shell.add_child(shield_button)

	var shield_panel := PanelContainer.new()
	shield_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	shield_panel.offset_left = 110.0
	shield_panel.offset_top = 24.0
	shield_panel.offset_right = 340.0
	shield_panel.offset_bottom = 108.0
	shell.add_child(shield_panel)
	var shield_margin := MarginContainer.new()
	shield_margin.add_theme_constant_override("margin_left", 12)
	shield_margin.add_theme_constant_override("margin_top", 8)
	shield_margin.add_theme_constant_override("margin_right", 12)
	shield_margin.add_theme_constant_override("margin_bottom", 8)
	shield_panel.add_child(shield_margin)
	var shield_box := VBoxContainer.new()
	shield_box.add_theme_constant_override("separation", 4)
	shield_margin.add_child(shield_box)
	shield_label = Label.new()
	shield_label.text = "防护罩 关 · F"
	shield_label.add_theme_font_size_override("font_size", 20)
	shield_box.add_child(shield_label)
	shield_bar = ProgressBar.new()
	shield_bar.custom_minimum_size = Vector2(0, 18)
	shield_bar.max_value = SHIELD_MAX_ENERGY
	shield_bar.value = shield_energy
	shield_bar.show_percentage = false
	shield_box.add_child(shield_bar)

	var cargo_panel := PanelContainer.new()
	cargo_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	cargo_panel.offset_left = -260.0
	cargo_panel.offset_top = 24.0
	cargo_panel.offset_right = -24.0
	cargo_panel.offset_bottom = 96.0
	shell.add_child(cargo_panel)
	_cargo_hud_panel = cargo_panel

	var cargo_panel_margin := MarginContainer.new()
	cargo_panel_margin.add_theme_constant_override("margin_left", 12)
	cargo_panel_margin.add_theme_constant_override("margin_top", 8)
	cargo_panel_margin.add_theme_constant_override("margin_right", 12)
	cargo_panel_margin.add_theme_constant_override("margin_bottom", 8)
	cargo_panel.add_child(cargo_panel_margin)

	var cargo_panel_row := HBoxContainer.new()
	cargo_panel_row.add_theme_constant_override("separation", 10)
	cargo_panel_margin.add_child(cargo_panel_row)
	cargo_panel_row.add_child(cargo_icon)
	cargo_icon.custom_minimum_size = Vector2(48, 48)
	cargo_panel_row.add_child(cargo_label)
	cargo_label.add_theme_font_size_override("font_size", 22)


func _on_pause_button_pressed() -> void:
	if is_finished or is_failed:
		return
	if _pause_overlay != null:
		_pause_overlay.open_pause()


func _update_runner_letterboxes() -> void:
	if _letterbox_left == null or _letterbox_right == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var target_ratio := MOBILE_VIEWPORT_SIZE.x / MOBILE_VIEWPORT_SIZE.y
	var content_width := viewport_size.y * target_ratio
	if viewport_size.x <= content_width + 1.0:
		_letterbox_left.visible = false
		_letterbox_right.visible = false
		return
	var bar_width := (viewport_size.x - content_width) * 0.5
	_letterbox_left.visible = true
	_letterbox_left.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_letterbox_left.anchor_top = 0.0
	_letterbox_left.anchor_bottom = 1.0
	_letterbox_left.offset_left = 0.0
	_letterbox_left.offset_top = 0.0
	_letterbox_left.offset_right = bar_width
	_letterbox_left.offset_bottom = 0.0

	_letterbox_right.visible = true
	_letterbox_right.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_letterbox_right.anchor_top = 0.0
	_letterbox_right.anchor_bottom = 1.0
	_letterbox_right.offset_left = -bar_width
	_letterbox_right.offset_top = 0.0
	_letterbox_right.offset_right = 0.0
	_letterbox_right.offset_bottom = 0.0


func _update_hud() -> void:
	var type_zh := String(mission.get("task_type_zh", _mission_profile.get("name_zh", "补给")))
	if bool(_mission_profile.get("timed_fail", false)):
		time_label.text = "剩余 %0.1f · %s" % [maxf(_run_time - elapsed, 0.0), type_zh]
	else:
		time_label.text = "时间 %0.1f / %0.0f · %s" % [elapsed, _run_time, type_zh]
	var speed_text := "速度 %0.1f m/s" % (current_speed * speed_penalty_mult)
	if speed_penalty_timer > 0.0:
		speed_text += " (减速)"
	speed_label.text = speed_text

	var phase: Dictionary = LevelConfig.phase_at(track_distance)
	if track_layer > 0:
		phase_label.text = "侧墙跑 · 左/右切换高度列"
	else:
		phase_label.text = "阶段 %s · %s" % [phase["name"], phase["hint"]]
	cargo_label.text = "货物 %s  完整度 %0.0f%%" % [String(mission.get("cargo_name", "物资")), cargo_integrity]
	score_label.text = "星火币 %d" % run_score
	layer_label.text = "地图 %s" % LevelConfig.MAP_NAME
	collectible_label.text = "星火币 %d / %d · 水晶 %d" % [collected_count, total_collectibles, crystal_collected_count]
	if shield_label:
		if _is_shield_protecting():
			shield_label.text = "防护罩 开 · 抵挡沙尘暴"
			shield_label.add_theme_color_override("font_color", Color(0.45, 0.92, 1.0))
		elif shield_active and shield_energy <= 0.001:
			shield_label.text = "防护罩 耗尽 · 拾取水晶"
			shield_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
		else:
			shield_label.text = "防护罩 关 · F/盾键开启"
			shield_label.add_theme_color_override("font_color", Color(0.75, 0.82, 0.9))
	if shield_bar:
		shield_bar.value = shield_energy
	if shield_button:
		shield_button.modulate = Color(0.55, 0.95, 1.0) if _is_shield_protecting() else Color(1, 1, 1)

	var danger_ratio := 1.0 - clampf(chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var chase_status := "安全"
	if danger_ratio > 0.72:
		chase_status = "极危"
	elif danger_ratio > 0.45:
		chase_status = "危险"
	elif danger_ratio > 0.22:
		chase_status = "逼近"
	chase_label.text = "%s %0.1fm [%s]" % [LevelConfig.CHASER_NAME, chaser_distance, chase_status]
	chase_bar.value = chaser_distance
	if danger_ratio > 0.72:
		chase_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.2))
	elif danger_ratio > 0.45:
		chase_label.add_theme_color_override("font_color", Color(1.0, 0.65, 0.15))
	else:
		chase_label.add_theme_color_override("font_color", Color(0.55, 0.95, 0.75))

	if chaser_hint_panel:
		var hint_alpha := clampf(danger_ratio * 0.85 + 0.15, 0.15, 1.0)
		chaser_hint_panel.modulate = Color(1.0, 0.55 + danger_ratio * 0.25, 0.25, hint_alpha)
		chaser_hint_label.text = "%s\n%0.0fm" % [LevelConfig.CHASER_NAME, chaser_distance] if danger_ratio > 0.15 else "零潮\n安全"
	if danger_vignette:
		danger_vignette.color = Color(0.55, 0.12, 0.04, danger_ratio * 0.1)

	if strike_toast_timer > 0.0:
		strike_toast_timer = maxf(strike_toast_timer - get_process_delta_time(), 0.0)
		strike_toast_label.modulate.a = clampf(strike_toast_timer / 1.6, 0.0, 1.0)
	elif strike_toast_label.text != "":
		strike_toast_label.text = ""
		strike_toast_label.modulate.a = 0.0


func _show_state(title: String, body: String) -> void:
	state_title.text = title
	state_body.text = body
	state_panel.visible = true


func _update_camera() -> void:
	var slide_offset := -0.45 if _is_sliding() else 0.0
	var danger_ratio := clampf(1.0 - chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var shake_offset := Vector3.ZERO
	if camera_shake > 0.0:
		shake_offset = Vector3(randf_range(-0.035, 0.035), randf_range(-0.025, 0.025), 0.0) * (camera_shake / 0.16)
		camera_shake = maxf(camera_shake - get_process_delta_time(), 0.0)

	var cam_behind := CAMERA_BEHIND
	if is_intro:
		cam_behind = lerpf(CAMERA_BEHIND + 1.2, CAMERA_BEHIND, clampf(intro_elapsed / INTRO_DURATION, 0.0, 1.0))

	if _is_wall_running():
		var zone := _side_runway_zone_at(track_distance)
		var side := _wall_zone_side(zone)
		# 根节点已直立：相机仍挂在角色上。偏向主路内侧，始终能看见贴墙的主角
		cam_behind = 9.2
		camera_pivot.position = Vector3(
			shake_offset.x + (-side * 3.4),
			CAMERA_HEIGHT + 0.85 + slide_offset,
			cam_behind
		) + shake_offset * 0.35
		camera.position = Vector3(0.0, 0.35, 0.0)
		var focus := player.global_position + Vector3(0.0, 0.95, 0.0)
		var sample := _sample_path(track_distance)
		var inward: Vector3 = (sample["right"] as Vector3) * (-side)
		focus += inward * 1.1
		if camera.global_position.distance_squared_to(focus) > 0.02:
			camera.look_at(focus, Vector3.UP)
		camera.fov = lerpf(camera.fov, clampf(CAMERA_FOV + danger_ratio * 2.0, CAMERA_FOV, 68.0), 0.1)
		return

	camera_pivot.position = Vector3(
		shake_offset.x,
		CAMERA_HEIGHT + slide_offset,
		cam_behind
	) + shake_offset * 0.35
	camera.position = Vector3(0, 0.45, 0.0)

	# 沿真实路径（含岔路横向偏移）取前瞻点，避免瞬时切线直线瞄出路面
	var look_ahead := CAMERA_LOOK_AHEAD
	if not _fork_zone_at(track_distance).is_empty():
		look_ahead = minf(CAMERA_LOOK_AHEAD, 12.0)
	if is_intro:
		look_ahead *= 0.35
	var ahead := _world_on_path(track_distance + look_ahead, current_lateral, GROUND_Y)
	var mid := _world_on_path(track_distance + look_ahead * 0.45, current_lateral, GROUND_Y)
	# 近点 + 远点混合，岔路弯道更跟路面
	var look_target: Vector3 = (ahead["pos"] as Vector3).lerp(mid["pos"] as Vector3, 0.35) + Vector3(0.0, 1.25, 0.0)
	if camera.global_position.distance_squared_to(look_target) > 0.04:
		camera.look_at(look_target, Vector3.UP)

	var target_fov := clampf(CAMERA_FOV + danger_ratio * 2.0, CAMERA_FOV, 68.0)
	camera.fov = lerpf(camera.fov, target_fov, 0.1)


func _update_runner_feedback(delta: float) -> void:
	if _is_sliding():
		_set_player_pose("slide")
	elif vertical_velocity > 2.4:
		_set_player_pose("jump_start")
	elif not _is_on_ground():
		_set_player_pose("jump_peak")
	elif body_squash_timer > 0.0:
		_set_player_pose("landing")
	else:
		if _uses_skeletal_run():
			_set_player_pose("run")
		else:
			var run_step := int(floor(elapsed * 8.0)) % 2
			_set_player_pose("run_left" if run_step == 0 else "run_right")

	if _uses_skeletal_run() and player_pose_root and player_pose_root.visible and player_animation_player:
		var speed_mult := _player_run_anim_speed_mult()
		player_animation_player.speed_scale = maxf(current_speed / RUN_SPEED, 0.45) * speed_mult

	var x_error := target_lane_x - current_lateral
	if _is_wall_running():
		var target_wy: float = float(WALL_LANE_HEIGHTS[clampi(lane_index, 0, WALL_LANE_HEIGHTS.size() - 1)])
		x_error = (target_wy - current_wall_y) * 0.55
	body_tilt = lerpf(body_tilt, clampf(-x_error * 0.18, -0.45, 0.45), 1.0 - exp(-10.0 * delta))
	if player_body:
		if _is_wall_running():
			_apply_wall_run_body_orientation(_wall_zone_side(_side_runway_zone_at(track_distance)))
		else:
			player_body.rotation.z = body_tilt

	trail_particles.amount_ratio = remap(current_speed, RUN_SPEED, RUN_SPEED_MAX, 0.45, 1.0)

	if _is_sliding():
		player_body.scale = player_body.scale.lerp(Vector3.ONE, 1.0 - exp(-16.0 * delta))
		player_body.position.y = lerpf(player_body.position.y, 0.0, 1.0 - exp(-16.0 * delta))
		return

	if body_squash_timer > 0.0:
		body_squash_timer = maxf(body_squash_timer - delta, 0.0)
		var squash_ratio := body_squash_timer / 0.16
		player_body.scale = Vector3(1.0 + squash_ratio * 0.16, 1.0 - squash_ratio * 0.22, 1.0 + squash_ratio * 0.16)
	else:
		player_body.scale = player_body.scale.lerp(Vector3.ONE, 1.0 - exp(-12.0 * delta))
	player_body.position.y = lerpf(player_body.position.y, 0.0, 1.0 - exp(-12.0 * delta))


func _update_collectible_magnet(delta: float) -> void:
	for collectible in collectibles:
		if collectible["collected"]:
			continue
		if int(collectible.get("layer", 0)) != track_layer:
			continue
		var node := collectible["node"] as Node3D
		var to_player := player.global_position + Vector3(0, 0.45, 0) - node.global_position
		var distance := to_player.length()
		if distance > MAGNET_RADIUS:
			continue
		var pull := MAGNET_SPEED * delta * clampf(1.0 - distance / MAGNET_RADIUS, 0.18, 1.0)
		node.global_position += to_player.normalized() * minf(pull, distance)


func _emit_landing_particles() -> void:
	if not landing_particles:
		return
	landing_particles.restart()
	landing_particles.emitting = true


func _make_trail_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "SpeedTrail"
	particles.position = Vector3(0, -0.15, 0.45)
	particles.amount = 80
	particles.lifetime = 0.28
	particles.preprocess = 0.2
	particles.emitting = true
	particles.draw_pass_1 = _make_particle_mesh(0.035)

	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0, 0, 1)
	material.spread = 12.0
	material.initial_velocity_min = 5.0
	material.initial_velocity_max = 10.0
	material.gravity = Vector3(0, 0, 0)
	material.scale_min = 0.35
	material.scale_max = 1.1
	material.color = Color(1.0, 0.62, 0.18, 0.55)
	particles.process_material = material
	return particles


func _make_landing_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "LandingBurst"
	particles.position = Vector3(0, -0.68, 0)
	particles.amount = 36
	particles.lifetime = 0.32
	particles.one_shot = true
	particles.emitting = false
	particles.draw_pass_1 = _make_particle_mesh(0.045)

	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.spread = 80.0
	material.initial_velocity_min = 1.8
	material.initial_velocity_max = 4.2
	material.gravity = Vector3(0, -7.5, 0)
	material.scale_min = 0.55
	material.scale_max = 1.4
	material.color = Color(0.95, 0.98, 1.0, 0.85)
	particles.process_material = material
	return particles


func _make_particle_mesh(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = _make_material(Color(0.55, 0.95, 1.0), Color(0.25, 0.9, 1.0), 1.2)
	return mesh


func _build_finish_gate() -> void:
	var hearth_placed := _world_on_path(_track_length + 26.0, 0.0, GROUND_Y)
	var dome := _add_scaled_model_visual(
		track_root,
		_load_runner_scene(_hearth_scene_path),
		"HearthDomeSettlement",
		13.0,
		rad_to_deg(float(hearth_placed["yaw"])) + 180.0,
		hearth_placed["pos"]
	)
	dome.rotation_degrees.y += 18.0

	var gate := Node3D.new()
	gate.name = "HearthGate"
	var gate_placed := _world_on_path(_track_length, 0.0, 2.5)
	gate.position = gate_placed["pos"]
	gate.rotation.y = float(gate_placed["yaw"])
	track_root.add_child(gate)

	var portal_material := _make_material(Color(1.0, 0.72, 0.28), Color(1.0, 0.55, 0.12), 2.4)
	var frame_material := _make_material(Color(0.22, 0.14, 0.08), Color(0.65, 0.38, 0.12), 0.8)

	for x in [-4.2, 4.2]:
		var pillar := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.5, 5.2, 0.5)
		mesh.material = frame_material
		pillar.mesh = mesh
		pillar.position = Vector3(x, 0.0, 0.0)
		gate.add_child(pillar)

	var top := MeshInstance3D.new()
	var top_mesh := BoxMesh.new()
	top_mesh.size = Vector3(9.0, 0.55, 0.5)
	top_mesh.material = frame_material
	top.mesh = top_mesh
	top.position = Vector3(0, 2.35, 0)
	gate.add_child(top)

	var portal := MeshInstance3D.new()
	var portal_mesh := PlaneMesh.new()
	portal_mesh.size = Vector2(7.2, 4.1)
	portal_mesh.material = portal_material
	portal.mesh = portal_mesh
	portal.position = Vector3(0, 0.15, 0.08)
	gate.add_child(portal)


func _build_starfield() -> void:
	var material := _make_material(Color(1.0, 0.82, 0.55), Color(1.0, 0.65, 0.25), 0.8)
	for i in 80:
		var star := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = randf_range(0.018, 0.055)
		mesh.height = mesh.radius * 2.0
		mesh.radial_segments = 8
		mesh.rings = 4
		mesh.material = material
		star.mesh = mesh
		star.position = Vector3(randf_range(-60.0, 60.0), randf_range(7.0, 26.0), randf_range(-_track_length, 20.0))
		add_child(star)


func _add_obstacle_post(obstacle: Node3D, x: float, y: float, glow_color: Color) -> void:
	var post := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.08
	mesh.bottom_radius = 0.08
	mesh.height = 1.8
	mesh.radial_segments = 12
	mesh.material = _make_material(Color(0.06, 0.08, 0.09), glow_color, 1.2)
	post.mesh = mesh
	post.position = Vector3(x, y, 0)
	obstacle.add_child(post)


func _make_material(color: Color, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.15
	material.roughness = 0.65
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
