class_name MapLocationMarker
extends Control

signal activated

const MARKER_SIZE := 58.0
const LABEL_WIDTH := 128.0
const PIN_HIT := 76.0
const PIN_TIP_OFFSET_Y := 30.0

var location_id := ""
var _type_icon := "◎"
var _display_name := ""
var _preview_path := ""

var _glow: PanelContainer
var _frame: PanelContainer
var _preview: TextureRect
var _badge: Label
var _lock_overlay: ColorRect
var _name_panel: PanelContainer
var _name_label: Label
var _pin_canvas: Control
var _hit_button: Button
var _revealed := true
var _completed := false
var _selected := false
var _preview_mode := false
var _on_board := false
var _has_progress := false
var _show_question := false
var _pin_mode := false
var _ui_built := false
var _accent := Color(0.42, 0.82, 0.98)
var _pulse_tween: Tween
var _pulse_phase := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(MARKER_SIZE, MARKER_SIZE + 32.0)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	_apply_pending_config()
	_refresh_visuals()


func configure(id: String, display_name: String, preview_path: String, type_icon: String) -> void:
	location_id = id
	_display_name = display_name
	_preview_path = preview_path
	_type_icon = type_icon
	if _ui_built:
		_apply_pending_config()
		_refresh_visuals()


func set_pin_mode(enabled: bool) -> void:
	_pin_mode = enabled
	if _ui_built:
		_apply_layout_mode()
		_refresh_visuals()


func apply_state(
	revealed: bool,
	completed: bool,
	selected: bool,
	on_board: bool = false,
	_has_progress_unused: bool = false,
	preview: bool = false
) -> void:
	_revealed = revealed
	_completed = completed
	_selected = selected
	_on_board = on_board and not completed
	# 红点仅「已点亮」；运输进度半满不算红
	_has_progress = completed
	_preview_mode = preview
	_show_question = (revealed or preview) and not _on_board and not _completed
	if _ui_built:
		_refresh_visuals()


func _apply_pending_config() -> void:
	if not _ui_built:
		return
	if _name_label:
		_name_label.text = _display_name
	if _badge:
		_badge.text = _type_icon
	if _preview and _preview_path != "" and ResourceLoader.exists(_preview_path):
		_preview.texture = load(_preview_path) as Texture2D
	_apply_layout_mode()


func _apply_layout_mode() -> void:
	if not _ui_built:
		return
	if _pin_mode:
		custom_minimum_size = Vector2(PIN_HIT, PIN_HIT)
		size = custom_minimum_size
		if _frame:
			_frame.visible = false
		if _preview:
			_preview.visible = false
		if _lock_overlay:
			_lock_overlay.visible = false
		if _badge:
			_badge.visible = false
		if _name_panel:
			_name_panel.visible = false
		if _glow:
			_glow.visible = false
		if _pin_canvas:
			_pin_canvas.visible = true
			_pin_canvas.set_anchors_preset(PRESET_FULL_RECT)
	else:
		custom_minimum_size = Vector2(MARKER_SIZE, MARKER_SIZE + 32.0)
		size = custom_minimum_size
		if _frame:
			_frame.visible = true
		if _preview:
			_preview.visible = true
		if _badge:
			_badge.visible = true
		if _name_panel:
			_name_panel.visible = true
			_name_panel.position = Vector2((MARKER_SIZE - LABEL_WIDTH) * 0.5, MARKER_SIZE + 4)
		if _glow:
			_glow.visible = true
			_glow.position = Vector2(-5, -5)
			_glow.custom_minimum_size = Vector2(MARKER_SIZE + 10, MARKER_SIZE + 10)
		if _pin_canvas:
			_pin_canvas.visible = false


func _build_ui() -> void:
	if _ui_built:
		return

	_glow = PanelContainer.new()
	_glow.position = Vector2(-5, -5)
	_glow.custom_minimum_size = Vector2(MARKER_SIZE + 10, MARKER_SIZE + 10)
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_glow)

	_frame = PanelContainer.new()
	_frame.custom_minimum_size = Vector2(MARKER_SIZE, MARKER_SIZE)
	_frame.clip_contents = true
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)

	_preview = TextureRect.new()
	_preview.set_anchors_preset(PRESET_FULL_RECT)
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_preview)

	_lock_overlay = ColorRect.new()
	_lock_overlay.set_anchors_preset(PRESET_FULL_RECT)
	_lock_overlay.color = Color(0.04, 0.06, 0.10, 0.62)
	_lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock_overlay.visible = false
	_frame.add_child(_lock_overlay)

	_badge = Label.new()
	_badge.text = "◎"
	_badge.position = Vector2(4, 2)
	_badge.custom_minimum_size = Vector2(22, 18)
	_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_badge.add_theme_font_size_override("font_size", 11)
	_badge.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_badge)

	_pin_canvas = Control.new()
	_pin_canvas.name = "PinCanvas"
	_pin_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pin_canvas.set_anchors_preset(PRESET_FULL_RECT)
	add_child(_pin_canvas)
	_pin_canvas.draw.connect(_draw_pin)

	_name_panel = PanelContainer.new()
	_name_panel.position = Vector2((MARKER_SIZE - LABEL_WIDTH) * 0.5, MARKER_SIZE + 4)
	_name_panel.custom_minimum_size = Vector2(LABEL_WIDTH, 26)
	_name_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_panel)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.set_anchors_preset(PRESET_FULL_RECT)
	_name_label.add_theme_font_size_override("font_size", 13)
	_name_label.add_theme_color_override("font_color", Color(0.90, 0.94, 0.98))
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name_panel.add_child(_name_label)

	_hit_button = Button.new()
	_hit_button.focus_mode = Control.FOCUS_NONE
	_hit_button.flat = true
	_hit_button.set_anchors_preset(PRESET_FULL_RECT)
	_hit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_hit_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_hit_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_hit_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_hit_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_hit_button.pressed.connect(func(): activated.emit())
	add_child(_hit_button)

	_ui_built = true
	_apply_layout_mode()


func _draw_pin() -> void:
	if not _pin_mode or _pin_canvas == null:
		return
	var c := _pin_canvas.size * 0.5
	if c.x < 4.0:
		c = Vector2(PIN_HIT * 0.5, PIN_HIT * 0.5)
	# 未发放：只画问号，不要外圈
	if _show_question or (not _revealed and not _preview_mode and not _on_board and not _completed):
		var q_col := Color(0.78, 0.82, 0.88, 0.92) if _show_question else Color(0.62, 0.66, 0.72, 0.82)
		_pin_canvas.draw_string(ThemeDB.fallback_font, c + Vector2(-7, 8), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, q_col)
		return
	var accent := _accent
	var pulse := 0.5 + 0.5 * sin(_pulse_phase) if (_on_board or _completed) else 0.0
	var outer_r := lerpf(22.0, 30.0, pulse) if pulse > 0.0 else 22.0
	var ring_a := lerpf(0.18, 0.42, pulse) if pulse > 0.0 else 0.14
	var inner_r := 16.0
	# 外圈脉冲
	_pin_canvas.draw_arc(c, outer_r, 0.0, TAU, 48, Color(accent.r, accent.g, accent.b, ring_a), 2.0, true)
	_pin_canvas.draw_arc(c, outer_r * 0.72, 0.0, TAU, 40, Color(accent.r, accent.g, accent.b, ring_a * 0.55), 1.2, true)
	# 中心定位点
	_pin_canvas.draw_circle(c, inner_r + 3.0, Color(accent.r, accent.g, accent.b, 0.12))
	_pin_canvas.draw_circle(c, inner_r, Color(0.04, 0.07, 0.12, 0.78))
	_pin_canvas.draw_arc(c, inner_r, 0.0, TAU, 32, accent, 2.0, true)
	# 下方小三角指示
	var tip := c + Vector2(0.0, inner_r + 7.0)
	var tri := PackedVector2Array([
		tip + Vector2(0.0, 7.0),
		tip + Vector2(-5.0, 0.0),
		tip + Vector2(5.0, 0.0),
	])
	_pin_canvas.draw_colored_polygon(tri, Color(accent.r, accent.g, accent.b, 0.85))
	# 类型图标（简化为圆点/星）
	if _completed:
		_pin_canvas.draw_string(ThemeDB.fallback_font, c + Vector2(-6, 5), "★", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.82, 0.78, 0.95))
	elif _on_board:
		_pin_canvas.draw_circle(c, 4.5, accent.lightened(0.22))


func _refresh_visuals() -> void:
	if not _ui_built:
		return
	# 黄=任务板发放中 · 红=已点亮 · 灰?=已揭示但未发放
	var accent := Color(0.38, 0.72, 0.96)
	var glow := Color(0.22, 0.46, 0.72, 0.35)
	var frame_fill := Color(0.08, 0.11, 0.16, 0.94)
	if _completed:
		accent = Color(0.92, 0.34, 0.30)
		glow = Color(0.88, 0.28, 0.24, 0.42)
		frame_fill = Color(0.14, 0.06, 0.06, 0.96)
	elif _on_board:
		accent = Color(0.98, 0.78, 0.28)
		glow = Color(0.98, 0.72, 0.22, 0.42)
		frame_fill = Color(0.14, 0.11, 0.06, 0.96)
	elif _show_question:
		accent = Color(0.52, 0.58, 0.66)
		glow = Color(0.16, 0.20, 0.26, 0.24)
		frame_fill = Color(0.06, 0.07, 0.10, 0.88)
	elif not _revealed and not _preview_mode:
		accent = Color(0.42, 0.58, 0.72)
		glow = Color(0.16, 0.22, 0.30, 0.28)
		frame_fill = Color(0.06, 0.07, 0.10, 0.88)
	if _selected:
		accent = accent.lightened(0.14)
		glow = glow.lightened(0.08)
	_accent = accent

	if not _pin_mode:
		_glow.add_theme_stylebox_override("panel", _ring_style(glow, accent, 2 if _selected else 1, int((MARKER_SIZE + 10) * 0.5)))
		if _frame:
			_frame.add_theme_stylebox_override("panel", _ring_style(frame_fill, accent, 2 if _selected else 1, int(MARKER_SIZE * 0.5)))
		_name_panel.add_theme_stylebox_override("panel", _pill_style(Color(0.05, 0.07, 0.11, 0.88), accent, 1))
		if _preview:
			_preview.modulate = Color.WHITE if _revealed or _preview_mode else Color(0.62, 0.64, 0.68)
		_lock_overlay.visible = not _revealed and not _preview_mode
		if _completed:
			_badge.text = "★"
			_badge.add_theme_color_override("font_color", Color(1.0, 0.72, 0.68))
		elif _show_question:
			_badge.text = "?"
			_badge.add_theme_color_override("font_color", Color(0.72, 0.76, 0.82))
		elif not _revealed and not _preview_mode:
			_badge.text = "?"
			_badge.add_theme_color_override("font_color", Color(0.62, 0.66, 0.72))
		else:
			_badge.text = _type_icon
			_badge.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
		_name_label.text = _display_name
		_name_label.add_theme_color_override("font_color", accent if _revealed or _preview_mode else Color(0.68, 0.72, 0.78))
	else:
		if _pin_canvas:
			_pin_canvas.queue_redraw()
	var interactive := _on_board or _completed
	if _hit_button:
		_hit_button.disabled = not interactive
		_hit_button.mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	_start_pulse()


func _process(delta: float) -> void:
	if not _pin_mode or _pin_canvas == null or not _pin_canvas.visible:
		return
	_pulse_phase += delta * 3.2
	_pin_canvas.queue_redraw()


func _start_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	if _pin_mode:
		if not _on_board:
			return
		if _pin_canvas:
			set_process(true)
		return
	if not _glow:
		return
	if not _on_board:
		_glow.modulate.a = 0.55
		return
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_glow.modulate.a = 0.72
	_pulse_tween.tween_property(_glow, "modulate:a", 1.0, 0.85).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(_glow, "modulate:a", 0.55, 0.85).set_trans(Tween.TRANS_SINE)


func _ring_style(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = border
	style.shadow_size = 4 if _selected else 2
	style.shadow_offset = Vector2.ZERO
	return style


func _pill_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	return style
