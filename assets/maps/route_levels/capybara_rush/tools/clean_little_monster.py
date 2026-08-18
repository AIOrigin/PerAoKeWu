#!/usr/bin/env python3
"""Strip furniture base from little_monster; keep cyan body + yarn limbs."""
import bpy
import bmesh
from collections import defaultdict
from mathutils import Vector, kdtree

IN_PATH = "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/models/characters/little_monster.glb"
OUT_PATH = IN_PATH


def clear_scene():
	for o in list(bpy.data.objects):
		bpy.data.objects.remove(o, do_unlink=True)
	for m in list(bpy.data.meshes):
		bpy.data.meshes.remove(m)


def get_image(me):
	for mat in me.materials:
		if not mat:
			continue
		nt = getattr(mat, "node_tree", None)
		if not nt:
			continue
		for n in nt.nodes:
			if n.type == "TEX_IMAGE" and n.image:
				return n.image
	return None


def face_color(img, uv_layer, face, w, h, pixels):
	uvs = [loop[uv_layer].uv for loop in face.loops]
	cu = sum(u.x for u in uvs) / len(uvs)
	cv = sum(u.y for u in uvs) / len(uvs)
	x = int(min(w - 1, max(0, cu * (w - 1))))
	y = int(min(h - 1, max(0, cv * (h - 1))))
	i = (y * w + x) * 4
	return Vector((pixels[i], pixels[i + 1], pixels[i + 2]))


def is_strong_blue(c):
	r, g, b = c.x, c.y, c.z
	return b > 0.40 and (b - r) > 0.10


def is_body_blue(c):
	r, g, b = c.x, c.y, c.z
	return b > 0.35 and b >= r - 0.02 and (b - r) > 0.03


def is_dark_limb(c):
	r, g, b = c.x, c.y, c.z
	lum = (r + g + b) / 3.0
	sat = max(r, g, b) - min(r, g, b)
	return lum < 0.40 and sat < 0.16


def is_mouth_pink(c):
	r, g, b = c.x, c.y, c.z
	return r > 0.55 and r > g + 0.10 and r > b + 0.10


def is_teeth(c):
	r, g, b = c.x, c.y, c.z
	lum = (r + g + b) / 3.0
	sat = max(r, g, b) - min(r, g, b)
	return lum > 0.75 and sat < 0.14


def is_furniture(c):
	"""Desk top (brown), white sides, gray base."""
	r, g, b = c.x, c.y, c.z
	lum = (r + g + b) / 3.0
	sat = max(r, g, b) - min(r, g, b)
	# reddish-brown / terracotta top
	if r > 0.28 and r >= g and r > b + 0.04 and lum < 0.80 and (b - r) < 0.02:
		return True
	# white / light gray panel
	if lum > 0.72 and sat < 0.12 and (b - r) < 0.05:
		return True
	# gray plinth
	if sat < 0.10 and 0.25 < lum < 0.70 and (b - r) < 0.05:
		return True
	return False


def largest_spatial_component(points, radius):
	n = len(points)
	kd = kdtree.KDTree(n)
	for i, p in enumerate(points):
		kd.insert(p, i)
	kd.balance()
	parent = list(range(n))

	def find(a):
		while parent[a] != a:
			parent[a] = parent[parent[a]]
			a = parent[a]
		return a

	def union(a, b):
		ra, rb = find(a), find(b)
		if ra != rb:
			parent[rb] = ra

	for i, p in enumerate(points):
		for _co, j, _d in kd.find_range(p, radius):
			if j > i:
				union(i, j)
	buckets = defaultdict(list)
	for i in range(n):
		buckets[find(i)].append(i)
	largest = max(buckets.values(), key=len)
	print("COMPONENTS", len(buckets), "main", len(largest))
	return set(largest)


def main():
	clear_scene()
	bpy.ops.import_scene.gltf(filepath=IN_PATH)
	obj = [o for o in bpy.context.scene.objects if o.type == "MESH"][0]
	me = obj.data
	img = get_image(me)
	if not img.has_data:
		_ = img.pixels[0]
	pixels = list(img.pixels)
	w, h = img.size

	bm = bmesh.new()
	bm.from_mesh(me)
	bm.faces.ensure_lookup_table()
	uv = bm.loops.layers.uv.active

	data = []
	for f in bm.faces:
		c = face_color(img, uv, f, w, h, pixels)
		fc = obj.matrix_world @ f.calc_center_median()
		data.append((f, c, fc))

	strong_pts, strong_i = [], []
	for i, (f, c, fc) in enumerate(data):
		if c and is_strong_blue(c):
			strong_pts.append(fc.copy())
			strong_i.append(i)
	main_local = largest_spatial_component(strong_pts, 0.05)
	main_ids = {id(data[strong_i[i]][0]) for i in main_local}
	main_pts = [strong_pts[i] for i in main_local]
	center = sum(main_pts, Vector()) / len(main_pts)
	body_ymin = min(p.y for p in main_pts)
	body_ymax = max(p.y for p in main_pts)
	# Radius from upper body only (ignore seating-plane outliers / desk bleed)
	upper = [p for p in main_pts if p.y > body_ymin + 0.08]
	if len(upper) < 50:
		upper = main_pts
	rads = sorted(((p.x - center.x) ** 2 + (p.z - center.z) ** 2) ** 0.5 for p in upper)
	body_r = rads[int(0.92 * (len(rads) - 1))]
	print("CENTER", tuple(round(x, 3) for x in center), "ymin", round(body_ymin, 3), "r", round(body_r, 3))

	kd = kdtree.KDTree(len(main_pts))
	for i, p in enumerate(main_pts):
		kd.insert(p, i)
	kd.balance()

	drop, keep = [], 0
	for f, c, fc in data:
		_co, _i, dist = kd.find(fc)
		dx, dz = fc.x - center.x, fc.z - center.z
		rad = (dx * dx + dz * dz) ** 0.5
		n = (obj.matrix_world.to_3x3() @ f.normal).normalized()

		# furniture colors always go (even if clustered with body via texture bleed)
		if c and is_furniture(c):
			drop.append(f)
			continue

		# Desk slab: kill flat seating plane aggressively (keep only blue belly)
		near_seat = body_ymin - 0.05 <= fc.y <= body_ymin + 0.12
		if near_seat and abs(n.y) > 0.40:
			if c and is_strong_blue(c) and rad < body_r * 0.85:
				pass
			else:
				drop.append(f)
				continue
		# Warm peach/salmon desk top even if slightly tilted
		if near_seat and c is not None:
			r, g, b = c.x, c.y, c.z
			lum = (r + g + b) / 3.0
			if r > 0.35 and r >= b and (b - r) < 0.05 and lum > 0.30 and not is_strong_blue(c) and not is_dark_limb(c):
				drop.append(f)
				continue

		# Furniture side walls sticking out under body
		if fc.y < body_ymin + 0.04 and rad > body_r * 0.88:
			if not (c and is_dark_limb(c) and rad < body_r + 0.12):
				drop.append(f)
				continue

		if id(f) in main_ids:
			keep += 1
			continue
		if c is None:
			keep += 1
			continue

		# anything clearly below the body shell that isn't a yarn limb
		if fc.y < body_ymin - 0.01:
			if is_dark_limb(c) and rad < body_r + 0.08:
				keep += 1
				continue
			drop.append(f)
			continue

		if is_dark_limb(c) and dist < 0.22 and fc.y <= body_ymax + 0.02:
			keep += 1
			continue
		if is_mouth_pink(c) and dist < 0.12:
			keep += 1
			continue
		if is_teeth(c) and dist < 0.14:
			keep += 1
			continue
		if is_body_blue(c) and dist < 0.045:
			keep += 1
			continue

		drop.append(f)

	print("KEEP", keep, "DROP", len(drop), "TOTAL", len(data))
	if keep < 2000:
		raise RuntimeError("too aggressive")
	bmesh.ops.delete(bm, geom=drop, context="FACES")
	loose = [v for v in bm.verts if not v.link_faces]
	if loose:
		bmesh.ops.delete(bm, geom=loose, context="VERTS")
	bm.to_mesh(me)
	bm.free()
	me.update()

	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj
	bpy.ops.export_scene.gltf(filepath=OUT_PATH, export_format="GLB", use_selection=True, export_apply=True)
	print("wrote", OUT_PATH, "verts", len(me.vertices), "polys", len(me.polygons))


if __name__ == "__main__":
	main()
