#!/usr/bin/env python3
"""Add a looping twist-dance clip to every playable *_rigged.glb.

Keeps run / idle / jump (and extra Quaternius clips). Only replaces `dance`.
Does not remesh or rebind.
"""
from __future__ import annotations

import math
import shutil
import sys
from pathlib import Path

import bpy
from mathutils import Euler, Vector

CHAR_DIR = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters"
)

SOFT = {"bird", "mouse", "sloth", "tiny_planet", "bear"}

# 1.5s loop @ 24fps
FRAMES = (1, 10, 19, 28, 37)


def _activate(obj) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    if obj.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")


def _pick(names: set[str], *cands: str) -> str | None:
    for c in cands:
        if c in names:
            return c
    return None


def _bone_roles(arm) -> dict[str, str]:
    names = {b.name for b in arm.pose.bones}
    return {
        "hips": _pick(names, "Hips", "Body"),
        "spine": _pick(names, "Spine", "Abdomen", "Back", "Torso"),
        "chest": _pick(names, "Chest", "Torso2", "Torso"),
        "neck": _pick(names, "Neck", "Neck1"),
        "head": _pick(names, "Head"),
        "arm_l": _pick(names, "UpperArm.L"),
        "arm_r": _pick(names, "UpperArm.R"),
        "fore_l": _pick(names, "LowerArm.L"),
        "fore_r": _pick(names, "LowerArm.R"),
        "thigh_l": _pick(names, "Thigh.L", "UpperLeg.L"),
        "thigh_r": _pick(names, "Thigh.R", "UpperLeg.R"),
        "thigh_fl": _pick(names, "Thigh.FL", "FrontUpperLeg.L"),
        "thigh_fr": _pick(names, "Thigh.FR", "FrontUpperLeg.R"),
        "thigh_bl": _pick(names, "Thigh.BL", "BackUpperLeg.L"),
        "thigh_br": _pick(names, "Thigh.BR", "BackUpperLeg.R"),
        "tail": _pick(names, "Tail1", "Tail2"),
        "torso3": _pick(names, "Torso3"),
        "neck2": _pick(names, "Neck2"),
    }


def _remove_dance(arm) -> None:
    ad = arm.animation_data
    if ad:
        for track in list(ad.nla_tracks):
            if track.name.lower() == "dance":
                ad.nla_tracks.remove(track)
        if ad.action is not None and ad.action.name.lower() == "dance":
            ad.action = None
    used: set[int] = set()
    for obj in bpy.data.objects:
        if obj.animation_data is None:
            continue
        for track in obj.animation_data.nla_tracks:
            for strip in track.strips:
                if strip.action is not None:
                    used.add(id(strip.action))
        if obj.animation_data.action is not None:
            used.add(id(obj.animation_data.action))
    for action in list(bpy.data.actions):
        if action.name.lower() == "dance" and id(action) not in used:
            bpy.data.actions.remove(action)


def _stash(arm, name: str, action) -> None:
    if arm.animation_data is None:
        arm.animation_data_create()
    track = arm.animation_data.nla_tracks.new()
    track.name = name
    start = int(action.frame_range[0]) if action.frame_range else 1
    track.strips.new(name, max(start, 1), action)
    arm.animation_data.action = None


def _e(deg: tuple[float, float, float]) -> Euler:
    return Euler(tuple(math.radians(a) for a in deg), "XYZ")


def _key(arm, frame: int, pose: dict[str, tuple[float, float, float]], loc: dict[str, Vector] | None = None) -> None:
    bpy.context.scene.frame_set(frame)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="POSE")
    for bname, eulers in pose.items():
        pb = arm.pose.bones.get(bname)
        if pb is None:
            continue
        pb.rotation_mode = "XYZ"
        pb.rotation_euler = _e(eulers)
        pb.keyframe_insert(data_path="rotation_euler", frame=frame)
    if loc:
        for bname, vec in loc.items():
            pb = arm.pose.bones.get(bname)
            if pb is None:
                continue
            pb.location = vec
            pb.keyframe_insert(data_path="location", frame=frame)
    bpy.ops.object.mode_set(mode="OBJECT")


def _scale_pose(pose: dict, mul: float) -> dict:
    return {k: (v[0] * mul, v[1] * mul, v[2] * mul) for k, v in pose.items()}


def _build_poses(roles: dict[str, str], style: str, mul: float) -> list[dict]:
    """Five poses: center, left-twist, bounce-center, right-twist, center."""
    h = roles.get("hips")
    sp = roles.get("spine")
    ch = roles.get("chest")
    nk = roles.get("neck")
    hd = roles.get("head")
    al = roles.get("arm_l")
    ar = roles.get("arm_r")
    fl = roles.get("fore_l")
    fr = roles.get("fore_r")
    tl = roles.get("thigh_l")
    tr = roles.get("thigh_r")
    tfl = roles.get("thigh_fl")
    tfr = roles.get("thigh_fr")
    tbl = roles.get("thigh_bl")
    tbr = roles.get("thigh_br")
    tail = roles.get("tail")
    t3 = roles.get("torso3")
    nk2 = roles.get("neck2")

    def put(d, bone, eul):
        if bone:
            d[bone] = eul

    center: dict = {}
    left: dict = {}
    bounce: dict = {}
    right: dict = {}

    if style == "quad":
        put(center, h, (0, 0, 0))
        put(center, hd, (2, 0, 0))
        put(left, h, (4, 2, 20))
        put(left, sp, (3, 0, -14))
        put(left, ch, (4, 0, -10))
        put(left, nk, (6, 0, 8))
        put(left, hd, (10, 4, 14))
        put(left, tfl, (6, 0, 4))
        put(left, tbl, (5, 0, 4))
        put(left, tfr, (3, 0, -3))
        put(left, tbr, (3, 0, -3))
        put(bounce, h, (3, 0, 0))
        put(bounce, ch, (5, 0, 0))
        put(bounce, hd, (8, 0, 0))
        put(right, h, (4, -2, -20))
        put(right, sp, (3, 0, 14))
        put(right, ch, (4, 0, 10))
        put(right, nk, (6, 0, -8))
        put(right, hd, (10, -4, -14))
        put(right, tfr, (6, 0, -4))
        put(right, tbr, (5, 0, -4))
        put(right, tfl, (3, 0, 3))
        put(right, tbl, (3, 0, 3))
    elif style == "shiba":
        put(center, h, (0, 0, 0))
        put(left, h, (3, 0, 16))
        put(left, sp, (4, 0, -12))
        put(left, ch, (6, 0, -10))
        put(left, t3, (4, 0, -6))
        put(left, nk, (8, 0, 10))
        put(left, nk2, (6, 0, 8))
        put(left, hd, (12, 6, 14))
        put(left, tail, (8, 0, -22))
        put(bounce, h, (2, 0, 0))
        put(bounce, ch, (6, 0, 0))
        put(bounce, hd, (8, 0, 0))
        put(bounce, tail, (12, 0, 0))
        put(right, h, (3, 0, -16))
        put(right, sp, (4, 0, 12))
        put(right, ch, (6, 0, 10))
        put(right, t3, (4, 0, 6))
        put(right, nk, (8, 0, -10))
        put(right, nk2, (6, 0, -8))
        put(right, hd, (12, -6, -14))
        put(right, tail, (8, 0, 22))
    else:
        # biped / rabbit
        put(center, h, (0, 0, 0))
        put(left, h, (3, 4, 22))
        put(left, sp, (4, 0, -16))
        put(left, ch, (6, 0, -12))
        put(left, nk, (8, 0, 10))
        put(left, hd, (12, 6, 16))
        put(left, al, (-28, -16, 20))
        put(left, ar, (8, 10, -8))
        put(left, fl, (24, 0, 0))
        put(left, fr, (10, 0, 0))
        put(left, tl, (6, 0, 5))
        put(left, tr, (4, 0, -4))
        put(bounce, h, (2, 0, 0))
        put(bounce, ch, (6, 0, 0))
        put(bounce, hd, (8, 0, 0))
        put(bounce, al, (-12, -10, 0))
        put(bounce, ar, (-12, 10, 0))
        put(right, h, (3, -4, -22))
        put(right, sp, (4, 0, 16))
        put(right, ch, (6, 0, 12))
        put(right, nk, (8, 0, -10))
        put(right, hd, (12, -6, -16))
        put(right, ar, (-28, 16, -20))
        put(right, al, (8, -10, 8))
        put(right, fr, (24, 0, 0))
        put(right, fl, (10, 0, 0))
        put(right, tr, (6, 0, -5))
        put(right, tl, (4, 0, 4))

    return [
        _scale_pose(center, mul),
        _scale_pose(left, mul),
        _scale_pose(bounce, mul),
        _scale_pose(right, mul),
        _scale_pose(center, mul),
    ]


def _hip_locs(roles: dict[str, str], mul: float) -> list[dict[str, Vector]]:
    hips = roles.get("hips")
    if not hips:
        return [{}, {}, {}, {}, {}]
    z = 0.018 * mul
    return [
        {hips: Vector((0, 0, 0))},
        {hips: Vector((0.008 * mul, 0, z))},
        {hips: Vector((0, 0, z * 1.4))},
        {hips: Vector((-0.008 * mul, 0, z))},
        {hips: Vector((0, 0, 0))},
    ]


def _detect_style(arm) -> str:
    names = {b.name for b in arm.pose.bones}
    if "Thigh.FL" in names:
        return "quad"
    if "FrontUpperLeg.L" in names or "Torso2" in names:
        return "shiba"
    return "biped"


def _make_dance(arm, stem: str) -> None:
    _remove_dance(arm)
    if arm.animation_data is None:
        arm.animation_data_create()
    action = bpy.data.actions.new(name="dance")
    arm.animation_data.action = action
    roles = _bone_roles(arm)
    style = _detect_style(arm)
    mul = 0.52 if stem in SOFT else 1.0
    poses = _build_poses(roles, style, mul)
    locs = _hip_locs(roles, mul)
    for frame, pose, loc in zip(FRAMES, poses, locs):
        _key(arm, frame, pose, loc)
    action.use_cyclic = True
    _stash(arm, "dance", action)
    print(
        "  dance",
        stem,
        style,
        "mul",
        mul,
        "bones",
        sorted({k for p in poses for k in p}),
    )


def _export(path: Path) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.data.objects:
        if obj.type in {"MESH", "ARMATURE"}:
            obj.select_set(True)
    arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
    if arms:
        bpy.context.view_layer.objects.active = arms[0]
    kw = dict(
        filepath=str(path),
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
        export_nla_strips=True,
        export_anim_single_armature=True,
    )
    try:
        bpy.ops.export_scene.gltf(**kw, export_all_influences=True, export_morph=True)
    except TypeError:
        bpy.ops.export_scene.gltf(**kw)
    print("WROTE", path, path.stat().st_size if path.is_file() else 0)


def process(src: Path) -> None:
    stem = src.name.replace("_rigged.glb", "")
    bak = src.with_suffix(src.suffix + ".bak_before_dance")
    if not bak.exists():
        shutil.copy2(src, bak)
        print("backup", bak.name)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(src))
    arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
    if not arms:
        print("SKIP no armature", src.name)
        return
    arm = arms[0]
    bpy.context.scene.render.fps = 24
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = 37
    _make_dance(arm, stem)
    _export(src)


def main() -> None:
    files = sorted(CHAR_DIR.glob("*_rigged.glb"))
    if "--" in sys.argv:
        names = sys.argv[sys.argv.index("--") + 1 :]
        if names:
            files = [CHAR_DIR / n if n.endswith(".glb") else CHAR_DIR / f"{n}_rigged.glb" for n in names]
    for src in files:
        if not src.exists():
            print("missing", src)
            continue
        print("\n===", src.name, "===")
        process(src)


if __name__ == "__main__":
    main()
