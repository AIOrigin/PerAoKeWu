class_name EnergyChaserController
extends Node3D

## Nulltide Wraith：暗色密集星火光点聚合成的摄魂怪状幽影（非实体块）。
## 动态靠分层延迟运动（平滑跟随 / 悬浮 / 下摆拖曳）。

enum ChaseState { DORMANT, WARNING, CHASE, CRITICAL, CAPTURED }

signal pressure_changed(pressure: float, normalized_pressure: float)
signal chase_state_changed(new_state: ChaseState)
signal player_captured

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
@export var visual_height: float = 0.55
@export var follow_smoothing: float = 5.5
## >=0 时强制视觉间距（开局后侧展示用）
@export var preview_gap: float = -1.0
## 开局预览时抬高可见度（反打镜头要能看清幽影）
@export var preview_boost: float = 0.0

@export_group("Hover")
@export var hover_amplitude: float = 0.08
@export var hover_speed: float = 1.15
@export var yaw_amplitude_deg: float = 2.5
@export var yaw_speed: float = 0.55

@export_group("Tails")
@export var tail_sway_deg: float = 6.0
@export var tail_sway_speed: float = 1.2
@export var tail_drag_deg: float = 8.0

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
## 低配：减粒子量、关灯，仍保留光点轮廓
@export var low_fx: bool = false

## 色锚：近黑 / 靛紫 / 裂隙紫 / 浅雾紫 / 青星火花
const COL_NEAR_BLACK := Color(0.043, 0.027, 0.078, 1.0)
const COL_INDIGO := Color(0.149, 0.075, 0.263, 1.0)
const COL_RIFT := Color(0.537, 0.341, 0.824, 1.0)
const COL_MIST := Color(0.776, 0.718, 1.0, 1.0)
const COL_CYAN := Color(0.45, 0.85, 1.0, 1.0)

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
var _ghost_shell: Node3D
var _body_cloud: GPUParticles3D
var _hood_cloud: GPUParticles3D
var _void_maw: GPUParticles3D
var _rift_sparks: GPUParticles3D
var _cyan_specks: GPUParticles3D
var _tail_streams: Array[GPUParticles3D] = []
var _tail_pivots: Array[Node3D] = []
var _spark_layers: Array[GPUParticles3D] = []
var _ghost_mats: Array[StandardMaterial3D] = []
var _chase_light: OmniLight3D


func _ready() -> void:
	pressure = initial_pressure
	if visual_root == null:
		_build_default_visuals()
	_apply_visuals()
	set_process(true)


func _process(delta: float) -> void:
	# 视觉动态始终跑：即使 intro 关掉了 physics_process
	if not visible and preview_gap < 0.0 and state != ChaseState.CAPTURED:
		return
	_elapsed += delta
	_pulse = fmod(_pulse + delta * lerpf(1.0, 2.6, get_normalized_pressure()), TAU)
	if _flash_t > 0.0:
		_flash_t = maxf(_flash_t - delta, 0.0)
	_update_follow_motion(delta)
	_animate_hover(delta)
	_animate_tails(delta)
	_apply_visuals()


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
	# 视觉已在 _process 里刷新


func set_chase_target(world_pos: Vector3, yaw: float) -> void:
	_chase_target = world_pos
	_chase_yaw = yaw
	if not _has_chase_target:
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
	_apply_visuals()


func pulse_flash(duration: float = 0.4) -> void:
	_flash_t = maxf(_flash_t, duration)


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
		player_captured.emit()

	pressure_changed.emit(pressure, get_normalized_pressure())


func _update_follow_motion(delta: float) -> void:
	if not _has_chase_target:
		return
	# 指数平滑：慢半拍追向锚点，制造惯性追击感
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
	_hover_root.position.y = sin(_elapsed * hover_speed) * hover_amplitude
	_hover_root.rotation.y = deg_to_rad(sin(_elapsed * yaw_speed) * yaw_amplitude_deg)
	var near_t := clampf((10.0 - get_visual_gap()) / 10.0, 0.0, 1.0)
	_hover_root.rotation.x = deg_to_rad(lerpf(2.0, 8.0, near_t) + sin(_elapsed * 0.9) * 1.2)
	var bank_target := clampf(-_yaw_rate * 0.35, -0.28, 0.28)
	_bank_roll = lerpf(_bank_roll, bank_target, clampf(delta * 6.0, 0.0, 1.0))
	_hover_root.rotation.z = _bank_roll


func _animate_tails(delta: float) -> void:
	if _wraith_root == null:
		return
	var dt := maxf(delta, 0.001)
	var velocity := (global_position - _last_root_pos) / dt
	_last_root_pos = global_position
	var speed := velocity.length()
	var drag := clampf(speed * 0.12, 0.0, 1.0) * tail_drag_deg
	var p := get_normalized_pressure()
	var boost := clampf(preview_boost, 0.0, 1.0)
	drag *= lerpf(1.0, 1.55, p) * lerpf(1.0, 1.25, boost)
	var phases := [0.0, 1.7, 3.1]
	var drag_muls := [1.0, 0.8, 0.9]
	for i in _tail_pivots.size():
		var pivot := _tail_pivots[i]
		if pivot == null:
			continue
		var phase: float = phases[i] if i < phases.size() else float(i) * 1.4
		var dmul: float = drag_muls[i] if i < drag_muls.size() else 0.85
		var wave := sin(_elapsed * tail_sway_speed + phase) * tail_sway_deg
		pivot.rotation.x = deg_to_rad(wave + drag * dmul)
		pivot.rotation.z = deg_to_rad(sin(_elapsed * 0.7 + phase) * 2.0)
		var stretch := lerpf(1.0, 1.45, clampf(speed * 0.08, 0.0, 1.0)) * lerpf(1.0, 1.25, p)
		pivot.scale = Vector3(1.0, stretch, 1.0)


func _apply_visuals() -> void:
	var gap := get_visual_gap()
	var p := get_normalized_pressure()
	var boost := clampf(preview_boost, 0.0, 1.0)
	if boost > 0.01:
		p = maxf(p, lerpf(0.45, 0.65, boost))
		gap = minf(gap, lerpf(14.0, 9.0, boost))
	var flash := clampf(_flash_t / 0.4, 0.0, 1.0)
	visible = is_active or state == ChaseState.CAPTURED or preview_gap >= 0.0
	if visual_root == null:
		return
	visual_root.visible = visible

	var body_scale := 0.95
	if gap > 20.0:
		body_scale = lerpf(1.0, 0.88, clampf((gap - 20.0) / 8.0, 0.0, 1.0))
	elif gap > 10.0:
		body_scale = lerpf(1.12, 1.0, (gap - 10.0) / 10.0)
	else:
		body_scale = lerpf(1.28, 1.12, gap / 10.0)
	if state == ChaseState.CAPTURED:
		body_scale = 1.35
	body_scale *= lerpf(1.0, 1.12, boost) * (1.0 + flash * 0.08)
	if _wraith_root != null:
		_wraith_root.scale = Vector3.ONE * body_scale

	# 始终保持较高密度，远距也不能“空掉”
	var dens := clampf(lerpf(0.75, 1.0, 1.0 - gap / 28.0) + boost * 0.15 + flash * 0.12, 0.72, 1.0)
	if low_fx:
		dens = maxf(dens * 0.7, 0.55)
	var on := visible
	for layer in _spark_layers:
		if layer == null:
			continue
		layer.emitting = on
		layer.amount_ratio = dens
	if _rift_sparks != null:
		_rift_sparks.amount_ratio = dens
	if _cyan_specks != null:
		_cyan_specks.emitting = on
		_cyan_specks.amount_ratio = dens * lerpf(0.6, 1.0, p)
	for stream in _tail_streams:
		if stream == null:
			continue
		stream.emitting = on
		stream.amount_ratio = dens

	# 半透明幽影壳：保证远距轮廓可读
	var shell_a := clampf(lerpf(0.14, 0.32, p) + boost * 0.12 + flash * 0.15, 0.12, 0.4)
	var shell_e := lerpf(0.8, 2.2, p) + flash * 1.5 + boost * 0.6
	for mat in _ghost_mats:
		if mat == null:
			continue
		mat.albedo_color.a = shell_a
		mat.emission_energy_multiplier = shell_e

	if edge_particles != null:
		edge_particles.emitting = on
		edge_particles.amount_ratio = dens
	if spark_particles != null and spark_particles != _cyan_specks:
		spark_particles.emitting = on
		spark_particles.amount_ratio = dens

	if _chase_light != null:
		_chase_light.visible = not low_fx and on
		_chase_light.light_energy = lerpf(0.55, 1.8, p) + flash * 1.4 + boost * 0.8
		_chase_light.omni_range = lerpf(5.5, 10.0, boost)
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

	_spark_layers.clear()
	_tail_pivots.clear()
	_tail_streams.clear()
	_ghost_mats.clear()

	_wraith_root = Node3D.new()
	_wraith_root.name = "WraithRoot"
	visual_root.add_child(_wraith_root)

	_hover_root = Node3D.new()
	_hover_root.name = "HoverRoot"
	_wraith_root.add_child(_hover_root)

	# 半透明幽影壳：解决“纯暗粒子看不见”
	_ghost_shell = Node3D.new()
	_ghost_shell.name = "GhostShell"
	_hover_root.add_child(_ghost_shell)
	_add_ghost_volume("GhostMantle", Vector3(1.35, 2.1, 0.85), Vector3(0.0, 1.2, 0.0), Color(0.08, 0.04, 0.16, 0.22))
	_add_ghost_volume("GhostHood", Vector3(1.15, 1.25, 1.0), Vector3(0.0, 2.55, 0.05), Color(0.06, 0.03, 0.14, 0.26))
	_add_ghost_volume("GhostCollarL", Vector3(0.35, 1.0, 0.45), Vector3(-0.55, 2.6, 0.1), Color(0.1, 0.05, 0.2, 0.2), Vector3(8.0, 0.0, 18.0))
	_add_ghost_volume("GhostCollarR", Vector3(0.35, 1.0, 0.45), Vector3(0.55, 2.6, 0.1), Color(0.1, 0.05, 0.2, 0.2), Vector3(8.0, 0.0, -18.0))
	_add_ghost_volume("GhostVoid", Vector3(0.75, 0.9, 0.12), Vector3(0.0, 2.45, 0.48), Color(0.02, 0.0, 0.05, 0.45))
	_add_ghost_volume("GhostRift", Vector3(0.14, 1.7, 0.1), Vector3(0.0, 1.35, 0.42), Color(0.45, 0.25, 0.9, 0.35))

	# —— 密集星火光点（更大、更亮，才能在赛道里读出来） —— #
	_body_cloud = _make_spark_volume(
		"BodySparkCloud",
		Vector3(0.0, 1.15, 0.0),
		180 if not low_fx else 80,
		Vector3(0.78, 1.1, 0.52),
		Color(0.22, 0.1, 0.42, 0.85),
		COL_RIFT,
		2.2,
		0.06,
		0.14,
		0.9
	)
	_hover_root.add_child(_body_cloud)

	_hood_cloud = _make_spark_volume(
		"HoodSparkCloud",
		Vector3(0.0, 2.5, 0.05),
		120 if not low_fx else 56,
		Vector3(0.68, 0.75, 0.58),
		Color(0.18, 0.08, 0.38, 0.9),
		COL_MIST,
		2.6,
		0.05,
		0.12,
		1.0
	)
	_hover_root.add_child(_hood_cloud)

	_void_maw = _make_spark_volume(
		"VoidMawSparks",
		Vector3(0.0, 2.4, 0.45),
		56 if not low_fx else 28,
		Vector3(0.4, 0.5, 0.14),
		Color(0.08, 0.03, 0.16, 0.95),
		COL_INDIGO,
		1.2,
		0.05,
		0.11,
		0.7
	)
	_hover_root.add_child(_void_maw)

	_rift_sparks = _make_spark_volume(
		"RiftSparkLine",
		Vector3(0.0, 1.4, 0.42),
		48 if not low_fx else 22,
		Vector3(0.1, 1.0, 0.08),
		Color(0.65, 0.4, 1.0, 0.95),
		COL_RIFT,
		4.0,
		0.04,
		0.09,
		0.7
	)
	_hover_root.add_child(_rift_sparks)

	_cyan_specks = _make_spark_volume(
		"CyanSpeckCloud",
		Vector3(0.0, 2.75, 0.15),
		36 if not low_fx else 16,
		Vector3(0.6, 0.4, 0.45),
		Color(COL_CYAN.r, COL_CYAN.g, COL_CYAN.b, 0.9),
		COL_CYAN,
		4.5,
		0.03,
		0.07,
		1.0
	)
	_hover_root.add_child(_cyan_specks)

	_add_tail_stream("TailCenter", Vector3(0.0, 0.15, -0.1), 0.0)
	_add_tail_stream("TailLeft", Vector3(-0.5, 0.2, 0.0), -16.0)
	_add_tail_stream("TailRight", Vector3(0.5, 0.2, 0.0), 16.0)

	edge_particles = _make_spark_volume(
		"EdgeMistSparks",
		Vector3(0.0, 1.0, -0.15),
		70 if not low_fx else 28,
		Vector3(1.0, 1.25, 0.75),
		Color(0.35, 0.2, 0.7, 0.55),
		COL_MIST,
		1.8,
		0.08,
		0.18,
		1.2
	)
	_hover_root.add_child(edge_particles)

	spark_particles = _cyan_specks

	_chase_light = OmniLight3D.new()
	_chase_light.name = "VoidLight"
	_chase_light.light_color = COL_RIFT
	_chase_light.light_energy = 0.9
	_chase_light.omni_range = 7.5
	_chase_light.shadow_enabled = false
	_chase_light.position = Vector3(0.0, 1.8, 0.35)
	_hover_root.add_child(_chase_light)

	chase_audio = AudioStreamPlayer3D.new()
	chase_audio.name = "ChaseAudio3D"
	chase_audio.max_distance = 42.0
	visual_root.add_child(chase_audio)

	if low_fx and _chase_light != null:
		_chase_light.visible = false


func _add_ghost_volume(
	part_name: String,
	size: Vector3,
	pos: Vector3,
	col: Color,
	rot_deg: Vector3 = Vector3.ZERO
) -> void:
	var mi := MeshInstance3D.new()
	mi.name = part_name
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = col
	mat.emission_enabled = true
	mat.emission = Color(COL_RIFT.r, COL_RIFT.g, COL_RIFT.b)
	mat.emission_energy_multiplier = 1.2
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_fog = true
	mat.no_depth_test = false
	box.material = mat
	mi.mesh = box
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ghost_shell.add_child(mi)
	_ghost_mats.append(mat)


func _add_tail_stream(part_name: String, pos: Vector3, yaw_deg: float) -> void:
	var pivot := Node3D.new()
	pivot.name = part_name + "Pivot"
	pivot.position = pos
	pivot.rotation_degrees = Vector3(12.0, yaw_deg, 0.0)
	_hover_root.add_child(pivot)
	_tail_pivots.append(pivot)

	var stream := _make_tail_spark_stream(part_name + "Stream", 70 if not low_fx else 32)
	pivot.add_child(stream)
	_tail_streams.append(stream)
	_spark_layers.append(stream)


func _make_spark_volume(
	part_name: String,
	pos: Vector3,
	amount: int,
	box_extents: Vector3,
	albedo: Color,
	emission: Color,
	emit_energy: float,
	scale_min: float,
	scale_max: float,
	lifetime: float
) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = part_name
	p.position = pos
	p.amount = amount
	p.lifetime = lifetime
	p.preprocess = lifetime
	p.explosiveness = 0.0
	p.randomness = 0.65
	p.emitting = true
	p.local_coords = true
	p.visibility_aabb = AABB(-box_extents * 3.0 - Vector3(1, 1, 1), box_extents * 6.0 + Vector3(2, 2, 2))
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = box_extents
	mat.direction = Vector3(0.0, 0.2, -0.15)
	mat.spread = 180.0
	mat.initial_velocity_min = 0.04
	mat.initial_velocity_max = 0.28
	mat.angular_velocity_min = -30.0
	mat.angular_velocity_max = 30.0
	mat.gravity = Vector3(0.0, 0.06, 0.0)
	mat.damping_min = 0.2
	mat.damping_max = 0.8
	mat.scale_min = scale_min
	mat.scale_max = scale_max
	mat.color = Color(1, 1, 1, 1)
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.08, 0.55, 1.0])
	grad.colors = PackedColorArray([
		Color(albedo.r, albedo.g, albedo.b, 0.0),
		Color(albedo.r, albedo.g, albedo.b, albedo.a),
		Color(emission.r, emission.g, emission.b, albedo.a),
		Color(emission.r, emission.g, emission.b, 0.0),
	])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp
	p.process_material = mat
	p.draw_pass_1 = _make_spark_draw_mesh(albedo, emission, emit_energy, scale_max)
	_spark_layers.append(p)
	return p


func _make_tail_spark_stream(part_name: String, amount: int) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.name = part_name
	p.amount = amount
	p.lifetime = 1.25
	p.preprocess = 1.2
	p.emitting = true
	p.local_coords = true
	p.visibility_aabb = AABB(Vector3(-2.0, -4.0, -3.0), Vector3(4.0, 5.5, 5.0))
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(0.22, 0.1, 0.14)
	mat.direction = Vector3(0.0, -1.0, -0.4)
	mat.spread = 22.0
	mat.initial_velocity_min = 0.9
	mat.initial_velocity_max = 2.2
	mat.gravity = Vector3(0.0, -0.4, 0.0)
	mat.damping_min = 0.15
	mat.damping_max = 0.5
	mat.scale_min = 0.05
	mat.scale_max = 0.12
	mat.color = Color(1, 1, 1, 1)
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.12, 0.65, 1.0])
	grad.colors = PackedColorArray([
		Color(COL_RIFT.r, COL_RIFT.g, COL_RIFT.b, 0.0),
		Color(0.55, 0.32, 0.95, 0.9),
		Color(0.2, 0.1, 0.4, 0.55),
		Color(0.05, 0.02, 0.12, 0.0),
	])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp
	p.process_material = mat
	p.draw_pass_1 = _make_spark_draw_mesh(
		Color(0.35, 0.18, 0.7, 0.85), COL_RIFT, 2.8, 0.12
	)
	return p


func _make_spark_draw_mesh(albedo: Color, emission: Color, energy: float, radius: float) -> QuadMesh:
	# 广告牌光点：远距比小球更易识别
	var draw := QuadMesh.new()
	var s := maxf(radius * 1.6, 0.06)
	draw.size = Vector2(s, s)
	var dmat := StandardMaterial3D.new()
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmat.albedo_color = Color(albedo.r, albedo.g, albedo.b, 1.0)
	dmat.emission_enabled = true
	dmat.emission = emission
	dmat.emission_energy_multiplier = energy
	dmat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	dmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	dmat.disable_fog = true
	dmat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	draw.material = dmat
	return draw
