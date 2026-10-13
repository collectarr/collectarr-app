# Chrome, inspector and spreadsheet comparison — 2026-10-12

The reference was the authenticated CLZ Music page in Opera, inspected through
Opera Browser CLI. Collectarr was exercised through Playwright using the populated
Music inspector reference fixture and device-local Gilroy. Accent selections and
buttons remain Collectarr's kind colors.

## Changes

- Shared window headers render a flat accent color. The gradient API and its
  direction parameters were deleted; kind color transitions remain animated.
- Removed the edit dialog outline and the separate outline around its tab body.
  Field borders and the separator above the personal footer remain.
- Inspector actions paint hover effects above the toolbar background and use a
  hand cursor. More no longer contains an inert nested tap surface.
- Inspector, Add/Collection Status and workspace controls use the same 32px
  two-tone separator. The secondary toolbar occupies 38px including its chrome.
- Collection Status uses a compact transparent toolbar trigger and grouped popup
  entries. The edit field has a 34px control and a separate 34px arrow segment;
  its popup has text entries without status artwork, as in the reference.
  Desktop and compact layouts share the same toolbar dropdown implementation.
- Selected grouping rows and collection tabs use white text on the accent fill.
- Cover selectors have 24px pointer targets and 13px white circle icons. The
  inactive indicator has 40% opacity. Per the user's requested behavior, both
  selectors disappear unless both covers exist. Back-only entries show the back
  cover directly; two-cover side-by-side presentation does not need a selector.
- Inspector actions and menu, Add Albums, cover selectors, status arrows, table
  edit actions and sort arrows use semantic AppIcons tokens.

## Spreadsheet reference and behavior

CLZ's live DOM showed 14px/700 headers, 14px/400 body text, 26px ordinary rows,
5px horizontal cell padding and adjoining columns. Its resizer occupies the final
5px of a header. The client source
[`connect-tableresizer.js`](https://app-assets.clz.com/static/js/connect-tableresizer.js?v=1791200674)
updates widths with pointer movement, uses a 50px minimum, marks the active grip
with the accent and fits content on double-click. There is no width tween or
delayed preview to reproduce.

Collectarr now uses the same pointer-driven interaction. Drag calculations use
the width and pointer position captured at the start, so parent rebuilds do not
lose movement. Manual widths override auto-size and persist across reloads.
Removed the arbitrary maximum width clamp, inter-column gutters and outer table
insets. Header/body borders remain aligned above selected and hovered rows.
Headers stay fixed in order; sorting is separate from the resize target.
Double-click sizing measures bold labels and regular cell values separately.
Density and the user's row spacing preference remain adjustable.

## Verification

- `flutter analyze --no-pub`: no issues.
- 184 widget/unit tests passed across workspace controls, toolbar, Music
  inspector and shared UI, including navigation smoke tests.
- Tests cover repeated pointer updates across parent rebuilds, aligned column
  grid pixels, double-click sizing, grouped status selection, uniform footer
  field height and all four front/back availability combinations.
- Web and Windows debug builds passed.
- Architecture checker: no AST boundary violations; the existing 365 complexity
  reports remain. Its nonzero exit for that budget baseline is not a clean gate.
- Playwright: a 180px Artist resize changed the column from 160px to 340px and
  restored that width after reload with auto-size enabled. Edit, Share, eBay and
  More reported `pointer` cursors and visible hover backgrounds. Exercised the
  status popup and editor at viewport widths 1844, 1000 and 700; no page errors,
  Flutter exceptions or overflows were collected.
- Reviewed the resulting screenshots for the editor outline, flat header,
  status field, table geometry, selection text and cover indicators.

The CLZ measurements came from its live DOM and client code. A fresh CLZ PNG
request timed out in the connector, so this record does not claim a completed
pixel-difference image comparison or complete application-wide parity.

## Icon inventory

[Direct reference inventory](2026-10-12-direct-icon-references.md) lists every
remaining direct icon reference by count and first consumer. Its companion CSV
contains every file and line. Run `python tool/ui/icon_usage_inventory.py` to
refresh both. This inventory is separate from migrating every remaining icon.
