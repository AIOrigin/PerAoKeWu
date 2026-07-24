from pathlib import Path
from PIL import Image
import json
import shutil

ROOT = Path('/home/ubuntu/upload/Home_UI_技术切图')
SOURCE = ROOT / '2x_reference_png' / 'ui_home_bg_main_clean_1440x2560.png'
RUNTIME_2X = ROOT / '2x_runtime_png'
RUNTIME_1X = ROOT / '1x_runtime_png'
RUNTIME_2X.mkdir(parents=True, exist_ok=True)
RUNTIME_1X.mkdir(parents=True, exist_ok=True)

output_2x = RUNTIME_2X / 'ui_home_bg_main_1440x2560.png'
output_1x = RUNTIME_1X / 'ui_home_bg_main_720x1280.png'

if not SOURCE.exists():
    raise FileNotFoundError(f'未找到清洁主背景源图：{SOURCE}')

with Image.open(SOURCE) as image:
    if image.size != (1440, 2560):
        raise ValueError(f'主背景尺寸应为1440×2560，实际为{image.size}')
    image.save(output_2x, optimize=True)
    image.resize((720, 1280), Image.Resampling.LANCZOS).save(output_1x, optimize=True)

manifest = {
    'asset_group': 'Home Main Background',
    'source_design_canvas_px': {'width': 1440, 'height': 2560},
    'runtime_baseline_px': {'width': 720, 'height': 1280},
    'assets': [
        {
            'file': '2x_runtime_png/ui_home_bg_main_1440x2560.png',
            'scale': '2x',
            'width': 1440,
            'height': 2560,
            'role': 'full_screen_main_background',
            'has_alpha': False,
            'usage': 'Home页全屏主背景。无任何HUD、标题、任务卡、CTA或底部导航；先铺设，再叠加所有运行时UI。'
        },
        {
            'file': '1x_runtime_png/ui_home_bg_main_720x1280.png',
            'scale': '1x',
            'width': 720,
            'height': 1280,
            'role': 'full_screen_main_background',
            'has_alpha': False,
            'usage': '720×1280逻辑基准下的主背景版本。'
        }
    ],
    'implementation_rules': {
        'fit_mode': 'cover',
        'anchor': 'center',
        'tiling': 'disabled',
        'layer_order': [
            'ui_home_bg_main',
            'top_hud',
            'title_overlay_optional',
            'current_map_panel',
            'start_transport_cta',
            'bottom_tab_bar'
        ],
        'safe_area_note': '背景可延伸至异形屏边缘；HUD与底部导航必须单独避让安全区。'
    }
}

with (ROOT / 'background_asset_manifest.json').open('w', encoding='utf-8') as fp:
    json.dump(manifest, fp, ensure_ascii=False, indent=2)

print(f'已生成：{output_2x}')
print(f'已生成：{output_1x}')
print(f'已生成：{ROOT / "background_asset_manifest.json"}')
