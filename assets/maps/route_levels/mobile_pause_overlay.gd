class_name MobilePauseOverlay
extends Control

signal resumed
signal quit_pressed

var quit_text := "Back to Home"
var show_quit_button := true
var show_pause_button := true

var _paused := false
var _shade: ColorRect
var _panel: PanelContainer
var _pause_button: Button
var _resume_button: Button
var _quit_button: Button
var _bgm_check: CheckButton
var _bgm_slider: HSlider
var _sfx_slider: HSlider


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif _paused and event.is_action_pressed("ui_cancel"):
		close_pause()
		get_viewport().set_input_as_handled()


func configure(options: Dictionary) -> void:
	if options.has("quit_text"):
		quit_text = String(options["quit_text"])
	if options.has("show_quit"):
		show_quit_button = bool(options["show_quit"])
	if options.has("show_pause_button"):
		show_pause_button = bool(options["show_pause_button"])
	if _quit_button:
		_quit_button.text = quit_text
		_quit_button.visible = show_quit_button
	if _pause_button:
		_pause_button.visible = show_pause_button


func is_paused() -> bool:
	return _paused


func open_pause() -> void:
	if _paused:
		return
	_paused = true
	get_tree().paused = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	if _pause_button:
		_pause_button.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_audio_controls()


func force_close() -> void:
	_paused = false
	get_tree().paused = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func close_pause() -> void:
	if not _paused:
		return
	_paused = false
	get_tree().paused = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _pause_button and show_pause_button:
		_pause_button.visible = true
	resumed.emit()


func toggle_pause() -> void:
	if _paused:
		close_pause()
	else:
		open_pause()


func _build_ui() -> void:
	_shade = ColorRect.new()
	_shade.color = Color(0.02, 0.016, 0.012, 0.72)
	_shade.set_anchors_preset(PRESET_FULL_RECT)
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(560, 0)
	_panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(box)

	var title := Label.new()
	title.text = GameLocale.pick("游戏暂停", "Paused")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.96, 0.86, 0.62))
	box.add_child(title)

	var hint := Label.new()
	hint.text = GameLocale.pick("按 Esc 或暂停键继续", "Press Esc or Pause to resume")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.72, 0.66, 0.56))
	box.add_child(hint)

	_bgm_check = CheckButton.new()
	_bgm_check.text = GameLocale.pick("背景音乐 BGM", "Background Music")
	_bgm_check.focus_mode = Control.FOCUS_NONE
	_bgm_check.add_theme_font_size_override("font_size", 20)
	_bgm_check.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78))
	_bgm_check.toggled.connect(_on_bgm_toggled)
	box.add_child(_bgm_check)

	var bgm_row := HBoxContainer.new()
	bgm_row.add_theme_constant_override("separation", 10)
	box.add_child(bgm_row)
	var bgm_lab := Label.new()
	bgm_lab.text = GameLocale.t("settings_bgm_volume")
	bgm_lab.custom_minimum_size = Vector2(120, 0)
	bgm_lab.add_theme_font_size_override("font_size", 18)
	bgm_lab.add_theme_color_override("font_color", Color(0.9, 0.84, 0.7))
	bgm_row.add_child(bgm_lab)
	_bgm_slider = HSlider.new()
	_bgm_slider.min_value = 0.0
	_bgm_slider.max_value = 1.0
	_bgm_slider.step = 0.01
	_bgm_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bgm_slider.custom_minimum_size = Vector2(260, 28)
	_bgm_slider.value_changed.connect(_on_bgm_volume_changed)
	bgm_row.add_child(_bgm_slider)

	var sfx_row := HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 10)
	box.add_child(sfx_row)
	var sfx_lab := Label.new()
	sfx_lab.text = GameLocale.t("settings_sfx_volume")
	sfx_lab.custom_minimum_size = Vector2(120, 0)
	sfx_lab.add_theme_font_size_override("font_size", 18)
	sfx_lab.add_theme_color_override("font_color", Color(0.9, 0.84, 0.7))
	sfx_row.add_child(sfx_lab)
	_sfx_slider = HSlider.new()
	_sfx_slider.min_value = 0.0
	_sfx_slider.max_value = 1.0
	_sfx_slider.step = 0.01
	_sfx_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sfx_slider.custom_minimum_size = Vector2(260, 28)
	_sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_row.add_child(_sfx_slider)

	_resume_button = _make_action_button(GameLocale.pick("继续游戏", "Resume"), Color(0.86, 0.59, 0.27), Color(0.98, 0.82, 0.42))
	_resume_button.pressed.connect(close_pause)
	box.add_child(_resume_button)

	if quit_text == "返回主界面" or quit_text == "Back to Home":
		quit_text = GameLocale.pick("返回主界面", "Back to Home")
	_quit_button = _make_action_button(quit_text, Color(0.68, 0.58, 0.42, 0.98), Color(0.28, 0.20, 0.12, 0.96))
	_quit_button.pressed.connect(_on_quit_pressed)
	_quit_button.visible = show_quit_button
	box.add_child(_quit_button)

	_pause_button = Button.new()
	_pause_button.name = "PauseShortcutButton"
	_pause_button.text = GameLocale.pick("暂停", "Pause")
	_pause_button.custom_minimum_size = Vector2(96, 48)
	_pause_button.focus_mode = Control.FOCUS_NONE
	_pause_button.set_anchors_preset(PRESET_TOP_RIGHT)
	_pause_button.offset_left = -124.0
	_pause_button.offset_top = 112.0
	_pause_button.offset_right = -24.0
	_pause_button.offset_bottom = 160.0
	_pause_button.z_index = 40
	_pause_button.add_theme_font_size_override("font_size", 18)
	_style_button(_pause_button, Color(0.14, 0.11, 0.08, 0.88), Color(0.88, 0.74, 0.48))
	_pause_button.pressed.connect(open_pause)
	add_child(_pause_button)


func _refresh_audio_controls() -> void:
	if _bgm_check != null:
		_bgm_check.set_pressed_no_signal(Global.bgm_enabled)
	if _bgm_slider != null:
		_bgm_slider.set_value_no_signal(Global.bgm_volume)
		_bgm_slider.editable = Global.bgm_enabled
	if _sfx_slider != null:
		_sfx_slider.set_value_no_signal(Global.sfx_volume)


func _on_bgm_toggled(pressed: bool) -> void:
	Global.set_bgm_enabled(pressed)
	if _bgm_slider != null:
		_bgm_slider.editable = pressed


func _on_bgm_volume_changed(value: float) -> void:
	Global.set_bgm_volume(value)


func _on_sfx_volume_changed(value: float) -> void:
	Global.set_sfx_volume(value)


func _on_quit_pressed() -> void:
	_paused = false
	get_tree().paused = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	quit_pressed.emit()


func _make_action_button(text: String, fill: Color, border: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(420, 58)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 22)
	_style_button(button, fill, border)
	return button


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.095, 0.065, 0.96)
	style.border_color = Color(0.37, 0.27, 0.15)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _style_button(button: Button, fill: Color, border: Color) -> void:
	var normal := _button_style(fill, border)
	var hover := _button_style(fill.lightened(0.06), border.lightened(0.06))
	var pressed := _button_style(fill.darkened(0.10), border.darkened(0.06))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", pressed)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_color_override("font_color", Color(0.10, 0.07, 0.04))
	button.add_theme_color_override("font_hover_color", Color(0.10, 0.07, 0.04))
	button.add_theme_color_override("font_pressed_color", Color(0.10, 0.07, 0.04))
