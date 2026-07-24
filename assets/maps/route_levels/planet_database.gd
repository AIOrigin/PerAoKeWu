class_name PlanetDatabase
extends RefCounted

const GlassDesert = preload("res://assets/maps/route_levels/planets/planet_glass_desert.gd")
const RustBelt = preload("res://assets/maps/route_levels/planets/planet_rust_belt.gd")
const SavannaRing = preload("res://assets/maps/route_levels/planets/planet_savanna_ring.gd")

const RUNNER_SCENE := "res://assets/maps/route_levels/runner_60s/route_runner_60s.tscn"
const GALAXY_MAP_SCENE := "res://assets/maps/route_levels/galaxy_map/galaxy_map.tscn"
const EXPLORATION_SCENE := "res://assets/maps/route_levels/planet_explore/planet_explore.tscn"
const MOBILE_HOME_SCENE := "res://assets/maps/route_levels/mobile_home/mobile_home.tscn"

const PLANET_DIR := "res://3d素材/行星/"
const PLANET_MODEL_CRYSTAL := PLANET_DIR + "带纹理的行星3d模型.glb"
const PLANET_MODEL_3D := PLANET_DIR + "三维星球模型.glb"
const PLANET_MODEL_BLUE := PLANET_DIR + "蓝色星球3d模型.glb"
const PLANET_MODEL_GENERIC := PLANET_DIR + "行星+3d+模型.glb"
const PLANET_VISUAL_SIZE := 1.85
const STAR_DIR := "res://3d素材/恒星/"
const STAR_MODEL := STAR_DIR + "太阳型星体3d模型.glb"
const STAR_VISUAL_SIZE := 2.35
const DEFAULT_SHIP_MODEL := "res://3d素材/fighter+spaceship+3d+model.glb"
const SHIP_VISUAL_SIZE := 1.55

const GAME_MODES := {
	"explore": {
		"name": "探索模式",
		"description": "降落到星球表面，自由观察地貌、据点和飞船。",
	},
	"runner": {
		"name": "跑酷模式",
		"description": "进入 60 秒送货跑酷，保护货物并冲向目标据点。",
	},
}

const SHIPS := [
	{
		"id": "spark_moth",
		"name": "星火蛾",
		"role": "轻型信使船",
		"path": DEFAULT_SHIP_MODEL,
		"color": Color(0.35, 0.72, 1.0),
		"preview_yaw": 0.0,
		"visual_size": 1.35,
	},
	{
		"id": "aurora_sloop",
		"name": "极光单桅",
		"role": "均衡远航船",
		"path": DEFAULT_SHIP_MODEL,
		"color": Color(0.72, 0.95, 0.82),
		"preview_yaw": 0.0,
		"visual_size": 1.55,
	},
	{
		"id": "relay_cutter",
		"name": "中继快刀",
		"role": "高速穿梭船",
		"path": DEFAULT_SHIP_MODEL,
		"color": Color(1.0, 0.68, 0.28),
		"preview_yaw": 0.0,
		"visual_size": 1.42,
	},
	{
		"id": "night_comet",
		"name": "夜彗",
		"role": "重装护航船",
		"path": DEFAULT_SHIP_MODEL,
		"color": Color(0.75, 0.55, 1.0),
		"preview_yaw": 0.0,
		"visual_size": 1.72,
	},
]

const CONFIG_BY_ID := {
	"glass_desert": GlassDesert,
	"rust_belt": RustBelt,
	"savanna_ring": SavannaRing,
}

## 星系选关 UI 数据（马里奥银河式）
const STAR_SYSTEMS := [
	{
		"id": "ember_route",
		"name": "火种航线",
		"subtitle": "Elsa 主送货通道 · 晶砂与据点",
		"camera_focus": Vector3(0.0, 1.8, 0.0),
		"camera_distance": 16.5,
		"star_color": Color(1.0, 0.72, 0.28),
		"star_emission": Color(1.0, 0.55, 0.12),
		"planets": [
			{
				"id": "glass_desert",
				"model": PLANET_MODEL_3D,
				"unlocked": true,
				"orbit_radius": 5.8,
				"orbit_speed": 0.16,
				"orbit_tilt_deg": 14.0,
				"orbit_phase": 0.0,
				"size": 0.92,
				"color": Color(0.45, 0.82, 1.0),
				"emission": Color(0.25, 0.72, 1.0),
				"ring_color": Color(0.55, 0.95, 1.0, 0.55),
			},
		],
	},
	{
		"id": "outer_scrap",
		"name": "外环废土",
		"subtitle": "军车、锈网与泵站",
		"camera_focus": Vector3(0.0, 1.5, 0.0),
		"camera_distance": 18.0,
		"star_color": Color(1.0, 0.55, 0.22),
		"star_emission": Color(0.95, 0.35, 0.08),
		"planets": [
			{
				"id": "rust_belt",
				"model": PLANET_MODEL_3D,
				"unlocked": true,
				"orbit_radius": 4.6,
				"orbit_speed": 0.22,
				"orbit_tilt_deg": -18.0,
				"orbit_phase": 0.8,
				"size": 0.78,
				"color": Color(0.72, 0.42, 0.22),
				"emission": Color(0.95, 0.45, 0.12),
				"ring_color": Color(1.0, 0.62, 0.18, 0.45),
			},
			{
				"id": "savanna_ring",
				"model": PLANET_MODEL_GENERIC,
				"unlocked": false,
				"orbit_radius": 7.4,
				"orbit_speed": 0.12,
				"orbit_tilt_deg": 24.0,
				"orbit_phase": 2.4,
				"size": 0.86,
				"color": Color(0.48, 0.72, 0.32),
				"emission": Color(0.62, 0.92, 0.35),
				"ring_color": Color(0.75, 1.0, 0.45, 0.35),
			},
		],
	},
	{
		"id": "relay_cluster",
		"name": "中继星群",
		"subtitle": "轨道枢纽 · 即将开放",
		"camera_focus": Vector3(0.0, 2.0, 0.0),
		"camera_distance": 17.0,
		"star_color": Color(0.72, 0.82, 1.0),
		"star_emission": Color(0.45, 0.62, 1.0),
		"planets": [
			{
				"id": "orbital_dock",
				"model": PLANET_MODEL_BLUE,
				"unlocked": false,
				"display_only": true,
				"name_override": "轨道中继站",
				"name_en_override": "Orbital Dock",
				"description_override": "深空货运枢纽，连接多条星火航线。该星域仍在建设，暂不可进入。",
				"orbit_radius": 5.2,
				"orbit_speed": 0.1,
				"orbit_tilt_deg": 8.0,
				"orbit_phase": 1.2,
				"size": 0.7,
				"color": Color(0.55, 0.62, 0.82),
				"emission": Color(0.35, 0.55, 1.0),
				"ring_color": Color(0.65, 0.78, 1.0, 0.35),
			},
		],
	},
]


static func get_runner_config(planet_id: String) -> Script:
	return CONFIG_BY_ID.get(planet_id, GlassDesert)


static func get_ship(ship_id: String) -> Dictionary:
	for ship in SHIPS:
		if String(ship["id"]) == ship_id:
			return ship
	return SHIPS[0]


static func get_planet_model_path(planet_entry: Dictionary) -> String:
	return String(planet_entry.get("model", PLANET_MODEL_CRYSTAL))


static func get_planet_meta(planet_id: String) -> Dictionary:
	for system in STAR_SYSTEMS:
		for planet in system["planets"]:
			if String(planet["id"]) == planet_id:
				return _build_planet_card(planet, system)
	return _build_planet_card(STAR_SYSTEMS[0]["planets"][0], STAR_SYSTEMS[0])


static func _build_planet_card(planet_entry: Dictionary, system: Dictionary) -> Dictionary:
	var planet_id := String(planet_entry["id"])
	if planet_entry.get("display_only", false):
		return {
			"id": planet_id,
			"system_id": String(system["id"]),
			"system_name": String(system["name"]),
			"name": String(planet_entry.get("name_override", planet_id)),
			"name_en": String(planet_entry.get("name_en_override", "")),
			"description": String(planet_entry.get("description_override", "")),
			"unlocked": false,
			"display_only": true,
			"difficulty": 0,
			"cargo": "—",
			"hearth": "—",
			"chaser": "—",
		}

	var cfg: Script = get_runner_config(planet_id)
	return {
		"id": planet_id,
		"system_id": String(system["id"]),
		"system_name": String(system["name"]),
		"name": cfg.MAP_NAME,
		"name_en": cfg.MAP_NAME_EN,
		"description": _planet_description(planet_id),
		"unlocked": bool(planet_entry.get("unlocked", false)),
		"display_only": false,
		"difficulty": _planet_difficulty(planet_id),
		"cargo": String(cfg.MISSION.get("cargo_name", "")),
		"hearth": String(cfg.MISSION.get("target_hearth", "")),
		"chaser": cfg.CHASER_NAME,
		"task_type": String(cfg.MISSION.get("task_type", "")),
	}


static func _planet_description(planet_id: String) -> String:
	match planet_id:
		"glass_desert":
			return "玻璃晶砂覆盖的荒漠跑道，Elsa 需将净水模块送往地下水库据点。零潮在身后涌动，选择门决定修复还是速通。"
		"rust_belt":
			return "锈蚀工业废土与军车残骸横亘跑道。滤芯组运输路线危机四伏，锈潮猎犬会在失误后迅速逼近。"
		"savanna_ring":
			return "稀树草原环带上的开阔跑线，生物样本需在规定时间内送达观测站。兽迹与灌木构成天然障碍。"
		_:
			return "未知星域。"


static func _planet_difficulty(planet_id: String) -> int:
	match planet_id:
		"glass_desert":
			return 1
		"rust_belt":
			return 2
		"savanna_ring":
			return 2
		_:
			return 1
