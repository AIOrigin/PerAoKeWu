class_name CapybaraEditorVisual
extends RefCounted

## 编辑器预览：setpiece / 三连跳 / 断崖 的简易标记

const LANE_WIDTH := 1.08
const LANE_COUNT := 3
const ROAD_SURFACE_Y := 0.09

const TYPE_COLORS := {
	"stair_weave": Color(0.85, 0.55, 0.25),
	"stair_ascend": Color(0.92, 0.62, 0.28),
	"stair_wave": Color(0.78, 0.48, 0.22),
	"hurdle_single": Color(0.95, 0.35, 0.45),
	"hurdle_wide": Color(0.98, 0.28, 0.38),
	"stripe_single": Color(0.55, 0.85, 0.45),
	"combo_stair_hurdle": Color(0.88, 0.45, 0.62),
	"sweeper_single": Color(0.35, 0.78, 0.95),
	"sweeper_duel": Color(0.25, 0.65, 0.92),
	"pendulum_triple": Color(0.72, 0.42, 0.95),
	"swing_hoop": Color(0.95, 0.72, 0.25),
	"spin_ring": Color(0.45, 0.92, 0.82),
	"l_gate": Color(0.95, 0.55, 0.15),
	"fire_gate": Color(0.35, 0.82, 1.0),
	"cross_rotator": Color(0.55, 0.95, 0.35),
	"jump_challenge": Color(0.25, 0.72, 0.98),
	"cliff": Color(0.15, 0.18, 0.28),
}


static func lane_to_x(lane: int) -> float:
	var mid := (LANE_COUNT - 1) * 0.5
	return (float(lane) - mid) * LANE_WIDTH


static func uses_lane(type_id: String) -> bool:
	return type_id in ["hurdle_single", "hurdle_wide", "stripe_single", "spin_ring", "jump_challenge"]


func build_setpiece_marker(item: Dictionary, selected: bool) -> Node3D:
	var root := Node3D.new()
	var otype := String(item.get("type", "stair_weave"))
	var lane := int(item.get("lane", 1))
	var col: Color = TYPE_COLORS.get(otype, Color(0.8, 0.8, 0.85))
	if selected:
		col = col.lerp(Color(1.0, 0.95, 0.35), 0.45)

	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	match otype:
		"fire_gate", "l_gate":
			bm.size = Vector3(2.0, 2.2, 0.35)
		"pendulum_triple":
			bm.size = Vector3(2.8, 1.8, 0.4)
		"sweeper_single", "sweeper_duel":
			bm.size = Vector3(2.4, 0.35, 2.4)
		"cross_rotator", "spin_ring", "swing_hoop":
			bm.size = Vector3(2.2, 2.0, 2.2)
		"jump_challenge":
			bm.size = Vector3(2.6, 0.25, 8.5)
		"cliff":
			bm.size = Vector3(4.0, 0.15, 11.0)
		_:
			bm.size = Vector3(1.6, 1.2, 1.0)
	body.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(col.r, col.g, col.b, 0.82 if selected else 0.68)
	mat.emission_enabled = true
	mat.emission = col
	mat.emission_energy_multiplier = 1.8 if selected else 1.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	body.material_override = mat
	body.position.y = bm.size.y * 0.5 + ROAD_SURFACE_Y
	if uses_lane(otype):
		body.position.x = lane_to_x(lane)
	root.add_child(body)

	if selected:
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = 0.5
		torus.outer_radius = 0.68
		var rmat := StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.92, 0.2, 0.85)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.9, 0.25)
		rmat.emission_energy_multiplier = 2.0
		rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		torus.material = rmat
		ring.mesh = torus
		ring.rotation_degrees.x = 90.0
		ring.position.y = 0.12
		root.add_child(ring)

	var label := Label3D.new()
	label.text = "%s\n%.0fm" % [CapybaraLevelLayout.place_type_label(otype), float(item.get("dist", 0.0))]
	label.font_size = 40 if selected else 34
	label.pixel_size = 0.011
	label.position = Vector3(0.0, 2.4 if selected else 2.0, 0.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(1.0, 1.0, 0.55) if selected else Color(0.92, 0.96, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 8
	root.add_child(label)
	return root
