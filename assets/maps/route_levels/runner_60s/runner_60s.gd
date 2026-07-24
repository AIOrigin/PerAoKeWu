extends Node3D

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MobilePauseOverlay = preload("res://assets/maps/route_levels/mobile_pause_overlay.gd")
const HitFeedback = preload("res://assets/systems/hit_feedback/hit_feedback.gd")
const ROAD_ENERGY_NEON_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_energy_neon.gdshader")
const ROAD_ALIEN_ENERGY_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_alien_energy.gdshader")
const ROAD_HOLOGRAPHIC_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_holographic.gdshader")

const ROAD_STYLE_ORDER: Array[String] = ["holographic", "alien_energy", "energy_neon", "planet", "rust_metal", "void_crystal"]
const ROAD_STYLE_LABELS := {
	"holographic": "全息能量轨",
	"alien_energy": "异星能量轨",
	"planet": "星球默认",
	"energy_neon": "能量霓虹",
	"rust_metal": "锈蚀金属",
	"void_crystal": "虚空晶体",
}

const LANE_WIDTH := 4.0
const LANES := [-1, 0, 1]
const RUN_TIME := 60.0
const RUN_SPEED := 14.0
const RUN_SPEED_MAX := 24.0
const TRACK_LENGTH := RUN_TIME * (RUN_SPEED + RUN_SPEED_MAX) * 0.5
const LANE_CHANGE_EASE := 12.0
const GRAVITY := 28.0
const JUMP_SPEED := 12.5
const SLIDE_TIME := 0.75
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
const OBSTACLE_HALF_DEPTH := {
	"jump": 0.55,
	"low_barrier": 0.55,
	"slide": 0.72,
	"high_bar": 0.72,
	"train": 1.05,
	"train_moving": 1.05,
	"block_left": 0.75,
	"block_right": 0.75,
}
const STRIKE_DAMAGE_TIER := {
	"jump": 0.55,
	"low_barrier": 0.55,
	"slide": 0.7,
	"high_bar": 0.7,
	"block_left": 0.85,
	"block_right": 0.85,
	"train": 1.0,
	"train_moving": 1.15,
}
const HEAT_HAZARD_DPS := 7.0
const HEAT_HAZARD_HALF_LEN := 7.0
const HEAT_HAZARD_TICK := 0.45
const INTRO_DURATION := 3.0
const PRE_RUN_LOADING_TIME := 0.45
const PRE_RUN_COUNTDOWN_STEP := 1.0
const CHASER_ENABLED := false
const GROUND_Y := 0.85
const CAMERA_BEHIND := 7.8
const CAMERA_HEIGHT := 2.35
const CAMERA_LOOK_AHEAD := 18.0
const CAMERA_FOV := 64.0
const START_PAD_LENGTH := 72.0
const TOUCH_SWIPE_MIN_DISTANCE := 72.0
const TOUCH_TAP_MAX_DISTANCE := 26.0
const MOBILE_VIEWPORT_SIZE := Vector2(1080, 1920)
const ANIMATED_PLAYER_SCENE_PATH := "res://3d素材/cyberpunk+armor+3d+model_副本.glb"
const ANIMATED_PLAYER_IDLE_ANIM := "NlaTrack.002"
const ANIMATED_PLAYER_RUN_ANIM := "NlaTrack"
const ANIMATED_PLAYER_CELEBRATE_ANIM := "NlaTrack.001"
const PLAYER_MODEL_SCENE_PATH := "res://3d素材/Elsa.glb"
const PLAYER_RUN_LEFT_SCENE_PATH := "res://3d素材/奔跑左腿前.glb"
const PLAYER_RUN_RIGHT_SCENE_PATH := "res://3d素材/跑步右脚前.glb"
const PLAYER_JUMP_START_SCENE_PATH := "res://3d素材/起跳.glb"
const PLAYER_JUMP_PEAK_SCENE_PATH := "res://3d素材/跳跃高点.glb"
const PLAYER_LANDING_SCENE_PATH := "res://3d素材/落地.glb"
const PLAYER_SLIDE_SCENE_PATH := "res://3d素材/滑铲.glb"
const PLAYER_MODEL_HEIGHT := 1.65
const PLAYER_MODEL_YAW := -90.0
const PLAYER_INTRO_BODY_YAW := 180.0
const PLAYER_SLIDE_MODEL_HEIGHT := 0.75
const PLAYER_SLIDE_MODEL_YAW := 180.0
const IMPORTED_SCENE_FALLBACKS := {
	"res://3d素材/Elsa.glb": "res://.godot/imported/Elsa.glb-98f5c1965f2201b39824e7d015ccd31f.scn",
	"res://3d素材/奔跑左腿前.glb": "res://.godot/imported/奔跑左腿前.glb-9e99a5e9eabee48087ee92542977f25a.scn",
	"res://3d素材/跑步右脚前.glb": "res://.godot/imported/跑步右脚前.glb-08ee22fd58a2328e60ecd4958b8d9c45.scn",
	"res://3d素材/起跳.glb": "res://.godot/imported/起跳.glb-1573aa6ad9de7e88288b1ab76172b3e7.scn",
	"res://3d素材/跳跃高点.glb": "res://.godot/imported/跳跃高点.glb-bc7511edc3a2eb9738197efc09a8866b.scn",
	"res://3d素材/落地.glb": "res://.godot/imported/落地.glb-c15990896e7d93cd809dfccd4246d765.scn",
	"res://3d素材/滑铲.glb": "res://.godot/imported/滑铲.glb-5324a9310d5c602d2ffff35b79c260a7.scn",
	"res://3d素材/障碍物-需跳跃.glb": "res://.godot/imported/障碍物-需跳跃.glb-46f57db02e27254a677214f954ab0d83.scn",
	"res://3d素材/障碍物-需跳跃2.glb": "res://.godot/imported/障碍物-需跳跃2.glb-c8c9938e154747024ae7ac221ab7db3a.scn",
	"res://3d素材/居民穹顶据点 3d model.glb": "res://.godot/imported/居民穹顶据点 3d model.glb-f6066a8ae2d51e15aff61146c4296099.scn",
}

# 分层跑道（当前玩法锁定地面）
const LAYER_HEIGHTS := [GROUND_Y, 3.8, 6.5]
const LAYER_NAMES := ["地面", "车顶", "高架"]

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
var _path_baked := false
var _road_edge_particles: Array[GPUParticles3D] = []

var player: CharacterBody3D
var player_body: Node3D
var player_pose_root: Node3D
var player_slide_pose_root: Node3D
var player_pose_models: Dictionary = {}
var player_animation_player: AnimationPlayer
var player_animation_name := ""
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
var run_score := 0
var cargo_integrity := 100.0
var mission: Dictionary = {}
var obstacles: Array[Dictionary] = []
var collectibles: Array[Dictionary] = []
var track_distance := 0.0
var track_layer := 0
var track_root: Node3D
var passed_junctions: Array[int] = []
var _path_samples: Array[Dictionary] = []
var _path_length := 0.0
var _fork_side := 0
var _active_fork_index := -1
var _path_yaw := 0.0
var _fork_approach_warned: Array[int] = []

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
	mission = LevelConfig.get_mission_for_location(Global.runner_location_id).duplicate()
	if mission.is_empty():
		mission = LevelConfig.MISSION.duplicate()
	lane_change_ease = LANE_CHANGE_EASE + Global.get_lane_change_ease_bonus()
	cargo_integrity = 100.0
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


func _bootstrap_runner_world() -> void:
	_load_planet_assets()
	_build_world()
	await get_tree().process_frame
	_build_runner()
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
		_set_lane(lane_index - 1)
	elif event.is_action_pressed("move_right"):
		_set_lane(lane_index + 1)
	elif event.is_action_pressed("jump") and _is_on_ground():
		_try_jump()
	elif event.is_action_pressed("move_backward") and _is_on_ground():
		_try_slide()


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
		_set_lane(lane_index + (1 if touch_delta.x > 0.0 else -1))
	elif touch_delta.y < 0.0:
		_try_jump()
	else:
		_try_slide()
	return true


func _try_jump() -> void:
	if not _is_on_ground():
		return
	vertical_velocity = JUMP_SPEED
	_end_slide()
	body_squash_timer = 0.16
	camera_shake = maxf(camera_shake, 0.05)
	_emit_landing_particles()


func _try_slide() -> void:
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
	current_speed = lerpf(RUN_SPEED, RUN_SPEED_MAX, clampf(elapsed / RUN_TIME, 0.0, 1.0))
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
	current_lateral = lerpf(current_lateral, target_lane_x, 1.0 - exp(-lane_change_ease * delta))

	vertical_velocity -= GRAVITY * delta
	var ground_y := _layer_height(track_layer)
	var next_y := player.position.y + vertical_velocity * delta
	if next_y <= ground_y and vertical_velocity <= 0.0:
		next_y = ground_y
		vertical_velocity = 0.0
	player.position.y = next_y

	_sync_player_position()
	_sync_chaser_from_track()
	_update_moving_obstacles(delta)
	_check_ramps()
	_enforce_track_layer()

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

	if elapsed >= RUN_TIME or track_distance >= TRACK_LENGTH:
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


func _layer_height(layer: int) -> float:
	return LAYER_HEIGHTS[clampi(layer, 0, LAYER_HEIGHTS.size() - 1)]


func _is_on_ground() -> bool:
	return player.position.y <= _layer_height(track_layer) + 0.02 and vertical_velocity <= 0.01


func _distance_to_z(distance: float) -> float:
	# 兼容旧调用：仅直线近似，优先使用 _sample_path
	return _sample_path(distance)["pos"].z


func _bake_track_path() -> void:
	_path_samples.clear()
	var segments: Array = []
	if LevelConfig.has_method("get_track_segments"):
		segments = LevelConfig.get_track_segments()
	if segments.is_empty():
		segments = [{"length": TRACK_LENGTH + 80.0, "turn": 0.0}]

	var pos := Vector3.ZERO
	var yaw := 0.0
	var dist := 0.0
	var step := 2.0
	_path_samples.append({"d": 0.0, "pos": pos, "yaw": yaw})
	for seg in segments:
		var length := float(seg.get("length", 0.0))
		var turn := float(seg.get("turn", 0.0))
		if length <= 0.001:
			continue
		var steps := maxi(1, int(ceil(length / step)))
		var ds := length / float(steps)
		var dyaw := turn / float(steps)
		for _i in steps:
			yaw += dyaw
			var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
			pos += forward * ds
			dist += ds
			_path_samples.append({"d": dist, "pos": pos, "yaw": yaw})
	_path_length = dist
	if _path_length < TRACK_LENGTH:
		# 不足时直线补齐到终点
		var remain := TRACK_LENGTH + 40.0 - _path_length
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
	if _path_samples.size() == 1:
		var only: Dictionary = _path_samples[0]
		return _pack_path_sample(only["pos"], float(only["yaw"]))

	var lo := 0
	var hi := _path_samples.size() - 1
	while lo < hi - 1:
		var mid := (lo + hi) >> 1
		if float(_path_samples[mid]["d"]) <= d:
			lo = mid
		else:
			hi = mid
	var a: Dictionary = _path_samples[lo]
	var b: Dictionary = _path_samples[hi]
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
	if LevelConfig == null:
		return {}
	for zone in LevelConfig.JUNCTION_ZONES:
		var start := float(zone["distance"])
		var length := float(zone.get("length", 70.0))
		if distance >= start and distance <= start + length:
			return zone
	return {}


func _fork_adjusted_lateral(distance: float, lateral: float) -> float:
	# 岔路仍保留三道：branch_center + (-4/0/+4)
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
	var side := _fork_side
	if side == 0:
		if absf(lateral) > LANE_WIDTH * 0.25:
			side = -1 if lateral < 0.0 else 1
		else:
			# 中道：仍走脊柱（主路空洞，惩罚）
			return lateral * (1.0 - envelope * 0.9)
	var branch_center := float(side) * spread * envelope
	return branch_center + lateral


func _fork_yaw_nudge(distance: float, lateral: float) -> float:
	# 岔路朝向跟所在分支，与当前三道中的哪一条无关
	var zone := _fork_zone_at(distance)
	if zone.is_empty():
		return 0.0
	var side := _fork_side
	if side == 0:
		if absf(lateral) > LANE_WIDTH * 0.25:
			side = -1 if lateral < 0.0 else 1
		else:
			return 0.0
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


func _world_on_path(distance: float, lateral: float, y: float) -> Dictionary:
	var sample := _sample_path(distance)
	var x := _fork_adjusted_lateral(distance, lateral)
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * x
	pos.y = y
	return {"pos": pos, "yaw": float(sample["yaw"]), "forward": sample["forward"], "right": sample["right"]}


func _sync_player_position() -> void:
	var keep_y := player.position.y if player else GROUND_Y
	var placed := _world_on_path(track_distance, current_lateral, keep_y)
	player.position = placed["pos"]
	_path_yaw = float(placed["yaw"]) + _fork_yaw_nudge(track_distance, current_lateral)
	# 岔路上用前方真实落点推朝向，比单点 yaw nudge 更贴路面
	if not _fork_zone_at(track_distance).is_empty():
		var ahead := _world_on_path(track_distance + 8.0, current_lateral, keep_y)
		var delta: Vector3 = (ahead["pos"] as Vector3) - (placed["pos"] as Vector3)
		delta.y = 0.0
		if delta.length_squared() > 0.04:
			var face_yaw := atan2(-delta.x, -delta.z)
			_path_yaw = lerp_angle(_path_yaw, face_yaw, 0.72)
	player.rotation.y = _path_yaw


func _check_junctions() -> void:
	for junction_index in LevelConfig.JUNCTION_ZONES.size():
		if passed_junctions.has(junction_index):
			continue
		var zone: Dictionary = LevelConfig.JUNCTION_ZONES[junction_index]
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
			_fork_side = 0
			var fork_penalty := 8.0 * Global.get_cargo_damage_multiplier()
			_apply_cargo_loss(fork_penalty)
			if not is_failed:
				if _hit_feedback != null and player != null:
					_hit_feedback.apply_impact(
						player.global_position + Vector3(0.0, 1.7, 0.0),
						HitFeedback.Intensity.LIGHT,
						fork_penalty,
						"未选岔路"
					)
				_show_strike_warning("未选择岔路（请靠左或靠右）")

	# 离开分叉段后复位
	if _active_fork_index >= 0 and _active_fork_index < LevelConfig.JUNCTION_ZONES.size():
		var active: Dictionary = LevelConfig.JUNCTION_ZONES[_active_fork_index]
		var end_d := float(active["distance"]) + float(active.get("length", 70.0))
		if track_distance > end_d + 1.0:
			_active_fork_index = -1
			_fork_side = 0


func _check_fork_approach() -> void:
	for junction_index in LevelConfig.JUNCTION_ZONES.size():
		if _fork_approach_warned.has(junction_index) or passed_junctions.has(junction_index):
			continue
		var zone: Dictionary = LevelConfig.JUNCTION_ZONES[junction_index]
		var at_distance := float(zone["distance"])
		if track_distance < at_distance - 38.0 or track_distance > at_distance - 28.0:
			continue
		_fork_approach_warned.append(junction_index)
		_show_gate_toast("前方分叉 · 左=%s · 右=%s" % [
			String(zone.get("label_a", "左")),
			String(zone.get("label_b", "右")),
		])


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
	var speed_pad := maxf(absf(dist_to - dist_from) * 0.5, 0.12)
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
	# 横跨全路的滑铲/高杆屏障
	if obstacle_type in ["slide", "high_bar", "ramp"]:
		return true
	# 堵左/右：用连续横向位置，换道途中也公平
	if obstacle_type == "block_left":
		return current_lateral < LANE_WIDTH * 0.55
	if obstacle_type == "block_right":
		return current_lateral > -LANE_WIDTH * 0.55
	var lane_x := float(obstacle["lane"]) * LANE_WIDTH
	return absf(current_lateral - lane_x) <= LANE_HIT_HALF_WIDTH


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
		collected_count += 1
		run_score += int(LevelConfig.EMBER_COIN_VALUE)


func _enforce_track_layer() -> void:
	# 暂时锁定地面层，避免高层相机穿模、跑道消失
	track_layer = 0
	if _is_on_ground() and abs(player.position.y - _layer_height(0)) > 0.05:
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
			vertical_velocity = maxf(vertical_velocity, JUMP_SPEED * 1.0)
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
	var lateral := 0.0 if obstacle_type in ["slide", "high_bar"] else float(obstacle["lane"]) * LANE_WIDTH
	if obstacle_type in ["slide", "high_bar"]:
		y -= 0.06
	var placed := _world_on_path(dist, lateral, y)
	node.position = placed["pos"]
	node.rotation.y = float(placed["yaw"])


func _finish_run() -> void:
	is_finished = true
	_play_player_animation("celebrate")
	var first_clear := not Global.get_completed_runner_locations(Global.runner_planet_id).has(Global.runner_location_id)
	Global.mark_runner_location_completed(Global.runner_planet_id, Global.runner_location_id)
	_apply_mission_unlocks()
	var cargo_load := int(mission.get("cargo_load", 100))
	var delivered := int(float(cargo_load) * cargo_integrity * 0.01)
	var grade: String = LevelConfig.integrity_grade(cargo_integrity)
	var grade_label: String = LevelConfig.integrity_grade_label(cargo_integrity) if LevelConfig.has_method("integrity_grade_label") else grade
	var base_coins := collected_count * int(LevelConfig.EMBER_COIN_VALUE)
	var grade_mult: float = LevelConfig.grade_coin_multiplier(grade) if LevelConfig.has_method("grade_coin_multiplier") else 1.0
	var coin_bonus := int(round(float(base_coins) * Global.get_coin_yield_multiplier() * grade_mult))
	run_score += delivered + coin_bonus
	Global.add_ember_coins(coin_bonus)
	var xp_result: Dictionary = Global.grant_messenger_runner_rewards(
		grade,
		int(mission.get("difficulty", 1)),
		first_clear
	)
	Global.pending_location_showcase_id = Global.runner_location_id
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var level_text := "Lv.%d" % int(xp_result["new_level"])
	if bool(xp_result["level_up"]):
		level_text = "升级！Lv.%d" % int(xp_result["new_level"])
	var settlement_body := "MISSION COMPLETE / 任务完成\n\n货物完整度：%0.0f%%\n评级：%s\n\n基础奖励 %d × 评级倍率 %0.2f = 星火币 +%d\n经验 +%d（%s）\n\n相邻区域已可继续探索" % [
		cargo_integrity,
		grade_label,
		base_coins,
		grade_mult,
		coin_bonus,
		int(xp_result["xp_gain"]),
		level_text,
	]
	_show_state("MISSION COMPLETE / 任务完成", settlement_body)
	if state_restart_button:
		state_restart_button.visible = false


func _apply_mission_unlocks() -> void:
	var revealed := Global.get_revealed_exploration_locations(Global.runner_planet_id, ["dome"])
	if not revealed.has(Global.runner_location_id):
		revealed.append(Global.runner_location_id)
	for linked_id in mission.get("unlock_ids", []):
		var location_id := String(linked_id)
		if location_id != "" and not revealed.has(location_id):
			revealed.append(location_id)
	Global.set_revealed_exploration_locations(Global.runner_planet_id, revealed)


func _fail_run(reason: String = "被零潮捕获") -> void:
	is_failed = true
	_play_player_animation("idle")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var fail_reason := reason
	if cargo_integrity <= 0.0:
		fail_reason = "货物损毁"
	elif reason.contains("零潮") and not CHASER_ENABLED:
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
	var obstacle_type := String(obstacle["type"])
	if obstacle_type in LevelConfig.OBSTACLE_TYPES:
		return "撞上%s" % LevelConfig.OBSTACLE_TYPES[obstacle_type]
	return "撞上障碍"


func _on_runner_strike(reason: String, obstacle: Dictionary = {}) -> void:
	strike_count += 1
	strike_recovery_timer = 0.0
	chaser_distance = maxf(chaser_distance - CHASER_HIT_PENALTY, CHASER_CATCH_DISTANCE)
	speed_penalty_mult = HIT_SLOW_FACTOR
	speed_penalty_timer = HIT_SLOW_DURATION
	chaser_pulse = 1.0
	var obstacle_type := String(obstacle.get("type", ""))
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
		if CHASER_ENABLED:
			_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)
		return
	# HitFeedback 飘字 + Toast 完整度，双通道更可读
	_show_strike_warning(reason)


func _show_strike_warning(reason: String) -> void:
	if not gameplay_active:
		return
	intro_panel.visible = false
	if CHASER_ENABLED:
		strike_toast_label.text = "⚠ %s  |  %s %0.0fm  |  完整度 %0.0f%%" % [
			reason, LevelConfig.CHASER_NAME, chaser_distance, cargo_integrity
		]
	else:
		strike_toast_label.text = "⚠ %s  |  完整度 %0.0f%%" % [reason, cargo_integrity]
	strike_toast_timer = 1.6
	strike_toast_label.modulate = Color(1.0, 0.55, 0.35, 1.0)


func _update_chaser(delta: float) -> void:
	chaser_distance = maxf(chaser_distance - CHASER_BASE_CREEP * delta, CHASER_CATCH_DISTANCE)
	if strike_count > 0:
		strike_recovery_timer += delta
		if strike_recovery_timer >= STRIKE_RECOVERY_TIME:
			strike_count = 0
			strike_recovery_timer = 0.0
	elif chaser_distance < CHASER_MAX_DISTANCE:
		chaser_distance = minf(chaser_distance + CHASER_RECOVERY_RATE * delta, CHASER_MAX_DISTANCE)


func _check_chaser_caught() -> void:
	if not CHASER_ENABLED:
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
		intro_body.text = "准备出发"
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
		"block_left", "block_right":
			# 横向已过滤，进窗口即撞
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
	_player_scene_paths = assets.get("player", {}) if assets.get("player") is Dictionary else {}


func _player_asset_path(key: String, fallback: String) -> String:
	var path := String(_player_scene_paths.get(key, ""))
	return path if path != "" else fallback


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
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	if _road_style_id == "alien_energy":
		environment.background_mode = Environment.BG_COLOR
		environment.background_color = Color(0.008, 0.012, 0.025)
	else:
		environment.background_mode = Environment.BG_SKY
		environment.background_color = theme.get("background", Color(0.14, 0.09, 0.05))
		var sky := Sky.new()
		var panorama := PanoramaSkyMaterial.new()
		panorama.panorama = _world_panorama
		sky.sky_material = panorama
		environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = theme.get("ambient", Color(0.92, 0.68, 0.44))
	environment.ambient_light_energy = float(theme.get("ambient_energy", 1.35))
	environment.fog_enabled = true
	environment.fog_light_color = theme.get("fog_color", Color(0.82, 0.48, 0.2))
	environment.fog_density = float(theme.get("fog_density", 0.0022))
	environment.fog_aerial_perspective = 0.55
	environment.glow_enabled = false
	world.environment = environment
	_world_environment = world
	add_child(world)
	if _road_style_id != "alien_energy":
		_build_starfield()

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, 35, 0)
	if _road_style_id == "alien_energy":
		sun.light_color = Color(0.55, 0.75, 1.0)
		sun.light_energy = 0.65
	else:
		sun.light_color = theme.get("sun_color", Color(1.0, 0.82, 0.55))
		sun.light_energy = float(theme.get("sun_energy", 2.4))
	add_child(sun)

	_build_path_track()
	for zone in LevelConfig.JUNCTION_ZONES:
		_build_choice_gate(float(zone["distance"]), zone)
	_build_planet_surroundings(theme)
	_build_finish_gate()
	_apply_road_style_environment()


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
	var track_end := maxf(_path_length, TRACK_LENGTH) + 28.0
	var theme: Dictionary = LevelConfig.get_theme()
	var sand_mat: Material = kit.get("island", kit["shoulder"])
	if sand_mat == null:
		sand_mat = _make_material(theme.get("sand", Color(0.76, 0.43, 0.16)), Color(1.0, 0.55, 0.18), 0.1)

	# 连续挤出：托底 / 路肩 / 主路 / 描边 —— 不再用分段 Box/Plane，从根上消横缝
	_attach_path_strip(0.0, track_end, 21.0, GROUND_Y - 0.14, sand_mat, 2.5, 0.0, false)
	_attach_path_strip(0.0, track_end, 9.2, lane_y - 0.012, kit["shoulder"], 2.0, 0.0, true)
	var road_half := 6.0 if _road_style_id == "holographic" else (5.9 if _road_style_id == "alien_energy" else 6.3)
	_attach_path_strip(0.0, track_end, road_half, lane_y, kit["road"], 1.75, 0.0, true)
	# 紫/能量描边：贴在路缘的细条带
	var curb_half := 0.07
	var curb_lat := road_half - 0.02
	_attach_path_strip(0.0, track_end, curb_half, lane_y + 0.012, kit["curb"], 1.75, -curb_lat, true)
	_attach_path_strip(0.0, track_end, curb_half, lane_y + 0.012, kit["curb"], 1.75, curb_lat, true)
	if _road_style_id == "holographic" or _road_style_id == "energy_neon":
		_attach_path_strip(0.0, track_end, 0.045, lane_y + 0.01, kit["curb"], 1.75, -(curb_lat + 0.12), true)
		_attach_path_strip(0.0, track_end, 0.045, lane_y + 0.01, kit["curb"], 1.75, curb_lat + 0.12, true)

	_build_start_pad(kit["road"], kit["shoulder"], kit["curb"], kit["line"], kit["post"], lane_y)
	for zone in LevelConfig.JUNCTION_ZONES:
		_build_fork_branch_roads(zone, kit["road"], kit["shoulder"], kit["curb"], kit["line"], kit["island"], lane_y)


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
		for zone in LevelConfig.JUNCTION_ZONES:
			var gs := float(zone["distance"])
			var ge := gs + float(zone.get("length", 70.0))
			gaps.append(Vector2(gs, ge))
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
	var uv_scale := 0.08
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
				"shoulder": _make_material(theme.get("sand", Color(0.76, 0.43, 0.16)), Color(1.0, 0.55, 0.18), 0.1),
				"curb": _make_material(Color(0.12, 0.06, 0.16), Color(0.4, 0.2, 0.48), 0.4),
				"line": _make_material(Color(0.08, 0.16, 0.18), Color(0.3, 0.65, 0.7), 0.55),
				"post": _make_material(Color(0.06, 0.05, 0.1), Color(0.4, 0.25, 0.5), 0.35),
				"island": _make_material(theme.get("sand", Color(0.76, 0.43, 0.16)), Color(1.0, 0.55, 0.18), 0.1),
			}
		"alien_energy":
			return {
				"road": _make_alien_energy_road_material(),
				"shoulder": _make_material(Color(0.03, 0.07, 0.11), Color(0.2, 0.55, 0.7), 0.2),
				"curb": _make_material(Color(0.05, 0.12, 0.16), Color(0.45, 0.9, 1.0), 1.1),
				"line": _make_material(Color(0.08, 0.16, 0.22), Color(0.4, 0.85, 1.0), 0.7),
				"post": _make_material(Color(0.04, 0.08, 0.12), Color(0.35, 0.8, 1.0), 0.45),
				"island": _make_material(Color(0.02, 0.04, 0.07), Color(0.15, 0.4, 0.55), 0.12),
			}
		"energy_neon":
			return {
				"road": _make_energy_neon_road_material(),
				"shoulder": _make_material(Color(0.01, 0.02, 0.04), Color(0.05, 0.35, 0.5), 0.25),
				"curb": _make_material(Color(0.02, 0.08, 0.12), Color(0.25, 0.98, 1.0), 6.5),
				"line": _make_material(Color(0.05, 0.2, 0.28), Color(0.35, 1.0, 1.0), 4.0),
				"post": _make_material(Color(0.02, 0.03, 0.05), Color(1.0, 0.5, 0.15), 3.5),
				"island": _make_material(Color(0.02, 0.03, 0.05), Color(0.1, 0.4, 0.55), 0.2),
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
		_:
			return {
				"road": _make_material(theme.get("road", Color(0.32, 0.34, 0.32)), Color(0.72, 0.63, 0.42), 0.08),
				"shoulder": _make_material(theme.get("shoulder", Color(0.78, 0.44, 0.15)), Color(1.0, 0.62, 0.2), 0.45),
				"curb": _make_material(theme.get("curb", Color(0.95, 0.67, 0.25)), Color(1.0, 0.74, 0.28), 1.2),
				"line": _make_material(theme.get("lane_line", Color(1.0, 0.86, 0.42)), Color(1.0, 0.78, 0.28), 2.0),
				"post": _make_material(Color(0.18, 0.18, 0.16), Color(0.85, 0.62, 0.34), 0.35),
				"island": _make_material(theme.get("sand", Color(0.72, 0.42, 0.16)), Color(1.0, 0.55, 0.2), 0.12),
			}


func _make_alien_energy_road_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = ROAD_ALIEN_ENERGY_SHADER
	mat.set_shader_parameter("base_color", Color(0.035, 0.08, 0.125))
	mat.set_shader_parameter("vein_color", Color(0.55, 0.9, 1.0))
	mat.set_shader_parameter("particle_color", Color(0.4, 0.96, 1.0))
	mat.set_shader_parameter("roughness_val", 0.4)
	mat.set_shader_parameter("metallic_val", 0.1)
	mat.set_shader_parameter("vein_energy", 1.05)
	mat.set_shader_parameter("particle_energy", 0.75)
	mat.set_shader_parameter("flow_speed", 0.5)
	mat.set_shader_parameter("detail_scale", 0.13)
	return mat


func _make_holographic_road_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = ROAD_HOLOGRAPHIC_SHADER
	var road_tex := load("res://assets/maps/route_levels/runner_60s/holographic_road_topdown.png") as Texture2D
	if road_tex:
		mat.set_shader_parameter("road_tex", road_tex)
	mat.set_shader_parameter("base_color", Color(0.04, 0.08, 0.1))
	mat.set_shader_parameter("plasma_color", Color(0.25, 0.55, 0.6))
	mat.set_shader_parameter("circuit_color", Color(0.32, 0.65, 0.68))
	mat.set_shader_parameter("edge_color", Color(0.45, 0.22, 0.5))
	mat.set_shader_parameter("roughness_val", 0.48)
	mat.set_shader_parameter("metallic_val", 0.08)
	mat.set_shader_parameter("tex_blend", 0.4)
	mat.set_shader_parameter("tex_darken", 0.26)
	mat.set_shader_parameter("plasma_energy", 0.5)
	mat.set_shader_parameter("flow_energy", 0.35)
	mat.set_shader_parameter("wave_speed", 0.5)
	mat.set_shader_parameter("scroll_speed", 0.05)
	mat.set_shader_parameter("road_half_width", 6.0)
	return mat


func _make_energy_neon_road_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = ROAD_ENERGY_NEON_SHADER
	mat.set_shader_parameter("base_color", Color(0.008, 0.012, 0.025))
	mat.set_shader_parameter("vein_color", Color(0.25, 0.96, 1.0))
	mat.set_shader_parameter("seam_color", Color(1.0, 0.52, 0.18))
	mat.set_shader_parameter("roughness_val", 0.24)
	mat.set_shader_parameter("metallic_val", 0.06)
	mat.set_shader_parameter("vein_energy", 5.2)
	mat.set_shader_parameter("seam_energy", 2.4)
	mat.set_shader_parameter("scroll_speed", 0.07)
	mat.set_shader_parameter("crack_scale", 0.11)
	return mat


func _apply_road_style_environment() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	var theme: Dictionary = LevelConfig.get_theme()
	match _road_style_id:
		"holographic":
			env.ambient_light_color = Color(0.16, 0.15, 0.14)
			env.ambient_light_energy = 0.85
			env.fog_light_color = Color(0.55, 0.4, 0.25)
			env.fog_density = 0.0017
			env.glow_enabled = true
			env.glow_intensity = 0.22
			env.glow_strength = 0.75
			env.glow_bloom = 0.06
			env.glow_hdr_threshold = 1.05
		"alien_energy":
			env.ambient_light_color = Color(0.06, 0.1, 0.16)
			env.ambient_light_energy = 0.35
			env.fog_light_color = Color(0.02, 0.04, 0.08)
			env.fog_density = 0.0028
			env.glow_enabled = true
			env.glow_intensity = 0.28
			env.glow_strength = 0.9
			env.glow_bloom = 0.12
			env.glow_hdr_threshold = 0.85
		"energy_neon":
			# 压掉沙漠橙雾，否则再好的黑轨也会被环境光染成橙水
			env.ambient_light_color = Color(0.12, 0.18, 0.28)
			env.ambient_light_energy = 0.55
			env.fog_light_color = Color(0.05, 0.08, 0.14)
			env.fog_density = 0.0014
			env.glow_enabled = true
			env.glow_intensity = 0.85
			env.glow_strength = 1.15
			env.glow_bloom = 0.4
			env.glow_hdr_threshold = 0.55
		"void_crystal":
			env.ambient_light_color = Color(0.16, 0.12, 0.28)
			env.ambient_light_energy = 0.7
			env.fog_light_color = Color(0.1, 0.06, 0.18)
			env.fog_density = 0.0016
			env.glow_enabled = true
			env.glow_intensity = 0.55
			env.glow_strength = 1.05
			env.glow_bloom = 0.3
			env.glow_hdr_threshold = 0.65
		_:
			env.ambient_light_color = theme.get("ambient", Color(0.92, 0.68, 0.44))
			env.ambient_light_energy = float(theme.get("ambient_energy", 1.35))
			env.fog_light_color = theme.get("fog_color", Color(0.82, 0.48, 0.2))
			env.fog_density = float(theme.get("fog_density", 0.0022))
			env.glow_enabled = false
			env.glow_intensity = 0.0
			env.glow_bloom = 0.0


func _is_in_fork_main_gap(distance: float) -> bool:
	for zone in LevelConfig.JUNCTION_ZONES:
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
	var thin_energy := _road_style_id == "alien_energy" or _road_style_id == "holographic"
	var neon_edge := _road_style_id == "energy_neon" or _road_style_id == "holographic"
	var road_w := 12.0 if _road_style_id == "holographic" else (11.8 if _road_style_id == "alien_energy" else 12.6)
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
	var branch_half := 6.3
	# 中岛托底
	_attach_fork_center_island(zone, island_material, lane_y - 0.02)
	for side_f in [-1.0, 1.0]:
		var side: float = float(side_f)
		_attach_fork_branch_strip(start, length, spread, side, branch_half + 1.6, lane_y - 0.01, shoulder_material, 1.8)
		_attach_fork_branch_strip(start, length, spread, side, branch_half, lane_y + 0.01, road_material, 1.6)
		_attach_fork_branch_strip(start, length, spread, side, 0.07, lane_y + 0.02, curb_material, 1.6, branch_half - 0.05)
		_attach_fork_branch_strip(start, length, spread, side, 0.07, lane_y + 0.02, curb_material, 1.6, -(branch_half - 0.05))
	_build_fork_entry_wedge(zone, curb_material, lane_y)


func _attach_fork_center_island(zone: Dictionary, material: Material, y: float) -> void:
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	var step := 2.0
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start
	while d <= start + length + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		if envelope > 0.25:
			var half_w := maxf(spread * envelope * 0.55 - 2.0, 1.2)
			pts.append(_path_strip_point(d, half_w, y, 0.0))
		elif not pts.is_empty():
			break
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
	extra_lateral: float = 0.0
) -> void:
	if material == null:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start
	while d <= start + length + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		var lateral := side * spread * envelope + extra_lateral * side
		var sample := _sample_path(d)
		var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral
		# 岔路朝向略偏：用相邻采样估 right
		var t2 := clampf(t + step / maxf(length, 0.001), 0.0, 1.0)
		var offset := spread * envelope
		var offset2 := spread * _fork_envelope(t2)
		var d_lat := ((offset2 - offset) * side) / maxf(step, 0.001)
		var branch_yaw := float(sample["yaw"]) + atan(d_lat) * 0.85
		var branch_right := Vector3(cos(branch_yaw), 0.0, -sin(branch_yaw))
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
	var start := float(zone["distance"])
	var sample := _sample_path(start + 6.0)
	var accent_l := _make_material(Color(0.12, 0.45, 0.28), Color(0.25, 0.95, 0.55), 1.8)
	var accent_r := _make_material(Color(0.45, 0.22, 0.08), Color(1.0, 0.62, 0.2), 1.8)
	for side_data in [[-1.0, accent_l], [1.0, accent_r]]:
		var side: float = float(side_data[0])
		var mat: Material = side_data[1]
		var wedge := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(2.4, 0.08, 5.5)
		mesh.material = mat
		wedge.mesh = mesh
		wedge.position = sample["pos"] + (sample["right"] as Vector3) * (3.2 * side) + Vector3(0.0, lane_y + 0.06, 0.0)
		wedge.rotation.y = float(sample["yaw"]) + (-0.38 if side < 0.0 else 0.38)
		_attach_road(wedge)


func _build_start_pad(
	road_material: Material,
	shoulder_material: Material,
	curb_material: Material,
	line_material: Material,
	post_material: Material,
	lane_y: float
) -> void:
	var start_center_z := START_PAD_LENGTH * 0.5
	var foundation := MeshInstance3D.new()
	foundation.name = "StartSandFoundation"
	var foundation_mesh := BoxMesh.new()
	foundation_mesh.size = Vector3(58.0, 0.36, START_PAD_LENGTH + 8.0)
	var theme: Dictionary = LevelConfig.get_theme() if LevelConfig != null and LevelConfig.has_method("get_theme") else {}
	var foundation_mat := (
		_make_material(theme.get("sand", Color(0.76, 0.43, 0.16)), Color(1.0, 0.55, 0.18), 0.08)
		if _road_style_id == "holographic"
		else (
			_make_material(Color(0.02, 0.04, 0.07), Color(0.15, 0.45, 0.6), 0.15)
			if _road_style_id == "alien_energy"
			else (
				_make_material(Color(0.03, 0.06, 0.1), Color(0.15, 0.8, 1.0), 0.35)
				if _road_style_id == "energy_neon"
				else _make_material(Color(0.78, 0.45, 0.17), Color(1.0, 0.55, 0.18), 0.16)
			)
		)
	)
	foundation_mesh.material = foundation_mat
	foundation.mesh = foundation_mesh
	foundation.position = Vector3(0.0, lane_y - 0.18, start_center_z)
	_attach_road(foundation)

	var road := MeshInstance3D.new()
	road.name = "StartRoadApron"
	var start_w := 12.0 if _road_style_id == "holographic" else 12.6
	var road_mesh := PlaneMesh.new()
	road_mesh.size = Vector2(start_w, START_PAD_LENGTH + 2.0)
	road_mesh.orientation = PlaneMesh.FACE_Y
	road_mesh.material = road_material
	road.mesh = road_mesh
	road.position = Vector3(0.0, lane_y, start_center_z)
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(road)

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

	var curb_xs: Array = [-start_w * 0.5, start_w * 0.5]
	for x in curb_xs:
		var curb := MeshInstance3D.new()
		var curb_mesh := BoxMesh.new()
		if _road_style_id == "holographic":
			curb_mesh.size = Vector3(0.12, 0.04, START_PAD_LENGTH + 2.0)
		else:
			curb_mesh.size = Vector3(0.16, 0.12, START_PAD_LENGTH + 2.0)
		curb_mesh.material = curb_material
		curb.mesh = curb_mesh
		curb.position = Vector3(x, lane_y + (0.02 if _road_style_id == "holographic" else 0.06), start_center_z)
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
	if _road_style_id == "alien_energy":
		# 提示词要求：孤立能量轨，无沙漠/建筑环绕
		_build_void_surroundings_for_energy_road()
		return
	match String(theme.get("surroundings", "desert_crystal")):
		"industrial_ruin":
			_build_industrial_surroundings(theme)
		"savanna":
			_build_savanna_surroundings(theme)
		_:
			_build_desert_surroundings(theme)
	_build_path_side_dressing(theme)


func _build_void_surroundings_for_energy_road() -> void:
	# 仅极暗地面托底，突出单一连续跑道
	var mat := _make_material(Color(0.015, 0.02, 0.035), Color(0.05, 0.12, 0.2), 0.05)
	var d := 0.0
	var track_end := maxf(_path_length, TRACK_LENGTH) + 40.0
	while d < track_end:
		var sample := _sample_path(d)
		var pad := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(48.0, 0.05, 20.0)
		mesh.material = mat
		pad.mesh = mesh
		pad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pad.position = (sample["pos"] as Vector3) + Vector3(0.0, GROUND_Y - 0.28, 0.0)
		pad.rotation.y = float(sample["yaw"])
		track_root.add_child(pad)
		d += 18.0


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


func _build_desert_surroundings(theme: Dictionary = {}) -> void:
	var sand_material := _make_material(theme.get("sand", Color(0.76, 0.43, 0.16)), Color(1.0, 0.55, 0.18), 0.18)
	var cracked_material := _make_material(Color(0.36, 0.27, 0.18), Color(0.18, 0.85, 1.0), 0.55)
	var silhouette_material := _make_material(Color(0.09, 0.075, 0.065), Color(0.45, 0.25, 0.12), 0.2)
	var crystal_material := _make_crystal_material(theme.get("crystal", Color(0.13, 0.62, 1.0)), Color(0.08, 0.9, 1.0))
	var segment_len := 96.0
	var segment_count := int(ceil((TRACK_LENGTH + 120.0) / segment_len))

	for segment_index in segment_count:
		var seg_z := -segment_index * segment_len - segment_len * 0.5
		for x in [-32.0, 32.0]:
			var sand := MeshInstance3D.new()
			var sand_mesh := BoxMesh.new()
			sand_mesh.size = Vector3(46.0, 0.08, segment_len + 0.5)
			sand_mesh.material = sand_material
			sand.mesh = sand_mesh
			sand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			sand.position = Vector3(x, GROUND_Y - 0.18, seg_z)
			track_root.add_child(sand)

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

	var sand_material := _make_material(theme.get("sand", Color(0.76, 0.43, 0.16)), Color(1.0, 0.55, 0.18), 0.14)
	var rng := RandomNumberGenerator.new()
	var planet_key := "runner"
	if LevelConfig.has_method("get_planet_id"):
		planet_key = String(LevelConfig.get_planet_id())
	rng.seed = hash(planet_key + "_side_dressing")

	var track_end := maxf(_path_length, TRACK_LENGTH) + 48.0
	var d := 12.0
	while d < track_end:
		var fork_push := 12.0 if _is_in_fork_main_gap(d) else 0.0
		for side_f in [-1.0, 1.0]:
			var side: float = float(side_f)
			var lateral: float = side * (rng.randf_range(17.5, 24.0) + fork_push)
			_place_path_sand_ribbon(d, lateral, rng.randf_range(10.0, 16.0), 18.0, sand_material)
		d += 28.0

	if not _side_prop_paths.is_empty():
		d = 28.0
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
	sand.position.y = GROUND_Y - 0.17
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
		Vector3.ZERO
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
	var segment_count := int(ceil((TRACK_LENGTH + 120.0) / segment_len))
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
	var segment_count := int(ceil((TRACK_LENGTH + 120.0) / segment_len))
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
	key.light_energy = 1.35
	key.omni_range = 5.5
	key.shadow_enabled = false
	player.add_child(key)
	var rim := OmniLight3D.new()
	rim.name = "PlayerRunwayRim"
	rim.position = Vector3(0.0, 0.35, 0.8)
	rim.light_color = Color(0.45, 0.85, 0.95) if _road_style_id == "holographic" else Color(0.7, 0.85, 1.0)
	rim.light_energy = 0.85 if _road_style_id == "holographic" else 0.55
	rim.omni_range = 4.2
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

	var model_yaw := _player_yaw_degrees("model_yaw", PLAYER_MODEL_YAW)
	var slide_yaw := _player_yaw_degrees("slide_yaw", PLAYER_SLIDE_MODEL_YAW)
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

		push_warning("Cyberpunk armor player has no usable run animation; using pose models instead.")
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


func _get_slide_obstacle_scene(index: int) -> PackedScene:
	if not _slide_obstacle_paths.is_empty():
		return _load_runner_scene(_slide_obstacle_paths[index % _slide_obstacle_paths.size()])
	return _slide_obstacle_scene


func _get_jump_obstacle_scene(index: int) -> PackedScene:
	if _jump_obstacle_paths.is_empty():
		return null
	return _load_runner_scene(_jump_obstacle_paths[index % _jump_obstacle_paths.size()])


func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root
	for child in root.find_children("*", "AnimationPlayer", true, false):
		return child as AnimationPlayer
	return null


func _configure_player_animations() -> void:
	if not player_animation_player:
		push_warning("Cyberpunk armor player has no AnimationPlayer.")
		return
	for anim_name in [ANIMATED_PLAYER_IDLE_ANIM, ANIMATED_PLAYER_RUN_ANIM]:
		if player_animation_player.has_animation(anim_name):
			player_animation_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	if player_animation_player.has_animation(ANIMATED_PLAYER_CELEBRATE_ANIM):
		player_animation_player.get_animation(ANIMATED_PLAYER_CELEBRATE_ANIM).loop_mode = Animation.LOOP_NONE


func _play_player_animation(state_name: String) -> void:
	if not player_animation_player:
		return
	var anim_name := ANIMATED_PLAYER_IDLE_ANIM
	match state_name:
		"run", "slide", "jump", "landing":
			anim_name = ANIMATED_PLAYER_RUN_ANIM
		"celebrate":
			anim_name = ANIMATED_PLAYER_CELEBRATE_ANIM
	if player_animation_name == anim_name:
		return
	if not player_animation_player.has_animation(anim_name):
		push_warning("Missing player animation: %s" % anim_name)
		return
	player_animation_name = anim_name
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


func _set_player_intro_facing(_enabled: bool) -> void:
	if player_body == null:
		return
	# 开场与跑酷全程保持背对镜头，沿跑道 -Z 方向
	player_body.rotation_degrees.y = 0.0


func _add_scaled_model_visual(
	parent: Node3D,
	scene: PackedScene,
	model_name: String,
	target_height: float,
	yaw_degrees: float = 0.0,
	local_position: Vector3 = Vector3.ZERO
) -> Node3D:
	if not scene:
		return _add_missing_model_visual(parent, model_name, target_height, yaw_degrees, local_position)

	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees

	var bounds := _compute_node_aabb(model)
	if bounds.size.y <= 0.001:
		push_warning("%s bounds invalid, leaving model at source scale." % model_name)
		return model

	model.scale = Vector3.ONE * (target_height / bounds.size.y)
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
	for item in LevelConfig.build_obstacles():
		_register_obstacle(item)
	obstacles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)
	_obstacle_scan_index = 0

	var coin_index := 0
	for dist in LevelConfig.build_coin_distances():
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
			"collected": false,
		})
		coin_index += 1
	total_collectibles = collectibles.size()


func _register_obstacle(item: Dictionary) -> Node3D:
	var obstacle_type := String(item["type"])
	var lane: int = int(item.get("lane", 0))
	var dist: float = float(item["distance"])
	var layer: int = 0
	var node := _make_obstacle(lane, dist, obstacle_type, layer, item)
	var default_clear := 1.55 if obstacle_type in ["slide", "high_bar"] else 1.35
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
			_build_low_barrier(root)
		"train", "train_moving":
			_build_train(root, obstacle_type == "train_moving")
		"block_left":
			_build_lane_block(root, "left")
		"block_right":
			_build_lane_block(root, "right")
		"ramp":
			_build_ramp(root, int(item.get("target_layer", layer + 1)))
		"turn_left", "turn_right":
			_build_turn_sign(root, obstacle_type)
		_:
			_build_low_barrier(root)

	return root


func _build_low_barrier(root: Node3D) -> void:
	var scene_index := root.get_index() % maxi(_jump_obstacle_paths.size(), 1)
	if not _jump_obstacle_paths.is_empty():
		var asset_path := _jump_obstacle_paths[scene_index % _jump_obstacle_paths.size()]
		if "热浪" in asset_path:
			root.set_meta("heat_hazard", true)
	var visual := _add_scaled_model_visual(
		root,
		_get_jump_obstacle_scene(scene_index),
		"JumpObstacleModel",
		1.05,
		180.0,
		Vector3(0.0, 0.0, 0.0)
	)
	visual.rotation_degrees.y += 8.0 if scene_index == 0 else -8.0


func _build_high_bar(root: Node3D) -> void:
	# 锈蚀水管：比跑道（12.6）略宽，贴地横跨，可滑铲或跳过
	_add_road_span_gate(root, "SlideObstacleModel", _get_slide_obstacle_scene(0), 1.95, 14.8)


func _build_train(root: Node3D, moving: bool) -> void:
	var visual := _add_slide_obstacle_visual(root, "SlideRoadBlockAsset", Vector3.ZERO, 2.35)
	if moving:
		visual.rotation_degrees.y += 6.0


func _build_lane_block(root: Node3D, side: String) -> void:
	var blocked_x := [-LANE_WIDTH, 0.0] if side == "left" else [0.0, LANE_WIDTH]
	for i in blocked_x.size():
		var visual := _add_slide_obstacle_visual(root, "LaneBlockAsset_%d" % i, Vector3(blocked_x[i], 0.0, 0.0), 2.15)
		visual.position.z += -0.35 if i == 0 else 0.35


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
	var placed := _world_on_path(distance, float(lane) * LANE_WIDTH, y)
	collectible.position = placed["pos"]
	collectible.rotation.y = float(placed["yaw"])
	return collectible


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
	danger_vignette.visible = CHASER_ENABLED
	ui.add_child(danger_vignette)

	var chaser_hint_wrap := MarginContainer.new()
	chaser_hint_wrap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	chaser_hint_wrap.offset_left = -156.0
	chaser_hint_wrap.offset_top = 132.0
	chaser_hint_wrap.offset_right = -28.0
	chaser_hint_wrap.offset_bottom = 248.0
	chaser_hint_wrap.visible = CHASER_ENABLED
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
	time_label.text = "时间 %0.1f / 60.0" % elapsed
	var speed_text := "速度 %0.1f m/s" % (current_speed * speed_penalty_mult)
	if speed_penalty_timer > 0.0:
		speed_text += " (减速)"
	speed_label.text = speed_text

	var phase: Dictionary = LevelConfig.phase_at(track_distance)
	phase_label.text = "阶段 %s · %s" % [phase["name"], phase["hint"]]
	cargo_label.text = "货物 %s  完整度 %0.0f%%" % [String(mission.get("cargo_name", "物资")), cargo_integrity]
	score_label.text = "星火币 %d" % run_score
	layer_label.text = "地图 %s" % LevelConfig.MAP_NAME
	collectible_label.text = "星火币 %d / %d" % [collected_count, total_collectibles]

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

	camera_pivot.position = Vector3(shake_offset.x, CAMERA_HEIGHT + slide_offset, cam_behind) + shake_offset * 0.35
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
		var run_step := int(floor(elapsed * 8.0)) % 2
		_set_player_pose("run_left" if run_step == 0 else "run_right")

	var x_error := target_lane_x - current_lateral
	body_tilt = lerpf(body_tilt, clampf(-x_error * 0.18, -0.45, 0.45), 1.0 - exp(-10.0 * delta))
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
	var hearth_placed := _world_on_path(TRACK_LENGTH + 26.0, 0.0, GROUND_Y)
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
	var gate_placed := _world_on_path(TRACK_LENGTH, 0.0, 2.5)
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
		star.position = Vector3(randf_range(-60.0, 60.0), randf_range(7.0, 26.0), randf_range(-TRACK_LENGTH, 20.0))
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
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
