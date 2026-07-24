class_name MapLocationMarker
extends Control

signal activated

const MARKER_SIZE := 58.0
const LABEL_WIDTH := 108.0

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
var _hit_button: Button
var _revealed := true
var _completed := false
var _selected := false
var _ui_built := false


func _ready() -> void:
	custom_minimum_size = Vector2(MARKER_SIZE, MARKER_SIZE + 26.0)
	size = custom_minimum_size
	mouse_filter = MOUSE_FILTER_STOP
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


func apply_state(revealed: bool, completed: bool, selected: bool) -> void:
	_revealed = revealed
	_completed = completed
	_selected = selected
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


func _build_ui() -> void:
	if _ui_built:
		return

	_glow = PanelContainer.new()
	_glow.position = Vector2(-5, -5)
	_glow.custom_minimum_size = Vector2(MARKER_SIZE + 10, MARKER_SIZE + 10)
	_glow.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_glow)

	_frame = PanelContainer.new()
	_frame.custom_minimum_size = Vector2(MARKER_SIZE, MARKER_SIZE)
	_frame.clip_contents = true
	_frame.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_frame)

	_preview = TextureRect.new()
	_preview.set_anchors_preset(PRESET_FULL_RECT)
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_preview.mouse_filter = MOUSE_FILTER_IGNORE
	_frame.add_child(_preview)

	_lock_overlay = ColorRect.new()
	_lock_overlay.set_anchors_preset(PRESET_FULL_RECT)
	_lock_overlay.color = Color(0.04, 0.06, 0.10, 0.62)
	_lock_overlay.mouse_filter = MOUSE_FILTER_IGNORE
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
	_badge.mouse_filter = MOUSE_FILTER_IGNORE
	_frame.add_child(_badge)

	_name_panel = PanelContainer.new()
	_name_panel.position = Vector2((MARKER_SIZE - LABEL_WIDTH) * 0.5, MARKER_SIZE + 4)
	_name_panel.custom_minimum_size = Vector2(LABEL_WIDTH, 22)
	_name_panel.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_name_panel)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.set_anchors_preset(PRESET_FULL_RECT)
	_name_label.add_theme_font_size_override("font_size", 11)
	_name_label.add_theme_color_override("font_color", Color(0.90, 0.94, 0.98))
	_name_label.mouse_filter = MOUSE_FILTER_IGNORE
	_name_panel.add_child(_name_label)

	# 全覆盖透明按钮，保证点击可靠（子控件不再吞事件）
	_hit_button = Button.new()
	_hit_button.focus_mode = Control.FOCUS_NONE
	_hit_button.flat = true
	_hit_button.set_anchors_preset(PRESET_FULL_RECT)
	_hit_button.mouse_filter = MOUSE_FILTER_STOP
	_hit_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_hit_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_hit_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_hit_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_hit_button.pressed.connect(func(): activated.emit())
	add_child(_hit_button)

	_ui_built = true


func _refresh_visuals() -> void:
	if not _ui_built:
		return
	var accent := Color(0.38, 0.72, 0.96)
	var glow := Color(0.22, 0.46, 0.72, 0.35)
	var frame_fill := Color(0.08, 0.11, 0.16, 0.94)
	if _completed:
		accent = Color(0.98, 0.78, 0.28)
		glow = Color(0.98, 0.72, 0.22, 0.42)
		frame_fill = Color(0.14, 0.11, 0.06, 0.96)
	elif not _revealed:
		accent = Color(0.48, 0.52, 0.58)
		glow = Color(0.18, 0.20, 0.24, 0.28)
		frame_fill = Color(0.06, 0.07, 0.10, 0.88)
	if _selected:
		accent = accent.lightened(0.12)
		glow = glow.lightened(0.08)
		glow.a = min(glow.a + 0.18, 0.72)

	_glow.add_theme_stylebox_override("panel", _ring_style(glow, accent, 2, int((MARKER_SIZE + 10) * 0.5)))
	_frame.add_theme_stylebox_override("panel", _ring_style(frame_fill, accent, 2 if _selected else 1, int(MARKER_SIZE * 0.5)))
	_name_panel.add_theme_stylebox_override("panel", _pill_style(Color(0.05, 0.07, 0.11, 0.88), accent, 1))
	_preview.modulate = Color.WHITE if _revealed else Color(0.62, 0.64, 0.68)
	_lock_overlay.visible = not _revealed
	_badge.text = "★" if _completed else _type_icon
	if _completed:
		_badge.add_theme_color_override("font_color", Color(0.98, 0.84, 0.36))
	elif not _revealed:
		_badge.text = "?"
		_badge.add_theme_color_override("font_color", Color(0.72, 0.76, 0.82))
	else:
		_badge.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	_name_label.text = _display_name
	_name_label.add_theme_color_override("font_color", accent if _revealed else Color(0.68, 0.72, 0.78))


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
