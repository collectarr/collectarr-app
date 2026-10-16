# CLZ Music parity

Collectarr Music aims to be an improved, fully FOSS CLZ Music: familiar
workflows and density, a stricter data model, and no proprietary code, fonts or
assets. CLZ is a reference only. This is the single living comparison; update
it instead of adding dated audit files.

Last full pass: 2026-10-15/16, 1844 × 945, signed-in CLZ Music Web in Opera and a
release Web build of `ui-improvements` with the same albums imported.

## How to compare

CLZ is inspected read-only. Open editors and dialogs, then Cancel; never save
reference data. Collectarr uses an isolated browser origin, never a live
database.

```sh
flutter build web --release -o <scratch>/web
python -m http.server 7358 --bind 127.0.0.1 --directory <scratch>/web
opera-browser-cli new_page http://127.0.0.1:7358/#/libraries
```

- Flutter Web exposes an accessibility tree after the
  `flt-semantics-placeholder` element is clicked; `take_snapshot` then gives
  clickable references for both applications.
- Populate the isolated origin through Import → CLZ Music Web with a fictional
  XML file in the format of `test/fixtures/imports/music/clz_web/`. Reproduce
  CLZ albums by title, artist, format and tracks.
- `flutter run -d web-server` stays blank in an automated Opera profile; use the
  release build. Measure CLZ with `evaluate_script` and computed styles, and
  Collectarr from screenshots plus source values.
- Bring a tab to the front (`select_page <n> --bringToFront`) before taking a
  screenshot of it.

## Deliberate improvements

Keep these when matching the reference visually.

| Area | CLZ | Collectarr |
| --- | --- | --- |
| Data ownership | Cloud account is the source of truth | Offline-first local library; Core catalog and Sync are optional and self-hostable |
| Format | One album-level Format pick list | Format is derived from discs; each disc has a format family with format-aware fields (vinyl weight/RPM/side matrices only where they apply) |
| Recording | Album-level Recording Date | Recording data lives on discs, with explicit disc values taking precedence |
| Credits | Separate People and Classical tabs | One Credits tab with album/disc scope, stable contributor IDs and role vocabularies |
| Dates | Fixed date fields | Partial dates (year, year-month, full) everywhere |
| Statistics | One tab per collection | Adds an All Collections tab |
| Views | List, Vertical/Horizontal Cards, Covers, Shelves | Adds Flow Carousel |
| Schema changes | Opaque | Versioned contracts and explicit, ordered migrations |
| Fonts | Proprietary Gilroy | Bundled OFL Plus Jakarta Sans; a user-supplied local font can be loaded |
| Sort titles | Filled in by CLZ Core | Core derives them for new Music items and corrected titles; the app applies the same rule to local Add, Edit and imports |
| Shell top bar | Flat accent | Accent gradient, kept at the owner's request |
| Header account | Always signed in to CLZ | Shows "account's music" only while signed in to the optional Sync account |
| Links | The eBay link beside the cover is white | Every link uses the shared link blue |
| List header | No sort indicator | Shared-blue caret and priority number on sorted columns |

## Fixed in the 2026-10-15/16 passes

| Surface | Problem | Fix |
| --- | --- | --- |
| Folder panel | A fresh library grouped by **Has Back** because fallbacks took the first group; Music declares Artist | Fallbacks resolve the kind's declared default group |
| Cover placeholders | Titles split mid-word (“Discover / y”, “OK Com / puter”) | The title shrinks until its longest word fits |
| List view | “Wrap column content” never wrapped: an ellipsis truncates after one line even without `maxLines`, leaving taller rows with cut text | Wrapped cells clip instead of ellipsizing; regression test added |
| Details panel | Returning from a tool page showed “No album selected”; first-item selection only ran in debug Web | Restores the last selected album for the kind, otherwise selects the first visible one |
| Details header | Album total 67:22 while the Length column showed 1:07:22 | Album totals use h:mm:ss; disc headers keep minutes, as in CLZ |
| Details cover | Placeholder read “Arrival front cover” and used a different color than the grid | The album title is passed unchanged |
| Played History | Listen date field was 170 px and clipped YYYY/MM | Widened to fit its parts |
| Shared blue | Custom Fields help link and Add button, Find Duplicates button and Statistics album titles used the kind accent | Use the shared link/utility blue; Statistics rows follow CLZ's title, artist, format-year order |
| Pane split | Details defaulted to 350 px, so Details, Personal and Links stacked | Music details default to 1060 px (list ~500 px at 1844 px, clamped on smaller screens); the detail toolbar then shows text labels and sections sit side by side |
| Details | Disc band used the kind accent; a lone year read “(2014)” | Shared blue band with white text; the year is parenthesized only after a label |
| Editor | Played History used an accent outline; Add Disc/Add credit mixed neutral and accent outlines; Covers ordered Upload → Find Online with Material glyphs | Blue Mark as listened; neutral shared action style; Find Online → Upload → Remove with Font Awesome glyphs |
| Partial dates | Year-only release dates (the usual import case) left Release Year/Original Year exports, Print to PDF, statistics, technical details and Core match searches without a year | Years are read from the date parts |
| Page tabs | Statistics and Loan Manager used accent-outlined buttons as tabs | Shared folder tabs: active #383838, inactive #131313 with dimmed text |
| Details track list | Spanned the whole panel | One third of a wide panel, as in the reference |
| Shelves/Covers | An album without covers showed the Core cover of another entry linked to the same Core item | The album's own cover is authoritative; regression test added |
| Details backdrop/cover | The backdrop reloaded (flashed) while resizing the panel, and the cover changed size with it | Fixed decode width; covers keep 210 px (430 px side by side) |
| Folder panel | Only [None] closed the special rows | The last special row ([All …] or [None]) gets the 5 px gap |
| Collection status scope | No sign of an active filter; libraries opened on All | 2 px shared-blue outline when not All; libraries open on In Collection |
| Find Duplicates | Centered band with off-screen Keep/Remove | Full-width reference table: grey group rows, blue Keep, red Remove, gaps between groups, Artist/Title/Tracks/Added Date |
| Sort titles | Empty unless typed; title sorting was case-sensitive and ignored them | Filled automatically (Core and app); sorting uses them case-insensitively |
| Release date sorting | Year-only dates sorted as missing | Ordered by the partial date parts |
| Settings | No Sorting, Auto Capitalization or Localization | All three panels, with sort-title/name options, autocap method and exceptions, and date/number/currency formats |
| Toolbar | Plain count text; Material scope chip; "Search albums..." | #4A4A4A count pill, shared-blue scope pill, "Search albums & tracks..." |
| Navigation drawer | Optional sections expanded | Maintenance, Import / Export and Help start collapsed |
| Editor Personal tab | Two columns; currency code in price fields | Three columns on wide editors; the currency symbol follows the display setting |
| Loan Manager | Loose controls under accent tabs | Loaner filter, PRINT TO PDF, count pill and search in one bar on the tabbed panel |
| List view | Wrapped Artist/Title cells clipped to one row: row heights were measured only for plain text cells | Custom cells report the text they can show; regression test added |
| Toolbar | Add Albums used the kind accent, regular weight, wide padding | Shared blue #5EB1DE, 14/700, 30 px high, 4 px radius |
| List view | Grey row checkboxes, white pencils, accent sort caret | Shared blue, white on the selected row |
| Search fields | Material magnifier, muted and small in the folder search | Font Awesome magnifier; white 14 px in the folder search on #444 with 4 px radius |
| Details track list | Muted numbers and durations, no rules; band #5EB1DE with bold duration; discs stacked | 27 px ruled, striped rows with bold centred numbers and white durations; band #71AFD9 with regular duration; discs three abreast on wide panels |
| Details sections | Two columns with heading underlines and section borders; fixed 132 px label column; no row rules | Three columns aligned with the disc columns (Details, Personal, then Notes/Tags/Links); 18/700 headings without underline; 27 px ruled, striped rows with a label column fitted to its labels |
| Details header | Year and label 14/500, whole summary line bold, no rule under the cover | Label and year 15/700, genres/barcode/country 14/400, only the format bold; a #5A5A5A rule 20 px under the cover |
| Details Personal | "Added"/"Modified" as dates | "Added Date"/"Modified Date" with time, as in the reference |
| Editor | Opened 30 px from the top; inputs painted 32 px (the outline follows the content box, not `minHeight`); Artist rows 36 px; tab icons ran into wide labels | 10 px from the top; text, pick-list and name fields paint 34 px; fixed 18 px tab icon boxes |
| Editor | Cancel on an untouched album with no stored sort title asked to discard changes, because the draft derives the sort title | Changes are compared with the draft's own first output; regression test added |
| Column chooser | Cover listed under Main; thin 14 px preset name field | Images group with Back Cover and Front Cover; 34 px 18/700 preset name |
| Sort fields | No Images group, Format or Genre sort | Has Back/Has Front under Images, Format and Genre under Main |

## Open differences

Verified in the 2026-10-15 pass unless marked *carried over*; carried-over
items come from earlier audits and must be re-checked before closing.

### Layout and chrome

| Priority | Surface | CLZ | Collectarr |
| --- | --- | --- | --- |
| P2 | Alphabet bar | “All” is plain bold text | Blue “All” pill; the Artist/Composer/Title field chooser matches |
| P2 | Editor header | Flat accent 38 px bar, title only | Accent gradient with the kind icon |
| P2 | Cover columns | 90 px Back/Front Cover columns with 80 px images and header labels | 42 px thumbnails without header labels |
| P2 | Search | Search field only | Extra barcode, cover-search and random-pick buttons |

### Functionality

| Priority | Area | CLZ | Collectarr |
| --- | --- | --- | --- |
| P2 | Localization | Application language, time zone, time display format | English only; device time zone; durations as minutes:seconds |
| P2 | Editor rating | Ten large stars | Small stars with a 0/10 counter |
| P2 | Sort fields | Back/Front Cover and Core AlbumID sorts | Not offered; adds Status, Tracks, Purchase date and Personal/Recording/Activity/Loan/Value groups |
| P2 | Details Personal | One "Purchased" row ("On Oct 04, 2026"); no Quantity or Collection status rows | Separate purchase date/store rows; shows Quantity and Collection status |
| P2 | Imports | Also Music Label, CATraxx, OrangeCD, CDpedia | Not offered until authentic export fixtures are verified (see [import/export](import-export.md)) |
| P2 | Loans | Borrower profiles with email, address and sort name *(carried over)* | Borrower names, filters and history only |
| P2 | Report data error | Link under the track list | Corrections are proposed to Core from the editor |
| P2 | Statistics | Signed-album count, price/value line, track count and length per recent addition | Price/value line shown only with values; no per-addition track count/length |

### Typography and visuals *(carried over)*

Equal CSS and Flutter weights do not paint identically, and the bundled face is
not Gilroy. Compare with a user-supplied local font before changing weights.

- Calendar: CLZ uses a compact anchored month (14/700 header, blue weekdays,
  14/400 days); ours keeps a separate modal with a large date header.
- Settings: CLZ is one centered two-column page with 34 px #444 selects and
  compact checkboxes; ours adds category and Appearance tab bars, near-black
  floating-label selects and wider checkbox spacing.
- Icon systems are still mixed in Settings sub-tabs and picker actions.
- My Images intake: CLZ 164 × 300 tile, 18/700 #666 instruction on the body
  color; ours is lighter with 14 px text.
- Inspector: CLZ title 24/700 and 14/400 values; compare section spacing and
  separators at matched widths once the default split matches.

## Not yet compared live

Transfer Field Data, Re-Assign Index, every custom-field subtype editor and
validation state, populated My Images, the Manage Collections/Pick Lists save
flows and Windows native rendering. Shelves, Print to PDF, Manage Collections
and Pick Lists were opened and match in structure; Pick Lists opens the Artist
list directly instead of an empty selector. Opening a menu
does not establish its save behavior.

The toolbar pills, default status filter and detail panel were re-checked side
by side on 2026-10-16. The Settings panels, Loan Manager, editor Personal tab,
drawer and header label are covered by tests but have not been re-checked in
the browser yet.
