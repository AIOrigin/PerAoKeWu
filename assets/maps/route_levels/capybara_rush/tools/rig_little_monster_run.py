#!/usr/bin/env python3
"""Blender headless: auto-rig little_monster.glb + create run/idle/jump, export little_monster_rigged.glb"""
from __future__ import annotations

import math
import sys
from pathlib import Path

import bpy
from mathutils import Euler, Matrix, Vector

SRC = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/little_monster.glb"
)
OUT = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/little_monster_rigged.glb"
)


def clear_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def world_bounds(obj: bpy.types.Object) -> tuple[Vector, Vector]:
    corners = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
    mn = Vector((min(v.x for v in corners), min(v.y for v in corners), min(v.z for v in corners)))
    mx = Vector((max(v.x for v in corners), max(v.y for v in corners), max(v.z for v in corners)))
    return mn, mx


def make_bone(arm: bpy.types.Armature, name: str, head: Vector, tip: Vector, parent: str | None = None):
    bone = arm.edit_bones.new(name)
    bone.head = head
    bone.tail = tip
    if parent and parent in arm.edit_bones:
        bone.parent = arm.edit_bones[parent]
        bone.use_connect = False
    return bone


def build_armature(mn: Vector, mx: Vector) -> bpy.types.Object:
    size = mx - mn
    cx = (mn.x + mx.x) * 0.5
    cy = (mn.y + mx.y) * 0.5
    z0, z1 = mn.z, mx.z
    h = max(size.z, 0.01)
    w = max(size.x, 0.01)

    # Proportions for capsule stick-figure monster
    hip_z = z0 + h * 0.42
    chest_z = z0 + h * 0.68
    neck_z = z0 + h * 0.82
    head_z = z0 + h * 0.96
    shoulder_x = w * 0.28
    hip_x = w * 0.12
    arm_len = h * 0.28
    forearm = h * 0.22
    thigh = h * 0.24
    shin = h * 0.24
    # Slight forward offset so feet sit under body
    y = cy

    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm_obj = bpy.context.active_object
    arm_obj.name = "LittleMonsterArmature"
    arm = arm_obj.data
    arm.name = "LittleMonsterArmature"
    # remove default bone
    for b in list(arm.edit_bones):
        arm.edit_bones.remove(b)

    make_bone(arm, "Root", Vector((cx, y, z0)), Vector((cx, y, z0 + h * 0.05)))
    make_bone(arm, "Hips", Vector((cx, y, hip_z - h * 0.04)), Vector((cx, y, hip_z + h * 0.04)), "Root")
    make_bone(arm, "Spine", Vector((cx, y, hip_z + h * 0.04)), Vector((cx, y, chest_z - h * 0.04)), "Hips")
    make_bone(arm, "Chest", Vector((cx, y, chest_z - h * 0.04)), Vector((cx, y, neck_z)), "Spine")
    make_bone(arm, "Neck", Vector((cx, y, neck_z)), Vector((cx, y, head_z - h * 0.04)), "Chest")
    make_bone(arm, "Head", Vector((cx, y, head_z - h * 0.04)), Vector((cx, y, z1 + h * 0.02)), "Neck")

    # Arms
    make_bone(
        arm,
        "UpperArm.L",
        Vector((cx + shoulder_x, y, chest_z)),
        Vector((cx + shoulder_x + arm_len * 0.15, y, chest_z - arm_len)),
        "Chest",
    )
    make_bone(
        arm,
        "LowerArm.L",
        Vector((cx + shoulder_x + arm_len * 0.15, y, chest_z - arm_len)),
        Vector((cx + shoulder_x + arm_len * 0.25, y, chest_z - arm_len - forearm)),
        "UpperArm.L",
    )
    make_bone(
        arm,
        "UpperArm.R",
        Vector((cx - shoulder_x, y, chest_z)),
        Vector((cx - shoulder_x - arm_len * 0.15, y, chest_z - arm_len)),
        "Chest",
    )
    make_bone(
        arm,
        "LowerArm.R",
        Vector((cx - shoulder_x - arm_len * 0.15, y, chest_z - arm_len)),
        Vector((cx - shoulder_x - arm_len * 0.25, y, chest_z - arm_len - forearm)),
        "UpperArm.R",
    )

    # Legs
    make_bone(
        arm,
        "Thigh.L",
        Vector((cx + hip_x, y, hip_z)),
        Vector((cx + hip_x, y, hip_z - thigh)),
        "Hips",
    )
    make_bone(
        arm,
        "Shin.L",
        Vector((cx + hip_x, y, hip_z - thigh)),
        Vector((cx + hip_x, y, z0 + h * 0.02)),
        "Thigh.L",
    )
    make_bone(
        arm,
        "Thigh.R",
        Vector((cx - hip_x, y, hip_z)),
        Vector((cx - hip_x, y, hip_z - thigh)),
        "Hips",
    )
    make_bone(
        arm,
        "Shin.R",
        Vector((cx - hip_x, y, hip_z - thigh)),
        Vector((cx - hip_x, y, z0 + h * 0.02)),
        "Thigh.R",
    )

    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


def bind_mesh(mesh: bpy.types.Object, arm_obj: bpy.types.Object) -> None:
    """用骨骼线段距离刷权重（不依赖 Bone Heat，Tripo 网格更稳）。"""
    bpy.ops.object.select_all(action="DESELECT")
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = mesh
    if mesh.parent:
        bpy.ops.object.parent_clear(type="CLEAR_KEEP_TRANSFORM")
    for g in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(g)
    for m in list(mesh.modifiers):
        if m.type == "ARMATURE":
            mesh.modifiers.remove(m)

    bone_names = [b.name for b in arm_obj.data.bones]
    groups = {n: mesh.vertex_groups.new(name=n) for n in bone_names}

    bone_segs = []
    for b in arm_obj.data.bones:
        head = arm_obj.matrix_world @ b.head_local
        tip = arm_obj.matrix_world @ b.tail_local
        bone_segs.append((b.name, head, tip))

    def dist_point_segment(p, a, b):
        ab = b - a
        t = 0.0 if ab.length_squared < 1e-10 else max(0.0, min(1.0, (p - a).dot(ab) / ab.length_squared))
        return (p - (a + ab * t)).length

    falloff = 0.10
    torso = {"Root", "Hips", "Spine", "Chest", "Neck", "Head"}
    limb = {"UpperArm.L", "LowerArm.L", "UpperArm.R", "LowerArm.R", "Thigh.L", "Shin.L", "Thigh.R", "Shin.R"}
    me = mesh.data
    mw = mesh.matrix_world
    # 身体中心：强绑躯干，避免胳膊腿一摆豆身跟着拧
    cx = sum((arm_obj.matrix_world @ b.head_local).x for b in arm_obj.data.bones) / max(len(arm_obj.data.bones), 1)
    cy = sum((arm_obj.matrix_world @ b.head_local).y for b in arm_obj.data.bones) / max(len(arm_obj.data.bones), 1)
    for vi, v in enumerate(me.vertices):
        pw = mw @ v.co
        radial = math.sqrt((pw.x - cx) ** 2 + (pw.y - cy) ** 2)
        dists = [(dist_point_segment(pw, a, b), name) for name, a, b in bone_segs]
        dists.sort(key=lambda x: x[0])
        # 靠中轴的点主要跟躯干；靠外才允许肢体主导
        if radial < 0.12:
            candidates = [t for t in dists if t[1] in torso][:3] or dists[:2]
        else:
            candidates = dists[:3]
        weights = []
        for d, name in candidates:
            w = math.exp(-(d * d) / (2.0 * falloff * falloff))
            if name in torso and radial < 0.16:
                w *= 2.2
            if name in limb and radial < 0.10:
                w *= 0.25
            weights.append((name, w))
        s = sum(w for _, w in weights) or 1.0
        for name, w in weights:
            groups[name].add([vi], w / s, "REPLACE")

    mesh.parent = arm_obj
    mesh.matrix_parent_inverse = arm_obj.matrix_world.inverted()
    mod = mesh.modifiers.new(name="Armature", type="ARMATURE")
    mod.object = arm_obj
    mod.use_vertex_groups = True
    mod.use_deform_preserve_volume = True
    print("proximity weights done; groups", len(mesh.vertex_groups))


def ensure_action(arm_obj: bpy.types.Object, name: str) -> bpy.types.Action:
    if arm_obj.animation_data is None:
        arm_obj.animation_data_create()
    action = bpy.data.actions.new(name=name)
    # Blender 5 layered actions：先挂上再 keyframe
    arm_obj.animation_data.action = action
    return action


def key_pose(arm_obj: bpy.types.Object, frame: int, pose: dict[str, tuple[float, float, float]]) -> None:
    bpy.context.scene.frame_set(frame)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="POSE")
    for bname, eulers_deg in pose.items():
        pb = arm_obj.pose.bones.get(bname)
        if pb is None:
            continue
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = Euler(tuple(math.radians(a) for a in eulers_deg), "XYZ")
        pb.keyframe_insert(data_path="rotation_euler", frame=frame)
    bpy.ops.object.mode_set(mode="OBJECT")


def stash_nla(arm_obj: bpy.types.Object, name: str, action: bpy.types.Action) -> None:
    if arm_obj.animation_data is None:
        arm_obj.animation_data_create()
    track = arm_obj.animation_data.nla_tracks.new()
    track.name = name
    start = int(action.frame_range[0]) if action.frame_range else 1
    track.strips.new(name, max(start, 1), action)
    arm_obj.animation_data.action = None


def make_run(arm_obj: bpy.types.Object) -> None:
    """正向小跑：只绕 X 前后摆，禁止 Y/Z 扭腰拧胯（豆身会被拧成麻花）。"""
    action = ensure_action(arm_obj, "run")
    # 元组 = (X俯仰, Y侧摆, Z扭转) —— 跑姿 Y/Z 一律为 0
    # 手臂基础外展用很小的固定 Y，不参与周期拧转
    frames = {
        1: {
            "Hips": (3, 0, 0),
            "Spine": (2, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.L": (-28, 0, 0),
            "Shin.L": (22, 0, 0),
            "Thigh.R": (26, 0, 0),
            "Shin.R": (38, 0, 0),
            "UpperArm.L": (22, -8, 0),
            "LowerArm.L": (18, 0, 0),
            "UpperArm.R": (-24, 8, 0),
            "LowerArm.R": (28, 0, 0),
        },
        7: {
            "Hips": (2, 0, 0),
            "Spine": (1, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.L": (-6, 0, 0),
            "Shin.L": (12, 0, 0),
            "Thigh.R": (6, 0, 0),
            "Shin.R": (14, 0, 0),
            "UpperArm.L": (4, -8, 0),
            "LowerArm.L": (14, 0, 0),
            "UpperArm.R": (-4, 8, 0),
            "LowerArm.R": (14, 0, 0),
        },
        13: {
            "Hips": (3, 0, 0),
            "Spine": (2, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.L": (26, 0, 0),
            "Shin.L": (38, 0, 0),
            "Thigh.R": (-28, 0, 0),
            "Shin.R": (22, 0, 0),
            "UpperArm.L": (-24, -8, 0),
            "LowerArm.L": (28, 0, 0),
            "UpperArm.R": (22, 8, 0),
            "LowerArm.R": (18, 0, 0),
        },
        19: {
            "Hips": (2, 0, 0),
            "Spine": (1, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.L": (6, 0, 0),
            "Shin.L": (14, 0, 0),
            "Thigh.R": (-6, 0, 0),
            "Shin.R": (12, 0, 0),
            "UpperArm.L": (-4, -8, 0),
            "LowerArm.L": (14, 0, 0),
            "UpperArm.R": (4, 8, 0),
            "LowerArm.R": (14, 0, 0),
        },
        25: None,
    }
    for f, pose in frames.items():
        if pose is None:
            pose = frames[1]
        key_pose(arm_obj, f, pose)
    action.use_cyclic = True
    stash_nla(arm_obj, "run", action)


def make_idle(arm_obj: bpy.types.Object) -> None:
    action = ensure_action(arm_obj, "idle")
    base = {
        "Hips": (0, 0, 0),
        "Spine": (0, 0, 0),
        "Chest": (0, 0, 0),
        "Thigh.L": (4, 0, 2),
        "Shin.L": (6, 0, 0),
        "Thigh.R": (4, 0, -2),
        "Shin.R": (6, 0, 0),
        "UpperArm.L": (8, -10, 0),
        "LowerArm.L": (12, 0, 0),
        "UpperArm.R": (8, 10, 0),
        "LowerArm.R": (12, 0, 0),
    }
    up = dict(base)
    up["Spine"] = (2, 0, 0)
    up["UpperArm.L"] = (6, -10, 0)
    up["UpperArm.R"] = (6, 10, 0)
    key_pose(arm_obj, 1, base)
    key_pose(arm_obj, 20, up)
    key_pose(arm_obj, 40, base)
    action.use_cyclic = True
    stash_nla(arm_obj, "idle", action)


def make_jump(arm_obj: bpy.types.Object) -> None:
    action = ensure_action(arm_obj, "jump")
    key_pose(
        arm_obj,
        1,
        {
            "Hips": (-5, 0, 0),
            "Spine": (-4, 0, 0),
            "Thigh.L": (25, 0, 8),
            "Shin.L": (40, 0, 0),
            "Thigh.R": (25, 0, -8),
            "Shin.R": (40, 0, 0),
            "UpperArm.L": (-20, 0, -25),
            "LowerArm.L": (30, 0, 0),
            "UpperArm.R": (-20, 0, 25),
            "LowerArm.R": (30, 0, 0),
        },
    )
    key_pose(
        arm_obj,
        8,
        {
            "Hips": (10, 0, 0),
            "Spine": (8, 0, 0),
            "Thigh.L": (-15, 0, 5),
            "Shin.L": (10, 0, 0),
            "Thigh.R": (-15, 0, -5),
            "Shin.R": (10, 0, 0),
            "UpperArm.L": (-55, 0, -20),
            "LowerArm.L": (20, 0, 0),
            "UpperArm.R": (-55, 0, 20),
            "LowerArm.R": (20, 0, 0),
        },
    )
    key_pose(
        arm_obj,
        16,
        {
            "Hips": (0, 0, 0),
            "Spine": (2, 0, 0),
            "Thigh.L": (10, 0, 4),
            "Shin.L": (20, 0, 0),
            "Thigh.R": (10, 0, -4),
            "Shin.R": (20, 0, 0),
            "UpperArm.L": (-10, 0, -15),
            "LowerArm.L": (25, 0, 0),
            "UpperArm.R": (-10, 0, 15),
            "LowerArm.R": (25, 0, 0),
        },
    )
    stash_nla(arm_obj, "jump", action)


def export_glb(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    kwargs = dict(
        filepath=str(path),
        export_format="GLB",
        export_animations=True,
        export_skins=True,
        export_morph=False,
        export_apply=False,
        export_yup=True,
    )
    # Blender 4/5 导出参数略有差异
    try:
        bpy.ops.export_scene.gltf(
            **kwargs,
            export_animation_mode="NLA_TRACKS",
            export_nla_strips=True,
        )
    except TypeError:
        bpy.ops.export_scene.gltf(**kwargs)


def main() -> None:
    if not SRC.exists():
        print("SRC missing", SRC)
        sys.exit(1)
    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(SRC))
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    if not meshes:
        print("No mesh imported")
        sys.exit(1)
    mesh = meshes[0]
    mesh.name = "LittleMonsterMesh"

    # Freeze transforms for clean bind
    bpy.ops.object.select_all(action="DESELECT")
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = mesh
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    mn, mx = world_bounds(mesh)
    print("bounds", mn, mx)
    arm_obj = build_armature(mn, mx)
    bind_mesh(mesh, arm_obj)

    bpy.context.scene.render.fps = 24
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = 40

    make_run(arm_obj)
    make_idle(arm_obj)
    make_jump(arm_obj)

    # Select armature+mesh for export
    bpy.ops.object.select_all(action="DESELECT")
    mesh.select_set(True)
    arm_obj.select_set(True)
    bpy.context.view_layer.objects.active = arm_obj
    export_glb(OUT)
    print("WROTE", OUT, "size", OUT.stat().st_size)


if __name__ == "__main__":
    main()
