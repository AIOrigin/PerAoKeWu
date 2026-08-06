extends Node3D

## Capybara Rush 原型：三道自动跑 + 拾取叠塔。
## 打开 capybara_rush.tscn 后按 F6 运行。

const LANE_COUNT := 3
const LANE_WIDTH := 2.4
const ROAD_HALF_W := 4.2
const TRACK_LENGTH := 600.0  # ~50s @ RUN_SPEED 12
const RUN_SPEED := 12.0
const TARGET_DURATION_SEC := 50.0
const LANE_LERP := 10.0
const BOB_AMP := 0.06
const BOB_FREQ := 9.0
## 模型高度（贴地后）；叠层间距略小于身高以便看起来踩在背上
const TARGET_CAPY_HEIGHT := 1.05
const STACK_STEP_Y := 0.72
## 朝跑道前进 +Z（背对相机）；此前 PI/2 会朝向相机
const CAPY_FORWARD_YAW := -PI * 0.5
const QINGQING_FORWARD_YAW := -PI * 0.5
const CHAR_CAPYBARA := "capybara"
const CHAR_QINGQING := "qingqing"
const PICKUP_RADIUS_X := 1.15
const PICKUP_RADIUS_Z := 1.4
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
var _playing := false
var _select_ui: CanvasLayer
var _result_ui: CanvasLayer
var _select_spin_pivots: Array[Node3D] = []
var _collision_count := 0
var _drop_count := 0
var _picked_count := 0
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


func _ready() -> void:
	_world = Node3D.new()
	_world.name = "World"
	add_child(_world)
	_setup_environment()
	_build_track()
	_scatter_props()
	_spawn_clouds()
	_setup_camera()
	_setup_hud()
	_setup_character_select()
	_lane_x = _lane_to_x(_lane)


func _unhandled_input(event: InputEvent) -> void:
	# Esc：游戏中 / 开场 / 结算 均可回角色选择
	if _select_ui == null and (
		event.is_action_pressed("ui_cancel") or _key_pressed(event, KEY_ESCAPE)
	):
		get_tree().reload_current_scene()
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
	if _intro_showcasing:
		_update_intro_camera(delta)
		return
	if not _playing:
		return
	if _finished:
		return
	_progress = minf(_progress + RUN_SPEED * delta, TRACK_LENGTH)
	_prev_lane_x = _lane_x
	_lane_x = lerpf(_lane_x, _lane_to_x(_lane), 1.0 - exp(-LANE_LERP * delta))
	_update_sway(delta)
	_update_tower_motion()
	_update_pickup_bob()
	_try_collect_pickups()
	_try_hit_hazards()
	_try_drop_layers(delta)
	_update_camera()
	_update_hud()
	if _progress >= TRACK_LENGTH - 0.5:
		_finished = true
		_show_result_screen()


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
	_spawn_hazards()
	_spawn_pickups()
	_spawn_tower()
	_update_camera()
	if _character_id == CHAR_QINGQING:
		_start_qingqing_intro()
	else:
		_begin_gameplay()


func _begin_gameplay() -> void:
	_intro_showcasing = false
	_playing = true
	if _tower and not _stack.is_empty():
		var layer: Node3D = _stack[0]
		if layer and is_instance_valid(layer):
			layer.rotation = Vector3(0.0, _character_yaw(), 0.0)
			layer.position.y = 0.0
			layer.scale = Vector3.ONE
	if _hud_label:
		_hud_label.visible = true
	if _hud_tip:
		_hud_tip.visible = true
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
	var bob := sin(t * BOB_FREQ) * BOB_AMP
	_tower.position = Vector3(_lane_x, bob, _progress)
	# 换道倾斜 + 晃动额外抖动（高层视觉更晃）
	var lean_target := clampf((_lane_to_x(_lane) - _lane_x) * 0.22, -MAX_LEAN, MAX_LEAN)
	var wobble := sin(t * 14.0) * minf(_sway, 2.0) * 0.08
	_tower.rotation.z = lean_target + wobble
	# 拾取插入动画期间由 tween 接管各层位姿
	if _stack_animating:
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
		var pos: Vector3 = node.global_position
		var dx := absf(pos.x - _lane_x)
		var dz := absf(pos.z - _progress)
		if dx <= PICKUP_RADIUS_X and dz <= PICKUP_RADIUS_Z:
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


func _spawn_pickups() -> void:
	## 沿三道散落可叠水豚（约 50s 赛道加密分布）
	var z := 16.0
	var i := 0
	while z < TRACK_LENGTH - 22.0:
		var lane := i % LANE_COUNT
		_spawn_pickup_at(_lane_to_x(lane), z)
		if i % 3 == 0:
			var other := (lane + 1 + (i % 2)) % LANE_COUNT
			_spawn_pickup_at(_lane_to_x(other), z + 5.0)
		z += randf_range(10.0, 14.0)
		i += 1


func _spawn_hazards() -> void:
	## 草垛 / 木箱挡道：撞到猛晃并可能掉层
	var z := 28.0
	var i := 0
	while z < TRACK_LENGTH - 30.0:
		var lane := (i * 2 + 1) % LANE_COUNT
		var use_crate := (i % 2 == 1) and ResourceLoader.exists(CapybaraRushPaths.WOOD_CRATE)
		var path := CapybaraRushPaths.WOOD_CRATE if use_crate else CapybaraRushPaths.HAY_BALE
		var h := 1.35 if use_crate else 1.55
		var visual := _instance_fitted(path, h, 0.0)
		if visual == null and path != CapybaraRushPaths.HAY_BALE:
			visual = _instance_fitted(CapybaraRushPaths.HAY_BALE, 1.55, 0.0)
		if visual == null:
			visual = _make_stub_hazard(use_crate)
		var holder := Node3D.new()
		holder.position = Vector3(_lane_to_x(lane), 0.0, z)
		holder.add_child(visual)
		_world.add_child(holder)
		_hazards.append({"node": holder, "lane": lane, "hit": false})
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
		var node: Node3D = h.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var hz: float = node.global_position.z
		var hx: float = node.global_position.x
		if absf(hz - _progress) > 1.35:
			continue
		if absf(hx - _lane_x) > PICKUP_RADIUS_X * 1.05:
			continue
		h["hit"] = true
		_collision_count += 1
		# 撞障碍：必然掉一层
		_force_drop_from_hazard()
		var side := signf(hx - _lane_x)
		if is_zero_approx(side):
			side = 1.0
		node.position.x += side * 1.8
		node.position.y += 0.6
		node.rotate_z(side * 0.8)


func _spawn_clouds() -> void:
	var z := 8.0
	var i := 0
	while z < TRACK_LENGTH:
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
	holder.position = Vector3(x, 0.0, z)
	holder.add_child(visual)
	_world.add_child(holder)
	_pickups.append({"node": holder, "phase": randf() * TAU})


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


func _build_track() -> void:
	var road := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(ROAD_HALF_W * 2.0, 0.18, TRACK_LENGTH + 8.0)
	road.mesh = box
	road.position = Vector3(0.0, -0.09, TRACK_LENGTH * 0.5)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.82, 0.94)
	mat.roughness = 0.85
	road.material_override = mat
	_world.add_child(road)

	for i in range(1, LANE_COUNT):
		var line := MeshInstance3D.new()
		var lb := BoxMesh.new()
		lb.size = Vector3(0.08, 0.02, TRACK_LENGTH + 4.0)
		line.mesh = lb
		var mid := (LANE_COUNT - 1) * 0.5
		line.position = Vector3((float(i) - 0.5 - mid) * LANE_WIDTH, 0.01, TRACK_LENGTH * 0.5)
		var lm := StandardMaterial3D.new()
		lm.albedo_color = Color(0.98, 0.95, 1.0)
		lm.emission_enabled = true
		lm.emission = Color(0.9, 0.85, 1.0)
		lm.emission_energy_multiplier = 0.35
		line.material_override = lm
		_world.add_child(line)

	for side in [-1.0, 1.0]:
		var water := MeshInstance3D.new()
		var wb := BoxMesh.new()
		wb.size = Vector3(18.0, 0.05, TRACK_LENGTH + 20.0)
		water.mesh = wb
		water.position = Vector3(side * (ROAD_HALF_W + 10.0), -0.2, TRACK_LENGTH * 0.5)
		var wm := StandardMaterial3D.new()
		wm.albedo_color = Color(0.55, 0.72, 0.88, 0.92)
		wm.roughness = 0.25
		wm.metallic = 0.15
		water.material_override = wm
		_world.add_child(water)


func _scatter_props() -> void:
	_place_model(CapybaraRushPaths.FINISH_ARCH, Vector3(0.0, 0.0, TRACK_LENGTH), 3.2)

	var z := 10.0
	var flip := 1.0
	var fence_i := 0
	while z < TRACK_LENGTH - 8.0:
		var side := flip
		_place_model(
			CapybaraRushPaths.TREE_LOLLIPOP,
			Vector3(side * (ROAD_HALF_W + 2.8 + randf() * 1.5), 0.0, z),
			randf_range(1.6, 2.4),
			randf() * TAU
		)
		if randf() > 0.4:
			_place_model(
				CapybaraRushPaths.ROCK_EDGE,
				Vector3(side * (ROAD_HALF_W + 1.4 + randf()), 0.0, z + 3.0),
				randf_range(0.7, 1.2),
				randf() * TAU
			)
		if fence_i % 3 == 0:
			_place_model(
				CapybaraRushPaths.FENCE_PICKET,
				Vector3(side * (ROAD_HALF_W - 0.4), 0.0, z + 6.0),
				1.4,
				PI * 0.5
			)
		fence_i += 1
		z += randf_range(10.0, 15.0)
		flip *= -1.0


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
	# 右后方约 15°（角色右侧 = -X）
	var base := _tower.global_position + Vector3(0.0, TARGET_CAPY_HEIGHT * 0.4, 0.0)
	var stack_h := float(maxi(_stack.size() - 1, 0)) * STACK_STEP_Y
	var dist := 8.0 + stack_h * 0.55
	var cam_y := 2.8 + stack_h * 0.28
	var ang := deg_to_rad(15.0)
	var desired := base + Vector3(-sin(ang) * dist, cam_y, -cos(ang) * dist)
	_cam.global_position = _cam.global_position.lerp(desired, 0.14)
	# 略看向塔身中下部，兼顾前方赛道
	var look := base + Vector3(0.0, minf(stack_h * 0.22, 2.8), 8.0)
	_cam.look_at(look, Vector3.UP)
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
	_hud_tip.text = "移动就有概率掉 · 超8层更脆 · 撞障碍必掉"
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
	badge.text = "通关啦"
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
	sub.text = "本次角色 · %s" % unit
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 20)
	sub.add_theme_color_override("font_color", Color(0.55, 0.42, 0.58))
	v.add_child(sub)

	var hero := Label.new()
	hero.text = "%d" % arrived
	hero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero.add_theme_font_size_override("font_size", 72)
	hero.add_theme_color_override("font_color", Color(0.98, 0.42, 0.58))
	v.add_child(hero)

	var hero_cap := Label.new()
	hero_cap.text = "只%s抵达终点" % unit
	hero_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_cap.add_theme_font_size_override("font_size", 22)
	hero_cap.add_theme_color_override("font_color", Color(0.45, 0.32, 0.48))
	v.add_child(hero_cap)

	v.add_child(_result_stat_chip("碰撞", "%d 次" % _collision_count, Color(1.0, 0.93, 0.88)))
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
	var pct := int((_progress / TRACK_LENGTH) * 100.0)
	var remain_s := maxf((TRACK_LENGTH - _progress) / RUN_SPEED, 0.0)
	var moving := _is_moving_for_drop()
	var violent := _is_violent_move()
	var risk := 0.0
	if _stack.size() >= MIN_STACK_TO_DROP and moving:
		risk = _move_drop_chance_per_sec() * 100.0
	var state := "剧烈!" if violent else ("移动中" if moving else "静止")
	_hud_label.text = "%s Rush  约剩 %.0fs  进度 %d%%\n车道 %d / %d · 叠高 %d · %s · 风险 %.0f%%/s" % [
		_character_display_name(), remain_s, pct, _lane + 1, LANE_COUNT, _stack.size(), state, risk
	]


func _place_model(path: String, pos: Vector3, target_height: float, yaw: float = 0.0) -> void:
	var n := _instance_fitted(path, target_height, yaw)
	if n == null:
		return
	var holder := Node3D.new()
	holder.position = pos
	holder.add_child(n)
	_world.add_child(holder)


func _instance_fitted(path: String, target_height: float, yaw: float = 0.0) -> Node3D:
	if not ResourceLoader.exists(path):
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
