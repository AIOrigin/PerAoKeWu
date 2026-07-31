extends Node3D

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")

const MAP_TEXTURE_FALLBACK := "res://assets/ddddd.png"
const MAX_REVEAL_POINTS := 24
const REGION_REVEAL_RADIUS := 0.118
const MOBILE_ASPECT_THRESHOLD := 1.15
const MOBILE_VIEWPORT_SIZE := Vector2(1080, 1920)
const MOBILE_TOP_CHROME_HEIGHT := 108.0
const MOBILE_BOTTOM_HINT_HEIGHT := 44.0

const LocationDetailPopup = preload("res://assets/maps/route_levels/planet_explore/location_detail_popup.gd")
const MapLocationMarker = preload("res://assets/maps/route_levels/planet_explore/map_location_marker.gd")
const MobilePauseOverlay = preload("res://assets/maps/route_levels/mobile_pause_overlay.gd")
const RUNNER_PRELOAD_PATHS := [
	"res://elsa动作/elsa正面.glb",
	"res://elsa动作/elsa奔跑左腿前.glb",
	"res://elsa动作/elsa奔跑右腿前.glb",
	"res://elsa动作/elsa起跳.glb",
	"res://elsa动作/elsa跳跃高点.glb",
	"res://elsa动作/跳跃落地.glb",
	"res://elsa动作/滑铲.glb",
	"res://mvp素材第二批/rook/rook立体.glb",
	"res://mvp素材第二批/rook/rook跑步1 左腿蹬地右腿在前.glb",
	"res://mvp素材第二批/rook/rook跑步2 右腿前踩地左腿空中.glb",
	"res://mvp素材第二批/rook/rook起跳.glb",
	"res://mvp素材第二批/rook/rook跳跃高点.glb",
	"res://mvp素材第二批/rook/rook跳跃落地.glb",
	"res://mvp素材第二批/rook/rook滑铲.glb",
	"res://3d素材/障碍物-需跳跃.glb",
	"res://3d素材/障碍物-需滑铲.glb",
]

var _location_data: Array[Dictionary] = []
var _revealed_location_ids: Array[String] = ["dome"]
var _reveal_points: Array[Vector2] = []
var _selected_location_id := "dome"
var _map_image_texture: Texture2D
var _map_image_size := Vector2(1152.0, 2048.0)
var _location_buttons: Dictionary = {}
var _map_root: Control
var _map_texture: TextureRect
var _fog_rect: ColorRect
var _location_layer: Control
var _connection_layer: Control
var _map_stats_label: Label
var _info_panel: PanelContainer
var _info_title: Label
var _info_status: Label
var _info_desc: Label
var _info_functions: Label
var _info_preview: TextureRect
var _story_button: Button
var _scan_button: Button
var _runner_button: Button
var _title_panel: PanelContainer
var _top_back_button: Button
var _mobile_hint_label: Label
var _detail_popup: LocationDetailPopup
var _ui_shell: Control
var _mobile_layout := true
var _pause_overlay: MobilePauseOverlay

@onready var legacy_panel: PanelContainer = $UI/Panel
@onready var hint_label: Label = $UI/Hint
@onready var back_button: Button = $UI/Panel/Margin/VBox/ButtonRow/BackButton
@onready var legacy_runner_button: Button = $UI/Panel/Margin/VBox/ButtonRow/RunnerButton


func _ready() -> void:
	add_to_group("PlanetExploreScene")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	back_button.pressed.connect(_return_to_galaxy)
	legacy_runner_button.pressed.connect(_start_runner)
	legacy_panel.visible = false
	hint_label.visible = false
	_mobile_layout = true
	hint_label.text = "点击地图上的地点进入详情  ·  累计运输进度满额后点亮据点"
	get_viewport().size_changed.connect(_on_viewport_resized)
	_load_map_texture()
	_build_location_data()
	_load_revealed_location_state()
	var unlocked_names := _apply_completed_runner_unlocks()
	if not unlocked_names.is_empty():
		hint_label.text = "跑酷完成：%s 已点亮" % "、".join(unlocked_names)
	_rebuild_reveal_points_from_revealed_locations()
	_build_map_ui()
	_setup_pause_overlay()
	_select_location(_selected_location_id)
	_maybe_show_pending_showcase()


func _maybe_show_pending_showcase() -> void:
	var location_id := Global.pending_location_showcase_id
	if location_id == "":
		return
	Global.pending_location_showcase_id = ""
	if not _is_revealed(location_id):
		return
	call_deferred("_show_location_showcase", location_id)


func _unhandled_input(event: InputEvent) -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		return
	if event.is_action_pressed("ui_cancel"):
		if _detail_popup != null:
			_close_location_detail()
			return
		if _pause_overlay != null:
			_pause_overlay.open_pause()
			get_viewport().set_input_as_handled()
		return
	elif event.is_action_pressed("ui_accept") and _detail_popup == null:
		_start_runner()


func _on_viewport_resized() -> void:
	_mobile_layout = _is_mobile_layout()
	_apply_responsive_layout()
	_layout_location_buttons()
	_update_reveal_shader()


func _on_explore_shell_resized() -> void:
	_mobile_layout = _is_mobile_layout()
	_apply_responsive_layout()
	call_deferred("_layout_location_buttons")
	_update_reveal_shader()


func _is_mobile_layout() -> bool:
	if _ui_shell != null and _ui_shell.size.x > 1.0 and _ui_shell.size.y > 1.0:
		return _ui_shell.size.y > _ui_shell.size.x * MOBILE_ASPECT_THRESHOLD
	var viewport_size := get_viewport().get_visible_rect().size
	return viewport_size.y > viewport_size.x * MOBILE_ASPECT_THRESHOLD


func _build_mobile_frame(ui: CanvasLayer) -> Control:
	var letterbox := ColorRect.new()
	letterbox.name = "Letterbox"
	letterbox.color = Color(0.02, 0.018, 0.014)
	letterbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	letterbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(letterbox)

	var frame := AspectRatioContainer.new()
	frame.name = "MobileExploreFrame"
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.stretch_mode = AspectRatioContainer.STRETCH_FIT
	frame.ratio = MOBILE_VIEWPORT_SIZE.x / MOBILE_VIEWPORT_SIZE.y
	frame.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	frame.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	ui.add_child(frame)

	var shell := Control.new()
	shell.name = "MobileExploreShell"
	shell.custom_minimum_size = MOBILE_VIEWPORT_SIZE
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(shell)
	shell.resized.connect(_on_explore_shell_resized)
	return shell


func _load_map_texture() -> void:
	var map_path := MAP_TEXTURE_FALLBACK
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	if cfg.has_method("get_explore_map_path"):
		map_path = String(cfg.get_explore_map_path())
	var loaded_texture: Texture2D = load(map_path) as Texture2D
	if loaded_texture == null:
		push_error("Failed to load planet map texture: %s" % map_path)
		loaded_texture = load(MAP_TEXTURE_FALLBACK) as Texture2D
	if loaded_texture == null:
		return
	_map_image_texture = loaded_texture
	_map_image_size = loaded_texture.get_size()
	if _map_image_size.x <= 1.0 or _map_image_size.y <= 1.0:
		_map_image_size = Vector2(1152.0, 2048.0)


func _build_location_data() -> void:
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	_location_data.clear()
	if cfg.has_method("get_explore_locations"):
		for item in cfg.get_explore_locations():
			if item is Dictionary:
				_location_data.append(item)


func _build_map_ui() -> void:
	var ui: CanvasLayer = $UI
	_ui_shell = _build_mobile_frame(ui)

	_map_root = Control.new()
	_map_root.name = "CrystalDesertMap"
	_map_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui_shell.add_child(_map_root)
	_ui_shell.move_child(_map_root, 0)

	_map_texture = TextureRect.new()
	_map_texture.name = "BaseMap"
	_map_texture.texture = _map_image_texture
	_map_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_map_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_map_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 直接点地图上的地点，不再叠圆形据点标记
	_map_texture.mouse_filter = Control.MOUSE_FILTER_STOP
	_map_texture.gui_input.connect(_on_map_gui_input)
	_map_root.add_child(_map_texture)

	var vignette := ColorRect.new()
	vignette.name = "WarmVignette"
	vignette.color = Color(0.16, 0.10, 0.05, 0.18)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_root.add_child(vignette)

	_fog_rect = ColorRect.new()
	_fog_rect.name = "FogLayer"
	_fog_rect.color = Color.WHITE
	_fog_rect.material = _create_fog_material()
	_fog_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fog_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_root.add_child(_fog_rect)

	_connection_layer = Control.new()
	_connection_layer.name = "ConnectionLayer"
	_connection_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_connection_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_connection_layer.visible = false
	_map_root.add_child(_connection_layer)

	_location_layer = Control.new()
	_location_layer.name = "LocationLayer"
	_location_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_location_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_location_layer.visible = false
	_map_root.add_child(_location_layer)

	# 不再生成 MapLocationMarker 圆形节点；点击走底图 hit-test
	_build_info_panel(_ui_shell)
	_build_top_chrome(_ui_shell)
	_build_mobile_hint(_ui_shell)
	_mobile_layout = true
	_apply_responsive_layout()
	_update_reveal_shader()
	_update_location_buttons()
	call_deferred("_layout_location_buttons")
	call_deferred("_refresh_map_stats")
	call_deferred("_warm_runner_assets")


func _create_fog_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec4 reveal_0 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_1 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_2 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_3 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_4 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_5 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_6 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_7 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_8 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_9 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_10 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_11 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_12 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_13 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_14 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_15 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_16 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_17 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_18 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_19 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_20 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_21 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_22 = vec4(-1.0, -1.0, 0.0, 0.0);
uniform vec4 reveal_23 = vec4(-1.0, -1.0, 0.0, 0.0);

float reveal_amount(vec2 uv, vec4 circle) {
	if (circle.z <= 0.0) {
		return 0.0;
	}
	float distance_to_center = distance(uv, circle.xy);
	return 1.0 - smoothstep(circle.z, circle.z + circle.w, distance_to_center);
}

void fragment() {
	vec2 uv = UV;
	float reveal = 0.0;
	reveal = max(reveal, reveal_amount(uv, reveal_0));
	reveal = max(reveal, reveal_amount(uv, reveal_1));
	reveal = max(reveal, reveal_amount(uv, reveal_2));
	reveal = max(reveal, reveal_amount(uv, reveal_3));
	reveal = max(reveal, reveal_amount(uv, reveal_4));
	reveal = max(reveal, reveal_amount(uv, reveal_5));
	reveal = max(reveal, reveal_amount(uv, reveal_6));
	reveal = max(reveal, reveal_amount(uv, reveal_7));
	reveal = max(reveal, reveal_amount(uv, reveal_8));
	reveal = max(reveal, reveal_amount(uv, reveal_9));
	reveal = max(reveal, reveal_amount(uv, reveal_10));
	reveal = max(reveal, reveal_amount(uv, reveal_11));
	reveal = max(reveal, reveal_amount(uv, reveal_12));
	reveal = max(reveal, reveal_amount(uv, reveal_13));
	reveal = max(reveal, reveal_amount(uv, reveal_14));
	reveal = max(reveal, reveal_amount(uv, reveal_15));
	reveal = max(reveal, reveal_amount(uv, reveal_16));
	reveal = max(reveal, reveal_amount(uv, reveal_17));
	reveal = max(reveal, reveal_amount(uv, reveal_18));
	reveal = max(reveal, reveal_amount(uv, reveal_19));
	reveal = max(reveal, reveal_amount(uv, reveal_20));
	reveal = max(reveal, reveal_amount(uv, reveal_21));
	reveal = max(reveal, reveal_amount(uv, reveal_22));
	reveal = max(reveal, reveal_amount(uv, reveal_23));
	float alpha = mix(0.76, 0.10, reveal);
	vec3 ink = vec3(0.025, 0.020, 0.016);
	COLOR = vec4(ink, alpha);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _build_top_chrome(ui: Control) -> void:
	const CHROME_FILL := Color(0.06, 0.08, 0.12, 0.94)
	const CHROME_BORDER := Color(0.34, 0.52, 0.68, 0.88)
	const CHROME_TEXT := Color(0.92, 0.95, 0.98)
	const CHROME_MUTED := Color(0.58, 0.64, 0.72)
	const CHROME_ACCENT := Color(0.42, 0.82, 0.98)

	_title_panel = PanelContainer.new()
	_title_panel.name = "MapTitlePanel"
	_title_panel.add_theme_stylebox_override("panel", _chrome_panel_style(CHROME_FILL, CHROME_BORDER))
	ui.add_child(_title_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	_title_panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	margin.add_child(hbox)

	var accent_bar := ColorRect.new()
	accent_bar.custom_minimum_size = Vector2(3, 0)
	accent_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	accent_bar.color = CHROME_ACCENT
	accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(accent_bar)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 2)
	hbox.add_child(title_box)

	var title := Label.new()
	title.text = "MAP 1"
	title.add_theme_color_override("font_color", CHROME_TEXT)
	title.add_theme_font_size_override("font_size", 22)
	title_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "ENDLESS GLASS DESERT"
	subtitle.add_theme_color_override("font_color", CHROME_MUTED)
	subtitle.add_theme_font_size_override("font_size", 12)
	title_box.add_child(subtitle)

	_map_stats_label = Label.new()
	_map_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_map_stats_label.add_theme_font_size_override("font_size", 13)
	hbox.add_child(_map_stats_label)
	_refresh_map_stats()

	_top_back_button = Button.new()
	_top_back_button.name = "BackToMobileMapButton"
	_top_back_button.text = "‹"
	_top_back_button.custom_minimum_size = Vector2(46, 46)
	_top_back_button.add_theme_font_size_override("font_size", 28)
	_style_chrome_button(_top_back_button)
	_top_back_button.pressed.connect(_return_to_galaxy)
	hbox.add_child(_top_back_button)


func _build_mobile_hint(ui: Control) -> void:
	_mobile_hint_label = Label.new()
	_mobile_hint_label.name = "MobileExploreHint"
	_mobile_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mobile_hint_label.add_theme_font_size_override("font_size", 15)
	_mobile_hint_label.add_theme_color_override("font_color", Color(0.92, 0.82, 0.62))
	ui.add_child(_mobile_hint_label)


func _build_info_panel(ui: Control) -> void:
	_info_panel = PanelContainer.new()
	_info_panel.name = "LocationInfoPanel"
	_info_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.76, 0.66, 0.50, 0.94), Color(0.15, 0.10, 0.055, 0.96), 2))
	ui.add_child(_info_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_info_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 11)
	margin.add_child(vbox)

	_info_title = Label.new()
	_info_title.add_theme_color_override("font_color", Color(0.15, 0.10, 0.04))
	_info_title.add_theme_font_size_override("font_size", 27)
	_info_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_info_title)

	_info_preview = TextureRect.new()
	_info_preview.custom_minimum_size = Vector2(0, 128)
	_info_preview.texture = _map_image_texture
	_info_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_info_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	vbox.add_child(_info_preview)

	_info_status = Label.new()
	_info_status.add_theme_color_override("font_color", Color(0.08, 0.34, 0.14))
	_info_status.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_info_status)

	_info_desc = Label.new()
	_info_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_desc.add_theme_color_override("font_color", Color(0.18, 0.13, 0.07))
	_info_desc.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_info_desc)

	_info_functions = Label.new()
	_info_functions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info_functions.add_theme_color_override("font_color", Color(0.18, 0.13, 0.07))
	_info_functions.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_info_functions)

	_story_button = Button.new()
	_story_button.custom_minimum_size = Vector2(0, 56)
	_story_button.text = "剧情"
	_story_button.add_theme_font_size_override("font_size", 18)
	_style_action_button(_story_button, Color(0.20, 0.15, 0.10, 0.95), Color(0.88, 0.74, 0.48))
	_story_button.pressed.connect(_show_selected_location_story)
	vbox.add_child(_story_button)

	_scan_button = Button.new()
	_scan_button.custom_minimum_size = Vector2(0, 58)
	_scan_button.text = "跑酷完成后解锁相邻区域"
	_scan_button.add_theme_font_size_override("font_size", 18)
	_style_action_button(_scan_button, Color(0.14, 0.11, 0.08, 0.92), Color(0.42, 0.32, 0.20))
	_scan_button.disabled = true
	vbox.add_child(_scan_button)

	var road_row := HBoxContainer.new()
	road_row.add_theme_constant_override("separation", 10)
	vbox.add_child(road_row)
	var road_title := Label.new()
	road_title.text = "跑道"
	road_title.custom_minimum_size = Vector2(72, 0)
	road_title.add_theme_font_size_override("font_size", 14)
	road_title.add_theme_color_override("font_color", Color(0.72, 0.86, 0.95))
	road_row.add_child(road_title)
	var road_option := OptionButton.new()
	road_option.name = "RoadStyleOption"
	road_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	road_option.custom_minimum_size = Vector2(0, 44)
	road_option.focus_mode = Control.FOCUS_NONE
	Global.populate_runner_road_style_option(road_option)
	road_option.item_selected.connect(func(index: int) -> void:
		if index >= 0 and index < Global.RUNNER_ROAD_STYLE_ORDER.size():
			Global.set_runner_road_style(Global.RUNNER_ROAD_STYLE_ORDER[index])
	)
	_style_explore_option_button(road_option)
	road_row.add_child(road_option)

	var bg_row := HBoxContainer.new()
	bg_row.add_theme_constant_override("separation", 10)
	vbox.add_child(bg_row)
	var bg_title := Label.new()
	bg_title.text = "背景"
	bg_title.custom_minimum_size = Vector2(72, 0)
	bg_title.add_theme_font_size_override("font_size", 14)
	bg_title.add_theme_color_override("font_color", Color(0.72, 0.86, 0.95))
	bg_row.add_child(bg_title)
	var bg_option := OptionButton.new()
	bg_option.name = "BackgroundStyleOption"
	bg_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bg_option.custom_minimum_size = Vector2(0, 44)
	bg_option.focus_mode = Control.FOCUS_NONE
	Global.populate_runner_background_style_option(bg_option)
	bg_option.item_selected.connect(func(index: int) -> void:
		if index >= 0 and index < Global.RUNNER_BACKGROUND_STYLE_ORDER.size():
			Global.set_runner_background_style(Global.RUNNER_BACKGROUND_STYLE_ORDER[index])
	)
	_style_explore_option_button(bg_option)
	bg_row.add_child(bg_option)

	_runner_button = Button.new()
	_runner_button.custom_minimum_size = Vector2(0, 62)
	_runner_button.text = "进入跑酷模式"
	_runner_button.add_theme_font_size_override("font_size", 20)
	_style_action_button(_runner_button, Color(0.86, 0.59, 0.27), Color(0.98, 0.82, 0.42))
	_runner_button.pressed.connect(_start_runner)
	_info_panel.visible = false
	vbox.add_child(_runner_button)


func _apply_responsive_layout() -> void:
	if _map_root == null:
		return
	_apply_map_root_layout()
	_apply_top_chrome_layout()
	_apply_info_panel_layout()
	if _map_texture:
		_map_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	if _info_preview:
		_info_preview.custom_minimum_size = Vector2(0, 168 if _mobile_layout else 128)
		_info_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if hint_label:
		hint_label.visible = not _mobile_layout
	if _mobile_hint_label:
		_mobile_hint_label.visible = _mobile_layout
		if _mobile_layout:
			_mobile_hint_label.text = "点击地图上的地点打开详情 · 拖拽旋转 3D 建筑"
	_apply_mobile_hint_layout()


func _apply_map_root_layout() -> void:
	_map_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _mobile_layout:
		_map_root.offset_left = 0.0
		_map_root.offset_top = MOBILE_TOP_CHROME_HEIGHT + 18.0
		_map_root.offset_right = 0.0
		_map_root.offset_bottom = -MOBILE_BOTTOM_HINT_HEIGHT - 24.0
	else:
		_map_root.offset_left = 0.0
		_map_root.offset_top = 0.0
		_map_root.offset_right = 0.0
		_map_root.offset_bottom = 0.0


func _apply_top_chrome_layout() -> void:
	if _title_panel == null:
		return
	if _mobile_layout:
		_title_panel.anchor_left = 0.0
		_title_panel.anchor_right = 1.0
		_title_panel.anchor_top = 0.0
		_title_panel.anchor_bottom = 0.0
		_title_panel.offset_left = 14.0
		_title_panel.offset_top = 12.0
		_title_panel.offset_right = -14.0
		_title_panel.offset_bottom = MOBILE_TOP_CHROME_HEIGHT - 6.0
	else:
		_title_panel.anchor_left = 0.0
		_title_panel.anchor_right = 0.0
		_title_panel.anchor_top = 0.0
		_title_panel.anchor_bottom = 0.0
		_title_panel.offset_left = 28.0
		_title_panel.offset_top = 22.0
		_title_panel.offset_right = 430.0
		_title_panel.offset_bottom = 118.0


func _apply_info_panel_layout() -> void:
	if _info_panel == null:
		return
	if _mobile_layout:
		_info_panel.anchor_left = 0.0
		_info_panel.anchor_right = 1.0
		_info_panel.anchor_top = 1.0
		_info_panel.anchor_bottom = 1.0
		_info_panel.offset_left = 22.0
		_info_panel.offset_top = -MOBILE_BOTTOM_HINT_HEIGHT - 20.0
		_info_panel.offset_right = -22.0
		_info_panel.offset_bottom = -20.0
	else:
		_info_panel.anchor_left = 1.0
		_info_panel.anchor_right = 1.0
		_info_panel.anchor_top = 0.5
		_info_panel.anchor_bottom = 0.5
		_info_panel.offset_left = -360.0
		_info_panel.offset_top = -245.0
		_info_panel.offset_right = -28.0
		_info_panel.offset_bottom = 245.0


func _add_location_button(location: Dictionary) -> void:
	# 保留接口兼容；探索地图已改为点底图地点，不再创建圆形标记
	pass


func _layout_location_buttons() -> void:
	# 无圆形节点可布局；连线层已隐藏
	pass


func _on_map_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_try_open_location_at_map_pos(touch.position)
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			_try_open_location_at_map_pos(mouse.position)


func _try_open_location_at_map_pos(local_pos: Vector2) -> void:
	var location_id := _hit_test_map_location(local_pos)
	if location_id == "":
		return
	_open_location_detail(location_id)


func _hit_test_map_location(local_pos: Vector2) -> String:
	var image_rect := _get_map_image_rect()
	if image_rect.size.x <= 1.0 or image_rect.size.y <= 1.0:
		return ""
	if not image_rect.has_point(local_pos):
		return ""
	var uv := Vector2(
		(local_pos.x - image_rect.position.x) / image_rect.size.x,
		(local_pos.y - image_rect.position.y) / image_rect.size.y
	)
	var best_id := ""
	var best_score := 999.0
	for location in _location_data:
		var id := String(location["id"])
		var hit := false
		var score := 999.0
		var area: Variant = location.get("area", [])
		if typeof(area) == TYPE_ARRAY and (area as Array).size() >= 3:
			var poly := PackedVector2Array()
			for p in area as Array:
				poly.append(p as Vector2)
			if Geometry2D.is_point_in_polygon(uv, poly):
				hit = true
				score = uv.distance_to(location["pos"] as Vector2)
		if not hit:
			var anchor: Vector2 = location["pos"]
			var radius := float(location.get("hit_radius", 0.09))
			var dist := uv.distance_to(anchor)
			if dist <= radius:
				hit = true
				score = dist
		if hit and score < best_score:
			best_score = score
			best_id = id
	return best_id


func _get_map_image_rect() -> Rect2:
	var root_size := _map_root.size if _map_root != null else get_viewport().get_visible_rect().size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport().get_visible_rect().size
	var viewport_aspect := root_size.x / root_size.y
	var image_aspect := _map_image_size.x / _map_image_size.y
	if _mobile_layout:
		if viewport_aspect < image_aspect:
			var width := root_size.x
			var height := width / image_aspect
			return Rect2(Vector2.ZERO, Vector2(width, height))
		var height := root_size.y
		var width := height * image_aspect
		return Rect2(Vector2((root_size.x - width) * 0.5, 0.0), Vector2(width, height))
	if viewport_aspect > image_aspect:
		var width := root_size.x
		var height := width / image_aspect
		return Rect2(Vector2(0.0, (root_size.y - height) * 0.5), Vector2(width, height))
	var height := root_size.y
	var width := height * image_aspect
	return Rect2(Vector2((root_size.x - width) * 0.5, 0.0), Vector2(width, height))


func _select_location(location_id: String) -> void:
	_selected_location_id = location_id
	var location := _get_location(location_id)
	if location.is_empty():
		return
	var revealed := _is_revealed(location_id)
	var completed := Global.get_completed_runner_locations(Global.exploration_planet_id).has(location_id)
	_info_title.text = String(location["name"])
	if completed:
		_info_status.text = "● 状态：Lit（已点亮）"
	elif revealed:
		_info_status.text = "● 状态：修复中"
	else:
		_info_status.text = "● 状态：未开放"
	if revealed:
		_info_desc.text = "%s\n%s" % [String(location.get("tagline", "")), String(location.get("goal", ""))]
	else:
		_info_desc.text = "还没轮到这个据点的任务哦。"
	_info_functions.text = ""
	_update_location_buttons()
	_refresh_map_stats()


func _open_location_detail(location_id: String) -> void:
	_select_location(location_id)
	_close_location_detail()
	var popup := LocationDetailPopup.new()
	popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup.story_pressed.connect(_on_detail_story_pressed)
	popup.runner_pressed.connect(_on_detail_runner_pressed)
	popup.closed.connect(_on_detail_closed)
	if _ui_shell:
		_ui_shell.add_child(popup)
		_ui_shell.move_child(popup, -1)
	else:
		$UI.add_child(popup)
	_set_detail_chrome_visible(false)
	_detail_popup = popup
	popup.call_deferred("present", _build_location_detail_payload(location_id))


func _close_location_detail() -> void:
	if _detail_popup == null:
		return
	_detail_popup.queue_free()
	_detail_popup = null
	_set_detail_chrome_visible(true)


func _set_detail_chrome_visible(visible: bool) -> void:
	if _title_panel:
		_title_panel.visible = visible
	if _top_back_button:
		_top_back_button.visible = visible
	if _mobile_hint_label:
		_mobile_hint_label.visible = visible and _mobile_layout


func _on_detail_closed() -> void:
	_detail_popup = null
	_set_detail_chrome_visible(true)


func _on_detail_story_pressed() -> void:
	_show_selected_location_story()


func _on_detail_runner_pressed() -> void:
	_close_location_detail()
	_start_runner_with_transition()


func _start_runner_with_transition() -> void:
	if not _is_revealed(_selected_location_id):
		return
	if _ui_shell and _ui_shell.get_node_or_null("RunnerTransitionOverlay") == null:
		var overlay := ColorRect.new()
		overlay.name = "RunnerTransitionOverlay"
		overlay.color = Color(0.03, 0.05, 0.08, 0.98)
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		_ui_shell.add_child(overlay)
		var label := Label.new()
		label.text = "正在进入运输任务…"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.94))
		overlay.add_child(label)
	call_deferred("_start_runner")


func _warm_runner_assets() -> void:
	for path in RUNNER_PRELOAD_PATHS:
		if ResourceLoader.exists(path):
			ResourceLoader.load_threaded_request(path)


func _build_location_detail_payload(location_id: String) -> Dictionary:
	var revealed := _is_revealed(location_id)
	var completed := Global.get_completed_runner_locations(Global.exploration_planet_id).has(location_id)
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	if cfg.has_method("build_detail_payload"):
		return cfg.build_detail_payload(location_id, revealed, completed)
	return {}


func _unlock_linked_locations(location_id: String) -> Array[String]:
	var unlocked_names: Array[String] = []
	if not _is_revealed(location_id):
		return unlocked_names
	var location := _get_location(location_id)
	for linked_id in location.get("reveal", []):
		var id := String(linked_id)
		if not _revealed_location_ids.has(id):
			_revealed_location_ids.append(id)
			var linked_location := _get_location(id)
			if not linked_location.is_empty():
				unlocked_names.append(String(linked_location["name"]))
	return unlocked_names


func _load_revealed_location_state() -> void:
	Global.ensure_mission_dispatch_ready(Global.exploration_planet_id)
	var fallback_ids: Array[String] = MissionDispatch.get_batch1_location_ids(Global.exploration_planet_id)
	if fallback_ids.is_empty():
		fallback_ids = ["dome"]
	_revealed_location_ids = Global.get_revealed_exploration_locations(Global.exploration_planet_id, fallback_ids)
	if _revealed_location_ids.has("pump"):
		_revealed_location_ids.erase("pump")
		if not _revealed_location_ids.has("reservoir"):
			_revealed_location_ids.append("reservoir")
	Global.set_revealed_exploration_locations(Global.exploration_planet_id, _revealed_location_ids)
	if _revealed_location_ids.has(Global.runner_location_id):
		_selected_location_id = Global.runner_location_id
	elif not _revealed_location_ids.is_empty():
		_selected_location_id = _revealed_location_ids[0]


func _apply_completed_runner_unlocks() -> Array[String]:
	var all_unlocked_names: Array[String] = []
	for location_id in Global.get_completed_runner_locations(Global.exploration_planet_id):
		for unlocked_name in _unlock_linked_locations(location_id):
			if not all_unlocked_names.has(unlocked_name):
				all_unlocked_names.append(unlocked_name)
	Global.set_revealed_exploration_locations(Global.exploration_planet_id, _revealed_location_ids)
	return all_unlocked_names


func _rebuild_reveal_points_from_revealed_locations() -> void:
	_reveal_points.clear()
	for location_id in _revealed_location_ids:
		var location := _get_location(location_id)
		if not location.is_empty():
			_add_location_reveal_points(location)


func _add_location_reveal_points(location: Dictionary) -> void:
	for point in location.get("area", [location["pos"]]):
		if _reveal_points.size() >= MAX_REVEAL_POINTS:
			return
		_reveal_points.append(point)


func _has_locked_linked_locations(location: Dictionary) -> bool:
	for linked_id in location.get("reveal", []):
		if not _revealed_location_ids.has(String(linked_id)):
			return true
	return false


func _update_location_buttons() -> void:
	for location in _location_data:
		var id := String(location["id"])
		var marker: MapLocationMarker = _location_buttons.get(id)
		if marker == null:
			continue
		var revealed := _is_revealed(id)
		var completed := Global.get_completed_runner_locations(Global.exploration_planet_id).has(id)
		var selected := id == _selected_location_id
		marker.apply_state(revealed, completed, selected)


func _update_reveal_shader() -> void:
	var material := _fog_rect.material as ShaderMaterial
	if material == null:
		return
	for i in MAX_REVEAL_POINTS:
		material.set_shader_parameter("reveal_%d" % i, Vector4(-1.0, -1.0, 0.0, 0.0))
	for i in min(_reveal_points.size(), MAX_REVEAL_POINTS):
		var screen_pos := _map_pos_to_screen_uv(_reveal_points[i])
		material.set_shader_parameter("reveal_%d" % i, Vector4(screen_pos.x, screen_pos.y, REGION_REVEAL_RADIUS, 0.070))


func _map_pos_to_screen_uv(map_pos: Vector2) -> Vector2:
	var image_rect := _get_map_image_rect()
	var root_size := _map_root.size if _map_root != null else get_viewport().get_visible_rect().size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport().get_visible_rect().size
	var local_pos := image_rect.position + Vector2(image_rect.size.x * map_pos.x, image_rect.size.y * map_pos.y)
	return Vector2(local_pos.x / root_size.x, local_pos.y / root_size.y)


func _panel_style(fill: Color, border: Color, border_width: int, radius: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _chrome_panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := _panel_style(fill, border, 1, 10)
	style.border_width_top = 2
	style.border_color = border
	style.shadow_color = Color(0.18, 0.42, 0.68, 0.28)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 2)
	return style


func _style_chrome_button(button: Button) -> void:
	var fill := Color(0.10, 0.13, 0.18, 0.96)
	var border := Color(0.38, 0.58, 0.76, 0.92)
	button.add_theme_stylebox_override("normal", _panel_style(fill, border, 1, 8))
	button.add_theme_stylebox_override("hover", _panel_style(fill.lightened(0.06), border.lightened(0.06), 1, 8))
	button.add_theme_stylebox_override("pressed", _panel_style(fill.darkened(0.08), border.darkened(0.04), 1, 8))
	button.add_theme_stylebox_override("disabled", _panel_style(fill.darkened(0.18), border.darkened(0.12), 1, 8))
	button.add_theme_color_override("font_color", Color(0.88, 0.94, 0.98))
	button.add_theme_color_override("font_disabled_color", Color(0.48, 0.52, 0.58))


func _style_action_button(button: Button, fill: Color, border: Color) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(fill, border, 2))
	button.add_theme_stylebox_override("hover", _panel_style(fill.lightened(0.08), border.lightened(0.08), 2))
	button.add_theme_stylebox_override("pressed", _panel_style(fill.darkened(0.12), border.darkened(0.08), 2))
	button.add_theme_stylebox_override("disabled", _panel_style(fill.darkened(0.22), border.darkened(0.12), 1))
	button.add_theme_color_override("font_color", Color(0.10, 0.07, 0.04))
	button.add_theme_color_override("font_disabled_color", Color(0.42, 0.36, 0.30))


func _style_explore_option_button(option: OptionButton) -> void:
	var fill := Color(0.14, 0.18, 0.24)
	var border := Color(0.35, 0.55, 0.7)
	option.add_theme_stylebox_override("normal", _panel_style(fill, border, 2))
	option.add_theme_stylebox_override("hover", _panel_style(fill.lightened(0.08), border.lightened(0.08), 2))
	option.add_theme_stylebox_override("pressed", _panel_style(fill.darkened(0.12), border.darkened(0.08), 2))
	option.add_theme_stylebox_override("focus", _panel_style(fill, border, 2))
	option.add_theme_font_size_override("font_size", 15)
	option.add_theme_color_override("font_color", Color(0.72, 0.86, 0.95))


func _apply_mobile_hint_layout() -> void:
	if _mobile_hint_label == null:
		return
	if not _mobile_layout:
		return
	_mobile_hint_label.anchor_left = 0.0
	_mobile_hint_label.anchor_right = 1.0
	_mobile_hint_label.anchor_top = 1.0
	_mobile_hint_label.anchor_bottom = 1.0
	_mobile_hint_label.offset_left = 24.0
	_mobile_hint_label.offset_right = -24.0
	_mobile_hint_label.offset_top = -MOBILE_BOTTOM_HINT_HEIGHT - 52.0
	_mobile_hint_label.offset_bottom = -MOBILE_BOTTOM_HINT_HEIGHT - 18.0


func _refresh_map_stats() -> void:
	if _map_stats_label == null:
		return
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	var total := int(cfg.get_outpost_count()) if cfg.has_method("get_outpost_count") else _location_data.size()
	var lit := 0
	for location in _location_data:
		if Global.get_completed_runner_locations(Global.exploration_planet_id).has(String(location["id"])):
			lit += 1
	var purify := int(round(float(lit) / float(maxi(total, 1)) * 100.0))
	_map_stats_label.text = "已点亮 %d/%d\n净化度 %d%%" % [lit, total, purify]
	_map_stats_label.add_theme_color_override("font_color", Color(0.58, 0.64, 0.72))


func _layout_connections() -> void:
	if _connection_layer == null:
		return
	for child in _connection_layer.get_children():
		child.queue_free()
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	if not cfg.has_method("get_explore_connections"):
		return
	var image_rect := _get_map_image_rect()
	var pos_map := {}
	for location in _location_data:
		var id := String(location["id"])
		var pos: Vector2 = location["pos"]
		pos_map[id] = image_rect.position + Vector2(image_rect.size.x * pos.x, image_rect.size.y * pos.y)
	for pair in cfg.get_explore_connections():
		if pair.size() < 2:
			continue
		var from_id := String(pair[0])
		var to_id := String(pair[1])
		if not pos_map.has(from_id) or not pos_map.has(to_id):
			continue
		var line := Line2D.new()
		line.points = PackedVector2Array([pos_map[from_id], pos_map[to_id]])
		line.width = 1.5
		line.default_color = Color(0.42, 0.72, 0.96, 0.38)
		line.antialiased = true
		_connection_layer.add_child(line)


func _is_revealed(location_id: String) -> bool:
	return _revealed_location_ids.has(location_id)


func _get_location(location_id: String) -> Dictionary:
	for location in _location_data:
		if String(location["id"]) == location_id:
			return location
	return {}


func _return_to_galaxy() -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		_pause_overlay.close_pause()
	Global.mobile_home_tab = "map"
	Global.change_game_scene(PlanetDatabase.MOBILE_HOME_SCENE)


func _setup_pause_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PauseLayer"
	layer.layer = 40
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_pause_overlay = MobilePauseOverlay.new()
	_pause_overlay.configure({
		"quit_text": "返回主界面",
		"show_quit": true,
		"show_pause_button": true,
	})
	_pause_overlay.quit_pressed.connect(_return_to_galaxy)
	layer.add_child(_pause_overlay)


func _start_runner() -> void:
	if not _is_revealed(_selected_location_id):
		return
	Global.runner_planet_id = Global.exploration_planet_id
	Global.runner_location_id = _selected_location_id
	Global.set_active_mission(Global.exploration_planet_id, _selected_location_id)
	Global.mobile_home_tab = "home"
	Global.change_game_scene(PlanetDatabase.RUNNER_SCENE)


func _show_selected_location_story() -> void:
	if not _is_revealed(_selected_location_id):
		return
	var location := _get_location(_selected_location_id)
	if location.is_empty():
		return
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	var mission: Dictionary = cfg.get_mission_for_location(_selected_location_id)
	var title := "%s · 剧情" % String(location["name"])
	var body := String(mission.get("story", "这里还没有新的剧情记录。"))
	if Global.get_completed_runner_locations(Global.exploration_planet_id).has(_selected_location_id):
		body += "\n\n运输完成后，据点广播恢复，居民开始向周边节点发送火种信号。"
	_show_story_overlay(title, body)


func _show_location_showcase(location_id: String) -> void:
	var location := _get_location(location_id)
	if location.is_empty():
		return
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	var preview_path := ""
	if cfg.has_method("get_location_preview_path"):
		preview_path = String(cfg.get_location_preview_path(location_id))
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	$UI.add_child(root)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.016, 0.012, 0.82)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 760)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.76, 0.66, 0.50, 0.98), Color(0.15, 0.10, 0.055, 0.96), 2))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	var title := Label.new()
	title.text = "%s · 已点亮" % String(location["name"])
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.15, 0.10, 0.04))
	title.add_theme_font_size_override("font_size", 28)
	box.add_child(title)

	if preview_path != "":
		var image := TextureRect.new()
		image.custom_minimum_size = Vector2(0, 420)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.texture = load(preview_path) as Texture2D
		box.add_child(image)

	var body := Label.new()
	body.text = "运输完成，据点已恢复运作。相邻区域可在地图上继续探索。"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_color_override("font_color", Color(0.18, 0.13, 0.07))
	body.add_theme_font_size_override("font_size", 17)
	box.add_child(body)

	var close := Button.new()
	close.text = "继续探索"
	close.custom_minimum_size = Vector2(0, 56)
	close.add_theme_font_size_override("font_size", 20)
	_style_action_button(close, Color(0.86, 0.59, 0.27), Color(0.98, 0.82, 0.42))
	close.pressed.connect(root.queue_free)
	box.add_child(close)

	_select_location(location_id)


func _show_story_overlay(title_text: String, body_text: String) -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	$UI.add_child(root)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.016, 0.012, 0.68)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 390)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.76, 0.66, 0.50, 0.98), Color(0.15, 0.10, 0.055, 0.96), 2))
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.15, 0.10, 0.04))
	title.add_theme_font_size_override("font_size", 30)
	box.add_child(title)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(0, 190)
	body.add_theme_color_override("font_color", Color(0.18, 0.13, 0.07))
	body.add_theme_font_size_override("font_size", 18)
	box.add_child(body)

	var close := Button.new()
	close.text = "关闭"
	close.custom_minimum_size = Vector2(0, 58)
	close.add_theme_font_size_override("font_size", 20)
	close.pressed.connect(root.queue_free)
	box.add_child(close)
