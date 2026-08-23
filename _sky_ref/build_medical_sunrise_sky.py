# W1-format 2048x1024 panorama. Camera band holds pink-white / pink / purple / deep blue.

from pathlib import Path
import shutil
import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parent
OUT = ROOT.parent / "assets" / "maps" / "route_levels" / "runner_60s" / "backgrounds" / "panoramas"
W, H = 2048, 1024
CAM_TOP = 0.34
CAM_BOT = 0.54
SUN_U = 0.94


def to_np(im: Image.Image) -> np.ndarray:
    return np.asarray(im.convert("RGB"), dtype=np.float32) / 255.0


def from_np(arr: np.ndarray) -> Image.Image:
    return Image.fromarray(np.clip(arr * 255.0, 0, 255).astype(np.uint8), "RGB")


def luma(arr: np.ndarray) -> np.ndarray:
    return arr[..., 0] * 0.299 + arr[..., 1] * 0.587 + arr[..., 2] * 0.114


def sample(arr: np.ndarray, xs: np.ndarray, ys: np.ndarray) -> np.ndarray:
    h, w = arr.shape[:2]
    xs = np.mod(xs, w - 1.001)
    ys = np.clip(ys, 0.0, h - 1.001)
    x0 = np.floor(xs).astype(np.int32)
    y0 = np.floor(ys).astype(np.int32)
    x1 = np.minimum(x0 + 1, w - 1)
    y1 = np.minimum(y0 + 1, h - 1)
    tx = (xs - x0)[..., None]
    ty = (ys - y0)[..., None]
    return (arr[y0, x0] * (1 - tx) + arr[y0, x1] * tx) * (1 - ty) + (
        arr[y1, x0] * (1 - tx) + arr[y1, x1] * tx
    ) * ty


def crop_frac(im: Image.Image, top: float, bottom: float) -> np.ndarray:
    w, h = im.size
    return to_np(im.crop((0, int(h * top), w, int(h * bottom))))


def local_contrast(arr: np.ndarray, radius: int, amount: float) -> np.ndarray:
    blur = to_np(from_np(arr).filter(ImageFilter.GaussianBlur(radius=radius)))
    return np.clip(blur + (arr - blur) * amount, 0.0, 1.0)


def make_strip(parts: list, height: int) -> np.ndarray:
    resized = []
    for p in parts:
        nw = max(int(round(p.shape[1] * height / max(p.shape[0], 1))), 64)
        resized.append(to_np(from_np(p).resize((nw, height), Image.Resampling.LANCZOS)))
    strip = np.concatenate(resized, axis=1)
    seam = min(64, strip.shape[1] // 8)
    left, right = strip[:, :seam].copy(), strip[:, -seam:].copy()
    for i in range(seam):
        t = (i + 1) / float(seam)
        strip[:, i] = left[:, i] * t + right[:, i] * (1.0 - t)
        strip[:, -seam + i] = right[:, i] * (1.0 - t) + left[:, i] * t
    return strip


def paint_pano(strip: np.ndarray) -> np.ndarray:
    uu = np.linspace(0.0, 1.0, W, dtype=np.float32)[None, :].repeat(H, axis=0)
    vv = np.linspace(0.0, 1.0, H, dtype=np.float32)[:, None].repeat(W, axis=1)
    t = np.clip((vv - CAM_TOP) / (CAM_BOT - CAM_TOP), 0.0, 1.0)
    # Full sky crop: deep blue at top of camera, pink-white sun at horizon.
    ys = t * (strip.shape[0] - 1.001)
    xs = uu * (strip.shape[1] - 1.001)
    clouds = sample(strip, xs, ys)
    zenith = np.array([0.04, 0.06, 0.18], np.float32)
    ground = np.array([0.08, 0.06, 0.10], np.float32)
    zen_fade = np.clip((CAM_TOP - vv) / 0.18, 0.0, 1.0)[..., None]
    gnd_fade = np.clip((vv - CAM_BOT) / 0.10, 0.0, 1.0)[..., None]
    out = clouds * (1.0 - zen_fade) + zenith * zen_fade
    out = out * (1.0 - gnd_fade) + ground * gnd_fade
    return np.clip(out, 0.0, 1.0)


def main() -> None:
    assets = Path.home() / ".cursor" / "projects" / "c-Users-zy-Documents-PerAoKeWu" / "assets"
    portrait_src = next(assets.glob("*6de2a32b-5fb6-42a8-a657-72990a7b3877.png"))
    pano_src = next(assets.glob("*f9b93185-ef8b-4ca8-a088-f82a6b98891d.png"))
    shutil.copy2(portrait_src, ROOT / "medical_ref_portrait.png")
    shutil.copy2(pano_src, ROOT / "medical_ref_pano.png")
    # Re-save as real PNG in case they are JPEG.
    for name in ("medical_ref_portrait.png", "medical_ref_pano.png"):
        im = Image.open(ROOT / name).convert("RGB")
        im.save(ROOT / name, format="PNG")

    portrait = Image.open(ROOT / "medical_ref_portrait.png")
    pano360 = Image.open(ROOT / "medical_ref_pano.png")
    # Vertical concept: sky only, all four colors.
    a = local_contrast(crop_frac(portrait, 0.08, 0.48), 6, 1.22)
    # 360: zenith aurora down to pink horizon, skip ice sheet.
    b = local_contrast(crop_frac(pano360, 0.08, 0.48), 5, 1.18)
    strip = make_strip([a, b, a[:, a.shape[1] // 5 :]], 720)
    out = paint_pano(strip)

    y = luma(out)
    col = y[int(H * 0.40) : int(H * 0.52)].mean(axis=0)
    src_u = float(np.argmax(col) / (W - 1))
    out = np.roll(out, int(round((SUN_U - src_u) * W)), axis=1)

    OUT.mkdir(parents=True, exist_ok=True)
    from_np(out).save(OUT / "medical_sunrise_scene_sky.png", optimize=True)
    from_np(out).save(ROOT / "medical_sunrise_pano.png")
    y0, y1 = int(H * CAM_TOP), int(H * CAM_BOT)
    view = np.concatenate([out[y0:y1, int(W * 0.72) :], out[y0:y1, : int(W * 0.28)]], axis=1)
    from_np(view).resize((960, 420), Image.Resampling.LANCZOS).save(ROOT / "medical_sunrise_cam.png")

    y255 = luma(out) * 255.0
    print("src_u", src_u)
    for frac in (0.20, 0.36, 0.42, 0.46, 0.50, 0.54):
        rgb = out[int(H * frac)].mean(axis=0) * 255.0
        print(f"v={frac:.2f} luma={y255[int(H * frac)].mean():.0f} rgb={tuple(int(x) for x in rgb)}")


if __name__ == "__main__":
    main()
