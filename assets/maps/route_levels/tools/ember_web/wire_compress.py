#!/usr/bin/env python3
"""Pre-compress wasm/pck for S3 upload (Brotli or gzip)."""
from __future__ import annotations

import argparse
import gzip
import sys
from pathlib import Path

DEFAULT_CODEC = "br"
BR_QUALITY = 11


def encode(data: bytes, codec: str = DEFAULT_CODEC) -> bytes:
    if codec == "br":
        try:
            import brotli
        except ImportError as exc:
            raise SystemExit(
                "缺少 brotli 模块。部署前执行：python3 -m pip install brotli"
            ) from exc
        return brotli.compress(data, quality=BR_QUALITY)
    if codec == "gzip":
        return gzip.compress(data, compresslevel=9)
    raise SystemExit(f"未知压缩格式：{codec}（支持 br / gzip）")


def wire_size(path: Path, codec: str = DEFAULT_CODEC) -> int:
    return len(encode(path.read_bytes(), codec))


def main() -> None:
    parser = argparse.ArgumentParser(description="压缩 wasm/pck 供 CDN 传输")
    parser.add_argument("cmd", choices=["encode", "size"])
    parser.add_argument("src", type=Path)
    parser.add_argument("dst", nargs="?", type=Path)
    parser.add_argument("codec", nargs="?", default=DEFAULT_CODEC, choices=["br", "gzip"])
    args = parser.parse_args()
    raw = args.src.read_bytes()
    compressed = encode(raw, args.codec)
    if args.cmd == "size":
        print(len(compressed))
        return
    if args.dst is None:
        raise SystemExit("encode 需要输出路径 dst")
    args.dst.write_bytes(compressed)
    print(
        f"codec={args.codec} raw={len(raw)/1024/1024:.1f}MB wire={len(compressed)/1024/1024:.1f}MB",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
