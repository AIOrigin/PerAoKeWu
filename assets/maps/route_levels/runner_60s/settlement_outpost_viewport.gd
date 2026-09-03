extends SubViewportContainer
class_name SettlementOutpostViewport

## 结算页上半：据点深蓝实心剪影（底边贴地平线）

const FINISH_GATE_BUILDING_HEIGHT := 11.2
const SILHOUETTE_SHADER = preload("res://assets/maps/route_levels/runner_60s/finish_outpost_silhouette.gdshader")

var _viewport: SubViewport
var _world_root: Node3D
var _camera: Camera3D
var _silhouette_mats: Array[ShaderMaterial] = []
var _t := 0.0


func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_sync_viewport_size)


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	var pulse := 0.98 + sin(_t * 1.4) * 0.02
	for mat in _silhouette_mats:
		if mat != null:
			mat.set_shader_parameter("pulse", pulse)
			mat.set_shader_parameter("approach_boost", 0.12)


func setup(hearth_scene_path: String) -> void:
	_clear_world()
	if hearth_scene_path == "":
		return
	var packed: PackedScene = EmberCdn.load_packed(hearth_scene_path)
	if packed == null:
		packed = load(hearth_scene_path) as PackedScene
	if packed == null:
		return
	if _viewport == null:
		_viewport = SubViewport.new()
		_viewport.name = "OutpostViewport"
		_viewport.own_world_3d = true
		_viewport.transparent_bg = true
		_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
		add_child(_viewport)

		_world_root = Node3D.new()
		_world_root.name = "OutpostWorld"
		_viewport.add_child(_world_root)

		var env_node := WorldEnvironment.new()
		var env := Environment.new()
		env.background_mode = Environment.BG_CLEAR_COLOR
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.15, 0.22, 0.32)
		env.ambient_light_energy = 0.2
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		env.tonemap_exposure = 0.85
		env.glow_enabled = false
		env_node.environment = env
		_world_root.add_child(env_node)

		_camera = Camera3D.new()
		_camera.name = "OutpostCamera"
		_camera.current = true
		_world_root.add_child(_camera)

		var key := DirectionalLight3D.new()
		key.rotation_degrees = Vector3(-40.0, 30.0, 0.0)
		key.light_color = Color(0.5, 0.7, 0.85)
		key.light_energy = 0.12
		_world_root.add_child(key)

	var model := packed.instantiate() as Node3D
	if model == null:
		return
	model.name = "OutpostBuilding"
	model.rotation.y = PI + deg_to_rad(30.0)
	_world_root.add_child(model)
	_fit_building(model)
	_apply_silhouette(model)
	_frame_camera(model)
	_sync_viewport_size()


func _clear_world() -> void:
	_silhouette_mats.clear()
	if _world_root == null:
		return
	for child in _world_root.get_children():
		if child.name == "OutpostBuilding":
			child.queue_free()


func _sync_viewport_size() -> void:
	if _viewport == null:
		return
	_viewport.size = Vector2i(maxi(int(size.x), 2), maxi(int(size.y), 2))


func _fit_building(model: Node3D) -> void:
	var bounds := _compute_aabb(model)
	var sy := FINISH_GATE_BUILDING_HEIGHT / maxf(bounds.size.y, 0.001)
	model.scale = Vector3(sy, sy, sy)
	model.force_update_transform()
	bounds = _compute_aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)


func _frame_camera(model: Node3D) -> void:
	if _camera == null:
		return
	var bounds := _compute_aabb(model)
	var center := bounds.position + bounds.size * 0.5
	center.y = bounds.position.y + bounds.size.y * 0.34
	var extent := maxf(bounds.size.x, bounds.size.z)
	var dist := maxf(extent * 1.0, bounds.size.y * 1.3) + 5.0
	_camera.position = center + Vector3(dist * 0.52, dist * 0.55, dist * 0.85)
	_camera.look_at(Vector3(center.x, bounds.position.y + bounds.size.y * 0.2, center.z), Vector3.UP)
	_camera.fov = 28.0


func _apply_silhouette(root: Node3D) -> void:
	_silhouette_mats.clear()
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var mat := ShaderMaterial.new()
		mat.shader = SILHOUETTE_SHADER
		# 实心深蓝剪影，几乎无发光，避免线框感
		mat.set_shader_parameter("body_color", Color(0.045, 0.06, 0.10, 1.0))
		mat.set_shader_parameter("rim_color", Color(0.25, 0.4, 0.55, 1.0))
		mat.set_shader_parameter("window_glow", Color(0.1, 0.18, 0.28, 1.0))
		mat.set_shader_parameter("approach_boost", 0.12)
		mat.set_shader_parameter("pulse", 1.0)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.material_override = mat
		_silhouette_mats.append(mat)


func _compute_aabb(node: Node3D) -> AABB:
	var merged := AABB()
	var first := true
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_inst := mi as MeshInstance3D
		if mesh_inst.mesh == null:
			continue
		var local_aabb := mesh_inst.mesh.get_aabb()
		var xf_aabb := mesh_inst.global_transform * local_aabb
		if first:
			merged = xf_aabb
			first = false
		else:
			merged = merged.merge(xf_aabb)
	if first:
		return AABB(Vector3.ZERO, Vector3.ONE)
	return merged
