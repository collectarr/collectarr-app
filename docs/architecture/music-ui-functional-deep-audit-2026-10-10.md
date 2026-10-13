# Music live UI and functional audit — 2026-10-10

This extends the [sidebar audit](music-sidebar-live-audit-2026-10-10.md) and
[inspector/editor audit](music-inspector-editor-live-audit-2026-10-10.md), after
the facet lifecycle fix `e73e8eca4`. It records remaining differences, not an
implementation of them. Collectarr's accent selection and Save color remain
intentional; CLZ blue selection is not a parity requirement.

## Method and evidence limits

Authenticated CLZ Music Web was inspected interactively through the working
Opera DevTools CLI. Collectarr was rebuilt for Web and driven through Playwright
against disposable IndexedDB fixtures. The fixture contains Audit Alpha, Audit
Beta and Lupus Dei, Jazz/Rock genres, a disc, a First Song track and a scoped
Producer credit. Local mutations affect this fixture, not the user's database.
No catalog edits, loans, deletes or backups were saved/executed in CLZ.

Both applications were captured at 1844 × 945, 900 × 700, 700 × 650 and
480 × 650 for Main, Tracks, Covers and My Images. Links was also inspected at
1200 × 800. Opera resizing works with the CLI's `widthxheightxscale` argument;
the previous report's reference-resize limitation is superseded.

“Opened” below establishes the destination and visible controls. It does not
establish that file generation, server synchronization, import, restore or
destructive actions succeed. Core was unavailable locally during this pass.
Admin-only routes were not inspected. An Add Albums drawer automation attempt
timed out; this is not evidence of a product failure. Complete end-to-end feature
parity is therefore not established.

## Confirmed defects and misleading destinations

| Priority | Finding | Reproduction / evidence |
| --- | --- | --- |
| P0 | Previous/Next silently discards editor changes | Change Lupus Dei's title to `Lupus Dei Unsaved audit`, navigate Previous, then Next. The original title returns without a save/discard prompt. The coordinator replaces the edit request without a dirty guard. |
| P1 | Tracks search does not find an existing track | Select Tracks scope and search `First Song`: zero of three albums, although the editor and inspector show that track. CLZ finds its populated album using `Lupus Daemonis`. Collectarr's projection engine accepts `searchTarget` but does not use it when building the filter search document. |
| P1 | Statistics loses valid recent-addition titles | The three named fixture entries appear as `Untitled` under Most recent additions. Statistics reads the optional catalog summary rather than the independent entry's title. |
| P1 | Export to XML opens CSV controls | Sidebar destination offers Copy Collectarr CSV / Copy CLZ-friendly CSV, rather than an XML workflow. A separate XML encoder exists in source; this finding concerns the sidebar wiring, not the absence of all XML code. |
| P1 | Re-Assign Index and Transfer Field Data do not open their workflows | Both drawer actions navigate to Libraries and show “Open the library Tools menu…”. CLZ opens the corresponding dialog directly. The actual Collectarr tools exist elsewhere. |
| Gap | Link Albums is a placeholder | Clicking it displays “Album linking is not available in Collectarr yet.” CLZ has unmatched albums, barcode matching, candidate preview and linking controls. |
| Gap | Cloud Sync & Sharing has no equivalent sharing UI | It opens connection/pairing settings. CLZ offers private/partial/public sharing, per-collection settings and personal-field inclusion. Sync and hosted sharing are different capabilities. |

The initial synthetic click in the loan form did not submit it. Repeating with
a real pointer click successfully created the loan and returned it. This is an
automation correction, not a confirmed loan-persistence defect.

## Sidebar destination inventory

| Destination | CLZ reference | Collectarr observed destination / remaining difference |
| --- | --- | --- |
| Add Albums | Search/add entry point | Present; no complete add/provider/server transaction verified in this pass. |
| Manage Pick Lists | Music vocabulary selector, values and management | Opened. Defaults to Age Rating, including non-Music rating values, rather than a Music-relevant list. Prior audit covers vocabulary CRUD; not all lists were modified again. |
| Manage Collections | Management dialog plus bottom collection tabs | Opened; Main Collection count and create control present. Prior audit covers CRUD/reordering. No new CLZ collection mutations. |
| My Shelf | No identical destination established | Opened: entry/wishlist counts, pricing summaries, filters and shelf actions. Additional Collectarr feature. |
| Libraries | Main collection workspace | Opened: returns to Music workspace. |
| Print to PDF | Report workflow | Opened: all/current/checked scope, album/track mode, columns, sort, page setup, preview. File download and printing not executed. |
| Statistics | Charts, most recent additions and listening summaries | Opened. Recent titles broken; cyan chart/header accents differ from the Music accent. |
| Find Duplicates | Dedicated page with Title, Title & Artist, UPC and Index criteria | Opened: simple local-candidate dialog, initially empty. No corresponding criteria selector. Duplicate creation is verified separately; detector criteria coverage is not. |
| Loan Manager | Current Loans / Loan History, loaner filter, PDF | Opened: barcode loan/return, search and All/Active/Overdue/Returned filters. Entry-level lend/return cycle succeeds; global barcode lookup not verified. |
| Calendar | No matching CLZ destination established | Opened: Activity, Agenda/Month, Today and ICS export. Additional feature; ICS download not executed. |
| Manage Custom Fields | Dedicated page and Add Custom Field | Opened: modal manager. Cyan header and Close action leak the global accent. Creation/validation not repeated. |
| Cloud Sync & Sharing | Hosted privacy/sharing configuration | Opens Settings connection section; pairing and sync controls, no matching sharing configuration. |
| Pre-fill Settings | Personal defaults plus catalog defaults and always-show option | Opened: only Location and Tags. Header remains cyan, Save uses accent. Music v2 defaults should use current disc/credit semantics rather than restore CLZ root role fields. |
| Settings | Skin, detail theme/layout, covers, wrapping, auto-size, language/timezone and other preferences | Opens connection settings. Captured route does not expose a corresponding CLZ appearance-preference page. |
| Re-Assign Index Values | Direct dialog with sort criteria | Drawer only redirects to Tools. CLZ dialog confirmed through the actual action; a direct URL 404 was an invalid probe and is not a CLZ defect. |
| Backup / Restore | Server backup, restore, upload and download | Opens Settings data section: JSON backup/restore and integration exports. Local versus server backup semantics differ. No backup/restore executed. |
| Clear Database | Destructive maintenance action | Opens the same Settings data section; clear control present. No clear executed. |
| Transfer Field Data | Direct source/target transfer dialog | Drawer redirects to Tools instead of opening it. No transfer executed. |
| Export CSV / TXT | Scope, columns, sort, delimiter/enclosure and preview | Opened: corresponding controls and album/track modes present. Generated file/escaping not revalidated in this UI audit. |
| Export XML | XML export | Opens CSV clipboard controls; wrong destination. |
| Import Data | CSV/TXT and provider/application-specific guided imports | Opened: CSV/TXT, Discogs, CATraxx, Delicious Library, OrangeCD, CDpedia, Music Collector and CLZ Music Web. CLZ additionally lists Music Label. Parsing/import transactions not executed. |
| Link Albums | Matching and linking page | Explicit unimplemented message. |
| Keyboard Shortcuts | Help controls | Opened: Collectarr shortcut dialog. Shortcut execution matrix remains unverified. |

## Verified local interactions

- Duplicate Audit Beta twice: the fixture grows from three to five entries.
- Group Genre: Jazz contains two entries, Rock three. Count ordering puts Rock
  before Jazz; alphabetical ordering restores Jazz before Rock.
- Entry Loan: lend to Audit Borrower, then Mark returned; the history shows the
  borrower and lent/returned dates.
- Inspector layout menu exposes Vertical Split, Horizontal Split and No Details.
  Selecting No Details hides the pane, and that preference survives reload.
  Horizontal split drag geometry was not separately exercised here.
- All nine Music edit tabs opened: Main, Details, Credits, Tracks, Personal,
  Custom Fields, Covers, My Images and Links. Tabs have visible icons.
- Previous/Next and track-only search were exercised and failed as recorded
  above. Do not infer success from the presence of their buttons.

Collection CRUD, nested folder navigation, vocabulary edits, column selection
and sort favorites have evidence in the preceding sidebar audit. They were not
all repeated in this pass. All seven collection-status choices are present;
result-count verification for each status still needs populated fixtures.

## Typography, geometry and responsive comparison

| Element | CLZ measured / observed | Collectarr measured / observed | Assessment |
| --- | --- | --- | --- |
| Desktop edit dialog | 1200 px wide, top 10 px | 1200 px wide, top 10 px | Aligned. Tab changes preserve the top edge. |
| Main header | 18 px, weight 700 | Wide desktop 16 px/700; compact 18 px/700 | Desktop title remains too small. |
| Typeface | Gilroy | Collectarr Sans | Different glyph metrics; matching numeric weight alone cannot establish visual parity. |
| Field labels | 13 px/700 | 13 px/700 | Numeric spec aligned; inspect actual face rendering before increasing all weights. |
| Input text | 14 px/400, 34 px input box | Shared body 14 px/500; editor visible controls approximately 32–34 px | Weight differs. Flutter accessibility rectangles can be 40 px and are not the painted field border. |
| Main tab strip | 14 px/400, approximately 32 px | 14 px/400, approximately 33 px | Close; inactive #131313 and active #383838 aligned. |
| Table headings | Reference varies by table | Generic table header 13 px/800 | Requires per-table visual tuning, not a global weight increase. |
| Save | 100 × 32 px, blue | Approximately 100 × 32 px, Music accent | Accent intentional. |
| 700 px dialog | Full available width | 652 px with 24 px side insets | Remaining narrow geometry difference. At 480 px the local dialog fills width. |
| Narrow footer | Status, Index, Quantity above full-width Location | Two-by-two: Status/Index, Quantity/Location | Different breakpoint/layout. |
| Narrow edit tab navigation | Explicit left/right navigation arrows | Horizontal scrolling with clipped offscreen tabs and no arrows | Scroll affordance missing. |
| Covers at 480 px | Narrow stacked presentation | Front cover fills the visible editor area; remaining content requires scrolling | Footer stays visible; check discoverability of Back Cover and horizontal actions. |
| My Images at 700 px | Reference captured for comparison | Drop/paste/click target, description and type, max-five instruction; tall target extends below visible body | Scroll/accessibility interaction still needs a populated image fixture. |
| Links | URL/Description editable row, drag/selection affordances | Name/URL/Description table and add flow | Extra Name is intentional; empty-row and reorder interaction differ. |

Rounded Main fields are now broadly consistent in the screenshots, including
date parts. Genre chips and footer inputs remain aligned at desktop size. This
does not establish caret alignment in every focus state or every tab. Status
icons still use cyan even inside the accent-colored editor.

The Music inspector now visibly includes Overview, track list, disc details,
album metadata, personal data and scoped credits. Copy/Print, listening, image,
link and metadata-filter actions still require an action-by-action outcome
matrix; section presence alone is not sufficient.

## Highlights, icons and motion

- Neutral edit-tab colors match CLZ (#131313 inactive, #383838 active). Music
  accent selection remains intentional. Statistics, Custom Fields and Pre-fill
  headers still expose cyan. Status check icons also retain cyan.
- The drawer uses Font Awesome-style SVG assets, while workspace/editor controls
  include Material icons. The previous report's blanket “Material icons” drawer
  description is superseded. Compare shape, stroke and baseline per control;
  using similar names does not guarantee identical icons.
- CLZ edit tabs, disc tabs and collection tabs use jQuery sortable with horizontal
  axis, 5 px activation distance, pointer tolerance and 250 ms revert.
- Collectarr's edit-tab color transition is 250 ms with ease. Its reorderable
  strip activates via an immediate drag listener and Flutter reorder mechanics;
  equivalent drag threshold, gap motion and drop trajectory are not proven.
- Music disc buttons use 13 px/700 text and radius 3, and lack the same explicit
  animated color container. General edit tabs use radius 4 at the top.
- Drawer section expansion is 350 ms in Collectarr and the CLZ collapse CSS;
  Collectarr's chevron animates separately over 150 ms. Duration agreement alone
  does not establish identical easing or frame-by-frame motion.
- A reference disc drag command completed but the observed order did not change.
  It is an inconclusive gesture, not a passed reorder check. No changed reference
  draft was saved. Live drag/drop and reduced-motion behavior remain open.

## Follow-up order

1. Protect dirty editor navigation; add a meaningful regression test.
2. Route track search through the kind-owned track facts/search contribution.
3. Correct entry titles in Statistics and drawer destinations for XML/index/transfer.
4. Apply Music accent consistently to remaining shared dialogs and chart surfaces.
5. Tune desktop header size, narrow footer, tab arrows, disc typography and drag behavior.
6. Decide and implement sharing/linking/prefill/duplicate-criteria scope explicitly.
7. Complete populated-image, inspector action, export/download, import/restore,
   status-count, keyboard and live reorder checks before claiming feature parity.

Music's generic Credits tab and disc-owned recording metadata intentionally
replace CLZ's Classical/People and root recording layout. No compatibility
fields or old role arrays should be restored for visual parity.

## Verification and retained evidence

### Implementation follow-up

Dirty Previous/Next/Cancel and route Back now use the shared unsaved-change
guard. Save still closes the editor normally. Track-only search uses Music's
contained search facts. Statistics entry titles and direct index/transfer/XML
drawer destinations have been corrected. Pre-fill, Custom Fields, sharing and
export dialogs use the active kind accent, including Save actions.

The resumed live Opera CLI check confirms that CLZ Partial means public without
personal fields, rather than an unlisted link. App and Sync now distinguish
Partial from optional private sharing links. Private/public mode changes rotate
the token, and disabling the private link revokes access. Publishing is an
explicit snapshot operation; automatic republishing after entry changes remains
unimplemented. No CLZ sharing settings were changed in this reference check.

The action matrix in follow-up item 7 and frame-by-frame reorder equivalence
remain open. These implementation checks do not establish complete live parity.

The follow-up gate passes 826 App tests with one skip, analyzer with no issues,
the architecture boundary check, and a Windows debug build. Sync passes all 41
tests and Ruff checks. Regression coverage includes guarded route Back followed
by Save, personal-value exclusion, Partial suppression of personal fields, and
private/public token rotation.

The Web release was rebuilt successfully for this audit. The preceding lifecycle
fix has analyzer, Windows build and 820 passing tests with one skip recorded in
its commit. This audit adds documentation/evidence only; it does not claim a new
application test gate or a new native Windows visual run. CLZ viewport was restored
to 1844 × 945 and reference drafts were canceled.

Selected screenshots contain only disposable Collectarr data:

- [Track-only search failure](evidence/music-deep-audit/track-search.png)
- [Statistics title/accents](evidence/music-deep-audit/statistics.png)
- [700 px Main editor](evidence/music-deep-audit/main-700.png)
- [700 px My Images](evidence/music-deep-audit/my-images-700.png)
- [Pre-fill scope and header accent](evidence/music-deep-audit/prefill.png)
- [Successful returned loan](evidence/music-deep-audit/loan-returned.png)


### Workspace backgrounds and panel dividers

Live CLZ computed styles: folder-panel and view-content both use #383838;
folder-panel-dragger and detail-panel-dragger use #262626 at 6 px.
Collectarr now shares the folder background with cover grids, card browsing,
physical shelves, grouped shelves, and the layout underneath empty content.
Empty grids paint their configured background. Right and bottom inspector
separators use the same continuous neutral divider; dragging keeps the kind
accent. Pane width/height budgets now reserve the actual 6 px separator width.


### Panel grip and toolbar seam follow-up

The CLZ dragger also paints an ::after marker: five 2 x 2 light marks spaced
6 px apart in a centered 34 px strip, rotated vertically for column resizing.
Collectarr renders this pattern directly for both separator orientations,
without a pill outline or external image dependency. The continuous 6 px
seam remains visible and changes to the kind accent while dragging.

Measured toolbar borders are #4A4A4A above and #262626 below in dark mode.
Folder, collection, and unframed inspector toolbars now share those seams.
Raster widget checks cover both grip orientations and opaque seam painting;
existing resize callback and constrained sidebar/inspector tests still pass.


### Collection surfaces and customization settings

Re-inspected the live CLZ Music Settings page through Opera without saving
remote preferences. Its sections are Customization, Localization, Behaviour,
Sorting, Auto Capitalization, and eBay search links. The desktop reference uses
flat rectangular neutral panels and compact labeled controls.

Implemented the collection-surface differences from the follow-up audit:
- List empty canvas and toolbar bands use the same #383838 as folders.
- Table rows alternate #383838 / #2E3035; header cells use #464950, with sorted
  columns on #262626 and kind-accent sort indicators preserved.
- Shared dropdown menus use #444444 with #666666 borders in dark mode.
- Toolbar groups have fine vertical separators. Sort uses A-Z; list uses bars;
  layout and chevron icons are aligned, edit/share use filled icons, and barcode
  search uses a barcode icon. Collections use #272323.
- The inspector toolbar stays above its scrolling content. Its backdrop paints
  actual cover artwork beneath a 90% neutral overlay, with no generated fallback
  artwork. The Music overview no longer adds an opaque bordered card.

Settings keep Connection, Libraries, Appearance, Proposals, Data, Account, Logs.
Medium and desktop widths use scrollable section tabs; compact screens retain
section navigation. Appearance has Customization, Covers & layout, Typography,
and Behaviour & links tabs, with rectangular panels.

Persistent functional settings now include application skin (system/light/dark),
independent Details template (application/light/dark/blue), main screen split,
backdrop, back cover when space permits, wrapped column content, automatic
column widths, status indicators, pencil icons, removal/duplication confirmation,
and eBay visibility, wishlist-only scope, its three display positions, regional
market selection and automatic/all/sold listing filters. Automatic uses all
listings for wishlist entries and sold listings for collection entries. The
Music cover link, inspector toolbar and Links section share that filter; the
cover link uses the kind accent for its text, underline and icon.
Wrapping measures visible rows lazily; auto sizing samples up to 200 entries,
caps widths, and never replaces saved manual column widths. Split selection
writes the existing per-kind workspace preference rather than a second setting.

This closes the audited library surface/display controls. CLZ localization,
separate sort-name display policies, automatic capitalization, application-wide
Blue skin are not replicated by this change.
These need their own consumers and are not represented by inert settings.

Validation: full Flutter suite 830 passed / 1 skipped; analyzer clean; architecture
boundary check has no violations; Windows debug build verified separately.

Regional eBay follow-up: 26 focused settings/inspector tests pass, analyzer is
clean, architecture boundaries have no violations, and Windows debug build passes.
