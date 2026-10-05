# Music folder sidebar: CLZ alignment

Date: 2026-10-05.

## Reference and comparison scope

Reference: `C:/Users/saita/Desktop/tmp/My Albums - CLZ Music Web.mhtml`.
The saved page shows Genre grouping, `[All Albums]`, `[None]`, nine folder
rows, and favorites with multiple grouping levels.

The initial audit compared decoded DOM/CSS with Flutter source. The follow-up
also renders the actual Flutter sidebar/header components in an isolated Web
preview using the reference genre labels/counts, at a 324.469 px pane width and
1x device scale. A narrow 180 px preview checks the header layout visually.
The preview uses demonstration data and does not access the user's catalog.
It is not a screenshot of the complete Windows application.

Local comparison artifacts are ignored build/preview files:

- `.tmp-sidebar-captures/app.png`
- `.tmp-sidebar-captures/app-narrow.png`
- `.tmp-sidebar-captures/clz.png`
- `.tmp-sidebar-captures/clz-metrics.json`

The extracted CLZ screenshot has missing Font Awesome glyphs because those font
resources are not embedded in the saved page. It is useful for geometry, colors
and typography, but does not establish exact icon parity or interactive behavior.

## Completed behavior corrections

- Selecting a sidebar favorite passes the complete `LibraryFolderPreset`.
- Count sorting keeps All first and None before ordinary values. Count ties
  resolve through the shared name comparator.
- Recursive tree sorting uses the same comparator as the flat list.
- Sort mode is persisted per kind and complete preset, through the existing
  preference store. Stale reads cannot replace a newer UI choice; writes queue.
- Header controls adapt progressively instead of disappearing below 220 px.
- Folder search clears when the kind or complete grouping preset changes.
- Tree nodes honor persisted expansion IDs. Selecting a descendant no longer
  forces ancestors open on every projection rebuild; selecting a path explicitly
  adds its expansion IDs. Active search temporarily opens matching ancestry.
- The All row stays above the tree and does not expose a collapse toggle.
- Tree count sorting now uses the displayed count. The current tree builder
  assigns the same distinct-item count to `count` and `cumulativeCount`.
- Pane width measurement uses the same text style, text scale and count metrics
  as the visible rows.
- Filtering no longer sorts each subtree twice.

## Completed visual alignment

| Element | Current implementation |
| --- | --- |
| Shared rows | `LibraryFolderRow` renders flat folders and tree nodes. |
| Row height | 27 px at normal text scale/default density; grows for increased text scale or user padding. |
| Typography | 14 px Medium, 22 px line height; shared with width measurement. |
| Count badge | Right aligned, at least 28 px, radius 4 px; expands for larger numbers/text scales. |
| Normal dark surfaces | Folder panel `#383838`, badge/hover `#464950`, row separator `#262626`. |
| Selection | Solid current App accent; white count badge with contrast-adjusted accent text. |
| Selected label | Black or white according to accent contrast, intentionally retaining App readability behavior. |
| Empty bucket separation | 5 px gap after None, matching CLZ's `is-cutoff` row. |
| Header | 38 px including separator; neutral selector, current-list manager icon. |
| Search | 26 px, integrated search/clear icon, padding 3 px vertically/5 px horizontally. |
| Sort switch | 60 x 26 px, radius 4 px, moving 26 x 22 px indicator, 300 ms transition. |
| Active sort | Neutral indicator with an accent outline; inactive icon fades to 25% opacity. |
| Hierarchy | 26 px caret area, darker depth surfaces and hierarchy borders; no decorative leaf dots. |
| Extra actions | Tree/drilldown, Back and Hide remain available in More instead of filling the normal header. |

These neutral dark values follow the CLZ reference. Light mode uses the App
palette. Selection, active controls and relevant hierarchy borders continue to
use the configured App accent.

## Dictionary management

A group definition can declare a typed `bucketVocabulary`. This enables the
existing pick-list manager directly from the sidebar; no separate Music manager
or favorites dialog is introduced.

Music mappings cover Artist, Format, Genre, Label, Country, Instrument,
Package/Sleeve Condition, Media Condition, Packaging, Sound, Storage Device,
Studio, Vinyl Color, Signed by, and the existing people/classical role lists.
Dates and computed flags do not expose a dictionary manager.

The coordinator selects the corresponding list and Music scope in the shared
manager and invalidates the shelf when it closes. The dictionary's existing
editing semantics are retained; this change does not add a new bulk metadata
rename/delete mechanism. Favorites management remains in the grouping menu.

## Remaining intentional or unverified differences

- Collectarr Sans is used instead of Gilroy. Medium/Bold roles and sizes are
  aligned, but glyph shapes and widths are not identical.
- Material icons approximate CLZ's Font Awesome icons.
- Bright accents can produce dark selected label text for readability, whereas
  the saved CLZ blue selection uses white text.
- More preserves App-specific tree/navigation controls; the captured CLZ header
  has only the selector and dictionary manager.
- Native Windows rasterization, the complete workspace, dictionary mutations
  and CLZ's live interactions have not been compared end to end in this task.

## Validation

Scoped Dart static analysis of all changed production files and the generic page
entry point reports no issues. The isolated Web preview compiles successfully.
No automated tests were added or run.
