# Library dropdown reference audit

Reviewed the authenticated CLZ Music page in Opera and exercised the Collectarr
debug web build with an isolated, populated reference library on 2026-10-11.
Only menus and selectors were opened in CLZ; no reference records were changed.

## Observed reference geometry

| Surface | CLZ measurement | Collectarr implementation |
| --- | --- | --- |
| Dropdown panel | `#444444`, square corners, 1 px `#666666` border | Shared neutral dropdown tokens, with light-theme equivalents |
| Collection status | 26 px option rows, 14 px regular labels | Both toolbar variants and the edit status picker use compact rows |
| Inspector More and Layout | 30 px rows, 14 px regular labels | Shared menu rows replace oversized inspector ListTiles |
| Favorites | Manage Favorites first, then Favorites section | Columns use that ordering; selection markers retain the configured accent |
| Column launcher | Column icon plus separate dropdown arrow | Accessible icon split control: Change columns / Column Favorites |
| Column selector | 600 px dialog, grouped checkboxes, reorderable selection | 600 px maximum width; common group headers and category checkboxes |

Collectarr retains its accent colors rather than adopting CLZ's blue selection
colors. The existing column favorite editor and preset persistence remain in
the chooser. This audit aligns dropdown styling and selector interactions;
the chooser's additional favorite controls remain a visual difference.

## Shared implementation

`ui/app_dropdown_menu.dart` owns the neutral panel colors and border shape.
Workspace dropdown tokens reuse those values, as do generic edit pickers.
`LibraryWorkspaceMenuRow` supplies compact inspector, favorite and tool rows.
`LibraryWorkspaceMenuTreeHeader` supports a leading category checkbox and is
shared by grouping and column selection.

The audit includes collection status, More, Layout, View, Density, Search Scope,
sort favorites, column favorites, grouping, tools, context actions, compact
alphabet menus and edit field pickers. Menu selection no longer shifts the
popup upwards to center its selected row over the launcher. Configured accents
are captured before opening overlays and the column chooser.

## Runtime defect found and fixed

Opening the populated Music editor emitted a Form assertion for the Location
controller: `setState() or markNeedsBuild() called during build`.
`LibraryDropdownPickField.didUpdateWidget` synchronously notified TextFormField
while its parent was rebuilding. Parent-driven controller synchronization now
runs after the frame, checks that the field remains mounted, and reads the
latest value. The regression test reproduced the assertion before the fix and
passes after it. Repeating the live editor flow emits no exceptions.

## Verification

- Full suite: **855 passed / 1 skipped**.
- Final analysis: no issues.
- Architecture: no AST boundary violations; 371 informational complexity reports.
- Duplication checker: no repeated kind implementation clusters.
- Windows and Web debug builds: successful.
- Live browser: 14 menu/selector checks, including column selection at 1844,
  1000, 700 and 380 px, followed by opening the editor status picker and cancellation;
  **no framework exceptions, page errors or overflow reports**.

Collectarr-only evidence is stored in
`evidence/library-dropdown-parity-2026-10-11/`.
