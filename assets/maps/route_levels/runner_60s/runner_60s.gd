extends Node3D

# 若 Godot 仍显示旧报错：完全退出编辑器后重新打开项目（磁盘版已修复）

const PlanetDatabase = preload("res://assets/maps/route_levels/planet_database.gd")
const MissionDispatch = preload("res://assets/maps/route_levels/mission_dispatch.gd")
const MissionTypes = preload("res://assets/maps/route_levels/mission_types.gd")
const CustomLevels = preload("res://assets/maps/route_levels/runner_60s/custom_levels.gd")
const ObstacleLayout = preload("res://assets/maps/route_levels/runner_60s/obstacle_layout.gd")
const RoadMeshBuilder = preload("res://assets/maps/route_levels/runner_60s/road_mesh_builder.gd")
const CharacterRoster = preload("res://assets/maps/route_levels/character_roster.gd")
const MobilePauseOverlay = preload("res://assets/maps/route_levels/mobile_pause_overlay.gd")
const HitFeedback = preload("res://assets/systems/hit_feedback/hit_feedback.gd")
const ROAD_ENERGY_NEON_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_energy_neon.gdshader")
const ROAD_ALIEN_ENERGY_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_alien_energy.gdshader")
const ROAD_HOLOGRAPHIC_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_holographic.gdshader")
const PIT_LAVA_SHADER = preload("res://assets/maps/route_levels/runner_60s/pit_lava.gdshader")
const RESERVOIR_W2_SKY_SHADER = preload("res://assets/maps/route_levels/runner_60s/reservoir_w2_sky.gdshader")
const MEDICAL_SUNRISE_SKY_SHADER = preload("res://assets/maps/route_levels/runner_60s/medical_sunrise_sky.gdshader")
const W1_SKY_AURORA_SHADER = preload("res://assets/maps/route_levels/runner_60s/w1_sky_aurora.gdshader")
const RESERVOIR_SKY_DOME_SHADER = preload("res://assets/maps/route_levels/runner_60s/reservoir_sky_dome.gdshader")
const RESERVOIR_W1_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w1_scene_sky.png")
const RESERVOIR_W2_PINK_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w2_pink_sky.png")
const MEDICAL_M2_DUSK_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w2_scene_sky.png")
const MEDICAL_SUNRISE_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/medical_sunrise_scene_sky.png")
const RELAY_E1_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/relay_e1_scene_sky.png")
const RELAY_E2_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/relay_e2_scene_sky.png")
const RELAY_E3_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/relay_e3_scene_sky.png")
const RELAY_E4_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/relay_e4_scene_sky.png")
const RESERVOIR_W3_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w3_scene_sky.png")
const RESERVOIR_W4_SKY_PANORAMA = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w4_scene_sky.png")
const RESERVOIR_W3_SKY_PLATE = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w3_sky_plate.png")
const RESERVOIR_W4_SKY_PLATE = preload("res://assets/maps/route_levels/runner_60s/backgrounds/panoramas/glass_desert_w4_sky_plate.png")
const SHIELD_ENERGY_SHADER = preload("res://assets/maps/route_levels/runner_60s/shield_energy.gdshader")
const FINISH_OUTPOST_SILHOUETTE_SHADER = preload("res://assets/maps/route_levels/runner_60s/finish_outpost_silhouette.gdshader")
const FINISH_OUTPOST_SKY_SHADER = preload("res://assets/maps/route_levels/runner_60s/finish_outpost_sky.gdshader")
const FINISH_PORTAL_GATE_SHADER = preload("res://assets/maps/route_levels/runner_60s/finish_portal_gate.gdshader")
const FINISH_OUTPOST_TITLE_SHADER = preload("res://assets/maps/route_levels/runner_60s/finish_outpost_title_wave.gdshader")
const SettlementHorizonLayer = preload("res://assets/maps/route_levels/runner_60s/settlement_horizon_layer.gd")
const CoinPickupScreenFx = preload("res://assets/maps/route_levels/runner_60s/coin_pickup_screen_fx.gd")
const SettlementHorizonHeader = preload("res://assets/maps/route_levels/runner_60s/settlement_horizon_header.gd")

const ROAD_STYLE_ORDER: Array[String] = RoadMeshBuilder.STYLE_ORDER
const ROAD_STYLE_LABELS := RoadMeshBuilder.STYLE_LABELS
# 概念资产 holographic_energy_runway.png → 全息能量轨 / 能量霓虹
# 异星能量轨 = 固态能量 shader；星球默认 = 晶砂实心路；粗粝沙漠 = 砾石沙面 shader

const LANE_WIDTH := 4.0
const RUNWAY_OBSTACLE_SPAN_INSET := 0.96
const RUNWAY_OBSTACLE_SPAN := LANE_WIDTH * 3.0 * RUNWAY_OBSTACLE_SPAN_INSET
const ORB_TARGET_HEIGHT := 2.65
const ORB_RUNWAY_WIDTH := LANE_WIDTH * 3.0
const ORB_SMALL_SPAN := ORB_RUNWAY_WIDTH / 6.0
const ORB_LARGE_SPAN := ORB_RUNWAY_WIDTH * 0.52
const ORB_HUGE_SPAN := ORB_RUNWAY_WIDTH * 0.78
# 终点前巨球：约 3.5~4× huge（目视约 4× 常规紫球量级），沙漠下仍压得住画面
const ORB_COLOSSAL_SPAN := ORB_HUGE_SPAN * 3.6
const ORB_SMALL_SCALE := ORB_SMALL_SPAN / ORB_TARGET_HEIGHT
const ORB_LARGE_SCALE := ORB_LARGE_SPAN / ORB_TARGET_HEIGHT
const ORB_HUGE_SCALE := ORB_HUGE_SPAN / ORB_TARGET_HEIGHT
const ORB_COLOSSAL_SCALE := ORB_COLOSSAL_SPAN / ORB_TARGET_HEIGHT
const ORB_HIT_RADIUS_FACTOR := 0.34
const ORB_HIT_DEPTH_FACTOR := 0.26
const ORB_POP_REVEAL_DIST := 42.0
const ORB_COLOSSAL_POP_REVEAL_DIST := 95.0
# 弹出动画未完成前不参与碰撞，避免「看不见却撞碎」
const ORB_COLLISION_POP_MIN := 0.78
const ORB_SMALL_DRIFT_SPEED := 5.35
const ORB_LARGE_DRIFT_SPEED := 1.02
const ORB_SMALL_FLOAT_SPEED := 2.9
const ORB_LARGE_FLOAT_SPEED := 0.68
const ORB_SMALL_FLOAT_AMP := 0.1
const ORB_LARGE_FLOAT_AMP := 0.32
const ORB_VISUAL_BASE_Y := 0.85
const ORB_DRIFT_SPAN := LANE_WIDTH * 1.12
const ORB_LAYOUT_VERSION := 8
const JUMP_BAR_HEIGHT := 1.28
const JUMP_WALL_TARGET_HEIGHT := 1.54
const JUMP_WALL_CLEAR_Y := 0.58
const JUMP_WOOD_FENCE_CHANCE := 12
const SLIDE_GATE_TOP := 3.08
const SLIDE_GATE_OPEN_BOTTOM := 1.22
const SLIDE_GATE_BLADE_PERIOD := 2.65
const TRAIN_GATE_TOP := 3.55
const TRAIN_GATE_BLADE_SPAN := LANE_WIDTH * 2.35
const SLIDE_GATE_HEIGHT := SLIDE_GATE_TOP
const SLIDE_CLEAR_Y := GROUND_Y + SLIDE_GATE_TOP - 0.06
const SLIDE_GATE_PILLAR_OUTSIDE_MARGIN := 1.05
const SLIDE_GATE_MODEL_BBOX_WIDTH := 1.0

const SLIDE_STAND_BODY_TOP := 1.18
const SLIDE_GATE_OUTER_EXTRA := 0.65
const SLIDE_GATE_INNER_BUFFER := 0.55
const SLIDE_GATE_MAX_OUTER_EXTRA := 2.6
const COIN_AIR_Y_OFFSET := 1.05
const COIN_GROUND_Y_OFFSET := 0.38
const COIN_MID_AIR_Y_OFFSET := 0.92
const COIN_HIGH_AIR_Y_OFFSET := 1.58
const LOW_SLIDE_BEAM_TOP := 2.18
const LOW_SLIDE_OPEN_BOTTOM := 0.48
const WAVE_ARC_OPEN_BOTTOM := 0.58
const WAVE_ARC_APEX_Y := 2.14
const WAVE_ARC_WALL_SPAN := 2.55
const ENERGY_RING_CENTER_Y := 1.28
const ENERGY_RING_INNER_HALF := 0.34
const ENERGY_RING_INNER_HALF_Y := 0.36
const ENERGY_RING_OUTER_HALF := 0.95
const ENERGY_RING_SCENE_PATHS: Array[String] = [
	"res://assets/maps/route_levels/runner_60s/environment_pack_v2/midnear_spark_ring_1.glb",
	"res://assets/maps/route_levels/runner_60s/environment_pack_v2/中景近景_星火环1.glb",
]
const TRAIN_GATE_SCENE_PATH := "res://mvp素材第二批/障碍物/0803/能量屏障（滑铲）.glb"
const LAVA_PLATFORM_MIN_STEP_Y := 0.52
const LAVA_PLATFORM_MAX_Y := 2.08
const FINISH_STRAIGHT_MIN := 680.0
const COIN_AIR_PICKUP_MARGIN := 0.35
const COIN_AIR_MIN_JUMP_Y := 0.72
const BUFF_AIR_Y_OFFSET := 1.38
const BUFF_GROUND_Y_OFFSET := 0.72
const SPEED_BOOST_DURATION := 5.0
const SPEED_BOOST_DURATION_EMERGENCY := 6.8
const SPEED_BOOST_MULT := 1.42
const SPEED_BOOST_MULT_EMERGENCY := 1.55
const SPEED_BOOST_SKILL_THRESHOLD := 5
## 路面加速垫：短距爆发 + 短暂余韵，中继站再加强
const PAD_BURST_DIST := 7.8
const PAD_BURST_MULT := 2.28
const PAD_BURST_DIST_RELAY := 10.5
const PAD_BURST_MULT_RELAY := 2.55
const PAD_LINGER_BOOST_TIME := 2.1
const PAD_LINGER_BOOST_TIME_RELAY := 2.8
const EMERGENCY_DASH_MULT := 1.55
const EMERGENCY_DASH_DURATION := 2.6
const EMERGENCY_DASH_HOLD := 0.35
# 选择门：右岔加速 / 左岔稳速护航
const FORK_RUSH_DURATION := 6.0
const FORK_RUSH_RAMP := 1.15
const FORK_RUSH_START_MULT := 1.18
const FORK_RUSH_MULT := 2.05
const FORK_SAFE_SPEED_MULT := 0.90
const FORK_RUSH_COIN_RADIUS := 2.4
const FORK_RUSH_HIT_IFRAME := 0.12
const FORK_RUSH_DAMAGE_MULT := 0.72
const WALL_RUN_SPEED_MULT := 1.08
# 终点冲刺路标
const FINISH_SPRINT_MULT := 1.85
const FINISH_SPRINT_DURATION := 7.5
const FINISH_GATE_BEFORE_END := 14.0
const FINISH_PORTAL_DEPTH := 4.0
const FINISH_TITLE_BASE_SCALE := 3.2
const FINISH_SILHOUETTE_INK := Color("#0A0E16")
const FINISH_SILHOUETTE_LINE := Color("#68C8F0")
const FINISH_HORIZON_HEIGHT := 22.0
const FINISH_OUTPOST_SILHOUETTE := {
	"gate": "res://assets/maps/route_levels/runner_60s/settlement/defense_settlement_silhouette.png",
	"relay": "res://assets/maps/route_levels/runner_60s/settlement/relay_settlement_silhouette.png",
	"medical": "res://assets/maps/route_levels/runner_60s/settlement/medical_settlement_silhouette.png",
}
# 普通撞障（非撞碎关）：顿帧 + 弹回
const HIT_STUN_TIME := 0.34
const HIT_STOP_TIME := 0.085
const HIT_BOUNCE_GAP := 0.55
const HIT_STUN_SPEED_MULT := 0.06
const AIR_LANE_CHANGE_MULT := 0.16
const AIR_LANE_CHANGE_RUSH_MULT := 0.08
## 空中前冲：略收，方便落地后立刻滑铲 / 连续跳；平台间距同步此系数
const AIR_FORWARD_SPEED_MULT := 0.62
const OVERWEIGHT_JUMP_SHORT_MULT := 0.42
const JUMP_DOUBLE_TAP_WINDOW := 0.62
const JUMP_DOUBLE_TAP_WINDOW_MOBILE := 0.85
# 全关卡默认：装备硬冲碎障
const SMASH_RUNNER_HP_DAMAGE := 0.45
const SMASH_LAYOUT_IDS := [
	"mission_reservoir_base",
	"layout_set_early_1",
	"layout_set_early_2",
	"layout_set_early_3",
	"layout_set_early_4",
	"layout_set_crisis_1",
	"layout_set_crisis_2",
	"layout_set_crisis_3",
	"layout_set_crisis_4",
	"layout_set_relay_1",
	"layout_set_relay_2",
	"layout_set_relay_3",
	"layout_set_relay_4",
	"mission_reservoir_w1",
	"mission_reservoir_w2",
	"mission_reservoir_w3",
	"mission_reservoir_w4",
	"mission_dome_h1",
	"mission_dome_h2",
	"mission_dome_h3",
	"mission_dome_h4",
	"mission_medical_m1",
	"mission_medical_m2",
	"mission_medical_m3",
	"mission_medical_m4",
	"mission_gate_d1",
	"mission_gate_d2",
	"mission_gate_d3",
	"mission_gate_d4",
	"mission_relay_e1",
	"mission_relay_e2",
	"mission_relay_e3",
	"mission_relay_e4",
	"mission_relay_lab",
	"mission_relay_rain",
	"mission_relay_01",
]
const SMASH_MISSION_IDS := [
	"mission_reservoir_01",
	"mission_reservoir_02",
	"mission_reservoir_03",
	"mission_reservoir_04",
	"mission_medical_01",
	"mission_medical_02",
	"mission_medical_03",
	"mission_medical_04",
	"mission_gate_01",
	"mission_gate_02",
	"mission_gate_03",
	"mission_gate_04",
	"mission_dome_01",
	"mission_dome_02",
	"mission_dome_03",
	"mission_dome_04",
]
const LANES := [-1, 0, 1]
const RUN_SPEED := 14.0
const RUN_SPEED_MAX := 24.0
const RUN_SPEED_EMERGENCY := 11.0
const RUN_SPEED_MAX_EMERGENCY := 17.5
const DEFAULT_RUN_TIME := MissionTypes.BASE_DURATION
const DEFAULT_TRACK_LENGTH := MissionTypes.BASE_TRACK_LENGTH
const LANE_CHANGE_EASE := 10.0
const GRAVITY := 30.0
const JUMP_SPEED := 10.8
## 轻点/下滑：短滑铲，方便马上接跳跃
const SLIDE_TIME := 0.46
## 按住滑铲键可延长到此上限
const SLIDE_HOLD_MAX := 1.05
## 最短承诺时长（过完障碍口前不立刻站起）
const SLIDE_MIN_COMMIT := 0.24
## 松手后收尾时长（尽快结束动作）
const SLIDE_RELEASE_FADE := 0.07
const MAGNET_RADIUS := 3.0
const MAGNET_SPEED := 14.0
const MAGNET_LANE_ONLY := true

# 追逐者：身后 Nulltide Wraith（零潮幽影），间距由压迫压力驱动
const CHASER_START_DISTANCE := 28.0
const CHASER_INTRO_START := 42.0
const CHASER_RELAY_INTRO_START := 48.0
const CHASER_MAX_DISTANCE := 35.0
const CHASER_BASE_CREEP := 0.42
const CHASER_RELAY_CREEP_SCALE := 0.78
const CHASER_HIT_PENALTY := 7.0
const CHASER_RELAY_HIT_PENALTY := 5.5
const CHASER_RECOVERY_RATE := 1.8
const CHASER_BOOST_RECOVERY_MULT := 2.6
const CHASER_BOOST_REPULSE := 6.0
const CHASER_CATCH_DISTANCE := 0.5
const CHASER_VISUAL_SCALE := 0.68
const CHASER_LATERAL_OFFSET := -0.38
const CHASER_FLOAT_HEIGHT := 1.05
## 开局后侧反打镜头总时长（方案 III）
const CHASER_REAR_INTRO_TIME := 2.6
const CHASER_REAR_PREVIEW_GAP := 10.5
const CHASER_REAR_RETURN_SEC := 0.3
## 跑酷顺利时，分叉处 Nullfeed 缩短间距比例
const TIDE_WELL_GAP_SHRINK := 0.25
const TIDE_WELL_SHOW_GAP := 16.0
const STRIKE_RECOVERY_TIME := 4.5
const HIT_SLOW_FACTOR := 0.52
const HIT_SLOW_DURATION := 1.35
const HIT_IFRAME_TIME := 0.85
const LANE_HIT_HALF_WIDTH := LANE_WIDTH * 0.52
const LANE_HIT_HALF_WIDTH_JUMP := LANE_WIDTH * 0.42
# 封道时仅最外侧车道可过（左封=右道安全，右封=左道安全）
const LANE_BLOCK_SAFE_EDGE := LANE_WIDTH * 0.35
const OBSTACLE_HALF_DEPTH := {
	"jump": 0.42,
	"low_barrier": 0.55,
	"orb": 0.26,
	"meteorite": 1.15,
	"slide": 0.72,
	"high_bar": 0.72,
	"wave_arc_slide": 0.78,
	"energy_ring": 0.62,
	"train": 0.55,
	"train_moving": 0.58,
	"meteorite_gate": 1.1,
	"block_left": 0.75,
	"block_right": 0.75,
	"main_block": 8.0,
}
const STRIKE_DAMAGE_TIER := {
	"jump": 0.55,
	"low_barrier": 0.55,
	"orb": 0.5,
	"meteorite": 0.85,
	"slide": 0.7,
	"high_bar": 0.7,
	"wave_arc_slide": 0.72,
	"energy_ring": 0.62,
	"block_left": 0.85,
	"block_right": 0.85,
	"main_block": 1.05,
	"train": 0.55,
	"train_moving": 0.62,
	"meteorite_gate": 0.0,
}
## 撞碎模式：按关卡内「可撞碎障碍总数」均分 100% 完整度（撞满才归零）
## 另保留 SMASH_CARGO_TIER 等常量供日后分级模式启用
const SMASH_CARGO_BASE := 8.0
const SMASH_CARGO_DAMAGE_MIN := 5.0
const SMASH_CARGO_DAMAGE_MAX := 22.0
const SMASH_CARGO_TIER := {
	"jump": 0.72,
	"low_barrier": 0.72,
	"orb": 0.62,
	"slide": 1.08,
	"high_bar": 1.08,
	"wave_arc_slide": 1.05,
	"energy_ring": 0.88,
	"meteorite": 1.32,
	"block_left": 1.22,
	"block_right": 1.22,
	"train": 0.78,
	"train_moving": 0.85,
}
const ENV_POISON_DPS_MULT := 1.38
const HEAT_HAZARD_DPS := 7.0
const HEAT_HAZARD_HALF_LEN := 7.0
const HEAT_HAZARD_TICK := 0.45
const SANDSTORM_TICK := 0.4
const SANDSTORM_DEFAULT_DPS := 9.0
const SKY_PROGRESS_SCROLL := 0.52
const SETTLEMENT_PANEL_BG := Color(0.06, 0.09, 0.14, 0.88)
const SETTLEMENT_PANEL_BORDER := Color("#68C8F0", 0.68)
const SETTLEMENT_BODY_COLOR := Color("#D8E8F8")
const SETTLEMENT_BUTTON_BG := Color(0.10, 0.14, 0.22, 0.96)
const SETTLEMENT_BUTTON_BORDER := Color("#68C8F0", 0.72)
const SHIELD_MAX_ENERGY := 100.0
const SHIELD_START_ENERGY := 0.0
const SHIELD_MIN_ACTIVATE := 15.0
const DEFENSE_CARGO_START_SHIELD := 25.0
const DEFENSE_CARGO_FRAGILITY := 0.7
const SHIELD_CRYSTAL_RESTORE := 10.0
const SHIELD_DRAIN_PER_SEC := 2.0
const SHIELD_HAZARD_DRAIN_PER_SEC := 6.0
const SHIELD_DRAIN_MULT := 1.15
## 天空鼓励弹幕文案（星火信使使命感 · 中英）
const SKY_CHEER_LINES: Array[Dictionary] = [
	{"zh": "太棒了，信使", "en": "Amazing, Messenger"},
	{"zh": "前线需要你，信使", "en": "The front needs you, Messenger"},
	{"zh": "一路坎坷，无畏冲锋", "en": "Rough road ahead — charge on"},
	{"zh": "希望马上运到", "en": "Hope is almost delivered"},
	{"zh": "星火未灭，使命必达", "en": "Ember still burns — mission stands"},
	{"zh": "你的每一步，都在点亮前哨", "en": "Every step lights the outpost"},
	{"zh": "货物安好，就是胜利", "en": "Safe cargo is victory"},
	{"zh": "沙暴挡不住星火信使", "en": "Sandstorms can't stop you"},
	{"zh": "坚持住——补给马上送达", "en": "Hold on — supply is coming"},
	{"zh": "荒原再远，信使必至", "en": "No waste too far for a Messenger"},
	{"zh": "别停步，前方在等你", "en": "Don't stop — they wait ahead"},
	{"zh": "你不是一个人在跑", "en": "You never run alone"},
	{"zh": "把希望送到他们手里", "en": "Put hope in their hands"},
	{"zh": "星火传递者，冲啊", "en": "Spark bearer — go!"},
	{"zh": "这一程，值得铭记", "en": "This run is worth remembering"},
	{"zh": "稳住节奏，使命在肩", "en": "Keep the pace — duty on your back"},
	{"zh": "你跑过的路，都在发光", "en": "The path you run begins to glow"},
	{"zh": "送达之日，荣耀归来", "en": "Deliver, then return in glory"},
	{"zh": "风沙再烈，心火更旺", "en": "Wilder sand, fiercer heartfire"},
	{"zh": "信使荣耀，今日加冕", "en": "Messenger honor — crowned today"},
]
const SKY_CHEER_EN_FONT := 56
const SKY_CHEER_ZH_FONT := 32
const SKY_CHEER_SCALE := 0.74
const SKY_CHEER_MAX_WIDTH_RATIO := 0.82
const SKY_CHEER_MIN_COUNT := 5
const SKY_CHEER_MAX_COUNT := 7
const INTRO_DURATION := 3.0
const PRE_RUN_LOADING_TIME := 0.45
const PRE_RUN_COUNTDOWN_STEP := 1.0
const RUNNER_BGM_COUNTDOWN_LEAD := PRE_RUN_COUNTDOWN_STEP * 3.0
# 追击默认关闭；Ignition Run 等任务类型会在开局打开 _chaser_enabled
const CHASER_ENABLED_DEFAULT := false
const GROUND_Y := 0.85
const LAVA_PLATFORM_THICKNESS := 0.36
const CAMERA_BEHIND := 6.5
const CAMERA_HEIGHT := 2.2
const CAMERA_LOOK_AHEAD := 18.0
const CAMERA_FOV := 64.0
const DISTANT_SCALE_CAP := 80.0
const DISTANT_VISIBLE_AHEAD := 560.0
const DISTANT_VISIBLE_BEHIND := -90.0
const DISTANT_RUNWAY_CLEARANCE := 24.0
const MIDGROUND_RUNWAY_CLEARANCE := 3.4
const CHANNEL_BASE_CLEARANCE := 1.85
const CHANNEL_BASE_HEIGHT := 2.85
const DISTANT_TOWER_LATERAL_MIN := 36.0
const DISTANT_TOWER_LATERAL_MAX := 52.0
const DISTANT_ACCENT_LATERAL_MIN := 42.0
const DISTANT_ACCENT_LATERAL_MAX := 58.0
const MIDGROUND_LATERAL_MIN := 13.0
const MIDGROUND_LATERAL_MAX := 19.5
const MIDGROUND_FORK_PUSH := 6.0
const MIDGROUND_CLUSTER_SPACING_MIN := 20.0
const MIDGROUND_CLUSTER_SPACING_MAX := 30.0
const MIDGROUND_SCALE_CAP := 80.0
const MIDGROUND_VISIBLE_AHEAD := 130.0
const MIDGROUND_VISIBLE_BEHIND := -22.0
const MIDGROUND_REVEAL_AHEAD := 168.0
const MIDGROUND_MIN_VISIBLE_HEIGHT := 2.2
const MIDGROUND_PROP_DEFAULTS: Array[String] = [
	"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
	"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
	"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
	"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
]
const RUNWAY_EDGE_FILLER_PATHS: Array[String] = [
	"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
	"res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb",
]
const FORK_GAP_DECOR_PATHS: Array[String] = [
	"res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb",
	"res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb",
	"res://mvp素材第二批/障碍物/0803/废旧广告牌（滑铲）.glb",
]
const ENVIRONMENT_PACK_V2_MIX_RATIO := 0.20
const ENVIRONMENT_PACK_V2_PATHS := [
	"res://assets/maps/route_levels/runner_60s/environment_pack_v2/mid_deadzone_billboard.glb",
	"res://assets/maps/route_levels/runner_60s/environment_pack_v2/midnear_spark_ring_1.glb",
	"res://assets/maps/route_levels/runner_60s/environment_pack_v2/midnear_spark_ring_2.glb",
]
const RUNNER_OBS_LIGHT_JUMP := "res://assets/maps/route_levels/runner_60s/obstacles_lightweight/jump_crumbling_ruined_wall.glb"
const RUNNER_OBS_LIGHT_JUMP_WALL := RUNNER_OBS_LIGHT_JUMP
const RUNNER_ENERGY_ORB_GRUMPY := "res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_grumpy_2_5d.png"
const RUNNER_ENERGY_ORB_ANGRY := "res://assets/maps/route_levels/runner_60s/obstacles_2_5d/obstacle_energy_orb_angry_2_5d.png"
const RUNNER_ENERGY_ORB_SPRITES: Array[String] = [
	RUNNER_ENERGY_ORB_GRUMPY,
	RUNNER_ENERGY_ORB_ANGRY,
]
const RUNNER_OBS_LIGHT_SLIDE_PIPELINE := "res://assets/maps/route_levels/runner_60s/obstacles_lightweight/slide_rusty_industrial_pipeline.glb"
const RUNNER_OBS_LIGHT_SLIDE_SPIKE := "res://assets/maps/route_levels/runner_60s/obstacles_lightweight/slide_spike_barrier.glb"
const OBSTACLE_PROP_MEDICAL_POD := "res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb"
const OBSTACLE_PROP_MEDICAL_CRATE := "res://assets/maps/route_levels/models/environment/midground/midground_medical_crate.glb"
const OBSTACLE_PROP_BROKEN_DRONE := "res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb"
const OBSTACLE_PROP_RELAY_DRONE := "res://assets/maps/route_levels/runner_60s/relay_final/midground_drone.glb"
const OBSTACLE_PROP_METEORITE := "res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb"
const OBSTACLE_PROP_EXCAVATOR := "res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb"
const RESERVOIR_SLIDE_BILLBOARD := "res://mvp素材第二批/障碍物/0803/废旧广告牌（滑铲）.glb"
const RESERVOIR_CRYSTAL_TOWER := "res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb"
const RESERVOIR_CRYSTAL_PILLAR_1 := "res://assets/maps/route_levels/models/environment/distant/giant_energy_crystal_pillar_1.glb"
const RESERVOIR_CRYSTAL_PILLAR_2 := "res://assets/maps/route_levels/models/environment/distant/giant_energy_crystal_pillar_2.glb"
const RESERVOIR_CRYSTAL_PILLARS: Array[String] = [
	RESERVOIR_CRYSTAL_TOWER,
	RESERVOIR_CRYSTAL_PILLAR_1,
	RESERVOIR_CRYSTAL_PILLAR_2,
]
const RESERVOIR_CHANNEL_CORAL := "res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb"
const RESERVOIR_CHANNEL_TREE := "res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb"
const RESERVOIR_CHANNEL_BILLBOARD := "res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb"
const RESERVOIR_CHANNEL_OBSERVATORY := "res://assets/maps/route_levels/models/environment/distant/futuristic_pod.glb"
const RESERVOIR_CHANNEL_OBSERVATORY_ALT := "res://assets/maps/route_levels/models/environment/midground/midground_medical_pod.glb"
const RESERVOIR_CRASHED_SHIP := "res://assets/maps/route_levels/models/environment/distant/futuristic_spaceship.glb"
const SKY_PANORAMA_BILLBOARD_RECTS := [
	Vector4(0.06, 0.10, 0.20, 0.42),
	Vector4(0.38, 0.06, 0.24, 0.46),
	Vector4(0.68, 0.12, 0.20, 0.40),
	Vector4(0.22, 0.02, 0.26, 0.34),
	Vector4(0.56, 0.03, 0.24, 0.32),
]
const MIDGROUND_METEORITE_PALETTES := [
	{
		"label": "sandstone",
		"albedo": Color(0.78, 0.62, 0.42),
		"emission": Color(0.16, 0.12, 0.08),
		"emission_energy": 0.0,
	},
	{
		"label": "ash",
		"albedo": Color(0.62, 0.56, 0.48),
		"emission": Color(0.10, 0.10, 0.09),
		"emission_energy": 0.0,
	},
	{
		"label": "iron_dust",
		"albedo": Color(0.70, 0.50, 0.38),
		"emission": Color(0.14, 0.08, 0.06),
		"emission_energy": 0.0,
	},
	{
		"label": "dusty_sage",
		"albedo": Color(0.58, 0.60, 0.46),
		"emission": Color(0.08, 0.10, 0.08),
		"emission_energy": 0.0,
	},
	{
		"label": "slate",
		"albedo": Color(0.56, 0.54, 0.50),
		"emission": Color(0.07, 0.08, 0.10),
		"emission_energy": 0.0,
	},
	{
		"label": "clay",
		"albedo": Color(0.74, 0.54, 0.40),
		"emission": Color(0.12, 0.08, 0.06),
		"emission_energy": 0.0,
	},
]
const START_PAD_LENGTH := 72.0
const TOUCH_SWIPE_MIN_DISTANCE := 72.0
const TOUCH_TAP_MAX_DISTANCE := 26.0
const MOBILE_VIEWPORT_SIZE := Vector2(1080, 1920)
const ANIMATED_PLAYER_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/animated.fbx"
const ANIMATED_PLAYER_IDLE_ANIM := "NlaTrack.002"
const ANIMATED_PLAYER_RUN_ANIM := "mixamo_com"
const ANIMATED_PLAYER_CELEBRATE_ANIM := "NlaTrack.001"
const PLAYER_MODEL_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/idle.glb"
const PLAYER_RUN_LEFT_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/run_left.glb"
const PLAYER_RUN_RIGHT_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/run_right.glb"
const PLAYER_JUMP_START_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/jump_start.glb"
const PLAYER_JUMP_PEAK_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/jump_apex.glb"
const PLAYER_LANDING_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/jump_land.glb"
const PLAYER_SLIDE_SCENE_PATH := "res://assets/maps/route_levels/models/characters/elsa/slide.glb"
const PLAYER_MODEL_HEIGHT := 1.65
const PLAYER_SKELETAL_MODEL_HEIGHT := 2.08
const PLAYER_MODEL_YAW := -90.0
const PLAYER_INTRO_BODY_YAW := 180.0
const PLAYER_SLIDE_MODEL_HEIGHT := 0.75
const PLAYER_SLIDE_VISUAL_HEIGHT := 1.65
const PLAYER_SLIDE_CROUCH_HEIGHT := 0.58
const PLAYER_SLIDE_MAX_DEPTH := 1.25
const PLAYER_SKELETAL_SLIDE_BODY_SCALE := Vector3(1.0, 0.70, 1.0)
const PLAYER_SKELETAL_SLIDE_BODY_Y := -0.22
const PLAYER_SLIDE_MODEL_YAW := 180.0
const IMPORTED_SCENE_FALLBACKS := {
	"res://assets/maps/route_levels/models/obstacles/jump/barrier_01.glb": "res://.godot/imported/障碍物-需跳跃.glb-46f57db02e27254a677214f954ab0d83.scn",
	"res://assets/maps/route_levels/models/obstacles/jump/barrier_02.glb": "res://.godot/imported/障碍物-需跳跃2.glb-c8c9938e154747024ae7ac221ab7db3a.scn",
	"res://assets/maps/route_levels/models/environment/buildings/dome_habitat_legacy.glb": "res://.godot/imported/居民穹顶据点 3d model.glb-f6066a8ae2d51e15aff61146c4296099.scn",
	"res://3d素材/障碍物-需跳跃.glb": "res://.godot/imported/障碍物-需跳跃.glb-46f57db02e27254a677214f954ab0d83.scn",
	"res://3d素材/障碍物-需跳跃2.glb": "res://.godot/imported/障碍物-需跳跃2.glb-c8c9938e154747024ae7ac221ab7db3a.scn",
	"res://3d素材/居民穹顶据点 3d model.glb": "res://.godot/imported/居民穹顶据点 3d model.glb-f6066a8ae2d51e15aff61146c4296099.scn",
	"res://mvp素材第一批/居民穹顶3d.glb": "res://.godot/imported/居民穹顶3d.glb-dd223b3c77563b276502526a69ea43fa.scn",
	RUNNER_OBS_LIGHT_JUMP: "res://.godot/imported/jump_crumbling_ruined_wall.glb-a4790482496b3a5ed5266abd70d13067.scn",
	RUNNER_OBS_LIGHT_SLIDE_PIPELINE: "res://.godot/imported/slide_rusty_industrial_pipeline.glb-fbe22b715a93f4197e3f5f175890b749.scn",
	RUNNER_OBS_LIGHT_SLIDE_SPIKE: "res://.godot/imported/slide_spike_barrier.glb-bf10e4e63e39b9e23970fcfe9037a6f0.scn",
}
const HEARTH_DOME_TEXTURES := {
	"basecolor": [
		"res://mvp素材第一批/居民穹顶3d_glass_dome_3d_model_basecolor.jpg",
		"res://3d素材/居民穹顶据点 3d model_desert+dome+3d+model_basecolor.jpg",
	],
	"normal": [
		"res://mvp素材第一批/居民穹顶3d_glass_dome_3d_model_normal.jpg",
		"res://3d素材/居民穹顶据点 3d model_desert+dome+3d+model_normal.jpg",
	],
	"orm": [
		"res://mvp素材第一批/居民穹顶3d_glass_dome_3d_model_rm.jpg",
		"res://3d素材/居民穹顶据点 3d model_desert+dome+3d+model_rm.jpg",
	],
}

# 垂直墙跑（神秘海域式侧墙，与主路成 90°）
const WALL_RUN_LAYER := 1
const WALL_LANE_HEIGHTS: Array[float] = [1.55, 3.05, 4.55] # 墙面上的三列高度：低 / 中 / 高
const WALL_LANE_LABELS: Array[String] = ["低列", "中列", "高列"]
const WALL_DEFAULT_OFFSET := 6.25 # 路缘对齐：road_half(6.0) + 墙厚一半
const WALL_THICKNESS := 0.5
const WALL_FACE_HEIGHT := 6.4
const WALL_RUN_UV_SCALE := 0.14
# 脚点贴墙面后略朝主路推出，避免 z-fight / 穿模
const WALL_STAND_CLEARANCE := 0.18
## 侧墙跑道起止占位：陨石山 / 挖掘机等（与 early/crisis 视觉 kit 交叉）
const SIDE_RUNWAY_ANCHOR_METEORITE := "res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb"
const SIDE_RUNWAY_ANCHOR_EXCAVATOR := "res://assets/maps/route_levels/models/environment/midground/midground_excavator_robot.glb"
const SIDE_RUNWAY_ANCHOR_CORAL := "res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb"
const LAYER_HEIGHTS := [GROUND_Y, 3.8, 6.5] # 保留兼容；墙跑不再用抬高层
const LAYER_NAMES := ["地面", "侧墙", "高架"]

var LevelConfig: Script
var _world_panorama: Texture2D
var _jump_obstacle_paths: Array[String] = []
var _slide_obstacle_paths: Array[String] = []
var _side_prop_paths: Array[String] = []
var _midground_prop_paths: Array[String] = []
var _landmark_prop_paths: Array[String] = []
var _distant_tower_paths: Array[String] = []
var _distant_pod_paths: Array[String] = []
var _distant_spaceship_paths: Array[String] = []
var _distant_hearth_paths: Array[String] = []
var _distant_accent_prop_paths: Array[String] = []
var _near_runway_prop_paths: Array[String] = []
var _environment_pack_v2_paths: Array[String] = []
var _environment_pack_v2_mix_ratio := 0.0
var _slide_obstacle_scene: PackedScene
var _hearth_scene_path := ""
var _player_scene_paths: Dictionary = {}
var _scene_cache: Dictionary = {}
var _world_ready := false
var _side_dressing_root: Node3D
var _distant_background_root: Node3D
var _runway_side_lights_root: Node3D
var _ruin_backdrop_root: Node3D
var _sky_accents_root: Node3D
var _medical_m2_aurora_root: Node3D
var _road_root: Node3D
var _lava_platform_visual_root: Node3D = null
var _world_environment: WorldEnvironment
var _reservoir_sky_dome: MeshInstance3D
var _relay_sky_flat_pano: Texture2D
var _road_mesh: RoadMeshBuilder = RoadMeshBuilder.new()
var _road_style_kit: Dictionary = {}
var _road_style_id := "holographic"
var _background_style_id := "desert_crystal"
var _path_baked := false
var _road_edge_particles: Array[GPUParticles3D] = []

var player: CharacterBody3D
var player_body: Node3D
var player_pose_root: Node3D
var player_slide_pose_root: Node3D
var player_pose_models: Dictionary = {}
var player_animation_player: AnimationPlayer
var player_animation_name := ""
var _skeletal_run_enabled := false
var camera_pivot: Node3D
var camera: Camera3D
var trail_particles: GPUParticles3D
var landing_particles: GPUParticles3D
var foot_spark_particles: GPUParticles3D
var body_spark_particles: GPUParticles3D
var _ember_fx_root: Node3D
var _foot_flame_mesh: MeshInstance3D
var _foot_flame_mesh_b: MeshInstance3D
var _body_flame_mesh: MeshInstance3D
var _foot_flame_mat: ShaderMaterial
var _foot_flame_mat_b: ShaderMaterial
var _body_flame_mat: ShaderMaterial
var _aura_kick_smooth := 0.0
var jump_streak_particles: GPUParticles3D
var wall_boost_particles: GPUParticles3D
var rush_aura_particles: GPUParticles3D
var _trail_process_mat: ParticleProcessMaterial
var _hit_fov_punch := 0.0
var _speed_feel_punch := 0.0
var _run_body_pitch := 0.0
var _speed_rumble := 0.0
var _wall_boost_fx_timer := 0.0
var _jump_fx_timer := 0.0
var lane_index := 1
var target_lane_x := 0.0
var current_lateral := 0.0
var lane_change_ease := LANE_CHANGE_EASE
var vertical_velocity := 0.0
var slide_timer := 0.0
var _slide_elapsed := 0.0
var _slide_hold_wanted := false
var elapsed := 0.0
var current_speed := RUN_SPEED
var body_tilt := 0.0
var body_squash_timer := 0.0
var player_pose_name := ""
var _player_pose_base_scale := Vector3.ONE
var _player_pose_base_yaw := 0.0
var _player_slide_base_y := 0.0
var _run_anim_speed_smooth := 1.0
var _run_stride_phase := 0.0
var camera_shake := 0.0
var was_on_ground := true
var _air_pose_grace := 0.0
var _landing_pose_timer := 0.0
var _jump_takeoff_pose_timer := 0.0
var _land_fx_cd := 0.0
var _peak_air_vy := 0.0
var is_finished := false
var is_failed := false
var collected_count := 0
var total_collectibles := 0
var crystal_collected_count := 0
var run_score := 0
var cargo_integrity := 100.0
var shield_energy := SHIELD_START_ENERGY
var shield_active := false
var _shield_mesh: MeshInstance3D
var _shield_waist_ring: MeshInstance3D
var _shield_orbit_ring_b: MeshInstance3D
var _shield_ground_ripple: MeshInstance3D
var _shield_shader_mat: ShaderMaterial
var _shield_warned_empty := false
var _shield_drain_fx_cd := 0.0
var _path_stretch_smooth := 1.0
var _coin_hud_flash_cd := 0.0
var mission: Dictionary = {}
var _mission_profile: Dictionary = {}
var _run_time := DEFAULT_RUN_TIME
var _track_length := DEFAULT_TRACK_LENGTH
var _finish_line_distance := 0.0
var _finish_portal_root: Node3D
var _finish_outpost_title_rig: Label3D
var _finish_outpost_title_glow: Label3D
var _finish_outpost_title_bloom: Label3D
var _finish_title_base_y := 16.6
var _finish_title_z := -5.2
var _finish_outpost_height := 21.0
var _finish_silhouette_mats: Array[ShaderMaterial] = []
var _finish_silhouette_billboard_mat: StandardMaterial3D
var _finish_silhouette_rim_mat: StandardMaterial3D
var _finish_portal_mats: Array[ShaderMaterial] = []
var _finish_title_mat: ShaderMaterial
var _finish_sky_mat: ShaderMaterial
var _finish_silhouette_billboard: Node3D
var _finish_outpost_model_mats: Array[StandardMaterial3D] = []
var _finish_approach_boost_cached := -1.0
var _finish_title_scale_cached := -1.0
var _sandstorm_grit_particles: GPUParticles3D
var _overweight_intro_pending := false
var _overweight_run_tip_shown := false
var _overweight_jump_armed := false
var _overweight_short_jump_timer := 0.0
var _chaser_enabled := CHASER_ENABLED_DEFAULT
var _pressure_chaser_enabled := false
var _energy_chaser: EnergyChaserController = null
var _chase_overlay: ColorRect = null
var _chase_overlay_mat: ShaderMaterial = null
var _capture_swallow: ColorRect = null
var _capture_swallow_mat: ShaderMaterial = null
var _capture_cinematic_active := false
var _capture_cinematic_t := 0.0
var _capture_fail_reason := ""
var _capture_settlement_ready := false
var _chaser_intro_look := 0.0
## 开局后侧反打：0→2.6s；每关仅播一次
var _chaser_rear_intro_t := 0.0
var _chaser_rear_intro_played := false
var _chaser_rear_flash_done := false
## 分叉 Nullfeed 标记（左右岔都会经过）
var _tide_wells: Array[Dictionary] = []
var _chaser_hint_bar: ProgressBar = null
const CAPTURE_CINEMATIC_TIME := 1.55
var obstacles: Array[Dictionary] = []
var collectibles: Array[Dictionary] = []
var track_distance := 0.0
var track_layer := 0
var current_wall_y := 3.05
var _wall_roll := 0.0
var track_root: Node3D
var passed_junctions: Array[int] = []
var _path_samples: Array[Dictionary] = []
var _path_length := 0.0
var _fork_side := 0
var _active_fork_index := -1
var _path_yaw := 0.0
var _fork_approach_warned: Array[int] = []
var _y_fork_regions: Array = []
var _junction_fork_regions: Array = []
var passed_y_forks: Array[int] = []
var _active_y_fork_index := -1
var _y_fork_approach_warned: Array[int] = []
var _cached_junction_zones: Array = []
var _cached_sandstorm_zones: Array = []
var _cached_side_runway_zones: Array = []
var _layout_zones_ready := false

var chaser: Node3D
var chaser_body: MeshInstance3D
var _chaser_cloak_root: Node3D
var _chaser_cloak_layers: Array[MeshInstance3D] = []
var _chaser_void_face: MeshInstance3D
var _chaser_trail: GPUParticles3D
var chaser_distance := CHASER_START_DISTANCE
var chaser_pulse := 0.0
var strike_count := 0
var _smash_hit_count := 0
var _smash_obstacle_total := 0
var _smash_cargo_damage := 10.0
var strike_recovery_timer := 0.0
var speed_penalty_mult := 1.0
var speed_penalty_timer := 0.0
var is_intro := true
var intro_elapsed := 0.0
var pre_run_phase := "loading"
var countdown_step := 3
var countdown_timer := 0.0
var gameplay_active := false
var touch_active := false
var touch_start_pos := Vector2.ZERO

var time_label: Label
var speed_label: Label
var collectible_label: Label
var layer_label: Label
var phase_label: Label
var score_label: Label
var cargo_label: Label
var cargo_detail_label: Label
var cargo_title_label: Label
var cargo_icon: TextureRect
var chase_label: Label
var chase_bar: ProgressBar
var chaser_hint_wrap: MarginContainer
var chaser_hint_panel: PanelContainer
var chaser_hint_label: Label
var danger_vignette: ColorRect
var strike_toast_label: Label
var strike_toast_timer := 0.0
## 天空鼓励弹幕（固定视线中央天空 HUD）
var _sky_cheer_hud_layer: Control
var _sky_cheer_schedule: Array[Dictionary] = [] # [{d, text, spawned}]
var _sky_cheer_active: Array[Dictionary] = [] # [{label, age, life, speed, y, start_x}]
var _sky_cheer_rng := RandomNumberGenerator.new()
var _hit_feedback: HitFeedback
var _cargo_hud_panel: PanelContainer
var _heat_tick_accum := 0.0
var _side_runway_penalty_accum := 0.0
var _lava_platforms: Array = []
var _lava_platform_hint_timer := 0.0
var _path_height_keys: Array = []
var _launch_pads: Array = []
var _width_zones: Array = []
var _open_gaps: Array = []
var _mechanic_layout_ready := false
var _launch_air_lock_until_d := -1.0
var _triggered_launch_ids: Dictionary = {}
var _mechanic_hint_warned: Dictionary = {}
var _sandstorm_tick_accum := 0.0
var _sandstorm_active := false
var _sandstorm_warned_keys: Array = []
var _sandstorm_particles: GPUParticles3D
var _rain_particles: GPUParticles3D
var _rain_soft_particles: GPUParticles3D
var _rain_splash_particles: GPUParticles3D
var _rain_active := false
var _rain_intensity := 1.0
var _rain_puddles: Array[Dictionary] = []
var _rain_puddle_spawn_accum := 0.0
var _rain_puddle_next_d := -1.0
var _rain_puddle_hit_cd := 0.0
var _rain_puddle_rng := RandomNumberGenerator.new()
var _cached_rain_zones: Array = []
var _rain_full_track := false
var _rain_intro_shown := false
var _rain_enter_toast_cd := 0.0
var _side_hazard_emitters: Dictionary = {}
var _side_hazard_runtime: Dictionary = {}
var _base_fog_density := 0.0022
var _base_fog_light_color := Color(0.36, 0.30, 0.38)
var _base_ambient_light_color := Color(0.48, 0.44, 0.56)
var _base_ambient_light_energy := 0.74
var _base_sky_yaw := 0.0
var _base_sky_pitch := 0.0
var _base_sun_rot := Vector3(-52, 35, 0)
var _base_sun_energy := 1.75
var _base_sun_color := Color(0.94, 0.78, 0.58)
var _base_panorama_energy := 1.65
var _wall_mount_armed := false
var _wall_mount_armed_until_d := -1.0
var _pit_fall_grace := 0.0
var _last_wall_side := 1.0
var _hit_iframe_timer := 0.0
var _obstacle_scan_index := 0
## 侧墙跑首次教学：贴墙道 → 再朝墙按 → 跳跃
const WALL_TUT_OFF := 0
const WALL_TUT_APPROACH := 1
const WALL_TUT_LANE := 2
const WALL_TUT_ARM := 3
const WALL_TUT_JUMP := 4
const WALL_TUT_DONE := 5
var _wall_tut_step := WALL_TUT_OFF
var _wall_tut_zone: Dictionary = {}
var _wall_tut_root: Node3D
var _side_runway_guide_root: Node3D
var _wall_tut_panel: PanelContainer
var _wall_tut_title: Label
var _wall_tut_body: Label
var _wall_tut_pulse := 0.0
var _wall_jump_hint_label: Label
var _wall_jump_hint_timer := 0.0
## 通用操作教学（跳/滑/换道/盾/分叉/沙尘），与侧墙教学共用面板
var _coach_tip_key := ""
var _coach_tip_until_d := -1.0
## 教学暂停：冻结推进，等玩家完成指定操作
var _tutorial_paused := false
var _tutorial_expect := ""
var intro_panel: PanelContainer
var intro_title: Label
var intro_body: Label
var state_panel: PanelContainer
var state_title: Label
var state_body: Label
var state_restart_button: Button
var state_back_button: Button
var _settlement_horizon_layer: SettlementHorizonLayer
var _settlement_horizon_header: SettlementHorizonHeader
var _state_wrap: MarginContainer
var _state_outer: VBoxContainer
var _state_box: VBoxContainer
var _state_panel_spacer: Control
var _state_button_row: VBoxContainer
var _settlement_celebration_active := false
var _settlement_is_failure := false
var _settlement_continue_locked := false
var pause_button: Button
var shield_button: Button
var shield_label: Label
var shield_bar: ProgressBar
var _shield_energy_label: Label
var _buff_hud_panel: PanelContainer
var _top_hud_wrap: MarginContainer
var _run_timer_label: Label
var _buff_boost_row: HBoxContainer
var _boost_pips: Array[ColorRect] = []
var _boost_count_label: Label
var _boost_dash_icon_wrap: PanelContainer
var _boost_dash_icon: Label
var _boost_status_label: Label
var _boost_dash_pulse := 0.0
var _speed_boost_bar: ProgressBar
var _speed_boost_time_label: Label
var hud_root: Control
var debug_hud_box: VBoxContainer
var settlement_detail_timer := 0.0
var pending_settlement_title := ""
var pending_settlement_body := ""
var _runner_bgm_started := false
var _letterbox_left: ColorRect
var _letterbox_right: ColorRect
var _pause_overlay: MobilePauseOverlay
var _coin_screen_flash: ColorRect
var _coin_flash_tween: Tween
var _coin_pickup_screen_fx: CoinPickupScreenFx

var _speed_boost_timer := 0.0
var _speed_boost_cycle := 0
var _pad_burst_until_d := -1.0
var _is_emergency_run := false
var _midground_vis_tick := 0
var _fork_rush_timer := 0.0
var _fork_rush_elapsed := 0.0
var _finish_sprint_timer := 0.0
var _finish_sprint_pads: Array = []
var _hit_stun_timer := 0.0
var _hitstop_timer := 0.0
var _hit_recoil_timer := 0.0
var _emergency_dash_charges := 0
var _emergency_dash_timer := 0.0
var _coin_pickup_burst_mesh: Mesh
var _coin_pickup_pentagon_ring_mesh: Mesh
var _coin_pickup_pentagon_fill_mesh: Mesh
var _coin_streak_count := 0
var _coin_streak_timer := 0.0
const COIN_STREAK_WINDOW := 1.05
var _skeletal_stabilize_timer := 0.0
func _ready() -> void:
	LevelConfig = PlanetDatabase.get_runner_config(Global.runner_planet_id)
	mission = _resolve_runner_mission()
	if mission.is_empty() and LevelConfig != null:
		mission = LevelConfig.MISSION.duplicate()
	_apply_mission_type_profile()
	lane_change_ease = LANE_CHANGE_EASE + Global.get_lane_change_ease_bonus()
	cargo_integrity = 100.0
	_smash_hit_count = 0
	_smash_obstacle_total = 0
	_smash_cargo_damage = 10.0
	shield_energy = DEFENSE_CARGO_START_SHIELD if _is_defense_cargo() else SHIELD_START_ENERGY
	shield_active = false
	_shield_warned_empty = false
	crystal_collected_count = 0
	track_root = Node3D.new()
	track_root.name = "TrackRoot"
	add_child(track_root)
	_build_ui()
	_setup_pause_overlay()
	intro_panel.visible = true
	pre_run_phase = "loading"
	intro_elapsed = 0.0
	# 进关先淡出主页曲，等 3-2-1 再从头播跑酷曲
	Global.stop_bgm(0.55)
	get_viewport().size_changed.connect(_update_runner_letterboxes)
	call_deferred("_update_runner_letterboxes")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if OS.has_feature("mobile") else Input.MOUSE_MODE_CAPTURED
	call_deferred("_bootstrap_runner_world")

func _resolve_runner_mission() -> Dictionary:
	if CustomLevels.has_level(Global.runner_location_id):
		var custom_mission := CustomLevels.make_mission(Global.runner_location_id).duplicate()
		var custom_meta := CustomLevels.get_level(Global.runner_location_id)
		var base_planet := String(custom_meta.get("planet_id", Global.runner_planet_id))
		if base_planet != "" and base_planet != Global.runner_planet_id:
			LevelConfig = PlanetDatabase.get_runner_config(base_planet)
		return custom_mission
	var mission_id := String(Global.runner_mission_id)
	if mission_id != "" and LevelConfig != null and LevelConfig.has_method("get_mission_by_id"):
		var by_id: Dictionary = LevelConfig.get_mission_by_id(mission_id)
		if not by_id.is_empty():
			return by_id.duplicate()
	if LevelConfig != null and LevelConfig.has_method("get_mission_for_location"):
		var by_location: Dictionary = LevelConfig.get_mission_for_location(Global.runner_location_id)
		if not by_location.is_empty():
			return by_location.duplicate()
	return {}

func _runner_layout_id() -> String:
	var layout_id := String(mission.get("layout_id", Global.runner_mission_id)).strip_edges()
	if layout_id == "":
		return ""
	if not ObstacleLayout.has_layout(layout_id):
		push_warning("Runner: layout JSON not found: %s" % layout_id)
		return ""
	if ObstacleLayout.load_root(layout_id).is_empty():
		push_warning("Runner: layout JSON invalid or empty: %s" % layout_id)
		return ""
	return layout_id


func _mission_layout_id_for_smash() -> String:
	var layout_id := String(mission.get("layout_id", Global.runner_mission_id)).strip_edges()
	if layout_id != "":
		return layout_id
	return _runner_layout_id()

func _mission_layout_id() -> String:
	return _runner_layout_id()

func _apply_mission_type_profile() -> void:
	mission = MissionTypes.enrich_mission(mission)
	_mission_profile = MissionTypes.resolve(mission)
	_run_time = float(_mission_profile.get("duration", DEFAULT_RUN_TIME))
	_track_length = MissionTypes.track_length_for(_run_time)
	_chaser_enabled = bool(_mission_profile.get("enable_chaser", false))
	_pressure_chaser_enabled = bool(_mission_profile.get("pressure_chaser", false)) \
		or String(_mission_profile.get("chaser_mode", mission.get("chaser_mode", ""))) == "pressure" \
		or bool(mission.get("pressure_chaser", false))
	# 星火中继站追击关统一走 Pressure 异能量前沿
	if _chaser_enabled and _is_relay_mission():
		_pressure_chaser_enabled = true
	if _pressure_chaser_enabled:
		_chaser_enabled = true
	mission["duration"] = _run_time
	mission["task_type"] = String(_mission_profile.get("task_type", "Supply Run"))
	mission["task_type_zh"] = String(_mission_profile.get("name_zh", "补给"))
	mission["task_hint"] = String(_mission_profile.get("hint", ""))
	mission["base_reward"] = int(_mission_profile.get("base_reward", 0))
	_is_emergency_run = bool(_mission_profile.get("timed_fail", false))
	current_speed = _base_run_speed()

func _bootstrap_runner_world() -> void:
	_load_planet_assets()
	_build_world()
	await get_tree().process_frame
	_build_runner()
	_apply_road_style_environment()
	_build_chaser()
	await get_tree().process_frame
	_build_content()
	_load_cargo_icon()
	if _pressure_chaser_enabled and _energy_chaser != null:
		_energy_chaser.runner = player
		_energy_chaser.set_physics_process(false)
		# 开局只预览潮体（压迫=0），正式追击等后侧镜头结束再 start_chase
		_energy_chaser.begin_visual_preview(CHASER_REAR_PREVIEW_GAP)
		chaser_distance = CHASER_REAR_PREVIEW_GAP
		_chaser_intro_look = 0.0
		_chaser_rear_intro_t = 0.0
		_chaser_rear_intro_played = false
		_chaser_rear_flash_done = false
	else:
		chaser_distance = CHASER_RELAY_INTRO_START if (_is_relay_mission() and _chaser_enabled) else CHASER_INTRO_START
	current_lateral = 0.0
	target_lane_x = 0.0
	_sync_player_position()
	_sync_chaser_from_track()
	if _pressure_chaser_enabled:
		_spawn_tide_wells_for_relay()
	_setup_hit_feedback()
	if _road_style_id == "alien_energy":
		_spawn_alien_energy_edge_particles()
	# holographic / energy_neon：关掉常驻边缘粒子，大幅减 GPU 负担
	# elif _road_style_id in ["holographic", "energy_neon"]:
	# 	_spawn_holographic_edge_particles()
	_update_hud()
	_world_ready = true

func _setup_hit_feedback() -> void:
	if _hit_feedback != null:
		return
	_hit_feedback = HitFeedback.new()
	_hit_feedback.name = "HitFeedback"
	add_child(_hit_feedback)
	if hud_root == null:
		return
	_hit_feedback.setup(hud_root, track_root if track_root else self, _cargo_hud_panel)
	_hit_feedback.shake_requested.connect(func(amount: float):
		camera_shake = maxf(camera_shake, amount)
	)

func _mark_input_handled() -> void:
	var vp := get_viewport()
	if vp != null:
		vp.set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		return

	if _settlement_celebration_active and _try_settlement_button_input(event):
		_mark_input_handled()
		return

	if _handle_touch_input(event):
		return

	if event.is_action_pressed("ui_cancel"):
		if is_finished or is_failed:
			_return_to_exploration_map()
			return
		if _pause_overlay != null:
			_pause_overlay.open_pause()
			_mark_input_handled()
		return

	if is_finished or is_failed:
		if event.is_action_pressed("jump"):
			_restart_run()
		return

	if is_intro or not gameplay_active:
		return

	# 教学暂停：任意键 / 点击 / 触屏轻点 均可继续
	if _try_dismiss_paused_coach_from_event(event):
		_mark_input_handled()
		return

	if event.is_action_pressed("move_left"):
		_try_lane_change(lane_index - 1)
	elif event.is_action_pressed("move_right"):
		_try_lane_change(lane_index + 1)
	elif event.is_action_pressed("move_backward") and (_is_on_ground() or _is_wall_running()):
		_slide_hold_wanted = true
		_try_slide()
	elif event.is_action_released("move_backward"):
		_slide_hold_wanted = false
		_request_slide_release()
	elif event.is_action_pressed("jump"):
		# 建设包双击第二下常在空中，不可再要求接地
		_try_jump()
	elif event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_F or key.physical_keycode == KEY_F:
			_toggle_shield()
			_mark_input_handled()
		elif _is_emergency_dash_key(key):
			_try_start_emergency_dash()
			_mark_input_handled()

func _is_emergency_dash_key(key: InputEventKey) -> bool:
	# Shift / E：紧急冲刺
	var code := key.keycode if key.keycode != KEY_NONE else key.physical_keycode
	var phys := key.physical_keycode
	return (
		code == KEY_SHIFT
		or phys == KEY_SHIFT
		or code == KEY_E
		or phys == KEY_E
	)

func _base_run_speed() -> float:
	return RUN_SPEED_EMERGENCY if _is_emergency_run else RUN_SPEED

func _max_run_speed() -> float:
	return RUN_SPEED_MAX_EMERGENCY if _is_emergency_run else RUN_SPEED_MAX

func _emergency_dash_hint_text() -> String:
	return "Shift/E 或点按冲刺"

func _try_dismiss_paused_coach_from_event(event: InputEvent) -> bool:
	if not _tutorial_paused or _coach_tip_key == "":
		return false
	# wall tutorial: keep waiting for the expected action
	if _tutorial_expect.begins_with("wall_"):
		return false
	if event.is_action_pressed("jump") or event.is_action_pressed("ui_accept"):
		return _dismiss_paused_coach_tip()
	if event is InputEventKey and event.pressed and not event.echo:
		return _dismiss_paused_coach_tip()
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			return _dismiss_paused_coach_tip()
	return false

func _dismiss_paused_coach_tip() -> bool:
	if _coach_tip_key == "":
		return false
	_complete_coach_tip(_coach_tip_key)
	return true

func _try_dismiss_overweight_jump_coach_from_event(event: InputEvent) -> bool:
	return _try_dismiss_paused_coach_from_event(event)

func _handle_touch_input(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			touch_active = true
			touch_start_pos = touch_event.position
			return false
		if not touch_active:
			return false
		touch_active = false
		var touch_delta := touch_event.position - touch_start_pos
		if touch_delta.length() <= TOUCH_TAP_MAX_DISTANCE:
			return _handle_mobile_tap()
		return _apply_swipe(touch_delta)

	if event is InputEventScreenDrag and touch_active:
		var drag_event := event as InputEventScreenDrag
		var drag_delta := drag_event.position - touch_start_pos
		if drag_delta.length() >= TOUCH_SWIPE_MIN_DISTANCE:
			touch_active = false
			return _apply_swipe(drag_delta)

	return false

func _handle_mobile_tap() -> bool:
	if _settlement_celebration_active:
		return false
	if is_finished or is_failed:
		_restart_run()
		return true
	if is_intro:
		intro_elapsed = INTRO_DURATION
		return true
	if gameplay_active and _is_wall_running():
		_try_jump()
		return true
	if gameplay_active and _is_overweight_cargo() and not _is_on_ground():
		if _try_overweight_full_jump_boost():
			return true
	return false

func _apply_swipe(touch_delta: Vector2) -> bool:
	if is_finished or is_failed:
		return false
	if is_intro or not gameplay_active:
		return false
	if touch_delta.length() < TOUCH_SWIPE_MIN_DISTANCE:
		return false

	if absf(touch_delta.x) > absf(touch_delta.y):
		_try_lane_change(lane_index + (1 if touch_delta.x > 0.0 else -1))
	elif touch_delta.y < 0.0:
		_try_jump()
	else:
		_try_slide()
	return true

func _notify_coach_action(action: String) -> void:
	if _coach_tip_key == "":
		return
	if action == _coach_tip_key:
		_complete_coach_tip(_coach_tip_key)
		return
	# 开盾也算完成沙尘教学
	if action == "shield" and _coach_tip_key == "sandstorm":
		_complete_coach_tip("sandstorm")
		Global.mark_runner_tutorial_seen("shield")
	# 换道也可结束沙尘/分叉提示
	elif action == "lane" and _coach_tip_key in ["fork", "sandstorm"]:
		_complete_coach_tip(_coach_tip_key)

func _tutorial_allows_action(action: String) -> bool:
	if not _tutorial_paused:
		return true
	match _tutorial_expect:
		"jump", "wall_jump":
			return action == "jump"
		"slide":
			return action == "slide"
		"lane", "fork", "wall_lane", "wall_arm":
			return action == "lane"
		"shield":
			return action == "shield"
		"sandstorm":
			return action == "shield" or action == "lane"
		_:
			return false

func _begin_tutorial_pause(expect: String) -> void:
	_tutorial_paused = true
	_tutorial_expect = expect

func _end_tutorial_pause() -> void:
	_tutorial_paused = false
	_tutorial_expect = ""

func _try_jump() -> void:
	if _is_wall_running():
		_end_slide()
		_execute_wall_jump()
		return
	# 短滑铲后可立刻起跳：承诺时长过后允许打断滑铲接跳跃
	if _is_sliding():
		if _slide_elapsed < SLIDE_MIN_COMMIT:
			return
		_end_slide()
	if not _tutorial_allows_action("jump"):
		_show_gate_toast("请按教学提示操作")
		return
	# 建设包：空中第二下补满跳（须在接地判定之前）
	if _is_overweight_cargo() and not _is_on_ground():
		if _try_overweight_full_jump_boost():
			return
		return
	if not _is_on_ground():
		return
	# 侧墙入口：贴外车道直接满跳上墙（能源包等非超重货物）
	if _wall_entry_jump_ready():
		if not _wall_mount_armed:
			_wall_mount_armed = true
			_wall_mount_armed_until_d = track_distance + 36.0
		_overweight_jump_armed = false
		_overweight_short_jump_timer = 0.0
		_execute_jump(JUMP_SPEED)
		if _is_overweight_cargo():
			_show_gate_toast("贴墙满跳 · 上侧墙")
		return
	# 侧墙教学最后一步：暂停中直接上墙，避免跳跃高度来不及结算
	if _tutorial_paused and _tutorial_expect == "wall_jump":
		vertical_velocity = JUMP_SPEED
		_end_slide()
		if player != null:
			player.position.y = GROUND_Y + 1.15
		_end_tutorial_pause()
		_try_side_runway_entry()
		if not _is_wall_running():
			# 兜底：仍未上墙则恢复教学暂停
			_begin_tutorial_pause("wall_jump")
			_refresh_wall_tut_panel(_wall_tut_side_name(_wall_tut_zone))
		return
	if _is_overweight_cargo():
		_try_overweight_ground_jump()
		return
	_execute_jump(JUMP_SPEED)

func _try_slide() -> void:
	if _is_wall_running():
		_execute_wall_slide()
		return
	if not _tutorial_allows_action("slide"):
		_show_gate_toast("请按教学提示操作")
		return
	if not _is_on_ground():
		return
	_start_slide()
	_notify_coach_action("slide")

func _execute_wall_jump() -> void:
	if not _tutorial_allows_action("jump"):
		_show_gate_toast("请按教学提示操作")
		return
	var dest := mini(lane_index + 1, WALL_LANE_HEIGHTS.size() - 1)
	lane_index = dest
	target_lane_x = 0.0
	var dest_y := float(WALL_LANE_HEIGHTS[dest])
	current_wall_y = dest_y
	if player != null:
		player.position.y = dest_y + 0.42
	vertical_velocity = JUMP_SPEED * 0.78
	_landing_pose_timer = 0.0
	_jump_takeoff_pose_timer = 0.12
	if not _uses_skeletal_run():
		body_squash_timer = 0.16
	else:
		body_squash_timer = 0.0
	_jump_fx_timer = 0.42
	camera_shake = maxf(camera_shake, 0.2)
	_set_player_pose("jump_start")
	_play_player_animation("jump", true)
	_emit_jump_takeoff_fx()
	_notify_coach_action("jump")
	_show_gate_toast("侧墙跳跃 · %s" % WALL_LANE_LABELS[dest])
	if strike_toast_label:
		strike_toast_label.modulate = Color(1.0, 0.78, 0.32, 1.0)
	strike_toast_timer = 0.85

func _execute_wall_slide() -> void:
	if not _tutorial_allows_action("slide"):
		_show_gate_toast("请按教学提示操作")
		return
	lane_index = 0
	target_lane_x = 0.0
	var dest_y := float(WALL_LANE_HEIGHTS[0])
	current_wall_y = dest_y
	if player != null:
		player.position.y = dest_y
	vertical_velocity = -6.5
	slide_timer = 0.38
	_slide_elapsed = 0.0
	_slide_hold_wanted = _is_slide_input_held()
	body_squash_timer = maxf(body_squash_timer, 0.22)
	if player_body:
		player_body.scale = Vector3(1.16, 0.78, 1.12)
	_set_player_pose("slide")
	_play_player_animation("slide", true)
	_emit_landing_particles()
	camera_shake = maxf(camera_shake, 0.2)
	_notify_coach_action("slide")
	_show_gate_toast("侧墙滑铲 · 低列")
	if strike_toast_label:
		strike_toast_label.modulate = Color(0.45, 0.88, 1.0, 1.0)
	strike_toast_timer = 0.85

func _restart_run() -> void:
	if state_restart_button != null and state_restart_button.disabled:
		return
	if _settlement_continue_locked:
		return
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if not _world_ready:
		if is_intro:
			_update_pre_run(delta)
		return

	if is_finished:
		return
	if is_failed:
		if _capture_cinematic_active:
			_update_capture_cinematic(delta)
		return

	if is_intro:
		_update_pre_run(delta)
		_sync_player_position()
		_sync_chaser_from_track()
		_update_rain_weather(delta)
		_update_rain_corrosive_puddles(delta)
		_update_runner_feedback(delta)
		_update_chaser_visuals(delta)
		_update_distant_depth_cues()
		_update_scene_dressing_visibility()
		_update_float_orbs(delta)
		_update_camera()
		_update_hud()
		return

	# 教学暂停：不推进路程，只保留换道插值/镜头/HUD，等正确操作
	if _tutorial_paused:
		if not _is_sliding():
			current_lateral = lerpf(current_lateral, target_lane_x, 1.0 - exp(-lane_change_ease * delta))
		_sync_player_position()
		_sync_chaser_from_track()
		_update_shield_energy_drain(delta)
		_update_shield_visual(delta)
		_update_runner_feedback(delta)
		_pulse_wall_tut_markers(delta)
		_refresh_active_tutorial_panel()
		_update_camera()
		_update_hud()
		return

	elapsed += delta
	current_speed = lerpf(_base_run_speed(), _max_run_speed(), clampf(elapsed / _run_time, 0.0, 1.0))
	if speed_penalty_timer > 0.0:
		speed_penalty_timer = maxf(speed_penalty_timer - delta, 0.0)
		if speed_penalty_timer == 0.0:
			speed_penalty_mult = 1.0
	if _hit_iframe_timer > 0.0:
		_hit_iframe_timer = maxf(_hit_iframe_timer - delta, 0.0)
	_update_slide_timer(delta)
	if _overweight_short_jump_timer > 0.0:
		_overweight_short_jump_timer = maxf(_overweight_short_jump_timer - delta, 0.0)
		if _overweight_short_jump_timer <= 0.0:
			_overweight_jump_armed = false
	if _fork_rush_timer > 0.0:
		_fork_rush_timer = maxf(_fork_rush_timer - delta, 0.0)
	var rush_zone := _fork_zone_at(track_distance)
	if _fork_side > 0 and not rush_zone.is_empty() and String(rush_zone.get("effect_b", "")) == "fast":
		_fork_rush_elapsed += delta
	elif _fork_rush_elapsed > 0.0 and (rush_zone.is_empty() or _fork_side != 1):
		_fork_rush_elapsed = 0.0
	if _speed_boost_timer > 0.0:
		_speed_boost_timer = maxf(_speed_boost_timer - delta, 0.0)
	if _finish_sprint_timer > 0.0:
		_finish_sprint_timer = maxf(_finish_sprint_timer - delta, 0.0)
	if _coin_streak_timer > 0.0:
		_coin_streak_timer = maxf(_coin_streak_timer - delta, 0.0)
		if _coin_streak_timer <= 0.0:
			_coin_streak_count = 0
	if _emergency_dash_timer > 0.0:
		_emergency_dash_timer = maxf(_emergency_dash_timer - delta, 0.0)
	if _speed_feel_punch > 0.0:
		_speed_feel_punch = maxf(_speed_feel_punch - delta * 2.4, 0.0)

	var effective_speed := current_speed * speed_penalty_mult * _effective_speed_boost_mult()
	if not _is_on_ground() and not _is_wall_running() and not _is_sliding() and not _is_safe_launch_flight():
		effective_speed *= AIR_FORWARD_SPEED_MULT
	# 岔路横向外撇会拉长实际路程；平滑弧长补偿，避免忽快忽慢
	var path_stretch := _path_world_stretch(track_distance, current_lateral)
	_path_stretch_smooth = lerpf(_path_stretch_smooth, path_stretch, 1.0 - exp(-7.5 * delta))
	var dist_from := track_distance
	track_distance += (effective_speed / _path_stretch_smooth) * delta
	_update_chaser(delta)
	_check_fork_approach()
	_check_junctions()
	_apply_fork_branch_lateral_snap()
	_check_y_fork_approach()
	_check_y_forks()
	if not _is_sliding():
		var lane_ease := lane_change_ease
		# 空中大幅削弱换道，加速段几乎锁死横向，避免跳起来飘太远
		if not _is_on_ground() and not _is_wall_running():
			if _is_launch_air_locked():
				lane_ease *= 0.02
			else:
				lane_ease *= AIR_LANE_CHANGE_RUSH_MULT if _is_fork_rushing() else AIR_LANE_CHANGE_MULT
		current_lateral = lerpf(current_lateral, target_lane_x, 1.0 - exp(-lane_ease * delta))

	if _is_wall_running():
		var target_wy: float = float(WALL_LANE_HEIGHTS[clampi(lane_index, 0, WALL_LANE_HEIGHTS.size() - 1)])
		current_wall_y = lerpf(current_wall_y, target_wy, 1.0 - exp(-lane_change_ease * delta))
		vertical_velocity -= GRAVITY * 0.42 * delta
		var next_y := player.position.y + vertical_velocity * delta
		var ceiling: float = float(WALL_LANE_HEIGHTS[WALL_LANE_HEIGHTS.size() - 1]) + 1.35
		if next_y <= current_wall_y and vertical_velocity <= 0.0:
			next_y = current_wall_y
			vertical_velocity = 0.0
		player.position.y = minf(next_y, ceiling)
	else:
		vertical_velocity -= GRAVITY * delta
		var ground_y := _ground_y_at(track_distance)
		var next_y := player.position.y + vertical_velocity * delta
		var over_pit := _is_over_open_pit()
		if over_pit:
			var launch_gap := _open_gap_kind_at(track_distance) == "launch"
			if _pit_fall_grace <= 0.0:
				_pit_fall_grace = 0.28 if launch_gap else 0.72
			_pit_fall_grace = maxf(_pit_fall_grace - delta, 0.0)
			_try_pit_entry_wall_rescue()
			var plat_support := _lava_platform_landing_y(next_y, track_distance, current_lateral)
			var elevated_plat := plat_support > ground_y + 0.28
			var can_snap_plat := plat_support > ground_y - 0.35 and next_y <= plat_support + 0.16
			if elevated_plat:
				can_snap_plat = can_snap_plat and vertical_velocity <= -0.42
			else:
				can_snap_plat = can_snap_plat and vertical_velocity <= 0.22
			if can_snap_plat:
				next_y = plat_support
				vertical_velocity = 0.0
				_pit_fall_grace = 0.42
				player.position.y = next_y
			else:
				# 真正坠落：不要先陷 2cm 再掉，否则会透过全息网格看见熔岩又弹回来
				if next_y <= ground_y and vertical_velocity > -4.0 and not _is_safe_launch_flight():
					vertical_velocity = -8.5
				if _is_safe_launch_flight() and _open_gap_kind_at(track_distance) == "launch":
					# 只在明显腾空时保高度；贴近路面则继续下落进坑
					var glide_y := ground_y + 1.35
					if next_y < glide_y and player.position.y > ground_y + 1.1:
						next_y = maxf(next_y, ground_y + 0.95)
						vertical_velocity = maxf(vertical_velocity, -2.4)
				player.position.y = next_y
			if player.position.y < ground_y - 0.55 and _pit_fall_grace <= 0.0 and not _is_safe_launch_flight():
				_fail_into_pit()
			elif (
				_open_gap_kind_at(track_distance) == "launch"
				and player.position.y <= ground_y + 0.35
				and _pit_fall_grace <= 0.0
				and not _is_safe_launch_flight()
			):
				_fail_into_pit("坠入弹射熔岩缺口")
		elif next_y <= ground_y and vertical_velocity <= 0.0:
			_pit_fall_grace = 0.0
			var plat_stand := _lava_platform_landing_y(next_y, track_distance, current_lateral)
			next_y = plat_stand if plat_stand > ground_y - 0.12 else ground_y
			vertical_velocity = 0.0
			player.position.y = next_y
		else:
			_pit_fall_grace = 0.0
			player.position.y = next_y
		if _is_sliding():
			var plat_y := _lava_platform_surface_under_player()
			if plat_y > ground_y + 0.32:
				pass
			elif plat_y > ground_y - 0.05:
				player.position.y = plat_y
			elif not over_pit:
				player.position.y = ground_y
			vertical_velocity = 0.0

	_try_trigger_launch_pads()
	_update_lift_pad_visuals()
	_update_mechanic_lab_hints()
	_update_launch_pad_approach_hints()
	_check_ramps()
	_maybe_auto_arm_wall_mount()
	_try_side_runway_entry()
	_enforce_track_layer()
	_sync_player_position()
	_sync_chaser_from_track()
	_update_moving_obstacles(delta)
	_update_float_orbs(delta)
	_update_meteor_fall_roll(delta)
	_update_meteorite_gate_drops(delta)
	_update_train_blade_gates()
	_update_train_moving_props(delta)
	_update_procedural_obstacle_fx(delta)
	_update_lava_platform_hint(delta)
	_sync_fork_branch_obstacle_visibility()
	_update_side_runway_ground_penalty(delta)
	_update_wall_jump_center_hint(delta)
	_update_wall_run_tutorial(delta)
	_update_runner_coach_tips(delta)
	_update_sandstorm_hazard(delta)
	_update_rain_weather(delta)
	_update_rain_corrosive_puddles(delta)
	_update_shield_energy_drain(delta)
	_update_shield_visual(delta)

	var grounded := _is_on_ground()
	if not grounded:
		_peak_air_vy = minf(_peak_air_vy, vertical_velocity)
	elif not was_on_ground:
		var big_land := _peak_air_vy < -4.2
		_landing_pose_timer = 0.24 if big_land else 0.20
		if _uses_skeletal_run():
			body_squash_timer = 0.22 if big_land else 0.16
			camera_shake = maxf(camera_shake, 0.09 if big_land else 0.035)
			if big_land and _land_fx_cd <= 0.0:
				_emit_landing_particles()
				_land_fx_cd = 0.32
		else:
			body_squash_timer = 0.12
			camera_shake = maxf(camera_shake, 0.16)
			_emit_landing_particles()
		_air_pose_grace = 0.0
		_jump_takeoff_pose_timer = 0.0
		_set_player_pose("landing")
		_peak_air_vy = 0.0
		_overweight_jump_armed = false
		_overweight_short_jump_timer = 0.0
	was_on_ground = grounded

	_update_runner_feedback(delta)
	_update_chaser_visuals(delta)
	_update_collectible_magnet(delta)
	_update_coin_collectible_visuals(delta)
	_check_collectibles()
	_update_tide_wells(delta)
	_update_sky_cheer_spawns()
	_update_sky_cheer_visuals(delta)
	_check_finish_sprint_pads()
	_check_obstacles(dist_from, track_distance)
	_update_env_hazards(delta)
	_check_chaser_caught()

	if track_distance >= _effective_finish_distance():
		_finish_run()
	elif elapsed >= _run_time and bool(_mission_profile.get("timed_fail", false)):
		_fail_run("限时到达失败")

	_update_distant_depth_cues()
	_update_scene_dressing_visibility()
	_update_finish_outpost_approach(delta)
	_update_runner_sky_presentation(delta)
	_update_reservoir_sky_dome()
	_update_camera()
	_update_hud()

func _process(delta: float) -> void:
	_coin_hud_flash_cd = maxf(_coin_hud_flash_cd - delta, 0.0)
	_land_fx_cd = maxf(_land_fx_cd - delta, 0.0)
	if settlement_detail_timer > 0.0:
		settlement_detail_timer = maxf(settlement_detail_timer - delta, 0.0)
		if settlement_detail_timer == 0.0 and pending_settlement_title != "":
			_show_state(pending_settlement_title, pending_settlement_body)
			pending_settlement_title = ""
			pending_settlement_body = ""
	for collectible in collectibles:
		if collectible["collected"]:
			continue
		var node := collectible["node"] as Node3D
		if node == null or not is_instance_valid(node):
			continue
		node.rotate_y(delta * 6.0)
		node.rotate_z(delta * 1.7)

func _try_lane_change(next_lane_index: int) -> void:
	if not _tutorial_allows_action("lane"):
		_show_gate_toast("请按教学提示操作")
		return
	if _is_launch_air_locked():
		_show_gate_toast("弹射中 · 先落地再换道")
		return
	if _is_sliding():
		_end_slide()
	# 主路最外道再朝侧墙按一次 = 预备上墙（不自动吸附）
	if track_layer == 0 and _try_arm_wall_mount(next_lane_index):
		_on_wall_tutorial_action("arm")
		return
	if next_lane_index < 0 or next_lane_index >= LANES.size():
		return
	_wall_mount_armed = false
	_set_lane(next_lane_index)
	_on_wall_tutorial_action("lane")
	_notify_coach_action("lane")

func _wall_edge_lane_index(zone: Dictionary) -> int:
	return 2 if _wall_zone_side(zone, track_distance) > 0.0 else 0

func _try_arm_wall_mount(requested_lane: int) -> bool:
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		_wall_mount_armed = false
		return false
	var wall_side := _wall_zone_side(zone, track_distance)
	var edge := _wall_edge_lane_index(zone)
	var toward_wall := (wall_side > 0.0 and requested_lane > lane_index) or (wall_side < 0.0 and requested_lane < lane_index)
	if lane_index != edge or not toward_wall:
		return false
	_wall_mount_armed = true
	_wall_mount_armed_until_d = track_distance + 36.0
	_show_gate_toast("贴墙就绪 · 跳跃上墙")
	return true

func _is_wall_mount_ready(zone: Dictionary) -> bool:
	if not _wall_mount_armed:
		return false
	if track_distance > _wall_mount_armed_until_d:
		_wall_mount_armed = false
		return false
	return lane_index == _wall_edge_lane_index(zone)

## 能源包等非超重关卡：贴外车道进入入口区即自动就绪，少一步「再朝墙按」
func _maybe_auto_arm_wall_mount() -> void:
	if _is_overweight_cargo() or track_layer != 0 or player == null:
		return
	if _skip_side_runway_while_on_fork_branch():
		return
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		return
	if lane_index != _wall_edge_lane_index(zone):
		return
	if not _wall_mount_armed:
		_wall_mount_armed = true
		_wall_mount_armed_until_d = track_distance + 42.0

func _nearest_lane_index(lateral: float) -> int:
	var best_index := 0
	var best_dist := INF
	for i in LANES.size():
		var lane_x := float(LANES[i]) * LANE_WIDTH
		var dist := absf(lateral - lane_x)
		if dist < best_dist:
			best_dist = dist
			best_index = i
	return best_index

func _layer_height(layer: int) -> float:
	return LAYER_HEIGHTS[clampi(layer, 0, LAYER_HEIGHTS.size() - 1)]

func _is_gate_lab_mission() -> bool:
	return _mission_id_str() == "mission_gate_lab" or _runner_layout_id() == "mission_gate_lab"

func _ensure_mechanic_layout() -> void:
	if _mechanic_layout_ready:
		return
	_mechanic_layout_ready = true
	_path_height_keys.clear()
	_launch_pads.clear()
	_width_zones.clear()
	_open_gaps.clear()
	var layout_id := _runner_layout_id()
	if layout_id == "":
		return
	var root: Dictionary = ObstacleLayout.load_root(layout_id)
	for raw in root.get("height_keys", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		_path_height_keys.append({
			"d": float(raw.get("d", raw.get("distance", 0.0))),
			"y": float(raw.get("y", raw.get("lift", 0.0))),
		})
	_path_height_keys.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("d", 0.0)) < float(b.get("d", 0.0))
	)
	for raw in root.get("launch_pads", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var pad_lane := clampi(int(raw.get("lane", 0)), -1, 1)
		_launch_pads.append({
			"id": String(raw.get("id", "launch_%d" % _launch_pads.size())),
			"distance": float(raw.get("distance", 0.0)),
			"lane": pad_lane,
			"impulse": float(raw.get("impulse", JUMP_SPEED * 1.45)),
			"half_depth": float(raw.get("half_depth", 1.6)),
			"lock_air_lane": bool(raw.get("lock_air_lane", true)),
			"lock_distance": float(raw.get("lock_distance", 28.0)),
			"speed_boost": bool(raw.get("speed_boost", false)),
			"boost_time": float(raw.get("boost_time", 2.4)),
			"launch_cross": bool(raw.get("launch_cross", false)),
			"hint": String(raw.get("hint", "弹射")),
			"pad_text": String(raw.get("pad_text", "")),
		})
	for raw in root.get("width_zones", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		_width_zones.append({
			"start": float(raw.get("start", 0.0)),
			"length": float(raw.get("length", 40.0)),
			"half_width": float(raw.get("half_width", 1.25)),
		})
	for raw in root.get("open_gaps", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var start := float(raw.get("start", 0.0))
		var end := float(raw.get("end", start + float(raw.get("length", 0.0))))
		if end > start + 1.5:
			_open_gaps.append({
				"start": start,
				"end": end,
				"kind": String(raw.get("kind", "")),
			})
	_resolve_lava_crossing_conflicts()

func _path_height_lift_at(distance: float) -> float:
	_ensure_mechanic_layout()
	if _path_height_keys.is_empty():
		return 0.0
	var d := distance
	var first: Dictionary = _path_height_keys[0]
	if d <= float(first.get("d", 0.0)):
		return float(first.get("y", 0.0))
	var last: Dictionary = _path_height_keys[_path_height_keys.size() - 1]
	if d >= float(last.get("d", 0.0)):
		return float(last.get("y", 0.0))
	for i in range(_path_height_keys.size() - 1):
		var a: Dictionary = _path_height_keys[i]
		var b: Dictionary = _path_height_keys[i + 1]
		var da := float(a.get("d", 0.0))
		var db := float(b.get("d", 0.0))
		if d >= da and d <= db:
			var t := 0.0 if db <= da + 0.0001 else clampf((d - da) / (db - da), 0.0, 1.0)
			t = t * t * (3.0 - 2.0 * t)
			return lerpf(float(a.get("y", 0.0)), float(b.get("y", 0.0)), t)
	return 0.0

func _ground_y_at(distance: float) -> float:
	return GROUND_Y + _path_height_lift_at(distance)

func _width_zone_at(distance: float) -> Dictionary:
	_ensure_mechanic_layout()
	for zone in _width_zones:
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 0.0))
		if distance >= start and distance <= start + length:
			return zone
	return {}

func _is_on_narrow_beam(distance: float = NAN, lateral: float = NAN) -> bool:
	var d := track_distance if is_nan(distance) else distance
	var lat := current_lateral if is_nan(lateral) else lateral
	var zone := _width_zone_at(d)
	if zone.is_empty():
		return false
	return absf(lat) <= float(zone.get("half_width", 1.2)) - 0.08

func _is_off_narrow_beam() -> bool:
	var zone := _width_zone_at(track_distance)
	if zone.is_empty():
		return false
	return not _is_on_narrow_beam()

func _open_gap_kind_at(distance: float) -> String:
	_ensure_mechanic_layout()
	for gap in _open_gaps:
		if distance >= float(gap.get("start", 0.0)) and distance <= float(gap.get("end", 0.0)):
			return String(gap.get("kind", ""))
	return ""

func _is_launch_air_locked() -> bool:
	return _launch_air_lock_until_d > track_distance and not _is_on_ground() and not _is_wall_running()

func _is_safe_launch_flight() -> bool:
	# 仅「腾空飞过」算安全；落在缺口玻璃/地面高度上必须坠坑
	if _launch_air_lock_until_d <= track_distance or _is_wall_running():
		return false
	if player == null:
		return false
	var ground_y := _ground_y_at(track_distance)
	if player.position.y <= ground_y + 1.05:
		return false
	if _open_gap_kind_at(track_distance) == "launch":
		return true
	if player.position.y > ground_y + 0.85:
		return true
	return vertical_velocity > 2.2

func _lift_pad_surface_y(plat: Dictionary, dist: float = NAN) -> float:
	var d := track_distance if is_nan(dist) else dist
	var base := float(plat.get("base_y", plat.get("surface_y", GROUND_Y)))
	var amp := float(plat.get("bob_amp", plat.get("amp", 0.0)))
	if amp <= 0.001:
		return base
	var period := maxf(float(plat.get("bob_period_m", plat.get("period_m", 32.0))), 8.0)
	var phase := float(plat.get("bob_phase", plat.get("phase", 0.0)))
	return base + amp * sin((d / period) * TAU + phase)

func _is_wall_running() -> bool:
	return track_layer == WALL_RUN_LAYER

func _is_on_ground() -> bool:
	if _is_wall_running():
		return absf(player.position.y - current_wall_y) <= 0.08 and vertical_velocity <= 0.01
	var plat_y := _lava_platform_surface_under_player()
	if plat_y > GROUND_Y - 0.25 and player.position.y <= plat_y + 0.14 and vertical_velocity <= 0.01:
		return true
	return player.position.y <= _ground_y_at(track_distance) + 0.02 and vertical_velocity <= 0.01

func _player_in_air_pose(delta: float) -> bool:
	# 防抖：避免主路微颠簸把骨骼跑切到静态跳跃姿势（角色会闪没）
	if _is_sliding() or _is_wall_running() or _landing_pose_timer > 0.0:
		_air_pose_grace = 0.0
		return false
	# 已落地：立刻结束空中姿势，避免 grace 期间卡在 jump_peak
	if _is_on_ground() and vertical_velocity <= 0.08:
		_air_pose_grace = 0.0
		return false
	var airborne := (not _is_on_ground()) or vertical_velocity > 1.6
	if airborne:
		_air_pose_grace = 0.18
	elif _air_pose_grace > 0.0:
		_air_pose_grace = maxf(_air_pose_grace - delta, 0.0)
	return _air_pose_grace > 0.0

func _player_run_visual_height() -> float:
	if _skeletal_run_enabled:
		return PLAYER_SKELETAL_MODEL_HEIGHT
	return PLAYER_MODEL_HEIGHT


func _restore_player_pose_facing() -> void:
	if player_pose_root == null:
		return
	player_pose_root.rotation.x = 0.0
	player_pose_root.rotation.y = _player_pose_base_yaw
	player_pose_root.rotation.z = 0.0


func _fit_slide_pose_to_runner(slide_root: Node3D) -> void:
	if slide_root == null:
		return
	# 滑铲 GLB 是躺姿：不能套用跑步 scale，否则模型后端会顶进相机里形成「头顶阴影」
	slide_root.scale = Vector3.ONE
	slide_root.rotation_degrees.x = 0.0
	slide_root.rotation_degrees.z = 0.0
	var bounds := _compute_node_aabb(slide_root)
	if bounds.size.y > 0.001:
		var sy := PLAYER_SLIDE_CROUCH_HEIGHT / bounds.size.y
		slide_root.scale = Vector3.ONE * sy
	slide_root.force_update_transform()
	bounds = _compute_node_aabb(slide_root)
	if bounds.size.z > PLAYER_SLIDE_MAX_DEPTH and bounds.size.z > 0.001:
		slide_root.scale.z *= PLAYER_SLIDE_MAX_DEPTH / bounds.size.z
		slide_root.force_update_transform()
		bounds = _compute_node_aabb(slide_root)
	var anchor_x := player_pose_root.position.x if player_pose_root else -(bounds.position.x + bounds.size.x * 0.5)
	var anchor_z := player_pose_root.position.z if player_pose_root else -(bounds.position.z + bounds.size.z * 0.5)
	# 略往前推，避免躺姿后端 (+Z) 穿进身后相机
	slide_root.position = Vector3(anchor_x, -bounds.position.y, anchor_z - bounds.size.z * 0.22)
	_player_slide_base_y = slide_root.position.y
	for node in slide_root.find_children("*", "MeshInstance3D", true, false):
		(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _stabilize_slide_pose_visual() -> void:
	if player_slide_pose_root == null or not _is_sliding():
		return
	_fit_slide_pose_to_runner(player_slide_pose_root)

func _clamp_player_body_scale() -> void:
	if player_body == null:
		return
	var s := player_body.scale
	s.x = clampf(s.x, 0.88, 1.32)
	s.y = clampf(s.y, 0.9, 1.28)
	s.z = clampf(s.z, 0.88, 1.32)
	player_body.scale = s

func _wall_lane_height_for_lane_value(lane: int) -> float:
	var idx := _lane_value_to_index(lane)
	return WALL_LANE_HEIGHTS[clampi(idx, 0, WALL_LANE_HEIGHTS.size() - 1)]

func _distance_to_z(distance: float) -> float:
	# 兼容旧调用：仅直线近似，优先使用 _sample_path
	return _sample_path(distance)["pos"].z

func _active_track_segments() -> Array:
	if CustomLevels.has_level(Global.runner_location_id) and CustomLevels.has_custom_track(Global.runner_location_id):
		return CustomLevels.get_track_segments(Global.runner_location_id)
	var layout_id := _runner_layout_id()
	if layout_id != "":
		var layout_segments: Array = ObstacleLayout.load_track_segments(layout_id)
		if not layout_segments.is_empty():
			return layout_segments
	if LevelConfig != null and LevelConfig.has_method("get_track_segments"):
		return LevelConfig.get_track_segments()
	return []

func _is_distance_on_track_turn(distance: float, pad: float = 14.0) -> bool:
	# 弯道/Y叉上障碍容易偏出路面，碰撞按路程仍生效，看起来就像撞空气
	var cursor := 0.0
	for raw in _active_track_segments():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = raw
		var length := float(seg.get("length", 0.0))
		var is_turn := absf(float(seg.get("turn", 0.0))) > 0.08
		var is_fork := String(seg.get("type", "")) == "y_fork"
		if (is_turn or is_fork) and distance >= cursor - pad and distance <= cursor + length + pad:
			return true
		cursor += length
	return false

func _junction_zones() -> Array:
	if CustomLevels.has_level(Global.runner_location_id) and CustomLevels.has_custom_junctions(Global.runner_location_id):
		return CustomLevels.get_junction_zones(Global.runner_location_id)
	var layout_id := _runner_layout_id()
	if layout_id != "":
		var out_layout: Array = []
		for raw in ObstacleLayout.load_junction_zones(layout_id):
			if typeof(raw) == TYPE_DICTIONARY:
				out_layout.append(ObstacleLayout.normalize_junction_zone(raw))
		if not out_layout.is_empty():
			return out_layout
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if not constants.has("JUNCTION_ZONES"):
		return []
	var out: Array = []
	for raw in constants["JUNCTION_ZONES"]:
		if typeof(raw) == TYPE_DICTIONARY:
			out.append(ObstacleLayout.normalize_junction_zone(raw))
	return out

func _bake_track_path() -> void:
	var segments: Array = _active_track_segments()
	var baked: Dictionary = ObstacleLayout.bake_path_from_segments(segments, 2.0)
	_path_samples.clear()
	for s in baked.get("samples", []):
		if typeof(s) == TYPE_DICTIONARY:
			_path_samples.append(s)
	_path_length = float(baked.get("length", 0.0))
	_y_fork_regions = ObstacleLayout.bake_y_fork_regions(segments, 2.0)
	if _path_length < _track_length:
		# 不足时直线补齐到终点
		var pos: Vector3 = baked.get("end_pos", Vector3.ZERO)
		var yaw := float(baked.get("end_yaw", 0.0))
		var dist := _path_length
		var remain := _track_length + 40.0 - _path_length
		var step := 2.0
		var steps2 := maxi(1, int(ceil(remain / step)))
		var ds2 := remain / float(steps2)
		var forward2 := Vector3(-sin(yaw), 0.0, -cos(yaw))
		for _j in steps2:
			pos += forward2 * ds2
			dist += ds2
			_path_samples.append({"d": dist, "pos": pos, "yaw": yaw})
		_path_length = dist
	_bake_junction_fork_regions()

func _bake_junction_fork_regions() -> void:
	_junction_fork_regions.clear()
	var step := 2.0
	var lead := 14.0
	for zone in _junction_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var start := float(zone.get("distance", 0.0))
		var length := float(zone.get("length", 70.0))
		var spread := float(zone.get("spread", 18.0))
		var left_samples: Array = []
		var right_samples: Array = []
		var d := start - lead
		var end_d := start + length + lead
		while d <= end_d + 0.001:
			var main := _sample_path_samples(_path_samples, d)
			var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
			var envelope := _fork_envelope(t)
			var pos_l: Vector3 = main["pos"] + (main["right"] as Vector3) * (-spread * envelope)
			var pos_r: Vector3 = main["pos"] + (main["right"] as Vector3) * (spread * envelope)
			var yaw := float(main["yaw"])
			left_samples.append({"d": d, "pos": pos_l, "yaw": yaw})
			right_samples.append({"d": d, "pos": pos_r, "yaw": yaw})
			d += step
		_junction_fork_regions.append({
			"d_start": start - lead,
			"d_end": start + length + lead,
			"left": left_samples,
			"right": right_samples,
		})

func _junction_fork_region_at(distance: float) -> Dictionary:
	for region in _junction_fork_regions:
		if typeof(region) != TYPE_DICTIONARY:
			continue
		var d0 := float(region.get("d_start", 0.0))
		var d1 := float(region.get("d_end", 0.0))
		if distance >= d0 and distance <= d1:
			return region
	return {}

func _side_runway_path_locks_main_road(distance: float) -> bool:
	# 墙跑 mesh 只在主路径上；但已选岔路且仍在 junction 分支区时，地面应沿岔路走
	if _is_wall_running():
		return true
	if _fork_side != 0 and not _junction_fork_region_at(distance).is_empty():
		return false
	if not _side_runway_wall_zone_at(distance).is_empty():
		return true
	if not _side_runway_entry_zone(distance).is_empty():
		return true
	return false

func _skip_side_runway_while_on_fork_branch() -> bool:
	return _fork_side != 0 and not _junction_fork_region_at(track_distance).is_empty()

func _sample_path(distance: float) -> Dictionary:
	if _path_samples.is_empty():
		_bake_track_path()
	var d := clampf(distance, 0.0, maxf(_path_length, 0.0))
	if _side_runway_path_locks_main_road(d):
		return _sample_path_samples(_path_samples, d)
	# Y 分叉选右岔时，改采右支几何（左支已烘焙进主路径）
	if _y_fork_side_at(d) > 0:
		var region := _y_fork_region_at(d)
		var right_samples: Array = region.get("right", [])
		if right_samples.size() >= 2:
			return _sample_path_samples(right_samples, d)
	# 横向 junction 岔：沿烘焙岔路 polyline 采样，避免直线侧偏冲出路面
	if _fork_side != 0:
		var j_region := _junction_fork_region_at(d)
		if not j_region.is_empty():
			var branch_key := "right" if _fork_side > 0 else "left"
			var branch_samples: Array = j_region.get(branch_key, [])
			if branch_samples.size() >= 2:
				return _sample_path_samples(branch_samples, d)
	return _sample_path_samples(_path_samples, d)

func _sample_path_for_obstacle(distance: float, fork_branch: int = 0) -> Dictionary:
	# 障碍锚定在关卡几何上，不随玩家当前 _fork_side / 车道预览漂移
	if _path_samples.is_empty():
		_bake_track_path()
	var d := clampf(distance, 0.0, maxf(_path_length, 0.0))
	if fork_branch != 0:
		var y_region := _y_fork_region_at(d)
		if not y_region.is_empty():
			if fork_branch > 0:
				var y_right: Array = y_region.get("right", [])
				if y_right.size() >= 2:
					return _sample_path_samples(y_right, d)
			return _sample_path_samples(_path_samples, d)
		var j_region := _junction_fork_region_at(d)
		if not j_region.is_empty():
			var branch_key := "right" if fork_branch > 0 else "left"
			var branch_samples: Array = j_region.get(branch_key, [])
			if branch_samples.size() >= 2:
				return _sample_path_samples(branch_samples, d)
	return _sample_path_samples(_path_samples, d)

func _fork_adjusted_lateral_for_obstacle(distance: float, lateral: float, fork_branch: int) -> float:
	if fork_branch != 0:
		return lateral
	if not _y_fork_region_at(distance).is_empty():
		return lateral
	if not _junction_fork_region_at(distance).is_empty():
		return lateral
	var zone := _fork_zone_at(distance)
	if zone.is_empty():
		return lateral
	if absf(lateral) < 0.01:
		return lateral
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var envelope := _fork_envelope(t)
	if envelope <= 0.001:
		return lateral
	var spread := float(zone.get("spread", 10.0))
	var side := -1 if lateral < 0.0 else 1
	var branch_center := float(side) * spread * envelope
	return branch_center + lateral

func _world_on_path_for_obstacle(distance: float, lateral: float, y: float, content_layer: int, fork_branch: int = 0) -> Dictionary:
	var sample := _sample_path_for_obstacle(distance, fork_branch)
	var x := _fork_adjusted_lateral_for_obstacle(distance, lateral, fork_branch)
	if content_layer == WALL_RUN_LAYER:
		var zone := _side_runway_zone_at(distance)
		if not zone.is_empty():
			return _world_on_wall(
				distance,
				_wall_zone_side(zone, distance),
				_effective_wall_lateral_offset(zone),
				y
			)
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * x
	pos.y = y
	return {"pos": pos, "yaw": float(sample["yaw"]), "forward": sample["forward"], "right": sample["right"]}

func _sample_path_samples(samples: Array, distance: float) -> Dictionary:
	if samples.is_empty():
		return _pack_path_sample(Vector3.ZERO, 0.0)
	var d := distance
	if samples.size() == 1:
		var only: Dictionary = samples[0]
		var only_pos: Vector3 = only["pos"]
		only_pos.y = _path_height_lift_at(d)
		return _pack_path_sample(only_pos, float(only["yaw"]))
	var lo := 0
	var hi := samples.size() - 1
	while lo < hi - 1:
		var mid := (lo + hi) >> 1
		if float((samples[mid] as Dictionary)["d"]) <= d:
			lo = mid
		else:
			hi = mid
	var a: Dictionary = samples[lo]
	var b: Dictionary = samples[hi]
	var da := float(a["d"])
	var db := float(b["d"])
	var t := 0.0 if db <= da + 0.0001 else clampf((d - da) / (db - da), 0.0, 1.0)
	var pos: Vector3 = (a["pos"] as Vector3).lerp(b["pos"] as Vector3, t)
	var yaw := lerp_angle(float(a["yaw"]), float(b["yaw"]), t)
	pos.y = _path_height_lift_at(d)
	return _pack_path_sample(pos, yaw)

func _pack_path_sample(pos: Vector3, yaw: float) -> Dictionary:
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := forward.cross(Vector3.UP).normalized()
	return {"pos": pos, "yaw": yaw, "forward": forward, "right": right}

func _path_world_stretch(distance: float, lateral: float) -> float:
	# |d世界位置 / d track_distance|：平路≈1，岔路外扩/收回时 >1
	if _fork_zone_at(distance).is_empty():
		return 1.0
	# 速通岔：完全不吃弧长补偿，过 SPEEDUP 立刻有加速感
	if _is_fork_rushing():
		return 1.0
	var eps := 0.75
	var a: Vector3 = _world_on_path(distance, lateral, GROUND_Y)["pos"]
	var b: Vector3 = _world_on_path(distance + eps, lateral, GROUND_Y)["pos"]
	var world_step := a.distance_to(b)
	return clampf(world_step / eps, 0.55, 2.4)

func _fork_zone_at(distance: float) -> Dictionary:
	for zone in _junction_zones():
		var start := float(zone["distance"])
		var length := float(zone.get("length", 70.0))
		if distance >= start and distance <= start + length:
			return zone
	return {}

func _fork_adjusted_lateral(distance: float, lateral: float) -> float:
	# 侧墙区强制主路几何，车道偏移不再叠加岔路 spread
	if _side_runway_path_locks_main_road(distance):
		return lateral
	# Y 岔 / junction 岔路几何已烘焙进 branch samples，只保留车道偏移
	if _y_fork_side_at(distance) > 0:
		return lateral
	if _fork_side != 0 and not _junction_fork_region_at(distance).is_empty():
		return lateral
	# 岔路仍保留三道：branch_center + (-4/0/+4)；中间空隙禁跑
	var zone := _fork_zone_at(distance)
	if zone.is_empty():
		return lateral
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var envelope := _fork_envelope(t)
	if envelope <= 0.001:
		return lateral
	var spread := float(zone.get("spread", 10.0))
	var side := _resolve_fork_side(lateral)
	if side == 0 and _fork_side != 0:
		side = _fork_side
	var branch_center := float(side) * spread * envelope
	# 主路挖空段 / 已锁岔：抬高最小 envelope，保证落岔中心
	if _fork_side != 0 and envelope > 0.08:
		var floor_v := 0.62 if _is_in_fork_main_gap(distance) else 0.42
		if _is_fork_rushing():
			floor_v = maxf(floor_v, 0.72)
		envelope = maxf(envelope, floor_v)
		branch_center = float(side) * spread * envelope
	return branch_center + lateral

func _is_full_width_obstacle_type(obstacle_type: String) -> bool:
	return obstacle_type in ["slide", "high_bar", "jump", "low_barrier", "main_block", "ramp", "wave_arc_slide"]

func _runway_half_width() -> float:
	match _road_style_id:
		"holographic":
			return 6.0
		"energy_neon":
			return 6.4
		"alien_energy":
			return 6.0
		"coarse_desert":
			return 6.5
		_:
			return 6.3

func _runway_obstacle_span_at(_distance: float = 0.0) -> float:
	return _runway_half_width() * 2.0 * RUNWAY_OBSTACLE_SPAN_INSET

func _slide_gate_model_pillar_half(asset_path: String) -> float:
	var lower := asset_path.to_lower()
	if "能量屏障" in asset_path or ("energy" in lower and "barrier" in lower):
		return 0.46
	return 0.5

func _slide_gate_span_at(_distance: float = 0.0, asset_path: String = "") -> float:
	# 按模型底座实际位置缩放，让立柱落在跑道外缘/路肩上，横梁仍横跨整路
	var pillar_half := _runway_half_width() + SLIDE_GATE_PILLAR_OUTSIDE_MARGIN
	var model_pillar_half := _slide_gate_model_pillar_half(asset_path)
	return pillar_half * SLIDE_GATE_MODEL_BBOX_WIDTH / maxf(model_pillar_half, 0.001)

func _fork_branch_center_lateral(distance: float) -> float:
	var zone := _fork_zone_at(distance)
	if zone.is_empty():
		return 0.0
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var envelope := _fork_envelope(t)
	if envelope <= 0.001:
		return 0.0
	var spread := float(zone.get("spread", 10.0))
	var side := _fork_side
	if side == 0:
		side = _resolve_fork_side(current_lateral)
	return float(side) * spread * envelope

func _full_width_obstacle_lateral(distance: float) -> float:
	# 与 _place_obstacle_node 全宽分支一致：岔路已烘焙进 path 时不再叠 spread
	if _fork_zone_at(distance).is_empty():
		return 0.0
	if _fork_side != 0 and not _junction_fork_region_at(distance).is_empty():
		return 0.0
	if _y_fork_side_at(distance) > 0:
		return 0.0
	return _fork_adjusted_lateral(distance, 0.0)

func _world_on_path_absolute(distance: float, lateral: float, y: float, content_layer: int = -1) -> Dictionary:
	var sample := _sample_path(distance)
	if content_layer == WALL_RUN_LAYER:
		var zone := _side_runway_zone_at(distance)
		if not zone.is_empty():
			return _world_on_wall(
				distance,
				_wall_zone_side(zone, distance),
				_effective_wall_lateral_offset(zone),
				y
			)
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral
	pos.y = y
	return {"pos": pos, "yaw": float(sample["yaw"]), "forward": sample["forward"], "right": sample["right"]}

func _resolve_fork_side(lateral: float) -> int:
	# 始终落到左或右岔；中间不作为可跑路径
	if _fork_side < 0:
		return -1
	if _fork_side > 0:
		return 1
	if absf(lateral) > LANE_WIDTH * 0.2:
		return -1 if lateral < 0.0 else 1
	if lane_index <= 0:
		return -1
	if lane_index >= 2:
		return 1
	return -1 if lateral <= 0.0 else 1

func _fork_yaw_nudge(distance: float, lateral: float) -> float:
	# 岔路朝向跟所在分支，与当前三道中的哪一条无关
	var zone := _fork_zone_at(distance)
	if zone.is_empty():
		return 0.0
	var side := _resolve_fork_side(lateral)
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var spread := float(zone.get("spread", 10.0))
	var step := 4.0
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var t2 := clampf(t + step / maxf(length, 0.001), 0.0, 1.0)
	var offset := spread * _fork_envelope(t)
	var offset2 := spread * _fork_envelope(t2)
	var d_lat := ((offset2 - offset) * float(side)) / maxf(step, 0.001)
	return atan(d_lat) * 0.85

func _side_runway_zones() -> Array:
	var zones: Array = _raw_side_runway_zones()
	return _merge_synthetic_side_zones_for_main_blocks(zones)

func _raw_side_runway_zones() -> Array:
	if CustomLevels.has_level(Global.runner_location_id):
		return CustomLevels.get_side_runway_zones(Global.runner_location_id)
	var layout_id := _runner_layout_id()
	if layout_id != "":
		var out_layout: Array = []
		for raw in ObstacleLayout.load_side_runway_zones(layout_id):
			if typeof(raw) == TYPE_DICTIONARY:
				out_layout.append(ObstacleLayout.normalize_side_zone(raw))
		if not out_layout.is_empty() or ObstacleLayout.layout_has_section(layout_id, "side_runway_zones"):
			return out_layout
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if constants.has("SIDE_RUNWAY_ZONES"):
		var out: Array = []
		for raw in constants["SIDE_RUNWAY_ZONES"]:
			if typeof(raw) == TYPE_DICTIONARY:
				out.append(ObstacleLayout.normalize_side_zone(raw))
		return out
	return []

func _layout_obstacle_items_raw() -> Array:
	if CustomLevels.has_level(Global.runner_location_id):
		return CustomLevels.load_obstacles(Global.runner_location_id)
	var layout_id := _runner_layout_id()
	if layout_id != "":
		return ObstacleLayout.load_items(layout_id)
	if LevelConfig != null and LevelConfig.has_method("build_obstacles"):
		return LevelConfig.build_obstacles()
	return []

func _merge_synthetic_side_zones_for_main_blocks(zones: Array) -> Array:
	# 孤立 main_block 自动补侧墙，否则主路封堵无法通过
	var merged: Array = []
	for z in zones:
		if typeof(z) == TYPE_DICTIONARY:
			merged.append(ObstacleLayout.normalize_side_zone(z))
	for raw in _layout_obstacle_items_raw():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if int(item.get("layer", 0)) != 0:
			continue
		if _main_block_cross_mode(item) == "platform":
			continue
		var covered := false
		for i in range(merged.size()):
			var z2: Dictionary = merged[i]
			if ObstacleLayout.side_zone_covers_main_block(z2, item):
				covered = true
				break
			# 有重叠但盖不满：拉长侧墙，避免墙提前结束坠入坑中
			var extended := ObstacleLayout.extend_side_zone_to_cover_main_block(z2, item)
			if ObstacleLayout.side_zone_covers_main_block(extended, item):
				merged[i] = extended
				covered = true
				break
		if covered:
			continue
		merged.append(ObstacleLayout.side_zone_from_main_block(item, {
			"side": "outer",
			"fallback_side": 1,
		}))
	return ObstacleLayout.sort_side_zones(merged)

func _is_distance_in_side_wall_corridor(distance: float) -> bool:
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		var length := float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 10.0))
		var pad := 22.0
		if distance >= start - entry - pad and distance <= start + length + pad:
			return true
	return false

func _is_distance_in_side_runway_entry_window(distance: float) -> bool:
	# 侧墙入口前：禁止在路面上放碰撞障碍，仅保留 ramp / 转向标
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		var entry := float(zone.get("entry_window", 10.0))
		if distance >= start - entry - 3.0 and distance <= start + 4.0:
			return true
	return false

func _obstacle_blocks_side_runway_entry(otype: String, item: Dictionary) -> bool:
	if otype in ["ramp", "turn_left", "turn_right", "main_block"]:
		return false
	if int(item.get("layer", 0)) == WALL_RUN_LAYER:
		return false
	return true

func _filter_adapted_obstacles_from_wall_corridors(items: Array) -> Array:
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
		# 入口窗：除 ramp 外一律不在路面生成（装饰改由 _attach_side_runway_ramp_dressing 贴墙摆放）
		if _is_distance_in_side_runway_entry_window(dist) and _obstacle_blocks_side_runway_entry(otype, item):
			continue
		if int(item.get("layer", 0)) == 0 and not _is_distance_on_main_ground_runway(dist, 0):
			continue
		# 侧墙走廊内：仅保留 ramp/主路封堵/转向标；侧墙跑道上不再生成可碰撞障碍
		if _is_distance_in_side_wall_corridor(dist) and not keep_types.has(otype):
			continue
		out.append(item)
	return out

func _filter_core_obstacle_types(items: Array) -> Array:
	var allowed := {"jump": true, "slide": true, "orb": true, "high_bar": true}
	var out: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = (raw as Dictionary).duplicate(true)
		var otype := String(item.get("type", ""))
		if otype == "high_bar":
			item["type"] = "slide"
			otype = "slide"
		if allowed.has(otype):
			out.append(item)
	return out

func _side_runway_zone_at(distance: float) -> Dictionary:
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		var length := float(zone.get("length", 70.0))
		if distance >= start and distance <= start + length:
			return zone
	return {}

func _side_runway_entry_zone(distance: float) -> Dictionary:
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		var length := float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 8.0))
		if distance >= start - entry and distance <= start + length:
			return zone
	return {}

func _side_runway_wall_end(zone: Dictionary) -> float:
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 70.0))
	var exit_w := float(zone.get("entry_window", 10.0)) * 0.55
	return start + length + exit_w

func _side_runway_wall_zone_at(distance: float) -> Dictionary:
	# 含出口弯折 ramp，避免墙段数据已结束但仍在下墙过渡时被强行落进坑
	for zone in _side_runway_zones():
		var start := float(zone["start"])
		if distance >= start and distance <= _side_runway_wall_end(zone):
			return zone
	return {}

func _is_in_any_open_pit(distance: float) -> bool:
	return _is_in_side_runway_pit(distance) or _is_in_main_block_pit(distance)


func _is_distance_on_main_ground_runway(distance: float, layer: int = 0) -> bool:
	# 主路 layer=0 障碍只能放在有地面的区段（排除岔路挖空 / 坍塌坑）
	if layer != 0:
		return true
	if _is_in_fork_main_gap(distance):
		return false
	if _is_in_side_runway_pit(distance):
		return false
	if _is_in_main_block_pit(distance):
		return false
	return true

func _side_runway_envelope(distance: float, zone: Dictionary) -> float:
	var start := float(zone["start"])
	var length := float(zone.get("length", 70.0))
	var edge := minf(5.0, length * 0.18)
	if edge <= 0.001:
		return 1.0
	var t_in := clampf((distance - start) / edge, 0.0, 1.0)
	var t_out := clampf((start + length - distance) / edge, 0.0, 1.0)
	var t := minf(t_in, t_out)
	return t * t * (3.0 - 2.0 * t)

func _path_curvature_sign(distance: float, window: float = 22.0) -> float:
	# 正=左转（外径在 +right），负=右转（外径在 -right）
	var a := _sample_path(maxf(distance - window * 0.5, 0.0))
	var b := _sample_path(distance + window * 0.5)
	var dyaw := wrapf(float(b["yaw"]) - float(a["yaw"]), -PI, PI)
	if absf(dyaw) < 0.04:
		return 0.0
	return signf(dyaw)

func _wall_zone_side(zone: Dictionary, distance: float = NAN) -> float:
	if zone.is_empty():
		return 1.0 if _last_wall_side >= 0.0 else -1.0
	var raw: Variant = zone.get("side", 1)
	if typeof(raw) == TYPE_STRING and String(raw) == "outer":
		# 上墙后锁定左右侧，避免弯道中途翻面导致坠坑或跑到墙背面
		if _is_wall_running() and absf(_last_wall_side) > 0.01:
			return _last_wall_side
		var ref_d := distance
		if not is_finite(ref_d):
			ref_d = float(zone["start"]) + float(zone.get("length", 70.0)) * 0.5
		var curv := _path_curvature_sign(ref_d, 24.0)
		if absf(curv) < 0.5:
			return float(zone.get("fallback_side", 1))
		return curv
	return float(raw)

func _wall_run_road_half() -> float:
	match _road_style_id:
		"energy_neon":
			return 6.4
		"holographic":
			return _holographic_road_half()
		"alien_energy":
			return 6.0
		"coarse_desert":
			return 6.5
		_:
			return 6.0

func _effective_wall_lateral_offset(zone: Dictionary = {}) -> float:
	# 侧墙跑面内缘与水平跑道外缘重合，保证是「同一条跑道」弯折上去
	var edge := _wall_run_road_half() + WALL_THICKNESS * 0.5
	if zone.is_empty():
		return edge
	if zone.has("lateral_offset"):
		var custom := float(zone["lateral_offset"])
		# 旧数据写死 7.0–7.4：统一收拢到路缘，避免侧墙漂在沙地上
		if custom >= 6.8 and custom <= 7.5:
			return edge
		if absf(custom - edge) <= 0.45:
			return custom
	return edge

func _side_coin_in_active_zone(dist: float) -> bool:
	for zone in _side_runway_zones():
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 10.0))
		if dist >= start - entry - 3.0 and dist <= start + length + 3.0:
			return true
	return false

func _wall_inner_face_lateral(side: float, offset: float) -> float:
	# 朝向主路的立墙表面
	return side * offset - side * (WALL_THICKNESS * 0.5)

func _wall_stand_lateral(side: float, offset: float) -> float:
	# 脚在墙面外侧（朝主路），给躯干留出站立空间
	return _wall_inner_face_lateral(side, offset) - side * WALL_STAND_CLEARANCE

func _world_on_wall(distance: float, side: float, offset: float, height: float) -> Dictionary:
	if _path_samples.is_empty():
		_bake_track_path()
	var d := clampf(distance, 0.0, maxf(_path_length, 0.0))
	var sample := _sample_path_samples(_path_samples, d)
	var lat := _wall_stand_lateral(side, offset)
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lat
	pos.y = height
	return {
		"pos": pos,
		"yaw": float(sample["yaw"]),
		"forward": sample["forward"],
		"right": sample["right"],
		"side": side,
	}

func _apply_wall_run_body_orientation(side: float) -> void:
	# 只转视觉根：头顶朝主路，脚贴墙；玩家根节点保持直立供相机跟随
	_wall_roll = side * (PI * 0.5)
	if player_body:
		var pitch := 0.0
		if lane_index <= 0 or _is_sliding():
			pitch = 0.62 # 低列 / 滑铲：明显前俯
		elif _jump_fx_timer > 0.0 or vertical_velocity > 2.0:
			pitch = -0.55 # 跳跃：明显抬头
		elif lane_index >= 2:
			pitch = -0.22 # 高列微抬头
		var yaw_lean := clampf(body_tilt * 0.95, -0.7, 0.7)
		player_body.rotation = Vector3(pitch, yaw_lean, _wall_roll + body_tilt * 0.28)

func _world_on_path(distance: float, lateral: float, y: float, content_layer: int = -1) -> Dictionary:
	var sample := _sample_path(distance)
	var x := _fork_adjusted_lateral(distance, lateral)
	# 墙跑内容改走 _world_on_wall；此处仅主路
	if content_layer == WALL_RUN_LAYER:
		var zone := _side_runway_zone_at(distance)
		if not zone.is_empty():
			return _world_on_wall(
				distance,
				_wall_zone_side(zone, distance),
				_effective_wall_lateral_offset(zone),
				y
			)
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * x
	pos.y = y
	return {"pos": pos, "yaw": float(sample["yaw"]), "forward": sample["forward"], "right": sample["right"]}

func _sync_player_position() -> void:
	if player == null:
		return
	if _is_wall_running():
		var zone := _side_runway_wall_zone_at(track_distance)
		if zone.is_empty():
			zone = _side_runway_entry_zone(track_distance)
		if zone.is_empty() and _is_in_any_open_pit(track_distance):
			zone = _side_runway_hold_over_pit(track_distance)
		var side := _last_wall_side
		if absf(side) < 0.01:
			side = _wall_zone_side(zone, track_distance) if not zone.is_empty() else 1.0
			_last_wall_side = side
		var offset := _effective_wall_lateral_offset(zone) if not zone.is_empty() else _effective_wall_lateral_offset()
		var keep_y := player.position.y
		var placed := _world_on_wall(track_distance, side, offset, keep_y)
		_path_yaw = float(placed["yaw"])
		# 根节点只跟路径偏航，相机才能稳定锁角色
		player.position = placed["pos"]
		player.rotation = Vector3(0.0, _path_yaw, 0.0)
		_wall_roll = side * (PI * 0.5)
		_apply_wall_run_body_orientation(side)
		return

	var keep_y := player.position.y if player else GROUND_Y
	var placed := _world_on_path(track_distance, current_lateral, keep_y)
	player.position = placed["pos"]
	_path_yaw = float(placed["yaw"]) + _fork_yaw_nudge(track_distance, current_lateral)
	# 岔路上用前方真实落点推朝向，平滑跟随路面
	if not _fork_zone_at(track_distance).is_empty() or not _y_fork_region_at(track_distance).is_empty():
		var ahead := _world_on_path(track_distance + 8.0, current_lateral, keep_y)
		var delta: Vector3 = (ahead["pos"] as Vector3) - (placed["pos"] as Vector3)
		delta.y = 0.0
		if delta.length_squared() > 0.04:
			var face_yaw := atan2(-delta.x, -delta.z)
			_path_yaw = lerp_angle(_path_yaw, face_yaw, 0.32)
	# 离开侧墙后恢复直立朝向；急弯/岔路略加快朝向跟随，减少「车头甩、镜头慢」的眩晕
	var on_fork_now := not _fork_zone_at(track_distance).is_empty()
	var yaw_blend := 0.38
	if on_fork_now:
		yaw_blend = 0.48
	elif _path_turn_sharpness(track_distance) > 0.15:
		yaw_blend = 0.45
	player.rotation.y = lerp_angle(player.rotation.y, _path_yaw, yaw_blend)
	player.rotation.x = 0.0
	player.rotation.z = 0.0
	_wall_roll = lerpf(_wall_roll, 0.0, 0.28)
	if player_body:
		var recoil_pitch := 0.0
		var recoil_yaw := 0.0
		if _hit_recoil_timer > 0.0:
			var t := clampf(_hit_recoil_timer / 0.58, 0.0, 1.0)
			recoil_pitch = -0.32 * t
			recoil_yaw = sin(elapsed * 48.0) * 0.10 * t
		player_body.rotation.x = lerpf(player_body.rotation.x, recoil_pitch + _run_body_pitch, 0.45)
		player_body.rotation.y = lerpf(player_body.rotation.y, recoil_yaw, 0.4)
		player_body.rotation.z = lerpf(player_body.rotation.z, body_tilt, 0.28)

func _check_junctions() -> void:
	for junction_index in _junction_zones().size():
		if passed_junctions.has(junction_index):
			continue
		var zone: Dictionary = _junction_zones()[junction_index]
		var at_distance: float = float(zone["distance"])
		var zone_len := float(zone.get("length", 70.0))
		var zone_end := at_distance + zone_len
		if track_distance < at_distance:
			continue
		# 速通一帧可能跳过 22m 决策窗：仍在分叉段内则补锁，避免主路挖空段落沙
		if track_distance > at_distance + 22.0:
			if track_distance <= zone_end + 2.0:
				_lock_junction_choice(junction_index, zone)
			continue
		var intent := _fork_side_from_intent()
		var chosen_side := 0
		if intent != 0:
			chosen_side = intent
		elif track_distance < at_distance + 18.0:
			continue
		else:
			if target_lane_x > 0.0 or lane_index >= 1:
				chosen_side = 1
				_show_gate_toast("中道犹豫 · 已按右道转入速通岔")
				strike_toast_label.modulate = Color(0.55, 0.85, 1.0, 1.0)
			else:
				chosen_side = -1
				_show_gate_toast("中道无路 · 已转入安全岔（左）")
				strike_toast_label.modulate = Color(0.55, 0.95, 0.75, 1.0)
			strike_toast_timer = 1.4
		_commit_junction_choice(junction_index, zone, chosen_side)

	_enforce_active_fork_side()
	_ensure_fork_effect_while_on_branch()

	if _active_fork_index >= 0 and _active_fork_index < _junction_zones().size():
		var active: Dictionary = _junction_zones()[_active_fork_index]
		var end_d := float(active["distance"]) + float(active.get("length", 70.0))
		if track_distance > end_d + 1.0:
			_active_fork_index = -1
			if _y_fork_region_at(track_distance).is_empty():
				_fork_side = 0

func _lock_junction_choice(junction_index: int, zone: Dictionary) -> void:
	var intent := _fork_side_from_intent()
	var chosen_side := intent if intent != 0 else _resolve_fork_side(current_lateral)
	_commit_junction_choice(junction_index, zone, chosen_side)

func _commit_junction_choice(junction_index: int, zone: Dictionary, chosen_side: int) -> void:
	if passed_junctions.has(junction_index):
		return
	passed_junctions.append(junction_index)
	_active_fork_index = junction_index
	if chosen_side < 0:
		_fork_side = -1
		_apply_gate_effect(String(zone.get("effect_a", "repair")))
	else:
		_fork_side = 1
		_apply_gate_effect(String(zone.get("effect_b", "fast")))

func _apply_fork_branch_lateral_snap() -> void:
	# Y 岔 / junction 岔路几何已烘焙进 branch，换道由 target_lane_x 驱动，不锁道
	if _y_fork_side_at(track_distance) > 0:
		return
	if _fork_side != 0 and not _junction_fork_region_at(track_distance).is_empty():
		return
	var zone := _fork_zone_at(track_distance)
	if zone.is_empty():
		return
	_enforce_active_fork_side()
	if _fork_side == 0:
		return
	# 仅在主路挖空段轻推落岔；分支内仍允许三道换道躲障
	if not _is_in_fork_main_gap(track_distance):
		return
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var t := clampf((track_distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var envelope := maxf(_fork_envelope(t), 0.58)
	var spread := float(zone.get("spread", 10.0))
	var branch_center := float(_fork_side) * spread * envelope
	var desired := branch_center + float(LANES[lane_index]) * LANE_WIDTH
	target_lane_x = float(LANES[lane_index]) * LANE_WIDTH
	current_lateral = lerpf(current_lateral, desired, 0.34)

func _ensure_fork_effect_while_on_branch() -> void:
	var zone := _fork_zone_at(track_distance)
	if zone.is_empty():
		return
	# 已锁定则绝不翻边；未锁定时只跟明确意图，绝不中道默认左
	if _fork_side == 0:
		var intent := _fork_side_from_intent()
		if intent == 0:
			return
		_fork_side = intent
	for i in _junction_zones().size():
		var z: Dictionary = _junction_zones()[i]
		if absf(float(z.get("distance", -999.0)) - float(zone.get("distance", 0.0))) > 0.5:
			continue
		if not passed_junctions.has(i):
			passed_junctions.append(i)
			_active_fork_index = i
			if _fork_side > 0:
				_apply_gate_effect(String(z.get("effect_b", "fast")))
			else:
				_apply_gate_effect(String(z.get("effect_a", "safe")))
		break
	# 仅「速通」右岔整段保持飞驰；奖励/安全左岔不维持加速
	var right_effect := String(zone.get("effect_b", ""))
	if _fork_side > 0 and right_effect == "fast":
		_fork_rush_timer = maxf(_fork_rush_timer, FORK_RUSH_DURATION * 0.55)
	elif _fork_side != 0:
		_fork_rush_timer = 0.0
		_fork_rush_elapsed = 0.0

func _enforce_active_fork_side() -> void:
	var zone := _fork_zone_at(track_distance)
	if zone.is_empty():
		return
	var start := float(zone["distance"])
	var length := float(zone.get("length", 70.0))
	var t := clampf((track_distance - start) / maxf(length, 0.001), 0.0, 1.0)
	if _fork_envelope(t) < 0.08:
		return
	# 一旦选定左右岔，整段锁定，禁止中途翻到另一岔
	if _fork_side == 0:
		var intend := _fork_side_from_intent()
		if intend == 0:
			# 主路已挖空时，按当前横向/车道立即落岔，避免冲下黄沙
			if _is_in_fork_main_gap(track_distance):
				intend = _resolve_fork_side(current_lateral)
			if intend == 0:
				return
		_fork_side = intend
	elif _fork_side < 0:
		_fork_side = -1
	else:
		_fork_side = 1
	if _active_fork_index < 0:
		for i in _junction_zones().size():
			var z: Dictionary = _junction_zones()[i]
			if absf(float(z.get("distance", -999.0)) - start) < 0.5:
				_active_fork_index = i
				break

func _fork_side_from_intent() -> int:
	# 0 = 尚犹豫；优先目标道，再看当前横向 / 车道
	if lane_index >= 2 or target_lane_x > LANE_WIDTH * 0.35 or current_lateral > LANE_WIDTH * 0.28:
		return 1
	if lane_index <= 0 or target_lane_x < -LANE_WIDTH * 0.35 or current_lateral < -LANE_WIDTH * 0.28:
		return -1
	if target_lane_x > LANE_WIDTH * 0.12:
		return 1
	if target_lane_x < -LANE_WIDTH * 0.12:
		return -1
	return 0

func _check_fork_approach() -> void:
	# 分叉提示改由空中 REGULAR/SPEEDUP 标牌承担，不再弹顶部弱 toast
	for junction_index in _junction_zones().size():
		if _fork_approach_warned.has(junction_index) or passed_junctions.has(junction_index):
			continue
		var zone: Dictionary = _junction_zones()[junction_index]
		var at_distance := float(zone["distance"])
		if track_distance < at_distance - 38.0 or track_distance > at_distance - 28.0:
			continue
		_fork_approach_warned.append(junction_index)

func _y_fork_region_at(distance: float) -> Dictionary:
	for region in _y_fork_regions:
		if typeof(region) != TYPE_DICTIONARY:
			continue
		var d0 := float(region.get("d_start", 0.0))
		var d1 := float(region.get("d_end", 0.0))
		if distance >= d0 and distance <= d1:
			return region
	return {}

func _y_fork_side_at(distance: float) -> int:
	if _y_fork_region_at(distance).is_empty():
		return 0
	if _fork_side != 0:
		return _fork_side
	# 尚未锁定时按当前车道预览（铺路/摆障碍时 _fork_side=0 → 走左岔主路径）
	if not gameplay_active:
		return 0
	return _resolve_fork_side(current_lateral)

func _check_y_fork_approach() -> void:
	for i in _y_fork_regions.size():
		if _y_fork_approach_warned.has(i) or passed_y_forks.has(i):
			continue
		var region: Dictionary = _y_fork_regions[i]
		var at_distance := float(region.get("d_start", 0.0))
		if track_distance < at_distance - 38.0 or track_distance > at_distance - 28.0:
			continue
		_y_fork_approach_warned.append(i)
		_show_gate_toast("前方 Y 分叉 · 左岔障碍 · 右岔奖励加障碍")

func _check_y_forks() -> void:
	for i in _y_fork_regions.size():
		if passed_y_forks.has(i):
			continue
		var region: Dictionary = _y_fork_regions[i]
		var at_distance := float(region.get("d_start", 0.0))
		var end_d := float(region.get("d_end", at_distance + 58.0))
		if track_distance < at_distance:
			continue
		# 速通一帧可能跳过 4m 决策窗：仍在 Y 岔段内则补锁
		if track_distance > at_distance + 4.0:
			if track_distance <= end_d + 2.0:
				_lock_y_fork_choice(i, region)
			continue
		_commit_y_fork_choice(i, region)
	_enforce_active_y_fork_side()
	if _active_y_fork_index >= 0 and _active_y_fork_index < _y_fork_regions.size():
		var active: Dictionary = _y_fork_regions[_active_y_fork_index]
		var end_d := float(active.get("d_end", 0.0))
		if track_distance > end_d + 1.0:
			_active_y_fork_index = -1
			# 若仍在旧横向分叉区内，保留其 _fork_side
			if _fork_zone_at(track_distance).is_empty():
				_fork_side = 0

func _lock_y_fork_choice(fork_index: int, _region: Dictionary) -> void:
	if passed_y_forks.has(fork_index):
		return
	passed_y_forks.append(fork_index)
	_active_y_fork_index = fork_index
	var y_intent := _fork_side_from_intent()
	if y_intent != 0:
		_fork_side = y_intent
	elif _fork_side == 0:
		_fork_side = _resolve_fork_side(current_lateral)
		if _fork_side == 0:
			_fork_side = -1 if current_lateral <= 0.0 else 1

func _commit_y_fork_choice(fork_index: int, _region: Dictionary) -> void:
	if passed_y_forks.has(fork_index):
		return
	passed_y_forks.append(fork_index)
	_active_y_fork_index = fork_index
	var y_intent := _fork_side_from_intent()
	if y_intent < 0 or lane_index <= 0:
		_fork_side = -1
		_show_gate_toast("左岔路")
	elif y_intent > 0 or lane_index >= 2:
		_fork_side = 1
		_show_gate_toast("右岔路")
	else:
		_fork_side = -1 if current_lateral <= 0.0 else 1
		var fork_penalty := 8.0 * Global.get_cargo_damage_multiplier()
		_apply_cargo_loss(fork_penalty)
		if not is_failed:
			if _hit_feedback != null and player != null:
				_hit_feedback.apply_impact(
					_runway_tip_anchor(),
					HitFeedback.Intensity.LIGHT,
					fork_penalty,
				)

func _enforce_active_y_fork_side() -> void:
	var region := _y_fork_region_at(track_distance)
	if region.is_empty():
		return
	if _fork_side == 0:
		var intent := _fork_side_from_intent()
		if intent == 0:
			return
		_fork_side = intent
	if _active_y_fork_index < 0:
		var d0 := float(region.get("d_start", -999.0))
		for i in _y_fork_regions.size():
			var r: Dictionary = _y_fork_regions[i]
			if absf(float(r.get("d_start", -999.0)) - d0) < 0.5:
				_active_y_fork_index = i
				break

func _apply_cargo_loss(amount: float) -> void:
	if amount <= 0.0:
		return
	cargo_integrity = maxf(cargo_integrity - amount, 0.0)
	if _hit_feedback != null:
		_hit_feedback.flash_cargo()
	if cargo_integrity <= 0.0:
		_fail_run("货物完整度归零，%s 损毁" % String(mission.get("cargo_name", "物资")))

func _update_env_hazards(delta: float) -> void:
	if is_finished or is_failed or not gameplay_active:
		return
	var in_heat := false
	for obstacle in obstacles:
		if not bool(obstacle.get("heat_hazard", false)):
			continue
		if int(obstacle.get("layer", 0)) != track_layer:
			continue
		var obs_dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
		if absf(track_distance - obs_dist) > HEAT_HAZARD_HALF_LEN:
			continue
		if not _player_in_obstacle_lateral(obstacle):
			continue
		in_heat = true
		break
	if not in_heat:
		_heat_tick_accum = 0.0
		return
	_heat_tick_accum += delta
	if _heat_tick_accum < HEAT_HAZARD_TICK:
		return
	_heat_tick_accum = 0.0
	var dmg := HEAT_HAZARD_DPS * HEAT_HAZARD_TICK * Global.get_cargo_damage_multiplier() * _cargo_fragility_mult() * 0.88 * _cargo_fragility_mult() * 0.88 * _cargo_fragility_mult() * 0.88
	_apply_cargo_loss(dmg)
	if is_failed:
		return
	if _hit_feedback != null and player != null:
		_hit_feedback.apply_env_tick_at(player.global_position + Vector3(0.0, 1.7, 0.0), dmg, "热量侵蚀")
	elif strike_toast_label:
		_show_strike_warning("热量侵蚀")

func _sandstorm_zones() -> Array:
	if CustomLevels.has_level(Global.runner_location_id):
		return CustomLevels.get_sandstorm_zones(Global.runner_location_id)
	var layout_id := _runner_layout_id()
	if layout_id != "":
		var out_layout: Array = []
		for raw in ObstacleLayout.load_sandstorm_zones(layout_id):
			if typeof(raw) == TYPE_DICTIONARY:
				out_layout.append(ObstacleLayout.normalize_sandstorm_zone(raw))
		if not out_layout.is_empty() or ObstacleLayout.layout_has_section(layout_id, "sandstorm_zones"):
			return out_layout
	if LevelConfig == null:
		return []
	var constants: Dictionary = LevelConfig.get_script_constant_map()
	if constants.has("SANDSTORM_ZONES"):
		var out: Array = []
		for raw in constants["SANDSTORM_ZONES"]:
			if typeof(raw) == TYPE_DICTIONARY:
				out.append(ObstacleLayout.normalize_sandstorm_zone(raw))
		return out
	return []

func _sandstorm_region_at(distance: float) -> Dictionary:
	for zone in _sandstorm_zones():
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		if distance < start or distance > start + length:
			continue
		return zone
	return {}

func _sandstorm_zone_at(distance: float) -> Dictionary:
	var player_lane := int(LANES[clampi(lane_index, 0, LANES.size() - 1)])
	var region := _sandstorm_region_at(distance)
	if region.is_empty():
		return {}
	if String(region.get("emit_style", "volume")) == "side_cave":
		var key := int(float(region.get("start", 0.0)))
		var runtime: Dictionary = _side_hazard_runtime.get(key, {})
		if not bool(runtime.get("burst_active", false)):
			return {}
		var effective := region.duplicate(true)
		effective["covered_lanes"] = runtime.get("covered_lanes", region.get("covered_lanes", [-1, 0, 1]))
		if not _sandstorm_covers_lane(effective, player_lane):
			return {}
		return effective
	if not _sandstorm_covers_lane(region, player_lane):
		return {}
	return region

func _sandstorm_covers_lane(zone: Dictionary, lane_value: int) -> bool:
	var covered: Array = zone.get("covered_lanes", [-1, 0, 1])
	for v in covered:
		if int(v) == lane_value:
			return true
	return false

func _sandstorm_volume_layout(zone: Dictionary) -> Dictionary:
	var covered: Array = zone.get("covered_lanes", [-1, 0, 1])
	if covered.is_empty():
		covered = [-1, 0, 1]
	var min_lane := int(covered[0])
	var max_lane := int(covered[0])
	for v in covered:
		min_lane = mini(min_lane, int(v))
		max_lane = maxi(max_lane, int(v))
	var center := (float(min_lane) + float(max_lane)) * 0.5
	var span := float(max_lane - min_lane) + 1.0
	return {
		"lateral_bias": center * LANE_WIDTH,
		"half_width": span * LANE_WIDTH * 0.5 + 0.9,
	}

func _update_sandstorm_hazard(delta: float) -> void:
	_update_side_hazard_bursts(delta)
	if is_finished or is_failed or not gameplay_active:
		_set_sandstorm_visual(false, false)
		return
	var region := _sandstorm_region_at(track_distance)
	var zone := _sandstorm_zone_at(track_distance)
	var in_region := not region.is_empty()
	var active := not zone.is_empty()
	if in_region and not _sandstorm_active:
		var key := int(float(region.get("start", 0.0)))
		if not _sandstorm_warned_keys.has(key):
			_sandstorm_warned_keys.append(key)
			var label := String(region.get("label", "环境危害"))
			if String(region.get("emit_style", "volume")) == "side_cave":
				if _is_shield_protecting():
					_show_strike_warning("%s · 两侧能量穴交替喷涌 · 防护罩生效" % label)
				else:
					_show_strike_warning("%s · 观察左右喷涌节奏换道" % label)
			elif _is_shield_protecting():
				_show_strike_warning("%s来袭 · 防护罩抵挡中" % label)
			else:
				_show_strike_warning("%s来袭 · 开启防护罩(F)或换道" % label)
	_sandstorm_active = in_region
	var use_volume_fx := in_region and String(region.get("emit_style", "volume")) != "side_cave"
	_set_sandstorm_visual(use_volume_fx and active, in_region)
	if not active:
		_sandstorm_tick_accum = 0.0
		return
	_sandstorm_tick_accum += delta
	_shield_drain_fx_cd = maxf(_shield_drain_fx_cd - delta, 0.0)
	if _sandstorm_tick_accum < SANDSTORM_TICK:
		return
	_sandstorm_tick_accum = 0.0
	var dps := float(zone.get("dps", SANDSTORM_DEFAULT_DPS))
	var storm_mult := clampf(float(mission.get("sandstorm_dps_mult", 1.0)), 0.5, 2.5)
	dps *= storm_mult
	var dmg := dps * SANDSTORM_TICK * Global.get_cargo_damage_multiplier()
	var label := String(zone.get("label", "沙尘暴"))
	if _is_shield_protecting():
		var drain := dmg * SHIELD_DRAIN_MULT
		shield_energy = maxf(shield_energy - drain, 0.0)
		if shield_energy <= 0.001:
			shield_active = false
			_shield_warned_empty = true
			_show_strike_warning("防护罩能量耗尽 · 无法抵御沙尘暴")
		elif _hit_feedback != null and player != null and _shield_drain_fx_cd <= 0.0:
			_shield_drain_fx_cd = 1.35
			_hit_feedback.apply_env_tick_at(player.global_position + Vector3(0.0, 1.7, 0.0), drain * 0.35, "防护罩")
		return
	_apply_cargo_loss(dmg)
	if is_failed:
		return
	if _hit_feedback != null and player != null:
		_hit_feedback.apply_env_tick_at(player.global_position + Vector3(0.0, 1.7, 0.0), dmg, label)
	else:
		_show_strike_warning("%s侵蚀" % label)

func _is_shield_protecting() -> bool:
	return shield_active and shield_energy >= SHIELD_MIN_ACTIVATE - 0.001

func _toggle_shield() -> void:
	if is_finished or is_failed or is_intro or not gameplay_active:
		return
	if not _tutorial_allows_action("shield"):
		_show_gate_toast("请按教学提示操作")
		return
	if shield_active:
		shield_active = false
		_show_gate_toast("防护罩关闭")
		return
	if shield_energy <= 0.001:
		_show_strike_warning("防护罩能量不足 · 拾取水晶充能")
		return
	shield_active = true
	_shield_warned_empty = false
	_show_gate_toast("防护罩开启 · 可挡沙尘暴")
	_ensure_shield_mesh()
	_notify_coach_action("shield")

func _ensure_shield_mesh() -> void:
	if player == null:
		return
	if _shield_mesh == null or not is_instance_valid(_shield_mesh):
		_shield_mesh = MeshInstance3D.new()
		_shield_mesh.name = "PlayerShieldBubble"
		var sphere := SphereMesh.new()
		sphere.radius = 1.08
		sphere.height = 2.16
		sphere.radial_segments = 28
		sphere.rings = 14
		_shield_shader_mat = ShaderMaterial.new()
		_shield_shader_mat.shader = SHIELD_ENERGY_SHADER
		_shield_shader_mat.set_shader_parameter("core_tint", Color(0.14, 0.56, 0.98, 0.06))
		_shield_shader_mat.set_shader_parameter("rim_tint", Color(0.38, 0.82, 1.0, 0.42))
		_shield_shader_mat.set_shader_parameter("spark_tint", Color(0.94, 0.98, 1.0, 1.0))
		sphere.material = _shield_shader_mat
		_shield_mesh.mesh = sphere
		_shield_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		player.add_child(_shield_mesh)
		_shield_mesh.position = Vector3(0.0, 1.02, 0.0)
	if _shield_ground_ripple == null or not is_instance_valid(_shield_ground_ripple):
		_shield_ground_ripple = MeshInstance3D.new()
		_shield_ground_ripple.name = "PlayerShieldGroundRipple"
		var disc := CylinderMesh.new()
		disc.top_radius = 0.92
		disc.bottom_radius = 0.92
		disc.height = 0.02
		disc.radial_segments = 32
		var ripple_mat := _make_material(Color(0.35, 0.78, 1.0, 0.12), Color(0.55, 0.92, 1.0), 0.95)
		(ripple_mat as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		(ripple_mat as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		disc.material = ripple_mat
		_shield_ground_ripple.mesh = disc
		_shield_ground_ripple.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		player.add_child(_shield_ground_ripple)
		_shield_ground_ripple.position = Vector3(0.0, 0.05, 0.0)


func _make_shield_orbit_ring(inner_r: float, outer_r: float, tint: Color, emission: float) -> MeshInstance3D:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = inner_r
	torus.outer_radius = outer_r
	torus.rings = 8
	torus.ring_segments = 32
	var ring_mat := _make_material(tint, Color(1.0, 1.0, 1.0), emission)
	(ring_mat as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	(ring_mat as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	torus.material = ring_mat
	ring.mesh = torus
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return ring

func _update_shield_visual(_delta: float) -> void:
	_ensure_shield_mesh()
	if _shield_mesh == null:
		return
	var protecting := _is_shield_protecting()
	_shield_mesh.visible = protecting
	if _shield_waist_ring != null and is_instance_valid(_shield_waist_ring):
		_shield_waist_ring.visible = protecting
	elif protecting and player != null:
		_shield_waist_ring = _make_shield_orbit_ring(0.96, 1.04, Color(0.88, 0.96, 1.0, 0.38), 1.65)
		_shield_waist_ring.position = Vector3(0.0, 0.95, 0.0)
		_shield_waist_ring.rotation.x = PI * 0.5
		player.add_child(_shield_waist_ring)
	if _shield_orbit_ring_b != null and is_instance_valid(_shield_orbit_ring_b):
		_shield_orbit_ring_b.visible = protecting
	elif protecting and player != null:
		_shield_orbit_ring_b = _make_shield_orbit_ring(0.96, 1.04, Color(0.92, 0.98, 1.0, 0.34), 1.75)
		_shield_orbit_ring_b.position = Vector3(0.0, 0.95, 0.0)
		_shield_orbit_ring_b.rotation.z = PI * 0.5
		player.add_child(_shield_orbit_ring_b)
	if _shield_ground_ripple != null and is_instance_valid(_shield_ground_ripple):
		_shield_ground_ripple.visible = protecting
		if protecting:
			var ripple := 0.92 + 0.08 * sin(Time.get_ticks_msec() * 0.011)
			_shield_ground_ripple.scale = Vector3(ripple, 1.0, ripple)
			var ripple_mat := _shield_ground_ripple.get_active_material(0)
			if ripple_mat is StandardMaterial3D:
				(ripple_mat as StandardMaterial3D).albedo_color.a = 0.06 + 0.05 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.013))
	if not protecting or _shield_shader_mat == null:
		return
	var ratio := clampf(shield_energy / SHIELD_MAX_ENERGY, 0.0, 1.0)
	var pulse := 0.90 + 0.10 * sin(Time.get_ticks_msec() * 0.008)
	var storm := 1.0 if _sandstorm_active else 0.0
	_shield_shader_mat.set_shader_parameter("energy_ratio", ratio)
	_shield_shader_mat.set_shader_parameter("pulse", pulse)
	_shield_shader_mat.set_shader_parameter("storm_boost", storm)
	if _sandstorm_active:
		_shield_shader_mat.set_shader_parameter("rim_tint", Color(0.48, 0.88, 1.0, 0.52))
	else:
		_shield_shader_mat.set_shader_parameter("rim_tint", Color(0.38, 0.82, 1.0, 0.42))

func _set_sandstorm_visual(volume_fx_active: bool, region_active: bool = true) -> void:
	if _sandstorm_particles:
		_sandstorm_particles.emitting = volume_fx_active
		if volume_fx_active and player != null:
			_sandstorm_particles.global_position = player.global_position + Vector3(0.0, 1.2, 0.0)
	if _sandstorm_grit_particles:
		_sandstorm_grit_particles.emitting = volume_fx_active
		if volume_fx_active and player != null:
			_sandstorm_grit_particles.global_position = player.global_position + Vector3(0.0, 0.85, 0.0)
	if danger_vignette:
		if region_active:
			danger_vignette.modulate.a = maxf(danger_vignette.modulate.a, 0.38)
	if _world_environment and _world_environment.environment:
		var env := _world_environment.environment
		if _is_relay_mission():
			if not _is_rain_weather():
				# 中继站保持关雾（同水源一），沙暴只用路面/UI提示，不整屏染色
				env.fog_enabled = false
				env.fog_aerial_perspective = 0.0
			return
		var storm_boost := 2.35
		if _uses_medical_sunrise_sky():
			storm_boost = 1.22
		var target_density := _base_fog_density * (storm_boost if region_active else 1.0)
		env.fog_density = lerpf(env.fog_density, target_density, 0.18)
		var region := _sandstorm_region_at(track_distance)
		var is_poison := String(region.get("hazard_kind", "sand")) == "poison"
		if _uses_medical_sunrise_sky():
			# 毒雾只标路面危险，不要把整片天洗成荧光绿遮罩
			env.fog_aerial_perspective = lerpf(env.fog_aerial_perspective, 0.02 if region_active else 0.05, 0.18)
		var poison_mix := 0.16 if _uses_medical_sunrise_sky() else 0.48
		var storm_tint: Color
		storm_tint = _base_fog_light_color.lerp(
			Color(0.42, 0.58, 0.36, 1.0) if is_poison else Color(0.82, 0.55, 0.32),
			poison_mix
		)
		var target_color := storm_tint if region_active else _base_fog_light_color
		env.fog_light_color = env.fog_light_color.lerp(target_color, 0.16)

func _apply_gate_effect(effect: String) -> void:
	match effect:
		"repair", "safe":
			# 货物完整度会被障碍/环境扣掉；安全岔专门回补，并稳速免障
			cargo_integrity = minf(cargo_integrity + 10.0, 100.0)
			if _pressure_chaser_enabled and _energy_chaser != null:
				_energy_chaser.reward_clean_play(15.0)
				chaser_distance = _energy_chaser.get_visual_gap()
			_fork_rush_timer = 0.0
			_fork_rush_elapsed = 0.0
			speed_penalty_mult = 1.0
			speed_penalty_timer = 0.0
			if player != null:
				_spawn_floating_pickup_label("+10", player.global_position, Color(0.55, 0.98, 0.72))
			_show_runway_combat_tip("完整度 +10", Color(0.45, 0.98, 0.72, 1.0))
		"fast":
			run_score += 160
			if _pressure_chaser_enabled and _energy_chaser != null:
				_energy_chaser.add_pressure(8.0)
				chaser_distance = _energy_chaser.get_visual_gap()
			else:
				chaser_distance = maxf(chaser_distance - 3.0, CHASER_CATCH_DISTANCE)
			_fork_rush_timer = FORK_RUSH_DURATION
			_fork_rush_elapsed = 0.0
			_speed_boost_timer = 0.0
			speed_penalty_mult = 1.0
			speed_penalty_timer = 0.0
			camera_shake = maxf(camera_shake, 0.12)
			_speed_feel_punch = 1.0
			_hit_fov_punch = 0.0
			if trail_particles:
				trail_particles.amount_ratio = 1.0
				trail_particles.speed_scale = 2.2
			_set_trail_color(Color(0.55, 0.85, 1.0, 0.82))
			_show_gate_toast("速通岔 · 提速中 · 仍需换道躲障")
			strike_toast_label.modulate = Color(0.55, 0.85, 1.0, 1.0)
			strike_toast_timer = 1.6
		"bonus":
			run_score += 180
			cargo_integrity = minf(cargo_integrity + 8.0, 100.0)
			_fork_rush_timer = 0.0
			_fork_rush_elapsed = 0.0
			speed_penalty_mult = 1.0
			speed_penalty_timer = 0.0
			_show_runway_combat_tip("完整度 +8", Color(1.0, 0.86, 0.35, 1.0))
		_:
			run_score += 60
			_show_gate_toast("岔路通过 · 得分 +60")

func _is_on_fast_fork() -> bool:
	if _fork_side <= 0:
		return false
	var zone := _fork_zone_at(track_distance)
	if zone.is_empty():
		return false
	return String(zone.get("effect_b", "")) == "fast"

func _is_fork_rushing() -> bool:
	return _fork_rush_timer > 0.0 or _is_on_fast_fork()

func _effective_speed_boost_mult() -> float:
	if _finish_sprint_timer > 0.0:
		return FINISH_SPRINT_MULT
	if _is_fork_rushing():
		# 过加速门后 1~2s 平滑提速到可操作峰值，避免瞬拉过高
		var t := clampf(_fork_rush_elapsed / FORK_RUSH_RAMP, 0.0, 1.0)
		var ease := t * t * (3.0 - 2.0 * t)
		return lerpf(FORK_RUSH_START_MULT, FORK_RUSH_MULT, ease)
	if _fork_side < 0 and not _fork_zone_at(track_distance).is_empty():
		return FORK_SAFE_SPEED_MULT
	var boot := 1.0
	if _speed_boost_timer > 0.0:
		boot = SPEED_BOOST_MULT_EMERGENCY if _is_emergency_run else SPEED_BOOST_MULT
	var pad := 1.0
	if _pad_burst_until_d > track_distance:
		pad = PAD_BURST_MULT_RELAY if _is_relay_mission() else PAD_BURST_MULT
	return maxf(boot, pad)

func _wall_run_speed_mult() -> float:
	if not _is_wall_running():
		return 1.0
	var zone := _side_runway_zone_at(track_distance)
	if zone.is_empty():
		zone = _side_runway_hold_over_pit(track_distance)
	if zone.is_empty():
		return WALL_RUN_SPEED_MULT
	return clampf(float(zone.get("speed_mult", WALL_RUN_SPEED_MULT)), 1.02, 1.12)

func _is_on_safe_fork() -> bool:
	return _fork_side < 0 and not _fork_zone_at(track_distance).is_empty()

func _show_gate_toast(label: String) -> void:
	strike_toast_label.text = "→ %s" % label
	strike_toast_timer = 1.2
	strike_toast_label.modulate = Color(0.55, 0.95, 0.75, 1.0)

func _runway_tip_anchor() -> Vector3:
	if player == null:
		return Vector3.ZERO
	return player.global_position + Vector3(0.0, 0.18, 0.38)

func _show_runway_combat_tip(text: String, color: Color = Color(1.0, 0.72, 0.38, 1.0)) -> void:
	if not gameplay_active or player == null or _hit_feedback == null:
		return
	_hit_feedback.spawn_runway_tip_at(_runway_tip_anchor(), text, color)

func _compact_strike_tip(reason: String) -> String:
	var trimmed := reason.strip_edges()
	if trimmed.contains("防护罩") or trimmed.contains("能量"):
		if trimmed.contains("不足") or trimmed.contains("关闭"):
			return "防护罩 -"
		if trimmed.contains("抵挡"):
			return "防护罩 OK"
		if trimmed.contains("开启") or trimmed.contains("需"):
			return "防护罩 !"
		return "防护罩 !"
	if trimmed.contains("区 ·") or trimmed.contains("来袭"):
		return "完整度 -"
	if trimmed.contains("撞碎") or trimmed.contains("货物"):
		var pct_re := RegEx.new()
		pct_re.compile("(\\d+)%")
		var pct_match := pct_re.search(trimmed)
		if pct_match:
			return "完整度 -%s" % pct_match.get_string(1)
		var num_re := RegEx.new()
		num_re.compile("-\\s*(\\d+)")
		var num_match := num_re.search(trimmed)
		if num_match:
			return "完整度 -%s" % num_match.get_string(1)
		return "完整度 -"
	if trimmed.contains("体力") or trimmed.contains("HP"):
		var hp_re := RegEx.new()
		hp_re.compile("-\\s*(\\d+(?:\\.\\d+)?)")
		var hp_match := hp_re.search(trimmed)
		if hp_match:
			return "HP -%s" % hp_match.get_string(1)
		return "HP -"
	if trimmed.contains("侵蚀") or trimmed.contains("热量") or trimmed.contains("沙暴"):
		return "完整度 -"
	if trimmed.contains("飞驰") or trimmed.contains("撞击"):
		return "完整度 -"
	if trimmed.contains("坍塌") or trimmed.contains("上墙"):
		return "上墙 !"
	return trimmed.substr(0, mini(trimmed.length(), 12))

func _build_sky_cheer_root() -> void:
	if hud_root == null:
		return
	if _sky_cheer_hud_layer != null and is_instance_valid(_sky_cheer_hud_layer):
		return
	_sky_cheer_hud_layer = Control.new()
	_sky_cheer_hud_layer.name = "SkyCheerHud"
	_sky_cheer_hud_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sky_cheer_hud_layer.offset_left = 0.0
	_sky_cheer_hud_layer.offset_top = 0.0
	_sky_cheer_hud_layer.offset_right = 0.0
	_sky_cheer_hud_layer.offset_bottom = 0.0
	_sky_cheer_hud_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sky_cheer_hud_layer.z_index = 60
	hud_root.add_child(_sky_cheer_hud_layer)
	if not hud_root.resized.is_connected(_sync_sky_cheer_hud_size):
		hud_root.resized.connect(_sync_sky_cheer_hud_size)
	call_deferred("_sync_sky_cheer_hud_size")

func _sync_sky_cheer_hud_size(_unused: Variant = null) -> void:
	if _sky_cheer_hud_layer == null or hud_root == null:
		return
	var sz := hud_root.size
	if sz.x < 8.0 or sz.y < 8.0:
		sz = MOBILE_VIEWPORT_SIZE
	_sky_cheer_hud_layer.size = sz
	_sky_cheer_hud_layer.position = Vector2.ZERO

func _schedule_sky_cheer_danmaku() -> void:
	_clear_sky_cheer_danmaku()
	var finish_d := maxf(_finish_arrival_distance(), maxf(_path_length, _track_length * 0.82))
	if finish_d < 80.0:
		finish_d = maxf(_track_length, 120.0)
	_sky_cheer_rng.randomize()
	var count := _sky_cheer_rng.randi_range(SKY_CHEER_MIN_COUNT, SKY_CHEER_MAX_COUNT)
	var pool: Array = SKY_CHEER_LINES.duplicate()
	for i in range(pool.size() - 1, 0, -1):
		var j := _sky_cheer_rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var span_start := maxf(16.0, finish_d * 0.04)
	var span_end := finish_d * 0.90
	var usable := maxf(span_end - span_start, 40.0)
	var step := usable / float(count + 1)
	var run_time := maxf(_run_time, 8.0)
	var time_start := maxf(1.0, run_time * 0.04)
	var time_end := run_time * 0.88
	var time_step := maxf((time_end - time_start) / float(count + 1), 1.5)
	for i in count:
		var jitter := _sky_cheer_rng.randf_range(-step * 0.28, step * 0.28)
		var at_d := clampf(span_start + step * float(i + 1) + jitter, span_start, span_end)
		var at_time := clampf(
			time_start + time_step * float(i + 1) + _sky_cheer_rng.randf_range(-0.8, 0.8),
			time_start,
			time_end
		)
		var line: Dictionary = pool[i % pool.size()]
		_sky_cheer_schedule.append({
			"d": at_d,
			"at_time": at_time,
			"zh": String(line.get("zh", "")),
			"en": String(line.get("en", "")),
			"spawned": false,
		})

func _clear_sky_cheer_danmaku() -> void:
	_sky_cheer_schedule.clear()
	for entry in _sky_cheer_active:
		var block := entry.get("root") as Control
		if block == null:
			block = entry.get("label") as Control
		if block != null and is_instance_valid(block):
			block.queue_free()
	_sky_cheer_active.clear()
	if _sky_cheer_hud_layer != null and is_instance_valid(_sky_cheer_hud_layer):
		for child in _sky_cheer_hud_layer.get_children():
			if is_instance_valid(child):
				child.queue_free()
	if _sky_cheer_hud_layer != null and is_instance_valid(_sky_cheer_hud_layer):
		for child in _sky_cheer_hud_layer.get_children():
			if is_instance_valid(child):
				child.queue_free()
	if _sky_cheer_hud_layer != null and is_instance_valid(_sky_cheer_hud_layer):
		for child in _sky_cheer_hud_layer.get_children():
			if is_instance_valid(child):
				child.queue_free()

func _update_sky_cheer_spawns() -> void:
	if not gameplay_active or is_intro or is_failed or is_finished:
		return
	if _tutorial_paused:
		return
	if _sky_cheer_hud_layer == null:
		return
	for i in _sky_cheer_schedule.size():
		var item: Dictionary = _sky_cheer_schedule[i]
		if bool(item.get("spawned", false)):
			continue
		var ready_by_distance := track_distance >= float(item.get("d", 0.0))
		var ready_by_time := elapsed >= float(item.get("at_time", 99999.0))
		if not ready_by_distance and not ready_by_time:
			continue
		item["spawned"] = true
		_sky_cheer_schedule[i] = item
		_spawn_sky_cheer_line(String(item.get("zh", "")), String(item.get("en", "")))

func _sky_cheer_spawn_y(layer_h: float) -> float:
	return layer_h * 0.24

func _spawn_sky_cheer_line(zh: String, en: String) -> void:
	if (zh == "" and en == "") or _sky_cheer_hud_layer == null:
		return
	var layer_w := maxf(_sky_cheer_hud_layer.size.x, MOBILE_VIEWPORT_SIZE.x)
	var layer_h := maxf(_sky_cheer_hud_layer.size.y, MOBILE_VIEWPORT_SIZE.y)
	var max_text_w := layer_w * SKY_CHEER_MAX_WIDTH_RATIO
	var block := VBoxContainer.new()
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	block.add_theme_constant_override("separation", 3)
	if en != "":
		var en_lab := Label.new()
		en_lab.text = en
		en_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		en_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		en_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		en_lab.custom_minimum_size = Vector2(max_text_w, 0.0)
		en_lab.add_theme_font_size_override("font_size", SKY_CHEER_EN_FONT)
		en_lab.add_theme_color_override("font_color", Color(1.0, 0.98, 0.82, 1.0))
		en_lab.add_theme_color_override("font_outline_color", Color(0.06, 0.03, 0.01, 0.92))
		en_lab.add_theme_constant_override("outline_size", 10)
		block.add_child(en_lab)
	if zh != "":
		var zh_lab := Label.new()
		zh_lab.text = zh
		zh_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		zh_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		zh_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		zh_lab.custom_minimum_size = Vector2(max_text_w, 0.0)
		zh_lab.add_theme_font_size_override("font_size", SKY_CHEER_ZH_FONT)
		zh_lab.add_theme_color_override("font_color", Color(1.0, 0.94, 0.68, 0.96))
		zh_lab.add_theme_color_override("font_outline_color", Color(0.06, 0.03, 0.01, 0.88))
		zh_lab.add_theme_constant_override("outline_size", 8)
		block.add_child(zh_lab)
	block.modulate = Color(1, 1, 1, 0)
	block.z_index = 20
	_sky_cheer_hud_layer.add_child(block)
	block.reset_size()
	var y := _sky_cheer_spawn_y(layer_h)
	var center_x := (layer_w - block.size.x) * 0.5
	block.position = Vector2(center_x, y)
	block.pivot_offset = block.size * 0.5
	block.scale = Vector2(SKY_CHEER_SCALE, SKY_CHEER_SCALE)
	var life := _sky_cheer_rng.randf_range(3.6, 4.8)
	_sky_cheer_active.append({
		"root": block,
		"label": block,
		"age": 0.0,
		"life": life,
		"center_x": center_x,
		"y": y,
		"bob": _sky_cheer_rng.randf_range(0.8, 1.1),
		"phase": _sky_cheer_rng.randf() * TAU,
	})

func _update_sky_cheer_visuals(delta: float) -> void:
	if _sky_cheer_active.is_empty():
		return
	var remain: Array[Dictionary] = []
	for entry in _sky_cheer_active:
		var block := entry.get("root", entry.get("label")) as Control
		if block == null or not is_instance_valid(block):
			continue
		var age := float(entry.get("age", 0.0)) + delta
		entry["age"] = age
		var life := maxf(float(entry.get("life", 4.0)), 0.1)
		var t := age / life
		var fade_in := clampf(age / 0.35, 0.0, 1.0)
		var fade_out := clampf((1.0 - t) / 0.45, 0.0, 1.0)
		var alpha := minf(fade_in, fade_out)
		block.modulate = Color(1, 1, 1, alpha)
		var bob := float(entry.get("bob", 1.0))
		var phase := float(entry.get("phase", 0.0))
		var y0 := float(entry.get("y", block.position.y))
		block.position.x = float(entry.get("center_x", block.position.x))
		block.position.y = y0 + sin(age * bob + phase) * 4.0
		block.scale = Vector2(SKY_CHEER_SCALE, SKY_CHEER_SCALE)
		if t < 1.0 and alpha > 0.01:
			remain.append(entry)
		else:
			block.queue_free()
	_sky_cheer_active = remain

func _orb_pop_visual_scale(pop: float) -> float:
	return lerpf(0.05, 1.0, pop * pop)

func _orb_collision_scale(obstacle: Dictionary) -> float:
	if not bool(obstacle.get("float_orb", false)):
		return 1.0
	if not bool(obstacle.get("orb_revealed", false)):
		return 0.0
	var pop := float(obstacle.get("orb_pop", 0.0))
	if pop < ORB_COLLISION_POP_MIN:
		return 0.0
	return _orb_pop_visual_scale(pop)

func _obstacle_world_near_player(obstacle: Dictionary) -> bool:
	# 路程对上但模型在另一条岔路上：不能撞碎「看不见」的东西
	var node := obstacle.get("node") as Node3D
	if node == null or not is_instance_valid(node) or player == null:
		return false
	if not node.visible:
		return false
	var delta: Vector3 = node.global_position - player.global_position
	delta.y = 0.0
	var max_r := 5.2
	if _is_full_width_obstacle_type(String(obstacle.get("type", ""))):
		max_r = 6.4
	return delta.length() <= max_r


func _obstacle_collision_active(obstacle: Dictionary) -> bool:
	if bool(obstacle.get("float_orb", false)):
		if not _obstacle_has_meaningful_visual(obstacle):
			return false
		return _orb_collision_scale(obstacle) > 0.02
	var otype := String(obstacle.get("type", ""))
	if otype == "energy_ring":
		return false
	if otype == "meteorite":
		if bool(obstacle.get("fall_roll", false)) and String(obstacle.get("meteor_state", "sky")) == "sky":
			return false
		var air_y := float(obstacle.get("meteor_air_y", obstacle.get("y_offset", 0.0)))
		if air_y > 1.15:
			return false
	if otype == "main_block" and _main_block_obstacle_uses_platform(obstacle):
		return false
	if _is_distance_in_lava_platform_exclusion(
		float(obstacle.get("distance", 0.0)) + float(obstacle.get("move_offset", 0.0))
	):
		return false
	# 没有可见模型就不结算：避免弯道上「看不见却掉完整度」
	if otype != "" and otype != "main_block":
		if not _obstacle_has_meaningful_visual(obstacle):
			return false
	return true

func _obstacle_has_meaningful_visual(obstacle: Dictionary) -> bool:
	var node := obstacle.get("node") as Node3D
	if node == null or not is_instance_valid(node):
		return false
	if not node.visible:
		return false
	var visual: Node3D = node.get_node_or_null("JumpObstacleModel") as Node3D
	if visual == null:
		visual = node.get_node_or_null("SlideObstacleModel") as Node3D
	if visual == null:
		visual = node.get_node_or_null("TrainRoadBlockAsset") as Node3D
	if visual == null:
		visual = node.get_node_or_null("WaveArcBridgeModel") as Node3D
	if visual == null:
		visual = node.get_node_or_null("WaveArcEnergyArch") as Node3D
	if visual == null:
		visual = node.get_node_or_null("MeteoriteObstacleModel") as Node3D
	if visual == null:
		visual = node.get_node_or_null("TrainWaveBlade") as Node3D
	if visual == null:
		visual = node.get_node_or_null("EnergyRingModel") as Node3D
	if visual == null:
		visual = node.get_node_or_null("LaneDodgeBarrier_0") as Node3D
	if visual == null:
		visual = node
	if visual == null:
		return false
	if "MissingFallback" in visual.name:
		return false
	if bool(obstacle.get("float_orb", false)):
		var pop := float(obstacle.get("orb_pop", 0.0))
		if pop < ORB_COLLISION_POP_MIN:
			return false
	var bounds := _compute_node_aabb(visual)
	if bounds.size.y < 0.16:
		return false
	var footprint := maxf(bounds.size.x, bounds.size.z)
	return footprint >= 0.35

func _check_obstacles(dist_from: float, dist_to: float) -> void:
	if _hit_iframe_timer > 0.0:
		return
	# 左安全岔：障碍不结算伤害，真正「安全」
	if _is_on_safe_fork():
		return
	var span_min := minf(dist_from, dist_to)
	var span_max := maxf(dist_from, dist_to)
	# 按速度加厚判定带，高速时避免“穿模漏检”
	var speed_pad := maxf(absf(dist_to - dist_from) * 0.32, 0.08)
	var scan_ahead := span_max + 6.0
	var i := _obstacle_scan_index
	var n := obstacles.size()
	while i < n:
		var obstacle: Dictionary = obstacles[i]
		var obstacle_type := String(obstacle.get("type", ""))
		if obstacle_type in ["ramp", "turn_left", "turn_right"]:
			i += 1
			continue
		if bool(obstacle.get("hit", false)):
			i += 1
			continue
		if int(obstacle.get("layer", 0)) != track_layer:
			i += 1
			continue
		if int(obstacle.get("fork_branch", 0)) != 0 and _fork_side != int(obstacle.get("fork_branch", 0)):
			i += 1
			continue
		# 已选岔路时，主路障碍（含全宽滑铲）不应误伤分支上的玩家
		if _fork_side != 0 and int(obstacle.get("fork_branch", 0)) == 0:
			var obs_d := float(obstacle.get("distance", 0.0))
			if not _junction_fork_region_at(obs_d).is_empty() or not _y_fork_region_at(obs_d).is_empty():
				i += 1
				continue
		if not _obstacle_collision_active(obstacle):
			i += 1
			continue
		if not _obstacle_world_near_player(obstacle):
			i += 1
			continue
		var obs_dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
		var half := float(obstacle.get("half_depth", _obstacle_half_depth(obstacle_type)))
		if bool(obstacle.get("float_orb", false)):
			half *= _orb_collision_scale(obstacle)
			half += speed_pad * 0.1
		else:
			half += speed_pad
		var moving := bool(obstacle.get("moving", false))
		# 已远抛在身后：静态障碍推进扫描游标；移动障碍仍可能回头
		if obs_dist + half < span_min - 1.25:
			if not moving and i == _obstacle_scan_index:
				_obstacle_scan_index += 1
			i += 1
			continue
		# 静态且还很远：跳过（不 break，以免漏检后方已逼近的移动障碍）
		if not moving and obs_dist - half > scan_ahead:
			i += 1
			continue
		if span_max < obs_dist - half or span_min > obs_dist + half:
			i += 1
			continue
		if not _player_in_obstacle_lateral(obstacle):
			i += 1
			continue
		if not _obstacle_has_meaningful_visual(obstacle):
			i += 1
			continue
		if _hits_obstacle(obstacle):
			obstacle["hit"] = true
			if _is_fork_rushing():
				_hit_iframe_timer = FORK_RUSH_HIT_IFRAME
			else:
				_hit_iframe_timer = HIT_IFRAME_TIME
			_on_runner_strike(_strike_reason_for_obstacle(obstacle), obstacle)
			return
		i += 1

func _obstacle_half_depth(obstacle_type: String) -> float:
	return float(OBSTACLE_HALF_DEPTH.get(obstacle_type, 0.65))

func _obstacle_hit_window(obstacle: Dictionary) -> float:
	return _obstacle_half_depth(String(obstacle.get("type", ""))) + 0.35

func _lane_value_to_index(lane: int) -> int:
	for i in LANES.size():
		if LANES[i] == lane:
			return i
	return 1

func _player_in_obstacle_lateral(obstacle: Dictionary) -> bool:
	var obstacle_type := String(obstacle["type"])
	# 横跨全路的滑铲/高杆屏障 / 主路封堵 / 跳板 / 跳跃栏
	if _is_full_width_obstacle_type(obstacle_type):
		return true
	# 封左：左道+中道有障，只有右道 (≈+LANE_WIDTH) 可过
	if obstacle_type == "block_left":
		return current_lateral < LANE_WIDTH - LANE_BLOCK_SAFE_EDGE
	# 封右：中道+右道有障，只有左道 (≈-LANE_WIDTH) 可过
	if obstacle_type == "block_right":
		return current_lateral > -LANE_WIDTH + LANE_BLOCK_SAFE_EDGE
	var lane_x := float(obstacle["lane"]) * LANE_WIDTH
	if bool(obstacle.get("float_orb", false)):
		lane_x += float(obstacle.get("lateral_offset", 0.0))
		var hit_hw := float(obstacle.get("hit_half_width", 0.34)) * _orb_collision_scale(obstacle)
		return absf(current_lateral - lane_x) <= hit_hw
	if obstacle_type in ["train", "train_moving"]:
		var train_node := obstacle.get("node") as Node3D
		if train_node != null and bool(train_node.get_meta("has_wave_blade", false)):
			return true
	if obstacle_type == "energy_ring":
		var outer := float(obstacle.get("ring_outer_half", ENERGY_RING_OUTER_HALF))
		return absf(current_lateral - lane_x) <= outer + 0.14
	var half_w := LANE_HIT_HALF_WIDTH_JUMP if obstacle_type in ["jump", "low_barrier", "orb", "train", "train_moving"] else LANE_HIT_HALF_WIDTH
	if obstacle_type == "meteorite":
		half_w = float(obstacle.get("hit_half_width", LANE_WIDTH * 0.62))
	if obstacle_type == "meteorite":
		half_w = float(obstacle.get("hit_half_width", LANE_WIDTH * 0.62))
	if obstacle_type == "meteorite":
		half_w = float(obstacle.get("hit_half_width", LANE_WIDTH * 0.62))
	return absf(current_lateral - lane_x) <= half_w

func _collectible_in_pickup_range(node: Node3D, collectible: Dictionary) -> bool:
	var kind := String(collectible.get("kind", "coin"))
	var pickup_radius := 2.35 if kind == "shield_crystal" else 1.65
	if collectible.has("gate_train_dist"):
		pickup_radius = 3.35
	if kind == "coin":
		pickup_radius = 1.85
	var delta_pos := node.global_position - player.global_position
	var horiz := Vector2(delta_pos.x, delta_pos.z).length()
	var vert := absf(delta_pos.y)
	if kind == "shield_crystal":
		if horiz <= pickup_radius and vert <= 2.1:
			return true
		var along := absf(track_distance - float(collectible.get("distance", 0.0)))
		var lateral_gap := absf(current_lateral - float(collectible.get("lane", 0)) * LANE_WIDTH)
		return along <= pickup_radius + 1.0 and lateral_gap <= 2.5 and vert <= 2.4
	if bool(collectible.get("air", false)):
		if horiz <= pickup_radius and vert <= 1.55:
			return true
		if horiz <= 1.25 and vert <= 2.05:
			return true
		return false
	return horiz <= pickup_radius and vert <= 1.35

func _check_collectibles() -> void:
	for collectible in collectibles:
		if collectible["collected"]:
			continue
		if int(collectible.get("layer", 0)) != track_layer:
			continue
		var node := collectible["node"] as Node3D
		if node == null or not is_instance_valid(node):
			continue
		if not _collectible_in_pickup_range(node, collectible):
			continue
		collectible["collected"] = true
		node.visible = false
		var kind := String(collectible.get("kind", "coin"))
		if kind == "shield_crystal":
			crystal_collected_count += 1
			var before := shield_energy
			var restore := SHIELD_CRYSTAL_RESTORE
			shield_energy = minf(shield_energy + restore, SHIELD_MAX_ENERGY)
			_shield_warned_empty = false
			run_score += 8
			var gained := int(round(shield_energy - before))
			if gained > 0:
				_show_gate_toast("水晶充能 +%d" % gained)
			else:
				_show_gate_toast("护盾已满 · 水晶已吸收")
			_spawn_collectible_pickup_fx(node.global_position, kind)
			_pulse_shield_pickup_feedback(gained, node.global_position)
			camera_shake = maxf(camera_shake, 0.08)
		elif kind == "speed_boost":
			_register_speed_boost_pickup()
			_spawn_collectible_pickup_fx(node.global_position, kind)
		else:
			collected_count += 1
			run_score += int(LevelConfig.EMBER_COIN_VALUE)
			_register_coin_streak_pickup(node.global_position)

func _spawn_collectible_pickup_fx(world_pos: Vector3, kind: String) -> void:
	if track_root == null:
		return
	if kind == "coin" or kind == "":
		_spawn_coin_pickup_burst(world_pos)
		_pulse_coin_hud_feedback()
		camera_shake = maxf(camera_shake, 0.045)
		return
	var fx_cfg := _collectible_pickup_fx_config(kind)
	_spawn_pickup_particle_burst(world_pos, fx_cfg)
	if not bool(fx_cfg.get("show_ring", false)):
		return
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = float(fx_cfg.get("ring_inner", 0.12))
	ring_mesh.outer_radius = float(fx_cfg.get("ring_outer", 0.2))
	ring_mesh.rings = 6
	ring_mesh.ring_segments = 16
	var ring_color: Color = fx_cfg.get("ring_color", Color(1.0, 0.82, 0.28))
	ring_mesh.material = _make_material(ring_color, ring_color.lightened(0.15), float(fx_cfg.get("ring_emission", 1.4)))
	(ring_mesh.material as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.mesh = ring_mesh
	ring.rotation.x = PI * 0.5
	track_root.add_child(ring)
	ring.global_position = world_pos + Vector3(0.0, 0.1, 0.0)
	var tween := create_tween()
	var ring_scale := float(fx_cfg.get("ring_scale", 1.45))
	tween.tween_property(ring, "scale", Vector3(ring_scale, ring_scale, ring_scale), float(fx_cfg.get("ring_duration", 0.22))).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(ring.queue_free)


func _update_runner_sky_presentation(_delta: float) -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	if not _background_uses_sky_panorama():
		return
	var env := _world_environment.environment
	var prog := clampf(track_distance / maxf(_track_length, 1.0), 0.0, 1.0)
	var path_yaw_rad := deg_to_rad(_path_yaw)
	# 全程随里程轻滚全景 + 转弯补偿：云层/明暗带在整局内持续变化
	var scroll_mult := 0.04 if _is_relay_mission() else 1.0
	var turn_comp := 0.05 if _is_relay_mission() else 0.48
	if _is_relay_mission():
		scroll_mult = 0.22
		turn_comp = 0.12
	elif _mission_id_str() in ["mission_reservoir_03", "mission_reservoir_04"]:
		# 对着全景里太阳/云那一段，不要滚出画面
		scroll_mult = 0.18
	elif _mission_id_str() == "mission_reservoir_02":
		scroll_mult = 0.16
		turn_comp = 0.10
	elif _mission_id_str() == "mission_medical_m2":
		# 第二关需要整局云层明暗滚得更明显，但仍停在云带上
		scroll_mult = 0.22
		turn_comp = 0.10
	elif _uses_medical_sunrise_sky():
		# 医疗二三关一旦滚偏就会变成一片，并可能滚进发绿的区域
		scroll_mult = 0.06
		turn_comp = 0.08
	var scroll := prog * SKY_PROGRESS_SCROLL * scroll_mult
	var sky_yaw := _base_sky_yaw + scroll - path_yaw_rad * turn_comp
	var target_fog := _base_fog_light_color
	var target_amb := _base_ambient_light_color
	var cloud_phase := elapsed * 0.40 + prog * 5.8 + track_distance * 0.0020
	var pan_energy := _base_panorama_energy
	if _mission_id_str() == "mission_medical_m2":
		pan_energy = _base_panorama_energy * (0.86 + 0.16 * sin(cloud_phase) + 0.10 * sin(cloud_phase * 1.72))
	elif _mission_id_str() == "mission_reservoir_02":
		pan_energy = _base_panorama_energy * (0.92 + 0.10 * sin(cloud_phase) + 0.06 * sin(cloud_phase * 1.64))
	else:
		pan_energy = _base_panorama_energy * (1.0 + 0.040 * sin(cloud_phase) + 0.024 * sin(cloud_phase * 2.31))
	env.sky_rotation = Vector3(_base_sky_pitch, sky_yaw, 0.0) if _uses_reservoir_sky_gradient() else Vector3(_base_sky_pitch, sky_yaw, 0.0)
	var sky_mat := env.sky.sky_material if env.sky != null else null
	if _is_relay_mission() and sky_mat is PanoramaSkyMaterial:
		var pan := sky_mat as PanoramaSkyMaterial
		var base_e := maxf(_base_panorama_energy, 0.01)
		pan.energy_multiplier = base_e * (
			0.98 + 0.03 * sin(cloud_phase) + 0.015 * sin(cloud_phase * 2.1 + 0.7)
		)
	elif _is_relay_mission() and sky_mat is ShaderMaterial:
		_apply_relay_graded_sky(sky_mat as ShaderMaterial, cloud_phase)
	elif _is_relay_mission() and sky_mat is ProceduralSkyMaterial:
		_apply_relay_procedural_sky(sky_mat as ProceduralSkyMaterial, cloud_phase)
	elif _uses_reservoir_sky_gradient() and sky_mat is ShaderMaterial:
		_apply_reservoir_graded_sky(sky_mat as ShaderMaterial, cloud_phase)
	elif _uses_reservoir_sky_gradient() and sky_mat is ProceduralSkyMaterial:
		_apply_reservoir_procedural_sky(sky_mat as ProceduralSkyMaterial, cloud_phase)
	elif sky_mat is PanoramaSkyMaterial:
		(sky_mat as PanoramaSkyMaterial).energy_multiplier = pan_energy
	var sun := get_node_or_null("RunnerSun") as DirectionalLight3D
	if sun:
		var sun_sway := sin(elapsed * 0.46) * 2.6
		var sun_sink := prog * 6.0
		sun.rotation_degrees = Vector3(
			_base_sun_rot.x + sun_sway + sun_sink,
			_base_sun_rot.y + prog * 10.0,
			_base_sun_rot.z
		)
		var light_pulse := 0.93 + 0.07 * sin(elapsed * 0.62 + prog * 3.2)
		sun.light_energy = _base_sun_energy * light_pulse
		if _is_relay_mission():
			# 只微脉冲能量，颜色保持近白，避免把 runner/建筑染成天空色
			sun.light_energy = _base_sun_energy * (0.94 + 0.08 * sin(elapsed * 0.48 + prog * 2.1))
			sun.light_color = _base_sun_color
		elif _mission_id_str() == "mission_reservoir_02":
			sun.rotation_degrees = Vector3(-48.0 + sun_sway * 0.4, 28.0 + prog * 8.0, 0.0)
			var rose := Color(0.98, 0.70, 0.78)
			var lilac := Color(0.82, 0.64, 0.92)
			sun.light_color = rose.lerp(lilac, 0.38 + 0.28 * sin(elapsed * 0.32 + prog * 1.7))
			sun.light_energy = _base_sun_energy * (0.90 + 0.12 * sin(elapsed * 0.36 + prog * 1.9))
		elif _mission_id_str() == "mission_medical_m2":
			sun.rotation_degrees = Vector3(-50.0 + sun_sway * 0.55, 32.0 + prog * 10.0, 0.0)
			var warm := Color(0.96, 0.78, 0.56)
			var cool_m2 := Color(0.70, 0.74, 0.96)
			sun.light_color = warm.lerp(cool_m2, 0.32 + 0.42 * sin(elapsed * 0.30 + prog * 1.8))
			sun.light_energy = _base_sun_energy * (0.82 + 0.20 * sin(elapsed * 0.34 + prog * 2.0))
		elif _mission_id_str() == "mission_reservoir_03":
			sun.rotation_degrees = Vector3(-52.0 + sun_sway * 0.35, 35.0 + prog * 8.0, 0.0)
			sun.light_color = Color(0.96, 0.78, 0.52)
			sun.light_energy = _base_sun_energy * (0.95 + 0.06 * sin(elapsed * 0.30 + prog * 1.5))
		elif _mission_id_str() == "mission_reservoir_04":
			sun.rotation_degrees = Vector3(-52.0 + sun_sway * 0.35, 35.0 + prog * 8.0, 0.0)
			sun.light_color = Color(0.96, 0.78, 0.52)
			sun.light_energy = _base_sun_energy * (0.95 + 0.06 * sin(elapsed * 0.30 + prog * 1.5))
		elif _uses_medical_sunrise_sky():
			sun.rotation_degrees = Vector3(-52.0 + sun_sway * 0.30, 35.0 + prog * 6.0, 0.0)
			sun.light_color = _base_sun_color
			sun.light_energy = _base_sun_energy * (0.96 + 0.05 * sin(elapsed * 0.28 + prog * 1.3))
		elif _uses_reservoir_sky_gradient():
			var dusk := Color(minf(_base_sun_color.r * 0.92, 1.0), _base_sun_color.g * 0.78, minf(_base_sun_color.b * 1.18, 1.0))
			sun.light_color = _base_sun_color.lerp(dusk, clampf(prog * 0.85, 0.0, 1.0))
		else:
			# 夕照微暖 ↔ 略冷 随路程变化，增强光影层次（不是一片黄）
			var warmth := clampf(1.0 - prog * 0.22, 0.72, 1.0)
			var cool := Color(_base_sun_color.r * 0.88, _base_sun_color.g * 0.92, minf(_base_sun_color.b * 1.12, 1.0))
			sun.light_color = cool.lerp(_base_sun_color, warmth)
	if _is_relay_mission():
		_apply_relay_nightscape_atmosphere_tint(env, prog, cloud_phase)
	elif _uses_near_far_light_split():
		_apply_dome_h1_atmosphere_tint(env, prog, cloud_phase)
	elif _uses_reservoir_sky_gradient() and _mission_id_str() not in ["mission_reservoir_03", "mission_reservoir_04"]:
		_apply_reservoir_later_atmosphere_tint(env, prog, cloud_phase)
	if not _sandstorm_active:
		if _uses_reservoir_sky_dome():
			env.fog_enabled = false
			env.fog_aerial_perspective = 0.0
		elif _uses_medical_sunrise_sky() or (not _uses_reservoir_sky_gradient() and not _is_relay_mission()):
			env.fog_light_color = env.fog_light_color.lerp(target_fog, 0.06)
			env.ambient_light_color = env.ambient_light_color.lerp(target_amb, 0.05)
			env.fog_density = lerpf(env.fog_density, _base_fog_density, 0.04)


func _apply_relay_nightscape_atmosphere_tint(env: Environment, prog: float, phase: float) -> void:
	# 水源一式：不重染雾/环境光；只做轻微能量脉冲，保住本色与明暗
	if env.fog_enabled:
		env.fog_enabled = false
	env.fog_aerial_perspective = 0.0
	env.ambient_light_color = _base_ambient_light_color
	env.ambient_light_energy = lerpf(
		env.ambient_light_energy,
		_base_ambient_light_energy * (0.96 + 0.04 * sin(phase * 0.55 + prog * 1.6)),
		0.08
	)
	if env.glow_enabled:
		var pulse := 0.5 + 0.5 * sin(phase * 0.68 + prog * 3.8)
		env.glow_intensity = 0.08 + 0.04 * pulse
		env.glow_strength = 0.24 + 0.05 * pulse
	var sun := get_node_or_null("RunnerSun") as DirectionalLight3D
	if sun:
		# 能量随里程微变，颜色锁在基准近白光
		sun.light_color = _base_sun_color
		sun.light_energy = _base_sun_energy * (0.94 + 0.08 * sin(phase * 0.48 + prog * 2.1))


func _apply_relay_atmosphere_tint(env: Environment, phase: float) -> void:
	var spark := Color(0.22, 0.48, 0.86)
	var ember := Color(0.18, 0.22, 0.42)
	match _mission_id_str():
		"mission_relay_e2":
			spark = Color(0.18, 0.62, 0.98)
			ember = Color(0.16, 0.28, 0.52)
		"mission_relay_e3":
			spark = Color(0.78, 0.28, 0.72)
			ember = Color(0.32, 0.12, 0.36)
		"mission_relay_e4":
			spark = Color(0.42, 0.78, 1.00)
			ember = Color(0.22, 0.32, 0.58)
	var blend := (sin(phase * 0.28) + 1.0) * 0.5
	var tint := ember.lerp(spark, 0.35 + blend * 0.25)
	env.fog_light_color = _base_fog_light_color.lerp(tint, 0.10)
	env.ambient_light_color = _base_ambient_light_color.lerp(tint, 0.08)
	env.fog_aerial_perspective = lerpf(
		env.fog_aerial_perspective,
		clampf(env.fog_aerial_perspective + 0.012, 0.034, 0.052),
		0.18
	)
	if env.glow_enabled:
		env.glow_intensity = 0.16 + 0.08 * (0.5 + 0.5 * sin(phase * 1.45))
		env.glow_strength = 0.38 + 0.10 * (0.5 + 0.5 * sin(phase * 0.88 + 0.6))


func _apply_dome_h1_atmosphere_tint(env: Environment, prog: float, phase: float) -> void:
	# 近景昏黄路侧暖光，远景紫雾穹顶 —— 参考废墟长桥概念
	var near_warm := Color(0.34, 0.24, 0.16)
	var far_purple := Color(0.42, 0.18, 0.58)
	var far_mix := clampf(prog * 1.08 + 0.08, 0.0, 1.0)
	var pulse := 0.5 + 0.5 * sin(phase * 0.72 + prog * 4.2)
	env.fog_light_color = _base_fog_light_color.lerp(near_warm, 0.18).lerp(far_purple, far_mix * 0.62)
	env.ambient_light_color = _base_ambient_light_color.lerp(near_warm, 0.12).lerp(
		far_purple.lightened(0.08),
		far_mix * 0.34
	)
	env.fog_density = lerpf(_base_fog_density, _base_fog_density * (1.08 + far_mix * 0.22), 0.06)
	env.fog_aerial_perspective = lerpf(
		env.fog_aerial_perspective,
		clampf(0.12 + far_mix * 0.06, 0.08, 0.18),
		0.05
	)
	if env.glow_enabled:
		env.glow_intensity = 0.16 + 0.10 * pulse
		env.glow_strength = 0.34 + 0.12 * pulse
	var sun := get_node_or_null("RunnerSun") as DirectionalLight3D
	if sun:
		var warm := Color(0.82, 0.56, 0.32)
		var cool := Color(0.58, 0.48, 0.72)
		sun.light_color = warm.lerp(cool, far_mix * 0.55)
		sun.light_energy = _base_sun_energy * lerpf(0.92, 0.72, far_mix)


func _apply_reservoir_later_atmosphere_tint(env: Environment, prog: float, phase: float) -> void:
	# 水源后续关：沿路程做粉紫渐变，明暗随关卡不同，不回到第一关橙黄夕照
	var near := Color(0.56, 0.36, 0.44)
	var far := Color(0.50, 0.30, 0.64)
	var mix_amt := 0.48
	match _mission_id_str():
		"mission_reservoir_02":
			near = Color(0.56, 0.48, 0.72)
			far = Color(0.36, 0.42, 0.70)
			mix_amt = 0.34
		"mission_reservoir_03":
			near = Color(0.58, 0.60, 0.70)
			far = Color(0.48, 0.54, 0.72)
			mix_amt = 0.08
		"mission_reservoir_04":
			near = Color(0.36, 0.16, 0.28)
			far = Color(0.28, 0.10, 0.24)
			mix_amt = 0.32
	var far_mix := clampf(prog * 0.95, 0.0, 1.0)
	var pulse := 0.5 + 0.5 * sin(phase * 0.64 + prog * 3.6)
	env.fog_light_color = _base_fog_light_color.lerp(near, 0.14).lerp(far, far_mix * mix_amt)
	env.ambient_light_color = _base_ambient_light_color.lerp(near.lightened(0.06), 0.10).lerp(
		far.lightened(0.08),
		far_mix * 0.36
	)
	if _uses_reservoir_sky_gradient():
		var shade := 0.88 + 0.18 * pulse
		if _mission_id_str() == "mission_reservoir_04":
			shade = 0.78 + 0.16 * pulse
		env.ambient_light_energy = lerpf(env.ambient_light_energy, _base_ambient_light_energy * shade, 0.12)
	if env.glow_enabled:
		env.glow_intensity = 0.14 + 0.10 * pulse
		env.glow_strength = 0.32 + 0.12 * pulse


func _uses_json_obstacle_layout() -> bool:
	return _runner_layout_id() != ""


func _is_early_outpost_location() -> bool:
	var loc := String(Global.runner_location_id)
	if LevelConfig != null and LevelConfig.has_method("is_early_outpost_location"):
		return LevelConfig.is_early_outpost_location(loc)
	return loc in ["dome", "reservoir"]


func _is_reservoir_location() -> bool:
	if String(Global.runner_location_id) == "reservoir":
		return true
	return String(mission.get("location_id", "")) == "reservoir"


func _is_gate_location() -> bool:
	if String(Global.runner_location_id) == "gate":
		return true
	return String(mission.get("location_id", "")) == "gate"


func _reservoir_orb_tint_at(distance: float) -> String:
	# 第二关天空偏浅，紫球能看清；其它粉紫关仍用青/金拉开对比。
	if _mission_id_str() == "mission_reservoir_02":
		return "purple"
	var cycle: Array[String] = ["cyan", "gold", "teal"]
	return cycle[absi(int(round(distance * 0.37))) % cycle.size()]


func _uses_reservoir_sky_gradient() -> bool:
	# 水源第二关改走第一关全景粉紫偏色，不再用会洗成一片紫的程序天
	return false


func _uses_medical_sunrise_sky() -> bool:
	return _mission_id_str().begins_with("mission_medical_")


func _uses_reservoir_baked_sky() -> bool:
	# 第三/四关改走真实全景图，不再运行时烘焙平涂天
	return false


func _reservoir_photo_sky_texture() -> Texture2D:
	# 水源三四关：用第一关已验证全景。医疗关不要走这条（会开 REALTIME cubemap 平均成一片粉）
	if _mission_id_str() in ["mission_reservoir_03", "mission_reservoir_04"]:
		return RESERVOIR_W1_SKY_PANORAMA
	return null


func _uses_reservoir_sky_dome() -> bool:
	# 第三/四关都走第一关同款世界全景，镜头天空板会跟着跳跃一起抬
	return false


func _is_relay_mission() -> bool:
	if String(Global.runner_location_id) == "relay":
		return true
	return String(mission.get("mission_id", "")).begins_with("mission_relay")


func _is_full_track_rain() -> bool:
	if String(mission.get("weather", "")).to_lower() == "rain":
		return true
	return _mission_id_str() == "mission_relay_rain"


func _is_relay_run_task() -> bool:
	# 各据点运输任务类型「Relay Run / 中继」，不是星火中继站 location
	return String(mission.get("task_type", "")).strip_edges() == "Relay Run"


func _is_rain_weather() -> bool:
	# 全图雨、分段毒雨、或本局已启用雨效
	if _rain_active:
		return true
	return _is_full_track_rain()


func _relay_disables_fog() -> bool:
	# 中继站默认关雾；启用毒雨（全图或分段）时保留薄雾
	return _is_relay_mission() and not _rain_active


func _rain_zones() -> Array:
	if not _cached_rain_zones.is_empty():
		return _cached_rain_zones
	var out: Array = []
	var mission_zones: Variant = mission.get("rain_zones", [])
	if typeof(mission_zones) == TYPE_ARRAY:
		for raw in mission_zones:
			if typeof(raw) == TYPE_DICTIONARY:
				out.append(ObstacleLayout.normalize_rain_zone(raw))
	var layout_id := _runner_layout_id()
	if layout_id != "":
		for raw in ObstacleLayout.load_rain_zones(layout_id):
			if typeof(raw) == TYPE_DICTIONARY:
				out.append(raw)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("start", 0.0)) < float(b.get("start", 0.0))
	)
	_cached_rain_zones = out
	return _cached_rain_zones


func _rain_zone_at(distance: float) -> Dictionary:
	for zone in _rain_zones():
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 60.0))
		if distance >= start and distance <= start + length:
			return zone
	return {}


func _is_in_rain_hazard_at(distance: float) -> bool:
	if not _rain_active:
		return false
	if _rain_full_track:
		return true
	return not _rain_zone_at(distance).is_empty()


func _current_rain_intensity() -> float:
	var base := clampf(float(mission.get("rain_intensity", 1.0)), 0.35, 1.6)
	if _rain_full_track:
		return base
	var zone := _rain_zone_at(track_distance)
	if zone.is_empty():
		return 0.0
	return clampf(float(zone.get("intensity", base)), 0.35, 1.6)


func _generate_random_rain_zones(count: int = 1) -> Array:
	var track_end := maxf(maxf(_path_length, _track_length) * 0.88, 180.0)
	var out: Array = []
	var cursor := 80.0 + _rain_puddle_rng.randf_range(0.0, 40.0)
	for _i in range(maxi(count, 1)):
		if cursor + 50.0 >= track_end:
			break
		var length := _rain_puddle_rng.randf_range(55.0, 110.0)
		var start := cursor + _rain_puddle_rng.randf_range(0.0, 30.0)
		if start + length > track_end:
			length = maxf(track_end - start, 40.0)
		out.append(ObstacleLayout.normalize_rain_zone({
			"start": start,
			"length": length,
			"intensity": _rain_puddle_rng.randf_range(0.75, 1.15),
			"label": "突发毒雨",
			"rain_kind": "toxic",
		}))
		cursor = start + length + _rain_puddle_rng.randf_range(90.0, 160.0)
	return out


func _mission_id_str() -> String:
	return String(mission.get("mission_id", Global.runner_mission_id))


func _is_dome_h1_mission() -> bool:
	return _mission_id_str() == "mission_dome_h1"


func _mission_visual_scene() -> Dictionary:
	var raw: Variant = mission.get("visual_scene", {})
	return raw if typeof(raw) == TYPE_DICTIONARY else {}


func _uses_ruin_dressing() -> bool:
	return _is_dome_h1_mission() or bool(_mission_visual_scene().get("ruin_dressing", false))


func _uses_runway_side_lights() -> bool:
	return _is_dome_h1_mission() or bool(_mission_visual_scene().get("runway_side_lights", false))


func _uses_near_far_light_split() -> bool:
	return _is_dome_h1_mission() or bool(_mission_visual_scene().get("near_far_light_split", false))


func _uses_beat_sync_content() -> bool:
	# 所有 JSON 布局关：128BPM 拍点对齐障碍 + 节奏金币
	return _uses_json_obstacle_layout()


func _finish_straight_zone_start() -> float:
	return maxf(_track_length * 0.82, FINISH_STRAIGHT_MIN)


func _effective_finish_distance() -> float:
	if _finish_line_distance > 0.0:
		return _finish_line_distance
	return maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)


func _register_coin_streak_pickup(world_pos: Vector3) -> void:
	_coin_streak_count += 1
	var streak_window := COIN_STREAK_WINDOW
	streak_window *= 1.12 + clampf((_visual_speed_ratio() - 1.0) * 0.18, 0.0, 0.22)
	_coin_streak_timer = streak_window
	_spawn_coin_pickup_burst(world_pos, _coin_streak_count)
	_pulse_coin_screen_flash(_coin_streak_count)
	_pulse_coin_hud_feedback(_coin_streak_count)
	if _coin_streak_count >= 3 and trail_particles:
		trail_particles.amount_ratio = minf(trail_particles.amount_ratio + 0.06, 0.75)
		_set_trail_color(Color(1.0, 0.82, 0.22, 0.72))
	camera_shake = maxf(camera_shake, 0.03 + minf(float(_coin_streak_count) * 0.006, 0.06))


func _spawn_coin_pickup_burst(world_pos: Vector3, streak: int = 1) -> void:
	if track_root == null:
		return
	var gold := Color(1.0, 0.88, 0.28)
	var bright := Color(1.0, 0.96, 0.55)
	var white := Color(1.0, 0.98, 0.82)
	var streak_idx := maxi(streak - 1, 0)
	_spawn_coin_arc_pop_label(world_pos, streak)
	# 参考 50s：金色 + 白色火花粒子
	var particles := GPUParticles3D.new()
	particles.name = "CoinGoldFx"
	particles.one_shot = true
	particles.emitting = true
	particles.amount = mini(28 + streak * 3, 48)
	particles.lifetime = 0.44 + minf(float(streak) * 0.01, 0.08)
	particles.explosiveness = 0.98
	particles.fixed_fps = 0
	track_root.add_child(particles)
	particles.global_position = world_pos + Vector3(0.0, 0.55, 0.0)
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.0, 1.0, -0.12)
	mat.spread = lerpf(155.0, 72.0, clampf(float(streak_idx) / 8.0, 0.0, 1.0))
	mat.initial_velocity_min = 1.4 + minf(float(streak) * 0.08, 0.55)
	mat.initial_velocity_max = 4.0 + minf(float(streak) * 0.12, 0.85)
	mat.gravity = Vector3(0.0, -6.5, 0.0)
	mat.scale_min = 0.16
	mat.scale_max = 0.42
	mat.color = gold
	particles.process_material = mat
	if _coin_pickup_burst_mesh == null:
		_coin_pickup_burst_mesh = _make_pickup_particle_mesh(0.055, gold, 5.2)
	particles.draw_pass_1 = _coin_pickup_burst_mesh
	particles.restart()
	var sparks := GPUParticles3D.new()
	sparks.name = "CoinSparkFx"
	sparks.one_shot = true
	sparks.emitting = true
	sparks.amount = mini(12 + streak, 22)
	sparks.lifetime = 0.32
	sparks.explosiveness = 1.0
	track_root.add_child(sparks)
	sparks.global_position = world_pos + Vector3(0.0, 0.62, 0.0)
	var spark_mat := ParticleProcessMaterial.new()
	spark_mat.direction = Vector3(0.05, 1.0, 0.0)
	spark_mat.spread = 180.0
	spark_mat.initial_velocity_min = 2.2
	spark_mat.initial_velocity_max = 5.5
	spark_mat.gravity = Vector3(0.0, -8.0, 0.0)
	spark_mat.scale_min = 0.06
	spark_mat.scale_max = 0.14
	spark_mat.color = white
	sparks.process_material = spark_mat
	if _coin_pickup_burst_mesh != null:
		sparks.draw_pass_1 = _make_pickup_particle_mesh(0.028, white, 6.5)
	sparks.restart()
	_spawn_coin_pickup_pentagon_layers(world_pos, gold, bright)
	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.18
	ring_mesh.outer_radius = 0.32
	ring_mesh.rings = 6
	ring_mesh.ring_segments = 18
	ring_mesh.material = _make_material(Color(1.0, 0.84, 0.22, 0.72), bright, 3.2)
	(ring_mesh.material as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.mesh = ring_mesh
	ring.rotation.x = PI * 0.5
	track_root.add_child(ring)
	ring.global_position = world_pos + Vector3(0.0, 0.22, 0.0)
	var ring_tw := create_tween()
	ring_tw.set_parallel(true)
	ring_tw.tween_property(ring, "scale", Vector3(2.0, 2.0, 2.0), 0.26).set_ease(Tween.EASE_OUT)
	ring_tw.tween_property(ring, "modulate:a", 0.0, 0.26)
	ring_tw.chain().tween_callback(ring.queue_free)
	get_tree().create_timer(0.62).timeout.connect(particles.queue_free)
	get_tree().create_timer(0.62).timeout.connect(sparks.queue_free)


func _spawn_coin_arc_pop_label(world_pos: Vector3, streak: int) -> void:
	if track_root == null or camera == null or player == null:
		return
	var bright := Color(1.0, 0.96, 0.55)
	var streak_idx := maxi(streak - 1, 0)
	var slot := streak_idx % 4
	var basis := camera.global_transform.basis
	var lane_bias := clampf((world_pos.x - player.global_position.x) * 0.22, -0.42, 0.42)
	var start := world_pos + Vector3(0.0, 0.40, 0.0) + basis.x * lane_bias
	var mid := start \
		+ basis.x * (0.30 + float(slot % 2) * 0.11 + lane_bias * 0.35) \
		+ basis.y * (0.58 + float(slot) * 0.06) \
		+ basis.z * (-0.12 - float(slot) * 0.02)
	var end := start \
		+ basis.x * (0.54 + float(slot % 2) * 0.09 + lane_bias * 0.25) \
		+ basis.y * (1.02 + float(slot) * 0.08) \
		+ basis.z * (-0.28 - float(slot) * 0.03)
	var lbl := Label3D.new()
	lbl.text = "+%d" % int(LevelConfig.EMBER_COIN_VALUE)
	lbl.font_size = 92 + mini(streak_idx, 12) * 4
	lbl.modulate = bright
	lbl.outline_modulate = Color(0.22, 0.10, 0.02, 0.92)
	lbl.outline_size = 10
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	track_root.add_child(lbl)
	lbl.global_position = start
	lbl.scale = Vector3(0.82, 0.82, 0.82)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_method(func(t: float):
		var u := 1.0 - t
		lbl.global_position = u * u * start + 2.0 * u * t * mid + t * t * end
		lbl.scale = Vector3.ONE * (0.82 + t * 0.20)
	, 0.0, 1.0, 0.54).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.54).set_delay(0.20).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(lbl.queue_free)


func _pulse_coin_screen_flash(streak: int) -> void:
	if _coin_screen_flash == null or not is_instance_valid(_coin_screen_flash):
		return
	var alpha := 0.06 + minf(float(streak) * 0.014, 0.24)
	_coin_screen_flash.visible = true
	_coin_screen_flash.color = Color(1.0, 0.86, 0.28, alpha)
	var tw := create_tween()
	tw.tween_property(_coin_screen_flash, "color:a", 0.0, 0.22).set_ease(Tween.EASE_OUT)


func _spawn_coin_pickup_pentagon_layers(world_pos: Vector3, gold: Color, bright: Color) -> void:
	if _coin_pickup_pentagon_ring_mesh == null:
		_coin_pickup_pentagon_ring_mesh = _make_polygon_ring_mesh(5, 0.70, 1.0)
	if _coin_pickup_pentagon_fill_mesh == null:
		_coin_pickup_pentagon_fill_mesh = _make_polygon_ring_mesh(5, 0.05, 0.86)
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color(gold.r, gold.g, gold.b, 0.82)
	ring_mat.emission_enabled = true
	ring_mat.emission = bright
	ring_mat.emission_energy_multiplier = 3.2
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flash := MeshInstance3D.new()
	flash.name = "CoinPentagonFlash"
	flash.mesh = _coin_pickup_pentagon_fill_mesh
	flash.material_override = ring_mat.duplicate()
	flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	track_root.add_child(flash)
	flash.global_position = world_pos + Vector3(0.0, 0.40, 0.0)
	flash.scale = Vector3(0.14, 0.14, 0.14)
	var flash_mat := flash.material_override as StandardMaterial3D
	var flash_tw := create_tween()
	flash_tw.set_parallel(true)
	flash_tw.tween_property(flash, "scale", Vector3(0.72, 0.72, 0.72), 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	flash_tw.tween_method(func(a: float):
		flash_mat.albedo_color.a = a
	, 0.72, 0.0, 0.22).set_ease(Tween.EASE_IN).set_delay(0.04)
	flash_tw.chain().tween_callback(flash.queue_free)
	for layer_i in 4:
		var pent := MeshInstance3D.new()
		pent.name = "CoinPentagonBurst"
		pent.mesh = _coin_pickup_pentagon_ring_mesh
		pent.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		track_root.add_child(pent)
		var base := 0.20 + float(layer_i) * 0.05
		pent.global_position = world_pos + Vector3(0.0, 0.36 + float(layer_i) * 0.025, 0.0)
		pent.scale = Vector3(base, base, base)
		pent.rotation_degrees.y = float(layer_i) * 8.0
		var fade_mat := ring_mat.duplicate() as StandardMaterial3D
		pent.material_override = fade_mat
		var tw := create_tween()
		tw.set_parallel(true)
		var delay := float(layer_i) * 0.045
		var end_scale := base * (2.55 + float(layer_i) * 0.20)
		tw.tween_property(pent, "scale", Vector3(end_scale, end_scale, end_scale), 0.36).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_delay(delay)
		tw.tween_property(pent, "rotation_degrees:y", pent.rotation_degrees.y + 14.0, 0.36).set_delay(delay)
		tw.tween_method(func(a: float):
			fade_mat.albedo_color.a = a
		, 0.82, 0.0, 0.34).set_ease(Tween.EASE_IN).set_delay(delay + 0.05)
		tw.chain().tween_callback(pent.queue_free)


func _pulse_coin_hud_feedback(streak: int = 1) -> void:
	for label in [collectible_label, score_label]:
		if label == null or not is_instance_valid(label):
			continue
		label.modulate = Color(1.0, 0.94, 0.28)
		var tw := create_tween()
		tw.tween_property(label, "modulate", Color(1, 1, 1), 0.22).set_ease(Tween.EASE_OUT)
	# 连吃 ≥4 时角标 xN
	if streak >= 4 and _coin_pickup_screen_fx != null and is_instance_valid(_coin_pickup_screen_fx):
		var hide_sec := COIN_STREAK_WINDOW
		_coin_pickup_screen_fx.play_combo_only(streak, hide_sec)


func _spawn_floating_pickup_label(text: String, world_pos: Vector3, color: Color = Color(1.0, 0.88, 0.22)) -> void:
	if track_root == null:
		return
	var label := Label3D.new()
	label.text = text
	label.font_size = 108
	label.modulate = color
	label.outline_size = 14
	label.outline_modulate = Color(0.10, 0.06, 0.02, 0.9)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	track_root.add_child(label)
	var start := world_pos + Vector3(0.0, 1.65, 0.0)
	label.global_position = start
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "global_position", start + Vector3(0.0, 2.35, 0.0), 0.78).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(label, "modulate:a", 0.0, 0.78).set_delay(0.22).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(label.queue_free)


func _pulse_shield_pickup_feedback(gained: int, world_pos: Vector3 = Vector3.ZERO) -> void:
	if _shield_energy_label != null and is_instance_valid(_shield_energy_label):
		_shield_energy_label.modulate = Color(0.45, 0.98, 1.0)
		_shield_energy_label.scale = Vector2(1.18, 1.18)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(_shield_energy_label, "modulate", Color(0.55, 0.95, 1.0), 0.36).set_ease(Tween.EASE_OUT)
		tw.tween_property(_shield_energy_label, "scale", Vector2.ONE, 0.36).set_ease(Tween.EASE_OUT)
	if shield_bar != null and is_instance_valid(shield_bar):
		shield_bar.modulate = Color(0.72, 1.0, 1.0)
		var bar_tw := create_tween()
		bar_tw.tween_property(shield_bar, "modulate", Color(1, 1, 1), 0.38).set_ease(Tween.EASE_OUT)
	if gained > 0:
		var pos := world_pos
		if pos == Vector3.ZERO and player != null:
			pos = player.global_position
		_spawn_floating_pickup_label("+%d" % gained, pos, Color(0.55, 0.95, 1.0))
		_show_runway_combat_tip("+%d 防护能量" % gained, Color(0.98, 0.72, 0.82, 1.0))
	elif world_pos != Vector3.ZERO:
		_spawn_floating_pickup_label("已满", world_pos, Color(0.72, 0.82, 0.92))


func _flash_coin_screen() -> void:
	if hud_root == null:
		return
	if _coin_screen_flash == null or not is_instance_valid(_coin_screen_flash):
		_coin_screen_flash = ColorRect.new()
		_coin_screen_flash.name = "CoinPickupFlash"
		_coin_screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_coin_screen_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_coin_screen_flash.color = Color(1.0, 0.86, 0.28, 0.0)
		_coin_screen_flash.z_index = 77
		hud_root.add_child(_coin_screen_flash)
	if _coin_flash_tween != null and is_instance_valid(_coin_flash_tween):
		_coin_flash_tween.kill()
	_coin_screen_flash.visible = true
	_coin_screen_flash.color = Color(1.0, 0.92, 0.38, 0.32 + minf(float(_coin_streak_count) * 0.04, 0.22))
	_coin_flash_tween = create_tween()
	_coin_flash_tween.tween_property(_coin_screen_flash, "color:a", 0.0, 0.18).set_ease(Tween.EASE_OUT)
	_coin_flash_tween.tween_callback(func():
		if _coin_screen_flash != null and is_instance_valid(_coin_screen_flash):
			_coin_screen_flash.visible = false
	)


func _mount_side_runway(zone: Dictionary, toast: String = "侧墙跑 · 上下换高度道") -> void:
	if zone.is_empty() or player == null:
		return
	# 必须先算墙侧再设墙跑层：_wall_zone_side 在墙跑中会锁定旧 _last_wall_side
	var mount_side := _wall_zone_side(zone, track_distance)
	track_layer = WALL_RUN_LAYER
	_end_slide()
	_wall_mount_armed = false
	_pit_fall_grace = 0.0
	_last_wall_side = mount_side
	lane_index = 1
	target_lane_x = 0.0
	current_lateral = 0.0
	current_wall_y = WALL_LANE_HEIGHTS[1]
	player.position.y = current_wall_y
	vertical_velocity = 0.0
	_wall_roll = mount_side * (PI * 0.5)
	camera_shake = maxf(camera_shake, 0.1)
	_sync_player_position()
	_apply_wall_run_body_orientation(mount_side)
	_show_gate_toast("侧墙 · 跳换高列 / 滑铲低列")
	_complete_wall_run_tutorial()

func _try_side_runway_entry() -> void:
	if track_layer != 0 or player == null:
		return
	if _skip_side_runway_while_on_fork_branch():
		_wall_mount_armed = false
		return
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		_wall_mount_armed = false
		return
	# 必须：靠墙最外道 → 再朝墙按一次（armed）→ 跳跃，才上墙
	if not _is_wall_mount_ready(zone):
		return
	if player.position.y < GROUND_Y + 0.85:
		return
	if vertical_velocity < -2.0:
		return
	_mount_side_runway(zone)

func _try_pit_entry_wall_rescue() -> void:
	# 坑口贴外墙：自动拉上墙，避免「还没跳就进坑」
	if track_layer != 0 or player == null or is_failed or is_finished:
		return
	if _skip_side_runway_while_on_fork_branch():
		return
	if not _is_in_side_runway_pit(track_distance):
		return
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		return
	if lane_index != _wall_edge_lane_index(zone):
		return
	if player.position.y > GROUND_Y + 1.35:
		return
	_mount_side_runway(zone, "侧墙跑 · 坑口自动上墙")

func _is_over_open_pit() -> bool:
	if track_layer != 0:
		return false
	# 岔路支线是实路，不能因为主路熔岩坑距离重叠而往下掉
	if _is_on_fork_branch_road(track_distance):
		return false
	if _is_on_narrow_beam():
		return false
	if _is_off_narrow_beam():
		return true
	if _is_in_side_runway_pit(track_distance):
		return true
	if not _is_in_main_block_pit(track_distance):
		return false
	# 熔岩平台模式：站在任意踏板/桥接板上时不算悬空
	if not _lava_platforms.is_empty() and player != null:
		var plat := _lava_platform_landing_y(player.position.y + 0.08, track_distance, current_lateral)
		if plat > GROUND_Y - 0.12:
			return false
	return true

func _main_block_platform_bridge_inset() -> float:
	# 与 _generate_lava_platform_specs 入口/出口桥一致，坑外保留主路
	return 0.92 + 0.28 + 0.92

func _main_block_platform_open_lava_range(center: float, half: float) -> Vector2:
	var inset := _main_block_platform_bridge_inset()
	var open_start := center - half + inset
	var open_end := center + half - inset
	if open_end <= open_start + 4.0:
		var shrink := half * 0.35
		return Vector2(center - shrink, center + shrink)
	return Vector2(open_start, open_end)

func _is_in_main_block_pit(distance: float) -> bool:
	# 只认真正挖开的路面缺口，避免「人还在蓝路上却按熔岩坑坠落」
	for gap in _main_block_road_gaps():
		if typeof(gap) == TYPE_VECTOR2 and distance >= gap.x and distance <= gap.y:
			return true
	return false

func _fail_into_pit(reason: String = "坠入主路熔岩坍塌坑") -> void:
	if is_failed or is_finished:
		return
	if _is_off_narrow_beam() or _open_gap_kind_at(track_distance) == "beam":
		reason = "偏离窄梁 · 回到中间道"
	elif _open_gap_kind_at(track_distance) == "launch":
		reason = "没踩上弹射垫 · 缺口前踩发光板飞过去"
	elif _lava_platforms.size() > 0:
		reason = "坠入熔岩 · 沿空中平台逐格跳跃通过"
	elif _wall_tut_step >= WALL_TUT_APPROACH and _wall_tut_step < WALL_TUT_DONE:
		reason = "坠入坍塌坑 · 需：贴墙道→再朝墙按→跳跃"
	# 定格成坠入坑中，而不是半空跳跃姿势
	if player != null:
		vertical_velocity = -12.0
		player.position.y = minf(player.position.y, GROUND_Y - 1.6)
		_sync_player_position()
		_set_player_pose("landing")
	camera_shake = maxf(camera_shake, 0.35)
	_fail_run(reason)

func _update_wall_jump_center_hint(delta: float) -> void:
	if _wall_jump_hint_label == null:
		return
	var show_hint := false
	if not is_finished and not is_failed and not _is_wall_running():
		var zone := _side_runway_entry_zone(track_distance)
		if zone.is_empty():
			zone = _side_runway_zone_at(track_distance)
		if not zone.is_empty():
			var start := float(zone.get("start", 0.0))
			var entry := float(zone.get("entry_window", 10.0))
			# 入口窗到上墙前：屏幕中央大字
			if track_distance >= start - entry - 2.0 and track_distance <= start + 10.0:
				show_hint = true
	if show_hint:
		_wall_jump_hint_timer = minf(_wall_jump_hint_timer + delta * 3.2, 1.0)
		_wall_jump_hint_label.text = "跳跃上墙\nJump on Wall"
		var pulse := 0.82 + 0.18 * sin(elapsed * 5.5)
		_wall_jump_hint_label.modulate = Color(1.0, 0.94, 0.45, _wall_jump_hint_timer * pulse)
		_wall_jump_hint_label.visible = true
	else:
		_wall_jump_hint_timer = maxf(_wall_jump_hint_timer - delta * 4.0, 0.0)
		_wall_jump_hint_label.modulate.a = _wall_jump_hint_timer
		if _wall_jump_hint_timer <= 0.01:
			_wall_jump_hint_label.visible = false

func _update_side_runway_ground_penalty(_delta: float) -> void:
	# 坑上改为真实坠落判死；此处只做贴墙提示
	if is_finished or is_failed or not gameplay_active:
		return
	if track_layer != 0:
		return
	if not _is_in_side_runway_pit(track_distance):
		return
	if player != null and player.position.y <= GROUND_Y + 0.15 and strike_toast_label:
		if _lava_platforms.size() > 0:
			_show_strike_warning("熔岩区 · 跳上前方平台逐格通过！")
		elif _wall_tut_step >= WALL_TUT_APPROACH and _wall_tut_step < WALL_TUT_DONE:
			_show_strike_warning("坍塌坑！教学：贴墙道 → 再朝墙按 → 跳")
		else:
			_show_strike_warning("主路坍塌 · 立刻上侧墙！")

func _first_side_runway_zone() -> Dictionary:
	var zones := _side_runway_zones()
	if zones.is_empty():
		return {}
	var best: Dictionary = {}
	var best_start := INF
	for z in zones:
		if typeof(z) != TYPE_DICTIONARY:
			continue
		var start := float(z.get("start", 0.0))
		if start < best_start:
			best_start = start
			best = z
	return best

func _setup_side_runway_entry_guides() -> void:
	# 每个侧墙区：水平跑道上永久方位箭头 + 贴墙道高亮（不依赖教学开关）
	if _side_runway_guide_root != null and is_instance_valid(_side_runway_guide_root):
		_side_runway_guide_root.queue_free()
	if _side_runway_zones().is_empty():
		return
	_side_runway_guide_root = Node3D.new()
	_side_runway_guide_root.name = "SideRunwayEntryGuides"
	if track_root != null:
		track_root.add_child(_side_runway_guide_root)
	else:
		add_child(_side_runway_guide_root)
	for zone in _side_runway_zones():
		var start := float(zone.get("start", 0.0))
		var entry := float(zone.get("entry_window", 10.0))
		var side := _wall_zone_side(zone)
		var edge_lane_x := float(LANES[_wall_edge_lane_index(zone)]) * LANE_WIDTH
		for i in 5:
			var d := start - entry + 2.0 + float(i) * 2.35
			if d < 8.0:
				continue
			var t := float(i) / 4.0
			var lat := lerpf(0.0, edge_lane_x, 0.22 + t * 0.68)
			_side_runway_guide_root.add_child(_make_wall_guide_arrow(d, lat, side, i >= 3))
		_side_runway_guide_root.add_child(
			_make_runway_lane_guide_pad(start - entry + 1.0, start + 2.5, edge_lane_x)
		)
		var pit: Vector2 = _side_runway_pit_range(zone)
		if pit.y > pit.x + 6.0:
			_side_runway_guide_root.add_child(_make_wall_tut_pit_warning(pit.x - 5.0))

func _make_runway_lane_guide_pad(start_d: float, end_d: float, lateral: float) -> Node3D:
	var root := Node3D.new()
	root.name = "RunwayLaneGuidePad"
	var mat := _make_material(Color(0.15, 0.9, 1.0, 0.4), Color(0.3, 0.95, 1.0), 1.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_attach_path_strip_to_parent(
		root, start_d, end_d, LANE_WIDTH * 0.42, GROUND_Y + 0.07, mat, 1.6, lateral
	)
	return root

func _setup_wall_run_tutorial_markers() -> void:
	if not Global.should_show_runner_tutorial("wall_run"):
		_wall_tut_step = WALL_TUT_DONE
		return
	var zone := _first_side_runway_zone()
	if zone.is_empty():
		return
	_wall_tut_zone = zone
	# 仅标记「待接近」，真正进入区间后再暂停教学
	_wall_tut_step = WALL_TUT_APPROACH
	if _wall_tut_root != null and is_instance_valid(_wall_tut_root):
		_wall_tut_root.queue_free()
	_wall_tut_root = Node3D.new()
	_wall_tut_root.name = "WallRunTutorialMarkers"
	if track_root != null:
		track_root.add_child(_wall_tut_root)
	else:
		add_child(_wall_tut_root)
	var start := float(zone.get("start", 0.0))
	# 地面箭头由 _setup_side_runway_entry_guides 常驻生成
	var zone_end := start + float(zone.get("length", 55.0))
	for gap in _main_block_road_gaps():
		var gs: float = gap.x
		if gs < start - 20.0 or gs > zone_end + 20.0:
			continue
		_wall_tut_root.add_child(_make_wall_tut_pit_warning(gs - 6.0))
		break

func _make_wall_tut_arrow(distance: float, lateral: float, wall_side: float) -> Node3D:
	return _make_wall_guide_arrow(distance, lateral, wall_side, false)

func _make_wall_tut_ready_pad(start_d: float, end_d: float, wall_side: float) -> Node3D:
	var root := Node3D.new()
	var offset := float(wall_side) * (_effective_wall_lateral_offset(_wall_tut_zone) - 1.35)
	var mat := _make_material(Color(0.15, 0.9, 1.0, 0.35), Color(0.3, 0.95, 1.0), 1.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_attach_path_strip_to_parent(root, start_d, end_d, 1.1, GROUND_Y + 0.08, mat, 2.0, offset)
	return root

func _attach_path_strip_to_parent(
	parent: Node3D,
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	lateral_bias: float,
	edge_wobble: float = 0.0,
	inner_on_left: bool = true,
	feather_inner: bool = false,
	feather_center: bool = false
) -> void:
	if end_d <= start_d + 0.05:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var d := start_d
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	var prev_pos := Vector3.ZERO
	var prev_right := Vector3.RIGHT
	var has_prev := false
	while d <= end_d + 0.001:
		var wob := _strip_edge_wobble(d, lateral_bias, edge_wobble) if edge_wobble > 0.001 else 0.0
		var half_l := half_width
		var half_r := half_width
		if edge_wobble > 0.001:
			if inner_on_left:
				half_r += wob
			else:
				half_l += wob
		var pt := _path_strip_point_shaped(d, half_l, half_r, y, lateral_bias)
		var origin: Vector3 = pt["pos"]
		var right: Vector3 = pt["right"]
		var l: Vector3 = pt["L"]
		var r: Vector3 = pt["R"]
		if has_prev:
			st.set_normal(Vector3.UP)
			st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, prev_pos, prev_right, prev_l, true))
			st.add_vertex(prev_l)
			st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, prev_pos, prev_right, prev_r, false))
			st.add_vertex(prev_r)
			st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, origin, right, r, false))
			st.add_vertex(r)
			st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, prev_pos, prev_right, prev_l, true))
			st.add_vertex(prev_l)
			st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, origin, right, r, false))
			st.add_vertex(r)
			st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, origin, right, l, true))
			st.add_vertex(l)
		prev_l = l
		prev_r = r
		prev_pos = origin
		prev_right = right
		has_prev = true
		if d >= end_d:
			break
		d = minf(d + step, end_d)
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	parent.add_child(mi)

func _make_wall_tut_pit_warning(distance: float) -> Node3D:
	var root := Node3D.new()
	var sample := _sample_path(distance)
	root.position = (sample["pos"] as Vector3) + Vector3(0.0, GROUND_Y + 0.05, 0.0)
	root.rotation.y = float(sample["yaw"])
	var gate := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(LANE_WIDTH * 3.1, 0.18, 1.4)
	var mat := _make_material(Color(1.0, 0.35, 0.12, 0.7), Color(1.0, 0.45, 0.15), 2.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	box.material = mat
	gate.mesh = box
	gate.position.y = 0.12
	root.add_child(gate)
	return root

func _wall_tut_side_name(zone: Dictionary) -> String:
	return "右" if _wall_zone_side(zone) > 0.0 else "左"

func _wall_tut_approach_distance(zone: Dictionary) -> float:
	# 暂停式教学不需要提前很远：靠近入口/贴墙垫再弹，避免「还没到侧墙就暂停」
	var start := float(zone.get("start", 0.0))
	return start - 10.0

func _update_wall_run_tutorial(_delta: float) -> void:
	if not Global.should_show_runner_tutorial("wall_run") or _wall_tut_step == WALL_TUT_OFF or _wall_tut_step >= WALL_TUT_DONE:
		return
	if is_intro or is_failed or is_finished or not gameplay_active:
		return
	# 其它教学暂停中时，不要抢占成侧墙教学
	if _tutorial_paused and not _tutorial_expect.begins_with("wall_"):
		return
	if _wall_tut_zone.is_empty():
		_wall_tut_zone = _first_side_runway_zone()
		if _wall_tut_zone.is_empty():
			return
	var start := float(_wall_tut_zone.get("start", 0.0))
	var length := float(_wall_tut_zone.get("length", 55.0))
	var approach_d := _wall_tut_approach_distance(_wall_tut_zone)

	if track_distance < approach_d or track_distance > start + length + 8.0:
		return

	if _is_wall_running():
		_complete_wall_run_tutorial()
		return

	# 侧墙教学优先：靠近入口后再暂停，按步骤等正确操作
	if _coach_tip_key != "":
		_coach_tip_key = ""
	if not _tutorial_paused or not _tutorial_expect.begins_with("wall_"):
		var edge := _wall_edge_lane_index(_wall_tut_zone)
		if _wall_mount_armed and _is_wall_mount_ready(_wall_tut_zone):
			_wall_tut_step = WALL_TUT_JUMP
			_begin_tutorial_pause("wall_jump")
		elif lane_index == edge:
			_wall_tut_step = WALL_TUT_ARM
			_begin_tutorial_pause("wall_arm")
		else:
			_wall_tut_step = WALL_TUT_LANE
			_begin_tutorial_pause("wall_lane")
	_refresh_wall_tut_panel(_wall_tut_side_name(_wall_tut_zone))
	_pulse_wall_tut_markers(_delta)

func _pulse_wall_tut_markers(delta: float) -> void:
	if _wall_tut_root == null:
		return
	_wall_tut_pulse += delta
	var pulse := 0.65 + 0.35 * sin(_wall_tut_pulse * 6.0)
	for child in _wall_tut_root.get_children():
		for mi in child.find_children("*", "MeshInstance3D", true, false):
			var mesh_i := mi as MeshInstance3D
			if mesh_i.material_override is StandardMaterial3D:
				(mesh_i.material_override as StandardMaterial3D).emission_energy_multiplier = 1.2 * pulse

func _on_wall_tutorial_action(kind: String) -> void:
	# 仅在侧墙教学已进入暂停流程后才响应；避免开局换道误触发
	if not (_tutorial_paused and _tutorial_expect.begins_with("wall_")):
		return
	if not Global.should_show_runner_tutorial("wall_run"):
		return
	if _wall_tut_step <= WALL_TUT_OFF or _wall_tut_step >= WALL_TUT_DONE:
		return
	if _wall_tut_zone.is_empty():
		return
	var edge := _wall_edge_lane_index(_wall_tut_zone)
	var side_name := _wall_tut_side_name(_wall_tut_zone)
	if kind == "lane":
		if lane_index == edge:
			_wall_tut_step = WALL_TUT_ARM
			_begin_tutorial_pause("wall_arm")
			_refresh_wall_tut_panel(side_name)
			_show_gate_toast("很好 · 再朝%s墙按一次换道" % side_name)
		else:
			_wall_tut_step = WALL_TUT_LANE
			_begin_tutorial_pause("wall_lane")
			_refresh_wall_tut_panel(side_name)
	elif kind == "arm":
		_wall_tut_step = WALL_TUT_JUMP
		_begin_tutorial_pause("wall_jump")
		_refresh_wall_tut_panel(side_name)
		_show_gate_toast("贴墙就绪 · 现在跳跃上墙")

func _refresh_wall_tut_panel(side_name: String) -> void:
	if _wall_tut_panel == null:
		return
	_wall_tut_panel.visible = true
	match _wall_tut_step:
		WALL_TUT_LANE:
			_wall_tut_title.text = "侧墙教学 · ① 换道（已暂停）"
			_wall_tut_body.text = "前方主路坍塌！先换到%s侧贴墙车道\n（跟随绿色箭头）完成后继续" % side_name
		WALL_TUT_ARM:
			_wall_tut_title.text = "侧墙教学 · ② 贴墙（已暂停）"
			_wall_tut_body.text = "已在贴墙道 · 再朝%s墙按一次换道\n出现「贴墙就绪」后准备跳" % side_name
		WALL_TUT_JUMP:
			_wall_tut_title.text = "侧墙教学 · ③ 跳跃（已暂停）"
			_wall_tut_body.text = "贴墙就绪！立刻跳跃上墙\n墙上可上下换高度，绕过坍塌坑"
		_:
			_wall_tut_title.text = "侧墙教学（已暂停）"
			_wall_tut_body.text = "贴墙道 → 再朝墙按 → 跳跃上墙"

func _complete_wall_run_tutorial() -> void:
	if _wall_tut_step >= WALL_TUT_DONE and Global.has_seen_runner_tutorial("wall_run"):
		return
	_wall_tut_step = WALL_TUT_DONE
	Global.mark_runner_tutorial_seen("wall_run")
	_end_tutorial_pause()
	if _coach_tip_key == "" and _wall_tut_panel:
		_wall_tut_panel.visible = false
	if _wall_tut_root != null and is_instance_valid(_wall_tut_root):
		_wall_tut_root.queue_free()
		_wall_tut_root = null
	_show_gate_toast("侧墙教学完成 · 三步：换道→贴墙→跳")

func _is_wall_tut_panel_busy() -> bool:
	if not Global.should_show_runner_tutorial("wall_run"):
		return false
	if _wall_tut_step <= WALL_TUT_OFF or _wall_tut_step >= WALL_TUT_DONE:
		return false
	if _wall_tut_zone.is_empty():
		return false
	var start := float(_wall_tut_zone.get("start", 0.0))
	var length := float(_wall_tut_zone.get("length", 55.0))
	var approach_d := _wall_tut_approach_distance(_wall_tut_zone)
	return track_distance >= approach_d and track_distance <= start + length + 8.0

func _coach_tip_copy(key: String) -> Dictionary:
	match key:
		"lane":
			return {
				"title": "换道教学（已暂停）",
				"body": "左右滑动（或 ←→）切换车道\n躲开当前道上的障碍后继续",
			}
		"jump":
			return {
				"title": "跳跃教学（已暂停）",
				"body": "上滑（或空格）跳跃\n越过前方低矮障碍后继续",
			}
		"slide":
			return {
				"title": "滑铲教学（已暂停）",
				"body": "下滑（或 ↓）滑铲\n钻过前方高处障碍后继续",
			}
		"shield":
			return {
				"title": "防护罩教学（已暂停）",
				"body": "先拾取防护水晶充能（每个+%d）\n能量≥15 后点「盾」或按 F 开启\n开启后持续耗能：常态每0.5秒-1，沙暴/热浪每0.5秒-3" % int(SHIELD_CRYSTAL_RESTORE),
			}
		"sandstorm":
			return {
				"title": "沙尘暴教学（已暂停）",
				"body": "前方沙尘侵蚀货物\n先囤够防护能量再开罩，或换到安全车道",
			}
		"fork":
			return {
				"title": "分叉教学（已暂停）",
				"body": "前方道路分叉\n左右换道选择岔路后继续",
			}
		_:
			return {"title": "操作提示（已暂停）", "body": ""}

func _show_coach_tip(key: String, until_d: float) -> void:
	if key == "" or not Global.should_show_runner_tutorial(key):
		return
	if _is_wall_tut_panel_busy():
		return
	_coach_tip_key = key
	_coach_tip_until_d = until_d
	var expect := key
	_begin_tutorial_pause(expect)
	var copy := _coach_tip_copy(key)
	if _wall_tut_panel == null:
		return
	_wall_tut_panel.visible = true
	_wall_tut_title.text = String(copy.get("title", "操作提示"))
	_wall_tut_body.text = String(copy.get("body", ""))

func _complete_coach_tip(key: String) -> void:
	if key == "":
		return
	Global.mark_runner_tutorial_seen(key)
	if _coach_tip_key == key:
		_coach_tip_key = ""
		_coach_tip_until_d = -1.0
		_end_tutorial_pause()
		if not _is_wall_tut_panel_busy() and _wall_tut_panel:
			_wall_tut_panel.visible = false
		_show_gate_toast("教学完成 · 继续前进")

func _refresh_active_tutorial_panel() -> void:
	if _is_wall_tut_panel_busy():
		_refresh_wall_tut_panel(_wall_tut_side_name(_wall_tut_zone))
		return
	if _coach_tip_key == "":
		return
	var copy := _coach_tip_copy(_coach_tip_key)
	if _wall_tut_panel:
		_wall_tut_panel.visible = true
		_wall_tut_title.text = String(copy.get("title", ""))
		_wall_tut_body.text = String(copy.get("body", ""))

func _find_upcoming_coach_obstacle(types: Array, look_ahead: float = 18.0, min_ahead: float = 8.0) -> Dictionary:
	var best: Dictionary = {}
	var best_d := INF
	for obstacle in obstacles:
		if typeof(obstacle) != TYPE_DICTIONARY:
			continue
		var otype := String(obstacle.get("type", ""))
		if not types.has(otype):
			continue
		if int(obstacle.get("layer", 0)) != track_layer:
			continue
		if bool(obstacle.get("hit", false)):
			continue
		var obs_d: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
		var delta_d := obs_d - track_distance
		# 靠近后再暂停，做完动作刚好能过障
		if delta_d < min_ahead or delta_d > look_ahead:
			continue
		if delta_d < best_d:
			best_d = delta_d
			best = obstacle
	return best

func _update_runner_coach_tips(_delta: float) -> void:
	if not Global.is_runner_tutorial_enabled():
		if _coach_tip_key != "":
			_coach_tip_key = ""
			_end_tutorial_pause()
			if _wall_tut_panel:
				_wall_tut_panel.visible = false
		return
	if is_intro or is_failed or is_finished or not gameplay_active:
		return
	if _tutorial_paused or _is_wall_tut_panel_busy():
		return
	if _coach_tip_key != "":
		return

	# 靠近障碍/区域时暂停教学，完成指定操作后再继续
	var jump_obs := _find_upcoming_coach_obstacle(["jump", "low_barrier", "orb"], 11.0, 5.0)
	if not jump_obs.is_empty() and Global.should_show_runner_tutorial("jump"):
		var jd: float = float(jump_obs["distance"]) + float(jump_obs.get("move_offset", 0.0))
		_show_coach_tip("jump", jd + 4.0)
		return

	var slide_obs := _find_upcoming_coach_obstacle(["slide", "high_bar"], 11.0, 5.0)
	if not slide_obs.is_empty() and Global.should_show_runner_tutorial("slide"):
		var sd: float = float(slide_obs["distance"]) + float(slide_obs.get("move_offset", 0.0))
		_show_coach_tip("slide", sd + 4.0)
		return

	var lane_obs := _find_upcoming_coach_obstacle(["train", "train_moving"], 14.0, 6.0)
	if not lane_obs.is_empty() and Global.should_show_runner_tutorial("lane"):
		var ld: float = float(lane_obs["distance"]) + float(lane_obs.get("move_offset", 0.0))
		_show_coach_tip("lane", ld + 4.0)
		return

	if Global.should_show_runner_tutorial("sandstorm") or Global.should_show_runner_tutorial("shield"):
		for zone in _sandstorm_zones():
			var start := float(zone.get("start", 0.0))
			if track_distance < start - 18.0 or track_distance > start - 6.0:
				continue
			if Global.should_show_runner_tutorial("shield"):
				_show_coach_tip("shield", start + float(zone.get("length", 40.0)))
			elif Global.should_show_runner_tutorial("sandstorm"):
				_show_coach_tip("sandstorm", start + float(zone.get("length", 40.0)))
			return

	if Global.should_show_runner_tutorial("fork"):
		for zone in _junction_zones():
			var at_d := float(zone.get("distance", 0.0))
			if track_distance < at_d - 18.0 or track_distance > at_d - 8.0:
				continue
			_show_coach_tip("fork", at_d + 8.0)
			return

func _side_runway_hold_over_pit(distance: float) -> Dictionary:
	# 墙段已结束但仍在坍塌坑上时，暂用最近侧墙数据继续贴跑
	if not _is_in_any_open_pit(distance):
		return {}
	var best: Dictionary = {}
	var best_gap := INF
	for zone in _side_runway_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var start := float(zone.get("start", 0.0))
		var end := _side_runway_wall_end(zone)
		var entry := float(zone.get("entry_window", 10.0))
		if distance < start - entry - 4.0:
			continue
		if distance > end + 52.0:
			continue
		var gap := 0.0 if distance <= end else distance - end
		if gap < best_gap:
			best_gap = gap
			best = zone
	return best

func _enforce_track_layer() -> void:
	if player == null:
		return
	if _is_wall_running():
		var zone := _side_runway_wall_zone_at(track_distance)
		if zone.is_empty():
			zone = _side_runway_entry_zone(track_distance)
		# 侧墙区间已结束但仍在坍塌坑上：禁止下墙，沿用最近侧墙继续贴跑
		if zone.is_empty() and _is_in_any_open_pit(track_distance):
			zone = _side_runway_hold_over_pit(track_distance)
		if zone.is_empty():
			# 离开侧墙：自动落回靠墙主路车道（无需跳跃）
			track_layer = 0
			_wall_mount_armed = false
			_wall_roll = 0.0
			player.rotation = Vector3(0.0, _path_yaw, 0.0)
			if player_body:
				player_body.rotation = Vector3(0.0, 0.0, body_tilt)
			vertical_velocity = minf(vertical_velocity, -2.0)
			lane_index = 2 if _last_wall_side > 0.0 else 0
			target_lane_x = float(LANES[lane_index]) * LANE_WIDTH
			current_lateral = target_lane_x
			_show_gate_toast("落回主路")
			strike_toast_label.modulate = Color(0.55, 0.9, 1.0, 1.0)
			strike_toast_timer = 1.1
			return
		if player.position.y <= current_wall_y + 0.05 and vertical_velocity <= 0.01:
			player.position.y = current_wall_y
			vertical_velocity = 0.0
		return
	if _is_on_ground() and not _is_over_open_pit() and _lava_platform_surface_under_player() < GROUND_Y - 0.2:
		var snap_y := _ground_y_at(track_distance)
		if absf(player.position.y - snap_y) > 0.05:
			player.position.y = snap_y
			vertical_velocity = 0.0

func _check_ramps() -> void:
	for obstacle in obstacles:
		if String(obstacle["type"]) != "ramp":
			continue
		if int(obstacle.get("layer", 0)) != track_layer:
			continue
		var obs_dist: float = float(obstacle["distance"])
		if abs(track_distance - obs_dist) > 1.5:
			continue
		if not _player_in_obstacle_lateral(obstacle):
			continue
		if vertical_velocity > 2.0 or _is_on_ground():
			vertical_velocity = maxf(vertical_velocity, JUMP_SPEED * 1.15)
			camera_shake = maxf(camera_shake, 0.12)

func _update_moving_obstacles(delta: float) -> void:
	for obstacle in obstacles:
		var otype := String(obstacle.get("type", ""))
		# 光波门/列车门：只动光刃，不沿跑道滑移
		if otype in ["train", "train_moving"]:
			continue
		if not bool(obstacle.get("moving", false)):
			obstacle["move_offset"] = 0.0
			continue
		obstacle["move_offset"] = float(obstacle.get("move_offset", 0.0)) + float(obstacle["move_speed"]) * delta
		_place_obstacle_node(obstacle)

func _update_float_orbs(delta: float) -> void:
	for obstacle in obstacles:
		if not bool(obstacle.get("float_orb", false)):
			continue
		if int(obstacle.get("orb_layout_version", 0)) != ORB_LAYOUT_VERSION:
			_refit_float_orb(obstacle)
		var node := obstacle.get("node") as Node3D
		if node == null:
			continue
		var obs_dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
		var delta_d := obs_dist - track_distance
		var reveal_dist := ORB_COLOSSAL_POP_REVEAL_DIST if String(obstacle.get("orb_tier", "")) == "colossal" else ORB_POP_REVEAL_DIST
		if delta_d > reveal_dist or delta_d < -10.0:
			node.visible = false
			obstacle["orb_revealed"] = false
			obstacle["orb_pop"] = 0.0
			var hidden_visual := node.get_node_or_null("JumpObstacleModel") as Node3D
			if hidden_visual:
				var base_scale: Vector3 = obstacle.get("orb_base_scale", Vector3.ONE)
				hidden_visual.scale = base_scale * 0.01
			continue
		node.visible = true
		if not bool(obstacle.get("orb_revealed", false)):
			obstacle["orb_revealed"] = true
			obstacle["orb_pop"] = 0.0
		obstacle["orb_pop"] = minf(float(obstacle.get("orb_pop", 0.0)) + delta * 14.0, 1.0)
		var offset := float(obstacle.get("lateral_offset", 0.0))
		var dir := float(obstacle.get("lateral_dir", 1.0))
		var drift_speed := float(obstacle.get("lateral_speed", 3.2))
		var drift_span := float(obstacle.get("drift_span", ORB_DRIFT_SPAN))
		offset += dir * drift_speed * delta
		if offset >= drift_span:
			offset = drift_span
			obstacle["lateral_dir"] = -1.0
		elif offset <= -drift_span:
			offset = -drift_span
			obstacle["lateral_dir"] = 1.0
		obstacle["lateral_offset"] = offset
		_place_obstacle_node(obstacle)
		var visual := node.get_node_or_null("JumpObstacleModel") as Node3D
		if visual:
			var base_scale: Vector3 = obstacle.get("orb_base_scale", Vector3.ONE)
			var pop := float(obstacle.get("orb_pop", 1.0))
			var pop_scale := _orb_pop_visual_scale(pop)
			visual.scale = Vector3(base_scale.x * pop_scale, base_scale.y * pop_scale, base_scale.z * pop_scale)
			var phase := float(obstacle.get("orb_float_phase", 0.0))
			var float_speed := float(obstacle.get("orb_float_speed", ORB_SMALL_FLOAT_SPEED))
			var float_amp := float(obstacle.get("orb_float_amp", ORB_SMALL_FLOAT_AMP))
			phase += delta * float_speed
			obstacle["orb_float_phase"] = phase
			var base_y := float(obstacle.get("orb_visual_base_y", ORB_VISUAL_BASE_Y))
			visual.position.y = base_y + sin(phase) * float_amp
			var tier := String(obstacle.get("orb_tier", "small"))
			if tier == "large":
				visual.rotation_degrees.z = sin(phase * 0.3) * 3.2
				visual.rotation_degrees.x = sin(phase * 0.2 + 0.8) * 1.4
			else:
				visual.rotation_degrees.z = sin(phase * 0.92) * 9.5
				visual.rotation_degrees.x = sin(phase * 0.66 + 0.8) * 5.2

func _sync_fork_branch_obstacle_visibility() -> void:
	for obstacle in obstacles:
		var fork_branch := int(obstacle.get("fork_branch", 0))
		if fork_branch == 0:
			continue
		var node := obstacle.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var show := _fork_side == 0 or _fork_side == fork_branch
		node.visible = show

func _sparse_obstacle_skip_distance(distance: float) -> bool:
	if not _is_distance_on_main_ground_runway(distance, 0):
		return true
	# 侧墙入口留空，方便上墙
	if _is_distance_in_side_runway_entry_window(distance):
		return true
	if _is_distance_on_track_turn(distance, 12.0):
		return true
	if _is_distance_in_lava_platform_exclusion(distance) or _is_in_main_block_pit(distance):
		return true
	if _is_distance_in_lava_crossing_clear_zone(distance):
		return true
	if not _junction_fork_region_at(distance).is_empty():
		return true
	return false

func _inject_sparse_runway_obstacles() -> void:
	# JSON / 自定义关：长直道补可见障碍（掉落陨石 + 紫色能量球），避免只剩金币
	if _uses_beat_sync_content():
		return
	var finish_cut := maxf(_track_length - 28.0, _track_length * 0.92)
	var max_gap := 28.0
	var fill_step := 18.0
	var pattern: Array[String] = ["meteorite", "orb", "jump", "meteorite", "orb", "slide", "meteorite", "orb"]
	var ground_dists: Array[float] = [22.0]
	for obstacle in obstacles:
		if int(obstacle.get("layer", 0)) != 0:
			continue
		var otype := String(obstacle.get("type", ""))
		if otype in ["ramp", "turn_left", "turn_right", "main_block"]:
			continue
		ground_dists.append(float(obstacle.get("distance", 0.0)))
	ground_dists.append(finish_cut)
	ground_dists.sort()
	var pi := 0
	var inserts: Array[Dictionary] = []
	for i in range(ground_dists.size() - 1):
		var seg_start := ground_dists[i]
		var seg_end := ground_dists[i + 1]
		if seg_end - seg_start <= max_gap:
			continue
		var fill_d := seg_start + 12.0
		while seg_end - fill_d > 10.0 and fill_d < finish_cut:
			if _sparse_obstacle_skip_distance(fill_d):
				fill_d += 6.0
				continue
			var lane: int = int(LANES[(pi + int(fill_d * 0.19)) % LANES.size()])
			var otype: String = pattern[pi % pattern.size()]
			pi += 1
			var item: Dictionary = {"distance": fill_d, "lane": lane, "type": otype, "layer": 0}
			if otype == "slide":
				item["low_slide"] = true
			elif otype == "meteorite":
				item["span"] = 2.15 if pi % 2 == 0 else 1.85
				item["fall_roll"] = (pi % 3) != 1
				if bool(item.get("fall_roll", false)):
					var spd_rng := RandomNumberGenerator.new()
					spd_rng.seed = int(fill_d * 7.0) + lane * 13 + pi * 5
					item["meteor_fall_speed"] = spd_rng.randf_range(12.0, 30.0)
					item["fall_height"] = spd_rng.randf_range(11.0, 19.0)
					item["roll_speed"] = spd_rng.randf_range(-6.2, -4.0)
			elif otype == "orb":
				item["orb_size"] = "medium"
				item["orb_tint"] = _reservoir_orb_tint_at(fill_d) if _is_reservoir_location() else "purple"
			inserts.append(item)
			fill_d += fill_step + float(pi % 3) * 2.0
	for item in inserts:
		_register_obstacle(item)


func _gate_tension_step() -> float:
	if _mission_id_str() == "mission_gate_d4" or _is_emergency_run:
		return 9.0
	if _mission_id_str() == "mission_gate_d2":
		return 10.0
	if _mission_id_str() == "mission_gate_d3":
		return 11.0
	return 10.4


func _gate_has_nearby_obstacle(distance: float, gap: float) -> bool:
	for obstacle in obstacles:
		if int(obstacle.get("layer", 0)) != 0:
			continue
		if absf(float(obstacle.get("distance", 0.0)) - distance) < gap:
			return true
	return false


func _gate_tension_skip_distance(distance: float) -> bool:
	if _sparse_obstacle_skip_distance(distance):
		return true
	_ensure_mechanic_layout()
	for pad in _launch_pads:
		if typeof(pad) != TYPE_DICTIONARY:
			continue
		# 弹射垫前后留空，避免滑铲/跳跃挡在熔岩前
		if absf(float(pad.get("distance", 0.0)) - distance) < 18.0:
			return true
	return false


func _inject_gate_tension_obstacles() -> void:
	# 防御哨站：直道用紫球+高低/降落陨石填满只剩金币的空档
	if not _is_gate_location():
		return
	_ensure_mechanic_layout()
	var finish_cut := maxf(_track_length - 28.0, _track_length * 0.92)
	var step := _gate_tension_step()
	var pattern: Array[String] = [
		"orb", "meteorite", "orb", "orb", "jump",
		"meteorite", "orb", "slide", "orb", "meteorite",
		"orb", "train",
	]
	if _mission_id_str() == "mission_gate_d2":
		pattern = [
			"orb", "meteorite", "orb", "jump", "orb",
			"meteorite", "orb", "slide", "orb", "meteorite",
		]
	var d := START_PAD_LENGTH + 16.0
	var pi := 0
	while d < finish_cut:
		if _gate_tension_skip_distance(d):
			d += 5.0
			continue
		if _gate_has_nearby_obstacle(d, 6.0):
			d += step * 0.45
			continue
		var lane: int = int(LANES[(pi + int(d * 0.17)) % LANES.size()])
		var otype: String = pattern[pi % pattern.size()]
		if pi % 17 == 8 and not _gate_has_nearby_obstacle(d, 14.0):
			otype = "meteorite_gate"
		pi += 1
		var item: Dictionary = {
			"distance": d,
			"lane": lane,
			"type": otype,
			"layer": 0,
		}
		if otype == "slide":
			item["low_slide"] = true
		elif otype == "orb":
			var sizes: Array[String] = ["tiny", "small", "small", "medium", "tiny"]
			item["orb_size"] = sizes[pi % sizes.size()]
			item["orb_tint"] = "purple"
			if pi % 2 == 0:
				item["drift_speed"] = 6.2 + float(pi % 5) * 0.85
				item["drift_span"] = LANE_WIDTH * (1.35 + float(pi % 3) * 0.22)
				item["float_speed"] = 2.6 + float(pi % 4) * 0.4
				item["float_amp"] = 0.14 + float(pi % 3) * 0.06
		elif otype == "meteorite":
			var spans: Array[float] = [1.45, 1.85, 2.2, 2.65, 3.05]
			item["span"] = spans[pi % spans.size()]
			var falling := (pi % 3) != 1
			item["fall_roll"] = falling
			if falling:
				var heights: Array[float] = [9.8, 12.4, 15.2, 17.6, 19.4]
				item["fall_height"] = heights[pi % heights.size()]
				item["meteor_fall_speed"] = 18.0 + float(pi % 5) * 2.2
				item["roll_speed"] = -4.6 - float(pi % 4) * 0.35
		elif otype == "meteorite_gate":
			item["drop_count"] = 6
			item["drop_interval"] = 0.82
		_register_obstacle(item)
		d += step + float(pi % 3) * 0.8


func _inject_finish_sprint_orb_gauntlet() -> void:
	# SPEED UP 之后到终点门：密集横向漂移的紫色能量球
	var sprint_d := -1.0
	for raw in _finish_sprint_entries():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		sprint_d = maxf(sprint_d, float(raw.get("distance", 0.0)))
	if sprint_d < 40.0:
		return
	var finish_d := _finish_line_distance if _finish_line_distance > 0.0 else maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)
	var start := sprint_d + 8.0
	var end := finish_d - 14.0
	if end - start < 16.0:
		return
	var d := start
	var i := 0
	var lanes: Array[int] = [-1, 0, 1, 1, 0, -1]
	var sizes: Array[String] = ["tiny", "small", "medium", "small", "tiny", "medium"]
	while d < end:
		if _sparse_obstacle_skip_distance(d):
			d += 4.0
			continue
		var crowded := false
		for obstacle in obstacles:
			if absf(float(obstacle.get("distance", 0.0)) - d) < 3.4:
				crowded = true
				break
		if not crowded:
			_register_obstacle({
				"distance": d,
				"lane": lanes[i % lanes.size()],
				"type": "orb",
				"orb_size": sizes[i % sizes.size()],
				"orb_tint": _reservoir_orb_tint_at(d) if _is_reservoir_location() else "purple",
				"drift_speed": 6.4 + float(i % 5) * 1.15,
				"drift_span": LANE_WIDTH * (1.55 + float(i % 3) * 0.28),
				"float_speed": 2.8 + float(i % 4) * 0.35,
				"float_amp": 0.16 + float(i % 3) * 0.05,
				"layer": 0,
			})
			i += 1
		d += 5.4


func _resolve_lava_crossing_conflicts() -> void:
	# 熔岩过法互斥：平台跳 / 侧墙跑 段不得再叠加速垫或误放弹射垫
	# 真正的「弹射过熔岩」垫（launch_cross）保留在 open_gaps 入口
	var blocked: Array[Vector2] = []
	for raw in _layout_obstacle_items_raw():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if int(item.get("layer", 0)) != 0:
			continue
		var center := float(item.get("distance", 0.0))
		var half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		var mode := _main_block_cross_mode(item)
		if mode == "platform":
			blocked.append(Vector2(center - half - 22.0, center + half + 12.0))
		elif mode == "side_wall":
			blocked.append(Vector2(center - half - 14.0, center + half + 10.0))
	for zone in _raw_side_runway_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var zstart := float(zone.get("start", 0.0))
		var zlen := float(zone.get("length", 55.0))
		var entry := float(zone.get("entry_window", 10.0))
		blocked.append(Vector2(zstart - entry - 6.0, zstart + zlen + 6.0))
	if blocked.is_empty():
		return
	for i in range(_launch_pads.size() - 1, -1, -1):
		var pad: Dictionary = _launch_pads[i]
		# 过熔岩弹射垫不参与互斥剔除（由关卡 JSON 与 open_gaps 配对）
		if bool(pad.get("launch_cross", false)):
			continue
		var at := float(pad.get("distance", 0.0))
		for band: Vector2 in blocked:
			if at >= band.x and at <= band.y:
				_launch_pads.remove_at(i)
				break


func _pad_is_speed_only(pad: Dictionary) -> bool:
	return bool(pad.get("speed_boost", false)) and not bool(pad.get("launch_cross", false))


func _inject_side_runway_speed_boosts() -> void:
	# 侧墙跑道只放加速靴，不放跳栏/滑梁
	var boost_index := collectibles.size()
	for zone in _side_runway_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 12.0))
		var span := maxf(length - entry * 0.55, 14.0)
		var count := 2 if length <= 38.0 else 3
		for j in count:
			var t := (float(j) + 1.0) / float(count + 1)
			var dist := start + entry + span * t
			if dist >= _track_length - 24.0:
				continue
			var crowded := false
			for c in collectibles:
				if String(c.get("kind", "")) != "speed_boost":
					continue
				if int(c.get("layer", 0)) != WALL_RUN_LAYER:
					continue
				if absf(float(c.get("distance", 0.0)) - dist) < 7.0:
					crowded = true
					break
			if crowded:
				continue
			var lane := 0 if j % 2 == 0 else 1
			var y := _wall_lane_height_for_lane_value(lane) + 0.42
			_register_collectible_data(lane, dist, y, WALL_RUN_LAYER, "speed_boost")
			boost_index += 1


func _purge_side_wall_collision_obstacles() -> void:
	var keep: Array = []
	for obstacle in obstacles:
		if typeof(obstacle) != TYPE_DICTIONARY:
			continue
		if int(obstacle.get("layer", 0)) != WALL_RUN_LAYER:
			keep.append(obstacle)
			continue
		var otype := String(obstacle.get("type", ""))
		if otype in ["ramp", "turn_left", "turn_right", "main_block"]:
			keep.append(obstacle)
			continue
		var node := obstacle.get("node") as Node3D
		if node != null and is_instance_valid(node):
			node.queue_free()
	obstacles.clear()
	for o in keep:
		obstacles.append(o)
	_obstacle_scan_index = 0


func _inject_side_runway_wave_arc_obstacles() -> void:
	pass

func _junction_overlaps_y_fork(zone: Dictionary) -> bool:
	var start := float(zone.get("distance", 0.0))
	var end := start + float(zone.get("length", 70.0))
	for region in _y_fork_regions:
		if typeof(region) != TYPE_DICTIONARY:
			continue
		var y0 := float(region.get("d_start", 0.0))
		var y1 := float(region.get("d_end", 0.0))
		if start < y1 and y0 < end:
			return true
	return false


func _inject_y_fork_branch_obstacles() -> void:
	for region in _y_fork_regions:
		if typeof(region) != TYPE_DICTIONARY:
			continue
		var start := float(region.get("d_start", 0.0))
		var length := maxf(float(region.get("d_end", start)) - start, 20.0)
		var left_pattern: Array[Dictionary] = [
			{"t": 0.18, "lane": -1, "type": "jump"},
			{"t": 0.34, "lane": 0, "type": "slide"},
			{"t": 0.50, "lane": 1, "type": "meteorite", "fall_roll": true},
			{"t": 0.66, "lane": 0, "type": "orb", "orb_size": "small"},
			{"t": 0.82, "lane": -1, "type": "jump"},
		]
		var right_pattern: Array[Dictionary] = [
			{"t": 0.20, "lane": 0, "type": "jump"},
			{"t": 0.38, "lane": 1, "type": "orb", "orb_size": "small"},
			{"t": 0.54, "lane": -1, "type": "slide"},
			{"t": 0.70, "lane": 0, "type": "meteorite", "fall_roll": true},
			{"t": 0.84, "lane": 1, "type": "jump"},
		]
		for spec in left_pattern:
			_register_fork_branch_obstacle_spec(start, length, spec, -1)
		for spec in right_pattern:
			_register_fork_branch_obstacle_spec(start, length, spec, 1)


func _register_y_fork_branch_rewards() -> void:
	for region in _y_fork_regions:
		if typeof(region) != TYPE_DICTIONARY:
			continue
		var start := float(region.get("d_start", 0.0))
		var end := float(region.get("d_end", start + 80.0))
		var d := start + 10.0
		var i := 0
		while d < end - 8.0:
			var lane := int(LANES[i % LANES.size()])
			var y: float = _coin_collectible_y(i % 3 == 0, 0)
			_register_collectible_data(lane, d, y, 0, "coin", i % 3 == 0, 1)
			i += 1
			d += 7.0
		_register_collectible_data(0, start + (end - start) * 0.42, _speed_boost_collectible_y(0, 0), 0, "speed_boost", false, 1)
		_register_collectible_data(1, start + (end - start) * 0.68, _layer_height(0) + 0.85, 0, "shield_crystal", false, 1)


func _inject_junction_fork_branch_obstacles() -> void:
	for zone in _junction_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		if _junction_overlaps_y_fork(zone):
			continue
		var start := float(zone.get("distance", 0.0))
		var length := float(zone.get("length", 70.0))
		var effect_b := String(zone.get("effect_b", "fast"))
		var left_pattern: Array[Dictionary] = [
			{"t": 0.18, "lane": -1, "type": "jump"},
			{"t": 0.32, "lane": 0, "type": "meteorite", "fall_roll": true},
			{"t": 0.46, "lane": 1, "type": "slide"},
			{"t": 0.60, "lane": 0, "type": "orb", "orb_size": "small"},
			{"t": 0.74, "lane": -1, "type": "jump"},
			{"t": 0.88, "lane": 1, "type": "orb", "orb_size": "small"},
		]
		var right_pattern: Array[Dictionary] = [
			{"t": 0.16, "lane": 0, "type": "jump"},
			{"t": 0.30, "lane": 1, "type": "orb", "orb_size": "small"},
			{"t": 0.44, "lane": -1, "type": "slide"},
			{"t": 0.58, "lane": 0, "type": "meteorite", "fall_roll": true},
			{"t": 0.72, "lane": 1, "type": "jump"},
			{"t": 0.86, "lane": 0, "type": "orb", "orb_size": "small"},
		]
		if effect_b == "fast":
			right_pattern = [
				{"t": 0.16, "lane": 0, "type": "jump"},
				{"t": 0.30, "lane": -1, "type": "train"},
				{"t": 0.44, "lane": 1, "type": "orb", "orb_size": "small"},
				{"t": 0.58, "lane": 0, "type": "slide"},
				{"t": 0.72, "lane": 1, "type": "jump"},
				{"t": 0.86, "lane": -1, "type": "meteorite", "fall_roll": true},
			]
		if _is_gate_location():
			left_pattern.append_array([
				{"t": 0.24, "lane": 1, "type": "orb", "orb_size": "tiny", "orb_tint": "purple"},
				{"t": 0.40, "lane": -1, "type": "meteorite", "fall_roll": true, "span": 1.7, "fall_height": 13.5},
				{"t": 0.68, "lane": 0, "type": "orb", "orb_size": "small", "orb_tint": "purple"},
			])
			right_pattern.append_array([
				{"t": 0.24, "lane": -1, "type": "orb", "orb_size": "tiny", "orb_tint": "purple"},
				{"t": 0.50, "lane": 1, "type": "meteorite", "fall_roll": true, "span": 2.1, "fall_height": 16.0},
				{"t": 0.80, "lane": 0, "type": "orb", "orb_size": "medium", "orb_tint": "purple"},
			])
		for spec in left_pattern:
			_register_fork_branch_obstacle_spec(start, length, spec, -1)
		for spec in right_pattern:
			_register_fork_branch_obstacle_spec(start, length, spec, 1)
	obstacles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)

func _register_fork_branch_obstacle_spec(start: float, length: float, spec: Dictionary, fork_branch: int) -> void:
	var dist := start + length * float(spec.get("t", 0.0))
	if _has_fork_branch_obstacle_near(dist, fork_branch):
		return
	var otype := String(spec.get("type", "jump"))
	var item: Dictionary = {
		"distance": dist,
		"lane": int(spec.get("lane", 0)),
		"type": otype,
		"layer": 0,
		"fork_branch": fork_branch,
	}
	if otype == "slide":
		item["low_slide"] = true
	if otype == "orb":
		item["orb_size"] = String(spec.get("orb_size", "small"))
		if spec.has("orb_tint"):
			item["orb_tint"] = String(spec.get("orb_tint", "purple"))
	if otype == "meteorite":
		item["span"] = float(spec.get("span", 1.9))
		item["fall_roll"] = bool(spec.get("fall_roll", true))
		if spec.has("fall_height"):
			item["fall_height"] = float(spec.get("fall_height", 16.0))
	_register_obstacle(item)

func _has_fork_branch_obstacle_near(distance: float, fork_branch: int) -> bool:
	for obstacle in obstacles:
		if int(obstacle.get("fork_branch", 0)) != fork_branch:
			continue
		if absf(float(obstacle["distance"]) - distance) < 2.5:
			return true
	return false

func _update_full_width_obstacle_positions() -> void:
	# 仅必要时批量校正；平时障碍锚定路径，不每帧重算（避免「往镜头漂」）
	for obstacle in obstacles:
		if not _is_full_width_obstacle_type(String(obstacle.get("type", ""))):
			continue
		if bool(obstacle.get("smashed", false)) or bool(obstacle.get("hit", false)):
			continue
		_place_obstacle_node(obstacle)

func _road_lane_y(layer: int) -> float:
	# 与 RoadMeshBuilder lane_y 对齐，避免障碍根节点浮在路面上
	if layer == 0:
		return GROUND_Y - 0.05
	return _layer_height(layer)

func _place_obstacle_node(obstacle: Dictionary, _reposition_only: bool = false) -> void:
	var node := obstacle.get("node") as Node3D
	if node == null or not is_instance_valid(node):
		return
	var obstacle_type := String(obstacle.get("type", ""))
	var dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
	var layer: int = int(obstacle.get("layer", 0))
	var y := _road_lane_y(layer) + float(obstacle.get("y_offset", 0.0))
	if layer == 0:
		y += _path_height_lift_at(dist)
	var full_width := _is_full_width_obstacle_type(obstacle_type)
	var lateral := 0.0
	if not full_width:
		if bool(obstacle.get("float_orb", false)):
			lateral = float(obstacle["lane"]) * LANE_WIDTH + float(obstacle.get("lateral_offset", 0.0))
		else:
			lateral = float(obstacle["lane"]) * LANE_WIDTH
	if obstacle_type in ["slide", "high_bar", "main_block", "wave_arc_slide"]:
		y -= 0.10
	var fork_branch := int(obstacle.get("fork_branch", 0))
	var placed := _world_on_path_for_obstacle(dist, lateral, y, layer, fork_branch)
	node.position = placed["pos"]
	var yaw := float(placed["yaw"])
	if full_width and not _fork_zone_at(dist).is_empty() and fork_branch == 0:
		var ahead := _world_on_path_for_obstacle(dist + 6.0, 0.0, y, layer, 0)
		var delta: Vector3 = (ahead["pos"] as Vector3) - (placed["pos"] as Vector3)
		delta.y = 0.0
		if delta.length_squared() > 0.04:
			yaw = atan2(-delta.x, -delta.z)
	node.rotation.y = yaw

func _finish_run() -> void:
	is_finished = true
	if _energy_chaser != null:
		_energy_chaser.stop_chase()
	if _chase_overlay != null:
		_chase_overlay.visible = false
	_close_settlement_pause()
	get_tree().paused = false
	_play_player_animation("celebrate")
	var cargo_load := int(mission.get("cargo_load", 100))
	# 据点进度贡献按设计固定装载量 100 × 完整度%
	var progress_cargo_load := 100
	var repair_total := Global.DEFAULT_OUTPOST_REPAIR_TOTAL
	var light_reward_coins := 0
	var is_custom := CustomLevels.has_level(Global.runner_location_id)
	var progress_result := {
		"newly_lit": false,
		"already_lit": false,
		"contribution": 0,
		"progress_after": 0,
		"repair_total": repair_total,
	}
	var mission_id := String(Global.runner_mission_id)
	if mission_id == "":
		mission_id = Global.mission_key(mission)
	if not is_custom and mission_id != "":
		if LevelConfig.has_method("get_outpost_meta"):
			var outpost_meta: Dictionary = LevelConfig.get_outpost_meta(Global.runner_location_id)
			repair_total = maxi(1, int(outpost_meta.get("repair_total", repair_total)))
			light_reward_coins = maxi(0, int(outpost_meta.get("reward_coins", 0)))
		progress_result = Global.apply_mission_run_progress(
			Global.runner_planet_id,
			mission_id,
			cargo_integrity,
			mission
		)
	var newly_lit := bool(progress_result.get("location_newly_lit", progress_result.get("newly_lit", false)))
	var progress_gain := int(progress_result.get("gain", progress_result.get("contribution", 0)))
	var progress_after := int(progress_result.get("progress_after", 0))
	var progress_total := int(progress_result.get("target", progress_result.get("repair_total", 100)))
	var newly_completed := bool(progress_result.get("newly_completed", false))
	var reward_pending := int(progress_result.get("reward_pending", 0))
	if newly_lit:
		_apply_mission_unlocks()
		# 点亮奖励改为详情页手动领取，避免与据点奖励重复发放
		Global.queue_outpost_light_reward(Global.runner_planet_id, Global.runner_location_id)
		Global.pending_location_showcase_id = Global.runner_location_id
	else:
		Global.pending_location_showcase_id = ""
	var delivered := int(float(cargo_load) * cargo_integrity * 0.01)
	var grade: String = LevelConfig.integrity_grade(cargo_integrity)
	var grade_label: String = LevelConfig.integrity_grade_label(cargo_integrity) if LevelConfig.has_method("integrity_grade_label") else grade
	var base_coins := collected_count * int(LevelConfig.EMBER_COIN_VALUE)
	var grade_mult: float = LevelConfig.grade_coin_multiplier(grade) if LevelConfig.has_method("grade_coin_multiplier") else 1.0
	var time_mult := MissionTypes.time_bonus_multiplier(_mission_profile, elapsed, _run_time)
	var coin_bonus := int(round(float(base_coins) * Global.get_coin_yield_multiplier() * grade_mult * time_mult))
	run_score += delivered + coin_bonus
	Global.add_ember_coins(coin_bonus)
	var xp_result: Dictionary = Global.grant_messenger_runner_rewards(
		grade,
		int(mission.get("difficulty", 1)),
		newly_lit
	)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var level_text := "Lv.%d" % int(xp_result["new_level"])
	if bool(xp_result["level_up"]):
		level_text = "Level up! Lv.%d" % int(xp_result["new_level"])
	var type_line := "%s • %0.0f s" % [
		String(mission.get("task_type", "Supply Run")),
		elapsed,
	]
	var progress_line := "Mission Progress • %d / %d" % [progress_after, progress_total]
	if progress_gain > 0 and not newly_completed:
		progress_line = "Mission Progress +%d • %d / %d" % [progress_gain, progress_after, progress_total]
	elif newly_completed:
		progress_line = "Mission Complete • %d / %d" % [progress_after, progress_total]
	var reward_line := "Run Reward • %d Ember Coins" % coin_bonus
	if newly_completed and reward_pending > 0:
		reward_line += "\nClaim %d Ember Coins on Tasks" % reward_pending
	var settlement_body := "%s\nCargo Integrity • %0.0f%%\nRating • %s\n%s\n\n%s\nXP +%d • %s" % [
		type_line,
		cargo_integrity,
		grade_label,
		progress_line,
		reward_line,
		int(xp_result["xp_gain"]),
		level_text,
	]
	var location_title := _finish_outpost_title_en()
	_settlement_is_failure = false
	_show_state(location_title, settlement_body, "success")
	if state_back_button and String(Global.runner_return_scene) == "":
		state_back_button.text = "BACK TO MAP"
	var outpost_complete := _is_settlement_outpost_complete(progress_after, progress_total, newly_lit)
	_set_continue_run_enabled(not outpost_complete)
	if state_restart_button and newly_lit:
		state_restart_button.visible = false
	elif state_restart_button:
		state_restart_button.visible = true
		state_restart_button.text = "CONTINUE RUN"

func _apply_mission_unlocks() -> void:
	# 点亮后的揭示与任务板由批次派发统一处理
	Global.sync_mission_dispatch(Global.runner_planet_id)
	var revealed := Global.get_revealed_exploration_locations(
		Global.runner_planet_id,
		MissionDispatch.get_batch1_location_ids(Global.runner_planet_id)
	)
	if not revealed.has(Global.runner_location_id):
		revealed.append(Global.runner_location_id)
	for linked_id in mission.get("unlock_ids", []):
		var location_id := String(linked_id)
		# 仅揭示已解锁批次内的相邻点，避免提前开下一批
		if location_id == "":
			continue
		if not MissionDispatch.is_location_batch_unlocked(Global.runner_planet_id, location_id):
			continue
		if not revealed.has(location_id):
			revealed.append(location_id)
	Global.set_revealed_exploration_locations(Global.runner_planet_id, revealed)
	Global.sync_mission_dispatch(Global.runner_planet_id)

func _fail_run(reason: String = "被零潮捕获") -> void:
	if _is_chaser_capture_reason(reason) and not _capture_settlement_ready:
		_begin_capture_cinematic(reason)
		return
	is_failed = true
	_capture_cinematic_active = false
	if _energy_chaser != null and _energy_chaser.state != EnergyChaserController.ChaseState.CAPTURED:
		_energy_chaser.stop_chase()
	if _chase_overlay != null:
		_chase_overlay.visible = false
	if _capture_swallow != null:
		_capture_swallow.visible = false
	_close_settlement_pause()
	get_tree().paused = false
	_clear_sky_cheer_danmaku()
	_play_player_animation("idle")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var fail_reason := reason
	if cargo_integrity <= 0.0:
		fail_reason = "货物损毁"
	elif reason.contains("零潮") and not _chaser_enabled:
		fail_reason = "时间耗尽"
	var fail_reason_en := _fail_reason_en(fail_reason)
	var mission: Dictionary = LevelConfig.MISSION if LevelConfig != null else {}
	var repair_total := 400
	if LevelConfig != null and LevelConfig.has_method("get_outpost_meta"):
		var outpost_meta: Dictionary = LevelConfig.get_outpost_meta(Global.runner_location_id)
		repair_total = maxi(1, int(outpost_meta.get("repair_total", 400)))
	var location_progress := Global.get_outpost_progress(Global.runner_planet_id, Global.runner_location_id)
	var xp_result: Dictionary = Global.grant_messenger_runner_rewards("Failed", int(mission.get("difficulty", 1)), false)
	var level_text := "Lv.%d" % int(xp_result["new_level"])
	var type_line := "%s • %0.0f s" % [
		String(mission.get("task_type", "Supply Run")),
		elapsed,
	]
	var progress_line := "Outpost Progress • %d / %d" % [location_progress, repair_total]
	var settlement_body := "%s\nCargo Integrity • %0.0f%%\nRating • Failed ☆☆☆☆☆\n%s\n\nMission Reward • 0 Ember Coins\nXP +%d • %s" % [
		type_line,
		cargo_integrity,
		progress_line,
		int(xp_result["xp_gain"]),
		level_text,
	]
	var location_title := _finish_outpost_title_en()
	_settlement_is_failure = true
	_show_state(location_title, settlement_body, "failure", fail_reason_en)
	_set_continue_run_enabled(true)
	if state_back_button:
		if String(Global.runner_return_scene) != "":
			state_back_button.text = "BACK TO EDITOR"
		elif _settlement_is_failure:
			state_back_button.text = "BACK TO MAP"
		else:
			state_back_button.text = "BACK TO MAP"

func _on_state_back_pressed() -> void:
	_return_to_exploration_map()

func _fail_reason_en(reason: String) -> String:
	var text := reason.strip_edges()
	if text.contains("货物") or text.contains("损毁") or text.contains("完整度"):
		return "DELIVERY LOST"
	if text.contains("时间") or text.contains("限时"):
		return "TIME OUT"
	if text.contains("零潮") or text.contains("追上") or text.contains("吞没") or text.contains("异能"):
		return "ZERO TIDE CONSUMED YOU"
	if text.contains("坑") or text.contains("熔岩") or text.contains("坍塌"):
		return "ROUTE FAILED"
	return text.to_upper()

func _is_settlement_outpost_complete(location_progress: int, progress_total: int, newly_lit: bool) -> bool:
	if newly_lit:
		return true
	if progress_total > 0 and location_progress >= progress_total:
		return true
	var planet_id := String(Global.runner_planet_id)
	var location_id := String(Global.runner_location_id)
	if planet_id != "" and location_id != "" and Global.get_completed_runner_locations(planet_id).has(location_id):
		return true
	return false

func _set_continue_run_enabled(enabled: bool) -> void:
	_settlement_continue_locked = not enabled
	if state_restart_button == null:
		return
	state_restart_button.visible = true
	state_restart_button.text = "RETRY DELIVERY" if _settlement_is_failure else "CONTINUE RUN"
	state_restart_button.disabled = not enabled
	state_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	if enabled:
		state_restart_button.modulate = Color(1, 1, 1, 1)
		state_restart_button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		state_restart_button.add_theme_color_override("font_hover_color", Color(0.96, 0.98, 1.0))
		state_restart_button.add_theme_color_override("font_pressed_color", Color(0.72, 0.78, 0.88))
		state_restart_button.add_theme_color_override("font_disabled_color", Color(0.55, 0.58, 0.66))
		_apply_settlement_button_style(state_restart_button, SETTLEMENT_BUTTON_BG, SETTLEMENT_BUTTON_BORDER)
	else:
		# 任务/据点已达成：变灰不可按
		state_restart_button.modulate = Color(0.62, 0.64, 0.70, 0.85)
		state_restart_button.add_theme_color_override("font_color", Color(0.52, 0.54, 0.60))
		state_restart_button.add_theme_color_override("font_hover_color", Color(0.52, 0.54, 0.60))
		state_restart_button.add_theme_color_override("font_pressed_color", Color(0.52, 0.54, 0.60))
		state_restart_button.add_theme_color_override("font_disabled_color", Color(0.48, 0.50, 0.56))
		_apply_settlement_button_style(state_restart_button, Color(0.16, 0.17, 0.24, 0.72), Color(0.36, 0.38, 0.46, 0.4))

func _return_to_exploration_map() -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		_pause_overlay.close_pause()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.play_home_bgm()
	var return_scene := String(Global.runner_return_scene)
	Global.runner_return_scene = ""
	if return_scene != "":
		Global.change_game_scene(return_scene)
		return
	Global.exploration_planet_id = Global.runner_planet_id
	Global.mobile_home_tab = "map"
	Global.change_game_scene(PlanetDatabase.EXPLORATION_SCENE)

func _close_settlement_pause() -> void:
	if _pause_overlay != null:
		_pause_overlay.force_close()

func _setup_pause_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.name = "PauseLayer"
	layer.layer = 40
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_pause_overlay = MobilePauseOverlay.new()
	var quit_text := "返回编辑器" if String(Global.runner_return_scene) != "" else "返回地图"
	_pause_overlay.configure({
		"quit_text": quit_text,
		"show_quit": true,
		"show_pause_button": true,
	})
	_pause_overlay.quit_pressed.connect(_return_to_exploration_map)
	layer.add_child(_pause_overlay)

func _strike_reason_for_obstacle(obstacle: Dictionary) -> String:
	var custom := String(obstacle.get("strike_label", ""))
	if custom != "":
		return "撞上%s" % custom
	var obstacle_type := String(obstacle["type"])
	if obstacle_type in LevelConfig.OBSTACLE_TYPES:
		return "撞上%s" % LevelConfig.OBSTACLE_TYPES[obstacle_type]
	return "撞上障碍"

func _set_lane(next_lane_index: int) -> void:
	var prev := lane_index
	lane_index = clampi(next_lane_index, 0, LANES.size() - 1)
	target_lane_x = LANES[lane_index] * LANE_WIDTH
	if _is_wall_running() and lane_index != prev:
		var target_wy := float(WALL_LANE_HEIGHTS[lane_index])
		current_wall_y = target_wy
		if player != null:
			player.position.y = lerpf(player.position.y, target_wy + 0.18, 0.85)
		vertical_velocity = maxf(vertical_velocity, 4.2)
		body_tilt = clampf(body_tilt + (1.0 if lane_index > prev else -1.0) * 0.55, -0.85, 0.85)
		camera_shake = maxf(camera_shake, 0.14)
		var label := WALL_LANE_LABELS[clampi(lane_index, 0, WALL_LANE_LABELS.size() - 1)]
		_show_gate_toast("侧墙换列 · %s" % label)
		strike_toast_label.modulate = Color(0.55, 0.92, 1.0, 1.0)
		strike_toast_timer = 0.85


func _uses_smash_collision() -> bool:
	var layout_id := _mission_layout_id_for_smash()
	if layout_id != "" and SMASH_LAYOUT_IDS.has(layout_id):
		return true
	var mid := String(mission.get("mission_id", "")).strip_edges()
	if mid == "":
		mid = String(Global.runner_mission_id).strip_edges()
	if mid != "" and SMASH_MISSION_IDS.has(mid):
		return true
	return false


func _refresh_smash_budget() -> void:
	_smash_obstacle_total = 0
	if not _uses_smash_collision():
		_smash_cargo_damage = SMASH_CARGO_BASE
		return
	for obstacle in obstacles:
		if typeof(obstacle) != TYPE_DICTIONARY:
			continue
		if _can_smash_obstacle(obstacle):
			_smash_obstacle_total += 1
	var total := maxi(_smash_obstacle_total, 1)
	_smash_cargo_damage = 100.0 / float(total)


func _cargo_fragility_mult() -> float:
	var explicit := float(mission.get("cargo_fragility", 0.0))
	if explicit > 0.01:
		return clampf(explicit, 0.5, 2.0)
	if _is_defense_cargo():
		return DEFENSE_CARGO_FRAGILITY
	if _is_overweight_cargo():
		return 0.78
	return 1.0


func _toxic_rain_cargo_hit_mult() -> float:
	## 毒雨段内：碰撞货物完整度损失额外 +10%（可用 rain_cargo_hit_mult 覆盖）
	if not _is_in_rain_hazard_at(track_distance):
		return 1.0
	var zone := _rain_zone_at(track_distance)
	var kind := String(mission.get("rain_kind", "toxic")).to_lower()
	if not zone.is_empty():
		kind = String(zone.get("rain_kind", kind)).to_lower()
	if kind == "clean":
		return 1.0
	return clampf(float(mission.get("rain_cargo_hit_mult", 1.1)), 1.0, 2.0)


func _cargo_damage_for_smash_obstacle(obstacle: Dictionary) -> float:
	var otype := String(obstacle.get("type", ""))
	var tier := float(SMASH_CARGO_TIER.get(otype, 1.0))
	if _is_large_smash_obstacle_entry(obstacle):
		tier *= 1.52
	elif otype == "orb":
		match String(obstacle.get("orb_tier", "")):
			"huge", "colossal":
				tier *= 1.48
			"large":
				tier *= 1.22
			"medium":
				tier *= 1.0
			_:
				tier *= 0.78
	elif otype == "meteorite":
		var radius := float(obstacle.get("meteor_radius", 0.0))
		if radius <= 0.01:
			radius = maxf(float(obstacle.get("span", 2.0)) * 0.5, 0.7)
		if radius >= 1.45:
			tier *= 1.42
		elif radius >= 1.1:
			tier *= 1.18
		elif radius >= 0.85:
			tier *= 1.0
		else:
			tier *= 0.82
	var dmg := SMASH_CARGO_BASE * tier * _cargo_fragility_mult() * Global.get_cargo_damage_multiplier() * _toxic_rain_cargo_hit_mult()
	return clampf(dmg, SMASH_CARGO_DAMAGE_MIN, SMASH_CARGO_DAMAGE_MAX)




func _is_large_smash_obstacle(obstacle_type: String) -> bool:
	return obstacle_type in ["slide", "high_bar", "block_left", "block_right", "meteorite"]


func _is_large_smash_obstacle_entry(obstacle: Dictionary) -> bool:
	if _is_large_smash_obstacle(String(obstacle.get("type", ""))):
		return true
	return String(obstacle.get("orb_tier", "")) in ["large", "huge", "colossal"]


func _smash_sfx_size_key(obstacle: Dictionary) -> String:
	var otype := String(obstacle.get("type", ""))
	match otype:
		"meteorite":
			var radius := float(obstacle.get("meteor_radius", 0.0))
			if radius <= 0.01:
				radius = maxf(float(obstacle.get("span", 2.0)) * 0.5, 0.7)
			if radius >= 1.45:
				return "huge"
			if radius >= 1.1:
				return "large"
			if radius >= 0.85:
				return "medium"
			return "small"
		"train", "train_moving":
			return "medium"
		"slide", "high_bar", "block_left", "block_right", "main_block":
			return "large"
		"orb":
			match String(obstacle.get("orb_tier", "")):
				"colossal", "huge":
					return "huge"
				"large":
					return "large"
				"tiny":
					return "tiny"
				_:
					return "small"
		"jump", "low_barrier":
			return "small"
		_:
			return "medium"


func _can_smash_obstacle(obstacle: Dictionary) -> bool:
	var otype := String(obstacle.get("type", ""))
	# 熔岩封路仍不可撞碎，必须上墙绕过
	if otype in ["main_block", "ramp", "turn_left", "turn_right", "meteorite_gate"]:
		return false
	if not _obstacle_has_meaningful_visual(obstacle):
		return false
	return true


func _shatter_obstacle(obstacle: Dictionary) -> void:
	obstacle["hit"] = true
	obstacle["smashed"] = true
	var otype := String(obstacle.get("type", ""))
	var palette := _smash_palette_for_type(otype)
	var size_key := _smash_sfx_size_key(obstacle)
	var node = obstacle.get("node", null)
	var blast_pos := player.global_position + Vector3(0.0, 1.1, 0.0) if player else Vector3.ZERO
	var forward := Vector3(0.0, 0.0, -1.0)
	if player != null:
		forward = (-player.global_transform.basis.z).normalized()
	if node != null and is_instance_valid(node) and node is Node3D:
		var n := node as Node3D
		blast_pos = n.global_position + Vector3(0.0, 0.95, 0.0)
		_play_obstacle_shatter_fx(n, otype, palette, forward, size_key)
		obstacle["node"] = null
	else:
		Global.play_sfx_shatter(1.0, size_key in ["large", "huge"], size_key)
		_spawn_shatter_burst(blast_pos, palette, _is_large_smash_obstacle(otype), forward)


func _play_obstacle_shatter_fx(node: Node3D, obstacle_type: String, palette: Dictionary, forward: Vector3, size_key: String = "medium") -> void:
	var large := size_key in ["large", "huge"] or _is_large_smash_obstacle(obstacle_type)
	Global.play_sfx_shatter(1.0, large, size_key)
	var origin := node.global_position + Vector3(0.0, 0.95, 0.0)
	# 瞬间碎裂：本体立刻消失，改为碎片/粒子
	node.visible = false
	if large:
		_spawn_shatter_chunks(origin, palette, forward, 18 if obstacle_type.begins_with("train") else 14)
	else:
		# 小型：很多细碎片 + 超密粒子
		_spawn_shatter_chunks(origin, palette, forward, 28, true)
	_spawn_shatter_burst(origin, palette, large, forward)
	node.queue_free()


func _smash_palette_for_type(obstacle_type: String) -> Dictionary:
	match obstacle_type:
		"orb":
			return {
				"dust": Color(0.78, 0.42, 1.0),
				"spark": Color(0.95, 0.55, 1.0),
				"chunk": Color(0.55, 0.28, 0.82),
				"emit": Color(0.72, 0.35, 1.0),
			}
		"meteorite":
			return {
				"dust": Color(0.55, 0.72, 0.95),
				"spark": Color(0.45, 0.95, 1.0),
				"chunk": Color(0.35, 0.42, 0.55),
				"emit": Color(0.55, 0.85, 1.0),
			}
		"jump", "low_barrier":
			return {
				"dust": Color(0.95, 0.86, 0.55),
				"spark": Color(1.0, 0.72, 0.28),
				"chunk": Color(0.9, 0.78, 0.48),
				"emit": Color(1.0, 0.82, 0.4),
			}
		"slide", "high_bar":
			return {
				"dust": Color(0.45, 0.88, 1.0),
				"spark": Color(0.35, 0.95, 1.0),
				"chunk": Color(0.55, 0.72, 0.85),
				"emit": Color(0.4, 0.9, 1.0),
			}
		"wave_arc_slide":
			return {
				"dust": Color(0.62, 0.42, 0.95),
				"spark": Color(1.0, 0.62, 0.32),
				"chunk": Color(0.48, 0.32, 0.72),
				"emit": Color(0.95, 0.55, 1.0),
			}
		"energy_ring":
			return {
				"dust": Color(0.78, 0.42, 1.0),
				"spark": Color(1.0, 0.72, 0.38),
				"chunk": Color(0.55, 0.28, 0.82),
				"emit": Color(0.88, 0.45, 1.0),
			}
		"train", "train_moving":
			return {
				"dust": Color(0.72, 0.74, 0.78),
				"spark": Color(1.0, 0.48, 0.18),
				"chunk": Color(0.42, 0.44, 0.48),
				"emit": Color(1.0, 0.55, 0.2),
			}
		"block_left", "block_right":
			return {
				"dust": Color(0.78, 0.55, 1.0),
				"spark": Color(0.95, 0.45, 1.0),
				"chunk": Color(0.55, 0.4, 0.72),
				"emit": Color(0.85, 0.4, 1.0),
			}
		_:
			return {
				"dust": Color(0.9, 0.82, 0.6),
				"spark": Color(1.0, 0.65, 0.25),
				"chunk": Color(0.75, 0.7, 0.6),
				"emit": Color(1.0, 0.7, 0.3),
			}


func _spawn_shatter_burst(world_pos: Vector3, palette: Dictionary, large: bool, forward: Vector3) -> void:
	if track_root == null:
		return
	var dust_col: Color = palette.get("dust", Color(0.9, 0.8, 0.5))
	var spark_col: Color = palette.get("spark", Color(1.0, 0.6, 0.2))
	var emit_col: Color = palette.get("emit", spark_col)
	# 主溅射：大量尘屑
	var dust := _make_burst_particles(
		28 if large else 18,
		0.65 if large else 0.48,
		dust_col,
		emit_col,
		3.5 if large else 2.4,
		9.5 if large else 6.8,
		0.07,
		0.2
	)
	track_root.add_child(dust)
	dust.global_position = world_pos
	# 火花层
	var sparks := _make_burst_particles(
		18 if large else 12,
		0.4,
		spark_col,
		emit_col,
		4.0,
		11.0 if large else 8.0,
		0.04,
		0.1,
		true
	)
	track_root.add_child(sparks)
	sparks.global_position = world_pos
	# 冲击环
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.35
	torus.outer_radius = 0.55
	torus.rings = 12
	torus.ring_segments = 24
	var ring_mat := _make_material(Color(emit_col.r, emit_col.g, emit_col.b, 0.75), emit_col, 2.8)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	torus.material = ring_mat
	ring.mesh = torus
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	track_root.add_child(ring)
	ring.global_position = world_pos
	if forward.length_squared() > 0.01:
		ring.look_at(world_pos + forward, Vector3.UP)
	ring.rotate_object_local(Vector3.RIGHT, PI * 0.5)
	var ring_tw := create_tween()
	ring_tw.set_parallel(true)
	ring_tw.tween_property(ring, "scale", Vector3(3.2 if large else 2.2, 3.2 if large else 2.2, 3.2 if large else 2.2), 0.28).set_ease(Tween.EASE_OUT)
	ring_tw.tween_property(ring_mat, "albedo_color:a", 0.0, 0.28)
	ring_tw.chain().tween_callback(ring.queue_free)
	get_tree().create_timer(1.0).timeout.connect(func():
		if is_instance_valid(dust):
			dust.queue_free()
		if is_instance_valid(sparks):
			sparks.queue_free()
	)


func _make_burst_particles(
	amount: int,
	lifetime: float,
	albedo: Color,
	emit_col: Color,
	vel_min: float,
	vel_max: float,
	scale_min: float,
	scale_max: float,
	as_sparks: bool = false
) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = amount
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.fixed_fps = 0
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 180.0
	mat.initial_velocity_min = vel_min
	mat.initial_velocity_max = vel_max
	mat.gravity = Vector3(0.0, -16.0 if as_sparks else -12.0, 0.0)
	mat.scale_min = scale_min
	mat.scale_max = scale_max
	mat.color = albedo
	particles.process_material = mat
	var mesh: Mesh
	var sm := StandardMaterial3D.new()
	sm.albedo_color = albedo
	sm.emission_enabled = true
	sm.emission = emit_col
	sm.emission_energy_multiplier = 2.4 if as_sparks else 1.5
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if as_sparks:
		var box := BoxMesh.new()
		box.size = Vector3(0.07, 0.07, 0.18)
		box.material = sm
		mesh = box
	else:
		var sphere := SphereMesh.new()
		sphere.radius = 0.07
		sphere.height = 0.14
		sphere.material = sm
		mesh = sphere
	particles.draw_pass_1 = mesh
	return particles


func _spawn_shatter_chunks(world_pos: Vector3, palette: Dictionary, forward: Vector3, count: int, _tiny: bool = false) -> void:
	if track_root == null:
		return
	var chunk_col: Color = palette.get("chunk", Color(0.7, 0.65, 0.55))
	var emit_col: Color = palette.get("emit", Color(1.0, 0.7, 0.3))
	var right := forward.cross(Vector3.UP)
	if right.length_squared() < 0.01:
		right = Vector3.RIGHT
	right = right.normalized()
	for i in count:
		var chunk := MeshInstance3D.new()
		var mesh: Mesh
		if i % 3 == 0:
			var prism := PrismMesh.new()
			prism.size = Vector3(randf_range(0.25, 0.55), randf_range(0.18, 0.4), randf_range(0.2, 0.45))
			mesh = prism
		elif i % 3 == 1:
			var box := BoxMesh.new()
			box.size = Vector3(randf_range(0.22, 0.5), randf_range(0.16, 0.35), randf_range(0.2, 0.42))
			mesh = box
		else:
			var sphere := SphereMesh.new()
			sphere.radius = randf_range(0.12, 0.22)
			sphere.height = sphere.radius * 2.0
			mesh = sphere
		var mat := _make_material(chunk_col, emit_col, 1.1)
		if mesh is PrimitiveMesh:
			(mesh as PrimitiveMesh).material = mat
		chunk.mesh = mesh
		chunk.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		track_root.add_child(chunk)
		chunk.global_position = world_pos + right * randf_range(-0.6, 0.6) + Vector3(0.0, randf_range(0.1, 0.5), 0.0)
		chunk.rotation_degrees = Vector3(randf_range(0.0, 360.0), randf_range(0.0, 360.0), randf_range(0.0, 360.0))
		var dir := (forward * randf_range(0.35, 1.1) + right * randf_range(-1.0, 1.0) + Vector3.UP * randf_range(0.6, 1.4)).normalized()
		var fly := dir * randf_range(2.8, 5.5)
		var end_pos := chunk.global_position + fly + Vector3(0.0, -1.8, 0.0)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(chunk, "global_position", end_pos, randf_range(0.42, 0.7)).set_ease(Tween.EASE_OUT)
		tw.tween_property(chunk, "rotation_degrees", chunk.rotation_degrees + Vector3(randf_range(120.0, 420.0), randf_range(-180.0, 180.0), randf_range(90.0, 360.0)), 0.65)
		tw.tween_property(chunk, "scale", Vector3(0.05, 0.05, 0.05), 0.55).set_delay(0.12)
		tw.chain().tween_callback(chunk.queue_free)


func _on_runner_strike(reason: String, obstacle: Dictionary = {}) -> void:
	var obstacle_type := String(obstacle.get("type", ""))
	if obstacle_type == "main_block":
		if _main_block_obstacle_uses_platform(obstacle):
			return
		_fail_into_pit("冲入主路熔岩坍塌带（需上侧墙绕过）")
		return
	if obstacle_type != "" and not _obstacle_has_meaningful_visual(obstacle):
		return
	strike_count += 1
	strike_recovery_timer = 0.0
	if _pressure_chaser_enabled and _energy_chaser != null:
		pass
	else:
		chaser_distance = maxf(chaser_distance - _chaser_hit_penalty(), CHASER_CATCH_DISTANCE)
	var rushing := _is_fork_rushing()
	var smash := _uses_smash_collision() and _can_smash_obstacle(obstacle)
	if smash and not _obstacle_has_meaningful_visual(obstacle):
		return
	if smash:
		_smash_hit_count += 1
		_apply_smash_body_impact(_is_large_smash_obstacle_entry(obstacle))
		run_score += 18
		var cargo_dmg := _smash_cargo_damage * _toxic_rain_cargo_hit_mult()
		_apply_cargo_loss(cargo_dmg)
		var hp_lost := Global.apply_runner_hp_loss(SMASH_RUNNER_HP_DAMAGE)
		var impact_pos := player.global_position + Vector3(0.0, 1.7, 0.0) if player else Vector3.ZERO
		if _hit_feedback != null:
			_hit_feedback.apply_impact(
				impact_pos,
				HitFeedback.Intensity.HEAVY,
				cargo_dmg,
				"撞碎 %d/%d" % [_smash_hit_count, maxi(_smash_obstacle_total, 1)]
			)
		_shatter_obstacle(obstacle)
		if is_failed:
			return
		if _pressure_chaser_enabled and _energy_chaser != null:
			_energy_chaser.notify_hit(true)
			chaser_distance = _energy_chaser.get_visual_gap()
		elif chaser_distance <= CHASER_CATCH_DISTANCE and _chaser_enabled:
			_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)
			return
		var toast := "撞碎障碍 · 货物 -%0.0f%%（%d/%d）" % [
			cargo_dmg, _smash_hit_count, maxi(_smash_obstacle_total, 1)
		]
		if hp_lost > 0.001:
			toast += " · 体力 -%0.1f" % hp_lost
		_show_strike_warning(toast)
		return
	if rushing:
		speed_penalty_mult = 1.0
		speed_penalty_timer = 0.0
		run_score += 35
		camera_shake = maxf(camera_shake, 0.38)
	else:
		speed_penalty_mult = HIT_SLOW_FACTOR
		speed_penalty_timer = HIT_SLOW_DURATION
		_apply_obstacle_impact_block(obstacle)
	chaser_pulse = 1.0
	var tier := float(STRIKE_DAMAGE_TIER.get(obstacle_type, 1.0))
	var fragility := _cargo_fragility_mult()
	var damage: float = float(LevelConfig.CARGO_DAMAGE_PER_HIT) * tier * Global.get_cargo_damage_multiplier() * fragility * _toxic_rain_cargo_hit_mult()
	if rushing:
		damage *= FORK_RUSH_DAMAGE_MULT
	var intensity: int = HitFeedback.Intensity.MEDIUM
	if rushing:
		intensity = HitFeedback.Intensity.HEAVY
	elif tier >= 1.35:
		intensity = HitFeedback.Intensity.HEAVY
	elif tier <= 0.9:
		intensity = HitFeedback.Intensity.LIGHT
	_apply_cargo_loss(damage)
	var impact_pos2 := player.global_position + Vector3(0.0, 1.7, 0.0) if player else Vector3.ZERO
	if _hit_feedback != null:
		_hit_feedback.apply_impact(impact_pos2, intensity, damage, "飞驰撞击" if rushing else reason)
	else:
		camera_shake = maxf(camera_shake, 0.32 if rushing else 0.28)
	_pulse_obstacle_hit_visual(obstacle)
	if is_failed:
		return
	if _pressure_chaser_enabled and _energy_chaser != null:
		var severe := rushing or intensity == HitFeedback.Intensity.HEAVY
		_energy_chaser.notify_hit(severe)
		chaser_distance = _energy_chaser.get_visual_gap()
	elif chaser_distance <= CHASER_CATCH_DISTANCE:
		if _chaser_enabled:
			_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)
		return
	_show_strike_warning("飞驰连撞" if rushing else reason)


func _apply_obstacle_impact_block(obstacle: Dictionary) -> void:
	var obs_dist := float(obstacle.get("distance", track_distance)) + float(obstacle.get("move_offset", 0.0))
	var half := float(obstacle.get("half_depth", _obstacle_half_depth(String(obstacle.get("type", "")))))
	track_distance = minf(track_distance, obs_dist - half - HIT_BOUNCE_GAP)
	_hit_stun_timer = HIT_STUN_TIME
	_hitstop_timer = HIT_STOP_TIME
	_hit_recoil_timer = 0.42
	camera_shake = maxf(camera_shake, 0.4)
	if player != null:
		vertical_velocity = minf(vertical_velocity, -1.2)
	_sync_player_position()


func _apply_smash_body_impact(large: bool) -> void:
	speed_penalty_mult = 0.55 if large else 0.68
	speed_penalty_timer = 0.38 if large else 0.26
	_hit_stun_timer = 0.2 if large else 0.14
	_hitstop_timer = 0.1 if large else 0.07
	_hit_recoil_timer = 0.48 if large else 0.36
	body_squash_timer = maxf(body_squash_timer, 0.16 if large else 0.12)
	camera_shake = maxf(camera_shake, 0.58 if large else 0.46)
	if player != null:
		vertical_velocity = minf(vertical_velocity, -2.4 if large else -1.6)
	track_distance = maxf(track_distance - (0.55 if large else 0.32), 0.0)
	if player_body:
		player_body.scale = Vector3(1.1, 0.88, 1.08)
	_sync_player_position()


func _pulse_obstacle_hit_visual(obstacle: Dictionary) -> void:
	var node = obstacle.get("node", null)
	if node == null or not is_instance_valid(node) or not (node is Node3D):
		return
	var n := node as Node3D
	var base_scale := n.scale
	var tw := create_tween()
	tw.tween_property(n, "scale", base_scale * Vector3(1.12, 0.88, 1.12), 0.05)
	tw.tween_property(n, "scale", base_scale, 0.16)

func _show_strike_warning(reason: String) -> void:
	if not gameplay_active:
		return
	intro_panel.visible = false
	var tip := _compact_strike_tip(reason)
	var color := Color(0.55, 0.88, 1.0, 1.0) if tip.contains("防护罩") else Color(1.0, 0.55, 0.35, 1.0)
	_show_runway_combat_tip(tip, color)

func _chaser_hit_penalty() -> float:
	if _is_relay_mission():
		return CHASER_RELAY_HIT_PENALTY
	return CHASER_HIT_PENALTY


func _chaser_repulse(amount: float) -> void:
	if not _chaser_enabled:
		return
	if _pressure_chaser_enabled and _energy_chaser != null:
		# 加速靴 / 稳定器：减压，映射方案中的 stabilizer ≈ -15
		var relief := 15.0 if amount >= CHASER_BOOST_REPULSE * 0.5 else 8.0
		_energy_chaser.reward_clean_play(relief)
		chaser_distance = _energy_chaser.get_visual_gap()
		return
	chaser_distance = minf(chaser_distance + maxf(amount, 0.0), CHASER_MAX_DISTANCE)


func _update_chaser(delta: float) -> void:
	if not _chaser_enabled:
		return
	if _pressure_chaser_enabled and _energy_chaser != null:
		chaser_distance = _energy_chaser.get_visual_gap()
		if _energy_chaser.state == EnergyChaserController.ChaseState.CRITICAL:
			camera_shake = maxf(camera_shake, 0.08 + _energy_chaser.get_normalized_pressure() * 0.06)
		if strike_count > 0:
			strike_recovery_timer += delta
			if strike_recovery_timer >= STRIKE_RECOVERY_TIME:
				strike_count = 0
				strike_recovery_timer = 0.0
		return
	var creep_mult := clampf(float(_mission_profile.get("chaser_creep_mult", 1.0)), 0.5, 2.0)
	if _is_relay_mission():
		creep_mult *= CHASER_RELAY_CREEP_SCALE
	chaser_distance = maxf(chaser_distance - CHASER_BASE_CREEP * creep_mult * delta, CHASER_CATCH_DISTANCE)
	if strike_count > 0:
		strike_recovery_timer += delta
		if strike_recovery_timer >= STRIKE_RECOVERY_TIME:
			strike_count = 0
			strike_recovery_timer = 0.0
	else:
		var recovery := CHASER_RECOVERY_RATE
		if _speed_boost_timer > 0.0 or _finish_sprint_timer > 0.0 or _is_fork_rushing():
			recovery *= CHASER_BOOST_RECOVERY_MULT
		if chaser_distance < CHASER_MAX_DISTANCE:
			chaser_distance = minf(chaser_distance + recovery * delta, CHASER_MAX_DISTANCE)

func _check_chaser_caught() -> void:
	if not _chaser_enabled:
		return
	if _pressure_chaser_enabled:
		return
	if chaser_distance <= CHASER_CATCH_DISTANCE:
		_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)

func _update_pre_run(delta: float) -> void:
	intro_elapsed += delta
	if _pressure_chaser_enabled and _energy_chaser != null and is_intro:
		# 开局：压迫冻结为 0，只展示潮体；后侧反打驱动镜头
		_energy_chaser.pressure = 0.0
		_energy_chaser._clean_timer = 0.0
		_energy_chaser.preview_gap = CHASER_REAR_PREVIEW_GAP
		_update_chaser_rear_intro(delta)
		chaser_distance = _energy_chaser.get_visual_gap()
	if pre_run_phase == "loading":
		intro_title.text = "Preparing Route..."
		intro_body.text = "正在规划运输路线…"
		if _world_ready and intro_elapsed >= PRE_RUN_LOADING_TIME:
			pre_run_phase = "countdown"
			countdown_step = 3
			countdown_timer = 0.0
			_refresh_smash_budget()
			Global.play_runner_bgm_from_start()
		return

	if pre_run_phase == "countdown":
		countdown_timer += delta
		if _chaser_enabled and not _pressure_chaser_enabled:
			_chaser_intro_look = maxf(_chaser_intro_look - delta * 0.22, 0.35)
		intro_title.text = str(countdown_step)
		intro_body.text = _pre_run_briefing_text()
		if countdown_timer >= PRE_RUN_COUNTDOWN_STEP:
			countdown_timer = 0.0
			countdown_step -= 1
			if countdown_step <= 0:
				is_intro = false
				gameplay_active = true
				intro_panel.visible = false
				_chaser_intro_look = 0.0
				_set_player_intro_facing(false)
				_schedule_sky_cheer_danmaku()
				_finish_chaser_rear_intro()
				if _chaser_enabled:
					call_deferred("_show_chaser_intro")
				_overweight_intro_pending = _is_overweight_cargo()
				if _is_defense_cargo() and shield_energy >= SHIELD_MIN_ACTIVATE - 0.001:
					shield_active = true
					_ensure_shield_mesh()
					_show_gate_toast("防御包 · 防护罩 +%d" % int(DEFENSE_CARGO_START_SHIELD))
				_overweight_run_tip_shown = false
				call_deferred("_try_show_overweight_intro_tip")
				if _is_rain_weather():
					call_deferred("_show_rain_intro")
		return


func _chaser_rear_intro_blend() -> float:
	## 0–0.6 正后 · 0.6–1.8 后侧反打 · 1.8–2.1 平滑回切 · 之后 0
	if not _pressure_chaser_enabled:
		return 0.0
	var t := _chaser_rear_intro_t
	if t < 0.6:
		return 0.0
	if t < 0.85:
		return _ease_out_cubic(clampf((t - 0.6) / 0.25, 0.0, 1.0))
	if t < 1.8:
		return 1.0
	if t < 1.8 + CHASER_REAR_RETURN_SEC:
		return 1.0 - _ease_out_cubic(clampf((t - 1.8) / CHASER_REAR_RETURN_SEC, 0.0, 1.0))
	return 0.0


func _update_chaser_rear_intro(delta: float) -> void:
	if _chaser_rear_intro_played or not _pressure_chaser_enabled:
		return
	# 仅在 countdown 阶段推进（loading 时保持正后预览）
	# 幽影脉冲 / 闪烁由 EnergyChaserController._process 驱动，此处不重复累加
	if pre_run_phase != "countdown":
		_chaser_intro_look = 0.0
		return
	_chaser_rear_intro_t = minf(_chaser_rear_intro_t + delta, CHASER_REAR_INTRO_TIME)
	_chaser_intro_look = _chaser_rear_intro_blend()
	# 1.8s 裂隙脉动闪一次
	if not _chaser_rear_flash_done and _chaser_rear_intro_t >= 1.8 and _energy_chaser != null:
		_chaser_rear_flash_done = true
		_energy_chaser.pulse_flash(0.4)
		camera_shake = maxf(camera_shake, 0.12)


func _finish_chaser_rear_intro() -> void:
	if not _pressure_chaser_enabled or _energy_chaser == null:
		return
	_chaser_rear_intro_played = true
	_chaser_rear_intro_t = CHASER_REAR_INTRO_TIME
	_chaser_intro_look = 0.0
	var start_p := float(mission.get("chaser_initial_pressure", 18.0))
	_energy_chaser.start_chase(start_p)
	_energy_chaser.set_physics_process(true)
	chaser_distance = _energy_chaser.get_visual_gap()


func _spawn_tide_wells_for_relay() -> void:
	## 分叉两路中间空中：紫色大叹号 + Nullfeed；路过缩短间距 25%
	for well in _tide_wells:
		var n: Node = well.get("node") as Node
		if n != null and is_instance_valid(n):
			n.queue_free()
	_tide_wells.clear()
	if not _pressure_chaser_enabled or track_root == null:
		return
	var candidates: Array[Dictionary] = []
	var path_len := maxf(_path_length, _track_length)
	var mid0 := path_len * 0.22
	var mid1 := path_len * 0.82
	for zone in _junction_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var start := float(zone.get("distance", 0.0))
		var length := float(zone.get("length", 70.0))
		# 两路最开处：分叉中段中线空中
		var mid_d := start + length * 0.5
		if mid_d < mid0 or mid_d > mid1:
			continue
		candidates.append({"d": mid_d, "spread": float(zone.get("spread", 18.0))})
	for region in _y_fork_regions:
		if typeof(region) != TYPE_DICTIONARY:
			continue
		var d0 := float(region.get("d_start", -1.0))
		var d1 := float(region.get("d_end", -1.0))
		if d0 < 0.0 or d1 < 0.0:
			continue
		var mid_d2 := (d0 + d1) * 0.5
		if mid_d2 < mid0 or mid_d2 > mid1:
			continue
		candidates.append({"d": mid_d2, "spread": 14.0})
	# 个别：最多 2 个
	var placed: Array[float] = []
	for c in candidates:
		if placed.size() >= 2:
			break
		var d := float(c.get("d", 0.0))
		var ok := true
		for pd in placed:
			if absf(d - pd) < 100.0:
				ok = false
				break
		if not ok:
			continue
		placed.append(d)
		_tide_wells.append(_make_tide_well(d, float(c.get("spread", 16.0))))


func _make_tide_well(distance: float, spread: float = 16.0) -> Dictionary:
	var root := Node3D.new()
	root.name = "NullfeedMark_%.0f" % distance
	track_root.add_child(root)

	# 大紫色叹号（空中 billboard）
	var bang := Label3D.new()
	bang.name = "Bang"
	bang.text = "!"
	bang.font_size = 220
	bang.modulate = Color(0.78, 0.42, 1.0, 1.0)
	bang.outline_size = 28
	bang.outline_modulate = Color(0.18, 0.04, 0.35, 0.95)
	bang.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bang.no_depth_test = true
	bang.position = Vector3(0.0, 0.0, 0.0)
	root.add_child(bang)

	var title := Label3D.new()
	title.name = "NullfeedLabel"
	title.text = "Nullfeed"
	title.font_size = 72
	title.modulate = Color(0.86, 0.62, 1.0, 1.0)
	title.outline_size = 16
	title.outline_modulate = Color(0.12, 0.03, 0.28, 0.92)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.no_depth_test = true
	title.position = Vector3(0.0, -1.15, 0.0)
	root.add_child(title)

	# 淡紫光柱：提示空中位置
	var beam := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.08
	cyl.bottom_radius = 0.35
	cyl.height = 3.2
	cyl.radial_segments = 12
	var bmat := _make_material(Color(0.45, 0.18, 0.85, 0.22), Color(0.7, 0.35, 1.0), 2.2)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cyl.material = bmat
	beam.mesh = cyl
	beam.position = Vector3(0.0, -2.2, 0.0)
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(beam)

	var light := OmniLight3D.new()
	light.light_color = Color(0.72, 0.4, 1.0)
	light.light_energy = 1.6
	light.omni_range = 8.0
	light.shadow_enabled = false
	light.position = Vector3(0.0, 0.2, 0.0)
	root.add_child(light)

	root.visible = false
	var placed := _world_on_path(distance, 0.0, GROUND_Y + 4.6)
	root.global_position = placed["pos"]
	return {
		"distance": distance,
		"spread": spread,
		"node": root,
		"collected": false,
		"shown": false,
	}


func _update_tide_wells(delta: float) -> void:
	if not _pressure_chaser_enabled or _tide_wells.is_empty():
		return
	for well in _tide_wells:
		if bool(well.get("collected", false)):
			continue
		var node := well.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var d := float(well.get("distance", 0.0))
		var placed := _world_on_path(d, 0.0, GROUND_Y + 4.6)
		node.global_position = placed["pos"]
		# 接近分叉就显示（两路中间空中）
		var approach := track_distance > d - 48.0 and track_distance < d + 10.0
		var show := approach and gameplay_active and not is_intro and not is_failed
		well["shown"] = show
		node.visible = show
		if show:
			var bob := 1.0 + sin(elapsed * 3.2) * 0.05
			node.scale = Vector3.ONE * bob
			var bang := node.get_node_or_null("Bang") as Label3D
			if bang != null:
				bang.modulate.a = lerpf(0.75, 1.0, 0.5 + 0.5 * sin(elapsed * 5.0))
		if not show:
			continue
		# 左右岔都会经过中线空中标记：大横向容差
		var along := absf(track_distance - d)
		var lat := absf(current_lateral)
		var half_spread := float(well.get("spread", 16.0)) * 0.55
		if along <= 3.5 and lat <= maxf(half_spread, 5.5):
			_collect_tide_well(well)


func _collect_tide_well(well: Dictionary) -> void:
	if bool(well.get("collected", false)):
		return
	well["collected"] = true
	var node := well.get("node") as Node3D
	if node != null and is_instance_valid(node):
		node.visible = false
	if _energy_chaser == null:
		return
	var before := _energy_chaser.get_visual_gap()
	var after := _energy_chaser.shrink_visual_gap(TIDE_WELL_GAP_SHRINK)
	chaser_distance = after
	camera_shake = maxf(camera_shake, 0.28)
	_show_gate_toast("Nullfeed · Nulltide closes in %0.0f→%0.0f m" % [before, after])
	if strike_toast_label:
		strike_toast_label.modulate = Color(0.85, 0.45, 1.0, 1.0)
		strike_toast_timer = 2.4


func _ease_out_cubic(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)


func _try_show_overweight_intro_tip() -> void:
	if not _overweight_intro_pending:
		return
	_overweight_intro_pending = false
	if not gameplay_active or is_failed or is_finished or is_intro:
		return
	if not _is_overweight_cargo():
		return
	if _overweight_run_tip_shown:
		return
	_overweight_run_tip_shown = true
	# 新 key：避免旧存档已标记 overweight_jump 导致第二关完全不弹
	if Global.should_show_runner_tutorial("overweight_jump_v2") \
			or Global.should_show_runner_tutorial("overweight_jump"):
		_show_coach_tip("overweight_jump", track_distance + 80.0)
	else:
		_show_gate_toast("建设包：单击短跳 · 快速双击满跳")

func _show_chaser_intro() -> void:
	if not _chaser_enabled or not gameplay_active or is_failed or is_finished:
		return
	if _pressure_chaser_enabled:
		if _energy_chaser != null and not _energy_chaser.is_active:
			var start_p := float(mission.get("chaser_initial_pressure", 18.0))
			_energy_chaser.start_chase(start_p)
		_show_gate_toast("Nulltide on your trail · pads ease the pressure")
		strike_toast_label.modulate = Color(0.78, 0.62, 1.0, 1.0)
		strike_toast_timer = 2.8
		return
	var intro_dist := CHASER_RELAY_INTRO_START if _is_relay_mission() else CHASER_INTRO_START
	_show_gate_toast("%s on your trail · stay %0.0f m ahead" % [LevelConfig.CHASER_NAME, intro_dist])
	strike_toast_label.modulate = Color(0.78, 0.62, 1.0, 1.0)
	strike_toast_timer = 2.6


func _sync_chaser_from_track() -> void:
	if not chaser:
		return
	var intro_show := is_intro and _chaser_enabled and _world_ready and not is_finished
	var run_show := _chaser_enabled and gameplay_active and not is_finished and not is_failed
	var capture_show := _capture_cinematic_active
	if not (intro_show or run_show or capture_show):
		chaser.visible = false
		if _chaser_trail:
			_chaser_trail.emitting = false
		return
	var chase_dist := maxf(chaser_distance, 1.2)
	if intro_show and _pressure_chaser_enabled:
		# 反打时略拉近潮体，保证入画可读
		chase_dist = lerpf(CHASER_REAR_PREVIEW_GAP, 8.2, _chaser_intro_look)
		if _energy_chaser != null:
			_energy_chaser.preview_gap = chase_dist
			_energy_chaser.preview_boost = lerpf(0.75, 1.0, _chaser_intro_look)
	elif capture_show:
		chase_dist = lerpf(chase_dist, 0.8, clampf(_capture_cinematic_t / CAPTURE_CINEMATIC_TIME, 0.0, 1.0))
	var back_d := track_distance - chase_dist
	var sample := _sample_path(back_d)
	var base_y := float((sample.get("pos") as Vector3).y) if sample.has("pos") else GROUND_Y
	var placed := _world_on_path(back_d, CHASER_LATERAL_OFFSET, base_y + CHASER_FLOAT_HEIGHT)
	var player_ahead := _world_on_path(track_distance + 2.0, current_lateral, player.position.y if player else base_y)
	var to_player: Vector3 = (player_ahead["pos"] as Vector3) - (placed["pos"] as Vector3)
	to_player.y = 0.0
	var face_yaw := 0.0
	if to_player.length_squared() > 0.04:
		face_yaw = atan2(to_player.x, to_player.z)
	if _pressure_chaser_enabled and _energy_chaser != null:
		# 自然追击：只设锚点，由 Wraith 指数平滑 + 悬浮/下摆完成动态
		_energy_chaser.set_chase_target(placed["pos"] as Vector3, face_yaw)
		chaser.scale = Vector3.ONE
		chaser.visible = true
		return
	chaser.global_position = placed["pos"]
	chaser.rotation = Vector3(deg_to_rad(4.0), face_yaw, 0.0)
	var danger := 1.0 - clampf(chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var vis_scale := lerpf(0.52, CHASER_VISUAL_SCALE, 0.35 + danger * 0.65)
	chaser.scale = Vector3.ONE * vis_scale
	chaser.visible = true
	if _chaser_trail:
		_chaser_trail.emitting = true
		_chaser_trail.amount_ratio = clampf(0.22 + danger * 0.55, 0.18, 0.78)

func _start_slide() -> void:
	slide_timer = SLIDE_TIME
	_slide_elapsed = 0.0
	_slide_hold_wanted = _is_slide_input_held()
	# 滑铲期间锁定在当前横向位置，避免换道 lerp 悄悄进行
	lane_index = _nearest_lane_index(current_lateral)
	target_lane_x = current_lateral
	player_body.scale = Vector3.ONE
	player_body.position.y = 0.0
	vertical_velocity = minf(vertical_velocity, 0.0)
	body_squash_timer = maxf(body_squash_timer, 0.14)
	_emit_landing_particles()
	if _uses_skeletal_run():
		if player_pose_root:
			player_pose_root.visible = false
		if player_slide_pose_root:
			player_slide_pose_root.visible = true
			_fit_slide_pose_to_runner(player_slide_pose_root)
		if player_animation_player:
			player_animation_player.stop()
	else:
		if player_pose_root:
			player_pose_root.visible = false
		if player_slide_pose_root:
			player_slide_pose_root.visible = true
			_fit_slide_pose_to_runner(player_slide_pose_root)
	camera_shake = maxf(camera_shake, 0.06)

func _end_slide() -> void:
	slide_timer = 0.0
	_slide_elapsed = 0.0
	_slide_hold_wanted = false
	player_body.scale = Vector3.ONE
	player_body.position.y = 0.0
	if player_slide_pose_root:
		player_slide_pose_root.visible = false
	if player_pose_root:
		player_pose_root.visible = true
		if _uses_skeletal_run():
			player_pose_root.position = Vector3.ZERO
			_restore_player_pose_facing()
			if player_animation_player:
				_play_player_animation("run", true)

func _is_sliding() -> bool:
	return slide_timer > 0.0


func _is_slide_input_held() -> bool:
	if Input.is_action_pressed("move_backward"):
		return true
	return _slide_hold_wanted


func _request_slide_release() -> void:
	_slide_hold_wanted = false
	if not _is_sliding():
		return
	if _slide_elapsed < SLIDE_MIN_COMMIT:
		return
	# 松手：尽快收尾，方便立刻接跳跃
	slide_timer = minf(slide_timer, SLIDE_RELEASE_FADE)


func _update_slide_timer(delta: float) -> void:
	if slide_timer <= 0.0:
		return
	_slide_elapsed += delta
	var holding := _is_slide_input_held()
	if holding:
		_slide_hold_wanted = true
		if _slide_elapsed < SLIDE_HOLD_MAX:
			# 按住时维持滑铲，直到上限
			slide_timer = maxf(slide_timer, 0.12)
		else:
			_end_slide()
			return
	# 未按住：按剩余计时自然结束；松手提前收尾由 _request_slide_release 处理
	slide_timer = maxf(slide_timer - delta, 0.0)
	if slide_timer == 0.0:
		_end_slide()


func _hits_obstacle(obstacle: Dictionary) -> bool:
	var obstacle_type := String(obstacle["type"])
	var on_wall_obs := _is_wall_running() and int(obstacle.get("layer", 0)) == WALL_RUN_LAYER
	match obstacle_type:
		"slide", "high_bar", "wave_arc_slide":
			# 侧墙：滑铲动作 = 切到最低列；也可跳过横杆
			if on_wall_obs:
				return not (lane_index <= 0 or _player_clears_obstacle(obstacle))
			var open_bottom := float(obstacle.get("open_bottom", SLIDE_GATE_OPEN_BOTTOM))
			if obstacle_type == "wave_arc_slide":
				open_bottom = float(obstacle.get("open_bottom", WAVE_ARC_OPEN_BOTTOM))
			var is_low_bar := open_bottom <= LOW_SLIDE_OPEN_BOTTOM + 0.06 or obstacle_type == "wave_arc_slide"
			# 滑铲门：必须贴地滑铲；跳跃/抬高均无效
			if not _is_sliding():
				return true
			if is_low_bar:
				var beam_bottom := GROUND_Y + open_bottom + 0.05
				var head_y := player.position.y + 0.34
				if head_y > beam_bottom - 0.06:
					return true
			if player.position.y > GROUND_Y + (0.24 if is_low_bar else 0.32) or vertical_velocity > (0.45 if is_low_bar else 0.65):
				return true
			return false
		"energy_ring":
			var lane_x := float(obstacle.get("lane", 0)) * LANE_WIDTH
			var outer := float(obstacle.get("ring_outer_half", ENERGY_RING_OUTER_HALF))
			if absf(current_lateral - lane_x) > outer + 0.18:
				return false
			var center_y := float(obstacle.get("ring_center_y", GROUND_Y + ENERGY_RING_CENTER_Y))
			var inner_vert := float(obstacle.get("ring_inner_half_y", ENERGY_RING_INNER_HALF_Y))
			var body_y := player.position.y + 0.52
			# 贴地跑过 / 跳高不够：一律撞环
			if _is_on_ground() or player.position.y <= GROUND_Y + 0.22:
				return true
			if body_y < center_y - inner_vert * 0.45:
				return true
			if _player_passes_energy_ring_hole(obstacle):
				return false
			return true
		"jump", "low_barrier", "orb":
			if on_wall_obs and obstacle_type != "orb":
				# 侧墙低栏：低列从下方钻过，中列须跳，高列可直接过
				var under_y := float(WALL_LANE_HEIGHTS[1]) - 0.55
				if player.position.y <= under_y:
					return false
				return not _player_clears_obstacle(obstacle)
			return not _player_clears_obstacle(obstacle)
		"meteorite":
			# 占道陨石：换道躲开，或高跳越过；高空待命/下落中不结算碰撞
			if bool(obstacle.get("fall_roll", false)) and String(obstacle.get("meteor_state", "sky")) == "sky":
				return false
			var meteor_y := float(obstacle.get("meteor_air_y", obstacle.get("y_offset", 0.0)))
			if meteor_y > 1.15:
				return false
			return not _player_clears_obstacle(obstacle)
		"train", "train_moving":
			var train_node := obstacle.get("node") as Node3D
			if train_node != null and bool(train_node.get_meta("has_wave_blade", false)):
				# 光波抬起可跑过；落下时碰上即撞碎/受伤，只有跳过门顶才算躲过
				if not _slide_blade_is_blocking(obstacle):
					return false
				var clear_y := float(obstacle.get("blade_top", TRAIN_GATE_TOP)) - 0.55
				return player.position.y < clear_y
			if bool(obstacle.get("prop_slide", false)) and _is_sliding():
				return false
			return not _player_clears_obstacle(obstacle)
		"meteorite_gate":
			return false
		"main_block":
			# 熔岩平台穿越：靠坑洞坠落判定，不用 main_block 碰撞带
			if _main_block_obstacle_uses_platform(obstacle):
				return false
			return true
		"block_left", "block_right":
			# 横向已过滤，进窗口即撞
			return true
		"ramp", "turn_left", "turn_right":
			return false
	return not _player_clears_obstacle(obstacle)

func _player_passes_energy_ring_hole(obstacle: Dictionary) -> bool:
	if player == null:
		return false
	var lane_x := float(obstacle.get("lane", 0)) * LANE_WIDTH
	var inner_lat := float(obstacle.get("ring_inner_half", ENERGY_RING_INNER_HALF))
	var center_y := float(obstacle.get("ring_center_y", GROUND_Y + ENERGY_RING_CENTER_Y))
	var inner_vert := float(obstacle.get("ring_inner_half_y", ENERGY_RING_INNER_HALF_Y))
	var body_y := player.position.y + 0.52
	if absf(current_lateral - lane_x) > inner_lat:
		return false
	if _is_on_ground() or vertical_velocity <= 0.08:
		return false
	if body_y < center_y - inner_vert * 0.35 or body_y > center_y + inner_vert * 0.92:
		return false
	return player.position.y > GROUND_Y + 0.32

func _player_clears_obstacle(obstacle: Dictionary) -> bool:
	# clear_height 为绝对世界 Y；略放宽，减少“脚擦到也算撞”
	var clear_y := float(obstacle.get("clear_height", 1.28)) - 0.06
	return player.position.y >= clear_y

func _player_under_slide_gate(obstacle: Dictionary) -> bool:
	# 头顶低于横梁底即可从门洞通过（站立跑 / 轻跳穿过开口）
	if player == null:
		return false
	var open_bottom := float(obstacle.get("open_bottom", SLIDE_GATE_OPEN_BOTTOM))
	var beam_bottom_y := _layer_height(int(obstacle.get("layer", 0))) + open_bottom + 0.06
	var body_top := player.position.y + (0.38 if _is_sliding() else SLIDE_STAND_BODY_TOP)
	return body_top <= beam_bottom_y

func _slide_blade_phase(obstacle: Dictionary) -> float:
	var dist := float(obstacle.get("distance", 0.0))
	return fmod(elapsed + dist * 0.17, SLIDE_GATE_BLADE_PERIOD) / SLIDE_GATE_BLADE_PERIOD


func _train_gate_blocks_player(obstacle: Dictionary) -> bool:
	if not _slide_blade_is_blocking(obstacle):
		return false
	var clear_y := float(obstacle.get("blade_top", TRAIN_GATE_TOP)) - 0.55
	return player == null or player.position.y < clear_y


func _slide_blade_is_blocking(obstacle: Dictionary) -> bool:
	# 0~0.38 刀在上（可过）；0.38~0.82 下落挡路；其后回收
	var t := _slide_blade_phase(obstacle)
	return t >= 0.38 and t <= 0.82

func _slide_blade_local_y(obstacle: Dictionary) -> float:
	var t := _slide_blade_phase(obstacle)
	var top_y := float(obstacle.get("blade_top", TRAIN_GATE_TOP)) - 0.2
	var bot_y := 0.55
	if t < 0.38:
		return top_y
	if t > 0.90:
		return top_y
	if t <= 0.82:
		var u := clampf((t - 0.38) / 0.44, 0.0, 1.0)
		u = u * u * (3.0 - 2.0 * u)
		return lerpf(top_y, bot_y, u)
	var r := clampf((t - 0.82) / 0.08, 0.0, 1.0)
	return lerpf(bot_y, top_y, r)

func _player_clears_low_obstacle(obstacle: Dictionary) -> bool:
	return _player_clears_obstacle(obstacle)

func _load_panorama_texture(path: String) -> Texture2D:
	if path.strip_edges() == "":
		return null
	if _is_relay_mission():
		return _load_panorama_texture_raw(path)
	var imported: Variant = load(path)
	if imported is Texture2D:
		return imported as Texture2D
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img != null and not img.is_empty():
		push_warning("Panorama import missing, loaded raw image: %s" % path)
		return ImageTexture.create_from_image(img)
	push_error("Failed to load panorama: %s" % path)
	return null


func _load_panorama_texture_raw(path: String) -> Texture2D:
	var res_path := path.strip_edges()
	if res_path == "":
		return null
	var imported: Variant = load(res_path)
	if imported is Texture2D:
		return imported as Texture2D
	var global_path := ProjectSettings.globalize_path(res_path)
	var img := Image.load_from_file(global_path)
	if img != null and not img.is_empty():
		if img.is_compressed():
			img.decompress()
		return ImageTexture.create_from_image(img)
	push_error("Failed to load relay panorama: %s" % res_path)
	return null

func _load_planet_assets() -> void:
	var assets: Dictionary = LevelConfig.get_assets()
	var mission_pano := String(mission.get("panorama", "")).strip_edges()
	var default_pano := String(assets.get("panorama", "res://assets/maps/route_levels/models/backgrounds/panoramas/triptych.png")).strip_edges()
	if _mission_id_str() == "mission_reservoir_02":
		# 水源第二关：第一关云层全景，色调偏粉紫
		_world_panorama = RESERVOIR_W2_PINK_SKY_PANORAMA
	elif _mission_id_str() == "mission_medical_m2":
		# 医疗第二关：第一关云层 + 暮色光感，不用假极光帘
		_world_panorama = MEDICAL_M2_DUSK_SKY_PANORAMA
	elif _uses_medical_sunrise_sky():
		# 医疗：直接用水源第一关已验证全景，不再走单独导入的医疗图
		_world_panorama = RESERVOIR_W1_SKY_PANORAMA
	elif _is_relay_mission():
		if mission_pano != "":
			_world_panorama = _load_panorama_texture(mission_pano)
		else:
			_world_panorama = RELAY_E1_SKY_PANORAMA
	elif mission_pano != "":
		_world_panorama = _load_panorama_texture(mission_pano)
		if _world_panorama == null and default_pano != "":
			push_warning("Mission panorama failed, fallback: %s" % default_pano)
			_world_panorama = _load_panorama_texture(default_pano)
	else:
		_world_panorama = _load_panorama_texture(default_pano)
	_jump_obstacle_paths.clear()
	var jump_src: Array = mission.get("jump_obstacles", assets.get("jump_obstacles", []))
	for path in jump_src:
		_jump_obstacle_paths.append(String(path))
	_ensure_energy_orb_assets_loaded()
	_purge_energy_orb_scene_cache()
	_slide_obstacle_paths.clear()
	var slide_src: Array = mission.get("slide_obstacles", assets.get("slide_obstacles", []))
	for path in slide_src:
		_slide_obstacle_paths.append(String(path))
	if _slide_obstacle_paths.is_empty() and assets.has("slide_obstacle"):
		_slide_obstacle_paths.append(String(assets.get("slide_obstacle")))
	if _is_reservoir_location():
		_slide_obstacle_paths.clear()
		_slide_obstacle_paths.append(RESERVOIR_SLIDE_BILLBOARD)
	_side_prop_paths.clear()
	for path in assets.get("side_props", []):
		_side_prop_paths.append(String(path))
	_midground_prop_paths.clear()
	var mid_src: Array = mission.get("midground_props", assets.get("midground_props", []))
	for path in mid_src:
		_midground_prop_paths.append(String(path))
	if _midground_prop_paths.is_empty():
		for path in _side_prop_paths:
			_midground_prop_paths.append(path)
	if _midground_prop_paths.is_empty():
		for path in MIDGROUND_PROP_DEFAULTS:
			_midground_prop_paths.append(path)
	_landmark_prop_paths.clear()
	for path in assets.get("landmark_props", []):
		_landmark_prop_paths.append(String(path))
	if _landmark_prop_paths.is_empty() and assets.has("hearth"):
		_landmark_prop_paths.append(String(assets.get("hearth")))
	_distant_tower_paths.clear()
	var distant_src: Array = mission.get("distant_tower_props", assets.get("distant_tower_props", assets.get("distant_crystal_pillars", [])))
	for path in distant_src:
		_distant_tower_paths.append(String(path))
	_distant_pod_paths.clear()
	for path in assets.get("distant_pod_props", []):
		_distant_pod_paths.append(String(path))
	_distant_spaceship_paths.clear()
	var ship_src: Variant = mission.get("distant_spaceship_props", null)
	if ship_src == null:
		ship_src = assets.get("distant_spaceship_props", assets.get("distant_anchor_props", []))
	if ship_src is Array:
		for path in ship_src:
			_distant_spaceship_paths.append(String(path))
	_distant_hearth_paths.clear()
	var hearth_src: Variant = mission.get("distant_hearth_props", null)
	if hearth_src == null:
		hearth_src = assets.get("distant_hearth_props", [])
	if hearth_src is Array:
		for path in hearth_src:
			_distant_hearth_paths.append(String(path))
	if _distant_hearth_paths.is_empty() and hearth_src == null and assets.has("hearth"):
		_distant_hearth_paths.append(String(assets.get("hearth")))
	_distant_accent_prop_paths.clear()
	var accent_src: Variant = mission.get("distant_accent_props", null)
	if accent_src is Array:
		for path in accent_src:
			_distant_accent_prop_paths.append(String(path))
	_near_runway_prop_paths.clear()
	var near_src: Variant = mission.get("near_runway_props", null)
	if near_src is Array:
		for path in near_src:
			_near_runway_prop_paths.append(String(path))
	_apply_location_distant_props()
	var slide_path := _slide_obstacle_paths[0] if not _slide_obstacle_paths.is_empty() else String(assets.get("slide_obstacle", "res://assets/maps/route_levels/models/obstacles/slide/barrier_01.glb"))
	_slide_obstacle_scene = _load_runner_scene(slide_path, false)
	_hearth_scene_path = LevelConfig.get_location_hearth_model(Global.runner_location_id) if LevelConfig.has_method("get_location_hearth_model") else String(assets.get("hearth", "res://assets/maps/route_levels/models/environment/buildings/dome_habitat_legacy.glb"))
	_player_scene_paths = _resolve_player_scene_paths(assets)
	_apply_environment_pack_v2_mix(mission)

func _default_environment_pack_v2_paths() -> Array[String]:
	var out: Array[String] = []
	for path in ENVIRONMENT_PACK_V2_PATHS:
		if ResourceLoader.exists(path) or FileAccess.file_exists(ProjectSettings.globalize_path(path)):
			out.append(path)
	return out

func _apply_environment_pack_v2_mix(mission: Dictionary) -> void:
	_environment_pack_v2_paths.clear()
	_environment_pack_v2_mix_ratio = 0.0
	var mix_ratio := float(mission.get("environment_pack_v2_mix", ENVIRONMENT_PACK_V2_MIX_RATIO))
	if mix_ratio <= 0.0:
		return
	var pack: Array[String] = []
	var custom: Variant = mission.get("environment_pack_v2", null)
	if custom is Array and not (custom as Array).is_empty():
		for raw in custom:
			var path := String(raw).strip_edges()
			if path != "":
				pack.append(path)
	else:
		pack = _default_environment_pack_v2_paths()
	if pack.is_empty():
		return
	_environment_pack_v2_paths = pack
	_environment_pack_v2_mix_ratio = clampf(mix_ratio, 0.0, 1.0)

func _should_pick_environment_pack_v2(rng: RandomNumberGenerator, scale: float = 1.0) -> bool:
	if _environment_pack_v2_paths.is_empty() or _environment_pack_v2_mix_ratio <= 0.0:
		return false
	var effective := clampf(_environment_pack_v2_mix_ratio * scale, 0.0, 1.0)
	return rng.randf() < effective

func _pick_environment_pack_v2_path(rng: RandomNumberGenerator) -> String:
	if _environment_pack_v2_paths.is_empty():
		return ""
	return _environment_pack_v2_paths[rng.randi() % _environment_pack_v2_paths.size()]

func _apply_location_distant_props() -> void:
	# 远景：按据点批次与任务轮换塔型；危机批次穿插医疗箱/水晶树/无人机等中景 accent
	var loc := String(Global.runner_location_id)
	var mission_id := String(Global.runner_mission_id)
	if loc == "relay":
		return
	var prefer_signal := absi(mission_id.hash()) % 2 == 0
	if loc == "gate" or loc == "medical":
		if prefer_signal:
			_distant_tower_paths = [
				"res://assets/maps/route_levels/models/environment/distant/distant_signal_tower.glb",
				"res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb",
			]
		else:
			_distant_tower_paths = [
				"res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb",
				"res://assets/maps/route_levels/models/environment/distant/distant_signal_tower.glb",
			]
		if _distant_accent_prop_paths.is_empty():
			_distant_accent_prop_paths = [
				OBSTACLE_PROP_MEDICAL_CRATE,
				OBSTACLE_PROP_BROKEN_DRONE,
				"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
				OBSTACLE_PROP_EXCAVATOR,
				"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			]
		var rot_start := absi(mission_id.hash()) % maxi(_distant_accent_prop_paths.size(), 1)
		var rotated: Array[String] = []
		for i in _distant_accent_prop_paths.size():
			rotated.append(_distant_accent_prop_paths[(rot_start + i) % _distant_accent_prop_paths.size()])
		_distant_accent_prop_paths = rotated
	elif loc == "reservoir":
		var kept: Array[String] = []
		for path in _distant_tower_paths:
			var p := String(path)
			if "signal_tower" in p.to_lower():
				continue
			kept.append(p)
		if kept.is_empty():
			kept.append("res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb")
		_distant_tower_paths = kept
		if _distant_accent_prop_paths.is_empty():
			_distant_accent_prop_paths = [
				OBSTACLE_PROP_METEORITE,
				"res://assets/maps/route_levels/models/environment/midground/midground_water_purifier.glb",
				OBSTACLE_PROP_EXCAVATOR,
				"res://assets/maps/route_levels/models/environment/midground/amber_crystal_coral.glb",
			]
		if _distant_spaceship_paths.is_empty():
			_distant_spaceship_paths = [
				"res://assets/maps/route_levels/models/environment/distant/futuristic_spaceship.glb",
				"res://assets/maps/route_levels/models/environment/distant/futuristic_pod.glb",
			]
	elif loc == "dome":
		var kept_dome: Array[String] = []
		for path in _distant_tower_paths:
			var p := String(path)
			if "signal_tower" in p.to_lower():
				continue
			kept_dome.append(p)
		if kept_dome.is_empty():
			kept_dome.append("res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb")
		_distant_tower_paths = kept_dome
	else:
		var kept2: Array[String] = []
		for path in _distant_tower_paths:
			var p := String(path)
			if "signal_tower" in p.to_lower():
				continue
			kept2.append(p)
		if kept2.is_empty():
			kept2.append("res://assets/maps/route_levels/models/environment/distant/fantasy_crystal_tower.glb")
		_distant_tower_paths = kept2
	if LevelConfig.has_method("get_location_hearth_model"):
		var hearth_path := String(LevelConfig.get_location_hearth_model(loc)).strip_edges()
		if hearth_path != "" and ResourceLoader.exists(hearth_path):
			_distant_hearth_paths = [hearth_path]

func _resolve_player_scene_paths(assets: Dictionary) -> Dictionary:
	var character_id := Global.get_selected_character_id()
	var snapshot: Dictionary = Global.get_messenger_snapshot()
	var unlocked: Array = snapshot.get("unlocked_stories", [])
	if not CharacterRoster.is_unlocked(character_id, unlocked):
		character_id = CharacterRoster.CHAR_ELSA
	if LevelConfig.has_method("get_player_assets"):
		var configured: Variant = LevelConfig.get_player_assets(character_id)
		if configured is Dictionary and not configured.is_empty():
			return configured
	var players: Variant = assets.get("players", {})
	if players is Dictionary and players.has(character_id):
		return (players[character_id] as Dictionary).duplicate(true)
	if assets.get("player") is Dictionary:
		return (assets["player"] as Dictionary).duplicate(true)
	return {}

func _player_asset_path(key: String, fallback: String) -> String:
	var path := String(_player_scene_paths.get(key, ""))
	return path if path != "" else fallback

func _player_run_anim_name() -> String:
	return _player_asset_path("run_anim", ANIMATED_PLAYER_RUN_ANIM)

func _player_run_anim_speed_mult() -> float:
	if _player_scene_paths.has("run_anim_speed"):
		return float(_player_scene_paths["run_anim_speed"])
	return 1.0

func _player_surface_texture_path() -> String:
	return _player_asset_path("surface_texture", "")

func _apply_player_surface_textures(model: Node3D) -> void:
	var tex_path := _player_surface_texture_path()
	if tex_path == "" or not ResourceLoader.exists(tex_path):
		return
	var tex := load(tex_path) as Texture2D
	if tex == null:
		return
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = tex
		mat.albedo_color = Color.WHITE
		mat.metallic = 0.0
		mat.roughness = 0.9
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		mesh_instance.material_override = mat

func _ensure_player_mesh_visible(root: Node3D) -> void:
	if root == null:
		return
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		mesh_instance.visible = true
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		var mat := mesh_instance.get_active_material(0)
		if mat is StandardMaterial3D:
			var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
			dup.cull_mode = BaseMaterial3D.CULL_DISABLED
			mesh_instance.material_override = dup

func _uses_skeletal_run() -> bool:
	return _skeletal_run_enabled and player_animation_player != null

func _hide_air_pose_models() -> void:
	for key in ["jump_start", "jump_peak", "landing", "slide"]:
		var model := player_pose_models.get(key) as Node3D
		if model:
			model.visible = false

func _show_air_pose_model(pose_name: String) -> void:
	_hide_air_pose_models()
	var model := player_pose_models.get(pose_name) as Node3D
	if model:
		model.visible = true

func _apply_skeletal_player_pose(pose_name: String) -> void:
	var logical := pose_name
	if pose_name in ["run_left", "run_right"]:
		logical = "run"
	# 跳跃/落地姿势每帧都要刷新可见性，不能因同名 logical 被 early return 卡住
	var same_pose := player_pose_name == logical
	if same_pose and logical not in ["jump_start", "jump_peak", "landing"]:
		return
	player_pose_name = logical

	match logical:
		"slide":
			if player_pose_root:
				player_pose_root.visible = false
				player_pose_root.position.y = 0.0
			if player_slide_pose_root:
				player_slide_pose_root.visible = true
			_hide_air_pose_models()
			if player_animation_player:
				player_animation_player.stop()
		"jump_start", "jump_peak", "landing":
			if player_pose_root:
				player_pose_root.visible = false
				player_pose_root.position.y = 0.0
			if player_slide_pose_root:
				player_slide_pose_root.visible = false
			var air_pose := logical
			if air_pose == "landing" and not player_pose_models.has("landing"):
				air_pose = "jump_start"
			_show_air_pose_model(air_pose)
			if player_animation_player:
				player_animation_player.stop()
		_:
			if player_pose_root:
				player_pose_root.visible = true
			if player_slide_pose_root:
				player_slide_pose_root.visible = false
			_hide_air_pose_models()
			_play_player_animation("idle" if logical == "idle" else "run")

func _player_yaw_degrees(key: String, fallback: float) -> float:
	if _player_scene_paths.has(key):
		return float(_player_scene_paths[key])
	return fallback

func _load_cargo_icon() -> void:
	if cargo_icon == null:
		return
	var icon_path := ""
	if LevelConfig.has_method("get_cargo_icon_path"):
		icon_path = String(LevelConfig.get_cargo_icon_path(mission))
	if icon_path != "" and ResourceLoader.exists(icon_path):
		cargo_icon.texture = load(icon_path) as Texture2D
		cargo_icon.visible = true
	else:
		cargo_icon.visible = false

func _build_world() -> void:
	var theme: Dictionary = LevelConfig.get_theme()
	_road_style_id = _resolve_runner_road_style()
	_background_style_id = Global.get_runner_background_style()
	# 星球关卡优先用主题 surroundings（晶砂荒原=desert_crystal），不受详情页已移除的背景选项影响
	if LevelConfig != null and LevelConfig.has_method("get_theme"):
		var planet_surroundings := String(LevelConfig.get_theme().get("surroundings", "")).strip_edges()
		if planet_surroundings != "":
			_background_style_id = Global.normalize_runner_background_style(planet_surroundings)
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	_configure_runner_sky(environment, theme)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	# 水源一关雾；中继站默认关雾（雨天试验除外）
	environment.fog_enabled = not (_uses_reservoir_sky_dome() or _relay_disables_fog())
	environment.glow_enabled = false
	world.environment = environment
	_world_environment = world
	add_child(world)
	if _background_uses_starfield() and _mission_id_str() not in ["mission_reservoir_02", "mission_reservoir_03", "mission_reservoir_04"] and not _uses_medical_sunrise_sky():
		_build_starfield()

	var sun := DirectionalLight3D.new()
	sun.name = "RunnerSun"
	sun.rotation_degrees = Vector3(-52, 35, 0)
	_configure_runner_sun(sun, theme)
	add_child(sun)

	_build_path_track()
	_build_side_runway_tracks()
	_build_sandstorm_zones()
	for zone in _junction_zones():
		_build_choice_gate(float(zone.get("distance", 0.0)), zone)
		_build_fork_approach_symbols(zone)
	_build_planet_surroundings(theme)
	_build_finish_gate()
	_apply_background_environment()
	_apply_road_style_environment()
	_apply_mission_environment()
	_setup_rain_weather()
	if _world_environment and _world_environment.environment:
		var env := _world_environment.environment
		if _uses_reservoir_sky_dome() or _relay_disables_fog():
			env.fog_enabled = false
			env.fog_aerial_perspective = 0.0
		elif _is_rain_weather():
			env.fog_enabled = true
			env.fog_aerial_perspective = maxf(env.fog_aerial_perspective, 0.08)
		_base_fog_density = env.fog_density
		_base_fog_light_color = env.fog_light_color
		_base_ambient_light_color = env.ambient_light_color
		_base_ambient_light_energy = env.ambient_light_energy
		_base_sky_yaw = env.sky_rotation.y
		_base_sky_pitch = env.sky_rotation.x
		if env.sky != null and env.sky.sky_material is PanoramaSkyMaterial:
			_base_panorama_energy = (env.sky.sky_material as PanoramaSkyMaterial).energy_multiplier
		elif env.sky != null and env.sky.sky_material is ShaderMaterial and _is_relay_mission():
			var sky_energy = (env.sky.sky_material as ShaderMaterial).get_shader_parameter("energy")
			if sky_energy != null:
				_base_panorama_energy = float(sky_energy)
	var sun_node := get_node_or_null("RunnerSun") as DirectionalLight3D
	if sun_node:
		_base_sun_rot = sun_node.rotation_degrees
		_base_sun_energy = sun_node.light_energy
		_base_sun_color = sun_node.light_color

func _background_uses_sky_panorama() -> bool:
	return _background_style_id in ["desert_crystal", "industrial_ruin", "savanna"]

func _background_uses_starfield() -> bool:
	return _background_style_id in ["desert_crystal", "industrial_ruin", "savanna", "starfield"]

func _configure_runner_sky(environment: Environment, theme: Dictionary) -> void:
	if _background_uses_sky_panorama():
		environment.background_mode = Environment.BG_SKY
		environment.background_color = Color(0.08, 0.07, 0.14)
		var sky := Sky.new()
		if _is_relay_mission():
			_configure_relay_panorama_sky(sky)
		elif _reservoir_photo_sky_texture() != null:
			var panorama := PanoramaSkyMaterial.new()
			panorama.panorama = _reservoir_photo_sky_texture()
			panorama.filter = true
			var pan_energy := 1.56
			var mission_env = mission.get("environment", {})
			if typeof(mission_env) == TYPE_DICTIONARY:
				pan_energy = float(mission_env.get("panorama_energy", pan_energy))
			panorama.energy_multiplier = pan_energy
			sky.sky_material = panorama
			# 提高辐照度分辨率，避免云层和高楼剪影被 cubemap 平均成一片灰
			sky.process_mode = Sky.PROCESS_MODE_REALTIME
			sky.radiance_size = Sky.RADIANCE_SIZE_256
		elif _uses_reservoir_sky_gradient():
			var graded := ShaderMaterial.new()
			graded.shader = RESERVOIR_W2_SKY_SHADER
			_apply_reservoir_graded_sky(graded, 0.0)
			sky.sky_material = graded
			sky.process_mode = Sky.PROCESS_MODE_REALTIME
			sky.radiance_size = Sky.RADIANCE_SIZE_256
		elif _world_panorama != null:
			var panorama := PanoramaSkyMaterial.new()
			panorama.panorama = _world_panorama
			panorama.filter = true
			var pan_energy := 1.25
			var mission_env = mission.get("environment", {})
			if typeof(mission_env) == TYPE_DICTIONARY:
				pan_energy = float(mission_env.get("panorama_energy", pan_energy))
			panorama.energy_multiplier = pan_energy
			sky.sky_material = panorama
		else:
			var proc := ProceduralSkyMaterial.new()
			# 程序化回落：上冷下暖，保留地平线层次，避免一整片黄
			proc.sky_top_color = Color(0.40, 0.36, 0.50)
			proc.sky_horizon_color = Color(0.82, 0.58, 0.40)
			proc.ground_bottom_color = Color(0.24, 0.16, 0.10)
			proc.ground_horizon_color = Color(0.62, 0.44, 0.30)
			proc.sun_angle_max = 28.0
			proc.energy_multiplier = 1.18
			sky.sky_material = proc
		environment.sky = sky
		environment.sky_rotation = Vector3.ZERO
	elif _background_style_id == "starfield":
		environment.background_mode = Environment.BG_COLOR
		environment.background_color = Color(0.006, 0.01, 0.022)
	else:
		environment.background_mode = Environment.BG_COLOR
		environment.background_color = Color(0.01, 0.018, 0.032)

func _configure_runner_sun(sun: DirectionalLight3D, theme: Dictionary) -> void:
	sun.shadow_enabled = false
	if _background_style_id in ["void_dark", "starfield"]:
		sun.light_color = Color(0.62, 0.82, 1.0)
		sun.light_energy = 0.55
	elif _is_relay_mission():
		# 近白方向光：靠明暗分面，不把本色染成天空色
		match _mission_id_str():
			"mission_relay_e2":
				sun.light_color = Color(0.94, 0.82, 0.80)
				sun.light_energy = 1.70
			"mission_relay_e3":
				sun.light_color = Color(0.82, 0.92, 0.88)
				sun.light_energy = 1.72
			"mission_relay_e4":
				sun.light_color = Color(0.82, 0.88, 0.98)
				sun.light_energy = 1.74
			_:
				sun.light_color = Color(0.86, 0.84, 0.94)
				sun.light_energy = 1.68
		sun.rotation_degrees = Vector3(-52, 35, 0)
	else:
		sun.light_color = theme.get("sun_color", Color(0.96, 0.82, 0.62))
		sun.light_energy = float(theme.get("sun_energy", 1.85 if _background_style_id == "desert_crystal" else 2.4))
	if _mission_id_str() == "mission_reservoir_02":
		sun.rotation_degrees = Vector3(-48, 28, 0)
		sun.light_color = Color(0.96, 0.72, 0.78)
		sun.light_energy = 1.68
	elif _mission_id_str() == "mission_reservoir_03":
		sun.rotation_degrees = Vector3(-52, 35, 0)
		sun.light_color = Color(0.96, 0.78, 0.52)
		sun.light_energy = 1.82
	elif _mission_id_str() == "mission_reservoir_04":
		sun.rotation_degrees = Vector3(-52, 35, 0)
		sun.light_color = Color(0.96, 0.78, 0.52)
		sun.light_energy = 1.82
	elif _uses_medical_sunrise_sky():
		sun.rotation_degrees = Vector3(-52, 35, 0)
		sun.light_color = theme.get("sun_color", Color(1.0, 0.86, 0.88))
		sun.light_energy = float(theme.get("sun_energy", 1.62))


func _apply_relay_procedural_sky(proc: ProceduralSkyMaterial, phase: float) -> void:
	var mix := 0.5 + 0.5 * sin(phase)
	var top_a := Color(0.02, 0.03, 0.10)
	var top_b := Color(0.05, 0.06, 0.16)
	var horizon_a := Color(0.10, 0.22, 0.48)
	var horizon_b := Color(0.18, 0.16, 0.42)
	match _mission_id_str():
		"mission_relay_e2":
			horizon_a = Color(0.12, 0.36, 0.68)
			horizon_b = Color(0.16, 0.28, 0.58)
		"mission_relay_e3":
			horizon_a = Color(0.42, 0.14, 0.48)
			horizon_b = Color(0.58, 0.18, 0.52)
		"mission_relay_e4":
			horizon_a = Color(0.22, 0.48, 0.78)
			horizon_b = Color(0.36, 0.28, 0.62)
	proc.sky_top_color = top_a.lerp(top_b, mix)
	proc.sky_horizon_color = horizon_a.lerp(horizon_b, 0.5 + 0.5 * sin(phase * 1.41 + 0.6))
	proc.ground_bottom_color = Color(0.03, 0.04, 0.08)
	proc.ground_horizon_color = Color(0.08, 0.10, 0.18)
	proc.sun_angle_max = 10.0
	proc.sun_curve = 0.028
	proc.energy_multiplier = 0.82 + 0.08 * sin(phase * 1.85)


func _relay_sky_source_pano() -> Texture2D:
	if _relay_sky_flat_pano == null:
		var img := Image.create(4, 4, false, Image.FORMAT_RGB8)
		img.fill(Color(0.02, 0.03, 0.08))
		_relay_sky_flat_pano = ImageTexture.create_from_image(img)
	return _relay_sky_flat_pano


func _relay_panorama_energy(default_energy: float = 1.06) -> float:
	var mission_env = mission.get("environment", {})
	if typeof(mission_env) == TYPE_DICTIONARY:
		return float(mission_env.get("panorama_energy", default_energy))
	return default_energy


func _configure_relay_panorama_sky(sky: Sky) -> void:
	var panorama := PanoramaSkyMaterial.new()
	panorama.panorama = _relay_mission_sky_pano()
	panorama.filter = true
	panorama.energy_multiplier = _relay_panorama_energy()
	sky.sky_material = panorama
	sky.process_mode = Sky.PROCESS_MODE_REALTIME
	# 跟水源一一样用较低辐照度分辨率，避免天空色洗到地面和建筑
	sky.radiance_size = Sky.RADIANCE_SIZE_256


func _relay_mission_sky_pano() -> Texture2D:
	if _world_panorama != null:
		return _world_panorama
	match _mission_id_str():
		"mission_relay_e2":
			return RELAY_E2_SKY_PANORAMA
		"mission_relay_e3":
			return RELAY_E3_SKY_PANORAMA
		"mission_relay_e4":
			return RELAY_E4_SKY_PANORAMA
		_:
			return RELAY_E1_SKY_PANORAMA


func _apply_relay_graded_sky(mat: ShaderMaterial, phase: float) -> void:
	if mat == null or mat.shader == null:
		return
	# 全景图作结构源 + 轻量色调分级 + 薄云层（保留光带/星云，避免压成纯色）
	mat.set_shader_parameter("source_pano", _relay_mission_sky_pano())
	var pulse := 0.5 + 0.5 * sin(phase * 0.38)
	var cloud_speed := 0.009
	var energy := 1.24 + 0.04 * pulse
	var contrast := 1.18
	var sil := 0.48
	var cloud_amount := 0.22
	var source_keep := 0.62
	var zenith := Color(0.05, 0.08, 0.20)
	var mid := Color(0.12, 0.20, 0.38)
	var horizon := Color(0.22, 0.38, 0.62)
	var highlight := Color(0.58, 0.78, 0.98)
	var shadow := Color(0.04, 0.06, 0.12)
	var ground := Color(0.08, 0.09, 0.14)
	var cloud_dark := Color(0.12, 0.20, 0.36)
	var cloud_bright := Color(0.38, 0.62, 0.90)
	match _mission_id_str():
		"mission_relay_e2":
			energy = 1.28 + 0.04 * pulse
			source_keep = 0.60
			cloud_amount = 0.24
			zenith = Color(0.04, 0.08, 0.22)
			mid = Color(0.10, 0.24, 0.44)
			horizon = Color(0.20, 0.42, 0.68)
			highlight = Color(0.42, 0.76, 0.98)
			cloud_dark = Color(0.10, 0.20, 0.36)
			cloud_bright = Color(0.30, 0.60, 0.92)
		"mission_relay_e3":
			energy = 1.26 + 0.04 * pulse
			source_keep = 0.58
			cloud_amount = 0.20
			zenith = Color(0.06, 0.05, 0.18)
			mid = Color(0.18, 0.12, 0.30)
			horizon = Color(0.34, 0.18, 0.42)
			highlight = Color(0.72, 0.42, 0.82)
			cloud_dark = Color(0.14, 0.10, 0.22)
			cloud_bright = Color(0.52, 0.28, 0.62)
		"mission_relay_e4":
			energy = 1.30 + 0.04 * pulse
			source_keep = 0.64
			cloud_amount = 0.18
			zenith = Color(0.04, 0.08, 0.22)
			mid = Color(0.10, 0.20, 0.38)
			horizon = Color(0.22, 0.40, 0.64)
			highlight = Color(0.52, 0.78, 0.98)
			cloud_dark = Color(0.10, 0.16, 0.30)
			cloud_bright = Color(0.34, 0.62, 0.92)
	var mission_env = mission.get("environment", {})
	if typeof(mission_env) == TYPE_DICTIONARY:
		energy = float(mission_env.get("panorama_energy", energy))
	mat.set_shader_parameter("energy", energy)
	mat.set_shader_parameter("contrast", contrast)
	mat.set_shader_parameter("silhouette_strength", sil)
	mat.set_shader_parameter("cloud_amount", cloud_amount)
	mat.set_shader_parameter("cloud_speed", cloud_speed)
	mat.set_shader_parameter("source_keep", source_keep)
	mat.set_shader_parameter("cloud_low", 0.04)
	mat.set_shader_parameter("cloud_high", 0.52)
	mat.set_shader_parameter("paint_sky", 0.0)
	mat.set_shader_parameter("sky_style", 0.0)
	mat.set_shader_parameter("aurora_amount", 0.0)
	mat.set_shader_parameter("cloud_dark_color", cloud_dark)
	mat.set_shader_parameter("cloud_bright_color", cloud_bright)
	mat.set_shader_parameter("zenith_color", zenith)
	mat.set_shader_parameter("mid_color", mid)
	mat.set_shader_parameter("horizon_color", horizon)
	mat.set_shader_parameter("highlight_color", highlight)
	mat.set_shader_parameter("shadow_color", shadow)
	mat.set_shader_parameter("ground_color", ground)


func _relay_sky_grade_colors() -> Dictionary:
	var zenith := Color(0.012, 0.018, 0.048)
	var mid := Color(0.028, 0.048, 0.12)
	var horizon := Color(0.06, 0.14, 0.32)
	var streak := Color(0.18, 0.52, 0.92)
	var spark := Color(0.62, 0.82, 1.0)
	match _mission_id_str():
		"mission_relay_e2":
			zenith = Color(0.014, 0.024, 0.058)
			mid = Color(0.032, 0.072, 0.16)
			horizon = Color(0.08, 0.22, 0.42)
			streak = Color(0.14, 0.58, 0.98)
			spark = Color(0.48, 0.78, 1.0)
		"mission_relay_e3":
			zenith = Color(0.022, 0.010, 0.042)
			mid = Color(0.08, 0.028, 0.12)
			horizon = Color(0.22, 0.10, 0.28)
			streak = Color(0.72, 0.22, 0.78)
			spark = Color(0.92, 0.48, 0.88)
		"mission_relay_e4":
			zenith = Color(0.014, 0.028, 0.062)
			mid = Color(0.04, 0.10, 0.20)
			horizon = Color(0.10, 0.26, 0.46)
			streak = Color(0.28, 0.68, 0.98)
			spark = Color(0.72, 0.90, 1.0)
	return {
		"zenith": zenith,
		"mid": mid,
		"horizon": horizon,
		"streak": streak,
		"spark": spark,
	}


func _relay_sky_pixel(u: float, v: float, src: Color) -> Color:
	var palette := _relay_sky_grade_colors()
	var zenith: Color = palette["zenith"]
	var mid: Color = palette["mid"]
	var horizon: Color = palette["horizon"]
	var streak_col: Color = palette["streak"]
	var spark_col: Color = palette["spark"]
	var grade := zenith
	if v < 0.34:
		grade = zenith.lerp(mid, v / 0.34)
	elif v < 0.52:
		grade = mid.lerp(horizon, (v - 0.34) / 0.18)
	else:
		grade = horizon.lerp(Color(0.04, 0.06, 0.10), clampf((v - 0.52) / 0.48, 0.0, 1.0))
	var neb := _sky_fbm(Vector2(u * 5.2, v * 7.4))
	var neb2 := _sky_fbm(Vector2(u * 11.0 + 2.7, v * 4.2 - 1.1))
	grade = grade.lerp(streak_col, neb * 0.16)
	var band := smoothstep(0.26, 0.38, v) * (1.0 - smoothstep(0.56, 0.70, v))
	var streak := pow(maxf(neb2, neb * 0.72), 1.35)
	grade = grade.lerp(streak_col, streak * band * 0.42)
	var luma := src.r * 0.299 + src.g * 0.587 + src.b * 0.114
	var spark_w := clampf((luma - 0.34) / 0.48, 0.0, 1.0)
	spark_w *= 1.0 - band * 0.72
	var softened := grade.lerp(spark_col, spark_w * 0.38)
	var src_mix := clampf(spark_w * 0.42 + band * 0.18, 0.0, 0.62)
	var out := grade.lerp(softened, 0.58).lerp(src, src_mix * 0.48)
	out = out.lerp(grade, 0.22 + (1.0 - v) * 0.18)
	return Color(
		clampf(out.r, 0.0, 1.0),
		clampf(out.g, 0.0, 1.0),
		clampf(out.b, 0.0, 1.0),
		1.0
	)


func _bake_relay_mission_sky() -> Texture2D:
	var src_tex: Texture2D = _world_panorama
	if src_tex == null:
		return src_tex
	var img := src_tex.get_image()
	if img == null:
		return src_tex
	if img.is_compressed():
		img.decompress()
	img = img.duplicate()
	var w := img.get_width()
	var hgt := img.get_height()
	if w > 1280:
		var nh := maxi(int(round(float(hgt) * 1280.0 / float(w))), 640)
		img.resize(1280, nh, Image.INTERPOLATE_LANCZOS)
		w = img.get_width()
		hgt = img.get_height()
	var y := 0
	while y < hgt:
		var vv := float(y) / float(maxi(hgt - 1, 1))
		var x := 0
		while x < w:
			var uu := float(x) / float(maxi(w - 1, 1))
			var px := img.get_pixel(x, y)
			img.set_pixel(x, y, _relay_sky_pixel(uu, vv, px))
			x += 1
		y += 1
	return ImageTexture.create_from_image(img)


func _relay_night_haze_color() -> Color:
	match _mission_id_str():
		"mission_relay_e2":
			return Color(0.48, 0.18, 0.22)
		"mission_relay_e3":
			return Color(0.14, 0.36, 0.34)
		"mission_relay_e4":
			return Color(0.16, 0.28, 0.50)
	return Color(0.26, 0.28, 0.44)


func _apply_relay_nightscape_look(root: Node3D, depth_tier: int = 1) -> void:
	if not _is_relay_mission() or root == null:
		return
	depth_tier = clampi(depth_tier, 0, 2)
	# 水源一式：关雾染色、保留贴图本色；仅轻微压暗 + 方向光吃到明暗
	var albedo_keep: Array[float] = [0.88, 0.94, 0.98]
	var keep := albedo_keep[depth_tier]
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_i in mesh_instance.mesh.get_surface_count():
			var mat := mesh_instance.get_surface_override_material(surface_i)
			if mat == null:
				mat = mesh_instance.mesh.surface_get_material(surface_i)
			if not mat is StandardMaterial3D:
				continue
			var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
			dup.disable_fog = true
			dup.metallic = minf(dup.metallic, 0.22)
			dup.roughness = clampf(dup.roughness, 0.28, 0.82)
			dup.metallic_specular = 0.45
			dup.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
			dup.clearcoat_enabled = false
			dup.rim_enabled = false
			var base := dup.albedo_color
			dup.albedo_color = Color(base.r * keep, base.g * keep, base.b * keep, base.a)
			mesh_instance.set_surface_override_material(surface_i, dup)


func _sky_hash(x: int, y: int) -> float:
	var n := x * 374761393 + y * 668265263
	n = (n ^ (n >> 13)) * 1274126177
	return float(n & 0x7fffffff) / 2147483647.0


func _sky_noise2(p: Vector2) -> float:
	var ix := int(floorf(p.x))
	var iy := int(floorf(p.y))
	var fx: float = p.x - floorf(p.x)
	var fy: float = p.y - floorf(p.y)
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)
	var a := _sky_hash(ix, iy)
	var b := _sky_hash(ix + 1, iy)
	var c := _sky_hash(ix, iy + 1)
	var d := _sky_hash(ix + 1, iy + 1)
	return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fy)


func _sky_fbm(p: Vector2) -> float:
	var v := 0.0
	var a := 0.5
	v += a * _sky_noise2(p)
	p *= 2.07
	a *= 0.5
	v += a * _sky_noise2(p)
	p *= 2.03
	a *= 0.5
	v += a * _sky_noise2(p)
	p *= 2.11
	a *= 0.5
	v += a * _sky_noise2(p)
	return v


func _bake_reservoir_mission_sky() -> Texture2D:
	var src_tex: Texture2D = _world_panorama if _world_panorama != null else RESERVOIR_W1_SKY_PANORAMA
	if src_tex == null:
		return RESERVOIR_W1_SKY_PANORAMA
	var img := src_tex.get_image()
	if img == null:
		return src_tex
	if img.is_compressed():
		img.decompress()
	img = img.duplicate()
	var w := img.get_width()
	var hgt := img.get_height()
	if w > 1280:
		var nh := maxi(int(round(float(hgt) * 1280.0 / float(w))), 640)
		img.resize(1280, nh, Image.INTERPOLATE_LANCZOS)
		w = img.get_width()
		hgt = img.get_height()
	var night := _mission_id_str() == "mission_reservoir_04"
	var y := 0
	while y < hgt:
		var vv := float(y) / float(maxi(hgt - 1, 1))
		var x := 0
		while x < w:
			var uu := float(x) / float(maxi(w - 1, 1))
			var px := img.get_pixel(x, y)
			var luma := px.r * 0.299 + px.g * 0.587 + px.b * 0.114
			if night:
				img.set_pixel(x, y, _w4_sky_pixel(uu, vv, luma, x, y))
			else:
				img.set_pixel(x, y, _w3_sky_pixel(uu, vv, luma))
			x += 1
		y += 1
	var tex := ImageTexture.create_from_image(img)
	return tex


func _w3_sky_pixel(u: float, v: float, luma: float) -> Color:
	# 镜头约看 v=0.42–0.56：这段必须自己有明暗云，不能指望原图亮度
	var zenith := Color(0.14, 0.28, 0.62)
	var mid := Color(0.42, 0.32, 0.74)
	var air := Color(0.36, 0.52, 0.88)
	var warm := Color(0.90, 0.56, 0.34)
	var ground := Color(0.14, 0.10, 0.10)
	var grade := zenith
	if v < 0.36:
		grade = zenith.lerp(mid, v / 0.36)
	elif v < 0.50:
		grade = mid.lerp(air, (v - 0.36) / 0.14)
	elif v < 0.57:
		grade = air.lerp(warm, (v - 0.50) / 0.07)
	else:
		grade = warm.lerp(ground, clampf((v - 0.57) / 0.43, 0.0, 1.0))
	var n1 := _sky_fbm(Vector2(u * 7.2, v * 11.0))
	var n2 := _sky_fbm(Vector2(u * 14.5 + 3.1, v * 18.0 - 1.4))
	var cover := n1 * 0.62 + n2 * 0.38
	var clouds := smoothstep(0.36, 0.58, cover)
	var lit := smoothstep(0.48, 0.76, n2)
	var band := smoothstep(0.22, 0.38, v) * (1.0 - smoothstep(0.54, 0.68, v))
	var amt := clouds * band
	var col := grade
	col = col.lerp(Color(0.16, 0.14, 0.32), amt * (1.0 - lit) * 0.78)
	col = col.lerp(Color(0.96, 0.90, 0.98), amt * lit * 0.72)
	col = col.lerp(col.lightened(0.12), clampf((luma - 0.2) * 0.35, 0.0, 0.2))
	return col


func _w4_sky_pixel(u: float, v: float, luma: float, x: int, y: int) -> Color:
	# 上暗下亮的清透深蓝，银河加宽加亮，星星按格子画大
	var top := Color(0.02, 0.06, 0.18)
	var mid := Color(0.10, 0.24, 0.48)
	var hz := Color(0.08, 0.16, 0.32)
	var ground := Color(0.04, 0.05, 0.08)
	var grade := top
	if v < 0.38:
		grade = top.lerp(mid, v / 0.38)
	elif v < 0.54:
		grade = mid.lerp(hz, (v - 0.38) / 0.16)
	else:
		grade = hz.lerp(ground, clampf((v - 0.54) / 0.46, 0.0, 1.0))
	var neb := _sky_fbm(Vector2(u * 5.5, v * 8.0))
	grade = grade.lerp(Color(0.18, 0.32, 0.62), neb * 0.28)
	var mw := exp(-pow((v - 0.46) / 0.13, 2.0))
	mw *= 0.30 + 0.70 * pow(0.5 + 0.5 * sin(u * TAU * 0.95 + neb * 2.2), 2.0)
	grade = grade.lerp(Color(0.42, 0.52, 0.88), mw * 0.72)
	grade = grade.lerp(Color(0.36, 0.22, 0.55), mw * neb * 0.35)
	grade = grade.lerp(grade.lightened(0.10), clampf(luma, 0.0, 1.0) * 0.12)
	var cell := 5
	var cx := int(floorf(float(x) / float(cell)))
	var cy := int(floorf(float(y) / float(cell)))
	var hs := _sky_hash(cx, cy)
	if hs > 0.90:
		var fx: float = float(x % cell) - float(cell) * 0.5
		var fy: float = float(y % cell) - float(cell) * 0.5
		var d := sqrt(fx * fx + fy * fy) / (float(cell) * 0.55)
		var spark := clampf(1.0 - d, 0.0, 1.0)
		spark *= spark
		if spark > 0.02:
			grade = grade.lerp(Color(0.88, 0.94, 1.0), spark * (0.55 + 0.45 * hs))
	if _sky_hash(cx + 11, cy + 3) > 0.97:
		var fx2 := float(x % 7) - 3.0
		var fy2 := float(y % 7) - 3.0
		var d2 := sqrt(fx2 * fx2 + fy2 * fy2)
		if d2 < 2.4:
			grade = grade.lerp(Color(0.95, 0.97, 1.0), clampf(1.0 - d2 / 2.4, 0.0, 1.0) * 0.9)
	return grade


func _apply_reservoir_graded_sky(mat: ShaderMaterial, phase: float) -> void:
	if mat == null or mat.shader == null:
		return
	var pano: Texture2D = _world_panorama if _world_panorama != null else RESERVOIR_W1_SKY_PANORAMA
	mat.set_shader_parameter("source_pano", pano)
	var pulse := 0.5 + 0.5 * sin(phase * 0.42)
	var cloud_speed := 0.014
	var energy := 1.14 + 0.10 * pulse
	var contrast := 1.62
	var sil := 1.0
	var zenith := Color(0.08, 0.10, 0.28)
	var mid := Color(0.48, 0.36, 0.68)
	var horizon := Color(0.62, 0.66, 0.92)
	var highlight := Color(0.96, 0.92, 1.0)
	var shadow := Color(0.04, 0.04, 0.10)
	var ground := Color(0.16, 0.12, 0.14)
	var cloud_amount := 0.70
	var aurora_amt := 0.0
	var aurora := Color(0.38, 0.86, 1.0)
	var source_keep := 0.0
	var cloud_low := 0.02
	var cloud_high := 0.48
	match _mission_id_str():
		"mission_reservoir_03":
			cloud_speed = 0.012
			energy = 1.08 + 0.06 * pulse
			contrast = 1.35
			sil = 0.35
			cloud_amount = 0.70
			source_keep = 0.0
			aurora_amt = 0.0
			zenith = Color(0.16, 0.32, 0.68)
			mid = Color(0.42, 0.34, 0.74)
			horizon = Color(0.82, 0.52, 0.38)
			highlight = Color(0.92, 0.88, 0.96)
			shadow = Color(0.08, 0.10, 0.22)
			ground = Color(0.16, 0.12, 0.14)
		"mission_reservoir_04":
			cloud_speed = 0.010
			energy = 0.98 + 0.04 * pulse
			contrast = 1.20
			sil = 0.20
			cloud_amount = 0.0
			source_keep = 0.0
			aurora_amt = 0.0
			zenith = Color(0.04, 0.10, 0.26)
			mid = Color(0.08, 0.18, 0.38)
			horizon = Color(0.12, 0.20, 0.34)
			highlight = Color(0.62, 0.74, 0.95)
			shadow = Color(0.02, 0.04, 0.10)
			ground = Color(0.06, 0.06, 0.10)
	mat.set_shader_parameter("energy", energy)
	mat.set_shader_parameter("contrast", contrast)
	mat.set_shader_parameter("silhouette_strength", sil)
	mat.set_shader_parameter("cloud_amount", cloud_amount)
	mat.set_shader_parameter("cloud_speed", cloud_speed)
	mat.set_shader_parameter("source_keep", source_keep)
	mat.set_shader_parameter("cloud_low", cloud_low)
	mat.set_shader_parameter("cloud_high", cloud_high)
	mat.set_shader_parameter("paint_sky", 0.0)
	var style := 0.0
	match _mission_id_str():
		"mission_reservoir_03":
			style = 1.0
		"mission_reservoir_04":
			style = 2.0
	mat.set_shader_parameter("sky_style", style)
	if _mission_id_str() == "mission_reservoir_04":
		mat.set_shader_parameter("cloud_dark_color", Color(0.22, 0.08, 0.18))
		mat.set_shader_parameter("cloud_bright_color", Color(1.0, 0.76, 0.84))
	else:
		mat.set_shader_parameter("cloud_dark_color", Color(0.20, 0.34, 0.58))
		mat.set_shader_parameter("cloud_bright_color", Color(0.90, 0.94, 1.0))
	mat.set_shader_parameter("aurora_amount", aurora_amt)
	mat.set_shader_parameter("aurora_color", aurora)
	mat.set_shader_parameter("zenith_color", zenith)
	mat.set_shader_parameter("mid_color", mid)
	mat.set_shader_parameter("horizon_color", horizon)
	mat.set_shader_parameter("highlight_color", highlight)
	mat.set_shader_parameter("shadow_color", shadow)
	mat.set_shader_parameter("ground_color", ground)


func _apply_reservoir_w2_sky(mat: ShaderMaterial, phase: float) -> void:
	_apply_reservoir_graded_sky(mat, phase)


func _apply_medical_sunrise_sky(mat: ShaderMaterial, _phase: float) -> void:
	if mat == null or mat.shader == null:
		return
	mat.set_shader_parameter("source_pano", MEDICAL_SUNRISE_SKY_PANORAMA)
	var energy := 1.18
	var mission_env = mission.get("environment", {})
	if typeof(mission_env) == TYPE_DICTIONARY:
		energy = float(mission_env.get("panorama_energy", energy))
	mat.set_shader_parameter("energy", energy)


func _apply_reservoir_procedural_sky(proc: ProceduralSkyMaterial, phase: float) -> void:
	var pulse := 0.5 + 0.5 * sin(phase * 0.62)
	var top := Color(0.52, 0.48, 0.72)
	var horizon := Color(0.78, 0.62, 0.74)
	var ground_h := Color(0.46, 0.34, 0.28)
	var ground_b := Color(0.22, 0.16, 0.14)
	match _mission_id_str():
		"mission_reservoir_02":
			top = Color(0.46, 0.54, 0.86).lerp(Color(0.62, 0.46, 0.82), pulse * 0.55)
			horizon = Color(0.84, 0.66, 0.82).lerp(Color(0.58, 0.72, 0.90), pulse * 0.50)
			ground_h = Color(0.56, 0.40, 0.46)
			ground_b = Color(0.24, 0.16, 0.18)
		"mission_reservoir_03":
			top = Color(0.78, 0.62, 0.78).lerp(Color(0.86, 0.70, 0.62), pulse * 0.48)
			horizon = Color(0.94, 0.72, 0.52).lerp(Color(0.90, 0.64, 0.70), pulse * 0.40)
			ground_h = Color(0.62, 0.42, 0.32)
			ground_b = Color(0.28, 0.18, 0.14)
		"mission_reservoir_04":
			top = Color(0.34, 0.28, 0.48)
			horizon = Color(0.62, 0.36, 0.50)
			ground_h = Color(0.36, 0.20, 0.22)
			ground_b = Color(0.16, 0.10, 0.12)
	proc.sky_top_color = top
	proc.sky_horizon_color = horizon
	proc.ground_bottom_color = ground_b
	proc.ground_horizon_color = ground_h
	proc.sun_angle_max = 22.0 if _mission_id_str() in ["mission_reservoir_02", "mission_reservoir_03"] else 26.0
	proc.sun_curve = 0.14 if _mission_id_str() in ["mission_reservoir_02", "mission_reservoir_03"] else 0.08
	if _mission_id_str() == "mission_reservoir_04":
		proc.energy_multiplier = 0.92
	elif _mission_id_str() == "mission_reservoir_02":
		proc.energy_multiplier = 0.94 + 0.16 * pulse
	elif _mission_id_str() == "mission_reservoir_03":
		proc.energy_multiplier = 0.98 + 0.10 * pulse
	else:
		proc.energy_multiplier = 1.12

func _apply_background_environment() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	var theme: Dictionary = LevelConfig.get_theme()
	match _background_style_id:
		"void_dark":
			env.ambient_light_color = Color(0.14, 0.22, 0.32)
			env.ambient_light_energy = 0.95
			env.fog_light_color = Color(0.08, 0.14, 0.22)
			env.fog_density = 0.0012
			env.fog_aerial_perspective = 0.38
			env.glow_enabled = false
			env.tonemap_exposure = 1.08
			_boost_runner_lights(Color(0.62, 0.82, 1.0), 0.55, 0.95)
		"starfield":
			env.ambient_light_color = Color(0.12, 0.18, 0.28)
			env.ambient_light_energy = 0.82
			env.fog_light_color = Color(0.06, 0.1, 0.18)
			env.fog_density = 0.0008
			env.fog_aerial_perspective = 0.32
			env.glow_enabled = true
			env.glow_intensity = 0.35
			env.glow_strength = 0.9
			env.glow_bloom = 0.18
			env.tonemap_exposure = 1.1
			_boost_runner_lights(Color(0.58, 0.78, 1.0), 0.48, 0.85)
		"industrial_ruin":
			env.ambient_light_color = Color(0.72, 0.68, 0.62)
			env.ambient_light_energy = 1.15
			env.fog_light_color = Color(0.55, 0.48, 0.38)
			env.fog_density = 0.0024
			env.fog_aerial_perspective = 0.5
			env.glow_enabled = false
			env.tonemap_exposure = 1.0
			_boost_runner_lights(Color(0.92, 0.78, 0.55), 2.1, 0.58)
		"savanna":
			env.ambient_light_color = Color(0.94, 0.78, 0.48)
			env.ambient_light_energy = 1.38
			env.fog_light_color = Color(0.86, 0.62, 0.32)
			env.fog_density = 0.0028
			env.fog_aerial_perspective = 0.58
			env.glow_enabled = false
			env.tonemap_exposure = 1.02
			_boost_runner_lights(Color(1.0, 0.82, 0.52), 2.5, 0.6)
		"desert_crystal":
			if _is_relay_mission():
				if _is_rain_weather():
					# 轻微湿冷压暗；几乎不染绿，避免角色/障碍发绿
					env.ambient_light_color = Color(0.42, 0.44, 0.46)
					env.ambient_light_energy = 0.64
					env.fog_enabled = true
					env.fog_light_color = Color(0.30, 0.33, 0.36)
					env.fog_density = 0.00072
					env.fog_aerial_perspective = 0.07
					env.glow_enabled = false
					env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
					env.tonemap_exposure = 0.98
					_boost_runner_lights(Color(0.80, 0.82, 0.86), 1.05, 0.42)
				else:
					# 对齐水源一：中性环境光 + 关雾染色 + 强方向光吃明暗
					env.ambient_light_color = Color(0.48, 0.46, 0.54)
					env.ambient_light_energy = 0.72
					env.fog_enabled = false
					env.fog_light_color = Color(0.32, 0.30, 0.40)
					env.fog_density = 0.00028
					env.fog_aerial_perspective = 0.0
					env.glow_enabled = false
					env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
					env.tonemap_exposure = 1.06
					_boost_runner_lights(Color(0.88, 0.86, 0.94), 1.68, 0.52)
			else:
				# 晶砂荒原：琥珀夕照 + 紫灰薄雾，避免纯黄洗屏
				env.ambient_light_color = Color(0.48, 0.44, 0.56)
				env.ambient_light_energy = 0.74
				env.fog_light_color = Color(0.38, 0.32, 0.42)
				env.fog_density = 0.00038
				env.fog_aerial_perspective = 0.07
				env.glow_enabled = false
				env.tonemap_exposure = 0.98
				_boost_runner_lights(Color(0.94, 0.78, 0.58), 1.75, 0.42)
				if _is_dome_h1_mission():
					env.ambient_light_color = Color(0.26, 0.22, 0.32)
					env.ambient_light_energy = 0.44
					env.fog_light_color = Color(0.18, 0.14, 0.28)
					env.fog_density = 0.00068
					env.fog_aerial_perspective = 0.14
					env.tonemap_exposure = 0.88
					_boost_runner_lights(Color(0.78, 0.52, 0.34), 1.05, 0.28)
		_:
			env.ambient_light_color = theme.get("ambient", Color(0.92, 0.68, 0.44))
			env.ambient_light_energy = float(theme.get("ambient_energy", 1.35))
			env.fog_light_color = theme.get("fog_color", Color(0.82, 0.48, 0.2))
			env.fog_density = float(theme.get("fog_density", 0.0022))
			env.fog_aerial_perspective = 0.55
			env.glow_enabled = false
			env.tonemap_exposure = 1.0
			_boost_runner_lights(
				theme.get("sun_color", Color(1.0, 0.82, 0.55)),
				float(theme.get("sun_energy", 2.4)),
				0.55
			)
	_apply_mission_environment_overrides(env)

func _apply_mission_environment_overrides(env: Environment) -> void:
	var raw = mission.get("environment", {})
	if typeof(raw) != TYPE_DICTIONARY:
		return
	var overrides: Dictionary = raw
	if overrides.has("fog_color"):
		env.fog_light_color = overrides["fog_color"]
	if overrides.has("fog_density"):
		env.fog_density = float(overrides["fog_density"])
	if overrides.has("fog_aerial_perspective"):
		env.fog_aerial_perspective = float(overrides["fog_aerial_perspective"])
	if overrides.has("fog_enabled"):
		env.fog_enabled = bool(overrides["fog_enabled"])
	if overrides.has("ambient"):
		env.ambient_light_color = overrides["ambient"]
	if overrides.has("ambient_energy"):
		env.ambient_light_energy = float(overrides["ambient_energy"])
	if overrides.has("tonemap_exposure"):
		env.tonemap_exposure = float(overrides["tonemap_exposure"])

func _mission_uses_textured_ground() -> bool:
	return bool(mission.get("textured_ground", false))

func _mission_sky_accents_config() -> Dictionary:
	var raw: Variant = mission.get("sky_accents", false)
	if raw is Dictionary:
		return raw
	if raw == true:
		return {
			"energy_gates": true,
		}
	return {}

func _mission_has_sky_accents() -> bool:
	return not _mission_sky_accents_config().is_empty()

func _mission_sky_distant_density() -> float:
	return maxf(1.0, float(_mission_sky_accents_config().get("distant_density", 1.0)))

func _make_desert_surroundings_material() -> Material:
	var tex_path := String(mission.get("ground_texture", "")).strip_edges()
	if tex_path == "":
		tex_path = "res://assets/maps/route_levels/runner_60s/backgrounds/textures/glass_desert_w1_ground_albedo.jpg"
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/maps/route_levels/runner_60s/desert_surroundings.gdshader")
	if ResourceLoader.exists(tex_path):
		mat.set_shader_parameter("ground_tex", load(tex_path) as Texture2D)
	if String(Global.runner_location_id) == "relay":
		# 据点同款暖沙贴图，整体压暗；保持 W1 暖色色相，不随天空变色
		mat.set_shader_parameter("sand_tint", Color(0.52, 0.40, 0.28))
		mat.set_shader_parameter("warm_tint", Color(0.50, 0.32, 0.20))
		mat.set_shader_parameter("cool_shadow", Color(0.26, 0.16, 0.11))
		mat.set_shader_parameter("dust_veil", Color(0.44, 0.32, 0.22))
		mat.set_shader_parameter("tone_warmth", 0.40)
	elif _is_dome_h1_mission() or bool(_mission_visual_scene().get("dark_ground", false)):
		# 居民穹顶 H1：湿暗废墟地面，近处偏褐、远处偏紫灰
		mat.set_shader_parameter("sand_tint", Color(0.18, 0.14, 0.13))
		mat.set_shader_parameter("warm_tint", Color(0.42, 0.28, 0.18))
		mat.set_shader_parameter("cool_shadow", Color(0.08, 0.06, 0.12))
		mat.set_shader_parameter("dust_veil", Color(0.22, 0.16, 0.28))
		mat.set_shader_parameter("tone_warmth", 0.24)
	else:
		# 对齐 W1 夕照玻璃沙漠：暖橙沙 + 路缘软影
		mat.set_shader_parameter("sand_tint", Color(0.96, 0.76, 0.5))
		mat.set_shader_parameter("warm_tint", Color(0.92, 0.58, 0.32))
		mat.set_shader_parameter("cool_shadow", Color(0.48, 0.3, 0.2))
		mat.set_shader_parameter("dust_veil", Color(0.82, 0.62, 0.4))
		mat.set_shader_parameter("tone_warmth", 0.58)
	mat.set_shader_parameter("tex_scale", 0.016)
	mat.set_shader_parameter("detail_scale", 0.22)
	mat.set_shader_parameter("inner_feather", 0.48)
	mat.set_shader_parameter("roughness_val", 0.96)
	return mat

func _build_path_track() -> void:
	if not _path_baked:
		_bake_track_path()
		_path_baked = true
	if _road_root == null:
		_road_root = Node3D.new()
		_road_root.name = "RoadRoot"
		track_root.add_child(_road_root)
	else:
		while _road_root.get_child_count() > 0:
			_road_root.get_child(0).free()
	var lane_y := GROUND_Y - 0.05
	var theme: Dictionary = LevelConfig.get_theme() if LevelConfig != null else {}
	var extra_gaps: Array = []
	for zone in _side_runway_zones():
		var pit: Vector2 = _side_runway_pit_range(zone)
		if pit.y > pit.x + 4.0:
			extra_gaps.append(pit)
	for gap2 in _main_block_road_gaps():
		if gap2.y > gap2.x + 2.0:
			extra_gaps.append(gap2)
	# 主路挤出与编辑器共用 RoadMeshBuilder；起点垫仍用实机专用造型
	var road_opts: Dictionary = {
		"track_pad": 28.0,
		"extra_gaps": extra_gaps,
		"clear_children": false,
		"include_start_pad": false,
		"cast_shadow_off": true,
		"theme": theme,
	}
	if _mission_uses_textured_ground() and _road_style_id == "holographic":
		road_opts["holographic_apron_material"] = _make_desert_surroundings_material()
		road_opts["holographic_apron_half_extra"] = 7.0
		road_opts["holographic_apron_half_extra"] = 8.0
	var kit: Dictionary = _road_mesh.rebuild(
		_road_root,
		Callable(self, "_sample_path"),
		maxf(_path_length, _track_length),
		_road_style_id,
		_junction_zones(),
		road_opts
	)
	if kit.is_empty():
		kit = _make_road_style_kit(_road_style_id)
	_road_style_kit = kit
	if _mission_uses_textured_ground() and _road_style_id == "holographic":
		_build_holographic_road_edge_sand(
			lane_y,
			maxf(_path_length, _track_length) + 28.0,
			_make_desert_surroundings_material()
		)
	_build_start_pad(kit["road"], kit["shoulder"], kit["curb"], kit["line"], kit["post"], lane_y)
	for zone in _junction_zones():
		_build_fork_branch_roads(zone, kit["road"], kit["shoulder"], kit["curb"], kit["line"], kit["island"], lane_y)
	_build_y_fork_branch_roads(kit, lane_y)

func _build_holographic_road_edge_sand(lane_y: float, track_end: float, sand_material: Material) -> void:
	# 与全息跑道同节点树、贴路缘多层沙肩，消除 6m→13m 横向暗缝
	if sand_material == null:
		return
	var road_half := _holographic_road_half()
	var ground_y := _desert_ground_y(lane_y)
	var step := 1.4
	var wings: Array[Dictionary] = [
		{"bias": road_half + 0.95, "half": 2.05},
		{"bias": road_half + 3.2, "half": 2.35},
		{"bias": road_half + 5.8, "half": 2.65},
		{"bias": road_half + 8.6, "half": 3.05},
		{"bias": road_half + 11.6, "half": 3.35},
	]
	for side_sign: float in [-1.0, 1.0]:
		var inner_left := side_sign > 0.0
		for wing in wings:
			_attach_path_strip_skipping_pits(
				0.0,
				track_end,
				float(wing["half"]),
				ground_y,
				sand_material,
				step,
				side_sign * float(wing["bias"]),
				0.34,
				inner_left,
				true,
				false
			)

func _attach_path_strip_skipping_pits(
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	lateral_bias: float,
	edge_wobble: float = 0.0,
	inner_on_left: bool = true,
	feather_inner: bool = false,
	feather_center: bool = false
) -> void:
	var gaps: Array = []
	for gap in _main_block_road_gaps():
		if gap is Vector2 and gap.y > gap.x + 2.0:
			gaps.append(gap)
	for zone in _side_runway_zones():
		var pit: Vector2 = _side_runway_pit_range(zone)
		if pit.y > pit.x + 4.0:
			gaps.append(pit)
	gaps.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var cursor := start_d
	for gap in gaps:
		var gs: float = gap.x
		var ge: float = gap.y
		if ge <= cursor:
			continue
		if gs > cursor + 0.08:
			_attach_path_strip_segment(
				cursor, minf(gs, end_d), half_width, y, material, step,
				lateral_bias, edge_wobble, inner_on_left, feather_inner, feather_center
			)
		cursor = maxf(cursor, ge)
		if cursor >= end_d:
			return
	if end_d > cursor + 0.08:
		_attach_path_strip_segment(
			cursor, end_d, half_width, y, material, step,
			lateral_bias, edge_wobble, inner_on_left, feather_inner, feather_center
		)

func _build_side_runway_tracks() -> void:
	if LevelConfig == null:
		return
	var kit: Dictionary = _road_style_kit if not _road_style_kit.is_empty() else _make_road_style_kit(_road_style_id)
	for zone in _side_runway_zones():
		_attach_wall_run_mesh(zone, kit)
		_attach_wall_run_entry_ramp(zone, kit)
		_attach_wall_run_exit_ramp(zone, kit)
		_attach_side_runway_pit(zone, kit)
		_attach_side_runway_pit_monolith(zone)
		_attach_side_runway_zone_anchors(zone)
		_attach_side_runway_ramp_dressing(zone)
	# main_block：沿路径挖坑+警示，避免长方体在弯道斜出跑道外
	_prepare_lava_platforms_from_layout()
	for gap in _main_block_road_gaps():
		_attach_main_block_path_pit(gap, kit)
	_spawn_lava_platform_visuals()
	_spawn_mechanic_lab_visuals()
	_setup_side_runway_entry_guides()
	_setup_wall_run_tutorial_markers()

func _build_sandstorm_zones() -> void:
	_side_hazard_emitters.clear()
	_side_hazard_runtime.clear()
	for zone in _sandstorm_zones():
		if String(zone.get("emit_style", "volume")) == "side_cave":
			_attach_side_hazard_cave(zone)
		else:
			_attach_sandstorm_volume(zone)
	_sandstorm_particles = _make_sandstorm_particles()
	add_child(_sandstorm_particles)
	_sandstorm_particles.emitting = false
	_sandstorm_grit_particles = _make_sandstorm_grit_particles()
	add_child(_sandstorm_grit_particles)
	_sandstorm_grit_particles.emitting = false

func _attach_side_hazard_cave(zone: Dictionary) -> void:
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 40.0))
	var mid := start + length * 0.5
	var sample := _sample_path(mid)
	var pos: Vector3 = sample["pos"]
	var yaw := float(sample["yaw"])
	var emitter := SideHazardEmitter.new()
	emitter.configure(zone, pos, yaw)
	track_root.add_child(emitter)
	_side_hazard_emitters[int(start)] = emitter
	# 入口警示环（仍提示玩家即将进入侧向喷涌区）
	var entry := _sample_path(start + 1.5)
	var ring := MeshInstance3D.new()
	ring.name = "SideHazardGate"
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 2.2
	ring_mesh.outer_radius = 2.55
	ring_mesh.rings = 10
	ring_mesh.ring_segments = 24
	var is_poison := String(zone.get("hazard_kind", "sand")) == "poison"
	var ring_mat := _make_material(
		Color(0.55, 0.92, 0.38, 0.5) if is_poison else Color(0.95, 0.55, 0.18, 0.55),
		Color(1.0, 0.55, 0.12) if not is_poison else Color(0.45, 0.95, 0.22),
		1.45
	)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_mesh.material = ring_mat
	ring.mesh = ring_mesh
	var right: Vector3 = entry["right"]
	ring.position = (entry["pos"] as Vector3) + Vector3(0.0, GROUND_Y + 1.8, 0.0)
	ring.rotation = Vector3(PI * 0.5, float(entry["yaw"]), 0.0)
	track_root.add_child(ring)

func _update_side_hazard_bursts(delta: float) -> void:
	if is_finished or is_failed or not gameplay_active:
		for emitter in _side_hazard_emitters.values():
			if emitter is SideHazardEmitter:
				(emitter as SideHazardEmitter).set_zone_active(false)
		_side_hazard_runtime.clear()
		return
	for zone in _sandstorm_zones():
		if String(zone.get("emit_style", "volume")) != "side_cave":
			continue
		var key := int(float(zone.get("start", 0.0)))
		var emitter: SideHazardEmitter = _side_hazard_emitters.get(key, null)
		if emitter == null:
			continue
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		var in_region := track_distance >= start and track_distance <= start + length
		emitter.set_zone_active(in_region)
		if not in_region:
			_side_hazard_runtime.erase(key)
			continue
		var runtime: Dictionary = emitter.advance_burst(delta)
		_side_hazard_runtime[key] = runtime

func _attach_sandstorm_volume(zone: Dictionary) -> void:
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 40.0))
	var layout := _sandstorm_volume_layout(zone)
	var half_w: float = float(layout["half_width"])
	var bias: float = float(layout["lateral_bias"])
	var haze_mat := _make_material(Color(0.86, 0.55, 0.22, 0.16), Color(1.0, 0.62, 0.22), 0.55)
	haze_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	haze_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	# 沿路径铺一段半透明沙雾罩（宽度/横向偏移随占据列数变化）
	_attach_path_strip_segment(start, start + length, half_w, GROUND_Y + 1.6, haze_mat, 2.2, bias)
	_attach_path_strip_segment(start, start + length, half_w + 0.8, GROUND_Y + 3.2, haze_mat, 2.4, bias)
	# 入口警示环（对准占据列中心）
	var sample := _sample_path(start + 1.5)
	var ring := MeshInstance3D.new()
	ring.name = "SandstormGate"
	var ring_mesh := TorusMesh.new()
	var ring_r := clampf(half_w * 0.55, 1.6, 5.7)
	ring_mesh.inner_radius = ring_r
	ring_mesh.outer_radius = ring_r + 0.45
	ring_mesh.rings = 12
	ring_mesh.ring_segments = 28
	var ring_mat := _make_material(Color(0.95, 0.55, 0.18, 0.55), Color(1.0, 0.55, 0.12), 1.6)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_mesh.material = ring_mat
	ring.mesh = ring_mesh
	var right: Vector3 = sample["right"]
	ring.position = (sample["pos"] as Vector3) + right * bias + Vector3(0.0, GROUND_Y + 1.8, 0.0)
	ring.rotation = Vector3(PI * 0.5, float(sample["yaw"]), 0.0)
	track_root.add_child(ring)

func _make_sandstorm_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "SandstormDust"
	particles.amount = 148
	particles.lifetime = 1.45
	particles.preprocess = 0.5
	particles.visibility_aabb = AABB(Vector3(-20, -4, -20), Vector3(40, 16, 40))
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1.0, 0.18, 0.42)
	mat.spread = 62.0
	mat.initial_velocity_min = 7.0
	mat.initial_velocity_max = 16.0
	mat.gravity = Vector3(0.0, -0.55, 0.0)
	mat.scale_min = 0.06
	mat.scale_max = 0.26
	mat.color = Color(0.94, 0.70, 0.38, 0.78)
	particles.process_material = mat
	var draw := SphereMesh.new()
	draw.radius = 0.08
	draw.height = 0.16
	var draw_mat := StandardMaterial3D.new()
	draw_mat.albedo_color = Color(0.92, 0.66, 0.32, 0.62)
	draw_mat.emission_enabled = true
	draw_mat.emission = Color(0.88, 0.52, 0.16)
	draw_mat.emission_energy_multiplier = 0.55
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw.material = draw_mat
	particles.draw_pass_1 = draw
	return particles


func _make_sandstorm_grit_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "SandstormGrit"
	particles.amount = 220
	particles.lifetime = 0.85
	particles.preprocess = 0.35
	particles.visibility_aabb = AABB(Vector3(-14, -2, -14), Vector3(28, 10, 28))
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.85, 0.35, 0.55)
	mat.spread = 78.0
	mat.initial_velocity_min = 3.5
	mat.initial_velocity_max = 9.5
	mat.gravity = Vector3(0.0, -1.2, 0.0)
	mat.scale_min = 0.03
	mat.scale_max = 0.09
	mat.color = Color(0.98, 0.78, 0.48, 0.55)
	particles.process_material = mat
	var draw := BoxMesh.new()
	draw.size = Vector3(0.06, 0.06, 0.06)
	var draw_mat := StandardMaterial3D.new()
	draw_mat.albedo_color = Color(0.95, 0.72, 0.38, 0.48)
	draw_mat.emission_enabled = true
	draw_mat.emission = Color(0.85, 0.55, 0.18)
	draw_mat.emission_energy_multiplier = 0.35
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	draw.material = draw_mat
	particles.draw_pass_1 = draw
	return particles


func _setup_rain_weather() -> void:
	_cached_rain_zones.clear()
	ObstacleLayout.clear_root_cache(_runner_layout_id())
	_rain_full_track = false
	_rain_intro_shown = false
	_rain_enter_toast_cd = 0.0
	_clear_rain_corrosive_puddles()
	_rain_puddle_spawn_accum = 0.0
	_rain_puddle_next_d = -1.0
	_rain_puddle_hit_cd = 0.0
	_rain_puddle_rng.seed = hash(_mission_id_str() + "_toxic_puddle_v2")
	_rain_intensity = clampf(float(mission.get("rain_intensity", 1.0)), 0.35, 1.6)

	var zones: Array = _rain_zones()
	var enable := false
	if _is_full_track_rain():
		enable = true
		# 全图雨：无分段则整段生效；有分段则只在分段内
		_rain_full_track = zones.is_empty()
	elif not zones.is_empty():
		enable = true
		_rain_full_track = false
	elif _is_relay_run_task():
		# 各据点 Relay Run 运输关：默认铺 2 段毒雨（可在 JSON rain_zones 里手写覆盖）
		_cached_rain_zones = _generate_random_rain_zones(2)
		enable = not _cached_rain_zones.is_empty()
		_rain_full_track = false
		if enable:
			mission["rain_kind"] = String(mission.get("rain_kind", "toxic"))
			mission["rain_cargo_hit_mult"] = float(mission.get("rain_cargo_hit_mult", 1.1))
	else:
		# 其他关卡可随机出现毒雨段（mission.rain_chance，默认 0.12；显式 0 关闭）
		var chance := float(mission.get("rain_chance", -1.0))
		if chance < 0.0:
			chance = 0.12
		if chance > 0.0 and _rain_puddle_rng.randf() < clampf(chance, 0.0, 1.0):
			var n := 1 if _rain_puddle_rng.randf() < 0.65 else 2
			_cached_rain_zones = _generate_random_rain_zones(n)
			enable = not _cached_rain_zones.is_empty()
			_rain_full_track = false
			if enable:
				mission["rain_kind"] = String(mission.get("rain_kind", "toxic"))
				mission["rain_cargo_hit_mult"] = float(mission.get("rain_cargo_hit_mult", 1.1))

	_rain_active = enable
	if not _rain_active:
		return
	_rain_particles = _make_rain_streak_particles()
	add_child(_rain_particles)
	_rain_soft_particles = _make_rain_soft_droplet_particles()
	add_child(_rain_soft_particles)
	_rain_splash_particles = _make_rain_splash_particles()
	add_child(_rain_splash_particles)
	_rain_particles.emitting = false
	_rain_soft_particles.emitting = false
	_rain_splash_particles.emitting = false
	# 若开局已在雨段内，预铺少量水洼
	if _is_in_rain_hazard_at(track_distance + 18.0):
		for i in 2:
			var at_d := track_distance + 18.0 + float(i) * 22.0
			if _is_in_rain_hazard_at(at_d):
				_spawn_rain_corrosive_puddle(at_d)


func _show_rain_intro() -> void:
	if not _rain_active or not gameplay_active or _rain_intro_shown:
		return
	if not _rain_full_track and not _is_in_rain_hazard_at(track_distance):
		return
	_rain_intro_shown = true
	_show_gate_toast("Toxic rain · dodge acid puddles")
	strike_toast_label.text = "→ Toxic rain segment · jump / change lane"
	strike_toast_label.modulate = Color(0.62, 0.88, 0.48, 1.0)
	strike_toast_timer = 3.0


func _clear_rain_corrosive_puddles() -> void:
	for entry in _rain_puddles:
		var node: Node = entry.get("node") as Node
		if node != null and is_instance_valid(node):
			node.queue_free()
	_rain_puddles.clear()


func _update_rain_corrosive_puddles(delta: float) -> void:
	if not _rain_active:
		return
	if is_finished or is_failed:
		for entry in _rain_puddles:
			var n: Node3D = entry.get("node") as Node3D
			if n != null and is_instance_valid(n):
				n.visible = false
		return
	# 按路程预铺：仅在毒雨段前方落下酸性积液（熔岩区 / 侧墙不生成）
	_rain_enter_toast_cd = maxf(0.0, _rain_enter_toast_cd - delta)
	if gameplay_active and not is_intro and _is_in_rain_hazard_at(track_distance):
		if not _rain_intro_shown and _rain_enter_toast_cd <= 0.0:
			_show_rain_intro()
		if _rain_puddle_next_d < 0.0:
			_rain_puddle_next_d = track_distance + 10.0
		while track_distance + 42.0 >= _rain_puddle_next_d:
			if not _is_in_rain_hazard_at(_rain_puddle_next_d):
				_rain_puddle_next_d += _rain_puddle_rng.randf_range(4.0, 8.0)
				continue
			var spawned := _spawn_rain_corrosive_puddle(_rain_puddle_next_d)
			if spawned:
				_rain_puddle_next_d += _rain_puddle_rng.randf_range(18.0, 28.0)
			else:
				_rain_puddle_next_d += _rain_puddle_rng.randf_range(6.0, 10.0)

	_rain_puddle_hit_cd = maxf(_rain_puddle_hit_cd - delta, 0.0)
	var standing_in := false
	var contact_node: Node3D = null
	var i := 0
	while i < _rain_puddles.size():
		var entry: Dictionary = _rain_puddles[i]
		var node: Node3D = entry.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			_rain_puddles.remove_at(i)
			continue
		var puddle_d := float(entry.get("distance", 0.0))
		var life := float(entry.get("life", 0.0)) - delta
		entry["life"] = life
		if puddle_d < track_distance - 8.0 or life <= 0.0:
			node.queue_free()
			_rain_puddles.remove_at(i)
			continue
		var lateral := float(entry.get("lateral", 0.0))
		var radius := float(entry.get("radius", 1.15))
		var hit_r := float(entry.get("hit_radius", radius * 0.9))
		var placed := _world_on_path(puddle_d, lateral, GROUND_Y + 0.02)
		node.global_position = placed["pos"] as Vector3
		# 保留生成时的 yaw 抖动，只叠路径朝向
		node.rotation = Vector3(0.0, float(placed.get("yaw", 0.0)) + float(entry.get("yaw_jitter", 0.0)), 0.0)
		var age := float(entry.get("max_life", life)) - life
		var appear := clampf((age - 0.08) / 0.45, 0.0, 1.0)
		_set_acid_puddle_appear(node, appear)
		var near := absf(track_distance - puddle_d) <= 5.5 and absf(current_lateral - lateral) <= LANE_WIDTH * 0.85
		_pulse_acid_puddle_reaction(entry, age, near)

		var along := absf(track_distance - puddle_d)
		var lat_gap := absf(current_lateral - lateral)
		var in_zone := along <= hit_r and lat_gap <= hit_r * 0.92
		var airborne_safe := (not _is_on_ground()) and player != null and player.position.y > _ground_y_at(track_distance) + 0.55
		if (
			in_zone
			and not airborne_safe
			and not _is_wall_running()
			and track_layer == 0
			and gameplay_active
			and not is_intro
		):
			standing_in = true
			contact_node = node
		_rain_puddles[i] = entry
		i += 1

	if standing_in and _rain_puddle_hit_cd <= 0.0 and gameplay_active and not is_intro:
		_rain_puddle_hit_cd = float(mission.get("rain_puddle_tick", 0.38))
		var dmg := float(mission.get("rain_puddle_damage", 4.5))
		dmg *= Global.get_cargo_damage_multiplier() * _cargo_fragility_mult() * _toxic_rain_cargo_hit_mult()
		_apply_cargo_loss(dmg)
		if contact_node != null:
			_burst_acid_puddle_contact(contact_node)
		if is_failed:
			return
		camera_shake = maxf(camera_shake, 0.08)
		if _hit_feedback != null and player != null:
			_hit_feedback.apply_env_tick_at(player.global_position + Vector3(0.0, 1.6, 0.0), dmg, "毒雨腐蚀")
		_show_strike_warning("毒雨腐蚀 · 换道或跳起躲开")
		strike_toast_label.modulate = Color(0.72, 0.62, 0.42, 1.0)


func _rain_puddle_allowed_at(at_distance: float, lateral: float) -> bool:
	# 熔岩坑 / 熔岩平台排除带：不生成积液
	if _is_in_main_block_pit(at_distance):
		return false
	if _is_distance_in_lava_platform_exclusion(at_distance):
		return false
	if _is_distance_in_lava_crossing_clear_zone(at_distance):
		return false
	if _is_in_any_open_pit(at_distance):
		return false
	# 侧墙 / 侧跑道段：不在墙侧与坑侧生成
	var wall_z: Dictionary = _side_runway_wall_zone_at(at_distance)
	if not wall_z.is_empty():
		return false
	var side_z: Dictionary = _side_runway_zone_at(at_distance)
	if not side_z.is_empty():
		return false
	# 限制在主路三道内，避免贴到路肩/侧坡
	if absf(lateral) > LANE_WIDTH * 1.05:
		return false
	return true


func _set_acid_puddle_appear(root: Node3D, appear: float) -> void:
	if root == null:
		return
	var fade_out := 1.0 - clampf(appear, 0.0, 1.0)
	for child in root.get_children():
		if child is GeometryInstance3D:
			(child as GeometryInstance3D).transparency = fade_out


func _make_acid_puddle_mat(color: Color, rough: float = 0.82, metallic: float = 0.04, emit_energy: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = color
	mat.roughness = rough
	mat.metallic = metallic
	mat.disable_fog = true
	if emit_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = Color(color.r * 0.55, color.g * 0.62, color.b * 0.4, 1.0)
		mat.emission_energy_multiplier = emit_energy
	return mat


func _add_acid_disc(parent: Node3D, radius: float, y: float, mat: Material, disc_name: String) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = disc_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.014
	mesh.radial_segments = 28
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = Vector3(0.0, y, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


func _build_irregular_acid_blob_mesh(radius: float, segments: int = 26, jagged: float = 0.34) -> ArrayMesh:
	# 顶视不规则积液轮廓：低频瓣形 + 高频毛边，避免完美圆贴画
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var phase_a := _rain_puddle_rng.randf() * TAU
	var phase_b := _rain_puddle_rng.randf() * TAU
	var phase_c := _rain_puddle_rng.randf() * TAU
	var amp_a := jagged * _rain_puddle_rng.randf_range(0.45, 0.85)
	var amp_b := jagged * _rain_puddle_rng.randf_range(0.25, 0.55)
	var amp_c := jagged * _rain_puddle_rng.randf_range(0.12, 0.32)
	var pts: Array[Vector3] = []
	for i in segments:
		var t := (float(i) / float(segments)) * TAU
		var wobble := 1.0 \
			+ amp_a * sin(t * 2.0 + phase_a) \
			+ amp_b * sin(t * 3.0 + phase_b) \
			+ amp_c * sin(t * 5.0 + phase_c) \
			+ _rain_puddle_rng.randf_range(-jagged * 0.18, jagged * 0.18)
		wobble = clampf(wobble, 0.52, 1.48)
		pts.append(Vector3(cos(t) * radius * wobble, 0.0, sin(t) * radius * wobble))
	var nrm := Vector3.UP
	for i in segments:
		var a: Vector3 = pts[i]
		var b: Vector3 = pts[(i + 1) % segments]
		st.set_normal(nrm)
		st.add_vertex(Vector3.ZERO)
		st.set_normal(nrm)
		st.add_vertex(a)
		st.set_normal(nrm)
		st.add_vertex(b)
	return st.commit()


func _add_acid_blob(parent: Node3D, radius: float, y: float, mat: Material, blob_name: String, jagged: float = 0.34) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = blob_name
	mi.mesh = _build_irregular_acid_blob_mesh(radius, 24 + _rain_puddle_rng.randi_range(0, 8), jagged)
	mi.material_override = mat
	mi.position = Vector3(0.0, y, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


func _pulse_acid_puddle_reaction(entry: Dictionary, age: float, near: bool) -> void:
	var pulse: float = 0.55 + 0.45 * sin(age * 2.2)
	var wave_pulse: float = 0.5 + 0.5 * sin(age * 3.1 + 0.8)
	var near_boost: float = 1.4 if near else 1.0
	var patches: Array = entry.get("reaction_patches", []) as Array
	for p in patches:
		if not (p is MeshInstance3D):
			continue
		var mi := p as MeshInstance3D
		if not is_instance_valid(mi):
			continue
		var mat := mi.material_override as StandardMaterial3D
		if mat == null:
			continue
		mat.emission_enabled = true
		mat.emission_energy_multiplier = (0.1 + 0.18 * pulse) * near_boost
	var waves: Array = entry.get("wave_patches", []) as Array
	for w in waves:
		if not (w is MeshInstance3D):
			continue
		var wmi := w as MeshInstance3D
		if not is_instance_valid(wmi):
			continue
		var wmat := wmi.material_override as StandardMaterial3D
		if wmat == null:
			continue
		wmat.emission_enabled = true
		wmat.emission_energy_multiplier = (0.35 + 0.55 * wave_pulse) * near_boost
		var c := wmat.albedo_color
		c.a = clampf(0.28 + 0.22 * wave_pulse, 0.22, 0.55)
		wmat.albedo_color = c


func _burst_acid_puddle_contact(root: Node3D) -> void:
	if root == null or not is_instance_valid(root):
		return
	var burst := GPUParticles3D.new()
	burst.emitting = true
	burst.one_shot = true
	burst.amount = 12
	burst.lifetime = 0.5
	burst.explosiveness = 0.88
	burst.visibility_aabb = AABB(Vector3(-2, -0.5, -2), Vector3(4, 2, 4))
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.48
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 48.0
	mat.initial_velocity_min = 0.25
	mat.initial_velocity_max = 0.95
	mat.gravity = Vector3(0, -1.4, 0)
	mat.scale_min = 0.035
	mat.scale_max = 0.09
	mat.color = Color(0.71, 0.83, 0.43, 0.45)
	burst.process_material = mat
	var dm := SphereMesh.new()
	dm.radius = 0.03
	dm.height = 0.06
	var dmat := StandardMaterial3D.new()
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmat.albedo_color = Color(0.62, 0.76, 0.4, 0.48)
	dmat.emission_enabled = true
	dmat.emission = Color(0.48, 0.62, 0.28, 1.0)
	dmat.emission_energy_multiplier = 0.4
	dm.material = dmat
	burst.draw_pass_1 = dm
	burst.position = Vector3(0.0, 0.06, 0.0)
	root.add_child(burst)
	get_tree().create_timer(0.7).timeout.connect(func() -> void:
		if is_instance_valid(burst):
			burst.queue_free()
	)


func _spawn_rain_corrosive_puddle(at_distance: float) -> bool:
	if track_root == null:
		return false
	for entry in _rain_puddles:
		if absf(float(entry.get("distance", -999.0)) - at_distance) < 9.0:
			return false
	var lane := int(LANES[_rain_puddle_rng.randi() % LANES.size()])
	var lateral := float(lane) * LANE_WIDTH
	if _rain_puddle_rng.randf() < 0.28:
		lateral += _rain_puddle_rng.randf_range(-0.35, 0.35)
	lateral = clampf(lateral, -LANE_WIDTH * 1.0, LANE_WIDTH * 1.0)
	if not _rain_puddle_allowed_at(at_distance, lateral):
		return false

	# 大小拉开：小 / 中 / 大，避免同一贴画尺寸
	var size_roll := _rain_puddle_rng.randf()
	var radius: float
	if size_roll < 0.34:
		radius = _rain_puddle_rng.randf_range(0.62, 0.95)
	elif size_roll < 0.78:
		radius = _rain_puddle_rng.randf_range(1.05, 1.55)
	else:
		radius = _rain_puddle_rng.randf_range(1.7, 2.25)
	var hit_radius := radius * _rain_puddle_rng.randf_range(0.86, 0.92)
	var life := _rain_puddle_rng.randf_range(7.5, 11.0)
	var root := Node3D.new()
	root.name = "ToxicAcidPuddle"
	track_root.add_child(root)

	var yaw_jitter := _rain_puddle_rng.randf_range(-0.9, 0.9)
	# 更强椭圆拉伸，轮廓彼此不像
	var squash_x := _rain_puddle_rng.randf_range(0.62, 1.38)
	var squash_z := _rain_puddle_rng.randf_range(0.58, 1.42)

	# Layer A: 不规则浊酸底液（略提亮）
	var base_col := Color(0.24, 0.36, 0.26, 0.68)
	_add_acid_blob(root, radius, 0.016, _make_acid_puddle_mat(base_col, 0.88, 0.03), "BaseLiquid", _rain_puddle_rng.randf_range(0.28, 0.42))

	# 1～3 个偏移小瓣，进一步打碎圆形
	var lobe_n := _rain_puddle_rng.randi_range(1, 3)
	for _li in range(lobe_n):
		var lang := _rain_puddle_rng.randf() * TAU
		var ldist := radius * _rain_puddle_rng.randf_range(0.28, 0.72)
		var lr := radius * _rain_puddle_rng.randf_range(0.22, 0.52)
		var lobe_col := Color(0.3, 0.42, 0.3, 0.58)
		var lobe := _add_acid_blob(root, lr, 0.015, _make_acid_puddle_mat(lobe_col, 0.9, 0.03), "BaseLobe", _rain_puddle_rng.randf_range(0.3, 0.48))
		lobe.position = Vector3(cos(lang) * ldist, lobe.position.y, sin(lang) * ldist)
		lobe.rotation.y = _rain_puddle_rng.randf() * TAU
		lobe.scale = Vector3(_rain_puddle_rng.randf_range(0.55, 1.35), 1.0, _rain_puddle_rng.randf_range(0.5, 1.3))

	# Layer B: 浑浊覆盖（另一套不规则）
	var murk_col := Color(0.42, 0.6, 0.42, 0.36)
	var murk := _add_acid_blob(
		root,
		radius * _rain_puddle_rng.randf_range(0.72, 0.92),
		0.024,
		_make_acid_puddle_mat(murk_col, 0.8, 0.03),
		"MurkyOverlay",
		_rain_puddle_rng.randf_range(0.26, 0.4)
	)
	murk.rotation.y = _rain_puddle_rng.randf_range(0.0, TAU)
	murk.scale = Vector3(_rain_puddle_rng.randf_range(0.75, 1.2), 1.0, _rain_puddle_rng.randf_range(0.7, 1.25))

	# Layer C: 稀疏反应斑
	var reaction_patches: Array = []
	var patch_n := _rain_puddle_rng.randi_range(2, 4)
	for _pi in range(patch_n):
		var ang := _rain_puddle_rng.randf() * TAU
		var dist := radius * _rain_puddle_rng.randf_range(0.18, 0.8)
		var pr := radius * _rain_puddle_rng.randf_range(0.06, 0.15)
		var use_violet := _rain_puddle_rng.randf() < 0.3
		var pc: Color
		if use_violet:
			pc = Color(0.45, 0.34, 0.52, 0.3)
		else:
			pc = Color(0.78, 0.9, 0.5, 0.34)
		var pmat := _make_acid_puddle_mat(pc, 0.55, 0.06, 0.32)
		var pmi := _add_acid_blob(root, pr, 0.032 + _rain_puddle_rng.randf_range(0.0, 0.008), pmat, "ReactionPatch", 0.38)
		pmi.position = Vector3(cos(ang) * dist, pmi.position.y, sin(ang) * dist)
		pmi.rotation.y = _rain_puddle_rng.randf() * TAU
		pmi.scale = Vector3(_rain_puddle_rng.randf_range(0.55, 1.4), 1.0, _rain_puddle_rng.randf_range(0.45, 1.25))
		reaction_patches.append(pmi)

	# 局部亮水波：细长亮纹，轻轻呼吸，不要整滩均匀发亮
	var wave_patches: Array = []
	var wave_n := _rain_puddle_rng.randi_range(2, 4)
	for _wi in range(wave_n):
		var wang := _rain_puddle_rng.randf() * TAU
		var wdist := radius * _rain_puddle_rng.randf_range(0.12, 0.7)
		var wr := radius * _rain_puddle_rng.randf_range(0.14, 0.28)
		var wave_col := Color(0.82, 0.96, 0.58, 0.4)
		if _rain_puddle_rng.randf() < 0.22:
			wave_col = Color(0.72, 0.88, 0.62, 0.36)
		var wmat := _make_acid_puddle_mat(wave_col, 0.35, 0.12, 0.55)
		var wave := _add_acid_blob(root, wr, 0.036 + _rain_puddle_rng.randf_range(0.0, 0.01), wmat, "BrightWave", 0.22)
		wave.position = Vector3(cos(wang) * wdist, wave.position.y, sin(wang) * wdist)
		wave.rotation.y = wang + _rain_puddle_rng.randf_range(-0.4, 0.4) + PI * 0.5
		# 拉成长条水波纹
		wave.scale = Vector3(
			_rain_puddle_rng.randf_range(1.35, 2.2),
			1.0,
			_rain_puddle_rng.randf_range(0.22, 0.42)
		)
		wave_patches.append(wave)

	# 湿边薄晕：同样不规则，不要圆描边
	var rim_col := Color(0.34, 0.48, 0.34, 0.2)
	var rim := _add_acid_blob(root, radius * 1.08, 0.012, _make_acid_puddle_mat(rim_col, 0.92, 0.02), "SoftRim", 0.36)
	rim.rotation.y = _rain_puddle_rng.randf() * TAU

	# 贴地边缘溅射光粒：雨滴打在水圈四周，向外微溅（不是高飘）
	var rim_splash := GPUParticles3D.new()
	rim_splash.name = "RimGroundSplash"
	rim_splash.emitting = true
	rim_splash.amount = clampi(int(8.0 + radius * 3.0), 8, 14)
	rim_splash.lifetime = 0.38
	rim_splash.explosiveness = 0.05
	rim_splash.randomness = 0.7
	rim_splash.visibility_aabb = AABB(Vector3(-3.5, -0.4, -3.5), Vector3(7, 2.2, 7))
	var splash_mat := ParticleProcessMaterial.new()
	splash_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	splash_mat.emission_ring_axis = Vector3(0, 1, 0)
	splash_mat.emission_ring_height = 0.04
	splash_mat.emission_ring_radius = radius * 1.02
	splash_mat.emission_ring_inner_radius = radius * 0.88
	splash_mat.direction = Vector3(0, 1, 0)
	splash_mat.spread = 62.0
	splash_mat.initial_velocity_min = 0.35
	splash_mat.initial_velocity_max = 1.05
	splash_mat.gravity = Vector3(0, -3.2, 0)
	splash_mat.damping_min = 1.2
	splash_mat.damping_max = 2.4
	splash_mat.scale_min = 0.03
	splash_mat.scale_max = 0.08
	splash_mat.color = Color(0.86, 0.96, 0.5, 0.78)
	rim_splash.process_material = splash_mat
	var splash_mesh := SphereMesh.new()
	splash_mesh.radius = 0.028
	splash_mesh.height = 0.056
	var splash_draw := StandardMaterial3D.new()
	splash_draw.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	splash_draw.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	splash_draw.albedo_color = Color(0.88, 0.97, 0.52, 0.8)
	splash_draw.emission_enabled = true
	splash_draw.emission = Color(0.78, 0.94, 0.38, 1.0)
	splash_draw.emission_energy_multiplier = 1.55
	splash_draw.disable_fog = true
	splash_mesh.material = splash_draw
	rim_splash.draw_pass_1 = splash_mesh
	rim_splash.position = Vector3(0.0, 0.03, 0.0)
	root.add_child(rim_splash)

	# 水面上稀疏雨滴落点（很淡）
	var rain_impact := GPUParticles3D.new()
	rain_impact.name = "RainImpactParticles"
	rain_impact.emitting = true
	rain_impact.amount = clampi(int(6.0 + radius * 2.0), 6, 10)
	rain_impact.lifetime = 0.45
	rain_impact.visibility_aabb = AABB(Vector3(-2.5, -0.3, -2.5), Vector3(5, 2, 5))
	var impact_mat := ParticleProcessMaterial.new()
	impact_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	impact_mat.emission_sphere_radius = radius * 0.55
	impact_mat.direction = Vector3(0, -1, 0)
	impact_mat.spread = 6.0
	impact_mat.initial_velocity_min = 0.35
	impact_mat.initial_velocity_max = 0.9
	impact_mat.gravity = Vector3(0, -2.2, 0)
	impact_mat.scale_min = 0.018
	impact_mat.scale_max = 0.045
	impact_mat.color = Color(0.75, 0.88, 0.45, 0.4)
	rain_impact.process_material = impact_mat
	var rmesh := SphereMesh.new()
	rmesh.radius = 0.02
	rmesh.height = 0.04
	var rdraw := StandardMaterial3D.new()
	rdraw.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rdraw.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rdraw.albedo_color = Color(0.75, 0.88, 0.45, 0.38)
	rdraw.emission_enabled = true
	rdraw.emission = Color(0.58, 0.74, 0.32, 1.0)
	rdraw.emission_energy_multiplier = 0.35
	rmesh.material = rdraw
	rain_impact.draw_pass_1 = rmesh
	rain_impact.position = Vector3(0.0, 0.28, 0.0)
	root.add_child(rain_impact)

	# 稀疏气泡（大水坑略多）
	var bubbles := GPUParticles3D.new()
	bubbles.name = "BubbleParticles"
	bubbles.emitting = true
	bubbles.amount = 4 if radius < 1.1 else (6 if radius < 1.7 else 8)
	bubbles.lifetime = 1.0
	bubbles.visibility_aabb = AABB(Vector3(-2.5, -0.2, -2.5), Vector3(5, 2, 5))
	var bmat := ParticleProcessMaterial.new()
	bmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	bmat.emission_sphere_radius = radius * 0.45
	bmat.direction = Vector3(0, 1, 0)
	bmat.spread = 10.0
	bmat.initial_velocity_min = 0.04
	bmat.initial_velocity_max = 0.14
	bmat.gravity = Vector3(0, 0.04, 0)
	bmat.scale_min = 0.025
	bmat.scale_max = 0.06
	bmat.color = Color(0.5, 0.68, 0.36, 0.4)
	bubbles.process_material = bmat
	var bmesh := SphereMesh.new()
	bmesh.radius = 0.028
	bmesh.height = 0.056
	var bdraw := StandardMaterial3D.new()
	bdraw.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bdraw.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bdraw.albedo_color = Color(0.52, 0.68, 0.36, 0.42)
	bdraw.emission_enabled = true
	bdraw.emission = Color(0.42, 0.58, 0.26, 1.0)
	bdraw.emission_energy_multiplier = 0.35
	bmesh.material = bdraw
	bubbles.draw_pass_1 = bmesh
	bubbles.position = Vector3(0.0, 0.04, 0.0)
	root.add_child(bubbles)

	root.scale = Vector3(squash_x, 1.0, squash_z)
	var placed := _world_on_path(at_distance, lateral, GROUND_Y + 0.02)
	root.global_position = placed["pos"] as Vector3
	root.rotation = Vector3(0.0, float(placed.get("yaw", 0.0)) + yaw_jitter, 0.0)
	_set_acid_puddle_appear(root, 0.0)

	_rain_puddles.append({
		"node": root,
		"distance": at_distance,
		"lateral": lateral,
		"radius": radius,
		"hit_radius": hit_radius,
		"life": life,
		"max_life": life,
		"yaw_jitter": yaw_jitter,
		"base_scale": root.scale,
		"reaction_patches": reaction_patches,
		"wave_patches": wave_patches,
	})
	return true


func _update_rain_weather(_delta: float) -> void:
	if not _rain_active:
		return
	var anchor: Node3D = player
	if camera != null and is_instance_valid(camera):
		anchor = camera
	if anchor == null:
		return
	var pos: Vector3 = anchor.global_position
	var in_rain := _is_in_rain_hazard_at(track_distance) and not is_finished and not is_failed
	var dens := clampf(_current_rain_intensity(), 0.0, 1.0)
	if dens <= 0.01:
		in_rain = false
	if _rain_particles != null:
		_rain_particles.emitting = in_rain
		_rain_particles.global_position = pos + Vector3(0.0, 8.2, -1.2)
		_rain_particles.amount_ratio = dens
	if _rain_soft_particles != null:
		_rain_soft_particles.emitting = in_rain
		_rain_soft_particles.global_position = pos + Vector3(0.0, 6.5, -0.6)
		_rain_soft_particles.amount_ratio = dens * 0.9
	if _rain_splash_particles != null:
		_rain_splash_particles.emitting = in_rain
		var ground_y := pos.y
		if player != null:
			ground_y = player.global_position.y
		_rain_splash_particles.global_position = Vector3(pos.x, ground_y + 0.06, pos.z - 0.8)
		_rain_splash_particles.amount_ratio = dens * 0.9


func _make_rain_draw_mat(albedo: Color, emission: Color, energy: float) -> StandardMaterial3D:
	var draw_mat := StandardMaterial3D.new()
	draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw_mat.albedo_color = albedo
	draw_mat.emission_enabled = true
	draw_mat.emission = emission
	draw_mat.emission_energy_multiplier = energy
	draw_mat.disable_fog = true
	draw_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	draw_mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	return draw_mat


func _make_rain_streak_particles() -> GPUParticles3D:
	# 主雨层：胶囊沿速度对齐，像真实雨滴拖影，而非硬细线
	var particles := GPUParticles3D.new()
	particles.name = "RainStreaks"
	particles.amount = int(lerpf(220.0, 360.0, clampf(_rain_intensity, 0.0, 1.0)))
	particles.lifetime = 0.62
	particles.preprocess = 0.6
	particles.randomness = 0.55
	particles.visibility_aabb = AABB(Vector3(-20, -12, -20), Vector3(40, 32, 40))
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ParticleProcessMaterial.new()
	mat.particle_flag_align_y = true
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(10.0, 0.6, 11.0)
	mat.direction = Vector3(0.18, -1.0, 0.06)
	mat.spread = 7.0
	mat.initial_velocity_min = 16.0
	mat.initial_velocity_max = 26.0
	mat.gravity = Vector3(0.8, -36.0, 0.2)
	mat.damping_min = 0.0
	mat.damping_max = 0.15
	mat.scale_min = 0.55
	mat.scale_max = 1.15
	mat.color = Color(1, 1, 1, 1)
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.12, 0.7, 1.0])
	# 雾青橄榄毒雨：半透明，不刺眼荧光绿
	grad.colors = PackedColorArray([
		Color(0.52, 0.68, 0.42, 0.0),
		Color(0.48, 0.70, 0.40, 0.55),
		Color(0.42, 0.62, 0.36, 0.38),
		Color(0.36, 0.52, 0.32, 0.0),
	])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp
	particles.process_material = mat
	var draw := CapsuleMesh.new()
	draw.radius = 0.028
	draw.height = 0.42
	draw.radial_segments = 6
	draw.rings = 2
	draw.material = _make_rain_draw_mat(
		Color(0.55, 0.72, 0.45, 0.42),
		Color(0.40, 0.62, 0.32),
		0.45
	)
	particles.draw_pass_1 = draw
	return particles


func _make_rain_soft_droplet_particles() -> GPUParticles3D:
	# 近景柔点水珠：补体积感，避免只有线
	var particles := GPUParticles3D.new()
	particles.name = "RainSoftDroplets"
	particles.amount = int(lerpf(70.0, 120.0, clampf(_rain_intensity, 0.0, 1.0)))
	particles.lifetime = 0.7
	particles.preprocess = 0.55
	particles.randomness = 0.7
	particles.visibility_aabb = AABB(Vector3(-14, -8, -14), Vector3(28, 22, 28))
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(7.0, 1.2, 7.5)
	mat.direction = Vector3(0.14, -1.0, 0.05)
	mat.spread = 10.0
	mat.initial_velocity_min = 10.0
	mat.initial_velocity_max = 18.0
	mat.gravity = Vector3(0.5, -22.0, 0.15)
	mat.scale_min = 0.35
	mat.scale_max = 0.85
	mat.color = Color(1, 1, 1, 1)
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.2, 0.75, 1.0])
	grad.colors = PackedColorArray([
		Color(0.58, 0.72, 0.48, 0.0),
		Color(0.52, 0.68, 0.44, 0.32),
		Color(0.46, 0.60, 0.40, 0.22),
		Color(0.40, 0.52, 0.36, 0.0),
	])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp
	particles.process_material = mat
	var draw := SphereMesh.new()
	draw.radius = 0.045
	draw.height = 0.1
	draw.radial_segments = 8
	draw.rings = 4
	draw.material = _make_rain_draw_mat(
		Color(0.58, 0.74, 0.48, 0.28),
		Color(0.42, 0.58, 0.34),
		0.28
	)
	particles.draw_pass_1 = draw
	return particles


func _make_rain_splash_particles() -> GPUParticles3D:
	# 落地溅花：短促扁环，比小球更像雨点砸地
	var particles := GPUParticles3D.new()
	particles.name = "RainSplashes"
	particles.amount = int(lerpf(55.0, 110.0, clampf(_rain_intensity, 0.0, 1.0)))
	particles.lifetime = 0.28
	particles.preprocess = 0.22
	particles.randomness = 0.8
	particles.visibility_aabb = AABB(Vector3(-12, -1, -12), Vector3(24, 5, 24))
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(6.0, 0.04, 7.0)
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 70.0
	mat.initial_velocity_min = 0.35
	mat.initial_velocity_max = 1.4
	mat.gravity = Vector3(0.0, -5.5, 0.0)
	mat.scale_min = 0.45
	mat.scale_max = 1.25
	mat.color = Color(1, 1, 1, 1)
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.18, 0.55, 1.0])
	grad.colors = PackedColorArray([
		Color(0.62, 0.78, 0.48, 0.0),
		Color(0.55, 0.74, 0.42, 0.45),
		Color(0.48, 0.64, 0.38, 0.2),
		Color(0.40, 0.52, 0.34, 0.0),
	])
	var ramp := GradientTexture1D.new()
	ramp.gradient = grad
	mat.color_ramp = ramp
	particles.process_material = mat
	var draw := TorusMesh.new()
	draw.inner_radius = 0.02
	draw.outer_radius = 0.09
	draw.rings = 6
	draw.ring_segments = 10
	draw.material = _make_rain_draw_mat(
		Color(0.58, 0.76, 0.46, 0.35),
		Color(0.44, 0.62, 0.34),
		0.35
	)
	particles.draw_pass_1 = draw
	return particles


func _side_runway_pit_range(zone: Dictionary) -> Vector2:
	var start := float(zone["start"])
	var length := float(zone.get("length", 70.0))
	var entry := float(zone.get("entry_window", 10.0))
	# 入口留足上墙距离；出口留安全落地岛，避免下墙仍落在坑上
	var pit_s := start + maxf(12.0, entry * 0.85)
	var exit_pad := maxf(14.0, length * 0.22)
	var pit_e := start + length - exit_pad
	if pit_e <= pit_s + 8.0:
		pit_e = pit_s + 8.0
	return Vector2(pit_s, pit_e)

func _main_block_road_gaps() -> Array:
	# 路网建造早于障碍注册：读本关障碍表（含 layout JSON）
	var items: Array = _layout_obstacle_items_raw()
	var gaps: Array = []
	var seen: Dictionary = {}
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if int(item.get("layer", 0)) != 0:
			continue
		var center := float(item.get("distance", 0.0))
		var half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		var key := "%d" % int(round(center))
		if seen.has(key):
			continue
		seen[key] = true
		if _main_block_cross_mode(item) == "platform":
			gaps.append(_main_block_platform_open_lava_range(center, half))
		else:
			gaps.append(Vector2(center - half, center + half))
	_ensure_mechanic_layout()
	for gap in _open_gaps:
		gaps.append(Vector2(float(gap.get("start", 0.0)), float(gap.get("end", 0.0))))
	for zone in _width_zones:
		var start := float(zone.get("start", 0.0))
		var end := start + float(zone.get("length", 0.0))
		if end > start + 2.0:
			gaps.append(Vector2(start, end))
	return gaps

func _layout_lava_cross_mode() -> String:
	var layout_id := _runner_layout_id()
	if layout_id != "":
		var mode := String(ObstacleLayout.load_root(layout_id).get("lava_cross_mode", "")).strip_edges()
		if mode != "":
			return mode
	if Global.runner_planet_id == "glass_desert":
		return "platform"
	return "side_wall"

func _main_block_cross_mode(item: Dictionary) -> String:
	var item_mode := String(item.get("cross", "")).strip_edges()
	if item_mode != "":
		return item_mode
	return _layout_lava_cross_mode()

func _main_block_obstacle_uses_platform(obstacle: Dictionary) -> bool:
	var stored := String(obstacle.get("cross_mode", "")).strip_edges()
	if stored == "platform":
		return true
	if stored == "side_wall":
		return false
	var center := float(obstacle.get("distance", 0.0))
	var half := float(obstacle.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
	for raw in _layout_obstacle_items_raw():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		var item_center := float(item.get("distance", 0.0))
		var item_half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		if center >= item_center - item_half - 0.35 and center <= item_center + item_half + 0.35:
			return _main_block_cross_mode(item) == "platform"
	return _layout_lava_cross_mode() == "platform"

func _lava_platform_jump_spacing() -> float:
	var speed := maxf(_base_run_speed(), 11.0)
	var air_time := (2.0 * JUMP_SPEED) / GRAVITY
	# 与 AIR_FORWARD_SPEED_MULT 同步，再略收 8% 留落地余量
	var reach := speed * air_time * AIR_FORWARD_SPEED_MULT * 0.92
	return clampf(reach, 6.0, 9.0)

func _lava_platform_exclusion_zones() -> Array:
	var zones: Array = []
	for raw in _layout_obstacle_items_raw():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if _main_block_cross_mode(item) != "platform":
			continue
		var center := float(item.get("distance", 0.0))
		var half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		zones.append({
			"pit": Vector2(center - half, center + half),
			"exclude": Vector2(center - half - 20.0, center + half + 10.0),
		})
	return zones

func _is_distance_in_lava_platform_exclusion(distance: float) -> bool:
	for raw in _lava_platform_exclusion_zones():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var zone: Dictionary = raw
		var ex: Vector2 = zone.get("exclude", Vector2.ZERO)
		if distance >= ex.x and distance <= ex.y:
			return true
	return false

func _lava_platform_pit_zones_from_items(items: Array) -> Array:
	var zones: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if _main_block_cross_mode(item) != "platform":
			continue
		var center := float(item.get("distance", 0.0))
		var half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		zones.append(Vector2(center - half - 20.0, center + half + 10.0))
	return zones

func _filter_obstacles_near_lava_platform_pits(items: Array) -> Array:
	var pit_zones := _lava_platform_pit_zones_from_items(items)
	if pit_zones.is_empty():
		return items
	var out: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			out.append(raw)
			continue
		var item: Dictionary = raw
		var otype := String(item.get("type", ""))
		if otype == "main_block" or otype == "ramp":
			out.append(item)
			continue
		if int(item.get("layer", 0)) != 0:
			out.append(item)
			continue
		var dist := float(item.get("distance", 0.0))
		var drop := false
		for zone in pit_zones:
			var z: Vector2 = zone
			if dist >= z.x and dist <= z.y:
				drop = true
				break
		if not drop:
			out.append(item)
	return out

func _purge_obstacles_in_lava_platform_zones() -> void:
	if _lava_platform_exclusion_zones().is_empty() and _lava_crossing_clear_zones().is_empty():
		return
	var keep: Array = []
	for obstacle in obstacles:
		if typeof(obstacle) != TYPE_DICTIONARY:
			continue
		var otype := String(obstacle.get("type", ""))
		if otype == "main_block" or otype == "ramp":
			keep.append(obstacle)
			continue
		if int(obstacle.get("layer", 0)) != 0:
			keep.append(obstacle)
			continue
		var dist := float(obstacle.get("distance", 0.0)) + float(obstacle.get("move_offset", 0.0))
		if _is_distance_in_lava_platform_exclusion(dist) or _is_distance_in_lava_crossing_clear_zone(dist):
			var node := obstacle.get("node") as Node3D
			if node != null and is_instance_valid(node):
				node.queue_free()
			continue
		keep.append(obstacle)
	obstacles.clear()
	for o in keep:
		obstacles.append(o)
	_obstacle_scan_index = 0


## 熔岩过法互斥清理带：弹射 / 平台跳 / 侧墙 三选一，入口前不放滑铲跳跃等路面障碍
func _lava_crossing_clear_zones() -> Array:
	_ensure_mechanic_layout()
	var zones: Array = []
	# 弹射熔岩：缺口前到缺口内清空（垫板本身不占障碍槽）
	for gap in _open_gaps:
		if typeof(gap) != TYPE_DICTIONARY:
			continue
		if String(gap.get("kind", "")) != "launch":
			continue
		var start := float(gap.get("start", 0.0))
		var end := float(gap.get("end", start))
		zones.append(Vector2(start - 28.0, end + 2.0))
	for pad in _launch_pads:
		if typeof(pad) != TYPE_DICTIONARY:
			continue
		# 过熔岩弹射：大清空；纯加速垫：小清空
		var at := float(pad.get("distance", 0.0))
		if bool(pad.get("launch_cross", false)) or (bool(pad.get("lock_air_lane", true)) and not bool(pad.get("speed_boost", false))):
			zones.append(Vector2(at - 26.0, at + 6.0))
		else:
			zones.append(Vector2(at - 8.0, at + 4.0))
	# 侧墙熔岩：入口窗到坑尾
	for zone in _side_runway_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var zstart := float(zone.get("start", 0.0))
		var zlen := float(zone.get("length", 0.0))
		var entry := float(zone.get("entry_window", 10.0))
		zones.append(Vector2(zstart - entry - 4.0, zstart + zlen + 4.0))
	# 平台跳熔岩：沿用平台排除带
	for raw in _lava_platform_exclusion_zones():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var ex: Vector2 = raw.get("exclude", Vector2.ZERO)
		if ex.y > ex.x:
			zones.append(ex)
	return zones


func _is_distance_in_lava_crossing_clear_zone(distance: float) -> bool:
	for zone in _lava_crossing_clear_zones():
		var z: Vector2 = zone
		if distance >= z.x and distance <= z.y:
			return true
	return false


func _filter_orphan_platform_ramps(items: Array) -> Array:
	# 侧墙熔岩段不再保留仅供平台跳用的 ramp
	var side_centers: Array[float] = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if _main_block_cross_mode(item) != "side_wall":
			continue
		side_centers.append(float(item.get("distance", 0.0)))
	if side_centers.is_empty():
		return items
	var out: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			out.append(raw)
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "ramp":
			out.append(item)
			continue
		var dist := float(item.get("distance", 0.0))
		var drop := false
		for center in side_centers:
			if dist >= center - 36.0 and dist <= center + 2.0:
				drop = true
				break
		if not drop:
			out.append(item)
	return out


func _filter_obstacles_near_lava_crossings(items: Array) -> Array:
	var clear_zones := _lava_crossing_clear_zones()
	if clear_zones.is_empty():
		return items
	var out: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			out.append(raw)
			continue
		var item: Dictionary = raw
		var otype := String(item.get("type", ""))
		if otype in ["main_block", "ramp", "turn_left", "turn_right"]:
			out.append(item)
			continue
		if int(item.get("layer", 0)) != 0:
			out.append(item)
			continue
		var dist := float(item.get("distance", 0.0))
		var drop := false
		for zone in clear_zones:
			var z: Vector2 = zone
			if dist >= z.x and dist <= z.y:
				drop = true
				break
		if not drop:
			out.append(item)
	return out


func _generate_lava_platform_specs(pit: Vector2, center: float) -> Array:
	var specs: Array = []
	var step := _lava_platform_jump_spacing()
	var entry_hd := 0.92
	var exit_hd := 0.92
	var start := pit.x + entry_hd + 0.85
	var end := pit.y - exit_hd - 0.85
	var span := maxf(end - start, step * 2.4)
	var inner_count := clampi(int(floor(span / step)), 4, 8)
	var actual_step := span / float(inner_count + 1)
	var peak_idx := maxi(1, int(round(float(inner_count) * 0.55)))
	var lane_seq := [0, -1, 0, 1, 0, -1, 0, 1]
	specs.append({
		"distance": pit.x + entry_hd + 0.28,
		"lateral": 0.0,
		"surface_y": GROUND_Y + 0.06,
		"half_width": LANE_WIDTH * 0.78,
		"half_depth": entry_hd,
		"pit_center": center,
		"bridge": true,
	})
	for i in inner_count:
		var dist := start + actual_step * float(i + 1)
		var step_idx := i + 1
		var y_off := LAVA_PLATFORM_MIN_STEP_Y * float(step_idx if step_idx <= peak_idx else (inner_count - i))
		y_off = clampf(y_off, LAVA_PLATFORM_MIN_STEP_Y * 0.9, LAVA_PLATFORM_MAX_Y - GROUND_Y)
		var lane: int = int(lane_seq[i % lane_seq.size()])
		var lateral: float = float(lane) * LANE_WIDTH * (0.78 if lane != 0 else 0.0)
		specs.append({
			"distance": dist,
			"lateral": lateral,
			"surface_y": GROUND_Y + y_off,
			"half_width": LANE_WIDTH * (0.72 if lane == 0 else 0.66),
			"half_depth": 1.08,
			"pit_center": center,
		})
	specs.append({
		"distance": pit.y - exit_hd - 0.28,
		"lateral": 0.0,
		"surface_y": GROUND_Y + 0.06,
		"half_width": LANE_WIDTH * 0.78,
		"half_depth": exit_hd,
		"pit_center": center,
		"bridge": true,
	})
	return specs

func _prepare_lava_platforms_from_layout() -> void:
	_lava_platforms.clear()
	for raw in _layout_obstacle_items_raw():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		if int(item.get("layer", 0)) != 0:
			continue
		if _main_block_cross_mode(item) != "platform":
			continue
		var center := float(item.get("distance", 0.0))
		var half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		var pit := Vector2(center - half, center + half)
		for spec in _generate_lava_platform_specs(pit, center):
			_lava_platforms.append(spec)
	_ensure_mechanic_layout()
	var layout_id := _runner_layout_id()
	if layout_id != "":
		for raw in ObstacleLayout.load_root(layout_id).get("lift_pads", []):
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var pad: Dictionary = raw
			_lava_platforms.append({
				"distance": float(pad.get("distance", 0.0)),
				"lateral": float(pad.get("lateral", 0.0)),
				"base_y": float(pad.get("base_y", GROUND_Y + 0.2)),
				"surface_y": float(pad.get("base_y", GROUND_Y + 0.2)),
				"bob_amp": float(pad.get("amp", pad.get("bob_amp", 0.0))),
				"bob_period_m": float(pad.get("period_m", pad.get("bob_period_m", 32.0))),
				"bob_phase": float(pad.get("phase", pad.get("bob_phase", 0.0))),
				"half_width": float(pad.get("half_width", LANE_WIDTH * 0.68)),
				"half_depth": float(pad.get("half_depth", 1.32)),
				"bridge": bool(pad.get("bridge", false)),
				"lift": true,
			})

func _refresh_lava_platforms() -> void:
	if track_root != null:
		var old := track_root.get_node_or_null("LavaPlatformCrossing")
		if old != null:
			old.queue_free()
	_prepare_lava_platforms_from_layout()
	_spawn_lava_platform_visuals()

func _lava_platform_landing_y(feet_y: float, dist: float, lateral: float) -> float:
	var best := -999.0
	for raw in _lava_platforms:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var plat: Dictionary = raw
		var pd := float(plat.get("distance", 0.0))
		var hw := float(plat.get("half_width", LANE_WIDTH * 0.56))
		var hd := float(plat.get("half_depth", 1.08))
		if dist < pd - hd - 0.35 or dist > pd + hd + 0.42:
			continue
		if absf(lateral - float(plat.get("lateral", 0.0))) > hw + 0.26:
			continue
		var top := _lift_pad_surface_y(plat, dist)
		if feet_y <= top + 0.36 and feet_y >= top - 3.0:
			best = maxf(best, top)
	return best

func _lava_platform_surface_under_player() -> float:
	if player == null or _lava_platforms.is_empty():
		return -999.0
	return _lava_platform_landing_y(player.position.y + 0.04, track_distance, current_lateral)

func _lava_platform_road_material() -> Material:
	var kit: Dictionary = _road_style_kit if not _road_style_kit.is_empty() else _make_road_style_kit(_road_style_id)
	if kit.has("road") and kit.get("road") != null:
		return (kit.get("road") as Material).duplicate()
	if _road_style_id == "holographic":
		return _make_holographic_road_material()
	return _make_holographic_road_material()

func _lava_platform_side_material() -> StandardMaterial3D:
	# 与主路一致的深蓝，不发光，避免黄色/紫色镶边干扰
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.035, 0.07, 0.13)
	mat.metallic = 0.28
	mat.roughness = 0.62
	mat.emission_enabled = false
	var tex := _load_holographic_runway_texture(false)
	if tex:
		mat.albedo_texture = tex
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		mat.uv1_scale = Vector3(0.35, 0.35, 0.35)
	return mat

func _lava_platform_edge_material() -> StandardMaterial3D:
	return _lava_platform_side_material()

func _lava_platform_underside_material() -> StandardMaterial3D:
	var mat := _lava_platform_side_material().duplicate()
	mat.albedo_color = Color(0.025, 0.05, 0.09)
	return mat

func _attach_lava_platform_slab(
	parent: Node3D,
	dist: float,
	lateral: float,
	surface_y: float,
	hw: float,
	hd: float,
	road_mat: Material,
	line_mat: Material,
	curb_mat: Material
) -> void:
	var thickness := LAVA_PLATFORM_THICKNESS
	var deck_y := surface_y - 0.05
	var start_d := dist - hd
	var end_d := dist + hd
	var placed := _world_on_path(dist, lateral, surface_y)
	var holder := Node3D.new()
	holder.name = "LavaPlatformSlab"
	holder.position = placed["pos"]
	holder.rotation.y = float(placed["yaw"])
	parent.add_child(holder)
	var side_mat := _lava_platform_side_material()
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(hw * 2.0, thickness, hd * 2.0)
	body.mesh = body_mesh
	body.material_override = side_mat
	body.position = Vector3(0.0, -0.05 - thickness * 0.5, 0.0)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(body)
	var edge_mat: Material = _lava_platform_edge_material()
	for spec in [
		{"size": Vector3(hw * 2.06, thickness * 1.02, 0.11), "pos": Vector3(0.0, body.position.y, hd - 0.04)},
		{"size": Vector3(hw * 2.06, thickness * 1.02, 0.11), "pos": Vector3(0.0, body.position.y, -hd + 0.04)},
		{"size": Vector3(0.11, thickness * 1.02, hd * 2.06), "pos": Vector3(hw - 0.04, body.position.y, 0.0)},
		{"size": Vector3(0.11, thickness * 1.02, hd * 2.06), "pos": Vector3(-hw + 0.04, body.position.y, 0.0)},
	]:
		var rim := MeshInstance3D.new()
		var rim_mesh := BoxMesh.new()
		rim_mesh.size = spec["size"]
		rim.mesh = rim_mesh
		rim.material_override = edge_mat
		rim.position = spec["pos"]
		rim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		holder.add_child(rim)
	# 顶面：主路 strip（正确 UV）略高出板体
	_attach_path_strip_segment(start_d, end_d, hw, deck_y + 0.018, road_mat, 1.2, lateral)
	if line_mat != null:
		for lane_off in [-LANE_WIDTH * 0.5, LANE_WIDTH * 0.5]:
			if absf(lane_off) <= hw - 0.2:
				_attach_path_strip_segment(
					start_d, end_d, 0.055, deck_y + 0.032, line_mat, 1.2, lateral + lane_off
				)
	# 平台不用 curb 镶边（易变成黄/紫色块）
	# 底面封板
	var under_mat := _lava_platform_underside_material()
	_attach_path_strip_segment(start_d, end_d, hw * 0.96, deck_y - thickness + 0.06, under_mat, 1.2, lateral)

func _spawn_lava_platform_visuals() -> void:
	if _lava_platforms.is_empty() or track_root == null:
		return
	var root := Node3D.new()
	root.name = "LavaPlatformCrossing"
	track_root.add_child(root)
	var road_mat := _lava_platform_road_material()
	var kit: Dictionary = _road_style_kit if not _road_style_kit.is_empty() else _make_road_style_kit(_road_style_id)
	var line_mat: Material = kit.get("line", null)
	var curb_mat: Material = kit.get("curb", null)
	_lava_platform_visual_root = root
	for i in _lava_platforms.size():
		var plat: Dictionary = _lava_platforms[i]
		var dist := float(plat.get("distance", 0.0))
		var lateral := float(plat.get("lateral", 0.0))
		var surface_y := _lift_pad_surface_y(plat, dist)
		var hw := float(plat.get("half_width", LANE_WIDTH * 0.68))
		var hd := float(plat.get("half_depth", 1.32))
		if bool(plat.get("lift", false)):
			_attach_lift_pad_visual(root, plat, i)
			continue
		_attach_lava_platform_slab(root, dist, lateral, surface_y, hw, hd, road_mat, line_mat, curb_mat)
		if surface_y > GROUND_Y + 0.18:
			var support_mat := _lava_platform_side_material().duplicate()
			support_mat.albedo_color = Color(0.03, 0.06, 0.11, 0.5)
			support_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			var drop := surface_y - GROUND_Y
			var placed := _world_on_path(dist, lateral, surface_y)
			var holder := Node3D.new()
			holder.name = "LavaPlatformSupport_%d" % i
			holder.position = placed["pos"]
			holder.rotation.y = float(placed["yaw"])
			root.add_child(holder)
			var pillar := MeshInstance3D.new()
			var pillar_mesh := BoxMesh.new()
			pillar_mesh.size = Vector3(maxf(hw * 0.36, 0.55), maxf(drop, 0.25), maxf(hd * 0.42, 0.75))
			pillar.mesh = pillar_mesh
			pillar.material_override = support_mat
			pillar.position = Vector3(0.0, GROUND_Y - surface_y + drop * 0.5, 0.0)
			pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			holder.add_child(pillar)
		plat["node"] = root
	_lava_platform_visual_root = null

func _update_lava_platform_hint(delta: float) -> void:
	if _lava_platforms.is_empty() or is_failed or is_finished or not gameplay_active:
		return
	if _is_gate_lab_mission():
		return
	if track_layer != 0:
		return
	var show := false
	for raw in _lava_platforms:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var plat: Dictionary = raw
		var pd := float(plat.get("distance", 0.0))
		if track_distance >= pd - 16.0 and track_distance <= pd + 2.0:
			show = true
			break
	if show:
		_lava_platform_hint_timer = minf(_lava_platform_hint_timer + delta * 2.6, 1.0)
	else:
		_lava_platform_hint_timer = maxf(_lava_platform_hint_timer - delta * 3.0, 0.0)
	if _lava_platform_hint_timer > 0.08 and strike_toast_label:
		strike_toast_label.text = "熔岩平台 · 逐格跳上，高度渐升"
		strike_toast_label.modulate = Color(1.0, 0.72, 0.38, _lava_platform_hint_timer)
		strike_toast_timer = maxf(strike_toast_timer, 0.12)

func _try_trigger_launch_pads() -> void:
	if player == null or track_layer != 0 or _is_wall_running() or is_failed or is_finished:
		return
	_ensure_mechanic_layout()
	for pad in _launch_pads:
		var pid := String(pad.get("id", ""))
		var dist := float(pad.get("distance", 0.0))
		var hd := float(pad.get("half_depth", 1.6))
		if track_distance < dist - hd or track_distance > dist + hd:
			if track_distance > dist + hd + 8.0:
				_triggered_launch_ids.erase(pid)
			continue
		if _triggered_launch_ids.has(pid):
			continue
		var pad_lane := clampi(int(pad.get("lane", 0)), -1, 1)
		var pad_lat := float(pad_lane) * LANE_WIDTH
		if absf(current_lateral - pad_lat) > LANE_WIDTH * 0.58:
			continue
		var ground_y := _ground_y_at(track_distance)
		if player.position.y > ground_y + 0.55:
			continue
		_triggered_launch_ids[pid] = true
		var launch_cross := bool(pad.get("launch_cross", false))
		var speed_only := _pad_is_speed_only(pad)
		if speed_only:
			var burst_dist := PAD_BURST_DIST_RELAY if _is_relay_mission() else PAD_BURST_DIST
			var linger := PAD_LINGER_BOOST_TIME_RELAY if _is_relay_mission() else PAD_LINGER_BOOST_TIME
			_pad_burst_until_d = track_distance + burst_dist
			# 爆发后接一段加速靴余韵，体感更明显
			_speed_boost_timer = maxf(_speed_boost_timer, linger)
			_chaser_repulse(CHASER_BOOST_REPULSE * 0.85)
			_refresh_buff_hud()
			camera_shake = maxf(camera_shake, 0.24)
			_speed_feel_punch = maxf(_speed_feel_punch, 1.35)
			_hit_fov_punch = maxf(_hit_fov_punch, 0.48)
			if trail_particles:
				trail_particles.amount_ratio = 1.0
				trail_particles.speed_scale = 3.2
			_set_trail_color(Color(1.0, 0.82, 0.22, 1.0))
			var boost_hint := String(pad.get("hint", "")).strip_edges()
			if boost_hint == "":
				boost_hint = "Speed Pad · Burst"
			_show_gate_toast(boost_hint)
			continue
		vertical_velocity = maxf(vertical_velocity, float(pad.get("impulse", JUMP_SPEED * 1.45)))
		_pit_fall_grace = maxf(_pit_fall_grace, 1.35)
		_set_lane(pad_lane + 1)
		current_lateral = lerpf(current_lateral, pad_lat, 0.55)
		if bool(pad.get("lock_air_lane", true)):
			_launch_air_lock_until_d = track_distance + float(pad.get("lock_distance", 28.0))
		if bool(pad.get("speed_boost", false)):
			_speed_boost_timer = maxf(_speed_boost_timer, float(pad.get("boost_time", 2.4)))
			_chaser_repulse(CHASER_BOOST_REPULSE * 0.7)
			_refresh_buff_hud()
		camera_shake = maxf(camera_shake, 0.16)
		var hint := String(pad.get("hint", "")).strip_edges()
		if hint == "":
			hint = "弹射"
		_show_gate_toast(hint)

func _update_lift_pad_visuals() -> void:
	if _lava_platforms.is_empty():
		return
	for raw in _lava_platforms:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var plat: Dictionary = raw
		if not bool(plat.get("lift", false)):
			continue
		var holder := plat.get("holder") as Node3D
		if holder == null or not is_instance_valid(holder):
			continue
		var dist := float(plat.get("distance", 0.0))
		var lateral := float(plat.get("lateral", 0.0))
		var surface_y := _lift_pad_surface_y(plat)
		var placed := _world_on_path(dist, lateral, surface_y)
		holder.position = placed["pos"]
		holder.rotation.y = float(placed["yaw"])

func _update_mechanic_lab_hints() -> void:
	if not _is_gate_lab_mission() or is_failed or is_finished or not gameplay_active:
		return
	var hints: Array[Dictionary] = [
		{"d": 62.0, "text": "前方橙色垫 · 跑上去就飞，不用跳也不用换道"},
		{"d": 186.0, "text": "平台跳跃 · 逐格跳过去，不用等"},
		{"d": 276.0, "text": "紫色球会上下漂 · 跳过或换道躲开"},
		{"d": 292.0, "text": "缓坡来了 · 跟着路面爬升，不用跳"},
		{"d": 508.0, "text": "窄梁 · 回到中间道，别掉下去"},
		{"d": 616.0, "text": "再踩橙色垫 · 跑上去就飞上高架"},
		{"d": 688.0, "text": "高架 U 弯 · 跟着路水平掉头"},
	]
	for hint in hints:
		var key := String(hint.get("text", ""))
		var at := float(hint.get("d", 0.0))
		if _mechanic_hint_warned.has(key):
			continue
		if track_distance >= at and track_distance <= at + 18.0:
			_mechanic_hint_warned[key] = true
			_show_gate_toast(key)

func _update_launch_pad_approach_hints() -> void:
	if is_failed or is_finished or not gameplay_active:
		return
	_ensure_mechanic_layout()
	for pad in _launch_pads:
		var pid := "approach_%s" % String(pad.get("id", ""))
		if _mechanic_hint_warned.has(pid):
			continue
		var dist := float(pad.get("distance", 0.0))
		if track_distance < dist - 24.0 or track_distance > dist - 3.0:
			continue
		_mechanic_hint_warned[pid] = true
		var lane := clampi(int(pad.get("lane", 0)), -1, 1)
		var side := "左道" if lane < 0 else ("右道" if lane > 0 else "中道")
		var hint := String(pad.get("hint", "")).strip_edges()
		if hint == "":
			hint = "%s弹射垫 · 换到%s踩上去" % [side, side]
		_show_gate_toast(hint)

func _attach_lift_pad_visual(parent: Node3D, plat: Dictionary, index: int) -> void:
	var dist := float(plat.get("distance", 0.0))
	var lateral := float(plat.get("lateral", 0.0))
	var surface_y := _lift_pad_surface_y(plat, dist)
	var hw := float(plat.get("half_width", LANE_WIDTH * 0.68))
	var hd := float(plat.get("half_depth", 1.32))
	var placed := _world_on_path(dist, lateral, surface_y)
	var holder := Node3D.new()
	holder.name = "LiftPad_%d" % index
	holder.position = placed["pos"]
	holder.rotation.y = float(placed["yaw"])
	parent.add_child(holder)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.42, 0.48)
	mat.metallic = 0.35
	mat.roughness = 0.38
	mat.emission_enabled = true
	mat.emission = Color(0.18, 0.78, 0.86)
	mat.emission_energy_multiplier = 0.85 if float(plat.get("bob_amp", 0.0)) > 0.01 else 0.42
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(hw * 2.0, 0.22, hd * 2.0)
	body.mesh = mesh
	body.material_override = mat
	body.position = Vector3(0.0, -0.11, 0.0)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(body)
	plat["holder"] = holder
	_lava_platforms[index] = plat

func _launch_pad_surface_text(pad: Dictionary) -> String:
	var custom := String(pad.get("pad_text", "")).strip_edges()
	if custom != "":
		return custom
	if _pad_is_speed_only(pad):
		return "SPEEDUP"
	return "LAUNCH"


func _make_launch_pad_material(albedo: Color, emission: Color, energy: float, metallic: float = 0.42, roughness: float = 0.28) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.metallic = metallic
	mat.roughness = roughness
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = energy
	return mat


func _attach_launch_pad_box(parent: Node3D, size: Vector3, pos: Vector3, mat: Material) -> void:
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	body.mesh = mesh
	body.material_override = mat
	body.position = pos
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(body)


func _attach_launch_pad_visual(root: Node3D, pad: Dictionary) -> void:
	# 过熔岩弹射：青白；纯加速：琥珀金，避免误认成弹射
	var dist := float(pad.get("distance", 0.0))
	var hd := float(pad.get("half_depth", 1.6))
	var pad_lane := clampi(int(pad.get("lane", 0)), -1, 1)
	var pad_lat := float(pad_lane) * LANE_WIDTH
	var hw := LANE_WIDTH * 0.88
	var placed := _world_on_path(dist, pad_lat, _ground_y_at(dist) + 0.05)
	var holder := Node3D.new()
	holder.name = "LaunchPad"
	holder.position = placed["pos"]
	holder.rotation.y = float(placed["yaw"])
	root.add_child(holder)
	var speed_only := _pad_is_speed_only(pad)
	var base_mat: StandardMaterial3D
	var glow_mat: StandardMaterial3D
	var rim_mat: StandardMaterial3D
	var arrow_mat: StandardMaterial3D
	if speed_only:
		base_mat = _make_launch_pad_material(Color(0.14, 0.08, 0.02), Color(0.7, 0.38, 0.06), 0.85, 0.4, 0.42)
		glow_mat = _make_launch_pad_material(Color(1.0, 0.62, 0.12), Color(1.0, 0.72, 0.18), 2.6, 0.1, 0.18)
		rim_mat = _make_launch_pad_material(Color(1.0, 0.9, 0.55), Color(1.0, 0.8, 0.3), 1.9, 0.08, 0.2)
		arrow_mat = _make_launch_pad_material(Color(1.0, 0.95, 0.55), Color(1.0, 0.78, 0.15), 2.0, 0.05, 0.18)
		hw = LANE_WIDTH * 0.72
	else:
		base_mat = _make_launch_pad_material(Color(0.05, 0.10, 0.16), Color(0.08, 0.42, 0.55), 0.55, 0.55, 0.38)
		glow_mat = _make_launch_pad_material(Color(0.18, 0.82, 0.95), Color(0.22, 0.92, 1.0), 2.15, 0.12, 0.18)
		rim_mat = _make_launch_pad_material(Color(0.95, 0.98, 1.0), Color(0.75, 0.95, 1.0), 1.8, 0.08, 0.22)
		arrow_mat = _make_launch_pad_material(Color(1.0, 0.96, 0.72), Color(1.0, 0.82, 0.28), 1.65, 0.05, 0.2)
		hw = LANE_WIDTH * 0.92
	_attach_launch_pad_box(holder, Vector3(hw * 2.0, 0.20, hd * 2.0), Vector3(0.0, 0.02, 0.0), base_mat)
	_attach_launch_pad_box(holder, Vector3(hw * 1.62, 0.05, hd * 1.58), Vector3(0.0, 0.13, 0.0), glow_mat)
	_attach_launch_pad_box(holder, Vector3(0.08, 0.10, hd * 2.02), Vector3(-hw + 0.05, 0.10, 0.0), rim_mat)
	_attach_launch_pad_box(holder, Vector3(0.08, 0.10, hd * 2.02), Vector3(hw - 0.05, 0.10, 0.0), rim_mat)
	_attach_launch_pad_box(holder, Vector3(hw * 2.02, 0.10, 0.08), Vector3(0.0, 0.10, -hd + 0.05), rim_mat)
	_attach_launch_pad_box(holder, Vector3(hw * 2.02, 0.10, 0.08), Vector3(0.0, 0.10, hd - 0.05), rim_mat)
	for i in 3:
		var z := -hd * 0.42 + float(i) * (hd * 0.38)
		_attach_launch_pad_box(holder, Vector3(0.42 - float(i) * 0.06, 0.05, 0.22), Vector3(0.0, 0.17, z), arrow_mat)
	var en := _launch_pad_surface_text(pad)
	if en in ["", "SPEEDUP", "LAUNCH"]:
		en = "SPEEDUP" if speed_only else "LAUNCH"
	# 全据点规则：仅加速垫/弹射垫保留世界字标；上方与垫面只用英文名
	var face_bg := MeshInstance3D.new()
	var face_bg_mesh := BoxMesh.new()
	face_bg_mesh.size = Vector3(hw * 1.35, 0.04, 0.72)
	var face_bg_mat := StandardMaterial3D.new()
	face_bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	face_bg_mat.albedo_color = Color(0.02, 0.03, 0.06, 0.82) if not speed_only else Color(0.12, 0.05, 0.01, 0.85)
	face_bg_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	face_bg.mesh = face_bg_mesh
	face_bg.material_override = face_bg_mat
	face_bg.position = Vector3(0.0, 0.19, hd * 0.12)
	face_bg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	holder.add_child(face_bg)
	var face := Label3D.new()
	face.text = en
	face.font_size = 64
	face.pixel_size = 0.016
	face.modulate = Color(1.0, 0.92, 0.35) if speed_only else Color(0.75, 0.98, 1.0)
	face.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)
	face.outline_size = 18
	face.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	face.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	face.position = Vector3(0.0, 0.24, hd * 0.12)
	face.rotation_degrees = Vector3(-90.0, 180.0, 0.0)
	face.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	holder.add_child(face)
	# 悬浮标牌：始终朝向镜头
	var hover := Label3D.new()
	hover.text = en
	hover.modulate = Color(1.0, 0.9, 0.28) if speed_only else Color(0.55, 0.96, 1.0)
	hover.font_size = 72
	hover.pixel_size = 0.012
	hover.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)
	hover.outline_size = 22
	hover.position = Vector3(0.0, 1.75, 0.0)
	hover.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	holder.add_child(hover)
	var hover_sub := Label3D.new()
	hover_sub.text = "Step to boost" if speed_only else "Step to launch"
	hover_sub.modulate = Color(1.0, 0.95, 0.75) if speed_only else Color(0.85, 0.95, 1.0)
	hover_sub.font_size = 36
	hover_sub.pixel_size = 0.011
	hover_sub.outline_modulate = Color(0.0, 0.0, 0.0, 1.0)
	hover_sub.outline_size = 14
	hover_sub.position = Vector3(0.0, 1.35, 0.0)
	hover_sub.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	holder.add_child(hover_sub)


func _attach_launch_gap_broken_edges(pit: Vector2) -> void:
	var lane_y := GROUND_Y + 0.04
	var kit: Dictionary = _road_style_kit if not _road_style_kit.is_empty() else {}
	var road_mat: Material = kit.get("road", _make_holographic_road_material())
	var offsets: Array[Dictionary] = [
		{"d": pit.x + 0.55, "lat": -2.4, "yaw": 0.22, "size": Vector3(1.35, 0.16, 1.05)},
		{"d": pit.x + 1.15, "lat": 2.1, "yaw": -0.28, "size": Vector3(1.15, 0.14, 0.92)},
		{"d": pit.y - 0.85, "lat": -1.8, "yaw": 0.18, "size": Vector3(1.25, 0.15, 0.88)},
		{"d": pit.y - 1.35, "lat": 2.35, "yaw": -0.24, "size": Vector3(1.05, 0.13, 0.78)},
	]
	for raw in offsets:
		var spec: Dictionary = raw
		var placed := _world_on_path(float(spec.get("d", 0.0)), float(spec.get("lat", 0.0)), lane_y)
		var slab := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = spec.get("size", Vector3(1.1, 0.14, 0.9))
		slab.mesh = mesh
		slab.material_override = road_mat
		slab.position = placed["pos"]
		slab.rotation.y = float(placed["yaw"]) + float(spec.get("yaw", 0.0))
		slab.rotation.z = 0.18 if float(spec.get("lat", 0.0)) > 0.0 else -0.16
		slab.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		track_root.add_child(slab)


func _spawn_mechanic_lab_visuals() -> void:
	_ensure_mechanic_layout()
	if track_root == null:
		return
	var old := track_root.get_node_or_null("MechanicLabVisuals")
	if old != null:
		old.queue_free()
	var root := Node3D.new()
	root.name = "MechanicLabVisuals"
	track_root.add_child(root)
	for pad in _launch_pads:
		_attach_launch_pad_visual(root, pad)
	for zone in _width_zones:
		var start := float(zone.get("start", 0.0))
		var end := start + float(zone.get("length", 0.0))
		var hw := float(zone.get("half_width", 1.25))
		var kit: Dictionary = _road_style_kit if not _road_style_kit.is_empty() else _make_road_style_kit(_road_style_id)
		var road_mat: Material = kit.get("road", _make_holographic_road_material())
		var edge_mat := StandardMaterial3D.new()
		edge_mat.albedo_color = Color(0.95, 0.78, 0.22)
		edge_mat.emission_enabled = true
		edge_mat.emission = Color(1.0, 0.82, 0.28)
		edge_mat.emission_energy_multiplier = 0.9
		_attach_path_strip_segment(start, end, hw, GROUND_Y - 0.02, road_mat, 1.1, 0.0)
		_attach_path_strip_segment(start, end, 0.07, GROUND_Y + 0.03, edge_mat, 1.1, hw - 0.05)
		_attach_path_strip_segment(start, end, 0.07, GROUND_Y + 0.03, edge_mat, 1.1, -(hw - 0.05))

func _main_block_pit_uses_platforms(pit: Vector2) -> bool:
	var mid := (pit.x + pit.y) * 0.5
	_ensure_mechanic_layout()
	if _open_gap_kind_at(mid) == "lifts":
		return true
	if _open_gap_kind_at(mid) in ["launch", "beam"]:
		return false
	for raw in _layout_obstacle_items_raw():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		if String(item.get("type", "")) != "main_block":
			continue
		var center := float(item.get("distance", 0.0))
		var half := float(item.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		if mid >= center - half - 0.5 and mid <= center + half + 0.5:
			return _main_block_cross_mode(item) == "platform"
	return _layout_lava_cross_mode() == "platform"

func _is_on_fork_branch_road(distance: float) -> bool:
	# 岔路分支仍用主路径 distance，但角色不在主路坑/侧墙坑上
	if _y_fork_side_at(distance) != 0:
		return true
	if _fork_side != 0 and not _junction_fork_region_at(distance).is_empty():
		return true
	return false

func _is_in_side_runway_pit(distance: float) -> bool:
	if _is_on_fork_branch_road(distance):
		return false
	for zone in _side_runway_zones():
		var pit: Vector2 = _side_runway_pit_range(zone)
		if distance >= pit.x and distance <= pit.y:
			return true
	return false

func _attach_side_runway_pit(zone: Dictionary, kit: Dictionary) -> void:
	var pit: Vector2 = _side_runway_pit_range(zone)
	_attach_path_pit_visual(pit, kit, "SideRunwayPit")

func _attach_main_block_path_pit(pit: Vector2, kit: Dictionary) -> void:
	_attach_path_pit_visual(pit, kit, "MainBlockPathPit")

func _make_pit_lava_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = PIT_LAVA_SHADER
	mat.set_shader_parameter("lava_deep", Color(0.05, 0.01, 0.0))
	mat.set_shader_parameter("lava_hot", Color(0.82, 0.2, 0.02))
	mat.set_shader_parameter("lava_bright", Color(0.95, 0.58, 0.1))
	mat.set_shader_parameter("scroll_speed", 0.52)
	mat.set_shader_parameter("crack_scale", 13.0)
	mat.set_shader_parameter("bubble_strength", 0.95)
	mat.set_shader_parameter("emission_boost", 0.78)
	return mat

func _attach_path_pit_visual(pit: Vector2, kit: Dictionary, node_name: String) -> void:
	if pit.y <= pit.x + 2.0:
		return
	var lane_y := GROUND_Y - 0.05
	var curb_mat: Material = kit.get("curb", kit.get("road", null))
	# 深渊底层：盖住沙漠橙地面，做成真正「往下掉」的视觉
	var abyss_mat := _make_material(Color(0.012, 0.01, 0.018), Color(0.05, 0.02, 0.01), 0.15)
	_attach_path_strip_segment(pit.x, pit.y, 8.4, lane_y - 4.6, abyss_mat, 1.8, 0.0)
	_attach_path_strip_segment(pit.x, pit.y, 7.8, lane_y - 2.6, abyss_mat, 1.8, 0.0)
	# 熔岩面抬到坑口附近，路面缺口里一眼能看见岩浆
	var lava_mat := _make_pit_lava_material()
	_attach_path_strip_segment(pit.x + 0.25, pit.y - 0.25, 6.8, lane_y - 1.05, lava_mat, 1.6, 0.0)
	_attach_path_strip_segment(pit.x + 0.7, pit.y - 0.7, 5.2, lane_y - 0.62, lava_mat, 1.6, 0.0)
	var platform_pit := _main_block_pit_uses_platforms(pit)
	var rim_mat := _make_material(Color(0.62, 0.18, 0.05, 0.72), Color(1.0, 0.38, 0.08), 1.55)
	rim_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rim_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_attach_path_strip_segment(pit.x - 0.2, pit.x + 1.6, 6.6, lane_y + 0.03, rim_mat, 1.2, 0.0)
	_attach_path_strip_segment(pit.y - 1.6, pit.y + 0.2, 6.6, lane_y + 0.03, rim_mat, 1.2, 0.0)
	if not platform_pit:
		var char_mat := _make_material(Color(0.04, 0.03, 0.035), Color(0.35, 0.08, 0.02), 0.55)
		_attach_path_strip_segment(pit.x - 0.4, pit.x + 1.2, 7.0, lane_y + 0.02, char_mat, 1.2, 0.0)
		_attach_path_strip_segment(pit.y - 1.2, pit.y + 0.4, 7.0, lane_y + 0.02, char_mat, 1.2, 0.0)
		_attach_path_strip_segment(pit.x, pit.y, 7.8, lane_y - 0.08, char_mat, 1.8, 0.0)
	if curb_mat and not platform_pit:
		_attach_path_strip_segment(pit.x - 0.9, pit.x + 0.5, 6.2, lane_y + 0.05, curb_mat, 1.2, 0.0)
		_attach_path_strip_segment(pit.y - 0.5, pit.y + 0.9, 6.2, lane_y + 0.05, curb_mat, 1.2, 0.0)
	if not platform_pit:
		var glow_mat := _make_material(Color(0.85, 0.22, 0.04, 0.22), Color(0.9, 0.32, 0.04), 1.55)
		glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		_attach_path_strip_segment(pit.x + 0.2, pit.y - 0.2, 7.1, lane_y + 0.04, glow_mat, 2.0, 0.0)
	_attach_pit_lava_embers(pit)
	var mid := (pit.x + pit.y) * 0.5
	if _open_gap_kind_at(mid) == "launch":
		_attach_launch_gap_broken_edges(pit)

func _attach_pit_lava_embers(pit: Vector2) -> void:
	var mid := (pit.x + pit.y) * 0.5
	var sample := _sample_path(mid)
	var anchor := sample["pos"] as Vector3
	anchor.y = GROUND_Y - 0.55
	var particles := GPUParticles3D.new()
	particles.name = "PitLavaEmbers"
	particles.amount = 28
	particles.lifetime = 1.45
	particles.preprocess = 0.45
	particles.visibility_aabb = AABB(Vector3(-10, -2, -10), Vector3(20, 12, 20))
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(2.8, 0.15, maxf((pit.y - pit.x) * 0.28, 3.0))
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 28.0
	mat.initial_velocity_min = 0.45
	mat.initial_velocity_max = 2.1
	mat.gravity = Vector3(0.0, 0.85, 0.0)
	mat.scale_min = 0.08
	mat.scale_max = 0.28
	mat.color = Color(1.0, 0.42, 0.08, 0.75)
	particles.process_material = mat
	var draw := SphereMesh.new()
	draw.radius = 0.07
	draw.height = 0.14
	var draw_mat := StandardMaterial3D.new()
	draw_mat.albedo_color = Color(1.0, 0.45, 0.1, 0.72)
	draw_mat.emission_enabled = true
	draw_mat.emission = Color(0.95, 0.32, 0.04)
	draw_mat.emission_energy_multiplier = 1.55
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw.material = draw_mat
	particles.draw_pass_1 = draw
	particles.position = anchor
	particles.rotation.y = float(sample["yaw"])
	track_root.add_child(particles)

	# 更大更慢的冒泡球，强化岩浆液面感
	var bubbles := GPUParticles3D.new()
	bubbles.name = "PitLavaBubbles"
	bubbles.amount = 16
	bubbles.lifetime = 2.1
	bubbles.preprocess = 0.8
	bubbles.visibility_aabb = AABB(Vector3(-10, -2, -10), Vector3(20, 10, 20))
	var bmat := ParticleProcessMaterial.new()
	bmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	bmat.emission_box_extents = Vector3(2.4, 0.08, maxf((pit.y - pit.x) * 0.24, 2.6))
	bmat.direction = Vector3(0.0, 1.0, 0.0)
	bmat.spread = 12.0
	bmat.initial_velocity_min = 0.2
	bmat.initial_velocity_max = 0.85
	bmat.gravity = Vector3(0.0, 0.35, 0.0)
	bmat.scale_min = 0.35
	bmat.scale_max = 1.1
	bmat.color = Color(1.0, 0.55, 0.12, 0.45)
	bubbles.process_material = bmat
	var bdraw := SphereMesh.new()
	bdraw.radius = 0.12
	bdraw.height = 0.24
	var bdraw_mat := StandardMaterial3D.new()
	bdraw_mat.albedo_color = Color(1.0, 0.5, 0.1, 0.4)
	bdraw_mat.emission_enabled = true
	bdraw_mat.emission = Color(0.9, 0.35, 0.05)
	bdraw_mat.emission_energy_multiplier = 1.2
	bdraw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bdraw.material = bdraw_mat
	bubbles.draw_pass_1 = bdraw
	bubbles.position = anchor + Vector3(0.0, 0.12, 0.0)
	bubbles.rotation.y = float(sample["yaw"])
	track_root.add_child(bubbles)

func _attach_wall_run_mesh(zone: Dictionary, kit: Dictionary) -> void:
	var start := float(zone["start"])
	var entry := float(zone.get("entry_window", 10.0))
	var end_d := start + float(zone.get("length", 70.0))
	# 入口窗就开始铺墙，和可吸附区间对齐，避免先跳上却看不见墙
	var mesh_start := start - entry
	var side := _wall_zone_side(zone)
	var offset := _effective_wall_lateral_offset(zone)
	var step := 1.75
	var slices: Array[Dictionary] = []
	var d := mesh_start
	while d < end_d - 0.001:
		slices.append(_wall_run_slice(d, side, offset))
		d += step
	slices.append(_wall_run_slice(end_d, side, offset))
	if slices.size() < 2:
		return

	# 侧墙跑面 = 水平全息跑道的 90° 弯折段，共用同一套路面材质
	var road_mat: Material = _make_wall_run_face_material(kit)
	var line_mat: Material = kit.get("line", kit.get("curb", road_mat))
	var uv_scale := WALL_RUN_UV_SCALE

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(slices.size() - 1):
		var a: Dictionary = slices[i]
		var b: Dictionary = slices[i + 1]
		var da := float(a.get("distance", mesh_start + float(i) * step))
		var db := float(b.get("distance", da + step))
		var u_a := da * uv_scale
		var u_b := db * uv_scale
		var v_bot := 0.0
		var v_top := WALL_FACE_HEIGHT * uv_scale
		# 朝向主路的立面（跑墙面）——与主路同纹理走向
		_add_wall_quad_uv(
			st,
			a["inner_bottom"], b["inner_bottom"], b["inner_top"], a["inner_top"],
			Vector2(u_a, v_bot), Vector2(u_b, v_bot), Vector2(u_b, v_top), Vector2(u_a, v_top)
		)
		# 外侧/back 面
		_add_wall_quad(st, a["outer_bottom"], a["outer_top"], b["outer_top"], b["outer_bottom"])
		# 顶边
		_add_wall_quad(st, a["inner_top"], b["inner_top"], b["outer_top"], a["outer_top"])
	var mesh := st.commit()
	if mesh != null:
		var mi := MeshInstance3D.new()
		mi.name = "WallRunFace"
		mi.mesh = mesh
		mi.material_override = road_mat
		_attach_road(mi)

	# 三列高度分隔线（与主路 lane line 同材质）
	for h in WALL_LANE_HEIGHTS:
		_attach_wall_lane_rail(mesh_start, end_d, side, offset, h, line_mat, step)

	# 上下路缘条（与主路 curb 一致，避免侧墙像另一套橙色贴图）
	var curb_mat: Material = kit.get("curb", road_mat)
	if curb_mat != null:
		_attach_wall_lane_rail(mesh_start, end_d, side, offset, 0.14, curb_mat, step)
		_attach_wall_lane_rail(mesh_start, end_d, side, offset, WALL_FACE_HEIGHT - 0.12, curb_mat, step)

	_attach_wall_edge_soft_glow(slices, side)

func _attach_wall_run_entry_ramp(zone: Dictionary, kit: Dictionary) -> void:
	# 水平路缘 → 侧墙立面的连续弯折，避免「地面一条、墙上另一条」
	var road_mat: Material = _make_wall_run_face_material(kit)
	if road_mat == null:
		return
	var start := float(zone["start"])
	var entry := float(zone.get("entry_window", 10.0))
	var ramp_start := start - entry
	var ramp_end := start + 5.0
	var side := _wall_zone_side(zone)
	var offset := _effective_wall_lateral_offset(zone)
	var road_half := _wall_run_road_half()
	var lane_y := GROUND_Y - 0.05
	var inner_lat := _wall_inner_face_lateral(side, offset)
	var edge_lat := side * road_half
	var steps := 9
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var prev: Array[Vector3] = []
	for si in range(steps + 1):
		var t := float(si) / float(steps)
		var d := lerpf(ramp_start, ramp_end, t)
		var sample := _sample_path(d)
		var right: Vector3 = sample["right"]
		var bend := smoothstep(0.0, 1.0, t)
		var center_lat := lerpf(edge_lat, inner_lat, bend)
		var strip_half := lerpf(road_half * 0.42, road_half * 0.34, bend)
		var y_base := lerpf(lane_y, lane_y + 0.04, bend)
		var rise := bend * bend * 1.15
		var center: Vector3 = sample["pos"] + right * center_lat
		center.y = y_base + rise
		var tangent := right * strip_half
		var v0 := center - tangent
		var v1 := center + tangent
		var lift := Vector3(0.0, 0.06 + bend * 0.12, 0.0)
		v0 += lift
		v1 += lift
		if si > 0:
			_add_wall_quad(st, prev[0], prev[1], v1, v0)
		prev = [v0, v1]
	var ramp_mesh := st.commit()
	if ramp_mesh == null:
		return
	var ramp_mi := MeshInstance3D.new()
	ramp_mi.name = "WallRunEntryRamp"
	ramp_mi.mesh = ramp_mesh
	ramp_mi.material_override = road_mat
	ramp_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(ramp_mi)
	# 入口前：路缘外肩仍铺同材质窄条，视觉上接进主路
	var shoulder_bias := edge_lat + side * 0.55
	var curb_mat: Material = kit.get("curb", road_mat)
	if curb_mat != null:
		_attach_path_strip_segment(ramp_start, start + 2.0, road_half * 0.09, lane_y + 0.018, curb_mat, 1.6, edge_lat + side * 0.48)
	_attach_path_strip_segment(ramp_start, start + 2.0, road_half * 0.38, lane_y + 0.004, road_mat, 1.6, shoulder_bias)

func _attach_wall_run_exit_ramp(zone: Dictionary, kit: Dictionary) -> void:
	# 侧墙末端弯回水平路缘，与入口 ramp 对称
	var road_mat: Material = _make_wall_run_face_material(kit)
	if road_mat == null:
		return
	var start := float(zone["start"])
	var end_d := start + float(zone.get("length", 70.0))
	var exit_window := float(zone.get("entry_window", 10.0)) * 0.55
	var ramp_start := end_d - 5.0
	var ramp_end := end_d + exit_window
	var side := _wall_zone_side(zone)
	var offset := _effective_wall_lateral_offset(zone)
	var road_half := _wall_run_road_half()
	var lane_y := GROUND_Y - 0.05
	var inner_lat := _wall_inner_face_lateral(side, offset)
	var edge_lat := side * road_half
	var steps := 9
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var prev: Array[Vector3] = []
	for si in range(steps + 1):
		var t := float(si) / float(steps)
		var d := lerpf(ramp_start, ramp_end, t)
		var sample := _sample_path(d)
		var right: Vector3 = sample["right"]
		var bend := smoothstep(0.0, 1.0, t)
		var center_lat := lerpf(inner_lat, edge_lat, bend)
		var strip_half := lerpf(road_half * 0.34, road_half * 0.42, bend)
		var y_base := lerpf(lane_y + 0.04, lane_y, bend)
		var rise := (1.0 - bend) * (1.0 - bend) * 1.15
		var center: Vector3 = sample["pos"] + right * center_lat
		center.y = y_base + rise
		var tangent := right * strip_half
		var v0 := center - tangent
		var v1 := center + tangent
		var lift := Vector3(0.0, 0.06 + (1.0 - bend) * 0.12, 0.0)
		v0 += lift
		v1 += lift
		if si > 0:
			_add_wall_quad(st, prev[0], prev[1], v1, v0)
		prev = [v0, v1]
	var ramp_mesh := st.commit()
	if ramp_mesh == null:
		return
	var ramp_mi := MeshInstance3D.new()
	ramp_mi.name = "WallRunExitRamp"
	ramp_mi.mesh = ramp_mesh
	ramp_mi.material_override = road_mat
	ramp_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(ramp_mi)
	var curb_mat: Material = kit.get("curb", road_mat)
	if curb_mat != null:
		_attach_path_strip_segment(end_d - 2.0, ramp_end, road_half * 0.09, lane_y + 0.018, curb_mat, 1.6, edge_lat + side * 0.48)

func _ensure_side_dressing_root() -> void:
	if _side_dressing_root != null and is_instance_valid(_side_dressing_root):
		return
	_side_dressing_root = Node3D.new()
	_side_dressing_root.name = "MidgroundDressing"
	track_root.add_child(_side_dressing_root)

func _side_runway_anchor_prop_paths() -> Array[String]:
	match _runner_visual_batch():
		"crisis":
			return [
				OBSTACLE_PROP_MEDICAL_CRATE,
				OBSTACLE_PROP_BROKEN_DRONE,
				OBSTACLE_PROP_MEDICAL_POD,
				OBSTACLE_PROP_EXCAVATOR,
			]
		"relay":
			return [OBSTACLE_PROP_RELAY_DRONE, OBSTACLE_PROP_METEORITE, OBSTACLE_PROP_BROKEN_DRONE]
		_:
			return [
				OBSTACLE_PROP_MEDICAL_CRATE,
				OBSTACLE_PROP_BROKEN_DRONE,
				OBSTACLE_PROP_METEORITE,
				SIDE_RUNWAY_ANCHOR_EXCAVATOR,
				SIDE_RUNWAY_ANCHOR_CORAL,
			]

func _side_runway_pit_monolith_paths() -> Array[String]:
	return [
		SIDE_RUNWAY_ANCHOR_CORAL,
		SIDE_RUNWAY_ANCHOR_METEORITE,
		SIDE_RUNWAY_ANCHOR_EXCAVATOR,
	]

func _attach_side_runway_pit_monolith(zone: Dictionary) -> void:
	# 熔岩坑正中：巨型水晶树 / 陨石 / 塔，封死主路视觉，逼迫上侧墙
	var pit: Vector2 = _side_runway_pit_range(zone)
	if pit.y <= pit.x + 10.0:
		return
	_ensure_side_dressing_root()
	var mid_d := (pit.x + pit.y) * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = int(mid_d * 29.0 + float(zone.get("start", 0.0)))
	var paths := _side_runway_pit_monolith_paths()
	var path := paths[rng.randi() % paths.size()]
	var scene := _load_runner_scene(path, false)
	if scene == null:
		return
	var root := Node3D.new()
	root.name = "SideRunwayPitMonolith_%d" % int(mid_d)
	_side_dressing_root.add_child(root)
	var placed := _world_on_path(mid_d, 0.0, GROUND_Y - 0.8)
	root.position = placed["pos"]
	root.position.y = GROUND_Y - 0.72
	root.rotation.y = float(placed["yaw"]) + rng.randf_range(-0.35, 0.35)
	var lower := path.to_lower()
	var target_h := 6.2 if "coral" in lower else (5.4 if "meteorite" in lower else 5.0)
	var footprint := clampf(target_h * 1.05, 5.5, 9.5)
	var model := _add_scaled_model_visual(
		root,
		scene,
		"PitMonolithModel",
		target_h,
		rng.randf_range(-22.0, 22.0),
		Vector3.ZERO,
		footprint,
		footprint * 1.15
	)
	if model != null:
		_preserve_midground_materials(root)
		if _is_midground_meteorite(path):
			_apply_midground_meteorite_variant(root, _pick_meteorite_palette(rng, mid_d, 0.0))
		_disable_mesh_shadows(root)
	# 坑缘两侧小碎石（纯装饰，在熔岩里）
	for flank_i in 2:
		var flank_d := mid_d + (float(flank_i) - 0.5) * (pit.y - pit.x) * 0.38
		var flank_lat := (1.15 if flank_i == 0 else -1.15)
		_spawn_side_runway_dressing_prop(
			flank_d, flank_lat, GROUND_Y - 1.05, OBSTACLE_PROP_METEORITE, 1.55, rng
		)

func _attach_side_runway_zone_anchors(zone: Dictionary) -> void:
	# 侧墙起止：仅在坑外缘放小型标识，不在侧墙跑道上放大道具
	_ensure_side_dressing_root()
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 70.0))
	var end_d := start + length
	var side := _wall_zone_side(zone)
	var offset := _effective_wall_lateral_offset(zone)
	var paths := _side_runway_anchor_prop_paths()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(start * 19.0 + side * 733.0)
	var fore_lat := side * (offset + 3.75)
	var pit: Vector2 = _side_runway_pit_range(zone)
	_spawn_side_runway_anchor(end_d + 2.5, fore_lat * 0.88, paths[1 % paths.size()], 2.4, rng)
	_spawn_side_runway_anchor(end_d + 4.5, fore_lat, paths[0], 2.6, rng)
	if pit.y > pit.x + 6.0:
		var lip_lat := side * 2.8
		_spawn_side_runway_anchor(pit.x - 1.2, lip_lat, paths[2 % paths.size()], 1.8, rng)
		_spawn_side_runway_anchor(pit.y + 1.0, lip_lat, paths[3 % paths.size()], 1.8, rng)

func _attach_side_runway_ramp_dressing(zone: Dictionary) -> void:
	# 水平路缘 ↔ 侧墙立面过渡带：散落医疗箱 / 残破无人机等，弱化硬切边
	_ensure_side_dressing_root()
	var start := float(zone.get("start", 0.0))
	var length := float(zone.get("length", 70.0))
	var entry := float(zone.get("entry_window", 10.0))
	var end_d := start + length
	var exit_window := entry * 0.55
	var side := _wall_zone_side(zone)
	var offset := _effective_wall_lateral_offset(zone)
	var outer_lat := side * (offset + 3.15)
	# 装饰只贴在墙外缘/近景，不占路面车道
	var wall_face_lat := outer_lat + side * 0.18
	var fore_lat := outer_lat + side * 0.62
	var paths := _side_runway_anchor_prop_paths()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(start * 31.0 + side * 911.0)
	var lane_y := GROUND_Y - 0.05
	var entry_spots: Array[Dictionary] = [
		{"d": start - entry * 0.78, "lat": fore_lat, "h": 1.85, "pi": 0},
		{"d": start - entry * 0.52, "lat": wall_face_lat, "h": 1.45, "pi": 1},
		{"d": start - entry * 0.28, "lat": fore_lat, "h": 1.65, "pi": 2},
		{"d": start - entry * 0.06, "lat": wall_face_lat, "h": 1.35, "pi": 0},
		{"d": start + 2.4, "lat": wall_face_lat, "h": 1.25, "pi": 3},
		{"d": start + 5.2, "lat": fore_lat, "h": 1.55, "pi": 1},
	]
	for spot in entry_spots:
		var lat := float(spot["lat"])
		var along := clampf((float(spot["d"]) - (start - entry)) / maxf(entry, 0.001), 0.0, 1.0)
		var rise := along * along * 0.55
		var path := paths[int(spot["pi"]) % paths.size()]
		_spawn_side_runway_dressing_prop(
			float(spot["d"]), lat, lane_y + rise, path, float(spot["h"]), rng
		)
	var exit_spots: Array[Dictionary] = [
		{"d": end_d - 4.8, "lat": wall_face_lat, "h": 1.35, "pi": 2},
		{"d": end_d - 2.0, "lat": fore_lat, "h": 1.55, "pi": 0},
		{"d": end_d + exit_window * 0.38, "lat": wall_face_lat, "h": 1.45, "pi": 1},
		{"d": end_d + exit_window * 0.74, "lat": fore_lat, "h": 1.65, "pi": 3},
	]
	for spot in exit_spots:
		var lat := float(spot["lat"])
		var blend := clampf((float(spot["d"]) - end_d) / maxf(exit_window, 0.001), 0.0, 1.0)
		var rise := blend * blend * 0.45
		var path := paths[int(spot["pi"]) % paths.size()]
		_spawn_side_runway_dressing_prop(
			float(spot["d"]), lat, lane_y + rise, path, float(spot["h"]), rng
		)
	_spawn_side_runway_dressing_prop(start + 0.8, wall_face_lat, lane_y, paths[0], 2.35, rng)
	_spawn_side_runway_dressing_prop(end_d - 0.5, fore_lat, lane_y, paths[1 % paths.size()], 2.1, rng)

func _spawn_side_runway_dressing_prop(
	distance: float,
	lateral: float,
	world_y: float,
	asset_path: String,
	target_height: float,
	rng: RandomNumberGenerator
) -> void:
	if asset_path.strip_edges() == "" or not ResourceLoader.exists(asset_path):
		return
	var scene := _load_runner_scene(asset_path, false)
	if scene == null:
		return
	var root := Node3D.new()
	root.name = "WallRampDress_%d" % _side_dressing_root.get_child_count()
	_side_dressing_root.add_child(root)
	var placed := _world_on_path(distance, lateral, world_y)
	root.position = placed["pos"]
	root.position.y = world_y
	var path_yaw := float(placed["yaw"])
	var model_yaw := rng.randf_range(-24.0, 24.0)
	if "drone" in asset_path.to_lower() or "robot" in asset_path.to_lower():
		model_yaw += rng.randf_range(72.0, 108.0)
	root.rotation.y = path_yaw + rng.randf_range(-0.35, 0.35)
	var footprint := clampf(target_height * 0.92, 1.35, 2.85)
	var model := _add_scaled_model_visual(
		root,
		scene,
		"WallRampDressModel",
		target_height,
		model_yaw,
		Vector3.ZERO,
		footprint,
		MIDGROUND_SCALE_CAP
	)
	if model != null:
		_preserve_midground_materials(root)
		if _is_midground_meteorite(asset_path):
			_apply_midground_meteorite_variant(root, _pick_meteorite_palette(rng, distance, lateral))
		_disable_mesh_shadows(root)
		_add_ground_contact_shadow(root, footprint * 0.55, 0.85)

func _spawn_side_runway_anchor(
	distance: float,
	lateral: float,
	asset_path: String,
	target_height: float,
	rng: RandomNumberGenerator
) -> void:
	if asset_path.strip_edges() == "" or not ResourceLoader.exists(asset_path):
		return
	_spawn_midground_prop(distance, lateral, asset_path, target_height, rng, 1.05)

func _make_wall_run_steel_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.07, 0.12, 0.24)
	mat.metallic = 0.72
	mat.roughness = 0.38
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.18, 0.32)
	mat.emission_energy_multiplier = 0.22
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat

func _make_wall_run_face_material(kit: Dictionary = {}) -> Material:
	var road: Material = kit.get("road") as Material
	if road != null:
		if road is Resource:
			return (road as Resource).duplicate() as Material
		return road
	if _road_style_id == "energy_neon":
		return _make_energy_neon_road_material()
	return _make_holographic_road_material()

func _wall_run_slice(distance: float, side: float, offset: float) -> Dictionary:
	var sample := _sample_path(distance)
	var right: Vector3 = sample["right"]
	var base: Vector3 = sample["pos"] + right * (side * offset)
	var y0 := GROUND_Y - 0.12
	var y1 := y0 + WALL_FACE_HEIGHT
	var half_t := WALL_THICKNESS * 0.5
	# 内侧面更靠近主路
	var inner_lat_shift := -side * half_t
	var outer_lat_shift := side * half_t
	var ib := base + right * inner_lat_shift
	var ob := base + right * outer_lat_shift
	ib.y = y0
	ob.y = y0
	var it := ib + Vector3(0.0, y1 - y0, 0.0)
	var ot := ob + Vector3(0.0, y1 - y0, 0.0)
	return {
		"distance": distance,
		"inner_bottom": ib,
		"inner_top": it,
		"outer_bottom": ob,
		"outer_top": ot,
	}

func _add_wall_quad(st: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3) -> void:
	var n := (v1 - v0).cross(v3 - v0)
	if n.length_squared() < 0.0001:
		n = Vector3.UP
	else:
		n = n.normalized()
	st.set_normal(n)
	st.set_uv(Vector2(0.0, 0.0))
	st.add_vertex(v0)
	st.set_uv(Vector2(1.0, 0.0))
	st.add_vertex(v1)
	st.set_uv(Vector2(1.0, 1.0))
	st.add_vertex(v2)
	st.set_uv(Vector2(0.0, 0.0))
	st.add_vertex(v0)
	st.set_uv(Vector2(1.0, 1.0))
	st.add_vertex(v2)
	st.set_uv(Vector2(0.0, 1.0))
	st.add_vertex(v3)

func _add_wall_quad_uv(
	st: SurfaceTool,
	v0: Vector3,
	v1: Vector3,
	v2: Vector3,
	v3: Vector3,
	uv0: Vector2,
	uv1: Vector2,
	uv2: Vector2,
	uv3: Vector2
) -> void:
	var n := (v1 - v0).cross(v3 - v0)
	if n.length_squared() < 0.0001:
		n = Vector3.UP
	else:
		n = n.normalized()
	st.set_normal(n)
	st.set_uv(uv0)
	st.add_vertex(v0)
	st.set_uv(uv1)
	st.add_vertex(v1)
	st.set_uv(uv2)
	st.add_vertex(v2)
	st.set_uv(uv0)
	st.add_vertex(v0)
	st.set_uv(uv2)
	st.add_vertex(v2)
	st.set_uv(uv3)
	st.add_vertex(v3)

func _attach_wall_lane_rail(
	start_d: float,
	end_d: float,
	side: float,
	offset: float,
	height: float,
	material: Material,
	step: float
) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_w := 0.07
	var d := start_d
	var prev_l := Vector3.ZERO
	var prev_r := Vector3.ZERO
	var has_prev := false
	while d <= end_d + 0.001:
		var sample := _sample_path(minf(d, end_d))
		var right: Vector3 = sample["right"]
		var inward: Vector3 = right * (-side)
		# 指示线贴在墙面内侧
		var center: Vector3 = sample["pos"] + right * _wall_inner_face_lateral(side, offset)
		center.y = height
		# 贴墙细轨：沿墙法线展开一点厚度
		var l := center + inward * 0.02 - inward * half_w
		var r := center + inward * 0.02 + inward * half_w
		if has_prev:
			_add_wall_quad(st, prev_l, prev_r, r, l)
		prev_l = l
		prev_r = r
		has_prev = true
		if d >= end_d:
			break
		d += step
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.name = "WallLaneRail"
	mi.mesh = mesh
	mi.material_override = material
	_attach_road(mi)

func _attach_road(node: Node) -> void:
	if _lava_platform_visual_root != null and is_instance_valid(_lava_platform_visual_root):
		_lava_platform_visual_root.add_child(node)
		return
	if _road_root != null:
		_road_root.add_child(node)
	else:
		track_root.add_child(node)

func _attach_path_strip(
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float = 2.0,
	lateral_bias: float = 0.0,
	skip_fork_gaps: bool = false
) -> void:
	if end_d <= start_d + 0.05 or material == null:
		return
	if skip_fork_gaps and LevelConfig != null:
		var cursor := start_d
		var gaps: Array = []
		for zone in _junction_zones():
			var gs := float(zone["distance"])
			var glen := float(zone.get("length", 70.0))
			var ge := gs + glen
			# 入口/出口保留主路与岔路重叠衔接；中段挖空形成不可跑空隙
			var keep := maxf(glen * 0.14, 12.0)
			var overlap := 4.0
			var cut_s := gs + keep - overlap
			var cut_e := ge - keep + overlap
			if cut_e > cut_s + 8.0:
				gaps.append(Vector2(cut_s, cut_e))
		# 侧墙段主路挖坍塌坑
		for zone in _side_runway_zones():
			var pit: Vector2 = _side_runway_pit_range(zone)
			if pit.y > pit.x + 4.0:
				gaps.append(pit)
		# main_block 封堵带也挖开主路，避免「看不见坑却判坠入」
		for gap2 in _main_block_road_gaps():
			if gap2.y > gap2.x + 2.0:
				gaps.append(gap2)
		gaps.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
		for gap in gaps:
			var gs: float = gap.x
			var ge: float = gap.y
			if ge <= cursor or gs >= end_d:
				continue
			if cursor < gs:
				_attach_path_strip_segment(cursor, minf(gs, end_d), half_width, y, material, step, lateral_bias)
			cursor = maxf(cursor, ge)
		if cursor < end_d:
			_attach_path_strip_segment(cursor, end_d, half_width, y, material, step, lateral_bias)
		return
	_attach_path_strip_segment(start_d, end_d, half_width, y, material, step, lateral_bias)

func _attach_path_strip_segment(
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	lateral_bias: float,
	edge_wobble: float = 0.0,
	inner_on_left: bool = true,
	feather_inner: bool = false,
	feather_center: bool = false
) -> void:
	if end_d <= start_d + 0.05:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start_d
	while d < end_d - 0.001:
		var wob := _strip_edge_wobble(d, lateral_bias, edge_wobble) if edge_wobble > 0.001 else 0.0
		var half_l := half_width
		var half_r := half_width
		if edge_wobble > 0.001:
			if inner_on_left:
				half_r += wob
			else:
				half_l += wob
		pts.append(_path_strip_point_shaped(d, half_l, half_r, y, lateral_bias))
		d += step
	var wob_end := _strip_edge_wobble(end_d, lateral_bias, edge_wobble) if edge_wobble > 0.001 else 0.0
	var half_l_end := half_width
	var half_r_end := half_width
	if edge_wobble > 0.001:
		if inner_on_left:
			half_r_end += wob_end
		else:
			half_l_end += wob_end
	pts.append(_path_strip_point_shaped(end_d, half_l_end, half_r_end, y, lateral_bias))
	if pts.size() < 2:
		return
	var uv_scale := 0.14 if _road_style_id == "holographic" else (0.2 if _road_style_id == "energy_neon" else (0.11 if _road_style_id == "coarse_desert" else 0.08))
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		var L0: Vector3 = a["L"]
		var R0: Vector3 = a["R"]
		var L1: Vector3 = b["L"]
		var R1: Vector3 = b["R"]
		var path_pos: Vector3 = a["pos"]
		var path_right: Vector3 = a["right"]
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, path_pos, path_right, L0, true))
		st.add_vertex(L0)
		st.set_uv(Vector2(1.0, v0))
		st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, path_pos, path_right, R0, false))
		st.add_vertex(R0)
		st.set_uv(Vector2(1.0, v1))
		st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, b["pos"], b["right"], R1, false))
		st.add_vertex(R1)
		st.set_uv(Vector2(0.0, v0))
		st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, path_pos, path_right, L0, true))
		st.add_vertex(L0)
		st.set_uv(Vector2(1.0, v1))
		st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, b["pos"], b["right"], R1, false))
		st.add_vertex(R1)
		st.set_uv(Vector2(0.0, v1))
		st.set_color(_strip_corner_color(feather_inner, inner_on_left, feather_center, b["pos"], b["right"], L1, true))
		st.add_vertex(L1)
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)

func _strip_edge_wobble(distance: float, lateral_bias: float, amplitude: float) -> float:
	return (
		sin(distance * 0.29 + lateral_bias * 0.11) * 0.42
		+ sin(distance * 0.71 + lateral_bias * 0.23) * 0.28
		+ sin(distance * 1.37 + lateral_bias * 0.07) * 0.18
	) * amplitude

func _path_strip_point_shaped(
	distance: float,
	half_left: float,
	half_right: float,
	y: float,
	lateral_bias: float
) -> Dictionary:
	var sample := _sample_path(distance)
	var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral_bias
	var right: Vector3 = sample["right"]
	var L: Vector3 = origin - right * half_left
	var R: Vector3 = origin + right * half_right
	var lift := (sample["pos"] as Vector3).y
	L.y = y + lift
	R.y = y + lift
	return {"L": L, "R": R, "d": distance, "pos": origin, "right": right}

func _strip_corner_color(
	feather_inner: bool,
	inner_on_left: bool,
	feather_center: bool,
	path_pos: Vector3,
	path_right: Vector3,
	vertex: Vector3,
	is_left_corner: bool
) -> Color:
	var c := Color(1.0, 1.0, 1.0, 1.0)
	if feather_inner:
		var is_inner := (is_left_corner and inner_on_left) or ((not is_left_corner) and (not inner_on_left))
		c.r = 0.06 if is_inner else 1.0
	if feather_center:
		var road_half := _holographic_road_half()
		var lat := absf((vertex - path_pos).dot(path_right))
		c.b = clampf((lat - road_half) / 2.6, 0.0, 1.0)
	return c

func _path_strip_point(distance: float, half_width: float, y: float, lateral_bias: float) -> Dictionary:
	return _path_strip_point_shaped(distance, half_width, half_width, y, lateral_bias)

func _make_road_style_kit(style_id: String) -> Dictionary:
	var theme: Dictionary = LevelConfig.get_theme() if LevelConfig != null else {}
	return RoadMeshBuilder.make_kit(style_id, theme)

func _make_opaque_road_base_material(style_id: String) -> StandardMaterial3D:
	match style_id:
		"alien_energy":
			return _make_material(Color(0.1, 0.16, 0.22), Color(0.22, 0.48, 0.58), 0.12)
		"energy_neon":
			return _make_material(Color(0.04, 0.06, 0.1), Color(0.08, 0.28, 0.38), 0.12)
		"planet":
			return _make_material(Color(0.2, 0.15, 0.11), Color(0.28, 0.2, 0.14), 0.05)
		"coarse_desert":
			return _make_opaque_desert_surface_material(Color(0.38, 0.24, 0.12))
		_:
			return _make_material(Color(0.015, 0.04, 0.08), Color(0.1, 0.38, 0.48), 0.18)

func _make_alien_energy_road_material() -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = ROAD_ALIEN_ENERGY_SHADER
	mat.set_shader_parameter("base_color", Color(0.12, 0.2, 0.28))
	mat.set_shader_parameter("vein_color", Color(0.55, 0.92, 1.0))
	mat.set_shader_parameter("particle_color", Color(0.42, 0.98, 1.0))
	mat.set_shader_parameter("roughness_val", 0.34)
	mat.set_shader_parameter("metallic_val", 0.08)
	mat.set_shader_parameter("vein_energy", 2.35)
	mat.set_shader_parameter("particle_energy", 1.3)
	mat.set_shader_parameter("flow_speed", 0.55)
	mat.set_shader_parameter("detail_scale", 0.12)
	return mat

func _make_planet_road_material() -> StandardMaterial3D:
	# 星球默认：实心晶砂路面，贴地不透明，避免沙漠从下方「透出来」
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.36, 0.3)
	mat.roughness = 0.78
	mat.metallic = 0.06
	mat.emission_enabled = true
	mat.emission = Color(0.48, 0.38, 0.26)
	mat.emission_energy_multiplier = 0.15
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat

func _make_coarse_desert_road_material() -> StandardMaterial3D:
	# 实心沙石路面：与星球默认同样强制不透明，避免沙漠从下方透出
	var mat := StandardMaterial3D.new()
	var tex_path := "res://assets/maps/route_levels/models/track/textures/white_sandstone_blocks_02_diff_1k.jpg"
	if ResourceLoader.exists(tex_path):
		mat.albedo_texture = load(tex_path) as Texture2D
	mat.albedo_color = Color(0.78, 0.58, 0.36)
	mat.roughness = 0.94
	mat.metallic = 0.02
	mat.emission_enabled = false
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat

func _make_opaque_desert_surface_material(
	color: Color,
	emission: Color = Color.BLACK,
	emission_energy: float = 0.0
) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	mat.metallic = 0.02
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	if emission_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = emission_energy
	return mat

func _load_holographic_runway_texture(prefer_topdown: bool = true) -> Texture2D:
	# 路径 mesh 用俯视图贴图平铺；透视概念图仅作展示，直接平铺会采到大量黑边
	var tex_paths: Array[String] = []
	if prefer_topdown:
		tex_paths = [
			"res://assets/maps/route_levels/models/track/textures/holographic_road_topdown.png",
			"res://assets/maps/route_levels/models/track/textures/holographic_energy_runway.png",
		]
	else:
		tex_paths = [
			"res://assets/maps/route_levels/models/track/textures/holographic_energy_runway.png",
			"res://assets/maps/route_levels/models/track/textures/holographic_road_topdown.png",
		]
	for tex_path in tex_paths:
		if ResourceLoader.exists(tex_path):
			var tex := load(tex_path) as Texture2D
			if tex:
				return tex
	return null

func _make_holographic_road_material() -> StandardMaterial3D:
	# 全息能量轨：俯视图贴图平铺，青绿电路纹理 + 紫边由 curb/line 条带承担
	var mat := StandardMaterial3D.new()
	var tex := _load_holographic_runway_texture(true)
	if tex:
		mat.albedo_texture = tex
		mat.emission_texture = tex
	mat.albedo_color = Color(0.28, 0.68, 0.78)
	mat.emission_enabled = true
	mat.emission = Color(0.38, 0.92, 1.0)
	mat.emission_energy_multiplier = 0.95
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat

func _load_energy_neon_runway_texture() -> Texture2D:
	var tex_path := "res://assets/maps/route_levels/models/track/textures/energy_neon_runway.jpg"
	if ResourceLoader.exists(tex_path):
		return load(tex_path) as Texture2D
	return null

func _make_energy_neon_road_material() -> StandardMaterial3D:
	# 能量霓虹：概念图底图（青裂纹 + 青/橙边轨），unshaded 强发光保证 void 里可见
	var mat := StandardMaterial3D.new()
	var tex := _load_energy_neon_runway_texture()
	if tex:
		mat.albedo_texture = tex
		mat.emission_texture = tex
	mat.albedo_color = Color(0.42, 0.82, 0.92)
	mat.emission_enabled = true
	mat.emission = Color(0.32, 0.95, 1.0)
	mat.emission_energy_multiplier = 3.2
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat

func _apply_road_style_environment() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var env := _world_environment.environment
	match _road_style_id:
		"holographic", "energy_neon", "alien_energy":
			# 全息路面用材质自发光即可；Bloom/Glow 是低配卡顿主因
			if _is_relay_mission():
				env.glow_enabled = true
				env.glow_intensity = 0.14
				env.glow_strength = 0.32
				env.glow_bloom = 0.05
				env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
			else:
				env.glow_enabled = false
				env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
				var exposure := 1.04
				if _is_dome_h1_mission():
					exposure = 0.90
				env.tonemap_exposure = maxf(env.tonemap_exposure, exposure)
		"void_crystal":
			env.glow_enabled = false
			env.tonemap_exposure = maxf(env.tonemap_exposure, 1.06)
		"coarse_desert":
			env.glow_enabled = true
			env.glow_intensity = 0.22
			env.glow_strength = 0.55
			env.glow_bloom = 0.08
			env.glow_hdr_threshold = 0.88
			env.tonemap_exposure = maxf(env.tonemap_exposure, 1.04)

func _boost_runner_lights(sun_color: Color, sun_energy: float, rim_energy: float) -> void:
	var sun := get_node_or_null("RunnerSun") as DirectionalLight3D
	if sun:
		sun.light_color = sun_color
		sun.light_energy = sun_energy
		sun.shadow_enabled = false
	if player == null:
		return
	var key := player.get_node_or_null("PlayerKeyLight") as OmniLight3D
	if key:
		key.light_color = sun_color.lerp(Color.WHITE, 0.25)
		key.light_energy = maxf(1.05, sun_energy * 0.42)
		key.shadow_enabled = false
	var rim := player.get_node_or_null("PlayerRunwayRim") as OmniLight3D
	if rim:
		rim.light_energy = maxf(rim_energy * 0.55, 0.45)
		rim.shadow_enabled = false

func _fork_gap_cut_t_start(zone: Dictionary) -> float:
	var length := float(zone.get("length", 70.0))
	return clampf(maxf(length * 0.25, 20.0) / maxf(length, 0.001), 0.08, 0.45)

func _fork_gap_cut_t_end(zone: Dictionary) -> float:
	var length := float(zone.get("length", 70.0))
	return 1.0 - clampf(maxf(length * 0.06, 4.5) / maxf(length, 0.001), 0.04, 0.12)

func _is_in_fork_main_gap(distance: float) -> bool:
	for zone in _junction_zones():
		var start := float(zone["distance"])
		var length := float(zone.get("length", 70.0))
		if distance < start or distance > start + length:
			continue
		var t := (distance - start) / maxf(length, 0.001)
		# 与 RoadMeshBuilder.fork_gaps 同步：选道后再挖空主路
		if t > _fork_gap_cut_t_start(zone) and t < _fork_gap_cut_t_end(zone):
			return true
	return false

func _desert_shoulder_half_width() -> float:
	var road_half := 6.0 if _road_style_id == "holographic" else 6.3
	return road_half + (8.0 if _mission_uses_textured_ground() else 2.4)

func _desert_ground_y(lane_y: float) -> float:
	# 贴近跑道底面，减少侧视时的路缘台阶缝
	return lane_y - 0.018

func _holographic_road_half() -> float:
	return 6.0

func _fork_gap_fill_half_width(zone: Dictionary, distance: float) -> float:
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	var envelope := _fork_envelope(t)
	var branch_half := _fork_branch_half_width()
	var arm := spread * envelope
	if arm <= branch_half + 0.28:
		return 0.0
	return clampf(arm - branch_half - 0.18, 0.45, spread * 0.46)

func _build_fork_junction_sand_base(zone: Dictionary, lane_y: float, sand_material: Material) -> void:
	# 整段分叉区铺全宽沙底，覆盖 fork_gaps 挖空的主路（进岔前纵向断档）
	if sand_material == null:
		return
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var pad_half := _desert_shoulder_half_width()
	_attach_path_strip_skipping_pits(
		start,
		start + length,
		pad_half,
		_desert_ground_y(lane_y),
		sand_material,
		1.75,
		0.0
	)

func _build_fork_gap_ground_fill(zone: Dictionary, lane_y: float, sand_material: Material) -> void:
	# 两岔张开后的中间楔形（主路挖空段已由 _build_fork_junction_sand_base 托底）
	if sand_material == null:
		return
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var step := 2.2
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start + 5.0
	var end_d := start + length - 5.0
	while d <= end_d + 0.001:
		var gap_half := _fork_gap_fill_half_width(zone, d)
		if gap_half > 0.4:
			pts.append(_path_strip_point(d, gap_half, lane_y - 0.037, 0.0))
		d += step
	if pts.size() < 2:
		return
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		st.set_normal(Vector3.UP)
		st.add_vertex(a["L"])
		st.add_vertex(a["R"])
		st.add_vertex(b["R"])
		st.add_vertex(a["L"])
		st.add_vertex(b["R"])
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.name = "ForkGapGround"
	mi.mesh = mesh
	mi.material_override = sand_material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)

func _build_fork_gap_decor(zone: Dictionary, lane_y: float) -> void:
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var decor_root := Node3D.new()
	decor_root.name = "ForkGapDecor"
	_attach_road(decor_root)
	var pad_half := _desert_shoulder_half_width()
	var placements: Array[Dictionary] = [
		{"t": 0.06, "path_idx": 2, "lat": 0.0, "scale": 0.42, "yaw_off": 0.12, "use_pad": true},
		{"t": 0.14, "path_idx": 0, "lat": -2.8, "scale": 0.38, "yaw_off": 0.28, "use_pad": true},
		{"t": 0.22, "path_idx": 1, "lat": 3.1, "scale": 0.4, "yaw_off": -0.32, "use_pad": true},
		{"t": 0.34, "path_idx": 0, "lat": -2.2, "scale": 0.52, "yaw_off": 0.35, "use_pad": false},
		{"t": 0.46, "path_idx": 2, "lat": 0.6, "scale": 0.48, "yaw_off": -0.15, "use_pad": false},
		{"t": 0.52, "path_idx": 1, "lat": 2.6, "scale": 0.46, "yaw_off": -0.42, "use_pad": false},
		{"t": 0.64, "path_idx": 2, "lat": -0.8, "scale": 0.58, "yaw_off": 0.18, "use_pad": false},
		{"t": 0.78, "path_idx": 0, "lat": 4.2, "scale": 0.4, "yaw_off": -0.55, "use_pad": false},
	]
	for p in placements:
		var d := start + length * float(p["t"])
		var gap_half := _fork_gap_fill_half_width(zone, d)
		var limit_half := pad_half - 0.6 if bool(p.get("use_pad", false)) else gap_half
		if limit_half < 0.55:
			continue
		var path := FORK_GAP_DECOR_PATHS[int(p["path_idx"]) % FORK_GAP_DECOR_PATHS.size()]
		var scene := _load_runner_scene(path, false)
		if scene == null:
			continue
		var sample := _sample_path(d)
		var right: Vector3 = sample["right"]
		var yaw := float(sample["yaw"])
		var inst := scene.instantiate() as Node3D
		decor_root.add_child(inst)
		var lat: float = clampf(float(p["lat"]), -limit_half + 0.55, limit_half - 0.55)
		var prop_pos: Vector3 = sample["pos"] + right * lat
		prop_pos.y = lane_y - 0.02
		inst.position = prop_pos
		inst.rotation.y = yaw + float(p["yaw_off"])
		var sc := float(p["scale"])
		inst.scale = Vector3(sc, sc * 0.82, sc)
		_disable_mesh_shadows(inst)

func _fork_envelope(t: float) -> float:
	# 0→1→0，中段最开
	return sin(clampf(t, 0.0, 1.0) * PI)

func _build_path_road_slice(
	distance: float,
	segment_len: float,
	lateral_bias: float,
	road_material: Material,
	shoulder_material: Material,
	curb_material: Material,
	line_material: Material,
	post_material: Material,
	lane_y: float
) -> void:
	var sample := _sample_path(distance)
	var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral_bias
	var yaw := float(sample["yaw"])
	# PlaneMesh 顶面即车道面，不再用厚盒子端面露缝
	var center := origin + Vector3(0.0, lane_y, 0.0)

	var road := MeshInstance3D.new()
	var thin_energy := _road_style_id in ["alien_energy", "holographic", "energy_neon"]
	var neon_edge := _road_style_id in ["energy_neon", "holographic"]
	var road_w := 12.6 if _road_style_id == "energy_neon" else (12.0 if _road_style_id == "holographic" else (11.8 if _road_style_id == "alien_energy" else 12.6))
	var road_mesh := PlaneMesh.new()
	road_mesh.size = Vector2(road_w, segment_len)
	road_mesh.orientation = PlaneMesh.FACE_Y
	road_mesh.material = road_material
	road.mesh = road_mesh
	road.position = center
	road.rotation.y = yaw
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(road)

	for side in [-1.0, 1.0]:
		# 沙色贴边肩：填满紫边外侧与地形之间的空隙
		var shoulder := MeshInstance3D.new()
		var shoulder_mesh := PlaneMesh.new()
		shoulder_mesh.size = Vector2(3.2 if thin_energy else 1.8, segment_len)
		shoulder_mesh.orientation = PlaneMesh.FACE_Y
		shoulder_mesh.material = shoulder_material
		shoulder.mesh = shoulder_mesh
		var shoulder_x := 7.7 if thin_energy else 7.25
		shoulder.position = center + (sample["right"] as Vector3) * (shoulder_x * side)
		shoulder.position.y = lane_y - 0.008
		shoulder.rotation.y = yaw
		shoulder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(shoulder)

		var curb := MeshInstance3D.new()
		var curb_mesh := BoxMesh.new()
		if _road_style_id == "alien_energy":
			curb_mesh.size = Vector3(0.08, 0.03, segment_len)
		elif neon_edge:
			curb_mesh.size = Vector3(0.12, 0.04, segment_len)
		else:
			curb_mesh.size = Vector3(0.16, 0.12, segment_len)
		curb_mesh.material = curb_material
		curb.mesh = curb_mesh
		var curb_x := road_w * 0.5 - 0.02
		if _road_style_id == "energy_neon":
			curb_x = 6.35
		elif not thin_energy and _road_style_id != "holographic":
			curb_x = 6.45
		curb.position = center + (sample["right"] as Vector3) * (curb_x * side)
		curb.position.y = lane_y + (0.02 if thin_energy else 0.06)
		curb.rotation.y = yaw
		curb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(curb)
		if neon_edge:
			var curb2 := MeshInstance3D.new()
			var curb2_mesh := BoxMesh.new()
			curb2_mesh.size = Vector3(0.06, 0.025, segment_len)
			curb2_mesh.material = curb_material
			curb2.mesh = curb2_mesh
			curb2.position = center + (sample["right"] as Vector3) * ((curb_x + 0.14) * side)
			curb2.position.y = lane_y + 0.015
			curb2.rotation.y = yaw
			curb2.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(curb2)

	# 中线短划（全息贴图已含能量核，不再叠实体虚线）
	if line_material and not thin_energy and int(distance / segment_len) % 2 == 0:
		var dash := MeshInstance3D.new()
		var dash_mesh := BoxMesh.new()
		dash_mesh.size = Vector3(0.18, 0.04, 2.4)
		dash_mesh.material = line_material
		dash.mesh = dash_mesh
		dash.position = center + Vector3(0.0, 0.04, 0.0)
		dash.rotation.y = yaw
		_attach_road(dash)

	if post_material and not thin_energy and int(distance / segment_len) % 3 == 0:
		for side: float in [-1.0, 1.0]:
			var post := MeshInstance3D.new()
			var post_mesh := BoxMesh.new()
			post_mesh.size = Vector3(0.18, 0.7, 0.18)
			post_mesh.material = post_material
			post.mesh = post_mesh
			post.position = center + (sample["right"] as Vector3) * (7.9 * side)
			post.position.y = GROUND_Y + 0.34
			post.rotation.y = yaw
			_attach_road(post)

func _build_y_fork_branch_roads(_kit: Dictionary, _lane_y: float) -> void:
	# 主路径已沿左岔；补画右岔实心路面（与编辑器共用 polyline 挤出）
	var segments: Array = _active_track_segments()
	for entry in ObstacleLayout.segment_start_poses(segments, 2.0):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = entry.get("segment", {})
		if not ObstacleLayout.is_y_fork_segment(seg):
			continue
		var poly: Array = ObstacleLayout.bake_y_fork_branch_polyline(
			entry.get("pos", Vector3.ZERO),
			float(entry.get("yaw", 0.0)),
			float(seg.get("branch_length", 55.0)),
			float(seg.get("angle", deg_to_rad(45.0))),
			-1.0,
			2.0
		)
		_road_mesh.add_polyline_road(_road_root, poly, _road_style_id, true)

func _attach_polyline_strip(
	samples: Array,
	half_width: float,
	y: float,
	material: Material,
	lateral_bias: float = 0.0
) -> void:
	if material == null or samples.size() < 2:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	for i in samples.size():
		var s: Dictionary = samples[i]
		var pos: Vector3 = s.get("pos", Vector3.ZERO)
		var yaw := float(s.get("yaw", 0.0))
		var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
		var right := forward.cross(Vector3.UP).normalized()
		var origin := pos + right * lateral_bias
		var L := origin - right * half_width
		var R := origin + right * half_width
		L.y = y
		R.y = y
		pts.append({"L": L, "R": R, "d": float(s.get("d", float(i) * 2.0))})
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		st.set_normal(Vector3.UP)
		st.add_vertex(a["L"])
		st.add_vertex(a["R"])
		st.add_vertex(b["R"])
		st.add_vertex(a["L"])
		st.add_vertex(b["R"])
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	_attach_road(mi)

func _fork_branch_half_width() -> float:
	# 岔路至少与主路同宽，略加宽避免障碍物视觉「压过」路面
	return _runway_half_width() + 0.55

func _build_fork_branch_roads(
	zone: Dictionary,
	road_material: Material,
	shoulder_material: Material,
	curb_material: Material,
	line_material: Material,
	island_material: Material,
	lane_y: float
) -> void:
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	# 与主路同宽：左右岔各含完整左中右三道
	var branch_half := _fork_branch_half_width()
	var lead := 14.0
	# 全息贴图中心亮、两侧偏暗：岔路补实心底盘，避免看起来像细丝带
	var holo_deck: Material = null
	if _road_style_id == "holographic":
		holo_deck = _make_material(Color(0.06, 0.16, 0.22), Color(0.18, 0.55, 0.72), 0.35)
	# 不铺中间托底：中间故意留空，仅左右岔有路面
	for side_f in [-1.0, 1.0]:
		var side: float = float(side_f)
		if holo_deck != null:
			_attach_fork_branch_strip(start, length, spread, side, branch_half + 0.35, lane_y - 0.01, holo_deck, 2.2, 0.0, lead)
		elif _road_style_id != "holographic":
			_attach_fork_branch_strip(start, length, spread, side, branch_half + 2.6, lane_y - 0.012, shoulder_material, 2.5, 0.0, lead)
		_attach_fork_branch_strip(start, length, spread, side, branch_half, lane_y + 0.01, road_material, 2.2, 0.0, lead)
		# 岔路边色：左绿右橙，全息路也能一眼看出两条岔
		var edge_mat := _make_material(
			Color(0.2, 0.95, 0.55) if side < 0.0 else Color(1.0, 0.45, 0.12),
			Color(0.25, 1.0, 0.6) if side < 0.0 else Color(1.0, 0.5, 0.15),
			0.7
		)
		_attach_fork_branch_strip(start, length, spread, side, 0.14, lane_y + 0.028, edge_mat, 2.2, branch_half - 0.1, lead)
		_attach_fork_branch_strip(start, length, spread, side, 0.14, lane_y + 0.028, edge_mat, 2.2, -(branch_half - 0.1), lead)
		# 岔内三道分隔线
		if line_material:
			_attach_fork_branch_strip(start, length, spread, side, 0.05, lane_y + 0.016, line_material, 2.2, LANE_WIDTH, lead)
			_attach_fork_branch_strip(start, length, spread, side, 0.05, lane_y + 0.016, line_material, 2.2, -LANE_WIDTH, lead)
	# 中间分隔岛：强调「中间不能跑」
	if island_material:
		_attach_fork_center_island(zone, island_material, lane_y + 0.04)
	# 入口短衔接（只盖极短，避免把 Y 分叉又铺成直道）
	var tip := 5.0
	var bridge_half := branch_half + 0.2
	_attach_path_strip_skipping_pits(start - 2.0, start + tip, bridge_half, lane_y + 0.006, road_material, 1.2, 0.0)
	_attach_path_strip_skipping_pits(start + length - tip, start + length + 4.0, bridge_half, lane_y + 0.006, road_material, 1.2, 0.0)
	_build_fork_entry_wedge(zone, curb_material if curb_material else road_material, lane_y)
	var sand_fill: Material = (
		_make_desert_surroundings_material()
		if _mission_uses_textured_ground()
		else shoulder_material
	)
	_build_fork_junction_sand_base(zone, lane_y, sand_fill)
	_build_fork_gap_ground_fill(zone, lane_y, sand_fill)
	if _mission_uses_textured_ground() and not _is_gate_location():
		_build_fork_gap_decor(zone, lane_y)

func _attach_fork_center_island(zone: Dictionary, material: Material, y: float) -> void:
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	var step := 3.0
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start + 6.0
	var end_d := start + length - 6.0
	while d <= end_d + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		# 细分隔带，不再随 spread 胀成大黑岛
		var half_w := minf(maxf(spread * envelope * 0.06, 0.28), 1.1)
		pts.append(_path_strip_point(d, half_w, y, 0.0))
		d += step
	if pts.size() < 2:
		return
	var glow := _make_material(Color(0.12, 0.2, 0.28, 0.7), Color(0.35, 0.75, 0.95), 0.55)
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var uv_scale := 0.08
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(a["R"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.name = "ForkCenterIsland"
	mi.mesh = mesh
	mi.material_override = glow if material == null else material
	# 强制用半透明细带，避免 kit island 深色不透明大块
	mi.material_override = glow
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)

func _attach_fork_branch_strip(
	start: float,
	length: float,
	spread: float,
	side: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	extra_lateral: float = 0.0,
	lead: float = 0.0
) -> void:
	if material == null:
		return
	var centers: Array[Vector3] = []
	var rights: Array[Vector3] = []
	var ds: Array[float] = []
	var d := start - lead
	var end_d := start + length + lead
	while d <= end_d + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		var lateral := side * spread * envelope + extra_lateral * side
		var sample := _sample_path(d)
		var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral
		origin.y = y
		centers.append(origin)
		rights.append(sample["right"] as Vector3)
		ds.append(d)
		d += step
	if centers.size() < 2:
		return
	# 用相邻中心点求岔路切向的真正横向，避免 atan 偏航把路面挤成细丝带
	var pts: Array[Dictionary] = []
	for i in centers.size():
		var origin: Vector3 = centers[i]
		var path_right: Vector3 = rights[i]
		var branch_right := path_right
		var delta := Vector3.ZERO
		if i + 1 < centers.size():
			delta = centers[i + 1] - origin
		elif i > 0:
			delta = origin - centers[i - 1]
		delta.y = 0.0
		if delta.length_squared() > 0.0001:
			var fwd := delta.normalized()
			var cand := fwd.cross(Vector3.UP)
			if cand.length_squared() > 0.0001:
				cand = cand.normalized()
				if cand.dot(path_right) < 0.0:
					cand = -cand
				branch_right = cand
		var L: Vector3 = origin - branch_right * half_width
		var R: Vector3 = origin + branch_right * half_width
		L.y = y
		R.y = y
		pts.append({"L": L, "R": R, "d": ds[i]})
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var uv_scale := 0.14 if _road_style_id == "holographic" else 0.08
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(a["R"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)

func _build_fork_entry_wedge(zone: Dictionary, curb_material: Material, lane_y: float) -> void:
	# 入口导向条：与跑道材质一致，替代突兀的绿/橙方块
	var start := float(zone["distance"])
	var spread := float(zone.get("spread", 22.0))
	var sample := _sample_path(start + 2.0)
	for side_f in [-1.0, 1.0]:
		var side: float = float(side_f)
		var guide := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.12, 0.03, 6.5)
		mesh.material = curb_material
		guide.mesh = mesh
		guide.position = (sample["pos"] as Vector3) + (sample["right"] as Vector3) * (2.8 * side)
		guide.position.y = lane_y + 0.025
		guide.rotation.y = float(sample["yaw"]) + (-0.22 if side < 0.0 else 0.22)
		_attach_road(guide)

func _attach_fork_underlay(zone: Dictionary, material: Material, y: float) -> void:
	# 岔路区暗色托底，填满主路挖空后的空隙
	if material == null:
		return
	var start := float(zone["distance"])
	var length := float(zone.get("length", 90.0))
	var spread := float(zone.get("spread", 22.0))
	var branch_half := _fork_branch_half_width()
	var lead := 14.0
	var step := 1.75
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start - lead
	while d <= start + length + lead * 0.35 + 0.001:
		var t := clampf((d - start) / maxf(length, 0.001), 0.0, 1.0)
		var envelope := _fork_envelope(t)
		var outer := spread * envelope + branch_half + 3.2
		outer = maxf(outer, 9.5)
		pts.append(_path_strip_point(d, outer, y, 0.0))
		d += step
	if pts.size() < 2:
		return
	var uv_scale := 0.06
	for i in range(pts.size() - 1):
		var a: Dictionary = pts[i]
		var b: Dictionary = pts[i + 1]
		var v0 := float(a["d"]) * uv_scale
		var v1 := float(b["d"]) * uv_scale
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v0))
		st.add_vertex(a["R"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v0))
		st.add_vertex(a["L"])
		st.set_uv(Vector2(1.0, v1))
		st.add_vertex(b["R"])
		st.set_uv(Vector2(0.0, v1))
		st.add_vertex(b["L"])
	var mesh := st.commit()
	if mesh == null:
		return
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(mi)

func _build_start_pad(
	road_material: Material,
	shoulder_material: Material,
	curb_material: Material,
	line_material: Material,
	post_material: Material,
	lane_y: float
) -> void:
	var start_center_z := START_PAD_LENGTH * 0.5
	var start_w := 12.6 if _road_style_id == "energy_neon" else (12.0 if _road_style_id == "holographic" else (13.0 if _road_style_id == "coarse_desert" else 12.6))
	var foundation := MeshInstance3D.new()
	foundation.name = "StartSandFoundation"
	var theme: Dictionary = LevelConfig.get_theme() if LevelConfig != null and LevelConfig.has_method("get_theme") else {}
	var foundation_mat: Material = (
		_make_desert_surroundings_material()
		if _mission_uses_textured_ground() and _road_style_id in ["holographic", "energy_neon"]
		else (
			_make_material(Color(0.01, 0.03, 0.06), Color(0.08, 0.32, 0.42), 0.22)
			if _road_style_id in ["holographic", "energy_neon"]
			else (
				_make_material(Color(0.02, 0.04, 0.07), Color(0.15, 0.45, 0.6), 0.15)
				if _road_style_id == "alien_energy"
				else (
					_make_opaque_desert_surface_material(Color(0.46, 0.3, 0.15))
					if _road_style_id == "coarse_desert"
					else _make_material(Color(0.62, 0.4, 0.2), Color(0.85, 0.5, 0.2), 0.12)
				)
			)
		)
	)
	if _road_style_id in ["holographic", "energy_neon"]:
		var pad_w := start_w + (14.0 if _mission_uses_textured_ground() else 0.4)
		var pad_drop := 0.04 if _mission_uses_textured_ground() else 0.03
		if _mission_uses_textured_ground():
			var pad_plane := PlaneMesh.new()
			pad_plane.size = Vector2(pad_w, START_PAD_LENGTH + 1.5)
			pad_plane.orientation = PlaneMesh.FACE_Y
			pad_plane.material = foundation_mat
			foundation.mesh = pad_plane
			foundation.position = Vector3(0.0, _desert_ground_y(lane_y), start_center_z)
		else:
			var foundation_mesh := BoxMesh.new()
			foundation_mesh.size = Vector3(pad_w, 0.04, START_PAD_LENGTH + 1.5)
			foundation_mesh.material = foundation_mat
			foundation.mesh = foundation_mesh
			foundation.position = Vector3(0.0, lane_y - pad_drop, start_center_z)
	elif _road_style_id == "alien_energy":
		var foundation_mesh := BoxMesh.new()
		foundation_mesh.size = Vector3(start_w + 2.0, 0.08, START_PAD_LENGTH + 2.0)
		foundation_mesh.material = foundation_mat
		foundation.mesh = foundation_mesh
		foundation.position = Vector3(0.0, lane_y - 0.06, start_center_z)
	else:
		var foundation_mesh := BoxMesh.new()
		foundation_mesh.size = Vector3(58.0, 0.36, START_PAD_LENGTH + 8.0)
		foundation_mesh.material = foundation_mat
		foundation.mesh = foundation_mesh
		foundation.position = Vector3(0.0, lane_y - 0.18, start_center_z)
	_attach_road(foundation)

	if _road_style_id in ["alien_energy", "planet", "coarse_desert"]:
		var opaque_apron := MeshInstance3D.new()
		opaque_apron.name = "StartRoadOpaqueBase"
		var opaque_mesh := PlaneMesh.new()
		opaque_mesh.size = Vector2(start_w, START_PAD_LENGTH + 2.0)
		opaque_mesh.orientation = PlaneMesh.FACE_Y
		opaque_mesh.material = _make_opaque_road_base_material(_road_style_id)
		opaque_apron.mesh = opaque_mesh
		opaque_apron.position = Vector3(0.0, lane_y - 0.02, start_center_z)
		opaque_apron.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(opaque_apron)

	var road := MeshInstance3D.new()
	road.name = "StartRoadApron"
	var road_mesh := PlaneMesh.new()
	road_mesh.size = Vector2(start_w, START_PAD_LENGTH + 2.0)
	road_mesh.orientation = PlaneMesh.FACE_Y
	road_mesh.material = road_material
	road.mesh = road_mesh
	road.position = Vector3(0.0, lane_y, start_center_z)
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_attach_road(road)

	if _road_style_id not in ["holographic", "energy_neon"]:
		# 起点两侧沙肩，与路径托底衔接
		for x in [-7.8, 7.8]:
			var shoulder := MeshInstance3D.new()
			var shoulder_mesh := PlaneMesh.new()
			shoulder_mesh.size = Vector2(3.4, START_PAD_LENGTH + 2.0)
			shoulder_mesh.orientation = PlaneMesh.FACE_Y
			shoulder_mesh.material = shoulder_material
			shoulder.mesh = shoulder_mesh
			shoulder.position = Vector3(x, lane_y - 0.008, start_center_z)
			shoulder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(shoulder)
	else:
		var road_half := 6.4 if _road_style_id == "energy_neon" else 6.0
		var sand_wing_mat: Material = (
			_make_desert_surroundings_material()
			if _mission_uses_textured_ground()
			else shoulder_material
		)
		if _mission_uses_textured_ground():
			for x in [-7.2, 7.2]:
				var wing := MeshInstance3D.new()
				var wing_mesh := PlaneMesh.new()
				wing_mesh.size = Vector2(6.2, START_PAD_LENGTH + 2.0)
				wing_mesh.orientation = PlaneMesh.FACE_Y
				wing_mesh.material = sand_wing_mat
				wing.mesh = wing_mesh
				wing.position = Vector3(x, _desert_ground_y(lane_y), start_center_z)
				wing.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				_attach_road(wing)
		var shoulder_half := 1.6
		var shoulder_x := road_half + shoulder_half
		for x in [-shoulder_x, shoulder_x]:
			var shoulder := MeshInstance3D.new()
			var shoulder_mesh := PlaneMesh.new()
			shoulder_mesh.size = Vector2(shoulder_half * 2.0, START_PAD_LENGTH + 2.0)
			shoulder_mesh.orientation = PlaneMesh.FACE_Y
			shoulder_mesh.material = shoulder_material
			shoulder.mesh = shoulder_mesh
			shoulder.position = Vector3(x, lane_y - 0.008, start_center_z)
			shoulder.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(shoulder)

	var curb_xs: Array = [-start_w * 0.5, start_w * 0.5]
	if _road_style_id == "holographic":
		for x in curb_xs:
			var curb := MeshInstance3D.new()
			var curb_mesh := BoxMesh.new()
			curb_mesh.size = Vector3(0.12, 0.04, START_PAD_LENGTH + 2.0)
			curb_mesh.material = curb_material
			curb.mesh = curb_mesh
			curb.position = Vector3(x, lane_y + 0.02, start_center_z)
			curb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			_attach_road(curb)

	if _road_style_id != "holographic" and _road_style_id != "alien_energy":
		_build_lane_dashes_segment(start_center_z, line_material)
		_build_side_posts_segment(start_center_z, post_material)

func _build_lane_dashes_segment(seg_z: float, light_material: Material) -> void:
	for x in [-2.0, 2.0]:
		var line := MeshInstance3D.new()
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(0.08, 0.045, 48.5)
		line_mesh.material = light_material
		line.mesh = line_mesh
		line.position = Vector3(x, GROUND_Y + 0.015, seg_z)
		_attach_road(line)

	for step in 4:
		var dash := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.34, 0.05, 1.7)
		mesh.material = light_material
		dash.mesh = mesh
		dash.position = Vector3(0.0, GROUND_Y + 0.025, seg_z + 10.0 - step * 12.0)
		_attach_road(dash)

func _build_side_posts_segment(seg_z: float, post_material: Material) -> void:
	for x in [-7.65, 7.65]:
		for step in 4:
			var post := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.07
			mesh.bottom_radius = 0.07
			mesh.height = 0.82
			mesh.radial_segments = 10
			mesh.material = post_material
			post.mesh = mesh
			post.position = Vector3(x, GROUND_Y + 0.34, seg_z + 12.0 - step * 12.0)
			_attach_road(post)

func _build_planet_surroundings(theme: Dictionary) -> void:
	match _background_style_id:
		"void_dark", "starfield":
			_build_void_surroundings_for_energy_road()
		"industrial_ruin":
			_build_industrial_surroundings(theme)
		"savanna":
			_build_savanna_surroundings(theme)
		_:
			_build_desert_surroundings(theme)
	_build_path_side_dressing(theme)
	_build_near_sky_layers()
	if not _distant_tower_paths.is_empty() or not _distant_spaceship_paths.is_empty() or not _distant_hearth_paths.is_empty():
		_build_distant_background(theme)
	# 医疗第二关不再挂假极光帘，天空走真实全景光影


func _build_medical_m2_aurora_curtains() -> void:
	# 已停用：假极光帘看起来像贴画
	return
	if _mission_id_str() != "mission_medical_m2":
		return
	if _medical_m2_aurora_root != null:
		_medical_m2_aurora_root.queue_free()
	_medical_m2_aurora_root = Node3D.new()
	_medical_m2_aurora_root.name = "MedicalM2Aurora"
	if track_root != null:
		track_root.add_child(_medical_m2_aurora_root)
	else:
		add_child(_medical_m2_aurora_root)
	# 钉在跑道两侧和高空，不跟镜头。比上一版更大、更亮，仍从旁边掠过。
	var spots: Array[Dictionary] = [
		{"d": 72.0, "side": -1.0, "lat": 28.0, "y": 42.0, "w": 40.0, "h": 58.0, "purple": true},
		{"d": 72.0, "side": 1.0, "lat": 30.0, "y": 44.0, "w": 36.0, "h": 56.0, "purple": false},
		{"d": 150.0, "side": -1.0, "lat": 24.0, "y": 48.0, "w": 44.0, "h": 62.0, "purple": false},
		{"d": 150.0, "side": 1.0, "lat": 26.0, "y": 46.0, "w": 38.0, "h": 60.0, "purple": true},
		{"d": 230.0, "side": -1.0, "lat": 32.0, "y": 44.0, "w": 42.0, "h": 58.0, "purple": true},
		{"d": 230.0, "side": 1.0, "lat": 22.0, "y": 50.0, "w": 40.0, "h": 64.0, "purple": false},
		{"d": 320.0, "side": -1.0, "lat": 26.0, "y": 47.0, "w": 46.0, "h": 60.0, "purple": false},
		{"d": 320.0, "side": 1.0, "lat": 34.0, "y": 43.0, "w": 38.0, "h": 56.0, "purple": true},
		{"d": 400.0, "side": -1.0, "lat": 20.0, "y": 52.0, "w": 48.0, "h": 66.0, "purple": true},
		{"d": 400.0, "side": 1.0, "lat": 28.0, "y": 48.0, "w": 42.0, "h": 60.0, "purple": false},
	]
	for i in spots.size():
		var spot: Dictionary = spots[i]
		var purple := bool(spot.get("purple", true))
		var color_a := Color(0.68, 0.42, 1.0, 0.34) if purple else Color(0.38, 0.82, 1.0, 0.32)
		var color_b := Color(0.40, 0.88, 1.0, 0.26) if purple else Color(0.78, 0.46, 1.0, 0.26)
		_add_medical_m2_aurora_curtain(
			i,
			float(spot["d"]),
			float(spot["side"]) * float(spot["lat"]),
			float(spot["y"]),
			float(spot["w"]),
			float(spot["h"]),
			color_a,
			color_b,
			0.028 + float(i) * 0.006,
			float(i) * 1.7
		)


func _add_medical_m2_aurora_curtain(
	index: int,
	distance: float,
	lateral: float,
	height: float,
	width: float,
	tall: float,
	color_a: Color,
	color_b: Color,
	speed: float,
	band_seed: float
) -> void:
	var placed := _world_on_path(distance, lateral, GROUND_Y + height)
	var sample := _sample_path(distance)
	var quad := QuadMesh.new()
	quad.size = Vector2(width, tall)
	var mesh := MeshInstance3D.new()
	mesh.name = "AuroraCurtain_%d" % index
	mesh.mesh = quad
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := ShaderMaterial.new()
	mat.shader = W1_SKY_AURORA_SHADER
	mat.render_priority = -90 + index
	mat.set_shader_parameter("color_a", color_a)
	mat.set_shader_parameter("color_b", color_b)
	mat.set_shader_parameter("scroll_speed", speed)
	mat.set_shader_parameter("band_seed", band_seed)
	mat.set_shader_parameter("horizon_glow", 0.42)
	mat.set_shader_parameter("float_strength", 0.55)
	mesh.material_override = mat
	var pos: Vector3 = placed["pos"]
	mesh.position = pos
	# 面向跑道，让玩家往前跑时从侧面掠过，而不是贴在镜头上
	mesh.rotation.y = float(sample.get("yaw", 0.0)) + PI
	_medical_m2_aurora_root.add_child(mesh)


func _build_void_surroundings_for_energy_road() -> void:
	# 极暗地面托底：顶面贴近路肩下沿，避免两侧露出垂直缝
	var mat := _make_material(Color(0.015, 0.02, 0.035), Color(0.05, 0.12, 0.2), 0.05)
	var lane_y := GROUND_Y - 0.05
	var pad_y := lane_y - 0.055
	var d := 0.0
	var track_end := maxf(_path_length, _track_length) + 40.0
	while d < track_end:
		var sample := _sample_path(d)
		var pad := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(56.0, 0.05, 20.0)
		mesh.material = mat
		pad.mesh = mesh
		pad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pad.position = (sample["pos"] as Vector3) + Vector3(0.0, pad_y, 0.0)
		pad.rotation.y = float(sample["yaw"])
		track_root.add_child(pad)
		d += 18.0

func _surroundings_foundation_half() -> float:
	match _road_style_id:
		"coarse_desert":
			return 16.0
		"planet":
			return 14.0
		_:
			return 21.0

func _spawn_alien_energy_edge_particles() -> void:
	_road_edge_particles.clear()
	if player == null:
		return
	for side in [-1.0, 1.0]:
		var fx := GPUParticles3D.new()
		fx.name = "AlienEdgeDust_%s" % ("L" if side < 0.0 else "R")
		fx.amount = 14
		fx.lifetime = 1.15
		fx.explosiveness = 0.0
		fx.randomness = 0.35
		fx.fixed_fps = 20
		fx.visibility_aabb = AABB(Vector3(-8, -2, -20), Vector3(16, 6, 40))
		var mesh := SphereMesh.new()
		mesh.radius = 0.03
		mesh.height = 0.06
		mesh.radial_segments = 6
		mesh.rings = 3
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.45, 0.92, 1.0, 0.65)
		mat.emission_enabled = true
		mat.emission = Color(0.35, 0.9, 1.0)
		mat.emission_energy_multiplier = 1.2
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh.material = mat
		fx.draw_pass_1 = mesh
		var proc := ParticleProcessMaterial.new()
		proc.direction = Vector3(0, 0.15, -1)
		proc.spread = 12.0
		proc.initial_velocity_min = 0.4
		proc.initial_velocity_max = 1.6
		proc.gravity = Vector3(0, 0.05, 0)
		proc.scale_min = 0.35
		proc.scale_max = 1.0
		proc.color = Color(0.55, 0.95, 1.0, 0.7)
		fx.process_material = proc
		fx.position = Vector3(side * 5.9, 0.15, -2.0)
		player.add_child(fx)
		fx.emitting = true
		_road_edge_particles.append(fx)

func _spawn_holographic_edge_particles() -> void:
	_spawn_alien_energy_edge_particles()

func _build_desert_surroundings(_theme: Dictionary = {}) -> void:
	# 环境沙地：W1 等任务可开贴图沙面；跑道仍保持 holographic，不共用贴地材质
	if not _path_baked or _path_samples.is_empty():
		_bake_track_path()
		_path_baked = true
	var old := track_root.get_node_or_null("DesertSurroundings")
	if old != null:
		old.queue_free()
	var sand_material: Material
	if _mission_uses_textured_ground():
		sand_material = _make_desert_surroundings_material()
	else:
		sand_material = _make_material(Color(0.58, 0.38, 0.22), Color(0.7, 0.45, 0.22), 0.1)
	var root := Node3D.new()
	root.name = "DesertSurroundings"
	track_root.add_child(root)
	var track_end := maxf(_path_length, _track_length) + 48.0
	_build_desert_path_shoulder_strips(root, sand_material, track_end)
	_build_desert_outer_sand_fields(root, sand_material, track_end)
	if _mission_uses_textured_ground():
		_build_desert_sand_inner_lips(root, sand_material, track_end)
	if _road_style_id == "holographic" and _mission_uses_textured_ground():
		_build_runway_edge_fillers(root, track_end)

func _build_desert_path_shoulder_strips(parent: Node3D, sand_material: Material, track_end: float) -> void:
	var lane_y := GROUND_Y - 0.05
	var road_half := _holographic_road_half() if _road_style_id == "holographic" else 6.3
	var step := 1.75 if _road_style_id == "holographic" else 2.2
	var pad_y := _desert_ground_y(lane_y)
	var pad_half := _desert_shoulder_half_width()
	_attach_path_strip_to_parent(
		parent, 0.0, track_end, pad_half, pad_y, sand_material, step, 0.0,
		0.28, true, false, true
	)
	if not _mission_uses_textured_ground():
		return
	for side_sign: float in [-1.0, 1.0]:
		var inner_left := side_sign > 0.0
		var bias: float = side_sign * (road_half + 1.0)
		_attach_path_strip_to_parent(
			parent, 0.0, track_end, 2.4, pad_y, sand_material, step, bias,
			0.38, inner_left, true, false
		)
		bias = side_sign * (road_half + 3.6)
		_attach_path_strip_to_parent(
			parent, 0.0, track_end, 2.5, pad_y, sand_material, step, bias,
			0.42, inner_left, true, false
		)
		bias = side_sign * (road_half + 6.4)
		_attach_path_strip_to_parent(
			parent, 0.0, track_end, 2.8, pad_y, sand_material, step, bias,
			0.46, inner_left, true, false
		)
		bias = side_sign * (road_half + 9.2)
		_attach_path_strip_to_parent(
			parent, 0.0, track_end, 3.0, pad_y, sand_material, step, bias,
			0.5, inner_left, true, false
		)

func _build_desert_outer_sand_fields(parent: Node3D, sand_material: Material, track_end: float) -> void:
	var lane_y := GROUND_Y - 0.05
	var road_half := 6.0 if _road_style_id == "holographic" else 6.3
	var segment_len := 32.0 if _mission_uses_textured_ground() else 96.0
	var segment_count := int(ceil((track_end + 72.0) / segment_len))
	var sand_half_w := 28.0 if _mission_uses_textured_ground() else 23.0
	# 外场沙盒内沿贴近跑道（原 6.8m 太远，侧视会露出宽黑缝）
	var sand_inner := road_half + (0.55 if _mission_uses_textured_ground() else _surroundings_foundation_half())
	var sand_center := sand_inner + sand_half_w
	var sand_height := 0.08
	var sand_top_y := _desert_ground_y(lane_y)
	var sand_y := sand_top_y - sand_height * 0.5

	for segment_index in segment_count:
		var d := float(segment_index) * segment_len + segment_len * 0.5
		var sample := _sample_path(minf(d, track_end))
		var origin: Vector3 = sample["pos"]
		var right: Vector3 = sample["right"]
		var yaw: float = float(sample["yaw"])
		for side: float in [-1.0, 1.0]:
			var sand := MeshInstance3D.new()
			var sand_mesh := BoxMesh.new()
			sand_mesh.size = Vector3(sand_half_w * 2.0, sand_height, segment_len + 0.35)
			sand_mesh.material = sand_material
			sand.mesh = sand_mesh
			sand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			sand.position = origin + right * (side * sand_center)
			sand.position.y = sand_y
			sand.rotation.y = yaw
			parent.add_child(sand)

func _build_desert_sand_inner_lips(parent: Node3D, sand_material: Material, track_end: float) -> void:
	# 外场 Box 内沿竖直面用水平薄带盖住
	var lane_y := GROUND_Y - 0.05
	var road_half := _holographic_road_half() if _road_style_id == "holographic" else 6.3
	var lip_y := _desert_ground_y(lane_y)
	var sand_inner := road_half + 0.55
	var step := 1.75 if _road_style_id == "holographic" else 2.2
	for side_sign: float in [-1.0, 1.0]:
		var inner_left := side_sign > 0.0
		var bias: float = side_sign * (sand_inner + 0.85)
		_attach_path_strip_to_parent(
			parent, 0.0, track_end, 1.6, lip_y, sand_material, step, bias,
			0.36, inner_left, true, false
		)

func _build_runway_edge_fillers(parent: Node3D, track_end: float) -> void:
	# 水源据点用通道中景形成两侧体积，不再把原尺寸珊瑚贴在跑道边
	if _is_reservoir_location():
		return
	# 仅作少量点缀：几何合缝后仍可见的小缝才用晶体掩饰
	var filler_root := Node3D.new()
	filler_root.name = "RunwayEdgeFillers"
	parent.add_child(filler_root)
	var road_half := 6.0
	var lane_y := GROUND_Y - 0.05
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(String(mission.get("mission_id", "runner")) + "_edge_fill_v3")
	var d := 22.0
	var slot := 0
	while d < track_end:
		if _is_gate_location() and not _fork_zone_covering(d, 16.0).is_empty():
			d += rng.randf_range(16.0, 24.0)
			continue
		if rng.randf() < 0.42:
			d += rng.randf_range(16.0, 24.0)
			continue
		for side_sign: float in [-1.0, 1.0]:
			if rng.randf() < 0.55:
				continue
			var path := RUNWAY_EDGE_FILLER_PATHS[slot % RUNWAY_EDGE_FILLER_PATHS.size()]
			slot += 1
			var scene := _load_runner_scene(path, false)
			if scene == null:
				continue
			var sample := _sample_path(d)
			var right: Vector3 = sample["right"]
			var yaw := float(sample["yaw"])
			var inst := scene.instantiate() as Node3D
			filler_root.add_child(inst)
			var prop_pos: Vector3 = sample["pos"] + right * (
				side_sign * rng.randf_range(road_half + 0.85, road_half + 2.0)
			)
			prop_pos.y = lane_y - rng.randf_range(0.02, 0.08)
			inst.position = prop_pos
			inst.rotation.y = yaw + side_sign * rng.randf_range(0.1, 0.5)
			var sc := rng.randf_range(0.14, 0.28)
			inst.scale = Vector3(sc, sc * rng.randf_range(0.55, 0.82), sc)
			if _is_gate_location():
				_clamp_edge_filler_off_runway(inst, d, side_sign, road_half)
			_disable_mesh_shadows(inst)
		d += rng.randf_range(18.0, 28.0)

func _build_path_side_dressing(_theme: Dictionary) -> void:
	_build_midground_dressing(_theme)
	if _is_reservoir_location():
		_build_reservoir_channel_dressing()
	else:
		_build_near_runway_dressing(_theme)
	if _uses_ruin_dressing():
		_build_ruin_silhouette_backdrop()
	if _uses_runway_side_lights():
		_build_runway_side_lights()


func _should_skip_channel_at(distance: float) -> bool:
	if distance < START_PAD_LENGTH + 6.0:
		return true
	for zone in _side_runway_zones():
		var pit: Vector2 = _side_runway_pit_range(zone)
		if distance >= pit.x - 6.0 and distance <= pit.y + 6.0:
			return true
	for gap in _main_block_road_gaps():
		if typeof(gap) == TYPE_VECTOR2 and distance >= gap.x - 4.0 and distance <= gap.y + 4.0:
			return true
	var finish_d := _finish_line_distance if _finish_line_distance > 0.0 else maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)
	if distance >= finish_d - 28.0:
		return true
	return false


func _reservoir_channel_segments() -> Array:
	var segs: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("reservoir_channel_seg_v7_" + _mission_id_str())
	var catalog: Array[String] = [
		"arch_tree",
		"stagger",
		"meteorite",
		"stagger",
		"arch_tree",
		"open",
		"stagger",
		"meteorite",
	]
	var rot := 0 if _mission_id_str() == "mission_reservoir_01" else absi(_mission_id_str().hash()) % catalog.size()
	var track_end := maxf(_path_length, _track_length)
	var d := START_PAD_LENGTH + 8.0
	if _mission_id_str() == "mission_reservoir_01":
		segs.append({"start": d, "end": d + 68.0, "mode": "opening"})
		d += 68.0
	var slot := 0
	while d < track_end - 20.0:
		var mode := catalog[(rot + slot) % catalog.size()]
		var length := 44.0
		match mode:
			"arch_tree":
				length = rng.randf_range(46.0, 64.0)
			"meteorite":
				length = rng.randf_range(34.0, 50.0)
			"open":
				length = rng.randf_range(26.0, 38.0)
			_:
				length = rng.randf_range(38.0, 54.0)
		segs.append({"start": d, "end": d + length, "mode": mode})
		d += length
		slot += 1
	return segs


func _reservoir_side_segments() -> Array:
	return _reservoir_channel_segments()


func _reservoir_side_mode_at(distance: float) -> String:
	for raw in _reservoir_channel_segments():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = raw
		if distance >= float(seg.get("start", 0.0)) and distance < float(seg.get("end", 0.0)):
			return String(seg.get("mode", "stagger"))
	return "stagger"


func _reservoir_mode_arches_side(mode: String, lateral: float) -> bool:
	match mode:
		"arch_tree":
			return true
		"stagger", "meteorite":
			return true
		"open", "opening":
			return false
		_:
			return false


func _build_reservoir_channel_dressing() -> void:
	_ensure_side_dressing_root()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("reservoir_channel_v6_" + _mission_id_str())
	for raw in _reservoir_channel_segments():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var seg: Dictionary = raw
		var mode := String(seg.get("mode", "stagger"))
		var d := float(seg.get("start", 0.0))
		var seg_end := float(seg.get("end", 0.0))
		var step := 18.0
		match mode:
			"arch_tree":
				step = rng.randf_range(15.0, 19.0)
			"meteorite":
				step = rng.randf_range(18.0, 26.0)
			"open":
				step = rng.randf_range(18.0, 24.0)
			"opening":
				step = rng.randf_range(30.0, 40.0)
			_:
				step = rng.randf_range(16.0, 22.0)
		while d < seg_end - 6.0:
			if _should_skip_channel_at(d):
				d += rng.randf_range(8.0, 12.0)
				continue
			match mode:
				"arch_tree":
					_spawn_reservoir_tree_arch(d, rng)
				"meteorite":
					var rock_side := -1.0 if int(round(d / 14.0)) % 2 == 0 else 1.0
					_spawn_reservoir_meteorite_cluster(d, rock_side, rng)
					var other_kinds: Array[String] = ["billboard", "tree", "coral", "observatory"]
					_spawn_reservoir_side_kind(
						d + rng.randf_range(-2.4, 3.0),
						-rock_side,
						other_kinds[rng.randi() % other_kinds.size()],
						rng
					)
				"opening":
					_spawn_reservoir_opening_prop(d, rng)
				"open":
					if rng.randf() < 0.34:
						_spawn_reservoir_open_prop(d, -1.0 if rng.randf() < 0.5 else 1.0, rng)
				_:
					_spawn_reservoir_stagger_pair(d, rng)
			d += step


func _spawn_reservoir_opening_prop(distance: float, rng: RandomNumberGenerator) -> void:
	var side := -1.0 if int(round(distance / 18.0)) % 2 == 0 else 1.0
	if rng.randf() < 0.55:
		_spawn_reservoir_channel_prop(
			distance,
			side,
			RESERVOIR_CHANNEL_BILLBOARD if rng.randf() < 0.7 else RESERVOIR_SLIDE_BILLBOARD,
			rng.randf_range(3.8, 5.6),
			rng.randf_range(4.8, 7.2),
			0.0,
			3.4,
			rng
		)
		return
	_spawn_reservoir_channel_prop(
		distance,
		side,
		RESERVOIR_CRASHED_SHIP,
		rng.randf_range(4.6, 7.0),
		rng.randf_range(6.4, 9.0),
		rng.randf_range(-4.0, 4.0),
		5.4,
		rng
	)


func _spawn_reservoir_tree_arch(distance: float, rng: RandomNumberGenerator) -> void:
	for side: float in [-1.0, 1.0]:
		_spawn_reservoir_channel_prop(
			distance + rng.randf_range(-1.2, 1.2),
			side,
			RESERVOIR_CHANNEL_CORAL,
			rng.randf_range(8.2, 11.4),
			rng.randf_range(2.2, 3.2),
			rng.randf_range(24.0, 34.0),
			3.0,
			rng
		)
		_spawn_reservoir_channel_prop(
			distance + 3.0 + rng.randf_range(-0.8, 0.8),
			side,
			RESERVOIR_CHANNEL_TREE,
			rng.randf_range(12.4, 16.8),
			rng.randf_range(4.0, 5.8),
			rng.randf_range(22.0, 32.0),
			4.6,
			rng
		)


func _spawn_reservoir_stagger_pair(distance: float, rng: RandomNumberGenerator) -> void:
	var kinds: Array[String] = ["billboard", "observatory", "coral", "tree", "meteorite"]
	var left := kinds[rng.randi() % kinds.size()]
	var right := kinds[rng.randi() % kinds.size()]
	if right == left or (left == "meteorite" and right == "meteorite"):
		right = kinds[(kinds.find(left) + 2) % kinds.size()]
	_spawn_reservoir_side_kind(distance, -1.0, left, rng)
	_spawn_reservoir_side_kind(distance + rng.randf_range(-2.6, 3.2), 1.0, right, rng)


func _spawn_reservoir_meteorite_cluster(distance: float, side: float, rng: RandomNumberGenerator) -> void:
	var count := rng.randi_range(1, 2)
	for i in count:
		var size_roll := rng.randf()
		var height := 4.2
		var footprint := 3.2
		var inset := 4.2
		if size_roll < 0.38:
			height = rng.randf_range(2.2, 3.8)
			footprint = rng.randf_range(1.6, 2.6)
			inset = rng.randf_range(2.8, 4.4)
		elif size_roll < 0.78:
			height = rng.randf_range(5.0, 7.4)
			footprint = rng.randf_range(2.8, 4.2)
			inset = rng.randf_range(3.8, 6.0)
		else:
			height = rng.randf_range(9.0, 13.0)
			footprint = rng.randf_range(4.6, 6.8)
			inset = rng.randf_range(5.2, 7.8)
		_spawn_reservoir_channel_prop(
			distance + rng.randf_range(-5.2, 6.0) + float(i) * rng.randf_range(2.4, 4.2),
			side,
			OBSTACLE_PROP_METEORITE,
			height,
			inset + rng.randf_range(-0.6, 1.2),
			rng.randf_range(0.0, 6.0),
			footprint,
			rng
		)


func _spawn_reservoir_side_kind(distance: float, side: float, kind: String, rng: RandomNumberGenerator) -> void:
	match kind:
		"tree":
			_spawn_reservoir_channel_prop(
				distance,
				side,
				RESERVOIR_CHANNEL_TREE,
				rng.randf_range(8.6, 12.4),
				rng.randf_range(3.2, 5.0),
				rng.randf_range(6.0, 14.0),
				4.4,
				rng
			)
		"coral":
			_spawn_reservoir_channel_prop(
				distance,
				side,
				RESERVOIR_CHANNEL_CORAL,
				rng.randf_range(6.4, 9.8),
				rng.randf_range(2.6, 4.2),
				rng.randf_range(4.0, 12.0),
				3.4,
				rng
			)
		"meteorite":
			_spawn_reservoir_meteorite_cluster(distance, side, rng)
		"billboard":
			var billboard := RESERVOIR_CHANNEL_BILLBOARD if rng.randf() < 0.62 else RESERVOIR_SLIDE_BILLBOARD
			_spawn_reservoir_channel_prop(
				distance,
				side,
				billboard,
				rng.randf_range(5.2, 7.8),
				rng.randf_range(3.2, 5.4),
				rng.randf_range(0.0, 6.0),
				3.8,
				rng
			)
		"observatory":
			var observatory := RESERVOIR_CHANNEL_OBSERVATORY if rng.randf() < 0.7 else RESERVOIR_CHANNEL_OBSERVATORY_ALT
			_spawn_reservoir_channel_prop(
				distance,
				side,
				observatory,
				rng.randf_range(6.2, 9.2),
				rng.randf_range(5.0, 7.2),
				rng.randf_range(3.0, 10.0),
				5.6,
				rng
			)
		_:
			if rng.randf() < 0.22:
				_spawn_reservoir_open_prop(distance, side, rng)


func _spawn_reservoir_open_prop(distance: float, side: float, rng: RandomNumberGenerator) -> void:
	var path := RESERVOIR_CHANNEL_BILLBOARD
	if rng.randf() < 0.38:
		path = OBSTACLE_PROP_EXCAVATOR
	_spawn_reservoir_channel_prop(
		distance,
		side,
		path,
		rng.randf_range(2.2, 3.6),
		rng.randf_range(6.5, 9.5),
		0.0,
		3.6,
		rng
	)


func _spawn_reservoir_channel_prop(
	distance: float,
	side: float,
	asset_path: String,
	target_height: float,
	edge_inset: float,
	lean_deg: float,
	max_footprint: float,
	rng: RandomNumberGenerator
) -> void:
	var scene := _load_runner_scene(asset_path, false)
	if scene == null:
		return
	var road_half := _holographic_road_half() if _road_style_id == "holographic" else 6.2
	var lateral := side * (road_half + edge_inset)
	var root := Node3D.new()
	root.name = "ChannelProp_%d" % _side_dressing_root.get_child_count()
	_side_dressing_root.add_child(root)
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	root.position = placed["pos"]
	var path_yaw := float(placed["yaw"])
	if _is_channel_billboard_prop(asset_path):
		root.rotation.y = path_yaw + PI if side < 0.0 else path_yaw
		root.rotation.y += rng.randf_range(-0.08, 0.08)
	else:
		root.rotation.y = path_yaw
	root.set_meta("path_distance", distance)
	var model := _add_scaled_model_visual(
		root,
		scene,
		"ChannelPropModel",
		target_height,
		rng.randf_range(-8.0, 8.0),
		Vector3.ZERO,
		-1.0,
		MIDGROUND_SCALE_CAP,
		true
	)
	if model:
		_squash_midground_footprint_keep_height(model, max_footprint)
	_resit_midground_on_ground(root)
	if absf(lean_deg) > 0.5:
		var forward: Vector3 = placed["forward"]
		root.rotate(forward, deg_to_rad(lean_deg) * (-1.0 if lateral > 0.0 else 1.0))
		_resit_midground_on_ground(root, 1.05)
	_preserve_midground_materials(root)
	if _is_midground_meteorite(asset_path):
		_apply_midground_meteorite_variant(root, _pick_meteorite_palette(rng, distance, lateral))
	elif _is_reservoir_crystal_prop(asset_path):
		_apply_reservoir_crystal_look(root, rng, distance, lateral)
	_disable_mesh_shadows(root)

func _build_midground_dressing(_theme: Dictionary) -> void:
	_ensure_midground_prop_paths()
	if _midground_prop_paths.is_empty():
		return
	_ensure_side_dressing_root()

	var planet_key := "runner"
	if LevelConfig.has_method("get_planet_id"):
		planet_key = String(LevelConfig.get_planet_id())
	var track_end := maxf(_path_length, _track_length) + 48.0
	_build_midground_dressing_pass(
		planet_key + "_midground_v5_" + String(Global.runner_location_id) + "_" + String(Global.runner_mission_id),
		_midground_prop_paths_filtered(false),
		track_end
	)
	_build_midground_dressing_pass(
		planet_key + "_midground_robot_v1_" + String(Global.runner_location_id) + "_" + String(Global.runner_mission_id),
		_midground_robot_prop_paths(),
		track_end,
		START_PAD_LENGTH + 19.0
	)

func _midground_density_scale() -> float:
	var base := 1.0
	match _runner_visual_batch():
		"crisis":
			base = 0.68
		"early":
			base = 0.88
		_:
			base = 1.0
	if _uses_ruin_dressing():
		base *= 1.10
	if _is_relay_mission():
		match _mission_id_str():
			"mission_relay_e1":
				base *= 0.92
			"mission_relay_e2":
				base *= 1.08
			"mission_relay_e3":
				base *= 1.00
			"mission_relay_e4":
				base *= 1.14
	return base

func _build_near_runway_dressing(_theme: Dictionary) -> void:
	if _near_runway_prop_paths.is_empty():
		return
	_ensure_side_dressing_root()
	var planet_key := "runner"
	if LevelConfig.has_method("get_planet_id"):
		planet_key = String(LevelConfig.get_planet_id())
	var track_end := maxf(_path_length, _track_length) + 48.0
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(planet_key + "_near_runway_" + String(Global.runner_location_id) + "_" + String(Global.runner_mission_id))
	var d := START_PAD_LENGTH + 14.0
	while d < track_end - 24.0:
		if _should_skip_midground_at(d):
			d += rng.randf_range(8.0, 12.0)
			continue
		var path := ""
		if _should_pick_environment_pack_v2(rng):
			path = _pick_environment_pack_v2_path(rng)
		elif not _near_runway_prop_paths.is_empty():
			path = _near_runway_prop_paths[rng.randi() % _near_runway_prop_paths.size()]
		if path == "":
			d += rng.randf_range(14.0, 22.0)
			continue
		if _is_gate_location() and _is_runway_wrapping_prop(path):
			d += rng.randf_range(10.0, 16.0)
			continue
		if _is_reservoir_location() and ("purifier" in path.to_lower() or "coral" in path.to_lower()):
			d += rng.randf_range(14.0, 22.0)
			continue
		var side := -1.0 if rng.randf() > 0.5 else 1.0
		var lateral := side * rng.randf_range(8.5, 11.8)
		var height := rng.randf_range(1.35, 2.15)
		if _is_reservoir_location():
			lateral = side * rng.randf_range(13.6, 17.2)
			if "purifier" in path.to_lower() or "coral" in path.to_lower():
				height = rng.randf_range(8.8, 13.5)
			elif "meteorite" in path.to_lower():
				height = rng.randf_range(6.4, 10.5)
			else:
				height = rng.randf_range(1.6, 2.6)
		elif _is_gate_location():
			if _is_bulky_near_runway_prop(path):
				lateral = side * rng.randf_range(10.2, 13.6)
				height = rng.randf_range(1.8, 2.8)
			else:
				lateral = side * rng.randf_range(9.2, 12.2)
				height = rng.randf_range(1.5, 2.4)
			lateral = _gate_dressing_lateral_outside_runway(d, side, absf(lateral), rng)
		elif "purifier" in path.to_lower() or "coral" in path.to_lower():
			height = rng.randf_range(2.2, 3.4)
		if "pod" in path.to_lower() and not _is_reservoir_location() and not _is_gate_location():
			height = rng.randf_range(1.8, 2.8)
		_spawn_midground_prop(d, lateral, path, height, rng, 0.85, _is_gate_location())
		d += rng.randf_range(14.0, 22.0)


func _build_runway_side_lights() -> void:
	var old := track_root.get_node_or_null("RunwaySideLights")
	if old != null:
		old.queue_free()
	_runway_side_lights_root = Node3D.new()
	_runway_side_lights_root.name = "RunwaySideLights"
	track_root.add_child(_runway_side_lights_root)
	var track_end := maxf(_path_length, _track_length) + 48.0
	var d := 10.0
	var slot := 0
	while d < track_end:
		for side_sign: float in [-1.0, 1.0]:
			_spawn_runway_side_lamp(_runway_side_lights_root, d, side_sign, slot)
		d += 14.0 if slot % 3 != 2 else 16.5
		slot += 1


func _spawn_runway_side_lamp(parent: Node3D, distance: float, side: float, slot: int) -> void:
	var road_half := _holographic_road_half() if _road_style_id == "holographic" else 6.2
	var lateral := side * (road_half + 1.05)
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	var anchor := Node3D.new()
	anchor.name = "SideLamp_%d_%s" % [slot, "L" if side < 0.0 else "R"]
	anchor.position = placed["pos"]
	anchor.position.y = GROUND_Y + 0.02
	anchor.rotation.y = float(placed["yaw"])
	anchor.set_meta("path_distance", distance)
	parent.add_child(anchor)

	var rail := MeshInstance3D.new()
	var rail_mesh := BoxMesh.new()
	rail_mesh.size = Vector3(0.14, 0.92, 0.22)
	var rail_mat := StandardMaterial3D.new()
	rail_mat.albedo_color = Color(0.07, 0.06, 0.08)
	rail.mesh = rail_mesh
	rail.mesh.material = rail_mat
	rail.position = Vector3(0.0, 0.46, 0.0)
	rail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	anchor.add_child(rail)

	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(0.34, 0.18, 0.24)
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(1.0, 0.62, 0.28)
	head_mat.emission_enabled = true
	head_mat.emission = Color(1.0, 0.52, 0.16)
	head_mat.emission_energy_multiplier = 2.2
	head.mesh = head_mesh
	head.mesh.material = head_mat
	head.position = Vector3(0.0, 0.98, 0.0)
	head.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	anchor.add_child(head)

	var light := OmniLight3D.new()
	light.name = "WarmLantern"
	light.light_color = Color(1.0, 0.58, 0.22)
	light.light_energy = 0.78
	light.omni_range = 10.5
	light.omni_attenuation = 1.42
	light.shadow_enabled = false
	light.position = Vector3(0.0, 1.02, 0.0)
	anchor.add_child(light)


func _build_ruin_silhouette_backdrop() -> void:
	var old := track_root.get_node_or_null("RuinSilhouettes")
	if old != null:
		old.queue_free()
	_ruin_backdrop_root = Node3D.new()
	_ruin_backdrop_root.name = "RuinSilhouettes"
	track_root.add_child(_ruin_backdrop_root)
	var track_end := maxf(_path_length, _track_length) + 48.0
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_mission_id_str() + "_ruin_sil_v1")
	var d := 32.0
	while d < track_end:
		if _should_skip_midground_at(d):
			d += rng.randf_range(10.0, 14.0)
			continue
		for side: float in [-1.0, 1.0]:
			if rng.randf() < 0.28:
				continue
			var lateral := side * rng.randf_range(20.0, 33.0)
			var cluster := Node3D.new()
			cluster.name = "RuinCluster_%d" % _ruin_backdrop_root.get_child_count()
			var placed := _world_on_path(d, lateral, GROUND_Y)
			cluster.position = placed["pos"]
			cluster.rotation.y = float(placed["yaw"]) + rng.randf_range(-0.24, 0.24)
			cluster.set_meta("path_distance", d)
			cluster.set_meta("scene_layer", "ruin")
			_ruin_backdrop_root.add_child(cluster)
			var count := rng.randi_range(2, 5)
			for _i in count:
				var h := rng.randf_range(3.8, 13.5)
				var w := rng.randf_range(1.1, 3.2)
				var box := MeshInstance3D.new()
				var bm := BoxMesh.new()
				bm.size = Vector3(w, h, w * rng.randf_range(0.55, 1.15))
				var mat := StandardMaterial3D.new()
				mat.albedo_color = Color(0.035, 0.03, 0.04)
				mat.emission_enabled = true
				mat.emission = Color(0.10, 0.07, 0.14)
				mat.emission_energy_multiplier = 0.12
				bm.material = mat
				box.mesh = bm
				box.position = Vector3(
					rng.randf_range(-2.8, 2.8),
					h * 0.5,
					rng.randf_range(-2.2, 2.2)
				)
				box.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				cluster.add_child(box)
		d += rng.randf_range(16.0, 26.0)


func _midground_prop_paths_filtered(include_robots: bool) -> Array[String]:
	var out: Array[String] = []
	for path in _midground_prop_paths:
		var is_robot := _is_midground_robot(path)
		if include_robots:
			if is_robot:
				out.append(path)
		elif not is_robot:
			if _is_reservoir_location() and _is_midground_meteorite(path):
				continue
			out.append(path)
	return out

func _midground_robot_prop_paths() -> Array[String]:
	return _midground_prop_paths_filtered(true)

func _build_midground_dressing_pass(
	seed_key: String,
	prop_paths: Array[String],
	track_end: float,
	start_distance: float = START_PAD_LENGTH + 8.0
) -> void:
	if prop_paths.is_empty():
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seed_key)

	var d := start_distance
	var slot_i := 0
	var spawned := 0
	while d < track_end - 30.0:
		if _should_skip_midground_at(d):
			d += rng.randf_range(10.0, 16.0)
			continue
		var phase := _midground_phase_weight(d)
		var asset_path := _pick_midground_asset_path(rng, phase, prop_paths)
		if asset_path == "":
			d += rng.randf_range(MIDGROUND_CLUSTER_SPACING_MIN, MIDGROUND_CLUSTER_SPACING_MAX)
			slot_i += 1
			continue
		if _is_reservoir_location() and (
			"purifier" in asset_path.to_lower() or "coral" in asset_path.to_lower()
		):
			d += rng.randf_range(14.0, 20.0)
			slot_i += 1
			continue
		var spec := _midground_spec_for_path(asset_path)
		var sides := _pick_midground_sides(rng, asset_path)
		for side_i in sides.size():
			var side: float = float(sides[side_i])
			var fork_push := MIDGROUND_FORK_PUSH if _is_in_fork_main_gap(d) else 0.0
			var lat_min := float(spec.get("lateral_min", MIDGROUND_LATERAL_MIN))
			var lat_max := float(spec.get("lateral_max", MIDGROUND_LATERAL_MAX))
			if _is_midground_neon_sign(asset_path):
				if side < 0.0:
					lat_min = 17.5
					lat_max = 21.5
				else:
					lat_min = 14.0
					lat_max = 18.0
			var lateral := side * rng.randf_range(lat_min, lat_max + fork_push)
			var cluster_count := rng.randi_range(
				int(spec.get("cluster_min", 1)),
				int(spec.get("cluster_max", 2))
			)
			if float(spec.get("cluster_chance", 0.0)) > rng.randf():
				cluster_count = rng.randi_range(int(spec.get("cluster_min", 2)), int(spec.get("cluster_max", 3)))
			for ci in cluster_count:
				var offset_d := d + float(ci) * rng.randf_range(1.8, 4.2)
				if side_i > 0:
					offset_d += rng.randf_range(1.5, 5.0)
				var offset_lat := lateral + float(ci - cluster_count * 0.5) * rng.randf_range(0.8, 1.6)
				if _is_gate_location():
					offset_lat = _gate_dressing_lateral_outside_runway(offset_d, side, absf(offset_lat), rng)
				var target_h := _midground_target_height(rng, asset_path, side, spec)
				if _spawn_midground_prop(
					offset_d,
					offset_lat,
					asset_path,
					target_h,
					rng,
					float(spec.get("emission_boost", 1.0))
				):
					spawned += 1
		if _is_midground_meteorite(asset_path) and phase != "warmup" and rng.randf() < 0.0:
			spawned += _spawn_meteorite_scatter(d, rng, asset_path, spec)
		var spacing_min := MIDGROUND_CLUSTER_SPACING_MIN * _midground_density_scale()
		var spacing_max := MIDGROUND_CLUSTER_SPACING_MAX * _midground_density_scale()
		if phase == "late":
			spacing_min = 16.0
			spacing_max = 24.0
		elif phase == "mid":
			spacing_min = 18.0
			spacing_max = 27.0
		if _is_midground_robot(asset_path):
			spacing_min = 22.0
			spacing_max = 32.0
		d += rng.randf_range(spacing_min, spacing_max)
		slot_i += 1
	if spawned == 0 and not seed_key.contains("robot"):
		push_warning("Midground dressing spawned 0 props; check GLB paths under models/environment/midground/")

func _midground_target_height(
	rng: RandomNumberGenerator,
	asset_path: String,
	side: float,
	spec: Dictionary
) -> float:
	if _is_midground_neon_sign(asset_path):
		if side < 0.0:
			return rng.randf_range(2.5, 3.0)
		return rng.randf_range(3.8, 4.4)
	return rng.randf_range(
		float(spec.get("height_min", 2.0)),
		float(spec.get("height_max", 3.5))
	)

func _pick_midground_sides(rng: RandomNumberGenerator, asset_path: String) -> Array:
	# 随机单侧为主，偶尔成对；避免严格左右交替
	var sides: Array = []
	if _is_midground_neon_sign(asset_path):
		if rng.randf() < 0.14:
			var first := 1.0 if rng.randf() > 0.5 else -1.0
			sides.append(first)
			sides.append(-first)
		else:
			sides.append(1.0 if rng.randf() > 0.5 else -1.0)
	elif _is_reservoir_location() and _is_channel_midground_prop(asset_path):
		if rng.randf() < 0.18:
			sides.append(1.0)
			sides.append(-1.0)
		else:
			sides.append(1.0 if rng.randf() > 0.5 else -1.0)
	elif rng.randf() < 0.12:
		sides.append(1.0)
		sides.append(-1.0)
	else:
		sides.append(1.0 if rng.randf() > 0.5 else -1.0)
	return sides

func _is_midground_neon_sign(path: String) -> bool:
	var lower := path.to_lower()
	return "neon_sign" in lower or "neon+sign" in lower


func _is_channel_billboard_prop(path: String) -> bool:
	var lower := path.to_lower()
	return (
		_is_midground_neon_sign(path)
		or "广告牌" in path
		or "billboard" in lower
	)

func _is_midground_meteorite(path: String) -> bool:
	var lower := path.to_lower()
	return "meteorite" in lower or "energy_meteorite" in lower


func _is_reservoir_crystal_prop(path: String) -> bool:
	var lower := path.to_lower()
	return "purifier" in lower or "coral" in lower or "crystal_coral" in lower


func _apply_reservoir_crystal_look(root: Node3D, rng: RandomNumberGenerator, distance: float, lateral: float) -> void:
	if root == null:
		return
	var palettes: Array[Dictionary] = [
		{"albedo": Color(0.82, 0.62, 0.38), "emission": Color(0.62, 0.34, 0.12), "energy": 0.38},
		{"albedo": Color(0.42, 0.68, 0.70), "emission": Color(0.16, 0.46, 0.50), "energy": 0.34},
		{"albedo": Color(0.88, 0.78, 0.58), "emission": Color(0.52, 0.40, 0.18), "energy": 0.30},
		{"albedo": Color(0.50, 0.60, 0.46), "emission": Color(0.24, 0.42, 0.26), "energy": 0.32},
		{"albedo": Color(0.72, 0.48, 0.36), "emission": Color(0.50, 0.24, 0.12), "energy": 0.36},
	]
	var tint_mix := 0.62
	if _mission_id_str() == "mission_reservoir_03":
		palettes = [
			{"albedo": Color(0.38, 0.66, 0.72), "emission": Color(0.12, 0.42, 0.50), "energy": 0.36},
			{"albedo": Color(0.86, 0.64, 0.32), "emission": Color(0.58, 0.32, 0.10), "energy": 0.34},
			{"albedo": Color(0.46, 0.62, 0.42), "emission": Color(0.20, 0.40, 0.22), "energy": 0.32},
			{"albedo": Color(0.90, 0.76, 0.52), "emission": Color(0.50, 0.36, 0.16), "energy": 0.30},
			{"albedo": Color(0.32, 0.54, 0.68), "emission": Color(0.10, 0.34, 0.48), "energy": 0.38},
		]
		tint_mix = 0.78
	var idx := absi(int(distance * 1.7) + int(lateral * 11.0) + rng.randi_range(0, 2)) % palettes.size()
	var look: Dictionary = palettes[idx]
	var albedo_tint: Color = look.get("albedo", Color(0.78, 0.62, 0.42))
	var emission: Color = look.get("emission", Color(0.48, 0.30, 0.14))
	var energy := clampf(float(look.get("energy", 0.34)), 0.24, 0.48)
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_i in mesh_instance.mesh.get_surface_count():
			var mat := mesh_instance.get_surface_override_material(surface_i)
			if mat == null:
				mat = mesh_instance.mesh.surface_get_material(surface_i)
			if not mat is StandardMaterial3D:
				continue
			var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
			var base := dup.albedo_color
			dup.albedo_color = Color(
				lerpf(base.r, albedo_tint.r, tint_mix),
				lerpf(base.g, albedo_tint.g, tint_mix),
				lerpf(base.b, albedo_tint.b, tint_mix),
				base.a
			)
			dup.metallic = minf(dup.metallic, 0.12)
			dup.roughness = clampf(maxf(dup.roughness, 0.36), 0.36, 0.62)
			dup.rim_enabled = true
			dup.rim = 0.28
			dup.rim_tint = 0.45
			dup.emission_enabled = true
			dup.emission = emission
			dup.emission_energy_multiplier = energy
			mesh_instance.set_surface_override_material(surface_i, dup)


func _is_midground_robot(path: String) -> bool:
	var lower := path.to_lower()
	return "sphere_robot" in lower or "cracked_sphere" in lower or "excavator" in lower or "excavator" in lower or "excavator" in lower

func _pick_meteorite_palette(rng: RandomNumberGenerator, distance: float, lateral: float) -> Dictionary:
	var palettes: Array = MIDGROUND_METEORITE_PALETTES
	if palettes.is_empty():
		return {}
	var idx := absi(int(distance * 2.4) + int(lateral * 17.0) + rng.randi_range(0, palettes.size() - 1)) % palettes.size()
	return palettes[idx] as Dictionary

func _spawn_meteorite_scatter(
	base_d: float,
	rng: RandomNumberGenerator,
	asset_path: String,
	spec: Dictionary
) -> int:
	var spawned := 0
	var scatter_n := rng.randi_range(2, 4)
	for _i in scatter_n:
		var side := 1.0 if rng.randf() > 0.5 else -1.0
		var lateral := side * rng.randf_range(14.5, 21.5)
		var dist := base_d + rng.randf_range(-7.0, 9.0)
		var height := rng.randf_range(
			float(spec.get("height_min", 2.4)) * 0.42,
			float(spec.get("height_max", 4.2)) * 0.68
		)
		if _spawn_midground_prop(dist, lateral, asset_path, height, rng, 1.0):
			spawned += 1
	return spawned

func _ensure_midground_prop_paths() -> void:
	if not _midground_prop_paths.is_empty():
		return
	for path in MIDGROUND_PROP_DEFAULTS:
		_midground_prop_paths.append(path)

func _midground_phase_weight(distance: float) -> String:
	if distance < 180.0:
		return "warmup"
	if distance < 520.0:
		return "mid"
	return "late"

func _pick_midground_asset_path(
	rng: RandomNumberGenerator,
	phase: String,
	paths: Array[String] = []
) -> String:
	var base_pool: Array[String] = paths if not paths.is_empty() else _midground_prop_paths
	if base_pool.is_empty() and _environment_pack_v2_paths.is_empty():
		return ""
	if _should_pick_environment_pack_v2(rng) and not _environment_pack_v2_paths.is_empty():
		var packed := _pick_weighted_midground_from_pool(rng, phase, _environment_pack_v2_paths)
		if not (_is_gate_location() and _is_runway_wrapping_prop(packed)):
			return packed
	if base_pool.is_empty():
		var fallback := _pick_environment_pack_v2_path(rng)
		if _is_gate_location() and _is_runway_wrapping_prop(fallback):
			return ""
		return fallback
	var picked := _pick_weighted_midground_from_pool(rng, phase, base_pool)
	if _is_gate_location() and _is_runway_wrapping_prop(picked):
		return ""
	return picked

func _pick_weighted_midground_from_pool(
	rng: RandomNumberGenerator,
	phase: String,
	pool: Array[String]
) -> String:
	if pool.is_empty():
		return ""
	var weight_key := "weight_%s" % phase
	var total := 0.0
	for path in pool:
		var spec := _midground_spec_for_path(path)
		total += maxf(float(spec.get(weight_key, 0.2)), 0.001)
	if total <= 0.001:
		return pool[rng.randi() % pool.size()]
	var roll := rng.randf() * total
	for path in pool:
		var spec := _midground_spec_for_path(path)
		roll -= maxf(float(spec.get(weight_key, 0.2)), 0.001)
		if roll <= 0.0:
			return path
	return pool[pool.size() - 1]

func _midground_spec_for_path(path: String) -> Dictionary:
	var lower := path.to_lower()
	if "neon_sign" in lower or "neon+sign" in lower:
		return {
			"height_min": 2.6,
			"height_max": 4.4,
			"lateral_min": 14.0,
			"lateral_max": 18.0,
			"cluster_chance": 0.0,
			"cluster_min": 1,
			"cluster_max": 1,
			"emission_boost": 0.55,
			"weight_warmup": 0.15,
			"weight_mid": 0.08,
			"weight_late": 0.05,
		}
	if "meteorite" in lower or "energy_meteorite" in lower:
		if _is_reservoir_location():
			return {
				"height_min": 7.2,
				"height_max": 12.5,
				"lateral_min": 14.5,
				"lateral_max": 19.5,
				"cluster_chance": 0.12,
				"cluster_min": 1,
				"cluster_max": 1,
				"emission_boost": 0.82,
				"weight_warmup": 0.22,
				"weight_mid": 0.30,
				"weight_late": 0.28,
			}
		return {
			"height_min": 2.4,
			"height_max": 4.2,
			"lateral_min": 14.0,
			"lateral_max": 20.5,
			"cluster_chance": 0.12,
			"cluster_min": 1,
			"cluster_max": 1,
			"emission_boost": 0.7,
			"weight_warmup": 0.08,
			"weight_mid": 0.22,
			"weight_late": 0.28,
		}
	if "coral" in lower or "amber" in lower or "crystal_coral" in lower:
		if _is_reservoir_location():
			return {
				"height_min": 9.5,
				"height_max": 16.0,
				"lateral_min": 13.8,
				"lateral_max": 18.2,
				"cluster_chance": 0.10,
				"cluster_min": 1,
				"cluster_max": 1,
				"emission_boost": 0.55,
				"weight_warmup": 0.28,
				"weight_mid": 0.34,
				"weight_late": 0.30,
			}
		return {
			"height_min": 2.8,
			"height_max": 5.0,
			"lateral_min": 13.0,
			"lateral_max": 18.0,
			"cluster_chance": 0.18,
			"cluster_min": 1,
			"cluster_max": 1,
			"emission_boost": 0.65,
			"weight_warmup": 0.14,
			"weight_mid": 0.35,
			"weight_late": 0.28,
		}
	if "water_purifier" in lower:
		if _is_reservoir_location():
			return {
				"height_min": 10.0,
				"height_max": 16.8,
				"lateral_min": 14.2,
				"lateral_max": 18.6,
				"cluster_chance": 0.08,
				"cluster_min": 1,
				"cluster_max": 1,
				"emission_boost": 0.55,
				"weight_warmup": 0.26,
				"weight_mid": 0.32,
				"weight_late": 0.28,
			}
		return {
			"height_min": 2.8,
			"height_max": 5.2,
			"lateral_min": 12.5,
			"lateral_max": 18.5,
			"cluster_chance": 0.24,
			"cluster_min": 1,
			"cluster_max": 2,
			"emission_boost": 0.55,
			"weight_warmup": 0.22,
			"weight_mid": 0.38,
			"weight_late": 0.32,
		}
	if "medical_pod" in lower or "medical_crate" in lower:
		return {
			"height_min": 2.8,
			"height_max": 5.2,
			"lateral_min": 12.5,
			"lateral_max": 18.5,
			"cluster_chance": 0.24,
			"cluster_min": 1,
			"cluster_max": 2,
			"emission_boost": 0.55,
			"weight_warmup": 0.22,
			"weight_mid": 0.38,
			"weight_late": 0.32,
		}
	if "signal_tower" in lower:
		return {
			"height_min": 8.0,
			"height_max": 14.0,
			"lateral_min": 18.0,
			"lateral_max": 28.0,
			"cluster_chance": 0.08,
			"cluster_min": 1,
			"cluster_max": 1,
			"emission_boost": 0.45,
			"weight_warmup": 0.12,
			"weight_mid": 0.28,
			"weight_late": 0.32,
		}
	if "sphere_robot" in lower or "cracked_sphere" in lower or "excavator" in lower:
		if _is_reservoir_location() and "excavator" in lower:
			return {
				"height_min": 2.2,
				"height_max": 3.4,
				"lateral_min": 14.5,
				"lateral_max": 19.0,
				"cluster_chance": 0.08,
				"cluster_min": 1,
				"cluster_max": 1,
				"emission_boost": 0.50,
				"weight_warmup": 0.16,
				"weight_mid": 0.20,
				"weight_late": 0.18,
			}
		return {
			"height_min": 2.6,
			"height_max": 4.6,
			"lateral_min": 12.0,
			"lateral_max": 18.5,
			"cluster_chance": 0.18,
			"cluster_min": 1,
			"cluster_max": 2,
			"emission_boost": 0.7,
			"weight_warmup": 0.14,
			"weight_mid": 0.32,
			"weight_late": 0.28,
		}
	if "deadzone_billboard" in lower or "死域广告牌" in lower:
		return {
			"height_min": 3.2,
			"height_max": 5.6,
			"lateral_min": 13.5,
			"lateral_max": 19.0,
			"cluster_chance": 0.08,
			"cluster_min": 1,
			"cluster_max": 1,
			"emission_boost": 0.62,
			"weight_warmup": 0.12,
			"weight_mid": 0.14,
			"weight_late": 0.12,
		}
	if "spark_ring" in lower or "星火环" in lower:
		return {
			"height_min": 2.4,
			"height_max": 4.8,
			"lateral_min": 11.5,
			"lateral_max": 17.5,
			"cluster_chance": 0.12,
			"cluster_min": 1,
			"cluster_max": 2,
			"emission_boost": 0.78,
			"weight_warmup": 0.14,
			"weight_mid": 0.16,
			"weight_late": 0.14,
		}
	return {
		"height_min": 2.0,
		"height_max": 3.2,
		"lateral_min": MIDGROUND_LATERAL_MIN,
		"lateral_max": MIDGROUND_LATERAL_MAX,
		"cluster_chance": 0.25,
		"cluster_min": 1,
		"cluster_max": 2,
		"emission_boost": 1.0,
		"weight_warmup": 0.33,
		"weight_mid": 0.33,
		"weight_late": 0.33,
	}

func _should_skip_distant_at(distance: float) -> bool:
	if not _y_fork_region_at(distance).is_empty():
		return true
	if _is_in_fork_main_gap(distance):
		return true
	for gap in _main_block_road_gaps():
		if distance >= gap.x - 6.0 and distance <= gap.y + 6.0:
			return true
	for zone in _side_runway_zones():
		var pit: Vector2 = _side_runway_pit_range(zone)
		if distance >= pit.x - 8.0 and distance <= pit.y + 8.0:
			return true
	return false

func _should_skip_midground_at(distance: float) -> bool:
	if distance < START_PAD_LENGTH + 4.0:
		return true
	if _is_gate_location():
		# 分叉段改把近/中景推到岔路外侧，不再整段不刷
		if not _y_fork_region_at(distance).is_empty():
			return true
		for gap in _main_block_road_gaps():
			if typeof(gap) == TYPE_VECTOR2 and distance >= gap.x - 6.0 and distance <= gap.y + 6.0:
				return true
		for zone in _side_runway_zones():
			var wall_start := float(zone.get("start", 0.0))
			var entry_window := float(zone.get("entry_window", 10.0))
			if distance >= wall_start - entry_window and distance <= wall_start + entry_window:
				return true
			var pit: Vector2 = _side_runway_pit_range(zone)
			if distance >= pit.x - 8.0 and distance <= pit.y + 8.0:
				return true
		var gate_finish := _finish_line_distance if _finish_line_distance > 0.0 else maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)
		if distance >= gate_finish - 95.0:
			return true
		return false
	if _should_skip_distant_at(distance):
		return true
	if _is_in_fork_main_gap(distance):
		return true
	for zone in _side_runway_zones():
		var start := float(zone.get("start", 0.0))
		var entry_window := float(zone.get("entry_window", 10.0))
		if distance >= start - entry_window and distance <= start + entry_window:
			return true
	# 终点紫光幕附近清空中景，避免和据点抢戏
	var finish_d := _finish_line_distance if _finish_line_distance > 0.0 else maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)
	if distance >= finish_d - 95.0:
		return true
	return false

func _spawn_midground_prop(
	distance: float,
	lateral: float,
	asset_path: String,
	target_height: float,
	rng: RandomNumberGenerator,
	emission_boost: float = 1.0,
	near_runway: bool = false
) -> bool:
	var scene := _load_runner_scene(asset_path, false)
	if scene == null:
		push_warning("Midground GLB missing: %s" % asset_path)
		return false
	var root := Node3D.new()
	root.name = "MidProp_%d" % _side_dressing_root.get_child_count()
	_side_dressing_root.add_child(root)
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	root.position = placed["pos"]
	var path_yaw := float(placed["yaw"])
	var is_neon := _is_midground_neon_sign(asset_path)
	var channel := (
		_is_reservoir_location()
		and _is_channel_midground_prop(asset_path)
		and not _is_midground_meteorite(asset_path)
		and _reservoir_mode_arches_side(_reservoir_side_mode_at(distance), lateral)
	)
	var on_left := lateral < 0.0
	if is_neon and on_left:
		target_height *= 0.68
	var model_yaw := rng.randf_range(-18.0, 18.0)
	if is_neon:
		# 左侧广告牌绕 Y 转 180°，与右侧成对称、箭头仍朝向跑道
		root.rotation.y = path_yaw + PI if on_left else path_yaw
		root.rotation.y += rng.randf_range(-0.08, 0.08)
		model_yaw = rng.randf_range(-4.0, 4.0)
	else:
		root.rotation.y = path_yaw if channel else path_yaw + rng.randf_range(-0.42, 0.42)
	root.set_meta("path_distance", distance)
	var preferred_fp := clampf(target_height * 1.15, 1.8, 4.2)
	if is_neon:
		preferred_fp = clampf(target_height * 1.05, 1.8, 3.6)
	if _is_gate_location() and near_runway:
		preferred_fp = clampf(target_height * 1.85, 3.2, 7.4)
	var footprint := -1.0 if channel else _midground_safe_footprint(lateral, preferred_fp)
	if _is_gate_location() and near_runway:
		footprint = _gate_near_safe_footprint(lateral, preferred_fp)
	var model := _add_scaled_model_visual(
		root,
		scene,
		"MidPropModel",
		target_height,
		model_yaw,
		Vector3.ZERO,
		footprint,
		MIDGROUND_SCALE_CAP,
		channel
	)
	if channel:
		if model:
			_squash_midground_footprint_keep_height(model, 4.6)
		_resit_midground_on_ground(root)
		_apply_reservoir_channel_lean(root, lateral, rng, asset_path)
		_resit_midground_on_ground(root, 1.05)
		_push_midground_base_off_runway(root, distance, lateral)
		_resit_midground_on_ground(root, 1.05)
	elif not _is_wide_midground_prop(asset_path):
		_enforce_midground_min_size(model, target_height)
		_clamp_midground_footprint(model, footprint)
	elif _is_gate_location():
		_clamp_midground_footprint(model, footprint if footprint > 0.0 else 8.0)
	_preserve_midground_materials(root)
	if _is_midground_meteorite(asset_path):
		_apply_midground_meteorite_variant(root, _pick_meteorite_palette(rng, distance, lateral))
	elif _is_reservoir_location() and _is_reservoir_crystal_prop(asset_path):
		_apply_reservoir_crystal_look(root, rng, distance, lateral)
	elif _is_relay_mission():
		var depth_tier := 2 if _is_wide_midground_prop(asset_path) else 1
		_apply_relay_nightscape_look(root, depth_tier)
	if _is_gate_location():
		_keep_dressing_prop_clear_runway(root, distance, lateral, near_runway)
	_disable_mesh_shadows(root)
	return true

func _apply_midground_meteorite_variant(root: Node3D, palette: Dictionary) -> void:
	if palette.is_empty():
		return
	var albedo_tint: Color = palette.get("albedo", Color(0.72, 0.56, 0.40))
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_i in mesh_instance.mesh.get_surface_count():
			var mat := mesh_instance.get_surface_override_material(surface_i)
			if mat == null:
				mat = mesh_instance.mesh.surface_get_material(surface_i)
			if mat is StandardMaterial3D:
				var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
				dup.albedo_color = albedo_tint
				dup.metallic = 0.0
				dup.roughness = 0.90
				dup.clearcoat_enabled = false
				dup.rim_enabled = false
				dup.emission_enabled = false
				dup.emission_energy_multiplier = 0.0
				dup.emission_texture = null
				dup.roughness_texture = null
				dup.metallic_texture = null
				dup.orm_texture = null
				dup.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
				mesh_instance.set_surface_override_material(surface_i, dup)
			elif mesh_instance.material_override is StandardMaterial3D:
				var ov := (mesh_instance.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
				ov.albedo_color = albedo_tint
				ov.metallic = 0.0
				ov.roughness = 0.90
				ov.clearcoat_enabled = false
				ov.emission_enabled = false
				ov.emission_energy_multiplier = 0.0
				ov.emission_texture = null
				ov.roughness_texture = null
				ov.metallic_texture = null
				ov.orm_texture = null
				mesh_instance.material_override = ov

func _preserve_midground_materials(root: Node3D) -> void:
	# 只清掉覆盖材质，保留 GLB 自带贴图/颜色
	for node in root.find_children("*", "MeshInstance3D", true, false):
		(node as MeshInstance3D).material_override = null


func _apply_distant_amber_haze_look(root: Node3D) -> void:
	# 远景：保留琥珀晶体本色，去掉油腻高光，略降饱和好融进大气
	if root == null:
		return
	if _is_relay_mission():
		return
	# 第三/四关：保留贴图，只压自发光，避免远景变成黄色色块
	if _mission_id_str() in ["mission_reservoir_03", "mission_reservoir_04"]:
		_tame_distant_crystal_emission(root)
		return
	var haze := Color(0.62, 0.58, 0.66)
	if _mission_id_str() == "mission_reservoir_03":
		haze = Color(0.70, 0.58, 0.50)
	elif _mission_id_str() == "mission_reservoir_04":
		haze = Color(0.42, 0.28, 0.38)
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_i in mesh_instance.mesh.get_surface_count():
			var mat := mesh_instance.get_surface_override_material(surface_i)
			if mat == null:
				mat = mesh_instance.mesh.surface_get_material(surface_i)
			if not mat is StandardMaterial3D:
				continue
			var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
			var base := dup.albedo_color
			var faded := Color(
				lerpf(base.r, haze.r, 0.28),
				lerpf(base.g, haze.g, 0.28),
				lerpf(base.b, haze.b, 0.28),
				base.a
			)
			var grey := (faded.r + faded.g + faded.b) / 3.0
			dup.albedo_color = Color(
				lerpf(faded.r, grey, 0.18),
				lerpf(faded.g, grey, 0.18),
				lerpf(faded.b, grey, 0.18),
				base.a
			)
			dup.metallic_texture = null
			dup.metallic = minf(dup.metallic, 0.04)
			dup.roughness = clampf(dup.roughness, 0.28, 0.62)
			dup.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
			if dup.emission_enabled:
				dup.emission_energy_multiplier = clampf(dup.emission_energy_multiplier * 0.55, 0.18, 1.4)
			mesh_instance.set_surface_override_material(surface_i, dup)


func _tame_distant_crystal_emission(root: Node3D) -> void:
	if root == null:
		return
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_i in mesh_instance.mesh.get_surface_count():
			var mat := mesh_instance.get_surface_override_material(surface_i)
			if mat == null:
				mat = mesh_instance.mesh.surface_get_material(surface_i)
			if not mat is StandardMaterial3D:
				continue
			var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
			dup.metallic = minf(dup.metallic, 0.06)
			dup.roughness = clampf(dup.roughness, 0.16, 0.38)
			dup.rim_enabled = true
			dup.rim = 0.46
			dup.rim_tint = 0.35
			if dup.emission_enabled:
				dup.emission_energy_multiplier = minf(dup.emission_energy_multiplier, 0.55)
			mesh_instance.set_surface_override_material(surface_i, dup)


func _apply_clear_amber_crystal_look(root: Node3D) -> void:
	if root == null:
		return
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for surface_i in mesh_instance.mesh.get_surface_count():
			var mat := mesh_instance.get_surface_override_material(surface_i)
			if mat == null:
				mat = mesh_instance.mesh.surface_get_material(surface_i)
			if not mat is StandardMaterial3D:
				continue
			var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
			var amber := Color(1.0, 0.62, 0.22)
			dup.albedo_color = dup.albedo_color.lerp(amber, 0.55)
			dup.metallic_texture = null
			dup.metallic = 0.02
			dup.roughness = 0.14
			dup.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
			dup.emission_enabled = true
			dup.emission = Color(1.0, 0.52, 0.14)
			dup.emission_energy_multiplier = 2.35
			dup.rim_enabled = true
			dup.rim = 0.72
			dup.rim_tint = 0.45
			mesh_instance.set_surface_override_material(surface_i, dup)


func _ensure_reservoir_sky_dome() -> void:
	if not _uses_reservoir_sky_dome() or camera == null:
		return
	if _reservoir_sky_dome != null and is_instance_valid(_reservoir_sky_dome):
		return
	var plate := MeshInstance3D.new()
	plate.name = "ReservoirSkyPlate"
	plate.mesh = QuadMesh.new()
	plate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	plate.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	plate.extra_cull_margin = 1200.0
	plate.custom_aabb = AABB(Vector3(-4000.0, -4000.0, -4000.0), Vector3(8000.0, 8000.0, 8000.0))
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_fog = true
	mat.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	if _mission_id_str() == "mission_reservoir_04":
		mat.albedo_texture = RESERVOIR_W4_SKY_PLATE
	else:
		mat.albedo_texture = RESERVOIR_W3_SKY_PLATE
	plate.material_override = mat
	camera.add_child(plate)
	_reservoir_sky_dome = plate
	_fit_reservoir_sky_plate()


func _fit_reservoir_sky_plate() -> void:
	if _reservoir_sky_dome == null or camera == null:
		return
	var dist := 620.0
	var half_h := dist * tan(deg_to_rad(camera.fov * 0.5)) * 1.35
	var vp := get_viewport()
	var aspect := 9.0 / 16.0
	if vp != null:
		var r := vp.get_visible_rect().size
		if r.y > 0.5:
			aspect = r.x / r.y
	var mesh := _reservoir_sky_dome.mesh as QuadMesh
	if mesh == null:
		mesh = QuadMesh.new()
		_reservoir_sky_dome.mesh = mesh
	mesh.size = Vector2(half_h * 2.0 * aspect * 1.35, half_h * 2.0)
	_reservoir_sky_dome.position = Vector3(0.0, 0.0, -dist)


func _update_reservoir_sky_dome() -> void:
	if not _uses_reservoir_sky_dome():
		return
	_ensure_reservoir_sky_dome()
	if _reservoir_sky_dome == null or camera == null:
		return
	if _reservoir_sky_dome.get_parent() != camera:
		if _reservoir_sky_dome.get_parent() != null:
			_reservoir_sky_dome.get_parent().remove_child(_reservoir_sky_dome)
		camera.add_child(_reservoir_sky_dome)
	_fit_reservoir_sky_plate()
	_reservoir_sky_dome.visible = true


func _enforce_midground_min_size(model: Node3D, target_height: float) -> void:
	if model == null:
		return
	var bounds := _compute_node_aabb(model)
	var current_h := maxf(bounds.size.y, 0.001)
	var min_h := maxf(MIDGROUND_MIN_VISIBLE_HEIGHT, target_height * 0.72)
	if current_h < min_h:
		model.scale *= min_h / current_h
		bounds = _compute_node_aabb(model)
		model.position.y += -bounds.position.y


func _is_wide_midground_prop(path: String) -> bool:
	var lower := String(path).to_lower()
	return (
		"coral" in lower
		or "purifier" in lower
		or "crystal" in lower
		or "meteorite" in lower
	)


func _is_runway_wrapping_prop(path: String) -> bool:
	var lower := String(path).to_lower()
	return "spark_ring" in lower or "星火环" in lower


func _is_bulky_near_runway_prop(path: String) -> bool:
	var lower := String(path).to_lower()
	return (
		_is_runway_wrapping_prop(path)
		or _is_midground_robot(path)
		or _is_wide_midground_prop(path)
		or "neon_sign" in lower
		or "purifier" in lower
		or "medical_pod" in lower
	)


func _is_in_junction_dressing_span(distance: float, pad: float = 10.0) -> bool:
	return not _fork_zone_covering(distance, pad).is_empty()


func _fork_zone_covering(distance: float, pad: float = 16.0) -> Dictionary:
	for zone in _junction_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var start := float(zone.get("distance", 0.0))
		var length := float(zone.get("length", 70.0))
		if distance >= start - pad and distance <= start + length + pad:
			return zone
	return {}


func _fork_envelope_at_distance(distance: float, zone: Dictionary) -> float:
	var start := float(zone.get("distance", 0.0))
	var length := float(zone.get("length", 70.0))
	var t := clampf((distance - start) / maxf(length, 0.001), 0.0, 1.0)
	return _fork_envelope(t)


func _gate_runway_lateral_bands(distance: float) -> Array:
	var bands: Array = []
	var road_half := _holographic_road_half() if _road_style_id == "holographic" else 6.3
	var zone := _fork_zone_covering(distance, 16.0)
	if zone.is_empty():
		bands.append(Vector2(-road_half, road_half))
		return bands
	var envelope := _fork_envelope_at_distance(distance, zone)
	var spread := float(zone.get("spread", 17.0))
	var branch_half := _fork_branch_half_width()
	var center_abs := spread * envelope
	if center_abs < 1.2:
		bands.append(Vector2(-road_half, road_half))
		return bands
	bands.append(Vector2(-center_abs - branch_half, -center_abs + branch_half))
	bands.append(Vector2(center_abs - branch_half, center_abs + branch_half))
	if envelope < 0.28:
		bands.append(Vector2(-road_half, road_half))
	return bands


func _gate_dressing_lateral_outside_runway(
	distance: float,
	side: float,
	preferred_abs: float,
	rng: RandomNumberGenerator
) -> float:
	var sign_v := 1.0 if side >= 0.0 else -1.0
	var zone := _fork_zone_covering(distance, 16.0)
	if zone.is_empty():
		return sign_v * preferred_abs
	var envelope := _fork_envelope_at_distance(distance, zone)
	var spread := float(zone.get("spread", 17.0))
	var branch_half := _fork_branch_half_width()
	var outer := spread * envelope + branch_half
	if outer < 7.2:
		return sign_v * maxf(preferred_abs, 9.2)
	var abs_lat := rng.randf_range(outer + 1.6, outer + 4.6)
	return sign_v * abs_lat


func _is_channel_midground_prop(path: String) -> bool:
	return _is_wide_midground_prop(path)


func _apply_reservoir_channel_lean(root: Node3D, lateral: float, rng: RandomNumberGenerator, asset_path: String = "") -> void:
	if root == null:
		return
	var lean := deg_to_rad(rng.randf_range(6.0, 14.0))
	if _is_midground_meteorite(asset_path):
		lean = deg_to_rad(rng.randf_range(3.0, 9.0))
	var yaw := root.rotation.y
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	root.rotate(forward, lean * (-1.0 if lateral > 0.0 else 1.0))


func _resit_midground_on_ground(root: Node3D, base_radius: float = -1.0) -> void:
	if root == null:
		return
	root.force_update_transform()
	var sit_y := GROUND_Y - 0.12
	var min_y := 1.0e9
	var origin := root.global_position
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		mesh_instance.force_update_transform()
		var aabb := mesh_instance.mesh.get_aabb()
		var samples: Array[Vector3] = [
			Vector3(aabb.position.x + aabb.size.x * 0.5, aabb.position.y, aabb.position.z + aabb.size.z * 0.5),
		]
		for corner in _aabb_corners(aabb):
			samples.append(corner)
		for local_pt in samples:
			var world_point: Vector3 = mesh_instance.global_transform * local_pt
			if base_radius > 0.0:
				var dx := world_point.x - origin.x
				var dz := world_point.z - origin.z
				if dx * dx + dz * dz > base_radius * base_radius:
					continue
			min_y = minf(min_y, world_point.y)
	if min_y < 1.0e8:
		root.global_position.y += sit_y - min_y


func _squash_midground_footprint_keep_height(model: Node3D, max_footprint: float) -> void:
	if model == null or max_footprint <= 0.001:
		return
	var bounds := _compute_node_aabb(model)
	var footprint := maxf(bounds.size.x, bounds.size.z)
	if footprint <= max_footprint or footprint <= 0.001:
		return
	var keep_y := model.scale.y
	model.scale.x *= max_footprint / footprint
	model.scale.z *= max_footprint / footprint
	model.scale.y = keep_y
	bounds = _compute_node_aabb(model)
	model.position.y = -bounds.position.y
	model.position.x = -(bounds.position.x + bounds.size.x * 0.5)
	model.position.z = -(bounds.position.z + bounds.size.z * 0.5)


func _push_midground_base_off_runway(root: Node3D, distance: float, lateral: float) -> void:
	if root == null:
		return
	var sample := _sample_path(distance)
	var right: Vector3 = sample["right"]
	var origin: Vector3 = sample["pos"]
	var keep := _holographic_road_half() + CHANNEL_BASE_CLEARANCE
	var base_top := GROUND_Y + CHANNEL_BASE_HEIGHT
	var extra := 0.0
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for corner in _aabb_corners(mesh_instance.mesh.get_aabb()):
			var world_point: Vector3 = mesh_instance.global_transform * corner
			if world_point.y > base_top:
				continue
			var lat := (world_point - origin).dot(right)
			if absf(lat) < keep:
				extra = maxf(extra, keep - absf(lat))
	if extra > 0.04:
		root.global_position += right * signf(lateral) * extra


func _midground_safe_footprint(lateral: float, preferred: float) -> float:
	var road_half := 6.2
	if has_method("_holographic_road_half") and _road_style_id == "holographic":
		road_half = _holographic_road_half()
	var edge_room := absf(lateral) - (road_half + MIDGROUND_RUNWAY_CLEARANCE)
	var max_fp := maxf(edge_room * 1.55, 1.4)
	return clampf(minf(preferred, max_fp), 1.4, 4.4)


func _gate_near_safe_footprint(lateral: float, preferred: float) -> float:
	# 外道可被挡住形成通道，中道 |lat|<2.45 必须留空
	var keep := 2.45
	var edge_room := maxf(absf(lateral) - keep, 2.2)
	return clampf(minf(preferred, edge_room * 1.12), 2.6, 8.0)


func _dressing_lateral_extents(root: Node3D, origin: Vector3, right: Vector3) -> Vector2:
	var min_lat := 1.0e9
	var max_lat := -1.0e9
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		mesh_instance.force_update_transform()
		for corner in _aabb_corners(mesh_instance.mesh.get_aabb()):
			var world_point: Vector3 = mesh_instance.global_transform * (corner as Vector3)
			var lat: float = (world_point - origin).dot(right)
			min_lat = minf(min_lat, lat)
			max_lat = maxf(max_lat, lat)
	if min_lat > 1.0e8:
		return Vector2.ZERO
	return Vector2(min_lat, max_lat)


func _keep_dressing_prop_clear_runway(
	root: Node3D,
	distance: float,
	lateral: float,
	near_runway: bool = false
) -> void:
	if root == null:
		return
	root.force_update_transform()
	var sample := _sample_path(distance)
	var right: Vector3 = sample["right"]
	var origin: Vector3 = sample["pos"]
	var keep := 2.45
	var max_span := 8.6 if near_runway else 12.0
	var extents := _dressing_lateral_extents(root, origin, right)
	if extents == Vector2.ZERO:
		return
	var span := extents.y - extents.x
	if span > max_span:
		var model := root.get_node_or_null("MidPropModel") as Node3D
		if model == null:
			model = root
		_squash_midground_footprint_keep_height(model, max_span)
		root.force_update_transform()
		extents = _dressing_lateral_extents(root, origin, right)
		if extents == Vector2.ZERO:
			return
	var side := 1.0 if lateral >= 0.0 else -1.0
	var extra := 0.0
	var bands: Array = _gate_runway_lateral_bands(distance)
	if bands.is_empty():
		if side > 0.0:
			extra = maxf(0.0, keep - extents.x)
		else:
			extra = maxf(0.0, extents.y + keep)
	else:
		for raw in bands:
			var band: Vector2 = raw
			var center := (band.x + band.y) * 0.5
			if extents.x >= center + keep or extents.y <= center - keep:
				continue
			if side > 0.0:
				extra = maxf(extra, (center + keep) - extents.x)
			else:
				extra = maxf(extra, extents.y - (center - keep))
	if extra > 0.04:
		root.global_position += right * side * extra
		root.force_update_transform()
	_resit_midground_on_ground(root, 1.2)


func _clamp_edge_filler_off_runway(inst: Node3D, distance: float, side_sign: float, road_half: float) -> void:
	if inst == null:
		return
	inst.force_update_transform()
	var bounds := _compute_node_aabb(inst)
	var footprint := maxf(bounds.size.x, bounds.size.z)
	if footprint > 1.8 and footprint > 0.001:
		inst.scale *= 1.8 / footprint
		inst.force_update_transform()
	var sample := _sample_path(distance)
	var right: Vector3 = sample["right"]
	var origin: Vector3 = sample["pos"]
	var extents := _dressing_lateral_extents(inst, origin, right)
	if extents == Vector2.ZERO:
		return
	var keep := road_half - 0.35
	var extra := 0.0
	if side_sign > 0.0:
		extra = maxf(0.0, keep - extents.x)
	else:
		extra = maxf(0.0, extents.y + keep)
	if extra > 0.03:
		inst.global_position += right * side_sign * extra


func _clamp_midground_footprint(model: Node3D, max_footprint: float) -> void:
	if model == null or max_footprint <= 0.001:
		return
	var bounds := _compute_node_aabb(model)
	var footprint := maxf(bounds.size.x, bounds.size.z)
	if footprint > max_footprint and footprint > 0.001:
		model.scale *= max_footprint / footprint
		bounds = _compute_node_aabb(model)
		model.position.y += -bounds.position.y


func _distant_safe_footprint(lateral: float, preferred: float) -> float:
	var edge_room := absf(lateral) - DISTANT_RUNWAY_CLEARANCE
	return clampf(minf(preferred, edge_room * 2.0), 4.0, 12.0)


func _build_near_sky_layers() -> void:
	# 中继站用全景天空；近空板会像贴在远处的物体，上一版已禁用
	if _is_relay_mission():
		return
	var layers: Array = mission.get("near_sky_textures", [])
	if layers.is_empty():
		return
	var root := Node3D.new()
	root.name = "NearSkyLayers"
	track_root.add_child(root)
	var track_end := maxf(_path_length, _track_length) + 40.0
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(String(Global.runner_mission_id) + "_near_sky")
	var slot := 0
	var d := 36.0
	while d < track_end:
		var tex_path := String(layers[slot % layers.size()])
		slot += 1
		if tex_path.strip_edges() == "" or not ResourceLoader.exists(tex_path):
			d += rng.randf_range(48.0, 72.0)
			continue
		var tex := load(tex_path) as Texture2D
		if tex == null:
			d += rng.randf_range(48.0, 72.0)
			continue
		for side_sign: float in [-1.0, 1.0]:
			var lateral := side_sign * rng.randf_range(42.0, 68.0)
			var placed := _world_on_path(d, lateral, GROUND_Y)
			var layer := MeshInstance3D.new()
			var mesh := QuadMesh.new()
			var aspect := maxf(float(tex.get_width()), 1.0) / maxf(float(tex.get_height()), 1.0)
			mesh.size = Vector2(72.0 * aspect, 72.0)
			layer.mesh = mesh
			var mat := StandardMaterial3D.new()
			mat.albedo_texture = tex
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			mat.alpha_scissor_threshold = 0.08
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
			layer.material_override = mat
			var pos: Vector3 = placed["pos"]
			pos.y += rng.randf_range(18.0, 28.0)
			layer.position = pos
			layer.rotation.y = float(placed["yaw"]) + side_sign * rng.randf_range(-0.12, 0.12)
			root.add_child(layer)
		d += rng.randf_range(52.0, 78.0)


func _build_distant_background(_theme: Dictionary) -> void:
	# 远景锚点：固定在世界坐标，高横向偏移不占用跑道；能量柱稍密，其间错落飞船/穹顶。
	_distant_background_root = Node3D.new()
	_distant_background_root.name = "DistantBackground"
	track_root.add_child(_distant_background_root)

	var rng := RandomNumberGenerator.new()
	var planet_key := "runner"
	if LevelConfig.has_method("get_planet_id"):
		planet_key = String(LevelConfig.get_planet_id())
	rng.seed = hash(planet_key + "_distant_v3_" + String(Global.runner_location_id) + "_" + String(Global.runner_mission_id))

	var track_end := maxf(_path_length, _track_length) + 48.0
	var d := 48.0
	var slot_i := 0
	var crisis_batch := _runner_visual_batch() == "crisis"
	var reservoir_batch := _is_reservoir_location()
	var density_scale := clampf(_mission_sky_distant_density(), 0.85, 2.2)
	var stride_mul := 1.0 / density_scale
	if reservoir_batch:
		_build_reservoir_distant_colonies(rng, track_end)
		var ship_d := 96.0
		while ship_d < track_end + 40.0:
			if not _distant_spaceship_paths.is_empty() and not _should_skip_distant_at(ship_d):
				var ship_side := 1.0 if rng.randf() > 0.5 else -1.0
				_spawn_distant_prop(
					ship_d,
					ship_side * rng.randf_range(70.0, 94.0),
					_distant_spaceship_paths,
					rng.randf_range(12.0, 18.0),
					rng,
					"DistantShip"
				)
			ship_d += rng.randf_range(108.0, 148.0)
		return
	var tower_stride := 4 if crisis_batch else 3
	while d < track_end:
		if _should_skip_distant_at(d):
			d += rng.randf_range(18.0, 28.0) * stride_mul
			slot_i += 1
			continue
		var fork_push := 8.0 if _is_in_fork_main_gap(d) else 0.0
		# 能量柱：危机批次降低密度，避免远景千篇一律
		if not _distant_tower_paths.is_empty() and slot_i % tower_stride != 2:
			var tower_sides: Array = [-1.0, 1.0] if slot_i % 3 != 2 else [1.0 if slot_i % 2 == 0 else -1.0]
			for side in tower_sides:
				var lateral := float(side) * (rng.randf_range(DISTANT_TOWER_LATERAL_MIN, DISTANT_TOWER_LATERAL_MAX) + fork_push)
				_spawn_distant_tower_cluster(
					d + rng.randf_range(-3.0, 3.0),
					lateral,
					rng,
					rng.randf_range(18.0, 30.0) if reservoir_batch else rng.randf_range(28.0, 46.0)
				)
		# 柱间错落：水源据点优先能量山/水晶树/挖掘机；危机批次医疗箱/水晶树；其它飞船/据点
		if slot_i % 2 == 1 or (crisis_batch and slot_i % 3 == 0) or (reservoir_batch and slot_i % 3 == 0):
			var accent_d := d + rng.randf_range(12.0, 24.0)
			var accent_side := 1.0 if rng.randf() > 0.5 else -1.0
			var accent_lateral := accent_side * (rng.randf_range(DISTANT_ACCENT_LATERAL_MIN, DISTANT_ACCENT_LATERAL_MAX) + fork_push)
			var accent_roll := rng.randf()
			if reservoir_batch and not _distant_accent_prop_paths.is_empty() and accent_roll < 0.55:
				_spawn_distant_prop(
					accent_d,
					accent_lateral,
					_distant_accent_prop_paths,
					rng.randf_range(7.0, 12.0),
					rng,
					"DistantAccent"
				)
			elif reservoir_batch and not _distant_spaceship_paths.is_empty() and accent_roll < 0.88:
				_spawn_distant_prop(
					accent_d,
					accent_lateral,
					_distant_spaceship_paths,
					rng.randf_range(16.0, 24.0),
					rng,
					"DistantShip"
				)
			elif crisis_batch and not _distant_accent_prop_paths.is_empty() and accent_roll < 0.72:
				_spawn_distant_prop(
					accent_d,
					accent_lateral * 0.82,
					_distant_accent_prop_paths,
					rng.randf_range(10.0, 18.0),
					rng,
					"DistantAccent"
				)
			elif accent_roll < 0.52 and not _distant_spaceship_paths.is_empty():
				_spawn_distant_prop(
					accent_d,
					accent_lateral,
					_distant_spaceship_paths,
					rng.randf_range(20.0, 32.0),
					rng,
					"DistantShip"
				)
			elif not _distant_hearth_paths.is_empty() and not crisis_batch:
				_spawn_distant_prop(
					accent_d,
					accent_lateral,
					_distant_hearth_paths,
					rng.randf_range(14.0, 22.0),
					rng,
					"DistantHearth"
				)
			elif not _distant_accent_prop_paths.is_empty():
				_spawn_distant_prop(
					accent_d,
					accent_lateral * 0.85,
					_distant_accent_prop_paths,
					rng.randf_range(10.0, 17.0),
					rng,
					"DistantAccent"
				)
			elif not _distant_spaceship_paths.is_empty():
				_spawn_distant_prop(
					accent_d,
					accent_lateral,
					_distant_spaceship_paths,
					rng.randf_range(20.0, 32.0),
					rng,
					"DistantShip"
				)
		d += rng.randf_range(26.0 if crisis_batch else 30.0, 42.0 if crisis_batch else 46.0) * stride_mul
		slot_i += 1


func _build_reservoir_distant_colonies(rng: RandomNumberGenerator, track_end: float) -> void:
	var d := 118.0
	var slot := 0
	while d < track_end + 90.0:
		var side := -1.0 if slot % 2 == 0 else 1.0
		_spawn_reservoir_energy_colony(d + rng.randf_range(-8.0, 8.0), side, rng)
		d += rng.randf_range(78.0, 104.0)
		slot += 1


func _spawn_reservoir_energy_colony(distance: float, side: float, rng: RandomNumberGenerator) -> void:
	var center_lat := side * rng.randf_range(86.0, 118.0)
	var placed := _world_on_path(distance, center_lat, GROUND_Y)
	var cluster := Node3D.new()
	cluster.name = "EnergyColony_%d" % _distant_background_root.get_child_count()
	cluster.position = placed["pos"]
	cluster.rotation.y = float(placed["yaw"]) + rng.randf_range(-0.18, 0.18)
	cluster.set_meta("path_distance", distance)
	cluster.set_meta("distant_layer", 1)
	_distant_background_root.add_child(cluster)
	var pillar_n := rng.randi_range(2, 3)
	var heights: Array[float] = [58.0, 76.0, 48.0, 92.0, 64.0]
	for j in pillar_n:
		var pillar_path := RESERVOIR_CRYSTAL_PILLARS[rng.randi() % RESERVOIR_CRYSTAL_PILLARS.size()]
		var scene := _load_runner_scene(pillar_path, false)
		if scene == null:
			continue
		var tower := Node3D.new()
		tower.name = "EnergyTower_%d" % j
		cluster.add_child(tower)
		tower.position = Vector3(
			rng.randf_range(-4.5, 4.5) + float(j) * rng.randf_range(5.5, 8.0),
			0.0,
			rng.randf_range(-6.0, 6.0) + float(j) * rng.randf_range(3.2, 5.4)
		)
		var target_h := heights[j % heights.size()] * rng.randf_range(0.94, 1.16)
		if j == 0:
			target_h = rng.randf_range(78.0, 108.0)
		_add_scaled_model_visual(
			tower,
			scene,
			"CrystalTower",
			target_h,
			rng.randf_range(-12.0, 12.0),
			Vector3.ZERO,
			rng.randf_range(6.0, 9.2),
			120.0,
			true
		)
	_resit_midground_on_ground(cluster)
	_preserve_midground_materials(cluster)
	_apply_distant_amber_haze_look(cluster)
	_disable_mesh_shadows(cluster)


func _spawn_distant_tower_cluster(
	distance: float,
	lateral: float,
	rng: RandomNumberGenerator,
	cluster_height: float
) -> void:
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	var cluster := Node3D.new()
	cluster.name = "DistantTowerCluster_%d" % _distant_background_root.get_child_count()
	cluster.position = placed["pos"]
	cluster.rotation.y = float(placed["yaw"]) + rng.randf_range(-0.22, 0.22)
	cluster.set_meta("path_distance", distance)
	cluster.set_meta("distant_layer", 1)
	_distant_background_root.add_child(cluster)

	var tower_count := rng.randi_range(1, 2)
	var safe_fp := _distant_safe_footprint(lateral, cluster_height * 0.28)
	for i in tower_count:
		var asset_path := ""
		if _should_pick_environment_pack_v2(rng, 0.5):
			asset_path = _pick_environment_pack_v2_path(rng)
		elif not _distant_tower_paths.is_empty():
			asset_path = _distant_tower_paths[rng.randi() % _distant_tower_paths.size()]
		if asset_path == "":
			continue
		var scene := _load_runner_scene(asset_path, false)
		if scene == null:
			continue
		var tower_root := Node3D.new()
		tower_root.name = "Tower_%d" % i
		cluster.add_child(tower_root)
		var spread_x := rng.randf_range(-2.8, 2.8)
		var spread_z := rng.randf_range(-4.5, 4.5) + float(i - tower_count * 0.5) * 1.8
		tower_root.position = Vector3(spread_x, 0.0, spread_z)
		var target_h := cluster_height * rng.randf_range(0.72, 1.12)
		_add_scaled_model_visual(
			tower_root,
			scene,
			"CrystalTower",
			target_h,
			rng.randf_range(-10.0, 10.0),
			Vector3.ZERO,
			safe_fp,
			DISTANT_SCALE_CAP
		)
		_apply_distant_atmosphere_material(tower_root)

func _spawn_distant_prop(
	distance: float,
	lateral: float,
	paths: Array[String],
	target_height: float,
	rng: RandomNumberGenerator,
	model_name: String
) -> void:
	if paths.is_empty() and _environment_pack_v2_paths.is_empty():
		return
	var asset_path := ""
	if _should_pick_environment_pack_v2(rng, 0.65):
		asset_path = _pick_environment_pack_v2_path(rng)
	elif not paths.is_empty():
		asset_path = paths[rng.randi() % paths.size()]
	if asset_path == "":
		return
	var scene := _load_runner_scene(asset_path, false)
	if scene == null:
		return
	var root := Node3D.new()
	root.name = "%s_%d" % [model_name, _distant_background_root.get_child_count()]
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	root.position = placed["pos"]
	root.rotation.y = float(placed["yaw"]) + rng.randf_range(-0.28, 0.28)
	root.set_meta("path_distance", distance)
	root.set_meta("distant_layer", 2 if model_name == "DistantShip" else 1)
	_distant_background_root.add_child(root)
	var safe_fp := _distant_safe_footprint(lateral, target_height * (0.42 if model_name == "DistantHearth" else 0.5))
	_add_scaled_model_visual(
		root,
		scene,
		model_name,
		target_height,
		rng.randf_range(-12.0, 12.0),
		Vector3.ZERO,
		safe_fp,
		DISTANT_SCALE_CAP
	)
	_resit_midground_on_ground(root)
	if _is_channel_midground_prop(asset_path):
		_preserve_midground_materials(root)
		_disable_mesh_shadows(root)
	else:
		_apply_distant_atmosphere_material(root)

func _update_distant_depth_cues() -> void:
	# 远景明暗每 3 帧更新一次，减轻 CPU
	if Engine.get_process_frames() % 3 != 0:
		return
	# 只调轻微明暗，不移动坐标、不用半透明：保留模型原色与贴图。
	if _distant_background_root == null or player == null:
		return
	for child in _distant_background_root.get_children():
		if not child is Node3D:
			continue
		var node := child as Node3D
		var anchor_d := float(node.get_meta("path_distance", -1.0))
		if anchor_d < 0.0:
			continue
		var delta_d := anchor_d - track_distance
		if delta_d < DISTANT_VISIBLE_BEHIND or delta_d > DISTANT_VISIBLE_AHEAD:
			node.visible = false
			continue
		node.visible = true
		if String(node.name).begins_with("EnergyColony"):
			continue
		var shade := 1.0
		if delta_d > 50.0:
			shade = clampf(1.0 - (delta_d - 50.0) / 420.0 * 0.14, 0.86, 1.0)
		elif delta_d < 0.0:
			shade = clampf(1.0 + delta_d / 110.0 * 0.1, 0.9, 1.0)
		if _uses_near_far_light_split():
			if delta_d > 70.0:
				var far_t := clampf((delta_d - 70.0) / 360.0, 0.0, 1.0)
				shade *= lerpf(1.0, 0.62, far_t)
			elif delta_d >= 0.0 and delta_d < 36.0:
				shade *= lerpf(0.88, 1.0, delta_d / 36.0)
		elif _is_relay_mission():
			if delta_d > 50.0:
				var far_t := clampf((delta_d - 50.0) / 340.0, 0.0, 1.0)
				# 远景只轻压暗，避免叠 albedo_keep 后变成黑块
				shade *= lerpf(1.0, 0.74, far_t)
			elif delta_d >= 0.0 and delta_d < 48.0:
				shade *= lerpf(0.88, 1.0, delta_d / 48.0)
		var last_shade := float(node.get_meta("distant_last_shade", -1.0))
		if absf(last_shade - shade) < 0.01:
			continue
		node.set_meta("distant_last_shade", shade)
		_apply_distant_depth_visual(node, shade)

func _apply_distant_depth_visual(root: Node3D, shade: float) -> void:
	for gi_node in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := gi_node as GeometryInstance3D
		if gi.mesh:
			for surface_idx in gi.mesh.get_surface_count():
				_apply_distant_depth_surface(gi, surface_idx, shade)
		elif gi.material_override:
			gi.material_override = _apply_distant_depth_material(
				gi, gi.material_override, shade, "override"
			)

func _apply_distant_depth_surface(gi: GeometryInstance3D, surface_idx: int, shade: float) -> void:
	var mat: Material = gi.get_surface_override_material(surface_idx)
	if mat == null and gi.mesh:
		mat = gi.mesh.surface_get_material(surface_idx)
	if mat == null:
		return
	var tuned := _apply_distant_depth_material(gi, mat, shade, "s%d" % surface_idx)
	gi.set_surface_override_material(surface_idx, tuned)

func _apply_distant_depth_material(
	gi: GeometryInstance3D,
	src: Material,
	shade: float,
	surface_key: String
) -> Material:
	if not src is StandardMaterial3D:
		return src
	var meta_key := "distant_base_albedo_%s" % surface_key
	if not gi.has_meta(meta_key):
		gi.set_meta(meta_key, (src as StandardMaterial3D).albedo_color)
	var base: Color = gi.get_meta(meta_key)
	var mat := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
	mat.disable_fog = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.albedo_color = Color(base.r * shade, base.g * shade, base.b * shade, 1.0)
	if _is_relay_mission():
		# 远景也关雾、保留本色；轻微压暗即可
		mat.metallic = minf(mat.metallic, 0.18)
		mat.roughness = clampf(mat.roughness, 0.32, 0.80)
		mat.metallic_specular = 0.42
		mat.rim_enabled = false
	return mat

func _make_distant_fallback_silhouette(height: float, base: Color) -> Node3D:
	var root := Node3D.new()
	root.name = "HorizonFallback"
	var mesh_inst := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(height * 0.16, height, height * 0.16)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = base
	mat.disable_fog = true
	mesh.material = mat
	mesh_inst.mesh = mesh
	mesh_inst.position = Vector3(0.0, height * 0.5, 0.0)
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mesh_inst)
	return root

func _make_distant_material_from(src: Material) -> Material:
	if src is StandardMaterial3D:
		var mat := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
		mat.disable_fog = true
		# 保留 GLB 原贴图；中继站也关雾，避免天空色洗进远景
		return mat
	if src is BaseMaterial3D:
		var dup := src.duplicate()
		if dup is StandardMaterial3D:
			return _make_distant_material_from(dup)
		if dup is BaseMaterial3D:
			(dup as BaseMaterial3D).disable_fog = true
		return dup
	return src

func _tune_distant_geometry_material(gi: GeometryInstance3D) -> void:
	if gi.mesh:
		for surface_idx in gi.mesh.get_surface_count():
			var src: Material = gi.get_surface_override_material(surface_idx)
			if src == null:
				src = gi.mesh.surface_get_material(surface_idx)
			if src == null:
				continue
			var tuned := _make_distant_material_from(src)
			if tuned:
				gi.set_surface_override_material(surface_idx, tuned)
	elif gi.material_override:
		gi.material_override = _make_distant_material_from(gi.material_override)

func _apply_distant_atmosphere_material(root: Node3D, _crystal: bool = false) -> void:
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gi.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		_tune_distant_geometry_material(gi)
	if _is_relay_mission():
		_apply_relay_nightscape_look(root, 0)
	# 生成后立即写入一次深度明暗，避免首帧过暗/不可见。
	var anchor_root := root
	while anchor_root.get_parent() is Node3D and not anchor_root.has_meta("path_distance"):
		anchor_root = anchor_root.get_parent() as Node3D
	if anchor_root.has_meta("path_distance"):
		var delta_d := float(anchor_root.get_meta("path_distance")) - track_distance
		var shade := 1.0
		if delta_d > 50.0:
			shade = clampf(1.0 - (delta_d - 50.0) / 420.0 * 0.14, 0.86, 1.0)
		elif delta_d < 0.0:
			shade = clampf(1.0 + delta_d / 110.0 * 0.1, 0.9, 1.0)
		_apply_distant_depth_visual(root, shade)

func _place_path_sand_ribbon(
	distance: float,
	lateral: float,
	width: float,
	length: float,
	material: Material
) -> void:
	var sample := _sample_path(distance)
	var sand := MeshInstance3D.new()
	var sand_mesh := BoxMesh.new()
	sand_mesh.size = Vector3(width, 0.07, length)
	sand_mesh.material = material
	sand.mesh = sand_mesh
	sand.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sand.position = (sample["pos"] as Vector3) + (sample["right"] as Vector3) * lateral
	sand.position.y = GROUND_Y - 0.05 - 0.062
	sand.rotation.y = float(sample["yaw"])
	_side_dressing_root.add_child(sand)

func _spawn_path_side_prop(
	distance: float,
	lateral: float,
	paths: Array[String],
	target_height: float,
	rng: RandomNumberGenerator
) -> void:
	if paths.is_empty():
		return
	var asset_path := paths[rng.randi() % paths.size()]
	var scene := _load_runner_scene(asset_path, false)
	var root := Node3D.new()
	root.name = "SideProp_%d" % _side_dressing_root.get_child_count()
	_side_dressing_root.add_child(root)
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	root.position = placed["pos"]
	root.rotation.y = float(placed["yaw"]) + rng.randf_range(-0.55, 0.55)
	_add_scaled_model_visual(
		root,
		scene,
		"SidePropModel",
		target_height,
		rng.randf_range(-25.0, 25.0),
		Vector3.ZERO,
		clampf(target_height * 1.75, 2.5, 8.0)
	)
	_disable_mesh_shadows(root)

func _disable_mesh_shadows(root: Node3D) -> void:
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		(node as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _build_industrial_surroundings(theme: Dictionary) -> void:
	var sand_material := _make_material(theme.get("sand", Color(0.38, 0.24, 0.14)), Color(0.55, 0.32, 0.18), 0.22)
	var rust_material := _make_material(Color(0.28, 0.18, 0.12), theme.get("crystal", Color(0.85, 0.42, 0.12)), 0.45)
	var silhouette_material := _make_material(Color(0.08, 0.07, 0.06), Color(0.35, 0.22, 0.12), 0.18)
	var segment_len := 96.0
	var segment_count := int(ceil((_track_length + 120.0) / segment_len))
	for segment_index in segment_count:
		var seg_z := -segment_index * segment_len - segment_len * 0.5
		for x in [-32.0, 32.0]:
			var sand := MeshInstance3D.new()
			var sand_mesh := BoxMesh.new()
			sand_mesh.size = Vector3(46.0, 0.08, segment_len + 0.5)
			sand_mesh.material = sand_material
			sand.mesh = sand_mesh
			sand.position = Vector3(x, GROUND_Y - 0.18, seg_z)
			track_root.add_child(sand)
		_add_background_ruins(seg_z, -22.0, silhouette_material)
		if segment_index % 2 == 1:
			_add_cracked_glass_patch(seg_z, 22.0, rust_material)

func _build_savanna_surroundings(theme: Dictionary) -> void:
	var sand_material := _make_material(theme.get("sand", Color(0.62, 0.48, 0.22)), Color(0.78, 0.68, 0.32), 0.16)
	var tree_material := _make_material(Color(0.22, 0.34, 0.14), theme.get("crystal", Color(0.35, 0.78, 0.42)), 0.35)
	var bush_material := _make_material(Color(0.18, 0.28, 0.12), Color(0.45, 0.82, 0.28), 0.28)
	var segment_len := 96.0
	var segment_count := int(ceil((_track_length + 120.0) / segment_len))
	for segment_index in segment_count:
		var seg_z := -segment_index * segment_len - segment_len * 0.5
		for x in [-32.0, 32.0]:
			var sand := MeshInstance3D.new()
			var sand_mesh := BoxMesh.new()
			sand_mesh.size = Vector3(46.0, 0.08, segment_len + 0.5)
			sand_mesh.material = sand_material
			sand.mesh = sand_mesh
			sand.position = Vector3(x, GROUND_Y - 0.18, seg_z)
			track_root.add_child(sand)
		if segment_index % 2 == 0:
			_add_background_crystals(seg_z, -21.0, tree_material)
		else:
			for i in 3:
				var bush := MeshInstance3D.new()
				var mesh := SphereMesh.new()
				mesh.radius = randf_range(0.55, 1.1)
				mesh.height = mesh.radius * 2.0
				mesh.material = bush_material
				bush.mesh = mesh
				bush.position = Vector3(23.0 + i * 2.2, GROUND_Y + mesh.radius * 0.5, seg_z + randf_range(-16.0, 16.0))
				track_root.add_child(bush)

func _add_background_ruins(seg_z: float, x_base: float, material: Material) -> void:
	for i in 4:
		var tower := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(randf_range(1.2, 2.6), randf_range(2.5, 7.5), randf_range(1.0, 2.2))
		mesh.material = material
		tower.mesh = mesh
		tower.position = Vector3(
			x_base + i * randf_range(2.6, 4.2),
			GROUND_Y - 0.1 + mesh.size.y * 0.5,
			seg_z + randf_range(-22.0, 22.0)
		)
		tower.rotation_degrees.y = randf_range(-8.0, 8.0)
		track_root.add_child(tower)

func _add_background_crystals(seg_z: float, x_base: float, material: Material) -> void:
	for i in 3:
		var crystal := MeshInstance3D.new()
		var mesh := PrismMesh.new()
		mesh.size = Vector3(randf_range(0.8, 1.8), randf_range(3.0, 7.0), randf_range(0.8, 1.8))
		mesh.material = material
		crystal.mesh = mesh
		crystal.position = Vector3(
			x_base + i * randf_range(2.0, 4.0),
			GROUND_Y - 0.1 + mesh.size.y * 0.5,
			seg_z + randf_range(-20.0, 20.0)
		)
		crystal.rotation_degrees = Vector3(randf_range(-6.0, 6.0), randf_range(0.0, 180.0), randf_range(-5.0, 5.0))
		track_root.add_child(crystal)

func _add_cracked_glass_patch(seg_z: float, x: float, material: Material) -> void:
	var patch := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(7.0, 0.035, 12.0)
	mesh.material = material
	patch.mesh = mesh
	patch.position = Vector3(x, GROUND_Y - 0.12, seg_z)
	patch.rotation_degrees.y = randf_range(-10.0, 10.0)
	track_root.add_child(patch)

func _build_choice_gate(at_distance: float, zone: Dictionary) -> void:
	var lane_a := int(zone.get("lane_a", 0))
	var lane_b := int(zone.get("lane_b", 2))
	var label_a := String(zone.get("label_a", "安全岔路"))
	var label_b := String(zone.get("label_b", "速通岔路"))
	var effect_a := String(zone.get("effect_a", "repair"))
	var effect_b := String(zone.get("effect_b", "fast"))
	# 放在分叉明显张开处，贴左右岔口；用浮空标牌，不再做可贴地穿过的大门
	var gate_d := at_distance + maxf(float(zone.get("length", 90.0)) * 0.18, 14.0)
	var spread := float(zone.get("spread", 22.0))
	var mouth_lateral := maxf(spread * _fork_envelope(0.18), 8.0)
	for lane in [lane_a, lane_b]:
		var is_left: bool = lane == lane_a
		var side := -1.0 if is_left else 1.0
		var label := label_a if is_left else label_b
		var effect := effect_a if is_left else effect_b
		var accent := Color(0.28, 0.9, 0.7) if is_left else Color(0.55, 0.76, 0.92)
		var marker := Node3D.new()
		marker.name = "ChoiceGate"
		var placed := _world_on_path(gate_d, mouth_lateral * side, GROUND_Y + 3.2)
		marker.position = placed["pos"]
		marker.rotation.y = float(placed["yaw"]) + (-0.2 if is_left else 0.2)
		track_root.add_child(marker)
		_add_choice_gate_banner(marker, accent, label, effect, is_left)

func _finish_sprint_entries() -> Array:
	var layout_id := _mission_layout_id()
	if layout_id != "":
		var items := ObstacleLayout.load_finish_sprints(layout_id)
		if not items.is_empty():
			return items
	# 默认：终点门前约 110m，偏左道窄板
	var finish_d := _finish_line_distance if _finish_line_distance > 0.0 else maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)
	return [{"distance": maxf(finish_d - 110.0, 60.0), "lane": -1}]

func _build_finish_sprint_pads() -> void:
	_finish_sprint_pads.clear()
	for raw in _finish_sprint_entries():
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var dist := float(raw.get("distance", 0.0))
		if dist < 40.0:
			continue
		var lane := int(raw.get("lane", 0))
		# 约占跑道宽度 1/3（约一条半车道），不对整条路铺板
		var width_ratio := clampf(float(raw.get("width_ratio", 1.0 / 3.0)), 0.28, 0.62)
		if width_ratio >= 0.52:
			lane = 0
		var half_w := _runway_half_width() * width_ratio
		var root := _make_finish_sprint_pad(dist, lane, half_w, width_ratio)
		_finish_sprint_pads.append({
			"distance": dist,
			"lane": lane,
			"half_width": half_w,
			"width_ratio": width_ratio,
			"triggered": false,
			"node": root,
		})

func _make_finish_sprint_pad(distance: float, lane: int, half_w: float, width_ratio: float = 0.33) -> Node3D:
	var root := Node3D.new()
	root.name = "FinishSprintPad"
	var lateral := 0.0 if width_ratio >= 0.52 else float(lane) * LANE_WIDTH
	var placed := _world_on_path(distance, lateral, GROUND_Y)
	root.position = placed["pos"]
	root.rotation.y = float(placed["yaw"])
	track_root.add_child(root)
	var radius := maxf(half_w * 1.15, 1.35)
	var ring := MeshInstance3D.new()
	ring.name = "SprintPentagon"
	ring.mesh = _make_polygon_ring_mesh(5, radius * 0.72, radius)
	var ring_mat := _make_material(Color(1.0, 0.86, 0.22, 0.92), Color(1.0, 0.78, 0.18), 2.4)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	ring.position = Vector3(0.0, 0.04, 0.0)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(ring)
	var fill := MeshInstance3D.new()
	fill.mesh = _make_polygon_ring_mesh(5, 0.08, radius * 0.68)
	var fill_mat := _make_material(Color(1.0, 0.82, 0.18, 0.22), Color(1.0, 0.72, 0.12), 1.1)
	fill_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fill.material_override = fill_mat
	fill.position = Vector3(0.0, 0.03, 0.0)
	fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(fill)
	var tip := Label3D.new()
	tip.text = "SPEED UP"
	tip.font_size = 72
	tip.modulate = Color(1.0, 0.92, 0.42)
	tip.outline_size = 12
	tip.outline_modulate = Color(0.08, 0.06, 0.02)
	tip.position = Vector3(0.0, 1.85, 0.0)
	tip.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tip.no_depth_test = true
	root.add_child(tip)
	return root


func _make_polygon_ring_mesh(sides: int, inner_r: float, outer_r: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := maxi(sides, 3)
	for i in n:
		var a0 := -PI * 0.5 + TAU * float(i) / float(n)
		var a1 := -PI * 0.5 + TAU * float(i + 1) / float(n)
		var o0 := Vector3(cos(a0) * outer_r, 0.0, sin(a0) * outer_r)
		var o1 := Vector3(cos(a1) * outer_r, 0.0, sin(a1) * outer_r)
		var i0 := Vector3(cos(a0) * inner_r, 0.0, sin(a0) * inner_r)
		var i1 := Vector3(cos(a1) * inner_r, 0.0, sin(a1) * inner_r)
		st.add_vertex(i0)
		st.add_vertex(o0)
		st.add_vertex(o1)
		st.add_vertex(i0)
		st.add_vertex(o1)
		st.add_vertex(i1)
	return st.commit()

func _check_finish_sprint_pads() -> void:
	if _finish_sprint_timer > 0.0:
		return
	for pad in _finish_sprint_pads:
		if typeof(pad) != TYPE_DICTIONARY:
			continue
		if bool(pad.get("triggered", false)):
			continue
		var dist := float(pad.get("distance", 0.0))
		if track_distance < dist or track_distance > dist + 5.5:
			continue
		var lane := int(pad.get("lane", 0))
		var half_w := float(pad.get("half_width", LANE_WIDTH * 0.45))
		var width_ratio := float(pad.get("width_ratio", half_w / maxf(_runway_half_width(), 0.01)))
		var target_lat := float(lane) * LANE_WIDTH
		if width_ratio >= 0.52:
			if absf(current_lateral) > _runway_half_width() * 0.92:
				continue
		elif absf(current_lateral - target_lat) > half_w + 0.12:
			continue
		pad["triggered"] = true
		_apply_finish_sprint()
		var node = pad.get("node", null)
		if node != null and is_instance_valid(node):
			var tw := create_tween()
			tw.tween_property(node, "scale", Vector3(1.18, 1.18, 1.18), 0.08)
			tw.tween_property(node, "scale", Vector3.ONE, 0.2)
		return

func _apply_finish_sprint() -> void:
	_finish_sprint_timer = FINISH_SPRINT_DURATION
	_speed_boost_timer = 0.0
	speed_penalty_mult = 1.0
	speed_penalty_timer = 0.0
	camera_shake = maxf(camera_shake, 0.14)
	run_score += 120
	if player != null:
		_spawn_floating_pickup_label("+15", player.global_position, Color(1.0, 0.90, 0.28))
	_show_gate_toast("SPEED UP · 终点冲刺")
	strike_toast_label.modulate = Color(1.0, 0.88, 0.4, 1.0)
	strike_toast_timer = 1.5

func _add_choice_gate_banner(parent: Node3D, accent: Color, label: String, effect: String, is_left: bool) -> void:
	var board := MeshInstance3D.new()
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(3.6, 2.4, 0.1)
	var board_mat := _make_material(Color(0.04, 0.05, 0.08, 0.78), accent * 0.4, 0.6)
	board_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	board.mesh = board_mesh
	board.material_override = board_mat
	board.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(board)
	var tag := _fork_ground_tag(effect, is_left)
	var tip := Label3D.new()
	tip.text = "%s\n%s\n%s\n%s" % [
		tag,
		"←" if is_left else "→",
		label,
		_choice_gate_effect_hint(effect),
	]
	tip.font_size = 56 if effect == "fast" else 46
	tip.pixel_size = 0.012
	var is_speed := effect == "fast"
	tip.modulate = Color(0.94, 0.97, 1.0, 1.0) if is_speed else accent.lightened(0.2)
	tip.outline_size = 18
	tip.outline_modulate = Color(0.08, 0.18, 0.36, 1.0) if is_speed else Color(0.0, 0.12, 0.1, 0.98)
	tip.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tip.position = Vector3(0.0, 0.1, 0.12)
	parent.add_child(tip)
	# 地面指向岔路的短色带
	var guide := MeshInstance3D.new()
	var guide_mesh := BoxMesh.new()
	guide_mesh.size = Vector3(1.4, 0.05, 3.2)
	guide.mesh = guide_mesh
	guide.material_override = _make_material(accent * 0.35, accent, 0.85)
	guide.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	guide.position = Vector3(0.0, -3.1, -0.6)
	parent.add_child(guide)

func _build_fork_approach_symbols(zone: Dictionary) -> void:
	# 进岔前：空中视线中央醒目提示（不上路）
	var at_distance := float(zone.get("distance", 0.0))
	var effect_a := String(zone.get("effect_a", "safe"))
	var effect_b := String(zone.get("effect_b", "fast"))
	var left_tag := _fork_ground_tag(effect_a, true)
	var right_tag := _fork_ground_tag(effect_b, false)
	# REGULAR 青绿；SPEEDUP 用冷钢蓝白，避开沙漠橙且不艳俗
	var left_color := Color(0.32, 0.92, 0.72)
	var right_color := Color(0.58, 0.78, 0.95)
	# 加速门与分叉触发点对齐：过门后立刻进入 1~2s 提速
	# 左右拉开，避免 REGULAR/SPEEDUP 在透视下互相遮挡
	var sign_d: float = maxf(at_distance - 0.8, 12.0)
	_add_fork_air_sign(sign_d, -4.5, left_tag, "←", left_color)
	_add_fork_air_sign(sign_d, 4.5, right_tag, "→", right_color)

func _fork_ground_tag(effect: String, is_left: bool) -> String:
	match effect:
		"repair", "safe":
			return "REGULAR"
		"fast":
			return "SPEEDUP"
		"bonus":
			return "BONUS"
		_:
			return "REGULAR" if is_left else "SPEEDUP"

func _add_fork_air_sign(distance: float, lateral: float, tag: String, arrow: String, accent: Color) -> void:
	var marker := Node3D.new()
	marker.name = "ForkAirSign"
	# 抬高：避开分叉门板，保证各角度都能看清文字
	var placed := _world_on_path(distance, lateral, GROUND_Y + 5.9)
	marker.position = placed["pos"]
	marker.rotation.y = float(placed["yaw"])
	track_root.add_child(marker)

	# 内容再往外侧、上方偏一点，减少与分叉门重合
	var side_nudge := 0.35 if lateral > 0.0 else -0.35
	var content := Node3D.new()
	content.name = "SignContent"
	content.position = Vector3(side_nudge, 0.55, 0.0)
	marker.add_child(content)

	# 深色不透明背板：保证字在沙漠天空上可读
	var board := MeshInstance3D.new()
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(3.4, 2.35, 0.1)
	var board_mat := _make_material(Color(0.02, 0.03, 0.06, 0.92), accent * 0.45, 0.85)
	board_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	board.mesh = board_mesh
	board.material_override = board_mat
	board.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	board.position = Vector3(0.0, 0.15, 0.0)
	content.add_child(board)

	# 亮色描边框，进一步和背景拉开
	var frame := MeshInstance3D.new()
	var frame_mesh := BoxMesh.new()
	frame_mesh.size = Vector3(3.6, 2.55, 0.04)
	frame.mesh = frame_mesh
	frame.material_override = _make_material(accent * 0.35, accent, 2.4)
	frame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	frame.position = Vector3(0.0, 0.15, -0.04)
	content.add_child(frame)

	var title := Label3D.new()
	title.text = tag
	title.font_size = 92
	title.pixel_size = 0.012
	# SPEEDUP：冷白字 + 深蓝描边；REGULAR：青绿
	var is_speed := tag == "SPEEDUP"
	title.modulate = Color(0.94, 0.97, 1.0, 1.0) if is_speed else accent.lightened(0.2)
	title.outline_size = 20
	title.outline_modulate = Color(0.08, 0.18, 0.36, 1.0) if is_speed else Color(0.0, 0.14, 0.12, 0.98)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.no_depth_test = true
	title.render_priority = 8
	title.position = Vector3(0.0, 0.95, 0.12)
	content.add_child(title)

	var arrow_label := Label3D.new()
	arrow_label.text = arrow
	arrow_label.font_size = 140
	arrow_label.pixel_size = 0.014
	arrow_label.modulate = Color(0.86, 0.92, 1.0, 1.0) if is_speed else accent
	arrow_label.outline_size = 22
	arrow_label.outline_modulate = Color(0.06, 0.16, 0.32, 1.0) if is_speed else Color(0.0, 0.12, 0.1, 0.98)
	arrow_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arrow_label.no_depth_test = true
	arrow_label.render_priority = 8
	arrow_label.position = Vector3(0.0, -0.05, 0.12)
	content.add_child(arrow_label)

	# 轻量箭头块，补充立体感
	var chev := MeshInstance3D.new()
	var cm := PrismMesh.new()
	cm.size = Vector3(1.1, 0.35, 0.85)
	chev.mesh = cm
	chev.material_override = _make_material(accent * 0.55, accent, 2.0)
	chev.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	chev.rotation_degrees = Vector3(0.0, 0.0 if lateral > 0.0 else 180.0, 90.0)
	chev.position = Vector3(0.0, -0.85, 0.12)
	content.add_child(chev)

func _add_choice_gate_arch(parent: Node3D, accent: Color, label: String, effect: String) -> void:
	# 固定尺寸拱门：两侧完全一致；面板改为不透明以免 overdraw
	var arch_w := 2.4
	var arch_h := 2.8
	var pillar_t := 0.28
	var mat := _make_material(accent * 0.45, accent, 1.05)
	for sx in [-1.0, 1.0]:
		var pillar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(pillar_t, arch_h, pillar_t)
		pillar.mesh = box
		pillar.material_override = mat
		pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pillar.position = Vector3(sx * arch_w * 0.5, arch_h * 0.5, 0.0)
		parent.add_child(pillar)
	var beam := MeshInstance3D.new()
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(arch_w + pillar_t, 0.26, pillar_t)
	beam.mesh = beam_mesh
	beam.material_override = mat
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	beam.position = Vector3(0.0, arch_h - 0.08, 0.0)
	parent.add_child(beam)
	var panel := MeshInstance3D.new()
	var panel_mesh := BoxMesh.new()
	panel_mesh.size = Vector3(arch_w * 0.92, arch_h * 0.72, 0.05)
	var panel_mat := _make_material(accent * 0.35, accent, 0.75)
	panel.mesh = panel_mesh
	panel.material_override = panel_mat
	panel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	panel.position = Vector3(0.0, arch_h * 0.48, 0.0)
	parent.add_child(panel)
	var tip := Label3D.new()
	var ground_tag := _fork_ground_tag(effect, effect in ["repair", "safe"])
	tip.text = "%s\n%s\n%s" % [ground_tag, label, _choice_gate_effect_hint(effect)]
	tip.font_size = 46 if effect == "fast" else 40
	tip.modulate = accent.lightened(0.25)
	tip.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tip.position = Vector3(0.0, arch_h + 0.7, 0.0)
	parent.add_child(tip)
	var guide := MeshInstance3D.new()
	var guide_mesh := BoxMesh.new()
	guide_mesh.size = Vector3(1.2, 0.05, 2.6)
	guide_mesh.material = _make_material(accent * 0.3, accent, 0.9)
	guide.mesh = guide_mesh
	guide.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	guide.position = Vector3(0.0, 0.05, -1.2)
	parent.add_child(guide)

func _choice_gate_effect_hint(effect: String) -> String:
	match effect:
		"repair", "safe":
			return "稳速·货物护航"
		"fast":
			return "突然飞驰！"
		"bonus":
			return "额外得分"
		_:
			return "通过获益"

func _build_junction_marker(at_distance: float, required_lane: int) -> void:
	var marker := Node3D.new()
	marker.name = "JunctionMarker"
	var placed := _world_on_path(at_distance, LANES[required_lane] * LANE_WIDTH, 0.0)
	marker.position = placed["pos"]
	marker.rotation.y = float(placed["yaw"])
	track_root.add_child(marker)

	var is_left := required_lane == 0
	var arrow_color := Color(0.2, 1.0, 0.55) if is_left else Color(1.0, 0.55, 0.15)
	var mat := _make_material(arrow_color * 0.4, arrow_color, 2.0)
	var arrow := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.2, 0.12, 3.6)
	mesh.material = mat
	arrow.mesh = mesh
	arrow.position = Vector3(0, 0.15, 0)
	arrow.rotation_degrees = Vector3(0, -25 if is_left else 25, 0)
	marker.add_child(arrow)

func _build_runner() -> void:
	player = CharacterBody3D.new()
	player.name = "RunnerPlayer"
	player.position = Vector3(0, GROUND_Y, 0)
	add_child(player)

	var body := Node3D.new()
	body.name = "PlayerVisualRoot"
	player.add_child(body)
	player_body = body
	trail_particles = _make_trail_particles()
	player.add_child(trail_particles)
	landing_particles = _make_landing_particles()
	player.add_child(landing_particles)
	foot_spark_particles = _make_foot_spark_particles()
	player.add_child(foot_spark_particles)
	body_spark_particles = _make_body_spark_particles()
	player.add_child(body_spark_particles)
	_build_ember_flame_aura()
	jump_streak_particles = _make_jump_streak_particles()
	player.add_child(jump_streak_particles)
	wall_boost_particles = _make_wall_boost_particles()
	player.add_child(wall_boost_particles)
	rush_aura_particles = _make_rush_aura_particles()
	player.add_child(rush_aura_particles)

	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraRig"
	player.add_child(camera_pivot)

	camera = Camera3D.new()
	camera.name = "RunnerCamera"
	camera.current = true
	camera.fov = CAMERA_FOV
	camera.near = 0.08
	camera.far = 820.0
	camera.position = Vector3(0, 0.45, 0)
	camera.rotation_degrees = Vector3(-18, 0, 0)
	camera_pivot.add_child(camera)
	_build_player_visual()
	_add_player_light()
	_ensure_reservoir_sky_dome()
	_update_camera()

func _add_player_light() -> void:
	# 轻量点光：全息路原先双 Omni + 高能量会拖垮移动端/核显
	var key := OmniLight3D.new()
	key.name = "PlayerKeyLight"
	key.position = Vector3(0.0, 1.35, -0.2)
	key.light_color = Color(1.0, 0.82, 0.62)
	var holo := _road_style_id in ["holographic", "energy_neon"]
	key.light_energy = 0.85 if holo else 1.1
	key.omni_range = 4.2 if holo else 5.5
	key.shadow_enabled = false
	player.add_child(key)
	# 全息路关掉第二盏 rim 光，减少动态光照开销
	if holo:
		return
	var rim := OmniLight3D.new()
	rim.name = "PlayerRunwayRim"
	rim.position = Vector3(0.0, 0.35, 0.8)
	rim.light_color = Color(0.7, 0.85, 1.0)
	rim.light_energy = 0.45
	rim.omni_range = 4.0
	rim.shadow_enabled = false
	player.add_child(rim)

func _add_ground_contact_shadow(parent: Node3D, width: float, depth: float) -> void:
	var shadow := MeshInstance3D.new()
	shadow.name = "ContactShadow"
	var mesh := SphereMesh.new()
	mesh.radius = maxf(width, depth) * 0.28
	mesh.height = 0.04
	mesh.radial_segments = 12
	mesh.rings = 4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.02, 0.015, 0.01, 0.28)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	shadow.mesh = mesh
	shadow.scale = Vector3(1.35, 0.15, maxf(depth / maxf(width, 0.01), 0.55))
	shadow.position = Vector3(0.0, 0.01, 0.0)
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(shadow)

func _build_player_visual() -> void:
	for child in player_body.get_children():
		child.queue_free()

	player_body.scale = Vector3.ONE
	player_body.position = Vector3.ZERO
	player_body.rotation = Vector3.ZERO
	_set_player_intro_facing(true)

	player_pose_name = ""
	player_pose_models.clear()
	player_slide_pose_root = null
	player_animation_player = null
	player_animation_name = ""
	_skeletal_run_enabled = false

	var model_yaw := _player_yaw_degrees("model_yaw", PLAYER_MODEL_YAW)
	var slide_yaw := _player_yaw_degrees("slide_yaw", PLAYER_SLIDE_MODEL_YAW)

	var animated_path := _player_asset_path("animated_model", "")
	if animated_path != "":
		var run_anim := _player_run_anim_name()
		var animated_scene := _load_runner_scene(animated_path, false)
		if animated_scene:
			var skeletal_yaw := _player_yaw_degrees("animated_model_yaw", model_yaw + 180.0)
			player_pose_root = _add_scaled_model_visual(
				player_body,
				animated_scene,
				"MixamoRunner",
				PLAYER_SKELETAL_MODEL_HEIGHT,
				skeletal_yaw,
				Vector3.ZERO,
				-1.0,
				-1.0
			)
			_apply_player_surface_textures(player_pose_root)
			_ensure_player_mesh_visible(player_pose_root)
			_player_pose_base_scale = player_pose_root.scale
			_player_pose_base_yaw = player_pose_root.rotation.y
			player_animation_player = _find_animation_player(player_pose_root)
			if player_animation_player and player_animation_player.has_animation(run_anim):
				_skeletal_run_enabled = true
				_configure_player_animations()
				player_slide_pose_root = _add_scaled_model_visual(
					player_body,
					_load_runner_scene(_player_asset_path("slide", PLAYER_SLIDE_SCENE_PATH)),
					"SlidePoseModel",
					PLAYER_SLIDE_MODEL_HEIGHT,
					slide_yaw,
					Vector3.ZERO,
					-1.0,
					-1.0
				)
				_fit_slide_pose_to_runner(player_slide_pose_root)
				player_slide_pose_root.visible = false
				_add_player_pose_model("jump_start", _load_runner_scene(_player_asset_path("jump_start", PLAYER_JUMP_START_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
				_add_player_pose_model("jump_peak", _load_runner_scene(_player_asset_path("jump_peak", PLAYER_JUMP_PEAK_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
				_add_player_pose_model("landing", _load_runner_scene(_player_asset_path("landing", PLAYER_LANDING_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
				_set_player_pose("idle")
				return
		push_warning("Mixamo runner is missing animation '%s'; falling back to pose models." % run_anim)
		if player_pose_root:
			player_pose_root.queue_free()
		player_pose_root = null
		player_animation_player = null
		player_animation_name = ""
		_skeletal_run_enabled = false

	var use_config_player := _player_scene_paths.has("model")
	var animated_scene: PackedScene = null
	if not use_config_player:
		animated_scene = _load_runner_scene(ANIMATED_PLAYER_SCENE_PATH, false)
	if animated_scene:
		player_pose_root = _add_scaled_model_visual(
			player_body,
			animated_scene,
			"CyberpunkArmorRunner",
			PLAYER_MODEL_HEIGHT,
			model_yaw
		)
		player_animation_player = _find_animation_player(player_pose_root)
		if player_animation_player and player_animation_player.has_animation(ANIMATED_PLAYER_RUN_ANIM):
			_configure_player_animations()
			player_slide_pose_root = _add_scaled_model_visual(
				player_body,
				_load_runner_scene(_player_asset_path("slide", PLAYER_SLIDE_SCENE_PATH)),
				"SlidePoseModel",
				PLAYER_SLIDE_MODEL_HEIGHT,
				slide_yaw,
				Vector3.ZERO,
				-1.0,
				-1.0
			)
			_fit_slide_pose_to_runner(player_slide_pose_root)
			player_slide_pose_root.visible = false
			_play_player_animation("idle")
			return

		push_warning("Fallback animated player has no usable run animation; using pose models instead.")
		if player_pose_root:
			player_pose_root.queue_free()
		player_pose_root = null
		player_animation_player = null
		player_animation_name = ""

	_add_player_pose_model("idle", _load_runner_scene(_player_asset_path("model", PLAYER_MODEL_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("run_left", _load_runner_scene(_player_asset_path("run_left", PLAYER_RUN_LEFT_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("run_right", _load_runner_scene(_player_asset_path("run_right", PLAYER_RUN_RIGHT_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("jump_start", _load_runner_scene(_player_asset_path("jump_start", PLAYER_JUMP_START_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("jump_peak", _load_runner_scene(_player_asset_path("jump_peak", PLAYER_JUMP_PEAK_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("landing", _load_runner_scene(_player_asset_path("landing", PLAYER_LANDING_SCENE_PATH)), PLAYER_MODEL_HEIGHT, model_yaw)
	_add_player_pose_model("slide", _load_runner_scene(_player_asset_path("slide", PLAYER_SLIDE_SCENE_PATH)), PLAYER_SLIDE_MODEL_HEIGHT, slide_yaw)
	_set_player_pose("idle")

func _load_runner_scene(path: String, warn_if_missing: bool = true) -> PackedScene:
	if path == "":
		return null
	# 2.5D PNG 障碍：运行时打成透明 Quad 场景
	if path.ends_with(".png") or path.ends_with(".webp") or path.ends_with(".jpg") or path.ends_with(".jpeg"):
		return _get_or_create_sprite_obstacle_scene(path, warn_if_missing)
	if _scene_cache.has(path):
		return _scene_cache[path] as PackedScene

	var scene := ResourceLoader.load(path) as PackedScene
	if scene:
		_scene_cache[path] = scene
		return scene

	var fallback_path: String = IMPORTED_SCENE_FALLBACKS.get(path, "")
	if not fallback_path.is_empty():
		if _scene_cache.has(fallback_path):
			return _scene_cache[fallback_path] as PackedScene
		scene = ResourceLoader.load(fallback_path) as PackedScene
		if scene:
			_scene_cache[fallback_path] = scene
			_scene_cache[path] = scene
			return scene

	if warn_if_missing:
		push_warning("Runner model is missing: %s" % path)
	return null

func _get_or_create_sprite_obstacle_scene(path: String, warn_if_missing: bool = true) -> PackedScene:
	# 能量球尺寸/锚点迭代时强制重建，避免旧 PackedScene 缓存导致大小档不生效
	if "energy_orb" in path:
		_scene_cache.erase(path)
	elif _scene_cache.has(path):
		return _scene_cache[path] as PackedScene
	var tex: Texture2D = null
	# 优先从磁盘读最新 PNG，避免编辑器缓存到未抠透明的旧图
	var abs_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(abs_path):
		var img := Image.new()
		if img.load(abs_path) == OK:
			tex = ImageTexture.create_from_image(img)
	if tex == null and ResourceLoader.exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		if warn_if_missing:
			push_warning("Runner sprite obstacle missing: %s" % path)
		return null

	var root := Node3D.new()
	root.name = "SpriteObstacle"
	root.set_meta("sprite_obstacle_path", path)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "SpriteQuad"
	var quad := QuadMesh.new()
	var tw := maxf(float(tex.get_width()), 1.0)
	var th := maxf(float(tex.get_height()), 1.0)
	var aspect := tw / th
	# 单位高度 1，后续再按玩法缩放；光幕用宽扁比例
	if "phase_curtain" in path:
		quad.size = Vector2(1.0, 1.0 / maxf(aspect, 0.01))  # 先按宽度=1，后面拉到路宽
		root.set_meta("sprite_fit", "road_width")
		root.set_meta("sprite_aspect", aspect)
	elif "energy_sprigs" in path:
		quad.size = Vector2(1.0, 1.0 / maxf(aspect, 0.01))
		root.set_meta("sprite_fit", "road_width")
		root.set_meta("sprite_aspect", aspect)
	else:
		quad.size = Vector2(aspect, 1.0)
		root.set_meta("sprite_fit", "height")
		root.set_meta("sprite_aspect", aspect)

	var mat := StandardMaterial3D.new()
	# 刀口透明：棋盘格残留也不会糊成白板
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.12
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = tex
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if "phase_curtain" in path:
		mat.albedo_color = Color.WHITE
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.emission_enabled = true
		mat.emission = Color(0.35, 0.75, 1.0)
		mat.emission_energy_multiplier = 0.55
	elif "energy_sprigs" in path:
		# 横跨跑道的低棱芽：保留贴图细节，避免自发光 + 无 shading 洗成惨白
		mat.albedo_color = Color(0.72, 0.82, 0.95)
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		mat.emission_enabled = true
		mat.emission = Color(0.1, 0.22, 0.38)
		mat.emission_energy_multiplier = 0.16
	elif "orb" in path:
		mat.albedo_color = Color(0.92, 0.95, 1.0)
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.emission_enabled = true
		mat.emission = Color(0.55, 0.75, 1.0)
		mat.emission_texture = tex
		mat.emission_energy_multiplier = 2.4
	else:
		mat.albedo_color = Color.WHITE
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.emission_enabled = true
		mat.emission = Color(0.4, 0.7, 0.95)
		mat.emission_energy_multiplier = 0.4
	mat.no_depth_test = false
	quad.material = mat
	mesh_instance.mesh = quad
	mesh_instance.rotation_degrees.y = 180.0 if "phase_curtain" in path else 0.0
	mesh_instance.position.y = 0.0 if "phase_curtain" in path or "energy_sprigs" in path or "orb" in path else 0.5
	root.add_child(mesh_instance)
	mesh_instance.owner = root

	var packed := PackedScene.new()
	var err := packed.pack(root)
	root.free()
	if err != OK:
		if warn_if_missing:
			push_warning("Failed to pack sprite obstacle: %s" % path)
		return null
	_scene_cache[path] = packed
	return packed

func _get_slide_obstacle_scene(index: int) -> PackedScene:
	if not _slide_obstacle_paths.is_empty():
		return _load_runner_scene(_slide_obstacle_paths[index % _slide_obstacle_paths.size()])
	return _slide_obstacle_scene

func _get_slide_obstacle_scene_glb_fallback() -> PackedScene:
	# 滑铲横杆：优先锈蚀水管，与封道/列车区分
	return _get_slide_obstacle_scene_by_hint(["锈蚀水管", "rust", "pipe"], 1)

func _get_train_obstacle_scene() -> PackedScene:
	for path in _train_gate_prop_paths():
		var scene := _load_runner_scene(path, false)
		if scene != null:
			return scene
	return _get_slide_obstacle_scene_by_hint(["坍塌广告牌", "billboard"], 2)

func _runner_visual_batch() -> String:
	match String(Global.runner_location_id):
		"medical", "gate":
			return "crisis"
		"relay":
			return "relay"
		_:
			return "early"

func _lane_block_prop_paths() -> Array[String]:
	match _runner_visual_batch():
		"crisis":
			return [
				OBSTACLE_PROP_MEDICAL_CRATE,
				OBSTACLE_PROP_BROKEN_DRONE,
				OBSTACLE_PROP_MEDICAL_POD,
				OBSTACLE_PROP_EXCAVATOR,
			]
		"relay":
			return [OBSTACLE_PROP_RELAY_DRONE, OBSTACLE_PROP_METEORITE]
		_:
			return [
				OBSTACLE_PROP_METEORITE,
				OBSTACLE_PROP_BROKEN_DRONE,
				OBSTACLE_PROP_MEDICAL_CRATE,
			]

func _train_gate_prop_paths() -> Array[String]:
	match _runner_visual_batch():
		"crisis":
			return [
				OBSTACLE_PROP_MEDICAL_CRATE,
				OBSTACLE_PROP_BROKEN_DRONE,
				OBSTACLE_PROP_MEDICAL_POD,
				OBSTACLE_PROP_EXCAVATOR,
			]
		"relay":
			return [OBSTACLE_PROP_RELAY_DRONE, OBSTACLE_PROP_METEORITE, OBSTACLE_PROP_BROKEN_DRONE]
		_:
			return [
				OBSTACLE_PROP_METEORITE,
				OBSTACLE_PROP_BROKEN_DRONE,
				OBSTACLE_PROP_MEDICAL_CRATE,
				"res://mvp素材第二批/障碍物/0803/废旧广告牌（滑铲）.glb",
			]

func _get_lane_block_scene() -> PackedScene:
	for path in _lane_block_prop_paths():
		var scene := _load_runner_scene(path, false)
		if scene != null:
			return scene
	return _get_slide_obstacle_scene_by_hint(["闪避柱", "全息闪避", "能量裂缝", "crack"], 1)

func _get_slide_obstacle_scene_by_hint(hints: Array, fallback_index: int) -> PackedScene:
	var matched := _first_slide_asset_for_hints(hints)
	if matched != "":
		return _load_runner_scene(matched, false)
	if not _slide_obstacle_paths.is_empty():
		return _get_slide_obstacle_scene(fallback_index)
	return _slide_obstacle_scene

func _get_jump_obstacle_scene(index: int) -> PackedScene:
	if _jump_obstacle_paths.is_empty():
		return null
	return _load_runner_scene(_jump_obstacle_paths[index % _jump_obstacle_paths.size()])

func _is_energy_orb_asset_path(path: String) -> bool:
	if "energy_orb" in path:
		return true
	for orb_path in RUNNER_ENERGY_ORB_SPRITES:
		if path == orb_path:
			return true
	return false

func _ensure_energy_orb_assets_loaded() -> void:
	for path in RUNNER_ENERGY_ORB_SPRITES:
		var p := String(path).strip_edges()
		if p != "" and not _jump_obstacle_paths.has(p):
			_jump_obstacle_paths.append(p)

func _resolve_energy_orb_asset_path(item: Dictionary) -> String:
	_ensure_energy_orb_assets_loaded()
	var indices := _energy_orb_path_indices()
	if indices.is_empty():
		return RUNNER_ENERGY_ORB_GRUMPY
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	var pick := indices[(absi(lane * 13 + dist_key)) % indices.size()]
	if pick >= 0 and pick < _jump_obstacle_paths.size():
		return _jump_obstacle_paths[pick]
	return RUNNER_ENERGY_ORB_GRUMPY

func _jump_bar_path_indices() -> Array[int]:
	var out: Array[int] = []
	for i in range(_jump_obstacle_paths.size()):
		if not _is_energy_orb_asset_path(_jump_obstacle_paths[i]):
			out.append(i)
	return out

func _energy_orb_path_indices() -> Array[int]:
	var out: Array[int] = []
	for i in range(_jump_obstacle_paths.size()):
		if _is_energy_orb_asset_path(_jump_obstacle_paths[i]):
			out.append(i)
	return out

func _is_lightweight_obstacle_asset(path: String) -> bool:
	var lower := String(path).to_lower()
	return (
		"obstacles_lightweight" in lower
		or "crumbling_ruined_wall" in lower
		or "rusty_industrial_pipeline" in lower
		or "spike_barrier" in lower
	)

func _uses_lightweight_jump_obstacles() -> bool:
	for path in _jump_obstacle_paths:
		if _is_lightweight_obstacle_asset(path):
			return true
	return false

func _is_color_block_obstacle_asset(path: String) -> bool:
	# 能量屏障/全息会被拉成整面发光色块，禁止当跳跃/滑铲模型
	var p := String(path)
	return p == "" or "能量屏障" in p or "全息" in p or "energy_barrier" in p.to_lower() or "hologram" in p.to_lower()

func _resolve_jump_bar_style(item: Dictionary) -> String:
	var forced := String(item.get("jump_style", "")).strip_edges().to_lower()
	if forced != "":
		return forced
	# 水源据点：约六成木栅栏，贴合旧关与 128BPM 跳跃节奏；居民穹顶仍用断墙 GLB
	if _is_reservoir_location():
		var dist_key := int(round(float(item.get("distance", 0.0))))
		var lane := int(item.get("lane", 0))
		if (absi(dist_key + lane * 17) % 5) < 3:
			return "wood_fence"
		return "glb"
	if _uses_lightweight_jump_obstacles():
		return "glb"
	return "glb"

func _is_lightweight_jump_obstacle_asset(path: String) -> bool:
	var lower := String(path).to_lower()
	return (
		"crumbling_ruined_wall" in lower
		or ("obstacles_lightweight" in lower and "jump" in lower)
	)

func _jump_target_height_for(asset_path: String) -> float:
	if _is_lightweight_jump_obstacle_asset(asset_path):
		return JUMP_WALL_TARGET_HEIGHT
	return JUMP_BAR_HEIGHT

func _pick_jump_bar_scene_index(item: Dictionary) -> int:
	var indices := _jump_bar_path_indices()
	if indices.is_empty():
		return 0
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return indices[(absi(lane * 17 + dist_key)) % indices.size()]

func _pick_energy_orb_scene_index(item: Dictionary) -> int:
	var asset_path := _resolve_energy_orb_asset_path(item)
	for i in range(_jump_obstacle_paths.size()):
		if _jump_obstacle_paths[i] == asset_path:
			return i
	return maxi(_jump_obstacle_paths.size() - 1, 0)

func _pick_slide_obstacle_scene_index(item: Dictionary) -> int:
	var usable := _slide_usable_path_indices()
	if usable.is_empty():
		return 0
	if bool(item.get("low_slide", false)):
		if _is_reservoir_location():
			return usable[absi(int(float(item.get("distance", 0.0)))) % usable.size()]
		var hinted := _slide_path_index_for_hints(["rusty", "pipeline", "rust", "pipe", "spike", "尖刺", "广告牌", "billboard"])
		if hinted >= 0:
			return hinted
		return usable[0]
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return usable[(absi(lane * 19 + dist_key)) % usable.size()]


func _slide_usable_path_indices() -> Array[int]:
	var out: Array[int] = []
	for i in range(_slide_obstacle_paths.size()):
		if _is_color_block_obstacle_asset(_slide_obstacle_paths[i]):
			continue
		out.append(i)
	return out


func _slide_path_index_for_hints(hints: Array) -> int:
	for i in range(_slide_obstacle_paths.size()):
		var path := String(_slide_obstacle_paths[i])
		if _is_color_block_obstacle_asset(path):
			continue
		var lower := path.to_lower()
		for hint in hints:
			var h := String(hint).to_lower()
			if h != "" and h in lower:
				return i
	return -1


func _first_slide_asset_for_hints(hints: Array) -> String:
	var idx := _slide_path_index_for_hints(hints)
	if idx >= 0 and idx < _slide_obstacle_paths.size():
		return String(_slide_obstacle_paths[idx])
	return ""

func _orb_roll(item: Dictionary) -> Dictionary:
	var forced := String(item.get("orb_size", "")).strip_edges().to_lower()
	var tier := "small"
	if forced in ["colossal", "mega", "xl"]:
		tier = "colossal"
	elif forced in ["huge", "giant", "static_huge"]:
		tier = "huge"
	elif forced in ["large", "big"]:
		tier = "large"
	elif forced in ["medium", "mid"]:
		tier = "medium"
	elif forced in ["tiny", "mini"]:
		tier = "tiny"
	elif forced == "small":
		tier = "small"
	else:
		var dist_key := int(float(item.get("distance", 0.0)))
		var lane := int(item.get("lane", 0))
		var bucket := (int(dist_key / 7) + lane * 3 + 1) % 5
		match bucket:
			0:
				tier = "large"
			1:
				tier = "medium"
			2:
				tier = "tiny"
			_:
				tier = "small"
	var scale := ORB_SMALL_SCALE
	var span := ORB_SMALL_SPAN
	var drift_speed := ORB_SMALL_DRIFT_SPEED
	var float_speed := ORB_SMALL_FLOAT_SPEED
	var float_amp := ORB_SMALL_FLOAT_AMP
	match tier:
		"colossal":
			scale = ORB_COLOSSAL_SCALE
			span = ORB_COLOSSAL_SPAN
			drift_speed = 0.0
			float_speed = 0.28
			float_amp = 0.06
		"huge":
			scale = ORB_HUGE_SCALE
			span = ORB_HUGE_SPAN
			drift_speed = 0.0
			float_speed = 0.35
			float_amp = 0.08
		"large":
			scale = ORB_LARGE_SCALE
			span = ORB_LARGE_SPAN
			drift_speed = ORB_LARGE_DRIFT_SPEED
			float_speed = ORB_LARGE_FLOAT_SPEED
			float_amp = ORB_LARGE_FLOAT_AMP
		"medium":
			scale = lerpf(ORB_SMALL_SCALE, ORB_LARGE_SCALE, 0.45)
			span = lerpf(ORB_SMALL_SPAN, ORB_LARGE_SPAN, 0.45)
			drift_speed = lerpf(ORB_LARGE_DRIFT_SPEED, ORB_SMALL_DRIFT_SPEED, 0.55)
			float_speed = lerpf(ORB_LARGE_FLOAT_SPEED, ORB_SMALL_FLOAT_SPEED, 0.55)
			float_amp = lerpf(ORB_SMALL_FLOAT_AMP, ORB_LARGE_FLOAT_AMP, 0.55)
		"tiny":
			scale = ORB_SMALL_SCALE * 0.62
			span = ORB_SMALL_SPAN * 0.62
			drift_speed = ORB_SMALL_DRIFT_SPEED * 1.35
			float_speed = ORB_SMALL_FLOAT_SPEED * 1.45
			float_amp = ORB_SMALL_FLOAT_AMP * 1.6
	if _is_reservoir_location():
		match tier:
			"tiny":
				span *= 0.78
				scale *= 0.78
			"small":
				span *= 0.92
				scale *= 0.92
			"medium":
				span *= 1.08
				scale *= 1.08
			"huge":
				span *= 1.18
				scale *= 1.18
		var size_jitter := 0.86 + 0.32 * float(absi(int(float(item.get("distance", 0.0)) * 13.0)) % 10) / 9.0
		span *= size_jitter
		scale *= size_jitter
	# JSON 可覆盖漂移/浮动速度，制造大小不一、快慢不定
	if item.has("drift_speed"):
		drift_speed = float(item.get("drift_speed", drift_speed))
	if item.has("float_speed"):
		float_speed = float(item.get("float_speed", float_speed))
	if item.has("float_amp"):
		float_amp = float(item.get("float_amp", float_amp))
	var drift_span := ORB_DRIFT_SPAN
	if item.has("drift_span"):
		drift_span = float(item.get("drift_span", drift_span))
	elif drift_speed >= 7.5:
		drift_span = LANE_WIDTH * 2.05
	var orb_static := bool(item.get("static", false)) or absf(drift_speed) <= 0.001 or tier in ["huge", "colossal"]
	if orb_static:
		drift_speed = 0.0
	var tint := String(item.get("orb_tint", "")).strip_edges().to_lower()
	if tint == "":
		tint = "purple" if bool(item.get("purple", false)) else ""
	if _is_reservoir_location() and (tint == "" or tint == "purple"):
		tint = _reservoir_orb_tint_at(float(item.get("distance", 0.0)))
	return {
		"tier": tier,
		"scale": scale,
		"span": span,
		"drift_speed": drift_speed,
		"float_speed": float_speed,
		"float_amp": float_amp,
		"tint": tint,
		"static": orb_static,
		"drift_span": drift_span,
	}

func _orb_size_scale_for(item: Dictionary) -> float:
	return float(_orb_roll(item).get("scale", ORB_SMALL_SCALE))

func _build_train(root: Node3D, item: Dictionary, moving: bool) -> void:
	# 列车门：空心金门架 + 光波刀（门内不放滑铲/跳跃模型）
	var span := TRAIN_GATE_BLADE_SPAN
	var gate_h := TRAIN_GATE_TOP
	var visual := _add_train_gate_visual(root, span, gate_h)
	var asset_path := String(root.get_meta("train_gate_asset_path", ""))
	if moving and visual != null:
		visual.rotation_degrees.y += 6.0
		root.set_meta("train_spin", true)
	root.set_meta("obstacle_asset_path", asset_path if asset_path != "" else "train_wave_gate")
	root.set_meta("blade_top", gate_h)
	root.set_meta("has_wave_blade", true)
	_add_train_wave_blade(root, span)
	if _runner_layout_id() == "":
		var train_d := float(item.get("distance", 0.0))
		if train_d <= _last_hazard_end_distance():
			_ensure_train_gate_buff_visual(root)
	_add_ground_contact_shadow(root, span * 0.92, 1.05)

func _resolve_train_gate_scene() -> PackedScene:
	var scene := _load_runner_scene(TRAIN_GATE_SCENE_PATH, false)
	if scene != null:
		return scene
	return _get_slide_obstacle_scene_by_hint(["能量屏障", "energy", "barrier"], 0)

func _add_train_gate_frame_pillars(parent: Node3D, span: float, gate_h: float) -> void:
	var pillar_w := 0.36
	var pillar_d := 0.48
	var warm := Color(1.0, 0.78, 0.28)
	var gold_mat := _make_material(warm * 0.82, warm, 2.35)
	gold_mat.metallic = 0.42
	gold_mat.roughness = 0.38
	for sx in [-1.0, 1.0]:
		var pillar := MeshInstance3D.new()
		pillar.name = "TrainGatePillar"
		var box := BoxMesh.new()
		box.size = Vector3(pillar_w, gate_h, pillar_d)
		pillar.mesh = box
		pillar.material_override = gold_mat
		pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pillar.position = Vector3(sx * span * 0.47, gate_h * 0.5, 0.0)
		parent.add_child(pillar)
	var beam := MeshInstance3D.new()
	beam.name = "TrainGateBeam"
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(span * 0.98, 0.32, pillar_d * 1.08)
	beam.mesh = beam_mesh
	beam.material_override = gold_mat
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	beam.position = Vector3(0.0, gate_h - 0.1, 0.0)
	parent.add_child(beam)

func _add_train_gate_visual(parent: Node3D, span: float, gate_h: float) -> Node3D:
	# 空心光波门：仅门架 + 光波带，不在门内塞滑铲/跳跃模型
	var holder := Node3D.new()
	holder.name = "TrainRoadBlockAsset"
	parent.add_child(holder)
	parent.set_meta("train_gate_asset_path", "train_wave_gate")
	_add_train_gate_frame_pillars(holder, span, gate_h)
	_add_train_gate_wave_field(holder, span, gate_h)
	var display := Label3D.new()
	display.name = "TrainGateDisplay"
	display.text = "$ 000"
	display.font_size = 56
	display.modulate = Color(0.92, 0.98, 1.0, 0.92)
	display.outline_size = 8
	display.outline_modulate = Color(0.05, 0.12, 0.22, 0.95)
	display.position = Vector3(0.0, gate_h * 0.58, 0.18)
	holder.add_child(display)
	return holder

func _add_train_gate_wave_field(parent: Node3D, span: float, gate_h: float) -> void:
	if parent.get_node_or_null("TrainGateWaveField") != null:
		return
	var root := Node3D.new()
	root.name = "TrainGateWaveField"
	parent.add_child(root)
	var mat := _make_wave_energy_material(Color(1.0, 0.82, 0.32, 0.78), Color(1.0, 0.58, 0.14), 4.8, 0.78)
	for i in 5:
		var wave := MeshInstance3D.new()
		wave.name = "TrainGateWave_%d" % i
		var mesh := BoxMesh.new()
		mesh.size = Vector3(span * 0.86, 0.05 + float(i % 2) * 0.02, 0.12)
		wave.mesh = mesh
		wave.material_override = mat.duplicate()
		wave.position = Vector3(0.0, 0.62 + float(i) * 0.34, 0.14)
		wave.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(wave)
	var band := MeshInstance3D.new()
	band.name = "TrainGateWaveBand"
	var band_mesh := BoxMesh.new()
	band_mesh.size = Vector3(span * 0.9, 0.08, 0.18)
	band.mesh = band_mesh
	band.material_override = _make_wave_energy_material(Color(1.0, 0.72, 0.22, 0.55), Color(1.0, 0.45, 0.1), 3.6, 0.55)
	band.position = Vector3(0.0, 1.05, 0.12)
	band.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(band)

func _add_procedural_train_gate_panel(parent: Node3D, gate_h: float, span: float) -> void:
	var panel := MeshInstance3D.new()
	panel.name = "TrainGateFallbackPanel"
	var panel_mesh := BoxMesh.new()
	panel_mesh.size = Vector3(span * 0.72, gate_h * 0.42, 0.42)
	var panel_mat := _make_material(Color(0.1, 0.14, 0.18), Color(0.35, 0.82, 1.0), 1.55)
	panel_mat.metallic = 0.48
	panel_mat.roughness = 0.34
	panel.mesh = panel_mesh
	panel.material_override = panel_mat
	panel.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	panel.position = Vector3(0.0, gate_h * 0.58, 0.06)
	parent.add_child(panel)
	var display := Label3D.new()
	display.text = "$ 000"
	display.font_size = 72
	display.modulate = Color(0.92, 0.98, 1.0, 0.95)
	display.outline_size = 10
	display.outline_modulate = Color(0.05, 0.12, 0.22, 0.95)
	display.position = Vector3(0.0, gate_h * 0.58, 0.22)
	parent.add_child(display)

func _make_procedural_train_gate_visual(parent: Node3D, gate_h: float, span: float) -> Node3D:
	var model := Node3D.new()
	model.name = "TrainRoadBlockAsset"
	parent.add_child(model)
	_add_train_gate_frame_pillars(model, span, gate_h)
	_add_procedural_train_gate_panel(model, gate_h, span)
	return model

func _build_meteorite_gate(root: Node3D, item: Dictionary) -> void:
	# 陨石门：门架本身不挡路，接近时从上空随机车道掉落陨石
	root.set_meta("obstacle_asset_path", "meteorite_gate")
	var span := _runway_obstacle_span_at(float(item.get("distance", 0.0)))
	var pillar_h := 4.35
	var pillar_w := 0.38
	var pillar_d := 0.42
	var gate_mat := StandardMaterial3D.new()
	gate_mat.albedo_color = Color(0.22, 0.28, 0.38, 0.92)
	gate_mat.emission_enabled = true
	gate_mat.emission = Color(1.0, 0.42, 0.12)
	gate_mat.emission_energy_multiplier = 1.45
	gate_mat.metallic = 0.55
	gate_mat.roughness = 0.42
	for side_i in 2:
		var side := -1 if side_i == 0 else 1
		var pillar := MeshInstance3D.new()
		pillar.name = "MeteorGatePillar_%d" % side_i
		var box := BoxMesh.new()
		box.size = Vector3(pillar_w, pillar_h, pillar_d)
		pillar.mesh = box
		pillar.material_override = gate_mat
		pillar.position = Vector3(side * span * 0.46, pillar_h * 0.5, 0.0)
		pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(pillar)
		var lamp := MeshInstance3D.new()
		lamp.name = "MeteorGateLamp_%d" % side_i
		var lamp_mesh := SphereMesh.new()
		lamp_mesh.radius = 0.18
		lamp_mesh.height = 0.36
		lamp.mesh = lamp_mesh
		var lamp_mat := StandardMaterial3D.new()
		lamp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		lamp_mat.albedo_color = Color(1.0, 0.35, 0.08, 1.0)
		lamp_mat.emission_enabled = true
		lamp_mat.emission = Color(1.0, 0.28, 0.05)
		lamp_mat.emission_energy_multiplier = 4.2
		lamp.material_override = lamp_mat
		lamp.position = Vector3(side * span * 0.46, pillar_h + 0.12, 0.0)
		lamp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(lamp)
	var beam := MeshInstance3D.new()
	beam.name = "MeteorGateBeam"
	var beam_box := BoxMesh.new()
	beam_box.size = Vector3(span * 0.94, 0.26, 0.38)
	beam.mesh = beam_box
	var beam_mat := gate_mat.duplicate() as StandardMaterial3D
	beam_mat.emission = Color(1.0, 0.55, 0.18)
	beam_mat.emission_energy_multiplier = 2.1
	beam.material_override = beam_mat
	beam.position = Vector3(0.0, pillar_h + 0.02, 0.0)
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(beam)
	var hazard := MeshInstance3D.new()
	hazard.name = "MeteorGateHazardZone"
	var hazard_box := BoxMesh.new()
	hazard_box.size = Vector3(span * 0.88, 0.04, LANE_WIDTH * 2.4)
	var hazard_mat := StandardMaterial3D.new()
	hazard_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hazard_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hazard_mat.albedo_color = Color(1.0, 0.42, 0.12, 0.22)
	hazard_mat.emission_enabled = true
	hazard_mat.emission = Color(1.0, 0.35, 0.08)
	hazard_mat.emission_energy_multiplier = 1.2
	hazard.mesh = hazard_box
	hazard.material_override = hazard_mat
	hazard.position = Vector3(0.0, 0.03, 0.0)
	hazard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(hazard)

func _add_train_gate_pass_hint(_root: Node3D) -> void:
	# 全据点：障碍物不显示动作字标（仅加速垫/弹射垫保留字标）
	return

func _ensure_train_gate_buff_visual(root: Node3D) -> Node3D:
	var existing := root.get_node_or_null("GateShieldCrystal") as Node3D
	if existing != null:
		return existing
	# 清理旧版加速靴节点
	var legacy := root.get_node_or_null("GateSpeedBoost") as Node3D
	if legacy != null:
		legacy.queue_free()
	var crystal := _make_shield_crystal(0, 0.0, 0.0, 0, 0, true)
	crystal.name = "GateShieldCrystal"
	root.add_child(crystal)
	crystal.position = Vector3(0.0, 1.05, 0.38)
	crystal.scale = Vector3(1.45, 1.45, 1.45)
	crystal.rotation = Vector3.ZERO
	return crystal

func _build_lane_block(root: Node3D, side: String) -> void:
	# 左封：左道+中道；右封：中道+右道（须换到外侧车道；不是滑铲门/分叉）
	var blocked_x := [-LANE_WIDTH, 0.0] if side == "left" else [0.0, LANE_WIDTH]
	for i in blocked_x.size():
		_add_lane_dodge_barrier(root, blocked_x[i], i, side)
	# 仅地面淡标，不用绿色「换道」浮字（直线封道易与分叉混淆）
	var safe_x := LANE_WIDTH if side == "left" else -LANE_WIDTH
	var pad := MeshInstance3D.new()
	pad.name = "LaneDodgeSafePad"
	var pad_mesh := BoxMesh.new()
	pad_mesh.size = Vector3(LANE_WIDTH * 0.62, 0.04, 1.35)
	var pad_mat := StandardMaterial3D.new()
	pad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pad_mat.albedo_color = Color(0.95, 0.78, 0.28, 0.28)
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(1.0, 0.72, 0.22)
	pad_mat.emission_energy_multiplier = 0.85
	pad.mesh = pad_mesh
	pad.material_override = pad_mat
	pad.position = Vector3(safe_x, 0.03, 0.0)
	pad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(pad)

func _add_lane_dodge_barrier(parent: Node3D, lateral_x: float, index: int, side: String = "left") -> void:
	# 封道柱：用医疗箱 / 残破无人机等模型占位，不再用橙色方块
	var holder := Node3D.new()
	holder.name = "LaneDodgeBarrier_%d" % index
	var nudge := -0.35 if side == "left" else 0.35
	holder.position = Vector3(lateral_x + nudge, 0.0, -0.22 if index == 0 else 0.22)
	parent.add_child(holder)
	var paths := _lane_block_prop_paths()
	var path := paths[(absi(int(lateral_x * 7)) + index) % paths.size()]
	var scene := _load_runner_scene(path, false)
	if scene != null:
		var yaw := 22.0 if side == "left" else -22.0
		if "drone" in path.to_lower() or "robot" in path.to_lower():
			yaw += 78.0
		var visual := _add_scaled_model_visual(
			holder,
			scene,
			"LaneBlockProp_%d" % index,
			2.05,
			yaw,
			Vector3.ZERO,
			LANE_WIDTH * 1.55
		)
		_preserve_midground_materials(visual)
		_add_ground_contact_shadow(holder, LANE_WIDTH * 0.9, 1.0)
		return
	var block_h := 2.05
	var block_w := LANE_WIDTH * 0.48
	var block_d := 0.95
	var body := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(block_w, block_h, block_d)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.92, 0.42, 0.1, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.38, 0.06)
	mat.emission_energy_multiplier = 1.85
	mat.metallic = 0.22
	mat.roughness = 0.38
	body.mesh = box
	body.material_override = mat
	body.position = Vector3(0.0, block_h * 0.5, 0.0)
	holder.add_child(body)
	var rim := MeshInstance3D.new()
	var rim_box := BoxMesh.new()
	rim_box.size = Vector3(block_w * 1.08, 0.14, block_d * 1.06)
	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 0.92, 0.35, 1.0)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.85, 0.2)
	rim_mat.emission_energy_multiplier = 2.4
	rim.mesh = rim_box
	rim.material_override = rim_mat
	rim.position = Vector3(0.0, block_h + 0.02, 0.0)
	holder.add_child(rim)

func _add_height_scaled_model_visual(
	parent: Node3D,
	scene: PackedScene,
	model_name: String,
	target_height: float,
	yaw_degrees: float = 0.0,
	local_position: Vector3 = Vector3.ZERO,
	max_width: float = -1.0,
	max_depth: float = -1.0
) -> Node3D:
	# 按高度轴缩放（宽门洞不会被 max(x,y,z) 压成贴地迷你架）
	if not scene:
		return _add_missing_model_visual(parent, model_name, target_height, yaw_degrees, local_position)
	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees
	var bounds := _compute_node_aabb(model)
	if bounds.size.y <= 0.001:
		push_warning("%s height invalid, fallback." % model_name)
		model.scale = Vector3.ONE * (target_height / 2.0)
	else:
		var sy := target_height / bounds.size.y
		model.scale = Vector3.ONE * sy
	bounds = _compute_node_aabb(model)
	if max_width > 0.0 and bounds.size.x > max_width and bounds.size.x > 0.001:
		model.scale.x *= max_width / bounds.size.x
		bounds = _compute_node_aabb(model)
	if max_depth > 0.0 and bounds.size.z > max_depth and bounds.size.z > 0.001:
		model.scale.z *= max_depth / bounds.size.z
		bounds = _compute_node_aabb(model)
	# 高度可能被二次缩放影响，再校正一次 Y
	if bounds.size.y > 0.001 and absf(bounds.size.y - target_height) > 0.08:
		model.scale.y *= target_height / bounds.size.y
		bounds = _compute_node_aabb(model)
	model.position += Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5),
	)
	return model

func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root
	for child in root.find_children("*", "AnimationPlayer", true, false):
		return child as AnimationPlayer
	return null

func _configure_player_animations() -> void:
	if not player_animation_player:
		push_warning("Runner skeletal model has no AnimationPlayer.")
		return
	var run_anim := _player_run_anim_name()
	if player_animation_player.has_animation(run_anim):
		player_animation_player.get_animation(run_anim).loop_mode = Animation.LOOP_LINEAR
		_sanitize_run_animation_root_motion(player_animation_player.get_animation(run_anim))
	for anim_name in [ANIMATED_PLAYER_IDLE_ANIM, ANIMATED_PLAYER_RUN_ANIM]:
		if anim_name == run_anim:
			continue
		if player_animation_player.has_animation(anim_name):
			player_animation_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	if player_animation_player.has_animation(ANIMATED_PLAYER_CELEBRATE_ANIM):
		player_animation_player.get_animation(ANIMATED_PLAYER_CELEBRATE_ANIM).loop_mode = Animation.LOOP_NONE

func _sanitize_run_animation_root_motion(anim: Animation) -> void:
	# Mixamo 跑步常带 Hips 位移，和路径推进叠加会产生「每步后退」视觉卡顿
	for i in range(anim.get_track_count()):
		if anim.track_get_type(i) != Animation.TYPE_POSITION_3D:
			continue
		var path := String(anim.track_get_path(i))
		var lower := path.to_lower()
		if "hips" in lower or ":root" in lower or path.ends_with("Root.position"):
			anim.track_set_enabled(i, false)

func _play_player_animation(state_name: String, force_restart: bool = false) -> void:
	if not player_animation_player:
		return
	var anim_name := _player_run_anim_name()
	match state_name:
		"run", "slide", "jump", "landing":
			anim_name = _player_run_anim_name()
		"celebrate":
			anim_name = ANIMATED_PLAYER_CELEBRATE_ANIM if player_animation_player.has_animation(ANIMATED_PLAYER_CELEBRATE_ANIM) else _player_run_anim_name()
		"idle":
			anim_name = _player_run_anim_name()
	if state_name == "idle":
		player_animation_player.speed_scale = 0.0
	elif state_name == "slide":
		player_animation_player.speed_scale = 0.58
	elif state_name == "run":
		player_animation_player.speed_scale = _run_anim_speed_for_feel()
	if not force_restart and player_animation_name == anim_name and state_name != "idle" and state_name != "run":
		return
	if not player_animation_player.has_animation(anim_name):
		push_warning("Missing player animation: %s" % anim_name)
		return
	player_animation_name = anim_name
	if force_restart or not player_animation_player.is_playing() or player_animation_player.current_animation != anim_name:
		var blend := 0.22 if state_name == "run" else 0.14
		player_animation_player.play(anim_name, blend)

func _add_player_pose_model(
	pose_name: String,
	scene: PackedScene,
	target_height: float = PLAYER_MODEL_HEIGHT,
	yaw_degrees: float = PLAYER_MODEL_YAW
) -> void:
	if not scene:
		return
	var model := _add_scaled_model_visual(player_body, scene, "RunnerModel_%s" % pose_name, target_height, yaw_degrees)
	model.visible = false
	player_pose_models[pose_name] = model

func _set_player_pose(pose_name: String) -> void:
	if pose_name == "jump":
		pose_name = "jump_start"
	if _uses_skeletal_run():
		_apply_skeletal_player_pose(pose_name)
		return
	if player_animation_player:
		if player_pose_root:
			player_pose_root.visible = pose_name != "slide"
		if player_slide_pose_root:
			player_slide_pose_root.visible = pose_name == "slide"
		match pose_name:
			"slide":
				_play_player_animation("idle")
			"jump_start", "jump_peak":
				_play_player_animation("jump")
			"landing":
				_play_player_animation("landing")
			"run_left", "run_right":
				_play_player_animation("run")
			_:
				_play_player_animation("idle")
		return
	if player_pose_name == pose_name and pose_name not in ["jump_start", "jump_peak", "landing"]:
		return
	player_pose_name = pose_name

	for model in player_pose_models.values():
		(model as Node3D).visible = false
	var pose_key := pose_name
	if pose_key == "landing" and not player_pose_models.has("landing"):
		pose_key = "jump_start"
	player_pose_root = player_pose_models.get(pose_key, player_pose_models.get("idle")) as Node3D
	if player_pose_root:
		player_pose_root.visible = true

func _set_player_intro_facing(intro_active: bool) -> void:
	if player_body == null:
		return
	# Mixamo 骨骼跑：开场与正式跑同向（仅 animated_model_yaw），不再叠 intro_body_yaw
	if _player_asset_path("animated_model", "") != "":
		player_body.rotation_degrees.y = 0.0
		return
	# 静态姿势 GLB：开场 idle 需额外转 body 展示正面
	if intro_active:
		player_body.rotation_degrees.y = _player_yaw_degrees("intro_body_yaw", PLAYER_INTRO_BODY_YAW)
	else:
		player_body.rotation_degrees.y = 0.0

func _add_scaled_model_visual(
	parent: Node3D,
	scene: PackedScene,
	model_name: String,
	target_height: float,
	yaw_degrees: float = 0.0,
	local_position: Vector3 = Vector3.ZERO,
	max_footprint: float = -1.0,
	max_scale_cap: float = 12.0,
	scale_by_height: bool = false
) -> Node3D:
	if not scene:
		return _add_missing_model_visual(parent, model_name, target_height, yaw_degrees, local_position)

	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees

	var bounds := _compute_node_aabb(model)
	var characteristic := bounds.size.y if scale_by_height else maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if characteristic <= 0.001:
		push_warning("%s bounds invalid, using fallback scale." % model_name)
		model.scale = Vector3.ONE * (target_height / 2.0)
	else:
		var scale_factor := target_height / characteristic
		# Mixamo 绑骨后 mesh AABB 常只有几厘米，需要放大；普通道具仍限制上限
		if max_scale_cap > 0.0:
			scale_factor = minf(scale_factor, max_scale_cap)
		model.scale = Vector3.ONE * scale_factor

	bounds = _compute_node_aabb(model)
	if max_footprint > 0.0:
		var footprint := maxf(bounds.size.x, bounds.size.z)
		if footprint > max_footprint and footprint > 0.001:
			model.scale *= max_footprint / footprint
			bounds = _compute_node_aabb(model)

	model.position += Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5),
	)
	return model

func _add_missing_model_visual(
	parent: Node3D,
	model_name: String,
	target_height: float,
	yaw_degrees: float,
	local_position: Vector3
) -> Node3D:
	# 禁止占位色块。跳跃改木栅栏，其它类型不生成假模型。
	if model_name == "JumpObstacleModel":
		_add_wooden_fence_jump_visual(parent, _runway_obstacle_span_at(0.0), maxf(target_height, JUMP_BAR_HEIGHT))
		parent.set_meta("obstacle_asset_path", "wood_fence_jump")
		return parent.get_node_or_null("JumpObstacleModel") as Node3D
	return null

func _tint_model(model: Node3D, material: Material) -> void:
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		mesh_instance.material_override = material

func _make_crystal_material(color: Color, glow: Color) -> StandardMaterial3D:
	var material := _make_material(color, glow, 3.4)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _compute_node_aabb(root: Node3D) -> AABB:
	var merged := AABB()
	var first := true
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if not mesh_instance.mesh:
			continue
		var local_box := mesh_instance.mesh.get_aabb()
		for corner in _aabb_corners(local_box):
			var world_point: Vector3 = mesh_instance.global_transform * corner
			var local_point: Vector3 = root.global_transform.affine_inverse() * world_point
			if first:
				merged = AABB(local_point, Vector3.ZERO)
				first = false
			else:
				merged = merged.expand(local_point)
	return merged

func _aabb_corners(box: AABB) -> Array:
	return [
		box.position,
		box.position + Vector3(box.size.x, 0.0, 0.0),
		box.position + Vector3(0.0, box.size.y, 0.0),
		box.position + Vector3(0.0, 0.0, box.size.z),
		box.position + Vector3(box.size.x, box.size.y, 0.0),
		box.position + Vector3(box.size.x, 0.0, box.size.z),
		box.position + Vector3(0.0, box.size.y, box.size.z),
		box.position + box.size,
	]

func _build_chaser() -> void:
	if _pressure_chaser_enabled:
		_build_energy_pressure_chaser()
		return
	chaser = Node3D.new()
	chaser.name = "NullTideChaser"
	add_child(chaser)

	_chaser_cloak_root = Node3D.new()
	_chaser_cloak_root.name = "CloakRoot"
	chaser.add_child(_chaser_cloak_root)
	_chaser_cloak_layers.clear()

	var cloak_mat := _make_chaser_cloak_material()
	var layer_specs := [
		{"size": Vector3(3.0, 0.62, 1.55), "y": 0.28, "rx": -6.0, "z": 0.0},
		{"size": Vector3(2.55, 0.58, 1.28), "y": 0.82, "rx": 2.0, "z": 0.06},
		{"size": Vector3(2.05, 0.52, 1.02), "y": 1.28, "rx": 8.0, "z": 0.12},
		{"size": Vector3(1.55, 0.48, 0.78), "y": 1.68, "rx": 14.0, "z": 0.16},
	]
	for spec in layer_specs:
		var layer := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = spec["size"]
		mesh.material = cloak_mat
		layer.mesh = mesh
		layer.position = Vector3(0.0, float(spec["y"]), float(spec["z"]))
		layer.rotation_degrees.x = float(spec["rx"])
		layer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_chaser_cloak_root.add_child(layer)
		_chaser_cloak_layers.append(layer)

	var hood := MeshInstance3D.new()
	var hood_mesh := BoxMesh.new()
	hood_mesh.size = Vector3(1.08, 1.02, 1.02)
	hood_mesh.material = cloak_mat
	hood.mesh = hood_mesh
	hood.position = Vector3(0.0, 2.05, 0.12)
	hood.rotation_degrees.x = -16.0
	hood.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_chaser_cloak_root.add_child(hood)
	chaser_body = hood

	_chaser_void_face = MeshInstance3D.new()
	var void_mesh := SphereMesh.new()
	void_mesh.radius = 0.34
	void_mesh.height = 0.68
	void_mesh.radial_segments = 12
	void_mesh.rings = 8
	void_mesh.material = _make_chaser_void_material()
	_chaser_void_face.mesh = void_mesh
	_chaser_void_face.position = Vector3(0.0, 1.92, 0.48)
	_chaser_void_face.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_chaser_cloak_root.add_child(_chaser_void_face)

	for side in [-1.0, 1.0]:
		var arm := MeshInstance3D.new()
		var arm_mesh := BoxMesh.new()
		arm_mesh.size = Vector3(0.12, 1.42, 0.12)
		arm_mesh.material = cloak_mat
		arm.mesh = arm_mesh
		arm.position = Vector3(side * 0.78, 1.18, 0.62)
		arm.rotation_degrees = Vector3(34.0, side * 16.0, side * -24.0)
		arm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_chaser_cloak_root.add_child(arm)

	var wisp := MeshInstance3D.new()
	var wisp_mesh := BoxMesh.new()
	wisp_mesh.size = Vector3(2.6, 0.06, 2.6)
	wisp_mesh.material = _make_material(Color(0.18, 0.04, 0.28, 0.42), Color(0.62, 0.12, 0.92), 2.4)
	wisp.mesh = wisp_mesh
	wisp.position = Vector3(0.0, 0.08, 0.0)
	wisp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_chaser_cloak_root.add_child(wisp)

	_chaser_trail = _make_chaser_trail_particles()
	_chaser_trail.position = Vector3(0.0, 0.35, -0.25)
	chaser.add_child(_chaser_trail)

	chaser.scale = Vector3(CHASER_VISUAL_SCALE, CHASER_VISUAL_SCALE, CHASER_VISUAL_SCALE)
	chaser.visible = false


func _build_energy_pressure_chaser() -> void:
	_energy_chaser = EnergyChaserController.new()
	_energy_chaser.name = "EnergyChaser"
	_energy_chaser.initial_pressure = float(mission.get("chaser_initial_pressure", 18.0))
	_energy_chaser.max_gap = 28.0
	_energy_chaser.min_gap = 1.6
	_energy_chaser.visual_height = 0.55
	_energy_chaser.follow_smoothing = 5.5
	_energy_chaser.hover_amplitude = 0.08
	_energy_chaser.tail_drag_deg = 8.0
	add_child(_energy_chaser)
	chaser = _energy_chaser
	chaser_body = null
	_chaser_cloak_root = null
	_chaser_cloak_layers.clear()
	_chaser_void_face = null
	_chaser_trail = null
	if not _energy_chaser.player_captured.is_connected(_on_energy_chaser_captured):
		_energy_chaser.player_captured.connect(_on_energy_chaser_captured)
	_ensure_chase_overlay()
	_energy_chaser.screen_shader = _chase_overlay_mat
	chaser.visible = false


func _ensure_chase_overlay() -> void:
	if _chase_overlay != null and is_instance_valid(_chase_overlay):
		return
	var shader := load("res://assets/maps/route_levels/runner_60s/shaders/energy_chase_overlay.gdshader") as Shader
	_chase_overlay_mat = ShaderMaterial.new()
	if shader != null:
		_chase_overlay_mat.shader = shader
	_chase_overlay_mat.set_shader_parameter("chase_strength", 0.0)
	_chase_overlay_mat.set_shader_parameter("chase_state", 0.0)
	_chase_overlay = ColorRect.new()
	_chase_overlay.name = "EnergyChaseOverlay"
	_chase_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_chase_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chase_overlay.material = _chase_overlay_mat
	_chase_overlay.color = Color(1, 1, 1, 1)
	_chase_overlay.visible = false
	_chase_overlay.z_index = 40
	if hud_root != null:
		hud_root.add_child(_chase_overlay)
	else:
		add_child(_chase_overlay)


func _on_energy_chaser_captured() -> void:
	if is_failed or is_finished or _capture_cinematic_active:
		return
	_fail_run("%s 吞没了你" % LevelConfig.CHASER_NAME)


func _is_chaser_capture_reason(reason: String) -> bool:
	var t := reason.strip_edges()
	if not _chaser_enabled:
		return false
	return t.contains("追上") or t.contains("吞没") or t.contains("零潮") or t.contains("异能") or t.contains("Nulltide")


func _begin_capture_cinematic(reason: String) -> void:
	if _capture_cinematic_active or is_finished:
		return
	is_failed = true
	gameplay_active = false
	_capture_cinematic_active = true
	_capture_cinematic_t = 0.0
	_capture_fail_reason = reason
	_capture_settlement_ready = false
	_close_settlement_pause()
	get_tree().paused = false
	_clear_sky_cheer_danmaku()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if intro_panel:
		intro_panel.visible = false
	if chaser_hint_wrap:
		chaser_hint_wrap.visible = false
	_ensure_capture_swallow()
	if _capture_swallow != null:
		_capture_swallow.visible = true
		if _capture_swallow_mat != null:
			_capture_swallow_mat.set_shader_parameter("swallow", 0.0)
	if _energy_chaser != null:
		_energy_chaser.is_active = true
		_energy_chaser.pressure = _energy_chaser.max_pressure
		_energy_chaser.state = EnergyChaserController.ChaseState.CAPTURED
		_energy_chaser.visible = true
	if player_body:
		_play_player_animation("idle")
	camera_shake = maxf(camera_shake, 0.55)


func _ensure_capture_swallow() -> void:
	if _capture_swallow != null and is_instance_valid(_capture_swallow):
		return
	var shader := load("res://assets/maps/route_levels/runner_60s/shaders/energy_capture_swallow.gdshader") as Shader
	_capture_swallow_mat = ShaderMaterial.new()
	if shader != null:
		_capture_swallow_mat.shader = shader
	_capture_swallow_mat.set_shader_parameter("swallow", 0.0)
	_capture_swallow = ColorRect.new()
	_capture_swallow.name = "EnergyCaptureSwallow"
	_capture_swallow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_capture_swallow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capture_swallow.material = _capture_swallow_mat
	_capture_swallow.color = Color(1, 1, 1, 1)
	_capture_swallow.visible = false
	_capture_swallow.z_index = 90
	if hud_root != null:
		hud_root.add_child(_capture_swallow)
	else:
		add_child(_capture_swallow)


func _update_capture_cinematic(delta: float) -> void:
	_capture_cinematic_t += delta
	var u := clampf(_capture_cinematic_t / CAPTURE_CINEMATIC_TIME, 0.0, 1.0)
	var ease_u := 1.0 - pow(1.0 - u, 2.2)
	if _capture_swallow_mat != null:
		_capture_swallow_mat.set_shader_parameter("swallow", ease_u)
	if _chase_overlay_mat != null:
		_chase_overlay_mat.set_shader_parameter("chase_strength", lerpf(0.7, 1.0, ease_u))
	if _chase_overlay != null:
		_chase_overlay.visible = true
	# Runner 倒下 / 消散
	if player_body != null and is_instance_valid(player_body):
		player_body.rotation_degrees.x = lerpf(player_body.rotation_degrees.x, 78.0, 1.0 - exp(-3.2 * delta))
		player_body.scale = Vector3.ONE * lerpf(1.0, 0.42, ease_u)
		_set_runner_capture_fade(lerpf(1.0, 0.08, ease_u))
	if player != null and is_instance_valid(player):
		var ground_y := _ground_y_at(track_distance)
		player.position.y = lerpf(player.position.y, ground_y - 0.35 * ease_u, 0.2)
	if chaser != null and is_instance_valid(chaser):
		chaser.scale = Vector3.ONE * lerpf(1.2, 2.6, ease_u)
	_sync_chaser_from_track()
	camera_shake = maxf(camera_shake, 0.2 + ease_u * 0.35)
	_update_camera()
	if u >= 1.0:
		_capture_cinematic_active = false
		_capture_settlement_ready = true
		if player_body != null and is_instance_valid(player_body):
			player_body.scale = Vector3.ONE
			player_body.rotation_degrees.x = 0.0
			_set_runner_capture_fade(1.0)
		var reason := _capture_fail_reason if _capture_fail_reason != "" else ("%s 吞没了你" % LevelConfig.CHASER_NAME)
		_fail_run(reason)


func _set_runner_capture_fade(alpha: float) -> void:
	if player_body == null or not is_instance_valid(player_body):
		return
	var a := clampf(alpha, 0.0, 1.0)
	for node in player_body.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		if gi == null:
			continue
		gi.transparency = 1.0 - a


func _make_chaser_cloak_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.04, 0.02, 0.06, 0.92)
	mat.emission_enabled = true
	mat.emission = Color(0.22, 0.05, 0.38)
	mat.emission_energy_multiplier = 1.35
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.disable_fog = true
	return mat


func _make_chaser_void_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.01, 0.0, 0.02, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.48, 0.1, 0.72)
	mat.emission_energy_multiplier = 1.6
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.disable_fog = true
	return mat


func _make_chaser_trail_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "NullTideTrail"
	particles.amount = 24
	particles.lifetime = 0.85
	particles.preprocess = 0.2
	particles.emitting = false
	particles.local_coords = true
	particles.fixed_fps = 30
	var mesh := SphereMesh.new()
	mesh.radius = 0.08
	mesh.height = 0.16
	mesh.radial_segments = 6
	mesh.rings = 3
	mesh.material = _make_material(Color(0.12, 0.03, 0.2, 0.55), Color(0.55, 0.15, 0.88), 2.8)
	particles.draw_pass_1 = mesh
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.0, 0.35, 1.0)
	mat.spread = 28.0
	mat.initial_velocity_min = 0.35
	mat.initial_velocity_max = 1.6
	mat.gravity = Vector3(0.0, 0.15, 0.0)
	mat.scale_min = 0.35
	mat.scale_max = 1.15
	mat.color = Color(0.35, 0.08, 0.55, 0.65)
	particles.process_material = mat
	return particles


func _update_chaser_visuals(delta: float) -> void:
	if not chaser or not chaser.visible:
		return
	if _pressure_chaser_enabled:
		return
	chaser_pulse = maxf(chaser_pulse - delta * 1.8, 0.0)
	var danger := 1.0 - clampf(chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var bob := sin(elapsed * 5.5 + intro_elapsed * 3.0) * (0.06 + danger * 0.05)
	var sway := sin(elapsed * 3.2) * 0.04
	if _chaser_cloak_root:
		_chaser_cloak_root.position.y = bob + chaser_pulse * 0.22
		_chaser_cloak_root.rotation.z = sway
	if chaser_body:
		chaser_body.rotation_degrees.x = -16.0 - danger * 6.0 - chaser_pulse * 4.0
	for i in _chaser_cloak_layers.size():
		var layer := _chaser_cloak_layers[i]
		if layer == null:
			continue
		var flutter := sin(elapsed * 7.0 + float(i) * 0.9) * (0.04 + danger * 0.06)
		layer.rotation_degrees.z = flutter * (1.0 if i % 2 == 0 else -1.0)
	if _chaser_void_face:
		var void_mat := _chaser_void_face.get_active_material(0) as StandardMaterial3D
		if void_mat:
			void_mat.emission_energy_multiplier = lerpf(1.4, 3.6, danger + chaser_pulse * 0.45)
			void_mat.emission = Color(0.42, 0.08, 0.68).lerp(Color(0.72, 0.18, 0.95), danger)
	if _chaser_trail:
		_chaser_trail.speed_scale = lerpf(0.75, 1.35, danger)

func _w1_beat_distance(beat: float) -> float:
	# 128BPM + 线性加速；扣除倒计时期间 BGM 已播放的 3s，与 never_stop_running 对齐
	var bpm := _content_bgm_bpm()
	var offset := 0.06
	if Global.has_method("get_bgm_beat_offset_sec") and bpm >= 126.0:
		offset = Global.get_bgm_beat_offset_sec()
		if offset <= 0.0:
			offset = 0.06
	var t := beat * (60.0 / bpm) + offset - RUNNER_BGM_COUNTDOWN_LEAD
	if t <= 0.001:
		return 0.0
	var run_t := maxf(_run_time, 1.0)
	var v0 := _base_run_speed()
	var v1 := _max_run_speed()
	return v0 * t + 0.5 * (v1 - v0) * t * t / run_t


func _content_bgm_bpm() -> float:
	if String(Global.runner_location_id) == "dome":
		return 118.0
	return 128.0


func _distance_to_w1_beat(dist: float) -> int:
	var best_b := 8
	var best_err := 99999.0
	for b in range(6, 180):
		var err := absf(_w1_beat_distance(float(b)) - dist)
		if err < best_err:
			best_err = err
			best_b = b
	return best_b


func _w1_obstacle_beats_for_coins(gap: float) -> Array[int]:
	var beats: Array[int] = []
	for obstacle in obstacles:
		if int(obstacle.get("layer", 0)) != 0:
			continue
		var otype := String(obstacle.get("type", ""))
		if otype in ["ramp", "turn_left", "turn_right"]:
			continue
		var beat := _distance_to_w1_beat(float(obstacle.get("distance", 0.0)))
		var dup := false
		for existing in beats:
			if absf(float(existing) - float(beat)) < gap * 0.5:
				dup = true
				break
		if not dup:
			beats.append(beat)
	beats.sort()
	return beats


func _w1_is_finish_straight(dist: float) -> bool:
	return dist >= _finish_straight_zone_start()


func _should_skip_mechanic_collectible(distance: float, lane: int) -> bool:
	var zone := _width_zone_at(distance)
	if not zone.is_empty():
		return absf(float(lane) * LANE_WIDTH) > float(zone.get("half_width", 1.2)) - 0.08
	return _is_in_main_block_pit(distance)

func _w1_teaching_coins() -> Array:
	# 参考视频：每拍+半拍密币（卡 128BPM），跑道左/中/右交错
	var coins: Array = []
	var obstacle_beats := _w1_obstacle_beats_for_coins(0.22)
	var lane_pat: Array[int] = [0, -1, 1, 0, 1, -1]
	for b in range(4, 108):
		if _w1_beat_blocked_for_coins(b, obstacle_beats, 0.22):
			continue
		var d := _w1_beat_distance(float(b))
		if d <= 0.01 or _is_in_fork_main_gap(d) or _should_skip_mechanic_collectible(d, lane_pat[b % lane_pat.size()]):
			continue
		var finish_zone := _w1_is_finish_straight(d)
		var lane := lane_pat[b % lane_pat.size()]
		if finish_zone:
			if b % 2 != 0:
				var half_only := _w1_beat_distance(float(b) + 0.5)
				if half_only > 0.01 and not _is_in_fork_main_gap(half_only):
					coins.append(_w1_coin_item(half_only, lane_pat[(b + 1) % lane_pat.size()], false))
				continue
			lane = lane_pat[(b / 2) % lane_pat.size()]
		coins.append(_w1_coin_item(d, lane, false))
		var half_d := _w1_beat_distance(float(b) + 0.5)
		if half_d > 0.01 and not _is_in_fork_main_gap(half_d):
			coins.append(_w1_coin_item(half_d, lane, b % 3 == 0, 1 if b % 3 == 0 else 0))
		if not finish_zone and b % 8 == 0:
			_w1_append_diagonal_ribbon(coins, float(b), (int(b) / 8) % 2 != 0)
	return coins


func _snap_w1_layout_items_to_beats(items: Array) -> void:
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var otype := String(item.get("type", ""))
		if otype in ["ramp", "turn_left", "turn_right", "main_block"]:
			continue
		var dist := float(item.get("distance", 0.0))
		if dist <= 1.0:
			continue
		var beat := _distance_to_w1_beat(dist)
		if otype in ["jump", "slide", "high_bar"]:
			beat = maxi(int(round(float(beat) / 2.0) * 2), 8)
		item["distance"] = _w1_beat_distance(float(beat))


func _w1_beat_blocked_for_coins(beat: int, obstacle_beats: Array[int], gap: float) -> bool:
	for ob in obstacle_beats:
		if absf(float(beat) - float(ob)) < gap:
			return true
	return false


func _w1_coin_item(dist: float, lane: int, air: bool, air_tier: int = -1) -> Dictionary:
	var tier := air_tier
	if tier < 0:
		tier = 1 if air else 0
	return {
		"distance": dist,
		"lane": lane,
		"layer": 0,
		"air": tier > 0,
		"air_tier": tier,
		"pattern": "w1",
	}


func _w1_append_diagonal_ribbon(coins: Array, start_b: float, to_right: bool) -> void:
	var end_lane := 1 if to_right else -1
	var steps: Array = [
		{"off": 0.0, "lane": 0, "tier": 0},
		{"off": 0.25, "lane": 0, "tier": 1},
		{"off": 0.5, "lane": end_lane, "tier": 0},
		{"off": 0.75, "lane": end_lane, "tier": 1},
		{"off": 1.0, "lane": end_lane, "tier": 2},
	]
	for step in steps:
		var d := _w1_beat_distance(start_b + float(step["off"]))
		if _is_in_fork_main_gap(d):
			continue
		var tier := int(step["tier"])
		coins.append(_w1_coin_item(d, int(step["lane"]), tier > 0, tier))


func _build_content() -> void:
	var raw_obstacles: Array
	if CustomLevels.has_level(Global.runner_location_id):
		raw_obstacles = CustomLevels.load_obstacles_for_run(Global.runner_location_id, LevelConfig)
	elif _runner_layout_id() != "":
		raw_obstacles = ObstacleLayout.load_items(_runner_layout_id())
	else:
		raw_obstacles = LevelConfig.build_obstacles()
	var obstacle_items: Array
	if _runner_layout_id() != "" or CustomLevels.has_level(Global.runner_location_id):
		obstacle_items = []
		for raw in raw_obstacles:
			if typeof(raw) == TYPE_DICTIONARY:
				obstacle_items.append((raw as Dictionary).duplicate(true))
	else:
		obstacle_items = MissionTypes.adapt_obstacles(
			raw_obstacles,
			_mission_profile,
			_track_length
		)
	# 先吸附拍点，再滤侧墙/熔岩排除带，避免吸附后障碍又叠进坑或走廊
	if _uses_beat_sync_content():
		_snap_w1_layout_items_to_beats(obstacle_items)
	# adapt / 拍点后可能把下滑门等漂进侧墙走廊，再滤一次
	obstacle_items = _filter_adapted_obstacles_from_wall_corridors(obstacle_items)
	obstacle_items = _filter_obstacles_near_lava_platform_pits(obstacle_items)
	obstacle_items = _filter_obstacles_near_lava_crossings(obstacle_items)
	obstacle_items = _filter_orphan_platform_ramps(obstacle_items)
	# 关卡 JSON / 自定义关：保留编辑器摆放的全类型障碍；仅 procedural 回落才裁成跳铲球
	if _runner_layout_id() == "" and not CustomLevels.has_level(Global.runner_location_id):
		obstacle_items = _filter_core_obstacle_types(obstacle_items)
	for item in obstacle_items:
		_register_obstacle(item)
	_inject_sparse_runway_obstacles()
	_inject_gate_tension_obstacles()
	_inject_finish_sprint_orb_gauntlet()
	_inject_side_runway_wave_arc_obstacles()
	_inject_side_runway_speed_boosts()
	_purge_side_wall_collision_obstacles()
	_inject_junction_fork_branch_obstacles()
	_inject_y_fork_branch_obstacles()
	_purge_obstacles_in_lava_platform_zones()
	_refresh_smash_budget()
	obstacles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)
	_obstacle_scan_index = 0
	_refresh_lava_platforms()

	var coin_index := 0
	var main_coins: Array = []
	if _uses_beat_sync_content():
		main_coins = _w1_teaching_coins()
	elif LevelConfig.has_method("build_main_runway_coins"):
		main_coins = MissionTypes.adapt_main_runway_coins(
			LevelConfig.build_main_runway_coins(),
			_track_length,
			float(_mission_profile.get("obstacle_density", 1.0))
		)
	if not main_coins.is_empty():
		for raw in main_coins:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = raw
			var lane: int = int(item.get("lane", 0))
			var dist: float = float(item.get("distance", 0.0))
			if _is_in_fork_main_gap(dist):
				continue
			if _should_skip_mechanic_collectible(dist, lane):
				continue
			var layer: int = int(item.get("layer", 0))
			var air := bool(item.get("air", false))
			var air_tier := int(item.get("air_tier", 1 if air else 0))
			var y: float = _coin_collectible_y(air, layer, 0, air_tier)
			if layer == 0:
				y += _path_height_lift_at(dist)
			var collectible := _make_collectible(lane, dist, y, layer)
			collectibles.append({
				"node": collectible,
				"lane": lane,
				"distance": dist,
				"y": y,
				"layer": layer,
				"kind": "coin",
				"air": air,
				"pattern": String(item.get("pattern", "")),
				"collected": false,
				"bob_phase": fmod(dist * 0.17 + float(lane) * 0.9, TAU),
			})
			coin_index += 1
	else:
		var coin_dists: Array = MissionTypes.adapt_coin_distances(
			LevelConfig.build_coin_distances(),
			_track_length,
			float(_mission_profile.get("obstacle_density", 1.0))
		)
		for dist in coin_dists:
			var lane: int = int(LANES[coin_index % LANES.size()])
			var layer: int = 0
			var y: float = _layer_height(layer) + (0.35 if coin_index % 5 != 2 else 1.2)
			var collectible := _make_collectible(lane, dist, y, layer)
			collectibles.append({
				"node": collectible,
				"lane": lane,
				"distance": dist,
				"y": y,
				"layer": layer,
				"kind": "coin",
				"collected": false,
			})
			coin_index += 1

	if LevelConfig.has_method("build_side_runway_coins"):
		var side_coins: Array = MissionTypes.adapt_side_runway_coins(
			LevelConfig.build_side_runway_coins(),
			_track_length
		)
		for raw in side_coins:
			if typeof(raw) != TYPE_DICTIONARY:
				continue
			var item: Dictionary = raw
			var lane: int = int(item.get("lane", 0))
			var dist: float = float(item.get("distance", 0.0))
			if not _side_coin_in_active_zone(dist):
				continue
			var layer: int = int(item.get("layer", WALL_RUN_LAYER))
			var y_boost := bool(item.get("y_boost", false))
			var y: float = _wall_lane_height_for_lane_value(lane) + (0.55 if y_boost else 0.0)
			var collectible := _make_collectible(lane, dist, y, layer)
			collectibles.append({
				"node": collectible,
				"lane": lane,
				"distance": dist,
				"y": y,
				"layer": layer,
				"kind": "coin",
				"collected": false,
			})

	_spawn_shield_crystals()
	_register_speed_boost_data()
	_register_bonus_fork_rewards()
	_register_y_fork_branch_rewards()
	_materialize_registered_collectibles()
	_refresh_smash_budget()
	total_collectibles = 0
	for c in collectibles:
		if String(c.get("kind", "coin")) == "coin":
			total_collectibles += 1
	_build_finish_sprint_pads()



func _speed_boosts_enabled() -> bool:
	if bool(_mission_profile.get("timed_fail", false)):
		return true
	var mt := String(_mission_profile.get("id", mission.get("mission_type", "")))
	if mt == "emergency":
		return true
	# 星火中继站追击关：JSON 未单独配置时仍投放默认加速靴
	return bool(_mission_profile.get("enable_chaser", false)) and _is_relay_mission()


func _default_speed_boosts() -> Array:
	var out: Array = []
	var step := clampf(_track_length / 7.0, 70.0, 140.0)
	var d := step
	var i := 0
	while d < _track_length - 35.0:
		out.append({"distance": d, "lane": int(LANES[i % LANES.size()]), "layer": 0})
		d += step
		i += 1
	return out


func _speed_boost_collectible_y(boost_index: int, layer: int) -> float:
	return _layer_height(layer) + (BUFF_AIR_Y_OFFSET if boost_index % 2 == 0 else BUFF_GROUND_Y_OFFSET)


func _speed_boost_duration() -> float:
	return SPEED_BOOST_DURATION_EMERGENCY if _is_emergency_run else SPEED_BOOST_DURATION


func _register_speed_boost_pickup() -> void:
	var dur := _speed_boost_duration()
	if _is_relay_mission():
		dur *= 1.18
	_speed_boost_timer = dur
	_speed_boost_cycle += 1
	_chaser_repulse(CHASER_BOOST_REPULSE)
	camera_shake = maxf(camera_shake, 0.14 if _is_relay_mission() else 0.08)
	_speed_feel_punch = maxf(_speed_feel_punch, 0.95 if _is_relay_mission() else 0.55)
	_hit_fov_punch = maxf(_hit_fov_punch, 0.28 if _is_relay_mission() else 0.12)
	_show_gate_toast("Speed Pad · shake Nulltide" if _chaser_enabled else "Speed Boost")
	_refresh_buff_hud()


func _materialize_registered_collectibles() -> void:
	for entry in collectibles:
		if entry.get("node") != null:
			continue
		var kind := String(entry.get("kind", "coin"))
		var lane := int(entry.get("lane", 0))
		var dist := float(entry.get("distance", 0.0))
		var y := float(entry.get("y", _layer_height(0)))
		var layer := int(entry.get("layer", 0))
		var fork_side := int(entry.get("fork_side", 0))
		var node: Node3D = null
		match kind:
			"coin":
				node = _make_collectible(lane, dist, y, layer, fork_side)
			"speed_boost":
				node = _make_speed_boost(lane, dist, y, layer, fork_side)
			"shield_crystal":
				node = _make_shield_crystal(lane, dist, y, layer, fork_side)
			_:
				node = _make_collectible(lane, dist, y, layer, fork_side)
		entry["node"] = node


func _world_on_path_forced_fork(distance: float, lateral: float, y: float, layer: int, fork_side: int = 0) -> Dictionary:
	return _world_on_path_for_obstacle(distance, lateral, y, layer, fork_side)


func _make_speed_boost(lane: int, distance: float, y: float, layer: int, fork_side: int = 0) -> Node3D:
	var root := Node3D.new()
	root.name = "SpeedBoostBoot"
	var boot := _build_speed_boot_mesh()
	boot.name = "BootVisual"
	boot.position.y = 0.08
	# 略侧倾，侧面轮廓更像靴子
	boot.rotation_degrees = Vector3(-6.0, 28.0, 8.0)
	root.add_child(boot)
	# 脚下光环，拾取更醒目
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.38
	torus.outer_radius = 0.52
	torus.rings = 10
	torus.ring_segments = 18
	torus.material = _make_material(Color(1.0, 0.72, 0.2, 0.45), Color(1.0, 0.55, 0.08), 1.6)
	ring.mesh = torus
	ring.position.y = 0.04
	ring.rotation_degrees = Vector3(90, 0, 0)
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(ring)
	track_root.add_child(root)
	var placed: Dictionary = _world_on_path_forced_fork(distance, float(lane) * LANE_WIDTH, y, layer, fork_side)
	root.position = placed["pos"]
	root.rotation.y = float(placed["yaw"])
	return root


func _build_speed_boot_mesh() -> Node3D:
	var boot := Node3D.new()
	var leather := _make_material(Color(0.18, 0.22, 0.32), Color(0.35, 0.55, 0.95), 0.55)
	leather.metallic = 0.35
	leather.roughness = 0.42
	var sole_mat := _make_material(Color(0.08, 0.09, 0.12), Color(0.2, 0.25, 0.35), 0.15)
	sole_mat.metallic = 0.1
	sole_mat.roughness = 0.7
	var accent := _make_material(Color(1.0, 0.62, 0.16), Color(1.0, 0.55, 0.08), 2.6)
	accent.metallic = 0.55
	accent.roughness = 0.28
	var cyan := _make_material(Color(0.35, 0.85, 1.0, 0.92), Color(0.25, 0.75, 1.0), 2.2)
	cyan.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	# 鞋底
	var sole := MeshInstance3D.new()
	var sole_mesh := BoxMesh.new()
	sole_mesh.size = Vector3(0.52, 0.12, 0.92)
	sole_mesh.material = sole_mat
	sole.mesh = sole_mesh
	sole.position = Vector3(0.0, 0.08, 0.02)
	boot.add_child(sole)

	# 鞋跟
	var heel := MeshInstance3D.new()
	var heel_mesh := BoxMesh.new()
	heel_mesh.size = Vector3(0.46, 0.22, 0.28)
	heel_mesh.material = sole_mat
	heel.mesh = heel_mesh
	heel.position = Vector3(0.0, 0.14, 0.34)
	boot.add_child(heel)

	# 鞋面（脚背）
	var vamp := MeshInstance3D.new()
	var vamp_mesh := BoxMesh.new()
	vamp_mesh.size = Vector3(0.48, 0.28, 0.58)
	vamp_mesh.material = leather
	vamp.mesh = vamp_mesh
	vamp.position = Vector3(0.0, 0.28, -0.06)
	vamp.rotation_degrees = Vector3(-12.0, 0.0, 0.0)
	boot.add_child(vamp)

	# 鞋头
	var toe := MeshInstance3D.new()
	var toe_mesh := SphereMesh.new()
	toe_mesh.radius = 0.22
	toe_mesh.height = 0.36
	toe_mesh.material = leather
	toe.mesh = toe_mesh
	toe.position = Vector3(0.0, 0.26, -0.42)
	toe.scale = Vector3(1.05, 0.72, 1.15)
	boot.add_child(toe)

	# 靴筒
	var shaft := MeshInstance3D.new()
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.17
	shaft_mesh.bottom_radius = 0.21
	shaft_mesh.height = 0.62
	shaft_mesh.radial_segments = 12
	shaft_mesh.material = leather
	shaft.mesh = shaft_mesh
	shaft.position = Vector3(0.0, 0.62, 0.22)
	shaft.rotation_degrees = Vector3(8.0, 0.0, 0.0)
	boot.add_child(shaft)

	# 筒口装饰环
	var cuff := MeshInstance3D.new()
	var cuff_mesh := TorusMesh.new()
	cuff_mesh.inner_radius = 0.14
	cuff_mesh.outer_radius = 0.2
	cuff_mesh.rings = 8
	cuff_mesh.ring_segments = 14
	cuff_mesh.material = accent
	cuff.mesh = cuff_mesh
	cuff.position = Vector3(0.0, 0.94, 0.18)
	cuff.rotation_degrees = Vector3(98.0, 0.0, 0.0)
	boot.add_child(cuff)

	# 侧面能量条（加速感）
	var stripe := MeshInstance3D.new()
	var stripe_mesh := BoxMesh.new()
	stripe_mesh.size = Vector3(0.06, 0.18, 0.7)
	stripe_mesh.material = cyan
	stripe.mesh = stripe_mesh
	stripe.position = Vector3(0.26, 0.34, -0.02)
	stripe.rotation_degrees = Vector3(-10.0, 0.0, 0.0)
	boot.add_child(stripe)

	# 后跟推进焰翼
	var wing := MeshInstance3D.new()
	var wing_mesh := PrismMesh.new()
	wing_mesh.size = Vector3(0.18, 0.42, 0.28)
	wing_mesh.material = accent
	wing.mesh = wing_mesh
	wing.position = Vector3(0.0, 0.36, 0.52)
	wing.rotation_degrees = Vector3(90.0, 0.0, 180.0)
	boot.add_child(wing)

	return boot


func _register_speed_boost_data() -> void:
	var items: Array = []
	var layout_id := _mission_layout_id()
	if layout_id != "":
		items = ObstacleLayout.load_speed_boosts(layout_id)
	# 关卡 JSON 可单独投放加速包；否则仅紧急/限时任务用默认刷点
	if items.is_empty():
		if not _speed_boosts_enabled():
			return
		items = _default_speed_boosts()
	var finish_cut := maxf(_track_length - 30.0, _track_length * 0.9)
	var boost_index := 0
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var dist := float(item.get("distance", 0.0))
		if dist < 8.0 or dist > finish_cut:
			continue
		var lane := int(item.get("lane", 0))
		var layer := int(item.get("layer", 0))
		var y: float = _speed_boost_collectible_y(boost_index, layer)
		boost_index += 1
		_register_collectible_data(lane, dist, y, layer, "speed_boost")


func _register_collectible_data(
	lane: int,
	distance: float,
	y: float,
	layer: int,
	kind: String,
	air: bool = false,
	fork_side: int = 0
) -> void:
	collectibles.append({
		"node": null,
		"lane": lane,
		"distance": distance,
		"y": y,
		"layer": layer,
		"kind": kind,
		"air": air,
		"fork_side": fork_side,
		"collected": false,
	})


func _register_bonus_fork_rewards() -> void:
	# 奖励右岔：短距内密布金币 + 加速包（强制落在右岔几何）
	for zone in _junction_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		if String(zone.get("effect_b", "")) != "bonus":
			continue
		if _junction_overlaps_y_fork(zone):
			continue
		var z_start := float(zone.get("distance", 0.0))
		var z_len := float(zone.get("length", 50.0))
		var d0 := z_start + 8.0
		var d1 := z_start + z_len - 5.0
		if d1 <= d0:
			continue
		var coin_i := 0
		var d := d0
		while d <= d1:
			var lane := int(LANES[coin_i % LANES.size()])
			var y: float = _coin_collectible_y(false, 0)
			_register_collectible_data(lane, d, y, 0, "coin", false, 1)
			coin_i += 1
			d += 6.5
		var boost_i := 0
		d = d0 + 3.5
		while d <= d1:
			var blane := int(LANES[boost_i % LANES.size()])
			var by: float = _speed_boost_collectible_y(boost_i, 0)
			_register_collectible_data(blane, d, by, 0, "speed_boost", false, 1)
			boost_i += 1
			d += 8.5
		# 中段一枚防护水晶
		var mid := (d0 + d1) * 0.5
		_register_collectible_data(0, mid, _layer_height(0) + 0.85, 0, "shield_crystal", false, 1)


func _spawn_shield_crystals() -> void:
	var items: Array = []
	var layout_id := _runner_layout_id()
	if layout_id != "":
		items = ObstacleLayout.load_shield_crystals(layout_id)
	if items.is_empty() and LevelConfig != null and LevelConfig.has_method("build_shield_crystals") and layout_id == "" and not CustomLevels.has_level(Global.runner_location_id):
		items = LevelConfig.build_shield_crystals()
	if items.is_empty():
		items = _default_shield_crystals_from_sandstorms()
	var seen_dist: Dictionary = {}
	var deduped: Array = []
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var dkey := "%.1f:%d" % [float(raw.get("distance", 0.0)), int(raw.get("lane", 0))]
		if seen_dist.has(dkey):
			continue
		seen_dist[dkey] = true
		deduped.append(raw)
	items = deduped
	var finish_cut := maxf(_track_length - 30.0, _track_length * 0.9)
	for raw in items:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var item: Dictionary = raw
		var dist := float(item.get("distance", 0.0))
		if dist < 20.0 or dist > finish_cut:
			continue
		if not _shield_crystal_allowed_at(dist):
			continue
		var lane := int(item.get("lane", 0))
		var layer := int(item.get("layer", 0))
		var y: float = _layer_height(layer) + 0.85
		var node := _make_shield_crystal(lane, dist, y, layer)
		collectibles.append({
			"node": node,
			"lane": lane,
			"distance": dist,
			"y": y,
			"layer": layer,
			"kind": "shield_crystal",
			"collected": false,
		})

func _default_shield_crystals_from_sandstorms() -> Array:
	# 节奏：热浪前给够开罩的水晶；水晶后面必须还有热浪。最后一片热浪结束后不再刷。
	var out: Array = []
	var zones := _sorted_hazard_zones()
	if zones.is_empty():
		return out
	var first := float(zones[0].get("start", 0.0))
	var a := clampf(minf(80.0, first - 70.0), 48.0, maxf(48.0, first - 52.0))
	var b := clampf(minf(a + 44.0, first - 28.0), a + 28.0, maxf(a + 28.0, first - 22.0))
	out.append({"lane": 0, "distance": a, "layer": 0})
	out.append({"lane": 0, "distance": b, "layer": 0})
	for i in zones.size():
		var zone: Dictionary = zones[i]
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		var end := start + length
		var has_next := i < zones.size() - 1
		var approach := start - 22.0
		if approach > b + 18.0:
			out.append({"lane": 0, "distance": approach, "layer": 0})
		if length >= 36.0:
			out.append({"lane": 0, "distance": start + length * 0.40, "layer": 0})
		if has_next:
			var next_start := float(zones[i + 1].get("start", end + 80.0))
			var refill := end + 14.0
			if refill < next_start - 24.0:
				out.append({"lane": 0, "distance": refill, "layer": 0})
	return out


func _sorted_hazard_zones() -> Array:
	var zones: Array = []
	for raw in _sandstorm_zones():
		if typeof(raw) == TYPE_DICTIONARY:
			zones.append(raw)
	zones.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("start", 0.0)) < float(b.get("start", 0.0))
	)
	return zones


func _first_hazard_start_distance() -> float:
	var zones := _sorted_hazard_zones()
	if zones.is_empty():
		return INF
	return float(zones[0].get("start", INF))


func _last_hazard_end_distance() -> float:
	var last := -INF
	for zone in _sorted_hazard_zones():
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		last = maxf(last, start + length)
	return last

func _register_obstacle(item: Dictionary) -> Node3D:
	var obstacle_type := String(item["type"])
	if obstacle_type == "energy_ring":
		return null
	var lane: int = int(item.get("lane", 0))
	var dist: float = float(item["distance"])
	var layer: int = int(item.get("layer", 0))
	var fork_branch := int(item.get("fork_branch", 0))
	# 横向岔路中段主路障碍会与分支几何重叠，改由 fork_branch 注入
	if fork_branch == 0 and not _junction_fork_region_at(dist).is_empty():
		var zone := _fork_zone_at(dist)
		if not zone.is_empty():
			var t := (dist - float(zone["distance"])) / maxf(float(zone.get("length", 70.0)), 0.001)
			if t > 0.04 and t < 0.96:
				return null
	# 支路障碍铺在分叉地面上，不能按「主路挖空」丢掉
	if fork_branch == 0 and not _is_distance_on_main_ground_runway(dist, layer):
		return null
	if layer == 0 and fork_branch == 0 and obstacle_type != "main_block" and _is_distance_on_track_turn(dist, 12.0):
		return null
	var node := _make_obstacle(lane, dist, obstacle_type, layer, item)
	var asset_path := String(node.get_meta("obstacle_asset_path", ""))
	var is_float_orb := obstacle_type == "orb" or (node.has_meta("float_orb") and bool(node.get_meta("float_orb")))
	var is_low_slide := obstacle_type in ["slide", "high_bar"] and (
		bool(item.get("low_slide", false)) or bool(node.get_meta("low_slide", false))
	)
	var default_clear := SLIDE_CLEAR_Y if obstacle_type in ["slide", "high_bar", "wave_arc_slide"] else GROUND_Y + 0.52
	if obstacle_type == "wave_arc_slide":
		default_clear = GROUND_Y + WAVE_ARC_APEX_Y - 0.04
	if is_low_slide:
		default_clear = GROUND_Y + LOW_SLIDE_BEAM_TOP - 0.04
	if layer == WALL_RUN_LAYER:
		if obstacle_type in ["slide", "high_bar", "wave_arc_slide"]:
			default_clear = float(WALL_LANE_HEIGHTS[2]) + 0.2
		elif obstacle_type in ["jump", "low_barrier"]:
			default_clear = float(WALL_LANE_HEIGHTS[1]) + 0.55
	if obstacle_type == "main_block":
		default_clear = _layer_height(layer) + 4.0
	if is_float_orb:
		default_clear = GROUND_Y + 1.02
	elif "energy_sprigs" in asset_path:
		default_clear = GROUND_Y + 0.45
	if bool(item.get("overweight_tutorial", false)) and obstacle_type in ["jump", "low_barrier"] and layer == 0:
		default_clear = GROUND_Y + 0.72
	elif obstacle_type in ["jump", "low_barrier"] and _is_lightweight_jump_obstacle_asset(asset_path):
		default_clear = GROUND_Y + JUMP_WALL_CLEAR_Y
	if obstacle_type in ["train", "train_moving"]:
		if bool(node.get_meta("has_wave_blade", false)):
			default_clear = GROUND_Y + 0.52
		else:
			default_clear = float(node.get_meta("prop_clear_height", GROUND_Y + 1.86))
	var strike_label := ""
	if LevelConfig.has_method("get_jump_obstacle_label") and asset_path != "":
		strike_label = LevelConfig.get_jump_obstacle_label(asset_path)
	var entry := {
		"node": node,
		"lane": lane,
		"distance": dist,
		"type": obstacle_type,
		"layer": layer,
		"fork_branch": int(item.get("fork_branch", 0)),
		"clear_height": float(item.get("clear_height", default_clear)),
		"half_depth": float(item.get("half_depth", _obstacle_half_depth(obstacle_type))),
		"hit": false,
		"heat_hazard": node.has_meta("heat_hazard") and bool(node.get_meta("heat_hazard")),
		"float_orb": is_float_orb,
		"strike_label": strike_label,
		"moving": obstacle_type == "train_moving",
		"move_speed": float(item.get("move_speed", 0.0)),
		"move_offset": 0.0,
		"y_offset": float(item.get("y_offset", 0.0)),
		"target_layer": int(item.get("target_layer", layer + 1)),
	}
	if obstacle_type in ["slide", "high_bar", "wave_arc_slide"]:
		entry["open_bottom"] = float(node.get_meta("open_bottom", LOW_SLIDE_OPEN_BOTTOM if is_low_slide else SLIDE_GATE_OPEN_BOTTOM))
		if obstacle_type == "wave_arc_slide":
			entry["open_bottom"] = float(node.get_meta("open_bottom", WAVE_ARC_OPEN_BOTTOM))
		if is_low_slide or obstacle_type == "wave_arc_slide":
			entry["low_slide"] = true
	if obstacle_type == "energy_ring":
		entry["ring_center_y"] = float(node.get_meta("ring_center_y", GROUND_Y + ENERGY_RING_CENTER_Y))
		entry["ring_inner_half"] = float(node.get_meta("ring_inner_half", ENERGY_RING_INNER_HALF))
		entry["ring_inner_half_y"] = float(node.get_meta("ring_inner_half_y", ENERGY_RING_INNER_HALF_Y))
		entry["ring_outer_half"] = float(node.get_meta("ring_outer_half", ENERGY_RING_OUTER_HALF))
		entry["clear_height"] = entry["ring_center_y"] + ENERGY_RING_OUTER_HALF + 0.35
		entry["hit_half_width"] = float(node.get_meta("ring_outer_half", ENERGY_RING_OUTER_HALF))
		entry["half_depth"] = 1.35
	if obstacle_type in ["train", "train_moving"]:
		if bool(node.get_meta("has_wave_blade", false)):
			entry["blade_top"] = float(node.get_meta("blade_top", TRAIN_GATE_TOP))
			entry["hit_half_width"] = _runway_half_width() * 0.98
			entry["half_depth"] = 0.85
			entry["clear_height"] = float(entry["blade_top"])
		else:
			entry["hit_half_width"] = float(node.get_meta("prop_hit_half_width", LANE_HIT_HALF_WIDTH_JUMP))
			entry["half_depth"] = float(node.get_meta("prop_half_depth", 0.55))
			if bool(node.get_meta("prop_slide", false)):
				entry["prop_slide"] = true
	if obstacle_type == "main_block":
		entry["cross_mode"] = _main_block_cross_mode(item)
	if obstacle_type == "meteorite":
		entry["fall_roll"] = bool(item.get("fall_roll", false))
		entry["meteor_radius"] = float(node.get_meta("meteorite_radius", maxf(float(item.get("span", 2.0)) * 0.5, 0.7)))
		entry["hit_half_width"] = float(node.get_meta("meteorite_hit_half_width", LANE_WIDTH * 0.62))
		entry["half_depth"] = float(node.get_meta("meteorite_half_depth", _obstacle_half_depth("meteorite")))
		entry["clear_height"] = float(node.get_meta("meteorite_clear_height", entry["clear_height"]))
		if item.has("meteor_state"):
			entry["meteor_state"] = String(item.get("meteor_state", "sky"))
		if item.has("meteor_air_y"):
			entry["meteor_air_y"] = float(item.get("meteor_air_y", 16.0))
		elif item.has("fall_height"):
			entry["meteor_air_y"] = float(item.get("fall_height", 16.0))
		if bool(entry.get("fall_roll", false)):
			if not entry.has("meteor_state"):
				entry["meteor_state"] = "sky"
			if not entry.has("meteor_air_y"):
				entry["meteor_air_y"] = 16.0
			entry["y_offset"] = float(entry.get("meteor_air_y", 16.0))
			if item.has("roll_speed"):
				entry["roll_speed"] = float(item.get("roll_speed", -5.5))
		if item.has("meteor_fall_speed"):
			entry["meteor_fall_speed"] = float(item.get("meteor_fall_speed", 22.0))
		if item.has("fall_trigger_ahead"):
			entry["fall_trigger_ahead"] = float(item.get("fall_trigger_ahead", 58.0))
	if obstacle_type == "meteorite_gate":
		entry["gate_drop_timer"] = 0.35
		entry["gate_drop_interval"] = clampf(float(item.get("drop_interval", 1.05)), 0.55, 2.5)
		entry["gate_drops_left"] = clampi(int(item.get("drop_count", 5)), 2, 12)
		entry["gate_drop_index"] = 0
		entry["gate_rng_seed"] = hash(int(dist * 13) + lane * 31)
		entry["half_depth"] = 1.15
	if is_float_orb:
		entry["lateral_offset"] = 0.0
		entry["lateral_dir"] = 1.0 if randf() > 0.5 else -1.0
		if item.has("orb_size"):
			entry["orb_size"] = String(item.get("orb_size", ""))
		entry["orb_tier"] = String(node.get_meta("orb_tier", "small"))
		entry["lateral_speed"] = float(node.get_meta("orb_drift_speed", ORB_SMALL_DRIFT_SPEED))
		entry["drift_span"] = float(node.get_meta("orb_drift_span", ORB_DRIFT_SPAN))
		entry["orb_float_phase"] = randf() * TAU
		entry["orb_float_speed"] = float(node.get_meta("orb_float_speed", ORB_SMALL_FLOAT_SPEED))
		entry["orb_float_amp"] = float(node.get_meta("orb_float_amp", ORB_SMALL_FLOAT_AMP))
		entry["orb_visual_base_y"] = ORB_VISUAL_BASE_Y
		entry["orb_pop"] = 0.0
		entry["orb_revealed"] = false
		var visual := node.get_node_or_null("JumpObstacleModel") as Node3D
		if visual:
			entry["orb_base_scale"] = visual.scale
		entry["hit_half_width"] = float(node.get_meta("orb_hit_half_width", 0.34))
		entry["half_depth"] = float(node.get_meta("orb_half_depth", _obstacle_half_depth("orb")))
		entry["orb_size_scale"] = float(node.get_meta("orb_size_scale", 1.0))
		entry["orb_layout_version"] = ORB_LAYOUT_VERSION
	obstacles.append(entry)
	if not bool(entry.get("moving", false)):
		entry["move_offset"] = 0.0
	_place_obstacle_node(entry)
	if obstacle_type in ["train", "train_moving"] and bool(node.get_meta("has_wave_blade", false)) and _runner_layout_id() == "":
		_register_train_gate_shield_crystal(entry)
	return node

func _make_obstacle(lane: int, distance: float, obstacle_type: String, layer: int, item: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = "%sObstacle" % obstacle_type.capitalize()
	track_root.add_child(root)

	if layer == WALL_RUN_LAYER and obstacle_type in ["jump", "low_barrier", "slide", "high_bar", "wave_arc_slide"]:
		if obstacle_type == "wave_arc_slide":
			_build_wall_wave_arc_slide(root, item)
		else:
			_build_wall_face_obstacle(root, item, obstacle_type)
		return root

	match obstacle_type:
		"slide", "high_bar":
			_build_high_bar(root, item)
		"wave_arc_slide":
			_build_wave_arc_slide(root, item)
		"energy_ring":
			_build_energy_ring(root, item)
		"orb":
			_build_energy_orb(root, item)
		"train":
			_build_train(root, item, false)
		"train_moving":
			_build_train(root, item, true)
		"block_left":
			_build_lane_block(root, "left")
		"block_right":
			_build_lane_block(root, "right")
		"main_block":
			_build_main_block(root, item)
		"ramp":
			_build_ramp(root, int(item.get("target_layer", layer + 1)))
		"turn_left", "turn_right":
			_build_turn_sign(root, obstacle_type)
		"meteorite":
			_build_runway_meteorite(root, item)
		"meteorite_gate":
			_build_meteorite_gate(root, item)
		"jump", "low_barrier":
			_build_jump_bar(root, item)
		_:
			_build_jump_bar(root, item)

	return root


func _build_wall_face_obstacle(root: Node3D, item: Dictionary, obstacle_type: String) -> void:
	var is_slide := obstacle_type in ["slide", "high_bar"]
	root.set_meta("wall_face_obstacle", true)
	root.set_meta("obstacle_asset_path", "wall_face_%s" % ("slide" if is_slide else "jump"))
	var bar := MeshInstance3D.new()
	bar.name = "WallFaceObstacleBar"
	var box := BoxMesh.new()
	if is_slide:
		# 青蓝横梁挡中高列：必须滑到低列
		box.size = Vector3(0.72, 1.85, 3.4)
	else:
		# 橙色低栏挡低列：必须跳到中/高列
		box.size = Vector3(0.7, 1.15, 3.2)
	bar.mesh = box
	var mat := StandardMaterial3D.new()
	if is_slide:
		mat.albedo_color = Color(0.08, 0.72, 1.0, 1.0)
		mat.emission = Color(0.12, 0.85, 1.0)
	else:
		mat.albedo_color = Color(1.0, 0.42, 0.06, 1.0)
		mat.emission = Color(1.0, 0.48, 0.05)
	mat.emission_enabled = true
	mat.emission_energy_multiplier = 3.4
	mat.metallic = 0.18
	mat.roughness = 0.28
	bar.material_override = mat
	bar.position = Vector3(0.22, box.size.y * 0.5 + (0.85 if is_slide else 0.08), 0.0)
	root.add_child(bar)
	var stripe := MeshInstance3D.new()
	stripe.name = "WallFaceObstacleStripe"
	var stripe_box := BoxMesh.new()
	stripe_box.size = Vector3(box.size.x + 0.06, 0.16, box.size.z + 0.08)
	stripe.mesh = stripe_box
	var stripe_mat := StandardMaterial3D.new()
	stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stripe_mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	stripe_mat.emission_enabled = true
	stripe_mat.emission = Color(1.0, 1.0, 1.0)
	stripe_mat.emission_energy_multiplier = 2.2
	stripe.material_override = stripe_mat
	stripe.position = bar.position + Vector3(0.02, (0.62 if is_slide else -0.28), 0.0)
	root.add_child(stripe)


func _build_jump_bar(root: Node3D, item: Dictionary = {}) -> void:
	var span := _runway_obstacle_span_at(float(item.get("distance", 0.0)))
	root.set_meta("obstacle_span", span)
	var style := _resolve_jump_bar_style(item)
	var scene_index := _pick_jump_bar_scene_index(item)
	var asset_path := ""
	if scene_index < _jump_obstacle_paths.size():
		asset_path = _jump_obstacle_paths[scene_index]
	if style == "wood_fence" or _is_color_block_obstacle_asset(asset_path):
		root.set_meta("obstacle_asset_path", "wood_fence_jump")
		_add_wooden_fence_jump_visual(root, span, JUMP_BAR_HEIGHT)
		_add_ground_contact_shadow(root, span * 0.82, 0.75)
		return
	root.set_meta("obstacle_asset_path", asset_path)
	var target_h := _jump_target_height_for(asset_path)
	_add_jump_bar_visual(root, _get_jump_obstacle_scene(scene_index), target_h, span)
	if root.get_node_or_null("JumpObstacleModel") == null:
		_add_wooden_fence_jump_visual(root, span, JUMP_BAR_HEIGHT)
		root.set_meta("obstacle_asset_path", "wood_fence_jump")
	else:
		_apply_obstacle_visual_materials(root, "JumpObstacleModel", asset_path)
	_add_ground_contact_shadow(root, span * 0.82, 0.75)

func _build_runway_meteorite(root: Node3D, item: Dictionary = {}) -> void:
	# 占道陨石：贴地滚动；视觉绕球心转，避免转进跑道
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(int(float(item.get("distance", 0.0)) * 17.0) + int(item.get("lane", 0)) * 31)
	var default_span := LANE_WIDTH * rng.randf_range(0.52, 1.85)
	var diameter := clampf(float(item.get("span", default_span)), LANE_WIDTH * 0.65, LANE_WIDTH * 2.05)
	var radius := diameter * 0.5
	var palette := _pick_meteorite_palette(rng, float(item.get("distance", 0.0)), float(item.get("lane", 0)) * LANE_WIDTH)
	var visual := Node3D.new()
	visual.name = "MeteoriteObstacleModel"
	root.add_child(visual)
	var spin := Node3D.new()
	spin.name = "MeteoriteSpin"
	spin.position.y = radius
	visual.add_child(spin)
	var used_glb := _attach_meteorite_glb_to_spin(spin, diameter, palette)
	if used_glb:
		root.set_meta("obstacle_asset_path", OBSTACLE_PROP_METEORITE)
	if not used_glb:
		var body := MeshInstance3D.new()
		body.name = "MeteoriteSphere"
		var sphere := SphereMesh.new()
		sphere.radius = radius
		sphere.height = diameter
		var fall_roll := bool(item.get("fall_roll", false))
		sphere.radial_segments = 10 if fall_roll else 20
		sphere.rings = 6 if fall_roll else 10
		body.mesh = sphere
		var mat := StandardMaterial3D.new()
		var albedo: Color = palette.get("albedo", Color(0.52, 0.44, 0.38))
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		mat.albedo_color = albedo
		mat.emission_enabled = false
		mat.emission_energy_multiplier = 0.0
		mat.roughness = 0.88
		mat.metallic = 0.0
		body.material_override = mat
		body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		spin.add_child(body)
		root.set_meta("obstacle_asset_path", "sphere_meteorite")
	visual.rotation_degrees.y = rng.randf_range(0.0, 360.0)
	root.set_meta("meteorite_radius", radius)
	root.set_meta("meteorite_hit_half_width", clampf(radius * 0.82, 0.38, radius * 0.92))
	root.set_meta("meteorite_half_depth", clampf(radius * 0.82, 0.48, radius * 0.92))
	root.set_meta("meteorite_clear_height", GROUND_Y + diameter * 0.9)
	if not bool(item.get("fall_roll", false)):
		_add_ground_contact_shadow(root, diameter * 0.95, 1.15)


func _attach_meteorite_glb_to_spin(spin: Node3D, diameter: float, palette: Dictionary = {}) -> bool:
	var scene := _load_runner_scene(OBSTACLE_PROP_METEORITE, false)
	if scene == null:
		return false
	var model := scene.instantiate() as Node3D
	if model == null:
		return false
	model.name = "MeteoriteSphere"
	spin.add_child(model)
	model.force_update_transform()
	var bounds := _compute_node_aabb(model)
	var max_dim := maxf(maxf(bounds.size.x, bounds.size.y), bounds.size.z)
	if max_dim < 0.05:
		model.queue_free()
		return false
	var s := diameter / max_dim
	model.scale = Vector3(s, s, s)
	model.force_update_transform()
	bounds = _compute_node_aabb(model)
	model.position = -(bounds.position + bounds.size * 0.5)
	if not palette.is_empty():
		_apply_midground_meteorite_variant(spin, palette)
	return true

func _build_energy_orb(root: Node3D, item: Dictionary = {}) -> void:
	var roll := _orb_roll(item)
	var tier := String(roll.get("tier", "small"))
	var size_scale := float(roll.get("scale", ORB_SMALL_SCALE))
	var target_span := float(roll.get("span", ORB_SMALL_SPAN))
	var orb_tint := String(roll.get("tint", ""))
	var asset_path := _resolve_energy_orb_asset_path(item)
	root.set_meta("obstacle_asset_path", asset_path)
	root.set_meta("float_orb", true)
	root.set_meta("orb_tier", tier)
	root.set_meta("orb_size_scale", size_scale)
	root.set_meta("orb_drift_speed", float(roll.get("drift_speed", ORB_SMALL_DRIFT_SPEED)))
	root.set_meta("orb_drift_span", float(roll.get("drift_span", ORB_DRIFT_SPAN)))
	root.set_meta("orb_float_speed", float(roll.get("float_speed", ORB_SMALL_FLOAT_SPEED)))
	root.set_meta("orb_float_amp", float(roll.get("float_amp", ORB_SMALL_FLOAT_AMP)))
	root.set_meta("orb_tint", orb_tint)
	root.set_meta("orb_static", bool(roll.get("static", false)))
	var visual: Node3D
	var scene: PackedScene = null
	if _is_energy_orb_asset_path(asset_path):
		scene = _load_runner_scene(asset_path, false)
	if scene != null and _is_energy_orb_asset_path(asset_path):
		visual = scene.instantiate() as Node3D
		visual.name = "JumpObstacleModel"
		root.add_child(visual)
		_fit_energy_orb_to_span(visual, target_span)
		_apply_orb_tier_visual(visual, tier, orb_tint)
	else:
		visual = _make_procedural_energy_orb_visual(root, target_span, tier, orb_tint)
	visual.position.y += ORB_VISUAL_BASE_Y
	if tier == "colossal":
		# 超大球抬高，避免大半埋进路面
		visual.position.y += target_span * 0.28
	# 不加 OmniLight / 光圈：紫区会出现巨大移动光斑
	root.set_meta("orb_base_scale", visual.scale)
	root.set_meta("orb_visual_base_y", visual.position.y)
	var bounds := _compute_node_aabb(visual)
	var visual_radius := maxf(bounds.size.x, bounds.size.z) * 0.5
	root.set_meta("orb_hit_half_width", visual_radius * ORB_HIT_RADIUS_FACTOR)
	root.set_meta("orb_half_depth", visual_radius * ORB_HIT_DEPTH_FACTOR)
	root.visible = false

func _make_procedural_energy_orb_visual(root: Node3D, span: float, tier: String, tint: String) -> Node3D:
	var visual := Node3D.new()
	visual.name = "JumpObstacleModel"
	root.add_child(visual)
	var radius := maxf(span * 0.5, 0.22)
	var body := MeshInstance3D.new()
	body.name = "EnergyOrbSphere"
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 24
	sphere.rings = 16
	body.mesh = sphere
	var look := _orb_tint_look(tint)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(look.albedo.r, look.albedo.g, look.albedo.b, 0.94)
	mat.emission_enabled = true
	mat.emission = look.emission
	var emission := 5.2
	match tier:
		"colossal":
			emission = 11.0
		"huge":
			emission = 8.5
		"large":
			emission = 6.8
		"medium":
			emission = 5.8
		"tiny":
			emission = 4.2
	mat.emission_energy_multiplier = emission
	body.material_override = mat
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.position.y = radius
	visual.add_child(body)
	var halo := MeshInstance3D.new()
	halo.name = "EnergyOrbHalo"
	var halo_mesh := SphereMesh.new()
	halo_mesh.radius = radius * 1.18
	halo_mesh.height = radius * 2.36
	halo_mesh.radial_segments = 16
	halo_mesh.rings = 8
	halo.mesh = halo_mesh
	var halo_mat := StandardMaterial3D.new()
	halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo_mat.albedo_color = Color(look.emission.r, look.emission.g, look.emission.b, 0.14)
	halo_mat.emission_enabled = true
	halo_mat.emission = mat.emission
	halo_mat.emission_energy_multiplier = emission * 0.42
	halo_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	halo.material_override = halo_mat
	halo.position.y = radius
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visual.add_child(halo)
	visual.set_meta("sprite_obstacle_path", "procedural_energy_orb")
	return visual

func _purge_energy_orb_scene_cache() -> void:
	for path in _jump_obstacle_paths:
		if "energy_orb" in path:
			_scene_cache.erase(path)

func _refit_float_orb(obstacle: Dictionary) -> void:
	var node := obstacle.get("node") as Node3D
	if node == null:
		return
	var visual := node.get_node_or_null("JumpObstacleModel") as Node3D
	if visual == null:
		return
	var item := {"distance": obstacle["distance"], "lane": obstacle["lane"]}
	if obstacle.has("orb_size"):
		item["orb_size"] = obstacle["orb_size"]
	if obstacle.has("orb_tint"):
		item["orb_tint"] = obstacle["orb_tint"]
	if obstacle.has("orb_static"):
		item["static"] = obstacle["orb_static"]
	var roll := _orb_roll(item)
	var tier := String(roll.get("tier", "small"))
	var target_span := float(roll.get("span", ORB_SMALL_SPAN))
	obstacle["orb_tier"] = tier
	obstacle["orb_static"] = bool(roll.get("static", false))
	obstacle["orb_target_span"] = target_span
	obstacle["lateral_speed"] = float(roll.get("drift_speed", ORB_SMALL_DRIFT_SPEED))
	obstacle["drift_span"] = float(roll.get("drift_span", ORB_DRIFT_SPAN))
	obstacle["orb_float_speed"] = float(roll.get("float_speed", ORB_SMALL_FLOAT_SPEED))
	obstacle["orb_float_amp"] = float(roll.get("float_amp", ORB_SMALL_FLOAT_AMP))
	obstacle["orb_tint"] = String(roll.get("tint", ""))
	node.set_meta("orb_tier", tier)
	node.set_meta("orb_static", obstacle["orb_static"])
	_fit_energy_orb_to_span(visual, target_span)
	_apply_orb_tier_visual(visual, tier, String(roll.get("tint", "")))
	visual.position.y = ORB_VISUAL_BASE_Y
	if tier == "colossal":
		visual.position.y += target_span * 0.28
	# 清掉旧版补光/光圈，避免紫区出现巨大移动光斑
	for glow_name in ["ColossalOrbGlow", "PurpleOrbGlow", "PurpleOrbHalo"]:
		var leftover := node.get_node_or_null(glow_name)
		if leftover != null:
			leftover.queue_free()
	obstacle["orb_base_scale"] = visual.scale
	obstacle["orb_layout_version"] = ORB_LAYOUT_VERSION
	obstacle["orb_visual_base_y"] = visual.position.y
	if obstacle["orb_static"]:
		obstacle["lateral_speed"] = 0.0
		obstacle["lateral_offset"] = 0.0
	var bounds := _compute_node_aabb(visual)
	var visual_radius := maxf(bounds.size.x, bounds.size.z) * 0.5
	obstacle["hit_half_width"] = visual_radius * ORB_HIT_RADIUS_FACTOR
	obstacle["half_depth"] = visual_radius * ORB_HIT_DEPTH_FACTOR
	node.set_meta("orb_hit_half_width", obstacle["hit_half_width"])
	node.set_meta("orb_half_depth", obstacle["half_depth"])

func _fit_energy_orb_to_span(model: Node3D, span: float) -> void:
	if model == null or span <= 0.0:
		return
	model.scale = Vector3.ONE
	model.position = Vector3.ZERO
	var sprite_path := String(model.get_meta("sprite_obstacle_path", ""))
	var is_sprite_orb := "energy_orb" in sprite_path
	if is_sprite_orb:
		for node in model.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := node as MeshInstance3D
			if mesh_instance.mesh is QuadMesh:
				var quad := mesh_instance.mesh as QuadMesh
				var quad_h := maxf(quad.size.y, 0.001)
				var uniform := span / quad_h
				model.scale = Vector3(uniform, uniform, uniform)
				model.force_update_transform()
				var bounds := _compute_node_aabb(model)
				model.position = Vector3(
					-(bounds.position.x + bounds.size.x * 0.5),
					-bounds.position.y,
					-(bounds.position.z + bounds.size.z * 0.5)
				)
				return
	var bounds := _compute_node_aabb(model)
	var current := maxf(maxf(bounds.size.x, bounds.size.y), bounds.size.z)
	if current <= 0.001:
		model.scale = Vector3.ONE * span
		return
	model.scale = Vector3.ONE * (span / current)
	model.force_update_transform()
	bounds = _compute_node_aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)

func _orb_tint_look(tint: String) -> Dictionary:
	match tint:
		"cyan":
			return {
				"albedo": Color(0.28, 0.96, 1.0),
				"emission": Color(0.10, 0.74, 1.0),
				"sprite": Color(0.42, 0.98, 1.0),
			}
		"gold":
			return {
				"albedo": Color(1.0, 0.84, 0.32),
				"emission": Color(1.0, 0.56, 0.10),
				"sprite": Color(1.0, 0.88, 0.40),
			}
		"teal":
			return {
				"albedo": Color(0.22, 1.0, 0.70),
				"emission": Color(0.08, 0.82, 0.48),
				"sprite": Color(0.38, 1.0, 0.78),
			}
		"amber":
			return {
				"albedo": Color(1.0, 0.64, 0.20),
				"emission": Color(1.0, 0.40, 0.06),
				"sprite": Color(1.0, 0.74, 0.34),
			}
		"purple":
			return {
				"albedo": Color(1.0, 0.70, 1.0),
				"emission": Color(0.98, 0.38, 1.0),
				"sprite": Color(1.0, 0.68, 1.0),
			}
		_:
			return {
				"albedo": Color(0.62, 0.90, 1.0),
				"emission": Color(0.35, 0.78, 1.0),
				"sprite": Color(0.72, 0.90, 1.0),
			}


func _apply_orb_tier_visual(model: Node3D, tier: String, tint: String = "") -> void:
	var is_large := tier in ["large", "huge", "colossal"]
	var look := _orb_tint_look(tint)
	var named_tint := tint in ["purple", "cyan", "gold", "teal", "amber"]
	var emission_boost := 1.15 if not is_large else 2.8
	if tier == "huge":
		emission_boost *= 1.15
	elif tier == "colossal":
		emission_boost *= 1.35
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		var mat := mesh_instance.get_active_material(0)
		if mat is StandardMaterial3D:
			var dup := mat.duplicate() as StandardMaterial3D
			if named_tint:
				dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				dup.alpha_scissor_threshold = 0.08
				dup.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				dup.albedo_color = look.albedo
				dup.emission_enabled = true
				dup.emission = look.emission
				if dup.albedo_texture != null:
					dup.emission_texture = dup.albedo_texture
				var named_e := 5.2
				if tint == "purple":
					named_e = 6.6
				if _mission_id_str() == "mission_reservoir_02" and tint == "purple":
					named_e = 7.6
				if tier == "huge":
					named_e = 8.5
				elif tier == "colossal":
					named_e = 11.0
				elif is_large:
					named_e = 6.5
				dup.emission_energy_multiplier = named_e
				dup.roughness = 0.04
				dup.metallic = 0.0
				dup.rim_enabled = true
				dup.rim = 1.0
				dup.rim_tint = 0.05
				dup.cull_mode = BaseMaterial3D.CULL_DISABLED
				dup.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
			else:
				dup.emission_energy_multiplier *= emission_boost
				if is_large:
					dup.albedo_color = dup.albedo_color.lerp(Color(0.82, 0.42, 1.0), 0.38)
					dup.emission = dup.emission.lerp(Color(0.55, 0.22, 0.95), 0.62)
				else:
					dup.albedo_color = dup.albedo_color.lerp(Color(0.55, 0.78, 1.0), 0.18)
					dup.emission = dup.emission.lerp(Color(0.18, 0.42, 0.88), 0.35)
			mesh_instance.material_override = dup
	for node in model.find_children("*", "Sprite3D", true, false):
		var spr := node as Sprite3D
		if named_tint:
			spr.modulate = look.sprite
			spr.transparent = true

func _add_jump_bar_visual(root: Node3D, scene: PackedScene, target_height: float, target_span: float) -> void:
	if scene == null:
		_add_jump_bar_procedural_fallback(root, target_height, target_span)
		return
	var model := scene.instantiate() as Node3D
	model.name = "JumpObstacleModel"
	root.add_child(model)
	model.position = Vector3.ZERO
	model.rotation_degrees = Vector3.ZERO

	var bounds0 := _compute_node_aabb(model)
	if bounds0.size.y <= 0.001:
		push_warning("JumpObstacleModel bounds invalid: %s" % root.get_meta("obstacle_asset_path", ""))
		model.name = "JumpObstacleModelDiscard"
		model.queue_free()
		_add_jump_bar_procedural_fallback(root, target_height, target_span)
		return
	var sy := target_height / maxf(bounds0.size.y, 0.001)
	# 保留厚度，避免被拉成「纸片矮栏」
	var depth0 := minf(bounds0.size.x, bounds0.size.z)
	var span0 := maxf(bounds0.size.x, bounds0.size.z)
	var span_scale := target_span / maxf(span0, 0.001)
	var depth_scale := clampf(sy, 0.9, 2.4)
	if depth0 > 0.001:
		# 目标厚度至少约为高度的 35%，避免扁片
		var min_depth := target_height * 0.35
		depth_scale = maxf(depth_scale, min_depth / depth0)
		depth_scale = minf(depth_scale, 3.2)
	if bounds0.size.z >= bounds0.size.x:
		model.rotation_degrees.y = 90.0
		model.force_update_transform()
		model.scale = Vector3(depth_scale, sy, span_scale)
	else:
		model.scale = Vector3(span_scale, sy, depth_scale)
	model.force_update_transform()
	var bounds := _compute_node_aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)
	# 断墙可以很薄，不能当色块丢掉；只有完全没宽度才回退
	if maxf(bounds.size.x, bounds.size.z) < target_span * 0.42:
		model.name = "JumpObstacleModelDiscard"
		model.queue_free()
		_add_jump_bar_procedural_fallback(root, target_height, target_span)
		return
	_add_ground_contact_shadow(root, target_span * 0.92, 0.9)


func _add_jump_bar_procedural_fallback(root: Node3D, target_height: float, target_span: float) -> void:
	var wall_path := RUNNER_OBS_LIGHT_JUMP_WALL
	var wall := _load_runner_scene(wall_path, false)
	if wall != null:
		_add_road_span_gate(root, "JumpObstacleModel", wall, target_height, target_span)
		root.set_meta("obstacle_asset_path", wall_path)
		return
	_add_wooden_fence_jump_visual(root, target_span, JUMP_BAR_HEIGHT)
	root.set_meta("obstacle_asset_path", "wood_fence_jump")

func _add_fence_rail_segment(
	parent: Node3D,
	x0: float,
	x1: float,
	y: float,
	h: float,
	depth: float,
	mat: StandardMaterial3D
) -> void:
	if absf(x1 - x0) < 0.06:
		return
	var rail := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(absf(x1 - x0), h, depth)
	mesh.material = mat
	rail.mesh = mesh
	rail.position = Vector3((x0 + x1) * 0.5, y, 0.0)
	rail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(rail)

func _add_wooden_fence_jump_visual(root: Node3D, span: float, target_height: float) -> void:
	var gate_root := Node3D.new()
	gate_root.name = "JumpObstacleModel"
	root.add_child(gate_root)
	var wood := _make_material(Color(0.46, 0.32, 0.20), Color(0.58, 0.40, 0.24), 0.18)
	var wood_dark := _make_material(Color(0.34, 0.23, 0.14), Color(0.48, 0.30, 0.18), 0.14)
	wood.roughness = 0.82
	wood_dark.roughness = 0.88
	var half := span * 0.5
	var stake_h := target_height * 1.08
	var stake_w := 0.13
	var stake_count := 6
	for i in range(stake_count):
		var t := float(i) / float(stake_count - 1)
		var sx := lerpf(-half * 0.95, half * 0.95, t)
		var lean := 0.0
		if i == 2:
			lean = 0.10
		elif i == 3:
			lean = -0.10
		var stake := MeshInstance3D.new()
		stake.name = "FenceStake_%d" % i
		var stake_mesh := BoxMesh.new()
		stake_mesh.size = Vector3(stake_w, stake_h, stake_w * 0.92)
		stake_mesh.material = wood if i % 2 == 0 else wood_dark
		stake.mesh = stake_mesh
		stake.position = Vector3(sx + lean * 0.08, stake_h * 0.5, lean * 0.06)
		stake.rotation.z = lean * 0.28
		stake.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		gate_root.add_child(stake)
		for diag in [-1.0, 1.0]:
			var spike := MeshInstance3D.new()
			var spike_mesh := BoxMesh.new()
			spike_mesh.size = Vector3(stake_w * 0.32, stake_h * 0.16, stake_w * 0.32)
			spike_mesh.material = wood_dark
			spike.mesh = spike_mesh
			spike.position = Vector3(sx + lean * 0.08, stake_h + stake_h * 0.05, lean * 0.06)
			spike.rotation.y = deg_to_rad(45.0) * diag
			spike.rotation.z = lean * 0.28
			gate_root.add_child(spike)
	var rail_h := 0.11
	var rail_depth := 0.14
	var gap_half := span * 0.11
	_add_fence_rail_segment(gate_root, -half * 0.96, half * 0.96, stake_h * 0.90, rail_h, rail_depth, wood)
	_add_fence_rail_segment(gate_root, -half * 0.96, -gap_half, stake_h * 0.56, rail_h, rail_depth, wood_dark)
	_add_fence_rail_segment(gate_root, gap_half, half * 0.96, stake_h * 0.56, rail_h, rail_depth, wood_dark)
	_add_fence_rail_segment(gate_root, -half * 0.96, half * 0.96, stake_h * 0.24, rail_h, rail_depth, wood)
	_add_ground_contact_shadow(root, span * 0.92, 0.9)

func _build_high_bar(root: Node3D, item: Dictionary = {}) -> void:
	if bool(item.get("low_slide", false)) or _is_reservoir_location():
		_build_low_slide_barrier(root, item)
		return
	var scene_index := _pick_slide_obstacle_scene_index(item)
	var asset_path := ""
	if scene_index < _slide_obstacle_paths.size():
		asset_path = _slide_obstacle_paths[scene_index]
		root.set_meta("obstacle_asset_path", asset_path)
	var span := _slide_gate_span_at(float(item.get("distance", 0.0)), asset_path)
	root.set_meta("obstacle_span", span)
	var scene := _get_slide_obstacle_scene(scene_index)
	if scene != null and not _is_color_block_obstacle_asset(asset_path):
		_add_road_span_gate(root, "SlideObstacleModel", scene, SLIDE_GATE_TOP, span)
		_apply_obstacle_visual_materials(root, "SlideObstacleModel", asset_path)
	else:
		_add_slide_gate_visual(root, span, SLIDE_GATE_TOP, SLIDE_GATE_OPEN_BOTTOM)


func _build_low_slide_barrier(root: Node3D, item: Dictionary = {}) -> void:
	# 低杆必须滑铲：水源只用废旧广告牌，其它据点优先锈管/尖刺
	root.set_meta("low_slide", true)
	root.set_meta("open_bottom", LOW_SLIDE_OPEN_BOTTOM)
	var span := _runway_obstacle_span_at(float(item.get("distance", 0.0)))
	root.set_meta("obstacle_span", span)
	var dist_key := int(float(item.get("distance", 0.0)))
	var asset_path := ""
	if _is_reservoir_location():
		asset_path = RESERVOIR_SLIDE_BILLBOARD
	else:
		var use_spike := (absi(dist_key) % 2) == 1
		var hints: Array = ["spike", "尖刺"] if use_spike else ["rusty", "pipeline", "rust", "pipe"]
		asset_path = _first_slide_asset_for_hints(hints)
	var scene := _load_runner_scene(asset_path, false) if asset_path != "" else null
	if scene != null and not _is_color_block_obstacle_asset(asset_path):
		root.set_meta("obstacle_asset_path", asset_path)
		_add_road_span_gate(root, "SlideObstacleModel", scene, LOW_SLIDE_BEAM_TOP, span)
		_apply_obstacle_visual_materials(root, "SlideObstacleModel", asset_path)
	else:
		root.set_meta("obstacle_asset_path", "low_slide_beam")
		_add_low_slide_beam_visual(root, span, LOW_SLIDE_OPEN_BOTTOM, LOW_SLIDE_BEAM_TOP)
	_add_ground_contact_shadow(root, span * 0.96, 0.55)


func _make_wave_energy_material(warm: Color, cool: Color, energy: float, alpha: float = 1.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(warm.r, warm.g, warm.b, alpha)
	mat.emission_enabled = true
	mat.emission = cool
	mat.emission_energy_multiplier = energy
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	if alpha < 0.99:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat


func _add_wave_arc_energy_arch(
	parent: Node3D,
	span: float,
	open_bottom: float,
	apex_y: float,
	axis: String = "x"
) -> Node3D:
	var gate_root := Node3D.new()
	gate_root.name = "WaveArcEnergyArch"
	parent.add_child(gate_root)
	var half := span * 0.47
	var segments := 14
	var tube_r := 0.09
	var arc_mat := _make_wave_energy_material(Color(0.95, 0.72, 0.32, 0.94), Color(1.0, 0.58, 0.18), 5.6, 0.92)
	for i in segments:
		var t0 := float(i) / float(segments)
		var t1 := float(i + 1) / float(segments)
		var a0 := lerpf(PI, 0.0, t0)
		var a1 := lerpf(PI, 0.0, t1)
		var p0 := Vector3(cos(a0) * half, open_bottom + sin(a0) * (apex_y - open_bottom), 0.0)
		var p1 := Vector3(cos(a1) * half, open_bottom + sin(a1) * (apex_y - open_bottom), 0.0)
		if axis == "z":
			p0 = Vector3(0.0, open_bottom + sin(a0) * (apex_y - open_bottom), cos(a0) * half)
			p1 = Vector3(0.0, open_bottom + sin(a1) * (apex_y - open_bottom), cos(a1) * half)
		var mid := (p0 + p1) * 0.5
		var seg := MeshInstance3D.new()
		var seg_mesh := CylinderMesh.new()
		seg_mesh.top_radius = tube_r
		seg_mesh.bottom_radius = tube_r
		seg_mesh.height = maxf(p0.distance_to(p1), 0.06)
		seg_mesh.radial_segments = 10
		seg_mesh.rings = 1
		seg_mesh.material = arc_mat
		seg.mesh = seg_mesh
		seg.material_override = arc_mat
		seg.position = mid
		seg.look_at(mid + (p1 - p0).normalized(), Vector3.UP)
		seg.rotate_object_local(Vector3.RIGHT, PI * 0.5)
		seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gate_root.add_child(seg)
	return gate_root


func _add_wave_arc_bridge_visual(
	parent: Node3D,
	span: float,
	open_bottom: float,
	apex_y: float,
	axis: String = "x"
) -> Node3D:
	var gate_root := Node3D.new()
	gate_root.name = "WaveArcBridgeModel"
	parent.add_child(gate_root)
	var half := span * 0.47
	var segments := 16
	var tube_w := 0.24 if axis == "x" else 0.2
	var tube_d := 0.18 if axis == "x" else 0.22
	var arc_mat := _make_wave_energy_material(Color(0.72, 0.32, 0.95, 0.88), Color(1.0, 0.58, 0.22), 4.2, 0.88)
	var base_mat := _make_material(Color(0.28, 0.3, 0.36), Color(0.55, 0.22, 0.92), 1.35)
	base_mat.metallic = 0.72
	base_mat.roughness = 0.38
	for side in [-1, 1]:
		var base := MeshInstance3D.new()
		var base_mesh := CylinderMesh.new()
		base_mesh.top_radius = 0.42
		base_mesh.bottom_radius = 0.48
		base_mesh.height = 0.28
		base_mesh.material = base_mat
		base.mesh = base_mesh
		if axis == "x":
			base.position = Vector3(side * half, open_bottom * 0.08, 0.0)
		else:
			base.position = Vector3(0.12, open_bottom * 0.08, side * half)
		base.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gate_root.add_child(base)
		for li in 4:
			var lamp := MeshInstance3D.new()
			var lamp_mesh := BoxMesh.new()
			lamp_mesh.size = Vector3(0.1, 0.06, 0.1)
			lamp_mesh.material = _make_wave_energy_material(Color(0.95, 0.72, 0.28), Color(1.0, 0.58, 0.16), 3.4)
			lamp.mesh = lamp_mesh
			var ang := float(li) / 4.0 * TAU
			lamp.position = base.position + Vector3(cos(ang) * 0.34, 0.1, sin(ang) * 0.34)
			lamp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			gate_root.add_child(lamp)
	for i in segments:
		var t0 := float(i) / float(segments)
		var t1 := float(i + 1) / float(segments)
		var a0 := lerpf(PI, 0.0, t0)
		var a1 := lerpf(PI, 0.0, t1)
		var p0 := Vector3(cos(a0) * half, open_bottom + sin(a0) * (apex_y - open_bottom), 0.0)
		var p1 := Vector3(cos(a1) * half, open_bottom + sin(a1) * (apex_y - open_bottom), 0.0)
		if axis == "z":
			p0 = Vector3(0.0, open_bottom + sin(a0) * (apex_y - open_bottom), cos(a0) * half)
			p1 = Vector3(0.0, open_bottom + sin(a1) * (apex_y - open_bottom), cos(a1) * half)
		var mid := (p0 + p1) * 0.5
		var seg := MeshInstance3D.new()
		var seg_mesh := BoxMesh.new()
		seg_mesh.size = Vector3(tube_w, tube_w, p0.distance_to(p1) + 0.04) if axis == "x" else Vector3(tube_d, tube_w, p0.distance_to(p1) + 0.04)
		seg_mesh.material = arc_mat
		seg.mesh = seg_mesh
		seg.material_override = arc_mat
		seg.position = mid
		if axis == "x":
			seg.look_at(mid + (p1 - p0).normalized(), Vector3.UP)
			seg.rotation.x = 0.0
		else:
			seg.look_at(mid + (p1 - p0).normalized(), Vector3.UP)
		seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gate_root.add_child(seg)
	var glow := MeshInstance3D.new()
	glow.name = "WaveArcGlow"
	var glow_mesh := BoxMesh.new()
	glow_mesh.size = Vector3(span * 0.72, apex_y - open_bottom, 0.08) if axis == "x" else Vector3(0.08, apex_y - open_bottom, span * 0.72)
	glow.mesh = glow_mesh
	glow.material_override = _make_wave_energy_material(Color(0.95, 0.62, 0.18, 0.24), Color(1.0, 0.72, 0.22), 1.8, 0.24)
	glow.position = Vector3(0.0, open_bottom + (apex_y - open_bottom) * 0.52, 0.0)
	if axis == "z":
		glow.position = Vector3(0.08, open_bottom + (apex_y - open_bottom) * 0.52, 0.0)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gate_root.add_child(glow)
	return gate_root


func _build_wave_arc_slide(root: Node3D, item: Dictionary) -> void:
	root.set_meta("obstacle_asset_path", "wave_arc_slide")
	root.set_meta("open_bottom", WAVE_ARC_OPEN_BOTTOM)
	root.set_meta("low_slide", true)
	root.set_meta("wave_arc_fx", true)
	var span := _runway_obstacle_span_at(float(item.get("distance", 0.0)))
	root.set_meta("obstacle_span", span)
	var layout_proc := _runner_layout_id() != ""
	var scene: PackedScene = null
	if not layout_proc:
		scene = _get_slide_obstacle_scene_by_hint(["能量屏障", "energy", "barrier"], 0)
		if scene == null:
			scene = _get_slide_obstacle_scene(_low_slide_obstacle_scene_index())
	var asset_path := ""
	if scene != null:
		for path in _slide_obstacle_paths:
			if _load_runner_scene(path, false) == scene:
				asset_path = String(path)
				break
	if scene != null:
		if asset_path != "":
			root.set_meta("obstacle_asset_path", asset_path)
		_add_road_span_gate(root, "SlideObstacleModel", scene, WAVE_ARC_APEX_Y, span)
		_apply_obstacle_visual_materials(root, "SlideObstacleModel", asset_path)
		if asset_path == "" or not _should_preserve_obstacle_materials(asset_path):
			_add_low_slide_holo_accents(root, span, WAVE_ARC_APEX_Y - 0.28)
	else:
		_add_slide_gate_visual(root, span, WAVE_ARC_APEX_Y, WAVE_ARC_OPEN_BOTTOM)
	_add_wave_arc_energy_arch(root, span, WAVE_ARC_OPEN_BOTTOM, WAVE_ARC_APEX_Y)
	_add_ground_contact_shadow(root, span * 0.94, 0.95)


func _build_wall_wave_arc_slide(root: Node3D, item: Dictionary) -> void:
	root.set_meta("wall_face_obstacle", true)
	root.set_meta("obstacle_asset_path", "wall_wave_arc_slide")
	root.set_meta("low_slide", true)
	root.set_meta("wave_arc_fx", true)
	var span := float(item.get("wall_span", WAVE_ARC_WALL_SPAN))
	var open_y := 0.42
	var apex_y := 1.72
	root.set_meta("open_bottom", open_y)
	_add_wave_arc_bridge_visual(root, span, open_y, apex_y, "z")


func _resolve_energy_ring_scene() -> PackedScene:
	for path in ENERGY_RING_SCENE_PATHS:
		var scene := _load_runner_scene(path, false)
		if scene != null:
			return scene
	return null

func _build_energy_ring(root: Node3D, item: Dictionary) -> void:
	root.set_meta("obstacle_asset_path", "energy_ring")
	root.set_meta("energy_ring_fx", true)
	var inner_r := float(item.get("ring_inner", 0.52))
	var outer_r := float(item.get("ring_outer", 1.02))
	root.set_meta("ring_center_y", GROUND_Y + ENERGY_RING_CENTER_Y)
	root.set_meta("ring_inner_half", inner_r * 0.48)
	root.set_meta("ring_inner_half_y", ENERGY_RING_INNER_HALF_Y * 0.72)
	root.set_meta("ring_outer_half", outer_r * 0.92)
	var model := Node3D.new()
	model.name = "EnergyRingModel"
	root.add_child(model)
	var scene := _resolve_energy_ring_scene()
	var used_glb := false
	if scene != null:
		var ring := scene.instantiate() as Node3D
		if ring != null:
			ring.name = "EnergyRingAsset"
			model.add_child(ring)
			var target := outer_r * 2.05
			var bounds := _compute_node_aabb(ring)
			if bounds.size.y > 0.001:
				var s := target / maxf(maxi(bounds.size.x, bounds.size.y), bounds.size.z)
				ring.scale = Vector3.ONE * s
				bounds = _compute_node_aabb(ring)
				ring.position = Vector3(
					-(bounds.position.x + bounds.size.x * 0.5),
					ENERGY_RING_CENTER_Y - (bounds.position.y + bounds.size.y * 0.5),
					-(bounds.position.z + bounds.size.z * 0.5)
				)
				for path in ENERGY_RING_SCENE_PATHS:
					if _load_runner_scene(path, false) == scene:
						root.set_meta("obstacle_asset_path", path)
						break
				used_glb = true
			else:
				ring.queue_free()
	if not used_glb:
		var torus := MeshInstance3D.new()
		var torus_mesh := TorusMesh.new()
		torus_mesh.inner_radius = inner_r
		torus_mesh.outer_radius = outer_r
		torus_mesh.rings = 28
		torus_mesh.ring_segments = 48
		var ring_mat := _make_wave_energy_material(Color(0.95, 0.72, 0.28, 0.94), Color(1.0, 0.58, 0.16), 5.2, 0.94)
		torus_mesh.material = ring_mat
		torus.mesh = torus_mesh
		torus.material_override = ring_mat
		torus.rotation_degrees.x = 90.0
		torus.position = Vector3(0.0, ENERGY_RING_CENTER_Y, 0.0)
		torus.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		model.add_child(torus)
		for i in 6:
			var bolt := MeshInstance3D.new()
			bolt.name = "EnergyRingBolt_%d" % i
			var bolt_mesh := BoxMesh.new()
			bolt_mesh.size = Vector3(0.06, 0.42 + float(i % 2) * 0.12, 0.06)
			bolt.mesh = bolt_mesh
			bolt.material_override = _make_wave_energy_material(Color(1.0, 0.92, 0.55), Color(1.0, 0.82, 0.35), 6.8)
			var ang := float(i) / 6.0 * TAU + 0.2
			bolt.position = Vector3(cos(ang) * (inner_r + outer_r) * 0.5, ENERGY_RING_CENTER_Y + sin(ang * 1.7) * 0.18, sin(ang) * (inner_r + outer_r) * 0.5)
			bolt.rotation_degrees = Vector3(0.0, rad_to_deg(ang), 28.0 if i % 2 == 0 else -22.0)
			bolt.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			model.add_child(bolt)
	_add_ground_contact_shadow(root, outer_r * 1.8, 1.05)
	_add_ground_contact_shadow(root, outer_r * 2.1, 0.82)


func _low_slide_obstacle_scene_index() -> int:
	for i in range(_slide_obstacle_paths.size()):
		var path := String(_slide_obstacle_paths[i])
		if "废旧广告牌" in path or "billboard" in path.to_lower():
			return i
	return 0 if not _slide_obstacle_paths.is_empty() else -1


func _add_low_slide_holo_accents(_root: Node3D, _span: float, _beam_y: float) -> void:
	# 不再铺发光色条，避免赛道上出现蓝色色块
	pass


func _rust_obstacle_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.38, 0.28, 0.22)
	mat.metallic = 0.62
	mat.roughness = 0.58
	mat.emission_enabled = false
	return mat


func _add_low_slide_beam_visual(root: Node3D, span: float, open_bottom: float, beam_top: float) -> Node3D:
	var gate_root := Node3D.new()
	gate_root.name = "SlideObstacleModel"
	root.add_child(gate_root)
	var half := span * 0.5
	var beam_h := maxf(beam_top - open_bottom, 1.15)
	var beam_center := open_bottom + beam_h * 0.5
	var rust := _rust_obstacle_material()
	for side in [-1, 1]:
		var pylon := MeshInstance3D.new()
		pylon.name = "LowSlidePylon_%d" % side
		var pylon_mesh := CylinderMesh.new()
		pylon_mesh.top_radius = 0.22
		pylon_mesh.bottom_radius = 0.28
		pylon_mesh.height = beam_top
		pylon_mesh.radial_segments = 10
		pylon.mesh = pylon_mesh
		pylon.material_override = rust
		pylon.position = Vector3(side * half * 0.96, beam_top * 0.5 - 0.02, 0.0)
		pylon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		gate_root.add_child(pylon)
	var beam := MeshInstance3D.new()
	beam.name = "LowSlideBeam"
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.26
	beam_mesh.bottom_radius = 0.26
	beam_mesh.height = span * 0.98
	beam_mesh.radial_segments = 12
	beam.mesh = beam_mesh
	beam.material_override = rust
	beam.rotation.z = PI * 0.5
	beam.position = Vector3(0.0, beam_center, 0.0)
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	gate_root.add_child(beam)
	var bar2 := MeshInstance3D.new()
	bar2.name = "LowSlideBeamUpper"
	var bar2_mesh := CylinderMesh.new()
	bar2_mesh.top_radius = 0.18
	bar2_mesh.bottom_radius = 0.18
	bar2_mesh.height = span * 0.96
	bar2_mesh.radial_segments = 10
	bar2.mesh = bar2_mesh
	bar2.material_override = rust
	bar2.rotation.z = PI * 0.5
	bar2.position = Vector3(0.0, minf(beam_top - 0.18, beam_center + 0.55), 0.0)
	gate_root.add_child(bar2)
	return gate_root


func _add_slide_gate_visual(root: Node3D, span: float, top_height: float, open_bottom: float) -> Node3D:
	var gate_root := Node3D.new()
	gate_root.name = "SlideObstacleModel"
	root.add_child(gate_root)
	var half_span := span * 0.5
	var pillar_h := maxf(top_height - open_bottom, 0.45)
	var pillar_center_y := open_bottom + pillar_h * 0.5
	var rust := _rust_obstacle_material()
	for side in [-1, 1]:
		var pillar := MeshInstance3D.new()
		pillar.name = "SlidePillar_%d" % side
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.16
		mesh.bottom_radius = 0.2
		mesh.height = pillar_h
		mesh.radial_segments = 10
		pillar.mesh = mesh
		pillar.material_override = rust
		pillar.position = Vector3(side * half_span, pillar_center_y, 0.0)
		gate_root.add_child(pillar)
	var beam := MeshInstance3D.new()
	beam.name = "SlideTopBeam"
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.14
	beam_mesh.bottom_radius = 0.14
	beam_mesh.height = span * 0.96
	beam_mesh.radial_segments = 10
	beam.mesh = beam_mesh
	beam.material_override = rust
	beam.rotation.z = PI * 0.5
	beam.position = Vector3(0.0, top_height - 0.13, 0.0)
	gate_root.add_child(beam)
	_add_ground_contact_shadow(root, span * 0.92, 1.0)
	return gate_root

func _add_slide_visibility_curtain(_root: Node3D) -> void:
	pass

func _apply_obstacle_hologram_material(root: Node3D, albedo: Color, emission: Color, energy: float) -> void:
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		if gi.mesh:
			for surface_idx in gi.mesh.get_surface_count():
				var src: Material = gi.get_surface_override_material(surface_idx)
				if src == null:
					src = gi.mesh.surface_get_material(surface_idx)
				if src == null:
					continue
				var tuned := _make_hologram_material_from(src, albedo, emission, energy)
				gi.set_surface_override_material(surface_idx, tuned)
		elif gi.material_override:
			gi.material_override = _make_hologram_material_from(gi.material_override, albedo, emission, energy)

func _is_glb_obstacle_asset(path: String) -> bool:
	var lower := String(path).to_lower().strip_edges()
	return lower.ends_with(".glb") or lower.ends_with(".gltf")

func _should_preserve_obstacle_materials(path: String) -> bool:
	if path == "" or path.begins_with("wood_fence"):
		return false
	if _is_glb_obstacle_asset(path):
		return true
	return _is_lightweight_obstacle_asset(path)

func _apply_obstacle_visual_materials(root: Node3D, model_name: String, asset_path: String) -> void:
	var model := root.get_node_or_null(model_name) as Node3D
	if model == null:
		return
	if _is_color_block_obstacle_asset(asset_path):
		return
	if _is_lightweight_jump_obstacle_asset(asset_path):
		_preserve_jump_wall_materials(model)
	elif _should_preserve_obstacle_materials(asset_path) or asset_path == "":
		_preserve_obstacle_materials(model)

func _preserve_jump_wall_materials(root: Node3D) -> void:
	# 断墙：严格保留 GLB 贴图/结晶分区，仅关雾 + 轻微中性提亮（不整片粉紫发光）
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		if gi.mesh:
			for surface_idx in gi.mesh.get_surface_count():
				var src: Material = gi.get_surface_override_material(surface_idx)
				if src == null:
					src = gi.mesh.surface_get_material(surface_idx)
				if src == null:
					continue
				gi.set_surface_override_material(
					surface_idx,
					_neutralize_jump_wall_material(src)
				)
		elif gi.material_override:
			gi.material_override = _neutralize_jump_wall_material(gi.material_override)

func _neutralize_jump_wall_material(src: Material) -> Material:
	if not src is StandardMaterial3D:
		if src is BaseMaterial3D:
			var generic := src.duplicate()
			(generic as BaseMaterial3D).disable_fog = true
			return generic
		return src
	var mat := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
	var base := mat.albedo_color
	# 中性提亮混凝土，不偏向蓝/紫
	mat.albedo_color = Color(
		clampf(base.r * 1.22 + 0.12, 0.40, 1.0),
		clampf(base.g * 1.22 + 0.12, 0.40, 1.0),
		clampf(base.b * 1.22 + 0.12, 0.40, 1.0)
	)
	mat.roughness = clampf(mat.roughness, 0.28, 0.95)
	mat.disable_fog = true
	# 仅保留模型自带的结晶 emission，禁止给整片 mesh 强加发光
	var had_emission := mat.emission_enabled and _color_rgb_energy(mat.emission) > 0.04
	var is_crystal := had_emission and base.b > base.r + 0.12 and base.b > 0.38
	if is_crystal:
		mat.emission_energy_multiplier = clampf(mat.emission_energy_multiplier * 1.35, 0.0, 2.2)
	else:
		# 暗色混凝土在沙漠路面上略提亮，避免「只剩一条地影/结晶点却照样撞」
		mat.emission_enabled = true
		mat.emission = Color(0.52, 0.48, 0.44)
		mat.emission_energy_multiplier = 0.42
	return mat

func _color_rgb_energy(color: Color) -> float:
	return color.r * color.r + color.g * color.g + color.b * color.b

func _preserve_obstacle_materials(root: Node3D) -> void:
	# GLB 障碍保留原 PBR 贴图/颜色，仅关雾避免被跑道环境洗色
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		if gi.mesh:
			for surface_idx in gi.mesh.get_surface_count():
				var src: Material = gi.get_surface_override_material(surface_idx)
				if src == null:
					src = gi.mesh.surface_get_material(surface_idx)
				if src == null:
					continue
				var mat := src.duplicate()
				if mat is BaseMaterial3D:
					(mat as BaseMaterial3D).disable_fog = true
				gi.set_surface_override_material(surface_idx, mat)
		elif gi.material_override:
			var mat := gi.material_override.duplicate()
			if mat is BaseMaterial3D:
				(mat as BaseMaterial3D).disable_fog = true
			gi.material_override = mat

func _apply_obstacle_runway_contrast(root: Node3D) -> void:
	# 暖色提亮，与青蓝全息跑道拉开层次
	var warm := Color(1.0, 0.78, 0.38)
	for node in root.find_children("*", "GeometryInstance3D", true, false):
		var gi := node as GeometryInstance3D
		if gi.mesh:
			for surface_idx in gi.mesh.get_surface_count():
				var src: Material = gi.get_surface_override_material(surface_idx)
				if src == null:
					src = gi.mesh.surface_get_material(surface_idx)
				if src == null:
					continue
				var tuned := _make_runway_contrast_material_from(src, warm)
				gi.set_surface_override_material(surface_idx, tuned)
		elif gi.material_override:
			gi.material_override = _make_runway_contrast_material_from(gi.material_override, warm)

func _make_runway_contrast_material_from(src: Material, warm: Color) -> Material:
	if not src is StandardMaterial3D:
		return src
	var mat := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
	var base := mat.albedo_color
	mat.albedo_color = Color(
		minf(base.r * 1.42 + 0.14, 1.0),
		minf(base.g * 1.28 + 0.1, 1.0),
		minf(base.b * 0.92 + 0.04, 1.0),
		1.0
	).lerp(warm, 0.18)
	mat.emission_enabled = true
	mat.emission = warm
	mat.emission_energy_multiplier = 0.55
	mat.metallic = minf(mat.metallic, 0.12)
	mat.roughness = clampf(mat.roughness * 0.82, 0.28, 0.78)
	mat.disable_fog = true
	return mat

func _make_hologram_material_from(src: Material, albedo: Color, emission: Color, energy: float) -> Material:
	if not src is StandardMaterial3D:
		return src
	var mat := (src as StandardMaterial3D).duplicate() as StandardMaterial3D
	mat.albedo_color = Color(albedo.r, albedo.g, albedo.b, 1.0)
	mat.emission_enabled = true
	mat.emission = emission
	mat.emission_energy_multiplier = energy
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.metallic = 0.15
	mat.roughness = 0.35
	mat.disable_fog = true
	return mat

func _add_road_span_gate(
	parent: Node3D,
	model_name: String,
	scene: PackedScene,
	target_height: float,
	target_span: float
) -> Node3D:
	# 全路横杆：立柱贴地、宽度略超跑道，视觉上像架在路面上的屏障
	if scene == null:
		return _add_missing_model_visual(parent, model_name, target_height, 0.0, Vector3.ZERO)

	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = Vector3.ZERO
	model.rotation_degrees = Vector3.ZERO

	var bounds := _compute_node_aabb(model)
	if bounds.size.y <= 0.001:
		push_warning("%s gate bounds invalid" % model_name)
		return model

	# 若模型更宽轴在 Z，转到横跨 X（路面横向）
	if bounds.size.z > bounds.size.x * 1.15:
		model.rotation_degrees.y = 90.0
		bounds = _compute_node_aabb(model)

	# X 拉满跨度，Y 控高度；避免均匀缩放被高度夹窄
	var sx := (target_span * 1.10) / maxf(bounds.size.x, 0.001)
	var sy := target_height / maxf(bounds.size.y, 0.001)
	model.scale = Vector3(sx, sy, sx)
	bounds = _compute_node_aabb(model)
	model.position = Vector3(
		-(bounds.position.x + bounds.size.x * 0.5),
		-bounds.position.y,
		-(bounds.position.z + bounds.size.z * 0.5)
	)
	# 立柱底座贴路肩，少压进跑道网格
	model.position.y -= 0.02
	_add_ground_contact_shadow(parent, bounds.size.x * 0.95, maxf(bounds.size.z, 1.1))
	return model

func _add_slide_obstacle_visual(parent: Node3D, model_name: String, local_position: Vector3, target_height: float) -> Node3D:
	# 列车/封道等仍用单车道道具缩放
	var height := clampf(target_height, 1.6, 2.4)
	var visual := _add_scaled_model_visual(
		parent,
		_get_slide_obstacle_scene(parent.get_index()),
		model_name,
		height,
		0.0,
		local_position
	)
	var bounds := _compute_node_aabb(visual)
	var max_span := LANE_WIDTH * 1.5
	var span := maxf(bounds.size.x, bounds.size.z)
	if span > max_span and span > 0.001:
		visual.scale *= max_span / span
		bounds = _compute_node_aabb(visual)
		visual.position = local_position + Vector3(
			-(bounds.position.x + bounds.size.x * 0.5),
			-bounds.position.y,
			-(bounds.position.z + bounds.size.z * 0.5)
		)
	_add_ground_contact_shadow(visual, minf(span, max_span), 1.0)
	return visual

func _build_ramp(root: Node3D, target_layer: int) -> void:
	var scene := _get_jump_obstacle_scene(1)
	if scene == null:
		scene = _get_jump_obstacle_scene(0)
	var visual := _add_scaled_model_visual(
		root,
		scene,
		"RampMarkerAsset",
		1.2,
		180.0,
		Vector3(0.0, 0.0, 0.0)
	)
	if visual == null:
		_add_procedural_ramp_visual(root, target_layer)
		return
	visual.rotation_degrees.x = -12.0


func _add_procedural_ramp_visual(root: Node3D, _target_layer: int) -> void:
	var body := MeshInstance3D.new()
	body.name = "RampMarkerAsset"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(LANE_WIDTH * 1.12, 0.18, 3.4)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.38, 0.48)
	mat.metallic = 0.28
	mat.roughness = 0.32
	mat.emission_enabled = true
	mat.emission = Color(0.22, 0.82, 0.98)
	mat.emission_energy_multiplier = 1.15
	body.mesh = mesh
	body.material_override = mat
	body.rotation_degrees.x = -12.0
	body.position = Vector3(0.0, 0.32, 0.0)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(body)

func _build_main_block(root: Node3D, item: Dictionary) -> void:
	var half_depth := float(item.get("half_depth", 8.0))
	var dist := float(item.get("distance", 0.0))
	var platform_cross := _main_block_cross_mode(item) == "platform"
	root.set_meta("main_block_platform_cross", platform_cross)
	if platform_cross:
		var kit: Dictionary = _road_style_kit if not _road_style_kit.is_empty() else _make_road_style_kit(_road_style_id)
		var line_mat: Material = kit.get("line", null)
		var sign := MeshInstance3D.new()
		sign.name = "MainBlockGate"
		var sign_mesh := BoxMesh.new()
		sign_mesh.size = Vector3(LANE_WIDTH * 2.8, 0.08, 0.55)
		var sign_mat := _lava_platform_road_material() if line_mat == null else line_mat.duplicate()
		sign.mesh = sign_mesh
		sign.material_override = sign_mat
		sign.position = Vector3(0.0, 0.06, half_depth - 1.4)
		sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(sign)
		return
	var _hd := half_depth
	var gate := MeshInstance3D.new()
	gate.name = "MainBlockGate"
	var gate_mesh := BoxMesh.new()
	gate_mesh.size = Vector3(LANE_WIDTH * 3.2, 0.22, 1.8)
	var gate_mat := _make_material(Color(0.95, 0.32, 0.12, 0.7), Color(1.0, 0.4, 0.1), 2.4)
	gate_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gate_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	gate_mesh.material = gate_mat
	gate.mesh = gate_mesh
	gate.position = Vector3(0.0, 0.12, 0.0)
	root.add_child(gate)

	var post_l := MeshInstance3D.new()
	var post_r := MeshInstance3D.new()
	for post in [post_l, post_r]:
		var pm := BoxMesh.new()
		pm.size = Vector3(0.28, 2.4, 0.28)
		var pmat := _make_material(Color(0.9, 0.35, 0.12), Color(1.0, 0.45, 0.15), 1.8)
		pm.material = pmat
		post.mesh = pm
		post.position = Vector3(0.0, 1.2, 0.0)
		root.add_child(post)
	post_l.position.x = -LANE_WIDTH * 1.45
	post_r.position.x = LANE_WIDTH * 1.45

	var beam := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(LANE_WIDTH * 3.0, 0.22, 0.22)
	var bmat := _make_material(Color(1.0, 0.4, 0.15), Color(1.0, 0.5, 0.2), 2.0)
	bm.material = bmat
	beam.mesh = bm
	beam.position = Vector3(0.0, 2.35, 0.0)
	root.add_child(beam)
	_add_ground_contact_shadow(root, LANE_WIDTH * 3.0, 1.2)

func _build_turn_sign(root: Node3D, turn_type: String) -> void:
	# 不再用跳跃模型冒充门：左 REGULAR / 右 SPEEDUP 的轻量路标
	var is_left := turn_type == "turn_left"
	var accent := Color(0.28, 0.9, 0.7) if is_left else Color(0.55, 0.76, 0.92)
	var tag := "REGULAR" if is_left else "SPEEDUP"
	var mat := _make_material(accent * 0.4, accent, 0.95)
	for sx in [-1.0, 1.0]:
		var pillar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.18, 2.2, 0.18)
		pillar.mesh = box
		pillar.material_override = mat
		pillar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		pillar.position = Vector3(sx * 0.85, 1.1, 0.0)
		root.add_child(pillar)
	var beam := MeshInstance3D.new()
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(1.9, 0.16, 0.16)
	beam.mesh = beam_mesh
	beam.material_override = mat
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	beam.position = Vector3(0.0, 2.15, 0.0)
	root.add_child(beam)
	var tip := Label3D.new()
	tip.text = "%s\n%s" % [tag, ("← 安全" if is_left else "飞驰 →")]
	tip.font_size = 48
	tip.modulate = Color(0.94, 0.97, 1.0, 1.0) if not is_left else accent.lightened(0.15)
	tip.outline_size = 16
	tip.outline_modulate = Color(0.08, 0.18, 0.36, 1.0) if not is_left else Color(0.0, 0.12, 0.1, 0.98)
	tip.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tip.position = Vector3(0.0, 2.65, 0.0)
	root.add_child(tip)
	var pad := MeshInstance3D.new()
	var pad_mesh := BoxMesh.new()
	pad_mesh.size = Vector3(1.4, 0.04, 1.8)
	pad.mesh = pad_mesh
	pad.material_override = _make_material(accent * 0.4, accent, 0.7)
	pad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pad.position = Vector3(0.0, 0.04, 0.0)
	root.add_child(pad)

func _make_collectible(lane: int, distance: float, y: float, layer: int, fork_side: int = 0) -> Node3D:
	var collectible := Node3D.new()
	collectible.name = "EmberCoin"
	var coin_scale := 1.08
	var body_r := 0.36
	var body_h := 0.092
	var rim_in := 0.33
	var rim_out := 0.42
	var body_segments := 20
	var rim_rings := 8
	var rim_segments := 20

	var body := MeshInstance3D.new()
	body.name = "CoinBody"
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = body_r
	body_mesh.bottom_radius = body_r
	body_mesh.height = body_h
	body_mesh.radial_segments = body_segments
	body_mesh.material = _make_coin_face_material(true)
	body.mesh = body_mesh
	body.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	collectible.add_child(body)

	var rim := MeshInstance3D.new()
	rim.name = "CoinRim"
	var rim_mesh := TorusMesh.new()
	rim_mesh.inner_radius = rim_in
	rim_mesh.outer_radius = rim_out
	rim_mesh.rings = rim_rings
	rim_mesh.ring_segments = rim_segments
	rim_mesh.material = _make_coin_rim_material(true)
	rim.mesh = rim_mesh
	rim.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	collectible.add_child(rim)

	var emboss := MeshInstance3D.new()
	emboss.name = "CoinEmboss"
	var emboss_mesh := CylinderMesh.new()
	emboss_mesh.top_radius = body_r * 0.52
	emboss_mesh.bottom_radius = body_r * 0.52
	emboss_mesh.height = 0.034
	emboss_mesh.radial_segments = 16
	emboss_mesh.material = _make_coin_emboss_material(true)
	emboss.mesh = emboss_mesh
	emboss.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	emboss.position = Vector3(0.0, 0.0, body_h * 0.55)
	collectible.add_child(emboss)

	var glow := MeshInstance3D.new()
	glow.name = "CoinGlow"
	var glow_mesh := TorusMesh.new()
	glow_mesh.inner_radius = rim_out * 0.90
	glow_mesh.outer_radius = rim_out * 1.10
	glow_mesh.rings = 6
	glow_mesh.ring_segments = 16
	var glow_mat := StandardMaterial3D.new()
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color = Color(1.0, 0.82, 0.22, 0.10)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1.0, 0.68, 0.10)
	glow_mat.emission_energy_multiplier = 0.75
	glow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	glow_mesh.material = glow_mat
	glow.mesh = glow_mesh
	glow.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	collectible.add_child(glow)

	collectible.scale = Vector3(coin_scale, coin_scale, coin_scale)
	track_root.add_child(collectible)
	var placed: Dictionary
	if layer == WALL_RUN_LAYER:
		placed = _world_on_path(distance, 0.0, y, WALL_RUN_LAYER)
	elif fork_side != 0:
		placed = _world_on_path_forced_fork(distance, float(lane) * LANE_WIDTH, y, layer, fork_side)
	else:
		placed = _world_on_path(distance, float(lane) * LANE_WIDTH, y, layer)
	collectible.position = placed["pos"]
	collectible.rotation.y = float(placed["yaw"])
	return collectible


func _make_coin_face_material(w1_rich: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.92, 0.68, 0.12) if w1_rich else Color(0.88, 0.64, 0.10)
	mat.metallic = 0.96
	mat.roughness = 0.24 if w1_rich else 0.28
	mat.metallic_specular = 0.88
	mat.emission_enabled = true
	mat.emission = Color(0.85, 0.48, 0.04)
	mat.emission_energy_multiplier = 0.06 if w1_rich else 0.04
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.82 if w1_rich else 0.68
	mat.clearcoat_roughness = 0.08
	mat.rim_enabled = w1_rich
	mat.rim = 0.55 if w1_rich else 0.0
	mat.rim_tint = 0.22
	return mat


func _make_coin_rim_material(w1_rich: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.82, 0.54, 0.04) if w1_rich else Color(0.78, 0.52, 0.06)
	mat.metallic = 1.0
	mat.roughness = 0.18 if w1_rich else 0.28
	mat.metallic_specular = 0.92
	mat.emission_enabled = true
	mat.emission = Color(0.98, 0.48, 0.03)
	mat.emission_energy_multiplier = 0.05 if w1_rich else 0.03
	return mat


func _make_coin_emboss_material(w1_rich: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.92, 0.38) if w1_rich else Color(1.0, 0.88, 0.32)
	mat.metallic = 0.98
	mat.roughness = 0.12
	mat.metallic_specular = 1.0
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.78, 0.18)
	mat.emission_energy_multiplier = 0.07 if w1_rich else 0.04
	return mat

func _make_shield_crystal(
	lane: int,
	distance: float,
	y: float,
	layer: int,
	fork_side: int = 0,
	gate_visual: bool = false
) -> Node3D:
	var root := Node3D.new()
	root.name = "ShieldCrystal"
	var crystal := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.72, 1.35, 0.72)
	var mat := _make_material(Color(0.48, 0.92, 1.0, 0.62), Color(0.42, 0.95, 1.0), 5.2)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	prism.material = mat
	crystal.mesh = prism
	crystal.position.y = 0.68
	root.add_child(crystal)
	var glow := MeshInstance3D.new()
	var glow_mesh := SphereMesh.new()
	glow_mesh.radius = 0.52
	glow_mesh.height = 1.04
	var glow_mat := _make_material(Color(0.55, 0.94, 1.0, 0.28), Color(0.50, 0.92, 1.0), 3.6)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_mesh.material = glow_mat
	glow.mesh = glow_mesh
	glow.position.y = 0.68
	root.add_child(glow)
	if gate_visual:
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.42
		torus.outer_radius = 0.52
		torus.rings = 6
		torus.ring_segments = 24
		var ring_mat := _make_material(Color(0.62, 0.96, 1.0, 0.35), Color(0.75, 0.98, 1.0), 2.2)
		(ring_mat as StandardMaterial3D).transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		(ring_mat as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		torus.material = ring_mat
		ring.mesh = torus
		ring.rotation.x = PI * 0.5
		ring.position.y = 0.12
		root.add_child(ring)
	if gate_visual:
		return root
	track_root.add_child(root)
	var placed: Dictionary = _world_on_path_forced_fork(distance, float(lane) * LANE_WIDTH, y, layer, fork_side)
	root.position = placed["pos"]
	root.rotation.y = float(placed["yaw"])
	return root

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	_letterbox_left = ColorRect.new()
	_letterbox_left.name = "RunnerLetterboxLeft"
	_letterbox_left.color = Color(0.02, 0.018, 0.014)
	_letterbox_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_letterbox_left.visible = false
	ui.add_child(_letterbox_left)

	_letterbox_right = ColorRect.new()
	_letterbox_right.name = "RunnerLetterboxRight"
	_letterbox_right.color = Color(0.02, 0.018, 0.014)
	_letterbox_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_letterbox_right.visible = false
	ui.add_child(_letterbox_right)

	var frame := AspectRatioContainer.new()
	frame.name = "RunnerMobileFrame"
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.stretch_mode = AspectRatioContainer.STRETCH_FIT
	frame.ratio = MOBILE_VIEWPORT_SIZE.x / MOBILE_VIEWPORT_SIZE.y
	frame.alignment_horizontal = AspectRatioContainer.ALIGNMENT_CENTER
	frame.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER
	ui.add_child(frame)

	var shell := Control.new()
	shell.name = "RunnerMobileShell"
	shell.custom_minimum_size = MOBILE_VIEWPORT_SIZE
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(shell)
	hud_root = shell

	_settlement_horizon_layer = SettlementHorizonLayer.new()
	_settlement_horizon_layer.name = "SettlementHorizon"
	_settlement_horizon_layer.visible = false
	_settlement_horizon_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_settlement_horizon_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settlement_horizon_layer.z_index = 30
	shell.add_child(_settlement_horizon_layer)
	shell.resized.connect(_sync_settlement_horizon_layout)

	_settlement_horizon_header = SettlementHorizonHeader.new()
	_settlement_horizon_header.name = "SettlementHorizonHeader"
	_settlement_horizon_header.visible = false
	_settlement_horizon_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_settlement_horizon_header.z_index = 55
	shell.add_child(_settlement_horizon_header)

	_state_wrap = MarginContainer.new()
	_state_wrap.name = "StateWrap"
	_state_wrap.set_anchors_preset(Control.PRESET_FULL_RECT)
	_state_wrap.add_theme_constant_override("margin_left", 28)
	_state_wrap.add_theme_constant_override("margin_right", 28)
	_state_wrap.add_theme_constant_override("margin_top", 0)
	_state_wrap.add_theme_constant_override("margin_bottom", 20)
	_state_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_state_wrap.z_index = 50
	_state_wrap.visible = false
	_state_wrap.process_mode = Node.PROCESS_MODE_ALWAYS
	shell.add_child(_state_wrap)

	_state_outer = VBoxContainer.new()
	_state_outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_state_outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_state_outer.add_theme_constant_override("separation", 12)
	_state_outer.mouse_filter = Control.MOUSE_FILTER_PASS
	_state_wrap.add_child(_state_outer)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	shell.add_child(margin)

	var root := VBoxContainer.new()
	margin.add_child(root)
	debug_hud_box = root
	debug_hud_box.visible = false

	time_label = Label.new()
	speed_label = Label.new()
	collectible_label = Label.new()
	layer_label = Label.new()
	phase_label = Label.new()
	score_label = Label.new()
	cargo_icon = TextureRect.new()
	cargo_icon.custom_minimum_size = Vector2(52, 52)
	cargo_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cargo_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cargo_icon.visible = false
	chase_label = Label.new()
	for label in [time_label, speed_label, phase_label, score_label, layer_label, chase_label, collectible_label]:
		label.add_theme_font_size_override("font_size", 26)
		root.add_child(label)

	chase_bar = ProgressBar.new()
	chase_bar.custom_minimum_size = Vector2(0, 22)
	chase_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chase_bar.max_value = CHASER_MAX_DISTANCE
	chase_bar.value = CHASER_START_DISTANCE
	chase_bar.show_percentage = false
	root.add_child(chase_bar)

	strike_toast_label = Label.new()
	strike_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	strike_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	strike_toast_label.add_theme_font_size_override("font_size", 22)
	strike_toast_label.modulate = Color(1, 1, 1, 0)
	strike_toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(strike_toast_label)
	# 横跨画幅顶部居中；勿用 CENTER_TOP 零尺寸锚点（会粘在左上角）
	strike_toast_label.anchor_left = 0.06
	strike_toast_label.anchor_right = 0.94
	strike_toast_label.anchor_top = 0.0
	strike_toast_label.anchor_bottom = 0.0
	strike_toast_label.offset_left = 0.0
	strike_toast_label.offset_right = 0.0
	strike_toast_label.offset_top = 118.0
	strike_toast_label.offset_bottom = 168.0

	danger_vignette = ColorRect.new()
	danger_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	danger_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	danger_vignette.color = Color(0.45, 0.1, 0.04, 0.0)
	danger_vignette.visible = _chaser_enabled
	ui.add_child(danger_vignette)

	_coin_screen_flash = ColorRect.new()
	_coin_screen_flash.name = "CoinScreenFlash"
	_coin_screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_coin_screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_coin_screen_flash.color = Color(1.0, 0.88, 0.35, 0.0)
	_coin_screen_flash.visible = false
	_coin_screen_flash.z_index = 77
	shell.add_child(_coin_screen_flash)

	_coin_pickup_screen_fx = CoinPickupScreenFx.new()
	_coin_pickup_screen_fx.name = "CoinPickupScreenFx"
	shell.add_child(_coin_pickup_screen_fx)
	_build_sky_cheer_root()

	var chaser_hint_wrap := MarginContainer.new()
	chaser_hint_wrap.name = "ChaserHintWrap"
	chaser_hint_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chaser_hint_wrap.z_index = 28
	# 左上、顶栏下方：避免被右上货物/按钮遮住
	chaser_hint_wrap.set_anchors_preset(Control.PRESET_TOP_LEFT)
	chaser_hint_wrap.offset_left = 14.0
	chaser_hint_wrap.offset_top = 96.0
	chaser_hint_wrap.offset_right = 214.0
	chaser_hint_wrap.offset_bottom = 230.0
	chaser_hint_wrap.visible = false
	shell.add_child(chaser_hint_wrap)
	self.chaser_hint_wrap = chaser_hint_wrap

	chaser_hint_panel = PanelContainer.new()
	chaser_hint_panel.custom_minimum_size = Vector2(190, 118)
	var chaser_hint_style := StyleBoxFlat.new()
	chaser_hint_style.bg_color = Color(0.04, 0.05, 0.12, 0.94)
	chaser_hint_style.border_color = Color(0.78, 0.42, 1.0, 0.95)
	chaser_hint_style.set_border_width_all(2)
	chaser_hint_style.set_corner_radius_all(12)
	chaser_hint_style.content_margin_left = 12
	chaser_hint_style.content_margin_right = 12
	chaser_hint_style.content_margin_top = 10
	chaser_hint_style.content_margin_bottom = 10
	chaser_hint_panel.add_theme_stylebox_override("panel", chaser_hint_style)
	chaser_hint_wrap.add_child(chaser_hint_panel)

	var hint_box := VBoxContainer.new()
	hint_box.alignment = BoxContainer.ALIGNMENT_CENTER
	hint_box.add_theme_constant_override("separation", 4)
	chaser_hint_panel.add_child(hint_box)

	chaser_hint_label = Label.new()
	chaser_hint_label.text = "身后追击"
	chaser_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chaser_hint_label.add_theme_font_size_override("font_size", 16)
	chaser_hint_label.add_theme_color_override("font_color", Color(0.92, 0.94, 0.98))
	hint_box.add_child(chaser_hint_label)

	var hint_dist := Label.new()
	hint_dist.name = "ChaserHintDistance"
	hint_dist.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_dist.add_theme_font_size_override("font_size", 30)
	hint_dist.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
	hint_box.add_child(hint_dist)

	_chaser_hint_bar = ProgressBar.new()
	_chaser_hint_bar.name = "ChaserHintBar"
	_chaser_hint_bar.custom_minimum_size = Vector2(0, 12)
	_chaser_hint_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chaser_hint_bar.max_value = 100.0
	_chaser_hint_bar.value = 0.0
	_chaser_hint_bar.show_percentage = false
	hint_box.add_child(_chaser_hint_bar)

	var hint_sub := Label.new()
	hint_sub.name = "ChaserHintSub"
	hint_sub.text = LevelConfig.CHASER_NAME
	hint_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_sub.add_theme_font_size_override("font_size", 13)
	hint_sub.add_theme_color_override("font_color", Color(0.78, 0.82, 0.92))
	hint_box.add_child(hint_sub)

	state_panel = PanelContainer.new()
	state_panel.visible = true
	state_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	state_panel.custom_minimum_size = Vector2(0, 0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.09, 0.16, 0.86)
	panel_style.border_color = Color(0.48, 0.78, 0.98, 0.62)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(16)
	panel_style.content_margin_left = 18
	panel_style.content_margin_right = 18
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 16
	state_panel.add_theme_stylebox_override("panel", panel_style)
	_state_outer.add_child(state_panel)

	var state_margin := MarginContainer.new()
	state_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	state_margin.mouse_filter = Control.MOUSE_FILTER_PASS
	state_margin.add_theme_constant_override("margin_left", 8)
	state_margin.add_theme_constant_override("margin_right", 8)
	state_margin.add_theme_constant_override("margin_top", 8)
	state_margin.add_theme_constant_override("margin_bottom", 8)
	state_panel.add_child(state_margin)

	var state_box := VBoxContainer.new()
	_state_box = state_box
	state_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	state_box.alignment = BoxContainer.ALIGNMENT_CENTER
	state_box.add_theme_constant_override("separation", 10)
	state_margin.add_child(state_box)

	state_title = Label.new()
	state_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_title.add_theme_font_size_override("font_size", 34)
	state_title.add_theme_color_override("font_color", Color(0.98, 0.82, 0.45))
	state_title.visible = false
	state_box.add_child(state_title)

	state_body = Label.new()
	state_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_body.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	state_body.custom_minimum_size = Vector2(0, 0)
	state_body.add_theme_font_size_override("font_size", 24)
	state_body.add_theme_color_override("font_color", SETTLEMENT_BODY_COLOR)
	state_body.add_theme_constant_override("line_spacing", 12)
	state_box.add_child(state_body)

	_state_panel_spacer = Control.new()
	_state_panel_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_state_panel_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_state_panel_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_state_panel_spacer.visible = false
	state_box.add_child(_state_panel_spacer)

	_state_button_row = VBoxContainer.new()
	_state_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_state_button_row.size_flags_vertical = Control.SIZE_SHRINK_END
	_state_button_row.add_theme_constant_override("separation", 14)
	_state_button_row.mouse_filter = Control.MOUSE_FILTER_PASS
	state_box.add_child(_state_button_row)

	state_restart_button = Button.new()
	state_restart_button.text = "CONTINUE RUN"
	state_restart_button.custom_minimum_size = Vector2(0, 60)
	state_restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_restart_button.add_theme_font_size_override("font_size", 24)
	state_restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	state_restart_button.pressed.connect(_restart_run)
	state_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_settlement_button_style(state_restart_button, SETTLEMENT_BUTTON_BG, SETTLEMENT_BUTTON_BORDER)
	_state_button_row.add_child(state_restart_button)

	state_back_button = Button.new()
	state_back_button.text = "BACK TO MAP"
	state_back_button.custom_minimum_size = Vector2(0, 60)
	state_back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_back_button.add_theme_font_size_override("font_size", 24)
	state_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
	state_back_button.mouse_filter = Control.MOUSE_FILTER_STOP
	state_back_button.pressed.connect(_on_state_back_pressed)
	_apply_settlement_button_style(state_back_button, SETTLEMENT_BUTTON_BG, SETTLEMENT_BUTTON_BORDER)
	_state_button_row.add_child(state_back_button)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(center)

	intro_panel = PanelContainer.new()
	intro_panel.custom_minimum_size = Vector2(680, 300)
	var intro_style := StyleBoxFlat.new()
	intro_style.bg_color = Color(0.04, 0.08, 0.14, 0.84)
	intro_style.border_color = Color(0.55, 0.88, 1.0, 0.58)
	intro_style.set_border_width_all(2)
	intro_style.set_corner_radius_all(16)
	intro_style.content_margin_left = 28
	intro_style.content_margin_right = 28
	intro_style.content_margin_top = 22
	intro_style.content_margin_bottom = 22
	intro_panel.add_theme_stylebox_override("panel", intro_style)
	center.add_child(intro_panel)

	var intro_box := VBoxContainer.new()
	intro_box.alignment = BoxContainer.ALIGNMENT_CENTER
	intro_panel.add_child(intro_box)

	intro_title = Label.new()
	intro_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_title.add_theme_font_size_override("font_size", 56)
	intro_title.add_theme_color_override("font_color", Color(1.0, 0.98, 0.94))
	intro_title.add_theme_color_override("font_outline_color", Color(0.04, 0.08, 0.14, 0.9))
	intro_title.add_theme_constant_override("outline_size", 6)
	intro_box.add_child(intro_title)

	intro_body = Label.new()
	intro_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_body.custom_minimum_size = Vector2(680, 0)
	intro_body.add_theme_font_size_override("font_size", 28)
	intro_body.add_theme_color_override("font_color", Color(0.96, 0.94, 0.90))
	intro_body.add_theme_color_override("font_outline_color", Color(0.04, 0.08, 0.14, 0.85))
	intro_body.add_theme_constant_override("outline_size", 4)
	intro_box.add_child(intro_body)
	intro_panel.visible = true

	_wall_tut_panel = PanelContainer.new()
	_wall_tut_panel.name = "WallRunTutorialPanel"
	_wall_tut_panel.visible = false
	_wall_tut_panel.custom_minimum_size = Vector2(720, 260)
	_wall_tut_panel.set_anchors_preset(Control.PRESET_CENTER)
	_wall_tut_panel.offset_left = -360.0
	_wall_tut_panel.offset_right = 360.0
	_wall_tut_panel.offset_top = -140.0
	_wall_tut_panel.offset_bottom = 140.0
	var tut_style := StyleBoxFlat.new()
	tut_style.bg_color = Color(0.05, 0.08, 0.14, 0.92)
	tut_style.set_border_width_all(3)
	tut_style.border_color = Color(0.4, 0.98, 0.82, 0.9)
	tut_style.set_corner_radius_all(18)
	tut_style.content_margin_left = 28
	tut_style.content_margin_right = 28
	tut_style.content_margin_top = 22
	tut_style.content_margin_bottom = 22
	_wall_tut_panel.add_theme_stylebox_override("panel", tut_style)
	center.add_child(_wall_tut_panel)
	var tut_box := VBoxContainer.new()
	tut_box.add_theme_constant_override("separation", 14)
	_wall_tut_panel.add_child(tut_box)
	_wall_tut_title = Label.new()
	_wall_tut_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wall_tut_title.add_theme_font_size_override("font_size", 44)
	_wall_tut_title.modulate = Color(0.5, 1.0, 0.88)
	tut_box.add_child(_wall_tut_title)
	_wall_tut_body = Label.new()
	_wall_tut_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wall_tut_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_wall_tut_body.custom_minimum_size = Vector2(640, 0)
	_wall_tut_body.add_theme_font_size_override("font_size", 34)
	tut_box.add_child(_wall_tut_body)

	pause_button = Button.new()
	pause_button.text = "Ⅱ"
	pause_button.custom_minimum_size = Vector2(72, 72)
	pause_button.add_theme_font_size_override("font_size", 28)
	pause_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	pause_button.offset_left = 24.0
	pause_button.offset_top = 24.0
	pause_button.offset_right = 96.0
	pause_button.offset_bottom = 96.0
	pause_button.pressed.connect(_on_pause_button_pressed)
	shell.add_child(pause_button)

	shield_button = Button.new()
	shield_button.text = "盾"
	shield_button.tooltip_text = "防护罩 (F)"
	shield_button.custom_minimum_size = Vector2(72, 72)
	shield_button.add_theme_font_size_override("font_size", 26)
	shield_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	shield_button.offset_left = 24.0
	shield_button.offset_top = 108.0
	shield_button.offset_right = 96.0
	shield_button.offset_bottom = 180.0
	shield_button.pressed.connect(_toggle_shield)
	shell.add_child(shield_button)

	_build_top_status_hud(shell)
	_build_emergency_timer_banner(shell)

func _build_emergency_timer_banner(parent: Control) -> void:
	if not _is_emergency_run:
		return
	_run_timer_label = Label.new()
	_run_timer_label.name = "EmergencyRunTimer"
	_run_timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_run_timer_label.z_index = 48
	_run_timer_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_run_timer_label.offset_left = 0.0
	_run_timer_label.offset_top = 6.0
	_run_timer_label.offset_right = 0.0
	_run_timer_label.offset_bottom = 58.0
	_run_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_run_timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_buff_label(_run_timer_label, 42, Color(1.0, 0.84, 0.38), 6)
	_run_timer_label.text = "限时 %0.1fs" % _run_time
	_run_timer_label.visible = true
	parent.add_child(_run_timer_label)

func _style_buff_label(label: Label, font_size: int, color: Color, outline_size: int = 3) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.01, 0.03, 0.06, 0.98))
	label.add_theme_constant_override("outline_size", outline_size)


func _make_status_panel_style(accent: Color) -> StyleBoxFlat:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.05, 0.09, 0.94)
	panel_style.border_color = accent
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	panel_style.shadow_size = 10
	panel_style.content_margin_left = 12
	panel_style.content_margin_right = 12
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	return panel_style


func _top_status_panel_height() -> float:
	return 184.0 if _is_emergency_run else 92.0


func _make_buff_bar_style(fill: Color, _track: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(6)
	return style


func _build_top_status_hud(parent: Control) -> void:
	_top_hud_wrap = MarginContainer.new()
	_top_hud_wrap.name = "TopStatusHud"
	_top_hud_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_hud_wrap.z_index = 12
	_top_hud_wrap.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_top_hud_wrap.offset_left = 108.0
	var hud_top := 64.0 if _is_emergency_run else 10.0
	_top_hud_wrap.offset_top = hud_top
	_top_hud_wrap.offset_right = -14.0
	var panel_h := _top_status_panel_height()
	_top_hud_wrap.offset_bottom = hud_top + panel_h
	parent.add_child(_top_hud_wrap)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_top_hud_wrap.add_child(row)

	_build_buff_hud(row)
	_build_cargo_hud(row)


func _build_buff_hud(parent: Control) -> void:
	_buff_hud_panel = PanelContainer.new()
	_buff_hud_panel.name = "BuffHudPanel"
	_buff_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buff_hud_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buff_hud_panel.size_flags_stretch_ratio = 1.08
	_buff_hud_panel.custom_minimum_size = Vector2(320.0, _top_status_panel_height())
	parent.add_child(_buff_hud_panel)
	_buff_hud_panel.add_theme_stylebox_override(
		"panel",
		_make_status_panel_style(Color(0.52, 0.82, 0.96, 0.72))
	)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buff_hud_panel.add_child(root)

	var buff_title := Label.new()
	buff_title.text = "增益状态"
	_style_buff_label(buff_title, 20, Color(0.78, 0.90, 1.0), 3)
	root.add_child(buff_title)

	var shield_row := HBoxContainer.new()
	shield_row.add_theme_constant_override("separation", 10)
	shield_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shield_row)

	var shield_icon_wrap := PanelContainer.new()
	shield_icon_wrap.custom_minimum_size = Vector2(58, 58)
	shield_icon_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shield_icon_style := StyleBoxFlat.new()
	shield_icon_style.bg_color = Color(0.05, 0.10, 0.16, 0.92)
	shield_icon_style.border_color = Color(0.35, 0.58, 0.82, 0.65)
	shield_icon_style.set_border_width_all(1)
	shield_icon_style.set_corner_radius_all(10)
	shield_icon_style.content_margin_left = 4
	shield_icon_style.content_margin_right = 4
	shield_icon_style.content_margin_top = 4
	shield_icon_style.content_margin_bottom = 4
	shield_icon_wrap.add_theme_stylebox_override("panel", shield_icon_style)
	shield_row.add_child(shield_icon_wrap)
	var shield_icon_label := Label.new()
	shield_icon_label.text = "盾"
	shield_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shield_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_buff_label(shield_icon_label, 26, Color(0.82, 0.96, 1.0))
	shield_icon_wrap.add_child(shield_icon_label)

	var shield_text_col := VBoxContainer.new()
	shield_text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shield_text_col.add_theme_constant_override("separation", 2)
	shield_text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shield_row.add_child(shield_text_col)

	var shield_head := HBoxContainer.new()
	shield_head.add_theme_constant_override("separation", 8)
	shield_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shield_text_col.add_child(shield_head)

	var shield_title := Label.new()
	shield_title.text = "防护罩"
	_style_buff_label(shield_title, 22, Color(0.95, 0.98, 1.0))
	shield_head.add_child(shield_title)

	shield_label = Label.new()
	shield_label.text = "关闭 · F/盾键开启"
	shield_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_buff_label(shield_label, 18, Color(0.72, 0.84, 0.94), 2)
	shield_head.add_child(shield_label)

	_shield_energy_label = Label.new()
	_shield_energy_label.text = "%d/%d" % [int(round(shield_energy)), int(SHIELD_MAX_ENERGY)]
	_style_buff_label(_shield_energy_label, 20, Color(0.55, 0.95, 1.0))
	shield_head.add_child(_shield_energy_label)

	shield_bar = ProgressBar.new()
	shield_bar.custom_minimum_size = Vector2(0, 20)
	shield_bar.max_value = SHIELD_MAX_ENERGY
	shield_bar.value = shield_energy
	shield_bar.show_percentage = false
	shield_bar.add_theme_stylebox_override("fill", _make_buff_bar_style(Color(0.35, 0.88, 1.0), Color(0.12, 0.20, 0.28)))
	shield_bar.add_theme_stylebox_override("background", _make_buff_bar_style(Color(0.10, 0.14, 0.20, 0.95), Color(0.10, 0.14, 0.20)))
	shield_text_col.add_child(shield_bar)

	var boost_divider := ColorRect.new()
	boost_divider.custom_minimum_size = Vector2(0, 1)
	boost_divider.color = Color(0.45, 0.72, 0.88, 0.28)
	boost_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(boost_divider)

	_buff_boost_row = HBoxContainer.new()
	_buff_boost_row.add_theme_constant_override("separation", 12)
	_buff_boost_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_buff_boost_row)

	var boost_icon := Label.new()
	boost_icon.text = "⚡"
	boost_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_buff_label(boost_icon, 26, Color(0.98, 0.88, 0.42))
	_buff_boost_row.add_child(boost_icon)

	var boost_body := VBoxContainer.new()
	boost_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boost_body.add_theme_constant_override("separation", 4)
	boost_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buff_boost_row.add_child(boost_body)

	var boost_head := HBoxContainer.new()
	boost_head.add_theme_constant_override("separation", 8)
	boost_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boost_body.add_child(boost_head)

	var boost_title := Label.new()
	boost_title.text = "加速"
	_style_buff_label(boost_title, 22, Color(0.95, 0.98, 1.0))
	boost_head.add_child(boost_title)

	_speed_boost_time_label = Label.new()
	_speed_boost_time_label.text = "未激活"
	_speed_boost_time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_speed_boost_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_style_buff_label(_speed_boost_time_label, 18, Color(0.68, 0.78, 0.88), 2)
	boost_head.add_child(_speed_boost_time_label)

	_speed_boost_bar = ProgressBar.new()
	_speed_boost_bar.custom_minimum_size = Vector2(0, 18)
	_speed_boost_bar.max_value = _speed_boost_duration()
	_speed_boost_bar.value = 0.0
	_speed_boost_bar.show_percentage = false
	_speed_boost_bar.add_theme_stylebox_override("fill", _make_buff_bar_style(Color(0.98, 0.78, 0.22), Color(0.98, 0.78, 0.22)))
	_speed_boost_bar.add_theme_stylebox_override("background", _make_buff_bar_style(Color(0.10, 0.14, 0.20, 0.95), Color(0.10, 0.14, 0.20)))
	boost_body.add_child(_speed_boost_bar)

	if not _is_emergency_run:
		return

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 1)
	divider.color = Color(0.45, 0.72, 0.88, 0.28)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(divider)

	var emergency_boost_row := HBoxContainer.new()
	emergency_boost_row.add_theme_constant_override("separation", 12)
	emergency_boost_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(emergency_boost_row)

	var emergency_icon := Label.new()
	emergency_icon.text = "🚀"
	emergency_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_buff_label(emergency_icon, 26, Color(0.98, 0.88, 0.42))
	emergency_boost_row.add_child(emergency_icon)

	var emergency_body := VBoxContainer.new()
	emergency_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	emergency_body.add_theme_constant_override("separation", 4)
	emergency_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emergency_boost_row.add_child(emergency_body)

	var emergency_head := HBoxContainer.new()
	emergency_head.add_theme_constant_override("separation", 8)
	emergency_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emergency_body.add_child(emergency_head)

	var emergency_title := Label.new()
	emergency_title.text = "加速包"
	_style_buff_label(emergency_title, 22, Color(0.95, 0.98, 1.0))
	emergency_head.add_child(emergency_title)

	_boost_count_label = Label.new()
	_boost_count_label.text = "0/5"
	_style_buff_label(_boost_count_label, 24, Color(0.55, 0.95, 1.0))
	emergency_head.add_child(_boost_count_label)

	_boost_status_label = Label.new()
	_boost_status_label.text = "集满 5 个解锁冲刺"
	_boost_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_boost_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_style_buff_label(_boost_status_label, 16, Color(0.68, 0.78, 0.88), 2)
	emergency_head.add_child(_boost_status_label)

	var pip_row := HBoxContainer.new()
	pip_row.add_theme_constant_override("separation", 6)
	pip_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emergency_body.add_child(pip_row)

	_boost_pips.clear()
	for _i in SPEED_BOOST_SKILL_THRESHOLD:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(0, 18)
		pip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pip.color = Color(0.12, 0.18, 0.26, 0.95)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pip_row.add_child(pip)
		_boost_pips.append(pip)

	_boost_dash_icon_wrap = PanelContainer.new()
	_boost_dash_icon_wrap.custom_minimum_size = Vector2(58, 58)
	_boost_dash_icon_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dash_style := StyleBoxFlat.new()
	dash_style.bg_color = Color(0.08, 0.12, 0.18, 0.92)
	dash_style.border_color = Color(0.32, 0.48, 0.58, 0.65)
	dash_style.set_border_width_all(2)
	dash_style.set_corner_radius_all(12)
	dash_style.content_margin_left = 6
	dash_style.content_margin_right = 6
	dash_style.content_margin_top = 2
	dash_style.content_margin_bottom = 2
	_boost_dash_icon_wrap.add_theme_stylebox_override("panel", dash_style)
	emergency_boost_row.add_child(_boost_dash_icon_wrap)

	var dash_col := VBoxContainer.new()
	dash_col.alignment = BoxContainer.ALIGNMENT_CENTER
	dash_col.add_theme_constant_override("separation", 0)
	dash_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boost_dash_icon_wrap.add_child(dash_col)

	_boost_dash_icon = Label.new()
	_boost_dash_icon.text = "—"
	_boost_dash_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_buff_label(_boost_dash_icon, 22, Color(0.42, 0.48, 0.54), 2)
	dash_col.add_child(_boost_dash_icon)

	var dash_hint := Label.new()
	dash_hint.text = "冲刺"
	dash_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_buff_label(dash_hint, 13, Color(0.58, 0.66, 0.74), 2)
	dash_col.add_child(dash_hint)


func _build_cargo_hud(parent: Control) -> void:
	_cargo_hud_panel = PanelContainer.new()
	_cargo_hud_panel.name = "CargoHudPanel"
	_cargo_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cargo_hud_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cargo_hud_panel.size_flags_stretch_ratio = 0.92
	_cargo_hud_panel.custom_minimum_size = Vector2(300.0, _top_status_panel_height())
	parent.add_child(_cargo_hud_panel)
	_cargo_hud_panel.add_theme_stylebox_override(
		"panel",
		_make_status_panel_style(Color(0.42, 0.72, 0.96, 0.78))
	)

	var root := VBoxContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("separation", 6)
	_cargo_hud_panel.add_child(root)

	cargo_title_label = Label.new()
	cargo_title_label.text = "货物"
	_style_buff_label(cargo_title_label, 20, Color(0.78, 0.90, 1.0), 3)
	root.add_child(cargo_title_label)

	var cargo_row := HBoxContainer.new()
	cargo_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cargo_row.add_theme_constant_override("separation", 10)
	cargo_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(cargo_row)

	var icon_wrap := PanelContainer.new()
	icon_wrap.custom_minimum_size = Vector2(58, 58)
	icon_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = Color(0.05, 0.10, 0.16, 0.92)
	icon_style.border_color = Color(0.35, 0.58, 0.82, 0.65)
	icon_style.set_border_width_all(1)
	icon_style.set_corner_radius_all(10)
	icon_style.content_margin_left = 4
	icon_style.content_margin_right = 4
	icon_style.content_margin_top = 4
	icon_style.content_margin_bottom = 4
	icon_wrap.add_theme_stylebox_override("panel", icon_style)
	cargo_row.add_child(icon_wrap)
	icon_wrap.add_child(cargo_icon)
	cargo_icon.custom_minimum_size = Vector2(50, 50)
	cargo_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cargo_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var cargo_text_col := VBoxContainer.new()
	cargo_text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cargo_text_col.add_theme_constant_override("separation", 2)
	cargo_text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cargo_text_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cargo_row.add_child(cargo_text_col)

	cargo_label = Label.new()
	cargo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	cargo_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cargo_label.clip_text = false
	cargo_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	cargo_text_col.add_child(cargo_label)
	_style_buff_label(cargo_label, 26, Color(0.95, 0.98, 1.0), 4)

	cargo_detail_label = Label.new()
	cargo_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	cargo_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cargo_detail_label.clip_text = false
	cargo_detail_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	cargo_detail_label.visible = false
	cargo_text_col.add_child(cargo_detail_label)
	_style_buff_label(cargo_detail_label, 18, Color(0.72, 0.84, 0.94), 3)


func _on_pause_button_pressed() -> void:
	if is_finished or is_failed:
		return
	if _pause_overlay != null:
		_pause_overlay.open_pause()

func _update_runner_letterboxes() -> void:
	if _letterbox_left == null or _letterbox_right == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var target_ratio := MOBILE_VIEWPORT_SIZE.x / MOBILE_VIEWPORT_SIZE.y
	var content_width := viewport_size.y * target_ratio
	if viewport_size.x <= content_width + 1.0:
		_letterbox_left.visible = false
		_letterbox_right.visible = false
		return
	var bar_width := (viewport_size.x - content_width) * 0.5
	_letterbox_left.visible = true
	_letterbox_left.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_letterbox_left.anchor_top = 0.0
	_letterbox_left.anchor_bottom = 1.0
	_letterbox_left.offset_left = 0.0
	_letterbox_left.offset_top = 0.0
	_letterbox_left.offset_right = bar_width
	_letterbox_left.offset_bottom = 0.0

	_letterbox_right.visible = true
	_letterbox_right.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_letterbox_right.anchor_top = 0.0
	_letterbox_right.anchor_bottom = 1.0
	_letterbox_right.offset_left = -bar_width
	_letterbox_right.offset_top = 0.0
	_letterbox_right.offset_right = 0.0
	_letterbox_right.offset_bottom = 0.0

func _update_hud() -> void:
	var type_zh := String(mission.get("task_type_zh", _mission_profile.get("name_zh", "补给")))
	if bool(_mission_profile.get("timed_fail", false)):
		time_label.text = "剩余 %0.1f · %s" % [maxf(_run_time - elapsed, 0.0), type_zh]
	else:
		time_label.text = "时间 %0.1f / %0.0f · %s" % [elapsed, _run_time, type_zh]
	var speed_text := "速度 %0.1f m/s" % (current_speed * speed_penalty_mult)
	if speed_penalty_timer > 0.0:
		speed_text += " (减速)"
	speed_label.text = speed_text

	var phase: Dictionary = LevelConfig.phase_at(track_distance)
	if track_layer > 0:
		phase_label.text = "侧墙跑 · 左/右切换高度列"
	else:
		phase_label.text = "阶段 %s · %s" % [phase["name"], phase["hint"]]
	if cargo_label != null:
		var cargo_name := String(mission.get("cargo_name", "物资"))
		if cargo_title_label != null:
			cargo_title_label.text = "货物 · %s" % cargo_name
		if _uses_smash_collision():
			cargo_label.text = "完整度 %0.0f%%" % cargo_integrity
			if cargo_detail_label != null:
				cargo_detail_label.text = "撞碎 %d/%d  ·  体力 %0.0f/%0.0f" % [
					_smash_hit_count,
					maxi(_smash_obstacle_total, 1),
					Global.runner_hp,
					Global.runner_hp_max,
				]
				cargo_detail_label.visible = true
		else:
			cargo_label.text = "完整度 %0.0f%%" % cargo_integrity
			if cargo_detail_label != null:
				cargo_detail_label.text = "装载 %d" % int(mission.get("cargo_load", 0))
				cargo_detail_label.visible = int(mission.get("cargo_load", 0)) > 0
	score_label.text = "星火币 %d" % run_score
	layer_label.text = "地图 %s" % LevelConfig.MAP_NAME
	collectible_label.text = "星火币 %d / %d · 水晶 %d" % [collected_count, total_collectibles, crystal_collected_count]
	_refresh_buff_hud()
	if shield_button:
		shield_button.modulate = Color(0.55, 0.95, 1.0) if _is_shield_protecting() else Color(1, 1, 1)

	var danger_ratio := 1.0 - clampf(chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var chase_status := "安全"
	if _pressure_chaser_enabled and _energy_chaser != null:
		var gap_m := _energy_chaser.get_visual_gap()
		danger_ratio = 1.0 - clampf(gap_m / 28.0, 0.0, 1.0)
		chase_status = _energy_chaser.get_state_label()
		chase_label.text = "身后 %0.0f 米 · %s" % [gap_m, chase_status]
		if chase_bar:
			chase_bar.max_value = 28.0
			chase_bar.value = gap_m
		if _chase_overlay != null:
			var ov_on := _chaser_enabled and gameplay_active and not is_failed and not is_finished and not is_intro
			if _energy_chaser != null:
				ov_on = ov_on and _energy_chaser.get_normalized_pressure() >= 0.5
			_chase_overlay.visible = ov_on
		# 与追击面板同一套米数色：<10 红 · 10–20 紫 · >20 绿
		if gap_m < 10.0:
			chase_label.add_theme_color_override("font_color", Color(1.0, 0.28, 0.28))
		elif gap_m <= 20.0:
			chase_label.add_theme_color_override("font_color", Color(0.78, 0.42, 1.0))
		else:
			chase_label.add_theme_color_override("font_color", Color(0.55, 0.98, 0.72))
	else:
		if danger_ratio > 0.72:
			chase_status = "极危"
		elif danger_ratio > 0.45:
			chase_status = "危险"
		elif danger_ratio > 0.22:
			chase_status = "逼近"
		chase_label.text = "身后 %0.1f 米 · %s" % [chaser_distance, chase_status]
		chase_bar.value = chaser_distance
		if danger_ratio > 0.72:
			chase_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.2))
		elif danger_ratio > 0.45:
			chase_label.add_theme_color_override("font_color", Color(1.0, 0.65, 0.15))
		else:
			chase_label.add_theme_color_override("font_color", Color(0.55, 0.95, 0.75))

	if chaser_hint_wrap:
		var show_hint := _chaser_enabled and not is_finished and not _capture_cinematic_active
		if _settlement_celebration_active:
			show_hint = false
		chaser_hint_wrap.visible = show_hint
		chaser_hint_wrap.z_index = 28
		if show_hint and chaser_hint_panel:
			var show_m := chaser_distance
			if _pressure_chaser_enabled and _energy_chaser != null:
				show_m = _energy_chaser.get_visual_gap()
			# <10 红 · 10–20 紫 · >20 绿
			var dist_color := Color(0.55, 0.98, 0.72)
			var border := Color(0.45, 0.9, 0.65, 0.95)
			if show_m < 10.0:
				dist_color = Color(1.0, 0.28, 0.28)
				border = Color(1.0, 0.32, 0.38, 1.0)
			elif show_m <= 20.0:
				dist_color = Color(0.78, 0.42, 1.0)
				border = Color(0.72, 0.4, 1.0, 1.0)
			chaser_hint_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
			var style := chaser_hint_panel.get_theme_stylebox("panel") as StyleBoxFlat
			if style != null:
				style = style.duplicate() as StyleBoxFlat
				style.border_color = border
				style.bg_color = Color(0.04, 0.05, 0.12, 0.96)
				chaser_hint_panel.add_theme_stylebox_override("panel", style)
			chaser_hint_label.text = "压迫追击" if _pressure_chaser_enabled else "身后追击"
			var dist_lbl := chaser_hint_panel.find_child("ChaserHintDistance", true, false) as Label
			if dist_lbl:
				dist_lbl.text = "%0.0f 米" % show_m
				dist_lbl.add_theme_color_override("font_color", dist_color)
			if _chaser_hint_bar != null:
				_chaser_hint_bar.max_value = 28.0
				# 距离越近条越满
				_chaser_hint_bar.value = clampf(28.0 - show_m, 0.0, 28.0)
				_chaser_hint_bar.visible = true
			var sub_lbl := chaser_hint_panel.find_child("ChaserHintSub", true, false) as Label
			if sub_lbl:
				if _pressure_chaser_enabled and _energy_chaser != null:
					sub_lbl.text = LevelConfig.CHASER_NAME
				else:
					sub_lbl.text = LevelConfig.CHASER_NAME
	if danger_vignette:
		if is_intro or not gameplay_active:
			danger_vignette.color = Color(0.42, 0.08, 0.55, 0.0)
		elif _pressure_chaser_enabled:
			var vg := 0.0 if danger_ratio < 0.5 else danger_ratio * 0.1
			danger_vignette.color = Color(0.42, 0.08, 0.55, vg)
		else:
			danger_vignette.color = Color(0.55, 0.12, 0.04, danger_ratio * 0.1)

	if strike_toast_timer > 0.0:
		strike_toast_timer = maxf(strike_toast_timer - get_process_delta_time(), 0.0)
		strike_toast_label.modulate.a = clampf(strike_toast_timer / 1.6, 0.0, 1.0)
	elif strike_toast_label.text != "":
		strike_toast_label.text = ""
		strike_toast_label.modulate.a = 0.0

func _show_state(title: String, body: String, settlement_mode: String = "", fail_reason_en: String = "") -> void:
	state_title.text = title
	state_body.text = body
	var use_settlement := settlement_mode in ["success", "failure"]
	if _state_wrap != null:
		_state_wrap.visible = true
	state_panel.visible = true
	state_title.visible = not use_settlement
	_set_settlement_presentation(use_settlement, title, settlement_mode == "failure", fail_reason_en)


func _set_settlement_presentation(active: bool, outpost_title: String = "", failed: bool = false, fail_reason_en: String = "") -> void:
	_settlement_celebration_active = active
	_settlement_is_failure = failed
	if _settlement_horizon_layer != null:
		_settlement_horizon_layer.visible = active
		if active:
			_settlement_horizon_layer.configure(outpost_title, Global.runner_location_id, _hearth_scene_path, failed)
	if _settlement_horizon_header != null:
		_settlement_horizon_header.visible = active
		if active:
			_settlement_horizon_header.configure(outpost_title, failed, fail_reason_en)
	if _coin_pickup_screen_fx != null and is_instance_valid(_coin_pickup_screen_fx):
		if active:
			_coin_pickup_screen_fx.clear_combo()
		_coin_pickup_screen_fx.visible = not active
	if _coin_screen_flash != null and is_instance_valid(_coin_screen_flash):
		_coin_screen_flash.visible = not active
	if _cargo_hud_panel != null:
		_cargo_hud_panel.visible = not active
	if _top_hud_wrap != null:
		_top_hud_wrap.visible = not active
	if _sky_cheer_hud_layer != null:
		_sky_cheer_hud_layer.visible = not active
	if pause_button != null:
		pause_button.visible = not active
		pause_button.z_index = 0
	if shield_button != null:
		shield_button.visible = not active
		shield_button.z_index = 0
	if danger_vignette != null:
		danger_vignette.visible = (not active) and _chaser_enabled
	if chaser_hint_wrap != null:
		chaser_hint_wrap.visible = (not active) and _chaser_enabled and not _capture_cinematic_active
	if _chase_overlay != null and active:
		_chase_overlay.visible = false
	if intro_panel != null:
		intro_panel.visible = intro_panel.visible and not active
	if player != null and is_instance_valid(player):
		player.visible = not active
	if _finish_portal_root != null and is_instance_valid(_finish_portal_root):
		_finish_portal_root.visible = not active
	if _finish_outpost_title_rig != null and is_instance_valid(_finish_outpost_title_rig):
		_finish_outpost_title_rig.visible = not active
	if _finish_outpost_title_glow != null and is_instance_valid(_finish_outpost_title_glow):
		_finish_outpost_title_glow.visible = not active
	if _finish_outpost_title_bloom != null and is_instance_valid(_finish_outpost_title_bloom):
		_finish_outpost_title_bloom.visible = not active
	if _state_wrap != null:
		if active:
			_state_wrap.visible = true
			_raise_settlement_ui()
			call_deferred("_sync_settlement_horizon_layout")
			call_deferred("_ensure_settlement_buttons_interactive")
		else:
			_state_wrap.z_index = 50
			_state_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_state_wrap.add_theme_constant_override("margin_top", 0)
			_state_wrap.add_theme_constant_override("margin_left", 28)
			_state_wrap.add_theme_constant_override("margin_right", 28)
			_state_wrap.add_theme_constant_override("margin_bottom", 20)
			if _state_outer != null:
				_state_outer.alignment = BoxContainer.ALIGNMENT_END
			if _state_box != null:
				_state_box.alignment = BoxContainer.ALIGNMENT_CENTER
			if _state_panel_spacer != null:
				_state_panel_spacer.visible = false
			if state_panel != null:
				state_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				state_panel.custom_minimum_size = Vector2.ZERO


func _sync_settlement_horizon_layout() -> void:
	if _settlement_horizon_header == null or _settlement_horizon_layer == null:
		return
	var layer_size := _settlement_horizon_layer.size
	if layer_size.y < 1.0:
		layer_size = _settlement_horizon_layer.get_viewport_rect().size
	var h := layer_size.y
	var w := layer_size.x
	var horizon_y := h * float(_settlement_horizon_layer.horizon_ratio)
	_settlement_horizon_header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_settlement_horizon_header.offset_left = w * 0.03
	_settlement_horizon_header.offset_right = -w * 0.03
	_settlement_horizon_header.offset_top = horizon_y + 8.0
	_settlement_horizon_header.offset_bottom = horizon_y + 98.0
	if _state_wrap != null and _settlement_celebration_active:
		_raise_settlement_ui()
		_state_wrap.add_theme_constant_override("margin_top", int(horizon_y + 88.0))
		_state_wrap.add_theme_constant_override("margin_left", int(w * 0.06))
		_state_wrap.add_theme_constant_override("margin_right", int(w * 0.06))
		_state_wrap.add_theme_constant_override("margin_bottom", int(h * 0.04))
		if _state_outer != null:
			_state_outer.alignment = BoxContainer.ALIGNMENT_BEGIN
			_state_outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_state_outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
			_state_outer.add_theme_constant_override("separation", 0)
		if state_panel != null:
			state_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			state_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
			state_panel.custom_minimum_size = Vector2(0, 0)
			state_panel.mouse_filter = Control.MOUSE_FILTER_PASS
			var settle_style := StyleBoxFlat.new()
			settle_style.bg_color = SETTLEMENT_PANEL_BG
			settle_style.border_color = SETTLEMENT_PANEL_BORDER
			settle_style.set_border_width_all(2)
			settle_style.set_corner_radius_all(16)
			settle_style.content_margin_left = 24
			settle_style.content_margin_right = 24
			settle_style.content_margin_top = 22
			settle_style.content_margin_bottom = 20
			settle_style.shadow_color = Color("#000000", 0.45)
			settle_style.shadow_size = 10
			state_panel.add_theme_stylebox_override("panel", settle_style)
		if _state_button_row != null:
			_state_button_row.add_theme_constant_override("separation", int(maxf(h * 0.014, 12.0)))
			_state_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_state_button_row.size_flags_vertical = Control.SIZE_SHRINK_END
			_state_button_row.mouse_filter = Control.MOUSE_FILTER_PASS
			_state_button_row.add_theme_constant_override("margin_top", 12)
		if state_restart_button != null:
			state_restart_button.custom_minimum_size = Vector2(0, maxf(58.0, h * 0.062))
			state_restart_button.add_theme_font_size_override("font_size", int(maxf(22.0, h * 0.024)))
			state_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
			state_restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
			state_restart_button.z_index = 210
			_apply_settlement_button_style(state_restart_button, SETTLEMENT_BUTTON_BG, SETTLEMENT_BUTTON_BORDER)
		if state_back_button != null:
			state_back_button.custom_minimum_size = Vector2(0, maxf(58.0, h * 0.062))
			state_back_button.add_theme_font_size_override("font_size", int(maxf(22.0, h * 0.024)))
			state_back_button.mouse_filter = Control.MOUSE_FILTER_STOP
			state_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
			state_back_button.disabled = false
			state_back_button.z_index = 210
			_apply_settlement_button_style(state_back_button, SETTLEMENT_BUTTON_BG, SETTLEMENT_BUTTON_BORDER)
		if state_body != null:
			state_body.add_theme_font_size_override("font_size", int(maxf(24.0, h * 0.026)))
			state_body.add_theme_color_override("font_color", SETTLEMENT_BODY_COLOR)
			state_body.add_theme_constant_override("line_spacing", 10)
			state_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			state_body.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			state_body.custom_minimum_size.x = maxf(w * 0.82, 300.0)
		if _state_box != null:
			_state_box.alignment = BoxContainer.ALIGNMENT_BEGIN
		if _state_panel_spacer != null:
			_state_panel_spacer.visible = true
		_ensure_settlement_buttons_interactive()


func _raise_settlement_ui() -> void:
	if _state_wrap == null or hud_root == null:
		return
	if _state_wrap.get_parent() == hud_root:
		hud_root.move_child(_state_wrap, hud_root.get_child_count() - 1)
	_state_wrap.z_index = 500
	_state_wrap.visible = true
	_state_wrap.mouse_filter = Control.MOUSE_FILTER_PASS
	_state_wrap.process_mode = Node.PROCESS_MODE_ALWAYS


func _try_settlement_button_input(event: InputEvent) -> bool:
	var pressed := false
	var pos := Vector2.ZERO
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		pressed = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
		pos = mb.position
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		pressed = touch.pressed
		pos = touch.position
	if not pressed:
		return false
	if state_back_button != null and state_back_button.visible and not state_back_button.disabled:
		if state_back_button.get_global_rect().has_point(pos):
			call_deferred("_on_state_back_pressed")
			return true
	if state_restart_button != null and state_restart_button.visible and not state_restart_button.disabled:
		if state_restart_button.get_global_rect().has_point(pos):
			call_deferred("_restart_run")
			return true
	return false


func _ensure_settlement_buttons_interactive() -> void:
	if not _settlement_celebration_active:
		return
	if _state_outer != null:
		_state_outer.mouse_filter = Control.MOUSE_FILTER_PASS
	if state_body != null:
		state_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _state_wrap != null:
		_state_wrap.mouse_filter = Control.MOUSE_FILTER_PASS
		_state_wrap.process_mode = Node.PROCESS_MODE_ALWAYS
	if state_panel != null:
		state_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	if _state_box != null:
		_state_box.mouse_filter = Control.MOUSE_FILTER_PASS
	if _state_button_row != null:
		_state_button_row.mouse_filter = Control.MOUSE_FILTER_PASS
	if state_back_button != null:
		state_back_button.disabled = false
		state_back_button.visible = true
		state_back_button.mouse_filter = Control.MOUSE_FILTER_STOP
		state_back_button.move_to_front()
	if state_restart_button != null and state_restart_button.visible and not state_restart_button.disabled:
		state_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		state_restart_button.move_to_front()


func _path_turn_sharpness(distance: float) -> float:
	# 0=直道，越大弯越急（用于压镜头眩晕）
	var a := _sample_path(distance)
	var b := _sample_path(distance + 10.0)
	var dyaw := absf(angle_difference(float(a["yaw"]), float(b["yaw"])))
	return clampf(dyaw / 1.2, 0.0, 1.0)

func _visual_speed_ratio() -> float:
	var base := maxf(_base_run_speed(), 0.001)
	var boost := _effective_speed_boost_mult()
	var dash := EMERGENCY_DASH_MULT if _emergency_dash_timer > 0.0 else 1.0
	return clampf((current_speed * boost * dash) / base, 0.7, 2.4)

func _run_anim_speed_for_feel() -> float:
	var ratio := _visual_speed_ratio()
	var mapped := lerpf(1.12, 1.42, clampf((ratio - 0.88) / 0.95, 0.0, 1.0))
	if _is_fork_rushing() or _finish_sprint_timer > 0.0 or _speed_boost_timer > 0.0:
		mapped = minf(mapped + 0.08, 1.48)
	return mapped * _player_run_anim_speed_mult()

func _update_camera() -> void:
	# 滑铲时相机略抬高；骨骼模式不再大幅拉远（避免 GLB 后端穿镜时的补偿）
	var slide_offset := 0.14 if _is_sliding() else 0.0
	var slide_pullback := 0.0 if (_is_sliding() and _uses_skeletal_run()) else (1.35 if _is_sliding() else 0.0)
	var danger_ratio := clampf(1.0 - chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var speed_ratio := _visual_speed_ratio()
	var speed_feel := clampf((speed_ratio - 1.0) / 0.9, 0.0, 1.0)
	if _speed_feel_punch > 0.0:
		speed_feel = minf(speed_feel + _speed_feel_punch * 0.55, 1.0)
	_speed_rumble = lerpf(_speed_rumble, speed_feel * 0.007, 0.06)
	var shake_offset := Vector3.ZERO
	if camera_shake > 0.0:
		shake_offset = Vector3(randf_range(-0.022, 0.022), randf_range(-0.016, 0.016), 0.0) * (camera_shake / 0.16)
		camera_shake = maxf(camera_shake - get_process_delta_time(), 0.0)
	if _speed_rumble > 0.003 and not is_intro and not _is_sliding():
		# 正弦微震替代逐帧随机，高速奔跑时更顺
		shake_offset += Vector3(
			sin(elapsed * 31.0) * _speed_rumble,
			cos(elapsed * 27.0) * _speed_rumble * 0.65,
			0.0
		)

	var cam_behind := CAMERA_BEHIND
	var cam_side := 0.0
	var rear_blend := _chaser_intro_look if (_pressure_chaser_enabled and is_intro) else 0.0
	if is_intro:
		if _pressure_chaser_enabled:
			# 后侧反打：站到 Runner 右后侧外撇，越过肩背看潮体（避免正后被身子挡住）
			cam_behind = lerpf(CAMERA_BEHIND + 0.4, CAMERA_BEHIND - 0.35, rear_blend)
			cam_side = lerpf(0.0, 2.45, rear_blend)
		elif _chaser_enabled:
			cam_behind = lerpf(CAMERA_BEHIND + 3.2, CAMERA_BEHIND + 1.4, 1.0 - _chaser_intro_look)
		else:
			cam_behind = lerpf(CAMERA_BEHIND + 1.2, CAMERA_BEHIND, clampf(intro_elapsed / INTRO_DURATION, 0.0, 1.0))
	else:
		cam_behind = lerpf(CAMERA_BEHIND, CAMERA_BEHIND + 0.55, speed_feel)

	if _is_wall_running():
		var zone := _side_runway_wall_zone_at(track_distance)
		if zone.is_empty():
			zone = _side_runway_zone_at(track_distance)
		var side := _wall_zone_side(zone, track_distance)
		# 根节点已直立：相机仍挂在角色上。偏向主路内侧，始终能看见贴墙的主角
		cam_behind = 9.2
		camera_pivot.position = Vector3(
			shake_offset.x + (-side * 3.4),
			CAMERA_HEIGHT + 0.85 + slide_offset,
			cam_behind
		) + shake_offset * 0.35
		camera.position = Vector3(0.0, 0.35, 0.0)
		var focus := player.global_position + Vector3(0.0, 0.95, 0.0)
		var sample := _sample_path(track_distance)
		var inward: Vector3 = (sample["right"] as Vector3) * (-side)
		focus += inward * 1.1
		if camera.global_position.distance_squared_to(focus) > 0.02:
			camera.look_at(focus, Vector3.UP)
		camera.fov = lerpf(camera.fov, clampf(CAMERA_FOV + danger_ratio * 2.0, CAMERA_FOV, 68.0), 0.1)
		return

	var intro_lift := 0.0
	if is_intro and _pressure_chaser_enabled:
		intro_lift = lerpf(0.15, 0.85, rear_blend)
	elif is_intro and _chaser_enabled:
		intro_lift = 0.45 * _chaser_intro_look
	camera_pivot.position = Vector3(
		shake_offset.x + cam_side,
		CAMERA_HEIGHT + slide_offset + intro_lift,
		cam_behind + slide_pullback
	) + shake_offset * 0.35
	camera.position = Vector3(0, 0.45, 0.0)

	# 沿真实路径（含岔路横向偏移）取前瞻点，避免瞬时切线直线瞄出路面
	var look_ahead := CAMERA_LOOK_AHEAD
	if not _fork_zone_at(track_distance).is_empty():
		look_ahead = minf(CAMERA_LOOK_AHEAD, 12.0)
	if is_intro:
		look_ahead *= lerpf(0.35, 0.05, rear_blend)
	if _finish_sprint_timer > 0.0:
		look_ahead += 5.0
		cam_behind += 0.35
	var ahead := _world_on_path(track_distance + look_ahead, current_lateral, GROUND_Y)
	var mid := _world_on_path(track_distance + look_ahead * 0.45, current_lateral, GROUND_Y)
	# 近点 + 远点混合，岔路弯道更跟路面
	var look_target: Vector3 = (ahead["pos"] as Vector3).lerp(mid["pos"] as Vector3, 0.35) + Vector3(0.0, 1.25, 0.0)
	if is_intro and _pressure_chaser_enabled and chaser != null and is_instance_valid(chaser) and chaser.visible:
		# 后侧反打：镜头对准潮体中心，Runner 只占肩背前景
		var chase_focus: Vector3 = chaser.global_position + Vector3(0.0, 0.85, 0.0)
		var runner_focus: Vector3 = player.global_position + Vector3(0.0, 1.15, 0.0) if player else look_target
		var blend := lerpf(0.18, 0.88, rear_blend)
		look_target = runner_focus.lerp(chase_focus, blend)
		if rear_blend > 0.55 and camera != null:
			camera.fov = lerpf(camera.fov, 58.0, 0.2)
	elif is_intro and _chaser_enabled and chaser != null and is_instance_valid(chaser) and chaser.visible:
		var chase_focus2: Vector3 = chaser.global_position + Vector3(0.0, 1.1, 0.0)
		var runner_focus2: Vector3 = player.global_position + Vector3(0.0, 1.35, 0.0) if player else look_target
		look_target = runner_focus2.lerp(chase_focus2, 0.28 * _chaser_intro_look)
	if _capture_cinematic_active and chaser != null and is_instance_valid(chaser):
		look_target = chaser.global_position.lerp(player.global_position if player else chaser.global_position, 0.35) + Vector3(0.0, 1.2, 0.0)
	if camera.global_position.distance_squared_to(look_target) > 0.04:
		camera.look_at(look_target, Vector3.UP)

	var target_fov := clampf(CAMERA_FOV + danger_ratio * 2.0, CAMERA_FOV, 68.0)
	if _finish_sprint_timer > 0.0:
		target_fov = 74.0
	camera.fov = lerpf(camera.fov, target_fov, 0.12)

func _update_runner_feedback(delta: float) -> void:
	if _landing_pose_timer > 0.0:
		_landing_pose_timer = maxf(_landing_pose_timer - delta, 0.0)
	if _jump_takeoff_pose_timer > 0.0:
		_jump_takeoff_pose_timer = maxf(_jump_takeoff_pose_timer - delta, 0.0)
	if _is_sliding():
		_set_player_pose("slide")
	elif _landing_pose_timer > 0.0:
		_set_player_pose("landing")
	elif _uses_skeletal_run():
		if _jump_takeoff_pose_timer > 0.0:
			_set_player_pose("jump_start")
		elif _player_in_air_pose(delta):
			if vertical_velocity > 0.35:
				_set_player_pose("jump_start")
			else:
				_set_player_pose("jump_peak")
		else:
			_set_player_pose("run")
	elif _jump_takeoff_pose_timer > 0.0 or vertical_velocity > 2.4:
		_set_player_pose("jump_start")
	elif not _is_on_ground() or _player_in_air_pose(delta):
		_set_player_pose("jump_peak")
	else:
		var run_step := int(floor(elapsed * 8.0)) % 2
		_set_player_pose("run_left" if run_step == 0 else "run_right")

	if _uses_skeletal_run() and player_pose_root and player_animation_player and player_pose_name == "run":
		var target_speed := _run_anim_speed_for_feel()
		_run_anim_speed_smooth = lerpf(_run_anim_speed_smooth, target_speed, 1.0 - exp(-5.5 * delta))
		player_animation_player.speed_scale = _run_anim_speed_smooth
		if _is_on_ground() and not _is_sliding():
			_run_stride_phase += delta * _run_anim_speed_smooth * 9.8
			var bounce := pow(maxf(sin(_run_stride_phase), 0.0), 0.78)
			player_pose_root.position.y = bounce * 0.024
			player_pose_root.position.x = 0.0
			player_pose_root.position.z = lerpf(player_pose_root.position.z, 0.0, 1.0 - exp(-16.0 * delta))
	elif _is_sliding():
		_stabilize_slide_pose_visual()

	var speed_feel := clampf((_visual_speed_ratio() - 1.0) / 0.9, 0.0, 1.0)
	var x_error := target_lane_x - current_lateral
	if _is_wall_running():
		var target_wy: float = float(WALL_LANE_HEIGHTS[clampi(lane_index, 0, WALL_LANE_HEIGHTS.size() - 1)])
		x_error = (target_wy - current_wall_y) * 0.55
	body_tilt = lerpf(body_tilt, clampf(-x_error * 0.09, -0.22, 0.22), 1.0 - exp(-6.0 * delta))
	if _is_sliding():
		body_tilt = lerpf(body_tilt, 0.0, 1.0 - exp(-14.0 * delta))
	# 高速前倾：平滑跟随，减少与路径同步的拉扯感
	var pitch_target := -deg_to_rad(2.5 + speed_feel * 5.5 + _speed_feel_punch * 1.6)
	if _is_sliding() or not _is_on_ground():
		pitch_target = 0.0
	_run_body_pitch = lerpf(_run_body_pitch, pitch_target, 1.0 - exp(-6.0 * delta))
	if player_body and _is_wall_running():
		_apply_wall_run_body_orientation(_wall_zone_side(_side_runway_zone_at(track_distance), track_distance))
		# 主路 body tilt / pitch 统一在 _sync_player_position 更新，避免双重 lerp 造成微抖

	trail_particles.amount_ratio = clampf(0.18 + speed_feel * 0.28, 0.15, 0.42)
	if _is_fork_rushing() or _finish_sprint_timer > 0.0 or _speed_boost_timer > 0.0:
		trail_particles.amount_ratio = clampf(0.55 + speed_feel * 0.35, 0.5, 0.82)
		trail_particles.speed_scale = 1.85 if _is_fork_rushing() else (1.65 if _speed_boost_timer > 0.0 else 1.55)
		if _is_fork_rushing():
			_set_trail_color(Color(0.5, 0.85, 1.0, 0.88))
		elif _speed_boost_timer > 0.0:
			_set_trail_color(Color(1.0, 0.78, 0.28, 0.86))
		else:
			_set_trail_color(Color(1.0, 0.78, 0.35, 0.75))
		if wall_boost_particles and _is_fork_rushing():
			wall_boost_particles.emitting = true
			wall_boost_particles.amount_ratio = 0.38
			wall_boost_particles.speed_scale = 1.2
		if rush_aura_particles and (_is_fork_rushing() or _finish_sprint_timer > 0.0):
			rush_aura_particles.emitting = true
			rush_aura_particles.amount_ratio = 0.62 if _is_fork_rushing() else 0.48
			rush_aura_particles.speed_scale = 1.35 if _is_fork_rushing() else 1.15
		elif rush_aura_particles:
			rush_aura_particles.emitting = false
	elif _is_wall_running():
		trail_particles.amount_ratio = clampf(0.12 + speed_feel * 0.12, 0.1, 0.22)
		var action_boost := _jump_fx_timer > 0.0 or body_squash_timer > 0.08
		trail_particles.speed_scale = 1.05 if action_boost else 0.85
		_set_trail_color(Color(0.55, 0.82, 1.0, 0.55) if action_boost else Color(0.32, 0.55, 0.72, 0.22))
		if foot_spark_particles:
			foot_spark_particles.amount_ratio = 0.18 if action_boost else 0.08
		_pulse_wall_boost_particles(action_boost or _wall_boost_fx_timer > 0.0)
		if rush_aura_particles:
			rush_aura_particles.emitting = false
	else:
		trail_particles.speed_scale = lerpf(0.85, 1.25, speed_feel) * (1.1 if _jump_fx_timer > 0.0 else 1.0)
		_set_trail_color(Color(1.0, 0.62, 0.18, 0.28 + speed_feel * 0.22))
		_pulse_wall_boost_particles(false)
		if rush_aura_particles:
			rush_aura_particles.emitting = false

	# 末段落陨石段关掉路边粒子，减轻 GPU 压力
	var edge_on := track_distance < 760.0
	for fx in _road_edge_particles:
		if fx != null and is_instance_valid(fx):
			fx.emitting = edge_on

	var boosting := _speed_boost_timer > 0.0 or _pad_burst_until_d > track_distance or _is_fork_rushing() or _finish_sprint_timer > 0.0 or _emergency_dash_timer > 0.0
	if _ember_fx_root:
		# 脚下火环 + 周身蝴蝶光晕：全程保持，避免中后段角色“裸奔”
		var ember_on := not is_finished and not is_failed and (gameplay_active or is_intro)
		_ember_fx_root.visible = ember_on
		if ember_on:
			_update_ember_flame_aura(delta)

	if foot_spark_particles:
		# 火焰光圈附近的少量火星点缀 · 随 BGM 拍点闪烁
		var spark_on := not is_finished and not is_failed and (gameplay_active or is_intro) and (boosting or _aura_kick_smooth > 0.22)
		foot_spark_particles.emitting = spark_on
		if spark_on:
			var rush := boosting
			var air := not _is_on_ground()
			var sliding := _is_sliding()
			var beat := _aura_kick_smooth
			foot_spark_particles.position.y = 0.18 if air else (0.02 if sliding else 0.05)
			foot_spark_particles.position.z = 0.18 if sliding else 0.06
			var spark_s := Vector3(0.45, 0.35, 0.55) if sliding else Vector3.ONE
			spark_s *= 1.0 + beat * 0.18 + speed_feel * 0.08
			foot_spark_particles.scale = spark_s
			var base_ratio := 0.10 if sliding else (0.12 if air else 0.14)
			if rush:
				base_ratio += 0.10
			foot_spark_particles.amount_ratio = clampf(base_ratio + beat * 0.05, 0.08, 0.28 if rush else 0.18)
			foot_spark_particles.speed_scale = (0.88 if rush else (0.82 if air else 0.78)) + beat * 0.1

	if body_spark_particles:
		# 周身星火：平时少量点缀，加速时更密
		var body_on := not is_finished and not is_failed and (gameplay_active or is_intro)
		body_spark_particles.emitting = body_on
		if body_on:
			var sliding := _is_sliding()
			var air := not _is_on_ground()
			var beat := _aura_kick_smooth
			body_spark_particles.position.y = 0.55 if sliding else (1.05 if air else 0.95)
			body_spark_particles.scale = (Vector3(0.55, 0.42, 0.7) if sliding else Vector3.ONE) * (1.0 + beat * 0.12)
			var body_ratio := 0.28 if boosting else 0.14
			body_spark_particles.amount_ratio = clampf((0.12 if sliding else body_ratio) + beat * 0.06, 0.10, 0.38)
			body_spark_particles.speed_scale = 0.82 + beat * 0.25
			var pm := body_spark_particles.process_material as ParticleProcessMaterial
			if pm:
				pm.emission_box_extents = Vector3(0.4, 0.32, 0.05) if sliding else Vector3(0.7 + beat * 0.2, 0.55 + beat * 0.15, 0.06)

	if jump_streak_particles:
		var in_air := not _is_on_ground() and not _is_wall_running()
		jump_streak_particles.emitting = in_air or _jump_fx_timer > 0.0
		jump_streak_particles.amount_ratio = 1.0 if _jump_fx_timer > 0.15 else 0.55

	if _is_sliding():
		if not _uses_skeletal_run():
			player_body.scale = player_body.scale.lerp(Vector3.ONE, 1.0 - exp(-16.0 * delta))
			player_body.position.y = lerpf(player_body.position.y, 0.0, 1.0 - exp(-16.0 * delta))
			_clamp_player_body_scale()
		return

	if body_squash_timer > 0.0:
		body_squash_timer = maxf(body_squash_timer - delta, 0.0)
		if not _uses_skeletal_run():
			var squash_ratio := body_squash_timer / 0.22
			var x_amp := 0.22 if _hit_recoil_timer > 0.0 else 0.12
			var y_amp := 0.28 if _hit_recoil_timer > 0.0 else 0.14
			player_body.scale = Vector3(1.0 + squash_ratio * x_amp, 1.0 - squash_ratio * y_amp, 1.0 + squash_ratio * x_amp)
	elif not _uses_skeletal_run():
		player_body.scale = player_body.scale.lerp(Vector3.ONE, 1.0 - exp(-12.0 * delta))
	if not _uses_skeletal_run():
		player_body.position.y = lerpf(player_body.position.y, 0.0, 1.0 - exp(-12.0 * delta))
		_clamp_player_body_scale()

func _update_collectible_magnet(delta: float) -> void:
	var player_lane := int(LANES[lane_index])
	var magnet_scan := 88.0
	for collectible in collectibles:
		if collectible["collected"]:
			continue
		if int(collectible.get("layer", 0)) != track_layer:
			continue
		if absf(track_distance - float(collectible.get("distance", 0.0))) > magnet_scan:
			continue
		var node := collectible["node"] as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var coin_lane := int(collectible.get("lane", 0))
		var lane_gap := absi(coin_lane - player_lane)
		var kind := String(collectible.get("kind", "coin"))
		if kind != "shield_crystal" and MAGNET_LANE_ONLY and lane_gap > 0:
			if kind != "coin":
				continue
		if kind == "shield_crystal" and lane_gap > 0:
			continue
		var magnet_y := 0.65 if bool(collectible.get("air", false)) else 0.45
		var magnet_radius := MAGNET_RADIUS + (0.6 if bool(collectible.get("air", false)) and not _is_on_ground() else 0.0)
		if kind == "shield_crystal":
			magnet_radius += 1.45
		elif kind == "coin":
			magnet_radius += 0.55
		var to_player := player.global_position + Vector3(0, magnet_y, 0) - node.global_position
		var distance := to_player.length()
		if distance > magnet_radius:
			continue
		var pull := MAGNET_SPEED * delta * clampf(1.0 - distance / magnet_radius, 0.12, 1.0)
		node.global_position += to_player.normalized() * minf(pull, distance)


func _update_coin_collectible_visuals(delta: float) -> void:
	if is_finished or is_failed or not gameplay_active:
		return
	var spin := 2.6
	var pulse_t := elapsed * 4.6
	var visual_scan := 92.0
	for collectible in collectibles:
		if collectible.get("collected", false):
			continue
		if String(collectible.get("kind", "coin")) != "coin":
			continue
		if absf(track_distance - float(collectible.get("distance", 0.0))) > visual_scan:
			continue
		var node := collectible.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		node.rotate_object_local(Vector3.UP, delta * spin)
		var phase := float(collectible.get("bob_phase", 0.0))
		var bob := sin(pulse_t + phase) * (0.05 if bool(collectible.get("air", false)) else 0.028)
		var base_y := float(collectible.get("y", node.position.y))
		node.position.y = base_y + bob
		var wobble := sin(pulse_t * 0.85 + phase * 1.7) * 0.08
		node.rotation.x = wobble


func _is_overweight_cargo() -> bool:
	return MissionTypes.is_overweight_cargo(mission)


func _is_defense_cargo() -> bool:
	return MissionTypes.is_defense_cargo(mission)


func _jump_double_tap_window() -> float:
	if OS.has_feature("mobile"):
		return JUMP_DOUBLE_TAP_WINDOW_MOBILE
	return JUMP_DOUBLE_TAP_WINDOW


func _try_overweight_full_jump_boost() -> bool:
	if not _overweight_jump_armed or _overweight_short_jump_timer <= 0.0:
		return false
	_overweight_jump_armed = false
	_overweight_short_jump_timer = 0.0
	vertical_velocity = maxf(vertical_velocity, JUMP_SPEED)
	_end_slide()
	_landing_pose_timer = 0.0
	_jump_takeoff_pose_timer = 0.12
	if not _uses_skeletal_run():
		body_squash_timer = 0.14
	else:
		body_squash_timer = 0.0
		_set_player_pose("jump_start")
	camera_shake = maxf(camera_shake, 0.12)
	_jump_fx_timer = 0.38
	_emit_jump_takeoff_fx()
	_notify_coach_action("jump")
	return true


func _try_overweight_ground_jump() -> void:
	var window := _jump_double_tap_window()
	if _overweight_jump_armed and _overweight_short_jump_timer > 0.0:
		_overweight_jump_armed = false
		_overweight_short_jump_timer = 0.0
		_execute_jump(JUMP_SPEED)
		return
	_overweight_jump_armed = true
	_overweight_short_jump_timer = window
	_execute_jump(JUMP_SPEED * OVERWEIGHT_JUMP_SHORT_MULT)


func _coin_collectible_y(air: bool, layer: int, wall_lane: int = 0, air_tier: int = -1) -> float:
	if layer == WALL_RUN_LAYER:
		var base_y := _wall_lane_height_for_lane_value(wall_lane)
		return base_y + (0.92 if air else 0.0)
	var explicit_tier := air_tier >= 0
	var tier := air_tier
	if tier < 0:
		tier = 1 if air else 0
	match tier:
		2:
			return _layer_height(layer) + COIN_HIGH_AIR_Y_OFFSET
		1:
			if explicit_tier:
				return _layer_height(layer) + COIN_MID_AIR_Y_OFFSET
			return _layer_height(layer) + COIN_AIR_Y_OFFSET
		_:
			return _layer_height(layer) + COIN_GROUND_Y_OFFSET


func _collectible_pickup_fx_config(kind: String) -> Dictionary:
	match kind:
		"shield_crystal":
			return {
				"amount": 26,
				"lifetime": 0.34,
				"spread": 155.0,
				"vel_min": 1.2,
				"vel_max": 3.8,
				"scale_min": 0.18,
				"scale_max": 0.48,
				"color": Color(0.45, 0.95, 1.0, 0.88),
				"particle_radius": 0.032,
				"particle_color": Color(0.55, 0.98, 1.0),
				"particle_emission": 2.4,
				"show_ring": true,
				"ring_inner": 0.16,
				"ring_outer": 0.26,
				"ring_color": Color(0.48, 0.96, 1.0, 0.72),
				"ring_emission": 2.2,
				"ring_scale": 1.75,
				"ring_duration": 0.28,
			}
		"speed_boost":
			return {
				"amount": 20,
				"lifetime": 0.3,
				"spread": 150.0,
				"vel_min": 1.1,
				"vel_max": 3.6,
				"scale_min": 0.18,
				"scale_max": 0.46,
				"color": Color(1.0, 0.68, 0.14, 0.82),
				"particle_radius": 0.03,
				"show_ring": true,
				"ring_inner": 0.13,
				"ring_outer": 0.21,
				"ring_color": Color(1.0, 0.62, 0.12, 0.58),
				"ring_emission": 1.7,
				"ring_scale": 1.6,
				"ring_duration": 0.24,
			}
		_:
			return {
				"amount": 8,
				"lifetime": 0.18,
				"spread": 95.0,
				"vel_min": 0.6,
				"vel_max": 1.8,
				"scale_min": 0.1,
				"scale_max": 0.24,
				"color": Color(1.0, 0.86, 0.38, 0.72),
				"particle_radius": 0.018,
				"show_ring": false,
			}


func _finish_arrival_distance() -> float:
	if _finish_line_distance <= 0.0:
		return _track_length
	return _finish_line_distance + FINISH_PORTAL_DEPTH + 4.0


func _finish_outpost_title_en() -> String:
	if LevelConfig != null and LevelConfig.has_method("get_outpost_meta"):
		var meta: Dictionary = LevelConfig.get_outpost_meta(Global.runner_location_id)
		var name_en := String(meta.get("name_en", "")).strip_edges()
		if name_en != "":
			return name_en
	return "Destination"


func _spawn_pickup_particle_burst(world_pos: Vector3, fx_cfg: Dictionary) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "CollectPickupFx"
	particles.one_shot = true
	particles.emitting = true
	particles.amount = int(fx_cfg.get("amount", 10))
	particles.lifetime = float(fx_cfg.get("lifetime", 0.22))
	particles.explosiveness = 1.0
	particles.fixed_fps = 0
	track_root.add_child(particles)
	particles.global_position = world_pos + Vector3(0.0, float(fx_cfg.get("y_offset", 0.28)), 0.0)
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = float(fx_cfg.get("spread", 120.0))
	mat.initial_velocity_min = float(fx_cfg.get("vel_min", 0.8))
	mat.initial_velocity_max = float(fx_cfg.get("vel_max", 2.4))
	mat.gravity = Vector3(0.0, -4.0, 0.0)
	mat.scale_min = float(fx_cfg.get("scale_min", 0.12))
	mat.scale_max = float(fx_cfg.get("scale_max", 0.34))
	mat.color = fx_cfg.get("color", Color(1.0, 0.84, 0.28, 0.82))
	particles.process_material = mat
	particles.draw_pass_1 = _make_pickup_particle_mesh(
		float(fx_cfg.get("particle_radius", 0.028)),
		fx_cfg.get("particle_color", Color(1.0, 0.86, 0.38)),
		float(fx_cfg.get("particle_emission", 1.8))
	)
	particles.restart()
	get_tree().create_timer(float(fx_cfg.get("cleanup", 0.48))).timeout.connect(particles.queue_free)


func _make_pickup_particle_mesh(radius: float, albedo: Color, emission_energy: float = 1.8) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(albedo.r, albedo.g, albedo.b, 0.92)
	mat.emission_enabled = true
	mat.emission = Color(albedo.r, albedo.g, albedo.b)
	mat.emission_energy_multiplier = emission_energy
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	return mesh


func _execute_jump(jump_speed: float) -> void:
	vertical_velocity = jump_speed
	_end_slide()
	_landing_pose_timer = 0.0
	_jump_takeoff_pose_timer = 0.12
	if not _uses_skeletal_run():
		body_squash_timer = 0.16
	else:
		body_squash_timer = 0.0
		_set_player_pose("jump_start")
	camera_shake = maxf(camera_shake, 0.12)
	_jump_fx_timer = 0.45
	_emit_jump_takeoff_fx()
	_notify_coach_action("jump")
	if _coach_tip_key == "overweight_jump" and _is_overweight_cargo() and jump_speed >= JUMP_SPEED * 0.9:
		_complete_coach_tip("overweight_jump")


func _emit_jump_takeoff_fx() -> void:
	if landing_particles:
		landing_particles.restart()
		landing_particles.emitting = true
	if jump_streak_particles:
		jump_streak_particles.restart()
		jump_streak_particles.emitting = true
	if player_body and not _uses_skeletal_run():
		player_body.scale = Vector3(0.86, 1.22, 0.86)


func _set_trail_color(col: Color) -> void:
	if _trail_process_mat == null:
		return
	_trail_process_mat.color = col


func _pulse_wall_boost_particles(active: bool) -> void:
	if wall_boost_particles == null:
		return
	wall_boost_particles.emitting = active
	if active and _wall_boost_fx_timer > 1.0:
		wall_boost_particles.amount_ratio = 1.0
		wall_boost_particles.speed_scale = 1.8
	elif active:
		wall_boost_particles.amount_ratio = 0.7
		wall_boost_particles.speed_scale = 1.25


func _make_jump_streak_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "JumpStreak"
	particles.position = Vector3(0.0, -0.2, 0.35)
	particles.amount = 42
	particles.lifetime = 0.32
	particles.emitting = false
	particles.visibility_aabb = AABB(Vector3(-4, -3, -4), Vector3(8, 8, 10))
	var box := BoxMesh.new()
	box.size = Vector3(0.04, 0.04, 0.28)
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.85, 0.95, 1.0, 0.85)
	sm.emission_enabled = true
	sm.emission = Color(0.55, 0.85, 1.0)
	sm.emission_energy_multiplier = 3.2
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	box.material = sm
	particles.draw_pass_1 = box
	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0.0, -0.15, 1.0)
	material.spread = 22.0
	material.initial_velocity_min = 7.0
	material.initial_velocity_max = 14.0
	material.gravity = Vector3(0.0, -2.0, 0.0)
	material.scale_min = 0.55
	material.scale_max = 1.4
	material.color = Color(0.7, 0.92, 1.0, 0.8)
	particles.process_material = material
	return particles


func _make_wall_boost_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "WallBoostTrail"
	particles.position = Vector3(0.0, 0.1, 0.55)
	particles.amount = 48
	particles.lifetime = 0.38
	particles.emitting = false
	particles.visibility_aabb = AABB(Vector3(-5, -4, -5), Vector3(10, 10, 12))
	var box := BoxMesh.new()
	box.size = Vector3(0.05, 0.05, 0.42)
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.35, 0.95, 1.0, 0.9)
	sm.emission_enabled = true
	sm.emission = Color(0.25, 0.85, 1.0)
	sm.emission_energy_multiplier = 4.0
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	box.material = sm
	particles.draw_pass_1 = box
	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0.0, 0.05, 1.0)
	material.spread = 28.0
	material.initial_velocity_min = 9.0
	material.initial_velocity_max = 18.0
	material.gravity = Vector3(0.0, 0.0, 0.0)
	material.scale_min = 0.7
	material.scale_max = 1.6
	material.color = Color(0.4, 0.95, 1.0, 0.88)
	particles.process_material = material
	return particles


func _wall_entry_jump_ready() -> bool:
	if track_layer != 0 or player == null:
		return false
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		return false
	return lane_index == _wall_edge_lane_index(zone)


func _apply_mission_environment() -> void:
	if _world_environment == null or _world_environment.environment == null:
		return
	var mission_env: Variant = mission.get("environment", {})
	if typeof(mission_env) != TYPE_DICTIONARY:
		return
	var overlay: Dictionary = mission_env
	if overlay.is_empty():
		return
	var env := _world_environment.environment
	if overlay.has("ambient"):
		env.ambient_light_color = overlay["ambient"]
	if overlay.has("ambient_energy"):
		env.ambient_light_energy = float(overlay["ambient_energy"])
	if overlay.has("fog_color"):
		env.fog_light_color = overlay["fog_color"]
	if overlay.has("fog_density"):
		env.fog_density = float(overlay["fog_density"])
	if overlay.has("fog_aerial_perspective"):
		env.fog_aerial_perspective = float(overlay["fog_aerial_perspective"])
	if overlay.has("fog_enabled"):
		env.fog_enabled = bool(overlay["fog_enabled"])
	if overlay.has("panorama_energy") and env.sky != null:
		var sky_mat := env.sky.sky_material
		if sky_mat is PanoramaSkyMaterial:
			(sky_mat as PanoramaSkyMaterial).energy_multiplier = float(overlay["panorama_energy"])
		elif sky_mat is ShaderMaterial:
			(sky_mat as ShaderMaterial).set_shader_parameter("energy", float(overlay["panorama_energy"]))
	if overlay.has("sky_rotation_y") or overlay.has("sky_rotation_x"):
		env.sky_rotation = Vector3(
			float(overlay.get("sky_rotation_x", 0.0)),
			float(overlay.get("sky_rotation_y", env.sky_rotation.y)),
			0.0
		)
	var sun := get_node_or_null("RunnerSun") as DirectionalLight3D
	if sun:
		if overlay.has("sun_color"):
			sun.light_color = overlay["sun_color"]
		if overlay.has("sun_energy"):
			sun.light_energy = float(overlay["sun_energy"])
	if overlay.has("tonemap_exposure"):
		env.tonemap_exposure = float(overlay["tonemap_exposure"])
	if overlay.has("adjustment_brightness") or overlay.has("adjustment_contrast") or overlay.has("adjustment_saturation"):
		env.adjustment_enabled = true
		env.adjustment_brightness = float(overlay.get("adjustment_brightness", 1.0))
		env.adjustment_contrast = float(overlay.get("adjustment_contrast", 1.0))
		env.adjustment_saturation = float(overlay.get("adjustment_saturation", 1.0))


func _apply_settlement_button_style(button: Button, bg: Color, border: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.border_color = border
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(8)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(bg.r + 0.05, bg.g + 0.05, bg.b + 0.07, bg.a)
	hover.border_color = Color(border.r + 0.12, border.g + 0.12, border.b + 0.16, minf(border.a + 0.2, 1.0))
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(bg.r * 0.85, bg.g * 0.85, bg.b * 0.9, bg.a)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", hover)


func _attach_wall_edge_soft_glow(slices: Array, side: float) -> void:
	if slices.size() < 2:
		return
	# 侧墙内边沿：极弱冷蓝描边，避免整块发光立面
	var glow_mat := _make_material(Color(0.12, 0.22, 0.36, 0.14), Color(0.18, 0.32, 0.48), 0.35)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var soft_mat := _make_material(Color(0.08, 0.14, 0.24, 0.08), Color(0.12, 0.2, 0.32), 0.18)
	soft_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	soft_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for pass_i in 2:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var inset := 0.08 if pass_i == 0 else 0.32
		var lift := 0.04 if pass_i == 0 else 0.02
		var height := WALL_FACE_HEIGHT * (0.92 if pass_i == 0 else 0.7)
		for i in range(slices.size() - 1):
			var a: Dictionary = slices[i]
			var b: Dictionary = slices[i + 1]
			var a_in: Vector3 = a["inner_bottom"]
			var b_in: Vector3 = b["inner_bottom"]
			var a_out: Vector3 = a["outer_bottom"]
			var inward := (a_in - a_out)
			if inward.length_squared() < 0.0001:
				inward = Vector3.RIGHT * (-side)
			inward = inward.normalized() * inset
			var a0 := a_in + inward + Vector3(0, lift, 0)
			var b0 := b_in + inward + Vector3(0, lift, 0)
			var a1 := a0 + Vector3(0, height, 0)
			var b1 := b0 + Vector3(0, height, 0)
			_add_wall_quad(st, a0, b0, b1, a1)
		var mesh := st.commit()
		if mesh == null:
			continue
		var mi := MeshInstance3D.new()
		mi.name = "WallEdgeSoftGlow_%d" % pass_i
		mi.mesh = mesh
		mi.material_override = glow_mat if pass_i == 0 else soft_mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(mi)


func _make_wall_guide_arrow(
	distance: float,
	lateral: float,
	wall_side: float,
	emphasis: bool = false
) -> Node3D:
	var root := Node3D.new()
	var sample := _sample_path(distance)
	var right: Vector3 = sample["right"] as Vector3
	var pos: Vector3 = sample["pos"] + right * lateral
	pos.y = GROUND_Y + 0.05
	root.position = pos
	var toward_wall := right * signf(wall_side)
	if toward_wall.length_squared() > 0.0001:
		root.look_at(pos + toward_wall.normalized(), Vector3.UP)

	var mat := _make_material(Color(1.0, 0.78, 0.12, 0.95), Color(1.0, 0.88, 0.25), 2.6 if emphasis else 1.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var thick := 0.06
	var y_off := thick * 0.5
	var wing_len := 0.58 if emphasis else 0.44
	var wing_w := 0.18 if emphasis else 0.14
	var tip_z := -0.52 if emphasis else -0.42

	# 完全贴地的左/右 chevron（-Z 为 look_at 后的侧墙方向）
	var wing_l := MeshInstance3D.new()
	var wing_l_mesh := BoxMesh.new()
	wing_l_mesh.size = Vector3(wing_w, thick, wing_len)
	wing_l.mesh = wing_l_mesh
	wing_l.material_override = mat
	wing_l.position = Vector3(-wing_w * 0.85, y_off, tip_z * 0.42)
	wing_l.rotation_degrees = Vector3(0.0, 48.0, 0.0)
	wing_l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(wing_l)

	var wing_r := MeshInstance3D.new()
	var wing_r_mesh := BoxMesh.new()
	wing_r_mesh.size = Vector3(wing_w, thick, wing_len)
	wing_r.mesh = wing_r_mesh
	wing_r.material_override = mat
	wing_r.position = Vector3(wing_w * 0.85, y_off, tip_z * 0.42)
	wing_r.rotation_degrees = Vector3(0.0, -48.0, 0.0)
	wing_r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(wing_r)

	var tip := MeshInstance3D.new()
	var tip_mesh := BoxMesh.new()
	tip_mesh.size = Vector3(wing_w * 0.75, thick, wing_w * 0.75)
	tip.mesh = tip_mesh
	tip.material_override = mat
	tip.position = Vector3(0.0, y_off, tip_z)
	tip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(tip)

	var shaft := MeshInstance3D.new()
	var shaft_mesh := BoxMesh.new()
	var shaft_len := 0.48 if emphasis else 0.36
	shaft_mesh.size = Vector3(wing_w * 0.55, thick, shaft_len)
	shaft.mesh = shaft_mesh
	shaft.material_override = mat
	shaft.position = Vector3(0.0, y_off, tip_z + shaft_len * 0.5 + wing_w * 0.15)
	shaft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(shaft)
	return root


func _shield_crystal_allowed_at(distance: float) -> bool:
	# 只在「后面还有热浪可用」的路段投放；最后一片热浪结束后不再刷
	var zones := _sorted_hazard_zones()
	if zones.is_empty():
		return false
	if distance < 24.0:
		return false
	var last_end := _last_hazard_end_distance()
	if last_end < 0.0 or distance > last_end:
		return false
	return true


func _add_train_wave_blade(root: Node3D, span: float) -> MeshInstance3D:
	var existing := root.get_node_or_null("TrainWaveBlade") as MeshInstance3D
	if existing != null:
		return existing
	var top_y := float(root.get_meta("blade_top", TRAIN_GATE_TOP))
	var blade := MeshInstance3D.new()
	blade.name = "TrainWaveBlade"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.13
	mesh.bottom_radius = 0.13
	mesh.height = span * 0.9
	mesh.radial_segments = 18
	mesh.rings = 1
	var mat := _make_wave_energy_material(Color(1.0, 0.86, 0.38, 0.96), Color(1.0, 0.68, 0.18), 5.8, 0.96)
	mesh.material = mat
	blade.mesh = mesh
	blade.material_override = mat
	blade.rotation_degrees.z = 90.0
	blade.position = Vector3(0.0, top_y - 0.2, 0.16)
	blade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(blade)
	var glow := MeshInstance3D.new()
	glow.name = "TrainWaveBladeTrail"
	var glow_mesh := CylinderMesh.new()
	glow_mesh.top_radius = 0.05
	glow_mesh.bottom_radius = 0.18
	glow_mesh.height = 1.35
	glow_mesh.radial_segments = 12
	var glow_mat := _make_wave_energy_material(Color(1.0, 0.55, 0.22, 0.32), Color(1.0, 0.42, 0.12), 2.8, 0.32)
	glow_mesh.material = glow_mat
	glow.mesh = glow_mesh
	glow.material_override = glow_mat
	glow.rotation_degrees.z = 90.0
	glow.position = Vector3(0.0, top_y - 0.95, 0.12)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(glow)
	return blade


func _update_train_blade_gates() -> void:
	var near_lo := track_distance - 8.0
	var near_hi := track_distance + 70.0
	for obstacle in obstacles:
		var otype := String(obstacle.get("type", ""))
		if otype not in ["train", "train_moving"]:
			continue
		var node := obstacle.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		if not bool(node.get_meta("has_wave_blade", false)):
			continue
		var dist := float(obstacle.get("distance", 0.0)) + float(obstacle.get("move_offset", 0.0))
		if dist < near_lo or dist > near_hi:
			continue
		obstacle["blade_top"] = float(node.get_meta("blade_top", TRAIN_GATE_TOP))
		var blade := node.get_node_or_null("TrainWaveBlade") as MeshInstance3D
		if blade == null:
			blade = _add_train_wave_blade(node, TRAIN_GATE_BLADE_SPAN)
		var top_y := float(obstacle.get("blade_top", TRAIN_GATE_TOP))
		var y := _slide_blade_local_y(obstacle)
		blade.position.y = y
		var blocking := _slide_blade_is_blocking(obstacle)
		blade.scale = Vector3(1.0, 1.4 if blocking else 0.9, 1.0)
		var mat := blade.get_active_material(0) as StandardMaterial3D
		if mat:
			# 落下挡路：血红刀；上方可过：金黄光刃
			mat.albedo_color = Color(1.0, 0.28, 0.32, 0.96) if blocking else Color(1.0, 0.82, 0.35, 0.92)
			mat.emission = Color(1.0, 0.12, 0.18) if blocking else Color(1.0, 0.72, 0.2)
			mat.emission_energy_multiplier = 6.8 if blocking else 5.0
		var trail := node.get_node_or_null("TrainWaveBladeTrail") as MeshInstance3D
		if trail:
			trail.visible = blocking or _slide_blade_phase(obstacle) < 0.42
			trail.position.y = lerpf(y, top_y - 0.2, 0.42)
			var th := maxf(top_y - y, 0.4)
			trail.scale = Vector3(th / 1.35, 1.0, th / 1.35)
		var wave_field := node.get_node_or_null("TrainGateWaveField") as Node3D
		if wave_field != null:
			var phase := _slide_blade_phase(obstacle)
			for child in wave_field.get_children():
				if not String(child.name).begins_with("TrainGateWave"):
					continue
				var idx := int(String(child.name).get_slice("_", 2))
				child.position.y = 0.62 + float(idx) * 0.34 + sin(elapsed * 5.5 + phase * TAU + float(idx) * 0.8) * 0.08
				var wmat := (child as MeshInstance3D).get_active_material(0) as StandardMaterial3D
				if wmat:
					var pulse := 0.72 + sin(elapsed * 7.0 + float(idx)) * 0.28
					wmat.emission_energy_multiplier = (6.2 if blocking else 4.4) * pulse


func _update_train_moving_props(delta: float) -> void:
	for obstacle in obstacles:
		if String(obstacle.get("type", "")) != "train_moving":
			continue
		var node := obstacle.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		if not bool(node.get_meta("train_spin", false)):
			continue
		var visual := node.get_node_or_null("RoadPropObstacle") as Node3D
		if visual == null:
			visual = node.get_node_or_null("TrainRoadBlockAsset") as Node3D
		if visual != null:
			visual.rotation_degrees.y += 52.0 * delta


func _update_procedural_obstacle_fx(delta: float) -> void:
	var pulse := 0.82 + sin(elapsed * 4.2) * 0.18
	for obstacle in obstacles:
		if bool(obstacle.get("hit", false)):
			continue
		var node := obstacle.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var dist := float(obstacle.get("distance", 0.0)) + float(obstacle.get("move_offset", 0.0))
		if absf(track_distance - dist) > 48.0:
			continue
		var otype := String(obstacle.get("type", ""))
		if otype == "energy_ring" or bool(node.get_meta("energy_ring_fx", false)):
			var ring := node.get_node_or_null("EnergyRingModel") as Node3D
			if ring != null:
				ring.rotation.y += delta * 1.35
				for bolt in ring.get_children():
					if String(bolt.name).begins_with("EnergyRingBolt"):
						bolt.rotation_degrees.z += delta * (48.0 if int(bolt.name.get_slice("_", 2)) % 2 == 0 else -42.0)
		if otype == "wave_arc_slide" or bool(node.get_meta("wave_arc_fx", false)):
			var glow := node.find_child("WaveArcGlow", true, false) as MeshInstance3D
			if glow != null:
				var mat := glow.material_override as StandardMaterial3D
				if mat != null:
					mat.emission_energy_multiplier = 1.4 * pulse


func _update_meteorite_gate_drops(delta: float) -> void:
	var near_lo := track_distance - 6.0
	var near_hi := track_distance + 62.0
	for obstacle in obstacles:
		if String(obstacle.get("type", "")) != "meteorite_gate":
			continue
		if int(obstacle.get("gate_drops_left", 0)) <= 0:
			continue
		var gate_dist := float(obstacle.get("distance", 0.0)) + float(obstacle.get("move_offset", 0.0))
		if gate_dist < near_lo or gate_dist > near_hi:
			continue
		var timer := float(obstacle.get("gate_drop_timer", 0.0)) - delta
		if timer > 0.0:
			obstacle["gate_drop_timer"] = timer
			continue
		var drop_index := int(obstacle.get("gate_drop_index", 0))
		var rng := RandomNumberGenerator.new()
		rng.seed = int(obstacle.get("gate_rng_seed", 1)) + drop_index * 17
		var lane: int = int(LANES[rng.randi() % LANES.size()])
		_spawn_meteor_gate_drop(obstacle, lane, rng)
		obstacle["gate_drops_left"] = int(obstacle.get("gate_drops_left", 0)) - 1
		obstacle["gate_drop_index"] = drop_index + 1
		var interval := float(obstacle.get("gate_drop_interval", 1.05))
		obstacle["gate_drop_timer"] = interval * rng.randf_range(0.72, 1.18)


func _spawn_meteor_gate_drop(gate: Dictionary, lane: int, rng: RandomNumberGenerator) -> void:
	var gate_dist := float(gate.get("distance", 0.0))
	var layer := int(gate.get("layer", 0))
	var drop_dist := gate_dist + rng.randf_range(-6.0, 14.0)
	var air_y := rng.randf_range(11.0, 19.0)
	var drop_item := {
		"type": "meteorite",
		"lane": lane,
		"distance": drop_dist,
		"layer": layer,
		"fall_roll": true,
		"span": LANE_WIDTH * rng.randf_range(0.48, 0.76),
		"meteor_state": "falling",
		"meteor_air_y": air_y,
		"y_offset": air_y,
		"meteor_fall_speed": rng.randf_range(12.0, 32.0),
		"fall_trigger_ahead": 999.0,
	}
	_register_obstacle(drop_item)
	camera_shake = maxf(camera_shake, 0.06)


func _pre_run_briefing_text() -> String:
	var dest := String(mission.get("target_hearth", "")).strip_edges()
	if dest == "" and LevelConfig != null and LevelConfig.has_method("get_outpost_meta"):
		var meta: Dictionary = LevelConfig.get_outpost_meta(Global.runner_location_id)
		dest = String(meta.get("name", "")).strip_edges()
	if dest == "":
		dest = "未知据点"
	var cargo := String(mission.get("cargo_name", "物资")).strip_edges()
	if cargo == "":
		cargo = "物资"
	var load_n := int(mission.get("cargo_load", 0))
	var cargo_line := "运输货物：%s ×%d" % [cargo, load_n] if load_n > 0 else "运输货物：%s" % cargo
	var task_type := String(mission.get("task_type_zh", mission.get("task_type", "补给"))).strip_edges()
	var obs_count := maxi(_smash_obstacle_total, 0)
	if obs_count <= 0:
		obs_count = obstacles.size()
	return "目的地：%s\n%s\n运输类型：%s\n障碍物：%d" % [dest, cargo_line, task_type, obs_count]


func _update_meteor_fall_roll(delta: float) -> void:
	# 陨石：远处高空 → 接近时坠落 → 贴地滚动朝玩家
	var near_lo := track_distance - 10.0
	var near_hi := track_distance + 85.0
	for obstacle in obstacles:
		if String(obstacle.get("type", "")) != "meteorite":
			continue
		if not bool(obstacle.get("fall_roll", false)):
			continue
		if bool(obstacle.get("hit", false)) or bool(obstacle.get("smashed", false)):
			continue
		var base_dist := float(obstacle.get("distance", 0.0))
		var obs_dist := base_dist + float(obstacle.get("move_offset", 0.0))
		if obs_dist < near_lo or obs_dist > near_hi:
			continue
		_ensure_obstacle_spawned(obstacle)
		var node := obstacle.get("node") as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var state := String(obstacle.get("meteor_state", "sky"))
		var air_y := float(obstacle.get("meteor_air_y", 16.0))
		var ahead := obs_dist - track_distance
		if state == "sky" and ahead <= float(obstacle.get("fall_trigger_ahead", 58.0)):
			state = "falling"
			obstacle["meteor_state"] = state
			obstacle["meteor_fall_speed"] = float(obstacle.get("meteor_fall_speed", 22.0))
		if state == "falling":
			var fall_spd := float(obstacle.get("meteor_fall_speed", 22.0)) + delta * 18.0
			obstacle["meteor_fall_speed"] = fall_spd
			air_y = maxf(air_y - fall_spd * delta, 0.0)
			obstacle["meteor_air_y"] = air_y
			obstacle["y_offset"] = air_y
			_spin_meteorite_visual(node, fall_spd * 0.18 * delta)
			if air_y <= 0.05:
				obstacle["meteor_air_y"] = 0.0
				obstacle["y_offset"] = 0.06
				obstacle["meteor_state"] = "rolling"
				obstacle["moving"] = true
				# 朝玩家滚来（负向偏移）
				if absf(float(obstacle.get("move_speed", 0.0))) < 0.01:
					obstacle["move_speed"] = float(obstacle.get("roll_speed", -5.5))
				camera_shake = maxf(camera_shake, 0.16)
		elif state == "rolling":
			obstacle["y_offset"] = 0.06
			obstacle["meteor_air_y"] = 0.0
			var rolled := float(obstacle.get("meteor_roll_dist", 0.0)) + absf(float(obstacle.get("move_speed", -5.5))) * delta
			obstacle["meteor_roll_dist"] = rolled
			var radius := float(obstacle.get("meteor_radius", 1.0))
			_set_meteorite_roll_angle(node, -rolled / maxf(radius, 0.35))
		else:
			# 仍在高空待命
			obstacle["y_offset"] = air_y
		_place_obstacle_node(obstacle, true)


func _meteorite_spin_node(node: Node3D) -> Node3D:
	if node == null or not is_instance_valid(node):
		return null
	var spin := node.get_node_or_null("MeteoriteObstacleModel/MeteoriteSpin") as Node3D
	if spin != null:
		return spin
	return node.get_node_or_null("MeteoriteObstacleModel") as Node3D


func _spin_meteorite_visual(node: Node3D, delta_angle: float) -> void:
	var spin := _meteorite_spin_node(node)
	if spin != null:
		spin.rotate_x(delta_angle)


func _set_meteorite_roll_angle(node: Node3D, angle: float) -> void:
	var spin := _meteorite_spin_node(node)
	if spin != null:
		spin.rotation.x = angle


func _try_start_emergency_dash() -> void:
	if not _is_emergency_run or not gameplay_active or is_finished or is_failed:
		return
	if _emergency_dash_charges <= 0 or _emergency_dash_timer > 0.0:
		return
	_emergency_dash_charges -= 1
	_emergency_dash_timer = EMERGENCY_DASH_DURATION
	_show_gate_toast("紧急冲刺!")
	_refresh_buff_hud()


func _refresh_buff_hud(delta: float = 0.0) -> void:
	if _buff_hud_panel == null:
		return
	if _settlement_celebration_active:
		if _top_hud_wrap != null:
			_top_hud_wrap.visible = false
		if _run_timer_label != null:
			_run_timer_label.visible = false
		return
	if _top_hud_wrap != null:
		_top_hud_wrap.visible = true

	if _run_timer_label != null:
		if _is_emergency_run and not is_finished and not is_failed:
			var remain := maxf(_run_time - elapsed, 0.0) if gameplay_active else _run_time
			_run_timer_label.visible = true
			_run_timer_label.text = "限时 %0.1fs" % remain
			var urgent := gameplay_active and remain <= 10.0
			_style_buff_label(
				_run_timer_label,
				44 if urgent else 42,
				Color(1.0, 0.42, 0.32) if urgent else Color(1.0, 0.84, 0.38),
				6
			)
		else:
			_run_timer_label.visible = false

	if shield_label:
		if _is_shield_protecting():
			shield_label.text = "开启 · 每0.5秒-1"
			_style_buff_label(shield_label, 18, Color(0.45, 0.98, 1.0), 2)
		elif shield_energy <= 0.001:
			shield_label.text = "无能量 · 拾取防护水晶(+%d)" % int(SHIELD_CRYSTAL_RESTORE)
			_style_buff_label(shield_label, 18, Color(1.0, 0.55, 0.42), 2)
		elif shield_energy < SHIELD_MIN_ACTIVATE - 0.001:
			shield_label.text = "能量不足 · 需≥%d开启" % int(SHIELD_MIN_ACTIVATE)
			_style_buff_label(shield_label, 18, Color(1.0, 0.72, 0.42), 2)
		else:
			shield_label.text = "关闭 · F/盾键开启"
			_style_buff_label(shield_label, 18, Color(0.78, 0.88, 0.96), 2)
	if _shield_energy_label:
		_shield_energy_label.text = "%d/%d" % [int(round(shield_energy)), int(SHIELD_MAX_ENERGY)]
		if shield_energy <= 0.001:
			_style_buff_label(_shield_energy_label, 20, Color(1.0, 0.55, 0.42))
		elif shield_energy < SHIELD_MIN_ACTIVATE - 0.001:
			_style_buff_label(_shield_energy_label, 20, Color(1.0, 0.62, 0.42))
		elif _is_shield_protecting():
			_style_buff_label(_shield_energy_label, 20, Color(0.45, 0.98, 1.0))
		else:
			_style_buff_label(_shield_energy_label, 20, Color(0.55, 0.95, 1.0))
	if shield_bar:
		shield_bar.value = shield_energy
		var fill_color := Color(0.35, 0.88, 1.0)
		if shield_energy <= 0.001:
			fill_color = Color(0.72, 0.28, 0.24)
		elif shield_energy < SHIELD_MIN_ACTIVATE - 0.001:
			fill_color = Color(0.92, 0.38, 0.28)
		elif _is_shield_protecting():
			fill_color = Color(0.42, 0.96, 1.0)
		shield_bar.add_theme_stylebox_override("fill", _make_buff_bar_style(fill_color, fill_color))

	if _speed_boost_bar != null:
		var active := _speed_boost_timer > 0.001
		_speed_boost_bar.visible = active
		if _buff_boost_row != null:
			_buff_boost_row.visible = active
		if active:
			_speed_boost_bar.value = _speed_boost_timer
			var ratio := clampf(_speed_boost_timer / maxf(_speed_boost_duration(), 0.01), 0.0, 1.0)
			var boost_fill := Color(0.98, 0.78, 0.22).lerp(Color(1.0, 0.92, 0.45), ratio)
			_speed_boost_bar.add_theme_stylebox_override("fill", _make_buff_bar_style(boost_fill, boost_fill))
			if _speed_boost_time_label:
				_speed_boost_time_label.text = "提速 %0.1fs" % _speed_boost_timer
				_style_buff_label(_speed_boost_time_label, 18, Color(1.0, 0.88, 0.38), 2)
		elif _speed_boost_time_label:
			_speed_boost_time_label.text = "未激活"
			_style_buff_label(_speed_boost_time_label, 18, Color(0.68, 0.78, 0.88), 2)

	if not _is_emergency_run or _boost_count_label == null:
		return

	_boost_count_label.text = "%d/5" % _speed_boost_cycle
	for i in _boost_pips.size():
		var filled := i < _speed_boost_cycle
		_boost_pips[i].color = Color(0.38, 0.92, 1.0, 0.98) if filled else Color(0.12, 0.18, 0.26, 0.95)

	var has_dash := _emergency_dash_charges > 0
	if _boost_dash_icon_wrap:
		var dash_style := _boost_dash_icon_wrap.get_theme_stylebox("panel") as StyleBoxFlat
		if dash_style:
			if has_dash:
				_boost_dash_pulse += delta * 5.5
				var pulse := 0.72 + sin(_boost_dash_pulse) * 0.28
				dash_style.bg_color = Color(0.10, 0.26, 0.38, 0.96)
				dash_style.border_color = Color(0.55, 0.95, 1.0, pulse)
			else:
				dash_style.bg_color = Color(0.08, 0.12, 0.18, 0.92)
				dash_style.border_color = Color(0.32, 0.48, 0.58, 0.65)
	if _boost_dash_icon:
		if has_dash:
			_boost_dash_icon.text = "×%d" % _emergency_dash_charges
			_style_buff_label(_boost_dash_icon, 24, Color(0.98, 0.98, 1.0), 3)
		else:
			_boost_dash_icon.text = "—"
			_style_buff_label(_boost_dash_icon, 22, Color(0.42, 0.48, 0.54), 2)

	var status_bits: Array[String] = []
	if _speed_boost_timer > 0.0:
		status_bits.append("提速 %0.1fs" % _speed_boost_timer)
	if _emergency_dash_timer > 0.0:
		status_bits.append("冲刺中 %0.1fs" % _emergency_dash_timer)
	if status_bits.is_empty():
		if has_dash:
			status_bits.append("长按前进释放")
		else:
			status_bits.append("集满 5 个解锁冲刺")
	if _boost_status_label:
		_boost_status_label.text = " · ".join(status_bits)


func _collectible_node_alive(node: Node3D) -> bool:
	return (
		node != null
		and is_instance_valid(node)
		and node.is_inside_tree()
		and not node.is_queued_for_deletion()
		and not bool(node.get_meta("_disposed", false))
	)


func _ensure_obstacle_spawned(obstacle: Dictionary) -> void:
	if not bool(obstacle.get("spawn_pending", false)):
		return
	var item: Dictionary = obstacle.get("spawn_item", {})
	if item.is_empty():
		return
	var node := _make_obstacle(
		int(item.get("lane", 0)),
		float(item.get("distance", 0.0)),
		String(item.get("type", "")),
		int(item.get("layer", 0)),
		item
	)
	obstacle["node"] = node
	obstacle.erase("spawn_item")
	obstacle.erase("spawn_pending")
	_place_obstacle_node(obstacle)


func _is_in_shield_hazard_zone() -> bool:
	if _sandstorm_active:
		return true
	for obstacle in obstacles:
		if typeof(obstacle) != TYPE_DICTIONARY:
			continue
		if not bool(obstacle.get("heat_hazard", false)):
			continue
		if bool(obstacle.get("hit", false)):
			continue
		var obs_d: float = float(obstacle.get("distance", 0.0)) + float(obstacle.get("move_offset", 0.0))
		var half := float(obstacle.get("half_depth", 1.2)) + 1.5
		if absf(track_distance - obs_d) <= half:
			return true
	return false


func _try_attach_gate_boosts_for_train(obstacle: Dictionary) -> void:
	var root := obstacle.get("node") as Node3D
	if root == null or not is_instance_valid(root):
		return
	var train_dist := float(obstacle.get("distance", 0.0))
	for collectible in collectibles:
		if collectible.get("collected", false):
			continue
		if not bool(collectible.get("gate_boost", false)):
			continue
		if absf(float(collectible.get("gate_train_dist", -999.0)) - train_dist) > 0.5:
			continue
		if _collectible_node_alive(collectible.get("node") as Node3D):
			continue
		var lane := int(collectible.get("lane", 0))
		var layer := int(collectible.get("layer", 0))
		var y := float(collectible.get("y", _layer_height(layer) + 0.95))
		var boost := _make_speed_boost(lane, train_dist, y, layer)
		if boost.get_parent() != null:
			boost.get_parent().remove_child(boost)
		root.add_child(boost)
		var blade_local_y := float(root.get_meta("blade_top", TRAIN_GATE_TOP)) - 1.08
		boost.position = Vector3(0.0, blade_local_y, 0.34)
		boost.rotation = Vector3.ZERO
		collectible["node"] = boost
		collectible["distance"] = train_dist


func _register_train_gate_shield_crystal(obstacle: Dictionary) -> void:
	var root := obstacle.get("node") as Node3D
	if root == null or not is_instance_valid(root):
		return
	var crystal := root.get_node_or_null("GateShieldCrystal") as Node3D
	if crystal == null:
		return
	for collectible in collectibles:
		if bool(collectible.get("collected", false)):
			continue
		if collectible.get("node") == crystal:
			return
	var dist := float(obstacle.get("distance", 0.0))
	var lane := int(obstacle.get("lane", 0))
	var layer := int(obstacle.get("layer", 0))
	collectibles.append({
		"node": crystal,
		"lane": lane,
		"distance": dist,
		"y": crystal.global_position.y if crystal.is_inside_tree() else _layer_height(layer) + 1.05,
		"layer": layer,
		"kind": "shield_crystal",
		"air": false,
		"gate_train_dist": dist,
		"collected": false,
	})


func _resolve_runner_road_style() -> String:
	if CustomLevels.has_level(Global.runner_location_id):
		var custom_style := CustomLevels.get_road_style(Global.runner_location_id)
		if custom_style != "":
			return Global.normalize_runner_road_style(custom_style)
	var layout_id := _runner_layout_id()
	if layout_id != "":
		var layout_style := String(ObstacleLayout.load_root(layout_id).get("road_style", ""))
		if layout_style != "":
			return Global.normalize_runner_road_style(layout_style)
	var mission_style := String(mission.get("road_style", "")).strip_edges()
	if mission_style != "":
		return Global.normalize_runner_road_style(mission_style)
	# 晶砂荒漠正式关卡统一全息能量轨；勿回退到详情页全局选项（可能是 coarse_desert）
	if Global.runner_planet_id == "glass_desert":
		return "holographic"
	return Global.get_runner_road_style()


func _update_shield_energy_drain(delta: float) -> void:
	if not shield_active or is_failed or is_finished or is_intro or not gameplay_active:
		return
	if _tutorial_paused:
		return
	var rate := SHIELD_DRAIN_PER_SEC
	if _is_in_shield_hazard_zone():
		rate = SHIELD_HAZARD_DRAIN_PER_SEC
	shield_energy = maxf(shield_energy - rate * delta, 0.0)
	# 低于开启门槛自动关闭（鼓励先囤能量再开）
	if shield_energy < SHIELD_MIN_ACTIVATE - 0.001:
		shield_active = false
		if not _shield_warned_empty:
			_shield_warned_empty = true
			_show_strike_warning("防护罩能量不足 · 已关闭（需≥%d再开）" % int(SHIELD_MIN_ACTIVATE))


func _midground_visible_ahead() -> float:
	if _is_reservoir_location():
		return 240.0
	return MIDGROUND_REVEAL_AHEAD if _uses_near_far_light_split() else MIDGROUND_VISIBLE_AHEAD


func _update_scene_dressing_visibility() -> void:
	_update_midground_visibility()
	_update_runway_side_light_visibility()


func _update_runway_side_light_visibility() -> void:
	if _runway_side_lights_root == null:
		return
	for child in _runway_side_lights_root.get_children():
		if not child is Node3D:
			continue
		var node := child as Node3D
		var anchor_d := float(node.get_meta("path_distance", -1.0))
		if anchor_d < 0.0:
			continue
		var delta_d := anchor_d - track_distance
		node.visible = delta_d >= -20.0 and delta_d <= 98.0
		if not node.visible:
			continue
		var light := node.get_node_or_null("WarmLantern") as OmniLight3D
		if light == null:
			continue
		var energy := 0.78
		if delta_d > 68.0:
			energy *= clampf(1.0 - (delta_d - 68.0) / 30.0, 0.28, 1.0)
		elif delta_d < 10.0:
			energy *= clampf(0.55 + delta_d / 10.0 * 0.45, 0.55, 1.0)
		light.light_energy = energy


func _update_midground_visibility() -> void:
	var roots: Array[Node3D] = []
	if _side_dressing_root != null:
		roots.append(_side_dressing_root)
	if _ruin_backdrop_root != null:
		roots.append(_ruin_backdrop_root)
	if roots.is_empty():
		return
	_midground_vis_tick += 1
	if _midground_vis_tick < 4:
		return
	_midground_vis_tick = 0
	var ahead := _midground_visible_ahead()
	for root in roots:
		for child in root.get_children():
			if not child is Node3D:
				continue
			var node := child as Node3D
			var anchor_d := float(node.get_meta("path_distance", -1.0))
			if anchor_d < 0.0:
				continue
			var delta_d := anchor_d - track_distance
			if delta_d < MIDGROUND_VISIBLE_BEHIND or delta_d > ahead:
				node.visible = false
				continue
			node.visible = true
			var shade := 1.0
			if _uses_near_far_light_split():
				if delta_d > MIDGROUND_VISIBLE_AHEAD:
					shade = clampf(
						1.0 - (delta_d - MIDGROUND_VISIBLE_AHEAD) / maxf(ahead - MIDGROUND_VISIBLE_AHEAD, 1.0),
						0.0,
						1.0
					)
				if delta_d >= 0.0 and delta_d < 40.0:
					shade *= lerpf(0.84, 1.0, delta_d / 40.0)
				elif delta_d > 90.0:
					shade *= lerpf(1.0, 0.72, clampf((delta_d - 90.0) / 70.0, 0.0, 1.0))
			if shade < 0.98:
				_apply_distant_depth_visual(node, shade)


func _emit_landing_particles() -> void:
	if not landing_particles:
		return
	landing_particles.restart()
	landing_particles.emitting = true

func _make_ember_flame_material(
	core: Color,
	flame: Color,
	tip: Color,
	inner: float,
	outer: float,
	flow: float,
	tongue: float,
	vert_soft: float = 0.0
) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/maps/route_levels/runner_60s/ember_flame_aura.gdshader")
	mat.set_shader_parameter("core_color", core)
	mat.set_shader_parameter("flame_color", flame)
	mat.set_shader_parameter("tip_color", tip)
	mat.set_shader_parameter("ring_inner", inner)
	mat.set_shader_parameter("ring_outer", outer)
	mat.set_shader_parameter("flow_speed", flow)
	mat.set_shader_parameter("tongue_strength", tongue)
	mat.set_shader_parameter("vertical_soft", vert_soft)
	mat.set_shader_parameter("intensity", 1.0)
	mat.set_shader_parameter("pulse", 1.0)
	return mat

func _make_ember_flame_disc(mat: ShaderMaterial, diameter: float) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(diameter, diameter)
	quad.material = mat
	mi.mesh = quad
	mi.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

func _build_ember_flame_aura() -> void:
	if player == null:
		return
	if _ember_fx_root != null and is_instance_valid(_ember_fx_root):
		_ember_fx_root.queue_free()
	_ember_fx_root = Node3D.new()
	_ember_fx_root.name = "EmberFlameAura"
	player.add_child(_ember_fx_root)

	# 脚下主火焰光圈：跳动火舌质感
	_foot_flame_mat = _make_ember_flame_material(
		Color(1.0, 0.96, 0.88, 1.0),
		Color(1.0, 0.48, 0.18, 0.95),
		Color(0.4, 0.75, 1.0, 0.0),
		0.12,
		1.05,
		4.4,
		0.95
	)
	_foot_flame_mesh = _make_ember_flame_disc(_foot_flame_mat, 1.38)
	_foot_flame_mesh.name = "FootFlameRing"
	_foot_flame_mesh.position = Vector3(0.0, 0.04, 0.04)
	_ember_fx_root.add_child(_foot_flame_mesh)

	# 脚下第二层反向火舌
	_foot_flame_mat_b = _make_ember_flame_material(
		Color(1.0, 0.9, 0.7, 0.95),
		Color(1.0, 0.32, 0.12, 0.82),
		Color(0.55, 0.7, 1.0, 0.0),
		0.22,
		1.12,
		-5.2,
		1.0
	)
	_foot_flame_mesh_b = _make_ember_flame_disc(_foot_flame_mat_b, 1.12)
	_foot_flame_mesh_b.name = "FootFlameRingInner"
	_foot_flame_mesh_b.position = Vector3(0.0, 0.08, 0.02)
	_ember_fx_root.add_child(_foot_flame_mesh_b)

	# 周身蝴蝶形光晕：柔和透亮，不挡角色
	_body_flame_mat = ShaderMaterial.new()
	_body_flame_mat.shader = load("res://assets/maps/route_levels/runner_60s/ember_butterfly_aura.gdshader")
	_body_flame_mat.set_shader_parameter("core_color", Color(1.0, 0.96, 0.92, 0.72))
	_body_flame_mat.set_shader_parameter("flame_color", Color(1.0, 0.48, 0.28, 0.58))
	_body_flame_mat.set_shader_parameter("tip_color", Color(1.0, 0.32, 0.18, 0.0))
	_body_flame_mat.set_shader_parameter("flow_speed", 1.8)
	_body_flame_mat.set_shader_parameter("wing_spread", 1.0)
	_body_flame_mat.set_shader_parameter("flap", 0.28)
	_body_flame_mat.set_shader_parameter("soft_edge", 0.22)
	_body_flame_mat.set_shader_parameter("intensity", 0.52)
	_body_flame_mat.set_shader_parameter("pulse", 1.0)
	_body_flame_mesh = MeshInstance3D.new()
	_body_flame_mesh.name = "BodyButterflyAura"
	var body_quad := QuadMesh.new()
	body_quad.size = Vector2(1.45, 1.32)
	body_quad.material = _body_flame_mat
	_body_flame_mesh.mesh = body_quad
	_body_flame_mesh.position = Vector3(0.0, 0.92, 0.18)
	_body_flame_mesh.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	_body_flame_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ember_fx_root.add_child(_body_flame_mesh)
	_ember_fx_root.visible = false

func _update_ember_flame_aura(delta: float) -> void:
	if _ember_fx_root == null:
		return
	var sliding := _is_sliding()
	var air := not _is_on_ground()
	var rush := _is_fork_rushing() or _finish_sprint_timer > 0.0 or _emergency_dash_timer > 0.0
	var rhythm: Dictionary = Global.get_bgm_rhythm(delta)
	var kick := float(rhythm.get("kick", 0.0))
	var bass := float(rhythm.get("bass", 0.0))
	# 拍点快起慢落，视觉更跟得上鼓点
	var kick_follow := 10.0 if kick > _aura_kick_smooth else 4.5
	_aura_kick_smooth = lerpf(_aura_kick_smooth, kick, 1.0 - exp(-kick_follow * maxf(delta, 0.001)))
	var beat := _aura_kick_smooth
	var pulse := float(rhythm.get("pulse", 1.0))
	pulse = lerpf(0.88, 1.18, clampf(pulse * 0.35 + beat * 0.35, 0.0, 1.0))
	if rush:
		pulse *= 1.06
	var intensity := 0.82 if rush else (0.76 if air else 0.80)
	intensity *= 0.94 + beat * 0.10 + bass * 0.06
	if sliding:
		intensity *= 0.72
		pulse *= 0.9

	if _foot_flame_mat:
		_foot_flame_mat.set_shader_parameter("pulse", pulse)
		_foot_flame_mat.set_shader_parameter("intensity", intensity * (0.92 + beat * 0.08))
		_foot_flame_mat.set_shader_parameter("flow_speed", (4.2 if rush else 3.4) + beat * 0.45)
		_foot_flame_mat.set_shader_parameter("tongue_strength", 0.72 + beat * 0.05)
	if _foot_flame_mat_b:
		var inner_pulse := lerpf(0.90, 1.06, clampf(beat * 0.18 + bass * 0.12, 0.0, 1.0))
		_foot_flame_mat_b.set_shader_parameter("pulse", inner_pulse)
		_foot_flame_mat_b.set_shader_parameter("intensity", intensity * (0.88 + beat * 0.08))
		_foot_flame_mat_b.set_shader_parameter("flow_speed", (-4.2 if rush else -3.5) - beat * 0.35)
	if _body_flame_mat:
		_body_flame_mat.set_shader_parameter("pulse", lerpf(0.88, 1.08, beat))
		_body_flame_mat.set_shader_parameter("intensity", intensity * (0.48 if sliding else 0.52) * (1.0 + beat * 0.18))
		_body_flame_mat.set_shader_parameter("flap", (0.32 if rush else 0.22) + beat * 0.10)
		_body_flame_mat.set_shader_parameter("wing_spread", (1.02 if rush else 0.98) + beat * 0.04)
		_body_flame_mat.set_shader_parameter("flow_speed", 1.4 + beat * 1.2 + bass * 0.6)

	var beat_scale := 1.0 + beat * 0.06 + bass * 0.02
	var foot_scale := Vector3(0.38, 0.82, 0.48) if sliding else (Vector3(0.72, 0.92, 0.72) if air else Vector3(0.82, 1.0, 0.82))
	foot_scale *= beat_scale
	var foot_y := 0.02 if sliding else (0.12 if air else 0.04)
	foot_y += beat * 0.03
	var spin_speed := 36.0 + beat * 48.0 + bass * 24.0
	var t := Global.get_bgm_playback_sec() if Global.is_bgm_playing() else Time.get_ticks_msec() * 0.001
	if _foot_flame_mesh:
		_foot_flame_mesh.scale = foot_scale
		_foot_flame_mesh.position = Vector3(0.0, foot_y, 0.16 if sliding else 0.04)
		_foot_flame_mesh.rotation_degrees.y = fmod(t * spin_speed, 360.0)
	if _foot_flame_mesh_b:
		_foot_flame_mesh_b.scale = foot_scale * (0.82 + beat * 0.1)
		_foot_flame_mesh_b.position = Vector3(0.0, foot_y + 0.03 + beat * 0.02, 0.12 if sliding else 0.02)
		_foot_flame_mesh_b.rotation_degrees.y = fmod(-t * (spin_speed * 1.35), 360.0)
	if _body_flame_mesh:
		var body_y := 0.55 if sliding else (1.05 if air else 0.95)
		body_y += beat * 0.05
		_body_flame_mesh.position = Vector3(0.0, body_y, 0.08 if sliding else 0.12)
		# 滑铲时翅膀收拢变矮；站立时保持蝴蝶竖立，并随拍点轻颤
		if sliding:
			_body_flame_mesh.scale = Vector3(0.62, 0.48, 1.0) * (1.0 + beat * 0.12)
			_body_flame_mesh.rotation_degrees = Vector3(-25.0, 180.0, 0.0)
		else:
			var body_s := 1.0 + beat * 0.16
			_body_flame_mesh.scale = Vector3(body_s, body_s * (1.0 + beat * 0.06), 1.0)
			_body_flame_mesh.rotation_degrees = Vector3(
				(8.0 if air else 0.0) - beat * 4.0,
				180.0,
				sin(t * TAU * Global.get_bgm_bpm() / 60.0) * (3.0 + beat * 6.0)
			)

func _make_foot_spark_draw_mesh(size: float, color: Color, emission: Color, energy: float) -> Mesh:
	var mesh := SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2.0
	mesh.radial_segments = 6
	mesh.rings = 3
	var sm := StandardMaterial3D.new()
	sm.albedo_color = color
	sm.emission_enabled = true
	sm.emission = emission
	sm.emission_energy_multiplier = energy
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh.material = sm
	return mesh

func _make_foot_spark_twinkle_ramp() -> GradientTexture1D:
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.15, 0.45, 0.75, 1.0])
	grad.colors = PackedColorArray([
		Color(1.0, 0.82, 0.35, 0.0),
		Color(1.0, 0.95, 0.72, 1.0),
		Color(1.0, 0.48, 0.16, 0.42),
		Color(1.0, 0.78, 0.28, 0.82),
		Color(0.85, 0.28, 0.08, 0.0),
	])
	var tex := GradientTexture1D.new()
	tex.gradient = grad
	return tex

func _make_foot_spark_particles() -> GPUParticles3D:
	# 火焰光圈附近少量火星点缀
	var particles := GPUParticles3D.new()
	particles.name = "FootFlameSparks"
	particles.position = Vector3(0.0, 0.05, 0.06)
	particles.amount = 10
	particles.lifetime = 0.32
	particles.preprocess = 0.10
	particles.emitting = false
	particles.local_coords = true
	particles.fixed_fps = 30
	particles.visibility_aabb = AABB(Vector3(-3, -1.5, -3), Vector3(6, 4, 6))
	particles.draw_pass_1 = _make_foot_spark_draw_mesh(
		0.032,
		Color(1.0, 0.78, 0.42, 0.92),
		Color(1.0, 0.55, 0.18),
		6.4
	)
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	material.emission_ring_radius = 0.48
	material.emission_ring_inner_radius = 0.22
	material.emission_ring_height = 0.05
	material.emission_ring_axis = Vector3(0.0, 1.0, 0.0)
	material.direction = Vector3(0.0, 1.0, 0.0)
	material.spread = 35.0
	material.initial_velocity_min = 0.35
	material.initial_velocity_max = 1.4
	material.gravity = Vector3(0.0, -1.2, 0.0)
	material.scale_min = 0.4
	material.scale_max = 1.1
	material.color = Color(1.0, 0.72, 0.32, 0.9)
	material.color_ramp = _make_foot_spark_twinkle_ramp()
	particles.process_material = material
	return particles

func _make_body_spark_particles() -> GPUParticles3D:
	# 蝴蝶光晕外围少量火星
	var particles := GPUParticles3D.new()
	particles.name = "BodyButterflySparks"
	particles.position = Vector3(0.0, 0.95, 0.1)
	particles.amount = 14
	particles.lifetime = 0.48
	particles.preprocess = 0.12
	particles.emitting = false
	particles.local_coords = true
	particles.fixed_fps = 30
	particles.visibility_aabb = AABB(Vector3(-4, -3, -3), Vector3(8, 6, 6))
	particles.draw_pass_1 = _make_foot_spark_draw_mesh(
		0.024,
		Color(1.0, 0.72, 0.38, 0.86),
		Color(1.0, 0.42, 0.16),
		5.6
	)
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(0.95, 0.75, 0.08)
	material.direction = Vector3(0.0, 0.35, 0.0)
	material.spread = 70.0
	material.initial_velocity_min = 0.08
	material.initial_velocity_max = 0.55
	material.gravity = Vector3(0.0, 0.15, 0.0)
	material.scale_min = 0.3
	material.scale_max = 0.9
	material.color = Color(1.0, 0.62, 0.28, 0.78)
	material.color_ramp = _make_foot_spark_twinkle_ramp()
	particles.process_material = material
	return particles

func _make_rush_aura_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "RushAura"
	particles.position = Vector3(0.0, 0.55, 0.1)
	particles.amount = 48
	particles.lifetime = 0.34
	particles.preprocess = 0.1
	particles.emitting = false
	particles.visibility_aabb = AABB(Vector3(-4, -3, -4), Vector3(8, 8, 10))
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.05, 0.05, 0.42)
	var sm := StandardMaterial3D.new()
	sm.albedo_color = Color(0.55, 0.9, 1.0, 0.75)
	sm.emission_enabled = true
	sm.emission = Color(0.35, 0.8, 1.0)
	sm.emission_energy_multiplier = 2.8
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = sm
	particles.draw_pass_1 = mesh
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.72
	material.direction = Vector3(0.0, 0.05, 1.0)
	material.spread = 28.0
	material.initial_velocity_min = 6.0
	material.initial_velocity_max = 13.0
	material.gravity = Vector3(0.0, 0.0, 0.0)
	material.scale_min = 0.5
	material.scale_max = 1.35
	material.color = Color(0.55, 0.88, 1.0, 0.7)
	particles.process_material = material
	return particles

func _make_trail_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "SpeedTrail"
	particles.position = Vector3(0, -0.15, 0.45)
	particles.amount = 24
	particles.lifetime = 0.22
	particles.preprocess = 0.12
	particles.emitting = true
	particles.draw_pass_1 = _make_particle_mesh(0.028)

	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0, 0, 1)
	material.spread = 10.0
	material.initial_velocity_min = 3.5
	material.initial_velocity_max = 6.5
	material.gravity = Vector3(0, 0, 0)
	material.scale_min = 0.25
	material.scale_max = 0.75
	material.color = Color(1.0, 0.62, 0.18, 0.38)
	particles.process_material = material
	_trail_process_mat = material
	return particles

func _make_landing_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "LandingBurst"
	particles.position = Vector3(0, -0.68, 0)
	particles.amount = 12
	particles.lifetime = 0.28
	particles.one_shot = true
	particles.emitting = false
	particles.draw_pass_1 = _make_particle_mesh(0.045)

	var material := ParticleProcessMaterial.new()
	material.direction = Vector3(0, 1, 0)
	material.spread = 80.0
	material.initial_velocity_min = 1.8
	material.initial_velocity_max = 4.2
	material.gravity = Vector3(0, -7.5, 0)
	material.scale_min = 0.55
	material.scale_max = 1.4
	material.color = Color(0.95, 0.98, 1.0, 0.85)
	particles.process_material = material
	return particles

func _make_particle_mesh(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = _make_material(Color(0.55, 0.95, 1.0), Color(0.25, 0.9, 1.0), 1.2)
	return mesh

func _build_finish_gate() -> void:
	_finish_line_distance = maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)
	_finish_silhouette_mats.clear()
	_finish_portal_mats.clear()
	_finish_title_mat = null
	_finish_sky_mat = null
	_finish_silhouette_billboard = null
	_finish_silhouette_billboard_mat = null
	_finish_silhouette_rim_mat = null
	_finish_outpost_title_glow = null
	_finish_outpost_title_bloom = null
	_finish_outpost_model_mats.clear()
	_finish_outpost_height = 21.0
	_finish_title_z = -5.2

	_finish_portal_root = Node3D.new()
	_finish_portal_root.name = "FinishPortalRoot"
	var portal_placed := _world_on_path(_finish_line_distance + FINISH_PORTAL_DEPTH, 0.0, 0.0)
	_finish_portal_root.position = portal_placed["pos"]
	_finish_portal_root.rotation.y = float(portal_placed["yaw"])
	track_root.add_child(_finish_portal_root)

	# 终点：彩色抠图据点（防御/中继/医疗）或既有剪影，贴图按 location 区分
	_finish_silhouette_billboard = _make_finish_silhouette_billboard()
	if _finish_silhouette_billboard:
		_finish_portal_root.add_child(_finish_silhouette_billboard)

	# 标题浮在建筑上方（英文据点名，如 DEFENSE OUTPOST）
	_finish_title_base_y = _finish_outpost_height * 0.82 + 3.4
	var title_text := _finish_outpost_title_en().to_upper()
	_finish_outpost_title_bloom = _make_finish_outpost_title_layer(
		"FinishOutpostTitleBloom",
		title_text,
		Color(1.0, 0.62, 0.92, 0.32),
		Color(0.92, 0.42, 1.0, 0.55),
		48
	)
	_finish_outpost_title_glow = _make_finish_outpost_title_layer(
		"FinishOutpostTitleGlow",
		title_text,
		Color(0.92, 0.78, 1.0, 0.62),
		Color(0.78, 0.38, 0.98, 0.82),
		32
	)
	_finish_outpost_title_rig = _make_finish_outpost_title_layer(
		"FinishOutpostTitle",
		title_text,
		Color(1.0, 0.97, 1.0, 1.0),
		Color(0.95, 0.55, 0.88, 0.95),
		18
	)
	_finish_outpost_title_rig.render_priority = 4
	_finish_title_scale_cached = -1.0


func _make_finish_outpost_title_layer(
	node_name: String,
	title_text: String,
	fill: Color,
	outline: Color,
	outline_size: int
) -> Label3D:
	var title := Label3D.new()
	title.name = node_name
	title.text = title_text
	title.font_size = 520
	title.pixel_size = 0.0065
	title.modulate = fill
	title.outline_modulate = outline
	title.outline_size = outline_size
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector3(0.0, _finish_title_base_y, _finish_title_z)
	title.no_depth_test = true
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.render_priority = 2
	title.scale = Vector3.ONE * FINISH_TITLE_BASE_SCALE
	_finish_portal_root.add_child(title)
	return title


func _refresh_finish_hearth_scene_path() -> void:
	var loc := String(Global.runner_location_id)
	var candidates: Array[String] = []
	if LevelConfig != null and LevelConfig.has_method("get_location_hearth_model"):
		candidates.append(String(LevelConfig.get_location_hearth_model(loc)).strip_edges())
	if _hearth_scene_path.strip_edges() != "":
		candidates.append(_hearth_scene_path.strip_edges())
	candidates.append("res://3d素材/居民穹顶据点 3d model.glb")
	candidates.append("res://mvp素材第一批/居民穹顶3d.glb")
	var seen: Dictionary = {}
	for path in candidates:
		if path == "" or seen.has(path):
			continue
		seen[path] = true
		if ResourceLoader.exists(path) or IMPORTED_SCENE_FALLBACKS.has(path):
			_hearth_scene_path = path
			return
	push_warning("Finish hearth 3D model missing for location '%s'" % loc)


func _load_hearth_dome_texture(kind: String) -> Texture2D:
	for path in HEARTH_DOME_TEXTURES.get(kind, []):
		if path == "":
			continue
		if ResourceLoader.exists(path):
			var tex := ResourceLoader.load(path) as Texture2D
			if tex != null:
				return tex
	return null

func _make_hearth_dome_surface_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var albedo := _load_hearth_dome_texture("basecolor")
	var normal := _load_hearth_dome_texture("normal")
	var orm := _load_hearth_dome_texture("orm")
	if albedo != null:
		mat.albedo_texture = albedo
		mat.albedo_color = Color(0.92, 0.96, 1.0, 1.0)
	else:
		mat.albedo_color = Color(0.22, 0.38, 0.52, 1.0)
	if normal != null:
		mat.normal_enabled = true
		mat.normal_texture = normal
	if orm != null:
		mat.roughness_texture = orm
		mat.metallic_texture = orm
		mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
	mat.metallic = 0.42
	mat.roughness = 0.34
	mat.emission_enabled = true
	mat.emission = Color(0.18, 0.42, 0.62)
	mat.emission_energy_multiplier = 0.38
	mat.disable_fog = true
	return mat

func _apply_dome_hearth_textures(root: Node3D) -> bool:
	var dome_mat := _make_hearth_dome_surface_material()
	var applied := dome_mat.albedo_texture != null
	for gi_node in root.find_children("*", "MeshInstance3D", true, false):
		var gi := gi_node as MeshInstance3D
		if gi.mesh == null:
			continue
		for surface_idx in gi.mesh.get_surface_count():
			var patch := dome_mat.duplicate() as StandardMaterial3D
			gi.set_surface_override_material(surface_idx, patch)
			_finish_outpost_model_mats.append(patch)
	return applied

func _hearth_model_looks_untextured(root: Node3D) -> bool:
	var mesh_count := 0
	for gi_node in root.find_children("*", "MeshInstance3D", true, false):
		var gi := gi_node as MeshInstance3D
		if gi.mesh == null:
			continue
		mesh_count += 1
		for surface_idx in gi.mesh.get_surface_count():
			var mat: Material = gi.get_surface_override_material(surface_idx)
			if mat == null:
				mat = gi.mesh.surface_get_material(surface_idx)
			if mat is StandardMaterial3D:
				var std := mat as StandardMaterial3D
				if std.albedo_texture != null:
					return false
				var c := std.albedo_color
				if c.r < 0.88 or c.g < 0.88 or c.b < 0.88:
					return false
	if mesh_count == 0:
		return true
	return true

func _make_procedural_habitat_dome() -> Node3D:
	var root := Node3D.new()
	root.name = "FinishHabitatDomeProcedural"
	var dome_mat := _make_hearth_dome_surface_material()
	var base_mat := _make_material(Color(0.10, 0.13, 0.17), Color(0.28, 0.48, 0.68), 0.45)
	var glow_mat := _make_material(Color(0.95, 0.72, 0.32), Color(1.0, 0.82, 0.42), 1.6)

	var platform := MeshInstance3D.new()
	var plat_mesh := CylinderMesh.new()
	plat_mesh.top_radius = 13.5
	plat_mesh.bottom_radius = 15.0
	plat_mesh.height = 3.0
	plat_mesh.radial_segments = 28
	plat_mesh.material = base_mat
	platform.mesh = plat_mesh
	platform.position.y = 1.5
	platform.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(platform)

	var ring := MeshInstance3D.new()
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 12.8
	ring_mesh.outer_radius = 13.6
	ring_mesh.rings = 8
	ring_mesh.ring_segments = 32
	ring_mesh.material = glow_mat
	ring.mesh = ring_mesh
	ring.rotation.x = PI * 0.5
	ring.position.y = 3.2
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(ring)

	var dome := MeshInstance3D.new()
	var dome_mesh := SphereMesh.new()
	dome_mesh.radius = 12.5
	dome_mesh.height = 14.0
	dome_mesh.radial_segments = 36
	dome_mesh.rings = 18
	dome_mesh.material = dome_mat
	dome.mesh = dome_mesh
	dome.position.y = 9.0
	dome.scale = Vector3(1.0, 0.78, 1.0)
	dome.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(dome)

	var spire := MeshInstance3D.new()
	var spire_mesh := CylinderMesh.new()
	spire_mesh.top_radius = 0.18
	spire_mesh.bottom_radius = 0.42
	spire_mesh.height = 3.6
	spire_mesh.material = base_mat
	spire.mesh = spire_mesh
	spire.position.y = 17.8
	spire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(spire)

	var beacon := MeshInstance3D.new()
	var beacon_mesh := SphereMesh.new()
	beacon_mesh.radius = 0.55
	beacon_mesh.material = glow_mat
	beacon.mesh = beacon_mesh
	beacon.position.y = 19.6
	beacon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(beacon)

	for i in 10:
		var win := MeshInstance3D.new()
		var win_mesh := BoxMesh.new()
		win_mesh.size = Vector3(1.4, 1.0, 0.18)
		win_mesh.material = glow_mat
		win.mesh = win_mesh
		var ang := float(i) / 10.0 * TAU
		win.position = Vector3(cos(ang) * 12.2, 4.8 + float(i % 3) * 1.6, sin(ang) * 12.2)
		win.look_at(win.position + Vector3(cos(ang), 0.0, sin(ang)), Vector3.UP)
		win.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(win)
	return root

func _spawn_finish_outpost_hearth_model() -> bool:
	_finish_outpost_model_mats.clear()
	if _finish_portal_root == null:
		return false
	var path := _hearth_scene_path.strip_edges()
	var spawned: Node3D = null
	if path != "":
		var scene := _load_runner_scene(path, false)
		if scene != null:
			var anchor := Node3D.new()
			anchor.name = "FinishOutpostModel"
			_finish_portal_root.add_child(anchor)
			_add_scaled_model_visual(
				anchor,
				scene,
				"FinishHearth",
				92.0,
				0.0,
				Vector3(0.0, 0.0, -5.2),
				-1.0,
				48.0
			)
			_preserve_midground_materials(anchor)
			_apply_dome_hearth_textures(anchor)
			if not _hearth_model_looks_untextured(anchor):
				_apply_finish_outpost_visible_model(anchor)
				spawned = anchor
			else:
				anchor.queue_free()
	if spawned == null:
		spawned = _make_procedural_habitat_dome()
		spawned.position = Vector3(0.0, 0.0, -5.2)
		spawned.scale = Vector3(1.72, 1.72, 1.72)
		_finish_portal_root.add_child(spawned)
	if _finish_silhouette_billboard != null:
		_finish_silhouette_billboard.visible = true
		if spawned != null:
			spawned.position.z = minf(float(spawned.position.z), -6.5)
	return spawned != null


func _apply_finish_outpost_visible_model(root: Node3D) -> void:
	# 保留 GLB 原色与贴图，只做轻量远景可读性增强（避免洗成白块）
	_preserve_midground_materials(root)
	_finish_outpost_model_mats.clear()
	for gi_node in root.find_children("*", "MeshInstance3D", true, false):
		var gi := gi_node as MeshInstance3D
		gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gi.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		if gi.mesh:
			for surface_idx in gi.mesh.get_surface_count():
				_tint_finish_outpost_surface(gi, surface_idx)
		elif gi.material_override is StandardMaterial3D:
			var mat := _duplicate_finish_outpost_visible_mat(gi.material_override as StandardMaterial3D)
			gi.material_override = mat
			_finish_outpost_model_mats.append(mat)


func _tint_finish_outpost_surface(gi: GeometryInstance3D, surface_idx: int) -> void:
	var src: Material = gi.get_surface_override_material(surface_idx)
	if src == null and gi.mesh:
		src = gi.mesh.surface_get_material(surface_idx)
	if src == null or not src is StandardMaterial3D:
		return
	var mat := _duplicate_finish_outpost_visible_mat(src as StandardMaterial3D)
	gi.set_surface_override_material(surface_idx, mat)
	_finish_outpost_model_mats.append(mat)


func _duplicate_finish_outpost_visible_mat(base: StandardMaterial3D) -> StandardMaterial3D:
	var mat := base.duplicate() as StandardMaterial3D
	mat.disable_fog = true
	if base.albedo_texture != null:
		mat.emission_enabled = true
		mat.emission = Color(0.22, 0.42, 0.58)
		mat.emission_energy_multiplier = 0.32
		mat.metallic = clampf(base.metallic, 0.0, 0.55)
		mat.roughness = clampf(base.roughness, 0.18, 0.72)
		return mat
	var albedo := base.albedo_color
	mat.albedo_color = Color(
		minf(albedo.r * 1.12 + 0.04, 1.0),
		minf(albedo.g * 1.12 + 0.04, 1.0),
		minf(albedo.b * 1.14 + 0.06, 1.0),
		1.0
	)
	mat.emission_enabled = true
	mat.emission = albedo.lerp(Color(0.55, 0.72, 0.95), 0.35)
	mat.emission_energy_multiplier = 0.95
	mat.metallic = minf(base.metallic, 0.38)
	mat.roughness = clampf(base.roughness * 0.88, 0.32, 0.9)
	return mat


func _finish_outpost_silhouette_path() -> String:
	if LevelConfig != null and LevelConfig.has_method("get_location_finish_silhouette"):
		return String(LevelConfig.get_location_finish_silhouette(Global.runner_location_id)).strip_edges()
	return ""


func _finish_outpost_silhouette_fallbacks() -> Array[String]:
	var loc := String(Global.runner_location_id)
	match loc:
		"dome":
			return [
				"res://assets/maps/route_levels/runner_60s/settlement/habitat_dome_silhouette.jpg",
				"res://assets/maps/route_levels/runner_60s/settlement/habitat_dome_silhouette.png",
			]
		"reservoir":
			return [
				"res://assets/maps/route_levels/runner_60s/settlement/water_station_silhouette.png",
			]
		"medbay", "medical":
			return [String(FINISH_OUTPOST_SILHOUETTE.get("medical", ""))]
		"relay":
			return [String(FINISH_OUTPOST_SILHOUETTE.get("relay", ""))]
		"outpost", "gate":
			return [
				"res://assets/maps/route_levels/runner_60s/settlement/defense_settlement_silhouette.png",
				"res://assets/maps/route_levels/runner_60s/settlement/defense_outpost_front_cutout.png",
				String(FINISH_OUTPOST_SILHOUETTE.get("gate", "")),
			]
		_:
			return []


func _try_load_finish_texture(path: String) -> Texture2D:
	if path == "":
		return null
	var abs_path := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path) or FileAccess.file_exists(abs_path):
		var img := Image.load_from_file(abs_path)
		if img != null and not img.is_empty():
			return ImageTexture.create_from_image(img)
	if ResourceLoader.exists(path):
		var res := load(path)
		if res is Texture2D:
			return res
	return null


func _load_finish_silhouette_texture() -> Dictionary:
	var candidates: Array[String] = []
	var primary := _finish_outpost_silhouette_path()
	if primary != "":
		candidates.append(primary)
	for path in _finish_outpost_silhouette_fallbacks():
		if path != "" and not candidates.has(path):
			candidates.append(path)
	for path in candidates:
		var tex := _try_load_finish_texture(path)
		if tex != null:
			return {"texture": tex, "path": path}
	return {}


func _prepare_finish_silhouette_texture(source: Texture2D, path: String, location_id: String = "") -> Texture2D:
	if source == null:
		return _make_procedural_finish_silhouette_texture(location_id)
	var lowered := path.to_lower()
	# 彩色抠图：做成与水源/穹顶同级的软剪影，避免灰金属色和环境打架
	if "cutout" in lowered:
		return _soft_bake_finish_silhouette_texture(source)
	if lowered.contains("silhouette") or lowered.contains("water_station") or lowered.contains("habitat_dome"):
		return _strip_finish_silhouette_background(source)
	return _bake_finish_silhouette_texture(source)


func _soft_bake_finish_silhouette_texture(source: Texture2D) -> Texture2D:
	if source == null:
		return null
	var img := source.get_image()
	if img == null or img.is_empty():
		return source
	img = img.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	var ink := FINISH_SILHOUETTE_INK
	var rim := FINISH_SILHOUETTE_LINE
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.04:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			var luma := c.r * 0.3 + c.g * 0.59 + c.b * 0.11
			var cyan := clampf((c.b - c.r) * 1.6, 0.0, 1.0)
			var lift := clampf((luma - 0.18) / 0.55, 0.0, 1.0)
			var mix := clampf(lift * 0.32 + cyan * 0.28, 0.0, 0.55)
			var tone := ink.lerp(rim, mix)
			img.set_pixel(x, y, Color(tone.r, tone.g, tone.b, maxf(c.a, 0.92)))
	return ImageTexture.create_from_image(img)


func _color_saturation(c: Color) -> float:
	var mx := maxf(c.r, maxf(c.g, c.b))
	var mn := minf(c.r, minf(c.g, c.b))
	if mx <= 0.001:
		return 0.0
	return (mx - mn) / mx


func _strip_finish_silhouette_background(source: Texture2D) -> Texture2D:
	var img := source.get_image()
	if img == null or img.is_empty():
		return source
	img = img.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	# 已有透明通道的预烘焙剪影：只清掉近零 alpha，勿把深蓝建筑当黑底洪水冲掉
	var has_transparent := false
	var has_opaque := false
	for y in mini(h, 64):
		for x in mini(w, 64):
			var a0 := img.get_pixel(x, y).a
			if a0 < 0.2:
				has_transparent = true
			if a0 > 0.6:
				has_opaque = true
			if has_transparent and has_opaque:
				break
		if has_transparent and has_opaque:
			break
	if has_transparent and has_opaque:
		for y in h:
			for x in w:
				if img.get_pixel(x, y).a < 0.04:
					img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
		return ImageTexture.create_from_image(img)
	# 去掉白底/灰棋盘，以及剪影图常见的实心黑底（从边缘洪水填充）
	var is_bg: PackedByteArray = PackedByteArray()
	is_bg.resize(w * h)
	var queue: Array[Vector2i] = []
	for x in w:
		for y in [0, h - 1]:
			var c0 := img.get_pixel(x, y)
			if _finish_pixel_is_backdrop(c0):
				is_bg[y * w + x] = 1
				queue.append(Vector2i(x, y))
	for y in h:
		for x in [0, w - 1]:
			var c1 := img.get_pixel(x, y)
			if _finish_pixel_is_backdrop(c1) and is_bg[y * w + x] == 0:
				is_bg[y * w + x] = 1
				queue.append(Vector2i(x, y))
	var dirs: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	]
	while not queue.is_empty():
		var p: Vector2i = queue.pop_back()
		for d: Vector2i in dirs:
			var n: Vector2i = p + d
			if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h:
				continue
			var idx := n.y * w + n.x
			if is_bg[idx] != 0:
				continue
			if _finish_pixel_is_backdrop(img.get_pixel(n.x, n.y)):
				is_bg[idx] = 1
				queue.append(n)
	for y in h:
		for x in w:
			var idx2 := y * w + x
			var c := img.get_pixel(x, y)
			if is_bg[idx2] != 0 or c.a < 0.04:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	return ImageTexture.create_from_image(img)


func _finish_pixel_is_backdrop(c: Color) -> bool:
	if c.a < 0.04:
		return true
	var luma := c.r * 0.3 + c.g * 0.59 + c.b * 0.11
	var sat := _color_saturation(c)
	if luma > 0.72 and sat < 0.28:
		return true
	if luma > 0.58 and sat < 0.12:
		return true
	# 实心黑底（剪影导出常见）
	if luma < 0.045 and sat < 0.18:
		return true
	return false


func _bake_finish_silhouette_texture(source: Texture2D) -> Texture2D:
	if source == null:
		return null
	var img := source.get_image()
	if img == null or img.is_empty():
		return source
	img = img.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.04:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue
			var luma := c.r * 0.3 + c.g * 0.59 + c.b * 0.11
			# 去掉天空/底色，只保留建筑主体（避免整图变实心黑块）
			if luma > 0.58:
				img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
			elif luma > 0.08:
				var alpha := clampf((0.58 - luma) / 0.42, 0.35, 1.0) * c.a
				img.set_pixel(x, y, Color(
					FINISH_SILHOUETTE_INK.r,
					FINISH_SILHOUETTE_INK.g,
					FINISH_SILHOUETTE_INK.b,
					maxf(alpha, 0.88)
				))
			else:
				img.set_pixel(x, y, Color(
					FINISH_SILHOUETTE_INK.r,
					FINISH_SILHOUETTE_INK.g,
					FINISH_SILHOUETTE_INK.b,
					maxf(c.a, 0.96)
				))
	return ImageTexture.create_from_image(img)


func _make_procedural_finish_silhouette_texture(location_id: String = "") -> Texture2D:
	var loc := location_id if location_id != "" else String(Global.runner_location_id)
	if loc == "reservoir":
		return _make_procedural_water_station_silhouette_texture()
	return _make_procedural_habitat_dome_silhouette_texture()


func _make_procedural_habitat_dome_silhouette_texture() -> Texture2D:
	var w := 512
	var h := 256
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	var ink := FINISH_SILHOUETTE_INK
	var cx := w * 0.5
	# 平台
	for y in range(int(h * 0.72), int(h * 0.82)):
		for x in range(int(w * 0.18), int(w * 0.82)):
			img.set_pixel(x, y, Color(ink.r, ink.g, ink.b, 0.96))
	# 穹顶弧
	for y in range(int(h * 0.18), int(h * 0.74)):
		for x in range(int(w * 0.22), int(w * 0.78)):
			var nx := (float(x) - cx) / (w * 0.28)
			var ny := (float(y) - h * 0.72) / (h * 0.54)
			if nx * nx + ny * ny <= 1.0:
				img.set_pixel(x, y, Color(ink.r, ink.g, ink.b, 0.98))
	# 尖塔
	for y in range(int(h * 0.06), int(h * 0.22)):
		var half := int(lerpf(4.0, 16.0, float(y) / float(h * 0.22)))
		for x in range(int(cx) - half, int(cx) + half):
			if x >= 0 and x < w:
				img.set_pixel(x, y, Color(ink.r, ink.g, ink.b, 0.98))
	return ImageTexture.create_from_image(img)


func _make_procedural_water_station_silhouette_texture() -> Texture2D:
	var w := 512
	var h := 256
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	var ink := FINISH_SILHOUETTE_INK
	var cx := w * 0.5
	for y in range(int(h * 0.70), int(h * 0.82)):
		for x in range(int(w * 0.20), int(w * 0.80)):
			img.set_pixel(x, y, Color(ink.r, ink.g, ink.b, 0.96))
	for y in range(int(h * 0.28), int(h * 0.72)):
		var half := int(lerpf(w * 0.10, w * 0.22, float(y - h * 0.28) / (h * 0.44)))
		for x in range(int(cx) - half, int(cx) + half):
			if x >= 0 and x < w:
				img.set_pixel(x, y, Color(ink.r, ink.g, ink.b, 0.98))
	for y in range(int(h * 0.12), int(h * 0.30)):
		var half := int(lerpf(10.0, 22.0, float(y - h * 0.12) / (h * 0.18)))
		for x in range(int(cx) - half, int(cx) + half):
			if x >= 0 and x < w:
				img.set_pixel(x, y, Color(ink.r, ink.g, ink.b, 0.98))
	return ImageTexture.create_from_image(img)


func _make_finish_silhouette_billboard() -> Node3D:
	var location_id := String(Global.runner_location_id)
	var loaded := _load_finish_silhouette_texture()
	var source: Texture2D = loaded.get("texture")
	var path := String(loaded.get("path", ""))
	var tex := _prepare_finish_silhouette_texture(source, path, location_id)
	if tex == null:
		tex = _make_procedural_finish_silhouette_texture(location_id)
	if tex == null:
		return _make_finish_horizon_rocks()

	var tex_w := maxi(tex.get_width(), 1)
	var tex_h := maxi(tex.get_height(), 1)
	var aspect := float(tex_w) / float(tex_h)
	# 与水源/穹顶同量级占屏；等距/正面据点按宽高比适配
	var height := 21.0
	var width := 62.0
	var y_frac := 0.48
	if location_id in ["gate", "outpost"]:
		# 正面贴地 2D：底边对齐地面，略放大占屏
		height = 26.0
		width = height * aspect
		if width > 70.0:
			width = 70.0
			height = width / maxf(aspect, 0.2)
		elif width < 46.0:
			width = 46.0
			height = width / maxf(aspect, 0.2)
		y_frac = 0.48
	elif location_id in ["medical", "medbay", "relay"]:
		height = 28.0
		width = height * aspect
		if width > 68.0:
			width = 68.0
			height = width / maxf(aspect, 0.2)
		elif width < 44.0:
			width = 44.0
			height = width / maxf(aspect, 0.2)
		y_frac = 0.30
	_finish_outpost_height = height

	var board := MeshInstance3D.new()
	board.name = "FinishOutpostSilhouette"
	var quad := QuadMesh.new()
	quad.size = Vector2(width, height)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	mat.albedo_texture = tex
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_fog = true
	mat.no_depth_test = false
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	mat.emission_enabled = false
	quad.material = mat
	board.mesh = quad
	board.position = Vector3(0.0, height * y_frac, -5.6)
	board.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_finish_silhouette_billboard_mat = mat
	_finish_silhouette_rim_mat = null
	_finish_title_z = -5.2
	return board


func _add_finish_outpost_set_dressing(parent: Node3D) -> void:
	if parent == null:
		return
	var dome := _make_finish_energy_dome()
	parent.add_child(dome)
	var crystals := _make_finish_flank_crystals()
	parent.add_child(crystals)


func _make_finish_energy_dome() -> Node3D:
	var root := Node3D.new()
	root.name = "FinishEnergyDome"
	root.position = Vector3(0.0, 1.25, -2.15)
	var shell := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 17.0
	mesh.height = 10.0
	mesh.radial_segments = 36
	mesh.rings = 18
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.62, 0.28, 0.92, 0.16)
	mat.emission_enabled = true
	mat.emission = Color(0.78, 0.42, 1.0)
	mat.emission_energy_multiplier = 1.05
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_fog = true
	shell.mesh = mesh
	shell.material_override = mat
	shell.scale = Vector3(1.0, 0.52, 1.0)
	shell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(shell)
	var base_ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 15.5
	torus.outer_radius = 16.2
	torus.ring_segments = 48
	torus.rings = 8
	var ring_mat := StandardMaterial3D.new()
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	ring_mat.albedo_color = Color(0.82, 0.45, 1.0, 0.38)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.92, 0.55, 1.0)
	ring_mat.emission_energy_multiplier = 1.35
	ring_mat.disable_fog = true
	torus.material = ring_mat
	base_ring.mesh = torus
	base_ring.rotation.x = PI * 0.5
	base_ring.position = Vector3(0.0, 0.08, 0.0)
	base_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(base_ring)
	return root


func _make_finish_flank_crystals() -> Node3D:
	var root := Node3D.new()
	root.name = "FinishFlankCrystals"
	var specs := [
		{"side": -1, "x": 24.0, "h": 11.5, "w": 2.4, "d": 1.8, "ry": -18.0, "rz": 8.0},
		{"side": -1, "x": 31.0, "h": 8.2, "w": 1.8, "d": 1.4, "ry": -28.0, "rz": -12.0},
		{"side": 1, "x": 26.0, "h": 10.8, "w": 2.2, "d": 1.6, "ry": 22.0, "rz": -6.0},
		{"side": 1, "x": 33.0, "h": 7.6, "w": 1.6, "d": 1.2, "ry": 32.0, "rz": 14.0},
	]
	for i in specs.size():
		var spec: Dictionary = specs[i]
		var crystal := MeshInstance3D.new()
		crystal.name = "FlankCrystal_%d" % i
		var box := BoxMesh.new()
		box.size = Vector3(float(spec["w"]), float(spec["h"]), float(spec["d"]))
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.10, 0.08, 0.14, 0.92)
		mat.emission_enabled = true
		mat.emission = Color(0.62, 0.38, 0.98)
		mat.emission_energy_multiplier = 1.28
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.disable_fog = true
		box.material = mat
		crystal.mesh = box
		crystal.position = Vector3(float(spec["x"]), box.size.y * 0.46, -2.8)
		crystal.rotation_degrees = Vector3(0.0, float(spec["ry"]), float(spec["rz"]))
		crystal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(crystal)
	return root


func _make_finish_horizon_rocks() -> MeshInstance3D:
	var root := MeshInstance3D.new()
	root.name = "FinishHorizonRocks"
	var mat := _make_material(Color(0.05, 0.06, 0.08), Color(0.12, 0.16, 0.22), 0.08)
	for i in 7:
		var rock := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(randf_range(1.6, 3.4), randf_range(3.5, 8.5), randf_range(1.2, 2.2))
		mesh.material = mat
		rock.mesh = mesh
		rock.position = Vector3(-12.0 + float(i) * 4.0, mesh.size.y * 0.42, -6.0)
		rock.rotation_degrees.y = randf_range(-18.0, 18.0)
		rock.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		root.add_child(rock)
	return root


func _apply_finish_outpost_silhouette(root: Node3D) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		var mat := ShaderMaterial.new()
		mat.shader = FINISH_OUTPOST_SILHOUETTE_SHADER
		mat.set_shader_parameter("body_color", Color(0.04, 0.05, 0.09, 1.0))
		mat.set_shader_parameter("rim_color", Color(0.32, 0.52, 0.72, 1.0))
		mat.set_shader_parameter("window_glow", Color(0.10, 0.20, 0.36, 1.0))
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.material_override = mat
		_finish_silhouette_mats.append(mat)


func _update_finish_outpost_approach(_delta: float) -> void:
	if _finish_portal_root == null or not is_instance_valid(_finish_portal_root):
		return
	var finish_d := _finish_line_distance if _finish_line_distance > 0.0 else maxf(_track_length - FINISH_GATE_BEFORE_END, 80.0)
	var remain := finish_d - track_distance
	if remain > 320.0 and _finish_sprint_timer <= 0.0:
		return
	var boost := clampf(1.0 - remain / 280.0, 0.0, 1.0)
	if _finish_sprint_timer > 0.0:
		boost = maxf(boost, 0.82)
	var boost_changed := absf(boost - _finish_approach_boost_cached) >= 0.025
	if boost_changed:
		_finish_approach_boost_cached = boost
		if _finish_silhouette_billboard_mat != null:
			var base := _finish_silhouette_billboard_mat.albedo_color
			if base.r > 0.5:
				var lift := lerpf(0.94, 1.06, boost)
				_finish_silhouette_billboard_mat.albedo_color = Color(lift, lift, lift, 1.0)
			else:
				var lift := lerpf(0.94, 1.06, boost)
				_finish_silhouette_billboard_mat.albedo_color = Color(0.04 * lift, 0.05 * lift, 0.08 * lift, 1.0)
	if _finish_outpost_title_rig != null and is_instance_valid(_finish_outpost_title_rig):
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.0018)
		var fill := Color(1.0, 0.94, 1.0, 1.0).lerp(Color(0.92, 0.72, 1.0, 1.0), pulse)
		var outline := Color(1.0, 0.62, 0.88, 0.95).lerp(Color(0.72, 0.38, 1.0, 0.92), 1.0 - pulse)
		var title_scale := FINISH_TITLE_BASE_SCALE * lerpf(1.0, 1.08, boost)
		if absf(title_scale - _finish_title_scale_cached) >= 0.012:
			_finish_title_scale_cached = title_scale
			var s := Vector3.ONE * title_scale
			_finish_outpost_title_rig.scale = s
			if _finish_outpost_title_glow != null and is_instance_valid(_finish_outpost_title_glow):
				_finish_outpost_title_glow.scale = s * 1.04
			if _finish_outpost_title_bloom != null and is_instance_valid(_finish_outpost_title_bloom):
				_finish_outpost_title_bloom.scale = s * 1.12
		_finish_outpost_title_rig.position.y = _finish_title_base_y
		_finish_outpost_title_rig.position.z = _finish_title_z
		_finish_outpost_title_rig.modulate = fill
		_finish_outpost_title_rig.outline_modulate = outline
		if _finish_outpost_title_glow != null and is_instance_valid(_finish_outpost_title_glow):
			_finish_outpost_title_glow.position = Vector3(0.0, _finish_title_base_y, _finish_title_z - 0.02)
			_finish_outpost_title_glow.modulate = Color(0.95, 0.72, 1.0, 0.42 + pulse * 0.22)
		if _finish_outpost_title_bloom != null and is_instance_valid(_finish_outpost_title_bloom):
			_finish_outpost_title_bloom.position = Vector3(0.0, _finish_title_base_y, _finish_title_z - 0.08)
			_finish_outpost_title_bloom.modulate = Color(1.0, 0.58, 0.92, 0.18 + pulse * 0.16)

func _build_starfield() -> void:
	var material := _make_material(Color(1.0, 0.82, 0.55), Color(1.0, 0.65, 0.25), 0.8)
	for i in 80:
		var star := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = randf_range(0.018, 0.055)
		mesh.height = mesh.radius * 2.0
		mesh.radial_segments = 8
		mesh.rings = 4
		mesh.material = material
		star.mesh = mesh
		star.position = Vector3(randf_range(-60.0, 60.0), randf_range(7.0, 26.0), randf_range(-_track_length, 20.0))
		add_child(star)

func _add_obstacle_post(obstacle: Node3D, x: float, y: float, glow_color: Color) -> void:
	var post := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.08
	mesh.bottom_radius = 0.08
	mesh.height = 1.8
	mesh.radial_segments = 12
	mesh.material = _make_material(Color(0.06, 0.08, 0.09), glow_color, 1.2)
	post.mesh = mesh
	post.position = Vector3(x, y, 0)
	obstacle.add_child(post)

func _make_material(color: Color, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.15
	material.roughness = 0.65
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
