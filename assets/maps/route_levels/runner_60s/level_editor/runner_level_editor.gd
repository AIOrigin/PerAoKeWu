extends Node3D

## 跑酷关卡编辑器：① 拼接赛道基准 → ② 在基准上摆障碍，保存为 JSON
## 打开方式：在 Godot 中打开本场景 → F6 运行当前场景

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const ObstacleLayout = preload("res://assets/maps/route_levels/runner_60s/obstacle_layout.gd")
const CustomLevels = preload("res://assets/maps/route_levels/runner_60s/custom_levels.gd")
const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const ObstacleVisualFactory = preload("res://assets/maps/route_levels/runner_60s/level_editor/obstacle_visual_factory.gd")
const EditorRoadPreview = preload("res://assets/maps/route_levels/runner_60s/level_editor/editor_road_preview.gd")

const LANE_WIDTH := 4.0
const LANES := [-1, 0, 1]
const GROUND_Y := 0.85
const PLACE_TYPES: Array[String] = [
	"jump", "slide", "orb", "train", "train_moving",
	"block_left", "block_right", "ramp", "main_block",
	"turn_left", "turn_right",
]

var LevelConfig: Script
var _visual_factory: ObstacleVisualFactory = ObstacleVisualFactory.new()
var _road_preview: EditorRoadPreview = EditorRoadPreview.new()
var _road_style_id := "holographic"
var _world_environment: WorldEnvironment
var _planet_id := "glass_desert"
var _path_samples: Array[Dictionary] = []
var _path_length := 1200.0
var _track_length := 1200.0
var _cursor_d := 40.0
var _lane_index := 1
var _place_type := "jump"
var _items: Array = []
var _side_zones: Array = []
var _sand_zones: Array = []
var _track_segments: Array = []
var _junctions: Array = []
var _selected := -1
var _selected_side := -1
var _selected_sand := -1
var _selected_seg := -1
var _selected_fork := -1
var _dirty := false

var _track_root: Node3D
var _marker_root: Node3D
var _side_root: Node3D
var _sand_root: Node3D
var _fork_root: Node3D
var _cursor_marker: MeshInstance3D
var _camera: Camera3D
var _status: Label
var _list: ItemList
var _side_list: ItemList
var _sand_list: ItemList
var _seg_list: ItemList
var _fork_list: ItemList
var _side_length_spin: SpinBox
var _side_side_option: OptionButton
var _sand_length_spin: SpinBox
var _sand_lanes_option: OptionButton
var _sand_lane_option: OptionButton
var _sand_dps_spin: SpinBox
var _seg_len_spin: SpinBox
var _seg_turn_spin: SpinBox
var _fork_len_spin: SpinBox
var _fork_spread_spin: SpinBox
var _dist_slider: HSlider
var _dist_spin: SpinBox
var _type_option: OptionButton
var _lane_option: OptionButton
var _planet_option: OptionButton
var _road_style_option: OptionButton
var _dragging_marker := false
var _drag_index := -1
var _drag_lane_accum := 0.0
var _ui_canvas_root: Control
var _end_add_btn: Button
var _end_add_marker: MeshInstance3D
var _piece_picker: PopupPanel
var _next_seg_len_spin: SpinBox

## 拖拽：按屏幕相对位移推进距离（避免透视下绝对射线过灵敏）
const DRAG_DIST_PER_PX := 0.12
const DRAG_DIST_PER_PX_FINE := 0.035
const DRAG_LANE_THRESHOLD_PX := 52.0
const DRAG_DEADZONE_PX := 0.6
const DEFAULT_SIDE_LENGTH := 55.0
const DEFAULT_SIDE_OFFSET := 7.2
const DEFAULT_SIDE_ENTRY := 10.0
const DEFAULT_SAND_LENGTH := 42.0
const DEFAULT_SAND_DPS := 9.0
const DEFAULT_FORK_LENGTH := 100.0
const DEFAULT_FORK_SPREAD := 20.0
const DEFAULT_SEG_LENGTH := 80.0
const DEFAULT_Y_FORK_BRANCH := 55.0
const DEFAULT_Y_FORK_ANGLE_DEG := 45.0

const EDIT_MODE_TRACK := "track"
const EDIT_MODE_OBSTACLES := "obstacles"

var _edit_mode := EDIT_MODE_TRACK
var _mode_tabs: TabBar
var _track_panel: VBoxContainer
var _obstacle_panel: VBoxContainer
var _phase_hint: Label


func _ready() -> void:
	_build_ui()
	_setup_world()
	_planet_id = "glass_desert"
	_load_planet(_planet_id)
	# 新建编辑：从一条初始直线开始，不带星球默认障碍
	_reset_to_initial_straight(false)
	_dirty = false
	_set_edit_mode(EDIT_MODE_TRACK)
	_refresh_all()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_set_cursor_d(_cursor_d + (8.0 if not Input.is_key_pressed(KEY_SHIFT) else 2.0))
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
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
			elif _edit_mode == EDIT_MODE_TRACK:
				# 拼赛道阶段：点地只移动游标，不摆障碍
				if _try_set_cursor_at_mouse(mb.position):
					get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			if _dragging_marker:
				_items = ObstacleLayout.sort_items(_items)
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
				else:
					_open_piece_picker()
			KEY_DELETE, KEY_BACKSPACE:
				if _edit_mode == EDIT_MODE_OBSTACLES:
					_delete_selected()
				elif _selected_seg >= 0:
					_delete_selected_seg()
				elif _selected_fork >= 0:
					_delete_selected_fork()
			KEY_S:
				if key.ctrl_pressed:
					_save_layout()
			KEY_P:
				if key.ctrl_pressed:
					_playtest_layout()
					get_viewport().set_input_as_handled()
			KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
				if _edit_mode == EDIT_MODE_OBSTACLES:
					var idx := key.keycode - KEY_1
					if idx >= 0 and idx < PLACE_TYPES.size():
						_set_place_type(PLACE_TYPES[idx])


func _process(_delta: float) -> void:
	_update_camera()
	_update_cursor_marker()
	_update_end_add_affordance()


func _setup_world() -> void:
	_world_environment = WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	# 编辑器需要高对比：亮背景 + 强环境光，避免赛道「融进黑底」
	environment.background_color = Color(0.42, 0.48, 0.55)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.92, 0.95, 1.0)
	environment.ambient_light_energy = 1.35
	environment.glow_enabled = false
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	_world_environment.environment = environment
	add_child(_world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 35, 0)
	sun.light_energy = 1.8
	sun.light_color = Color(1.0, 0.98, 0.92)
	sun.shadow_enabled = false
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20, -120, 0)
	fill.light_energy = 0.55
	fill.light_color = Color(0.75, 0.85, 1.0)
	add_child(fill)

	# 地面参考面，方便判断方向与距离
	var ground := MeshInstance3D.new()
	ground.name = "EditorGround"
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(4000, 4000)
	ground.mesh = ground_mesh
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.55, 0.58, 0.52)
	ground_mat.roughness = 1.0
	ground.material_override = ground_mat
	ground.position.y = GROUND_Y - 0.08
	add_child(ground)

	_track_root = Node3D.new()
	_track_root.name = "TrackRoot"
	add_child(_track_root)
	_marker_root = Node3D.new()
	_marker_root.name = "Markers"
	add_child(_marker_root)
	_side_root = Node3D.new()
	_side_root.name = "SideRunways"
	add_child(_side_root)
	_sand_root = Node3D.new()
	_sand_root.name = "Sandstorms"
	add_child(_sand_root)
	_fork_root = Node3D.new()
	_fork_root.name = "ForkMarkers"
	add_child(_fork_root)

	_camera = Camera3D.new()
	_camera.fov = 55.0
	_camera.near = 0.15
	_camera.far = 4000.0
	_camera.current = true
	# 左侧面板约占视口，水平偏移让跑道落在右侧可见区中心
	_camera.h_offset = 4.5
	add_child(_camera)

	_cursor_marker = MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(2.2, 0.22, 2.8)
	var cmat := StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 1.0, 0.2, 0.9)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.9, 0.2)
	cmat.emission_energy_multiplier = 2.4
	cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cm.material = cmat
	_cursor_marker.mesh = cm
	add_child(_cursor_marker)

	_end_add_marker = MeshInstance3D.new()
	_end_add_marker.name = "EndAddMarker"
	var em := BoxMesh.new()
	em.size = Vector3(3.2, 0.35, 3.2)
	var emat := StandardMaterial3D.new()
	emat.albedo_color = Color(0.2, 1.0, 0.45, 0.95)
	emat.emission_enabled = true
	emat.emission = Color(0.2, 1.0, 0.5)
	emat.emission_energy_multiplier = 4.0
	emat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	em.material = emat
	_end_add_marker.mesh = em
	add_child(_end_add_marker)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	_ui_canvas_root = root

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
	panel_style.shadow_color = Color(0, 0, 0, 0.45)
	panel_style.shadow_size = 12
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
	title.text = "跑酷关卡编辑器"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	v.add_child(title)

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 15)
	_status.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	_status.text = "滚轮/A·D 移动 · Tab 切阶段 · Ctrl+S 保存"
	v.add_child(_status)

	v.add_child(_make_label("星球"))
	_planet_option = OptionButton.new()
	for pid in ["glass_desert", "rust_belt", "savanna_ring"]:
		_planet_option.add_item(pid)
	_planet_option.item_selected.connect(func(i: int) -> void:
		_load_planet(_planet_option.get_item_text(i))
		_refresh_all()
	)
	v.add_child(_planet_option)

	v.add_child(_make_label("跑道样式（可更换）"))
	_road_style_option = OptionButton.new()
	for style_id in EditorRoadPreview.STYLE_ORDER:
		_road_style_option.add_item(EditorRoadPreview.style_label(style_id))
	_select_road_style_option(_road_style_id)
	_road_style_option.item_selected.connect(func(i: int) -> void:
		if i < 0 or i >= EditorRoadPreview.STYLE_ORDER.size():
			return
		_road_style_id = EditorRoadPreview.STYLE_ORDER[i]
		_dirty = true
		_rebuild_track_mesh()
		_update_status()
		_flash_status("跑道样式：%s" % EditorRoadPreview.style_label(_road_style_id))
	)
	v.add_child(_road_style_option)

	# —— 两阶段：① 拼赛道 → ② 摆障碍 ——
	_mode_tabs = TabBar.new()
	_mode_tabs.add_tab("① 拼赛道")
	_mode_tabs.add_tab("② 摆障碍")
	_mode_tabs.add_theme_font_size_override("font_size", 18)
	_mode_tabs.tab_changed.connect(func(i: int) -> void:
		_set_edit_mode(EDIT_MODE_TRACK if i == 0 else EDIT_MODE_OBSTACLES)
	)
	v.add_child(_mode_tabs)

	_phase_hint = Label.new()
	_phase_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phase_hint.add_theme_font_size_override("font_size", 15)
	_phase_hint.add_theme_color_override("font_color", Color(1.0, 0.95, 0.55))
	v.add_child(_phase_hint)

	_track_panel = VBoxContainer.new()
	_track_panel.name = "TrackPanel"
	_track_panel.add_theme_constant_override("separation", 8)
	_track_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(_track_panel)

	_obstacle_panel = VBoxContainer.new()
	_obstacle_panel.name = "ObstaclePanel"
	_obstacle_panel.add_theme_constant_override("separation", 8)
	_obstacle_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_obstacle_panel.visible = false
	v.add_child(_obstacle_panel)

	_track_panel.add_child(_make_label("拼赛道：尽头「＋」接下一段"))
	var seg_hint := Label.new()
	seg_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	seg_hint.add_theme_font_size_override("font_size", 14)
	seg_hint.add_theme_color_override("font_color", Color(0.85, 0.9, 0.98))
	seg_hint.text = "初始一条直线。点尽头「＋」选下一段。分叉是 Y 字：±45° 两条斜路，汇合后再接直线。"
	_track_panel.add_child(seg_hint)

	var next_len_row := HBoxContainer.new()
	next_len_row.add_theme_constant_override("separation", 6)
	_track_panel.add_child(next_len_row)
	next_len_row.add_child(_make_label("下一段直线长"))
	_next_seg_len_spin = SpinBox.new()
	_next_seg_len_spin.min_value = 5.0
	_next_seg_len_spin.max_value = 800.0
	_next_seg_len_spin.step = 1.0
	_next_seg_len_spin.value = DEFAULT_SEG_LENGTH
	_next_seg_len_spin.prefix = "m"
	_next_seg_len_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_len_row.add_child(_next_seg_len_spin)

	var end_add_row := HBoxContainer.new()
	end_add_row.add_theme_constant_override("separation", 4)
	_track_panel.add_child(end_add_row)
	end_add_row.add_child(_make_button("＋ 添加下一段…", _open_piece_picker))
	end_add_row.add_child(_make_button("跳到尽头", func() -> void:
		_set_cursor_d(_path_length)
		_flash_status("已跳到赛道尽头")
	))

	_track_panel.add_child(_make_label("已有路段（选中可改长/转）"))
	var seg_params := HBoxContainer.new()
	seg_params.add_theme_constant_override("separation", 6)
	_track_panel.add_child(seg_params)
	_seg_len_spin = SpinBox.new()
	_seg_len_spin.min_value = 5.0
	_seg_len_spin.max_value = 800.0
	_seg_len_spin.step = 1.0
	_seg_len_spin.value = DEFAULT_SEG_LENGTH
	_seg_len_spin.prefix = "长"
	_seg_len_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seg_params.add_child(_seg_len_spin)
	_seg_turn_spin = SpinBox.new()
	_seg_turn_spin.min_value = -180.0
	_seg_turn_spin.max_value = 180.0
	_seg_turn_spin.step = 1.0
	_seg_turn_spin.value = 0.0
	_seg_turn_spin.prefix = "转°"
	_seg_turn_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seg_params.add_child(_seg_turn_spin)
	var seg_edit_row := HBoxContainer.new()
	seg_edit_row.add_theme_constant_override("separation", 4)
	_track_panel.add_child(seg_edit_row)
	seg_edit_row.add_child(_make_button("应用到选中段", _apply_seg_params_to_selected))
	seg_edit_row.add_child(_make_button("删选中段", _delete_selected_seg))
	var seg_btns3 := HBoxContainer.new()
	seg_btns3.add_theme_constant_override("separation", 4)
	_track_panel.add_child(seg_btns3)
	seg_btns3.add_child(_make_button("重置为初始直线", func() -> void: _reset_to_initial_straight(true)))
	seg_btns3.add_child(_make_button("载入默认路线", _load_default_track_segments))
	_seg_list = ItemList.new()
	_seg_list.name = "TrackSegList"
	_seg_list.custom_minimum_size = Vector2(0, 110)
	_seg_list.item_selected.connect(func(i: int) -> void:
		_selected_seg = i
		if i >= 0 and i < _track_segments.size():
			var s: Dictionary = _track_segments[i]
			if ObstacleLayout.is_y_fork_segment(s):
				_seg_len_spin.set_value_no_signal(float(s.get("branch_length", DEFAULT_Y_FORK_BRANCH)))
				_seg_turn_spin.set_value_no_signal(rad_to_deg(float(s.get("angle", deg_to_rad(DEFAULT_Y_FORK_ANGLE_DEG)))))
			else:
				_seg_len_spin.set_value_no_signal(float(s.get("length", DEFAULT_SEG_LENGTH)))
				_seg_turn_spin.set_value_no_signal(rad_to_deg(float(s.get("turn", 0.0))))
			_jump_cursor_to_segment(i)
		_update_status()
	)
	_track_panel.add_child(_seg_list)

	_track_panel.add_child(_make_label("旧版横向分叉区（可选，不同于 Y 字路口）"))
	var fork_params := HBoxContainer.new()
	fork_params.add_theme_constant_override("separation", 6)
	_track_panel.add_child(fork_params)
	_fork_len_spin = SpinBox.new()
	_fork_len_spin.min_value = 30.0
	_fork_len_spin.max_value = 300.0
	_fork_len_spin.step = 1.0
	_fork_len_spin.value = DEFAULT_FORK_LENGTH
	_fork_len_spin.prefix = "长"
	_fork_len_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fork_len_spin.value_changed.connect(func(_v: float) -> void:
		_apply_fork_params_to_selected()
	)
	fork_params.add_child(_fork_len_spin)
	_fork_spread_spin = SpinBox.new()
	_fork_spread_spin.min_value = 4.0
	_fork_spread_spin.max_value = 40.0
	_fork_spread_spin.step = 0.5
	_fork_spread_spin.value = DEFAULT_FORK_SPREAD
	_fork_spread_spin.prefix = "开"
	_fork_spread_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fork_spread_spin.value_changed.connect(func(_v: float) -> void:
		_apply_fork_params_to_selected()
	)
	fork_params.add_child(_fork_spread_spin)
	var fork_btns := HBoxContainer.new()
	fork_btns.add_theme_constant_override("separation", 4)
	_track_panel.add_child(fork_btns)
	fork_btns.add_child(_make_button("在游标处分叉", _add_fork_at_cursor))
	fork_btns.add_child(_make_button("删分叉", _delete_selected_fork))
	var fork_btns2 := HBoxContainer.new()
	fork_btns2.add_theme_constant_override("separation", 4)
	_track_panel.add_child(fork_btns2)
	fork_btns2.add_child(_make_button("载入默认分叉", _load_default_junctions))
	fork_btns2.add_child(_make_button("清空分叉", _clear_junctions))
	_fork_list = ItemList.new()
	_fork_list.name = "ForkList"
	_fork_list.custom_minimum_size = Vector2(0, 72)
	_fork_list.item_selected.connect(func(i: int) -> void:
		_selected_fork = i
		if i >= 0 and i < _junctions.size():
			var z: Dictionary = _junctions[i]
			_set_cursor_d(float(z.get("distance", 0.0)))
			_fork_len_spin.set_value_no_signal(float(z.get("length", DEFAULT_FORK_LENGTH)))
			_fork_spread_spin.set_value_no_signal(float(z.get("spread", DEFAULT_FORK_SPREAD)))
		_refresh_fork_visuals()
		_update_status()
	)
	_track_panel.add_child(_fork_list)

	_track_panel.add_child(_make_label("侧向跑道（墙跑基准）"))
	var side_row := HBoxContainer.new()
	side_row.add_theme_constant_override("separation", 6)
	_track_panel.add_child(side_row)
	_side_side_option = OptionButton.new()
	_side_side_option.add_item("外径 outer", 0)
	_side_side_option.add_item("左侧 left", 1)
	_side_side_option.add_item("右侧 right", 2)
	_side_side_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_row.add_child(_side_side_option)
	_side_length_spin = SpinBox.new()
	_side_length_spin.min_value = 20.0
	_side_length_spin.max_value = 200.0
	_side_length_spin.step = 1.0
	_side_length_spin.value = DEFAULT_SIDE_LENGTH
	_side_length_spin.prefix = "长"
	side_row.add_child(_side_length_spin)
	var side_btns := HBoxContainer.new()
	side_btns.add_theme_constant_override("separation", 6)
	_track_panel.add_child(side_btns)
	side_btns.add_child(_make_button("添加侧墙", _add_side_zone_at_cursor))
	side_btns.add_child(_make_button("删侧墙", _delete_selected_side))
	var side_btns2 := HBoxContainer.new()
	side_btns2.add_theme_constant_override("separation", 6)
	_track_panel.add_child(side_btns2)
	side_btns2.add_child(_make_button("载入默认侧墙", _load_default_side_zones))
	_side_list = ItemList.new()
	_side_list.name = "SideZoneList"
	_side_list.custom_minimum_size = Vector2(0, 80)
	_side_list.item_selected.connect(func(i: int) -> void:
		_selected_side = i
		if i >= 0 and i < _side_zones.size():
			var z: Dictionary = _side_zones[i]
			_set_cursor_d(float(z.get("start", 0.0)))
			_side_length_spin.value = float(z.get("length", DEFAULT_SIDE_LENGTH))
			_select_side_option_from_zone(z)
		_refresh_side_visuals()
	)
	_track_panel.add_child(_side_list)
	var side_hint := Label.new()
	side_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_hint.add_theme_font_size_override("font_size", 14)
	side_hint.add_theme_color_override("font_color", Color(0.9, 0.95, 0.75))
	side_hint.text = "侧墙属赛道基准。要「侧墙+跳板+主挡」请切②摆障碍。"
	_track_panel.add_child(side_hint)

	_track_panel.add_child(_make_label("游标距离（拼路时定位）"))
	var track_dist_row := HBoxContainer.new()
	_track_panel.add_child(track_dist_row)
	var track_dist_spin_proxy := SpinBox.new()
	track_dist_spin_proxy.min_value = 0.0
	track_dist_spin_proxy.max_value = 5000.0
	track_dist_spin_proxy.step = 1.0
	track_dist_spin_proxy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	track_dist_spin_proxy.value_changed.connect(func(vv: float) -> void:
		_set_cursor_d(vv, false)
		if _dist_spin:
			_dist_spin.set_value_no_signal(vv)
		if _dist_slider:
			_dist_slider.set_value_no_signal(vv)
	)
	# 与障碍页共用同一套距离控件：稍后创建正式 _dist_spin/_dist_slider
	_track_panel.set_meta("pending_dist_spin", track_dist_spin_proxy)
	track_dist_row.add_child(track_dist_spin_proxy)

	var go_obs := _make_button("赛道拼好了 → 去摆障碍", func() -> void:
		_set_edit_mode(EDIT_MODE_OBSTACLES)
	)
	_track_panel.add_child(go_obs)

	# ——— 障碍阶段面板 ———
	_obstacle_panel.add_child(_make_label("在已拼好的赛道基准上放置障碍"))
	var obs_hint := Label.new()
	obs_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	obs_hint.add_theme_font_size_override("font_size", 14)
	obs_hint.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	obs_hint.text = "左键放置/拖拽 · 右键删除 · Space 放置 · 1-9 选类型。"
	_obstacle_panel.add_child(obs_hint)

	_obstacle_panel.add_child(_make_label("障碍类型（1-9 快捷键）"))
	_type_option = OptionButton.new()
	for t in PLACE_TYPES:
		_type_option.add_item(t)
	_type_option.item_selected.connect(func(i: int) -> void:
		_place_type = PLACE_TYPES[i]
		_update_status()
	)
	_obstacle_panel.add_child(_type_option)

	_obstacle_panel.add_child(_make_label("车道（Q/E）"))
	_lane_option = OptionButton.new()
	_lane_option.add_item("左道 (-1)", 0)
	_lane_option.add_item("中道 (0)", 1)
	_lane_option.add_item("右道 (1)", 2)
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
	_dist_spin.max_value = 5000.0
	_dist_spin.step = 1.0
	_dist_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dist_spin.value_changed.connect(func(vv: float) -> void:
		_set_cursor_d(vv, false)
		var pending: SpinBox = _track_panel.get_meta("pending_dist_spin") if _track_panel and _track_panel.has_meta("pending_dist_spin") else null
		if pending:
			pending.set_value_no_signal(vv)
	)
	dist_row.add_child(_dist_spin)
	# 同步拼赛道页的距离框
	var pending_spin: SpinBox = _track_panel.get_meta("pending_dist_spin")
	if pending_spin:
		pending_spin.value = _cursor_d

	_dist_slider = HSlider.new()
	_dist_slider.min_value = 0.0
	_dist_slider.max_value = 1200.0
	_dist_slider.step = 1.0
	_dist_slider.value_changed.connect(func(vv: float) -> void:
		_set_cursor_d(vv, false)
	)
	_obstacle_panel.add_child(_dist_slider)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	_obstacle_panel.add_child(btn_row)
	btn_row.add_child(_make_button("放置 (Space)", _place_at_cursor))
	btn_row.add_child(_make_button("删除选中", _delete_selected))

	_obstacle_panel.add_child(_make_label("侧墙套件（障碍辅助）"))
	var kit_row := HBoxContainer.new()
	kit_row.add_theme_constant_override("separation", 6)
	_obstacle_panel.add_child(kit_row)
	kit_row.add_child(_make_button("侧墙套件", _add_side_kit_at_cursor))
	var kit_hint := Label.new()
	kit_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kit_hint.add_theme_font_size_override("font_size", 11)
	kit_hint.modulate = Color(0.8, 0.85, 0.7)
	kit_hint.text = "套件 = 侧墙 + ramp + main_block；单独放 main_block 也会自动补侧墙与跳板"
	_obstacle_panel.add_child(kit_hint)

	_obstacle_panel.add_child(_make_label("沙尘暴（可设覆盖车道）"))
	var sand_row := HBoxContainer.new()
	sand_row.add_theme_constant_override("separation", 6)
	_obstacle_panel.add_child(sand_row)
	_sand_lanes_option = OptionButton.new()
	_sand_lanes_option.add_item("占1列", 1)
	_sand_lanes_option.add_item("占2列", 2)
	_sand_lanes_option.add_item("占3列(全宽)", 3)
	_sand_lanes_option.select(2)
	_sand_lanes_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sand_lanes_option.item_selected.connect(func(_i: int) -> void:
		_refresh_sand_lane_option_labels()
		_sync_sand_lane_option_enabled()
		_apply_sand_params_to_selected({})
	)
	sand_row.add_child(_sand_lanes_option)
	_sand_lane_option = OptionButton.new()
	_sand_lane_option.add_item("仅左道", 0)
	_sand_lane_option.add_item("仅中道", 1)
	_sand_lane_option.add_item("仅右道", 2)
	_sand_lane_option.select(1)
	_sand_lane_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sand_lane_option.item_selected.connect(func(_i: int) -> void:
		_apply_sand_params_to_selected({})
	)
	sand_row.add_child(_sand_lane_option)
	var sand_row2 := HBoxContainer.new()
	sand_row2.add_theme_constant_override("separation", 6)
	_obstacle_panel.add_child(sand_row2)
	_sand_length_spin = SpinBox.new()
	_sand_length_spin.min_value = 10.0
	_sand_length_spin.max_value = 300.0
	_sand_length_spin.step = 1.0
	_sand_length_spin.value = DEFAULT_SAND_LENGTH
	_sand_length_spin.prefix = "长"
	_sand_length_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sand_length_spin.value_changed.connect(func(vv: float) -> void:
		_apply_sand_params_to_selected({"length": vv})
	)
	sand_row2.add_child(_sand_length_spin)
	_sand_dps_spin = SpinBox.new()
	_sand_dps_spin.min_value = 1.0
	_sand_dps_spin.max_value = 30.0
	_sand_dps_spin.step = 0.5
	_sand_dps_spin.value = DEFAULT_SAND_DPS
	_sand_dps_spin.prefix = "DPS"
	_sand_dps_spin.value_changed.connect(func(vv: float) -> void:
		_apply_sand_params_to_selected({"dps": vv})
	)
	sand_row2.add_child(_sand_dps_spin)
	var sand_presets := HBoxContainer.new()
	sand_presets.add_theme_constant_override("separation", 4)
	_obstacle_panel.add_child(sand_presets)
	sand_presets.add_child(_make_button("全宽", func() -> void: _set_sand_coverage_ui(3, 1)))
	sand_presets.add_child(_make_button("仅中", func() -> void: _set_sand_coverage_ui(1, 1)))
	sand_presets.add_child(_make_button("左+中", func() -> void: _set_sand_coverage_ui(2, 0)))
	sand_presets.add_child(_make_button("中+右", func() -> void: _set_sand_coverage_ui(2, 1)))
	var sand_btns := HBoxContainer.new()
	sand_btns.add_theme_constant_override("separation", 6)
	_obstacle_panel.add_child(sand_btns)
	sand_btns.add_child(_make_button("添加沙尘暴", _add_sand_zone_at_cursor))
	sand_btns.add_child(_make_button("删沙尘暴", _delete_selected_sand))
	var sand_btns2 := HBoxContainer.new()
	sand_btns2.add_theme_constant_override("separation", 6)
	_obstacle_panel.add_child(sand_btns2)
	sand_btns2.add_child(_make_button("载入默认沙尘暴", _load_default_sand_zones))
	_sand_list = ItemList.new()
	_sand_list.name = "SandZoneList"
	_sand_list.custom_minimum_size = Vector2(0, 80)
	_sand_list.item_selected.connect(func(i: int) -> void:
		_selected_sand = i
		if i >= 0 and i < _sand_zones.size():
			var z: Dictionary = _sand_zones[i]
			_set_cursor_d(float(z.get("start", 0.0)))
			_select_sand_options_from_zone(z)
			if _sand_length_spin:
				_sand_length_spin.set_value_no_signal(float(z.get("length", DEFAULT_SAND_LENGTH)))
			if _sand_dps_spin:
				_sand_dps_spin.set_value_no_signal(float(z.get("dps", DEFAULT_SAND_DPS)))
		_refresh_sand_visuals()
	)
	_obstacle_panel.add_child(_sand_list)
	var sand_hint := Label.new()
	sand_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sand_hint.add_theme_font_size_override("font_size", 11)
	sand_hint.modulate = Color(0.95, 0.8, 0.55)
	sand_hint.text = "覆盖范围：占N列 + 起点道。场景橙色带=受影响车道；未覆盖道可换道躲避。保存进自定义关后运行时生效。默认星球仍是全宽三道。"
	_obstacle_panel.add_child(sand_hint)
	_refresh_sand_lane_option_labels()
	_sync_sand_lane_option_enabled()

	_obstacle_panel.add_child(_make_label("障碍列表（点击选中）"))
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(0, 160)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.item_selected.connect(func(i: int) -> void:
		_selected = i
		if i >= 0 and i < _items.size():
			var it: Dictionary = _items[i]
			_set_cursor_d(float(it.get("distance", 0.0)))
			var lane := int(it.get("lane", 0))
			_set_lane_index(_lane_value_to_index(lane))
			var t := String(it.get("type", "jump"))
			var ti := PLACE_TYPES.find(t)
			if ti >= 0:
				_set_place_type(t)
				_type_option.select(ti)
	)
	_obstacle_panel.add_child(_list)

	var go_track := _make_button("← 返回拼赛道", func() -> void:
		_set_edit_mode(EDIT_MODE_TRACK)
	)
	_obstacle_panel.add_child(go_track)

	# ——— 共用：保存 / 关卡列表 ———
	var btn_row2 := HBoxContainer.new()
	btn_row2.add_theme_constant_override("separation", 6)
	v.add_child(btn_row2)
	btn_row2.add_child(_make_button("▶ 试玩当前", _playtest_layout))
	btn_row2.add_child(_make_button("保存为关卡", _save_layout))
	btn_row2.add_child(_make_button("重新加载", _reload_layout))

	var btn_row3 := HBoxContainer.new()
	btn_row3.add_theme_constant_override("separation", 6)
	v.add_child(btn_row3)
	btn_row3.add_child(_make_button("载入默认表", _load_defaults_from_code))
	btn_row3.add_child(_make_button("清空障碍", func() -> void:
		_items.clear()
		_sand_zones.clear()
		_selected = -1
		_selected_sand = -1
		_dirty = true
		_refresh_markers()
		_refresh_sand_visuals()
		_refresh_list()
		_refresh_sand_list()
		_update_status()
	))

	var next_seq := CustomLevels.next_sequence()
	var next_hint := Label.new()
	next_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_hint.add_theme_font_size_override("font_size", 12)
	next_hint.modulate = Color(0.75, 0.9, 1.0)
	next_hint.name = "NextLevelHint"
	next_hint.text = "下次保存将创建：%s（%s）" % [
		CustomLevels.format_name(next_seq),
		CustomLevels.format_id(next_seq),
	]
	v.add_child(next_hint)

	v.add_child(_make_label("已上架自定义关卡"))
	var custom_list := ItemList.new()
	custom_list.name = "CustomLevelList"
	custom_list.custom_minimum_size = Vector2(0, 90)
	custom_list.item_selected.connect(func(i: int) -> void:
		_load_custom_level_by_list_index(i)
	)
	v.add_child(custom_list)
	_refresh_custom_level_list(custom_list)

	var help := Label.new()
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.add_theme_font_size_override("font_size", 14)
	help.add_theme_color_override("font_color", Color(0.95, 0.95, 0.8))
	help.text = "①拼赛道 → ②摆障碍 → 试玩/保存。Tab 切阶段 · Ctrl+P 试玩 · Ctrl+S 保存。"
	v.add_child(help)

	_status.text = "先拼赛道：点尽头「＋」或 Space 选下一段 · Ctrl+P 试玩 · Tab 摆障碍"

	_build_end_add_button(root)
	_build_piece_picker(root)


func _build_end_add_button(parent: Control) -> void:
	_end_add_btn = Button.new()
	_end_add_btn.name = "EndAddButton"
	_end_add_btn.text = "＋ 添加"
	_end_add_btn.custom_minimum_size = Vector2(120, 48)
	_end_add_btn.add_theme_font_size_override("font_size", 20)
	_end_add_btn.add_theme_color_override("font_color", Color(0.05, 0.12, 0.08))
	_end_add_btn.add_theme_color_override("font_hover_color", Color(0.05, 0.12, 0.08))
	_end_add_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.35, 0.95, 0.55, 0.95)
	normal.border_color = Color(0.85, 1.0, 0.9)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate()
	hover.bg_color = Color(0.5, 1.0, 0.65, 1.0)
	_end_add_btn.add_theme_stylebox_override("normal", normal)
	_end_add_btn.add_theme_stylebox_override("hover", hover)
	_end_add_btn.add_theme_stylebox_override("pressed", hover)
	_end_add_btn.pressed.connect(_open_piece_picker)
	_end_add_btn.visible = false
	parent.add_child(_end_add_btn)


func _build_piece_picker(parent: Control) -> void:
	_piece_picker = PopupPanel.new()
	_piece_picker.name = "PiecePicker"
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.12, 0.16, 0.98)
	panel_style.border_color = Color(0.4, 0.95, 0.6, 0.9)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 12
	panel_style.content_margin_bottom = 12
	_piece_picker.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(_piece_picker)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.custom_minimum_size = Vector2(260, 0)
	_piece_picker.add_child(box)

	var title := Label.new()
	title.text = "选择下一段赛道"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	box.add_child(title)

	var sub := Label.new()
	sub.text = "接在当前赛道尽头之后"
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color(0.8, 0.9, 0.85))
	box.add_child(sub)

	var choices: Array = [
		["直线", func() -> void: _pick_piece_straight()],
		["左转 90°", func() -> void: _pick_piece_turn(70.0, 90.0)],
		["右转 90°", func() -> void: _pick_piece_turn(70.0, -90.0)],
		["左转 45°", func() -> void: _pick_piece_turn(55.0, 45.0)],
		["右转 45°", func() -> void: _pick_piece_turn(55.0, -45.0)],
		["分叉 Y±45°", func() -> void: _pick_piece_fork()],
		["侧墙", func() -> void: _pick_piece_side()],
	]
	for c in choices:
		box.add_child(_make_button(String(c[0]), c[1] as Callable))
	box.add_child(_make_button("取消", func() -> void:
		if _piece_picker:
			_piece_picker.hide()
	))


func _make_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0))
	return l


func _set_edit_mode(mode: String) -> void:
	_edit_mode = mode if mode in [EDIT_MODE_TRACK, EDIT_MODE_OBSTACLES] else EDIT_MODE_TRACK
	var is_track := _edit_mode == EDIT_MODE_TRACK
	if _track_panel:
		_track_panel.visible = is_track
	if _obstacle_panel:
		_obstacle_panel.visible = not is_track
	if _mode_tabs and _mode_tabs.tab_count >= 2:
		var want := 0 if is_track else 1
		if _mode_tabs.current_tab != want:
			_mode_tabs.set_current_tab(want)
	if _marker_root:
		_marker_root.visible = not is_track
	if _phase_hint:
		if is_track:
			_phase_hint.text = "① 拼赛道：点尽头「＋」选择下一段。点地不会放障碍。"
			_phase_hint.add_theme_color_override("font_color", Color(1.0, 0.95, 0.45))
		else:
			_phase_hint.text = "② 摆障碍：在已拼赛道上放置。改路请回①。"
			_phase_hint.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0))
	if _end_add_btn and not is_track:
		_end_add_btn.visible = false
	if _end_add_marker and not is_track:
		_end_add_marker.visible = false
	if _piece_picker and _piece_picker.visible and not is_track:
		_piece_picker.hide()
	_dragging_marker = false
	_drag_index = -1
	_update_status()


func _try_set_cursor_at_mouse(screen_pos: Vector2) -> bool:
	var hit := _ray_from_mouse(screen_pos)
	if hit.is_empty():
		return false
	var world: Vector3 = hit["pos"]
	var d := _nearest_distance_to_point(world)
	var on_path: Vector3 = _sample_path(d)["pos"]
	if Vector2(world.x, world.z).distance_to(Vector2(on_path.x, on_path.z)) > 14.0:
		return false
	_set_cursor_d(d)
	return true


func _make_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 36)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color(0.05, 0.08, 0.12))
	b.add_theme_color_override("font_hover_color", Color(0.05, 0.08, 0.12))
	b.add_theme_color_override("font_pressed_color", Color(0.05, 0.08, 0.12))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.78, 0.88, 0.98)
	normal.border_color = Color(0.95, 0.98, 1.0)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(6)
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	var hover := normal.duplicate()
	hover.bg_color = Color(0.88, 0.94, 1.0)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.62, 0.78, 0.92)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.pressed.connect(cb)
	return b


func _load_planet(planet_id: String) -> void:
	_planet_id = planet_id
	LevelConfig = PlanetDatabase.get_runner_config(planet_id)
	_visual_factory.configure_from_level_config(LevelConfig)
	_road_style_id = EditorRoadPreview.normalize_style(String(Global.get_runner_road_style()))
	_select_road_style_option(_road_style_id)
	var duration := 65.0
	if LevelConfig != null and LevelConfig.get("MISSION") != null:
		duration = float(LevelConfig.MISSION.get("duration", 65.0))
	_track_length = MissionTypes.track_length_for(duration)
	_track_segments = _planet_default_track_segments()
	_junctions = _planet_default_junctions()
	_bake_path()
	_rebuild_track_mesh()
	if ObstacleLayout.has_layout(_planet_id):
		var layout_root: Dictionary = ObstacleLayout.load_root(_planet_id)
		_items = ObstacleLayout.sort_items(ObstacleLayout.load_items(_planet_id))
		# 有 key 即采用（含空数组 = 刻意清空）；无 key 才回退星球默认
		if layout_root.has("side_runway_zones"):
			_side_zones = ObstacleLayout.load_side_runway_zones(_planet_id)
		else:
			_side_zones = _planet_default_side_zones()
		if layout_root.has("sandstorm_zones"):
			_sand_zones = ObstacleLayout.load_sandstorm_zones(_planet_id)
		else:
			_sand_zones = _planet_default_sand_zones()
		var saved_segs := ObstacleLayout.load_track_segments(_planet_id)
		if not saved_segs.is_empty():
			_track_segments = saved_segs
			_bake_path()
			_rebuild_track_mesh()
		# 有 key 即采用（含空数组）；无 key 保留星球默认
		if layout_root.has("junction_zones"):
			_junctions = ObstacleLayout.load_junction_zones(_planet_id)
	elif LevelConfig != null and LevelConfig.has_method("_default_obstacles"):
		_items = ObstacleLayout.sort_items(LevelConfig._default_obstacles())
		_side_zones = _planet_default_side_zones()
		_sand_zones = _planet_default_sand_zones()
	else:
		var GlassDesert = load("res://assets/maps/route_levels/planets/planet_glass_desert.gd")
		if GlassDesert and GlassDesert.has_method("_default_obstacles"):
			_items = ObstacleLayout.sort_items(GlassDesert._default_obstacles())
		else:
			_items.clear()
		_side_zones = _planet_default_side_zones()
		_sand_zones = _planet_default_sand_zones()
	_dirty = false
	_selected = -1
	_selected_side = -1
	_selected_sand = -1
	_selected_seg = -1
	_selected_fork = -1
	_set_cursor_d(40.0)


func _planet_default_track_segments() -> Array:
	if LevelConfig != null and LevelConfig.has_method("get_track_segments"):
		var out: Array = []
		for raw in LevelConfig.get_track_segments():
			if typeof(raw) == TYPE_DICTIONARY:
				out.append(ObstacleLayout.normalize_track_segment(raw))
		if not out.is_empty():
			return out
	return [ObstacleLayout.normalize_track_segment({"length": _track_length + 80.0, "turn": 0.0})]


func _planet_default_junctions() -> Array:
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if not constants.has("JUNCTION_ZONES"):
		return []
	var out: Array = []
	for raw in constants["JUNCTION_ZONES"]:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(ObstacleLayout.normalize_junction_zone(raw))
	return ObstacleLayout.sort_junction_zones(out)


func _planet_default_side_zones() -> Array:
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if not constants.has("SIDE_RUNWAY_ZONES"):
		return []
	var out: Array = []
	for raw in constants["SIDE_RUNWAY_ZONES"]:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(ObstacleLayout.normalize_side_zone(raw))
	return ObstacleLayout.sort_side_zones(out)


func _planet_default_sand_zones() -> Array:
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if not constants.has("SANDSTORM_ZONES"):
		return []
	var out: Array = []
	for raw in constants["SANDSTORM_ZONES"]:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(ObstacleLayout.normalize_sandstorm_zone(raw))
	return ObstacleLayout.sort_sandstorm_zones(out)


func _bake_path() -> void:
	var baked: Dictionary = ObstacleLayout.bake_path_from_segments(_track_segments, 2.0)
	_path_samples.clear()
	for s in baked.get("samples", []):
		if typeof(s) == TYPE_DICTIONARY:
			_path_samples.append(s)
	_path_length = maxf(float(baked.get("length", 0.0)), 1.0)
	if _dist_slider:
		_dist_slider.max_value = maxf(_path_length, 100.0)
	if _dist_spin:
		_dist_spin.max_value = _dist_slider.max_value if _dist_slider else maxf(_path_length, 100.0)


func _sample_path(distance: float) -> Dictionary:
	if _path_samples.is_empty():
		return {"pos": Vector3.ZERO, "yaw": 0.0, "forward": Vector3(0, 0, -1), "right": Vector3(1, 0, 0)}
	var d := clampf(distance, 0.0, _path_length)
	var lo := 0
	var hi := _path_samples.size() - 1
	while lo < hi - 1:
		var mid := (lo + hi) >> 1
		if float(_path_samples[mid]["d"]) <= d:
			lo = mid
		else:
			hi = mid
	var a: Dictionary = _path_samples[lo]
	var b: Dictionary = _path_samples[hi]
	var da := float(a["d"])
	var db := float(b["d"])
	var t := 0.0 if db <= da + 0.0001 else clampf((d - da) / (db - da), 0.0, 1.0)
	var pos: Vector3 = (a["pos"] as Vector3).lerp(b["pos"] as Vector3, t)
	var yaw := lerp_angle(float(a["yaw"]), float(b["yaw"]), t)
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := forward.cross(Vector3.UP).normalized()
	return {"pos": pos, "yaw": yaw, "forward": forward, "right": right}


func _rebuild_track_mesh() -> void:
	if _world_environment != null:
		_road_preview.apply_environment(_world_environment.environment, _road_style_id)
	_road_preview.rebuild(
		_track_root,
		Callable(self, "_sample_path"),
		_path_length,
		_road_style_id,
		_junctions,
		{"track_pad": 12.0, "include_start_pad": true}
	)
	_rebuild_y_fork_branch_meshes()


func _rebuild_y_fork_branch_meshes() -> void:
	# 主路径已走左岔；这里补画右岔，形成完整 Y 字
	if _track_root == null:
		return
	for entry in ObstacleLayout.segment_start_poses(_track_segments, 2.0):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = entry.get("segment", {})
		if not ObstacleLayout.is_y_fork_segment(seg):
			continue
		var poly: Array = ObstacleLayout.bake_y_fork_branch_polyline(
			entry.get("pos", Vector3.ZERO),
			float(entry.get("yaw", 0.0)),
			float(seg.get("branch_length", DEFAULT_Y_FORK_BRANCH)),
			float(seg.get("angle", deg_to_rad(DEFAULT_Y_FORK_ANGLE_DEG))),
			-1.0,
			2.0
		)
		_road_preview.add_polyline_road(_track_root, poly, _road_style_id)


func _select_road_style_option(style_id: String) -> void:
	if _road_style_option == null:
		return
	var id := EditorRoadPreview.normalize_style(style_id)
	var idx := EditorRoadPreview.STYLE_ORDER.find(id)
	if idx >= 0:
		_road_style_option.select(idx)


func _world_on_path(distance: float, lane_value: int) -> Vector3:
	var sample := _sample_path(distance)
	var lat := float(lane_value) * LANE_WIDTH
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lat
	pos.y = GROUND_Y
	return pos


func _refresh_all() -> void:
	_refresh_markers()
	_refresh_side_visuals()
	_refresh_sand_visuals()
	_refresh_fork_visuals()
	_refresh_list()
	_refresh_side_list()
	_refresh_sand_list()
	_refresh_seg_list()
	_refresh_fork_list()
	_update_status()
	_update_cursor_marker()
	_update_camera()


func _refresh_markers() -> void:
	while _marker_root.get_child_count() > 0:
		_marker_root.get_child(0).free()
	for i in _items.size():
		var it: Dictionary = _items[i]
		var node := _make_obstacle_marker(it, i == _selected)
		node.set_meta("item_index", i)
		_marker_root.add_child(node)
	_marker_root.visible = _edit_mode == EDIT_MODE_OBSTACLES


func _make_obstacle_marker(item: Dictionary, selected: bool) -> Node3D:
	var root := Node3D.new()
	var otype := String(item.get("type", "jump"))
	var lane := int(item.get("lane", 0))
	var dist := float(item.get("distance", 0.0))
	var sample := _sample_path(dist)
	var lateral := 0.0 if ObstacleVisualFactory.uses_center_lane(otype) else float(lane) * LANE_WIDTH
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral
	pos.y = GROUND_Y
	if otype in ["slide", "high_bar", "main_block"]:
		pos.y -= 0.06
	root.position = pos
	root.rotation.y = float(sample["yaw"])

	var model := _visual_factory.build(item)
	root.add_child(model)

	if selected:
		var ring := MeshInstance3D.new()
		ring.name = "SelectionRing"
		var torus := TorusMesh.new()
		torus.inner_radius = 0.55
		torus.outer_radius = 0.72
		torus.rings = 12
		torus.ring_segments = 24
		var rmat := StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.92, 0.2, 0.85)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.9, 0.25)
		rmat.emission_energy_multiplier = 2.2
		rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		torus.material = rmat
		ring.mesh = torus
		ring.rotation_degrees.x = 90.0
		ring.position.y = 0.08
		root.add_child(ring)

	var label := Label3D.new()
	label.text = "%s\n%.0f" % [otype, dist]
	label.font_size = 42 if selected else 36
	label.pixel_size = 0.012
	label.position = Vector3(0.0, 2.6 if selected else 2.2, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 1.0, 0.55) if selected else Color(0.92, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 8
	root.add_child(label)
	return root


func _refresh_list() -> void:
	if _list == null:
		return
	_list.clear()
	for i in _items.size():
		var it: Dictionary = _items[i]
		_list.add_item("%02d  d=%.0f  lane=%d  %s" % [
			i,
			float(it.get("distance", 0.0)),
			int(it.get("lane", 0)),
			String(it.get("type", "?")),
		])
	if _selected >= 0 and _selected < _items.size():
		_list.select(_selected)


func _refresh_side_list() -> void:
	if _side_list == null:
		return
	_side_list.clear()
	for i in _side_zones.size():
		var z: Dictionary = _side_zones[i]
		_side_list.add_item("%02d  start=%.0f  len=%.0f  %s" % [
			i,
			float(z.get("start", 0.0)),
			float(z.get("length", 0.0)),
			String(z.get("side", "outer")),
		])
	if _selected_side >= 0 and _selected_side < _side_zones.size():
		_side_list.select(_selected_side)


func _refresh_side_visuals() -> void:
	if _side_root == null:
		return
	while _side_root.get_child_count() > 0:
		_side_root.get_child(0).free()
	for i in _side_zones.size():
		var z: Dictionary = _side_zones[i]
		_side_root.add_child(_make_side_zone_visual(z, i == _selected_side))


func _make_side_zone_visual(zone: Dictionary, selected: bool) -> Node3D:
	var root := Node3D.new()
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", DEFAULT_SIDE_LENGTH))
	var entry := float(zone.get("entry_window", DEFAULT_SIDE_ENTRY))
	var offset := float(zone.get("lateral_offset", DEFAULT_SIDE_OFFSET))
	var side_sign := _side_zone_sign(zone)
	var mat := StandardMaterial3D.new()
	var col := Color(1.0, 0.55, 0.15, 0.55) if selected else Color(1.0, 0.35, 0.08, 0.38)
	mat.albedo_color = col
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.45, 0.1)
	mat.emission_energy_multiplier = 1.4 if selected else 0.7
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step := 2.0
	var d := maxf(0.0, start - entry)
	var end_d := start + length
	var prev_a := Vector3.ZERO
	var prev_b := Vector3.ZERO
	var has_prev := false
	var wall_h := 4.5
	while d <= end_d + 0.001:
		var sample := _sample_path(minf(d, _path_length))
		var origin: Vector3 = sample["pos"]
		var right: Vector3 = sample["right"]
		var base := origin + right * (side_sign * offset)
		base.y = GROUND_Y
		var a := base
		var b := base + Vector3(0.0, wall_h, 0.0)
		if has_prev:
			st.set_normal(right * side_sign)
			st.add_vertex(prev_a)
			st.add_vertex(prev_b)
			st.add_vertex(b)
			st.add_vertex(prev_a)
			st.add_vertex(b)
			st.add_vertex(a)
		prev_a = a
		prev_b = b
		has_prev = true
		if d >= end_d:
			break
		d = minf(d + step, end_d)
	var mesh := st.commit()
	if mesh:
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.material_override = mat
		root.add_child(mi)
	var label := Label3D.new()
	label.text = "SIDE\n%.0f→%.0f" % [start, start + length]
	label.font_size = 42
	label.modulate = Color(1.0, 0.85, 0.4)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	var mid := _sample_path(start + length * 0.5)
	label.position = (mid["pos"] as Vector3) + (mid["right"] as Vector3) * (side_sign * offset) + Vector3(0, wall_h + 0.6, 0)
	root.add_child(label)
	return root


func _side_zone_sign(zone: Dictionary) -> float:
	var side := String(zone.get("side", "outer"))
	if side == "left":
		return -1.0
	if side == "right":
		return 1.0
	# outer：用当前路径弯道近似——取 fallback
	return float(int(zone.get("fallback_side", 1)))


func _current_side_choice() -> Dictionary:
	var idx := _side_side_option.selected if _side_side_option else 0
	match idx:
		1:
			return {"side": "left", "fallback_side": -1}
		2:
			return {"side": "right", "fallback_side": 1}
		_:
			return {"side": "outer", "fallback_side": 1 if _lane_index >= 1 else -1}


func _select_side_option_from_zone(zone: Dictionary) -> void:
	if _side_side_option == null:
		return
	match String(zone.get("side", "outer")):
		"left":
			_side_side_option.select(1)
		"right":
			_side_side_option.select(2)
		_:
			_side_side_option.select(0)


func _make_side_zone_at_cursor() -> Dictionary:
	var choice := _current_side_choice()
	return ObstacleLayout.normalize_side_zone({
		"start": snappedf(_cursor_d, 1.0),
		"length": float(_side_length_spin.value) if _side_length_spin else DEFAULT_SIDE_LENGTH,
		"side": choice["side"],
		"fallback_side": choice["fallback_side"],
		"lateral_offset": DEFAULT_SIDE_OFFSET,
		"layer": 1,
		"entry_window": DEFAULT_SIDE_ENTRY,
	})


func _add_side_zone_at_cursor() -> void:
	_side_zones.append(_make_side_zone_at_cursor())
	_side_zones = ObstacleLayout.sort_side_zones(_side_zones)
	_selected_side = _side_zones.size() - 1
	# 重排后按 start 找回
	var start := snappedf(_cursor_d, 1.0)
	for i in _side_zones.size():
		if absf(float(_side_zones[i].get("start", 0.0)) - start) < 0.5:
			_selected_side = i
			break
	_dirty = true
	_refresh_side_list()
	_refresh_side_visuals()
	_update_status()
	_flash_status("已添加侧边跑道")


func _add_side_kit_at_cursor() -> void:
	var zone := _make_side_zone_at_cursor()
	var start := float(zone["start"])
	var length := float(zone["length"])
	var entry := float(zone["entry_window"])
	_side_zones.append(zone)
	_side_zones = ObstacleLayout.sort_side_zones(_side_zones)
	# 入口跳板 + 主路封堵（与正式关卡默认对齐习惯）
	_items.append(ObstacleLayout.normalize_item({
		"type": "ramp",
		"lane": 0,
		"distance": snappedf(start - entry + 2.0, 1.0),
		"target_layer": 1,
		"layer": 0,
	}))
	_items.append(ObstacleLayout.normalize_item({
		"type": "main_block",
		"lane": 0,
		"distance": snappedf(start + length * 0.5, 1.0),
		"half_depth": maxf(12.0, length * 0.45),
		"layer": 0,
	}))
	_items = ObstacleLayout.sort_items(_items)
	_dirty = true
	_selected = -1
	_selected_side = 0
	for i in _side_zones.size():
		if absf(float(_side_zones[i].get("start", 0.0)) - start) < 0.5:
			_selected_side = i
			break
	_refresh_all()
	_flash_status("已添加侧墙套件（侧墙 + ramp + main_block）")


func _delete_selected_side() -> void:
	if _selected_side < 0 or _selected_side >= _side_zones.size():
		return
	_side_zones.remove_at(_selected_side)
	_selected_side = mini(_selected_side, _side_zones.size() - 1)
	_dirty = true
	_refresh_side_list()
	_refresh_side_visuals()
	_update_status()


func _load_default_side_zones() -> void:
	_side_zones = _planet_default_side_zones()
	_selected_side = -1
	_dirty = true
	_refresh_side_list()
	_refresh_side_visuals()
	_update_status()
	_flash_status("已载入星球默认侧边跑道（未保存）")


func _sync_sand_lane_option_enabled() -> void:
	if _sand_lane_option == null or _sand_lanes_option == null:
		return
	var count := _sand_lanes_option.get_selected_id()
	_sand_lane_option.disabled = count >= 3
	if count == 2 and _sand_lane_option.selected >= 2:
		_sand_lane_option.select(1)


func _refresh_sand_lane_option_labels() -> void:
	if _sand_lane_option == null or _sand_lanes_option == null:
		return
	var count := _sand_lanes_option.get_selected_id()
	var keep := _sand_lane_option.selected
	_sand_lane_option.clear()
	match count:
		1:
			_sand_lane_option.add_item("仅左道", 0)
			_sand_lane_option.add_item("仅中道", 1)
			_sand_lane_option.add_item("仅右道", 2)
		2:
			_sand_lane_option.add_item("左+中", 0)
			_sand_lane_option.add_item("中+右", 1)
			# 占位，保持索引稳定；选到会自动钳回
			_sand_lane_option.add_item("(不可用)", 2)
			_sand_lane_option.set_item_disabled(2, true)
		_:
			_sand_lane_option.add_item("全宽三道", 0)
			_sand_lane_option.add_item("全宽三道", 1)
			_sand_lane_option.add_item("全宽三道", 2)
	if count == 2:
		_sand_lane_option.select(clampi(keep, 0, 1))
	elif count >= 3:
		_sand_lane_option.select(1)
	else:
		_sand_lane_option.select(clampi(keep, 0, 2))


func _set_sand_coverage_ui(lane_count: int, lane_option_index: int) -> void:
	if _sand_lanes_option == null:
		return
	var count := clampi(lane_count, 1, 3)
	for i in _sand_lanes_option.item_count:
		if _sand_lanes_option.get_item_id(i) == count:
			_sand_lanes_option.select(i)
			break
	_refresh_sand_lane_option_labels()
	_sync_sand_lane_option_enabled()
	if _sand_lane_option and not _sand_lane_option.disabled:
		_sand_lane_option.select(clampi(lane_option_index, 0, 2 if count == 1 else 1))
	if _selected_sand >= 0:
		_apply_sand_params_to_selected({})
	else:
		_flash_status("已设覆盖：%s（再点「添加沙尘暴」放到游标处）" % _sand_coverage_label_from_ui())


func _sand_coverage_label_from_ui() -> String:
	var count := _sand_lanes_option.get_selected_id() if _sand_lanes_option else 3
	count = clampi(count, 1, 3)
	var lane_idx := _sand_lane_option.selected if _sand_lane_option else 1
	var anchor := lane_idx - 1
	if count == 2:
		anchor = -1 if lane_idx <= 0 else 0
	elif count == 3:
		anchor = 0
	return _covered_lanes_label(ObstacleLayout.sandstorm_covered_lanes(count, anchor))


func _covered_lanes_label(covered: Array) -> String:
	if covered.is_empty() or covered.size() >= 3:
		return "全宽(左中右)"
	var names: PackedStringArray = PackedStringArray()
	for v in covered:
		match int(v):
			-1:
				names.append("左")
			0:
				names.append("中")
			1:
				names.append("右")
	return "+".join(names)


func _select_sand_options_from_zone(zone: Dictionary) -> void:
	if _sand_lanes_option == null:
		return
	var count := clampi(int(zone.get("lane_count", 3)), 1, 3)
	for i in _sand_lanes_option.item_count:
		if _sand_lanes_option.get_item_id(i) == count:
			_sand_lanes_option.select(i)
			break
	_refresh_sand_lane_option_labels()
	var anchor := int(zone.get("lane", 0))
	var lane_idx := clampi(anchor + 1, 0, 2)
	if count == 2:
		lane_idx = 0 if anchor <= -1 else 1
	_sand_lane_option.select(lane_idx)
	_sync_sand_lane_option_enabled()


func _apply_sand_params_to_selected(overrides: Dictionary) -> void:
	if _selected_sand < 0 or _selected_sand >= _sand_zones.size():
		return
	var z: Dictionary = _sand_zones[_selected_sand].duplicate(true)
	var count := _sand_lanes_option.get_selected_id() if _sand_lanes_option else int(z.get("lane_count", 3))
	count = clampi(count, 1, 3)
	var lane_idx := _sand_lane_option.selected if _sand_lane_option else 1
	var anchor := lane_idx - 1
	if count == 2:
		anchor = -1 if lane_idx <= 0 else 0
	elif count == 3:
		anchor = 0
	z["lane_count"] = count
	z["lane"] = anchor
	z["length"] = float(overrides.get("length", _sand_length_spin.value if _sand_length_spin else z.get("length", DEFAULT_SAND_LENGTH)))
	z["dps"] = float(overrides.get("dps", _sand_dps_spin.value if _sand_dps_spin else z.get("dps", DEFAULT_SAND_DPS)))
	z["start"] = float(z.get("start", _cursor_d))
	_sand_zones[_selected_sand] = ObstacleLayout.normalize_sandstorm_zone(z)
	_dirty = true
	_refresh_sand_list()
	_refresh_sand_visuals()
	_update_status()


func _make_sand_zone_at_cursor() -> Dictionary:
	var count := _sand_lanes_option.get_selected_id() if _sand_lanes_option else 3
	count = clampi(count, 1, 3)
	var lane_idx := _sand_lane_option.selected if _sand_lane_option else 1
	var anchor := lane_idx - 1
	if count == 2:
		anchor = -1 if lane_idx <= 0 else 0
	elif count == 3:
		anchor = 0
	var label := "沙尘暴"
	if count == 1:
		label = "窄道沙尘"
	elif float(_sand_dps_spin.value) >= 11.5:
		label = "强沙尘暴"
	return ObstacleLayout.normalize_sandstorm_zone({
		"start": snappedf(_cursor_d, 1.0),
		"length": float(_sand_length_spin.value) if _sand_length_spin else DEFAULT_SAND_LENGTH,
		"dps": float(_sand_dps_spin.value) if _sand_dps_spin else DEFAULT_SAND_DPS,
		"label": label,
		"lane_count": count,
		"lane": anchor,
	})


func _add_sand_zone_at_cursor() -> void:
	var zone := _make_sand_zone_at_cursor()
	_sand_zones.append(zone)
	_sand_zones = ObstacleLayout.sort_sandstorm_zones(_sand_zones)
	var start := float(zone.get("start", 0.0))
	_selected_sand = 0
	for i in _sand_zones.size():
		if absf(float(_sand_zones[i].get("start", 0.0)) - start) < 0.5:
			_selected_sand = i
			break
	_dirty = true
	_refresh_sand_list()
	_refresh_sand_visuals()
	_update_status()
	_flash_status("已添加沙尘暴 · %s · 长%.0f · dps%.1f" % [
		_covered_lanes_label(zone.get("covered_lanes", [])),
		float(zone.get("length", 0.0)),
		float(zone.get("dps", DEFAULT_SAND_DPS)),
	])


func _delete_selected_sand() -> void:
	if _selected_sand < 0 or _selected_sand >= _sand_zones.size():
		return
	_sand_zones.remove_at(_selected_sand)
	_selected_sand = mini(_selected_sand, _sand_zones.size() - 1)
	_dirty = true
	_refresh_sand_list()
	_refresh_sand_visuals()
	_update_status()


func _load_default_sand_zones() -> void:
	_sand_zones = _planet_default_sand_zones()
	_selected_sand = -1
	_dirty = true
	_refresh_sand_list()
	_refresh_sand_visuals()
	_update_status()
	_flash_status("已载入星球默认沙尘暴（未保存）")


func _refresh_sand_list() -> void:
	if _sand_list == null:
		return
	_sand_list.clear()
	for i in _sand_zones.size():
		var z: Dictionary = _sand_zones[i]
		var covered: Array = z.get("covered_lanes", [])
		_sand_list.add_item("%02d  %.0f→%.0f  %s  dps=%.1f" % [
			i,
			float(z.get("start", 0.0)),
			float(z.get("start", 0.0)) + float(z.get("length", 0.0)),
			_covered_lanes_label(covered),
			float(z.get("dps", DEFAULT_SAND_DPS)),
		])
	if _selected_sand >= 0 and _selected_sand < _sand_zones.size():
		_sand_list.select(_selected_sand)


func _rebuild_path_preview() -> void:
	_bake_path()
	_rebuild_track_mesh()
	_refresh_markers()
	_refresh_side_visuals()
	_refresh_sand_visuals()
	_refresh_fork_visuals()
	_update_cursor_marker()
	_update_camera()
	_update_status()


func _add_track_segment(length: float, turn_deg: float, mode: String = "auto") -> void:
	var seg := ObstacleLayout.normalize_track_segment({
		"length": length,
		"turn": deg_to_rad(turn_deg),
	})
	var insert_at := _track_segments.size()
	var resolved := mode
	if resolved == "auto":
		# 有选中：插到选中段后面（两段之间）；无选中：末尾追加
		resolved = "after" if _selected_seg >= 0 and _selected_seg < _track_segments.size() else "append"
	match resolved:
		"before":
			if _selected_seg < 0 or _selected_seg >= _track_segments.size():
				_flash_status("请先在下方路段列表中选中一段，再插到前面")
				return
			insert_at = _selected_seg
		"after":
			if _selected_seg < 0 or _selected_seg >= _track_segments.size():
				_flash_status("请先在下方路段列表中选中一段，再插到后面")
				return
			insert_at = _selected_seg + 1
		_:
			insert_at = _track_segments.size()
	_track_segments.insert(insert_at, seg)
	_selected_seg = insert_at
	_seg_len_spin.set_value_no_signal(length)
	_seg_turn_spin.set_value_no_signal(turn_deg)
	_dirty = true
	_refresh_seg_list()
	_rebuild_path_preview()
	var range_txt := _segment_distance_range(insert_at)
	# 弯道：镜头对准新弯；直线：留在尽头方便继续「＋」
	if absf(turn_deg) > 0.5:
		_jump_cursor_to_segment(insert_at, true)
	else:
		_set_cursor_d(_path_length)
	_flash_status("已接上路段 %02d（%s）长%.0f 转%+.0f°" % [
		insert_at, range_txt, length, turn_deg,
	])


func _segment_distance_range(index: int) -> String:
	var acc := 0.0
	for i in mini(index, _track_segments.size()):
		acc += float((_track_segments[i] as Dictionary).get("length", 0.0))
	var length := 0.0
	if index >= 0 and index < _track_segments.size():
		length = float((_track_segments[index] as Dictionary).get("length", 0.0))
	return "@%.0f→%.0f" % [acc, acc + length]


func _move_selected_seg(delta: int) -> void:
	if _selected_seg < 0 or _selected_seg >= _track_segments.size():
		_flash_status("请先选中要移动的路段")
		return
	var target := _selected_seg + delta
	if target < 0 or target >= _track_segments.size():
		return
	var item: Variant = _track_segments[_selected_seg]
	_track_segments.remove_at(_selected_seg)
	_track_segments.insert(target, item)
	_selected_seg = target
	_dirty = true
	_refresh_seg_list()
	_rebuild_path_preview()
	_jump_cursor_to_segment(_selected_seg, true)
	_flash_status("路段已移到 %02d" % _selected_seg)


func _apply_seg_params_to_selected() -> void:
	if _selected_seg < 0 or _selected_seg >= _track_segments.size():
		_flash_status("请先在路段列表中选中一段再应用")
		return
	var prev: Dictionary = _track_segments[_selected_seg]
	if ObstacleLayout.is_y_fork_segment(prev):
		_track_segments[_selected_seg] = ObstacleLayout.normalize_track_segment({
			"type": "y_fork",
			"branch_length": float(_seg_len_spin.value),
			"angle_deg": float(_seg_turn_spin.value),
		})
	else:
		_track_segments[_selected_seg] = ObstacleLayout.normalize_track_segment({
			"length": float(_seg_len_spin.value),
			"turn": deg_to_rad(float(_seg_turn_spin.value)),
		})
	_dirty = true
	_refresh_seg_list()
	_rebuild_path_preview()
	_jump_cursor_to_segment(_selected_seg, true)
	_flash_status("已更新路段 %02d（%s）" % [_selected_seg, _segment_distance_range(_selected_seg)])


func _delete_selected_seg() -> void:
	if _selected_seg < 0 or _selected_seg >= _track_segments.size():
		return
	if _track_segments.size() <= 1:
		_flash_status("至少保留一段初始直线；可用「重置为初始直线」")
		return
	_track_segments.remove_at(_selected_seg)
	_selected_seg = mini(_selected_seg, _track_segments.size() - 1)
	_dirty = true
	_refresh_seg_list()
	_rebuild_path_preview()


func _clear_track_segments() -> void:
	_reset_to_initial_straight(true)


func _reset_to_initial_straight(flash: bool = true) -> void:
	_track_segments = [ObstacleLayout.normalize_track_segment({
		"length": DEFAULT_SEG_LENGTH,
		"turn": 0.0,
	})]
	_junctions = []
	_side_zones = []
	_sand_zones = []
	_items.clear()
	_selected_seg = 0
	_selected_fork = -1
	_selected_side = -1
	_selected_sand = -1
	_selected = -1
	_dirty = true
	if _seg_len_spin:
		_seg_len_spin.set_value_no_signal(DEFAULT_SEG_LENGTH)
	if _seg_turn_spin:
		_seg_turn_spin.set_value_no_signal(0.0)
	if _next_seg_len_spin:
		_next_seg_len_spin.set_value_no_signal(DEFAULT_SEG_LENGTH)
	_refresh_seg_list()
	_refresh_fork_list()
	_refresh_side_list()
	_refresh_sand_list()
	_refresh_list()
	_refresh_markers()
	_rebuild_path_preview()
	_set_cursor_d(_path_length)
	if flash:
		_flash_status("已重置为初始直线（%.0fm）· 障碍已清空 · 点尽头「＋」接下一段" % DEFAULT_SEG_LENGTH)


func _load_default_track_segments() -> void:
	_track_segments = _planet_default_track_segments()
	_selected_seg = -1
	_dirty = true
	_refresh_seg_list()
	_rebuild_path_preview()
	_flash_status("已载入星球默认路线（未保存）")


func _jump_cursor_to_segment(index: int, into_segment: bool = false) -> void:
	if index < 0 or index >= _track_segments.size():
		return
	var d := 0.0
	for i in index:
		d += float((_track_segments[i] as Dictionary).get("length", 0.0))
	if into_segment:
		var length := float((_track_segments[index] as Dictionary).get("length", 0.0))
		# 跳到段内前段，方便看见转弯
		d += clampf(length * 0.35, 8.0, minf(length * 0.8, 28.0))
	_set_cursor_d(d)


func _refresh_seg_list() -> void:
	if _seg_list == null:
		return
	_seg_list.clear()
	var acc := 0.0
	for i in _track_segments.size():
		var s: Dictionary = _track_segments[i]
		var length := float(s.get("length", 0.0))
		var kind := "直"
		var detail := ""
		if ObstacleLayout.is_y_fork_segment(s):
			kind = "Y分叉"
			var ang := rad_to_deg(float(s.get("angle", deg_to_rad(45.0))))
			var branch := float(s.get("branch_length", length * 0.5))
			detail = "  支路%.0f ±%.0f°" % [branch, ang]
		else:
			var turn_deg := rad_to_deg(float(s.get("turn", 0.0)))
			if turn_deg > 0.5:
				kind = "左拐"
			elif turn_deg < -0.5:
				kind = "右拐"
			detail = "  转%+.0f°" % turn_deg
		_seg_list.add_item("%02d  %s  长%.0f%s  @%.0f→%.0f" % [
			i, kind, length, detail, acc, acc + length,
		])
		acc += length
	if _selected_seg >= 0 and _selected_seg < _track_segments.size():
		_seg_list.select(_selected_seg)


func _add_fork_at_cursor() -> void:
	_junctions.append(ObstacleLayout.normalize_junction_zone({
		"distance": snappedf(_cursor_d, 1.0),
		"length": float(_fork_len_spin.value),
		"spread": float(_fork_spread_spin.value),
		"lane_a": 0,
		"label_a": "安全岔路",
		"effect_a": "repair",
		"lane_b": 2,
		"label_b": "速通岔路",
		"effect_b": "fast",
	}))
	_junctions = ObstacleLayout.sort_junction_zones(_junctions)
	_selected_fork = -1
	for i in _junctions.size():
		if absf(float((_junctions[i] as Dictionary).get("distance", 0.0)) - _cursor_d) < 0.6:
			_selected_fork = i
			break
	_dirty = true
	_refresh_fork_list()
	_refresh_fork_visuals()
	_rebuild_track_mesh()
	_update_status()
	_flash_status("已在 %.0fm 添加分叉" % _cursor_d)


func _apply_fork_params_to_selected() -> void:
	if _selected_fork < 0 or _selected_fork >= _junctions.size():
		return
	var z: Dictionary = (_junctions[_selected_fork] as Dictionary).duplicate(true)
	z["length"] = float(_fork_len_spin.value)
	z["spread"] = float(_fork_spread_spin.value)
	_junctions[_selected_fork] = ObstacleLayout.normalize_junction_zone(z)
	_dirty = true
	_refresh_fork_list()
	_refresh_fork_visuals()
	_rebuild_track_mesh()
	_update_status()


func _delete_selected_fork() -> void:
	if _selected_fork < 0 or _selected_fork >= _junctions.size():
		return
	_junctions.remove_at(_selected_fork)
	_selected_fork = mini(_selected_fork, _junctions.size() - 1)
	_dirty = true
	_refresh_fork_list()
	_refresh_fork_visuals()
	_rebuild_track_mesh()
	_update_status()


func _clear_junctions() -> void:
	_junctions.clear()
	_selected_fork = -1
	_dirty = true
	_refresh_fork_list()
	_refresh_fork_visuals()
	_rebuild_track_mesh()
	_update_status()
	_flash_status("已清空全部分叉")


func _load_default_junctions() -> void:
	_junctions = _planet_default_junctions()
	_selected_fork = -1
	_dirty = true
	_refresh_fork_list()
	_refresh_fork_visuals()
	_rebuild_track_mesh()
	_update_status()
	_flash_status("已载入星球默认分叉（未保存）")


func _refresh_fork_list() -> void:
	if _fork_list == null:
		return
	_fork_list.clear()
	for i in _junctions.size():
		var z: Dictionary = _junctions[i]
		_fork_list.add_item("%02d  @%.0f  长%.0f  开度%.0f  %s|%s" % [
			i,
			float(z.get("distance", 0.0)),
			float(z.get("length", DEFAULT_FORK_LENGTH)),
			float(z.get("spread", DEFAULT_FORK_SPREAD)),
			String(z.get("label_a", "A")),
			String(z.get("label_b", "B")),
		])
	if _selected_fork >= 0 and _selected_fork < _junctions.size():
		_fork_list.select(_selected_fork)


func _refresh_fork_visuals() -> void:
	if _fork_root == null:
		return
	while _fork_root.get_child_count() > 0:
		_fork_root.get_child(0).free()
	for i in _junctions.size():
		var z: Dictionary = _junctions[i]
		_fork_root.add_child(_make_fork_zone_visual(z, i == _selected_fork))


func _make_fork_zone_visual(zone: Dictionary, selected: bool) -> Node3D:
	var root := Node3D.new()
	var start := float(zone.get("distance", 0.0))
	var length := float(zone.get("length", DEFAULT_FORK_LENGTH))
	var spread := float(zone.get("spread", DEFAULT_FORK_SPREAD))
	var steps := maxi(2, int(ceil(length / 6.0)))
	for s in steps + 1:
		var t := float(s) / float(steps)
		var d := start + length * t
		var envelope := sin(PI * t)
		var offset := spread * envelope
		for side_f in [-1.0, 1.0]:
			var mi := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(1.1 if selected else 0.7, 0.12, 2.2)
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0.2, 0.95, 0.55, 0.75) if selected else Color(0.15, 0.7, 0.45, 0.45)
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.emission_enabled = selected
			if selected:
				mat.emission = Color(0.2, 1.0, 0.5)
				mat.emission_energy_multiplier = 1.4
			mi.mesh = mesh
			mi.material_override = mat
			var sample := _sample_path(d)
			var lat: float = float(side_f) * (LANE_WIDTH + offset)
			mi.position = (sample["pos"] as Vector3) + (sample["right"] as Vector3) * lat + Vector3(0, GROUND_Y + 0.05, 0)
			mi.rotation.y = float(sample["yaw"])
			root.add_child(mi)
	# 入口旗标
	var flag := MeshInstance3D.new()
	var flag_mesh := BoxMesh.new()
	flag_mesh.size = Vector3(0.4, 3.2, 0.4)
	var flag_mat := StandardMaterial3D.new()
	flag_mat.albedo_color = Color(0.3, 1.0, 0.6)
	flag_mat.emission_enabled = true
	flag_mat.emission = Color(0.2, 1.0, 0.5)
	flag_mat.emission_energy_multiplier = 2.0
	flag.mesh = flag_mesh
	flag.material_override = flag_mat
	var start_sample := _sample_path(start)
	flag.position = (start_sample["pos"] as Vector3) + Vector3(0, GROUND_Y + 1.6, 0)
	root.add_child(flag)
	return root


func _refresh_sand_visuals() -> void:
	if _sand_root == null:
		return
	while _sand_root.get_child_count() > 0:
		_sand_root.get_child(0).free()
	for i in _sand_zones.size():
		var z: Dictionary = _sand_zones[i]
		_sand_root.add_child(_make_sand_zone_visual(z, i == _selected_sand))


func _make_sand_zone_visual(zone: Dictionary, selected: bool) -> Node3D:
	var root := Node3D.new()
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", DEFAULT_SAND_LENGTH))
	var covered: Array = zone.get("covered_lanes", [-1, 0, 1])
	if covered.is_empty():
		covered = [-1, 0, 1]
	var min_lane := int(covered[0])
	var max_lane := int(covered[0])
	for v in covered:
		min_lane = mini(min_lane, int(v))
		max_lane = maxi(max_lane, int(v))
	var bias := (float(min_lane) + float(max_lane)) * 0.5 * LANE_WIDTH
	var half_w := (float(max_lane - min_lane) + 1.0) * LANE_WIDTH * 0.5 + 0.6
	var mat := StandardMaterial3D.new()
	var col := Color(1.0, 0.72, 0.25, 0.42) if selected else Color(0.92, 0.55, 0.18, 0.28)
	mat.albedo_color = col
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.55, 0.15)
	mat.emission_energy_multiplier = 1.2 if selected else 0.55
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step := 2.0
	var d := start
	var end_d := start + length
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	var has_prev := false
	while d <= end_d + 0.001:
		var sample := _sample_path(minf(d, _path_length))
		var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * bias
		var right: Vector3 = sample["right"]
		var l := origin - right * half_w
		var r := origin + right * half_w
		l.y = GROUND_Y + 0.12
		r.y = GROUND_Y + 0.12
		if has_prev:
			st.set_normal(Vector3.UP)
			st.add_vertex(prev_l)
			st.add_vertex(prev_r)
			st.add_vertex(r)
			st.add_vertex(prev_l)
			st.add_vertex(r)
			st.add_vertex(l)
		prev_l = l
		prev_r = r
		has_prev = true
		if d >= end_d:
			break
		d = minf(d + step, end_d)
	var mesh := st.commit()
	if mesh:
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.material_override = mat
		root.add_child(mi)
	var label := Label3D.new()
	label.text = "%s\n%s · %.0fm" % [
		String(zone.get("label", "沙尘暴")),
		_covered_lanes_label(covered),
		length,
	]
	label.font_size = 40
	label.modulate = Color(1.0, 0.85, 0.45)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	var mid := _sample_path(start + length * 0.5)
	label.position = (mid["pos"] as Vector3) + (mid["right"] as Vector3) * bias + Vector3(0, 2.4, 0)
	root.add_child(label)
	return root


func _set_cursor_d(d: float, sync_controls: bool = true) -> void:
	_cursor_d = clampf(d, 0.0, maxf(_path_length, 1.0))
	if sync_controls:
		if _dist_slider:
			_dist_slider.set_value_no_signal(_cursor_d)
		if _dist_spin:
			_dist_spin.set_value_no_signal(_cursor_d)
	else:
		if _dist_slider and absf(_dist_slider.value - _cursor_d) > 0.01:
			_dist_slider.set_value_no_signal(_cursor_d)
		if _dist_spin and absf(_dist_spin.value - _cursor_d) > 0.01:
			_dist_spin.set_value_no_signal(_cursor_d)
	if _track_panel and _track_panel.has_meta("pending_dist_spin"):
		var pending: SpinBox = _track_panel.get_meta("pending_dist_spin")
		if pending and absf(pending.value - _cursor_d) > 0.01:
			pending.set_value_no_signal(_cursor_d)
	_update_cursor_marker()
	_update_status()


func _set_lane_index(idx: int) -> void:
	_lane_index = clampi(idx, 0, 2)
	if _lane_option and _lane_option.selected != _lane_index:
		_lane_option.select(_lane_index)
	_update_cursor_marker()
	_update_status()


func _set_place_type(t: String) -> void:
	_place_type = t
	_update_status()


func _lane_value_to_index(lane: int) -> int:
	if lane < 0:
		return 0
	if lane > 0:
		return 2
	return 1


func _lane_index_to_value(idx: int) -> int:
	return int(LANES[clampi(idx, 0, 2)])


func _update_cursor_marker() -> void:
	if _cursor_marker == null:
		return
	var lane_v := _lane_index_to_value(_lane_index)
	var sample := _sample_path(_cursor_d)
	_cursor_marker.position = _world_on_path(_cursor_d, lane_v) + Vector3(0.0, 0.08, 0.0)
	_cursor_marker.rotation.y = float(sample["yaw"])


func _update_end_add_affordance() -> void:
	var show := _edit_mode == EDIT_MODE_TRACK and _camera != null and _path_length > 0.5
	if _end_add_marker:
		_end_add_marker.visible = show
		if show:
			var sample_m := _sample_path(_path_length)
			var pos_m: Vector3 = sample_m["pos"]
			var fwd_m: Vector3 = sample_m["forward"]
			_end_add_marker.global_position = pos_m + Vector3(0.0, 0.25, 0.0) + fwd_m * 2.2
			_end_add_marker.rotation.y = float(sample_m["yaw"])
	if _end_add_btn == null:
		return
	if not show:
		_end_add_btn.visible = false
		return
	var sample := _sample_path(_path_length)
	var world: Vector3 = sample["pos"] + Vector3.UP * 3.2 + sample["forward"] * 1.5
	if _camera.is_position_behind(world):
		_end_add_btn.visible = false
		return
	var screen := _camera.unproject_position(world)
	_end_add_btn.visible = true
	var sz := _end_add_btn.size
	if sz.x < 2.0 or sz.y < 2.0:
		sz = _end_add_btn.get_combined_minimum_size()
	_end_add_btn.position = screen - Vector2(sz.x * 0.5, sz.y * 0.5)


func _open_piece_picker() -> void:
	if _edit_mode != EDIT_MODE_TRACK:
		_flash_status("请切到「① 拼赛道」再添加路段")
		return
	if _piece_picker == null:
		return
	_set_cursor_d(_path_length)
	_piece_picker.popup_centered(Vector2(280, 420))


func _close_piece_picker() -> void:
	if _piece_picker and _piece_picker.visible:
		_piece_picker.hide()


func _pick_piece_straight() -> void:
	_close_piece_picker()
	var length := float(_next_seg_len_spin.value) if _next_seg_len_spin else DEFAULT_SEG_LENGTH
	_add_track_segment(length, 0.0, "append")


func _pick_piece_turn(length: float, turn_deg: float) -> void:
	_close_piece_picker()
	_add_track_segment(length, turn_deg, "append")


func _pick_piece_fork() -> void:
	_close_piece_picker()
	_add_y_fork_segment()


func _add_y_fork_segment() -> void:
	var branch := DEFAULT_Y_FORK_BRANCH
	if _next_seg_len_spin:
		branch = maxf(float(_next_seg_len_spin.value) * 0.5, 20.0)
	elif _fork_len_spin:
		branch = maxf(float(_fork_len_spin.value) * 0.5, 20.0)
	var seg := ObstacleLayout.normalize_track_segment({
		"type": "y_fork",
		"branch_length": branch,
		"angle_deg": DEFAULT_Y_FORK_ANGLE_DEG,
	})
	_track_segments.append(seg)
	_selected_seg = _track_segments.size() - 1
	if _seg_len_spin:
		_seg_len_spin.set_value_no_signal(branch)
	if _seg_turn_spin:
		_seg_turn_spin.set_value_no_signal(DEFAULT_Y_FORK_ANGLE_DEG)
	_dirty = true
	_refresh_seg_list()
	_rebuild_path_preview()
	_jump_cursor_to_segment(_selected_seg, true)
	_flash_status("已添加 Y 分叉：±%.0f° 斜出再汇合，可再接直线" % DEFAULT_Y_FORK_ANGLE_DEG)


func _pick_piece_side() -> void:
	_close_piece_picker()
	_set_cursor_d(maxf(0.0, _path_length - 10.0))
	_add_side_zone_at_cursor()


func _update_camera() -> void:
	if _camera == null:
		return
	var sample := _sample_path(_cursor_d)
	var pos: Vector3 = sample["pos"]
	var forward: Vector3 = sample["forward"]
	var right: Vector3 = sample["right"]
	# 拼赛道时拉高看清整段；摆障碍时略近
	var back := 22.0 if _edit_mode == EDIT_MODE_TRACK else 8.5
	var up := 14.0 if _edit_mode == EDIT_MODE_TRACK else 5.2
	var look_ahead := 16.0 if _edit_mode == EDIT_MODE_TRACK else 8.0
	var cam_pos := pos - forward * back + Vector3(0.0, up, 0.0) + right * 1.6
	_camera.global_position = cam_pos
	_camera.look_at(pos + forward * look_ahead + Vector3(0.0, 0.4, 0.0), Vector3.UP)


func _update_status() -> void:
	if _status == null:
		return
	var flag := " *" if _dirty else ""
	var phase := "拼赛道" if _edit_mode == EDIT_MODE_TRACK else "摆障碍"
	var tip := "点尽头「＋」/Space 选下一段 · Ctrl+P 试玩 · Tab 切阶段" if _edit_mode == EDIT_MODE_TRACK else "左键放置/拖拽 · Space 放置 · Ctrl+P 试玩 · Tab 切阶段"
	_status.text = "[%s] %s%s | d=%.0f | 跑道=%s\n路段 %d · 分叉 %d · 侧墙 %d · 障碍 %d · 沙尘 %d → 下次 %s\n%s · Ctrl+S 保存" % [
		phase,
		_planet_id,
		flag,
		_cursor_d,
		EditorRoadPreview.style_label(_road_style_id),
		_track_segments.size(),
		_junctions.size(),
		_side_zones.size(),
		_items.size(),
		_sand_zones.size(),
		CustomLevels.format_name(CustomLevels.next_sequence()),
		tip,
	]


func _place_at_cursor() -> void:
	if _edit_mode != EDIT_MODE_OBSTACLES:
		_flash_status("请先切到「② 摆障碍」再放置")
		return
	var item := {
		"type": _place_type,
		"lane": _lane_index_to_value(_lane_index),
		"distance": snappedf(_cursor_d, 1.0),
	}
	if _place_type == "ramp":
		item["target_layer"] = 1
		item["layer"] = 0
	elif _place_type == "main_block":
		item["half_depth"] = 26.0
		item["layer"] = 0
		item["lane"] = 0
	elif _place_type == "train_moving":
		item["move_speed"] = -10.0
	_items.append(ObstacleLayout.normalize_item(item))
	_items = ObstacleLayout.sort_items(_items)
	var auto_note := ""
	if _place_type == "main_block":
		auto_note = _ensure_side_support_for_main_block(ObstacleLayout.normalize_item(item))
	_dirty = true
	_selected = _find_nearest_index(float(item["distance"]), int(item.get("lane", 0)), String(item["type"]))
	_refresh_markers()
	_refresh_list()
	_refresh_side_list()
	_refresh_side_visuals()
	_update_status()
	if auto_note != "":
		_flash_status(auto_note)


func _ensure_side_support_for_main_block(main_block: Dictionary) -> String:
	# 放置 main_block 时自动配套侧墙 + 入口跳板，否则无法通过
	var choice := _current_side_choice()
	var notes: PackedStringArray = PackedStringArray()
	var covered := false
	for z in _side_zones:
		if ObstacleLayout.side_zone_covers_main_block(z, main_block):
			covered = true
			break
	var zone: Dictionary
	if covered:
		# 找到覆盖它的区，补 ramp 即可
		for z2 in _side_zones:
			if ObstacleLayout.side_zone_covers_main_block(z2, main_block):
				zone = z2
				break
	else:
		zone = ObstacleLayout.side_zone_from_main_block(main_block, choice)
		_side_zones.append(zone)
		_side_zones = ObstacleLayout.sort_side_zones(_side_zones)
		notes.append("侧墙")
	if zone.is_empty():
		return ""
	var ramp_d := ObstacleLayout.ramp_distance_for_side_zone(zone)
	var has_ramp := false
	for it in _items:
		if typeof(it) != TYPE_DICTIONARY:
			continue
		if String(it.get("type", "")) != "ramp":
			continue
		if absf(float(it.get("distance", 0.0)) - ramp_d) <= 8.0:
			has_ramp = true
			break
	if not has_ramp:
		_items.append(ObstacleLayout.normalize_item({
			"type": "ramp",
			"lane": 0,
			"distance": ramp_d,
			"target_layer": 1,
			"layer": 0,
		}))
		_items = ObstacleLayout.sort_items(_items)
		notes.append("入口跳板")
	if notes.is_empty():
		return "main_block 已有配套侧墙"
	return "已为 main_block 自动添加：%s（需贴墙上墙绕过）" % " + ".join(notes)


func _find_nearest_index(distance: float, lane: int, otype: String) -> int:
	var best := -1
	var best_score := INF
	for i in _items.size():
		var it: Dictionary = _items[i]
		if String(it.get("type", "")) != otype:
			continue
		if int(it.get("lane", 0)) != lane:
			continue
		var score := absf(float(it.get("distance", 0.0)) - distance)
		if score < best_score:
			best_score = score
			best = i
	return best


func _delete_selected() -> void:
	if _selected < 0 or _selected >= _items.size():
		return
	_items.remove_at(_selected)
	_selected = mini(_selected, _items.size() - 1)
	_dirty = true
	_refresh_markers()
	_refresh_list()
	_update_status()


func _save_layout() -> void:
	_items = ObstacleLayout.sort_items(_items)
	var duration := 65.0
	if LevelConfig != null and LevelConfig.get("MISSION") != null:
		duration = float(LevelConfig.MISSION.get("duration", 65.0))
	var entry := CustomLevels.create_level(_planet_id, _items, {
		"duration": duration,
		"task_type": "Supply Run",
		"base_planet_id": _planet_id,
		"side_runway_zones": _side_zones,
		"sandstorm_zones": _sand_zones,
		"track_segments": _track_segments,
		"junction_zones": _junctions,
		"road_style": _road_style_id,
	})
	var ok := not entry.is_empty()
	_dirty = not ok
	_refresh_list()
	_refresh_custom_level_ui()
	_update_status()
	if ok:
		_flash_status("已上架关卡：%s（%s）· 障碍 %d · 路段 %d" % [
			String(entry.get("name", "")),
			String(entry.get("id", "")),
			_items.size(),
			_track_segments.size(),
		])
	else:
		_flash_status("保存失败")


func _playtest_layout() -> void:
	_items = ObstacleLayout.sort_items(_items)
	var duration := 65.0
	if LevelConfig != null and LevelConfig.get("MISSION") != null:
		duration = float(LevelConfig.MISSION.get("duration", 65.0))
	# 短轨试玩：按已拼路程估时长，避免被任务全长拖太久
	var path_len := maxf(_path_length, 40.0)
	var estimated := clampf(path_len / 12.0 + 8.0, 20.0, duration)
	var entry := CustomLevels.save_playtest(_planet_id, _items, {
		"duration": estimated,
		"task_type": "Supply Run",
		"base_planet_id": _planet_id,
		"side_runway_zones": _side_zones,
		"sandstorm_zones": _sand_zones,
		"track_segments": _track_segments,
		"junction_zones": _junctions,
		"road_style": _road_style_id,
	})
	if entry.is_empty():
		_flash_status("试玩失败：无法写入草稿（检查 data 目录写权限）")
		return
	Global.runner_planet_id = _planet_id
	Global.runner_location_id = CustomLevels.PLAYTEST_ID
	Global.runner_return_scene = CustomLevels.EDITOR_SCENE
	Global.set_runner_road_style(_road_style_id)
	_flash_status("正在进入试玩…")
	Global.change_game_scene(PlanetDatabase.RUNNER_SCENE)


func _refresh_custom_level_ui() -> void:
	var hint := find_child("NextLevelHint", true, false) as Label
	if hint:
		var next_seq := CustomLevels.next_sequence()
		hint.text = "下次保存将创建：%s（%s）" % [
			CustomLevels.format_name(next_seq),
			CustomLevels.format_id(next_seq),
		]
	var custom_list := find_child("CustomLevelList", true, false) as ItemList
	if custom_list:
		_refresh_custom_level_list(custom_list)


func _refresh_custom_level_list(custom_list: ItemList) -> void:
	custom_list.clear()
	for level in CustomLevels.list_levels():
		custom_list.add_item("%s · %s · %d障碍 · %d路段 · %d分叉 · %s" % [
			String(level.get("name", "?")),
			String(level.get("id", "")),
			int(level.get("obstacle_count", 0)),
			int(level.get("track_segment_count", 0)),
			int(level.get("junction_count", 0)),
			String(level.get("planet_id", "")),
		])
		custom_list.set_item_metadata(custom_list.item_count - 1, String(level.get("id", "")))


func _load_custom_level_by_list_index(index: int) -> void:
	var custom_list := find_child("CustomLevelList", true, false) as ItemList
	if custom_list == null or index < 0 or index >= custom_list.item_count:
		return
	var level_id := String(custom_list.get_item_metadata(index))
	if level_id.is_empty():
		return
	var level := CustomLevels.get_level(level_id)
	var base_planet := String(level.get("planet_id", _planet_id))
	if base_planet != _planet_id:
		_planet_id = base_planet
		for i in _planet_option.item_count:
			if _planet_option.get_item_text(i) == base_planet:
				_planet_option.select(i)
				break
		LevelConfig = PlanetDatabase.get_runner_config(_planet_id)
		_visual_factory.configure_from_level_config(LevelConfig)
		var duration := 65.0
		if LevelConfig != null and LevelConfig.get("MISSION") != null:
			duration = float(LevelConfig.MISSION.get("duration", 65.0))
		_track_length = MissionTypes.track_length_for(duration)
	_items = CustomLevels.load_obstacles(level_id)
	_side_zones = CustomLevels.load_side_runway_zones(level_id)
	_sand_zones = CustomLevels.load_sandstorm_zones(level_id)
	var segs := CustomLevels.load_track_segments(level_id)
	if segs.is_empty():
		_track_segments = _planet_default_track_segments()
	else:
		_track_segments = segs
	if CustomLevels.has_custom_junctions(level_id):
		_junctions = CustomLevels.load_junction_zones(level_id)
	else:
		_junctions = _planet_default_junctions()
	var saved_style := CustomLevels.load_road_style(level_id)
	if saved_style != "":
		_road_style_id = EditorRoadPreview.normalize_style(saved_style)
	else:
		_road_style_id = EditorRoadPreview.normalize_style(String(Global.get_runner_road_style()))
	_select_road_style_option(_road_style_id)
	_bake_path()
	_rebuild_track_mesh()
	_dirty = false
	_selected = -1
	_selected_side = -1
	_selected_sand = -1
	_selected_seg = -1
	_selected_fork = -1
	_refresh_all()
	_flash_status("已载入 %s（再保存会新建下一关，不会覆盖）" % String(level.get("name", level_id)))


func _reload_layout() -> void:
	_load_planet(_planet_id)
	_refresh_all()
	_flash_status("已重新加载")


func _load_defaults_from_code() -> void:
	if LevelConfig != null and LevelConfig.has_method("_default_obstacles"):
		_items = ObstacleLayout.sort_items(LevelConfig._default_obstacles())
	elif _planet_id == "glass_desert" or LevelConfig != null:
		# rust/savanna 无独立默认时回退玻璃沙漠默认
		var GlassDesert = load("res://assets/maps/route_levels/planets/planet_glass_desert.gd")
		if GlassDesert and GlassDesert.has_method("_default_obstacles"):
			_items = ObstacleLayout.sort_items(GlassDesert._default_obstacles())
	_dirty = true
	_selected = -1
	_refresh_all()
	_flash_status("已载入代码默认障碍表（未保存）")


func _flash_status(msg: String) -> void:
	if _status:
		_status.text = msg + "\n" + _status.text


func _ray_from_mouse(screen_pos: Vector2) -> Dictionary:
	var from := _camera.project_ray_origin(screen_pos)
	var dir := _camera.project_ray_normal(screen_pos)
	# 与地面 y=GROUND_Y 求交
	if absf(dir.y) < 0.0001:
		return {}
	var t := (GROUND_Y - from.y) / dir.y
	if t < 0.0:
		return {}
	var hit: Vector3 = from + dir * t
	return {"pos": hit}


func _nearest_distance_to_point(world: Vector3) -> float:
	var best_d := 0.0
	var best_score := INF
	var step := 2.0
	var d := 0.0
	while d <= _path_length:
		var sample := _sample_path(d)
		var p: Vector3 = sample["pos"]
		p.y = GROUND_Y
		var score := p.distance_squared_to(world)
		if score < best_score:
			best_score = score
			best_d = d
		d += step
	# 局部细化
	for fine in range(-5, 6):
		var dd := clampf(best_d + float(fine) * 0.4, 0.0, _path_length)
		var sample2 := _sample_path(dd)
		var p2: Vector3 = sample2["pos"]
		p2.y = GROUND_Y
		var score2 := p2.distance_squared_to(world)
		if score2 < best_score:
			best_score = score2
			best_d = dd
	return best_d


func _nearest_lane_at(world: Vector3, distance: float) -> int:
	var sample := _sample_path(distance)
	var origin: Vector3 = sample["pos"]
	var right: Vector3 = sample["right"]
	var delta := world - origin
	delta.y = 0.0
	var lat: float = delta.dot(right)
	return _lane_index_to_value(_lane_value_to_index(int(round(lat / LANE_WIDTH))))


func _try_place_at_mouse(screen_pos: Vector2) -> bool:
	if _edit_mode != EDIT_MODE_OBSTACLES:
		return false
	var hit := _ray_from_mouse(screen_pos)
	if hit.is_empty():
		return false
	var world: Vector3 = hit["pos"]
	var d := _nearest_distance_to_point(world)
	# 太远则忽略（点到沙漠）
	var on_path: Vector3 = _sample_path(d)["pos"]
	if Vector2(world.x, world.z).distance_to(Vector2(on_path.x, on_path.z)) > 10.0:
		return false
	_set_cursor_d(d)
	var lane_v := _nearest_lane_at(world, d)
	_set_lane_index(_lane_value_to_index(lane_v))
	_place_at_cursor()
	return true


func _try_pick_marker(screen_pos: Vector2) -> bool:
	var hit := _ray_from_mouse(screen_pos)
	if hit.is_empty():
		return false
	var world: Vector3 = hit["pos"]
	var best := -1
	var best_score := 2.8 * 2.8
	for i in _items.size():
		var it: Dictionary = _items[i]
		var otype := String(it.get("type", ""))
		var lane_v := 0 if ObstacleVisualFactory.uses_center_lane(otype) else int(it.get("lane", 0))
		var p := _world_on_path(float(it.get("distance", 0.0)), lane_v)
		var score := p.distance_squared_to(world)
		if score < best_score:
			best_score = score
			best = i
	if best < 0:
		return false
	_selected = best
	_drag_index = best
	var it2: Dictionary = _items[best]
	_set_cursor_d(float(it2.get("distance", 0.0)))
	_set_lane_index(_lane_value_to_index(int(it2.get("lane", 0))))
	_refresh_markers()
	_refresh_list()
	return true


func _drag_marker_by_relative(relative: Vector2) -> void:
	if _drag_index < 0 or _drag_index >= _items.size():
		return
	if relative.length() < DRAG_DEADZONE_PX:
		return
	var it: Dictionary = _items[_drag_index]
	var d := float(it.get("distance", 0.0))
	var lane_v := int(it.get("lane", 0))
	var sample := _sample_path(d)
	var origin: Vector3 = sample["pos"]
	var forward: Vector3 = sample["forward"]
	var right: Vector3 = sample["right"]
	# 把路径切向/横向投影到屏幕，用相对位移分解，避免绝对射线透视放大
	var sp0 := _camera.unproject_position(origin)
	var sp_f := _camera.unproject_position(origin + forward * 8.0)
	var sp_r := _camera.unproject_position(origin + right * LANE_WIDTH)
	var screen_fwd := sp_f - sp0
	var screen_right := sp_r - sp0
	if screen_fwd.length_squared() < 0.0001:
		screen_fwd = Vector2(0.0, -1.0)
	else:
		screen_fwd = screen_fwd.normalized()
	if screen_right.length_squared() < 0.0001:
		screen_right = Vector2(1.0, 0.0)
	else:
		screen_right = screen_right.normalized()

	var sens := DRAG_DIST_PER_PX_FINE if Input.is_key_pressed(KEY_SHIFT) else DRAG_DIST_PER_PX
	d = clampf(d + relative.dot(screen_fwd) * sens, 0.0, _path_length)
	_drag_lane_accum += relative.dot(screen_right)
	if _drag_lane_accum >= DRAG_LANE_THRESHOLD_PX:
		lane_v = mini(lane_v + 1, 1)
		_drag_lane_accum = 0.0
	elif _drag_lane_accum <= -DRAG_LANE_THRESHOLD_PX:
		lane_v = maxi(lane_v - 1, -1)
		_drag_lane_accum = 0.0

	it["distance"] = snappedf(d, 1.0)
	it["lane"] = lane_v
	_items[_drag_index] = ObstacleLayout.normalize_item(it)
	_dirty = true
	_set_cursor_d(d)
	_set_lane_index(_lane_value_to_index(lane_v))
	# 拖拽中不重排，松手后再排
	_refresh_markers()
	_refresh_list()


func _try_delete_at_mouse(screen_pos: Vector2) -> bool:
	if not _try_pick_marker(screen_pos):
		return false
	_delete_selected()
	return true
