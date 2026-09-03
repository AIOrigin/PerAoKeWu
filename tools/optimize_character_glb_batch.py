#!/usr/bin/env python3
"""Optimize character GLBs for mobile: shrink textures; light decimate only if no armature.

Preserves animations/armatures. Does NOT join skinned meshes.
"""
from __future__ import annotations

import os
import shutil
import sys

import bpy

DEFAULT_MAX_TEX = 1024
# Only decimate static (no armature) meshes down toward this
STATIC_TARGET_TRIS = 12000
TOLERANCE = 0.2


def _argv_after_double_dash() -> list[str]:
	if "--" in sys.argv:
		return sys.argv[sys.argv.index("--") + 1 :]
	return []


def parse_args() -> dict:
	args = _argv_after_double_dash()
	out = {"list_file": "", "backup_dir": "", "max_tex": DEFAULT_MAX_TEX}
	i = 0
	while i < len(args):
		a = args[i]
		if a == "--list-file" and i + 1 < len(args):
			out["list_file"] = args[i + 1]
			i += 2
		elif a == "--backup-dir" and i + 1 < len(args):
			out["backup_dir"] = args[i + 1]
			i += 2
		elif a == "--max-tex" and i + 1 < len(args):
			out["max_tex"] = int(args[i + 1])
			i += 2
		else:
			i += 1
	return out


def clear_scene() -> None:
	bpy.ops.object.select_all(action="SELECT")
	bpy.ops.object.delete(use_global=False)
	for block in (
		bpy.data.meshes,
		bpy.data.materials,
		bpy.data.images,
		bpy.data.armatures,
		bpy.data.actions,
	):
		for item in list(block):
			block.remove(item)


def has_armature() -> bool:
	return any(o.type == "ARMATURE" for o in bpy.data.objects)


def mesh_has_armature_mod(obj: bpy.types.Object) -> bool:
	for mod in obj.modifiers:
		if mod.type == "ARMATURE":
			return True
	return False


def tri_count(obj: bpy.types.Object) -> int:
	if obj.type != "MESH" or obj.data is None:
		return 0
	return len(obj.data.polygons)


def shrink_images(max_dim: int) -> int:
	changed = 0
	for img in list(bpy.data.images):
		if img.size[0] <= 0 or img.size[1] <= 0:
			continue
		w, h = int(img.size[0]), int(img.size[1])
		if max(w, h) <= max_dim:
			continue
		scale = max_dim / float(max(w, h))
		nw = max(1, int(round(w * scale)))
		nh = max(1, int(round(h * scale)))
		img.scale(nw, nh)
		changed += 1
	return changed


def apply_decimate(obj: bpy.types.Object, ratio: float) -> None:
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj
	mod = obj.modifiers.new(name="Decimate", type="DECIMATE")
	mod.decimate_type = "COLLAPSE"
	mod.ratio = max(0.001, min(1.0, ratio))
	mod.use_collapse_triangulate = True
	bpy.ops.object.modifier_apply(modifier=mod.name)


def light_decimate_static(target: int) -> tuple[int, int]:
	"""Decimate only meshes without armature modifiers. Returns (before, after)."""
	before = sum(tri_count(o) for o in bpy.data.objects if o.type == "MESH")
	for obj in list(bpy.data.objects):
		if obj.type != "MESH":
			continue
		if mesh_has_armature_mod(obj):
			continue
		# skip if parented to armature in a typical skin setup
		if obj.find_armature() is not None:
			continue
		n = tri_count(obj)
		if n <= target:
			continue
		apply_decimate(obj, target / float(n))
	after = sum(tri_count(o) for o in bpy.data.objects if o.type == "MESH")
	return before, after


def export_glb(path: str) -> None:
	# Blender 5.x: export_skins is boolean (not "ALL"/"VISIBLE")
	bpy.ops.export_scene.gltf(
		filepath=path,
		export_format="GLB",
		use_selection=False,
		export_apply=False,  # keep armature modifiers / skins
		export_animations=True,
		export_materials="EXPORT",
		export_image_format="JPEG",
		export_jpeg_quality=75,
		export_image_quality=75,
		export_skins=True,
		export_morph=True,
	)


def process_one(path: str, backup_dir: str, max_tex: int) -> str:
	abs_path = os.path.abspath(path)
	if not os.path.isfile(abs_path):
		return f"SKIP missing: {path}"

	before_size = os.path.getsize(abs_path)
	if backup_dir:
		os.makedirs(backup_dir, exist_ok=True)
		# Keep path relative to route_levels for unambiguous restore
		norm = abs_path.replace("\\", "/")
		marker = "/assets/maps/route_levels/"
		if marker in norm:
			rel = norm.split(marker, 1)[1]
		else:
			rel = os.path.basename(abs_path)
		bak = os.path.join(backup_dir, rel.replace("/", os.sep))
		os.makedirs(os.path.dirname(bak), exist_ok=True)
		if not os.path.isfile(bak):
			shutil.copy2(abs_path, bak)

	clear_scene()
	bpy.ops.import_scene.gltf(filepath=abs_path)
	skinned = has_armature() or any(
		mesh_has_armature_mod(o) or (o.type == "MESH" and o.find_armature() is not None)
		for o in bpy.data.objects
	)
	tris_before = sum(tri_count(o) for o in bpy.data.objects if o.type == "MESH")
	tex_n = shrink_images(max_tex)
	decim_note = "skip_decimate_skinned"
	tris_after = tris_before
	if not skinned:
		b, a = light_decimate_static(STATIC_TARGET_TRIS)
		tris_before, tris_after = b, a
		decim_note = "static_decimate"
	export_glb(abs_path)
	after_size = os.path.getsize(abs_path)
	return (
		f"OK {path} | {decim_note} tris {tris_before}->{tris_after} | "
		f"tex_resized={tex_n} | "
		f"{before_size/1024/1024:.1f}MB -> {after_size/1024/1024:.1f}MB"
	)


def main() -> None:
	cfg = parse_args()
	list_file = cfg["list_file"]
	if not list_file or not os.path.isfile(list_file):
		raise SystemExit("Need --list-file")
	with open(list_file, "r", encoding="utf-8") as f:
		paths = [ln.strip() for ln in f if ln.strip() and not ln.strip().startswith("#")]
	print(f"Character optimize {len(paths)} | max_tex={cfg['max_tex']}")
	for p in paths:
		try:
			print(process_one(p, cfg["backup_dir"], cfg["max_tex"]), flush=True)
		except Exception as e:
			print(f"FAIL {p}: {e}", flush=True)


main()
