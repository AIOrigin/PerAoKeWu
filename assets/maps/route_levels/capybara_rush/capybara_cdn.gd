class_name CapybaraCdn
extends Node

## Web 版：从 S3/CDN 下载 GLB 到 user:// 缓存，桌面版直接走 res://

const WebConfig := preload("res://assets/maps/route_levels/capybara_rush/capybara_web_config.gd")
const CapybaraRushPaths := preload("res://assets/maps/route_levels/capybara_rush/model_paths.gd")

signal preload_progress(done: int, total: int, path: String)
signal preload_finished()
signal model_cached(res_path: String)

var _web_helpers_ready := false


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
		await get_tree().create_timer(0.35).timeout
		ok = await _download_to_cache(url, cached)
	if ok:
		model_cached.emit(res_path)
	else:
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
		CapybaraRushPaths.TREE_LOLLIPOP,
		CapybaraRushPaths.BUSH_ROUND,
		CapybaraRushPaths.ROCK_EDGE,
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
	if not is_inside_tree():
		return false
	if OS.has_feature("web"):
		return await _download_to_cache_web(url, dest_path)
	return await _download_to_cache_http(url, dest_path)


func _download_to_cache_http(url: String, dest_path: String) -> bool:
	var http := HTTPRequest.new()
	http.use_threads = false
	http.timeout = 30.0
	add_child(http)
	await get_tree().process_frame
	var err := http.request(url)
	if err != OK:
		http.queue_free()
		return false
	var result: Array = await http.request_completed
	http.queue_free()
	if not is_inside_tree():
		return false
	if result.size() < 4:
		return false
	var code: int = int(result[1])
	var body: PackedByteArray = result[3]
	if code != 200 or body.is_empty():
		return false
	return _write_cache_file(dest_path, body)


func _ensure_web_download_helpers() -> void:
	if _web_helpers_ready:
		return
	JavaScriptBridge.eval(
		"""
window._capyJobs = window._capyJobs || {};
window._capyStartFetch = function (token, url) {
	var job = {busy: true, ok: false, len: 0, err: '', buf: null};
	window._capyJobs[token] = job;
	fetch(url, {mode: 'cors', credentials: 'omit'}).then(function (r) {
		if (!r.ok) {
			job.err = 'http ' + r.status;
			job.busy = false;
			return null;
		}
		return r.arrayBuffer();
	}).then(function (buf) {
		if (!buf) {
			if (job.busy) job.busy = false;
			return;
		}
		job.buf = new Uint8Array(buf);
		job.len = job.buf.length;
		job.ok = job.len > 0;
		if (!job.ok) job.err = 'empty';
		job.busy = false;
	}).catch(function (e) {
		job.err = String((e && e.message) ? e.message : e);
		job.ok = false;
		job.busy = false;
	});
};
window._capyBusy = function (token) {
	var j = window._capyJobs[token];
	return !!(j && j.busy);
};
window._capyOk = function (token) {
	var j = window._capyJobs[token];
	return !!(j && j.ok);
};
window._capyLen = function (token) {
	var j = window._capyJobs[token];
	return j ? (j.len || 0) : 0;
};
window._capyErr = function (token) {
	var j = window._capyJobs[token];
	return (j && j.err) ? j.err : 'fetch';
};
window._capyB64Chunk = function (token, start, end) {
	var j = window._capyJobs[token];
	if (!j || !j.buf) return '';
	var s = j.buf.subarray(start, end);
	var bin = '';
	var n = 0x8000;
	for (var i = 0; i < s.length; i += n) {
		bin += String.fromCharCode.apply(null, s.subarray(i, Math.min(i + n, s.length)));
	}
	return btoa(bin);
};
window._capyDrop = function (token) {
	delete window._capyJobs[token];
};
window._capyWriteFS = function (token, absPath) {
	var j = window._capyJobs[token];
	if (!j || !j.buf) return 'no-buf';
	var eng = window.__capyEngine;
	if (!eng || typeof eng.copyToFS !== 'function') return 'no-engine';
	try {
		eng.copyToFS(absPath, j.buf);
		return 'ok';
	} catch (e) {
		return String((e && e.message) ? e.message : e);
	}
};
		""",
		true
	)
	_web_helpers_ready = true


func _download_to_cache_web(url: String, dest_path: String) -> bool:
	## fetch 在 JS 里拿齐二进制；再按 24KB 做 base64 拷进 Godot。
	## 整包 Array.from / 整包 base64 会在 4MB+ GLB 上把桥接撑死。
	_ensure_web_download_helpers()
	var token := "%d_%d" % [Time.get_ticks_msec(), randi()]
	JavaScriptBridge.eval(
		"window._capyStartFetch(%s,%s)" % [JSON.stringify(token), JSON.stringify(url)],
		true
	)
	var tok_js := JSON.stringify(token)
	var waited := 0.0
	while int(JavaScriptBridge.eval("window._capyBusy(%s)?1:0" % tok_js, true)) == 1 and waited < 120.0:
		await get_tree().process_frame
		waited += maxf(get_process_delta_time(), 0.016)
	if int(JavaScriptBridge.eval("window._capyOk(%s)?1:0" % tok_js, true)) != 1:
		var why := String(JavaScriptBridge.eval("window._capyErr(%s)" % tok_js, true))
		JavaScriptBridge.eval("window._capyDrop(%s)" % tok_js, true)
		push_warning("CapybaraCdn fetch %s: %s" % [why, url])
		return false
	var n := int(JavaScriptBridge.eval("window._capyLen(%s)" % tok_js, true))
	if n <= 0:
		JavaScriptBridge.eval("window._capyDrop(%s)" % tok_js, true)
		return false
	var abs_path := ProjectSettings.globalize_path(dest_path)
	if not abs_path.begins_with("/"):
		abs_path = "/userfs/" + dest_path.trim_prefix("user://")
	var fs_ret := String(JavaScriptBridge.eval(
		"window._capyWriteFS(%s,%s)" % [tok_js, JSON.stringify(abs_path)],
		true
	))
	if fs_ret == "ok" and FileAccess.file_exists(dest_path):
		JavaScriptBridge.eval("window._capyDrop(%s)" % tok_js, true)
		return true
	# copyToFS 不可用时才走 base64，大文件会很慢
	push_warning("CapybaraCdn copyToFS %s, falling back: %s" % [fs_ret, dest_path])
	var body := PackedByteArray()
	var chunk := 24576
	var i := 0
	while i < n:
		var end_i := mini(i + chunk, n)
		var raw: Variant = JavaScriptBridge.eval(
			"window._capyB64Chunk(%s,%d,%d)" % [tok_js, i, end_i],
			true
		)
		if typeof(raw) != TYPE_STRING or String(raw).is_empty():
			JavaScriptBridge.eval("window._capyDrop(%s)" % tok_js, true)
			return false
		var part := Marshalls.base64_to_raw(String(raw))
		if part.is_empty():
			JavaScriptBridge.eval("window._capyDrop(%s)" % tok_js, true)
			return false
		body.append_array(part)
		i = end_i
		if i % 98304 == 0:
			await get_tree().process_frame
	JavaScriptBridge.eval("window._capyDrop(%s)" % tok_js, true)
	if body.size() != n:
		return false
	return _write_cache_file(dest_path, body)


func _write_cache_file(dest_path: String, body: PackedByteArray) -> bool:
	var f := FileAccess.open(dest_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(body)
	f.flush()
	var written := f.get_length()
	f.close()
	return written == body.size()


func _ensure_cache_dir(abs_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(abs_dir)
