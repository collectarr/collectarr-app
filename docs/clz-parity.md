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
| Header account | Always signed in to CLZ | Shows "account's music" only while signed in to the optional Sync account |
| Links | The eBay link beside the cover is white | Every link uses the shared link blue |
| List header | No sort indicator | Shared-blue caret and priority number on sorted columns |
| Chrome icons | Dialog and editor titles only | Kind icons in the top bar and dialog headers, kept at the owner's request |
| Narrow windows | Folder panel and details keep their widths; the list collapses to nothing and details run off-screen | Folder panel keeps its width, details shrink to their minimum, the list keeps at least 320 px |
| Settings | One page | The reference page is Appearance > Customization; Connection, Libraries, Proposals, Data, Account, Logs, Covers & layout and Typography are added tabs |
| Played History | Mark as listened records today | A date beside the button records listens on other days |
| Search | Search field only | Extra barcode, cover-search and random-pick buttons |
| Localization | Application language, time zone and a time display format | English only and the device time zone, shown read-only; Music lengths keep m:ss and h:mm:ss, which CLZ Music shows regardless of its time format |
| Sort fields | Back/Front Cover sorts | Has Back/Has Front cover the same need; no separate cover sorts |
| Loan Manager | Current loans only | Also deletes loan records and lends or returns by barcode |
| Add dialog | Search field only | Advanced artist, label and year fields toggle beside the field; cover search sits in the tab row |

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
| Cards | Horizontal title in the link blue, format and year bold, track count and length as two icon badges, no status chip; vertical cards edge-to-edge with white details | Horizontal: #5EB1DE title, 14/400 "CD – 2006", bold "♪ n" over a plain 12/400 length, 21 px status chip bottom right. Vertical: 5 px cover inset, #EBEBEB 13/700 title, #9E9E9E 12 px artist and year, status chip on the cover; selected cards turn #5EB1DE with white text |
| Horizontal cards | Cover in a fixed 72 px column letterboxed inside a 110 px card, leaving empty bands beside and below it | 100 px card; cover sized to its own aspect ratio up to 92 px (default), text 5 px after it |
| Covers and vertical cards | Covers sat on a field-coloured tile with a 1 px border, 2 px padding and a soft 6 px shadow; the cover itself had a second outline and a 16 px shadow; vertical cards had a 1 px border and a 64 px footer | Bare cover with only a 3 px black shadow; vertical cards have a `0 1 3` black shadow, no border and a 62 px footer with an 18.6 px title line |
| Exports | XML, CSV/TXT and PDF generated without feedback; the XML export saved at once; PDF offered a Print / Open button beside Download; Download file replaced Generate on the CSV page | A centred progress window (bold title, message, striped bar) while generating; XML then shows "XML file generated successfully" with a Download button; Generate and Download file are 32 px full-width buttons, Download (green) under Generate, no Print / Open |
| Add Albums search | Advanced fields (Artist, Record Label, Year) under the search; a plain "Searching..." line while waiting | No advanced fields; a spinning arc (56 px) over "Searching..." (28/900, #2E3035) while a search has no results |
| Add/Update from Core settings | The gear in Add and the Settings button opened the Pre-fill dialog; no way to choose what Core downloads | A 600 px dialog with Add from Core and Update from Core tabs. Add: Yes/No download per non-personal field; Update: Skip/Update/Replace per field, each with a Select all row. Add leaves "No" fields empty; Update from Core (metadata refresh) fills or replaces linked entries by mode. Pre-fill stays on the add confirmation and the menu. The reference lists a handful of fields; ours lists every non-personal field Core defines for the kind |
| Browsing background | #383838 behind covers, cards, Card Flow and List | #131313 in dark mode in every view except Shelves, which keeps the shelf style |
| Selection | Items drew unselected until the mouse button was released | Mouse press selects at once; touch and pen select on release |
| Editor | Floating field labels painted at 75% of 13 px (about 10 px); labels pure white; fieldset titles white | Labels paint 13/700 white at 70% opacity (about #C4C4C4 on the panel) and fieldset titles are #999 16.8/700 as in the reference |
| Loan | The item and selection Loan actions opened dialogs (a single-item form and a separate batch dialog) | Both open the routed Loan Album page under the Loan Manager header: item rows, Loaned To, Notes, Loan Date, Due Date two weeks out, blue "Loan Album" button; the selection lends every selected entry |
| Selection toolbar | Kind-accent bar with text Cancel/Edit/Remove/Print to PDF buttons and an "N of M selected" pill | Shared #5EB1DE bar with a #40A3D8 bottom rule: icon-only Cancel, a checkbox "All", icon-only Edit and Remove, a divider, the more menu (Print to PDF first) and an "N of M" pill |
| Column chooser | Cover listed under Main; thin 14 px preset name field | Images group with Back Cover and Front Cover; 34 px 18/700 preset name |
| Sort fields | No Images group, Format or Genre sort | Has Back/Has Front under Images, Format and Genre under Main |
| Chrome | Diagonal dark gradient over the accent in the top bar, dialog and editor headers | Flat kind accent; kind icons kept |
| Alphabet bar | Blue "All" pill; 12 px letters in 28 px slots; "0-9" wrapped at 1280 px | "All" plain; only a chosen letter gets the 30 px blue pill (5 px radius); 14 px letters, labels never wrap |
| Cover columns | 42 px unlabelled thumbnails | Labelled 90 px Back/Front Cover columns with a 79 px image; rows grow to 83 px |
| Details Personal | Separate purchase rows; Quantity and Collection status repeated from the header | One "Purchased" row ("On <date> at <store> for <price>") |
| Details track list | No "Report data error" link | Grey "Report data error >" under the tracks opens the editor (Propose to Core) for Core albums |
| Editor rating | Small stars in a bordered box with a 0/10 counter | Ten 28 px stars, #BBBBBB/#F4B30A, hover preview, no counter |
| Played History | Framed group, "Total Plays", headphones icon | Plain label "(total plays: N)" over a 32 px blue button |
| Statistics | 890 px page, bold summary, small legend squares with counts, 80 px recent rows without track data | 958 px page, bold figures in regular sentences with signed and price/value lines, 40 × 12 legend swatches, 100 px recent rows with tracks and length |
| Settings | Tabbed sub-pages, floating-label near-black selects, Material checkbox tiles | Reference two-column page with blue legends, 34 px #444 selects, compact checkboxes and radios; opens first |
| Resize | Narrow windows shrank the folder panel first, and that clamped width was saved | Folder panel keeps its width; the stored width survives a narrow window |
| Settings Behaviour | No "Adding from Core" | "Add/Update from Core settings" opens the two-tab Core settings dialog |
| Core ID | No Core AlbumID column or sort | Core ID column and sort from the album's Core reference |
| Statistics | Price/value line only with values | Always shown; zero without prices |
| Loans | Free-text borrower; loans list dialog before the lend form; due date unset; return as orange text | Reference "Loan Album" form with a loaner picker, due date two weeks later (calendar days); borrowers have sort name, email and address (schema 2); one-row Loan Manager bar, #CCC count pill, white titles, clock/plane dates, blue return square |
| Sync | Incoming pick-list values lost their sort name and hidden state | Applied with the new contact fields |
| Calendar | Material month, 320 × 352 px, no Today | Reference 221 × 280 month with « », blue weekdays, neighbouring days, Today; title steps to months and years; an outside click closes it |
| Icons | Material icons in Settings tabs, picker carets and loan tabs | Font Awesome throughout |
| My Images | Lighter tile and helper line | #666 dashed tile and instruction on the body colour; helper white at 70 % |
| Motion | 17 menus animated; 54 % backdrop; list rows faded on hover; drawer ignored overlay clicks | Menus open instantly; 50 % backdrop; instant row hover; overlay click closes the drawer (200 ms linear dialogs and drawer, as in CLZ) |
| View menu | Covers used a table glyph, Shelves a Material shelf icon | Own SVG glyphs drawn like the reference: a 3 × 3 square grid and an upright shelf unit |
| Export to XML | The drawer opened an "Export Collection" dialog with a title-only XML; the selection opened a page of XML text | Both show the reference's centred compact confirm (icon, title, message, Cancel/Export) and then save the complete XML |
| Edit buttons | A press that moved more than 18 px before release did not open the editor | Detail toolbar buttons and the list and tile pencils click on release over the button, as browsers do; regression test added |
| Search field | 34 px with an accent border, 12.5 px text, Material barcode, cover and dice glyphs | 30 px #444 field without border, 14 px text and #999 placeholder; a barcode-in-frame glyph, Font Awesome camera and dice |
| Search suggestions | Near-black panel with the title only and a format line | #383838 list flush under the field: 40 px cover, bold "Artist - Title", year, ruled rows, #464950 hover, "View all results ›" |
| Search scope menu | 26 px rows with 13 px icons, opened right-aligned to the button | 30 px rows, 16 px icons, regular weight, left-aligned under the button |
| Zoom | Ctrl + wheel over a list or panel scrolled it instead of zooming | Ctrl/⌘ + wheel zooms wherever the pointer is; regression test added |
| Random pick | Selected an album that could be off-screen or outside the chosen letter | Picks among the shown albums and scrolls List, Cards, Covers and Shelves to it |
| Add dialog | 1320 px two-pane dialog: "Search by" tabs, Manual and Scan links, format chips, side preview, "0 selected" footer | 690 px full-height column 10 px from the top: "Add Albums By:", folder tabs (Artist & Title, Barcode, settings gear), "Add Manually ›", 34 px field with a blue Search button, "N Results" caption with the format select, 71 px rows (cover, title, artist, "CD \| 1 disc, 10 tracks", barcode, checkbox), a "Confirm your selection" sheet over a dimmed dialog; the footer appears only for checked results |
| Sidebar sections | Opened over 200 ms with an ease-in-out curve, the header lit on hover and rippled on click | 350 ms CSS `ease`, chevron turns in 100 ms, no header hover and no ripple |

## Open differences

Verified in the 2026-10-15 pass unless marked *carried over*; carried-over
items come from earlier audits and must be re-checked before closing.

### Functionality

| Priority | Area | CLZ | Collectarr |
| --- | --- | --- | --- |
| P1 | Light theme | Light content areas (white list, light grey folder panel and details) under the dark top bar and toolbars; captured on CLZ Games Web 2026-10-16 | Only the dark theme has been compared; light theme not yet matched |
| P2 | Imports | Also Music Label, OrangeCD, CDpedia | Not offered: no public schema or sample export exists (see [import/export](import-export.md)); CATraxx XML is imported |

### Typography

Equal CSS and Flutter weights do not paint identically, and the bundled face is
not Gilroy. Compare with a user-supplied local font before changing weights.

- Resolved 2026-10-16: CLZ's CSS 400 is Gilroy Medium, and Flutter paints
  outlines about 15 % lighter than the browser, so normal text now uses
  SemiBold outlines in both the bundled and the local-Gilroy family (see
  [local font loading](architecture/local-font-loading.md)). Regular list
  text measures within 5 % of CLZ, bold within 3 %.
- Resolved 2026-10-18: local Gilroy Bold measured 19 % lighter than CLZ's bold
  in the Windows engine (the earlier 3 % figure was the bundled face), so the
  700 slot now uses Black outlines (within 5 %), or ExtraBold (within 10 %).

## Not yet compared live

Add dialog results and the confirm sheet: the comparison build has no Core
server, so they were checked in widget renders against CLZ measurements.
Transfer Field Data, Re-Assign Index, every custom-field subtype editor and
validation state, populated My Images, the Manage Collections/Pick Lists save
flows and Windows native rendering. Shelves, Print to PDF, Manage Collections
and Pick Lists were opened and match in structure; Pick Lists opens the Artist
list directly instead of an empty selector. Opening a menu
does not establish its save behavior.

The toolbar pills, default status filter, detail panel, editor Personal tab,
calendar, My Images, Settings, Statistics, Loan Manager and lend flow, drawer
and window resizing (1844, 1280, 1024 and 800 px) were re-checked side by side
on 2026-10-16. The header account label appears only while signed in to Sync,
so it is covered by tests rather than the signed-out comparison build.
