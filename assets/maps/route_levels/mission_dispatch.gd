extends RefCounted
class_name MissionDispatch

## 批次解锁 + 3 槽缺口派发（对齐《星火信使机制梳理》）

const BOARD_SLOT_COUNT := 3
## 批次未解锁时仍可在 Tasks / 地图详情预览（不进入任务板派发）
const PREVIEW_LOCATIONS := {
	"glass_desert": ["relay"],
}
## 关卡调优：预览据点允许「试玩体验」进跑酷（暂不计入任务板接取）
const ALLOW_PREVIEW_TRIAL_RUN := true
const DEFAULT_BATCHES := [
	{"id": 1, "name": "生存基础", "locations": ["dome", "reservoir"]},
	{"id": 2, "name": "危机应对", "locations": ["medical", "gate"]},
	{"id": 3, "name": "网络核心", "locations": ["relay"]},
]


static func get_batches(planet_id: String) -> Array:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_mission_batches"):
		var custom: Array = cfg.get_mission_batches()
		if not custom.is_empty():
			return custom
	if planet_id == "glass_desert" or planet_id == "":
		return DEFAULT_BATCHES.duplicate(true)
	return DEFAULT_BATCHES.duplicate(true)


static func get_batch_meta(planet_id: String, batch_id: int) -> Dictionary:
	for entry in get_batches(planet_id):
		if int(entry.get("id", 0)) == batch_id:
			return entry
	return {}


static func get_location_batch_id(planet_id: String, location_id: String) -> int:
	for entry in get_batches(planet_id):
		for id in entry.get("locations", []):
			if String(id) == location_id:
				return int(entry.get("id", 0))
	return 0


static func get_batch_location_ids(planet_id: String, up_to_batch: int) -> Array[String]:
	var result: Array[String] = []
	for entry in get_batches(planet_id):
		var batch_id := int(entry.get("id", 0))
		if batch_id <= 0 or batch_id > up_to_batch:
			continue
		for id in entry.get("locations", []):
			var location_id := String(id)
			if location_id != "" and not result.has(location_id):
				result.append(location_id)
	return result


static func get_batch1_location_ids(planet_id: String) -> Array[String]:
	return get_batch_location_ids(planet_id, 1)


## 当前应解锁到第几批：
## 1 初始开放居民穹顶+水源据点任务；2=批次1任一据点点亮后开放医疗+防御哨站；3=批次1+2平均进度≥85%
static func compute_unlocked_batch(planet_id: String) -> int:
	var batches := get_batches(planet_id)
	if batches.is_empty():
		return 1
	var unlocked := 1
	# Batch 2：批次1任一据点进度 100%（已点亮）
	var batch1_ids := get_batch_location_ids(planet_id, 1)
	var any_batch1_lit := false
	for location_id in batch1_ids:
		if Global.get_completed_runner_locations(planet_id).has(location_id):
			any_batch1_lit = true
			break
	if any_batch1_lit:
		unlocked = 2
	# Batch 3：前两批所有据点平均进度 ≥ 85%
	if unlocked >= 2:
		var early_ids := get_batch_location_ids(planet_id, 2)
		if not early_ids.is_empty():
			var sum_pct := 0.0
			for location_id in early_ids:
				var total: int = maxi(1, Global.get_outpost_repair_total(planet_id, location_id))
				var current: int = Global.get_outpost_progress(planet_id, location_id)
				sum_pct += clampf(float(current) / float(total) * 100.0, 0.0, 100.0)
			var avg := sum_pct / float(early_ids.size())
			if avg >= 85.0:
				unlocked = 3
	return clampi(unlocked, 1, batches.size())


static func is_location_batch_unlocked(planet_id: String, location_id: String, unlocked_batch: int = -1) -> bool:
	var batch_id := get_location_batch_id(planet_id, location_id)
	if batch_id <= 0:
		return false
	var unlocked := unlocked_batch if unlocked_batch > 0 else compute_unlocked_batch(planet_id)
	return batch_id <= unlocked


static func is_preview_location(planet_id: String, location_id: String) -> bool:
	var ids: Array = PREVIEW_LOCATIONS.get(planet_id, [])
	if not ids.has(location_id):
		return false
	return not is_location_batch_unlocked(planet_id, location_id)


static func can_preview_trial_run(planet_id: String, location_id: String) -> bool:
	return ALLOW_PREVIEW_TRIAL_RUN and is_preview_location(planet_id, location_id)


static func gap_priority(planet_id: String, location_id: String) -> float:
	if Global.get_completed_runner_locations(planet_id).has(location_id):
		return 0.0
	var total := maxi(1, Global.get_outpost_repair_total(planet_id, location_id))
	var current := clampi(Global.get_outpost_progress(planet_id, location_id), 0, total)
	return float(total - current) / float(total) * 100.0


static func _mission_order(planet_id: String, location_id: String) -> int:
	var cfg: Script = PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null
	if cfg != null and cfg.has_method("get_mission_for_location"):
		var mission: Dictionary = cfg.get_mission_for_location(location_id)
		return int(mission.get("order", 999))
	return 999


## 可进任务板的据点：已解锁批次、未点亮，按缺口优先（同缺口看 order 升序）
static func list_board_candidates(planet_id: String, unlocked_batch: int = -1) -> Array[String]:
	var unlocked := unlocked_batch if unlocked_batch > 0 else compute_unlocked_batch(planet_id)
	var candidates: Array[String] = []
	for location_id in get_batch_location_ids(planet_id, unlocked):
		if Global.get_completed_runner_locations(planet_id).has(location_id):
			continue
		candidates.append(location_id)
	candidates.sort_custom(func(a: String, b: String) -> bool:
		var gap_a := gap_priority(planet_id, a)
		var gap_b := gap_priority(planet_id, b)
		if not is_equal_approx(gap_a, gap_b):
			return gap_a > gap_b
		return _mission_order(planet_id, a) < _mission_order(planet_id, b)
	)
	return candidates


static func sanitize_board(planet_id: String, board: Array, unlocked_batch: int) -> Array[String]:
	var result: Array[String] = []
	for raw in board:
		var location_id := String(raw)
		if location_id == "":
			continue
		if Global.get_completed_runner_locations(planet_id).has(location_id):
			continue
		if not is_location_batch_unlocked(planet_id, location_id, unlocked_batch):
			continue
		if not result.has(location_id):
			result.append(location_id)
	return result


static func fill_board_slots(planet_id: String, board: Array, unlocked_batch: int = -1) -> Array[String]:
	return fill_mission_board_slots(planet_id, board, unlocked_batch)


static func _runner_config(planet_id: String) -> Script:
	return PlanetDatabase.get_runner_config(planet_id) if planet_id != "" else null


static func _is_valid_mission_id(planet_id: String, mission_id: String) -> bool:
	if mission_id == "":
		return false
	var cfg := _runner_config(planet_id)
	if cfg != null and cfg.has_method("get_mission_by_id"):
		return not cfg.get_mission_by_id(mission_id).is_empty()
	return false


static func _migrate_slot_to_mission_id(planet_id: String, slot: String) -> String:
	var id := String(slot).strip_edges()
	if id == "":
		return ""
	if _is_valid_mission_id(planet_id, id):
		return id
	var cfg := _runner_config(planet_id)
	if cfg != null and cfg.has_method("get_missions_for_location"):
		var matches: Array = cfg.get_missions_for_location(id)
		if not matches.is_empty():
			return Global.mission_key(matches[0] as Dictionary)
	if cfg != null and cfg.has_method("get_mission_for_location"):
		return Global.mission_key(cfg.get_mission_for_location(id))
	return ""


## 可进任务板的 mission：批次已解锁、据点未点亮
static func list_mission_board_candidates(planet_id: String, unlocked_batch: int = -1) -> Array[String]:
	var cfg := _runner_config(planet_id)
	if cfg == null or not cfg.has_method("get_location_missions"):
		return []
	var unlocked := unlocked_batch if unlocked_batch > 0 else compute_unlocked_batch(planet_id)
	var candidates: Array[String] = []
	for raw in cfg.get_location_missions():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var mission: Dictionary = raw
		var location_id := String(mission.get("location_id", ""))
		if location_id == "":
			continue
		if Global.get_completed_runner_locations(planet_id).has(location_id):
			continue
		if not is_location_batch_unlocked(planet_id, location_id, unlocked):
			continue
		var mission_id: String = Global.mission_key(mission)
		if mission_id != "" and Global.is_mission_completed(planet_id, mission_id):
			continue
		if mission_id != "" and not candidates.has(mission_id):
			candidates.append(mission_id)
	candidates.sort_custom(func(a: String, b: String) -> bool:
		var ma: Dictionary = cfg.get_mission_by_id(a) if cfg.has_method("get_mission_by_id") else {}
		var mb: Dictionary = cfg.get_mission_by_id(b) if cfg.has_method("get_mission_by_id") else {}
		var gap_a := gap_priority(planet_id, String(ma.get("location_id", "")))
		var gap_b := gap_priority(planet_id, String(mb.get("location_id", "")))
		if not is_equal_approx(gap_a, gap_b):
			return gap_a > gap_b
		return int(ma.get("order", 999)) < int(mb.get("order", 999))
	)
	return candidates


## 任务面板：未完成、进行中、已完成待领取均展示；已领取且完成的任务隐藏
static func list_tasks_panel_missions(planet_id: String, unlocked_batch: int = -1) -> Array[String]:
	var cfg := _runner_config(planet_id)
	if cfg == null or not cfg.has_method("get_location_missions"):
		return []
	var unlocked := unlocked_batch if unlocked_batch > 0 else compute_unlocked_batch(planet_id)
	var result: Array[String] = []
	for raw in cfg.get_location_missions():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var mission: Dictionary = raw
		var location_id := String(mission.get("location_id", ""))
		if location_id == "":
			continue
		if not is_location_batch_unlocked(planet_id, location_id, unlocked):
			if not is_preview_location(planet_id, location_id):
				continue
		var mission_id: String = Global.mission_key(mission)
		if mission_id == "":
			continue
		if Global.is_mission_completed(planet_id, mission_id) and not Global.is_mission_reward_pending(planet_id, mission_id):
			continue
		if not result.has(mission_id):
			result.append(mission_id)
	result.sort_custom(func(a: String, b: String) -> bool:
		var ma: Dictionary = cfg.get_mission_by_id(a) if cfg.has_method("get_mission_by_id") else {}
		var mb: Dictionary = cfg.get_mission_by_id(b) if cfg.has_method("get_mission_by_id") else {}
		return int(ma.get("order", 999)) < int(mb.get("order", 999))
	)
	return result


static func sanitize_mission_board(planet_id: String, board: Array, unlocked_batch: int) -> Array[String]:
	var cfg := _runner_config(planet_id)
	var result: Array[String] = []
	for raw in board:
		var mission_id: String = _migrate_slot_to_mission_id(planet_id, String(raw))
		if mission_id == "":
			continue
		var mission: Dictionary = {}
		if cfg != null and cfg.has_method("get_mission_by_id"):
			mission = cfg.get_mission_by_id(mission_id)
		if mission.is_empty():
			continue
		var location_id := String(mission.get("location_id", ""))
		if Global.get_completed_runner_locations(planet_id).has(location_id):
			continue
		if not is_location_batch_unlocked(planet_id, location_id, unlocked_batch):
			continue
		if Global.is_mission_completed(planet_id, mission_id):
			continue
		if not result.has(mission_id):
			result.append(mission_id)
	return result


## 3 槽 mission 任务板；rotate_completed 为刚跑完要从板上轮换下去的 mission_id
static func fill_mission_board_slots(
	planet_id: String,
	board: Array,
	unlocked_batch: int = -1,
	rotate_completed: String = ""
) -> Array[String]:
	var unlocked := unlocked_batch if unlocked_batch > 0 else compute_unlocked_batch(planet_id)
	var slots := sanitize_mission_board(planet_id, board, unlocked)
	if rotate_completed != "":
		var rotate_idx := slots.find(rotate_completed)
		if rotate_idx >= 0:
			slots.remove_at(rotate_idx)
	while slots.size() < BOARD_SLOT_COUNT:
		var added := false
		for mission_id in list_mission_board_candidates(planet_id, unlocked):
			if slots.has(mission_id):
				continue
			slots.append(mission_id)
			added = true
			break
		if not added:
			break
	if slots.size() > BOARD_SLOT_COUNT:
		return slots.slice(0, BOARD_SLOT_COUNT)
	return slots


static func batch_unlock_summary(planet_id: String, unlocked_batch: int) -> String:
	var meta := get_batch_meta(planet_id, unlocked_batch)
	var name := String(meta.get("name", "批次%d" % unlocked_batch))
	return "批次%d · %s" % [unlocked_batch, name]
