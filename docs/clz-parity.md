# CLZ parity

Collectarr aims to be an improved, fully FOSS CLZ Music, Games and Comics: familiar
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
- Read colours from computed styles, not screenshot pixels: Chrome
  colour-manages the page, so CLZ's CSS #00AEE6 paints as #50AEE5, and a
  colour copied from a pixel paints lighter again.
- Compare text with local Gilroy loaded (Settings > Appearance >
  Typography > Import local fonts) and CLZ's computed styles; its CSS 400 is
  Gilroy Medium.

## Deliberate improvements

Keep these when matching the reference visually.

| Area | CLZ | Collectarr |
| --- | --- | --- |
| Data ownership | Cloud account is the source of truth | Offline-first local library; Core catalog and Sync are optional and self-hostable |
| Format | One album-level Format pick list | Format is derived from discs; each disc has a format family with format-aware fields (vinyl weight/RPM/side matrices only where they apply) |
| Recording | Album-level Recording Date | Recording data lives on discs, with explicit disc values taking precedence |
| Credits | Separate People and Classical tabs | One Credits tab with album/disc scope, stable contributor IDs and role vocabularies |
| Comic creators and characters | Read-only Core lists plus a separate per-copy Custom list for each | One editable list each of names with role or real name, as in Music; no separate person or character records or Core IDs |
| Dates | Fixed date fields | Partial dates (year, year-month, full) everywhere |
| Statistics | One tab per collection | Adds an All Collections tab |
| Views | List, Vertical/Horizontal Cards, Covers, Shelves | Adds Flow Carousel |
| Schema changes | Opaque | Versioned contracts and explicit, ordered migrations |
| Game valuation | Core Region (US/EU) chooses which PriceCharting prices CLZ fetches | No price fetching (PriceCharting's terms), so no Core Region; the PriceCharting ID already names the NTSC or PAL release and opens its page |
| Comic valuation | CovrPrice values and CovrPrice export | No CovrPrice: it is paid and has no public API, so value stays the user's own My Value |
| Cover images | Covers are links to CLZ's own image servers | Covers from other sites are downloaded once and kept with the entry (scaled to 600 px wide at most) and travel with Sync; only Core covers stay links, cached locally. The web app cannot read other sites' images (no CORS), so it keeps their links until a native client syncs the covers |
| Fonts | Proprietary Gilroy | Bundled OFL Plus Jakarta Sans; a user-supplied local font can be loaded |
| Sort titles | Filled in by CLZ Core | Core derives them for new Music items and corrected titles; the app applies the same rule to local Add, Edit and imports |
| Header account | Always signed in to CLZ | Shows "account's music" only while signed in; personal sync uses a separate endpoint and key, and its header action stays hidden until these are configured |
| My Account | Blue account sidebar and an external account portal | Neutral sidebar matching the main navigation; a local overview across libraries, sync status, activity and account settings. Logout clears the session while keeping local collections |
| Links | The eBay link beside the cover is white | Every link uses the shared link blue |
| List header | No sort indicator | Shared-blue caret and priority number on sorted columns |
| Chrome icons | Dialog and editor titles only | Kind icons in the top bar and dialog headers, kept at the owner's request |
| Narrow windows | Folder panel and details keep their widths; the list collapses to nothing and details run off-screen | Folder panel keeps its width, details shrink to their minimum, the list keeps at least 320 px |
| Settings | One page | The reference page is Appearance > Customization; Connection, Proposals, Data, Account, Updates and Logs are added tabs; pick lists and keyboard shortcuts stay in the main menu and Tools, so there is no Libraries tab |
| Played History | Mark as listened records today | A date beside the button records listens on other days |
| Search | Search field only; regular expressions only in the old desktop app | Extra barcode, cover-search and random-pick buttons; "matches:" regular expressions in the local search, never sent to Core |
| Localization | Application language, time zone and a time display format | The Application Language list shows CLZ's 12 languages with their flags (FOSS flag-icons) and native names; the interface is English only so far, so the others are listed but disabled. The time zone follows the device, shown read-only; Music lengths keep m:ss and h:mm:ss, which CLZ Music shows regardless of its time format |
| Sort fields | Back/Front Cover sorts | Has Back/Has Front cover the same need; no separate cover sorts |
| Loan Manager | Current loans only | Also deletes loan records and lends or returns by barcode |
| Add dialog | Search field only | Advanced artist, label and year fields toggle beside the field; cover search sits in the tab row |
| Backups | Web: one downloadable backup file made on request; the old desktop app kept time-stamped backups for a set number of days | Desktop and mobile copy the database daily and before every restore or clear, prune by a kept period and restore from Settings > Data; a restore first keeps a copy of the current data, so it can be undone |
| Number order | Text compares character by character: 12 before 2, Raft 10 before Raft 2 (checked on CLZ Music Web, 2026-10-18) | Digit runs compare by value: 2 before 12, Raft 2 before Raft 10 |
| Sort Names | Shown only on the person lists (Artist, Composer, Conductor, Musician, Engineer, Producer, Songwriter, Signee) and Box Set; the other lists store one but hide it, so "The End Records" stays under T | Every pick list shows its Sort Name, fills it from the Name as it is typed (the article rule, as for Sort Title), and every pick-list folder is ordered by it |

## Comics comparison

Comics is the next public kind under development on `comics`. Existing Comics
code is scaffolding, not evidence of reference parity. The branch exposes the
library for isolated validation; release readiness depends on the workflows below.

| Status | Workflow | Reference and validation needed |
| --- | --- | --- |
| Inspected; gaps open | Library and series browsing | Main menu, layout menu and details panel inspected; List columns, sorts and the details panel layout remain open (see below) |
| Inspected; gaps open | Add Comics | Compared live against a seeded local Core on 2026-10-30: Series tab, issue grid and list, sort, check-all and the confirm sheet match; series suggestions while typing, the count pill for owned series, NCBD and the Pre-fill fields remain open (see below) |
| Inspected; gaps open | Issue editor | Eleven tabs inspected; pick-list contents, save round-trips and visual comparison remain open |
| Inspected; gaps open | Personal collection | Reading, grading, signatures, purchase, value and storage fields inspected; collection actions and loans remain open |
| Pending inspection | Series completeness | Missing issues, variants, collection boundaries and available actions |
| Partially inspected | Bulk and portability | Import sources and Export to CSV/TXT/XML inspected; export columns, XML import and multi-selection remain open |
| Pending inspection | Visual and accessibility checks | Default/dark appearance, narrow windows, keyboard traversal, empty states and invalid input |

The signed-in reference library and all eleven issue editor tabs have now been
inspected, including the manual-add shell. Editors were closed with Cancel;
no reference records were added or changed. Captures remain in temporary
storage. The following is an observed inventory, not a parity signoff.

| Reference surface | Observed controls and remaining work |
| --- | --- |
| Editor tabs | Main, Details, Value, Personal, Custom Fields, Covers, My Images, Creators, Characters, Plot, Links. Collection editor navigation now follows this order. Removed the extra Entry tab and embedded its grading fields in Value; full visual comparison remains open |
| Main | Series, Barcode, Format, Series Group, Issue No., Variant, Variant Description, partial Cover/Release Dates, Publisher, Imprint |
| Shared editor footer | Collection Status, Index, Quantity and Storage Box remain visible on every tab; Previous/Next appear for existing issues |
| Details | Crossover, Story Arc, Title, Subtitle, Country, Language, Age, No. of Pages, Genre in two columns: Crossover, Title, Country, Age with No. of Pages on the left; Story Arc, Subtitle, Language, Genre on the right. CLZ keeps no separate ISBN or UPC (Barcode holds either), Edition title or Age rating; Collectarr's Details no longer edits them and keeps Core's ISBN/UPC identifiers for barcode lookup. Crossover, Story Arc, Country, Language and Age are single-value pick lists and only Genre takes several values, as in CLZ; an unchanged Story Arc keeps any further arcs from Core (compared 2026-10-30). Subtitle and Variant Description round-trip independently of edition title. Series edits preserve the issue title. Age now has its own `publication_age` field and vocabulary, separate from audience age rating; the inspected CLZ account supplies Modern as a user-list value |
| Value | Grade, Raw/Slabbed, My Value, Signed by, Grading Company, Slab Certification Number, Grader Notes, Label Type, Custom Label, Page Quality, Key, Key Reason, Key Category, purchase and sale facts, Cover Price |
| Key selector | Implemented Major/Minor/Trivia/No in the typed entry editor, replacing the boolean plus free-text severity. Key Reason and Key Category remain available even with No; round-trip coverage added. Visual comparison remains open |
| Personal | Read No/Yes, Read Date, Notes, Owner, My Rating, Tags, Bag/Board Date. Read Date and Bag/Board Date drew a floating label with the calendar after the boxes; every date field now shares the Cover Date control, with the calendar in the label row as in CLZ (2026-10-30) |
| Images | Separate Front/Back Cover controls; My Images supports descriptions and types. Preserve Collectarr's independently implemented image system |
| Credits and characters | CLZ shows read-only Core lists beside per-copy Custom lists. Collectarr keeps one editable Creators list and one Characters list (see Deliberate improvements); Core and App dropped the duplicate `contributors` and `character_details` fields and the person/character IDs. The unreachable Creator, Character and Story Arc pages were removed; character and story arc folders are counted locally |
| Add modes | Series, Issue, Barcode, NCBD and Add Manually; Add opens on Series. Series: a title search with suggestions (cover, publisher, year span, issue count), a series list with issue counts and "Not found? Add it manually" under it, then a cover grid of the chosen series with a checkbox per issue, All (n), issue/variant badges, cover month and variant description, owned/sort toggles and grid/list views. Barcode: one field with Search. Collectarr matches the Series flow (opening on Series, the grid and list, Sort Issues, a partial All check) and adds cover scan. Open: suggestions while typing a series, NCBD (needs a Core release-week query) |

Manual Add now follows the same eleven-tab order, with Main publication fields,
Details issue title/subtitle, Value grading/purchase/sale controls, Personal
reading/rating/Bag/Board Date and an editable Plot. Front/Back Cover controls
are separate from My Images. Its common footer preserves Index and Quantity;
the typed create payload now retains reading, quantity, index, value and sale
data. A widget regression traverses Personal and Plot and verifies the resulting
copy snapshot. Empty private issue titles are allowed, matching Music/Games.
Main/Details use the kind-owned column composition over the existing form
renderer; Value/Personal reuse common responsive rows, inputs and pick lists.
Tab icons come from `AppIcons`, and collection editor dimensions/insets match
Music/Games. Repeated Main/Details section headings and the redundant Plot label
were removed. The reference tab strip measures 32 px high with 14 px text,
weight 400 and 5/10 px padding: the shared strip already supplies those values,
so Comics does not introduce another tab primitive. Grading Company, Label Type
and Custom Label now use managed lists without invented built-in choices.
Browser keyboard input and a widget regression confirm that switching Main and
Details preserves Series/Issue/Variant without putting them into Title.
Complete browser save/reload and the remaining tab comparisons stay open.

The branch now registers Comics in Core, Sync and App. Core's ordered schema
upgrade preserves existing Music/Game records; App schema 5 adds the three
Comics tracking tables without replacing existing data or pending sync work.
Catalog create/read/search and Sync snapshot tests pass in isolated storage.
App connects Comics to barcode, calendar, managed lists, serial authority and
CSV import. The CSV importer preserves series/issue/variant identity, publication
date precision, personal grading, reading and quantity. The actual CLZ Web XML
export was inspected read-only in temporary storage; XML and image import remain
open. End-to-end saves and the remaining parity checks are still release gates.

Editor implementation now lives under `comic/edit/`, using the typed catalog
form, personal form, entry draft and cover controls owned by Comics. Catalog
and collection targets share the dedicated typed dialog and the common shell
mechanics used by Games. The generic host, controller, duplicate text state and
superseded tab renderers were removed. Main and Details follow reference field
ownership; personal values stay outside catalog corrections. Cover and image
edits, custom values and unsaved-change detection are included in the commit
result. A dialog regression verifies Save/reload of reading, explicit grading
clears and preservation of unrelated personal fields and catalog identity.
Pixel layout, all pick lists and the remaining schema gaps are still open;
tab ordering alone is not a parity signoff.
Cover Date and Release Date now use Music's shared partial-date input in the
collection editor and typed Add/Edit field schemas. Missing year, month or day
remain missing through the typed model; clearing a date removes its stored
parts. Removed the Comics text-date/year controllers rather than maintaining
two editable date representations. Core contracts and Sync snapshot validation
are covered; end-to-end import and editor validation remain open.

### Browsing, details, dialogs and import/export

Compared on 2026-10-30 at 2560 × 1249 against the signed-in reference with
five comics, and a release Web build with the same five imported from CSV.

| Surface | Reference | Collectarr | State |
| --- | --- | --- | --- |
| Main menu | Collection: Add Comics from Core, Add Comics Manually, Manage Pick Lists, Manage Collections; Key Info: Update Key Info; Tools: Print to PDF, Statistics, Find Duplicates, Loan Manager, Missing Comics | Same sections and Maintenance/Import–Export items, with Add Comics Manually after Add Comics from Core and Missing Comics last in Tools (it was a toolbar action that did nothing); Calendar is added; CovrPrice is left out deliberately | Open: Update Key Info is only a selection action |
| Motion | Menu slides in 200 ms linear over a 200 ms fade; controls ease over 250 ms | Shared motion constants already match (Music pass) | Matches |
| Layout menu | Horizontal Split, Vertical Split, No Details | Same three, with a check on the active one | Matches |
| List view | Default columns Series, Issue (number and variant, "2A"), Variant Description, Publisher, Release Date, Storage Box, Format, Added Date; sorted by Series then Issue | Showed "Comic Series", "Comic Issue Nu…" headers over empty cells | Fixed: catalog, personal and loan columns in the reference chooser groups, the same defaults, sorted by Series then Issue |
| Series folders | Series folders are 41 px rows with the first issue's cover cropped from the top at 60 x 40 and "[All Comics]" with a folder icon; other folder fields are plain rows. Inside a series folder, Vertical Cards drop the series line (`card-details no-series`); Horizontal Cards keep it | Plain rows; cards repeated the series in every card | Fixed: series folders show the lowest-numbered issue's cover, and Vertical Cards in a series folder start at the cover (compared 2026-10-30). Series Group is an ordinary folder field in the reference, as here, and the details pane lists it right after Format |
| Details panel | Series title, Story Arc/Title subtitle, `#2A` badge; key line; cover beside variant description, Release, Cover, publisher logo, barcode, eBay link; the 30 px Collection Status icon and plot; then Creators, Characters, Details columns and Personal, Value rows | Was a generic hero with the series twice, `#2` without the variant, chips, Quick actions and a tab strip | Fixed: the reference order and columns, wrapping on narrow panels |
| Alphabet bar | Letters pick series, filed past a leading article ("The Art of Witch Hat Atelier" under A); hovered and chosen letters are 5 px pills, #464950 on hover | Letters picked titles; the hover was square | Fixed (2026-10-30): a Series/Title choice beside the bar, Series by default, as Music offers Artist/Composer/Title; the hover is rounded in every kind |
| Folder menu | 250 px #444 panel with a #666 rim; 30 px 14/400 rows, No Folders and Manage Favorites bold; #666 Favorites/Folders rules; Images, Main, Value, Edition, Creators & Characters and Personal holding 70 fields; an open category and the 20 px bar beside its rows #787878; #666 hover; the current folder only checked | Series and Publisher under Main, then Location and Condition; a 350 px menu with bold rows and a shaded current row | Fixed (2026-10-30): every reference folder field in its category and order, Location named Storage Box, Condition dropped (the reference groups by Grade); the same panel, rows and colours in every kind |
| Details status | The Collection Status icon beside the plot | A Read check there | Fixed (2026-10-30). Open: compare a comic with every field filled; the reference account has none, and filling one means saving there |
| Status marks | List rows: In Collection a bare #2AA4CC tick, white on the selected row; other statuses a 25 × 22 pill (4 px) in their colour with a white glyph. Vertical Cards (29 × 27), Covers and Shelves (25 × 23): bottom-left on the cover, In Collection a white tick outlined in #3B3B3B. Horizontal Cards: bottom-right 25 × 23 pills, In Collection blue too | List rows always showed a blue tick, whatever the status, so a changed status never showed; cards drew a 21 px square at the right; Covers and Shelves had no status | Fixed (2026-10-30), checked in every view with each status, selected and not. Collectarr keeps white glyphs where the reference's Covers CSS leaves Wish List and For Sale glyphs black |
| Status filter | The "All ▾" trigger stays lit (#464950, 5 px) while its menu is open | Lit only on hover | Fixed (2026-10-30) |
| Pick-list menus | 5 px above the rows and a 5 px `::after` below inside the #666 border: an empty list opens 12 px tall, one value 44 px | 5 px above only: an empty list opened 5 px tall | Fixed (2026-10-30) |
| Details panel data | Release and Cover dates, plot | Release showed "–" for every stored full date and the user's Plot never appeared | Fixed: a stored release date keeps its exact date; the panel shows the Plot |
| Edit dialog | Title "Absolute Batman #2A"; Issue No., Series Group; footer Collection Status, Index, Quantity, Storage Box | Was "Edit comic", Issue Number, Series group, Collection status, no Quantity | Fixed |
| Import sources | Text/CSV, Comic Collector XML, CLZ Comics Web XML, CovrPrice CSV, Comic Collector Live CSV, Comic Collector user-defined fields | Text/CSV, Comic Collector XML and CLZ Comics Web XML, in the reference's order and wording. The Web XML import was checked against a real 1041-comic export: credits and characters arrive only when edited in the reference, and Storage Box, links, custom images and loans are not imported yet | Comic Collector XML added from the Collectorz desktop shape (unverified against a real comics export). Open: Comic Collector Live CSV and Comic Collector user-defined fields need sample exports; CovrPrice is left out deliberately. Source logos stay generic icons: the reference's Comic Collector, CLZ and CCL logos are proprietary and not in Simple Icons |
| Import wording | "Import comics from CSV / TXT", "Import Comics", "Link Comics" | Said "issues" and "Link Issues" | Fixed |
| Import review | No preview: Import reads and imports the chosen file | Listed the parsed records for review before a second Import; the CSV importer copied the Series into an empty Title | Fixed: Import reads and imports in one step for every kind and source; an empty Title stays empty |
| Export to CSV / TXT | Which Comics, Visible Columns preset and Sort Order with Manage, CSV/TXT tabs, preview, Generate file | Columns fell back to Title, Creator / Series, Format, Status with empty values | Fixed: the List view columns, defaults first |
| Vertical Cards | 158 × 320 card on #383838: series centred above the cover in 13/700 #EBEBEB (two lines, 43 px), 148 × 207 cover inset 5 px, "#1" in 18/700 with the release date ("Oct 2014", "Nov 13, 2024") in 12/400 #9E9E9E at the right, then the grade's number in a 1 px #5EB1DE pill with 5 px corners; sorted by Series then Issue | Generic card: a small cover over the series name, no issue, date or grade. Comic covers used the landscape default ratio (1.53 read as width / height), so Covers tiles were 100 × 65. The library sorted by Release Date, descending, because it takes its defaults from the catalog registry | Fixed: a headlined card layout with the same rows and measurements, portrait 148 × 207 covers, and Series then Issue as the default sort. The Collection Status sits bottom-left as in the reference (2026-10-30). Open: a sort saved before this change stays |
| Main screen layout | Details panel right of the comics | Details below the comics (the only kind that defaulted to Horizontal Split) | Fixed: Vertical Split by default, 1060 px details as in Music. Open: the details cover is about 95 px wide against the reference's 165 px, the "Cover:" date and the publisher logo row are missing, and Creators, Characters and Details are not three side-by-side columns |
| Missing Comics | Full-window table: Filter Series, Show variants, Show "On Order", Show unreleased, Compact list, Sort issues Asc; columns Series, Owned, Missing, Missing Issues ("1 3–26" from Core's issue list for the series), Hide; Close and Download PDF | "Missing comics" dialog with chips (Compact/Verbose, Ascending/Descending, Variants, Hide on-order, Hide unreleased) and list tiles; it counts only catalog issues already in the library, so one owned issue per series reports nothing | Fixed: the same 30 px-inset table, filter bar, checkboxes, Asc/Desc pill, Hide links and Close/Download PDF footer, with "1 3–26" runs; the PDF prints the same table. Open, P1: it counts only catalog issues already in the library, so one owned issue per series reports nothing; read each series' issues from Core. Hidden series reappear when the dialog reopens |
| Export to XML | "Export to XML" confirm (Cancel/Export), "XML file generated successfully." with Download; a `<collectorz>` file of `<comic>` records with CLZ ids, display names and only user-edited credits (19 KB for five comics) | Same dialogs and wording. The file is Collectarr's own `<collectarr>` layout of typed fields: every stored catalog and personal value, nulls included (20 KB for the same five) | Open: decide whether to also write the CLZ layout; Import Comics reads CLZ's file |
| Link Comics | Your Comic / Core comics / Link table; "All comics are linked." when nothing is unlinked | Said "Core result" and "All entries are linked." | Fixed; rows for unlinked comics are not compared, since the reference account has none and unlinking there would change it |
| App switcher | Square white popover, 145 px, top edge on the header's bottom (y 37) in a 1 px rgba(0,0,0,.2) border, with a 22 × 11 pointer rising into the header under the icon; 36 px rows: 26 px app icon and "CLZ Comics" in Gilroy 16/700 #333 | Rounded, grey-edged, "Comics" in 14/700; then 9 px below the header with a black-outlined pointer | Fixed: same position, border and pointer; with local Gilroy the labels match in width (86 px) and weight |
| Toolbar hover | View, sort, layout and Edit/Share buttons highlight #464950 with a 4 px radius | Square highlight | Fixed: every toolbar hover is rounded 4 px |
| Kind accent and icon | Header and accents CSS #00AEE6 (Chrome paints it as #50AEE5 in screenshots); a speech-balloon app icon | Cyan #44BFE7, then the screenshot value #50AEE5, which painted lighter (#6BAEE4); a generic stacked-books icon | Fixed: CSS #00AEE6, read from computed styles rather than screenshot pixels, and an original speech-balloon icon |
| Add Comics tabs | Series (magnifier), Issue (#, "Enter series title and issue number..."), Barcode, NCBD, settings | Series (stacked layers), Title ("Search comics by series, issue, or exact title..."), Barcode, settings, cover scan | Fixed: Series and Issue named, iconed and hinted as in the reference; cover scan kept. Open: NCBD (new releases) needs a Core release calendar |
| Add Comics result toggles | Hide owned and Hide variants as 32 px struck-through icons, then Sort Issues and Grid/List View, all right-aligned in the 38 px "All (n)" row on #383838; #737373, 5 px corners when on | "Hide entry" and "Hide variants" chips, shown even before a search; a centred "4 Results" caption over a separate toggle bar | Fixed (2026-10-30): one row with the checkbox before "All (n)" (a dash while only some are checked), the hide toggles, Sort Issues and the two views |
| Add Comics Series tab | 1690 px dialog opening on Series: 460 px series list (95 × 60 cover, 15/700 title, count pill, publisher left and years right, opened row #5EB1DE) with "Not found?" under it, beside the series band and 163 × 299 #383838 blocks on the dialog grey: 153 × 234 cover, 22 px checkbox, "#1A" in a 2 px white 5 px-round box, cover month over year in 11 px, variant description in 12 px; the clicked block turns blue; list view 71 px rows with a 52 × 70 cover, "2024, Dec." and the variant in #888. Clicking a block raises a 730 px "Confirm your selection": 137 × 210 cover, series 24/700 with an 18/700 "#1A" box, publisher, variant, barcode, Release/Cover, price, key, then creators by role beside Characters | Opened on Issue in a 690 px dialog; issues as rows titled "Starfall Station #1 #1 #1"; a hovered opened series lost its blue; Not found sat under the issues; a full-width confirm sheet with "Issue identity" chips and generic "Publisher / Studio / Creator" and "No. / Vol." rows | Fixed (2026-10-30), checked live against a local Core with fictional series. Open: the count pill turns blue for series already in the collection; the reference shows a publisher logo where Collectarr writes the publisher; the 90 % translucent dialog body |

Inspect the signed-in `https://app.clz.com/comics` reference read-only. Close
editors and dialogs with Cancel. Record observed fields and remaining gaps
here; validate Collectarr saves and upgrades only in isolated test storage.
Keep the deliberate improvements above when matching the reference.

## Games comparison

Compared in the existing signed-in Chrome session at 1844 × 945. CLZ Games,
Hardware and Toys were inspected without saving; editors were closed with
Cancel. The existing Collectarr comparison origin was inspected without
saving. Changes were exercised in a separate release build on port 7359,
using a fictional game and its own browser storage. Different records and
cover images mean this is a workflow comparison, not a pixel-identical content
comparison. The earlier Music pass below remains valid for shared mechanics.

The chrome/theme follow-up used the existing Chrome session at 2560 × 1305
and a separate Collectarr release origin on port 47383 with the fictional
Games XML fixture. CLZ's account sidebar was opened without following Logout.
Light and Dark were previewed by temporarily changing only the loaded skin
and details stylesheet URLs, then restoring them; no account settings were
saved. The reference's named **Default** skin mixes dark toolbars with light
content; **Light** is a separate skin with pale toolbars. Earlier references
to that mixed skin as "light" below mean Default, not the named Light skin.
Account overview and sidebar were visually checked in both Collectarr themes;
signed-in logout and preservation of local collections use isolated widget
tests. Sign in and session restoration use the app logo, installed build
version and shared theme palette. Both themes and a narrow viewport were
visually checked; widget tests cover autofill fields, password visibility,
keyboard submission, loading/errors and returning to the selected library.
This does not claim a new full pass over every editor and view.

The route-by-route light pass (2026-10-23) compared CLZ's Default skin with
a Collectarr release build in its light theme, both at 2560 × 1305, with
the same three games. Routes: the Games list with folders and details,
main menu, Add, Edit (Main), Settings, Statistics, Find Duplicates, Loan
Manager, Manage Custom Fields and Cloud Sharing. CLZ was measured with
computed styles and by hovering each control (its stylesheets are
cross-origin); Collectarr from pixel samples. The CLZ editor and Add
dialog were closed with Cancel and ×.

### Compared surfaces

| Surface | CLZ Games | Collectarr / result |
| --- | --- | --- |
| Workspace | Platform folders; Platform and Title ordering; list, cards, covers and shelves | Games supplies these choices; folder and sort field inventories are recorded in the [Game ledger](architecture/catalog-item-field-ledgers/game.md). Not every sort/group combination was exercised with populated records |
| Add | Title, Barcode, Platform, settings, Add Manually; platform and region controls | Compared 1:1 on 2026-10-25 against an isolated local Core built from the sibling repository and seeded with fictional games (CLZ searched read-only, confirm sheet dismissed). See "Add Games layout" below |
| Main | Title, Sort Title, Platform, Release Date, Developer, Publisher, Series, Barcode, Format, Edition, Region, Audience Rating, Genre | The dedicated Games Main form contains these fields and the same two-column composition |
| Value | Completeness, Box, Manual, lockable Value, Condition, purchase facts, valuation chart, PriceCharting ID and Core Region (dropped, see Deliberate improvements) | Fields present. Fixed the packaging/completeness transition and Manual Add losing a chosen tier when it also applied a recorded value. Recorded snapshots only; no PriceCharting refresh. The lock makes Value read-only, as in CLZ; "Find sold listings on eBay" sits under Value and "Check historical values at PriceCharting.com" under the chart (compared 2026-10-25) |
| Personal | Owner, Storage Device/Slot, Notes, Completed/Date, My Rating, Tags | Fields present; does not establish every pick-list save path |
| Custom Fields | Empty guidance; separately configured definitions | Tab present; subtype-by-subtype editing still belongs to the shared unverified coverage |
| Covers | Front/Back, Find Online, Upload, Remove, Crop / Rotate | Compared side by side on 2026-10-25: 13 px bold labels at 70 % opacity, a 38 px #131313 toolbar with rounded top corners, 30 px actions with 14 px glyphs, #010101 dividers, a #464950 hover and 25 % disabled opacity, the cover across a #444 preview with a #666 border, and a 210 x 300 blank when there is none. Collectarr matches; native file selection was not exercised |
| My Images | Up to five additional images, caption and image type | Tab present; populated image management not compared live |
| Description / Links | Description editor, external links and YouTube trailers | Separate tabs and link/trailer tables present; playback not exercised |
| Details | Platform icon/name/year, series/title/status, companies, format/rating/genres, completeness/value, Description/Trailer/Personal | Fixed the missing platform icon. Existing metadata controls what is shown; empty fixture fields are not evidence of missing fields |
| Utility links | eBay sold-listings action | Fixed the shared inspector link inheriting the Games red accent; it now uses shared link blue |
| Save / Cancel | Reference inspected with Cancel only | Isolated Collectarr Manual Add saved a fictional PC game with a partial year, CIB, packaging and value; reference data and the original comparison library stayed untouched |

### Games inventory implementation and remaining differences

| Priority | Area | Confirmed requirement / remaining work |
| --- | --- | --- |
| Done | Hardware and Toys | Independent `game_hardware` / `game_toy` domain modules, repositories, editors and Core tables/contracts. Collections share the Games tab bar; type is immutable on rename and cross-kind moves are rejected. Creation offers a fixed collection type |
| Done | Hardware forms | Main: Title, Sort Title, Platform, Release Date, Barcode, Hardware Type, Series, Serial No. Value has the five Games completeness levels and packaging. Personal has Owner, Notes, My Rating, Tags, without completion/storage. Image uses Device Image / Box Image. Serial No. stays personal. An isolated controller was added with PC, a year-only date, CIB packaging and a serial number |
| Done | Toys forms | Main: Title, Sort Title, Barcode, Release Date, Series, Type, Subtype. Value offers Loose/New and Box, without Manual or Core Region. Personal has Owner, Notes, My Rating, Tags. Image uses Figure Image / Box Image. An isolated figure was added with a year-only date and New/Box; invalid completeness values are rejected |
| Done | Core type boundary | The sibling Core publishes four catalog kinds with independent Hardware/Toy schemas and routes. Ordered migration 2 adds the three Games inventory tables while preserving Music. Fresh install, upgrade, preservation and inventory search/read/correction flows passed on isolated PostgreSQL |
| Done | Hardware Add search | Title/Barcode, platform picker and Consoles/Controllers/Accessories filters reach Core before pagination; isolated browser search returned two Console results, then three Console/Controller results without caption overlap |
| Done | Inventory import/export | Guided CLZ Web XML import has separate Games, Hardware and Toys mappings and rejects mixed types. "Import a Text or CSV file" maps CLZ Games CSV/TXT exports (header labels auto-map; CLZ dates like "Nov 14, 2014", Yes/No flags, "A \| B" lists and prices are understood) for all three kinds. Native CSV preserves complete typed entries. Loaned To, Loan Date and Due Date create a loan for the imported copy (once per borrower and date), and any other column can be imported as a custom field named after its header (created as text when missing; importing again updates the value). CLZ's CSV has no image columns, so attachments only arrive through the XML cover URL; PriceCharting ID and Value Locked are not CSV columns either |
| Done | Add Games layout | CLZ's 1200 px dialog (10 px from the window top and bottom) lists a game once per platform: 52x70 cover, 15 px bold title, platform line, a 24 px edition count that turns blue when owned. Choosing it shows the title and platform beside the search row, the 65x32 region segments and 174x268 edition tiles (164x232 cover, edition title or barcode, region). An edition opens a 730x369 Confirm your selection sheet: 210 px cover, 24 px title, platform with the year, edition and region. Collectarr now matches; the grouping is a shared Add mechanic, the title/platform key, captions and preview belong to Games |
| Done | Add Games platform | CLZ shows the platform's icon and name inside the title field and opens Pick Platform: Favorites (All platforms, starred platforms), then generations newest first with radio, icon and star. Collectarr matches; favorites are kept on the device. The chosen platform used to join the search text, so Core found nothing; it now narrows the title results |
| Open P2 | Platform vocabulary | CLZ offers about 225 platforms with short names (Wii, PSP, SNES, Genesis / Mega Drive, Nintendo Switch 2); Collectarr's Pick Platform uses its 27 built-in names (Nintendo Wii, PlayStation Portable, ...). Renaming them changes stored entry values and needs an ordered migration, so it is an owner decision |
| Done | Add Games list extras | CLZ ends the results with "Not found? Add game manually." (Collectarr now does, opening Add Manually) and "CLZ Core for Games: Report missing game." (Collectarr proposes missing games from Add Manually's Propose to Core instead). Its dialog body is a translucent slate (rgba(93,98,108,.9)) with the rows on #383838, a #2D2D2D row hover, a 6 px #262626 divider and editions in #383838 boxes. Regions filter only the chosen game's editions, without a new search, and a region without editions is greyed out (#555, #888 text); Collectarr matches, using an opaque slate (compared 2026-10-25) |
| Done | PriceCharting | PriceCharting's terms bar using its Price Data in public software without written permission, and the site blocks automated access, so there is no refresh, API or scraping. CLZ links its values instead; Collectarr opens `pricecharting.com/game/<PriceCharting ID>` (the ID names the NTSC or PAL release) from the Value tab chart and the details pane's "Values by PriceCharting", and keeps recorded valuation snapshots (compared 2026-10-25) |
| Done | Loose packaging valuation | Box/Manual changes atomically recalculate an unlocked Loose value from recorded snapshots in the same currency; unavailable snapshots and locked values preserve the entered amount |
| Done | Collection icons | CLZ uses collection-type SVG assets: a controller, joystick and figure on a base. Collectarr uses original SVG drawings of these motifs in the tabs, collection menu and account overview; paths are declared in `AppIcons` and selected by each kind's identity. No CLZ artwork or Pro font is bundled |
| Done | Library switcher chrome | CLZ's button is Font Awesome Pro `grid-2`; Collectarr keeps its original four-square SVG in `AppIcons`. The popover stays white in both themes, with a pointer centered on the icon and its right side flush with the window edge. It expands symmetrically under the icon where space allows, accounting for Sync, Account and update actions. Kind tiles are 26 px, rows 36 px and labels 14 px. It lists each family once; selection, Escape and outside dismissal are checked, with geometry coverage at 390 and 1200 px |
| Done | Header account and sync | Added the right account sidebar with My Account and Logout (Sign in for a local-only session). Both sidebars share the same neutral palette color. The account page shows local totals, independent library counts, sync status, Activity and account/connection settings. Logout uses the existing session controller, keeps collections and clears the signed-in header label even when the last email remains remembered. Sync is hidden until loaded connection settings contain an endpoint and key, independently of catalog sign-in. Solid Sync (14 px) and Account (16 px) balance the custom switcher's 16 px painted glyph |
| Done | Header identity and platform | CLR is the chosen short name, with a 22 px, weight 800 title and an outlined WEB, DESKTOP or MOBILE suffix. Platform follows the build runtime, not viewport width: a browser on a phone remains WEB. CLZ Web has an outlined WEB suffix; [official mobile screenshots](https://clz.com/games/mobile) and the [mobile forum capture](https://club.clz.com/t/total-value-of-folder-view/10054) show CLZ Games without a MOBILE suffix. Its legacy Windows product is [Game Collector](https://help.clz.com/game), not a matching CLZ Games DESKTOP header. Collectarr deliberately labels all three runtimes consistently |
| Done | List canvas | CLZ's empty list area is gray in Dark and white with light content. Collectarr lists now use those surfaces instead of the near-black covers background; covers/cards retain their own background |
| Open P2 | Named Light skin | CLZ's separate Light skin also lightens toolbars, pane separators and collection strip. Collectarr's light mode still follows the mixed Default skin through `AppDarkChrome`; a full pale chrome variant remains absent |
| Done | Light list selection text | CLZ paints selected list text white on the shared blue row; Collectarr's selected cells now do too, in both themes (2026-10-23) |
| Done | List columns | CLZ's default Games list shows Platform, Title, Release Date, Publisher, Developer, Genre and Added Date; Collectarr's default list now matches, including Added Date (compared 2026-10-23) |
| Done | Column chooser and favorites | CLZ's column chooser groups Images, Main, Value, Edition, Personal and Loan, and its column favorites are My List View (the default list), My Find Duplicates (Title, Platform, Release Date, Index, Added Date) and My Print / Export (Platform, Title, Release Date, Publisher, Genre), the same on every Games-family tab. The menu lists Manage Favorites, then a Favorites heading with the active favorite checked; Collectarr now matches. Games now offers those columns under the same labels and groups (Value Loose/CiB/New/Graded, My Rating, Modified Date…; not Core Region, which is dropped) and the Loan group (Loaned To, Loan Date, Due Date of the open loan), sorting through the matching reference sorts; Hardware and Toys get the same favorites limited to their columns. The generic Essential/Collection/Reference presets referenced no Games column (compared 2026-10-23) |
| Open P3 | Column chooser gaps | Games has no Back Cover image, Description, eBay, Core GameID/MediaID or Toy NFCID columns. Collectarr keeps its Status, Wishlist, Franchise and Box/Manual Only value columns |
| Done | Hardware list and details | CLZ's list leads with the platform icon and Platform before Title, and its details show the platform icon with "Platform (year)"; Hardware now matches. Toys keep Title, Release Date and Series and open on Series folders because they have no platform (deliberate; compared 2026-10-23 with a fictional Toy and Hardware in an isolated origin) |
| Done | CLZ CSV export | CLZ's Export to CSV / TXT writes the labels of a chosen column set (any of the Main, Value, Hardware, Toy, Edition, Personal and Loan columns) as the header row, unescaped HTML in Description and dates as "Nov 14, 2014"; Collectarr maps columns by label instead of expecting a fixed layout (checked 2026-10-23 on the Games and Toys collections through the export preview; Hardware was empty, so its columns are assumed identical) |
| Done | Hardware and Toys details typography | Series 15 px bold, title 24 px/27 px lines, platform and year 15 px bold with the platform icon, description and links 14 px, matching CLZ's computed styles on the Toys detail panel (Gilroy 14 px body, 14 px bold labels, 18 px section titles) |
| Done | Horizontal cards | Footer reserves separate space for the platform, value and status; compact-width geometry checks prevent overlap |
| Done | Hardware/Toy folders | Tags retain separate folders even when a tag contains commas; Added/Modified folders group by calendar day, and valuation folders use the Value category |
| Done | List dates and headers | CLZ lists dates as "Nov 14, 2014" and leaves the icon column header empty; Games, Hardware and Toys lists now use the date setting, icon columns have no clipped "C…"/"P…" header, and the default Games list has no cover column (compared 2026-10-23 with the same three games imported into an isolated origin) |
| Done | Details Format | CLZ shows the Format ("Steam Download") above the genres; imported Formats now appear there too |
| Done | Main menu and switcher | Games menus said "Link Albums" and the library switcher listed "Games" three times; they now read "Link Games" and list Games once |
| Done | Series, Completed, purchase dates | The Series field read nothing; "Completion" held the Collection Status (now labelled so, with a separate Completed field); patched purchase dates now update the Purchase Date folders |
| Done | Statistics | CLZ has one tab per Games-family collection. Games: summary, Games by Platform stacked by completeness, Most valuable / Most recent, Value per Platform with its total, Release Year, Genre, Completeness, Value by Completeness and Games Completed. Hardware: the same without Value per Platform, Genre and Completed. Toys: summary by type, the two lists, Toys by Type pie and by completeness, Release Year and Value by Completeness. Collectarr now draws the same tabs and sections (compared 2026-10-23); the Hardware list is titled "Most valuable hardware" where CLZ reuses "Most valuable games", and values use the Currency display setting |
| Done | Pre-fill Settings | CLZ offers Completeness with Box/Manual, Location, Owner, Purchase Date/Store/Price, Quantity and Tags, without Condition. Games, Hardware and Toys now show the same fields, each with its own completeness tiers (compared 2026-10-23); a pre-fill never sets the Value |
| Open P2 | Pick lists | CLZ: Audience Rating, Condition, Developer, Format, Genre, Image Type, Loaned To, Location, Owner, Platform, Publisher, Purchase Store, Region, Series, Storage Device, Sub Type, Tag. The unused Age Rating and "Edition / Format" lists were removed (2026-10-23). Collectarr still adds Sold To (its own Sold fields) and has no Image Type list for My Images |
| Done | Pick list Manage | CLZ's Select Genres switches to Manage Genres in place: the same rows gain pencils and a remove column, with Back and Merge Mode below. Collectarr builds Manage behind the list and swaps once it has loaded, so no spinner shows (compared 2026-10-25) |
| Done | Pick list values | CLZ keeps a value only while an entry uses it and seeds nothing: on the reference account Condition and Region were empty and Platform listed the three platforms in use; its Manage has no New. Games, Hardware and Toys lists no longer seed values (Toy Type stays fixed), and opening a selector, a standalone Manage or a dropdown deletes the kind's stored values no entry uses, keeping fixed values and the field's selection (compared 2026-10-25). Music still seeds some lists; recheck against CLZ Music before removing them |
| Done | No results and sorting favorites | Filters or a search without results show CLZ's blue "No results found..." banner (#5EB1DE, 26 px bold heading, white Reset all filters button) instead of a centred message. Games and Hardware start sorted by Platform then Title, CLZ's one built-in sorting favorite (checked in the menu); Manage Sorting Favorites uses CLZ's rows with a dot on the active favorite and ASC/DESC badges. Clicking the open collection tab does nothing. The Collection Status filter reads each entry's status (For Sale and On Order included; In Collection keeps For Sale copies) and folder counts follow it: CLZ's In Collection shows [All Games] 8 / PC 2 where All shows 9 / 3 (compared 2026-10-26) |
| Done | Import progress and success | Inspected 2026-10-25 by importing two fictional rows into the reference account (then removed). CLZ shows an "Import / Importing your games..." window whose bar fills, with "Finishing.." under it, then replaces the duplicate warning with a green "Import Successful" alert: "You have N unlinked Games, find matches and link your Games" and a Link Games button. Its CSV import defaults to Comma. Collectarr now matches; its bar fills over matching, preparing and writing rows |
| Done | Main menu | CLZ lists Add Games, Add Hardware and Add Toys-to-Life from Core on every Games tab; Collectarr now lists one Add from Core entry per family kind, each opening that library (Toys keep the Collectarr name) |
| Done | Settings | CLZ's Details Panel has "Show trailer videos"; Collectarr now offers it for libraries with trailers (Games, Hardware, Toys) and hides the Trailer section when it is off. Trailers stay a list of links rather than embedded players |
| Open P3 | Details and value | CLZ shows "Find sold listings on eBay" under the value box; Collectarr shows "Search eBay" at the end of the panel. The value itself now reads like CLZ's ("$ 17.58") |
| Done | Editor and import form | Rechecked 2026-10-25: Edition takes the same share of its row as in CLZ (about 59 %), the Collection Status row lines up with the fields above, and the CSV import radios and checkbox use shared blue. The Collection Status menu now has CLZ's dimmed 13 px bold group headings, 24 px indented 32 px rows, a rounded, shadowed #444 menu with a #666 rim, and the same #666 shade for the current and the hovered status, with a pointer cursor. Single-value dropdowns (Platform, Series, Location) use the same menu: plain 32 px rows attached to the field, and an empty menu for an empty list; Location has no "No location" row. An emptied Quantity saves 0, the empty Custom Fields tab uses CLZ's wording, and no control spreads a press ripple |
| Done | Light list colors | CLZ Default: white headings, #EEE when sorted or hovered, #DDD column rules, #F9F9F9 first-row stripes with white second rows, #F3F3F3 row hover. Collectarr's light sorted headings were black on #262626 (unreadable), rules dark, stripes inverted and hover white; now matched (2026-10-23) |
| Done | Light folder panel and search | CLZ keeps the folder search strip dark (#383838, #4A4A4A top rule) with a white field; folder rows hover #DDD, counts sit on #DDD badges, rows are split by #E4E4E4; the toolbar search is white. Collectarr matched the light content instead; now matched (2026-10-23). Folder rows also fade their colors over 0.25 s, as CLZ's do |
| Done | Motion | CLZ slides its menu in over 0.2 s linear while the 50 % black overlay fades, fades modals over 0.2 s, and fades toolbar hover over 0.25 s; list rows change instantly. Collectarr's timings match; its dialog motion stays the deliberate fade-and-slide (2026-10-23) |
| Done | Settings after a reload | Reloading /settings?kind=game showed Music's options ("Auto Cap album titles", album confirmations, Music's layout) because Appearance read the last library chosen in the session; it now uses the route's library (2026-10-23) |
| Done | Dark chrome in the light skin | CLZ Default keeps the main menu, page headers (Back and a 16 px bold title) and the Find Duplicates option bar on #383838. Collectarr's light theme painted them light with a 14 px title; they now stay dark, the account sidebar with them (2026-10-23) |
| Done | List alignment | CLZ right-aligns dates and their headings. Numeric headings now follow their right-aligned cells, and Games, Hardware and Toys dates are right-aligned (2026-10-23) |
| Done | Details toolbar and Completed | The details-toolbar eBay logo painted #333 on #383838 in light mode; it is white again. The Personal table marks Completed with a cross or check, as CLZ does, instead of an empty value (2026-10-23) |
| Done | Date and number formats | CLZ offers 17 date display formats (day/month names, with or without leading zeros, two- or four-digit years, ISO), 6 number formats and editing orders labelled with an example; Collectarr had 6 date and 4 number formats and bare editing orders. Collectarr now lists CLZ's formats in its order (recorded 2026-10-26), keeps its dotted 31.08.2026 after them, and shows a partial date with the same pattern minus the day |
| Done | Currency and Currency display | CLZ lists 20 currencies; each offers its symbol, a regional symbol where one exists (US$, CA$, JP ¥, HU Ft…) and its code (USD; HUF Ft for the currencies whose regional choice is a country prefix), and a new currency starts on the regional choice, or the symbol when there is none. Prices read as the choice, a space and the amount in lists, details and editor fields. Recorded for every currency on 2026-10-26. Collectarr now matches, keeping RON, TRY and MXN after CLZ's list and using ISO INR where CLZ shows IND; CLZ's "HR ♢" entry is left out |
| Done | Settings dropdowns | CLZ's dark settings selects are 34 px tall with a 9x6 white arrow 4 px inside the border; Collectarr's were 30 px with a smaller grey arrow 14 px in. Settings selects now match (measured on screenshots, 2026-10-26); their open list stays Collectarr's 25 px rows, as CLZ uses the browser's native list |
| Done | Tab reorder under zoom | At any zoom other than 100 % a dragged editor or collection tab drifted away from the pointer and dropped in the wrong slot, because Flutter's reorderable overlay mixes zoomed and unzoomed coordinates (flutter/flutter#195303). Both strips now drag in their own coordinates through a shared row (2026-10-26) |
| Done | Description formatting | CLZ's Description tab is a plain textarea holding light HTML (<b>, <br/>) that the details pane renders formatted. Collectarr kept the same editor but showed the markup as text; the details pane now renders b/strong, i/em, u, br, p, ul/ol lists of li items (indented 40 px per level with the bullet or number before them, as a browser does) and common entities, drops other tags and leaves untagged text as written (2026-10-26) |
| Done | Tags selector | The Personal tab's Tags opened a generic options list while Genre opened the pick list selector; both editors' and Add's Tags now use the pick list selector, as CLZ does for every list field (2026-10-26) |
| Done | Choice button groups | CLZ's Completeness, Completed and Core Region groups have 4 px outer corners, #444 segments in a #666 frame, #999 text and separators, and a #666 selected segment with white text (dark skin, computed styles 2026-10-26). Collectarr used 2 px corners and #555 frames on the field colour; now matched |
| Done | Personal Completed | The Games editor's Completed No/Yes kept its old highlight after a click because the Personal tab's kind fields were not rebuilt when the draft changed; they now rebuild, as the Value tab's Completeness already did (2026-10-26) |
| Done | Editor tab order | Previous/Next in the Games, Hardware and Toys editors painted the default tab order for a frame before the saved one; they now start in the saved order like the other editors (2026-10-26) |
| Done | Light Settings | CLZ frames settings boxes in white with a #DDD border, 15 px apart in columns 30 px apart, with white selects, #DDD/#333 block buttons, Sorting last in the left column and a hint under eBay "Automatic". Collectarr used borderless #F9F9F9 boxes 37 px apart, #EEE selects, a #666 button and Sorting at the top right; now matched (2026-10-23). Legends keep the shared blue (#5EB1DE) where CLZ Default uses #0082A6 |
| Open P3 | List rows | CLZ top-aligns cell text with 2 px padding (and its row controls); Collectarr centers cells vertically, which shows on wrapped rows. CLZ's default widths here were Platform 230, Title 300, Publisher/Developer 150, Genre 225 and dates 110 px; Collectarr starts narrower (Platform 120, Title 260, others 140). Not established whether these CLZ widths are defaults or resized |
| Open P3 | Light Settings extras | CLZ offers Default, Light, Dark and Blue skins and Light, Dark and Blue details templates; Collectarr offers System, Light and Dark and "Follow application". CLZ's Main Screen Layout select shows an icon |
| Open P3 | Statistics | CLZ's collection tabs are bordered boxes; the bar charts show y-axis counts and vertical grid lines; card titles use #0082A6. Collectarr uses plain tabs, no y-axis labels, horizontal grid lines and lighter blue titles. CLZ ordered equal platform bars PS5, PS4, PC; Collectarr PC, PS5, PS4 |
| Open P3 | Loan Manager | CLZ draws the loan toolbar on a #EEE band inside a bordered box and its tabs as bordered boxes; Collectarr's toolbar band is white and its tabs plain. Collectarr adds "Lend / return by barcode" (deliberate) |

### Control and icon follow-up

Compared the signed-in CLZ Games Default skin and an isolated Collectarr
release build on port 7367 at 2560 × 1305. The latter imported the fictional
three-game XML fixture into new browser storage. CLZ editors were closed with
Cancel. Reference values below come from computed styles after hover settled;
Collectarr uses screenshots, widget geometry and source inspection. Both app
themes were checked for Layout, including the compact vertical inspector and
the labelled horizontal inspector. This is a focused continuation, not a new
full audit of every view, dialog or editor tab.

| Status | Control / state | Comparison and result |
| --- | --- | --- |
| Done | Layout glyphs | CLZ uses a window with its band rotated right/bottom and overlapping windows for No Details. Replaced Collectarr's Material sidebar/splitscreen/hidden-eye glyphs with the corresponding FOSS Font Awesome window glyphs; the trigger follows the selected layout |
| Done | Layout trigger | Compact inspector trigger is 46 × 30 px, matching CLZ, with a dropdown arrow in both compact and labelled forms and a visible #464950 hover on dark chrome. Widget tests exercise hover/cursor and every layout choice in both themes; the release build was exercised through horizontal, hidden and vertical layouts |
| Done | Layout menu | Horizontal Split → Vertical Split → No Details, as in CLZ; 30 px rows. Reserved space for the selected check so the longest label cannot collide with it |
| Done | Utility selection | View's active item and Layout's selected check use shared utility blue instead of the library accent. This follows the project's color rule; CLZ's View menu has no colored active-item marker |
| Done | Portrait cover geometry | The standard profile passed width/height (0.7 for Games, Hardware and Toys) as a height multiplier, producing landscape tiles. It now uses the reciprocal, so 140 px width yields 200 px height; the same profile sizes Covers, vertical cards, shelves and image fallbacks. Covers/cards contain the complete artwork instead of cropping it to the fallback ratio; horizontal cards already contained it and Flow's foreground preserves it |
| Done | Light vertical cards | Non-selected titles and metadata were #EBEBEB/#9E9E9E on white, nearly invisible. Light cards now use the light palette's primary/muted text; selected cards retain white text. A regression checks title contrast against the card background |
| Done | List text weight | CLZ's computed cell style is Gilroy 14 px/400. Collectarr keeps 14 px and uses the bundled Bold face for denser list rows; user-supplied local faces retain their calibrated 400 slot. This is an optical adjustment, not a claim that Plus Jakarta Sans and Gilroy have identical outlines |
| Checked / improved | Games XML export | The isolated Games collection completed Export → generation → Download and produced a 9 KB XML with three full entries. No total no-op was reproduced there. Empty exports now explain that there is nothing to export, and dismissing the Download prompt does not save a file. Isolated widget flows save and parse Games, Hardware and Toys exports into temporary files through a mocked save selector; the actual failing installation remains unverified |
| Open P2 | Light popup menus | CLZ Default shows a white View/Layout popup with #333 text and #DDD row hover. Collectarr carries the dark chrome theme into these popups: #444 with white text. Fix the popup palette independently of the dark trigger bar, then check the sort/column/status menus too |
| Open P3 | Hover shape | CLZ toolbar hover rectangles have square corners. Shared Collectarr toolbar hover surfaces still have a 5 px radius; inspector actions have a 4 px radius |
| Open P3 | Inspector action density | CLZ's narrow inspector hides Edit/Share/Layout labels and uses 30 × 30 px Edit/Share/More buttons. Collectarr keeps Edit/Share labels at widths where the reference already hides them; align the breakpoint and padding with equivalent pane widths |
| Open P3 | Editor tab glyphs | Main, Value, Personal, Covers and My Images use the same glyph families. Custom Fields differs (CLZ pen-field, Collectarr pen-square); Description is regular in CLZ and solid in Collectarr; Links is an earth glyph in CLZ and chain links in Collectarr. Use FOSS glyphs or an independently drawn field icon; do not copy the proprietary pen-field asset |
| Open P3 | Editor density | CLZ tabs are 32 px, inputs paint 34 px and footer buttons are 32 px; its Main dialog is 1200 px wide and starts 10 px down. Collectarr's screenshot has the same width/top offset and painted input height, but Main tab geometry reports 33 px including its border. Flutter's input accessibility boxes are larger than the painted outlines; do not use their 40 px bounds as the input height |
| Reference checked | Workspace toolbar glyphs and sizes | CLZ uses bars for List, sort-alpha-down for Sorting, columns for Columns, pencil/share/vertical-ellipsis in the inspector, and an open folder plus angle-down for grouping. View trigger 46 × 30 px, sort/column action halves 30 × 30 px, separate favorites arrows 18 × 30 px. Collectarr uses the corresponding families; the covers/shelves glyphs remain independently drawn SVGs |
| Preserved | Intentional icon differences | Platform category glyphs, the app identity, kind icons in headers, Flow Carousel and the extra search/tools controls remain deliberate additions. Different cover content and persisted pane widths are not treated as icon or spacing regressions |

Validation: release Web build, focused analysis and the standard correctness
run passed for the control pass. The follow-up after removing TV/Manga passed
1,275 tests in an isolated checkout with
`dart run tool/run_tests.dart --kinds=all`; the former inactive
kind setup failures no longer apply. All five graphical views were exercised
in the isolated release origin. Reference comparisons use loaded images, not
the reference's temporary 0.7-ratio loading placeholders; its three loaded
cover images rendered at 175 px high with their own natural aspect ratios.

### Platform artwork licensing

Keep the current FOSS device/category glyphs and platform names. The
[Font Awesome Free license](https://github.com/FortAwesome/Font-Awesome/blob/7.x/LICENSE.txt)
permits its font/SVG distribution under OFL/CC BY with attribution, but brand
marks remain their owners' trademarks. Its presence in an icon font is not
blanket permission from the platform owner. The
[Simple Icons disclaimer](https://github.com/simple-icons/simple-icons/blob/develop/DISCLAIMER.md)
also distinguishes the project's CC0 license from individual artwork licenses,
trademarks and brand guidelines.

[Microsoft's app trademark guidance](https://learn.microsoft.com/en-us/windows/apps/publish/partner-center/trademark-and-copyright-protection)
explicitly requires a formal license for its graphical marks in apps; plain
platform names are a different use. PlayStation's
[trademark notice](https://www.playstation.com/en-us/legal/copyright-and-trademark-notice/)
identifies the PlayStation/PS4/PS5 marks but grants no general redistribution
permission. These sources do not establish clearance for a complete platform
logo pack. Before adding a mark, document both the artwork license/source and
the brand owner's applicable terms or permission. Do not extract CLZ's pack.

### Deliberate Games behavior

- Platform icons are CC0 Simple Icons logos where one exists (PlayStation with its generation, PSP, Vita, Steam, Steam Deck, Sega, Atari, Apple, Linux, Android) and Collectarr glyphs otherwise (Xbox, Nintendo, PC). CLZ's own platform images are never copied; see `assets/LOGOS.md`.
- Games, Hardware and Toys expose only their own fields. CLZ also shows generic Games columns and Toy folders across inventory types; Collectarr keeps Toy classification exclusively in Toys.
- The next local schema is 3, combining Games tracking, list-valued tags and dropping the removed TV and Manga tables in one upgrade from released schema 2. Unreleased intermediate schemas are not migration baselines.

- Without a recorded amount for a newly chosen completeness tier, preserve the
  manually entered value. A locked value also survives tier changes. Choosing
  a tier still updates packaging: N/A/Loose clear Box and Manual;
  CIB/New/Graded select both. The reference transitions were checked in its
  unsaved editor, then cancelled.
- Hardware/Toys must not be inferred from collection names: a renamed
  collection retains its concrete type, and moves must preserve that type.

## Fixed in the 2026-10-15/16 Music passes

| Surface | Problem | Fix |
| --- | --- | --- |
| Folder panel | A fresh library grouped by **Has Back** because fallbacks took the first group; Music declares Artist | Fallbacks resolve the kind's declared default group |
| Cover placeholders | Coloured generated cover with the title and, before that, titles split mid-word | A dark tile with the kind's Font Awesome icon (compact disc, book, film, TV, gamepad, open book, dice), like the reference's per-kind placeholder; comics keep their #number badge |
| Collection tab reorder | The tabs flashed their old order until the save returned | The dropped order is kept until the saved order arrives. The drag look (tilt, shadow, sliding neighbours) stays Flutter's, a deliberate choice; the reference's jQuery sortable has no tilt and no sliding |
| Collections button | Filled surface, 14 px bright icon, no check mark | Transparent, #383838 on hover, 16 px icon at 75 %, check mark on the active collection |
| Folder and text sorting | Folders sorted by raw text: capitals first, Raft 10 before Raft 2, accented names after Z, and Sort Names ignored | Case- and accent-insensitive natural order for folders and Music's Title, Artist, Format and Genre sorts. Folders keep their real names but follow Sort Names, as in the reference ("Akira Yamaoka" sits with the Ys as "Yamaoka, Akira"): the pick list's, then for Music artists and credits the credit's or the article rule; Settings can ignore them |
| Item Spacing edges | Horizontal Cards grew its outer margin with the slider | A fixed 10 px margin in every grid view; the slider only sets the gaps between items |
| Untitled albums | Add Manually and the editor refused an empty title | Music allows an empty title in both; other kinds still require one |
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
| Link Albums | Full-width page with a button row, plain badges and a small cover | 960 px column with the tinted header box: striped progress bar attached to Find matches, unlinked count pill, Match-score labels and the bulk Link button; 92 px covers in the table |
| Horizontal cards | Fixed 100 px minimum height left empty bands above and below small covers | Height is the cover plus 4 px padding at any size |
| Add tabs | Unselected tabs darker (#505050) and Add Manually lit on hover; no Catalog No. tab; no scan button in the Barcode field | All tabs #666 with unselected at 50 % opacity, no Add Manually hover, Catalog No. tab (Music) and the main search bar's scan button in Barcode |
| Core settings | Only the flat schema fields | Rows come from Core's Catalog Item contract with Core's titles: every field plus Discs, Credits, Artist credits and External links, with each disc's Tracks and Credits indented under Discs. Kinds without a Core catalog show a message |
| Dialog motion | Fade only | Fade over 150 ms while sliding from a quarter of the dialog's height over 300 ms; reversed on close |
| Selection under the pointer | A card or list row clicked while hovered turned black until the pointer left it | Turns the selection blue at once; pixel regression test for cards and rows |
| Artist pick list | Closed after each pick (single select) with round radios; + , × and search icons brighter than the reference | Multi-select “Select Artists” with square check boxes and one Save; + is white at 70 %, × and search are grey, at 16 px |

## Open differences

Verified in the 2026-10-15 pass unless marked *carried over*; carried-over
items come from earlier audits and must be re-checked before closing.

### Functionality

| Priority | Area | CLZ | Collectarr |
| --- | --- | --- | --- |
| P2 | Light skin coverage | Default mixes dark toolbars with light content; the separately named Light skin also lightens the chrome (see Games follow-up) | Collectarr follows Default through `AppDarkChrome`. Populated Games details, account overview, sidebar and switcher have been checked with light content; a full pale chrome variant and a complete light pass over editors/cards remain open |
| P2 | Imports | Also Music Label, OrangeCD, CDpedia | Not offered: no public schema or sample export exists (see [import/export](import-export.md)); CATraxx XML is imported |

CLZ mixed Default skin, previously labelled light, computed styles at 1844 × 945: top bar in the kind accent
(Games `#E23149`); toolbars and pane headers `#383838`; pane draggers
`#262626`; bottom collection tabs `#272323` with inactive tabs `#131313` at
75 % white and the active tab in the accent; light browsing canvas `#F6F6F6` (the list's empty area is white in the Games follow-up); folder
panel `#F9F9F9` with `#333` text; cards white with `#333` text; selected card
and folder `#5EB1DE` with white text; details panel white at 90 % over the
backdrop, title and section headings `#0082A6` (24 px and 18 px bold), field
labels `#777` 15 px bold upper case, values `#333` 15 px; value badge `#0082A6`
over a `#B1D8EA` completeness row; list value pill `#2AA4CC`.

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

Music and Games Add results and the confirm sheet were checked in widget
renders against CLZ measurements; Comics Add was compared live with a local Core.
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
