extends RefCounted
class_name CharacterPageUI

# 设计令牌 via preload（勿用 const Design = CharacterRunnerDesign，GDScript 不允许）
const Design = preload("res://assets/maps/route_levels/mobile_home/character_runner_design.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const CharacterHubRing = preload("res://assets/maps/route_levels/mobile_home/character_hub_ring.gd")
const CharacterPortraitDisc = preload("res://assets/maps/route_levels/mobile_home/character_portrait_disc.gd")

const STAT_GLYPH := {"sp": "⏱", "hp": "♥", "en": "🔋"}
const GEAR_GLYPH := {"boots": "👢", "core": "⚛", "shield": "🛡"}


static func build(parent: Control, ctx: Dictionary) -> void:
	var shell := _RunnerPageShell.new()
	shell.name = "RunnerPageShell"
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(shell)
	shell.setup(ctx)


class _RunnerPageShell extends Control:
	var _canvas: Control
	var _design_size := Vector2.ZERO

	func setup(ctx: Dictionary) -> void:
		_canvas = Control.new()
		_canvas.name = "DesignCanvas"
		_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_canvas)
		_design_size = CharacterPageUI._build_canvas(_canvas, ctx)
		_canvas.custom_minimum_size = _design_size
		_canvas.size = _design_size
		resized.connect(_fit_canvas)
		call_deferred("_fit_canvas")

	func _fit_canvas() -> void:
		if _design_size.x <= 0.0 or size.x <= 1.0:
			return
		var sx := size.x / _design_size.x
		var sy := size.y / _design_size.y
		var scale := minf(sx, sy)
		_canvas.scale = Vector2(scale, scale)
		_canvas.position = Vector2((size.x - _design_size.x * scale) * 0.5, 0.0)


static func _build_canvas(root: Control, ctx: Dictionary) -> Vector2:
	var character_id: String = String(ctx.get("character_id", CharacterRoster.CHAR_ELSA))
	var snapshot: Dictionary = ctx.get("snapshot", {})
	var character: Dictionary = CharacterRoster.get_character(character_id)
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	var is_locked := not CharacterRoster.is_unlocked(character_id, unlocked)
	var is_active := String(ctx.get("active_character_id", character_id)) == character_id

	var col := VBoxContainer.new()
	col.custom_minimum_size = Vector2(Design.CONTENT_W, 0)
	col.size = Vector2(Design.CONTENT_W, 0)
	col.add_theme_constant_override("separation", Design.fs_cqh(1.4))
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(col)

	col.add_child(_build_hub(ctx, character, snapshot, character_id, is_locked, is_active))
	if is_locked:
		col.add_child(_build_unlock_banner(character))
	col.add_child(_build_info_section(ctx, character, snapshot, is_locked))
	col.add_child(_build_equipment_section(character, is_locked))

	_finalize_col(col)
	return Vector2(Design.CONTENT_W, col.size.y)


static func _finalize_col(col: VBoxContainer) -> void:
	col.update_minimum_size()
	var min_sz := col.get_combined_minimum_size()
	col.custom_minimum_size = min_sz
	col.size = min_sz


static func _build_hub(
	ctx: Dictionary,
	character: Dictionary,
	snapshot: Dictionary,
	character_id: String,
	is_locked: bool,
	is_active: bool
) -> Control:
	var hub := Control.new()
	hub.custom_minimum_size = Vector2(Design.CONTENT_W, Design.cqh(44))
	hub.clip_contents = false
	hub.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var glow := _HubBackdrop.new()
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hub.add_child(glow)

	var id_tag := _pill_tag(String(character.get("runner_code", "R-07")))
	id_tag.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	id_tag.offset_top = Design.cqh(0.8)
	id_tag.offset_right = 0
	id_tag.offset_left = -Design.cqw(14)
	id_tag.z_index = 6
	hub.add_child(id_tag)

	var ring_size := int(Design.cqw(56))
	var ring_top := int(Design.cqh(4.2))
	var inset := ring_size * 0.135
	var portrait_d := int(ring_size - inset * 2.0)

	var ring_wrap := Control.new()
	ring_wrap.custom_minimum_size = Vector2(ring_size, ring_size)
	ring_wrap.clip_contents = true
	ring_wrap.set_anchors_preset(Control.PRESET_CENTER_TOP)
	ring_wrap.offset_left = -ring_size / 2
	ring_wrap.offset_right = ring_size / 2
	ring_wrap.offset_top = ring_top
	ring_wrap.offset_bottom = ring_top + ring_size
	hub.add_child(ring_wrap)

	var ring := CharacterHubRing.new()
	ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ring.set_stats(character.get("hub_stats", []), is_locked)
	ring_wrap.add_child(ring)

	var portrait := CharacterPortraitDisc.new()
	portrait.setup(
		CharacterRoster.load_texture(String(character.get("hero_path", ""))),
		portrait_d,
		is_locked
	)
	portrait.position = Vector2(inset, inset)
	portrait.z_index = 2
	ring_wrap.add_child(portrait)

	for stat in character.get("hub_stats", []):
		if stat is Dictionary:
			hub.add_child(_build_stat_node(stat as Dictionary, is_locked))

	hub.add_child(_hub_arrow(ctx, false))
	hub.add_child(_hub_arrow(ctx, true))

	if not is_locked:
		var use_pill := _build_use_pill(ctx, character_id, is_active)
		use_pill.z_index = 6
		hub.add_child(use_pill)

	hub.add_child(_build_lv_badge(snapshot))
	hub.add_child(_build_pager(ctx, character_id))
	return hub


static func _build_stat_node(stat: Dictionary, dimmed: bool) -> Control:
	var icon := String(stat.get("icon", "sp"))
	var color: Color = Design.STAT_COLORS.get(icon, Design.CYAN_SOFT)
	if dimmed:
		color.a *= 0.45

	var node := Control.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = 4
	var chip_px := int(Design.cqw(9.2))

	if icon == "sp":
		node.set_anchors_preset(Control.PRESET_TOP_LEFT)
		node.offset_top = Design.cqh(0.2)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", int(Design.cqw(1.8)))
		row.add_child(_stat_chip(icon, color, chip_px))
		row.add_child(_stat_value(stat, color))
		row.add_child(_stat_label(String(stat.get("label", "SPEED"))))
		node.add_child(row)
		row.update_minimum_size()
		node.custom_minimum_size = row.get_combined_minimum_size()
		node.size = node.custom_minimum_size
		node.offset_left = (Design.CONTENT_W - node.size.x) * 0.5
		return node

	if icon == "hp":
		node.set_anchors_preset(Control.PRESET_TOP_LEFT)
		node.offset_left = Design.cqw(11.5)
		node.offset_top = Design.cqh(23)
	elif icon == "en":
		node.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		node.offset_right = Design.cqw(11.5)
		node.offset_top = Design.cqh(23)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", int(Design.cqh(0.3)))
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(_stat_chip(icon, color, chip_px))
	col.add_child(_stat_value(stat, color))
	col.add_child(_stat_label(String(stat.get("label", ""))))
	node.add_child(col)
	if icon == "en":
		col.update_minimum_size()
		var sz := col.get_combined_minimum_size()
		node.custom_minimum_size = sz
		node.offset_left = -sz.x
	return node


static func _stat_chip(icon: String, color: Color, size_px: int) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(size_px, size_px)
	var style := StyleBoxFlat.new()
	style.bg_color = color.lerp(Color(0.024, 0.047, 0.086), 0.68)
	style.set_corner_radius_all(size_px / 2)
	style.border_color = color.lerp(Color.WHITE, 0.45)
	style.set_border_width_all(1)
	style.shadow_color = Color(color.r, color.g, color.b, 0.45)
	style.shadow_size = 8
	chip.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = STAT_GLYPH.get(icon, "●")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", int(size_px * 0.42))
	label.add_theme_color_override("font_color", color.lerp(Color.WHITE, 0.35))
	chip.add_child(label)
	return chip


static func _stat_value(stat: Dictionary, color: Color) -> Label:
	var label := Label.new()
	label.text = String(stat.get("value", ""))
	label.add_theme_font_size_override("font_size", Design.fs_cqw(4.3))
	label.add_theme_color_override("font_color", color.lerp(Color.WHITE, 0.35))
	label.add_theme_color_override("font_shadow_color", Color(color.r, color.g, color.b, 0.55))
	return label


static func _stat_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", Design.fs_cqw(2.5))
	label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86))
	label.add_theme_constant_override("letter_spacing", Design.em_cqw(2.5, 0.18))
	return label


static func _pill_tag(text: String) -> PanelContainer:
	var tag := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.027, 0.063, 0.114, 0.6)
	style.border_color = Color(0.667, 0.902, 1.0, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(Design.fs_cqw(1.4))
	style.content_margin_left = Design.fs_cqw(2.0)
	style.content_margin_right = Design.fs_cqw(2.0)
	style.content_margin_top = int(Design.cqh(0.35))
	style.content_margin_bottom = int(Design.cqh(0.35))
	tag.add_theme_stylebox_override("panel", style)
	var tag_label := Label.new()
	tag_label.text = text
	tag_label.add_theme_font_size_override("font_size", Design.fs_cqw(2.6))
	tag_label.add_theme_color_override("font_color", Design.CYAN_SOFT)
	tag.add_child(tag_label)
	return tag


static func _hub_arrow(ctx: Dictionary, next: bool) -> Button:
	var btn := Button.new()
	var sz := int(Design.cqw(9.4))
	btn.custom_minimum_size = Vector2(sz, sz)
	btn.focus_mode = Control.FOCUS_NONE
	btn.text = "›" if next else "‹"
	btn.set_anchors_preset(Control.PRESET_TOP_LEFT if not next else Control.PRESET_TOP_RIGHT)
	btn.offset_top = Design.cqh(17)
	btn.z_index = 5
	if next:
		btn.offset_right = 0
		btn.offset_left = -sz
	else:
		btn.offset_left = 0
		btn.offset_right = sz
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.027, 0.063, 0.114, 0.55)
	box.border_color = Color(0.667, 0.902, 1.0, 0.35)
	box.set_border_width_all(1)
	box.set_corner_radius_all(Design.fs_cqw(2.2))
	btn.add_theme_stylebox_override("normal", box)
	btn.add_theme_stylebox_override("hover", box)
	btn.add_theme_stylebox_override("pressed", box)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_font_size_override("font_size", int(sz * 0.42))
	btn.add_theme_color_override("font_color", Design.ICE)
	var cb: Callable = ctx.get("on_cycle", Callable())
	if cb.is_valid():
		btn.pressed.connect(cb.bind(1 if next else -1))
	return btn


static func _build_lv_badge(snapshot: Dictionary) -> PanelContainer:
	var badge := PanelContainer.new()
	var badge_w := int(Design.cqw(66))
	var badge_h := int(Design.cqh(5.5))
	badge.custom_minimum_size = Vector2(badge_w, badge_h)
	badge.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	badge.offset_left = -badge_w / 2
	badge.offset_right = badge_w / 2
	badge.offset_bottom = -Design.cqh(0.6)
	badge.offset_top = -Design.cqh(0.6) - badge_h
	badge.add_theme_stylebox_override("panel", Design.glass_style(Design.cqw(10), Vector4(16, 8, 16, 8)))
	var panel_style: StyleBoxFlat = badge.get_theme_stylebox("panel") as StyleBoxFlat
	if panel_style:
		panel_style.content_margin_left = Design.fs_cqw(4.0)
		panel_style.content_margin_right = Design.fs_cqw(4.0)
		panel_style.content_margin_top = int(Design.cqh(0.9))
		panel_style.content_margin_bottom = int(Design.cqh(0.9))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(Design.cqw(2.8)))
	badge.add_child(row)

	var lv := Label.new()
	lv.text = "LV.%d" % int(snapshot.get("level", 1))
	lv.add_theme_font_size_override("font_size", Design.fs_cqw(4.8))
	lv.add_theme_color_override("font_color", Design.ICE)
	lv.add_theme_color_override("font_shadow_color", Color(Design.CYAN.r, Design.CYAN.g, Design.CYAN.b, 0.45))
	row.add_child(lv)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(right)

	var xp_need := int(snapshot.get("xp_to_next", 0))
	var xp_into := int(snapshot.get("xp_into_level", 0))
	var bar_h := maxi(int(Design.cqh(0.7)), 5)
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, bar_h)
	bar.show_percentage = false
	bar.max_value = float(maxi(xp_need, 1))
	bar.value = float(xp_into if xp_need > 0 else 1)
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.627, 0.784, 0.922, 0.15)
	track.set_corner_radius_all(Design.fs_cqw(1))
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.384, 0.863, 0.961)
	fill.set_corner_radius_all(Design.fs_cqw(1))
	fill.shadow_color = Color(0.384, 0.863, 0.961, 0.45)
	fill.shadow_size = 4
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", fill)
	right.add_child(bar)

	var xp := Label.new()
	xp.text = "MAX XP" if xp_need <= 0 else "%s / %s XP" % [_fmt(xp_into), _fmt(xp_need)]
	xp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	xp.add_theme_font_size_override("font_size", Design.fs_cqw(2.3))
	xp.add_theme_color_override("font_color", Design.TEXT_SUB)
	right.add_child(xp)
	return badge


static func _build_pager(ctx: Dictionary, current_id: String) -> Control:
	var wrap := Control.new()
	wrap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(Design.cqw(1.3)))
	row.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	row.offset_right = -Design.cqw(1)
	row.offset_bottom = -Design.cqh(1.2)
	wrap.add_child(row)
	for id in CharacterRoster.ordered_ids():
		var dot := Button.new()
		dot.focus_mode = Control.FOCUS_NONE
		var d := maxi(int(Design.cqw(1.5)), 6)
		dot.custom_minimum_size = Vector2(d, d)
		var on := id == current_id
		var st := StyleBoxFlat.new()
		st.bg_color = Design.CYAN if on else Color(0.627, 0.784, 0.922, 0.3)
		st.set_corner_radius_all(d / 2)
		if on:
			st.shadow_color = Color(Design.CYAN.r, Design.CYAN.g, Design.CYAN.b, 0.8)
			st.shadow_size = 4
		dot.add_theme_stylebox_override("normal", st)
		dot.add_theme_stylebox_override("hover", st)
		dot.add_theme_stylebox_override("pressed", st)
		dot.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var cb: Callable = ctx.get("on_select", Callable())
		if cb.is_valid():
			dot.pressed.connect(cb.bind(id))
		row.add_child(dot)
	return wrap


static func _build_use_pill(ctx: Dictionary, character_id: String, is_active: bool) -> Button:
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.offset_top = Design.cqh(34.2)
	btn.offset_right = Design.cqw(6)
	btn.offset_left = -Design.cqw(24)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(Design.fs_cqw(1.8))
	style.content_margin_left = Design.fs_cqw(2.6)
	style.content_margin_right = Design.fs_cqw(2.6)
	style.content_margin_top = int(Design.cqh(0.5))
	style.content_margin_bottom = int(Design.cqh(0.5))
	if is_active:
		btn.disabled = true
		style.bg_color = Color(0.494, 0.878, 0.722, 0.12)
		style.border_color = Color(0.494, 0.878, 0.722, 0.6)
	else:
		style.bg_color = Color(0.314, 0.549, 0.745, 0.55)
		style.border_color = Color(0.745, 0.933, 1.0, 0.6)
		var cb: Callable = ctx.get("on_switch", Callable())
		if cb.is_valid():
			btn.pressed.connect(cb.bind(character_id))
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_font_size_override("font_size", Design.fs_cqw(2.9))
	btn.add_theme_constant_override("letter_spacing", Design.em_cqw(2.9, 0.16))
	btn.add_theme_color_override("font_color", Color(0, 0, 0, 0))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(Design.cqw(1.4)))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(row)

	var dot := ColorRect.new()
	dot.custom_minimum_size = Vector2(Design.cqw(1.4), Design.cqw(1.4))
	dot.color = Design.GREEN if is_active else Design.CYAN
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dot)

	var label := Label.new()
	label.text = "IN USE" if is_active else "SWITCH"
	label.add_theme_font_size_override("font_size", Design.fs_cqw(2.9))
	label.add_theme_color_override("font_color", Color(0.682, 0.949, 0.831) if is_active else Design.ICE)
	label.add_theme_constant_override("letter_spacing", Design.em_cqw(2.9, 0.16))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	return btn


static func _build_unlock_banner(character: Dictionary) -> Control:
	var wrap := CenterContainer.new()
	wrap.custom_minimum_size = Vector2(0, Design.cqh(4))
	var tag := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.702, 0.361, 0.1)
	style.border_color = Color(1.0, 0.702, 0.361, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(Design.fs_cqw(1.6))
	style.content_margin_left = Design.fs_cqw(2.6)
	style.content_margin_right = Design.fs_cqw(2.6)
	style.content_margin_top = int(Design.cqh(0.45))
	style.content_margin_bottom = int(Design.cqh(0.45))
	tag.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = String(character.get("unlock_banner", "LOCKED"))
	label.add_theme_font_size_override("font_size", Design.fs_cqw(2.7))
	label.add_theme_color_override("font_color", Color(1.0, 0.851, 0.678))
	tag.add_child(label)
	wrap.add_child(tag)
	return wrap


static func _build_info_section(
	ctx: Dictionary,
	character: Dictionary,
	snapshot: Dictionary,
	is_locked: bool
) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", Design.card_style())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(Design.cqw(3)))
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(row)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", int(Design.cqh(0.3)))
	row.add_child(left)

	var name := Label.new()
	name.text = String(character.get("name_en", "ELSA"))
	name.add_theme_font_size_override("font_size", Design.fs_cqw(6.8))
	name.add_theme_color_override("font_color", Design.ICE)
	name.add_theme_color_override("font_shadow_color", Color(0.667, 0.894, 0.98, 0.45))
	left.add_child(name)

	var bonus := Label.new()
	bonus.text = "LEVEL BONUS • EMBER COINS %s" % String(snapshot.get("coin_bonus_text", "+0%"))
	bonus.add_theme_font_size_override("font_size", Design.fs_cqw(2.3))
	bonus.add_theme_color_override("font_color", Design.CYAN_SOFT)
	left.add_child(bonus)

	var story := _build_story_pill(ctx, character, is_locked)
	story.custom_minimum_size = Vector2(Design.cqw(28), 0)
	story.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	row.add_child(story)
	return card


static func _build_story_pill(ctx: Dictionary, character: Dictionary, locked: bool) -> Control:
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.063, 0.137, 0.227, 0.55)
	style.border_color = Color(0.667, 0.902, 1.0, 0.38)
	style.set_border_width_all(1)
	style.set_corner_radius_all(Design.fs_cqw(2))
	style.content_margin_left = Design.fs_cqw(2.8)
	style.content_margin_right = Design.fs_cqw(2.8)
	style.content_margin_top = int(Design.cqh(0.9))
	style.content_margin_bottom = int(Design.cqh(0.9))
	style.shadow_color = Color(Design.CYAN.r, Design.CYAN.g, Design.CYAN.b, 0.14)
	style.shadow_size = 8
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	if not locked:
		var cb: Callable = ctx.get("on_story", Callable())
		if cb.is_valid():
			btn.pressed.connect(cb.bind(String(character.get("id", CharacterRoster.CHAR_ELSA))))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(Design.cqw(2)))
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(row)
	var icon := Label.new()
	icon.text = "📖"
	icon.add_theme_font_size_override("font_size", Design.fs_cqw(5))
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", int(Design.cqh(0.2)))
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	var title := Label.new()
	title.text = "RUNNER STORY"
	title.add_theme_font_size_override("font_size", Design.fs_cqw(2.8))
	title.add_theme_color_override("font_color", Design.TEXT)
	title.add_theme_constant_override("letter_spacing", Design.em_cqw(2.8, 0.1))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(title)
	var sub := Label.new()
	sub.text = "LOCKED" if locked else "READ ARCHIVE ›"
	sub.add_theme_font_size_override("font_size", Design.fs_cqw(2.2))
	sub.add_theme_color_override("font_color", Design.TEXT_SUB if locked else Design.CYAN_SOFT)
	sub.add_theme_constant_override("letter_spacing", Design.em_cqw(2.2, 0.06))
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(sub)
	return btn


static func _build_equipment_section(character: Dictionary, is_locked: bool) -> Control:
	var sec := VBoxContainer.new()
	sec.add_theme_constant_override("separation", int(Design.cqh(0.9)))
	sec.add_child(_section_label())

	var fan_host := Control.new()
	var card_w := int(Design.cqw(29))
	var card_h := int(Design.cqh(16.5))
	var overlap := int(Design.cqw(1.4))
	fan_host.custom_minimum_size = Vector2(Design.CONTENT_W, card_h + Design.cqh(3))
	fan_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fan_host.clip_contents = false
	sec.add_child(fan_host)

	var gear_list: Array = character.get("gear", [])
	var count := gear_list.size()
	var total_w := card_w * count - overlap * maxi(count - 1, 0)
	var start_x := (Design.CONTENT_W - total_w) * 0.5

	for i in count:
		if gear_list[i] is Dictionary:
			var card := _build_gear_card(gear_list[i] as Dictionary, i, is_locked, card_w, card_h)
			card.position = Vector2(start_x + i * (card_w - overlap), Design.cqh(0.4))
			card.z_index = 2 if i == 1 else 1
			fan_host.add_child(card)
	return sec


static func _section_label() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(Design.cqw(2)))
	var gem := ColorRect.new()
	gem.custom_minimum_size = Vector2(Design.cqw(1.2), Design.cqw(1.2))
	gem.rotation = deg_to_rad(45.0)
	gem.color = Design.CYAN
	gem.pivot_offset = gem.custom_minimum_size * 0.5
	row.add_child(gem)
	var label := Label.new()
	label.text = "EQUIPMENT"
	label.add_theme_font_size_override("font_size", Design.fs_cqw(2.7))
	label.add_theme_color_override("font_color", Design.TEXT_SUB)
	label.add_theme_constant_override("letter_spacing", Design.em_cqw(2.7, 0.32))
	row.add_child(label)
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.color = Color(0.627, 0.784, 0.922, 0.3)
	row.add_child(line)
	return row


static func _build_gear_card(
	gear: Dictionary,
	index: int,
	runner_locked: bool,
	card_w: int,
	card_h: int
) -> Control:
	var locked := runner_locked or bool(gear.get("locked", false))
	var empty := not bool(gear.get("equipped", false)) and not locked
	var rarity := String(gear.get("rarity", "rare"))
	var accent: Color = Design.RARITY.get(rarity, Design.CYAN_SOFT)
	if locked or empty:
		accent = Color(0.42, 0.486, 0.561)

	var pivot := Control.new()
	pivot.custom_minimum_size = Vector2(card_w, card_h)
	pivot.size = Vector2(card_w, card_h)
	pivot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot.pivot_offset = Vector2(card_w * 0.5, card_h)
	if index == 0:
		pivot.rotation_degrees = -7.0
	elif index == 2:
		pivot.rotation_degrees = 7.0

	var corner_r := Design.fs_cqw(2.2)
	var panel_style := Design.gear_style(accent, locked or empty, corner_r)
	panel_style.content_margin_left = int(Design.cqw(1.4))
	panel_style.content_margin_right = int(Design.cqw(1.4))
	panel_style.content_margin_top = int(Design.cqh(1.2))
	panel_style.content_margin_bottom = int(Design.cqh(1.3))

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(card_w, card_h)
	panel.size = Vector2(card_w, card_h)
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", panel_style)
	pivot.add_child(panel)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", int(Design.cqh(0.55)))
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(col)

	if not locked and not empty:
		var shine := ColorRect.new()
		shine.custom_minimum_size = Vector2(card_w - int(Design.cqw(2.8)), 2)
		shine.size = shine.custom_minimum_size
		shine.position = Vector2(int(Design.cqw(1.4)), 1)
		var hi := accent.lerp(Color.WHITE, 0.55)
		shine.color = Color(hi.r, hi.g, hi.b, 0.75)
		shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(shine)
		shine.z_index = 2

	var slot := Label.new()
	slot.text = String(gear.get("slot", "SLOT"))
	slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_theme_font_size_override("font_size", Design.fs_cqw(2.1))
	slot.add_theme_color_override("font_color", accent.lerp(Color(0.788, 0.847, 0.910), 0.45))
	slot.add_theme_constant_override("letter_spacing", Design.em_cqw(2.1, 0.22))
	col.add_child(slot)

	var icon_box := _gear_icon_box(accent, locked or empty)
	col.add_child(icon_box)
	var icon_l := Label.new()
	icon_l.text = "🔒" if locked else ("+" if empty else GEAR_GLYPH.get(String(gear.get("icon_key", "")), "G"))
	icon_l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_l.add_theme_font_size_override("font_size", Design.fs_cqw(4.5))
	icon_l.add_theme_color_override("font_color", accent.lerp(Color.WHITE, 0.35))
	icon_box.add_child(icon_l)

	var name := Label.new()
	name.text = "LOCKED" if locked else ("EMPTY SLOT" if empty else String(gear.get("name", "")))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.custom_minimum_size = Vector2(card_w - 8, Design.cqw(6.6))
	name.add_theme_font_size_override("font_size", Design.fs_cqw(2.8))
	name.add_theme_color_override("font_color", accent.lerp(Color.WHITE, 0.35))
	col.add_child(name)

	if not locked and not empty:
		var rarity_wrap := PanelContainer.new()
		rarity_wrap.add_theme_stylebox_override("panel", Design.gear_rarity_style(accent))
		var rarity_l := Label.new()
		rarity_l.text = String(gear.get("rarity_label", "RARE"))
		rarity_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rarity_l.add_theme_font_size_override("font_size", Design.fs_cqw(2.3))
		rarity_l.add_theme_color_override("font_color", accent.lerp(Color.WHITE, 0.45))
		rarity_l.add_theme_constant_override("letter_spacing", Design.em_cqw(2.3, 0.14))
		rarity_wrap.add_child(rarity_l)
		col.add_child(rarity_wrap)
		var fx := Label.new()
		fx.text = String(gear.get("fx", ""))
		fx.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fx.add_theme_font_size_override("font_size", Design.fs_cqw(2.3))
		fx.add_theme_color_override("font_color", Design.GREEN)
		col.add_child(fx)
	return pivot


static func _gear_icon_box(accent: Color, dimmed: bool) -> PanelContainer:
	var box := PanelContainer.new()
	var side := int(Design.cqw(10.5))
	box.custom_minimum_size = Vector2(side, side)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.031, 0.059, 0.106, 0.82)
	style.border_color = accent if not dimmed else Color(0.42, 0.486, 0.561)
	style.set_border_width_all(1 if dimmed else 2)
	style.set_corner_radius_all(Design.fs_cqw(2))
	if not dimmed:
		style.shadow_color = Color(accent.r, accent.g, accent.b, 0.45)
		style.shadow_size = 8
	box.add_theme_stylebox_override("panel", style)
	return box


static func _fmt(value: int) -> String:
	var text := str(value)
	if text.length() <= 3:
		return text
	var out := ""
	for i in text.length():
		if i > 0 and (text.length() - i) % 3 == 0:
			out += ","
		out += text[i]
	return out


class _HubBackdrop extends Control:
	func _draw() -> void:
		if size.x <= 1.0:
			return
		var center := Vector2(size.x * 0.5, size.y * 0.38)
		var radius := Design.cqw(40.0)
		draw_circle(center, radius, Color(0.557, 0.882, 0.969, 0.07))
		draw_circle(center, radius * 0.55, Color(0.557, 0.882, 0.969, 0.05))
