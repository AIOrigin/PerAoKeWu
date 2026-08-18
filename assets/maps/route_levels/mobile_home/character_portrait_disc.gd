extends Control
class_name CharacterPortraitDisc

const VIEWPORT_MASK := preload(
	"res://assets/maps/route_levels/mobile_home/ui_character/portrait_viewport_mask.gdshader"
)


func setup(texture: Texture2D, diameter: int, locked: bool = false) -> void:
	for child in get_children():
		child.queue_free()

	custom_minimum_size = Vector2(diameter, diameter)
	size = Vector2(diameter, diameter)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var viewport := SubViewport.new()
	viewport.size = Vector2i(diameter, diameter)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	var backdrop := _RadialBackdrop.new()
	backdrop.size = Vector2(diameter, diameter)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(backdrop)

	if locked:
		var lock := Label.new()
		lock.text = "?"
		lock.size = Vector2(diameter, diameter)
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock.add_theme_font_size_override("font_size", maxi(int(diameter * 0.34), 18))
		lock.add_theme_color_override("font_color", Color(0.82, 0.90, 0.98, 0.92))
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		viewport.add_child(lock)
	elif texture:
		var hero_host := Control.new()
		hero_host.size = Vector2(diameter, diameter)
		hero_host.clip_contents = true
		hero_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
		viewport.add_child(hero_host)

		var hero := TextureRect.new()
		hero.texture = texture
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var tex_size := texture.get_size()
		if tex_size.x > 1.0 and tex_size.y > 1.0:
			var cover := maxf(float(diameter) / tex_size.x, float(diameter) / tex_size.y) * 1.06
			var w := tex_size.x * cover
			var h := tex_size.y * cover
			hero.size = Vector2(w, h)
			hero.position = Vector2((diameter - w) * 0.5, diameter - h)
		else:
			hero.size = Vector2(diameter, diameter)
			hero.position = Vector2.ZERO
		hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hero_host.add_child(hero)

	var container := SubViewportContainer.new()
	container.custom_minimum_size = Vector2(diameter, diameter)
	container.size = Vector2(diameter, diameter)
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(viewport)
	var mask := ShaderMaterial.new()
	mask.shader = VIEWPORT_MASK
	container.material = mask
	add_child(container)

	var border := _PortraitRing.new()
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.z_index = 2
	add_child(border)


class _RadialBackdrop extends Control:
	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.5
		draw_circle(center, radius, Color(0.031, 0.055, 0.094, 1.0))
		draw_circle(center, radius * 0.92, Color(0.047, 0.082, 0.133, 0.95))
		draw_circle(center, radius * 0.72, Color(0.063, 0.118, 0.176, 0.55))


class _PortraitRing extends Control:
	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.5 - 1.0
		draw_arc(center, radius, 0.0, TAU, 96, Color(0.667, 0.902, 1.0, 0.55), 2.0, true)
		draw_arc(center, radius, 0.0, TAU, 96, Color(0.557, 0.882, 0.969, 0.22), 8.0, true)
