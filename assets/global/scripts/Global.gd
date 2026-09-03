#class_name Global Code
extends Node

signal main_player_ready
signal global_scenes_ready
signal sky_limit_ready

const explod_max_speed: float = 100.0 ## m
const default_gravity: float = 9.8
const Hl = preload("res://assets/global/scripts/HL.gd")
const MOBILE_PROGRESS_SAVE_PATH := "user://mobile_progress.json"
const MOBILE_PROGRESS_VERSION := 6
const CharacterProgression = preload("res://assets/maps/route_levels/character_progression.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")
const DEFAULT_OUTPOST_REPAIR_TOTAL := 400


###
# 旧 FPS 全局场景已移除；跑酷只依赖下方进度字段
###
var GLOBAL_SCENES_LIST_START = "GLOBAL_SCENES_LIST_START"
var GLOBAL_SCENES_LIST_END = "GLOBAL_SCENES_LIST_END"
###
var global_scenes_list: Array = []


# 其他
var main_player = null
var main_player_camera = null
var sky_limit = null
var runner_planet_id: String = "glass_desert"
var exploration_planet_id: String = "glass_desert"
var runner_location_id: String = "dome"
var runner_mission_id: String = ""
## 预览据点「试玩」：可跑酷，但不计入任务进度 / 点亮 / 领奖
var runner_trial_run: bool = false
## 跑酷结束后回到的场景；空则回探索地图
var runner_return_scene: String = ""
## 跑酷跑道外观（进关前选择，与背景独立）
var runner_road_style: String = "holographic"
## 跑酷场景背景（天空 + 两侧地形，与跑道独立）
var runner_background_style: String = "desert_crystal"
var selected_ship_id: String = "spark_moth"
var selected_character_id: String = "elsa"
var mobile_home_tab: String = "home"
var pending_location_showcase_id: String = ""
## Tasks「点亮XX」跳转地图后，聚焦闪烁的 location_id（仪式完成或取消后清空）
var pending_map_light_focus: String = ""
## planet_id -> Array[String] 已完成点亮仪式（雾气退散）的据点
var map_light_ceremony_done_by_planet: Dictionary = {}
## planet_id -> Array[String] 据点点亮奖励待领取 / 已领取
var outpost_light_rewards_pending_by_planet: Dictionary = {}
var outpost_light_rewards_claimed_by_planet: Dictionary = {}
var first_launch_story_seen: bool = false
var opening_comic_seen: bool = false
var home_guide_seen: bool = false
var transport_intro_seen: bool = false
## 跑酷新手引导总开关（设置里可关）
var runner_tutorial_enabled: bool = true
## UI 语言：zh / en（设置里切换；重置进度时保留）
var ui_locale: String = "zh"
## 开发测试：全解锁模式（解锁全部据点批次，详情页展示全部负责人立绘）
var dev_full_unlock: bool = false
## 分项：jump / slide / lane / shield / fork / sandstorm / wall_run
var runner_tutorial_seen: Dictionary = {}
## 兼容旧字段
var runner_wall_run_tutorial_seen: bool = false

const HOME_BGM_PATH := "res://assets/audio/music/ember_runners.mp3"
const RUNNER_BGM_PATH := "res://assets/audio/music/never_stop_running.mp3"
const DOME_BGM_PATH := "res://assets/audio/music/my_people.mp3"
const MEDICAL_BGM_PATH := "res://assets/audio/music/medical_rooftop_bounce.mp3"
const GATE_BGM_PATH := "res://assets/audio/music/parkour_leap.mp3"
const RELAY_BGM_PATH := "res://assets/audio/music/heavy_wall_echo.mp3"
const HOME_BGM_DB := -8.0
const RUNNER_BGM_DB := -6.0
const BGM_FADE_OUT_DB := -48.0
## 跑酷曲拍速（Never Stop Running）；与光晕律动对齐，可微调
const RUNNER_BGM_BPM := 128.0
const DOME_BGM_BPM := 118.0
const HOME_BGM_BPM := 112.0
const RUNNER_BGM_BEAT_OFFSET_SEC := 0.06
const DOME_BGM_BEAT_OFFSET_SEC := 0.0
## 距曲末 N 秒启动下一遍，掩盖 MP3 尾音拖腔
const DOME_BGM_LOOP_LEAD_SEC := 2.5
const HOME_BGM_BEAT_OFFSET_SEC := 0.0
const SFX_SHATTER_PATH := "res://assets/audio/sfx/obstacle_shatter.wav"
var _music_player: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _bgm_primary_is_a := true
var _bgm_overlap_armed := false
var _sfx_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_pool_index := 0
const SFX_POOL_SIZE := 8
var _sfx_shatter_stream: AudioStream
var _music_mode := ""
var _active_bgm_path := ""
var _music_fade_tween: Tween
var _bgm_spectrum = null
var _bgm_bass_smooth := 0.0
var bgm_enabled: bool = true
var bgm_volume: float = 0.72
var sfx_volume: float = 0.9

var ember_coins: int = 0
var gold_coins: int = 1280
var runner_energy: int = 86
var runner_energy_max: int = 120
## 角色体力（跨关持久；碰撞微扣，完整度归零才本关失败）
var runner_hp: float = 100.0
var runner_hp_max: float = 100.0
var messenger_xp: int = 0
var messenger_cargo_guard_level: int = 0
var messenger_coin_bonus_level: int = 0
var messenger_mobility_level: int = 0
var messenger_unlocked_stories: Array[String] = []
var exploration_revealed_locations_by_planet: Dictionary = {}
var completed_runner_locations_by_planet: Dictionary = {}
# planet_id -> { location_id: int }  据点运输累计进度（装载量×完整度%）
var runner_outpost_progress_by_planet: Dictionary = {}
## planet_id -> mission_id -> 累计进度（单任务目标通常 100）
var runner_mission_progress_by_planet: Dictionary = {}
## planet_id -> Array[String] 已完成 mission_id
var completed_missions_by_planet: Dictionary = {}
## planet_id -> Array[String] 已完成但未领取奖励的 mission_id
var mission_rewards_pending_by_planet: Dictionary = {}
## planet_id -> Array[String] 已领取完成奖励的 mission_id
var mission_rewards_claimed_by_planet: Dictionary = {}
# planet_id -> Array[String]  任务板 4 槽（mission_id，两据点交错）
var mission_board_slots_by_planet: Dictionary = {}
# planet_id -> int  已解锁到第几批（1/2/3）
var unlocked_mission_batch_by_planet: Dictionary = {}
# planet_id -> { "location_id": String }  当前指派/进行中的运输任务
var active_missions_by_planet: Dictionary = {}
var accepted_missions_by_planet: Dictionary = {}
## 每日任务：YYYY-MM-DD / task_id -> progress / 已领取 task_id
var daily_tasks_date := ""
var daily_task_progress: Dictionary = {}
var daily_tasks_claimed: Array[String] = []

var paused_time_process: float = 0.0
var paused_time_physics_process: float = 0.0

var gravity_value: float
var gravity_vector: Vector3
var gravity: Vector3:
	get():
		return gravity_vector * gravity_value


func _ready() -> void:
	load_mobile_progress()
	ensure_mission_dispatch_ready("glass_desert")
	gravity_value = ProjectSettings.get_setting("physics/3d/default_gravity")
	gravity_vector = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	_setup_game_music()


func _notification(what: int) -> void:
	# Windows WASAPI 在休眠/换输出设备后会 invalidate；焦点回来时尝试续播 BGM
	if what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_WM_WINDOW_FOCUS_IN]:
		call_deferred("_recover_audio_after_device_change")
	# 停止调试/退出前先停音频，减轻 WASAPI GetBufferSize 报错
	if what in [NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_PREDELETE]:
		_shutdown_audio_output()


func _ensure_resource_uid_registered(path: String) -> void:
	# 新导入的 mp3 可能还没进 uid_cache，load/exists 会报 Unrecognized UID
	if path.strip_edges() == "":
		return
	var uid := ResourceLoader.get_resource_uid(path)
	if uid == ResourceUID.INVALID_ID or ResourceUID.has_id(uid):
		return
	ResourceUID.add_id(uid, path)


func _setup_game_music() -> void:
	_ensure_resource_uid_registered(HOME_BGM_PATH)
	_ensure_resource_uid_registered(RUNNER_BGM_PATH)
	_ensure_resource_uid_registered(DOME_BGM_PATH)
	_ensure_resource_uid_registered(MEDICAL_BGM_PATH)
	_ensure_resource_uid_registered(GATE_BGM_PATH)
	_ensure_resource_uid_registered(RELAY_BGM_PATH)
	if _music_player != null and is_instance_valid(_music_player):
		return
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "GameMusicPlayer"
	_music_player.bus = "Music" if AudioServer.get_bus_index("Music") >= 0 else "Master"
	add_child(_music_player)
	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.name = "GameMusicPlayerB"
	_music_player_b.bus = "Music" if AudioServer.get_bus_index("Music") >= 0 else "Master"
	add_child(_music_player_b)
	if not _music_player.finished.is_connected(_on_bgm_finished):
		_music_player.finished.connect(_on_bgm_finished)
	if not _music_player_b.finished.is_connected(_on_bgm_finished):
		_music_player_b.finished.connect(_on_bgm_finished)
	_apply_bgm_volume()


func _active_bgm_player() -> AudioStreamPlayer:
	return _music_player if _bgm_primary_is_a else _music_player_b


func _inactive_bgm_player() -> AudioStreamPlayer:
	return _music_player_b if _bgm_primary_is_a else _music_player


func _on_bgm_finished() -> void:
	if not bgm_enabled:
		return
	var player := _active_bgm_player()
	if player == null or not is_instance_valid(player):
		return
	# My People 系（穹顶 / 医疗）用提前叠播；其它曲目仍立即重播
	if _is_my_people_style_bgm(_active_bgm_path):
		if not _bgm_overlap_armed:
			_queue_bgm_overlap_loop()
		return
	if _music_mode == "" or _active_bgm_path == "":
		return
	var keep_db := player.volume_db
	player.play(0.0)
	player.volume_db = keep_db


func _queue_bgm_overlap_loop() -> void:
	if _active_bgm_path == "" or not bgm_enabled:
		return
	var stream := _load_looped_bgm(_active_bgm_path, true)
	if stream == null:
		return
	var lead := DOME_BGM_LOOP_LEAD_SEC
	var main := _active_bgm_player()
	var alt := _inactive_bgm_player()
	if main == null or alt == null:
		return
	_bgm_overlap_armed = true
	alt.stream = stream
	var target_db := _bgm_target_db(_music_mode)
	alt.volume_db = target_db - 12.0
	alt.play(0.0)
	_kill_bgm_fade()
	_music_fade_tween = create_tween()
	_music_fade_tween.set_parallel(true)
	_music_fade_tween.tween_property(main, "volume_db", BGM_FADE_OUT_DB, lead)
	_music_fade_tween.tween_property(alt, "volume_db", target_db, lead * 0.55)
	_music_fade_tween.chain().tween_callback(func() -> void:
		if is_instance_valid(main):
			main.stop()
		_bgm_primary_is_a = not _bgm_primary_is_a
		_bgm_overlap_armed = false
	)


func _tick_bgm_early_loop() -> void:
	if not bgm_enabled or _music_mode != "runner" or not _is_my_people_style_bgm(_active_bgm_path):
		_bgm_overlap_armed = false
		return
	var player := _active_bgm_player()
	if player == null or not player.playing or player.stream == null:
		return
	var length := float(player.stream.get_length())
	if length < 5.0:
		return
	var pos := maxf(player.get_playback_position(), 0.0)
	var remaining := length - pos
	if remaining > DOME_BGM_LOOP_LEAD_SEC:
		return
	if _bgm_overlap_armed:
		return
	_queue_bgm_overlap_loop()


func _ensure_bgm_spectrum() -> void:
	# Music 总线频谱（预挂在 default_bus_layout），供信使光晕跟低音律动
	var bus_idx := AudioServer.get_bus_index("Music")
	if bus_idx < 0:
		bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx < 0:
		return
	var effect_idx := -1
	for i in AudioServer.get_bus_effect_count(bus_idx):
		if AudioServer.get_bus_effect(bus_idx, i) is AudioEffectSpectrumAnalyzer:
			effect_idx = i
			break
	if effect_idx < 0:
		return
	_bgm_spectrum = AudioServer.get_bus_effect_instance(bus_idx, effect_idx) as AudioEffectSpectrumAnalyzerInstance


func get_bgm_mode() -> String:
	return _music_mode


func is_bgm_playing() -> bool:
	if not bgm_enabled:
		return false
	for p in [_music_player, _music_player_b]:
		if p != null and is_instance_valid(p) and p.playing:
			return true
	return false


func get_bgm_playback_sec() -> float:
	if not is_bgm_playing():
		return 0.0
	var player := _active_bgm_player()
	if player == null or not player.playing:
		return 0.0
	return maxf(player.get_playback_position(), 0.0)


func get_bgm_bpm() -> float:
	if _music_mode == "runner":
		if _is_my_people_style_bgm(_active_bgm_path):
			return DOME_BGM_BPM
		return RUNNER_BGM_BPM
	return HOME_BGM_BPM


func get_bgm_beat_offset_sec() -> float:
	if _music_mode == "runner":
		if _is_my_people_style_bgm(_active_bgm_path):
			return DOME_BGM_BEAT_OFFSET_SEC
		return RUNNER_BGM_BEAT_OFFSET_SEC
	return HOME_BGM_BEAT_OFFSET_SEC


func is_dome_mission_id(mission_id: String) -> bool:
	return String(mission_id).begins_with("mission_dome_")


func is_medical_mission_id(mission_id: String) -> bool:
	return String(mission_id).begins_with("mission_medical_")


func is_gate_mission_id(mission_id: String) -> bool:
	return String(mission_id).begins_with("mission_gate_")


func is_relay_mission_id(mission_id: String) -> bool:
	return String(mission_id).begins_with("mission_relay_")


func _is_my_people_style_bgm(path: String) -> bool:
	return path == DOME_BGM_PATH or path == MEDICAL_BGM_PATH


func get_runner_bgm_path(mission_id: String = "") -> String:
	var key := String(mission_id if mission_id != "" else runner_mission_id)
	var want_medical := is_medical_mission_id(key) or (runner_location_id == "medical" and key != "")
	if want_medical:
		if ResourceLoader.exists(MEDICAL_BGM_PATH):
			return MEDICAL_BGM_PATH
		push_warning("Medical BGM missing at %s — using runner fallback" % MEDICAL_BGM_PATH)
		return RUNNER_BGM_PATH
	var want_dome := is_dome_mission_id(key) or (runner_location_id == "dome" and key != "")
	if want_dome:
		if ResourceLoader.exists(DOME_BGM_PATH):
			return DOME_BGM_PATH
		push_warning("Dome BGM missing at %s — using runner fallback" % DOME_BGM_PATH)
		return RUNNER_BGM_PATH
	var want_gate := is_gate_mission_id(key) or (runner_location_id == "gate" and key != "")
	if want_gate:
		_ensure_resource_uid_registered(GATE_BGM_PATH)
		if ResourceLoader.exists(GATE_BGM_PATH):
			return GATE_BGM_PATH
		push_warning("Gate BGM missing at %s — using runner fallback" % GATE_BGM_PATH)
		return RUNNER_BGM_PATH
	var want_relay := is_relay_mission_id(key) or (runner_location_id == "relay" and key != "")
	if want_relay:
		_ensure_resource_uid_registered(RELAY_BGM_PATH)
		if ResourceLoader.exists(RELAY_BGM_PATH):
			return RELAY_BGM_PATH
		push_warning("Relay BGM missing at %s — using runner fallback" % RELAY_BGM_PATH)
		return RUNNER_BGM_PATH
	return RUNNER_BGM_PATH


## 返回 { kick, pulse, bass, phase }：kick=拍点闪烁 0~1，pulse=综合律动倍率，bass=低音能量
func get_bgm_rhythm(delta: float = 0.016) -> Dictionary:
	var bpm := get_bgm_bpm()
	var beat_dur := 60.0 / maxf(bpm, 1.0)
	var t := get_bgm_playback_sec() - get_bgm_beat_offset_sec()
	if not is_bgm_playing():
		# 无 BGM 时保留轻柔假拍，避免光晕僵死
		t = Time.get_ticks_msec() * 0.001
	var phase := fposmod(t, beat_dur) / beat_dur
	# 拍点瞬间尖峰，随后衰减 → 闪烁跳动
	var kick := exp(-phase * 7.2)
	var eighth := fposmod(t * 2.0, beat_dur) / beat_dur
	var offbeat := exp(-eighth * 6.0) * 0.38
	# 不用实时频谱（低配 FFT 开销大）；用拍点合成低音感
	var bass := clampf(kick * 0.85 + offbeat * 0.35, 0.0, 1.0)
	_bgm_bass_smooth = lerpf(_bgm_bass_smooth, bass, 1.0 - exp(-12.0 * maxf(delta, 0.001)))
	var kick_flash := clampf(kick + offbeat * 0.55 + _bgm_bass_smooth * 0.35, 0.0, 1.35)
	var pulse := 0.82 + kick_flash * 0.48 + _bgm_bass_smooth * 0.18
	return {
		"kick": kick_flash,
		"pulse": pulse,
		"bass": _bgm_bass_smooth,
		"phase": phase,
	}


func _sample_bgm_bass_energy(delta: float) -> float:
	_ensure_bgm_spectrum()
	var target := 0.0
	if _bgm_spectrum != null and is_bgm_playing():
		var mag: Vector2 = _bgm_spectrum.get_magnitude_for_frequency_range(45.0, 160.0)
		var raw := (mag.x + mag.y) * 0.5
		# 线性化并抬到可见区间
		target = clampf((raw - 0.0008) * 55.0, 0.0, 1.0)
		# 再取一点中低频，增强鼓点感
		var mid: Vector2 = _bgm_spectrum.get_magnitude_for_frequency_range(160.0, 420.0)
		var mid_e := clampf((((mid.x + mid.y) * 0.5) - 0.0006) * 40.0, 0.0, 1.0)
		target = clampf(target * 0.72 + mid_e * 0.38, 0.0, 1.0)
	var follow := 14.0 if target > _bgm_bass_smooth else 7.0
	_bgm_bass_smooth = lerpf(_bgm_bass_smooth, target, 1.0 - exp(-follow * maxf(delta, 0.001)))
	return _bgm_bass_smooth


func _setup_sfx_player() -> void:
	if _sfx_pool.size() >= SFX_POOL_SIZE:
		return
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "GameSfxPlayer_%d" % i
		p.bus = "Master"
		p.max_polyphony = 1
		add_child(p)
		_sfx_pool.append(p)
	_sfx_player = _sfx_pool[0]
	_cache_shatter_streams()


func _cache_shatter_streams() -> void:
	# 允许热重载后重新读 wav
	if _sfx_shatter_stream != null:
		return
	if ResourceLoader.exists(SFX_SHATTER_PATH):
		_sfx_shatter_stream = load(SFX_SHATTER_PATH) as AudioStream


func reload_shatter_sfx() -> void:
	_sfx_shatter_stream = null
	_cache_shatter_streams()


func _next_sfx_player() -> AudioStreamPlayer:
	_setup_sfx_player()
	if _sfx_pool.is_empty():
		return null
	var p: AudioStreamPlayer = _sfx_pool[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % _sfx_pool.size()
	return p


## size_key: tiny / small / medium / large / huge
## 沉闷砰 + 哗啦碎 + 咔哧；体积越大越低沉越响
func play_sfx_shatter(pitch_scale: float = 1.0, heavy: bool = false, size_key: String = "") -> void:
	if sfx_volume <= 0.001:
		return
	_cache_shatter_streams()
	if _sfx_shatter_stream == null:
		return
	var key := size_key
	if key == "":
		key = "large" if heavy else "medium"
	var cfg := _shatter_size_config(key)
	var player := _next_sfx_player()
	if player == null:
		return
	var jitter := randf_range(-0.03, 0.03)
	var pitch := float(cfg.get("pitch", 0.92)) * pitch_scale + jitter
	player.stream = _sfx_shatter_stream
	player.pitch_scale = clampf(pitch, 0.55, 1.35)
	player.volume_db = linear_to_db(clampf(sfx_volume * float(cfg.get("vol", 1.15)), 0.001, 1.0))
	player.play(0.0)
	# 中大体积叠一层更低的「砰」体感
	if bool(cfg.get("boom_layer", false)):
		var boom := _next_sfx_player()
		if boom != null and boom != player:
			boom.stream = _sfx_shatter_stream
			boom.pitch_scale = clampf(pitch * float(cfg.get("boom_pitch_mult", 0.72)), 0.48, 0.95)
			boom.volume_db = linear_to_db(clampf(sfx_volume * float(cfg.get("boom_vol", 0.85)), 0.001, 1.0))
			boom.play(0.0)
	# 大体积再叠一层稍高的「哗啦/咔哧」碎屑
	if bool(cfg.get("crunch_layer", false)):
		var crunch := _next_sfx_player()
		if crunch != null and crunch != player:
			crunch.stream = _sfx_shatter_stream
			crunch.pitch_scale = clampf(pitch * float(cfg.get("crunch_pitch_mult", 1.12)), 0.85, 1.4)
			crunch.volume_db = linear_to_db(clampf(sfx_volume * float(cfg.get("crunch_vol", 0.48)), 0.001, 1.0))
			crunch.play(0.02)


func _shatter_size_config(size_key: String) -> Dictionary:
	match String(size_key):
		"tiny":
			return {"pitch": 1.18, "vol": 0.78, "boom_layer": false, "crunch_layer": false}
		"small":
			return {"pitch": 1.04, "vol": 0.95, "boom_layer": false, "crunch_layer": true, "crunch_pitch_mult": 1.18, "crunch_vol": 0.32}
		"large":
			return {
				"pitch": 0.78, "vol": 1.42,
				"boom_layer": true, "boom_pitch_mult": 0.68, "boom_vol": 0.95,
				"crunch_layer": true, "crunch_pitch_mult": 1.05, "crunch_vol": 0.55,
			}
		"huge":
			return {
				"pitch": 0.64, "vol": 1.58,
				"boom_layer": true, "boom_pitch_mult": 0.58, "boom_vol": 1.12,
				"crunch_layer": true, "crunch_pitch_mult": 0.98, "crunch_vol": 0.62,
			}
		_:
			return {
				"pitch": 0.9, "vol": 1.18,
				"boom_layer": true, "boom_pitch_mult": 0.74, "boom_vol": 0.72,
				"crunch_layer": true, "crunch_pitch_mult": 1.08, "crunch_vol": 0.42,
			}


func play_home_bgm(fade_sec: float = 1.05) -> void:
	if not bgm_enabled:
		stop_bgm(0.2)
		return
	_setup_game_music()
	if _music_mode == "home" and _music_player != null and _music_player.playing:
		_apply_bgm_volume()
		return
	_switch_bgm(HOME_BGM_PATH, true, _bgm_target_db("home"), fade_sec, "home", false)


func play_runner_bgm_from_start(fade_sec: float = 0.28) -> void:
	if not bgm_enabled:
		stop_bgm(0.15)
		return
	_setup_game_music()
	var path := get_runner_bgm_path()
	_switch_bgm(path, true, _bgm_target_db("runner"), fade_sec, "runner", true)


func stop_bgm(fade_sec: float = 0.45) -> void:
	_setup_game_music()
	if _music_player == null:
		return
	_music_mode = ""
	_active_bgm_path = ""
	_bgm_overlap_armed = false
	_kill_bgm_fade()
	var any_playing := is_bgm_playing()
	if fade_sec <= 0.001 or not any_playing:
		if _music_player != null:
			_music_player.stop()
		if _music_player_b != null:
			_music_player_b.stop()
		return
	var player := _active_bgm_player()
	_music_fade_tween = create_tween()
	_music_fade_tween.tween_property(player, "volume_db", BGM_FADE_OUT_DB, fade_sec)
	_music_fade_tween.tween_callback(func() -> void:
		if _music_player != null:
			_music_player.stop()
		if _music_player_b != null:
			_music_player_b.stop()
	)


func set_bgm_enabled(enabled: bool, persist: bool = true) -> void:
	bgm_enabled = enabled
	if not bgm_enabled:
		stop_bgm(0.25)
	elif _music_mode == "home":
		play_home_bgm(0.35)
	elif _music_mode == "runner":
		# 恢复时从当前位置附近续播感：直接淡入当前轨
		_setup_game_music()
		if _music_player != null and _music_player.stream != null:
			_music_player.volume_db = BGM_FADE_OUT_DB
			if not _music_player.playing:
				_music_player.play()
			_apply_bgm_volume(true)
		else:
			play_runner_bgm_from_start(0.35)
	else:
		play_home_bgm(0.4)
	if persist:
		save_mobile_progress()


func set_bgm_volume(linear_01: float, persist: bool = true) -> void:
	bgm_volume = clampf(linear_01, 0.0, 1.0)
	_apply_bgm_volume()
	if persist:
		save_mobile_progress()


func set_sfx_volume(linear_01: float, persist: bool = true) -> void:
	sfx_volume = clampf(linear_01, 0.0, 1.0)
	if persist:
		save_mobile_progress()


func _bgm_target_db(mode: String) -> float:
	var base := HOME_BGM_DB if mode == "home" else RUNNER_BGM_DB
	if not bgm_enabled or bgm_volume <= 0.001:
		return BGM_FADE_OUT_DB
	return base + linear_to_db(clampf(bgm_volume, 0.001, 1.0))


func _apply_bgm_volume(fade_in: bool = false) -> void:
	if _music_player == null:
		return
	if not bgm_enabled or bgm_volume <= 0.001:
		if _music_player != null:
			_music_player.volume_db = BGM_FADE_OUT_DB
		if _music_player_b != null:
			_music_player_b.volume_db = BGM_FADE_OUT_DB
		return
	var target := _bgm_target_db(_music_mode if _music_mode != "" else "home")
	var player := _active_bgm_player()
	if fade_in and player != null:
		_kill_bgm_fade()
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(player, "volume_db", target, 0.35)
	elif player != null:
		player.volume_db = target


func _switch_bgm(
	path: String,
	loop: bool,
	target_db: float,
	fade_sec: float,
	mode: String,
	force_restart: bool
) -> void:
	if _music_player == null:
		return
	if not bgm_enabled:
		if _music_player != null:
			_music_player.stop()
		if _music_player_b != null:
			_music_player_b.stop()
		_music_mode = mode
		return
	var player := _active_bgm_player()
	var same_track := _active_bgm_path == path and player != null and player.playing
	if _music_mode == mode and same_track and not force_restart:
		_apply_bgm_volume()
		return
	_kill_bgm_fade()
	var stream := _load_looped_bgm(path, loop)
	if stream == null:
		push_warning("BGM missing: %s" % path)
		return
	if _music_player.playing and fade_sec > 0.05:
		var out_t := mini(fade_sec * 0.55, 0.55)
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", BGM_FADE_OUT_DB, out_t)
		_music_fade_tween.tween_callback(func() -> void:
			_start_bgm_player(stream, target_db, fade_sec, mode, path)
		)
	else:
		call_deferred("_start_bgm_player", stream, target_db, fade_sec, mode, path)


func _start_bgm_player(
	stream: AudioStream,
	target_db: float,
	fade_sec: float,
	mode: String,
	path: String
) -> void:
	if _music_player == null or not is_instance_valid(_music_player):
		return
	_bgm_primary_is_a = true
	_bgm_overlap_armed = false
	if _music_player_b != null and is_instance_valid(_music_player_b):
		_music_player_b.stop()
	_music_player.stream = stream
	_music_player.volume_db = BGM_FADE_OUT_DB if fade_sec > 0.05 else target_db
	_music_player.play(0.0)
	_music_mode = mode
	_active_bgm_path = path
	if not _music_player.playing:
		call_deferred("_recover_audio_after_device_change")
	if fade_sec > 0.05:
		_kill_bgm_fade()
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", target_db, fade_sec)


func _recover_audio_after_device_change() -> void:
	if not bgm_enabled or _music_mode == "":
		return
	var saved_path := _active_bgm_path
	var saved_mode := _music_mode
	var saved_pos := 0.0
	var player := _active_bgm_player()
	if player != null and is_instance_valid(player) and player.playing:
		saved_pos = maxf(player.get_playback_position(), 0.0)
	_reopen_audio_output_device()
	_setup_game_music()
	if saved_path == "":
		return
	_switch_bgm(saved_path, true, _bgm_target_db(saved_mode), 0.22, saved_mode, true)
	player = _active_bgm_player()
	if player != null and is_instance_valid(player) and saved_pos > 0.15:
		player.seek(saved_pos)
	_apply_bgm_volume(true)


func _reopen_audio_output_device() -> void:
	_stop_all_sfx_immediate()
	if _music_player != null and is_instance_valid(_music_player):
		_music_player.stop()
	if _music_player_b != null and is_instance_valid(_music_player_b):
		_music_player_b.stop()
	var devices := AudioServer.get_output_device_list()
	if devices.is_empty():
		return
	var current := AudioServer.output_device
	var pick := current if current in devices else String(devices[0])
	if pick != current:
		AudioServer.output_device = pick
		return
	# 同设备再选一次，促使 WASAPI 重新打开输出
	AudioServer.output_device = ""
	AudioServer.output_device = pick


func _stop_all_sfx_immediate() -> void:
	for player in _sfx_pool:
		if player != null and is_instance_valid(player):
			player.stop()


func _shutdown_audio_output() -> void:
	_kill_bgm_fade()
	_stop_all_sfx_immediate()
	if _music_player != null and is_instance_valid(_music_player):
		_music_player.stop()
	if _music_player_b != null and is_instance_valid(_music_player_b):
		_music_player_b.stop()


func _load_looped_bgm(path: String, loop: bool) -> AudioStream:
	_ensure_resource_uid_registered(path)
	if not ResourceLoader.exists(path):
		return null
	var loaded := load(path)
	if loaded == null or not (loaded is AudioStream):
		return null
	var stream := (loaded as AudioStream).duplicate()
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	elif stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	return stream


func _kill_bgm_fade() -> void:
	if _music_fade_tween != null and is_instance_valid(_music_fade_tween):
		_music_fade_tween.kill()
	_music_fade_tween = null


func _process(_delta: float) -> void:
	if not get_tree().paused:
		paused_time_process += _delta
	_tick_bgm_early_loop()


func _physics_process(_delta: float) -> void:
	if not get_tree().paused:
		paused_time_physics_process += _delta


func _global_scenes_ready() -> void:
	paused_time_process = 0.0
	paused_time_physics_process = 0.0
	global_scenes_ready.emit()


func ready_global_scenes() -> void:
	# 旧 FPS 全局场景装配已移除
	pass


func reload_current_scene() -> void:
	get_tree().reload_current_scene()


func change_game_scene(scene_path: String) -> void:
	get_tree().paused = false
	_stop_all_sfx_immediate()
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to change scene: %s error=%s" % [scene_path, error])
		return
	call_deferred("_ready_global_scenes_after_scene_change")


func get_revealed_exploration_locations(planet_id: String, fallback_ids: Array[String]) -> Array[String]:
	# 地图可见 = 当前批次已开放的任务据点（与探索迷雾解耦，由 sync_mission_dispatch 维护）
	var stored_variant: Variant = exploration_revealed_locations_by_planet.get(planet_id, null)
	var source: Array = []
	if stored_variant == null or (stored_variant is Array and (stored_variant as Array).is_empty()):
		source = fallback_ids.duplicate()
	elif stored_variant is Array:
		source = stored_variant as Array
	var result: Array[String] = []
	for id in source:
		var location_id := String(id)
		if location_id != "" and not result.has(location_id):
			result.append(location_id)
	return result


func set_revealed_exploration_locations(planet_id: String, location_ids: Array[String]) -> void:
	var stored: Array[String] = []
	for location_id in location_ids:
		if location_id != "" and not stored.has(location_id):
			stored.append(location_id)
	exploration_revealed_locations_by_planet[planet_id] = stored
	save_mobile_progress()


func mark_runner_location_completed(planet_id: String, location_id: String) -> bool:
	if planet_id == "" or location_id == "":
		return false
	var completed: Array = completed_runner_locations_by_planet.get(planet_id, [])
	if completed.has(location_id):
		return false
	completed.append(location_id)
	completed_runner_locations_by_planet[planet_id] = completed
	queue_outpost_light_reward(planet_id, location_id)
	var repair_total := get_outpost_repair_total(planet_id, location_id)
	_set_outpost_progress_value(planet_id, location_id, repair_total)
	var active: Dictionary = get_active_mission(planet_id)
	if String(active.get("location_id", "")) == location_id:
		# 先清任务再同步派发，避免 sync 存盘时仍带着旧 active
		if active_missions_by_planet.has(planet_id):
			active_missions_by_planet.erase(planet_id)
	sync_mission_dispatch(planet_id)
	_sync_messenger_story_unlocks()
	return true


func is_map_light_ceremony_done(planet_id: String, location_id: String) -> bool:
	if planet_id == "" or location_id == "":
		return false
	return get_map_light_ceremony_done(planet_id).has(location_id)


func get_map_light_ceremony_done(planet_id: String) -> Array[String]:
	var stored: Array = map_light_ceremony_done_by_planet.get(planet_id, [])
	var result: Array[String] = []
	for value in stored:
		var text := String(value)
		if text != "" and not result.has(text):
			result.append(text)
	return result


func list_pending_light_ceremonies(planet_id: String) -> Array[String]:
	var pending: Array[String] = []
	for location_id in get_completed_runner_locations(planet_id):
		if not is_map_light_ceremony_done(planet_id, location_id):
			pending.append(location_id)
	return pending


func is_map_light_ceremony_pending(planet_id: String, location_id: String) -> bool:
	if planet_id == "" or location_id == "":
		return false
	return get_completed_runner_locations(planet_id).has(location_id) \
		and not is_map_light_ceremony_done(planet_id, location_id)


func complete_map_light_ceremony(planet_id: String, location_id: String) -> bool:
	if planet_id == "" or location_id == "":
		return false
	if not get_completed_runner_locations(planet_id).has(location_id):
		return false
	var done: Array = map_light_ceremony_done_by_planet.get(planet_id, [])
	if done.has(location_id):
		return false
	done.append(location_id)
	map_light_ceremony_done_by_planet[planet_id] = done
	if pending_map_light_focus == location_id:
		pending_map_light_focus = ""
	queue_outpost_light_reward(planet_id, location_id)
	save_mobile_progress()
	return true


func queue_outpost_light_reward(planet_id: String, location_id: String) -> void:
	if planet_id == "" or location_id == "":
		return
	if is_outpost_light_reward_claimed(planet_id, location_id):
		return
	var pending: Array = outpost_light_rewards_pending_by_planet.get(planet_id, []).duplicate()
	if not pending.has(location_id):
		pending.append(location_id)
		outpost_light_rewards_pending_by_planet[planet_id] = pending


func is_outpost_light_reward_pending(planet_id: String, location_id: String) -> bool:
	if planet_id == "" or location_id == "":
		return false
	if is_outpost_light_reward_claimed(planet_id, location_id):
		return false
	var pending: Array = outpost_light_rewards_pending_by_planet.get(planet_id, [])
	if pending.has(location_id):
		return true
	# 已点亮但尚未领取：视为可领（兼容旧存档）
	return get_completed_runner_locations(planet_id).has(location_id)


func is_outpost_light_reward_claimed(planet_id: String, location_id: String) -> bool:
	if planet_id == "" or location_id == "":
		return false
	var claimed: Array = outpost_light_rewards_claimed_by_planet.get(planet_id, [])
	return claimed.has(location_id)


func claim_outpost_light_reward(planet_id: String, location_id: String) -> Dictionary:
	var empty := {"coins": 0, "unlock_character": "", "character_unlocked": false}
	if not is_outpost_light_reward_pending(planet_id, location_id):
		return empty
	var coins := 0
	var unlock_character := ""
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_outpost_meta"):
		var meta: Dictionary = cfg.get_outpost_meta(location_id)
		coins = maxi(0, int(meta.get("reward_coins", 0)))
		unlock_character = String(meta.get("unlock_character", ""))
	var pending: Array = outpost_light_rewards_pending_by_planet.get(planet_id, []).duplicate()
	if pending.has(location_id):
		pending.erase(location_id)
		outpost_light_rewards_pending_by_planet[planet_id] = pending
	var claimed: Array = outpost_light_rewards_claimed_by_planet.get(planet_id, []).duplicate()
	if not claimed.has(location_id):
		claimed.append(location_id)
		outpost_light_rewards_claimed_by_planet[planet_id] = claimed
	var character_unlocked := false
	if unlock_character.to_lower() == "rook":
		var had_story := messenger_unlocked_stories.has("dome_resident")
		_unlock_messenger_story("dome_resident")
		character_unlocked = not had_story
	if coins > 0:
		add_ember_coins(coins)
	else:
		save_mobile_progress()
	return {
		"coins": coins,
		"unlock_character": unlock_character,
		"character_unlocked": character_unlocked,
	}


func reset_map_light_progress(planet_id: String = "glass_desert") -> void:
	if planet_id == "":
		planet_id = "glass_desert"
	if map_light_ceremony_done_by_planet.has(planet_id):
		map_light_ceremony_done_by_planet.erase(planet_id)
	pending_map_light_focus = ""
	# 保留据点完成状态，便于再次出现「点亮XX」测地图仪式
	save_mobile_progress()


func get_outpost_display_name(planet_id: String, location_id: String) -> String:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_outpost_meta"):
		var meta: Dictionary = cfg.get_outpost_meta(location_id)
		var localized := GameLocale.field(meta, "name", "name_en")
		if localized != "":
			return localized
	return location_id


func get_ui_locale() -> String:
	return "en" if ui_locale == "en" else "zh"


func set_ui_locale(locale: String) -> void:
	ui_locale = "en" if locale == "en" else "zh"
	save_mobile_progress()


func is_ui_english() -> bool:
	return get_ui_locale() == "en"


func get_outpost_progress(planet_id: String, location_id: String) -> int:
	if planet_id == "" or location_id == "":
		return 0
	if get_completed_runner_locations(planet_id).has(location_id):
		return get_outpost_repair_total(planet_id, location_id)
	var planet_progress: Dictionary = runner_outpost_progress_by_planet.get(planet_id, {})
	return maxi(0, int(planet_progress.get(location_id, 0)))


func get_outpost_repair_total(planet_id: String, location_id: String) -> int:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_outpost_meta"):
		var meta: Dictionary = cfg.get_outpost_meta(location_id)
		if not meta.is_empty():
			return maxi(1, int(meta.get("repair_total", DEFAULT_OUTPOST_REPAIR_TOTAL)))
	return DEFAULT_OUTPOST_REPAIR_TOTAL


## 结算写入据点进度。贡献 = round(装载量 × 完整度%)。满额才点亮。
## 返回：contribution / progress_before / progress_after / repair_total / newly_lit / already_lit / unlocked_batch / batch_just_unlocked
func apply_runner_delivery_progress(
	planet_id: String,
	location_id: String,
	cargo_load: int,
	integrity_percent: float,
	repair_total: int = -1,
	completed_mission_id: String = ""
) -> Dictionary:
	var total := repair_total if repair_total > 0 else get_outpost_repair_total(planet_id, location_id)
	total = maxi(1, total)
	var contribution := int(round(float(maxi(cargo_load, 0)) * clampf(integrity_percent, 0.0, 100.0) * 0.01))
	var already_lit := get_completed_runner_locations(planet_id).has(location_id)
	var before := get_outpost_progress(planet_id, location_id)
	var previous_batch := get_unlocked_mission_batch(planet_id)
	if already_lit:
		var dispatch_lit := sync_mission_dispatch(planet_id, completed_mission_id)
		return {
			"contribution": 0,
			"progress_before": before,
			"progress_after": total,
			"repair_total": total,
			"newly_lit": false,
			"already_lit": true,
			"unlocked_batch": int(dispatch_lit.get("unlocked_batch", previous_batch)),
			"batch_just_unlocked": false,
			"board_slots": dispatch_lit.get("board_slots", []),
		}
	var after := mini(before + maxi(contribution, 0), total)
	_set_outpost_progress_value(planet_id, location_id, after)
	var newly_lit := after >= total
	if newly_lit:
		mark_runner_location_completed(planet_id, location_id)
	else:
		sync_mission_dispatch(planet_id, completed_mission_id)
	var unlocked_batch := get_unlocked_mission_batch(planet_id)
	return {
		"contribution": contribution,
		"progress_before": before,
		"progress_after": after if not newly_lit else total,
		"repair_total": total,
		"newly_lit": newly_lit,
		"already_lit": false,
		"unlocked_batch": unlocked_batch,
		"batch_just_unlocked": unlocked_batch > previous_batch,
		"board_slots": get_mission_board_slots(planet_id),
	}


func get_mission_progress(planet_id: String, mission_id: String) -> int:
	if planet_id == "" or mission_id == "":
		return 0
	if is_mission_completed(planet_id, mission_id):
		var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
		if cfg != null and cfg.has_method("get_mission_by_id"):
			var mission: Dictionary = cfg.get_mission_by_id(mission_id)
			return MissionTypes.mission_progress_target(mission)
	var planet_map: Dictionary = runner_mission_progress_by_planet.get(planet_id, {})
	return maxi(0, int(planet_map.get(mission_id, 0)))


func is_mission_completed(planet_id: String, mission_id: String) -> bool:
	if planet_id == "" or mission_id == "":
		return false
	var done: Array = completed_missions_by_planet.get(planet_id, [])
	return done.has(mission_id)


func _set_mission_progress_value(planet_id: String, mission_id: String, value: int) -> void:
	if planet_id == "" or mission_id == "":
		return
	var planet_map: Dictionary = runner_mission_progress_by_planet.get(planet_id, {}).duplicate()
	planet_map[mission_id] = maxi(0, value)
	runner_mission_progress_by_planet[planet_id] = planet_map


func mark_mission_completed(planet_id: String, mission_id: String, target: int) -> void:
	if planet_id == "" or mission_id == "":
		return
	var done: Array = completed_missions_by_planet.get(planet_id, []).duplicate()
	if not done.has(mission_id):
		done.append(mission_id)
	completed_missions_by_planet[planet_id] = done
	_set_mission_progress_value(planet_id, mission_id, target)


func is_mission_reward_pending(planet_id: String, mission_id: String) -> bool:
	if planet_id == "" or mission_id == "":
		return false
	var pending: Array = mission_rewards_pending_by_planet.get(planet_id, [])
	return pending.has(mission_id)


func is_mission_reward_claimed(planet_id: String, mission_id: String) -> bool:
	if planet_id == "" or mission_id == "":
		return false
	var claimed: Array = mission_rewards_claimed_by_planet.get(planet_id, [])
	return claimed.has(mission_id)


func mark_mission_reward_pending(planet_id: String, mission_id: String) -> void:
	if planet_id == "" or mission_id == "":
		return
	var pending: Array = mission_rewards_pending_by_planet.get(planet_id, []).duplicate()
	if not pending.has(mission_id):
		pending.append(mission_id)
	mission_rewards_pending_by_planet[planet_id] = pending


func mark_mission_reward_claimed(planet_id: String, mission_id: String) -> void:
	if planet_id == "" or mission_id == "":
		return
	var pending: Array = mission_rewards_pending_by_planet.get(planet_id, []).duplicate()
	var pending_idx := pending.find(mission_id)
	if pending_idx >= 0:
		pending.remove_at(pending_idx)
	mission_rewards_pending_by_planet[planet_id] = pending
	var claimed: Array = mission_rewards_claimed_by_planet.get(planet_id, []).duplicate()
	if not claimed.has(mission_id):
		claimed.append(mission_id)
	mission_rewards_claimed_by_planet[planet_id] = claimed


func get_mission_reward_amount(planet_id: String, mission_id: String) -> int:
	if planet_id == "" or mission_id == "":
		return 0
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if cfg != null and cfg.has_method("get_mission_by_id"):
		var mission: Dictionary = cfg.get_mission_by_id(mission_id)
		if not mission.is_empty():
			return maxi(0, int(mission.get("base_reward", 0)))
	return 0


func claim_mission_reward(planet_id: String, mission_id: String, amount: int = -1) -> bool:
	if not is_mission_reward_pending(planet_id, mission_id):
		return false
	var payout := amount if amount >= 0 else get_mission_reward_amount(planet_id, mission_id)
	if payout > 0:
		add_ember_coins(payout)
	mark_mission_reward_claimed(planet_id, mission_id)
	save_mobile_progress()
	return true


func _today_key() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [int(dt.get("year", 1970)), int(dt.get("month", 1)), int(dt.get("day", 1))]


func ensure_daily_tasks_fresh() -> void:
	var today := _today_key()
	if daily_tasks_date != today:
		daily_tasks_date = today
		daily_task_progress = {}
		daily_tasks_claimed.clear()
	daily_task_progress["daily_login"] = 1


func get_daily_task_progress(task_id: String, target: int) -> int:
	ensure_daily_tasks_fresh()
	return mini(maxi(0, int(daily_task_progress.get(task_id, 0))), maxi(target, 1))


func add_daily_task_progress(task_id: String, delta: int, target: int = -1) -> void:
	ensure_daily_tasks_fresh()
	var cur := int(daily_task_progress.get(task_id, 0))
	var next := cur + delta
	if target > 0:
		next = mini(next, target)
	daily_task_progress[task_id] = maxi(0, next)


## 成功通关一局运输后写入日常进度（试玩不计入）
func record_daily_run_completion(integrity: float, coins_earned: int) -> void:
	ensure_daily_tasks_fresh()
	add_daily_task_progress("first_run", 1, 1)
	if integrity >= 90.0:
		add_daily_task_progress("safe_courier", 1, 1)
	if coins_earned > 0:
		add_daily_task_progress("spark_collector", coins_earned, 100)
	save_mobile_progress()


func is_daily_task_complete(task_id: String, target: int) -> bool:
	return get_daily_task_progress(task_id, target) >= maxi(target, 1)


func is_daily_task_claimed(task_id: String) -> bool:
	ensure_daily_tasks_fresh()
	return daily_tasks_claimed.has(task_id)


func is_daily_task_reward_pending(task_id: String, target: int) -> bool:
	return is_daily_task_complete(task_id, target) and not is_daily_task_claimed(task_id)


func claim_daily_task_reward(task_id: String, reward: int, target: int = 1) -> bool:
	if not is_daily_task_reward_pending(task_id, target):
		return false
	if reward > 0:
		add_ember_coins(reward)
	if not daily_tasks_claimed.has(task_id):
		daily_tasks_claimed.append(task_id)
	save_mobile_progress()
	return true


func _sync_location_progress_from_missions(planet_id: String, location_id: String) -> int:
	if planet_id == "" or location_id == "":
		return 0
	# 据点已点亮后不再用任务进度回写，避免显示/Continue 判定被压回未满
	if get_completed_runner_locations(planet_id).has(location_id):
		return get_outpost_repair_total(planet_id, location_id)
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if cfg == null or not cfg.has_method("get_missions_for_location"):
		return get_outpost_progress(planet_id, location_id)
	var sum := 0
	for raw in cfg.get_missions_for_location(location_id):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var mission: Dictionary = raw
		var mid := mission_key(mission)
		sum += get_mission_progress(planet_id, mid)
	var total := get_outpost_repair_total(planet_id, location_id)
	sum = clampi(sum, 0, total)
	_set_outpost_progress_value(planet_id, location_id, sum)
	return sum


## 单局结算：按完整度换算任务进度；满目标解锁 base_reward；据点进度=同据点 mission 进度之和
func apply_mission_run_progress(
	planet_id: String,
	mission_id: String,
	integrity_percent: float,
	mission: Dictionary = {}
) -> Dictionary:
	var target := MissionTypes.mission_progress_target(mission)
	var location_id := String(mission.get("location_id", ""))
	var previous_batch := get_unlocked_mission_batch(planet_id)
	if mission_id == "":
		return {"gain": 0, "progress_before": 0, "progress_after": 0, "target": target, "newly_completed": false, "already_completed": true, "reward_paid": 0, "location_newly_lit": false}
	if is_mission_completed(planet_id, mission_id):
		var loc_sum := get_outpost_progress(planet_id, location_id)
		return {
			"gain": 0,
			"progress_before": target,
			"progress_after": target,
			"target": target,
			"newly_completed": false,
			"already_completed": true,
			"reward_paid": 0,
			"location_newly_lit": false,
			"progress_total": get_outpost_repair_total(planet_id, location_id),
			"location_progress": loc_sum,
		}
	var gain := MissionTypes.integrity_to_mission_progress(integrity_percent)
	var before := get_mission_progress(planet_id, mission_id)
	var after := mini(before + gain, target)
	_set_mission_progress_value(planet_id, mission_id, after)
	var newly_completed := after >= target
	var reward_pending := 0
	if newly_completed:
		mark_mission_completed(planet_id, mission_id, target)
		reward_pending = int(mission.get("base_reward", 0))
		if reward_pending > 0:
			mark_mission_reward_pending(planet_id, mission_id)
	var location_progress := _sync_location_progress_from_missions(planet_id, location_id)
	var repair_total := get_outpost_repair_total(planet_id, location_id)
	var location_newly_lit := false
	if location_id != "" and location_progress >= repair_total:
		if not get_completed_runner_locations(planet_id).has(location_id):
			mark_runner_location_completed(planet_id, location_id)
			location_newly_lit = true
	sync_mission_dispatch(planet_id, mission_id if newly_completed else "")
	var unlocked_batch := get_unlocked_mission_batch(planet_id)
	return {
		"gain": gain,
		"progress_before": before,
		"progress_after": after if not newly_completed else target,
		"target": target,
		"newly_completed": newly_completed,
		"already_completed": false,
		"reward_paid": 0,
		"reward_pending": reward_pending,
		"location_newly_lit": location_newly_lit,
		"progress_total": repair_total,
		"location_progress": location_progress,
		"unlocked_batch": unlocked_batch,
		"batch_just_unlocked": unlocked_batch > previous_batch,
		"board_slots": get_mission_board_slots(planet_id),
	}


func _set_outpost_progress_value(planet_id: String, location_id: String, value: int) -> void:
	if planet_id == "" or location_id == "":
		return
	var planet_progress: Dictionary = runner_outpost_progress_by_planet.get(planet_id, {}).duplicate()
	planet_progress[location_id] = maxi(0, value)
	runner_outpost_progress_by_planet[planet_id] = planet_progress


func get_unlocked_mission_batch(planet_id: String) -> int:
	if planet_id == "":
		return 1
	if unlocked_mission_batch_by_planet.has(planet_id):
		return clampi(int(unlocked_mission_batch_by_planet[planet_id]), 1, 3)
	return MissionDispatch.compute_unlocked_batch(planet_id)


func get_mission_board_slots(planet_id: String) -> Array[String]:
	var result: Array[String] = []
	if planet_id == "":
		return result
	var raw: Variant = mission_board_slots_by_planet.get(planet_id, [])
	if raw is Array:
		for value in raw:
			var location_id := String(value)
			if location_id != "" and not result.has(location_id):
				result.append(location_id)
	return result


func is_mission_on_board(planet_id: String, mission_or_location_id: String) -> bool:
	return get_mission_board_slots(planet_id).has(mission_or_location_id)


## 同步批次解锁、地图揭示与任务板。返回 unlocked_batch / batch_just_unlocked / board_slots / revealed_added
func sync_mission_dispatch(planet_id: String, rotate_completed_mission_id: String = "") -> Dictionary:
	if planet_id == "":
		return {
			"unlocked_batch": 1,
			"batch_just_unlocked": false,
			"board_slots": [],
			"revealed_added": [],
		}
	if dev_full_unlock:
		apply_dev_full_unlock(planet_id)
		var unlocked_batch := MissionDispatch.compute_unlocked_batch(planet_id)
		return {
			"unlocked_batch": unlocked_batch,
			"batch_just_unlocked": false,
			"board_slots": get_mission_board_slots(planet_id),
			"revealed_added": [],
		}
	var previous_batch := int(unlocked_mission_batch_by_planet.get(planet_id, 0))
	var unlocked_batch := MissionDispatch.compute_unlocked_batch(planet_id)
	unlocked_mission_batch_by_planet[planet_id] = unlocked_batch
	var batch_just_unlocked := previous_batch > 0 and unlocked_batch > previous_batch

	var revealed := get_revealed_exploration_locations(planet_id, MissionDispatch.get_batch1_location_ids(planet_id))
	var revealed_added: Array[String] = []
	for location_id in MissionDispatch.get_batch_location_ids(planet_id, unlocked_batch):
		if not revealed.has(location_id):
			revealed.append(location_id)
			revealed_added.append(location_id)
	# 直接写揭示表，避免 set_revealed 再触发一次额外存盘
	exploration_revealed_locations_by_planet[planet_id] = revealed

	var board := MissionDispatch.fill_mission_board_slots(
		planet_id,
		get_mission_board_slots(planet_id),
		unlocked_batch,
		rotate_completed_mission_id
	)
	mission_board_slots_by_planet[planet_id] = board
	save_mobile_progress()
	return {
		"unlocked_batch": unlocked_batch,
		"batch_just_unlocked": batch_just_unlocked,
		"board_slots": board,
		"revealed_added": revealed_added,
	}


func ensure_mission_dispatch_ready(planet_id: String = "glass_desert") -> void:
	if planet_id == "":
		planet_id = "glass_desert"
	if dev_full_unlock:
		apply_dev_full_unlock(planet_id)
	else:
		sync_mission_dispatch(planet_id)


func is_dev_full_unlock() -> bool:
	return dev_full_unlock


func set_dev_full_unlock(enabled: bool, planet_id: String = "glass_desert") -> void:
	dev_full_unlock = enabled
	if planet_id == "":
		planet_id = "glass_desert"
	if enabled:
		apply_dev_full_unlock(planet_id)
	else:
		sync_mission_dispatch(planet_id)
	save_mobile_progress()


func apply_dev_full_unlock(planet_id: String = "glass_desert") -> void:
	if planet_id == "":
		planet_id = "glass_desert"
	var batches := MissionDispatch.get_batches(planet_id)
	var max_batch := 1
	for entry in batches:
		max_batch = maxi(max_batch, int(entry.get("id", 1)))
	unlocked_mission_batch_by_planet[planet_id] = max_batch
	var all_ids: Array[String] = []
	var all_mission_ids: Array[String] = []
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_explore_locations"):
		for loc in cfg.get_explore_locations():
			if typeof(loc) != TYPE_DICTIONARY:
				continue
			var location_id := String((loc as Dictionary).get("id", ""))
			if location_id != "" and not all_ids.has(location_id):
				all_ids.append(location_id)
	if all_ids.is_empty():
		all_ids = MissionDispatch.get_batch_location_ids(planet_id, max_batch)
	if cfg != null and cfg.has_method("get_location_missions"):
		for raw in cfg.get_location_missions():
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var mission_id := mission_key(raw as Dictionary)
			if mission_id != "" and not all_mission_ids.has(mission_id):
				all_mission_ids.append(mission_id)
	exploration_revealed_locations_by_planet[planet_id] = all_ids
	# 全解锁：任务板放入全部未完成任务，方便直接开打
	if not all_mission_ids.is_empty():
		mission_board_slots_by_planet[planet_id] = all_mission_ids
	else:
		mission_board_slots_by_planet[planet_id] = MissionDispatch.fill_mission_board_slots(
			planet_id,
			get_mission_board_slots(planet_id),
			max_batch,
			""
		)
	_sync_messenger_story_unlocks()
	save_mobile_progress()


## 重置单星球运输任务进度（保留等级、货币等），用于从批次 1 重新测试
func reset_planet_mission_progress(planet_id: String = "glass_desert") -> void:
	if planet_id == "":
		planet_id = "glass_desert"
	dev_full_unlock = false
	if completed_runner_locations_by_planet.has(planet_id):
		completed_runner_locations_by_planet.erase(planet_id)
	if runner_outpost_progress_by_planet.has(planet_id):
		runner_outpost_progress_by_planet.erase(planet_id)
	if runner_mission_progress_by_planet.has(planet_id):
		runner_mission_progress_by_planet.erase(planet_id)
	if completed_missions_by_planet.has(planet_id):
		completed_missions_by_planet.erase(planet_id)
	if mission_rewards_pending_by_planet.has(planet_id):
		mission_rewards_pending_by_planet.erase(planet_id)
	if mission_rewards_claimed_by_planet.has(planet_id):
		mission_rewards_claimed_by_planet.erase(planet_id)
	if mission_board_slots_by_planet.has(planet_id):
		mission_board_slots_by_planet.erase(planet_id)
	if unlocked_mission_batch_by_planet.has(planet_id):
		unlocked_mission_batch_by_planet.erase(planet_id)
	if active_missions_by_planet.has(planet_id):
		active_missions_by_planet.erase(planet_id)
	if accepted_missions_by_planet.has(planet_id):
		accepted_missions_by_planet.erase(planet_id)
	if map_light_ceremony_done_by_planet.has(planet_id):
		map_light_ceremony_done_by_planet.erase(planet_id)
	pending_map_light_focus = ""
	if outpost_light_rewards_pending_by_planet.has(planet_id):
		outpost_light_rewards_pending_by_planet.erase(planet_id)
	if outpost_light_rewards_claimed_by_planet.has(planet_id):
		outpost_light_rewards_claimed_by_planet.erase(planet_id)
	exploration_revealed_locations_by_planet[planet_id] = MissionDispatch.get_batch1_location_ids(planet_id)
	sync_mission_dispatch(planet_id)
	save_mobile_progress()


func get_active_mission(planet_id: String) -> Dictionary:
	var raw: Variant = active_missions_by_planet.get(planet_id, {})
	if raw is Dictionary:
		var location_id := String(raw.get("location_id", ""))
		if location_id != "":
			var mission_id := String(raw.get("mission_id", ""))
			if mission_id == "":
				mission_id = location_id
			return {"location_id": location_id, "mission_id": mission_id}
	return {}


func mission_key(mission: Dictionary) -> String:
	var mission_id := String(mission.get("mission_id", ""))
	if mission_id != "":
		return mission_id
	return String(mission.get("location_id", ""))


func is_mission_accepted(planet_id: String, mission_key_id: String) -> bool:
	if mission_key_id == "":
		return false
	var accepted: Array = accepted_missions_by_planet.get(planet_id, [])
	return accepted.has(mission_key_id)


func accept_mission(planet_id: String, mission_key_id: String) -> void:
	if planet_id == "" or mission_key_id == "":
		return
	var accepted: Array = accepted_missions_by_planet.get(planet_id, []).duplicate()
	if not accepted.has(mission_key_id):
		accepted.append(mission_key_id)
	accepted_missions_by_planet[planet_id] = accepted
	save_mobile_progress()


func set_active_mission(planet_id: String, location_id: String, mission_id: String = "") -> void:
	if planet_id == "" or location_id == "":
		return
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		return
	var key := mission_id if mission_id != "" else location_id
	active_missions_by_planet[planet_id] = {"location_id": location_id, "mission_id": key}
	if not is_mission_accepted(planet_id, key):
		accept_mission(planet_id, key)
	else:
		save_mobile_progress()


func clear_active_mission(planet_id: String) -> void:
	if planet_id == "":
		return
	if active_missions_by_planet.has(planet_id):
		active_missions_by_planet.erase(planet_id)
		save_mobile_progress()


func is_active_mission(planet_id: String, location_id: String, mission_key_id: String = "") -> bool:
	var active := get_active_mission(planet_id)
	if mission_key_id != "":
		return String(active.get("mission_id", "")) == mission_key_id
	return String(active.get("location_id", "")) == location_id


## 校验进行中任务：据点已点亮 / 批次未解锁 / 该任务已完成则清除。
func validate_active_mission(planet_id: String) -> Dictionary:
	var current := get_active_mission(planet_id)
	var location_id := String(current.get("location_id", ""))
	if location_id == "":
		return {}
	if get_completed_runner_locations(planet_id).has(location_id):
		clear_active_mission(planet_id)
		return {}
	if not MissionDispatch.is_location_batch_unlocked(planet_id, location_id):
		clear_active_mission(planet_id)
		return {}
	var mid := String(current.get("mission_id", ""))
	if mid != "" and mid != location_id and is_mission_completed(planet_id, mid):
		clear_active_mission(planet_id)
		return {}
	return current


func add_ember_coins(amount: int) -> void:
	ember_coins = max(0, ember_coins + amount)
	save_mobile_progress()


func get_messenger_snapshot() -> Dictionary:
	return CharacterProgression.build_snapshot(
		CharacterProgression.level_from_xp(messenger_xp),
		messenger_xp,
		messenger_cargo_guard_level,
		messenger_coin_bonus_level,
		messenger_mobility_level,
		ember_coins,
		messenger_unlocked_stories
	)


func get_cargo_damage_multiplier() -> float:
	return CharacterProgression.cargo_damage_multiplier(messenger_cargo_guard_level)


func apply_runner_hp_loss(amount: float) -> float:
	if amount <= 0.001:
		return 0.0
	var before := runner_hp
	runner_hp = maxf(runner_hp - amount, 0.0)
	var lost := before - runner_hp
	if lost > 0.001:
		save_mobile_progress()
	return lost


func get_coin_yield_multiplier() -> float:
	return CharacterProgression.coin_yield_multiplier(messenger_coin_bonus_level)


func get_lane_change_ease_bonus() -> float:
	return CharacterProgression.lane_change_ease_bonus(messenger_mobility_level)


func grant_messenger_runner_rewards(grade: String, difficulty: int, first_clear: bool) -> Dictionary:
	var xp_gain := CharacterProgression.runner_xp_reward(grade, difficulty, first_clear)
	var old_level := CharacterProgression.level_from_xp(messenger_xp)
	messenger_xp = maxi(messenger_xp + xp_gain, 0)
	var new_level := CharacterProgression.level_from_xp(messenger_xp)
	save_mobile_progress()
	return {
		"xp_gain": xp_gain,
		"level_up": new_level > old_level,
		"old_level": old_level,
		"new_level": new_level,
	}


func try_upgrade_messenger_stat(stat_id: String) -> bool:
	var current_level := _get_messenger_stat_level(stat_id)
	if not CharacterProgression.can_upgrade(stat_id, current_level, ember_coins):
		return false
	var cost := CharacterProgression.upgrade_cost(stat_id, current_level)
	ember_coins -= cost
	_set_messenger_stat_level(stat_id, current_level + 1)
	save_mobile_progress()
	return true


func _get_messenger_stat_level(stat_id: String) -> int:
	match stat_id:
		CharacterProgression.STAT_CARGO_GUARD:
			return messenger_cargo_guard_level
		CharacterProgression.STAT_COIN_BONUS:
			return messenger_coin_bonus_level
		CharacterProgression.STAT_MOBILITY:
			return messenger_mobility_level
	return 0


func _set_messenger_stat_level(stat_id: String, level: int) -> void:
	var clamped := clampi(level, 0, CharacterProgression.MAX_STAT_LEVEL)
	match stat_id:
		CharacterProgression.STAT_CARGO_GUARD:
			messenger_cargo_guard_level = clamped
		CharacterProgression.STAT_COIN_BONUS:
			messenger_coin_bonus_level = clamped
		CharacterProgression.STAT_MOBILITY:
			messenger_mobility_level = clamped


func _unlock_messenger_story(story_id: String) -> void:
	if story_id == "" or messenger_unlocked_stories.has(story_id):
		return
	messenger_unlocked_stories.append(story_id)


func _remove_messenger_story(story_id: String) -> void:
	if story_id == "":
		return
	var idx := messenger_unlocked_stories.find(story_id)
	if idx >= 0:
		messenger_unlocked_stories.remove_at(idx)


func _clamp_selected_character_to_unlocked() -> void:
	if not CharacterRoster.is_unlocked(selected_character_id, messenger_unlocked_stories):
		selected_character_id = CharacterRoster.CHAR_ELSA


func mark_first_launch_story_seen() -> void:
	first_launch_story_seen = true
	save_mobile_progress()


func mark_opening_comic_seen() -> void:
	opening_comic_seen = true
	first_launch_story_seen = true
	save_mobile_progress()


func mark_home_guide_seen() -> void:
	home_guide_seen = true
	save_mobile_progress()


func mark_transport_intro_seen() -> void:
	transport_intro_seen = true
	save_mobile_progress()


func mark_runner_wall_run_tutorial_seen() -> void:
	mark_runner_tutorial_seen("wall_run")


func is_runner_tutorial_enabled() -> bool:
	return runner_tutorial_enabled


func set_runner_tutorial_enabled(enabled: bool) -> void:
	runner_tutorial_enabled = enabled
	save_mobile_progress()


func has_seen_runner_tutorial(key: String) -> bool:
	if key == "wall_run" and runner_wall_run_tutorial_seen:
		return true
	return bool(runner_tutorial_seen.get(key, false))


func mark_runner_tutorial_seen(key: String) -> void:
	if key == "":
		return
	if bool(runner_tutorial_seen.get(key, false)):
		if key == "wall_run":
			runner_wall_run_tutorial_seen = true
		return
	runner_tutorial_seen[key] = true
	if key == "wall_run":
		runner_wall_run_tutorial_seen = true
	save_mobile_progress()


func reset_runner_tutorials() -> void:
	runner_tutorial_seen.clear()
	runner_wall_run_tutorial_seen = false
	save_mobile_progress()


func should_show_runner_tutorial(key: String) -> bool:
	return runner_tutorial_enabled and not has_seen_runner_tutorial(key)


func set_selected_ship(ship_id: String) -> void:
	if ship_id == "":
		return
	selected_ship_id = ship_id
	save_mobile_progress()


func set_selected_character(character_id: String) -> void:
	if character_id == "":
		return
	if not CharacterRoster.is_unlocked(character_id, messenger_unlocked_stories):
		character_id = CharacterRoster.CHAR_ELSA
	selected_character_id = character_id
	save_mobile_progress()


func get_selected_character_id() -> String:
	return selected_character_id


const RUNNER_ROAD_STYLE_ORDER: Array[String] = ["holographic", "alien_energy", "energy_neon", "planet", "coarse_desert", "rust_metal", "void_crystal"]
const RUNNER_ROAD_STYLE_LABELS := {
	"holographic": "全息能量轨",
	"alien_energy": "异星能量轨",
	"energy_neon": "能量霓虹",
	"planet": "星球默认",
	"coarse_desert": "粗粝沙漠",
	"rust_metal": "锈蚀金属",
	"void_crystal": "虚空晶体",
}
const RUNNER_ROAD_STYLE_LABELS_EN := {
	"holographic": "Holo Energy Track",
	"alien_energy": "Alien Energy Track",
	"energy_neon": "Energy Neon",
	"planet": "Planet Default",
	"coarse_desert": "Coarse Desert",
	"rust_metal": "Rust Metal",
	"void_crystal": "Void Crystal",
}


func get_runner_road_style() -> String:
	return normalize_runner_road_style(runner_road_style)


func get_runner_road_style_label(style_id: String = "") -> String:
	var id := normalize_runner_road_style(style_id if style_id != "" else runner_road_style)
	return GameLocale.pick(
		String(RUNNER_ROAD_STYLE_LABELS.get(id, id)),
		String(RUNNER_ROAD_STYLE_LABELS_EN.get(id, RUNNER_ROAD_STYLE_LABELS.get(id, id)))
	)


func normalize_runner_road_style(style_id: String) -> String:
	if RUNNER_ROAD_STYLE_ORDER.has(style_id):
		return style_id
	return "holographic"


func set_runner_road_style(style_id: String) -> void:
	runner_road_style = normalize_runner_road_style(style_id)
	save_mobile_progress()


func cycle_runner_road_style() -> String:
	var current := get_runner_road_style()
	var idx := RUNNER_ROAD_STYLE_ORDER.find(current)
	if idx < 0:
		idx = 0
	runner_road_style = RUNNER_ROAD_STYLE_ORDER[(idx + 1) % RUNNER_ROAD_STYLE_ORDER.size()]
	save_mobile_progress()
	return runner_road_style


const RUNNER_BACKGROUND_STYLE_ORDER: Array[String] = [
	"desert_crystal",
	"industrial_ruin",
	"savanna",
	"starfield",
	"void_dark",
]
const RUNNER_BACKGROUND_STYLE_LABELS := {
	"void_dark": "虚空暗域",
	"desert_crystal": "晶砂荒漠",
	"industrial_ruin": "工业废墟",
	"savanna": "稀树草原",
	"starfield": "深空星野",
}
const RUNNER_BACKGROUND_STYLE_LABELS_EN := {
	"void_dark": "Void Dark",
	"desert_crystal": "Crystal Desert",
	"industrial_ruin": "Industrial Ruin",
	"savanna": "Savanna",
	"starfield": "Starfield",
}


func get_runner_background_style() -> String:
	return normalize_runner_background_style(runner_background_style)


func get_runner_background_style_label(style_id: String = "") -> String:
	var id := normalize_runner_background_style(style_id if style_id != "" else runner_background_style)
	return GameLocale.pick(
		String(RUNNER_BACKGROUND_STYLE_LABELS.get(id, id)),
		String(RUNNER_BACKGROUND_STYLE_LABELS_EN.get(id, RUNNER_BACKGROUND_STYLE_LABELS.get(id, id)))
	)


func normalize_runner_background_style(style_id: String) -> String:
	if RUNNER_BACKGROUND_STYLE_ORDER.has(style_id):
		return style_id
	return "desert_crystal"


func set_runner_background_style(style_id: String) -> void:
	runner_background_style = normalize_runner_background_style(style_id)
	save_mobile_progress()


func populate_runner_road_style_option(option: OptionButton) -> void:
	option.clear()
	for style_id in RUNNER_ROAD_STYLE_ORDER:
		option.add_item(get_runner_road_style_label(style_id))
	var idx := RUNNER_ROAD_STYLE_ORDER.find(get_runner_road_style())
	option.select(maxi(idx, 0))


func populate_runner_background_style_option(option: OptionButton) -> void:
	option.clear()
	for style_id in RUNNER_BACKGROUND_STYLE_ORDER:
		option.add_item(get_runner_background_style_label(style_id))
	var idx := RUNNER_BACKGROUND_STYLE_ORDER.find(get_runner_background_style())
	option.select(maxi(idx, 0))


func save_mobile_progress() -> void:
	var data := {
		"version": MOBILE_PROGRESS_VERSION,
		"first_launch_story_seen": first_launch_story_seen,
		"opening_comic_seen": opening_comic_seen,
		"home_guide_seen": home_guide_seen,
		"transport_intro_seen": transport_intro_seen,
		"runner_tutorial_enabled": runner_tutorial_enabled,
		"ui_locale": get_ui_locale(),
		"dev_full_unlock": dev_full_unlock,
		"runner_tutorial_seen": runner_tutorial_seen.duplicate(true),
		"runner_wall_run_tutorial_seen": runner_wall_run_tutorial_seen or bool(runner_tutorial_seen.get("wall_run", false)),
		"bgm_enabled": bgm_enabled,
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume,
		"ember_coins": ember_coins,
		"gold_coins": gold_coins,
		"runner_energy": runner_energy,
		"runner_energy_max": runner_energy_max,
		"runner_hp": runner_hp,
		"runner_hp_max": runner_hp_max,
		"messenger_xp": messenger_xp,
		"messenger_cargo_guard_level": messenger_cargo_guard_level,
		"messenger_coin_bonus_level": messenger_coin_bonus_level,
		"messenger_mobility_level": messenger_mobility_level,
		"messenger_unlocked_stories": messenger_unlocked_stories.duplicate(),
		"selected_ship_id": selected_ship_id,
		"selected_character_id": selected_character_id,
		"runner_road_style": get_runner_road_style(),
		"runner_background_style": get_runner_background_style(),
		"exploration_revealed_locations_by_planet": _string_array_dict_to_save_data(exploration_revealed_locations_by_planet),
		"completed_runner_locations_by_planet": _string_array_dict_to_save_data(completed_runner_locations_by_planet),
		"map_light_ceremony_done_by_planet": _string_array_dict_to_save_data(map_light_ceremony_done_by_planet),
		"outpost_light_rewards_pending_by_planet": _string_array_dict_to_save_data(outpost_light_rewards_pending_by_planet),
		"outpost_light_rewards_claimed_by_planet": _string_array_dict_to_save_data(outpost_light_rewards_claimed_by_planet),
		"runner_outpost_progress_by_planet": _int_dict_dict_to_save_data(runner_outpost_progress_by_planet),
		"runner_mission_progress_by_planet": _int_dict_dict_to_save_data(runner_mission_progress_by_planet),
		"completed_missions_by_planet": _string_array_dict_to_save_data(completed_missions_by_planet),
		"mission_rewards_pending_by_planet": _string_array_dict_to_save_data(mission_rewards_pending_by_planet),
		"mission_rewards_claimed_by_planet": _string_array_dict_to_save_data(mission_rewards_claimed_by_planet),
		"mission_board_slots_by_planet": _string_array_dict_to_save_data(mission_board_slots_by_planet),
		"unlocked_mission_batch_by_planet": _int_dict_to_save_data(unlocked_mission_batch_by_planet),
		"active_missions_by_planet": active_missions_by_planet.duplicate(true),
		"accepted_missions_by_planet": _string_array_dict_to_save_data(accepted_missions_by_planet),
		"daily_tasks_date": daily_tasks_date,
		"daily_task_progress": daily_task_progress.duplicate(true),
		"daily_tasks_claimed": daily_tasks_claimed.duplicate(),
	}
	var file := FileAccess.open(MOBILE_PROGRESS_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Failed to save mobile progress: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data, "\t"))


func load_mobile_progress() -> void:
	if not FileAccess.file_exists(MOBILE_PROGRESS_SAVE_PATH):
		return
	var file := FileAccess.open(MOBILE_PROGRESS_SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Failed to load mobile progress: %s" % FileAccess.get_open_error())
		return
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or not (json.data is Dictionary):
		push_warning("Failed to parse mobile progress save.")
		return
	var data: Dictionary = json.data
	first_launch_story_seen = bool(data.get("first_launch_story_seen", first_launch_story_seen))
	opening_comic_seen = bool(data.get("opening_comic_seen", opening_comic_seen))
	home_guide_seen = bool(data.get("home_guide_seen", home_guide_seen))
	transport_intro_seen = bool(data.get("transport_intro_seen", transport_intro_seen))
	runner_tutorial_enabled = bool(data.get("runner_tutorial_enabled", true))
	ui_locale = "en" if String(data.get("ui_locale", ui_locale)) == "en" else "zh"
	dev_full_unlock = bool(data.get("dev_full_unlock", false))
	bgm_enabled = bool(data.get("bgm_enabled", true))
	bgm_volume = clampf(float(data.get("bgm_volume", bgm_volume)), 0.0, 1.0)
	sfx_volume = clampf(float(data.get("sfx_volume", sfx_volume)), 0.0, 1.0)
	runner_tutorial_seen = {}
	var seen_raw: Variant = data.get("runner_tutorial_seen", {})
	if typeof(seen_raw) == TYPE_DICTIONARY:
		for k in (seen_raw as Dictionary).keys():
			runner_tutorial_seen[String(k)] = bool((seen_raw as Dictionary)[k])
	runner_wall_run_tutorial_seen = bool(data.get("runner_wall_run_tutorial_seen", runner_wall_run_tutorial_seen))
	if runner_wall_run_tutorial_seen:
		runner_tutorial_seen["wall_run"] = true
	ember_coins = max(0, int(data.get("ember_coins", ember_coins)))
	gold_coins = max(0, int(data.get("gold_coins", gold_coins)))
	runner_energy_max = maxi(1, int(data.get("runner_energy_max", runner_energy_max)))
	runner_energy = clampi(int(data.get("runner_energy", runner_energy)), 0, runner_energy_max)
	runner_hp_max = maxf(1.0, float(data.get("runner_hp_max", runner_hp_max)))
	runner_hp = clampf(float(data.get("runner_hp", runner_hp)), 0.0, runner_hp_max)
	messenger_xp = maxi(0, int(data.get("messenger_xp", messenger_xp)))
	messenger_cargo_guard_level = clampi(int(data.get("messenger_cargo_guard_level", messenger_cargo_guard_level)), 0, CharacterProgression.MAX_STAT_LEVEL)
	messenger_coin_bonus_level = clampi(int(data.get("messenger_coin_bonus_level", messenger_coin_bonus_level)), 0, CharacterProgression.MAX_STAT_LEVEL)
	messenger_mobility_level = clampi(int(data.get("messenger_mobility_level", messenger_mobility_level)), 0, CharacterProgression.MAX_STAT_LEVEL)
	messenger_unlocked_stories = _load_string_array(data.get("messenger_unlocked_stories", []))
	selected_ship_id = String(data.get("selected_ship_id", selected_ship_id))
	selected_character_id = String(data.get("selected_character_id", selected_character_id))
	runner_road_style = normalize_runner_road_style(String(data.get("runner_road_style", runner_road_style)))
	runner_background_style = normalize_runner_background_style(
		String(data.get("runner_background_style", runner_background_style))
	)
	# 详情页背景选项已移除；旧存档若落在虚空暗域，恢复晶砂荒漠
	if runner_background_style == "void_dark":
		runner_background_style = "desert_crystal"
	exploration_revealed_locations_by_planet = _save_data_to_string_array_dict(data.get("exploration_revealed_locations_by_planet", {}))
	completed_runner_locations_by_planet = _save_data_to_string_array_dict(data.get("completed_runner_locations_by_planet", {}))
	map_light_ceremony_done_by_planet = _save_data_to_string_array_dict(data.get("map_light_ceremony_done_by_planet", {}))
	outpost_light_rewards_pending_by_planet = _save_data_to_string_array_dict(data.get("outpost_light_rewards_pending_by_planet", {}))
	outpost_light_rewards_claimed_by_planet = _save_data_to_string_array_dict(data.get("outpost_light_rewards_claimed_by_planet", {}))
	runner_outpost_progress_by_planet = _save_data_to_int_dict_dict(data.get("runner_outpost_progress_by_planet", {}))
	runner_mission_progress_by_planet = _save_data_to_int_dict_dict(data.get("runner_mission_progress_by_planet", {}))
	completed_missions_by_planet = _save_data_to_string_array_dict(data.get("completed_missions_by_planet", {}))
	mission_rewards_pending_by_planet = _save_data_to_string_array_dict(data.get("mission_rewards_pending_by_planet", {}))
	mission_rewards_claimed_by_planet = _save_data_to_string_array_dict(data.get("mission_rewards_claimed_by_planet", {}))
	mission_board_slots_by_planet = _save_data_to_string_array_dict(data.get("mission_board_slots_by_planet", {}))
	unlocked_mission_batch_by_planet = _save_data_to_int_dict(data.get("unlocked_mission_batch_by_planet", {}))
	active_missions_by_planet = _save_data_to_active_missions_dict(data.get("active_missions_by_planet", {}))
	accepted_missions_by_planet = _save_data_to_string_array_dict(data.get("accepted_missions_by_planet", {}))
	daily_tasks_date = String(data.get("daily_tasks_date", daily_tasks_date))
	daily_task_progress = {}
	var daily_prog_raw: Variant = data.get("daily_task_progress", {})
	if typeof(daily_prog_raw) == TYPE_DICTIONARY:
		for k in (daily_prog_raw as Dictionary).keys():
			daily_task_progress[String(k)] = int((daily_prog_raw as Dictionary)[k])
	daily_tasks_claimed = []
	var daily_claimed_raw: Variant = data.get("daily_tasks_claimed", [])
	if typeof(daily_claimed_raw) == TYPE_ARRAY:
		for item in daily_claimed_raw:
			daily_tasks_claimed.append(String(item))
	ensure_daily_tasks_fresh()
	_sync_completed_outpost_progress()
	_sync_mission_reward_claim_state()
	_sync_messenger_story_unlocks()


func _sync_messenger_story_unlocks() -> void:
	var before_stories := messenger_unlocked_stories.duplicate()
	var before_char := selected_character_id
	var dome_lit := get_completed_runner_locations("glass_desert").has("dome")
	var dome_claimed := is_outpost_light_reward_claimed("glass_desert", "dome")
	# Rook 在领取穹顶点亮奖励时解锁；点亮瞬间不同步解锁，避免领取页无法播角色揭示
	if is_dev_full_unlock() or (dome_lit and dome_claimed):
		_unlock_messenger_story("dome_resident")
	elif not dome_lit:
		_remove_messenger_story("dome_resident")
	_clamp_selected_character_to_unlocked()
	if before_stories != messenger_unlocked_stories or before_char != selected_character_id:
		save_mobile_progress()


## 正式运输才计入任务板 / 据点点亮；试玩与未解锁批次不计入
func should_count_runner_mission_progress() -> bool:
	if runner_trial_run:
		return false
	if runner_planet_id == "" or runner_location_id == "":
		return false
	if CustomLevels.has_level(runner_location_id):
		return false
	return MissionDispatch.is_location_batch_unlocked(runner_planet_id, runner_location_id)

func _sync_completed_outpost_progress() -> void:
	# 旧存档：已点亮据点补满进度条，并同步对应 mission 为已完成
	for planet_id in completed_runner_locations_by_planet.keys():
		var planet_key := String(planet_id)
		for location_id in get_completed_runner_locations(planet_key):
			var total := get_outpost_repair_total(planet_key, location_id)
			var planet_progress: Dictionary = runner_outpost_progress_by_planet.get(planet_key, {})
			if int(planet_progress.get(location_id, 0)) < total:
				_set_outpost_progress_value(planet_key, location_id, total)
			_mark_location_missions_completed(planet_key, location_id)


func _mark_location_missions_completed(planet_id: String, location_id: String) -> void:
	if planet_id == "" or location_id == "":
		return
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id)
	if cfg == null or not cfg.has_method("get_missions_for_location"):
		return
	for raw in cfg.get_missions_for_location(location_id):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var mission: Dictionary = raw
		var mid := mission_key(mission)
		var target := MissionTypes.mission_progress_target(mission)
		mark_mission_completed(planet_id, mid, target)
		mark_mission_reward_claimed(planet_id, mid)


func _sync_mission_reward_claim_state() -> void:
	# 旧存档：已完成任务默认视为已领取（此前为自动发放）
	for planet_id in completed_missions_by_planet.keys():
		var planet_key := String(planet_id)
		for raw in completed_missions_by_planet.get(planet_key, []):
			var mid := String(raw)
			if mid == "":
				continue
			if is_mission_reward_pending(planet_key, mid) or is_mission_reward_claimed(planet_key, mid):
				continue
			mark_mission_reward_claimed(planet_key, mid)


func reset_mobile_progress() -> void:
	dev_full_unlock = false
	first_launch_story_seen = false
	opening_comic_seen = false
	home_guide_seen = false
	transport_intro_seen = false
	runner_tutorial_enabled = true
	runner_tutorial_seen.clear()
	runner_wall_run_tutorial_seen = false
	ember_coins = 0
	gold_coins = 1280
	runner_energy = 86
	runner_energy_max = 120
	runner_hp = 100.0
	runner_hp_max = 100.0
	messenger_xp = 0
	messenger_cargo_guard_level = 0
	messenger_coin_bonus_level = 0
	messenger_mobility_level = 0
	messenger_unlocked_stories.clear()
	selected_ship_id = "spark_moth"
	selected_character_id = "elsa"
	runner_road_style = "holographic"
	runner_background_style = "desert_crystal"
	exploration_revealed_locations_by_planet.clear()
	completed_runner_locations_by_planet.clear()
	map_light_ceremony_done_by_planet.clear()
	pending_map_light_focus = ""
	outpost_light_rewards_pending_by_planet.clear()
	outpost_light_rewards_claimed_by_planet.clear()
	runner_outpost_progress_by_planet.clear()
	runner_mission_progress_by_planet.clear()
	completed_missions_by_planet.clear()
	mission_rewards_pending_by_planet.clear()
	mission_rewards_claimed_by_planet.clear()
	mission_board_slots_by_planet.clear()
	unlocked_mission_batch_by_planet.clear()
	active_missions_by_planet.clear()
	accepted_missions_by_planet.clear()
	daily_tasks_date = ""
	daily_task_progress.clear()
	daily_tasks_claimed.clear()
	if FileAccess.file_exists(MOBILE_PROGRESS_SAVE_PATH):
		DirAccess.remove_absolute(MOBILE_PROGRESS_SAVE_PATH)
	ensure_mission_dispatch_ready("glass_desert")
	save_mobile_progress()


func _string_array_dict_to_save_data(source: Dictionary) -> Dictionary:
	var result := {}
	for key in source.keys():
		var values: Array = source[key]
		var stored: Array[String] = []
		for value in values:
			var text := String(value)
			if text != "" and not stored.has(text):
				stored.append(text)
		result[String(key)] = stored
	return result


func _int_dict_dict_to_save_data(source: Dictionary) -> Dictionary:
	var result := {}
	for planet_key in source.keys():
		var raw: Variant = source[planet_key]
		if not (raw is Dictionary):
			continue
		var stored := {}
		for location_key in raw.keys():
			stored[String(location_key)] = maxi(0, int(raw[location_key]))
		result[String(planet_key)] = stored
	return result


func _int_dict_to_save_data(source: Dictionary) -> Dictionary:
	var result := {}
	for key in source.keys():
		result[String(key)] = maxi(0, int(source[key]))
	return result


func _save_data_to_int_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for key in source.keys():
		result[String(key)] = maxi(0, int(source[key]))
	return result


func _save_data_to_int_dict_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for planet_key in source.keys():
		var raw: Variant = source[planet_key]
		if not (raw is Dictionary):
			continue
		var stored := {}
		for location_key in raw.keys():
			stored[String(location_key)] = maxi(0, int(raw[location_key]))
		result[String(planet_key)] = stored
	return result


func _load_string_array(source_variant: Variant) -> Array[String]:
	var result: Array[String] = []
	if source_variant is Array:
		for value in source_variant:
			var text := String(value)
			if text != "" and not result.has(text):
				result.append(text)
	return result


func _save_data_to_string_array_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for key in source.keys():
		var stored: Array[String] = []
		var values: Variant = source[key]
		if values is Array:
			for value in values:
				var text := String(value)
				if text != "" and not stored.has(text):
					stored.append(text)
		result[String(key)] = stored
	return result


func _save_data_to_active_missions_dict(source_variant: Variant) -> Dictionary:
	var result := {}
	if not (source_variant is Dictionary):
		return result
	var source: Dictionary = source_variant
	for key in source.keys():
		var entry: Variant = source[key]
		if entry is Dictionary:
			var location_id := String(entry.get("location_id", ""))
			if location_id != "":
				var mission_id := String(entry.get("mission_id", ""))
				if mission_id == "":
					mission_id = location_id
				result[String(key)] = {"location_id": location_id, "mission_id": mission_id}
		elif typeof(entry) == TYPE_STRING:
			var location_id := String(entry)
			if location_id != "":
				result[String(key)] = {"location_id": location_id}
	return result


func get_completed_runner_locations(planet_id: String) -> Array[String]:
	var completed: Array = completed_runner_locations_by_planet.get(planet_id, [])
	var result: Array[String] = []
	for id in completed:
		var location_id := String(id)
		if location_id != "" and not result.has(location_id):
			result.append(location_id)
	return result


func _ready_global_scenes_after_scene_change() -> void:
	await get_tree().process_frame
	if not get_tree().current_scene:
		return
	if get_tree().current_scene.is_in_group("RunnerGameScene"):
		ready_runner_global_scenes()
		return
	if get_tree().current_scene.is_in_group("GalaxyMapScene"):
		set_mouse_mode()
		return
	set_mouse_mode()


func ready_runner_global_scenes() -> void:
	set_mouse_mode()


func get_delta_time() -> float:
	if Engine.is_in_physics_frame():
		return get_physics_process_delta_time()
	return get_process_delta_time()


# Global.set_mouse_mode()
func set_mouse_mode() -> void:
	# 竖屏手游：默认可见光标；桌面跑酷也保持可见（暂停/UI 可点）
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func is_tool_ui_move_camera() -> bool:
	return false


func tool_ui_visible() -> bool:
	return false




# 返回两个标识名称(键"name"为"START"和"END")中间字典的数组
static func get_dicts_between_start_end(dict_array: Array, start: String = "START", end: String = "END") -> Array:
	var result := []
	var started := false

	for dict in dict_array:
		if dict.name == start:
			started = true
			continue
		if dict.name == end:
			break
		if started:
			result.append(dict)

	return result


"""
下边是弃用的 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
"""


# 获取指定文件夹下特定类型的随机资源
# folder_path: 文件夹路径（如"res://assets/sounds"）
# allowed_types: 允许的资源类型数组（如["PackedScene", "Texture2D"]），留空则允许所有类型
func get_random_resource(folder_path: String, allowed_types: Array = []) -> Resource:
	# 用于存储符合条件的资源路径
	var valid_resources := []

	# 检查文件夹是否存在
	if not DirAccess.dir_exists_absolute(folder_path):
		push_error("Folder does not exist: " + folder_path)
		return null

	# 遍历目录
	var dir := DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			# 跳过目录和隐藏文件
			if not dir.current_is_dir() and not file_name.begins_with("."):
				var full_path := folder_path.path_join(file_name)
				# 检查文件扩展名是否是资源类型
				if ResourceLoader.exists(full_path):
					# 如果指定了类型限制，则检查类型
					if allowed_types.is_empty():
						valid_resources.append(full_path)
					else:
						var rfl := ResourceFormatLoader.new()
						var resource_type := rfl._get_resource_type(full_path) # buggggggg
						if resource_type in allowed_types:
							valid_resources.append(full_path)
			file_name = dir.get_next()
	else:
		push_error("Failed to open directory: " + folder_path)
		return null

	# 如果没有找到符合条件的资源
	if valid_resources.is_empty():
		push_error("No valid resources found in: " + folder_path)
		return null

	# 随机选择一个资源并加载
	var random_index := randi() % valid_resources.size()
	var selected_resource := ResourceLoader.load(valid_resources[random_index])

	return selected_resource





#func





"""
update
calculate
create
process
global
start
end
position
count

# await get_tree().physics_frame

	#var time_start = Time.get_ticks_usec()
	#var time_end = Time.get_ticks_usec()
	#print("took %d microseconds" % (time_end - time_start))

#ProjectSettings.get_setting("")



"""






pass
