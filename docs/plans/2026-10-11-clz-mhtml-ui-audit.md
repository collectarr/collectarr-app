# CLZ Music: visual, DOM/CSS and MHTML audit

Inspected on 2026-10-11 at 1844 × 945. This report supplements the
[spreadsheet audit](2026-10-11-clz-music-table-audit.md) with current editor,
typography and motion evidence. It records remaining work, not completed fixes.

The current follow-up is [the October 12 post-cleanup audit](2026-10-12-clz-post-cleanup-ui-audit.md).
It supersedes this remaining-work table, including the incorrect Genre
full-width recommendation and editor/footer/motion findings fixed since then.

## Evidence and limits

Live Opera inspection covered workspace, Select Sort Fields, Select Column
Fields, Main, Details, Tracks, Personal, Covers, My Images, Links and Settings.
Current computed styles were saved for each state. Editor tabs were opened
and cancelled; no CLZ album was saved. Runtime sortable options were read.
Collectarr's corresponding editor states, sidebar and Settings were captured
with Playwright using the isolated populated reference collection.

Local evidence is in
`%TEMP%/collectarr-browser-compare/parity/mhtml-audit/`:

- `clz-*-live.json`: serialized DOM, current form values, computed styles,
  dimensions, icon font/pseudo content and transition declarations.
- `clz-*-dom-css.mhtml`: inspected DOM plus bundled public CSS/font/icon
  resources. These are assembled archives, not native Opera Save Page files.
  Scripts are removed and external album images are not bundled. There are
  63 bundled resources; eight obsolete Glyphicon resource URLs return 404.
- `clz-*-archive.png`: renderings of those archives in Chromium. A JavaScript
  disabled banner and missing album images are archive artifacts, not product
  differences. In particular, Covers image height cannot be compared from
  the archive rendering.
- `app-*.png`: live Collectarr screenshots; `app-*.mhtml`: native CDP snapshots.
  Flutter paints the UI onto a canvas, so these MHTML files do not expose the
  rendered font styles. Collectarr typography evidence comes from Dart and
  screenshots, not inferred CSS.
- `clz-runtime-motion.json`: sortable configuration. The transition event
  probe captured no events; CSS transition durations below are configured
  values, not measured playback durations.
- `app-browser-errors.json`: no captured framework/page errors in this pass.

The supplied `My Albums`, `full_editor`, Export, Import, Print to PDF and Stats
MHTML files were also inventoried. Their common stylesheet includes unused
components and other kinds; rule presence alone is not proof of a missing
Music feature. Export/import/statistics transactions were not repeated here.
CLZ and Collectarr have different item data, disc/track counts and collection
settings. Content length and empty/populated states are not parity defects.

## Remaining differences

| Priority | Surface | CLZ evidence | Current Collectarr difference / next action |
| --- | --- | --- | --- |
| P0 | Main form geometry | Genre spans the full form width below Artist | Genre occupies the right half. Move its presentation to the full-width row without restoring root recording fields. |
| P0 | Form label emphasis | Main labels are 13px, weight 700, line-height about 18.57px | Several field helpers still use 600, while Disc Title uses 800. Map labels to one measured role; avoid a global weight increase. |
| P0 | Form values | CLZ values are generally 14px/400 | Editor body overrides remain 14px/500; disc/track fields also use 13px. Compare matched strings and normalize by role. |
| P0 | Collection Status | CLZ displays a text value and separate arrow segment | Our current editor value includes a cyan status check. This is an accent leak, despite the popup accent improvements. |
| P0 | Covers toolbar order | Find Online → Upload → Remove, with Crop / Rotate at the right | Ours starts Upload → Find Online. Align order and action spacing. |
| P1 | Covers action glyphs | Magnifier, upload, trash and pencil are Font Awesome glyphs | Ours uses image-search, upload-outline, restore and crop-rotate glyphs. Align the silhouette of equivalent actions; Restore is a separate Collectarr behavior. |
| P1 | Covers action text | Toolbar actions inherit 14px/400 and `.btn` transitions | Ours is visibly heavier. Compare individual labels; preserve kind accent and current image lifecycle. |
| P1 | Main vertical rhythm | Live standard controls are typically 34px high | Our common inputs are around 32px, with row/padding differences visible in Main. Use measured dimensions for compact desktop controls. |
| P1 | Editor footer | Previous and Next are filled 100 × 32 buttons; Cancel/Save also 100 × 32 | Ours uses text Previous/Next. Disabled state is expected for the single-entry fixture, but the button geometry differs independently. |
| P1 | Editor shell | CLZ has rounded outer corners and a visible dialog shadow | Editor theme specifies zero corner radius; screenshot has square corners. Match shell corners/shadow separately from cover borders. |
| P1 | Footer divider | CLZ separates the local field strip using its dark panel surfaces | Ours has a stronger light divider. Match contrast while keeping the local fields aligned. |
| P1 | Tracks typography | Track values and header labels are 14px in the inspected editor | Several local table/action styles are 13px and weights vary from 600 to 800. Normalize table roles, not track models. |
| P1 | Disc metadata access | Storage Device, Slot and side matrices are above the CLZ track table | Our Tracks view shows Disc Title; storage and technical fields exist under Details → disc. This is a placement/discoverability difference, not absent storage support. |
| P1 | My Images intake text | Archive render has a larger bold, multiline instruction | Our intake explicitly uses 14px without a bold override. Match text size, weight and wrapping against live computed intake styles before editing. |
| P1 | My Images intake background | CLZ empty intake visually blends into the panel | Our intake is a lighter filled rectangle. Compare equivalent empty states; don't infer a layout defect from the populated reference tile. |
| P1 | Settings density | CLZ uses compact controls and checkbox rows within centered columns | Our page adds two tab rows, larger checkbox spacing and more vertical padding. Keep the additional settings, tighten the common groups. |
| P1 | Settings input treatment | Live CLZ standard selects use gray filled fields | Our screenshot uses nearly black fields, floating labels and stronger value weight. Share compact library form styling where appropriate. |
| P1 | Settings organization | Customization, Localization, Sorting, Auto Capitalization and eBay are visible cards | Our Customization separates Application/List view/Details panel; other settings sit behind sub-tabs. This is confirmed navigation/layout drift; this pass does not establish that every corresponding preference is absent. |
| P1 | Table type roles | Header 14px/700, ordinary row text 14px/400 in live CLZ | Our table overrides are 14px/800 and 14px/500. Re-measure with matching cell text before changing the weights. |
| P2 | Icon family | Live icons resolve to Font Awesome 6 Pro | Editor tab SVGs already resemble the same glyph family; toolbar/search/crop/settings actions still mix Material outlines and SVGs. Audit equivalent actions individually, not a blanket icon replacement. |
| P2 | Brand/header treatment | CLZ header is flat accent | Our header has a gradient. This is visual drift; keep the selected kind accent and COLLECTARR MUSIC identity. |

## Motion audit

| Interaction | CLZ evidence | Collectarr status |
| --- | --- | --- |
| Edit tab hover | `.nav-tabs li a` declares 250ms transition | Already has `AnimatedContainer(250ms, Curves.ease)`. Background tokens #131313/#383838 are also present. Do not classify this as missing. |
| Edit tab drag release | Initialized horizontal sortable uses `revert: 250`, `helper: clone`, `axis: x` | Uses Flutter ReorderableListView with proxy rotation/scale. Release duration/trajectory is not explicitly matched; compare a live drag recording before changing it. |
| Sort/column selected row hover | Fields declare 100ms linear background/border/transform/shadow transitions | Shared reorder row already uses 100ms linear, scale/rotation and small shadow. Available checkbox rows still use Material InkWell rather than the same transition model. |
| Sort/column drop | Runtime sortable has `revert: 100` | Our custom list immediately clears its drag state in `_finish()`. Missing explicit 100ms return-to-slot animation. |
| Dialog opening | Bootbox CSS configures opacity 200ms linear; backdrop 100ms linear | `AppDialogRoute` uses a 150ms fade with easeOutQuad. Animation exists, but timing/curve and separate backdrop handling differ. Runtime event probe did not measure the actual CLZ fade. |
| Buttons / cover actions | Common `.btn` declares 250ms | Ours relies on Material button state transitions/InkWell in several surfaces, without a shared explicit 250ms hover treatment. Match per-surface hover/focus states; Material ripple is a different effect. |
| Sidebar opening | Overlay menu CSS declares a 200ms linear margin slide | Collectarr uses Scaffold drawer motion. Compare live movement/width; a stylesheet declaration alone does not establish the perceived timing difference. |
| Sidebar subsection chevron | CSS declares 100ms linear | Needs a targeted expand/collapse interaction audit. No claim of a missing functional subsection. |
| Inspector image navigation | Carousel arrow opacity transition is 100ms | Needs equivalent multi-image fixture and hover recording. Not established by the current single-cover comparison. |

## Intentional differences and already completed work

Keep accent-colored Save/selections/favorites, the current kind icon and brand,
the padding slider, and the application-specific settings. Music v2 owns generic
Credits, disc recording data and format capabilities. Do not restore People,
Classical, root recording fields or guessed format families for CLZ parity.
Propose to Core and cover Restore are Collectarr actions with distinct semantics.

Spreadsheet headers are now fixed. Column order belongs to Select Column
Fields. The 1px #262626 header/body/utility column borders have already been
implemented and checked; they are not outstanding findings.

Find Online, uploads, crop/save, image paste/drop, links, Previous/Next across
multiple items, full preference persistence and collection CRUD need separate
transaction checks. Opening a tab and seeing its controls does not prove these
flows work. No missing capability is inferred merely from an MHTML snapshot.

## Repeating the static inspection

```powershell
python scripts/audit_mhtml.py `
  'C:\Users\saita\Desktop\tmp\My Albums - CLZ Music Web.mhtml' `
  'C:\Users\saita\Desktop\tmp\full_editor.mhtml' `
  --output "$env:TEMP\collectarr-clz-style-report.json"
```

The helper records source hashes, resource inventory and leaf CSS declarations
for typography, motion, transforms, shadows and glyphs. It does not calculate
the CSS cascade or execute archived scripts. Keep account DOM and third-party
font/icon archives in local evidence storage rather than committing them.
