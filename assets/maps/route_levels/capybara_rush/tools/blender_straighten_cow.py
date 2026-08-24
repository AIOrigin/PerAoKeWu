#!/usr/bin/env python3
"""Straighten cow mesh (cancel forward lean) then rebuild biped + small-stride run."""
from __future__ import annotations

import math
import os
import sys
from pathlib import Path

import bpy
from mathutils import Euler, Vector

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import batch_prepare_glb_resouses as biped  # noqa: E402
import rig_cow_tripo as cow  # noqa: E402
import rig_qingqing as qq  # noqa: E402

argv = sys.argv[sys.argv.index("--") + 1 :]
src_path, dst_path = argv[0], argv[1]


def _pts(mesh) -> list[Vector]:
    mw = mesh.matrix_world
    return [mw @ v.co for v in mesh.data.vertices]


def _avg(ps: list[Vector]) -> Vector:
    return sum(ps, Vector()) / len(ps)


def straighten(mesh) -> None:
    pts = _pts(mesh)
    z0 = min(p.z for p in pts)
    z1 = max(p.z for p in pts)
    h = z1 - z0
    feet = [p for p in pts if p.z < z0 + h * 0.10]
    chest = [p for p in pts if z0 + h * 0.62 < p.z < z0 + h * 0.82]
    head = [p for p in pts if p.z > z0 + h * 0.82]
    if not feet or not chest:
        print("straighten skip")
        return
    f = _avg(feet)
    c = _avg(chest)
    hd = _avg(head) if head else c
    dy = hd.y - f.y
    dz = max(hd.z - f.z, 1e-4)
    # 头顶比脚更靠 -Y（脸）= 前倾。绕 X 负向把胸拉回脚上方。
    lean = math.atan2(dy, dz)
    extra = math.radians(-8.0)  # 俯视相机里再收一点，避免看起来还在探身
    rot = -lean + extra
    print(
        "lean_deg",
        round(math.degrees(lean), 2),
        "apply_deg",
        round(math.degrees(rot), 2),
        "feetY",
        round(f.y, 3),
        "chestY",
        round(c.y, 3),
        "headY",
        round(hd.y, 3),
    )
    R = Euler((rot, 0.0, 0.0), "XYZ").to_matrix()
    pivot = Vector((f.x, f.y, f.z))
    for v in mesh.data.vertices:
        world = mesh.matrix_world @ v.co
        world = pivot + R @ (world - pivot)
        v.co = mesh.matrix_world.inverted() @ world
    mesh.data.update()
    cow.center_mesh(mesh)
    pts2 = _pts(mesh)
    z0 = min(p.z for p in pts2)
    z1 = max(p.z for p in pts2)
    h = z1 - z0
    feet = [p for p in pts2 if p.z < z0 + h * 0.10]
    head = [p for p in pts2 if p.z > z0 + h * 0.82]
    print(
        "after feetY",
        round(_avg(feet).y, 3),
        "headY",
        round(_avg(head).y, 3) if head else None,
        "dY",
        round((_avg(head).y - _avg(feet).y) if head else 0.0, 3),
    )


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
        bpy.ops.export_scene.gltf(**kw, export_all_influences=True)
    except TypeError:
        bpy.ops.export_scene.gltf(**kw)
    print("WROTE", path, os.path.getsize(path) if os.path.isfile(path) else 0)


bpy.ops.wm.read_factory_settings(use_empty=True)
print("STRAIGHTEN", src_path)
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

straighten(mesh)
mn, mx = biped.world_bounds_objs([mesh])
print("bounds", tuple(round(x, 3) for x in (mx - mn)))
arm = biped.build_biped(mn, mx)
arm.name = "CowArmature"
arm.data.name = "CowArmature"
qq.bind_humanoid(mesh, arm)
cow.boost_leg_weights(mesh)
bpy.context.view_layer.objects.active = mesh
bpy.ops.object.vertex_group_normalize_all(lock_active=False)
bpy.context.scene.render.fps = 24
cow.make_cow_anims(arm)
_export(dst_path)
