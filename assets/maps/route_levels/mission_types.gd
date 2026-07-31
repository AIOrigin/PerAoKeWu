extends RefCounted
class_name MissionTypes

## 五种运输任务类型：时长 / 障碍密度 / 限时 / 追击（对齐《星火信使机制梳理》）

const RUN_SPEED := 14.0
const RUN_SPEED_MAX := 24.0
const BASE_DURATION := 60.0
const BASE_TRACK_LENGTH := BASE_DURATION * (RUN_SPEED + RUN_SPEED_MAX) * 0.5

## 规范键 → 参数
const PROFILES := {
	"Supply Run": {
		"id": "supply",
		"name_zh": "补给",
		"duration": 52.0,
		"obstacle_density": 0.65,
		"timed_fail": false,
		"time_bonus": false,
		"enable_chaser": false,
		"fork_bias": false,
		"base_reward": 120,
		"hint": "障碍较少 · 熟悉换道与跳跃",
	},
	"Repair Run": {
		"id": "repair",
		"name_zh": "抢修",
		"duration": 65.0,
		"obstacle_density": 1.3,
		"timed_fail": false,
		"time_bonus": false,
		"enable_chaser": false,
		"fork_bias": false,
		"base_reward": 150,
		"hint": "障碍密集 · 时间相对宽裕",
	},
	"Emergency Run": {
		"id": "emergency",
		"name_zh": "紧急",
		"duration": 40.0,
		"obstacle_density": 1.0,
		"timed_fail": true,
		"time_bonus": true,
		"enable_chaser": false,
		"fork_bias": false,
		"base_reward": 180,
		"hint": "强制限时 · 剩余时间提高奖励倍率",
	},
	"Relay Run": {
		"id": "relay",
		"name_zh": "中继",
		"duration": 75.0,
		"obstacle_density": 1.1,
		"timed_fail": false,
		"time_bonus": false,
		"enable_chaser": false,
		"fork_bias": true,
		"base_reward": 200,
		"hint": "长距运输 · 多分叉选择",
	},
	"Ignition Run": {
		"id": "ignition",
		"name_zh": "点火",
		"duration": 80.0,
		"obstacle_density": 1.2,
		"timed_fail": false,
		"time_bonus": false,
		"enable_chaser": true,
		"fork_bias": false,
		"base_reward": 250,
		"hint": "高压点火 · 零潮追击开启",
	},
}

const _ALIASES := {
	"supply": "Supply Run",
	"supply run": "Supply Run",
	"补给": "Supply Run",
	"repair": "Repair Run",
	"repair run": "Repair Run",
	"抢修": "Repair Run",
	"emergency": "Emergency Run",
	"emergency run": "Emergency Run",
	"紧急": "Emergency Run",
	"relay": "Relay Run",
	"relay run": "Relay Run",
	"中继": "Relay Run",
	"ignition": "Ignition Run",
	"ignition run": "Ignition Run",
	"点火": "Ignition Run",
}


static func normalize_type(raw: String) -> String:
	var key := raw.strip_edges()
	if key == "":
		return "Supply Run"
	if PROFILES.has(key):
		return key
	var lower := key.to_lower()
	if _ALIASES.has(lower):
		return String(_ALIASES[lower])
	if _ALIASES.has(key):
		return String(_ALIASES[key])
	return "Supply Run"


static func resolve(mission: Dictionary = {}) -> Dictionary:
	var type_key := normalize_type(String(mission.get("task_type", "Supply Run")))
	var profile: Dictionary = PROFILES[type_key].duplicate(true)
	profile["task_type"] = type_key
	if mission.has("duration") and float(mission.get("duration", 0.0)) > 0.0:
		profile["duration"] = float(mission["duration"])
	return profile


static func track_length_for(duration: float) -> float:
	return maxf(duration, 1.0) * (RUN_SPEED + RUN_SPEED_MAX) * 0.5


static func display_name(mission: Dictionary = {}) -> String:
	var profile := resolve(mission)
	return "%s（%s）" % [String(profile.get("name_zh", "补给")), String(profile.get("task_type", "Supply Run"))]


static func short_label(mission: Dictionary = {}) -> String:
	return String(resolve(mission).get("name_zh", "补给"))


static func enrich_mission(mission: Dictionary) -> Dictionary:
	if mission.is_empty():
		return mission
	var out: Dictionary = mission.duplicate(true)
	var profile := resolve(out)
	out["task_type"] = String(profile.get("task_type", "Supply Run"))
	out["duration"] = float(profile.get("duration", BASE_DURATION))
	out["task_type_zh"] = String(profile.get("name_zh", "补给"))
	out["task_hint"] = String(profile.get("hint", ""))
	out["base_reward"] = int(profile.get("base_reward", 0))
	return out


static func adapt_obstacles(items: Array, profile: Dictionary, track_length: float) -> Array:
	var density := clampf(float(profile.get("obstacle_density", 1.0)), 0.35, 2.0)
	var fork_bias := bool(profile.get("fork_bias", false))
	var scale := track_length / BASE_TRACK_LENGTH
	var finish_cut := maxf(track_length - 24.0, track_length * 0.92)
	var result: Array = []
	var keep_budget := 0.0
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = (raw as Dictionary).duplicate(true)
		var otype := String(item.get("type", ""))
		# 主路封堵 / 侧轨入口跳板：与 SIDE_RUNWAY_ZONES 绝对距离对齐，不缩放、不抽稀
		if otype in ["main_block", "ramp"] and int(item.get("layer", 0)) == 0:
			var abs_dist := float(item.get("distance", 0.0))
			if abs_dist < finish_cut:
				item["distance"] = abs_dist
				result.append(item)
			continue
		var dist := float(item.get("distance", 0.0)) * scale
		if dist < 40.0 or dist > finish_cut:
			continue
		item["distance"] = dist
		var is_fork_sign := otype in ["turn_left", "turn_right"]
		if is_fork_sign:
			if fork_bias or density >= 0.85:
				result.append(item)
			continue
		if density >= 0.999:
			result.append(item)
		else:
			keep_budget += density
			if keep_budget >= 1.0:
				keep_budget -= 1.0
				result.append(item)
	if density > 1.05:
		var extras: Array = []
		var combat_i := 0
		for raw in result:
			var item: Dictionary = raw
			var otype := String(item.get("type", ""))
			if otype not in ["jump", "slide", "train", "block_left", "block_right"]:
				continue
			combat_i += 1
			# 确定性加密：按密度多塞若干中间障碍
			var copies := int(floor(density - 1.0 + 0.001))
			if combat_i % 2 == 0:
				copies += 1
			for c in range(mini(copies, 2)):
				var extra: Dictionary = item.duplicate(true)
				extra["distance"] = float(item.get("distance", 0.0)) + 26.0 + float(c) * 18.0
				if float(extra["distance"]) < finish_cut:
					extras.append(extra)
		result.append_array(extras)
	return result


static func adapt_coin_distances(dists: Array, track_length: float, density: float = 1.0) -> Array:
	var scale := track_length / BASE_TRACK_LENGTH
	var spacing_keep := clampf(0.75 + density * 0.25, 0.55, 1.2)
	var finish_cut := maxf(track_length - 30.0, track_length * 0.9)
	var result: Array = []
	var budget := 0.0
	for raw in dists:
		var dist := float(raw) * scale
		if dist < 20.0 or dist > finish_cut:
			continue
		budget += spacing_keep
		if budget >= 1.0:
			budget -= 1.0
			result.append(dist)
	return result


static func adapt_side_runway_coins(coins: Array, track_length: float) -> Array:
	# 与 SIDE_RUNWAY_ZONES 绝对距离对齐：不缩放、不按密度抽稀
	var finish_cut := maxf(track_length - 30.0, track_length * 0.9)
	var result: Array = []
	for raw in coins:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = (raw as Dictionary).duplicate(true)
		var dist := float(item.get("distance", 0.0))
		if dist < 20.0 or dist > finish_cut:
			continue
		result.append(item)
	return result


static func adapt_main_runway_coins(coins: Array, track_length: float, density: float = 1.0) -> Array:
	var scale := track_length / BASE_TRACK_LENGTH
	var spacing_keep := clampf(0.75 + density * 0.25, 0.55, 1.2)
	var finish_cut := maxf(track_length - 30.0, track_length * 0.9)
	var result: Array = []
	var budget := 0.0
	for raw in coins:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = (raw as Dictionary).duplicate(true)
		var dist := float(item.get("distance", 0.0)) * scale
		if dist < 20.0 or dist > finish_cut:
			continue
		budget += spacing_keep
		if budget >= 1.0:
			budget -= 1.0
			item["distance"] = dist
			result.append(item)
	return result


static func time_bonus_multiplier(profile: Dictionary, elapsed: float, run_time: float) -> float:
	if not bool(profile.get("time_bonus", false)):
		return 1.0
	var safe_time := maxf(run_time, 1.0)
	var remain := clampf(safe_time - elapsed, 0.0, safe_time)
	# 剩余越多倍率越高：准时到达约 1.0，剩余一半约 1.5，几乎立刻完成约 2.0
	return 1.0 + remain / safe_time
