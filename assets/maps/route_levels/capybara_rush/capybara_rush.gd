extends Node3D

## Capybara Rush 原型：Stack 叠塔 / 竞速冲锋。
## 打开 capybara_rush.tscn 后按 F6 运行。

const CapybaraTrackPathScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_track_path.gd")
const LevelCatalogScript := preload("res://assets/maps/route_levels/capybara_rush/level_catalog.gd")
const CapybaraHazardsScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_hazards.gd")
const CapybaraFinishScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_finish.gd")

const LANE_COUNT := 3
## 车道中心间距：略大于障碍边长，三列几乎贴紧
const LANE_WIDTH := 1.08
const ROAD_HALF_W := 2.05
const TRACK_LATERAL_SPEED := 5.5
const TRACK_LATERAL_MARGIN := 0.68
const ROTATOR_LATERAL_MARGIN := 0.95
const ROTATOR_ARENA_RADIUS := 3.2
const ROTATOR_ANG_SPEED := 1.05
## 与 build_road_mesh 一致：厚度居中时顶面在 +thickness/2
const ROAD_THICKNESS := 0.18
const ROAD_SURFACE_Y := ROAD_THICKNESS * 0.5
## 起跑线与开局站位：角色站在起跑线后方（尚未越线），仍在跑道中央
const START_LINE_PROGRESS := 8.5
const START_PLAYER_PROGRESS := 6.5
const TRACK_LENGTH := 600.0  # fallback；正式关卡用 JSON track_length
const RUN_SPEED := 12.0
const RACE_RUN_SPEED := 13.5
## 选角后进关卡；通关「下一关」会写这里再 reload
static var pending_level_id := 0
static var pending_character_id := ""
const TARGET_DURATION_SEC := 50.0
const BOB_AMP := 0.06
const BOB_FREQ := 9.0
## 可吃加分物原地旋转；胡萝卜等障碍物保持静止以便区分
const FRUIT_SPIN_SPEED := 2.0
const SPEED_ORB_SPIN_SPEED := 2.4
## 深棕站立卡皮巴拉：目标高度与叠层间距（接近身高，只留一点嵌合）
const TARGET_CAPY_HEIGHT := 0.92
const TARGET_PILOT_HEIGHT := 1.55
const STACK_STEP_Y := 0.88
## 网格最长轴在局部 X；-PI/2 使鼻朝跑道前进方向
const CAPY_FORWARD_YAW := -PI * 0.5
const QINGQING_FORWARD_YAW := -PI * 0.5
## 钩织小怪：默认朝向与卡皮接近，可按模型再微调
const MONSTER_FORWARD_YAW := -PI * 0.5
## Quaternius 动物 GLB 已朝跑道 +Z，勿再转 -90°（否则横着跑）
const RABBIT_FORWARD_YAW := 0.0
const SHIBA_FORWARD_YAW := 0.0
## 自动绑骨角色：导出时头骨朝上，身体默认朝 +Z
# 粉鸟 glb 休息朝向是局部 +X；+90° 对准赛道前进（-90° 会倒着跑）
const BIRD_FORWARD_YAW := PI * 0.5
const MOUSE_FORWARD_YAW := 0.0
const SLOTH_FORWARD_YAW := 0.0
const TINY_PLANET_FORWARD_YAW := 0.0
const BEAR_FORWARD_YAW := 0.0
## Tripo 开飞船整模默认朝向与步行水豚不同，需单独校正为朝 +Z
const PILOT_FORWARD_YAW := 0.0
const SPACESHIP_FORWARD_YAW := 0.0
## 贴地余量：在「当前动画脚底」对齐后再微抬，避免闪进地面
const CAPY_FOOT_LIFT := 0.07
const CHAR_FOOT_LIFT := 0.08
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
## 直立/双足类：叠层扭摆减弱，避免拧成麻花
const CHAR_UPRIGHT_IDS: Array[String] = [
	CHAR_QINGQING, CHAR_LITTLE_MONSTER, CHAR_LITTLE_RABBIT, CHAR_SHIBA, CHAR_BIRD,
	CHAR_MOUSE, CHAR_SLOTH, CHAR_TINY_PLANET, CHAR_BEAR,
]
## 自动临近权重蒙皮：大动作会「融化」，少扭骨
const CHAR_SOFT_SKIN_IDS: Array[String] = [
	CHAR_BIRD, CHAR_MOUSE, CHAR_SLOTH, CHAR_TINY_PLANET, CHAR_BEAR,
]
const MODE_STACK := "stack"
const MODE_RACE := "race"
const PICKUP_RADIUS_X := 1.15
const PICKUP_RADIUS_Z := 1.4
## 竞速：碰飞船冲锋 5s；冲锋中撞障 -1s；加速包 +0.5s
const BOOST_DURATION := 5.0
const BOOST_HIT_PENALTY := 1.0
const BOOST_PACK_BONUS := 0.5
const BOOST_SPEED_MUL := 1.32
const BOOST_MAX_TIME := 12.0
## 跳跃 / 台阶 / 加速道具 / 加速赛道
const JUMP_SPEED := 8.2
const TRAMPOLINE_JUMP_SPEED := 17.5
const TRAMPOLINE_AIR_SPEED_MUL := 1.45
const TRAMPOLINE_APPROACH_MARGIN := 24.0
const GRAVITY := 24.0
const JUMP_CLEAR_Y := 0.55
const BLOCK_SIZE := 0.95
const BLOCK_GAP := 0.06
const ROTATOR_PILLAR_CELL := BLOCK_SIZE
const ROTATOR_PILLAR_ROWS := 4
const ROTATOR_PILLAR_COUNT := 4
const ROTATOR_CENTER_FRUIT_COUNT := 4
const HAZARD_CROSS_TYPE_GAP := 16.0
const PACING_BEAT_SEC_MIN := 1.25
const PACING_BEAT_SEC_MAX := 1.62
const PACING_RECOVERY_SEC_MIN := 1.85
const PACING_RECOVERY_SEC_MAX := 2.25
const PENDULUM_TRIPLE_COUNT := 3
const PENDULUM_TRIPLE_SPACING := 4.6
const PENDULUM_TRIPLE_HANG := 3.6
const PENDULUM_TRIPLE_PIVOT_Y := 4.4
## 火焰滑动门：中间留一车道宽缺口，整组左右循环平移
const FIRE_GATE_GAP_WIDTH := LANE_WIDTH * 1.02
const FIRE_GATE_SLIDE_AMP := LANE_WIDTH * 1.05
const FIRE_GATE_WALL_H := 1.08
const FIRE_GATE_HALF_LEN := 0.88
const FIRE_GATE_SLIDE_SPEED := 1.65
const SPEED_ORB_MUL := 1.18
const SPEED_ORB_DURATION := 2.5
const SPEED_LANE_MUL := 1.48
const SPEED_LANE_FRUIT_SPACING := 2.5
const PLATFORM_TOP_Y := 1.15
const PLATFORM_HALF_LEN := 2.2
## 静止水豚：朝向跑道；玩家靠近时扭头回看（身子不动）
const PICKUP_LOOK_RANGE := 22.0
## 过肩回头：约 140°，从身后相机能看到半张脸
const PICKUP_LOOK_MAX := 2.45
## 近距离至少转到约 125°（半脸）
const PICKUP_LOOK_HALF_FACE := 2.2
const PICKUP_LOOK_LERP := 10.0
const PICKUP_LOOK_BEHIND_BIAS := 0.35
## 晃动 / 掉层
## - ≥3 层：只要在移动（换道/滑动中）就有掉落概率
## - >8 层：概率大幅抬升
## - 撞障碍：障碍几层就掉几只重叠的卡皮巴拉；障碍物留在原地
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
var _hazard_sys: CapybaraHazards
var _trampolines: Array[Dictionary] = []
var _cliffs: Array[Dictionary] = []
var _falling: Array[Dictionary] = []
const CLIFF_GAP_LEN := 11.0
const CLIFF_VOID_Y := -10.0
## 未踩跳跳床坠入断崖：倾倒掉底四只后落到对岸继续（受罚过崖，不白嫖、不死循环）
const CLIFF_BOTTOM_DROP := 4
const CLIFF_TIP_TRIGGER_Y := -1.2
const CLIFF_TIP_ANGLE := 1.05  # ~60°
var _cliff_rescuing := false
var _cliff_tip_pitch := 0.0
## 本跳是否来自跳跳床；只有它才能穿过断崖
var _cliff_from_trampoline := false
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
## 开场：原地转圈，按空格出发
var _waiting_to_start := false
var _ready_spin_yaw := 0.0
const READY_SPIN_SPEED := 2.2
## 兼容旧青青开场标记（现并入 waiting）
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
var _air_y := ROAD_SURFACE_Y
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
## 终点台阶吃瓜
var _finish_sys: CapybaraFinish
var _watermelon_count := 0
## 登上台阶后、齐舞前的角色（含 step_yaw）
## 音频
var _bgm_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _stream_bgm: AudioStream
var _stream_fruit: AudioStream
var _stream_hit: AudioStream
var _stream_pickup: AudioStream
## 路上水果金币
var _fruits: Array[Dictionary] = []
var _rotator_arenas: Array[Dictionary] = []
var _coin_score := 0
var _fruit_orange := 0
var _fruit_apple := 0
var _fruit_banana := 0
var _fruit_pineapple := 0
var _fruit_durian := 0
var _fruit_icecream := 0
var _fruit_crystal := 0
var _level_id := 1
var _level_cfg: Dictionary = {}
var _theme_cfg: Dictionary = {}
var _level_ui: CanvasLayer
var _world_env: WorldEnvironment
var _sun_light: DirectionalLight3D
var _road_mesh: MeshInstance3D
var _water_meshes: Array[MeshInstance3D] = []
## 视差冰块贴图缓存（parallax ice）
var _ice_tex_over: Texture2D
var _ice_tex_under: Texture2D
var _ice_tex_normal: Texture2D
## 起跳掉顶层概率（叠≥2）；从 0.14 大幅下调，避免跳一下就散架
const JUMP_DROP_CHANCE := 0.02
## 暂时关闭：移动/跳跃的概率掉层（撞障碍、断崖等强制掉落仍保留）
const ENABLE_MOVE_DROP := false
const ENABLE_JUMP_DROP := false

func _ready() -> void:
	_world = Node3D.new()
	_world.name = "World"
	add_child(_world)
	_hazard_sys = CapybaraHazardsScript.new(self)
	_finish_sys = CapybaraFinishScript.new(self)
	_setup_environment()
	_setup_camera()
	_setup_hud()
	_setup_audio()
	if pending_level_id > 0:
		_character_id = pending_character_id if not pending_character_id.is_empty() else CHAR_CAPYBARA
		_level_id = pending_level_id
		pending_level_id = 0
		pending_character_id = ""
		_load_level_bundle(_level_id)
		_rebuild_level_world()
		_start_stack_game()
	else:
		_load_level_bundle(1)
		_rebuild_level_world()
		_setup_character_select()
	_lane_x = _lane_to_x(_lane)


func _unhandled_input(event: InputEvent) -> void:
	# Esc：游戏中 / 开场 / 结算 / 模式选择 均可回角色选择
	if _select_ui == null and (
		event.is_action_pressed("ui_cancel") or _key_pressed(event, KEY_ESCAPE)
	):
		get_tree().reload_current_scene()
		return
	if _mode_ui != null or _select_ui != null or _level_ui != null:
		return
	# 出发前：原地转圈，空格开始跑酷
	if _waiting_to_start:
		if (
			event.is_action_pressed("ui_accept")
			or _key_pressed(event, KEY_SPACE)
			or _key_pressed(event, KEY_ENTER)
		):
			_begin_gameplay()
		return
	if not _playing:
		return
	if _finished:
		if _result_ui != null and (
			event.is_action_pressed("ui_accept") or _key_pressed(event, KEY_R)
		):
			_reload_same_level()
		return
	elif (
		event.is_action_pressed("ui_accept")
		or event.is_action_pressed("ui_up")
		or _key_pressed(event, KEY_SPACE)
		or _key_pressed(event, KEY_W)
		or _key_pressed(event, KEY_UP)
	):
		_try_jump()


func _key_pressed(event: InputEvent, code: Key) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == code


func _process(delta: float) -> void:
	_update_falling(delta)
	_update_clouds(delta)
	if _select_ui != null:
		_spin_select_previews(delta)
		return
	if _mode_ui != null or _level_ui != null:
		return
	if _waiting_to_start or _intro_showcasing:
		_update_ready_spin(delta)
		_hazard_sys.update(delta)
		return
	if not _playing:
		return
	if _finished:
		if _finish_sys.ceremony_active:
			_finish_sys.update_camera(delta)
		_update_falling(delta)
		return
	if _game_mode == MODE_RACE:
		_update_boost(delta)
	_update_speed_buff(delta)
	_update_jump(delta)
	_try_trampoline_bounce()
	_update_trampoline_cd(delta)
	_refresh_speed_lane_state()
	_hazard_sys.update(delta)
	var speed := _current_run_speed()
	var track_len := _track_len()
	if not _cliff_rescuing:
		var next_prog := minf(_progress + speed * delta, track_len)
		# 没踩跳跳床：可以掉进断崖，但不能靠普通跳「飞」到对岸
		if not _cliff_from_trampoline:
			var cap := _cliff_forward_cap()
			if cap >= 0.0:
				next_prog = minf(next_prog, cap)
		_progress = next_prog
	_update_lateral_move(delta)
	_update_sway(delta)
	_update_tower_motion()
	_try_collect_speed_orbs()
	_update_speed_orb_spin(delta)
	if _game_mode == MODE_STACK:
		if not _cliff_rescuing:
			_update_pickup_bob(delta)
			_try_collect_pickups()
			_update_fruit_bob(delta)
			_try_collect_fruits()
			_try_hit_hazards()
			_try_drop_layers(delta)
	else:
		_update_boost_pack_bob()
		_try_collect_spaceships()
		_try_collect_boost_packs()
		_try_hit_hazards_race()
	_update_camera()
	_update_hud()
	if not _cliff_rescuing and _progress >= track_len - 0.5:
		_finished = true
		_finish_sys.start_ceremony()


func _track_len() -> float:
	if not _level_cfg.is_empty():
		return float(_level_cfg.get("track_length", TRACK_LENGTH))
	if _path != null and _path.length > 1.0:
		return _path.length
	return TRACK_LENGTH


func _try_jump(boost_speed: float = -1.0) -> void:
	if not _grounded or _finished:
		return
	_grounded = false
	_on_platform = false
	# 普通跳不能过断崖；只有跳跳床传入的 boost 才算
	if boost_speed > 0.0:
		_cliff_from_trampoline = true
		_vel_y = boost_speed
	else:
		_cliff_from_trampoline = false
		_vel_y = JUMP_SPEED
	# 跳跃有小概率掉顶层（叠高≥2）；弹床大跳同样适用
	if ENABLE_JUMP_DROP and _game_mode == MODE_STACK and _stack.size() >= 2 and randf() < JUMP_DROP_CHANCE:
		_drop_top_layer(true)
		_drop_cd = maxf(_drop_cd, 0.35)
		_sway = minf(_sway + 0.45, 2.2)
	# 只有最底层跳，上面叠着的保持静止
	if not _stack.is_empty() and _stack[0] != null and is_instance_valid(_stack[0]):
		_play_capy_clip(_stack[0], ["jump"], true)


func _update_jump(delta: float) -> void:
	if _cliff_rescuing:
		return
	var platform_y := _platform_top_under_player()
	var floor_y := platform_y if platform_y >= 0.0 else ROAD_SURFACE_Y
	# 断崖缺口内永远没有地面：跳跳床飞过；否则坠落倾倒受罚到对岸
	if _in_cliff_gap():
		floor_y = CLIFF_VOID_Y
	if _grounded:
		_ground_y = floor_y
		_air_y = floor_y
		_vel_y = 0.0
		# 安全落地后清弹床标记
		if not _in_cliff_gap():
			_cliff_from_trampoline = false
		if floor_y < -1.0:
			# 走到断崖边缘未跳 → 坠落
			_grounded = false
			_on_platform = false
			_vel_y = -2.0
			return
		if _on_platform and platform_y < 0.0:
			_grounded = false
			_on_platform = false
			_vel_y = -0.5
		return
	_vel_y -= GRAVITY * delta
	_air_y += _vel_y * delta
	# 叠塔：未用跳跳床坠入断崖 → 倾倒掉底四层，落到对岸继续
	if (
		_game_mode == MODE_STACK
		and not _cliff_from_trampoline
		and _air_y < CLIFF_TIP_TRIGGER_Y
		and (_in_cliff_gap() or floor_y < -1.0)
	):
		_begin_cliff_tip_rescue()
		return
	# 弹床仍摔进深渊 / 竞速深坠
	if _air_y < -4.0:
		if _game_mode == MODE_STACK:
			_begin_cliff_tip_rescue()
		else:
			_fail_game("掉下断崖，游戏失败")
		return
	if _vel_y <= 0.0 and _air_y <= floor_y + 0.02 and floor_y > -1.0:
		_air_y = floor_y
		_vel_y = 0.0
		_grounded = true
		_ground_y = floor_y
		_on_platform = platform_y >= 0.0
		if not _in_cliff_gap():
			_cliff_from_trampoline = false


func _cliff_forward_cap() -> float:
	## 无弹床时，前进不能越过当前断崖终点（普通跳飞不过去，只能坠落受罚）
	for c in _cliffs:
		var d0 := float(c.get("dist0", -1.0))
		var d1 := float(c.get("dist1", -1.0))
		if bool(c.get("penalized", false)):
			continue
		if _progress > d0 - 0.05 and _progress < d1:
			return d1 - 0.08
	return -1.0


func _cliff_cross_dist() -> float:
	## 倾倒受罚后落到对岸，继续往前（不再退回崖前死循环）
	for c in _cliffs:
		var d0 := float(c.get("dist0", -1.0))
		var d1 := float(c.get("dist1", -1.0))
		if _progress >= d0 - 2.0 and _progress <= d1 + 5.0:
			c["penalized"] = true
			return minf(d1 + 2.2, _track_len() - 1.0)
	return minf(_progress + float(_level_cfg.get("cliff_gap_len", CLIFF_GAP_LEN)) + 2.0, _track_len() - 1.0)


func _begin_cliff_tip_rescue() -> void:
	if _cliff_rescuing or _finished:
		return
	if _stack.is_empty():
		_fail_game("掉下断崖，游戏失败")
		return
	_cliff_rescuing = true
	_cliff_from_trampoline = false
	_grounded = false
	_vel_y = 0.0
	_air_y = maxf(_air_y, -1.0)
	_play_sfx_hit()
	_sway = minf(_sway + 1.4, 2.6)
	var land_dist := _cliff_cross_dist()
	var tw := create_tween()
	tw.tween_property(self, "_cliff_tip_pitch", CLIFF_TIP_ANGLE, 0.38) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(_cliff_drop_bottom_and_land.bind(land_dist))
	tw.tween_property(self, "_cliff_tip_pitch", 0.0, 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_finish_cliff_tip_rescue)


func _cliff_drop_bottom_and_land(land_dist: float) -> void:
	## 最底下最多掉 4 只；至少留 1 只，落到对岸继续
	var drop_n := mini(CLIFF_BOTTOM_DROP, maxi(_stack.size() - 1, 0))
	for _i in drop_n:
		if _stack.is_empty():
			break
		_drop_layer_into_cliff(0)
	if _stack.is_empty():
		_cliff_rescuing = false
		_cliff_tip_pitch = 0.0
		_fail_game("掉下断崖，游戏失败")
		return
	_progress = land_dist
	_air_y = ROAD_SURFACE_Y + 0.4
	_vel_y = 0.0
	_repack_stack_heights()
	_refresh_stack_layer_anims()


func _finish_cliff_tip_rescue() -> void:
	_cliff_rescuing = false
	_cliff_tip_pitch = 0.0
	_cliff_from_trampoline = false
	_grounded = true
	_air_y = ROAD_SURFACE_Y
	_vel_y = 0.0
	_on_platform = false
	_refresh_stack_layer_anims()
	if _hud_tip != null and _playing and not _finished:
		_hud_tip.text = "没踩跳跳床摔过去了 · 底下掉了几只 · 下次换有床的道飞"


func _refresh_stack_layer_anims() -> void:
	for i in _stack.size():
		var layer: Node3D = _stack[i]
		if layer == null or not is_instance_valid(layer):
			continue
		if i == 0:
			_play_capy_clip(layer, ["run"], true)
		else:
			_park_stack_rider(layer)


func _drop_layer_into_cliff(idx: int) -> void:
	## 断崖倾倒：底层甩进深渊
	if _stack.is_empty():
		return
	idx = clampi(idx, 0, _stack.size() - 1)
	var layer: Node3D = _stack[idx]
	_stack.remove_at(idx)
	if layer == null or not is_instance_valid(layer):
		_repack_stack_heights()
		return
	_drop_count += 1
	var gpos := layer.global_position
	var grot := layer.global_rotation
	_tower.remove_child(layer)
	_world.add_child(layer)
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
	_falling.append({
		"node": layer,
		"vel": vel,
		"spin": spin,
		"life": 0.0,
		"can_hop": false,
		"hops_left": 0,
		"into_void": true,
	})
	_repack_stack_heights()


func _in_cliff_gap() -> bool:
	for c in _cliffs:
		var d0 := float(c.get("dist0", -1.0))
		var d1 := float(c.get("dist1", -1.0))
		if _progress > d0 and _progress < d1:
			return true
	return false


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


func _speed_lane_mul() -> float:
	return float(_level_cfg.get("speed_lane_mul", SPEED_LANE_MUL))


func _refresh_speed_lane_state() -> void:
	_on_speed_lane = false
	if not _grounded:
		return
	for lane in _speed_lanes:
		var d0: float = float(lane.get("dist0", 0.0))
		var d1: float = float(lane.get("dist1", 0.0))
		var lateral: float = float(lane.get("lateral", 0.0))
		if _progress < d0 - 0.35 or _progress > d1 + 0.35:
			continue
		if absf(lateral - _lane_x) > LANE_WIDTH * 0.52:
			continue
		_on_speed_lane = true
		return


func _is_on_speed_lane_corridor(dist: float, lateral: float) -> bool:
	for lane in _speed_lanes:
		if dist < float(lane.get("dist0", 0.0)) - 0.6 or dist > float(lane.get("dist1", 0.0)) + 0.6:
			continue
		if absf(float(lane.get("lateral", 0.0)) - lateral) <= LANE_WIDTH * 0.52:
			return true
	return false


func _current_run_speed() -> float:
	var base := RACE_RUN_SPEED if _is_race() else float(_level_cfg.get("run_speed", RUN_SPEED))
	var mul := 1.0
	if _is_race() and _boosting:
		mul *= BOOST_SPEED_MUL
	if _speed_buff_left > 0.0:
		mul *= SPEED_ORB_MUL
	if _on_speed_lane:
		mul *= _speed_lane_mul()
	# 弹床越崖：空中额外前进，避免刚够/不够落在缺口里
	if _cliff_from_trampoline and not _grounded:
		mul *= TRAMPOLINE_AIR_SPEED_MUL
	return base * mul


func _is_race() -> bool:
	return _game_mode == MODE_RACE


func _is_airborne_clear(clear_y: float = JUMP_CLEAR_Y) -> bool:
	## clear_y 按「障碍顶绝对高度」理解：脚底 _air_y 超过才算跳过
	return (not _grounded) and _air_y >= clear_y - 0.02


func _try_trampoline_bounce() -> void:
	if not _grounded or _finished or not _playing:
		return
	for t in _trampolines:
		if bool(t.get("used_cd", false)):
			# 冷却用 life 字段倒计时在 process 外处理
			continue
		if not _along_overlap(float(t.get("dist", -999.0)), float(t.get("lateral", 0.0)), 1.6, 1.15):
			continue
		t["used_cd"] = true
		t["cd"] = 0.85
		_try_jump(TRAMPOLINE_JUMP_SPEED)
		# 弹床压扁回弹
		var node: Node3D = t.get("node")
		if node != null and is_instance_valid(node):
			var pad: Node3D = node.find_child("Pad", true, false) as Node3D
			if pad != null:
				var tw := create_tween()
				tw.tween_property(pad, "scale", Vector3(1.15, 0.45, 1.15), 0.08)
				tw.tween_property(pad, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK)
		break


func _update_trampoline_cd(delta: float) -> void:
	for t in _trampolines:
		if not bool(t.get("used_cd", false)):
			continue
		t["cd"] = float(t.get("cd", 0.0)) - delta
		if float(t["cd"]) <= 0.0:
			t["used_cd"] = false
			t["cd"] = 0.0


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
	if not ENABLE_MOVE_DROP:
		return
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


func _force_drop_from_hazard(h: Dictionary = {}) -> void:
	# 撞障碍：重叠几层掉几只；会清空整塔或只剩 0 → 失败
	# 注意：拾取动画中不要直接 return 吞掉伤害——由 _try_hit_hazards 排队，结束后再结算
	if _stack.size() <= 1:
		_fail_game("撞到障碍，游戏失败")
		return
	var idxs := _hit_stack_layer_indices(h)
	if idxs.is_empty():
		idxs = [0]
	if idxs.size() >= _stack.size():
		_fail_game("撞到障碍，游戏失败")
		return
	# 从高下标到低剔除，避免 remove 后下标错位
	idxs.sort()
	idxs.reverse()
	for idx in idxs:
		_drop_layer_at(int(idx), true)
	_drop_cd = _drop_cooldown()
	_sway = minf(_sway + 1.2 + float(idxs.size()) * 0.15, 3.0)


func _hit_stack_layer_indices(h: Dictionary) -> Array[int]:
	## 障碍有几层、叠塔有几层脚底仍卡在障碍高度内，就掉几只
	var result: Array[int] = []
	if _stack.is_empty():
		return result
	var hit_top := CapybaraHazards.hit_top(h)
	var max_drop := int(h.get("rows", 0))
	if max_drop <= 0:
		max_drop = maxi(1, int(round(hit_top / (BLOCK_SIZE + BLOCK_GAP))))
	for i in _stack.size():
		if result.size() >= max_drop:
			break
		var y0 := _air_y + float(i) * STACK_STEP_Y
		# 该层脚底已高于障碍顶 → 之上都安全
		if y0 >= hit_top - 0.05:
			break
		result.append(i)
	return result


func _fail_game(reason: String) -> void:
	if _finished:
		return
	_finished = true
	_finish_sys.ceremony_active = false
	_stop_bgm()
	# 撞飞最后一只
	if not _stack.is_empty():
		_drop_top_layer(true)
	_show_fail_screen(reason)


func _show_fail_screen(reason: String) -> void:
	if _result_ui != null:
		return
	if _hud_label:
		_hud_label.visible = false
	if _hud_tip:
		_hud_tip.visible = false

	_result_ui = CanvasLayer.new()
	_result_ui.layer = 30
	add_child(_result_ui)

	var dim := ColorRect.new()
	dim.color = Color(0.35, 0.28, 0.40, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_ui.add_child(dim)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_ui.add_child(root)

	var card := PanelContainer.new()
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -240
	card.offset_right = 240
	card.offset_top = -200
	card.offset_bottom = 200
	card.add_theme_stylebox_override("panel", _cartoon_panel_style(
		Color(1.0, 0.96, 0.97),
		Color(0.95, 0.55, 0.65),
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
	v.add_theme_constant_override("separation", 14)
	margin.add_child(v)

	var badge := Label.new()
	badge.text = "失败"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 20)
	badge.add_theme_color_override("font_color", Color(0.95, 0.40, 0.55))
	v.add_child(badge)

	var title := Label.new()
	title.text = reason
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	v.add_child(title)

	v.add_child(_result_stat_chip("进度", "%d%%" % int((_progress / maxf(_track_len(), 1.0)) * 100.0), Color(1.0, 0.93, 0.88)))
	v.add_child(_result_stat_chip("碰撞", "%d 次" % _collision_count, Color(1.0, 0.93, 0.88)))

	var tip := Label.new()
	tip.text = "只剩一只时撞障会失败 · R / Enter 重开"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 16)
	tip.add_theme_color_override("font_color", Color(0.62, 0.55, 0.66))
	v.add_child(tip)

	var btn := Button.new()
	btn.text = "再试一次"
	btn.custom_minimum_size = Vector2(0, 58)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_stylebox_override("normal", _cartoon_panel_style(Color(1.0, 0.55, 0.68), Color(1.0, 0.78, 0.86), 22.0, 0.0))
	btn.add_theme_stylebox_override("hover", _cartoon_panel_style(Color(1.0, 0.62, 0.74), Color(1.0, 0.84, 0.90), 22.0, 0.0))
	btn.add_theme_stylebox_override("pressed", _cartoon_panel_style(Color(0.92, 0.48, 0.62), Color(1.0, 0.72, 0.82), 22.0, 0.0))
	btn.pressed.connect(func() -> void: _reload_same_level())
	v.add_child(btn)

	card.scale = Vector2(0.82, 0.82)
	card.pivot_offset = Vector2(240, 200)
	var tw := create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(card, "scale", Vector2.ONE, 0.4)


func _drop_top_layer(allow_hop: bool = false) -> void:
	if _stack.is_empty():
		return
	_drop_layer_at(_stack.size() - 1, allow_hop)


func _drop_layer_at(idx: int, allow_hop: bool = false) -> void:
	if _stack.is_empty():
		return
	idx = clampi(idx, 0, _stack.size() - 1)
	var layer: Node3D = _stack[idx]
	_stack.remove_at(idx)
	if layer == null or not is_instance_valid(layer):
		_repack_stack_heights()
		return
	_drop_count += 1
	var gpos := layer.global_position
	var grot := layer.global_rotation
	_tower.remove_child(layer)
	_world.add_child(layer)
	layer.global_position = gpos
	layer.global_rotation = grot
	_play_capy_clip(layer, ["jump", "run"], false)
	# 向外侧甩出；被撞掉的可再跳几下
	var side := signf(_tower.rotation.z)
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
	_falling.append({
		"node": layer,
		"vel": vel,
		"spin": spin,
		"life": 0.0,
		"can_hop": allow_hop,
		"hops_left": 2 if allow_hop else 0,
	})
	_repack_stack_heights()


func _repack_stack_heights() -> void:
	for i in _stack.size():
		var layer: Node3D = _stack[i]
		if layer == null or not is_instance_valid(layer):
			continue
		layer.position.x = 0.0
		layer.position.z = 0.0
		layer.position.y = float(i) * STACK_STEP_Y


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
	_falling = remain


func _update_pickup_bob(delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001
	for p in _pickups:
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node):
			continue
		var phase: float = float(p.get("phase", 0.0))
		var dist: float = float(p.get("dist", 0.0))
		var lateral: float = float(p.get("lateral", 0.0))
		var bob_y := ROAD_SURFACE_Y + absf(sin(t * 3.0 + phase)) * 0.06
		_path_place(node, dist, lateral, bob_y, 0.0)

		var target_yaw := 0.0
		if _tower != null and absf(dist - _progress) <= PICKUP_LOOK_RANGE:
			var to_player := _tower.global_position - node.global_position
			to_player.y = 0.0
			if to_player.length_squared() > 0.04:
				var face_yaw := atan2(to_player.x, to_player.z)
				var base_yaw := float(node.rotation.y) + _character_yaw()
				target_yaw = wrapf(face_yaw - base_yaw, -PI, PI)
				var near_k := 1.0 - clampf(absf(dist - _progress) / PICKUP_LOOK_RANGE, 0.0, 1.0)
				# 在玩家前方（回看相机）时加重，保证半张脸
				var ahead := dist > _progress
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
						side = 1.0 if (lateral - _lane_x) >= 0.0 else -1.0
					if absf(desired) < min_turn:
						desired = side * min_turn
				target_yaw = clampf(desired, -PICKUP_LOOK_MAX, PICKUP_LOOK_MAX)
		var cur: float = float(p.get("look_yaw", 0.0))
		cur = lerpf(cur, target_yaw, 1.0 - exp(-PICKUP_LOOK_LERP * delta))
		p["look_yaw"] = cur
		# 扭头幅度大时暂停身体动画，避免头部通道盖掉回头
		var ap: AnimationPlayer = p.get("anim")
		if ap != null and is_instance_valid(ap):
			var pause_at := 0.22 if _character_id != CHAR_CAPYBARA and _character_id != CHAR_QINGQING else 0.35
			if absf(cur) > pause_at:
				if ap.is_playing():
					ap.stop()
				ap.active = false
			else:
				var vis: Node = p.get("visual")
				if vis == null:
					vis = node
				_play_capy_clip(vis, ["dance", "run"], true)
		# 延后一帧应用，压过 AnimationPlayer
		_apply_pickup_head_yaw(p, cur)
	# 再 deferred 盖一次，确保渲染前是回头姿势
	call_deferred("_apply_all_pickup_looks")


func _apply_all_pickup_looks() -> void:
	for p in _pickups:
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
	## 绕世界竖直轴扭骨（相对 rest），兼容四足颈骨与直立头骨
	var rest: Transform3D = skel.get_bone_rest(bone_idx)
	var parent_idx := skel.get_bone_parent(bone_idx)
	var parent_global: Transform3D = skel.global_transform
	if parent_idx >= 0:
		parent_global = skel.global_transform * skel.get_bone_global_pose(parent_idx)
	var rest_global := parent_global * rest
	var new_global := Transform3D(Basis(Quaternion(Vector3.UP, yaw)) * rest_global.basis, rest_global.origin)
	var new_local := parent_global.affine_inverse() * new_global
	skel.set_bone_pose_rotation(bone_idx, new_local.basis.get_rotation_quaternion())
	skel.set_bone_pose_position(bone_idx, new_local.origin)


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
	ap.play(clip)
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
	# 软蒙皮：少拧颈头骨，主要靠身子微转，避免融化
	if _is_soft_skin_character():
		into["look_bones"] = []
		into["body_look"] = 0.25
	else:
		into["look_bones"] = look_bones
		var body_look := 0.0
		if _character_id != CHAR_CAPYBARA and _character_id != CHAR_QINGQING:
			body_look = 0.55 if _is_upright_character() else 0.35
		into["body_look"] = body_look
	into["anim"] = ap
	into["visual"] = visual
	into["anim_name"] = _find_anim_by_keys(ap, ["dance"])
	into["look_yaw"] = 0.0
	into["look_played"] = false
	if skel != null and (bone >= 0 or not look_bones.is_empty()):
		if bone >= 0:
			into["head_rest_q"] = skel.get_bone_rest(bone).basis.get_rotation_quaternion()
		else:
			into["head_rest_q"] = Quaternion.IDENTITY
		_ensure_mesh_skeleton(visual, skel)
	else:
		into["head_rest_q"] = Quaternion.IDENTITY
		push_warning("Capybara head bone missing; no look-back")
	# 路上闲置：手舞足蹈；靠近时仍用代码竖直轴扭头
	_play_capy_clip(visual, ["dance", "idle", "run"], true)
	if ap != null:
		if ap.is_playing():
			ap.seek(randf() * maxf(ap.current_animation_length, 0.1))
		# 物理帧播动画，_process 里扭头可盖住头部轨道
		ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	# dance 脚底往往低于 rest，再贴一次地
	_resnap_character_feet(visual)

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

func _lane_to_x(lane: int) -> float:
	var mid := (LANE_COUNT - 1) * 0.5
	return (float(lane) - mid) * LANE_WIDTH


func _lane_from_x(x: float) -> int:
	var best := 1
	var best_d := 999999.0
	for l in LANE_COUNT:
		var d := absf(_lane_to_x(l) - x)
		if d < best_d:
			best_d = d
			best = l
	return best


func _on_rotator_arena() -> bool:
	for a in _rotator_arenas:
		var half := float(a.get("half_len", ROTATOR_ARENA_RADIUS))
		if absf(_progress - float(a.get("dist", -9999.0))) <= half:
			return true
	return false


func _lateral_limit() -> float:
	if _on_rotator_arena():
		return ROTATOR_ARENA_RADIUS - ROTATOR_LATERAL_MARGIN
	return ROAD_HALF_W - TRACK_LATERAL_MARGIN


func _lateral_input() -> float:
	var dir := 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir += 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir -= 1.0
	return dir


func _update_lateral_move(delta: float) -> void:
	_prev_lane_x = _lane_x
	var max_x := _lateral_limit()
	var dir := _lateral_input()
	if dir != 0.0:
		_lane_x += dir * TRACK_LATERAL_SPEED * delta
		_lane_x = clampf(_lane_x, -max_x, max_x)
		_lane_change_times.append(Time.get_ticks_msec() * 0.001)
	_lane = _lane_from_x(_lane_x)


func _character_display_name() -> String:
	match _character_id:
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
		_:
			return "卡皮巴拉"


func _pick_rigged_or_base(rigged: String, base: String) -> String:
	if ResourceLoader.exists(rigged) or FileAccess.file_exists(rigged):
		return rigged
	if ResourceLoader.exists(base) or FileAccess.file_exists(base):
		return base
	return ""


func _character_model_path() -> String:
	match _character_id:
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
	# 卡皮：仅当已导入可加载时才用绑定版
	if ResourceLoader.exists(CapybaraRushPaths.CAPYBARA_BASE_RIGGED):
		return CapybaraRushPaths.CAPYBARA_BASE_RIGGED
	return CapybaraRushPaths.CAPYBARA_BASE


func _character_yaw() -> float:
	match _character_id:
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
		_:
			return CAPY_FORWARD_YAW


func _is_upright_character(char_id: String = "") -> bool:
	var id := char_id if not char_id.is_empty() else _character_id
	return id in CHAR_UPRIGHT_IDS


func _is_soft_skin_character(char_id: String = "") -> bool:
	var id := char_id if not char_id.is_empty() else _character_id
	return id in CHAR_SOFT_SKIN_IDS


func _path_is_soft_skin(path: String) -> bool:
	var p := path.to_lower()
	for id in CHAR_SOFT_SKIN_IDS:
		if p.contains(String(id)):
			return true
	return false


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
	tip.offset_top = 100
	tip.offset_left = -260
	tip.offset_right = 260
	tip.offset_bottom = 128
	tip.add_theme_font_size_override("font_size", 18)
	tip.add_theme_color_override("font_color", Color(0.55, 0.42, 0.58))
	_select_ui.add_child(tip)

	# 全屏边距 + 可滚动 3 列网格
	var page := MarginContainer.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.add_theme_constant_override("margin_left", 28)
	page.add_theme_constant_override("margin_right", 28)
	page.add_theme_constant_override("margin_top", 140)
	page.add_theme_constant_override("margin_bottom", 24)
	_select_ui.add_child(page)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 14)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	var cards: Array = [
		["卡皮巴拉", CHAR_CAPYBARA, CapybaraRushPaths.CAPYBARA_BASE, Color(1.0, 0.93, 0.88)],
	]
	var qing_preview := _pick_rigged_or_base(CapybaraRushPaths.QINGQING_RIGGED, CapybaraRushPaths.QINGQING)
	if not qing_preview.is_empty():
		cards.append(["青青", CHAR_QINGQING, qing_preview, Color(0.92, 0.96, 0.90)])
	var extras: Array = [
		["小怪兽", CHAR_LITTLE_MONSTER, CapybaraRushPaths.LITTLE_MONSTER_RIGGED, CapybaraRushPaths.LITTLE_MONSTER, Color(0.88, 0.98, 0.98)],
		["小兔子", CHAR_LITTLE_RABBIT, CapybaraRushPaths.LITTLE_RABBIT_RIGGED, CapybaraRushPaths.LITTLE_RABBIT, Color(1.0, 0.94, 0.96)],
		["柴犬", CHAR_SHIBA, CapybaraRushPaths.SHIBA_RIGGED, CapybaraRushPaths.SHIBA, Color(0.98, 0.92, 0.84)],
		["小鸟", CHAR_BIRD, CapybaraRushPaths.BIRD_RIGGED, CapybaraRushPaths.BIRD, Color(0.90, 0.96, 1.0)],
		["小老鼠", CHAR_MOUSE, CapybaraRushPaths.MOUSE_RIGGED, CapybaraRushPaths.MOUSE, Color(0.94, 0.94, 0.90)],
		["树懒", CHAR_SLOTH, CapybaraRushPaths.SLOTH_RIGGED, CapybaraRushPaths.SLOTH, Color(0.93, 0.90, 0.84)],
		["小行星", CHAR_TINY_PLANET, CapybaraRushPaths.TINY_PLANET_RIGGED, CapybaraRushPaths.TINY_PLANET, Color(0.90, 0.94, 0.98)],
		["小熊", CHAR_BEAR, CapybaraRushPaths.BEAR_RIGGED, CapybaraRushPaths.BEAR, Color(0.96, 0.90, 0.84)],
	]
	for e in extras:
		var preview := _pick_rigged_or_base(String(e[2]), String(e[3]))
		if preview.is_empty():
			continue
		cards.append([e[0], e[1], preview, e[4]])

	for c in cards:
		var card := _make_character_card(String(c[0]), String(c[1]), String(c[2]), c[3] as Color)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(180, 240)
		grid.add_child(card)

	if _hud_label:
		_hud_label.visible = false
	if _hud_tip:
		_hud_tip.visible = false


func _make_character_card(label_text: String, char_id: String, model_path: String, tint: Color) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 280)
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(
		Color(1.0, 0.98, 0.99),
		Color(1.0, 0.72, 0.82),
		24.0,
		3.0
	))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	margin.add_child(v)

	var preview_frame := PanelContainer.new()
	preview_frame.custom_minimum_size = Vector2(0, 160)
	preview_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_frame.add_theme_stylebox_override("panel", _cartoon_panel_style(
		tint,
		Color(1, 1, 1, 0.8),
		18.0,
		2.0
	))
	v.add_child(preview_frame)

	var preview := _make_model_preview(model_path)
	preview_frame.add_child(preview)

	var name_l := Label.new()
	name_l.text = label_text
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 24)
	name_l.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	v.add_child(name_l)

	var btn := Button.new()
	btn.text = "选择 " + label_text
	btn.custom_minimum_size = Vector2(0, 44)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.98))
	btn.add_theme_stylebox_override("normal", _cartoon_panel_style(Color(1.0, 0.55, 0.68), Color(1.0, 0.78, 0.86), 18.0, 0.0))
	btn.add_theme_stylebox_override("hover", _cartoon_panel_style(Color(1.0, 0.62, 0.74), Color(1.0, 0.84, 0.90), 18.0, 0.0))
	btn.add_theme_stylebox_override("pressed", _cartoon_panel_style(Color(0.92, 0.48, 0.62), Color(1.0, 0.72, 0.82), 18.0, 0.0))
	btn.pressed.connect(_on_character_chosen.bind(char_id))
	v.add_child(btn)
	return panel


func _make_model_preview(model_path: String) -> Control:
	# TextureRect 铺满预览区，避免 SubViewportContainer 只画在左上角
	var host := Control.new()
	host.custom_minimum_size = Vector2(180, 150)
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.clip_contents = true

	var sv := SubViewport.new()
	sv.size = Vector2i(384, 384)
	sv.transparent_bg = true
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sv.own_world_3d = true
	host.add_child(sv)

	var tex := TextureRect.new()
	tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
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
	# 选角预览：略矮一点、不加脚底抬升动画干扰取景
	var model := _instance_fitted(model_path, 0.85, 0.0)
	if model:
		_mute_animation_players(model)
		var skel := _find_skeleton(model)
		if skel != null:
			skel.reset_bone_poses()
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
	cam.fov = 28.0
	root.add_child(cam)
	cam.current = true
	cam.position = Vector3(0.0, 0.4, 2.4)
	cam.look_at(Vector3(0.0, 0.3, 0.0), Vector3.UP)

	_select_spin_pivots.append(pivot)
	# 进树后再取 AABB；多帧一次，避免蒙皮尚未刷新
	call_deferred("_frame_select_preview", cam, holder, pivot)
	call_deferred("_deferred_reframe_select_preview", cam, holder, pivot)
	return host


func _deferred_reframe_select_preview(cam: Camera3D, holder: Node3D, pivot: Node3D) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_frame_select_preview(cam, holder, pivot)


func _frame_select_preview(cam: Camera3D, holder: Node3D, pivot: Node3D) -> void:
	if cam == null or not is_instance_valid(cam):
		return
	if holder == null or not is_instance_valid(holder):
		return
	holder.position = Vector3.ZERO
	if pivot != null and is_instance_valid(pivot):
		pivot.rotation = Vector3.ZERO
	var skel := _find_skeleton(holder)
	if skel != null:
		skel.reset_bone_poses()
	holder.force_update_transform()
	var aabb := _local_aabb(holder)
	if aabb.size.length() < 0.05:
		aabb = AABB(Vector3(-0.45, 0.0, -0.45), Vector3(0.9, 0.9, 0.9))
	# 把包围盒中心放到原点，保证全身在镜头里
	holder.position = -aabb.get_center()
	holder.force_update_transform()
	aabb = _local_aabb(holder)
	var center := aabb.get_center()
	var extent := maxf(maxf(aabb.size.x, aabb.size.y), aabb.size.z)
	var radius := maxf(extent * 0.55, 0.5)
	var half_fov := deg_to_rad(cam.fov * 0.5)
	var dist := radius / maxf(tan(half_fov), 0.01) * 2.05
	cam.position = Vector3(radius * 0.12, center.y + aabb.size.y * 0.02, dist)
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
	_setup_level_select()


func _start_stack_game() -> void:
	_game_mode = MODE_STACK
	_cliff_rescuing = false
	_cliff_tip_pitch = 0.0
	_cliff_from_trampoline = false
	_progress = START_PLAYER_PROGRESS
	_lane = 1
	_lane_x = _lane_to_x(_lane)
	_air_y = ROAD_SURFACE_Y
	_grounded = true
	_vel_y = 0.0
	if _mode_ui:
		_mode_ui.queue_free()
		_mode_ui = null
	_spawn_cliffs()
	_hazard_sys.clear()
	_hazard_sys.spawn_center_rotators()
	_hazard_sys.spawn_all()
	_spawn_trampolines()
	_spawn_pickups()
	if bool(_level_cfg.get("showcase_props", false)) or bool(_level_cfg.get("test_level", false)):
		_speed_lanes.clear()
		_spawn_speed_lanes()
	_spawn_fruits()
	if bool(_level_cfg.get("showcase_props", false)) or bool(_level_cfg.get("test_level", false)):
		_spawn_speed_lane_fruits()
		_speed_orbs.clear()
		_spawn_speed_orbs()
		_boost_packs.clear()
		_spawn_boost_packs()
	_spawn_start_line()
	_spawn_tower()
	_update_camera()
	_start_ready_spin()


func _setup_mode_select() -> void:
	# 保留函数以免旧调用报错；直接进入叠塔
	_start_stack_game()


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


func _on_mode_chosen(_mode_id: String) -> void:
	# 兼容旧 UI：一律进 Stack
	_start_stack_game()


func _begin_gameplay() -> void:
	_intro_showcasing = false
	_waiting_to_start = false
	_playing = true
	_progress = maxf(_progress, START_PLAYER_PROGRESS)
	_air_y = ROAD_SURFACE_Y
	_grounded = true
	_vel_y = 0.0
	if _tower and not _stack.is_empty():
		var layer: Node3D = _stack[0]
		if layer and is_instance_valid(layer):
			var model_yaw := (
				PILOT_FORWARD_YAW if (_is_race() and _boosting) else _character_yaw()
			)
			layer.rotation = Vector3(0.0, model_yaw, 0.0)
			layer.position = Vector3.ZERO
			layer.scale = Vector3.ONE
			_play_capy_clip(layer, ["run", "idle", "dance"], true)
			call_deferred("_resnap_character_feet", layer, ["run", "idle"])
	if _hud_label:
		_hud_label.visible = true
	if _hud_tip:
		_hud_tip.visible = true
		if _is_race():
			_hud_tip.text = "空格/W跳跃躲障 · 碰飞船冲锋 · 黄星加速 · 橙道加速"
		else:
			_hud_tip.text = "Lv.%d %s · 速%.1f · 断崖踩跳跳床飞" % [
				_level_id,
				String(_level_cfg.get("name", "")),
				float(_level_cfg.get("run_speed", RUN_SPEED)),
			]
	_update_camera()
	_update_hud()
	_start_bgm()


func _start_ready_spin() -> void:
	## 全角色：起跑线后原地转圈，按空格再开跑
	_waiting_to_start = true
	_intro_showcasing = false
	_playing = false
	_ready_spin_yaw = 0.0
	_progress = START_PLAYER_PROGRESS
	_lane = 1
	_lane_x = _lane_to_x(_lane)
	_air_y = ROAD_SURFACE_Y
	_grounded = true
	if _hud_label:
		_hud_label.visible = true
		_hud_label.text = "%s 准备出发" % _character_display_name()
	if _hud_tip:
		_hud_tip.visible = true
		_hud_tip.text = "起跑线后展示中 · 按空格开始跑酷"
	if _tower == null or _stack.is_empty():
		_begin_gameplay()
		return
	_path_place_tower_ready()
	var layer: Node3D = _stack[0]
	if layer == null or not is_instance_valid(layer):
		_begin_gameplay()
		return
	layer.rotation = Vector3(0.0, _character_yaw(), 0.0)
	layer.position = Vector3.ZERO
	layer.scale = Vector3.ONE
	# 先 idle 贴地，准备转圈用 idle（dance 抬脚会量错、看起来陷进路面）
	_play_capy_clip(layer, ["idle", "run", "dance"], true)
	call_deferred("_resnap_then_ready_idle", layer)
	_update_camera()
	if _hud_label:
		_hud_label.text = "%s 准备出发" % _character_display_name()
	if _hud_tip:
		_hud_tip.text = "起跑线后展示中 · 按空格开始跑酷"


func _path_place_tower_ready() -> void:
	if _tower == null:
		return
	if _path != null:
		var f: Dictionary = _path.frame_at(_progress)
		_path_yaw = float(f["yaw"])
		var p: Vector3 = f["pos"]
		var r: Vector3 = f["right"]
		# 脚底对齐路面顶，避免浮空/埋地
		_tower.global_position = p + r * _lane_x + Vector3(0.0, ROAD_SURFACE_Y, 0.0)
		_tower.rotation = Vector3(0.0, _path_yaw, 0.0)
	else:
		_tower.position = Vector3(_lane_x, ROAD_SURFACE_Y, _progress)
		_tower.rotation = Vector3.ZERO


func _update_ready_spin(delta: float) -> void:
	_path_place_tower_ready()
	if _tower == null or _stack.is_empty():
		_update_camera()
		return
	var layer: Node3D = _stack[0]
	if layer == null or not is_instance_valid(layer):
		_update_camera()
		return
	_ready_spin_yaw += READY_SPIN_SPEED * delta
	layer.rotation = Vector3(0.0, _character_yaw() + _ready_spin_yaw, 0.0)
	layer.position = Vector3.ZERO
	_update_camera()


func _start_qingqing_intro() -> void:
	# 旧接口：并入全角色准备转圈
	_start_ready_spin()


func _update_intro_camera(_delta: float) -> void:
	_update_ready_spin(_delta)


func _setup_audio() -> void:
	## 路径见 CapybaraRushPaths；缺文件时静默跳过，不阻断开玩
	_stream_bgm = _load_audio_stream(CapybaraRushPaths.BGM_RUN)
	_stream_fruit = _load_audio_stream(CapybaraRushPaths.SFX_FRUIT)
	_stream_hit = _load_audio_stream(CapybaraRushPaths.SFX_HIT)
	_stream_pickup = _load_audio_stream(CapybaraRushPaths.SFX_PICKUP)

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BgmPlayer"
	_bgm_player.bus = "Master"
	_bgm_player.volume_db = -10.0
	add_child(_bgm_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SfxPlayer"
	_sfx_player.bus = "Master"
	_sfx_player.volume_db = -2.0
	add_child(_sfx_player)


func _load_audio_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	# 优先用 Godot 导入资源；未导入时直接解析 WAV
	if ResourceLoader.exists(path):
		var res: Resource = load(path)
		if res is AudioStream:
			return res as AudioStream
	if path.ends_with(".wav") and FileAccess.file_exists(path):
		return _load_wav_stream(path)
	# 允许同名 .ogg
	var ogg_path := path.get_basename() + ".ogg"
	if ResourceLoader.exists(ogg_path):
		var ogg_res: Resource = load(ogg_path)
		if ogg_res is AudioStream:
			return ogg_res as AudioStream
	push_warning("Audio missing: %s（放到 audio/ 目录即可）" % path)
	return null


func _load_wav_stream(path: String) -> AudioStreamWAV:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var data := f.get_buffer(f.get_length())
	if data.size() < 44:
		return null
	# 极简 RIFF/WAVE PCM 解析
	if data.slice(0, 4).get_string_from_ascii() != "RIFF":
		return null
	if data.slice(8, 12).get_string_from_ascii() != "WAVE":
		return null
	var pos := 12
	var channels := 1
	var sample_rate := 22050
	var bits := 16
	var pcm := PackedByteArray()
	while pos + 8 <= data.size():
		var chunk_id := data.slice(pos, pos + 4).get_string_from_ascii()
		var chunk_size := data.decode_u32(pos + 4)
		pos += 8
		if chunk_id == "fmt ":
			channels = data.decode_u16(pos + 2)
			sample_rate = data.decode_u32(pos + 4)
			bits = data.decode_u16(pos + 14)
		elif chunk_id == "data":
			pcm = data.slice(pos, pos + chunk_size)
			break
		pos += chunk_size
		if chunk_size % 2 == 1:
			pos += 1
	if pcm.is_empty():
		return null
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS if bits == 16 else AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = channels > 1
	stream.data = pcm
	return stream


func _start_bgm() -> void:
	if _bgm_player == null or _stream_bgm == null:
		return
	if _stream_bgm is AudioStreamWAV:
		(_stream_bgm as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif _stream_bgm is AudioStreamOggVorbis:
		(_stream_bgm as AudioStreamOggVorbis).loop = true
	_bgm_player.stream = _stream_bgm
	_bgm_player.volume_db = -10.0
	if not _bgm_player.playing:
		_bgm_player.play()


func _stop_bgm(fade_sec: float = 0.35) -> void:
	if _bgm_player == null or not _bgm_player.playing:
		return
	if fade_sec <= 0.001:
		_bgm_player.stop()
		return
	var from_db := _bgm_player.volume_db
	var tw := create_tween()
	tw.tween_property(_bgm_player, "volume_db", -40.0, fade_sec)
	tw.tween_callback(func() -> void:
		if _bgm_player != null:
			_bgm_player.stop()
			_bgm_player.volume_db = from_db
	)


func _play_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return
	# 每次新建短命播放器，避免连吃水果时互相打断
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.pitch_scale = clampf(pitch_scale, 0.7, 1.4)
	p.volume_db = -2.0
	p.bus = "Master"
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


func _play_sfx_fruit() -> void:
	_play_sfx(_stream_fruit, randf_range(0.94, 1.08))


func _play_sfx_hit() -> void:
	_play_sfx(_stream_hit, randf_range(0.92, 1.05))


func _play_sfx_pickup() -> void:
	_play_sfx(_stream_pickup, randf_range(0.96, 1.06))


func _update_tower_motion() -> void:
	if _tower == null:
		return
	var t := Time.get_ticks_msec() * 0.001
	# 只向上轻颠，避免负 bob 把脚压进跑道
	var bob := absf(sin(t * BOB_FREQ)) * BOB_AMP if _grounded and not _cliff_rescuing else 0.0
	if _path != null:
		var f: Dictionary = _path.frame_at(_progress)
		_path_yaw = float(f["yaw"])
		var p: Vector3 = f["pos"]
		var r: Vector3 = f["right"]
		_tower.global_position = p + r * _lane_x + Vector3(0.0, _air_y + bob, 0.0)
		var lean_target := clampf((_lane_x - _prev_lane_x) * 14.0, -MAX_LEAN, MAX_LEAN)
		var wobble := sin(t * 14.0) * minf(_sway, 2.0) * 0.08
		if _cliff_rescuing:
			lean_target = 0.0
			wobble = 0.0
		# 模型自身 yaw 在 fitted wrap 上；塔只跟弯道切向；断崖倾倒用 tip pitch
		_tower.rotation = Vector3(_cliff_tip_pitch, _path_yaw, lean_target + wobble)
	else:
		_tower.position = Vector3(_lane_x, _air_y + bob, _progress)
		var lean_target2 := clampf((_lane_x - _prev_lane_x) * 14.0, -MAX_LEAN, MAX_LEAN)
		var wobble2 := sin(t * 14.0) * minf(_sway, 2.0) * 0.08
		_tower.rotation.x = _cliff_tip_pitch
		_tower.rotation.z = 0.0 if _cliff_rescuing else (lean_target2 + wobble2)
	# 拾取插入动画期间由 tween 接管各层位姿
	if _stack_animating or _cliff_rescuing:
		return
	if _is_race():
		if _race_visual != null:
			_sync_capy_locomotion_anim(_race_visual, not _grounded)
		return
	var n := _stack.size()
	var want_jump := not _grounded
	for i in n:
		var layer: Node3D = _stack[i]
		if layer == null:
			continue
		# 只有最底层跑/跳；上面叠着的定住不动
		if i == 0:
			_sync_capy_locomotion_anim(layer, want_jump)
			var amp := 0.04 + minf(_sway, 2.2) * 0.04
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
			layer.rotation = Vector3(0.0, _character_yaw(), 0.0)
			layer.position = Vector3(0.0, float(i) * STACK_STEP_Y, 0.0)


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
	if idx == 0:
		_play_capy_clip(layer, ["run"], true)
	else:
		_park_stack_rider(layer)
	# 叠上只轻微晃一下，不会触发掉落
	_sway = minf(_sway + 0.08, 1.2)


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
	_tower.add_child(incoming)
	incoming.global_position = gpos
	# 复位朝向：跟着塔的弯道切向，模型自身 yaw 朝前方
	incoming.rotation = Vector3(0.0, _character_yaw(), 0.0)
	# 复位头骨，避免拾取时扭头姿势带进塔里
	var skel := _find_skeleton(incoming)
	var bone := _find_head_bone(skel)
	if skel != null and bone >= 0:
		skel.reset_bone_pose(bone)
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
	_play_sfx_pickup()
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
		if i == 0:
			_play_capy_clip(layer, ["run"], true)
		else:
			_park_stack_rider(layer)
		_resnap_character_feet(layer)

	_stack_animating = false
	_flush_pending_hazard_hits()
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
	if not _stack.is_empty():
		call_deferred("_resnap_character_feet", _stack[0], ["idle", "run"])


func _spawn_start_line() -> void:
	## 起跑线：黑白格纹横条，角色站在其前方（更大 progress）
	var holder := Node3D.new()
	holder.name = "StartLine"
	_world.add_child(holder)
	_path_place(holder, START_LINE_PROGRESS, 0.0, ROAD_SURFACE_Y + 0.01, 0.0)
	var stripe_w := ROAD_HALF_W * 2.05
	var stripe_d := 0.55
	var cell := 0.42
	var cols := maxi(int(stripe_w / cell), 6)
	var rows := 2
	var origin_x := -stripe_w * 0.5
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(0.98, 0.98, 1.0)
	white.roughness = 0.85
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.12, 0.12, 0.16)
	black.roughness = 0.9
	for r in rows:
		for c in cols:
			var mi := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(cell * 0.96, 0.04, stripe_d / float(rows) * 0.92)
			mi.mesh = box
			mi.material_override = white if ((c + r) % 2 == 0) else black
			mi.position = Vector3(
				origin_x + (float(c) + 0.5) * cell,
				0.02,
				(float(r) - 0.5) * (stripe_d / float(rows))
			)
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			holder.add_child(mi)
	# 小立牌提示
	var post := MeshInstance3D.new()
	var pc := CylinderMesh.new()
	pc.top_radius = 0.05
	pc.bottom_radius = 0.06
	pc.height = 0.85
	post.mesh = pc
	var pm := StandardMaterial3D.new()
	pm.albedo_color = Color(0.95, 0.35, 0.45)
	post.material_override = pm
	post.position = Vector3(-stripe_w * 0.5 - 0.25, 0.42, 0.0)
	post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(post)
	var flag := MeshInstance3D.new()
	var fb := BoxMesh.new()
	fb.size = Vector3(0.55, 0.32, 0.04)
	flag.mesh = fb
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color(1.0, 0.92, 0.35)
	flag.material_override = fm
	flag.position = Vector3(-stripe_w * 0.5 + 0.05, 0.78, 0.0)
	flag.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(flag)


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
	for h in _hazard_sys.items:
		if bool(h.get("hit", false)):
			continue
		if _hazard_sys.overlap(h, _progress, _lane_x, _air_y) == false:
			continue
		if _is_airborne_clear(CapybaraHazards.hit_top(h)):
			continue
		h["hit"] = true
		_collision_count += 1
		_play_sfx_hit()
		if _boosting:
			_boost_time_left = maxf(_boost_time_left - BOOST_HIT_PENALTY, 0.0)
			if _boost_time_left <= 0.001:
				_end_boost()
		_sway = minf(_sway + 0.9, 2.5)
		# 障碍物保持原地，不被撞飞


func _spawn_pickups() -> void:
	## 沿三道散落可叠水豚；间距读关卡
	var z := 16.0
	var i := 0
	var track_len := _track_len()
	var spacing: Array = _level_cfg.get("pickup_spacing", [10.0, 14.0])
	var lo := float(spacing[0]) if spacing.size() > 0 else 10.0
	var hi := float(spacing[1]) if spacing.size() > 1 else 14.0
	while z < track_len - 22.0:
		var lane := i % LANE_COUNT
		_spawn_pickup_at(_lane_to_x(lane), z)
		if i % 3 == 0:
			var other := (lane + 1 + (i % 2)) % LANE_COUNT
			_spawn_pickup_at(_lane_to_x(other), z + 5.0)
		z += randf_range(lo, hi)
		i += 1


func _spawn_fruits() -> void:
	## 路上水果 = 金币；稀有度越高分越高（冰雪关用雪糕/水晶）
	_fruits.clear()
	_coin_score = 0
	_fruit_orange = 0
	_fruit_apple = 0
	_fruit_banana = 0
	_fruit_pineapple = 0
	_fruit_durian = 0
	_fruit_icecream = 0
	_fruit_crystal = 0
	var pool: Array[String] = _fruit_pool_for_level()
	var z := 20.0
	var i := 0
	var track_len := _track_len()
	while z < track_len - 28.0:
		var kind: String = pool[i % pool.size()]
		var lane := (i + 1) % LANE_COUNT
		var lateral := _lane_to_x(lane)
		if _is_on_speed_lane_corridor(z, lateral):
			z += 1.8
			i += 1
			continue
		var visual := _make_fruit_visual(kind)
		var holder := Node3D.new()
		_world.add_child(holder)
		_path_place(holder, z, lateral, 0.55, 0.0)
		holder.add_child(visual)
		_fruits.append({
			"node": holder,
			"visual": visual,
			"dist": z,
			"lateral": lateral,
			"kind": kind,
			"coins": _fruit_coin_value(kind),
			"phase": randf() * TAU,
			"taken": false,
		})
		var fsp: Array = _level_cfg.get("fruit_spacing", [9.0, 13.0])
		var flo := float(fsp[0]) if fsp.size() > 0 else 9.0
		var fhi := float(fsp[1]) if fsp.size() > 1 else 13.0
		z += randf_range(flo, fhi)
		i += 1


func _fruit_pool_for_level() -> Array[String]:
	var raw: Variant = _level_cfg.get("fruit_pool", null)
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
	return String(_theme_cfg.get("id", "")) == "frost_snow" \
		or String(_level_cfg.get("theme_id", "")) == "frost_snow" \
		or String(_level_cfg.get("stair_kind", "")) == "ice"


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
		var fitted := _instance_fitted(model_path, target_h, 0.0)
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
	for f in _fruits:
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
		_path_place(node, dist, lateral, y, 0.0)
		var vis: Node3D = f.get("visual") as Node3D
		if vis == null or not is_instance_valid(vis):
			if node.get_child_count() > 0:
				vis = node.get_child(0) as Node3D
		if vis != null and is_instance_valid(vis):
			vis.rotation.y += FRUIT_SPIN_SPEED * delta


func _update_speed_orb_spin(delta: float) -> void:
	for o in _speed_orbs:
		if bool(o.get("taken", false)):
			continue
		var node: Node3D = o.get("node")
		if node == null or not is_instance_valid(node) or node.get_child_count() <= 0:
			continue
		var vis := node.get_child(0) as Node3D
		if vis != null:
			vis.rotation.y += SPEED_ORB_SPIN_SPEED * delta


func _try_collect_fruits() -> void:
	for f in _fruits:
		if bool(f.get("taken", false)):
			continue
		var node: Node3D = f.get("node")
		if node == null or not is_instance_valid(node):
			continue
		if not _along_overlap(float(f.get("dist", -999.0)), float(f.get("lateral", 0.0)), 1.1, 1.05):
			continue
		f["taken"] = true
		var coins := int(f.get("coins", 5))
		_coin_score += coins
		_play_sfx_fruit()
		var kind := String(f.get("kind", "orange"))
		match kind:
			"apple":
				_fruit_apple += 1
			"banana":
				_fruit_banana += 1
			"pineapple":
				_fruit_pineapple += 1
			"durian":
				_fruit_durian += 1
			"icecream":
				_fruit_icecream += 1
			"crystal":
				_fruit_crystal += 1
			_:
				_fruit_orange += 1
		node.visible = false



func _spawn_cliffs() -> void:
	## 断崖数量由关卡 JSON `cliffs` 控制；跳跳床只出现在断崖前
	_cliffs.clear()
	for g in _planned_cliff_gaps():
		var d0 := float(g.get("dist0", 0.0))
		var d1 := float(g.get("dist1", 0.0))
		_cliffs.append({"dist0": d0, "dist1": d1})
		_spawn_cliff_visual(d0, d1)


func _near_cliff_zone(dist: float, margin: float = 14.0) -> bool:
	for c in _cliffs:
		var d0 := float(c.get("dist0", 0.0)) - margin
		var d1 := float(c.get("dist1", 0.0)) + margin * 0.45
		if dist >= d0 and dist <= d1:
			return true
	return false


func _planned_cliff_gaps() -> Array:
	## 与路面挖空共用同一套区间，保证中间真正中空
	var gaps: Array = []
	var track_len := _track_len()
	var n := clampi(int(_level_cfg.get("cliffs", 0)), 0, 2)
	var gap := float(_level_cfg.get("cliff_gap_len", CLIFF_GAP_LEN))
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
	var road_col := CapybaraLevelCatalog.color3(_theme_cfg.get("road_color"), Color(0.86, 0.82, 0.94))
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
		_world.add_child(lip)
		_path_place(lip, edge_dist, 0.0, 0.0, 0.0)

		# 路面色檐口
		var rim := MeshInstance3D.new()
		var rim_box := BoxMesh.new()
		rim_box.size = Vector3(ROAD_HALF_W * 2.15, 0.16, 0.7)
		rim.mesh = rim_box
		var rim_mat := StandardMaterial3D.new()
		rim_mat.albedo_color = road_col
		rim_mat.roughness = 0.85
		rim.material_override = rim_mat
		rim.position = Vector3(0.0, 0.02, face_sign * 0.12)
		rim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		lip.add_child(rim)

		# 草皮外檐（略探出断口）
		var sod := MeshInstance3D.new()
		var sod_box := BoxMesh.new()
		sod_box.size = Vector3(ROAD_HALF_W * 2.25, 0.22, 0.85)
		sod.mesh = sod_box
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
		_world.add_child(wall_root)
		_path_place(wall_root, mid, side * (ROAD_HALF_W + 1.1), 0.0, 0.0)
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
	_world.add_child(void_n)
	_path_place(void_n, mid, 0.0, 0.0, 0.0)
	var abyss := MeshInstance3D.new()
	var abyss_plane := PlaneMesh.new()
	abyss_plane.size = Vector2(ROAD_HALF_W * 2.6 + 2.0, gap_len + 1.0)
	abyss_plane.subdivide_width = 36
	abyss_plane.subdivide_depth = maxi(20, int(gap_len * 3.0))
	abyss.mesh = abyss_plane
	var abyss_col := CapybaraLevelCatalog.color3(
		_theme_cfg.get("water_color"), Color(0.25, 0.48, 0.78, 0.92)
	)
	abyss.material_override = _make_water_ripple_material(abyss_col, 0.55, true)
	abyss.position.y = -7.2
	abyss.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	void_n.add_child(abyss)
	_water_meshes.append(abyss)
	var fog := MeshInstance3D.new()
	var fog_box := BoxMesh.new()
	fog_box.size = Vector3(ROAD_HALF_W * 2.4, 1.8, gap_len * 0.92)
	fog.mesh = fog_box
	fog.material_override = mist
	fog.position.y = -3.8
	fog.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	void_n.add_child(fog)


func _spawn_trampolines() -> void:
	## 每个断崖前：三道里只在一条跑道放跳跳床（首处固定中道，并清掉弹床/崖口障碍）
	_trampolines.clear()
	var seed_v := int(_level_cfg.get("hazard_seed", 1))
	var cliff_i := 0
	for c in _cliffs:
		var dist := float(c.get("dist0", 0.0)) - 4.8
		if dist < 20.0:
			cliff_i += 1
			continue
		var lane := 1 if cliff_i == 0 else -1
		if lane < 0:
			var rng := RandomNumberGenerator.new()
			rng.seed = hash([_level_id, seed_v, cliff_i, int(dist * 10.0)]) as int
			lane = rng.randi() % LANE_COUNT
		_hazard_sys.clear_near_cliff_approach(dist, lane)
		_spawn_trampoline_at(dist, lane)
		c["trampoline_lane"] = lane
		cliff_i += 1


func _spawn_trampoline_at(dist: float, lane: int) -> void:
	var lateral := _lane_to_x(lane)
	var visual := _make_trampoline_visual()
	var holder := Node3D.new()
	_world.add_child(holder)
	_path_place(holder, dist, lateral, 0.0, 0.0)
	holder.add_child(visual)
	_trampolines.append({
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
	rim_mat.albedo_color = CapybaraLevelCatalog.color3(_theme_cfg.get("trampoline_rim"), Color(1.0, 0.35, 0.55))
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



func _try_hit_hazards() -> void:
	for h in _hazard_sys.items:
		if bool(h.get("hit", false)):
			continue
		if _hazard_sys.overlap(h, _progress, _lane_x, _air_y) == false:
			continue
		# 脚底必须真正超过障碍顶才算跳过。
		# 以前用偏低的 clear_y：看起来还在穿模，却判定“跳过了”→ 不掉层。
		var hit_top := CapybaraHazards.hit_top(h)
		if (not _grounded) and _air_y >= hit_top - 0.02:
			continue
		# 拾取叠层动画中：先记下，动画结束后再掉层（避免 hit=true 却直接 return）
		if _stack_animating:
			h["pending_hit"] = true
			continue
		_apply_hazard_hit(h)


func _apply_hazard_hit(h: Dictionary) -> void:
	if bool(h.get("hit", false)):
		return
	h["hit"] = true
	h["pending_hit"] = false
	_collision_count += 1
	_play_sfx_hit()
	_force_drop_from_hazard(h)
	# 障碍物保持原地，不被撞飞


func _flush_pending_hazard_hits() -> void:
	## 拾取动画结束：结算期间擦过的障碍（即使人已离开碰撞盒也要掉）
	for h in _hazard_sys.items:
		if bool(h.get("hit", false)):
			continue
		if not bool(h.get("pending_hit", false)):
			continue
		_apply_hazard_hit(h)



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
	_path_place(holder, z, x, ROAD_SURFACE_Y, 0.0)
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
	_pickups.append(entry)


func _make_capy_visual() -> Node3D:
	var paths: Array[String] = [_character_model_path()]
	# 回退：卡皮绑定版 → 基础版
	if _character_id == CHAR_CAPYBARA:
		paths = [CapybaraRushPaths.CAPYBARA_BASE_RIGGED, CapybaraRushPaths.CAPYBARA_BASE]
	for path in paths:
		var n := _instance_fitted(path, TARGET_CAPY_HEIGHT, _character_yaw())
		if n:
			return n
	var stub := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.5
	sph.height = 1.0
	stub.mesh = sph
	var sm := StandardMaterial3D.new()
	match _character_id:
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


func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.72, 0.78, 0.92)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.92, 0.88, 0.95)
	env.ambient_light_energy = 0.85
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_world_env = WorldEnvironment.new()
	_world_env.environment = env
	add_child(_world_env)

	_sun_light = DirectionalLight3D.new()
	_sun_light.rotation_degrees = Vector3(-48, 35, 0)
	_sun_light.light_color = Color(1.0, 0.96, 0.9)
	_sun_light.light_energy = 1.15
	_sun_light.shadow_enabled = true
	add_child(_sun_light)


func _path_place(node: Node3D, dist: float, lateral: float, y: float = 0.0, yaw_extra: float = 0.0) -> void:
	if _path != null:
		_path.apply_to(node, dist, lateral, y, yaw_extra)
	else:
		node.position = Vector3(lateral, y, dist)
		node.rotation.y = yaw_extra


func _build_path_and_track() -> void:
	_path = CapybaraTrackPathScript.new()
	_path.build_winding(_track_len())
	_water_meshes.clear()

	_road_mesh = MeshInstance3D.new()
	_road_mesh.mesh = _path.build_road_mesh(ROAD_HALF_W, ROAD_THICKNESS, _planned_cliff_gaps())
	var mat := StandardMaterial3D.new()
	mat.albedo_color = CapybaraLevelCatalog.color3(_theme_cfg.get("road_color"), Color(0.86, 0.82, 0.94))
	mat.roughness = 0.85
	_road_mesh.material_override = mat
	_world.add_child(_road_mesh)

	var water_col := CapybaraLevelCatalog.color3(_theme_cfg.get("water_color"), Color(0.45, 0.70, 0.88))
	var track_z := float(_path.length) + 80.0
	# 整块水面铺在赛道下方（教程：细分平面 + 顶点浪）。
	# Y 低于路面，浪高也不顶穿跑道，避免再盖住白色赛道。
	var water := MeshInstance3D.new()
	water.name = "OceanWater"
	var plane := PlaneMesh.new()
	plane.size = Vector2(160.0, track_z)
	plane.subdivide_width = 96
	plane.subdivide_depth = clampi(int(track_z * 0.55), 96, 220)
	water.mesh = plane
	water.position = Vector3(0.0, -0.85, float(_path.length) * 0.45)
	# sea_height≈0.35 → 波峰约 -0.5，仍低于路面 ~0.09
	water.material_override = _make_water_ripple_material(water_col, 0.38, false)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_world.add_child(water)
	_water_meshes.append(water)


func _make_water_ripple_material(color: Color, sea_h: float = 0.38, deep_abyss: bool = false) -> Material:
	## stylized water（gameidea.org 教程：sea_octave 噪声浪）
	var sh: Shader = load("res://assets/maps/route_levels/capybara_rush/shaders/water_ripple.gdshader") as Shader
	if sh == null:
		var fb := StandardMaterial3D.new()
		fb.albedo_color = color
		fb.roughness = 0.12
		return fb
	var base := Color(
		clampf(color.r * 0.9 + 0.12, 0.0, 1.0),
		clampf(color.g * 0.9 + 0.15, 0.0, 1.0),
		clampf(color.b * 0.95 + 0.18, 0.0, 1.0)
	)
	var deep := Color(color.r * 0.22, color.g * 0.42, color.b * 0.55)
	var fog := Color(color.r * 0.1, color.g * 0.25, color.b * 0.36)
	var sm := ShaderMaterial.new()
	sm.shader = sh
	sm.set_shader_parameter("base_tint_color", base)
	sm.set_shader_parameter("deep_color", deep)
	sm.set_shader_parameter("underwater_fog_color", fog)
	sm.set_shader_parameter("water_absorption", Vector3(0.28, 0.08, 0.04))
	sm.set_shader_parameter("sea_height", sea_h)
	sm.set_shader_parameter("sea_choppy", 4.0 if deep_abyss else 3.6)
	sm.set_shader_parameter("sea_speed", 1.55)
	sm.set_shader_parameter("sea_freq", 0.10 if deep_abyss else 0.15)
	sm.set_shader_parameter("max_depth", 16.0 if deep_abyss else 7.0)
	sm.set_shader_parameter("fade_start_depth", 0.35)
	sm.set_shader_parameter("refraction_strength", 0.65)
	sm.set_shader_parameter("roughness", 0.09)
	sm.set_shader_parameter("specular", 0.7)
	sm.set_shader_parameter("foam_crest_amount", 2.6)
	sm.set_shader_parameter("foam_color", Color(0.95, 0.98, 1.0))
	return sm


func _scatter_props() -> void:
	## 路边装饰：主题树/灌木；缺模型则回退棒棒糖树
	var track_len := _track_len()
	_place_along(CapybaraRushPaths.FINISH_ARCH, track_len - 1.2, 0.0, 0.0, 3.2, 0.0)
	var tree_path := _theme_prop_path("tree", CapybaraRushPaths.TREE_LOLLIPOP)
	var bush_path := _theme_prop_path("bush", CapybaraRushPaths.BUSH_ROUND)
	var side_path := _theme_prop_path("side_prop", "")

	var z := 18.0
	var flip := 1.0
	while z < track_len - 20.0:
		var side := flip
		_place_along(
			tree_path,
			z, side * (ROAD_HALF_W + 3.6 + randf() * 1.2), 0.0,
			randf_range(1.8, 2.4), randf() * TAU
		)
		if randf() > 0.65:
			_place_along(
				bush_path,
				z + 4.0, side * (ROAD_HALF_W + 2.2), 0.0,
				randf_range(0.9, 1.2), randf() * TAU
			)
		if not side_path.is_empty() and randf() > 0.72:
			_place_along(
				side_path,
				z + randf_range(6.0, 14.0), -side * (ROAD_HALF_W + 2.0 + randf() * 0.8), 0.0,
				randf_range(0.38, 0.52), randf() * TAU
			)
		z += randf_range(28.0, 40.0)
		flip *= -1.0


func _ensure_ice_parallax_textures() -> void:
	## 程序化表层 / 底层 / 法线（供 CapybaraHazards 冰块材质使用）
	if _ice_tex_over != null and _ice_tex_under != null and _ice_tex_normal != null:
		return
	var res := 128
	var over_img := Image.create(res, res, false, Image.FORMAT_RGBA8)
	var under_img := Image.create(res, res, false, Image.FORMAT_RGBA8)
	var height := PackedFloat32Array()
	height.resize(res * res)
	for y in res:
		for x in res:
			var fx := float(x) / float(res)
			var fy := float(y) / float(res)
			var n1 := _ice_hash2(fx * 7.0, fy * 7.0)
			var n2 := _ice_hash2(fx * 17.0 + 3.1, fy * 17.0 + 1.7)
			var n3 := _ice_hash2(fx * 31.0 + 8.0, fy * 29.0)
			var ridge := 1.0 - absf(n1 * 2.0 - 1.0)
			var crack := smoothstep(0.7, 0.95, ridge)
			var grain := n2 * 0.55 + n3 * 0.45
			height[y * res + x] = crack * 0.65 + grain * 0.35
			var over_c := Color(
				0.72 + grain * 0.2 + crack * 0.22,
				0.88 + grain * 0.1 + crack * 0.12,
				0.98,
				1.0
			)
			over_img.set_pixel(x, y, over_c)
			var under_c := Color(
				0.28 + (1.0 - crack) * 0.25 + grain * 0.1,
				0.48 + (1.0 - crack) * 0.2,
				0.72 + grain * 0.15,
				1.0
			)
			under_img.set_pixel(x, y, under_c)
	var normal_img := Image.create(res, res, false, Image.FORMAT_RGBA8)
	for y in res:
		for x in res:
			var xl := height[y * res + ((x - 1 + res) % res)]
			var xr := height[y * res + ((x + 1) % res)]
			var yd := height[((y - 1 + res) % res) * res + x]
			var yu := height[((y + 1) % res) * res + x]
			var dx := (xl - xr) * 3.5
			var dy := (yd - yu) * 3.5
			var n := Vector3(dx, dy, 1.0).normalized()
			normal_img.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5))
	_ice_tex_over = ImageTexture.create_from_image(over_img)
	_ice_tex_under = ImageTexture.create_from_image(under_img)
	_ice_tex_normal = ImageTexture.create_from_image(normal_img)


func _ice_hash2(x: float, y: float) -> float:
	var n := sin(x * 127.1 + y * 311.7) * 43758.5453
	return n - floor(n)


func _disable_subtree_shadows(root: Node) -> void:
	if root == null:
		return
	if root is GeometryInstance3D:
		(root as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in root.get_children():
		_disable_subtree_shadows(c)





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
	## 高对比橙色加速道 + 前进方向箭头（局部 +Z）
	var z := 90.0
	var i := 0
	var track_len := _track_len()
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
		var lateral := _lane_to_x(lane)
		var seg_len := randf_range(16.0, 24.0)
		var holder := Node3D.new()
		_world.add_child(holder)
		_path_place(holder, z + seg_len * 0.5, lateral, 0.04, 0.0)

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

		_speed_lanes.append({
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
	var fruit_spacing := float(_level_cfg.get("speed_lane_fruit_spacing", SPEED_LANE_FRUIT_SPACING))
	for lane in _speed_lanes:
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
		_world.add_child(holder)
		_path_place(holder, fz, lateral, 0.55, 0.0)
		holder.add_child(visual)
		_fruits.append({
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
	_hud_tip.text = "断崖踩跳跳床飞过去 · 硬闯会倾倒掉底四只再摔到对岸"
	_hud_tip.position = Vector2(24, 110)
	_hud_tip.add_theme_font_size_override("font_size", 16)
	_hud_tip.add_theme_color_override("font_color", Color(0.25, 0.22, 0.35))
	layer.add_child(_hud_tip)


func _show_result_screen() -> void:
	if _result_ui != null:
		return
	_stop_bgm(0.5)
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
	card.offset_top = -320
	card.offset_bottom = 320
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
	v.add_theme_constant_override("separation", 10)
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
		hero.text = "%d" % _coin_score
	hero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero.add_theme_font_size_override("font_size", 72)
	hero.add_theme_color_override("font_color", Color(0.98, 0.42, 0.58))
	v.add_child(hero)

	var hero_cap := Label.new()
	if _is_race():
		hero_cap.text = "次登上飞船冲锋"
	else:
		hero_cap.text = "金币 · %d 只%s抵达" % [arrived, unit]
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
		if _is_frost_theme() or _fruit_icecream > 0 or _fruit_crystal > 0:
			v.add_child(_result_stat_chip("雪糕", "%d · +%d" % [_fruit_icecream, _fruit_icecream * 10], Color(0.92, 0.97, 1.0)))
			v.add_child(_result_stat_chip("水晶", "%d · +%d" % [_fruit_crystal, _fruit_crystal * 22], Color(0.85, 0.95, 1.0)))
		else:
			v.add_child(_result_stat_chip("橙子", "%d · +%d" % [_fruit_orange, _fruit_orange * 5], Color(1.0, 0.93, 0.82)))
			v.add_child(_result_stat_chip("苹果", "%d · +%d" % [_fruit_apple, _fruit_apple * 8], Color(1.0, 0.90, 0.90)))
			v.add_child(_result_stat_chip("香蕉", "%d · +%d" % [_fruit_banana, _fruit_banana * 12], Color(1.0, 0.96, 0.82)))
			v.add_child(_result_stat_chip("菠萝", "%d · +%d" % [_fruit_pineapple, _fruit_pineapple * 18], Color(1.0, 0.94, 0.75)))
			v.add_child(_result_stat_chip("榴莲", "%d · +%d" % [_fruit_durian, _fruit_durian * 30], Color(0.95, 0.92, 0.7)))
		v.add_child(_result_stat_chip("金币合计", "%d" % _coin_score, Color(1.0, 0.94, 0.72)))
	v.add_child(_result_stat_chip("西瓜", "%d · +%d" % [_watermelon_count, _watermelon_count * 20], Color(1.0, 0.90, 0.92)))

	var tip := Label.new()
	if _coin_score > 0:
		tip.text = "Lv.%d %s · 速度 %.1f" % [_level_id, String(_level_cfg.get("name", "")), float(_level_cfg.get("run_speed", RUN_SPEED))]
	else:
		tip.text = "Lv.%d %s · R 重开本关" % [_level_id, String(_level_cfg.get("name", ""))]
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 16)
	tip.add_theme_color_override("font_color", Color(0.62, 0.55, 0.66))
	v.add_child(tip)

	CapybaraLevelCatalog.mark_cleared(_level_id)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	v.add_child(row)

	var btn := Button.new()
	btn.text = "再来一局"
	btn.custom_minimum_size = Vector2(160, 58)
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_focus_color", Color(1, 1, 1))
	var btn_n := _cartoon_panel_style(Color(1.0, 0.55, 0.68), Color(1.0, 0.78, 0.86), 22.0, 0.0)
	var btn_h := _cartoon_panel_style(Color(1.0, 0.62, 0.74), Color(1.0, 0.84, 0.90), 22.0, 0.0)
	var btn_p := _cartoon_panel_style(Color(0.92, 0.48, 0.62), Color(1.0, 0.72, 0.82), 22.0, 0.0)
	btn.add_theme_stylebox_override("normal", btn_n)
	btn.add_theme_stylebox_override("hover", btn_h)
	btn.add_theme_stylebox_override("pressed", btn_p)
	btn.add_theme_stylebox_override("focus", btn_h)
	btn.pressed.connect(func() -> void: _reload_same_level())
	row.add_child(btn)

	if _level_id < CapybaraLevelCatalog.LEVEL_COUNT:
		var next_btn := Button.new()
		next_btn.text = "下一关"
		next_btn.custom_minimum_size = Vector2(160, 58)
		next_btn.add_theme_font_size_override("font_size", 22)
		next_btn.add_theme_color_override("font_color", Color(1, 1, 1))
		next_btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
		next_btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
		next_btn.add_theme_color_override("font_focus_color", Color(1, 1, 1))
		var next_n := _cartoon_panel_style(Color(0.45, 0.72, 0.95), Color(0.7, 0.88, 1.0), 22.0, 0.0)
		var next_h := _cartoon_panel_style(Color(0.52, 0.78, 0.98), Color(0.78, 0.92, 1.0), 22.0, 0.0)
		var next_p := _cartoon_panel_style(Color(0.36, 0.62, 0.88), Color(0.62, 0.82, 0.98), 22.0, 0.0)
		next_btn.add_theme_stylebox_override("normal", next_n)
		next_btn.add_theme_stylebox_override("hover", next_h)
		next_btn.add_theme_stylebox_override("pressed", next_p)
		next_btn.add_theme_stylebox_override("focus", next_h)
		next_btn.pressed.connect(func() -> void: _reload_next_level())
		row.add_child(next_btn)

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
	if _hud_label == null or _finished or _waiting_to_start:
		return
	var track_len := _track_len()
	var pct := int((_progress / maxf(track_len, 1.0)) * 100.0)
	var speed := _current_run_speed()
	var remain_s := maxf((track_len - _progress) / maxf(speed, 0.01), 0.0)
	var speed_txt := ""
	if _speed_buff_left > 0.0:
		speed_txt += " 星加速%.1fs" % _speed_buff_left
	if _on_speed_lane:
		speed_txt += " 赛道×%.2f" % _speed_lane_mul()
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
	if ENABLE_MOVE_DROP and _stack.size() >= MIN_STACK_TO_DROP and moving:
		risk = _move_drop_chance_per_sec() * 100.0
	var state := "剧烈!" if violent else ("移动中" if moving else "静止")
	_hud_label.text = "%s Rush  约剩 %.0fs  进度 %d%%\n车道 %d/%d · 叠高 %d · 金币 %d · %s · 风险 %.0f%%%s" % [
		_character_display_name(), remain_s, pct, _lane + 1, LANE_COUNT, _stack.size(), _coin_score, state, risk, speed_txt
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
	# 蒙皮网格需进树后用 get_aabb，否则贴地会算矮、腿埋地
	var skel := _find_skeleton(wrap)
	if skel != null:
		skel.reset_bone_poses()
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
		path.contains("/characters/")
		or path.contains("capybara")
		or path.contains("qingqing")
	)
	# 角色默认进跑姿再量脚：rest 贴地 → 一跑就埋进赛道
	if is_char:
		_play_capy_clip(wrap, ["idle", "run"], true)
		_snap_fitted_feet_to_ground(
			wrap,
			raw,
			_foot_lift_for_path(path),
			["idle", "run"],
			_is_capy_model_path(path)
		)
	else:
		_play_capy_clip(wrap, ["run", "dance"], true)

	remove_child(wrap)
	return wrap


func _is_capy_model_path(path: String) -> bool:
	return path.contains("capybara")


func _foot_lift_for_path(path: String) -> float:
	if _is_capy_model_path(path):
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
	if not _waiting_to_start:
		return
	_play_capy_clip(visual, ["idle", "run"], true)


func _resnap_then_ready_dance(visual: Node3D) -> void:
	# 兼容旧调用：终点/展示仍可能需要 dance，先贴地再播
	await _resnap_character_feet(visual, ["idle", "run"])
	if visual == null or not is_instance_valid(visual):
		return
	if not _waiting_to_start:
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
	if _character_id != CHAR_CAPYBARA and _character_id != CHAR_QINGQING:
		lift = CHAR_FOOT_LIFT
	var prefer_bones := _character_id == CHAR_CAPYBARA
	_snap_fitted_feet_to_ground(visual, raw, lift, measure_keys, prefer_bones)
	if _is_soft_skin_character() or _character_id == CHAR_CAPYBARA:
		await get_tree().process_frame
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


func _reload_same_level() -> void:
	pending_level_id = _level_id
	pending_character_id = _character_id
	get_tree().reload_current_scene()


func _reload_next_level() -> void:
	pending_level_id = mini(_level_id + 1, CapybaraLevelCatalog.LEVEL_COUNT)
	pending_character_id = _character_id
	get_tree().reload_current_scene()


func _load_level_bundle(level_id: int) -> void:
	_level_id = clampi(level_id, 1, CapybaraLevelCatalog.LEVEL_COUNT)
	_level_cfg = CapybaraLevelCatalog.load_level(_level_id)
	_theme_cfg = CapybaraLevelCatalog.load_theme_for_level(_level_cfg)
	_apply_theme_environment()


func _apply_theme_environment() -> void:
	if _world_env != null and _world_env.environment != null:
		var env := _world_env.environment
		env.background_color = CapybaraLevelCatalog.color3(_theme_cfg.get("sky_color"), env.background_color)
		env.ambient_light_color = CapybaraLevelCatalog.color3(_theme_cfg.get("ambient_color"), env.ambient_light_color)
		env.ambient_light_energy = float(_theme_cfg.get("ambient_energy", env.ambient_light_energy))
	if _sun_light != null:
		_sun_light.light_color = CapybaraLevelCatalog.color3(_theme_cfg.get("sun_color"), _sun_light.light_color)
		_sun_light.light_energy = float(_theme_cfg.get("sun_energy", _sun_light.light_energy))


func _rebuild_level_world() -> void:
	while _world.get_child_count() > 0:
		var c := _world.get_child(0)
		_world.remove_child(c)
		c.free()
	_clouds.clear()
	_finish_sys.clear()
	_hazard_sys.clear()
	_trampolines.clear()
	_cliffs.clear()
	_pickups.clear()
	_fruits.clear()
	_rotator_arenas.clear()
	_speed_lanes.clear()
	_speed_orbs.clear()
	_boost_packs.clear()
	_tower = null
	_stack.clear()
	_cliff_rescuing = false
	_cliff_tip_pitch = 0.0
	_cliff_from_trampoline = false
	_build_path_and_track()
	_scatter_props()
	_finish_sys.spawn_stairs()
	_spawn_clouds()


func _theme_prop_path(key: String, fallback: String) -> String:
	var props: Variant = _theme_cfg.get("props", {})
	if typeof(props) != TYPE_DICTIONARY:
		return fallback
	var p := String((props as Dictionary).get(key, ""))
	if p.is_empty():
		return fallback
	if ResourceLoader.exists(p) or FileAccess.file_exists(p):
		return p
	return fallback


func _theme_obstacle_path(key: String) -> String:
	var obs: Variant = _theme_cfg.get("obstacles", {})
	if typeof(obs) != TYPE_DICTIONARY:
		return ""
	var raw: Variant = (obs as Dictionary).get(key, null)
	if raw == null:
		return ""
	var p := str(raw)
	if p.is_empty() or p == "<null>" or p == "null":
		return ""
	if ResourceLoader.exists(p) or FileAccess.file_exists(p):
		return p
	return ""


func _setup_level_select() -> void:
	if _level_ui != null:
		_level_ui.queue_free()
	_level_ui = CanvasLayer.new()
	_level_ui.layer = 25
	add_child(_level_ui)
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_level_ui.add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.55, 0.68, 0.88, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -420
	panel.offset_right = 420
	panel.offset_top = -300
	panel.offset_bottom = 300
	panel.add_theme_stylebox_override("panel", _cartoon_panel_style(
		Color(1.0, 0.98, 0.99), Color(1.0, 0.72, 0.82), 28.0, 4.0
	))
	root.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	margin.add_child(v)
	var title := Label.new()
	title.text = "选择关卡 · %d 关" % CapybaraLevelCatalog.LEVEL_COUNT
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.35, 0.22, 0.42))
	v.add_child(title)
	var unlocked := CapybaraLevelCatalog.get_unlocked_max()
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 420)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(scroll)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)
	for i in range(1, CapybaraLevelCatalog.LEVEL_COUNT + 1):
		var cfg := CapybaraLevelCatalog.load_level(i)
		var b := Button.new()
		var spd := float(cfg.get("run_speed", 12.0))
		b.text = "%02d\n%s\n%.1f" % [i, String(cfg.get("name", "")), spd]
		b.custom_minimum_size = Vector2(140, 78)
		b.add_theme_font_size_override("font_size", 14)
		var is_test := bool(cfg.get("test_level", false))
		var locked := i > unlocked and not is_test
		b.disabled = locked
		if locked:
			b.text = "%02d\n锁定" % i
		elif is_test:
			b.text = "%02d\n%s\n测试" % [i, String(cfg.get("name", ""))]
			b.tooltip_text = "开发测试关 · 含全部障碍 · 无需解锁"
		else:
			var theme_name := String(CapybaraLevelCatalog.load_theme(String(cfg.get("theme_id", "lake_clear"))).get("display_name", ""))
			b.tooltip_text = "%s · %s · 断崖%d" % [theme_name, String(cfg.get("name", "")), int(cfg.get("cliffs", 0))]
		var lid := i
		b.pressed.connect(_on_level_chosen.bind(lid))
		grid.add_child(b)


func _on_level_chosen(level_id: int) -> void:
	if _level_ui != null:
		_level_ui.queue_free()
		_level_ui = null
	_load_level_bundle(level_id)
	_rebuild_level_world()
	_start_stack_game()
