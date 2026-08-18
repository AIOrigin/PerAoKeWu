class_name CapybaraRace
extends RefCounted

## 竞速模式、相机、HUD、音频

const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")

const LANE_COUNT := 3
const RUN_SPEED := 12.0
const RACE_RUN_SPEED := 13.5
const ROAD_SURFACE_Y := 0.09
const BOOST_SPEED_MUL := 1.32
const BOOST_DURATION := 5.0
const BOOST_HIT_PENALTY := 1.0
const BOOST_PACK_BONUS := 0.5
const BOOST_MAX_TIME := 12.0
const SPEED_ORB_MUL := 1.18
const SPEED_LANE_MUL := 1.48
const TRAMPOLINE_AIR_SPEED_MUL := 1.45
const TARGET_CAPY_HEIGHT := 0.92
const TARGET_PILOT_HEIGHT := 1.55
const STACK_STEP_Y := 0.88
const SPACESHIP_FORWARD_YAW := 0.0
const MODE_RACE := "race"
const MODE_STACK := "stack"
const ENABLE_MOVE_DROP := false
const MIN_STACK_TO_DROP := 3
const HIGH_STACK_THRESHOLD := 8
const PILOT_FORWARD_YAW := 0.0
## 叠高时相机缓拉远/抬高，避免塔顶视角过高
const CAM_STACK_DIST_BASE := 9.0
const CAM_STACK_DIST_SCALE := 0.58
const CAM_STACK_DIST_MAX := 14.8
const CAM_STACK_Y_BASE := 3.35
const CAM_STACK_Y_SCALE := 0.26
const CAM_STACK_Y_MAX := 5.6
const CAM_LOOK_LIFT_BASE := TARGET_CAPY_HEIGHT * 0.26
const CAM_LOOK_LIFT_SCALE := 0.34
const CAM_LOOK_LIFT_MAX := 4.8
const CAM_FOV_STACK_MIN := 50.0
const CAM_FOV_STACK_MAX := 70.0
const CAM_FOV_STACK_REF := 6.2

var _host: Node


func _init(host: Node) -> void:
	_host = host


func setup_audio() -> void:
	_setup_audio()


func setup_camera() -> void:
	_setup_camera()


func update_camera() -> void:
	_update_camera()


func update_hud() -> void:
	_update_hud()


func current_run_speed() -> float:
	return _current_run_speed()


func is_race() -> bool:
	return _is_race()


func update_boost(delta: float) -> void:
	_update_boost(delta)


func start_bgm() -> void:
	_start_bgm()


func stop_bgm(fade_sec: float = 0.35) -> void:
	_stop_bgm(fade_sec)


func play_sfx_fruit() -> void:
	_play_sfx_fruit()


func play_sfx_hit() -> void:
	_play_sfx_hit()


func play_sfx_pickup() -> void:
	_play_sfx_pickup()


func spawn_race_runner() -> void:
	_spawn_race_runner()


func spawn_spaceships() -> void:
	_spawn_spaceships()


func spawn_boost_packs() -> void:
	_spawn_boost_packs()


func try_collect_spaceships() -> void:
	_try_collect_spaceships()


func try_collect_boost_packs() -> void:
	_try_collect_boost_packs()


func update_boost_pack_bob() -> void:
	_update_boost_pack_bob()


func try_hit_hazards_race() -> void:
	_try_hit_hazards_race()



func _current_run_speed() -> float:
	var base := RACE_RUN_SPEED if _is_race() else float(_host._level_cfg.get("run_speed", RUN_SPEED))
	var mul := 1.0
	if _is_race() and _host._boosting:
		mul *= BOOST_SPEED_MUL
	if _host._speed_buff_left > 0.0:
		mul *= SPEED_ORB_MUL
	if _host._on_speed_lane:
		mul *= _host._world_sys._speed_lane_mul()
	# 弹床越崖：空中额外前进，避免刚够/不够落在缺口里
	if _host._cliff_from_trampoline and not _host._grounded:
		mul *= TRAMPOLINE_AIR_SPEED_MUL
	return base * mul


func _is_race() -> bool:
	return _host._game_mode == MODE_RACE


func _setup_audio() -> void:
	## 路径见 CapybaraRushPaths；缺文件时静默跳过，不阻断开玩
	_host._stream_bgm = _load_audio_stream(CapybaraRushPaths.BGM_RUN)
	_host._stream_fruit = _load_audio_stream(CapybaraRushPaths.SFX_FRUIT)
	_host._stream_hit = _load_audio_stream(CapybaraRushPaths.SFX_HIT)
	_host._stream_pickup = _load_audio_stream(CapybaraRushPaths.SFX_PICKUP)

	_host._bgm_player = AudioStreamPlayer.new()
	_host._bgm_player.name = "BgmPlayer"
	_host._bgm_player.bus = "Master"
	_host._bgm_player.volume_db = -10.0
	_host.add_child(_host._bgm_player)

	_host._sfx_player = AudioStreamPlayer.new()
	_host._sfx_player.name = "SfxPlayer"
	_host._sfx_player.bus = "Master"
	_host._sfx_player.volume_db = -2.0
	_host.add_child(_host._sfx_player)


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
	if _host._bgm_player == null or _host._stream_bgm == null:
		return
	if _host._stream_bgm is AudioStreamWAV:
		(_host._stream_bgm as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	elif _host._stream_bgm is AudioStreamOggVorbis:
		(_host._stream_bgm as AudioStreamOggVorbis).loop = true
	_host._bgm_player.stream = _host._stream_bgm
	_host._bgm_player.volume_db = -10.0
	if not _host._bgm_player.playing:
		_host._bgm_player.play()


func _stop_bgm(fade_sec: float = 0.35) -> void:
	if _host._bgm_player == null or not _host._bgm_player.playing:
		return
	if fade_sec <= 0.001:
		_host._bgm_player.stop()
		return
	var from_db: float = _host._bgm_player.volume_db
	var tw := _host.create_tween()
	tw.tween_property(_host._bgm_player, "volume_db", -40.0, fade_sec)
	tw.tween_callback(func() -> void:
		if _host._bgm_player != null:
			_host._bgm_player.stop()
			_host._bgm_player.volume_db = from_db
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
	_host.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


func _play_sfx_fruit() -> void:
	_play_sfx(_host._stream_fruit, randf_range(0.94, 1.08))


func _play_sfx_hit() -> void:
	_play_sfx(_host._stream_hit, randf_range(0.92, 1.05))


func _play_sfx_pickup() -> void:
	_play_sfx(_host._stream_pickup, randf_range(0.96, 1.06))


func _spawn_race_runner() -> void:
	_host._tower = Node3D.new()
	_host._tower.name = "RaceRunner"
	_host._world.add_child(_host._tower)
	_set_race_visual(false)


func _set_race_visual(as_pilot: bool) -> void:
	if _host._tower == null:
		return
	for c in _host._tower.get_children():
		c.queue_free()
	_host._stack.clear()
	_host._race_visual = null
	var visual: Node3D
	if as_pilot:
		visual = _host._instance_fitted(CapybaraRushPaths.CAPYBARA_PILOT, TARGET_PILOT_HEIGHT, PILOT_FORWARD_YAW)
		if visual == null:
			visual = _make_stub_pilot()
			if visual:
				visual.rotation.y = PILOT_FORWARD_YAW
	else:
		visual = _host._stack_sys.make_capy_visual()
	if visual == null:
		return
	# 与叠塔一致：直接挂 fitted wrap，避免 holder 再叠一层朝向
	visual.position = Vector3.ZERO
	_host._tower.add_child(visual)
	_host._stack.append(visual)
	_host._race_visual = visual


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
	var capy: Node3D = _host._stack_sys.make_capy_visual()
	if capy:
		capy.scale = Vector3.ONE * 0.55
		capy.position = Vector3(0.0, 0.75, 0.1)
		root.add_child(capy)
	return root


func _spawn_spaceships() -> void:
	var z := 40.0
	var i := 0
	var track_len: float = _host._track_len()
	while z < track_len - 40.0:
		var lane := (i * 2) % LANE_COUNT
		var lateral: float = _host._lane_to_x(lane)
		var visual: Node3D = _host._instance_fitted(CapybaraRushPaths.SPACESHIP, 1.25, SPACESHIP_FORWARD_YAW)
		if visual == null:
			visual = _make_stub_spaceship()
		var holder := Node3D.new()
		_host._world.add_child(holder)
		_host._track_sys.path_place(holder, z, lateral, 0.15, 0.0)
		holder.add_child(visual)
		_host._spaceships.append({"node": holder, "lane": lane, "dist": z, "lateral": lateral, "taken": false})
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
	var track_len: float = _host._track_len()
	while z < track_len - 35.0:
		var lane := (i + 1) % LANE_COUNT
		var lateral: float = _host._lane_to_x(lane)
		var visual: Node3D = _host._instance_fitted(CapybaraRushPaths.BOOST_PACK, 0.95, 0.0)
		if visual == null:
			visual = _make_stub_boost_pack()
		var holder := Node3D.new()
		holder.visible = false
		_host._world.add_child(holder)
		_host._track_sys.path_place(holder, z, lateral, 0.2, 0.0)
		holder.add_child(visual)
		_host._boost_packs.append({
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
	for p in _host._boost_packs:
		if bool(p.get("taken", false)):
			continue
		var node: Node3D = p.get("node")
		if node != null and is_instance_valid(node):
			node.visible = on


func _update_boost(delta: float) -> void:
	if not _host._boosting:
		return
	_host._boost_time_left = maxf(_host._boost_time_left - delta, 0.0)
	if _host._boost_time_left <= 0.001:
		_end_boost()


func _start_boost(add_sec: float) -> void:
	var was: bool = _host._boosting
	_host._boost_time_left = minf(_host._boost_time_left + add_sec, BOOST_MAX_TIME)
	_host._boosting = _host._boost_time_left > 0.0
	if _host._boosting and not was:
		_set_race_visual(true)
		_set_boost_packs_visible(true)


func _end_boost() -> void:
	_host._boosting = false
	_host._boost_time_left = 0.0
	_set_race_visual(false)
	_set_boost_packs_visible(false)


func _try_collect_spaceships() -> void:
	for s in _host._spaceships:
		if bool(s.get("taken", false)):
			continue
		var node: Node3D = s.get("node")
		if node == null or not is_instance_valid(node):
			continue
		if not _host._along_overlap(float(s.get("dist", -999.0)), float(s.get("lateral", 0.0)), 1.2, 1.15):
			continue
		s["taken"] = true
		_host._ship_count += 1
		node.visible = false
		_start_boost(BOOST_DURATION)


func _try_collect_boost_packs() -> void:
	if not _host._boosting:
		return
	for p in _host._boost_packs:
		if bool(p.get("taken", false)):
			continue
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node) or not node.visible:
			continue
		if not _host._along_overlap(float(p.get("dist", -999.0)), float(p.get("lateral", 0.0)), 1.0, 1.0):
			continue
		p["taken"] = true
		_host._boost_pack_count += 1
		node.visible = false
		_start_boost(BOOST_PACK_BONUS)


func _update_boost_pack_bob() -> void:
	if not _host._boosting:
		return
	var t := Time.get_ticks_msec() * 0.001
	for p in _host._boost_packs:
		if bool(p.get("taken", false)):
			continue
		var node: Node3D = p.get("node")
		if node == null or not is_instance_valid(node) or not node.visible:
			continue
		var phase: float = float(p.get("phase", 0.0))
		node.position.y = 0.25 + sin(t * 4.0 + phase) * 0.12
		node.rotation.y = t * 1.6 + phase


func _try_hit_hazards_race() -> void:
	for h in _host._hazard_sys.items:
		if bool(h.get("hit", false)):
			continue
		if _host._hazard_sys.overlap(h, _host._progress, _host._lane_x, _host._air_y) == false:
			continue
		if _host._world_sys.is_airborne_clear(CapybaraHazards.hit_top(h)):
			continue
		h["hit"] = true
		_host._collision_count += 1
		_host._play_sfx_hit()
		if _host._boosting:
			_host._boost_time_left = maxf(_host._boost_time_left - BOOST_HIT_PENALTY, 0.0)
			if _host._boost_time_left <= 0.001:
				_end_boost()
		_host._sway = minf(_host._sway + 0.9, 2.5)
		# 障碍物保持原地，不被撞飞


func _setup_camera() -> void:
	_host._cam = Camera3D.new()
	_host._cam.fov = 52.0
	_host._cam.near = 0.1
	_host._cam.far = 220.0
	_host.add_child(_host._cam)
	_host._cam.current = true
	if _host._tower:
		var base: Vector3 = _host._tower.global_position + Vector3(0.0, TARGET_CAPY_HEIGHT * 0.4, 0.0)
		var ang := deg_to_rad(15.0)
		var back := 8.0
		# 角色朝 +Z 时，其右侧为 -X
		_host._cam.global_position = base + Vector3(-sin(ang) * back, 3.2, -cos(ang) * back)
	_update_camera()


func _update_camera() -> void:
	if _host._cam == null or _host._tower == null:
		return
	var base_y := TARGET_PILOT_HEIGHT * 0.35 if (_is_race() and _host._boosting) else TARGET_CAPY_HEIGHT * 0.4
	var base: Vector3 = _host._tower.global_position + Vector3(0.0, base_y, 0.0)
	var raw_stack_h := 0.0 if _is_race() else float(maxi(_host._stack.size() - 1, 0)) * STACK_STEP_Y
	# 叠层越高增益越弱，避免几十层高时变成鸟瞰
	var stack_h := sqrt(raw_stack_h * 1.25) if raw_stack_h > 0.001 else 0.0
	var dist := clampf(CAM_STACK_DIST_BASE + stack_h * CAM_STACK_DIST_SCALE, CAM_STACK_DIST_BASE, CAM_STACK_DIST_MAX)
	var cam_y := clampf(CAM_STACK_Y_BASE + stack_h * CAM_STACK_Y_SCALE, CAM_STACK_Y_BASE, CAM_STACK_Y_MAX)
	var look_lift := clampf(
		CAM_LOOK_LIFT_BASE + stack_h * CAM_LOOK_LIFT_SCALE,
		CAM_LOOK_LIFT_BASE,
		CAM_LOOK_LIFT_MAX
	)
	if _is_race() and _host._boosting:
		dist += 0.8
		cam_y += 0.35
	var ang := deg_to_rad(15.0)
	var desired: Vector3
	var look: Vector3
	if _host._path != null:
		var f: Dictionary = _host._path.frame_at(_host._progress)
		var tangent: Vector3 = f["tangent"]
		var right: Vector3 = f["right"]
		# 右后方：-tangent 为后，-right 为角色右侧（与旧直线赛道一致）
		desired = base - tangent * (dist * cos(ang)) - right * (dist * sin(ang)) + Vector3(0.0, cam_y, 0.0)
		look = base + tangent * 8.0 + Vector3(0.0, look_lift, 0.0)
	else:
		desired = base + Vector3(-sin(ang) * dist, cam_y, -cos(ang) * dist)
		look = base + Vector3(0.0, look_lift, 8.0)
	_host._cam.global_position = _host._cam.global_position.lerp(desired, 0.14)
	_host._cam.look_at(look, Vector3.UP)
	if _is_race():
		_host._cam.fov = lerpf(52.0, 66.0, 1.0 if _host._boosting else 0.0)
	else:
		_host._cam.fov = lerpf(
			CAM_FOV_STACK_MIN,
			CAM_FOV_STACK_MAX,
			clampf(stack_h / CAM_FOV_STACK_REF, 0.0, 1.0)
		)




func _update_hud() -> void:
	if _host._hud_label == null or _host._finished:
		return
	if _host._speed_buff_left > 0.0 and _host._hud_tip:
		_host._hud_tip.text = "加速中 %.1fs" % _host._speed_buff_left
	_host._ui_sys.update_play_hud()


