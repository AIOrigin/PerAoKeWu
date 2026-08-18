class_name CapybaraTrackPath
extends RefCounted

## 弯道赛道：Curve3D 采样 + 圆角路面条带

const MeshUtil := preload("res://assets/maps/route_levels/capybara_rush/capybara_mesh_util.gd")

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


func build_road_mesh(half_w: float, thickness: float = 0.18, gaps: Array = []) -> ArrayMesh:
	## gaps: [{dist0, dist1}, ...] 断崖区间不铺路面，中间留空
	## 圆角截面（接近胶囊边），避免薄板 90° 硬棱
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(0)
	var fillet := minf(thickness * 0.46, 0.082)
	var profile: PackedVector2Array = MeshUtil.rounded_rect_profile(half_w, thickness, fillet, 4)
	var nprof := profile.size()
	if nprof < 4:
		return ArrayMesh.new()
	var prof_n := _profile_outward_normals(profile)
	var step := 1.4
	var ranges := _road_solid_ranges(gaps)
	for rng in ranges:
		var d0 := float(rng[0])
		var d1 := float(rng[1])
		if d1 - d0 < 0.05:
			continue
		var slices: Array[PackedVector3Array] = []
		var norms: Array[PackedVector3Array] = []
		var d := d0
		while true:
			var sl := _road_slice(d, profile, prof_n)
			slices.append(sl["pts"])
			norms.append(sl["nrms"])
			if d >= d1 - 0.0001:
				break
			d = minf(d + step, d1)
		if slices.size() < 2:
			continue
		for si in slices.size() - 1:
			var s0: PackedVector3Array = slices[si]
			var s1: PackedVector3Array = slices[si + 1]
			var n0: PackedVector3Array = norms[si]
			var n1: PackedVector3Array = norms[si + 1]
			for j in nprof:
				var j2 := (j + 1) % nprof
				_road_quad(st, s0[j], s0[j2], s1[j2], s1[j], n0[j], n0[j2], n1[j2], n1[j])
		_cap_road_slice(st, slices[0], norms[0], true)
		_cap_road_slice(st, slices[slices.size() - 1], norms[slices.size() - 1], false)
	st.index()
	st.generate_normals()
	return st.commit()


func _road_solid_ranges(gaps: Array) -> Array:
	var out: Array = []
	var cursor := 0.0
	while cursor < length - 0.05:
		var covering := _gap_covering(cursor, gaps)
		if covering >= 0.0:
			cursor = covering if covering > cursor else cursor + 0.25
			continue
		var start := cursor
		var end := length
		for g in gaps:
			if typeof(g) != TYPE_DICTIONARY:
				continue
			var a := float(g.get("dist0", -1.0))
			if a > start:
				end = minf(end, a)
		if end - start >= 0.05:
			out.append([start, end])
		cursor = end
	return out


func _gap_covering(dist: float, gaps: Array) -> float:
	## 若 dist 落在缺口内，返回该缺口终点；否则 -1
	for g in gaps:
		if typeof(g) != TYPE_DICTIONARY:
			continue
		var a := float(g.get("dist0", -1.0))
		var b := float(g.get("dist1", -1.0))
		if b <= a:
			continue
		if dist >= a and dist < b:
			return b
	return -1.0


func _road_slice(dist: float, profile: PackedVector2Array, prof_n: PackedVector2Array) -> Dictionary:
	var f := frame_at(dist)
	var p: Vector3 = f["pos"]
	var right: Vector3 = f["right"]
	var pts := PackedVector3Array()
	var nrms := PackedVector3Array()
	pts.resize(profile.size())
	nrms.resize(profile.size())
	for i in profile.size():
		var q: Vector2 = profile[i]
		var nn: Vector2 = prof_n[i]
		pts[i] = p + right * q.x + Vector3(0.0, q.y, 0.0)
		nrms[i] = (right * nn.x + Vector3(0.0, nn.y, 0.0)).normalized()
	return {"pts": pts, "nrms": nrms}


func _profile_outward_normals(profile: PackedVector2Array) -> PackedVector2Array:
	var n := profile.size()
	var out := PackedVector2Array()
	out.resize(n)
	for i in n:
		var prev: Vector2 = profile[(i - 1 + n) % n]
		var nxt: Vector2 = profile[(i + 1) % n]
		var t := (nxt - prev)
		if t.length_squared() < 0.000001:
			out[i] = Vector2.UP
			continue
		t = t.normalized()
		out[i] = Vector2(t.y, -t.x)
	return out


func _road_quad(
	st: SurfaceTool,
	a: Vector3, b: Vector3, c: Vector3, d: Vector3,
	na: Vector3, nb: Vector3, nc: Vector3, nd: Vector3
) -> void:
	st.set_normal(na)
	st.add_vertex(a)
	st.set_normal(nb)
	st.add_vertex(b)
	st.set_normal(nc)
	st.add_vertex(c)
	st.set_normal(na)
	st.add_vertex(a)
	st.set_normal(nc)
	st.add_vertex(c)
	st.set_normal(nd)
	st.add_vertex(d)


func _cap_road_slice(st: SurfaceTool, pts: PackedVector3Array, _nrms: PackedVector3Array, start_cap: bool) -> void:
	if pts.size() < 3:
		return
	var mid := Vector3.ZERO
	for p in pts:
		mid += p
	mid /= float(pts.size())
	var tangent := (pts[0] - mid).cross(pts[mini(3, pts.size() - 1)] - mid)
	if tangent.length_squared() < 0.00001:
		tangent = Vector3(0.0, 0.0, 1.0 if start_cap else -1.0)
	else:
		tangent = tangent.normalized()
	if start_cap:
		tangent = -tangent
	var nrm := tangent
	for i in pts.size():
		var a: Vector3 = pts[i]
		var b: Vector3 = pts[(i + 1) % pts.size()]
		if start_cap:
			st.set_normal(nrm)
			st.add_vertex(mid)
			st.add_vertex(b)
			st.add_vertex(a)
		else:
			st.set_normal(nrm)
			st.add_vertex(mid)
			st.add_vertex(a)
			st.add_vertex(b)


func _segment_overlaps_gap(d0: float, d1: float, gaps: Array) -> bool:
	for g in gaps:
		if typeof(g) != TYPE_DICTIONARY:
			continue
		var a := float(g.get("dist0", -1.0))
		var b := float(g.get("dist1", -1.0))
		if b <= a:
			continue
		if d1 > a and d0 < b:
			return true
	return false
