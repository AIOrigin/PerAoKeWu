class_name CapybaraFinish
extends RefCounted

## 终点台阶生成、爬阶 ceremony、齐舞与镜头（从 capybara_rush.gd 拆出）

const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")
const MeshUtil := preload("res://assets/maps/route_levels/capybara_rush/capybara_mesh_util.gd")

const LANE_COUNT := 3
const STACK_STEP_Y := 1.18
const FINISH_STEP_COUNT := 18
const FINISH_STEP_RISE := 1.22
const FINISH_STEP_DEPTH := 2.25
const FINISH_STEP_WIDTH := 8.8
const FINISH_PATH_WIDTH := 2.15
const FINISH_MELON_SCALE := 1.25
const FINISH_PATH_SURFACE_Y := 0.05
const FINISH_STEP_FOOT_EXTRA := 0.05
const FINISH_MAX_PER_STEP := 1
const FINISH_CLIMB_SEC_PER_STEP := 0.38
const FINISH_CLIMB_ARC := 0.34
const FINISH_TURN_SEC := 0.55
const FINISH_DANCE_HOLD_SEC := 2.8
const FINISH_LEAN_AMP := 0.18
const FINISH_LEAN_HALF_SEC := 0.30

var steps: Array[Dictionary] = []
var stairs_root: Node3D
var ceremony_active := false
var focus_step := 0
var climb_left_upto := -1
var dancers: Array[Dictionary] = []
var _repack_from_y: Array[float] = []
var _host: Node


func _init(host: Node) -> void:
	_host = host


func clear() -> void:
	steps.clear()
	stairs_root = null
	dancers.clear()
	ceremony_active = false
	focus_step = 0
	climb_left_upto = -1


func spawn_stairs() -> void:
	_spawn_finish_stairs()


func start_ceremony() -> void:
	_start_finish_ceremony()


func update_camera(delta: float) -> void:
	_update_finish_camera(delta)


func _finish_end_frame() -> Dictionary:
	var track_len: float = _host._track_len()
	if _host._path != null:
		return _host._path.frame_at(track_len)
	return {
		"pos": Vector3(0.0, 0.0, track_len),
		"tangent": Vector3(0.0, 0.0, 1.0),
		"right": Vector3(1.0, 0.0, 0.0),
		"yaw": 0.0,
	}


func _spawn_finish_stairs() -> void:
	steps.clear()
	stairs_root = Node3D.new()
	stairs_root.name = "FinishStairs"
	_host._world.add_child(stairs_root)

	var f := _finish_end_frame()
	var origin: Vector3 = f["pos"]
	var tangent: Vector3 = f["tangent"]
	var right: Vector3 = f["right"]
	var yaw: float = float(f["yaw"])

	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.42, 0.78, 0.38)
	grass.roughness = 0.92
	var dirt := StandardMaterial3D.new()
	dirt.albedo_color = Color(0.78, 0.68, 0.48)
	dirt.roughness = 0.9
	var path_mat := StandardMaterial3D.new()
	path_mat.albedo_color = Color(0.93, 0.88, 0.72)
	path_mat.roughness = 0.88

	for i in FINISH_STEP_COUNT:
		var along := 0.9 + float(i) * FINISH_STEP_DEPTH
		var top_y := float(i) * FINISH_STEP_RISE
		var step_h := FINISH_STEP_RISE + 0.08
		var center := origin + tangent * along + Vector3(0.0, top_y, 0.0)

		var step := Node3D.new()
		step.name = "Step_%d" % i
		stairs_root.add_child(step)
		step.global_position = center
		step.rotation.y = yaw

		# 绿色草皮块
		var body := MeshInstance3D.new()
		body.mesh = MeshUtil.rounded_box(Vector3(FINISH_STEP_WIDTH, step_h, FINISH_STEP_DEPTH * 0.92), 0.08)
		body.position = Vector3(0.0, -step_h * 0.5, 0.0)
		body.material_override = grass
		body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		step.add_child(body)

		# 侧面泥土
		var side_mi := MeshInstance3D.new()
		side_mi.mesh = MeshUtil.rounded_box(Vector3(FINISH_STEP_WIDTH * 0.98, step_h * 0.85, 0.12), 0.04)
		side_mi.position = Vector3(0.0, -step_h * 0.45, FINISH_STEP_DEPTH * 0.42)
		side_mi.material_override = dirt
		side_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		step.add_child(side_mi)

		# 三道浅色落脚道（左/中/右），与赛道车道对齐
		for lane_i in LANE_COUNT:
			var path_mi := MeshInstance3D.new()
			path_mi.mesh = MeshUtil.rounded_box(Vector3(FINISH_PATH_WIDTH, 0.06, FINISH_STEP_DEPTH * 0.78), 0.025)
			path_mi.position = Vector3(_host._lane_to_x(lane_i), 0.02, 0.0)
			path_mi.material_override = path_mat
			path_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			step.add_child(path_mi)

		# 西瓜固定在台阶正中；爬阶落点跟玩家车道，吃瓜不要求同道
		var melon := _make_watermelon_slice()
		_host._disable_subtree_shadows(melon)
		step.add_child(melon)
		melon.position = Vector3(0.0, 0.18, 0.0)
		melon.scale = Vector3.ONE * FINISH_MELON_SCALE
		melon.rotation = Vector3(0.0, deg_to_rad(-18.0), 0.0)

		var land_pos := center + Vector3(0.0, FINISH_PATH_SURFACE_Y, 0.0)
		steps.append({
			"node": step,
			"land": land_pos,
			"surface_y": land_pos.y,
			"right": right,
			"yaw": yaw,
			"melon": melon,
			"melon_lane": -1,  # 中央瓜：落到该阶即可吃
			"eaten": false,
		})


func _finish_step_floor_y(step: Dictionary, stack_offset_y: float = 0.0) -> float:
	return (
		float(step.get("surface_y", (step["land"] as Vector3).y))
		+ stack_offset_y
		+ _host._foot_lift_for_path(_host._character_model_path())
		+ FINISH_STEP_FOOT_EXTRA
	)

func _place_actor_on_finish_land(actor: Node3D, land: Vector3, floor_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	actor.global_position = Vector3(land.x, floor_y, land.z)
	actor.force_update_transform()
	_host._snap_actor_feet_to_world_y(actor, floor_y)


func _finish_climb_point(step: Dictionary, lane: int = -1) -> Vector3:
	## 爬阶 tween 目标：XZ 跟车道，Y 用贴地高度（不是仅 path 顶面）
	var p := _finish_land_for_lane(step, lane)
	p.y = _finish_step_floor_y(step)
	return p


func _finish_land_for_lane(step: Dictionary, lane: int = -1) -> Vector3:
	## 台阶落点按当前（或指定）车道横移，避免左道冲线却落到正中间
	var use_lane: int = _host._lane if lane < 0 else lane
	var lat: float = _host._lane_to_x(use_lane)
	var right: Vector3 = step.get("right", Vector3.RIGHT)
	if right.length_squared() < 0.0001:
		right = Vector3.RIGHT
	else:
		right = right.normalized()
	return (step["land"] as Vector3) + right * lat


func _make_watermelon_slice() -> Node3D:
	## 优先 Tripo 西瓜切片；缺模型时回退程序楔形
	var fitted: Node3D = _host._instance_fitted(CapybaraRushPaths.WATERMELON_SLICE, 0.72, 0.0)
	if fitted != null:
		fitted.name = "Watermelon"
		return fitted
	var root := Node3D.new()
	root.name = "Watermelon"

	var rind_mat := StandardMaterial3D.new()
	rind_mat.albedo_color = Color(0.16, 0.52, 0.20)
	rind_mat.roughness = 0.82
	rind_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	var stripe_mat := StandardMaterial3D.new()
	stripe_mat.albedo_color = Color(0.42, 0.78, 0.36)
	stripe_mat.roughness = 0.8
	stripe_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	var pith_mat := StandardMaterial3D.new()
	pith_mat.albedo_color = Color(0.96, 0.97, 0.93)
	pith_mat.roughness = 0.72
	pith_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	var flesh_mat := StandardMaterial3D.new()
	flesh_mat.albedo_color = Color(0.91, 0.20, 0.30)
	flesh_mat.roughness = 0.45
	flesh_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	var seed_mat := StandardMaterial3D.new()
	seed_mat.albedo_color = Color(0.06, 0.04, 0.03)
	seed_mat.roughness = 0.5

	var flesh := MeshInstance3D.new()
	flesh.mesh = _build_wedge_mesh(0.48, 0.26, 0.36, 0.0)
	flesh.material_override = flesh_mat
	flesh.position = Vector3(0.0, 0.13, 0.0)
	root.add_child(flesh)

	var pith := MeshInstance3D.new()
	pith.mesh = _build_wedge_shell_mesh(0.50, 0.48, 0.28, 0.38, 0.04)
	pith.material_override = pith_mat
	pith.position = Vector3(0.0, 0.13, 0.0)
	root.add_child(pith)

	var rind := MeshInstance3D.new()
	rind.mesh = _build_wedge_shell_mesh(0.54, 0.50, 0.30, 0.40, 0.05)
	rind.material_override = rind_mat
	rind.position = Vector3(0.0, 0.13, 0.0)
	root.add_child(rind)

	var stripe := MeshInstance3D.new()
	var stripe_box := BoxMesh.new()
	stripe_box.size = Vector3(0.08, 0.22, 0.42)
	stripe.mesh = stripe_box
	stripe.material_override = stripe_mat
	stripe.position = Vector3(0.0, 0.13, -0.18)
	stripe.rotation.x = deg_to_rad(12.0)
	root.add_child(stripe)

	var seed_spots := [
		Vector3(-0.10, 0.28, 0.02),
		Vector3(0.02, 0.30, -0.04),
		Vector3(0.12, 0.27, 0.06),
		Vector3(-0.04, 0.24, 0.08),
		Vector3(0.06, 0.25, -0.08),
		Vector3(-0.14, 0.22, -0.02),
		Vector3(0.0, 0.22, 0.0),
		Vector3(0.10, 0.23, 0.0),
	]
	for sp in seed_spots:
		var seed := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = 0.03
		sm.height = 0.06
		seed.mesh = sm
		seed.material_override = seed_mat
		seed.position = sp
		root.add_child(seed)
	return root


func _build_wedge_mesh(width: float, height: float, depth: float, y_lift: float) -> ArrayMesh:
	## 三角形柱：尖端 +Z，底边 -Z（西瓜切片轮廓）
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var hw := width * 0.5
	var tip := Vector3(0.0, y_lift, depth * 0.55)
	var bl := Vector3(-hw, y_lift, -depth * 0.45)
	var br := Vector3(hw, y_lift, -depth * 0.45)
	var tip2 := tip + Vector3(0.0, height, 0.0)
	var bl2 := bl + Vector3(0.0, height, 0.0)
	var br2 := br + Vector3(0.0, height, 0.0)
	# 顶面（切面）
	_st_tri(st, tip2, br2, bl2)
	# 底面
	_st_tri(st, tip, bl, br)
	# 三侧面
	_st_quad(st, tip, tip2, br2, br)
	_st_quad(st, br, br2, bl2, bl)
	_st_quad(st, bl, bl2, tip2, tip)
	st.generate_normals()
	return st.commit()


func _build_wedge_shell_mesh(w_out: float, w_in: float, h: float, d: float, thick: float) -> ArrayMesh:
	## 外轮廓略大的三角壳（瓜皮/内皮）
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var y0 := 0.0
	var y1 := h
	# 外三角
	var o_tip := Vector3(0.0, y0, d * 0.55)
	var o_bl := Vector3(-w_out * 0.5, y0, -d * 0.45)
	var o_br := Vector3(w_out * 0.5, y0, -d * 0.45)
	var o_tip2 := o_tip + Vector3(0.0, y1, 0.0)
	var o_bl2 := o_bl + Vector3(0.0, y1, 0.0)
	var o_br2 := o_br + Vector3(0.0, y1, 0.0)
	# 内三角（收缩）
	var scale := w_in / maxf(w_out, 0.001)
	var i_tip := o_tip * Vector3(scale, 1.0, scale) + Vector3(0.0, thick * 0.5, 0.0)
	var i_bl := o_bl * Vector3(scale, 1.0, scale) + Vector3(0.0, thick * 0.5, 0.0)
	var i_br := o_br * Vector3(scale, 1.0, scale) + Vector3(0.0, thick * 0.5, 0.0)
	var i_tip2 := o_tip2 * Vector3(scale, 1.0, scale) - Vector3(0.0, thick * 0.5, 0.0)
	var i_bl2 := o_bl2 * Vector3(scale, 1.0, scale) - Vector3(0.0, thick * 0.5, 0.0)
	var i_br2 := o_br2 * Vector3(scale, 1.0, scale) - Vector3(0.0, thick * 0.5, 0.0)
	# 外侧面
	_st_quad(st, o_tip, o_tip2, o_br2, o_br)
	_st_quad(st, o_br, o_br2, o_bl2, o_bl)
	_st_quad(st, o_bl, o_bl2, o_tip2, o_tip)
	# 顶/底外环带
	_st_quad(st, o_tip2, i_tip2, i_br2, o_br2)
	_st_quad(st, o_br2, i_br2, i_bl2, o_bl2)
	_st_quad(st, o_bl2, i_bl2, i_tip2, o_tip2)
	_st_quad(st, o_tip, o_br, i_br, i_tip)
	_st_quad(st, o_br, o_bl, i_bl, i_br)
	_st_quad(st, o_bl, o_tip, i_tip, i_bl)
	st.generate_normals()
	return st.commit()


func _st_tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)


func _st_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	_st_tri(st, a, b, c)
	_st_tri(st, a, c, d)

func _start_finish_ceremony() -> void:
	if ceremony_active:
		return
	ceremony_active = true
	_host._watermelon_count = 0
	focus_step = 0
	dancers.clear()
	if _host._hud_tip:
		_host._hud_tip.visible = true
		_host._hud_tip.text = "Climb up · Leave one on each step for watermelon!"
	if _host._hud_label:
		_host._hud_label.text = "Finish!"
	_run_finish_stairs_sequence()


func _run_finish_stairs_sequence() -> void:
	if steps.is_empty():
		ceremony_active = false
		_host._show_result_screen()
		return

	# 竞速：单角色连续爬阶
	if _host._is_race():
		_run_finish_stairs_race()
		return

	# 叠塔：连续滑上各阶（带轻微弧线），过阶瞬间留下一只，不再一阶一停
	if _host._tower == null or _host._stack.is_empty():
		ceremony_active = false
		_host._show_result_screen()
		return

	_host._repack_stack_heights()
	for layer in _host._stack:
		if layer != null and is_instance_valid(layer):
			layer.position = Vector3(0.0, layer.position.y, 0.0)
			layer.rotation = Vector3(0.0, _host._character_yaw(), 0.0)

	dancers.clear()
	climb_left_upto = -1
	focus_step = 0

	var climbs := mini(_host._stack.size(), steps.size())
	if climbs <= 0:
		ceremony_active = false
		_host._show_result_screen()
		return

	var points: Array[Vector3] = []
	points.append(_host._tower.global_position)
	for i in climbs:
		points.append(_finish_climb_point(steps[i]))

	var first_yaw := float(steps[0]["yaw"])
	_host._tower.rotation = Vector3(0.0, first_yaw, 0.0)
	if not _host._stack.is_empty():
		var top: Node3D = _host._stack[_host._stack.size() - 1]
		if top != null and is_instance_valid(top):
			_host._play_capy_clip(top, ["run"], true)

	var total_sec := float(climbs) * FINISH_CLIMB_SEC_PER_STEP
	var tw := _host.create_tween()
	tw.set_parallel(false)
	tw.tween_method(
		_finish_climb_tower_along.bind(points, climbs),
		0.0,
		float(climbs),
		total_sec
	).set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback(_finish_climb_tower_finalize.bind(climbs, points))
	tw.tween_callback(_park_remaining_finish_stack)
	tw.tween_callback(_begin_finish_group_dance)
	tw.tween_interval(FINISH_TURN_SEC + FINISH_DANCE_HOLD_SEC)
	tw.tween_callback(func() -> void:
		ceremony_active = false
		_host._show_result_screen()
	)


func _finish_climb_tower_along(t: float, points: Array[Vector3], climbs: int) -> void:
	if _host._tower == null or not is_instance_valid(_host._tower) or climbs <= 0:
		return
	var capped := clampf(t, 0.0, float(climbs))
	# points[0]=起点, points[1]=第0阶落点 …
	var seg := mini(int(floor(capped)), climbs - 1)
	var frac := capped - float(seg)
	if capped >= float(climbs):
		seg = climbs - 1
		frac = 1.0
	var a: Vector3 = points[seg]
	var b: Vector3 = points[seg + 1]
	var frac_eased := _smooth01(frac)
	var pos := a.lerp(b, frac_eased)
	# 连续弧线：用时间 frac 保证每阶中段最高，起落更圆
	pos.y += sin(PI * frac) * FINISH_CLIMB_ARC
	_host._tower.global_position = pos
	focus_step = seg
	_lerp_tower_step_yaw(seg, frac_eased)
	_apply_finish_stack_repack(frac_eased)

	# 到达某一阶落点时留下一只（只触发一次）
	while climb_left_upto + 1 < climbs and capped + 0.0001 >= float(climb_left_upto + 1):
		var si := climb_left_upto + 1
		climb_left_upto = si
		if si < 0 or si >= steps.size():
			break
		var step: Dictionary = steps[si]
		var step_yaw: float = float(step["yaw"])
		_try_eat_finish_melon(step, _host._lane, _host._tower)
		_leave_one_on_finish_step(si, step_yaw)


func _smooth01(t: float) -> float:
	var x := clampf(t, 0.0, 1.0)
	return 0.5 - 0.5 * cos(PI * x)


func _lerp_tower_step_yaw(seg: int, frac: float) -> void:
	if _host._tower == null or not is_instance_valid(_host._tower) or steps.is_empty():
		return
	var i0 := clampi(seg, 0, steps.size() - 1)
	var i1 := clampi(seg + 1, 0, steps.size() - 1)
	var yaw0 := float(steps[i0]["yaw"])
	var yaw1 := float(steps[i1]["yaw"])
	_host._tower.rotation = Vector3(0.0, lerp_angle(yaw0, yaw1, frac), 0.0)


func _apply_finish_stack_repack(k: float) -> void:
	if _repack_from_y.size() != _host._stack.size():
		return
	for i in _host._stack.size():
		var layer: Node3D = _host._stack[i]
		if layer == null or not is_instance_valid(layer):
			continue
		layer.position.x = 0.0
		layer.position.z = 0.0
		layer.position.y = lerpf(_repack_from_y[i], float(i) * STACK_STEP_Y, k)
	if k >= 0.995:
		_repack_from_y.clear()


func _finish_climb_tower_finalize(climbs: int, points: Array[Vector3]) -> void:
	## 补齐末尾可能因浮点没触发的落阶
	if _host._tower != null and is_instance_valid(_host._tower) and points.size() > climbs:
		_host._tower.global_position = points[climbs]
	_apply_finish_stack_repack(1.0)
	while climb_left_upto + 1 < climbs:
		var si := climb_left_upto + 1
		climb_left_upto = si
		if si < 0 or si >= steps.size():
			break
		var step: Dictionary = steps[si]
		var step_yaw: float = float(step["yaw"])
		_try_eat_finish_melon(step, _host._lane, _host._tower)
		_leave_one_on_finish_step(si, step_yaw)


func _run_finish_stairs_race() -> void:
	var actors: Array[Node3D] = []
	if _host._race_visual != null and is_instance_valid(_host._race_visual):
		actors.append(_host._race_visual)
	elif _host._tower != null:
		for c in _host._tower.get_children():
			if c is Node3D:
				actors.append(c as Node3D)
				break
	if actors.is_empty():
		ceremony_active = false
		_host._show_result_screen()
		return

	var finish_lane: int = _host._lane
	dancers.clear()
	var actor: Node3D = actors[0]
	# 单角色连续爬几阶吃西瓜
	var climbs := mini(3, steps.size())
	var points: Array[Vector3] = []
	points.append(actor.global_position)
	for i in climbs:
		points.append(_finish_climb_point(steps[i], finish_lane))
	climb_left_upto = -1
	var total_sec := float(climbs) * FINISH_CLIMB_SEC_PER_STEP
	var tw := _host.create_tween()
	tw.set_parallel(false)
	tw.tween_method(
		_finish_climb_actor_along.bind(actor, points, climbs, finish_lane),
		0.0,
		float(climbs),
		total_sec
	).set_trans(Tween.TRANS_LINEAR)
	tw.tween_callback(func() -> void:
		if actor != null and is_instance_valid(actor) and points.size() > climbs:
			var step: Dictionary = steps[climbs - 1]
			var land: Vector3 = points[climbs]
			var floor_y := _finish_step_floor_y(step)
			_place_actor_on_finish_land(actor, land, floor_y)
		if climbs > 0:
			var step2: Dictionary = steps[climbs - 1]
			_register_finish_dancer(
				actor,
				float(step2["yaw"]),
				_finish_step_floor_y(step2),
				climbs - 1
			)
	)
	tw.tween_callback(_begin_finish_group_dance)
	tw.tween_interval(FINISH_TURN_SEC + FINISH_DANCE_HOLD_SEC)
	tw.tween_callback(func() -> void:
		ceremony_active = false
		_host._show_result_screen()
	)


func _finish_climb_actor_along(t: float, actor: Node3D, points: Array[Vector3], climbs: int, finish_lane: int) -> void:
	if actor == null or not is_instance_valid(actor) or climbs <= 0:
		return
	var capped := clampf(t, 0.0, float(climbs))
	var seg := mini(int(floor(capped)), climbs - 1)
	var frac := capped - float(seg)
	if capped >= float(climbs):
		seg = climbs - 1
		frac = 1.0
	var pos: Vector3 = points[seg].lerp(points[seg + 1], _smooth01(frac))
	pos.y += sin(PI * frac) * FINISH_CLIMB_ARC
	actor.global_position = pos
	focus_step = seg
	while climb_left_upto + 1 < climbs and capped + 0.0001 >= float(climb_left_upto + 1):
		var si := climb_left_upto + 1
		climb_left_upto = si
		var step: Dictionary = steps[si]
		actor.rotation = Vector3(0.0, float(step["yaw"]) + _host._character_yaw(), 0.0)
		_try_eat_finish_melon(step, finish_lane, actor)


func _prepare_finish_tower_step(step_i: int, step_yaw: float) -> void:
	focus_step = step_i
	if _host._tower == null or not is_instance_valid(_host._tower):
		return
	_host._tower.rotation = Vector3(0.0, step_yaw, 0.0)
	# 只给顶层播跳跃，避免整塔每层重启动画造成卡顿
	if not _host._stack.is_empty():
		var top: Node3D = _host._stack[_host._stack.size() - 1]
		if top != null and is_instance_valid(top):
			_host._play_capy_clip(top, ["jump"], false)


func _leave_one_on_finish_step(step_i: int, step_yaw: float) -> void:
	## 最底层留下站在本阶；其余叠塔继续往上跳
	if _host._stack.is_empty() or _host._tower == null or not is_instance_valid(_host._tower):
		return
	if step_i < 0 or step_i >= steps.size():
		return
	var layer: Node3D = _host._stack[0]
	_host._stack.remove_at(0)
	if layer == null or not is_instance_valid(layer):
		_host._repack_stack_heights()
		return
	var land: Vector3 = _finish_land_for_lane(steps[step_i])
	var floor_y := _finish_step_floor_y(steps[step_i])
	_host._tower.remove_child(layer)
	_host._world.add_child(layer)
	layer.rotation = Vector3(0.0, step_yaw + _host._character_yaw(), 0.0)
	_place_actor_on_finish_land(layer, land, floor_y)
	_host._stack_sys.park_stack_rider(layer)
	_register_finish_dancer(layer, step_yaw, floor_y, step_i)
	_repack_from_y.clear()
	for i in _host._stack.size():
		var remain: Node3D = _host._stack[i]
		if remain != null and is_instance_valid(remain):
			_repack_from_y.append(remain.position.y)
		else:
			_repack_from_y.append(float(i) * STACK_STEP_Y)


func _finish_step_dancer_count(step_i: int) -> int:
	var n := 0
	for d in dancers:
		if int(d.get("step_i", -1)) == step_i:
			n += 1
	return n


func _find_empty_finish_step() -> int:
	for i in range(steps.size() - 1, -1, -1):
		if _finish_step_dancer_count(i) < FINISH_MAX_PER_STEP:
			return i
	return -1


func _register_finish_dancer(actor: Node3D, step_yaw: float, floor_y: float = -1.0, step_i: int = -1) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	if floor_y < 0.0:
		floor_y = actor.global_position.y
	dancers.append({"node": actor, "step_yaw": step_yaw, "floor_y": floor_y, "step_i": step_i})


func _park_remaining_finish_stack() -> void:
	## 剩余层：优先填空阶（每阶最多一只）；台阶满则直接移除不展示
	if _host._stack.is_empty() or _host._tower == null or not is_instance_valid(_host._tower):
		return
	if steps.is_empty():
		return
	var remain: Array[Node3D] = _host._stack.duplicate()
	_host._stack.clear()
	var gpos: Vector3 = _host._tower.global_position
	for layer in remain:
		if layer == null or not is_instance_valid(layer):
			continue
		var step_i := _find_empty_finish_step()
		if step_i < 0:
			layer.queue_free()
			continue
		var step: Dictionary = steps[step_i]
		var step_yaw: float = float(step["yaw"])
		var land: Vector3 = _finish_land_for_lane(step)
		var floor_y := _finish_step_floor_y(step)
		_host._tower.remove_child(layer)
		_host._world.add_child(layer)
		layer.rotation = Vector3(0.0, step_yaw + _host._character_yaw(), 0.0)
		_place_actor_on_finish_land(layer, land, floor_y)
		_host._stack_sys.park_stack_rider(layer)
		_register_finish_dancer(layer, step_yaw, floor_y, step_i)
	_host._tower.global_position = gpos


func _set_actor_basis(actor: Node3D, basis: Basis) -> void:
	var t := actor.global_transform
	t.basis = basis.orthonormalized()
	actor.global_transform = t


func _finish_camera_face_yaw(step_yaw: float) -> float:
	## 镜头在台阶后方沿跑道看过来；转身 180° 面对镜头
	return step_yaw + _host._character_yaw() + PI


func _finish_celebrate_basis(face_yaw: float, lean: float = 0.0) -> Basis:
	## 保持四足趴地正立，只绕竖直轴对镜头 + 轻晃。
	## 以前绕 X/Z 抬 52°「坐立」会露肚皮/穿模，看起来像镂空黑块。
	return Basis(Vector3.UP, face_yaw + lean)


func _seat_actor_on_floor_y(actor: Node3D, floor_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	var first := true
	var min_y := 0.0
	for node in _host._find_meshes(actor):
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var local := mi.get_aabb()
		for i in 8:
			var pt: Vector3 = mi.global_transform * local.get_endpoint(i)
			if first:
				min_y = pt.y
				first = false
			else:
				min_y = minf(min_y, pt.y)
	if first:
		return
	actor.global_position.y += floor_y - min_y


func _begin_finish_group_dance() -> void:
	## 全员上完后：一起转向镜头，再左右轻晃
	if dancers.is_empty():
		return
	focus_step = mini(dancers.size() - 1, maxi(steps.size() - 1, 0))
	for i in dancers.size():
		var info: Dictionary = dancers[i]
		var actor: Node3D = info.get("node")
		var step_yaw: float = float(info.get("step_yaw", 0.0))
		var floor_y: float = float(info.get("floor_y", actor.global_position.y if actor != null else 0.0))
		if actor == null or not is_instance_valid(actor):
			continue
		_start_finish_silly_dance(actor, step_yaw, floor_y, float(i) * 0.06)


func _finish_turn_lerp(t: float, actor: Node3D, start_basis: Basis, target: Basis, floor_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	_set_actor_basis(actor, start_basis.slerp(target, t))
	_seat_actor_on_floor_y(actor, floor_y)


func _finish_lean_apply(lean: float, actor: Node3D, face_yaw: float, floor_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	_set_actor_basis(actor, _finish_celebrate_basis(face_yaw, lean))
	_seat_actor_on_floor_y(actor, floor_y)


func _start_finish_silly_dance(actor: Node3D, step_yaw: float, floor_y: float, delay_sec: float = 0.0) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	var face := _finish_camera_face_yaw(step_yaw)
	_host._snap_actor_feet_to_world_y(actor, floor_y)
	# 不停动画、不 reset 骨骼：硬掰坐立 + rest pose 才是镂空黑块的主因
	var start_basis := actor.global_transform.basis
	var target := _finish_celebrate_basis(face, 0.0)
	var tw := _host.create_tween()
	if delay_sec > 0.0:
		tw.tween_interval(delay_sec)
	tw.tween_method(
		_finish_turn_lerp.bind(actor, start_basis, target, floor_y),
		0.0,
		1.0,
		FINISH_TURN_SEC
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_on_finish_turned_to_camera.bind(actor, face, target, floor_y))


func _on_finish_turned_to_camera(actor: Node3D, face: float, target: Basis, floor_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	_set_actor_basis(actor, target)
	_seat_actor_on_floor_y(actor, floor_y)
	_host._play_capy_clip(actor, ["dance", "idle", "run"], true)
	_seat_actor_on_floor_y(actor, floor_y)


func _loop_finish_lean_dance(actor: Node3D, face_yaw: float, floor_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	var amp := FINISH_LEAN_AMP * (0.35 if _host._is_soft_skin_character() else 1.0)
	var lean_tw := _host.create_tween().set_loops()
	var apply := _finish_lean_apply.bind(actor, face_yaw, floor_y)
	lean_tw.tween_method(apply, 0.0, amp, FINISH_LEAN_HALF_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	lean_tw.tween_method(apply, amp, -amp, FINISH_LEAN_HALF_SEC * 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	lean_tw.tween_method(apply, -amp, 0.0, FINISH_LEAN_HALF_SEC) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _prepare_finish_actor(actor: Node3D, _land: Vector3, step_yaw: float, step_i: int = 0) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	focus_step = step_i
	# 竞速：从塔上解绑到世界
	var gpos := actor.global_position
	var parent := actor.get_parent()
	if parent != null:
		parent.remove_child(actor)
	_host._world.add_child(actor)
	actor.global_position = gpos
	actor.rotation = Vector3(0.0, step_yaw + _host._character_yaw(), 0.0)
	_host._play_capy_clip(actor, ["jump"], false)


func _try_eat_finish_melon(step: Dictionary, finish_lane: int, _actor: Node3D) -> void:
	if bool(step.get("eaten", false)):
		return
	var melon_lane := int(step.get("melon_lane", -1))
	# melon_lane < 0：中央西瓜，落到该阶即可；否则需对车道
	if melon_lane >= 0 and melon_lane != finish_lane:
		return
	var melon: Node3D = step.get("melon")
	if melon == null or not is_instance_valid(melon):
		return
	step["eaten"] = true
	_host._watermelon_count += 1
	_host._coin_score += _host._fruit_coin_value("watermelon")
	_host._play_sfx_fruit()
	var eat_tw := _host.create_tween()
	eat_tw.tween_property(melon, "scale", Vector3.ZERO, 0.22).set_trans(Tween.TRANS_BACK)
	eat_tw.tween_callback(func() -> void:
		if is_instance_valid(melon):
			melon.visible = false
	)
	if _host._hud_label:
		_host._hud_label.text = "Watermelon x%d · Coins %d" % [_host._watermelon_count, _host._coin_score]


func _update_finish_camera(delta: float) -> void:
	if _host._cam == null or steps.is_empty():
		return
	var focus_i := clampi(focus_step, 0, steps.size() - 1)
	var land: Vector3 = steps[focus_i]["land"]
	var f := _finish_end_frame()
	var tangent: Vector3 = f["tangent"]
	var right: Vector3 = f["right"]
	# 剩余叠塔高度：爬得越高 / 塔越高，镜头越往后拉
	var tower_h := float(_host._stack.size()) * STACK_STEP_Y
	var climb_t := float(focus_i) / maxf(float(steps.size() - 1), 1.0)
	var back := 8.2 + tower_h * 0.85 + climb_t * 3.4
	var height := 3.8 + tower_h * 0.48 + climb_t * 2.1
	var desired := land - tangent * back - right * 1.8 + Vector3(0.0, height, 0.0)
	var look := land + tangent * 1.2 + Vector3(0.0, 0.9 + tower_h * 0.42, 0.0)
	var k := 1.0 - exp(-5.5 * delta) # 跟阶更快，减少镜头追赶造成的顿挫
	_host._cam.global_position = _host._cam.global_position.lerp(desired, k)
	_host._cam.look_at_from_position(_host._cam.global_position, look, Vector3.UP)
	var want_fov := lerpf(44.0, 36.0, climb_t)
	_host._cam.fov = lerpf(_host._cam.fov, want_fov, k)

