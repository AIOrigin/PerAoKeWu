class_name EnergyChaserController
extends Node3D

## Nulltide Wraith：使用桌面导入的异能怪 GLB（开场 angry / 跑步 / 抓到比心）。

enum ChaseState { DORMANT, WARNING, CHASE, CRITICAL, CAPTURED }
enum VisualPose { INTRO, RUN, CAPTURE }

signal pressure_changed(pressure: float, normalized_pressure: float)
signal chase_state_changed(new_state: ChaseState)
signal player_captured

const WRAITH_BASE_PATH := "res://assets/maps/route_levels/runner_60s/relay_final/wraith/wraith_base.glb"
const WRAITH_INTRO_PATH := "res://assets/maps/route_levels/runner_60s/relay_final/wraith/wraith_intro_angry.glb"
const WRAITH_RUN_PATH := "res://assets/maps/route_levels/runner_60s/relay_final/wraith/wraith_run.glb"
const WRAITH_CAPTURE_PATH := "res://assets/maps/route_levels/runner_60s/relay_final/wraith/wraith_capture_heart.glb"

@export_group("References")
@export var runner: Node3D
@export var visual_root: Node3D
@export var edge_particles: GPUParticles3D
@export var spark_particles: GPUParticles3D
@export var chase_audio: AudioStreamPlayer3D
@export var screen_shader: ShaderMaterial

@export_group("Distance")
@export var max_gap: float = 28.0
@export var min_gap: float = 1.6
@export var visual_height: float = 0.05
@export var follow_smoothing: float = 5.5
@export var preview_gap: float = -1.0
@export var preview_boost: float = 0.0
## 开场反打：锁定站位，禁止平滑飘入
var intro_position_locked: bool = false

@export_group("Model")
@export var model_height: float = 2.2
## GLB 多为 +Z 朝前；节点用 -Z 对准 runner，故补 180°
@export var model_yaw_deg: float = 180.0
## 捕获演出时由 runner 驱动：比心阶段放大，镜头需仍能框住全身
@export var capture_display_boost: float = 1.0
@export var hover_amplitude: float = 0.03
@export var hover_speed: float = 1.05

@export_group("Pressure")
@export var max_pressure: float = 100.0
@export var initial_pressure: float = 18.0
@export var passive_relief_per_second: float = 0.8
@export var warning_threshold: float = 20.0
@export var chase_threshold: float = 50.0
@export var critical_threshold: float = 75.0
@export var hit_pressure: float = 18.0
@export var severe_hit_pressure: float = 28.0
@export var perfect_dodge_relief: float = 8.0
@export var stabilizer_relief: float = 15.0
@export var clean_play_delay: float = 6.0
@export var clean_play_relief_per_second: float = 1.5

@export_group("Quality")
@export var low_fx: bool = false

var pressure: float = 0.0
var state: ChaseState = ChaseState.DORMANT
var is_active: bool = false
var _clean_timer: float = 0.0
var _captured_emitted: bool = false
var _pulse: float = 0.0
var _flash_t: float = 0.0
var _elapsed: float = 0.0

var _chase_target: Vector3 = Vector3.ZERO
var _chase_yaw: float = 0.0
var _has_chase_target: bool = false
var _last_root_pos: Vector3 = Vector3.ZERO
var _yaw_rate: float = 0.0
var _bank_roll: float = 0.0

var _wraith_root: Node3D
var _hover_root: Node3D
var _pose_models: Dictionary = {} # VisualPose -> Node3D
var _pose_players: Dictionary = {} # VisualPose -> AnimationPlayer
var _current_pose: VisualPose = VisualPose.INTRO
var _chase_light: OmniLight3D
## 兼容旧字段（runner 可能仍引用）
var tail_drag_deg: float = 8.0
var yaw_amplitude_deg: float = 1.5
var yaw_speed: float = 0.45


func _ready() -> void:
	pressure = initial_pressure
	if visual_root == null:
		_build_default_visuals()
	_apply_visuals()
	set_process(true)


func _process(delta: float) -> void:
	if not visible and preview_gap < 0.0 and state != ChaseState.CAPTURED:
		return
	_elapsed += delta
	_pulse = fmod(_pulse + delta * lerpf(1.0, 2.6, get_normalized_pressure()), TAU)
	if _flash_t > 0.0:
		_flash_t = maxf(_flash_t - delta, 0.0)
	_update_follow_motion(delta)
	_animate_hover(delta)
	_apply_visuals()
	_keep_pose_anim_alive()


func _physics_process(delta: float) -> void:
	if not is_active or state == ChaseState.CAPTURED:
		return
	var relief := passive_relief_per_second
	_clean_timer += delta
	if _clean_timer >= clean_play_delay:
		relief += clean_play_relief_per_second
	if preview_gap < 0.0:
		pressure = maxf(0.0, pressure - relief * delta)
	_update_state()


func set_chase_target(world_pos: Vector3, yaw: float) -> void:
	_chase_target = world_pos
	_chase_yaw = yaw
	if not _has_chase_target:
		global_position = world_pos
		rotation = Vector3(0.0, yaw, 0.0)
		_last_root_pos = world_pos
		_has_chase_target = true


func snap_chase_target(world_pos: Vector3, yaw: float) -> void:
	_chase_target = world_pos
	_chase_yaw = yaw
	global_position = world_pos
	rotation = Vector3(0.0, yaw, 0.0)
	_last_root_pos = world_pos
	_has_chase_target = true


func start_chase(start_pressure: float = -1.0) -> void:
	is_active = true
	_captured_emitted = false
	_clean_timer = 0.0
	preview_gap = -1.0
	preview_boost = 0.0
	var p := initial_pressure if start_pressure < 0.0 else start_pressure
	pressure = clampf(p, 0.0, max_pressure)
	_update_state()
	play_pose(VisualPose.RUN, true)
	_apply_visuals()


func stop_chase() -> void:
	is_active = false
	pressure = 0.0
	state = ChaseState.DORMANT
	_clean_timer = 0.0
	_captured_emitted = false
	preview_gap = -1.0
	preview_boost = 0.0
	_flash_t = 0.0
	_has_chase_target = false
	play_pose(VisualPose.INTRO, false)
	_apply_visuals()


func begin_visual_preview(gap_m: float = 14.0) -> void:
	is_active = true
	_captured_emitted = false
	_clean_timer = 0.0
	pressure = 0.0
	state = ChaseState.DORMANT
	preview_gap = gap_m
	preview_boost = 1.0
	_update_state()
	play_pose(VisualPose.INTRO, true)
	_apply_visuals()


func pulse_flash(duration: float = 0.4) -> void:
	_flash_t = maxf(_flash_t, duration)


func play_capture_anim() -> void:
	play_pose(VisualPose.CAPTURE, true)


func set_capture_display_boost(boost: float) -> void:
	capture_display_boost = maxf(boost, 0.01)
	_apply_visuals()


func play_pose(pose: VisualPose, restart: bool = false) -> void:
	_current_pose = pose
	for key in _pose_models.keys():
		var node: Node3D = _pose_models[key] as Node3D
		if node != null and is_instance_valid(node):
			node.visible = int(key) == int(pose)
	var player: AnimationPlayer = _pose_players.get(pose) as AnimationPlayer
	if player == null:
		return
	var anim_name := _first_anim_name(player)
	if anim_name == "":
		return
	var loop := pose == VisualPose.RUN or pose == VisualPose.INTRO
	var anim := player.get_animation(anim_name)
	if anim != null:
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	if restart or player.current_animation != anim_name or not player.is_playing():
		player.play(anim_name)
		player.seek(0.0, true)


func shrink_visual_gap(ratio: float = 0.25) -> float:
	if preview_gap >= 0.0:
		preview_gap = -1.0
	var gap := get_visual_gap()
	var target := maxf(min_gap + 0.2, gap * (1.0 - clampf(ratio, 0.05, 0.8)))
	var span := maxf(max_gap - min_gap, 0.001)
	var normalized := clampf((max_gap - target) / span, 0.0, 1.0)
	pressure = clampf(normalized * max_pressure, 0.0, max_pressure)
	_clean_timer = 0.0
	_update_state()
	_apply_visuals()
	return get_visual_gap()


func add_pressure(amount: float) -> void:
	if not is_active or state == ChaseState.CAPTURED:
		return
	if preview_gap >= 0.0:
		return
	pressure = clampf(pressure + amount, 0.0, max_pressure)
	if amount > 0.0:
		_clean_timer = 0.0
	_update_state()
	_apply_visuals()


func reward_clean_play(amount: float = -1.0) -> void:
	var relief := perfect_dodge_relief if amount < 0.0 else absf(amount)
	add_pressure(-relief)


func notify_hit(severe: bool = false) -> void:
	add_pressure(severe_hit_pressure if severe else hit_pressure)


func notify_stabilizer() -> void:
	reward_clean_play(stabilizer_relief)


func get_visual_gap() -> float:
	if preview_gap >= 0.0:
		return preview_gap
	var normalized := pressure / maxf(max_pressure, 0.001)
	return lerpf(max_gap, min_gap, normalized)


func get_normalized_pressure() -> float:
	if preview_gap >= 0.0:
		return clampf(1.0 - (preview_gap - min_gap) / maxf(max_gap - min_gap, 0.001), 0.0, 1.0) * 0.22
	return pressure / maxf(max_pressure, 0.001)


func get_state_label() -> String:
	match state:
		ChaseState.DORMANT:
			return "潜伏"
		ChaseState.WARNING:
			return "警告"
		ChaseState.CHASE:
			return "追击"
		ChaseState.CRITICAL:
			return "临界"
		ChaseState.CAPTURED:
			return "捕获"
	return "潜伏"


func get_runner_forward() -> Vector3:
	if runner == null:
		return Vector3(0.0, 0.0, -1.0)
	return -runner.global_transform.basis.z.normalized()


func _update_state() -> void:
	var next_state := ChaseState.DORMANT
	if preview_gap >= 0.0:
		next_state = ChaseState.DORMANT
	elif pressure >= max_pressure - 0.001:
		next_state = ChaseState.CAPTURED
	elif pressure >= critical_threshold:
		next_state = ChaseState.CRITICAL
	elif pressure >= chase_threshold:
		next_state = ChaseState.CHASE
	elif pressure >= warning_threshold:
		next_state = ChaseState.WARNING
	else:
		next_state = ChaseState.DORMANT

	if next_state != state:
		state = next_state
		chase_state_changed.emit(state)

	if state == ChaseState.CAPTURED and not _captured_emitted:
		_captured_emitted = true
		is_active = false
		play_pose(VisualPose.CAPTURE, true)
		player_captured.emit()

	pressure_changed.emit(pressure, get_normalized_pressure())


func _update_follow_motion(delta: float) -> void:
	if not _has_chase_target:
		return
	if intro_position_locked:
		global_position = _chase_target
		rotation.y = _chase_yaw
		_yaw_rate = 0.0
		return
	var weight := 1.0 - exp(-follow_smoothing * delta)
	global_position = global_position.lerp(_chase_target, weight)
	var cur_yaw := rotation.y
	var dyaw := wrapf(_chase_yaw - cur_yaw, -PI, PI)
	var applied := dyaw * weight
	rotation.y = cur_yaw + applied
	_yaw_rate = lerpf(_yaw_rate, applied / maxf(delta, 0.001), clampf(delta * 8.0, 0.0, 1.0))


func _animate_hover(delta: float) -> void:
	if _hover_root == null:
		return
	if intro_position_locked:
		_hover_root.position.y = visual_height
		_hover_root.rotation = Vector3.ZERO
		_bank_roll = 0.0
		return
	_hover_root.position.y = visual_height + sin(_elapsed * hover_speed) * hover_amplitude
	# 朝向由节点 yaw 对准 runner，这里不再左右晃头把脸甩开
	_hover_root.rotation.y = 0.0
	var near_t := clampf((10.0 - get_visual_gap()) / 10.0, 0.0, 1.0)
	_hover_root.rotation.x = deg_to_rad(lerpf(0.0, 2.5, near_t))
	var bank_target := clampf(-_yaw_rate * 0.18, -0.12, 0.12)
	_bank_roll = lerpf(_bank_roll, bank_target, clampf(delta * 6.0, 0.0, 1.0))
	_hover_root.rotation.z = _bank_roll


func _keep_pose_anim_alive() -> void:
	var player: AnimationPlayer = _pose_players.get(_current_pose) as AnimationPlayer
	if player == null:
		return
	if _current_pose == VisualPose.CAPTURE:
		return
	if not player.is_playing():
		var anim_name := _first_anim_name(player)
		if anim_name != "":
			player.play(anim_name)


func _apply_visuals() -> void:
	var gap := get_visual_gap()
	var p := get_normalized_pressure()
	var boost := clampf(preview_boost, 0.0, 1.0)
	if intro_position_locked:
		boost = 0.0
	if boost > 0.01:
		p = maxf(p, lerpf(0.45, 0.65, boost))
		gap = minf(gap, lerpf(14.0, 9.0, boost))
	var flash := clampf(_flash_t / 0.4, 0.0, 1.0)
	visible = is_active or state == ChaseState.CAPTURED or preview_gap >= 0.0
	if visual_root == null:
		return
	visual_root.visible = visible

	var body_scale := 1.0
	if gap > 20.0:
		body_scale = lerpf(1.0, 0.92, clampf((gap - 20.0) / 8.0, 0.0, 1.0))
	elif gap > 10.0:
		body_scale = lerpf(1.06, 1.0, (gap - 10.0) / 10.0)
	else:
		body_scale = lerpf(1.14, 1.06, gap / 10.0)
	if state == ChaseState.CAPTURED:
		body_scale = maxf(1.0, capture_display_boost)
	body_scale *= lerpf(1.0, 1.06, boost) * (1.0 + flash * 0.04)
	if _wraith_root != null:
		_wraith_root.scale = Vector3.ONE * body_scale

	if edge_particles != null:
		edge_particles.emitting = false
	if spark_particles != null:
		spark_particles.emitting = false

	if _chase_light != null:
		_chase_light.visible = not low_fx and visible
		_chase_light.light_energy = lerpf(0.35, 1.05, p) + flash * 0.7 + boost * 0.35
		_chase_light.omni_range = lerpf(5.0, 8.5, boost)
	if chase_audio != null:
		chase_audio.volume_db = lerpf(-32.0, -6.0, p)
	if screen_shader != null:
		var screen_p := 0.0
		if boost < 0.01:
			if gap < 10.0:
				screen_p = lerpf(0.0, 0.8, (10.0 - gap) / 10.0)
			elif p >= 0.5:
				screen_p = lerpf(0.0, p, (p - 0.5) / 0.5) * 0.5
			screen_p = maxf(screen_p, flash * 0.3)
		screen_shader.set_shader_parameter("chase_strength", screen_p)
		screen_shader.set_shader_parameter("chase_state", float(state))


func _build_default_visuals() -> void:
	visual_root = Node3D.new()
	visual_root.name = "NulltideWraithVisual"
	add_child(visual_root)

	_wraith_root = Node3D.new()
	_wraith_root.name = "WraithRoot"
	visual_root.add_child(_wraith_root)

	_hover_root = Node3D.new()
	_hover_root.name = "HoverRoot"
	_wraith_root.add_child(_hover_root)

	_add_pose_model(VisualPose.INTRO, WRAITH_INTRO_PATH, WRAITH_BASE_PATH)
	_add_pose_model(VisualPose.RUN, WRAITH_RUN_PATH, WRAITH_BASE_PATH)
	_add_pose_model(VisualPose.CAPTURE, WRAITH_CAPTURE_PATH, WRAITH_BASE_PATH)

	_chase_light = OmniLight3D.new()
	_chase_light.name = "VoidLight"
	_chase_light.light_color = Color(0.42, 0.22, 0.72)
	_chase_light.light_energy = 0.55
	_chase_light.omni_range = 6.5
	_chase_light.shadow_enabled = false
	_chase_light.position = Vector3(0.0, 1.4, 0.35)
	_hover_root.add_child(_chase_light)

	chase_audio = AudioStreamPlayer3D.new()
	chase_audio.name = "ChaseAudio3D"
	chase_audio.max_distance = 42.0
	visual_root.add_child(chase_audio)

	if low_fx and _chase_light != null:
		_chase_light.visible = false

	play_pose(VisualPose.INTRO, true)


func _add_pose_model(pose: VisualPose, path: String, fallback_path: String = "") -> void:
	var node := _instantiate_glb(path)
	if node == null and fallback_path != "":
		node = _instantiate_glb(fallback_path)
	if node == null:
		push_warning("Nulltide wraith model missing: %s" % path)
		return
	node.name = "Pose_%d" % int(pose)
	_hover_root.add_child(node)
	_fit_model_height(node, model_height)
	node.rotation_degrees.y = model_yaw_deg
	node.visible = false
	_disable_shadows(node)
	_sanitize_root_motion(node)
	_pose_models[pose] = node
	var ap := _find_animation_player(node)
	if ap != null:
		_pose_players[pose] = ap


func _instantiate_glb(path: String) -> Node3D:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		var packed := load(path) as PackedScene
		if packed != null:
			return packed.instantiate() as Node3D
	var abs_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(abs_path):
		return null
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file(abs_path, state)
	if err != OK:
		push_warning("GLTF load failed (%s): %s" % [str(err), path])
		return null
	var generated := doc.generate_scene(state)
	return generated as Node3D


func _fit_model_height(root: Node3D, target_h: float) -> void:
	if root == null:
		return
	root.scale = Vector3.ONE
	root.position = Vector3.ZERO
	var aabb := _collect_local_aabb(root)
	var h := maxf(aabb.size.y, 0.05)
	var s := target_h / h
	root.scale = Vector3.ONE * s
	# 贴地：缩放后把原 AABB 底边放到原点
	root.position.y = -aabb.position.y * s


func _collect_local_aabb(root: Node3D) -> AABB:
	var merged := AABB()
	var has := false
	for node in root.find_children("*", "VisualInstance3D", true, false):
		var vi := node as VisualInstance3D
		if vi == null:
			continue
		var local := vi.get_aabb()
		var rel := Transform3D.IDENTITY
		var cur: Node = vi
		while cur != null and cur != root:
			if cur is Node3D:
				rel = (cur as Node3D).transform * rel
			cur = cur.get_parent()
		var world_aabb := _xform_aabb(local, rel)
		if not has:
			merged = world_aabb
			has = true
		else:
			merged = merged.merge(world_aabb)
	if not has:
		return AABB(Vector3(-0.5, 0.0, -0.5), Vector3(1.0, 1.8, 1.0))
	return merged


func _collect_aabb(root: Node3D) -> AABB:
	return _collect_local_aabb(root)


func _xform_aabb(aabb: AABB, xf: Transform3D) -> AABB:
	var pts: Array[Vector3] = [
		aabb.position,
		aabb.position + Vector3(aabb.size.x, 0, 0),
		aabb.position + Vector3(0, aabb.size.y, 0),
		aabb.position + Vector3(0, 0, aabb.size.z),
		aabb.position + Vector3(aabb.size.x, aabb.size.y, 0),
		aabb.position + Vector3(aabb.size.x, 0, aabb.size.z),
		aabb.position + Vector3(0, aabb.size.y, aabb.size.z),
		aabb.position + aabb.size,
	]
	var out := AABB(xf * pts[0], Vector3.ZERO)
	for i in range(1, pts.size()):
		out = out.expand(xf * pts[i])
	return out


func _disable_shadows(root: Node) -> void:
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		if gi != null:
			gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root as AnimationPlayer
	for child in root.find_children("*", "AnimationPlayer", true, false):
		return child as AnimationPlayer
	return null


func _first_anim_name(player: AnimationPlayer) -> String:
	if player == null:
		return ""
	var names := player.get_animation_list()
	if names.is_empty():
		return ""
	for n in names:
		if String(n) != "RESET":
			return String(n)
	return String(names[0])


func _sanitize_root_motion(root: Node) -> void:
	var player := _find_animation_player(root)
	if player == null:
		return
	for anim_name in player.get_animation_list():
		var anim := player.get_animation(anim_name)
		if anim == null:
			continue
		for i in range(anim.get_track_count()):
			if anim.track_get_type(i) != Animation.TYPE_POSITION_3D:
				continue
			var path := String(anim.track_get_path(i))
			var lower := path.to_lower()
			if "hips" in lower or "root" in lower or path.ends_with(":position"):
				# 保留相对骨骼，关掉明显根位移轨
				if "hips" in lower or lower.ends_with("/root") or lower.ends_with(":root"):
					anim.track_set_enabled(i, false)
