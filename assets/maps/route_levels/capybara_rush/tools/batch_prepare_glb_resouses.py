#!/usr/bin/env python3
"""Batch: glb-resouses → characters/*_rigged.glb with run/idle/jump (+ dance)."""
from __future__ import annotations

import math
import shutil
import sys
from pathlib import Path

import bpy
from mathutils import Euler, Vector

ROOT = Path("/Users/mima1234/Documents/HYPERLUNATIC/glb-resouses")
OUT_DIR = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters"
)

# (src_glob_or_name, out_stem, mode)
# mode: "quaternius" = already rigged+anim; "autoroot" = decimate+bind+keyframe
JOBS = [
    ("quaternius_cc0-cyan-rabbit-1278.glb", "little_rabbit", "quaternius"),
    ("quaternius_cc0-shiba-inu-1332.glb", "shiba", "quaternius"),
    ("tiny_planet_friends_3d-bird-4162.glb", "bird", "autoroot"),
    ("tiny_planet_friends_3d-mouse-4188.glb", "mouse", "autoroot"),
    ("tiny_planet_friends_3d-sloth-4187.glb", "sloth", "autoroot"),
    ("tiny_planet_friends_3d-tinyplanet-2829.glb", "tiny_planet", "autoroot"),
    ("wings_of_freedom-bear-3111.glb", "bear", "autoroot"),
]

QUATERNIUS_ALIAS = {
    # rabbit-style
    "run": ["Run", "Gallop", "Walk", "Run_Holding"],
    "idle": ["Idle", "Idle_2", "Idle_Holding"],
    "jump": ["Jump", "Gallop_Jump", "Jump_ToIdle", "Jump_Idle"],
    "dance": ["Wave", "Yes", "Idle_2", "Eating"],
}


def clear_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def world_bounds_objs(objs: list[bpy.types.Object]) -> tuple[Vector, Vector]:
    corners: list[Vector] = []
    for o in objs:
        if o.type != "MESH":
            continue
        corners += [o.matrix_world @ Vector(c) for c in o.bound_box]
    if not corners:
        return Vector((0, 0, 0)), Vector((1, 1, 1))
    mn = Vector((min(v.x for v in corners), min(v.y for v in corners), min(v.z for v in corners)))
    mx = Vector((max(v.x for v in corners), max(v.y for v in corners), max(v.z for v in corners)))
    return mn, mx


def find_action(name: str) -> bpy.types.Action | None:
    for a in bpy.data.actions:
        if a.name == name or a.name.lower() == name.lower():
            return a
    return None


def stash_alias(arm: bpy.types.Object, alias: str, candidates: list[str]) -> None:
    action = None
    for c in candidates:
        action = find_action(c)
        if action:
            break
    if action is None:
        print("  ! missing", alias, candidates)
        return
    if arm.animation_data is None:
        arm.animation_data_create()
    dup = action.copy()
    dup.name = alias
    track = arm.animation_data.nla_tracks.new()
    track.name = alias
    start = int(dup.frame_range[0]) if dup.frame_range else 1
    track.strips.new(alias, max(start, 1), dup)
    print("  alias", alias, "<-", action.name)


def export_selected(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
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


def process_quaternius(src: Path, stem: str) -> None:
    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(src))
    for o in list(bpy.data.objects):
        if o.type == "MESH" and (o.parent is None or "ico" in o.name.lower()):
            print("  remove", o.name)
            bpy.data.objects.remove(o, do_unlink=True)
    arm = next((o for o in bpy.data.objects if o.type == "ARMATURE"), None)
    if arm is None:
        raise RuntimeError("no armature")
    arm.name = f"{stem}_Armature"
    if arm.animation_data:
        for t in list(arm.animation_data.nla_tracks):
            arm.animation_data.nla_tracks.remove(t)
        arm.animation_data.action = None
    for alias, cands in QUATERNIUS_ALIAS.items():
        stash_alias(arm, alias, cands)
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    for o in bpy.data.objects:
        if o.type == "MESH":
            o.select_set(True)
    bpy.context.view_layer.objects.active = arm
    out = OUT_DIR / f"{stem}_rigged.glb"
    main = OUT_DIR / f"{stem}.glb"
    export_selected(out)
    shutil.copy2(out, main)
    print("  WROTE", out.name, out.stat().st_size)


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
    hip_z = z0 + h * 0.36
    chest_z = z0 + h * 0.68
    neck_z = z0 + h * 0.82
    head_z = z0 + h * 0.96
    shoulder_x = w * 0.28
    hip_x = w * 0.22
    arm_len = h * 0.28
    forearm = h * 0.22
    thigh = h * 0.22
    y = cy

    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm_obj = bpy.context.active_object
    arm_obj.name = "AutoArmature"
    arm = arm_obj.data
    for b in list(arm.edit_bones):
        arm.edit_bones.remove(b)

    make_bone(arm, "Root", Vector((cx, y, z0)), Vector((cx, y, z0 + h * 0.05)))
    make_bone(arm, "Hips", Vector((cx, y, hip_z - h * 0.04)), Vector((cx, y, hip_z + h * 0.04)), "Root")
    make_bone(arm, "Spine", Vector((cx, y, hip_z + h * 0.04)), Vector((cx, y, chest_z - h * 0.04)), "Hips")
    make_bone(arm, "Chest", Vector((cx, y, chest_z - h * 0.04)), Vector((cx, y, neck_z)), "Spine")
    make_bone(arm, "Neck", Vector((cx, y, neck_z)), Vector((cx, y, head_z - h * 0.04)), "Chest")
    make_bone(arm, "Head", Vector((cx, y, head_z - h * 0.04)), Vector((cx, y, z1 + h * 0.02)), "Neck")
    make_bone(arm, "UpperArm.L", Vector((cx + shoulder_x, y, chest_z)), Vector((cx + shoulder_x + arm_len * 0.15, y, chest_z - arm_len)), "Chest")
    make_bone(arm, "LowerArm.L", Vector((cx + shoulder_x + arm_len * 0.15, y, chest_z - arm_len)), Vector((cx + shoulder_x + arm_len * 0.25, y, chest_z - arm_len - forearm)), "UpperArm.L")
    make_bone(arm, "UpperArm.R", Vector((cx - shoulder_x, y, chest_z)), Vector((cx - shoulder_x - arm_len * 0.15, y, chest_z - arm_len)), "Chest")
    make_bone(arm, "LowerArm.R", Vector((cx - shoulder_x - arm_len * 0.15, y, chest_z - arm_len)), Vector((cx - shoulder_x - arm_len * 0.25, y, chest_z - arm_len - forearm)), "UpperArm.R")
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
    mesh.name = "Body"
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return mesh


def decimate_mesh(mesh: bpy.types.Object, target_faces: int = 10000) -> None:
    faces = len(mesh.data.polygons)
    if faces <= target_faces:
        print("  faces", faces, "ok")
        return
    ratio = max(0.02, min(1.0, target_faces / float(faces)))
    print("  decimate", faces, "-> ~", int(faces * ratio), "ratio", round(ratio, 4))
    mod = mesh.modifiers.new("Decimate", "DECIMATE")
    mod.ratio = ratio
    bpy.context.view_layer.objects.active = mesh
    bpy.ops.object.modifier_apply(modifier="Decimate")
    print("  faces now", len(mesh.data.polygons))


def bind_proximity(mesh: bpy.types.Object, arm_obj: bpy.types.Object) -> None:
    """Legs-only skin: torso locked to Hips; only bottom L/R verts follow thighs/shins.
    Prevents blob melt while still showing a run gait.
    """
    for g in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(g)
    for m in list(mesh.modifiers):
        if m.type == "ARMATURE":
            mesh.modifiers.remove(m)
    groups = {b.name: mesh.vertex_groups.new(name=b.name) for b in arm_obj.data.bones}

    mn, mx = world_bounds_objs([mesh])
    size = mx - mn
    mw = mesh.matrix_world
    cx = (mn.x + mx.x) * 0.5
    cz0, cz1 = mn.z, mx.z
    h = max(cz1 - cz0, 0.01)
    half_w = max(size.x * 0.5, 1e-4)

    def smoothstep(edge0: float, edge1: float, x: float) -> float:
        t = max(0.0, min(1.0, (x - edge0) / max(edge1 - edge0, 1e-6)))
        return t * t * (3.0 - 2.0 * t)

    for vi, v in enumerate(mesh.data.vertices):
        pw = mw @ v.co
        height_k = (pw.z - cz0) / h
        # 0 at mid-body, 1 at feet
        foot_k = 1.0 - smoothstep(0.12, 0.42, height_k)
        foot_k = foot_k * foot_k
        # 越靠脚底越偏小腿
        shin_k = 1.0 - smoothstep(0.02, 0.24, height_k)
        # 左右：+X → L，-X → R；中间均分
        sx = max(-1.0, min(1.0, (pw.x - cx) / half_w))
        wl = max(0.0, sx)
        wr = max(0.0, -sx)
        if wl + wr < 1e-4:
            wl = wr = 0.5
        else:
            # 拉开左右，减少对侧腿拉扯
            wl = wl ** 0.85
            wr = wr ** 0.85
            s = wl + wr
            wl /= s
            wr /= s

        # 腿最多吃 75%，全身至少留 25% 在 Hips，杜绝融化
        leg_total = foot_k * 0.75
        w_hips = 1.0 - leg_total
        w_l = leg_total * wl
        w_r = leg_total * wr
        weights = {
            "Hips": w_hips,
            "Thigh.L": w_l * (1.0 - shin_k * 0.65),
            "Shin.L": w_l * (shin_k * 0.65),
            "Thigh.R": w_r * (1.0 - shin_k * 0.65),
            "Shin.R": w_r * (shin_k * 0.65),
        }
        # 其余骨写 0，避免残留
        for name, g in groups.items():
            g.add([vi], float(weights.get(name, 0.0)), "REPLACE")

    mesh.parent = arm_obj
    mesh.matrix_parent_inverse = arm_obj.matrix_world.inverted()
    mod = mesh.modifiers.new("Armature", "ARMATURE")
    mod.object = arm_obj
    mod.use_vertex_groups = True
    print("  weights: legs-only (torso locked)")


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


def make_simple_anims(arm_obj):
    """Leg-driven run: no arm/spine twist (blob torso stays intact)."""
    action = ensure_action(arm_obj, "run")
    frames = {
        1: {
            "Hips": (2, 0, 0),
            "Thigh.L": (-22, 0, 0),
            "Shin.L": (18, 0, 0),
            "Thigh.R": (18, 0, 0),
            "Shin.R": (26, 0, 0),
        },
        7: {
            "Hips": (1, 0, 0),
            "Thigh.L": (-6, 0, 0),
            "Shin.L": (10, 0, 0),
            "Thigh.R": (6, 0, 0),
            "Shin.R": (12, 0, 0),
        },
        13: {
            "Hips": (2, 0, 0),
            "Thigh.L": (18, 0, 0),
            "Shin.L": (26, 0, 0),
            "Thigh.R": (-22, 0, 0),
            "Shin.R": (18, 0, 0),
        },
        19: {
            "Hips": (1, 0, 0),
            "Thigh.L": (6, 0, 0),
            "Shin.L": (12, 0, 0),
            "Thigh.R": (-6, 0, 0),
            "Shin.R": (10, 0, 0),
        },
        25: None,
    }
    for f, pose in frames.items():
        key_pose(arm_obj, f, frames[1] if pose is None else pose)
    action.use_cyclic = True
    stash_nla(arm_obj, "run", action)

    action = ensure_action(arm_obj, "idle")
    base = {"Hips": (0, 0, 0), "Thigh.L": (3, 0, 0), "Shin.L": (5, 0, 0), "Thigh.R": (3, 0, 0), "Shin.R": (5, 0, 0)}
    up = {"Hips": (1, 0, 0), "Thigh.L": (3, 0, 0), "Shin.L": (5, 0, 0), "Thigh.R": (3, 0, 0), "Shin.R": (5, 0, 0)}
    key_pose(arm_obj, 1, base)
    key_pose(arm_obj, 20, up)
    key_pose(arm_obj, 40, base)
    action.use_cyclic = True
    stash_nla(arm_obj, "idle", action)

    action = ensure_action(arm_obj, "jump")
    key_pose(arm_obj, 1, {"Hips": (-2, 0, 0), "Thigh.L": (14, 0, 0), "Shin.L": (22, 0, 0), "Thigh.R": (14, 0, 0), "Shin.R": (22, 0, 0)})
    key_pose(arm_obj, 8, {"Hips": (4, 0, 0), "Thigh.L": (-8, 0, 0), "Shin.L": (8, 0, 0), "Thigh.R": (-8, 0, 0), "Shin.R": (8, 0, 0)})
    key_pose(arm_obj, 16, {"Hips": (0, 0, 0), "Thigh.L": (4, 0, 0), "Shin.L": (10, 0, 0), "Thigh.R": (4, 0, 0), "Shin.R": (10, 0, 0)})
    stash_nla(arm_obj, "jump", action)

    if find_action("idle"):
        a = find_action("idle").copy()
        a.name = "dance"
        track = arm_obj.animation_data.nla_tracks.new()
        track.name = "dance"
        track.strips.new("dance", 1, a)


def process_autoroot(src: Path, stem: str) -> None:
    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(src))
    for o in list(bpy.data.objects):
        if o.type == "MESH" and "ico" in o.name.lower() and o.parent is None:
            bpy.data.objects.remove(o, do_unlink=True)
    mesh = join_meshes()
    decimate_mesh(mesh, target_faces=9000)
    mn, mx = world_bounds_objs([mesh])
    print("  bounds size", tuple(round(x, 3) for x in (mx - mn)))
    arm = build_biped(mn, mx)
    bind_proximity(mesh, arm)
    bpy.context.scene.render.fps = 24
    make_simple_anims(arm)
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = arm
    out = OUT_DIR / f"{stem}_rigged.glb"
    main = OUT_DIR / f"{stem}.glb"
    export_selected(out)
    shutil.copy2(out, main)
    print("  WROTE", out.name, out.stat().st_size)


def main() -> None:
    only = set(sys.argv[sys.argv.index("--") + 1 :]) if "--" in sys.argv else set()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for fname, stem, mode in JOBS:
        if only and stem not in only and fname not in only:
            continue
        src = ROOT / fname
        if not src.exists():
            print("SKIP missing", src)
            continue
        print("===", fname, "->", stem, mode)
        try:
            if mode == "quaternius":
                process_quaternius(src, stem)
            else:
                process_autoroot(src, stem)
        except Exception as e:
            print("FAILED", stem, e)
            raise


if __name__ == "__main__":
    main()
