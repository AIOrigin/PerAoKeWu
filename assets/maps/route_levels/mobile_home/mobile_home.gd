extends Control

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")
const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const CustomLevels = preload("res://assets/maps/route_levels/runner_60s/custom_levels.gd")
const CharacterProgression = preload("res://assets/maps/route_levels/character_progression.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const CharacterPageUI = preload("res://assets/maps/route_levels/mobile_home/character_page_ui.gd")
const MobilePauseOverlay = preload("res://assets/maps/route_levels/mobile_pause_overlay.gd")
const HomeFrameOverlay = preload("res://assets/maps/route_levels/mobile_home/home_frame_overlay.gd")
const MapFrameOverlay = preload("res://assets/maps/route_levels/mobile_home/map_frame_overlay.gd")
const TaskDetailSheet = preload("res://assets/maps/route_levels/mobile_home/task_detail_sheet.gd")
const ComicIntroPlayer = preload("res://assets/maps/route_levels/mobile_home/comic_intro_player.gd")

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
const TASKS_UI_SCALE := 1.0
const SETTINGS_UI_SCALE := 1.42

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
const UI_MISSION_DONE := Color(0.34, 0.72, 0.58)  # 完成态：低饱和青绿
# RUN 星火红：暗血红 / 勃艮第，半透明玻璃感（参考 #4A0E17 · #6C1D24 · #A31C1C）
const UI_EMBER_RUN_BG := Color(0.29, 0.055, 0.09, 0.58)
const UI_EMBER_RUN_BORDER := Color(0.42, 0.11, 0.14, 0.82)
const UI_EMBER_RUN_GLOW := Color(0.64, 0.11, 0.11, 0.30)
const UI_EMBER_RUN_TEXT := Color(0.93, 0.78, 0.76)
const UI_REWARD_CLAIM := ClaimButtonUI.HIGHLIGHT  # 待领取高亮 · 淡粉体系
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
const HOME_MISSION_THUMB_BY_LOCATION := {
	"dome": HOME_UI_ROOT + "mission_thumb_dome.jpg",
	"reservoir": HOME_UI_ROOT + "mission_thumb_water_station.webp",
	"medical": HOME_UI_ROOT + "mission_thumb_medical.jpg",
	"gate": HOME_UI_ROOT + "mission_thumb_gate.jpg",
	"relay": HOME_UI_ROOT + "mission_thumb_relay.jpg",
}
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
		"body": "点击 MAP，选择一个地图，查看各个据点和相关运输任务。也可以直接在 TASKS 里接取运输任务。",
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
var _story_canvas: CanvasLayer
var _story_intro_replay := false
var _guide_overlay: Control
var _guide_layer: CanvasLayer
var _transport_intro_layer: CanvasLayer
var _character_story_overlay: Control
var _character_story_layer: CanvasLayer
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
var _bg_bottom_fade: ColorRect
var _bg_bottom_deep: ColorRect
var _home_title_box: Control
var _dawnline_hit: Control
var _dawnline_glow: Control
var _dawnline_finger: Control
var _dawnline_hint_tween: Tween
var _selected_tab := TAB_HOME
var _selected_planet_id := "glass_desert"
var _guide_step := -1
var _pause_overlay: MobilePauseOverlay
var _settings_overlay: Control
var _settings_bgm_slider: HSlider
var _settings_language_option: OptionButton
var _energy_tick := 0.0
var _task_detail: Control
var _tasks_sub_tab := "missions"
var _tasks_missions_box: VBoxContainer
var _tasks_daily_box: VBoxContainer
var _tasks_tab_missions_btn: Button
var _tasks_tab_daily_btn: Button
var _tasks_daily_red_dot: Control
var _tasks_ritual_footer: PanelContainer
var _tasks_completed_btn: Button
var _tasks_completed_overlay: Control
var _tasks_completed_list_box: VBoxContainer


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
	Global.ensure_mission_dispatch_ready("glass_desert")
	call_deferred("_apply_mobile_layout")
	_show_tab(_selected_tab)
	_refresh_status_bar()
	Global.play_home_bgm()
	# 首次：不自动播漫画，等玩家点 DAWNLINE 光点；看完漫画后再走首页引导
	if not Global.opening_comic_seen:
		call_deferred("_refresh_dawnline_comic_hint")
	elif not Global.home_guide_seen:
		_start_home_guide()
	else:
		_refresh_dawnline_comic_hint()


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
	if _tasks_completed_overlay != null and _tasks_completed_overlay.visible:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
			_close_tasks_completed_overlay()
			get_viewport().set_input_as_handled()
		return
	if _story_overlay != null and is_instance_valid(_story_overlay):
		if _story_overlay is ComicIntroPlayer:
			var intro := _story_overlay as ComicIntroPlayer
			if event.is_action_pressed("ui_accept"):
				intro._on_next_pressed()
				get_viewport().set_input_as_handled()
				return
			if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
				intro._on_skip_pressed()
				get_viewport().set_input_as_handled()
				return
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
		var h_margin := side_margin
		var top_inset := _home_spec_h(112)
		var bottom_inset := _home_spec_h(1228 - 1110)
		if _selected_tab == TAB_CHARACTER:
			# 四周留缝：左右边距 + 底栏上方小间隙（小缝即可，避免再出现大块露底）
			h_margin = side_margin
			top_inset = _home_spec_h(104)
			bottom_inset = _home_spec_h(20)
		_content_host.offset_left = h_margin
		_content_host.offset_right = -h_margin
		_content_host.offset_top = top_inset + top_margin
		_content_host.offset_bottom = -bottom_inset - bottom_margin
	elif _root_margin:
		_root_margin.add_theme_constant_override("margin_left", side_margin)
		_root_margin.add_theme_constant_override("margin_right", side_margin)
		_root_margin.add_theme_constant_override("margin_top", top_margin)
		_root_margin.add_theme_constant_override("margin_bottom", bottom_margin)
	if _page_scroll and _page_box:
		var page_w := _page_scroll.size.x
		if page_w > 1.0:
			_page_box.custom_minimum_size.x = page_w
	if _page_title:
		var title_fs := _tasks_spec_fs(42) if _selected_tab == TAB_TASKS else 34
		_page_title.add_theme_font_size_override("font_size", title_fs)
	if _page_subtitle and _selected_tab == TAB_TASKS:
		_page_subtitle.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
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
	_bg_bottom_fade = bg_bottom

	var bg_bottom_deep := ColorRect.new()
	bg_bottom_deep.name = "BackgroundBottomDeep"
	bg_bottom_deep.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bg_bottom_deep.offset_top = -154.0
	bg_bottom_deep.color = Color(0.016, 0.027, 0.051, 0.85)
	bg_bottom_deep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(bg_bottom_deep)
	_bg_bottom_deep = bg_bottom_deep

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
	_home_title_box.offset_bottom = float(_home_spec_h(420))
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
	l1.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	l2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(l2)

	var dawn_wrap := Control.new()
	dawn_wrap.name = "DawnlineHit"
	dawn_wrap.custom_minimum_size = Vector2(0, _home_spec_h(72))
	dawn_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dawn_wrap.mouse_filter = Control.MOUSE_FILTER_STOP
	box.add_child(dawn_wrap)
	_dawnline_hit = dawn_wrap

	var glow := PanelContainer.new()
	glow.name = "DawnlineGlow"
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_preset(Control.PRESET_CENTER)
	glow.offset_left = -_home_spec_w(168)
	glow.offset_right = _home_spec_w(168)
	glow.offset_top = -_home_spec_h(22)
	glow.offset_bottom = _home_spec_h(28)
	var glow_style := StyleBoxFlat.new()
	glow_style.bg_color = Color(0.35, 0.85, 1.0, 0.22)
	glow_style.border_color = Color(0.75, 0.95, 1.0, 0.85)
	glow_style.set_border_width_all(2)
	glow_style.set_corner_radius_all(_home_spec_w(18))
	glow_style.shadow_color = Color(0.45, 0.9, 1.0, 0.55)
	glow_style.shadow_size = 18
	glow.add_theme_stylebox_override("panel", glow_style)
	glow.visible = false
	dawn_wrap.add_child(glow)
	_dawnline_glow = glow

	var sub_row := HBoxContainer.new()
	sub_row.set_anchors_preset(Control.PRESET_FULL_RECT)
	sub_row.alignment = BoxContainer.ALIGNMENT_CENTER
	sub_row.add_theme_constant_override("separation", _home_spec_w(18))
	sub_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dawn_wrap.add_child(sub_row)

	var line_l := ColorRect.new()
	line_l.custom_minimum_size = Vector2(_home_spec_w(82), 1)
	line_l.color = Color(0.624, 0.847, 0.961, 0.85)
	line_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_row.add_child(line_l)

	var subtitle := Label.new()
	subtitle.name = "DawnlineLabel"
	subtitle.text = "DAWNLINE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", _home_spec_fs(40))
	subtitle.add_theme_color_override("font_color", Color(0.894, 0.969, 0.996))
	subtitle.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.65))
	subtitle.add_theme_constant_override("shadow_offset_x", 0)
	subtitle.add_theme_constant_override("shadow_offset_y", 0)
	subtitle.add_theme_constant_override("shadow_outline_size", 6)
	subtitle.add_theme_constant_override("letter_spacing", _home_spec_em(40, 0.62))
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_row.add_child(subtitle)

	var line_r := ColorRect.new()
	line_r.custom_minimum_size = Vector2(_home_spec_w(82), 1)
	line_r.color = Color(0.624, 0.847, 0.961, 0.85)
	line_r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sub_row.add_child(line_r)

	# 指引箭头：居中放在 DAWNLINE 正下方（单独 host，便于对称动画）
	var arrow_wrap := VBoxContainer.new()
	arrow_wrap.name = "DawnlineFinger"
	arrow_wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	arrow_wrap.add_theme_constant_override("separation", _home_spec_h(2))
	arrow_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow_wrap.visible = false
	arrow_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arrow_wrap.custom_minimum_size = Vector2(0, _home_spec_h(70))
	box.add_child(arrow_wrap)
	_dawnline_finger = arrow_wrap

	var arrow_host := Control.new()
	arrow_host.name = "GuideArrowHost"
	arrow_host.custom_minimum_size = Vector2(0, _home_spec_h(48))
	arrow_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arrow_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow_wrap.add_child(arrow_host)

	var arrow := Label.new()
	arrow.name = "GuideArrow"
	arrow.text = "▲"
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.add_theme_font_size_override("font_size", _home_spec_fs(48))
	arrow.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35, 1.0))
	arrow.add_theme_color_override("font_outline_color", Color(0.05, 0.1, 0.16, 1.0))
	arrow.add_theme_constant_override("outline_size", 10)
	arrow.add_theme_color_override("font_shadow_color", Color(0.4, 0.9, 1.0, 0.75))
	arrow.add_theme_constant_override("shadow_offset_x", 0)
	arrow.add_theme_constant_override("shadow_offset_y", 0)
	arrow.add_theme_constant_override("shadow_outline_size", 12)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow_host.add_child(arrow)

	var tap_lbl := Label.new()
	tap_lbl.name = "GuideTapLabel"
	tap_lbl.text = GameLocale.pick("从这里开始", "Start from here")
	tap_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tap_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tap_lbl.add_theme_font_size_override("font_size", _home_spec_fs(20))
	tap_lbl.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	tap_lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.08, 0.12, 0.95))
	tap_lbl.add_theme_constant_override("outline_size", 5)
	tap_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow_wrap.add_child(tap_lbl)

	var chev := Label.new()
	chev.name = "DawnlineChevron"
	chev.text = "▽"
	chev.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chev.add_theme_font_size_override("font_size", _home_spec_fs(22))
	chev.add_theme_color_override("font_color", Color(0.710, 0.941, 1.0, 0.75))
	chev.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(chev)

	dawn_wrap.gui_input.connect(_on_dawnline_input)
	return box


func _on_dawnline_input(event: InputEvent) -> void:
	if Global.opening_comic_seen:
		return
	if _story_overlay != null and is_instance_valid(_story_overlay):
		return
	var tapped := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped = true
	elif event is InputEventScreenTouch and event.pressed:
		tapped = true
	if not tapped:
		return
	get_viewport().set_input_as_handled()
	_on_dawnline_comic_pressed()


func _on_dawnline_comic_pressed() -> void:
	if Global.opening_comic_seen:
		_refresh_dawnline_comic_hint()
		return
	_hide_dawnline_comic_hint()
	_show_story_intro(false)


func _should_show_dawnline_comic_hint() -> bool:
	return not Global.opening_comic_seen \
		and _selected_tab == TAB_HOME \
		and (_story_overlay == null or not is_instance_valid(_story_overlay)) \
		and (_guide_overlay == null or not is_instance_valid(_guide_overlay))


func _refresh_dawnline_comic_hint() -> void:
	if _should_show_dawnline_comic_hint():
		_show_dawnline_comic_hint()
	else:
		_hide_dawnline_comic_hint()


func _show_dawnline_comic_hint() -> void:
	if _dawnline_glow:
		_dawnline_glow.visible = true
	if _dawnline_finger:
		_dawnline_finger.visible = true
		var tap_lbl := _dawnline_finger.get_node_or_null("GuideTapLabel") as Label
		if tap_lbl:
			tap_lbl.text = GameLocale.pick("从这里开始", "Start from here")
	if _dawnline_hit:
		_dawnline_hit.mouse_filter = Control.MOUSE_FILTER_STOP
	var chev := _home_title_box.get_node_or_null("DawnlineChevron") as Control if _home_title_box else null
	if chev:
		chev.visible = false
	_start_dawnline_hint_tween()


func _hide_dawnline_comic_hint() -> void:
	if _dawnline_hint_tween != null and is_instance_valid(_dawnline_hint_tween):
		_dawnline_hint_tween.kill()
		_dawnline_hint_tween = null
	if _dawnline_glow:
		_dawnline_glow.visible = false
		_dawnline_glow.modulate = Color(1, 1, 1, 1)
	if _dawnline_finger:
		_dawnline_finger.visible = false
		_dawnline_finger.modulate = Color(1, 1, 1, 1)
	var chev := _home_title_box.get_node_or_null("DawnlineChevron") as Control if _home_title_box else null
	if chev:
		chev.visible = true
	if _dawnline_hit and Global.opening_comic_seen:
		_dawnline_hit.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _start_dawnline_hint_tween() -> void:
	if _dawnline_glow == null or _dawnline_finger == null:
		return
	if _dawnline_hint_tween != null and is_instance_valid(_dawnline_hint_tween):
		_dawnline_hint_tween.kill()
		_dawnline_hint_tween = null
	_dawnline_glow.modulate = Color(1, 1, 1, 0.55)
	_dawnline_finger.modulate = Color(1, 1, 1, 1)
	# 等布局完成后再居中 pivot，避免缩放看起来左右偏滑
	call_deferred("_play_dawnline_arrow_tween")


func _play_dawnline_arrow_tween() -> void:
	if _dawnline_glow == null or _dawnline_finger == null:
		return
	if not _dawnline_finger.visible:
		return
	if _dawnline_hint_tween != null and is_instance_valid(_dawnline_hint_tween):
		_dawnline_hint_tween.kill()
	var host := _dawnline_finger.get_node_or_null("GuideArrowHost") as Control
	var arrow := _dawnline_finger.get_node_or_null("GuideArrowHost/GuideArrow") as Control
	if arrow == null:
		arrow = _dawnline_finger.get_node_or_null("GuideArrow") as Control
	var base_y := 0.0
	var bob := float(_home_spec_h(8))
	if arrow != null and host != null:
		arrow.reset_size()
		# 水平居中于 DAWNLINE 标题轴
		var ax := (host.size.x - arrow.size.x) * 0.5
		var ay := (host.size.y - arrow.size.y) * 0.5
		arrow.position = Vector2(ax, ay)
		arrow.pivot_offset = arrow.size * 0.5
		arrow.scale = Vector2.ONE
		base_y = ay
	_dawnline_hint_tween = create_tween()
	_dawnline_hint_tween.set_loops()
	_dawnline_hint_tween.tween_property(_dawnline_glow, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_dawnline_hint_tween.parallel().tween_property(_dawnline_finger, "modulate:a", 1.0, 0.55)
	if arrow != null:
		_dawnline_hint_tween.parallel().tween_property(arrow, "scale", Vector2(1.12, 1.12), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_dawnline_hint_tween.parallel().tween_property(arrow, "position:y", base_y - bob, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_dawnline_hint_tween.tween_property(_dawnline_glow, "modulate:a", 0.5, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_dawnline_hint_tween.parallel().tween_property(_dawnline_finger, "modulate:a", 0.75, 0.55)
	if arrow != null:
		_dawnline_hint_tween.parallel().tween_property(arrow, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_dawnline_hint_tween.parallel().tween_property(arrow, "position:y", base_y, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


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
	var is_runner := tab_id == TAB_CHARACTER
	if _page_scrim:
		_page_scrim.visible = not is_home and not is_runner
		_page_scrim.color = Color(0.016, 0.027, 0.051, 0.40) if is_map else Color(0.016, 0.027, 0.051, 0.55)
	if _bg_bottom_fade:
		_bg_bottom_fade.visible = not is_runner
	if _bg_bottom_deep:
		_bg_bottom_deep.visible = not is_runner
	if _home_overlay:
		_home_overlay.visible = is_home
	if _home_title_box:
		_home_title_box.visible = is_home
	_refresh_dawnline_comic_hint()
	if _map_overlay:
		_map_overlay.visible = is_map
	if _page_scroll:
		_page_scroll.visible = not is_home and not is_map
		_page_scroll.vertical_scroll_mode = (
			ScrollContainer.SCROLL_MODE_DISABLED if (is_home or is_runner)
			else ScrollContainer.SCROLL_MODE_AUTO
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
			call_deferred("_maybe_show_transport_intro")
		TAB_TASKS:
			_page_title.text = ""
			_page_subtitle.text = ""
			_build_tasks_page()
			call_deferred("_maybe_show_transport_intro")
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
	_apply_mobile_layout()
	if is_runner:
		call_deferred("_refit_runner_page_host")
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
	var active_id := Global.get_selected_character_id()
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	if not CharacterRoster.is_unlocked(active_id, unlocked):
		active_id = CharacterRoster.CHAR_ELSA
	var character: Dictionary = CharacterRoster.get_character(active_id)
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
	if planet_id == "glass_desert":
		return GameLocale.pick("无尽晶砂漠", "Crystal Waste")
	var localized := GameLocale.field(meta, "name", "name_en")
	return localized if localized != "" else "Unknown Map"


func _home_outpost_display_name(location_id: String, fallback: String) -> String:
	match location_id:
		"dome":
			return GameLocale.pick("居民穹顶", "Habitat Dome")
		"reservoir":
			return GameLocale.pick("水源据点", "Water Station")
		"medical":
			return GameLocale.pick("医疗据点", "Medical Station")
		"relay":
			return GameLocale.pick("星火中继站", "Ember Relay Station")
		"gate":
			return GameLocale.pick("防御哨站", "Defense Outpost")
		_:
			return fallback if fallback != "" else GameLocale.pick("据点", "Outpost")


func _home_outpost_status(planet_id: String, location_id: String) -> Dictionary:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if cfg == null or not cfg.has_method("build_detail_payload"):
		return {"title": location_id, "status_short": GameLocale.pick("未知", "Unknown")}
	var completed := Global.get_completed_runner_locations(planet_id).has(location_id)
	var revealed := Global.get_revealed_exploration_locations(planet_id, ["dome"]).has(location_id)
	var payload: Dictionary = cfg.build_detail_payload(location_id, revealed, completed)
	var status_short := GameLocale.pick("已点亮", "Lit") if completed else (GameLocale.pick("运输修复中", "Repairing") if revealed else GameLocale.pick("未开放", "Locked"))
	var title := GameLocale.field(payload, "title", "title_en")
	if title == "":
		title = Global.get_outpost_display_name(planet_id, location_id)
	return {
		"title": title if title != "" else location_id,
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
			return GameLocale.pick("净水救援", "Water Rescue")
		"medical":
			return GameLocale.pick("医疗驰援", "Medical Aid")
		"relay":
			return GameLocale.pick("星火中继", "Ember Relay")
		"gate":
			return GameLocale.pick("防线加固", "Defense Reinforce")
		_:
			var task_type := String(mission.get("task_type", ""))
			if task_type != "":
				return task_type
			var cargo := GameLocale.field(mission, "cargo_name", "cargo_name_en")
			return cargo if cargo != "" else GameLocale.pick("运输任务", "Transport")


func _home_repair_progress(planet_id: String, location_id: String) -> Dictionary:
	# 修复进度对应当前任务据点（起点），与地图详情 payload 同源
	var status := _home_outpost_status(planet_id, location_id)
	return {
		"current": int(status.get("repair_current", 0)),
		"total": maxi(int(status.get("repair_total", 1)), 1),
	}


func _home_mission_thumb(location_id: String) -> Texture2D:
	var path := String(HOME_MISSION_THUMB_BY_LOCATION.get(location_id, HOME_MISSION_THUMB_PATH))
	var tex := _load_header_texture(path)
	if tex != null:
		return tex
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

	box.add_child(_build_runner_style_dropdown_row(GameLocale.pick("跑道外观", "Track Look"), true))
	box.add_child(_build_runner_style_dropdown_row(GameLocale.pick("场景背景", "Backdrop"), false))


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
				_show_toast(GameLocale.pick("跑道：%s" % Global.get_runner_road_style_label(), "Track: %s" % Global.get_runner_road_style_label()))
		)
	else:
		Global.populate_runner_background_style_option(option)
		option.item_selected.connect(func(index: int) -> void:
			if index >= 0 and index < Global.RUNNER_BACKGROUND_STYLE_ORDER.size():
				Global.set_runner_background_style(Global.RUNNER_BACKGROUND_STYLE_ORDER[index])
				_show_toast(GameLocale.pick("背景：%s" % Global.get_runner_background_style_label(), "Backdrop: %s" % Global.get_runner_background_style_label()))
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

	_attach_transport_help_button(_map_title_host)


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
	_page_box.add_theme_constant_override("separation", _tasks_spec_h(12))
	_build_tasks_page_header()
	_build_tasks_sub_tabs()
	_tasks_missions_box = VBoxContainer.new()
	_tasks_missions_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tasks_missions_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tasks_missions_box.add_theme_constant_override("separation", _tasks_spec_h(10))
	_page_box.add_child(_tasks_missions_box)
	_tasks_daily_box = VBoxContainer.new()
	_tasks_daily_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tasks_daily_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tasks_daily_box.add_theme_constant_override("separation", _tasks_spec_h(12))
	_tasks_daily_box.visible = false
	_page_box.add_child(_tasks_daily_box)
	_build_tasks_ritual_footer()
	_populate_tasks_missions(planet_id)
	_populate_tasks_daily(planet_id)
	_refresh_tasks_sub_tab_visibility()


func _build_tasks_page_header() -> void:
	var wrap := Control.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.custom_minimum_size = Vector2(0, _tasks_spec_h(72))
	_page_box.add_child(wrap)

	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", _tasks_spec_h(6))
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(col)

	var title := Label.new()
	title.text = "TASKS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title_ls := LabelSettings.new()
	title_ls.font_size = _tasks_spec_fs(30)
	title_ls.font_color = Color(0.965, 0.984, 1.0)
	title_ls.shadow_color = Color(0.667, 0.894, 0.98, 0.45)
	title_ls.shadow_size = 10
	title.label_settings = title_ls
	title.add_theme_constant_override("letter_spacing", _tasks_spec_em(30, 0.24))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(title)

	var divider := Control.new()
	divider.custom_minimum_size = Vector2(0, _tasks_spec_h(14))
	divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(divider)
	var line := ColorRect.new()
	line.color = Color(0.627, 0.863, 0.98, 0.55)
	line.set_anchors_preset(Control.PRESET_CENTER)
	line.offset_left = -int(_tasks_spec_w(120))
	line.offset_right = int(_tasks_spec_w(120))
	line.offset_top = -1
	line.offset_bottom = 1
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.add_child(line)
	var diamond := ColorRect.new()
	diamond.color = Color(0.95, 0.98, 1.0)
	diamond.custom_minimum_size = Vector2(_tasks_spec_w(8), _tasks_spec_w(8))
	diamond.rotation = deg_to_rad(45.0)
	diamond.set_anchors_preset(Control.PRESET_CENTER)
	diamond.offset_left = -int(_tasks_spec_w(4))
	diamond.offset_right = int(_tasks_spec_w(4))
	diamond.offset_top = -int(_tasks_spec_w(4))
	diamond.offset_bottom = int(_tasks_spec_w(4))
	diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.add_child(diamond)

	_attach_transport_help_button(wrap)


func _build_tasks_ritual_footer() -> void:
	_tasks_ritual_footer = PanelContainer.new()
	_tasks_ritual_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tasks_ritual_footer.size_flags_vertical = Control.SIZE_SHRINK_END
	_tasks_ritual_footer.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.016, 0.035, 0.062, 0.52)
	panel_style.border_color = Color(0.667, 0.902, 1.0, 0.26)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(_tasks_spec_w(14))
	panel_style.content_margin_left = _tasks_spec_w(18)
	panel_style.content_margin_right = _tasks_spec_w(12)
	panel_style.content_margin_top = _tasks_spec_h(10)
	panel_style.content_margin_bottom = _tasks_spec_h(16)
	panel_style.shadow_color = Color(0.557, 0.882, 0.969, 0.12)
	panel_style.shadow_size = 8
	_tasks_ritual_footer.add_theme_stylebox_override("panel", panel_style)
	_page_box.add_child(_tasks_ritual_footer)

	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", _tasks_spec_h(8))
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tasks_ritual_footer.add_child(col)

	var tab_row := HBoxContainer.new()
	tab_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(tab_row)
	var tab_spacer := Control.new()
	tab_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_row.add_child(tab_spacer)

	_tasks_completed_btn = Button.new()
	_tasks_completed_btn.text = GameLocale.t("tasks_completed_btn")
	_tasks_completed_btn.focus_mode = Control.FOCUS_NONE
	_tasks_completed_btn.custom_minimum_size = Vector2(_tasks_spec_w(96), _tasks_spec_h(28))
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.024, 0.055, 0.098, 0.9)
	btn_style.border_color = Color(0.627, 0.863, 0.98, 0.45)
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(_tasks_spec_w(8))
	btn_style.content_margin_left = _tasks_spec_w(10)
	btn_style.content_margin_right = _tasks_spec_w(10)
	btn_style.content_margin_top = _tasks_spec_h(4)
	btn_style.content_margin_bottom = _tasks_spec_h(4)
	_tasks_completed_btn.add_theme_stylebox_override("normal", btn_style)
	_tasks_completed_btn.add_theme_stylebox_override("hover", btn_style)
	_tasks_completed_btn.add_theme_stylebox_override("pressed", btn_style)
	_tasks_completed_btn.add_theme_font_size_override("font_size", _tasks_spec_fs(11))
	_tasks_completed_btn.add_theme_color_override("font_color", Color(0.627, 0.863, 0.98, 0.92))
	_tasks_completed_btn.pressed.connect(_open_tasks_completed_overlay)
	tab_row.add_child(_tasks_completed_btn)

	col.add_child(_make_tasks_ritual_divider())

	var title := Label.new()
	title.text = GameLocale.t("tasks_ritual_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", _tasks_spec_fs(15))
	title.add_theme_color_override("font_color", UI_CYAN_SOFT)
	title.add_theme_constant_override("letter_spacing", _tasks_spec_em(15, 0.42))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(title)

	var lead := Label.new()
	lead.text = GameLocale.t("tasks_ritual_lead")
	lead.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lead.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lead.add_theme_font_size_override("font_size", _tasks_spec_fs(17))
	lead.add_theme_color_override("font_color", UI_ICE)
	lead.add_theme_color_override("font_shadow_color", Color(0.557, 0.882, 0.969, 0.35))
	lead.add_theme_constant_override("shadow_outline_size", 6)
	lead.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(lead)

	var body := Label.new()
	body.text = GameLocale.t("tasks_ritual_body")
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", _tasks_spec_fs(13))
	body.add_theme_color_override("font_color", UI_MUTED)
	body.add_theme_constant_override("line_spacing", _tasks_spec_h(4))
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(body)

	col.add_child(_make_tasks_ritual_divider())

	var seal := Label.new()
	seal.text = GameLocale.t("tasks_ritual_seal")
	seal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	seal.add_theme_font_size_override("font_size", _tasks_spec_fs(12))
	seal.add_theme_color_override("font_color", Color(0.627, 0.863, 0.98, 0.78))
	seal.add_theme_constant_override("letter_spacing", _tasks_spec_em(12, 0.18))
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(seal)


func _make_tasks_ritual_divider() -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(0, _tasks_spec_h(12))
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line := ColorRect.new()
	line.color = Color(0.627, 0.863, 0.98, 0.42)
	line.set_anchors_preset(Control.PRESET_CENTER)
	line.offset_left = -int(_tasks_spec_w(88))
	line.offset_right = int(_tasks_spec_w(88))
	line.offset_top = -1
	line.offset_bottom = 1
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(line)
	var diamond := Label.new()
	diamond.text = "◆"
	diamond.set_anchors_preset(Control.PRESET_CENTER)
	diamond.offset_left = -int(_tasks_spec_w(8))
	diamond.offset_right = int(_tasks_spec_w(8))
	diamond.offset_top = -int(_tasks_spec_h(8))
	diamond.offset_bottom = int(_tasks_spec_h(8))
	diamond.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	diamond.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	diamond.add_theme_font_size_override("font_size", _tasks_spec_fs(9))
	diamond.add_theme_color_override("font_color", UI_CYAN)
	diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(diamond)
	return wrap


func _collect_archived_completed_missions(planet_id: String) -> Array:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if cfg == null or not cfg.has_method("get_mission_by_id"):
		return []
	var done_raw: Array = Global.completed_missions_by_planet.get(planet_id, [])
	var missions: Array = []
	for raw in done_raw:
		var mission_id := String(raw)
		if mission_id == "":
			continue
		if Global.is_mission_reward_pending(planet_id, mission_id):
			continue
		var mission: Dictionary = cfg.get_mission_by_id(mission_id)
		if mission.is_empty():
			continue
		missions.append(mission)
	missions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 999)) < int(b.get("order", 999))
	)
	return missions


func _ensure_tasks_completed_overlay() -> void:
	if _tasks_completed_overlay != null:
		return
	_tasks_completed_overlay = Control.new()
	_tasks_completed_overlay.name = "TasksCompletedOverlay"
	_tasks_completed_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tasks_completed_overlay.visible = false
	_tasks_completed_overlay.z_index = 235
	_tasks_completed_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_root.add_child(_tasks_completed_overlay)

	var mask := ColorRect.new()
	mask.color = Color(0.008, 0.02, 0.039, 0.62)
	mask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mask.mouse_filter = Control.MOUSE_FILTER_STOP
	mask.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			_close_tasks_completed_overlay()
		elif event is InputEventScreenTouch and event.pressed:
			_close_tasks_completed_overlay()
	)
	_tasks_completed_overlay.add_child(mask)

	var sheet := PanelContainer.new()
	sheet.set_anchors_preset(Control.PRESET_CENTER)
	sheet.offset_left = -int(_tasks_spec_w(300))
	sheet.offset_right = int(_tasks_spec_w(300))
	sheet.offset_top = -int(_tasks_spec_h(280))
	sheet.offset_bottom = int(_tasks_spec_h(280))
	sheet.mouse_filter = Control.MOUSE_FILTER_STOP
	var sheet_style := StyleBoxFlat.new()
	sheet_style.bg_color = Color(0.031, 0.067, 0.118, 0.96)
	sheet_style.border_color = Color(0.667, 0.902, 1.0, 0.42)
	sheet_style.set_border_width_all(1)
	sheet_style.set_corner_radius_all(_tasks_spec_w(16))
	sheet_style.content_margin_left = _tasks_spec_w(14)
	sheet_style.content_margin_right = _tasks_spec_w(14)
	sheet_style.content_margin_top = _tasks_spec_h(12)
	sheet_style.content_margin_bottom = _tasks_spec_h(12)
	sheet.add_theme_stylebox_override("panel", sheet_style)
	_tasks_completed_overlay.add_child(sheet)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", _tasks_spec_h(10))
	sheet.add_child(root)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", _tasks_spec_w(8))
	root.add_child(title_row)
	var title := Label.new()
	title.text = GameLocale.t("tasks_completed_title")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
	title.add_theme_color_override("font_color", UI_ICE)
	title_row.add_child(title)
	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.custom_minimum_size = Vector2(_tasks_spec_w(34), _tasks_spec_w(34))
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color(0.08, 0.14, 0.22, 0.72)
	close_style.border_color = Color(0.627, 0.863, 0.98, 0.35)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(_tasks_spec_w(8))
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	close_btn.add_theme_color_override("font_color", UI_MUTED)
	close_btn.pressed.connect(_close_tasks_completed_overlay)
	title_row.add_child(close_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_tasks_completed_list_box = VBoxContainer.new()
	_tasks_completed_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tasks_completed_list_box.add_theme_constant_override("separation", _tasks_spec_h(6))
	scroll.add_child(_tasks_completed_list_box)


func _populate_tasks_completed_list(planet_id: String = "glass_desert") -> void:
	if _tasks_completed_list_box == null:
		return
	for child in _tasks_completed_list_box.get_children():
		child.queue_free()
	var missions: Array = _collect_archived_completed_missions(planet_id)
	if missions.is_empty():
		_add_muted_label(_tasks_completed_list_box, GameLocale.t("tasks_completed_empty"))
		return
	for mission in missions:
		if mission is Dictionary:
			_add_tasks_completed_row(planet_id, mission as Dictionary)


func _add_tasks_completed_row(_planet_id: String, mission: Dictionary) -> void:
	var profile: Dictionary = MissionTypes.resolve(mission)
	var location_id := String(mission.get("location_id", "dome"))
	var type_en := String(mission.get("task_type", profile.get("task_type", "Supply Run"))).to_upper()
	if not type_en.ends_with(" RUN") and "RUN" not in type_en:
		type_en = "%s RUN" % type_en.replace(" RUN", "")
	var outpost := _home_outpost_display_name(
		location_id,
		String(mission.get("target_hearth", mission.get("source_hearth", location_id)))
	)
	var reward := int(mission.get("base_reward", profile.get("base_reward", 50)))
	var accent := _mission_type_accent(String(mission.get("task_type", "")))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, _tasks_spec_h(52))
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.027, 0.063, 0.114, 0.5)
	panel_style.border_color = Color(UI_MISSION_DONE.r, UI_MISSION_DONE.g, UI_MISSION_DONE.b, 0.28)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(_tasks_spec_w(10))
	panel_style.content_margin_left = _tasks_spec_w(10)
	panel_style.content_margin_right = _tasks_spec_w(10)
	panel_style.content_margin_top = _tasks_spec_h(6)
	panel_style.content_margin_bottom = _tasks_spec_h(6)
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.modulate = Color(0.9, 0.92, 0.95, 0.86)
	_tasks_completed_list_box.add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", _tasks_spec_w(8))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(row)

	var icon_lbl := Label.new()
	icon_lbl.text = _mission_type_icon_char(String(mission.get("task_type", "")))
	icon_lbl.custom_minimum_size = Vector2(_tasks_spec_w(28), _tasks_spec_w(28))
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(16))
	icon_lbl.add_theme_color_override("font_color", accent)
	row.add_child(icon_lbl)

	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", _tasks_spec_h(2))
	row.add_child(body)
	var name_lbl := Label.new()
	name_lbl.text = type_en
	name_lbl.clip_text = true
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(15))
	name_lbl.add_theme_color_override("font_color", UI_TEXT)
	body.add_child(name_lbl)
	var sub_lbl := Label.new()
	sub_lbl.text = outpost
	sub_lbl.clip_text = true
	sub_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sub_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(12))
	sub_lbl.add_theme_color_override("font_color", UI_MUTED)
	body.add_child(sub_lbl)

	var right := HBoxContainer.new()
	right.add_theme_constant_override("separation", _tasks_spec_w(6))
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(right)
	var reward_lbl := Label.new()
	reward_lbl.text = "★ %d" % reward
	reward_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(13))
	reward_lbl.add_theme_color_override("font_color", UI_CYAN_SOFT)
	right.add_child(reward_lbl)
	var done_lbl := Label.new()
	done_lbl.text = "DONE"
	done_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(12))
	done_lbl.add_theme_color_override("font_color", UI_MISSION_DONE)
	right.add_child(done_lbl)


func _open_tasks_completed_overlay() -> void:
	_ensure_tasks_completed_overlay()
	_populate_tasks_completed_list("glass_desert")
	if _bottom_nav_root:
		_bottom_nav_root.visible = false
	if _page_scrim:
		_page_scrim.visible = true
		_page_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	if _ui_root and _tasks_completed_overlay.get_parent() == _ui_root:
		_ui_root.move_child(_tasks_completed_overlay, -1)
	_tasks_completed_overlay.visible = true


func _close_tasks_completed_overlay() -> void:
	if _tasks_completed_overlay:
		_tasks_completed_overlay.visible = false
	if _bottom_nav_root:
		_bottom_nav_root.visible = true
	if _page_scrim:
		_page_scrim.visible = _selected_tab != TAB_HOME and _selected_tab != TAB_MAP
		_page_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _build_tasks_sub_tabs() -> void:
	var outer := PanelContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var outer_style := StyleBoxFlat.new()
	outer_style.bg_color = Color(0.039, 0.078, 0.137, 0.55)
	outer_style.border_color = Color(0.667, 0.902, 1.0, 0.28)
	outer_style.set_border_width_all(1)
	outer_style.set_corner_radius_all(_tasks_spec_w(14))
	outer_style.content_margin_left = _tasks_spec_w(4)
	outer_style.content_margin_right = _tasks_spec_w(4)
	outer_style.content_margin_top = _tasks_spec_h(4)
	outer_style.content_margin_bottom = _tasks_spec_h(4)
	outer.add_theme_stylebox_override("panel", outer_style)
	_page_box.add_child(outer)

	var tabs := HBoxContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_theme_constant_override("separation", _tasks_spec_w(6))
	outer.add_child(tabs)
	_tasks_tab_missions_btn = Button.new()
	_tasks_tab_missions_btn.text = "MISSIONS"
	_tasks_tab_missions_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tasks_tab_missions_btn.focus_mode = Control.FOCUS_NONE
	_tasks_tab_missions_btn.pressed.connect(_switch_tasks_sub_tab.bind("missions"))
	tabs.add_child(_tasks_tab_missions_btn)
	_tasks_tab_daily_btn = Button.new()
	_tasks_tab_daily_btn.text = "DAILY"
	_tasks_tab_daily_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tasks_tab_daily_btn.focus_mode = Control.FOCUS_NONE
	_tasks_tab_daily_btn.clip_contents = false
	_tasks_tab_daily_btn.pressed.connect(_switch_tasks_sub_tab.bind("daily"))
	tabs.add_child(_tasks_tab_daily_btn)
	_ensure_daily_tab_red_dot()
	_style_tasks_sub_tab_buttons()
	_refresh_daily_tab_red_dot()


func _style_tasks_sub_tab_buttons() -> void:
	for entry in [
		{"btn": _tasks_tab_missions_btn, "id": "missions"},
		{"btn": _tasks_tab_daily_btn, "id": "daily"},
	]:
		var button: Button = entry["btn"]
		if button == null:
			continue
		var selected := String(entry["id"]) == _tasks_sub_tab
		var style := StyleBoxFlat.new()
		if selected:
			style.bg_color = Color(0.078, 0.157, 0.255, 0.62)
			style.border_color = Color(0.667, 0.902, 1.0, 0.5)
			style.shadow_color = Color(0.557, 0.882, 0.969, 0.28)
			style.shadow_size = 6
		else:
			style.bg_color = Color(0.02, 0.04, 0.07, 0.0)
			style.border_color = Color(0.667, 0.902, 1.0, 0.0)
		style.set_border_width_all(1)
		style.set_corner_radius_all(_tasks_spec_w(12))
		style.content_margin_top = _tasks_spec_h(10)
		style.content_margin_bottom = _tasks_spec_h(10)
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.custom_minimum_size = Vector2(0, _tasks_spec_h(44))
		button.add_theme_font_size_override("font_size", _tasks_spec_fs(18))
		button.add_theme_color_override("font_color", UI_ICE if selected else UI_MUTED)


func _switch_tasks_sub_tab(tab_id: String) -> void:
	_tasks_sub_tab = tab_id
	_style_tasks_sub_tab_buttons()
	_refresh_tasks_sub_tab_visibility()
	if tab_id == "daily":
		call_deferred("_refresh_tasks_daily")


func _refresh_tasks_sub_tab_visibility() -> void:
	if _tasks_missions_box:
		_tasks_missions_box.visible = _tasks_sub_tab == "missions"
	if _tasks_daily_box:
		_tasks_daily_box.visible = _tasks_sub_tab == "daily"
	if _tasks_ritual_footer:
		_tasks_ritual_footer.visible = _tasks_sub_tab == "missions"


func _refresh_tasks_mission_cards(planet_id: String = "glass_desert") -> void:
	if _tasks_missions_box != null and is_instance_valid(_tasks_missions_box):
		_populate_tasks_missions(planet_id)
		return
	if _selected_tab == TAB_TASKS:
		_show_tab(TAB_TASKS, true)


func _populate_tasks_missions(planet_id: String) -> void:
	if _tasks_missions_box == null:
		return
	for child in _tasks_missions_box.get_children():
		child.queue_free()
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	Global.ensure_mission_dispatch_ready(planet_id)
	for location_id in Global.list_pending_light_ceremonies(planet_id):
		_add_tasks_light_ceremony_card(planet_id, location_id)
	var mission_ids: Array[String] = MissionDispatch.list_tasks_panel_missions(planet_id)
	var active := Global.get_active_mission(planet_id)
	var active_mission_id := String(active.get("mission_id", ""))
	var full_unlock := Global.is_dev_full_unlock()
	if active_mission_id != "" and not mission_ids.has(active_mission_id) \
			and (full_unlock or mission_ids.size() < MissionDispatch.BOARD_SLOT_COUNT):
		mission_ids.insert(0, active_mission_id)
	if not full_unlock and mission_ids.size() > MissionDispatch.BOARD_SLOT_COUNT:
		mission_ids = mission_ids.slice(0, MissionDispatch.BOARD_SLOT_COUNT)
	var shown := 0
	for mission_id in mission_ids:
		if not full_unlock and shown >= MissionDispatch.BOARD_SLOT_COUNT:
			break
		if cfg == null or not cfg.has_method("get_mission_by_id"):
			continue
		var mission: Dictionary = cfg.get_mission_by_id(mission_id)
		if mission.is_empty():
			continue
		if Global.is_mission_completed(planet_id, mission_id) \
				and not Global.is_mission_reward_pending(planet_id, mission_id):
			continue
		_add_tasks_mission_card(planet_id, mission)
		shown += 1
	if shown == 0 and active_mission_id != "" and cfg != null and cfg.has_method("get_mission_by_id"):
		var active_mission: Dictionary = cfg.get_mission_by_id(active_mission_id)
		if not active_mission.is_empty() \
				and not (Global.is_mission_completed(planet_id, active_mission_id) \
				and not Global.is_mission_reward_pending(planet_id, active_mission_id)):
			_add_tasks_mission_card(planet_id, active_mission)
			shown += 1
	var pending_light := Global.list_pending_light_ceremonies(planet_id)
	if shown == 0 and pending_light.is_empty():
		_add_muted_label(
			_tasks_missions_box,
			GameLocale.t("tasks_empty")
		)


func _add_tasks_light_ceremony_card(planet_id: String, location_id: String) -> void:
	var outpost_name := Global.get_outpost_display_name(planet_id, location_id)
	var accent := Color(0.98, 0.78, 0.28)
	var panel := _make_tasks_mission_card_shell(accent, false, true)
	_tasks_missions_box.add_child(panel)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", _tasks_spec_w(8))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(row)

	var accent_bar := ColorRect.new()
	accent_bar.custom_minimum_size = Vector2(_tasks_spec_w(4), _tasks_spec_h(52))
	accent_bar.color = accent
	accent_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(accent_bar)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(_tasks_spec_w(52), _tasks_spec_w(52))
	icon_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(0.16, 0.12, 0.04, 0.72)
	icon_style.border_color = Color(accent.r, accent.g, accent.b, 0.55)
	icon_style.set_border_width_all(1)
	icon_style.set_corner_radius_all(_tasks_spec_w(10))
	icon_wrap.add_theme_stylebox_override("panel", icon_style)
	row.add_child(icon_wrap)
	var icon_lbl := Label.new()
	icon_lbl.text = "✦"
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(22))
	icon_lbl.add_theme_color_override("font_color", accent)
	icon_wrap.add_child(icon_lbl)

	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", _tasks_spec_h(3))
	row.add_child(body)
	var name_lbl := Label.new()
	name_lbl.text = GameLocale.pick("点亮%s" % outpost_name, "Light %s" % outpost_name)
	name_lbl.clip_text = true
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
	name_lbl.add_theme_color_override("font_color", UI_TEXT)
	body.add_child(name_lbl)
	var obj_lbl := Label.new()
	obj_lbl.text = GameLocale.pick("运输进度已满 · 前往地图点亮据点", "Transport complete · light the outpost on Map")
	obj_lbl.clip_text = true
	obj_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	obj_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(14))
	obj_lbl.add_theme_color_override("font_color", UI_MUTED)
	body.add_child(obj_lbl)

	var action := Button.new()
	action.text = "LIGHT UP"
	action.focus_mode = Control.FOCUS_NONE
	action.custom_minimum_size = Vector2(_tasks_spec_w(128), _tasks_spec_h(44))
	action.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.94, 0.72, 0.22, 0.92)
	btn_style.border_color = Color(0.98, 0.84, 0.42, 0.95)
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(_tasks_spec_w(10))
	action.add_theme_stylebox_override("normal", btn_style)
	action.add_theme_stylebox_override("hover", btn_style)
	action.add_theme_stylebox_override("pressed", btn_style)
	action.add_theme_color_override("font_color", Color(0.12, 0.08, 0.02))
	action.add_theme_font_size_override("font_size", _tasks_spec_fs(16))
	action.pressed.connect(_on_tasks_light_ceremony_pressed.bind(planet_id, location_id))
	row.add_child(action)


func _on_tasks_light_ceremony_pressed(planet_id: String, location_id: String) -> void:
	if not Global.is_map_light_ceremony_pending(planet_id, location_id):
		_show_toast(GameLocale.pick("该据点已点亮或尚未完成运输", "Outpost already lit or transport incomplete"))
		_refresh_tasks_mission_cards(planet_id)
		return
	Global.pending_map_light_focus = location_id
	_open_planet_map(planet_id)


func _populate_tasks_daily(planet_id: String) -> void:
	if _tasks_daily_box == null:
		return
	for child in _tasks_daily_box.get_children():
		child.queue_free()
	Global.ensure_daily_tasks_fresh()
	for entry in _daily_task_defs():
		_add_tasks_daily_row(entry)
	var refresh := Label.new()
	refresh.text = "New tasks in %s" % _daily_tasks_reset_countdown()
	refresh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	refresh.add_theme_font_size_override("font_size", _tasks_spec_fs(15))
	refresh.add_theme_color_override("font_color", UI_MUTED)
	_tasks_daily_box.add_child(refresh)
	_refresh_daily_tab_red_dot()


func _has_pending_daily_rewards() -> bool:
	Global.ensure_daily_tasks_fresh()
	for entry in _daily_task_defs():
		var task_id := String(entry.get("id", ""))
		var target := int(entry.get("target", 1))
		if task_id != "" and Global.is_daily_task_reward_pending(task_id, target):
			return true
	return false


func _ensure_daily_tab_red_dot() -> void:
	if _tasks_tab_daily_btn == null:
		return
	if _tasks_daily_red_dot != null and is_instance_valid(_tasks_daily_red_dot):
		return
	var existing := _tasks_tab_daily_btn.get_node_or_null("DailyRedDot") as Control
	if existing != null:
		_tasks_daily_red_dot = existing
		return
	var dot := Panel.new()
	dot.name = "DailyRedDot"
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.custom_minimum_size = Vector2(_tasks_spec_w(14), _tasks_spec_w(14))
	dot.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	dot.anchor_left = 1.0
	dot.anchor_right = 1.0
	dot.anchor_top = 0.0
	dot.anchor_bottom = 0.0
	dot.offset_left = -_tasks_spec_w(22)
	dot.offset_right = -_tasks_spec_w(8)
	dot.offset_top = _tasks_spec_h(6)
	dot.offset_bottom = _tasks_spec_h(20)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.94, 0.22, 0.28, 1.0)
	style.border_color = Color(1.0, 0.85, 0.88, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(999)
	dot.add_theme_stylebox_override("panel", style)
	dot.visible = false
	_tasks_tab_daily_btn.add_child(dot)
	_tasks_daily_red_dot = dot


func _refresh_daily_tab_red_dot() -> void:
	_ensure_daily_tab_red_dot()
	if _tasks_daily_red_dot == null:
		return
	_tasks_daily_red_dot.visible = _has_pending_daily_rewards()


func _daily_task_defs() -> Array:
	return [
		{"id": "daily_login", "name": "DAILY LOGIN", "obj": "Log in today", "target": 1, "reward": 20},
		{"id": "first_run", "name": "FIRST RUN", "obj": "Complete 1 transport run", "target": 1, "reward": 30},
		{"id": "safe_courier", "name": "SAFE COURIER", "obj": "Finish a run with cargo integrity ≥ 90%", "target": 1, "reward": 40},
		{"id": "spark_collector", "name": "SPARK COLLECTOR", "obj": "Collect 100 Star Coins in runs", "target": 100, "reward": 30},
	]


func _daily_tasks_reset_countdown() -> String:
	var now := Time.get_datetime_dict_from_system()
	var sec_now := int(now.get("hour", 0)) * 3600 + int(now.get("minute", 0)) * 60 + int(now.get("second", 0))
	var sec_left := maxi(0, 86400 - sec_now)
	var h := sec_left / 3600
	var m := (sec_left % 3600) / 60
	var s := sec_left % 60
	return "%02d:%02d:%02d" % [h, m, s]


func _refresh_tasks_daily() -> void:
	_populate_tasks_daily("glass_desert")


func _add_tasks_daily_row(entry: Dictionary) -> void:
	var task_id := String(entry.get("id", ""))
	var target := maxi(1, int(entry.get("target", 1)))
	var reward := int(entry.get("reward", 0))
	var prog_now := Global.get_daily_task_progress(task_id, target)
	var is_done := Global.is_daily_task_complete(task_id, target)
	var reward_pending := Global.is_daily_task_reward_pending(task_id, target)
	var claimed := Global.is_daily_task_claimed(task_id)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.clip_contents = true
	panel.custom_minimum_size = Vector2(0, _tasks_spec_h(92))
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.027, 0.063, 0.114, 0.62)
	if reward_pending:
		panel_style.border_color = Color(ClaimButtonUI.BORDER.r, ClaimButtonUI.BORDER.g, ClaimButtonUI.BORDER.b, 0.72)
	elif is_done:
		panel_style.border_color = Color(UI_MISSION_DONE.r, UI_MISSION_DONE.g, UI_MISSION_DONE.b, 0.35)
	else:
		panel_style.border_color = Color(0.588, 0.843, 1.0, 0.28)
	panel_style.set_border_width_all(1 if not reward_pending else 2)
	panel_style.set_corner_radius_all(_tasks_spec_w(12))
	panel_style.content_margin_left = _tasks_spec_w(12)
	panel_style.content_margin_right = _tasks_spec_w(10)
	panel_style.content_margin_top = _tasks_spec_h(10)
	panel_style.content_margin_bottom = _tasks_spec_h(10)
	panel.add_theme_stylebox_override("panel", panel_style)
	if is_done and not reward_pending:
		panel.modulate = Color(0.88, 0.9, 0.94, 0.82)
	_tasks_daily_box.add_child(panel)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", _tasks_spec_w(10))
	panel.add_child(row)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(_tasks_spec_w(52), _tasks_spec_w(52))
	icon_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(0.063, 0.137, 0.227, 0.6)
	icon_style.border_color = Color(ClaimButtonUI.BORDER.r, ClaimButtonUI.BORDER.g, ClaimButtonUI.BORDER.b, 0.55 if reward_pending else (0.3 if not is_done else 0.45))
	icon_style.set_border_width_all(1)
	icon_style.set_corner_radius_all(_tasks_spec_w(10))
	icon_wrap.add_theme_stylebox_override("panel", icon_style)
	row.add_child(icon_wrap)
	var icon_lbl := Label.new()
	icon_lbl.text = "◆"
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
	if claimed:
		icon_lbl.add_theme_color_override("font_color", Color(UI_CYAN.r, UI_CYAN.g, UI_CYAN.b, 0.42))
	elif reward_pending:
		icon_lbl.add_theme_color_override("font_color", UI_CYAN_SOFT)
	elif is_done:
		icon_lbl.add_theme_color_override("font_color", Color(UI_CYAN.r, UI_CYAN.g, UI_CYAN.b, 0.55))
	else:
		icon_lbl.add_theme_color_override("font_color", UI_CYAN)
	icon_wrap.add_child(icon_lbl)

	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", _tasks_spec_h(4))
	row.add_child(body)
	var title := Label.new()
	title.text = String(entry.get("name", ""))
	title.clip_text = true
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
	title.add_theme_color_override("font_color", UI_TEXT)
	body.add_child(title)
	var obj := Label.new()
	obj.text = String(entry.get("obj", ""))
	obj.clip_text = true
	obj.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	obj.add_theme_font_size_override("font_size", _tasks_spec_fs(14))
	obj.add_theme_color_override("font_color", UI_MUTED)
	body.add_child(obj)

	var prog_row := HBoxContainer.new()
	prog_row.add_theme_constant_override("separation", _tasks_spec_w(8))
	body.add_child(prog_row)
	var prog_num := Label.new()
	prog_num.text = "%d / %d" % [prog_now, target]
	prog_num.add_theme_font_size_override("font_size", _tasks_spec_fs(14))
	prog_num.add_theme_color_override("font_color", UI_CYAN_SOFT if reward_pending else UI_CYAN)
	prog_row.add_child(prog_num)
	var bar_bg := PanelContainer.new()
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_bg.custom_minimum_size = Vector2(0, _tasks_spec_h(6))
	var bar_bg_style := StyleBoxFlat.new()
	bar_bg_style.bg_color = Color(0.627, 0.784, 0.922, 0.15)
	bar_bg_style.set_corner_radius_all(_tasks_spec_w(4))
	bar_bg.add_theme_stylebox_override("panel", bar_bg_style)
	prog_row.add_child(bar_bg)
	var fill := ColorRect.new()
	fill.color = UI_CYAN_SOFT if reward_pending else UI_CYAN
	fill.set_anchors_preset(Control.PRESET_TOP_LEFT)
	fill.anchor_right = clampf(float(prog_now) / float(target), 0.06, 1.0)
	fill.offset_bottom = _tasks_spec_h(6)
	bar_bg.add_child(fill)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(1, _tasks_spec_h(52))
	divider.color = Color(0.588, 0.843, 1.0, 0.22)
	divider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(divider)

	var reward_col := VBoxContainer.new()
	reward_col.custom_minimum_size = Vector2(_tasks_spec_w(54), 0)
	reward_col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	reward_col.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_col.add_theme_constant_override("separation", _tasks_spec_h(2))
	row.add_child(reward_col)

	if reward_pending:
		var claim_btn := Button.new()
		claim_btn.focus_mode = Control.FOCUS_NONE
		claim_btn.text = ""
		claim_btn.custom_minimum_size = Vector2(_tasks_spec_w(54), _tasks_spec_h(52))
		_apply_daily_reward_claim_style(claim_btn)
		claim_btn.pressed.connect(_on_claim_daily_task_reward.bind(task_id, reward, target))
		reward_col.add_child(claim_btn)
		var claim_v := VBoxContainer.new()
		claim_v.set_anchors_preset(Control.PRESET_FULL_RECT)
		claim_v.alignment = BoxContainer.ALIGNMENT_CENTER
		claim_v.add_theme_constant_override("separation", _tasks_spec_h(2))
		claim_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		claim_btn.add_child(claim_v)
		var star_claim := Label.new()
		star_claim.text = "★"
		star_claim.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star_claim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star_claim.add_theme_font_size_override("font_size", _tasks_spec_fs(16))
		star_claim.add_theme_color_override("font_color", ClaimButtonUI.STAR)
		claim_v.add_child(star_claim)
		var reward_claim := Label.new()
		reward_claim.text = str(reward)
		reward_claim.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_claim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		reward_claim.add_theme_font_size_override("font_size", _tasks_spec_fs(18))
		reward_claim.add_theme_color_override("font_color", ClaimButtonUI.TEXT)
		claim_v.add_child(reward_claim)
	elif claimed:
		var done_lbl := Label.new()
		done_lbl.text = "✓"
		done_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		done_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
		done_lbl.add_theme_color_override("font_color", UI_MISSION_DONE)
		reward_col.add_child(done_lbl)
	else:
		var star := Label.new()
		star.text = "★"
		star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star.add_theme_font_size_override("font_size", _tasks_spec_fs(16))
		star.add_theme_color_override("font_color", Color(UI_CYAN.r, UI_CYAN.g, UI_CYAN.b, 0.45))
		reward_col.add_child(star)
		var reward_lbl := Label.new()
		reward_lbl.text = str(reward)
		reward_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(18))
		reward_lbl.add_theme_color_override("font_color", Color(UI_ICE.r, UI_ICE.g, UI_ICE.b, 0.55))
		reward_col.add_child(reward_lbl)


func _on_claim_daily_task_reward(task_id: String, reward: int, target: int) -> void:
	if not Global.claim_daily_task_reward(task_id, reward, target):
		_show_toast(GameLocale.pick("暂无可领取奖励", "No reward to claim"))
		return
	_show_toast(GameLocale.pick("每日奖励 · 星火币 +%d" % reward, "Daily reward · Ember Coins +%d" % reward))
	_refresh_status_bar()
	call_deferred("_refresh_tasks_daily")


func _mission_type_accent(task_type: String) -> Color:
	match MissionTypes.normalize_type(task_type):
		"Repair Run":
			return Color(0.38, 0.82, 0.58)
		"Emergency Run":
			return Color(0.98, 0.72, 0.28)
		"Relay Run":
			return Color(0.62, 0.78, 0.98)
		"Ignition Run":
			return Color(0.92, 0.48, 0.38)
		_:
			return UI_CYAN


func _mission_card_summary(mission: Dictionary, profile: Dictionary, outpost_name: String) -> String:
	var cargo := GameLocale.field(mission, "cargo_name", "cargo_name_en")
	if cargo == "":
		cargo = "Cargo"
	var duration_s := int(mission.get("duration", profile.get("duration", 60)))
	var timed := bool(profile.get("timed_fail", false))
	var time_text := "%ds LIMIT" % duration_s if timed else "%d-%ds" % [maxi(duration_s - 10, 30), duration_s]
	return "%s · %s · %s" % [cargo, outpost_name, time_text]


func _mission_card_meta_bbcode(mission: Dictionary, profile: Dictionary, outpost_name: String) -> String:
	var cargo := GameLocale.field(mission, "cargo_name", "cargo_name_en")
	if cargo == "":
		cargo = "Cargo"
	var duration_s := int(mission.get("duration", profile.get("duration", 60)))
	var timed := bool(profile.get("timed_fail", false))
	if timed:
		return "%s · %s · [color=#f5c040]%ds LIMIT[/color]" % [cargo, outpost_name, duration_s]
	return "%s · %s · %d-%ds" % [cargo, outpost_name, maxi(duration_s - 10, 30), duration_s]


func _make_tasks_mission_card_shell(accent: Color, is_done: bool, reward_pending: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.clip_contents = true
	panel.custom_minimum_size = Vector2(0, _tasks_spec_h(92))
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.027, 0.063, 0.114, 0.62)
	if is_done and reward_pending:
		card_style.border_color = Color(UI_REWARD_CLAIM.r, UI_REWARD_CLAIM.g, UI_REWARD_CLAIM.b, 0.55)
	elif is_done:
		card_style.border_color = Color(UI_MISSION_DONE.r, UI_MISSION_DONE.g, UI_MISSION_DONE.b, 0.35)
	else:
		card_style.border_color = Color(accent.r, accent.g, accent.b, 0.28)
	card_style.set_border_width_all(1)
	card_style.set_corner_radius_all(_tasks_spec_w(12))
	card_style.content_margin_left = _tasks_spec_w(10)
	card_style.content_margin_right = _tasks_spec_w(10)
	card_style.content_margin_top = _tasks_spec_h(8)
	card_style.content_margin_bottom = _tasks_spec_h(8)
	panel.add_theme_stylebox_override("panel", card_style)
	return panel


func _add_tasks_mission_card(planet_id: String, mission: Dictionary) -> void:
	var location_id := String(mission.get("location_id", "dome"))
	var mission_id := Global.mission_key(mission)
	var profile: Dictionary = MissionTypes.resolve(mission)
	var progress_target := MissionTypes.mission_progress_target(mission)
	var progress_now := Global.get_mission_progress(planet_id, mission_id)
	var is_done := Global.is_mission_completed(planet_id, mission_id)
	var reward_pending := Global.is_mission_reward_pending(planet_id, mission_id)
	var type_en := String(mission.get("task_type", profile.get("task_type", "Supply Run"))).to_upper()
	if not type_en.ends_with(" RUN") and "RUN" not in type_en:
		type_en = "%s RUN" % type_en.replace(" RUN", "")
	var outpost := _home_outpost_display_name(
		location_id,
		String(mission.get("target_hearth", mission.get("source_hearth", location_id)))
	)
	var reward := int(mission.get("base_reward", profile.get("base_reward", 50)))
	var accepted := Global.is_mission_accepted(planet_id, mission_id)
	var is_preview := MissionDispatch.is_preview_location(planet_id, location_id)
	var accent := _mission_type_accent(String(mission.get("task_type", "")))

	var panel := _make_tasks_mission_card_shell(accent, is_done, reward_pending)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var open_detail := func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_task_detail(planet_id, mission.duplicate(true))
		elif event is InputEventScreenTouch and event.pressed:
			_open_task_detail(planet_id, mission.duplicate(true))
	# 点卡片本体 → 任务详情；只有右侧 ACCEPT/RUN 才接取或开跑
	panel.gui_input.connect(open_detail)
	_tasks_missions_box.add_child(panel)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", _tasks_spec_w(8))
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)

	var accent_bar := ColorRect.new()
	accent_bar.custom_minimum_size = Vector2(_tasks_spec_w(4), _tasks_spec_h(52))
	accent_bar.color = accent
	accent_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(accent_bar)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(_tasks_spec_w(52), _tasks_spec_w(52))
	icon_wrap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(0.063, 0.137, 0.227, 0.6)
	icon_style.border_color = Color(accent.r, accent.g, accent.b, 0.45)
	icon_style.set_border_width_all(1)
	icon_style.set_corner_radius_all(_tasks_spec_w(10))
	icon_wrap.add_theme_stylebox_override("panel", icon_style)
	row.add_child(icon_wrap)
	var icon_lbl := Label.new()
	icon_lbl.text = _mission_type_icon_char(String(mission.get("task_type", "")))
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
	icon_lbl.add_theme_color_override("font_color", accent)
	icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_wrap.add_child(icon_lbl)

	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_stretch_ratio = 1.0
	body.add_theme_constant_override("separation", _tasks_spec_h(3))
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(body)
	var name_lbl := Label.new()
	name_lbl.text = type_en
	name_lbl.clip_text = true
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(20))
	name_lbl.add_theme_color_override("font_color", UI_TEXT)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(name_lbl)
	var obj_lbl := RichTextLabel.new()
	obj_lbl.bbcode_enabled = true
	obj_lbl.text = _mission_card_meta_bbcode(mission, profile, outpost)
	obj_lbl.fit_content = true
	obj_lbl.scroll_active = false
	obj_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	obj_lbl.custom_minimum_size = Vector2(0, _tasks_spec_fs(18))
	obj_lbl.add_theme_font_size_override("normal_font_size", _tasks_spec_fs(14))
	obj_lbl.add_theme_color_override("default_color", UI_MUTED)
	obj_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(obj_lbl)
	if not is_done and progress_now > 0:
		var prog_lbl := Label.new()
		prog_lbl.text = "Progress %d / %d" % [progress_now, progress_target]
		prog_lbl.clip_text = true
		prog_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(13))
		prog_lbl.add_theme_color_override("font_color", Color(0.62, 0.72, 0.82))
		body.add_child(prog_lbl)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_SHRINK_END
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", _tasks_spec_h(6))
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(right)
	var reward_row := HBoxContainer.new()
	reward_row.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_row.add_theme_constant_override("separation", _tasks_spec_w(4))
	reward_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right.add_child(reward_row)
	var star_lbl := Label.new()
	star_lbl.text = "★"
	star_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(16))
	star_lbl.add_theme_color_override("font_color", UI_CYAN)
	star_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reward_row.add_child(star_lbl)
	var reward_lbl := Label.new()
	reward_lbl.text = str(reward)
	reward_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(18))
	reward_lbl.add_theme_color_override("font_color", UI_ICE)
	reward_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reward_row.add_child(reward_lbl)

	if is_done and reward_pending:
		var claim_btn := Button.new()
		claim_btn.focus_mode = Control.FOCUS_NONE
		claim_btn.text = "CLAIM"
		claim_btn.mouse_filter = Control.MOUSE_FILTER_STOP
		claim_btn.custom_minimum_size = Vector2(_tasks_spec_w(88), _tasks_spec_h(34))
		_apply_mission_reward_claim_style(claim_btn)
		claim_btn.pressed.connect(_on_claim_mission_reward.bind(planet_id, mission_id, reward))
		right.add_child(claim_btn)
	elif is_done:
		var done_lbl := Label.new()
		done_lbl.text = "DONE"
		done_lbl.add_theme_font_size_override("font_size", _tasks_spec_fs(14))
		done_lbl.add_theme_color_override("font_color", UI_MISSION_DONE)
		done_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		right.add_child(done_lbl)
	else:
		var action_btn := Button.new()
		action_btn.focus_mode = Control.FOCUS_NONE
		action_btn.mouse_filter = Control.MOUSE_FILTER_STOP
		if is_preview:
			action_btn.text = GameLocale.pick("试玩", "TRIAL") if MissionDispatch.can_preview_trial_run(planet_id, location_id) else "PREVIEW"
		else:
			action_btn.text = "RUN" if accepted else "ACCEPT"
		action_btn.custom_minimum_size = Vector2(_tasks_spec_w(88), _tasks_spec_h(34))
		_apply_mission_action_button_style(action_btn, accepted and not is_preview)
		action_btn.pressed.connect(_on_tasks_mission_action.bind(planet_id, mission.duplicate(true), action_btn))
		right.add_child(action_btn)


func _mission_type_icon_char(task_type: String) -> String:
	match MissionTypes.normalize_type(task_type):
		"Repair Run":
			return "🔧"
		"Emergency Run":
			return "⚡"
		"Relay Run":
			return "↗"
		"Ignition Run":
			return "🔥"
		_:
			return "▣"


func _apply_mission_action_button_style(button: Button, is_run: bool) -> void:
	var btn_style := StyleBoxFlat.new()
	if is_run:
		btn_style.bg_color = Color(0.431, 0.784, 0.922, 0.92)
		btn_style.border_color = Color(0.847, 0.969, 1.0, 0.95)
		btn_style.shadow_color = Color(0.557, 0.882, 0.969, 0.45)
		btn_style.shadow_size = 8
		button.add_theme_color_override("font_color", Color(0.024, 0.133, 0.2))
	else:
		btn_style.bg_color = Color(0.157, 0.275, 0.373, 0.58)
		btn_style.border_color = Color(0.745, 0.933, 1.0, 0.62)
		btn_style.shadow_color = Color(0.557, 0.882, 0.969, 0.28)
		btn_style.shadow_size = 6
		button.add_theme_color_override("font_color", UI_ICE)
	btn_style.set_border_width_all(1)
	btn_style.set_corner_radius_all(_tasks_spec_w(14))
	btn_style.content_margin_left = _tasks_spec_w(8)
	btn_style.content_margin_right = _tasks_spec_w(8)
	btn_style.content_margin_top = _tasks_spec_h(4)
	btn_style.content_margin_bottom = _tasks_spec_h(4)
	var hover_style := btn_style.duplicate() as StyleBoxFlat
	if is_run:
		hover_style.bg_color = Color(0.667, 0.941, 1.0, 0.98)
	else:
		hover_style.bg_color = Color(0.196, 0.333, 0.451, 0.72)
	var pressed_style := btn_style.duplicate() as StyleBoxFlat
	pressed_style.shadow_size = 2
	button.add_theme_stylebox_override("normal", btn_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_font_size_override("font_size", _tasks_spec_fs(15))


func _apply_daily_reward_claim_style(button: Button) -> void:
	ClaimButtonUI.apply(
		button,
		_tasks_spec_w(10),
		_tasks_spec_w(4),
		_tasks_spec_h(6),
		_tasks_spec_w(4),
		_tasks_spec_h(6),
		-1
	)


func _apply_mission_reward_claim_style(button: Button) -> void:
	ClaimButtonUI.apply(
		button,
		_tasks_spec_w(14),
		_tasks_spec_w(8),
		_tasks_spec_h(4),
		_tasks_spec_w(8),
		_tasks_spec_h(4),
		_tasks_spec_fs(15)
	)


func _on_claim_mission_reward(planet_id: String, mission_id: String, reward: int) -> void:
	if not Global.claim_mission_reward(planet_id, mission_id, reward):
		_show_toast(GameLocale.pick("暂无可领取奖励", "No reward to claim"))
		return
	_show_toast(GameLocale.pick("领取成功 · 星火币 +%d" % reward, "Claimed · Ember Coins +%d" % reward))
	_refresh_status_bar()
	call_deferred("_refresh_tasks_mission_cards", planet_id)


func _on_tasks_mission_action(planet_id: String, mission: Dictionary, action_button: Button = null) -> void:
	var location_id := String(mission.get("location_id", ""))
	var mission_id := Global.mission_key(mission)
	if location_id == "":
		return
	if MissionDispatch.is_preview_location(planet_id, location_id):
		if MissionDispatch.can_preview_trial_run(planet_id, location_id):
			_start_runner_for_mission(planet_id, mission, true)
		else:
			_open_task_detail(planet_id, mission)
			_show_toast(GameLocale.pick("预览任务 · 解锁后可接取出发", "Preview · unlock batch to accept and run"))
		return
	if Global.is_mission_completed(planet_id, mission_id):
		if Global.is_mission_reward_pending(planet_id, mission_id):
			return
		_start_runner_for_mission(planet_id, mission)
		return
	if Global.is_mission_accepted(planet_id, mission_id):
		_start_runner_for_mission(planet_id, mission)
		return
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		_show_toast(GameLocale.pick("该批次任务尚未解锁", "This mission batch is still locked"))
		return
	Global.accept_mission(planet_id, mission_id)
	_show_toast(GameLocale.pick("已接取 · 点击 RUN 出发", "Accepted · tap RUN to start"))
	if action_button != null and is_instance_valid(action_button):
		action_button.text = "RUN"
		_apply_mission_action_button_style(action_button, true)
	call_deferred("_refresh_tasks_mission_cards", planet_id)


func _start_runner_for_mission(planet_id: String, mission: Dictionary, trial_run: bool = false) -> void:
	var location_id := String(mission.get("location_id", "dome"))
	var is_trial := trial_run and MissionDispatch.can_preview_trial_run(planet_id, location_id)
	if MissionDispatch.is_preview_location(planet_id, location_id):
		if is_trial:
			_show_toast(GameLocale.pick("调优试玩 · 进度暂不计入任务板", "Trial run · progress does not count toward the board"))
		else:
			_show_toast(GameLocale.pick("该批次任务尚未解锁", "This mission batch is still locked"))
			return
	var mission_id := Global.mission_key(mission)
	_sync_selected_character_from_global()
	_selected_planet_id = planet_id
	Global.runner_trial_run = is_trial
	if not is_trial:
		Global.set_active_mission(planet_id, location_id, mission_id)
	Global.mobile_home_tab = TAB_HOME
	Global.exploration_planet_id = planet_id
	Global.runner_planet_id = planet_id
	Global.runner_location_id = location_id
	Global.runner_mission_id = mission_id if String(mission.get("mission_id", "")) != "" else ""
	Global.change_game_scene(PlanetDatabase.RUNNER_SCENE)


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
	if not CharacterRoster.is_unlocked(Global.get_selected_character_id(), unlocked):
		Global.set_selected_character(CharacterRoster.CHAR_ELSA)
	if _selected_character_id == "":
		_selected_character_id = Global.get_selected_character_id()

	# 强制占满滚动视口高度，否则装备栏拿不到「底部空余」可扩展
	var view_h := 0.0
	var view_w := 0.0
	if _page_scroll:
		view_h = _page_scroll.size.y
		view_w = _page_scroll.size.x
	if view_h <= 1.0 and _content_host:
		view_h = _content_host.size.y
		view_w = maxf(view_w, _content_host.size.x)
	if _page_box and view_h > 1.0:
		_page_box.custom_minimum_size = Vector2(view_w, view_h)
		_page_box.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var host := Control.new()
	host.name = "RunnerPageHost"
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	host.clip_contents = false
	if view_h > 1.0:
		host.custom_minimum_size = Vector2(view_w, view_h)
	else:
		host.custom_minimum_size = Vector2.ZERO
	_page_box.add_child(host)

	var ctx := {
		"character_id": _selected_character_id,
		"active_character_id": Global.get_selected_character_id(),
		"snapshot": snapshot,
		"on_cycle": _cycle_character,
		"on_select": _select_character_id,
		"on_switch": _switch_active_character,
		"on_story": _show_character_story,
	}
	CharacterPageUI.build(host, ctx)
	# 下一帧视口尺寸更稳，再触发布局增高
	call_deferred("_refit_runner_page_host")


func _refit_runner_page_host() -> void:
	if _selected_tab != TAB_CHARACTER:
		return
	if _page_scroll == null or _page_box == null:
		return
	# 等一帧：切换 Elsa/Rook 重建后 Scroll 尺寸才稳定，避免用中间态把整页缩没
	await get_tree().process_frame
	if _selected_tab != TAB_CHARACTER or _page_scroll == null or _page_box == null:
		return
	var view_h := _page_scroll.size.y
	var view_w := _page_scroll.size.x
	if view_h <= 8.0 or view_w <= 8.0:
		return
	_page_box.custom_minimum_size = Vector2(view_w, view_h)
	_page_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var host := _page_box.get_node_or_null("RunnerPageHost") as Control
	if host:
		host.custom_minimum_size = Vector2(view_w, view_h)
		host.size = Vector2(view_w, view_h)
		host.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var shell := host.get_node_or_null("RunnerPageShell")
		if shell != null and shell.has_method("_fit_canvas"):
			shell.call("_fit_canvas")
	await get_tree().process_frame
	if _selected_tab != TAB_CHARACTER or _page_scroll == null:
		return
	view_h = _page_scroll.size.y
	view_w = _page_scroll.size.x
	if view_h <= 8.0 or view_w <= 8.0:
		return
	host = _page_box.get_node_or_null("RunnerPageHost") as Control
	if host:
		host.custom_minimum_size = Vector2(view_w, view_h)
		host.size = Vector2(view_w, view_h)
		var shell2 := host.get_node_or_null("RunnerPageShell")
		if shell2 != null and shell2.has_method("_fit_canvas"):
			shell2.call("_fit_canvas")


func _select_character_id(character_id: String) -> void:
	# 仅切换浏览角色；出战角色由 SWITCH / _switch_active_character 决定
	if character_id == _selected_character_id:
		return
	_selected_character_id = character_id
	_show_tab(TAB_CHARACTER, true)


func _switch_active_character(character_id: String) -> void:
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	if not CharacterRoster.is_unlocked(character_id, snapshot.get("unlocked_stories", [])):
		return
	Global.set_selected_character(character_id)
	_selected_character_id = character_id
	var name := String(CharacterRoster.get_character(character_id).get("name_en", character_id))
	_show_toast("Now running as %s" % name)
	_show_tab(TAB_CHARACTER, true)


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
	switch_hint.text = GameLocale.pick("左右切换", "Swipe L/R")
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
	unlock_hint.text = GameLocale.pick("可切换 Elsa / Rook", "Switch Elsa / Rook") if rook_unlocked else GameLocale.pick("完成居民穹顶后解锁 Rook", "Unlock Rook after Habitat Dome")
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
	title.text = CharacterRoster.title_for_ui(character)
	if title.text == "":
		title.text = String(snapshot.get("title", GameLocale.pick("信使", "Courier")))
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
	title.text = GameLocale.pick("📖  角色故事", "📖  Character Story")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.96, 0.94, 0.90))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(title)

	var action := Label.new()
	action.text = GameLocale.pick("阅读档案  ›", "Read dossier  ›")
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
	title.text = GameLocale.pick("性能概览", "Performance")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", UI_TEXT)
	header.add_child(title)

	var bonus := Label.new()
	bonus.text = GameLocale.pick(
		"等级加成 · 星火币 %s" % String(snapshot.get("coin_bonus_text", "+0%")),
		"Level bonus · Coins %s" % String(snapshot.get("coin_bonus_text", "+0%"))
	)
	bonus.add_theme_font_size_override("font_size", 14)
	bonus.add_theme_color_override("font_color", Color(0.90, 0.76, 0.42))
	header.add_child(bonus)

	var stats: Array = character.get("stats", [])
	for stat in stats:
		_add_character_stat_row(CharacterRoster.stat_label_for_ui(stat), String(stat.get("value", "")), float(stat.get("fill", 0.5)))


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
	title.text = "%s · %s" % [
		GameLocale.field(character, "trait_name", "trait_name_en"),
		GameLocale.field(character, "trait_gear", "trait_gear_en"),
	]
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", UI_TEXT)
	text.add_child(title)

	var desc := Label.new()
	desc.text = CharacterRoster.trait_desc_for_ui(character)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 15)
	desc.add_theme_color_override("font_color", UI_MUTED)
	text.add_child(desc)

	var tag := Label.new()
	tag.text = CharacterRoster.trait_tag_for_ui(character)
	tag.add_theme_font_size_override("font_size", 13)
	tag.add_theme_color_override("font_color", Color(0.56, 0.78, 0.82))
	text.add_child(tag)


func _cycle_character(direction: int = 1) -> void:
	# 左右浏览不改出战角色；点 SWITCH 才设为 IN USE
	var next_id := (
		CharacterRoster.next_id(_selected_character_id)
		if direction >= 0
		else CharacterRoster.prev_id(_selected_character_id)
	)
	if next_id == _selected_character_id:
		return
	_selected_character_id = next_id
	_show_tab(TAB_CHARACTER, true)


func _show_character_story(character_id: String) -> void:
	if _character_story_layer:
		_character_story_layer.queue_free()
		_character_story_layer = null
		_character_story_overlay = null

	_selected_character_id = character_id
	var character: Dictionary = CharacterRoster.get_character(character_id)
	var snapshot: Dictionary = Global.get_messenger_snapshot()

	var layer := CanvasLayer.new()
	layer.layer = 50
	_ui_root.add_child(layer)
	_character_story_layer = layer

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(root)
	_character_story_overlay = root

	if _content_host:
		_content_host.visible = false

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
	top_title.text = "RUNNER STORY"
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
	_add_story_section_header(story_box, String(character.get("section_background", "BACKGROUND")), "02")
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
	# 01：插画高度约 52% 视口，避免占满整屏挤掉 02 正文
	var side := maxf(MOBILE_VIEWPORT_SIZE.y * 0.52, 280.0)
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

	var paragraphs: Array = CharacterRoster.story_paragraphs_for_ui(character)
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
	if _character_story_layer:
		_character_story_layer.queue_free()
		_character_story_layer = null
	_character_story_overlay = null
	_show_tab(TAB_CHARACTER, true)


func _add_stat_upgrade_card(stat_id: String, current_level: int) -> void:
	var label := CharacterProgression.stat_label(stat_id)
	var effect := CharacterProgression.stat_percent_text(stat_id, current_level)
	var body := GameLocale.pick(
		"%s · 当前 Lv.%d / %d · 效果 %s" % [label, current_level, CharacterProgression.MAX_STAT_LEVEL, effect],
		"%s · Lv.%d / %d · Effect %s" % [label, current_level, CharacterProgression.MAX_STAT_LEVEL, effect]
	)
	var card := _add_card(label, body)
	if current_level >= CharacterProgression.MAX_STAT_LEVEL:
		_add_muted_label(card, GameLocale.pick("已满级", "Maxed"))
		return
	var cost := CharacterProgression.upgrade_cost(stat_id, current_level)
	if cost < 0:
		return
	var can_buy := Global.ember_coins >= cost
	var button := _add_primary_button(
		card,
		GameLocale.pick("升级（%d 星火币）" % cost, "Upgrade (%d coins)" % cost),
		_upgrade_messenger_stat.bind(stat_id)
	)
	button.disabled = not can_buy
	if not can_buy:
		_add_muted_label(card, GameLocale.pick("星火币不足，完成运输可获得更多", "Not enough coins — finish runs to earn more"))


func _upgrade_messenger_stat(stat_id: String) -> void:
	if Global.try_upgrade_messenger_stat(stat_id):
		_show_toast(GameLocale.pick(
			"%s 升级成功" % CharacterProgression.stat_label(stat_id),
			"%s upgraded" % CharacterProgression.stat_label(stat_id)
		))
		_show_tab(TAB_CHARACTER, true, true)
		return
	_show_toast(GameLocale.pick("星火币不足，无法升级", "Not enough coins to upgrade"))


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
	if _page_scrim:
		_page_scrim.visible = true
		_page_scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	_task_detail.z_index = 240
	if _ui_root and _task_detail.get_parent() == _ui_root:
		_ui_root.move_child(_task_detail, -1)
	_task_detail.open(planet_id, mission)


func _on_task_detail_closed() -> void:
	if _bottom_nav_root:
		_bottom_nav_root.visible = true
	if _page_scrim:
		_page_scrim.visible = _selected_tab != TAB_HOME and _selected_tab != TAB_MAP
		_page_scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_task_detail_accept(planet_id: String, location_id: String, mission_id: String = "") -> void:
	if planet_id == "" or location_id == "":
		return
	if mission_id == "":
		mission_id = location_id
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	var mission: Dictionary = {}
	if cfg != null and cfg.has_method("get_mission_by_id"):
		mission = cfg.get_mission_by_id(mission_id)
	if mission.is_empty():
		mission = cfg.get_mission_for_location(location_id) if cfg != null else {"location_id": location_id}
	if MissionDispatch.is_preview_location(planet_id, location_id):
		if MissionDispatch.can_preview_trial_run(planet_id, location_id):
			if _task_detail:
				_task_detail.close()
			_start_runner_for_mission(planet_id, mission, true)
		else:
			_show_toast(GameLocale.pick("预览任务 · 网络核心批次解锁后可接取出发", "Preview · accept after Network Core batch unlocks"))
		return
	var mission_done := Global.is_mission_completed(planet_id, mission_id)
	var reward_pending := Global.is_mission_reward_pending(planet_id, mission_id)
	var location_lit := Global.get_completed_runner_locations(planet_id).has(location_id)
	var accepted := Global.is_mission_accepted(planet_id, mission_id)
	if reward_pending:
		var payout := Global.get_mission_reward_amount(planet_id, mission_id)
		if Global.claim_mission_reward(planet_id, mission_id, payout):
			_show_toast(GameLocale.pick("领取成功 · 星火币 +%d" % payout, "Claimed · Ember Coins +%d" % payout))
			_refresh_status_bar()
			_open_task_detail(planet_id, mission)
			_refresh_tasks_mission_cards(planet_id)
		return
	if mission_done or location_lit or accepted:
		if _task_detail:
			_task_detail.close()
		_start_runner_for_mission(planet_id, mission)
		return
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		_show_toast(GameLocale.pick("该批次任务尚未解锁", "This mission batch is still locked"))
		return
	Global.accept_mission(planet_id, mission_id)
	_show_toast(GameLocale.pick("已接取 · 点击 RUN 出发", "Accepted · tap RUN to start"))
	_open_task_detail(planet_id, mission)
	_refresh_tasks_mission_cards(planet_id)


func _add_mission_card(
	planet: Dictionary,
	mission: Dictionary,
	slot_index: int = 0,
	from_board: bool = false
) -> void:
	var planet_id := String(planet["id"])
	var location_id := String(mission.get("location_id", "dome"))
	var completed := Global.get_completed_runner_locations(planet_id).has(location_id)
	var batch_unlocked := MissionDispatch.is_location_batch_unlocked(planet_id, location_id)
	var is_active := Global.is_active_mission(planet_id, location_id)
	var on_board := from_board or Global.is_mission_on_board(planet_id, Global.mission_key(mission))
	var status := GameLocale.pick("已完成", "Done") if completed else (GameLocale.pick("进行中", "Active") if is_active else (GameLocale.pick("任务板上", "On board") if on_board else (GameLocale.pick("可接取", "Available") if batch_unlocked else GameLocale.pick("待解锁", "Locked"))))
	var border_color := UI_GREEN if completed else (UI_ORANGE if is_active else (Color(0.96, 0.58, 0.22) if on_board or batch_unlocked else UI_PANEL_BORDER))

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
	var type_name := GameLocale.field(mission, "task_type_zh", "task_type")
	if type_name == "":
		type_name = GameLocale.pick(String(profile.get("name_zh", "补给")), String(profile.get("task_type", "Supply")))
	var duration_s := int(mission.get("duration", profile.get("duration", 60)))
	type_label.text = "%s · %ds" % [type_name, duration_s]
	if slot_index > 0:
		type_label.text = GameLocale.pick("槽位 %d · %s" % [slot_index, type_label.text], "Slot %d · %s" % [slot_index, type_label.text])
	type_label.add_theme_font_size_override("font_size", 15)
	type_label.add_theme_color_override("font_color", UI_TEXT)
	text_box.add_child(type_label)

	var hint_text := GameLocale.field(mission, "task_hint", "task_hint_en")
	if hint_text == "":
		hint_text = GameLocale.field(profile, "hint", "hint_en")
	if hint_text != "":
		var hint_label := Label.new()
		hint_label.text = hint_text
		hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint_label.add_theme_font_size_override("font_size", 12)
		hint_label.add_theme_color_override("font_color", UI_MUTED)
		text_box.add_child(hint_label)

	var route_label := Label.new()
	var source_label := GameLocale.field(mission, "source_hearth", "source_hearth_en")
	if source_label == "":
		source_label = String(mission.get("source_hearth", String(planet["name"])))
	var target_label := Global.get_outpost_display_name(String(planet.get("id", _selected_planet_id)), String(mission.get("location_id", "")))
	if target_label == "":
		target_label = GameLocale.field(mission, "target_hearth", "target_hearth_en")
	if target_label == "":
		target_label = GameLocale.pick("据点", "Outpost")
	route_label.text = "%s → %s" % [source_label, target_label]
	route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_label.add_theme_font_size_override("font_size", 18)
	route_label.add_theme_color_override("font_color", UI_CYAN)
	text_box.add_child(route_label)

	var cargo_label := Label.new()
	var cargo_name := GameLocale.field(mission, "cargo_name", "cargo_name_en")
	if cargo_name == "":
		cargo_name = GameLocale.pick("物资", "Cargo")
	cargo_label.text = GameLocale.pick(
		"%s × %d · 难度 %d" % [cargo_name, int(mission.get("cargo_load", 1)), int(mission.get("difficulty", 1))],
		"%s × %d · Diff %d" % [cargo_name, int(mission.get("cargo_load", 1)), int(mission.get("difficulty", 1))]
	)
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
	if batch_unlocked or completed or on_board:
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
	elif batch_unlocked:
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
		_add_muted_label(box, "需要先解锁对应任务批次")


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
	tag.text = GameLocale.pick("推荐任务", "Recommended")
	tag.add_theme_font_size_override("font_size", 13)
	tag.add_theme_color_override("font_color", UI_STATUS)
	text_box.add_child(tag)
	var line1 := Label.new()
	var type_name := String(mission.get("task_type", MissionTypes.short_label(mission))) if GameLocale.is_en() else String(mission.get("task_type_zh", MissionTypes.short_label(mission)))
	var duration_s := int(mission.get("duration", MissionTypes.resolve(mission).get("duration", 60)))
	var target_name := GameLocale.field(mission, "target_hearth", "target_hearth_en")
	if target_name == "":
		target_name = Global.get_outpost_display_name(planet_id, location_id)
	if target_name == "":
		target_name = GameLocale.pick("据点", "Outpost")
	line1.text = "%s · %ds · %s" % [type_name, duration_s, target_name]
	line1.add_theme_font_size_override("font_size", 18)
	line1.add_theme_color_override("font_color", UI_TEXT)
	text_box.add_child(line1)
	var line2 := Label.new()
	var cargo_name := GameLocale.field(mission, "cargo_name", "cargo_name_en")
	if cargo_name == "":
		cargo_name = GameLocale.pick("物资", "Cargo")
	line2.text = "%s × %d" % [cargo_name, int(mission.get("cargo_load", 1))]
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


func _make_settings_flat_button(text: String) -> Button:
	var button := _make_flat_button(text)
	button.custom_minimum_size = Vector2(0, _settings_spec_h(56))
	button.add_theme_font_size_override("font_size", _settings_spec_fs(17))
	var radius := _settings_spec_w(8)
	var fill := Color(0.10, 0.13, 0.18, 0.96)
	var border := UI_PANEL_BORDER
	button.add_theme_stylebox_override("normal", _style(fill, border, 1, radius))
	button.add_theme_stylebox_override("hover", _style(fill.lightened(0.06), UI_FRAME_BORDER, 1, radius))
	button.add_theme_stylebox_override("pressed", _style(fill.darkened(0.06), border, 1, radius))
	button.add_theme_stylebox_override("disabled", _style(fill.darkened(0.16), Color(0.18, 0.22, 0.28), 1, radius))
	return button


func _make_settings_gold_button(text: String) -> Button:
	var button := _make_gold_button(text)
	button.custom_minimum_size = Vector2(0, _settings_spec_h(64))
	button.add_theme_font_size_override("font_size", _settings_spec_fs(20))
	var radius := _settings_spec_w(10)
	button.add_theme_stylebox_override("normal", _style(UI_GOLD, UI_GOLD_BORDER, 2, radius))
	button.add_theme_stylebox_override("hover", _style(UI_GOLD.lightened(0.05), UI_GOLD_BORDER.lightened(0.04), 2, radius))
	button.add_theme_stylebox_override("pressed", _style(UI_GOLD.darkened(0.08), UI_GOLD_BORDER.darkened(0.04), 2, radius))
	button.add_theme_stylebox_override("disabled", _style(UI_GOLD.darkened(0.22), UI_GOLD_BORDER.darkened(0.12), 1, radius))
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
		_settings_overlay.queue_free()
		_settings_overlay = null
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
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_close_settings()
	)
	_settings_overlay.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	# IGNORE：空白处点击落到遮罩可关闭；面板本身 STOP 仍可点
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settings_overlay.add_child(center)

	var panel := PanelContainer.new()
	var panel_w := _settings_spec_w(560)
	# 正式版只保留语言 / BGM / 回看剧情，面板不必再做很高
	var panel_h := mini(_settings_spec_h(520), maxf(360.0, _ui_root.size.y * 0.62))
	panel.custom_minimum_size = Vector2(panel_w, panel_h)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _style(UI_FRAME, UI_FRAME_BORDER, 2, _settings_spec_w(14)))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", _settings_spec_w(28))
	margin.add_theme_constant_override("margin_right", _settings_spec_w(28))
	margin.add_theme_constant_override("margin_top", _settings_spec_h(22))
	margin.add_theme_constant_override("margin_bottom", _settings_spec_h(22))
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", _settings_spec_h(12))
	margin.add_child(root)

	var title := Label.new()
	title.text = GameLocale.t("settings_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", _settings_spec_fs(32))
	title.add_theme_color_override("font_color", UI_TEXT)
	root.add_child(title)

	var tip := Label.new()
	tip.text = GameLocale.t("settings_tip")
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(_settings_spec_w(480), 0)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", _settings_spec_fs(16))
	tip.add_theme_color_override("font_color", UI_MUTED)
	root.add_child(tip)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", _settings_spec_h(14))
	root.add_child(box)

	var lang_row := HBoxContainer.new()
	lang_row.add_theme_constant_override("separation", _settings_spec_w(12))
	box.add_child(lang_row)
	var lang_label := Label.new()
	lang_label.text = GameLocale.t("settings_language")
	lang_label.custom_minimum_size = Vector2(_settings_spec_w(140), 0)
	lang_label.add_theme_font_size_override("font_size", _settings_spec_fs(18))
	lang_label.add_theme_color_override("font_color", UI_TEXT)
	lang_row.add_child(lang_label)
	_settings_language_option = OptionButton.new()
	_settings_language_option.focus_mode = Control.FOCUS_NONE
	_settings_language_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_language_option.custom_minimum_size = Vector2(0, _settings_spec_h(44))
	_settings_language_option.add_theme_font_size_override("font_size", _settings_spec_fs(18))
	_settings_language_option.add_item(GameLocale.t("settings_lang_zh"), 0)
	_settings_language_option.add_item(GameLocale.t("settings_lang_en"), 1)
	_settings_language_option.item_selected.connect(_on_settings_language_selected)
	lang_row.add_child(_settings_language_option)

	var bgm_vol_row := HBoxContainer.new()
	bgm_vol_row.add_theme_constant_override("separation", _settings_spec_w(12))
	box.add_child(bgm_vol_row)
	var bgm_vol_label := Label.new()
	bgm_vol_label.text = GameLocale.t("settings_bgm_volume")
	bgm_vol_label.custom_minimum_size = Vector2(_settings_spec_w(140), 0)
	bgm_vol_label.add_theme_font_size_override("font_size", _settings_spec_fs(18))
	bgm_vol_label.add_theme_color_override("font_color", UI_TEXT)
	bgm_vol_row.add_child(bgm_vol_label)
	_settings_bgm_slider = HSlider.new()
	_settings_bgm_slider.min_value = 0.0
	_settings_bgm_slider.max_value = 1.0
	_settings_bgm_slider.step = 0.01
	_settings_bgm_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_bgm_slider.custom_minimum_size = Vector2(0, _settings_spec_h(36))
	_settings_bgm_slider.value_changed.connect(_on_settings_bgm_volume_changed)
	bgm_vol_row.add_child(_settings_bgm_slider)

	var story_review_btn := _make_settings_flat_button(GameLocale.t("settings_story_review"))
	story_review_btn.pressed.connect(_on_settings_story_review)
	box.add_child(story_review_btn)

	var close_btn := _make_settings_gold_button(GameLocale.t("settings_close"))
	close_btn.pressed.connect(_close_settings)
	root.add_child(close_btn)


func _refresh_settings_ui() -> void:
	if _settings_language_option != null:
		_settings_language_option.set_block_signals(true)
		_settings_language_option.select(1 if Global.is_ui_english() else 0)
		_settings_language_option.set_block_signals(false)
	if _settings_bgm_slider != null:
		_settings_bgm_slider.set_value_no_signal(Global.bgm_volume)
		_settings_bgm_slider.editable = true


func _on_settings_language_selected(index: int) -> void:
	var next := "en" if index == 1 else "zh"
	if Global.get_ui_locale() == next:
		return
	GameLocale.set_locale(next)
	_show_toast(GameLocale.t("toast_lang_en" if next == "en" else "toast_lang_zh"))
	# 重建设置页与当前主页 Tab，立即应用文案
	_open_settings()
	_show_tab(_selected_tab, true)


func _on_settings_bgm_volume_changed(value: float) -> void:
	Global.set_bgm_volume(value)
	# 音量>0 自动开启，=0 视为关闭
	if value > 0.001 and not Global.bgm_enabled:
		Global.set_bgm_enabled(true)
	elif value <= 0.001 and Global.bgm_enabled:
		Global.set_bgm_enabled(false)


func _attach_transport_help_button(parent: Control) -> void:
	if parent == null:
		return
	if parent.get_node_or_null("TransportHelpBtn") != null:
		return
	var btn := Button.new()
	btn.name = "TransportHelpBtn"
	btn.text = "?"
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(_home_spec_w(44), _home_spec_w(44))
	btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 0.0
	btn.anchor_bottom = 0.0
	btn.offset_left = -_home_spec_w(52)
	btn.offset_right = -_home_spec_w(8)
	btn.offset_top = _home_spec_h(4)
	btn.offset_bottom = _home_spec_h(48)
	btn.add_theme_font_size_override("font_size", _home_spec_fs(24))
	var normal := _style(Color(0.05, 0.10, 0.16, 0.88), UI_CYAN, 1, 999)
	var hover := _style(Color(0.10, 0.20, 0.30, 0.94), UI_CYAN_SOFT, 1, 999)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_color_override("font_color", UI_ICE)
	btn.pressed.connect(_show_transport_intro.bind(true))
	parent.add_child(btn)
	parent.move_child(btn, -1)


func _maybe_show_transport_intro() -> void:
	if Global.transport_intro_seen:
		return
	if _selected_tab != TAB_MAP and _selected_tab != TAB_TASKS:
		return
	if _guide_step >= 0:
		return
	if _guide_layer != null and is_instance_valid(_guide_layer):
		return
	if _transport_intro_layer != null and is_instance_valid(_transport_intro_layer):
		return
	if _story_canvas != null and is_instance_valid(_story_canvas):
		return
	_show_transport_intro(false)


func _show_transport_intro(force: bool = false) -> void:
	if not force and Global.transport_intro_seen:
		return
	if _transport_intro_layer != null and is_instance_valid(_transport_intro_layer):
		_transport_intro_layer.queue_free()
	_transport_intro_layer = CanvasLayer.new()
	_transport_intro_layer.name = "TransportIntroLayer"
	_transport_intro_layer.layer = 65
	add_child(_transport_intro_layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_transport_intro_layer.add_child(root)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.04, 0.08, 0.78)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(minf(get_viewport_rect().size.x - 48.0, 640.0), 0)
	panel.add_theme_stylebox_override("panel", _style(Color(0.035, 0.07, 0.12, 0.98), UI_FRAME_BORDER, 2, 18))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	var title := Label.new()
	title.text = GameLocale.t("transport_intro_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UI_CYAN_SOFT)
	box.add_child(title)

	var body := Label.new()
	body.text = GameLocale.t("transport_intro_body")
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", 20)
	body.add_theme_color_override("font_color", Color(0.90, 0.94, 0.98))
	body.add_theme_constant_override("line_spacing", 8)
	box.add_child(body)

	var ok := Button.new()
	ok.text = GameLocale.t("transport_intro_ok")
	ok.focus_mode = Control.FOCUS_NONE
	ok.custom_minimum_size = Vector2(0, 56)
	ok.add_theme_font_size_override("font_size", 22)
	ok.add_theme_stylebox_override("normal", _style(UI_GOLD, UI_GOLD_BORDER, 2, 12))
	ok.add_theme_stylebox_override("hover", _style(UI_GOLD.lightened(0.05), UI_GOLD_BORDER.lightened(0.04), 2, 12))
	ok.add_theme_stylebox_override("pressed", _style(UI_GOLD.darkened(0.08), UI_GOLD_BORDER.darkened(0.04), 2, 12))
	ok.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
	ok.pressed.connect(_close_transport_intro)
	box.add_child(ok)


func _close_transport_intro() -> void:
	if not Global.transport_intro_seen:
		Global.mark_transport_intro_seen()
	if _transport_intro_layer != null and is_instance_valid(_transport_intro_layer):
		_transport_intro_layer.queue_free()
	_transport_intro_layer = null


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
	_add_muted_label(card, GameLocale.pick(
		"经验 %d / %d" % [int(snapshot["xp_into_level"]), xp_to_next],
		"XP %d / %d" % [int(snapshot["xp_into_level"]), xp_to_next]
	))


func _add_progress_card(title: String, completed: int, total: int, revealed: int, percent_override: int = -1) -> void:
	var percent := percent_override if percent_override >= 0 else int(round(float(completed) / float(maxi(total, 1)) * 100.0))
	var card := _add_card(title, GameLocale.pick(
		"已完成 %d / %d 条运输 · 已点亮 %d 处据点 · 净化度 %d%%" % [completed, total, revealed, percent],
		"%d / %d runs done · %d outposts lit · Purify %d%%" % [completed, total, revealed, percent]
	))
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
		var active_mission_id := String(active.get("mission_id", ""))
		if active_mission_id != "" and cfg.has_method("get_mission_by_id"):
			var active_mission: Dictionary = cfg.get_mission_by_id(active_mission_id)
			if not active_mission.is_empty():
				return {"planet_id": planet_id, "location_id": active_id, "mission": active_mission}
		if active_id != "":
			var fallback_mission: Dictionary = cfg.get_mission_for_location(active_id)
			if not fallback_mission.is_empty():
				return {"planet_id": planet_id, "location_id": active_id, "mission": fallback_mission}

		var board := Global.get_mission_board_slots(planet_id)
		for mission_id in board:
			if cfg == null or not cfg.has_method("get_mission_by_id"):
				continue
			var mission: Dictionary = cfg.get_mission_by_id(mission_id)
			if mission.is_empty():
				continue
			var location_id := String(mission.get("location_id", ""))
			if Global.get_completed_runner_locations(planet_id).has(location_id):
				continue
			Global.set_active_mission(planet_id, location_id, mission_id)
			return {"planet_id": planet_id, "location_id": location_id, "mission": mission}

		var missions: Array = cfg.get_location_missions() if cfg.has_method("get_location_missions") else []
		var replay := _find_replay_mission_entry(planet_id, missions)
		if not replay.is_empty():
			return replay
	return {}


func _find_replay_mission_entry(planet_id: String, missions: Array) -> Dictionary:
	# 主线全清后：HOME 仍展示最后一条已点亮任务，允许再次进跑酷
	var best_mission: Dictionary = {}
	var best_order := -1
	for mission in missions:
		var location_id := String(mission.get("location_id", ""))
		if location_id == "":
			continue
		if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
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
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	var mission: Dictionary = cfg.get_mission_for_location(location_id) if cfg != null else {"location_id": location_id}
	var active := Global.get_active_mission(planet_id)
	if String(active.get("location_id", "")) == location_id and cfg != null and cfg.has_method("get_mission_by_id"):
		var active_mission: Dictionary = cfg.get_mission_by_id(String(active.get("mission_id", "")))
		if not active_mission.is_empty():
			mission = active_mission
	_start_runner_for_mission(planet_id, mission)


func _accept_mission(planet_id: String, location_id: String) -> void:
	if Global.get_completed_runner_locations(planet_id).has(location_id):
		_show_toast("该据点任务已完成")
		return
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		_show_toast("该批次任务尚未解锁")
		return
	Global.set_active_mission(planet_id, location_id)
	_show_toast("已设为当前据点任务")
	_show_tab(TAB_HOME, true)


func _select_ship(ship_id: String) -> void:
	Global.set_selected_ship(ship_id)
	_show_toast("已切换飞船：%s" % String(PlanetDatabase.get_ship(ship_id)["name"]))
	_show_tab(TAB_CHARACTER, true, true)


func _on_settings_story_review() -> void:
	_close_settings()
	_show_story_intro(true)


func _show_story_intro(replay: bool = false) -> void:
	if _story_overlay != null and is_instance_valid(_story_overlay):
		return
	_hide_dawnline_comic_hint()
	_story_intro_replay = replay
	if _story_canvas == null or not is_instance_valid(_story_canvas):
		_story_canvas = CanvasLayer.new()
		_story_canvas.name = "StoryCanvas"
		_story_canvas.layer = 55
		add_child(_story_canvas)
	var player := ComicIntroPlayer.new()
	player.name = "OpeningStoryIntro"
	player.set_anchors_preset(Control.PRESET_FULL_RECT)
	player.offset_right = 0.0
	player.offset_bottom = 0.0
	player.size = get_viewport_rect().size
	player.configure({
		"show_title": true,
		"allow_skip": true,
	})
	player.finished.connect(_on_story_intro_finished)
	player.skipped.connect(_on_story_intro_skipped)
	_story_canvas.add_child(player)
	_story_overlay = player


func _close_story_intro(mark_seen: bool) -> void:
	if _story_overlay != null and is_instance_valid(_story_overlay):
		_story_overlay.queue_free()
	_story_overlay = null
	if _story_canvas != null and is_instance_valid(_story_canvas):
		_story_canvas.queue_free()
		_story_canvas = null
	_story_intro_replay = false
	if mark_seen:
		Global.mark_opening_comic_seen()
	_refresh_dawnline_comic_hint()


func _on_story_intro_finished() -> void:
	var first_time := not _story_intro_replay
	_close_story_intro(first_time)
	if first_time:
		_start_home_guide()


func _on_story_intro_skipped() -> void:
	var first_time := not _story_intro_replay
	_close_story_intro(first_time)
	if first_time:
		_start_home_guide()


func _finish_story_intro() -> void:
	_close_story_intro(true)
	_start_home_guide()


func _start_home_guide() -> void:
	if Global.home_guide_seen:
		return
	if _guide_layer != null and is_instance_valid(_guide_layer):
		return
	_hide_dawnline_comic_hint()
	_guide_step = 0
	_build_guide_overlay()
	_show_guide_step(0)


func _build_guide_overlay() -> void:
	if _guide_layer != null and is_instance_valid(_guide_layer):
		_guide_layer.queue_free()
	_guide_layer = CanvasLayer.new()
	_guide_layer.name = "HomeGuideLayer"
	_guide_layer.layer = 60
	add_child(_guide_layer)

	_guide_overlay = Control.new()
	_guide_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_guide_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_guide_overlay.clip_contents = false
	_guide_layer.add_child(_guide_overlay)

	var shade := ColorRect.new()
	shade.name = "GuideShade"
	shade.color = Color(0.02, 0.04, 0.08, 0.72)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 底栏上方才遮罩，让 MAP / TASKS 保持可见
	shade.anchor_bottom = 0.9055
	shade.offset_bottom = 0.0
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_guide_overlay.add_child(shade)

	_guide_highlight = PanelContainer.new()
	_guide_highlight.name = "GuideHighlight"
	_guide_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_guide_highlight.clip_contents = false
	_guide_highlight.add_theme_stylebox_override(
		"panel",
		_style(Color(0.42, 0.86, 0.98, 0.18), UI_CYAN, 2, 14)
	)
	_guide_overlay.add_child(_guide_highlight)

	_guide_callout = PanelContainer.new()
	_guide_callout.name = "GuideCallout"
	_guide_callout.mouse_filter = Control.MOUSE_FILTER_STOP
	_guide_callout.clip_contents = false
	_guide_callout.custom_minimum_size = Vector2(560, 0)
	var callout_style := _style(Color(0.035, 0.07, 0.12, 0.97), UI_FRAME_BORDER, 2, 18)
	callout_style.content_margin_left = 0
	callout_style.content_margin_right = 0
	callout_style.content_margin_top = 0
	callout_style.content_margin_bottom = 0
	_guide_callout.add_theme_stylebox_override("panel", callout_style)
	_guide_overlay.add_child(_guide_callout)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 28)
	_guide_callout.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	margin.add_child(box)

	_guide_title_label = Label.new()
	_guide_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guide_title_label.clip_text = false
	_guide_title_label.add_theme_font_size_override("font_size", 34)
	_guide_title_label.add_theme_color_override("font_color", UI_CYAN_SOFT)
	_guide_title_label.add_theme_constant_override("line_spacing", 4)
	box.add_child(_guide_title_label)

	_guide_body_label = Label.new()
	_guide_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_guide_body_label.clip_text = false
	_guide_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_guide_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_guide_body_label.add_theme_font_size_override("font_size", 26)
	_guide_body_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	_guide_body_label.add_theme_constant_override("line_spacing", 10)
	box.add_child(_guide_body_label)

	_guide_next_button = Button.new()
	_guide_next_button.focus_mode = Control.FOCUS_NONE
	_guide_next_button.custom_minimum_size = Vector2(0, 60)
	_guide_next_button.add_theme_font_size_override("font_size", 24)
	_guide_next_button.add_theme_stylebox_override("normal", _style(UI_GOLD, UI_GOLD_BORDER, 2, 12))
	_guide_next_button.add_theme_stylebox_override("hover", _style(UI_GOLD.lightened(0.05), UI_GOLD_BORDER.lightened(0.04), 2, 12))
	_guide_next_button.add_theme_stylebox_override("pressed", _style(UI_GOLD.darkened(0.08), UI_GOLD_BORDER.darkened(0.04), 2, 12))
	_guide_next_button.add_theme_color_override("font_color", Color(0.08, 0.05, 0.02))
	_guide_next_button.pressed.connect(_on_guide_got_it_pressed)
	box.add_child(_guide_next_button)

	_set_nav_interactive(false)
	_update_guide_layout()


func _show_guide_step(step_index: int) -> void:
	if step_index < 0 or step_index >= GUIDE_STEPS.size():
		return
	var step: Dictionary = GUIDE_STEPS[step_index]
	var tab_id := String(step["tab"])
	_show_tab(tab_id, true)
	_guide_title_label.text = GameLocale.pick("从这里开始", "Start from here")
	_guide_body_label.text = GameLocale.pick(
		"点击 MAP，选择一个地图，查看各个据点和相关运输任务。也可以直接在 TASKS 里接取运输任务。",
		"Tap MAP, choose a region, then view outposts and transport missions. You can also accept missions directly in TASKS."
	)
	_guide_next_button.text = GameLocale.pick("知道了", "Got it")
	_update_guide_layout()
	call_deferred("_update_guide_layout")


func _on_guide_got_it_pressed() -> void:
	_finish_home_guide()


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
	_guide_highlight = null
	_guide_callout = null
	_guide_title_label = null
	_guide_body_label = null
	_guide_next_button = null
	_guide_overlay = null
	if _guide_layer != null and is_instance_valid(_guide_layer):
		_guide_layer.queue_free()
	_guide_layer = null


func _set_nav_interactive(enabled: bool) -> void:
	for button in _nav_buttons.values():
		button.disabled = not enabled


func _update_guide_layout() -> void:
	if _guide_overlay == null or _guide_step < 0 or _guide_step >= GUIDE_STEPS.size():
		return
	if _guide_callout == null or _guide_highlight == null:
		return
	var map_btn: Control = _nav_buttons.get(TAB_MAP)
	var tasks_btn: Control = _nav_buttons.get(TAB_TASKS)
	if map_btn == null:
		return

	# 高亮覆盖 MAP + TASKS
	var highlight_rect := map_btn.get_global_rect()
	if tasks_btn != null:
		highlight_rect = highlight_rect.merge(tasks_btn.get_global_rect())
	_guide_highlight.global_position = highlight_rect.position - Vector2(10, 10)
	_guide_highlight.size = highlight_rect.size + Vector2(20, 20)

	var viewport_size := get_viewport_rect().size
	var side_pad := 28.0
	var callout_width := minf(viewport_size.x - side_pad * 2.0, 640.0)
	_guide_callout.custom_minimum_size = Vector2(callout_width, 0)
	if _guide_body_label != null:
		_guide_body_label.custom_minimum_size = Vector2(maxi(callout_width - 64.0, 220.0), 0)
	_guide_callout.reset_size()
	var callout_size := _guide_callout.get_combined_minimum_size()
	callout_size.x = callout_width
	callout_size.y = maxf(callout_size.y, 180.0)
	_guide_callout.size = callout_size

	var nav_top := highlight_rect.position.y
	if _bottom_nav_root != null:
		nav_top = mini(nav_top, _bottom_nav_root.get_global_rect().position.y)
	var gap := 16.0
	# 贴在底栏 MAP / TASKS 正上方
	var callout_x := (viewport_size.x - callout_width) * 0.5
	var callout_y := nav_top - callout_size.y - gap
	var top_limit := 96.0
	if callout_y < top_limit:
		callout_y = top_limit
		callout_size.y = maxf(140.0, nav_top - gap - callout_y)
		_guide_callout.size = callout_size
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


func _tasks_spec_w(design_px: float) -> int:
	return _home_spec_w(design_px * TASKS_UI_SCALE)


func _tasks_spec_h(design_px: float) -> int:
	return _home_spec_h(design_px * TASKS_UI_SCALE)


func _tasks_spec_fs(design_px: float) -> int:
	return _home_spec_fs(design_px * TASKS_UI_SCALE)


func _tasks_spec_em(design_font_px: float, em: float) -> int:
	return _home_spec_em(design_font_px * TASKS_UI_SCALE, em)


func _settings_spec_w(design_px: float) -> int:
	return _home_spec_w(design_px * SETTINGS_UI_SCALE)


func _settings_spec_h(design_px: float) -> int:
	return _home_spec_h(design_px * SETTINGS_UI_SCALE)


func _settings_spec_fs(design_px: float) -> int:
	return _home_spec_fs(design_px * SETTINGS_UI_SCALE)


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
