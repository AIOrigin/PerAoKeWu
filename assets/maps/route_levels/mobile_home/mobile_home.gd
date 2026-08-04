extends Control

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")
const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const CustomLevels = preload("res://assets/maps/route_levels/runner_60s/custom_levels.gd")
const CharacterProgression = preload("res://assets/maps/route_levels/character_progression.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const MobilePauseOverlay = preload("res://assets/maps/route_levels/mobile_pause_overlay.gd")
const HomeFrameOverlay = preload("res://assets/maps/route_levels/mobile_home/home_frame_overlay.gd")
const MapFrameOverlay = preload("res://assets/maps/route_levels/mobile_home/map_frame_overlay.gd")
const TaskDetailSheet = preload("res://assets/maps/route_levels/mobile_home/task_detail_sheet.gd")

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
# 标注稿基准（home/星火信使-主界面UI.html spec）
const HOME_DESIGN_SIZE := Vector2(682.0, 1228.0)

# 晶莹蓝白体系（home/星火信使-主界面UI.html）
const UI_BG := Color(0.016, 0.027, 0.051, 0.98)
const UI_FRAME := Color(0.027, 0.063, 0.114, 0.62)
const UI_FRAME_BORDER := Color(0.667, 0.902, 1.0, 0.55)
const UI_PANEL := Color(0.027, 0.063, 0.114, 0.45)
const UI_PANEL_BORDER := Color(0.588, 0.843, 1.0, 0.4)
const UI_TEXT := Color(0.957, 0.984, 1.0)
const UI_MUTED := Color(0.576, 0.639, 0.71)
const UI_STATUS := Color(0.710, 0.941, 1.0)
const UI_CYAN := Color(0.557, 0.882, 0.969)
const UI_CYAN_SOFT := Color(0.635, 0.925, 0.976)
const UI_ICE := Color(0.902, 0.988, 1.0)
const UI_NAV_ACTIVE := Color(0.435, 0.839, 1.0)  # #6FD6FF 标注激活色
const UI_REWARD := Color(0.557, 0.882, 0.969)
const UI_GOLD := Color(0.557, 0.882, 0.969)
const UI_GOLD_BORDER := Color(0.682, 0.914, 0.961)
const UI_GREEN := Color(0.42, 0.86, 0.58)
const UI_ORANGE := Color(0.557, 0.882, 0.969)
const UI_ORANGE_BORDER := Color(0.435, 0.839, 1.0)
const UI_HEADER := Color(0.027, 0.063, 0.114, 0.62)
const UI_METAL := Color(0.027, 0.063, 0.114, 0.62)
const UI_METAL_BORDER := Color(0.627, 0.784, 0.922, 0.18)

const HEADER_UI_ROOT := "res://assets/maps/route_levels/mobile_home/ui_header/"
const HEADER_ICON_ENERGY := HEADER_UI_ROOT + "icon_energy.png"
const HEADER_ICON_GOLD := HEADER_UI_ROOT + "icon_gold.png"
const HEADER_ICON_EMBER := HEADER_UI_ROOT + "icon_ember.png"
const HEADER_ICON_SETTINGS := HEADER_UI_ROOT + "icon_settings.png"
const HOME_UI_ROOT := "res://assets/maps/route_levels/mobile_home/ui_home/"
const HOME_BG_PATH := HOME_UI_ROOT + "background_dawnline.webp"
const HOME_AVATAR_PATH := HOME_UI_ROOT + "avatar_default.png"
const HOME_MISSION_THUMB_PATH := HOME_UI_ROOT + "mission_thumb_water_station.webp"
const HOME_CIRCULAR_AVATAR_SHADER := HOME_UI_ROOT + "circular_avatar.gdshader"
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
const MAPLIST_MAP_CRYSTAL := MAPLIST_UI_ROOT + "map_crystal.jpg"
const MAPLIST_MAP_VENOM := MAPLIST_UI_ROOT + "map_venom.jpg"
const MAPLIST_MAP_GRAVITY := MAPLIST_UI_ROOT + "map_gravity.jpg"
const MAPLIST_MAP_REDSTORM := MAPLIST_UI_ROOT + "map_redstorm.jpg"
const MAPLIST_BG := MAPLIST_UI_ROOT + "map_list_background.webp"
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
		"body": "点击下方 MAP 进入据点地图。\n也可从 TASKS 接取运输任务；批次会逐步解锁。",
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
var _content_host: Control
var _status_bar_root: Control
var _bottom_nav_root: Control
var _ui_root: Control
var _home_background: TextureRect
var _home_overlay: Control
var _map_overlay: Control
var _map_title_host: Control
var _map_list_scroll: ScrollContainer
var _map_list_box: VBoxContainer
var _home_mission_host: Control
var _home_start_host: Control
var _page_scrim: ColorRect
var _home_title_box: Control
var _selected_tab := TAB_HOME
var _selected_planet_id := "glass_desert"
var _guide_step := -1
var _pause_overlay: MobilePauseOverlay
var _settings_overlay: Control
var _settings_tutorial_check: CheckButton
var _energy_tick := 0.0
var _task_detail: Control


func _ready() -> void:
	add_to_group("MobileHomeScene")
	_sync_selected_character_from_global()
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
	if _task_detail != null and _task_detail.visible:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
			_task_detail.close()
			get_viewport().set_input_as_handled()
		return
	if _story_overlay != null and _story_overlay.visible:
		return
	if _settings_overlay != null and _settings_overlay.visible:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
			_close_settings()
			get_viewport().set_input_as_handled()
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
	_sync_map_list_width()
	_update_guide_layout()
	_position_toast()


func _sync_map_list_width() -> void:
	if _map_list_scroll == null or _map_list_box == null:
		return
	var w := _map_list_scroll.size.x
	if w > 1.0:
		_map_list_box.custom_minimum_size.x = w


func _apply_mobile_layout() -> void:
	var frame_size := get_viewport().get_visible_rect().size
	if _ui_root != null and _ui_root.size.x > 1.0 and _ui_root.size.y > 1.0:
		frame_size = _ui_root.size
	var scale := maxf(frame_size.x / MOBILE_VIEWPORT_SIZE.x, 0.75)
	var side_margin := int(maxf(24.0, 28.0 * scale))
	var top_margin := 0
	var bottom_margin := 0
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		var safe := DisplayServer.get_display_safe_area()
		if safe.size.x > 0 and safe.size.y > 0:
			side_margin = maxi(side_margin, safe.position.x)
			top_margin = maxi(top_margin, safe.position.y)
			bottom_margin = maxi(bottom_margin, maxi(0, int(frame_size.y) - safe.end.y))
	if _content_host:
		_content_host.offset_left = side_margin
		_content_host.offset_right = -side_margin
		_content_host.offset_top = _home_spec_h(112) + top_margin
		_content_host.offset_bottom = -_home_spec_h(1228 - 1110) - bottom_margin
	elif _root_margin:
		_root_margin.add_theme_constant_override("margin_left", side_margin)
		_root_margin.add_theme_constant_override("margin_right", side_margin)
		_root_margin.add_theme_constant_override("margin_top", top_margin)
		_root_margin.add_theme_constant_override("margin_bottom", bottom_margin)
	if _page_title:
		_page_title.add_theme_font_size_override("font_size", 34)
	for button in _nav_buttons.values():
		button.custom_minimum_size = Vector2(0, _home_spec_h(98))
		var tab_label := button.find_child("TabLabel", true, false) as Label
		if tab_label:
			tab_label.add_theme_font_size_override("font_size", _home_spec_fs(22))
		var tab_icon := button.find_child("TabIcon", true, false) as TextureRect
		if tab_icon:
			var icon_sz := _home_spec_fs(42)
			tab_icon.custom_minimum_size = Vector2(icon_sz, icon_sz)


func _build_ui() -> void:
	var letterbox := ColorRect.new()
	letterbox.color = Color(0.016, 0.027, 0.051)
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

	var bg_scrim := ColorRect.new()
	bg_scrim.name = "BackgroundScrim"
	bg_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_scrim.color = Color(0.016, 0.027, 0.051, 0.08)
	bg_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(bg_scrim)

	var bg_top := ColorRect.new()
	bg_top.name = "BackgroundTopFade"
	bg_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	bg_top.offset_bottom = 268.0
	bg_top.color = Color(0.016, 0.027, 0.051, 0.42)
	bg_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(bg_top)

	var bg_bottom := ColorRect.new()
	bg_bottom.name = "BackgroundBottomFade"
	bg_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bg_bottom.offset_top = -690.0
	bg_bottom.color = Color(0.016, 0.027, 0.051, 0.55)
	bg_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(bg_bottom)

	var bg_bottom_deep := ColorRect.new()
	bg_bottom_deep.name = "BackgroundBottomDeep"
	bg_bottom_deep.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bg_bottom_deep.offset_top = -154.0
	bg_bottom_deep.color = Color(0.016, 0.027, 0.051, 0.85)
	bg_bottom_deep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(bg_bottom_deep)

	_page_scrim = ColorRect.new()
	_page_scrim.name = "PageScrim"
	_page_scrim.color = Color(0.016, 0.027, 0.051, 0.55)
	_page_scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page_scrim.visible = false
	shell.add_child(_page_scrim)

	_content_host = Control.new()
	_content_host.name = "ContentHost"
	_content_host.set_anchors_preset(Control.PRESET_FULL_RECT)
	_content_host.anchor_top = 0.0912
	_content_host.anchor_bottom = 0.9055
	_content_host.offset_left = 28
	_content_host.offset_right = -28
	shell.add_child(_content_host)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	_content_host.add_child(root)

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

	_ensure_toast_layer()
	_ensure_task_detail()

	_home_overlay = Control.new()
	_home_overlay.name = "HomeOverlay"
	_home_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_home_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(_home_overlay)

	_home_title_box = _build_home_title_overlay()
	_home_title_box.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_home_title_box.offset_top = float(_home_spec_h(140))
	_home_title_box.offset_bottom = float(_home_spec_h(345))
	_home_overlay.add_child(_home_title_box)

	_home_mission_host = Control.new()
	_home_mission_host.name = "HomeMissionHost"
	_home_mission_host.anchor_left = 0.1246
	_home_mission_host.anchor_top = 0.6563
	_home_mission_host.anchor_right = 0.8783
	_home_mission_host.anchor_bottom = 0.7842
	_home_mission_host.mouse_filter = Control.MOUSE_FILTER_PASS
	_home_overlay.add_child(_home_mission_host)

	_home_start_host = Control.new()
	_home_start_host.name = "HomeStartHost"
	_home_start_host.anchor_left = 0.1393
	_home_start_host.anchor_top = 0.794
	_home_start_host.anchor_right = 0.8651
	_home_start_host.anchor_bottom = 0.8876
	_home_start_host.mouse_filter = Control.MOUSE_FILTER_PASS
	_home_overlay.add_child(_home_start_host)

	_map_overlay = Control.new()
	_map_overlay.name = "MapOverlay"
	_map_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_map_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_overlay.visible = false
	shell.add_child(_map_overlay)

	_map_title_host = Control.new()
	_map_title_host.name = "MapTitleHost"
	_map_title_host.anchor_left = 0.0
	_map_title_host.anchor_top = 0.106
	_map_title_host.anchor_right = 1.0
	_map_title_host.anchor_bottom = 0.206
	_map_title_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_overlay.add_child(_map_title_host)

	_map_list_scroll = ScrollContainer.new()
	_map_list_scroll.name = "MapListScroll"
	_map_list_scroll.anchor_left = 0.065
	_map_list_scroll.anchor_top = 0.206
	_map_list_scroll.anchor_right = 0.935
	_map_list_scroll.anchor_bottom = 0.9055
	_map_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_map_overlay.add_child(_map_list_scroll)

	_map_list_box = VBoxContainer.new()
	_map_list_box.name = "MapListBox"
	_map_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_list_scroll.add_child(_map_list_box)

	_status_bar_root = Control.new()
	_status_bar_root.name = "StatusBarRoot"
	_status_bar_root.anchor_left = 0.0411
	_status_bar_root.anchor_top = 0.0228
	_status_bar_root.anchor_right = 0.9589
	_status_bar_root.anchor_bottom = 0.0912
	_status_bar_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(_status_bar_root)
	_status_bar_root.add_child(_build_status_bar())

	_bottom_nav_root = Control.new()
	_bottom_nav_root.name = "BottomNavRoot"
	_bottom_nav_root.anchor_left = 0.0367
	_bottom_nav_root.anchor_top = 0.9055
	_bottom_nav_root.anchor_right = 0.9633
	_bottom_nav_root.anchor_bottom = 0.9853
	shell.add_child(_bottom_nav_root)
	_bottom_nav_root.add_child(_build_bottom_nav())


func _build_home_title_overlay() -> Control:
	var box := VBoxContainer.new()
	box.name = "HomeTitle"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.custom_minimum_size = Vector2.ZERO

	var l1 := Label.new()
	l1.text = "EMBER"
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l1.add_theme_font_size_override("font_size", _home_spec_fs(86))
	l1.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0))
	l1.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.55))
	l1.add_theme_constant_override("shadow_offset_x", 0)
	l1.add_theme_constant_override("shadow_offset_y", 0)
	l1.add_theme_constant_override("shadow_outline_size", 10)
	l1.add_theme_constant_override("letter_spacing", _home_spec_em(86, 0.04))
	box.add_child(l1)

	var l2 := Label.new()
	l2.text = "RUNNERS:"
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l2.add_theme_font_size_override("font_size", _home_spec_fs(86))
	l2.add_theme_color_override("font_color", Color(0.89, 0.95, 0.99))
	l2.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.45))
	l2.add_theme_constant_override("shadow_offset_x", 0)
	l2.add_theme_constant_override("shadow_offset_y", 0)
	l2.add_theme_constant_override("shadow_outline_size", 10)
	l2.add_theme_constant_override("letter_spacing", _home_spec_em(86, 0.04))
	box.add_child(l2)

	var sub_row := HBoxContainer.new()
	sub_row.alignment = BoxContainer.ALIGNMENT_CENTER
	sub_row.add_theme_constant_override("separation", _home_spec_w(18))
	box.add_child(sub_row)

	var line_l := ColorRect.new()
	line_l.custom_minimum_size = Vector2(_home_spec_w(82), 1)
	line_l.color = Color(0.624, 0.847, 0.961, 0.85)
	line_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sub_row.add_child(line_l)

	var subtitle := Label.new()
	subtitle.text = "DAWNLINE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", _home_spec_fs(40))
	subtitle.add_theme_color_override("font_color", Color(0.894, 0.969, 0.996))
	subtitle.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.65))
	subtitle.add_theme_constant_override("shadow_offset_x", 0)
	subtitle.add_theme_constant_override("shadow_offset_y", 0)
	subtitle.add_theme_constant_override("shadow_outline_size", 6)
	subtitle.add_theme_constant_override("letter_spacing", _home_spec_em(40, 0.62))
	sub_row.add_child(subtitle)

	var line_r := ColorRect.new()
	line_r.custom_minimum_size = Vector2(_home_spec_w(82), 1)
	line_r.color = Color(0.624, 0.847, 0.961, 0.85)
	line_r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sub_row.add_child(line_r)

	var chev := Label.new()
	chev.text = "▽"
	chev.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chev.add_theme_font_size_override("font_size", _home_spec_fs(22))
	chev.add_theme_color_override("font_color", Color(0.710, 0.941, 1.0, 0.75))
	box.add_child(chev)
	return box


func _on_avatar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_tab(TAB_CHARACTER)
	elif event is InputEventScreenTouch and event.pressed:
		_show_tab(TAB_CHARACTER)


func _build_status_bar() -> Control:
	var bar := Control.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	bar.add_child(row)

	var left_pill := PanelContainer.new()
	left_pill.add_theme_stylebox_override("panel", _style_glass(48, 10, 18, 10))
	row.add_child(left_pill)

	var left_margin := MarginContainer.new()
	left_margin.add_theme_constant_override("margin_left", 6)
	left_margin.add_theme_constant_override("margin_right", 20)
	left_margin.add_theme_constant_override("margin_top", 4)
	left_margin.add_theme_constant_override("margin_bottom", 4)
	left_pill.add_child(left_margin)

	var left := HBoxContainer.new()
	left.alignment = BoxContainer.ALIGNMENT_BEGIN
	left.add_theme_constant_override("separation", 14)
	left_margin.add_child(left)

	var avatar_sz := _home_spec_w(70)
	var avatar_wrap := Control.new()
	avatar_wrap.custom_minimum_size = Vector2(avatar_sz, avatar_sz)
	avatar_wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	avatar_wrap.gui_input.connect(_on_avatar_input)
	left.add_child(avatar_wrap)

	var avatar_bg := Panel.new()
	avatar_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	avatar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.04, 0.08, 0.14)
	bg_style.set_corner_radius_all(avatar_sz / 2)
	bg_style.set_content_margin_all(0)
	avatar_bg.add_theme_stylebox_override("panel", bg_style)
	avatar_wrap.add_child(avatar_bg)

	_status_avatar_icon = TextureRect.new()
	_status_avatar_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_status_avatar_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_status_avatar_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_status_avatar_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status_avatar_icon.visible = false
	var avatar_shader := load(HOME_CIRCULAR_AVATAR_SHADER) as Shader
	if avatar_shader:
		var avatar_mat := ShaderMaterial.new()
		avatar_mat.shader = avatar_shader
		_status_avatar_icon.material = avatar_mat
	avatar_wrap.add_child(_status_avatar_icon)

	_status_avatar_fallback = Label.new()
	_status_avatar_fallback.text = "E"
	_status_avatar_fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_status_avatar_fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_avatar_fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_status_avatar_fallback.add_theme_font_size_override("font_size", _home_spec_fs(24))
	_status_avatar_fallback.add_theme_color_override("font_color", UI_CYAN_SOFT)
	_status_avatar_fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar_wrap.add_child(_status_avatar_fallback)

	var avatar_ring := Panel.new()
	avatar_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	avatar_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ring_style := StyleBoxFlat.new()
	ring_style.bg_color = Color.TRANSPARENT
	ring_style.set_corner_radius_all(avatar_sz / 2)
	ring_style.set_border_width_all(2)
	ring_style.border_color = Color(0.588, 0.784, 0.941, 0.55)
	ring_style.shadow_color = Color(0.435, 0.839, 1.0, 0.28)
	ring_style.shadow_size = 6
	ring_style.set_content_margin_all(0)
	avatar_ring.add_theme_stylebox_override("panel", ring_style)
	avatar_wrap.add_child(avatar_ring)

	_status_level_badge = Label.new()
	_status_level_badge.visible = false
	avatar_wrap.add_child(_status_level_badge)
	_status_xp_bar = ProgressBar.new()
	_status_xp_bar.visible = false
	avatar_wrap.add_child(_status_xp_bar)

	var name_col := VBoxContainer.new()
	name_col.alignment = BoxContainer.ALIGNMENT_CENTER
	name_col.add_theme_constant_override("separation", 2)
	name_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	left.add_child(name_col)

	_status_name = Label.new()
	_status_name.text = "Elsa"
	_status_name.add_theme_font_size_override("font_size", _home_spec_fs(30))
	_status_name.add_theme_color_override("font_color", UI_TEXT)
	name_col.add_child(_status_name)

	var level_row := HBoxContainer.new()
	level_row.add_theme_constant_override("separation", 8)
	name_col.add_child(level_row)

	_status_level_label = Label.new()
	_status_level_label.text = "Lv. 1"
	_status_level_label.add_theme_font_size_override("font_size", _home_spec_fs(24))
	_status_level_label.add_theme_color_override("font_color", UI_MUTED)
	level_row.add_child(_status_level_label)

	var level_diamond := Label.new()
	level_diamond.text = "◆"
	level_diamond.add_theme_font_size_override("font_size", 10)
	level_diamond.add_theme_color_override("font_color", UI_CYAN)
	level_diamond.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	level_row.add_child(level_diamond)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(1, _home_spec_h(44))
	divider.color = Color(0.627, 0.784, 0.922, 0.25)
	divider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(divider)

	var row_spacer := Control.new()
	row_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(row_spacer)

	var credits_wrap := HBoxContainer.new()
	credits_wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	credits_wrap.add_theme_constant_override("separation", 12)
	row.add_child(credits_wrap)

	var coin_icon := Label.new()
	coin_icon.text = "★"
	coin_icon.add_theme_font_size_override("font_size", _home_spec_fs(28))
	coin_icon.add_theme_color_override("font_color", UI_NAV_ACTIVE)
	coin_icon.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.55))
	coin_icon.add_theme_constant_override("shadow_outline_size", 6)
	coin_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credits_wrap.add_child(coin_icon)

	_status_ember_label = Label.new()
	_status_ember_label.text = "0"
	_status_ember_label.add_theme_font_size_override("font_size", _home_spec_fs(28))
	_status_ember_label.add_theme_color_override("font_color", UI_TEXT)
	_status_ember_label.add_theme_constant_override("letter_spacing", 2)
	credits_wrap.add_child(_status_ember_label)

	var settings_button := Button.new()
	settings_button.focus_mode = Control.FOCUS_NONE
	settings_button.flat = true
	var settings_sz := _home_spec_w(76)
	settings_button.custom_minimum_size = Vector2(settings_sz, settings_sz)
	settings_button.add_theme_stylebox_override("normal", _style_glass(_home_spec_w(22), 10, 10, 10))
	settings_button.add_theme_stylebox_override("hover", _style_glass(_home_spec_w(22), 10, 10, 10))
	settings_button.add_theme_stylebox_override("pressed", _style(Color(0.02, 0.05, 0.09, 0.82), UI_PANEL_BORDER, 1, _home_spec_w(22)))
	settings_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	settings_button.pressed.connect(_open_settings)
	row.add_child(settings_button)

	var settings_icon := TextureRect.new()
	settings_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16)
	settings_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	settings_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	settings_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var settings_tex := _load_header_texture(FINAL_ICON_SETTINGS)
	if settings_tex == null:
		settings_tex = _load_header_texture(HEADER_ICON_SETTINGS)
	if settings_tex:
		settings_icon.texture = settings_tex
		settings_icon.modulate = UI_TEXT
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
	var nav_host := PanelContainer.new()
	nav_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	nav_host.add_theme_stylebox_override("panel", _style_nav_bar())

	var nav := MarginContainer.new()
	nav.add_theme_constant_override("margin_left", 10)
	nav.add_theme_constant_override("margin_right", 10)
	nav.add_theme_constant_override("margin_top", 4)
	nav.add_theme_constant_override("margin_bottom", 6)
	nav_host.add_child(nav)

	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 0)
	nav.add_child(row)

	_add_nav_button(row, TAB_HOME, String(TAB_LABELS[TAB_HOME]))
	_add_nav_button(row, TAB_MAP, String(TAB_LABELS[TAB_MAP]))
	_add_nav_button(row, TAB_TASKS, String(TAB_LABELS[TAB_TASKS]))
	_add_nav_button(row, TAB_CHARACTER, String(TAB_LABELS[TAB_CHARACTER]))
	return nav_host


func _add_nav_button(parent: Control, tab_id: String, label: String) -> void:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, _home_spec_h(98))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.flat = true
	button.pressed.connect(_show_tab.bind(tab_id))

	# 激活指示条：HTML .nav-item.active::before
	var indicator := ColorRect.new()
	indicator.name = "ActiveIndicator"
	indicator.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	indicator.offset_left = 22
	indicator.offset_right = -22
	indicator.offset_top = 0
	indicator.offset_bottom = 2
	indicator.color = UI_NAV_ACTIVE
	indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	indicator.visible = false
	button.add_child(indicator)

	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	col.offset_top = _home_spec_h(12)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 4)
	button.add_child(col)

	var icon := TextureRect.new()
	icon.name = "TabIcon"
	var nav_icon_sz := _home_spec_fs(42)
	icon.custom_minimum_size = Vector2(nav_icon_sz, nav_icon_sz)
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
	text.add_theme_font_size_override("font_size", _home_spec_fs(22))
	text.add_theme_color_override("font_color", UI_MUTED)
	text.add_theme_constant_override("letter_spacing", 3)
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

		var indicator := button.find_child("ActiveIndicator", true, false) as ColorRect
		var label := button.find_child("TabLabel", true, false) as Label
		var icon := button.find_child("TabIcon", true, false) as TextureRect
		if indicator:
			indicator.visible = selected
		if label:
			label.add_theme_color_override("font_color", UI_NAV_ACTIVE if selected else UI_MUTED)
		if icon:
			icon.modulate = UI_NAV_ACTIVE if selected else Color(0.58, 0.64, 0.71)


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
	var is_map := tab_id == TAB_MAP
	if _page_scrim:
		_page_scrim.visible = not is_home
		_page_scrim.color = Color(0.016, 0.027, 0.051, 0.40) if is_map else Color(0.016, 0.027, 0.051, 0.55)
	if _home_overlay:
		_home_overlay.visible = is_home
	if _home_title_box:
		_home_title_box.visible = is_home
	if _map_overlay:
		_map_overlay.visible = is_map
	if _page_scroll:
		_page_scroll.visible = not is_home and not is_map
		_page_scroll.vertical_scroll_mode = (
			ScrollContainer.SCROLL_MODE_DISABLED if is_home else ScrollContainer.SCROLL_MODE_AUTO
		)
		_page_scroll.scroll_vertical = 0
	if _home_background:
		if is_map:
			var map_bg := _load_header_texture(MAPLIST_BG)
			if map_bg:
				_home_background.texture = map_bg
		elif is_home:
			var home_bg := _load_header_texture(HOME_BG_PATH)
			if home_bg:
				_home_background.texture = home_bg
	if _content_host:
		_content_host.visible = not is_home and not is_map
	_clear_home_hosts()
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
		_status_level_label.text = "Lv. %d" % level
	if _status_level_badge:
		_status_level_badge.text = str(level)
	if _status_ember_label:
		_status_ember_label.text = _format_count(Global.ember_coins)
	if _status_avatar_fallback:
		_status_avatar_fallback.text = String(character.get("badge", char_name.left(1)))

	var portrait := CharacterRoster.load_texture(String(character.get("portrait_path", "")))
	if portrait == null:
		portrait = _load_header_texture(HOME_AVATAR_PATH)
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


func _clear_home_hosts() -> void:
	if _home_mission_host == null or _home_start_host == null:
		return
	for child in _home_mission_host.get_children():
		child.queue_free()
	for child in _home_start_host.get_children():
		child.queue_free()


func _build_home_page() -> void:
	_clear_home_hosts()
	var next_entry := _find_next_mission_entry()
	if next_entry.is_empty():
		_mount_home_mission_panel(
			_home_map_display_name("glass_desert"),
			"Water Station",
			"Supply run",
			"",
			0,
			1
		)
		_mount_home_start_button("VIEW MAP", _show_tab.bind(TAB_MAP))
		return

	var planet_id := String(next_entry["planet_id"])
	var location_id := String(next_entry["location_id"])
	var mission: Dictionary = next_entry["mission"]
	var is_replay := bool(next_entry.get("replay", false))
	var map_name := _home_map_display_name(planet_id)
	var outpost_status := _home_outpost_status(planet_id, location_id)
	var source_name := _home_outpost_display_name(
		location_id,
		String(mission.get("source_hearth", outpost_status.get("title", "Water Station")))
	)
	var repair := _home_repair_progress(planet_id, location_id)
	var mission_type := "Supply run"
	if is_replay:
		mission_type = "Replay run"
	_mount_home_mission_panel(
		map_name,
		source_name,
		mission_type,
		location_id,
		int(repair["current"]),
		int(repair["total"])
	)
	var start_label := "START RUN" if not is_replay else "REPLAY RUN"
	_mount_home_start_button(
		start_label,
		_start_runner_for_location.bind(planet_id, location_id)
	)


func _mount_home_mission_panel(
	map_name: String,
	outpost_name: String,
	mission_type: String,
	location_id: String,
	repair_current: int,
	repair_total: int
) -> void:
	if _home_mission_host == null:
		return
	var panel := _build_home_mission_panel(
		map_name, outpost_name, mission_type, location_id, repair_current, repair_total
	)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_home_mission_host.add_child(panel)


func _mount_home_start_button(text: String, callback: Callable) -> void:
	if _home_start_host == null:
		return
	var button := _add_home_start_button(_home_start_host, text, callback)
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _home_map_display_name(planet_id: String) -> String:
	var meta: Dictionary = PlanetDatabase.get_planet_meta(planet_id)
	var name := String(meta.get("name", ""))
	# 设计稿显示名；配置 MAP_NAME 为「无尽晶砂漠」
	if planet_id == "glass_desert":
		return "Crystal Waste"
	return name if name != "" else "Unknown Map"


func _home_outpost_display_name(location_id: String, fallback: String) -> String:
	match location_id:
		"reservoir", "dome":
			return "Water Station"
		"medical":
			return "Medical Outpost"
		"relay":
			return "Relay Station"
		"gate":
			return "Gate Fortress"
		_:
			return fallback if fallback != "" else "Outpost"


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


func _home_all_missions_complete(planet_id: String) -> bool:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if cfg == null or not cfg.has_method("get_location_missions"):
		return false
	for mission in cfg.get_location_missions():
		var location_id := String(mission.get("location_id", ""))
		if location_id == "":
			continue
		if not Global.get_completed_runner_locations(planet_id).has(location_id):
			return false
	return true


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


func _home_mission_thumb(location_id: String) -> Texture2D:
	if location_id in ["dome", "reservoir", "medical", "relay", "gate"]:
		return _load_header_texture(HOME_MISSION_THUMB_PATH)
	return _load_header_texture(HOME_MISSION_THUMB_PATH)


func _build_home_mission_panel(
	map_name: String,
	outpost_name: String,
	mission_type: String,
	location_id: String,
	repair_current: int,
	repair_total: int
) -> Control:
	var wrap := Control.new()

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _style_mission_frame())
	wrap.add_child(panel)

	var frame := HomeFrameOverlay.ChamferBorderOverlay.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(frame)
	frame.resized.connect(frame.queue_redraw)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 5)
	row.add_child(left)

	var tag_row := HBoxContainer.new()
	tag_row.add_theme_constant_override("separation", 6)
	left.add_child(tag_row)

	var tag_icon := Label.new()
	tag_icon.text = "◎"
	tag_icon.add_theme_font_size_override("font_size", _home_spec_fs(14))
	tag_icon.add_theme_color_override("font_color", UI_CYAN_SOFT)
	tag_row.add_child(tag_icon)

	var tag := Label.new()
	tag.text = "CURRENT MISSION"
	tag.add_theme_font_size_override("font_size", _home_spec_fs(20))
	tag.add_theme_color_override("font_color", Color(0.710, 0.941, 1.0))
	tag.add_theme_constant_override("letter_spacing", 4)
	tag.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.35))
	tag.add_theme_constant_override("shadow_outline_size", 3)
	tag_row.add_child(tag)

	var map_title := Label.new()
	map_title.text = "%s -\n%s" % [map_name, outpost_name]
	map_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	map_title.add_theme_font_size_override("font_size", _home_spec_fs(30))
	map_title.add_theme_color_override("font_color", UI_TEXT)
	left.add_child(map_title)

	var type_label := Label.new()
	type_label.text = mission_type
	type_label.add_theme_font_size_override("font_size", _home_spec_fs(22))
	type_label.add_theme_color_override("font_color", UI_CYAN)
	type_label.add_theme_constant_override("letter_spacing", 2)
	type_label.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.3))
	type_label.add_theme_constant_override("shadow_outline_size", 3)
	left.add_child(type_label)

	var thumb_w := _home_spec_w(238)
	var thumb_h := _home_spec_h(112)
	var thumb_wrap := PanelContainer.new()
	thumb_wrap.custom_minimum_size = Vector2(thumb_w, thumb_h)
	thumb_wrap.add_theme_stylebox_override("panel", _style(Color(0.02, 0.05, 0.09, 0.6), UI_PANEL_BORDER, 1, 2))
	row.add_child(thumb_wrap)

	var thumb := TextureRect.new()
	thumb.custom_minimum_size = Vector2(thumb_w - 8, thumb_h - 8)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var thumb_tex := _home_mission_thumb(location_id)
	if thumb_tex:
		thumb.texture = thumb_tex
	thumb_wrap.add_child(thumb)

	return wrap


func _add_home_road_style_picker(parent: Control) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style_glass(10, 12, 12, 12))
	parent.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	box.add_child(_build_runner_style_dropdown_row("跑道外观", true))
	box.add_child(_build_runner_style_dropdown_row("场景背景", false))


func _build_runner_style_dropdown_row(title_text: String, is_road: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = title_text
	title.custom_minimum_size = Vector2(120, 0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UI_MUTED)
	row.add_child(title)

	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.custom_minimum_size = Vector2(0, 56)
	option.focus_mode = Control.FOCUS_NONE
	if is_road:
		Global.populate_runner_road_style_option(option)
		option.item_selected.connect(func(index: int) -> void:
			if index >= 0 and index < Global.RUNNER_ROAD_STYLE_ORDER.size():
				Global.set_runner_road_style(Global.RUNNER_ROAD_STYLE_ORDER[index])
				_show_toast("跑道：%s" % Global.get_runner_road_style_label())
		)
	else:
		Global.populate_runner_background_style_option(option)
		option.item_selected.connect(func(index: int) -> void:
			if index >= 0 and index < Global.RUNNER_BACKGROUND_STYLE_ORDER.size():
				Global.set_runner_background_style(Global.RUNNER_BACKGROUND_STYLE_ORDER[index])
				_show_toast("背景：%s" % Global.get_runner_background_style_label())
		)
	_style_home_option_button(option)
	row.add_child(option)
	return row


func _style_home_option_button(option: OptionButton) -> void:
	option.add_theme_stylebox_override("normal", _style_glass(8, 10, 10, 10))
	option.add_theme_stylebox_override("hover", _style_glass(8, 10, 10, 10))
	option.add_theme_stylebox_override("pressed", _style(Color(0.02, 0.05, 0.09, 0.82), UI_PANEL_BORDER, 1, 8))
	option.add_theme_stylebox_override("focus", _style_glass(8, 10, 10, 10))
	option.add_theme_font_size_override("font_size", 18)
	option.add_theme_color_override("font_color", UI_CYAN)


func _add_home_start_button(parent: Control, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.flat = false
	button.text = ""
	var normal := _style_home_start_button(false)
	var hover := _style_home_start_button(true)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.078, 0.137, 0.216, 0.72)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("disabled", normal)

	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 6)
	button.add_child(row)

	var label := Label.new()
	label.text = text.to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", _home_spec_fs(48))
	label.add_theme_color_override("font_color", UI_ICE)
	label.add_theme_constant_override("letter_spacing", _home_spec_em(48, 0.34))
	label.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.4))
	label.add_theme_constant_override("shadow_outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)

	var arrow := Label.new()
	arrow.text = "›"
	arrow.add_theme_font_size_override("font_size", _home_spec_fs(52))
	arrow.add_theme_color_override("font_color", Color(0.784, 0.949, 0.992))
	arrow.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.45))
	arrow.add_theme_constant_override("shadow_outline_size", 4)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(arrow)

	var brackets := HomeFrameOverlay.StartBracketOverlay.new()
	brackets.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	brackets.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(brackets)

	button.pressed.connect(callback)
	parent.add_child(button)

	var pulse := create_tween()
	pulse.set_loops()
	pulse.tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.3)
	pulse.tween_property(button, "modulate", Color(0.94, 0.99, 1.0, 1.0), 1.3)
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


func _clear_map_page() -> void:
	if _map_title_host != null:
		for child in _map_title_host.get_children():
			child.queue_free()
	if _map_list_box != null:
		for child in _map_list_box.get_children():
			child.queue_free()


func _build_map_page() -> void:
	_clear_map_page()
	_map_list_box.add_theme_constant_override("separation", _home_spec_h(27))
	_add_map_archive_header()
	_add_map_archive_card({
		"index": "01",
		"planet_id": "glass_desert",
		"name": "CRYSTAL WASTE",
		"preview": MAPLIST_MAP_CRYSTAL,
		"unlocked": true,
	})
	_add_map_archive_card({
		"index": "02",
		"planet_id": "",
		"name": "VENOM MIRE",
		"preview": MAPLIST_MAP_VENOM,
		"unlocked": false,
	})
	_add_map_archive_card({
		"index": "03",
		"planet_id": "",
		"name": "GRAVITY-SHATTERED CITY",
		"preview": MAPLIST_MAP_GRAVITY,
		"unlocked": false,
		"long_name": true,
	})
	_add_map_archive_card({
		"index": "04",
		"planet_id": "",
		"name": "REDSTORM BELT",
		"preview": MAPLIST_MAP_REDSTORM,
		"unlocked": false,
	})
	call_deferred("_sync_map_list_width")


func _add_map_archive_header() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_title_host.add_child(center)

	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", _home_spec_h(7))
	header.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center.add_child(header)

	var title := Label.new()
	title.text = "MAP ARCHIVE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", _home_spec_fs(48))
	title.add_theme_color_override("font_color", Color(0.965, 0.984, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.55))
	title.add_theme_constant_override("shadow_outline_size", 8)
	title.add_theme_constant_override("letter_spacing", _home_spec_em(48, 0.16))
	header.add_child(title)

	var line_wrap := Control.new()
	line_wrap.custom_minimum_size = Vector2(_home_spec_w(286), _home_spec_h(10))
	line_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(line_wrap)

	var line := ColorRect.new()
	line.set_anchors_preset(Control.PRESET_CENTER)
	line.offset_left = -_home_spec_w(143)
	line.offset_right = _home_spec_w(143)
	line.offset_top = -1
	line.offset_bottom = 1
	line.color = Color(0.627, 0.863, 0.98, 0.65)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_wrap.add_child(line)

	var diamond := Label.new()
	diamond.text = "◆"
	diamond.set_anchors_preset(Control.PRESET_CENTER)
	diamond.offset_left = -_home_spec_w(8)
	diamond.offset_right = _home_spec_w(8)
	diamond.offset_top = -_home_spec_h(8)
	diamond.offset_bottom = _home_spec_h(8)
	diamond.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diamond.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	diamond.add_theme_font_size_override("font_size", _home_spec_fs(10))
	diamond.add_theme_color_override("font_color", UI_ICE)
	diamond.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.65))
	diamond.add_theme_constant_override("shadow_outline_size", 4)
	diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line_wrap.add_child(diamond)

	var sub_row := HBoxContainer.new()
	sub_row.alignment = BoxContainer.ALIGNMENT_CENTER
	sub_row.add_theme_constant_override("separation", _home_spec_w(15))
	header.add_child(sub_row)

	var sub_line_l := ColorRect.new()
	sub_line_l.custom_minimum_size = Vector2(_home_spec_w(38), 1)
	sub_line_l.color = Color(0.561, 0.663, 0.753, 0.85)
	sub_line_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sub_row.add_child(sub_line_l)

	var sub := Label.new()
	sub.text = "— SELECT A REGION —"
	sub.add_theme_font_size_override("font_size", _home_spec_fs(20))
	sub.add_theme_color_override("font_color", Color(0.624, 0.698, 0.776))
	sub.add_theme_constant_override("letter_spacing", _home_spec_em(20, 0.34))
	sub_row.add_child(sub)

	var sub_line_r := ColorRect.new()
	sub_line_r.custom_minimum_size = Vector2(_home_spec_w(38), 1)
	sub_line_r.color = Color(0.561, 0.663, 0.753, 0.85)
	sub_line_r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sub_row.add_child(sub_line_r)


func _add_map_archive_card(data: Dictionary) -> void:
	var unlocked := bool(data.get("unlocked", false))
	var card_h := _home_spec_h(169)
	var thumb_w := _home_spec_w(273)
	var inner_h := card_h - _home_spec_h(17) * 2
	var pad_v := _home_spec_h(17)
	var pad_l := _home_spec_w(20)
	var pad_r := _home_spec_w(20)

	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(0, card_h)
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.clip_contents = true
	wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	if unlocked:
		wrap.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_open_planet_map(String(data.get("planet_id", "glass_desert")))
			elif event is InputEventScreenTouch and event.pressed:
				_open_planet_map(String(data.get("planet_id", "glass_desert")))
		)
	_map_list_box.add_child(wrap)

	var frame := MapFrameOverlay.MapCardFrameOverlay.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.z_index = 4
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(frame)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.z_index = 1
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style_map_card_glass())
	wrap.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", pad_l)
	margin.add_theme_constant_override("margin_right", pad_r)
	margin.add_theme_constant_override("margin_top", pad_v)
	margin.add_theme_constant_override("margin_bottom", pad_v)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", _home_spec_w(22))
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(row)

	var thumb_wrap := PanelContainer.new()
	thumb_wrap.custom_minimum_size = Vector2(thumb_w, inner_h)
	thumb_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	thumb_wrap.clip_contents = true
	thumb_wrap.add_theme_stylebox_override("panel", _style_map_thumb_frame())
	thumb_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(thumb_wrap)

	var thumb_inner := Control.new()
	thumb_inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	thumb_inner.clip_contents = true
	thumb_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thumb_wrap.add_child(thumb_inner)

	var preview_path := String(data.get("preview", ""))
	if preview_path == "" or not ResourceLoader.exists(preview_path):
		preview_path = MAPLIST_PREVIEW_01
	if ResourceLoader.exists(preview_path):
		var image := TextureRect.new()
		image.texture = load(preview_path) as Texture2D
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not unlocked:
			image.modulate = Color(0.72, 0.72, 0.78, 0.88)
		thumb_inner.add_child(image)

	if unlocked:
		var avail_bar := MarginContainer.new()
		avail_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		avail_bar.add_theme_constant_override("margin_left", _home_spec_w(17))
		avail_bar.add_theme_constant_override("margin_bottom", _home_spec_h(12))
		avail_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb_inner.add_child(avail_bar)

		var avail_stack := VBoxContainer.new()
		avail_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
		avail_stack.alignment = BoxContainer.ALIGNMENT_END
		avail_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
		avail_bar.add_child(avail_stack)

		var avail := HBoxContainer.new()
		avail.add_theme_constant_override("separation", _home_spec_w(8))
		avail.mouse_filter = Control.MOUSE_FILTER_IGNORE
		avail_stack.add_child(avail)

		var dot := PanelContainer.new()
		dot.custom_minimum_size = Vector2(_home_spec_w(11), _home_spec_w(11))
		var dot_style := StyleBoxFlat.new()
		dot_style.bg_color = UI_CYAN_SOFT
		dot_style.set_corner_radius_all(_home_spec_w(6))
		dot_style.shadow_color = Color(0.557, 0.882, 0.969, 0.55)
		dot_style.shadow_size = 6
		dot.add_theme_stylebox_override("panel", dot_style)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		avail.add_child(dot)

		var avail_label := Label.new()
		avail_label.text = "AVAILABLE"
		avail_label.add_theme_font_size_override("font_size", _home_spec_fs(18))
		avail_label.add_theme_color_override("font_color", UI_CYAN_SOFT)
		avail_label.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.45))
		avail_label.add_theme_constant_override("shadow_outline_size", 4)
		avail_label.add_theme_constant_override("letter_spacing", _home_spec_em(18, 0.18))
		avail_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		avail.add_child(avail_label)
	else:
		var veil := ColorRect.new()
		veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		veil.color = Color(0.016, 0.031, 0.055, 0.22)
		veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb_inner.add_child(veil)

		var lock_center := CenterContainer.new()
		lock_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lock_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		thumb_inner.add_child(lock_center)

		var lock_ring := PanelContainer.new()
		lock_ring.custom_minimum_size = Vector2(_home_spec_w(61), _home_spec_w(61))
		var lock_style := StyleBoxFlat.new()
		lock_style.bg_color = Color(0.031, 0.063, 0.11, 0.75)
		lock_style.border_color = Color(0.667, 0.902, 1.0, 0.5)
		lock_style.set_border_width_all(2)
		lock_style.set_corner_radius_all(_home_spec_w(31))
		lock_style.shadow_color = Color(0.557, 0.882, 0.969, 0.28)
		lock_style.shadow_size = 10
		lock_ring.add_theme_stylebox_override("panel", lock_style)
		lock_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock_center.add_child(lock_ring)

		var lock_icon := Label.new()
		lock_icon.text = "🔒"
		lock_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lock_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_icon.add_theme_font_size_override("font_size", _home_spec_fs(24))
		lock_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock_ring.add_child(lock_icon)

	var info_wrap := MarginContainer.new()
	if unlocked:
		info_wrap.custom_minimum_size.x = _home_spec_w(191)
		info_wrap.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	else:
		info_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_wrap.add_theme_constant_override("margin_top", _home_spec_h(20))
	info_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(info_wrap)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", _home_spec_h(4))
	info.modulate = Color(1, 1, 1, 1.0 if unlocked else 0.55)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_wrap.add_child(info)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", _home_spec_w(16))
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(head)

	var num := Label.new()
	num.text = String(data.get("index", "01"))
	num.add_theme_font_size_override("font_size", _home_spec_fs(25))
	num.add_theme_color_override("font_color", UI_CYAN)
	num.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.45))
	num.add_theme_constant_override("shadow_outline_size", 4)
	num.add_theme_constant_override("letter_spacing", _home_spec_em(25, 0.08))
	num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(num)

	var name := Label.new()
	name.text = String(data.get("name", "MAP"))
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if bool(data.get("long_name", false)) else TextServer.AUTOWRAP_OFF
	name.add_theme_font_size_override(
		"font_size",
		_home_spec_fs(23) if bool(data.get("long_name", false)) else _home_spec_fs(24)
	)
	name.add_theme_color_override("font_color", UI_TEXT)
	name.add_theme_constant_override("letter_spacing", _home_spec_em(24, 0.06))
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(name)

	if unlocked:
		# 切角框右下为斜切，需比标注稿 3.2cqw/1.1cqh 再多留一点空
		var enter_pad_r := _home_spec_w(36)
		var enter_pad_b := _home_spec_h(26)
		var enter_btn_w := _home_spec_w(118)
		var enter_btn_h := _home_spec_h(34)
		var enter := Button.new()
		enter.text = "ENTER  »"
		enter.focus_mode = Control.FOCUS_NONE
		enter.z_index = 5
		enter.custom_minimum_size = Vector2(enter_btn_w, enter_btn_h)
		enter.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		enter.offset_left = -enter_pad_r - enter_btn_w
		enter.offset_top = -enter_pad_b - enter_btn_h
		enter.offset_right = -enter_pad_r
		enter.offset_bottom = -enter_pad_b
		enter.add_theme_font_size_override("font_size", _home_spec_fs(23))
		enter.add_theme_color_override("font_color", UI_ICE)
		enter.add_theme_constant_override("letter_spacing", _home_spec_em(23, 0.22))
		var enter_n := _style_map_enter_button(false)
		var enter_h := _style_map_enter_button(true)
		enter.add_theme_stylebox_override("normal", enter_n)
		enter.add_theme_stylebox_override("hover", enter_h)
		enter.add_theme_stylebox_override("pressed", enter_h)
		enter.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		enter.pressed.connect(_open_planet_map.bind(String(data.get("planet_id", "glass_desert"))))
		wrap.add_child(enter)


func _style_map_card_glass() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.047, 0.094, 0.165, 0.0)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.set_content_margin_all(0)
	return style


func _style_map_thumb_frame() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.07, 0.35)
	style.border_color = Color(0.667, 0.902, 1.0, 0.5)
	style.set_border_width_all(1)
	style.set_content_margin_all(0)
	style.shadow_color = Color(0.557, 0.882, 0.969, 0.28)
	style.shadow_size = 8
	return style


func _style_map_enter_button(hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.118, 0.216, 0.314, 0.72) if hover else Color(0.157, 0.275, 0.392, 0.58)
	style.border_color = Color(0.745, 0.933, 0.996, 0.6)
	style.set_border_width_all(1)
	style.set_corner_radius_all(_home_spec_w(15))
	style.shadow_color = Color(0.557, 0.882, 0.969, 0.45)
	style.shadow_size = 12
	style.content_margin_left = _home_spec_w(18)
	style.content_margin_right = _home_spec_w(18)
	style.content_margin_top = _home_spec_h(8)
	style.content_margin_bottom = _home_spec_h(8)
	return style


func _build_tasks_page() -> void:
	var planet_id := "glass_desert"
	Global.ensure_mission_dispatch_ready(planet_id)
	var unlocked_batch := Global.get_unlocked_mission_batch(planet_id)
	var batch_label := MissionDispatch.batch_unlock_summary(planet_id, unlocked_batch)
	var board := Global.get_mission_board_slots(planet_id)
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	_add_lead_panel(
		"运输任务板",
		"%s\n常驻 %d 槽 · 按据点缺口优先补发 · 点亮后自动换新任务" % [
			batch_label,
			MissionDispatch.BOARD_SLOT_COUNT,
		]
	)
	var missions_to_show: Array = []
	if not board.is_empty():
		for location_id in board:
			var mission: Dictionary = cfg.get_mission_for_location(String(location_id)) if cfg != null else {}
			if mission.is_empty():
				mission = {
					"location_id": String(location_id),
					"cargo_name": "运输物资",
					"task_type": "Supply Run",
					"difficulty": 1,
				}
			missions_to_show.append(mission)
	elif cfg != null and cfg.has_method("get_location_missions"):
		# 任务板清空后仍展示已开放据点任务，便于再次运输 / 测详情
		for mission in cfg.get_location_missions():
			var location_id := String(mission.get("location_id", ""))
			if location_id == "":
				continue
			if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id, unlocked_batch):
				continue
			missions_to_show.append(mission)

	if missions_to_show.is_empty():
		_add_card("任务板已清空", "当前批次可运输据点均已点亮。可从地图再次运输，或等待下一批次解锁。")
	else:
		if board.is_empty():
			_add_muted_label(_page_box, "当前批次据点已全部点亮 · 以下为可再次运输任务")
		var planet_meta: Dictionary = PlanetDatabase.get_planet_meta(planet_id)
		var slot_index := 1
		for mission in missions_to_show:
			_add_mission_card(planet_meta, mission, slot_index, not board.is_empty())
			slot_index += 1

	_add_section_title("批次进度")
	for entry in MissionDispatch.get_batches(planet_id):
		var batch_id := int(entry.get("id", 0))
		var status := "已开放" if batch_id <= unlocked_batch else "未解锁"
		var locs: PackedStringArray = PackedStringArray()
		for location_id in entry.get("locations", []):
			var meta: Dictionary = cfg.get_outpost_meta(String(location_id)) if cfg != null and cfg.has_method("get_outpost_meta") else {}
			var name := String(meta.get("name", location_id))
			var progress := Global.get_outpost_progress(planet_id, String(location_id))
			var total := Global.get_outpost_repair_total(planet_id, String(location_id))
			locs.append("%s %d/%d" % [name, progress, total])
		var unlock_hint := ""
		if batch_id == 2 and unlocked_batch < 2:
			unlock_hint = "\n解锁条件：批次1任一据点点亮"
		elif batch_id == 3 and unlocked_batch < 3:
			unlock_hint = "\n解锁条件：批次1+2平均进度 ≥ 85%"
		_add_card(
			"批次%d · %s · %s" % [batch_id, String(entry.get("name", "")), status],
			" · ".join(locs) + unlock_hint
		)

	_add_section_title("自定义关卡")
	var customs: Array = CustomLevels.list_levels()
	if customs.is_empty():
		_add_card("暂无自定义关卡", "在关卡编辑器中摆放障碍后点「保存为关卡」，会按 自定义01、自定义02… 自动上架到此处。")
	else:
		for level in customs:
			_add_custom_level_card(level)


func _add_custom_level_card(level: Dictionary) -> void:
	var planet_id := String(level.get("planet_id", "glass_desert"))
	var level_id := String(level.get("id", ""))
	var display_name := String(level.get("name", level_id))
	var duration := int(level.get("duration", 65))
	var obstacle_count := int(level.get("obstacle_count", 0))
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color(0.08, 0.10, 0.13, 0.98), UI_CYAN, 2, 8))
	_page_box.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)
	var title := Label.new()
	title.text = display_name
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", UI_CYAN)
	box.add_child(title)
	var meta := Label.new()
	meta.text = "%s · %ds · %d 障碍 · 底图 %s" % [level_id, duration, obstacle_count, planet_id]
	meta.add_theme_font_size_override("font_size", 13)
	meta.add_theme_color_override("font_color", UI_MUTED)
	box.add_child(meta)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	box.add_child(actions)
	var start_btn := _add_primary_button(actions, "开始跑酷", _start_runner_for_location.bind(planet_id, level_id))
	start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL


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
	Global.set_selected_character(_selected_character_id)
	_show_toast("已切换至 %s" % String(CharacterRoster.get_character(next_id).get("name", next_id)))
	_show_tab(TAB_CHARACTER, true)


func _show_character_story(character_id: String) -> void:
	if _character_story_overlay:
		_character_story_overlay.queue_free()
		_character_story_overlay = null

	_selected_character_id = character_id
	Global.set_selected_character(_selected_character_id)
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


func _ensure_task_detail() -> void:
	if _task_detail != null:
		return
	_task_detail = TaskDetailSheet.new()
	_task_detail.configure(MOBILE_VIEWPORT_SIZE, HOME_DESIGN_SIZE, _home_outpost_display_name)
	_task_detail.accept_pressed.connect(_on_task_detail_accept)
	_task_detail.closed.connect(_on_task_detail_closed)
	_ui_root.add_child(_task_detail)


func _open_task_detail(planet_id: String, mission: Dictionary) -> void:
	_ensure_task_detail()
	if _bottom_nav_root:
		_bottom_nav_root.visible = false
	_task_detail.open(planet_id, mission)


func _on_task_detail_closed() -> void:
	if _bottom_nav_root:
		_bottom_nav_root.visible = true


func _on_task_detail_accept(planet_id: String, location_id: String) -> void:
	if planet_id == "" or location_id == "":
		return
	var completed := Global.get_completed_runner_locations(planet_id).has(location_id)
	var is_active := Global.is_active_mission(planet_id, location_id)
	if completed or is_active:
		if _task_detail:
			_task_detail.close()
		_start_runner_for_location(planet_id, location_id)
		return
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		_show_toast("该批次任务尚未解锁")
		return
	if not Global.get_revealed_exploration_locations(planet_id, MissionDispatch.get_batch1_location_ids(planet_id)).has(location_id):
		_show_toast("需要先在地图中点亮据点")
		return
	Global.set_active_mission(planet_id, location_id)
	_show_toast("已接取 · 可点 START RUN 出发")
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	var mission: Dictionary = cfg.get_mission_for_location(location_id) if cfg != null else {}
	if mission.is_empty():
		mission = {"location_id": location_id}
	_open_task_detail(planet_id, mission)
	if _selected_tab == TAB_TASKS:
		_build_tasks_page()


func _add_mission_card(
	planet: Dictionary,
	mission: Dictionary,
	slot_index: int = 0,
	from_board: bool = false
) -> void:
	var planet_id := String(planet["id"])
	var location_id := String(mission.get("location_id", "dome"))
	var completed := Global.get_completed_runner_locations(planet_id).has(location_id)
	var revealed := Global.get_revealed_exploration_locations(
		planet_id,
		MissionDispatch.get_batch1_location_ids(planet_id)
	).has(location_id)
	var batch_unlocked := MissionDispatch.is_location_batch_unlocked(planet_id, location_id)
	var is_active := Global.is_active_mission(planet_id, location_id)
	var on_board := from_board or Global.is_mission_on_board(planet_id, location_id)
	var status := "已完成" if completed else ("进行中" if is_active else ("任务板上" if on_board else ("可接取" if batch_unlocked and revealed else "待解锁")))
	var border_color := UI_GREEN if completed else (UI_ORANGE if is_active else (Color(0.96, 0.58, 0.22) if on_board or (batch_unlocked and revealed) else UI_PANEL_BORDER))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _style(Color(0.08, 0.10, 0.13, 0.98), border_color, 2, 8))
	_page_box.add_child(panel)
	panel.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_task_detail(planet_id, mission.duplicate(true))
	)

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
	var profile: Dictionary = MissionTypes.resolve(mission)
	var type_zh := String(mission.get("task_type_zh", profile.get("name_zh", "补给")))
	var duration_s := int(mission.get("duration", profile.get("duration", 60)))
	type_label.text = "%s · %ds" % [type_zh, duration_s]
	if slot_index > 0:
		type_label.text = "槽位 %d · %s" % [slot_index, type_label.text]
	type_label.add_theme_font_size_override("font_size", 15)
	type_label.add_theme_color_override("font_color", UI_TEXT)
	text_box.add_child(type_label)

	var hint_text := String(mission.get("task_hint", profile.get("hint", "")))
	if hint_text != "":
		var hint_label := Label.new()
		hint_label.text = hint_text
		hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint_label.add_theme_font_size_override("font_size", 12)
		hint_label.add_theme_color_override("font_color", UI_MUTED)
		text_box.add_child(hint_label)

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
	if revealed or completed or on_board:
		var repair := _home_repair_progress(planet_id, location_id)
		var repair_lbl := Label.new()
		var gap := MissionDispatch.gap_priority(planet_id, location_id)
		repair_lbl.text = "据点修复 %d / %d · 缺口优先 %.0f%%" % [
			int(repair["current"]),
			int(repair["total"]),
			gap,
		]
		repair_lbl.add_theme_font_size_override("font_size", 13)
		repair_lbl.add_theme_color_override("font_color", Color(0.72, 0.76, 0.82))
		box.add_child(repair_lbl)

	if completed:
		_add_muted_label(box, "据点进度 100%")
		_add_home_road_style_picker(box)
		var replay_actions := HBoxContainer.new()
		replay_actions.add_theme_constant_override("separation", 8)
		box.add_child(replay_actions)
		var replay_btn := _add_primary_button(replay_actions, "再次运输", _start_runner_for_location.bind(planet_id, location_id))
		replay_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var map_btn := _add_secondary_button(replay_actions, "查看地图", _open_planet_map.bind(planet_id))
		map_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	elif batch_unlocked and revealed:
		_add_home_road_style_picker(box)
		var actions := HBoxContainer.new()
		actions.add_theme_constant_override("separation", 8)
		box.add_child(actions)
		var repair2 := _home_repair_progress(planet_id, location_id)
		var start_label := "继续运输" if int(repair2["current"]) > 0 else "开始运输"
		var start_btn := _add_primary_button(actions, start_label, _start_runner_for_location.bind(planet_id, location_id))
		start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if is_active:
			var home_btn := _add_secondary_button(actions, "回首页", _show_tab.bind(TAB_HOME))
			home_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			var accept_btn := _add_secondary_button(actions, "设为当前", _accept_mission.bind(planet_id, location_id))
			accept_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var map_btn2 := _add_secondary_button(actions, "查看地图", _open_planet_map.bind(planet_id))
		map_btn2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		var lock_reason := "需要先解锁对应任务批次"
		if batch_unlocked and not revealed:
			lock_reason = "需要先在地图中点亮据点"
		_add_muted_label(box, lock_reason)


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
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _style(UI_PANEL, Color(0.96, 0.58, 0.22), 2, 10))
	_page_box.add_child(panel)
	panel.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_task_detail(planet_id, mission.duplicate(true))
	)

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
	var type_zh := String(mission.get("task_type_zh", MissionTypes.short_label(mission)))
	var duration_s := int(mission.get("duration", MissionTypes.resolve(mission).get("duration", 60)))
	line1.text = "%s · %ds · %s" % [type_zh, duration_s, String(mission.get("target_hearth", "据点"))]
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
	var portrait_path := String(cfg.get_runner_portrait_path(_selected_character_id))
	if portrait_path == "" or not ResourceLoader.exists(portrait_path):
		return null
	return load(portrait_path) as Texture2D


func _sync_selected_character_from_global() -> void:
	_selected_character_id = Global.get_selected_character_id()
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	if not CharacterRoster.is_unlocked(_selected_character_id, unlocked):
		_selected_character_id = CharacterRoster.CHAR_ELSA
	Global.set_selected_character(_selected_character_id)


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


func _open_settings() -> void:
	if _settings_overlay != null and is_instance_valid(_settings_overlay):
		_settings_overlay.visible = true
		_refresh_settings_ui()
		return
	_build_settings_overlay()
	_refresh_settings_ui()


func _close_settings() -> void:
	if _settings_overlay != null and is_instance_valid(_settings_overlay):
		_settings_overlay.visible = false


func _build_settings_overlay() -> void:
	_settings_overlay = Control.new()
	_settings_overlay.name = "SettingsOverlay"
	_settings_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_root.add_child(_settings_overlay)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.04, 0.08, 0.78)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			_close_settings()
	)
	_settings_overlay.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _style(UI_FRAME, UI_FRAME_BORDER, 2, 14))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var title := Label.new()
	title.text = "设置"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", UI_TEXT)
	box.add_child(title)

	var tip := Label.new()
	tip.text = "跑酷新手引导会在首次遇到跳跃、滑铲、换道、防护罩、分叉、侧墙时提示。"
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(480, 0)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 16)
	tip.add_theme_color_override("font_color", UI_MUTED)
	box.add_child(tip)

	_settings_tutorial_check = CheckButton.new()
	_settings_tutorial_check.text = "开启跑酷新手引导"
	_settings_tutorial_check.focus_mode = Control.FOCUS_NONE
	_settings_tutorial_check.add_theme_font_size_override("font_size", 20)
	_settings_tutorial_check.add_theme_color_override("font_color", UI_TEXT)
	_settings_tutorial_check.toggled.connect(_on_settings_tutorial_toggled)
	box.add_child(_settings_tutorial_check)

	var reset_btn := _make_flat_button("重置跑酷教学进度")
	reset_btn.pressed.connect(_on_settings_reset_tutorials)
	box.add_child(reset_btn)

	var home_guide_btn := _make_flat_button("重新播放主页引导")
	home_guide_btn.pressed.connect(_on_settings_replay_home_guide)
	box.add_child(home_guide_btn)

	var close_btn := _make_gold_button("关闭")
	close_btn.pressed.connect(_close_settings)
	box.add_child(close_btn)


func _refresh_settings_ui() -> void:
	if _settings_tutorial_check == null:
		return
	_settings_tutorial_check.set_pressed_no_signal(Global.is_runner_tutorial_enabled())


func _on_settings_tutorial_toggled(pressed: bool) -> void:
	Global.set_runner_tutorial_enabled(pressed)
	_show_toast("跑酷新手引导已%s" % ("开启" if pressed else "关闭"))


func _on_settings_reset_tutorials() -> void:
	Global.reset_runner_tutorials()
	_show_toast("已重置跑酷教学，下次开跑会重新提示")


func _on_settings_replay_home_guide() -> void:
	Global.home_guide_seen = false
	Global.save_mobile_progress()
	_close_settings()
	if _guide_overlay != null and is_instance_valid(_guide_overlay):
		_guide_overlay.queue_free()
		_guide_overlay = null
	_start_home_guide()


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
	# 优先使用已指派；否则取任务板第一槽（缺口优先派发结果）
	for planet in _get_playable_planets():
		if not bool(planet.get("unlocked", false)):
			continue
		var planet_id := String(planet["id"])
		Global.ensure_mission_dispatch_ready(planet_id)
		var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
		if cfg == null or not cfg.has_method("get_mission_for_location"):
			continue

		var active := Global.validate_active_mission(planet_id)
		var active_id := String(active.get("location_id", ""))
		if active_id != "":
			var active_mission: Dictionary = cfg.get_mission_for_location(active_id)
			if not active_mission.is_empty():
				return {"planet_id": planet_id, "location_id": active_id, "mission": active_mission}

		var board := Global.get_mission_board_slots(planet_id)
		for location_id in board:
			if Global.get_completed_runner_locations(planet_id).has(location_id):
				continue
			var mission: Dictionary = cfg.get_mission_for_location(location_id)
			if mission.is_empty():
				continue
			Global.set_active_mission(planet_id, location_id)
			return {"planet_id": planet_id, "location_id": location_id, "mission": mission}

		var missions: Array = cfg.get_location_missions() if cfg.has_method("get_location_missions") else []
		var replay := _find_replay_mission_entry(planet_id, missions)
		if not replay.is_empty():
			return replay
	return {}


func _find_replay_mission_entry(planet_id: String, missions: Array) -> Dictionary:
	# 主线全清后：HOME 仍展示最后一条已点亮任务，允许再次进跑酷
	var revealed := Global.get_revealed_exploration_locations(planet_id, ["dome"])
	var best_mission: Dictionary = {}
	var best_order := -1
	for mission in missions:
		var location_id := String(mission.get("location_id", ""))
		if location_id == "" or not revealed.has(location_id):
			continue
		var order := int(mission.get("order", 0))
		if order >= best_order:
			best_order = order
			best_mission = mission
	if best_mission.is_empty():
		return {}
	return {
		"planet_id": planet_id,
		"location_id": String(best_mission.get("location_id", "")),
		"mission": best_mission,
		"replay": true,
	}


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
	_sync_selected_character_from_global()
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
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		_show_toast("该批次任务尚未解锁")
		return
	if not Global.get_revealed_exploration_locations(planet_id, MissionDispatch.get_batch1_location_ids(planet_id)).has(location_id):
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
	_guide_overlay.clip_contents = false
	_ui_root.add_child(_guide_overlay)

	var shade := ColorRect.new()
	shade.name = "GuideShade"
	shade.color = Color(0.02, 0.04, 0.08, 0.72)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_guide_overlay.add_child(shade)

	_guide_highlight = PanelContainer.new()
	_guide_highlight.name = "GuideHighlight"
	_guide_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_guide_highlight.clip_contents = false
	_guide_highlight.add_theme_stylebox_override(
		"panel",
		_style(Color(0.42, 0.86, 0.98, 0.14), UI_CYAN, 2, 14)
	)
	_guide_overlay.add_child(_guide_highlight)

	_guide_callout = PanelContainer.new()
	_guide_callout.name = "GuideCallout"
	_guide_callout.clip_contents = false
	_guide_callout.custom_minimum_size = Vector2(520, 0)
	var callout_style := _style(Color(0.035, 0.07, 0.12, 0.96), UI_FRAME_BORDER, 2, 16)
	callout_style.content_margin_left = 0
	callout_style.content_margin_right = 0
	callout_style.content_margin_top = 0
	callout_style.content_margin_bottom = 0
	_guide_callout.add_theme_stylebox_override("panel", callout_style)
	_guide_overlay.add_child(_guide_callout)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 24)
	_guide_callout.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	_guide_title_label = Label.new()
	_guide_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guide_title_label.clip_text = false
	_guide_title_label.add_theme_font_size_override("font_size", 26)
	_guide_title_label.add_theme_color_override("font_color", UI_CYAN_SOFT)
	_guide_title_label.add_theme_constant_override("line_spacing", 4)
	box.add_child(_guide_title_label)

	_guide_body_label = Label.new()
	_guide_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_guide_body_label.clip_text = false
	_guide_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_guide_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guide_body_label.add_theme_font_size_override("font_size", 18)
	_guide_body_label.add_theme_color_override("font_color", UI_MUTED)
	_guide_body_label.add_theme_constant_override("line_spacing", 6)
	box.add_child(_guide_body_label)

	_guide_next_button = Button.new()
	_guide_next_button.focus_mode = Control.FOCUS_NONE
	_guide_next_button.custom_minimum_size = Vector2(0, 52)
	_guide_next_button.add_theme_font_size_override("font_size", 18)
	_guide_next_button.add_theme_stylebox_override("normal", _style(UI_GOLD, UI_GOLD_BORDER, 2, 12))
	_guide_next_button.add_theme_stylebox_override("hover", _style(UI_GOLD.lightened(0.05), UI_GOLD_BORDER.lightened(0.04), 2, 12))
	_guide_next_button.add_theme_stylebox_override("pressed", _style(UI_GOLD.darkened(0.08), UI_GOLD_BORDER.darkened(0.04), 2, 12))
	_guide_next_button.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
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
	if _guide_callout == null or _guide_highlight == null:
		return
	var tab_id := String(GUIDE_STEPS[_guide_step]["tab"])
	var button: Control = _nav_buttons.get(tab_id)
	if button == null:
		return
	var button_rect := button.get_global_rect()
	_guide_highlight.global_position = button_rect.position - Vector2(8, 8)
	_guide_highlight.size = button_rect.size + Vector2(16, 16)

	var overlay_rect := _guide_overlay.get_global_rect()
	var side_pad := 36.0
	var callout_width := minf(overlay_rect.size.x - side_pad * 2.0, 560.0)
	_guide_callout.custom_minimum_size = Vector2(callout_width, 0)
	if _guide_body_label != null:
		_guide_body_label.custom_minimum_size = Vector2(maxi(callout_width - 56.0, 200.0), 0)
	# 先按内容最小尺寸定高，再定位，避免高度为 0 时叠在底栏上
	_guide_callout.reset_size()
	var callout_size := _guide_callout.get_combined_minimum_size()
	callout_size.x = callout_width
	callout_size.y = maxf(callout_size.y, 160.0)
	_guide_callout.size = callout_size

	var callout_x := overlay_rect.position.x + (overlay_rect.size.x - callout_width) * 0.5
	var gap := 24.0
	var nav_top := button_rect.position.y
	if _bottom_nav_root != null:
		nav_top = mini(nav_top, _bottom_nav_root.get_global_rect().position.y)
	var callout_y := nav_top - callout_size.y - gap
	var top_limit := overlay_rect.position.y + 96.0
	if callout_y < top_limit:
		callout_y = top_limit
	# 绝不压住底栏
	if callout_y + callout_size.y > nav_top - 12.0:
		callout_y = nav_top - callout_size.y - gap
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


func _home_scale_x() -> float:
	return MOBILE_VIEWPORT_SIZE.x / HOME_DESIGN_SIZE.x


func _home_scale_y() -> float:
	return MOBILE_VIEWPORT_SIZE.y / HOME_DESIGN_SIZE.y


func _home_spec_w(design_px: float) -> int:
	return int(round(design_px * _home_scale_x()))


func _home_spec_h(design_px: float) -> int:
	return int(round(design_px * _home_scale_y()))


func _home_spec_fs(design_px: float) -> int:
	return int(round(design_px * _home_scale_x()))


func _home_spec_em(design_font_px: float, em: float) -> int:
	return int(round(design_font_px * em * _home_scale_x()))


func _style_glass(radius: int = 12, margin_left: int = 10, margin_right: int = 10, margin_vertical: int = 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UI_FRAME
	style.border_color = UI_METAL_BORDER
	style.set_border_width_all(1)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = margin_left
	style.content_margin_right = margin_right
	style.content_margin_top = margin_vertical
	style.content_margin_bottom = margin_vertical
	return style


func _style_mission_frame() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.027, 0.063, 0.114, 0.45)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.shadow_color = Color(0.557, 0.882, 0.969, 0.32)
	style.shadow_size = 12
	return style


func _style_nav_bar() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.027, 0.063, 0.114, 0.62)
	style.border_color = Color(0.627, 0.784, 0.922, 0.16)
	style.set_border_width_all(1)
	style.set_corner_radius_all(26)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	return style


func _style_home_start_button(hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.157, 0.275, 0.392, 0.58) if hover else Color(0.118, 0.216, 0.314, 0.5)
	style.border_color = Color(0.588, 0.843, 1.0, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(_home_spec_w(40))
	style.shadow_color = Color(0.557, 0.882, 0.969, 0.38)
	style.shadow_size = 18
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


func _home_spaced_label(text: String) -> String:
	var out := PackedStringArray()
	for ch in text:
		if ch == " ":
			out.append("  ")
		else:
			out.append("%s " % ch)
	return "".strip_edges()


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
