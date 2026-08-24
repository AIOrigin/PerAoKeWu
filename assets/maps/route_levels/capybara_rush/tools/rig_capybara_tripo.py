#!/usr/bin/env python3
"""Blender: Tripo 卡皮四足绑骨 + run → capybara_base_rigged.glb

glTF 导入 Blender 后：Z=上、Y=身长、X=左右（与能站立的 bak 一致）。
不要把最短轴当身高去转网格，否则会侧躺。
"""
from __future__ import annotations

import math
from pathlib import Path

import bpy
from mathutils import Euler, Vector

SRC = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/capybara_base.glb"
)
OUT = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/capybara_base_rigged.glb"
)


def clear_scene() -> None:
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o, do_unlink=True)
    for b in list(bpy.data.armatures):
        bpy.data.armatures.remove(b)
    for m in list(bpy.data.meshes):
        bpy.data.meshes.remove(m)
    for a in list(bpy.data.actions):
        bpy.data.actions.remove(a)


def world_bounds_objs(objs: list[bpy.types.Object]) -> tuple[Vector, Vector]:
    corners: list[Vector] = []
    for o in objs:
        if o.type != "MESH":
            continue
        corners += [o.matrix_world @ Vector(c) for c in o.bound_box]
    mn = Vector((min(v.x for v in corners), min(v.y for v in corners), min(v.z for v in corners)))
    mx = Vector((max(v.x for v in corners), max(v.y for v in corners), max(v.z for v in corners)))
    return mn, mx


def mesh_points(mesh: bpy.types.Object) -> list[Vector]:
    mw = mesh.matrix_world
    return [mw @ v.co for v in mesh.data.vertices]


def apply_mesh_rotation(mesh: bpy.types.Object, euler_xyz: tuple[float, float, float]) -> None:
    R = Euler(euler_xyz, "XYZ").to_matrix()
    for v in mesh.data.vertices:
        v.co = R @ v.co
    mesh.data.update()
    bpy.context.view_layer.update()


def center_z_up(mesh: bpy.types.Object) -> None:
    """保持导入后的 Z-up；嘴脸转到 -Y；脚底 y 不变、落到 z=0。"""
    pts = mesh_points(mesh)
    print(
        "  import spans",
        tuple(round(max(p[i] for p in pts) - min(p[i] for p in pts), 3) for i in range(3)),
        "(X,Y,Z)",
    )

    # 身长在 Y：尖的一端为脸 → -Y
    ys = [p.y for p in pts]
    y0, y1 = min(ys), max(ys)
    low = [p for p in pts if p.y <= y0 + (y1 - y0) * 0.12]
    high = [p for p in pts if p.y >= y1 - (y1 - y0) * 0.12]

    def tip_score(ps: list[Vector]) -> float:
        if not ps:
            return 0.0
        return (sum(p.z for p in ps) / len(ps)) - 0.00001 * len(ps)

    if tip_score(high) >= tip_score(low):
        apply_mesh_rotation(mesh, (0.0, 0.0, math.pi))
        print("  face was +Y → 180° to -Y")
    else:
        print("  face already toward -Y")

    pts = mesh_points(mesh)
    cx = sum(p.x for p in pts) / len(pts)
    cy = sum(p.y for p in pts) / len(pts)
    cz = min(p.z for p in pts)
    inv = mesh.matrix_world.inverted()
    delta = Vector((cx, cy, cz))
    for v in mesh.data.vertices:
        v.co = inv @ ((mesh.matrix_world @ v.co) - delta)
    mesh.data.update()
    bpy.context.view_layer.objects.active = mesh
    mesh.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    mn, mx = world_bounds_objs([mesh])
    print("  centered", tuple(round(x, 3) for x in (mx - mn)), "feet_z", round(mn.z, 3))


def make_bone(arm, name, head, tip, parent=None):
    b = arm.edit_bones.new(name)
    b.head = head
    b.tail = tip
    if parent and parent in arm.edit_bones:
        b.parent = arm.edit_bones[parent]
        b.use_connect = False
    return b


def build_quadruped(mn: Vector, mx: Vector) -> bpy.types.Object:
    """Blender Z 上、脸 -Y。"""
    cx = (mn.x + mx.x) * 0.5
    sy = max(mx.y - mn.y, 1e-4)
    sx = max(mx.x - mn.x, 1e-4)
    sz = max(mx.z - mn.z, 1e-4)
    half_w = sx * 0.5
    y_nose = mn.y
    y_tail = mx.y
    y_front = y_nose + sy * 0.22
    y_rear = y_tail - sy * 0.18
    ground = mn.z + sz * 0.02
    knee_z = mn.z + sz * 0.22
    hip_z = mn.z + sz * 0.48
    spine_z = mn.z + sz * 0.58
    head_z = mn.z + sz * 0.72

    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm_obj = bpy.context.active_object
    arm_obj.name = "CapyArmature"
    arm = arm_obj.data
    arm.name = "CapyArmature"
    for b in list(arm.edit_bones):
        arm.edit_bones.remove(b)

    make_bone(arm, "Root", Vector((cx, (y_nose + y_tail) * 0.5, ground)), Vector((cx, (y_nose + y_tail) * 0.5, ground + sz * 0.05)))
    make_bone(arm, "Hips", Vector((cx, y_rear, hip_z)), Vector((cx, y_rear, hip_z + sz * 0.04)), "Root")
    make_bone(arm, "Spine", Vector((cx, y_rear, spine_z)), Vector((cx, (y_nose + y_tail) * 0.5, spine_z)), "Hips")
    make_bone(arm, "Chest", Vector((cx, (y_nose + y_tail) * 0.5, spine_z)), Vector((cx, y_front, spine_z)), "Spine")
    make_bone(
        arm,
        "Neck",
        Vector((cx, y_nose + sy * 0.10, head_z - sz * 0.06)),
        Vector((cx, y_nose + sy * 0.04, head_z)),
        "Chest",
    )
    make_bone(
        arm,
        "Head",
        Vector((cx, y_nose + sy * 0.04, head_z)),
        Vector((cx, y_nose - sy * 0.02, head_z + sz * 0.02)),
        "Neck",
    )

    for side, sx_mult in (("L", 1.0), ("R", -1.0)):
        lx = cx + half_w * 0.55 * sx_mult
        make_bone(arm, f"Thigh.F{side}", Vector((lx, y_front, hip_z)), Vector((lx, y_front, knee_z)), "Chest")
        make_bone(arm, f"Shin.F{side}", Vector((lx, y_front, knee_z)), Vector((lx, y_front, ground)), f"Thigh.F{side}")
        make_bone(arm, f"Thigh.B{side}", Vector((lx, y_rear, hip_z)), Vector((lx, y_rear, knee_z)), "Hips")
        make_bone(arm, f"Shin.B{side}", Vector((lx, y_rear, knee_z)), Vector((lx, y_rear, ground)), f"Thigh.B{side}")

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
    mesh.name = "CapyBody"
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return mesh


def decimate_mesh(mesh: bpy.types.Object, target_faces: int = 28000) -> None:
    faces = len(mesh.data.polygons)
    if faces <= target_faces:
        print("  faces", faces, "ok")
        return
    ratio = max(0.08, min(1.0, target_faces / float(faces)))
    print("  decimate", faces, "→ ~", target_faces, "ratio", round(ratio, 3))
    mod = mesh.modifiers.new("Decimate", "DECIMATE")
    mod.ratio = ratio
    bpy.context.view_layer.objects.active = mesh
    bpy.ops.object.modifier_apply(modifier="Decimate")
    print("  faces now", len(mesh.data.polygons))


def bind_quadruped_legs(mesh: bpy.types.Object, arm_obj: bpy.types.Object, mn: Vector, mx: Vector) -> None:
    for g in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(g)
    for m in list(mesh.modifiers):
        if m.type == "ARMATURE":
            mesh.modifiers.remove(m)
    groups = {b.name: mesh.vertex_groups.new(name=b.name) for b in arm_obj.data.bones}

    sz = max(mx.z - mn.z, 1e-4)
    sy = max(mx.y - mn.y, 1e-4)
    cx = (mn.x + mx.x) * 0.5
    mw = mesh.matrix_world
    y_split = mn.y + sy * 0.48

    def smoothstep(edge0: float, edge1: float, x: float) -> float:
        denom = edge1 - edge0
        if abs(denom) < 1e-6:
            return 0.0 if x < edge0 else 1.0
        t = max(0.0, min(1.0, (x - edge0) / denom))
        return t * t * (3.0 - 2.0 * t)

    n_leg = 0
    for vi, v in enumerate(mesh.data.vertices):
        pw = mw @ v.co
        fz = (pw.z - mn.z) / sz
        fy = (pw.y - mn.y) / sy
        weights: dict[str, float] = {}

        if fy < 0.18 and fz > 0.55:
            if fz > 0.78:
                weights["Head"] = 0.85
                weights["Neck"] = 0.15
            else:
                weights["Neck"] = 0.7
                weights["Chest"] = 0.3
        elif fz < 0.55:
            foot_k = smoothstep(0.55, 0.06, fz)
            shin_k = smoothstep(0.36, 0.04, fz)
            is_front = pw.y < y_split
            side = "L" if pw.x >= cx else "R"
            prefix = "F" if is_front else "B"
            thigh = f"Thigh.{prefix}{side}"
            shin = f"Shin.{prefix}{side}"
            leg_total = min(1.0, foot_k * 1.05)
            torso = 1.0 - leg_total
            if torso > 0.01:
                weights["Chest" if is_front else "Hips"] = torso
            if leg_total > 0.01:
                weights[thigh] = leg_total * (1.0 - shin_k * 0.75)
                weights[shin] = leg_total * shin_k * 0.75
                n_leg += 1
        elif fy > 0.72:
            weights["Hips"] = 1.0
        elif fy > 0.40:
            weights["Spine"] = 1.0
        else:
            weights["Chest"] = 1.0

        total = sum(weights.values()) or 1.0
        for name, w in weights.items():
            if name in groups and w > 1e-4:
                groups[name].add([vi], w / total, "REPLACE")

    mesh.parent = arm_obj
    mesh.matrix_parent_inverse = arm_obj.matrix_world.inverted()
    mod = mesh.modifiers.new("Armature", "ARMATURE")
    mod.object = arm_obj
    mod.use_vertex_groups = True
    print("  bound quadruped; leg verts", n_leg)


def key_pose(arm_obj, frame, pose):
    bpy.context.scene.frame_set(frame)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="POSE")
    for pb in arm_obj.pose.bones:
        pb.rotation_mode = "XYZ"
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


def make_capy_anims(arm_obj) -> None:
    """四足小跑：对角成对（FL+BR / FR+BL）。腿骨应朝下，绕局部 X 前后迈。"""
    run = ensure_action(arm_obj, "run")
    run_frames = {
        1: {
            "Hips": (3, 0, 0),
            "Spine": (2, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.FL": (-22, 0, 0),
            "Shin.FL": (16, 0, 0),
            "Thigh.FR": (20, 0, 0),
            "Shin.FR": (34, 0, 0),
            "Thigh.BL": (18, 0, 0),
            "Shin.BL": (30, 0, 0),
            "Thigh.BR": (-20, 0, 0),
            "Shin.BR": (14, 0, 0),
        },
        7: {
            "Hips": (1, 0, 0),
            "Thigh.FL": (-5, 0, 0),
            "Shin.FL": (20, 0, 0),
            "Thigh.FR": (5, 0, 0),
            "Shin.FR": (18, 0, 0),
            "Thigh.BL": (5, 0, 0),
            "Shin.BL": (18, 0, 0),
            "Thigh.BR": (-5, 0, 0),
            "Shin.BR": (20, 0, 0),
        },
        13: {
            "Hips": (3, 0, 0),
            "Spine": (2, 0, 0),
            "Chest": (1, 0, 0),
            "Thigh.FL": (20, 0, 0),
            "Shin.FL": (34, 0, 0),
            "Thigh.FR": (-22, 0, 0),
            "Shin.FR": (16, 0, 0),
            "Thigh.BL": (-20, 0, 0),
            "Shin.BL": (14, 0, 0),
            "Thigh.BR": (18, 0, 0),
            "Shin.BR": (30, 0, 0),
        },
        19: {
            "Hips": (1, 0, 0),
            "Thigh.FL": (5, 0, 0),
            "Shin.FL": (18, 0, 0),
            "Thigh.FR": (-5, 0, 0),
            "Shin.FR": (20, 0, 0),
            "Thigh.BL": (-5, 0, 0),
            "Shin.BL": (20, 0, 0),
            "Thigh.BR": (5, 0, 0),
            "Shin.BR": (18, 0, 0),
        },
        25: None,
    }
    for f, pose in run_frames.items():
        key_pose(arm_obj, f, run_frames[1] if pose is None else pose)
    run.use_cyclic = True
    stash_nla(arm_obj, "run", run)

    idle = ensure_action(arm_obj, "idle")
    stand = {
        "Hips": (0, 0, 0),
        "Thigh.FL": (4, 0, 0),
        "Shin.FL": (10, 0, 0),
        "Thigh.FR": (4, 0, 0),
        "Shin.FR": (10, 0, 0),
        "Thigh.BL": (5, 0, 0),
        "Shin.BL": (12, 0, 0),
        "Thigh.BR": (5, 0, 0),
        "Shin.BR": (12, 0, 0),
    }
    breathe = dict(stand)
    breathe["Hips"] = (2, 0, 0)
    breathe["Chest"] = (2, 0, 0)
    breathe["Head"] = (3, 0, 0)
    key_pose(arm_obj, 1, stand)
    key_pose(arm_obj, 24, breathe)
    key_pose(arm_obj, 48, stand)
    idle.use_cyclic = True
    stash_nla(arm_obj, "idle", idle)

    jump = ensure_action(arm_obj, "jump")
    key_pose(
        arm_obj,
        1,
        {
            "Hips": (-4, 0, 0),
            "Thigh.FL": (18, 0, 0),
            "Shin.FL": (28, 0, 0),
            "Thigh.FR": (18, 0, 0),
            "Shin.FR": (28, 0, 0),
            "Thigh.BL": (18, 0, 0),
            "Shin.BL": (28, 0, 0),
            "Thigh.BR": (18, 0, 0),
            "Shin.BR": (28, 0, 0),
        },
    )
    key_pose(
        arm_obj,
        8,
        {
            "Hips": (8, 0, 0),
            "Thigh.FL": (-16, 0, 0),
            "Shin.FL": (12, 0, 0),
            "Thigh.FR": (-16, 0, 0),
            "Shin.FR": (12, 0, 0),
            "Thigh.BL": (-16, 0, 0),
            "Shin.BL": (12, 0, 0),
            "Thigh.BR": (-16, 0, 0),
            "Shin.BR": (12, 0, 0),
        },
    )
    key_pose(
        arm_obj,
        16,
        {
            "Hips": (0, 0, 0),
            "Thigh.FL": (6, 0, 0),
            "Shin.FL": (14, 0, 0),
            "Thigh.FR": (6, 0, 0),
            "Shin.FR": (14, 0, 0),
            "Thigh.BL": (6, 0, 0),
            "Shin.BL": (14, 0, 0),
            "Thigh.BR": (6, 0, 0),
            "Shin.BR": (14, 0, 0),
        },
    )
    stash_nla(arm_obj, "jump", jump)

    dance = ensure_action(arm_obj, "dance")
    key_pose(arm_obj, 1, {"Head": (0, 0, -8), "Neck": (0, 0, -4)})
    key_pose(arm_obj, 12, {"Head": (0, 0, 8), "Neck": (0, 0, 4)})
    key_pose(arm_obj, 24, {"Head": (0, 0, -8), "Neck": (0, 0, -4)})
    dance.use_cyclic = True
    stash_nla(arm_obj, "dance", dance)

    head = ensure_action(arm_obj, "capy_head_look")
    key_pose(arm_obj, 1, {"Head": (0, 0, 0), "Neck": (0, 0, 0)})
    key_pose(arm_obj, 10, {"Head": (0, 8, 12), "Neck": (0, 4, 6)})
    key_pose(arm_obj, 20, {"Head": (0, -6, -10), "Neck": (0, -3, -5)})
    key_pose(arm_obj, 30, {"Head": (0, 0, 0), "Neck": (0, 0, 0)})
    head.use_cyclic = True
    stash_nla(arm_obj, "capy_head_look", head)

    finish = ensure_action(arm_obj, "capy_finish_dance")
    key_pose(arm_obj, 1, {"Head": (0, 0, 0), "Hips": (0, 0, 0)})
    key_pose(arm_obj, 8, {"Head": (0, 10, 14), "Hips": (2, 0, 0)})
    key_pose(arm_obj, 16, {"Head": (0, -8, -12), "Hips": (0, 0, 0)})
    finish.use_cyclic = True
    stash_nla(arm_obj, "capy_finish_dance", finish)


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


def main() -> None:
    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(SRC))
    for o in list(bpy.data.objects):
        if o.type in {"EMPTY", "ARMATURE"}:
            bpy.data.objects.remove(o, do_unlink=True)
    mesh = join_meshes()
    decimate_mesh(mesh, target_faces=28000)
    center_z_up(mesh)
    mn, mx = world_bounds_objs([mesh])
    print("bounds", tuple(round(x, 3) for x in (mx - mn)), "faces", len(mesh.data.polygons))
    arm = build_quadruped(mn, mx)
    bind_quadruped_legs(mesh, arm, mn, mx)
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
    make_capy_anims(arm)
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = arm
    export_selected(OUT)
    print("WROTE", OUT, OUT.stat().st_size)


if __name__ == "__main__":
    main()
