#!/usr/bin/env python3
"""Fix capy/cow facing (+Z in Godot) and rebind legs so run/idle actually move."""
from __future__ import annotations

import math
import os
import sys
from pathlib import Path

import bpy
from mathutils import Euler, Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import rig_capybara_tripo as capy_rig
import rig_cow_tripo as cow_rig
import rig_qingqing as qq

argv = sys.argv[sys.argv.index("--") + 1 :]
src_path, dst_path, kind = argv[0], argv[1], argv[2]


def _activate(obj) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    if obj.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")


def _world_pts(mesh) -> list[Vector]:
    mw = mesh.matrix_world
    return [mw @ v.co for v in mesh.data.vertices]


def _snout_xy(mesh) -> Vector:
    pts = _world_pts(mesh)
    z0 = min(p.z for p in pts)
    z1 = max(p.z for p in pts)
    cx = sum(p.x for p in pts) / len(pts)
    cy = sum(p.y for p in pts) / len(pts)
    top = [p for p in pts if p.z > z0 + (z1 - z0) * 0.58]
    if not top:
        top = pts
    far = max(top, key=lambda p: (p.x - cx) ** 2 + (p.y - cy) ** 2)
    return Vector((far.x - cx, far.y - cy, 0.0))


def _rotate_rig_around_z(arm, mesh, delta: float) -> None:
    if abs(delta) < math.radians(6.0):
        print("ROTATE skip", round(math.degrees(delta), 1))
        return
    R = Euler((0.0, 0.0, delta), "XYZ").to_matrix()
    mw = mesh.matrix_world.copy()
    mesh.parent = None
    mesh.matrix_world = mw
    for v in mesh.data.vertices:
        v.co = R @ v.co
    mesh.data.update()
    _activate(arm)
    bpy.ops.object.mode_set(mode="EDIT")
    for bone in arm.data.edit_bones:
        bone.head = R @ bone.head
        bone.tail = R @ bone.tail
        if bone.use_connect:
            continue
    bpy.ops.object.mode_set(mode="OBJECT")
    mesh.parent = arm
    mesh.matrix_parent_inverse = arm.matrix_world.inverted()
    print("ROTATE_Z", round(math.degrees(delta), 1), "deg")


def _face_neg_y(arm, mesh) -> None:
    off = _snout_xy(mesh)
    ang = math.atan2(off.y, off.x)
    delta = -math.pi * 0.5 - ang
    while delta > math.pi:
        delta -= 2.0 * math.pi
    while delta < -math.pi:
        delta += 2.0 * math.pi
    print("snout_before", tuple(round(x, 3) for x in off), "delta_deg", round(math.degrees(delta), 1))
    _rotate_rig_around_z(arm, mesh, delta)
    off2 = _snout_xy(mesh)
    print("snout_after", tuple(round(x, 3) for x in off2))


def _clear_actions(arm) -> None:
    if arm.animation_data:
        for track in list(arm.animation_data.nla_tracks):
            arm.animation_data.nla_tracks.remove(track)
        arm.animation_data.action = None
    for action in list(bpy.data.actions):
        bpy.data.actions.remove(action)


def _reset_pose(arm) -> None:
    _activate(arm)
    bpy.ops.object.mode_set(mode="POSE")
    bpy.ops.pose.select_all(action="SELECT")
    bpy.ops.pose.transforms_clear()
    bpy.ops.object.mode_set(mode="OBJECT")


def _auto_weights(arm, mesh) -> None:
    for g in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(g)
    for mod in list(mesh.modifiers):
        if mod.type == "ARMATURE":
            mesh.modifiers.remove(mod)
    mesh.parent = None
    bpy.ops.object.select_all(action="DESELECT")
    mesh.select_set(True)
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.parent_set(type="ARMATURE_AUTO")
    print("AUTO_WEIGHTS groups", [g.name for g in mesh.vertex_groups])


def _count_leg_weights(mesh, needles: tuple[str, ...]) -> int:
    n = 0
    groups = [g for g in mesh.vertex_groups if any(k in g.name for k in needles)]
    for g in groups:
        for i in range(len(mesh.data.vertices)):
            try:
                if g.weight(i) > 0.04:
                    n += 1
                    break
            except RuntimeError:
                pass
        else:
            continue
    # count verts on any leg group
    hit = 0
    for i in range(len(mesh.data.vertices)):
        for g in groups:
            try:
                if g.weight(i) > 0.04:
                    hit += 1
                    break
            except RuntimeError:
                pass
    print("LEG_VERTS", hit, "groups", [g.name for g in groups])
    return hit


def _ensure_arm_mod(arm, mesh) -> None:
    has = False
    for mod in mesh.modifiers:
        if mod.type == "ARMATURE":
            mod.object = arm
            mod.use_vertex_groups = True
            has = True
    if not has:
        mod = mesh.modifiers.new("Armature", "ARMATURE")
        mod.object = arm
        mod.use_vertex_groups = True
    mesh.parent = arm


def _export(path: str) -> None:
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
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
    )
    try:
        bpy.ops.export_scene.gltf(**kw, export_all_influences=True, export_morph=True)
    except TypeError:
        bpy.ops.export_scene.gltf(**kw)
    print("WROTE", path, os.path.getsize(path) if os.path.isfile(path) else 0)


bpy.ops.wm.read_factory_settings(use_empty=True)
print("IMPORT", src_path, kind)
bpy.ops.import_scene.gltf(filepath=src_path)

for obj in list(bpy.data.objects):
    if obj.type == "MESH" and obj.name.startswith("Icosphere") and len(obj.data.vertices) <= 80:
        bpy.data.objects.remove(obj, do_unlink=True)

meshes = [o for o in bpy.data.objects if o.type == "MESH" and len(o.data.vertices) >= 200]
arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
if not meshes or not arms:
    raise RuntimeError("missing mesh/armature")
mesh = max(meshes, key=lambda o: len(o.data.vertices))
arm = mesh.parent if mesh.parent and mesh.parent.type == "ARMATURE" else arms[0]

_reset_pose(arm)
_face_neg_y(arm, mesh)
_clear_actions(arm)

if kind == "capy":
    mn, mx = capy_rig.world_bounds_objs([mesh])
    capy_rig.bind_quadruped_legs(mesh, arm, mn, mx)
    legs = _count_leg_weights(mesh, ("Thigh.", "Shin."))
    if legs < 200:
        print("FALLBACK AUTO WEIGHTS")
        _auto_weights(arm, mesh)
        mn, mx = capy_rig.world_bounds_objs([mesh])
        capy_rig.bind_quadruped_legs(mesh, arm, mn, mx)
    capy_rig.make_capy_anims(arm)
else:
    _auto_weights(arm, mesh)
    cow_rig.boost_leg_weights(mesh)
    _ensure_arm_mod(arm, mesh)
    _count_leg_weights(mesh, ("Thigh.", "Shin."))
    cow_rig.make_cow_anims(arm)

_ensure_arm_mod(arm, mesh)
print("snout_final", tuple(round(x, 3) for x in _snout_xy(mesh)))
_export(dst_path)
