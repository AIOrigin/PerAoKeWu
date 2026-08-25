extends RefCounted
class_name MissionTypes

## 五种运输任务类型：时长 / 障碍密度 / 限时 / 追击（对齐《星火信使机制梳理》）

const RUN_SPEED := 14.0
const RUN_SPEED_MAX := 24.0
const BASE_DURATION := 60.0
const BASE_TRACK_LENGTH := BASE_DURATION * (RUN_SPEED + RUN_SPEED_MAX) * 0.5
const MISSION_PROGRESS_TARGET := 100

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
	"supply run v1": "Supply Run",
	"supply run v2": "Supply Run",
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
	if mission.has("obstacle_density"):
		profile["obstacle_density"] = clampf(float(mission["obstacle_density"]), 0.35, 2.0)
	if mission.has("fork_bias"):
		profile["fork_bias"] = bool(mission["fork_bias"])
	if mission.has("enable_chaser"):
		profile["enable_chaser"] = bool(mission["enable_chaser"])
	if mission.has("chaser_creep_mult"):
		profile["chaser_creep_mult"] = clampf(float(mission["chaser_creep_mult"]), 0.5, 2.0)
	if mission.has("pressure_chaser"):
		profile["pressure_chaser"] = bool(mission["pressure_chaser"])
	if mission.has("chaser_mode"):
		profile["chaser_mode"] = String(mission["chaser_mode"])
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
	out["task_hint"] = String(mission.get("task_hint", profile.get("hint", "")))
	if mission.has("base_reward"):
		out["base_reward"] = int(mission.get("base_reward", 0))
	else:
		out["base_reward"] = int(profile.get("base_reward", 0))
	out["progress_target"] = maxi(1, int(mission.get("progress_target", MISSION_PROGRESS_TARGET)))
	return out


## 单局完整度 → 任务进度增量（v1：S/A/B/C = +100/+70/+40/+20，阈值 95/80/60）
static func integrity_to_mission_progress(integrity_percent: float) -> int:
	var v := clampf(integrity_percent, 0.0, 100.0)
	if v >= 95.0:
		return 100
	if v >= 80.0:
		return 70
	if v >= 60.0:
		return 40
	if v > 0.0:
		return 20
	return 0


static func mission_progress_target(mission: Dictionary) -> int:
	return maxi(1, int(mission.get("progress_target", MISSION_PROGRESS_TARGET)))


## 建设包等超重货物：单击短跳、双击标准跳
static func is_overweight_cargo(mission: Dictionary) -> bool:
	if mission.is_empty():
		return false
	if String(mission.get("cargo_mechanic", "")) == "overweight":
		return true
	if "超重" in String(mission.get("cargo_trait", "")):
		return true
	var en := String(mission.get("cargo_name_en", "")).strip_edges().to_lower()
	if en == "construction kit":
		return true
	if String(mission.get("cargo_name", "")) == "建设包":
		return true
	return false


## 防御包：任意据点/关卡通用。碰撞掉损更低，开局自带防护罩能量。
static func is_defense_cargo(mission: Dictionary) -> bool:
	if mission.is_empty():
		return false
	if String(mission.get("cargo_mechanic", "")) == "defense":
		return true
	if String(mission.get("cargo_icon", "")).strip_edges() == "防御":
		return true
	var name := String(mission.get("cargo_name", ""))
	if "防御包" in name:
		return true
	if "defense pack" in String(mission.get("cargo_name_en", "")).strip_edges().to_lower():
		return true
	if "防御包" in String(mission.get("cargo_secondary", "")):
		return true
	return false


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
		var abs_dist_raw := float(item.get("distance", 0.0))
		# 开局教学区：跳跃/滑铲不缩放、不抽稀，保证前几秒两种操作都能练到
		if otype in ["jump", "slide", "high_bar", "low_barrier"] and abs_dist_raw < 88.0:
			if abs_dist_raw >= 30.0 and abs_dist_raw < finish_cut:
				item["distance"] = abs_dist_raw
				result.append(item)
			continue
		# 主路封堵 / 侧轨入口跳板：与 SIDE_RUNWAY_ZONES 绝对距离对齐，不缩放、不抽稀
		if otype in ["main_block", "ramp"] and int(item.get("layer", 0)) == 0:
			var abs_dist := abs_dist_raw
			if abs_dist < finish_cut:
				item["distance"] = abs_dist
				result.append(item)
			continue
		# 终点前陨石 / 陨石门：绝对距离摆放，避免缩放/抽稀后消失
		if otype in ["meteorite", "meteorite_gate"]:
			if abs_dist_raw >= 30.0 and abs_dist_raw < finish_cut:
				item["distance"] = abs_dist_raw
				result.append(item)
			continue
		# 终点前超大紫球：绝对距离摆放，避免缩放/抽稀后变小或消失
		var orb_size := String(item.get("orb_size", "")).strip_edges().to_lower()
		if otype == "orb" and orb_size in ["colossal", "mega", "xl"]:
			if abs_dist_raw >= 30.0 and abs_dist_raw < finish_cut:
				item["distance"] = abs_dist_raw
				result.append(item)
			continue
		var dist := abs_dist_raw * scale
		if dist < 30.0 or dist > finish_cut:
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
		var min_action_gap := 22.0
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
				var extra_dist := float(item.get("distance", 0.0)) + 26.0 + float(c) * 18.0
				if extra_dist >= finish_cut:
					continue
				# 避免插在既有跳/铲之间过近，防止铲完来不及跳
				var too_close := false
				for other in result:
					var ot := String(other.get("type", ""))
					if ot not in ["jump", "slide"]:
						continue
					if absf(float(other.get("distance", 0.0)) - extra_dist) < min_action_gap:
						too_close = true
						break
				if too_close:
					continue
				extra["distance"] = extra_dist
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
		var pattern := String(item.get("pattern", ""))
		if pattern in ["column", "cluster", "air_stream"] or bool(item.get("air", false)):
			item["distance"] = dist
			result.append(item)
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
