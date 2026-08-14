"""Headless Blender: 金钟罩 pickup prop → golden_bell_shield.glb"""
import bpy
import math
import os

OUT = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "golden_bell_shield.glb",
)

# reset
bpy.ops.wm.read_factory_settings(use_empty=True)

# bell body: UV sphere upper half, low poly
bpy.ops.mesh.primitive_uv_sphere_add(
    segments=16, ring_count=8, radius=0.55, location=(0, 0, 0.42)
)
bell = bpy.context.active_object
bell.name = "BellDome"
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="DESELECT")
bpy.ops.object.mode_set(mode="OBJECT")
mesh = bell.data
for v in mesh.vertices:
    if v.co.z < 0.02:
        v.select = True
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.delete(type="VERT")
bpy.ops.object.mode_set(mode="OBJECT")

# rim base ring
bpy.ops.mesh.primitive_torus_add(
    major_radius=0.52, minor_radius=0.06, major_segments=24, minor_segments=8,
    location=(0, 0, 0.04),
)
rim = bpy.context.active_object
rim.name = "BellRim"

# small orb on top (装饰)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08, location=(0, 0, 0.92))
orb = bpy.context.active_object
orb.name = "BellOrb"

# merge
bpy.ops.object.select_all(action="DESELECT")
for obj in [bell, rim, orb]:
    obj.select_set(True)
bpy.context.view_layer.objects.active = bell
bpy.ops.object.join()
root = bpy.context.active_object
root.name = "GoldenBellShield"

# material
mat = bpy.data.materials.new("GoldenBell")
mat.use_nodes = True
nodes = mat.node_tree.nodes
links = mat.node_tree.links
nodes.clear()
out = nodes.new("ShaderNodeOutputMaterial")
bsdf = nodes.new("ShaderNodeBsdfPrincipled")
bsdf.inputs["Base Color"].default_value = (1.0, 0.78, 0.12, 1.0)
bsdf.inputs["Metallic"].default_value = 0.95
bsdf.inputs["Roughness"].default_value = 0.18
bsdf.inputs["Emission Color"].default_value = (1.0, 0.82, 0.2, 1.0)
bsdf.inputs["Emission Strength"].default_value = 1.8
if "Alpha" in bsdf.inputs:
    bsdf.inputs["Alpha"].default_value = 0.88
links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
mat.blend_method = "BLEND" if hasattr(mat, "blend_method") else mat.blend_method
root.data.materials.append(mat)

# origin at bottom center
bpy.ops.object.origin_set(type="ORIGIN_GEOMETRY", center="BOUNDS")
root.location = (0, 0, 0)

bpy.ops.object.select_all(action="DESELECT")
root.select_set(True)
bpy.context.view_layer.objects.active = root
bpy.ops.export_scene.gltf(
    filepath=OUT,
    export_format="GLB",
    use_selection=True,
    export_apply=True,
)
print("WROTE", OUT)
