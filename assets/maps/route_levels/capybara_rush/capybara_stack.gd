class_name CapybaraStack
extends RefCounted

## 叠塔、拾取动画、角色 rig / 动画

const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")

const LANE_COUNT := 3
const ROAD_SURFACE_Y := 0.09
const STACK_STEP_Y := 0.88
const TARGET_CAPY_HEIGHT := 0.92
const PICKUP_RADIUS_X := 1.15
const PICKUP_RADIUS_Z := 1.4
const PICKUP_LOOK_RANGE := 22.0
const PICKUP_LOOK_MAX := 2.45
const PICKUP_LOOK_HALF_FACE := 2.2
const PICKUP_LOOK_LERP := 10.0
const BOB_AMP := 0.06
const BOB_FREQ := 9.0
const VIOLENT_WINDOW_SEC := 1.0
const VIOLENT_MIN_CHANGES := 2
const MOVE_DROP_WINDOW_SEC := 0.85
const MIN_STACK_TO_DROP := 3
const HIGH_STACK_THRESHOLD := 8
const DROP_COOLDOWN_BASE := 0.55
const DROP_COOLDOWN_MIN := 0.18
const DROP_COOLDOWN_SHRINK_PER_LAYER := 0.04
const MAX_LEAN := 0.55
const SWAY_BUILD := 1.4
const SWAY_DECAY := 2.2
const ENABLE_MOVE_DROP := false
const ENABLE_JUMP_DROP := false
const JUMP_DROP_CHANCE := 0.02
const BLOCK_SIZE := 0.95
const BLOCK_GAP := 0.06
const PICKUP_JUMP_EXTRA := 0.28
const PICKUP_ANIM_JUMP_SEC := 0.26
const PICKUP_ANIM_SLIDE_SEC := 0.32
const PICKUP_ANIM_SETTLE_SEC := 0.22
const READY_SPIN_SPEED := 2.2
const INTRO_SPIN_SEC := 2.4
const START_PLAYER_PROGRESS := 6.5
const CAPY_FOOT_LIFT := 0.07
const CHAR_FOOT_LIFT := 0.08
const CLIFF_BOTTOM_DROP := 4
const CLIFF_TIP_ANGLE := 1.05
const CHAR_CAPYBARA := "capybara"
const CHAR_QINGQING := "qingqing"
const CHAR_LITTLE_MONSTER := "little_monster"
const CHAR_LITTLE_RABBIT := "little_rabbit"
const CHAR_SHIBA := "shiba"
const CHAR_BIRD := "bird"
const CHAR_MOUSE := "mouse"
const CHAR_SLOTH := "sloth"
const CHAR_TINY_PLANET := "tiny_planet"
const CHAR_BEAR := "bear"
const CHAR_COW := "cow"
const CHAR_UPRIGHT_IDS: Array[String] = [
	CHAR_QINGQING, CHAR_LITTLE_MONSTER, CHAR_LITTLE_RABBIT, CHAR_SHIBA, CHAR_BIRD,
	CHAR_MOUSE, CHAR_SLOTH, CHAR_TINY_PLANET, CHAR_BEAR, CHAR_COW,
]
const CHAR_SOFT_SKIN_IDS: Array[String] = [
	CHAR_BIRD, CHAR_MOUSE, CHAR_SLOTH, CHAR_TINY_PLANET, CHAR_BEAR,
]
const CAPY_FORWARD_YAW := -PI * 0.5
## 新 Tripo 卡皮：体轴沿 +Z，鼻朝 -Z，需转 180° 才与赛道前进一致
## Tripo 卡皮：绑骨已把嘴脸烤到赛道 +Z，无需再额外 yaw
const TRIPO_CAPY_FORWARD_YAW := 0.0
const QINGQING_FORWARD_YAW := -PI * 0.5
const MONSTER_FORWARD_YAW := -PI * 0.5
const RABBIT_FORWARD_YAW := 0.0
const SHIBA_FORWARD_YAW := 0.0
const BIRD_FORWARD_YAW := PI * 0.5
const MOUSE_FORWARD_YAW := 0.0
const SLOTH_FORWARD_YAW := 0.0
const TINY_PLANET_FORWARD_YAW := 0.0
const BEAR_FORWARD_YAW := 0.0
## Tripo 牛（直立双足）：rest 脸朝 +X，需 -90° 才与赛道 +Z 一致
# 嘴脸已在 cow_rigged 里烤成 +Z；左右胯在 ±X，run 用局部 X 前后迈步
const COW_FORWARD_YAW := 0.0
const PILOT_FORWARD_YAW := 0.0

var _host: Node


func _init(host: Node) -> void:
	_host = host



func update_falling(delta: float) -> void:
	_update_falling(delta)

func update_sway(delta: float) -> void:
	_update_sway(delta)

func update_tower_motion() -> void:
	_update_tower_motion()

func update_pickup_bob(delta: float) -> void:
	_update_pickup_bob(delta)

func try_collect_pickups() -> void:
	_try_collect_pickups()

func try_drop_layers(delta: float) -> void:
	_try_drop_layers(delta)

func try_hit_hazards() -> void:
	_try_hit_hazards()

func spawn_tower() -> void:
	_spawn_tower()

func spawn_pickups() -> void:
	_spawn_pickups()

func start_ready_spin() -> void:
	_start_ready_spin()

func update_ready_spin(delta: float) -> void:
	_update_ready_spin(delta)

func play_capy_clip(visual: Node, clip_keys: Array, loop: bool = true) -> void:
	_play_capy_clip(visual, clip_keys, loop)

func character_yaw() -> float:
	return _character_yaw()

func character_model_path() -> String:
	return _character_model_path()

func repack_stack_heights() -> void:
	_repack_stack_heights()

func snap_actor_feet_to_world_y(actor: Node3D, target_y: float) -> void:
	_snap_actor_feet_to_world_y(actor, target_y)

func instance_fitted(path: String, target_height: float, yaw: float = 0.0, start_anim: String = "run") -> Node3D:
	return _instance_fitted(path, target_height, yaw, start_anim)

func is_violent_move() -> bool:
	return _is_violent_move()

func is_moving_for_drop() -> bool:
	return _is_moving_for_drop()

func is_soft_skin_character(char_id: String = "") -> bool:
	return _is_soft_skin_character(char_id)

func character_display_name() -> String:
	return _character_display_name()

func finish_pickup_under_anim(incoming: Node3D, old_layers: Array[Node3D]) -> void:
	_finish_pickup_under_anim(incoming, old_layers)


func refresh_stack_layer_anims() -> void:
	_refresh_stack_layer_anims()


func park_stack_rider(visual: Node) -> void:
	_park_stack_rider(visual)


func drop_layer_into_cliff(idx: int) -> void:
	_drop_layer_into_cliff(idx)


func pick_rigged_or_base(rigged: String, base: String) -> String:
	return _pick_rigged_or_base(rigged, base)


func find_skeleton(node: Node) -> Skeleton3D:
	return _find_skeleton(node)


func local_aabb(root: Node3D) -> AABB:
	return _local_aabb(root)


func make_capy_visual() -> Node3D:
	return _make_capy_visual()


func move_drop_chance_per_sec() -> float:
	return _move_drop_chance_per_sec()


func mute_animation_players(node: Node) -> void:
	_mute_animation_players(node)


func _refresh_stack_layer_anims() -> void:
	for i in _host._stack.size():
		var layer: Node3D = _host._stack[i]
		if layer == null or not is_instance_valid(layer):
			continue
		if i == 0:
			_play_capy_clip(layer, ["run"], true)
		else:
			_park_stack_rider(layer)


func _drop_layer_into_cliff(idx: int) -> void:
	## 断崖倾倒：底层甩进深渊
	if _host._stack.is_empty():
		return
	idx = clampi(idx, 0, _host._stack.size() - 1)
	var layer: Node3D = _host._stack[idx]
	_host._stack.remove_at(idx)
	if layer == null or not is_instance_valid(layer):
		_repack_stack_heights()
		return
	_host._drop_count += 1
	var gpos := layer.global_position
	var grot := layer.global_rotation
	_host._tower.remove_child(layer)
	_host._world.add_child(layer)
	layer.global_position = gpos
	layer.global_rotation = grot
	_play_capy_clip(layer, ["jump", "run"], false)
	var side := -1.0 if randf() < 0.5 else 1.0
	var vel := Vector3(
		side * randf_range(1.2, 3.5),
		randf_range(-1.5, 2.2),
		randf_range(-0.8, 2.5)
	)
	var spin := Vector3(
		randf_range(1.5, 4.5),
		randf_range(-2.5, 2.5),
		side * randf_range(2.0, 5.0)
	)
	_host._falling.append({
		"node": layer,
		"vel": vel,
		"spin": spin,
		"life": 0.0,
		"can_hop": false,
		"hops_left": 0,
		"into_void": true,
	})
	_repack_stack_heights()


func _layers_above_min() -> int:
	return maxi(_host._stack.size() - MIN_STACK_TO_DROP, 0)


func _drop_cooldown() -> float:
	return maxf(
		DROP_COOLDOWN_BASE - float(_layers_above_min()) * DROP_COOLDOWN_SHRINK_PER_LAYER,
		DROP_COOLDOWN_MIN
	)


func _prune_lane_changes(window_sec: float) -> void:
	var now := Time.get_ticks_msec() * 0.001
	while not _host._lane_change_times.is_empty() and now - _host._lane_change_times[0] > window_sec:
		_host._lane_change_times.remove_at(0)


func _is_violent_move() -> bool:
	_prune_lane_changes(VIOLENT_WINDOW_SEC)
	return _host._lane_change_times.size() >= VIOLENT_MIN_CHANGES


func _is_moving_for_drop() -> bool:
	# 横向还在滑，或最近有过换道按键
	if absf(_host._lane_x - _host._prev_lane_x) > 0.025:
		return true
	_prune_lane_changes(MOVE_DROP_WINDOW_SEC)
	return not _host._lane_change_times.is_empty()


func _update_sway(delta: float) -> void:
	var lat_speed := absf(_host._lane_x - _host._prev_lane_x) / maxf(delta, 0.0001)
	var height_mul := 1.0 + float(maxi(_host._stack.size() - 1, 0)) * 0.12
	_host._sway += lat_speed * SWAY_BUILD * height_mul * delta
	_host._sway = maxf(_host._sway - SWAY_DECAY * delta, 0.0)
	if _host._drop_cd > 0.0:
		_host._drop_cd = maxf(_host._drop_cd - delta, 0.0)


func _move_drop_chance_per_sec() -> float:
	var n: int = _host._stack.size()
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
	if not ENABLE_MOVE_DROP:
		return
	if _host._stack_animating:
		return
	if _host._stack.size() < MIN_STACK_TO_DROP or _host._drop_cd > 0.0:
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
	_host._drop_cd = _drop_cooldown()
	_host._sway *= 0.3


func _force_drop_from_hazard(h: Dictionary = {}) -> void:
	# 撞障碍：重叠几层掉几只；会清空整塔或只剩 0 → 失败
	# 注意：拾取动画中不要直接 return 吞掉伤害——由 _try_hit_hazards 排队，结束后再结算
	if _host._stack.size() <= 1:
		_host._fail_game("撞到障碍，游戏失败")
		return
	var idxs := _hit_stack_layer_indices(h)
	if idxs.is_empty():
		idxs = [0]
	if idxs.size() >= _host._stack.size():
		_host._fail_game("撞到障碍，游戏失败")
		return
	# 从高下标到低剔除，避免 remove 后下标错位
	idxs.sort()
	idxs.reverse()
	for idx in idxs:
		_drop_layer_at(int(idx), true)
	_host._drop_cd = _drop_cooldown()
	_host._sway = minf(_host._sway + 1.2 + float(idxs.size()) * 0.15, 3.0)


func _hit_stack_layer_indices(h: Dictionary) -> Array[int]:
	## 障碍有几层、叠塔有几层脚底仍卡在障碍高度内，就掉几只
	var result: Array[int] = []
	if _host._stack.is_empty():
		return result
	var hit_top := CapybaraHazards.hit_top(h)
	var max_drop := int(h.get("rows", 0))
	if max_drop <= 0:
		max_drop = maxi(1, int(round(hit_top / (BLOCK_SIZE + BLOCK_GAP))))
	for i in _host._stack.size():
		if result.size() >= max_drop:
			break
		var y0: float = _host._air_y + float(i) * STACK_STEP_Y
		# 该层脚底已高于障碍顶 → 之上都安全
		if y0 >= hit_top - 0.05:
			break
		result.append(i)
	return result


func _drop_top_layer(allow_hop: bool = false) -> void:
	if _host._stack.is_empty():
		return
	_drop_layer_at(_host._stack.size() - 1, allow_hop)


func _drop_layer_at(idx: int, allow_hop: bool = false) -> void:
	if _host._stack.is_empty():
		return
	idx = clampi(idx, 0, _host._stack.size() - 1)
	var layer: Node3D = _host._stack[idx]
	_host._stack.remove_at(idx)
	if layer == null or not is_instance_valid(layer):
		_repack_stack_heights()
		return
	_host._drop_count += 1
	var gpos := layer.global_position
	var grot := layer.global_rotation
	_host._tower.remove_child(layer)
	_host._world.add_child(layer)
	layer.global_position = gpos
	layer.global_rotation = grot
	_play_capy_clip(layer, ["jump", "run"], false)
	# 向外侧甩出；被撞掉的可再跳几下
	var side := signf(_host._tower.rotation.z)
	if is_zero_approx(side):
		side = -1.0 if randf() < 0.5 else 1.0
	var vel := Vector3(
		side * randf_range(3.2, 5.8),
		randf_range(5.5, 7.5) if allow_hop else randf_range(4.0, 6.5),
		randf_range(-0.5, 2.2)
	)
	var spin := Vector3(
		randf_range(-2.0, 2.0),
		randf_range(-1.5, 1.5),
		side * randf_range(1.5, 4.0)
	)
	_host._falling.append({
		"node": layer,
		"vel": vel,
		"spin": spin,
		"life": 0.0,
		"can_hop": allow_hop,
		"hops_left": 2 if allow_hop else 0,
	})
	_repack_stack_heights()


func _repack_stack_heights() -> void:
	for i in _host._stack.size():
		var layer: Node3D = _host._stack[i]
		if layer == null or not is_instance_valid(layer):
			continue
		layer.position.x = 0.0
		layer.position.z = 0.0
		layer.position.y = float(i) * STACK_STEP_Y


func _update_falling(delta: float) -> void:
	var remain: Array[Dictionary] = []
	for f in _host._falling:
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
		var into_void := bool(f.get("into_void", false))
		# 坠入断崖：不在跑道上弹，继续往下掉
		if into_void:
			if float(f["life"]) > 2.8 or node.global_position.y < -14.0:
				node.queue_free()
				continue
			remain.append(f)
			continue
		# 落地：可再跳的会弹跳离开，否则减速消失
		if node.global_position.y < 0.08 and vel.y < 0.0:
			node.global_position.y = 0.08
			var hops := int(f.get("hops_left", 0))
			if bool(f.get("can_hop", false)) and hops > 0:
				f["hops_left"] = hops - 1
				vel.y = randf_range(5.0, 7.2)
				vel.x *= 1.05
				vel.z += randf_range(0.4, 1.2)
				f["vel"] = vel
				spin *= 0.45
				f["spin"] = spin
				_play_capy_clip(node, ["jump"], false)
			else:
				vel.y *= -0.28
				vel.x *= 0.65
				vel.z *= 0.65
				f["vel"] = vel
				spin *= 0.55
				f["spin"] = spin
		var max_life := 2.4 if bool(f.get("can_hop", false)) else 1.35
		if float(f["life"]) > max_life or (node.global_position.y <= 0.1 and absf(vel.y) < 0.8 and float(f["life"]) > 0.85):
			node.scale = node.scale.lerp(Vector3.ZERO, 1.0 - exp(-10.0 * delta))
			if node.scale.x < 0.08 or float(f["life"]) > max_life + 0.8:
				node.queue_free()
				continue
		remain.append(f)
	_host._falling = remain


func _update_pickup_bob(delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	for p in _host._pickups:
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var phase: float = float(p.get("phase", 0.0))
		var dist: float = float(p.get("dist", 0.0))
		var lateral: float = float(p.get("lateral", 0.0))
		var bob_y := ROAD_SURFACE_Y + absf(sin(t * 3.0 + phase)) * 0.06
		_host._track_sys.path_place(node, dist, lateral, bob_y, 0.0)

		var target_yaw := 0.0
		if _host._tower != null and absf(dist - _host._progress) <= PICKUP_LOOK_RANGE:
			var to_player: Vector3 = _host._tower.global_position - node.global_position
			to_player.y = 0.0
			if to_player.length_squared() > 0.04:
				var face_yaw := atan2(to_player.x, to_player.z)
				var base_yaw := float(node.rotation.y) + _character_yaw()
				target_yaw = wrapf(face_yaw - base_yaw, -PI, PI)
				var near_k := 1.0 - clampf(absf(dist - _host._progress) / PICKUP_LOOK_RANGE, 0.0, 1.0)
				# 在玩家前方（回看相机）时加重，保证半张脸
				var ahead: bool = dist > _host._progress
				var strength := near_k * near_k
				if ahead:
					strength = maxf(strength, near_k * 0.85)
				var desired := clampf(target_yaw, -PICKUP_LOOK_MAX, PICKUP_LOOK_MAX) * lerpf(0.55, 1.0, strength)
				# 近时强制至少转到半脸角度
				var min_turn := PICKUP_LOOK_HALF_FACE * strength
				if ahead and min_turn > 0.2:
					var side := signf(desired)
					if is_zero_approx(side):
						# 正后方时略偏一侧，避免 180° 正对拧坏蒙皮
						side = 1.0 if (lateral - _host._lane_x) >= 0.0 else -1.0
					if absf(desired) < min_turn:
						desired = side * min_turn
				target_yaw = clampf(desired, -PICKUP_LOOK_MAX, PICKUP_LOOK_MAX)
		var cur: float = float(p.get("look_yaw", 0.0))
		cur = lerpf(cur, target_yaw, 1.0 - exp(-PICKUP_LOOK_LERP * delta))
		p["look_yaw"] = cur
		# 路上待捡保持站立；扭头幅度大时只停动画，回来后仍站着，不要切回跑/舞
		var ap: AnimationPlayer = p.get("anim")
		if ap != null and is_instance_valid(ap):
			var pause_at := 0.22 if _host._character_id != CHAR_CAPYBARA and _host._character_id != CHAR_QINGQING else 0.35
			if absf(cur) > pause_at:
				if ap.is_playing():
					ap.stop()
				ap.active = false
			elif not ap.active:
				var vis: Node = p.get("visual")
				if vis == null:
					vis = node
				_park_stack_rider(vis)
		# 延后一帧应用，压过 AnimationPlayer
		_apply_pickup_head_yaw(p, cur)
	# 再 deferred 盖一次，确保渲染前是回头姿势
	_host.call_deferred("_stack_sys._apply_all_pickup_looks")


func _apply_all_pickup_looks() -> void:
	for p in _host._pickups:
		if p is Dictionary:
			_apply_pickup_head_yaw(p, float(p.get("look_yaw", 0.0)))


func _apply_pickup_head_yaw(p: Dictionary, yaw: float) -> void:
	# LookPivot：卡皮只拧头；新角色可略转身子，否则自动权重几乎看不出回头
	var look: Node3D = p.get("look")
	var body_look := float(p.get("body_look", 0.0))
	if look != null and is_instance_valid(look):
		look.rotation.y = yaw * body_look

	var skel: Skeleton3D = p.get("skel")
	if skel == null or not is_instance_valid(skel):
		return

	var bones: Array = p.get("look_bones", [])
	if bones.is_empty():
		var bone0: int = int(p.get("head_bone", -1))
		if bone0 >= 0:
			bones = [bone0]
			var bone1: int = int(p.get("head_bone_1", -1))
			if bone1 >= 0:
				bones.append(bone1)
	if bones.is_empty():
		return

	skel.reset_bone_poses()
	var n := bones.size()
	for i in n:
		var bi: int = int(bones[i])
		if bi < 0:
			continue
		# 靠近末梢的骨多转一点，过肩更明显
		var w := (float(i) + 1.0) / float(n * (n + 1) / 2)
		_set_bone_world_yaw(skel, bi, yaw * w)
	skel.force_update_all_bone_transforms()


func _set_bone_world_yaw(skel: Skeleton3D, bone_idx: int, yaw: float) -> void:
	## 仅绕骨局部 Y 轴旋转 pose，不改 bone position，避免蒙皮把腿/身子拉形
	skel.set_bone_pose_rotation(bone_idx, Quaternion(Vector3.UP, yaw))


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for c in node.get_children():
		var s := _find_skeleton(c)
		if s != null:
			return s
	return null


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for c in node.get_children():
		var a := _find_animation_player(c)
		if a != null:
			return a
	return null


func _normalize_bone_key(name: String) -> String:
	return name.to_lower().replace("::", "_").replace("/", "_").replace(" ", "_")


func _find_head_bone(skel: Skeleton3D) -> int:
	if skel == null:
		return -1
	var prefer := ["head_0", "head_1", "head"]
	var best := -1
	var best_score := -1
	for i in skel.get_bone_count():
		var key := _normalize_bone_key(skel.get_bone_name(i))
		# 避免匹配 forehead / headband 等
		if "shoulder" in key or "fore" in key:
			continue
		for s in prefer.size():
			if prefer[s] in key:
				var score := prefer.size() - s
				# 精确叫 head 加分
				if key == "head" or key.ends_with("_head") or key.ends_with("/head"):
					score += 2
				if score > best_score:
					best_score = score
					best = i
				break
	return best


func _find_head_bone_secondary(skel: Skeleton3D, primary: int) -> int:
	if skel == null or primary < 0:
		return -1
	# 优先 primary 的子骨里带 head 的
	for i in skel.get_bone_count():
		if skel.get_bone_parent(i) != primary:
			continue
		var key := _normalize_bone_key(skel.get_bone_name(i))
		if "head" in key:
			return i
	# 否则找 head_1
	for i in skel.get_bone_count():
		if i == primary:
			continue
		var key2 := _normalize_bone_key(skel.get_bone_name(i))
		if "head_1" in key2:
			return i
	return -1


func _collect_look_bones(skel: Skeleton3D) -> Array[int]:
	## 颈→头链：新角色单转 Head 往往看不见，需连 Neck 一起过肩
	var out: Array[int] = []
	if skel == null:
		return out
	var necks: Array[int] = []
	var heads: Array[int] = []
	for i in skel.get_bone_count():
		var key := _normalize_bone_key(skel.get_bone_name(i))
		if "shoulder" in key or "clavicle" in key:
			continue
		if "neck" in key:
			necks.append(i)
		elif key == "head" or key.ends_with("_head") or "head_" in key or key.begins_with("head"):
			heads.append(i)
	# Neck1/2/3 或 Neck 按名排序，保证从根到梢
	necks.sort_custom(func(a: int, b: int) -> bool:
		return skel.get_bone_name(a) < skel.get_bone_name(b)
	)
	heads.sort_custom(func(a: int, b: int) -> bool:
		return skel.get_bone_name(a) < skel.get_bone_name(b)
	)
	# 最多取末两节颈 + 头骨，避免整条脊柱拧麻花
	if necks.size() > 2:
		necks = necks.slice(necks.size() - 2, necks.size())
	for i in necks:
		out.append(i)
	for i in heads:
		out.append(i)
	if out.is_empty():
		var fallback := _find_head_bone(skel)
		if fallback >= 0:
			out.append(fallback)
			var sec := _find_head_bone_secondary(skel, fallback)
			if sec >= 0:
				out.append(sec)
	return out


func _find_anim_by_keys(ap: AnimationPlayer, keys: Array) -> String:
	if ap == null:
		return ""
	# 按 keys 优先级匹配（前面优先）
	for k in keys:
		var needle := String(k).to_lower()
		for n in ap.get_animation_list():
			if needle in String(n).to_lower():
				return String(n)
	return ""


func _find_head_look_anim_name(ap: AnimationPlayer) -> String:
	return _find_anim_by_keys(ap, ["head_look", "capy_head"])


func _play_capy_clip(visual: Node, clip_keys: Array, loop: bool = true) -> void:
	var ap := _find_animation_player(visual)
	if ap == null:
		return
	var clip := _find_anim_by_keys(ap, clip_keys)
	if clip.is_empty():
		return
	ap.active = true
	ap.speed_scale = 1.0
	if ap.current_animation != clip or not ap.is_playing():
		ap.play(clip)
	var anim := ap.get_animation(clip)
	if anim != null:
		anim.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE


func _freeze_soft_skin_rest(visual: Node) -> void:
	## 仅用于选角预览等需要 rest 外形的场合
	if visual == null or not is_instance_valid(visual):
		return
	_mute_animation_players(visual)
	var skel := _find_skeleton(visual)
	if skel == null:
		return
	skel.reset_bone_poses()
	if skel.has_method("force_update_all_bone_transforms"):
		skel.call("force_update_all_bone_transforms")


func _sync_capy_locomotion_anim(visual: Node, want_jump: bool) -> void:
	if visual == null or not is_instance_valid(visual):
		return
	if want_jump:
		_play_capy_clip(visual, ["jump"], true)
	else:
		# 奔跑姿态（原版四足跑 / 软蒙皮腿部跑）
		_play_capy_clip(visual, ["run"], true)


func _park_stack_rider(visual: Node) -> void:
	## 叠在上面的乘客：停跑，定在 idle/rest，不再动
	if visual == null or not is_instance_valid(visual):
		return
	var ap := _find_animation_player(visual)
	if ap == null:
		return
	var clip := _find_anim_by_keys(ap, ["idle", "dance"])
	if clip.is_empty():
		_mute_animation_players(visual)
		var skel := _find_skeleton(visual)
		if skel != null:
			skel.reset_bone_poses()
		return
	ap.active = true
	ap.speed_scale = 1.0
	if ap.current_animation != clip or ap.is_playing():
		ap.play(clip)
		ap.seek(0.0, true)
		ap.pause()
	elif ap.current_animation_position > 0.02:
		ap.seek(0.0, true)
		ap.pause()


func _mute_animation_players(node: Node) -> void:
	if node is AnimationPlayer:
		var ap := node as AnimationPlayer
		ap.active = false
		ap.stop()
		ap.speed_scale = 1.0
	for c in node.get_children():
		_mute_animation_players(c)


func _bind_pickup_head(visual: Node3D, into: Dictionary) -> void:
	var skel := _find_skeleton(visual)
	var look_bones := _collect_look_bones(skel)
	var bone := look_bones[0] if not look_bones.is_empty() else _find_head_bone(skel)
	var bone1 := look_bones[1] if look_bones.size() > 1 else _find_head_bone_secondary(skel, bone)
	var ap := _find_animation_player(visual)
	into["skel"] = skel
	into["head_bone"] = bone
	into["head_bone_1"] = bone1
	var has_head_rig := skel != null and (bone >= 0 or not look_bones.is_empty())
	if not has_head_rig:
		# 静态 GLB（新 Tripo 无 Head 骨）：LookPivot 整模转向玩家
		into["look_bones"] = []
		into["body_look"] = 0.52
	elif _is_soft_skin_character():
		# 软蒙皮：少拧颈头骨，主要靠身子微转，避免融化
		into["look_bones"] = []
		into["body_look"] = 0.25
	else:
		into["look_bones"] = look_bones
		var body_look := 0.0
		if _host._character_id != CHAR_CAPYBARA and _host._character_id != CHAR_QINGQING:
			body_look = 0.55 if _is_upright_character() else 0.35
		into["body_look"] = body_look
	into["anim"] = ap
	into["visual"] = visual
	into["anim_name"] = _find_anim_by_keys(ap, ["dance"])
	into["look_yaw"] = 0.0
	into["look_played"] = false
	if has_head_rig:
		if bone >= 0:
			into["head_rest_q"] = skel.get_bone_rest(bone).basis.get_rotation_quaternion()
		else:
			into["head_rest_q"] = Quaternion.IDENTITY
		_ensure_mesh_skeleton(visual, skel)
	else:
		into["head_rest_q"] = Quaternion.IDENTITY
	# 路上待捡：站立静止。跑姿只留给塔底那只。
	_park_stack_rider(visual)
	if ap != null:
		ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	_resnap_character_feet(visual, ["idle", "run"])

func _ensure_mesh_skeleton(root: Node, skel: Skeleton3D) -> void:
	if skel == null:
		return
	for node in _find_meshes(root):
		var mi := node as MeshInstance3D
		if mi == null:
			continue
		var want := mi.get_path_to(skel)
		if mi.skeleton != want:
			mi.skeleton = want

func _character_display_name() -> String:
	match _host._character_id:
		CHAR_QINGQING:
			return "青青"
		CHAR_LITTLE_MONSTER:
			return "小怪兽"
		CHAR_LITTLE_RABBIT:
			return "小兔子"
		CHAR_SHIBA:
			return "柴犬"
		CHAR_BIRD:
			return "小鸟"
		CHAR_MOUSE:
			return "小老鼠"
		CHAR_SLOTH:
			return "树懒"
		CHAR_TINY_PLANET:
			return "小行星"
		CHAR_BEAR:
			return "小熊"
		CHAR_COW:
			return "牛来"
		_:
			return "卡皮巴拉"


func _pick_rigged_or_base(rigged: String, base: String) -> String:
	# Web 从 CDN 拉绑定版；磁盘上没有 res:// glb 也要返回 rigged 路径
	if _host._cdn_sys != null and _host._cdn_sys.is_enabled():
		return rigged
	if ResourceLoader.exists(rigged) or FileAccess.file_exists(rigged):
		return rigged
	if ResourceLoader.exists(base) or FileAccess.file_exists(base):
		return base
	return ""


func _character_model_path() -> String:
	match _host._character_id:
		CHAR_QINGQING:
			var p := _pick_rigged_or_base(CapybaraRushPaths.QINGQING_RIGGED, CapybaraRushPaths.QINGQING)
			if not p.is_empty():
				return p
			if ResourceLoader.exists(CapybaraRushPaths.QINGQING):
				return CapybaraRushPaths.QINGQING
		CHAR_LITTLE_MONSTER:
			var p := _pick_rigged_or_base(CapybaraRushPaths.LITTLE_MONSTER_RIGGED, CapybaraRushPaths.LITTLE_MONSTER)
			if not p.is_empty():
				return p
		CHAR_LITTLE_RABBIT:
			var p := _pick_rigged_or_base(CapybaraRushPaths.LITTLE_RABBIT_RIGGED, CapybaraRushPaths.LITTLE_RABBIT)
			if not p.is_empty():
				return p
		CHAR_SHIBA:
			var p := _pick_rigged_or_base(CapybaraRushPaths.SHIBA_RIGGED, CapybaraRushPaths.SHIBA)
			if not p.is_empty():
				return p
		CHAR_BIRD:
			var p := _pick_rigged_or_base(CapybaraRushPaths.BIRD_RIGGED, CapybaraRushPaths.BIRD)
			if not p.is_empty():
				return p
		CHAR_MOUSE:
			var p := _pick_rigged_or_base(CapybaraRushPaths.MOUSE_RIGGED, CapybaraRushPaths.MOUSE)
			if not p.is_empty():
				return p
		CHAR_SLOTH:
			var p := _pick_rigged_or_base(CapybaraRushPaths.SLOTH_RIGGED, CapybaraRushPaths.SLOTH)
			if not p.is_empty():
				return p
		CHAR_TINY_PLANET:
			var p := _pick_rigged_or_base(CapybaraRushPaths.TINY_PLANET_RIGGED, CapybaraRushPaths.TINY_PLANET)
			if not p.is_empty():
				return p
		CHAR_BEAR:
			var p := _pick_rigged_or_base(CapybaraRushPaths.BEAR_RIGGED, CapybaraRushPaths.BEAR)
			if not p.is_empty():
				return p
		CHAR_COW:
			return _pick_rigged_or_base(CapybaraRushPaths.COW_RIGGED, CapybaraRushPaths.COW)
		CHAR_CAPYBARA:
			return _pick_rigged_or_base(CapybaraRushPaths.CAPYBARA_BASE_RIGGED, CapybaraRushPaths.CAPYBARA_BASE)
	return CapybaraRushPaths.CAPYBARA_BASE

func _character_yaw() -> float:
	match _host._character_id:
		CHAR_QINGQING:
			return QINGQING_FORWARD_YAW
		CHAR_LITTLE_MONSTER:
			return MONSTER_FORWARD_YAW
		CHAR_LITTLE_RABBIT:
			return RABBIT_FORWARD_YAW
		CHAR_SHIBA:
			return SHIBA_FORWARD_YAW
		CHAR_BIRD:
			return BIRD_FORWARD_YAW
		CHAR_MOUSE:
			return MOUSE_FORWARD_YAW
		CHAR_SLOTH:
			return SLOTH_FORWARD_YAW
		CHAR_TINY_PLANET:
			return TINY_PLANET_FORWARD_YAW
		CHAR_BEAR:
			return BEAR_FORWARD_YAW
		CHAR_COW:
			return COW_FORWARD_YAW
		_:
			if _host._character_id == CHAR_CAPYBARA and _is_tripo_capy_path(_character_model_path()):
				return TRIPO_CAPY_FORWARD_YAW
			return CAPY_FORWARD_YAW


func _is_upright_character(char_id: String = "") -> bool:
	var id: String = char_id if not char_id.is_empty() else _host._character_id
	return id in CHAR_UPRIGHT_IDS


func _is_soft_skin_character(char_id: String = "") -> bool:
	var id: String = char_id if not char_id.is_empty() else _host._character_id
	return id in CHAR_SOFT_SKIN_IDS


func _path_is_soft_skin(path: String) -> bool:
	var p := path.to_lower()
	for id in CHAR_SOFT_SKIN_IDS:
		if p.contains(String(id)):
			return true
	return false




func _start_ready_spin() -> void:
	## 全角色：起跑线后原地转圈，按空格再开跑
	_host._waiting_to_start = true
	_host._intro_showcasing = false
	_host._playing = false
	_host._ready_spin_yaw = 0.0
	_host._progress = START_PLAYER_PROGRESS
	_host._lane = 1
	_host._lane_x = _host._lane_to_x(_host._lane)
	_host._air_y = ROAD_SURFACE_Y
	_host._grounded = true
	if _host._hud_tip:
		_host._hud_tip.visible = true
		_host._hud_tip.text = "%s 准备出发 · 点屏幕开跑" % _character_display_name()
	if _host._tower == null or _host._stack.is_empty():
		_host._begin_gameplay()
		return
	_path_place_tower_ready()
	var layer: Node3D = _host._stack[0]
	if layer == null or not is_instance_valid(layer):
		_host._begin_gameplay()
		return
	layer.rotation = Vector3(0.0, _character_yaw(), 0.0)
	layer.position = Vector3.ZERO
	layer.scale = Vector3.ONE
	# 先 idle 贴地，准备转圈用 idle（dance 抬脚会量错、看起来陷进路面）
	_play_capy_clip(layer, ["idle", "run", "dance"], true)
	_host.call_deferred("_resnap_then_ready_idle", layer)
	_host._race_sys.update_camera()
	if _host._hud_tip:
		_host._hud_tip.text = "%s 准备出发 · 点屏幕开跑" % _character_display_name()
	_host._ui_sys.show_ready_chrome()


func _path_place_tower_ready() -> void:
	if _host._tower == null:
		return
	if _host._path != null:
		var f: Dictionary = _host._path.frame_at(_host._progress)
		_host._path_yaw = float(f["yaw"])
		var p: Vector3 = f["pos"]
		var r: Vector3 = f["right"]
		# 脚底对齐路面顶，避免浮空/埋地
		_host._tower.global_position = p + r * _host._lane_x + Vector3(0.0, ROAD_SURFACE_Y, 0.0)
		_host._tower.rotation = Vector3(0.0, _host._path_yaw, 0.0)
	else:
		_host._tower.position = Vector3(_host._lane_x, ROAD_SURFACE_Y, _host._progress)
		_host._tower.rotation = Vector3.ZERO


func _update_ready_spin(delta: float) -> void:
	_path_place_tower_ready()
	if _host._tower == null or _host._stack.is_empty():
		_host._race_sys.update_camera()
		return
	var layer: Node3D = _host._stack[0]
	if layer == null or not is_instance_valid(layer):
		_host._race_sys.update_camera()
		return
	_host._ready_spin_yaw += READY_SPIN_SPEED * delta
	layer.rotation = Vector3(0.0, _character_yaw() + _host._ready_spin_yaw, 0.0)
	layer.position = Vector3.ZERO
	_host._race_sys.update_camera()


func _start_qingqing_intro() -> void:
	# 旧接口：并入全角色准备转圈
	_start_ready_spin()


func _update_intro_camera(_delta: float) -> void:
	_update_ready_spin(_delta)


func _update_tower_motion() -> void:
	if _host._tower == null:
		return
	var t := Time.get_ticks_msec() * 0.001
	# 只向上轻颠，避免负 bob 把脚压进跑道
	var bob := absf(sin(t * BOB_FREQ)) * BOB_AMP if _host._grounded and not _host._cliff_rescuing else 0.0
	if _host._path != null:
		var f: Dictionary = _host._path.frame_at(_host._progress)
		_host._path_yaw = float(f["yaw"])
		var p: Vector3 = f["pos"]
		var r: Vector3 = f["right"]
		_host._tower.global_position = p + r * _host._lane_x + Vector3(0.0, _host._air_y + bob, 0.0)
		var lean_target := clampf((_host._lane_x - _host._prev_lane_x) * 14.0, -MAX_LEAN, MAX_LEAN)
		var wobble := sin(t * 14.0) * minf(_host._sway, 2.0) * 0.08
		if _host._cliff_rescuing:
			lean_target = 0.0
			wobble = 0.0
		# 模型自身 yaw 在 fitted wrap 上；塔只跟弯道切向；断崖倾倒用 tip pitch
		_host._tower.rotation = Vector3(_host._cliff_tip_pitch, _host._path_yaw, lean_target + wobble)
	else:
		_host._tower.position = Vector3(_host._lane_x, _host._air_y + bob, _host._progress)
		var lean_target2 := clampf((_host._lane_x - _host._prev_lane_x) * 14.0, -MAX_LEAN, MAX_LEAN)
		var wobble2 := sin(t * 14.0) * minf(_host._sway, 2.0) * 0.08
		_host._tower.rotation.x = _host._cliff_tip_pitch
		_host._tower.rotation.z = 0.0 if _host._cliff_rescuing else (lean_target2 + wobble2)
	# 拾取插入动画期间由 tween 接管各层位姿
	if _host._stack_animating or _host._cliff_rescuing:
		return
	if _host._is_race():
		if _host._race_visual != null:
			_sync_capy_locomotion_anim(_host._race_visual, not _host._grounded)
		return
	var n: int = _host._stack.size()
	var want_jump: bool = not _host._grounded
	for i in n:
		var layer: Node3D = _host._stack[i]
		if layer == null:
			continue
		# 只有最底层跑/跳；上面叠着的定住不动
		if i == 0:
			_sync_capy_locomotion_anim(layer, want_jump)
			var amp := 0.04 + minf(_host._sway, 2.2) * 0.04
			var roll_mul := 0.25 if _is_upright_character() else 0.8
			var pitch_mul := 0.55 if _is_upright_character() else 1.0
			if _is_soft_skin_character():
				pitch_mul = 0.35
				roll_mul = 0.12
				amp = minf(amp, 0.035)
			layer.rotation = Vector3(
				sin(t * BOB_FREQ) * amp * pitch_mul,
				_character_yaw(),
				sin(t * 11.0) * amp * roll_mul
			)
			layer.position = Vector3(0.0, 0.0, 0.0)
		else:
			_park_stack_rider(layer)
			layer.rotation = Vector3(0.0, _character_yaw(), 0.0)
			layer.position = Vector3(0.0, float(i) * STACK_STEP_Y, 0.0)


func _try_collect_pickups() -> void:
	var remain: Array[Dictionary] = []
	for p in _host._pickups:
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var dist: float = float(p.get("dist", node.global_position.z))
		var lateral: float = float(p.get("lateral", node.global_position.x))
		if _host._along_overlap(dist, lateral, PICKUP_RADIUS_Z, PICKUP_RADIUS_X):
			_host._picked_count += 1
			if _host._stack_animating:
				_host._pending_pickup_holders.append(node)
			else:
				_begin_pickup_under_anim(node)
		else:
			remain.append(p)
	_host._pickups = remain


func _add_stack_layer() -> void:
	var idx: int = _host._stack.size()
	var layer := _make_capy_visual("run" if idx == 0 else "idle")
	if layer == null:
		return
	layer.position = Vector3(0.0, float(idx) * STACK_STEP_Y, 0.0)
	_host._tower.add_child(layer)
	_host._stack.append(layer)
	if idx == 0:
		_play_capy_clip(layer, ["run"], true)
	else:
		_park_stack_rider(layer)
	# 叠上只轻微晃一下，不会触发掉落
	_host._sway = minf(_host._sway + 0.08, 1.2)


func _extract_pickup_visual(holder: Node3D) -> Node3D:
	if holder == null or not is_instance_valid(holder):
		return null
	# holder → LookPivot → fitted wrap；叠塔要用最内层 wrap
	var incoming: Node3D = null
	var look := holder.get_node_or_null("LookPivot") as Node3D
	if look != null and look.get_child_count() > 0:
		incoming = look.get_child(0) as Node3D
	elif holder.get_child_count() > 0:
		incoming = holder.get_child(0) as Node3D
	if incoming == null:
		incoming = holder
	var gpos := incoming.global_position
	var parent := incoming.get_parent()
	if parent:
		parent.remove_child(incoming)
	if holder != incoming and is_instance_valid(holder):
		holder.queue_free()
	_host._tower.add_child(incoming)
	incoming.global_position = gpos
	# 复位朝向：跟着塔的弯道切向，模型自身 yaw 朝前方
	incoming.rotation = Vector3(0.0, _character_yaw(), 0.0)
	# 复位全部头颈骨 pose，避免拾取时扭头姿势带进塔里
	var skel := _find_skeleton(incoming)
	if skel != null:
		skel.reset_bone_poses()
	return incoming


func _begin_pickup_under_anim(pickup_holder: Node3D) -> void:
	if _host._tower == null or pickup_holder == null or not is_instance_valid(pickup_holder):
		return
	if _host._stack_animating:
		_host._pending_pickup_holders.append(pickup_holder)
		return

	var old_layers: Array[Node3D] = _host._stack.duplicate()
	var incoming := _extract_pickup_visual(pickup_holder)
	if incoming == null:
		_drain_pending_pickups()
		return

	_host._stack_animating = true
	_host._sway = minf(_host._sway + 0.12, 1.4)
	_host._play_sfx_pickup()
	# 先占位到底层，动画只负责位姿；计数/相机立即 +1
	_host._stack.insert(0, incoming)
	for old in old_layers:
		_park_stack_rider(old)

	var face_yaw := _character_yaw()
	var start_local := incoming.position
	# 从身前略低处钻入
	var dive_pos := Vector3(
		clampf(start_local.x * 0.35, -0.8, 0.8),
		-0.18,
		clampf(start_local.z, -0.2, 1.2) * 0.45 + 0.55
	)

	var tw := _host.create_tween()
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
	if incoming == null or not is_instance_valid(incoming) or _host._stack.is_empty() or _host._stack[0] != incoming:
		_host._stack.clear()
		if incoming != null and is_instance_valid(incoming):
			_host._stack.append(incoming)
		for layer in old_layers:
			if layer != null and is_instance_valid(layer):
				_host._stack.append(layer)

	for i in _host._stack.size():
		var layer: Node3D = _host._stack[i]
		if layer == null or not is_instance_valid(layer):
			continue
		layer.position = Vector3(0.0, float(i) * STACK_STEP_Y, 0.0)
		layer.rotation = Vector3(0.0, face_yaw, 0.0)
		layer.scale = Vector3.ONE
		if i == 0:
			_play_capy_clip(layer, ["run"], true)
			_resnap_character_feet(layer, ["run", "idle"])
		else:
			_park_stack_rider(layer)
			_resnap_character_feet(layer, ["idle", "run"])

	_host._stack_animating = false
	_flush_pending_hazard_hits()
	_drain_pending_pickups()


func _drain_pending_pickups() -> void:
	while not _host._pending_pickup_holders.is_empty():
		var next: Node3D = _host._pending_pickup_holders.pop_front()
		if next != null and is_instance_valid(next):
			_begin_pickup_under_anim(next)
			return


func _spawn_tower() -> void:
	_host._tower = Node3D.new()
	_host._tower.name = "CapyTower"
	_host._world.add_child(_host._tower)
	_add_stack_layer()
	if not _host._stack.is_empty():
		_host.call_deferred("_resnap_character_feet", _host._stack[0], ["idle", "run"])


func _spawn_pickups() -> void:
	## 沿三道散落可叠水豚；间距读关卡
	var z := 16.0
	var i := 0
	var track_len: float = _host._track_len()
	var spacing: Array = _host._level_cfg.get("pickup_spacing", [10.0, 14.0])
	var lo := float(spacing[0]) if spacing.size() > 0 else 10.0
	var hi := float(spacing[1]) if spacing.size() > 1 else 14.0
	while z < track_len - 22.0:
		var lane := i % LANE_COUNT
		_spawn_pickup_at(_host._lane_to_x(lane), z)
		if i % 3 == 0:
			var other := (lane + 1 + (i % 2)) % LANE_COUNT
			_spawn_pickup_at(_host._lane_to_x(other), z + 5.0)
		z += randf_range(lo, hi)
		i += 1


func _try_hit_hazards() -> void:
	for h in _host._hazard_sys.items:
		if bool(h.get("hit", false)):
			continue
		if _host._hazard_sys.overlap(h, _host._progress, _host._lane_x, _host._air_y) == false:
			continue
		# 脚底必须真正超过障碍顶才算跳过。
		# 以前用偏低的 clear_y：看起来还在穿模，却判定“跳过了”→ 不掉层。
		var hit_top := CapybaraHazards.hit_top(h)
		if (not _host._grounded) and _host._air_y >= hit_top - 0.02:
			continue
		# 拾取叠层动画中：先记下，动画结束后再掉层（避免 hit=true 却直接 return）
		if _host._stack_animating:
			h["pending_hit"] = true
			continue
		_apply_hazard_hit(h)


func _apply_hazard_hit(h: Dictionary) -> void:
	if bool(h.get("hit", false)):
		return
	h["hit"] = true
	h["pending_hit"] = false
	_host._collision_count += 1
	_host._play_sfx_hit()
	_force_drop_from_hazard(h)
	# 障碍物保持原地，不被撞飞


func _flush_pending_hazard_hits() -> void:
	## 拾取动画结束：结算期间擦过的障碍（即使人已离开碰撞盒也要掉）
	for h in _host._hazard_sys.items:
		if bool(h.get("hit", false)):
			continue
		if not bool(h.get("pending_hit", false)):
			continue
		_apply_hazard_hit(h)



func _spawn_pickup_at(x: float, z: float) -> void:
	var visual := _make_capy_visual("idle")
	if visual == null:
		return
	var holder := Node3D.new()
	_host._world.add_child(holder)
	_host._track_sys.path_place(holder, z, x, ROAD_SURFACE_Y, 0.0)
	# LookPivot 仅作无骨骼回退；有 Head 骨时身子不动
	var look := Node3D.new()
	look.name = "LookPivot"
	holder.add_child(look)
	look.add_child(visual)
	var entry := {
		"node": holder, "look": look, "phase": randf() * TAU,
		"dist": z, "lateral": x,
	}
	_bind_pickup_head(visual, entry)
	_host._pickups.append(entry)


func _make_capy_visual(start_anim: String = "run") -> Node3D:
	var paths: Array[String] = [_character_model_path()]
	if paths[0].is_empty():
		paths = [CapybaraRushPaths.CAPYBARA_BASE]
	for path in paths:
		var n: Node3D = _host._instance_fitted(path, TARGET_CAPY_HEIGHT, _character_yaw(), start_anim)
		if n:
			return n
	var stub := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.5
	sph.height = 1.0
	stub.mesh = sph
	var sm := StandardMaterial3D.new()
	match _host._character_id:
		CHAR_QINGQING:
			sm.albedo_color = Color(0.85, 0.72, 0.55)
		CHAR_LITTLE_MONSTER:
			sm.albedo_color = Color(0.55, 0.88, 0.90)
		CHAR_LITTLE_RABBIT:
			sm.albedo_color = Color(0.98, 0.82, 0.88)
		CHAR_SHIBA:
			sm.albedo_color = Color(0.86, 0.62, 0.38)
		CHAR_BIRD:
			sm.albedo_color = Color(0.55, 0.78, 0.95)
		CHAR_MOUSE:
			sm.albedo_color = Color(0.72, 0.70, 0.66)
		CHAR_SLOTH:
			sm.albedo_color = Color(0.70, 0.58, 0.42)
		CHAR_TINY_PLANET:
			sm.albedo_color = Color(0.55, 0.72, 0.88)
		CHAR_BEAR:
			sm.albedo_color = Color(0.62, 0.42, 0.28)
		CHAR_COW:
			sm.albedo_color = Color(0.55, 0.48, 0.42)
		_:
			sm.albedo_color = Color(0.78, 0.62, 0.42)
	stub.material_override = sm
	stub.position.y = 0.5
	push_warning("Character model failed to load; using sphere stub")
	return stub


func _tint_capy_brown(root: Node) -> void:
	## 均匀乘色变棕，避免再改贴图像素（否则 UV 岛会像拼色）
	for node in _find_meshes(root):
		var mi := node as MeshInstance3D
		if mi == null:
			continue
		var mat_count := mi.get_surface_override_material_count()
		if mat_count <= 0 and mi.mesh != null:
			mat_count = mi.mesh.get_surface_count()
		for i in mat_count:
			var base_mat: Material = mi.get_active_material(i)
			if base_mat == null:
				continue
			var mat := base_mat.duplicate() as Material
			if mat is StandardMaterial3D:
				var sm := mat as StandardMaterial3D
				# 整模同一乘数，不会出现「上深下浅」拼缝
				sm.albedo_color = Color(0.62, 0.42, 0.28, sm.albedo_color.a)
			mi.set_surface_override_material(i, mat)


func _measure_lowest_global_y(wrap: Node3D, prefer_bones: bool = false) -> float:
	if wrap == null or not is_instance_valid(wrap):
		return INF
	wrap.force_update_transform()
	var skel := _find_skeleton(wrap)
	if skel != null and skel.has_method("force_update_all_bone_transforms"):
		skel.call("force_update_all_bone_transforms")
	var local_y := _measure_lowest_contact_y(wrap, prefer_bones)
	if local_y == INF or local_y > 9000.0:
		return INF
	return (wrap.global_transform * Vector3(0.0, local_y, 0.0)).y


func _seat_actor_on_floor_y(actor: Node3D, floor_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	var first := true
	var min_y := 0.0
	for node in _find_meshes(actor):
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


func _snap_actor_feet_to_world_y(actor: Node3D, target_y: float) -> void:
	if actor == null or not is_instance_valid(actor):
		return
	var prefer_bones := true
	var ap := _find_animation_player(actor)
	var restore_clip := ""
	var restore_pos := 0.0
	var restore_playing := false
	var lowest_global := INF
	if ap != null:
		restore_clip = ap.current_animation
		restore_pos = ap.current_animation_position
		restore_playing = ap.is_playing()
		var measure_clip := _find_anim_by_keys(ap, ["run", "idle"])
		if not measure_clip.is_empty():
			ap.play(measure_clip)
			var times := _foot_snap_sample_times(ap, measure_clip)
			if times.is_empty():
				actor.force_update_transform()
				lowest_global = _measure_lowest_global_y(actor, prefer_bones)
			else:
				for seek_t in times:
					ap.seek(seek_t, true)
					ap.advance(0.0)
					actor.force_update_transform()
					lowest_global = minf(lowest_global, _measure_lowest_global_y(actor, prefer_bones))
	if lowest_global == INF:
		actor.force_update_transform()
		lowest_global = _measure_lowest_global_y(actor, prefer_bones)
	if lowest_global == INF:
		_seat_actor_on_floor_y(actor, target_y)
		if ap != null and not restore_clip.is_empty():
			ap.play(restore_clip)
			ap.seek(restore_pos, true)
			if not restore_playing:
				ap.pause()
		return
	actor.global_position.y += target_y - lowest_global
	# 二次校正：旋转/骨骼采样后 mesh 底仍可能略低
	actor.force_update_transform()
	var mesh_low := INF
	for node in _find_meshes(actor):
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var local := mi.get_aabb()
		for i in 8:
			mesh_low = minf(mesh_low, (mi.global_transform * local.get_endpoint(i)).y)
	if mesh_low != INF and mesh_low < target_y - 0.008:
		actor.global_position.y += target_y - mesh_low
	if ap != null and not restore_clip.is_empty():
		ap.play(restore_clip)
		ap.seek(restore_pos, true)
		if not restore_playing:
			ap.pause()



func _instance_fitted(path: String, target_height: float, yaw: float = 0.0, start_anim: String = "run") -> Node3D:
	var load_path := path
	if _host._cdn_sys != null:
		load_path = _host._cdn_sys.resolve_model_path(path)
	# 新入库的 .glb 可能尚未进 ResourceLoader 缓存，仍允许 FileAccess 直读
	if not ResourceLoader.exists(load_path) and not FileAccess.file_exists(load_path):
		push_warning("Missing model: %s" % load_path)
		return null
	var packed: PackedScene = _load_model_packed(load_path)
	if packed == null:
		push_warning("Failed to load model: %s" % load_path)
		return null
	var raw: Node3D = packed.instantiate() as Node3D
	if raw == null:
		return null

	var wrap := Node3D.new()
	wrap.add_child(raw)
	_host.add_child(wrap)
	# 蒙皮网格需进树后用 get_aabb，否则贴地会算矮、腿埋地
	var skel := _find_skeleton(wrap)
	if skel != null:
		skel.reset_bone_poses()
		_ensure_mesh_skeleton(wrap, skel)
	var aabb := _local_aabb(wrap)
	if aabb.size.y < 0.01:
		aabb = AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1, 1))
	var s := target_height / aabb.size.y
	raw.scale = Vector3.ONE * s
	# 先按 rest AABB 居中缩放；脚底最终以动画后再测为准
	raw.position = Vector3(
		-(aabb.position.x + aabb.size.x * 0.5) * s,
		-aabb.position.y * s,
		-(aabb.position.z + aabb.size.z * 0.5) * s
	)
	wrap.rotation.y = yaw

	var is_char := (
		load_path.contains("/characters/")
		or load_path.contains("qingqing")
		or _is_cow_model_path(load_path)
		or _is_capy_model_path(load_path)
	)
	# 角色默认进跑姿再量脚：rest 贴地 → 一跑就埋进赛道
	# 路上待捡用 idle/rest 量脚，避免一生成就是跑姿
	var want_run := is_char and start_anim != "idle"
	if is_char:
		if want_run:
			_play_capy_clip(wrap, ["run", "idle"], true)
		else:
			_play_capy_clip(wrap, ["idle", "run"], true)
		_snap_fitted_feet_to_ground(
			wrap,
			raw,
			_foot_lift_for_path(path),
			["idle", "run"] if not want_run else ["run", "idle"],
			_is_capy_model_path(path) or _is_cow_model_path(path)
		)
	else:
		_play_capy_clip(wrap, ["run", "dance"], true)

	_host.remove_child(wrap)
	if is_char:
		if want_run:
			_play_capy_clip(wrap, ["run"], true)
		else:
			_park_stack_rider(wrap)
		if (
			_is_capy_model_path(load_path) or _is_capy_model_path(path)
			or _is_cow_model_path(load_path) or _is_cow_model_path(path)
		):
			_apply_preview_albedo(wrap, path if path != "" else load_path)
	return wrap


var _gltf_packed_cache: Dictionary = {}


func _load_model_packed(load_path: String) -> PackedScene:
	if _gltf_packed_cache.has(load_path):
		return _gltf_packed_cache[load_path] as PackedScene
	var packed: PackedScene = null
	if load_path.begins_with("res://") and ResourceLoader.exists(load_path):
		packed = load(load_path) as PackedScene
	if packed == null and FileAccess.file_exists(load_path):
		packed = _pack_gltf_file(load_path)
	if packed != null:
		_gltf_packed_cache[load_path] = packed
	return packed


func _pack_gltf_file(path: String) -> PackedScene:
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	var err := doc.append_from_file(path, state)
	if err != OK:
		push_warning("GLTF append_from_file failed %s err=%s" % [path, err])
		return null
	var root := doc.generate_scene(state)
	if root == null:
		push_warning("GLTF generate_scene failed %s" % path)
		return null
	var packed := PackedScene.new()
	if packed.pack(root) != OK:
		push_warning("GLTF pack failed %s" % path)
		return null
	return packed


## Blender 已把碎三角焊成封闭体。这里只用未压缩 RGB 贴图 + 不透明材质，避免 Godot 把 Alpha 抖成盐粒。
const CAPY_ALBEDO_PATH := "res://assets/maps/route_levels/capybara_rush/models/characters/capybara_blender_albedo.png"
const COW_ALBEDO_PATH := "res://assets/maps/route_levels/capybara_rush/models/characters/cow_blender_albedo.png"
static var _capy_preview_tex: Texture2D = null
static var _cow_preview_tex: Texture2D = null


func _load_rgb8_texture(path: String) -> Texture2D:
	var img: Image = null
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex != null:
			img = tex.get_image()
			if img != null and img.is_compressed():
				img.decompress()
	if img == null:
		img = Image.new()
		var err := img.load(ProjectSettings.globalize_path(path))
		if err != OK:
			push_warning("capy albedo load failed %s err=%s" % [path, err])
			return null
	if img.get_format() != Image.FORMAT_RGB8:
		img.convert(Image.FORMAT_RGB8)
	return ImageTexture.create_from_image(img)


func _preview_tex_for(model_path: String) -> Texture2D:
	if _is_cow_model_path(model_path):
		if _cow_preview_tex == null:
			_cow_preview_tex = _load_rgb8_texture(COW_ALBEDO_PATH)
		return _cow_preview_tex
	if _capy_preview_tex == null:
		_capy_preview_tex = _load_rgb8_texture(CAPY_ALBEDO_PATH)
	return _capy_preview_tex


func _make_sealed_material(tex: Texture2D) -> StandardMaterial3D:
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	sm.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	sm.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_OFF
	sm.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_DISABLED
	sm.cull_mode = BaseMaterial3D.CULL_BACK
	sm.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
	sm.metallic = 0.0
	sm.metallic_specular = 0.0
	sm.roughness = 1.0
	sm.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	sm.vertex_color_use_as_albedo = false
	sm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	sm.albedo_color = Color.WHITE
	sm.albedo_texture = tex
	return sm


func _apply_preview_albedo(root: Node, model_path: String) -> void:
	var tex := _preview_tex_for(model_path)
	if tex == null:
		push_warning("capy sealed albedo missing path=%s" % model_path)
		return
	var mat := _make_sealed_material(tex)
	var mesh_n := 0
	for node in _find_meshes(root):
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		mesh_n += 1
		mi.transparency = 0.0
		mi.material_overlay = null
		mi.material_override = mat
		if mi.mesh != null:
			for i in mi.mesh.get_surface_count():
				mi.set_surface_override_material(i, null)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		mi.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	push_warning("capy sealed albedo meshes=%s path=%s" % [mesh_n, model_path])


func _is_capy_model_path(path: String) -> bool:
	## 不能用 path.contains("capybara")：目录名 capybara_rush 会误伤全部角色
	var file := path.get_file().to_lower()
	return (
		file.begins_with("capybara_base")
		or file == "capybara.glb"
		or file.begins_with("capybara.")
	)


func _is_tripo_capy_path(path: String) -> bool:
	var file := path.get_file().to_lower()
	return file.begins_with("capybara_base")


func _is_cow_model_path(path: String) -> bool:
	var p := path.to_lower()
	return "cow" in p


func _foot_lift_for_path(path: String) -> float:
	if _is_capy_model_path(path) or _is_cow_model_path(path):
		return CAPY_FOOT_LIFT
	if path.contains("qingqing"):
		return CAPY_FOOT_LIFT
	return CHAR_FOOT_LIFT


func _find_foot_bone_indices(skel: Skeleton3D) -> Array[int]:
	## 四足：爪尖骨；直立：脚/踝/趾 — 比整体 AABB 可靠
	if skel == null:
		return []
	var out: Array[int] = []
	for i in skel.get_bone_count():
		var key := _normalize_bone_key(skel.get_bone_name(i))
		if key.contains("limb_3"):
			out.append(i)
			continue
		if key.contains("shin"):
			out.append(i)
			continue
		if key.contains("1_left_limb"):
			out.append(i)
			continue
		if key.contains("foot") or key.contains("ankle") or key.contains("heel") or key.ends_with("toe"):
			out.append(i)
	return out


func _measure_lowest_foot_bone_y(wrap: Node3D) -> float:
	var skel := _find_skeleton(wrap)
	if skel == null:
		return INF
	var foots := _find_foot_bone_indices(skel)
	if foots.is_empty():
		return INF
	if skel.has_method("force_update_all_bone_transforms"):
		skel.call("force_update_all_bone_transforms")
	var inv := wrap.global_transform.affine_inverse()
	var lowest := INF
	for bi in foots:
		var gp: Transform3D = skel.get_bone_global_pose(bi)
		var local: Vector3 = (inv * skel.global_transform * gp).origin
		lowest = minf(lowest, local.y)
	return lowest


func _measure_lowest_contact_y(wrap: Node3D, prefer_bones: bool = false) -> float:
	var bone_y := _measure_lowest_foot_bone_y(wrap)
	var mesh_y := _measure_lowest_wrap_y(wrap)
	if bone_y != INF and mesh_y != INF:
		return minf(bone_y, mesh_y)
	if prefer_bones and bone_y != INF:
		return bone_y
	if bone_y != INF:
		return bone_y
	return mesh_y


func _measure_lowest_wrap_y(wrap: Node3D) -> float:
	if wrap == null:
		return 0.0
	var skel := _find_skeleton(wrap)
	if skel != null and skel.has_method("force_update_all_bone_transforms"):
		skel.call("force_update_all_bone_transforms")
	wrap.force_update_transform()
	for node in _find_meshes(wrap):
		var mi := node as MeshInstance3D
		if mi != null:
			mi.force_update_transform()
	var aabb := _local_aabb(wrap)
	if aabb.size.y < 0.01:
		return 0.0
	return aabb.position.y


func _foot_snap_sample_times(ap: AnimationPlayer, measure_clip: String) -> Array[float]:
	var out: Array[float] = []
	var anim := ap.get_animation(measure_clip)
	if anim == null or anim.length <= 0.001:
		return out
	var clip_l := measure_clip.to_lower()
	if clip_l.contains("run"):
		for i in 7:
			out.append(float(i) / 6.0 * anim.length)
	elif clip_l.contains("idle"):
		out.append(0.05)
		out.append(anim.length * 0.35)
	else:
		out.append(clampf(anim.length * 0.2, 0.05, 0.16))
	return out


func _snap_fitted_feet_to_ground(
	wrap: Node3D,
	raw: Node3D,
	epsilon: float = 0.04,
	measure_keys: Array = ["run", "idle"],
	prefer_bone_feet: bool = false
) -> void:
	## 扫跑步/待机多帧；四足优先用爪骨最低点贴地
	if wrap == null or raw == null:
		return
	var ap := _find_animation_player(wrap)
	var restore_clip := ""
	var restore_pos := 0.0
	var restore_playing := false
	var lowest_y := INF
	if ap != null:
		restore_clip = ap.current_animation
		restore_pos = ap.current_animation_position
		restore_playing = ap.is_playing()
		var measure_clip := _find_anim_by_keys(ap, measure_keys)
		if not measure_clip.is_empty():
			ap.play(measure_clip)
			var times := _foot_snap_sample_times(ap, measure_clip)
			if times.is_empty():
				lowest_y = _measure_lowest_contact_y(wrap, prefer_bone_feet)
			else:
				for seek_t in times:
					ap.seek(seek_t, true)
					ap.advance(0.0)
					lowest_y = minf(lowest_y, _measure_lowest_contact_y(wrap, prefer_bone_feet))
	if lowest_y == INF:
		lowest_y = _measure_lowest_contact_y(wrap, prefer_bone_feet)
	if lowest_y == INF or lowest_y > 9000.0:
		return
	# 已贴地时测量值≈0，勿重复叠 epsilon（否则会飘起来）
	if absf(lowest_y) < 0.008:
		return
	raw.position.y -= lowest_y
	raw.position.y += epsilon
	if ap != null and not restore_clip.is_empty():
		ap.play(restore_clip)
		ap.seek(restore_pos, true)
		if not restore_playing:
			ap.pause()


func _resnap_then_ready_idle(visual: Node3D) -> void:
	await _resnap_character_feet(visual, ["idle", "run"])
	if visual == null or not is_instance_valid(visual):
		return
	if not _host._waiting_to_start:
		return
	_play_capy_clip(visual, ["idle", "run"], true)


func _resnap_then_ready_dance(visual: Node3D) -> void:
	# 兼容旧调用：终点/展示仍可能需要 dance，先贴地再播
	await _resnap_character_feet(visual, ["idle", "run"])
	if visual == null or not is_instance_valid(visual):
		return
	if not _host._waiting_to_start:
		return
	_play_capy_clip(visual, ["dance", "idle", "run"], true)


func _resnap_character_feet(visual: Node3D, measure_keys: Array = ["run", "idle"]) -> void:
	if visual == null or not is_instance_valid(visual) or visual.get_child_count() == 0:
		return
	var raw := visual.get_child(0) as Node3D
	if raw == null:
		return
	# 必须在场景树里才能量蒙皮 AABB
	if not visual.is_inside_tree():
		return
	var lift := _foot_lift_for_path(_character_model_path())
	if _host._character_id not in [CHAR_CAPYBARA, CHAR_COW, CHAR_QINGQING]:
		lift = CHAR_FOOT_LIFT
	var prefer_bones: bool = _host._character_id in [CHAR_CAPYBARA, CHAR_COW]
	_snap_fitted_feet_to_ground(visual, raw, lift, measure_keys, prefer_bones)
	if _is_soft_skin_character() or _host._character_id in [CHAR_CAPYBARA, CHAR_COW]:
		await _host.get_tree().process_frame
		if visual != null and is_instance_valid(visual) and visual.get_child_count() > 0:
			raw = visual.get_child(0) as Node3D
			if raw != null:
				_snap_fitted_feet_to_ground(visual, raw, lift, measure_keys, prefer_bones)


func _local_aabb(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var inv := root.global_transform.affine_inverse()
	for node in _find_meshes(root):
		var mi := node as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		# VisualInstance AABB（含蒙皮），比 mesh.get_aabb() 更贴真实站姿
		var local := mi.get_aabb()
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
