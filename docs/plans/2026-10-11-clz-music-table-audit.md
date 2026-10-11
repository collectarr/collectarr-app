# Music List / spreadsheet audit — 2026-10-11

Reference: authenticated live CLZ Music Web in Opera; Collectarr Web debug at
commit `a0843c147`, isolated local reference storage. Both captured at
2508×1309, then 1000×945 and 700×945. Opened view, sort and column favorites,
sort/column editors, selection toolbar and selection More menu. No album edits,
removals, transfers or merges were executed. CLZ dialogs were canceled and the
viewport was restored. Collectarr reported no runtime exceptions during the
completed browser pass. Screenshots and DOM/semantics captures are in the local
temporary `collectarr-browser-compare/parity/table-audit` directory.

The CLZ account has 40 entries; isolated Collectarr has one populated reference
entry. Counts, saved favorite names, column widths and current grouping are
user state, not parity defects. Multi-row keyboard/range selection and large
table scrolling are not certified by this pass. Keep Collectarr kind accents;
blue CLZ selections and buttons are not implementation targets. Preserve Music
v2 ownership, generic Credits and explicit scalar reducer sorts.

## Functional differences

1. Music column editor exposes 13 available columns, all under Main. CLZ
   exposes Images, Main, Details, Edition, Classical, People, Personal and Loan.
   Missing comparable scalar/personal/image fields include Added/Modified Date,
   Index, Quantity, Location, Owner, Notes, Tags, Rating, price/value, loan and
   cover-presence fields. Credits/disc fields need Music v2 semantics, not the
   old CLZ root-role arrays.
2. Sort editor exposes six choices: Artist, Title, Release Date, earliest/latest
   disc recording date and Tracks. CLZ has many more choices, including Label,
   Cat No, dates/year/month, personal and cover fields. Expand eligible scalar
   definitions explicitly; do not sort many-valued fields implicitly.
3. `Move to other collection` in the selection More menu dispatches
   `onBulkMoveToWishlist ?? onBulkMoveToEntry`. Presenter callbacks call the
   wishlist/entry flows, rather than the collection picker. The row context
   menu already has an actual collection picker. This is a behavior bug.
4. Export to XML and Merge Albums are shown but disabled in Collectarr. They
   are available actions in CLZ. Loan was disabled for this particular local
   fixture; its callback is conditional, so this does not establish that loan
   support is absent.
5. Title is locked on in the column editor; CLZ shows a removable Title row.
6. The table accepts and forwards `onColumnReordered`, but the header never
   invokes it and contains no drag source/target. Column reordering works via
   the chooser; direct header reordering is unwired. This audit does not claim
   that CLZ supports direct header dragging.
7. Collectarr column resize double-click resets to default width, rather than
   fitting current content. Auto-size is a separate setting and measures at
   most 200 entries with a 60–480 px clamp. These are implementation limits;
   CLZ double-click behavior was not independently established.
8. Collectarr wrap uses at most three text lines and then ellipsis. CLZ showed
   wrapped rows in the live table; unrestricted long-text behavior needs a
   dedicated fixture before claiming full parity.

## Table geometry and presentation

9. CLZ measured header height 26.5 px and ordinary row height 26 px. Collectarr
   compact defaults are 28 px header and 34 px row, adjusted by the new spacing
   slider. Defaults remain visibly taller even though adjustable now.
10. CLZ cell text is Gilroy Medium (CSS 400), 14 px, with 2 px vertical / 5 px
    horizontal padding; headers are Gilroy Bold (700), 14 px. Collectarr cells
    inherit Manrope body weight at 14 px; headers use 13 px / 800. The optical
    medium correction applied to edit tabs has not aligned table cell text.
11. CLZ headers measured #464950, with the sorted header #262626. Collectarr
    uses a similar header family but different sorted-header indicators:
    accent arrow plus visible priority number even for a single sort.
12. CLZ numeric/date columns are right-aligned in the captured table. Collectarr
    Discs/Tracks are right-aligned, but Release Date and Length are left-aligned.
13. Release dates in the local table display as `2026-02-18`; the CLZ reference
    displays `Feb 18, 2026`. Table formatting is not aligned with the reference
    display-date preference.
14. Genre uses comma-separated text locally, while CLZ displays ` | `.
15. Selection/status/edit utility columns have more separation locally. CLZ
    measured 28 px each; Collectarr inserts additional columnSpacing between
    utility cells. The local pencil is muted gray; CLZ uses its selection accent.
16. Collectarr includes a select-all checkbox in the header; the CLZ captured
    header is blank in that cell and uses All in selection mode.

## Toolbar, favorites and dialogs

17. CLZ's compact list toolbar places view, sorting and columns together. Local
    order is sorting, view, density, columns and row-height slider, plus Tools
    and a filter chip. Density/spacing are deliberate extra functionality, but
    their footprint needs responsive treatment.
18. Local favorites menus add bookmark icons and numeric column counts. CLZ
    uses a check for the active favorite, compact separators and a gear at
    Manage Favorites. Local column icon is visibly smaller inside a framed
    split button. Menu contents otherwise reflect different user presets.
19. Column editor integrates a favorites panel, counts, search placeholder and
    Reset. CLZ opens the current named preset directly in a compact two-column
    chooser. Local rows are taller and Title has a lock instead of removal.
20. Sort editor is a wide three-panel favorites/preset/fields workspace; CLZ is
    a narrow two-column chooser. Local width is 960 px, CLZ modal 600 px in the
    captured DOM. Inline favorites management is extra UI, not missing sorting.
21. Modal headers differ: local dark title and square framed X on accent;
    CLZ white title and plain white X, rounded upper corners. Selected field
    rows and category backgrounds also differ in shade and spacing.
22. Selection mode correctly replaces the local normal toolbar, with Cancel,
    All, Edit, Remove, Print, More and count. Local actions are centered over a
    wide pane; CLZ packs them immediately after Cancel/All. More menu is close
    structurally, with the disabled actions and move bug noted above.

## Responsive behavior

23. At 1000 px, the tested CLZ layout gives the active inspector most of the
    main area. Collectarr keeps sidebar + narrow table + inspector; toolbar
    controls and most table columns move outside the available visible width.
24. At 700 px, CLZ hides the folder pane/inspector in the observed list state
    and gives the table full width, with a folder Back affordance and floating
    Add button. Collectarr keeps the 250 px folder pane and stacks inspector
    below the table. Its multi-row top controls consume substantially more
    vertical space, and only Artist plus part of Title remain visible.
25. At 700 px, CLZ retains view/sort/column dropdowns immediately above the
    table. Collectarr switches to compact top chrome and View & Organize,
    changing access to those controls; this is a different workflow.

Suggested implementation order: fix collection transfer dispatch; complete
explicit columns and scalar sorts; improve narrow layout and toolbar access;
align table typography/date/alignment; simplify chooser geometry and favorites
chrome. XML/merge require separate feature decisions. Do not revive legacy
Classical/People or old Music recording fields merely to match CLZ labels.


## Field chooser cutover ? 2026-10-11

Select Sort Fields and Select Column Fields now use a shared 600px dialog,
38px white-on-accent header, top alignment, two equal field panes, and a fixed
Cancel/Save footer. Available categories and checkbox rows are 28px high;
selected rows use the existing folder-favorite reorder list, insertion
placeholder and hover/drag animation. The selected pane is inset, without
extra available/selected headings or counts. Columns show the configuration
name; sorting shows a field-priority summary and compact ASC/DESC controls.
Folder Favorites shares the field search, category and checkbox primitives.

The duplicated chooser pane/category/selected-row implementations were deleted.
Title can be removed unless a caller explicitly requires a primary column.
Sort priority follows the saved row order; at least one sort is retained.
Favorites remain accessible from the header gear. Search and checkboxes use the
current kind accent. Available fields are alphabetical within each category;
selected fields retain their explicit order. Narrow dialogs stack the panes.

Validation: 20 chooser/folder widget tests, including drag/save round trips,
direction changes, Title removal and a 350px window; 277 library/Music/report
regression tests; analyzer clean; Windows debug build succeeds. Live browser
screenshots compare both choosers with CLZ and check 2508px/700px layouts.
Manrope remains the app font; the geometry and weight approximate CLZ without
copying its font files or restoring obsolete Music fields.


## Spreadsheet and selected-entry follow-through ? 2026-10-11

The toolbar keeps View, Sort and Columns adjacent, then additional layout,
density and spacing controls. Favorite menus use an active check and a gear,
without bookmark/count decoration. At 700px the table uses the available width
and retains the same controls; folder navigation moves to a dropdown and Add
floats. A narrow inspector replaces the table when activated and has Back.
Desktop resize preferences remain intact. Utility cells are 28px with no extra
column spacing, and the application header checkbox is omitted. Header dragging
can insert before/after the target, including the final position; double-click
on a resize handle fits the column to all displayed values.

Selected local entries can now open an XML preview with copy/download. XML
serializes typed canonical entry JSON recursively, including nested stable IDs,
arrays, booleans and escaped text; it is a Collectarr export, not a CLZ import
compatibility format. Music exposes merge through its kind policy contribution.
The user chooses the retained album and donor order; the transaction appends
discs, preserves retained edition/personal data, remaps colliding contained IDs
and header links, scopes donor album credits to their discs, moves attached
records, and archives donors. It does not mutate Core catalog records.

Browser validation on an isolated reference collection opened XML, duplicated
an entry, selected both copies, chose the retained album and merged them into
one active row with two discs/two tracks and 8:30 duration. No app exceptions
were captured. Domain tests cover strict round-trip identity and rollback;
widget tests cover menu eligibility updates and deferred dialog dispatch.
