#!/usr/bin/env python3
"""Rebuild capy armature so legs point down, then write a proper trot.

The sealed GLB kept a sideways donor skeleton (thighs along +Y). Rotating
those bones made a paddle-run. This keeps the sealed mesh, builds a Z-up
quadruped, rebinds, and exports.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

import bpy
from mathutils import Vector

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rig_capybara_tripo as capy  # noqa: E402

argv = sys.argv[sys.argv.index("--") + 1 :]
src_path, dst_path = argv[0], argv[1]


def _export(path: str) -> None:
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.data.objects:
        obj.select_set(True)
    kw = dict(
        filepath=path,
        export_format="GLB",
        export_extras=False,
        export_yup=True,
        export_apply=False,
        export_animations=True,
        export_skins=True,
        export_texcoords=True,
        export_normals=True,
        export_materials="EXPORT",
        export_image_format="AUTO",
        export_cameras=False,
        export_lights=False,
        use_selection=False,
    )
    try:
        bpy.ops.export_scene.gltf(**kw, export_all_influences=True, export_morph=True)
    except TypeError:
        bpy.ops.export_scene.gltf(**kw)
    print("WROTE", path, os.path.getsize(path) if os.path.isfile(path) else 0)


bpy.ops.wm.read_factory_settings(use_empty=True)
print("REBUILD", src_path)
bpy.ops.import_scene.gltf(filepath=src_path)

meshes = [o for o in bpy.data.objects if o.type == "MESH" and len(o.data.vertices) >= 200]
if not meshes:
    raise RuntimeError("no mesh")
mesh = max(meshes, key=lambda o: len(o.data.vertices))
mesh.parent = None
bpy.ops.object.select_all(action="DESELECT")
mesh.select_set(True)
bpy.context.view_layer.objects.active = mesh
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

for obj in list(bpy.data.objects):
    if obj.type == "ARMATURE":
        bpy.data.objects.remove(obj, do_unlink=True)
for arm in list(bpy.data.armatures):
    bpy.data.armatures.remove(arm)
for action in list(bpy.data.actions):
    bpy.data.actions.remove(action)

mn, mx = capy.world_bounds_objs([mesh])
print("bounds", tuple(round(x, 3) for x in mn), tuple(round(x, 3) for x in mx), "span", tuple(round(x, 3) for x in (mx - mn)))
arm = capy.build_quadruped(mn, mx)

bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode="EDIT")
for b in arm.data.edit_bones:
    if b.name.startswith("Thigh") or b.name.startswith("Shin"):
        b.align_roll(Vector((1.0, 0.0, 0.0)))
bpy.ops.object.mode_set(mode="OBJECT")

capy.bind_quadruped_legs(mesh, arm, mn, mx)
capy.make_capy_anims(arm)
print("bones")
bpy.ops.object.mode_set(mode="EDIT")
for b in arm.data.edit_bones:
    d = b.tail - b.head
    print(" ", b.name, "vec", tuple(round(x, 3) for x in d))
bpy.ops.object.mode_set(mode="OBJECT")
print("actions", [a.name for a in bpy.data.actions])
_export(dst_path)
