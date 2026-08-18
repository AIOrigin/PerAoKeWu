#!/usr/bin/env python3
"""Blender headless: rig qingqing.glb (humanoid) + run/idle/jump/dance → qingqing_rigged.glb"""
from __future__ import annotations

import math
import shutil
from pathlib import Path

import bpy
from mathutils import Euler, Vector

CHAR_DIR = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters"
)
SRC = CHAR_DIR / "qingqing.glb"
OUT_RIGGED = CHAR_DIR / "qingqing_rigged.glb"
OUT_MAIN = CHAR_DIR / "qingqing.glb"
BACKUP = CHAR_DIR / "qingqing_unrigged_backup.glb"


def clear_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def world_bounds(obj: bpy.types.Object) -> tuple[Vector, Vector]:
    corners = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    mn = Vector((min(v.x for v in corners), min(v.y for v in corners), min(v.z for v in corners)))
    mx = Vector((max(v.x for v in corners), max(v.y for v in corners), max(v.z for v in corners)))
    return mn, mx


def make_bone(arm, name, head, tip, parent=None):
    b = arm.edit_bones.new(name)
    b.head = head
    b.tail = tip
    if parent and parent in arm.edit_bones:
        b.parent = arm.edit_bones[parent]
        b.use_connect = False
    return b


def build_biped(mn: Vector, mx: Vector) -> bpy.types.Object:
    size = mx - mn
    cx = (mn.x + mx.x) * 0.5
    cy = (mn.y + mx.y) * 0.5
    z0, z1 = mn.z, mx.z
    h = max(size.z, 0.01)
    w = max(size.x, 0.01)
    # 小人形：髋稍高、腿稍长
    hip_z = z0 + h * 0.48
    chest_z = z0 + h * 0.72
    neck_z = z0 + h * 0.86
    head_z = z0 + h * 0.96
    shoulder_x = w * 0.32
    hip_x = w * 0.14
    arm_len = h * 0.26
    forearm = h * 0.22
    thigh = h * 0.26
    y = cy

    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm_obj = bpy.context.active_object
    arm_obj.name = "QingqingArmature"
    arm = arm_obj.data
    for b in list(arm.edit_bones):
        arm.edit_bones.remove(b)

    make_bone(arm, "Root", Vector((cx, y, z0)), Vector((cx, y, z0 + h * 0.05)))
    make_bone(arm, "Hips", Vector((cx, y, hip_z - h * 0.03)), Vector((cx, y, hip_z + h * 0.03)), "Root")
    make_bone(arm, "Spine", Vector((cx, y, hip_z + h * 0.03)), Vector((cx, y, chest_z - h * 0.04)), "Hips")
    make_bone(arm, "Chest", Vector((cx, y, chest_z - h * 0.04)), Vector((cx, y, neck_z)), "Spine")
    make_bone(arm, "Neck", Vector((cx, y, neck_z)), Vector((cx, y, head_z - h * 0.03)), "Chest")
    make_bone(arm, "Head", Vector((cx, y, head_z - h * 0.03)), Vector((cx, y, z1 + h * 0.02)), "Neck")
    make_bone(arm, "UpperArm.L", Vector((cx + shoulder_x, y, chest_z)), Vector((cx + shoulder_x + arm_len * 0.12, y, chest_z - arm_len)), "Chest")
    make_bone(arm, "LowerArm.L", Vector((cx + shoulder_x + arm_len * 0.12, y, chest_z - arm_len)), Vector((cx + shoulder_x + arm_len * 0.2, y, chest_z - arm_len - forearm)), "UpperArm.L")
    make_bone(arm, "UpperArm.R", Vector((cx - shoulder_x, y, chest_z)), Vector((cx - shoulder_x - arm_len * 0.12, y, chest_z - arm_len)), "Chest")
    make_bone(arm, "LowerArm.R", Vector((cx - shoulder_x - arm_len * 0.12, y, chest_z - arm_len)), Vector((cx - shoulder_x - arm_len * 0.2, y, chest_z - arm_len - forearm)), "UpperArm.R")
    make_bone(arm, "Thigh.L", Vector((cx + hip_x, y, hip_z)), Vector((cx + hip_x, y, hip_z - thigh)), "Hips")
    make_bone(arm, "Shin.L", Vector((cx + hip_x, y, hip_z - thigh)), Vector((cx + hip_x, y, z0 + h * 0.02)), "Thigh.L")
    make_bone(arm, "Thigh.R", Vector((cx - hip_x, y, hip_z)), Vector((cx - hip_x, y, hip_z - thigh)), "Hips")
    make_bone(arm, "Shin.R", Vector((cx - hip_x, y, hip_z - thigh)), Vector((cx - hip_x, y, z0 + h * 0.02)), "Thigh.R")
    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


def join_meshes() -> bpy.types.Object:
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("no mesh")
    bpy.ops.object.select_all(action="DESELECT")
    for m in meshes:
        m.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    mesh = bpy.context.active_object
    mesh.name = "QingqingBody"
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return mesh


def bind_humanoid(mesh: bpy.types.Object, arm_obj: bpy.types.Object) -> None:
    """Proximity humanoid weights + Armature modifier (exports as Godot Skeleton3D+Skin)."""
    for g in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(g)
    for m in list(mesh.modifiers):
        if m.type == "ARMATURE":
            mesh.modifiers.remove(m)

    groups = {b.name: mesh.vertex_groups.new(name=b.name) for b in arm_obj.data.bones}
    mn, mx = world_bounds(mesh)
    size = mx - mn
    mw = mesh.matrix_world
    cx = (mn.x + mx.x) * 0.5
    cz0 = mn.z
    h = max(size.z, 0.01)
    half_w = max(size.x * 0.5, 1e-4)
    segs = [
        (b.name, arm_obj.matrix_world @ b.head_local, arm_obj.matrix_world @ b.tail_local)
        for b in arm_obj.data.bones
    ]

    def dist_ps(p, a, b):
        ab = b - a
        t = 0.0 if ab.length_squared < 1e-10 else max(0.0, min(1.0, (p - a).dot(ab) / ab.length_squared))
        return (p - (a + ab * t)).length

    falloff = max(size.length * 0.07, 0.05)
    for vi, v in enumerate(mesh.data.vertices):
        pw = mw @ v.co
        height_k = (pw.z - cz0) / h
        sx = max(-1.0, min(1.0, (pw.x - cx) / half_w))
        dists = sorted(((dist_ps(pw, a, b), n) for n, a, b in segs), key=lambda x: x[0])
        cands = dists[:4]
        weights = []
        for d, name in cands:
            w = math.exp(-(d * d) / (2.0 * falloff * falloff))
            if name in {"Root", "Hips", "Spine", "Chest", "Neck", "Head"}:
                if 0.32 < height_k < 0.88:
                    w *= 2.4
                else:
                    w *= 1.1
            if "Thigh" in name or "Shin" in name:
                if height_k > 0.55:
                    w *= 0.12
                elif (name.endswith(".L") and sx < -0.05) or (name.endswith(".R") and sx > 0.05):
                    w *= 0.15
                else:
                    w *= 2.4 if height_k < 0.48 else 1.2
            if "Arm" in name:
                if height_k < 0.48:
                    w *= 0.08
                elif (name.endswith(".L") and sx < -0.05) or (name.endswith(".R") and sx > 0.05):
                    w *= 0.2
                else:
                    w *= 2.0 if height_k > 0.55 else 0.8
            if name == "Head" and height_k > 0.82:
                w *= 3.0
            weights.append((name, w))
        # 保底躯干，防整模飞到手臂
        names = {n for n, _ in weights}
        for force in ("Hips", "Spine"):
            if force not in names and force in groups:
                weights.append((force, 0.25))
        s = sum(w for _, w in weights) or 1.0
        for name, w in weights:
            groups[name].add([vi], w / s, "REPLACE")

    mesh.parent = arm_obj
    mesh.matrix_parent_inverse = arm_obj.matrix_world.inverted()
    mod = mesh.modifiers.new("Armature", "ARMATURE")
    mod.object = arm_obj
    mod.use_vertex_groups = True
    print("  weights: humanoid proximity +", len(mesh.vertex_groups), "groups")


def key_pose(arm_obj, frame, pose):
    bpy.context.scene.frame_set(frame)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="POSE")
    for pb in arm_obj.pose.bones:
        pb.rotation_mode = "XYZ"
        if pb.name not in pose:
            pb.rotation_euler = Euler((0.0, 0.0, 0.0), "XYZ")
            pb.keyframe_insert(data_path="rotation_euler", frame=frame)
    for bname, eulers in pose.items():
        pb = arm_obj.pose.bones.get(bname)
        if not pb:
            continue
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = Euler(tuple(math.radians(a) for a in eulers), "XYZ")
        pb.keyframe_insert(data_path="rotation_euler", frame=frame)
    bpy.ops.object.mode_set(mode="OBJECT")


def ensure_action(arm_obj, name):
    if arm_obj.animation_data is None:
        arm_obj.animation_data_create()
    action = bpy.data.actions.new(name=name)
    arm_obj.animation_data.action = action
    return action


def stash_nla(arm_obj, name, action):
    if arm_obj.animation_data is None:
        arm_obj.animation_data_create()
    track = arm_obj.animation_data.nla_tracks.new()
    track.name = name
    start = int(action.frame_range[0]) if action.frame_range else 1
    track.strips.new(name, max(start, 1), action)
    arm_obj.animation_data.action = None


def make_biped_anims(arm_obj):
    action = ensure_action(arm_obj, "run")
    frames = {
        1: {
            "Hips": (3, 0, 0),
            "Spine": (2, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.L": (-26, 0, 0),
            "Shin.L": (22, 0, 0),
            "Thigh.R": (22, 0, 0),
            "Shin.R": (32, 0, 0),
            "UpperArm.L": (20, -8, 0),
            "LowerArm.L": (16, 0, 0),
            "UpperArm.R": (-22, 8, 0),
            "LowerArm.R": (24, 0, 0),
        },
        7: {
            "Hips": (2, 0, 0),
            "Spine": (1, 0, 0),
            "Thigh.L": (-6, 0, 0),
            "Shin.L": (12, 0, 0),
            "Thigh.R": (6, 0, 0),
            "Shin.R": (14, 0, 0),
            "UpperArm.L": (4, -8, 0),
            "LowerArm.L": (12, 0, 0),
            "UpperArm.R": (-4, 8, 0),
            "LowerArm.R": (12, 0, 0),
        },
        13: {
            "Hips": (3, 0, 0),
            "Spine": (2, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.L": (22, 0, 0),
            "Shin.L": (32, 0, 0),
            "Thigh.R": (-26, 0, 0),
            "Shin.R": (22, 0, 0),
            "UpperArm.L": (-22, -8, 0),
            "LowerArm.L": (24, 0, 0),
            "UpperArm.R": (20, 8, 0),
            "LowerArm.R": (16, 0, 0),
        },
        19: {
            "Hips": (2, 0, 0),
            "Spine": (1, 0, 0),
            "Thigh.L": (6, 0, 0),
            "Shin.L": (14, 0, 0),
            "Thigh.R": (-6, 0, 0),
            "Shin.R": (12, 0, 0),
            "UpperArm.L": (-4, -8, 0),
            "LowerArm.L": (12, 0, 0),
            "UpperArm.R": (4, 8, 0),
            "LowerArm.R": (12, 0, 0),
        },
        25: None,
    }
    for f, pose in frames.items():
        key_pose(arm_obj, f, frames[1] if pose is None else pose)
    action.use_cyclic = True
    stash_nla(arm_obj, "run", action)

    action = ensure_action(arm_obj, "idle")
    base = {
        "Hips": (0, 0, 0),
        "Spine": (0, 0, 0),
        "Thigh.L": (3, 0, 0),
        "Shin.L": (5, 0, 0),
        "Thigh.R": (3, 0, 0),
        "Shin.R": (5, 0, 0),
        "UpperArm.L": (6, -8, 0),
        "LowerArm.L": (10, 0, 0),
        "UpperArm.R": (6, 8, 0),
        "LowerArm.R": (10, 0, 0),
    }
    up = dict(base)
    up["Spine"] = (2, 0, 0)
    key_pose(arm_obj, 1, base)
    key_pose(arm_obj, 20, up)
    key_pose(arm_obj, 40, base)
    action.use_cyclic = True
    stash_nla(arm_obj, "idle", action)

    action = ensure_action(arm_obj, "jump")
    key_pose(arm_obj, 1, {"Hips": (-3, 0, 0), "Thigh.L": (16, 0, 0), "Shin.L": (26, 0, 0), "Thigh.R": (16, 0, 0), "Shin.R": (26, 0, 0), "UpperArm.L": (-20, -10, 0), "UpperArm.R": (-20, 10, 0)})
    key_pose(arm_obj, 8, {"Hips": (6, 0, 0), "Thigh.L": (-10, 0, 0), "Shin.L": (10, 0, 0), "Thigh.R": (-10, 0, 0), "Shin.R": (10, 0, 0), "UpperArm.L": (-36, -8, 0), "UpperArm.R": (-36, 8, 0)})
    key_pose(arm_obj, 16, {"Hips": (0, 0, 0), "Thigh.L": (4, 0, 0), "Shin.L": (12, 0, 0), "Thigh.R": (4, 0, 0), "Shin.R": (12, 0, 0), "UpperArm.L": (-6, -8, 0), "UpperArm.R": (-6, 8, 0)})
    stash_nla(arm_obj, "jump", action)

    idle = next((a for a in bpy.data.actions if a.name == "idle"), None)
    if idle:
        a = idle.copy()
        a.name = "dance"
        track = arm_obj.animation_data.nla_tracks.new()
        track.name = "dance"
        track.strips.new("dance", 1, a)


def export_selected(path: Path) -> None:
    kwargs = dict(
        filepath=str(path),
        export_format="GLB",
        export_animations=True,
        export_skins=True,
        export_morph=False,
        export_apply=False,
        export_yup=True,
        use_selection=True,
    )
    try:
        bpy.ops.export_scene.gltf(**kwargs, export_animation_mode="ACTIONS")
    except TypeError:
        try:
            bpy.ops.export_scene.gltf(**kwargs, export_animation_mode="NLA_TRACKS")
        except TypeError:
            bpy.ops.export_scene.gltf(**kwargs)


def main() -> None:
    # 始终从无骨骼备份开绑，避免二次导入坏掉的 empties 层级
    src = BACKUP if BACKUP.exists() else SRC
    if not src.exists():
        raise SystemExit(f"missing {src}")
    if not BACKUP.exists():
        shutil.copy2(SRC, BACKUP)
        print("backed up →", BACKUP.name)
        src = BACKUP

    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(src))
    # 清掉误导入的空物体/旧骨架
    for o in list(bpy.data.objects):
        if o.type in {"EMPTY", "ARMATURE"}:
            bpy.data.objects.remove(o, do_unlink=True)
    mesh = join_meshes()
    mn, mx = world_bounds(mesh)
    print("source", src.name, "bounds", tuple(round(x, 3) for x in (mx - mn)), "verts", len(mesh.data.vertices))
    arm = build_biped(mn, mx)
    bind_humanoid(mesh, arm)
    assert any(m.type == "ARMATURE" for m in mesh.modifiers), "missing Armature modifier"
    assert len(mesh.vertex_groups) >= 8, f"too few vertex groups: {len(mesh.vertex_groups)}"
    print("  mesh parent=", mesh.parent.name if mesh.parent else None, "groups=", len(mesh.vertex_groups))
    bpy.context.scene.render.fps = 24
    make_biped_anims(arm)

    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = arm
    export_selected(OUT_RIGGED)
    shutil.copy2(OUT_RIGGED, OUT_MAIN)
    print("WROTE", OUT_RIGGED.name, OUT_RIGGED.stat().st_size)
    print("WROTE", OUT_MAIN.name)


if __name__ == "__main__":
    main()
