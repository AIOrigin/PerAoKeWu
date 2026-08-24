#!/usr/bin/env python3
"""Print armature bones + animation names for each *_rigged.glb."""
import sys
from pathlib import Path

import bpy

CHAR_DIR = Path(
    "/Users/mima1234/Documents/HYPERLUNATIC/assets/maps/route_levels/capybara_rush/"
    "models/characters"
)


def inspect(path: Path) -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(path))
    arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
    print(f"\n=== {path.name} ===")
    print("actions:", [a.name for a in bpy.data.actions])
    if not arms:
        print("NO ARMATURE")
        return
    arm = arms[0]
    bones = [b.name for b in arm.data.bones]
    print("arm:", arm.name, "bones:", bones)
    if arm.animation_data:
        print("nla:", [t.name for t in arm.animation_data.nla_tracks])


def main() -> None:
    files = sorted(CHAR_DIR.glob("*_rigged.glb"))
    if "--" in sys.argv:
        only = sys.argv[sys.argv.index("--") + 1 :]
        files = [CHAR_DIR / n for n in only]
    for p in files:
        inspect(p)


if __name__ == "__main__":
    main()
