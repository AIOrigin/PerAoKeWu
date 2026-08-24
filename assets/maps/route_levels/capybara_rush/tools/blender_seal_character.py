#!/usr/bin/env python3
"""Close Tripo triangle-soup meshes so Godot stops showing white through cracks."""
import os
import sys

import bpy
import bmesh

argv = sys.argv[sys.argv.index("--") + 1 :]
src_path, dst_path = argv[0], argv[1]
clean_png = argv[2] if len(argv) > 2 and argv[2] else ""
voxel_size = float(argv[3]) if len(argv) > 3 else 0.008


def _activate(obj) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    if obj.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")


def _mesh_stats(obj) -> dict:
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.edges.ensure_lookup_table()
    out = {
        "verts": len(obj.data.vertices),
        "faces": len(obj.data.polygons),
        "boundary": sum(1 for e in bm.edges if e.is_boundary),
        "nonmanifold": sum(1 for e in bm.edges if not e.is_manifold),
    }
    bm.free()
    return out


def _clear_modifiers(obj) -> None:
    for mod in list(obj.modifiers):
        obj.modifiers.remove(mod)


def _force_opaque_material(mat) -> None:
    if mat is None:
        return
    mat.use_nodes = True
    if hasattr(mat, "use_transparent_shadow"):
        mat.use_transparent_shadow = False
    if hasattr(mat, "use_backface_culling"):
        mat.use_backface_culling = True
    nt = mat.node_tree
    if nt is None:
        return
    principled = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if principled is None:
        return
    for sock_name, value in (
        ("Alpha", 1.0),
        ("Metallic", 0.0),
        ("Transmission", 0.0),
        ("Transmission Weight", 0.0),
        ("Coat Weight", 0.0),
        ("Sheen Weight", 0.0),
        ("Specular IOR Level", 0.0),
        ("Specular", 0.0),
        ("Roughness", 1.0),
        ("Emission Strength", 0.0),
    ):
        sock = principled.inputs.get(sock_name)
        if sock is None:
            continue
        for link in list(sock.links):
            nt.links.remove(link)
        if sock.type == "VALUE":
            sock.default_value = value
    for sock_name in (
        "Normal",
        "Roughness",
        "Metallic",
        "Specular",
        "Specular IOR Level",
        "Coat Weight",
        "Sheen Weight",
        "Transmission",
        "Transmission Weight",
        "Alpha",
        "Emission",
        "Emission Color",
    ):
        sock = principled.inputs.get(sock_name)
        if sock is None:
            continue
        for link in list(sock.links):
            nt.links.remove(link)
    base = principled.inputs.get("Base Color")
    if base is None:
        return
    if clean_png and os.path.isfile(clean_png):
        for link in list(base.links):
            nt.links.remove(link)
        img = bpy.data.images.load(clean_png, check_existing=True)
        img.alpha_mode = "NONE"
        img.colorspace_settings.name = "sRGB"
        tex = nt.nodes.new("ShaderNodeTexImage")
        tex.image = img
        tex.location = (principled.location.x - 360, principled.location.y)
        nt.links.new(tex.outputs["Color"], base)
        print("WIRED_CLEAN_PNG", mat.name, clean_png)
    else:
        for link in list(base.links):
            from_node = link.from_node
            if from_node.type == "TEX_IMAGE" and from_node.image:
                from_node.image.alpha_mode = "NONE"


def _duplicate_mesh(obj, name: str):
    dup = obj.copy()
    dup.data = obj.data.copy()
    dup.name = name
    bpy.context.collection.objects.link(dup)
    dup.parent = obj.parent
    dup.matrix_world = obj.matrix_world.copy()
    return dup


def _voxel_remesh(obj, size: float) -> None:
    _activate(obj)
    _clear_modifiers(obj)
    mod = obj.modifiers.new(name="VoxelRemesh", type="REMESH")
    mod.mode = "VOXEL"
    mod.voxel_size = size
    mod.adaptivity = 0.0
    bpy.ops.object.modifier_apply(modifier=mod.name)


def _transfer_uv_and_weights(dst, src) -> None:
    _activate(dst)
    for vg in src.vertex_groups:
        if vg.name not in dst.vertex_groups:
            dst.vertex_groups.new(name=vg.name)
    if dst.data.uv_layers.active is None:
        dst.data.uv_layers.new(name="UVMap")
    mod = dst.modifiers.new(name="TransferSrc", type="DATA_TRANSFER")
    mod.object = src
    mod.use_vert_data = True
    mod.data_types_verts = {"VGROUP_WEIGHTS"}
    mod.vert_mapping = "POLYINTERP_NEAREST"
    mod.layers_vgroup_select_src = "ALL"
    mod.mix_mode = "REPLACE"
    mod.use_loop_data = True
    mod.data_types_loops = {"UV"}
    mod.loop_mapping = "POLYINTERP_NEAREST"
    try:
        bpy.ops.object.datalayout_transfer(modifier=mod.name)
    except Exception as exc:
        print("datalayout_transfer", exc)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    print("TRANSFER", dst.name, "vgroups", len(dst.vertex_groups), "uvs", len(dst.data.uv_layers))


def _shade_smooth(obj) -> None:
    _activate(obj)
    for poly in obj.data.polygons:
        poly.use_smooth = True
    try:
        bpy.ops.object.shade_smooth()
    except Exception:
        pass


bpy.ops.wm.read_factory_settings(use_empty=True)
print("IMPORT", src_path)
bpy.ops.import_scene.gltf(filepath=src_path)

# Junk leftover from some Blender sessions / unused orange proxy
for obj in list(bpy.data.objects):
    if obj.type == "MESH" and obj.name.startswith("Icosphere") and len(obj.data.vertices) <= 80:
        print("DROP", obj.name, len(obj.data.vertices))
        bpy.data.objects.remove(obj, do_unlink=True)

bodies = [o for o in bpy.data.objects if o.type == "MESH" and len(o.data.vertices) >= 200]
arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
if not bodies:
    raise RuntimeError("no body mesh")
body = max(bodies, key=lambda o: len(o.data.vertices))
arm = body.parent if body.parent and body.parent.type == "ARMATURE" else (arms[0] if arms else None)
print("BEFORE", body.name, _mesh_stats(body), "arm", arm.name if arm else None)

src = _duplicate_mesh(body, body.name + "_SRC")
_voxel_remesh(body, voxel_size)
print("REMESH", _mesh_stats(body))
_transfer_uv_and_weights(body, src)
bpy.data.objects.remove(src, do_unlink=True)

_clear_modifiers(body)
if arm is not None:
    body.parent = arm
    arm_mod = body.modifiers.new(name="Armature", type="ARMATURE")
    arm_mod.object = arm
    arm_mod.use_vertex_groups = True

_shade_smooth(body)
for img in bpy.data.images:
    img.alpha_mode = "NONE"
for mat in bpy.data.materials:
    _force_opaque_material(mat)
if not body.material_slots:
    mat = bpy.data.materials.new("CapyOpaque")
    body.data.materials.append(mat)
    _force_opaque_material(mat)

print("AFTER", body.name, _mesh_stats(body))

os.makedirs(os.path.dirname(dst_path) or ".", exist_ok=True)
export_kw = dict(
    filepath=dst_path,
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
    bpy.ops.export_scene.gltf(
        **export_kw,
        export_all_influences=True,
        export_morph=True,
        export_vertex_color="NONE",
    )
except TypeError:
    bpy.ops.export_scene.gltf(**export_kw)
print("WROTE", dst_path, os.path.getsize(dst_path) if os.path.isfile(dst_path) else 0)
