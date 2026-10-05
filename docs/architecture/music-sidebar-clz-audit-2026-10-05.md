# Music folder sidebar: CLZ comparison

Date: 2026-10-05.

## Evidence and scope

Reference: `C:/Users/saita/Desktop/tmp/My Albums - CLZ Music Web.mhtml`.
The saved page shows Genre grouping, `[All Albums]`, an active `[None]` row,
favorites with multiple grouping levels, and the folder selector/manager.
This audit compares its decoded DOM/CSS with the current Flutter implementation.
It is not a live screenshot comparison. The MHTML does not establish every
interactive behavior of the original CLZ application.

## Completed behavior corrections

1. Selecting a sidebar favorite passes its entire `LibraryFolderPreset` to
   `_setFolderPreset`; secondary and subsequent levels are retained.
2. Count sorting keeps `[All Albums]` first and `[None]` ahead of ordinary
   values. Equal counts use the existing name comparator for deterministic order.
3. Tree siblings use that same comparator, including recursive child sorting.
4. Alphabetical/count sorting is persisted through `LibraryViewPreferenceStore`,
   separately for each kind and complete folder preset. Cached values restore
   immediately; stale asynchronous reads cannot replace a more recent selection.
   Writes are queued so rapid toggles are stored in order.
5. The header keeps the selector at widths below 220 px. Actions progressively
   move to a More menu; below 140 px the selector uses its compact icon trigger.
   At transient rail widths too narrow for actions, the selector remains visible
   and scales down.

The duplicate Manage Favorites button and advanced filter dialog were already
removed. Manage Favorites remains in the grouping menu; Smart Lists remain.
Shared typography now uses 14 px Medium for folder values and controls, with
Bold for appropriate headings/menu triggers.

## Remaining visual differences

| Area | Saved CLZ reference | Current App | Recommended follow-up |
| --- | --- | --- | --- |
| Row height | 22 px line height + 2 px top/bottom padding + 1 px separator: about 27 px | `30 + sidebarRowPadding * 2`; default padding 4 gives 38 px | Introduce a shared compact folder row metric, targeting 27 px by default; preserve an explicit user density preference. |
| Count position | Right-aligned badge after the label | Fixed 20 px numeric area before the label in list and tree | Put the count after an expanded label; use the same badge widget in both views. |
| Count styling | Normal badge `#464950`, text `#eeeeee`, radius 4 px; selected badge white with blue text | Plain colored numeric text; no badge surface | Add shared badge styling and width based on the largest visible count. |
| Selected row | Full solid `#5eb1de` surface, white label | Translucent accent blend; list adds a 2 px left marker | Use a solid selection surface and consistent selected text/count colors. |
| Hover | Solid `#464950` | List uses an accent blend; tree has no equivalent full-row hover surface | Share row hover treatment between list and tree. |
| Search | 26 px input; integrated transparent search/clear action; surrounding padding 3 px vertically and 5 px horizontally | 30 px input; separate bordered action segment; surrounding padding 4 px top, 6 px bottom/horizontal | Align input height, insets and action surface. |
| Sort switch | 60 x 26 px, radius 4 px, moving 26 x 22 px inner indicator with a 0.3 s transition | 52 x 28 px, radius 2 px, divided static segments | Rebuild as one animated segmented control with matching geometry. |
| Header actions | Folder selector and a current-folder manager list icon | Tree/drilldown switch, conditional manager pencil, Back, Hide and responsive More | Decide which App actions remain visible; make the main dictionary manager a list icon. Back also exists in workspace navigation. |
| Dictionary manager | Saved DOM contains `folder-manage`, separate from Manage Favorites | Music grouping definitions do not enable bucket management | Implement typed pick-list value management before enabling this button; do not reuse the favorites dialog. |
| Tree geometry | Caret area 26 px; progressively darker nested surfaces and hierarchy borders | 14 px indentation per level, 18 px caret, dots on leaves, one panel surface | Share compact row metrics; align carets and add depth surfaces/borders if matching this appearance is desired. |
| Font family | Gilroy Medium mapped to CSS weight 400, Gilroy Bold to 700 | Collectarr Sans Medium mapped to Flutter weight 500, Bold to 700 | Sizes and weight roles are close; glyph shape and text width still differ. Exact font parity has not been established. |
| Icons | Font Awesome folder, list, search and sort glyphs | Material equivalents | Match icon proportions using project-owned icons where worthwhile. |
| Pane sizing | CSS basis 260 px; saved resized width 324.469 px; draggable divider | Resizable pane with shared width preferences and minimum-width calculation | Do not force the saved user's 324.469 px width as a universal default; compare divider appearance in a live capture. |

## Additional behavior/maintenance findings

### Tree expansion ignores collapse state

`_filterTreeNode` sets `isExpanded` when `filteredChildren.isNotEmpty`, even
without a search query. `_FolderTreeNodeView` combines this value with the
persisted expansion set using OR. Consequently, nodes with children are forced
open and removing an ID from the expansion set cannot close them.

Follow-up: preserve normal expansion state when the query is empty; force open
only matching ancestry during active search. There should be one authoritative
source for normal expansion state. Keep persisted selection and expansion IDs.

### Search survives grouping changes

The sidebar search controller is retained when the kind/preset changes.
A search intended for Genre can therefore hide values after switching to Artist.
Decide explicitly whether folder search resets on preset changes or is stored
per preset; do not carry it over accidentally.

### Minimum-width measurement uses different typography

`resolveLibrarySidebarMinWidth` measures the selected label using bodySmall/Bold,
while rows render bodyMedium/Medium. The estimate can be inconsistent with the
actual label width. Use the same shared row text style and count/caret metrics
when sizing the pane. Update the calculation alongside right-side count badges.

### Tree count meaning needs an explicit decision

Tree count sorting uses `cumulativeCount`, while the displayed number uses
`node.count`. Check the intended meaning for parent nodes and multi-value groups,
then make sort order and displayed counts agree or clearly document why they differ.

## Suggested implementation order

1. Repair normal tree collapse and define folder-search behavior on preset changes.
2. Extract a shared folder row and count badge used by flat and tree views.
3. Align row height, selection/hover colors, count position and width measurement.
4. Align search and sort controls, including the moving sort indicator.
5. Add Music dictionary management using the existing typed metadata operations;
   keep favorites management separate.
6. Review header action placement, hierarchy styling and icon proportions.
7. Capture App and the local reference at identical window size, pane width,
   scale factor and grouping. Compare text baselines, row positions and colors.
   This live visual comparison remains outstanding.

## Validation performed

Scoped Dart static analysis of the changed sidebar, preference store, body,
page entry points and header reported no issues. No automated widget tests or
live App screenshot comparison were performed in this task.
