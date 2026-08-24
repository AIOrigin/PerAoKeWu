#!/usr/bin/env python3
"""Blender: Tripo 牛双足 + 左右交替跑（局部 X，同青青）→ cow_rigged.glb"""
from __future__ import annotations

import math
import sys
from pathlib import Path

import bpy
from mathutils import Euler, Vector

sys.path.insert(0, str(Path(__file__).resolve().parent))
import batch_prepare_glb_resouses as biped
import rig_qingqing as qq

SRC = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/cow.glb"
)
OUT = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/cow_rigged.glb"
)


def snout_offset_xy(mesh: bpy.types.Object) -> Vector:
    """头顶部离中心最远的点 → 嘴脸水平方向（Tripo 牛常朝 +X，不是 ±Y）。"""
    mw = mesh.matrix_world
    pts = [mw @ v.co for v in mesh.data.vertices]
    z0 = min(p.z for p in pts)
    z1 = max(p.z for p in pts)
    h = max(z1 - z0, 1e-6)
    cx = sum(p.x for p in pts) / len(pts)
    cy = sum(p.y for p in pts) / len(pts)
    top = [p for p in pts if (p.z - z0) / h > 0.72]
    if not top:
        top = pts
    far = sorted(top, key=lambda p: (p.x - cx) ** 2 + (p.y - cy) ** 2, reverse=True)[:40]
    avg = sum((Vector((p.x, p.y, p.z)) for p in far), Vector()) / len(far)
    return Vector((avg.x - cx, avg.y - cy, 0.0))


def orient_face_neg_y(mesh: bpy.types.Object) -> None:
    """把嘴脸转到 Blender -Y，导出 Yup 后 Godot 脸朝 +Z，左右胯在 ±X。"""
    off = snout_offset_xy(mesh)
    if off.length < 1e-4:
        print("  face orient skipped (no snout hint)")
        return
    # 目标：snout → (0, -1)；当前角 → 绕 Z 转到 -Y
    ang = math.atan2(off.y, off.x)  # 相对 +X
    # +X 的角为 0；-Y 的角为 -π/2；需要旋转 delta = -π/2 - ang
    delta = -math.pi * 0.5 - ang
    # 已接近 -Y 则不动
    if abs(delta) < math.radians(8.0) or abs(abs(delta) - 2.0 * math.pi) < math.radians(8.0):
        print("  face already toward -Y", "snout", tuple(round(x, 3) for x in off))
        return
    R = Euler((0.0, 0.0, delta), "XYZ").to_matrix()
    for v in mesh.data.vertices:
        v.co = R @ v.co
    mesh.data.update()
    bpy.context.view_layer.update()
    off2 = snout_offset_xy(mesh)
    print(
        "  rotated",
        round(math.degrees(delta), 1),
        "° face → -Y; snout",
        tuple(round(x, 3) for x in off),
        "→",
        tuple(round(x, 3) for x in off2),
    )


def center_mesh(mesh: bpy.types.Object) -> None:
    mw = mesh.matrix_world
    pts = [mw @ v.co for v in mesh.data.vertices]
    cx = sum(p.x for p in pts) / len(pts)
    cy = sum(p.y for p in pts) / len(pts)
    cz = min(p.z for p in pts)
    inv = mw.inverted()
    delta = Vector((cx, cy, cz))
    for v in mesh.data.vertices:
        v.co = inv @ ((mw @ v.co) - delta)
    mesh.data.update()
    bpy.context.view_layer.objects.active = mesh
    mesh.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    pts2 = [mesh.matrix_world @ v.co for v in mesh.data.vertices]
    print(
        "  centered; +X",
        sum(1 for p in pts2 if p.x >= 0),
        "-X",
        sum(1 for p in pts2 if p.x < 0),
    )


def boost_leg_weights(mesh: bpy.types.Object) -> None:
    """下半身绑到 Thigh/Shin；尾巴（脸朝 -Y 时在 +Y 后方）绑到 Hips，避免被大腿拽成硬棍。"""
    mn, mx = biped.world_bounds_objs([mesh])
    sz = max(mx.z - mn.z, 1e-4)
    sy = max(mx.y - mn.y, 1e-4)
    sx = max(mx.x - mn.x, 1e-4)
    mw = mesh.matrix_world
    groups = {g.name: g for g in mesh.vertex_groups}
    n_l = n_r = n_tail = 0
    for vi, v in enumerate(mesh.data.vertices):
        pw = mw @ v.co
        fz = (pw.z - mn.z) / sz
        if fz >= 0.42:
            continue
        fy = (pw.y - mn.y) / sy
        fx = abs(pw.x - (mn.x + mx.x) * 0.5) / (sx * 0.5)
        # 后凸/尾巴：靠后且靠近中线，不要跟腿走
        is_tail = fy > 0.58 and fx < 0.55 and fz > 0.12
        for g in mesh.vertex_groups:
            try:
                g.remove([vi])
            except RuntimeError:
                pass
        if is_tail:
            groups["Hips"].add([vi], 0.75, "REPLACE")
            groups["Spine"].add([vi], 0.25, "REPLACE")
            n_tail += 1
            continue
        side = "L" if pw.x >= 0.0 else "R"
        shin = max(0.0, min(1.0, (0.22 - fz) / 0.22)) if fz < 0.22 else 0.0
        thigh = 1.0 - shin * 0.7
        hips = 0.15 if fz > 0.28 else 0.0
        total = thigh + shin * 0.7 + hips
        groups[f"Thigh.{side}"].add([vi], thigh / total, "REPLACE")
        if shin > 0.01:
            groups[f"Shin.{side}"].add([vi], (shin * 0.7) / total, "REPLACE")
        if hips > 0.01:
            groups["Hips"].add([vi], hips / total, "REPLACE")
        if side == "L":
            n_l += 1
        else:
            n_r += 1
    print("  boosted leg verts L", n_l, "R", n_r, "tail→Hips", n_tail)


def make_cow_anims(arm_obj) -> None:
    """与青青相同：大腿绕局部 X 交替迈步。

    cow 游戏内 yaw=-π/2 后，X 轴摆动 → 世界 X 左右分开迈腿；
    若误用局部 Z，左右腿骨会叠在前进轴上，看起来像两腿同相前后甩。
    """
    action = biped.ensure_action(arm_obj, "run")
    frames = {
        1: {
            "Hips": (4, 0, 0),
            "Spine": (2, 0, 0),
            "Thigh.L": (-26, 0, 0),
            "Shin.L": (28, 0, 0),
            "Thigh.R": (22, 0, 0),
            "Shin.R": (26, 0, 0),
            "UpperArm.L": (18, -8, 0),
            "LowerArm.L": (16, 0, 0),
            "UpperArm.R": (-20, 8, 0),
            "LowerArm.R": (16, 0, 0),
        },
        7: {
            "Hips": (2, 0, 0),
            "Thigh.L": (-6, 0, 0),
            "Shin.L": (14, 0, 0),
            "Thigh.R": (6, 0, 0),
            "Shin.R": (12, 0, 0),
            "UpperArm.L": (4, -8, 0),
            "UpperArm.R": (-4, 8, 0),
        },
        13: {
            "Hips": (4, 0, 0),
            "Spine": (2, 0, 0),
            "Thigh.L": (22, 0, 0),
            "Shin.L": (26, 0, 0),
            "Thigh.R": (-26, 0, 0),
            "Shin.R": (28, 0, 0),
            "UpperArm.L": (-20, -8, 0),
            "LowerArm.L": (16, 0, 0),
            "UpperArm.R": (18, 8, 0),
            "LowerArm.R": (16, 0, 0),
        },
        19: {
            "Hips": (2, 0, 0),
            "Thigh.L": (6, 0, 0),
            "Shin.L": (12, 0, 0),
            "Thigh.R": (-6, 0, 0),
            "Shin.R": (14, 0, 0),
            "UpperArm.L": (-4, -8, 0),
            "UpperArm.R": (4, 8, 0),
        },
        25: None,
    }
    for f, pose in frames.items():
        qq.key_pose(arm_obj, f, frames[1] if pose is None else pose)
    action.use_cyclic = True
    biped.stash_nla(arm_obj, "run", action)

    action = biped.ensure_action(arm_obj, "idle")
    base = {
        "Hips": (0, 0, 0),
        "Spine": (0, 0, 0),
        "Chest": (0, 0, 0),
        "Thigh.L": (6, 0, 0),
        "Shin.L": (10, 0, 0),
        "Thigh.R": (6, 0, 0),
        "Shin.R": (10, 0, 0),
        "UpperArm.L": (8, -8, 0),
        "UpperArm.R": (8, 8, 0),
    }
    up = dict(base)
    up["Chest"] = (1, 0, 0)
    up["Head"] = (2, 0, 0)
    qq.key_pose(arm_obj, 1, base)
    qq.key_pose(arm_obj, 20, up)
    qq.key_pose(arm_obj, 40, base)
    action.use_cyclic = True
    biped.stash_nla(arm_obj, "idle", action)

    action = biped.ensure_action(arm_obj, "jump")
    qq.key_pose(arm_obj, 1, {"Thigh.L": (22, 0, 0), "Shin.L": (36, 0, 0), "Thigh.R": (22, 0, 0), "Shin.R": (36, 0, 0), "UpperArm.L": (-28, -10, 0), "UpperArm.R": (-28, 10, 0)})
    qq.key_pose(arm_obj, 8, {"Thigh.L": (-16, 0, 0), "Shin.L": (14, 0, 0), "Thigh.R": (-16, 0, 0), "Shin.R": (14, 0, 0), "UpperArm.L": (-45, -8, 0), "UpperArm.R": (-45, 8, 0)})
    qq.key_pose(arm_obj, 16, {"Thigh.L": (6, 0, 0), "Shin.L": (12, 0, 0), "Thigh.R": (6, 0, 0), "Shin.R": (12, 0, 0)})
    biped.stash_nla(arm_obj, "jump", action)

    action = biped.ensure_action(arm_obj, "dance")
    qq.key_pose(arm_obj, 1, base)
    qq.key_pose(arm_obj, 12, up)
    qq.key_pose(arm_obj, 24, base)
    action.use_cyclic = True
    biped.stash_nla(arm_obj, "dance", action)


def main() -> None:
    biped.clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(SRC))
    for o in list(bpy.data.objects):
        if o.type in {"EMPTY", "ARMATURE"}:
            bpy.data.objects.remove(o, do_unlink=True)
    mesh = biped.join_meshes()
    mesh.name = "CowBody"
    biped.decimate_mesh(mesh, target_faces=28000)
    orient_face_neg_y(mesh)
    center_mesh(mesh)
    mn, mx = biped.world_bounds_objs([mesh])
    print("bounds", tuple(round(x, 3) for x in (mx - mn)), "faces", len(mesh.data.polygons))
    arm = biped.build_biped(mn, mx)
    arm.name = "CowArmature"
    arm.data.name = "CowArmature"
    qq.bind_humanoid(mesh, arm)
    boost_leg_weights(mesh)
    bpy.context.view_layer.objects.active = mesh
    bpy.ops.object.vertex_group_normalize_all(lock_active=False)
    mass = {g.name: 0.0 for g in mesh.vertex_groups}
    for vi in range(len(mesh.data.vertices)):
        for g in mesh.vertex_groups:
            try:
                w = g.weight(vi)
            except RuntimeError:
                continue
            if w:
                mass[g.name] += w
    print("  blender mass", {k: round(v, 1) for k, v in sorted(mass.items(), key=lambda x: -x[1])[:10]})
    bpy.context.scene.render.fps = 24
    make_cow_anims(arm)
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = arm
    biped.export_selected(OUT)
    print("WROTE", OUT, OUT.stat().st_size)


if __name__ == "__main__":
    main()
