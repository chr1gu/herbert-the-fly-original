#!/usr/bin/env python3
"""Converts the original 2011 Cocos2d resources into web-friendly assets.

- TexturePacker/Cocos plist atlases (format 2) -> Phaser "JSON hash" atlases
- CoreAudio .caf -> .mp3 (via ffmpeg)

Uses the retina (-hd, 960x640) set so the prototype runs at 2x the original
480x320 coordinate space.
"""
import json
import plistlib
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "original/resources"
OUT = Path(__file__).resolve().parents[1] / "assets"

ATLASES = ["clct_herbert", "clct_bugsgads", "clct_ingame", "clct_mm", "clct_tutorial"]
SINGLE_IMAGES = [
    "drugmode", "rainbow_start", "rainbow_end", "mm_bg", "mm_gameover_bg",
    "uber-lightning0", "uber-lightning2", "uber-lightning3", "health_life",
]

NUM = re.compile(r"-?\d+(?:\.\d+)?")


def nums(s):
    return [float(n) for n in NUM.findall(s)]


def convert_atlas(name):
    src_plist = SRC / "_retina" / f"{name}-hd.plist"
    with open(src_plist, "rb") as f:
        data = plistlib.load(f)

    frames = {}
    for key, fr in data["frames"].items():
        x, y, w, h = nums(fr["frame"])
        sx, sy, sw, sh = nums(fr["sourceColorRect"])
        srcw, srch = nums(fr["sourceSize"])
        frames[key[:-4] if key.endswith(".png") else key] = {
            "frame": {"x": x, "y": y, "w": w, "h": h},
            "rotated": bool(fr.get("rotated", False)),
            "trimmed": (sw, sh) != (srcw, srch),
            "spriteSourceSize": {"x": sx, "y": sy, "w": sw, "h": sh},
            "sourceSize": {"w": srcw, "h": srch},
        }

    out_dir = OUT / "atlas"
    out_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy(SRC / "_retina" / f"{name}-hd.png", out_dir / f"{name}.png")
    meta = {"image": f"{name}.png", "format": "RGBA8888", "scale": "1"}
    (out_dir / f"{name}.json").write_text(json.dumps({"frames": frames, "meta": meta}))
    print(f"atlas {name}: {len(frames)} frames")


def convert_audio():
    for caf in (SRC / "audio").rglob("*.caf"):
        rel = caf.relative_to(SRC / "audio").with_suffix(".mp3")
        dst = OUT / "audio" / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists():
            continue
        subprocess.run(
            ["ffmpeg", "-v", "error", "-y", "-i", str(caf), "-ac", "1", "-ar", "44100", "-b:a", "96k", str(dst)],
            check=True,
        )
        print(f"audio {rel}")


def copy_images():
    out_dir = OUT / "img"
    out_dir.mkdir(parents=True, exist_ok=True)
    for name in SINGLE_IMAGES:
        shutil.copy(SRC / "_retina" / f"{name}-hd.png", out_dir / f"{name}.png")


if __name__ == "__main__":
    if not SRC.exists():
        sys.exit(f"source resources not found: {SRC}")
    for a in ATLASES:
        convert_atlas(a)
    copy_images()
    convert_audio()
