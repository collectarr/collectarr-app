"""Build Collectarr Sans from the unmodified OFL Manrope variable source.

Requires fonttools==4.57.0. No proprietary font files are inputs.
Run from any directory: python tooling/fonts/build_collectarr_sans.py
"""

from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.pens.ttGlyphPen import TTGlyphPen

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).parent / "source" / "Manrope-Variable.ttf"
# The reference UI uses a medium face even for its normal-weight text.
FACES = ((400, 550, "Regular", .972), (500, 600, "Medium", .965),
         (600, 650, "SemiBold", .972), (700, 700, "Bold", .965))


def point(x, y, width_scale):
    # At 2000 units/em: 1000-unit x-height and 1400-unit cap height.
    target_y = y * (1000 / 1080) if y <= 1080 else 1000 + (y - 1080) * (400 / 360)
    return round(x * width_scale), round(target_y)


def build_face(weight, source_weight, style, width_scale):
    font = instantiateVariableFont(TTFont(SOURCE), {"wght": source_weight}, inplace=True)
    glyphs = font.getGlyphSet()
    replacements = {}
    for name in font.getGlyphOrder():
        recorded = DecomposingRecordingPen(glyphs)
        glyphs[name].draw(recorded)
        output = TTGlyphPen(None)
        for operation, points in recorded.value:
            getattr(output, operation)(*(None if p is None else point(*p, width_scale)
                                        for p in points))
        replacements[name] = output.glyph()
    font["glyf"].glyphs.update(replacements)
    font["hmtx"].metrics = {
        name: (round(advance * width_scale), round(bearing * width_scale))
        for name, (advance, bearing) in font["hmtx"].metrics.items()
    }
    font["hhea"].advanceWidthMax = max(advance for advance, _ in font["hmtx"].metrics.values())
    font["OS/2"].xAvgCharWidth = round(font["OS/2"].xAvgCharWidth * width_scale)
    font["OS/2"].sxHeight = 1000
    font["OS/2"].sCapHeight = 1400
    font["OS/2"].usWeightClass = weight
    font["OS/2"].fsSelection &= ~((1 << 5) | (1 << 6))
    font["OS/2"].fsSelection |= (1 << 5) if weight == 700 else (1 << 6)
    font["head"].macStyle = (font["head"].macStyle & ~1) | (weight == 700)
    family = "Collectarr Sans"
    for platform, encoding, language in [(3, 1, 0x409), (1, 0, 0)]:
        for name_id, value in {
            1: family, 2: style, 3: f"CollectarrSans-{style}-1.0",
            4: f"{family} {style}", 6: f"CollectarrSans-{style}",
            16: family, 17: style,
            10: "Collectarr Sans: proportional adaptation of Manrope. SIL OFL 1.1.",
        }.items():
            font["name"].setName(value, name_id, platform, encoding, language)
    destination = ROOT / "assets" / "fonts" / f"CollectarrSans-{style}.ttf"
    font.recalcTimestamp = False
    font.save(destination)
    print(destination.relative_to(ROOT), destination.stat().st_size)


if __name__ == "__main__":
    for face in FACES:
        build_face(*face)
