#!/usr/bin/env python3
"""Renders the akaDylan typeface into a BMFont glyph sheet (PNG + XML).

The akaDylan freeware license forbids bundling the font file into another
product, so only pre-rendered glyph images ship with the game. The .ttf is
read from the local archive and never copied into app/.
"""
from pathlib import Path
from xml.sax.saxutils import quoteattr

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
TTF = ROOT / "archive/Herbert the Fly/Cocos 1.0.1/herbert/herbert/Resources/akaDylan Plain.ttf"
OUT = Path(__file__).resolve().parents[1] / "assets/font"

SIZE = 64
STROKE = 8
PAD = 2
SHEET_W = 1024
CHARS = [chr(c) for c in range(32, 127)] + list("äöüÄÖÜéèàç·")
FILL = (255, 255, 255, 255)
STROKE_FILL = (34, 34, 34, 255)


def main():
    font = ImageFont.truetype(str(TTF), SIZE)
    ascent, descent = font.getmetrics()
    base = ascent + STROKE
    line_height = ascent + descent + 2 * STROKE

    glyphs = []
    for ch in CHARS:
        l, t, r, b = font.getbbox(ch, anchor="ls", stroke_width=STROKE)
        w, h = max(1, r - l), max(1, b - t)
        img = Image.new("RGBA", (w, h))
        if ch != " ":
            ImageDraw.Draw(img).text((-l, -t), ch, font=font, anchor="ls", fill=FILL, stroke_width=STROKE, stroke_fill=STROKE_FILL)
        glyphs.append((ch, img, l, base + t, round(font.getlength(ch)) + STROKE))

    x = y = PAD
    row_h = 0
    placed = []
    for ch, img, xo, yo, adv in glyphs:
        if x + img.width + PAD > SHEET_W:
            x, y, row_h = PAD, y + row_h + PAD, 0
        placed.append((ch, img, x, y, xo, yo, adv))
        x += img.width + PAD
        row_h = max(row_h, img.height)
    sheet_h = 1 << (y + row_h + PAD - 1).bit_length()

    sheet = Image.new("RGBA", (SHEET_W, sheet_h))
    chars_xml = []
    for ch, img, gx, gy, xo, yo, adv in placed:
        sheet.paste(img, (gx, gy))
        chars_xml.append(
            f'<char id="{ord(ch)}" x="{gx}" y="{gy}" width="{img.width}" height="{img.height}" '
            f'xoffset="{xo}" yoffset="{yo}" xadvance="{adv}" page="0" chnl="15"/>'
        )

    OUT.mkdir(parents=True, exist_ok=True)
    sheet.save(OUT / "akadylan.png", optimize=True)
    xml = (
        f'<?xml version="1.0"?>\n<font>\n<info face={quoteattr("akaDylan Plain")} size="{SIZE}"/>\n'
        f'<common lineHeight="{line_height}" base="{base}" scaleW="{SHEET_W}" scaleH="{sheet_h}" pages="1"/>\n'
        f'<pages><page id="0" file="akadylan.png"/></pages>\n<chars count="{len(chars_xml)}">\n'
        + "\n".join(chars_xml)
        + "\n</chars>\n</font>\n"
    )
    (OUT / "akadylan.xml").write_text(xml)
    print(f"{len(placed)} glyphs -> {OUT / 'akadylan.png'} ({SHEET_W}x{sheet_h})")


if __name__ == "__main__":
    main()
