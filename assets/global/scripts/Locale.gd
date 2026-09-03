extends Object
class_name GameLocale
## UI 语言：中文 / English。文案用 pick() 或 t()；内容字段用 field()。
## 使用 class_name 而非 Autoload，避免 Identifier not found: Locale。

const ZH := "zh"
const EN := "en"

## key -> { "zh": "...", "en": "..." }
const STRINGS := {
	"settings_title": {"zh": "设置", "en": "Settings"},
	"settings_tip": {
		"zh": "语言、背景音乐与剧情回顾。",
		"en": "Language, BGM, and story review.",
	},
	"settings_language": {"zh": "语言", "en": "Language"},
	"settings_lang_zh": {"zh": "中文", "en": "中文"},
	"settings_lang_en": {"zh": "English", "en": "English"},
	"settings_tutorial": {"zh": "开启跑酷新手引导", "en": "Enable runner tutorials"},
	"settings_bgm_volume": {"zh": "BGM 音量", "en": "BGM Volume"},
	"settings_sfx_volume": {"zh": "音效音量", "en": "SFX Volume"},
	"settings_dev": {"zh": "开发测试", "en": "Developer"},
	"settings_full_unlock": {
		"zh": "全解锁模式",
		"en": "Full Unlock Mode",
	},
	"settings_full_unlock_on": {
		"zh": "全解锁模式：开 · 点击关闭",
		"en": "Full Unlock: ON · tap to turn off",
	},
	"settings_full_unlock_off": {
		"zh": "全解锁模式：关 · 点击开启（可玩全部关卡）",
		"en": "Full Unlock: OFF · tap to unlock all levels",
	},
	"toast_full_unlock_on": {
		"zh": "全解锁已开启 · 地图与任务可进入全部关卡",
		"en": "Full unlock on · all outposts and missions available",
	},
	"toast_full_unlock_off": {
		"zh": "全解锁已关闭 · 恢复常规解锁规则",
		"en": "Full unlock off · normal unlock rules restored",
	},
	"settings_reset_all": {"zh": "重置全部进度（回到初始状态）", "en": "Reset all progress"},
	"settings_reset_missions": {
		"zh": "重置运输任务进度（从批次1开始）",
		"en": "Reset transport missions (start at batch 1)",
	},
	"settings_reset_map_light": {
		"zh": "重置地图点亮效果（可重测雾散）",
		"en": "Reset map light ceremony",
	},
	"settings_reset_tutorials": {"zh": "重置跑酷教学进度", "en": "Reset runner tutorials"},
	"settings_replay_guide": {"zh": "重新播放主页引导", "en": "Replay home guide"},
	"settings_replay_transport_intro": {"zh": "查看运输任务说明", "en": "View transport mission guide"},
	"transport_intro_title": {"zh": "运输任务说明", "en": "Transport Missions"},
	"transport_intro_body": {
		"zh": "作为星火信使，你的工作是接取运输任务，为各个据点运送关键物资。\n\n跑酷途中会遇到障碍物——可以直接撞碎；也会遇到环境伤害——可开启防护罩抵挡。撞击与环境伤害都会降低货物完整度；完整度为 0 时运输失败。\n\n结算会按货物完整度为据点结算物资进度。当据点进度达标后，可以点亮该据点，并开放更多据点与运输任务。",
		"en": "As an Ember Runner, your job is to accept transport missions and deliver critical supplies to outposts.\n\nOn the run you'll smash through obstacles, and face environmental hazards you can block with your shield. Impacts and hazards both reduce cargo integrity — if it hits 0, the delivery fails.\n\nSettlement awards outpost supply progress based on cargo integrity. When an outpost reaches its goal, you can light it up and unlock more outposts and missions.",
	},
	"transport_intro_ok": {"zh": "知道了", "en": "Got it"},
	"settings_story_review": {"zh": "剧情回顾", "en": "Story Review"},
	"settings_reset_comic": {
		"zh": "重置开场漫画（回首页点 DAWNLINE 播放）",
		"en": "Reset opening comic (tap DAWNLINE on Home)",
	},
	"settings_level_editor": {"zh": "跑道关卡编辑器（开发）", "en": "Track level editor (dev)"},
	"settings_close": {"zh": "关闭", "en": "Close"},
	"toast_lang_zh": {"zh": "语言已切换为中文", "en": "Language set to Chinese"},
	"toast_lang_en": {"zh": "语言已切换为英文", "en": "Language set to English"},
	"toast_reset_all": {"zh": "全部进度已重置", "en": "All progress reset"},
	"toast_reset_missions": {
		"zh": "已重置运输任务，从水源据点+防御哨站重新开始",
		"en": "Transport missions reset · start from Water Station & Defense Outpost",
	},
	"toast_reset_map_light": {
		"zh": "已重置地图点亮效果，可在 Tasks 再次点亮测雾散",
		"en": "Map light ceremony reset · re-light from Tasks to test fog",
	},
	"toast_reset_tutorials": {
		"zh": "已重置跑酷教学，下次开跑会重新提示",
		"en": "Runner tutorials reset · tips will show again next run",
	},
	"toast_tutorial_on": {"zh": "跑酷新手引导已开启", "en": "Runner tutorials enabled"},
	"toast_tutorial_off": {"zh": "跑酷新手引导已关闭", "en": "Runner tutorials disabled"},
	"toast_bgm_on": {"zh": "背景音乐已开启", "en": "BGM enabled"},
	"toast_bgm_off": {"zh": "背景音乐已关闭", "en": "BGM disabled"},
	"fail_cargo_cn": {"zh": "货物被击穿", "en": "Cargo destroyed"},
	"fail_cargo_en": {"zh": "CARGO DESTROYED", "en": "CARGO DESTROYED"},
	"fail_timeout_cn": {"zh": "超时未送达", "en": "Timed out"},
	"fail_timeout_en": {"zh": "TIME OUT", "en": "TIME OUT"},
	"fail_wraith_cn": {"zh": "被异能怪捕获", "en": "Caught by Wraith"},
	"fail_wraith_en": {"zh": "CAUGHT BY WRAITH", "en": "CAUGHT BY WRAITH"},
	"fail_lava_cn": {"zh": "掉入熔岩", "en": "Fell into lava"},
	"fail_lava_en": {"zh": "FELL INTO LAVA", "en": "FELL INTO LAVA"},
	"fail_generic_cn": {"zh": "运输失败", "en": "Delivery failed"},
	"fail_generic_en": {"zh": "DELIVERY FAILED", "en": "DELIVERY FAILED"},
	"fail_mission_title": {"zh": "任务失败", "en": "Mission Failed"},
	"fail_reason_label": {"zh": "失败原因", "en": "Failure Reason"},
	"coach_done": {"zh": "教学完成 · 继续前进", "en": "Tutorial complete · keep moving"},
	"coach_follow_prompt": {"zh": "请按教学提示操作", "en": "Follow the tutorial prompt"},
	"tasks_empty": {
		"zh": "暂无可接取任务。完成运输推进各任务进度（每项 100），四项合计点亮据点后将解锁下一批。",
		"en": "No missions available. Finish runs to fill each mission to 100; lighting an outpost unlocks the next batch.",
	},
	"tasks_completed_btn": {"zh": "已完成任务", "en": "Completed"},
	"tasks_completed_title": {"zh": "已完成任务", "en": "Completed Missions"},
	"tasks_completed_empty": {"zh": "暂无已完成任务", "en": "No completed missions yet"},
	"tasks_ritual_title": {"zh": "信使誓约", "en": "RUNNER'S PACT"},
	"tasks_ritual_lead": {
		"zh": "接取任务，即是与荒原立约。",
		"en": "To accept a mission is to swear to the wasteland.",
	},
	"tasks_ritual_body": {
		"zh": "你以星火信使之名起誓：穿越沙暴与熔岩，将希望送达前线据点。货物完好，据点方能重燃；每一次奔跑，都是在为黎明线续火。",
		"en": "You swear as an Ember Runner: cross sand and fire, deliver hope to the line. Keep the cargo intact — keep the outpost alive. Every run feeds the Dawn Line.",
	},
	"tasks_ritual_seal": {
		"zh": "—— 货物即火种，跑道即誓言 ——",
		"en": "— Cargo is ember. The runway is your oath. —",
	},
}


static func get_locale() -> String:
	if Global != null and String(Global.ui_locale) in [ZH, EN]:
		return String(Global.ui_locale)
	return ZH


static func is_en() -> bool:
	return get_locale() == EN


static func is_zh() -> bool:
	return not is_en()


static func set_locale(locale: String) -> void:
	var next := EN if locale == EN else ZH
	if Global == null:
		return
	if Global.ui_locale == next:
		return
	Global.set_ui_locale(next)


static func pick(zh_text: String, en_text: String) -> String:
	return en_text if is_en() else zh_text


static func t(key: String, fallback: String = "") -> String:
	if STRINGS.has(key):
		var entry: Dictionary = STRINGS[key]
		return pick(String(entry.get("zh", "")), String(entry.get("en", "")))
	return fallback if fallback != "" else key


## 内容字典双语字段：优先 name_en / cargo_name_en 等
static func field(data: Dictionary, key: String, en_key: String = "") -> String:
	if data.is_empty():
		return ""
	var en_field := en_key if en_key != "" else ("%s_en" % key)
	if is_en():
		var en_val := String(data.get(en_field, "")).strip_edges()
		if en_val != "":
			return en_val
	var zh_val := String(data.get(key, "")).strip_edges()
	if zh_val != "":
		return zh_val
	return String(data.get(en_field, "")).strip_edges()


static func pair_line(label_zh: String, label_en: String, value_zh: String, value_en: String) -> String:
	if is_en():
		return "%s · %s" % [label_en, value_en]
	return "%s · %s" % [label_zh, value_zh]
