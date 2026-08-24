extends Node3D

## Capybara Rush 原型：Stack 叠塔 / 竞速冲锋。
## 打开 capybara_rush.tscn 后按 F6 运行。

const CapybaraTrackPathScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_track_path.gd")
const LevelCatalogScript := preload("res://assets/maps/route_levels/capybara_rush/level_catalog.gd")
const CapybaraHazardsScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_hazards.gd")
const CapybaraFinishScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_finish.gd")
const CapybaraUiScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_ui.gd")
const CapybaraStackScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_stack.gd")
const CapybaraTrackScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_track.gd")
const CapybaraWorldScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_world.gd")
const CapybaraRaceScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_race.gd")
const CapybaraCdnScript := preload("res://assets/maps/route_levels/capybara_rush/capybara_cdn.gd")

const LANE_COUNT := 3
## 三车道贴满跑道：3 × 车道宽 = 跑道全宽，三颗骰子并排无左右空隙
const LANE_WIDTH := 1.52
const ROAD_HALF_W := LANE_WIDTH * 1.5
const TRACK_LATERAL_SPEED := 7.2
const TRACK_LATERAL_MARGIN := 0.52
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
const TARGET_DURATION_SEC := 50.0
const BOB_AMP := 0.06
const BOB_FREQ := 9.0
## 可吃加分物原地旋转；胡萝卜等障碍物保持静止以便区分
const FRUIT_SPIN_SPEED := 2.0
const SPEED_ORB_SPIN_SPEED := 2.4
## 深棕站立卡皮巴拉：目标高度与叠层间距（接近身高，只留一点嵌合）
const TARGET_CAPY_HEIGHT := 1.24
const TARGET_PILOT_HEIGHT := 1.55
const STACK_STEP_Y := 1.18
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
const CHAR_COW := "cow"
## 直立/双足类：叠层扭摆减弱，避免拧成麻花
const CHAR_UPRIGHT_IDS: Array[String] = [
	CHAR_QINGQING, CHAR_LITTLE_MONSTER, CHAR_LITTLE_RABBIT, CHAR_SHIBA, CHAR_BIRD,
	CHAR_MOUSE, CHAR_SLOTH, CHAR_TINY_PLANET, CHAR_BEAR,
]
const HIDDEN_CHARACTER_IDS: Array[String] = [CHAR_QINGQING]
## 自动临近权重蒙皮：大动作会「融化」，少扭骨
const CHAR_SOFT_SKIN_IDS: Array[String] = [
	CHAR_BIRD, CHAR_MOUSE, CHAR_SLOTH, CHAR_TINY_PLANET, CHAR_BEAR,
]
const MODE_STACK := "stack"
const MODE_RACE := "race"
## 拾取半径小于半车道，避免邻道苹果/卡皮自动吸附
const PICKUP_RADIUS_X := 0.72
const PICKUP_RADIUS_Z := 1.15
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
var _touch_start := Vector2.ZERO
var _touch_active := false
var _swipe_used := false
const TOUCH_SWIPE_MIN := 56.0
const TOUCH_TAP_MAX := 28.0
var _world: Node3D
var _clouds: Array[Node3D] = []
var _character_id := CHAR_CAPYBARA
var _game_mode := MODE_STACK
var _playing := false
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
var _ui_sys: CapybaraUi
var _stack_sys: CapybaraStack
var _track_sys: CapybaraTrack
var _world_sys: CapybaraWorld
var _race_sys: CapybaraRace
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
var _cdn_sys: CapybaraCdn
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
	_ui_sys = CapybaraUiScript.new(self)
	_stack_sys = CapybaraStackScript.new(self)
	_track_sys = CapybaraTrackScript.new(self)
	_world_sys = CapybaraWorldScript.new(self)
	_race_sys = CapybaraRaceScript.new(self)
	_cdn_sys = CapybaraCdnScript.new()
	_cdn_sys.name = "CapybaraCdn"
	add_child(_cdn_sys)
	_cdn_sys.preload_progress.connect(_ui_sys.on_cdn_preload_progress)
	_track_sys.setup_environment()
	_race_sys.setup_camera()
	_ui_sys.setup_hud()
	_race_sys.setup_audio()
	if CapybaraUi.pending_custom_level_id != "":
		_character_id = _normalize_character_id(CapybaraUi.pending_character_id)
		var custom_id := CapybaraUi.pending_custom_level_id
		CapybaraUi.pending_custom_level_id = ""
		CapybaraUi.pending_level_id = 0
		CapybaraUi.pending_character_id = ""
		_track_sys.load_custom_level_bundle(custom_id)
		await _prepare_level_assets()
		_rebuild_level_world()
		_start_stack_game()
	elif CapybaraUi.pending_level_id > 0:
		_character_id = _normalize_character_id(CapybaraUi.pending_character_id)
		_level_id = CapybaraUi.pending_level_id
		CapybaraUi.pending_level_id = 0
		CapybaraUi.pending_character_id = ""
		CapybaraUi.pending_open_level_select = false
		_track_sys.load_level_bundle(_level_id)
		await _prepare_level_assets()
		_rebuild_level_world()
		_start_stack_game()
	else:
		_track_sys.load_level_bundle(1)
		# 选角/选关菜单：不预载关卡 GLB，避免与 wasm/pck 抢带宽；进关后再 _prepare_level_assets
		if CapybaraUi.pending_open_level_select:
			_character_id = _normalize_character_id(CapybaraUi.pending_character_id)
			CapybaraUi.pending_open_level_select = false
			CapybaraUi.pending_character_id = ""
			_ui_sys.setup_level_select()
		else:
			_ui_sys.setup_character_select()
	_lane_x = _lane_to_x(_lane)



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or _key_pressed(event, KEY_ESCAPE):
		if _ui_sys.is_select_active():
			return
		if _ui_sys.is_paused():
			_ui_sys.resume_game()
			return
		if _ui_sys.is_result_active() or _ui_sys.level_ui != null:
			_ui_sys.request_character_select()
			return
		if _playing or _waiting_to_start:
			_ui_sys.pause_game()
			return
		reload_game_scene()
		return
	if _ui_sys.is_menu_blocking():
		return
	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
		return
	if event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)
		return
	# 出发前：原地转圈，空格 / 点屏幕开始跑酷
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
		if _ui_sys.is_result_active() and (
			event.is_action_pressed("ui_accept") or _key_pressed(event, KEY_R)
		):
			_ui_sys.reload_same_level()
		return
	elif (
		event.is_action_pressed("ui_accept")
		or event.is_action_pressed("ui_up")
		or _key_pressed(event, KEY_SPACE)
		or _key_pressed(event, KEY_W)
		or _key_pressed(event, KEY_UP)
	):
		_world_sys.try_jump()



func _key_pressed(event: InputEvent, code: Key) -> bool:
	return event is InputEventKey and event.pressed and not event.echo and event.keycode == code


func _handle_screen_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed:
		_touch_active = true
		_swipe_used = false
		_touch_start = touch.position
		return
	if not _touch_active:
		return
	_touch_active = false
	var delta := touch.position - _touch_start
	if _waiting_to_start:
		_begin_gameplay()
		return
	if not _playing or _finished:
		return
	if _swipe_used:
		return
	if delta.length() <= TOUCH_TAP_MAX:
		_world_sys.try_jump()
	else:
		_apply_touch_swipe(delta)


func _handle_screen_drag(drag: InputEventScreenDrag) -> void:
	if not _touch_active or _swipe_used:
		return
	if _waiting_to_start or not _playing or _finished:
		return
	var delta := drag.position - _touch_start
	if delta.length() >= TOUCH_SWIPE_MIN:
		_swipe_used = true
		_apply_touch_swipe(delta)


func _apply_touch_swipe(delta: Vector2) -> void:
	if absf(delta.x) >= absf(delta.y):
		# 与按键一致：左键增加 lane_x
		_snap_lane(1 if delta.x < 0.0 else -1)
	elif delta.y < 0.0:
		_world_sys.try_jump()


func _snap_lane(delta_lane: int) -> void:
	_lane = clampi(_lane + delta_lane, 0, LANE_COUNT - 1)
	_lane_x = clampf(_lane_to_x(_lane), -_lateral_limit(), _lateral_limit())
	_lane_change_times.append(Time.get_ticks_msec() * 0.001)



func _process(delta: float) -> void:
	if _ui_sys.is_paused():
		return
	_stack_sys.update_falling(delta)
	_track_sys.update_clouds(delta)
	if _ui_sys.is_select_active():
		_ui_sys.spin_select_previews(delta)
		return
	if _ui_sys.is_menu_blocking():
		return
	if _waiting_to_start or _intro_showcasing:
		_stack_sys.update_ready_spin(delta)
		_hazard_sys.update(delta)
		return
	if not _playing:
		return
	if _finished:
		if _finish_sys.ceremony_active:
			_finish_sys.update_camera(delta)
		_stack_sys.update_falling(delta)
		return
	if _game_mode == MODE_RACE:
		_race_sys.update_boost(delta)
	_world_sys.update_speed_buff(delta)
	_world_sys.update_jump(delta)
	_world_sys.try_trampoline_bounce()
	_world_sys.update_trampoline_cd(delta)
	_world_sys.refresh_speed_lane_state()
	_hazard_sys.update(delta)
	var speed := _race_sys.current_run_speed()
	var track_len := _track_len()
	if not _cliff_rescuing:
		var next_prog := minf(_progress + speed * delta, track_len)
		# 没踩跳跳床：可以掉进断崖，但不能靠普通跳「飞」到对岸
		if not _cliff_from_trampoline:
			var cap := _world_sys.cliff_forward_cap()
			if cap >= 0.0:
				next_prog = minf(next_prog, cap)
		_progress = next_prog
	_update_lateral_move(delta)
	_stack_sys.update_sway(delta)
	_stack_sys.update_tower_motion()
	_world_sys.try_collect_speed_orbs()
	_world_sys.update_speed_orb_spin(delta)
	if _game_mode == MODE_STACK:
		if not _cliff_rescuing:
			_stack_sys.update_pickup_bob(delta)
			_stack_sys.try_collect_pickups()
			_world_sys.update_fruit_bob(delta)
			_world_sys.try_collect_fruits()
			_stack_sys.try_hit_hazards()
			_stack_sys.try_drop_layers(delta)
	else:
		_race_sys.update_boost_pack_bob()
		_race_sys.try_collect_spaceships()
		_race_sys.try_collect_boost_packs()
		_race_sys.try_hit_hazards_race()
	_race_sys.update_camera()
	_race_sys.update_hud()
	if not _cliff_rescuing and _progress >= track_len - 0.5:
		_finished = true
		_ui_sys.show_ceremony_chrome()
		_finish_sys.start_ceremony()



func _track_len() -> float:
	if not _level_cfg.is_empty():
		return float(_level_cfg.get("track_length", TRACK_LENGTH))
	if _path != null and _path.length > 1.0:
		return _path.length
	return TRACK_LENGTH



func _show_result_screen() -> void:
	_ui_sys.show_result_screen()



func _ui_frame_select_preview(cam: Camera3D, holder: Node3D, pivot: Node3D) -> void:
	_ui_sys._frame_select_preview(cam, holder, pivot)



func _ui_deferred_reframe_select_preview(cam: Camera3D, holder: Node3D, pivot: Node3D) -> void:
	_ui_sys._deferred_reframe_select_preview(cam, holder, pivot)



func _fail_game(reason: String) -> void:
	if _finished:
		return
	_finished = true
	_finish_sys.ceremony_active = false
	_stop_bgm()
	# 撞飞最后一只
	if not _stack.is_empty():
		_stack_sys._drop_top_layer(true)
	_ui_sys.show_fail_screen(reason)





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
	dir += _ui_sys.steer_dir()
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



func _on_character_chosen(char_id: String) -> void:
	_character_id = _normalize_character_id(char_id)
	_ui_sys.dismiss_character_select()
	_ui_sys.setup_level_select()


func _normalize_character_id(char_id: String) -> String:
	if char_id in HIDDEN_CHARACTER_IDS:
		return CHAR_CAPYBARA
	return char_id if not char_id.is_empty() else CHAR_CAPYBARA



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
	_ui_sys.dismiss_mode_select()
	_world_sys.spawn_cliffs()
	_hazard_sys.clear()
	_hazard_sys.spawn_center_rotators()
	_hazard_sys.spawn_all()
	_world_sys.spawn_jump_challenges()
	_world_sys.spawn_trampolines()
	_stack_sys.spawn_pickups()
	if bool(_level_cfg.get("showcase_props", false)) or bool(_level_cfg.get("test_level", false)):
		_speed_lanes.clear()
		_world_sys.spawn_speed_lanes()
	_world_sys.spawn_fruits()
	if bool(_level_cfg.get("showcase_props", false)) or bool(_level_cfg.get("test_level", false)):
		_world_sys.spawn_speed_lane_fruits()
		_speed_orbs.clear()
		_world_sys.spawn_speed_orbs()
		_boost_packs.clear()
		_race_sys.spawn_boost_packs()
	_track_sys.spawn_start_line()
	_stack_sys.spawn_tower()
	_race_sys.update_camera()
	_stack_sys.start_ready_spin()





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
	if _hud_tip:
		var tip_extra := ""
		var jumps: Variant = _level_cfg.get("jump_challenges", [])
		if typeof(jumps) == TYPE_ARRAY and not (jumps as Array).is_empty():
			tip_extra = " · pool triple jump"
		_hud_tip.text = "Swipe lanes · tap jump%s" % tip_extra
	_ui_sys.show_playing_chrome()
	_race_sys.update_camera()
	_race_sys.update_hud()
	_race_sys.start_bgm()



func _along_overlap(dist: float, lateral: float, dz: float, dx: float) -> bool:
	return absf(dist - _progress) <= dz and absf(lateral - _lane_x) <= dx



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
	_platforms.clear()
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
	_track_sys.build_path_and_track()
	_track_sys.scatter_props()
	_finish_sys.spawn_stairs()
	_track_sys.spawn_clouds()



func _on_level_chosen(level_id: int) -> void:
	_ui_sys.dismiss_level_select()
	_track_sys.load_level_bundle(level_id)
	await _prepare_level_assets()
	_rebuild_level_world()
	_start_stack_game()


func _prepare_level_assets() -> void:
	if _cdn_sys == null or not _cdn_sys.is_enabled():
		return
	_ui_sys.show_cdn_loading()
	await _cdn_sys.preload_for_theme(_theme_cfg, _character_id)
	_ui_sys.hide_cdn_loading()


func _is_race() -> bool:
	return _race_sys.is_race()


func _current_run_speed() -> float:
	return _race_sys.current_run_speed()


func _play_capy_clip(visual: Node, clip_keys: Array, loop: bool = true) -> void:
	_stack_sys.play_capy_clip(visual, clip_keys, loop)


func _character_yaw() -> float:
	return _stack_sys.character_yaw()


func _character_model_path() -> String:
	return _stack_sys.character_model_path()


func _character_display_name() -> String:
	return _stack_sys.character_display_name()


func reload_game_scene() -> void:
	## 不用 reload_current_scene：编辑器 Game 视图里 current_scene 可能不是 SceneTree
	var tree := get_tree()
	if tree == null:
		return
	var path := scene_file_path
	if path.is_empty():
		path = "res://assets/maps/route_levels/capybara_rush/capybara_rush.tscn"
	tree.call_deferred("change_scene_to_file", path)


func _repack_stack_heights() -> void:
	_stack_sys.repack_stack_heights()


func _snap_actor_feet_to_world_y(actor: Node3D, target_y: float) -> void:
	_stack_sys.snap_actor_feet_to_world_y(actor, target_y)


func _instance_fitted(path: String, target_height: float, yaw: float = 0.0, start_anim: String = "run") -> Node3D:
	return _stack_sys.instance_fitted(path, target_height, yaw, start_anim)


func _path_place(node: Node3D, dist: float, lateral: float, y: float, yaw_extra: float = 0.0) -> void:
	_track_sys.path_place(node, dist, lateral, y, yaw_extra)


func _is_soft_skin_character(char_id: String = "") -> bool:
	return _stack_sys.is_soft_skin_character(char_id)


func _is_violent_move() -> bool:
	return _stack_sys.is_violent_move()


func _is_moving_for_drop() -> bool:
	return _stack_sys.is_moving_for_drop()


func _play_sfx_fruit() -> void:
	_race_sys.play_sfx_fruit()


func _play_sfx_hit() -> void:
	_race_sys.play_sfx_hit()


func _play_sfx_pickup() -> void:
	_race_sys.play_sfx_pickup()


func _stop_bgm(fade_sec: float = 0.35) -> void:
	_race_sys.stop_bgm(fade_sec)


func _fruit_coin_value(kind: String) -> int:
	return _world_sys.fruit_coin_value(kind)


func _is_frost_theme() -> bool:
	return _world_sys.is_frost_theme()


func _resnap_character_feet(visual: Node3D, measure_keys: Array = ["run", "idle"]) -> void:
	_stack_sys._resnap_character_feet(visual, measure_keys)


func _finish_pickup_under_anim(incoming: Node3D, old_layers: Array[Node3D]) -> void:
	_stack_sys.finish_pickup_under_anim(incoming, old_layers)


func _disable_subtree_shadows(root: Node) -> void:
	_track_sys._disable_subtree_shadows(root)


func _foot_lift_for_path(path: String) -> float:
	return _stack_sys._foot_lift_for_path(path)


func _find_meshes(node: Node) -> Array:
	return _stack_sys._find_meshes(node)


func _near_cliff_zone(dist: float, margin: float = TRAMPOLINE_APPROACH_MARGIN) -> bool:
	return _world_sys.near_cliff_zone(dist, margin)


func _pick_rigged_or_base(rigged: String, base: String) -> String:
	return _stack_sys.pick_rigged_or_base(rigged, base)


func _find_skeleton(node: Node) -> Skeleton3D:
	return _stack_sys.find_skeleton(node)


func _local_aabb(root: Node3D) -> AABB:
	return _stack_sys.local_aabb(root)


func _fruit_pool_for_level() -> Array[String]:
	return _world_sys.fruit_pool_for_level()


func _make_fruit_visual(kind: String) -> Node3D:
	return _world_sys.make_fruit_visual(kind)


func _mute_animation_players(node: Node) -> void:
	_stack_sys.mute_animation_players(node)


func _ensure_ice_parallax_textures() -> void:
	_track_sys.ensure_ice_parallax_textures()
