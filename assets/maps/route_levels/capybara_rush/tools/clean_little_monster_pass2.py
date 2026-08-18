#!/usr/bin/env python3
"""Second pass: drop floating props / tiny bugs near little_monster."""
import bpy
import bmesh
import shutil
from mathutils import Vector

IN_PATH = "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/models/characters/little_monster.glb"
OUT_PATH = IN_PATH


def clear_scene():
	for o in list(bpy.data.objects):
		bpy.data.objects.remove(o, do_unlink=True)
	for m in list(bpy.data.meshes):
		bpy.data.meshes.remove(m)


def aabb(obj):
	coords = [obj.matrix_world @ v.co for v in obj.data.vertices]
	xs = [c.x for c in coords]
	ys = [c.y for c in coords]
	zs = [c.z for c in coords]
	mn = Vector((min(xs), min(ys), min(zs)))
	mx = Vector((max(xs), max(ys), max(zs)))
	return mn, mx, (mn + mx) * 0.5, mx - mn


def main():
	clear_scene()
	bpy.ops.import_scene.gltf(filepath=IN_PATH)
	obj = [o for o in bpy.context.scene.objects if o.type == "MESH"][0]
	bpy.context.view_layer.objects.active = obj
	obj.select_set(True)

	# Merge by distance a bit so limbs stay connected to body if nearly touching
	bpy.ops.object.mode_set(mode="EDIT")
	bpy.ops.mesh.select_all(action="SELECT")
	bpy.ops.mesh.remove_doubles(threshold=0.004)
	bpy.ops.mesh.separate(type="LOOSE")
	bpy.ops.object.mode_set(mode="OBJECT")

	parts = [o for o in bpy.context.scene.objects if o.type == "MESH"]
	print("PARTS", len(parts))
	ranked = sorted(parts, key=lambda o: len(o.data.vertices), reverse=True)
	main_body = ranked[0]
	mn, mx, center, size = aabb(main_body)
	print("MAIN", main_body.name, "v", len(main_body.data.vertices), "size", tuple(round(x, 3) for x in size))

	keep = [main_body]
	drop = []
	for p in ranked[1:]:
		_mn, _mx, c, sz = aabb(p)
		vcount = len(p.data.vertices)
		# distance from main body center (XZ) and vertical
		dx = c.x - center.x
		dz = c.z - center.z
		rad = (dx * dx + dz * dz) ** 0.5
		# thin dark limbs: small volume, elongated, near underside
		is_limbish = (
			vcount < 2500
			and max(sz.x, sz.z) < 0.12
			and sz.y > 0.05
			and rad < 0.28
			and c.y < center.y + 0.05
		)
		# tiny floating props
		is_prop = vcount < 1500 and (rad > 0.16 or sz.length < 0.12)
		if is_limbish and not is_prop:
			keep.append(p)
			print("KEEP_LIMB", p.name, "v", vcount, "rad", round(rad, 3), "sz", tuple(round(x, 3) for x in sz))
		elif vcount > 800 and rad < 0.15 and sz.y > 0.15:
			# chunk of body that got separated
			keep.append(p)
			print("KEEP_CHUNK", p.name, "v", vcount, "rad", round(rad, 3))
		else:
			drop.append(p)
			print("DROP", p.name, "v", vcount, "rad", round(rad, 3), "sz", tuple(round(x, 3) for x in sz))

	for p in drop:
		bpy.data.objects.remove(p, do_unlink=True)

	keep = [o for o in bpy.context.scene.objects if o.type == "MESH"]
	bpy.ops.object.select_all(action="DESELECT")
	for p in keep:
		p.select_set(True)
	bpy.context.view_layer.objects.active = keep[0]
	if len(keep) > 1:
		bpy.ops.object.join()

	final = [o for o in bpy.context.scene.objects if o.type == "MESH"][0]
	print("FINAL verts", len(final.data.vertices), "polys", len(final.data.polygons))

	bpy.ops.object.select_all(action="DESELECT")
	final.select_set(True)
	bpy.context.view_layer.objects.active = final
	bpy.ops.export_scene.gltf(
		filepath=OUT_PATH,
		export_format="GLB",
		use_selection=True,
		export_apply=True,
	)
	print("wrote", OUT_PATH)


if __name__ == "__main__":
	main()
