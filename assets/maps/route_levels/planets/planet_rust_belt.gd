extends "res://assets/maps/route_levels/runner_planet_config.gd"

const GlassDesert = preload("res://assets/maps/route_levels/planets/planet_glass_desert.gd")

## 星球二 · 锈带荒原

const PLANET_ID := "rust_belt"

const GAME_TITLE := "星火信使：黎明线"
const MAP_NAME := "锈带荒原"
const MAP_NAME_EN := "Rust Belt Wastes"

const MISSION := {
	"runner_code": "Elsa",
	"cargo_name": "备用滤芯组",
	"cargo_load": 100,
	"target_hearth": "7号泵站",
	"task_type": "紧急维修",
}

const EMBER_COIN_VALUE := 18
const CARGO_DAMAGE_PER_HIT := 13.0
const CHASER_NAME := "锈潮猎犬"

const THEME := {
	"background": Color(0.08, 0.06, 0.05),
	"ambient": Color(0.72, 0.55, 0.42),
	"ambient_energy": 1.2,
	"fog_color": Color(0.55, 0.32, 0.18),
	"fog_density": 0.0028,
	"sun_color": Color(1.0, 0.62, 0.35),
	"sun_energy": 2.1,
	"road": Color(0.28, 0.26, 0.24),
	"shoulder": Color(0.42, 0.28, 0.16),
	"curb": Color(0.62, 0.38, 0.18),
	"lane_line": Color(0.95, 0.72, 0.28),
	"sand": Color(0.38, 0.24, 0.14),
	"crystal": Color(0.85, 0.42, 0.12),
	"surroundings": "industrial_ruin",
}

const ASSETS := {
	"panorama": "res://3d素材/三拼地图.png",
	"jump_obstacles": [
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_sprigs_2_5d.png",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_grumpy_2_5d.png",
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_angry_2_5d.png",
		"res://3d素材/障碍物-需跳跃.glb",
		"res://3d素材/障碍物-需跳跃2.glb",
	],
	"slide_obstacle": "res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_phase_curtain_2_5d.png",
	"slide_obstacles": [
		"res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_phase_curtain_2_5d.png",
		"res://3d素材/障碍物-需滑铲.glb",
	],
	"side_props": [
		"res://3d素材/障碍物-需跳跃.glb",
		"res://3d素材/障碍物-需跳跃2.glb",
		"res://3d素材/障碍物-需滑铲.glb",
	],
	"landmark_props": [
		"res://3d素材/居民穹顶据点 3d model.glb",
	],
	"hearth": "res://3d素材/居民穹顶据点 3d model.glb",
}

const RUN_PHASES := [
	{"name": "进站确认", "start": 0.0, "end": 50.0, "hint": "滤芯组 → 7号泵站"},
	{"name": "废土热身", "start": 50.0, "end": 320.0, "hint": "注意横杆与军车"},
	{"name": "岔路抉择", "start": 320.0, "end": 700.0, "hint": "维修通道 / 速运通道"},
	{"name": "锈潮紧逼", "start": 700.0, "end": 1020.0, "hint": "追击峰值 · 载具横冲"},
	{"name": "泵站冲刺", "start": 1020.0, "end": 99999.0, "hint": "冲入泵站闸门"},
]

const JUNCTION_ZONES := [
	{
		"distance": 360.0,
		"length": 72.0,
		"spread": 16.0,
		"lane_a": 0, "label_a": "维修岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "速运岔路", "effect_b": "fast",
	},
	{
		"distance": 580.0,
		"length": 72.0,
		"spread": 16.0,
		"lane_a": 0, "label_a": "加固岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "补给岔路", "effect_b": "bonus",
	},
	{
		"distance": 820.0,
		"length": 72.0,
		"spread": 16.0,
		"lane_a": 0, "label_a": "安全岔路", "effect_a": "repair",
		"lane_b": 2, "label_b": "速运岔路", "effect_b": "fast",
	},
]

const SIDE_RUNWAY_ZONES = GlassDesert.SIDE_RUNWAY_ZONES

const OBSTACLE_TYPES := {
	"jump": "废铁矮墙",
	"slide": "锈蚀横杆",
	"train": "废弃军车",
	"train_moving": "失控装甲车",
	"block_left": "左道封锁",
	"block_right": "右道封锁",
	"ramp": "钢架跳板",
	"main_block": "主路坍塌带",
	"turn_left": "维修门",
	"turn_right": "速运门",
}


static func get_planet_id() -> String:
	return PLANET_ID


static func get_theme() -> Dictionary:
	return THEME


static func get_assets() -> Dictionary:
	return ASSETS


static func get_player_assets(character_id: String = "elsa") -> Dictionary:
	return GlassDesert.get_player_assets(character_id)


static func get_track_segments() -> Array:
	return GlassDesert.get_track_segments()


static func get_mission_for_location(_location_id: String) -> Dictionary:
	return MISSION


static func get_location_missions() -> Array:
	return [MISSION.duplicate(true)]


static func build_obstacles() -> Array:
	return GlassDesert.build_obstacles()


static func build_coin_distances() -> Array:
	return GlassDesert.build_coin_distances()


static func build_main_runway_coins() -> Array:
	return GlassDesert.build_main_runway_coins()


static func build_side_runway_coins() -> Array:
	return GlassDesert.build_side_runway_coins()


static func phase_at(distance: float) -> Dictionary:
	for phase in RUN_PHASES:
		if distance >= float(phase["start"]) and distance < float(phase["end"]):
			return phase
	return RUN_PHASES[RUN_PHASES.size() - 1]


static func integrity_grade(integrity: float) -> String:
	return GlassDesert.integrity_grade(integrity)


static func integrity_grade_label(integrity: float) -> String:
	return GlassDesert.integrity_grade_label(integrity)


static func grade_coin_multiplier(grade: String) -> float:
	return GlassDesert.grade_coin_multiplier(grade)
