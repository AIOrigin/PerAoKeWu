class_name ObstacleVisualFactory
extends RefCounted

## 与 runner_60s 同款障碍外观：供关卡编辑器预览（及后续共用）

const LANE_WIDTH := 4.0
const IMPORTED_SCENE_FALLBACKS := {
	"res://3d素材/障碍物-需跳跃.glb": "res://.godot/imported/障碍物-需跳跃.glb-46f57db02e27254a677214f954ab0d83.scn",
	"res://3d素材/障碍物-需跳跃2.glb": "res://.godot/imported/障碍物-需跳跃2.glb-c8c9938e154747024ae7ac221ab7db3a.scn",
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
			_build_high_bar(root)
		"jump", "low_barrier":
			_build_low_barrier(root, item)
		"train", "train_moving":
			_build_train(root, otype == "train_moving")
		"block_left":
			_build_lane_block(root, "left")
		"block_right":
			_build_lane_block(root, "right")
		"ramp":
			_build_ramp(root)
		"main_block":
			_build_main_block(root)
		"turn_left", "turn_right":
			_build_turn_sign(root, otype)
		_:
			_build_low_barrier(root, item)
	return root


static func uses_center_lane(otype: String) -> bool:
	return otype in ["slide", "high_bar", "main_block", "ramp"]


func _build_low_barrier(root: Node3D, item: Dictionary) -> void:
	var path_count := maxi(_jump_paths.size(), 1)
	var scene_index := int(item.get("visual_index", -1))
	if scene_index < 0:
		var lane := int(item.get("lane", 0))
		var dist_key := int(float(item.get("distance", 0.0)))
		scene_index = absi(lane * 17 + dist_key) % path_count
	var asset_path := ""
	if not _jump_paths.is_empty():
		asset_path = _jump_paths[scene_index % _jump_paths.size()]
	var target_h := 1.15
	if "energy_orb" in asset_path:
		target_h = 1.45
	elif "energy_sprigs" in asset_path:
		target_h = 1.25
	elif "全息跳跃" in asset_path:
		target_h = 1.2
	if "全息跳跃" in asset_path:
		_add_jump_bar_visual(root, _jump_scene(scene_index), target_h, LANE_WIDTH * 1.55)
	else:
		var visual := _add_scaled_model(
			root,
			_jump_scene(scene_index),
			"JumpObstacleModel",
			target_h,
			0.0 if asset_path.ends_with(".png") else 180.0,
			Vector3.ZERO,
			LANE_WIDTH * 1.65
		)
		if "energy_orb" in asset_path:
			visual.position.y += 0.75
		elif not asset_path.ends_with(".png"):
			visual.rotation_degrees.y += 8.0 if scene_index == 0 else -8.0


func _build_high_bar(root: Node3D) -> void:
	var slide_path := _slide_paths[0] if not _slide_paths.is_empty() else ""
	if slide_path.ends_with(".png") and "phase_curtain" in slide_path:
		var scene := _slide_scene_at(0)
		if scene == null:
			_add_road_span_gate(root, null, 1.95, 14.8)
			_add_slide_curtain(root)
			return
		var model := scene.instantiate() as Node3D
		model.name = "SlideObstacleModel"
		root.add_child(model)
		var bounds := _aabb(model)
		model.scale = Vector3(13.5 / maxf(bounds.size.x, 0.001), 2.05 / maxf(bounds.size.y, 0.001), 1.0)
		bounds = _aabb(model)
		model.position = Vector3(
			-(bounds.position.x + bounds.size.x * 0.5),
			-bounds.position.y,
			-(bounds.position.z + bounds.size.z * 0.5)
		)
	elif slide_path.ends_with(".png"):
		var visual := _add_scaled_model(root, _slide_scene_at(0), "SlideObstacleModel", 2.2, 0.0, Vector3.ZERO)
		visual.position.y += 0.4
	else:
		_add_road_span_gate(root, _slide_scene_at(0), 1.95, 14.8)
	_add_slide_curtain(root)


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
	var bounds := _aabb(model)
	if bounds.size.y <= 0.001:
		return
	if bounds.size.z > bounds.size.x * 1.15:
		model.rotation_degrees.y = 90.0
		bounds = _aabb(model)
	var sx := target_span / maxf(bounds.size.x, 0.001)
	var sy := target_height / maxf(bounds.size.y, 0.001)
	model.scale = Vector3(sx, sy, clampf(sy, 0.85, 2.8))
	bounds = _aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)


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
		target_height / maxf(bounds.size.y, 0.001)
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
	var mat := _mat(Color(0.25, 0.85, 1.0, 0.38), Color(0.35, 0.95, 1.0), 2.2)
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
	max_footprint: float = -1.0
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
		model.scale = Vector3.ONE * minf(target_height / characteristic, 12.0)
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
