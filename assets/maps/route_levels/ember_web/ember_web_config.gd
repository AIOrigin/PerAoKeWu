class_name EmberWebConfig
extends RefCounted

## 星火信使网页版 CDN 配置。桌面/F6 留空逻辑：cdn_enabled() 为 false，仍读 res://。
## CloudFront OriginPath=/public，URL 里不要写 public/。

const ASSET_VERSION := "20260903-4"

const GAME_ID := "ember-runner"

## 运行时按前缀映射到 CDN；上传脚本保持同一相对路径。
const RES_MODELS_ROOT := "res://assets/maps/route_levels/models/"
const RES_RUNNER_ROOT := "res://assets/maps/route_levels/runner_60s/"
const RES_MVP_ROOT := "res://mvp素材第二批/"

const CDN_BASE_URL := "https://de0csn75w3vhy.cloudfront.net/games/ember-runner/models"
const CDN_IMAGE_BASE_URL := "https://de0csn75w3vhy.cloudfront.net/games/ember-runner/images"

const CACHE_ROOT := "user://ember_cdn/models/"
const IMAGE_CACHE_ROOT := "user://ember_cdn/images/"
const IMAGE_MANIFEST := "res://assets/maps/route_levels/ember_web/ember_image_manifest.json"


static func cdn_enabled() -> bool:
	return OS.has_feature("web") and not CDN_BASE_URL.strip_edges().is_empty()


static func is_cdn_model(res_path: String) -> bool:
	if not res_path.ends_with(".glb"):
		return false
	return (
		res_path.begins_with(RES_MODELS_ROOT)
		or res_path.begins_with(RES_RUNNER_ROOT)
		or res_path.begins_with(RES_MVP_ROOT)
	)


static func is_cdn_image(res_path: String) -> bool:
	var ext := res_path.get_extension().to_lower()
	if ext != "png" and ext != "webp" and ext != "jpg" and ext != "jpeg":
		return false
	if res_path.begins_with("res://addons/") or res_path.begins_with("res://.godot/"):
		return false
	return res_path.begins_with("res://")


static func is_cdn_asset(res_path: String) -> bool:
	return is_cdn_model(res_path) or is_cdn_image(res_path)


static func _rel_for_res_model(res_path: String) -> String:
	if res_path.begins_with(RES_MODELS_ROOT):
		return res_path.substr(RES_MODELS_ROOT.length())
	if res_path.begins_with(RES_RUNNER_ROOT):
		return "runner_60s/" + res_path.substr(RES_RUNNER_ROOT.length())
	if res_path.begins_with(RES_MVP_ROOT):
		return "mvp/" + res_path.substr(RES_MVP_ROOT.length())
	return ""


static func _encode_rel(rel: String) -> String:
	var parts := rel.split("/")
	var enc: PackedStringArray = []
	for part in parts:
		enc.append(String(part).uri_encode())
	return "/".join(enc)


static func remote_url_for_res_model(res_path: String) -> String:
	var rel := _rel_for_res_model(res_path)
	if rel.is_empty():
		return ""
	return CDN_BASE_URL.strip_edges().trim_suffix("/") + "/" + _encode_rel(rel)


static func cache_path_for_res_model(res_path: String) -> String:
	var rel := _rel_for_res_model(res_path)
	if rel.is_empty():
		return res_path
	return CACHE_ROOT + rel


static func remote_url_for_res_image(res_path: String) -> String:
	var rel := res_path.trim_prefix("res://")
	if rel.is_empty():
		return ""
	return CDN_IMAGE_BASE_URL.strip_edges().trim_suffix("/") + "/" + _encode_rel(rel)


static func cache_path_for_res_image(res_path: String) -> String:
	return IMAGE_CACHE_ROOT + res_path.trim_prefix("res://")


static func remote_url_for_res(res_path: String) -> String:
	if is_cdn_model(res_path):
		return remote_url_for_res_model(res_path)
	if is_cdn_image(res_path):
		return remote_url_for_res_image(res_path)
	return ""


static func cache_path_for_res(res_path: String) -> String:
	if is_cdn_model(res_path):
		return cache_path_for_res_model(res_path)
	if is_cdn_image(res_path):
		return cache_path_for_res_image(res_path)
	return res_path


static func manifest_paths(group: String) -> Array[String]:
	var out: Array[String] = []
	if not FileAccess.file_exists(IMAGE_MANIFEST):
		return out
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(IMAGE_MANIFEST))
	if parsed is Dictionary:
		for item in (parsed as Dictionary).get(group, []):
			var path := String(item)
			if path != "":
				out.append(path)
	return out
