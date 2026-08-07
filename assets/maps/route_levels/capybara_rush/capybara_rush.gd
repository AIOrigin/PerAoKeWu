extends Node3D

## Capybara Rush 原型：Stack 叠塔 / 竞速冲锋。
## 打开 capybara_rush.tscn 后按 F6 运行。

const CapybaraTrackPathScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_track_path.gd")

const LANE_COUNT := 3
const LANE_WIDTH := 2.4
const ROAD_HALF_W := 4.2
const TRACK_LENGTH := 600.0  # ~50s @ RUN_SPEED 12
const RUN_SPEED := 12.0
const RACE_RUN_SPEED := 13.5
const TARGET_DURATION_SEC := 50.0
const LANE_LERP := 10.0
const BOB_AMP := 0.06
const BOB_FREQ := 9.0
## 模型高度（贴地后）；叠层间距略小于身高以便看起来踩在背上
const TARGET_CAPY_HEIGHT := 1.05
const TARGET_PILOT_HEIGHT := 1.55
const STACK_STEP_Y := 0.72
## 朝跑道前进 +Z（背对相机）；此前 PI/2 会朝向相机
const CAPY_FORWARD_YAW := -PI * 0.5
const QINGQING_FORWARD_YAW := -PI * 0.5
## Tripo 开飞船整模默认朝向与步行水豚不同，需单独校正为朝 +Z
const PILOT_FORWARD_YAW := 0.0
const SPACESHIP_FORWARD_YAW := 0.0
const CHAR_CAPYBARA := "capybara"
const CHAR_QINGQING := "qingqing"
const MODE_STACK := "stack"
const MODE_RACE := "race"
const PICKUP_RADIUS_X := 1.15
const PICKUP_RADIUS_Z := 1.4
## 竞速：碰飞船冲锋 5s；冲锋中撞障 -1s；加速包 +0.5s
const BOOST_DURATION := 5.0
const BOOST_HIT_PENALTY := 1.0
const BOOST_PACK_BONUS := 0.5
const BOOST_SPEED_MUL := 1.9
const BOOST_MAX_TIME := 12.0
## 跳跃 / 台阶 / 加速道具 / 加速赛道
const JUMP_SPEED := 8.2
const GRAVITY := 24.0
const JUMP_CLEAR_Y := 0.55
const SPEED_ORB_MUL := 1.45
const SPEED_ORB_DURATION := 3.0
const SPEED_LANE_MUL := 1.35
const PLATFORM_TOP_Y := 1.15
const PLATFORM_HALF_LEN := 2.2
## 晃动 / 掉层
## - ≥3 层：只要在移动（换道/滑动中）就有掉落概率
## - >8 层：概率大幅抬升
## - 撞障碍：必然掉 1 层（叠高≥2）
const VIOLENT_WINDOW_SEC := 1.0
const VIOLENT_MIN_CHANGES := 2
const MOVE_DROP_WINDOW_SEC := 0.85  # 最近一次换道仍算「在移动」
const MIN_STACK_TO_DROP := 3
const HIGH_STACK_THRESHOLD := 8
const DROP_COOLDOWN_BASE := 0.55
const DROP_COOLDOWN_MIN := 0.18
const DROP_COOLDOWN_SHRINK_PER_LAYER := 0.04
const MAX_LEAN := 0.55
## 仅用于视觉晃动（非掉落判定）
const SWAY_BUILD := 1.4
const SWAY_DECAY := 2.2

var _progress := 0.0
var _lane := 1
var _lane_x := 0.0
var _prev_lane_x := 0.0
var _finished := false
var _tower: Node3D
var _stack: Array[Node3D] = []
var _pickups: Array[Dictionary] = []
var _hazards: Array[Dictionary] = []
var _falling: Array[Dictionary] = []
var _sway := 0.0
var _drop_cd := 0.0
var _lane_change_times: Array[float] = []
var _cam: Camera3D
var _hud_label: Label
var _hud_tip: Label
var _world: Node3D
var _clouds: Array[Node3D] = []
var _character_id := CHAR_CAPYBARA
var _game_mode := MODE_STACK
var _playing := false
var _select_ui: CanvasLayer
var _mode_ui: CanvasLayer
var _result_ui: CanvasLayer
var _select_spin_pivots: Array[Node3D] = []
var _collision_count := 0
var _drop_count := 0
var _picked_count := 0
var _ship_count := 0
var _boost_pack_count := 0
## 拾取插入动画：旧塔跳起 → 新单位钻到底
var _stack_animating := false
var _pending_pickup_holders: Array[Node3D] = []
const PICKUP_JUMP_EXTRA := 0.28
const PICKUP_ANIM_JUMP_SEC := 0.26
const PICKUP_ANIM_SLIDE_SEC := 0.32
const PICKUP_ANIM_SETTLE_SEC := 0.22
## 青青开场转一圈展示
var _intro_showcasing := false
const INTRO_SPIN_SEC := 2.4
## 竞速冲锋
var _boosting := false
var _boost_time_left := 0.0
var _spaceships: Array[Dictionary] = []
var _boost_packs: Array[Dictionary] = []
var _race_visual: Node3D
## 弯道 / 跳跃 / 加速
var _path # CapybaraTrackPathScript
var _air_y := 0.0
var _vel_y := 0.0
var _grounded := true
var _ground_y := 0.0
var _on_platform := false
var _speed_buff_left := 0.0
var _on_speed_lane := false
var _platforms: Array[Dictionary] = []
var _speed_orbs: Array[Dictionary] = []
var _speed_lanes: Array[Dictionary] = []
var _path_yaw := 0.0


func _ready() -> void:
	_world = Node3D.new()
	_world.name = "World"
	add_child(_world)
	_setup_environment()
	_build_path_and_track()
	_scatter_props()
	_spawn_clouds()
	_spawn_platforms()
	_spawn_speed_orbs()
	_spawn_speed_lanes()
	_setup_camera()
	_setup_hud()
	_setup_character_select()
	_lane_x = _lane_to_x(_lane)


func _unhandled_input(event: InputEvent) -> void:
	# Esc：游戏中 / 开场 / 结算 / 模式选择 均可回角色选择
	if _select_ui == null and (
		event.is_action_pressed("ui_cancel") or _key_pressed(event, KEY_ESCAPE)
	):
		get_tree().reload_current_scene()
		return
	if _mode_ui != null or _select_ui != null:
		return
	if not _playing:
		return
	if _finished:
		if event.is_action_pressed("ui_accept") or _key_pressed(event, KEY_R):
			get_tree().reload_current_scene()
		return
	if event.is_action_pressed("ui_left") or _key_pressed(event, KEY_A) or _key_pressed(event, KEY_LEFT):
		_try_change_lane(1)
	elif event.is_action_pressed("ui_right") or _key_pressed(event, KEY_D) or _key_pressed(event, KEY_RIGHT):
		_try_change_lane(-1)
	elif (
		event.is_action_pressed("ui_accept")
		or event.is_action_pressed("ui_up")
		or _key_pressed(event, KEY_SPACE)
		or _key_pressed(event, KEY_W)
		or _key_pressed(event, KEY_UP)
	):
		_try_jump()


func _try_change_lane(delta_lane: int) -> void:
	var next := clampi(_lane + delta_lane, 0, LANE_COUNT - 1)
	var now := Time.get_ticks_msec() * 0.001
	if next == _lane:
		# 顶在边道仍左右猛按，也算晃动意图
		_lane_change_times.append(now)
		return
	_lane = next
	_lane_change_times.append(now)


func _key_pressed(event: InputEvent, code: Key) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == code


func _process(delta: float) -> void:
	_update_falling(delta)
	_update_clouds(delta)
	if _select_ui != null:
		_spin_select_previews(delta)
		return
	if _mode_ui != null:
		return
	if _intro_showcasing:
		_update_intro_camera(delta)
		return
	if not _playing:
		return
	if _finished:
		return
	if _game_mode == MODE_RACE:
		_update_boost(delta)
	_update_speed_buff(delta)
	_update_jump(delta)
	_refresh_speed_lane_state()
	var speed := _current_run_speed()
	var track_len := _track_len()
	_progress = minf(_progress + speed * delta, track_len)
	_prev_lane_x = _lane_x
	_lane_x = lerpf(_lane_x, _lane_to_x(_lane), 1.0 - exp(-LANE_LERP * delta))
	_update_sway(delta)
	_update_tower_motion()
	_try_collect_speed_orbs()
	if _game_mode == MODE_STACK:
		_update_pickup_bob()
		_try_collect_pickups()
		_try_hit_hazards()
		_try_drop_layers(delta)
	else:
		_update_boost_pack_bob()
		_try_collect_spaceships()
		_try_collect_boost_packs()
		_try_hit_hazards_race()
	_update_camera()
	_update_hud()
	if _progress >= track_len - 0.5:
		_finished = true
		_show_result_screen()


func _track_len() -> float:
	if _path != null and _path.length > 1.0:
		return _path.length
	return TRACK_LENGTH


func _try_jump() -> void:
	if not _grounded or _finished:
		return
	_grounded = false
	_on_platform = false
	_vel_y = JUMP_SPEED


func _update_jump(delta: float) -> void:
	var platform_y := _platform_top_under_player()
	var floor_y := platform_y if platform_y >= 0.0 else 0.0
	if _grounded:
		_ground_y = floor_y
		_air_y = floor_y
		_vel_y = 0.0
		# 走出台阶则落下
		if _on_platform and platform_y < 0.0:
			_grounded = false
			_on_platform = false
			_vel_y = -0.5
		return
	_vel_y -= GRAVITY * delta
	_air_y += _vel_y * delta
	if _vel_y <= 0.0 and _air_y <= floor_y + 0.02:
		_air_y = floor_y
		_vel_y = 0.0
		_grounded = true
		_ground_y = floor_y
		_on_platform = platform_y >= 0.0


func _platform_top_under_player() -> float:
	## 脚下有台阶返回顶面高度，否则 -1
	for p in _platforms:
		var dist: float = float(p.get("dist", -999.0))
		var lateral: float = float(p.get("lateral", 0.0))
		if absf(dist - _progress) > PLATFORM_HALF_LEN:
			continue
		if absf(lateral - _lane_x) > LANE_WIDTH * 0.62:
			continue
		return float(p.get("top_y", PLATFORM_TOP_Y))
	return -1.0


func _update_speed_buff(delta: float) -> void:
	if _speed_buff_left > 0.0:
		_speed_buff_left = maxf(_speed_buff_left - delta, 0.0)


func _refresh_speed_lane_state() -> void:
	_on_speed_lane = false
	if not _grounded:
		return
	for lane in _speed_lanes:
		var d0: float = float(lane.get("dist0", 0.0))
		var d1: float = float(lane.get("dist1", 0.0))
		var lateral: float = float(lane.get("lateral", 0.0))
		if _progress < d0 or _progress > d1:
			continue
		if absf(lateral - _lane_x) > LANE_WIDTH * 0.55:
			continue
		_on_speed_lane = true
		return


func _current_run_speed() -> float:
	var base := RACE_RUN_SPEED if _is_race() else RUN_SPEED
	var mul := 1.0
	if _is_race() and _boosting:
		mul *= BOOST_SPEED_MUL
	if _speed_buff_left > 0.0:
		mul *= SPEED_ORB_MUL
	if _on_speed_lane:
		mul *= SPEED_LANE_MUL
	return base * mul


func _is_race() -> bool:
	return _game_mode == MODE_RACE


func _is_airborne_clear() -> bool:
	return (not _grounded) and (_air_y - _ground_y) >= JUMP_CLEAR_Y


func _layers_above_min() -> int:
	return maxi(_stack.size() - MIN_STACK_TO_DROP, 0)


func _drop_cooldown() -> float:
	return maxf(
		DROP_COOLDOWN_BASE - float(_layers_above_min()) * DROP_COOLDOWN_SHRINK_PER_LAYER,
		DROP_COOLDOWN_MIN
	)


func _prune_lane_changes(window_sec: float) -> void:
	var now := Time.get_ticks_msec() * 0.001
	while not _lane_change_times.is_empty() and now - _lane_change_times[0] > window_sec:
		_lane_change_times.remove_at(0)


func _is_violent_move() -> bool:
	_prune_lane_changes(VIOLENT_WINDOW_SEC)
	return _lane_change_times.size() >= VIOLENT_MIN_CHANGES


func _is_moving_for_drop() -> bool:
	# 横向还在滑，或最近有过换道按键
	if absf(_lane_x - _prev_lane_x) > 0.025:
		return true
	_prune_lane_changes(MOVE_DROP_WINDOW_SEC)
	return not _lane_change_times.is_empty()


func _update_sway(delta: float) -> void:
	var lat_speed := absf(_lane_x - _prev_lane_x) / maxf(delta, 0.0001)
	var height_mul := 1.0 + float(maxi(_stack.size() - 1, 0)) * 0.12
	_sway += lat_speed * SWAY_BUILD * height_mul * delta
	_sway = maxf(_sway - SWAY_DECAY * delta, 0.0)
	if _drop_cd > 0.0:
		_drop_cd = maxf(_drop_cd - delta, 0.0)


func _move_drop_chance_per_sec() -> float:
	var n := _stack.size()
	if n < MIN_STACK_TO_DROP:
		return 0.0
	var p := 0.0
	if n <= HIGH_STACK_THRESHOLD:
		# 3→约18%/s … 8→约48%/s
		p = 0.18 + float(n - MIN_STACK_TO_DROP) * 0.06
	else:
		# 超过 8 层：大幅抬升；9→约72%/s，之后每层再加
		p = 0.72 + float(n - HIGH_STACK_THRESHOLD) * 0.08
	if _is_violent_move():
		p = minf(p * 1.35, 0.99)
	else:
		p = minf(p, 0.95)
	return p


func _try_drop_layers(delta: float) -> void:
	if _stack_animating:
		return
	if _stack.size() < MIN_STACK_TO_DROP or _drop_cd > 0.0:
		return
	# 不在移动则不掉（超高塔也需有移动才掉；站桩不掉）
	if not _is_moving_for_drop():
		return
	var p := _move_drop_chance_per_sec()
	if p <= 0.0:
		return
	if randf() >= p * delta:
		return
	_drop_top_layer()
	_drop_cd = _drop_cooldown()
	_sway *= 0.3


func _force_drop_from_hazard() -> void:
	# 撞障碍必然掉一层（至少还剩底座）
	if _stack_animating:
		return
	if _stack.size() < 2:
		return
	_drop_top_layer()
	_drop_cd = _drop_cooldown()
	_sway = minf(_sway + 1.2, 3.0)


func _drop_top_layer() -> void:
	if _stack.is_empty():
		return
	var layer: Node3D = _stack.pop_back()
	if layer == null or not is_instance_valid(layer):
		return
	_drop_count += 1
	var gpos := layer.global_position
	var grot := layer.global_rotation
	_tower.remove_child(layer)
	_world.add_child(layer)
	layer.global_position = gpos
	layer.global_rotation = grot
	# 向倾斜外侧甩出
	var side := signf(_tower.rotation.z)
	if is_zero_approx(side):
		side = -1.0 if randf() < 0.5 else 1.0
	var vel := Vector3(
		side * randf_range(3.5, 6.5),
		randf_range(4.0, 6.5),
		randf_range(-1.0, 2.0)
	)
	var spin := Vector3(
		randf_range(-4.0, 4.0),
		randf_range(-2.0, 2.0),
		side * randf_range(3.0, 7.0)
	)
	_falling.append({
		"node": layer,
		"vel": vel,
		"spin": spin,
		"life": 0.0,
	})


func _update_falling(delta: float) -> void:
	var remain: Array[Dictionary] = []
	for f in _falling:
		var node: Node3D = f.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var vel: Vector3 = f["vel"]
		vel.y -= 18.0 * delta
		f["vel"] = vel
		node.global_position += vel * delta
		var spin: Vector3 = f["spin"]
		node.rotation += spin * delta
		f["life"] = float(f["life"]) + delta
		# 落地后弹一下再消失
		if node.global_position.y < 0.05 and vel.y < 0.0:
			node.global_position.y = 0.05
			vel.y *= -0.35
			vel.x *= 0.7
			vel.z *= 0.7
			f["vel"] = vel
			spin *= 0.6
			f["spin"] = spin
		if float(f["life"]) > 1.35 or (node.global_position.y <= 0.06 and absf(vel.y) < 0.8 and float(f["life"]) > 0.7):
			# 缩小淡出
			node.scale = node.scale.lerp(Vector3.ZERO, 1.0 - exp(-10.0 * delta))
			if node.scale.x < 0.08 or float(f["life"]) > 2.0:
				node.queue_free()
				continue
		remain.append(f)
	_falling = remain


func _update_pickup_bob() -> void:
	var t := Time.get_ticks_msec() * 0.001
	for p in _pickups:
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var phase: float = float(p.get("phase", 0.0))
		node.position.y = 0.08 + sin(t * 3.0 + phase) * 0.1


func _lane_to_x(lane: int) -> float:
	var mid := (LANE_COUNT - 1) * 0.5
	return (float(lane) - mid) * LANE_WIDTH


func _character_display_name() -> String:
	return "青青" if _character_id == CHAR_QINGQING else "卡皮巴拉"


func _character_model_path() -> String:
	if _character_id == CHAR_QINGQING and ResourceLoader.exists(CapybaraRushPaths.QINGQING):
		return CapybaraRushPaths.QINGQING
	return CapybaraRushPaths.CAPYBARA_BASE


func _character_yaw() -> float:
	return QINGQING_FORWARD_YAW if _character_id == CHAR_QINGQING else CAPY_FORWARD_YAW


func _setup_character_select() -> void:
	_select_spin_pivots.clear()
	_select_ui = CanvasLayer.new()
	_select_ui.layer = 20
	add_child(_select_ui)

	# 粉彩背景
	var dim := ColorRect.new()
	dim.color = Color(0.72, 0.78, 0.94, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_select_ui.add_child(dim)

	var wash := ColorRect.new()
	wash.color = Color(1.0, 0.82, 0.88, 0.28)
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_select_ui.add_child(wash)

	var title := Label.new()
	title.text = "选择角色"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 56
	title.offset_left = -220
	title.offset_right = 220
	title.offset_bottom = 110
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	_select_ui.add_child(title)

	var tip := Label.new()
	tip.text = "游戏中按 Esc 可返回这里哦"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tip.offset_top = 108
	tip.offset_left = -260
	tip.offset_right = 260
	tip.offset_bottom = 140
	tip.add_theme_font_size_override("font_size", 18)
	tip.add_theme_color_override("font_color", Color(0.55, 0.42, 0.58))
	_select_ui.add_child(tip)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_CENTER)
	row.offset_left = -380
	row.offset_right = 380
	row.offset_top = -20
	row.offset_bottom = 300
	row.add_theme_constant_override("separation", 36)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_select_ui.add_child(row)

	row.add_child(_make_character_card(
		"卡皮巴拉",
		CHAR_CAPYBARA,
		CapybaraRushPaths.CAPYBARA_BASE,
		Color(1.0, 0.93, 0.88)
	))
	row.add_child(_make_character_card(
		"青青",
		CHAR_QINGQING,
		CapybaraRushPaths.QINGQING,
		Color(0.92, 0.96, 0.90)
	))

	if _hud_label:
		_hud_label.visible = false
	if _hud_tip:
		_hud_tip.visible = false


func _make_character_card(label_text: String, char_id: String, model_path: String, tint: Color) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(320, 420)
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(
		Color(1.0, 0.98, 0.99),
		Color(1.0, 0.72, 0.82),
		28.0,
		4.0
	))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	margin.add_child(v)

	var preview_frame := PanelContainer.new()
	preview_frame.custom_minimum_size = Vector2(0, 250)
	preview_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_frame.add_theme_stylebox_override("panel", _cartoon_panel_style(
		tint,
		Color(1, 1, 1, 0.8),
		22.0,
		2.0
	))
	v.add_child(preview_frame)

	var preview := _make_model_preview(model_path)
	preview_frame.add_child(preview)

	var name_l := Label.new()
	name_l.text = label_text
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 28)
	name_l.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	v.add_child(name_l)

	var btn := Button.new()
	btn.text = "选择 " + label_text
	btn.custom_minimum_size = Vector2(0, 52)
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.98))
	btn.add_theme_stylebox_override("normal", _cartoon_panel_style(Color(1.0, 0.55, 0.68), Color(1.0, 0.78, 0.86), 20.0, 0.0))
	btn.add_theme_stylebox_override("hover", _cartoon_panel_style(Color(1.0, 0.62, 0.74), Color(1.0, 0.84, 0.90), 20.0, 0.0))
	btn.add_theme_stylebox_override("pressed", _cartoon_panel_style(Color(0.92, 0.48, 0.62), Color(1.0, 0.72, 0.82), 20.0, 0.0))
	btn.pressed.connect(_on_character_chosen.bind(char_id))
	v.add_child(btn)
	return panel


func _make_model_preview(model_path: String) -> Control:
	# TextureRect 铺满预览区，避免 SubViewportContainer 只画在左上角
	var host := Control.new()
	host.custom_minimum_size = Vector2(260, 230)
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sv := SubViewport.new()
	sv.size = Vector2i(512, 512)
	sv.transparent_bg = true
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sv.own_world_3d = true
	host.add_child(sv)

	var tex := TextureRect.new()
	tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
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
	var model := _instance_fitted(model_path, 1.0, 0.0)
	if model:
		holder.add_child(model)
	else:
		var stub := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = 0.45
		sph.height = 0.9
		stub.mesh = sph
		stub.position.y = 0.45
		holder.add_child(stub)

	var cam := Camera3D.new()
	cam.fov = 30.0
	root.add_child(cam)
	cam.current = true
	cam.position = Vector3(0.0, 0.55, 2.8)
	cam.look_at(Vector3(0.0, 0.45, 0.0), Vector3.UP)

	_select_spin_pivots.append(pivot)
	call_deferred("_frame_select_preview", cam, holder, pivot)
	return host


func _frame_select_preview(cam: Camera3D, holder: Node3D, pivot: Node3D) -> void:
	if cam == null or not is_instance_valid(cam):
		return
	if holder == null or not is_instance_valid(holder):
		return
	holder.position = Vector3.ZERO
	if pivot != null and is_instance_valid(pivot):
		pivot.rotation = Vector3.ZERO
	holder.force_update_transform()
	var aabb := _local_aabb(holder)
	if aabb.size.length() < 0.05:
		aabb = AABB(Vector3(-0.5, 0.0, -0.5), Vector3(1.0, 1.0, 1.0))
	holder.position = -aabb.get_center()
	holder.force_update_transform()
	aabb = _local_aabb(holder)
	var center := aabb.get_center()
	var extent := maxf(maxf(aabb.size.x, aabb.size.y), aabb.size.z)
	var radius := maxf(extent * 0.5, 0.55)
	var dist := radius / maxf(tan(deg_to_rad(cam.fov * 0.5)), 0.01) * 1.45
	cam.position = Vector3(0.0, center.y + radius * 0.05, dist)
	cam.look_at(Vector3(0.0, center.y, 0.0), Vector3.UP)


func _spin_select_previews(delta: float) -> void:
	for pivot in _select_spin_pivots:
		if pivot != null and is_instance_valid(pivot):
			pivot.rotation.y += delta * 0.85


func _on_character_chosen(char_id: String) -> void:
	_character_id = char_id
	_select_spin_pivots.clear()
	if _select_ui:
		_select_ui.queue_free()
		_select_ui = null
	_setup_mode_select()


func _setup_mode_select() -> void:
	_mode_ui = CanvasLayer.new()
	_mode_ui.layer = 21
	add_child(_mode_ui)

	var dim := ColorRect.new()
	dim.color = Color(0.72, 0.78, 0.94, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_mode_ui.add_child(dim)

	var title := Label.new()
	title.text = "选择模式"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 64
	title.offset_left = -220
	title.offset_right = 220
	title.offset_bottom = 120
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	_mode_ui.add_child(title)

	var tip := Label.new()
	tip.text = "角色：%s · Esc 返回重选" % _character_display_name()
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tip.offset_top = 118
	tip.offset_left = -280
	tip.offset_right = 280
	tip.offset_bottom = 150
	tip.add_theme_font_size_override("font_size", 18)
	tip.add_theme_color_override("font_color", Color(0.55, 0.42, 0.58))
	_mode_ui.add_child(tip)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_CENTER)
	row.offset_left = -420
	row.offset_right = 420
	row.offset_top = -40
	row.offset_bottom = 280
	row.add_theme_constant_override("separation", 32)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_mode_ui.add_child(row)

	row.add_child(_make_mode_card(
		"叠塔 Stack",
		"拾取水豚叠高塔\n避障保塔冲终点",
		MODE_STACK,
		Color(1.0, 0.93, 0.88)
	))
	row.add_child(_make_mode_card(
		"竞速 Rush",
		"碰飞船进入冲锋\n撞障-1s · 加速包+0.5s",
		MODE_RACE,
		Color(0.90, 0.96, 0.98)
	))


func _make_mode_card(title_text: String, desc_text: String, mode_id: String, tint: Color) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 300)
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(
		Color(1.0, 0.98, 0.99),
		Color(1.0, 0.72, 0.82),
		28.0,
		4.0
	))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	margin.add_child(v)

	var wash := ColorRect.new()
	wash.custom_minimum_size = Vector2(0, 72)
	wash.color = tint
	v.add_child(wash)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	v.add_child(title)

	var desc := Label.new()
	desc.text = desc_text
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 18)
	desc.add_theme_color_override("font_color", Color(0.52, 0.40, 0.55))
	v.add_child(desc)

	var btn := Button.new()
	btn.text = "开始"
	btn.custom_minimum_size = Vector2(0, 54)
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_stylebox_override("normal", _cartoon_panel_style(Color(1.0, 0.55, 0.68), Color(1.0, 0.78, 0.86), 20.0, 0.0))
	btn.add_theme_stylebox_override("hover", _cartoon_panel_style(Color(1.0, 0.62, 0.74), Color(1.0, 0.84, 0.90), 20.0, 0.0))
	btn.add_theme_stylebox_override("pressed", _cartoon_panel_style(Color(0.92, 0.48, 0.62), Color(1.0, 0.72, 0.82), 20.0, 0.0))
	btn.pressed.connect(_on_mode_chosen.bind(mode_id))
	v.add_child(btn)
	return panel


func _on_mode_chosen(mode_id: String) -> void:
	_game_mode = mode_id
	if _mode_ui:
		_mode_ui.queue_free()
		_mode_ui = null
	_spawn_hazards()
	if _is_race():
		_spawn_spaceships()
		_spawn_boost_packs()
		_spawn_race_runner()
	else:
		_spawn_pickups()
		_spawn_tower()
	_update_camera()
	if _character_id == CHAR_QINGQING and not _is_race():
		_start_qingqing_intro()
	else:
		_begin_gameplay()


func _begin_gameplay() -> void:
	_intro_showcasing = false
	_playing = true
	if _tower and not _stack.is_empty():
		var layer: Node3D = _stack[0]
		if layer and is_instance_valid(layer):
			var model_yaw := (
				PILOT_FORWARD_YAW if (_is_race() and _boosting) else _character_yaw()
			)
			layer.rotation = Vector3(0.0, model_yaw, 0.0)
			layer.position.y = 0.0
			layer.scale = Vector3.ONE
	if _hud_label:
		_hud_label.visible = true
	if _hud_tip:
		_hud_tip.visible = true
		if _is_race():
			_hud_tip.text = "空格/W跳跃躲障 · 碰飞船冲锋 · 黄星加速 · 橙道加速"
		else:
			_hud_tip.text = "空格/W跳跃躲障上阶 · 黄星加速 · 橙道加速 · 撞障掉层"
	_update_camera()
	_update_hud()


func _start_qingqing_intro() -> void:
	_intro_showcasing = true
	_playing = false
	if _hud_label:
		_hud_label.visible = false
	if _hud_tip:
		_hud_tip.visible = false
	if _tower == null or _stack.is_empty():
		_begin_gameplay()
		return

	_tower.position = Vector3(_lane_x, 0.0, _progress)
	_tower.rotation = Vector3.ZERO
	var layer: Node3D = _stack[0]
	if layer == null or not is_instance_valid(layer):
		_begin_gameplay()
		return
	var face := _character_yaw()
	layer.rotation = Vector3(0.0, face, 0.0)
	layer.position = Vector3.ZERO
	layer.scale = Vector3.ONE
	# 视角固定为跟跑相机，只让青青缓慢转一圈
	_update_camera()

	var tw := create_tween()
	tw.tween_property(layer, "rotation:y", face + TAU, INTRO_SPIN_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(_begin_gameplay)


func _update_intro_camera(_delta: float) -> void:
	if _tower == null:
		return
	_tower.position = Vector3(_lane_x, 0.0, _progress)
	_tower.rotation = Vector3.ZERO
	_update_camera()


func _update_tower_motion() -> void:
	if _tower == null:
		return
	var t := Time.get_ticks_msec() * 0.001
	var bob := sin(t * BOB_FREQ) * BOB_AMP if _grounded else 0.0
	if _path != null:
		var f: Dictionary = _path.frame_at(_progress)
		_path_yaw = float(f["yaw"])
		var p: Vector3 = f["pos"]
		var r: Vector3 = f["right"]
		_tower.global_position = p + r * _lane_x + Vector3(0.0, _air_y + bob, 0.0)
		var lean_target := clampf((_lane_to_x(_lane) - _lane_x) * 0.22, -MAX_LEAN, MAX_LEAN)
		var wobble := sin(t * 14.0) * minf(_sway, 2.0) * 0.08
		# 模型自身 yaw 在 fitted wrap 上；塔只跟弯道切向
		_tower.rotation = Vector3(0.0, _path_yaw, lean_target + wobble)
	else:
		_tower.position = Vector3(_lane_x, _air_y + bob, _progress)
		var lean_target2 := clampf((_lane_to_x(_lane) - _lane_x) * 0.22, -MAX_LEAN, MAX_LEAN)
		var wobble2 := sin(t * 14.0) * minf(_sway, 2.0) * 0.08
		_tower.rotation.z = lean_target2 + wobble2
	# 拾取插入动画期间由 tween 接管各层位姿
	if _stack_animating:
		return
	if _is_race():
		return
	var n := _stack.size()
	for i in n:
		var layer: Node3D = _stack[i]
		if layer == null:
			continue
		var h_ratio := float(i) / float(maxi(n - 1, 1))
		var amp := 0.04 + h_ratio * minf(_sway, 2.2) * 0.12
		layer.rotation.x = sin(t * BOB_FREQ + float(i) * 0.4) * amp
		layer.rotation.z = sin(t * 11.0 + float(i)) * amp * 0.8
		# 高层在晃动时微微错位，更像要掉
		layer.position.x = h_ratio * sin(t * 9.0 + float(i)) * minf(_sway, 2.0) * 0.12
		layer.position.y = float(i) * STACK_STEP_Y


func _try_collect_pickups() -> void:
	var remain: Array[Dictionary] = []
	for p in _pickups:
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var dist: float = float(p.get("dist", node.global_position.z))
		var lateral: float = float(p.get("lateral", node.global_position.x))
		if _along_overlap(dist, lateral, PICKUP_RADIUS_Z, PICKUP_RADIUS_X):
			_picked_count += 1
			if _stack_animating:
				_pending_pickup_holders.append(node)
			else:
				_begin_pickup_under_anim(node)
		else:
			remain.append(p)
	_pickups = remain


func _add_stack_layer() -> void:
	var layer := _make_capy_visual()
	if layer == null:
		return
	var idx := _stack.size()
	layer.position = Vector3(0.0, float(idx) * STACK_STEP_Y, 0.0)
	_tower.add_child(layer)
	_stack.append(layer)
	# 叠上只轻微晃一下，不会触发掉落
	_sway = minf(_sway + 0.08, 1.2)


func _extract_pickup_visual(holder: Node3D) -> Node3D:
	if holder == null or not is_instance_valid(holder):
		return null
	var incoming: Node3D = null
	if holder.get_child_count() > 0:
		incoming = holder.get_child(0) as Node3D
	if incoming == null:
		incoming = holder
	var gpos := incoming.global_position
	var grot := incoming.global_basis
	var parent := incoming.get_parent()
	if parent:
		parent.remove_child(incoming)
	if holder != incoming and is_instance_valid(holder):
		holder.queue_free()
	_tower.add_child(incoming)
	incoming.global_position = gpos
	incoming.global_basis = grot
	return incoming


func _begin_pickup_under_anim(pickup_holder: Node3D) -> void:
	if _tower == null or pickup_holder == null or not is_instance_valid(pickup_holder):
		return
	if _stack_animating:
		_pending_pickup_holders.append(pickup_holder)
		return

	var old_layers: Array[Node3D] = _stack.duplicate()
	var incoming := _extract_pickup_visual(pickup_holder)
	if incoming == null:
		_drain_pending_pickups()
		return

	_stack_animating = true
	_sway = minf(_sway + 0.12, 1.4)
	# 先占位到底层，动画只负责位姿；计数/相机立即 +1
	_stack.insert(0, incoming)

	var face_yaw := _character_yaw()
	var start_local := incoming.position
	# 从身前略低处钻入
	var dive_pos := Vector3(
		clampf(start_local.x * 0.35, -0.8, 0.8),
		-0.18,
		clampf(start_local.z, -0.2, 1.2) * 0.45 + 0.55
	)

	var tw := create_tween()
	tw.set_parallel(true)

	# 旧塔整体跳起（略过冲），给底下腾空
	for i in old_layers.size():
		var layer: Node3D = old_layers[i]
		if layer == null or not is_instance_valid(layer):
			continue
		var peak_y := float(i + 1) * STACK_STEP_Y + PICKUP_JUMP_EXTRA
		tw.tween_property(layer, "position:y", peak_y, PICKUP_ANIM_JUMP_SEC) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(layer, "scale", Vector3(1.06, 0.9, 1.06), PICKUP_ANIM_JUMP_SEC * 0.55) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(layer, "scale", Vector3.ONE, PICKUP_ANIM_JUMP_SEC * 0.45) \
			.set_delay(PICKUP_ANIM_JUMP_SEC * 0.55) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# 新单位俯身钻向塔底前方
	tw.tween_property(incoming, "position", dive_pos, PICKUP_ANIM_JUMP_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(incoming, "rotation:x", 0.35, PICKUP_ANIM_JUMP_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(incoming, "rotation:y", face_yaw, PICKUP_ANIM_JUMP_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tw.chain().set_parallel(true)
	# 钻到底座
	tw.tween_property(incoming, "position", Vector3(0.0, 0.0, 0.0), PICKUP_ANIM_SLIDE_SEC) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(incoming, "rotation:x", 0.0, PICKUP_ANIM_SLIDE_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(incoming, "rotation:y", face_yaw, PICKUP_ANIM_SLIDE_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(incoming, "rotation:z", 0.0, PICKUP_ANIM_SLIDE_SEC) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(incoming, "scale", Vector3(1.12, 0.88, 1.12), PICKUP_ANIM_SLIDE_SEC * 0.4) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(incoming, "scale", Vector3.ONE, PICKUP_ANIM_SLIDE_SEC * 0.6) \
		.set_delay(PICKUP_ANIM_SLIDE_SEC * 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 旧塔落到新高度
	for i in old_layers.size():
		var layer2: Node3D = old_layers[i]
		if layer2 == null or not is_instance_valid(layer2):
			continue
		var land_y := float(i + 1) * STACK_STEP_Y
		tw.tween_property(layer2, "position:y", land_y, PICKUP_ANIM_SETTLE_SEC) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_property(layer2, "position:x", 0.0, PICKUP_ANIM_SETTLE_SEC) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(layer2, "position:z", 0.0, PICKUP_ANIM_SETTLE_SEC) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(layer2, "rotation:x", 0.0, PICKUP_ANIM_SETTLE_SEC) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(layer2, "rotation:z", 0.0, PICKUP_ANIM_SETTLE_SEC) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tw.chain().tween_callback(func() -> void:
		_finish_pickup_under_anim(incoming, old_layers)
	)


func _finish_pickup_under_anim(incoming: Node3D, old_layers: Array[Node3D]) -> void:
	var face_yaw := _character_yaw()
	# 动画开始时已 insert(0)，这里只校正位姿；若节点失效则重建
	if incoming == null or not is_instance_valid(incoming) or _stack.is_empty() or _stack[0] != incoming:
		_stack.clear()
		if incoming != null and is_instance_valid(incoming):
			_stack.append(incoming)
		for layer in old_layers:
			if layer != null and is_instance_valid(layer):
				_stack.append(layer)

	for i in _stack.size():
		var layer: Node3D = _stack[i]
		if layer == null or not is_instance_valid(layer):
			continue
		layer.position = Vector3(0.0, float(i) * STACK_STEP_Y, 0.0)
		layer.rotation = Vector3(0.0, face_yaw, 0.0)
		layer.scale = Vector3.ONE

	_stack_animating = false
	_drain_pending_pickups()


func _drain_pending_pickups() -> void:
	while not _pending_pickup_holders.is_empty():
		var next: Node3D = _pending_pickup_holders.pop_front()
		if next != null and is_instance_valid(next):
			_begin_pickup_under_anim(next)
			return


func _spawn_tower() -> void:
	_tower = Node3D.new()
	_tower.name = "CapyTower"
	_world.add_child(_tower)
	_add_stack_layer()


func _spawn_race_runner() -> void:
	_tower = Node3D.new()
	_tower.name = "RaceRunner"
	_world.add_child(_tower)
	_set_race_visual(false)


func _set_race_visual(as_pilot: bool) -> void:
	if _tower == null:
		return
	for c in _tower.get_children():
		c.queue_free()
	_stack.clear()
	_race_visual = null
	var visual: Node3D
	if as_pilot:
		visual = _instance_fitted(CapybaraRushPaths.CAPYBARA_PILOT, TARGET_PILOT_HEIGHT, PILOT_FORWARD_YAW)
		if visual == null:
			visual = _make_stub_pilot()
			if visual:
				visual.rotation.y = PILOT_FORWARD_YAW
	else:
		visual = _make_capy_visual()
	if visual == null:
		return
	# 与叠塔一致：直接挂 fitted wrap，避免 holder 再叠一层朝向
	visual.position = Vector3.ZERO
	_tower.add_child(visual)
	_stack.append(visual)
	_race_visual = visual


func _make_stub_pilot() -> Node3D:
	var root := Node3D.new()
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.4, 0.7, 1.8)
	body.mesh = box
	body.position.y = 0.55
	var bm := StandardMaterial3D.new()
	bm.albedo_color = Color(0.55, 0.85, 0.78)
	body.material_override = bm
	root.add_child(body)
	var dome := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.45
	sph.height = 0.7
	dome.mesh = sph
	dome.position = Vector3(0.0, 1.05, 0.25)
	var dm := StandardMaterial3D.new()
	dm.albedo_color = Color(1.0, 0.55, 0.62)
	dome.material_override = dm
	root.add_child(dome)
	var capy := _make_capy_visual()
	if capy:
		capy.scale = Vector3.ONE * 0.55
		capy.position = Vector3(0.0, 0.75, 0.1)
		root.add_child(capy)
	return root


func _spawn_spaceships() -> void:
	var z := 40.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 40.0:
		var lane := (i * 2) % LANE_COUNT
		var lateral := _lane_to_x(lane)
		var visual := _instance_fitted(CapybaraRushPaths.SPACESHIP, 1.25, SPACESHIP_FORWARD_YAW)
		if visual == null:
			visual = _make_stub_spaceship()
		var holder := Node3D.new()
		_world.add_child(holder)
		_path_place(holder, z, lateral, 0.15, 0.0)
		holder.add_child(visual)
		_spaceships.append({"node": holder, "lane": lane, "dist": z, "lateral": lateral, "taken": false})
		z += randf_range(55.0, 75.0)
		i += 1


func _make_stub_spaceship() -> Node3D:
	var root := Node3D.new()
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.2, 0.55, 1.6)
	body.mesh = box
	body.position.y = 0.45
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.85, 0.78)
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.75, 0.7)
	mat.emission_energy_multiplier = 0.35
	body.material_override = mat
	root.add_child(body)
	return root


func _spawn_boost_packs() -> void:
	## 预埋冲锋续时包；仅在冲锋中可见并可拾取
	var z := 50.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 35.0:
		var lane := (i + 1) % LANE_COUNT
		var lateral := _lane_to_x(lane)
		var visual := _instance_fitted(CapybaraRushPaths.BOOST_PACK, 0.95, 0.0)
		if visual == null:
			visual = _make_stub_boost_pack()
		var holder := Node3D.new()
		holder.visible = false
		_world.add_child(holder)
		_path_place(holder, z, lateral, 0.2, 0.0)
		holder.add_child(visual)
		_boost_packs.append({
			"node": holder, "phase": randf() * TAU, "taken": false,
			"dist": z, "lateral": lateral,
		})
		z += randf_range(18.0, 28.0)
		i += 1


func _make_stub_boost_pack() -> Node3D:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.7, 0.7, 0.7)
	mi.mesh = box
	mi.position.y = 0.4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.78, 0.28)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.7, 0.2)
	mat.emission_energy_multiplier = 0.8
	mi.material_override = mat
	return mi


func _set_boost_packs_visible(on: bool) -> void:
	for p in _boost_packs:
		if bool(p.get("taken", false)):
			continue
		var node: Node3D = p.get("node")
		if node != null and is_instance_valid(node):
			node.visible = on


func _update_boost(delta: float) -> void:
	if not _boosting:
		return
	_boost_time_left = maxf(_boost_time_left - delta, 0.0)
	if _boost_time_left <= 0.001:
		_end_boost()


func _start_boost(add_sec: float) -> void:
	var was := _boosting
	_boost_time_left = minf(_boost_time_left + add_sec, BOOST_MAX_TIME)
	_boosting = _boost_time_left > 0.0
	if _boosting and not was:
		_set_race_visual(true)
		_set_boost_packs_visible(true)


func _end_boost() -> void:
	_boosting = false
	_boost_time_left = 0.0
	_set_race_visual(false)
	_set_boost_packs_visible(false)


func _try_collect_spaceships() -> void:
	for s in _spaceships:
		if bool(s.get("taken", false)):
			continue
		var node: Node3D = s.get("node")
		if node == null or not is_instance_valid(node):
			continue
		if not _along_overlap(float(s.get("dist", -999.0)), float(s.get("lateral", 0.0)), 1.2, 1.15):
			continue
		s["taken"] = true
		_ship_count += 1
		node.visible = false
		_start_boost(BOOST_DURATION)


func _try_collect_boost_packs() -> void:
	if not _boosting:
		return
	for p in _boost_packs:
		if bool(p.get("taken", false)):
			continue
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node) or not node.visible:
			continue
		if not _along_overlap(float(p.get("dist", -999.0)), float(p.get("lateral", 0.0)), 1.0, 1.0):
			continue
		p["taken"] = true
		_boost_pack_count += 1
		node.visible = false
		_start_boost(BOOST_PACK_BONUS)


func _along_overlap(dist: float, lateral: float, dz: float, dx: float) -> bool:
	return absf(dist - _progress) <= dz and absf(lateral - _lane_x) <= dx


func _update_boost_pack_bob() -> void:
	if not _boosting:
		return
	var t := Time.get_ticks_msec() * 0.001
	for p in _boost_packs:
		if bool(p.get("taken", false)):
			continue
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node) or not node.visible:
			continue
		var phase: float = float(p.get("phase", 0.0))
		node.position.y = 0.25 + sin(t * 4.0 + phase) * 0.12
		node.rotation.y = t * 1.6 + phase


func _try_hit_hazards_race() -> void:
	for h in _hazards:
		if bool(h.get("hit", false)):
			continue
		if _hazard_overlap(h) == false:
			continue
		if _is_airborne_clear():
			continue
		h["hit"] = true
		_collision_count += 1
		if _boosting:
			_boost_time_left = maxf(_boost_time_left - BOOST_HIT_PENALTY, 0.0)
			if _boost_time_left <= 0.001:
				_end_boost()
		_sway = minf(_sway + 0.9, 2.5)
		_knock_hazard(h)


func _spawn_pickups() -> void:
	## 沿三道散落可叠水豚（约 50s 赛道加密分布）
	var z := 16.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 22.0:
		var lane := i % LANE_COUNT
		_spawn_pickup_at(_lane_to_x(lane), z)
		if i % 3 == 0:
			var other := (lane + 1 + (i % 2)) % LANE_COUNT
			_spawn_pickup_at(_lane_to_x(other), z + 5.0)
		z += randf_range(10.0, 14.0)
		i += 1


func _spawn_hazards() -> void:
	## 草垛 / 木箱挡道：撞到猛晃并可能掉层；跳跃可躲
	var z := 28.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 30.0:
		var lane := (i * 2 + 1) % LANE_COUNT
		var lateral := _lane_to_x(lane)
		var use_crate := (i % 2 == 1) and ResourceLoader.exists(CapybaraRushPaths.WOOD_CRATE)
		var path := CapybaraRushPaths.WOOD_CRATE if use_crate else CapybaraRushPaths.HAY_BALE
		var h := 1.35 if use_crate else 1.55
		var visual := _instance_fitted(path, h, 0.0)
		if visual == null and path != CapybaraRushPaths.HAY_BALE:
			visual = _instance_fitted(CapybaraRushPaths.HAY_BALE, 1.55, 0.0)
		if visual == null:
			visual = _make_stub_hazard(use_crate)
		var holder := Node3D.new()
		_world.add_child(holder)
		_path_place(holder, z, lateral, 0.0, 0.0)
		holder.add_child(visual)
		_hazards.append({"node": holder, "lane": lane, "dist": z, "lateral": lateral, "hit": false})
		z += randf_range(16.0, 22.0)
		i += 1


func _make_stub_hazard(as_crate: bool) -> Node3D:
	var mi := MeshInstance3D.new()
	if as_crate:
		var box := BoxMesh.new()
		box.size = Vector3(1.2, 1.2, 1.2)
		mi.mesh = box
		mi.position.y = 0.6
	else:
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.85
		cyl.bottom_radius = 0.85
		cyl.height = 1.4
		mi.mesh = cyl
		mi.rotation.z = PI * 0.5
		mi.position.y = 0.7
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.78, 0.58, 0.28) if as_crate else Color(0.9, 0.75, 0.35)
	mi.material_override = mat
	return mi


func _try_hit_hazards() -> void:
	for h in _hazards:
		if bool(h.get("hit", false)):
			continue
		if _hazard_overlap(h) == false:
			continue
		if _is_airborne_clear():
			continue
		h["hit"] = true
		_collision_count += 1
		# 撞障碍：必然掉一层
		_force_drop_from_hazard()
		_knock_hazard(h)


func _hazard_overlap(h: Dictionary) -> bool:
	var dist: float = float(h.get("dist", -9999.0))
	var lateral: float = float(h.get("lateral", 0.0))
	if absf(dist - _progress) > 1.35:
		return false
	if absf(lateral - _lane_x) > PICKUP_RADIUS_X * 1.05:
		return false
	return true


func _knock_hazard(h: Dictionary) -> void:
	var node: Node3D = h.get("node")
	if node == null or not is_instance_valid(node):
		return
	var lateral: float = float(h.get("lateral", 0.0))
	var side := signf(lateral - _lane_x)
	if is_zero_approx(side):
		side = 1.0
	if _path != null:
		var f: Dictionary = _path.frame_at(float(h.get("dist", _progress)))
		var r: Vector3 = f["right"]
		node.global_position += r * side * 1.8 + Vector3(0.0, 0.6, 0.0)
	else:
		node.position.x += side * 1.8
		node.position.y += 0.6
	node.rotate_z(side * 0.8)


func _spawn_clouds() -> void:
	var z := 8.0
	var i := 0
	var track_len := _track_len()
	while z < track_len:
		var side := -1.0 if i % 2 == 0 else 1.0
		var cloud := _make_cloud_visual()
		var holder := Node3D.new()
		holder.position = Vector3(
			side * randf_range(7.0, 14.0),
			randf_range(4.5, 9.0),
			z + randf_range(-2.0, 2.0)
		)
		holder.scale = Vector3.ONE * randf_range(1.4, 2.6)
		holder.add_child(cloud)
		_world.add_child(holder)
		_clouds.append(holder)
		z += randf_range(18.0, 28.0)
		i += 1


func _make_cloud_visual() -> Node3D:
	var n := _instance_fitted(CapybaraRushPaths.CLOUD_FLUFFY, 1.8, 0.0)
	if n:
		return n
	# Tripo 云朵额度不足时的粉彩占位
	var root := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.92, 0.95)
	mat.roughness = 0.9
	for j in 4:
		var mi := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = randf_range(0.45, 0.75)
		sph.height = sph.radius * 2.0
		mi.mesh = sph
		mi.material_override = mat
		mi.position = Vector3(randf_range(-0.7, 0.7), randf_range(-0.15, 0.35), randf_range(-0.3, 0.3))
		root.add_child(mi)
	return root


func _update_clouds(delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	for i in _clouds.size():
		var c: Node3D = _clouds[i]
		if c == null or not is_instance_valid(c):
			continue
		c.position.x += sin(t * 0.35 + float(i)) * 0.15 * delta
		c.position.y += cos(t * 0.5 + float(i) * 0.7) * 0.08 * delta


func _spawn_pickup_at(x: float, z: float) -> void:
	var visual := _make_capy_visual()
	if visual == null:
		return
	var holder := Node3D.new()
	_world.add_child(holder)
	_path_place(holder, z, x, 0.0, 0.0)
	holder.add_child(visual)
	_pickups.append({"node": holder, "phase": randf() * TAU, "dist": z, "lateral": x})


func _make_capy_visual() -> Node3D:
	var n := _instance_fitted(_character_model_path(), TARGET_CAPY_HEIGHT, _character_yaw())
	if n:
		return n
	var stub := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.5
	sph.height = 1.0
	stub.mesh = sph
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.85, 0.72, 0.55) if _character_id == CHAR_QINGQING else Color(0.72, 0.52, 0.38)
	stub.material_override = sm
	stub.position.y = 0.5
	return stub


func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.72, 0.78, 0.92)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.92, 0.88, 0.95)
	env.ambient_light_energy = 0.85
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, 35, 0)
	sun.light_color = Color(1.0, 0.96, 0.9)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)


func _path_place(node: Node3D, dist: float, lateral: float, y: float = 0.0, yaw_extra: float = 0.0) -> void:
	if _path != null:
		_path.apply_to(node, dist, lateral, y, yaw_extra)
	else:
		node.position = Vector3(lateral, y, dist)
		node.rotation.y = yaw_extra


func _build_path_and_track() -> void:
	_path = CapybaraTrackPathScript.new()
	_path.build_winding(TRACK_LENGTH)

	var road := MeshInstance3D.new()
	road.mesh = _path.build_road_mesh(ROAD_HALF_W, 0.18)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.82, 0.94)
	mat.roughness = 0.85
	road.material_override = mat
	_world.add_child(road)

	# 弯道两侧水色大平面（取路径包围）
	for side in [-1.0, 1.0]:
		var water := MeshInstance3D.new()
		var wb := BoxMesh.new()
		wb.size = Vector3(80.0, 0.05, _path.length + 40.0)
		water.mesh = wb
		water.position = Vector3(side * 28.0, -0.25, _path.length * 0.45)
		var wm := StandardMaterial3D.new()
		wm.albedo_color = Color(0.55, 0.72, 0.88, 0.92)
		wm.roughness = 0.25
		wm.metallic = 0.15
		water.material_override = wm
		_world.add_child(water)


func _scatter_props() -> void:
	var track_len := _track_len()
	_place_along(CapybaraRushPaths.FINISH_ARCH, track_len, 0.0, 0.0, 3.2, 0.0)

	var z := 10.0
	var flip := 1.0
	var fence_i := 0
	while z < track_len - 8.0:
		var side := flip
		_place_along(
			CapybaraRushPaths.TREE_LOLLIPOP,
			z, side * (ROAD_HALF_W + 2.8 + randf() * 1.5), 0.0,
			randf_range(1.6, 2.4), randf() * TAU
		)
		if randf() > 0.4:
			_place_along(
				CapybaraRushPaths.ROCK_EDGE,
				z + 3.0, side * (ROAD_HALF_W + 1.4 + randf()), 0.0,
				randf_range(0.7, 1.2), randf() * TAU
			)
		if fence_i % 3 == 0:
			_place_along(
				CapybaraRushPaths.FENCE_PICKET,
				z + 6.0, side * (ROAD_HALF_W - 0.4), 0.0,
				1.4, PI * 0.5
			)
		match fence_i % 6:
			1:
				_place_along(CapybaraRushPaths.FENCE_HALF, z + 4.5, -side * (LANE_WIDTH * 0.85), 0.0, 1.15, PI * 0.5)
			2:
				_place_along(CapybaraRushPaths.LOW_WALL, z + 7.0, side * (LANE_WIDTH * 0.9), 0.0, 0.95, 0.0)
			3:
				_place_along(CapybaraRushPaths.TRAFFIC_CONE, z + 5.0, 0.0, 0.0, 0.85, randf() * TAU)
			4:
				_place_along(CapybaraRushPaths.BUSH_ROUND, z + 2.0, side * (ROAD_HALF_W + 1.1), 0.0, randf_range(0.9, 1.35), randf() * TAU)
			5:
				_place_along(CapybaraRushPaths.GAP_EDGE, z + 8.0, -side * (ROAD_HALF_W - 0.2), 0.0, 1.1, PI * 0.5 * side)
			_:
				_place_along(CapybaraRushPaths.PICKUP_GLOW_PAD, z + 1.5, 0.0, 0.02, 0.7, 0.0)
		fence_i += 1
		z += randf_range(10.0, 15.0)
		flip *= -1.0


func _spawn_platforms() -> void:
	var z := 70.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 50.0:
		var lane := (i + 2) % LANE_COUNT
		var lateral := _lane_to_x(lane)
		var visual := _instance_fitted(CapybaraRushPaths.STEP_PLATFORM, PLATFORM_TOP_Y + 0.35, 0.0)
		if visual == null:
			visual = _make_stub_platform()
		var holder := Node3D.new()
		_world.add_child(holder)
		_path_place(holder, z, lateral, 0.0, 0.0)
		holder.add_child(visual)
		_platforms.append({
			"node": holder, "dist": z, "lateral": lateral, "top_y": PLATFORM_TOP_Y,
		})
		z += randf_range(55.0, 80.0)
		i += 1


func _make_stub_platform() -> Node3D:
	var root := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.72, 0.62, 0.88)
	for s in 3:
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		var w := 2.2 - float(s) * 0.15
		var h := 0.38
		box.size = Vector3(w, h, 1.6 - float(s) * 0.12)
		mi.mesh = box
		mi.position = Vector3(0.0, h * 0.5 + float(s) * h, -float(s) * 0.35)
		mi.material_override = mat
		root.add_child(mi)
	return root


func _spawn_speed_orbs() -> void:
	var z := 35.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 25.0:
		var lane := i % LANE_COUNT
		var lateral := _lane_to_x(lane)
		var visual := _instance_fitted(CapybaraRushPaths.SPEED_ORB, 0.85, 0.0)
		if visual == null:
			visual = _make_stub_speed_orb()
		var holder := Node3D.new()
		_world.add_child(holder)
		_path_place(holder, z, lateral, 0.55, 0.0)
		holder.add_child(visual)
		_speed_orbs.append({
			"node": holder, "dist": z, "lateral": lateral,
			"phase": randf() * TAU, "taken": false,
		})
		z += randf_range(22.0, 34.0)
		i += 1


func _make_stub_speed_orb() -> Node3D:
	var mi := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.38
	sph.height = 0.76
	mi.mesh = sph
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.78, 0.25)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.7, 0.2)
	mat.emission_energy_multiplier = 1.2
	mi.material_override = mat
	return mi


func _spawn_speed_lanes() -> void:
	## 程序化橙色加速条，贴在某一车道上
	var z := 90.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 60.0:
		var lane := (i * 2) % LANE_COUNT
		var lateral := _lane_to_x(lane)
		var seg_len := randf_range(14.0, 22.0)
		var holder := Node3D.new()
		_world.add_child(holder)
		_path_place(holder, z + seg_len * 0.5, lateral, 0.03, 0.0)
		var mi := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(LANE_WIDTH * 0.9, 0.04, seg_len)
		mi.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.55, 0.2)
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.45, 0.1)
		mat.emission_energy_multiplier = 0.9
		mi.material_override = mat
		holder.add_child(mi)
		# 简易箭头块
		for k in 3:
			var arrow := MeshInstance3D.new()
			var ab := BoxMesh.new()
			ab.size = Vector3(0.35, 0.05, 0.55)
			arrow.mesh = ab
			arrow.position = Vector3(0.0, 0.04, -seg_len * 0.3 + float(k) * 2.2)
			var am := StandardMaterial3D.new()
			am.albedo_color = Color(1.0, 0.92, 0.3)
			am.emission_enabled = true
			am.emission = Color(1.0, 0.85, 0.2)
			am.emission_energy_multiplier = 1.1
			arrow.material_override = am
			holder.add_child(arrow)
		_speed_lanes.append({
			"node": holder, "dist0": z, "dist1": z + seg_len, "lateral": lateral,
		})
		z += randf_range(45.0, 70.0)
		i += 1


func _try_collect_speed_orbs() -> void:
	var t := Time.get_ticks_msec() * 0.001
	for o in _speed_orbs:
		var node: Node3D = o.get("node")
		if node == null or not is_instance_valid(node):
			continue
		if bool(o.get("taken", false)):
			continue
		var phase: float = float(o.get("phase", 0.0))
		var dist: float = float(o.get("dist", 0.0))
		var lateral: float = float(o.get("lateral", 0.0))
		var bob_y := 0.55 + sin(t * 4.0 + phase) * 0.12
		_path_place(node, dist, lateral, bob_y, t * 1.8 + phase)
		if not _along_overlap(dist, lateral, 1.15, 1.05):
			continue
		o["taken"] = true
		node.visible = false
		_speed_buff_left = maxf(_speed_buff_left, SPEED_ORB_DURATION)


func _setup_camera() -> void:
	_cam = Camera3D.new()
	_cam.fov = 52.0
	_cam.near = 0.1
	_cam.far = 220.0
	add_child(_cam)
	_cam.current = true
	if _tower:
		var base := _tower.global_position + Vector3(0.0, TARGET_CAPY_HEIGHT * 0.4, 0.0)
		var ang := deg_to_rad(15.0)
		var back := 8.0
		# 角色朝 +Z 时，其右侧为 -X
		_cam.global_position = base + Vector3(-sin(ang) * back, 3.2, -cos(ang) * back)
	_update_camera()


func _update_camera() -> void:
	if _cam == null or _tower == null:
		return
	var base_y := TARGET_PILOT_HEIGHT * 0.35 if (_is_race() and _boosting) else TARGET_CAPY_HEIGHT * 0.4
	var base := _tower.global_position + Vector3(0.0, base_y, 0.0)
	var stack_h := 0.0 if _is_race() else float(maxi(_stack.size() - 1, 0)) * STACK_STEP_Y
	var dist := 8.0 + stack_h * 0.55
	var cam_y := 2.8 + stack_h * 0.28
	if _is_race() and _boosting:
		dist += 0.8
		cam_y += 0.35
	var ang := deg_to_rad(15.0)
	var desired: Vector3
	var look: Vector3
	if _path != null:
		var f: Dictionary = _path.frame_at(_progress)
		var tangent: Vector3 = f["tangent"]
		var right: Vector3 = f["right"]
		# 右后方：-tangent 为后，-right 为角色右侧（与旧直线赛道一致）
		desired = base - tangent * (dist * cos(ang)) - right * (dist * sin(ang)) + Vector3(0.0, cam_y, 0.0)
		look = base + tangent * 8.0 + Vector3(0.0, minf(stack_h * 0.22, 2.8), 0.0)
	else:
		desired = base + Vector3(-sin(ang) * dist, cam_y, -cos(ang) * dist)
		look = base + Vector3(0.0, minf(stack_h * 0.22, 2.8), 8.0)
	_cam.global_position = _cam.global_position.lerp(desired, 0.14)
	_cam.look_at(look, Vector3.UP)
	if _is_race():
		_cam.fov = lerpf(52.0, 66.0, 1.0 if _boosting else 0.0)
	else:
		_cam.fov = lerpf(50.0, 72.0, clampf(stack_h / 8.0, 0.0, 1.0))


func _setup_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_label = Label.new()
	_hud_label.position = Vector2(24, 24)
	_hud_label.add_theme_font_size_override("font_size", 22)
	_hud_label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.22))
	_hud_label.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.75))
	_hud_label.add_theme_constant_override("outline_size", 4)
	layer.add_child(_hud_label)
	_hud_tip = Label.new()
	_hud_tip.text = "空格/W跳跃 · 黄星加速 · 橙道加速"
	_hud_tip.position = Vector2(24, 110)
	_hud_tip.add_theme_font_size_override("font_size", 16)
	_hud_tip.add_theme_color_override("font_color", Color(0.25, 0.22, 0.35))
	layer.add_child(_hud_tip)


func _show_result_screen() -> void:
	if _result_ui != null:
		return
	if _hud_label:
		_hud_label.visible = false
	if _hud_tip:
		_hud_tip.visible = false

	var arrived := _stack.size()
	var unit := _character_display_name()

	_result_ui = CanvasLayer.new()
	_result_ui.layer = 30
	add_child(_result_ui)

	# 柔和粉紫遮罩，贴合粉彩场景
	var dim := ColorRect.new()
	dim.color = Color(0.62, 0.72, 0.92, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_ui.add_child(dim)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_ui.add_child(root)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -250
	card.offset_right = 250
	card.offset_top = -280
	card.offset_bottom = 280
	card.add_theme_stylebox_override("panel", _cartoon_panel_style(
		Color(1.0, 0.97, 0.98),
		Color(1.0, 0.72, 0.82),
		28.0,
		5.0
	))
	root.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	card.add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	margin.add_child(v)

	var badge := Label.new()
	badge.text = "竞速通关" if _is_race() else "通关啦"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color(0.95, 0.45, 0.62))
	v.add_child(badge)

	var title := Label.new()
	title.text = "到达终点！"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	v.add_child(title)

	var sub := Label.new()
	sub.text = "本次 · %s · %s" % [unit, ("竞速" if _is_race() else "叠塔")]
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.55, 0.42, 0.58))
	v.add_child(sub)

	var hero := Label.new()
	if _is_race():
		hero.text = "%d" % _ship_count
	else:
		hero.text = "%d" % arrived
	hero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero.add_theme_font_size_override("font_size", 72)
	hero.add_theme_color_override("font_color", Color(0.98, 0.42, 0.58))
	v.add_child(hero)

	var hero_cap := Label.new()
	if _is_race():
		hero_cap.text = "次登上飞船冲锋"
	else:
		hero_cap.text = "只%s抵达终点" % unit
	hero_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_cap.add_theme_font_size_override("font_size", 22)
	hero_cap.add_theme_color_override("font_color", Color(0.45, 0.32, 0.48))
	v.add_child(hero_cap)

	v.add_child(_result_stat_chip("碰撞", "%d 次" % _collision_count, Color(1.0, 0.93, 0.88)))
	if _is_race():
		v.add_child(_result_stat_chip("加速包", "%d 个" % _boost_pack_count, Color(1.0, 0.96, 0.86)))
		v.add_child(_result_stat_chip("飞船", "%d 艘" % _ship_count, Color(0.90, 0.96, 0.98)))
	else:
		v.add_child(_result_stat_chip("掉落", "%d 只" % _drop_count, Color(0.90, 0.96, 0.92)))
		v.add_child(_result_stat_chip("拾取", "%d 只" % _picked_count, Color(0.92, 0.93, 1.0)))

	var tip := Label.new()
	tip.text = "按 R / Enter 也能重开哦"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 16)
	tip.add_theme_color_override("font_color", Color(0.62, 0.55, 0.66))
	v.add_child(tip)

	var btn := Button.new()
	btn.text = "再来一局"
	btn.custom_minimum_size = Vector2(0, 58)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.98))
	btn.add_theme_stylebox_override("normal", _cartoon_panel_style(Color(1.0, 0.55, 0.68), Color(1.0, 0.78, 0.86), 22.0, 0.0))
	btn.add_theme_stylebox_override("hover", _cartoon_panel_style(Color(1.0, 0.62, 0.74), Color(1.0, 0.84, 0.90), 22.0, 0.0))
	btn.add_theme_stylebox_override("pressed", _cartoon_panel_style(Color(0.92, 0.48, 0.62), Color(1.0, 0.72, 0.82), 22.0, 0.0))
	btn.pressed.connect(func() -> void: get_tree().reload_current_scene())
	v.add_child(btn)

	# 轻弹入场
	card.scale = Vector2(0.82, 0.82)
	card.pivot_offset = Vector2(250, 280)
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(card, "scale", Vector2.ONE, 0.45)


func _cartoon_panel_style(bg: Color, border: Color, radius: float, border_w: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = int(radius)
	sb.corner_radius_top_right = int(radius)
	sb.corner_radius_bottom_left = int(radius)
	sb.corner_radius_bottom_right = int(radius)
	sb.border_color = border
	sb.border_width_left = int(border_w)
	sb.border_width_top = int(border_w)
	sb.border_width_right = int(border_w)
	sb.border_width_bottom = int(border_w)
	sb.shadow_color = Color(0.55, 0.35, 0.5, 0.22)
	sb.shadow_size = 12
	sb.shadow_offset = Vector2(0, 6)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb


func _result_stat_chip(name: String, value: String, bg: Color) -> Control:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", _cartoon_panel_style(bg, Color(1, 1, 1, 0.65), 18.0, 2.0))
	var inner := HBoxContainer.new()
	row.add_child(inner)
	var left := Label.new()
	left.text = name
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_font_size_override("font_size", 22)
	left.add_theme_color_override("font_color", Color(0.42, 0.32, 0.45))
	var right := Label.new()
	right.text = value
	right.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_theme_font_size_override("font_size", 26)
	right.add_theme_color_override("font_color", Color(0.95, 0.38, 0.55))
	inner.add_child(left)
	inner.add_child(right)
	return row


func _update_hud() -> void:
	if _hud_label == null or _finished:
		return
	var track_len := _track_len()
	var pct := int((_progress / maxf(track_len, 1.0)) * 100.0)
	var speed := _current_run_speed()
	var remain_s := maxf((track_len - _progress) / maxf(speed, 0.01), 0.0)
	var speed_txt := ""
	if _speed_buff_left > 0.0:
		speed_txt += " 星加速%.1fs" % _speed_buff_left
	if _on_speed_lane:
		speed_txt += " 赛道加速"
	if not _grounded:
		speed_txt += " 跳跃中"
	elif _on_platform:
		speed_txt += " 上台阶"
	if _is_race():
		var boost_txt := ("冲锋 %.1fs" % _boost_time_left) if _boosting else "未冲锋"
		_hud_label.text = "%s 竞速  约剩 %.0fs  进度 %d%%\n车道 %d/%d · 飞船 %d · %s%s" % [
			_character_display_name(), remain_s, pct, _lane + 1, LANE_COUNT,
			_ship_count, boost_txt, speed_txt
		]
		return
	var moving := _is_moving_for_drop()
	var violent := _is_violent_move()
	var risk := 0.0
	if _stack.size() >= MIN_STACK_TO_DROP and moving:
		risk = _move_drop_chance_per_sec() * 100.0
	var state := "剧烈!" if violent else ("移动中" if moving else "静止")
	_hud_label.text = "%s Rush  约剩 %.0fs  进度 %d%%\n车道 %d/%d · 叠高 %d · %s · 风险 %.0f%%%s" % [
		_character_display_name(), remain_s, pct, _lane + 1, LANE_COUNT, _stack.size(), state, risk, speed_txt
	]


func _place_along(path: String, dist: float, lateral: float, y: float, target_height: float, yaw: float = 0.0) -> void:
	var n := _instance_fitted(path, target_height, yaw)
	if n == null:
		return
	var holder := Node3D.new()
	_world.add_child(holder)
	_path_place(holder, dist, lateral, y, 0.0)
	holder.add_child(n)


func _place_model(path: String, pos: Vector3, target_height: float, yaw: float = 0.0) -> void:
	var n := _instance_fitted(path, target_height, yaw)
	if n == null:
		return
	var holder := Node3D.new()
	holder.position = pos
	holder.add_child(n)
	_world.add_child(holder)


func _instance_fitted(path: String, target_height: float, yaw: float = 0.0) -> Node3D:
	# 新入库的 .glb 可能尚未进 ResourceLoader 缓存，仍允许 FileAccess 直读
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		push_warning("Missing model: %s" % path)
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var raw: Node3D = packed.instantiate() as Node3D
	if raw == null:
		return null

	var wrap := Node3D.new()
	wrap.add_child(raw)
	add_child(wrap)
	var aabb := _local_aabb(wrap)
	remove_child(wrap)

	if aabb.size.y < 0.01:
		aabb = AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1, 1))
	var s := target_height / aabb.size.y
	raw.scale = Vector3.ONE * s
	raw.position = Vector3(
		-(aabb.position.x + aabb.size.x * 0.5) * s,
		-aabb.position.y * s,
		-(aabb.position.z + aabb.size.z * 0.5) * s
	)
	wrap.rotation.y = yaw
	return wrap


func _local_aabb(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var inv := root.global_transform.affine_inverse()
	for node in _find_meshes(root):
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var local := mi.mesh.get_aabb()
		var xf := inv * mi.global_transform
		for i in 8:
			var pt: Vector3 = xf * local.get_endpoint(i)
			if first:
				result = AABB(pt, Vector3.ZERO)
				first = false
			else:
				result = result.expand(pt)
	if first:
		return AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1, 1))
	return result


func _find_meshes(node: Node) -> Array:
	var out: Array = []
	if node is MeshInstance3D:
		out.append(node)
	for c in node.get_children():
		out.append_array(_find_meshes(c))
	return out
