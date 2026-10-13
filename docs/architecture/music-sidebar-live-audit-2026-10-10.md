# Music sidebar, sorting and columns: live CLZ comparison

Audit session: 9?10 October 2026. Viewports: 1440?900 and 700?650.

CLZ was inspected in an authenticated, separate browser page. Collectarr used an isolated local web origin with disposable manual Music entries. After CDP stopped, a fresh temporary Playwright browser verified the rebuilt app with three entries (Jazz, Rock, and no genre). No CLZ album edits, vocabulary writes or collection membership changes were saved. Switching the CLZ view to List can update its view preference.

## Verified interactions

| Surface | Live observation | Collectarr outcome |
| --- | --- | --- |
| Sidebar bucket selection | CLZ Vinyl Color `dad` reduces 39 albums to 4; All Albums restores 39. | Rebuilt Genre None selection reduces three entries to the one empty entry; All Albums restores all three. Shared sidebar/scope tests pass. Nested drilldown/reset behavior remains a separate open check. |
| Sidebar search | CLZ search `dad` leaves that bucket only; an unmatched query hides all rows, including All Albums and None. Search is local to folder names. | Collectarr has a local folder-name search and tests for sidebar behavior. Do not claim a completed live search parity check for this fixture. |
| Group selector | CLZ exposes No Folders, Manage Favorites, Favorites, and grouped field lists. | All of these sections are present; Main expands to Artist, Disc Format, Disc Format Family, Genre, Label and date groups. |
| Sorting editor | CLZ has available checkbox fields, ordered selected rules, ASC/DESC, remove, search, Cancel and Save. | Corresponding controls exist. Search clear now clears both the visible text and filtering state; a widget regression verifies a second query and cancellation. |
| Sort favorites | CLZ defaults to Artist / Title and also offers user favorites. | Music now owns canonical Artist / Title, Title A?Z, Latest release, Recently added and Value high to low presets. Recently added reads added_at; value reads market_value. Unsupported presets are excluded from the current dialog's available sort surface. |
| Sort resize | Collectarr's old 300 px favorite pane crushed field names at 700 px. | Below 900 px dialog width, favorites move to a header menu. Selecting Latest release from that menu and keeping the editor free of Flutter layout exceptions are covered by a widget test. Desktop favorite pane is now 210 px. |
| Column chooser | CLZ shows available grouped fields and a reorderable selected list with Cancel/Save. | Collectarr provides those controls plus a favorites shelf and Reset. Search clear is fixed and regression tested. |
| Music columns | Collectarr previously displayed fallback headings and empty Genre/Release Date cells because the entry schema omitted default catalog columns. Shared default favorites also used unregistered generic IDs. | Both Music schemas now reuse explicit Music-owned catalog columns. Genre, Release Date, Track count, Label, Catalog Number, Barcode and Format Summary use their registered definitions. Music column favorites use canonical IDs. Contract tests verify every preset field exists in the entry schema. |

## Geometry, typography, colors and icons

These are measured observations, not a claim of pixel equality.

| Detail | CLZ | Collectarr / remaining difference |
| --- | --- | --- |
| Sidebar width | 250 px | 250 px in the desktop audit. |
| Folder rows | 27 px | Shared row primitive uses 27 px. |
| Folder search | 26 px; background #444444 | Dense search control present; final screenshot-level color comparison still pending. |
| Count badge | #464950; selected badge white | Shared folder primitive already uses the CLZ dark badge/hover tone and contrasting selected badge. |
| Selected folder | #5eb1de blue | Collectarr uses the kind accent, orange for Music. The user explicitly chose this appearance; blue selections are not a parity target. |
| Sort dialog width | 600 px; top at approximately 28 px | Collectarr is capped at 960 px, starts 28 px below the top and retains its favorites pane/menu. Its composition intentionally remains different. |
| Sort/column dialog header | 38 px, solid #f2932f | Sort, columns and collections now use a solid kind-accent header with a 38 px minimum height. Other dialogs retain their existing chrome. |
| Dialog body | #262626 | Collectarr uses app palette panels and extra pane borders; still different. |
| Available field labels | Gilroy, 14 px, weight 700 | Collectarr uses bundled Collectarr Sans. Weight and metrics should be assessed per control; these fonts are not identical. |
| Selected sort row | Compact drag bars, ASC/DESC, close icon | Collectarr uses compact drag / ASC-DESC / remove controls and puts Move up/down in an overflow menu. Material icon shapes remain different. |
| Sidebar manager icon | Font Awesome list icon | Collectarr uses Material format_list_bulleted. Shape differs despite equivalent purpose. |
| Alphabetical/count sort | Font Awesome sort-alpha-down / sort-amount-down | Collectarr uses Material sort_by_alpha / sort inside a segmented control. Shapes differ. |
| View chooser | List, Vertical Cards, Horizontal Cards, Covers, Shelves | Collectarr additionally has Flow Carousel; Shelves was disabled in the inspected web fixture. |
| Column favorites | CLZ uses a split toolbar selector and a compact field editor | Collectarr uses a selector plus an in-dialog favorites shelf. The old fixture's shelf was empty due to invalid generic preset IDs. Canonical Music presets correct those definitions; the rebuilt shelf was still empty because the generic dialog caller passed only saved presets. A follow-up fix now passes supported kind favorites, protects the schema primary column, and falls back to metadata labels for icon-only columns such as Cover. A caller-level widget regression verifies this wiring. |

## Intentional domain differences

Keep Music v2 semantics: Credits replaces Classical/People; recording fields belong to discs; Disc Format is many-valued while Format Summary is a display scalar. Do not restore CLZ root recording fields or compatibility aliases to match its menus.

Catalog Item and Library Entry remain distinct workspace surfaces. Personal columns and sorts must only be exposed on an entry surface; do not silently turn a partially available preset into a different preset.

## Next live checks

1. Resume the authenticated browser and verify folder search, alphabetical/count sorting, dictionary manager read-only controls, nested favorites and back navigation on matching fixtures.
2. Confirm the rebuilt column editor labels, values, preset application, drag order persistence and Cancel/Save semantics.
3. Compare remaining exact icon shapes and font metrics. Preserve kind-accent selections and buttons, as requested by the user.
4. Check 700 px and smaller column dialogs with saved favorites and long names; the sorting regression currently targets 700?650.

Resolved live discrepancy: Genre previously showed All Albums = 3, Jazz = 1 and Rock = 1, but no None row for the third entry. The facet loader omitted entries without values. It now creates the shared `[None]` bucket from valid shelf IDs not assigned to any named bucket, including a membership map used for filtering and collection-scoped counts. The rebuilt three-entry fixture shows All Albums = 3, None = 1, Jazz = 1 and Rock = 1. Selecting None shows only the empty-genre album; selecting All restores all three. This was a projection defect, not a persistence defect.

The earlier CDP browser stopped responding on 10 October. Automatic approval review rejected relaunching Chrome with the authenticated profile and remote debugging; no additional reason was provided. A standard Playwright launch with a fresh temporary profile succeeded. Later, Opera DevTools MCP and its CLI successfully opened a separate Opera profile, which the user authenticated to CLZ. Live reference checks have resumed through that CLI. The ChatGPT Browser Connector is installed and enabled separately; this audit uses the working local CLI commands.

## Resumed Opera CLI checks

The authenticated CLZ viewport was 1844 x 945. Collectarr's three-entry fixture was verified at 1440 x 900, and its collection manager was also captured at 1844 x 945 to match the reference. These checks establish interaction behavior and measured geometry, not complete pixel parity.

| Interaction | Observed result |
| --- | --- |
| Switch collection | CLZ music2 contains one album; music contains 39. Switching changes results and folder counts together. The original music2 selection was restored. |
| Search folder names | Searching `dad` leaves only its bucket, while the result list remains at 39 until the bucket is selected. An unmatched query hides All Albums and None as well as named buckets. Search was cleared after inspection. |
| Select / restore folder | Selecting `dad` reduces the results to four; All Albums restores 39. Counts remain 39 total, 35 None, four dad. |
| Sort draft | Adding Label appends an ASC rule; the direction control changes it to DESC; removal removes that rule. Cancel and reopen preserve the original Artist ASC / Title ASC rules. No sort changes were saved. |
| Column draft | Removing Genre changes the draft selected list. Cancel and reopen restore Genre in its original position among the nine configured columns. No column changes were saved. |
| Manage Collections | CLZ displays draggable rows, album counts, red Private indicators, edit/delete actions, Create new collection and OK. Collectarr displays rows, item counts, a lock / Private label, edit/delete actions, Create new collection and OK. Creating, renaming, deleting, sharing and persisting reorder have not been checked in the live reference during this pass. |

The CLZ sort dialog measures 600 px wide, starts 28 px below the viewport top, has a solid #f2932f header and #262626 body. Available field labels use Gilroy, 14 px, weight 700. The folder list measures 250 px wide with 27 px rows; its search is 26 px tall with #444444 background, and the selected folder is #5eb1de.

Remaining collection-manager visual differences: Collectarr's Create/OK actions use orange rather than CLZ's blue, the Create button occupies more height, the Private indicator uses a lock rather than a red circle, and the dialog outline/corners and action spacing differ. Font files also differ. Shared sort/column favorite panes still change the composition relative to CLZ. Keep these differences open; this pass does not claim they have been corrected.

The CLI's resize_page command returns `Browser.setContentsSize: Not supported` in this Opera version. Other tested commands (navigation, page snapshots, JavaScript inspection, click, fill, keyboard input and screenshots) work. Matching the local fixture to the measured reference viewport avoids treating a failed resize as a successful responsive check.

Current validation after the facet fix: 805 Flutter tests passed, one existing skipped; focused facet/sidebar/scope checks passed 14 tests; analyzer clean; Web release and Windows debug builds passed. Live rebuilt None selection and return-to-All both passed.

## Validation

Final full Flutter suite: 802 passed, one existing skipped. Targeted sidebar, sort dialog and column chooser suite: 12 passed. Music favorites contract test: passed. Analyzer clean; web release and Windows debug builds passed. Boundary audit: no AST violations, 364 existing complexity budget reports. Duplication audit: no repeated kind clusters. Column-manager wiring regression passed; final analyzer clean, Windows debug and web release builds passed after the fix. Rebuilt live manager labels include Cover and Title is always visible.

## Commits

- `cedf20b57` ? canonical Music favorites and reused catalog columns.
- `7c64f5f58` ? synchronized field search, explicit accents and narrow sort favorites menu.
- Follow-up column-manager commit wires supported favorites, primary field protection and icon-only column labels.


## Accent-preserving sorting, columns and collections follow-up

The user explicitly rejected blue selections/buttons. All three updated dialogs keep the Collectarr palette and kind accent; color matching to CLZ blue is intentionally excluded. A rebuilt browser screenshot caught one sort row still using the global blue selection. The dialog palette now derives selection tint from the kind accent, and a widget regression verifies that palette relationship.

Sorting and columns start 28 px below the viewport top, use a compact solid 38 px header, cap width at 960 px, and render field labels at 14 px / weight 700. Sorting keeps a smaller 210 px desktop favorites pane and a compact menu below 900 px. Available and selected fields stack below 520 px. Narrow selected sort rows place actions on a second line. Column favorites occupy less vertical space. These choices preserve our controls rather than claiming identical CLZ composition or fonts.

Functional fixes: Flutter onReorderItem already normalizes the destination index; sorting and columns no longer adjust it twice. The visible left column drag handle now starts the gesture. Column favorite matching compares ordered fields, so different orders do not falsely identify the same preset.

Manage Collections now has a compact Create action, aligned 38 px rows, dense edit/delete controls and an accent OK action. At narrow widths the Private label becomes a lock tooltip. Nested create/rename/destination/confirmation dialogs inherit the kind theme. Collections remain private local containers with exclusive membership; no sharing functionality was added.

Verified:

- Real widget drag down, Save and reopen for sorting and columns; Cancel preserves prior direction/column membership.
- Existing preset application, favorites callbacks, primary-column protection and search-clear regressions pass.
- Manage Collections widget flow: create Vinyl, drag collections and verify database order, cancel rename, delete into Main Collection, protect the last remaining collection. Existing repository tests verify membership transfer, active selection, strict names and kind isolation.
- Both field dialogs render without overflow at 420 x 740; rebuilt browser screenshots also cover 1440 x 900 and 700 x 650.
- Rebuilt Playwright fixture: folder-name search hides Rock for Jazz without changing the three-album result scope; vocabulary manager opens; selecting Jazz reduces results to one; Reset folders restores all three. This is a read-only vocabulary check, not a completed vocabulary CRUD audit.
- Rebuilt None / All selection and collection-manager screenshots were also checked in this pass.

Final verification: 809 Flutter tests passed, one existing skipped; analyzer clean; Web release and Windows debug builds passed; no AST boundary violations or repeated kind implementation clusters. The architecture checker still reports complexity budgets (365), which are warnings rather than a clean complexity result.

The previously remaining checks for nested Back, vocabulary CRUD and durable favorites are covered in the follow-up below. Reference collection CRUD/reorder has not been exercised against the user's CLZ data. Material icon shapes and font metrics remain deliberate/unresolved differences; this pass does not claim full pixel parity.


## Nested navigation, vocabulary CRUD and durable favorites audit

Completed against disposable local Music fixtures. The authenticated CLZ account was not modified.

| Flow | Evidence and outcome |
| --- | --- |
| Nested folders / Back | Created a Genre / Disc Format favorite through the manager, selected Audit Jazz, entered Disc Format and used Back to previous scope from the overflow menu. Genre and the one-album scope were restored. History tests also verify renamed buckets preserve unrelated scope state. |
| Create vocabulary | Entering custom Audit Jazz in the Music form creates a reusable Genre option. The manager exposes it alongside built-ins. Creation remains in the value selector/form; the manager does not gain a separate New action. |
| Rename selected vocabulary | Audit Jazz becomes Audit Renamed in item metadata and sidebar buckets; the selected one-album scope is retained. This previously failed because facet caching depended only on item IDs. |
| Remove vocabulary | Removing Audit Renamed clears its item reference and moves the album into None. The three-entry fixture then has None = 2 and Rock = 1. Widget tests also verify canceled removal leaves the option intact. |
| Duplicate vocabulary | A widget regression reproduces renaming a custom Genre to built-in Rock. The manager now rejects it with the existing Merge Mode message and retains the original value. Stored-name validation alone previously missed virtual built-in options. |
| Sort favorite restart | Saved Audit Persisted Sort, canceled the sort draft, reloaded, then closed and relaunched the entire Playwright browser with the same temporary profile. The stored favorite and canonical direction survived. |
| Nested favorite restart | Closed and relaunched the Playwright browser with the same temporary profile; the ordered music.genre / music.disc.format favorite survived. |
| Column favorite durability | A storage-restart regression reconstructs preferences and the store, verifies exact ordered columns and stable ID, verifies isolation from Books and verifies deletion persists. This is an automated persistence check, not a live column-browser restart claim. |
| Accent inheritance | Folder favorites and sidebar vocabulary managers now receive the kind-accent theme, including nested editors/confirmations and selection tint. A folder-dialog widget regression verifies palette accent, primary color and selection tint. The folder-manager settings action also has a descriptive tooltip. |

The facet signature now incorporates update time and immutable metadata identity, so edits invalidate cached buckets even when membership is unchanged. Signature calculation reads existing shelf sources directly rather than reconstructing workspace DTOs. The unused membership-only signature helper was deleted. Vocabulary management captures selection/history before opening the modal and maps replacements into the current bucket and ancestor snapshots on close, preserving route state while asynchronous shelf refreshes run.

Verification: 816 Flutter tests passed, one existing skipped; analyzer clean; Web release and Windows debug builds passed. No AST boundary violations or repeated kind implementation clusters; complexity warnings remain at 365. Browser checks used local temporary profiles and disposable data.

No legacy aliases or migration paths were added. These three previously open audit areas are closed at the evidence levels described above. Full CLZ pixel parity and sharing remain outside this audit.


## Inspector and editor continuation

The [follow-up inspector/editor report](music-inspector-editor-live-audit-2026-10-10.md) records the next live comparison, entry-action wiring gaps, remaining blue editor controls, geometry/font differences, and explicitly unverified flows.
