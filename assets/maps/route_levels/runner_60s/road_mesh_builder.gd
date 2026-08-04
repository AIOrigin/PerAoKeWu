class_name RoadMeshBuilder
extends RefCounted

## 编辑器与实机共用的路面挤出 / 样式 kit。改一层结构或材质，两边一起变。

const LANE_WIDTH := 4.0
const GROUND_Y := 0.85

const STYLE_ORDER: Array[String] = [
	"holographic", "alien_energy", "energy_neon", "planet",
	"coarse_desert", "rust_metal", "void_crystal",
]
const STYLE_LABELS := {
	"holographic": "全息能量轨",
	"alien_energy": "异星能量轨",
	"energy_neon": "能量霓虹",
	"planet": "星球默认",
	"coarse_desert": "粗粝沙漠",
	"rust_metal": "锈蚀金属",
	"void_crystal": "虚空晶体",
}

const ROAD_ALIEN_ENERGY_SHADER = preload("res://assets/maps/route_levels/runner_60s/road_alien_energy.gdshader")


static func normalize_style(style_id: String) -> String:
	if STYLE_ORDER.has(style_id):
		return style_id
	return "holographic"


static func style_label(style_id: String) -> String:
	return String(STYLE_LABELS.get(normalize_style(style_id), style_id))


## options:
##   track_pad: float = 12
##   extra_gaps: Array[Vector2]
##   clear_children: bool = true
##   include_start_pad: bool = true
##   cast_shadow_off: bool = false
##   theme: Dictionary（planet 等可覆盖 lane_line / road）
## 返回 kit，供分叉支路等继续用同一套材质。
func rebuild(
	parent: Node3D,
	sample_path: Callable,
	path_length: float,
	style_id: String,
	junctions: Array = [],
	options: Dictionary = {}
) -> Dictionary:
	var clear_children := bool(options.get("clear_children", true))
	if clear_children:
		while parent.get_child_count() > 0:
			parent.get_child(0).free()
	var empty: Dictionary = {}
	if path_length < 1.0:
		return empty

	var style := normalize_style(style_id)
	var theme: Dictionary = options.get("theme", {})
	var kit := make_kit(style, theme)
	var lane_y := GROUND_Y - 0.05
	var track_pad := float(options.get("track_pad", 12.0))
	var track_end := path_length + track_pad
	var gaps := fork_gaps(junctions)
	var extra: Array = options.get("extra_gaps", [])
	for g in extra:
		if g is Vector2 and g.y > g.x + 2.0:
			gaps.append(g)
	gaps.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)

	var cast_off := bool(options.get("cast_shadow_off", false))
	var step_main := 1.75

	if style in ["holographic", "energy_neon"]:
		var road_half := 6.4 if style == "energy_neon" else 6.0
		var shoulder_half := 1.6
		var shoulder_lat := road_half + shoulder_half
		var apron_half := shoulder_lat + shoulder_half + 0.2
		var underlay := make_mat(Color(0.02, 0.06, 0.1), Color(0.15, 0.45, 0.62), 0.55)
		if style == "energy_neon":
			underlay = make_mat(Color(0.01, 0.02, 0.04), Color(0.08, 0.28, 0.42), 0.35)
		elif style == "holographic":
			# 暗托底 + 与路同宽，避免弯道外侧冒出青蓝块
			underlay = make_mat(Color(0.015, 0.03, 0.05), Color(0.04, 0.1, 0.14), 0.08)
		var underlay_half := road_half if style == "holographic" else apron_half
		if style == "energy_neon":
			# 霓虹轨保留实心底盘，编辑器/实机可读
			var solid := make_mat(Color(0.06, 0.14, 0.2), Color(0.12, 0.4, 0.55), 0.45)
			_strip(parent, sample_path, 0.0, track_end, apron_half, lane_y - 0.028, solid, step_main, 0.0, style, gaps, cast_off)
		_strip(parent, sample_path, 0.0, track_end, underlay_half, lane_y - 0.018, underlay, step_main, 0.0, style, gaps, cast_off)
		_strip(parent, sample_path, 0.0, track_end, road_half, lane_y, kit["road"], step_main, 0.0, style, gaps, cast_off)
		if style != "holographic":
			_strip(parent, sample_path, 0.0, track_end, shoulder_half, lane_y - 0.008, kit["shoulder"], step_main, -shoulder_lat, style, gaps, cast_off)
			_strip(parent, sample_path, 0.0, track_end, shoulder_half, lane_y - 0.008, kit["shoulder"], step_main, shoulder_lat, style, gaps, cast_off)
		if style == "holographic":
			# 仅三道分隔线；不铺外侧发光路缘
			_strip(parent, sample_path, 0.0, track_end, 0.04, lane_y + 0.014, kit["line"], step_main, -LANE_WIDTH, style, gaps, cast_off)
			_strip(parent, sample_path, 0.0, track_end, 0.04, lane_y + 0.014, kit["line"], step_main, LANE_WIDTH, style, gaps, cast_off)
	else:
		var foundation_half := 14.0 if style == "planet" else (16.0 if style == "coarse_desert" else 21.0)
		var foundation_y := lane_y - 0.012 if style in ["planet", "coarse_desert"] else GROUND_Y - 0.14
		_strip(parent, sample_path, 0.0, track_end, foundation_half, foundation_y, kit["island"], 2.5, 0.0, style, gaps, cast_off)
		var shoulder_half := 9.2 if style != "coarse_desert" else (foundation_half - 6.5)
		_strip(parent, sample_path, 0.0, track_end, shoulder_half, lane_y - 0.012, kit["shoulder"], 2.0, 0.0, style, gaps, cast_off)
		var road_half := 6.0 if style == "alien_energy" else (6.5 if style == "coarse_desert" else 6.3)
		if style in ["alien_energy", "planet", "coarse_desert"]:
			var base_y := lane_y - 0.03 if style == "coarse_desert" else lane_y - 0.02
			_strip(parent, sample_path, 0.0, track_end, road_half, base_y, kit["base"], step_main, 0.0, style, gaps, cast_off)
		_strip(parent, sample_path, 0.0, track_end, road_half, lane_y, kit["road"], step_main, 0.0, style, gaps, cast_off)
		var curb_lat := road_half - 0.02
		_strip(parent, sample_path, 0.0, track_end, 0.07, lane_y + 0.012, kit["curb"], step_main, -curb_lat, style, gaps, cast_off)
		_strip(parent, sample_path, 0.0, track_end, 0.07, lane_y + 0.012, kit["curb"], step_main, curb_lat, style, gaps, cast_off)
		if style == "alien_energy":
			_strip(parent, sample_path, 0.0, track_end, 0.05, lane_y + 0.008, kit["line"], step_main, 0.0, style, gaps, cast_off)
		else:
			_strip(parent, sample_path, 0.0, track_end, 0.04, lane_y + 0.014, kit["line"], step_main, -LANE_WIDTH, style, gaps, cast_off)
			_strip(parent, sample_path, 0.0, track_end, 0.04, lane_y + 0.014, kit["line"], step_main, LANE_WIDTH, style, gaps, cast_off)

	if bool(options.get("include_start_pad", true)):
		_add_start_pad(parent, sample_path, kit, lane_y, style, cast_off)
	return kit


func apply_environment(env: Environment, style_id: String) -> void:
	if env == null:
		return
	var style := normalize_style(style_id)
	env.background_mode = Environment.BG_COLOR
	env.glow_enabled = false
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	match style:
		"holographic", "energy_neon", "alien_energy", "void_crystal":
			env.background_color = Color(0.38, 0.45, 0.52)
			env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			env.ambient_light_color = Color(0.9, 0.95, 1.0)
			env.ambient_light_energy = 1.4
		"coarse_desert", "planet", "rust_metal":
			env.background_color = Color(0.55, 0.48, 0.38)
			env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
			env.ambient_light_color = Color(1.0, 0.92, 0.78)
			env.ambient_light_energy = 1.35
		_:
			env.background_color = Color(0.42, 0.45, 0.48)
			env.ambient_light_color = Color(0.92, 0.94, 0.96)
			env.ambient_light_energy = 1.3


static func fork_gaps(junctions: Array) -> Array:
	var gaps: Array = []
	for raw in junctions:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var zone: Dictionary = raw
		var gs := float(zone.get("distance", 0.0))
		var glen := float(zone.get("length", 70.0))
		var ge := gs + glen
		var keep := maxf(glen * 0.14, 12.0)
		var cut_s := gs + keep - 4.0
		var cut_e := ge - keep + 4.0
		if cut_e > cut_s + 8.0:
			gaps.append(Vector2(cut_s, cut_e))
	gaps.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	return gaps


## samples: Array[{pos, yaw, d?}] — Y 分叉右岔等
func add_polyline_road(parent: Node3D, samples: Array, style_id: String, cast_shadow_off: bool = false) -> void:
	if parent == null or samples.size() < 2:
		return
	var style := normalize_style(style_id)
	var kit := make_kit(style)
	var lane_y := GROUND_Y - 0.05
	var road_half := 6.0 if style == "holographic" else (6.4 if style == "energy_neon" else 6.3)
	_polyline_strip(parent, samples, road_half + 1.4, lane_y - 0.02, kit["island"], style, 0.0, cast_shadow_off)
	_polyline_strip(parent, samples, road_half, lane_y, kit["road"], style, 0.0, cast_shadow_off)
	_polyline_strip(parent, samples, 0.07, lane_y + 0.012, kit["curb"], style, -(road_half - 0.02), cast_shadow_off)
	_polyline_strip(parent, samples, 0.07, lane_y + 0.012, kit["curb"], style, road_half - 0.02, cast_shadow_off)
	_polyline_strip(parent, samples, 0.04, lane_y + 0.014, kit["line"], style, -LANE_WIDTH, cast_shadow_off)
	_polyline_strip(parent, samples, 0.04, lane_y + 0.014, kit["line"], style, LANE_WIDTH, cast_shadow_off)


static func make_kit(style_id: String, theme: Dictionary = {}) -> Dictionary:
	var style := normalize_style(style_id)
	match style:
		"holographic":
			return {
				"road": _holographic_road(),
				"shoulder": make_mat(Color(0.02, 0.05, 0.08), Color(0.1, 0.4, 0.5), 0.2),
				"curb": make_mat(Color(0.08, 0.04, 0.14), Color(0.75, 0.35, 0.95), 1.6),
				"line": make_mat(Color(0.06, 0.14, 0.18), Color(0.45, 0.92, 1.0), 1.4),
				"post": make_mat(Color(0.03, 0.05, 0.08), Color(0.35, 0.7, 0.85), 0.5),
				"island": make_mat(Color(0.01, 0.03, 0.06), Color(0.06, 0.28, 0.38), 0.25),
				"base": make_mat(Color(0.015, 0.04, 0.08), Color(0.1, 0.38, 0.48), 0.18),
			}
		"alien_energy":
			return {
				"road": _alien_energy_road(),
				"shoulder": make_mat(Color(0.04, 0.09, 0.14), Color(0.28, 0.62, 0.78), 0.28),
				"curb": make_mat(Color(0.06, 0.14, 0.2), Color(0.5, 0.95, 1.0), 2.2),
				"line": make_mat(Color(0.1, 0.22, 0.3), Color(0.45, 0.95, 1.0), 2.4),
				"post": make_mat(Color(0.05, 0.1, 0.15), Color(0.4, 0.85, 1.0), 0.75),
				"island": make_mat(Color(0.03, 0.06, 0.1), Color(0.2, 0.48, 0.62), 0.18),
				"base": make_mat(Color(0.1, 0.16, 0.22), Color(0.22, 0.48, 0.58), 0.12),
			}
		"energy_neon":
			return {
				"road": _energy_neon_road(),
				"shoulder": make_mat(Color(0.01, 0.03, 0.06), Color(0.1, 0.38, 0.52), 0.22),
				"curb": make_mat(Color(0.1, 0.04, 0.18), Color(0.78, 0.32, 0.98), 2.6),
				"line": make_mat(Color(0.08, 0.2, 0.28), Color(0.35, 0.98, 1.0), 3.2),
				"post": make_mat(Color(0.03, 0.05, 0.08), Color(0.35, 0.85, 1.0), 0.55),
				"island": make_mat(Color(0.008, 0.02, 0.04), Color(0.08, 0.32, 0.48), 0.2),
				"base": make_mat(Color(0.04, 0.06, 0.1), Color(0.08, 0.28, 0.38), 0.12),
			}
		"planet":
			return {
				"road": _planet_road(),
				"shoulder": make_mat(Color(0.34, 0.24, 0.16), Color(0.42, 0.3, 0.18), 0.08),
				"curb": make_mat(Color(0.4, 0.3, 0.18), Color(0.72, 0.52, 0.26), 0.42),
				"line": make_mat(theme.get("lane_line", Color(1.0, 0.86, 0.42)), Color(1.0, 0.78, 0.28), 1.15),
				"post": make_mat(Color(0.18, 0.18, 0.16), Color(0.85, 0.62, 0.34), 0.35),
				"island": make_mat(Color(0.2, 0.14, 0.1), Color(0.32, 0.22, 0.14), 0.06),
				"base": make_mat(Color(0.2, 0.15, 0.11), Color(0.28, 0.2, 0.14), 0.05),
			}
		"coarse_desert":
			return {
				"road": _coarse_desert_road(),
				"shoulder": _opaque_desert(Color(0.5, 0.32, 0.17)),
				"curb": _opaque_desert(Color(0.42, 0.27, 0.14)),
				"line": _opaque_desert(Color(0.72, 0.56, 0.32), Color(0.85, 0.66, 0.36), 0.08),
				"post": _opaque_desert(Color(0.34, 0.22, 0.13)),
				"island": _opaque_desert(Color(0.46, 0.3, 0.15)),
				"base": _opaque_desert(Color(0.38, 0.24, 0.12)),
			}
		"rust_metal":
			return {
				"road": make_mat(Color(0.22, 0.16, 0.12), Color(0.55, 0.28, 0.1), 0.2),
				"shoulder": make_mat(Color(0.32, 0.2, 0.12), Color(0.7, 0.35, 0.12), 0.35),
				"curb": make_mat(Color(0.45, 0.26, 0.12), Color(0.95, 0.45, 0.15), 1.1),
				"line": make_mat(Color(0.95, 0.7, 0.25), Color(1.0, 0.7, 0.2), 1.8),
				"post": make_mat(Color(0.16, 0.12, 0.1), Color(0.85, 0.4, 0.15), 0.6),
				"island": make_mat(Color(0.28, 0.18, 0.12), Color(0.55, 0.3, 0.12), 0.15),
				"base": make_mat(Color(0.16, 0.12, 0.1), Color(0.4, 0.2, 0.1), 0.1),
			}
		"void_crystal":
			return {
				"road": make_mat(Color(0.06, 0.05, 0.12), Color(0.45, 0.25, 1.0), 0.55),
				"shoulder": make_mat(Color(0.1, 0.08, 0.18), Color(0.55, 0.35, 1.0), 0.7),
				"curb": make_mat(Color(0.12, 0.1, 0.22), Color(0.7, 0.45, 1.0), 2.8),
				"line": make_mat(Color(0.75, 0.55, 1.0), Color(0.85, 0.65, 1.0), 2.6),
				"post": make_mat(Color(0.08, 0.06, 0.14), Color(0.4, 0.9, 1.0), 1.4),
				"island": make_mat(Color(0.07, 0.05, 0.12), Color(0.5, 0.3, 0.9), 0.25),
				"base": make_mat(Color(0.04, 0.03, 0.08), Color(0.3, 0.15, 0.6), 0.2),
			}
		_:
			return make_kit("holographic", theme)


static func make_mat(color: Color, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material


func _strip(
	parent: Node3D,
	sample_path: Callable,
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	lateral_bias: float,
	style_id: String,
	gaps: Array,
	cast_shadow_off: bool = false
) -> void:
	if material == null or end_d <= start_d + 0.05:
		return
	if gaps.is_empty():
		_strip_segment(parent, sample_path, start_d, end_d, half_width, y, material, step, lateral_bias, style_id, cast_shadow_off)
		return
	var cursor := start_d
	for gap in gaps:
		var gs: float = gap.x
		var ge: float = gap.y
		if ge <= cursor or gs >= end_d:
			continue
		if cursor < gs:
			_strip_segment(parent, sample_path, cursor, minf(gs, end_d), half_width, y, material, step, lateral_bias, style_id, cast_shadow_off)
		cursor = maxf(cursor, ge)
	if cursor < end_d:
		_strip_segment(parent, sample_path, cursor, end_d, half_width, y, material, step, lateral_bias, style_id, cast_shadow_off)


func _strip_segment(
	parent: Node3D,
	sample_path: Callable,
	start_d: float,
	end_d: float,
	half_width: float,
	y: float,
	material: Material,
	step: float,
	lateral_bias: float,
	style_id: String,
	cast_shadow_off: bool = false
) -> void:
	if end_d <= start_d + 0.05:
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array[Dictionary] = []
	var d := start_d
	while d < end_d - 0.001:
		pts.append(_point(sample_path, d, half_width, y, lateral_bias))
		d += step
	pts.append(_point(sample_path, end_d, half_width, y, lateral_bias))
	if pts.size() < 2:
		return
	var uv_scale := 0.14 if style_id == "holographic" else (0.2 if style_id == "energy_neon" else (0.11 if style_id == "coarse_desert" else 0.08))
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
	if cast_shadow_off:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


func _point(sample_path: Callable, distance: float, half_width: float, y: float, lateral_bias: float) -> Dictionary:
	var sample: Dictionary = sample_path.call(distance)
	var origin: Vector3 = sample["pos"] + (sample["right"] as Vector3) * lateral_bias
	var right: Vector3 = sample["right"]
	var L := origin - right * half_width
	var R := origin + right * half_width
	L.y = y
	R.y = y
	return {"L": L, "R": R, "d": distance}


func _add_start_pad(
	parent: Node3D,
	sample_path: Callable,
	kit: Dictionary,
	lane_y: float,
	style_id: String,
	cast_shadow_off: bool = false
) -> void:
	var pad_half := 6.2
	_strip_segment(parent, sample_path, 0.0, 18.0, pad_half + 1.2, lane_y - 0.01, kit["shoulder"], 2.0, 0.0, style_id, cast_shadow_off)
	_strip_segment(parent, sample_path, 0.0, 14.0, pad_half, lane_y + 0.002, kit["road"], 2.0, 0.0, style_id, cast_shadow_off)
	_strip_segment(parent, sample_path, 0.0, 14.0, 0.06, lane_y + 0.016, kit["line"], 2.0, -LANE_WIDTH, style_id, cast_shadow_off)
	_strip_segment(parent, sample_path, 0.0, 14.0, 0.06, lane_y + 0.016, kit["line"], 2.0, LANE_WIDTH, style_id, cast_shadow_off)


func _polyline_strip(
	parent: Node3D,
	samples: Array,
	half_width: float,
	y: float,
	material: Material,
	style_id: String,
	lateral_bias: float = 0.0,
	cast_shadow_off: bool = false
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
		var d := float(s.get("d", float(i) * 2.0))
		pts.append({"L": L, "R": R, "d": d})
	var uv_scale := 0.14 if style_id == "holographic" else 0.09
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
	if cast_shadow_off:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


static func _holographic_road() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tex := _load_tex([
		"res://assets/maps/route_levels/runner_60s/holographic_road_topdown.png",
		"res://assets/maps/route_levels/runner_60s/holographic_energy_runway.png",
	])
	if tex:
		mat.albedo_texture = tex
		mat.emission_texture = tex
	mat.albedo_color = Color(0.28, 0.68, 0.78)
	mat.emission_enabled = true
	mat.emission = Color(0.38, 0.92, 1.0)
	mat.emission_energy_multiplier = 2.2
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat


static func _energy_neon_road() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tex := _load_tex(["res://assets/maps/route_levels/runner_60s/energy_neon_runway.png"])
	if tex:
		mat.albedo_texture = tex
		mat.emission_texture = tex
	mat.albedo_color = Color(0.55, 0.92, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.98, 1.0)
	mat.emission_energy_multiplier = 5.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat


static func _alien_energy_road() -> ShaderMaterial:
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


static func _planet_road() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.36, 0.3)
	mat.roughness = 0.78
	mat.metallic = 0.06
	mat.emission_enabled = true
	mat.emission = Color(0.48, 0.38, 0.26)
	mat.emission_energy_multiplier = 0.15
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat


static func _coarse_desert_road() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var tex := _load_tex(["res://assets/maps/route_levels/runner_60s/textures/white_sandstone_blocks_02_diff_1k.jpg"])
	if tex:
		mat.albedo_texture = tex
	mat.albedo_color = Color(0.78, 0.58, 0.36)
	mat.roughness = 0.94
	mat.metallic = 0.02
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	return mat


static func _opaque_desert(
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


static func _load_tex(paths: Array) -> Texture2D:
	for path in paths:
		if ResourceLoader.exists(String(path)):
			var tex := load(String(path)) as Texture2D
			if tex:
				return tex
	return null
