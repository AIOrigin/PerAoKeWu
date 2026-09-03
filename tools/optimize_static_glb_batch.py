#!/usr/bin/env python3
"""Headless Blender: decimate + shrink textures for shipping static GLBs.

Usage:
  blender -b -P tools/optimize_static_glb_batch.py -- --list-file PATH --backup-dir PATH

Expects --list-file with one absolute or repo-relative .glb path per line.
"""
from __future__ import annotations

import os
import shutil
import sys

import bpy

# Defaults tuned for mobile midground / props
DEFAULT_TARGET_TRIS = 10000
DEFAULT_MAX_TEX = 1024
TOLERANCE = 0.15


def _argv_after_double_dash() -> list[str]:
	if "--" in sys.argv:
		return sys.argv[sys.argv.index("--") + 1 :]
	return []


def parse_args() -> dict:
	args = _argv_after_double_dash()
	out = {
		"list_file": "",
		"backup_dir": "",
		"target_tris": DEFAULT_TARGET_TRIS,
		"max_tex": DEFAULT_MAX_TEX,
	}
	i = 0
	while i < len(args):
		a = args[i]
		if a == "--list-file" and i + 1 < len(args):
			out["list_file"] = args[i + 1]
			i += 2
		elif a == "--backup-dir" and i + 1 < len(args):
			out["backup_dir"] = args[i + 1]
			i += 2
		elif a == "--target-tris" and i + 1 < len(args):
			out["target_tris"] = int(args[i + 1])
			i += 2
		elif a == "--max-tex" and i + 1 < len(args):
			out["max_tex"] = int(args[i + 1])
			i += 2
		else:
			i += 1
	return out


def tri_count(obj: bpy.types.Object) -> int:
	if obj.type != "MESH" or obj.data is None:
		return 0
	return len(obj.data.polygons)


def total_tris() -> int:
	return sum(tri_count(o) for o in bpy.data.objects if o.type == "MESH")


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


def import_glb(path: str) -> list[bpy.types.Object]:
	before = set(bpy.data.objects)
	bpy.ops.import_scene.gltf(filepath=path)
	after = set(bpy.data.objects)
	imported = [o for o in after - before if o.type == "MESH"]
	if not imported:
		imported = [o for o in bpy.data.objects if o.type == "MESH"]
	return imported


def join_meshes(meshes: list[bpy.types.Object]) -> bpy.types.Object:
	bpy.ops.object.select_all(action="DESELECT")
	for obj in meshes:
		obj.select_set(True)
	bpy.context.view_layer.objects.active = meshes[0]
	if len(meshes) > 1:
		bpy.ops.object.join()
	joined = bpy.context.view_layer.objects.active
	return joined


def apply_decimate(obj: bpy.types.Object, ratio: float) -> None:
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj
	mod = obj.modifiers.new(name="Decimate", type="DECIMATE")
	mod.decimate_type = "COLLAPSE"
	mod.ratio = max(0.001, min(1.0, ratio))
	mod.use_collapse_triangulate = True
	bpy.ops.object.modifier_apply(modifier=mod.name)


def decimate_to_target(obj: bpy.types.Object, target: int) -> int:
	start = tri_count(obj)
	if start <= target:
		return start
	ratio = target / float(start)
	apply_decimate(obj, ratio)
	current = tri_count(obj)
	if current > target * (1.0 + TOLERANCE):
		apply_decimate(obj, target / float(max(1, current)))
		current = tri_count(obj)
	return current


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


def export_glb(path: str) -> None:
	bpy.ops.object.select_all(action="SELECT")
	bpy.ops.export_scene.gltf(
		filepath=path,
		export_format="GLB",
		use_selection=False,
		export_apply=True,
		export_materials="EXPORT",
		export_image_format="JPEG",
		export_jpeg_quality=80,
	)


def process_one(path: str, backup_dir: str, target_tris: int, max_tex: int) -> str:
	abs_path = os.path.abspath(path)
	if not os.path.isfile(abs_path):
		return f"SKIP missing: {path}"

	before_size = os.path.getsize(abs_path)
	if backup_dir:
		os.makedirs(backup_dir, exist_ok=True)
		# keep relative-ish unique name
		safe = abs_path.replace(":", "").replace("\\", "__").replace("/", "__")
		bak = os.path.join(backup_dir, os.path.basename(safe))
		if not os.path.isfile(bak):
			shutil.copy2(abs_path, bak)

	clear_scene()
	meshes = import_glb(abs_path)
	if not meshes:
		return f"FAIL no mesh: {path}"

	tris_before = total_tris()
	obj = join_meshes(meshes) if len(meshes) >= 1 else meshes[0]
	tris_mid = decimate_to_target(obj, target_tris)
	tex_n = shrink_images(max_tex)
	export_glb(abs_path)
	after_size = os.path.getsize(abs_path)
	return (
		f"OK {path} | tris {tris_before}->{tris_mid} | "
		f"tex_resized={tex_n} | "
		f"{before_size/1024/1024:.1f}MB -> {after_size/1024/1024:.1f}MB"
	)


def main() -> None:
	cfg = parse_args()
	list_file = cfg["list_file"]
	if not list_file or not os.path.isfile(list_file):
		raise SystemExit("Need --list-file with existing path")

	with open(list_file, "r", encoding="utf-8") as f:
		paths = [ln.strip() for ln in f if ln.strip() and not ln.strip().startswith("#")]

	print(f"Batch optimize {len(paths)} GLBs | target_tris={cfg['target_tris']} max_tex={cfg['max_tex']}")
	for p in paths:
		try:
			msg = process_one(p, cfg["backup_dir"], cfg["target_tris"], cfg["max_tex"])
			print(msg, flush=True)
		except Exception as e:
			print(f"FAIL {p}: {e}", flush=True)


main()
