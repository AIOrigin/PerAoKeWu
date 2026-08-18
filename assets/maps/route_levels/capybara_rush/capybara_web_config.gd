class_name CapybaraWebConfig
extends RefCounted

## 网页版 CDN 配置（部署 S3/CloudFront 后填写 BASE_URL）
## 桌面/F6 本地运行留空即可，仍从 res:// 读模型。

const RES_MODELS_ROOT := "res://assets/maps/route_levels/capybara_rush/models/"

## CloudFront（OriginPath=/public，URL 里不要写 public/）
## https://de0csn75w3vhy.cloudfront.net/games/capybara-rush/capybara/models
const CDN_BASE_URL := "https://de0csn75w3vhy.cloudfront.net/games/capybara-rush/capybara/models"

## Web 导出时在 exclude_filter 中排除 models/，运行时从此 CDN 拉取
const CACHE_ROOT := "user://capybara_cdn/models/"


static func cdn_enabled() -> bool:
	return OS.has_feature("web") and not CDN_BASE_URL.strip_edges().is_empty()


static func remote_url_for_res_model(res_path: String) -> String:
	if not res_path.begins_with(RES_MODELS_ROOT):
		return ""
	var rel := res_path.substr(RES_MODELS_ROOT.length())
	return CDN_BASE_URL.strip_edges().trim_suffix("/") + "/" + rel


static func cache_path_for_res_model(res_path: String) -> String:
	if not res_path.begins_with(RES_MODELS_ROOT):
		return res_path
	var rel := res_path.substr(RES_MODELS_ROOT.length())
	return CACHE_ROOT + rel
