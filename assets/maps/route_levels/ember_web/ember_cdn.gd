extends Node

## Web：从 CloudFront 拉 GLB/图片，经 Engine.copyToFS 写入 user://。桌面直接 res://。
## 最多 2 路并发；同一路径只下一遍。进 HOME 只预载 home 组图片。

const WebConfig := preload("res://assets/maps/route_levels/ember_web/ember_web_config.gd")
const ImageLoaderScript := preload("res://assets/maps/route_levels/ember_web/ember_image_loader.gd")

signal preload_progress(done: int, total: int, path: String)
signal preload_finished()
signal model_cached(res_path: String)

const MAX_CONCURRENT := 2

var _web_helpers_ready := false
var _image_loader_ready := false
var _active := 0
var _inflight: Dictionary = {}
var _packed_cache: Dictionary = {}
var _tex_cache: Dictionary = {}
var _image_loader: ResourceFormatLoader


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_register_image_loader()


func _ready() -> void:
	_apply_web_render()


func is_enabled() -> bool:
	return WebConfig.cdn_enabled()


func is_cdn_model(res_path: String) -> bool:
	return WebConfig.is_cdn_model(res_path)


func _register_image_loader() -> void:
	if _image_loader_ready or not WebConfig.cdn_enabled():
		return
	_image_loader = ImageLoaderScript.new()
	ResourceLoader.add_resource_format_loader(_image_loader, true)
	_image_loader_ready = true


func resolve_model_path(res_path: String) -> String:
	if not is_enabled() or not WebConfig.is_cdn_model(res_path):
		return res_path
	var cached := WebConfig.cache_path_for_res_model(res_path)
	if FileAccess.file_exists(cached):
		return cached
	return res_path


func load_packed(res_path: String) -> PackedScene:
	if res_path.is_empty():
		return null
	if not res_path.ends_with(".glb"):
		if ResourceLoader.exists(res_path):
			return ResourceLoader.load(res_path) as PackedScene
		return null
	var resolved := resolve_model_path(res_path)
	if resolved.begins_with("user://") and FileAccess.file_exists(resolved):
		return _pack_gltf(resolved)
	if is_enabled():
		if FileAccess.file_exists(resolved):
			return _pack_gltf(resolved)
		return null
	if ResourceLoader.exists(res_path):
		var packed := ResourceLoader.load(res_path) as PackedScene
		if packed != null:
			return packed
	if FileAccess.file_exists(resolved):
		return _pack_gltf(resolved)
	return null


func instantiate_glb(res_path: String) -> Node3D:
	var packed := load_packed(res_path)
	if packed != null:
		return packed.instantiate() as Node3D
	var resolved := resolve_model_path(res_path)
	if FileAccess.file_exists(resolved):
		return _generate_gltf(resolved)
	return null


func preload_paths_queued(paths: Array) -> void:
	if not is_enabled():
		preload_finished.emit()
		return
	var todo: Array[String] = []
	for raw in paths:
		var p := String(raw)
		if p.is_empty() or not WebConfig.is_cdn_asset(p):
			continue
		if p in todo:
			continue
		todo.append(p)
	if todo.is_empty():
		preload_finished.emit()
		return
	var total := todo.size()
	var idx := [0]
	var done_n := [0]
	var finished := [0]
	var workers := mini(MAX_CONCURRENT, todo.size())
	preload_progress.emit(0, total, "")
	for _w in workers:
		_preload_worker(todo, idx, done_n, finished, total)
	while int(finished[0]) < workers and is_inside_tree():
		await get_tree().process_frame
	preload_finished.emit()


func _preload_worker(todo: Array[String], idx: Array, done_n: Array, finished: Array, total: int) -> void:
	while is_inside_tree():
		var i: int = int(idx[0])
		if i >= todo.size():
			break
		idx[0] = i + 1
		var p := todo[i]
		await ensure_cached(p)
		done_n[0] = int(done_n[0]) + 1
		preload_progress.emit(int(done_n[0]), total, p)
	finished[0] = int(finished[0]) + 1


func ensure_cached(res_path: String) -> bool:
	if not is_enabled() or not WebConfig.is_cdn_asset(res_path):
		return true
	var cached := WebConfig.cache_path_for_res(res_path)
	if FileAccess.file_exists(cached):
		return true
	if _inflight.has(res_path):
		while _inflight.has(res_path) and is_inside_tree():
			await get_tree().process_frame
		return FileAccess.file_exists(cached)
	_inflight[res_path] = true
	while _active >= MAX_CONCURRENT and is_inside_tree():
		await get_tree().process_frame
	if not is_inside_tree():
		_inflight.erase(res_path)
		return false
	_active += 1
	var ok := await _download_one(res_path, cached)
	_active -= 1
	_inflight.erase(res_path)
	if ok:
		model_cached.emit(res_path)
	return ok


func preload_manifest_group(group: String) -> void:
	var paths: Array = []
	for path in WebConfig.manifest_paths(group):
		paths.append(path)
	await preload_paths_queued(paths)


func texture_available(res_path: String) -> bool:
	if res_path.strip_edges() == "":
		return false
	if _tex_cache.has(res_path):
		return true
	if is_enabled() and WebConfig.is_cdn_image(res_path):
		if FileAccess.file_exists(WebConfig.cache_path_for_res_image(res_path)):
			return true
	if ResourceLoader.exists(res_path):
		return true
	return FileAccess.file_exists(ProjectSettings.globalize_path(res_path))


func load_texture(res_path: String) -> Texture2D:
	if res_path.strip_edges() == "":
		return null
	if _tex_cache.has(res_path):
		return _tex_cache[res_path] as Texture2D
	if is_enabled() and WebConfig.is_cdn_image(res_path):
		var cached := WebConfig.cache_path_for_res_image(res_path)
		if FileAccess.file_exists(cached):
			var cdn_tex := _image_texture_from_file(cached)
			if cdn_tex != null:
				cdn_tex.take_over_path(res_path)
				_tex_cache[res_path] = cdn_tex
			return cdn_tex
	if ResourceLoader.exists(res_path):
		var imported := load(res_path) as Texture2D
		if imported != null:
			_tex_cache[res_path] = imported
			return imported
	var abs_path := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var raw_tex := _image_texture_from_file(abs_path)
		if raw_tex != null:
			_tex_cache[res_path] = raw_tex
		return raw_tex
	return null


func _image_texture_from_file(path: String) -> Texture2D:
	var img := Image.new()
	if img.load(path) != OK:
		img = Image.load_from_file(path)
	if img == null or img.is_empty():
		return null
	if img.is_compressed():
		img.decompress()
	return ImageTexture.create_from_image(img)


func _download_one(res_path: String, cached: String) -> bool:
	if FileAccess.file_exists(cached):
		return true
	var url := WebConfig.remote_url_for_res(res_path)
	if url.is_empty():
		return false
	var ok: bool = await _download_to_cache(url, cached)
	if not ok:
		push_warning("EmberCdn download failed: %s" % url)
	return ok


func _pack_gltf(path: String) -> PackedScene:
	if _packed_cache.has(path):
		return _packed_cache[path] as PackedScene
	var generated := _generate_gltf(path)
	if generated == null:
		return null
	var packed := PackedScene.new()
	if packed.pack(generated) != OK:
		generated.queue_free()
		return null
	generated.queue_free()
	_packed_cache[path] = packed
	return packed


func _generate_gltf(path: String) -> Node3D:
	var abs_path := ProjectSettings.globalize_path(path)
	var file_path := abs_path if FileAccess.file_exists(abs_path) else path
	if not FileAccess.file_exists(file_path):
		return null
	var doc := GLTFDocument.new()
	var state := GLTFState.new()
	if doc.append_from_file(file_path, state) != OK:
		return null
	return doc.generate_scene(state) as Node3D


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
	http.timeout = 60.0
	add_child(http)
	await get_tree().process_frame
	var err := http.request(url)
	if err != OK:
		http.queue_free()
		return false
	var result: Array = await http.request_completed
	http.queue_free()
	if not is_inside_tree() or result.size() < 4:
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
window._emberJobs = window._emberJobs || {};
window._emberStartFetch = function (token, url) {
	var job = {busy: true, ok: false, len: 0, err: '', buf: null};
	window._emberJobs[token] = job;
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
window._emberBusy = function (token) {
	var j = window._emberJobs[token];
	return !!(j && j.busy);
};
window._emberOk = function (token) {
	var j = window._emberJobs[token];
	return !!(j && j.ok);
};
window._emberLen = function (token) {
	var j = window._emberJobs[token];
	return j ? (j.len || 0) : 0;
};
window._emberErr = function (token) {
	var j = window._emberJobs[token];
	return (j && j.err) ? j.err : 'fetch';
};
window._emberDrop = function (token) {
	delete window._emberJobs[token];
};
window._emberWriteFS = function (token, absPath) {
	var j = window._emberJobs[token];
	if (!j || !j.buf) return 'no-buf';
	var eng = window.__emberEngine;
	if (!eng || typeof eng.copyToFS !== 'function') return 'no-engine';
	try {
		eng.copyToFS(absPath, j.buf);
		return 'ok';
	} catch (e) {
		return String((e && e.message) ? e.message : e);
	}
};
window._emberB64Chunk = function (token, start, end) {
	var j = window._emberJobs[token];
	if (!j || !j.buf) return '';
	var s = j.buf.subarray(start, end);
	var bin = '';
	var n = 0x8000;
	for (var i = 0; i < s.length; i += n) {
		bin += String.fromCharCode.apply(null, s.subarray(i, Math.min(i + n, s.length)));
	}
	return btoa(bin);
};
		""",
		true
	)
	_web_helpers_ready = true


func _download_to_cache_web(url: String, dest_path: String) -> bool:
	_ensure_web_download_helpers()
	var token := "%d_%d" % [Time.get_ticks_msec(), randi()]
	JavaScriptBridge.eval(
		"window._emberStartFetch(%s,%s)" % [JSON.stringify(token), JSON.stringify(url)],
		true
	)
	var tok_js := JSON.stringify(token)
	var waited := 0.0
	while int(JavaScriptBridge.eval("window._emberBusy(%s)?1:0" % tok_js, true)) == 1 and waited < 120.0:
		await get_tree().process_frame
		waited += maxf(get_process_delta_time(), 0.016)
	if int(JavaScriptBridge.eval("window._emberOk(%s)?1:0" % tok_js, true)) != 1:
		var why := String(JavaScriptBridge.eval("window._emberErr(%s)" % tok_js, true))
		JavaScriptBridge.eval("window._emberDrop(%s)" % tok_js, true)
		push_warning("EmberCdn fetch %s: %s" % [why, url])
		return false
	var n := int(JavaScriptBridge.eval("window._emberLen(%s)" % tok_js, true))
	if n <= 0:
		JavaScriptBridge.eval("window._emberDrop(%s)" % tok_js, true)
		return false
	var abs_path := ProjectSettings.globalize_path(dest_path)
	if not abs_path.begins_with("/"):
		abs_path = "/userfs/" + dest_path.trim_prefix("user://")
	var fs_ret := String(JavaScriptBridge.eval(
		"window._emberWriteFS(%s,%s)" % [tok_js, JSON.stringify(abs_path)],
		true
	))
	if fs_ret == "ok" and FileAccess.file_exists(dest_path):
		JavaScriptBridge.eval("window._emberDrop(%s)" % tok_js, true)
		return true
	push_warning("EmberCdn copyToFS %s, falling back: %s" % [fs_ret, dest_path])
	var body := PackedByteArray()
	var chunk := 24576
	var i := 0
	while i < n:
		var end_i := mini(i + chunk, n)
		var raw: Variant = JavaScriptBridge.eval(
			"window._emberB64Chunk(%s,%d,%d)" % [tok_js, i, end_i],
			true
		)
		if typeof(raw) != TYPE_STRING or String(raw).is_empty():
			JavaScriptBridge.eval("window._emberDrop(%s)" % tok_js, true)
			return false
		var part := Marshalls.base64_to_raw(String(raw))
		if part.is_empty():
			JavaScriptBridge.eval("window._emberDrop(%s)" % tok_js, true)
			return false
		body.append_array(part)
		i = end_i
		if i % 98304 == 0:
			await get_tree().process_frame
	JavaScriptBridge.eval("window._emberDrop(%s)" % tok_js, true)
	if body.size() != n:
		return false
	return _write_cache_file(dest_path, body)


func _write_cache_file(dest_path: String, body: PackedByteArray) -> bool:
	var f := FileAccess.open(dest_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(body)
	f.flush()
	f.close()
	if not FileAccess.file_exists(dest_path):
		return false
	var check := FileAccess.open(dest_path, FileAccess.READ)
	if check == null:
		return false
	return check.get_length() == body.size()


func _ensure_cache_dir(abs_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(abs_dir)


func _apply_web_render() -> void:
	if not OS.has_feature("web"):
		return
	var vp := get_viewport()
	if vp == null:
		return
	vp.msaa_3d = Viewport.MSAA_DISABLED
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	vp.use_taa = false
	if OS.has_feature("web_ios") or OS.has_feature("ios"):
		vp.scaling_3d_scale = 1.0
