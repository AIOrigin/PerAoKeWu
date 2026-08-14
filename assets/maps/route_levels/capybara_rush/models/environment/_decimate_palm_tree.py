#!/usr/bin/env python3
"""Headless Blender: join + decimate palm_tree.glb to ~TARGET_TRIS."""
from __future__ import annotations

import os
import shutil

import bpy

TARGET_TRIS = 5000
TOLERANCE = 0.12  # accept 5000 ± 12%
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_GLB = os.path.join(SCRIPT_DIR, "palm_tree.glb")
BACKUP_GLB = os.path.join(SCRIPT_DIR, "palm_tree_high.glb")
OUTPUT_GLB = INPUT_GLB


def tri_count(obj: bpy.types.Object) -> int:
    if obj.type != "MESH" or obj.data is None:
        return 0
    return len(obj.data.polygons)


def total_tris() -> int:
    return sum(tri_count(o) for o in bpy.data.objects if o.type == "MESH")


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in (
        bpy.data.meshes,
        bpy.data.materials,
        bpy.data.images,
        bpy.data.armatures,
        bpy.data.actions,
    ):
        for item in list(block):
            block.remove(item)


def import_glb(path: str) -> list[bpy.types.Object]:
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    after = set(bpy.data.objects)
    imported = [o for o in after - before if o.type == "MESH"]
    if not imported:
        imported = [o for o in bpy.data.objects if o.type == "MESH"]
    return imported


def join_meshes(meshes: list[bpy.types.Object]) -> bpy.types.Object:
    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    joined = bpy.context.view_layer.objects.active
    joined.name = "PalmTree"
    return joined


def apply_decimate(obj: bpy.types.Object, ratio: float) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    mod = obj.modifiers.new(name="Decimate", type="DECIMATE")
    mod.decimate_type = "COLLAPSE"
    mod.ratio = max(0.001, min(1.0, ratio))
    mod.use_collapse_triangulate = True
    bpy.ops.object.modifier_apply(modifier=mod.name)


def decimate_to_target(obj: bpy.types.Object, target: int) -> int:
    start = tri_count(obj)
    if start <= target:
        return start

    ratio = target / float(start)
    apply_decimate(obj, ratio)
    current = tri_count(obj)

    # Fine tune with a second pass if needed
    if current > target * (1.0 + TOLERANCE):
        ratio2 = target / float(current)
        apply_decimate(obj, ratio2)
        current = tri_count(obj)
    return current


def export_glb(path: str, obj: bpy.types.Object) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_materials="EXPORT",
        export_image_format="AUTO",
    )


def main() -> None:
    if not os.path.isfile(INPUT_GLB):
        raise SystemExit(f"Missing input: {INPUT_GLB}")

    if not os.path.isfile(BACKUP_GLB):
        shutil.copy2(INPUT_GLB, BACKUP_GLB)
        print(f"Backup saved: {BACKUP_GLB}")

    clear_scene()
    meshes = import_glb(INPUT_GLB)
    if not meshes:
        raise SystemExit("No mesh objects imported.")

    print(f"Imported {len(meshes)} mesh(es), {total_tris()} tris")
    palm = join_meshes(meshes) if len(meshes) > 1 else meshes[0]
    palm.name = "PalmTree"
    before_join_tris = tri_count(palm)
    final_tris = decimate_to_target(palm, TARGET_TRIS)
    export_glb(OUTPUT_GLB, palm)
    print(
        f"Done: {before_join_tris} -> {final_tris} tris "
        f"(target {TARGET_TRIS}) -> {OUTPUT_GLB}"
    )


main()
