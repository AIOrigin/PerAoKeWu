extends "res://assets/maps/route_levels/runner_planet_config.gd"

## 星球一 · 无尽晶砂漠

const PLANET_ID := "glass_desert"

const GAME_TITLE := "星火信使：黎明线"
const MAP_NAME := "无尽晶砂漠"
const MAP_NAME_EN := "Endless Glass Desert"

const MISSION := {
	"runner_code": "Elsa",
	"cargo_name": "净水模块",
	"cargo_icon": "净水",
	"cargo_load": 100,
	"target_hearth": "水源据点",
	"task_type": "Supply Run",
}

const EXPLORE_CONNECTIONS := [
	["reservoir", "dome"],
	["dome", "medical"],
	["dome", "gate"],
	["medical", "relay"],
	["gate", "relay"],
]

const EXPLORE_LOCATIONS := [
	{
		"id": "reservoir",
		"name": "水源据点",
		"name_en": "Water Station",
		"type": "水源据点",
		"tagline": "荒原最后的净水设施之一。",
		"goal": "修复净化系统，让生命之源重新流动。",
		"pos": Vector2(0.18, 0.32),
		"reveal": ["dome", "medical"],
		"area": [Vector2(0.12, 0.26), Vector2(0.20, 0.28), Vector2(0.16, 0.38), Vector2(0.10, 0.36)],
		"danger_stars": 3,
		"manager_name": "Mira",
		"manager_title": "净水系统工程师",
		"manager_quote": "只要水还在流动，荒原就还有明天。",
		"reward_coins": 1000,
		"repair_total": 400,
		"repair_current": 240,
		"needs": [
			{"name": "净水包", "current": 140, "total": 200, "cargo_icon": "净水"},
			{"name": "能源包", "current": 100, "total": 200, "cargo_icon": "能源包"},
		],
	},
	{
		"id": "dome",
		"name": "居民穹顶",
		"name_en": "Habitat Dome",
		"type": "居民穹顶",
		"tagline": "荒原最大的幸存者聚居地。",
		"goal": "修复穹顶，重建人类最后的家园。",
		"pos": Vector2(0.50, 0.38),
		"reveal": ["reservoir", "medical"],
		"area": [Vector2(0.44, 0.32), Vector2(0.54, 0.34), Vector2(0.50, 0.46), Vector2(0.40, 0.44)],
		"danger_stars": 4,
		"manager_name": "Owen",
		"manager_title": "聚居地负责人",
		"manager_quote": "这里是最后的家园，也是重建的起点。",
		"reward_coins": 1200,
		"unlock_character": "Rook",
		"repair_total": 400,
		"needs": [
			{"name": "建设包", "current": 180, "total": 200, "cargo_icon": "建设"},
			{"name": "能源包", "current": 80, "total": 200, "cargo_icon": "能源包"},
		],
	},
	{
		"id": "medical",
		"name": "医疗据点",
		"name_en": "Medical Station",
		"type": "医疗据点",
		"tagline": "保存旧时代医疗技术的基地。",
		"goal": "恢复设备，为幸存者提供救治。",
		"pos": Vector2(0.72, 0.48),
		"reveal": ["dome", "reservoir"],
		"area": [Vector2(0.66, 0.42), Vector2(0.76, 0.44), Vector2(0.72, 0.56), Vector2(0.62, 0.54)],
		"danger_stars": 4,
		"manager_name": "Iris",
		"manager_title": "医疗主管",
		"manager_quote": "每一份药剂，都是把一个人拉回黎明。",
		"reward_coins": 1500,
		"repair_total": 300,
		"needs": [
			{"name": "医疗包", "current": 120, "total": 200, "cargo_icon": "医疗"},
			{"name": "净水包", "current": 80, "total": 150, "cargo_icon": "净水"},
		],
	},
	{
		"id": "gate",
		"name": "防御哨站",
		"name_en": "Defense Outpost",
		"type": "防御哨站",
		"tagline": "守护荒原边界的防线。",
		"goal": "重启防御系统，抵御未知威胁。",
		"pos": Vector2(0.22, 0.72),
		"reveal": ["relay"],
		"area": [Vector2(0.16, 0.66), Vector2(0.26, 0.68), Vector2(0.22, 0.78), Vector2(0.12, 0.76)],
		"danger_stars": 5,
		"manager_name": "Kane",
		"manager_title": "防线指挥官",
		"manager_quote": "防线还在，家园就不会失守。",
		"reward_coins": 1500,
		"repair_total": 300,
		"needs": [
			{"name": "防御包", "current": 130, "total": 200, "cargo_icon": "防御"},
			{"name": "建设包", "current": 100, "total": 200, "cargo_icon": "建设"},
		],
	},
	{
		"id": "relay",
		"name": "星火中继站",
		"name_en": "Ember Relay Station",
		"type": "星火中继站",
		"tagline": "连接各区域的通讯核心。",
		"goal": "恢复信号，让希望再次传递。",
		"pos": Vector2(0.78, 0.68),
		"reveal": ["medical", "gate"],
		"area": [Vector2(0.72, 0.62), Vector2(0.82, 0.64), Vector2(0.78, 0.76), Vector2(0.68, 0.74)],
		"danger_stars": 5,
		"manager_name": "Nova",
		"manager_title": "中继站信号员",
		"manager_quote": "只要信号抵达，希望就不会熄灭。",
		"reward_coins": 2000,
		"repair_total": 300,
		"needs": [
			{"name": "能源包", "current": 160, "total": 200, "cargo_icon": "能源包"},
			{"name": "星火核心", "current": 20, "total": 100, "cargo_icon": "星火核心"},
		],
	},
]

const LOCATION_MISSIONS := [
	{
		"location_id": "dome",
		"runner_code": "Elsa",
		"cargo_name": "净水模块",
		"cargo_icon": "净水",
		"cargo_load": 100,
		"source_hearth": "居民穹顶",
		"target_hearth": "水源据点",
		"task_type": "Supply Run",
		"order": 10,
		"difficulty": 1,
		"runner_rhythm": "0-20 秒熟悉换道与跳跃，20-40 秒引入选择门，40-60 秒零潮追击。",
		"environment_factor": "低强度晶砂风，视野清晰。",
		"unlock_ids": ["reservoir", "medical"],
		"unlocks": ["水源据点", "医疗据点"],
		"story": "穹顶的净水库存只够支撑三天。Elsa 必须赶在零潮风暴前把模块送到水源据点。",
	},
	{
		"location_id": "reservoir",
		"runner_code": "Elsa",
		"cargo_name": "净水包",
		"cargo_icon": "净水",
		"cargo_load": 90,
		"source_hearth": "水源据点",
		"target_hearth": "医疗据点",
		"task_type": "Supply Run",
		"order": 20,
		"difficulty": 1,
		"runner_rhythm": "前段障碍少，中段奖励币密集，末段强调完整度保护。",
		"environment_factor": "水库盐雾会降低远景对比。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "水源据点重新出水后，医疗据点需要第一批净水包恢复伤员治疗。",
	},
	{
		"location_id": "medical",
		"runner_code": "Elsa",
		"cargo_name": "医疗包",
		"cargo_icon": "医疗",
		"cargo_load": 80,
		"source_hearth": "医疗据点",
		"target_hearth": "星火中继站",
		"task_type": "Emergency Run",
		"order": 30,
		"difficulty": 2,
		"runner_rhythm": "节奏较稳，但完整度惩罚更敏感。",
		"environment_factor": "医疗站附近低能见度，奖励币路线更分散。",
		"unlock_ids": ["relay"],
		"unlocks": ["星火中继站"],
		"story": "医疗据点启动后，医疗包运输将打开中继通讯线路。",
	},
	{
		"location_id": "relay",
		"runner_code": "Elsa",
		"cargo_name": "星火核心",
		"cargo_icon": "星火核心",
		"cargo_load": 95,
		"source_hearth": "星火中继站",
		"target_hearth": "防御哨站",
		"task_type": "Relay Run",
		"order": 40,
		"difficulty": 3,
		"runner_rhythm": "高压段提前，连续滑铲和跳跃组合更多。",
		"environment_factor": "中继站外有强沙暴，障碍轮廓更晚显现。",
		"unlock_ids": ["gate"],
		"unlocks": ["防御哨站"],
		"story": "星火中继站点亮后，防御哨站需要星火核心来接入星火网络。",
	},
	{
		"location_id": "gate",
		"runner_code": "Elsa",
		"cargo_name": "防御包",
		"cargo_icon": "建设",
		"cargo_load": 110,
		"source_hearth": "防御哨站",
		"target_hearth": "居民穹顶",
		"task_type": "Repair Run",
		"order": 50,
		"difficulty": 3,
		"runner_rhythm": "前 20 秒建立速度，20-40 秒加入移动车，40-60 秒连续选择门。",
		"environment_factor": "防御哨站外有强沙暴，追猎距离恢复更慢。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "防御哨站重启后，防御包回运能稳定穹顶外围的防线。",
	},
]

const EMBER_COIN_VALUE := 15
const CARGO_DAMAGE_PER_HIT := 22.0
const CHASER_NAME := "零潮追猎"

const THEME := {
	"background": Color(0.14, 0.09, 0.05),
	"ambient": Color(0.92, 0.68, 0.44),
	"ambient_energy": 1.35,
	"fog_color": Color(0.82, 0.48, 0.2),
	"fog_density": 0.0022,
	"sun_color": Color(1.0, 0.82, 0.55),
	"sun_energy": 2.4,
	"road": Color(0.32, 0.34, 0.32),
	"shoulder": Color(0.78, 0.44, 0.15),
	"curb": Color(0.95, 0.67, 0.25),
	"lane_line": Color(1.0, 0.86, 0.42),
	"sand": Color(0.76, 0.43, 0.16),
	"crystal": Color(0.13, 0.62, 1.0),
	"surroundings": "desert_crystal",
}

const ASSETS := {
	"panorama": "res://3d素材/三拼地图.png",
	"jump_obstacles": [
		"res://mvp素材第二批/障碍物/高墙.glb",
		"res://mvp素材第二批/障碍物/高墙2.glb",
		"res://mvp素材第二批/障碍物/晶砂倒刺1.glb",
		"res://mvp素材第二批/障碍物/晶砂倒刺2.glb",
		"res://mvp素材第二批/障碍物/热浪喷口1（跳跃，热量侵蚀）.glb",
		"res://mvp素材第二批/障碍物/热浪喷口2.glb",
		"res://mvp素材第二批/障碍物/热浪喷口3.glb",
	],
	"slide_obstacle": "res://mvp素材第二批/障碍物/锈蚀水管1.glb",
	"slide_obstacles": [
		"res://mvp素材第二批/障碍物/锈蚀水管1.glb",
		"res://mvp素材第二批/障碍物/坍塌广告牌.glb",
		"res://mvp素材第二批/障碍物/能量裂缝.glb",
	],
	# 跑道两侧装饰（低模重复摆放，不参与碰撞）
	"side_props": [
		"res://mvp素材第二批/障碍物/晶砂倒刺1.glb",
		"res://mvp素材第二批/障碍物/晶砂倒刺2.glb",
		"res://mvp素材第二批/障碍物/锈蚀水管1.glb",
		"res://mvp素材第二批/障碍物/高墙.glb",
		"res://mvp素材第二批/障碍物/高墙2.glb",
		"res://mvp素材第二批/障碍物/坍塌广告牌.glb",
		"res://mvp素材第二批/障碍物/能量裂缝.glb",
		"res://mvp素材第二批/障碍物/热浪喷口2.glb",
		"res://mvp素材第二批/障碍物/热浪喷口3.glb",
	],
	"landmark_props": [
		"res://mvp素材第一批/居民穹顶3d.glb",
		"res://mvp素材第一批/水源据点3d.glb",
		"res://mvp素材第一批/星火中继站3d.glb",
		"res://mvp素材第一批/防御哨站3d.glb",
	],
	"hearth": "res://mvp素材第一批/居民穹顶3d.glb",
	"player": {
		"model": "res://mvp素材第二批/rook/rook立体.glb",
		"run_left": "res://mvp素材第二批/rook/rook跑步1 左腿蹬地右腿在前.glb",
		"run_right": "res://mvp素材第二批/rook/rook跑步2 右腿前踩地左腿空中.glb",
		"run_alt": "res://mvp素材第二批/rook/rook跑步3.glb",
		"jump_start": "res://mvp素材第二批/rook/rook起跳.glb",
		"jump_peak": "res://mvp素材第二批/rook/rook跳跃高点.glb",
		"landing": "res://mvp素材第二批/rook/rook跳跃落地.glb",
		"slide": "res://mvp素材第二批/rook/rook滑铲.glb",
		"portrait": "res://mvp素材第二批/rook/rook正面.jpg",
		"model_yaw": 180.0,
		"slide_yaw": 180.0,
		"intro_body_yaw": 0.0,
	},
}

const MVP_ROOT := "res://mvp素材第一批/"
const MVP2_ROOT := "res://mvp素材第二批/"
const MVP2_CARGO_ROOT := MVP2_ROOT + "运输包2d/"

const MVP_MAPS := {
	"explore_zh": MVP_ROOT + "晶砂荒原中文地图9：16.webp",
	"explore_en": MVP_ROOT + "晶砂荒原地图9：16英文.webp",
	"preview_zh": MVP_ROOT + "晶砂荒原地图中文.webp",
	"preview_en": MVP_ROOT + "晶砂荒原地图英文.webp",
}

const MVP_LOCATIONS := {
	"dome": {
		"preview_2d": MVP_ROOT + "居民穹顶2d展示图.webp",
		"model_3d": MVP_ROOT + "居民穹顶3d.glb",
	},
	"reservoir": {
		"preview_2d": MVP_ROOT + "水源据点2d.webp",
		"model_3d": MVP_ROOT + "水源据点3d.glb",
	},
	"medical": {
		"preview_2d": MVP_ROOT + "医疗据点2d.webp",
		"model_3d": MVP_ROOT + "医疗据点3d.glb",
	},
	"relay": {
		"preview_2d": MVP_ROOT + "星火中继站2d.webp",
		"model_3d": MVP_ROOT + "星火中继站3d.glb",
	},
	"gate": {
		"preview_2d": MVP_ROOT + "防御哨站2d.webp",
		"model_3d": MVP_ROOT + "防御哨站3d.glb",
	},
}

const RUN_PHASES := [
	{"name": "目标确认", "start": 0.0, "end": 50.0, "hint": "净水模块 → 水源据点"},
	{"name": "节奏建立", "start": 50.0, "end": 320.0, "hint": "熟悉换道 / 跳跃 / 滑铲"},
	{"name": "策略选择", "start": 320.0, "end": 700.0, "hint": "注意拐弯 · 分叉选左/右路"},
	{"name": "零潮高压", "start": 700.0, "end": 1020.0, "hint": "追击与障碍密度峰值"},
	{"name": "终点冲刺", "start": 1020.0, "end": 99999.0, "hint": "冲入火种据点"},
]

# 跑道折线：length=段长，turn=该段累计转向（正=左转，负=右转）
# 分叉放在直线段上，与弯道错开，避免「只有拐弯没有分叉」的观感
const TRACK_SEGMENTS := [
	{"length": 280.0, "turn": 0.0},
	{"length": 45.0, "turn": PI * 0.5},
	{"length": 220.0, "turn": 0.0},
	{"length": 45.0, "turn": -PI * 0.5},
	{"length": 220.0, "turn": 0.0},
	{"length": 45.0, "turn": PI * 0.5},
	{"length": 220.0, "turn": 0.0},
	{"length": 45.0, "turn": -PI * 0.5},
	{"length": 160.0, "turn": 0.0},
]

# 分叉：到 distance 时按左/右车道选岔，跑完 length 后汇合；spread 越大 Y 形越开
const JUNCTION_ZONES := [
	{
		"distance": 110.0,
		"length": 100.0,
		"spread": 24.0,
		"lane_a": 0, "label_a": "安全岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "速通岔路", "effect_b": "fast",
	},
	{
		"distance": 420.0,
		"length": 100.0,
		"spread": 24.0,
		"lane_a": 0, "label_a": "修复岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "奖励岔路", "effect_b": "bonus",
	},
	{
		"distance": 720.0,
		"length": 100.0,
		"spread": 24.0,
		"lane_a": 0, "label_a": "安全岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "速通岔路", "effect_b": "fast",
	},
]

const OBSTACLE_TYPES := {
	"jump": "晶砂高墙",
	"slide": "锈蚀水管",
	"train": "坍塌广告牌",
	"train_moving": "失控运输车",
	"block_left": "能量裂缝",
	"block_right": "能量裂缝",
	"ramp": "沙丘跳板",
	"turn_left": "安全门",
	"turn_right": "速通门",
}


static func get_planet_id() -> String:
	return PLANET_ID


static func get_theme() -> Dictionary:
	return THEME


static func get_assets() -> Dictionary:
	return ASSETS


static func get_track_segments() -> Array:
	return TRACK_SEGMENTS.duplicate(true)


static func get_mission_for_location(location_id: String) -> Dictionary:
	for item in LOCATION_MISSIONS:
		if String(item["location_id"]) == location_id:
			return item
	return MISSION


static func get_location_missions() -> Array:
	return LOCATION_MISSIONS.duplicate(true)


static func build_obstacles() -> Array:
	return [
		{"lane": 0, "distance": 55.0, "type": "jump"},
		{"lane": -1, "distance": 95.0, "type": "slide"},
		{"lane": 1, "distance": 130.0, "type": "jump"},
		{"lane": 0, "distance": 165.0, "type": "train"},
		{"lane": 0, "distance": 220.0, "type": "block_left"},
		{"lane": 1, "distance": 260.0, "type": "jump"},
		{"lane": -1, "distance": 300.0, "type": "slide"},
		{"lane": 1, "distance": 100.0, "type": "turn_left"},
		{"lane": -1, "distance": 100.0, "type": "turn_right"},
		{"lane": 0, "distance": 250.0, "type": "train_moving", "move_speed": -10.0},
		{"lane": 1, "distance": 310.0, "type": "jump"},
		{"lane": -1, "distance": 350.0, "type": "jump"},
		{"lane": 0, "distance": 400.0, "type": "slide"},
		{"lane": 1, "distance": 410.0, "type": "turn_left"},
		{"lane": -1, "distance": 410.0, "type": "turn_right"},
		{"lane": 1, "distance": 540.0, "type": "block_right"},
		{"lane": -1, "distance": 580.0, "type": "jump"},
		{"lane": 0, "distance": 640.0, "type": "train_moving", "move_speed": 11.0},
		{"lane": 1, "distance": 680.0, "type": "jump"},
		{"lane": -1, "distance": 710.0, "type": "turn_left"},
		{"lane": 1, "distance": 710.0, "type": "turn_right"},
		{"lane": -1, "distance": 760.0, "type": "slide"},
		{"lane": 0, "distance": 820.0, "type": "train"},
		{"lane": 1, "distance": 860.0, "type": "block_left"},
		{"lane": 0, "distance": 920.0, "type": "jump"},
		{"lane": -1, "distance": 980.0, "type": "train_moving", "move_speed": -12.0},
		{"lane": 1, "distance": 1040.0, "type": "slide"},
		{"lane": 0, "distance": 1100.0, "type": "jump"},
	]


static func build_coin_distances() -> Array:
	var coins: Array = []
	var dist := 28.0
	while dist < 1120.0:
		coins.append(dist)
		dist += 38.0
	return coins


static func phase_at(distance: float) -> Dictionary:
	for phase in RUN_PHASES:
		if distance >= float(phase["start"]) and distance < float(phase["end"]):
			return phase
	return RUN_PHASES[RUN_PHASES.size() - 1]


static func integrity_grade(integrity: float) -> String:
	if integrity >= 95.0:
		return "Perfect"
	if integrity >= 80.0:
		return "Clean"
	if integrity >= 60.0:
		return "Stable"
	if integrity > 0.0:
		return "Damaged"
	return "Failed"


static func integrity_grade_label(integrity: float) -> String:
	var grade := integrity_grade(integrity)
	match grade:
		"Perfect":
			return "Perfect ★★★★★"
		"Clean":
			return "Clean ★★★★☆"
		"Stable":
			return "Stable ★★★☆☆"
		"Damaged":
			return "Damaged ★★☆☆☆"
		_:
			return "Failed ★☆☆☆☆"


static func grade_coin_multiplier(grade: String) -> float:
	match grade:
		"Perfect":
			return 1.20
		"Clean":
			return 1.00
		"Stable":
			return 0.85
		"Damaged":
			return 0.60
		_:
			return 0.30


static func get_explore_map_path(_locale: String = "zh") -> String:
	return String(MVP_MAPS.get("explore_zh" if _locale == "zh" else "explore_en", MVP_MAPS["explore_zh"]))


static func get_home_map_preview_path(_locale: String = "zh") -> String:
	return String(MVP_MAPS.get("preview_zh" if _locale == "zh" else "preview_en", MVP_MAPS["preview_zh"]))


static func get_location_preview_path(location_id: String) -> String:
	var entry: Dictionary = MVP_LOCATIONS.get(location_id, {})
	return String(entry.get("preview_2d", ""))


static func get_location_hearth_model(location_id: String) -> String:
	var entry: Dictionary = MVP_LOCATIONS.get(location_id, {})
	var model_path := String(entry.get("model_3d", ""))
	if model_path != "":
		return model_path
	return String(ASSETS.get("hearth", ""))


static func get_cargo_icon_path(mission: Dictionary) -> String:
	var icon_key := String(mission.get("cargo_icon", ""))
	if icon_key == "":
		return ""
	return MVP2_CARGO_ROOT + icon_key + ".webp"


static func get_runner_portrait_path() -> String:
	var player_assets: Dictionary = ASSETS.get("player", {})
	return String(player_assets.get("portrait", ""))


static func get_explore_locations() -> Array[Dictionary]:
	var locations: Array[Dictionary] = []
	for entry in EXPLORE_LOCATIONS:
		locations.append(entry)
	return locations


static func get_explore_connections() -> Array:
	return EXPLORE_CONNECTIONS.duplicate(true)


static func get_outpost_meta(location_id: String) -> Dictionary:
	for entry in EXPLORE_LOCATIONS:
		if String(entry.get("id", "")) == location_id:
			return entry.duplicate(true)
	return {}


static func get_outpost_count() -> int:
	return EXPLORE_LOCATIONS.size()


static func get_type_icon(location_id: String) -> String:
	match location_id:
		"reservoir":
			return "💧"
		"dome":
			return "🏛"
		"medical":
			return "✚"
		"gate":
			return "🛡"
		"relay":
			return "📡"
		_:
			return "◎"


static func get_manager_accent(location_id: String) -> Color:
	match location_id:
		"reservoir":
			return Color(0.24, 0.56, 0.82)
		"dome":
			return Color(0.78, 0.58, 0.28)
		"medical":
			return Color(0.32, 0.72, 0.52)
		"gate":
			return Color(0.62, 0.46, 0.34)
		"relay":
			return Color(0.52, 0.40, 0.82)
		_:
			return Color(0.35, 0.50, 0.68)


static func build_detail_payload(location_id: String, revealed: bool, completed: bool) -> Dictionary:
	var outpost := get_outpost_meta(location_id)
	if outpost.is_empty():
		return {}
	var mission: Dictionary = get_mission_for_location(location_id) if revealed else {}
	var repair_total := int(outpost.get("repair_total", 300))
	var repair_current := int(outpost.get("repair_current", -1))
	if repair_current < 0:
		repair_current = repair_total if completed else int(repair_total * 0.45)
	if completed:
		repair_current = repair_total
	elif not revealed:
		repair_current = 0
	var repair_percent := 100 if completed else int(round(float(repair_current) / float(maxi(repair_total, 1)) * 100.0))
	var needs: Array = []
	for need in outpost.get("needs", []):
		var item: Dictionary = need.duplicate(true)
		if completed:
			item["current"] = int(item.get("total", 0))
		elif not revealed:
			item["current"] = 0
		if item.has("cargo_icon"):
			item["icon_path"] = get_cargo_icon_path({"cargo_icon": String(item["cargo_icon"])})
		needs.append(item)
	var transport_missions: Array = []
	if revealed and not mission.is_empty():
		transport_missions.append({
			"index": "01",
			"type": String(mission.get("task_type", "Supply Run")),
			"cargo_text": "%s×%d" % [String(mission.get("cargo_name", "物资")), int(mission.get("cargo_load", 1))],
			"coins": 100 + int(mission.get("difficulty", 1)) * 10,
			"xp": 20 + int(mission.get("difficulty", 1)) * 5,
		})
		if needs.size() > 1:
			var second_need: Dictionary = needs[1]
			transport_missions.append({
				"index": "02",
				"type": "Supply Run",
				"cargo_text": "%s×15" % String(second_need.get("name", "物资")),
				"coins": 110 + int(mission.get("difficulty", 1)) * 10,
				"xp": 25 + int(mission.get("difficulty", 1)) * 5,
			})
	var status_text := "状态：Lit（已点亮）" if completed else ("状态：修复中" if revealed else "状态：未开放")
	var runner_label := "还没轮到这个据点的任务哦"
	if revealed:
		runner_label = "再次运输" if completed else "开始运输"
	var locked_hint := ""
	if not revealed:
		locked_hint = "\n主要奖励：角色 ??? · 星火币 ???"
	return {
		"location_id": location_id,
		"title": String(outpost.get("name", "未知据点")),
		"title_en": String(outpost.get("name_en", "")),
		"status": status_text,
		"tagline": String(outpost.get("tagline", "")),
		"goal": String(outpost.get("goal", "")),
		"description": "%s\n%s" % [String(outpost.get("tagline", "")), String(outpost.get("goal", ""))],
		"meta": "%s · %s" % [String(outpost.get("type", "据点")), "Lit" if completed else ("修复中" if revealed else "待解锁")],
		"danger_stars": int(outpost.get("danger_stars", 3)),
		"type_icon": get_type_icon(location_id),
		"manager_accent": get_manager_accent(location_id),
		"preview_path": get_location_preview_path(location_id),
		"model_path": get_location_hearth_model(location_id),
		"repair_percent": repair_percent,
		"repair_current": repair_current,
		"repair_total": repair_total,
		"needs": needs,
		"transport_missions": transport_missions,
		"manager": {
			"name": String(outpost.get("manager_name", "")),
			"title": String(outpost.get("manager_title", "")),
			"quote": String(outpost.get("manager_quote", "")),
		},
		"rewards": {
			"coins": int(outpost.get("reward_coins", 0)),
			"unlock_character": String(outpost.get("unlock_character", "")),
		},
		"cargo_icon_path": get_cargo_icon_path(mission) if not mission.is_empty() else "",
		"revealed": revealed,
		"completed": completed,
		"runner_label": runner_label,
		"locked_hint": locked_hint,
	}
