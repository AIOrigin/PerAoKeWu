extends Control

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const CharacterProgression = preload("res://assets/maps/route_levels/character_progression.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const MobilePauseOverlay = preload("res://assets/maps/route_levels/mobile_pause_overlay.gd")

const MAP_PREVIEW_FALLBACK := "res://assets/ddddd.png"
const TAB_HOME := "home"
const TAB_MAP := "map"
const TAB_TASKS := "tasks"
const TAB_CHARACTER := "character"

const TAB_LABELS := {
	TAB_HOME: "HOME",
	TAB_MAP: "MAP",
	TAB_TASKS: "TASKS",
	TAB_CHARACTER: "RUNNER",
}
const MOBILE_VIEWPORT_SIZE := Vector2(1080, 1920)

# 深蓝科技风（与据点详情页统一）
const UI_BG := Color(0.03, 0.05, 0.08, 0.98)
const UI_FRAME := Color(0.06, 0.08, 0.12, 0.98)
const UI_FRAME_BORDER := Color(0.34, 0.52, 0.68, 0.92)
const UI_PANEL := Color(0.08, 0.10, 0.14, 0.96)
const UI_PANEL_BORDER := Color(0.24, 0.38, 0.52, 0.72)
const UI_TEXT := Color(0.90, 0.93, 0.98)
const UI_MUTED := Color(0.58, 0.64, 0.72)
const UI_STATUS := Color(0.98, 0.74, 0.30)
const UI_CYAN := Color(0.42, 0.86, 0.98)
const UI_REWARD := Color(0.78, 0.62, 0.98)
const UI_GOLD := Color(0.94, 0.72, 0.22)
const UI_GOLD_BORDER := Color(0.98, 0.84, 0.42)
const UI_GREEN := Color(0.42, 0.86, 0.58)
const UI_ORANGE := Color(0.98, 0.62, 0.18)
const UI_ORANGE_BORDER := Color(1.0, 0.78, 0.36)
const UI_HEADER := Color(0.05, 0.055, 0.07, 0.98)
const UI_METAL := Color(0.10, 0.09, 0.08, 0.98)
const UI_METAL_BORDER := Color(0.62, 0.50, 0.30, 0.92)

const HEADER_UI_ROOT := "res://assets/maps/route_levels/mobile_home/ui_header/"
const HEADER_ICON_ENERGY := HEADER_UI_ROOT + "icon_energy.png"
const HEADER_ICON_GOLD := HEADER_UI_ROOT + "icon_gold.png"
const HEADER_ICON_EMBER := HEADER_UI_ROOT + "icon_ember.png"
const HEADER_ICON_SETTINGS := HEADER_UI_ROOT + "icon_settings.png"
const HOME_UI_ROOT := "res://assets/maps/route_levels/mobile_home/ui_home/"
const HOME_BG_PATH := HOME_UI_ROOT + "background.png"
const FINAL_UI_ROOT := "res://assets/maps/route_levels/mobile_home/ui_final/"
const FINAL_TOPBAR := FINAL_UI_ROOT + "ui_topbar_container.png"
const FINAL_MAP_FRAME := FINAL_UI_ROOT + "ui_map_panel_frame.png"
const FINAL_MISSION_FRAME := FINAL_UI_ROOT + "ui_mission_frame.png"
const FINAL_TABBAR := FINAL_UI_ROOT + "ui_tabbar_container.png"
const FINAL_BTN_NORMAL := FINAL_UI_ROOT + "ui_button_transport_normal.png"
const FINAL_BTN_PRESSED := FINAL_UI_ROOT + "ui_button_transport_pressed.png"
const FINAL_BTN_DISABLED := FINAL_UI_ROOT + "ui_button_transport_disabled.png"
const FINAL_TAB_INDICATOR := FINAL_UI_ROOT + "ui_tab_indicator_active.png"
const FINAL_PROGRESS_TRACK := FINAL_UI_ROOT + "ui_progressbar_track.png"
const FINAL_PROGRESS_FILL := FINAL_UI_ROOT + "ui_progressbar_fill.png"
const FINAL_AVATAR_RING := FINAL_UI_ROOT + "ui_avatar_ring.png"
const FINAL_UTILITY_SLOT := FINAL_UI_ROOT + "ui_utility_slot.png"
const FINAL_ICON_EMBER := FINAL_UI_ROOT + "icon_currency_ember_coin.png"
const FINAL_ICON_SETTINGS := FINAL_UI_ROOT + "icon_settings.png"
const FINAL_ICON_RUN := FINAL_UI_ROOT + "icon_action_run.png"
const FINAL_ICON_ARROW := FINAL_UI_ROOT + "icon_arrow_right.png"
const FINAL_ICON_CARGO := FINAL_UI_ROOT + "icon_cargo_water.png"
const FINAL_ICON_TAB := {
	TAB_HOME: FINAL_UI_ROOT + "icon_tab_home.png",
	TAB_MAP: FINAL_UI_ROOT + "icon_tab_map.png",
	TAB_TASKS: FINAL_UI_ROOT + "icon_tab_tasks.png",
	TAB_CHARACTER: FINAL_UI_ROOT + "icon_tab_runner.png",
}
const CHAR_UI_ROOT := "res://assets/maps/route_levels/mobile_home/ui_character/"
const CHAR_BADGE_BG := CHAR_UI_ROOT + "character_badge_bg.png"
const CHAR_SECTION_LINE := CHAR_UI_ROOT + "section_title_line.png"
const CHAR_CORNER_TL := CHAR_UI_ROOT + "comic_frame_corner_tl.png"
const CHAR_CORNER_BR := CHAR_UI_ROOT + "comic_frame_corner_br.png"
const CHAR_STORY_PANEL_BG := CHAR_UI_ROOT + "story_panel_bg.png"
const CHAR_STORY_PANEL_BORDER := CHAR_UI_ROOT + "story_panel_border.png"
const MAPLIST_UI_ROOT := "res://assets/maps/route_levels/mobile_home/ui_maplist/"
const MAPLIST_PREVIEW_01 := MAPLIST_UI_ROOT + "map01_preview.png"
const MAPLIST_ICON_OUTPOST := MAPLIST_UI_ROOT + "icon_outpost.png"
const MAPLIST_ICON_PURIFY := MAPLIST_UI_ROOT + "icon_purify.png"
const MAPLIST_ICON_CHAPTER := MAPLIST_UI_ROOT + "icon_chapter.png"
const MAPLIST_BADGE_DIAMOND := MAPLIST_UI_ROOT + "badge_diamond.png"
const UI_OPEN_GREEN := Color(0.42, 0.78, 0.38)
const UI_OPEN_GREEN_BG := Color(0.10, 0.18, 0.10, 0.95)

const TAB_SUBTITLES := {
	TAB_HOME: "继续推进晶砂荒漠黎明线",
	TAB_MAP: "选择星球，进入据点探索",
	TAB_TASKS: "查看并接取运输任务",
	TAB_CHARACTER: "培养信使，升级属性与飞船",
}

const GUIDE_STEPS := [
	{
		"tab": TAB_MAP,
		"title": "从这里开始",
		"body": "点击 MAP 进入据点地图，选择运输任务并开始跑酷。相邻区域会在完成任务后点亮。",
		"next": "知道了",
	},
]

var _page_box: VBoxContainer
var _page_scroll: ScrollContainer
var _page_title: Label
var _page_subtitle: Label
var _status_name: Label
var _status_level_label: Label
var _status_level_badge: Label
var _status_xp_bar: ProgressBar
var _status_energy_label: Label
var _status_energy_timer: Label
var _status_gold_label: Label
var _status_ember_label: Label
var _status_avatar_icon: TextureRect
var _status_avatar_fallback: Label
var _header_textures: Dictionary = {}
var _toast_panel: PanelContainer
var _toast_label: Label
var _toast_tween: Tween
var _nav_buttons: Dictionary = {}
var _story_overlay: Control
var _guide_overlay: Control
var _character_story_overlay: Control
var _selected_character_id: String = CharacterRoster.CHAR_ELSA
var _guide_highlight: PanelContainer
var _guide_callout: PanelContainer
var _guide_title_label: Label
var _guide_body_label: Label
var _guide_next_button: Button
var _root_margin: MarginContainer
var _ui_root: Control
var _home_background: TextureRect
var _page_scrim: ColorRect
var _home_title_box: Control
var _selected_tab := TAB_HOME
var _selected_planet_id := "glass_desert"
var _guide_step := -1
var _pause_overlay: MobilePauseOverlay
var _energy_tick := 0.0


func _ready() -> void:
	add_to_group("MobileHomeScene")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	get_viewport().size_changed.connect(_on_viewport_resized)
	if Global.mobile_home_tab != "":
		_selected_tab = Global.mobile_home_tab
	_build_ui()
	_setup_pause_overlay()
	call_deferred("_apply_mobile_layout")
	_show_tab(_selected_tab)
	_refresh_status_bar()
	if not Global.first_launch_story_seen:
		_show_story_intro()
	elif not Global.home_guide_seen:
		_start_home_guide()


func _unhandled_input(event: InputEvent) -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		return
	if _character_story_overlay != null and is_instance_valid(_character_story_overlay):
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
			_close_character_story()
			get_viewport().set_input_as_handled()
		return
	if _story_overlay != null and _story_overlay.visible:
		return
	if _guide_overlay != null and _guide_overlay.visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		if _pause_overlay != null:
			_pause_overlay.open_pause()
			get_viewport().set_input_as_handled()


func _setup_pause_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PauseLayer"
	layer.layer = 40
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_pause_overlay = MobilePauseOverlay.new()
	_pause_overlay.configure({
		"show_quit": false,
		"show_pause_button": true,
	})
	layer.add_child(_pause_overlay)


func _on_viewport_resized() -> void:
	_apply_mobile_layout()
	_update_guide_layout()
	_position_toast()


func _apply_mobile_layout() -> void:
	if _root_margin == null:
		return
	var frame_size := get_viewport().get_visible_rect().size
	if _ui_root != null and _ui_root.size.x > 1.0 and _ui_root.size.y > 1.0:
		frame_size = _ui_root.size
	var scale := maxf(frame_size.x / MOBILE_VIEWPORT_SIZE.x, 0.75)
	var side_margin := int(maxf(24.0, 28.0 * scale))
	var top_margin := int(maxf(16.0, 22.0 * scale))
	# 设计稿底栏贴底，默认不加空隙；仅在有底部安全区时抬高
	var bottom_margin := 0
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		var safe := DisplayServer.get_display_safe_area()
		if safe.size.x > 0 and safe.size.y > 0:
			side_margin = maxi(side_margin, safe.position.x)
			top_margin = maxi(top_margin, safe.position.y)
			bottom_margin = maxi(bottom_margin, maxi(0, int(frame_size.y) - safe.end.y))
	_root_margin.add_theme_constant_override("margin_left", side_margin)
	_root_margin.add_theme_constant_override("margin_right", side_margin)
	_root_margin.add_theme_constant_override("margin_top", top_margin)
	_root_margin.add_theme_constant_override("margin_bottom", bottom_margin)
	if _page_title:
		_page_title.add_theme_font_size_override("font_size", 34)
	for button in _nav_buttons.values():
		button.custom_minimum_size = Vector2(0, 96)
		button.add_theme_font_size_override("font_size", 15)


func _build_ui() -> void:
	var letterbox := ColorRect.new()
	letterbox.color = Color(0.01, 0.02, 0.04)
	letterbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	letterbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(letterbox)

	var frame := AspectRatioContainer.new()
	frame.name = "MobileFrame"
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.stretch_mode = AspectRatioContainer.STRETCH_FIT
	frame.ratio = MOBILE_VIEWPORT_SIZE.x / MOBILE_VIEWPORT_SIZE.y
	frame.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	frame.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	add_child(frame)

	var shell := Control.new()
	shell.name = "MobileShell"
	shell.custom_minimum_size = MOBILE_VIEWPORT_SIZE
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(shell)
	_ui_root = shell

	var background := TextureRect.new()
	background.name = "HomeBackground"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_tex := _load_header_texture(HOME_BG_PATH)
	if bg_tex:
		background.texture = bg_tex
	else:
		background.modulate = Color(0.12, 0.08, 0.05)
	shell.add_child(background)
	_home_background = background

	_page_scrim = ColorRect.new()
	_page_scrim.name = "PageScrim"
	_page_scrim.color = Color(0.02, 0.03, 0.05, 0.78)
	_page_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_scrim.visible = false
	shell.add_child(_page_scrim)

	var margin := MarginContainer.new()
	margin.name = "RootMargin"
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 0)
	shell.add_child(margin)
	_root_margin = margin

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	root.add_child(_build_status_bar())
	_home_title_box = _build_home_title_overlay()
	root.add_child(_home_title_box)

	_page_title = Label.new()
	_page_title.add_theme_font_size_override("font_size", 32)
	_page_title.add_theme_color_override("font_color", UI_TEXT)
	root.add_child(_page_title)

	_page_subtitle = Label.new()
	_page_subtitle.add_theme_font_size_override("font_size", 15)
	_page_subtitle.add_theme_color_override("font_color", UI_MUTED)
	root.add_child(_page_subtitle)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	_page_scroll = scroll

	_page_box = VBoxContainer.new()
	_page_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_box.add_theme_constant_override("separation", 16)
	scroll.add_child(_page_box)

	root.add_child(_build_bottom_nav())
	_ensure_toast_layer()


func _build_home_title_overlay() -> Control:
	var box := VBoxContainer.new()
	box.name = "HomeTitle"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var title := Label.new()
	title.text = "星火信使"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	title.add_theme_color_override("font_color", Color(0.98, 0.97, 0.94))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "黎明线"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 26)
	subtitle.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78, 0.92))
	subtitle.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.45))
	subtitle.add_theme_constant_override("shadow_offset_x", 1)
	subtitle.add_theme_constant_override("shadow_offset_y", 1)
	box.add_child(subtitle)
	return box


func _on_avatar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_tab(TAB_CHARACTER)
	elif event is InputEventScreenTouch and event.pressed:
		_show_tab(TAB_CHARACTER)


func _build_status_bar() -> Control:
	# 简洁顶栏：左头像+名+等级，右星火币+设置；深底+金底边
	var bar := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.059, 0.082, 0.125, 0.98) # #0F1520
	style.set_border_width_all(0)
	style.border_width_bottom = 2
	style.border_color = Color(0.831, 0.647, 0.455, 0.85) # #D4A574
	style.set_content_margin_all(0)
	bar.add_theme_stylebox_override("panel", style)
	bar.custom_minimum_size = Vector2(0, 88)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	bar.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	# —— 左侧：圆形头像 + 名 + 等级 ——
	var left := HBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.alignment = BoxContainer.ALIGNMENT_BEGIN
	left.add_theme_constant_override("separation", 12)
	row.add_child(left)

	var avatar_wrap := Control.new()
	avatar_wrap.custom_minimum_size = Vector2(56, 56)
	avatar_wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	avatar_wrap.gui_input.connect(_on_avatar_input)
	left.add_child(avatar_wrap)

	var avatar_clip := Panel.new()
	avatar_clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	avatar_clip.clip_contents = true
	avatar_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var clip_style := StyleBoxFlat.new()
	clip_style.bg_color = Color(0.10, 0.09, 0.08)
	clip_style.set_corner_radius_all(28)
	clip_style.set_border_width_all(2)
	clip_style.border_color = Color(0.831, 0.647, 0.455, 0.95)
	clip_style.set_content_margin_all(0)
	avatar_clip.add_theme_stylebox_override("panel", clip_style)
	avatar_wrap.add_child(avatar_clip)

	_status_avatar_icon = TextureRect.new()
	_status_avatar_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_status_avatar_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_status_avatar_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_status_avatar_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status_avatar_icon.visible = false
	avatar_clip.add_child(_status_avatar_icon)

	_status_avatar_fallback = Label.new()
	_status_avatar_fallback.text = "E"
	_status_avatar_fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_status_avatar_fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_avatar_fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_avatar_fallback.add_theme_font_size_override("font_size", 22)
	_status_avatar_fallback.add_theme_color_override("font_color", Color(0.92, 0.84, 0.62))
	_status_avatar_fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar_clip.add_child(_status_avatar_fallback)

	_status_level_badge = Label.new()
	_status_level_badge.visible = false
	avatar_wrap.add_child(_status_level_badge)
	_status_xp_bar = ProgressBar.new()
	_status_xp_bar.visible = false
	avatar_wrap.add_child(_status_xp_bar)

	var name_col := HBoxContainer.new()
	name_col.alignment = BoxContainer.ALIGNMENT_CENTER
	name_col.add_theme_constant_override("separation", 8)
	name_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.add_child(name_col)

	_status_name = Label.new()
	_status_name.text = "Elsa"
	_status_name.add_theme_font_size_override("font_size", 24)
	_status_name.add_theme_color_override("font_color", Color(0.98, 0.97, 0.95))
	_status_name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_col.add_child(_status_name)

	_status_level_label = Label.new()
	_status_level_label.text = "Lv.1"
	_status_level_label.add_theme_font_size_override("font_size", 18)
	_status_level_label.add_theme_color_override("font_color", Color(0.90, 0.78, 0.55))
	_status_level_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_col.add_child(_status_level_label)

	# —— 右侧：星火币 + 分隔 + 设置 ——
	var right := HBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_END
	right.add_theme_constant_override("separation", 14)
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(right)

	var coin_wrap := HBoxContainer.new()
	coin_wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	coin_wrap.add_theme_constant_override("separation", 8)
	right.add_child(coin_wrap)

	var coin_icon := TextureRect.new()
	coin_icon.custom_minimum_size = Vector2(32, 32)
	coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var coin_tex := _load_header_texture(FINAL_ICON_EMBER)
	if coin_tex == null:
		coin_tex = _load_header_texture(HEADER_ICON_EMBER)
	if coin_tex:
		coin_icon.texture = coin_tex
	coin_wrap.add_child(coin_icon)

	_status_ember_label = Label.new()
	_status_ember_label.text = "0"
	_status_ember_label.add_theme_font_size_override("font_size", 22)
	_status_ember_label.add_theme_color_override("font_color", Color(0.90, 0.78, 0.55))
	coin_wrap.add_child(_status_ember_label)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(1, 28)
	divider.color = Color(0.55, 0.48, 0.36, 0.45)
	divider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	right.add_child(divider)

	var settings_button := Button.new()
	settings_button.focus_mode = Control.FOCUS_NONE
	settings_button.flat = true
	settings_button.custom_minimum_size = Vector2(40, 40)
	settings_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	settings_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	settings_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	settings_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	settings_button.pressed.connect(func(): _show_toast("设置功能开发中"))
	right.add_child(settings_button)

	var settings_icon := TextureRect.new()
	settings_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 4)
	settings_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	settings_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	settings_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var settings_tex := _load_header_texture(FINAL_ICON_SETTINGS)
	if settings_tex == null:
		settings_tex = _load_header_texture(HEADER_ICON_SETTINGS)
	if settings_tex:
		settings_icon.texture = settings_tex
	settings_button.add_child(settings_icon)

	_status_energy_label = null
	_status_energy_timer = null
	_status_gold_label = null
	return bar

func _build_header_resource_pod(icon_path: String, kind: String) -> Control:
	# 保留函数以免旧调用崩溃；新顶栏不再使用资源舱
	var stub := Control.new()
	stub.visible = false
	stub.set_meta("unused_kind", kind)
	stub.set_meta("unused_icon", icon_path)
	return stub


func _load_header_texture(path: String) -> Texture2D:
	if _header_textures.has(path):
		return _header_textures[path] as Texture2D
	if path == "":
		return null
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		return null
	var tex := load(path) as Texture2D
	if tex:
		_header_textures[path] = tex
	return tex


func _style_header_metal_button(button: Button, icon_path: String, label: String) -> void:
	var normal := _style(Color(0.12, 0.10, 0.08, 0.98), UI_METAL_BORDER, 1, 3)
	var hover := _style(Color(0.18, 0.14, 0.10, 0.98), UI_GOLD_BORDER, 1, 3)
	var pressed := _style(Color(0.08, 0.07, 0.05, 0.98), UI_GOLD, 1, 3)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("disabled", normal)
	button.flat = false
	button.text = ""

	var tex := _load_header_texture(icon_path) if icon_path != "" else null
	if tex:
		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = tex
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		return

	button.text = label if label != "" else "+"
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", UI_GOLD)
	button.add_theme_color_override("font_hover_color", UI_GOLD_BORDER)
	button.add_theme_color_override("font_pressed_color", UI_ORANGE)


func _build_bottom_nav() -> Control:
	var nav := PanelContainer.new()
	var tabbar_tex := _load_header_texture(FINAL_TABBAR)
	if tabbar_tex:
		# 顶边金线与指示条对齐：顶部 content margin 压到最小
		nav.add_theme_stylebox_override("panel", _style_texture(tabbar_tex, 64, 36, 64, 36, 4, 0, 4, 10))
	else:
		nav.add_theme_stylebox_override("panel", _style(Color(0.05, 0.05, 0.06, 0.94), Color(0.28, 0.24, 0.18, 0.55), 1, 0))
	nav.custom_minimum_size = Vector2(0, 120)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_bottom", 8)
	nav.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 0)
	margin.add_child(row)

	_add_nav_button(row, TAB_HOME, String(TAB_LABELS[TAB_HOME]))
	_add_nav_button(row, TAB_MAP, String(TAB_LABELS[TAB_MAP]))
	_add_nav_button(row, TAB_TASKS, String(TAB_LABELS[TAB_TASKS]))
	_add_nav_button(row, TAB_CHARACTER, String(TAB_LABELS[TAB_CHARACTER]))
	return nav


func _add_nav_button(parent: Control, tab_id: String, label: String) -> void:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 100)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.flat = true
	button.pressed.connect(_show_tab.bind(tab_id))

	# 指示条贴顶、左右等距内缩，避免和底栏顶金线错位成「双线」
	var indicator := NinePatchRect.new()
	indicator.name = "ActiveIndicator"
	indicator.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	indicator.offset_left = 22
	indicator.offset_right = -22
	indicator.offset_top = 2
	indicator.offset_bottom = 10
	indicator.patch_margin_left = 12
	indicator.patch_margin_right = 12
	indicator.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	indicator.visible = false
	var ind_tex := _load_header_texture(FINAL_TAB_INDICATOR)
	if ind_tex:
		indicator.texture = ind_tex
	button.add_child(indicator)

	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.offset_top = 14
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 4)
	button.add_child(col)

	var icon := TextureRect.new()
	icon.name = "TabIcon"
	icon.custom_minimum_size = Vector2(40, 40)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_path := String(FINAL_ICON_TAB.get(tab_id, ""))
	var icon_tex := _load_header_texture(icon_path)
	if icon_tex:
		icon.texture = icon_tex
	col.add_child(icon)

	var text := Label.new()
	text.name = "TabLabel"
	text.text = label
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 15)
	text.add_theme_color_override("font_color", Color(0.62, 0.66, 0.72))
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(text)

	parent.add_child(button)
	_nav_buttons[tab_id] = button


func _update_nav_buttons() -> void:
	for tab_id in _nav_buttons.keys():
		var button: Button = _nav_buttons[tab_id]
		var selected := String(tab_id) == _selected_tab
		button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())

		var indicator := button.find_child("ActiveIndicator", true, false) as NinePatchRect
		var label := button.find_child("TabLabel", true, false) as Label
		var icon := button.find_child("TabIcon", true, false) as TextureRect
		if indicator:
			indicator.visible = selected
		if label:
			label.add_theme_color_override("font_color", UI_ORANGE_BORDER if selected else Color(0.62, 0.66, 0.72))
		if icon:
			icon.modulate = Color(1.0, 0.92, 0.72) if selected else Color(0.75, 0.78, 0.82)


func _show_tab(tab_id: String, force: bool = false, keep_scroll: bool = false) -> void:
	if _guide_step >= 0 and not force:
		return
	_selected_tab = tab_id
	Global.mobile_home_tab = tab_id
	var saved_scroll := 0
	if keep_scroll and _page_scroll:
		saved_scroll = _page_scroll.scroll_vertical
	else:
		_scroll_page_to_top()
	_clear_page()
	var is_home := tab_id == TAB_HOME
	if _page_scrim:
		_page_scrim.visible = not is_home
	if _home_title_box:
		_home_title_box.visible = is_home
	if _page_scroll:
		# 首页固定一屏，禁止滚动；其他页允许滚动
		_page_scroll.vertical_scroll_mode = (
			ScrollContainer.SCROLL_MODE_DISABLED if is_home else ScrollContainer.SCROLL_MODE_AUTO
		)
		_page_scroll.scroll_vertical = 0
	match tab_id:
		TAB_MAP:
			_page_title.text = ""
			_page_subtitle.text = ""
			_build_map_page()
		TAB_TASKS:
			_page_title.text = "TASKS"
			_page_subtitle.text = String(TAB_SUBTITLES.get(tab_id, ""))
			_build_tasks_page()
		TAB_CHARACTER:
			_page_title.text = ""
			_page_subtitle.text = ""
			_build_character_page()
		_:
			_page_title.text = ""
			_page_subtitle.text = ""
			_build_home_page()
	_page_title.visible = _page_title.text != ""
	_page_subtitle.visible = _page_subtitle.text != ""
	_update_nav_buttons()
	_refresh_status_bar()
	if keep_scroll and not is_home:
		_restore_page_scroll(saved_scroll)


func _restore_page_scroll(scroll_y: int) -> void:
	# 等内容撑开后再恢复，避免升级刷新把视口弹回顶部
	await get_tree().process_frame
	if _page_scroll == null or not is_instance_valid(_page_scroll):
		return
	_page_scroll.scroll_vertical = scroll_y
	await get_tree().process_frame
	if _page_scroll == null or not is_instance_valid(_page_scroll):
		return
	_page_scroll.scroll_vertical = scroll_y


func _refresh_status_bar() -> void:
	if _status_name == null:
		return
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	var level := int(snapshot["level"])
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	if not CharacterRoster.is_unlocked(_selected_character_id, unlocked):
		_selected_character_id = CharacterRoster.CHAR_ELSA
	var character: Dictionary = CharacterRoster.get_character(_selected_character_id)
	var char_name := String(character.get("name", snapshot.get("character_name", "Elsa")))
	_status_name.text = char_name
	if _status_level_label:
		_status_level_label.text = "Lv.%d" % level
	if _status_level_badge:
		_status_level_badge.text = str(level)
	if _status_ember_label:
		_status_ember_label.text = _format_count(Global.ember_coins)
	if _status_avatar_fallback:
		_status_avatar_fallback.text = String(character.get("badge", char_name.left(1)))

	var portrait := CharacterRoster.load_texture(String(character.get("portrait_path", "")))
	if portrait == null:
		portrait = _load_runner_portrait("glass_desert")
	if portrait and _status_avatar_icon:
		_status_avatar_icon.texture = portrait
		_status_avatar_icon.visible = true
		if _status_avatar_fallback:
			_status_avatar_fallback.visible = false
	elif _status_avatar_fallback:
		_status_avatar_fallback.visible = true
		if _status_avatar_icon:
			_status_avatar_icon.visible = false


func _format_count(value: int) -> String:
	var text := str(value)
	var result := ""
	var count := 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = text[i] + result
		count += 1
	return result


func _process(delta: float) -> void:
	_energy_tick += delta
	if _energy_tick < 1.0:
		return
	_energy_tick = 0.0
	if _status_energy_timer == null:
		return
	# 展示用回合同步倒计时（满能量时隐藏）
	if Global.runner_energy >= Global.runner_energy_max:
		_status_energy_timer.text = "MAX"
		return
	var secs := int(Time.get_unix_time_from_system()) % 165
	var remain := 165 - secs
	_status_energy_timer.text = "%02d:%02d" % [remain / 60, remain % 60]


func _scroll_page_to_top() -> void:
	if _page_scroll:
		_page_scroll.scroll_vertical = 0


func _clear_page() -> void:
	for child in _page_box.get_children():
		child.queue_free()
	_page_box.custom_minimum_size = Vector2.ZERO
	_page_box.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _build_home_page() -> void:
	# 设计稿：一屏固定布局，不滚动；任务卡贴底部
	_page_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_box.custom_minimum_size = Vector2.ZERO
	_page_box.add_theme_constant_override("separation", 14)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_box.add_child(spacer)

	var next_entry := _find_next_mission_entry()
	if next_entry.is_empty():
		_page_box.add_child(_build_home_mission_panel(
			_home_map_display_name("glass_desert"),
			"当前据点任务 · 已全部完成",
			"运送：—",
			0,
			1
		))
		_add_home_road_style_picker(_page_box)
		_add_home_start_button(_page_box, "查看地图", _show_tab.bind(TAB_MAP))
		return

	var planet_id := String(next_entry["planet_id"])
	var location_id := String(next_entry["location_id"])
	var mission: Dictionary = next_entry["mission"]
	var map_name := _home_map_display_name(planet_id)
	var outpost_status := _home_outpost_status(planet_id, location_id)

	var mission_code := "M-%02d" % maxi(1, int(mission.get("order", 10)) / 10)
	var mission_title := _home_mission_short_title(mission, location_id)
	var source_name := String(mission.get("source_hearth", outpost_status.get("title", "据点")))
	var cargo_name := String(mission.get("cargo_name", "物资"))
	var cargo_load := int(mission.get("cargo_load", 1))
	var display_qty := maxi(1, int(round(float(cargo_load) * 0.2)))
	var target_name := String(mission.get("target_hearth", "据点"))
	var objective := "运送：%s × %d → %s" % [cargo_name, display_qty, target_name]

	var repair := _home_repair_progress(planet_id, location_id)
	var mission_line := "当前据点任务 · %s %s · %s（%s）" % [
		mission_code,
		mission_title,
		source_name,
		String(outpost_status.get("status_short", "修复中")),
	]
	_page_box.add_child(_build_home_mission_panel(
		map_name,
		mission_line,
		objective,
		int(repair["current"]),
		int(repair["total"])
	))
	_add_home_road_style_picker(_page_box)
	_add_home_start_button(
		_page_box,
		"开始运输",
		_start_runner_for_location.bind(planet_id, location_id)
	)


func _home_map_display_name(planet_id: String) -> String:
	var meta: Dictionary = PlanetDatabase.get_planet_meta(planet_id)
	var name := String(meta.get("name", ""))
	# 设计稿显示名；配置 MAP_NAME 为「无尽晶砂漠」
	if planet_id == "glass_desert":
		return "晶砂荒原"
	return name if name != "" else "未知地图"


func _home_outpost_status(planet_id: String, location_id: String) -> Dictionary:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if cfg == null or not cfg.has_method("build_detail_payload"):
		return {"title": location_id, "status_short": "未知"}
	var completed := Global.get_completed_runner_locations(planet_id).has(location_id)
	var revealed := Global.get_revealed_exploration_locations(planet_id, ["dome"]).has(location_id)
	var payload: Dictionary = cfg.build_detail_payload(location_id, revealed, completed)
	var status_short := "已点亮" if completed else ("修复中" if revealed else "未开放")
	return {
		"title": String(payload.get("title", location_id)),
		"status_short": status_short,
		"repair_current": int(payload.get("repair_current", 0)),
		"repair_total": int(payload.get("repair_total", 1)),
	}


func _home_mission_short_title(mission: Dictionary, location_id: String) -> String:
	match location_id:
		"dome", "reservoir":
			return "净水救援"
		"medical":
			return "医疗驰援"
		"relay":
			return "星火中继"
		"gate":
			return "防线加固"
		_:
			var task_type := String(mission.get("task_type", ""))
			if task_type != "":
				return task_type
			return String(mission.get("cargo_name", "运输任务"))


func _home_repair_progress(planet_id: String, location_id: String) -> Dictionary:
	# 修复进度对应当前任务据点（起点），与地图详情 payload 同源
	var status := _home_outpost_status(planet_id, location_id)
	return {
		"current": int(status.get("repair_current", 0)),
		"total": maxi(int(status.get("repair_total", 1)), 1),
	}


func _build_home_mission_panel(
	map_name: String,
	mission_line: String,
	objective: String,
	repair_current: int,
	repair_total: int
) -> Control:
	# 设计稿约 825×398（1080 基准）；外框 + 半透明底 + 内容层
	const PANEL_H := 400.0
	var panel := Control.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, PANEL_H)

	var fill := Panel.new()
	fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.add_theme_stylebox_override(
		"panel",
		_style(Color(0.05, 0.05, 0.06, 0.78), Color(0, 0, 0, 0), 0, 8)
	)
	panel.add_child(fill)

	var map_frame := _load_header_texture(FINAL_MAP_FRAME)
	if map_frame:
		var frame := NinePatchRect.new()
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame.texture = map_frame
		frame.patch_margin_left = 80
		frame.patch_margin_top = 80
		frame.patch_margin_right = 80
		frame.patch_margin_bottom = 80
		frame.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
		frame.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_STRETCH
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(frame)
	else:
		fill.add_theme_stylebox_override(
			"panel",
			_style(Color(0.06, 0.06, 0.07, 0.82), Color(0.72, 0.62, 0.38, 0.75), 2, 8)
		)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var tag := Label.new()
	tag.text = "当前地图"
	tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 18)
	tag.add_theme_color_override("font_color", Color(0.90, 0.78, 0.42))
	box.add_child(tag)

	var map_label := Label.new()
	map_label.text = map_name
	map_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_label.add_theme_font_size_override("font_size", 44)
	map_label.add_theme_color_override("font_color", Color(0.98, 0.97, 0.94))
	box.add_child(map_label)

	var mission_label := Label.new()
	mission_label.text = mission_line
	mission_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mission_label.add_theme_font_size_override("font_size", 20)
	mission_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.92))
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(mission_label)

	# mission_frame 九宫格角标约 48px，行高过低会压扁；给足最小高度
	var objective_panel := PanelContainer.new()
	objective_panel.custom_minimum_size = Vector2(0, 108)
	var mission_frame := _load_header_texture(FINAL_MISSION_FRAME)
	if mission_frame:
		objective_panel.add_theme_stylebox_override(
			"panel",
			_style_texture(mission_frame, 48, 40, 48, 40, 28, 18, 28, 18)
		)
	else:
		objective_panel.add_theme_stylebox_override(
			"panel",
			_style(Color(0.04, 0.04, 0.05, 0.72), Color(0.78, 0.66, 0.32, 0.85), 1, 6)
		)
	box.add_child(objective_panel)

	# 图标+文案作为一组在框内水平/垂直居中（勿给 Label 开 EXPAND_FILL，否则会贴左）
	var obj_center := CenterContainer.new()
	obj_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	obj_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	objective_panel.add_child(obj_center)

	var obj_row := HBoxContainer.new()
	obj_row.alignment = BoxContainer.ALIGNMENT_CENTER
	obj_row.add_theme_constant_override("separation", 12)
	obj_center.add_child(obj_row)

	var cargo_icon := TextureRect.new()
	cargo_icon.custom_minimum_size = Vector2(40, 40)
	cargo_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cargo_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cargo_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cargo_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cargo_tex := _load_header_texture(FINAL_ICON_CARGO)
	if cargo_tex:
		cargo_icon.texture = cargo_tex
	obj_row.add_child(cargo_icon)

	var obj_label := Label.new()
	obj_label.text = objective
	obj_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	obj_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	obj_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	obj_label.add_theme_font_size_override("font_size", 22)
	obj_label.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92))
	obj_row.add_child(obj_label)

	var progress_row := HBoxContainer.new()
	progress_row.add_theme_constant_override("separation", 12)
	box.add_child(progress_row)

	var progress_tag := Label.new()
	progress_tag.text = "修复进度"
	progress_tag.add_theme_font_size_override("font_size", 18)
	progress_tag.add_theme_color_override("font_color", Color(0.80, 0.82, 0.86))
	progress_tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	progress_row.add_child(progress_tag)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 20)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.show_percentage = false
	bar.max_value = float(maxi(repair_total, 1))
	bar.value = float(clampi(repair_current, 0, repair_total))
	_apply_final_progress_bar(bar)
	progress_row.add_child(bar)

	var progress_value := Label.new()
	progress_value.text = "%d / %d" % [repair_current, repair_total]
	progress_value.add_theme_font_size_override("font_size", 18)
	progress_value.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78))
	progress_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	progress_row.add_child(progress_value)

	return panel


func _add_home_road_style_picker(parent: Control) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(UI_PANEL, UI_FRAME_BORDER, 1, 10))
	parent.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	row.add_child(info)

	var title := Label.new()
	title.text = "跑道外观"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UI_MUTED)
	info.add_child(title)

	var value := Label.new()
	value.name = "RoadStyleValue"
	value.text = Global.get_runner_road_style_label()
	value.add_theme_font_size_override("font_size", 22)
	value.add_theme_color_override("font_color", UI_CYAN)
	info.add_child(value)

	var btn := Button.new()
	btn.text = "切换"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(140, 64)
	btn.add_theme_font_size_override("font_size", 20)
	btn.pressed.connect(func():
		Global.cycle_runner_road_style()
		value.text = Global.get_runner_road_style_label()
		_show_toast("跑道外观：%s" % Global.get_runner_road_style_label())
	)
	row.add_child(btn)


func _add_home_start_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 112)
	# flat=true 会隐藏底板，导致只剩深色字贴在背景上
	button.flat = false

	var normal_tex := _load_header_texture(FINAL_BTN_NORMAL)
	var pressed_tex := _load_header_texture(FINAL_BTN_PRESSED)
	var disabled_tex := _load_header_texture(FINAL_BTN_DISABLED)
	if normal_tex:
		button.add_theme_stylebox_override("normal", _style_texture(normal_tex, 100, 36, 100, 36, 24, 16, 24, 16))
		button.add_theme_stylebox_override("hover", _style_texture(normal_tex, 100, 36, 100, 36, 24, 16, 24, 16))
		button.add_theme_stylebox_override(
			"pressed",
			_style_texture(pressed_tex if pressed_tex else normal_tex, 100, 36, 100, 36, 24, 16, 24, 16)
		)
		button.add_theme_stylebox_override(
			"disabled",
			_style_texture(disabled_tex if disabled_tex else normal_tex, 100, 36, 100, 36, 24, 16, 24, 16)
		)
	else:
		button.add_theme_stylebox_override("normal", _style(Color(0.86, 0.62, 0.22), Color(0.96, 0.82, 0.42), 2, 10))
		button.add_theme_stylebox_override("hover", _style(Color(0.92, 0.70, 0.28), Color(0.98, 0.88, 0.52), 2, 10))
		button.add_theme_stylebox_override("pressed", _style(Color(0.72, 0.48, 0.14), Color(0.88, 0.70, 0.32), 2, 10))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	button.add_theme_color_override("font_hover_color", Color(0, 0, 0, 0))
	button.add_theme_color_override("font_pressed_color", Color(0, 0, 0, 0))

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	button.add_child(row)

	var run_icon := TextureRect.new()
	run_icon.custom_minimum_size = Vector2(40, 40)
	run_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	run_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	run_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var run_tex := _load_header_texture(FINAL_ICON_RUN)
	if run_tex:
		run_icon.texture = run_tex
	row.add_child(run_icon)

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color(0.12, 0.08, 0.04))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)

	var arrow_icon := TextureRect.new()
	arrow_icon.custom_minimum_size = Vector2(36, 36)
	arrow_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	arrow_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	arrow_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var arrow_tex := _load_header_texture(FINAL_ICON_ARROW)
	if arrow_tex:
		arrow_icon.texture = arrow_tex
	row.add_child(arrow_icon)

	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _apply_final_progress_bar(bar: ProgressBar) -> void:
	var track := _load_header_texture(FINAL_PROGRESS_TRACK)
	var fill := _load_header_texture(FINAL_PROGRESS_FILL)
	if track and fill:
		bar.add_theme_stylebox_override("background", _style_texture(track, 12, 4, 12, 4, 0, 0, 0, 0))
		bar.add_theme_stylebox_override("fill", _style_texture(fill, 12, 4, 12, 4, 0, 0, 0, 0))
	else:
		_apply_progress_bar_theme(bar, 18, UI_ORANGE)


func _style_texture(
	tex: Texture2D,
	ml: int,
	mt: int,
	mr: int,
	mb: int,
	cl: int = 0,
	ct: int = 0,
	cr: int = 0,
	cb: int = 0
) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = tex
	style.texture_margin_left = float(ml)
	style.texture_margin_top = float(mt)
	style.texture_margin_right = float(mr)
	style.texture_margin_bottom = float(mb)
	style.content_margin_left = float(cl)
	style.content_margin_top = float(ct)
	style.content_margin_right = float(cr)
	style.content_margin_bottom = float(cb)
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.draw_center = true
	return style


func _build_map_page() -> void:
	_add_map_list_header()
	var progress := _get_planet_mission_progress("glass_desert")
	var purify_pct := _get_purification_percent("glass_desert")
	_add_map_list_card({
		"index": "01",
		"planet_id": "glass_desert",
		"title": "Map 1 — Endless Glass Desert",
		"chapter": "Chapter 1: Endless Glass Desert",
		"unlocked": true,
		"progress": progress,
		"purify_pct": purify_pct,
		"tint": UI_ORANGE,
	})
	_add_map_list_card({
		"index": "02",
		"planet_id": "",
		"title": "Map 2 — Ashwind Corridor",
		"chapter": "Chapter 2",
		"unlocked": false,
		"lock_hint": "Unlock after fully exploring\nEndless Glass Desert",
		"tint": Color(0.28, 0.48, 0.36),
	})
	_add_map_list_card({
		"index": "03",
		"planet_id": "",
		"title": "Map 3 — Ember Deep",
		"chapter": "Chapter 3",
		"unlocked": false,
		"lock_hint": "Unlock after clearing Ashwind Corridor",
		"tint": Color(0.42, 0.30, 0.55),
	})
	_add_muted_label(_page_box, "ⓘ  Complete the current map to unlock the next region")


func _add_map_list_header() -> void:
	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	_page_box.add_child(header)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)
	header.add_child(title_row)

	var compass := Label.new()
	compass.text = "🧭"
	compass.add_theme_font_size_override("font_size", 28)
	title_row.add_child(compass)

	var title := Label.new()
	title.text = "MAP LIST"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", UI_TEXT)
	title_row.add_child(title)

	var choose_row := HBoxContainer.new()
	choose_row.alignment = BoxContainer.ALIGNMENT_CENTER
	choose_row.add_theme_constant_override("separation", 10)
	header.add_child(choose_row)
	choose_row.add_child(_make_rule_line())
	var choose := Label.new()
	choose.text = "Choose a Region"
	choose.add_theme_font_size_override("font_size", 14)
	choose.add_theme_color_override("font_color", UI_MUTED)
	choose_row.add_child(choose)
	choose_row.add_child(_make_rule_line())

	var series := Label.new()
	series.text = "EMBER RUNNERS — DAWNLINE"
	series.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	series.add_theme_font_size_override("font_size", 13)
	series.add_theme_color_override("font_color", UI_ORANGE)
	header.add_child(series)


func _make_rule_line() -> ColorRect:
	var line := ColorRect.new()
	line.custom_minimum_size = Vector2(48, 1)
	line.color = Color(0.42, 0.38, 0.32, 0.75)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return line


func _add_map_list_card(data: Dictionary) -> void:
	var unlocked := bool(data.get("unlocked", false))
	var tint: Color = UI_ORANGE
	if data.has("tint") and data["tint"] is Color:
		tint = data["tint"] as Color
	var border := Color(0.98, 0.62, 0.18, 0.95) if unlocked else Color(0.35, 0.32, 0.28, 0.85)
	var fill := Color(0.07, 0.06, 0.05, 0.98)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 248)
	var frame := _style(fill, border, 3 if unlocked else 1, 4)
	frame.shadow_color = Color(0.98, 0.55, 0.12, 0.28) if unlocked else Color(0, 0, 0, 0.35)
	frame.shadow_size = 8 if unlocked else 2
	frame.content_margin_left = 0
	frame.content_margin_right = 0
	frame.content_margin_top = 0
	frame.content_margin_bottom = 0
	panel.add_theme_stylebox_override("panel", frame)
	_page_box.add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	panel.add_child(row)

	# —— 左侧预览 ——
	var thumb := Control.new()
	thumb.custom_minimum_size = Vector2(300, 248)
	thumb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	thumb.clip_contents = true
	row.add_child(thumb)

	var thumb_fill := ColorRect.new()
	thumb_fill.set_anchors_preset(Control.PRESET_FULL_RECT)
	thumb_fill.color = Color(0.08, 0.07, 0.06)
	thumb_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thumb.add_child(thumb_fill)

	var preview_path := ""
	if unlocked:
		if ResourceLoader.exists(MAPLIST_PREVIEW_01) and String(data.get("planet_id", "")) in ["", "glass_desert"]:
			preview_path = MAPLIST_PREVIEW_01
		else:
			var cfg: Script = PlanetDatabase.get_runner_config(String(data.get("planet_id", "glass_desert")))
			if cfg.has_method("get_home_map_preview_path"):
				preview_path = String(cfg.get_home_map_preview_path())
		if preview_path == "" or not ResourceLoader.exists(preview_path):
			preview_path = MAP_PREVIEW_FALLBACK
		if ResourceLoader.exists(preview_path):
			var image := TextureRect.new()
			image.texture = load(preview_path) as Texture2D
			image.set_anchors_preset(Control.PRESET_FULL_RECT)
			image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			image.mouse_filter = Control.MOUSE_FILTER_IGNORE
			thumb.add_child(image)
	else:
		var dim := ColorRect.new()
		dim.set_anchors_preset(Control.PRESET_FULL_RECT)
		dim.color = Color(0.04, 0.04, 0.05, 0.72)
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb.add_child(dim)
		var lock_mark := Label.new()
		lock_mark.text = "LOCKED"
		lock_mark.set_anchors_preset(Control.PRESET_CENTER)
		lock_mark.offset_left = -60
		lock_mark.offset_right = 60
		lock_mark.offset_top = -16
		lock_mark.offset_bottom = 16
		lock_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_mark.add_theme_font_size_override("font_size", 22)
		lock_mark.add_theme_color_override("font_color", tint.lightened(0.15))
		lock_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb.add_child(lock_mark)

	# 顶部：菱形序号 + UNLOCKED 横幅
	var badge_row := HBoxContainer.new()
	badge_row.position = Vector2(10, 10)
	badge_row.add_theme_constant_override("separation", 0)
	badge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thumb.add_child(badge_row)

	var index_wrap := Control.new()
	index_wrap.custom_minimum_size = Vector2(44, 44)
	index_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_row.add_child(index_wrap)

	var diamond_tex := _load_header_texture(MAPLIST_BADGE_DIAMOND)
	if diamond_tex:
		var diamond := TextureRect.new()
		diamond.texture = diamond_tex
		diamond.set_anchors_preset(Control.PRESET_FULL_RECT)
		diamond.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		diamond.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
		index_wrap.add_child(diamond)
	else:
		var diamond_bg := PanelContainer.new()
		diamond_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		diamond_bg.add_theme_stylebox_override("panel", _style(UI_ORANGE, UI_ORANGE_BORDER, 1, 4))
		diamond_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		index_wrap.add_child(diamond_bg)

	var index_badge := Label.new()
	index_badge.text = String(data.get("index", "01"))
	index_badge.set_anchors_preset(Control.PRESET_FULL_RECT)
	index_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	index_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	index_badge.add_theme_font_size_override("font_size", 15)
	index_badge.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55) if unlocked else UI_MUTED)
	index_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	index_wrap.add_child(index_badge)

	var state_badge := Label.new()
	state_badge.text = "  UNLOCKED  " if unlocked else "  LOCKED  "
	state_badge.custom_minimum_size = Vector2(0, 28)
	state_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	state_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state_badge.add_theme_font_size_override("font_size", 12)
	state_badge.add_theme_color_override("font_color", UI_ORANGE_BORDER if unlocked else UI_MUTED)
	var state_style := _style(Color(0.05, 0.04, 0.03, 0.82), border, 1, 0)
	state_style.content_margin_left = 10
	state_style.content_margin_right = 14
	state_style.content_margin_top = 4
	state_style.content_margin_bottom = 4
	state_badge.add_theme_stylebox_override("normal", state_style)
	state_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_row.add_child(state_badge)

	# —— 右侧信息面板 ——
	var info_panel := PanelContainer.new()
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var info_style := _style(Color(0.08, 0.07, 0.06, 0.98), Color(0.28, 0.22, 0.14, 0.55), 0, 0)
	info_style.content_margin_left = 16
	info_style.content_margin_right = 16
	info_style.content_margin_top = 14
	info_style.content_margin_bottom = 14
	info_panel.add_theme_stylebox_override("panel", info_style)
	row.add_child(info_panel)

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 10)
	info_panel.add_child(info)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	info.add_child(title_row)

	var title := Label.new()
	title.text = String(data.get("title", "Map"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.96, 0.86, 0.58) if unlocked else UI_MUTED)
	title_row.add_child(title)

	if unlocked:
		var open_badge := Label.new()
		open_badge.text = " OPEN › "
		open_badge.add_theme_font_size_override("font_size", 12)
		open_badge.add_theme_color_override("font_color", UI_OPEN_GREEN)
		var open_style := _style(UI_OPEN_GREEN_BG, Color(0.30, 0.55, 0.28, 0.9), 1, 3)
		open_style.content_margin_left = 8
		open_style.content_margin_right = 8
		open_style.content_margin_top = 4
		open_style.content_margin_bottom = 4
		open_badge.add_theme_stylebox_override("normal", open_style)
		open_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		title_row.add_child(open_badge)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 1)
	divider.color = Color(0.45, 0.34, 0.18, 0.55)
	info.add_child(divider)

	if unlocked:
		var progress: Dictionary = {}
		if data.get("progress") is Dictionary:
			progress = data["progress"] as Dictionary
		var purify_pct := int(data.get("purify_pct", 0))

		var stats := HBoxContainer.new()
		stats.add_theme_constant_override("separation", 0)
		stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(stats)

		stats.add_child(_build_map_stat_block(
			MAPLIST_ICON_OUTPOST,
			"OUTPOSTS LIT",
			"%d/%d" % [int(progress.get("completed", 0)), int(progress.get("total", 0))]
		))

		var vline := ColorRect.new()
		vline.custom_minimum_size = Vector2(1, 48)
		vline.color = Color(0.45, 0.34, 0.18, 0.45)
		vline.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		stats.add_child(vline)

		stats.add_child(_build_map_stat_block(
			MAPLIST_ICON_PURIFY,
			"PURIFICATION",
			"%d%%" % purify_pct
		))

		var chapter_row := HBoxContainer.new()
		chapter_row.add_theme_constant_override("separation", 8)
		info.add_child(chapter_row)

		var chapter_icon := TextureRect.new()
		chapter_icon.custom_minimum_size = Vector2(22, 22)
		chapter_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		chapter_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		chapter_icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		var chapter_tex := _load_header_texture(MAPLIST_ICON_CHAPTER)
		if chapter_tex:
			chapter_icon.texture = chapter_tex
		chapter_row.add_child(chapter_icon)

		var chapter_box := VBoxContainer.new()
		chapter_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chapter_box.add_theme_constant_override("separation", 1)
		chapter_row.add_child(chapter_box)

		var chapter_label := Label.new()
		chapter_label.text = "CHAPTER PROGRESS"
		chapter_label.add_theme_font_size_override("font_size", 11)
		chapter_label.add_theme_color_override("font_color", UI_MUTED)
		chapter_box.add_child(chapter_label)

		var chapter_name := Label.new()
		chapter_name.text = String(data.get("chapter", ""))
		chapter_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chapter_name.add_theme_font_size_override("font_size", 14)
		chapter_name.add_theme_color_override("font_color", UI_ORANGE)
		chapter_box.add_child(chapter_name)

		var spacer := Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		info.add_child(spacer)

		var enter := Button.new()
		enter.text = "ENTER MAP  >"
		enter.focus_mode = Control.FOCUS_NONE
		enter.custom_minimum_size = Vector2(0, 52)
		enter.add_theme_font_size_override("font_size", 18)
		enter.add_theme_color_override("font_color", Color(1.0, 0.86, 0.45))
		enter.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.65))
		enter.add_theme_color_override("font_pressed_color", UI_ORANGE)
		var enter_n := _style(Color(0.14, 0.09, 0.04, 0.98), Color(0.98, 0.62, 0.18), 2, 4)
		var enter_h := _style(Color(0.20, 0.12, 0.05, 0.98), Color(1.0, 0.78, 0.36), 2, 4)
		var enter_p := _style(Color(0.10, 0.06, 0.03, 0.98), UI_ORANGE, 2, 4)
		enter_n.shadow_color = Color(0.98, 0.50, 0.10, 0.35)
		enter_n.shadow_size = 6
		enter.add_theme_stylebox_override("normal", enter_n)
		enter.add_theme_stylebox_override("hover", enter_h)
		enter.add_theme_stylebox_override("pressed", enter_p)
		enter.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		enter.pressed.connect(_open_planet_map.bind(String(data.get("planet_id", "glass_desert"))))
		info.add_child(enter)
	else:
		var spacer := Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		info.add_child(spacer)
		var lock_hint := Label.new()
		lock_hint.text = String(data.get("lock_hint", "Locked"))
		lock_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lock_hint.add_theme_font_size_override("font_size", 15)
		lock_hint.add_theme_color_override("font_color", tint.lightened(0.2))
		info.add_child(lock_hint)
		var spacer2 := Control.new()
		spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
		info.add_child(spacer2)


func _build_map_stat_block(icon_path: String, label_text: String, value_text: String) -> Control:
	var wrap := HBoxContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.add_theme_constant_override("separation", 8)
	wrap.alignment = BoxContainer.ALIGNMENT_CENTER

	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_theme_constant_override("margin_left", 8)
	pad.add_theme_constant_override("margin_right", 8)
	pad.add_theme_constant_override("margin_top", 2)
	pad.add_theme_constant_override("margin_bottom", 2)
	wrap.add_child(pad)

	var inner := HBoxContainer.new()
	inner.add_theme_constant_override("separation", 8)
	pad.add_child(inner)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var tex := _load_header_texture(icon_path)
	if tex:
		icon.texture = tex
	inner.add_child(icon)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 0)
	inner.add_child(box)

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", UI_MUTED)
	box.add_child(label)

	var value := Label.new()
	value.text = value_text
	value.add_theme_font_size_override("font_size", 22)
	value.add_theme_color_override("font_color", Color(0.98, 0.84, 0.42))
	box.add_child(value)
	return wrap


func _build_tasks_page() -> void:
	var missions: Array[Dictionary] = []
	for planet in _get_playable_planets():
		var planet_id := String(planet["id"])
		var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
		for mission in cfg.get_location_missions():
			missions.append({"planet": planet, "mission": mission})
	missions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["mission"].get("order", 999)) < int(b["mission"].get("order", 999))
	)
	var completed_count := 0
	var available_count := 0
	for entry in missions:
		var planet_id := String(entry["planet"]["id"])
		var location_id := String(entry["mission"].get("location_id", ""))
		if Global.get_completed_runner_locations(planet_id).has(location_id):
			completed_count += 1
		elif Global.get_revealed_exploration_locations(planet_id, ["dome"]).has(location_id):
			available_count += 1
	_add_lead_panel(
		"运输任务",
		"共 %d 条主线 · 可接取 %d · 已完成 %d" % [missions.size(), available_count, completed_count]
	)
	for entry in missions:
		_add_mission_card(entry["planet"], entry["mission"])


func _build_character_page() -> void:
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	if not CharacterRoster.is_unlocked(_selected_character_id, unlocked):
		_selected_character_id = CharacterRoster.CHAR_ELSA
	var character: Dictionary = CharacterRoster.get_character(_selected_character_id)

	_page_box.add_theme_constant_override("separation", 18)
	_add_character_profile_card(character, snapshot)
	_add_character_identity_block(character, snapshot)
	_add_character_story_entry(character)
	_add_character_performance(character, snapshot)
	_add_character_trait_card(character)
	_add_section_title("属性升级")
	_add_stat_upgrade_card(CharacterProgression.STAT_CARGO_GUARD, int(snapshot["cargo_guard_level"]))
	_add_stat_upgrade_card(CharacterProgression.STAT_COIN_BONUS, int(snapshot["coin_bonus_level"]))
	_add_stat_upgrade_card(CharacterProgression.STAT_MOBILITY, int(snapshot["mobility_level"]))
	_add_section_title("飞船")
	for ship in PlanetDatabase.SHIPS:
		var ship_id := String(ship["id"])
		var selected := ship_id == Global.selected_ship_id
		var card := _add_card(
			String(ship["name"]),
			"%s\n%s" % [String(ship["role"]), String(ship["path"])],
			Color(0.10, 0.14, 0.20, 0.98) if selected else UI_PANEL,
			UI_CYAN if selected else UI_PANEL_BORDER
		)
		if selected:
			_add_status_badge(card, "当前飞船", UI_CYAN)
		else:
			_add_button_to(card, "设为当前飞船", _select_ship.bind(ship_id))


func _add_character_profile_card(character: Dictionary, snapshot: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 520)
	panel.add_theme_stylebox_override("panel", _style(Color(0.06, 0.07, 0.09, 0.96), Color(0.82, 0.64, 0.34, 0.9), 2, 12))
	_page_box.add_child(panel)

	var root := Control.new()
	root.custom_minimum_size = Vector2(0, 520)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(root)

	# 暖色底板（与立绘光晕接近，COVERED 裁切时边缘不露黑）
	var stage := ColorRect.new()
	stage.color = Color(0.22, 0.14, 0.08, 1.0)
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(stage)

	var hero := TextureRect.new()
	hero.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hero.offset_left = 4
	hero.offset_top = 4
	hero.offset_right = -4
	hero.offset_bottom = -4
	hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# 铺满卡片：按比例放大裁切，消除左右黑边
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hero_tex := CharacterRoster.load_texture(String(character.get("hero_path", "")))
	if hero_tex == null:
		hero_tex = CharacterRoster.load_texture(String(character.get("portrait_path", "")))
	if hero_tex:
		hero.texture = hero_tex
	else:
		hero.modulate = Color(0.18, 0.16, 0.12)
	root.add_child(hero)

	var tag := Label.new()
	tag.text = "RUNNER PROFILE"
	tag.position = Vector2(20, 18)
	tag.add_theme_font_size_override("font_size", 14)
	tag.add_theme_color_override("font_color", Color(0.92, 0.86, 0.72))
	tag.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	tag.add_theme_constant_override("shadow_offset_x", 1)
	tag.add_theme_constant_override("shadow_offset_y", 1)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(tag)

	var switch_hint := Label.new()
	switch_hint.text = "左右切换"
	switch_hint.anchor_left = 1.0
	switch_hint.anchor_right = 1.0
	switch_hint.offset_left = -160
	switch_hint.offset_right = -20
	switch_hint.offset_top = 16
	switch_hint.offset_bottom = 44
	switch_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	switch_hint.add_theme_font_size_override("font_size", 14)
	switch_hint.add_theme_color_override("font_color", Color(0.92, 0.86, 0.72, 0.85))
	switch_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(switch_hint)

	# 立绘两侧：左/右切换（对齐设计稿红框位置）
	root.add_child(_make_character_swipe_button(false))
	root.add_child(_make_character_swipe_button(true))

	var unlock_hint := Label.new()
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	var rook_unlocked := CharacterRoster.is_unlocked(CharacterRoster.CHAR_ROOK, unlocked)
	unlock_hint.text = "可切换 Elsa / Rook" if rook_unlocked else "完成居民穹顶后解锁 Rook"
	unlock_hint.anchor_top = 1.0
	unlock_hint.anchor_bottom = 1.0
	unlock_hint.anchor_right = 1.0
	unlock_hint.offset_left = 20
	unlock_hint.offset_right = -20
	unlock_hint.offset_top = -42
	unlock_hint.offset_bottom = -14
	unlock_hint.add_theme_font_size_override("font_size", 14)
	unlock_hint.add_theme_color_override("font_color", Color(0.82, 0.84, 0.88, 0.9))
	unlock_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(unlock_hint)


func _make_character_swipe_button(go_next: bool) -> Button:
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.flat = false
	btn.text = "›" if go_next else "‹"
	btn.custom_minimum_size = Vector2(56, 88)
	btn.anchor_top = 0.5
	btn.anchor_bottom = 0.5
	if go_next:
		btn.anchor_left = 1.0
		btn.anchor_right = 1.0
		btn.offset_left = -72
		btn.offset_right = -12
	else:
		btn.anchor_left = 0.0
		btn.anchor_right = 0.0
		btn.offset_left = 12
		btn.offset_right = 72
	btn.offset_top = -44
	btn.offset_bottom = 44
	var normal := _style(Color(0.08, 0.09, 0.11, 0.72), Color(0.82, 0.64, 0.34, 0.75), 2, 12)
	var hover := _style(Color(0.14, 0.12, 0.08, 0.88), Color(0.94, 0.78, 0.42, 0.95), 2, 12)
	var pressed := _style(Color(0.05, 0.06, 0.07, 0.9), Color(0.68, 0.52, 0.28, 0.9), 2, 12)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_font_size_override("font_size", 40)
	btn.add_theme_color_override("font_color", Color(0.96, 0.90, 0.72))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.78))
	btn.add_theme_color_override("font_pressed_color", Color(0.86, 0.74, 0.48))
	btn.pressed.connect(_cycle_character.bind(1 if go_next else -1))
	return btn


func _add_character_identity_block(character: Dictionary, snapshot: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_box.add_child(row)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 4)
	row.add_child(left)

	var name_label := Label.new()
	name_label.text = String(character.get("name_en", character.get("name", "ELSA")))
	name_label.add_theme_font_size_override("font_size", 44)
	name_label.add_theme_color_override("font_color", Color(0.98, 0.97, 0.94))
	left.add_child(name_label)

	var title := Label.new()
	title.text = String(character.get("title", snapshot.get("title", "信使")))
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.90, 0.74, 0.42))
	left.add_child(title)

	var right := VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.custom_minimum_size = Vector2(220, 0)
	row.add_child(right)

	var level_label := Label.new()
	level_label.text = "RUNNER LEVEL %d" % int(snapshot["level"])
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	level_label.add_theme_font_size_override("font_size", 16)
	level_label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.92))
	right.add_child(level_label)

	var xp_need := int(snapshot["xp_to_next"])
	var xp_into := int(snapshot["xp_into_level"])
	var xp_label := Label.new()
	if xp_need <= 0:
		xp_label.text = "MAX"
	else:
		xp_label.text = "%s / %s XP" % [_format_count(xp_into), _format_count(xp_need)]
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	xp_label.add_theme_font_size_override("font_size", 14)
	xp_label.add_theme_color_override("font_color", UI_MUTED)
	right.add_child(xp_label)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(220, 12)
	bar.show_percentage = false
	bar.max_value = float(maxi(xp_need, 1))
	bar.value = float(xp_into if xp_need > 0 else 1)
	_apply_final_progress_bar(bar)
	right.add_child(bar)


func _add_character_story_entry(character: Dictionary) -> void:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.flat = false
	button.custom_minimum_size = Vector2(0, 72)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _style(Color(0.07, 0.08, 0.10, 0.96), Color(0.78, 0.62, 0.34, 0.88), 2, 10))
	button.add_theme_stylebox_override("hover", _style(Color(0.10, 0.11, 0.13, 0.98), Color(0.92, 0.74, 0.40, 0.95), 2, 10))
	button.add_theme_stylebox_override("pressed", _style(Color(0.05, 0.06, 0.08, 0.98), Color(0.68, 0.52, 0.28, 0.9), 2, 10))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color(0, 0, 0, 0))
	button.pressed.connect(_show_character_story.bind(String(character.get("id", CharacterRoster.CHAR_ELSA))))
	_page_box.add_child(button)

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(row)

	var pad_l := Control.new()
	pad_l.custom_minimum_size = Vector2(18, 0)
	row.add_child(pad_l)

	var title := Label.new()
	title.text = "📖  角色故事"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.94, 0.90))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(title)

	var action := Label.new()
	action.text = "阅读档案  ›"
	action.add_theme_font_size_override("font_size", 18)
	action.add_theme_color_override("font_color", Color(0.90, 0.76, 0.46))
	action.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(action)

	var pad_r := Control.new()
	pad_r.custom_minimum_size = Vector2(18, 0)
	row.add_child(pad_r)


func _add_character_performance(character: Dictionary, snapshot: Dictionary) -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	_page_box.add_child(header)

	var title := Label.new()
	title.text = "性能概览"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", UI_TEXT)
	header.add_child(title)

	var bonus := Label.new()
	bonus.text = "等级加成 · 星火币 %s" % String(snapshot.get("coin_bonus_text", "+0%"))
	bonus.add_theme_font_size_override("font_size", 14)
	bonus.add_theme_color_override("font_color", Color(0.90, 0.76, 0.42))
	header.add_child(bonus)

	var stats: Array = character.get("stats", [])
	for stat in stats:
		_add_character_stat_row(String(stat.get("label", "")), String(stat.get("value", "")), float(stat.get("fill", 0.5)))


func _add_character_stat_row(label_text: String, value_text: String, fill_ratio: float) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color(0.07, 0.08, 0.10, 0.94), Color(0.28, 0.30, 0.34, 0.7), 1, 8))
	_page_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var name_label := Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size = Vector2(110, 0)
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.92, 0.93, 0.95))
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.text = value_text
	value_label.custom_minimum_size = Vector2(70, 0)
	value_label.add_theme_font_size_override("font_size", 18)
	value_label.add_theme_color_override("font_color", Color(0.96, 0.84, 0.48))
	row.add_child(value_label)

	var bar := ProgressBar.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size = Vector2(0, 14)
	bar.show_percentage = false
	bar.max_value = 1.0
	bar.value = clampf(fill_ratio, 0.0, 1.0)
	_apply_final_progress_bar(bar)
	row.add_child(bar)


func _add_character_trait_card(character: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color(0.07, 0.09, 0.11, 0.96), Color(0.34, 0.52, 0.58, 0.75), 1, 10))
	_page_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(64, 64)
	badge.add_theme_stylebox_override("panel", _style(Color(0.12, 0.28, 0.32, 0.95), Color(0.42, 0.78, 0.82, 0.8), 1, 10))
	row.add_child(badge)
	var badge_label := Label.new()
	badge_label.text = "↗"
	badge_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_label.add_theme_font_size_override("font_size", 28)
	badge_label.add_theme_color_override("font_color", Color(0.82, 0.96, 0.98))
	badge.add_child(badge_label)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 4)
	row.add_child(text)

	var title := Label.new()
	title.text = "%s · %s" % [String(character.get("trait_name", "")), String(character.get("trait_gear", ""))]
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", UI_TEXT)
	text.add_child(title)

	var desc := Label.new()
	desc.text = String(character.get("trait_desc", ""))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 15)
	desc.add_theme_color_override("font_color", UI_MUTED)
	text.add_child(desc)

	var tag := Label.new()
	tag.text = String(character.get("trait_tag", ""))
	tag.add_theme_font_size_override("font_size", 13)
	tag.add_theme_color_override("font_color", Color(0.56, 0.78, 0.82))
	text.add_child(tag)


func _cycle_character(direction: int = 1) -> void:
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	var next_id := (
		CharacterRoster.next_unlocked_id(_selected_character_id, unlocked)
		if direction >= 0
		else CharacterRoster.prev_unlocked_id(_selected_character_id, unlocked)
	)
	if next_id == _selected_character_id:
		if not CharacterRoster.is_unlocked(CharacterRoster.CHAR_ROOK, unlocked):
			_show_toast("完成居民穹顶运输后解锁 Rook")
		return
	_selected_character_id = next_id
	_show_toast("已切换至 %s" % String(CharacterRoster.get_character(next_id).get("name", next_id)))
	_show_tab(TAB_CHARACTER, true)


func _show_character_story(character_id: String) -> void:
	if _character_story_overlay:
		_character_story_overlay.queue_free()
		_character_story_overlay = null

	_selected_character_id = character_id
	var character: Dictionary = CharacterRoster.get_character(character_id)
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_root.add_child(root)
	_character_story_overlay = root

	var bg := ColorRect.new()
	bg.color = Color(0.059, 0.082, 0.125, 1.0) # #0F1520
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 24)
	root.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)

	# —— 顶栏：返回 + 标题 ——
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	column.add_child(top)

	var back := Button.new()
	back.text = "‹"
	back.focus_mode = Control.FOCUS_NONE
	back.flat = true
	back.custom_minimum_size = Vector2(48, 48)
	back.add_theme_font_size_override("font_size", 34)
	back.add_theme_color_override("font_color", Color(0.94, 0.92, 0.88))
	back.pressed.connect(_close_character_story)
	top.add_child(back)

	var top_title := Label.new()
	top_title.text = "信使故事  RUNNER STORY"
	top_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_title.add_theme_font_size_override("font_size", 22)
	top_title.add_theme_color_override("font_color", Color(0.94, 0.93, 0.90))
	top.add_child(top_title)

	var top_spacer := Control.new()
	top_spacer.custom_minimum_size = Vector2(48, 0)
	top.add_child(top_spacer)

	# —— 身份：圆形徽章 + 名 + 等级 ——
	var identity := HBoxContainer.new()
	identity.add_theme_constant_override("separation", 16)
	identity.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	column.add_child(identity)

	var badge_wrap := Control.new()
	badge_wrap.custom_minimum_size = Vector2(72, 72)
	badge_wrap.clip_contents = true
	identity.add_child(badge_wrap)
	var badge := Panel.new()
	badge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.clip_contents = true
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.545, 0.435, 0.263) # #8B6F43
	badge_style.set_corner_radius_all(999)
	badge_style.anti_aliasing = true
	badge_style.set_border_width_all(0)
	badge_style.set_content_margin_all(0)
	badge.add_theme_stylebox_override("panel", badge_style)
	badge_wrap.add_child(badge)
	var badge_label := Label.new()
	badge_label.text = String(character.get("badge", "?"))
	badge_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_label.add_theme_font_size_override("font_size", 28)
	badge_label.add_theme_color_override("font_color", Color(0.98, 0.96, 0.92))
	badge_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_wrap.add_child(badge_label)

	var id_text := HBoxContainer.new()
	id_text.alignment = BoxContainer.ALIGNMENT_CENTER
	id_text.add_theme_constant_override("separation", 12)
	id_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	identity.add_child(id_text)
	var name_label := Label.new()
	name_label.text = String(character.get("name_en", "ELSA"))
	name_label.add_theme_font_size_override("font_size", 36)
	name_label.add_theme_color_override("font_color", Color(0.98, 0.97, 0.94))
	id_text.add_child(name_label)
	var lv := Label.new()
	lv.text = "Lv.%d" % int(snapshot["level"])
	lv.add_theme_font_size_override("font_size", 20)
	lv.add_theme_color_override("font_color", Color(0.83, 0.65, 0.45))
	lv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	id_text.add_child(lv)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)

	var story_box := VBoxContainer.new()
	story_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	story_box.add_theme_constant_override("separation", 20)
	scroll.add_child(story_box)

	# 01 在上、02 在下，纵向排列（勿重叠）
	_add_story_section_header(story_box, String(character.get("section_why", "WHY SHE RUNS")), "01")
	_add_story_comic_block(story_box, character)
	_add_story_section_header(story_box, "BACKGROUND · 背景故事", "02")
	_add_story_text_panel(story_box, character)


func _add_story_section_header(parent: Control, title: String, index_text: String) -> void:
	# 设计稿：标题 + 细金线 + 序号（金线固定 2px，禁止被 HBox 纵向拉高）
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(row)

	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.83, 0.65, 0.45)) # #D4A574
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)

	var line_wrap := Control.new()
	line_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_wrap.custom_minimum_size = Vector2(24, 2)
	line_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(line_wrap)
	var line := ColorRect.new()
	line.color = Color(0.83, 0.65, 0.45, 0.95)
	line.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_wrap.add_child(line)

	var index := Label.new()
	index.text = index_text
	index.add_theme_font_size_override("font_size", 17)
	index.add_theme_color_override("font_color", Color(0.72, 0.74, 0.78))
	index.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(index)


func _add_story_comic_block(parent: Control, character: Dictionary) -> void:
	# 01：方形插画。Scroll 内不用 AspectRatioContainer（高度会变成 0 导致与 02 重叠）
	var side := maxf(MOBILE_VIEWPORT_SIZE.x - 64.0, 640.0)
	var frame := Control.new()
	frame.custom_minimum_size = Vector2(0, side)
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.clip_contents = true
	parent.add_child(frame)

	var stage := ColorRect.new()
	stage.color = Color(0.10, 0.08, 0.06, 1.0)
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(stage)

	var image := TextureRect.new()
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art := CharacterRoster.load_texture(String(character.get("story_art_path", "")))
	if art == null:
		art = CharacterRoster.load_texture(String(character.get("hero_path", "")))
	if art == null:
		art = CharacterRoster.load_texture(String(character.get("portrait_path", "")))
	if art:
		image.texture = art
		var sz := art.get_size()
		if sz.x > 1.0 and sz.y > 1.0 and absf(sz.x / sz.y - 1.0) > 0.08:
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.add_child(image)

	_add_story_frame_corners(frame, 1.0)

	if not bool(character.get("quote_in_art", false)):
		var quote_panel := PanelContainer.new()
		quote_panel.position = Vector2(56, 20)
		quote_panel.custom_minimum_size = Vector2(560, 0)
		quote_panel.add_theme_stylebox_override(
			"panel",
			_style(Color(0.96, 0.95, 0.93, 0.96), Color(0.12, 0.12, 0.12, 0.85), 1, 10)
		)
		frame.add_child(quote_panel)
		var quote_margin := MarginContainer.new()
		quote_margin.add_theme_constant_override("margin_left", 14)
		quote_margin.add_theme_constant_override("margin_right", 14)
		quote_margin.add_theme_constant_override("margin_top", 10)
		quote_margin.add_theme_constant_override("margin_bottom", 10)
		quote_panel.add_child(quote_margin)
		var quote := Label.new()
		quote.text = String(character.get("quote", ""))
		quote.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		quote.add_theme_font_size_override("font_size", 15)
		quote.add_theme_color_override("font_color", Color(0.12, 0.12, 0.14))
		quote_margin.add_child(quote)


func _add_story_frame_corners(frame: Control, pad: float = 0.0) -> void:
	# 设计稿：左上 / 右下细金 L，贴外框角
	var gold := Color(0.831, 0.647, 0.455, 0.98) # #D4A574
	frame.add_child(_make_l_corner_bracket(false, gold, pad))
	frame.add_child(_make_l_corner_bracket(true, gold, pad))


func _make_l_corner_bracket(bottom_right: bool, color: Color, pad: float = 0.0) -> Control:
	var arm := 28.0
	var thick := 2.0
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.custom_minimum_size = Vector2(arm, arm)
	root.size = Vector2(arm, arm)
	if bottom_right:
		root.anchor_left = 1.0
		root.anchor_top = 1.0
		root.anchor_right = 1.0
		root.anchor_bottom = 1.0
		root.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		root.grow_vertical = Control.GROW_DIRECTION_BEGIN
		root.offset_left = -arm - pad
		root.offset_top = -arm - pad
		root.offset_right = -pad
		root.offset_bottom = -pad
	else:
		root.position = Vector2(pad, pad)

	var h := ColorRect.new()
	h.color = color
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v := ColorRect.new()
	v.color = color
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if bottom_right:
		# ┘：底边 + 右边，贴外框
		h.position = Vector2(0, arm - thick)
		h.size = Vector2(arm, thick)
		v.position = Vector2(arm - thick, 0)
		v.size = Vector2(thick, arm)
	else:
		# ┌：顶边 + 左边，贴外框
		h.position = Vector2.ZERO
		h.size = Vector2(arm, thick)
		v.position = Vector2.ZERO
		v.size = Vector2(thick, arm)
	root.add_child(h)
	root.add_child(v)
	return root


func _add_story_text_panel(parent: Control, character: Dictionary) -> void:
	# 02：圆角文字卡；角标贴外框（StyleBox content_margin 必须为 0）
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.086, 0.118, 0.125, 0.92)
	panel_style.border_color = Color(0.83, 0.65, 0.45, 0.45)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.set_content_margin_all(0)
	panel.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(panel)

	var margin := MarginContainer.new()
	# 给 L 角留出空间，文字不压线
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var paragraphs: Array = character.get("story_paragraphs", [])
	for paragraph in paragraphs:
		var label := Label.new()
		label.text = String(paragraph)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.90, 0.91, 0.93))
		box.add_child(label)

	var overlay := Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(overlay)
	_add_story_frame_corners(overlay, 1.0)


func _close_character_story() -> void:
	if _character_story_overlay:
		_character_story_overlay.queue_free()
		_character_story_overlay = null
	_show_tab(TAB_CHARACTER, true)


func _add_stat_upgrade_card(stat_id: String, current_level: int) -> void:
	var label := String(CharacterProgression.STAT_LABELS.get(stat_id, stat_id))
	var effect := CharacterProgression.stat_percent_text(stat_id, current_level)
	var body := "%s · 当前 Lv.%d / %d · 效果 %s" % [
		label,
		current_level,
		CharacterProgression.MAX_STAT_LEVEL,
		effect,
	]
	var card := _add_card(label, body)
	if current_level >= CharacterProgression.MAX_STAT_LEVEL:
		_add_muted_label(card, "已满级")
		return
	var cost := CharacterProgression.upgrade_cost(stat_id, current_level)
	if cost < 0:
		return
	var can_buy := Global.ember_coins >= cost
	var button := _add_primary_button(card, "升级（%d 星火币）" % cost, _upgrade_messenger_stat.bind(stat_id))
	button.disabled = not can_buy
	if not can_buy:
		_add_muted_label(card, "星火币不足，完成运输可获得更多")


func _upgrade_messenger_stat(stat_id: String) -> void:
	if Global.try_upgrade_messenger_stat(stat_id):
		_show_toast("%s 升级成功" % String(CharacterProgression.STAT_LABELS.get(stat_id, stat_id)))
		_show_tab(TAB_CHARACTER, true, true)
		return
	_show_toast("星火币不足，无法升级")


func _add_mission_card(planet: Dictionary, mission: Dictionary) -> void:
	var planet_id := String(planet["id"])
	var location_id := String(mission.get("location_id", "dome"))
	var completed := Global.get_completed_runner_locations(planet_id).has(location_id)
	var revealed := Global.get_revealed_exploration_locations(planet_id, ["dome"]).has(location_id)
	var is_active := Global.is_active_mission(planet_id, location_id)
	var status := "已完成" if completed else ("进行中" if is_active else ("可接取" if revealed else "待解锁"))
	var border_color := UI_GREEN if completed else (UI_ORANGE if is_active else (Color(0.96, 0.58, 0.22) if revealed else UI_PANEL_BORDER))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color(0.08, 0.10, 0.13, 0.98), border_color, 2, 8))
	_page_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var cargo_texture := _load_mission_cargo_icon(planet_id, mission)
	if cargo_texture:
		var icon_wrap := PanelContainer.new()
		icon_wrap.custom_minimum_size = Vector2(56, 56)
		icon_wrap.add_theme_stylebox_override("panel", _style(Color(0.10, 0.12, 0.16, 0.98), UI_PANEL_BORDER, 1, 6))
		header.add_child(icon_wrap)
		var icon := TextureRect.new()
		icon.texture = cargo_texture
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_wrap.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 2)
	header.add_child(text_box)

	var type_label := Label.new()
	type_label.text = String(mission.get("task_type", "Supply Run"))
	type_label.add_theme_font_size_override("font_size", 15)
	type_label.add_theme_color_override("font_color", UI_TEXT)
	text_box.add_child(type_label)

	var route_label := Label.new()
	route_label.text = "%s → %s" % [
		String(mission.get("source_hearth", String(planet["name"]))),
		String(mission.get("target_hearth", "据点")),
	]
	route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_label.add_theme_font_size_override("font_size", 18)
	route_label.add_theme_color_override("font_color", UI_CYAN)
	text_box.add_child(route_label)

	var cargo_label := Label.new()
	cargo_label.text = "%s × %d · 难度 %d" % [
		String(mission.get("cargo_name", "物资")),
		int(mission.get("cargo_load", 1)),
		int(mission.get("difficulty", 1)),
	]
	cargo_label.add_theme_font_size_override("font_size", 14)
	cargo_label.add_theme_color_override("font_color", UI_MUTED)
	text_box.add_child(cargo_label)

	_add_status_badge(header, status, _status_color(status))

	var story := String(mission.get("story", ""))
	if story != "":
		var story_label := Label.new()
		story_label.text = story
		story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		story_label.add_theme_font_size_override("font_size", 14)
		story_label.add_theme_color_override("font_color", Color(0.68, 0.74, 0.82))
		box.add_child(story_label)

	var reward_row := HBoxContainer.new()
	reward_row.add_theme_constant_override("separation", 16)
	box.add_child(reward_row)
	var coins := 100 + int(mission.get("difficulty", 1)) * 10
	var xp := 20 + int(mission.get("difficulty", 1)) * 5
	var coin_lbl := Label.new()
	coin_lbl.text = "◉ %d" % coins
	coin_lbl.add_theme_font_size_override("font_size", 14)
	coin_lbl.add_theme_color_override("font_color", UI_STATUS)
	reward_row.add_child(coin_lbl)
	var xp_lbl := Label.new()
	xp_lbl.text = "EXP %d" % xp
	xp_lbl.add_theme_font_size_override("font_size", 14)
	xp_lbl.add_theme_color_override("font_color", UI_CYAN)
	reward_row.add_child(xp_lbl)

	# 据点修复进度（与地图详情同源）
	if revealed or completed:
		var repair := _home_repair_progress(planet_id, location_id)
		var repair_lbl := Label.new()
		repair_lbl.text = "据点修复 %d / %d" % [int(repair["current"]), int(repair["total"])]
		repair_lbl.add_theme_font_size_override("font_size", 13)
		repair_lbl.add_theme_color_override("font_color", Color(0.72, 0.76, 0.82))
		box.add_child(repair_lbl)

	if completed:
		_add_muted_label(box, "据点进度 100%")
	elif revealed:
		_add_home_road_style_picker(box)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 8)
		box.add_child(actions)
		var start_btn := _add_primary_button(actions, "开始运输", _start_runner_for_location.bind(planet_id, location_id))
		start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if is_active:
			var home_btn := _add_secondary_button(actions, "回首页", _show_tab.bind(TAB_HOME))
			home_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			var accept_btn := _add_secondary_button(actions, "设为当前", _accept_mission.bind(planet_id, location_id))
			accept_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var map_btn := _add_secondary_button(actions, "查看地图", _open_planet_map.bind(planet_id))
		map_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		_add_muted_label(box, "需要先在地图中点亮据点")


func _add_home_hero(purify_pct: int) -> void:
	var map_path := MAP_PREVIEW_FALLBACK
	var cfg: Script = PlanetDatabase.get_runner_config("glass_desert")
	if cfg.has_method("get_home_map_preview_path"):
		map_path = String(cfg.get_home_map_preview_path())
	var texture: Texture2D = load(map_path) as Texture2D

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(UI_PANEL, UI_FRAME_BORDER, 2, 10))
	_page_box.add_child(panel)

	var root := Control.new()
	root.custom_minimum_size = Vector2(0, 400)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(root)

	if texture:
		var image := TextureRect.new()
		image.texture = texture
		image.set_anchors_preset(Control.PRESET_FULL_RECT)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		root.add_child(image)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.08, 0.42)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)

	var title := Label.new()
	title.text = "ENDLESS GLASS DESERT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 110.0
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", UI_TEXT)
	root.add_child(title)

	var purify_box := VBoxContainer.new()
	purify_box.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	purify_box.offset_bottom = -22.0
	purify_box.add_theme_constant_override("separation", 8)
	root.add_child(purify_box)

	var purify_label := Label.new()
	purify_label.text = "净化度"
	purify_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	purify_label.add_theme_font_size_override("font_size", 14)
	purify_label.add_theme_color_override("font_color", UI_MUTED)
	purify_box.add_child(purify_label)

	var bar_row := HBoxContainer.new()
	bar_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bar_row.add_theme_constant_override("separation", 8)
	purify_box.add_child(bar_row)
	for i in 10:
		var seg := ColorRect.new()
		seg.custom_minimum_size = Vector2(26, 8)
		seg.color = UI_CYAN if i < int(round(float(purify_pct) / 10.0)) else Color(0.16, 0.20, 0.26, 0.72)
		bar_row.add_child(seg)
	var pct := Label.new()
	pct.text = "%d%%" % purify_pct
	pct.add_theme_font_size_override("font_size", 15)
	pct.add_theme_color_override("font_color", UI_CYAN)
	bar_row.add_child(pct)


func _add_recommended_task_card(mission: Dictionary, planet_id: String, location_id: String) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(UI_PANEL, Color(0.96, 0.58, 0.22), 2, 10))
	_page_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var portrait := _load_runner_portrait("glass_desert")
	if portrait:
		var icon_wrap := PanelContainer.new()
		icon_wrap.custom_minimum_size = Vector2(72, 72)
		icon_wrap.clip_contents = true
		icon_wrap.add_theme_stylebox_override("panel", _style(Color(0.10, 0.12, 0.16), UI_PANEL_BORDER, 1, 8))
		row.add_child(icon_wrap)
		var icon := TextureRect.new()
		icon.texture = portrait
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		icon_wrap.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)
	var tag := Label.new()
	tag.text = "推荐任务"
	tag.add_theme_font_size_override("font_size", 13)
	tag.add_theme_color_override("font_color", UI_STATUS)
	text_box.add_child(tag)
	var line1 := Label.new()
	line1.text = "Supply Run · %s" % String(mission.get("target_hearth", "据点"))
	line1.add_theme_font_size_override("font_size", 18)
	line1.add_theme_color_override("font_color", UI_TEXT)
	text_box.add_child(line1)
	var line2 := Label.new()
	line2.text = "%s × %d" % [String(mission.get("cargo_name", "物资")), int(mission.get("cargo_load", 1))]
	line2.add_theme_font_size_override("font_size", 15)
	line2.add_theme_color_override("font_color", UI_MUTED)
	text_box.add_child(line2)

	var play := Button.new()
	play.text = "▶"
	play.custom_minimum_size = Vector2(52, 52)
	play.focus_mode = Control.FOCUS_NONE
	play.add_theme_font_size_override("font_size", 20)
	play.add_theme_stylebox_override("normal", _style(UI_GOLD, UI_GOLD_BORDER, 1, 26))
	play.add_theme_stylebox_override("hover", _style(UI_GOLD.lightened(0.06), UI_GOLD_BORDER, 1, 26))
	play.add_theme_stylebox_override("pressed", _style(UI_GOLD.darkened(0.08), UI_GOLD_BORDER, 1, 26))
	play.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
	play.pressed.connect(_start_runner_for_location.bind(planet_id, location_id))
	row.add_child(play)


func _add_map_preview() -> void:
	var map_path := MAP_PREVIEW_FALLBACK
	var cfg: Script = PlanetDatabase.get_runner_config("glass_desert")
	if cfg.has_method("get_home_map_preview_path"):
		map_path = String(cfg.get_home_map_preview_path())
	var texture: Texture2D = load(map_path)
	if texture == null:
		return
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(UI_PANEL, UI_PANEL_BORDER, 1, 8))
	_page_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var image := TextureRect.new()
	image.texture = texture
	image.custom_minimum_size = Vector2(0, 360)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	margin.add_child(image)


func _add_planet_card(planet: Dictionary) -> void:
	var planet_id := String(planet["id"])
	var locked := not bool(planet.get("unlocked", false))
	var body := "%s\n任务货物：%s\n目标据点：%s\n难度：%s" % [
		String(planet.get("description", "")),
		String(planet.get("cargo", "—")),
		String(planet.get("hearth", "—")),
		str(int(planet.get("difficulty", 0))),
	]
	var card := _add_card(String(planet["name"]), body)
	if locked:
		_add_muted_label(card, "未解锁")
		return
	_add_button_to(card, "进入地图", _open_planet_map.bind(planet_id))
	_add_button_to(card, "开始运输", _start_runner_for_planet.bind(planet_id))


func _add_lead_panel(title: String, body: String) -> void:
	_add_card(title, body, Color(0.09, 0.12, 0.18, 0.98), UI_CYAN)


func _add_section_title(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", UI_MUTED)
	_page_box.add_child(label)


func _add_info_row(label_text: String, value_text: String) -> void:
	_add_card(label_text, value_text, UI_PANEL, UI_PANEL_BORDER)


func _load_mission_cargo_icon(planet_id: String, mission: Dictionary) -> Texture2D:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if not cfg.has_method("get_cargo_icon_path"):
		return null
	var icon_path := String(cfg.get_cargo_icon_path(mission))
	if icon_path == "" or not ResourceLoader.exists(icon_path):
		return null
	return load(icon_path) as Texture2D


func _load_runner_portrait(planet_id: String) -> Texture2D:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if not cfg.has_method("get_runner_portrait_path"):
		return null
	var portrait_path := String(cfg.get_runner_portrait_path())
	if portrait_path == "" or not ResourceLoader.exists(portrait_path):
		return null
	return load(portrait_path) as Texture2D


func _prepend_card_icon(card: VBoxContainer, texture: Texture2D) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(72, 72)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	card.add_child(row)
	card.move_child(row, 0)


func _add_portrait_banner(texture: Texture2D, caption: String) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(UI_PANEL, UI_FRAME_BORDER, 2, 10))
	_page_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(column)

	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(0, 480)
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(icon)

	var caption_label := Label.new()
	caption_label.text = caption
	caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_label.add_theme_font_size_override("font_size", 28)
	caption_label.add_theme_color_override("font_color", UI_TEXT)
	column.add_child(caption_label)


func _add_card(title: String, body: String, fill: Color = UI_PANEL, border: Color = UI_PANEL_BORDER) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(fill, border, 1, 8))
	_page_box.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var title_label := Label.new()
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", UI_TEXT)
	box.add_child(title_label)

	var body_label := Label.new()
	body_label.text = body
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 15)
	body_label.add_theme_color_override("font_color", UI_MUTED)
	box.add_child(body_label)
	return box


func _add_primary_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := _make_gold_button(text)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _add_secondary_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := _make_flat_button(text)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _add_button_to(parent: Control, text: String, callback: Callable) -> Button:
	return _add_primary_button(parent, text, callback)


func _add_muted_label(parent: Control, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", UI_MUTED)
	parent.add_child(label)


func _make_gold_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 64)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_stylebox_override("normal", _style(UI_GOLD, UI_GOLD_BORDER, 2, 10))
	button.add_theme_stylebox_override("hover", _style(UI_GOLD.lightened(0.05), UI_GOLD_BORDER.lightened(0.04), 2, 10))
	button.add_theme_stylebox_override("pressed", _style(UI_GOLD.darkened(0.08), UI_GOLD_BORDER.darkened(0.04), 2, 10))
	button.add_theme_stylebox_override("disabled", _style(UI_GOLD.darkened(0.22), UI_GOLD_BORDER.darkened(0.12), 1, 10))
	button.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
	button.add_theme_color_override("font_disabled_color", Color(0.28, 0.22, 0.16))
	return button


func _make_flat_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 56)
	button.add_theme_font_size_override("font_size", 17)
	_style_flat_button(button)
	return button


func _make_button(text: String, fill: Color, font_color: Color) -> Button:
	# 兼容旧调用：主色填充走金色按钮，其他走钢蓝扁平按钮
	if fill.r > 0.7 and fill.g > 0.4:
		return _make_gold_button(text)
	var button := _make_flat_button(text)
	button.add_theme_color_override("font_color", font_color if font_color.v > 0.4 else UI_TEXT)
	return button


func _style_flat_button(button: Button) -> void:
	var fill := Color(0.10, 0.13, 0.18, 0.96)
	var border := UI_PANEL_BORDER
	button.add_theme_stylebox_override("normal", _style(fill, border, 1, 8))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.06), UI_FRAME_BORDER, 1, 8))
	button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.06), border, 1, 8))
	button.add_theme_stylebox_override("disabled", _style(fill.darkened(0.16), Color(0.18, 0.22, 0.28), 1, 8))
	button.add_theme_color_override("font_color", UI_TEXT)
	button.add_theme_color_override("font_disabled_color", UI_MUTED)


func _ensure_toast_layer() -> void:
	if _toast_panel != null:
		return
	_toast_panel = PanelContainer.new()
	_toast_panel.visible = false
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.add_theme_stylebox_override("panel", _style(UI_FRAME, UI_FRAME_BORDER, 2, 10))
	_ui_root.add_child(_toast_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 12)
	_toast_panel.add_child(margin)

	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_label.custom_minimum_size = Vector2(420, 0)
	_toast_label.add_theme_font_size_override("font_size", 17)
	_toast_label.add_theme_color_override("font_color", UI_TEXT)
	margin.add_child(_toast_label)


func _show_toast(text: String, duration: float = 2.2) -> void:
	_ensure_toast_layer()
	_toast_label.text = text
	_toast_panel.visible = true
	call_deferred("_position_toast")
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_panel.modulate = Color(1, 1, 1, 1)
	_toast_tween.tween_interval(maxf(duration - 0.35, 0.1))
	_toast_tween.tween_property(_toast_panel, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(func(): _toast_panel.visible = false)


func _position_toast() -> void:
	if _toast_panel == null or _ui_root == null:
		return
	var frame := _ui_root.get_global_rect()
	var width := minf(frame.size.x - 48.0, 560.0)
	_toast_panel.custom_minimum_size = Vector2(width, 0)
	_toast_panel.size.x = width
	_toast_panel.global_position = Vector2(
		frame.position.x + (frame.size.x - width) * 0.5,
		frame.position.y + 108.0
	)


func _add_xp_card(snapshot: Dictionary) -> void:
	var card := _add_card(
		"Lv.%d · %s" % [int(snapshot["level"]), String(snapshot["title"])],
		"完成运输获得经验，评级越高奖励越多。"
	)
	var xp_to_next := int(snapshot["xp_to_next"])
	if xp_to_next <= 0:
		_add_muted_label(card, "已达当前版本等级上限")
		return
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 16)
	bar.max_value = xp_to_next
	bar.value = int(snapshot["xp_into_level"])
	bar.show_percentage = false
	_apply_progress_bar_theme(bar, 16)
	card.add_child(bar)
	_add_muted_label(card, "经验 %d / %d" % [int(snapshot["xp_into_level"]), xp_to_next])


func _add_progress_card(title: String, completed: int, total: int, revealed: int, percent_override: int = -1) -> void:
	var percent := percent_override if percent_override >= 0 else int(round(float(completed) / float(maxi(total, 1)) * 100.0))
	var card := _add_card(title, "已完成 %d / %d 条运输 · 已点亮 %d 处据点 · 净化度 %d%%" % [completed, total, revealed, percent])
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 14)
	bar.max_value = 100.0
	bar.value = percent
	bar.show_percentage = false
	_apply_progress_bar_theme(bar, 14)
	card.add_child(bar)


func _get_purification_percent(planet_id: String) -> int:
	var progress := _get_planet_mission_progress(planet_id)
	return int(round(float(progress["completed"]) / float(maxi(int(progress["total"]), 1)) * 100.0))


func _add_status_badge(parent: Control, text: String, color: Color) -> void:
	var badge := Label.new()
	badge.text = "  %s  " % text
	badge.add_theme_font_size_override("font_size", 13)
	badge.add_theme_color_override("font_color", color)
	badge.add_theme_stylebox_override("normal", _style(Color(0.06, 0.08, 0.12, 0.96), color, 1, 6))
	parent.add_child(badge)


func _apply_progress_bar_theme(bar: ProgressBar, height: int, fill_color: Color = UI_CYAN) -> void:
	bar.custom_minimum_size.y = height
	var bg := _style(Color(0.10, 0.12, 0.16, 0.95), Color(0.18, 0.24, 0.32), 1, height / 2)
	var fill := _style(fill_color, fill_color.lightened(0.12), 0, height / 2)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


func _status_color(status: String) -> Color:
	match status:
		"已完成":
			return UI_GREEN
		"进行中":
			return UI_ORANGE
		"可接取":
			return UI_STATUS
		_:
			return UI_MUTED


func _find_next_mission_entry() -> Dictionary:
	# 优先使用已指派的进行中任务，与 TASKS / 地图据点分发对齐
	for planet in _get_playable_planets():
		if not bool(planet.get("unlocked", false)):
			continue
		var planet_id := String(planet["id"])
		var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
		if cfg == null or not cfg.has_method("get_location_missions"):
			continue
		var missions: Array = cfg.get_location_missions()
		missions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return int(a.get("order", 999)) < int(b.get("order", 999))
		)

		var active := Global.validate_active_mission(planet_id)
		var active_id := String(active.get("location_id", ""))
		if active_id != "":
			for mission in missions:
				if String(mission.get("location_id", "")) == active_id:
					return {"planet_id": planet_id, "location_id": active_id, "mission": mission}

		for mission in missions:
			var location_id := String(mission.get("location_id", ""))
			if location_id == "":
				continue
			if Global.get_completed_runner_locations(planet_id).has(location_id):
				continue
			if Global.get_revealed_exploration_locations(planet_id, ["dome"]).has(location_id):
				# 自动指派为当前任务，保证 HOME 与任务分发同源
				Global.set_active_mission(planet_id, location_id)
				return {"planet_id": planet_id, "location_id": location_id, "mission": mission}
	return {}


func _get_planet_mission_progress(planet_id: String) -> Dictionary:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	var missions: Array = cfg.get_location_missions()
	var total := int(cfg.get_outpost_count()) if cfg.has_method("get_outpost_count") else missions.size()
	var completed := 0
	var revealed_locations := Global.get_revealed_exploration_locations(planet_id, ["dome"])
	for mission in missions:
		var location_id := String(mission.get("location_id", ""))
		if Global.get_completed_runner_locations(planet_id).has(location_id):
			completed += 1
	return {
		"completed": completed,
		"total": total,
		"revealed": revealed_locations.size(),
	}


func _get_playable_planets() -> Array[Dictionary]:
	var planets: Array[Dictionary] = []
	for system in PlanetDatabase.STAR_SYSTEMS:
		for planet_entry in system["planets"]:
			if bool(planet_entry.get("display_only", false)):
				continue
			var planet_id := String(planet_entry["id"])
			var meta: Dictionary = PlanetDatabase.get_planet_meta(planet_id)
			planets.append(meta)
	return planets


func _open_planet_map(planet_id: String) -> void:
	_selected_planet_id = planet_id
	Global.mobile_home_tab = TAB_MAP
	Global.exploration_planet_id = planet_id
	Global.change_game_scene(PlanetDatabase.EXPLORATION_SCENE)


func _open_galaxy_map() -> void:
	Global.change_game_scene(PlanetDatabase.GALAXY_MAP_SCENE)


func _start_runner_for_planet(planet_id: String) -> void:
	_start_runner_for_location(planet_id, "dome")


func _start_runner_for_location(planet_id: String, location_id: String) -> void:
	_selected_planet_id = planet_id
	# 接取/指派为当前任务，HOME 与 TASKS 同源
	Global.set_active_mission(planet_id, location_id)
	Global.mobile_home_tab = TAB_HOME
	Global.exploration_planet_id = planet_id
	Global.runner_planet_id = planet_id
	Global.runner_location_id = location_id
	Global.change_game_scene(PlanetDatabase.RUNNER_SCENE)


func _accept_mission(planet_id: String, location_id: String) -> void:
	if Global.get_completed_runner_locations(planet_id).has(location_id):
		_show_toast("该据点任务已完成")
		return
	if not Global.get_revealed_exploration_locations(planet_id, ["dome"]).has(location_id):
		_show_toast("需要先在地图中点亮据点")
		return
	Global.set_active_mission(planet_id, location_id)
	_show_toast("已设为当前据点任务")
	_show_tab(TAB_HOME, true)


func _select_ship(ship_id: String) -> void:
	Global.set_selected_ship(ship_id)
	_show_toast("已切换飞船：%s" % String(PlanetDatabase.get_ship(ship_id)["name"]))
	_show_tab(TAB_CHARACTER, true, true)


func _show_story_intro() -> void:
	_story_overlay = _make_overlay_panel()

	var box := _overlay_box(_story_overlay)
	var title := _overlay_label("星火信使：黎明线", 34, UI_CYAN)
	box.add_child(title)
	var body := _overlay_label(
		"零潮吞没了旧航线，幸存据点只剩断裂的补给网络。\n\n你是 Elsa，第一位抵达晶砂荒漠的星火信使。把净水模块送到水源据点，点亮第一条黎明线。",
		19,
		UI_MUTED
	)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(0, 180)
	box.add_child(body)
	_add_primary_button(box, "进入主界面", _finish_story_intro)


func _finish_story_intro() -> void:
	Global.mark_first_launch_story_seen()
	if _story_overlay:
		_story_overlay.queue_free()
		_story_overlay = null
	_start_home_guide()


func _start_home_guide() -> void:
	if _guide_overlay != null or Global.home_guide_seen:
		return
	_guide_step = 0
	_build_guide_overlay()
	_show_guide_step(0)


func _build_guide_overlay() -> void:
	_guide_overlay = Control.new()
	_guide_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_guide_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_root.add_child(_guide_overlay)

	var shade := ColorRect.new()
	shade.name = "GuideShade"
	shade.color = Color(0.02, 0.04, 0.08, 0.82)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_guide_overlay.add_child(shade)

	_guide_highlight = PanelContainer.new()
	_guide_highlight.name = "GuideHighlight"
	_guide_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_guide_highlight.add_theme_stylebox_override(
		"panel",
		_style(Color(0.42, 0.86, 0.98, 0.16), UI_CYAN, 2, 10)
	)
	_guide_overlay.add_child(_guide_highlight)

	_guide_callout = PanelContainer.new()
	_guide_callout.name = "GuideCallout"
	_guide_callout.custom_minimum_size = Vector2(560, 0)
	_guide_callout.add_theme_stylebox_override(
		"panel",
		_style(UI_FRAME, UI_FRAME_BORDER, 2, 10)
	)
	_guide_overlay.add_child(_guide_callout)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	_guide_callout.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	_guide_title_label = Label.new()
	_guide_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guide_title_label.add_theme_font_size_override("font_size", 28)
	_guide_title_label.add_theme_color_override("font_color", UI_TEXT)
	box.add_child(_guide_title_label)

	_guide_body_label = Label.new()
	_guide_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_guide_body_label.custom_minimum_size = Vector2(500, 0)
	_guide_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guide_body_label.add_theme_font_size_override("font_size", 17)
	_guide_body_label.add_theme_color_override("font_color", UI_MUTED)
	box.add_child(_guide_body_label)

	_guide_next_button = _make_gold_button("下一步")
	_guide_next_button.pressed.connect(_advance_home_guide)
	box.add_child(_guide_next_button)

	_set_nav_interactive(false)
	_update_guide_layout()


func _show_guide_step(step_index: int) -> void:
	if step_index < 0 or step_index >= GUIDE_STEPS.size():
		return
	var step: Dictionary = GUIDE_STEPS[step_index]
	var tab_id := String(step["tab"])
	_show_tab(tab_id, true)
	_guide_title_label.text = String(step["title"])
	_guide_body_label.text = String(step["body"])
	_guide_next_button.text = String(step["next"])
	_update_guide_layout()
	call_deferred("_update_guide_layout")


func _advance_home_guide() -> void:
	_guide_step += 1
	if _guide_step >= GUIDE_STEPS.size():
		_finish_home_guide()
		return
	_show_guide_step(_guide_step)


func _finish_home_guide() -> void:
	Global.mark_home_guide_seen()
	_clear_home_guide()
	_show_tab(TAB_MAP, true)


func _clear_home_guide() -> void:
	_guide_step = -1
	_set_nav_interactive(true)
	if _guide_overlay:
		_guide_overlay.queue_free()
		_guide_overlay = null
		_guide_highlight = null
		_guide_callout = null
		_guide_title_label = null
		_guide_body_label = null
		_guide_next_button = null


func _set_nav_interactive(enabled: bool) -> void:
	for button in _nav_buttons.values():
		button.disabled = not enabled


func _update_guide_layout() -> void:
	if _guide_overlay == null or _guide_step < 0 or _guide_step >= GUIDE_STEPS.size():
		return
	var tab_id := String(GUIDE_STEPS[_guide_step]["tab"])
	var button: Control = _nav_buttons.get(tab_id)
	if button == null:
		return
	var button_rect := button.get_global_rect()
	_guide_highlight.global_position = button_rect.position - Vector2(6, 6)
	_guide_highlight.size = button_rect.size + Vector2(12, 12)

	var overlay_rect := _guide_overlay.get_global_rect()
	var callout_width := minf(overlay_rect.size.x - 48.0, 620.0)
	_guide_callout.custom_minimum_size = Vector2(callout_width, 0)
	_guide_callout.size.x = callout_width
	var callout_x := overlay_rect.position.x + (overlay_rect.size.x - callout_width) * 0.5
	var callout_y := button_rect.position.y - _guide_callout.size.y - 18.0
	if callout_y < overlay_rect.position.y + 24.0:
		callout_y = button_rect.end.y + 18.0
	_guide_callout.global_position = Vector2(callout_x, callout_y)


func _make_overlay_panel() -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_root.add_child(root)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.08, 0.78)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)

	var center := CenterContainer.new()
	center.name = "OverlayCenter"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.name = "OverlayPanel"
	panel.custom_minimum_size = Vector2(640, 420)
	panel.add_theme_stylebox_override("panel", _style(UI_FRAME, UI_FRAME_BORDER, 2, 10))
	center.add_child(panel)
	return root


func _overlay_box(root: Control) -> VBoxContainer:
	var panel := root.get_node("OverlayCenter/OverlayPanel") as PanelContainer
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)
	return box


func _overlay_label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _style(fill: Color, border: Color, border_width: int = 1, radius: int = 6) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
