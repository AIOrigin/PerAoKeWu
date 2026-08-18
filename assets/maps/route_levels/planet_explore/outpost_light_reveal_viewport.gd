extends SubViewportContainer
class_name OutpostLightRevealViewport

## 据点点亮展示：黑色剪影 → 彩色建模

const BUILDING_HEIGHT := 11.2
const SILHOUETTE_SHADER := preload("res://assets/maps/route_levels/runner_60s/finish_outpost_silhouette.gdshader")

var _viewport: SubViewport
var _world_root: Node3D
var _camera: Camera3D
var _silhouette_root: Node3D
var _color_root: Node3D
var _silhouette_mats: Array[ShaderMaterial] = []
var _fade_mats: Array[StandardMaterial3D] = []
var _revealing := false


func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_sync_viewport_size)


func setup(model_path: String) -> void:
	_clear_world()
	if model_path.strip_edges() == "":
		return
	var packed: PackedScene = load(model_path) as PackedScene
	if packed == null:
		return
	_ensure_viewport()
	var scene := packed.instantiate() as Node3D
	if scene == null:
		return

	_silhouette_root = scene
	_silhouette_root.name = "OutpostSilhouette"
	_silhouette_root.rotation.y = PI + deg_to_rad(30.0)
	_world_root.add_child(_silhouette_root)
	_apply_silhouette(_silhouette_root)

	_color_root = packed.instantiate() as Node3D
	_color_root.name = "OutpostColor"
	_color_root.rotation.y = PI + deg_to_rad(30.0)
	_world_root.add_child(_color_root)
	_prepare_color_fade(_color_root)
	_color_root.visible = true

	_fit_building(_silhouette_root)
	_fit_building(_color_root)
	_frame_camera(_silhouette_root)
	_sync_viewport_size()


func play_reveal(duration: float = 1.15) -> void:
	if _revealing or _silhouette_root == null:
		return
	_revealing = true
	modulate.a = 1.0
	for mat in _silhouette_mats:
		if mat != null:
			mat.set_shader_parameter("approach_boost", 0.0)
			mat.set_shader_parameter("body_color", Color(0.018, 0.018, 0.022, 1.0))
			mat.set_shader_parameter("pulse", 1.0)
	for mat in _fade_mats:
		if mat != null:
			mat.albedo_color.a = 0.0

	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.tween_method(_set_color_alpha, 0.0, 1.0, duration)
	tw.parallel().tween_method(_set_silhouette_boost, 0.0, 1.25, duration * 0.92)
	tw.parallel().tween_method(_set_silhouette_body, Color(0.018, 0.018, 0.022), Color(0.08, 0.11, 0.16), duration * 0.88)
	tw.tween_callback(_finish_reveal)


func _finish_reveal() -> void:
	if _silhouette_root != null and is_instance_valid(_silhouette_root):
		_silhouette_root.queue_free()
		_silhouette_root = null
	_silhouette_mats.clear()
	for mat in _fade_mats:
		if mat != null:
			mat.albedo_color.a = 1.0
	_revealing = false


func _set_color_alpha(alpha: float) -> void:
	for mat in _fade_mats:
		if mat != null:
			mat.albedo_color.a = clampf(alpha, 0.0, 1.0)


func _set_silhouette_boost(value: float) -> void:
	for mat in _silhouette_mats:
		if mat != null:
			mat.set_shader_parameter("approach_boost", value)


func _set_silhouette_body(color: Color) -> void:
	for mat in _silhouette_mats:
		if mat != null:
			mat.set_shader_parameter("body_color", color)


func _ensure_viewport() -> void:
	if _viewport != null:
		return
	_viewport = SubViewport.new()
	_viewport.name = "OutpostRevealViewport"
	_viewport.own_world_3d = true
	_viewport.transparent_bg = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	add_child(_viewport)

	_world_root = Node3D.new()
	_world_root.name = "OutpostWorld"
	_viewport.add_child(_world_root)

	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.0, 0.0, 0.0, 0.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.58, 0.62)
	env.ambient_light_energy = 0.95
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.05
	env_node.environment = env
	_world_root.add_child(env_node)

	_camera = Camera3D.new()
	_camera.name = "OutpostCamera"
	_camera.current = true
	_world_root.add_child(_camera)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-42.0, 34.0, 0.0)
	key.light_color = Color(1.0, 0.96, 0.90)
	key.light_energy = 1.15
	_world_root.add_child(key)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-18.0, -120.0, 0.0)
	fill.light_color = Color(0.65, 0.78, 0.95)
	fill.light_energy = 0.42
	_world_root.add_child(fill)


func _clear_world() -> void:
	_silhouette_mats.clear()
	_fade_mats.clear()
	_silhouette_root = null
	_color_root = null
	_revealing = false
	if _world_root == null:
		return
	for child in _world_root.get_children():
		if child is Node3D and child.name.begins_with("Outpost"):
			child.queue_free()


func _sync_viewport_size() -> void:
	if _viewport == null:
		return
	_viewport.size = Vector2i(maxi(int(size.x), 2), maxi(int(size.y), 2))


func _fit_building(model: Node3D) -> void:
	var bounds := _compute_aabb(model)
	var sy := BUILDING_HEIGHT / maxf(bounds.size.y, 0.001)
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
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var mat := ShaderMaterial.new()
		mat.shader = SILHOUETTE_SHADER
		mat.set_shader_parameter("body_color", Color(0.018, 0.018, 0.022, 1.0))
		mat.set_shader_parameter("rim_color", Color(0.35, 0.38, 0.42, 1.0))
		mat.set_shader_parameter("window_glow", Color(0.08, 0.10, 0.14, 1.0))
		mat.set_shader_parameter("approach_boost", 0.0)
		mat.set_shader_parameter("pulse", 1.0)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.material_override = mat
		_silhouette_mats.append(mat)


func _prepare_color_fade(root: Node3D) -> void:
	_fade_mats.clear()
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if mi.mesh == null:
			continue
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if mi.material_override != null:
			var override_mat := _make_fade_mat(mi.material_override)
			mi.material_override = override_mat
			continue
		for surface_i in mi.mesh.get_surface_count():
			var src: Material = mi.get_surface_override_material(surface_i)
			if src == null:
				src = mi.mesh.surface_get_material(surface_i)
			var dup := _make_fade_mat(src)
			mi.set_surface_override_material(surface_i, dup)


func _make_fade_mat(src: Material) -> StandardMaterial3D:
	var dup: StandardMaterial3D
	if src is StandardMaterial3D:
		dup = (src as StandardMaterial3D).duplicate() as StandardMaterial3D
	else:
		dup = StandardMaterial3D.new()
		dup.albedo_color = Color(0.72, 0.68, 0.62)
	dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dup.albedo_color.a = 0.0
	_fade_mats.append(dup)
	return dup


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
