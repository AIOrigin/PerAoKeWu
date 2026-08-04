extends RefCounted
class_name CharacterRoster

## 星火信使 · 可切换角色档案与背景故事

const CHAR_ELSA := "elsa"
const CHAR_ROOK := "rook"

const CHARACTERS := {
	CHAR_ELSA: {
		"id": CHAR_ELSA,
		"runner_code": "R-07",
		"name": "Elsa",
		"name_en": "ELSA",
		"badge": "E",
		"title": "黎明线信使",
		"unlock_story_id": "",
		"unlock_banner": "",
		"story_lock_hint": "",
		"portrait_path": "res://assets/maps/route_levels/mobile_home/ui_character/elsa_fullbody.png",
		"hero_path": "res://assets/maps/route_levels/mobile_home/ui_character/elsa_fullbody.png",
		"story_art_path": "res://assets/maps/route_levels/mobile_home/ui_character/elsa_story.jpeg",
		"quote": "I run because a messenger once ran for me, now it's my turn to carry hope into the distance.",
		"quote_zh": "我奔跑，因为曾有信使为我奔来；现在轮到我，把希望送向远方。",
		"section_why": "WHY SHE RUNS",
		"section_background": "BACKGROUND",
		"quote_in_art": true,
		"trait_name": "疾风 - II",
		"trait_gear": "轻型外骨骼",
		"trait_desc": "短冲刺后速度提升，擅长低负重与精准闪避。",
		"trait_tag": "被动特性 · 战术机动",
		"hub_stats": [
			{"icon": "sp", "label": "SPEED", "value": "100", "pct": 78},
			{"icon": "hp", "label": "HP", "value": "100", "pct": 60},
			{"icon": "en", "label": "STAMINA", "value": "100", "pct": 60},
		],
		"gear": [
			{
				"slot": "BOOTS",
				"icon_key": "boots",
				"equipped": true,
				"name": "Swiftstride Boots",
				"rarity": "rare",
				"rarity_label": "RARE",
				"fx": "+12% SPEED",
			},
			{
				"slot": "CORE",
				"icon_key": "core",
				"equipped": true,
				"name": "Power Reactor Core",
				"rarity": "epic",
				"rarity_label": "EPIC",
				"fx": "+20% HP",
			},
			{
				"slot": "SHIELD",
				"icon_key": "shield",
				"equipped": true,
				"name": "Impact Shield",
				"rarity": "rare",
				"rarity_label": "RARE",
				"fx": "+15% IMPACT RESIST",
			},
		],
		"stats": [
			{"id": "hp", "label": "生命", "value": "105", "fill": 0.72},
			{"id": "stamina", "label": "耐力", "value": "100", "fill": 0.68},
			{"id": "speed", "label": "速度", "value": "100%", "fill": 0.85},
			{"id": "load", "label": "载重", "value": "100", "fill": 0.55},
			{"id": "cargo", "label": "货物稳定", "value": "100", "fill": 0.78},
		],
		"story_paragraphs": [
			"七岁那年，Elsa所在的地下掩体因净化系统故障，面临全灭的绝境。在掩体大门即将永久封死的那一刻，一个浑身是血的星火信使倒在了门外，手里紧紧攥着那枚救命的维修零件。",
			"从那天起，这个没有见过蓝天的孤儿明白了：在这片被零潮污染的死地里，人类唯一的希望，就是跑得比死亡更快。",
			"十五岁，她用废旧快递无人机的零件，为自己拼凑出了一套简陋的轻型外骨骼。别人说这套装备防御力为零，她却笑着说速度就是最好的防御。今天，她是荒原上最年轻的星火信使。只要她没倒下，希望就一定能准时送达。",
		],
		"story_paragraphs_en": [
			"At seven, Elsa's underground shelter was on the brink of collapse after its purification system failed.",
			"As the gates were closing, a wounded Ember Runner arrived with the last repair core needed to save the shelter.",
			"That day, Elsa learned that even in a world consumed by the Zero Tide, someone would still risk everything to deliver hope.",
			"At fifteen, she built her own lightweight exoskeleton from scrap parts and became the youngest Ember Runner in the wasteland.",
			"Some said her gear was too fragile.",
			"But she believed: \"Speed is the best defense.\"",
			"Now, Elsa carries supplies across deadly lands — because someone once ran this path for her.",
			"Now, it's her turn to carry hope forward.",
		],
	},
	CHAR_ROOK: {
		"id": CHAR_ROOK,
		"runner_code": "R-02",
		"name": "Rook",
		"name_en": "ROOK",
		"badge": "R",
		"title": "穹顶守护者",
		"unlock_story_id": "dome_resident",
		"unlock_banner": "LIGHT UP HABITAT DOME TO UNLOCK",
		"story_lock_hint": "Complete the story of Habitat Dome to read this archive.",
		"portrait_path": "res://assets/maps/route_levels/mobile_home/ui_character/rook_fullbody.png",
		"hero_path": "res://assets/maps/route_levels/mobile_home/ui_character/rook_fullbody.png",
		"story_art_path": "res://assets/maps/route_levels/mobile_home/ui_character/rook_story.jpeg",
		"quote": "I run because in her eyes, I saw the sister I couldn't save — this time, I will be the shield that never falls.",
		"quote_zh": "因为在她眼里，我看见了未能守护的妹妹——这一次，我要做永不倒下的盾。",
		"section_why": "WHY HE RUNS",
		"section_background": "BACKGROUND",
		"quote_in_art": true,
		"trait_name": "堡垒 - IV",
		"trait_gear": "重装战甲",
		"trait_desc": "高防御与护货优先，冲刺短但抗压强，适合危险路段护航。",
		"trait_tag": "被动特性 · 重装护卫",
		"hub_stats": [
			{"icon": "sp", "label": "SPEED", "value": "85", "pct": 50},
			{"icon": "hp", "label": "HP", "value": "130", "pct": 72},
			{"icon": "en", "label": "STAMINA", "value": "120", "pct": 65},
		],
		"gear": [
			{"slot": "BOOTS", "icon_key": "boots", "locked": true},
			{"slot": "CORE", "icon_key": "core", "locked": true},
			{"slot": "SHIELD", "icon_key": "shield", "locked": true},
		],
		"stats": [
			{"id": "hp", "label": "生命", "value": "140", "fill": 0.90},
			{"id": "stamina", "label": "耐力", "value": "90", "fill": 0.58},
			{"id": "speed", "label": "速度", "value": "78%", "fill": 0.45},
			{"id": "load", "label": "载重", "value": "130", "fill": 0.88},
			{"id": "cargo", "label": "货物稳定", "value": "120", "fill": 0.92},
		],
		"story_paragraphs": [
			"零潮爆发时，Rook 曾是最强的重装防暴军官，驾驶「堡垒-IV」保护幸存者撤离。但那一天，他没能救下自己的妹妹。废墟中，他伸出的机械臂只抓住了妹妹留下的发带。",
			"从此，他封存战甲，成为居民穹顶里的维修工。直到一天，一个年轻女孩带着受损的运输包冲进穹顶。面对逼近的变异机械，她没有逃跑，而是死死护住货物。那双倔强的眼睛，让 Rook 想起了曾经没能保护的妹妹。",
			"他终于明白，自己无法改变过去，但可以守护未来。于是，他重新启动「堡垒-IV」。这一次，他不是为了战斗。而是为了成为那个女孩身后，永远不会倒下的盾牌。",
		],
		"story_paragraphs_en": [],
	},
}


static func get_character(character_id: String) -> Dictionary:
	var data: Variant = CHARACTERS.get(character_id, {})
	if data is Dictionary and not data.is_empty():
		return (data as Dictionary).duplicate(true)
	return (CHARACTERS[CHAR_ELSA] as Dictionary).duplicate(true)


static func ordered_ids() -> Array[String]:
	return [CHAR_ELSA, CHAR_ROOK]


static func is_unlocked(character_id: String, unlocked_stories: Array) -> bool:
	var data := get_character(character_id)
	var unlock_id := String(data.get("unlock_story_id", ""))
	if unlock_id == "":
		return true
	return unlocked_stories.has(unlock_id)


static func next_id(current_id: String) -> String:
	var ids := ordered_ids()
	var start := ids.find(current_id)
	if start < 0:
		start = 0
	return ids[(start + 1) % ids.size()]


static func prev_id(current_id: String) -> String:
	var ids := ordered_ids()
	var start := ids.find(current_id)
	if start < 0:
		start = 0
	return ids[(start - 1 + ids.size()) % ids.size()]


static func next_unlocked_id(current_id: String, unlocked_stories: Array) -> String:
	return _step_unlocked_id(current_id, unlocked_stories, 1)


static func prev_unlocked_id(current_id: String, unlocked_stories: Array) -> String:
	return _step_unlocked_id(current_id, unlocked_stories, -1)


static func story_paragraphs_for_ui(character: Dictionary) -> Array:
	var en: Array = character.get("story_paragraphs_en", [])
	if not en.is_empty():
		return en
	return character.get("story_paragraphs", [])


static func _step_unlocked_id(current_id: String, unlocked_stories: Array, step: int) -> String:
	var ids := ordered_ids()
	var start := ids.find(current_id)
	if start < 0:
		start = 0
	var dir := 1 if step >= 0 else -1
	for i in ids.size():
		var idx := (start + dir * (i + 1) + ids.size() * 8) % ids.size()
		var candidate := ids[idx]
		if is_unlocked(candidate, unlocked_stories):
			return candidate
	return CHAR_ELSA


static func load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex:
			return tex
	var abs_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(abs_path):
		return null
	var img := Image.new()
	if img.load(abs_path) != OK:
		return null
	return ImageTexture.create_from_image(img)
