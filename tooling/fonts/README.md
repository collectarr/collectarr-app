# Collectarr Sans

Collectarr Sans is an OFL derivative of Manrope, created for the Library UI.
It uses Manrope's original outlines, with adjusted horizontal proportions,
spacing, x-height and cap height. It is visually close to the geometric style
of the saved CLZ editor, but is not Gilroy and is not an exact glyph clone.

Source: https://github.com/google/fonts/tree/main/ofl/manrope
License: `../../assets/fonts/CollectarrSans-OFL.txt` (SIL OFL 1.1).
The original copyright and license are retained; the derivative has a distinct
family name. No Gilroy file or outline is used to build these fonts.

## Rebuild

Install `fonttools==4.57.0`, then run:

```sh
python tooling/fonts/build_collectarr_sans.py
```

The checked-in, unmodified source is `source/Manrope-Variable.ttf`.
The four generated static faces have explicit Flutter weights 400, 500, 600
and 700. Static faces avoid relying on implicit variable-axis selection.
The normal face uses a medium stroke thickness to match the reference UI's
normal text; registered weights and source axis values intentionally differ.

## Visual comparison

See [the comparison image](../../docs/architecture/assets/collectarr-sans-comparison.png).
It renders both fonts at the same CSS sizes and weights, including Romanian
diacritics. For the sample title at 14px, the regular face measures 273.29px
against 273.24px in the reference; the bold face measures 278.14px against
277.94px. These measurements describe that sample only, not every string.
The letter shapes and rasterization still differ.

The family is registered in `pubspec.yaml` and used by the shared Library editor
theme through `kLibraryEditorFontFamily`. Other application areas retain their
existing font settings.
