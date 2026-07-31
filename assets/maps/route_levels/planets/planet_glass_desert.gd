extends "res://assets/maps/route_levels/runner_planet_config.gd"

const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const ObstacleLayout = preload("res://assets/maps/route_levels/runner_60s/obstacle_layout.gd")

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
	"duration": 52.0,
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
		"pos": Vector2(0.16, 0.28),
		"hit_radius": 0.11,
		"reveal": ["dome", "medical"],
		"area": [
			Vector2(0.08, 0.20), Vector2(0.24, 0.20), Vector2(0.26, 0.36), Vector2(0.08, 0.38),
		],
		"danger_stars": 3,
		"manager_name": "Mira",
		"manager_title": "净水系统工程师",
		"manager_quote": "只要水还在流动，荒原就还有明天。",
		"reward_coins": 300,
		"repair_total": 400,
		"needs": [
			{"name": "净水包", "current": 0, "total": 200, "cargo_icon": "净水"},
			{"name": "能源包", "current": 0, "total": 200, "cargo_icon": "能源包"},
		],
	},
	{
		"id": "dome",
		"name": "居民穹顶",
		"name_en": "Habitat Dome",
		"type": "居民穹顶",
		"tagline": "荒原最大的幸存者聚居地。",
		"goal": "修复穹顶，重建人类最后的家园。",
		"pos": Vector2(0.48, 0.46),
		"hit_radius": 0.12,
		"reveal": ["reservoir", "medical"],
		"area": [
			Vector2(0.38, 0.36), Vector2(0.58, 0.36), Vector2(0.60, 0.56), Vector2(0.36, 0.56),
		],
		"danger_stars": 4,
		"manager_name": "Owen",
		"manager_title": "聚居地负责人",
		"manager_quote": "这里是最后的家园，也是重建的起点。",
		"reward_coins": 300,
		"unlock_character": "Rook",
		"repair_total": 400,
		"needs": [
			{"name": "建设包", "current": 0, "total": 200, "cargo_icon": "建设"},
			{"name": "能源包", "current": 0, "total": 200, "cargo_icon": "能源包"},
		],
	},
	{
		"id": "medical",
		"name": "医疗据点",
		"name_en": "Medical Station",
		"type": "医疗据点",
		"tagline": "保存旧时代医疗技术的基地。",
		"goal": "恢复设备，为幸存者提供救治。",
		"pos": Vector2(0.70, 0.46),
		"hit_radius": 0.10,
		"reveal": ["dome", "reservoir"],
		"area": [
			Vector2(0.62, 0.38), Vector2(0.78, 0.38), Vector2(0.80, 0.56), Vector2(0.60, 0.56),
		],
		"danger_stars": 4,
		"manager_name": "Iris",
		"manager_title": "医疗主管",
		"manager_quote": "每一份药剂，都是把一个人拉回黎明。",
		"reward_coins": 300,
		"repair_total": 400,
		"needs": [
			{"name": "医疗包", "current": 0, "total": 200, "cargo_icon": "医疗"},
			{"name": "净水包", "current": 0, "total": 150, "cargo_icon": "净水"},
		],
	},
	{
		"id": "gate",
		"name": "防御哨站",
		"name_en": "Defense Outpost",
		"type": "防御哨站",
		"tagline": "守护荒原边界的防线。",
		"goal": "重启防御系统，抵御未知威胁。",
		"pos": Vector2(0.20, 0.74),
		"hit_radius": 0.10,
		"reveal": ["relay"],
		"area": [
			Vector2(0.12, 0.66), Vector2(0.30, 0.66), Vector2(0.30, 0.82), Vector2(0.10, 0.82),
		],
		"danger_stars": 5,
		"manager_name": "Kane",
		"manager_title": "防线指挥官",
		"manager_quote": "防线还在，家园就不会失守。",
		"reward_coins": 300,
		"repair_total": 400,
		"needs": [
			{"name": "防御包", "current": 0, "total": 200, "cargo_icon": "防御"},
			{"name": "建设包", "current": 0, "total": 200, "cargo_icon": "建设"},
		],
	},
	{
		"id": "relay",
		"name": "星火中继站",
		"name_en": "Ember Relay Station",
		"type": "星火中继站",
		"tagline": "连接各区域的通讯核心。",
		"goal": "恢复信号，让希望再次传递。",
		"pos": Vector2(0.78, 0.70),
		"hit_radius": 0.10,
		"reveal": ["medical", "gate"],
		"area": [
			Vector2(0.70, 0.60), Vector2(0.88, 0.60), Vector2(0.88, 0.80), Vector2(0.68, 0.80),
		],
		"danger_stars": 5,
		"manager_name": "Nova",
		"manager_title": "中继站信号员",
		"manager_quote": "只要信号抵达，希望就不会熄灭。",
		"reward_coins": 1000,
		"repair_total": 400,
		"needs": [
			{"name": "能源包", "current": 0, "total": 200, "cargo_icon": "能源包"},
			{"name": "星火核心", "current": 0, "total": 100, "cargo_icon": "星火核心"},
		],
	},
]

const MISSION_BATCHES := [
	{"id": 1, "name": "生存基础", "locations": ["dome", "reservoir"]},
	{"id": 2, "name": "危机应对", "locations": ["medical", "gate"]},
	{"id": 3, "name": "网络核心", "locations": ["relay"]},
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
		"duration": 52.0,
		"order": 10,
		"difficulty": 1,
		"runner_rhythm": "补给跑约 52 秒：障碍偏少，前段熟悉换道与跳跃，中段引入选择门。",
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
		"task_type": "Repair Run",
		"duration": 65.0,
		"order": 20,
		"difficulty": 1,
		"runner_rhythm": "抢修跑约 65 秒：障碍更密，时间相对宽裕，末段强调完整度保护。",
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
		"duration": 40.0,
		"order": 30,
		"difficulty": 2,
		"runner_rhythm": "紧急跑强制 40 秒限时：超时失败；越早送达，限时奖励倍率越高。",
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
		"task_type": "Ignition Run",
		"duration": 80.0,
		"order": 40,
		"difficulty": 3,
		"runner_rhythm": "点火跑约 80 秒：高压障碍 + 零潮追击开启，需兼顾完整度与逃逸距离。",
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
		"task_type": "Relay Run",
		"duration": 75.0,
		"order": 50,
		"difficulty": 3,
		"runner_rhythm": "中继跑约 75 秒：长距运输，分叉选择更多，连续滑铲与跳跃组合更密。",
		"environment_factor": "防御哨站外有强沙暴，岔路更晚显现。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "防御哨站重启后，防御包回运能稳定穹顶外围的防线。",
	},
]

const EMBER_COIN_VALUE := 15
const CARGO_DAMAGE_PER_HIT := 12.0
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

const ELSA_ACTION_ROOT := "res://elsa动作/"
const MVP_ROOT := "res://mvp素材第一批/"
const MVP2_ROOT := "res://mvp素材第二批/"
const MVP2_CARGO_ROOT := MVP2_ROOT + "运输包2d/"

const PLAYER_ELSA := {
	"model": ELSA_ACTION_ROOT + "elsa正面.glb",
	"run_left": ELSA_ACTION_ROOT + "elsa奔跑左腿前.glb",
	"run_right": ELSA_ACTION_ROOT + "elsa奔跑右腿前.glb",
	"jump_start": ELSA_ACTION_ROOT + "elsa起跳.glb",
	"jump_peak": ELSA_ACTION_ROOT + "elsa跳跃高点.glb",
	"landing": ELSA_ACTION_ROOT + "跳跃落地.glb",
	"slide": ELSA_ACTION_ROOT + "滑铲.glb",
	"animated_model": ELSA_ACTION_ROOT + "Running.fbx",
	"run_anim": "mixamo_com",
	"run_anim_speed": 1.0,
	"surface_texture": ELSA_ACTION_ROOT + "elsa正面_tripo_image_e7db2388-3d5b-4a2d-ab57-950535a6e250_0_0.jpg",
	"portrait": "res://assets/maps/route_levels/mobile_home/ui_character/elsa_fullbody.png",
	"model_yaw": 0.0,
	"animated_model_yaw": 180.0,
	"slide_yaw": 0.0,
	"intro_body_yaw": 180.0,
}

const PLAYER_ROOK := {
	"model": MVP2_ROOT + "rook/rook立体.glb",
	"run_left": MVP2_ROOT + "rook/rook跑步1 左腿蹬地右腿在前.glb",
	"run_right": MVP2_ROOT + "rook/rook跑步2 右腿前踩地左腿空中.glb",
	"run_alt": MVP2_ROOT + "rook/rook跑步3.glb",
	"jump_start": MVP2_ROOT + "rook/rook起跳.glb",
	"jump_peak": MVP2_ROOT + "rook/rook跳跃高点.glb",
	"landing": MVP2_ROOT + "rook/rook跳跃落地.glb",
	"slide": MVP2_ROOT + "rook/rook滑铲.glb",
	"portrait": MVP2_ROOT + "rook/rook正面.jpg",
	"model_yaw": 180.0,
	"slide_yaw": 180.0,
	"intro_body_yaw": 0.0,
}

const ASSETS := {
	"panorama": "res://3d素材/三拼地图.png",
	"jump_obstacles": [
		"res://mvp素材第二批/障碍物/全息跳跃栏.glb",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_sprigs_2_5d.png",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_grumpy_2_5d.png",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_angry_2_5d.png",
	],
	"slide_obstacle": "res://mvp素材第二批/障碍物/全息下滑门.glb",
	"slide_obstacles": [
		"res://mvp素材第二批/障碍物/全息下滑门.glb",
		"res://mvp素材第二批/障碍物/全息闪避柱.glb",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_phase_curtain_2_5d.png",
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
	"players": {
		"elsa": PLAYER_ELSA,
		"rook": PLAYER_ROOK,
	},
	"player": PLAYER_ELSA,
}

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
		"spread": 20.0,
		"lane_a": 0, "label_a": "安全岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "速通岔路", "effect_b": "fast",
	},
	{
		"distance": 420.0,
		"length": 100.0,
		"spread": 20.0,
		"lane_a": 0, "label_a": "修复岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "奖励岔路", "effect_b": "bonus",
	},
	{
		"distance": 720.0,
		"length": 100.0,
		"spread": 20.0,
		"lane_a": 0, "label_a": "安全岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "速通岔路", "effect_b": "fast",
	},
]

# 垂直侧墙跑：放在拐弯外径一侧；side 可用 "outer" 自动取外径
const SIDE_RUNWAY_ZONES := [
	{
		"start": 285.0,
		"length": 55.0,
		"side": "outer",
		"fallback_side": 1,
		"lateral_offset": 7.2,
		"layer": 1,
		"entry_window": 10.0,
	},
	{
		"start": 548.0,
		"length": 55.0,
		"side": "outer",
		"fallback_side": -1,
		"lateral_offset": 7.2,
		"layer": 1,
		"entry_window": 10.0,
	},
]

# 沙尘暴区：进入后持续扣货物完整度（避开侧墙/岔路中段）
const SANDSTORM_ZONES := [
	{
		"start": 168.0,
		"length": 42.0,
		"dps": 9.0,
		"label": "沙尘暴",
		"lane_count": 3,
	},
	{
		"start": 458.0,
		"length": 48.0,
		"dps": 10.5,
		"label": "沙尘暴",
		"lane_count": 3,
	},
	{
		"start": 860.0,
		"length": 55.0,
		"dps": 12.0,
		"label": "强沙尘暴",
		"lane_count": 3,
	},
]

const OBSTACLE_TYPES := {
	"jump": "全息跳跃栏",
	"slide": "全息下滑门",
	"train": "坍塌广告牌",
	"train_moving": "失控运输车",
	"block_left": "全息闪避柱",
	"block_right": "全息闪避柱",
	"ramp": "沙丘跳板",
	"main_block": "主路坍塌带",
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
			return MissionTypes.enrich_mission(item)
	return MissionTypes.enrich_mission(MISSION)


static func get_location_missions() -> Array:
	var out: Array = []
	for item in LOCATION_MISSIONS:
		out.append(MissionTypes.enrich_mission(item))
	return out


static func get_mission_batches() -> Array:
	return MISSION_BATCHES.duplicate(true)


static func get_jump_obstacle_label(asset_path: String) -> String:
	if "energy_orb" in asset_path:
		return "漂浮能量球"
	if "energy_sprigs" in asset_path:
		return "能量棱芽"
	return OBSTACLE_TYPES.get("jump", "跳跃障碍")


static func build_obstacles() -> Array:
	# 优先读关卡编辑器导出的 JSON；没有文件则用内置默认表
	if ObstacleLayout.has_layout(PLANET_ID):
		return _filter_obstacles_away_from_side_walls(ObstacleLayout.load_items(PLANET_ID))
	return _filter_obstacles_away_from_side_walls(_default_obstacles())


static func _default_obstacles() -> Array:
	return [
		{"lane": 0, "distance": 95.0, "type": "jump"},
		{"lane": -1, "distance": 145.0, "type": "slide"},
		{"lane": 1, "distance": 190.0, "type": "jump"},
		{"lane": 0, "distance": 250.0, "type": "train"},
		# 侧墙入口跳板 + 主路封堵（与 SIDE_RUNWAY_ZONES 对齐）
		{"lane": 0, "distance": 277.0, "type": "ramp", "target_layer": 1, "layer": 0},
		{"lane": 0, "distance": 312.0, "type": "main_block", "half_depth": 26.0, "layer": 0},
		{"lane": 1, "distance": 360.0, "type": "jump"},
		# 侧墙走廊结束后再放下滑门，避免缩放漂进墙跑区
		{"lane": -1, "distance": 375.0, "type": "slide"},
		{"lane": 1, "distance": 100.0, "type": "turn_left"},
		{"lane": -1, "distance": 100.0, "type": "turn_right"},
		{"lane": 0, "distance": 350.0, "type": "train_moving", "move_speed": -10.0},
		{"lane": 1, "distance": 430.0, "type": "jump"},
		{"lane": -1, "distance": 480.0, "type": "jump"},
		{"lane": 0, "distance": 540.0, "type": "ramp", "target_layer": 1, "layer": 0},
		{"lane": 0, "distance": 575.0, "type": "main_block", "half_depth": 26.0, "layer": 0},
		# 注意：勿在 SIDE_RUNWAY 入口再放 slide（曾导致「看不见却撞上全息下滑门」）
		{"lane": 1, "distance": 410.0, "type": "turn_left"},
		{"lane": -1, "distance": 410.0, "type": "turn_right"},
		{"lane": 1, "distance": 650.0, "type": "block_right"},
		{"lane": -1, "distance": 680.0, "type": "jump"},
		{"lane": 0, "distance": 740.0, "type": "train_moving", "move_speed": 11.0},
		{"lane": 1, "distance": 800.0, "type": "jump"},
		{"lane": -1, "distance": 710.0, "type": "turn_left"},
		{"lane": 1, "distance": 710.0, "type": "turn_right"},
		{"lane": -1, "distance": 860.0, "type": "slide"},
		{"lane": 0, "distance": 920.0, "type": "train"},
		{"lane": 1, "distance": 980.0, "type": "block_left"},
		{"lane": 0, "distance": 1040.0, "type": "jump"},
		{"lane": -1, "distance": 1100.0, "type": "train_moving", "move_speed": -12.0},
		{"lane": 1, "distance": 1160.0, "type": "slide"},
		{"lane": 0, "distance": 1220.0, "type": "jump"},
	]


static func _obstacle_in_side_wall_corridor(distance: float) -> bool:
	for zone in SIDE_RUNWAY_ZONES:
		var start := float(zone["start"])
		var length := float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 10.0))
		# 前后多留缓冲：缩放/加密障碍容易漂进侧墙区
		var pad := 22.0
		if distance >= start - entry - pad and distance <= start + length + pad:
			return true
	return false


static func _filter_obstacles_away_from_side_walls(items: Array) -> Array:
	# 侧墙走廊内只保留入口跳板 / 主路封堵 / 岔路牌，避免隐形下滑门等误伤
	var keep_types := {
		"main_block": true,
		"ramp": true,
		"turn_left": true,
		"turn_right": true,
	}
	var out: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var otype := String(item.get("type", ""))
		var dist := float(item.get("distance", 0.0))
		if _obstacle_in_side_wall_corridor(dist) and not keep_types.has(otype):
			continue
		out.append(item)
	return out

static func build_coin_distances() -> Array:
	# 兼容旧接口：仅返回距离；主路图案币走 build_main_runway_coins
	var coins: Array = []
	for item in build_main_runway_coins():
		coins.append(float(item.get("distance", 0.0)))
	return coins


static func build_main_runway_coins() -> Array:
	var coins: Array = []
	var cursor := 28.0
	var pattern_i := 0
	while cursor < 1120.0:
		var on_side := false
		for zone in SIDE_RUNWAY_ZONES:
			var zs := float(zone["start"])
			var ze := zs + float(zone.get("length", 70.0))
			if cursor >= zs - 4.0 and cursor <= ze + 4.0:
				on_side = true
				break
		if on_side:
			cursor += 38.0
			continue
		# 交替投放：S 形一段、单列一段、横排一段
		var kind := pattern_i % 3
		if kind == 0:
			_append_coin_pattern(coins, cursor, 0, "s_curve", 7, 6.0)
			cursor += 7.0 * 6.0 + 18.0
		elif kind == 1:
			# pattern_i%3 在 column 分支恒为 1，用整轮次轮换左/中/右列
			var col_lanes: Array[int] = [-1, 0, 1]
			var col_lane: int = col_lanes[int(pattern_i / 3) % 3]
			_append_coin_pattern(coins, cursor, 0, "column", 6, 5.5, col_lane)
			cursor += 5.5 * 5.0 + 20.0
		else:
			_append_coin_pattern(coins, cursor, 0, "row", 1, 8.0)
			cursor += 38.0
		pattern_i += 1
	return coins


static func _append_coin_pattern(
	out: Array,
	start: float,
	layer: int,
	pattern: String,
	count: int = 5,
	step: float = 7.0,
	lane_hint: int = 0
) -> void:
	# S 形序列：左右摆动形成连贯曲线
	var s_seq: Array[int] = [-1, 0, 1, 1, 0, -1]
	for i in count:
		var dist := start + float(i) * step
		match pattern:
			"row":
				for lane in [-1, 0, 1]:
					out.append({"distance": dist, "lane": lane, "layer": layer, "pattern": pattern})
			"zigzag":
				var z_lane := -1 if i % 2 == 0 else 1
				out.append({"distance": dist, "lane": z_lane, "layer": layer, "pattern": pattern})
				if i % 3 == 1:
					out.append({"distance": dist, "lane": 0, "layer": layer, "pattern": pattern, "y_boost": true})
			"s_curve", "s":
				var s_lane: int = s_seq[i % s_seq.size()]
				out.append({"distance": dist, "lane": s_lane, "layer": layer, "pattern": pattern})
			"column", "stream":
				out.append({"distance": dist, "lane": lane_hint, "layer": layer, "pattern": "column"})
			"gap_center":
				out.append({"distance": dist, "lane": -1, "layer": layer, "pattern": pattern})
				out.append({"distance": dist, "lane": 1, "layer": layer, "pattern": pattern})
			_:
				out.append({"distance": dist, "lane": lane_hint, "layer": layer, "pattern": pattern})


static func build_side_runway_coins() -> Array:
	var coins: Array = []
	# 第一段外径墙：S 形 → 中列单列
	_append_coin_pattern(coins, 290.0, 1, "s_curve", 8, 5.5)
	_append_coin_pattern(coins, 318.0, 1, "column", 5, 5.0, 0)
	# 第二段外径墙：左列单列 → S 形
	_append_coin_pattern(coins, 552.0, 1, "column", 6, 5.0, -1)
	_append_coin_pattern(coins, 580.0, 1, "s_curve", 7, 5.5)
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


static func get_player_assets(character_id: String = "elsa") -> Dictionary:
	var players: Variant = ASSETS.get("players", {})
	if players is Dictionary and players.has(character_id):
		return (players[character_id] as Dictionary).duplicate(true)
	var fallback: Variant = ASSETS.get("player", PLAYER_ELSA)
	if fallback is Dictionary:
		return (fallback as Dictionary).duplicate(true)
	return PLAYER_ELSA.duplicate(true)


static func get_runner_portrait_path(character_id: String = "elsa") -> String:
	var player_assets: Dictionary = get_player_assets(character_id)
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
	var repair_total := maxi(1, int(outpost.get("repair_total", 400)))
	var repair_current := 0
	if completed:
		repair_current = repair_total
	elif revealed:
		repair_current = clampi(Global.get_outpost_progress(PLANET_ID, location_id), 0, repair_total)
	var repair_percent := int(round(float(repair_current) / float(repair_total) * 100.0))
	var needs: Array = []
	for need in outpost.get("needs", []):
		var item: Dictionary = need.duplicate(true)
		var need_total := maxi(1, int(item.get("total", 1)))
		if completed:
			item["current"] = need_total
		elif not revealed:
			item["current"] = 0
		else:
			item["current"] = clampi(int(round(float(need_total) * float(repair_current) / float(repair_total))), 0, need_total)
		if item.has("cargo_icon"):
			item["icon_path"] = get_cargo_icon_path({"cargo_icon": String(item["cargo_icon"])})
		needs.append(item)
	var transport_missions: Array = []
	if revealed and not mission.is_empty():
		transport_missions.append({
			"index": "01",
			"type": String(mission.get("task_type_zh", mission.get("task_type", "补给"))),
			"type_en": String(mission.get("task_type", "Supply Run")),
			"duration": int(mission.get("duration", 60)),
			"cargo_text": "%s×%d" % [String(mission.get("cargo_name", "物资")), int(mission.get("cargo_load", 1))],
			"coins": int(mission.get("base_reward", 100 + int(mission.get("difficulty", 1)) * 10)),
			"xp": 20 + int(mission.get("difficulty", 1)) * 5,
			"hint": String(mission.get("task_hint", "")),
		})
		if needs.size() > 1:
			var second_need: Dictionary = needs[1]
			transport_missions.append({
				"index": "02",
				"type": "补给",
				"type_en": "Supply Run",
				"duration": 52,
				"cargo_text": "%s×15" % String(second_need.get("name", "物资")),
				"coins": 110 + int(mission.get("difficulty", 1)) * 10,
				"xp": 25 + int(mission.get("difficulty", 1)) * 5,
				"hint": "障碍较少 · 熟悉换道与跳跃",
			})
	var status_text := "状态：Lit（已点亮）" if completed else ("状态：修复中" if revealed else "状态：未开放")
	var runner_label := "还没轮到这个据点的任务哦"
	if revealed:
		if completed:
			runner_label = "再次运输"
		elif repair_current > 0:
			runner_label = "继续运输"
		else:
			runner_label = "开始运输"
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
