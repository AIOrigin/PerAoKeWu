#!/usr/bin/env python3
"""Import Quaternius cyan rabbit (already rigged+animated), clean, export for Capybara Rush."""
from __future__ import annotations

from pathlib import Path

import bpy

SRC = Path("/Users/mima1234/Documents/HYPERLUNATIC/原版/quaternius_cc0-cyan-rabbit-1278.glb")
OUT_RIGGED = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/little_rabbit_rigged.glb"
)
OUT_MAIN = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters/little_rabbit.glb"
)

# 游戏用小写名匹配；保留原动作并额外挂 NLA 别名
ALIAS = {
    "run": ["Run", "Run_Holding", "Walk"],
    "idle": ["Idle", "Idle_Holding", "Wave"],
    "jump": ["Jump", "Jump_Idle", "Jump_Land"],
    "dance": ["Wave", "Yes", "Sitting_Idle"],
}


def clear_scene() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def find_action(name: str) -> bpy.types.Action | None:
    for a in bpy.data.actions:
        if a.name == name:
            return a
    # case-insensitive
    low = name.lower()
    for a in bpy.data.actions:
        if a.name.lower() == low:
            return a
    return None


def stash_alias(arm: bpy.types.Object, alias: str, candidates: list[str]) -> None:
    action = None
    for c in candidates:
        action = find_action(c)
        if action is not None:
            break
    if action is None:
        print("missing action for", alias, candidates)
        return
    if arm.animation_data is None:
        arm.animation_data_create()
    # 复制一份改名，方便 glTF/ Godot 按 run/idle/jump 找到
    dup = action.copy()
    dup.name = alias
    track = arm.animation_data.nla_tracks.new()
    track.name = alias
    start = int(dup.frame_range[0]) if dup.frame_range else 1
    track.strips.new(alias, max(start, 1), dup)
    print("alias", alias, "<-", action.name)


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"missing {SRC}")
    clear_scene()
    bpy.ops.import_scene.gltf(filepath=str(SRC))

    # 删掉误带的默认球
    for o in list(bpy.data.objects):
        if o.type == "MESH" and o.name.lower().startswith("ico"):
            bpy.data.objects.remove(o, do_unlink=True)
            print("removed", o)

    arm = None
    for o in bpy.data.objects:
        if o.type == "ARMATURE":
            arm = o
            break
    if arm is None:
        raise SystemExit("no armature")

    arm.name = "RabbitArmature"
    print("bones", len(arm.data.bones))
    print("actions", [a.name for a in bpy.data.actions])

    # 清掉旧 NLA，挂游戏别名
    if arm.animation_data:
        for t in list(arm.animation_data.nla_tracks):
            arm.animation_data.nla_tracks.remove(t)
        arm.animation_data.action = None

    for alias, cands in ALIAS.items():
        stash_alias(arm, alias, cands)

    # 选中骨架+网格导出
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    for o in bpy.data.objects:
        if o.type == "MESH":
            o.select_set(True)
    bpy.context.view_layer.objects.active = arm

    OUT_RIGGED.parent.mkdir(parents=True, exist_ok=True)
    kwargs = dict(
        filepath=str(OUT_RIGGED),
        export_format="GLB",
        export_animations=True,
        export_skins=True,
        export_morph=False,
        export_apply=False,
        export_yup=True,
    )
    try:
        bpy.ops.export_scene.gltf(
            **kwargs,
            export_animation_mode="ACTIONS",
            export_nla_strips=True,
            export_def_bones=False,
        )
    except TypeError:
        try:
            bpy.ops.export_scene.gltf(**kwargs, export_animation_mode="NLA_TRACKS")
        except TypeError:
            bpy.ops.export_scene.gltf(**kwargs)

    # 主路径也换成这套（备份旧 Tripo 已在仓库里可另存）
    import shutil

    shutil.copy2(OUT_RIGGED, OUT_MAIN)
    print("WROTE", OUT_RIGGED, OUT_RIGGED.stat().st_size)
    print("WROTE", OUT_MAIN)


if __name__ == "__main__":
    main()
