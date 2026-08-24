import bpy
import sys

argv = sys.argv[sys.argv.index("--") + 1 :]
src, dst, ratio = argv[0], argv[1], float(argv[2])

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)


def _decimate_mesh(obj, ratio_value: float) -> None:
    me = obj.data
    print("BEFORE", obj.name, "verts", len(me.vertices), "faces", len(me.polygons))
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="OBJECT")
    # Armature 必须留在栈顶下面：先把 Decimate 挪到 index 0 再 Apply，避免烤死姿势。
    for mod in list(obj.modifiers):
        if mod.type == "ARMATURE":
            mod.show_viewport = False
            mod.show_render = False
    mod = obj.modifiers.new(name="DecimateCapy", type="DECIMATE")
    mod.decimate_type = "COLLAPSE"
    mod.ratio = ratio_value
    mod.use_collapse_triangulate = True
    try:
        bpy.ops.object.modifier_move_to_index(modifier=mod.name, index=0)
    except Exception as exc:
        print("move_to_index failed", exc)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    for mod in obj.modifiers:
        if mod.type == "ARMATURE":
            mod.show_viewport = True
            mod.show_render = True
    print("AFTER", obj.name, "verts", len(obj.data.vertices), "faces", len(obj.data.polygons))
    print("  vgroups", len(obj.vertex_groups), "modifiers", [m.type for m in obj.modifiers])


for obj in list(bpy.data.objects):
    if obj.type != "MESH":
        continue
    if obj.name.lower().startswith("ico"):
        print("SKIP", obj.name)
        continue
    if len(obj.data.vertices) < 500:
        print("SKIP small", obj.name, len(obj.data.vertices))
        continue
    _decimate_mesh(obj, ratio)

bpy.ops.export_scene.gltf(
    filepath=dst,
    export_format="GLB",
    export_extras=False,
    export_yup=True,
    export_apply=False,
    export_animations=True,
    export_skins=True,
    export_all_influences=True,
    export_morph=True,
    export_texcoords=True,
    export_normals=True,
    export_materials="EXPORT",
    export_image_format="AUTO",
)
print("WROTE", dst)
