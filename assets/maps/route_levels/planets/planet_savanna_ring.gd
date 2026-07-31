extends "res://assets/maps/route_levels/runner_planet_config.gd"

const GlassDesert = preload("res://assets/maps/route_levels/planets/planet_glass_desert.gd")
const ObstacleLayout = preload("res://assets/maps/route_levels/runner_60s/obstacle_layout.gd")

## 星球三 · 稀树环带（演示锁定）

const PLANET_ID := "savanna_ring"

const GAME_TITLE := "星火信使：黎明线"
const MAP_NAME := "稀树环带"
const MAP_NAME_EN := "Savanna Ring"

const MISSION := {
	"runner_code": "Elsa",
	"cargo_name": "生物样本",
	"cargo_load": 100,
	"target_hearth": "环带观测站",
	"task_type": "科研护送",
}

const EMBER_COIN_VALUE := 20
const CARGO_DAMAGE_PER_HIT := 11.0
const CHASER_NAME := "环带掠影"

const THEME := {
	"background": Color(0.05, 0.08, 0.06),
	"ambient": Color(0.78, 0.82, 0.55),
	"ambient_energy": 1.25,
	"fog_color": Color(0.62, 0.72, 0.38),
	"fog_density": 0.0018,
	"sun_color": Color(1.0, 0.92, 0.62),
	"sun_energy": 2.3,
	"road": Color(0.34, 0.36, 0.28),
	"shoulder": Color(0.58, 0.48, 0.22),
	"curb": Color(0.72, 0.62, 0.28),
	"lane_line": Color(0.95, 0.95, 0.55),
	"sand": Color(0.62, 0.48, 0.22),
	"crystal": Color(0.35, 0.78, 0.42),
	"surroundings": "savanna",
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
	{"name": "样本确认", "start": 0.0, "end": 50.0, "hint": "生物样本 → 观测站"},
	{"name": "环带热身", "start": 50.0, "end": 320.0, "hint": "开阔视野 · 保持节奏"},
	{"name": "兽迹岔路", "start": 320.0, "end": 700.0, "hint": "安全兽道 / 捷径兽道"},
	{"name": "掠影追击", "start": 700.0, "end": 1020.0, "hint": "环带掠影逼近"},
	{"name": "观测冲刺", "start": 1020.0, "end": 99999.0, "hint": "抵达观测站"},
]

const JUNCTION_ZONES = GlassDesert.JUNCTION_ZONES
const SIDE_RUNWAY_ZONES = GlassDesert.SIDE_RUNWAY_ZONES
const SANDSTORM_ZONES = GlassDesert.SANDSTORM_ZONES

const OBSTACLE_TYPES := {
	"jump": "倒木栏",
	"slide": "低垂枝桠",
	"train": "迁徙兽群影",
	"train_moving": "惊扰兽群",
	"block_left": "左道灌木",
	"block_right": "右道灌木",
	"ramp": "土丘跳板",
	"main_block": "主路坍塌带",
	"turn_left": "兽道门",
	"turn_right": "捷径门",
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
	if ObstacleLayout.has_layout(PLANET_ID):
		return ObstacleLayout.load_items(PLANET_ID)
	return GlassDesert.build_obstacles()


static func build_coin_distances() -> Array:
	return GlassDesert.build_coin_distances()


static func build_main_runway_coins() -> Array:
	return GlassDesert.build_main_runway_coins()


static func build_side_runway_coins() -> Array:
	return GlassDesert.build_side_runway_coins()


static func build_shield_crystals() -> Array:
	return GlassDesert.build_shield_crystals()


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
