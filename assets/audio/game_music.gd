extends Node

## 全局 BGM：主界面 Ember Runners；跑酷 Never Stop Running；居民穹顶 My People

const HOME_BGM_PATH := "res://assets/audio/music/ember_runners.mp3"
const RUNNER_BGM_PATH := "res://assets/audio/music/never_stop_running.mp3"
const DOME_BGM_PATH := "res://assets/audio/music/my_people.mp3"

const HOME_VOLUME_DB := -8.0
const RUNNER_VOLUME_DB := -6.0
const FADE_OUT_DB := -48.0

var _player: AudioStreamPlayer
var _mode := "" # "home" | "runner" | ""
var _fade_tween: Tween


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "GameMusicPlayer"
	_player.bus = "Master"
	add_child(_player)


func play_home(fade_sec: float = 1.05) -> void:
	# 已在播主页曲则不打断，跨页更自然
	if _mode == "home" and _player != null and _player.playing:
		return
	_switch_to(HOME_BGM_PATH, true, HOME_VOLUME_DB, fade_sec, "home", false)


func play_runner_from_start(fade_sec: float = 0.28) -> void:
	# 3-2-1 起：强制从头播跑酷曲
	_switch_to(RUNNER_BGM_PATH, true, RUNNER_VOLUME_DB, fade_sec, "runner", true)


func stop_music(fade_sec: float = 0.45) -> void:
	if _player == null:
		return
	_mode = ""
	_kill_fade()
	if fade_sec <= 0.001 or not _player.playing:
		_player.stop()
		return
	_fade_tween = create_tween()
	_fade_tween.tween_property(_player, "volume_db", FADE_OUT_DB, fade_sec)
	_fade_tween.tween_callback(_player.stop)


func _switch_to(
	path: String,
	loop: bool,
	target_db: float,
	fade_sec: float,
	mode: String,
	force_restart: bool
) -> void:
	if _player == null:
		return
	var same_track := _mode == mode and _player.playing and not force_restart
	if same_track:
		return
	_kill_fade()
	var stream := _load_looped_stream(path, loop)
	if stream == null:
		push_warning("GameMusic: missing stream %s" % path)
		return

	var start_fresh := func() -> void:
		_player.stream = stream
		_player.volume_db = FADE_OUT_DB if fade_sec > 0.05 else target_db
		_player.play(0.0)
		_mode = mode
		if fade_sec > 0.05:
			_fade_tween = create_tween()
			_fade_tween.tween_property(_player, "volume_db", target_db, fade_sec)

	if _player.playing and fade_sec > 0.05:
		var out_t := mini(fade_sec * 0.55, 0.55)
		_fade_tween = create_tween()
		_fade_tween.tween_property(_player, "volume_db", FADE_OUT_DB, out_t)
		_fade_tween.tween_callback(start_fresh)
	else:
		start_fresh.call()


func _load_looped_stream(path: String, loop: bool) -> AudioStream:
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


func _kill_fade() -> void:
	if _fade_tween != null and is_instance_valid(_fade_tween):
		_fade_tween.kill()
	_fade_tween = null
