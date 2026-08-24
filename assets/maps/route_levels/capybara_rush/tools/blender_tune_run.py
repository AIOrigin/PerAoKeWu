#!/usr/bin/env python3
"""Retune capy/cow run+idle on an already-sealed rigged GLB. Does not remesh."""
from __future__ import annotations

import math
import os
import sys
from pathlib import Path

import bpy
from mathutils import Euler

argv = sys.argv[sys.argv.index("--") + 1 :]
src_path, dst_path, kind = argv[0], argv[1], argv[2]


def _activate(obj) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    if obj.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")


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


def _ensure_action(arm, name):
    if arm.animation_data is None:
        arm.animation_data_create()
    action = bpy.data.actions.new(name=name)
    arm.animation_data.action = action
    return action


def _stash_nla(arm, name, action) -> None:
    if arm.animation_data is None:
        arm.animation_data_create()
    track = arm.animation_data.nla_tracks.new()
    track.name = name
    start = int(action.frame_range[0]) if action.frame_range else 1
    track.strips.new(name, max(start, 1), action)
    arm.animation_data.action = None


def _key_pose(arm, frame: int, pose: dict[str, tuple[float, float, float]]) -> None:
    bpy.context.scene.frame_set(frame)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="POSE")
    for pb in arm.pose.bones:
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = Euler((0.0, 0.0, 0.0), "XYZ")
        pb.keyframe_insert(data_path="rotation_euler", frame=frame)
    for bname, eulers in pose.items():
        pb = arm.pose.bones.get(bname)
        if pb is None:
            continue
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = Euler(tuple(math.radians(a) for a in eulers), "XYZ")
        pb.keyframe_insert(data_path="rotation_euler", frame=frame)
    bpy.ops.object.mode_set(mode="OBJECT")


def _world_tail(arm, pb):
    bpy.context.view_layer.update()
    return (arm.matrix_world @ pb.matrix).translation + (arm.matrix_world.to_3x3() @ pb.vector)


def _detect_axis(arm, bone_name: str, prefer: str) -> tuple[int, float]:
    """Return (axis_index, signed_degrees_scale).

    prefer='fore': +value should move the bone tip toward -Y (face).
    prefer='lift': +value should raise the bone tip (+Z).
    """
    pb = arm.pose.bones.get(bone_name)
    if pb is None:
        return 0, 1.0
    _activate(arm)
    bpy.ops.object.mode_set(mode="POSE")
    pb.rotation_mode = "XYZ"
    pb.rotation_euler = Euler((0, 0, 0), "XYZ")
    bpy.context.view_layer.update()
    rest = arm.matrix_world @ pb.tail
    best_axis, best_sign, best_score = 0, 1.0, -1.0
    for axis in range(3):
        for sign in (1.0, -1.0):
            e = [0.0, 0.0, 0.0]
            e[axis] = math.radians(18.0 * sign)
            pb.rotation_euler = Euler(e, "XYZ")
            bpy.context.view_layer.update()
            now = arm.matrix_world @ pb.tail
            if prefer == "fore":
                score = rest.y - now.y  # toward -Y
            else:
                score = now.z - rest.z  # lift
            if score > best_score:
                best_score = score
                best_axis = axis
                best_sign = sign
    pb.rotation_euler = Euler((0, 0, 0), "XYZ")
    bpy.context.view_layer.update()
    bpy.ops.object.mode_set(mode="OBJECT")
    print(f"AXIS {bone_name} {prefer} axis={best_axis} sign={best_sign} score={best_score:.4f}")
    return best_axis, best_sign


def _eulers(axis: int, sign: float, deg: float) -> tuple[float, float, float]:
    vals = [0.0, 0.0, 0.0]
    vals[axis] = deg * sign
    return (vals[0], vals[1], vals[2])


def _add(a, b) -> tuple[float, float, float]:
    return (a[0] + b[0], a[1] + b[1], a[2] + b[2])


def _make_quad_anims(arm) -> None:
    thigh_names = ["Thigh.FL", "Thigh.FR", "Thigh.BL", "Thigh.BR"]
    shin_names = ["Shin.FL", "Shin.FR", "Shin.BL", "Shin.BR"]
    if arm.pose.bones.get("Thigh.FL") is None:
        return
    thigh_ax = {n: _detect_axis(arm, n, "fore") for n in thigh_names if arm.pose.bones.get(n)}
    shin_ax: dict[str, tuple[int, float]] = {}
    for n in shin_names:
        parent = n.replace("Shin.", "Thigh.")
        if parent in thigh_ax:
            shin_ax[n] = thigh_ax[parent]
        elif arm.pose.bones.get(n):
            shin_ax[n] = _detect_axis(arm, n, "fore")

    def thigh(name: str, fore: float) -> tuple[float, float, float]:
        ax, sg = thigh_ax[name]
        return _eulers(ax, sg, fore)

    def shin(name: str, bend: float) -> tuple[float, float, float]:
        ax, sg = shin_ax[name]
        return _eulers(ax, sg, bend)

    def hips(_bob: float) -> tuple[float, float, float]:
        return (0.0, 0.0, 0.0)

    def spine(_nod: float) -> tuple[float, float, float]:
        return (0.0, 0.0, 0.0)

    # Capybara trot: diagonal pairs, short reach, clear plant vs pass.
    # FL+BR together, FR+BL together.
    run = _ensure_action(arm, "run")
    run_frames = {
        1: {
            "Hips": hips(3.0),
            "Spine": spine(2.0),
            "Chest": spine(-1.0),
            "Thigh.FL": thigh("Thigh.FL", -20.0),
            "Shin.FL": shin("Shin.FL", 18.0),
            "Thigh.FR": thigh("Thigh.FR", 18.0),
            "Shin.FR": shin("Shin.FR", 32.0),
            "Thigh.BL": thigh("Thigh.BL", 16.0),
            "Shin.BL": shin("Shin.BL", 28.0),
            "Thigh.BR": thigh("Thigh.BR", -18.0),
            "Shin.BR": shin("Shin.BR", 16.0),
        },
        7: {
            "Hips": hips(1.0),
            "Spine": spine(0.0),
            "Thigh.FL": thigh("Thigh.FL", -4.0),
            "Shin.FL": shin("Shin.FL", 22.0),
            "Thigh.FR": thigh("Thigh.FR", 4.0),
            "Shin.FR": shin("Shin.FR", 20.0),
            "Thigh.BL": thigh("Thigh.BL", 4.0),
            "Shin.BL": shin("Shin.BL", 20.0),
            "Thigh.BR": thigh("Thigh.BR", -4.0),
            "Shin.BR": shin("Shin.BR", 22.0),
        },
        13: {
            "Hips": hips(3.0),
            "Spine": spine(2.0),
            "Chest": spine(-1.0),
            "Thigh.FL": thigh("Thigh.FL", 18.0),
            "Shin.FL": shin("Shin.FL", 32.0),
            "Thigh.FR": thigh("Thigh.FR", -20.0),
            "Shin.FR": shin("Shin.FR", 18.0),
            "Thigh.BL": thigh("Thigh.BL", -18.0),
            "Shin.BL": shin("Shin.BL", 16.0),
            "Thigh.BR": thigh("Thigh.BR", 16.0),
            "Shin.BR": shin("Shin.BR", 28.0),
        },
        19: {
            "Hips": hips(1.0),
            "Spine": spine(0.0),
            "Thigh.FL": thigh("Thigh.FL", 4.0),
            "Shin.FL": shin("Shin.FL", 20.0),
            "Thigh.FR": thigh("Thigh.FR", -4.0),
            "Shin.FR": shin("Shin.FR", 22.0),
            "Thigh.BL": thigh("Thigh.BL", -4.0),
            "Shin.BL": shin("Shin.BL", 22.0),
            "Thigh.BR": thigh("Thigh.BR", 4.0),
            "Shin.BR": shin("Shin.BR", 20.0),
        },
        25: None,
    }
    for f, pose in run_frames.items():
        _key_pose(arm, f, run_frames[1] if pose is None else pose)
    run.use_cyclic = True
    _stash_nla(arm, "run", run)

    idle = _ensure_action(arm, "idle")
    stand = {
        "Hips": hips(0.5),
        "Thigh.FL": thigh("Thigh.FL", 4.0),
        "Shin.FL": shin("Shin.FL", 10.0),
        "Thigh.FR": thigh("Thigh.FR", 4.0),
        "Shin.FR": shin("Shin.FR", 10.0),
        "Thigh.BL": thigh("Thigh.BL", 5.0),
        "Shin.BL": shin("Shin.BL", 12.0),
        "Thigh.BR": thigh("Thigh.BR", 5.0),
        "Shin.BR": shin("Shin.BR", 12.0),
    }
    breathe = dict(stand)
    breathe["Hips"] = hips(2.0)
    breathe["Spine"] = spine(2.0)
    breathe["Chest"] = spine(1.5)
    _key_pose(arm, 1, stand)
    _key_pose(arm, 24, breathe)
    _key_pose(arm, 48, stand)
    idle.use_cyclic = True
    _stash_nla(arm, "idle", idle)

    jump = _ensure_action(arm, "jump")
    crouch = {
        "Hips": hips(-2.0),
        "Thigh.FL": thigh("Thigh.FL", 10.0),
        "Shin.FL": shin("Shin.FL", 28.0),
        "Thigh.FR": thigh("Thigh.FR", 10.0),
        "Shin.FR": shin("Shin.FR", 28.0),
        "Thigh.BL": thigh("Thigh.BL", 12.0),
        "Shin.BL": shin("Shin.BL", 30.0),
        "Thigh.BR": thigh("Thigh.BR", 12.0),
        "Shin.BR": shin("Shin.BR", 30.0),
    }
    air = {
        "Hips": hips(4.0),
        "Thigh.FL": thigh("Thigh.FL", -8.0),
        "Shin.FL": shin("Shin.FL", 14.0),
        "Thigh.FR": thigh("Thigh.FR", -8.0),
        "Shin.FR": shin("Shin.FR", 14.0),
        "Thigh.BL": thigh("Thigh.BL", -6.0),
        "Shin.BL": shin("Shin.BL", 16.0),
        "Thigh.BR": thigh("Thigh.BR", -6.0),
        "Shin.BR": shin("Shin.BR", 16.0),
    }
    _key_pose(arm, 1, crouch)
    _key_pose(arm, 8, air)
    _key_pose(arm, 16, stand)
    _stash_nla(arm, "jump", jump)

    dance = _ensure_action(arm, "dance")
    left = dict(stand)
    left["Hips"] = hips(2.0)
    left["Thigh.FL"] = thigh("Thigh.FL", 8.0)
    left["Thigh.BL"] = thigh("Thigh.BL", 8.0)
    right = dict(stand)
    right["Hips"] = hips(2.0)
    right["Thigh.FR"] = thigh("Thigh.FR", 8.0)
    right["Thigh.BR"] = thigh("Thigh.BR", 8.0)
    _key_pose(arm, 1, stand)
    _key_pose(arm, 12, left)
    _key_pose(arm, 24, stand)
    _key_pose(arm, 36, right)
    _key_pose(arm, 48, stand)
    dance.use_cyclic = True
    _stash_nla(arm, "dance", dance)


def _make_biped_anims(arm) -> None:
    """牛来等：后腿 Thigh/Shin + 前腿 UpperArm/LowerArm 对角小跑。"""
    if arm.pose.bones.get("Thigh.L") is None:
        return
    lt = _detect_axis(arm, "Thigh.L", "fore")
    rt = _detect_axis(arm, "Thigh.R", "fore")
    ls = _detect_axis(arm, "Shin.L", "lift")
    rs = _detect_axis(arm, "Shin.R", "lift")
    hip = _detect_axis(arm, "Hips", "lift")
    has_arms = arm.pose.bones.get("UpperArm.L") is not None
    if has_arms:
        ual = _detect_axis(arm, "UpperArm.L", "fore")
        uar = _detect_axis(arm, "UpperArm.R", "fore")
        lal = _detect_axis(arm, "LowerArm.L", "lift") if arm.pose.bones.get("LowerArm.L") else ual
        lar = _detect_axis(arm, "LowerArm.R", "lift") if arm.pose.bones.get("LowerArm.R") else uar

    def te(side: str, fore: float):
        ax, sg = lt if side == "L" else rt
        return _eulers(ax, sg, fore)

    def se(side: str, bend: float):
        ax, sg = ls if side == "L" else rs
        return _eulers(ax, sg, bend)

    def ua(side: str, fore: float, twist: float = 0.0):
        if not has_arms:
            return (0.0, 0.0, 0.0)
        ax, sg = ual if side == "L" else uar
        base = _eulers(ax, sg, fore)
        side_sign = -1.0 if side == "L" else 1.0
        return (base[0], base[1] + twist * side_sign, base[2])

    def la(side: str, bend: float):
        if not has_arms:
            return (0.0, 0.0, 0.0)
        ax, sg = lal if side == "L" else lar
        return _eulers(ax, sg, bend)

    def hips(bob: float):
        return _eulers(hip[0], hip[1], bob)

    run = _ensure_action(arm, "run")
    frames = {
        1: {
            "Hips": hips(4.0),
            "Thigh.L": te("L", -28.0),
            "Shin.L": se("L", 30.0),
            "Thigh.R": te("R", 24.0),
            "Shin.R": se("R", 28.0),
            "UpperArm.L": ua("L", 22.0, 8.0),
            "LowerArm.L": la("L", 18.0),
            "UpperArm.R": ua("R", -24.0, 8.0),
            "LowerArm.R": la("R", 16.0),
        },
        7: {
            "Hips": hips(2.0),
            "Thigh.L": te("L", -6.0),
            "Shin.L": se("L", 16.0),
            "Thigh.R": te("R", 6.0),
            "Shin.R": se("R", 14.0),
            "UpperArm.L": ua("L", 4.0, 8.0),
            "LowerArm.L": la("L", 12.0),
            "UpperArm.R": ua("R", -4.0, 8.0),
            "LowerArm.R": la("R", 12.0),
        },
        13: {
            "Hips": hips(4.0),
            "Thigh.L": te("L", 24.0),
            "Shin.L": se("L", 28.0),
            "Thigh.R": te("R", -28.0),
            "Shin.R": se("R", 30.0),
            "UpperArm.L": ua("L", -24.0, 8.0),
            "LowerArm.L": la("L", 16.0),
            "UpperArm.R": ua("R", 22.0, 8.0),
            "LowerArm.R": la("R", 18.0),
        },
        19: {
            "Hips": hips(2.0),
            "Thigh.L": te("L", 6.0),
            "Shin.L": se("L", 14.0),
            "Thigh.R": te("R", -6.0),
            "Shin.R": se("R", 16.0),
            "UpperArm.L": ua("L", -4.0, 8.0),
            "LowerArm.L": la("L", 12.0),
            "UpperArm.R": ua("R", 4.0, 8.0),
            "LowerArm.R": la("R", 12.0),
        },
        25: None,
    }
    for f, pose in frames.items():
        _key_pose(arm, f, frames[1] if pose is None else pose)
    run.use_cyclic = True
    _stash_nla(arm, "run", run)

    idle = _ensure_action(arm, "idle")
    stand = {
        "Hips": hips(0.5),
        "Thigh.L": te("L", 6.0),
        "Shin.L": se("L", 12.0),
        "Thigh.R": te("R", 6.0),
        "Shin.R": se("R", 12.0),
        "UpperArm.L": ua("L", 8.0, 8.0),
        "LowerArm.L": la("L", 10.0),
        "UpperArm.R": ua("R", 8.0, 8.0),
        "LowerArm.R": la("R", 10.0),
    }
    up = dict(stand)
    up["Hips"] = hips(2.0)
    _key_pose(arm, 1, stand)
    _key_pose(arm, 24, up)
    _key_pose(arm, 48, stand)
    idle.use_cyclic = True
    _stash_nla(arm, "idle", idle)

    jump = _ensure_action(arm, "jump")
    _key_pose(arm, 1, {
        "Thigh.L": te("L", 16.0), "Shin.L": se("L", 32.0),
        "Thigh.R": te("R", 16.0), "Shin.R": se("R", 32.0),
        "UpperArm.L": ua("L", -28.0, 10.0), "UpperArm.R": ua("R", -28.0, 10.0),
    })
    _key_pose(arm, 8, {
        "Thigh.L": te("L", -10.0), "Shin.L": se("L", 14.0),
        "Thigh.R": te("R", -10.0), "Shin.R": se("R", 14.0),
        "UpperArm.L": ua("L", -40.0, 8.0), "UpperArm.R": ua("R", -40.0, 8.0),
    })
    _key_pose(arm, 16, stand)
    _stash_nla(arm, "jump", jump)

    dance = _ensure_action(arm, "dance")
    left = dict(stand)
    left["Thigh.L"] = te("L", 14.0)
    left["UpperArm.L"] = ua("L", 16.0, 8.0)
    right = dict(stand)
    right["Thigh.R"] = te("R", 14.0)
    right["UpperArm.R"] = ua("R", 16.0, 8.0)
    _key_pose(arm, 1, stand)
    _key_pose(arm, 12, left)
    _key_pose(arm, 24, stand)
    _key_pose(arm, 36, right)
    _key_pose(arm, 48, stand)
    dance.use_cyclic = True
    _stash_nla(arm, "dance", dance)



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


def _verify_run_motion(arm) -> None:
    run = bpy.data.actions.get("run")
    if run is None:
        raise RuntimeError("missing run action")
    if arm.animation_data is None:
        arm.animation_data_create()
    # 从 NLA 取回 run，方便采样
    arm.animation_data.action = run
    bones = [
        n
        for n in (
            "Thigh.FL",
            "Thigh.FR",
            "Thigh.BL",
            "Thigh.BR",
            "Thigh.L",
            "Thigh.R",
            "UpperArm.L",
            "UpperArm.R",
        )
        if arm.pose.bones.get(n)
    ]
    tips: dict[str, list] = {b: [] for b in bones}
    for fr in (1, 13, 25):
        bpy.context.scene.frame_set(fr)
        bpy.context.view_layer.update()
        for b in bones:
            tip = arm.matrix_world @ arm.pose.bones[b].tail
            tips[b].append((tip.x, tip.y, tip.z))
    moved = 0
    for b, pts in tips.items():
        span = max(
            abs(pts[1][i] - pts[0][i]) for i in range(3)
        )
        print(f"MOTION {b} span={span:.4f} p0={tuple(round(x,3) for x in pts[0])} p1={tuple(round(x,3) for x in pts[1])}")
        if span > 0.02:
            moved += 1
    if moved < 2:
        raise RuntimeError(f"run animation too weak: only {moved} bones moved")
    arm.animation_data.action = None


bpy.ops.wm.read_factory_settings(use_empty=True)
print("TUNE", src_path, kind)
bpy.ops.import_scene.gltf(filepath=src_path)
arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
if not arms:
    raise RuntimeError("no armature")
arm = arms[0]
_reset_pose(arm)
_clear_actions(arm)
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 48
bpy.context.scene.render.fps = 24
if kind == "capy":
    _make_quad_anims(arm)
else:
    _make_biped_anims(arm)
print("actions", [a.name for a in bpy.data.actions])
_verify_run_motion(arm)
_export(dst_path)
