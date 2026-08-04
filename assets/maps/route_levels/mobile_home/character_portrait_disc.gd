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
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	var backdrop := ColorRect.new()
	backdrop.size = Vector2(diameter, diameter)
	backdrop.color = Color(0.18, 0.12, 0.08, 1.0)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(backdrop)

	if locked:
		var lock := Label.new()
		lock.text = "🔒"
		lock.size = Vector2(diameter, diameter)
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock.add_theme_font_size_override("font_size", maxi(int(diameter * 0.28), 16))
		lock.add_theme_color_override("font_color", Color(0.706, 0.784, 0.863, 0.85))
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		viewport.add_child(lock)
	elif texture:
		var hero := TextureRect.new()
		hero.texture = texture
		hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var tall := int(diameter * 1.22)
		hero.size = Vector2(diameter, tall)
		hero.position = Vector2(0, int(-diameter * 0.14))
		hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
		viewport.add_child(hero)

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


class _PortraitRing extends Control:
	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.5 - 1.0
		draw_arc(center, radius, 0.0, TAU, 96, Color(0.667, 0.902, 1.0, 0.55), 2.0, true)
		draw_arc(center, radius, 0.0, TAU, 96, Color(0.557, 0.882, 0.969, 0.22), 8.0, true)
