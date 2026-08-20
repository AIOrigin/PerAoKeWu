extends Node3D

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")

const MAP_TEXTURE_FALLBACK := "res://assets/ddddd.png"
const MAX_REVEAL_POINTS := 24
const REGION_REVEAL_RADIUS := 0.155
const CEREMONY_REVEAL_SOFTNESS := 0.085
const MOBILE_ASPECT_THRESHOLD := 1.15
const MOBILE_VIEWPORT_SIZE := Vector2(1080, 1920)
const MOBILE_TOP_CHROME_HEIGHT := 116.0
const MOBILE_BOTTOM_HINT_HEIGHT := 44.0
## 底图内装饰边框相对贴图的内缩（对齐顶栏与羊皮纸框）
const MAP_ART_FRAME_INSET := Vector4(0.045, 0.028, 0.045, 0.035) # L T R B

const LocationDetailPopup = preload("res://assets/maps/route_levels/planet_explore/location_detail_popup.gd")
const MapLocationMarker = preload("res://assets/maps/route_levels/planet_explore/map_location_marker.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
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
	"res://mvp素材第二批/障碍物/0803/能量屏障（滑铲）.glb",
	"res://assets/maps/route_levels/runner_60s/midground_props/cracked_sphere_robot.glb",
]

var _location_data: Array[Dictionary] = []
var _revealed_location_ids: Array[String] = ["dome", "reservoir"]
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
var _map_title_label: Label
var _top_back_button: Button
var _mobile_hint_label: Label
var _detail_popup: LocationDetailPopup
var _ui_shell: Control
var _mobile_layout := true
var _pause_overlay: MobilePauseOverlay
var _pending_detail_mission_id := ""
var _light_pulse: ColorRect
var _light_pulse_mat: ShaderMaterial
var _light_pulse_tween: Tween
var _ceremony_animating := false
var _ceremony_hint_active := false
var _temp_ceremony_points: Array[Vector2] = []
var _temp_ceremony_radius := 0.0
var _mobile_hint_panel: PanelContainer
var _mobile_aspect_frame: AspectRatioContainer

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
	Global.play_home_bgm()
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
	call_deferred("_maybe_start_pending_light_focus")


func _maybe_start_pending_light_focus() -> void:
	var focus_id := Global.pending_map_light_focus
	if focus_id == "":
		_ceremony_hint_active = false
		return
	if not Global.is_map_light_ceremony_pending(Global.exploration_planet_id, focus_id):
		Global.pending_map_light_focus = ""
		_ceremony_hint_active = false
		return
	_selected_location_id = focus_id
	_select_location(focus_id)
	_start_location_light_pulse(focus_id)
	var name := String(_get_location(focus_id).get("name", "据点"))
	_set_ceremony_hint("点击闪烁的%s，点亮并驱散雾气" % name)
	call_deferred("_layout_ceremony_hint_above_pulse")


func _set_ceremony_hint(text: String) -> void:
	_ceremony_hint_active = true
	if _mobile_hint_label:
		_mobile_hint_label.text = text
	if _mobile_hint_panel:
		_mobile_hint_panel.visible = _mobile_layout
	_layout_ceremony_hint_above_pulse()


func _clear_ceremony_hint() -> void:
	_ceremony_hint_active = false
	if _mobile_hint_panel:
		_mobile_hint_panel.visible = false


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
	_relayout_light_focus_ui()


func _on_explore_shell_resized() -> void:
	_mobile_layout = _is_mobile_layout()
	_apply_responsive_layout()
	call_deferred("_layout_location_buttons")
	_update_reveal_shader()
	call_deferred("_relayout_light_focus_ui")


func _relayout_light_focus_ui() -> void:
	if Global.pending_map_light_focus == "":
		return
	var loc := _get_location(Global.pending_map_light_focus)
	if loc.is_empty():
		return
	if _light_pulse != null and _light_pulse.visible:
		_layout_light_pulse_at(_location_tap_uv(loc))
	if _ceremony_hint_active:
		_layout_ceremony_hint_above_pulse()


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
	_mobile_aspect_frame = frame
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.stretch_mode = AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT
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

	_light_pulse = ColorRect.new()
	_light_pulse.name = "LightBeacon"
	_light_pulse.visible = false
	_light_pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_light_pulse_mat = _create_light_beacon_material()
	_light_pulse.material = _light_pulse_mat
	_light_pulse.color = Color.WHITE
	_map_root.add_child(_light_pulse)

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
	_location_layer.visible = true
	_map_root.add_child(_location_layer)

	_spawn_map_tap_markers()
	_build_info_panel(_ui_shell)
	_build_top_chrome(_ui_shell)
	_build_mobile_hint(_ui_shell)
	_mobile_layout = true
	_apply_responsive_layout()
	_update_reveal_shader()
	_update_location_buttons()
	call_deferred("_layout_location_buttons")
	call_deferred("_refresh_map_stats")
	call_deferred("_apply_top_chrome_layout")
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
	float alpha = mix(0.68, 0.08, reveal);
	vec3 ink = vec3(0.025, 0.020, 0.016);
	COLOR = vec4(ink, alpha);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _create_light_beacon_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);
	float flicker = 0.55 + 0.45 * sin(TIME * 11.0 + uv.y * 9.0);
	float pulse = 0.5 + 0.5 * sin(TIME * 3.2);

	// 柔光晕：无硬边圆圈
	float glow = exp(-r * r * 2.8) * (0.38 + 0.22 * pulse);
	glow *= smoothstep(1.05, 0.15, r);

	// 中心跳跃火苗（竖向椭圆 + 抖动）
	float wobble = 0.04 * sin(TIME * 14.0);
	vec2 flame_uv = vec2(uv.x * (2.2 + wobble), (uv.y + 0.12) * 1.55);
	float flame_core = exp(-dot(flame_uv, flame_uv) * 7.5) * flicker;
	float flame_tip = exp(-length(vec2(uv.x * 3.2, uv.y * 2.4 + 0.35)) * 6.0) * (0.5 + 0.5 * flicker);
	float flame = (flame_core * 1.15 + flame_tip * 0.85) * smoothstep(0.62, 0.0, r);

	// 向外扩散的光波环
	float t = fract(TIME * 0.48);
	float t2 = fract(TIME * 0.48 + 0.5);
	float wave1 = exp(-pow((r - t * 0.95) * 14.0, 2.0)) * (1.0 - t) * 0.72;
	float wave2 = exp(-pow((r - t2 * 0.95) * 14.0, 2.0)) * (1.0 - t2) * 0.48;
	float waves = (wave1 + wave2) * smoothstep(1.0, 0.2, r);

	vec3 col = vec3(1.0, 0.62, 0.18) * glow;
	col += vec3(1.0, 0.88, 0.35) * flame;
	col += vec3(1.0, 0.78, 0.28) * waves;
	float alpha = clamp(glow * 0.9 + flame * 0.98 + waves * 0.75, 0.0, 1.0);
	COLOR = vec4(col, alpha);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _build_top_chrome(ui: Control) -> void:
	const CHROME_FILL := Color(0.06, 0.08, 0.12, 0.94)
	const CHROME_BORDER := Color(0.34, 0.52, 0.68, 0.88)
	const CHROME_TEXT := Color(0.92, 0.95, 0.98)
	const CHROME_ACCENT := Color(0.42, 0.82, 0.98)

	_title_panel = PanelContainer.new()
	_title_panel.name = "MapTitlePanel"
	_title_panel.add_theme_stylebox_override("panel", _chrome_panel_style(CHROME_FILL, CHROME_BORDER))
	ui.add_child(_title_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 6)
	_title_panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(hbox)

	var accent_bar := ColorRect.new()
	accent_bar.custom_minimum_size = Vector2(4, 52)
	accent_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	accent_bar.color = CHROME_ACCENT
	accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(accent_bar)

	var title := Label.new()
	title.text = _resolve_map_chrome_title()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", CHROME_TEXT)
	title.add_theme_font_size_override("font_size", 32)
	hbox.add_child(title)
	_map_title_label = title

	_map_stats_label = Label.new()
	_map_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_map_stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_map_stats_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_map_stats_label.add_theme_font_size_override("font_size", 14)
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


func _resolve_map_chrome_title() -> String:
	match Global.exploration_planet_id:
		"glass_desert":
			return PlanetDatabase.GlassDesert.MAP_CHROME_TITLE
		"rust_belt":
			return PlanetDatabase.RustBelt.MAP_NAME_EN
		"savanna_ring":
			return PlanetDatabase.SavannaRing.MAP_NAME_EN
		_:
			return "Crystal Waste"


func _map_uses_cover_fill() -> bool:
	return _mobile_layout

func _map_root_local_rect() -> Rect2:
	var root_size := _map_root.size if _map_root != null else Vector2.ZERO
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport().get_visible_rect().size
	return Rect2(Vector2.ZERO, root_size)

func _map_uv_to_local(uv: Vector2) -> Vector2:
	var root_size := _map_root_local_rect().size
	if not _map_uses_cover_fill():
		var image_rect := _get_map_image_rect()
		return image_rect.position + Vector2(image_rect.size.x * uv.x, image_rect.size.y * uv.y)
	var image_aspect := _map_image_size.x / maxf(_map_image_size.y, 1.0)
	var root_aspect := root_size.x / maxf(root_size.y, 1.0)
	if root_aspect > image_aspect:
		var tex_display_h := root_size.x / image_aspect
		var crop_top := (tex_display_h - root_size.y) * 0.5
		return Vector2(uv.x * root_size.x, uv.y * tex_display_h - crop_top)
	var tex_display_w := root_size.y * image_aspect
	var crop_left := (tex_display_w - root_size.x) * 0.5
	return Vector2(uv.x * tex_display_w - crop_left, uv.y * root_size.y)

func _map_local_to_uv(local_pos: Vector2) -> Vector2:
	if not _map_uses_cover_fill():
		var image_rect := _get_map_image_rect()
		return Vector2(
			(local_pos.x - image_rect.position.x) / maxf(image_rect.size.x, 1.0),
			(local_pos.y - image_rect.position.y) / maxf(image_rect.size.y, 1.0)
		)
	var root_size := _map_root_local_rect().size
	var image_aspect := _map_image_size.x / maxf(_map_image_size.y, 1.0)
	var root_aspect := root_size.x / maxf(root_size.y, 1.0)
	if root_aspect > image_aspect:
		var tex_display_h := root_size.x / image_aspect
		var crop_top := (tex_display_h - root_size.y) * 0.5
		return Vector2(
			local_pos.x / maxf(root_size.x, 1.0),
			(local_pos.y + crop_top) / maxf(tex_display_h, 1.0)
		)
	var tex_display_w := root_size.y * image_aspect
	var crop_left := (tex_display_w - root_size.x) * 0.5
	return Vector2(
		(local_pos.x + crop_left) / maxf(tex_display_w, 1.0),
		local_pos.y / maxf(root_size.y, 1.0)
	)


func _get_map_chrome_align_rect() -> Rect2:
	if _ui_shell == null:
		return Rect2()
	return Rect2(Vector2.ZERO, Vector2(_ui_shell.size.x, 0.0))


func _build_mobile_hint(ui: Control) -> void:
	_mobile_hint_panel = PanelContainer.new()
	_mobile_hint_panel.name = "MobileExploreHintPanel"
	_mobile_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hint_style := StyleBoxFlat.new()
	hint_style.bg_color = Color(0.05, 0.07, 0.10, 0.88)
	hint_style.border_color = Color(0.98, 0.82, 0.38, 0.85)
	hint_style.set_border_width_all(1)
	hint_style.set_corner_radius_all(10)
	hint_style.content_margin_left = 14
	hint_style.content_margin_right = 14
	hint_style.content_margin_top = 8
	hint_style.content_margin_bottom = 8
	_mobile_hint_panel.add_theme_stylebox_override("panel", hint_style)
	_mobile_hint_panel.visible = false
	ui.add_child(_mobile_hint_panel)

	_mobile_hint_label = Label.new()
	_mobile_hint_label.name = "MobileExploreHint"
	_mobile_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mobile_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_mobile_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mobile_hint_label.add_theme_font_size_override("font_size", 20)
	_mobile_hint_label.add_theme_color_override("font_color", Color(0.98, 0.90, 0.62))
	_mobile_hint_panel.add_child(_mobile_hint_label)


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
		_map_texture.stretch_mode = (
			TextureRect.STRETCH_KEEP_ASPECT_COVERED
			if _mobile_layout
			else TextureRect.STRETCH_KEEP_ASPECT
		)
	if _mobile_aspect_frame:
		_mobile_aspect_frame.stretch_mode = (
			AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT
			if _mobile_layout
			else AspectRatioContainer.STRETCH_FIT
		)
	if _info_preview:
		_info_preview.custom_minimum_size = Vector2(0, 168 if _mobile_layout else 128)
		_info_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if hint_label:
		hint_label.visible = not _mobile_layout
	if _mobile_hint_panel:
		_mobile_hint_panel.visible = _mobile_layout and _ceremony_hint_active
	_apply_mobile_hint_layout()


func _apply_map_root_layout() -> void:
	_map_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _mobile_layout:
		_map_root.offset_left = 0.0
		_map_root.offset_top = MOBILE_TOP_CHROME_HEIGHT + 10.0
		_map_root.offset_right = 0.0
		_map_root.offset_bottom = -8.0
	else:
		_map_root.offset_left = 0.0
		_map_root.offset_top = 0.0
		_map_root.offset_right = 0.0
		_map_root.offset_bottom = 0.0


func _apply_top_chrome_layout() -> void:
	if _title_panel == null:
		return
	if _mobile_layout:
		var bar_h := MOBILE_TOP_CHROME_HEIGHT
		var bar_top := 8.0
		_title_panel.anchor_left = 0.0
		_title_panel.anchor_right = 1.0
		_title_panel.anchor_top = 0.0
		_title_panel.anchor_bottom = 0.0
		_title_panel.offset_left = 0.0
		_title_panel.offset_top = bar_top
		_title_panel.offset_right = 0.0
		_title_panel.offset_bottom = -(bar_top + bar_h)
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
	pass


func _spawn_map_tap_markers() -> void:
	for child in _location_layer.get_children():
		child.queue_free()
	_location_buttons.clear()
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	for location in _location_data:
		var id := String(location.get("id", ""))
		if id == "":
			continue
		if not bool(location.get("open_detail", true)):
			continue
		var marker := MapLocationMarker.new()
		marker.name = "Tap_%s" % id
		var preview_path := ""
		if cfg != null and cfg.has_method("get_location_preview_path"):
			preview_path = String(cfg.get_location_preview_path(id))
		var display_name := String(location.get("name_en", location.get("name", id)))
		var type_icon := "◎"
		if cfg != null and cfg.has_method("get_type_icon"):
			type_icon = String(cfg.get_type_icon(id))
		marker.configure(id, display_name, preview_path, type_icon)
		marker.set_pin_mode(true)
		marker.activated.connect(_on_map_marker_activated.bind(id))
		_location_layer.add_child(marker)
		_location_buttons[id] = marker
	call_deferred("_layout_location_buttons")


func _on_map_marker_activated(location_id: String) -> void:
	if _ceremony_animating:
		return
	var location := _get_location(location_id)
	if location.is_empty():
		return
	var open_detail := bool(location.get("open_detail", true))
	var needs_ceremony := Global.is_map_light_ceremony_pending(Global.exploration_planet_id, location_id)
	if needs_ceremony:
		_play_light_ceremony_then_maybe_open(location_id, open_detail)
		return
	if not open_detail:
		_select_location(location_id)
		return
	_open_location_detail(location_id)


func _location_tap_uv(location: Dictionary) -> Vector2:
	if location.has("tap_uv"):
		return location.get("tap_uv") as Vector2
	return location.get("pos", Vector2(0.5, 0.5)) as Vector2


func _layout_location_buttons() -> void:
	if _location_layer == null:
		return
	for location in _location_data:
		var id := String(location.get("id", ""))
		var marker: MapLocationMarker = _location_buttons.get(id)
		if marker == null:
			continue
		var uv := _location_tap_uv(location)
		var pixel_offset := Vector2.ZERO
		if location.has("tap_offset"):
			pixel_offset = location.get("tap_offset") as Vector2
		var center := _map_uv_to_local(uv) + pixel_offset
		var size := marker.size
		if size.x <= 1.0:
			size = Vector2(MapLocationMarker.PIN_HIT, MapLocationMarker.PIN_HIT)
		# pin 三角尖端对准 tap_uv（底图圆标中心）
		marker.position = center - Vector2(size.x * 0.5, size.y * 0.5 + MapLocationMarker.PIN_TIP_OFFSET_Y)
		var revealed := _is_revealed(id)
		var preview := MissionDispatch.is_preview_location(Global.exploration_planet_id, id)
		var completed := Global.get_completed_runner_locations(Global.exploration_planet_id).has(id)
		var selected := id == _selected_location_id
		marker.apply_state(revealed, completed, selected, preview)


func _on_map_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_try_open_location_at_map_pos(_map_input_local_pos(event))
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			_try_open_location_at_map_pos(_map_input_local_pos(event))


func _map_input_local_pos(event: InputEvent) -> Vector2:
	if _map_texture == null:
		return Vector2.ZERO
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		return _map_texture.get_global_transform_with_canvas().affine_inverse() * touch.position
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).position
	return Vector2.ZERO


func _try_open_location_at_map_pos(local_pos: Vector2) -> void:
	if _ceremony_animating:
		return
	var location_id := _hit_test_map_location(local_pos)
	if location_id == "":
		return
	var location := _get_location(location_id)
	if location.is_empty():
		return
	var open_detail := bool(location.get("open_detail", true))
	var needs_ceremony := Global.is_map_light_ceremony_pending(Global.exploration_planet_id, location_id)
	if needs_ceremony:
		_play_light_ceremony_then_maybe_open(location_id, open_detail)
		return
	if not open_detail:
		_select_location(location_id)
		return
	_open_location_detail(location_id)


func _play_light_ceremony_then_maybe_open(location_id: String, open_detail: bool) -> void:
	_ceremony_animating = true
	_stop_location_light_pulse()
	Global.complete_map_light_ceremony(Global.exploration_planet_id, location_id)
	var location := _get_location(location_id)
	_temp_ceremony_points.clear()
	var area: Variant = location.get("area", [])
	if typeof(area) == TYPE_ARRAY and (area as Array).size() > 0:
		for point in area as Array:
			_temp_ceremony_points.append(point as Vector2)
	else:
		_temp_ceremony_points.append(location.get("pos", Vector2(0.5, 0.5)) as Vector2)
	_temp_ceremony_radius = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_temp_ceremony_radius, 0.02, REGION_REVEAL_RADIUS, 1.15)
	tween.tween_callback(func() -> void:
		_temp_ceremony_points.clear()
		_temp_ceremony_radius = 0.0
		_rebuild_reveal_points_from_revealed_locations()
		_update_reveal_shader()
		_ceremony_animating = false
		_clear_ceremony_hint()
		_select_location(location_id)
		if open_detail:
			_open_location_detail(location_id)
	)


func _set_temp_ceremony_radius(radius: float) -> void:
	_temp_ceremony_radius = radius
	_update_reveal_shader()


func _start_location_light_pulse(location_id: String) -> void:
	if _light_pulse == null:
		return
	var location := _get_location(location_id)
	if location.is_empty():
		return
	_layout_light_pulse_at(_location_tap_uv(location))
	_light_pulse.visible = true
	_light_pulse.modulate = Color(1, 1, 1, 1)
	if _light_pulse_tween and _light_pulse_tween.is_valid():
		_light_pulse_tween.kill()
	# 亮度呼吸，不改形状（形状由 shader 火苗/光波负责）
	_light_pulse_tween = create_tween()
	_light_pulse_tween.set_loops()
	_light_pulse_tween.tween_property(_light_pulse, "modulate:a", 0.78, 0.7)
	_light_pulse_tween.tween_property(_light_pulse, "modulate:a", 1.0, 0.7)


func _stop_location_light_pulse() -> void:
	if _light_pulse_tween and _light_pulse_tween.is_valid():
		_light_pulse_tween.kill()
	_light_pulse_tween = null
	if _light_pulse:
		_light_pulse.visible = false


func _layout_light_pulse_at(map_pos: Vector2) -> void:
	if _light_pulse == null:
		return
	var center := _map_uv_to_local(map_pos)
	var root_size := _map_root_local_rect().size
	var diameter := mini(root_size.x, root_size.y) * 0.28
	_light_pulse.size = Vector2(diameter, diameter)
	_light_pulse.position = center - _light_pulse.size * 0.5


func _open_location_detail(location_id: String) -> void:
	var location := _get_location(location_id)
	if location.is_empty():
		return
	if not bool(location.get("open_detail", true)):
		_select_location(location_id)
		return
	_select_location(location_id)
	_close_location_detail()
	var popup := LocationDetailPopup.new()
	popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	popup.story_pressed.connect(_on_detail_story_pressed)
	popup.runner_pressed.connect(_on_detail_runner_pressed)
	popup.reward_claim_pressed.connect(_on_detail_reward_claim_pressed)
	popup.view_runner_pressed.connect(_on_detail_view_runner_pressed)
	popup.closed.connect(_on_detail_closed)
	if _ui_shell:
		_ui_shell.add_child(popup)
		_ui_shell.move_child(popup, -1)
	else:
		$UI.add_child(popup)
	_set_detail_chrome_visible(false)
	_detail_popup = popup
	popup.call_deferred("present", _build_location_detail_payload(location_id))


func _hit_test_map_location(local_pos: Vector2) -> String:
	var bounds := _map_root_local_rect()
	if bounds.size.x <= 1.0 or bounds.size.y <= 1.0:
		return ""
	if not bounds.has_point(local_pos):
		return ""
	var uv := _map_local_to_uv(local_pos)
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
			var anchor: Vector2 = _location_tap_uv(location)
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
	if _map_uses_cover_fill():
		return _map_root_local_rect()
	# 与 TextureRect STRETCH_KEEP_ASPECT 一致：等比缩放并居中
	var root_size := _map_root.size if _map_root != null else get_viewport().get_visible_rect().size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport().get_visible_rect().size
	var image_aspect := _map_image_size.x / maxf(_map_image_size.y, 1.0)
	var root_aspect := root_size.x / maxf(root_size.y, 1.0)
	var size := Vector2.ZERO
	if root_aspect > image_aspect:
		size = Vector2(root_size.y * image_aspect, root_size.y)
	else:
		size = Vector2(root_size.x, root_size.x / image_aspect)
	var pos := (root_size - size) * 0.5
	return Rect2(pos, size)


func _get_map_frame_rect(image_rect: Rect2 = Rect2()) -> Rect2:
	# 贴图内装饰边框，用于顶栏与提示对齐羊皮纸框
	if image_rect.size.x <= 1.0:
		image_rect = _get_map_image_rect()
	var left := image_rect.size.x * MAP_ART_FRAME_INSET.x
	var top := image_rect.size.y * MAP_ART_FRAME_INSET.y
	var right := image_rect.size.x * MAP_ART_FRAME_INSET.z
	var bottom := image_rect.size.y * MAP_ART_FRAME_INSET.w
	return Rect2(
		image_rect.position + Vector2(left, top),
		image_rect.size - Vector2(left + right, top + bottom)
	)


func _select_location(location_id: String) -> void:
	_selected_location_id = location_id
	var location := _get_location(location_id)
	if location.is_empty():
		return
	var revealed := _is_revealed(location_id)
	var preview := MissionDispatch.is_preview_location(Global.exploration_planet_id, location_id)
	var completed := Global.get_completed_runner_locations(Global.exploration_planet_id).has(location_id)
	_info_title.text = String(location["name"])
	if completed:
		_info_status.text = "● 状态：已点亮"
	elif preview:
		_info_status.text = "● 状态：预览（批次未开放）"
	elif revealed:
		_info_status.text = "● 状态：运输修复中"
	else:
		_info_status.text = "● 状态：未开放"
	if revealed or preview:
		_info_desc.text = "%s\n%s" % [String(location.get("tagline", "")), String(location.get("goal", ""))]
	else:
		_info_desc.text = "还没轮到这个据点的任务哦。"
	_info_functions.text = ""
	_update_location_buttons()
	_refresh_map_stats()


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
	if _mobile_hint_panel:
		_mobile_hint_panel.visible = visible and _mobile_layout and _ceremony_hint_active
	elif _mobile_hint_label:
		_mobile_hint_label.visible = visible and _mobile_layout


func _on_detail_closed() -> void:
	_detail_popup = null
	_set_detail_chrome_visible(true)


func _on_detail_story_pressed() -> void:
	_show_selected_location_story()


func _on_detail_runner_pressed(mission_id: String = "") -> void:
	var location_id := _selected_location_id
	if MissionDispatch.is_preview_location(Global.exploration_planet_id, location_id):
		if not MissionDispatch.can_preview_trial_run(Global.exploration_planet_id, location_id):
			return
	_pending_detail_mission_id = mission_id
	_close_location_detail()
	_start_runner_with_transition()


func _on_detail_reward_claim_pressed() -> void:
	if _detail_popup == null:
		return
	var location_id := _selected_location_id
	var snapshot_before: Dictionary = Global.get_messenger_snapshot()
	var was_rook_locked := not CharacterRoster.is_unlocked(
		CharacterRoster.CHAR_ROOK,
		snapshot_before.get("unlocked_stories", [])
	)
	var result: Dictionary = Global.claim_outpost_light_reward(Global.exploration_planet_id, location_id)
	var coins := int(result.get("coins", 0))
	var character_unlocked := bool(result.get("character_unlocked", false))
	if coins <= 0 and not character_unlocked:
		return
	if _detail_popup.has_method("present"):
		_detail_popup.present(_build_location_detail_payload(location_id))
	if character_unlocked and was_rook_locked:
		var unlock_name := String(result.get("unlock_character", "Rook"))
		if _detail_popup.has_method("play_character_unlock_reveal"):
			_detail_popup.play_character_unlock_reveal(unlock_name)


func _on_detail_view_runner_pressed(character_id: String) -> void:
	Global.mobile_home_tab = "character"
	Global.set_selected_character(character_id if character_id != "" else CharacterRoster.CHAR_ROOK)
	Global.change_game_scene(PlanetDatabase.MOBILE_HOME_SCENE)


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
	var batch_revealed := _is_revealed(location_id)
	var preview := MissionDispatch.is_preview_location(Global.exploration_planet_id, location_id)
	var completed := Global.get_completed_runner_locations(Global.exploration_planet_id).has(location_id)
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	if cfg.has_method("build_detail_payload"):
		return cfg.build_detail_payload(location_id, batch_revealed, completed, preview)
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
	Global.sync_mission_dispatch(Global.exploration_planet_id)
	_load_revealed_location_state()
	_rebuild_reveal_points_from_revealed_locations()
	return []


func _rebuild_reveal_points_from_revealed_locations() -> void:
	_reveal_points.clear()
	# 初始保留阴影；仅完成点亮仪式的据点驱散周围雾气
	for location_id in Global.get_map_light_ceremony_done(Global.exploration_planet_id):
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
	call_deferred("_layout_location_buttons")


func _update_reveal_shader() -> void:
	var material := _fog_rect.material as ShaderMaterial
	if material == null:
		return
	for i in MAX_REVEAL_POINTS:
		material.set_shader_parameter("reveal_%d" % i, Vector4(-1.0, -1.0, 0.0, 0.0))
	var write_index := 0
	for point in _reveal_points:
		if write_index >= MAX_REVEAL_POINTS:
			break
		var screen_pos := _map_pos_to_screen_uv(point)
		material.set_shader_parameter(
			"reveal_%d" % write_index,
			Vector4(screen_pos.x, screen_pos.y, REGION_REVEAL_RADIUS, CEREMONY_REVEAL_SOFTNESS)
		)
		write_index += 1
	if _temp_ceremony_radius > 0.0:
		for point in _temp_ceremony_points:
			if write_index >= MAX_REVEAL_POINTS:
				break
			var screen_pos := _map_pos_to_screen_uv(point)
			material.set_shader_parameter(
				"reveal_%d" % write_index,
				Vector4(screen_pos.x, screen_pos.y, _temp_ceremony_radius, CEREMONY_REVEAL_SOFTNESS)
			)
			write_index += 1


func _map_pos_to_screen_uv(map_pos: Vector2) -> Vector2:
	var root_size := _map_root.size if _map_root != null else get_viewport().get_visible_rect().size
	if root_size.x <= 1.0 or root_size.y <= 1.0:
		root_size = get_viewport().get_visible_rect().size
	var local_pos := _map_uv_to_local(map_pos)
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
	if _mobile_hint_panel == null:
		return
	if not _mobile_layout or not _ceremony_hint_active:
		_mobile_hint_panel.visible = false
		return
	if Global.pending_map_light_focus != "":
		_layout_ceremony_hint_above_pulse()


func _layout_ceremony_hint_above_pulse() -> void:
	if _mobile_hint_panel == null or not _mobile_layout:
		return
	var focus_id := Global.pending_map_light_focus
	if focus_id == "":
		return
	var location := _get_location(focus_id)
	if location.is_empty() or _map_root == null:
		return
	var map_pos: Vector2 = _location_tap_uv(location)
	var pulse_center_local := _map_uv_to_local(map_pos)
	var root_size := _map_root_local_rect().size
	var pulse_center_shell := _map_root.position + pulse_center_local
	var diameter := mini(root_size.x, root_size.y) * 0.28
	var hint_w := clampf(root_size.x * 0.72, 280.0, 520.0)
	var hint_h := 64.0
	var hint_x := pulse_center_shell.x - hint_w * 0.5
	var hint_y := pulse_center_shell.y - diameter * 0.52 - hint_h - 12.0
	var shell_w := _ui_shell.size.x if _ui_shell != null else hint_w + 20.0
	hint_x = clampf(hint_x, 12.0, maxf(12.0, shell_w - hint_w - 12.0))
	hint_y = maxf(MOBILE_TOP_CHROME_HEIGHT + 8.0, hint_y)
	_mobile_hint_panel.anchor_left = 0.0
	_mobile_hint_panel.anchor_right = 0.0
	_mobile_hint_panel.anchor_top = 0.0
	_mobile_hint_panel.anchor_bottom = 0.0
	_mobile_hint_panel.position = Vector2(hint_x, hint_y)
	_mobile_hint_panel.size = Vector2(hint_w, hint_h)
	if _mobile_hint_label:
		_mobile_hint_label.add_theme_font_size_override("font_size", 20)
	_mobile_hint_panel.visible = true


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
	var pos_map := {}
	for location in _location_data:
		var id := String(location["id"])
		var pos: Vector2 = location["pos"]
		pos_map[id] = _map_uv_to_local(pos)
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
	# 地图可见 = 当前批次任务已开放（开局即开放穹顶+水源；点亮后开放下一批）
	return MissionDispatch.is_location_batch_unlocked(Global.exploration_planet_id, location_id)


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
	if not MissionDispatch.is_location_batch_unlocked(Global.exploration_planet_id, _selected_location_id):
		if not MissionDispatch.can_preview_trial_run(Global.exploration_planet_id, _selected_location_id):
			return
	Global.runner_planet_id = Global.exploration_planet_id
	Global.runner_location_id = _selected_location_id
	var mission_id := _pending_detail_mission_id
	_pending_detail_mission_id = ""
	Global.runner_mission_id = mission_id
	Global.set_active_mission(Global.exploration_planet_id, _selected_location_id, mission_id)
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


func _location_display_name(location: Dictionary) -> String:
	var name_en := String(location.get("name_en", "")).strip_edges()
	if name_en != "":
		return name_en
	return String(location.get("name", "Outpost"))


func _show_location_showcase(location_id: String) -> void:
	var location := _get_location(location_id)
	if location.is_empty():
		return
	var cfg: Script = PlanetDatabase.get_runner_config(Global.exploration_planet_id)
	var model_path := ""
	if cfg.has_method("get_location_hearth_model"):
		model_path = String(cfg.get_location_hearth_model(location_id))
	var display_name := _location_display_name(location)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	$UI.add_child(root)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.016, 0.012, 0.0)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 760)
	panel.modulate.a = 0.0
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
	title.text = "%s · ACTIVATED" % display_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.15, 0.10, 0.04))
	title.add_theme_font_size_override("font_size", 28)
	title.modulate.a = 0.0
	box.add_child(title)

	var preview_host := Control.new()
	preview_host.custom_minimum_size = Vector2(0, 420)
	preview_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(preview_host)

	var reveal_view: OutpostLightRevealViewport = null
	if model_path != "":
		reveal_view = OutpostLightRevealViewport.new()
		reveal_view.set_anchors_preset(Control.PRESET_FULL_RECT)
		reveal_view.offset_left = 0.0
		reveal_view.offset_top = 0.0
		reveal_view.offset_right = 0.0
		reveal_view.offset_bottom = 0.0
		preview_host.add_child(reveal_view)
		reveal_view.setup(model_path)
	else:
		var cfg_preview := ""
		if cfg.has_method("get_location_preview_path"):
			cfg_preview = String(cfg.get_location_preview_path(location_id))
		if cfg_preview != "":
			var image := TextureRect.new()
			image.set_anchors_preset(Control.PRESET_FULL_RECT)
			image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			image.texture = load(cfg_preview) as Texture2D
			preview_host.add_child(image)

	var body := Label.new()
	body.text = "Delivery complete. The outpost is back online.\nExplore neighboring regions on the map."
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_color_override("font_color", Color(0.18, 0.13, 0.07))
	body.add_theme_font_size_override("font_size", 17)
	body.modulate.a = 0.0
	box.add_child(body)

	var close := Button.new()
	close.text = "CONTINUE EXPLORING"
	close.custom_minimum_size = Vector2(0, 56)
	close.add_theme_font_size_override("font_size", 20)
	close.modulate.a = 0.0
	_style_action_button(close, Color(0.86, 0.59, 0.27), Color(0.98, 0.82, 0.42))
	close.pressed.connect(root.queue_free)
	box.add_child(close)

	var intro := create_tween()
	intro.set_ease(Tween.EASE_OUT)
	intro.set_trans(Tween.TRANS_CUBIC)
	intro.tween_property(shade, "color:a", 0.82, 0.22)
	intro.parallel().tween_property(panel, "modulate:a", 1.0, 0.28)
	intro.parallel().tween_property(title, "modulate:a", 1.0, 0.32)
	if reveal_view != null:
		intro.tween_callback(func(): reveal_view.play_reveal(1.15))
	else:
		intro.tween_interval(0.08)
	intro.tween_property(body, "modulate:a", 1.0, 0.34).set_delay(0.72)
	intro.tween_property(close, "modulate:a", 1.0, 0.28).set_delay(0.88)

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
