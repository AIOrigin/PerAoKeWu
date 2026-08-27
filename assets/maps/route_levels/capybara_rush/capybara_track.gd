class_name CapybaraTrack
extends RefCounted

## 赛道生成、主题、路边道具

const CapybaraTrackPathScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_track_path.gd")
const MeshUtil := preload("res://assets/maps/route_levels/capybara_rush/capybara_mesh_util.gd")
const LevelCatalogScript := preload("res://assets/maps/route_levels/capybara_rush/level_catalog.gd")
const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")
const CapybaraWebConfig := preload("res://assets/maps/route_levels/capybara_rush/capybara_web_config.gd")
const CapybaraLevelCatalog = LevelCatalogScript

const LANE_COUNT := 3
const LANE_WIDTH := 1.08
const ROAD_HALF_W := 2.05
const ROAD_THICKNESS := 0.18
const ROAD_SURFACE_Y := ROAD_THICKNESS * 0.5
const START_LINE_PROGRESS := 8.5
const TRACK_LENGTH := 600.0

var _host: Node


func _init(host: Node) -> void:
	_host = host


func setup_environment() -> void:
	_setup_environment()


func build_path_and_track() -> void:
	_build_path_and_track()


func scatter_props() -> void:
	_scatter_props()


func spawn_start_line() -> void:
	_spawn_start_line()


func spawn_clouds() -> void:
	_spawn_clouds()


func update_clouds(delta: float) -> void:
	_update_clouds(delta)


func load_level_bundle(level_id: int) -> void:
	_load_level_bundle(level_id)


func load_custom_level_bundle(custom_id: String) -> void:
	_load_custom_level_bundle(custom_id)


func apply_theme_environment() -> void:
	_apply_theme_environment()


func path_place(node: Node3D, dist: float, lateral: float, y: float, yaw_extra: float = 0.0) -> void:
	_path_place(node, dist, lateral, y, yaw_extra)


func theme_obstacle_path(key: String) -> String:
	return _theme_obstacle_path(key)


func make_water_ripple_material(color: Color, sea_h: float = 0.38, deep_abyss: bool = false) -> Material:
	return _make_water_ripple_material(color, sea_h, deep_abyss)


func ensure_ice_parallax_textures() -> void:
	_ensure_ice_parallax_textures()


func _spawn_start_line() -> void:
	## 起跑线：黑白格纹横条，角色站在其前方（更大 progress）
	var holder := Node3D.new()
	holder.name = "StartLine"
	_host._world.add_child(holder)
	_path_place(holder, START_LINE_PROGRESS, 0.0, ROAD_SURFACE_Y + 0.01, 0.0)
	var stripe_w := ROAD_HALF_W * 2.05
	var stripe_d := 0.55
	var cell := 0.42
	var cols := maxi(int(stripe_w / cell), 6)
	var rows := 2
	var origin_x := -stripe_w * 0.5
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.98, 0.98, 1.0)
	white.roughness = 0.85
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.12, 0.12, 0.16)
	black.roughness = 0.9
	for r in rows:
		for c in cols:
			var mi := MeshInstance3D.new()
			mi.mesh = MeshUtil.rounded_box(
				Vector3(cell * 0.96, 0.05, stripe_d / float(rows) * 0.92),
				0.012
			)
			mi.material_override = white if ((c + r) % 2 == 0) else black
			mi.position = Vector3(
				origin_x + (float(c) + 0.5) * cell,
				0.02,
				(float(r) - 0.5) * (stripe_d / float(rows))
			)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			holder.add_child(mi)
	# 小立牌提示
	var post := MeshInstance3D.new()
	var pc := CylinderMesh.new()
	pc.top_radius = 0.05
	pc.bottom_radius = 0.06
	pc.height = 0.85
	post.mesh = pc
	var pm := StandardMaterial3D.new()
	pm.albedo_color = Color(0.95, 0.35, 0.45)
	post.material_override = pm
	post.position = Vector3(-stripe_w * 0.5 - 0.25, 0.42, 0.0)
	post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(post)
	var flag := MeshInstance3D.new()
	flag.mesh = MeshUtil.rounded_box(Vector3(0.55, 0.32, 0.05), 0.03)
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(1.0, 0.92, 0.35)
	flag.material_override = fm
	flag.position = Vector3(-stripe_w * 0.5 + 0.05, 0.78, 0.0)
	flag.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(flag)


func _spawn_clouds() -> void:
	var z := 8.0
	var i := 0
	var track_len: float = _host._track_len()
	while z < track_len:
		var side := -1.0 if i % 2 == 0 else 1.0
		var cloud := _make_cloud_visual()
		var holder := Node3D.new()
		holder.position = Vector3(
			side * randf_range(7.0, 14.0),
			randf_range(4.5, 9.0),
			z + randf_range(-2.0, 2.0)
		)
		holder.scale = Vector3.ONE * randf_range(1.4, 2.6)
		holder.add_child(cloud)
		_host._world.add_child(holder)
		_host._clouds.append(holder)
		z += randf_range(18.0, 28.0)
		i += 1


func _make_cloud_visual() -> Node3D:
	var n: Node3D = _host._instance_fitted(CapybaraRushPaths.CLOUD_FLUFFY, 1.8, 0.0)
	if n:
		return n
	# Tripo 云朵额度不足时的粉彩占位
	var root := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.92, 0.95)
	mat.roughness = 0.9
	for j in 4:
		var mi := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = randf_range(0.45, 0.75)
		sph.height = sph.radius * 2.0
		mi.mesh = sph
		mi.material_override = mat
		mi.position = Vector3(randf_range(-0.7, 0.7), randf_range(-0.15, 0.35), randf_range(-0.3, 0.3))
		root.add_child(mi)
	return root


func _update_clouds(delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	for i in _host._clouds.size():
		var c: Node3D = _host._clouds[i]
		if c == null or not is_instance_valid(c):
			continue
		c.position.x += sin(t * 0.35 + float(i)) * 0.15 * delta
		c.position.y += cos(t * 0.5 + float(i) * 0.7) * 0.08 * delta


func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.62, 0.72, 0.88)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.88, 0.86, 0.92)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.92
	env.glow_enabled = false
	_host._world_env = WorldEnvironment.new()
	_host._world_env.environment = env
	_host.add_child(_host._world_env)

	_host._sun_light = DirectionalLight3D.new()
	_host._sun_light.rotation_degrees = Vector3(-48, 35, 0)
	_host._sun_light.light_color = Color(1.0, 0.96, 0.9)
	_host._sun_light.light_energy = 0.95
	_host._sun_light.shadow_enabled = true
	# 高模自阴影 acne 会在亮色赛道上显成白噪点；略增 bias、收软阴影
	_host._sun_light.shadow_bias = 0.06
	_host._sun_light.shadow_normal_bias = 1.5
	_host._sun_light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	_host._sun_light.shadow_blur = 0.6
	_host.add_child(_host._sun_light)


func _path_place(node: Node3D, dist: float, lateral: float, y: float = 0.0, yaw_extra: float = 0.0) -> void:
	if _host._path != null:
		_host._path.apply_to(node, dist, lateral, y, yaw_extra)
	else:
		node.position = Vector3(lateral, y, dist)
		node.rotation.y = yaw_extra


func _build_path_and_track() -> void:
	_host._path = CapybaraTrackPathScript.new()
	_host._path.build_winding(_host._track_len())
	_host._water_meshes.clear()

	_host._road_mesh = MeshInstance3D.new()
	_host._road_mesh.mesh = _host._path.build_road_mesh(ROAD_HALF_W, ROAD_THICKNESS, _host._world_sys.planned_road_gaps())
	var mat := StandardMaterial3D.new()
	# 略降高光白底，减轻角色边缘/阴影上的过曝与虚化感
	var road_col := CapybaraLevelCatalog.color3(_host._theme_cfg.get("road_color"), Color(0.86, 0.82, 0.94))
	mat.albedo_color = Color(road_col.r * 0.92, road_col.g * 0.92, road_col.b * 0.94)
	mat.roughness = 0.9
	_host._road_mesh.material_override = mat
	_host._world.add_child(_host._road_mesh)

	var water_col := CapybaraLevelCatalog.color3(_host._theme_cfg.get("water_color"), Color(0.45, 0.70, 0.88))
	var track_z := float(_host._path.length) + 80.0
	# 整块水面铺在赛道下方（教程：细分平面 + 顶点浪）。
	# Y 低于路面，浪高也不顶穿跑道，避免再盖住白色赛道。
	var water := MeshInstance3D.new()
	water.name = "OceanWater"
	var plane := PlaneMesh.new()
	plane.size = Vector2(160.0, track_z)
	plane.subdivide_width = 96
	plane.subdivide_depth = clampi(int(track_z * 0.55), 96, 220)
	water.mesh = plane
	water.position = Vector3(0.0, -0.85, float(_host._path.length) * 0.45)
	# sea_height≈0.35 → 波峰约 -0.5，仍低于路面 ~0.09
	water.material_override = _make_water_ripple_material(water_col, 0.38, false)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_host._world.add_child(water)
	_host._water_meshes.append(water)


func _make_water_ripple_material(color: Color, sea_h: float = 0.38, deep_abyss: bool = false) -> Material:
	## stylized water（gameidea.org 教程：sea_octave 噪声浪）
	var sh: Shader = load("res://assets/maps/route_levels/capybara_rush/shaders/water_ripple.gdshader") as Shader
	if sh == null:
		var fb := StandardMaterial3D.new()
		fb.albedo_color = color
		fb.roughness = 0.12
		return fb
	var base := Color(
		clampf(color.r * 0.9 + 0.12, 0.0, 1.0),
		clampf(color.g * 0.9 + 0.15, 0.0, 1.0),
		clampf(color.b * 0.95 + 0.18, 0.0, 1.0)
	)
	var deep := Color(color.r * 0.22, color.g * 0.42, color.b * 0.55)
	var fog := Color(color.r * 0.1, color.g * 0.25, color.b * 0.36)
	var sm := ShaderMaterial.new()
	sm.shader = sh
	sm.set_shader_parameter("base_tint_color", base)
	sm.set_shader_parameter("deep_color", deep)
	sm.set_shader_parameter("underwater_fog_color", fog)
	sm.set_shader_parameter("water_absorption", Vector3(0.28, 0.08, 0.04))
	sm.set_shader_parameter("sea_height", sea_h)
	sm.set_shader_parameter("sea_choppy", 4.0 if deep_abyss else 3.6)
	sm.set_shader_parameter("sea_speed", 1.55)
	sm.set_shader_parameter("sea_freq", 0.10 if deep_abyss else 0.15)
	sm.set_shader_parameter("max_depth", 16.0 if deep_abyss else 7.0)
	sm.set_shader_parameter("fade_start_depth", 0.35)
	sm.set_shader_parameter("refraction_strength", 0.65)
	sm.set_shader_parameter("roughness", 0.09)
	sm.set_shader_parameter("specular", 0.7)
	sm.set_shader_parameter("foam_crest_amount", 2.6)
	sm.set_shader_parameter("foam_color", Color(0.95, 0.98, 1.0))
	return sm


func _scatter_props() -> void:
	## 路边装饰：主题树/灌木；缺模型则回退棒棒糖树
	var track_len: float = _host._track_len()
	_place_along(CapybaraRushPaths.FINISH_ARCH, track_len - 1.2, 0.0, 0.0, 3.2, 0.0)
	var tree_path := _theme_prop_path("tree", CapybaraRushPaths.TREE_LOLLIPOP)
	var bush_path := _theme_prop_path("bush", CapybaraRushPaths.BUSH_ROUND)
	var side_path := _theme_prop_path("side_prop", "")

	var z := 18.0
	var flip := 1.0
	while z < track_len - 20.0:
		var side := flip
		_place_along(
			tree_path,
			z, side * (ROAD_HALF_W + 3.6 + randf() * 1.2), 0.0,
			randf_range(1.8, 2.4), randf() * TAU
		)
		if randf() > 0.65:
			_place_along(
				bush_path,
				z + 4.0, side * (ROAD_HALF_W + 2.2), 0.0,
				randf_range(0.9, 1.2), randf() * TAU
			)
		if not side_path.is_empty() and randf() > 0.72:
			_place_along(
				side_path,
				z + randf_range(6.0, 14.0), -side * (ROAD_HALF_W + 2.0 + randf() * 0.8), 0.0,
				randf_range(0.38, 0.52), randf() * TAU
			)
		z += randf_range(28.0, 40.0)
		flip *= -1.0


func _ensure_ice_parallax_textures() -> void:
	## 程序化表层 / 底层 / 法线（供 CapybaraHazards 冰块材质使用）
	if _host._ice_tex_over != null and _host._ice_tex_under != null and _host._ice_tex_normal != null:
		return
	var res := 128
	var over_img := Image.create(res, res, false, Image.FORMAT_RGBA8)
	var under_img := Image.create(res, res, false, Image.FORMAT_RGBA8)
	var height := PackedFloat32Array()
	height.resize(res * res)
	for y in res:
		for x in res:
			var fx := float(x) / float(res)
			var fy := float(y) / float(res)
			var n1 := _ice_hash2(fx * 7.0, fy * 7.0)
			var n2 := _ice_hash2(fx * 17.0 + 3.1, fy * 17.0 + 1.7)
			var n3 := _ice_hash2(fx * 31.0 + 8.0, fy * 29.0)
			var ridge := 1.0 - absf(n1 * 2.0 - 1.0)
			var crack := smoothstep(0.7, 0.95, ridge)
			var grain := n2 * 0.55 + n3 * 0.45
			height[y * res + x] = crack * 0.65 + grain * 0.35
			var over_c := Color(
				0.72 + grain * 0.2 + crack * 0.22,
				0.88 + grain * 0.1 + crack * 0.12,
				0.98,
				1.0
			)
			over_img.set_pixel(x, y, over_c)
			var under_c := Color(
				0.28 + (1.0 - crack) * 0.25 + grain * 0.1,
				0.48 + (1.0 - crack) * 0.2,
				0.72 + grain * 0.15,
				1.0
			)
			under_img.set_pixel(x, y, under_c)
	var normal_img := Image.create(res, res, false, Image.FORMAT_RGBA8)
	for y in res:
		for x in res:
			var xl := height[y * res + ((x - 1 + res) % res)]
			var xr := height[y * res + ((x + 1) % res)]
			var yd := height[((y - 1 + res) % res) * res + x]
			var yu := height[((y + 1) % res) * res + x]
			var dx := (xl - xr) * 3.5
			var dy := (yd - yu) * 3.5
			var n := Vector3(dx, dy, 1.0).normalized()
			normal_img.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5))
	_host._ice_tex_over = ImageTexture.create_from_image(over_img)
	_host._ice_tex_under = ImageTexture.create_from_image(under_img)
	_host._ice_tex_normal = ImageTexture.create_from_image(normal_img)


func _ice_hash2(x: float, y: float) -> float:
	var n := sin(x * 127.1 + y * 311.7) * 43758.5453
	return n - floor(n)


func _disable_subtree_shadows(root: Node) -> void:
	if root == null:
		return
	if root is GeometryInstance3D:
		(root as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in root.get_children():
		_disable_subtree_shadows(c)





func _place_along(path: String, dist: float, lateral: float, y: float, target_height: float, yaw: float = 0.0) -> void:
	var n: Node3D = _host._instance_fitted(path, target_height, yaw)
	if n == null:
		return
	var holder := Node3D.new()
	_host._world.add_child(holder)
	_path_place(holder, dist, lateral, y, 0.0)
	holder.add_child(n)


func _place_model(path: String, pos: Vector3, target_height: float, yaw: float = 0.0) -> void:
	var n: Node3D = _host._instance_fitted(path, target_height, yaw)
	if n == null:
		return
	var holder := Node3D.new()
	holder.position = pos
	holder.add_child(n)
	_host._world.add_child(holder)


func _load_level_bundle(level_id: int) -> void:
	_host._level_id = clampi(level_id, 1, CapybaraLevelCatalog.LEVEL_COUNT)
	_host._level_cfg = CapybaraLevelCatalog.load_level(_host._level_id)
	_host._theme_cfg = CapybaraLevelCatalog.load_theme_for_level(_host._level_cfg)
	_apply_theme_environment()


func _load_custom_level_bundle(custom_id: String) -> void:
	var CustomLevels := load("res://assets/maps/route_levels/capybara_rush/level_editor/capybara_custom_levels.gd")
	if CustomLevels == null:
		push_error("CapybaraCustomLevels missing")
		return
	var cfg: Dictionary = CustomLevels.load_level_config(custom_id)
	if cfg.is_empty():
		push_warning("Custom level not found: %s" % custom_id)
		_load_level_bundle(1)
		return
	_host._level_id = 0
	_host._level_cfg = cfg
	_host._theme_cfg = CapybaraLevelCatalog.load_theme_for_level(_host._level_cfg)
	_apply_theme_environment()


func _apply_theme_environment() -> void:
	if _host._world_env != null and _host._world_env.environment != null:
		var env: Environment = _host._world_env.environment
		env.background_color = CapybaraLevelCatalog.color3(_host._theme_cfg.get("sky_color"), env.background_color)
		env.ambient_light_color = CapybaraLevelCatalog.color3(_host._theme_cfg.get("ambient_color"), env.ambient_light_color)
		env.ambient_light_energy = float(_host._theme_cfg.get("ambient_energy", env.ambient_light_energy))
	if _host._sun_light != null:
		_host._sun_light.light_color = CapybaraLevelCatalog.color3(_host._theme_cfg.get("sun_color"), _host._sun_light.light_color)
		_host._sun_light.light_energy = float(_host._theme_cfg.get("sun_energy", _host._sun_light.light_energy))


func _theme_prop_path(key: String, fallback: String) -> String:
	var props: Variant = _host._theme_cfg.get("props", {})
	if typeof(props) != TYPE_DICTIONARY:
		return fallback
	var p := String((props as Dictionary).get(key, ""))
	if p.is_empty():
		return fallback
	if _model_path_available(p):
		return p
	if CapybaraWebConfig.cdn_enabled() and p.ends_with(".glb"):
		return p
	return fallback


func _theme_obstacle_path(key: String) -> String:
	var obs: Variant = _host._theme_cfg.get("obstacles", {})
	if typeof(obs) != TYPE_DICTIONARY:
		return ""
	var raw: Variant = (obs as Dictionary).get(key, null)
	if raw == null:
		return ""
	var p := str(raw)
	if p.is_empty() or p == "<null>" or p == "null":
		return ""
	if _model_path_available(p):
		return p
	if CapybaraWebConfig.cdn_enabled() and p.ends_with(".glb"):
		return p
	return ""


func _model_path_available(p: String) -> bool:
	if ResourceLoader.exists(p) or FileAccess.file_exists(p):
		return true
	if CapybaraWebConfig.cdn_enabled():
		return FileAccess.file_exists(CapybaraWebConfig.cache_path_for_res_model(p))
	return false
