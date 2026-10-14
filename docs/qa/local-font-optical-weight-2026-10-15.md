# Local font optical weight

The user's View-menu screenshots show a visible weight difference even though
both controls request 14 px regular text. This supersedes the assumption in
the earlier typography audit that equal declared weights imply visual parity.

## Findings

- The visible reference menu declares Gilroy 14 px / 400. Its CSS names Medium
  as the normal face. No text stroke or text shadow is declared.
- Reference canvas advances agree with the user's local Medium font. Matching
  advances does not prove matching glyph outlines or rasterization.
- An isolated Flutter engine probe successfully selected local Medium in the
  existing 400 slot. This was not evidence that the rendered pixels matched.
- The supplied screenshots have the same #444444 menu background and roughly
  30 px row pitch. Text ink is nevertheless substantially lighter in Collectarr.
- Comparing local Medium, SemiBold and Bold renders identifies SemiBold as a
  closer visual weight for ordinary Flutter text without increasing font size.
  For `Horizontal Cards`, its advance changes from about 106.99 to 107.63 px.

## Implementation

The local font loader now registers SemiBold in normal UI slots 400 and 500,
falling back to Medium and Regular when those are the available local faces.
Both slots use the same outlines so explicit Medium controls do not become
lighter than ordinary controls. Bold titles/labels and the bundled fallback
keep their existing mapping. Settings describes the actual selection.

This is optical calibration, not a claim that CLZ uses SemiBold or that two
different renderers now produce identical pixels. No font asset was copied
from the reference. Diagnostic rasters and user font bytes remain outside git.

## Checks

- The correctness runner passes all 935 tests, including normal face selection,
  incomplete families, immutable originals, restoration and missing weights.
- `dart analyze`: no issues.
- Visual checks use fresh isolated browser storage and user-local font files;
  they do not modify the native application's database or font preferences.
- Playwright checked the View menu, navigation drawer and Music editor with
  actual local faces restored in correctly encoded browser preferences. No
  page or Flutter layout exceptions were reported. The new menu's measured
  text coverage is higher than the supplied original Collectarr screenshot.
- A full restart is required for the native process to use the revised engine
  registrations. This audit does not claim exact cross-renderer pixel parity.
