extends Node3D

## 卡皮巴拉跑酷关卡编辑器：① 配置赛道 → ② 摆 setpiece，保存为 JSON
## 打开方式：在 Godot 中打开本场景 → F6 运行当前场景

const CapybaraTrackPathScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_track_path.gd")
const LevelCatalogScript := preload("res://assets/maps/route_levels/capybara_rush/level_catalog.gd")
const CapybaraLevelLayout := preload("res://assets/maps/route_levels/capybara_rush/level_editor/capybara_level_layout.gd")
const CapybaraCustomLevels := preload("res://assets/maps/route_levels/capybara_rush/level_editor/capybara_custom_levels.gd")
const CapybaraEditorVisual := preload("res://assets/maps/route_levels/capybara_rush/level_editor/capybara_editor_visual.gd")

const LANE_WIDTH := 1.08
const LANE_COUNT := 3
const ROAD_HALF_W := 2.05
const ROAD_THICKNESS := 0.18
const ROAD_SURFACE_Y := ROAD_THICKNESS * 0.5

const EDIT_MODE_TRACK := "track"
const EDIT_MODE_OBSTACLES := "obstacles"

const DRAG_DIST_PER_PX := 0.12
const DRAG_DIST_PER_PX_FINE := 0.035
const DRAG_LANE_THRESHOLD_PX := 48.0
const DRAG_DEADZONE_PX := 0.6

var _path: CapybaraTrackPath
var _visual := CapybaraEditorVisual.new()
var _theme_cfg: Dictionary = {}
var _level_cfg: Dictionary = {}
var _setpieces: Array = []
var _jump_challenges: Array = []
var _track_length := 288.0
var _cursor_d := 40.0
var _lane_index := 1
var _place_type := "stair_weave"
var _selected := -1
var _selected_jump := -1
var _dirty := false
var _edit_mode := EDIT_MODE_TRACK
var _cam_zoom := 1.25
var _cam_overview_frames := 0
var _dragging_marker := false
var _drag_index := -1
var _drag_lane_accum := 0.0
var _template_level_id := 1

var _world_environment: WorldEnvironment
var _track_root: Node3D
var _marker_root: Node3D
var _jump_root: Node3D
var _cursor_marker: MeshInstance3D
var _camera: Camera3D
var _status: Label
var _phase_hint: Label
var _mode_tabs: TabBar
var _track_panel: VBoxContainer
var _obstacle_panel: VBoxContainer
var _list: ItemList
var _jump_list: ItemList
var _custom_list: ItemList
var _dist_slider: HSlider
var _dist_spin: SpinBox
var _type_option: OptionButton
var _lane_option: OptionButton
var _theme_option: OptionButton
var _track_len_spin: SpinBox
var _run_speed_spin: SpinBox
var _cliffs_spin: SpinBox
var _max_rows_spin: SpinBox
var _level_name_edit: LineEdit
var _template_option: OptionButton
var _jump_spacing_spin: SpinBox
var _jump_pads_spin: SpinBox


func _ready() -> void:
	_build_ui()
	_setup_world()
	_reset_new_level(false)
	_set_edit_mode(EDIT_MODE_TRACK)
	_refresh_all()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			if mb.ctrl_pressed or Input.is_key_pressed(KEY_CTRL):
				_cam_zoom = clampf(_cam_zoom * 0.88, 0.55, 4.0)
				_update_camera()
			else:
				_set_cursor_d(_cursor_d + (8.0 if not Input.is_key_pressed(KEY_SHIFT) else 2.0))
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			if mb.ctrl_pressed or Input.is_key_pressed(KEY_CTRL):
				_cam_zoom = clampf(_cam_zoom * 1.14, 0.55, 4.0)
				_update_camera()
			else:
				_set_cursor_d(_cursor_d - (8.0 if not Input.is_key_pressed(KEY_SHIFT) else 2.0))
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if _edit_mode == EDIT_MODE_OBSTACLES:
				if _try_pick_marker(mb.position):
					_dragging_marker = true
					_drag_lane_accum = 0.0
					get_viewport().set_input_as_handled()
				elif _try_place_at_mouse(mb.position):
					get_viewport().set_input_as_handled()
			elif _try_set_cursor_at_mouse(mb.position):
				get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			if _dragging_marker:
				_setpieces = CapybaraLevelLayout.sort_setpieces(_setpieces)
				_refresh_markers()
				_refresh_list()
			_dragging_marker = false
			_drag_index = -1
			_drag_lane_accum = 0.0
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			if _edit_mode == EDIT_MODE_OBSTACLES and _try_delete_at_mouse(mb.position):
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _dragging_marker and _drag_index >= 0:
		var mm := event as InputEventMouseMotion
		_drag_marker_by_relative(mm.relative)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		match key.keycode:
			KEY_A, KEY_LEFT:
				_set_cursor_d(_cursor_d - (12.0 if not key.shift_pressed else 3.0))
			KEY_D, KEY_RIGHT:
				_set_cursor_d(_cursor_d + (12.0 if not key.shift_pressed else 3.0))
			KEY_Q:
				if _edit_mode == EDIT_MODE_OBSTACLES:
					_set_lane_index(maxi(_lane_index - 1, 0))
			KEY_E:
				if _edit_mode == EDIT_MODE_OBSTACLES:
					_set_lane_index(mini(_lane_index + 1, 2))
			KEY_TAB:
				if not key.ctrl_pressed and not key.alt_pressed:
					_set_edit_mode(EDIT_MODE_OBSTACLES if _edit_mode == EDIT_MODE_TRACK else EDIT_MODE_TRACK)
					get_viewport().set_input_as_handled()
			KEY_SPACE, KEY_ENTER:
				if _edit_mode == EDIT_MODE_OBSTACLES:
					_place_at_cursor()
			KEY_DELETE, KEY_BACKSPACE:
				if _edit_mode == EDIT_MODE_OBSTACLES:
					if _selected_jump >= 0:
						_delete_selected_jump()
					else:
						_delete_selected()
			KEY_S:
				if key.ctrl_pressed:
					_save_layout()
			KEY_P:
				if key.ctrl_pressed:
					_playtest_layout()
					get_viewport().set_input_as_handled()
			KEY_F:
				_frame_whole_track()
				get_viewport().set_input_as_handled()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
				if _edit_mode == EDIT_MODE_OBSTACLES:
					var idx := key.keycode - KEY_1
					if idx >= 0 and idx < CapybaraLevelLayout.PLACE_TYPES.size():
						_set_place_type(CapybaraLevelLayout.PLACE_TYPES[idx])


func _process(_delta: float) -> void:
	if _cam_overview_frames > 0:
		_cam_overview_frames -= 1
	else:
		_update_camera()
	_update_cursor_marker()


func _setup_world() -> void:
	_world_environment = WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.22, 0.28, 0.36)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.86, 0.95)
	environment.ambient_light_energy = 0.95
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	_world_environment.environment = environment
	add_child(_world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, 38, 0)
	sun.light_energy = 1.6
	sun.shadow_enabled = false
	add_child(sun)

	_track_root = Node3D.new()
	_track_root.name = "TrackRoot"
	add_child(_track_root)
	_marker_root = Node3D.new()
	_marker_root.name = "Markers"
	add_child(_marker_root)
	_jump_root = Node3D.new()
	_jump_root.name = "JumpMarkers"
	add_child(_jump_root)

	_camera = Camera3D.new()
	_camera.fov = 62.0
	_camera.near = 0.2
	_camera.far = 6000.0
	_camera.current = true
	_camera.h_offset = 3.0
	add_child(_camera)

	_cursor_marker = MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(1.0, 0.18, 1.4)
	var cmat := StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 1.0, 0.2, 0.9)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.9, 0.2)
	cmat.emission_energy_multiplier = 2.2
	cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cm.material = cmat
	_cursor_marker.mesh = cm
	add_child(_cursor_marker)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var panel := PanelContainer.new()
	panel.position = Vector2(12, 12)
	panel.custom_minimum_size = Vector2(420, 780)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.10, 0.14, 0.96)
	panel_style.border_color = Color(0.75, 0.88, 1.0, 0.85)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 12
	panel_style.content_margin_right = 12
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(396, 760)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(v)

	var title := Label.new()
	title.text = "卡皮巴拉关卡编辑器"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	v.add_child(title)

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	v.add_child(_status)

	_mode_tabs = TabBar.new()
	_mode_tabs.add_tab("① 赛道设置")
	_mode_tabs.add_tab("② 摆障碍")
	_mode_tabs.tab_changed.connect(func(i: int) -> void:
		_set_edit_mode(EDIT_MODE_TRACK if i == 0 else EDIT_MODE_OBSTACLES)
	)
	v.add_child(_mode_tabs)

	_phase_hint = Label.new()
	_phase_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phase_hint.add_theme_font_size_override("font_size", 14)
	v.add_child(_phase_hint)

	_track_panel = VBoxContainer.new()
	_track_panel.add_theme_constant_override("separation", 8)
	v.add_child(_track_panel)

	_obstacle_panel = VBoxContainer.new()
	_obstacle_panel.add_theme_constant_override("separation", 8)
	_obstacle_panel.visible = false
	v.add_child(_obstacle_panel)

	# —— 赛道设置 ——
	_track_panel.add_child(_make_label("关卡名称"))
	_level_name_edit = LineEdit.new()
	_level_name_edit.placeholder_text = "自定义关卡名"
	_track_panel.add_child(_level_name_edit)

	_track_panel.add_child(_make_label("主题"))
	_theme_option = OptionButton.new()
	for tid in CapybaraLevelLayout.THEME_IDS:
		_theme_option.add_item(tid)
	_theme_option.item_selected.connect(func(_i: int) -> void:
		_apply_theme_from_ui()
		_dirty = true
		_rebuild_track_mesh()
		_update_status()
	)
	_track_panel.add_child(_theme_option)

	var params := GridContainer.new()
	params.columns = 2
	params.add_theme_constant_override("h_separation", 8)
	params.add_theme_constant_override("v_separation", 6)
	_track_panel.add_child(params)
	params.add_child(_make_label("跑道长度"))
	_track_len_spin = _make_spin(120.0, 900.0, 288.0, "m")
	_track_len_spin.value_changed.connect(func(vv: float) -> void:
		_track_length = vv
		_dirty = true
		_rebuild_path()
	)
	params.add_child(_track_len_spin)
	params.add_child(_make_label("跑速"))
	_run_speed_spin = _make_spin(6.0, 16.0, 12.0, "")
	_run_speed_spin.step = 0.5
	params.add_child(_run_speed_spin)
	params.add_child(_make_label("断崖数"))
	_cliffs_spin = _make_spin(0.0, 2.0, 0.0, "")
	_cliffs_spin.step = 1.0
	params.add_child(_cliffs_spin)
	params.add_child(_make_label("阶梯最高层"))
	_max_rows_spin = _make_spin(1.0, 6.0, 3.0, "")
	_max_rows_spin.step = 1.0
	params.add_child(_max_rows_spin)

	_track_panel.add_child(_make_label("从官方关卡载入模板"))
	_template_option = OptionButton.new()
	for i in range(1, LevelCatalogScript.LEVEL_COUNT + 1):
		var cfg := LevelCatalogScript.load_level(i)
		_template_option.add_item("Lv.%02d %s" % [i, String(cfg.get("name", ""))])
	_template_option.item_selected.connect(func(i: int) -> void:
		_template_level_id = i + 1
	)
	_track_panel.add_child(_template_option)
	_track_panel.add_child(_make_button("载入模板（覆盖当前）", _load_template_level))

	var track_dist_row := HBoxContainer.new()
	_track_panel.add_child(_make_label("游标距离"))
	_track_panel.add_child(track_dist_row)
	var track_dist_spin := SpinBox.new()
	track_dist_spin.min_value = 0.0
	track_dist_spin.max_value = 900.0
	track_dist_spin.step = 1.0
	track_dist_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	track_dist_spin.value_changed.connect(func(vv: float) -> void:
		_set_cursor_d(vv, false)
	)
	track_dist_row.add_child(track_dist_spin)
	_track_panel.set_meta("track_dist_spin", track_dist_spin)

	_track_panel.add_child(_make_button("赛道好了 → 去摆障碍", func() -> void:
		_set_edit_mode(EDIT_MODE_OBSTACLES)
	))

	# —— 摆障碍 ——
	_obstacle_panel.add_child(_make_label("障碍类型（1-9 快捷键）"))
	_type_option = OptionButton.new()
	for t in CapybaraLevelLayout.PLACE_TYPES:
		_type_option.add_item(CapybaraLevelLayout.place_type_label(t))
	_type_option.item_selected.connect(func(i: int) -> void:
		_set_place_type(CapybaraLevelLayout.PLACE_TYPES[i])
	)
	_obstacle_panel.add_child(_type_option)

	_obstacle_panel.add_child(_make_label("车道（Q/E）"))
	_lane_option = OptionButton.new()
	_lane_option.add_item("左道 (0)", 0)
	_lane_option.add_item("中道 (1)", 1)
	_lane_option.add_item("右道 (2)", 2)
	_lane_option.select(1)
	_lane_option.item_selected.connect(func(i: int) -> void:
		_set_lane_index(i)
	)
	_obstacle_panel.add_child(_lane_option)

	_obstacle_panel.add_child(_make_label("当前距离"))
	var dist_row := HBoxContainer.new()
	_obstacle_panel.add_child(dist_row)
	_dist_spin = SpinBox.new()
	_dist_spin.min_value = 0.0
	_dist_spin.max_value = 900.0
	_dist_spin.step = 1.0
	_dist_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dist_spin.value_changed.connect(func(vv: float) -> void:
		_set_cursor_d(vv, false)
		var ts: SpinBox = _track_panel.get_meta("track_dist_spin")
		if ts:
			ts.set_value_no_signal(vv)
	)
	dist_row.add_child(_dist_spin)
	_dist_slider = HSlider.new()
	_dist_slider.min_value = 0.0
	_dist_slider.max_value = 288.0
	_dist_slider.step = 1.0
	_dist_slider.value_changed.connect(func(vv: float) -> void:
		_set_cursor_d(vv, false)
	)
	_obstacle_panel.add_child(_dist_slider)

	var btn_row := HBoxContainer.new()
	btn_row.add_child(_make_button("放置 (Space)", _place_at_cursor))
	btn_row.add_child(_make_button("删除选中", _delete_selected))
	_obstacle_panel.add_child(btn_row)

	_obstacle_panel.add_child(_make_label("水池三连跳"))
	var jump_row := HBoxContainer.new()
	_jump_spacing_spin = _make_spin(6.0, 14.0, 8.8, "间距")
	_jump_pads_spin = _make_spin(2.0, 5.0, 3.0, "块数")
	_jump_pads_spin.step = 1.0
	jump_row.add_child(_jump_spacing_spin)
	jump_row.add_child(_jump_pads_spin)
	_obstacle_panel.add_child(jump_row)
	var jump_btns := HBoxContainer.new()
	jump_btns.add_child(_make_button("添加三连跳", _add_jump_at_cursor))
	jump_btns.add_child(_make_button("删三连跳", _delete_selected_jump))
	_obstacle_panel.add_child(jump_btns)
	_jump_list = ItemList.new()
	_jump_list.custom_minimum_size = Vector2(0, 72)
	_jump_list.item_selected.connect(func(i: int) -> void:
		_selected_jump = i
		_selected = -1
		if i >= 0 and i < _jump_challenges.size():
			var j: Dictionary = _jump_challenges[i]
			_set_cursor_d(float(j.get("dist", 0.0)))
			_set_lane_index(int(j.get("lane", 1)))
		_refresh_markers()
		_refresh_list()
	)
	_obstacle_panel.add_child(_jump_list)

	_obstacle_panel.add_child(_make_label("障碍列表"))
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(0, 140)
	_list.item_selected.connect(func(i: int) -> void:
		_selected = i
		_selected_jump = -1
		if i >= 0 and i < _setpieces.size():
			var it: Dictionary = _setpieces[i]
			_set_cursor_d(float(it.get("dist", 0.0)))
			_set_lane_index(int(it.get("lane", 1)))
			var t := String(it.get("type", ""))
			var ti := CapybaraLevelLayout.PLACE_TYPES.find(t)
			if ti >= 0:
				_set_place_type(t)
				_type_option.select(ti)
		_refresh_markers()
	)
	_obstacle_panel.add_child(_list)

	_obstacle_panel.add_child(_make_button("← 返回赛道设置", func() -> void:
		_set_edit_mode(EDIT_MODE_TRACK)
	))

	var btn_row2 := HBoxContainer.new()
	btn_row2.add_child(_make_button("▶ 试玩", _playtest_layout))
	btn_row2.add_child(_make_button("保存为关卡", _save_layout))
	btn_row2.add_child(_make_button("新建", func() -> void: _reset_new_level(true)))
	v.add_child(btn_row2)

	v.add_child(_make_label("已保存自定义关卡"))
	_custom_list = ItemList.new()
	_custom_list.custom_minimum_size = Vector2(0, 90)
	_custom_list.item_selected.connect(_load_custom_by_list_index)
	v.add_child(_custom_list)

	var help := Label.new()
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.add_theme_font_size_override("font_size", 13)
	help.modulate = Color(0.95, 0.95, 0.8)
	help.text = "① 设跑道 → ② 摆障碍 → Ctrl+P 试玩 · Ctrl+S 保存 · Tab 切换 · F 俯视"
	v.add_child(help)


func _make_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0))
	return l


func _make_spin(min_v: float, max_v: float, val: float, prefix: String) -> SpinBox:
	var s := SpinBox.new()
	s.min_value = min_v
	s.max_value = max_v
	s.value = val
	s.step = 0.5
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if prefix != "":
		s.prefix = prefix
	return s


func _make_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 36)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(cb)
	return b


func _set_edit_mode(mode: String) -> void:
	_edit_mode = mode
	var is_track := mode == EDIT_MODE_TRACK
	_track_panel.visible = is_track
	_obstacle_panel.visible = not is_track
	if _mode_tabs:
		_mode_tabs.set_current_tab(0 if is_track else 1)
	_marker_root.visible = not is_track
	_jump_root.visible = not is_track
	if _phase_hint:
		if is_track:
			_phase_hint.text = "① 设置跑道长度、主题、断崖。弯道由程序自动生成。"
			_phase_hint.add_theme_color_override("font_color", Color(1.0, 0.95, 0.45))
		else:
			_phase_hint.text = "② 在弯道上放置 setpiece。左键放置/拖拽，右键删除。"
			_phase_hint.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	_dragging_marker = false
	_drag_index = -1
	_update_status()


func _reset_new_level(flash: bool) -> void:
	_level_cfg = CapybaraLevelLayout.default_level_cfg()
	_setpieces.clear()
	_jump_challenges.clear()
	_track_length = float(_level_cfg.get("track_length", 288.0))
	_selected = -1
	_selected_jump = -1
	_dirty = false
	_sync_ui_from_cfg()
	_rebuild_path()
	if flash:
		_flash_status("已新建空白关卡")


func _sync_ui_from_cfg() -> void:
	if _level_name_edit:
		_level_name_edit.text = String(_level_cfg.get("name", "新关卡"))
	if _track_len_spin:
		_track_len_spin.set_value_no_signal(_track_length)
	if _run_speed_spin:
		_run_speed_spin.set_value_no_signal(float(_level_cfg.get("run_speed", 12.0)))
	if _cliffs_spin:
		_cliffs_spin.set_value_no_signal(float(_level_cfg.get("cliffs", 0)))
	if _max_rows_spin:
		_max_rows_spin.set_value_no_signal(float(_level_cfg.get("max_stair_rows", 3)))
	var theme_id := String(_level_cfg.get("theme_id", "lake_clear"))
	for i in _theme_option.item_count:
		if _theme_option.get_item_text(i) == theme_id:
			_theme_option.select(i)
			break
	_apply_theme_from_ui()
	_setpieces = CapybaraLevelLayout.sort_setpieces(_level_cfg.get("placed_setpieces", []))
	var jumps: Array = _level_cfg.get("jump_challenges", [])
	_jump_challenges = CapybaraLevelLayout.sort_jump_challenges(jumps if typeof(jumps) == TYPE_ARRAY else [])
	_refresh_custom_list()


func _apply_theme_from_ui() -> void:
	var theme_id := _theme_option.get_item_text(_theme_option.selected)
	_theme_cfg = LevelCatalogScript.load_theme(theme_id)
	if _world_environment and _world_environment.environment:
		_world_environment.environment.background_color = LevelCatalogScript.color3(
			_theme_cfg.get("sky_color"), _world_environment.environment.background_color
		)


func _collect_level_cfg() -> Dictionary:
	var cfg := _level_cfg.duplicate(true)
	cfg["name"] = _level_name_edit.text.strip_edges() if _level_name_edit else "新关卡"
	if cfg["name"].is_empty():
		cfg["name"] = "新关卡"
	cfg["theme_id"] = _theme_option.get_item_text(_theme_option.selected)
	cfg["track_length"] = _track_length
	cfg["run_speed"] = float(_run_speed_spin.value)
	cfg["cliffs"] = int(_cliffs_spin.value)
	cfg["max_stair_rows"] = int(_max_rows_spin.value)
	cfg["hazard_pattern"] = "manual"
	cfg["placed_setpieces"] = CapybaraLevelLayout.sort_setpieces(_setpieces)
	cfg["jump_challenges"] = CapybaraLevelLayout.sort_jump_challenges(_jump_challenges)
	return cfg


func _rebuild_path() -> void:
	_path = CapybaraTrackPathScript.new()
	_path.build_winding(_track_length)
	if _dist_slider:
		_dist_slider.max_value = maxf(_path.length, 40.0)
	if _dist_spin:
		_dist_spin.max_value = _path.length
	var ts: SpinBox = _track_panel.get_meta("track_dist_spin") if _track_panel else null
	if ts:
		ts.max_value = _path.length
	_rebuild_track_mesh()
	_refresh_markers()
	_update_cursor_marker()
	_update_camera()
	_update_status()


func _rebuild_track_mesh() -> void:
	if _track_root == null:
		return
	for c in _track_root.get_children():
		c.queue_free()
	if _path == null:
		return
	var road := MeshInstance3D.new()
	road.mesh = _path.build_road_mesh(ROAD_HALF_W, ROAD_THICKNESS, _planned_gaps())
	var mat := StandardMaterial3D.new()
	mat.albedo_color = LevelCatalogScript.color3(_theme_cfg.get("road_color"), Color(0.86, 0.82, 0.94))
	mat.roughness = 0.85
	road.material_override = mat
	_track_root.add_child(road)

	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(120.0, _path.length + 60.0)
	water.mesh = plane
	var wmat := StandardMaterial3D.new()
	wmat.albedo_color = LevelCatalogScript.color3(_theme_cfg.get("water_color"), Color(0.42, 0.62, 0.82))
	wmat.roughness = 0.2
	water.material_override = wmat
	water.position = Vector3(0.0, -0.75, _path.length * 0.45)
	water.rotation_degrees.x = -90.0
	_track_root.add_child(water)


func _planned_gaps() -> Array:
	var gaps: Array = []
	for j in _jump_challenges:
		if typeof(j) != TYPE_DICTIONARY:
			continue
		var start := float(j.get("dist", 0.0))
		var spacing := float(j.get("spacing", 8.8))
		var count := int(j.get("pad_count", 3))
		var half_len := float(j.get("pad_half_len", 1.6))
		var run := spacing * maxf(float(count - 1), 0.0) + half_len * 2.0 + 4.0
		gaps.append({"dist0": start, "dist1": start + run})
	return gaps


func _sample_path(distance: float) -> Dictionary:
	if _path == null:
		return {"pos": Vector3(0, 0, distance), "yaw": 0.0, "forward": Vector3(0, 0, 1), "right": Vector3(1, 0, 0)}
	return _path.frame_at(distance)


func _world_on_path(distance: float, lane: int) -> Vector3:
	var f := _sample_path(distance)
	var lat := CapybaraEditorVisual.lane_to_x(lane)
	var pos: Vector3 = f["pos"] + (f["right"] as Vector3) * lat
	pos.y = ROAD_SURFACE_Y
	return pos


func _refresh_all() -> void:
	_refresh_markers()
	_refresh_list()
	_refresh_custom_list()
	_update_status()
	_update_cursor_marker()
	_update_camera()


func _refresh_markers() -> void:
	if _marker_root == null:
		return
	for c in _marker_root.get_children():
		c.queue_free()
	for c in _jump_root.get_children():
		c.queue_free()
	for i in _setpieces.size():
		var it: Dictionary = _setpieces[i]
		var node := _visual.build_setpiece_marker(it, i == _selected)
		var dist := float(it.get("dist", 0.0))
		var lane := int(it.get("lane", 1))
		var sample := _sample_path(dist)
		var pos: Vector3 = sample["pos"]
		if CapybaraEditorVisual.uses_lane(String(it.get("type", ""))):
			pos += (sample["right"] as Vector3) * CapybaraEditorVisual.lane_to_x(lane)
		pos.y = ROAD_SURFACE_Y
		node.position = pos
		node.rotation.y = float(sample["yaw"])
		node.set_meta("item_index", i)
		_marker_root.add_child(node)
	for i in _jump_challenges.size():
		var j: Dictionary = _jump_challenges[i]
		var item := {
			"type": "jump_challenge",
			"dist": float(j.get("dist", 0.0)),
			"lane": int(j.get("lane", 1)),
		}
		var node := _visual.build_setpiece_marker(item, i == _selected_jump)
		var sample := _sample_path(float(j.get("dist", 0.0)))
		node.position = sample["pos"] as Vector3
		node.position.y = ROAD_SURFACE_Y
		node.position += (sample["right"] as Vector3) * CapybaraEditorVisual.lane_to_x(int(j.get("lane", 1)))
		node.rotation.y = float(sample["yaw"])
		_jump_root.add_child(node)


func _refresh_list() -> void:
	if _list:
		_list.clear()
		for i in _setpieces.size():
			var it: Dictionary = _setpieces[i]
			_list.add_item("%02d  d=%.0f  %s  lane=%d" % [
				i,
				float(it.get("dist", 0.0)),
				CapybaraLevelLayout.place_type_label(String(it.get("type", "?"))),
				int(it.get("lane", 1)),
			])
		if _selected >= 0 and _selected < _setpieces.size():
			_list.select(_selected)
	if _jump_list:
		_jump_list.clear()
		for i in _jump_challenges.size():
			var j: Dictionary = _jump_challenges[i]
			_jump_list.add_item("%02d  d=%.0f  间距%.1f  %d块  lane=%d" % [
				i,
				float(j.get("dist", 0.0)),
				float(j.get("spacing", 8.8)),
				int(j.get("pad_count", 3)),
				int(j.get("lane", 1)),
			])
		if _selected_jump >= 0 and _selected_jump < _jump_challenges.size():
			_jump_list.select(_selected_jump)


func _refresh_custom_list() -> void:
	if _custom_list == null:
		return
	_custom_list.clear()
	for level in CapybaraCustomLevels.list_levels():
		_custom_list.add_item("%s · %s · %.0fm · %d障碍" % [
			String(level.get("name", "?")),
			String(level.get("id", "")),
			float(level.get("track_length", 0.0)),
			int(level.get("setpiece_count", 0)),
		])
		_custom_list.set_item_metadata(_custom_list.item_count - 1, String(level.get("id", "")))


func _set_cursor_d(d: float, sync_controls: bool = true) -> void:
	var max_d := _path.length if _path else _track_length
	_cursor_d = clampf(d, 0.0, maxf(max_d, 1.0))
	if sync_controls:
		if _dist_slider:
			_dist_slider.set_value_no_signal(_cursor_d)
		if _dist_spin:
			_dist_spin.set_value_no_signal(_cursor_d)
	var ts: SpinBox = _track_panel.get_meta("track_dist_spin") if _track_panel else null
	if ts and absf(ts.value - _cursor_d) > 0.01:
		ts.set_value_no_signal(_cursor_d)
	_update_cursor_marker()
	_update_status()


func _set_lane_index(idx: int) -> void:
	_lane_index = clampi(idx, 0, 2)
	if _lane_option:
		_lane_option.select(_lane_index)
	_update_cursor_marker()
	_update_status()


func _set_place_type(t: String) -> void:
	_place_type = t
	_update_status()


func _update_cursor_marker() -> void:
	if _cursor_marker == null or _path == null:
		return
	var sample := _sample_path(_cursor_d)
	var pos := _world_on_path(_cursor_d, _lane_index)
	_cursor_marker.global_position = pos + Vector3(0.0, 0.1, 0.0)
	_cursor_marker.rotation.y = float(sample["yaw"])


func _update_camera() -> void:
	if _camera == null or _path == null:
		return
	var sample := _sample_path(_cursor_d)
	var pos: Vector3 = sample["pos"]
	var forward: Vector3 = sample["forward"]
	var right: Vector3 = sample["right"]
	var back := (42.0 if _edit_mode == EDIT_MODE_TRACK else 28.0) * _cam_zoom
	var up := (32.0 if _edit_mode == EDIT_MODE_TRACK else 20.0) * _cam_zoom
	var look_ahead := 40.0 * sqrt(_cam_zoom)
	_camera.global_position = pos - forward * back + Vector3(0.0, up, 0.0) + right * 2.0
	_camera.look_at(pos + forward * look_ahead + Vector3(0.0, 0.15, 0.0), Vector3.UP)


func _frame_whole_track() -> void:
	if _camera == null or _path == null:
		return
	var mid := _sample_path(_path.length * 0.5)
	var height := clampf(_path.length * 0.42, 36.0, 220.0)
	_cam_zoom = clampf(height / 32.0, 0.8, 4.0)
	_camera.global_position = (mid["pos"] as Vector3) + Vector3(0.0, height, 0.0)
	_camera.look_at(mid["pos"], Vector3.UP)
	_cam_overview_frames = 90
	_flash_status("俯视整轨 · Ctrl+滚轮缩放")


func _update_status() -> void:
	if _status == null:
		return
	var flag := " *" if _dirty else ""
	var phase := "赛道" if _edit_mode == EDIT_MODE_TRACK else "障碍"
	_status.text = "[%s]%s d=%.0f/%.0f · 障碍%d · 三连跳%d · 下次保存 %s\n滚轮/A·D · Tab · Ctrl+P试玩 · Ctrl+S保存 · F俯视" % [
		phase,
		flag,
		_cursor_d,
		_path.length if _path else _track_length,
		_setpieces.size(),
		_jump_challenges.size(),
		CapybaraCustomLevels.format_name(CapybaraCustomLevels.next_sequence()),
	]


func _place_at_cursor() -> void:
	if _edit_mode != EDIT_MODE_OBSTACLES:
		return
	var item := {
		"type": _place_type,
		"dist": snappedf(_cursor_d, 0.5),
	}
	if CapybaraEditorVisual.uses_lane(_place_type):
		item["lane"] = _lane_index
	_setpieces.append(CapybaraLevelLayout.normalize_setpiece(item))
	_setpieces = CapybaraLevelLayout.sort_setpieces(_setpieces)
	_dirty = true
	_selected = _setpieces.size() - 1
	_selected_jump = -1
	_rebuild_track_mesh()
	_refresh_markers()
	_refresh_list()
	_update_status()


func _add_jump_at_cursor() -> void:
	var item := CapybaraLevelLayout.normalize_jump_challenge({
		"dist": snappedf(_cursor_d, 0.5),
		"spacing": float(_jump_spacing_spin.value),
		"pad_count": int(_jump_pads_spin.value),
		"lane": _lane_index,
	})
	_jump_challenges.append(item)
	_jump_challenges = CapybaraLevelLayout.sort_jump_challenges(_jump_challenges)
	_dirty = true
	_selected_jump = _jump_challenges.size() - 1
	_selected = -1
	_rebuild_track_mesh()
	_refresh_markers()
	_refresh_list()
	_flash_status("已添加水池三连跳 @ %.0fm" % float(item.get("dist", 0.0)))


func _delete_selected() -> void:
	if _selected < 0 or _selected >= _setpieces.size():
		return
	_setpieces.remove_at(_selected)
	_selected = mini(_selected, _setpieces.size() - 1)
	_dirty = true
	_rebuild_track_mesh()
	_refresh_markers()
	_refresh_list()
	_update_status()


func _delete_selected_jump() -> void:
	if _selected_jump < 0 or _selected_jump >= _jump_challenges.size():
		return
	_jump_challenges.remove_at(_selected_jump)
	_selected_jump = mini(_selected_jump, _jump_challenges.size() - 1)
	_dirty = true
	_rebuild_track_mesh()
	_refresh_markers()
	_refresh_list()
	_update_status()


func _save_layout() -> void:
	var cfg := _collect_level_cfg()
	var entry := CapybaraCustomLevels.create_level(cfg)
	_dirty = entry.is_empty()
	_refresh_custom_list()
	_update_status()
	if not entry.is_empty():
		_flash_status("已保存：%s（%s）" % [String(entry.get("name", "")), String(entry.get("id", ""))])
	else:
		_flash_status("保存失败")


func _playtest_layout() -> void:
	var cfg := _collect_level_cfg()
	var entry := CapybaraCustomLevels.save_playtest(cfg)
	if entry.is_empty():
		_flash_status("试玩失败：无法写入草稿")
		return
	var ui_script := load("res://assets/maps/route_levels/capybara_rush/capybara_ui.gd")
	if ui_script:
		ui_script.pending_custom_level_id = CapybaraCustomLevels.PLAYTEST_ID
		ui_script.pending_character_id = "capybara"
		ui_script.editor_return_scene = CapybaraCustomLevels.EDITOR_SCENE
	_flash_status("正在进入试玩…")
	Global.change_game_scene(CapybaraCustomLevels.GAME_SCENE)


func _load_template_level() -> void:
	var cfg := LevelCatalogScript.load_level(_template_level_id)
	if cfg.is_empty():
		_flash_status("模板载入失败")
		return
	cfg["hazard_pattern"] = "manual"
	cfg["placed_setpieces"] = []
	cfg["name"] = String(cfg.get("name", "")) + "（编辑副本）"
	_level_cfg = cfg
	_track_length = float(cfg.get("track_length", 288.0))
	_setpieces.clear()
	_jump_challenges = CapybaraLevelLayout.sort_jump_challenges(cfg.get("jump_challenges", []))
	_selected = -1
	_selected_jump = -1
	_dirty = true
	_sync_ui_from_cfg()
	_rebuild_path()
	_flash_status("已载入 Lv.%02d 模板（障碍需手动摆放）" % _template_level_id)


func _load_custom_by_list_index(index: int) -> void:
	if _custom_list == null or index < 0 or index >= _custom_list.item_count:
		return
	var level_id := String(_custom_list.get_item_metadata(index))
	var cfg := CapybaraCustomLevels.load_level_config(level_id)
	if cfg.is_empty():
		_flash_status("载入失败")
		return
	_level_cfg = cfg
	_track_length = float(cfg.get("track_length", 288.0))
	_setpieces = CapybaraLevelLayout.sort_setpieces(cfg.get("placed_setpieces", []))
	_jump_challenges = CapybaraLevelLayout.sort_jump_challenges(cfg.get("jump_challenges", []))
	_selected = -1
	_selected_jump = -1
	_dirty = false
	_sync_ui_from_cfg()
	_rebuild_path()
	_flash_status("已载入 %s（再保存会新建下一关）" % String(cfg.get("name", level_id)))


func _flash_status(msg: String) -> void:
	if _status:
		_status.text = msg + "\n" + _status.text


func _ray_from_mouse(screen_pos: Vector2) -> Dictionary:
	var from := _camera.project_ray_origin(screen_pos)
	var dir := _camera.project_ray_normal(screen_pos)
	if absf(dir.y) < 0.0001:
		return {}
	var t := (ROAD_SURFACE_Y - from.y) / dir.y
	if t < 0.0:
		return {}
	return {"pos": from + dir * t}


func _nearest_distance_to_point(world: Vector3) -> float:
	if _path == null:
		return _cursor_d
	var best_d := 0.0
	var best_score := INF
	var d := 0.0
	while d <= _path.length:
		var p: Vector3 = _path.frame_at(d)["pos"]
		p.y = ROAD_SURFACE_Y
		var score := p.distance_squared_to(world)
		if score < best_score:
			best_score = score
			best_d = d
		d += 2.0
	return best_d


func _try_set_cursor_at_mouse(screen_pos: Vector2) -> bool:
	var hit := _ray_from_mouse(screen_pos)
	if hit.is_empty():
		return false
	var world: Vector3 = hit["pos"]
	var d := _nearest_distance_to_point(world)
	var on_path: Vector3 = _sample_path(d)["pos"]
	if Vector2(world.x, world.z).distance_to(Vector2(on_path.x, on_path.z)) > 12.0:
		return false
	_set_cursor_d(d)
	return true


func _try_place_at_mouse(screen_pos: Vector2) -> bool:
	if not _try_set_cursor_at_mouse(screen_pos):
		return false
	_place_at_cursor()
	return true


func _try_pick_marker(screen_pos: Vector2) -> bool:
	var hit := _ray_from_mouse(screen_pos)
	if hit.is_empty():
		return false
	var world: Vector3 = hit["pos"]
	var best := -1
	var best_score := 2.5 * 2.5
	for i in _setpieces.size():
		var it: Dictionary = _setpieces[i]
		var lane := int(it.get("lane", 1))
		var p := _world_on_path(float(it.get("dist", 0.0)), lane)
		var sample := _sample_path(float(it.get("dist", 0.0)))
		p = sample["pos"] + (sample["right"] as Vector3) * CapybaraEditorVisual.lane_to_x(lane)
		p.y = ROAD_SURFACE_Y
		if p.distance_squared_to(world) < best_score:
			best_score = p.distance_squared_to(world)
			best = i
	if best < 0:
		return false
	_selected = best
	_selected_jump = -1
	_drag_index = best
	var it2: Dictionary = _setpieces[best]
	_set_cursor_d(float(it2.get("dist", 0.0)))
	_set_lane_index(int(it2.get("lane", 1)))
	_refresh_markers()
	_refresh_list()
	return true


func _drag_marker_by_relative(relative: Vector2) -> void:
	if _drag_index < 0 or _drag_index >= _setpieces.size():
		return
	if relative.length() < DRAG_DEADZONE_PX:
		return
	var it: Dictionary = _setpieces[_drag_index]
	var d := float(it.get("dist", 0.0))
	var lane := int(it.get("lane", 1))
	var sample := _sample_path(d)
	var origin: Vector3 = sample["pos"]
	var forward: Vector3 = sample["forward"]
	var right: Vector3 = sample["right"]
	var sp0 := _camera.unproject_position(origin)
	var sp_f := _camera.unproject_position(origin + forward * 6.0)
	var sp_r := _camera.unproject_position(origin + right * LANE_WIDTH)
	var screen_fwd := (sp_f - sp0).normalized() if (sp_f - sp0).length_squared() > 0.0001 else Vector2(0, -1)
	var screen_right := (sp_r - sp0).normalized() if (sp_r - sp0).length_squared() > 0.0001 else Vector2(1, 0)
	var sens := DRAG_DIST_PER_PX_FINE if Input.is_key_pressed(KEY_SHIFT) else DRAG_DIST_PER_PX
	d = clampf(d + relative.dot(screen_fwd) * sens, 0.0, _path.length)
	_drag_lane_accum += relative.dot(screen_right)
	if _drag_lane_accum >= DRAG_LANE_THRESHOLD_PX:
		lane = mini(lane + 1, 2)
		_drag_lane_accum = 0.0
	elif _drag_lane_accum <= -DRAG_LANE_THRESHOLD_PX:
		lane = maxi(lane - 1, 0)
		_drag_lane_accum = 0.0
	it["dist"] = snappedf(d, 0.5)
	it["lane"] = lane
	_setpieces[_drag_index] = CapybaraLevelLayout.normalize_setpiece(it)
	_dirty = true
	_set_cursor_d(d)
	_set_lane_index(lane)
	_rebuild_track_mesh()
	_refresh_markers()
	_refresh_list()


func _try_delete_at_mouse(screen_pos: Vector2) -> bool:
	if not _try_pick_marker(screen_pos):
		return false
	_delete_selected()
	return true
