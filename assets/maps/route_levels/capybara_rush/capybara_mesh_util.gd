class_name CapybaraMeshUtil
extends RefCounted

## 圆角盒体：在实心 BoxMesh 上推顶点，保留引擎绕序，避免镂空

static var _box_cache: Dictionary = {}
const CACHE_VER := 3


static func rounded_box(size: Vector3, radius: float = -1.0, segs: int = 4) -> ArrayMesh:
	var sx := maxf(size.x, 0.002)
	var sy := maxf(size.y, 0.002)
	var sz := maxf(size.z, 0.002)
	var min_side := minf(sx, minf(sy, sz))
	var r := radius
	if r < 0.0:
		r = min_side * 0.16
	# 半径必须小于半边，否则对面挤成一张纸
	r = minf(r, min_side * 0.38)
	r = maxf(r, 0.001)
	var key := "%d_%.4f_%.4f_%.4f_%.4f_%d" % [CACHE_VER, sx, sy, sz, r, segs]
	if _box_cache.has(key):
		return _box_cache[key]
	var mesh := _build_rounded_box(Vector3(sx, sy, sz), r, maxi(segs, 2))
	_box_cache[key] = mesh
	return mesh


static func _build_rounded_box(size: Vector3, r: float, segs: int) -> ArrayMesh:
	var box := BoxMesh.new()
	box.size = size
	var loops := clampi(segs, 2, 8)
	box.subdivide_width = loops
	box.subdivide_height = loops
	box.subdivide_depth = loops
	var arrays: Array = box.get_mesh_arrays()
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var nrms := PackedVector3Array()
	nrms.resize(verts.size())
	var h := size * 0.5
	var inner := Vector3(maxf(h.x - r, 0.0001), maxf(h.y - r, 0.0001), maxf(h.z - r, 0.0001))
	for i in verts.size():
		var p: Vector3 = verts[i]
		var q := Vector3(
			clampf(p.x, -inner.x, inner.x),
			clampf(p.y, -inner.y, inner.y),
			clampf(p.z, -inner.z, inner.z)
		)
		var d := p - q
		var n: Vector3
		if d.length_squared() < 0.00000001:
			n = Vector3(
				signf(p.x) if absf(p.x) >= h.x - 0.0001 else 0.0,
				signf(p.y) if absf(p.y) >= h.y - 0.0001 else 0.0,
				signf(p.z) if absf(p.z) >= h.z - 0.0001 else 0.0
			)
			if n.length_squared() < 0.0001:
				n = Vector3.UP
			else:
				n = n.normalized()
		else:
			n = d.normalized()
		verts[i] = q + n * r
		nrms[i] = n
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = nrms
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


static func rounded_rect_profile(half_w: float, thickness: float, radius: float, segs: int = 4) -> PackedVector2Array:
	## (lateral, y) 逆时针，y 以厚度中心为 0
	var hw := maxf(half_w, 0.05)
	var ht := maxf(thickness * 0.5, 0.01)
	var r := minf(radius, minf(hw, ht) * 0.98)
	r = maxf(r, 0.004)
	var cx_l := -hw + r
	var cx_r := hw - r
	var cy_b := -ht + r
	var cy_t := ht - r
	var pts := PackedVector2Array()
	_append_arc(pts, cx_l, cy_b, r, PI, PI * 1.5, segs)
	_append_arc(pts, cx_r, cy_b, r, PI * 1.5, TAU, segs)
	_append_arc(pts, cx_r, cy_t, r, 0.0, PI * 0.5, segs)
	_append_arc(pts, cx_l, cy_t, r, PI * 0.5, PI, segs)
	return pts


static func _append_arc(pts: PackedVector2Array, cx: float, cy: float, r: float, a0: float, a1: float, segs: int) -> void:
	var n := maxi(segs, 2)
	var start := 0 if pts.is_empty() else 1
	for i in range(start, n + 1):
		var t := float(i) / float(n)
		var a := lerpf(a0, a1, t)
		pts.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
