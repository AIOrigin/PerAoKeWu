class_name ComicIntroPlayer
extends Control

signal finished
signal skipped

const OpeningStoryScript = preload("res://assets/maps/route_levels/mobile_home/opening_story.gd")

const FADE_DURATION := 0.42
const KEN_BURNS_DURATION := 9.5
const KEN_BURNS_SCALE_START := 1.02
const KEN_BURNS_SCALE_END := 1.10

var _panels: Array[Dictionary] = []
var _page_index := 0
var _show_title := true
var _allow_skip := true
var _is_transitioning := false

var _stage: Control
var _art_host: Control
var _art_rect: TextureRect
var _caption_label: Label
var _title_block: VBoxContainer
var _title_subtitle: Label
var _title_main: Label
var _title_tap_hint: Label
var _begin_center_btn: Button
var _bottom_bar: Control
var _page_dots: HBoxContainer
var _skip_btn: Button
var _next_btn: Button
var _fade_rect: ColorRect
var _tap_left: Control
var _tap_right: Control
var _ken_burns_tween: Tween
var _auto_tween: Tween


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	if _panels.is_empty():
		_panels = OpeningStoryScript.get_panels()
	_show_title_card()


func configure(options: Dictionary = {}) -> ComicIntroPlayer:
	if options.has("panels"):
		_panels = options["panels"]
	_show_title = bool(options.get("show_title", true))
	_allow_skip = bool(options.get("allow_skip", true))
	return self


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.015, 0.03, 1.0)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(bg)

	_stage = Control.new()
	_stage.set_anchors_preset(PRESET_FULL_RECT)
	_stage.clip_contents = true
	add_child(_stage)

	_art_host = Control.new()
	_art_host.set_anchors_preset(PRESET_FULL_RECT)
	_art_host.mouse_filter = MOUSE_FILTER_IGNORE
	_stage.add_child(_art_host)

	_art_rect = TextureRect.new()
	_art_rect.set_anchors_preset(PRESET_FULL_RECT)
	_art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_art_rect.mouse_filter = MOUSE_FILTER_IGNORE
	_art_host.add_child(_art_rect)

	var vignette := TextureRect.new()
	vignette.set_anchors_preset(PRESET_FULL_RECT)
	vignette.mouse_filter = MOUSE_FILTER_IGNORE
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.0, 0.0, 0.0, 0.55),
		Color(0.0, 0.0, 0.0, 0.0),
		Color(0.0, 0.0, 0.0, 0.0),
		Color(0.0, 0.0, 0.0, 0.72),
	])
	grad.offsets = PackedFloat32Array([0.0, 0.12, 0.72, 1.0])
	var grad_tex := GradientTexture2D.new()
	grad_tex.gradient = grad
	grad_tex.fill_from = Vector2(0.5, 0.0)
	grad_tex.fill_to = Vector2(0.5, 1.0)
	vignette.texture = grad_tex
	_stage.add_child(vignette)

	_caption_label = Label.new()
	_caption_label.set_anchors_preset(PRESET_CENTER)
	_caption_label.anchor_left = 0.5
	_caption_label.anchor_top = 0.5
	_caption_label.anchor_right = 0.5
	_caption_label.anchor_bottom = 0.5
	_caption_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_caption_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	_caption_label.offset_left = -340.0
	_caption_label.offset_right = 340.0
	_caption_label.offset_top = -120.0
	_caption_label.offset_bottom = 120.0
	_caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption_label.add_theme_font_size_override("font_size", 32)
	_caption_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	_caption_label.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.08, 0.96))
	_caption_label.add_theme_constant_override("outline_size", 6)
	_caption_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_caption_label.visible = false
	_stage.add_child(_caption_label)

	_title_block = VBoxContainer.new()
	_title_block.set_anchors_preset(PRESET_CENTER)
	_title_block.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_title_block.grow_vertical = Control.GROW_DIRECTION_BOTH
	_title_block.offset_left = -420.0
	_title_block.offset_right = 420.0
	_title_block.offset_top = -280.0
	_title_block.offset_bottom = 280.0
	_title_block.alignment = BoxContainer.ALIGNMENT_CENTER
	_title_block.add_theme_constant_override("separation", 22)
	_stage.add_child(_title_block)

	_title_subtitle = Label.new()
	_title_subtitle.text = OpeningStoryScript.title_subtitle()
	_title_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_subtitle.add_theme_font_size_override("font_size", 28)
	_title_subtitle.add_theme_color_override("font_color", Color(0.78, 0.84, 0.94))
	_title_subtitle.add_theme_constant_override("letter_spacing", 4)
	_title_block.add_child(_title_subtitle)

	_title_main = Label.new()
	_title_main.text = OpeningStoryScript.title_text()
	_title_main.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_main.autowrap_mode = TextServer.AUTOWRAP_OFF
	_title_main.add_theme_font_size_override("font_size", 56)
	_title_main.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	_title_main.add_theme_color_override("font_outline_color", Color(0.05, 0.08, 0.14, 0.9))
	_title_main.add_theme_constant_override("outline_size", 4)
	_title_main.add_theme_constant_override("line_spacing", 8)
	_title_block.add_child(_title_main)

	_title_tap_hint = Label.new()
	_title_tap_hint.text = "Tap Begin to start"
	_title_tap_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_tap_hint.add_theme_font_size_override("font_size", 18)
	_title_tap_hint.add_theme_color_override("font_color", Color(0.62, 0.70, 0.80))
	_title_block.add_child(_title_tap_hint)

	_begin_center_btn = _make_begin_center_button("Begin")
	_begin_center_btn.pressed.connect(_on_next_pressed)
	_title_block.add_child(_begin_center_btn)

	_bottom_bar = Control.new()
	_bottom_bar.set_anchors_preset(PRESET_BOTTOM_WIDE)
	_bottom_bar.offset_top = -120.0
	_bottom_bar.mouse_filter = MOUSE_FILTER_STOP

	var bar_shade := ColorRect.new()
	bar_shade.set_anchors_preset(PRESET_FULL_RECT)
	bar_shade.color = Color(0.01, 0.02, 0.04, 0.55)
	bar_shade.mouse_filter = MOUSE_FILTER_IGNORE
	_bottom_bar.add_child(bar_shade)

	var bar_margin := MarginContainer.new()
	bar_margin.set_anchors_preset(PRESET_FULL_RECT)
	bar_margin.add_theme_constant_override("margin_left", 28)
	bar_margin.add_theme_constant_override("margin_right", 28)
	bar_margin.add_theme_constant_override("margin_top", 16)
	bar_margin.add_theme_constant_override("margin_bottom", 24)
	_bottom_bar.add_child(bar_margin)

	var bar_row := HBoxContainer.new()
	bar_row.set_anchors_preset(PRESET_FULL_RECT)
	bar_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bar_margin.add_child(bar_row)

	_skip_btn = _make_bar_button("Skip")
	_skip_btn.pressed.connect(_on_skip_pressed)
	bar_row.add_child(_skip_btn)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_row.add_child(spacer)

	_page_dots = HBoxContainer.new()
	_page_dots.add_theme_constant_override("separation", 8)
	_page_dots.alignment = BoxContainer.ALIGNMENT_CENTER
	bar_row.add_child(_page_dots)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_row.add_child(spacer2)

	_next_btn = _make_bar_button("Next")
	_next_btn.pressed.connect(_on_next_pressed)
	bar_row.add_child(_next_btn)

	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(PRESET_FULL_RECT)
	_fade_rect.color = Color(0.01, 0.015, 0.03, 0.0)
	_fade_rect.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

	_tap_left = Control.new()
	_tap_left.name = "TapLeft"
	_tap_left.set_anchors_preset(PRESET_FULL_RECT)
	_tap_left.anchor_right = 0.34
	_tap_left.anchor_bottom = 0.88
	_tap_left.mouse_filter = MOUSE_FILTER_STOP
	_tap_left.gui_input.connect(_on_tap_left)
	add_child(_tap_left)

	_tap_right = Control.new()
	_tap_right.name = "TapRight"
	_tap_right.set_anchors_preset(PRESET_FULL_RECT)
	_tap_right.anchor_left = 0.34
	_tap_right.anchor_bottom = 0.88
	_tap_right.mouse_filter = MOUSE_FILTER_STOP
	_tap_right.gui_input.connect(_on_tap_right)
	add_child(_tap_right)

	add_child(_bottom_bar)


func _make_begin_center_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(280, 64)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 28)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.22, 0.55, 0.82, 0.92)
	normal.border_color = Color(0.72, 0.92, 1.0, 0.95)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(14)
	normal.content_margin_left = 28
	normal.content_margin_right = 28
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	var hover := normal.duplicate()
	hover.bg_color = Color(0.28, 0.62, 0.90, 0.96)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0))
	return btn


func _make_bar_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(120, 44)
	btn.add_theme_font_size_override("font_size", 18)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.04, 0.08, 0.14, 0.88)
	normal.border_color = Color(0.45, 0.72, 0.92, 0.65)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("pressed", normal)
	btn.add_theme_color_override("font_color", Color(0.88, 0.94, 1.0))
	return btn


func _show_title_card() -> void:
	_show_title = _show_title and _panels.size() > 0
	_title_block.visible = _show_title
	_caption_label.visible = false
	_art_rect.texture = null
	_art_host.scale = Vector2.ONE
	_art_host.position = Vector2.ZERO
	_page_dots.visible = false
	# 标题页：Begin 在中间文字下；底栏只留 Skip；关掉左右点击层以免挡按钮
	if _begin_center_btn:
		_begin_center_btn.visible = _show_title
	if _title_tap_hint:
		_title_tap_hint.visible = _show_title
	_set_side_taps_enabled(not _show_title)
	_bottom_bar.visible = _allow_skip
	_skip_btn.visible = _allow_skip
	_next_btn.visible = false
	if not _show_title and not _panels.is_empty():
		_show_panel(0)


func _show_panel(index: int) -> void:
	if index < 0 or index >= _panels.size():
		return
	_page_index = index
	_title_block.visible = false
	if _begin_center_btn:
		_begin_center_btn.visible = false
	_set_side_taps_enabled(true)
	_bottom_bar.visible = true
	_skip_btn.visible = _allow_skip
	_next_btn.visible = true
	_page_dots.visible = true
	_rebuild_page_dots()

	var panel: Dictionary = _panels[index]
	var tex: Texture2D = panel.get("texture") as Texture2D
	if tex == null:
		var path := String(panel.get("image_path", ""))
		if path != "":
			tex = load(path) as Texture2D
	if tex != null:
		_art_rect.texture = tex
		_art_rect.modulate = Color.WHITE
	else:
		_art_rect.texture = null
		_art_rect.modulate = Color(0.08, 0.10, 0.16)

	_caption_label.text = String(panel.get("caption", ""))
	if _art_rect.texture == null and _caption_label.text != "":
		_caption_label.text += "\n\n(Image missing — add PNG to story_intro/)"
	_caption_label.visible = _caption_label.text != ""
	_update_next_button_label()
	_start_ken_burns()


func _rebuild_page_dots() -> void:
	for child in _page_dots.get_children():
		child.queue_free()
	for i in _panels.size():
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(10, 10)
		dot.color = Color(0.55, 0.82, 0.96, 0.95) if i == _page_index else Color(0.35, 0.42, 0.52, 0.75)
		_page_dots.add_child(dot)


func _set_side_taps_enabled(enabled: bool) -> void:
	var filter := MOUSE_FILTER_STOP if enabled else MOUSE_FILTER_IGNORE
	if _tap_left:
		_tap_left.mouse_filter = filter
	if _tap_right:
		_tap_right.mouse_filter = filter


func _update_next_button_label() -> void:
	if _page_index >= _panels.size() - 1:
		_next_btn.text = "Continue"
	else:
		_next_btn.text = "Next"


func _start_ken_burns() -> void:
	if _ken_burns_tween != null and _ken_burns_tween.is_valid():
		_ken_burns_tween.kill()
	_art_host.scale = Vector2.ONE * KEN_BURNS_SCALE_START
	_art_host.pivot_offset = _art_host.size * 0.5
	_art_host.position = Vector2.ZERO
	_ken_burns_tween = create_tween()
	_ken_burns_tween.set_trans(Tween.TRANS_SINE)
	_ken_burns_tween.set_ease(Tween.EASE_IN_OUT)
	_ken_burns_tween.tween_property(_art_host, "scale", Vector2.ONE * KEN_BURNS_SCALE_END, KEN_BURNS_DURATION)


func _on_next_pressed() -> void:
	if _is_transitioning:
		return
	if _show_title:
		_begin_panels()
		return
	if _page_index >= _panels.size() - 1:
		finished.emit()
		return
	_transition_to(_page_index + 1)


func _on_skip_pressed() -> void:
	if not _allow_skip or _is_transitioning:
		return
	skipped.emit()
	finished.emit()


func _begin_panels() -> void:
	_show_title = false
	_transition_to(0)


func _transition_to(next_index: int) -> void:
	if next_index < 0 or next_index >= _panels.size():
		return
	_is_transitioning = true
	if _ken_burns_tween != null and _ken_burns_tween.is_valid():
		_ken_burns_tween.kill()
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, FADE_DURATION * 0.5)
	tween.tween_callback(func() -> void:
		_show_panel(next_index)
	)
	tween.tween_property(_fade_rect, "color:a", 0.0, FADE_DURATION * 0.5)
	tween.tween_callback(func() -> void:
		_is_transitioning = false
	)


func _go_previous() -> void:
	if _is_transitioning:
		return
	if _show_title:
		return
	if _page_index <= 0:
		return
	_transition_to(_page_index - 1)


func _on_tap_left(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_go_previous()


func _on_tap_right(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_next_pressed()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		set_anchors_preset(PRESET_FULL_RECT)
		offset_right = 0.0
		offset_bottom = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		_on_next_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") and _allow_skip:
		_on_skip_pressed()
		get_viewport().set_input_as_handled()
