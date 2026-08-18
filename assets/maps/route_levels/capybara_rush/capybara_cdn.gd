class_name CapybaraCdn
extends Node

## Web 版：从 S3/CDN 下载 GLB 到 user:// 缓存，桌面版直接走 res://

const WebConfig := preload("res://assets/maps/route_levels/capybara_rush/capybara_web_config.gd")
const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")

signal preload_progress(done: int, total: int, path: String)
signal preload_finished()


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
	var ids := [
		"capybara", "little_monster", "little_rabbit", "shiba", "bird",
		"mouse", "sloth", "tiny_planet", "bear", "cow",
	]
	var paths: Array[String] = []
	for id in ids:
		var p := _character_model_path(id)
		if not p.is_empty() and p not in paths:
			paths.append(p)
	await preload_paths_async(paths)


func preload_paths(paths: Array) -> void:
	if not is_enabled() or paths.is_empty():
		preload_finished.emit()
		return
	var todo: Array[String] = []
	for raw in paths:
		var p := String(raw)
		if p.is_empty() or not p.ends_with(".glb"):
			continue
		if p in todo:
			continue
		todo.append(p)
	var total := todo.size()
	var done := 0
	for p in todo:
		preload_progress.emit(done, total, p)
		await _ensure_cached(p)
		done += 1
		preload_progress.emit(done, total, p)
	preload_finished.emit()


func preload_for_theme(theme_cfg: Dictionary, character_id: String) -> void:
	var paths: Array[String] = []
	paths.append_array(_core_model_paths())
	paths.append_array(_paths_from_theme(theme_cfg))
	var char_path: String = _character_model_path(character_id)
	if not char_path.is_empty():
		paths.append(char_path)
	# 选角预览常用：默认卡皮巴拉
	if character_id != "capybara":
		var capy := _character_model_path("capybara")
		if not capy.is_empty():
			paths.append(capy)
	await preload_paths_async(paths)


func preload_paths_async(paths: Array) -> void:
	if not is_enabled() or paths.is_empty():
		return
	var todo: Array[String] = []
	for raw in paths:
		var p := String(raw)
		if p.is_empty() or not p.ends_with(".glb"):
			continue
		if p in todo:
			continue
		todo.append(p)
	var total := todo.size()
	var done := 0
	for p in todo:
		preload_progress.emit(done, total, p)
		await _ensure_cached(p)
		done += 1
		preload_progress.emit(done, total, p)
		await get_tree().process_frame


func _ensure_cached(res_path: String) -> void:
	if not res_path.begins_with(WebConfig.RES_MODELS_ROOT):
		return
	var cached := WebConfig.cache_path_for_res_model(res_path)
	if FileAccess.file_exists(cached):
		return
	# Web 导出已排除 models/，res:// 上即使有 .import 也不代表能实例化
	if ResourceLoader.exists(res_path) and not WebConfig.cdn_enabled():
		return
	var url := WebConfig.remote_url_for_res_model(res_path)
	if url.is_empty():
		return
	var ok: bool = await _download_to_cache(url, cached)
	if not ok:
		push_warning("CapybaraCdn download failed: %s" % url)


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


func _character_model_path(char_id: String) -> String:
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


func _download_to_cache(url: String, dest_path: String) -> bool:
	_ensure_cache_dir(dest_path.get_base_dir())
	var http := HTTPRequest.new()
	add_child(http)
	var err := http.request(url)
	if err != OK:
		http.queue_free()
		return false
	var result: Array = await http.request_completed
	http.queue_free()
	if result.size() < 4:
		return false
	var code: int = int(result[1])
	var body: PackedByteArray = result[3]
	if code != 200 or body.is_empty():
		return false
	var f := FileAccess.open(dest_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(body)
	return true


func _ensure_cache_dir(abs_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(abs_dir)
