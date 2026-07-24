extends Node3D

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")

const SHIP_MOVE_SPEED := 8.5
const SHIP_VERTICAL_SPEED := 5.5
const SHIP_ENTRY_SURFACE_RADIUS := 1.9
const SHIP_GALAXY_MARGIN := 16.0
const SHIP_LANE_BOUNDARY := 13.0
const SHIP_MIN_HEIGHT := 0.75
const SHIP_MAX_HEIGHT := 8.5
const SHIP_MAX_PITCH_DEG := 24.0
const SHIP_MAX_ROLL_DEG := 18.0
const SHIP_PLANET_CLEARANCE := 0.8
const SHIP_CAMERA_OFFSET := Vector3(0.0, 5.2, 12.0)

@onready var camera_rig: Node3D = $CameraRig
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var systems_root: Node3D = $SystemsRoot
@onready var ui_layer: CanvasLayer = $UI

@onready var title_label: Label = $UI/TopBar/TitleLabel
@onready var system_name_label: Label = $UI/TopBar/SystemNameLabel
@onready var system_subtitle_label: Label = $UI/TopBar/SystemSubtitleLabel
@onready var hint_label: Label = $UI/BottomHint
@onready var info_panel: PanelContainer = $UI/InfoPanel
@onready var planet_name_label: Label = $UI/InfoPanel/Margin/VBox/PlanetName
@onready var planet_en_label: Label = $UI/InfoPanel/Margin/VBox/PlanetEn
@onready var planet_desc_label: Label = $UI/InfoPanel/Margin/VBox/PlanetDesc
@onready var planet_stats_label: Label = $UI/InfoPanel/Margin/VBox/PlanetStats
@onready var explore_button: Button = $UI/InfoPanel/Margin/VBox/ModeRow/ExploreButton
@onready var runner_button: Button = $UI/InfoPanel/Margin/VBox/ModeRow/RunnerButton
@onready var ship_label: Label = $UI/InfoPanel/Margin/VBox/ShipLabel
@onready var ship_select: OptionButton = $UI/InfoPanel/Margin/VBox/ShipSelect
@onready var system_dots: HBoxContainer = $UI/SystemDots

var _system_nodes: Array[Node3D] = []
var _planet_nodes: Array[Dictionary] = []
var _current_system_index := 0
var _selected_planet_id := ""
var _ship_preview_root: Node3D
var _ship_attitude_pivot: Node3D
var _ship_preview_model: Node3D
var _ship_planet_id := ""
var _near_planet_id := ""
var _ship_heading := Vector3.FORWARD
var _ship_pitch_deg := 0.0
var _ship_roll_deg := 0.0
var _camera_tween: Tween
var _transitioning := false
var _hover_planet_id := ""
var _time := 0.0


func _ready() -> void:
	add_to_group("GalaxyMapScene")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	title_label.text = "星火信使：黎明线"
	hint_label.text = "WASD 驾驶飞船  ·  Space/Shift 升降  ·  靠近星球后 Enter/按钮进入  ·  ← → 快速切换"
	explore_button.pressed.connect(_on_explore_pressed)
	runner_button.pressed.connect(_on_runner_pressed)
	ship_select.item_selected.connect(_on_ship_selected)
	_build_starfield()
	_build_systems()
	_build_ship_selector()
	_build_ship_preview()
	_build_system_dots()
	_focus_system(0, false)
	if _planet_nodes.size() > 0:
		var first_planet_id := String(_planet_nodes[0]["id"])
		_place_ship_at_planet(first_planet_id)
		_select_planet(first_planet_id, false, false)


func _process(delta: float) -> void:
	_time += delta
	_update_planet_orbits(delta)
	_update_ship_control(delta)
	_update_current_system_from_ship()
	_update_nearest_planet_gate()
	_update_selection_pulse()
	if _ship_preview_root != null:
		_orient_camera_to_ship(delta)


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	if event.is_action_pressed("ui_left"):
		_switch_system(-1)
	elif event.is_action_pressed("ui_right"):
		_switch_system(1)
	elif event.is_action_pressed("ui_accept") and _can_enter_selected_planet():
		_on_runner_pressed()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click and _can_enter_selected_planet():
			_on_runner_pressed()
		elif event.pressed:
			_try_pick_planet(event.position)


func _build_starfield() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 918273
	var root := Node3D.new()
	root.name = "Starfield"
	add_child(root)
	var star_material := StandardMaterial3D.new()
	star_material.albedo_color = Color(1, 1, 1, 0.85)
	star_material.emission_enabled = true
	star_material.emission = Color(0.85, 0.92, 1.0)
	star_material.emission_energy_multiplier = 1.6
	star_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	for i in 420:
		var star := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = rng.randf_range(0.015, 0.05)
		mesh.height = mesh.radius * 2.0
		mesh.material = star_material
		star.mesh = mesh
		star.position = Vector3(
			rng.randf_range(-80.0, 80.0),
			rng.randf_range(-40.0, 40.0),
			rng.randf_range(-80.0, 80.0)
		)
		root.add_child(star)


func _build_systems() -> void:
	for system_index in PlanetDatabase.STAR_SYSTEMS.size():
		var system: Dictionary = PlanetDatabase.STAR_SYSTEMS[system_index]
		var system_node := Node3D.new()
		system_node.name = String(system["id"])
		system_node.position = Vector3(system_index * 34.0, 0.0, 0.0)
		systems_root.add_child(system_node)
		_system_nodes.append(system_node)

		_add_central_star(system_node, system)
		var system_planets: Array[Dictionary] = []
		for planet_entry in system["planets"]:
			system_planets.append(_create_planet(system_node, planet_entry, system_index))
		_planet_nodes.append_array(system_planets)
		_connect_planets_in_system(system_node, system_planets)


func _add_central_star(parent: Node3D, system: Dictionary) -> void:
	var star_root := Node3D.new()
	star_root.name = "CentralStar"
	parent.add_child(star_root)

	var model := _load_gltf_model(PlanetDatabase.STAR_MODEL)
	if model != null:
		star_root.add_child(model)
		_fit_model_to_diameter(model, PlanetDatabase.STAR_VISUAL_SIZE)
	else:
		push_warning("GalaxyMap: 恒星 GLB 加载失败，使用程序球体替代: %s" % PlanetDatabase.STAR_MODEL)
		var fallback := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = PlanetDatabase.STAR_VISUAL_SIZE * 0.5
		mesh.height = PlanetDatabase.STAR_VISUAL_SIZE
		mesh.radial_segments = 24
		mesh.rings = 16
		var mat := StandardMaterial3D.new()
		mat.albedo_color = system["star_color"]
		mat.emission_enabled = true
		mat.emission = system["star_emission"]
		mat.emission_energy_multiplier = 2.4
		mat.roughness = 0.35
		mesh.material = mat
		fallback.mesh = mesh
		star_root.add_child(fallback)

	var glow := MeshInstance3D.new()
	var glow_mesh := SphereMesh.new()
	glow_mesh.radius = PlanetDatabase.STAR_VISUAL_SIZE * 0.68
	glow_mesh.height = PlanetDatabase.STAR_VISUAL_SIZE * 1.36
	var glow_mat := StandardMaterial3D.new()
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color = Color(system["star_emission"], 0.12)
	glow_mat.emission_enabled = true
	glow_mat.emission = system["star_emission"]
	glow_mat.emission_energy_multiplier = 0.8
	glow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	glow_mesh.material = glow_mat
	glow.mesh = glow_mesh
	star_root.add_child(glow)


func _create_planet(parent: Node3D, planet_entry: Dictionary, system_index: int) -> Dictionary:
	var pivot := Node3D.new()
	pivot.name = "PlanetPivot_%s" % planet_entry["id"]
	parent.add_child(pivot)

	var target_diameter := float(planet_entry["size"]) * PlanetDatabase.PLANET_VISUAL_SIZE
	var visual_radius := target_diameter * 0.5
	var body := Node3D.new()
	body.name = "Body"
	pivot.add_child(body)

	var model_path := PlanetDatabase.get_planet_model_path(planet_entry)
	var model := _load_gltf_model(model_path)
	if model != null:
		body.add_child(model)
		_fit_model_to_diameter(model, target_diameter)
	else:
		push_warning("GalaxyMap: GLB 加载失败，使用程序球体替代: %s (planet=%s)" % [model_path, planet_entry["id"]])
		var fallback := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = visual_radius
		mesh.height = target_diameter
		mesh.radial_segments = 28
		mesh.rings = 18
		var mat := StandardMaterial3D.new()
		mat.albedo_color = planet_entry["color"]
		mat.emission_enabled = true
		mat.emission = planet_entry["emission"]
		mat.emission_energy_multiplier = 1.15
		mesh.material = mat
		fallback.mesh = mesh
		body.add_child(fallback)

	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = visual_radius * 1.28
	torus.outer_radius = visual_radius * 1.58
	torus.rings = 16
	torus.ring_segments = 32
	var ring_mat := StandardMaterial3D.new()
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.albedo_color = planet_entry["ring_color"]
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(planet_entry["emission"], 0.35)
	ring_mat.emission_energy_multiplier = 0.9
	ring_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	torus.material = ring_mat
	ring.mesh = torus
	ring.rotation_degrees = Vector3(68, 18, 8)
	ring.name = "Ring"
	ring.visible = false
	pivot.add_child(ring)

	var area := Area3D.new()
	area.name = "PickArea"
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = visual_radius * 1.12
	shape.shape = sphere
	area.add_child(shape)
	pivot.add_child(area)

	var path := MeshInstance3D.new()
	path.name = "OrbitPath"
	parent.add_child(path)
	_draw_orbit_path(path, float(planet_entry["orbit_radius"]))

	var entry := {
		"id": String(planet_entry["id"]),
		"system_index": system_index,
		"pivot": pivot,
		"body": body,
		"ring": ring,
		"area": area,
		"data": planet_entry,
		"visual_radius": visual_radius,
		"base_scale": 1.0,
	}
	area.input_event.connect(_on_planet_input.bind(entry))
	area.mouse_entered.connect(_on_planet_hover.bind(entry))
	return entry


func _draw_orbit_path(path_node: MeshInstance3D, radius: float) -> void:
	var im := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1, 1, 1, 0.14)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	path_node.mesh = im
	path_node.material_override = mat
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in 65:
		var t := float(i) / 64.0 * TAU
		im.surface_add_vertex(Vector3(cos(t) * radius, 0.0, sin(t) * radius))
	im.surface_end()


func _connect_planets_in_system(system_node: Node3D, planets: Array[Dictionary]) -> void:
	if planets.size() < 2:
		return
	var lines := MeshInstance3D.new()
	lines.name = "PlanetLinks"
	system_node.add_child(lines)
	var im := ImmediateMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.82, 0.45, 0.22)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	lines.mesh = im
	lines.material_override = mat
	for i in planets.size() - 1:
		im.surface_begin(Mesh.PRIMITIVE_LINES)
		im.surface_add_vertex(planets[i]["pivot"].position)
		im.surface_add_vertex(planets[i + 1]["pivot"].position)
		im.surface_end()


func _build_system_dots() -> void:
	for i in PlanetDatabase.STAR_SYSTEMS.size():
		var dot := Label.new()
		dot.text = "●"
		dot.add_theme_font_size_override("font_size", 18)
		dot.modulate = Color(1, 1, 1, 0.35)
		system_dots.add_child(dot)


func _build_ship_selector() -> void:
	ship_select.clear()
	for index in PlanetDatabase.SHIPS.size():
		var ship: Dictionary = PlanetDatabase.SHIPS[index]
		ship_select.add_item("%s · %s" % [String(ship["name"]), String(ship["role"])], index)
		if String(ship["id"]) == Global.selected_ship_id:
			ship_select.select(index)
	_update_ship_label()


func _build_ship_preview() -> void:
	_ship_preview_root = Node3D.new()
	_ship_preview_root.name = "SelectedShipPreview"
	add_child(_ship_preview_root)
	_ship_attitude_pivot = Node3D.new()
	_ship_attitude_pivot.name = "AttitudePivot"
	_ship_preview_root.add_child(_ship_attitude_pivot)
	_refresh_ship_preview()


func _update_system_dots() -> void:
	for i in system_dots.get_child_count():
		var dot: Label = system_dots.get_child(i)
		dot.modulate = Color(1.0, 0.82, 0.35, 1.0) if i == _current_system_index else Color(1, 1, 1, 0.35)


func _update_planet_orbits(delta: float) -> void:
	for entry in _planet_nodes:
		var data: Dictionary = entry["data"]
		var pivot: Node3D = entry["pivot"]
		var tilt := deg_to_rad(float(data["orbit_tilt_deg"]))
		var angle := _time * float(data["orbit_speed"]) + float(data["orbit_phase"])
		var radius := float(data["orbit_radius"])
		var local := Vector3(cos(angle) * radius, sin(angle) * sin(tilt) * radius * 0.35, sin(angle) * radius)
		pivot.position = local
		pivot.look_at(pivot.position + Vector3(0, 0.2, 0.1), Vector3.UP)
		var body: Node3D = entry["body"]
		body.rotate_y(delta * float(entry["data"].get("spin_speed", 0.18)))
	if _ship_preview_root != null and _ship_planet_id != "" and not _is_ship_being_piloted():
		_update_ship_preview_position()


func _update_selection_pulse() -> void:
	for entry in _planet_nodes:
		var body: Node3D = entry["body"]
		var ring: MeshInstance3D = entry["ring"]
		var planet_id := String(entry["id"])
		var selected := planet_id == _selected_planet_id
		var hovered := planet_id == _hover_planet_id
		var pulse_factor := 1.0 + sin(_time * 4.0) * 0.04 if selected else 1.0
		var scale_factor: float = pulse_factor * (1.08 if selected else 1.02 if hovered else 1.0)
		body.scale = Vector3.ONE * scale_factor
		ring.visible = selected or hovered
	if _ship_attitude_pivot != null and not _is_ship_being_piloted():
		_ship_attitude_pivot.rotation_degrees.y += 12.0 * get_process_delta_time()


func _update_ship_preview_position() -> void:
	if _ship_preview_root == null or _ship_planet_id == "":
		return
	var entry := _find_planet_entry(_ship_planet_id)
	if entry.is_empty():
		return
	var pivot: Node3D = entry["pivot"]
	_ship_preview_root.global_position = _ship_dock_position(pivot.global_position)


func _ship_dock_position(planet_position: Vector3) -> Vector3:
	return planet_position + Vector3(1.25, 0.75, 0.0)


func _place_ship_at_planet(planet_id: String) -> void:
	if _ship_preview_root == null:
		return
	var entry := _find_planet_entry(planet_id)
	if entry.is_empty():
		return
	var pivot: Node3D = entry["pivot"]
	_ship_planet_id = planet_id
	_near_planet_id = planet_id
	_ship_preview_root.global_position = _ship_dock_position(pivot.global_position)
	_ship_preview_root.rotation = Vector3.ZERO
	if _ship_attitude_pivot != null:
		_ship_attitude_pivot.rotation = Vector3.ZERO
	_ship_heading = Vector3.FORWARD
	_ship_pitch_deg = 0.0
	_ship_roll_deg = 0.0


func _is_ship_being_piloted() -> bool:
	return _ship_planet_id == ""


func _update_ship_control(delta: float) -> void:
	if _ship_preview_root == null or _transitioning:
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var vertical_input := Input.get_action_strength("jump") - Input.get_action_strength("shift")
	if input_dir.length() <= 0.001 and absf(vertical_input) <= 0.001:
		_update_ship_attitude(Vector3.ZERO, 0.0, delta)
		return
	_ship_planet_id = ""
	var move_basis := _get_ship_move_basis()
	var right: Vector3 = move_basis.x
	var forward: Vector3 = move_basis.z
	var horizontal_movement := right * input_dir.x + forward * -input_dir.y
	var velocity := Vector3.ZERO
	if horizontal_movement.length() > 0.001:
		velocity = horizontal_movement.normalized() * SHIP_MOVE_SPEED
	if absf(vertical_input) > 0.001:
		velocity.y = vertical_input * SHIP_VERTICAL_SPEED
	var next_position := _ship_preview_root.global_position + velocity * delta
	next_position = _clamp_ship_to_galaxy(next_position)
	next_position = _push_ship_out_of_planets(next_position)
	next_position.y = clampf(next_position.y, SHIP_MIN_HEIGHT, SHIP_MAX_HEIGHT)
	_ship_preview_root.global_position = next_position
	_update_ship_attitude(velocity, input_dir.x, delta)


func _get_ship_move_basis() -> Basis:
	var right := camera.global_transform.basis.x
	var forward := -camera.global_transform.basis.z
	right.y = 0.0
	forward.y = 0.0
	if right.length() <= 0.001 or forward.length() <= 0.001:
		return Basis.IDENTITY
	return Basis(right.normalized(), Vector3.UP, forward.normalized())


func _update_ship_attitude(velocity: Vector3, turn_input: float, delta: float) -> void:
	if _ship_attitude_pivot == null:
		return
	var attitude_weight := 1.0 - exp(-9.0 * delta)
	var roll_target := -turn_input * SHIP_MAX_ROLL_DEG if velocity.length() > 0.001 else 0.0
	_ship_roll_deg = lerpf(_ship_roll_deg, roll_target, attitude_weight)
	if velocity.length() > 0.001:
		_ship_heading = velocity.normalized()
		# GLB 机头在 +Z，looking_at 对齐的是 -Z，因此取反速度方向
		var target_basis := Basis.looking_at(-_ship_heading, Vector3.UP)
		target_basis = target_basis.rotated(target_basis.z, deg_to_rad(_ship_roll_deg))
		_ship_attitude_pivot.basis = _ship_attitude_pivot.basis.slerp(target_basis, attitude_weight)


func _clamp_ship_to_galaxy(world_position: Vector3) -> Vector3:
	if _system_nodes.is_empty():
		return world_position
	var first_origin := _system_nodes[0].global_position
	var last_origin := _system_nodes[_system_nodes.size() - 1].global_position
	world_position.x = clampf(world_position.x, first_origin.x - SHIP_GALAXY_MARGIN, last_origin.x + SHIP_GALAXY_MARGIN)
	world_position.z = clampf(world_position.z, first_origin.z - SHIP_LANE_BOUNDARY, first_origin.z + SHIP_LANE_BOUNDARY)
	world_position.y = clampf(world_position.y, SHIP_MIN_HEIGHT, SHIP_MAX_HEIGHT)
	return world_position


func _push_ship_out_of_planets(world_position: Vector3) -> Vector3:
	for entry in _planet_nodes:
		if int(entry["system_index"]) != _current_system_index:
			continue
		var pivot: Node3D = entry["pivot"]
		var center := pivot.global_position
		var radius := float(entry.get("visual_radius", entry["data"]["size"])) + SHIP_PLANET_CLEARANCE
		var offset := world_position - center
		var distance := offset.length()
		if distance >= radius:
			continue
		var direction := offset.normalized() if distance > 0.001 else Vector3.UP
		world_position = center + direction * radius
	return world_position


func _update_current_system_from_ship() -> void:
	if _ship_preview_root == null or _system_nodes.is_empty():
		return
	var nearest_index := _current_system_index
	var nearest_distance := INF
	for i in _system_nodes.size():
		var distance := _ship_preview_root.global_position.distance_to(_system_nodes[i].global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = i
	if nearest_index == _current_system_index:
		return
	_current_system_index = nearest_index
	_near_planet_id = ""
	_update_entry_buttons(false)
	_update_system_dots()
	var system: Dictionary = PlanetDatabase.STAR_SYSTEMS[_current_system_index]
	system_name_label.text = String(system["name"])
	system_subtitle_label.text = String(system["subtitle"])


func _update_nearest_planet_gate() -> void:
	if _ship_preview_root == null:
		return
	var nearest_id := ""
	var nearest_surface_distance := INF
	for entry in _planet_nodes:
		if int(entry["system_index"]) != _current_system_index:
			continue
		var meta: Dictionary = PlanetDatabase.get_planet_meta(String(entry["id"]))
		if not bool(meta["unlocked"]) or bool(meta.get("display_only", false)):
			continue
		var pivot: Node3D = entry["pivot"]
		var surface_distance := _ship_surface_distance_to_planet(entry)
		if surface_distance < nearest_surface_distance:
			nearest_surface_distance = surface_distance
			nearest_id = String(entry["id"])
	var in_range := nearest_id != "" and nearest_surface_distance <= SHIP_ENTRY_SURFACE_RADIUS
	if in_range:
		_near_planet_id = nearest_id
		if _selected_planet_id != nearest_id:
			_select_planet(nearest_id, false, false)
		else:
			_update_entry_buttons(_can_enter_selected_planet())
	elif not in_range and _near_planet_id != "":
		_near_planet_id = ""
		_update_entry_buttons(false)


func _ship_surface_distance_to_planet(entry: Dictionary) -> float:
	if _ship_preview_root == null:
		return INF
	var pivot: Node3D = entry["pivot"]
	var radius := float(entry.get("visual_radius", entry["data"]["size"]))
	return maxf(0.0, _ship_preview_root.global_position.distance_to(pivot.global_position) - radius)


func _switch_system(direction: int) -> void:
	var next := wrapi(_current_system_index + direction, 0, _system_nodes.size())
	if next == _current_system_index:
		return
	_focus_system(next, true)
	var first_in_system := _first_planet_in_system(next)
	if first_in_system != "":
		_place_ship_at_planet(first_in_system)
		_select_planet(first_in_system, true, false)


func _first_planet_in_system(system_index: int) -> String:
	for entry in _planet_nodes:
		if int(entry["system_index"]) == system_index:
			return String(entry["id"])
	return ""


func _focus_system(system_index: int, animated: bool) -> void:
	_current_system_index = system_index
	var system: Dictionary = PlanetDatabase.STAR_SYSTEMS[system_index]
	var focus_world := _system_nodes[system_index].global_position + Vector3(system["camera_focus"])
	var distance := float(system["camera_distance"])
	var target_pos := focus_world + Vector3(0.0, 2.2, distance)
	_update_system_dots()
	system_name_label.text = String(system["name"])
	system_subtitle_label.text = String(system["subtitle"])
	if animated:
		_transitioning = true
		if _camera_tween:
			_camera_tween.kill()
		_camera_tween = create_tween()
		_camera_tween.set_trans(Tween.TRANS_CUBIC)
		_camera_tween.set_ease(Tween.EASE_IN_OUT)
		_camera_tween.tween_property(camera_rig, "global_position", target_pos, 1.15)
		_camera_tween.finished.connect(func(): _transitioning = false)
	else:
		camera_rig.global_position = target_pos
	camera.look_at(focus_world, Vector3.UP)


func _orient_camera_to_planet(planet_id: String, delta: float) -> void:
	var entry := _find_planet_entry(planet_id)
	if entry.is_empty():
		return
	var pivot: Node3D = entry["pivot"]
	var look_target := pivot.global_position
	var desired := camera_rig.global_position.lerp(look_target + (camera_rig.global_position - look_target).normalized() * 14.0, delta * 1.5)
	camera_rig.global_position = desired
	camera.look_at(look_target, Vector3.UP)


func _orient_camera_to_ship(delta: float) -> void:
	if _ship_preview_root == null:
		return
	var look_target := _ship_preview_root.global_position
	# 相机只在世界空间跟随飞船位置，不随飞船 yaw 旋转，WASD 始终相对屏幕方向
	var desired := look_target + SHIP_CAMERA_OFFSET
	var follow_weight := 1.0 - exp(-4.5 * delta)
	camera_rig.global_position = camera_rig.global_position.lerp(desired, follow_weight)
	camera.look_at(look_target, Vector3.UP)


func _find_planet_entry(planet_id: String) -> Dictionary:
	for entry in _planet_nodes:
		if String(entry["id"]) == planet_id:
			return entry
	return {}


func _try_pick_planet(screen_pos: Vector2) -> void:
	var hit := _raycast_planet(screen_pos)
	if hit != "":
		_select_planet(hit, true)


func _raycast_planet(screen_pos: Vector2) -> String:
	var origin := camera.project_ray_origin(screen_pos)
	var direction := camera.project_ray_normal(screen_pos)
	var best_id := ""
	var best_dist := INF
	for entry in _planet_nodes:
		if int(entry["system_index"]) != _current_system_index:
			continue
		var pivot: Node3D = entry["pivot"]
		var center := pivot.global_position
		var radius := float(entry.get("visual_radius", entry["data"]["size"])) * 1.12
		var oc := origin - center
		var b := direction.dot(oc)
		var c := oc.dot(oc) - radius * radius
		var disc := b * b - c
		if disc < 0.0:
			continue
		var t := -b - sqrt(disc)
		if t > 0.0 and t < best_dist:
			best_dist = t
			best_id = String(entry["id"])
	return best_id


func _on_planet_input(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape: int, entry: Dictionary) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_planet(String(entry["id"]), true, false)
		if event.double_click and _can_enter_selected_planet():
			_on_runner_pressed()


func _on_planet_hover(entry: Dictionary) -> void:
	_hover_planet_id = String(entry["id"])


func _select_planet(planet_id: String, animated: bool, _move_ship: bool = true) -> void:
	if int(_find_planet_entry(planet_id).get("system_index", -1)) != _current_system_index:
		return
	_selected_planet_id = planet_id
	var meta := PlanetDatabase.get_planet_meta(planet_id)
	info_panel.visible = true
	planet_name_label.text = meta["name"]
	planet_en_label.text = meta.get("name_en", "")
	planet_desc_label.text = meta["description"]
	planet_stats_label.text = "所属星域：%s\n可选模式：探索 / 跑酷\n任务货物：%s\n目标据点：%s\n追猎威胁：%s\n难度：%s" % [
		meta["system_name"],
		meta["cargo"],
		meta["hearth"],
		meta["chaser"],
		"★".repeat(int(meta["difficulty"])) if int(meta["difficulty"]) > 0 else "—",
	]
	var playable := bool(meta["unlocked"]) and not bool(meta.get("display_only", false))
	_update_entry_buttons(playable and planet_id == _near_planet_id)
	if animated and _ship_preview_root == null:
		_orient_camera_to_planet(planet_id, 0.45)


func _refresh_ship_preview() -> void:
	if _ship_preview_root == null:
		return
	if _ship_preview_model != null:
		_ship_preview_model.queue_free()
		_ship_preview_model = null
	var ship: Dictionary = PlanetDatabase.get_ship(Global.selected_ship_id)
	_ship_preview_model = _load_gltf_model(String(ship["path"]))
	if _ship_preview_model == null:
		_ship_preview_model = _make_ship_preview(ship)
	else:
		var ship_size := float(ship.get("visual_size", PlanetDatabase.SHIP_VISUAL_SIZE))
		_fit_model_to_diameter(_ship_preview_model, ship_size)
	_ship_attitude_pivot.add_child(_ship_preview_model)
	_ship_preview_model.rotation_degrees = Vector3(-8.0, float(ship.get("preview_yaw", 0.0)), 0.0)
	_update_ship_preview_position()


func _load_gltf_model(path: String) -> Node3D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var resource := ResourceLoader.load(path)
		if resource is PackedScene:
			return _ensure_node3d((resource as PackedScene).instantiate())
	if FileAccess.file_exists(path):
		var gltf := GLTFDocument.new()
		var state := GLTFState.new()
		if gltf.append_from_file(path, state) == OK:
			var generated := gltf.generate_scene(state)
			if generated is Node:
				return _ensure_node3d(generated as Node)
	return null


func _ensure_node3d(node: Node) -> Node3D:
	if node is Node3D:
		return node as Node3D
	var pivot := Node3D.new()
	pivot.name = "ModelPivot"
	pivot.add_child(node)
	return pivot


func _fit_model_to_diameter(model: Node3D, target_diameter: float) -> void:
	var bounds := _compute_local_bounds(model)
	if not bounds.has_volume():
		return
	var max_dim := maxf(maxf(bounds.size.x, bounds.size.y), bounds.size.z)
	if max_dim <= 0.0001:
		return
	var scale_factor := target_diameter / max_dim
	model.scale = Vector3.ONE * scale_factor
	bounds = _compute_local_bounds(model)
	model.position = -bounds.get_center()


func _compute_local_bounds(root: Node3D) -> AABB:
	var bounds := AABB()
	var started := false
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var mesh_bounds := mesh_instance.get_aabb()
		var transformed := mesh_instance.transform * mesh_bounds
		if not started:
			bounds = transformed
			started = true
		else:
			bounds = bounds.merge(transformed)
	return bounds


func _load_ship_model(path: String) -> Node3D:
	return _load_gltf_model(path)


func _make_ship_preview(ship: Dictionary) -> Node3D:
	var root := Node3D.new()
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.4, 0.28, 0.8)
	var mat := StandardMaterial3D.new()
	var ship_color: Color = ship.get("color", Color(0.42, 0.72, 1.0))
	mat.albedo_color = ship_color
	mat.emission_enabled = true
	mat.emission = ship_color.darkened(0.35)
	mat.emission_energy_multiplier = 0.8
	mesh.material = mat
	mesh_instance.mesh = mesh
	root.add_child(mesh_instance)
	var nose := MeshInstance3D.new()
	var nose_mesh := PrismMesh.new()
	nose_mesh.size = Vector3(0.5, 0.34, 0.84)
	nose_mesh.material = mat
	nose.mesh = nose_mesh
	nose.position = Vector3(0.95, 0.0, 0.0)
	nose.rotation_degrees.z = -90.0
	root.add_child(nose)
	return root


func _update_ship_label() -> void:
	var ship: Dictionary = PlanetDatabase.get_ship(Global.selected_ship_id)
	ship_label.text = "当前飞船：%s · %s" % [String(ship["name"]), String(ship["role"])]


func _on_ship_selected(index: int) -> void:
	if index < 0 or index >= PlanetDatabase.SHIPS.size():
		return
	var ship: Dictionary = PlanetDatabase.SHIPS[index]
	Global.set_selected_ship(String(ship["id"]))
	_update_ship_label()
	_refresh_ship_preview()


func _can_enter_selected_planet() -> bool:
	if _selected_planet_id == "" or _selected_planet_id != _near_planet_id:
		return false
	var meta: Dictionary = PlanetDatabase.get_planet_meta(_selected_planet_id)
	return bool(meta["unlocked"]) and not bool(meta.get("display_only", false))


func _update_entry_buttons(can_enter: bool) -> void:
	if can_enter:
		info_panel.visible = true
	explore_button.disabled = not can_enter
	runner_button.disabled = not can_enter
	explore_button.text = "探索模式" if can_enter else "靠近星球开启"
	runner_button.text = "跑酷模式" if can_enter else "靠近星球开启"


func _on_explore_pressed() -> void:
	if not _can_enter_selected_planet():
		return
	Global.exploration_planet_id = _selected_planet_id
	Global.change_game_scene(PlanetDatabase.EXPLORATION_SCENE)


func _on_runner_pressed() -> void:
	if not _can_enter_selected_planet():
		return
	Global.runner_planet_id = _selected_planet_id
	Global.change_game_scene(PlanetDatabase.RUNNER_SCENE)


func _on_back_pressed() -> void:
	get_tree().quit()
