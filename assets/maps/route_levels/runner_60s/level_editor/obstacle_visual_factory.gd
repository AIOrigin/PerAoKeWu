class_name ObstacleVisualFactory
extends RefCounted

## 与 runner_60s 同款障碍外观：供关卡编辑器预览（及后续共用）

const LANE_WIDTH := 4.0
const RUNWAY_OBSTACLE_SPAN_INSET := 0.96
const RUNWAY_OBSTACLE_SPAN := LANE_WIDTH * 3.0 * RUNWAY_OBSTACLE_SPAN_INSET
const SLIDE_GATE_TOP := 3.08
const SLIDE_GATE_OPEN_BOTTOM := 1.22
const SLIDE_GATE_PILLAR_OUTSIDE_MARGIN := 0.55
const SLIDE_GATE_MODEL_BBOX_WIDTH := 1.0
const SLIDE_GATE_PREVIEW_ROAD_HALF := 6.4
const ORB_TARGET_HEIGHT := 2.65
const ORB_RUNWAY_WIDTH := LANE_WIDTH * 3.0
const ORB_SMALL_SPAN := ORB_RUNWAY_WIDTH / 9.0
const ORB_LARGE_SPAN := ORB_RUNWAY_WIDTH * 0.5
const ORB_SMALL_SCALE := ORB_SMALL_SPAN / ORB_TARGET_HEIGHT
const ORB_LARGE_SCALE := ORB_LARGE_SPAN / ORB_TARGET_HEIGHT
const ORB_VISUAL_BASE_Y := 0.85
const IMPORTED_SCENE_FALLBACKS := {
	"res://assets/maps/route_levels/models/obstacles/jump/barrier_01.glb": "res://.godot/imported/障碍物-需跳跃.glb-46f57db02e27254a677214f954ab0d83.scn",
	"res://assets/maps/route_levels/models/obstacles/jump/barrier_02.glb": "res://.godot/imported/障碍物-需跳跃2.glb-c8c9938e154747024ae7ac221ab7db3a.scn",
}

var _jump_paths: Array[String] = []
var _slide_paths: Array[String] = []
var _slide_scene: PackedScene
var _scene_cache: Dictionary = {}


func configure_from_level_config(level_config: Script) -> void:
	_jump_paths.clear()
	_slide_paths.clear()
	_slide_scene = null
	_scene_cache.clear()
	if level_config == null or not level_config.has_method("get_assets"):
		return
	var assets: Dictionary = level_config.get_assets()
	for path in assets.get("jump_obstacles", []):
		_jump_paths.append(String(path))
	for path in assets.get("slide_obstacles", []):
		_slide_paths.append(String(path))
	if _slide_paths.is_empty() and assets.has("slide_obstacle"):
		_slide_paths.append(String(assets.get("slide_obstacle")))
	var slide_path := _slide_paths[0] if not _slide_paths.is_empty() else String(assets.get("slide_obstacle", ""))
	_slide_scene = _load_scene(slide_path, false)


func build(item: Dictionary) -> Node3D:
	var otype := String(item.get("type", "jump"))
	var root := Node3D.new()
	root.name = "%sPreview" % otype.capitalize()
	match otype:
		"slide", "high_bar":
			_build_high_bar(root, item)
		"orb":
			_build_energy_orb(root, item)
		"jump", "low_barrier":
			_build_jump_bar(root, item)
		_:
			_build_jump_bar(root, item)
	return root


static func uses_center_lane(otype: String) -> bool:
	return otype in ["slide", "high_bar", "main_block", "ramp"]


func _build_jump_bar(root: Node3D, item: Dictionary) -> void:
	var scene_index := _pick_jump_bar_scene_index(item)
	_add_jump_bar_visual(root, _jump_scene(scene_index), 1.2, RUNWAY_OBSTACLE_SPAN)


func _build_energy_orb(root: Node3D, item: Dictionary) -> void:
	var scene_index := _pick_energy_orb_scene_index(item)
	var roll := _orb_roll(item)
	var target_span := float(roll.get("span", ORB_SMALL_SPAN))
	var scene := _jump_scene(scene_index)
	var visual: Node3D
	if scene:
		visual = scene.instantiate() as Node3D
		visual.name = "JumpObstacleModel"
		root.add_child(visual)
		_fit_energy_orb_to_span(visual, target_span)
	else:
		visual = _add_scaled_model(root, null, "JumpObstacleModel", target_span, 0.0, Vector3.ZERO)
		_fit_energy_orb_to_span(visual, target_span)
	visual.position.y += ORB_VISUAL_BASE_Y


func _fit_energy_orb_to_span(model: Node3D, span: float) -> void:
	if model == null or span <= 0.0:
		return
	model.scale = Vector3.ONE
	model.position = Vector3.ZERO
	model.rotation = Vector3.ZERO
	var bounds := _aabb(model)
	var current := maxf(maxf(bounds.size.x, bounds.size.y), bounds.size.z)
	if current <= 0.001:
		model.scale = Vector3.ONE * span
		return
	model.scale = Vector3.ONE * (span / current)
	model.force_update_transform()
	bounds = _aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)


func _build_high_bar(root: Node3D, item: Dictionary = {}) -> void:
	var scene_index := _pick_slide_obstacle_scene_index(item)
	var asset_path := _slide_paths[scene_index] if scene_index < _slide_paths.size() else ""
	var span := _slide_gate_span_for_path(asset_path)
	var scene := _slide_scene_at(scene_index)
	if scene != null:
		_add_road_span_gate(root, scene, SLIDE_GATE_TOP, span)
	else:
		_add_slide_gate_visual(root, span, SLIDE_GATE_TOP, SLIDE_GATE_OPEN_BOTTOM)


func _build_train(root: Node3D, moving: bool) -> void:
	var visual := _add_scaled_model(
		root,
		_scene_by_hint(["坍塌广告牌", "billboard"], 2),
		"SlideRoadBlockAsset",
		2.35,
		0.0,
		Vector3.ZERO,
		LANE_WIDTH * 3.2
	)
	if moving:
		visual.rotation_degrees.y += 6.0


func _build_lane_block(root: Node3D, side: String) -> void:
	var blocked_x := [-LANE_WIDTH, 0.0] if side == "left" else [0.0, LANE_WIDTH]
	for i in blocked_x.size():
		var visual := _add_scaled_model(
			root,
			_scene_by_hint(["闪避柱", "全息闪避", "能量裂缝", "crack"], 1),
			"LaneBlockAsset_%d" % i,
			2.15,
			0.0,
			Vector3(blocked_x[i], 0.0, 0.0),
			LANE_WIDTH * 1.55
		)
		visual.position.z += -0.35 if i == 0 else 0.35


func _build_ramp(root: Node3D) -> void:
	var visual := _add_scaled_model(root, _jump_scene(1), "RampMarkerAsset", 1.2, 180.0, Vector3.ZERO)
	visual.rotation_degrees.x = -12.0


func _build_main_block(root: Node3D) -> void:
	var gate := MeshInstance3D.new()
	var gate_mesh := BoxMesh.new()
	gate_mesh.size = Vector3(LANE_WIDTH * 3.2, 0.22, 1.8)
	gate_mesh.material = _mat(Color(0.95, 0.32, 0.12, 0.7), Color(1.0, 0.4, 0.1), 2.4)
	gate.mesh = gate_mesh
	gate.position = Vector3(0.0, 0.12, 0.0)
	root.add_child(gate)
	for sx_f: float in [-1.0, 1.0]:
		var post := MeshInstance3D.new()
		var pm := BoxMesh.new()
		pm.size = Vector3(0.28, 2.4, 0.28)
		pm.material = _mat(Color(0.9, 0.35, 0.12), Color(1.0, 0.45, 0.15), 1.8)
		post.mesh = pm
		post.position = Vector3(sx_f * LANE_WIDTH * 1.45, 1.2, 0.0)
		root.add_child(post)
	var beam := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(LANE_WIDTH * 3.0, 0.22, 0.22)
	bm.material = _mat(Color(1.0, 0.4, 0.15), Color(1.0, 0.5, 0.2), 2.0)
	beam.mesh = bm
	beam.position = Vector3(0.0, 2.35, 0.0)
	root.add_child(beam)


func _build_turn_sign(root: Node3D, turn_type: String) -> void:
	var is_left := turn_type == "turn_left"
	var visual := _add_scaled_model(
		root,
		_jump_scene(0),
		"TurnMarkerAsset",
		1.05,
		180.0,
		Vector3(-0.45 if is_left else 0.45, 0.0, 0.0)
	)
	visual.rotation_degrees.y += -28.0 if is_left else 28.0


func _add_jump_bar_visual(root: Node3D, scene: PackedScene, target_height: float, target_span: float) -> void:
	if scene == null:
		_add_missing(root, "JumpObstacleModel", target_height)
		return
	var model := scene.instantiate() as Node3D
	model.name = "JumpObstacleModel"
	root.add_child(model)
	var bounds0 := _aabb(model)
	if bounds0.size.y <= 0.001:
		return
	var sy := target_height / maxf(bounds0.size.y, 0.001)
	var depth_scale := clampf(sy, 0.85, 2.8)
	var span_size := maxf(bounds0.size.x, bounds0.size.z)
	if bounds0.size.z >= bounds0.size.x:
		model.rotation_degrees.y = 90.0
		model.force_update_transform()
		var span_scale := target_span / maxf(span_size, 0.001)
		model.scale = Vector3(depth_scale, sy, span_scale)
	else:
		var span_scale := target_span / maxf(span_size, 0.001)
		model.scale = Vector3(span_scale, sy, depth_scale)
	model.force_update_transform()
	var bounds := _aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)


func _add_slide_gate_visual(root: Node3D, span: float, top_height: float, open_bottom: float) -> void:
	var gate_root := Node3D.new()
	gate_root.name = "SlideObstacleModel"
	root.add_child(gate_root)

	var half_span := span * 0.5
	var pillar_h := maxf(top_height - open_bottom, 0.45)
	var pillar_center_y := open_bottom + pillar_h * 0.5
	var pillar_mat := _mat(Color(0.28, 0.62, 0.98), Color(0.14, 0.38, 0.88), 1.05)

	for side in [-1, 1]:
		var pillar := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.34, pillar_h, 0.36)
		mesh.material = pillar_mat
		pillar.mesh = mesh
		pillar.position = Vector3(side * half_span, pillar_center_y, 0.0)
		gate_root.add_child(pillar)

	var beam := MeshInstance3D.new()
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(span * 0.98, 0.26, 0.4)
	beam_mesh.material = pillar_mat
	beam.mesh = beam_mesh
	beam.position = Vector3(0.0, top_height - 0.13, 0.0)
	gate_root.add_child(beam)

	var holo := MeshInstance3D.new()
	var holo_mesh := BoxMesh.new()
	holo_mesh.size = Vector3(span * 0.94, maxf(top_height - open_bottom, 0.35), 0.06)
	var holo_mat := _mat(Color(0.22, 0.55, 0.95, 0.62), Color(0.18, 0.62, 1.0), 1.05)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	holo_mesh.material = holo_mat
	holo.mesh = holo_mesh
	holo.position = Vector3(0.0, open_bottom + (top_height - open_bottom) * 0.5, 0.0)
	gate_root.add_child(holo)


func _add_road_span_gate(parent: Node3D, scene: PackedScene, target_height: float, target_span: float) -> void:
	if scene == null:
		_add_missing(parent, "SlideObstacleModel", target_height)
		return
	var model := scene.instantiate() as Node3D
	model.name = "SlideObstacleModel"
	parent.add_child(model)
	var bounds := _aabb(model)
	if bounds.size.y <= 0.001:
		return
	if bounds.size.z > bounds.size.x * 1.15:
		model.rotation_degrees.y = 90.0
		bounds = _aabb(model)
	model.scale = Vector3(
		target_span / maxf(bounds.size.x, 0.001),
		target_height / maxf(bounds.size.y, 0.001),
		target_span / maxf(bounds.size.x, 0.001)
	)
	bounds = _aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y - 0.04,
		-(bounds.position.z + bounds.size.z * 0.5)
	)


func _add_slide_curtain(root: Node3D) -> void:
	var curtain := MeshInstance3D.new()
	curtain.name = "SlideVisibilityCurtain"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(LANE_WIDTH * 3.15, 1.85, 0.22)
	var mat := _mat(Color(0.22, 0.55, 0.95, 0.32), Color(0.18, 0.62, 1.0), 1.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	curtain.mesh = mesh
	curtain.position = Vector3(0.0, 1.05, 0.0)
	root.add_child(curtain)


func _add_scaled_model(
	parent: Node3D,
	scene: PackedScene,
	model_name: String,
	target_height: float,
	yaw_degrees: float = 0.0,
	local_position: Vector3 = Vector3.ZERO,
	max_footprint: float = -1.0,
	max_scale_cap: float = 12.0
) -> Node3D:
	if scene == null:
		return _add_missing(parent, model_name, target_height, yaw_degrees, local_position)
	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees
	var bounds := _aabb(model)
	var characteristic := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if characteristic <= 0.001:
		model.scale = Vector3.ONE * (target_height / 2.0)
	else:
		var scale_factor := target_height / characteristic
		if max_scale_cap > 0.0:
			scale_factor = minf(scale_factor, max_scale_cap)
		model.scale = Vector3.ONE * scale_factor
	bounds = _aabb(model)
	if max_footprint > 0.0:
		var footprint := maxf(bounds.size.x, bounds.size.z)
		if footprint > max_footprint and footprint > 0.001:
			model.scale *= max_footprint / footprint
			bounds = _aabb(model)
	model.position += Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)
	return model


func _add_missing(
	parent: Node3D,
	model_name: String,
	target_height: float,
	yaw_degrees: float = 0.0,
	local_position: Vector3 = Vector3.ZERO
) -> Node3D:
	var model := Node3D.new()
	model.name = "%sMissing" % model_name
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees
	parent.add_child(model)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.75, maxf(target_height, 0.25), 0.75)
	mesh.material = _mat(Color(0.18, 0.32, 0.42), Color(0.25, 0.9, 1.0), 0.8)
	mi.mesh = mesh
	mi.position.y = maxf(target_height, 0.25) * 0.5
	model.add_child(mi)
	return model


func _jump_scene(index: int) -> PackedScene:
	if _jump_paths.is_empty():
		return null
	return _load_scene(_jump_paths[index % _jump_paths.size()])


func _is_energy_orb_asset_path(path: String) -> bool:
	return "energy_orb" in path or path.ends_with(".png") or path.ends_with(".webp")


func _jump_bar_path_indices() -> Array[int]:
	var out: Array[int] = []
	for i in range(_jump_paths.size()):
		if not _is_energy_orb_asset_path(_jump_paths[i]):
			out.append(i)
	return out


func _energy_orb_path_indices() -> Array[int]:
	var out: Array[int] = []
	for i in range(_jump_paths.size()):
		if _is_energy_orb_asset_path(_jump_paths[i]):
			out.append(i)
	return out


func _pick_jump_bar_scene_index(item: Dictionary) -> int:
	var indices := _jump_bar_path_indices()
	if indices.is_empty():
		return 0
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return indices[(absi(lane * 17 + dist_key)) % indices.size()]


func _pick_energy_orb_scene_index(item: Dictionary) -> int:
	var indices := _energy_orb_path_indices()
	if indices.is_empty():
		return 1
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return indices[(absi(lane * 13 + dist_key)) % indices.size()]


func _pick_slide_obstacle_scene_index(item: Dictionary) -> int:
	if _slide_paths.is_empty():
		return 0
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return (absi(lane * 19 + dist_key)) % _slide_paths.size()


func _slide_gate_model_pillar_half(asset_path: String) -> float:
	var lower := asset_path.to_lower()
	if "能量屏障" in asset_path or ("energy" in lower and "barrier" in lower):
		return 0.46
	return 0.5


func _slide_gate_span_for_path(asset_path: String) -> float:
	var pillar_half := SLIDE_GATE_PREVIEW_ROAD_HALF + SLIDE_GATE_PILLAR_OUTSIDE_MARGIN
	var model_pillar_half := _slide_gate_model_pillar_half(asset_path)
	return pillar_half * SLIDE_GATE_MODEL_BBOX_WIDTH / maxf(model_pillar_half, 0.001)


func _orb_roll(item: Dictionary) -> Dictionary:
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	var bucket := (int(dist_key / 7) + lane * 3 + 1) % 4
	var is_large := bucket == 0
	var tier := "large" if is_large else "small"
	var scale := ORB_LARGE_SCALE if is_large else ORB_SMALL_SCALE
	return {
		"tier": tier,
		"scale": scale,
		"span": ORB_LARGE_SPAN if is_large else ORB_SMALL_SPAN,
	}


func _orb_size_scale_for(item: Dictionary) -> float:
	return float(_orb_roll(item).get("scale", ORB_SMALL_SCALE))


func _slide_scene_at(index: int) -> PackedScene:
	if not _slide_paths.is_empty():
		return _load_scene(_slide_paths[index % _slide_paths.size()])
	return _slide_scene


func _scene_by_hint(hints: Array, fallback_index: int) -> PackedScene:
	for path in _slide_paths:
		var path_text := String(path)
		if path_text.ends_with(".png") or path_text.ends_with(".webp"):
			continue
		for hint in hints:
			if String(hint) in path_text:
				return _load_scene(path_text)
	if not _slide_paths.is_empty():
		return _slide_scene_at(fallback_index)
	return _slide_scene


func _load_scene(path: String, warn_if_missing: bool = true) -> PackedScene:
	if path == "":
		return null
	if path.ends_with(".png") or path.ends_with(".webp") or path.ends_with(".jpg") or path.ends_with(".jpeg"):
		return _sprite_scene(path, warn_if_missing)
	if _scene_cache.has(path):
		return _scene_cache[path] as PackedScene
	var scene := ResourceLoader.load(path) as PackedScene
	if scene:
		_scene_cache[path] = scene
		return scene
	var fallback_path: String = IMPORTED_SCENE_FALLBACKS.get(path, "")
	if not fallback_path.is_empty():
		scene = ResourceLoader.load(fallback_path) as PackedScene
		if scene:
			_scene_cache[path] = scene
			return scene
	if warn_if_missing:
		push_warning("ObstacleVisualFactory missing: %s" % path)
	return null


func _sprite_scene(path: String, warn_if_missing: bool) -> PackedScene:
	if _scene_cache.has(path):
		return _scene_cache[path] as PackedScene
	var tex: Texture2D = null
	var abs_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(abs_path):
		var img := Image.new()
		if img.load(abs_path) == OK:
			tex = ImageTexture.create_from_image(img)
	if tex == null and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		if warn_if_missing:
			push_warning("ObstacleVisualFactory sprite missing: %s" % path)
		return null
	var root := Node3D.new()
	root.name = "SpriteObstacle"
	var mesh_instance := MeshInstance3D.new()
	var quad := QuadMesh.new()
	var tw := maxf(float(tex.get_width()), 1.0)
	var th := maxf(float(tex.get_height()), 1.0)
	var aspect := tw / th
	if "phase_curtain" in path:
		quad.size = Vector2(1.0, 1.0 / maxf(aspect, 0.01))
	else:
		quad.size = Vector2(aspect, 1.0)
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.12
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = tex
	mat.albedo_color = Color.WHITE
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED if "phase_curtain" in path else BaseMaterial3D.BILLBOARD_FIXED_Y
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.7, 0.95)
	mat.emission_energy_multiplier = 0.45
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
		return null
	_scene_cache[path] = packed
	return packed


func _aabb(root: Node3D) -> AABB:
	var merged := AABB()
	var first := true
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var local_box := mesh_instance.mesh.get_aabb()
		for corner in [
			local_box.position,
			local_box.position + Vector3(local_box.size.x, 0, 0),
			local_box.position + Vector3(0, local_box.size.y, 0),
			local_box.position + Vector3(0, 0, local_box.size.z),
			local_box.position + Vector3(local_box.size.x, local_box.size.y, 0),
			local_box.position + Vector3(local_box.size.x, 0, local_box.size.z),
			local_box.position + Vector3(0, local_box.size.y, local_box.size.z),
			local_box.position + local_box.size,
		]:
			var world_point: Vector3 = mesh_instance.global_transform * corner
			var local_point: Vector3 = root.global_transform.affine_inverse() * world_point
			if first:
				merged = AABB(local_point, Vector3.ZERO)
				first = false
			else:
				merged = merged.expand(local_point)
	return merged


func _mat(color: Color, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if color.a < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
