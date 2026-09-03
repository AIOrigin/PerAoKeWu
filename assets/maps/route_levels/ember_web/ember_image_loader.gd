extends ResourceFormatLoader

## Web：从 user:// CDN 缓存读 png/webp/jpg。仅在 EmberCdn 里注册，避免进编辑器导入链。

const WebConfig := preload("res://assets/maps/route_levels/ember_web/ember_web_config.gd")


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["png", "webp", "jpg", "jpeg"])


func _handles_type(type: StringName) -> bool:
	var t := String(type)
	if t.is_empty() or t == "Texture2D" or t == "ImageTexture" or t == "Image":
		return true
	return ClassDB.is_parent_class(t, "Texture2D")


func _get_resource_type(path: String) -> String:
	# 必须按路径判断。无条件返回 ImageTexture 会让引擎把 .gdshader / .gd 也当成贴图加载。
	if not OS.has_feature("web") or not WebConfig.is_cdn_image(path):
		return ""
	return "ImageTexture"


func _recognize_path(path: String, type: StringName) -> bool:
	if not OS.has_feature("web"):
		return false
	if not WebConfig.is_cdn_image(path):
		return false
	if type != &"" and not _handles_type(type):
		return false
	return FileAccess.file_exists(WebConfig.cache_path_for_res_image(path))


func _exists(path: String) -> bool:
	if not OS.has_feature("web") or not WebConfig.is_cdn_image(path):
		return false
	return FileAccess.file_exists(WebConfig.cache_path_for_res_image(path))


func _load(path: String, _original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
	if not OS.has_feature("web") or not WebConfig.is_cdn_image(path):
		return ERR_FILE_UNRECOGNIZED
	var cached := WebConfig.cache_path_for_res_image(path)
	if not FileAccess.file_exists(cached):
		return ERR_FILE_NOT_FOUND
	var img := Image.new()
	if img.load(cached) != OK:
		var loaded := Image.load_from_file(cached)
		if loaded == null or loaded.is_empty():
			return ERR_FILE_CANT_OPEN
		img = loaded
	if img.is_compressed():
		img.decompress()
	var tex := ImageTexture.create_from_image(img)
	if tex != null:
		tex.take_over_path(path)
	return tex
