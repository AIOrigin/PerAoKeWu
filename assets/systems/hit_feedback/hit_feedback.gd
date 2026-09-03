extends Node
class_name HitFeedback

## 可复用受击反馈：震屏钩子、撞击粒子、闪白、跑道旁飘字。

enum Intensity { LIGHT, MEDIUM, HEAVY }

signal shake_requested(amount: float)
signal hit_applied(payload: Dictionary)

const INTENSITY_SHAKE := {
	Intensity.LIGHT: 0.10,
	Intensity.MEDIUM: 0.22,
	Intensity.HEAVY: 0.34,
}

const INTENSITY_FLASH := {
	Intensity.LIGHT: 0.18,
	Intensity.MEDIUM: 0.32,
	Intensity.HEAVY: 0.48,
}

const RUNWAY_TIP_Y_MIN := 0.58
const RUNWAY_TIP_Y_MAX := 0.76
const RUNWAY_TIP_RIGHT_WORLD := 1.05
const INTEGRITY_TIP_COLOR := Color(1.0, 0.94, 0.82)
const INTEGRITY_TIP_FONT := 42
const CHOICE_SPLASH_FONT := 112
const CHOICE_SPLASH_HOLD := 3.0
const CHOICE_SPLASH_FADE := 0.30
const CHOICE_SPLASH_CENTER_Y := 0.38

var _ui_root: Control
var _world_parent: Node3D
var _flash: ColorRect
var _float_layer: Control
var _comic_canvas: CanvasLayer
var _comic_splash_layer: Control
var _choice_splash_label: Label
var _impact_fx: GPUParticles3D
var _flash_tween: Tween
var _cargo_flash_target: Control
var _cargo_flash_tween: Tween
var _choice_splash_tween: Tween


func setup(ui_root: Control, world_parent: Node3D, cargo_flash_target: Control = null) -> void:
	_ui_root = ui_root
	_world_parent = world_parent
	_cargo_flash_target = cargo_flash_target
	_ensure_flash()
	_ensure_float_layer()
	_ensure_choice_splash()
	_ensure_impact_fx()


func apply_impact(
	world_pos: Vector3,
	intensity: int = Intensity.MEDIUM,
	damage: float = 0.0,
	label: String = "",
	color: Color = Color(1.0, 0.45, 0.28)
) -> void:
	var shake := float(INTENSITY_SHAKE.get(intensity, 0.22))
	shake_requested.emit(shake)
	_burst_impact(world_pos, intensity)
	_flash_screen(float(INTENSITY_FLASH.get(intensity, 0.3)), color)
	# 完整度飘字已关：只留粒子/闪屏，数值看 HUD
	if damage <= 0.01 and label.strip_edges() != "":
		var short := _short_env_label(label)
		if not short.contains("完整度"):
			spawn_runway_tip_at(world_pos, short, color)
	hit_applied.emit({
		"kind": "impact",
		"intensity": intensity,
		"damage": damage,
		"label": label,
		"world_pos": world_pos,
	})


func apply_env_tick(damage: float, label: String = "热量侵蚀", color: Color = Color(1.0, 0.55, 0.2)) -> void:
	if damage <= 0.01:
		return
	_flash_screen(0.10, color)
	flash_cargo()
	# 完整度飘字已关；防护罩消耗仍提示
	if label.contains("防护"):
		spawn_runway_tip_screen(_format_env_tip(label, damage), color)
	hit_applied.emit({
		"kind": "env_tick",
		"damage": damage,
		"label": label,
	})


func apply_env_tick_at(world_pos: Vector3, damage: float, label: String = "热量侵蚀") -> void:
	if damage <= 0.01:
		return
	var color := INTEGRITY_TIP_COLOR
	if label.contains("防护"):
		color = Color(0.55, 0.88, 1.0)
	_flash_screen(0.08, color)
	flash_cargo()
	if label.contains("防护"):
		spawn_runway_tip_at(world_pos, _format_env_tip(label, damage), color)
	hit_applied.emit({
		"kind": "env_tick",
		"damage": damage,
		"label": label,
		"world_pos": world_pos,
	})


func spawn_runway_tip_at(world_pos: Vector3, text: String, color: Color = Color(1.0, 0.72, 0.38)) -> void:
	if text.strip_edges() == "":
		return
	# 跑者旁「完整度 ±N」小字一律不显示
	if text.contains("完整度"):
		return
	_ensure_float_layer()
	if _float_layer == null:
		return
	var subject_right := _tip_subject_right(text)
	var anchor_pos := _world_pos_to_subject_right(world_pos) if subject_right else world_pos
	var local := _project_runway_screen(anchor_pos)
	_make_floating_label(local, text, color, true, subject_right)


func spawn_choice_result_tip(_world_pos: Vector3, _text: String, _color: Color = INTEGRITY_TIP_COLOR) -> void:
	var trimmed := _text.strip_edges().to_upper()
	var is_safe := trimmed.contains("SAFE")
	spawn_comic_choice_splash(is_safe)


func spawn_comic_choice_splash(is_safe: bool) -> void:
	_ensure_choice_splash()
	if _choice_splash_label == null:
		return
	_stop_choice_splash_tween()
	var accent := Color(0.22, 0.98, 0.58, 1.0) if is_safe else Color(1.0, 0.18, 0.14, 1.0)
	_choice_splash_label.text = "Cargo SAFE!" if is_safe else "Cargo -50%"
	_choice_splash_label.add_theme_font_size_override("font_size", CHOICE_SPLASH_FONT)
	_choice_splash_label.add_theme_color_override("font_color", accent)
	_choice_splash_label.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.05, 1.0))
	_choice_splash_label.add_theme_constant_override("outline_size", 16)
	_choice_splash_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_layout_choice_splash_center()
	_choice_splash_label.visible = true
	if _comic_canvas != null:
		move_child(_comic_canvas, get_child_count() - 1)
	_flash_screen(0.14 if is_safe else 0.20, accent)
	shake_requested.emit(0.18 if is_safe else 0.24)
	_choice_splash_tween = create_tween()
	_choice_splash_tween.tween_interval(CHOICE_SPLASH_HOLD)
	_choice_splash_tween.tween_property(_choice_splash_label, "modulate:a", 0.0, CHOICE_SPLASH_FADE)
	_choice_splash_tween.tween_callback(_hide_choice_splash)


func _stop_choice_splash_tween() -> void:
	if _choice_splash_tween != null and _choice_splash_tween.is_valid():
		_choice_splash_tween.kill()
	_choice_splash_tween = null
	if _choice_splash_label != null and is_instance_valid(_choice_splash_label):
		_choice_splash_label.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _hide_choice_splash() -> void:
	if _choice_splash_label != null and is_instance_valid(_choice_splash_label):
		_choice_splash_label.visible = false
		_choice_splash_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_choice_splash_tween = null


func _layout_choice_splash_center() -> void:
	if _choice_splash_label == null:
		return
	var vp := _comic_viewport_size()
	_choice_splash_label.reset_size()
	var pos := Vector2(
		vp.x * 0.5 - _choice_splash_label.size.x * 0.5,
		vp.y * CHOICE_SPLASH_CENTER_Y - _choice_splash_label.size.y * 0.5
	)
	var pad := 12.0
	pos.x = clampf(pos.x, pad, maxf(vp.x - _choice_splash_label.size.x - pad, pad))
	pos.y = clampf(pos.y, pad, maxf(vp.y - _choice_splash_label.size.y - pad, pad))
	_choice_splash_label.position = pos


func _comic_viewport_size() -> Vector2:
	var vp := get_viewport()
	if vp != null:
		var rect := vp.get_visible_rect()
		if rect.size.x > 16.0 and rect.size.y > 16.0:
			return rect.size
	if _comic_splash_layer != null and _comic_splash_layer.size.x > 16.0:
		return _comic_splash_layer.size
	if _ui_root != null and _ui_root.size.x > 16.0:
		return _ui_root.size
	return Vector2(720.0, 1280.0)


func spawn_runway_tip_screen(text: String, color: Color = Color(1.0, 0.72, 0.38)) -> void:
	if text.strip_edges() == "":
		return
	if text.contains("完整度"):
		return
	_ensure_float_layer()
	if _float_layer == null:
		return
	var screen := Vector2(_float_layer.size.x * 0.5, _float_layer.size.y * 0.66)
	_make_floating_label(screen, text, color, true)


func flash_cargo() -> void:
	if _cargo_flash_target == null or not is_instance_valid(_cargo_flash_target):
		return
	if _cargo_flash_tween and _cargo_flash_tween.is_valid():
		_cargo_flash_tween.kill()
	_cargo_flash_target.modulate = Color(1.0, 0.35, 0.28, 1.0)
	_cargo_flash_tween = create_tween()
	_cargo_flash_tween.tween_property(_cargo_flash_target, "modulate", Color.WHITE, 0.35)


func _format_env_tip(label: String, damage: float) -> String:
	if label.contains("防护"):
		return "防护罩 -%0.0f" % damage
	return "完整度 -%0.0f" % damage


func _tip_subject_right(text: String) -> bool:
	return text.contains("完整度")


func _world_pos_to_subject_right(world_pos: Vector3) -> Vector3:
	if _ui_root == null:
		return world_pos + Vector3(RUNWAY_TIP_RIGHT_WORLD, 0.0, 0.0)
	var cam := _ui_root.get_viewport().get_camera_3d()
	if cam == null or not is_instance_valid(cam):
		return world_pos + Vector3(RUNWAY_TIP_RIGHT_WORLD, 0.0, 0.0)
	var right := cam.global_transform.basis.x
	right.y = 0.0
	if right.length_squared() < 0.01:
		return world_pos + Vector3(RUNWAY_TIP_RIGHT_WORLD, 0.0, 0.0)
	return world_pos + right.normalized() * RUNWAY_TIP_RIGHT_WORLD


func _short_env_label(label: String) -> String:
	var trimmed := label.strip_edges()
	if trimmed.contains("防护"):
		return "防护罩 -"
	if trimmed.contains("撞碎"):
		return "完整度 -"
	return trimmed.substr(0, mini(trimmed.length(), 10))


func _project_runway_screen(world_pos: Vector3) -> Vector2:
	var fallback := Vector2(
		_float_layer.size.x * 0.5,
		_float_layer.size.y * 0.66
	)
	if _ui_root == null:
		return fallback
	var cam := _ui_root.get_viewport().get_camera_3d()
	if cam == null or not is_instance_valid(cam) or cam.is_position_behind(world_pos):
		return fallback
	var viewport_pos := cam.unproject_position(world_pos)
	var local: Vector2 = _float_layer.get_global_transform_with_canvas().affine_inverse() * viewport_pos
	var pad := 8.0
	local.x = clampf(local.x, pad, maxf(_float_layer.size.x - pad, pad))
	var y_min := _float_layer.size.y * RUNWAY_TIP_Y_MIN
	var y_max := _float_layer.size.y * RUNWAY_TIP_Y_MAX
	local.y = clampf(local.y, y_min, y_max)
	return local


func _ensure_flash() -> void:
	if _flash != null or _ui_root == null:
		return
	_flash = ColorRect.new()
	_flash.name = "HitFlash"
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 0.35, 0.2, 0)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui_root.add_child(_flash)
	_ui_root.move_child(_flash, _ui_root.get_child_count() - 1)


func _ensure_float_layer() -> void:
	if _float_layer != null or _ui_root == null:
		return
	_float_layer = Control.new()
	_float_layer.name = "HitFloatLayer"
	_float_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_float_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_float_layer.z_index = 80
	_ui_root.add_child(_float_layer)


func _ensure_choice_splash() -> void:
	if _choice_splash_label != null:
		return
	_comic_canvas = CanvasLayer.new()
	_comic_canvas.name = "ComicSplashCanvas"
	_comic_canvas.layer = 120
	add_child(_comic_canvas)
	_comic_splash_layer = Control.new()
	_comic_splash_layer.name = "ComicSplashLayer"
	_comic_splash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_comic_splash_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_comic_canvas.add_child(_comic_splash_layer)
	_choice_splash_label = Label.new()
	_choice_splash_label.name = "ChoiceSplashLabel"
	_choice_splash_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_choice_splash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_choice_splash_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_choice_splash_label.add_theme_font_size_override("font_size", CHOICE_SPLASH_FONT)
	_choice_splash_label.visible = false
	_comic_splash_layer.add_child(_choice_splash_label)


func _ensure_impact_fx() -> void:
	if _impact_fx != null or _world_parent == null:
		return
	_impact_fx = GPUParticles3D.new()
	_impact_fx.name = "HitImpactBurst"
	_impact_fx.amount = 42
	_impact_fx.lifetime = 0.38
	_impact_fx.one_shot = true
	_impact_fx.emitting = false
	_impact_fx.explosiveness = 0.92
	var mesh := SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	mesh.radial_segments = 6
	mesh.rings = 3
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.55, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.4, 0.1)
	mat.emission_energy_multiplier = 2.2
	mesh.material = mat
	_impact_fx.draw_pass_1 = mesh
	var proc := ParticleProcessMaterial.new()
	proc.direction = Vector3(0, 1, 0)
	proc.spread = 180.0
	proc.initial_velocity_min = 2.5
	proc.initial_velocity_max = 7.5
	proc.gravity = Vector3(0, -10.0, 0)
	proc.scale_min = 0.4
	proc.scale_max = 1.5
	proc.color = Color(1.0, 0.62, 0.25, 0.9)
	_impact_fx.process_material = proc
	_world_parent.add_child(_impact_fx)


func _burst_impact(world_pos: Vector3, intensity: int) -> void:
	_ensure_impact_fx()
	if _impact_fx == null:
		return
	_impact_fx.global_position = world_pos + Vector3(0, 0.6, 0)
	match intensity:
		Intensity.LIGHT:
			_impact_fx.amount = 22
		Intensity.HEAVY:
			_impact_fx.amount = 56
		_:
			_impact_fx.amount = 42
	_impact_fx.restart()
	_impact_fx.emitting = true


func _flash_screen(alpha: float, color: Color) -> void:
	_ensure_flash()
	if _flash == null:
		return
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash.color = Color(color.r, color.g, color.b, clampf(alpha, 0.0, 0.65))
	_flash_tween = create_tween()
	_flash_tween.tween_property(_flash, "color:a", 0.0, 0.28)


func _make_floating_label(
	screen: Vector2,
	text: String,
	color: Color,
	runway: bool = false,
	anchor_right: bool = false,
	font_size_override: int = 0,
	_is_choice_result: bool = false
) -> void:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if anchor_right else HORIZONTAL_ALIGNMENT_CENTER
	var integrity_tip := runway and text.contains("完整度")
	var tip_font := INTEGRITY_TIP_FONT if integrity_tip else (34 if runway else 28)
	if font_size_override > 0:
		tip_font = font_size_override
	label.add_theme_font_size_override("font_size", tip_font)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.06, 0.92) if integrity_tip else Color(0.02, 0.04, 0.08, 0.96))
	label.add_theme_constant_override("outline_size", 8 if integrity_tip else (6 if runway else 4))
	_float_layer.add_child(label)
	label.reset_size()
	var jitter := Vector2.ZERO
	if runway:
		jitter = Vector2(randf_range(0.0, 6.0), randf_range(-3.0, 3.0)) if anchor_right else Vector2(randf_range(-12.0, 12.0), randf_range(-3.0, 3.0))
	else:
		jitter = Vector2(randf_range(-28.0, 28.0), randf_range(-10.0, 6.0))
	var pos := screen + jitter
	if not anchor_right:
		pos -= Vector2(label.size.x * 0.5, label.size.y * 0.5)
	else:
		pos.y -= label.size.y * 0.5
	var pad := 8.0
	pos.x = clampf(pos.x, pad, maxf(_float_layer.size.x - label.size.x - pad, pad))
	var y_min := _float_layer.size.y * (RUNWAY_TIP_Y_MIN if runway else 0.48)
	var y_max := _float_layer.size.y * (RUNWAY_TIP_Y_MAX if runway else 0.72)
	pos.y = clampf(pos.y, y_min, maxf(y_max - label.size.y, y_min))
	label.position = pos
	var rise := 22.0 if runway else 70.0
	var duration := 0.9 if runway else 0.75
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "position:y", label.position.y - rise, duration).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, duration).set_delay(0.12)
	tw.chain().tween_callback(label.queue_free)
