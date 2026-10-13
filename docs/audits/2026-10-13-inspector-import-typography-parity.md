# Inspector, import and typography comparison ? 2026-10-13

Compared the authenticated CLZ Music Web UI through Opera BrowserCLI and
Collectarr through Playwright, including screenshots and computed reference
styles. Used the supplied Music MHTML to verify the actual font-face mappings.
Collectarr comparisons used a separate fictional Music fixture and privately
imported local Gilroy faces. No CLZ entries were edited or proprietary fonts
added to the repository.

## Double-click and standalone details

In CLZ, double-click leaves the workspace open when Details is visible. With
No Details it navigates to a standalone version of the same inspector.
Collectarr now applies that condition to the shared workspace open handler:
right/bottom layouts select the item; hidden details open the detail route.
Early view interactions also supersede a pending initial preferences load.

LibraryDetailPage now composes LibraryInspector instead of duplicating its
hero, sections and actions. Both surfaces use the same kind contributions,
entry dispatch, personal data, custom fields, covers, backdrop and search
context. Standalone content is centered at a maximum width of 960 px, with a
full-width action strip. Metadata hyperlinks return to the workspace and keep
their filters. Selecting a visible details layout returns to that workspace.
The unused adaptive detail presentation and alternate builder contract were
removed.

## More actions and pick-list management

More uses the same hover surface and pointer cursor as Edit/Share/eBay.
Its menu starts at the trigger's left edge minus 5 px, 4 px below the trigger,
and expands right when space is available. Viewport constraints still apply.
Reference rows are 30 px high with 14 px normal text and 14 px semantic icons.
Action order is Duplicate, Remove/Collect, Loan, Move to other collection,
Update from Core, Unlink from Core, with separators before Core actions.
Actions remain conditional on actual entry/catalog capabilities.

CLZ's pick-list manage glyph is the Pro regular list icon, U+F03A at 16 px.
Collectarr retains its original list SVG, with stronger 2 px horizontal strokes
rather than substituting an unrelated Material icon.

## Why equal font weights looked different

The reference CSS declares Gilroy Medium as its **400** face, Gilroy Bold as
**700**, and Gilroy Black as **900**. Collectarr's previous 400 face was Gilroy
Regular. Matching the numeric weight alone therefore did not match the face.

When local Medium is available, normal text now registers an in-memory copy
at the engine's 400 slot. Glyph tables remain unchanged; OS/2 weight and font
checksums are updated in that copy. Original installed/imported bytes and
persisted face identities remain unchanged. Regular is used when Medium is
unavailable; bundled Plus Jakarta Sans fills missing weights.

| Surface | Reference and aligned Collectarr role |
| --- | --- |
| Normal controls, fields and sidebar rows | 14 px / 400 (Gilroy Medium locally) |
| Field labels | 13 px / 700 |
| Edit tabs and toolbar text | 14 px / 400 |
| Panel/dialog headings | 18 px / 700 |
| Music inspector album title | 24 px / 700 |
| Music inspector artist | 20 px / 700 |
| Shell brand | 24 px / 900, scales down when constrained |
| Collection tabs | 14 px / 400 |
| Import source heading | 30 px / 700 / 33 px line |
| CSV heading and upload prompt | 22 px / 700 / 24.2 px line |
| Import source cards | 18 px / 700 |
| Import step headings | 16 px / 700 |
| Import buttons | 14 px / 400, 32 px high |

Extra letter spacing and unintended 500/600/800 weights were removed from
shared roles and the affected sidebar, picker, edit and toolbar controls.
The remaining Group by/readonly field overrides and Tracks action labels
were checked separately; Tracks labels use 13 px/700 and actions 14 px/400.
Font settings and README explain the effective normal face. Restart the app
to replace faces already cached by the running font loader.

## Import pages

Inspected CLZ root, Text/CSV, Discogs, Music Label, CATraxx, Delicious Library,
OrangeCD, CDpedia, Music Collector, CLZ Music Web and one-time import screens.
Compared every currently supported Collectarr Music source, including narrow
700/390 px CSV layouts.

The shared import page now uses the dark management canvas, a 960 px centered
content area and headings inside the source panel. Source cards retain the
reference's single left column on wide screens. CSV setting cards use matching
spacing, dark borders and adjacent help icons. File controls use a raised
input surface inside an outlined panel; empty mapping preview is compact.
Warnings, numbered instructions, upload prompts and submit controls have
aligned sizing and spacing. All active controls use the current kind accent.
Music guidance separates the introductory paragraph from its instruction
lead-in. Parsing, field mapping and mutation contracts remain unchanged.

## Verification

- Complete unit/widget suite: **925 passed, one skipped**.
- Focused report/import checks after final geometry adjustments: **11 passed**.
- Font checks cover Medium selection, immutable original bytes, persisted
  face identity and checksum/glyph preservation.
- Workspace regression covers right/bottom/hidden details, shared standalone
  rendering and the More menu's right-opening placement.
- Analyzer: clean. AST architecture boundaries: no violations; existing
  complexity reports remain informational.
- Web release and Windows debug builds pass.
- Playwright verifies toolbar hover changes, double-click behavior, fullscreen
  details, edit dialog, all supported import pages and constrained layouts;
  browser/Flutter exception collectors remain empty.

## Deliberate differences

Kind accents, Collectarr branding and application-specific Music v2 fields
remain. Music Label and CLZ-only one-time import are not offered as unsupported
sources. Menus expose only applicable actions. Browser CSS and Flutter can
still differ in rasterization despite matching the actual face and text roles;
this audit does not claim pixel-identical rendering across platforms.
