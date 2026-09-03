from pathlib import Path

p = Path(r"C:\Users\zy洋芋糍粑\Documents\PerAoKeWu - 副本\assets\maps\route_levels\planets\planet_glass_desert.gd")
print("target", p, p.exists())
text = p.read_text(encoding="utf-8")

replacements = [
    (
        '"environment_flavor": "初火夜空：藏青底里只有一线电青星火。"',
        '"environment_flavor": "紫极光夜空 · 稀疏涡轮塔远景。"',
    ),
    (
        '"environment_flavor": "能量汇聚：电青流光加厚，地平线开始发亮。"',
        '"environment_flavor": "绯红残云夜 · 废墟塔林密布。"',
    ),
    (
        '"environment_flavor": "星火铺开：品红光带爬上地平线。"',
        '"environment_flavor": "翠绿极光夜 · 涡轮与废墟夹道。"',
    ),
    (
        '"environment_flavor": "燎原：青白能量流铺满夜空，黑暗被星火推开。"',
        '"environment_flavor": "青白能量风暴夜 · 远景塔群最密。"',
    ),
]

e2_old = """\t\t\"sky_accents\": {
\t\t\t\"energy_gates\": false,
\t\t\t\"energy_vortex\": false,
\t\t\t\"aurora\": false,
\t\t\t\"panorama_billboards\": false,
\t\t\t\"distant_density\": 1.12,
\t\t},
\t\t\"midground_props\": [RELAY_MIDGROUND_DRONE],
\t\t\"distant_tower_props\": [
\t\t\tRELAY_DISTANT_TURBINE,
\t\t\tRELAY_DISTANT_TOWER,
\t\t\tRELAY_DISTANT_RUIN,
\t\t],"""

e2_new = """\t\t\"sky_accents\": {
\t\t\t\"energy_gates\": false,
\t\t\t\"energy_vortex\": false,
\t\t\t\"aurora\": false,
\t\t\t\"panorama_billboards\": false,
\t\t\t\"distant_density\": 1.36,
\t\t},
\t\t\"midground_props\": [
\t\t\tRELAY_MIDGROUND_DRONE,
\t\t\tRELAY_MID_NEON,
\t\t\tRELAY_MID_SPHERE,
\t\t],
\t\t\"near_runway_props\": [
\t\t\tRELAY_MID_SPHERE,
\t\t\tRELAY_MID_NEON,
\t\t],
\t\t\"near_sky_textures\": [RELAY_SKY_NEAR_1, RELAY_SKY_NEAR_2],
\t\t\"distant_tower_props\": [
\t\t\tRELAY_DISTANT_RUIN,
\t\t\tRELAY_DISTANT_TOWER,
\t\t\tRELAY_DISTANT_TURBINE,
\t\t],"""

e3_old = """\t\t\"sky_accents\": {
\t\t\t\"energy_gates\": false,
\t\t\t\"energy_vortex\": false,
\t\t\t\"aurora\": false,
\t\t\t\"panorama_billboards\": false,
\t\t\t\"distant_density\": 1.10,
\t\t},
\t\t\"midground_props\": [RELAY_MIDGROUND_DRONE],
\t\t\"distant_tower_props\": [RELAY_DISTANT_TURBINE, RELAY_DISTANT_RUIN],"""

e3_new = """\t\t\"sky_accents\": {
\t\t\t\"energy_gates\": false,
\t\t\t\"energy_vortex\": false,
\t\t\t\"aurora\": false,
\t\t\t\"panorama_billboards\": false,
\t\t\t\"distant_density\": 1.22,
\t\t},
\t\t\"midground_props\": [
\t\t\tRELAY_MIDGROUND_DRONE,
\t\t\tRELAY_MID_METEOR,
\t\t\tRELAY_MID_NEON,
\t\t],
\t\t\"near_runway_props\": [
\t\t\tRELAY_MID_METEOR,
\t\t\tRELAY_MID_NEON,
\t\t],
\t\t\"near_sky_textures\": [RELAY_SKY_NEAR_2],
\t\t\"distant_tower_props\": [RELAY_DISTANT_TURBINE, RELAY_DISTANT_RUIN],"""

e4_old = """\t\t\"sky_accents\": {
\t\t\t\"energy_gates\": false,
\t\t\t\"energy_vortex\": false,
\t\t\t\"aurora\": false,
\t\t\t\"panorama_billboards\": false,
\t\t\t\"distant_density\": 1.18,
\t\t},
\t\t\"midground_props\": [RELAY_MIDGROUND_DRONE],
\t\t\"distant_tower_props\": [
\t\t\tRELAY_DISTANT_TURBINE,
\t\t\tRELAY_DISTANT_TOWER,
\t\t\tRELAY_DISTANT_RUIN,
\t\t],"""

e4_new = """\t\t\"sky_accents\": {
\t\t\t\"energy_gates\": false,
\t\t\t\"energy_vortex\": false,
\t\t\t\"aurora\": false,
\t\t\t\"panorama_billboards\": false,
\t\t\t\"distant_density\": 1.48,
\t\t},
\t\t\"midground_props\": [
\t\t\tRELAY_MIDGROUND_DRONE,
\t\t\tRELAY_MID_SPHERE,
\t\t\tRELAY_MID_NEON,
\t\t\tRELAY_MID_METEOR,
\t\t],
\t\t\"near_runway_props\": [
\t\t\tRELAY_MID_SPHERE,
\t\t\tRELAY_MID_NEON,
\t\t\tRELAY_MID_METEOR,
\t\t],
\t\t\"near_sky_textures\": [RELAY_SKY_NEAR_1, RELAY_SKY_NEAR_2],
\t\t\"distant_tower_props\": [
\t\t\tRELAY_DISTANT_TOWER,
\t\t\tRELAY_DISTANT_TURBINE,
\t\t\tRELAY_DISTANT_RUIN,
\t\t],"""

# Prefer already-patched e4 block if present
e4_alt_old = """\t\t\"sky_accents\": {
\t\t\t\"energy_gates\": false,
\t\t\t\"energy_vortex\": false,
\t\t\t\"aurora\": false,
\t\t\t\"panorama_billboards\": false,
\t\t\t\"distant_density\": 1.48,
\t\t},
\t\t\"midground_props\": [RELAY_MIDGROUND_DRONE],
\t\t\"distant_tower_props\": [
\t\t\tRELAY_DISTANT_TOWER,
\t\t\tRELAY_DISTANT_TURBINE,
\t\t\tRELAY_DISTANT_RUIN,
\t\t],"""

for old, new in replacements:
    if old in text:
        text = text.replace(old, new)
        print("flavor ok:", new.split('"')[-2] if False else old[:20])
    else:
        print("flavor skip/missing:", old[:40])

for name, old, new in [
    ("e2", e2_old, e2_new),
    ("e3", e3_old, e3_new),
    ("e4", e4_old, e4_new),
]:
    if old in text:
        text = text.replace(old, new, 1)
        print(name, "props patched")
    elif name == "e4" and e4_alt_old in text:
        text = text.replace(e4_alt_old, e4_new, 1)
        print("e4 alt props patched")
    else:
        print(name, "PROPS NOT FOUND")
        idx = text.find(f"mission_relay_{name}")
        print(repr(text[idx : idx + 420]))

# Ensure mid constants exist
needle = 'const RELAY_VISUAL_SCENE := {'
if "RELAY_MID_NEON" not in text and needle in text:
    insert = '''const RELAY_MID_NEON := "res://assets/maps/route_levels/models/environment/midground/neon_sign_prop.glb"
const RELAY_MID_SPHERE := "res://assets/maps/route_levels/models/environment/midground/cracked_sphere_robot.glb"
const RELAY_MID_METEOR := "res://assets/maps/route_levels/models/environment/midground/glowing_energy_meteorite.glb"
'''
    text = text.replace(needle, insert + needle, 1)
    print("inserted mid constants")

p.write_text(text, encoding="utf-8")
print("done", p)
print("has RELAY_MID_NEON", "RELAY_MID_NEON" in text)
print("e2 dens", '"distant_density": 1.36' in text)
print("e3 dens", '"distant_density": 1.22' in text)
print("e4 dens", '"distant_density": 1.48' in text)
