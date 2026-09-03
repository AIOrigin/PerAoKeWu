#!/usr/bin/env python3
"""Upsert the local (gitignored) Ember Runner Web export preset."""
from __future__ import annotations

import re
from pathlib import Path

PRESET_NAME = "Ember Runner Web"
EXCLUDE = (
    "**/_inbox/**,**/_pull_backup_*/**,**/blender-mcp/**,**/.godot/**,"
    "**/level_editor/**,**/docs/**,**/tools/**,**/_tools/**,**/release/**,"
    "**/glb-resouses/**,**/_inbox_tmp_*/**,**/_sky_ref/**,**/_video_frames*/**,"
    "**/.cursor/**,**/.tripo/**,**/_glb_pre_decimate_backup/**,**/Todo_Manager/**,"
    "**/script-ide/**,**/runner_level_editor_launcher/**,"
    "**/capybara_rush/**,**/原版/**,**/_dev_reference/**,**/_texture_sidecars/**,"
    "**/namespace_linker/namespace_linker.gd,**/namespace_linker/plugin.cfg,"
    "**/panorama_relay_reference.png,**/panorama_relay_reference.png.import,"
    "**/water_station_source.png,**/defense_outpost_cutout.png,**/medical_outpost_cutout.png,"
    "**/*_basecolor.jpg,**/*_basecolor.png,**/*_BaseColor.jpg,**/*_normal.jpg,"
    "**/*_rm.jpg,**/*_rm.png,**/*metallic-*_roughness.png,**/*Metallic-*_roughness.png,"
    "**/*.glb,**/*.glb.import,"
    "**/*.png,**/*.png.import,**/*.webp,**/*.webp.import,"
    "**/*.jpg,**/*.jpg.import,**/*.jpeg,**/*.jpeg.import"
)


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "project.godot").exists():
            return parent
    raise SystemExit("找不到 project.godot")


def next_preset_index(text: str) -> int:
    idxs = [int(m.group(1)) for m in re.finditer(r"^\[preset\.(\d+)\]\s*$", text, re.M)]
    return (max(idxs) + 1) if idxs else 0


def preset_block(index: int) -> str:
    return f"""
[preset.{index}]

name="{PRESET_NAME}"
platform="Web"
runnable=false
advanced_options=false
dedicated_server=false
custom_features="ember_web"
export_filter="all_resources"
include_filter=""
exclude_filter="{EXCLUDE}"
export_path="build/ember_runner_web/index.html"
patches=PackedStringArray()
encryption_include_filters=""
encryption_exclude_filters=""
seed=0
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.{index}.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=false
vram_texture_compression/for_mobile=true
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
progressive_web_app/ensure_cross_origin_isolation_headers=false
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=1
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0.02, 0.04, 0.08, 1)
threads/emscripten_pool_size=8
threads/godot_pool_size=4
variant/dynamic_memory_size=128
variant/dynamic_memory_max=512
"""


def upsert(path: Path) -> None:
    if not path.is_file():
        path.write_text(preset_block(0).lstrip() + "\n", encoding="utf-8")
        print(f"已新建 {path} 并写入 {PRESET_NAME}")
        return
    text = path.read_text(encoding="utf-8")
    m = re.search(
        rf'(name="{re.escape(PRESET_NAME)}"[\s\S]*?exclude_filter=")([^"]*)(")',
        text,
    )
    if m:
        if m.group(2) != EXCLUDE:
            text = text[: m.start(2)] + EXCLUDE + text[m.end(2) :]
            path.write_text(text, encoding="utf-8")
            print(f"已更新 {PRESET_NAME} exclude_filter")
        else:
            print(f"{PRESET_NAME} 已存在")
        return
    idx = next_preset_index(text)
    path.write_text(text.rstrip() + "\n" + preset_block(idx) + "\n", encoding="utf-8")
    print(f"已追加 preset.{idx} {PRESET_NAME}")


def main() -> None:
    upsert(repo_root() / "export_presets.cfg")


if __name__ == "__main__":
    main()
