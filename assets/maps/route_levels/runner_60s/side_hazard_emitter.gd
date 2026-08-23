extends Node3D
class_name SideHazardEmitter

## 跑道两侧悬浮能量穴 + 定向喷涌（热浪 / 毒雾 demo）

const SIDE_OFFSET := 7.8
const HEIGHT := 3.4

var _zone: Dictionary = {}
var _left_root: Node3D
var _right_root: Node3D
var _left_spray: GPUParticles3D
var _right_spray: GPUParticles3D
var _left_glow: OmniLight3D
var _right_glow: OmniLight3D

var _zone_active := false
var _burst_timer := 0.0
var _cycle_index := 0
var _current_side := "left"
var _burst_active := false
var _warned := false


func configure(zone: Dictionary, path_pos: Vector3, path_yaw: float) -> void:
	_zone = zone
	name = "SideHazard_%d" % int(float(zone.get("start", 0.0)))
	_burst_timer = 0.0
	_cycle_index = 0
	_current_side = "left"
	_burst_active = false
	_warned = false
	var forward := Vector3(-sin(path_yaw), 0.0, -cos(path_yaw))
	var right := Vector3(cos(path_yaw), 0.0, -sin(path_yaw))
	var up := Vector3.UP
	var left_pos := path_pos + right * SIDE_OFFSET + up * HEIGHT
	var right_pos := path_pos - right * SIDE_OFFSET + up * HEIGHT
	var is_poison := String(zone.get("hazard_kind", "sand")) == "poison"
	_left_root = _make_cave("LeftEnergyCave", left_pos, right, up, is_poison)
	_right_root = _make_cave("RightEnergyCave", right_pos, -right, up, is_poison)
	add_child(_left_root)
	add_child(_right_root)
	_left_spray = _left_root.get_node("Spray") as GPUParticles3D
	_right_spray = _right_root.get_node("Spray") as GPUParticles3D
	_left_glow = _left_root.get_node("Glow") as OmniLight3D
	_right_glow = _right_root.get_node("Glow") as OmniLight3D
	_set_spray_active(false, false)


func advance_burst(delta: float) -> Dictionary:
	if not _zone_active:
		_burst_active = false
		_set_spray_active(false, false)
		return _runtime_state()
	var interval := maxf(0.35, float(_zone.get("burst_interval", 0.82)))
	var duration := clampf(float(_zone.get("burst_duration", 0.55)), 0.2, interval - 0.08)
	_burst_timer += delta
	if _burst_timer >= interval:
		_burst_timer = 0.0
		_cycle_index += 1
		_pick_side_for_cycle()
	_burst_active = _burst_timer <= duration
	_update_spray_visuals()
	return _runtime_state()


func set_zone_active(active: bool) -> void:
	_zone_active = active
	if not active:
		_burst_active = false
		_burst_timer = 0.0
		_set_spray_active(false, false)


func needs_entry_warning() -> bool:
	return _zone_active and not _warned


func mark_entry_warned() -> void:
	_warned = true


func _runtime_state() -> Dictionary:
	var lanes: Array = []
	if _burst_active:
		if _current_side == "left":
			lanes = _lane_array("left_cover_lanes", [-1, 0])
		elif _current_side == "right":
			lanes = _lane_array("right_cover_lanes", [0, 1])
		else:
			lanes = [-1, 0, 1]
	return {
		"burst_active": _burst_active,
		"covered_lanes": lanes,
		"emit_side": _current_side,
	}


func _lane_array(key: String, fallback: Array) -> Array:
	if not _zone.has(key):
		return fallback.duplicate()
	var raw: Array = _zone[key]
	var out: Array = []
	for v in raw:
		out.append(clampi(int(v), -1, 1))
	return out if not out.is_empty() else fallback.duplicate()


func _pick_side_for_cycle() -> void:
	var pattern := String(_zone.get("emit_pattern", "alternate"))
	match pattern:
		"left":
			_current_side = "left"
		"right":
			_current_side = "right"
		"both":
			_current_side = "both"
		_:
			_current_side = "left" if _cycle_index % 2 == 1 else "right"


func _update_spray_visuals() -> void:
	if not _burst_active:
		_set_spray_active(false, false)
		_set_glow(0.35)
		return
	match _current_side:
		"left":
			_set_spray_active(true, false)
		"right":
			_set_spray_active(false, true)
		"both":
			_set_spray_active(true, true)
	_set_glow(1.35 if _burst_timer < 0.12 else 0.95)


func _set_spray_active(left_on: bool, right_on: bool) -> void:
	if _left_spray:
		_left_spray.emitting = left_on
	if _right_spray:
		_right_spray.emitting = right_on


func _set_glow(energy: float) -> void:
	if _left_glow:
		_left_glow.light_energy = energy
	if _right_glow:
		_right_glow.light_energy = energy


func _make_cave(cave_name: String, pos: Vector3, spray_dir: Vector3, up: Vector3, is_poison: bool) -> Node3D:
	var root := Node3D.new()
	root.name = cave_name
	root.position = pos
	var shell := MeshInstance3D.new()
	shell.name = "Shell"
	var sphere := SphereMesh.new()
	sphere.radius = 1.05
	sphere.height = 2.1
	sphere.radial_segments = 18
	sphere.rings = 12
	var shell_mat := StandardMaterial3D.new()
	if is_poison:
		shell_mat.albedo_color = Color(0.42, 0.12, 0.62, 0.42)
		shell_mat.emission_enabled = true
		shell_mat.emission = Color(0.72, 0.22, 0.95)
		shell_mat.emission_energy_multiplier = 1.35
	else:
		shell_mat.albedo_color = Color(0.38, 0.14, 0.06, 0.38)
		shell_mat.emission_enabled = true
		shell_mat.emission = Color(1.0, 0.42, 0.12)
		shell_mat.emission_energy_multiplier = 1.55
	shell_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shell_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shell_mat.roughness = 0.35
	sphere.material = shell_mat
	shell.mesh = sphere
	root.add_child(shell)
	var core := MeshInstance3D.new()
	core.name = "Core"
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.42
	core_mesh.height = 0.84
	var core_mat := StandardMaterial3D.new()
	if is_poison:
		core_mat.albedo_color = Color(0.55, 0.95, 0.42, 0.85)
		core_mat.emission = Color(0.45, 1.0, 0.35)
	else:
		core_mat.albedo_color = Color(1.0, 0.72, 0.18, 0.92)
		core_mat.emission = Color(1.0, 0.55, 0.08)
	core_mat.emission_enabled = true
	core_mat.emission_energy_multiplier = 2.4
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core_mesh.material = core_mat
	core.mesh = core_mesh
	root.add_child(core)
	var glow := OmniLight3D.new()
	glow.name = "Glow"
	glow.position = Vector3(0.0, 0.05, 0.0)
	glow.light_color = Color(0.62, 0.95, 0.38) if is_poison else Color(1.0, 0.52, 0.16)
	glow.light_energy = 0.35
	glow.omni_range = 5.5
	glow.shadow_enabled = false
	root.add_child(glow)
	var spray := _make_spray(is_poison)
	spray.name = "Spray"
	var basis := Basis()
	basis.y = up.normalized()
	basis.x = spray_dir.normalized()
	basis.z = basis.x.cross(basis.y).normalized()
	basis.x = basis.y.cross(basis.z).normalized()
	spray.transform.basis = basis
	spray.position = Vector3(0.0, -0.15, 0.0)
	root.add_child(spray)
	# 轻微悬浮动画由 runner 统一 tick，此处固定姿态
	return root


func _make_spray(is_poison: bool) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = 96 if is_poison else 112
	particles.lifetime = 0.72
	particles.preprocess = 0.2
	particles.explosiveness = 0.08
	particles.visibility_aabb = AABB(Vector3(-12, -4, -12), Vector3(24, 12, 24))
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.0, -0.08, 1.0)
	mat.spread = 18.0
	mat.initial_velocity_min = 11.0
	mat.initial_velocity_max = 19.0
	mat.gravity = Vector3(0.0, -2.4, 0.0)
	mat.scale_min = 0.12
	mat.scale_max = 0.34
	if is_poison:
		mat.color = Color(0.52, 0.95, 0.38, 0.82)
	else:
		mat.color = Color(1.0, 0.58, 0.12, 0.88)
	particles.process_material = mat
	var draw := QuadMesh.new()
	draw.size = Vector2(0.28, 0.72)
	var draw_mat := StandardMaterial3D.new()
	if is_poison:
		draw_mat.albedo_color = Color(0.45, 0.95, 0.32, 0.75)
		draw_mat.emission = Color(0.35, 0.92, 0.22)
	else:
		draw_mat.albedo_color = Color(1.0, 0.48, 0.08, 0.82)
		draw_mat.emission = Color(1.0, 0.38, 0.05)
	draw_mat.emission_enabled = true
	draw_mat.emission_energy_multiplier = 1.45
	draw_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	draw.material = draw_mat
	particles.draw_pass_1 = draw
	particles.emitting = false
	return particles
