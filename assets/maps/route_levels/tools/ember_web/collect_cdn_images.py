#!/usr/bin/env python3
"""List raster images to put on the Ember Runner CDN (not sidecar GLB textures)."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

IMAGE_EXTS = {".png", ".webp", ".jpg", ".jpeg"}

SKIP_DIR_PARTS = {
    "_inbox",
    "blender-mcp",
    ".godot",
    "level_editor",
    "docs",
    "tools",
    "_tools",
    "release",
    "glb-resouses",
    "_sky_ref",
    ".cursor",
    ".tripo",
    "_glb_pre_decimate_backup",
    "Todo_Manager",
    "script-ide",
    "namespace_linker",
    "runner_level_editor_launcher",
    "capybara_rush",
    "原版",
    "_dev_reference",
    "_texture_sidecars",
    "addons",
    "build",
    ".git",
}

SKIP_NAME_RES = [
    re.compile(r"basecolor", re.I),
    re.compile(r"_normal\.(jpg|jpeg|png)$", re.I),
    re.compile(r"_rm\.(jpg|jpeg|png)$", re.I),
    re.compile(r"metallic.*roughness", re.I),
    re.compile(r"tripo_image", re.I),
    re.compile(r"normal_bake", re.I),
    re.compile(r"panorama_relay_reference"),
    re.compile(r"water_station_source\.png$"),
    re.compile(r"defense_outpost_cutout\.png$"),
    re.compile(r"medical_outpost_cutout\.png$"),
    re.compile(r"_preview\.webp$"),
]

HOME_PREFIXES = (
    "assets/maps/route_levels/mobile_home/ui_home/",
    "assets/maps/route_levels/mobile_home/ui_final/",
    "assets/maps/route_levels/mobile_home/ui_character/",
    "assets/maps/route_levels/mobile_home/ui_maplist/",
    "assets/maps/route_levels/mobile_home/ui_cargo_icons/",
    "assets/maps/route_levels/mobile_home/ui_header/",
    "assets/maps/route_levels/models/environment/buildings/_extras_2d/",
    "assets/maps/route_levels/models/characters/rook/portrait.jpg",
    "assets/ddddd.png",
)

STORY_PREFIXES = ("assets/maps/route_levels/mobile_home/story_intro/",)

EXPLORE_PREFIXES = (
    "assets/maps/route_levels/planet_explore/",
    "mvp素材第二批/",
)

RUNNER_PREFIXES = (
    "assets/maps/route_levels/runner_60s/",
    "assets/maps/route_levels/models/backgrounds/",
    "assets/maps/route_levels/models/track/",
)


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "project.godot").exists():
            return parent
    raise SystemExit("找不到 project.godot")


def _skip_dir(rel: str) -> bool:
    parts = set(rel.split("/"))
    if parts & SKIP_DIR_PARTS:
        return True
    if "/_inbox_tmp_" in f"/{rel}/" or "/_pull_backup_" in f"/{rel}/" or "/_video_frames" in f"/{rel}/":
        return True
    return False


def _skip_file(name: str) -> bool:
    return any(rx.search(name) for rx in SKIP_NAME_RES)


def iter_images(root: Path) -> list[Path]:
    out: list[Path] = []
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in IMAGE_EXTS:
            continue
        rel = path.relative_to(root).as_posix()
        if _skip_dir(rel) or _skip_file(path.name):
            continue
        out.append(path)
    out.sort()
    return out


def group_for(rel: str) -> str:
    if any(rel.startswith(p) or rel == p.rstrip("/") for p in STORY_PREFIXES):
        return "story"
    if any(rel.startswith(p) or rel == p.rstrip("/") for p in HOME_PREFIXES):
        return "home"
    if any(rel.startswith(p) for p in EXPLORE_PREFIXES):
        return "explore"
    if any(rel.startswith(p) for p in RUNNER_PREFIXES):
        return "runner"
    return "misc"


def collect(root: Path) -> dict:
    groups: dict[str, list[str]] = {"home": [], "story": [], "explore": [], "runner": [], "misc": []}
    bytes_sum = 0
    files = iter_images(root)
    for path in files:
        rel = path.relative_to(root).as_posix()
        groups[group_for(rel)].append("res://" + rel)
        bytes_sum += path.stat().st_size
    return {
        "files": files,
        "groups": groups,
        "count": len(files),
        "mb": bytes_sum / 1024 / 1024,
    }


def write_manifest(root: Path, dest: Path | None = None) -> dict:
    data = collect(root)
    payload = {
        "home": data["groups"]["home"],
        "story": data["groups"]["story"],
        "explore": data["groups"]["explore"],
        "runner": data["groups"]["runner"],
        "misc": data["groups"]["misc"],
    }
    dest = dest or (root / "assets/maps/route_levels/ember_web/ember_image_manifest.json")
    dest.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return data


def main() -> None:
    root = repo_root()
    dest = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    data = write_manifest(root, dest)
    print(
        f"images={data['count']} mb={data['mb']:.1f} "
        + " ".join(f"{k}={len(v)}" for k, v in data["groups"].items()),
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
