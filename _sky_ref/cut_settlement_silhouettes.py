# Cut settlement-page building silhouettes from black / checkerboard backgrounds.

from collections import deque
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parent
OUT_DIR = ROOT.parent / "assets" / "maps" / "route_levels" / "runner_60s" / "settlement"

SOURCES = {
    "medical_settlement_silhouette.png": ROOT / "src_medical_silhouette.png",
    "defense_settlement_silhouette.png": ROOT / "src_defense_silhouette.png",
    "relay_settlement_silhouette.png": ROOT / "src_relay_silhouette.png",
}


def luma_sat(rgb: np.ndarray):
    rgb_f = rgb.astype(np.float32)
    r, g, b = rgb_f[..., 0], rgb_f[..., 1], rgb_f[..., 2]
    luma = 0.299 * r + 0.587 * g + 0.114 * b
    mx = np.maximum(np.maximum(r, g), b)
    mn = np.minimum(np.minimum(r, g), b)
    sat = np.divide(mx - mn, np.maximum(mx, 1.0))
    return luma, sat


def flood_background(rgb: np.ndarray, checker: bool) -> np.ndarray:
    h, w = rgb.shape[:2]
    luma, sat = luma_sat(rgb)
    bg = np.zeros((h, w), dtype=np.bool_)

    def is_seed(y: int, x: int) -> bool:
        L, S = float(luma[y, x]), float(sat[y, x])
        if checker and S < 0.08 and L > 70.0:
            return True
        if (not checker) and L < 8.0 and S < 0.35:
            return True
        return False

    def can_flood(y: int, x: int) -> bool:
        L, S = float(luma[y, x]), float(sat[y, x])
        if checker:
            return S < 0.10 and L > 55.0
        return L < 9.5 and S < 0.40

    q: deque = deque()
    for x in range(w):
        for y in (0, h - 1):
            if is_seed(y, x):
                bg[y, x] = True
                q.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if is_seed(y, x) and not bg[y, x]:
                bg[y, x] = True
                q.append((y, x))
    while q:
        y, x = q.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if ny < 0 or ny >= h or nx < 0 or nx >= w or bg[ny, nx]:
                continue
            if can_flood(ny, nx):
                bg[ny, nx] = True
                q.append((ny, nx))
    return bg


def crop_alpha(rgba: np.ndarray, pad: int = 10) -> np.ndarray:
    a = rgba[..., 3]
    ys, xs = np.where(a > 10)
    if ys.size == 0:
        return rgba
    y0 = max(int(ys.min()) - pad, 0)
    y1 = min(int(ys.max()) + 1 + pad, rgba.shape[0])
    x0 = max(int(xs.min()) - pad, 0)
    x1 = min(int(xs.max()) + 1 + pad, rgba.shape[1])
    return rgba[y0:y1, x0:x1]


def cutout(path: Path, checker: bool) -> Image.Image:
    rgb = np.asarray(Image.open(path).convert("RGB"))
    luma, _sat = luma_sat(rgb)
    bg = flood_background(rgb, checker)
    keep = ~bg
    keep_u8 = (keep.astype(np.uint8) * 255)
    alpha = np.asarray(
        Image.fromarray(keep_u8, "L").filter(ImageFilter.GaussianBlur(radius=0.8)),
        dtype=np.float32,
    )
    # Drop leftover true-black fringe, keep navy fill (luma ~12-30).
    fringe = keep & (luma < 6.0)
    padded = np.pad(~keep, 1, constant_values=False)
    has_bg_nb = (
        padded[0:-2, 1:-1] | padded[2:, 1:-1] | padded[1:-1, 0:-2] | padded[1:-1, 2:]
    )
    alpha[fringe & has_bg_nb] = 0.0
    rgba = np.dstack([rgb, np.clip(alpha, 0, 255).astype(np.uint8)])
    return Image.fromarray(crop_alpha(rgba), "RGBA")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for out_name, src in SOURCES.items():
        if not src.exists():
            raise SystemExit(f"missing {src}")
        out = cutout(src, checker="relay" in out_name)
        dest = OUT_DIR / out_name
        out.save(dest, optimize=True)
        print(out_name, out.size, out.mode)


if __name__ == "__main__":
    main()
