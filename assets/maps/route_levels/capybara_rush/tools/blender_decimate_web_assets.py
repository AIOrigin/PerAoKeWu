#!/usr/bin/env python3
"""Batch decimate + downscale textures for Web CDN GLBs (props/env/obstacles/characters)."""
from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[1]
MODELS = ROOT / "models"
BACKUP = MODELS / "_decimate_backup"
GDIGNORE = BACKUP / ".gdignore"

# ratio -1 = 只压贴图，不动网格（Tripo 模型 decimate 容易破面）
RULES: dict[str, tuple[str, float, int]] = {
    "props": ("props/*.glb", -1.0, 512),
    "environment": ("environment/*.glb", -1.0, 512),
    "obstacles": ("obstacles/*.glb", -1.0, 512),
    "characters": ("characters/*_rigged.glb", -1.0, 1024),
}


def _parse_args() -> tuple[list[str], bool]:
    argv = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    in_place = "--in-place" in argv
    cats = [a for a in argv if a in RULES]
    if not cats:
        cats = list(RULES.keys())
    return cats, in_place


def _clear_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def _downscale_textures(max_edge: int) -> None:
    for img in list(bpy.data.images):
        if img.size[0] <= 0 or img.size[1] <= 0:
            continue
        longest = max(img.size[0], img.size[1])
        if longest <= max_edge:
            continue
        scale = max_edge / float(longest)
        nw = max(4, int(img.size[0] * scale))
        nh = max(4, int(img.size[1] * scale))
        print(f"  tex {img.name}: {img.size[0]}x{img.size[1]} -> {nw}x{nh}")
        img.scale(nw, nh)


def _force_opaque_materials() -> None:
    for mat in bpy.data.materials:
        if mat is None:
            continue
        mat.blend_method = "OPAQUE"
        mat.use_backface_culling = True
        if mat.node_tree:
            for node in mat.node_tree.nodes:
                if node.type == "BSDF_PRINCIPLED":
                    node.inputs["Alpha"].default_value = 1.0


def _remove_helper_meshes() -> None:
    for obj in list(bpy.data.objects):
        if obj.type != "MESH":
            continue
        name = obj.name.lower()
        if name in {"icosphere", "ico_sphere"} or name.startswith("ico"):
            bpy.data.objects.remove(obj, do_unlink=True)


def _decimate_mesh(obj: bpy.types.Object, ratio: float) -> None:
    if obj.type != "MESH" or len(obj.data.vertices) < 400:
        return
    if obj.name.lower().startswith("ico"):
        return
    me = obj.data
    print(
        f"  mesh {obj.name}: v={len(me.vertices)} f={len(me.polygons)} ratio={ratio}"
    )
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="OBJECT")
    for mod in list(obj.modifiers):
        if mod.type == "ARMATURE":
            mod.show_viewport = False
            mod.show_render = False
    dec = obj.modifiers.new(name="DecimateWeb", type="DECIMATE")
    dec.decimate_type = "COLLAPSE"
    dec.ratio = ratio
    dec.use_collapse_triangulate = True
    try:
        bpy.ops.object.modifier_move_to_index(modifier=dec.name, index=0)
    except Exception:
        pass
    bpy.ops.object.modifier_apply(modifier=dec.name)
    for mod in obj.modifiers:
        if mod.type == "ARMATURE":
            mod.show_viewport = True
            mod.show_render = True
    print(f"    -> v={len(obj.data.vertices)} f={len(obj.data.polygons)}")


def _process_glb(src: Path, ratio: float, max_tex: int, in_place: bool) -> dict:
    before = src.stat().st_size
    backup_path = BACKUP / src.relative_to(MODELS)
    if in_place and not backup_path.exists():
        backup_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, backup_path)
        if not GDIGNORE.exists():
            GDIGNORE.parent.mkdir(parents=True, exist_ok=True)
            GDIGNORE.touch()

    _clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(src))
    _downscale_textures(max_tex)
    if ratio > 0.0:
        for obj in list(bpy.data.objects):
            if obj.type == "MESH":
                _decimate_mesh(obj, ratio)
    _remove_helper_meshes()
    _force_opaque_materials()

    out = src if in_place else src.with_name(src.stem + "_lite.glb")
    has_armature = any(o.type == "ARMATURE" for o in bpy.data.objects)
    bpy.ops.export_scene.gltf(
        filepath=str(out),
        export_format="GLB",
        export_extras=False,
        export_yup=True,
        export_apply=False,
        export_animations=has_armature,
        export_skins=has_armature,
        export_all_influences=has_armature,
        export_morph=False,
        export_texcoords=True,
        export_normals=True,
        export_materials="EXPORT",
        export_image_format="JPEG",
        export_jpeg_quality=78,
    )
    after = out.stat().st_size
    pct = (1.0 - after / before) * 100.0 if before else 0.0
    print(f"WROTE {out.name}: {before/1024/1024:.2f}MB -> {after/1024/1024:.2f}MB ({pct:.0f}% smaller)")
    return {
        "file": str(src.relative_to(MODELS)),
        "before": before,
        "after": after,
        "ratio": ratio,
    }


def main() -> None:
    cats, in_place = _parse_args()
    report: list[dict] = []
    for cat in cats:
        glob_pat, ratio, max_tex = RULES[cat]
        files = sorted(MODELS.glob(glob_pat))
        print(f"\n=== {cat} ({len(files)} files) ratio={ratio} tex={max_tex} ===")
        for src in files:
            if not src.is_file():
                continue
            try:
                report.append(_process_glb(src, ratio, max_tex, in_place))
            except Exception as exc:
                print(f"FAIL {src}: {exc}")
    summary = {
        "categories": cats,
        "files": len(report),
        "before_mb": sum(r["before"] for r in report) / 1024 / 1024,
        "after_mb": sum(r["after"] for r in report) / 1024 / 1024,
        "items": report,
    }
    out_json = ROOT / "tools" / "decimate_web_report.json"
    out_json.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(
        f"\nDONE {summary['files']} files: "
        f"{summary['before_mb']:.1f}MB -> {summary['after_mb']:.1f}MB"
    )
    print(f"report -> {out_json}")


if __name__ == "__main__":
    main()
