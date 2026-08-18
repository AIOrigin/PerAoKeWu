class_name CapybaraWorld
extends RefCounted

## 断崖、跳跳床、水果、加速道

const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")
const LevelCatalogScript := preload("res://assets/maps/route_levels/capybara_rush/level_catalog.gd")
const MeshUtil := preload("res://assets/maps/route_levels/capybara_rush/capybara_mesh_util.gd")
const CapybaraLevelCatalog = LevelCatalogScript

const LANE_COUNT := 3
const LANE_WIDTH := 1.08
const ROAD_SURFACE_Y := 0.09
const ROAD_HALF_W := 2.05
const GRAVITY := 24.0
const JUMP_SPEED := 8.2
const RUN_SPEED := 12.0
const JUMP_CLEAR_Y := 0.55
const JUMP_DROP_CHANCE := 0.02
const ENABLE_JUMP_DROP := false
const CLIFF_GAP_LEN := 11.0
const CLIFF_VOID_Y := -10.0
const CLIFF_TIP_TRIGGER_Y := -1.2
const CLIFF_BOTTOM_DROP := 4
const CLIFF_TIP_ANGLE := 1.05
const TRAMPOLINE_JUMP_SPEED := 17.5
const TRAMPOLINE_AIR_SPEED_MUL := 1.45
const TRAMPOLINE_APPROACH_MARGIN := 24.0
const FRUIT_SPIN_SPEED := 2.0
const SPEED_ORB_SPIN_SPEED := 2.4
const SPEED_ORB_MUL := 1.18
const SPEED_ORB_DURATION := 2.5
const SPEED_LANE_MUL := 1.48
const SPEED_LANE_FRUIT_SPACING := 2.5
const PLATFORM_TOP_Y := 1.15
const PLATFORM_HALF_LEN := 2.2
const JUMP_CHALLENGE_PAD_COUNT := 3
const JUMP_CHALLENGE_PAD_SPACING := 8.8
const JUMP_CHALLENGE_PAD_HALF_LEN := 1.6
const JUMP_CHALLENGE_PAD_HALF_LAT := 0.58
const JUMP_CHALLENGE_RUNOUT := 2.8
const JUMP_CHALLENGE_WATER_Y := -0.06
const JUMP_CHALLENGE_PAD_FLOAT_TOP := ROAD_SURFACE_Y - 0.01
const JUMP_CHALLENGE_PAD_THICK := 0.20
const MODE_STACK := "stack"

var _host: Node


func _init(host: Node) -> void:
	_host = host


func try_jump(boost_speed: float = -1.0) -> void:
	_try_jump(boost_speed)


func update_jump(delta: float) -> void:
	_update_jump(delta)


func cliff_forward_cap() -> float:
	return _cliff_forward_cap()


func update_speed_buff(delta: float) -> void:
	_update_speed_buff(delta)


func refresh_speed_lane_state() -> void:
	_refresh_speed_lane_state()


func try_trampoline_bounce() -> void:
	_try_trampoline_bounce()


func update_trampoline_cd(delta: float) -> void:
	_update_trampoline_cd(delta)


func update_fruit_bob(delta: float) -> void:
	_update_fruit_bob(delta)


func try_collect_fruits() -> void:
	_try_collect_fruits()


func update_speed_orb_spin(delta: float) -> void:
	_update_speed_orb_spin(delta)


func try_collect_speed_orbs() -> void:
	_try_collect_speed_orbs()


func spawn_cliffs() -> void:
	_spawn_cliffs()


func spawn_trampolines() -> void:
	_spawn_trampolines()


func spawn_fruits() -> void:
	_spawn_fruits()


func spawn_speed_lanes() -> void:
	_spawn_speed_lanes()


func spawn_speed_lane_fruits() -> void:
	_spawn_speed_lane_fruits()


func spawn_speed_orbs() -> void:
	_spawn_speed_orbs()


func spawn_platforms() -> void:
	_spawn_platforms()


func spawn_jump_challenges() -> void:
	_spawn_jump_challenges()


func planned_cliff_gaps() -> Array:
	return _planned_cliff_gaps()


func planned_road_gaps() -> Array:
	var gaps: Array = _planned_cliff_gaps()
	gaps.append_array(_planned_jump_challenge_gaps())
	return gaps


func near_cliff_zone(dist: float, margin: float = TRAMPOLINE_APPROACH_MARGIN) -> bool:
	return _near_cliff_zone(dist, margin)


func is_on_speed_lane_corridor(dist: float, lateral: float) -> bool:
	return _is_on_speed_lane_corridor(dist, lateral)


func fruit_coin_value(kind: String) -> int:
	return _fruit_coin_value(kind)


func is_frost_theme() -> bool:
	return _is_frost_theme()


func fruit_pool_for_level() -> Array[String]:
	return _fruit_pool_for_level()


func make_fruit_visual(kind: String) -> Node3D:
	return _make_fruit_visual(kind)


func is_airborne_clear(clear_y: float = JUMP_CLEAR_Y) -> bool:
	return _is_airborne_clear(clear_y)


func _try_jump(boost_speed: float = -1.0) -> void:
	if not _host._grounded or _host._finished:
		return
	_host._grounded = false
	_host._on_platform = false
	# 普通跳不能过断崖；只有跳跳床传入的 boost 才算
	if boost_speed > 0.0:
		_host._cliff_from_trampoline = true
		_host._vel_y = boost_speed
	else:
		_host._cliff_from_trampoline = false
		_host._vel_y = JUMP_SPEED
	# 跳跃有小概率掉顶层（叠高≥2）；弹床大跳同样适用
	if ENABLE_JUMP_DROP and _host._game_mode == MODE_STACK and _host._stack.size() >= 2 and randf() < JUMP_DROP_CHANCE:
		_host._stack_sys._drop_top_layer(true)
		_host._drop_cd = maxf(_host._drop_cd, 0.35)
		_host._sway = minf(_host._sway + 0.45, 2.2)
	# 只有最底层跳，上面叠着的保持静止
	if not _host._stack.is_empty() and _host._stack[0] != null and is_instance_valid(_host._stack[0]):
		_host._play_capy_clip(_host._stack[0], ["jump"], true)


func _update_jump(delta: float) -> void:
	if _host._cliff_rescuing:
		return
	var platform_y := _platform_top_under_player()
	var floor_y := platform_y if platform_y >= 0.0 else ROAD_SURFACE_Y
	# 断崖/水池缺口内无路面；落脚平台仍可站立
	if _in_cliff_gap() and platform_y < 0.0:
		floor_y = CLIFF_VOID_Y
	if _host._grounded:
		_host._ground_y = floor_y
		_host._air_y = floor_y
		_host._vel_y = 0.0
		# 安全落地后清弹床标记
		if not _in_cliff_gap():
			_host._cliff_from_trampoline = false
		if floor_y < -1.0:
			# 走到断崖边缘未跳 → 坠落
			_host._grounded = false
			_host._on_platform = false
			_host._vel_y = -2.0
			return
		if _host._on_platform and platform_y < 0.0:
			_host._grounded = false
			_host._on_platform = false
			_host._vel_y = -0.5
		return
	_host._vel_y -= GRAVITY * delta
	_host._air_y += _host._vel_y * delta
	# 叠塔：未用跳跳床坠入断崖 → 倾倒掉底四层，落到对岸继续
	if (
		_host._game_mode == MODE_STACK
		and not _host._cliff_from_trampoline
		and _host._air_y < CLIFF_TIP_TRIGGER_Y
		and (_in_cliff_gap() or floor_y < -1.0)
	):
		_begin_cliff_tip_rescue()
		return
	# 弹床仍摔进深渊 / 竞速深坠
	if _host._air_y < -4.0:
		if _host._game_mode == MODE_STACK:
			_begin_cliff_tip_rescue()
		else:
			_host._fail_game("掉下断崖，游戏失败")
		return
	if _host._vel_y <= 0.0 and _host._air_y <= floor_y + 0.02 and floor_y > -1.0:
		_host._air_y = floor_y
		_host._vel_y = 0.0
		_host._grounded = true
		_host._ground_y = floor_y
		_host._on_platform = platform_y >= 0.0
		if not _in_cliff_gap():
			_host._cliff_from_trampoline = false


func _cliff_forward_cap() -> float:
	## 无弹床时，前进不能越过当前断崖终点（普通跳飞不过去，只能坠落受罚）
	for c in _host._cliffs:
		if String(c.get("kind", "cliff")) == "jump":
			continue
		var d0 := float(c.get("dist0", -1.0))
		var d1 := float(c.get("dist1", -1.0))
		if bool(c.get("penalized", false)):
			continue
		if _host._progress > d0 - 0.05 and _host._progress < d1:
			return d1 - 0.08
	return -1.0


func _cliff_cross_dist() -> float:
	## 倾倒受罚后落到对岸，继续往前（不再退回崖前死循环）
	for c in _host._cliffs:
		var d0 := float(c.get("dist0", -1.0))
		var d1 := float(c.get("dist1", -1.0))
		if _host._progress >= d0 - 2.0 and _host._progress <= d1 + 5.0:
			c["penalized"] = true
			var land := d1 + (1.4 if String(c.get("kind", "cliff")) == "jump" else 2.2)
			return minf(land, _host._track_len() - 1.0)
	return minf(_host._progress + float(_host._level_cfg.get("cliff_gap_len", CLIFF_GAP_LEN)) + 2.0, _host._track_len() - 1.0)


func _begin_cliff_tip_rescue() -> void:
	if _host._cliff_rescuing or _host._finished:
		return
	if _host._stack.is_empty():
		_host._fail_game("掉下断崖，游戏失败")
		return
	_host._cliff_rescuing = true
	_host._cliff_from_trampoline = false
	_host._grounded = false
	_host._vel_y = 0.0
	_host._air_y = maxf(_host._air_y, -1.0)
	_host._play_sfx_hit()
	_host._sway = minf(_host._sway + 1.4, 2.6)
	var land_dist := _cliff_cross_dist()
	var tw := _host.create_tween()
	tw.tween_property(_host, "_cliff_tip_pitch", CLIFF_TIP_ANGLE, 0.38) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(_cliff_drop_bottom_and_land.bind(land_dist))
	tw.tween_property(_host, "_cliff_tip_pitch", 0.0, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_finish_cliff_tip_rescue)


func _cliff_drop_bottom_and_land(land_dist: float) -> void:
	## 最底下最多掉 4 只；至少留 1 只，落到对岸继续
	var drop_n := mini(CLIFF_BOTTOM_DROP, maxi(_host._stack.size() - 1, 0))
	for _i in drop_n:
		if _host._stack.is_empty():
			break
		_host._stack_sys.drop_layer_into_cliff(0)
	if _host._stack.is_empty():
		_host._cliff_rescuing = false
		_host._cliff_tip_pitch = 0.0
		_host._fail_game("掉下断崖，游戏失败")
		return
	_host._progress = land_dist
	_host._air_y = ROAD_SURFACE_Y + 0.4
	_host._vel_y = 0.0
	_host._repack_stack_heights()
	_host._stack_sys.refresh_stack_layer_anims()


func _finish_cliff_tip_rescue() -> void:
	_host._cliff_rescuing = false
	_host._cliff_tip_pitch = 0.0
	_host._cliff_from_trampoline = false
	_host._grounded = true
	_host._air_y = ROAD_SURFACE_Y
	_host._vel_y = 0.0
	_host._on_platform = false
	_host._stack_sys.refresh_stack_layer_anims()
	if _host._hud_tip != null and _host._playing and not _host._finished:
		_host._hud_tip.text = "没踩跳跳床摔过去了 · 底下掉了几只 · 下次换有床的道飞"


func _in_cliff_gap() -> bool:
	for c in _host._cliffs:
		var d0 := float(c.get("dist0", -1.0))
		var d1 := float(c.get("dist1", -1.0))
		if _host._progress > d0 and _host._progress < d1:
			return true
	return false


func _platform_top_under_player() -> float:
	## 脚下有台阶返回顶面高度，否则 -1
	for p in _host._platforms:
		var dist: float = float(p.get("dist", -999.0))
		var lateral: float = float(p.get("lateral", 0.0))
		var half_len := float(p.get("half_len", PLATFORM_HALF_LEN))
		var half_lat := float(p.get("half_lat", LANE_WIDTH * 0.62))
		if bool(p.get("jump_pad", false)):
			half_len += 0.28
			half_lat += 0.14
		if absf(dist - _host._progress) > half_len:
			continue
		if absf(lateral - _host._lane_x) > half_lat:
			continue
		return float(p.get("top_y", PLATFORM_TOP_Y))
	return -1.0


func _update_speed_buff(delta: float) -> void:
	if _host._speed_buff_left > 0.0:
		_host._speed_buff_left = maxf(_host._speed_buff_left - delta, 0.0)


func _speed_lane_mul() -> float:
	return float(_host._level_cfg.get("speed_lane_mul", SPEED_LANE_MUL))


func _refresh_speed_lane_state() -> void:
	_host._on_speed_lane = false
	if not _host._grounded:
		return
	for lane in _host._speed_lanes:
		var d0: float = float(lane.get("dist0", 0.0))
		var d1: float = float(lane.get("dist1", 0.0))
		var lateral: float = float(lane.get("lateral", 0.0))
		if _host._progress < d0 - 0.35 or _host._progress > d1 + 0.35:
			continue
		if absf(lateral - _host._lane_x) > LANE_WIDTH * 0.52:
			continue
		_host._on_speed_lane = true
		return


func _is_on_speed_lane_corridor(dist: float, lateral: float) -> bool:
	for lane in _host._speed_lanes:
		if dist < float(lane.get("dist0", 0.0)) - 0.6 or dist > float(lane.get("dist1", 0.0)) + 0.6:
			continue
		if absf(float(lane.get("lateral", 0.0)) - lateral) <= LANE_WIDTH * 0.52:
			return true
	return false


func _is_airborne_clear(clear_y: float = JUMP_CLEAR_Y) -> bool:
	## clear_y 按「障碍顶绝对高度」理解：脚底 _host._air_y 超过才算跳过
	return (not _host._grounded) and _host._air_y >= clear_y - 0.02


func _try_trampoline_bounce() -> void:
	if not _host._grounded or _host._finished or not _host._playing:
		return
	for t in _host._trampolines:
		if bool(t.get("used_cd", false)):
			# 冷却用 life 字段倒计时在 process 外处理
			continue
		if not _host._along_overlap(float(t.get("dist", -999.0)), float(t.get("lateral", 0.0)), 1.6, 1.15):
			continue
		t["used_cd"] = true
		t["cd"] = 0.85
		_try_jump(TRAMPOLINE_JUMP_SPEED)
		# 弹床压扁回弹
		var node: Node3D = t.get("node")
		if node != null and is_instance_valid(node):
			var pad: Node3D = node.find_child("Pad", true, false) as Node3D
			if pad != null:
				var tw := _host.create_tween()
				tw.tween_property(pad, "scale", Vector3(1.15, 0.45, 1.15), 0.08)
				tw.tween_property(pad, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK)
		break


func _update_trampoline_cd(delta: float) -> void:
	for t in _host._trampolines:
		if not bool(t.get("used_cd", false)):
			continue
		t["cd"] = float(t.get("cd", 0.0)) - delta
		if float(t["cd"]) <= 0.0:
			t["used_cd"] = false
			t["cd"] = 0.0


func _spawn_fruits() -> void:
	## 路上水果 = 金币；稀有度越高分越高（冰雪关用雪糕/水晶）
	_host._fruits.clear()
	_host._coin_score = 0
	_host._fruit_orange = 0
	_host._fruit_apple = 0
	_host._fruit_banana = 0
	_host._fruit_pineapple = 0
	_host._fruit_durian = 0
	_host._fruit_icecream = 0
	_host._fruit_crystal = 0
	var pool: Array[String] = _fruit_pool_for_level()
	var z := 20.0
	var i := 0
	var track_len: float = _host._track_len()
	while z < track_len - 28.0:
		var kind: String = pool[i % pool.size()]
		var lane := (i + 1) % LANE_COUNT
		var lateral: float = _host._lane_to_x(lane)
		if _is_on_speed_lane_corridor(z, lateral):
			z += 1.8
			i += 1
			continue
		var visual := _make_fruit_visual(kind)
		var holder := Node3D.new()
		_host._world.add_child(holder)
		_host._track_sys.path_place(holder, z, lateral, 0.55, 0.0)
		holder.add_child(visual)
		_host._fruits.append({
			"node": holder,
			"visual": visual,
			"dist": z,
			"lateral": lateral,
			"kind": kind,
			"coins": _fruit_coin_value(kind),
			"phase": randf() * TAU,
			"taken": false,
		})
		var fsp: Array = _host._level_cfg.get("fruit_spacing", [9.0, 13.0])
		var flo := float(fsp[0]) if fsp.size() > 0 else 9.0
		var fhi := float(fsp[1]) if fsp.size() > 1 else 13.0
		z += randf_range(flo, fhi)
		i += 1


func _fruit_pool_for_level() -> Array[String]:
	var raw: Variant = _host._level_cfg.get("fruit_pool", null)
	var out: Array[String] = []
	if typeof(raw) == TYPE_ARRAY and (raw as Array).size() > 0:
		for item in raw as Array:
			var k := String(item)
			if not k.is_empty():
				out.append(k)
		if not out.is_empty():
			return out
	if _is_frost_theme():
		return [
			"icecream", "icecream", "icecream",
			"crystal", "crystal",
			"icecream", "crystal",
		]
	return [
		"orange", "orange", "orange",
		"apple", "apple",
		"banana", "banana",
		"pineapple",
		"durian",
	]


func _is_frost_theme() -> bool:
	return String(_host._theme_cfg.get("id", "")) == "frost_snow" \
		or String(_host._level_cfg.get("theme_id", "")) == "frost_snow" \
		or String(_host._level_cfg.get("stair_kind", "")) == "ice"


func _fruit_coin_value(kind: String) -> int:
	match kind:
		"apple":
			return 8
		"banana":
			return 12
		"pineapple":
			return 18
		"durian":
			return 30
		"watermelon":
			return 20
		"icecream":
			return 10
		"crystal":
			return 22
		_:
			return 5


func _fruit_model_path(kind: String) -> String:
	match kind:
		"apple":
			return CapybaraRushPaths.FRUIT_APPLE
		"orange":
			return CapybaraRushPaths.FRUIT_ORANGE
		"banana":
			return CapybaraRushPaths.FRUIT_BANANA
		"pineapple":
			return CapybaraRushPaths.FRUIT_PINEAPPLE
		"durian":
			return CapybaraRushPaths.FRUIT_DURIAN
		"watermelon":
			return CapybaraRushPaths.WATERMELON_SLICE
		_:
			return ""


func _make_fruit_visual(kind: String) -> Node3D:
	if kind == "icecream":
		return _make_icecream_visual()
	if kind == "crystal":
		return _make_crystal_visual()
	var model_path := _fruit_model_path(kind)
	if not model_path.is_empty():
		var target_h := 0.62
		match kind:
			"pineapple":
				target_h = 0.78
			"durian":
				target_h = 0.7
			"banana":
				target_h = 0.58
			"watermelon":
				target_h = 0.72
		var fitted: Node3D = _host._instance_fitted(model_path, target_h, 0.0)
		if fitted != null:
			fitted.name = "Fruit_%s" % kind
			return fitted
		push_warning("Fruit model failed to load, using placeholder: %s" % model_path)
	# 模型未就绪时的程序占位
	var root := Node3D.new()
	root.name = "Fruit_%s" % kind
	match kind:
		"apple":
			var body := MeshInstance3D.new()
			var sph := SphereMesh.new()
			sph.radius = 0.28
			sph.height = 0.52
			body.mesh = sph
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0.88, 0.22, 0.24)
			mat.roughness = 0.4
			body.material_override = mat
			body.position.y = 0.28
			root.add_child(body)
			var stem := MeshInstance3D.new()
			var sc := CylinderMesh.new()
			sc.top_radius = 0.02
			sc.bottom_radius = 0.025
			sc.height = 0.1
			stem.mesh = sc
			var sm := StandardMaterial3D.new()
			sm.albedo_color = Color(0.35, 0.22, 0.12)
			stem.material_override = sm
			stem.position.y = 0.56
			root.add_child(stem)
			var leaf := MeshInstance3D.new()
			var lb := BoxMesh.new()
			lb.size = Vector3(0.16, 0.04, 0.1)
			leaf.mesh = lb
			var lm := StandardMaterial3D.new()
			lm.albedo_color = Color(0.35, 0.75, 0.28)
			leaf.material_override = lm
			leaf.position = Vector3(0.08, 0.58, 0.0)
			leaf.rotation.z = -0.55
			root.add_child(leaf)
		"orange":
			var body := MeshInstance3D.new()
			var sph := SphereMesh.new()
			sph.radius = 0.26
			sph.height = 0.5
			body.mesh = sph
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(1.0, 0.55, 0.12)
			mat.roughness = 0.55
			body.material_override = mat
			body.position.y = 0.26
			root.add_child(body)
			var leaf := MeshInstance3D.new()
			var lb := BoxMesh.new()
			lb.size = Vector3(0.12, 0.03, 0.08)
			leaf.mesh = lb
			var lm := StandardMaterial3D.new()
			lm.albedo_color = Color(0.32, 0.7, 0.25)
			leaf.material_override = lm
			leaf.position = Vector3(0.06, 0.5, 0.0)
			root.add_child(leaf)
		"banana":
			var body := MeshInstance3D.new()
			var cyl := CapsuleMesh.new()
			cyl.radius = 0.1
			cyl.height = 0.55
			body.mesh = cyl
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0.98, 0.86, 0.22)
			mat.roughness = 0.45
			body.material_override = mat
			body.position = Vector3(0.0, 0.28, 0.0)
			body.rotation.z = 0.55
			root.add_child(body)
		"pineapple":
			var body := MeshInstance3D.new()
			var sph := SphereMesh.new()
			sph.radius = 0.26
			sph.height = 0.62
			body.mesh = sph
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0.95, 0.72, 0.2)
			mat.roughness = 0.55
			body.material_override = mat
			body.position.y = 0.28
			root.add_child(body)
			var crown := MeshInstance3D.new()
			var cb := BoxMesh.new()
			cb.size = Vector3(0.2, 0.22, 0.08)
			crown.mesh = cb
			var cm := StandardMaterial3D.new()
			cm.albedo_color = Color(0.3, 0.75, 0.28)
			crown.material_override = cm
			crown.position.y = 0.62
			root.add_child(crown)
		"durian":
			var body := MeshInstance3D.new()
			var sph := SphereMesh.new()
			sph.radius = 0.3
			sph.height = 0.58
			body.mesh = sph
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0.78, 0.72, 0.28)
			mat.roughness = 0.65
			body.material_override = mat
			body.position.y = 0.3
			root.add_child(body)
		_:
			var body := MeshInstance3D.new()
			var sph := SphereMesh.new()
			sph.radius = 0.26
			sph.height = 0.52
			body.mesh = sph
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(1.0, 0.55, 0.12)
			mat.roughness = 0.5
			body.material_override = mat
			body.position.y = 0.26
			root.add_child(body)
	return root


func _make_icecream_visual() -> Node3D:
	## 程序化雪糕：脆筒 + 两球冰淇淋
	var root := Node3D.new()
	root.name = "Fruit_icecream"
	var cone := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.02
	cm.bottom_radius = 0.16
	cm.height = 0.42
	cone.mesh = cm
	var cmat := StandardMaterial3D.new()
	cmat.albedo_color = Color(0.92, 0.72, 0.42)
	cmat.roughness = 0.7
	cone.material_override = cmat
	cone.position.y = 0.21
	root.add_child(cone)
	var scoop_cols: Array[Color] = [
		Color(1.0, 0.72, 0.85),
		Color(0.75, 0.95, 1.0),
	]
	for i in 2:
		var scoop := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = 0.17 - float(i) * 0.02
		sph.height = sph.radius * 2.0
		scoop.mesh = sph
		var sm := StandardMaterial3D.new()
		sm.albedo_color = scoop_cols[i]
		sm.roughness = 0.35
		scoop.material_override = sm
		scoop.position.y = 0.42 + float(i) * 0.2
		root.add_child(scoop)
	return root


func _make_crystal_visual() -> Node3D:
	## 程序化水晶：拉长八面体感（双锥 + 高光）
	var root := Node3D.new()
	root.name = "Fruit_crystal"
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.9, 1.0, 0.88)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.12
	mat.metallic = 0.35
	mat.emission_enabled = true
	mat.emission = Color(0.35, 0.75, 1.0)
	mat.emission_energy_multiplier = 0.55
	var core := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.28, 0.55, 0.28)
	core.mesh = prism
	core.material_override = mat
	core.position.y = 0.28
	root.add_child(core)
	var tip := MeshInstance3D.new()
	var prism2 := PrismMesh.new()
	prism2.size = Vector3(0.22, 0.32, 0.22)
	tip.mesh = prism2
	tip.material_override = mat
	tip.position.y = 0.52
	tip.rotation.z = PI
	root.add_child(tip)
	return root


func _update_fruit_bob(delta: float) -> void:
	## 水果：轻浮 + 原地旋转（加分物标识）；胡萝卜障碍绝不走这里
	var t := Time.get_ticks_msec() * 0.001
	for f in _host._fruits:
		if bool(f.get("taken", false)):
			continue
		var node: Node3D = f.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var phase: float = float(f.get("phase", 0.0))
		var dist: float = float(f.get("dist", 0.0))
		var lateral: float = float(f.get("lateral", 0.0))
		var y := 0.45 + absf(sin(t * 3.2 + phase)) * 0.12
		# holder 只跟赛道切向，不整体乱转
		_host._track_sys.path_place(node, dist, lateral, y, 0.0)
		var vis: Node3D = f.get("visual") as Node3D
		if vis == null or not is_instance_valid(vis):
			if node.get_child_count() > 0:
				vis = node.get_child(0) as Node3D
		if vis != null and is_instance_valid(vis):
			vis.rotation.y += FRUIT_SPIN_SPEED * delta


func _update_speed_orb_spin(delta: float) -> void:
	for o in _host._speed_orbs:
		if bool(o.get("taken", false)):
			continue
		var node: Node3D = o.get("node")
		if node == null or not is_instance_valid(node) or node.get_child_count() <= 0:
			continue
		var vis := node.get_child(0) as Node3D
		if vis != null:
			vis.rotation.y += SPEED_ORB_SPIN_SPEED * delta


func _try_collect_fruits() -> void:
	for f in _host._fruits:
		if bool(f.get("taken", false)):
			continue
		var node: Node3D = f.get("node")
		if node == null or not is_instance_valid(node):
			continue
		if not _host._along_overlap(float(f.get("dist", -999.0)), float(f.get("lateral", 0.0)), 1.1, 1.05):
			continue
		f["taken"] = true
		var coins := int(f.get("coins", 5))
		_host._coin_score += coins
		_host._play_sfx_fruit()
		var kind := String(f.get("kind", "orange"))
		match kind:
			"apple":
				_host._fruit_apple += 1
			"banana":
				_host._fruit_banana += 1
			"pineapple":
				_host._fruit_pineapple += 1
			"durian":
				_host._fruit_durian += 1
			"icecream":
				_host._fruit_icecream += 1
			"crystal":
				_host._fruit_crystal += 1
			_:
				_host._fruit_orange += 1
		node.visible = false



func _spawn_cliffs() -> void:
	## 断崖数量由关卡 JSON `cliffs` 控制；跳跳床只出现在断崖前
	_host._cliffs.clear()
	for g in _planned_cliff_gaps():
		var d0 := float(g.get("dist0", 0.0))
		var d1 := float(g.get("dist1", 0.0))
		_host._cliffs.append({"dist0": d0, "dist1": d1})
		_spawn_cliff_visual(d0, d1)


func _near_cliff_zone(dist: float, margin: float = 14.0) -> bool:
	for c in _host._cliffs:
		var d0 := float(c.get("dist0", 0.0)) - margin
		var d1 := float(c.get("dist1", 0.0)) + margin * 0.45
		if dist >= d0 and dist <= d1:
			return true
	for g in _planned_jump_challenge_gaps():
		var d0 := float(g.get("dist0", 0.0)) - margin
		var d1 := float(g.get("dist1", 0.0)) + margin * 0.45
		if dist >= d0 and dist <= d1:
			return true
	return false


func _planned_cliff_gaps() -> Array:
	## 与路面挖空共用同一套区间，保证中间真正中空
	var gaps: Array = []
	var track_len: float = _host._track_len()
	var n := clampi(int(_host._level_cfg.get("cliffs", 0)), 0, 2)
	var gap := float(_host._level_cfg.get("cliff_gap_len", CLIFF_GAP_LEN))
	var ratios: Array[float] = []
	if n == 1:
		ratios = [0.48]
	elif n >= 2:
		ratios = [0.36, 0.72]
	for ratio in ratios:
		var z := track_len * ratio
		if z < 70.0 or z > track_len - 70.0:
			continue
		gaps.append({"dist0": z, "dist1": z + gap})
	return gaps


func _spawn_cliff_visual(d0: float, d1: float) -> void:
	## 卡通断崖：草皮顶 + 分层土石崖壁 + 深渊水面，中间真正镂空
	var gap_len := maxf(d1 - d0, 1.0)
	var mid := (d0 + d1) * 0.5
	var road_col := CapybaraLevelCatalog.color3(_host._theme_cfg.get("road_color"), Color(0.86, 0.82, 0.94))
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.45, 0.82, 0.40)
	grass.roughness = 0.92
	var dirt := StandardMaterial3D.new()
	dirt.albedo_color = Color(0.72, 0.52, 0.34)
	dirt.roughness = 0.95
	var rock := StandardMaterial3D.new()
	rock.albedo_color = Color(0.48, 0.44, 0.52)
	rock.roughness = 0.9
	var dark_rock := StandardMaterial3D.new()
	dark_rock.albedo_color = Color(0.32, 0.30, 0.38)
	dark_rock.roughness = 0.92
	var mist := StandardMaterial3D.new()
	mist.albedo_color = Color(0.75, 0.82, 0.95, 0.35)
	mist.roughness = 1.0
	mist.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist.cull_mode = BaseMaterial3D.CULL_DISABLED

	# —— 两端断口：伸出的草皮檐 + 向下的分层崖壁 ——
	for edge_i in 2:
		var edge_dist := d0 if edge_i == 0 else d1
		# 朝向深渊内侧：d0 的崖面向 +Z（前进），d1 面向 -Z
		var face_sign := 1.0 if edge_i == 0 else -1.0
		var lip := Node3D.new()
		_host._world.add_child(lip)
		_host._track_sys.path_place(lip, edge_dist, 0.0, 0.0, 0.0)

		# 路面色檐口
		var rim := MeshInstance3D.new()
		rim.mesh = MeshUtil.rounded_box(Vector3(ROAD_HALF_W * 2.15, 0.16, 0.7), 0.07)
		var rim_mat := StandardMaterial3D.new()
		rim_mat.albedo_color = road_col
		rim_mat.roughness = 0.85
		rim.material_override = rim_mat
		rim.position = Vector3(0.0, 0.02, face_sign * 0.12)
		rim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		lip.add_child(rim)

		# 草皮外檐（略探出断口）
		var sod := MeshInstance3D.new()
		sod.mesh = MeshUtil.rounded_box(Vector3(ROAD_HALF_W * 2.25, 0.22, 0.85), 0.08)
		sod.material_override = grass
		sod.position = Vector3(0.0, -0.05, face_sign * 0.35)
		sod.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		lip.add_child(sod)

		# 分层崖壁（土 → 岩 → 深岩），制造纵深
		var layers := [
			{"h": 1.4, "y": -0.85, "z": 0.15, "mat": dirt, "w": ROAD_HALF_W * 2.05},
			{"h": 2.2, "y": -2.4, "z": 0.28, "mat": rock, "w": ROAD_HALF_W * 2.15},
			{"h": 2.8, "y": -4.6, "z": 0.45, "mat": dark_rock, "w": ROAD_HALF_W * 2.35},
		]
		for L in layers:
			var face := MeshInstance3D.new()
			var fb := BoxMesh.new()
			fb.size = Vector3(float(L["w"]), float(L["h"]), 0.55)
			face.mesh = fb
			face.material_override = L["mat"]
			face.position = Vector3(0.0, float(L["y"]), face_sign * float(L["z"]))
			face.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			lip.add_child(face)

		# 两侧破碎土块，让断口不那么「一条直线」
		for side in [-1.0, 1.0]:
			var chunk := MeshInstance3D.new()
			var cb := BoxMesh.new()
			cb.size = Vector3(1.1, 1.6, 0.9)
			chunk.mesh = cb
			chunk.material_override = dirt
			chunk.position = Vector3(side * (ROAD_HALF_W * 0.72), -1.1, face_sign * 0.55)
			chunk.rotation_degrees = Vector3(randf_range(-8.0, 8.0), randf_range(-15.0, 15.0), side * randf_range(6.0, 14.0))
			chunk.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			lip.add_child(chunk)

	# —— 左右峡谷壁：高耸、带草顶 ——
	for side in [-1.0, 1.0]:
		var wall_root := Node3D.new()
		_host._world.add_child(wall_root)
		_host._track_sys.path_place(wall_root, mid, side * (ROAD_HALF_W + 1.1), 0.0, 0.0)
		# 主岩壁
		var main_w := MeshInstance3D.new()
		var mw := BoxMesh.new()
		mw.size = Vector3(2.4, 7.5, gap_len + 1.6)
		main_w.mesh = mw
		main_w.material_override = rock
		main_w.position = Vector3(side * 0.4, -2.8, 0.0)
		main_w.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		wall_root.add_child(main_w)
		# 下层深岩
		var deep_w := MeshInstance3D.new()
		var dw := BoxMesh.new()
		dw.size = Vector3(3.2, 4.0, gap_len + 2.2)
		deep_w.mesh = dw
		deep_w.material_override = dark_rock
		deep_w.position = Vector3(side * 0.9, -6.2, 0.0)
		deep_w.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		wall_root.add_child(deep_w)
		# 草顶
		var cap := MeshInstance3D.new()
		var cap_box := BoxMesh.new()
		cap_box.size = Vector3(2.8, 0.35, gap_len + 1.2)
		cap.mesh = cap_box
		cap.material_override = grass
		cap.position = Vector3(side * 0.35, 0.85, 0.0)
		cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		wall_root.add_child(cap)
		# 凸出台阶块，增加「悬崖」层次
		for k in 3:
			var ledge := MeshInstance3D.new()
			var lb := BoxMesh.new()
			var lh := 1.1 + float(k) * 0.35
			lb.size = Vector3(1.2 + float(k) * 0.25, lh, gap_len * (0.35 + float(k) * 0.12))
			ledge.mesh = lb
			ledge.material_override = dirt if k == 0 else rock
			ledge.position = Vector3(
				side * (0.2 - float(k) * 0.15),
				-1.2 - float(k) * 1.5,
				(float(k) - 1.0) * gap_len * 0.18
			)
			ledge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			wall_root.add_child(ledge)

	# —— 深渊水面 + 薄雾（强调坠落感） ——
	var void_n := Node3D.new()
	_host._world.add_child(void_n)
	_host._track_sys.path_place(void_n, mid, 0.0, 0.0, 0.0)
	var abyss := MeshInstance3D.new()
	var abyss_plane := PlaneMesh.new()
	abyss_plane.size = Vector2(ROAD_HALF_W * 2.6 + 2.0, gap_len + 1.0)
	abyss_plane.subdivide_width = 36
	abyss_plane.subdivide_depth = maxi(20, int(gap_len * 3.0))
	abyss.mesh = abyss_plane
	var abyss_col := CapybaraLevelCatalog.color3(
		_host._theme_cfg.get("water_color"), Color(0.25, 0.48, 0.78, 0.92)
	)
	abyss.material_override = _host._track_sys.make_water_ripple_material(abyss_col, 0.55, true)
	abyss.position.y = -7.2
	abyss.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	void_n.add_child(abyss)
	_host._water_meshes.append(abyss)
	var fog := MeshInstance3D.new()
	var fog_box := BoxMesh.new()
	fog_box.size = Vector3(ROAD_HALF_W * 2.4, 1.8, gap_len * 0.92)
	fog.mesh = fog_box
	fog.material_override = mist
	fog.position.y = -3.8
	fog.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	void_n.add_child(fog)


func _planned_jump_challenge_gaps() -> Array:
	var raw: Variant = _host._level_cfg.get("jump_challenges", [])
	if typeof(raw) != TYPE_ARRAY:
		return []
	var gaps: Array = []
	var track_len: float = _host._track_len()
	for item_v in raw as Array:
		var item: Dictionary = item_v if typeof(item_v) == TYPE_DICTIONARY else {}
		var start := float(item.get("dist", -1.0))
		if start < 24.0 or start > track_len - 36.0:
			continue
		var spec := _jump_challenge_spec(item)
		gaps.append({"dist0": start, "dist1": start + spec["gap_len"]})
	return gaps


func _jump_challenge_jump_reach() -> float:
	var speed := maxf(float(_host._level_cfg.get("run_speed", RUN_SPEED)), 5.0)
	return speed * (2.0 * JUMP_SPEED / GRAVITY)


func _jump_challenge_min_spacing(pad_half: float) -> float:
	## 板头起跳时，水平位移 ≈ reach，需 spacing >= reach 才能落上下一块板
	var reach := _jump_challenge_jump_reach()
	return maxf(reach + pad_half * 0.2, pad_half * 2.0 + 0.65)


func _jump_challenge_spec(item: Dictionary) -> Dictionary:
	var pad_count := clampi(int(item.get("pad_count", JUMP_CHALLENGE_PAD_COUNT)), 2, 5)
	var pad_half := float(item.get("pad_half_len", JUMP_CHALLENGE_PAD_HALF_LEN))
	var min_spacing := _jump_challenge_min_spacing(pad_half)
	var spacing := float(item.get("spacing", min_spacing))
	spacing = maxf(spacing, min_spacing)
	var runout := maxf(
		float(item.get("runout", JUMP_CHALLENGE_RUNOUT)),
		_jump_challenge_jump_reach() * 0.42
	)
	var span := pad_half * 2.0
	if pad_count > 1:
		span += spacing * float(pad_count - 1)
	var gap_len := span + runout
	return {
		"pad_count": pad_count,
		"spacing": spacing,
		"pad_half": pad_half,
		"pad_half_lat": float(item.get("pad_half_lat", JUMP_CHALLENGE_PAD_HALF_LAT)),
		"runout": runout,
		"gap_len": gap_len,
	}


func _spawn_jump_challenges() -> void:
	var raw: Variant = _host._level_cfg.get("jump_challenges", [])
	if typeof(raw) != TYPE_ARRAY or (raw as Array).is_empty():
		return
	_purge_jump_challenge_nodes()
	var kept: Array[Dictionary] = []
	for p in _host._platforms:
		if not bool(p.get("jump_pad", false)):
			kept.append(p)
	_host._platforms = kept
	for item_v in raw as Array:
		var item: Dictionary = item_v if typeof(item_v) == TYPE_DICTIONARY else {}
		var start := float(item.get("dist", -1.0))
		if start < 24.0:
			continue
		_spawn_jump_challenge_at(start, item)


func _purge_jump_challenge_nodes() -> void:
	if _host._world == null:
		return
	for c in _host._world.get_children():
		if c == null or not is_instance_valid(c):
			continue
		var n := String(c.name)
		if n.begins_with("JumpPad_") or n.begins_with("JumpLip") or n == "JumpPool" \
				or n.begins_with("JumpArch") or n.begins_with("JumpBeacon"):
			c.queue_free()


func _spawn_jump_challenge_at(start_dist: float, item: Dictionary) -> void:
	var spec := _jump_challenge_spec(item)
	var d0 := start_dist
	var d1 := start_dist + float(spec["gap_len"])
	var pad_count: int = spec["pad_count"]
	var spacing := float(spec["spacing"])
	var pad_half := float(spec["pad_half"])
	var pad_half_lat := float(spec["pad_half_lat"])
	var lane := clampi(int(item.get("lane", 1)), 0, LANE_COUNT - 1)
	var lateral: float = _host._lane_to_x(lane)

	_host._cliffs.append({"dist0": d0, "dist1": d1, "kind": "jump"})
	_host._hazard_sys.clear_near_cliff_approach(d0, lane)
	_host._hazard_sys.clear_near_cliff_approach(d1, lane)
	_spawn_jump_challenge_visual(d0, d1, lateral, spec)

	var top_y := JUMP_CHALLENGE_PAD_FLOAT_TOP
	var first_center := d0 + pad_half
	for i in pad_count:
		var pad_dist := first_center + float(i) * spacing
		_add_jump_pad(pad_dist, lateral, top_y, pad_half, pad_half_lat)


func _add_jump_pad(
	pad_dist: float,
	lateral: float,
	top_y: float,
	pad_half: float,
	pad_half_lat: float
) -> void:
	var visual := _make_jump_pad_visual(pad_half, pad_half_lat)
	var holder := Node3D.new()
	holder.name = "JumpPad_%d" % _host._platforms.size()
	_host._world.add_child(holder)
	var pad_center_y := top_y - JUMP_CHALLENGE_PAD_THICK * 0.5
	_host._path_place(holder, pad_dist, lateral, pad_center_y, 0.0)
	holder.add_child(visual)
	_host._platforms.append({
		"node": holder,
		"dist": pad_dist,
		"lateral": lateral,
		"top_y": top_y,
		"half_len": pad_half,
		"half_lat": pad_half_lat,
		"jump_pad": true,
	})


func _spawn_jump_challenge_visual(d0: float, d1: float, lateral: float, spec: Dictionary) -> void:
	var gap_len := maxf(d1 - d0, 1.0)
	var mid := (d0 + d1) * 0.5
	var pad_count: int = spec["pad_count"]
	var road_col := CapybaraLevelCatalog.color3(
		_host._theme_cfg.get("road_color"), Color(0.86, 0.82, 0.94)
	)
	var water_col := CapybaraLevelCatalog.color3(
		_host._theme_cfg.get("water_color"), Color(0.45, 0.70, 0.88)
	)
	var frost: bool = _host._is_frost_theme()

	for edge_i in 2:
		var edge_dist := d0 if edge_i == 0 else d1
		var face_sign := 1.0 if edge_i == 0 else -1.0
		var lip := Node3D.new()
		lip.name = "JumpLip"
		_host._world.add_child(lip)
		_host._path_place(lip, edge_dist, lateral, 0.0, 0.0)
		var rim := MeshInstance3D.new()
		var rim_box := BoxMesh.new()
		rim_box.size = Vector3(LANE_WIDTH * 1.55, 0.28, 1.15)
		rim.mesh = rim_box
		var rim_mat := StandardMaterial3D.new()
		rim_mat.albedo_color = road_col
		rim_mat.emission = Color(0.95, 0.55, 0.15) if edge_i == 0 else Color(0.35, 0.95, 0.45)
		rim_mat.emission_enabled = true
		rim_mat.emission_energy_multiplier = 0.55
		rim_mat.roughness = 0.82
		rim.material_override = rim_mat
		rim.position = Vector3(0.0, ROAD_SURFACE_Y + 0.08, face_sign * 0.18)
		rim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		lip.add_child(rim)

	var pool_root := Node3D.new()
	pool_root.name = "JumpPool"
	_host._world.add_child(pool_root)
	_host._path_place(pool_root, mid, lateral, 0.0, 0.0)

	var water := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(ROAD_HALF_W * 2.35, gap_len + 0.8)
	water.mesh = plane
	water.material_override = _make_jump_pool_material(water_col)
	water.position.y = JUMP_CHALLENGE_WATER_Y
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pool_root.add_child(water)
	_host._water_meshes.append(water)

	for side in [-1.0, 1.0]:
		var edge := MeshInstance3D.new()
		var eb := BoxMesh.new()
		eb.size = Vector3(0.22, 0.12, gap_len + 0.5)
		edge.mesh = eb
		var em := StandardMaterial3D.new()
		em.albedo_color = Color(0.55, 0.82, 1.0) if frost else Color(1.0, 0.82, 0.15)
		em.emission_enabled = true
		em.emission = em.albedo_color * 0.55
		em.emission_energy_multiplier = 0.65
		edge.material_override = em
		edge.position = Vector3(side * (LANE_WIDTH * 0.72), JUMP_CHALLENGE_WATER_Y + 0.02, 0.0)
		pool_root.add_child(edge)

	push_warning(
		"Capybara jump challenge: dist %.1f–%.1f, pads=%d (Lv.%d)"
		% [d0, d1, pad_count, int(_host._level_cfg.get("id", 0))]
	)


func _make_jump_pool_material(color: Color) -> StandardMaterial3D:
	## 三连跳水池：平坦水面，不用 ripple shader（避免顶点抬高盖住浮台）
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(color.r * 0.55, color.g * 0.72, color.b * 0.88, 0.82)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 0.18
	mat.metallic = 0.0
	mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	return mat


func _make_jump_pad_visual(half_len: float, half_lat: float) -> Node3D:
	## 浮在水面上的扁平板：顶面高于平坦水面，不透明、优先绘制
	var root := Node3D.new()
	var top := JUMP_CHALLENGE_PAD_THICK * 0.5
	var thick := JUMP_CHALLENGE_PAD_THICK
	var lat_w := half_lat * 2.0
	var len_d := half_len * 2.0
	var water_y := JUMP_CHALLENGE_WATER_Y
	var pad_top_world := JUMP_CHALLENGE_PAD_FLOAT_TOP
	var pad_bottom_world := pad_top_world - thick
	var submerge := clampf(water_y - pad_bottom_world, 0.0, thick * 0.55)

	var side_mat := StandardMaterial3D.new()
	if _host._is_frost_theme():
		side_mat.albedo_color = Color(0.35, 0.68, 0.92)
	else:
		side_mat.albedo_color = Color(0.48, 0.46, 0.58)
	side_mat.roughness = 0.48
	side_mat.render_priority = 2

	var top_mat := StandardMaterial3D.new()
	if _host._is_frost_theme():
		top_mat.albedo_color = Color(0.92, 0.98, 1.0)
		top_mat.emission = Color(0.55, 0.92, 1.0)
	else:
		top_mat.albedo_color = Color(0.94, 0.90, 1.0)
		top_mat.emission = Color(0.62, 0.52, 0.98)
	top_mat.roughness = 0.22
	top_mat.emission_enabled = true
	top_mat.emission_energy_multiplier = 0.85
	top_mat.render_priority = 3

	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(lat_w, thick, len_d)
	body.mesh = box
	body.material_override = side_mat
	body.position.y = 0.0
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(body)

	var deck := MeshInstance3D.new()
	var deck_box := BoxMesh.new()
	deck_box.size = Vector3(lat_w * 0.96, 0.06, len_d * 0.96)
	deck.mesh = deck_box
	deck.material_override = top_mat
	deck.position.y = top + 0.03
	deck.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(deck)

	if submerge > 0.04:
		var wet := MeshInstance3D.new()
		var wet_box := BoxMesh.new()
		wet_box.size = Vector3(lat_w * 1.02, submerge, len_d * 1.02)
		wet.mesh = wet_box
		var wet_mat := side_mat.duplicate() as StandardMaterial3D
		wet_mat.albedo_color = wet_mat.albedo_color.darkened(0.22)
		wet.material_override = wet_mat
		wet.position.y = -top + submerge * 0.5
		root.add_child(wet)

	for edge_z in [-1.0, 1.0]:
		var lip := MeshInstance3D.new()
		var lip_box := BoxMesh.new()
		lip_box.size = Vector3(lat_w * 1.04, 0.08, 0.12)
		lip.mesh = lip_box
		var lip_mat := top_mat.duplicate() as StandardMaterial3D
		lip_mat.emission_energy_multiplier = 1.15
		lip.material_override = lip_mat
		lip.position = Vector3(0.0, top + 0.05, edge_z * (len_d * 0.5 - 0.06))
		root.add_child(lip)

	return root


func _spawn_trampolines() -> void:
	## 每个断崖前：三道里只在一条跑道放跳跳床（首处固定中道，并清掉弹床/崖口障碍）
	_host._trampolines.clear()
	var seed_v := int(_host._level_cfg.get("hazard_seed", 1))
	var cliff_i := 0
	for c in _host._cliffs:
		if String(c.get("kind", "cliff")) == "jump":
			continue
		var dist := float(c.get("dist0", 0.0)) - 4.8
		if dist < 20.0:
			cliff_i += 1
			continue
		var lane := 1 if cliff_i == 0 else -1
		if lane < 0:
			var rng := RandomNumberGenerator.new()
			rng.seed = hash([_host._level_id, seed_v, cliff_i, int(dist * 10.0)]) as int
			lane = rng.randi() % LANE_COUNT
		_host._hazard_sys.clear_near_cliff_approach(dist, lane)
		_spawn_trampoline_at(dist, lane)
		c["trampoline_lane"] = lane
		cliff_i += 1


func _spawn_trampoline_at(dist: float, lane: int) -> void:
	var lateral: float = _host._lane_to_x(lane)
	var visual := _make_trampoline_visual()
	var holder := Node3D.new()
	_host._world.add_child(holder)
	_host._track_sys.path_place(holder, dist, lateral, 0.0, 0.0)
	holder.add_child(visual)
	_host._trampolines.append({
		"node": holder,
		"dist": dist,
		"lateral": lateral,
		"used_cd": false,
		"cd": 0.0,
	})


func _make_trampoline_visual() -> Node3D:
	var root := Node3D.new()
	root.name = "Trampoline"
	# 粉红外圈
	var rim := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.42
	torus.outer_radius = 0.58
	rim.mesh = torus
	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = CapybaraLevelCatalog.color3(_host._theme_cfg.get("trampoline_rim"), Color(1.0, 0.35, 0.55))
	rim_mat.roughness = 0.45
	rim.material_override = rim_mat
	rim.position.y = 0.12
	root.add_child(rim)
	# 灰黑弹面
	var pad := MeshInstance3D.new()
	pad.name = "Pad"
	var disk := CylinderMesh.new()
	disk.top_radius = 0.44
	disk.bottom_radius = 0.44
	disk.height = 0.06
	pad.mesh = disk
	var pad_mat := StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.28, 0.30, 0.34)
	pad_mat.roughness = 0.7
	pad.material_override = pad_mat
	pad.position.y = 0.14
	root.add_child(pad)
	# 四短腿
	var leg_mat := StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.75, 0.75, 0.78)
	for i in 4:
		var leg := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.035
		cyl.bottom_radius = 0.04
		cyl.height = 0.14
		leg.mesh = cyl
		leg.material_override = leg_mat
		var ang := float(i) * TAU * 0.25 + 0.4
		leg.position = Vector3(cos(ang) * 0.38, 0.07, sin(ang) * 0.38)
		root.add_child(leg)
	# 淡白光柱提示
	var glow := MeshInstance3D.new()
	var gc := CylinderMesh.new()
	gc.top_radius = 0.2
	gc.bottom_radius = 0.35
	gc.height = 1.6
	glow.mesh = gc
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(1.0, 1.0, 1.0, 0.12)
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = gm
	glow.position.y = 0.95
	root.add_child(glow)
	return root



func _spawn_platforms() -> void:
	var z := 70.0
	var i := 0
	var track_len: float = _host._track_len()
	while z < track_len - 50.0:
		var lane := (i + 2) % LANE_COUNT
		var lateral: float = _host._lane_to_x(lane)
		var visual: Node3D = _host._instance_fitted(CapybaraRushPaths.STEP_PLATFORM, PLATFORM_TOP_Y + 0.35, 0.0)
		if visual == null:
			visual = _make_stub_platform()
		var holder := Node3D.new()
		_host._world.add_child(holder)
		_host._track_sys.path_place(holder, z, lateral, 0.0, 0.0)
		holder.add_child(visual)
		_host._platforms.append({
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
	var track_len: float = _host._track_len()
	while z < track_len - 25.0:
		var lane := i % LANE_COUNT
		var lateral: float = _host._lane_to_x(lane)
		var visual: Node3D = _host._instance_fitted(CapybaraRushPaths.SPEED_ORB, 0.85, 0.0)
		if visual == null:
			visual = _make_stub_speed_orb()
		var holder := Node3D.new()
		_host._world.add_child(holder)
		_host._track_sys.path_place(holder, z, lateral, 0.55, 0.0)
		holder.add_child(visual)
		_host._speed_orbs.append({
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
	## 高对比橙色加速道 + 前进方向箭头（局部 +Z）
	var z := 90.0
	var i := 0
	var track_len: float = _host._track_len()
	var pad_mat := StandardMaterial3D.new()
	pad_mat.albedo_color = Color(1.0, 0.42, 0.12)
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(1.0, 0.38, 0.08)
	pad_mat.emission_energy_multiplier = 1.6
	pad_mat.roughness = 0.55
	var arrow_mat := StandardMaterial3D.new()
	arrow_mat.albedo_color = Color(1.0, 0.95, 0.25)
	arrow_mat.emission_enabled = true
	arrow_mat.emission = Color(1.0, 0.9, 0.15)
	arrow_mat.emission_energy_multiplier = 2.4
	arrow_mat.roughness = 0.4
	while z < track_len - 60.0:
		var lane := (i * 2) % LANE_COUNT
		var lateral: float = _host._lane_to_x(lane)
		var seg_len := randf_range(16.0, 24.0)
		var holder := Node3D.new()
		_host._world.add_child(holder)
		_host._track_sys.path_place(holder, z + seg_len * 0.5, lateral, 0.04, 0.0)

		var pad := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(LANE_WIDTH * 0.95, 0.06, seg_len)
		pad.mesh = box
		pad.material_override = pad_mat
		holder.add_child(pad)

		# 边框高亮，让赛道更抢眼
		for side in [-1.0, 1.0]:
			var edge := MeshInstance3D.new()
			var eb := BoxMesh.new()
			eb.size = Vector3(0.12, 0.08, seg_len)
			edge.mesh = eb
			edge.position = Vector3(side * LANE_WIDTH * 0.42, 0.03, 0.0)
			edge.material_override = arrow_mat
			holder.add_child(edge)

		var spacing := 2.1
		var start_z := -seg_len * 0.42
		var count := int(seg_len / spacing)
		for k in count:
			var arrow := _make_speed_chevron(arrow_mat)
			arrow.position = Vector3(0.0, 0.08, start_z + float(k) * spacing)
			holder.add_child(arrow)

		_host._speed_lanes.append({
			"node": holder,
			"dist0": z,
			"dist1": z + seg_len,
			"lateral": lateral,
			"seg_i": i,
		})
		z += randf_range(48.0, 72.0)
		i += 1


func _spawn_speed_lane_fruits() -> void:
	var pool := _fruit_pool_for_level()
	if pool.is_empty():
		return
	var fruit_spacing := float(_host._level_cfg.get("speed_lane_fruit_spacing", SPEED_LANE_FRUIT_SPACING))
	for lane in _host._speed_lanes:
		_spawn_fruits_on_speed_segment(
			float(lane.get("dist0", 0.0)),
			float(lane.get("dist1", 0.0)),
			float(lane.get("lateral", 0.0)),
			int(lane.get("seg_i", 0)),
			pool,
			fruit_spacing
		)


func _spawn_fruits_on_speed_segment(
	dist0: float,
	dist1: float,
	lateral: float,
	seg_i: int,
	pool: Array[String],
	spacing: float
) -> void:
	if pool.is_empty():
		return
	spacing = maxf(spacing, 1.8)
	var fz := dist0 + spacing * 0.45
	var fi := 0
	while fz < dist1 - spacing * 0.35:
		var kind: String = pool[(seg_i + fi) % pool.size()]
		var visual := _make_fruit_visual(kind)
		var holder := Node3D.new()
		_host._world.add_child(holder)
		_host._track_sys.path_place(holder, fz, lateral, 0.55, 0.0)
		holder.add_child(visual)
		_host._fruits.append({
			"node": holder,
			"visual": visual,
			"dist": fz,
			"lateral": lateral,
			"kind": kind,
			"coins": _fruit_coin_value(kind),
			"phase": randf() * TAU,
			"taken": false,
		})
		fz += spacing
		fi += 1


func _make_speed_chevron(mat: Material) -> Node3D:
	## 扁平 V 形箭头，尖端朝局部 +Z（沿赛道前进）
	var root := Node3D.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := Vector3.UP
	# 外轮廓箭头（宽 → 尖）
	var tip := Vector3(0.0, 0.0, 0.78)
	var left := Vector3(-0.72, 0.0, -0.35)
	var right := Vector3(0.72, 0.0, -0.35)
	var mid_l := Vector3(-0.28, 0.0, -0.05)
	var mid_r := Vector3(0.28, 0.0, -0.05)
	var back := Vector3(0.0, 0.0, -0.55)
	st.set_normal(n)
	st.add_vertex(tip); st.add_vertex(left); st.add_vertex(mid_l)
	st.add_vertex(tip); st.add_vertex(mid_l); st.add_vertex(mid_r)
	st.add_vertex(tip); st.add_vertex(mid_r); st.add_vertex(right)
	st.add_vertex(mid_l); st.add_vertex(back); st.add_vertex(mid_r)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	root.add_child(mi)
	# 轻微抬起厚度感
	var under := mi.duplicate() as MeshInstance3D
	under.position.y = -0.02
	under.scale = Vector3(0.92, 1.0, 0.92)
	root.add_child(under)
	return root


func _try_collect_speed_orbs() -> void:
	var t := Time.get_ticks_msec() * 0.001
	for o in _host._speed_orbs:
		var node: Node3D = o.get("node")
		if node == null or not is_instance_valid(node):
			continue
		if bool(o.get("taken", false)):
			continue
		var phase: float = float(o.get("phase", 0.0))
		var dist: float = float(o.get("dist", 0.0))
		var lateral: float = float(o.get("lateral", 0.0))
		var bob_y := 0.55 + sin(t * 4.0 + phase) * 0.12
		_host._track_sys.path_place(node, dist, lateral, bob_y, t * 1.8 + phase)
		if not _host._along_overlap(dist, lateral, 1.15, 1.05):
			continue
		o["taken"] = true
		node.visible = false
		_host._speed_buff_left = maxf(_host._speed_buff_left, SPEED_ORB_DURATION)
