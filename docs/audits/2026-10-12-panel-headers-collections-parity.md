# Panel titles and Manage Collections — 2026-10-12

Reference: authenticated [CLZ Music](https://app.clz.com/music), inspected in Opera using screenshots and computed DOM/CSS for Manage Collections, Add Collection and Edit Collection. The supplied Music MHTML was also available for the shared chrome comparison. No CLZ collection changes were saved.

## Shared modal title contract

Opened dialog and sheet titles now use a semantic icon followed by the panel label. Edit retains its existing album/artist title and displays the kind icon beside it. The shared title style is white, 18px, weight 700, line height 18px and zero letter spacing, matching the measured CLZ modal title.

AccentDialogHeader requires an icon. Per-call title font and foreground overrides were removed so panels cannot drift from the common style. Custom-field headers use the existing Collectarr SVG asset, tinted white. Text alerts declare their semantic header icons; raw feature AlertDialog call sites were moved to the shared accent wrapper. Existing title actions remain available. Shared pick-list and field-selection shells, online cover search, compact library selection, barcode scanning, view/layout sheets and adaptive item sheets use the same chrome.

The current kind accent and gradient remain. Page navigation headers retain the separate CLZ secondary-header metrics; field labels, table headings and sidebar section labels are not modal titles.

## Manage Collections comparison

| Element | Measured CLZ | Collectarr |
| --- | --- | --- |
| Manager | 640px wide, 6px outer corners, 38px title bar | Matching geometry, plus the requested collections icon |
| Toolbar | 40px, dark #464950, Create button aligned right | Shared toolbar tone; kind-accent Create button |
| Table | 37px rows; borders between every cell; alternating #2d2d2d / #262626 | Matching rows, cell separators and alternation; visible hover |
| Collection names/counts | 14px, weight 400; album/albums for Music | Same text metrics and kind-owned count labels |
| Row actions | Bars drag grip, pencil, trash; private circle marker | Shared semantic icons, accessible action tooltips and pointer/grab cursors |
| Footer | #383838, 10px padding, 100 × 32px OK button | Matching geometry; white text on the kind accent |
| Add/Edit Collection | 600px dialog; Collection Name; 34px input; private visibility; Cancel/Save | Matching form geometry and labels; visibility remains private |

Create, rename, cancel, reorder and delete-with-transfer retain their repository behavior. The final collection cannot be deleted. The compact manager keeps all actions visible and reduces the privacy cell to an icon with tooltip. Names and counts truncate safely when space is limited.

## Verification

The full Flutter test suite passes: 924 tests, with one existing skip. The focused collection/header tests also pass after the final form-footer adjustment. Flutter analysis is clean; the architecture checker reports no AST violations and 364 informational complexity findings. Windows debug and Web builds pass.

Private Playwright captures cover the manager with one/two collections, Add, Edit, canceling an unsaved rename, and 700px/390px layouts. Collection creation uses fictional browser-local data. The shared editor capture visits all eight secondary Music tabs and three responsive widths. Neither capture reports Flutter overflow or browser exceptions.

The broader test run exposed old icon/type assertions and an obsolete assumption that startup always enters authentication. Those tests now use the current semantic icons and explicitly exercise the real authentication route with deterministic signed-out state. Runtime authentication behavior was not changed.
