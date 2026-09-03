# Build Starfire Relay equirect skies from relay_sky_master.png (portrait landscape).
# Vertical compression maps the full reference into one natural sky dome view.

from pathlib import Path
import math
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent
OUT_DIR = ROOT.parent / "assets" / "maps" / "route_levels" / "runner_60s" / "backgrounds" / "panoramas"
# e1 keeps the purple aurora master; e2–e4 use distinct portrait skies.
SRC_BY_LEVEL = {
    "e1": ROOT / "relay_sky_master.png",
    "e2": ROOT / "relay_sky_e2_crimson.png",
    "e3": ROOT / "relay_sky_e3_emerald.png",
    "e4": ROOT / "relay_sky_e4_cyan.png",
}
W, H = 4096, 2048
SEAM_BLEND = 128
CAM_TOP = 0.10
CAM_BOT = 0.58


def to_np(im: Image.Image) -> np.ndarray:
    return np.asarray(im.convert("RGB"), dtype=np.float32) / 255.0


def from_np(arr: np.ndarray) -> Image.Image:
    return Image.fromarray(np.clip(arr * 255.0, 0, 255).astype(np.uint8), "RGB")


def smoothstep(t: float) -> float:
    t = max(0.0, min(1.0, t))
    return t * t * (3.0 - 2.0 * t)


def blend_equirect_seam(arr: np.ndarray, width: int = SEAM_BLEND) -> np.ndarray:
    out = arr.copy()
    h, w = out.shape[:2]
    width = min(max(width, 16), w // 3)
    y = 0
    while y < h:
        x = 0
        while x < width:
            t = smoothstep(float(x + 1) / float(width))
            left = out[y, x]
            right = out[y, w - 1 - x]
            mix = left * (1.0 - t) + right * t
            out[y, x] = mix
            out[y, w - 1 - x] = mix
            x += 1
        y += 1
    return out


def wrap_shift(arr: np.ndarray, frac: float) -> np.ndarray:
    if abs(frac) < 1e-4:
        return arr
    w = arr.shape[1]
    shift = int(round(frac * w)) % w
    return np.roll(arr, shift, axis=1)


def sample_bilinear(arr: np.ndarray, ys: np.ndarray, xs: np.ndarray) -> np.ndarray:
    h, w = arr.shape[:2]
    xs = np.mod(xs, w - 1.001)
    ys = np.clip(ys, 0.0, h - 1.001)
    x0 = np.floor(xs).astype(np.int32)
    y0 = np.floor(ys).astype(np.int32)
    x1 = np.minimum(x0 + 1, w - 1)
    y1 = np.minimum(y0 + 1, h - 1)
    tx = (xs - x0)[..., None]
    ty = (ys - y0)[..., None]
    c00 = arr[y0, x0]
    c10 = arr[y0, x1]
    c01 = arr[y1, x0]
    c11 = arr[y1, x1]
    return (c00 * (1 - tx) + c10 * tx) * (1 - ty) + (c01 * (1 - tx) + c11 * tx) * ty


def unify_portrait_wrap(portrait: np.ndarray, edge_frac: float = 0.08) -> np.ndarray:
    """Make portrait left/right identical so any equirect wrap is invisible."""
    ph, pw = portrait.shape[:2]
    edge = max(int(pw * edge_frac), 10)
    out = portrait.copy()
    anchor = (portrait[:, :edge].mean(axis=1) + portrait[:, -edge:].mean(axis=1)) * 0.5
    i = 0
    while i < edge:
        t = smoothstep(float(i + 1) / float(edge))
        out[:, i] = portrait[:, i] * t + anchor * (1.0 - t)
        out[:, pw - 1 - i] = portrait[:, pw - 1 - i] * t + anchor * (1.0 - t)
        i += 1
    return out


def horizontal_smooth(arr: np.ndarray, radius: int = 2) -> np.ndarray:
    """Remove column blocking from portrait upscale without blurring vertically."""
    if radius <= 0:
        return arr
    k = np.ones(radius * 2 + 1, dtype=np.float32) / float(radius * 2 + 1)
    out = arr.copy()
    c = 0
    while c < 3:
        out[:, :, c] = np.apply_along_axis(lambda row: np.convolve(row, k, mode="same"), 1, arr[:, :, c])
        c += 1
    return out


def vertical_soften(arr: np.ndarray, radius: int = 2) -> np.ndarray:
    """Soften horizontal banding before equirect mapping."""
    if radius <= 0:
        return arr
    k = np.ones(radius * 2 + 1, dtype=np.float32) / float(radius * 2 + 1)
    out = arr.copy()
    h = arr.shape[0]
    c = 0
    while c < 3:
        channel = arr[:, :, c]
        sm = np.zeros_like(channel)
        y = 0
        while y < h:
            y0 = max(0, y - radius)
            y1 = min(h, y + radius + 1)
            sm[y] = channel[y0:y1].mean()
            y += 1
        out[:, :, c] = sm
        c += 1
    return out


def make_wide_sky(portrait: np.ndarray, h_radius: int = 2, v_radius: int = 0) -> np.ndarray:
    ph = portrait.shape[0]
    unified = unify_portrait_wrap(portrait)
    wide = to_np(from_np(unified).resize((W, ph), Image.Resampling.LANCZOS))
    wide = horizontal_smooth(wide, h_radius)
    if v_radius > 0:
        softened = vertical_soften(wide, v_radius)
        wide = wide * 0.55 + softened * 0.45
    return wide


def center_equirect_seam(arr: np.ndarray) -> np.ndarray:
    """Place the equirect wrap at the portrait horizontal center (continuous), not at the sides."""
    w = arr.shape[1]
    return np.roll(arr, w // 2, axis=1)


def lock_equirect_seam(arr: np.ndarray, width: int = 16) -> np.ndarray:
    """Match only the wrap columns; leave the sky interior untouched."""
    out = arr.copy()
    h, w = out.shape[:2]
    width = min(max(width, 8), w // 4)
    seam = (out[:, 0] + out[:, -1]) * 0.5
    out[:, 0] = seam
    out[:, -1] = seam
    x = 1
    while x < width:
        t = smoothstep(float(x) / float(width))
        out[:, x] = out[:, x] * t + seam * (1.0 - t)
        out[:, w - 1 - x] = out[:, w - 1 - x] * t + seam * (1.0 - t)
        x += 1
    return out


def portrait_to_equirect(portrait: np.ndarray, row_blend: int = 1, h_radius: int = 2, v_radius: int = 0) -> np.ndarray:
    """Compress the full portrait vertically onto the sky dome so bands + horizon show together."""
    ph = portrait.shape[0]
    wide = make_wide_sky(portrait, h_radius=h_radius, v_radius=v_radius)

    y_top = int(H * 0.03)
    y_bottom = int(H * 0.78)
    span = y_bottom - y_top
    xs = np.arange(W, dtype=np.float32)

    out = np.zeros((H, W, 3), dtype=np.float32)
    y_out = y_top
    while y_out < y_bottom:
        v = (y_out - y_top) / float(max(span - 1, 1))
        src_y_center = v * float(ph - 1)
        if row_blend <= 1:
            ys = np.full(W, src_y_center, dtype=np.float32)
            out[y_out] = sample_bilinear(wide, ys, xs)
        else:
            acc = np.zeros((W, 3), dtype=np.float32)
            wsum = 0.0
            ky = -row_blend
            while ky <= row_blend:
                sy = float(np.clip(src_y_center + ky * 1.35, 0.0, ph - 1.001))
                ys = np.full(W, sy, dtype=np.float32)
                acc += sample_bilinear(wide, ys, xs)
                wsum += 1.0
                ky += 1
            out[y_out] = acc / max(wsum, 1.0)
        y_out += 1

    zenith = out[y_top].mean(axis=0) * 0.55 + np.array([0.008, 0.010, 0.028], dtype=np.float32)
    y = 0
    while y < y_top:
        t = float(y + 1) / float(max(y_top, 1))
        out[y] = zenith * (0.55 + 0.45 * t)
        y += 1

    nadir = out[y_bottom - 1].mean(axis=0) * 0.18 + np.array([0.010, 0.008, 0.022], dtype=np.float32)
    y = y_bottom
    while y < H:
        t = smoothstep((y - y_bottom) / float(max(H - y_bottom - 1, 1)))
        out[y] = out[y_bottom - 1] * (1.0 - t * 0.92) + nadir * t
        y += 1
    return out


def soften_equirect_bands(arr: np.ndarray, y0_frac: float = 0.06, y1_frac: float = 0.58, radius: int = 3, mix: float = 0.40) -> np.ndarray:
    """Blend adjacent equirect rows to break unnatural horizontal banding."""
    out = arr.copy()
    h, w, _ = out.shape
    y0 = int(h * y0_frac)
    y1 = int(h * y1_frac)
    y = y0
    while y < y1:
        acc = out[y].copy()
        weight = 1.0
        dy = 1
        while dy <= radius:
            t = mix / float(dy + 0.35)
            if y - dy >= 0:
                acc += out[y - dy] * t
                weight += t
            if y + dy < h:
                acc += out[y + dy] * t
                weight += t
            dy += 1
        out[y] = acc / weight
        y += 1
    return out


def light_grade(src: np.ndarray, cfg: dict) -> np.ndarray:
    tint = np.array(cfg["tint"], dtype=np.float32)
    keep = float(cfg["source_keep"])
    out = src * keep + np.clip(src * tint, 0.0, 1.0) * (1.0 - keep)
    lift = float(cfg.get("lift", 0.0))
    if lift > 0.0:
        out = np.clip(out * (1.0 - lift * 0.28) + lift, 0.0, 1.0)
    return np.clip(out * float(cfg.get("exposure", 1.0)), 0.0, 1.0)


def camera_preview(arr: np.ndarray, name: str) -> None:
    h, w = arr.shape[:2]
    y0, y1 = int(h * CAM_TOP), int(h * CAM_BOT)
    from_np(arr[y0:y1, :]).resize((960, 420), Image.Resampling.LANCZOS).save(ROOT / name)


LEVELS = {
    "e1": {"u_shift": 0.00, "exposure": 1.02, "tint": (1.0, 1.0, 1.0), "source_keep": 0.97},
    # e3 绿色自然；e2/e4 加纵向混合与柔化，消除横纹
    "e2": {
        "u_shift": 0.02,
        "exposure": 1.04,
        "tint": (1.01, 0.99, 0.99),
        "source_keep": 0.97,
        "lift": 0.05,
        "row_blend": 4,
        "h_smooth": 5,
        "v_soften": 2,
        "band_soften": 0.46,
    },
    "e3": {
        "u_shift": 0.04,
        "exposure": 1.04,
        "tint": (0.97, 1.03, 1.02),
        "source_keep": 0.96,
        "row_blend": 1,
        "h_smooth": 2,
    },
    "e4": {
        "u_shift": 0.01,
        "exposure": 1.04,
        "tint": (0.99, 1.00, 1.01),
        "source_keep": 0.97,
        "lift": 0.04,
        "row_blend": 4,
        "h_smooth": 5,
        "v_soften": 2,
        "band_soften": 0.44,
    },
}


def bake_level(key: str, cfg: dict) -> None:
    src = SRC_BY_LEVEL[key]
    if not src.exists():
        raise FileNotFoundError(f"missing sky source for {key}: {src}")
    portrait = to_np(Image.open(src).convert("RGB"))
    base = portrait_to_equirect(
        portrait,
        row_blend=int(cfg.get("row_blend", 1)),
        h_radius=int(cfg.get("h_smooth", 2)),
        v_radius=int(cfg.get("v_soften", 0)),
    )
    base = center_equirect_seam(base)
    base = lock_equirect_seam(base, 12)
    arr = wrap_shift(base, float(cfg["u_shift"]))
    arr = light_grade(arr, cfg)
    band_soften = float(cfg.get("band_soften", 0.0))
    if band_soften > 0.0:
        arr = soften_equirect_bands(arr, mix=band_soften)
    arr = lock_equirect_seam(arr, 8)
    arr = np.clip(arr, 0.0, 1.0)
    name = f"relay_{key}_scene_sky.png"
    from_np(arr).save(OUT_DIR / name, compress_level=1)
    from_np(arr).save(ROOT / f"relay_{key}_pano.png", compress_level=1)
    camera_preview(arr, f"relay_{key}_cam.png")
    a = np.asarray(from_np(arr))
    h = a.shape[0]
    print(f"--- {key} ({src.name}) ---")
    for frac in (0.18, 0.26, 0.34, 0.42):
        row = a[int(h * frac)]
        y = 0.299 * row[:, 0] + 0.587 * row[:, 1] + 0.114 * row[:, 2]
        std = float(y.std())
        edge = float(np.mean(np.abs(row[0].astype(float) - row[-1].astype(float))))
        print(f"  v={frac:.2f} luma={y.mean():.1f} std={std:.1f} edge={edge:.2f}")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for key, cfg in LEVELS.items():
        bake_level(key, cfg)


if __name__ == "__main__":
    main()
