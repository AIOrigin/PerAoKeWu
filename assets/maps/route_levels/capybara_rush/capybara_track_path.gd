class_name CapybaraTrackPath
extends RefCounted

## 弯道赛道：Curve3D 采样 + 简易路面条带

var curve: Curve3D
var length: float = 0.0


func build_winding(target_length: float = 600.0) -> void:
	curve = Curve3D.new()
	curve.bake_interval = 0.75
	var z := 0.0
	var x := 0.0
	var i := 0
	curve.add_point(Vector3(0.0, 0.0, 0.0))
	while z < target_length:
		var seg := 42.0
		z += seg
		# 左右摆动形成弯道
		var bend := sin(float(i) * 0.85) * 18.0 + cos(float(i) * 0.37) * 8.0
		x = lerpf(x, bend, 0.72)
		var p := Vector3(x, 0.0, z)
		var in_t := Vector3(0.0, 0.0, -seg * 0.28)
		var out_t := Vector3(0.0, 0.0, seg * 0.28)
		# 弯心处加大切线横向分量
		if i % 2 == 0:
			out_t.x = (bend - x) * 0.35
			in_t.x = -out_t.x
		curve.add_point(p, in_t, out_t)
		i += 1
	length = curve.get_baked_length()


func frame_at(dist: float) -> Dictionary:
	var d := clampf(dist, 0.0, maxf(length, 0.01))
	var pos := curve.sample_baked(d)
	var pos2 := curve.sample_baked(minf(d + 0.8, length))
	var tangent := pos2 - pos
	if tangent.length_squared() < 0.0001:
		tangent = Vector3(0.0, 0.0, 1.0)
	else:
		tangent = tangent.normalized()
	var right := Vector3.UP.cross(tangent)
	if right.length_squared() < 0.0001:
		right = Vector3(1.0, 0.0, 0.0)
	else:
		right = right.normalized()
	var yaw := atan2(tangent.x, tangent.z)
	return {
		"pos": pos,
		"tangent": tangent,
		"right": right,
		"yaw": yaw,
	}


func world_pos(dist: float, lateral: float, y: float = 0.0) -> Vector3:
	var f := frame_at(dist)
	var p: Vector3 = f["pos"]
	var r: Vector3 = f["right"]
	return p + r * lateral + Vector3(0.0, y, 0.0)


func apply_to(node: Node3D, dist: float, lateral: float, y: float = 0.0, yaw_extra: float = 0.0) -> void:
	if node == null or not is_instance_valid(node):
		return
	var f := frame_at(dist)
	var p: Vector3 = f["pos"]
	var r: Vector3 = f["right"]
	var yaw: float = float(f["yaw"])
	node.global_position = p + r * lateral + Vector3(0.0, y, 0.0)
	node.rotation = Vector3(0.0, yaw + yaw_extra, node.rotation.z)


func build_road_mesh(half_w: float, thickness: float = 0.18) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step := 1.4
	var d := 0.0
	while d < length:
		var d2 := minf(d + step, length)
		var f0 := frame_at(d)
		var f1 := frame_at(d2)
		var p0: Vector3 = f0["pos"]
		var p1: Vector3 = f1["pos"]
		var r0: Vector3 = f0["right"]
		var r1: Vector3 = f1["right"]
		var y := -thickness * 0.5
		var a := p0 - r0 * half_w + Vector3(0, y, 0)
		var b := p0 + r0 * half_w + Vector3(0, y, 0)
		var c := p1 + r1 * half_w + Vector3(0, y, 0)
		var e := p1 - r1 * half_w + Vector3(0, y, 0)
		var n := Vector3.UP
		_quad(st, a, b, c, e, n)
		# 顶面略抬高
		var a2 := a + Vector3(0, thickness, 0)
		var b2 := b + Vector3(0, thickness, 0)
		var c2 := c + Vector3(0, thickness, 0)
		var e2 := e + Vector3(0, thickness, 0)
		_quad(st, a2, b2, c2, e2, n)
		d = d2
	st.generate_normals()
	return st.commit()


func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, n: Vector3) -> void:
	st.set_normal(n)
	st.add_vertex(a)
	st.add_vertex(b)
	st.add_vertex(c)
	st.add_vertex(a)
	st.add_vertex(c)
	st.add_vertex(d)
