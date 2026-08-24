class_name CapybaraUi
extends RefCounted

## 选角 / 关卡 / 结算 / 局内 HUD（卡通手机风）

const LevelCatalogScript := preload("res://assets/maps/route_levels/capybara_rush/level_catalog.gd")
const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")
const CapybaraLevelCatalog = LevelCatalogScript
const UI_FONT := preload("res://assets/arts_graphic/font/LiberationMono-Regular-变体.tres")

const RUN_SPEED := 12.0
const CHAR_CAPYBARA := "capybara"
const CHAR_LITTLE_MONSTER := "little_monster"
const CHAR_LITTLE_RABBIT := "little_rabbit"
const CHAR_SHIBA := "shiba"
const CHAR_BIRD := "bird"
const CHAR_MOUSE := "mouse"
const CHAR_SLOTH := "sloth"
const CHAR_TINY_PLANET := "tiny_planet"
const CHAR_BEAR := "bear"
const CHAR_COW := "cow"

const COL_INK := Color(0.34, 0.20, 0.42)
const COL_MUTED := Color(0.58, 0.44, 0.60)
const COL_CREAM := Color(1.0, 0.975, 0.985)
const COL_PINK := Color(1.0, 0.55, 0.68)
const COL_PINK_DEEP := Color(0.92, 0.42, 0.58)
const COL_SKY := Color(0.48, 0.74, 0.96)
const COL_GOLD := Color(1.0, 0.78, 0.30)
const COL_MINT := Color(0.42, 0.84, 0.70)

const UI_DIR := "res://assets/maps/route_levels/capybara_rush/ui/"
const ICON_COIN := UI_DIR + "icon_coin.png"
const ICON_STACK := UI_DIR + "icon_stack.png"
const ICON_PAUSE := UI_DIR + "icon_pause.png"
const ICON_JUMP := UI_DIR + "icon_jump.png"
const ICON_LEFT := UI_DIR + "icon_left.png"
const ICON_RIGHT := UI_DIR + "icon_right.png"
const ICON_STAR := UI_DIR + "icon_star.png"
const ICON_LOCK := UI_DIR + "icon_lock.png"
const ICON_PLAY := UI_DIR + "icon_play.png"

static var pending_level_id := 0
static var pending_character_id := ""
static var pending_custom_level_id := ""
static var pending_open_level_select := false
static var editor_return_scene := ""

var select_ui: CanvasLayer
var mode_ui: CanvasLayer
var result_ui: CanvasLayer
var level_ui: CanvasLayer
var pause_ui: CanvasLayer
var _cdn_loading_ui: CanvasLayer
var hud_layer: CanvasLayer
var select_spin_pivots: Array[Node3D] = []
var _host: Node
var _paused := false
var _steer_left := false
var _steer_right := false
var _hud_coin_label: Label
var _hud_stack_label: Label
var _hud_progress: ProgressBar
var _hud_progress_text: Label
var _hud_controls: Control
var _start_overlay: Control
var _start_pulse: Tween
var _pause_btn: BaseButton
var _tex_cache: Dictionary = {}
var _ui_theme: Theme


func _init(host: Node) -> void:
	_host = host
	_install_ui_font()


func _install_ui_font() -> void:
	if UI_FONT == null:
		return
	ThemeDB.fallback_font = UI_FONT
	_ui_theme = Theme.new()
	_ui_theme.default_font = UI_FONT


func _bind_font(ctrl: Control) -> void:
	if UI_FONT == null:
		return
	ctrl.add_theme_font_override("font", UI_FONT)
	if _ui_theme != null:
		ctrl.theme = _ui_theme


func is_select_active() -> bool:
	return select_ui != null


func is_menu_blocking() -> bool:
	return mode_ui != null or select_ui != null or level_ui != null or pause_ui != null or _cdn_loading_ui != null


func is_result_active() -> bool:
	return result_ui != null


func is_paused() -> bool:
	return _paused


func steer_dir() -> float:
	var dir := 0.0
	if _steer_left:
		dir += 1.0
	if _steer_right:
		dir -= 1.0
	return dir


func dismiss_character_select() -> void:
	select_spin_pivots.clear()
	if select_ui:
		select_ui.queue_free()
		select_ui = null


func dismiss_mode_select() -> void:
	if mode_ui:
		mode_ui.queue_free()
		mode_ui = null


func dismiss_level_select() -> void:
	if level_ui:
		level_ui.queue_free()
		level_ui = null


func dismiss_pause() -> void:
	_paused = false
	_steer_left = false
	_steer_right = false
	if pause_ui:
		pause_ui.queue_free()
		pause_ui = null
	if _pause_btn:
		_pause_btn.visible = true


func setup_hud() -> void:
	_setup_hud()


func setup_character_select() -> void:
	_setup_character_select()


func setup_level_select() -> void:
	_setup_level_select()


func spin_select_previews(delta: float) -> void:
	_spin_select_previews(delta)


func show_result_screen() -> void:
	_show_result_screen()


func show_fail_screen(reason: String) -> void:
	_show_fail_screen(reason)


func reload_same_level() -> void:
	_reload_same_level()


func reload_next_level() -> void:
	_reload_next_level()


func show_ready_chrome() -> void:
	_set_hud_layer_visible(true)
	_set_controls_visible(false)
	_show_start_overlay()
	update_play_hud()


func show_playing_chrome() -> void:
	_set_hud_layer_visible(true)
	_hide_start_overlay()
	_set_controls_visible(true)
	update_play_hud()


func hide_play_chrome() -> void:
	_hide_start_overlay()
	_set_controls_visible(false)
	if _host._hud_label:
		_host._hud_label.visible = false
	if _host._hud_tip:
		_host._hud_tip.visible = false
	if _pause_btn:
		_pause_btn.visible = false


func show_ceremony_chrome() -> void:
	_hide_start_overlay()
	_set_controls_visible(false)
	_set_hud_layer_visible(true)
	if _pause_btn:
		_pause_btn.visible = false
	if _host._hud_tip:
		_host._hud_tip.visible = true
	if _host._hud_label:
		_host._hud_label.visible = true


func update_play_hud() -> void:
	if _host._hud_label == null:
		return
	var track_len: float = _host._track_len()
	var pct := int((_host._progress / maxf(track_len, 1.0)) * 100.0)
	pct = clampi(pct, 0, 100)
	if _hud_coin_label:
		_hud_coin_label.text = str(int(_host._coin_score))
	if _hud_stack_label:
		_hud_stack_label.text = str(_host._stack.size())
	if _hud_progress:
		_hud_progress.value = pct
	if _hud_progress_text:
		_hud_progress_text.text = "%d%%" % pct
	if _host._waiting_to_start:
		_host._hud_label.text = "Lv.%d  %s" % [_host._level_id, String(_host._level_cfg.get("name", ""))]
	elif _host._finished:
		pass
	else:
		_host._hud_label.text = "Lv.%d  %s" % [_host._level_id, String(_host._level_cfg.get("name", ""))]


func toggle_pause() -> void:
	if _paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	if _paused or result_ui != null or select_ui != null or level_ui != null:
		return
	if not _host._playing and not _host._waiting_to_start:
		return
	_paused = true
	_steer_left = false
	_steer_right = false
	_hide_start_overlay()
	if _pause_btn:
		_pause_btn.visible = false
	_show_pause_menu()


func resume_game() -> void:
	dismiss_pause()
	if _host._waiting_to_start:
		show_ready_chrome()
	elif _host._playing and not _host._finished:
		show_playing_chrome()


func request_character_select() -> void:
	CapybaraUi.pending_level_id = 0
	CapybaraUi.pending_character_id = ""
	CapybaraUi.pending_custom_level_id = ""
	CapybaraUi.pending_open_level_select = false
	_host.reload_game_scene()


func request_level_select() -> void:
	CapybaraUi.pending_level_id = 0
	CapybaraUi.pending_character_id = _host._character_id
	CapybaraUi.pending_open_level_select = true
	_host.reload_game_scene()


func _setup_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 18
	_host.add_child(hud_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _ui_theme != null:
		root.theme = _ui_theme
	hud_layer.add_child(root)

	var top := MarginContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 118
	top.add_theme_constant_override("margin_left", 16)
	top.add_theme_constant_override("margin_right", 16)
	top.add_theme_constant_override("margin_top", 18)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(top_row)

	var coin_chip := _make_stat_chip(ICON_COIN)
	_hud_coin_label = coin_chip["label"]
	top_row.add_child(coin_chip["root"])

	var stack_chip := _make_stat_chip(ICON_STACK)
	_hud_stack_label = stack_chip["label"]
	top_row.add_child(stack_chip["root"])

	var prog_wrap := Control.new()
	prog_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prog_wrap.custom_minimum_size = Vector2(160, 56)
	prog_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_row.add_child(prog_wrap)

	var prog_panel := PanelContainer.new()
	prog_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prog_panel.add_theme_stylebox_override("panel", _cartoon_panel_style(COL_CREAM, Color(1.0, 0.78, 0.86), 22.0, 3.0, 8))
	prog_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prog_wrap.add_child(prog_panel)

	var prog_inner := VBoxContainer.new()
	prog_inner.add_theme_constant_override("separation", 2)
	prog_panel.add_child(prog_inner)

	_host._hud_label = Label.new()
	_host._hud_label.text = "Capy Rush"
	_host._hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_host._hud_label.add_theme_font_size_override("font_size", 14)
	_host._hud_label.add_theme_color_override("font_color", COL_MUTED)
	prog_inner.add_child(_host._hud_label)

	var bar_row := Control.new()
	bar_row.custom_minimum_size = Vector2(0, 22)
	bar_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prog_inner.add_child(bar_row)

	_hud_progress = ProgressBar.new()
	_hud_progress.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud_progress.min_value = 0
	_hud_progress.max_value = 100
	_hud_progress.value = 0
	_hud_progress.show_percentage = false
	_hud_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar_bg := _cartoon_panel_style(Color(1.0, 0.90, 0.93), Color(1.0, 0.80, 0.88), 12.0, 0.0, 0)
	bar_bg.shadow_size = 0
	var bar_fill := _cartoon_panel_style(COL_PINK, Color(1.0, 0.78, 0.88), 12.0, 0.0, 0)
	bar_fill.shadow_size = 0
	_hud_progress.add_theme_stylebox_override("background", bar_bg)
	_hud_progress.add_theme_stylebox_override("fill", bar_fill)
	bar_row.add_child(_hud_progress)

	_hud_progress_text = Label.new()
	_hud_progress_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hud_progress_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_progress_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hud_progress_text.add_theme_font_size_override("font_size", 13)
	_hud_progress_text.add_theme_color_override("font_color", Color(1, 1, 1))
	_hud_progress_text.add_theme_color_override("font_outline_color", COL_PINK_DEEP)
	_hud_progress_text.add_theme_constant_override("outline_size", 3)
	_hud_progress_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar_row.add_child(_hud_progress_text)

	_pause_btn = _make_icon_button(ICON_PAUSE, Vector2(56, 56), func() -> void: toggle_pause())
	top_row.add_child(_pause_btn)

	_host._hud_tip = Label.new()
	_host._hud_tip.text = ""
	_host._hud_tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_host._hud_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_host._hud_tip.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_host._hud_tip.offset_left = -280
	_host._hud_tip.offset_right = 280
	_host._hud_tip.offset_top = -168
	_host._hud_tip.offset_bottom = -118
	_host._hud_tip.add_theme_font_size_override("font_size", 18)
	_host._hud_tip.add_theme_color_override("font_color", COL_INK)
	_host._hud_tip.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.92))
	_host._hud_tip.add_theme_constant_override("outline_size", 6)
	_host._hud_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_host._hud_tip)

	_hud_controls = Control.new()
	_hud_controls.set_anchors_preset(Control.PRESET_FULL_RECT)
	_hud_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_controls.visible = false
	root.add_child(_hud_controls)

	var left_btn := _make_icon_button(ICON_LEFT, Vector2(86, 86))
	left_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left_btn.offset_left = 22
	left_btn.offset_top = -118
	left_btn.offset_right = 108
	left_btn.offset_bottom = -32
	left_btn.button_down.connect(func() -> void: _steer_left = true)
	left_btn.button_up.connect(func() -> void: _steer_left = false)
	_hud_controls.add_child(left_btn)

	var right_btn := _make_icon_button(ICON_RIGHT, Vector2(86, 86))
	right_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	right_btn.offset_left = 118
	right_btn.offset_top = -118
	right_btn.offset_right = 204
	right_btn.offset_bottom = -32
	right_btn.button_down.connect(func() -> void: _steer_right = true)
	right_btn.button_up.connect(func() -> void: _steer_right = false)
	_hud_controls.add_child(right_btn)

	var jump_btn := _make_icon_button(ICON_JUMP, Vector2(108, 108), func() -> void:
		if _paused or _host._waiting_to_start or not _host._playing or _host._finished:
			return
		_host._world_sys.try_jump()
	)
	jump_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	jump_btn.offset_left = -136
	jump_btn.offset_top = -148
	jump_btn.offset_right = -28
	jump_btn.offset_bottom = -40
	_hud_controls.add_child(jump_btn)

	_set_hud_layer_visible(false)


func _show_start_overlay() -> void:
	_hide_start_overlay()
	if hud_layer == null:
		return
	_start_overlay = Control.new()
	_start_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_start_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	hud_layer.add_child(_start_overlay)

	var tap := Button.new()
	tap.flat = true
	tap.set_anchors_preset(Control.PRESET_FULL_RECT)
	tap.pressed.connect(func() -> void:
		if _host._waiting_to_start:
			_host._begin_gameplay()
	)
	_start_overlay.add_child(tap)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	card.offset_left = -210
	card.offset_right = 210
	card.offset_top = -210
	card.offset_bottom = -118
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", _cartoon_panel_style(COL_CREAM, COL_PINK, 28.0, 5.0))
	_start_overlay.add_child(card)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 6)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)

	var play_icon := TextureRect.new()
	play_icon.texture = _tex(ICON_PLAY)
	play_icon.custom_minimum_size = Vector2(52, 52)
	play_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	play_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	play_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(play_icon)

	var title := Label.new()
	title.text = "Tap to Start"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", COL_INK)
	v.add_child(title)

	var sub := Label.new()
	sub.text = "Swipe lanes · Jump obstacles · Stack higher"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", COL_MUTED)
	v.add_child(sub)

	card.pivot_offset = Vector2(210, 46)
	# 必须绑在卡片上：挂在 _host 上的 set_loops tween 会在 overlay 释放后空转刷屏并把网页打崩
	_start_pulse = card.create_tween()
	_start_pulse.set_loops()
	_start_pulse.set_trans(Tween.TRANS_SINE)
	_start_pulse.tween_property(card, "scale", Vector2(1.04, 1.04), 0.7)
	_start_pulse.tween_property(card, "scale", Vector2.ONE, 0.7)


func _hide_start_overlay() -> void:
	if _start_pulse != null:
		_start_pulse.kill()
		_start_pulse = null
	if _start_overlay:
		_start_overlay.queue_free()
		_start_overlay = null


func _show_pause_menu() -> void:
	if pause_ui != null:
		pause_ui.queue_free()
	pause_ui = CanvasLayer.new()
	pause_ui.layer = 40
	_host.add_child(pause_ui)

	var dim := ColorRect.new()
	dim.color = Color(0.42, 0.28, 0.46, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			resume_game()
	)
	pause_ui.add_child(dim)

	var card := _make_dialog_card(Vector2(280, 250), Color(1.0, 0.97, 0.98), COL_PINK)
	pause_ui.add_child(card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	card.get_child(0).add_child(v)

	var title := Label.new()
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", COL_INK)
	v.add_child(title)

	v.add_child(_make_text_button("Resume", COL_PINK, func() -> void: resume_game()))
	v.add_child(_make_text_button("Restart", COL_SKY, func() -> void: reload_same_level()))
	v.add_child(_make_text_button("Levels", Color(0.95, 0.72, 0.45), func() -> void: request_level_select()))
	v.add_child(_make_text_button("Characters", Color(0.78, 0.62, 0.92), func() -> void: request_character_select()))
	_pop_in(card, Vector2(280, 250))


func show_cdn_loading(text: String = "Downloading level assets…\nFirst time may take ~1 min. Keep this page open.") -> void:
	hide_cdn_loading()
	_cdn_loading_ui = CanvasLayer.new()
	_cdn_loading_ui.layer = 120
	_host.add_child(_cdn_loading_ui)
	var dim := ColorRect.new()
	dim.color = Color(0.55, 0.62, 0.88, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cdn_loading_ui.add_child(dim)
	var card := _make_dialog_card(Vector2(240, 150), COL_CREAM, COL_PINK)
	_cdn_loading_ui.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	card.get_child(0).add_child(v)
	var icon := TextureRect.new()
	icon.texture = _tex(ICON_STACK)
	icon.custom_minimum_size = Vector2(72, 72)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	v.add_child(icon)
	var label := Label.new()
	label.name = "CdnLoadingLabel"
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", COL_INK)
	_bind_font(label)
	v.add_child(label)


func update_cdn_loading(done: int, total: int, _path: String) -> void:
	if _cdn_loading_ui == null:
		return
	var label: Label = _cdn_loading_ui.find_child("CdnLoadingLabel", true, false) as Label
	if label == null:
		return
	if total <= 0:
		label.text = "Downloading level assets…\nFirst time may take ~1 min. Keep this page open."
	else:
		label.text = "Downloading level assets… %d / %d\nKeep this page open" % [done, total]


func on_cdn_preload_progress(done: int, total: int, path: String) -> void:
	update_cdn_loading(done, total, path)


func hide_cdn_loading() -> void:
	if _cdn_loading_ui:
		_cdn_loading_ui.queue_free()
		_cdn_loading_ui = null


func _show_fail_screen(reason: String) -> void:
	if result_ui != null:
		return
	hide_play_chrome()
	result_ui = CanvasLayer.new()
	result_ui.layer = 30
	_host.add_child(result_ui)
	_add_menu_wash(result_ui, Color(0.42, 0.28, 0.40, 0.58), Color(0.92, 0.55, 0.62, 0.22))

	var card := _make_dialog_card(Vector2(250, 220), COL_CREAM, COL_PINK)
	result_ui.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	card.get_child(0).add_child(v)

	var badge := Label.new()
	badge.text = "So Close!"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", COL_PINK_DEEP)
	v.add_child(badge)

	var title := Label.new()
	title.text = reason
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", COL_INK)
	v.add_child(title)

	v.add_child(_result_stat_chip("Progress", "%d%%" % int((_host._progress / maxf(_host._track_len(), 1.0)) * 100.0), Color(1.0, 0.93, 0.88)))
	v.add_child(_result_stat_chip("Hits", "%d" % _host._collision_count, Color(1.0, 0.93, 0.88)))

	var tip := Label.new()
	tip.text = "Hitting an obstacle with only one left ends the run"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 15)
	tip.add_theme_color_override("font_color", COL_MUTED)
	v.add_child(tip)

	v.add_child(_make_text_button("Try Again", COL_PINK, func() -> void: reload_same_level()))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	row.add_child(_make_text_button("Levels", COL_SKY, func() -> void: request_level_select(), Vector2(140, 48)))
	row.add_child(_make_text_button("Characters", Color(0.78, 0.62, 0.92), func() -> void: request_character_select(), Vector2(140, 48)))
	_pop_in(card, Vector2(250, 220))


func _setup_character_select() -> void:
	select_spin_pivots.clear()
	select_ui = CanvasLayer.new()
	select_ui.layer = 20
	_host.add_child(select_ui)
	_set_hud_layer_visible(false)
	_add_menu_wash(select_ui, Color(0.70, 0.80, 0.96, 0.94), Color(1.0, 0.78, 0.86, 0.28))

	var header := VBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_CENTER_TOP)
	header.offset_left = -280
	header.offset_right = 280
	header.offset_top = 28
	header.offset_bottom = 128
	header.add_theme_constant_override("separation", 2)
	select_ui.add_child(header)

	var game_title := Label.new()
	game_title.text = "Capy Rush"
	game_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_title.add_theme_font_size_override("font_size", 42)
	game_title.add_theme_color_override("font_color", COL_INK)
	game_title.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	game_title.add_theme_constant_override("outline_size", 8)
	_bind_font(game_title)
	header.add_child(game_title)

	var sub := Label.new()
	sub.text = "Pick a buddy and stack up high"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", COL_MUTED)
	header.add_child(sub)

	var page := MarginContainer.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("margin_left", 22)
	page.add_theme_constant_override("margin_right", 22)
	page.add_theme_constant_override("margin_top", 126)
	page.add_theme_constant_override("margin_bottom", 22)
	select_ui.add_child(page)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 3 if _vp_size().x >= 860 else 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	var capy_preview: String = CapybaraRushPaths.CAPYBARA_BASE_RIGGED
	var cards: Array = [
		["Capybara", CHAR_CAPYBARA, capy_preview, Color(1.0, 0.93, 0.88)],
	]
	var extras: Array = [
		["Little Monster", CHAR_LITTLE_MONSTER, CapybaraRushPaths.LITTLE_MONSTER_RIGGED, CapybaraRushPaths.LITTLE_MONSTER, Color(0.88, 0.98, 0.98)],
		["Bunny", CHAR_LITTLE_RABBIT, CapybaraRushPaths.LITTLE_RABBIT_RIGGED, CapybaraRushPaths.LITTLE_RABBIT, Color(1.0, 0.94, 0.96)],
		["Shiba", CHAR_SHIBA, CapybaraRushPaths.SHIBA_RIGGED, CapybaraRushPaths.SHIBA, Color(0.98, 0.92, 0.84)],
		["Birdie", CHAR_BIRD, CapybaraRushPaths.BIRD_RIGGED, CapybaraRushPaths.BIRD, Color(0.90, 0.96, 1.0)],
		["Mouse", CHAR_MOUSE, CapybaraRushPaths.MOUSE_RIGGED, CapybaraRushPaths.MOUSE, Color(0.94, 0.94, 0.90)],
		["Sloth", CHAR_SLOTH, CapybaraRushPaths.SLOTH_RIGGED, CapybaraRushPaths.SLOTH, Color(0.93, 0.90, 0.84)],
		["Tiny Planet", CHAR_TINY_PLANET, CapybaraRushPaths.TINY_PLANET_RIGGED, CapybaraRushPaths.TINY_PLANET, Color(0.90, 0.94, 0.98)],
		["Bear", CHAR_BEAR, CapybaraRushPaths.BEAR_RIGGED, CapybaraRushPaths.BEAR, Color(0.96, 0.90, 0.84)],
		["Cow", CHAR_COW, CapybaraRushPaths.COW_RIGGED, CapybaraRushPaths.COW, Color(0.92, 0.88, 0.82)],
	]
	for e in extras:
		var preview: String = _host._pick_rigged_or_base(String(e[2]), String(e[3]))
		if preview.is_empty():
			continue
		cards.append([e[0], e[1], preview, e[4]])

	for i in range(cards.size()):
		var c: Array = cards[i]
		var card := _make_character_card(String(c[0]), String(c[1]), String(c[2]), c[3] as Color, i)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(160, 250)
		grid.add_child(card)


func _make_character_card(label_text: String, char_id: String, model_path: String, tint: Color, preview_delay: int = 0) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(COL_CREAM, Color(1.0, 0.72, 0.82), 24.0, 4.0))
	panel.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_host._on_character_chosen(char_id)
	)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(v)

	var preview_frame := PanelContainer.new()
	preview_frame.custom_minimum_size = Vector2(0, 148)
	preview_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_frame.add_theme_stylebox_override("panel", _cartoon_panel_style(tint, Color(1, 1, 1, 0.85), 18.0, 2.0, 4))
	v.add_child(preview_frame)
	preview_frame.add_child(_make_model_preview(model_path, preview_delay))

	var name_l := Label.new()
	name_l.text = label_text
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 22)
	name_l.add_theme_color_override("font_color", COL_INK)
	v.add_child(name_l)

	var btn := _make_text_button("Pick Me", COL_PINK, func() -> void: _host._on_character_chosen(char_id), Vector2(0, 44))
	btn.add_theme_font_size_override("font_size", 20)
	v.add_child(btn)
	return panel


func _make_model_preview(model_path: String, preview_delay: int = 0) -> Control:
	var host := Control.new()
	host.custom_minimum_size = Vector2(180, 150)
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.clip_contents = true

	var sv := SubViewport.new()
	sv.size = Vector2i(384, 384)
	sv.transparent_bg = true
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sv.own_world_3d = true
	host.add_child(sv)

	var tex := TextureRect.new()
	tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(tex)
	tex.texture = sv.get_texture()

	var root := Node3D.new()
	sv.add_child(root)

	var env := Environment.new()
	env.background_mode = Environment.BG_CLEAR_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1.0, 0.95, 0.98)
	env.ambient_light_energy = 0.9
	var we := WorldEnvironment.new()
	we.environment = env
	root.add_child(we)

	var key := DirectionalLight3D.new()
	key.light_energy = 1.25
	key.rotation_degrees = Vector3(-35.0, 30.0, 0.0)
	root.add_child(key)

	var fill := DirectionalLight3D.new()
	fill.light_energy = 0.45
	fill.rotation_degrees = Vector3(-15.0, -140.0, 0.0)
	root.add_child(fill)

	var pivot := Node3D.new()
	root.add_child(pivot)
	var holder := Node3D.new()
	pivot.add_child(holder)

	var cam := Camera3D.new()
	cam.fov = 28.0
	root.add_child(cam)
	cam.current = true
	cam.position = Vector3(0.0, 0.4, 2.4)
	cam.look_at(Vector3(0.0, 0.3, 0.0), Vector3.UP)

	select_spin_pivots.append(pivot)

	var need_cdn: bool = (
		_host._cdn_sys != null
		and _host._cdn_sys.is_enabled()
		and not _host._cdn_sys.is_model_cached(model_path)
	)
	if need_cdn:
		var loading := Label.new()
		loading.text = "Loading"
		loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		loading.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		loading.add_theme_font_size_override("font_size", 18)
		loading.add_theme_color_override("font_color", COL_MUTED)
		_bind_font(loading)
		loading.mouse_filter = Control.MOUSE_FILTER_IGNORE
		host.add_child(loading)
		_fill_select_preview(host, holder, cam, pivot, loading, model_path, preview_delay)
	else:
		_attach_select_preview_model(holder, cam, pivot, null, model_path)
	return host


func _fill_select_preview(host: Control, holder: Node3D, cam: Camera3D, pivot: Node3D, loading: Label, model_path: String, preview_delay: int = 0) -> void:
	if preview_delay > 0:
		await _host.get_tree().create_timer(float(preview_delay) * 0.45)
	if not is_instance_valid(host):
		return
	if _host._cdn_sys != null and _host._cdn_sys.is_enabled():
		await _host._cdn_sys.ensure_cached(model_path)
	if not is_instance_valid(host) or not is_instance_valid(holder):
		return
	_attach_select_preview_model(holder, cam, pivot, loading, model_path)


func _attach_select_preview_model(holder: Node3D, cam: Camera3D, pivot: Node3D, loading: Label, model_path: String) -> void:
	var model: Node3D = _host._instance_fitted(model_path, 0.85, 0.0)
	if model:
		_host._mute_animation_players(model)
		var skel: Skeleton3D = _host._find_skeleton(model)
		if skel != null:
			skel.reset_bone_poses()
		holder.add_child(model)
		if loading != null and is_instance_valid(loading):
			loading.visible = false
		_host.call_deferred("_ui_frame_select_preview", cam, holder, pivot)
		_host.call_deferred("_ui_deferred_reframe_select_preview", cam, holder, pivot)
	elif loading != null and is_instance_valid(loading):
		loading.text = "Load failed"


func _deferred_reframe_select_preview(cam: Camera3D, holder: Node3D, pivot: Node3D) -> void:
	await _host.get_tree().process_frame
	await _host.get_tree().process_frame
	_frame_select_preview(cam, holder, pivot)


func _frame_select_preview(cam: Camera3D, holder: Node3D, pivot: Node3D) -> void:
	if cam == null or not is_instance_valid(cam):
		return
	if holder == null or not is_instance_valid(holder):
		return
	holder.position = Vector3.ZERO
	if pivot != null and is_instance_valid(pivot):
		pivot.rotation = Vector3.ZERO
	var skel: Skeleton3D = _host._find_skeleton(holder)
	if skel != null:
		skel.reset_bone_poses()
	holder.force_update_transform()
	var aabb: AABB = _host._local_aabb(holder)
	if aabb.size.length() < 0.05:
		aabb = AABB(Vector3(-0.45, 0.0, -0.45), Vector3(0.9, 0.9, 0.9))
	holder.position = -aabb.get_center()
	holder.force_update_transform()
	aabb = _host._local_aabb(holder)
	var center: Vector3 = aabb.get_center()
	var extent := maxf(maxf(aabb.size.x, aabb.size.y), aabb.size.z)
	var radius := maxf(extent * 0.55, 0.5)
	var half_fov := deg_to_rad(cam.fov * 0.5)
	var dist := radius / maxf(tan(half_fov), 0.01) * 2.05
	cam.position = Vector3(radius * 0.12, center.y + aabb.size.y * 0.02, dist)
	cam.look_at(Vector3(0.0, center.y, 0.0), Vector3.UP)


func _spin_select_previews(delta: float) -> void:
	for pivot in select_spin_pivots:
		if pivot != null and is_instance_valid(pivot):
			pivot.rotation.y += delta * 0.85


func _setup_mode_select() -> void:
	_host._start_stack_game()


func _show_result_screen() -> void:
	if result_ui != null:
		return
	_host._stop_bgm(0.5)
	hide_play_chrome()
	var arrived: int = _host._stack.size()
	var unit: String = _host._character_display_name()

	result_ui = CanvasLayer.new()
	result_ui.layer = 30
	_host.add_child(result_ui)
	_add_menu_wash(result_ui, Color(0.58, 0.70, 0.92, 0.55), Color(1.0, 0.78, 0.88, 0.22))

	var card := _make_dialog_card(Vector2(270, 340), Color(1.0, 0.97, 0.98), Color(1.0, 0.72, 0.82))
	result_ui.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	card.get_child(0).add_child(v)

	var badge := Label.new()
	badge.text = "Cleared!"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", COL_PINK_DEEP)
	v.add_child(badge)

	var title := Label.new()
	title.text = "Finish!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", COL_INK)
	v.add_child(title)

	var sub := Label.new()
	sub.text = "Run · %s" % unit
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", COL_MUTED)
	v.add_child(sub)

	var hero_row := HBoxContainer.new()
	hero_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hero_row.add_theme_constant_override("separation", 8)
	v.add_child(hero_row)
	var coin_icon := TextureRect.new()
	coin_icon.texture = _tex(ICON_COIN)
	coin_icon.custom_minimum_size = Vector2(42, 42)
	coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_row.add_child(coin_icon)
	var hero := Label.new()
	hero.text = str(_host._coin_score)
	hero.add_theme_font_size_override("font_size", 56)
	hero.add_theme_color_override("font_color", COL_PINK_DEEP)
	hero_row.add_child(hero)

	var hero_cap := Label.new()
	hero_cap.text = "Coins · %d %s arrived" % [arrived, unit]
	hero_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_cap.add_theme_font_size_override("font_size", 18)
	hero_cap.add_theme_color_override("font_color", COL_INK)
	v.add_child(hero_cap)

	v.add_child(_result_stat_chip("Hits", "%d" % _host._collision_count, Color(1.0, 0.93, 0.88)))
	v.add_child(_result_stat_chip("Drops", "%d" % _host._drop_count, Color(0.90, 0.96, 0.92)))
	v.add_child(_result_stat_chip("Picks", "%d" % _host._picked_count, Color(0.92, 0.93, 1.0)))
	if _host._is_frost_theme() or _host._fruit_icecream > 0 or _host._fruit_crystal > 0:
		v.add_child(_result_stat_chip("Ice Cream", "%d · +%d" % [_host._fruit_icecream, _host._fruit_icecream * 10], Color(0.92, 0.97, 1.0)))
		v.add_child(_result_stat_chip("Crystal", "%d · +%d" % [_host._fruit_crystal, _host._fruit_crystal * 22], Color(0.85, 0.95, 1.0)))
	else:
		v.add_child(_result_stat_chip("Fruit", "Or.%d Ap.%d Ba.%d" % [_host._fruit_orange, _host._fruit_apple, _host._fruit_banana], Color(1.0, 0.96, 0.82)))
		if _host._fruit_pineapple > 0 or _host._fruit_durian > 0:
			v.add_child(_result_stat_chip("Rares", "Pine%d Dur%d" % [_host._fruit_pineapple, _host._fruit_durian], Color(1.0, 0.94, 0.75)))
	v.add_child(_result_stat_chip("Melon", "%d · +%d" % [_host._watermelon_count, _host._watermelon_count * 20], Color(1.0, 0.90, 0.92)))

	CapybaraLevelCatalog.mark_cleared(_host._level_id)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)
	row.add_child(_make_text_button("Play Again", COL_PINK, func() -> void: reload_same_level(), Vector2(150, 54)))
	if _host._level_id < CapybaraLevelCatalog.LEVEL_COUNT:
		row.add_child(_make_text_button("Next Level", COL_SKY, func() -> void: reload_next_level(), Vector2(150, 54)))
	v.add_child(_make_text_button("Levels", Color(0.95, 0.72, 0.45), func() -> void: request_level_select(), Vector2(0, 48)))
	_pop_in(card, Vector2(270, 340))


func _setup_level_select() -> void:
	if level_ui != null:
		level_ui.queue_free()
	level_ui = CanvasLayer.new()
	level_ui.layer = 25
	_host.add_child(level_ui)
	_set_hud_layer_visible(false)
	_add_menu_wash(level_ui, Color(0.58, 0.72, 0.92, 0.62), Color(1.0, 0.82, 0.88, 0.22))

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _ui_theme != null:
		root.theme = _ui_theme
	level_ui.add_child(root)

	var back := _make_text_button("← Characters", Color(0.78, 0.62, 0.92), func() -> void:
		dismiss_level_select()
		setup_character_select()
	, Vector2(120, 48))
	back.set_anchors_preset(Control.PRESET_TOP_LEFT)
	back.offset_left = 18
	back.offset_top = 18
	back.offset_right = 148
	back.offset_bottom = 66
	root.add_child(back)

	var title := Label.new()
	title.text = "Select Level"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left = -200
	title.offset_right = 200
	title.offset_top = 22
	title.offset_bottom = 72
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", COL_INK)
	title.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.85))
	title.add_theme_constant_override("outline_size", 6)
	root.add_child(title)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = 84
	panel.offset_bottom = -24
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(COL_CREAM, Color(1.0, 0.72, 0.82), 28.0, 4.0))
	root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 4 if _vp_size().x >= 780 else 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	var unlocked := CapybaraLevelCatalog.get_unlocked_max()
	for i in range(1, CapybaraLevelCatalog.LEVEL_COUNT + 1):
		grid.add_child(_make_level_button(i, unlocked))


func _make_level_button(level_id: int, unlocked: int) -> Control:
	var cfg := CapybaraLevelCatalog.load_level(level_id)
	var theme_id := String(cfg.get("theme_id", "lake_clear"))
	var tint := _theme_tint(theme_id)
	var is_test := bool(cfg.get("test_level", false))
	var locked := level_id > unlocked and not is_test
	var cleared := CapybaraLevelCatalog.is_cleared(level_id)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(96, 108)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var border := Color(0.75, 0.78, 0.86) if locked else (COL_GOLD if cleared else Color(1.0, 0.72, 0.82))
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(tint if not locked else Color(0.90, 0.90, 0.93), border, 20.0, 3.0, 6))

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 2)
	panel.add_child(v)

	var top := HBoxContainer.new()
	top.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(top)
	if locked:
		var lock_icon := TextureRect.new()
		lock_icon.texture = _tex(ICON_LOCK)
		lock_icon.custom_minimum_size = Vector2(28, 28)
		lock_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		lock_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		top.add_child(lock_icon)
	elif cleared:
		var star := TextureRect.new()
		star.texture = _tex(ICON_STAR)
		star.custom_minimum_size = Vector2(26, 26)
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		top.add_child(star)

	var num := Label.new()
	num.text = "%02d" % level_id
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.add_theme_font_size_override("font_size", 28)
	num.add_theme_color_override("font_color", COL_MUTED if locked else COL_INK)
	v.add_child(num)

	var name_l := Label.new()
	name_l.text = "Locked" if locked else String(cfg.get("name", ""))
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_l.add_theme_font_size_override("font_size", 14)
	name_l.add_theme_color_override("font_color", COL_MUTED)
	v.add_child(name_l)

	if not locked:
		panel.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_host._on_level_chosen(level_id)
		)
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		panel.modulate = Color(1, 1, 1, 0.78)
	return panel


func _cartoon_panel_style(bg: Color, border: Color, radius: float, border_w: float, shadow: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(int(radius))
	sb.border_color = border
	sb.set_border_width_all(int(border_w))
	sb.shadow_color = Color(0.55, 0.35, 0.5, 0.22)
	sb.shadow_size = shadow
	sb.shadow_offset = Vector2(0, 5)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb


func _result_stat_chip(stat_name: String, value: String, bg: Color) -> Control:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", _cartoon_panel_style(bg, Color(1, 1, 1, 0.65), 16.0, 2.0, 4))
	var inner := HBoxContainer.new()
	row.add_child(inner)
	var left := Label.new()
	left.text = stat_name
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_font_size_override("font_size", 18)
	left.add_theme_color_override("font_color", Color(0.42, 0.32, 0.45))
	var right := Label.new()
	right.text = value
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_theme_font_size_override("font_size", 20)
	right.add_theme_color_override("font_color", COL_PINK_DEEP)
	inner.add_child(left)
	inner.add_child(right)
	return row


func _reload_same_level() -> void:
	CapybaraUi.pending_level_id = _host._level_id
	CapybaraUi.pending_character_id = _host._character_id
	_host.reload_game_scene()


func _reload_next_level() -> void:
	CapybaraUi.pending_level_id = mini(_host._level_id + 1, CapybaraLevelCatalog.LEVEL_COUNT)
	CapybaraUi.pending_character_id = _host._character_id
	_host.reload_game_scene()


func _make_stat_chip(icon_path: String) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(108, 52)
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(COL_CREAM, Color(1.0, 0.78, 0.86), 22.0, 3.0, 6))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(row)
	var icon := TextureRect.new()
	icon.texture = _tex(icon_path)
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	var lab := Label.new()
	lab.text = "0"
	lab.add_theme_font_size_override("font_size", 22)
	lab.add_theme_color_override("font_color", COL_INK)
	row.add_child(lab)
	return {"root": panel, "label": lab}


func _make_icon_button(icon_path: String, size: Vector2, on_press: Callable = Callable()) -> TextureButton:
	var btn := TextureButton.new()
	var tex := _tex(icon_path)
	btn.texture_normal = tex
	btn.texture_pressed = tex
	btn.texture_hover = tex
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.custom_minimum_size = size
	btn.modulate = Color(1, 1, 1, 0.98)
	if on_press.is_valid():
		btn.pressed.connect(on_press)
	return btn


func _make_text_button(text: String, fill: Color, on_press: Callable, min_size: Vector2 = Vector2(0, 52)) -> Button:
	var btn := Button.new()
	btn.text = text
	if min_size.x > 0.0 or min_size.y > 0.0:
		btn.custom_minimum_size = min_size
	else:
		btn.custom_minimum_size = Vector2(0, 52)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 22)
	_bind_font(btn)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.98))
	btn.add_theme_color_override("font_focus_color", Color(1, 1, 1))
	var hover := fill.lightened(0.08)
	var press := fill.darkened(0.08)
	btn.add_theme_stylebox_override("normal", _cartoon_panel_style(fill, fill.lightened(0.25), 20.0, 0.0, 6))
	btn.add_theme_stylebox_override("hover", _cartoon_panel_style(hover, hover.lightened(0.2), 20.0, 0.0, 6))
	btn.add_theme_stylebox_override("pressed", _cartoon_panel_style(press, press.lightened(0.15), 20.0, 0.0, 4))
	btn.add_theme_stylebox_override("focus", _cartoon_panel_style(hover, Color(1, 1, 1, 0.7), 20.0, 2.0, 6))
	btn.pressed.connect(on_press)
	return btn


func _make_dialog_card(half: Vector2, bg: Color, border: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -half.x
	card.offset_right = half.x
	card.offset_top = -half.y
	card.offset_bottom = half.y
	card.add_theme_stylebox_override("panel", _cartoon_panel_style(bg, border, 28.0, 5.0))
	if _ui_theme != null:
		card.theme = _ui_theme
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	card.add_child(margin)
	return card


func _add_menu_wash(layer: CanvasLayer, dim_col: Color, blob_col: Color) -> void:
	var dim := ColorRect.new()
	dim.color = dim_col
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dim)
	var blobs := [
		[Vector2(-80, -40), Vector2(280, 260)],
		[Vector2(0.72, -60), Vector2(340, 300)],
		[Vector2(-40, 0.62), Vector2(260, 240)],
		[Vector2(0.78, 0.70), Vector2(220, 200)],
	]
	for b in blobs:
		var p := Panel.new()
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pos: Vector2 = b[0]
		var sz: Vector2 = b[1]
		if pos.x <= 1.0 and pos.x >= 0.0:
			p.set_anchor(SIDE_LEFT, pos.x)
			p.set_anchor(SIDE_RIGHT, pos.x)
			p.offset_left = 0
			p.offset_right = sz.x
		else:
			p.set_anchors_preset(Control.PRESET_TOP_LEFT)
			p.offset_left = pos.x
			p.offset_right = pos.x + sz.x
		if pos.y <= 1.0 and pos.y >= 0.0:
			p.set_anchor(SIDE_TOP, pos.y)
			p.set_anchor(SIDE_BOTTOM, pos.y)
			p.offset_top = 0
			p.offset_bottom = sz.y
		else:
			p.offset_top = pos.y
			p.offset_bottom = pos.y + sz.y
		var sb := _cartoon_panel_style(blob_col, Color(1, 1, 1, 0.0), 999.0, 0.0, 0)
		sb.shadow_size = 0
		p.add_theme_stylebox_override("panel", sb)
		layer.add_child(p)


func _pop_in(card: Control, half: Vector2) -> void:
	card.scale = Vector2(0.82, 0.82)
	card.pivot_offset = half
	var tw := card.create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(card, "scale", Vector2.ONE, 0.4)


func _set_hud_layer_visible(v: bool) -> void:
	if hud_layer:
		hud_layer.visible = v


func _set_controls_visible(v: bool) -> void:
	if _hud_controls:
		_hud_controls.visible = v
	if _pause_btn:
		_pause_btn.visible = v or _host._waiting_to_start


func _vp_size() -> Vector2:
	if _host == null:
		return Vector2(1280, 720)
	return _host.get_viewport().get_visible_rect().size


func _theme_tint(theme_id: String) -> Color:
	match theme_id:
		"frost_snow":
			return Color(0.86, 0.94, 1.0)
		"onsen_volcano":
			return Color(1.0, 0.88, 0.80)
		"dusk_neon":
			return Color(0.90, 0.84, 1.0)
		"sakura_cloud":
			return Color(1.0, 0.88, 0.92)
		"honey_pasture":
			return Color(1.0, 0.95, 0.80)
		_:
			return Color(0.88, 0.95, 1.0)


func _tex(path: String) -> Texture2D:
	if _tex_cache.has(path):
		return _tex_cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null and FileAccess.file_exists(path):
		var img := Image.load_from_file(path)
		if img:
			tex = ImageTexture.create_from_image(img)
	_tex_cache[path] = tex
	return tex
