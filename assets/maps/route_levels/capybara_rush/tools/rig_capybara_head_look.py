#!/usr/bin/env python3
"""Blender: 仅 Head/Neck 绑骨，供赛道卡皮巴拉「只扭头、身体不动」"""
from __future__ import annotations

from pathlib import Path

import bpy
from mathutils import Vector

SRC = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/capybara_base.glb"
)
OUT = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/capybara_base_rigged.glb"
)


def clear_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def world_bounds(mesh: bpy.types.Object) -> tuple[Vector, Vector]:
    corners = [mesh.matrix_world @ Vector(c) for c in mesh.bound_box]
    mn = Vector((min(v.x for v in corners), min(v.y for v in corners), min(v.z for v in corners)))
    mx = Vector((max(v.x for v in corners), max(v.y for v in corners), max(v.z for v in corners)))
    return mn, mx


def make_bone(arm, name, head, tip, parent: str | None = None):
    b = arm.edit_bones.new(name)
    b.head = head
    b.tail = tip
    if parent and parent in arm.edit_bones:
        b.parent = arm.edit_bones[parent]
        b.use_connect = False
    return b


def build_head_armature(mn: Vector, mx: Vector) -> bpy.types.Object:
    """Tripo 卡皮：鼻朝 -Z（mn.z），头在前端。"""
    cx = (mn.x + mx.x) * 0.5
    cy = (mn.y + mx.y) * 0.5
    z_nose = mn.z
    sz = max(mx.z - mn.z, 1e-4)
    sy = max(mx.y - mn.y, 1e-4)
    top_y = mn.y + sy * 0.72

    bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
    arm_obj = bpy.context.active_object
    arm_obj.name = "CapyHeadArmature"
    arm = arm_obj.data
    arm.name = "CapyHeadArmature"
    for b in list(arm.edit_bones):
        arm.edit_bones.remove(b)

    # Body 不参与扭头，锁住躯干
    make_bone(
        arm,
        "Body",
        Vector((cx, cy, z_nose + sz * 0.22)),
        Vector((cx, cy, mx.z - sz * 0.05)),
    )
    make_bone(
        arm,
        "Neck",
        Vector((cx, cy, z_nose + sz * 0.16)),
        Vector((cx, top_y, z_nose + sz * 0.22)),
        "Body",
    )
    make_bone(
        arm,
        "Head",
        Vector((cx, top_y, z_nose + sz * 0.06)),
        Vector((cx, top_y, z_nose + sz * 0.02)),
        "Neck",
    )

    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


def bind_head_only(mesh: bpy.types.Object, arm_obj: bpy.types.Object, mn: Vector, mx: Vector) -> None:
    for g in list(mesh.vertex_groups):
        mesh.vertex_groups.remove(g)
    g_body = mesh.vertex_groups.new(name="Body")
    g_neck = mesh.vertex_groups.new(name="Neck")
    g_head = mesh.vertex_groups.new(name="Head")

    sz = max(mx.z - mn.z, 1e-4)
    sy = max(mx.y - mn.y, 1e-4)
    mw = mesh.matrix_world
    n_head = n_neck = n_body = 0

    for vi, v in enumerate(mesh.data.vertices):
        pw = mw @ v.co
        fz = (pw.z - mn.z) / sz  # 0=鼻端, 1=尾端
        fy = (pw.y - mn.y) / sy  # 0=脚底, 1=背顶
        # 四足：前腿也在 fz 小的一端，必须同时看高度 fy，否则腿会跟头一起拧
        if fy < 0.38:
            g_body.add([vi], 1.0, "REPLACE")
            n_body += 1
        elif fz < 0.19 and fy > 0.58:
            g_head.add([vi], 0.88, "REPLACE")
            g_neck.add([vi], 0.12, "REPLACE")
            n_head += 1
        elif fz < 0.30 and fy > 0.44:
            g_neck.add([vi], 0.82, "REPLACE")
            g_body.add([vi], 0.18, "REPLACE")
            n_neck += 1
        else:
            g_body.add([vi], 1.0, "REPLACE")
            n_body += 1
    print(f"  weights head={n_head} neck={n_neck} body={n_body}")

    mesh.parent = arm_obj
    mesh.matrix_parent_inverse = arm_obj.matrix_world.inverted()
    mod = mesh.modifiers.new("Armature", "ARMATURE")
    mod.object = arm_obj
    mod.use_vertex_groups = True
    print("  head-only weights bound")


def export_selected(path: Path) -> None:
    kwargs = dict(
        filepath=str(path),
        export_format="GLB",
        export_animations=False,
        export_skins=True,
        export_morph=False,
        export_apply=False,
        export_yup=True,
        use_selection=True,
    )
    bpy.ops.export_scene.gltf(**kwargs)


def main() -> None:
    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(SRC))
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError("no mesh")
    mesh = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.select_all(action="DESELECT")
        for m in meshes:
            m.select_set(True)
        bpy.context.view_layer.objects.active = meshes[0]
        bpy.ops.object.join()
        mesh = bpy.context.active_object
    mesh.name = "CapyBody"
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    mn, mx = world_bounds(mesh)
    print("bounds", tuple(round(x, 3) for x in (mx - mn)), "faces", len(mesh.data.polygons))
    arm = build_head_armature(mn, mx)
    bind_head_only(mesh, arm, mn, mx)

    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    mesh.select_set(True)
    bpy.context.view_layer.objects.active = arm
    export_selected(OUT)
    print("WROTE", OUT, OUT.stat().st_size)


if __name__ == "__main__":
    main()
