extends RefCounted
class_name CharacterPageUI

# 设计令牌 via preload（勿用 const Design = CharacterRunnerDesign，GDScript 不允许）
const Design = preload("res://assets/maps/route_levels/mobile_home/character_runner_design.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const CharacterHubRing = preload("res://assets/maps/route_levels/mobile_home/character_hub_ring.gd")
const CharacterPortraitDisc = preload("res://assets/maps/route_levels/mobile_home/character_portrait_disc.gd")

const STAT_GLYPH := {"sp": "⏱", "hp": "♥", "en": "🔋"}
const GEAR_GLYPH := {"boots": "👢", "core": "⚛", "shield": "🛡"}
# 与 CharacterHubRing 弧段中点对齐：上 / 左下 / 右下，间隔 120°
const STAT_ORBIT_DEG := {"sp": -90.0, "hp": 150.0, "en": 30.0}
# 纵向压缩：一屏内显示全，但保留可读高度与四周缝隙
const RUNNER_V := 0.78
## 设计稿内左右内边距（相对 CONTENT_W 外再缩一圈）
const PAGE_INSET_X := 3.0
const PAGE_INSET_TOP := 0.8
const PAGE_INSET_BOT := 1.2


static func _page_w() -> float:
	return Design.CONTENT_W - Design.cqw(PAGE_INSET_X) * 2.0


static func _vh(v: float) -> float:
	return Design.cqh(v * RUNNER_V)


static func _vhi(v: float) -> int:
	return int(round(_vh(v)))


## 区块高度同样走纵向压缩，避免故事/装备把页面撑出屏幕
static func _block_h(v: float) -> int:
	return _vhi(v)


static func build(parent: Control, ctx: Dictionary) -> void:
	var shell := _RunnerPageShell.new()
	shell.name = "RunnerPageShell"
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(shell)
	shell.setup(ctx)
	if parent is Control and not parent.resized.is_connected(shell._fit_canvas):
		parent.resized.connect(shell._fit_canvas)


class _RunnerPageShell extends Control:
	var _canvas: Control
	var _design_size := Vector2.ZERO
	var _base_design_size := Vector2.ZERO
	var _page_col: VBoxContainer
	var _equip_sec: VBoxContainer
	var _tray: PanelContainer
	var _fan_host: Control
	var _base_card_h := 0
	var _base_fan_h := 0
	var _fan_pad_v := 0
	var _card_w := 0
	var _fit_guard := false

	func setup(ctx: Dictionary) -> void:
		clip_contents = false
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_EXPAND_FILL
		_canvas = Control.new()
		_canvas.name = "DesignCanvas"
		_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_canvas)
		var built: Dictionary = CharacterPageUI._build_canvas(_canvas, ctx)
		_design_size = built.get("size", Vector2.ZERO)
		_base_design_size = _design_size
		_page_col = built.get("col") as VBoxContainer
		_equip_sec = built.get("equip_sec") as VBoxContainer
		_tray = built.get("tray") as PanelContainer
		_fan_host = built.get("fan_host") as Control
		_base_card_h = int(built.get("card_h", 0))
		_base_fan_h = int(built.get("fan_h", 0))
		_fan_pad_v = int(built.get("fan_pad_v", 0))
		_card_w = int(built.get("card_w", 0))
		_canvas.custom_minimum_size = _design_size
		_canvas.size = _design_size
		resized.connect(_fit_canvas)
		call_deferred("_fit_canvas")
		# 只盯 Scroll 视口，避免祖先链 resized 在中间态用错误尺寸反复拟合
		var ancestor: Node = get_parent()
		while ancestor:
			if ancestor is ScrollContainer:
				var sc := ancestor as ScrollContainer
				if not sc.resized.is_connected(_fit_canvas):
					sc.resized.connect(_fit_canvas)
				break
			ancestor = ancestor.get_parent()

	func _measure_avail() -> Vector2:
		var node: Node = self
		while node:
			if node is ScrollContainer:
				var sc := node as ScrollContainer
				if sc.size.x > 8.0 and sc.size.y > 8.0:
					return sc.size
			node = node.get_parent()
		var host := get_parent() as Control
		if host != null and host.size.x > 8.0 and host.size.y > 8.0:
			return host.size
		if size.x > 8.0 and size.y > 8.0:
			return size
		return Vector2.ZERO

	func _remeasure_design_height() -> float:
		if _page_col == null:
			return _base_design_size.y
		_page_col.custom_minimum_size = Vector2(CharacterPageUI._page_w(), 0)
		_page_col.reset_size()
		_page_col.update_minimum_size()
		var col_h := _page_col.get_combined_minimum_size().y
		# 测量异常时回退，避免后续 leftover 把缩放算崩
		if col_h < _base_design_size.y * 0.35 or col_h > _base_design_size.y * 4.0:
			col_h = _base_design_size.y
		_page_col.custom_minimum_size = Vector2(CharacterPageUI._page_w(), col_h)
		_page_col.size = _page_col.custom_minimum_size
		var pad := _page_col.get_parent() as Control
		if pad != null:
			pad.update_minimum_size()
			var pad_h := pad.get_combined_minimum_size().y
			if pad_h < _base_design_size.y * 0.35 or pad_h > _base_design_size.y * 4.0:
				pad_h = col_h + CharacterPageUI._vhi(CharacterPageUI.PAGE_INSET_TOP) + CharacterPageUI._vhi(CharacterPageUI.PAGE_INSET_BOT)
			pad.custom_minimum_size = Vector2(_base_design_size.x, pad_h)
			pad.size = pad.custom_minimum_size
			return pad_h
		return col_h + CharacterPageUI._vhi(CharacterPageUI.PAGE_INSET_TOP) + CharacterPageUI._vhi(CharacterPageUI.PAGE_INSET_BOT)

	func _fit_canvas() -> void:
		if _fit_guard or _base_design_size.x <= 0.0:
			return
		var avail := _measure_avail()
		if avail.x <= 8.0 or avail.y <= 8.0:
			return
		_fit_guard = true

		# 宿主锁死为视口，避免被未缩放 canvas 的设计高度撑破
		custom_minimum_size = Vector2(maxi(1, int(avail.x)), int(floor(avail.y)))
		size = custom_minimum_size

		# 1) 始终按宽度铺满——可读性优先，禁止再出现「缩成一小块」
		var scale_x := avail.x / _base_design_size.x
		var room := maxf(avail.y - 2.0, 1.0)
		var scale := scale_x

		# 2) 先回到基础卡片高度，测真实内容高
		_apply_equip_card_height(_base_card_h)
		var content_h := _remeasure_design_height()
		content_h = clampf(content_h, _base_design_size.y * 0.5, _base_design_size.y * 2.5)

		# 3) 宽度缩放后若还有竖直空余，有上限地加高装备卡（禁止无上限 leftover）
		var target_h := room / maxf(scale, 0.001)
		if content_h < target_h - 4.0 and _base_card_h > 0:
			var grow := int(floor(target_h - content_h))
			var grow_cap := maxi(_base_card_h, int(round(float(_base_card_h) * 1.25)))
			grow = clampi(grow, 0, grow_cap)
			if grow > 2:
				_apply_equip_card_height(_base_card_h + grow)
				var grown_h := _remeasure_design_height()
				if grown_h > target_h * 1.2 or grown_h < content_h:
					# 测量失控则退回基础高度
					_apply_equip_card_height(_base_card_h)
					content_h = _remeasure_design_height()
				else:
					content_h = grown_h

		content_h = clampf(content_h, _base_design_size.y * 0.5, target_h * 1.05)
		_design_size = Vector2(_base_design_size.x, content_h)

		# 4) 仅当基础内容仍超出时才略降缩放，且不低于宽度缩放的 92%
		if content_h * scale > room + 1.0:
			scale = maxf(room / maxf(content_h, 1.0), scale_x * 0.92)

		if _equip_sec:
			_equip_sec.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		if _tray:
			_tray.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		if _fan_host:
			_fan_host.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		_canvas.custom_minimum_size = _design_size
		_canvas.size = _design_size
		_canvas.scale = Vector2(scale, scale)
		var fitted := _design_size * scale
		_canvas.position = Vector2((avail.x - fitted.x) * 0.5, 0.0)
		_fit_guard = false

	func _apply_equip_card_height(card_h: int) -> void:
		if _fan_host == null or _base_card_h <= 0:
			return
		card_h = maxi(card_h, _base_card_h)
		var fan_h := card_h + _fan_pad_v * 2 + CharacterPageUI._block_h(0.35)
		if card_h <= _base_card_h and _base_fan_h > 0:
			fan_h = _base_fan_h
		_fan_host.custom_minimum_size = Vector2(
			_fan_host.custom_minimum_size.x if _fan_host.custom_minimum_size.x > 0 else 1.0,
			fan_h
		)
		_fan_host.size = _fan_host.custom_minimum_size
		for child in _fan_host.get_children():
			if child is Control:
				var card := child as Control
				var cw := _card_w if _card_w > 0 else int(card.custom_minimum_size.x)
				if cw <= 0:
					cw = 1
				card.custom_minimum_size = Vector2(cw, card_h)
				card.size = Vector2(cw, card_h)
				card.position.y = float(_fan_pad_v)
				for nested in card.get_children():
					if nested is Control:
						var panel := nested as Control
						panel.custom_minimum_size = Vector2(cw, card_h)
						panel.size = Vector2(cw, card_h)


static func _build_canvas(root: Control, ctx: Dictionary) -> Dictionary:
	var character_id: String = String(ctx.get("character_id", CharacterRoster.CHAR_ELSA))
	var snapshot: Dictionary = ctx.get("snapshot", {})
	var character: Dictionary = CharacterRoster.get_character(character_id)
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	var is_locked := not CharacterRoster.is_unlocked(character_id, unlocked)
	var is_active := String(ctx.get("active_character_id", character_id)) == character_id

	var col := VBoxContainer.new()
	var page_w := _page_w()
	col.custom_minimum_size = Vector2(page_w, 0)
	col.size = Vector2(page_w, 0)
	col.add_theme_constant_override("separation", _vhi(0.9))
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pad := MarginContainer.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_theme_constant_override("margin_left", int(Design.cqw(PAGE_INSET_X)))
	pad.add_theme_constant_override("margin_right", int(Design.cqw(PAGE_INSET_X)))
	pad.add_theme_constant_override("margin_top", _vhi(PAGE_INSET_TOP))
	pad.add_theme_constant_override("margin_bottom", _vhi(PAGE_INSET_BOT))
	pad.add_child(col)
	root.add_child(pad)

	col.add_child(_build_hub(ctx, character, snapshot, character_id, is_locked, is_active))
	col.add_child(_build_character_switch_bar(ctx, character_id, snapshot))
	col.add_child(_build_info_section(ctx, character, snapshot, character_id, is_locked, is_active))
	col.add_child(_build_story_banner(ctx, character, is_locked))
	var equip_built: Dictionary = _build_equipment_section(character, is_locked)
	var equip_sec: VBoxContainer = equip_built["sec"]
	col.add_child(equip_sec)

	_finalize_col(col)
	pad.update_minimum_size()
	var pad_sz := pad.get_combined_minimum_size()
	pad.custom_minimum_size = pad_sz
	pad.size = pad_sz
	return {
		"size": Vector2(Design.CONTENT_W, pad_sz.y),
		"col": col,
		"equip_sec": equip_sec,
		"tray": equip_built.get("tray"),
		"fan_host": equip_built.get("fan_host"),
		"card_h": equip_built.get("card_h", 0),
		"fan_h": equip_built.get("fan_h", 0),
		"fan_pad_v": equip_built.get("fan_pad_v", 0),
		"card_w": equip_built.get("card_w", 0),
	}


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
	# 立绘环按宽度略收，给下方 XP/故事/装备留出一屏空间
	var ring_size := int(Design.cqw(42))
	var chip_px := int(Design.cqw(7.2))
	var stat_gap := Design.cqw(1.6)
	var orbit_r := ring_size * 0.5 + chip_px * 0.5 + stat_gap
	# SPEED 在圆顶外侧：label + value 叠在 chip 上方，顶边必须留足，否则会被裁切
	var value_fs := Design.fs_cqw(3.8)
	var label_fs := Design.fs_cqw(2.2)
	var stack_sep := _vhi(0.15)
	var orbit_out := orbit_r - ring_size * 0.5
	var ring_pad_top := int(ceil(
		orbit_out + label_fs + value_fs + chip_px * 0.5 + stack_sep * 2.0 + _vh(0.55)
	))
	var ring_pad_bot := int(ceil(
		orbit_out * 0.42 + chip_px * 0.5 + value_fs + label_fs + stack_sep * 2.0 + _vh(0.35)
	))
	var ring_top := ring_pad_top
	var inset := ring_size * 0.075
	var portrait_d := int(ring_size - inset * 2.0)
	var hub_h := ring_top + ring_size + ring_pad_bot

	var hub := Control.new()
	hub.custom_minimum_size = Vector2(_page_w(), hub_h)
	hub.size = hub.custom_minimum_size
	hub.clip_contents = false
	hub.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var glow := _HubBackdrop.new()
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hub.add_child(glow)

	var id_tag := _pill_tag("?" if is_locked else String(character.get("runner_code", "R-07")))
	id_tag.z_index = 8
	hub.add_child(id_tag)
	id_tag.reset_size()
	var tag_sz := id_tag.get_combined_minimum_size()
	if tag_sz.x < 8.0:
		tag_sz = Vector2(Design.cqw(12.0), Design.cqh(2.4))
	id_tag.position = Vector2(_page_w() - tag_sz.x - Design.cqw(1.2), Design.cqh(0.55))

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
			hub.add_child(_build_stat_node(stat as Dictionary, is_locked, ring_top, ring_size, chip_px, orbit_r))

	return hub


static func _build_stat_node(
	stat: Dictionary,
	masked: bool,
	ring_top: float,
	ring_size: float,
	chip_px: int,
	orbit_r: float
) -> Control:
	var icon := String(stat.get("icon", "sp"))
	var color: Color = Design.STAT_COLORS.get(icon, Design.CYAN_SOFT)
	if masked:
		color.a *= 0.55

	var node := Control.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.z_index = 4
	node.clip_contents = false

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", _vhi(0.2))
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 顶部 SPEED：文字在外侧；底部 HP/EN：文字在外侧，圆 chip 朝向立绘
	# 子项水平居中：避免 STAMINA 比 HP 宽时，左对齐把「120」的「1」挤进立绘被挡成「20」
	if icon == "sp":
		col.add_child(_stat_label(String(stat.get("label", "SPEED"))))
		col.add_child(_stat_value(stat, color, masked))
		col.add_child(_stat_chip(icon, color, chip_px))
	else:
		col.add_child(_stat_chip(icon, color, chip_px))
		col.add_child(_stat_value(stat, color, masked))
		col.add_child(_stat_label(String(stat.get("label", ""))))
	for child in col.get_children():
		if child is Control:
			(child as Control).size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	node.add_child(col)
	col.update_minimum_size()
	var sz := col.get_combined_minimum_size()
	# 给三位数数值留足宽度，防止 min size 低估后被裁切
	sz.x = maxf(sz.x, Design.cqw(14.0))
	node.custom_minimum_size = sz
	node.size = sz
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var hub_cx := _page_w() * 0.5
	var hub_cy := ring_top + ring_size * 0.5
	var angle_deg: float = STAT_ORBIT_DEG.get(icon, -90.0)
	var dir := Vector2(cos(deg_to_rad(angle_deg)), sin(deg_to_rad(angle_deg)))
	# 侧向属性略收，避免贴边被 Scroll 裁切
	var orbit_use := orbit_r * (0.92 if icon != "sp" else 1.0)
	var chip_anchor := Vector2(hub_cx, hub_cy) + dir * orbit_use

	node.set_anchors_preset(Control.PRESET_TOP_LEFT)
	if icon == "sp":
		node.position = chip_anchor - Vector2(sz.x * 0.5, sz.y - chip_px * 0.5)
	else:
		node.position = chip_anchor - Vector2(sz.x * 0.5, chip_px * 0.5)
	var margin := Design.cqw(0.8)
	node.position.x = clampf(node.position.x, margin, _page_w() - sz.x - margin)
	node.position.y = maxf(node.position.y, 0.0)
	return node


static func _stat_chip(icon: String, color: Color, size_px: int) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(size_px, size_px)
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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


static func _stat_value(stat: Dictionary, color: Color, masked: bool = false) -> Label:
	var label := Label.new()
	label.text = "?" if masked else String(stat.get("value", ""))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_size_override("font_size", Design.fs_cqw(3.8))
	label.add_theme_color_override("font_color", color.lerp(Color.WHITE, 0.35))
	label.add_theme_color_override("font_shadow_color", Color(color.r, color.g, color.b, 0.55))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08, 0.75))
	return label


static func _stat_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_size_override("font_size", Design.fs_cqw(2.2))
	label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86))
	label.add_theme_constant_override("letter_spacing", Design.em_cqw(2.2, 0.18))
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


static func _hub_arrow_btn(ctx: Dictionary, next: bool) -> Control:
	var wrap := Control.new()
	var sz := maxi(_vhi(3.2), 28)
	wrap.custom_minimum_size = Vector2(sz, sz)
	wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	var lbl := Label.new()
	lbl.text = "›" if next else "‹"
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", int(sz * 0.56))
	lbl.add_theme_color_override("font_color", Design.ICE)
	lbl.add_theme_color_override("font_shadow_color", Color(0.38, 0.78, 1.0, 0.55))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(lbl)
	var cb: Callable = ctx.get("on_cycle", Callable())
	if cb.is_valid():
		wrap.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				cb.call(1 if next else -1)
		)
	return wrap


static func _build_character_switch_bar(ctx: Dictionary, current_id: String, snapshot: Dictionary) -> Control:
	var bar := PanelContainer.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size = Vector2(0, int(Design.cqh(3.6) * RUNNER_V))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.015, 0.028, 0.048, 0.94)
	panel.border_color = Color(0.627, 0.784, 0.922, 0.38)
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(Design.fs_cqw(2.4))
	panel.content_margin_left = int(Design.cqw(2.0))
	panel.content_margin_right = int(Design.cqw(2.0))
	panel.content_margin_top = _vhi(0.4)
	panel.content_margin_bottom = _vhi(0.4)
	bar.add_theme_stylebox_override("panel", panel)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", int(Design.cqw(3.2)))
	bar.add_child(row)
	row.add_child(_hub_arrow_btn(ctx, false))

	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.alignment = BoxContainer.ALIGNMENT_CENTER
	mid.add_theme_constant_override("separation", int(Design.cqh(0.35)))
	row.add_child(mid)

	var dots := HBoxContainer.new()
	dots.alignment = BoxContainer.ALIGNMENT_CENTER
	dots.add_theme_constant_override("separation", int(Design.cqw(1.6)))
	mid.add_child(dots)
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	for id in CharacterRoster.ordered_ids():
		var dot := Button.new()
		dot.focus_mode = Control.FOCUS_NONE
		var d := maxi(int(Design.cqw(1.8)), 7)
		dot.custom_minimum_size = Vector2(d, d)
		var on := id == current_id
		var st := StyleBoxFlat.new()
		var id_unlocked := CharacterRoster.is_unlocked(id, unlocked)
		if on:
			st.bg_color = Design.CYAN
		elif id_unlocked:
			st.bg_color = Color(0.627, 0.784, 0.922, 0.38)
		else:
			st.bg_color = Color(0.627, 0.784, 0.922, 0.18)
		st.set_corner_radius_all(d / 2)
		if on:
			st.shadow_color = Color(Design.CYAN.r, Design.CYAN.g, Design.CYAN.b, 0.85)
			st.shadow_size = 5
		dot.add_theme_stylebox_override("normal", st)
		dot.add_theme_stylebox_override("hover", st)
		dot.add_theme_stylebox_override("pressed", st)
		dot.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var cb: Callable = ctx.get("on_select", Callable())
		if cb.is_valid():
			dot.pressed.connect(cb.bind(id))
		dots.add_child(dot)

	var hint := Label.new()
	hint.text = "SWITCH RUNNER"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", Design.fs_cqw(2.0))
	hint.add_theme_color_override("font_color", Design.TEXT_SUB)
	hint.add_theme_constant_override("letter_spacing", Design.em_cqw(2.0, 0.28))
	mid.add_child(hint)

	row.add_child(_hub_arrow_btn(ctx, true))
	return bar


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
	character_id: String,
	is_locked: bool,
	is_active: bool
) -> Control:
	var wrap := VBoxContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_theme_constant_override("separation", _vhi(0.45))
	wrap.add_child(_build_xp_strip(snapshot, is_locked))

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var info_style := Design.card_style()
	info_style.content_margin_top = _vhi(0.7)
	info_style.content_margin_bottom = _vhi(0.7)
	info_style.content_margin_left = Design.fs_cqw(3.0)
	info_style.content_margin_right = Design.fs_cqw(3.0)
	card.add_theme_stylebox_override("panel", info_style)
	wrap.add_child(card)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", _vhi(0.35))
	card.add_child(body)

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", int(Design.cqw(2.0)))
	name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	name_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(name_row)

	var name := Label.new()
	name.text = String(character.get("name_en", "ELSA"))
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", Design.fs_cqw(5.4))
	name.add_theme_color_override("font_color", Design.ICE)
	name.add_theme_color_override("font_shadow_color", Color(0.667, 0.894, 0.98, 0.45))
	name_row.add_child(name)

	if not is_locked:
		var use_chip := _build_use_chip(ctx, character_id, is_active)
		use_chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		name_row.add_child(use_chip)

	var bonus := Label.new()
	var bonus_pct := "?" if is_locked else String(character.get("level_bonus_pct", snapshot.get("coin_bonus_text", "+0%")))
	bonus.text = "LEVEL BONUS • EMBER COINS %s" % bonus_pct
	bonus.add_theme_font_size_override("font_size", Design.fs_cqw(2.3))
	bonus.add_theme_color_override("font_color", Design.CYAN_SOFT)
	body.add_child(bonus)

	return wrap


static func _build_xp_strip(snapshot: Dictionary, masked: bool = false) -> Control:
	var badge := PanelContainer.new()
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge.custom_minimum_size = Vector2(0, _vhi(3.1))
	badge.add_theme_stylebox_override("panel", Design.glass_style(Design.cqw(8), Vector4(12, 4, 12, 4)))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", int(Design.cqw(2.4)))
	badge.add_child(row)

	var lv := Label.new()
	lv.text = "LV.?" if masked else "LV.%d" % int(snapshot.get("level", 1))
	lv.add_theme_font_size_override("font_size", Design.fs_cqw(4.0))
	lv.add_theme_color_override("font_color", Design.ICE)
	lv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lv)

	var xp_need := int(snapshot.get("xp_to_next", 0))
	var xp_into := int(snapshot.get("xp_into_level", 0))
	var bar_h := maxi(int(Design.cqh(0.65)), 5)
	var bar_wrap := CenterContainer.new()
	bar_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_wrap.custom_minimum_size = Vector2(0, _vhi(2.0))
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, bar_h)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false
	bar.max_value = 1.0 if masked else float(maxi(xp_need, 1))
	bar.value = 0.0 if masked else float(xp_into if xp_need > 0 else 1)
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.627, 0.784, 0.922, 0.15)
	track.set_corner_radius_all(Design.fs_cqw(1))
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.384, 0.863, 0.961)
	fill.set_corner_radius_all(Design.fs_cqw(1))
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", fill)
	bar_wrap.add_child(bar)
	row.add_child(bar_wrap)

	var xp := Label.new()
	xp.text = "? / ? XP" if masked else ("MAX XP" if xp_need <= 0 else "%s / %s XP" % [_fmt(xp_into), _fmt(xp_need)])
	xp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	xp.add_theme_font_size_override("font_size", Design.fs_cqw(2.1))
	xp.add_theme_color_override("font_color", Design.TEXT_SUB)
	xp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(xp)
	return badge


static func _build_use_chip(ctx: Dictionary, character_id: String, is_active: bool) -> Control:
	var chip := PanelContainer.new()
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var chip_h := _vhi(3.0)
	chip.custom_minimum_size = Vector2(0, chip_h)
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(Design.fs_cqw(1.6))
	var pad_v := _vhi(0.4)
	var pad_h := Design.fs_cqw(2.2)
	style.content_margin_left = pad_h
	style.content_margin_right = pad_h
	style.content_margin_top = pad_v
	style.content_margin_bottom = pad_v
	if is_active:
		style.bg_color = Color(0.494, 0.878, 0.722, 0.12)
		style.border_color = Color(0.494, 0.878, 0.722, 0.6)
	else:
		style.bg_color = Color(0.314, 0.549, 0.745, 0.45)
		style.border_color = Color(0.745, 0.933, 1.0, 0.55)
	style.set_border_width_all(1)
	chip.add_theme_stylebox_override("panel", style)

	var center := CenterContainer.new()
	chip.add_child(center)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(Design.cqw(1.2)))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(row)

	var dot_sz := int(Design.cqw(1.2))
	var dot := PanelContainer.new()
	dot.custom_minimum_size = Vector2(dot_sz, dot_sz)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var dot_style := StyleBoxFlat.new()
	dot_style.bg_color = Design.GREEN if is_active else Design.CYAN
	dot_style.set_corner_radius_all(dot_sz / 2)
	dot.add_theme_stylebox_override("panel", dot_style)
	row.add_child(dot)

	var label := Label.new()
	label.text = "IN USE" if is_active else "SWITCH"
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_size_override("font_size", Design.fs_cqw(2.5))
	label.add_theme_color_override("font_color", Color(0.682, 0.949, 0.831) if is_active else Design.ICE)
	row.add_child(label)

	if not is_active:
		var hit := Button.new()
		hit.flat = true
		hit.focus_mode = Control.FOCUS_NONE
		hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hit.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		hit.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		hit.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		hit.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		var cb: Callable = ctx.get("on_switch", Callable())
		if cb.is_valid():
			hit.pressed.connect(cb.bind(character_id))
		chip.add_child(hit)
	return chip


static func _build_story_banner(ctx: Dictionary, character: Dictionary, locked: bool) -> Control:
	# 故事条保底高度：两行字 + 内边距，避免被纵向压缩挤成一条线
	var title_fs := Design.fs_cqw(3.4)
	var sub_fs := Design.fs_cqw(2.3)
	var pad_v := maxi(_block_h(1.15), 8)
	var banner_h := maxi(_block_h(9.4), title_fs + sub_fs + pad_v * 2 + _vhi(0.55))
	var icon_side := int(clampf(float(banner_h - pad_v), Design.cqw(7.5), Design.cqw(10.0)))

	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(0, banner_h)
	btn.clip_contents = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045, 0.095, 0.165, 0.96)
	style.border_color = Color(0.667, 0.902, 1.0, 0.52)
	style.set_border_width_all(2)
	style.set_corner_radius_all(Design.fs_cqw(2.4))
	style.content_margin_left = Design.fs_cqw(2.6)
	style.content_margin_right = Design.fs_cqw(2.6)
	style.content_margin_top = pad_v
	style.content_margin_bottom = pad_v
	style.shadow_color = Color(Design.CYAN.r, Design.CYAN.g, Design.CYAN.b, 0.22)
	style.shadow_size = 10
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
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", int(Design.cqw(2.4)))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(row)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(icon_side, icon_side)
	icon_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var icon_box := StyleBoxFlat.new()
	icon_box.bg_color = Color(0.08, 0.16, 0.28, 0.95)
	icon_box.border_color = Color(0.667, 0.902, 1.0, 0.55)
	icon_box.set_border_width_all(1)
	icon_box.set_corner_radius_all(icon_side / 2)
	icon_wrap.add_theme_stylebox_override("panel", icon_box)
	var icon := Label.new()
	icon.text = "📖"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.add_theme_font_size_override("font_size", int(icon_side * 0.42))
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_wrap.add_child(icon)
	row.add_child(icon_wrap)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_col.add_theme_constant_override("separation", maxi(_vhi(0.25), 2))
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_col)
	var title := Label.new()
	title.text = "RUNNER STORY"
	title.add_theme_font_size_override("font_size", title_fs)
	title.add_theme_color_override("font_color", Design.ICE)
	title.add_theme_constant_override("letter_spacing", Design.em_cqw(3.4, 0.10))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(title)
	var sub := Label.new()
	sub.text = "? ? ?" if locked else "READ CHARACTER ARCHIVE"
	sub.add_theme_font_size_override("font_size", sub_fs)
	sub.add_theme_color_override("font_color", Design.TEXT_SUB if locked else Design.CYAN_SOFT)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(sub)

	var chev := Label.new()
	chev.text = "›"
	chev.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chev.add_theme_font_size_override("font_size", Design.fs_cqw(5.8))
	chev.add_theme_color_override("font_color", Design.CYAN)
	chev.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(chev)
	return btn


static func _build_equipment_section(character: Dictionary, is_locked: bool) -> Dictionary:
	var sec := VBoxContainer.new()
	sec.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sec.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	sec.add_theme_constant_override("separation", _vhi(0.4))
	sec.add_child(_section_label())

	var tray := PanelContainer.new()
	tray.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tray.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	tray.clip_contents = false
	var tray_style := StyleBoxFlat.new()
	# 半透明玻璃托盘：贴合卡片，避免大块近黑底板
	tray_style.bg_color = Color(0.018, 0.034, 0.058, 0.42)
	tray_style.border_color = Color(0.627, 0.784, 0.922, 0.22)
	tray_style.set_border_width_all(1)
	tray_style.set_corner_radius_all(Design.fs_cqw(2.0))
	tray_style.content_margin_left = int(Design.cqw(1.2))
	tray_style.content_margin_right = int(Design.cqw(1.2))
	tray_style.content_margin_top = _block_h(0.55)
	tray_style.content_margin_bottom = _block_h(0.7)
	tray.add_theme_stylebox_override("panel", tray_style)
	sec.add_child(tray)

	var fan_host := Control.new()
	var card_w := int(Design.cqw(27))
	var card_h := _block_h(15.5) if is_locked else _block_h(17.5)
	var overlap := int(Design.cqw(1.4))
	var fan_pad_v := _block_h(0.45)
	var fan_h := card_h + fan_pad_v * 2 + _block_h(0.35)
	fan_host.custom_minimum_size = Vector2(
		_page_w() - Design.cqw(2.4),
		fan_h
	)
	fan_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fan_host.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	fan_host.clip_contents = false
	tray.add_child(fan_host)

	var gear_list: Array = character.get("gear", [])
	var count := gear_list.size()
	var host_w := fan_host.custom_minimum_size.x
	var total_w := card_w * count - overlap * maxi(count - 1, 0)
	var start_x := (host_w - total_w) * 0.5

	for i in count:
		if gear_list[i] is Dictionary:
			var card := _build_gear_card(gear_list[i] as Dictionary, i, is_locked, card_w, card_h)
			card.position = Vector2(start_x + i * (card_w - overlap), fan_pad_v)
			card.z_index = 2 if i == 1 else 1
			fan_host.add_child(card)

	return {
		"sec": sec,
		"tray": tray,
		"fan_host": fan_host,
		"card_h": card_h,
		"fan_h": fan_h,
		"fan_pad_v": fan_pad_v,
		"card_w": card_w,
	}


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
	if runner_locked:
		locked = false
		empty = false
	var rarity := String(gear.get("rarity", "rare"))
	var accent: Color = Design.RARITY.get(rarity, Design.CYAN_SOFT)
	if runner_locked:
		accent = Design.CYAN_SOFT
	elif locked or empty:
		accent = Color(0.42, 0.486, 0.561)

	var pivot := Control.new()
	pivot.custom_minimum_size = Vector2(card_w, card_h)
	pivot.size = Vector2(card_w, card_h)
	pivot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot.pivot_offset = Vector2(card_w * 0.5, card_h * 0.5)

	var corner_r := Design.fs_cqw(2.2)
	var panel_style := Design.gear_style(accent, (locked or empty) and not runner_locked, corner_r)
	panel_style.content_margin_left = int(Design.cqw(1.2))
	panel_style.content_margin_right = int(Design.cqw(1.2))
	panel_style.content_margin_top = _block_h(0.5)
	panel_style.content_margin_bottom = _block_h(0.55)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(card_w, card_h)
	panel.size = Vector2(card_w, card_h)
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", panel_style)
	pivot.add_child(panel)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", int(Design.cqh(0.35)))
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(col)

	if not locked and not empty and not runner_locked:
		var shine := ColorRect.new()
		shine.custom_minimum_size = Vector2(card_w - int(Design.cqw(2.8)), 1)
		shine.size = shine.custom_minimum_size
		shine.position = Vector2(int(Design.cqw(1.4)), 1)
		var hi := accent.lerp(Color.WHITE, 0.45)
		shine.color = Color(hi.r, hi.g, hi.b, 0.28)
		shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(shine)
		shine.z_index = 2

	var slot := Label.new()
	slot.text = "?" if runner_locked else String(gear.get("slot", "SLOT"))
	slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_theme_font_size_override("font_size", Design.fs_cqw(2.1))
	slot.add_theme_color_override("font_color", Design.TEXT_SUB)
	slot.add_theme_constant_override("letter_spacing", Design.em_cqw(2.1, 0.22))
	col.add_child(slot)

	var icon_box := _gear_icon_box(accent, (locked or empty) and not runner_locked)
	col.add_child(icon_box)
	var icon_l := Label.new()
	if runner_locked:
		icon_l.text = "?"
	elif locked:
		icon_l.text = "🔒"
	elif empty:
		icon_l.text = "+"
	else:
		icon_l.text = GEAR_GLYPH.get(String(gear.get("icon_key", "")), "G")
	icon_l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_l.add_theme_font_size_override("font_size", Design.fs_cqw(4.5))
	icon_l.add_theme_color_override("font_color", Design.ICE if runner_locked else accent.lerp(Design.ICE, 0.72) if not (locked or empty) else Design.TEXT_SUB)
	icon_box.add_child(icon_l)

	var name := Label.new()
	if runner_locked:
		name.text = "???"
	elif locked:
		name.text = "LOCKED"
	elif empty:
		name.text = "EMPTY SLOT"
	else:
		name.text = String(gear.get("name", ""))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name.clip_text = true
	name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name.custom_minimum_size = Vector2(card_w - 8, Design.cqw(4.2))
	name.add_theme_font_size_override("font_size", Design.fs_cqw(2.5))
	name.add_theme_color_override("font_color", Design.ICE if not (locked or empty) else Design.TEXT_SUB)
	col.add_child(name)

	if not locked and not empty:
		var rarity_wrap := PanelContainer.new()
		rarity_wrap.add_theme_stylebox_override("panel", Design.gear_rarity_style(accent))
		var rarity_l := Label.new()
		rarity_l.text = "?" if runner_locked else String(gear.get("rarity_label", "RARE"))
		rarity_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rarity_l.add_theme_font_size_override("font_size", Design.fs_cqw(2.3))
		rarity_l.add_theme_color_override("font_color", accent.lerp(Design.ICE, 0.78))
		rarity_l.add_theme_constant_override("letter_spacing", Design.em_cqw(2.3, 0.14))
		rarity_wrap.add_child(rarity_l)
		col.add_child(rarity_wrap)
	return pivot


static func _gear_icon_box(accent: Color, dimmed: bool) -> PanelContainer:
	var box := PanelContainer.new()
	var side := int(Design.cqw(10.0))
	box.custom_minimum_size = Vector2(side, side)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.08, 0.95)
	style.border_color = accent.lerp(Color(0.72, 0.90, 1.0), 0.65) if not dimmed else Color(0.42, 0.486, 0.561)
	style.set_border_width_all(1 if dimmed else 2)
	style.set_corner_radius_all(Design.fs_cqw(2))
	if not dimmed:
		style.shadow_color = Color(accent.r, accent.g, accent.b, 0.35)
		style.shadow_size = 6
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
