extends RefCounted
class_name CharacterProgression

## 星火信使 · 可存档等级与属性设定

const CHARACTER_ID := "elsa"
const CHARACTER_NAME := "Elsa"
const MAX_LEVEL := 30
const MAX_STAT_LEVEL := 5

const XP_BY_GRADE := {
	"Perfect": 120,
	"Clean": 90,
	"Stable": 70,
	"Damaged": 45,
	"Failed": 25,
	# 兼容旧存档结算
	"S": 120,
	"A": 90,
	"B": 70,
	"C": 45,
	"F": 25,
}
const XP_PER_DIFFICULTY := 15
const FIRST_CLEAR_XP_BONUS := 40

const STAT_CARGO_GUARD := "cargo_guard"
const STAT_COIN_BONUS := "coin_bonus"
const STAT_MOBILITY := "mobility"

const STAT_LABELS := {
	STAT_CARGO_GUARD: "完整度保护",
	STAT_COIN_BONUS: "星火币收益",
	STAT_MOBILITY: "机动响应",
}

const UPGRADE_COSTS := {
	STAT_CARGO_GUARD: [80, 120, 180, 260, 360],
	STAT_COIN_BONUS: [80, 120, 180, 260, 360],
	STAT_MOBILITY: [80, 120, 180, 260, 360],
}

const TITLE_BY_LEVEL := [
	{"min_level": 1, "title": "见习信使"},
	{"min_level": 5, "title": "边境信使"},
	{"min_level": 10, "title": "星火信使"},
	{"min_level": 18, "title": "黎明线信使"},
	{"min_level": 25, "title": "零潮行者"},
]


static func xp_required_for_next_level(level: int) -> int:
	return 80 + maxi(level, 1) * 40


static func total_xp_for_level(level: int) -> int:
	var total := 0
	for current in range(1, maxi(level, 1)):
		total += xp_required_for_next_level(current)
	return total


static func level_from_xp(xp: int) -> int:
	var level := 1
	var remaining := maxi(xp, 0)
	while level < MAX_LEVEL:
		var need := xp_required_for_next_level(level)
		if remaining < need:
			break
		remaining -= need
		level += 1
	return level


static func xp_into_current_level(xp: int) -> int:
	var level := level_from_xp(xp)
	return maxi(xp - total_xp_for_level(level), 0)


static func title_for_level(level: int) -> String:
	var result := "见习信使"
	for entry in TITLE_BY_LEVEL:
		if level >= int(entry["min_level"]):
			result = String(entry["title"])
	return result


static func runner_xp_reward(grade: String, difficulty: int, first_clear: bool) -> int:
	var reward := int(XP_BY_GRADE.get(grade, XP_BY_GRADE["Damaged"]))
	reward += maxi(difficulty - 1, 0) * XP_PER_DIFFICULTY
	if first_clear:
		reward += FIRST_CLEAR_XP_BONUS
	return reward


static func cargo_damage_multiplier(cargo_guard_level: int) -> float:
	var level := clampi(cargo_guard_level, 0, MAX_STAT_LEVEL)
	return maxf(1.0 - level * 0.02, 0.75)


static func coin_yield_multiplier(coin_bonus_level: int) -> float:
	var level := clampi(coin_bonus_level, 0, MAX_STAT_LEVEL)
	return 1.0 + level * 0.04


static func lane_change_ease_bonus(mobility_level: int) -> float:
	var level := clampi(mobility_level, 0, MAX_STAT_LEVEL)
	return level * 1.5


static func stat_percent_text(stat_id: String, level: int) -> String:
	var clamped := clampi(level, 0, MAX_STAT_LEVEL)
	match stat_id:
		STAT_CARGO_GUARD:
			return "+%d%%" % (clamped * 2)
		STAT_COIN_BONUS:
			return "+%d%%" % (clamped * 4)
		STAT_MOBILITY:
			return "+%d%%" % (clamped * 6)
	return "+0%"


static func mobility_grade_text(mobility_level: int) -> String:
	var lane := _grade_letter(mobility_level + 1)
	var jump := _grade_letter(mobility_level)
	var slide := _grade_letter(mobility_level + 1)
	return "换道 %s · 跳跃 %s · 滑铲 %s" % [lane, jump, slide]


static func upgrade_cost(stat_id: String, current_level: int) -> int:
	var costs: Array = UPGRADE_COSTS.get(stat_id, [])
	if current_level < 0 or current_level >= costs.size():
		return -1
	return int(costs[current_level])


static func can_upgrade(stat_id: String, current_level: int, ember_coins: int) -> bool:
	if current_level >= MAX_STAT_LEVEL:
		return false
	var cost := upgrade_cost(stat_id, current_level)
	return cost >= 0 and ember_coins >= cost


static func build_snapshot(
	level: int,
	xp: int,
	cargo_guard_level: int,
	coin_bonus_level: int,
	mobility_level: int,
	ember_coins: int,
	unlocked_stories: Array[String]
) -> Dictionary:
	var current_level := level_from_xp(xp)
	var xp_need := xp_required_for_next_level(current_level) if current_level < MAX_LEVEL else 0
	var xp_into := xp_into_current_level(xp)
	return {
		"character_id": CHARACTER_ID,
		"character_name": CHARACTER_NAME,
		"level": current_level,
		"xp": xp,
		"xp_into_level": xp_into,
		"xp_to_next": xp_need,
		"title": title_for_level(current_level),
		"cargo_guard_level": cargo_guard_level,
		"coin_bonus_level": coin_bonus_level,
		"mobility_level": mobility_level,
		"cargo_guard_text": stat_percent_text(STAT_CARGO_GUARD, cargo_guard_level),
		"coin_bonus_text": stat_percent_text(STAT_COIN_BONUS, coin_bonus_level),
		"mobility_text": stat_percent_text(STAT_MOBILITY, mobility_level),
		"mobility_grade_text": mobility_grade_text(mobility_level),
		"ember_coins": ember_coins,
		"unlocked_stories": unlocked_stories.duplicate(),
		"has_dome_story": unlocked_stories.has("dome_resident"),
	}


static func _grade_letter(score: int) -> String:
	if score >= 5:
		return "A"
	if score >= 3:
		return "B"
	return "C"
