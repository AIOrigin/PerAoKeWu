import bpy
import sys

argv = sys.argv[sys.argv.index("--") + 1 :]
src_path, donor_path, dst_path, target_verts = argv[0], argv[1], argv[2], int(argv[3])


def _import(path: str, prefix: str) -> list:
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    new = [o for o in bpy.data.objects if o not in before]
    for o in new:
        o.name = prefix + o.name
    return new


def _meshes(objs) -> list:
    return [o for o in objs if o.type == "MESH" and len(o.data.vertices) >= 200]


def _armatures(objs) -> list:
    return [o for o in objs if o.type == "ARMATURE"]


def _activate(obj) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode="OBJECT")


def _decimate(obj, target: int) -> None:
    n = max(len(obj.data.vertices), 1)
    ratio = min(1.0, max(0.02, float(target) / float(n)))
    print("DECIMATE", obj.name, "verts", n, "ratio", round(ratio, 4), "target", target)
    _activate(obj)
    for mod in list(obj.modifiers):
        if mod.type == "ARMATURE":
            mod.show_viewport = False
    mod = obj.modifiers.new(name="DecimateSrc", type="DECIMATE")
    mod.decimate_type = "COLLAPSE"
    mod.ratio = ratio
    mod.use_collapse_triangulate = True
    try:
        bpy.ops.object.modifier_move_to_index(modifier=mod.name, index=0)
    except Exception as exc:
        print("move_to_index", exc)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    print("AFTER", obj.name, "verts", len(obj.data.vertices), "faces", len(obj.data.polygons))


def _transfer_weights(dst, src) -> None:
    _activate(dst)
    for vg in src.vertex_groups:
        if vg.name not in dst.vertex_groups:
            dst.vertex_groups.new(name=vg.name)
    mod = dst.modifiers.new(name="WeightTransfer", type="DATA_TRANSFER")
    mod.object = src
    mod.use_vert_data = True
    mod.data_types_verts = {"VGROUP_WEIGHTS"}
    mod.vert_mapping = "POLYINTERP_NEAREST"
    mod.layers_vgroup_select_src = "ALL"
    mod.mix_mode = "REPLACE"
    try:
        bpy.ops.object.datalayout_transfer(modifier=mod.name)
    except Exception as exc:
        print("datalayout_transfer", exc)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    print("VGROUPS", dst.name, len(dst.vertex_groups), [g.name for g in dst.vertex_groups[:8]])


bpy.ops.wm.read_factory_settings(use_empty=True)

src_objs = _import(src_path, "SRC_")
donor_objs = _import(donor_path, "DONOR_")

src_meshes = _meshes(src_objs)
donor_meshes = _meshes(donor_objs)
donor_arms = _armatures(donor_objs)
print("SRC meshes", [m.name for m in src_meshes], "DONOR meshes", [m.name for m in donor_meshes], "arms", [a.name for a in donor_arms])
if not src_meshes or not donor_meshes or not donor_arms:
    raise RuntimeError("missing mesh or armature")

body = src_meshes[0]
donor_body = max(donor_meshes, key=lambda o: len(o.data.vertices))
arm = donor_arms[0]
_decimate(body, target_verts)
_transfer_weights(body, donor_body)

_activate(body)
body.parent = arm
arm_mod = body.modifiers.new(name="Armature", type="ARMATURE")
arm_mod.object = arm
arm_mod.use_vertex_groups = True

for obj in list(donor_meshes):
    bpy.data.objects.remove(obj, do_unlink=True)

body.name = "CapyBody" if "6c40523a" in src_path or "capybara" in src_path.lower() else "CowBody"

bpy.ops.export_scene.gltf(
    filepath=dst_path,
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
print("WROTE", dst_path, "body verts", len(body.data.vertices), "arm", arm.name)
