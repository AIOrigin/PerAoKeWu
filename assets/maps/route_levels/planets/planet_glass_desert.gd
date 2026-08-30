extends "res://assets/maps/route_levels/runner_planet_config.gd"

const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const ObstacleLayout = preload("res://assets/maps/route_levels/runner_60s/obstacle_layout.gd")

## 星球一 · 无尽晶砂漠

const PLANET_ID := "glass_desert"

const GAME_TITLE := "星火信使：黎明线"
const MAP_NAME := "无尽晶砂漠"
const MAP_NAME_EN := "Endless Glass Desert"
const MAP_CHROME_TITLE := "Crystal Waste"

const MISSION := {
	"runner_code": "Elsa",
	"cargo_name": "净水包",
	"cargo_name_en": "Water Pack",
	"cargo_icon": "净水",
	"cargo_load": 90,
	"target_hearth": "水源据点",
	"task_type": "Supply Run",
	"duration": 55.0,
}

const EXPLORE_CONNECTIONS := [
	["reservoir", "dome"],
	["dome", "medical"],
	["dome", "gate"],
	["medical", "relay"],
	["gate", "relay"],
]

## 地标 UV 对齐美术底图：旧水库入口无详情；防御哨站仅地标无详情。
const EXPLORE_LOCATIONS := [
	{
		"id": "reservoir",
		"name": "水源据点",
		"name_en": "Water Station",
		"type": "水源据点",
		"tagline": "荒原最后的净水设施之一。",
		"goal": "修复净化系统，让生命之源重新流动。",
		"pos": Vector2(0.737, 0.603),
		"tap_uv": Vector2(0.737, 0.603),
		"hit_radius": 0.09,
		"reveal": ["dome", "medical"],
		"area": [
			Vector2(0.62, 0.42), Vector2(0.78, 0.42), Vector2(0.80, 0.58), Vector2(0.60, 0.58),
		],
		"danger_stars": 3,
		"manager_name": "Mira",
		"manager_title": "净水系统工程师",
		"manager_quote": "只要水还在流动，荒原就还有明天。",
		"manager_portrait": "res://assets/maps/route_levels/planet_explore/portraits/mira_fullbody.png",
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
		"pos": Vector2(0.508, 0.547),
		"tap_uv": Vector2(0.508, 0.547),
		"hit_radius": 0.12,
		"reveal": ["reservoir", "medical"],
		"area": [
			Vector2(0.38, 0.36), Vector2(0.58, 0.36), Vector2(0.60, 0.56), Vector2(0.36, 0.56),
		],
		"danger_stars": 4,
		"manager_name": "Owen",
		"manager_title": "聚居地负责人",
		"manager_title_en": "Settlement Lead",
		"manager_quote": "这里是最后的家园，也是重建的起点。",
		"manager_quote_en": "This is our last home — and where rebuilding begins.",
		"manager_portrait": "res://assets/maps/route_levels/planet_explore/portraits/owen_fullbody.png",
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
		"pos": Vector2(0.28, 0.58),
		"tap_uv": Vector2(0.28, 0.58),
		"hit_radius": 0.09,
		"reveal": ["dome", "reservoir"],
		"area": [
			Vector2(0.20, 0.50), Vector2(0.36, 0.50), Vector2(0.38, 0.66), Vector2(0.18, 0.66),
		],
		"danger_stars": 4,
		"manager_name": "Iris",
		"manager_title": "医疗主管",
		"manager_quote": "每一份药剂，都是把一个人拉回黎明。",
		"manager_portrait": "res://assets/maps/route_levels/planet_explore/portraits/iris_fullbody.png",
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
		"pos": Vector2(0.80, 0.78),
		"tap_uv": Vector2(0.80, 0.78),
		"hit_radius": 0.09,
		"open_detail": true,
		"reveal": ["relay"],
		"area": [
			Vector2(0.72, 0.70), Vector2(0.90, 0.70), Vector2(0.90, 0.88), Vector2(0.70, 0.88),
		],
		"danger_stars": 5,
		"manager_name": "Kane",
		"manager_title": "防线指挥官",
		"manager_quote": "防线还在，家园就不会失守。",
		"manager_portrait": "res://assets/maps/route_levels/planet_explore/portraits/kane_fullbody.png",
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
		"pos": Vector2(0.596, 0.215),
		"tap_uv": Vector2(0.596, 0.215),
		"hit_radius": 0.12,
		"open_detail": true,
		"reveal": ["medical", "gate"],
		"area": [
			Vector2(0.70, 0.05), Vector2(0.97, 0.05), Vector2(0.97, 0.34), Vector2(0.68, 0.34),
		],
		"danger_stars": 5,
		"manager_name": "Nova",
		"manager_title": "中继站信号员",
		"manager_quote": "只要信号抵达，希望就不会熄灭。",
		"manager_portrait": "res://assets/maps/route_levels/planet_explore/portraits/nova_fullbody.png",
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

## 每批 8 关各用独立 JSON（视觉素材同套、跑道/障碍布局各异）
const OBSTACLE_LAYOUT_SETS := {
	"early": [
		"mission_dome_h1", "mission_reservoir_w1",
		"mission_dome_h2", "mission_reservoir_w2",
		"mission_dome_h3", "mission_reservoir_w3",
		"mission_dome_h4", "mission_reservoir_w4",
	],
	"crisis": [
		"mission_medical_m1", "mission_gate_d1",
		"mission_medical_m2", "mission_gate_d2",
		"mission_medical_m3", "mission_gate_d3",
		"mission_medical_m4", "mission_gate_d4",
	],
	"relay": ["layout_set_relay_1", "layout_set_relay_2", "layout_set_relay_3", "layout_set_relay_4"],
}

## 2048×1024 等距柱状全景（由桌面「场景全景图」裁制）；全关共用，靠 Y 轴旋转区分视角
const RUNNER_SKY_PANORAMA := "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w1_scene_sky.png"
## 医疗四关：直接用水源/穹顶已验证的 W1 全景，靠朝向和光影区分
const MEDICAL_SKY_PANORAMA := "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w1_scene_sky.png"
const MEDICAL_M1_SKY_PANORAMA := RUNNER_SKY_PANORAMA
const MEDICAL_M2_SKY_PANORAMA := "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w2_scene_sky.png"
const MEDICAL_M3_SKY_PANORAMA := RUNNER_SKY_PANORAMA
const MEDICAL_M4_SKY_PANORAMA := RUNNER_SKY_PANORAMA
const RUNNER_GROUND_TEXTURE := "res://assets/maps/route_levels/runner_60s/backgrounds/textures/glass_desert_w1_ground_albedo.jpg"
## 星火中继站最终关素材（桌面「最后关卡物体」）
const RELAY_FINAL_ROOT := "res://assets/maps/route_levels/runner_60s/relay_final/"
const RELAY_PANO_ROOT := "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/"
const RELAY_E1_SKY_PANORAMA := RELAY_PANO_ROOT + "relay_e1_scene_sky.png"
const RELAY_E2_SKY_PANORAMA := RELAY_PANO_ROOT + "relay_e2_scene_sky.png"
const RELAY_E3_SKY_PANORAMA := RELAY_PANO_ROOT + "relay_e3_scene_sky.png"
const RELAY_E4_SKY_PANORAMA := RELAY_PANO_ROOT + "relay_e4_scene_sky.png"
const RELAY_SKY_PANORAMA := RELAY_E1_SKY_PANORAMA
const RELAY_SKY_NEAR_1 := RELAY_FINAL_ROOT + "sky_near_1.webp"
const RELAY_SKY_NEAR_2 := RELAY_FINAL_ROOT + "sky_near_2.webp"
const RELAY_GROUND_TEXTURE := RELAY_FINAL_ROOT + "ground_path.webp"
const RELAY_OBSTACLE := RELAY_FINAL_ROOT + "obstacle_near.glb"
const RELAY_MIDGROUND_DRONE := RELAY_FINAL_ROOT + "midground_drone.glb"
const RELAY_DISTANT_TOWER := RELAY_FINAL_ROOT + "distant_tower_futuristic.glb"
const RELAY_DISTANT_RUIN := RELAY_FINAL_ROOT + "distant_ruin_scifi.glb"
const RELAY_DISTANT_TURBINE := RELAY_FINAL_ROOT + "distant_turbine_steampunk.glb"
const RELAY_MID_NEON := "res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb"
const RELAY_MID_SPHERE := "res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb"
const RELAY_MID_METEOR := "res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb"
const RELAY_MID_CORAL := "res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb"
const RELAY_MID_EXCAVATOR := "res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb"
const RELAY_MID_PURIFIER := "res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb"
const RELAY_DIST_SIGNAL := "res://assets/maps/route_levels/models/environment/distant/distant_signal_tower.glb"
const RELAY_DIST_CRYSTAL_1 := "res://assets/maps/route_levels/models/environment/distant/giant_energy_crystal_pillar_1.glb"
const RELAY_DIST_CRYSTAL_2 := "res://assets/maps/route_levels/models/environment/distant/giant_energy_crystal_pillar_2.glb"
const RELAY_DIST_FANTASY := "res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb"
const RELAY_DIST_POD := "res://assets/maps/route_levels/models/environment/distant/futuristic_pod.glb"
const RELAY_DIST_SHIP := "res://assets/maps/route_levels/models/environment/distant/futuristic_spaceship.glb"
## 中继站共用装饰池：拉开种类，避免喇叭塔/涡轮成排复读
const RELAY_MID_POOL := [
	RELAY_MIDGROUND_DRONE,
	RELAY_MID_NEON,
	RELAY_MID_SPHERE,
	RELAY_MID_METEOR,
	RELAY_MID_CORAL,
	RELAY_MID_EXCAVATOR,
]
const RELAY_NEAR_POOL := [
	RELAY_MID_SPHERE,
	RELAY_MID_NEON,
	RELAY_MID_METEOR,
	RELAY_MID_CORAL,
	RELAY_MID_PURIFIER,
]
const RELAY_DISTANT_TOWER_POOL := [
	RELAY_DISTANT_TOWER,
	RELAY_DISTANT_TURBINE,
	RELAY_DISTANT_RUIN,
	RELAY_DIST_SIGNAL,
	RELAY_DIST_CRYSTAL_1,
	RELAY_DIST_CRYSTAL_2,
]
const RELAY_DISTANT_ACCENT_POOL := [
	RELAY_DIST_FANTASY,
	RELAY_DIST_POD,
	RELAY_DIST_CRYSTAL_1,
	RELAY_DISTANT_RUIN,
]
const RELAY_DISTANT_SHIP_POOL := [
	RELAY_DIST_SHIP,
	RELAY_DIST_POD,
]
const RUNNER_SKY_ACCENTS := {
	"energy_gates": true,
	"aurora": false,
	"panorama_billboards": false,
	"distant_density": 1.32,
}
const RUNNER_ENVIRONMENT_BASE := {
	"panorama_energy": 1.52,
	"fog_color": Color(0.38, 0.32, 0.42),
	"fog_density": 0.00038,
	"fog_aerial_perspective": 0.07,
	"ambient": Color(0.48, 0.44, 0.56),
	"ambient_energy": 0.74,
}
## 跑酷全程天空：里程滚动幅度（弧度），让云层/明暗带在整局内缓慢变化
const RUNNER_SKY_PROGRESS_SCROLL := 0.52
## 各任务在全景图上的 Y 轴旋转（弧度），同图不同视角（避开 W1 默认朝向）
const RUNNER_SKY_YAW := {
	"mission_reservoir_01": 0.0,
	"mission_reservoir_02": 0.14,
	"mission_reservoir_03": -0.40,
	"mission_reservoir_04": 0.36,
	"mission_dome_h1": -0.95,
	"mission_dome_h2": -1.82,
	"mission_dome_h3": -2.69,
	"mission_dome_h4": -3.56,
	"mission_medical_m1": 0.0,
	"mission_medical_m2": 0.18,
	"mission_medical_m3": -0.28,
	"mission_medical_m4": 2.88,
	"mission_relay_e1": 0.0,
	"mission_relay_e2": 0.0,
	"mission_relay_e3": 0.0,
	"mission_relay_e4": 0.0,
	"mission_relay_01": 0.0,
	"mission_gate_d1": 5.18,
	"mission_gate_d2": 5.31,
	"mission_gate_d3": 5.44,
	"mission_gate_d4": 5.57,
}
## 同张全景：第四关对准地平线剪影带，不要对着太阳核也不要抬头进天顶
const RUNNER_SKY_PITCH := {
	"mission_reservoir_03": 0.0,
	"mission_reservoir_04": 0.0,
	# 对准浓缩全景：光带 + 地平微光同时入镜
	"mission_relay_e1": -0.08,
	"mission_relay_e2": -0.06,
	"mission_relay_e3": -0.07,
	"mission_relay_e4": -0.05,
	"mission_relay_01": -0.08,
}

const RUNNER_PROP_ROOT := "res://assets/maps/route_levels/runner_60s/"
const RUNNER_MID := "res://assets/maps/route_levels/models/environment/midground/"
const RUNNER_DIST := "res://assets/maps/route_levels/models/environment/distant/"
const RUNNER_OBS_LIGHT := RUNNER_PROP_ROOT + "obstacles_lightweight/"
const RUNNER_ENV_V2 := RUNNER_PROP_ROOT + "environment_pack_v2/"
const MVP2_OBS := "res://mvp素材第二批/障碍物/0803/"

## 水源据点第一关：湖泊夕照。后续关卡用各自 environment，不要套这套橙黄底色。
const RESERVOIR_W1_ENVIRONMENT := {
	"panorama_energy": 1.56,
	"fog_color": Color(0.56, 0.40, 0.28),
	"fog_density": 0.00034,
	"fog_aerial_perspective": 0.06,
	"ambient": Color(0.66, 0.52, 0.38),
	"ambient_energy": 0.78,
	"sun_color": Color(0.96, 0.78, 0.52),
	"sun_energy": 1.82,
	"tonemap_exposure": 1.06,
}

## 水源 W2：第一关云层全景，色调偏粉紫，雾要薄才能看见明暗
const RESERVOIR_W2_ENVIRONMENT := {
	"panorama_energy": 1.54,
	"fog_color": Color(0.58, 0.42, 0.52),
	"fog_density": 0.00026,
	"fog_aerial_perspective": 0.040,
	"ambient": Color(0.64, 0.50, 0.60),
	"ambient_energy": 0.76,
	"sun_color": Color(0.96, 0.72, 0.78),
	"sun_energy": 1.68,
	"tonemap_exposure": 1.06,
}

## 水源 W3：第一关原图，略偏一侧仍对着云层和高楼剪影
const RESERVOIR_W3_ENVIRONMENT := {
	"panorama_energy": 1.56,
	"fog_color": Color(0.56, 0.40, 0.28),
	"fog_density": 0.00034,
	"fog_aerial_perspective": 0.06,
	"ambient": Color(0.66, 0.52, 0.38),
	"ambient_energy": 0.78,
	"sun_color": Color(0.96, 0.78, 0.52),
	"sun_energy": 1.82,
	"tonemap_exposure": 1.06,
}

## 水源 W4：第一关原图，另一侧看云层和高楼暗影，雾色跟第一关一样才不会发灰
const RESERVOIR_W4_ENVIRONMENT := {
	"panorama_energy": 1.56,
	"fog_color": Color(0.56, 0.40, 0.28),
	"fog_density": 0.00034,
	"fog_aerial_perspective": 0.06,
	"ambient": Color(0.66, 0.52, 0.38),
	"ambient_energy": 0.78,
	"sun_color": Color(0.96, 0.78, 0.52),
	"sun_energy": 1.82,
	"tonemap_exposure": 1.06,
}

## 医疗 M1：保持现在这版夕照还原
const MEDICAL_M1_ENVIRONMENT := {
	"panorama_energy": 1.56,
	"fog_color": Color(0.56, 0.40, 0.28),
	"fog_density": 0.00034,
	"fog_aerial_perspective": 0.06,
	"ambient": Color(0.66, 0.52, 0.38),
	"ambient_energy": 0.78,
	"sun_color": Color(0.96, 0.78, 0.52),
	"sun_energy": 1.82,
	"tonemap_exposure": 1.06,
}

## 医疗 M2：第一关云层 + 暮色光感，不要假极光帘
const MEDICAL_M2_ENVIRONMENT := {
	"panorama_energy": 1.56,
	"fog_color": Color(0.50, 0.40, 0.42),
	"fog_density": 0.00024,
	"fog_aerial_perspective": 0.040,
	"ambient": Color(0.58, 0.50, 0.56),
	"ambient_energy": 0.76,
	"sun_color": Color(0.90, 0.76, 0.68),
	"sun_energy": 1.68,
	"tonemap_exposure": 1.06,
}

## 医疗 M3：仍对着云层，玫暖光，雾跟第一关同系避免一片粉
const MEDICAL_M3_ENVIRONMENT := {
	"panorama_energy": 1.52,
	"fog_color": Color(0.56, 0.38, 0.32),
	"fog_density": 0.00032,
	"fog_aerial_perspective": 0.055,
	"ambient": Color(0.68, 0.48, 0.42),
	"ambient_energy": 0.76,
	"sun_color": Color(1.0, 0.72, 0.66),
	"sun_energy": 1.70,
	"tonemap_exposure": 1.04,
}

## 医疗 M4：暮紫压暗，对准剪影带
const MEDICAL_M4_ENVIRONMENT := {
	"panorama_energy": 0.96,
	"fog_color": Color(0.26, 0.16, 0.22),
	"fog_density": 0.00032,
	"fog_aerial_perspective": 0.05,
	"ambient": Color(0.36, 0.26, 0.34),
	"ambient_energy": 0.56,
	"sun_color": Color(0.78, 0.48, 0.42),
	"sun_energy": 1.22,
	"tonemap_exposure": 0.82,
	"adjustment_brightness": 0.78,
	"adjustment_contrast": 1.14,
	"adjustment_saturation": 0.94,
}

## 星火中继站：全景天空 + 居民穹顶 H1 同款分层雾（勿开近空 billboard）
const RELAY_VISUAL_SCENE := {
	"dark_ground": true,
	"near_far_light_split": true,
}
const RELAY_E1_ENVIRONMENT := {
	# 对齐全景天空的冷青紫环境光；地面棕靠 desert 材质，勿用暖土 ambient 洗脏天空
	"panorama_energy": 1.52,
	"fog_color": Color(0.34, 0.32, 0.42),
	"fog_density": 0.00042,
	"fog_aerial_perspective": 0.085,
	"ambient": Color(0.48, 0.46, 0.54),
	"ambient_energy": 0.72,
	"sun_color": Color(0.86, 0.84, 0.94),
	"sun_energy": 1.68,
	"tonemap_exposure": 1.06,
}
const RELAY_E2_ENVIRONMENT := {
	"panorama_energy": 1.50,
	"fog_color": Color(0.34, 0.32, 0.42),
	"fog_density": 0.00042,
	"fog_aerial_perspective": 0.085,
	"ambient": Color(0.48, 0.46, 0.54),
	"ambient_energy": 0.72,
	"sun_color": Color(0.94, 0.82, 0.80),
	"sun_energy": 1.70,
	"tonemap_exposure": 1.06,
}
const RELAY_E3_ENVIRONMENT := {
	"panorama_energy": 1.54,
	"fog_color": Color(0.28, 0.36, 0.36),
	"fog_density": 0.00042,
	"fog_aerial_perspective": 0.085,
	"ambient": Color(0.44, 0.50, 0.50),
	"ambient_energy": 0.74,
	"sun_color": Color(0.82, 0.92, 0.88),
	"sun_energy": 1.72,
	"tonemap_exposure": 1.06,
}
const RELAY_E4_ENVIRONMENT := {
	"panorama_energy": 1.50,
	"fog_color": Color(0.34, 0.32, 0.42),
	"fog_density": 0.00042,
	"fog_aerial_perspective": 0.085,
	"ambient": Color(0.48, 0.46, 0.54),
	"ambient_energy": 0.72,
	"sun_color": Color(0.82, 0.88, 0.98),
	"sun_energy": 1.74,
	"tonemap_exposure": 1.06,
}
const DOME_LIGHTWEIGHT_JUMP := [
	RUNNER_OBS_LIGHT + "jump_crumbling_ruined_wall.glb",
	"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_grumpy_2_5d.png",
	"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_angry_2_5d.png",
]
const DOME_LIGHTWEIGHT_SLIDES := [
	RUNNER_OBS_LIGHT + "slide_rusty_industrial_pipeline.glb",
	RUNNER_OBS_LIGHT + "slide_spike_barrier.glb",
	MVP2_OBS + "废旧广告牌（滑铲）.glb",
	MVP2_OBS + "能量屏障（滑铲）.glb",
]
const DOME_ENV_PACK_V2 := [
	RUNNER_ENV_V2 + "mid_deadzone_billboard.glb",
	RUNNER_ENV_V2 + "midnear_spark_ring_1.glb",
	RUNNER_ENV_V2 + "midnear_spark_ring_2.glb",
]

const LOCATION_MISSIONS := [
	{
		"mission_id": "mission_dome_h1",
		"location_id": "dome",
		"layout_id": "mission_dome_h1",
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": true,
			"distant_density": 1.62,
		},
		"visual_scene": {
			"runway_side_lights": true,
			"ruin_dressing": true,
			"dark_ground": true,
			"near_far_light_split": true,
		},
		"environment": {
			"panorama_energy": 0.98,
			"fog_color": Color(0.20, 0.16, 0.30),
			"fog_density": 0.00072,
			"fog_aerial_perspective": 0.15,
			"ambient": Color(0.30, 0.26, 0.36),
			"ambient_energy": 0.46,
		},
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://mvp素材第二批/障碍物/0803/废旧广告牌（滑铲）.glb",
		],
		"jump_obstacles": DOME_LIGHTWEIGHT_JUMP,
		"slide_obstacles": DOME_LIGHTWEIGHT_SLIDES,
		"environment_pack_v2": DOME_ENV_PACK_V2,
		"environment_pack_v2_mix": 0.20,
		"runner_code": "Elsa",
		"cargo_name": "能源包",
		"cargo_name_en": "Energy Pack",
		"cargo_icon": "能源包",
		"cargo_load": 88,
		"cargo_trait": "过热 · 点按冲刺散热",
		"obstacle_density": 1.0,
		"fork_bias": false,
		"source_hearth": "Crystal Wastes",
		"target_hearth": "居民穹顶",
		"task_type": "Supply Run",
		"duration": 50.0,
		"order": 11,
		"difficulty": 1,
		"base_reward": 50,
		"runner_rhythm": "热浪区会累积过热：短按冲刺散热，长按冲刺会减速并掉损。",
		"environment_factor": "暗色废墟长桥，路侧暖灯常亮；近景昏黄、远景紫雾穹顶逐段显现。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "第一批能源包需送达居民穹顶，重启穹顶温控系统。",
	},
	{
		"mission_id": "mission_dome_h2",
		"location_id": "dome",
		"layout_id": "mission_dome_h2",
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": true,
			"distant_density": 1.58,
		},
		"environment": {
			"panorama_energy": 1.55,
			"fog_color": Color(0.30, 0.28, 0.46),
			"fog_density": 0.00062,
			"fog_aerial_perspective": 0.14,
			"ambient": Color(0.44, 0.40, 0.62),
			"ambient_energy": 0.78,
		},
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		],
		"jump_obstacles": DOME_LIGHTWEIGHT_JUMP,
		"slide_obstacles": DOME_LIGHTWEIGHT_SLIDES,
		"environment_pack_v2": DOME_ENV_PACK_V2,
		"environment_pack_v2_mix": 0.20,
		"runner_code": "Elsa",
		"cargo_name": "防御包",
		"cargo_name_en": "Defense Pack",
		"cargo_icon": "防御",
		"cargo_load": 92,
		"cargo_fragility": 0.7,
		"cargo_trait": "主动防御 · 碰撞减损 · 开局盾25",
		"obstacle_density": 1.05,
		"fork_bias": false,
		"source_hearth": "Crystal Wastes",
		"target_hearth": "居民穹顶",
		"task_type": "Repair Run",
		"duration": 65.0,
		"order": 12,
		"difficulty": 2,
		"base_reward": 60,
		"runner_rhythm": "防御包可主动格挡：激活后免疫伤害，但速度 -10% 且消耗耐力。",
		"environment_factor": "侧墙绕坑与抬升支路，广告牌与屏障交替出现。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "防御组件需抢修送达，加固穹顶外墙。",
	},
	{
		"mission_id": "mission_dome_h3",
		"location_id": "dome",
		"layout_id": "mission_dome_h3",
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": true,
			"distant_density": 1.54,
		},
		"environment": {
			"panorama_energy": 1.70,
			"fog_color": Color(0.48, 0.34, 0.24),
			"fog_density": 0.00056,
			"fog_aerial_perspective": 0.12,
			"ambient": Color(0.54, 0.40, 0.36),
			"ambient_energy": 0.80,
		},
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"jump_obstacles": DOME_LIGHTWEIGHT_JUMP,
		"slide_obstacles": DOME_LIGHTWEIGHT_SLIDES,
		"environment_pack_v2": DOME_ENV_PACK_V2,
		"environment_pack_v2_mix": 0.20,
		"runner_code": "Elsa",
		"cargo_name": "能源包",
		"cargo_name_en": "Energy Pack",
		"cargo_icon": "能源包",
		"cargo_load": 90,
		"cargo_trait": "中继 · 长程控温",
		"obstacle_density": 1.0,
		"fork_bias": true,
		"source_hearth": "Ember Relay",
		"target_hearth": "居民穹顶",
		"task_type": "Relay Run",
		"duration": 75.0,
		"order": 13,
		"difficulty": 3,
		"base_reward": 70,
		"runner_rhythm": "长程中继：多处分叉与热浪区，规划路线并点按冲刺控温。",
		"environment_factor": "延续水源据点晶砂天际，琥珀薄雾为主；侧向远景补局部云层。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "中继能源需经多段岔路送达穹顶核心。",
	},
	{
		"mission_id": "mission_dome_h4",
		"location_id": "dome",
		"layout_id": "mission_dome_h4",
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": true,
			"distant_density": 1.38,
		},
		"environment": {
			"panorama_energy": 1.72,
			"fog_color": Color(0.46, 0.22, 0.18),
			"fog_density": 0.00064,
			"fog_aerial_perspective": 0.15,
			"ambient": Color(0.56, 0.34, 0.30),
			"ambient_energy": 0.76,
		},
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
		],
		"jump_obstacles": DOME_LIGHTWEIGHT_JUMP,
		"slide_obstacles": DOME_LIGHTWEIGHT_SLIDES,
		"environment_pack_v2": DOME_ENV_PACK_V2,
		"environment_pack_v2_mix": 0.20,
		"runner_code": "Elsa",
		"cargo_name": "建设包",
		"cargo_name_en": "Construction Kit",
		"cargo_icon": "建设",
		"cargo_load": 105,
		"cargo_trait": "超重 · 单击短跳",
		"obstacle_density": 0.98,
		"fork_bias": false,
		"sandstorm_dps_mult": 1.14,
		"source_hearth": "Crystal Wastes",
		"target_hearth": "居民穹顶",
		"task_type": "Emergency Run",
		"duration": 40.0,
		"order": 14,
		"difficulty": 4,
		"base_reward": 80,
		"mechanics_hint": "40 秒限时：超重建设包单击短跳，多吃加速靴。",
		"runner_rhythm": "极限负重限时：双击满跳越过障碍，冲刺缩短暴露时间。",
		"environment_factor": "赤色暮雾，末段紫球冲撞区。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "紧急建设包必须在时限内送达穹顶。",
	},
	{
		"mission_id": "mission_reservoir_01",
		"location_id": "reservoir",
		"layout_id": "mission_reservoir_w1",
		"panorama": "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w1_scene_sky.png",
		"ground_texture": "res://assets/maps/route_levels/runner_60s/backgrounds/textures/glass_desert_w1_ground_albedo.jpg",
		"textured_ground": true,
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"environment": RESERVOIR_W1_ENVIRONMENT,
		"environment_pack_v2_mix": 0.0,
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.48,
		},
		"runner_code": "Elsa",
		"cargo_name": "净水包",
		"cargo_name_en": "Water Pack",
		"cargo_icon": "净水",
		"cargo_load": 90,
		"cargo_fragility": 1.5,
		"cargo_trait": "极脆 ×1.5",
		"obstacle_density": 0.88,
		"fork_bias": false,
		"source_hearth": "居民穹顶",
		"target_hearth": "水源据点",
		"task_type": "Supply Run",
		"duration": 55.0,
		"order": 20,
		"difficulty": 1,
		"base_reward": 50,
		"runner_rhythm": "平坦直道、128BPM 中道连续金币，保护易碎净水包。",
		"environment_factor": "琥珀夕照薄雾，全息能量轨视野清晰。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "第一批净水包需送达水源据点，重启过滤系统。",
	},
	{
		"mission_id": "mission_reservoir_02",
		"location_id": "reservoir",
		"layout_id": "mission_reservoir_w2",
		"panorama": "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w2_pink_sky.png",
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		],
		"environment": RESERVOIR_W2_ENVIRONMENT,
		"environment_pack_v2_mix": 0.0,
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.42,
		},
		"runner_code": "Elsa",
		"cargo_name": "建设包",
		"cargo_name_en": "Construction Kit",
		"cargo_icon": "建设",
		"cargo_load": 95,
		"cargo_trait": "超重 · 单击短跳",
		"obstacle_density": 1.15,
		"fork_bias": false,
		"source_hearth": "居民穹顶",
		"target_hearth": "水源据点",
		"task_type": "Supply Run",
		"duration": 55.0,
		"order": 22,
		"difficulty": 2,
		"base_reward": 50,
		"runner_rhythm": "超重建设包：单击只会短跳（更低），需快速双击才达标准高度。跳跃障碍请连点两次越过。",
		"environment_factor": "淡粉紫混蓝天空，路边物体用暖石色/青色拉开层次。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "建设包是修复水源设施的基础物资，需完整送达。",
	},
	{
		"mission_id": "mission_reservoir_03",
		"location_id": "reservoir",
		"layout_id": "mission_reservoir_w3",
		"panorama": "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w1_scene_sky.png",
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"environment": RESERVOIR_W3_ENVIRONMENT,
		"environment_pack_v2_mix": 0.0,
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.40,
		},
		"runner_code": "Elsa",
		"cargo_name": "建设包",
		"cargo_name_en": "Construction Kit",
		"cargo_icon": "建设",
		"cargo_load": 100,
		"cargo_trait": "超重 · 单击短跳",
		"obstacle_density": 1.15,
		"fork_bias": true,
		"source_hearth": "居民穹顶",
		"target_hearth": "水源据点",
		"task_type": "Repair Run",
		"duration": 65.0,
		"order": 23,
		"difficulty": 3,
		"base_reward": 60,
		"runner_rhythm": "重装躲避：连续障碍带。建设包单击短跳、双击满跳，提前判断连点时机。",
		"environment_factor": "粉紫混橙暮空，冰蓝极光拉开层次。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "建设组件需同步送达，完成抢修作业。",
	},
	{
		"mission_id": "mission_reservoir_04",
		"location_id": "reservoir",
		"layout_id": "mission_reservoir_w4",
		"panorama": "res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w1_scene_sky.png",
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"environment": RESERVOIR_W4_ENVIRONMENT,
		"environment_pack_v2_mix": 0.0,
		"sky_accents": {
			"energy_gates": true,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.36,
		},
		"runner_code": "Elsa",
		"cargo_name": "净水包",
		"cargo_name_en": "Water Pack",
		"cargo_icon": "净水",
		"cargo_load": 85,
		"cargo_fragility": 1.5,
		"cargo_trait": "极脆 ×1.5",
		"obstacle_density": 1.08,
		"fork_bias": false,
		"sandstorm_dps_mult": 1.12,
		"source_hearth": "居民穹顶",
		"target_hearth": "水源据点",
		"task_type": "Emergency Run",
		"duration": 40.0,
		"order": 24,
		"difficulty": 4,
		"base_reward": 80,
		"mechanics_hint": "限时挑战：多吃加速靴提速。集满 5 个解锁紧急冲刺（电脑 Shift/E，手机点按冲刺键）。",
		"runner_rhythm": "毒雾初见：暴露会阶梯掉损，用冲刺缩短暴露时间，注意限时。",
		"environment_factor": "40 秒限时；暮色压暗，洋红雾带。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "紧急净水补给：限时送达，路线短但障碍密集。",
	},
	{
		"mission_id": "mission_medical_m1",
		"location_id": "medical",
		"layout_id": "mission_medical_m1",
		"panorama": MEDICAL_M1_SKY_PANORAMA,
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
		],
		"distant_accent_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
		],
		"environment": MEDICAL_M1_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "医疗包",
		"cargo_name_en": "Medical Pack",
		"cargo_icon": "医疗",
		"cargo_load": 78,
		"obstacle_density": 0.92,
		"fork_bias": false,
		"source_hearth": "居民穹顶",
		"target_hearth": "医疗据点",
		"task_type": "Emergency Run",
		"duration": 40.0,
		"order": 31,
		"difficulty": 1,
		"base_reward": 50,
		"mechanics_hint": "40 秒限时：多吃加速靴缩短暴露时间。",
		"runner_rhythm": "直线热身后接轻S弯与分叉，再上侧墙；沿途多加速靴。",
		"environment_factor": "夕照云层，琥珀暖光。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "第一批医疗包需送达医疗据点，重启基础救治能力。",
	},
	{
		"mission_id": "mission_medical_m2",
		"location_id": "medical",
		"layout_id": "mission_medical_m2",
		"panorama": MEDICAL_M2_SKY_PANORAMA,
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		],
		"distant_accent_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
		],
		"environment": MEDICAL_M2_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "医疗包",
		"cargo_name_en": "Medical Pack",
		"cargo_icon": "医疗",
		"cargo_load": 76,
		"cargo_fragility": 1.5,
		"cargo_trait": "极脆 ×1.5",
		"obstacle_density": 1.35,
		"fork_bias": false,
		"source_hearth": "居民穹顶",
		"target_hearth": "医疗据点",
		"task_type": "Emergency Run",
		"duration": 40.0,
		"order": 32,
		"difficulty": 2,
		"base_reward": 60,
		"mechanics_hint": "40 秒限时 + 极脆医疗包：障碍极密，零碰撞才安全。",
		"runner_rhythm": "连续S弯后接平台跳跃与左侧墙，末段分叉；限时多吃加速靴。",
		"environment_factor": "暮色云层，暖冷光影变化。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "抢修医疗物资：任何碰撞都会重创极脆医疗包。",
	},
	{
		"mission_id": "mission_medical_m3",
		"location_id": "medical",
		"layout_id": "mission_medical_m3",
		"panorama": MEDICAL_M3_SKY_PANORAMA,
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		],
		"distant_accent_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb",
		],
		"environment": MEDICAL_M3_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "净水包",
		"cargo_name_en": "Water Pack",
		"cargo_icon": "净水",
		"cargo_load": 88,
		"cargo_fragility": 1.5,
		"cargo_trait": "极脆 ×1.5",
		"obstacle_density": 1.05,
		"fork_bias": true,
		"sandstorm_dps_mult": 1.1,
		"source_hearth": "居民穹顶",
		"target_hearth": "医疗据点",
		"task_type": "Relay Run",
		"duration": 75.0,
		"order": 33,
		"difficulty": 3,
		"base_reward": 70,
		"runner_rhythm": "长途毒雾：多处分叉，选薄雾支路并控速通过长段毒雾。",
		"environment_factor": "同一片云层，玫暖主光。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "净水包中继运输：为医疗据点提供长期净水补给。",
	},
	{
		"mission_id": "mission_medical_m4",
		"location_id": "medical",
		"layout_id": "mission_medical_m4",
		"panorama": MEDICAL_M4_SKY_PANORAMA,
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
		],
		"distant_accent_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		],
		"environment": MEDICAL_M4_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "医疗包",
		"cargo_name_en": "Medical Pack",
		"cargo_icon": "医疗",
		"cargo_load": 82,
		"cargo_fragility": 1.5,
		"cargo_trait": "极脆 ×1.5 · 双货",
		"cargo_secondary": "净水包",
		"obstacle_density": 1.08,
		"fork_bias": false,
		"source_hearth": "居民穹顶",
		"target_hearth": "医疗据点",
		"task_type": "Emergency Run",
		"duration": 40.0,
		"order": 34,
		"difficulty": 4,
		"base_reward": 80,
		"mechanics_hint": "40 秒限时：医疗+净水双货，兼顾零碰撞与加速靴。",
		"runner_rhythm": "早Y岔后接平台与S弯，再上右侧墙冲刺；双货限时多吃加速靴。",
		"environment_factor": "暮紫压暗，剪影带更沉。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "紧急医疗与净水同步送达，完成医疗据点核心补给。",
	},
	{
		"mission_id": "mission_relay_e1",
		"location_id": "relay",
		"layout_id": "layout_set_relay_1",
		"road_style": "holographic",
		"ground_texture": RUNNER_GROUND_TEXTURE,
		"textured_ground": true,
		"visual_scene": RELAY_VISUAL_SCENE,
		"sky_accents": {
			"energy_gates": false,
			"energy_vortex": false,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.22,
		},
		"environment_pack_v2_mix": 0.0,
		"midground_props": RELAY_MID_POOL,
		"near_runway_props": RELAY_NEAR_POOL,
		"near_sky_textures": [],
		"distant_tower_props": RELAY_DISTANT_TOWER_POOL,
		"distant_accent_props": RELAY_DISTANT_ACCENT_POOL,
		"distant_spaceship_props": RELAY_DISTANT_SHIP_POOL,
		"distant_hearth_props": [],
		"jump_obstacles": [RELAY_OBSTACLE],
		"slide_obstacles": [RELAY_OBSTACLE],
		"environment": RELAY_E1_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "星火核心",
		"cargo_name_en": "Ember Core",
		"cargo_icon": "星火核心",
		"cargo_load": 95,
		"cargo_trait": "点火核心 · 身后零潮异能体",
		"obstacle_density": 1.05,
		"fork_bias": false,
		"source_hearth": "居民穹顶",
		"target_hearth": "星火中继站",
		"task_type": "Ignition Run",
		"enable_chaser": true,
		"pressure_chaser": true,
		"chaser_mode": "pressure",
		"chaser_initial_pressure": 20.0,
		"chaser_creep_mult": 0.72,
		"duration": 75.0,
		"order": 40,
		"difficulty": 1,
		"base_reward": 100,
		"mechanics_hint": "危机降临：护送星火核心；身后异能量前沿按压迫值迫近，受击加压，加速靴（稳定器）减压。",
		"runner_rhythm": "入门追击：多加速靴 + 短侧墙加速，保持身后距离。",
		"environment_factor": "紫极光夜：保留原天空，远景稀疏只留剪影塔影。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "星火中继站首次接收星火核心——危机沙暴中，零潮已嗅到核心的气息。",
	},
	{
		"mission_id": "mission_relay_e2",
		"location_id": "relay",
		"layout_id": "layout_set_relay_2",
		"road_style": "holographic",
		"ground_texture": RUNNER_GROUND_TEXTURE,
		"textured_ground": true,
		"visual_scene": RELAY_VISUAL_SCENE,
		"sky_accents": {
			"energy_gates": false,
			"energy_vortex": false,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.26,
		},
		"environment_pack_v2_mix": 0.0,
		"midground_props": [
			RELAY_MIDGROUND_DRONE,
			RELAY_MID_NEON,
			RELAY_MID_SPHERE,
			RELAY_MID_EXCAVATOR,
			RELAY_MID_CORAL,
			RELAY_MID_METEOR,
		],
		"near_runway_props": [
			RELAY_MID_SPHERE,
			RELAY_MID_NEON,
			RELAY_MID_CORAL,
			RELAY_MID_PURIFIER,
		],
		"near_sky_textures": [],
		"distant_tower_props": [
			RELAY_DISTANT_RUIN,
			RELAY_DIST_SIGNAL,
			RELAY_DISTANT_TOWER,
			RELAY_DIST_CRYSTAL_2,
			RELAY_DISTANT_TURBINE,
			RELAY_DIST_CRYSTAL_1,
		],
		"distant_accent_props": RELAY_DISTANT_ACCENT_POOL,
		"distant_spaceship_props": RELAY_DISTANT_SHIP_POOL,
		"distant_hearth_props": [],
		"jump_obstacles": [RELAY_OBSTACLE],
		"slide_obstacles": [RELAY_OBSTACLE],
		"environment": RELAY_E2_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "能源包",
		"cargo_name_en": "Energy Pack",
		"cargo_icon": "能源包",
		"cargo_load": 92,
		"cargo_trait": "过热 · 点按冲刺散热",
		"obstacle_density": 1.12,
		"fork_bias": true,
		"sandstorm_dps_mult": 1.22,
		"source_hearth": "防御哨站",
		"target_hearth": "星火中继站",
		"task_type": "Relay Run",
		"enable_chaser": true,
		"pressure_chaser": true,
		"chaser_mode": "pressure",
		"chaser_initial_pressure": 24.0,
		"chaser_creep_mult": 0.82,
		"duration": 85.0,
		"order": 41,
		"difficulty": 2,
		"base_reward": 70,
		"mechanics_hint": "炼狱迷宫：长途多分叉；身后异能量前沿压迫追击，加速靴减压，无失误可持续甩开。",
		"runner_rhythm": "长途追击：多段加速靴、多次短侧墙上墙，注意吃 buff 甩开身后异能体。",
		"environment_factor": "赤潮夜幕：酒红云海压境，粉红流光掠过地平线。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "能源包需穿越炼狱迷宫才能维持中继站温控——这是荒原上最漫长的补给线。",
	},
	{
		"mission_id": "mission_relay_e3",
		"location_id": "relay",
		"layout_id": "layout_set_relay_3",
		"road_style": "holographic",
		"ground_texture": RUNNER_GROUND_TEXTURE,
		"textured_ground": true,
		"visual_scene": RELAY_VISUAL_SCENE,
		"sky_accents": {
			"energy_gates": false,
			"energy_vortex": false,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.24,
		},
		"environment_pack_v2_mix": 0.0,
		"midground_props": [
			RELAY_MIDGROUND_DRONE,
			RELAY_MID_METEOR,
			RELAY_MID_NEON,
			RELAY_MID_CORAL,
			RELAY_MID_SPHERE,
			RELAY_MID_EXCAVATOR,
		],
		"near_runway_props": [
			RELAY_MID_METEOR,
			RELAY_MID_NEON,
			RELAY_MID_CORAL,
			RELAY_MID_PURIFIER,
		],
		"near_sky_textures": [],
		"distant_tower_props": [
			RELAY_DISTANT_TURBINE,
			RELAY_DISTANT_RUIN,
			RELAY_DIST_CRYSTAL_1,
			RELAY_DIST_SIGNAL,
			RELAY_DISTANT_TOWER,
			RELAY_DIST_CRYSTAL_2,
		],
		"distant_accent_props": RELAY_DISTANT_ACCENT_POOL,
		"distant_spaceship_props": RELAY_DISTANT_SHIP_POOL,
		"distant_hearth_props": [],
		"jump_obstacles": [RELAY_OBSTACLE],
		"slide_obstacles": [RELAY_OBSTACLE],
		"environment": RELAY_E3_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "能源包",
		"cargo_name_en": "Energy Pack",
		"cargo_icon": "能源包",
		"cargo_load": 86,
		"obstacle_density": 1.18,
		"fork_bias": false,
		"source_hearth": "医疗据点",
		"target_hearth": "星火中继站",
		"task_type": "Emergency Run",
		"enable_chaser": true,
		"pressure_chaser": true,
		"chaser_mode": "pressure",
		"chaser_initial_pressure": 26.0,
		"chaser_creep_mult": 0.78,
		"duration": 40.0,
		"order": 42,
		"difficulty": 3,
		"base_reward": 80,
		"mechanics_hint": "40 秒限时：障碍极密，压迫追击开启；多踩稳定器减压，剩余时间越高奖励越高。",
		"runner_rhythm": "紧急冲刺：短程高密度换道，加速靴甩开身后异能体，末段落石变速。",
		"environment_factor": "碧极光幕：青绿极光垂落，雾面映出冷翠反光。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "医疗据点紧急调拨能源包——中继站信号塔必须在四十秒内重新通电。",
	},
	{
		"mission_id": "mission_relay_e4",
		"location_id": "relay",
		"layout_id": "layout_set_relay_4",
		"road_style": "holographic",
		"ground_texture": RUNNER_GROUND_TEXTURE,
		"textured_ground": true,
		"visual_scene": RELAY_VISUAL_SCENE,
		"sky_accents": {
			"energy_gates": false,
			"energy_vortex": false,
			"aurora": false,
			"panorama_billboards": false,
			"distant_density": 1.28,
		},
		"environment_pack_v2_mix": 0.0,
		"midground_props": RELAY_MID_POOL,
		"near_runway_props": RELAY_NEAR_POOL,
		"near_sky_textures": [],
		"distant_tower_props": RELAY_DISTANT_TOWER_POOL,
		"distant_accent_props": RELAY_DISTANT_ACCENT_POOL,
		"distant_spaceship_props": RELAY_DISTANT_SHIP_POOL,
		"distant_hearth_props": [],
		"jump_obstacles": [RELAY_OBSTACLE],
		"slide_obstacles": [RELAY_OBSTACLE],
		"environment": RELAY_E4_ENVIRONMENT,
		"runner_code": "Elsa",
		"cargo_name": "星火核心",
		"cargo_name_en": "Ember Core",
		"cargo_icon": "星火核心",
		"cargo_load": 98,
		"cargo_trait": "点火核心 · 身后零潮异能体",
		"obstacle_density": 1.22,
		"fork_bias": false,
		"sandstorm_dps_mult": 1.16,
		"source_hearth": "星火中继站",
		"target_hearth": "星火中继站",
		"task_type": "Ignition Run",
		"enable_chaser": true,
		"pressure_chaser": true,
		"chaser_mode": "pressure",
		"chaser_initial_pressure": 32.0,
		"chaser_creep_mult": 1.05,
		"duration": 80.0,
		"order": 43,
		"difficulty": 4,
		"base_reward": 100,
		"mechanics_hint": "黎明线：风暴眼+熔岩+落石；异能量前沿压迫最高，需频繁稳定器减压避免被吞没。",
		"runner_rhythm": "终极点火：多段加速靴与短侧墙，交替危害中保持身后距离。",
		"environment_fix": "青白能量风暴夜 · 远景塔群最密。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "黎明线——携带星火核心穿越风暴眼，点亮中继站最后的信号链路。",
	},
	{
		"mission_id": "mission_gate_d1",
		"location_id": "gate",
		"layout_id": "mission_gate_d1",
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/distant/distant_signal_tower.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"environment_pack_v2_mix": 0.0,
		"environment": {
			"panorama_energy": 1.58,
			"fog_color": Color(0.48, 0.30, 0.22),
			"fog_density": 0.00064,
			"fog_aerial_perspective": 0.14,
			"ambient": Color(0.56, 0.38, 0.30),
			"ambient_energy": 0.76,
		},
		"runner_code": "Elsa",
		"cargo_name": "防御包",
		"cargo_name_en": "Defense Pack",
		"cargo_icon": "防御",
		"cargo_load": 108,
		"cargo_fragility": 0.7,
		"cargo_trait": "主动防御 · 碰撞减损 · 开局盾25",
		"obstacle_density": 1.0,
		"fork_bias": false,
		"sandstorm_dps_mult": 1.18,
		"source_hearth": "居民穹顶",
		"target_hearth": "防御哨站",
		"task_type": "Supply Run",
		"duration": 55.0,
		"order": 51,
		"difficulty": 1,
		"base_reward": 50,
		"runner_rhythm": "补给防御：跳铲换道，右道弹射可加速或飞过熔岩；落地仍可能撞障，记得开防护罩。",
		"environment_factor": "橙红火力带，近景破球机器人与挖掘机，远景信号塔。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "防御包首批补给：穿越火力覆盖带送达哨站。",
	},
	{
		"mission_id": "mission_gate_d2",
		"location_id": "gate",
		"layout_id": "mission_gate_d2",
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		],
		"environment_pack_v2_mix": 0.0,
		"jump_obstacles": [
			"res://assets/maps/route_levels/models/obstacles/jump/spiky_barrier.glb",
			"res://assets/maps/route_levels/models/obstacles/jump/thorn_bush.glb",
		],
		"slide_obstacles": [
			"res://assets/maps/route_levels/models/obstacles/slide/energy_barrier.glb",
			"res://assets/maps/route_levels/models/obstacles/slide/ruined_billboard.glb",
		],
		"environment": {
			"panorama_energy": 1.54,
			"fog_color": Color(0.42, 0.28, 0.38),
			"fog_density": 0.00060,
			"fog_aerial_perspective": 0.13,
			"ambient": Color(0.50, 0.36, 0.48),
			"ambient_energy": 0.74,
		},
		"runner_code": "Elsa",
		"cargo_name": "建设包",
		"cargo_name_en": "Construction Kit",
		"cargo_icon": "建设",
		"cargo_load": 105,
		"cargo_trait": "超重 · 单击短跳",
		"obstacle_density": 1.32,
		"fork_bias": false,
		"source_hearth": "居民穹顶",
		"target_hearth": "防御哨站",
		"task_type": "Repair Run",
		"duration": 65.0,
		"order": 52,
		"difficulty": 2,
		"base_reward": 60,
		"runner_rhythm": "超重建包：单击短跳、双击满跳。左道弹射飞过短熔岩，落地注意障碍；后段熔岩走侧墙，不要在空中再跳。",
		"environment_factor": "工地侧景：挖掘机、琥珀晶、陨石近景。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "哨站抢修：超重建设包需精准跳跃通过密集障碍带。",
	},
	{
		"mission_id": "mission_gate_d3",
		"location_id": "gate",
		"layout_id": "mission_gate_d3",
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/distant/distant_signal_tower.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb",
			"res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb",
		],
		"environment_pack_v2_mix": 0.0,
		"environment": {
			"panorama_energy": 1.62,
			"fog_color": Color(0.50, 0.32, 0.24),
			"fog_density": 0.00056,
			"fog_aerial_perspective": 0.12,
			"ambient": Color(0.54, 0.40, 0.34),
			"ambient_energy": 0.80,
		},
		"runner_code": "Elsa",
		"cargo_name": "防御包",
		"cargo_name_en": "Defense Pack",
		"cargo_icon": "防御",
		"cargo_load": 112,
		"cargo_fragility": 0.7,
		"cargo_trait": "主动防御 · 碰撞减损 · 开局盾25",
		"cargo_secondary": "能源包",
		"obstacle_density": 1.08,
		"fork_bias": true,
		"sandstorm_dps_mult": 1.12,
		"source_hearth": "居民穹顶",
		"target_hearth": "防御哨站",
		"task_type": "Relay Run",
		"duration": 90.0,
		"order": 53,
		"difficulty": 3,
		"base_reward": 70,
		"runner_rhythm": "长途双货：热浪里点按散热，受击开防护罩。右道弹射过熔岩，后段平台跳再上侧墙。",
		"environment_factor": "补给车队近景（净化器/药箱）+ 信号塔天际线。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "防御与能源中继运输：为哨站提供持续防线与能源。",
	},
	{
		"mission_id": "mission_gate_d4",
		"location_id": "gate",
		"layout_id": "mission_gate_d4",
		"midground_props": [
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		],
		"near_runway_props": [
			"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
			"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
			"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		],
		"environment_pack_v2_mix": 0.0,
		"environment": {
			"panorama_energy": 1.68,
			"fog_color": Color(0.46, 0.22, 0.18),
			"fog_density": 0.00066,
			"fog_aerial_perspective": 0.15,
			"ambient": Color(0.54, 0.32, 0.28),
			"ambient_energy": 0.74,
		},
		"runner_code": "Elsa",
		"cargo_name": "能源包",
		"cargo_name_en": "Energy Pack",
		"cargo_icon": "能源包",
		"cargo_load": 86,
		"cargo_trait": "过热 · 点按冲刺散热",
		"obstacle_density": 0.98,
		"fork_bias": false,
		"sandstorm_dps_mult": 1.14,
		"source_hearth": "居民穹顶",
		"target_hearth": "防御哨站",
		"task_type": "Emergency Run",
		"duration": 40.0,
		"order": 54,
		"difficulty": 4,
		"base_reward": 80,
		"mechanics_hint": "40 秒限时：点按散热。右道弹射飞熔岩；常规岔路左道双弹射提速；末段多加速。",
		"runner_rhythm": "限时能源：过热就点按。右弹射过熔岩，常规岔路踩双垫抢速，末段加速 buff 冲刺。",
		"environment_factor": "赤雾 + 近景破球/霓虹/陨石，末段紫球。",
		"unlock_ids": [],
		"unlocks": [],
		"story": "紧急能源包必须在时限内送达防御哨站核心。",
	},
]

const EMBER_COIN_VALUE := 15
const CARGO_DAMAGE_PER_HIT := 12.0
const CHASER_NAME := "Nulltide Wraith"

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

const ELSA_ACTION_ROOT := "res://assets/maps/route_levels/models/characters/elsa/"
const ROOK_ROOT := "res://assets/maps/route_levels/models/characters/rook/"
const BUILDINGS_ROOT := "res://assets/maps/route_levels/models/environment/buildings/"
const MAPS_2D_ROOT := "res://assets/maps/route_levels/models/environment/buildings/_extras_2d/"
const MVP2_ROOT := "res://mvp素材第二批/"
const MVP2_CARGO_ROOT := MVP2_ROOT + "运输包2d/"
const CARGO_UI_ICON_ROOT := "res://assets/maps/route_levels/mobile_home/ui_cargo_icons/"

const CARGO_UI_ICON_FILES := {
	"净水": "icon_water_pack_transparent.png",
	"建设": "icon_construction_kit_transparent.png",
	"医疗": "icon_medical_pack_transparent.png",
	"防御": "icon_defense_pack_transparent.png",
	"能源包": "icon_energy_pack_transparent.png",
	"星火核心": "icon_ember_core_transparent.png",
}

const CARGO_UI_ICON_BY_EN := {
	"water pack": "icon_water_pack_transparent.png",
	"water module": "icon_water_pack_transparent.png",
	"construction kit": "icon_construction_kit_transparent.png",
	"medical pack": "icon_medical_pack_transparent.png",
	"defense pack": "icon_defense_pack_transparent.png",
	"energy pack": "icon_energy_pack_transparent.png",
	"ember core": "icon_ember_core_transparent.png",
}

const PLAYER_ELSA := {
	"model": ELSA_ACTION_ROOT + "idle.glb",
	"run_left": ELSA_ACTION_ROOT + "run_left.glb",
	"run_right": ELSA_ACTION_ROOT + "run_right.glb",
	"jump_start": ELSA_ACTION_ROOT + "jump_start.glb",
	"jump_peak": ELSA_ACTION_ROOT + "jump_apex.glb",
	"landing": ELSA_ACTION_ROOT + "jump_land.glb",
	"slide": ELSA_ACTION_ROOT + "slide.glb",
	"animated_model": ELSA_ACTION_ROOT + "animated.fbx",
	"run_anim": "mixamo_com",
	"run_anim_speed": 1.06,
	"surface_texture": ELSA_ACTION_ROOT + "elsa正面_tripo_image_e7db2388-3d5b-4a2d-ab57-950535a6e250_0_0.jpg",
	"portrait": "res://assets/maps/route_levels/mobile_home/ui_character/elsa_fullbody.png",
	"model_yaw": 0.0,
	"animated_model_yaw": 180.0,
	"slide_yaw": 0.0,
	"intro_body_yaw": 180.0,
}

const PLAYER_ROOK := {
	"model": ROOK_ROOT + "idle.glb",
	"run_left": ROOK_ROOT + "run_01.glb",
	"run_right": ROOK_ROOT + "run_02.glb",
	"run_alt": ROOK_ROOT + "run_03.glb",
	"jump_start": ROOK_ROOT + "jump_start.glb",
	"jump_peak": ROOK_ROOT + "jump_apex.glb",
	"landing": ROOK_ROOT + "jump_land.glb",
	"slide": ROOK_ROOT + "slide.glb",
	"portrait": ROOK_ROOT + "portrait.jpg",
	"model_yaw": 180.0,
	"slide_yaw": 180.0,
	"intro_body_yaw": 0.0,
}

const ASSETS := {
	"panorama": RUNNER_SKY_PANORAMA,
	"jump_obstacles": [
		"res://assets/maps/route_levels/models/obstacles/jump/spiky_barrier.glb",
		"res://assets/maps/route_levels/models/obstacles/jump/thorn_bush.glb",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_grumpy_2_5d.png",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_angry_2_5d.png",
	],
	"slide_obstacle": "res://assets/maps/route_levels/models/obstacles/slide/ruined_billboard.glb",
	"slide_obstacles": [
		"res://assets/maps/route_levels/models/obstacles/slide/ruined_billboard.glb",
		"res://assets/maps/route_levels/models/obstacles/slide/energy_barrier.glb",
	],
	"side_props": [],
	"midground_props": [
		"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
		"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
		"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
		"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
	],
	"landmark_props": [
		"res://assets/maps/route_levels/models/environment/buildings/dome_habitat.glb",
		"res://assets/maps/route_levels/models/environment/buildings/water_outpost.glb",
		"res://assets/maps/route_levels/models/environment/buildings/spark_relay.glb",
		"res://assets/maps/route_levels/models/environment/buildings/defense_post.glb",
	],
	# 极远天际线：水晶能量柱为主；信号塔由防御哨站任务单独配置
	"distant_tower_props": [
		"res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb",
	],
	"distant_pod_props": [
		"res://assets/maps/route_levels/models/environment/distant/futuristic_pod.glb",
	],
	"distant_spaceship_props": [
		"res://assets/maps/route_levels/models/environment/distant/futuristic_spaceship.glb",
	],
	"distant_hearth_props": [
		"res://assets/maps/route_levels/models/environment/buildings/dome_habitat.glb",
	],
	"hearth": "res://assets/maps/route_levels/models/environment/buildings/dome_habitat.glb",
	"players": {
		"elsa": PLAYER_ELSA,
		"rook": PLAYER_ROOK,
	},
	"player": PLAYER_ELSA,
}

## 早期批次：居民穹顶专用（断墙/锈管/尖刺 + 废墟中景）。水源据点用 RESERVOIR_VISUAL_KIT，互不覆盖。
const EARLY_VISUAL_KIT := {
	"midground_props": [
		RUNNER_MID + "amber_crystal_coral.glb",
		RUNNER_MID + "glowing_energy_meteorite.glb",
		RUNNER_MID + "cracked_sphere_robot.glb",
		RUNNER_MID + "neon_sign_prop.glb",
	],
	"jump_obstacles": [
		RUNNER_OBS_LIGHT + "jump_crumbling_ruined_wall.glb",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_grumpy_2_5d.png",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_angry_2_5d.png",
	],
	"slide_obstacles": [
		RUNNER_OBS_LIGHT + "slide_rusty_industrial_pipeline.glb",
		RUNNER_OBS_LIGHT + "slide_spike_barrier.glb",
		MVP2_OBS + "废旧广告牌（滑铲）.glb",
		MVP2_OBS + "能量屏障（滑铲）.glb",
	],
	"distant_tower_props": [
		RUNNER_DIST + "fantasy_crystal_tower.glb",
	],
	"distant_spaceship_props": [
		RUNNER_DIST + "futuristic_spaceship.glb",
	],
}

## 水源据点：两侧高大水晶/能量山内倾成通道，底座不得压跑道
const RESERVOIR_VISUAL_KIT := {
	"midground_props": [
		RUNNER_MID + "amber_crystal_coral.glb",
		RUNNER_MID + "midground_water_purifier.glb",
		RUNNER_MID + "glowing_energy_meteorite.glb",
		RUNNER_MID + "neon_sign_prop.glb",
		RUNNER_MID + "midground_excavator_robot.glb",
	],
	"near_runway_props": [
		RUNNER_MID + "amber_crystal_coral.glb",
		RUNNER_MID + "midground_water_purifier.glb",
		RUNNER_MID + "glowing_energy_meteorite.glb",
		RUNNER_MID + "neon_sign_prop.glb",
	],
	"jump_obstacles": [
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_grumpy_2_5d.png",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_angry_2_5d.png",
	],
	"slide_obstacles": [
		MVP2_OBS + "废旧广告牌（滑铲）.glb",
	],
	"distant_tower_props": [
		RUNNER_DIST + "fantasy_crystal_tower.glb",
		RUNNER_DIST + "giant_energy_crystal_pillar_1.glb",
		RUNNER_DIST + "giant_energy_crystal_pillar_2.glb",
	],
	"distant_accent_props": [
		RUNNER_MID + "midground_water_purifier.glb",
		RUNNER_MID + "amber_crystal_coral.glb",
		RUNNER_MID + "midground_excavator_robot.glb",
	],
	"distant_hearth_props": [
		BUILDINGS_ROOT + "water_outpost.glb",
	],
	"distant_spaceship_props": [
		RUNNER_DIST + "futuristic_spaceship.glb",
		RUNNER_DIST + "futuristic_pod.glb",
	],
}

## 危机批次：医疗据点 + 防御哨站共用（医疗箱/水晶树/无人机/信号塔等交叉）
const CRISIS_VISUAL_KIT := {
	"midground_props": [
		RUNNER_MID + "midground_medical_pod.glb",
		RUNNER_MID + "midground_medical_crate.glb",
		RUNNER_MID + "midground_water_purifier.glb",
		RUNNER_MID + "midground_excavator_robot.glb",
		RUNNER_MID + "cracked_sphere_robot.glb",
		RUNNER_MID + "amber_crystal_coral.glb",
		RUNNER_MID + "neon_sign_prop.glb",
		RUNNER_MID + "glowing_energy_meteorite.glb",
	],
	"near_runway_props": [
		RUNNER_MID + "midground_medical_crate.glb",
		RUNNER_MID + "cracked_sphere_robot.glb",
		RUNNER_MID + "midground_water_purifier.glb",
		RUNNER_MID + "midground_medical_pod.glb",
	],
	"jump_obstacles": EARLY_VISUAL_KIT["jump_obstacles"],
	"slide_obstacles": EARLY_VISUAL_KIT["slide_obstacles"],
	"distant_tower_props": [
		RUNNER_DIST + "distant_signal_tower.glb",
		RUNNER_DIST + "fantasy_crystal_tower.glb",
	],
	"distant_accent_props": [
		RUNNER_MID + "midground_water_purifier.glb",
		RUNNER_MID + "midground_medical_crate.glb",
		RUNNER_MID + "cracked_sphere_robot.glb",
		RUNNER_MID + "midground_excavator_robot.glb",
		RUNNER_MID + "amber_crystal_coral.glb",
	],
	"distant_spaceship_props": [
		RUNNER_DIST + "futuristic_spaceship.glb",
	],
}

const MVP_MAPS := {
	"explore_zh": MAPS_2D_ROOT + "晶砂荒原中文地图9：16.webp",
	"explore_en": "res://assets/maps/route_levels/planet_explore/maps/crystal_wastes_map_9x16_en.jpg",
	"preview_zh": MAPS_2D_ROOT + "晶砂荒原地图中文.webp",
	"preview_en": MAPS_2D_ROOT + "晶砂荒原地图英文.webp",
}

const MVP_LOCATIONS := {
	"dome": {
		"preview_2d": MAPS_2D_ROOT + "居民穹顶2d展示图.webp",
		"model_3d": BUILDINGS_ROOT + "dome_habitat.glb",
		"finish_silhouette": "res://assets/maps/route_levels/runner_60s/settlement/habitat_dome_silhouette.jpg",
	},
	"reservoir": {
		"preview_2d": MAPS_2D_ROOT + "水源据点2d.webp",
		"model_3d": BUILDINGS_ROOT + "water_outpost.glb",
		"finish_silhouette": "res://assets/maps/route_levels/runner_60s/settlement/water_station_silhouette.png",
	},
	"medical": {
		"preview_2d": MAPS_2D_ROOT + "医疗据点2d.webp",
		"model_3d": BUILDINGS_ROOT + "medical_outpost.glb",
		"finish_silhouette": "res://assets/maps/route_levels/runner_60s/settlement/medical_settlement_silhouette.png",
	},
	"relay": {
		"preview_2d": MAPS_2D_ROOT + "星火中继站2d.webp",
		"model_3d": BUILDINGS_ROOT + "spark_relay.glb",
		# 终点用彩色正面/据点抠图；结算剪影另见 relay_settlement_silhouette（地平线对齐）
		"finish_silhouette": "res://assets/maps/route_levels/runner_60s/settlement/spark_relay_cutout.png",
		"settlement_silhouette": "res://assets/maps/route_levels/runner_60s/settlement/relay_settlement_silhouette.png",
	},
	"gate": {
		"preview_2d": MAPS_2D_ROOT + "防御哨站2d.webp",
		"model_3d": BUILDINGS_ROOT + "defense_post.glb",
		"finish_silhouette": "res://assets/maps/route_levels/runner_60s/settlement/defense_settlement_silhouette.png",
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
	"jump": "跳跃障碍",
	"slide": "滑铲障碍",
	"wave_arc_slide": "光波弧形桥",
	"energy_ring": "气体能量光圈",
	"orb": "漂浮能量球",
	"meteorite": "占道陨石",
	"high_bar": "滑铲障碍",
}


static func _rotated_prop_pool(pool: Array, seed_key: String, count: int = 3) -> Array:
	var n := pool.size()
	if n == 0:
		return []
	var take := clampi(count, 1, n)
	var start := absi(seed_key.hash()) % n
	var out: Array = []
	for i in take:
		out.append(pool[(start + i) % n])
	return out


static func _visual_kit_for_location(location_id: String) -> Dictionary:
	match location_id:
		"reservoir":
			return RESERVOIR_VISUAL_KIT
		"dome":
			return EARLY_VISUAL_KIT
		"medical", "gate":
			return CRISIS_VISUAL_KIT
		_:
			return {}


static func apply_visual_kit(mission: Dictionary) -> Dictionary:
	if mission.is_empty():
		return mission
	var loc := String(mission.get("location_id", ""))
	if loc == "relay":
		return mission
	var kit := _visual_kit_for_location(loc)
	if kit.is_empty():
		return mission
	var out: Dictionary = mission.duplicate(true)
	var mission_id := String(out.get("mission_id", loc))
	var mid_pool: Array = kit.get("midground_props", [])
	var rotated: Array = _rotated_prop_pool(mid_pool, mission_id, mini(mid_pool.size(), 6))
	var mission_mid: Variant = out.get("midground_props", [])
	var lock_mid := mission_id in [
		"mission_medical_m1", "mission_medical_m2", "mission_medical_m4",
		"mission_gate_d1", "mission_gate_d2", "mission_gate_d3", "mission_gate_d4",
	]
	if lock_mid and mission_mid is Array and not (mission_mid as Array).is_empty():
		out["midground_props"] = (mission_mid as Array).duplicate()
	else:
		if mission_mid is Array:
			for path in mission_mid:
				var p := String(path)
				if p != "" and p not in rotated:
					rotated.append(p)
		out["midground_props"] = rotated.slice(0, mini(rotated.size(), 6))
	if kit.has("near_runway_props"):
		var existing_near: Variant = out.get("near_runway_props", null)
		if not (existing_near is Array and not (existing_near as Array).is_empty()):
			out["near_runway_props"] = _rotated_prop_pool(
				kit["near_runway_props"],
				mission_id + "_near",
				4
			)
	for key in ["jump_obstacles", "slide_obstacles", "distant_tower_props", "distant_spaceship_props", "distant_accent_props", "distant_hearth_props"]:
		if not kit.has(key):
			continue
		var existing: Variant = out.get(key, null)
		if existing is Array and not (existing as Array).is_empty():
			continue
		out[key] = (kit[key] as Array).duplicate()
	if loc == "reservoir":
		out["slide_obstacles"] = [MVP2_OBS + "废旧广告牌（滑铲）.glb"]
		if not out.has("environment_pack_v2_mix"):
			out["environment_pack_v2_mix"] = 0.0
	if loc == "gate":
		# 星火环会套在跑道上，近景改走路边通道，不再混入环状模型
		out["environment_pack_v2_mix"] = 0.0
	return out


static func apply_runner_background(mission: Dictionary) -> Dictionary:
	if mission.is_empty():
		return mission
	var out: Dictionary = mission.duplicate(true)
	var mission_id := String(out.get("mission_id", ""))
	var yaw := float(RUNNER_SKY_YAW.get(mission_id, 0.0))
	var pitch := float(RUNNER_SKY_PITCH.get(mission_id, 0.0))
	if mission_id.begins_with("mission_relay"):
		if String(out.get("ground_texture", "")).strip_edges() == "":
			out["ground_texture"] = RUNNER_GROUND_TEXTURE
		out["textured_ground"] = true
		if String(out.get("panorama", "")).strip_edges() == "":
			match mission_id:
				"mission_relay_e2":
					out["panorama"] = RELAY_E2_SKY_PANORAMA
				"mission_relay_e3":
					out["panorama"] = RELAY_E3_SKY_PANORAMA
				"mission_relay_e4":
					out["panorama"] = RELAY_E4_SKY_PANORAMA
				_:
					out["panorama"] = RELAY_E1_SKY_PANORAMA
		var relay_scene = out.get("visual_scene", {})
		if typeof(relay_scene) != TYPE_DICTIONARY:
			relay_scene = {}
		var merged_scene: Dictionary = RELAY_VISUAL_SCENE.duplicate(true)
		for key in relay_scene:
			merged_scene[key] = relay_scene[key]
		out["visual_scene"] = merged_scene
	elif mission_id.begins_with("mission_medical"):
		if String(out.get("panorama", "")).strip_edges() == "":
			out["panorama"] = MEDICAL_SKY_PANORAMA
	elif String(out.get("panorama", "")).strip_edges() == "":
		out["panorama"] = RUNNER_SKY_PANORAMA
	if not mission_id.begins_with("mission_relay") and String(out.get("ground_texture", "")).strip_edges() == "":
		out["ground_texture"] = RUNNER_GROUND_TEXTURE
	if not bool(out.get("textured_ground", false)):
		out["textured_ground"] = true
	var accents: Dictionary = RUNNER_SKY_ACCENTS.duplicate(true)
	var existing_accents = out.get("sky_accents", {})
	if typeof(existing_accents) == TYPE_DICTIONARY:
		for key in existing_accents:
			accents[key] = existing_accents[key]
	out["sky_accents"] = accents
	var env: Dictionary = RUNNER_ENVIRONMENT_BASE.duplicate(true)
	if mission_id == "mission_reservoir_01":
		env = RESERVOIR_W1_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_reservoir_02":
		env = RESERVOIR_W2_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_reservoir_03":
		env = RESERVOIR_W3_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_reservoir_04":
		env = RESERVOIR_W4_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_medical_m1":
		env = MEDICAL_M1_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_medical_m2":
		env = MEDICAL_M2_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_medical_m3":
		env = MEDICAL_M3_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_medical_m4":
		env = MEDICAL_M4_ENVIRONMENT.duplicate(true)
	elif mission_id in ["mission_relay_e1", "mission_relay_01"]:
		env = RELAY_E1_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_relay_e2":
		env = RELAY_E2_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_relay_e3":
		env = RELAY_E3_ENVIRONMENT.duplicate(true)
	elif mission_id == "mission_relay_e4":
		env = RELAY_E4_ENVIRONMENT.duplicate(true)
	var existing = out.get("environment", {})
	if typeof(existing) == TYPE_DICTIONARY:
		for key in existing:
			env[key] = existing[key]
	if absf(yaw) > 0.001:
		env["sky_rotation_y"] = yaw
	if absf(pitch) > 0.001 or mission_id in ["mission_reservoir_03", "mission_reservoir_04"] or mission_id.begins_with("mission_relay"):
		env["sky_rotation_x"] = pitch
	out["environment"] = _sanitize_runner_environment(env, mission_id)
	return apply_visual_kit(out)


static func _sanitize_runner_environment(env: Dictionary, mission_id: String = "") -> Dictionary:
	var out: Dictionary = env.duplicate(true)
	if mission_id.begins_with("mission_relay"):
		# 对齐水源一：薄雾上限，避免 aerial fog 把角色/建筑染成天空色
		out["fog_aerial_perspective"] = minf(float(out.get("fog_aerial_perspective", 0.045)), 0.06)
		out["fog_density"] = minf(float(out.get("fog_density", 0.00028)), 0.00036)
		return out
	if mission_id.begins_with("mission_medical"):
		# 跟水源第一关同一套薄雾上限，保住全景里的云层明暗
		out["fog_aerial_perspective"] = minf(float(out.get("fog_aerial_perspective", 0.06)), 0.08)
		out["fog_density"] = minf(float(out.get("fog_density", 0.00034)), 0.00042)
		return out
	if mission_id == "mission_dome_h1":
		# 居民穹顶 H1：允许略深雾与透视，营造近暖远紫的废墟长桥
		out["fog_aerial_perspective"] = clampf(float(out.get("fog_aerial_perspective", 0.12)), 0.08, 0.16)
		out["fog_density"] = clampf(float(out.get("fog_density", 0.00065)), 0.00048, 0.00082)
		return out
	if mission_id == "mission_reservoir_01":
		# 水源第一关：湖泊夕照，保留琥珀雾，不掺紫
		out["fog_aerial_perspective"] = minf(float(out.get("fog_aerial_perspective", 0.06)), 0.08)
		out["fog_density"] = minf(float(out.get("fog_density", 0.00034)), 0.00042)
		return out
	if mission_id == "mission_reservoir_02":
		# 水源第二关：薄雾保住第一关云层，不要洗成一片紫
		out["fog_aerial_perspective"] = minf(float(out.get("fog_aerial_perspective", 0.040)), 0.055)
		out["fog_density"] = minf(float(out.get("fog_density", 0.00026)), 0.00034)
		return out
	if mission_id in ["mission_reservoir_03", "mission_reservoir_04"]:
		# 跟第一关同一套琥珀薄雾，灰紫雾会把云和高楼剪影洗掉
		out["fog_aerial_perspective"] = minf(float(out.get("fog_aerial_perspective", 0.06)), 0.08)
		out["fog_density"] = minf(float(out.get("fog_density", 0.00034)), 0.00042)
		return out
	if mission_id.begins_with("mission_reservoir"):
		# 后续关允许粉紫/明暗变化，不要洗回橙黄或统一紫灰
		out["fog_aerial_perspective"] = clampf(float(out.get("fog_aerial_perspective", 0.10)), 0.06, 0.16)
		out["fog_density"] = clampf(float(out.get("fog_density", 0.00042)), 0.00028, 0.00070)
		return out
	# 远景透视过高会把天空洗成纯色雾带
	out["fog_aerial_perspective"] = minf(float(out.get("fog_aerial_perspective", 0.07)), 0.09)
	out["fog_density"] = minf(float(out.get("fog_density", 0.00038)), 0.00055)
	var fog: Color = out.get("fog_color", RUNNER_ENVIRONMENT_BASE["fog_color"])
	var base_fog: Color = RUNNER_ENVIRONMENT_BASE["fog_color"]
	# 过暖雾色保留关卡性格，但掺入紫灰基线，避免整屏一片黄
	if fog.r - fog.b > 0.22 and fog.g > 0.36:
		out["fog_color"] = base_fog.lerp(fog, 0.58)
	var amb: Color = out.get("ambient", RUNNER_ENVIRONMENT_BASE["ambient"])
	var base_amb: Color = RUNNER_ENVIRONMENT_BASE["ambient"]
	if amb.r - amb.b > 0.28 and amb.g > 0.52:
		out["ambient"] = base_amb.lerp(amb, 0.62)
	return out


static func get_planet_id() -> String:
	return PLANET_ID


static func get_theme() -> Dictionary:
	return THEME


static func get_assets() -> Dictionary:
	return ASSETS


static func get_track_segments() -> Array:
	return TRACK_SEGMENTS.duplicate(true)


static func get_mission_by_id(mission_id: String) -> Dictionary:
	if mission_id == "":
		return {}
	if mission_id == "mission_relay_01":
		mission_id = "mission_relay_e1"
	for item in LOCATION_MISSIONS:
		if String(item.get("mission_id", "")) == mission_id:
			return apply_runner_background(MissionTypes.enrich_mission(item))
		if mission_id == String(item.get("location_id", "")) and not String(item.get("mission_id", "")):
			return apply_runner_background(MissionTypes.enrich_mission(item))
	return {}


static func get_missions_for_location(location_id: String) -> Array:
	var out: Array = []
	for item in LOCATION_MISSIONS:
		if String(item.get("location_id", "")) == location_id:
			out.append(apply_runner_background(MissionTypes.enrich_mission(item)))
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 0)) < int(b.get("order", 0))
	)
	return out


static func get_location_missions() -> Array:
	var out: Array = []
	for item in LOCATION_MISSIONS:
		out.append(apply_runner_background(MissionTypes.enrich_mission(item)))
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("order", 0)) < int(b.get("order", 0))
	)
	return out


static func get_mission_for_location(location_id: String) -> Dictionary:
	var matches := get_missions_for_location(location_id)
	if matches.is_empty():
		return MissionTypes.enrich_mission(MISSION)
	return matches[0]


static func get_tasks_missions() -> Array:
	return get_location_missions()


static func get_mission_batches() -> Array:
	return MISSION_BATCHES.duplicate(true)


static func get_jump_obstacle_label(asset_path: String) -> String:
	if "energy_orb" in asset_path:
		return "漂浮能量球"
	if "带刺" in asset_path:
		return "带刺障碍"
	if "荆棘" in asset_path:
		return "荆棘丛"
	if asset_path == "wood_fence_jump" or "wood_fence" in asset_path:
		return "木栅栏"
	return OBSTACLE_TYPES.get("jump", "跳跃障碍")


static func build_obstacles() -> Array:
	return _filter_obstacles_away_from_side_walls(_default_obstacles())


static func _default_obstacles() -> Array:
	var out: Array = []
	var d := 80.0
	var pattern_i := 0
	while d < 1180.0:
		if _obstacle_in_side_wall_corridor(d):
			d += 18.0
			continue
		match pattern_i % 4:
			0:
				out.append({"lane": 0, "distance": d, "type": "jump"})
				out.append({"lane": -1, "distance": d + 16.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": 1, "distance": d + 24.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": 0, "distance": d + 34.0, "type": "orb", "orb_size": "large"})
			1:
				out.append({"lane": 0, "distance": d, "type": "slide"})
				out.append({"lane": 1, "distance": d + 18.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": -1, "distance": d + 26.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": 0, "distance": d + 36.0, "type": "orb", "orb_size": "large"})
			2:
				out.append({"lane": -1, "distance": d, "type": "jump"})
				out.append({"lane": 0, "distance": d + 14.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": 1, "distance": d + 22.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": -1, "distance": d + 30.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": 1, "distance": d + 38.0, "type": "orb", "orb_size": "large"})
			3:
				out.append({"lane": 1, "distance": d, "type": "slide"})
				out.append({"lane": -1, "distance": d + 16.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": 0, "distance": d + 24.0, "type": "orb", "orb_size": "small"})
				out.append({"lane": 1, "distance": d + 32.0, "type": "orb", "orb_size": "large"})
		d += 58.0
		pattern_i += 1
	return out


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
		# 主路以地面 S 形 / 之字为主；每隔一段补少量低空金币（跳跃可及）
		var kind := pattern_i % 3
		if kind == 0:
			_append_coin_pattern(coins, cursor, 0, "s_curve", 8, 4.2)
			_append_coin_pattern(coins, cursor + 4.0, 0, "air_stream", 3, 2.8, 0)
			cursor += 8.0 * 4.2 + 16.0
		elif kind == 1:
			_append_coin_pattern(coins, cursor, 0, "zigzag", 7, 4.8)
			_append_coin_pattern(coins, cursor + 3.5, 0, "air_stream", 2, 3.0, 1)
			cursor += 7.0 * 4.8 + 18.0
		else:
			_append_coin_pattern(coins, cursor, 0, "scatter", 6, 4.5)
			cursor += 6.0 * 4.5 + 18.0
		pattern_i += 1
	return coins


static func _air_lane_apart_from(ground_lane: int) -> int:
	match ground_lane:
		-1:
			return 1
		1:
			return -1
		_:
			return 1


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
	var scatter_lanes: Array[int] = [-1, 0, 1, 0, -1, 1, 0, -1, 0, 1]
	for i in count:
		var dist := start + float(i) * step
		match pattern:
			"row":
				for lane in [-1, 0, 1]:
					out.append({"distance": dist, "lane": lane, "layer": layer, "pattern": pattern, "air": false})
			"scatter":
				var sc_lane: int = scatter_lanes[i % scatter_lanes.size()]
				out.append({"distance": dist, "lane": sc_lane, "layer": layer, "pattern": pattern, "air": false})
			"zigzag":
				var z_lane := -1 if i % 2 == 0 else 1
				out.append({"distance": dist, "lane": z_lane, "layer": layer, "pattern": pattern, "air": false})
			"s_curve", "s":
				var s_lane: int = s_seq[i % s_seq.size()]
				out.append({"distance": dist, "lane": s_lane, "layer": layer, "pattern": pattern, "air": false})
			"column", "stream":
				out.append({"distance": dist, "lane": lane_hint, "layer": layer, "pattern": "column", "air": false})
			"air_stream":
				out.append({"distance": dist, "lane": lane_hint, "layer": layer, "pattern": pattern, "air": true})
			"cluster":
				out.append({"distance": dist, "lane": lane_hint, "layer": layer, "pattern": "cluster", "air": false})
			"multi_column":
				for lane in [-1, 0, 1]:
					out.append({"distance": dist, "lane": lane, "layer": layer, "pattern": "multi_column", "air": false})
			"gap_center":
				out.append({"distance": dist, "lane": -1, "layer": layer, "pattern": pattern, "air": false})
				out.append({"distance": dist, "lane": 1, "layer": layer, "pattern": pattern, "air": false})
			_:
				out.append({"distance": dist, "lane": lane_hint, "layer": layer, "pattern": pattern, "air": false})


static func build_side_runway_coins() -> Array:
	# 侧墙段金币：与 JSON side_runway_zones 对齐（W2 约 248–330）
	var coins: Array = []
	_append_coin_pattern(coins, 252.0, 1, "column", 10, 1.6, 0)
	_append_coin_pattern(coins, 258.0, 1, "s_curve", 8, 2.8)
	_append_coin_pattern(coins, 270.0, 1, "multi_column", 6, 2.2)
	_append_coin_pattern(coins, 284.0, 1, "cluster", 8, 1.8, 0)
	_append_coin_pattern(coins, 296.0, 1, "column", 10, 1.5, 1)
	_append_coin_pattern(coins, 308.0, 1, "zigzag", 8, 2.0)
	_append_coin_pattern(coins, 318.0, 1, "cluster", 7, 1.7, -1)
	# W3 等后续侧墙段（无 zone 的关卡会被 runner 过滤掉）
	_append_coin_pattern(coins, 552.0, 1, "zigzag", 6, 4.0)
	_append_coin_pattern(coins, 580.0, 1, "cluster", 5, 2.5, -1)
	return coins


static func build_shield_crystals() -> Array:
	# 热浪前给水晶，最后一片热浪结束后不再刷
	var crystals: Array = []
	var n := SANDSTORM_ZONES.size()
	if n == 0:
		return crystals
	var first := float(SANDSTORM_ZONES[0].get("start", 0.0))
	crystals.append({"lane": 0, "distance": minf(75.0, first - 48.0), "layer": 0})
	crystals.append({"lane": 0, "distance": minf(108.0, first - 28.0), "layer": 0})
	for i in n:
		var zone: Dictionary = SANDSTORM_ZONES[i]
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		crystals.append({"lane": 0, "distance": start - 18.0, "layer": 0})
		if length >= 36.0:
			crystals.append({"lane": 0, "distance": start + length * 0.40, "layer": 0})
		if i < n - 1:
			crystals.append({"lane": 0, "distance": start + length + 12.0, "layer": 0})
	return crystals


static func phase_at(distance: float) -> Dictionary:
	for phase in RUN_PHASES:
		if distance >= float(phase["start"]) and distance < float(phase["end"]):
			return phase
	return RUN_PHASES[RUN_PHASES.size() - 1]


static func integrity_grade(integrity: float) -> String:
	# 仅用于结算奖励/进度区间换算；跑酷失败不走此函数（须完整度真实为 0）
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


static func get_explore_map_path(_locale: String = "en") -> String:
	return String(MVP_MAPS.get("explore_en" if _locale == "en" else "explore_zh", MVP_MAPS["explore_en"]))


static func get_home_map_preview_path(_locale: String = "en") -> String:
	return String(MVP_MAPS.get("preview_en" if _locale == "en" else "preview_zh", MVP_MAPS["preview_en"]))


static func get_location_preview_path(location_id: String) -> String:
	var entry: Dictionary = MVP_LOCATIONS.get(location_id, {})
	return String(entry.get("preview_2d", ""))


static func get_location_hearth_model(location_id: String) -> String:
	var entry: Dictionary = MVP_LOCATIONS.get(location_id, {})
	var model_path := String(entry.get("model_3d", ""))
	if model_path != "":
		return model_path
	return String(ASSETS.get("hearth", ""))


static func get_location_finish_silhouette(location_id: String) -> String:
	var entry: Dictionary = MVP_LOCATIONS.get(location_id, {})
	var silhouette := String(entry.get("finish_silhouette", "")).strip_edges()
	if silhouette != "" and _finish_silhouette_resource_exists(silhouette):
		return silhouette
	return ""


static func get_location_settlement_silhouette(location_id: String) -> String:
	var entry: Dictionary = MVP_LOCATIONS.get(location_id, {})
	var silhouette := String(entry.get("settlement_silhouette", "")).strip_edges()
	if silhouette == "":
		silhouette = String(entry.get("finish_silhouette", "")).strip_edges()
	if silhouette != "" and _finish_silhouette_resource_exists(silhouette):
		return silhouette
	return ""


static func _finish_silhouette_resource_exists(path: String) -> bool:
	if path.strip_edges() == "":
		return false
	if FileAccess.file_exists(path) or FileAccess.file_exists(ProjectSettings.globalize_path(path)):
		return true
	if not ResourceLoader.exists(path):
		return false
	return ResourceLoader.load(path) is Texture2D


static func get_cargo_icon_path(mission: Dictionary) -> String:
	var icon_key := String(mission.get("cargo_icon", ""))
	if icon_key != "" and CARGO_UI_ICON_FILES.has(icon_key):
		var ui_path := CARGO_UI_ICON_ROOT + String(CARGO_UI_ICON_FILES[icon_key])
		if ResourceLoader.exists(ui_path):
			return ui_path
	var cargo_en := String(mission.get("cargo_name_en", "")).strip_edges().to_lower()
	if cargo_en != "" and CARGO_UI_ICON_BY_EN.has(cargo_en):
		var ui_path_en := CARGO_UI_ICON_ROOT + String(CARGO_UI_ICON_BY_EN[cargo_en])
		if ResourceLoader.exists(ui_path_en):
			return ui_path_en
	if icon_key == "":
		return ""
	if ResourceLoader.exists(MVP2_CARGO_ROOT + icon_key + ".webp"):
		return MVP2_CARGO_ROOT + icon_key + ".webp"
	return ""


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


static func is_early_outpost_location(location_id: String) -> bool:
	return String(location_id) in ["dome", "reservoir"]


static func get_mission_batch_id(location_id: String) -> int:
	for batch in MISSION_BATCHES:
		for loc in batch.get("locations", []):
			if String(loc) == String(location_id):
				return int(batch.get("id", 0))
	return 0


static func resolve_obstacle_layout_id(layout_id: String) -> String:
	return ObstacleLayout.resolve_file_id(layout_id)


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
			return Color(0.28, 0.68, 0.96)
		_:
			return Color(0.35, 0.50, 0.68)


static func _detail_bilingual(en: String, _zh: String = "") -> String:
	return en


static func _need_name_en(cargo_icon: String, fallback: String = "") -> String:
	match cargo_icon:
		"净水":
			return "Water Packs"
		"能源包":
			return "Energy Packs"
		"建设":
			return "Construction Kits"
		"医疗":
			return "Medical Packs"
		"防御":
			return "Defense Packs"
		"星火核心":
			return "Ember Cores"
		_:
			return fallback if fallback != "" else "Supplies"


static func _detail_copy_en(location_id: String) -> Dictionary:
	match location_id:
		"reservoir":
			return {
				"type_en": "Water Station",
				"tagline_en": "One of the last water facilities in the wasteland.",
				"goal_en": "Restore purification so life can flow again.",
				"manager_title_en": "Water Systems Engineer",
				"manager_quote_en": "As long as water keeps moving, the wasteland still has tomorrow.",
			}
		"dome":
			return {
				"type_en": "Habitat Dome",
				"tagline_en": "The largest survivor settlement in the wasteland.",
				"goal_en": "Repair the dome and rebuild humanity's last home.",
				"manager_title_en": "Settlement Lead",
				"manager_quote_en": "This is our last home — and where rebuilding begins.",
			}
		"medical":
			return {
				"type_en": "Medical Station",
				"tagline_en": "A base preserving pre-Zero Tide medical tech.",
				"goal_en": "Restore equipment and care for survivors.",
				"manager_title_en": "Medical Director",
				"manager_quote_en": "Every dose is one more person pulled back toward dawn.",
			}
		"gate":
			return {
				"type_en": "Defense Outpost",
				"tagline_en": "The line that guards the wasteland border.",
				"goal_en": "Reboot defenses against unknown threats.",
				"manager_title_en": "Defense Commander",
				"manager_quote_en": "While the line holds, home cannot fall.",
			}
		"relay":
			return {
				"type_en": "Ember Relay Station",
				"tagline_en": "The comms core linking every region.",
				"goal_en": "Restore signal so hope can travel again.",
				"manager_title_en": "Relay Signal Officer",
				"manager_quote_en": "When the signal arrives, hope stays lit.",
			}
		_:
			return {}


static func build_detail_payload(location_id: String, revealed: bool, completed: bool, preview: bool = false) -> Dictionary:
	var outpost := get_outpost_meta(location_id)
	if outpost.is_empty():
		return {}
	var show_missions := revealed or preview
	var mission: Dictionary = get_mission_for_location(location_id) if show_missions else {}
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
			var cargo_icon := String(item["cargo_icon"])
			item["icon_path"] = get_cargo_icon_path({"cargo_icon": cargo_icon})
			item["name"] = _need_name_en(cargo_icon, String(item.get("name", "")))
		needs.append(item)
	var transport_missions: Array = []
	if show_missions:
		var mission_index := 1
		for raw_mission in get_missions_for_location(location_id):
			if typeof(raw_mission) != TYPE_DICTIONARY:
				continue
			# 与 Tasks 页同一套任务字典，供列表与 TaskDetailSheet 共用
			var loc_mission: Dictionary = (raw_mission as Dictionary).duplicate(true)
			if String(loc_mission.get("mission_id", "")) == "":
				loc_mission["mission_id"] = Global.mission_key(loc_mission)
			loc_mission["index"] = "%02d" % mission_index
			transport_missions.append(loc_mission)
			mission_index += 1
	var copy_en := _detail_copy_en(location_id)
	var status_text := ""
	if completed:
		status_text = "Status: Lit"
	elif revealed:
		status_text = "Status: Transport Repair"
	elif preview:
		status_text = "Status: Preview · Batch 3 locked"
	else:
		status_text = "Status: Locked"
	var locked_hint := ""
	if not revealed and not preview:
		locked_hint = "\nMain Rewards: Runner ??? · Ember Coins ???"
	elif preview and not revealed:
		locked_hint = "\nPreview only · missions not on dispatch board yet"
	var meta_state := ""
	if completed:
		meta_state = "Lit"
	elif revealed:
		meta_state = "Under Repair"
	elif preview:
		meta_state = "Preview"
	else:
		meta_state = "Locked"
	var type_en := String(copy_en.get("type_en", String(outpost.get("name_en", "Outpost"))))
	var tagline_en := String(copy_en.get("tagline_en", ""))
	var goal_en := String(copy_en.get("goal_en", ""))
	var show_manager: bool = revealed or completed or Global.is_dev_full_unlock()
	var manager_payload := {
		"name": "???",
		"title": "Unknown",
		"quote": "Confirm the manager after lighting up this outpost.",
		"portrait_path": "",
		"show_identity": false,
	}
	if show_manager:
		var title_en := String(outpost.get("manager_title_en", copy_en.get("manager_title_en", "")))
		var quote_en := String(outpost.get("manager_quote_en", copy_en.get("manager_quote_en", "")))
		manager_payload = {
			"name": String(outpost.get("manager_name", "")),
			"title": title_en,
			"quote": quote_en,
			"portrait_path": String(outpost.get("manager_portrait", "")),
			"show_identity": true,
		}
	return {
		"location_id": location_id,
		"planet_id": PLANET_ID,
		"title": String(outpost.get("name_en", "Outpost")),
		"title_en": String(outpost.get("name_en", "")),
		"status": status_text,
		"tagline": tagline_en,
		"goal": goal_en,
		"description": "%s\n%s" % [tagline_en, goal_en],
		"meta": "%s · %s" % [type_en, meta_state],
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
		"manager": manager_payload,
		"rewards": {
			"coins": int(outpost.get("reward_coins", 0)),
			"unlock_character": String(outpost.get("unlock_character", "")),
		},
		"cargo_icon_path": get_cargo_icon_path(mission) if not mission.is_empty() else "",
		"revealed": revealed or preview,
		"preview": preview,
		"completed": completed,
		"locked_hint": locked_hint,
	}
