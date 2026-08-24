class_name CapybaraWebConfig
extends RefCounted

## 网页版 CDN 配置（部署 S3/CloudFront 后填写 BASE_URL）
## 桌面/F6 本地运行留空即可，仍从 res:// 读模型。

const RES_MODELS_ROOT := "res://assets/maps/route_levels/capybara_rush/models/"

## 每次发布加 1（或改成日期如 20260819）。Web 会按此目录拉模型和本地缓存，旧版自动作废。
const ASSET_VERSION := "5"

## CloudFront（OriginPath=/public，URL 里不要写 public/）
## https://de0csn75w3vhy.cloudfront.net/games/capybara-rush/capybara/models
const CDN_BASE_URL := "https://de0csn75w3vhy.cloudfront.net/games/capybara-rush/capybara/models"

## Web 导出时在 exclude_filter 中排除 models/，运行时从此 CDN 拉取
const CACHE_ROOT := "user://capybara_cdn/"


static func asset_version() -> String:
	var v := ASSET_VERSION.strip_edges()
	return v if not v.is_empty() else "0"


static func cdn_enabled() -> bool:
	return OS.has_feature("web") and not CDN_BASE_URL.strip_edges().is_empty()


static func remote_url_for_res_model(res_path: String) -> String:
	if not res_path.begins_with(RES_MODELS_ROOT):
		return ""
	var rel := res_path.substr(RES_MODELS_ROOT.length())
	return "%s/%s/%s" % [CDN_BASE_URL.strip_edges().trim_suffix("/"), asset_version(), rel]


static func cache_path_for_res_model(res_path: String) -> String:
	if not res_path.begins_with(RES_MODELS_ROOT):
		return res_path
	var rel := res_path.substr(RES_MODELS_ROOT.length())
	return "%s%s/%s" % [CACHE_ROOT, asset_version(), rel]
