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
const LOW_SLIDE_BEAM_TOP := 1.64
const LOW_SLIDE_OPEN_BOTTOM := 0.80
const COIN_AIR_PICKUP_MARGIN := 0.35
const COIN_AIR_MIN_JUMP_Y := 0.72
const BUFF_AIR_Y_OFFSET := 1.38
const BUFF_GROUND_Y_OFFSET := 0.72
const SPEED_BOOST_DURATION := 5.0
const SPEED_BOOST_MULT := 1.42
const SPEED_BOOST_SKILL_THRESHOLD := 5
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
# 普通撞障（非撞碎关）：顿帧 + 弹回
const HIT_STUN_TIME := 0.34
const HIT_STOP_TIME := 0.085
const HIT_BOUNCE_GAP := 0.55
const HIT_STUN_SPEED_MULT := 0.06
const AIR_LANE_CHANGE_MULT := 0.16
const AIR_LANE_CHANGE_RUSH_MULT := 0.08
const OVERWEIGHT_JUMP_SHORT_MULT := 0.42
const JUMP_DOUBLE_TAP_WINDOW := 0.62
const JUMP_DOUBLE_TAP_WINDOW_MOBILE := 0.85
# 全关卡默认：装备硬冲碎障
const SMASH_RUNNER_HP_DAMAGE := 0.45
const SMASH_LAYOUT_IDS := [
	"mission_reservoir_base",
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
const SLIDE_TIME := 0.85
const MAGNET_RADIUS := 3.0
const MAGNET_SPEED := 14.0
const MAGNET_LANE_ONLY := true

# 追逐者：零潮追猎
const CHASER_START_DISTANCE := 28.0
const CHASER_INTRO_START := 42.0
const CHASER_MAX_DISTANCE := 35.0
const CHASER_BASE_CREEP := 0.42
const CHASER_HIT_PENALTY := 7.0
const CHASER_RECOVERY_RATE := 1.8
const CHASER_CATCH_DISTANCE := 0.5
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
	"train": 1.05,
	"train_moving": 1.05,
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
	"block_left": 0.85,
	"block_right": 0.85,
	"main_block": 1.05,
	"train": 1.0,
	"train_moving": 1.15,
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
	"meteorite": 1.32,
	"block_left": 1.22,
	"block_right": 1.22,
	"train": 1.26,
	"train_moving": 1.42,
}
const ENV_POISON_DPS_MULT := 1.38
const HEAT_HAZARD_DPS := 7.0
const HEAT_HAZARD_HALF_LEN := 7.0
const HEAT_HAZARD_TICK := 0.45
const SANDSTORM_TICK := 0.4
const SANDSTORM_DEFAULT_DPS := 9.0
const SKY_PROGRESS_SCROLL := 0.52
const SHIELD_MAX_ENERGY := 100.0
const SHIELD_START_ENERGY := 0.0
const SHIELD_MIN_ACTIVATE := 15.0
const SHIELD_CRYSTAL_RESTORE := 28.0
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
const SKY_CHEER_MIN_COUNT := 5
const SKY_CHEER_MAX_COUNT := 7
const INTRO_DURATION := 3.0
const PRE_RUN_LOADING_TIME := 0.45
const PRE_RUN_COUNTDOWN_STEP := 1.0
# 追击默认关闭；Ignition Run 等任务类型会在开局打开 _chaser_enabled
const CHASER_ENABLED_DEFAULT := false
const GROUND_Y := 0.85
const CAMERA_BEHIND := 6.5
const CAMERA_HEIGHT := 2.2
const CAMERA_LOOK_AHEAD := 18.0
const CAMERA_FOV := 64.0
const DISTANT_SCALE_CAP := 80.0
const DISTANT_VISIBLE_AHEAD := 560.0
const DISTANT_VISIBLE_BEHIND := -90.0
const DISTANT_RUNWAY_CLEARANCE := 24.0
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
const MIDGROUND_MIN_VISIBLE_HEIGHT := 2.2
const MIDGROUND_PROP_DEFAULTS: Array[String] = [
	"res://assets/maps/route_levels/runner_60s/midground_props/amber_crystal_coral.glb",
	"res://assets/maps/route_levels/runner_60s/midground_props/glowing_energy_meteorite.glb",
	"res://assets/maps/route_levels/runner_60s/midground_props/cracked_sphere_robot.glb",
]
const RUNWAY_EDGE_FILLER_PATHS: Array[String] = [
	"res://assets/maps/route_levels/runner_60s/midground_props/amber_crystal_coral.glb",
	"res://assets/maps/route_levels/runner_60s/midground_props/glowing_energy_meteorite.glb",
]
const FORK_GAP_DECOR_PATHS: Array[String] = [
	"res://assets/maps/route_levels/runner_60s/midground_props/cracked_sphere_robot.glb",
	"res://assets/maps/route_levels/runner_60s/midground_props/neon_sign_prop.glb",
	"res://mvp素材第二批/障碍物/0803/废旧广告牌（滑铲）.glb",
]
const SKY_PANORAMA_BILLBOARD_RECTS := [
	Vector4(0.06, 0.10, 0.20, 0.42),
	Vector4(0.38, 0.06, 0.24, 0.46),
	Vector4(0.68, 0.12, 0.20, 0.40),
	Vector4(0.22, 0.02, 0.26, 0.34),
	Vector4(0.56, 0.03, 0.24, 0.32),
]
const MIDGROUND_METEORITE_PALETTES := [
	{
		"label": "amber",
		"albedo": Color(1.06, 0.9, 0.68),
		"emission": Color(0.95, 0.45, 0.1),
		"emission_energy": 0.78,
	},
	{
		"label": "cyan",
		"albedo": Color(0.78, 0.94, 1.08),
		"emission": Color(0.18, 0.68, 1.0),
		"emission_energy": 1.05,
	},
	{
		"label": "violet",
		"albedo": Color(0.92, 0.82, 1.05),
		"emission": Color(0.52, 0.22, 0.92),
		"emission_energy": 0.92,
	},
	{
		"label": "rust",
		"albedo": Color(1.05, 0.72, 0.58),
		"emission": Color(0.88, 0.28, 0.08),
		"emission_energy": 0.72,
	},
	{
		"label": "jade",
		"albedo": Color(0.72, 0.98, 0.82),
		"emission": Color(0.15, 0.82, 0.48),
		"emission_energy": 0.88,
	},
]
const START_PAD_LENGTH := 72.0
const TOUCH_SWIPE_MIN_DISTANCE := 72.0
const TOUCH_TAP_MAX_DISTANCE := 26.0
const MOBILE_VIEWPORT_SIZE := Vector2(1080, 1920)
const ANIMATED_PLAYER_SCENE_PATH := "res://elsa动作/Running.fbx"
const ANIMATED_PLAYER_IDLE_ANIM := "NlaTrack.002"
const ANIMATED_PLAYER_RUN_ANIM := "mixamo_com"
const ANIMATED_PLAYER_CELEBRATE_ANIM := "NlaTrack.001"
const PLAYER_MODEL_SCENE_PATH := "res://elsa动作/elsa正面.glb"
const PLAYER_RUN_LEFT_SCENE_PATH := "res://elsa动作/elsa奔跑左腿前.glb"
const PLAYER_RUN_RIGHT_SCENE_PATH := "res://elsa动作/elsa奔跑右腿前.glb"
const PLAYER_JUMP_START_SCENE_PATH := "res://elsa动作/elsa起跳.glb"
const PLAYER_JUMP_PEAK_SCENE_PATH := "res://elsa动作/elsa跳跃高点.glb"
const PLAYER_LANDING_SCENE_PATH := "res://elsa动作/跳跃落地.glb"
const PLAYER_SLIDE_SCENE_PATH := "res://elsa动作/滑铲.glb"
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
	"res://3d素材/障碍物-需跳跃.glb": "res://.godot/imported/障碍物-需跳跃.glb-46f57db02e27254a677214f954ab0d83.scn",
	"res://3d素材/障碍物-需跳跃2.glb": "res://.godot/imported/障碍物-需跳跃2.glb-c8c9938e154747024ae7ac221ab7db3a.scn",
	"res://3d素材/居民穹顶据点 3d model.glb": "res://.godot/imported/居民穹顶据点 3d model.glb-f6066a8ae2d51e15aff61146c4296099.scn",
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
var _slide_obstacle_scene: PackedScene
var _hearth_scene_path := ""
var _player_scene_paths: Dictionary = {}
var _scene_cache: Dictionary = {}
var _world_ready := false
var _side_dressing_root: Node3D
var _distant_background_root: Node3D
var _sky_accents_root: Node3D
var _road_root: Node3D
var _world_environment: WorldEnvironment
var _road_mesh: RoadMeshBuilder = RoadMeshBuilder.new()
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
var elapsed := 0.0
var current_speed := RUN_SPEED
var body_tilt := 0.0
var body_squash_timer := 0.0
var player_pose_name := ""
var _player_pose_base_scale := Vector3.ONE
var _player_pose_base_yaw := 0.0
var _player_slide_base_y := 0.0
var _run_anim_speed_smooth := 1.0
var camera_shake := 0.0
var was_on_ground := true
var _air_pose_grace := 0.0
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
var _finish_silhouette_mats: Array[ShaderMaterial] = []
var _finish_portal_mats: Array[ShaderMaterial] = []
var _finish_title_mat: ShaderMaterial
var _finish_sky_mat: ShaderMaterial
var _finish_silhouette_billboard: MeshInstance3D
var _sandstorm_grit_particles: GPUParticles3D
var _overweight_intro_pending := false
var _overweight_run_tip_shown := false
var _overweight_jump_armed := false
var _overweight_short_jump_timer := 0.0
var _chaser_enabled := CHASER_ENABLED_DEFAULT
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
var chaser_eye_left: MeshInstance3D
var chaser_eye_right: MeshInstance3D
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
var _sandstorm_tick_accum := 0.0
var _sandstorm_active := false
var _sandstorm_warned_keys: Array = []
var _sandstorm_particles: GPUParticles3D
var _base_fog_density := 0.0022
var _base_fog_light_color := Color(0.36, 0.30, 0.38)
var _base_ambient_light_color := Color(0.48, 0.44, 0.56)
var _base_sky_yaw := 0.0
var _base_sun_rot := Vector3(-52, 35, 0)
var _base_sun_energy := 1.75
var _base_sun_color := Color(0.94, 0.78, 0.58)
var _base_panorama_energy := 1.65
var _wall_mount_armed := false
var _wall_mount_armed_until_d := -1.0
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
	shield_energy = SHIELD_START_ENERGY
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
	chaser_distance = CHASER_INTRO_START
	current_lateral = 0.0
	target_lane_x = 0.0
	_sync_player_position()
	_sync_chaser_from_track()
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
	elif event.is_action_pressed("move_backward") and _is_on_ground():
		_try_slide()
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
	if _is_sliding():
		return
	if not _tutorial_allows_action("jump"):
		_show_gate_toast("请按教学提示操作")
		return
	if _is_wall_running():
		vertical_velocity = JUMP_SPEED * 0.95
		_end_slide()
		# 墙上跳：优先抬到高列，动作更明显
		if lane_index < 2:
			_set_lane(mini(lane_index + 1, 2))
		else:
			body_squash_timer = 0.14
			_jump_fx_timer = 0.4
			camera_shake = maxf(camera_shake, 0.16)
			_emit_jump_takeoff_fx()
			_show_gate_toast("侧墙高跳")
			strike_toast_label.modulate = Color(0.75, 0.92, 1.0, 1.0)
			strike_toast_timer = 0.85
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
	if not _tutorial_allows_action("slide"):
		_show_gate_toast("请按教学提示操作")
		return
	if _is_wall_running():
		# 侧墙上滑铲 = 切到最低列，带明显俯冲
		var was_low := lane_index == 0
		_set_lane(0)
		body_squash_timer = maxf(body_squash_timer, 0.2)
		if player_body:
			player_body.scale = Vector3(1.14, 0.82, 1.1)
		_emit_landing_particles()
		camera_shake = maxf(camera_shake, 0.18)
		_notify_coach_action("slide")
		if was_low:
			_show_gate_toast("侧墙滑铲 · 低列")
			strike_toast_label.modulate = Color(0.7, 0.9, 1.0, 1.0)
			strike_toast_timer = 0.85
		return
	if not _is_on_ground():
		return
	_start_slide()
	_notify_coach_action("slide")

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

	if is_finished or is_failed:
		return

	if is_intro:
		_update_pre_run(delta)
		_sync_player_position()
		_sync_chaser_from_track()
		_update_runner_feedback(delta)
		_update_chaser_visuals(delta)
		_update_distant_depth_cues()
		_update_midground_visibility()
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
	if slide_timer > 0.0:
		slide_timer = maxf(slide_timer - delta, 0.0)
		if slide_timer == 0.0:
			_end_slide()
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
		var ground_y := _layer_height(0)
		var next_y := player.position.y + vertical_velocity * delta
		var over_pit := _is_over_open_pit()
		if over_pit:
			# 坑上无隐形地面：真正往下坠
			if next_y <= ground_y and vertical_velocity >= -0.5:
				# 刚踩到坑口：给一个下坠初速，避免卡在地面高度像「跳起来」
				vertical_velocity = minf(vertical_velocity, -6.5)
				next_y = ground_y - 0.02
			player.position.y = next_y
			if player.position.y < ground_y - 0.55:
				_fail_into_pit()
		elif next_y <= ground_y and vertical_velocity <= 0.0:
			next_y = ground_y
			vertical_velocity = 0.0
			player.position.y = next_y
		else:
			player.position.y = next_y
		if _is_sliding() and not over_pit:
			player.position.y = ground_y
			vertical_velocity = 0.0

	_sync_player_position()
	_sync_chaser_from_track()
	_update_moving_obstacles(delta)
	_update_float_orbs(delta)
	_update_meteor_fall_roll(delta)
	_update_train_blade_gates()
	_sync_fork_branch_obstacle_visibility()
	_check_ramps()
	_maybe_auto_arm_wall_mount()
	_try_side_runway_entry()
	_enforce_track_layer()
	_update_side_runway_ground_penalty(delta)
	_update_wall_jump_center_hint(delta)
	_update_wall_run_tutorial(delta)
	_update_runner_coach_tips(delta)
	_update_sandstorm_hazard(delta)
	_update_shield_energy_drain(delta)
	_update_shield_visual(delta)

	var grounded := _is_on_ground()
	if grounded and not was_on_ground:
		body_squash_timer = 0.12
		camera_shake = 0.16
		_emit_landing_particles()
		_overweight_jump_armed = false
		_overweight_short_jump_timer = 0.0
	was_on_ground = grounded

	_update_runner_feedback(delta)
	_update_chaser_visuals(delta)
	_update_collectible_magnet(delta)
	_update_coin_collectible_visuals(delta)
	_check_collectibles()
	_update_sky_cheer_spawns()
	_update_sky_cheer_visuals(delta)
	_check_finish_sprint_pads()
	_check_obstacles(dist_from, track_distance)
	_update_env_hazards(delta)
	_check_chaser_caught()

	if track_distance >= _track_length:
		_finish_run()
	elif elapsed >= _run_time:
		if bool(_mission_profile.get("timed_fail", false)):
			_fail_run("限时到达失败")
		else:
			_finish_run()

	_update_distant_depth_cues()
	_update_finish_outpost_approach(delta)
	_update_runner_sky_presentation(delta)
	_update_camera()
	_update_hud()

func _process(delta: float) -> void:
	_coin_hud_flash_cd = maxf(_coin_hud_flash_cd - delta, 0.0)
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
	return 2 if _wall_zone_side(zone) > 0.0 else 0

func _try_arm_wall_mount(requested_lane: int) -> bool:
	var zone := _side_runway_entry_zone(track_distance)
	if zone.is_empty():
		_wall_mount_armed = false
		return false
	var wall_side := _wall_zone_side(zone)
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

func _is_wall_running() -> bool:
	return track_layer == WALL_RUN_LAYER

func _is_on_ground() -> bool:
	if _is_wall_running():
		return absf(player.position.y - current_wall_y) <= 0.08 and vertical_velocity <= 0.01
	return player.position.y <= _layer_height(0) + 0.02 and vertical_velocity <= 0.01

func _player_in_air_pose(delta: float) -> bool:
	# 防抖：避免主路微颠簸把骨骼跑切到静态跳跃姿势（角色会闪没）
	if _is_sliding() or _is_wall_running():
		_air_pose_grace = 0.0
		return false
	var airborne := (not _is_on_ground()) or vertical_velocity > 1.6
	if airborne:
		_air_pose_grace = 0.14
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

func _sample_path(distance: float) -> Dictionary:
	if _path_samples.is_empty():
		_bake_track_path()
	var d := clampf(distance, 0.0, maxf(_path_length, 0.0))
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
				_wall_zone_side(zone),
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
		return _pack_path_sample(only["pos"], float(only["yaw"]))
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
	return obstacle_type in ["slide", "high_bar", "jump", "low_barrier", "main_block", "ramp"]

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
				_wall_zone_side(zone),
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
		# 侧墙走廊内：保留主路封堵/坡道；侧墙层（layer=1）跳/铲障碍单独保留
		if _is_distance_in_side_wall_corridor(dist) and not keep_types.has(otype):
			if int(item.get("layer", 0)) == WALL_RUN_LAYER and otype in ["jump", "low_barrier", "slide", "high_bar"]:
				out.append(item)
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

func _wall_zone_side(zone: Dictionary) -> float:
	if zone.is_empty():
		return 1.0
	var raw: Variant = zone.get("side", 1)
	if typeof(raw) == TYPE_STRING and String(raw) == "outer":
		var mid := float(zone["start"]) + float(zone.get("length", 70.0)) * 0.5
		var curv := _path_curvature_sign(mid)
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
	var sample := _sample_path(distance)
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
				_wall_zone_side(zone),
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
		var zone := _side_runway_zone_at(track_distance)
		if zone.is_empty():
			zone = _side_runway_entry_zone(track_distance)
		if zone.is_empty() and _is_in_main_block_pit(track_distance):
			zone = _side_runway_hold_over_pit(track_distance)
		var side := _wall_zone_side(zone) if not zone.is_empty() else _last_wall_side
		if absf(side) < 0.01:
			side = 1.0 if _last_wall_side >= 0.0 else -1.0
		var offset := _effective_wall_lateral_offset(zone) if not zone.is_empty() else _effective_wall_lateral_offset()
		var keep_y := player.position.y
		var placed := _world_on_wall(track_distance, side, offset, keep_y)
		_path_yaw = float(placed["yaw"])
		# 根节点只跟路径偏航，相机才能稳定锁角色
		player.position = placed["pos"]
		player.rotation = Vector3(0.0, _path_yaw, 0.0)
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
		_show_gate_toast("前方 Y 分叉 · 左道走左岔 · 右道走右岔")

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

func _sandstorm_zone_at(distance: float) -> Dictionary:
	var player_lane := int(LANES[clampi(lane_index, 0, LANES.size() - 1)])
	for zone in _sandstorm_zones():
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		if distance < start or distance > start + length:
			continue
		if not _sandstorm_covers_lane(zone, player_lane):
			continue
		return zone
	return {}

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
	if is_finished or is_failed or not gameplay_active:
		_set_sandstorm_visual(false)
		return
	var zone := _sandstorm_zone_at(track_distance)
	var active := not zone.is_empty()
	if active and not _sandstorm_active:
		var key := int(float(zone.get("start", 0.0)))
		if not _sandstorm_warned_keys.has(key):
			_sandstorm_warned_keys.append(key)
			if _is_shield_protecting():
				_show_strike_warning("%s来袭 · 防护罩抵挡中" % String(zone.get("label", "沙尘暴")))
			else:
				_show_strike_warning("%s来袭 · 开启防护罩(F)或换道" % String(zone.get("label", "沙尘暴")))
	_sandstorm_active = active
	_set_sandstorm_visual(active)
	if not active:
		_sandstorm_tick_accum = 0.0
		return
	_sandstorm_tick_accum += delta
	_shield_drain_fx_cd = maxf(_shield_drain_fx_cd - delta, 0.0)
	if _sandstorm_tick_accum < SANDSTORM_TICK:
		return
	_sandstorm_tick_accum = 0.0
	var dps := float(zone.get("dps", SANDSTORM_DEFAULT_DPS))
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
		_shield_shader_mat.set_shader_parameter("core_tint", Color(1.0, 0.42, 0.58, 0.04))
		_shield_shader_mat.set_shader_parameter("rim_tint", Color(1.0, 0.58, 0.74, 0.34))
		_shield_shader_mat.set_shader_parameter("spark_tint", Color(1.0, 0.92, 0.96, 1.0))
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
		var ripple_mat := _make_material(Color(1.0, 0.55, 0.72, 0.10), Color(1.0, 0.62, 0.78), 0.85)
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
		_shield_waist_ring = _make_shield_orbit_ring(0.98, 1.02, Color(0.72, 0.98, 1.0, 0.22), 1.1)
		_shield_waist_ring.position = Vector3(0.0, 0.95, 0.0)
		_shield_waist_ring.rotation.x = PI * 0.5
		player.add_child(_shield_waist_ring)
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
		_shield_shader_mat.set_shader_parameter("rim_tint", Color(1.0, 0.62, 0.78, 0.38))
	else:
		_shield_shader_mat.set_shader_parameter("rim_tint", Color(1.0, 0.58, 0.74, 0.34))

func _set_sandstorm_visual(active: bool) -> void:
	if _sandstorm_particles:
		_sandstorm_particles.emitting = active
		if active and player != null:
			_sandstorm_particles.global_position = player.global_position + Vector3(0.0, 1.2, 0.0)
	if _sandstorm_grit_particles:
		_sandstorm_grit_particles.emitting = active
		if active and player != null:
			_sandstorm_grit_particles.global_position = player.global_position + Vector3(0.0, 0.85, 0.0)
	if danger_vignette:
		if active:
			danger_vignette.modulate.a = maxf(danger_vignette.modulate.a, 0.38)
	if _world_environment and _world_environment.environment:
		var env := _world_environment.environment
		var target_density := _base_fog_density * (2.35 if active else 1.0)
		env.fog_density = lerpf(env.fog_density, target_density, 0.18)
		var storm_tint := _base_fog_light_color.lerp(Color(0.82, 0.55, 0.32), 0.48)
		var target_color := storm_tint if active else _base_fog_light_color
		env.fog_light_color = env.fog_light_color.lerp(target_color, 0.16)

func _apply_gate_effect(effect: String) -> void:
	match effect:
		"repair", "safe":
			# 货物完整度会被障碍/环境扣掉；安全岔专门回补，并稳速免障
			cargo_integrity = minf(cargo_integrity + 10.0, 100.0)
			_fork_rush_timer = 0.0
			_fork_rush_elapsed = 0.0
			speed_penalty_mult = 1.0
			speed_penalty_timer = 0.0
			if player != null:
				_spawn_floating_pickup_label("+10", player.global_position, Color(0.55, 0.98, 0.72))
			_show_runway_combat_tip("完整度 +10", Color(0.45, 0.98, 0.72, 1.0))
		"fast":
			run_score += 160
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
	if _speed_boost_timer > 0.0:
		return SPEED_BOOST_MULT
	return 1.0

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
	var band := _sky_cheer_rng.randi_range(0, 3)
	match band:
		0:
			return layer_h * _sky_cheer_rng.randf_range(0.05, 0.13)
		1:
			return layer_h * _sky_cheer_rng.randf_range(0.14, 0.24)
		2:
			return layer_h * _sky_cheer_rng.randf_range(0.25, 0.34)
		_:
			return layer_h * _sky_cheer_rng.randf_range(0.35, 0.44)

func _spawn_sky_cheer_line(zh: String, en: String) -> void:
	if (zh == "" and en == "") or _sky_cheer_hud_layer == null:
		return
	var block := VBoxContainer.new()
	block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	block.add_theme_constant_override("separation", 2)
	if zh != "":
		var zh_lab := Label.new()
		zh_lab.text = zh
		zh_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		zh_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		zh_lab.add_theme_font_size_override("font_size", 62)
		zh_lab.add_theme_color_override("font_color", Color(1.0, 0.96, 0.72, 1.0))
		zh_lab.add_theme_color_override("font_outline_color", Color(0.06, 0.03, 0.01, 0.92))
		zh_lab.add_theme_constant_override("outline_size", 16)
		block.add_child(zh_lab)
	if en != "":
		var en_lab := Label.new()
		en_lab.text = en
		en_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		en_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		en_lab.add_theme_font_size_override("font_size", 36)
		en_lab.add_theme_color_override("font_color", Color(1.0, 0.90, 0.62, 0.96))
		en_lab.add_theme_color_override("font_outline_color", Color(0.06, 0.03, 0.01, 0.88))
		en_lab.add_theme_constant_override("outline_size", 10)
		block.add_child(en_lab)
	block.modulate = Color(1, 1, 1, 0)
	block.z_index = 20
	_sky_cheer_hud_layer.add_child(block)
	block.reset_size()
	block.custom_minimum_size = Vector2(maxf(block.size.x, 480.0), maxf(block.size.y, 96.0))
	block.reset_size()
	var layer_w := maxf(_sky_cheer_hud_layer.size.x, MOBILE_VIEWPORT_SIZE.x)
	var layer_h := maxf(_sky_cheer_hud_layer.size.y, MOBILE_VIEWPORT_SIZE.y)
	var from_right := _sky_cheer_rng.randf() > 0.45
	var start_x := layer_w + 60.0 if from_right else -block.size.x - 60.0
	var y := _sky_cheer_spawn_y(layer_h)
	block.position = Vector2(start_x, y)
	var life := _sky_cheer_rng.randf_range(4.8, 6.2)
	var speed := _sky_cheer_rng.randf_range(95.0, 140.0)
	if from_right:
		speed = -speed
	_sky_cheer_active.append({
		"label": block,
		"age": 0.0,
		"life": life,
		"speed": speed,
		"y": y,
		"bob": _sky_cheer_rng.randf_range(0.7, 1.3),
		"phase": _sky_cheer_rng.randf() * TAU,
	})

func _update_sky_cheer_visuals(delta: float) -> void:
	if _sky_cheer_active.is_empty():
		return
	var remain: Array[Dictionary] = []
	for entry in _sky_cheer_active:
		var lab := entry.get("label") as Label
		if lab == null or not is_instance_valid(lab):
			continue
		var age := float(entry.get("age", 0.0)) + delta
		entry["age"] = age
		var life := maxf(float(entry.get("life", 5.0)), 0.1)
		var t := age / life
		var fade_in := clampf(age / 0.4, 0.0, 1.0)
		var fade_out := clampf((1.0 - t) / 0.4, 0.0, 1.0)
		var alpha := minf(fade_in, fade_out) * 1.0
		lab.modulate = Color(1, 1, 1, alpha)
		var speed := float(entry.get("speed", 120.0))
		var bob := float(entry.get("bob", 1.0))
		var phase := float(entry.get("phase", 0.0))
		var y0 := float(entry.get("y", lab.position.y))
		lab.position.x += speed * delta
		lab.position.y = y0 + sin(age * bob + phase) * 12.0
		if t < 1.0 and alpha > 0.01:
			remain.append(entry)
		else:
			lab.queue_free()
	_sky_cheer_active = remain

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
		var obs_dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
		var half := float(obstacle.get("half_depth", _obstacle_half_depth(obstacle_type)))
		if bool(obstacle.get("float_orb", false)):
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
		var hit_hw := float(obstacle.get("hit_half_width", 0.34))
		return absf(current_lateral - lane_x) <= hit_hw
	var half_w := LANE_HIT_HALF_WIDTH_JUMP if obstacle_type in ["jump", "low_barrier", "orb"] else LANE_HIT_HALF_WIDTH
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
	var scroll := prog * SKY_PROGRESS_SCROLL
	var sky_yaw := _base_sky_yaw + scroll - path_yaw_rad * 0.48
	var target_fog := _base_fog_light_color
	var target_amb := _base_ambient_light_color
	var cloud_phase := elapsed * 0.40 + prog * 5.8 + track_distance * 0.0020
	var pan_energy := _base_panorama_energy
	pan_energy = _base_panorama_energy * (1.0 + 0.040 * sin(cloud_phase) + 0.024 * sin(cloud_phase * 2.31))
	env.sky_rotation = Vector3(0.0, sky_yaw, 0.0)
	var sky_mat := env.sky.sky_material if env.sky != null else null
	if sky_mat is PanoramaSkyMaterial:
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
		# 夕照微暖 ↔ 略冷 随路程变化，增强光影层次（不是一片黄）
		var warmth := clampf(1.0 - prog * 0.22, 0.72, 1.0)
		var cool := Color(_base_sun_color.r * 0.88, _base_sun_color.g * 0.92, minf(_base_sun_color.b * 1.12, 1.0))
		sun.light_color = cool.lerp(_base_sun_color, warmth)
	if not _sandstorm_active:
		env.fog_light_color = env.fog_light_color.lerp(target_fog, 0.06)
		env.ambient_light_color = env.ambient_light_color.lerp(target_amb, 0.05)
		env.fog_density = lerpf(env.fog_density, _base_fog_density, 0.04)


func _is_reservoir_w1_mission() -> bool:
	var mid := String(mission.get("mission_id", ""))
	if mid == "mission_reservoir_01":
		return true
	return _mission_layout_id() == "mission_reservoir_w1"


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
	if not use_screen_pop and player != null and camera != null:
		var basis := camera.global_transform.basis
		var slot := streak_idx % 3
		var anchor := player.global_position + Vector3(0.0, 1.12, 0.0)
		var start := anchor + basis.x * (0.38 + float(slot) * 0.14) + basis.y * (0.42 + float(slot) * 0.16) + basis.z * (-0.10 - float(slot) * 0.06)
		var end := start + basis.x * 0.42 + basis.y * 0.92 + basis.z * (-0.26)
		var float_lbl := Label3D.new()
		float_lbl.text = "+%d" % int(LevelConfig.EMBER_COIN_VALUE)
		float_lbl.font_size = 96 + mini(streak_idx, 12) * 4
		float_lbl.modulate = bright
		float_lbl.outline_modulate = Color(0.22, 0.10, 0.02, 0.92)
		float_lbl.outline_size = 10
		float_lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		float_lbl.no_depth_test = true
		track_root.add_child(float_lbl)
		float_lbl.global_position = start
		var txt_tw := create_tween()
		txt_tw.set_parallel(true)
		txt_tw.tween_property(float_lbl, "global_position", end, 0.48).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		txt_tw.tween_property(float_lbl, "modulate:a", 0.0, 0.48).set_delay(0.16).set_ease(Tween.EASE_IN)
		txt_tw.chain().tween_callback(float_lbl.queue_free)
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


func _try_side_runway_entry() -> void:
	if track_layer != 0 or player == null:
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
	track_layer = WALL_RUN_LAYER
	_wall_mount_armed = false
	_last_wall_side = _wall_zone_side(zone)
	lane_index = 1
	target_lane_x = 0.0
	current_lateral = 0.0
	current_wall_y = WALL_LANE_HEIGHTS[1]
	player.position.y = current_wall_y
	vertical_velocity = 0.0
	camera_shake = maxf(camera_shake, 0.1)
	_sync_player_position()
	_show_gate_toast("侧墙跑 · 上下换高度道")
	_complete_wall_run_tutorial()

func _is_over_open_pit() -> bool:
	if track_layer != 0:
		return false
	if _is_in_side_runway_pit(track_distance):
		return true
	return _is_in_main_block_pit(track_distance)

func _is_in_main_block_pit(distance: float) -> bool:
	for obstacle in obstacles:
		if String(obstacle.get("type", "")) != "main_block":
			continue
		if int(obstacle.get("layer", 0)) != 0:
			continue
		var center := float(obstacle.get("distance", 0.0))
		var half := float(obstacle.get("half_depth", OBSTACLE_HALF_DEPTH.get("main_block", 8.0)))
		if distance >= center - half and distance <= center + half:
			return true
	return false

func _fail_into_pit(reason: String = "坠入主路熔岩坍塌坑") -> void:
	if is_failed or is_finished:
		return
	if _wall_tut_step >= WALL_TUT_APPROACH and _wall_tut_step < WALL_TUT_DONE:
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
		if _wall_tut_step >= WALL_TUT_APPROACH and _wall_tut_step < WALL_TUT_DONE:
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
	var entry := float(zone.get("entry_window", 10.0))
	var side := _wall_zone_side(zone)
	for i in 4:
		var d := start - entry + 3.0 + float(i) * 3.0
		if d < 5.0:
			continue
		# 与常驻引导一致：地面中央水平 →
		_wall_tut_root.add_child(_make_wall_tut_arrow(d, 0.0, side))
	_wall_tut_root.add_child(_make_wall_tut_ready_pad(start - 2.0, start + 8.0, side))
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
	var label := Label3D.new()
	label.text = "坍塌坑 · 上侧墙"
	label.font_size = 52
	label.modulate = Color(1.0, 0.55, 0.25)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 2.4, 0.0)
	root.add_child(label)
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
	if not _is_in_main_block_pit(distance):
		return {}
	var best: Dictionary = {}
	var best_gap := INF
	for zone in _side_runway_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		var start := float(zone.get("start", 0.0))
		var end := start + float(zone.get("length", 70.0))
		var entry := float(zone.get("entry_window", 10.0))
		if distance < start - entry - 4.0:
			continue
		if distance > end + 48.0:
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
		var zone := _side_runway_zone_at(track_distance)
		if zone.is_empty():
			zone = _side_runway_entry_zone(track_distance)
		# 侧墙区间已结束但仍在坍塌坑上：禁止下墙，沿用最近侧墙继续贴跑
		if zone.is_empty() and _is_in_main_block_pit(track_distance):
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
		_last_wall_side = _wall_zone_side(zone)
		if player.position.y <= current_wall_y + 0.05 and vertical_velocity <= 0.01:
			player.position.y = current_wall_y
			vertical_velocity = 0.0
		return
	if _is_on_ground() and not _is_over_open_pit() and absf(player.position.y - _layer_height(0)) > 0.05:
		player.position.y = _layer_height(0)
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
		offset += dir * drift_speed * delta
		if offset >= ORB_DRIFT_SPAN:
			offset = ORB_DRIFT_SPAN
			obstacle["lateral_dir"] = -1.0
		elif offset <= -ORB_DRIFT_SPAN:
			offset = -ORB_DRIFT_SPAN
			obstacle["lateral_dir"] = 1.0
		obstacle["lateral_offset"] = offset
		_place_obstacle_node(obstacle)
		var visual := node.get_node_or_null("JumpObstacleModel") as Node3D
		if visual:
			var base_scale: Vector3 = obstacle.get("orb_base_scale", Vector3.ONE)
			var pop := float(obstacle.get("orb_pop", 1.0))
			var pop_scale := lerpf(0.05, 1.0, pop * pop)
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

func _inject_fast_fork_branch_obstacles() -> void:
	for zone in _junction_zones():
		if typeof(zone) != TYPE_DICTIONARY:
			continue
		if String(zone.get("effect_b", "")) != "fast":
			continue
		var start := float(zone.get("distance", 0.0))
		var length := float(zone.get("length", 70.0))
		var pattern: Array[Dictionary] = [
			{"t": 0.20, "lane": 0, "type": "jump"},
			{"t": 0.36, "lane": -1, "type": "train"},
			{"t": 0.52, "lane": 1, "type": "jump"},
			{"t": 0.68, "lane": 0, "type": "slide"},
		]
		for spec in pattern:
			var dist := start + length * float(spec.get("t", 0.0))
			if _has_fork_branch_obstacle_near(dist, 1):
				continue
			_register_obstacle({
				"distance": dist,
				"lane": int(spec.get("lane", 0)),
				"type": String(spec.get("type", "jump")),
				"layer": 0,
				"fork_branch": 1,
			})
	obstacles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)

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
	if bool(obstacle.get("_path_placed", false)) and obstacle_type in ["train", "train_moving"]:
		return
	var dist: float = float(obstacle["distance"]) + float(obstacle.get("move_offset", 0.0))
	var layer: int = int(obstacle.get("layer", 0))
	var y := _road_lane_y(layer) + float(obstacle.get("y_offset", 0.0))
	var full_width := _is_full_width_obstacle_type(obstacle_type)
	var lateral := 0.0
	if not full_width:
		if bool(obstacle.get("float_orb", false)):
			lateral = float(obstacle["lane"]) * LANE_WIDTH + float(obstacle.get("lateral_offset", 0.0))
		else:
			lateral = float(obstacle["lane"]) * LANE_WIDTH
	if obstacle_type in ["slide", "high_bar", "main_block"]:
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
	if obstacle_type in ["train", "train_moving"]:
		obstacle["_path_placed"] = true
		_try_attach_gate_boosts_for_train(obstacle)
		_register_train_gate_shield_crystal(obstacle)

func _finish_run() -> void:
	is_finished = true
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
	if not is_custom:
		if LevelConfig.has_method("get_outpost_meta"):
			var outpost_meta: Dictionary = LevelConfig.get_outpost_meta(Global.runner_location_id)
			repair_total = maxi(1, int(outpost_meta.get("repair_total", repair_total)))
			light_reward_coins = maxi(0, int(outpost_meta.get("reward_coins", 0)))
		progress_result = Global.apply_runner_delivery_progress(
			Global.runner_planet_id,
			Global.runner_location_id,
			progress_cargo_load,
			cargo_integrity,
			repair_total
		)
	var newly_lit := bool(progress_result.get("newly_lit", false))
	var already_lit := bool(progress_result.get("already_lit", false))
	var contribution := int(progress_result.get("contribution", 0))
	var progress_after := int(progress_result.get("progress_after", 0))
	var progress_total := int(progress_result.get("repair_total", repair_total))
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
	var type_reward := int(_mission_profile.get("base_reward", mission.get("base_reward", 0)))
	var coin_bonus := int(round(float(base_coins) * Global.get_coin_yield_multiplier() * grade_mult * time_mult))
	var type_reward_paid := int(round(float(type_reward) * time_mult))
	run_score += delivered + coin_bonus + type_reward_paid
	Global.add_ember_coins(coin_bonus + type_reward_paid)
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
		_run_time,
	]
	var total_reward := coin_bonus + type_reward_paid
	var settlement_body := "%s\nCargo Integrity • %0.0f%%\nRating • %s\nOutpost Progress • %d / %d\n\nMission Reward • %d Ember Coins\nXP +%d • %s" % [
		type_line,
		cargo_integrity,
		grade_label,
		progress_after,
		progress_total,
		total_reward,
		int(xp_result["xp_gain"]),
		level_text,
	]
	var location_title := _finish_outpost_title_en()
	_settlement_is_failure = false
	_show_state(location_title, settlement_body, "success")
	if state_back_button and String(Global.runner_return_scene) == "":
		state_back_button.text = "BACK TO MAP"
	_set_continue_run_enabled(true)
	if state_restart_button and newly_lit:
		state_restart_button.visible = false
	elif state_restart_button:
		state_restart_button.visible = true
		state_restart_button.text = "CONTINUE RUN" if already_lit else "CONTINUE RUN"

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
	is_failed = true
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
	if _settlement_is_failure:
		_return_to_exploration_map()
	else:
		_return_to_home()

func _fail_reason_en(reason: String) -> String:
	var text := reason.strip_edges()
	if text.contains("货物") or text.contains("损毁") or text.contains("完整度"):
		return "DELIVERY LOST"
	if text.contains("时间") or text.contains("限时"):
		return "TIME OUT"
	if text.contains("零潮") or text.contains("追上"):
		return "ZERO TIDE CAUGHT YOU"
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
		_apply_settlement_button_style(state_restart_button, Color("#2A1C10", 0.96), Color("#E8A840", 0.82))
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

func _return_to_home() -> void:
	if _pause_overlay != null and _pause_overlay.is_paused():
		_pause_overlay.close_pause()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Global.play_home_bgm()
	var return_scene := String(Global.runner_return_scene)
	Global.runner_return_scene = ""
	if return_scene != "":
		Global.change_game_scene(return_scene)
		return
	if _settlement_is_failure:
		_return_to_exploration_map()
		return
	Global.exploration_planet_id = Global.runner_planet_id
	Global.mobile_home_tab = "home"
	Global.change_game_scene(PlanetDatabase.MOBILE_HOME_SCENE)

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
		# 侧墙换列更干脆，并给明确反馈
		current_wall_y = lerpf(current_wall_y, target_wy, 0.78)
		vertical_velocity = maxf(vertical_velocity, 3.6)
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
		return clampf(explicit, 0.65, 2.0)
	if _is_overweight_cargo():
		return 0.78
	return 1.0


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
	var dmg := SMASH_CARGO_BASE * tier * _cargo_fragility_mult() * Global.get_cargo_damage_multiplier()
	return clampf(dmg, SMASH_CARGO_DAMAGE_MIN, SMASH_CARGO_DAMAGE_MAX)




func _is_large_smash_obstacle(obstacle_type: String) -> bool:
	return obstacle_type in ["train", "train_moving", "slide", "high_bar", "block_left", "block_right", "meteorite"]


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
			return "huge" if otype == "train_moving" else "large"
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
	return otype != "main_block" and otype != "ramp" and otype != "turn_left" and otype != "turn_right"


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
		_fail_into_pit("冲入主路熔岩坍塌带（需上侧墙绕过）")
		return
	strike_count += 1
	strike_recovery_timer = 0.0
	chaser_distance = maxf(chaser_distance - CHASER_HIT_PENALTY, CHASER_CATCH_DISTANCE)
	var rushing := _is_fork_rushing()
	var smash := _uses_smash_collision() and _can_smash_obstacle(obstacle)
	if smash:
		_smash_hit_count += 1
		_apply_smash_body_impact(_is_large_smash_obstacle_entry(obstacle))
		run_score += 18
		var cargo_dmg := _smash_cargo_damage
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
		if chaser_distance <= CHASER_CATCH_DISTANCE and _chaser_enabled:
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
	var fragility := clampf(float(mission.get("cargo_fragility", 1.0)), 0.5, 2.5)
	var damage: float = float(LevelConfig.CARGO_DAMAGE_PER_HIT) * tier * Global.get_cargo_damage_multiplier() * fragility
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
	if chaser_distance <= CHASER_CATCH_DISTANCE:
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

func _update_chaser(delta: float) -> void:
	if not _chaser_enabled:
		return
	chaser_distance = maxf(chaser_distance - CHASER_BASE_CREEP * delta, CHASER_CATCH_DISTANCE)
	if strike_count > 0:
		strike_recovery_timer += delta
		if strike_recovery_timer >= STRIKE_RECOVERY_TIME:
			strike_count = 0
			strike_recovery_timer = 0.0
	elif chaser_distance < CHASER_MAX_DISTANCE:
		chaser_distance = minf(chaser_distance + CHASER_RECOVERY_RATE * delta, CHASER_MAX_DISTANCE)

func _check_chaser_caught() -> void:
	if not _chaser_enabled:
		return
	if chaser_distance <= CHASER_CATCH_DISTANCE:
		_fail_run("%s 追上了你" % LevelConfig.CHASER_NAME)

func _update_pre_run(delta: float) -> void:
	intro_elapsed += delta
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
		intro_title.text = str(countdown_step)
		intro_body.text = _pre_run_briefing_text()
		if countdown_timer >= PRE_RUN_COUNTDOWN_STEP:
			countdown_timer = 0.0
			countdown_step -= 1
			if countdown_step <= 0:
				is_intro = false
				gameplay_active = true
				intro_panel.visible = false
				_set_player_intro_facing(false)
				_schedule_sky_cheer_danmaku()
				_overweight_intro_pending = _is_overweight_cargo()
				_overweight_run_tip_shown = false
				call_deferred("_try_show_overweight_intro_tip")
		return

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

func _ease_out_cubic(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)

func _sync_chaser_from_track() -> void:
	if not chaser:
		return
	# 第三人称镜头下，3D 追逐者放在身后一定会挡视线；改为 HUD 提示
	chaser.visible = false

func _start_slide() -> void:
	slide_timer = SLIDE_TIME
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

func _hits_obstacle(obstacle: Dictionary) -> bool:
	var obstacle_type := String(obstacle["type"])
	var on_wall_obs := _is_wall_running() and int(obstacle.get("layer", 0)) == WALL_RUN_LAYER
	match obstacle_type:
		"slide", "high_bar":
			# 侧墙：滑铲动作 = 切到最低列；也可跳过横杆
			if on_wall_obs:
				return not (lane_index <= 0 or _player_clears_obstacle(obstacle))
			var open_bottom := float(obstacle.get("open_bottom", SLIDE_GATE_OPEN_BOTTOM))
			var is_low_bar := open_bottom <= LOW_SLIDE_OPEN_BOTTOM + 0.06
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
		"jump", "low_barrier", "orb":
			if on_wall_obs and obstacle_type != "orb":
				# 侧墙低栏：低列从下方钻过，中列须跳，高列可直接过
				var under_y := float(WALL_LANE_HEIGHTS[1]) - 0.55
				if player.position.y <= under_y:
					return false
				return not _player_clears_obstacle(obstacle)
			return not _player_clears_obstacle(obstacle)
		"meteorite":
			# 占道陨石：换道躲开，或高跳越过；高空下落中不结算碰撞
			if float(obstacle.get("meteor_air_y", 0.0)) > 1.15:
				return false
			return not _player_clears_obstacle(obstacle)
		"train", "train_moving":
			# 黄色巨门（广告牌门架）：空心可过；光波刀落下时才挡路；W1 教学关仅视觉不碰撞
			return _train_gate_blocks_player(obstacle)
		"block_left", "block_right", "main_block":
			# 横向已过滤，进窗口即撞；主路封堵不可跳过
			return true
		"ramp", "turn_left", "turn_right":
			return false
	return not _player_clears_obstacle(obstacle)

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
	# 关卡 JSON 火车门：空心可穿，光波刀仅作示意
	if _runner_layout_id() != "":
		return false
	if _is_sliding() or _player_clears_obstacle(obstacle):
		return false
	return _slide_blade_is_blocking(obstacle)


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
	var imported: Variant = load(path)
	if imported is Texture2D:
		return imported as Texture2D
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img != null and not img.is_empty():
		push_warning("Panorama import missing, loaded raw image: %s" % path)
		return ImageTexture.create_from_image(img)
	push_error("Failed to load panorama: %s" % path)
	return null

func _load_planet_assets() -> void:
	var assets: Dictionary = LevelConfig.get_assets()
	var mission_pano := String(mission.get("panorama", "")).strip_edges()
	var default_pano := String(assets.get("panorama", "res://3d素材/三拼地图.png")).strip_edges()
	if mission_pano != "":
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
	_purge_energy_orb_scene_cache()
	_slide_obstacle_paths.clear()
	var slide_src: Array = mission.get("slide_obstacles", assets.get("slide_obstacles", []))
	for path in slide_src:
		_slide_obstacle_paths.append(String(path))
	if _slide_obstacle_paths.is_empty() and assets.has("slide_obstacle"):
		_slide_obstacle_paths.append(String(assets.get("slide_obstacle")))
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
	_apply_location_distant_props()
	_distant_pod_paths.clear()
	for path in assets.get("distant_pod_props", []):
		_distant_pod_paths.append(String(path))
	_distant_spaceship_paths.clear()
	for path in assets.get("distant_spaceship_props", assets.get("distant_anchor_props", [])):
		_distant_spaceship_paths.append(String(path))
	_distant_hearth_paths.clear()
	for path in assets.get("distant_hearth_props", []):
		_distant_hearth_paths.append(String(path))
	if _distant_hearth_paths.is_empty() and assets.has("hearth"):
		_distant_hearth_paths.append(String(assets.get("hearth")))
	var slide_path := _slide_obstacle_paths[0] if not _slide_obstacle_paths.is_empty() else String(assets.get("slide_obstacle", "res://3d素材/障碍物-需滑铲.glb"))
	_slide_obstacle_scene = _load_runner_scene(slide_path, false)
	_hearth_scene_path = LevelConfig.get_location_hearth_model(Global.runner_location_id) if LevelConfig.has_method("get_location_hearth_model") else String(assets.get("hearth", "res://3d素材/居民穹顶据点 3d model.glb"))
	_player_scene_paths = _resolve_player_scene_paths(assets)

func _apply_location_distant_props() -> void:
	# 信号塔仅防御哨站；水源/穹顶/医疗用晶砂荒原水晶柱 + 据点模型
	var loc := String(Global.runner_location_id)
	if loc == "gate":
		_distant_tower_paths = [
			"res://assets/maps/route_levels/runner_60s/distant_props/fantasy_crystal_tower.glb",
			"res://assets/maps/route_levels/runner_60s/distant_props/distant_signal_tower.glb",
		]
	else:
		var kept: Array[String] = []
		for path in _distant_tower_paths:
			var p := String(path)
			if "signal_tower" in p.to_lower():
				continue
			kept.append(p)
		if kept.is_empty():
			kept.append("res://assets/maps/route_levels/runner_60s/distant_props/fantasy_crystal_tower.glb")
		_distant_tower_paths = kept
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
	if player_pose_name == logical:
		return
	player_pose_name = logical

	match logical:
		"slide":
			if player_pose_root:
				player_pose_root.visible = false
			if player_slide_pose_root:
				player_slide_pose_root.visible = true
			_hide_air_pose_models()
			if player_animation_player:
				player_animation_player.stop()
		"jump_start", "jump_peak", "landing":
			if player_pose_root:
				player_pose_root.visible = false
			if player_slide_pose_root:
				player_slide_pose_root.visible = false
			_show_air_pose_model(logical)
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
	environment.fog_enabled = true
	environment.glow_enabled = false
	world.environment = environment
	_world_environment = world
	add_child(world)
	if _background_uses_starfield():
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
	_apply_mission_environment()
	_apply_road_style_environment()
	if _world_environment and _world_environment.environment:
		var env := _world_environment.environment
		_base_fog_density = env.fog_density
		_base_fog_light_color = env.fog_light_color
		_base_ambient_light_color = env.ambient_light_color
		_base_sky_yaw = env.sky_rotation.y
		if env.sky != null and env.sky.sky_material is PanoramaSkyMaterial:
			_base_panorama_energy = (env.sky.sky_material as PanoramaSkyMaterial).energy_multiplier
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
		environment.background_color = theme.get("background", Color(0.14, 0.09, 0.05))
		var sky := Sky.new()
		if _world_panorama != null:
			var panorama := PanoramaSkyMaterial.new()
			panorama.panorama = _world_panorama
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
	else:
		sun.light_color = theme.get("sun_color", Color(0.96, 0.82, 0.62))
		sun.light_energy = float(theme.get("sun_energy", 1.85 if _background_style_id == "desert_crystal" else 2.4))

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
			# 晶砂荒原：琥珀夕照 + 紫灰薄雾，避免纯黄洗屏
			env.ambient_light_color = Color(0.48, 0.44, 0.56)
			env.ambient_light_energy = 0.74
			env.fog_light_color = Color(0.38, 0.32, 0.42)
			env.fog_density = 0.00038
			env.fog_aerial_perspective = 0.07
			env.glow_enabled = false
			env.tonemap_exposure = 0.98
			_boost_runner_lights(Color(0.94, 0.78, 0.58), 1.75, 0.42)
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
	if overrides.has("ambient"):
		env.ambient_light_color = overrides["ambient"]
	if overrides.has("ambient_energy"):
		env.ambient_light_energy = float(overrides["ambient_energy"])

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
	# 对齐 W1 夕照玻璃沙漠：暖橙沙 + 路缘软影
	mat.set_shader_parameter("sand_tint", Color(0.96, 0.76, 0.5))
	mat.set_shader_parameter("warm_tint", Color(0.92, 0.58, 0.32))
	mat.set_shader_parameter("cool_shadow", Color(0.48, 0.3, 0.2))
	mat.set_shader_parameter("dust_veil", Color(0.82, 0.62, 0.4))
	mat.set_shader_parameter("tex_scale", 0.016)
	mat.set_shader_parameter("detail_scale", 0.22)
	mat.set_shader_parameter("tone_warmth", 0.58)
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
			_attach_path_strip_segment(
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

func _build_side_runway_tracks() -> void:
	if LevelConfig == null:
		return
	var kit := _make_road_style_kit(_road_style_id)
	for zone in _side_runway_zones():
		_attach_wall_run_mesh(zone, kit)
		_attach_wall_run_entry_ramp(zone, kit)
		_attach_side_runway_pit(zone, kit)
	# main_block：沿路径挖坑+警示，避免长方体在弯道斜出跑道外
	for gap in _main_block_road_gaps():
		_attach_main_block_path_pit(gap, kit)
	_setup_wall_run_tutorial_markers()

func _build_sandstorm_zones() -> void:
	for zone in _sandstorm_zones():
		_attach_sandstorm_volume(zone)
	_sandstorm_particles = _make_sandstorm_particles()
	add_child(_sandstorm_particles)
	_sandstorm_particles.emitting = false
	_sandstorm_grit_particles = _make_sandstorm_grit_particles()
	add_child(_sandstorm_grit_particles)
	_sandstorm_grit_particles.emitting = false

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

func _side_runway_pit_range(zone: Dictionary) -> Vector2:
	var start := float(zone["start"])
	var length := float(zone.get("length", 70.0))
	# 入口留几米上墙，中后段挖坑
	var pit_s := start + 5.0
	var pit_e := start + length - 2.0
	return Vector2(pit_s, pit_e)

func _main_block_road_gaps() -> Array:
	# 路网建造早于障碍注册：直接读本关障碍表
	var items: Array = []
	if CustomLevels.has_level(Global.runner_location_id):
		items = CustomLevels.load_obstacles(Global.runner_location_id)
	elif LevelConfig != null and LevelConfig.has_method("build_obstacles"):
		items = LevelConfig.build_obstacles()
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
		gaps.append(Vector2(center - half, center + half))
	return gaps

func _is_in_side_runway_pit(distance: float) -> bool:
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
	_attach_path_strip_segment(pit.x, pit.y, 8.4, lane_y - 5.2, abyss_mat, 1.8, 0.0)
	_attach_path_strip_segment(pit.x, pit.y, 7.6, lane_y - 3.4, abyss_mat, 1.8, 0.0)
	# 熔岩面：略低于路面，带流动发光
	var lava_mat := _make_pit_lava_material()
	_attach_path_strip_segment(pit.x + 0.4, pit.y - 0.4, 6.6, lane_y - 1.15, lava_mat, 1.6, 0.0)
	_attach_path_strip_segment(pit.x + 1.0, pit.y - 1.0, 4.8, lane_y - 0.72, lava_mat, 1.6, 0.0)
	# 焦黑坑沿：遮住「像平地」的橙边
	var char_mat := _make_material(Color(0.04, 0.03, 0.035), Color(0.35, 0.08, 0.02), 0.55)
	_attach_path_strip_segment(pit.x - 0.4, pit.x + 1.2, 7.0, lane_y + 0.02, char_mat, 1.2, 0.0)
	_attach_path_strip_segment(pit.y - 1.2, pit.y + 0.4, 7.0, lane_y + 0.02, char_mat, 1.2, 0.0)
	_attach_path_strip_segment(pit.x, pit.y, 7.8, lane_y - 0.08, char_mat, 1.8, 0.0)
	if curb_mat:
		_attach_path_strip_segment(pit.x - 0.9, pit.x + 0.5, 6.2, lane_y + 0.05, curb_mat, 1.2, 0.0)
		_attach_path_strip_segment(pit.y - 0.5, pit.y + 0.9, 6.2, lane_y + 0.05, curb_mat, 1.2, 0.0)
	# 边缘热晕（半透明，不要铺成整块橙地）
	var glow_mat := _make_material(Color(0.85, 0.22, 0.04, 0.16), Color(0.9, 0.32, 0.04), 1.35)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_attach_path_strip_segment(pit.x + 0.2, pit.y - 0.2, 7.1, lane_y + 0.04, glow_mat, 2.0, 0.0)
	_attach_pit_lava_embers(pit)
	var mid := (pit.x + pit.y) * 0.5
	var sample := _sample_path(mid)
	var label := Label3D.new()
	label.name = node_name + "Label"
	label.text = "主路熔岩坍塌\n上侧墙绕过"
	label.font_size = 56
	label.modulate = Color(1.0, 0.45, 0.18)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = (sample["pos"] as Vector3) + Vector3(0.0, lane_y + 2.6, 0.0)
	track_root.add_child(label)

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

	# 侧墙加速光带：窄条琥珀提示
	var boost_mat := _make_material(Color(0.42, 0.22, 0.08, 0.42), Color(0.95, 0.52, 0.14), 1.35)
	boost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var boost_st := SurfaceTool.new()
	boost_st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(slices.size() - 1):
		var a: Dictionary = slices[i]
		var b: Dictionary = slices[i + 1]
		var a_in: Vector3 = a["inner_bottom"]
		var b_in: Vector3 = b["inner_bottom"]
		var a_top: Vector3 = a["inner_top"]
		var b_top: Vector3 = b["inner_top"]
		var a_out: Vector3 = a["outer_bottom"]
		var inward_a := (a_in - a_out)
		if inward_a.length_squared() < 0.0001:
			inward_a = Vector3.RIGHT * (-side)
		inward_a = inward_a.normalized() * 0.1
		_add_wall_quad(
			boost_st,
			a_in + inward_a + Vector3(0, 0.15, 0),
			b_in + inward_a + Vector3(0, 0.15, 0),
			b_top + inward_a - Vector3(0, 0.2, 0),
			a_top + inward_a - Vector3(0, 0.2, 0)
		)
	var boost_mesh := boost_st.commit()
	if boost_mesh != null:
		var boost_mi := MeshInstance3D.new()
		boost_mi.name = "WallRunBoostFace"
		boost_mi.mesh = boost_mesh
		boost_mi.material_override = boost_mat
		boost_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_attach_road(boost_mi)

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
	_attach_path_strip_segment(ramp_start, start + 2.0, road_half * 0.38, lane_y + 0.004, road_mat, 1.6, shoulder_bias)

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
	var road := kit.get("road") as Material
	if road != null:
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
	L.y = y
	R.y = y
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
	var tex_path := "res://assets/maps/route_levels/runner_60s/textures/white_sandstone_blocks_02_diff_1k.jpg"
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
			"res://assets/maps/route_levels/runner_60s/holographic_road_topdown.png",
			"res://assets/maps/route_levels/runner_60s/holographic_energy_runway.png",
		]
	else:
		tex_paths = [
			"res://assets/maps/route_levels/runner_60s/holographic_energy_runway.png",
			"res://assets/maps/route_levels/runner_60s/holographic_road_topdown.png",
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
	var tex_path := "res://assets/maps/route_levels/runner_60s/energy_neon_runway.png"
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
			env.glow_enabled = false
			env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
			env.tonemap_exposure = maxf(env.tonemap_exposure, 1.04)
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
	_attach_path_strip_segment(
		start, start + length, pad_half, _desert_ground_y(lane_y), sand_material, 1.75, 0.0
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
	_attach_path_strip_segment(start - 2.0, start + tip, bridge_half, lane_y + 0.006, road_material, 1.2, 0.0)
	_attach_path_strip_segment(start + length - tip, start + length + 4.0, bridge_half, lane_y + 0.006, road_material, 1.2, 0.0)
	_build_fork_entry_wedge(zone, curb_material if curb_material else road_material, lane_y)
	var sand_fill: Material = (
		_make_desert_surroundings_material()
		if _mission_uses_textured_ground()
		else shoulder_material
	)
	_build_fork_junction_sand_base(zone, lane_y, sand_fill)
	_build_fork_gap_ground_fill(zone, lane_y, sand_fill)
	if _mission_uses_textured_ground():
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
	if not _distant_tower_paths.is_empty() or not _distant_spaceship_paths.is_empty() or not _distant_hearth_paths.is_empty():
		_build_distant_background(theme)

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
			_disable_mesh_shadows(inst)
		d += rng.randf_range(18.0, 28.0)

func _build_path_side_dressing(_theme: Dictionary) -> void:
	_build_midground_dressing(_theme)

func _build_midground_dressing(_theme: Dictionary) -> void:
	_ensure_midground_prop_paths()
	if _midground_prop_paths.is_empty():
		return
	_side_dressing_root = Node3D.new()
	_side_dressing_root.name = "MidgroundDressing"
	track_root.add_child(_side_dressing_root)

	var planet_key := "runner"
	if LevelConfig.has_method("get_planet_id"):
		planet_key = String(LevelConfig.get_planet_id())
	var track_end := maxf(_path_length, _track_length) + 48.0
	_build_midground_dressing_pass(
		planet_key + "_midground_v5",
		_midground_prop_paths_filtered(false),
		track_end
	)
	_build_midground_dressing_pass(
		planet_key + "_midground_robot_v1",
		_midground_robot_prop_paths(),
		track_end,
		START_PAD_LENGTH + 19.0
	)

func _midground_prop_paths_filtered(include_robots: bool) -> Array[String]:
	var out: Array[String] = []
	for path in _midground_prop_paths:
		var is_robot := _is_midground_robot(path)
		if include_robots:
			if is_robot:
				out.append(path)
		elif not is_robot:
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
		var spacing_min := MIDGROUND_CLUSTER_SPACING_MIN
		var spacing_max := MIDGROUND_CLUSTER_SPACING_MAX
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
		push_warning("Midground dressing spawned 0 props; check GLB paths under midground_props/")

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
	elif rng.randf() < 0.12:
		sides.append(1.0)
		sides.append(-1.0)
	else:
		sides.append(1.0 if rng.randf() > 0.5 else -1.0)
	return sides

func _is_midground_neon_sign(path: String) -> bool:
	var lower := path.to_lower()
	return "neon_sign" in lower or "neon+sign" in lower

func _is_midground_meteorite(path: String) -> bool:
	var lower := path.to_lower()
	return "meteorite" in lower or "energy_meteorite" in lower

func _is_midground_robot(path: String) -> bool:
	var lower := path.to_lower()
	return "sphere_robot" in lower or "cracked_sphere" in lower or "excavator" in lower or "excavator" in lower or "excavator" in lower

func _pick_meteorite_palette(rng: RandomNumberGenerator, distance: float, lateral: float) -> Dictionary:
	var palettes: Array = MIDGROUND_METEORITE_PALETTES
	if palettes.is_empty():
		return {}
	var idx := absi(int(distance * 1.9) + int(lateral * 13.0) + rng.randi_range(0, 3)) % palettes.size()
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
	var pool: Array[String] = paths if not paths.is_empty() else _midground_prop_paths
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
	if "medical_pod" in lower or "medical_crate" in lower or "water_purifier" in lower:
		return {
			"height_min": 2.8,
			"height_max": 5.2,
			"lateral_min": 13.0,
			"lateral_max": 18.5,
			"cluster_chance": 0.14,
			"cluster_min": 1,
			"cluster_max": 1,
			"emission_boost": 0.55,
			"weight_warmup": 0.18,
			"weight_mid": 0.34,
			"weight_late": 0.28,
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
		return {
			"height_min": 2.6,
			"height_max": 4.6,
			"lateral_min": 13.5,
			"lateral_max": 19.0,
			"cluster_chance": 0.1,
			"cluster_min": 1,
			"cluster_max": 1,
			"emission_boost": 0.7,
			"weight_warmup": 0.1,
			"weight_mid": 0.28,
			"weight_late": 0.32,
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
	emission_boost: float = 1.0
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
		root.rotation.y = path_yaw + rng.randf_range(-0.42, 0.42)
	root.set_meta("path_distance", distance)
	var footprint := clampf(target_height * 1.55, 2.8, 7.5)
	if is_neon:
		footprint = clampf(target_height * 1.35, 2.6, 6.2)
	var model := _add_scaled_model_visual(
		root,
		scene,
		"MidPropModel",
		target_height,
		model_yaw,
		Vector3.ZERO,
		footprint,
		MIDGROUND_SCALE_CAP
	)
	_enforce_midground_min_size(model, target_height)
	_preserve_midground_materials(root)
	if _is_midground_meteorite(asset_path):
		_apply_midground_meteorite_variant(root, _pick_meteorite_palette(rng, distance, lateral))
	_disable_mesh_shadows(root)
	return true

func _apply_midground_meteorite_variant(root: Node3D, palette: Dictionary) -> void:
	if palette.is_empty():
		return
	var albedo_tint: Color = palette.get("albedo", Color.WHITE)
	var emission: Color = palette.get("emission", Color(0.4, 0.65, 0.95))
	var emission_energy := float(palette.get("emission_energy", 0.85))
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
				dup.albedo_color = dup.albedo_color * albedo_tint
				dup.emission_enabled = true
				dup.emission = emission
				dup.emission_energy_multiplier = emission_energy
				mesh_instance.set_surface_override_material(surface_i, dup)

func _preserve_midground_materials(root: Node3D) -> void:
	# 保留 GLB 自带 PBR 贴图/颜色，禁止代码洗成粉紫发光
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		mesh_instance.material_override = null
		if mesh_instance.mesh == null:
			continue
		for surface_i in mesh_instance.mesh.get_surface_count():
			var mat := mesh_instance.get_surface_override_material(surface_i)
			if mat == null:
				mat = mesh_instance.mesh.surface_get_material(surface_i)
			if mat is StandardMaterial3D:
				var dup := (mat as StandardMaterial3D).duplicate() as StandardMaterial3D
				dup.emission_energy_multiplier = clampf(dup.emission_energy_multiplier, 0.0, 1.25)
				mesh_instance.set_surface_override_material(surface_i, dup)

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

func _distant_safe_footprint(lateral: float, preferred: float) -> float:
	var edge_room := absf(lateral) - DISTANT_RUNWAY_CLEARANCE
	return clampf(minf(preferred, edge_room * 2.0), 4.0, 12.0)

func _build_distant_background(_theme: Dictionary) -> void:
	# 远景锚点：固定在世界坐标，高横向偏移不占用跑道；能量柱稍密，其间错落飞船/穹顶。
	_distant_background_root = Node3D.new()
	_distant_background_root.name = "DistantBackground"
	track_root.add_child(_distant_background_root)

	var rng := RandomNumberGenerator.new()
	var planet_key := "runner"
	if LevelConfig.has_method("get_planet_id"):
		planet_key = String(LevelConfig.get_planet_id())
	rng.seed = hash(planet_key + "_distant_v3")

	var track_end := maxf(_path_length, _track_length) + 48.0
	var d := 48.0
	var slot_i := 0
	var distant_density := _mission_sky_distant_density()
	while d < track_end:
		if _should_skip_distant_at(d):
			d += rng.randf_range(18.0, 28.0)
			slot_i += 1
			continue
		var fork_push := 8.0 if _is_in_fork_main_gap(d) else 0.0
		# 能量柱：略密，多数段左右各一组。
		if not _distant_tower_paths.is_empty():
			var tower_sides: Array = [-1.0, 1.0] if slot_i % 3 != 2 else [1.0 if slot_i % 2 == 0 else -1.0]
			for side in tower_sides:
				var lateral := float(side) * (rng.randf_range(DISTANT_TOWER_LATERAL_MIN, DISTANT_TOWER_LATERAL_MAX) + fork_push)
				_spawn_distant_tower_cluster(
					d + rng.randf_range(-3.0, 3.0),
					lateral,
					rng,
					rng.randf_range(28.0, 46.0)
				)
		# 能量柱之间错落：飞船或居民穹顶，偏更远横向。
		if slot_i % 2 == 1:
			var accent_d := d + rng.randf_range(12.0, 24.0)
			var accent_side := 1.0 if rng.randf() > 0.5 else -1.0
			var accent_lateral := accent_side * (rng.randf_range(DISTANT_ACCENT_LATERAL_MIN, DISTANT_ACCENT_LATERAL_MAX) + fork_push)
			var accent_roll := rng.randf()
			if accent_roll < 0.52 and not _distant_spaceship_paths.is_empty():
				_spawn_distant_prop(
					accent_d,
					accent_lateral,
					_distant_spaceship_paths,
					rng.randf_range(20.0, 32.0),
					rng,
					"DistantShip"
				)
			elif not _distant_hearth_paths.is_empty():
				_spawn_distant_prop(
					accent_d,
					accent_lateral,
					_distant_hearth_paths,
					rng.randf_range(14.0, 22.0),
					rng,
					"DistantHearth"
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
		d += rng.randf_range(30.0, 46.0)
		slot_i += 1

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
		var asset_path := _distant_tower_paths[rng.randi() % _distant_tower_paths.size()]
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
	if paths.is_empty():
		return
	var asset_path := paths[rng.randi() % paths.size()]
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
	_apply_distant_atmosphere_material(root)

func _update_distant_depth_cues() -> void:
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
		var shade := 1.0
		if delta_d > 50.0:
			shade = clampf(1.0 - (delta_d - 50.0) / 420.0 * 0.14, 0.86, 1.0)
		elif delta_d < 0.0:
			shade = clampf(1.0 + delta_d / 110.0 * 0.1, 0.9, 1.0)
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
		# 保留 GLB 原贴图、自发光与 PBR 参数，仅避免远景被雾吞没。
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
	camera.far = 720.0
	camera.position = Vector3(0, 0.45, 0)
	camera.rotation_degrees = Vector3(-18, 0, 0)
	camera_pivot.add_child(camera)
	_build_player_visual()
	_add_player_light()
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
	return _get_slide_obstacle_scene_by_hint(["坍塌广告牌", "billboard"], 2)

func _get_lane_block_scene() -> PackedScene:
	return _get_slide_obstacle_scene_by_hint(["闪避柱", "全息闪避", "能量裂缝", "crack"], 1)

func _get_slide_obstacle_scene_by_hint(hints: Array, fallback_index: int) -> PackedScene:
	for path in _slide_obstacle_paths:
		var path_text := String(path)
		if path_text.ends_with(".png") or path_text.ends_with(".webp"):
			continue
		for hint in hints:
			if String(hint) in path_text:
				return _load_runner_scene(path_text)
	if not _slide_obstacle_paths.is_empty():
		return _get_slide_obstacle_scene(fallback_index)
	return _slide_obstacle_scene

func _get_jump_obstacle_scene(index: int) -> PackedScene:
	if _jump_obstacle_paths.is_empty():
		return null
	return _load_runner_scene(_jump_obstacle_paths[index % _jump_obstacle_paths.size()])

func _is_energy_orb_asset_path(path: String) -> bool:
	return "energy_orb" in path or path.ends_with(".png") or path.ends_with(".webp")

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

func _pick_jump_bar_scene_index(item: Dictionary) -> int:
	var indices := _jump_bar_path_indices()
	if indices.is_empty():
		return 0
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return indices[(absi(lane * 17 + dist_key)) % indices.size()]

func _pick_energy_orb_scene_index(item: Dictionary) -> int:
	var indices := _energy_orb_path_indices()
	if indices.is_empty():
		return 1
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return indices[(absi(lane * 13 + dist_key)) % indices.size()]

func _pick_slide_obstacle_scene_index(item: Dictionary) -> int:
	if _slide_obstacle_paths.is_empty():
		return 0
	if bool(item.get("low_slide", false)):
		return _slide_path_index_for_hints(["锈蚀水管", "rust", "pipe", "水管"])
	var dist_key := int(float(item.get("distance", 0.0)))
	var lane := int(item.get("lane", 0))
	return (absi(lane * 19 + dist_key)) % _slide_obstacle_paths.size()


func _slide_path_index_for_hints(hints: Array) -> int:
	for i in range(_slide_obstacle_paths.size()):
		var path := String(_slide_obstacle_paths[i]).to_lower()
		for hint in hints:
			var h := String(hint).to_lower()
			if h in path:
				return i
	return 0 if _slide_obstacle_paths.is_empty() else mini(1, _slide_obstacle_paths.size() - 1)

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
	# JSON 可覆盖漂移/浮动速度，制造大小不一、快慢不定
	if item.has("drift_speed"):
		drift_speed = float(item.get("drift_speed", drift_speed))
	if item.has("float_speed"):
		float_speed = float(item.get("float_speed", float_speed))
	if item.has("float_amp"):
		float_amp = float(item.get("float_amp", float_amp))
	var orb_static := bool(item.get("static", false)) or absf(drift_speed) <= 0.001 or tier in ["huge", "colossal"]
	if orb_static:
		drift_speed = 0.0
	var tint := String(item.get("orb_tint", "")).strip_edges().to_lower()
	if tint == "":
		tint = "purple" if bool(item.get("purple", false)) else ""
	return {
		"tier": tier,
		"scale": scale,
		"span": span,
		"drift_speed": drift_speed,
		"float_speed": float_speed,
		"float_amp": float_amp,
		"tint": tint,
		"static": orb_static,
	}

func _orb_size_scale_for(item: Dictionary) -> float:
	return float(_orb_roll(item).get("scale", ORB_SMALL_SCALE))

func _build_train(root: Node3D, moving: bool) -> void:
	# 列车/黄色巨门：广告牌门架看起来能穿，实际用光波刀表达危险窗口
	var visual := _add_height_scaled_model_visual(
		root,
		_get_train_obstacle_scene(),
		"TrainRoadBlockAsset",
		TRAIN_GATE_TOP,
		0.0,
		Vector3.ZERO,
		TRAIN_GATE_BLADE_SPAN,
		LANE_WIDTH * 2.85
	)
	if visual != null:
		_apply_obstacle_runway_contrast(visual)
	if moving and visual != null:
		visual.rotation_degrees.y += 6.0
	root.set_meta("blade_top", TRAIN_GATE_TOP)
	root.set_meta("has_wave_blade", true)
	_add_train_wave_blade(root, TRAIN_GATE_BLADE_SPAN)
	_ensure_train_gate_buff_visual(root)

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
	# 窄实心柱：只占单道中心，留出清晰安全道；跳/铲仍会撞
	var holder := Node3D.new()
	holder.name = "LaneDodgeBarrier_%d" % index
	# 略向封堵侧收拢，不贴进安全道
	var nudge := -0.35 if side == "left" else 0.35
	holder.position = Vector3(lateral_x + nudge, 0.0, -0.22 if index == 0 else 0.22)
	parent.add_child(holder)
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
	for anim_name in [ANIMATED_PLAYER_IDLE_ANIM, ANIMATED_PLAYER_RUN_ANIM]:
		if anim_name == run_anim:
			continue
		if player_animation_player.has_animation(anim_name):
			player_animation_player.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
	if player_animation_player.has_animation(ANIMATED_PLAYER_CELEBRATE_ANIM):
		player_animation_player.get_animation(ANIMATED_PLAYER_CELEBRATE_ANIM).loop_mode = Animation.LOOP_NONE

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
		player_animation_player.play(anim_name, 0.14)

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
	if player_pose_name == pose_name:
		return
	player_pose_name = pose_name

	for model in player_pose_models.values():
		(model as Node3D).visible = false
	player_pose_root = player_pose_models.get(pose_name, player_pose_models.get("idle")) as Node3D
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
	max_scale_cap: float = 12.0
) -> Node3D:
	if not scene:
		return _add_missing_model_visual(parent, model_name, target_height, yaw_degrees, local_position)

	var model := scene.instantiate() as Node3D
	model.name = model_name
	parent.add_child(model)
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees

	var bounds := _compute_node_aabb(model)
	var characteristic := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
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
	var model := Node3D.new()
	model.name = "%sMissingFallback" % model_name
	model.position = local_position
	model.rotation_degrees.y = yaw_degrees
	parent.add_child(model)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.75, max(target_height, 0.25), 0.75)
	mesh.material = _make_material(Color(0.18, 0.32, 0.42), Color(0.25, 0.9, 1.0), 0.8)
	mesh_instance.mesh = mesh
	mesh_instance.position.y = max(target_height, 0.25) * 0.5
	model.add_child(mesh_instance)
	return model

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
	chaser = Node3D.new()
	chaser.name = "NullTideChaser"
	add_child(chaser)

	var shell := MeshInstance3D.new()
	var shell_mesh := BoxMesh.new()
	shell_mesh.size = Vector3(2.6, 2.8, 2.2)
	shell_mesh.material = _make_material(Color(0.12, 0.06, 0.08), Color(0.85, 0.18, 0.12), 0.9)
	shell.mesh = shell_mesh
	shell.position = Vector3(0, 1.4, 0)
	chaser.add_child(shell)
	chaser_body = shell

	var crest := MeshInstance3D.new()
	var crest_mesh := BoxMesh.new()
	crest_mesh.size = Vector3(1.8, 0.35, 1.4)
	crest_mesh.material = _make_material(Color(0.18, 0.08, 0.06), Color(1.0, 0.35, 0.12), 1.6)
	crest.mesh = crest_mesh
	crest.position = Vector3(0, 2.85, 0.1)
	chaser.add_child(crest)

	for x in [-0.55, 0.55]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.22
		eye_mesh.material = _make_material(Color(0.95, 0.22, 0.08), Color(1.0, 0.45, 0.12), 2.8)
		eye.mesh = eye_mesh
		eye.position = Vector3(x, 1.85, 1.15)
		chaser.add_child(eye)
		if x < 0.0:
			chaser_eye_left = eye
		else:
			chaser_eye_right = eye

	for i in 4:
		var spike := MeshInstance3D.new()
		var spike_mesh := BoxMesh.new()
		spike_mesh.size = Vector3(0.12, 0.55, 0.12)
		spike_mesh.material = _make_material(Color(0.15, 0.1, 0.2), Color(0.7, 0.1, 1.0), 1.4)
		spike.mesh = spike_mesh
		spike.position = Vector3(-0.9 + i * 0.6, 3.05, 0.0)
		spike.rotation_degrees = Vector3(0, 0, randf_range(-12, 12))
		chaser.add_child(spike)

	var aura := MeshInstance3D.new()
	var aura_mesh := BoxMesh.new()
	aura_mesh.size = Vector3(3.2, 0.08, 3.2)
	aura_mesh.material = _make_material(Color(0.4, 0.05, 0.6, 0.35), Color(0.9, 0.1, 1.0), 2.2)
	aura.mesh = aura_mesh
	aura.position = Vector3(0, 0.12, 0)
	chaser.add_child(aura)
	chaser.scale = Vector3(0.38, 0.38, 0.38)
	chaser.visible = false

func _update_chaser_visuals(delta: float) -> void:
	if not chaser or not chaser.visible:
		return
	chaser_pulse = maxf(chaser_pulse - delta * 1.8, 0.0)
	var danger := 1.0 - clampf(chaser_distance / CHASER_MAX_DISTANCE, 0.0, 1.0)
	var bob := sin(elapsed * 8.0 + intro_elapsed * 4.0) * 0.08
	chaser_body.position.y = 1.4 + bob + chaser_pulse * 0.35
	var eye_energy := lerpf(1.8, 3.2, danger + chaser_pulse * 0.5)
	for eye in [chaser_eye_left, chaser_eye_right]:
		if not eye:
			continue
		var mat := eye.get_active_material(0) as StandardMaterial3D
		if mat:
			mat.emission_energy_multiplier = eye_energy

func _w1_beat_distance(beat: float) -> float:
	# 128BPM + 55s 线性加速：距离与 never_stop_running 拍点对齐
	var bpm := Global.get_bgm_bpm() if Global.has_method("get_bgm_bpm") else 128.0
	var offset := Global.get_bgm_beat_offset_sec() if Global.has_method("get_bgm_beat_offset_sec") else 0.06
	var t := beat * (60.0 / bpm) + offset
	var run_t := maxf(_run_time, 1.0)
	var v0 := _base_run_speed()
	var v1 := _max_run_speed()
	return v0 * t + 0.5 * (v1 - v0) * t * t / run_t


func _distance_to_w1_beat(dist: float) -> int:
	var best_b := 6
	var best_err := 99999.0
	for b in range(4, 118):
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


func _w1_teaching_coins() -> Array:
	# 主道半拍密币 + 每 8 拍斜梯换道/高低差
	var coins: Array = []
	var obstacle_beats := _w1_obstacle_beats_for_coins(0.42)
	for b in range(4, 108):
		if _w1_beat_blocked_for_coins(b, obstacle_beats, 0.42):
			continue
		var d := _w1_beat_distance(float(b))
		if _is_in_fork_main_gap(d):
			continue
		coins.append(_w1_coin_item(d, 0, false))
		var half_d := _w1_beat_distance(float(b) + 0.5)
		if not _is_in_fork_main_gap(half_d):
			coins.append(_w1_coin_item(half_d, 0, b % 3 == 0, 1 if b % 3 == 0 else 0))
		if b % 8 == 0:
			_w1_append_diagonal_ribbon(coins, float(b), (int(b) / 8) % 2 != 0)
	return coins


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
	# adapt 缩放/加密后可能把下滑门等漂进侧墙走廊，再滤一次
	obstacle_items = _filter_adapted_obstacles_from_wall_corridors(obstacle_items)
	# 关卡 JSON / 自定义关：保留编辑器摆放的全类型障碍；仅 procedural 回落才裁成跳铲球
	if _runner_layout_id() == "" and not CustomLevels.has_level(Global.runner_location_id):
		obstacle_items = _filter_core_obstacle_types(obstacle_items)
	for item in obstacle_items:
		_register_obstacle(item)
	_inject_fast_fork_branch_obstacles()
	obstacles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)
	_obstacle_scan_index = 0

	var coin_index := 0
	var main_coins: Array = []
	if _is_reservoir_w1_mission():
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
			var layer: int = int(item.get("layer", 0))
			var air := bool(item.get("air", false))
			var air_tier := int(item.get("air_tier", 1 if air else 0))
			var y: float = _coin_collectible_y(air, layer, 0, air_tier)
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
	return mt == "emergency"


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


func _register_speed_boost_pickup() -> void:
	_speed_boost_timer = SPEED_BOOST_DURATION
	_speed_boost_cycle += 1
	camera_shake = maxf(camera_shake, 0.08)
	_show_gate_toast("加速靴 · 冲刺!")


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
				node = _make_collectible(lane, dist, y, layer)
			"speed_boost":
				node = _make_speed_boost(lane, dist, y, layer, fork_side)
			"shield_crystal":
				node = _make_shield_crystal(lane, dist, y, layer)
			_:
				node = _make_collectible(lane, dist, y, layer)
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
		if dist < 20.0 or dist > finish_cut:
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
			# 三连币：同距相邻道再补一枚，奖励更密
			if coin_i % 2 == 0:
				var lane2 := int(LANES[(coin_i + 1) % LANES.size()])
				_register_collectible_data(lane2, d + 1.1, y, 0, "coin", false, 1)
			coin_i += 1
			d += 3.0
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
	if _runner_layout_id() != "" or CustomLevels.has_level(Global.runner_location_id):
		items = _default_shield_crystals_from_sandstorms()
	elif LevelConfig != null and LevelConfig.has_method("build_shield_crystals") and not CustomLevels.has_level(Global.runner_location_id):
		items = LevelConfig.build_shield_crystals()
	else:
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
	var out: Array = []
	var zones := _sandstorm_zones()
	if zones.is_empty():
		# 无沙尘暴时仅开局少量试用
		for d in [75.0, 90.0]:
			out.append({"lane": (int(d) % 3) - 1, "distance": d, "layer": 0})
		return out
	for zone in zones:
		var start := float(zone.get("start", 0.0))
		var length := float(zone.get("length", 40.0))
		out.append({"lane": 0, "distance": start - 30.0, "layer": 0})
		out.append({"lane": 0, "distance": start - 14.0, "layer": 0})
		out.append({"lane": 0, "distance": start - 16.0, "layer": 0})
		out.append({"lane": 1, "distance": start - 8.0, "layer": 0})
		out.append({"lane": -1, "distance": start + length * 0.4, "layer": 0})
		out.append({"lane": 0, "distance": start + length + 12.0, "layer": 0})
	out.append({"lane": 0, "distance": 72.0, "layer": 0})
	return out

func _register_obstacle(item: Dictionary) -> Node3D:
	var obstacle_type := String(item["type"])
	var lane: int = int(item.get("lane", 0))
	var dist: float = float(item["distance"])
	var layer: int = int(item.get("layer", 0))
	var node := _make_obstacle(lane, dist, obstacle_type, layer, item)
	var asset_path := String(node.get_meta("obstacle_asset_path", ""))
	var is_float_orb := obstacle_type == "orb" or (node.has_meta("float_orb") and bool(node.get_meta("float_orb")))
	var is_low_slide := obstacle_type in ["slide", "high_bar"] and (
		bool(item.get("low_slide", false)) or bool(node.get_meta("low_slide", false))
	)
	var default_clear := SLIDE_CLEAR_Y if obstacle_type in ["slide", "high_bar"] else GROUND_Y + 0.52
	if is_low_slide:
		default_clear = GROUND_Y + LOW_SLIDE_BEAM_TOP - 0.04
	if layer == WALL_RUN_LAYER:
		if obstacle_type in ["slide", "high_bar"]:
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
	if obstacle_type in ["slide", "high_bar"]:
		entry["open_bottom"] = float(node.get_meta("open_bottom", LOW_SLIDE_OPEN_BOTTOM if is_low_slide else SLIDE_GATE_OPEN_BOTTOM))
		if is_low_slide:
			entry["low_slide"] = true
	if is_float_orb:
		entry["lateral_offset"] = 0.0
		entry["lateral_dir"] = 1.0 if randf() > 0.5 else -1.0
		if item.has("orb_size"):
			entry["orb_size"] = String(item.get("orb_size", ""))
		entry["orb_tier"] = String(node.get_meta("orb_tier", "small"))
		entry["lateral_speed"] = float(node.get_meta("orb_drift_speed", ORB_SMALL_DRIFT_SPEED))
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
	_place_obstacle_node(entry)
	return node

func _make_obstacle(lane: int, distance: float, obstacle_type: String, layer: int, item: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = "%sObstacle" % obstacle_type.capitalize()
	track_root.add_child(root)

	if layer == WALL_RUN_LAYER and obstacle_type in ["jump", "low_barrier", "slide", "high_bar"]:
		_build_wall_face_obstacle(root, item, obstacle_type)
		return root

	match obstacle_type:
		"slide", "high_bar":
			_build_high_bar(root, item)
		"orb":
			_build_energy_orb(root, item)
		"train":
			_build_train(root, false)
		"train_moving":
			_build_train(root, true)
		"block_left":
			_build_lane_block(root, "left")
		"block_right":
			_build_lane_block(root, "right")
		"main_block":
			_build_main_block(root, float(item.get("half_depth", 8.0)))
		"ramp":
			_build_ramp(root, int(item.get("target_layer", layer + 1)))
		"turn_left", "turn_right":
			_build_turn_sign(root, obstacle_type)
		"meteorite":
			_build_runway_meteorite(root, item)
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
		# 悬梁：挡中高列，下滑到低列或高跳越过
		box.size = Vector3(0.55, 1.65, 2.8)
	else:
		# 低栏：贴低列，中列需跳过
		box.size = Vector3(0.5, 0.9, 2.6)
	bar.mesh = box
	var mat := StandardMaterial3D.new()
	if is_slide:
		mat.albedo_color = Color(0.15, 0.55, 0.95, 0.92)
		mat.emission = Color(0.2, 0.75, 1.0)
	else:
		mat.albedo_color = Color(0.95, 0.45, 0.12, 0.95)
		mat.emission = Color(1.0, 0.4, 0.08)
	mat.emission_enabled = true
	mat.emission_energy_multiplier = 1.8
	mat.metallic = 0.35
	mat.roughness = 0.35
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bar.material_override = mat
	bar.position = Vector3(0.0, box.size.y * 0.5, 0.0)
	root.add_child(bar)
	var rim := MeshInstance3D.new()
	rim.name = "WallFaceObstacleRim"
	var rim_box := BoxMesh.new()
	rim_box.size = box.size + Vector3(0.08, 0.08, 0.08)
	rim.mesh = rim_box
	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.18)
	rim_mat.emission_enabled = true
	rim_mat.emission = mat.emission
	rim_mat.emission_energy_multiplier = 0.7
	rim_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rim.material_override = rim_mat
	rim.position = bar.position
	root.add_child(rim)
	var tip := Label3D.new()
	tip.text = "滑到低列 / 跳过" if is_slide else "跳跃越过"
	tip.font_size = 42
	tip.modulate = Color(0.75, 1.0, 0.95) if is_slide else Color(1.0, 0.75, 0.35)
	tip.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tip.position = Vector3(0.0, box.size.y + 0.55, 0.0)
	root.add_child(tip)


func _build_jump_bar(root: Node3D, item: Dictionary = {}) -> void:
	var scene_index := _pick_jump_bar_scene_index(item)
	var asset_path := ""
	if scene_index < _jump_obstacle_paths.size():
		asset_path = _jump_obstacle_paths[scene_index]
		root.set_meta("obstacle_asset_path", asset_path)
	# 跳跃障横跨整条跑道（与碰撞提示一致：需跳过，不可靠换道躲开视觉）
	var span := _runway_obstacle_span_at(float(item.get("distance", 0.0)))
	root.set_meta("obstacle_span", span)
	_add_jump_bar_visual(root, _get_jump_obstacle_scene(scene_index), JUMP_BAR_HEIGHT, span)
	var jump_model := root.get_node_or_null("JumpObstacleModel") as Node3D
	if jump_model:
		if "全息" in asset_path:
			_apply_obstacle_hologram_material(
				jump_model,
				Color(0.2, 0.98, 0.78),
				Color(0.08, 0.88, 0.55),
				1.05
			)
		else:
			_apply_obstacle_runway_contrast(jump_model)
	_add_ground_contact_shadow(root, span * 0.82, 0.75)

func _build_runway_meteorite(root: Node3D, item: Dictionary = {}) -> void:
	# 终点前占道陨石：正圆球体贴地占道，须换道或高跳；尺寸可大可小
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(int(float(item.get("distance", 0.0)) * 17.0) + int(item.get("lane", 0)) * 31)
	var default_span := LANE_WIDTH * rng.randf_range(0.75, 1.75)
	var diameter := clampf(float(item.get("span", default_span)), LANE_WIDTH * 0.65, LANE_WIDTH * 2.05)
	var radius := diameter * 0.5
	var palette := _pick_meteorite_palette(rng, float(item.get("distance", 0.0)), float(item.get("lane", 0)) * LANE_WIDTH)
	var visual := Node3D.new()
	visual.name = "MeteoriteObstacleModel"
	root.add_child(visual)
	var body := MeshInstance3D.new()
	body.name = "MeteoriteSphere"
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = diameter
	# 落陨石用极简网格 + 无光照材质，末段同屏多颗时更稳帧
	var fall_roll := bool(item.get("fall_roll", false))
	sphere.radial_segments = 6 if fall_roll else 20
	sphere.rings = 3 if fall_roll else 10
	body.mesh = sphere
	var mat := StandardMaterial3D.new()
	var albedo: Color = palette.get("albedo", Color(0.55, 0.42, 0.38))
	var emission: Color = palette.get("emission", Color(0.95, 0.45, 0.12))
	if fall_roll:
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = Color(
			clampf(albedo.r * 0.45 + emission.r * 0.55, 0.0, 1.0),
			clampf(albedo.g * 0.4 + emission.g * 0.35, 0.0, 1.0),
			clampf(albedo.b * 0.35 + emission.b * 0.2, 0.0, 1.0)
		)
		mat.emission_enabled = false
	else:
		mat.albedo_color = Color(albedo.r * 0.55, albedo.g * 0.48, albedo.b * 0.42)
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = maxf(float(palette.get("emission_energy", 0.9)) * 2.4, 1.8)
		mat.roughness = 0.72
		mat.metallic = 0.08
	body.material_override = mat
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.position.y = radius
	visual.add_child(body)
	visual.rotation_degrees.y = rng.randf_range(0.0, 360.0)
	root.set_meta("obstacle_asset_path", "sphere_meteorite")
	root.set_meta("meteorite_radius", radius)
	root.set_meta("meteorite_hit_half_width", clampf(radius * 0.92, LANE_WIDTH * 0.32, LANE_WIDTH * 0.95))
	root.set_meta("meteorite_half_depth", clampf(radius * 0.92, 0.55, LANE_WIDTH * 0.95))
	root.set_meta("meteorite_clear_height", GROUND_Y + diameter * 0.9)
	if not fall_roll:
		_add_ground_contact_shadow(root, diameter * 0.95, 1.15)

func _build_energy_orb(root: Node3D, item: Dictionary = {}) -> void:
	var scene_index := _pick_energy_orb_scene_index(item)
	var asset_path := ""
	if scene_index < _jump_obstacle_paths.size():
		asset_path = _jump_obstacle_paths[scene_index]
		root.set_meta("obstacle_asset_path", asset_path)
	root.set_meta("float_orb", true)
	var roll := _orb_roll(item)
	var tier := String(roll.get("tier", "small"))
	var size_scale := float(roll.get("scale", ORB_SMALL_SCALE))
	var target_span := float(roll.get("span", ORB_SMALL_SPAN))
	root.set_meta("orb_tier", tier)
	root.set_meta("orb_size_scale", size_scale)
	root.set_meta("orb_drift_speed", float(roll.get("drift_speed", ORB_SMALL_DRIFT_SPEED)))
	root.set_meta("orb_float_speed", float(roll.get("float_speed", ORB_SMALL_FLOAT_SPEED)))
	root.set_meta("orb_float_amp", float(roll.get("float_amp", ORB_SMALL_FLOAT_AMP)))
	root.set_meta("orb_tint", String(roll.get("tint", "")))
	root.set_meta("orb_static", bool(roll.get("static", false)))
	var scene := _get_jump_obstacle_scene(scene_index)
	var visual: Node3D
	if scene:
		visual = scene.instantiate() as Node3D
		visual.name = "JumpObstacleModel"
		root.add_child(visual)
		_fit_energy_orb_to_span(visual, target_span)
		_apply_orb_tier_visual(visual, tier, String(roll.get("tint", "")))
	else:
		visual = _add_missing_model_visual(root, "JumpObstacleModel", target_span, 0.0, Vector3.ZERO)
		_fit_energy_orb_to_span(visual, target_span)
		_apply_orb_tier_visual(visual, tier, String(roll.get("tint", "")))
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

func _apply_orb_tier_visual(model: Node3D, tier: String, tint: String = "") -> void:
	var is_large := tier in ["large", "huge", "colossal"]
	var is_purple := tint == "purple"
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
			if is_purple:
				# 紫球要明显自发光：贴图当 emission，避免沙漠里发灰发暗
				dup.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				dup.alpha_scissor_threshold = 0.08
				dup.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				dup.albedo_color = Color(1.0, 0.82, 1.0, 1.0)
				dup.emission_enabled = true
				dup.emission = Color(0.98, 0.55, 1.0)
				if dup.albedo_texture != null:
					dup.emission_texture = dup.albedo_texture
				var purple_e := 4.8
				if tier == "huge":
					purple_e = 8.5
				elif tier == "colossal":
					purple_e = 11.0
				elif is_large:
					purple_e = 6.5
				dup.emission_energy_multiplier = purple_e
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
	# 2.5D 精灵：亮透淡紫
	for node in model.find_children("*", "Sprite3D", true, false):
		var spr := node as Sprite3D
		if is_purple:
			spr.modulate = Color(1.0, 0.78, 1.0, 1.0)
			spr.transparent = true

func _add_jump_bar_visual(root: Node3D, scene: PackedScene, target_height: float, target_span: float) -> void:
	if scene == null:
		_add_missing_model_visual(root, "JumpObstacleModel", target_height, 0.0, Vector3.ZERO)
		return
	var model := scene.instantiate() as Node3D
	model.name = "JumpObstacleModel"
	root.add_child(model)
	model.position = Vector3.ZERO
	model.rotation_degrees = Vector3.ZERO

	var bounds0 := _compute_node_aabb(model)
	if bounds0.size.y <= 0.001:
		push_warning("JumpObstacleModel bounds invalid")
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
	_add_ground_contact_shadow(root, target_span * 0.92, 0.9)

func _build_high_bar(root: Node3D, item: Dictionary = {}) -> void:
	if bool(item.get("low_slide", false)):
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
	if scene != null:
		_add_road_span_gate(root, "SlideObstacleModel", scene, SLIDE_GATE_TOP, span)
	else:
		_add_slide_gate_visual(root, span, SLIDE_GATE_TOP, SLIDE_GATE_OPEN_BOTTOM)


func _build_low_slide_barrier(root: Node3D, item: Dictionary = {}) -> void:
	# 低杆：全宽金属横杆，必须滑铲通过
	root.set_meta("low_slide", true)
	root.set_meta("open_bottom", LOW_SLIDE_OPEN_BOTTOM)
	root.set_meta("obstacle_asset_path", "low_slide_beam")
	var span := _runway_obstacle_span_at(float(item.get("distance", 0.0)))
	root.set_meta("obstacle_span", span)
	_add_low_slide_beam_visual(root, span, LOW_SLIDE_BEAM_TOP - 0.22)
	_add_ground_contact_shadow(root, span * 0.96, 0.48)


func _add_low_slide_beam_visual(root: Node3D, span: float, beam_center_y: float) -> Node3D:
	var gate_root := Node3D.new()
	gate_root.name = "SlideObstacleModel"
	root.add_child(gate_root)
	var half := span * 0.5
	var pylon_mat := _make_material(Color(0.40, 0.44, 0.50), Color(0.48, 0.68, 0.92), 0.58)
	for side in [-1, 1]:
		var pylon := MeshInstance3D.new()
		pylon.name = "LowSlidePylon_%d" % side
		var pylon_mesh := BoxMesh.new()
		pylon_mesh.size = Vector3(0.56, maxf(beam_center_y - 0.04, 0.55), 0.56)
		pylon_mesh.material = pylon_mat
		pylon.mesh = pylon_mesh
		pylon.position = Vector3(side * half * 0.985, pylon_mesh.size.y * 0.5 - 0.02, 0.0)
		pylon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gate_root.add_child(pylon)
	var beam := MeshInstance3D.new()
	beam.name = "LowSlideBeam"
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(span * 1.02, 0.46, 0.76)
	var beam_mat := StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.56, 0.60, 0.66)
	beam_mat.metallic = 0.84
	beam_mat.roughness = 0.26
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.32, 0.52, 0.86)
	beam_mat.emission_energy_multiplier = 0.20
	beam_mesh.material = beam_mat
	beam.mesh = beam_mesh
	beam.position = Vector3(0.0, beam_center_y, 0.0)
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gate_root.add_child(beam)
	var cap_mat := _make_material(Color(0.92, 0.70, 0.16), Color(1.0, 0.82, 0.28), 1.05)
	for side in [-1, 1]:
		var cap := MeshInstance3D.new()
		cap.name = "LowSlideCap_%d" % side
		var cap_mesh := BoxMesh.new()
		cap_mesh.size = Vector3(0.78, 0.46, 0.78)
		cap_mesh.material = cap_mat
		cap.mesh = cap_mesh
		cap.position = Vector3(side * half * 0.965, beam_center_y, 0.0)
		cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gate_root.add_child(cap)
	return gate_root


func _add_slide_gate_visual(root: Node3D, span: float, top_height: float, open_bottom: float) -> Node3D:
	var gate_root := Node3D.new()
	gate_root.name = "SlideObstacleModel"
	root.add_child(gate_root)

	var half_span := span * 0.5
	var pillar_h := maxf(top_height - open_bottom, 0.45)
	var pillar_center_y := open_bottom + pillar_h * 0.5
	var pillar_mat := _make_material(Color(0.28, 0.62, 0.98), Color(0.14, 0.38, 0.88), 1.05)

	for side in [-1, 1]:
		var pillar := MeshInstance3D.new()
		pillar.name = "SlidePillar_%d" % side
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.34, pillar_h, 0.36)
		mesh.material = pillar_mat
		pillar.mesh = mesh
		pillar.position = Vector3(side * half_span, pillar_center_y, 0.0)
		gate_root.add_child(pillar)

	var beam := MeshInstance3D.new()
	beam.name = "SlideTopBeam"
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(span * 0.98, 0.26, 0.4)
	beam_mesh.material = pillar_mat
	beam.mesh = beam_mesh
	beam.position = Vector3(0.0, top_height - 0.13, 0.0)
	gate_root.add_child(beam)

	var holo := MeshInstance3D.new()
	holo.name = "SlideHoloPanel"
	var holo_mesh := BoxMesh.new()
	holo_mesh.size = Vector3(span * 0.94, maxf(top_height - open_bottom, 0.35), 0.06)
	var holo_mat := _make_material(Color(0.22, 0.55, 0.95, 0.62), Color(0.18, 0.62, 1.0), 1.05)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	holo_mesh.material = holo_mat
	holo.mesh = holo_mesh
	holo.position = Vector3(0.0, open_bottom + (top_height - open_bottom) * 0.5, 0.0)
	gate_root.add_child(holo)

	_add_ground_contact_shadow(root, span * 0.92, 1.0)
	return gate_root

func _add_slide_visibility_curtain(root: Node3D) -> void:
	var curtain := MeshInstance3D.new()
	curtain.name = "SlideVisibilityCurtain"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(LANE_WIDTH * 3.15, 2.55, 0.22)
	var mat := _make_material(Color(0.22, 0.55, 0.95, 0.32), Color(0.18, 0.62, 1.0), 1.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = mat
	curtain.mesh = mesh
	curtain.position = Vector3(0.0, SLIDE_GATE_HEIGHT * 0.78, 0.0)
	root.add_child(curtain)

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
	var visual := _add_scaled_model_visual(
		root,
		_get_jump_obstacle_scene(1),
		"RampMarkerAsset",
		1.2,
		180.0,
		Vector3(0.0, 0.0, 0.0)
	)
	visual.rotation_degrees.x = -12.0

func _build_main_block(root: Node3D, half_depth: float = 8.0) -> void:
	# 只做入口警示门；长坍塌带由沿路径的挖坑条带展示，避免弯道上长方体斜出跑道
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

	var label := Label3D.new()
	label.text = "主路坍塌"
	label.font_size = 56
	label.modulate = Color(1.0, 0.55, 0.25)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0.0, 3.0, 0.0)
	root.add_child(label)
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

func _make_collectible(lane: int, distance: float, y: float, layer: int) -> Node3D:
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
	glow_mat.albedo_color = Color(1.0, 0.82, 0.22, 0.22)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1.0, 0.72, 0.12)
	glow_mat.emission_energy_multiplier = 1.8
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
	else:
		placed = _world_on_path(distance, float(lane) * LANE_WIDTH, y, layer)
	collectible.position = placed["pos"]
	collectible.rotation.y = float(placed["yaw"])
	return collectible


func _make_coin_face_material(w1_rich: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.98, 0.78, 0.16) if w1_rich else Color(0.96, 0.74, 0.14)
	mat.metallic = 1.0
	mat.roughness = 0.14 if w1_rich else 0.2
	mat.metallic_specular = 1.0 if w1_rich else 0.92
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.62, 0.05)
	mat.emission_energy_multiplier = 0.22 if w1_rich else 0.12
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.72 if w1_rich else 0.55
	mat.clearcoat_roughness = 0.06
	mat.rim_enabled = w1_rich
	mat.rim = 0.85 if w1_rich else 0.0
	mat.rim_tint = 0.35
	return mat


func _make_coin_rim_material(w1_rich: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.82, 0.54, 0.04) if w1_rich else Color(0.78, 0.52, 0.06)
	mat.metallic = 1.0
	mat.roughness = 0.18 if w1_rich else 0.28
	mat.metallic_specular = 0.92
	mat.emission_enabled = true
	mat.emission = Color(0.98, 0.48, 0.03)
	mat.emission_energy_multiplier = 0.16 if w1_rich else 0.08
	return mat


func _make_coin_emboss_material(w1_rich: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.92, 0.38) if w1_rich else Color(1.0, 0.88, 0.32)
	mat.metallic = 0.98
	mat.roughness = 0.12
	mat.metallic_specular = 1.0
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.78, 0.18)
	mat.emission_energy_multiplier = 0.18 if w1_rich else 0.1
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
	chaser_hint_wrap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	chaser_hint_wrap.offset_left = -156.0
	chaser_hint_wrap.offset_top = 204.0
	chaser_hint_wrap.offset_right = -28.0
	chaser_hint_wrap.offset_bottom = 320.0
	chaser_hint_wrap.visible = _chaser_enabled
	shell.add_child(chaser_hint_wrap)

	chaser_hint_panel = PanelContainer.new()
	chaser_hint_panel.custom_minimum_size = Vector2(112, 88)
	chaser_hint_wrap.add_child(chaser_hint_panel)

	var hint_box := VBoxContainer.new()
	hint_box.alignment = BoxContainer.ALIGNMENT_CENTER
	chaser_hint_panel.add_child(hint_box)

	chaser_hint_label = Label.new()
	chaser_hint_label.text = LevelConfig.CHASER_NAME
	chaser_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chaser_hint_label.add_theme_font_size_override("font_size", 20)
	hint_box.add_child(chaser_hint_label)

	var hint_dist := Label.new()
	hint_dist.name = "ChaserHintDistance"
	hint_dist.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_dist.add_theme_font_size_override("font_size", 16)
	hint_box.add_child(hint_dist)

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
	state_body.add_theme_color_override("font_color", Color("#FFF0D8"))
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
	_apply_settlement_button_style(state_restart_button, Color("#2A1C10", 0.96), Color("#E8A840", 0.82))
	_state_button_row.add_child(state_restart_button)

	state_back_button = Button.new()
	state_back_button.text = "BACK TO MAP"
	state_back_button.custom_minimum_size = Vector2(0, 60)
	state_back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_back_button.add_theme_font_size_override("font_size", 24)
	state_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
	state_back_button.mouse_filter = Control.MOUSE_FILTER_STOP
	state_back_button.pressed.connect(_on_state_back_pressed)
	_apply_settlement_button_style(state_back_button, Color("#2A1C10", 0.96), Color("#E8A840", 0.82))
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
	_top_hud_wrap.offset_top = 10.0
	_top_hud_wrap.offset_right = -14.0
	var panel_h := _top_status_panel_height()
	_top_hud_wrap.offset_bottom = 10.0 + panel_h
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

	if _is_emergency_run:
		_run_timer_label = Label.new()
		_run_timer_label.visible = false
		_style_buff_label(_run_timer_label, 34, Color(1.0, 0.82, 0.42), 4)
		root.add_child(_run_timer_label)

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

	if not _is_emergency_run:
		return

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 1)
	divider.color = Color(0.45, 0.72, 0.88, 0.28)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(divider)

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
	boost_title.text = "加速包"
	_style_buff_label(boost_title, 22, Color(0.95, 0.98, 1.0))
	boost_head.add_child(boost_title)

	_boost_count_label = Label.new()
	_boost_count_label.text = "0/5"
	_style_buff_label(_boost_count_label, 24, Color(0.55, 0.95, 1.0))
	boost_head.add_child(_boost_count_label)

	_boost_status_label = Label.new()
	_boost_status_label.text = "集满 5 个解锁冲刺"
	_boost_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_boost_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_style_buff_label(_boost_status_label, 16, Color(0.68, 0.78, 0.88), 2)
	boost_head.add_child(_boost_status_label)

	var pip_row := HBoxContainer.new()
	pip_row.add_theme_constant_override("separation", 6)
	pip_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boost_body.add_child(pip_row)

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
	_buff_boost_row.add_child(_boost_dash_icon_wrap)

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
	if danger_ratio > 0.72:
		chase_status = "极危"
	elif danger_ratio > 0.45:
		chase_status = "危险"
	elif danger_ratio > 0.22:
		chase_status = "逼近"
	chase_label.text = "%s %0.1fm [%s]" % [LevelConfig.CHASER_NAME, chaser_distance, chase_status]
	chase_bar.value = chaser_distance
	if danger_ratio > 0.72:
		chase_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.2))
	elif danger_ratio > 0.45:
		chase_label.add_theme_color_override("font_color", Color(1.0, 0.65, 0.15))
	else:
		chase_label.add_theme_color_override("font_color", Color(0.55, 0.95, 0.75))

	if chaser_hint_panel:
		var hint_alpha := clampf(danger_ratio * 0.85 + 0.15, 0.15, 1.0)
		chaser_hint_panel.modulate = Color(1.0, 0.55 + danger_ratio * 0.25, 0.25, hint_alpha)
		chaser_hint_label.text = "%s\n%0.0fm" % [LevelConfig.CHASER_NAME, chaser_distance] if danger_ratio > 0.15 else "零潮\n安全"
	if danger_vignette:
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
	if intro_panel != null:
		intro_panel.visible = intro_panel.visible and not active
	if player != null and is_instance_valid(player):
		player.visible = not active
	if _finish_portal_root != null and is_instance_valid(_finish_portal_root):
		_finish_portal_root.visible = not active
	if _finish_outpost_title_rig != null and is_instance_valid(_finish_outpost_title_rig):
		_finish_outpost_title_rig.visible = not active
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
			settle_style.bg_color = Color("#221810", 0.88)
			settle_style.border_color = Color("#E8A840", 0.72)
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
			_apply_settlement_button_style(state_restart_button, Color("#2A1C10", 0.96), Color("#E8A840", 0.82))
		if state_back_button != null:
			state_back_button.custom_minimum_size = Vector2(0, maxf(58.0, h * 0.062))
			state_back_button.add_theme_font_size_override("font_size", int(maxf(22.0, h * 0.024)))
			state_back_button.mouse_filter = Control.MOUSE_FILTER_STOP
			state_back_button.process_mode = Node.PROCESS_MODE_ALWAYS
			state_back_button.disabled = false
			state_back_button.z_index = 210
			_apply_settlement_button_style(state_back_button, Color("#2A1C10", 0.96), Color("#E8A840", 0.82))
		if state_body != null:
			state_body.add_theme_font_size_override("font_size", int(maxf(24.0, h * 0.026)))
			state_body.add_theme_color_override("font_color", Color("#FFF0D8"))
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
	# 腿速封顶：爽感靠镜头/尾迹/前倾，不把跑步动画快进成动画片
	var ratio := _visual_speed_ratio()
	var mapped := lerpf(0.96, 1.18, clampf((ratio - 1.0) / 0.95, 0.0, 1.0))
	if _is_fork_rushing() or _finish_sprint_timer > 0.0 or _speed_boost_timer > 0.0:
		mapped = minf(mapped + 0.05, 1.24)
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
	_speed_rumble = lerpf(_speed_rumble, speed_feel * 0.012, 0.08)
	var shake_offset := Vector3.ZERO
	if camera_shake > 0.0:
		shake_offset = Vector3(randf_range(-0.022, 0.022), randf_range(-0.016, 0.016), 0.0) * (camera_shake / 0.16)
		camera_shake = maxf(camera_shake - get_process_delta_time(), 0.0)
	if _speed_rumble > 0.004 and not is_intro and not _is_sliding():
		shake_offset += Vector3(
			randf_range(-1.0, 1.0) * _speed_rumble,
			randf_range(-0.7, 0.7) * _speed_rumble,
			0.0
		)

	var cam_behind := CAMERA_BEHIND
	if is_intro:
		cam_behind = lerpf(CAMERA_BEHIND + 1.2, CAMERA_BEHIND, clampf(intro_elapsed / INTRO_DURATION, 0.0, 1.0))
	else:
		cam_behind = lerpf(CAMERA_BEHIND, CAMERA_BEHIND + 0.55, speed_feel)

	if _is_wall_running():
		var zone := _side_runway_zone_at(track_distance)
		var side := _wall_zone_side(zone)
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

	camera_pivot.position = Vector3(
		shake_offset.x,
		CAMERA_HEIGHT + slide_offset,
		cam_behind + slide_pullback
	) + shake_offset * 0.35
	camera.position = Vector3(0, 0.45, 0.0)

	# 沿真实路径（含岔路横向偏移）取前瞻点，避免瞬时切线直线瞄出路面
	var look_ahead := CAMERA_LOOK_AHEAD
	if not _fork_zone_at(track_distance).is_empty():
		look_ahead = minf(CAMERA_LOOK_AHEAD, 12.0)
	if is_intro:
		look_ahead *= 0.35
	if _finish_sprint_timer > 0.0:
		look_ahead += 5.0
		cam_behind += 0.35
	var ahead := _world_on_path(track_distance + look_ahead, current_lateral, GROUND_Y)
	var mid := _world_on_path(track_distance + look_ahead * 0.45, current_lateral, GROUND_Y)
	# 近点 + 远点混合，岔路弯道更跟路面
	var look_target: Vector3 = (ahead["pos"] as Vector3).lerp(mid["pos"] as Vector3, 0.35) + Vector3(0.0, 1.25, 0.0)
	if camera.global_position.distance_squared_to(look_target) > 0.04:
		camera.look_at(look_target, Vector3.UP)

	var target_fov := clampf(CAMERA_FOV + danger_ratio * 2.0, CAMERA_FOV, 68.0)
	if _finish_sprint_timer > 0.0:
		target_fov = 74.0
	camera.fov = lerpf(camera.fov, target_fov, 0.12)

func _update_runner_feedback(delta: float) -> void:
	if _is_sliding():
		_set_player_pose("slide")
	elif vertical_velocity > 2.4:
		_set_player_pose("jump_start")
	elif not _is_on_ground():
		_set_player_pose("jump_peak")
	elif body_squash_timer > 0.0:
		_set_player_pose("landing")
	else:
		if _uses_skeletal_run():
			_set_player_pose("run")
		else:
			var run_step := int(floor(elapsed * 8.0)) % 2
			_set_player_pose("run_left" if run_step == 0 else "run_right")

	if _uses_skeletal_run() and player_pose_root and player_animation_player and player_pose_name == "run":
		var target_speed := _run_anim_speed_for_feel()
		_run_anim_speed_smooth = lerpf(_run_anim_speed_smooth, target_speed, 1.0 - exp(-8.0 * delta))
		player_animation_player.speed_scale = _run_anim_speed_smooth
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
	# 高速前倾：适度压低，避免角色俯身过深像「缩小/消失」
	var pitch_target := -deg_to_rad(2.0 + speed_feel * 4.0 + _speed_feel_punch * 1.8)
	if _is_sliding() or not _is_on_ground():
		pitch_target = 0.0
	_run_body_pitch = lerpf(_run_body_pitch, pitch_target, 1.0 - exp(-8.0 * delta))
	if player_body:
		if _is_wall_running():
			_apply_wall_run_body_orientation(_wall_zone_side(_side_runway_zone_at(track_distance)))
		else:
			player_body.rotation.z = lerpf(player_body.rotation.z, body_tilt, 1.0 - exp(-9.0 * delta))
			# pitch 由 _sync_player_position 合并 _run_body_pitch，避免互相覆盖

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

	var boosting := _speed_boost_timer > 0.0 or _is_fork_rushing() or _finish_sprint_timer > 0.0 or _emergency_dash_timer > 0.0
	if _ember_fx_root:
		# 脚下火环 + 周身蝴蝶光晕：全程保持，避免中后段角色“裸奔”
		var ember_on := not is_finished and not is_failed and (gameplay_active or is_intro)
		_ember_fx_root.visible = ember_on
		if ember_on:
			_update_ember_flame_aura(delta)

	if foot_spark_particles:
		# 火焰光圈附近的少量火星点缀 · 随 BGM 拍点闪烁
		var spark_on := not is_finished and not is_failed and (gameplay_active or is_intro)
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
			foot_spark_particles.amount_ratio = clampf((0.16 if sliding else (0.20 if air else 0.24)) + beat * 0.06, 0.12, 0.38)
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
		var bob := sin(pulse_t + phase) * (0.06 if bool(collectible.get("air", false)) else 0.035)
		var base_y := float(collectible.get("y", node.position.y))
		node.position.y = base_y + bob


func _is_overweight_cargo() -> bool:
	return MissionTypes.is_overweight_cargo(mission)


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
	body_squash_timer = 0.14
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
	body_squash_timer = 0.16
	camera_shake = maxf(camera_shake, 0.12)
	_jump_fx_timer = 0.45
	_emit_landing_particles()
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
	if overlay.has("panorama_energy") and env.sky != null:
		var sky_mat := env.sky.sky_material
		if sky_mat is PanoramaSkyMaterial:
			(sky_mat as PanoramaSkyMaterial).energy_multiplier = float(overlay["panorama_energy"])
	if overlay.has("sky_rotation_y"):
		env.sky_rotation = Vector3(0.0, float(overlay["sky_rotation_y"]), 0.0)


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
	var pos: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral
	pos.y = GROUND_Y + (0.22 if emphasis else 0.12)
	root.position = pos
	root.rotation.y = float(sample["yaw"])
	var mat := _make_material(Color(1.0, 0.78, 0.12, 0.95), Color(1.0, 0.88, 0.25), 2.6 if emphasis else 1.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# 扁平箭头：尖端指向侧墙（右/左）
	var tip := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(1.55 if emphasis else 1.2, 0.14, 1.85 if emphasis else 1.45)
	prism.material = mat
	tip.mesh = prism
	# 放平后绕 Y，使尖端朝向侧墙
	tip.rotation_degrees = Vector3(90.0, 90.0 if wall_side > 0.0 else -90.0, 0.0)
	tip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(tip)
	# 箭身：短横条，强化方向可读
	var shaft := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.85 if emphasis else 0.65, 0.08, 0.32)
	shaft.mesh = box
	shaft.material_override = mat
	shaft.position = Vector3((-0.55 if wall_side > 0.0 else 0.55), 0.02, 0.0)
	shaft.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(shaft)
	return root


func _shield_crystal_allowed_at(distance: float) -> bool:
	# 无沙暴的后半段不再投放防护水晶（改用紫球障碍占道）
	var zones := _sandstorm_zones()
	if zones.is_empty():
		return distance < minf(140.0, _track_length * 0.25)
	for zone in zones:
		var start := float(zone.get("start", 0.0))
		var end := start + float(zone.get("length", 40.0))
		if distance >= start - 22.0 and distance <= end + 16.0:
			return true
	# 开局试用窗
	return distance <= 100.0


func _add_train_wave_blade(root: Node3D, span: float) -> MeshInstance3D:
	var existing := root.get_node_or_null("TrainWaveBlade") as MeshInstance3D
	if existing != null:
		return existing
	var top_y := float(root.get_meta("blade_top", TRAIN_GATE_TOP))
	var blade := MeshInstance3D.new()
	blade.name = "TrainWaveBlade"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(span * 0.92, 0.28, 0.22)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(1.0, 0.82, 0.35, 0.95)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.72, 0.2)
	mat.emission_energy_multiplier = 5.2
	mesh.material = mat
	blade.mesh = mesh
	blade.position = Vector3(0.0, top_y - 0.2, 0.14)
	blade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(blade)
	var trail := MeshInstance3D.new()
	trail.name = "TrainWaveBladeTrail"
	var trail_mesh := BoxMesh.new()
	trail_mesh.size = Vector3(span * 0.86, 1.6, 0.06)
	var trail_mat := StandardMaterial3D.new()
	trail_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	trail_mat.albedo_color = Color(1.0, 0.55, 0.25, 0.28)
	trail_mat.emission_enabled = true
	trail_mat.emission = Color(1.0, 0.45, 0.12)
	trail_mat.emission_energy_multiplier = 2.6
	trail_mesh.material = trail_mat
	trail.mesh = trail_mesh
	trail.position = Vector3(0.0, top_y - 1.0, 0.1)
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(trail)
	return blade


func _update_train_blade_gates() -> void:
	var near_lo := track_distance - 8.0
	var near_hi := track_distance + 70.0
	for obstacle in obstacles:
		var otype := String(obstacle.get("type", ""))
		if otype not in ["train", "train_moving"]:
			continue
		var dist := float(obstacle.get("distance", 0.0)) + float(obstacle.get("move_offset", 0.0))
		if dist < near_lo or dist > near_hi:
			continue
		var node := obstacle.get("node") as Node3D
		if node == null or not is_instance_valid(node):
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
			trail.scale = Vector3(1.0, th / 1.6, 1.0)


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
			if air_y <= 0.05:
				obstacle["meteor_air_y"] = 0.0
				obstacle["y_offset"] = 0.0
				obstacle["meteor_state"] = "rolling"
				obstacle["moving"] = true
				# 朝玩家滚来（负向偏移）
				if absf(float(obstacle.get("move_speed", 0.0))) < 0.01:
					obstacle["move_speed"] = float(obstacle.get("roll_speed", -5.5))
				camera_shake = maxf(camera_shake, 0.16)
		elif state == "rolling":
			obstacle["y_offset"] = 0.0
			obstacle["meteor_air_y"] = 0.0
			var rolled := float(obstacle.get("meteor_roll_dist", 0.0)) + absf(float(obstacle.get("move_speed", -5.5))) * delta
			obstacle["meteor_roll_dist"] = rolled
			var visual := node.get_node_or_null("MeteoriteObstacleModel") as Node3D
			if visual != null:
				var radius := float(obstacle.get("meteor_radius", 1.0))
				visual.rotation.x = -rolled / maxf(radius, 0.35)
		else:
			# 仍在高空待命
			obstacle["y_offset"] = air_y
		_place_obstacle_node(obstacle, true)


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
		return
	if _top_hud_wrap != null:
		_top_hud_wrap.visible = true

	if _run_timer_label != null:
		if _is_emergency_run and gameplay_active and not is_finished and not is_failed:
			var remain := maxf(_run_time - elapsed, 0.0)
			_run_timer_label.visible = true
			_run_timer_label.text = "限时 %0.1fs" % remain
			var urgent := remain <= 10.0
			_style_buff_label(
				_run_timer_label,
				36 if urgent else 34,
				Color(1.0, 0.42, 0.32) if urgent else Color(1.0, 0.82, 0.42),
				4
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
		elif _is_shield_protecting():
			_style_buff_label(_shield_energy_label, 20, Color(0.45, 0.98, 1.0))
		else:
			_style_buff_label(_shield_energy_label, 20, Color(0.55, 0.95, 1.0))
	if shield_bar:
		shield_bar.value = shield_energy
		var fill_color := Color(0.35, 0.88, 1.0)
		if shield_energy <= 0.001:
			fill_color = Color(0.72, 0.28, 0.24)
		elif _is_shield_protecting():
			fill_color = Color(0.42, 0.96, 1.0)
		shield_bar.add_theme_stylebox_override("fill", _make_buff_bar_style(fill_color, fill_color))

	if not _is_emergency_run or _buff_boost_row == null:
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


func _update_midground_visibility() -> void:
	if _side_dressing_root == null:
		return
	_midground_vis_tick += 1
	if _midground_vis_tick < 4:
		return
	_midground_vis_tick = 0
	for child in _side_dressing_root.get_children():
		if not child is Node3D:
			continue
		var node := child as Node3D
		var anchor_d := float(node.get_meta("path_distance", -1.0))
		if anchor_d < 0.0:
			continue
		var delta_d := anchor_d - track_distance
		node.visible = delta_d >= MIDGROUND_VISIBLE_BEHIND and delta_d <= MIDGROUND_VISIBLE_AHEAD


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
	particles.amount = 16
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

	_finish_portal_root = Node3D.new()
	_finish_portal_root.name = "FinishPortalRoot"
	var portal_placed := _world_on_path(_finish_line_distance + FINISH_PORTAL_DEPTH, 0.0, 0.0)
	_finish_portal_root.position = portal_placed["pos"]
	_finish_portal_root.rotation.y = float(portal_placed["yaw"])
	track_root.add_child(_finish_portal_root)

	# 视频：地平线后方是建筑/山体剪影，不是 3D 实模占满画面
	_finish_silhouette_billboard = _make_finish_silhouette_billboard()
	if _finish_silhouette_billboard:
		_finish_portal_root.add_child(_finish_silhouette_billboard)

	var sky_plane := MeshInstance3D.new()
	sky_plane.name = "FinishOutpostSky"
	var sky_mesh := QuadMesh.new()
	sky_mesh.size = Vector2(42.0, 16.0)
	_finish_sky_mat = ShaderMaterial.new()
	_finish_sky_mat.shader = FINISH_OUTPOST_SKY_SHADER
	sky_mesh.material = _finish_sky_mat
	sky_plane.mesh = sky_mesh
	sky_plane.position = Vector3(0.0, 7.2, -4.2)
	sky_plane.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_finish_portal_root.add_child(sky_plane)

	# 横向粉紫光幕：宽而扁，贴地平线，对齐视频 55–60s
	var gate := MeshInstance3D.new()
	gate.name = "FinishPortalGate"
	var gate_mesh := QuadMesh.new()
	gate_mesh.size = Vector2(26.0, 3.6)
	var gate_mat := ShaderMaterial.new()
	gate_mat.shader = FINISH_PORTAL_GATE_SHADER
	gate_mat.set_shader_parameter("base_color", Color(0.42, 0.55, 0.98, 0.55))
	gate_mat.set_shader_parameter("accent_color", Color(0.92, 0.55, 1.0, 1.0))
	gate_mat.set_shader_parameter("scan_color", Color(0.98, 0.72, 1.0, 0.95))
	gate_mat.set_shader_parameter("gate_open", 0.0)
	gate_mesh.material = gate_mat
	gate.mesh = gate_mesh
	gate.position = Vector3(0.0, 4.85, 0.18)
	gate.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_finish_portal_root.add_child(gate)
	_finish_portal_mats.append(gate_mat)

	var banner := MeshInstance3D.new()
	banner.name = "FinishTitleBanner"
	var banner_mesh := QuadMesh.new()
	banner_mesh.size = Vector2(34.0, 4.8)
	_finish_title_mat = ShaderMaterial.new()
	_finish_title_mat.shader = FINISH_OUTPOST_TITLE_SHADER
	_finish_title_mat.set_shader_parameter("wave_color", Color(0.55, 0.72, 1.0, 0.72))
	_finish_title_mat.set_shader_parameter("accent_color", Color(1.0, 0.72, 0.94, 1.0))
	banner_mesh.material = _finish_title_mat
	banner.mesh = banner_mesh
	banner.position = Vector3(0.0, 6.35, 0.28)
	banner.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_finish_portal_root.add_child(banner)

	var title := Label3D.new()
	title.name = "FinishOutpostTitle"
	var title_text := _finish_outpost_title_en().to_upper()
	if Global.runner_location_id == "reservoir" or title_text.contains("WATER"):
		title_text = "WATER STATION"
	title.text = title_text
	title.font_size = 248
	title.modulate = Color(0.88, 0.96, 1.0, 0.78)
	title.outline_modulate = Color(0.38, 0.18, 0.72, 0.95)
	title.outline_size = 22
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector3(0.0, 6.42, 0.42)
	title.no_depth_test = true
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_finish_portal_root.add_child(title)
	_finish_outpost_title_rig = title


func _make_finish_silhouette_billboard() -> MeshInstance3D:
	var path := "res://assets/maps/route_levels/runner_60s/settlement/water_station_silhouette.png"
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return _make_finish_horizon_rocks()
	var tex: Texture2D = load(path) as Texture2D
	if tex == null:
		return _make_finish_horizon_rocks()
	var board := MeshInstance3D.new()
	board.name = "FinishOutpostSilhouette"
	var quad := QuadMesh.new()
	quad.size = Vector2(34.0, 11.5)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.12
	mat.albedo_texture = tex
	mat.albedo_color = Color(0.04, 0.05, 0.08, 1.0)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.disable_fog = true
	quad.material = mat
	board.mesh = quad
	board.position = Vector3(0.0, 5.4, -5.6)
	board.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return board


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
	var boost := clampf(1.0 - remain / 220.0, 0.0, 1.0)
	if _finish_sprint_timer > 0.0:
		boost = maxf(boost, 0.82)
	var pulse := 0.92 + 0.08 * sin(Time.get_ticks_msec() * 0.006)
	# 远看青蓝横幅（~55s），冲近变粉紫光幕（~60s）
	var far_base := Color(0.42, 0.58, 0.98, 0.42)
	var near_base := Color(0.78, 0.28, 0.88, 0.78)
	var far_accent := Color(0.72, 0.86, 1.0, 1.0)
	var near_accent := Color(1.0, 0.55, 0.92, 1.0)
	var base_c := far_base.lerp(near_base, boost)
	var accent_c := far_accent.lerp(near_accent, boost)
	for mat in _finish_portal_mats:
		if mat == null:
			continue
		mat.set_shader_parameter("base_color", base_c)
		mat.set_shader_parameter("accent_color", accent_c)
		mat.set_shader_parameter("scan_color", Color(0.95, 0.78, 1.0, 0.95))
		mat.set_shader_parameter("gate_open", boost)
		mat.set_shader_parameter("pulse", pulse * (0.92 + boost * 0.18))
	if _finish_title_mat != null:
		_finish_title_mat.set_shader_parameter("wave_color", Color(0.48, 0.72, 1.0, 0.42).lerp(Color(0.88, 0.32, 0.82, 0.78), boost))
		_finish_title_mat.set_shader_parameter("accent_color", Color(0.85, 0.92, 1.0, 1.0).lerp(Color(1.0, 0.68, 0.94, 1.0), boost))
		_finish_title_mat.set_shader_parameter("approach_boost", boost)
		_finish_title_mat.set_shader_parameter("pulse", pulse)
	if _finish_sky_mat != null:
		_finish_sky_mat.set_shader_parameter("approach_boost", boost)
	if _finish_outpost_title_rig != null and is_instance_valid(_finish_outpost_title_rig):
		var title_pulse := 1.0 + 0.06 * sin(Time.get_ticks_msec() * 0.005) * (0.55 + boost * 0.45)
		_finish_outpost_title_rig.modulate = Color(0.82, 0.94, 1.0, 0.55).lerp(Color(1.0, 0.82, 0.98, 1.0), boost)
		_finish_outpost_title_rig.outline_modulate = Color(0.28, 0.42, 0.82, 0.88).lerp(Color(0.72, 0.22, 0.78, 0.98), boost)
		_finish_outpost_title_rig.font_size = int(lerpf(220.0, 268.0, boost) * title_pulse)

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
