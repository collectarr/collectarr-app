# Music menu-by-menu live comparison — 2026-10-11

This pass follows the [10 October audit](music-ui-functional-deep-audit-2026-10-10.md)
and the display-settings commits. It separates opened controls, completed local
transactions, remaining differences, and unavailable online transactions.

## Method

Authenticated CLZ Music was driven through Opera DevTools CLI in a dedicated
audit tab. Collectarr's current `lib/main.dart` was compiled for Web **in debug
mode**, with assertions enabled, and driven with Playwright against disposable
IndexedDB fixtures. No user SQLite database was opened or changed. No CLZ album,
personal data, collection, or sharing mutation was submitted.

Every Collectarr drawer destination was opened: 24 destinations. The corresponding
19 CLZ application destinations were opened, followed by the four external Help
links. Main destination captures used 1844 × 945, 900 × 700, and 480 × 650.
All nine Collectarr edit tabs and ten CLZ edit tabs were opened at those sizes.
Collectarr's six view modes, eight import entry points, seven Settings sections,
four Appearance sub-tabs, and six Admin tabs were also opened.

Console/framework assertions, uncaught browser errors, and failed network requests
were recorded separately. A successful screenshot is not evidence that a server
transaction, import parser, restore, or print operation succeeded.

The native Collectarr process was not running during this pass. Interactive
comparison therefore uses Flutter Web; Windows was verified by a debug build,
not a second native pointer-driven audit.

## Defects reproduced and fixed

| Trigger | Observed failure | Fix and verification |
| --- | --- | --- |
| Open Add Albums, then narrow the viewport to 480 px | `No Material widget found` from `LibraryAddModeTab`/`InkWell`, followed by cascading overflows | Compact `LibraryDialogScaffold` supplies `Material`. Route-level widget test opens the desktop dialog and resizes it; live Add recheck has zero framework errors at all three sizes. |
| Open Admin and narrow its collection-schema cards | `RenderFlex children have non-zero flex but incoming height constraints are unbounded` | Stacked schema cards use their children without horizontal `Expanded` wrappers. Scrollable widget test covers 1400, 900 and 480 px; live Admin recheck has zero framework errors. |
| Drawer → Transfer Field Data for independent local albums | Nothing opens because the coordinator requires Core provenance | Remove the unused `catalogRef` transfer property and provenance gate. The dialog now includes the three independent fixture entries. |
| Choose Condition as transfer source | `OpaqueLibraryEntryDispatch` is not a subtype of `MusicLibraryEntry` | Carry the dispatch's opaque **value**, not the wrapper. Regression test reads and writes real Music fields through the transfer capability. Live Copy completes and survives reload. |

Transfer verification: Condition → Purchase Store, Copy mode, three entries.
The UI reports **3 transferred, 0 skipped**. After reload, Purchase Store contains
`Near Mint` and Condition remains `Near Mint`. Core provenance remains absent.

## Drawer inventory

| Collectarr menu | Interaction performed | CLZ comparison / remaining limit |
| --- | --- | --- |
| Add Albums from Core | Opened Search, Barcode, advanced controls and Manual; resized Manual | CLZ has explicit Artist & Title, Barcode and Catalog No. modes. Collectarr's dedicated Catalog No. presentation still differs. Online search/add transaction not established without Core. |
| Manage Pick Lists | Opened the manager and Artist list | Music defaults to Artist now, rather than the old Age Rating destination. CLZ retains role-specific lists; Music v2 intentionally uses generic scoped credits. Full dictionary CRUD was not repeated. |
| Manage Collections | Opened create dialog, created a fixture collection, returned to its bottom tab and reloaded the manager | Creation/tab/persistence verified locally. CLZ manager and counts inspected; no remote creation or deletion. Rename/delete controls are present; not executed this pass. |
| My Shelf | Opened and resized | Additional Collectarr destination; no equivalent CLZ drawer item. |
| Libraries | Opened and resized | Returns to the Music workspace. |
| Print to PDF | Switched album/track scope; opened columns/sorts; expanded page setup; generated and downloaded PDF | Download is a 4503-byte `%PDF-1.5` document. System printing was not invoked. |
| Statistics | Opened and resized with named fixture entries | Recent titles are populated now. Dashboard/chart presentation remains different from CLZ. |
| Find Duplicates | Opened result dialog and the criteria picker | Automatic, Title, Title and artist/creator, Barcode/Identifier and Index **are present**. CLZ uses a dedicated page. This supersedes the old claim that the selector is missing; a duplicate-result matrix was not executed here. |
| Loan Manager | Opened and resized | CLZ exposes Current Loans / Loan History, loaner selection and PDF. Collectarr presents barcode lend/return and its own status filters. Borrower/PDF presentation is still different. |
| Calendar | Opened and resized | Additional Collectarr destination. ICS generation not executed. |
| Admin | Opened all six tabs and resized | Additional Collectarr destination. Local schema explorer works after the layout fix; server panels show unavailable-network states. No admin mutation executed. |
| Manage Custom Fields | Opened empty manager and resized | Collectarr uses a modal; CLZ uses a dedicated page. Custom-field CRUD not repeated. |
| Cloud Sync & Sharing | Opened and resized | Dedicated sharing destination exists. Local Sync endpoint unavailable; no publish, privacy or link-generation transaction verified. |
| Pre-fill Settings | Opened and resized | Personal defaults are exposed, including dates, prices and status. Ordering and some duplicated labels differ. No defaults saved this pass. |
| Settings | Opened all seven sections and four Appearance sub-tabs | Functional display settings exist. CLZ has a centered two-column settings page; Collectarr has full-width panels under tabs. Localization, capitalization and sort-name policy gaps remain. |
| Re-Assign Index Values | Opened confirmation and resized | Uses the current workspace display order. CLZ provides a sort-field selector inside the reassignment dialog. No index reassignment submitted. |
| Backup / Restore | Opened Data section and resized | Local JSON backup/restore differs from CLZ's server backup/upload/download workflow. No restore or backup executed. |
| Clear Database | Opened destination and resized | Routes to Data settings instead of opening CLZ's immediate dedicated confirmation. No database cleared. |
| Transfer Field Data | Opened field pickers; selected source/target; completed Copy; reloaded | Provenance and wrapper bugs fixed. CLZ also offers All / Current List / Checkboxed scope inside the dialog; Collectarr's drawer flow uses the current filtered list. |
| Export to CSV / TXT | Switched album/track scope and CSV/TXT; opened columns/sorts; generated and downloaded CSV | CSV parses into one header and three named album rows. TXT options inspected; TXT file generation not repeated. |
| Export to XML | Opened and downloaded XML | XML parses successfully with `count="3"` and three item elements. The former wrong CSV destination is fixed. |
| Import Data | Opened all eight import guides/wizards; resized each | Text/CSV, Discogs, CATraxx, Delicious Library, OrangeCD, CDpedia, Music Collector and CLZ Music Web. CLZ also offers Music Label. No imported file transaction executed. |
| Link Albums | Opened and resized the three unlinked fixture entries | Dedicated matching page exists, rather than the former placeholder. Server candidate lookup/provenance attachment not verified offline. |
| Keyboard Shortcuts | Opened and resized | Collectarr Help exposes shortcuts. CLZ Help also has Manual, Forum, Contact Support and What's New. Manual/forum loaded; Support/What's New encountered Cloudflare verification, so their contents were not audited. |

## Workspace and editor submenus

- Opened search scope, collection-status scope, folder-field selector, sort
  manager/favorites, view selector, density, Tools, inspector layout/actions and
  bottom collection menu. Expanded CLZ Maintenance, Import/Export and Help.
- Switched through Covers, Vertical Cards, Horizontal Cards, Flow Carousel,
  List and Shelves in Collectarr, including 480 px layouts. No framework errors.
- Opened the actual columns manager through **Columns → Manage columns**, not
  just its preset menu. Compared it with CLZ Select Column Fields. The primary
  title stays mandatory in Collectarr; preset/check styling and available groups
  still differ. No column reorder/preset-save persistence matrix was repeated.
- Opened Main, Details, Credits, Tracks, Personal, Custom Fields, Covers, My
  Images and Links in Collectarr; the corresponding CLZ tabs include People and
  Classical. Music v2's single Credits tab and disc-owned recording fields remain
  intentional domain differences, not missing legacy tabs.
- No new framework exceptions occurred during those editor tab/resize checks.
  Merely opening Covers does not verify Find Online result selection, crop/save,
  image upload or drag/paste lifecycle; those need the corresponding transactions.

## Remaining visual differences

1. **Inspector typography:** CLZ's observed main title is 24 px / weight 700;
   Collectarr Music uses 19 px / weight 800. CLZ section headings are 18 px / 700;
   Collectarr's compact muted accordion headings are visibly smaller.
2. **Font face/body weight:** CLZ computes Gilroy at 14 px / 400. Collectarr uses
   bundled Collectarr Sans, generally 14 px / 500. Editor labels already share
   13 px / 700, but matching numeric weights across different faces does not
   establish identical glyph geometry.
3. **Accent leaks:** the duplicate-criteria picker still has a global cyan
   header. The column-preset menu uses a cyan selected mark and a different dark
   surface. These are separate from deliberate semantic collection-status colors.
4. **Inspector composition:** extra Copy/Print controls, collapsible sections
   and boxed disc summaries differ from CLZ's simpler flowing Details/Personal
   sections. Background canvas/toolbar equality and visible pane drag grips are
   confirmed; this does not make every nested card/menu surface identical.
5. **Settings geometry:** full-width panels, a tall section-tab header and
   switches differ from CLZ's compact centered panels and checkboxes. Appearance
   tabs work, but the page is not a pixel-for-pixel copy.
6. **Tool workflow layout:** duplicates/custom fields are modal rather than
   dedicated pages. Transfer scopes and reassignment sort selection differ as
   described above. PDF/CSV download actions also retain green completion styling.

Kind accent selections and Save remain intentional. CLZ's blue selections are
not a requirement. No unsupported Music root recording/role fields, migration
fallbacks or compatibility models were introduced for visual parity.

## Validation and evidence

- Full Flutter suite: **836 passed, 1 skipped** after the final transfer fix.
- Analyzer: no issues. Architecture checker: no AST violations, 370 informational
  complexity findings. Windows debug build: passed.
- Initial synthetic menu failures and the initial wait for a download directly
  after Generate were automation mistakes. Export requires Generate, then
  Download. The corrected flow produced and parsed the files above.
- Core metadata requests to the configured localhost endpoint were refused.
  Online matching, sharing and catalog writes remain unverified. Their handled
  network error messages are not counted as framework assertion crashes.

Evidence:
[compact Add after fix](evidence/music-menu-audit-2026-10-11/add-compact-fixed.png),
[compact Admin after fix](evidence/music-menu-audit-2026-10-11/admin-compact-fixed.png),
[completed transfer](evidence/music-menu-audit-2026-10-11/transfer-complete.png),
[transfer after reload](evidence/music-menu-audit-2026-10-11/transfer-persisted.png),
[duplicate criteria](evidence/music-menu-audit-2026-10-11/duplicate-criteria.png),
[compact columns](evidence/music-menu-audit-2026-10-11/columns-compact.png),
[CLZ columns](evidence/music-menu-audit-2026-10-11/clz-columns.png), and
[compact scoped Credits](evidence/music-menu-audit-2026-10-11/credits-compact.png).
