class_name CapybaraCdn
extends Node

## Web 版：从 S3/CDN 下载 GLB 到 user:// 缓存，桌面版直接走 res://

const WebConfig := preload("res://assets/maps/route_levels/capybara_rush/capybara_web_config.gd")
const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")

signal preload_progress(done: int, total: int, path: String)
signal preload_finished()

## 同一 CDN 域名并发过高会占满浏览器连接池，后续请求一直 Pending
const MAX_CONCURRENT_DOWNLOADS := 2
const DOWNLOAD_TIMEOUT_SEC := 120.0

signal _download_slot_done(success: bool, path: String)

var _inflight: Dictionary = {}
var _download_queue: Array[String] = []
var _running_downloads := 0


func _ready() -> void:
	if is_enabled():
		# Web 切后台时 SceneTree 会 pause，CDN 下载仍需推进
		process_mode = Node.PROCESS_MODE_ALWAYS
		_prune_old_cdn_caches()


func is_enabled() -> bool:
	return WebConfig.cdn_enabled()


func resolve_model_path(res_path: String) -> String:
	if not is_enabled():
		return res_path
	if not res_path.begins_with(WebConfig.RES_MODELS_ROOT):
		return res_path
	var cached := WebConfig.cache_path_for_res_model(res_path)
	if FileAccess.file_exists(cached):
		return cached
	if ResourceLoader.exists(res_path):
		return res_path
	return res_path


func _character_res_path(char_id: String, rigged: String, plain: String) -> String:
	if WebConfig.cdn_enabled():
		return rigged
	if ResourceLoader.exists(rigged):
		return rigged
	return plain


func preload_all_characters() -> void:
	await preload_paths_async(_all_character_paths())


func preload_all_characters_async() -> void:
	preload_paths_async(_all_character_paths())


func _all_character_paths() -> Array[String]:
	var ids := [
		"capybara", "little_monster", "little_rabbit", "shiba", "bird",
		"mouse", "sloth", "tiny_planet", "bear", "cow",
	]
	var paths: Array[String] = []
	for id in ids:
		var p := character_model_path(id)
		if not p.is_empty() and p not in paths:
			paths.append(p)
	return paths


func preload_paths(paths: Array) -> void:
	await preload_paths_async(paths)
	preload_finished.emit()


func preload_for_theme(theme_cfg: Dictionary, character_id: String) -> void:
	var paths: Array[String] = []
	paths.append_array(_core_model_paths())
	paths.append_array(_paths_from_theme(theme_cfg))
	var char_path: String = character_model_path(character_id)
	if not char_path.is_empty():
		paths.append(char_path)
	if character_id != "capybara":
		var capy := character_model_path("capybara")
		if not capy.is_empty():
			paths.append(capy)
	await preload_paths_async(paths)


func preload_paths_async(paths: Array) -> void:
	if not is_enabled():
		return
	var todo := _collect_glb_paths(paths)
	var total := todo.size()
	if total == 0:
		return
	var done := 0
	for p in todo:
		if _is_cached(p):
			done += 1
			preload_progress.emit(done, total, p)
	for p in todo:
		if _is_cached(p):
			continue
		await _ensure_cached(p)
		done += 1
		preload_progress.emit(done, total, p)


func _collect_glb_paths(paths: Array) -> Array[String]:
	var todo: Array[String] = []
	for raw in paths:
		var p := String(raw)
		if p.is_empty() or not p.ends_with(".glb"):
			continue
		if p in todo:
			continue
		todo.append(p)
	return todo


func _is_cached(res_path: String) -> bool:
	if not res_path.begins_with(WebConfig.RES_MODELS_ROOT):
		return true
	var cached := WebConfig.cache_path_for_res_model(res_path)
	if FileAccess.file_exists(cached):
		return true
	return ResourceLoader.exists(res_path) and not WebConfig.cdn_enabled()


func is_model_cached(res_path: String) -> bool:
	return _is_cached(res_path)


func ensure_cached(res_path: String) -> void:
	await _ensure_cached(res_path)


func _ensure_cached(res_path: String) -> void:
	if _is_cached(res_path):
		return
	if bool(_inflight.get(res_path, false)):
		while not _is_cached(res_path) and bool(_inflight.get(res_path, false)):
			var slot: Array = await _download_slot_done
			if String(slot[1]) == res_path:
				return
		return
	_enqueue_download(res_path)
	while not _is_cached(res_path):
		var slot: Array = await _download_slot_done
		if String(slot[1]) == res_path:
			return


func _enqueue_download(res_path: String) -> void:
	if not is_enabled():
		return
	if not res_path.begins_with(WebConfig.RES_MODELS_ROOT):
		return
	if _is_cached(res_path):
		return
	if bool(_inflight.get(res_path, false)):
		return
	if res_path in _download_queue:
		return
	_download_queue.append(res_path)
	_pump_download_queue()


func _pump_download_queue() -> void:
	while _running_downloads < MAX_CONCURRENT_DOWNLOADS and not _download_queue.is_empty():
		var res_path: String = _download_queue.pop_front()
		if _is_cached(res_path) or bool(_inflight.get(res_path, false)):
			continue
		_inflight[res_path] = true
		_running_downloads += 1
		_start_download(res_path)


func _start_download(res_path: String) -> void:
	var url := WebConfig.remote_url_for_res_model(res_path)
	var dest := WebConfig.cache_path_for_res_model(res_path)
	if url.is_empty():
		call_deferred("_finish_download", false, res_path)
		return
	_ensure_cache_dir(dest.get_base_dir())
	var http := HTTPRequest.new()
	http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(http)
	http.timeout = DOWNLOAD_TIMEOUT_SEC
	http.request_completed.connect(
		func(_result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			http.queue_free()
			var ok := false
			if (code == 200 or code == 206) and not body.is_empty():
				var f := FileAccess.open(dest, FileAccess.WRITE)
				if f != null:
					f.store_buffer(body)
					ok = true
			if not ok:
				push_warning("CapybaraCdn download failed (%s): %s" % [code, url])
			_finish_download(ok, res_path),
		CONNECT_ONE_SHOT
	)
	var err := http.request(url)
	if err != OK:
		http.queue_free()
		call_deferred("_finish_download", false, res_path)


func _finish_download(_ok: bool, res_path: String) -> void:
	_inflight.erase(res_path)
	_running_downloads = maxi(0, _running_downloads - 1)
	_download_slot_done.emit(_ok, res_path)
	_pump_download_queue()


func _paths_from_theme(theme_cfg: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for section_key in ["props", "obstacles"]:
		var section: Variant = theme_cfg.get(section_key, {})
		if typeof(section) != TYPE_DICTIONARY:
			continue
		for k in (section as Dictionary).keys():
			var p := String((section as Dictionary).get(k, ""))
			if p.ends_with(".glb"):
				out.append(p)
	return out


func _core_model_paths() -> Array[String]:
	return [
		CapybaraRushPaths.CAPYBARA_BASE_RIGGED,
		CapybaraRushPaths.CLOUD_FLUFFY,
		CapybaraRushPaths.FINISH_ARCH,
		CapybaraRushPaths.FRUIT_ORANGE,
		CapybaraRushPaths.FRUIT_APPLE,
		CapybaraRushPaths.FRUIT_BANANA,
		CapybaraRushPaths.FRUIT_PINEAPPLE,
		CapybaraRushPaths.FRUIT_DURIAN,
		CapybaraRushPaths.PICKUP_GLOW_PAD,
		CapybaraRushPaths.STEP_PLATFORM,
		CapybaraRushPaths.SPEED_ORB,
		CapybaraRushPaths.WATERMELON_SLICE,
		CapybaraRushPaths.BOOST_PACK,
		CapybaraRushPaths.SPACESHIP,
		CapybaraRushPaths.CAPYBARA_PILOT,
	]


func character_model_path(char_id: String) -> String:
	match char_id:
		"capybara":
			return _character_res_path(char_id, CapybaraRushPaths.CAPYBARA_BASE_RIGGED, CapybaraRushPaths.CAPYBARA_BASE)
		"little_monster":
			return _character_res_path(char_id, CapybaraRushPaths.LITTLE_MONSTER_RIGGED, CapybaraRushPaths.LITTLE_MONSTER)
		"little_rabbit":
			return _character_res_path(char_id, CapybaraRushPaths.LITTLE_RABBIT_RIGGED, CapybaraRushPaths.LITTLE_RABBIT)
		"shiba":
			return _character_res_path(char_id, CapybaraRushPaths.SHIBA_RIGGED, CapybaraRushPaths.SHIBA)
		"bird":
			return _character_res_path(char_id, CapybaraRushPaths.BIRD_RIGGED, CapybaraRushPaths.BIRD)
		"mouse":
			return _character_res_path(char_id, CapybaraRushPaths.MOUSE_RIGGED, CapybaraRushPaths.MOUSE)
		"sloth":
			return _character_res_path(char_id, CapybaraRushPaths.SLOTH_RIGGED, CapybaraRushPaths.SLOTH)
		"tiny_planet":
			return _character_res_path(char_id, CapybaraRushPaths.TINY_PLANET_RIGGED, CapybaraRushPaths.TINY_PLANET)
		"bear":
			return _character_res_path(char_id, CapybaraRushPaths.BEAR_RIGGED, CapybaraRushPaths.BEAR)
		"cow":
			return _character_res_path(char_id, CapybaraRushPaths.COW_RIGGED, CapybaraRushPaths.COW)
		_:
			return CapybaraRushPaths.CAPYBARA_BASE


func _ensure_cache_dir(abs_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(abs_dir)


func _prune_old_cdn_caches() -> void:
	var root := WebConfig.CACHE_ROOT.trim_suffix("/")
	var da := DirAccess.open(root)
	if da == null:
		return
	var keep := WebConfig.asset_version()
	var stale: PackedStringArray = []
	da.list_dir_begin()
	var name := da.get_next()
	while name != "":
		if name != "." and name != ".." and da.current_is_dir() and name != keep:
			stale.append(name)
		name = da.get_next()
	da.list_dir_end()
	for old in stale:
		_remove_dir_recursive(root.path_join(old))


func _remove_dir_recursive(abs_path: String) -> void:
	var da := DirAccess.open(abs_path)
	if da == null:
		DirAccess.remove_absolute(abs_path)
		return
	da.list_dir_begin()
	var name := da.get_next()
	var files: PackedStringArray = []
	var dirs: PackedStringArray = []
	while name != "":
		if name != "." and name != "..":
			if da.current_is_dir():
				dirs.append(name)
			else:
				files.append(name)
		name = da.get_next()
	da.list_dir_end()
	for f in files:
		da.remove(f)
	for d in dirs:
		_remove_dir_recursive(abs_path.path_join(d))
	DirAccess.remove_absolute(abs_path)
