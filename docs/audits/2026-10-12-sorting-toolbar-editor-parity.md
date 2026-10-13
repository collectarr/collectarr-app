# Sorting, toolbar and edit chrome comparison — 2026-10-12

Compared authenticated CLZ Music in Opera using screenshots, DOM/computed styles and the supplied Music MHTML. Collectarr was inspected in Playwright with fictional local Music data; no CLZ records or production database entries were saved during the comparison.

## Measured reference and changes

| Surface | CLZ reference | Collectarr change |
| --- | --- | --- |
| Sorting trigger | 30px icon button + approximately 18px arrow button | Separate hover targets and matching split geometry; alphabetic sorting icon and chevron |
| Sorting favorites | Field labels, ascending/descending arrows, separators, active check, trailing management gear | Semantic field labels and shared Font Awesome icons; menu width measured from the rendered font and each criterion |
| Dropdown surfaces | Dark background #444444, border #666666 | Shared toolbar menu tokens, preserving light-theme equivalents |
| Toolbar hover | #464950 with a small corner radius and pointer cursor | Shared hover surface, including popup-owned buttons whose inner callback is null |
| Edit form | #383838 | Retained form surface |
| Edit collection/index strip | #262626 | Distinct darker prefooter background |
| Edit action footer | #383838, 10px padding, approximately 53px high | Matching footer geometry |
| Cancel / Save / Previous / Next | 14px, weight 400, 20px line height | Same text metrics in the editor and shared action buttons |
| Editor title / tabs | Title 18px/700; tabs 14px/400 | Shared title and tab typography updated |

Toolbar popups open immediately, matching the observed reference. Hover transitions respect reduced-motion settings. Save and active indicators keep the current kind accent rather than CLZ blue. The selected alphabet button also receives a visible hover treatment without losing its accent.

The audit exposed built-in favorites using bare field IDs that no longer resolved in canonical workspace schemas. Favorite definitions now belong to each kind and reference its actual registered sort fields. TV has no release-date favorite because that sort is not exposed in its current schema. No fallback ID aliases were introduced.

## Validation

- Canonical favorite resolution across all nine kinds.
- 69 focused tests covering toolbar controls, sort dialogs, hover/cursor behavior, edit dialogs and pick lists.
- Clean Flutter analysis and no AST architecture violations; the checker still reports 365 informational complexity findings.
- Windows debug and Web builds.
- Playwright hover checks for Add Albums, Collection Status, Search Scope, search actions, Group By, View, both Sorting controls, both Columns controls and Tools.
- Screenshots of sort favorites, Select Sort Fields, all eight secondary Music editor tabs and responsive layouts at 1100px, 700px and 390px; no Flutter overflow or browser exceptions in the capture run.

This aligns the inspected chrome, not every CLZ feature. Collectarr retains its own kind-specific fields, additional view modes and favorite-management behavior. Exact glyph geometry can still differ when the configured local font is unavailable; no proprietary CLZ font or asset was bundled.
