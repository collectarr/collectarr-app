# CLZ parity

Collectarr aims to be an improved, fully FOSS CLZ Music, Games and Comics: familiar
workflows and density, a stricter data model, and no proprietary code, fonts or
assets. CLZ is a reference only.

This file lists only what still differs from CLZ, what has not been compared
yet, and the deliberate differences to keep. Delete an item once it matches;
do not record finished work here. The changelog and git history hold that.

Last full Music pass: 2026-10-15/16, 1844 × 945, signed-in CLZ Music Web in
Opera and a release Web build with the same albums imported.

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

For Android, use the same physical device for both apps and keep its display
size, density and font settings unchanged. Build Collectarr from a temporary
source copy with a separate application ID and app label, so its database and
preferences cannot touch the installed app's data. Keep screenshots, UI dumps
and build logs in temporary storage. Open CLZ forms without entering or saving
data, then leave with Back or Cancel. An empty CLZ collection establishes only
empty-state, navigation and form layout behavior; populated lists and item
details still need comparison.

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
| Fonts | Desktop/web UI Gilroy; Android UI system sans-serif; comic slab labels use League Spartan and Open Sans on web and Android | Bundled OFL Plus Jakarta Sans for UI text and the matching OFL slab fonts on all platforms; a user-supplied local UI font can be loaded |
| Sort titles | Filled in by CLZ Core | Core derives them for new Music items and corrected titles; the app applies the same rule to local Add, Edit and imports |
| Header account | Always signed in to CLZ | Shows "account's music" only while signed in; personal sync uses a separate endpoint and key, and its header action stays hidden until these are configured |
| My Account | Blue account sidebar and an external account portal | Neutral sidebar matching the main navigation; a local overview across libraries, sync status, activity and account settings. Logout clears the session while keeping local collections |
| Links | The eBay link beside the cover is white | Every link uses the shared link blue |
| List header | No sort indicator | Shared-blue caret and priority number on sorted columns |
| Chrome icons | Dialog and editor titles only | Kind icons in the top bar and dialog headers, kept at the owner's request; edit dialogs show the shared edit pen |
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
| Sort Names | Shown only on the person lists (Artist, Composer, Conductor, Musician, Engineer, Producer, Songwriter, Signee) and Box Set; the other lists store one but hide it, so "The End Records" stays under T | Every pick list except Comics Publisher, Imprint, Format, Country, Language and Age shows its Sort Name, fills it from the Name as it is typed (the article rule, as for Sort Title), and every pick-list folder is ordered by it |
| Storage | Comics keeps a flat Storage Box pick list per app | Every kind files items in one shared Location tree (rooms, shelves, boxes) managed in Settings; Comics calls it Location |

### Deliberate Games behavior

- Platform icons are CC0 Simple Icons logos where one exists (PlayStation with its generation, PSP, Vita, Steam, Steam Deck, Sega, Atari, Apple, Linux, Android) and Collectarr glyphs otherwise (Xbox, Nintendo, PC). Users can replace them with their own SVG or raster files in Settings > Appearance > Platform icons. CLZ's own platform images are never copied; see `assets/LOGOS.md`.
- Games, Hardware and Toys expose only their own fields. CLZ also shows generic Games columns and Toy folders across inventory types; Collectarr keeps Toy classification exclusively in Toys.
- Without a recorded amount for a newly chosen completeness tier, preserve the
  manually entered value. A locked value also survives tier changes. Choosing
  a tier still updates packaging: N/A/Loose clear Box and Manual;
  CIB/New/Graded select both.
- Hardware/Toys must not be inferred from collection names: a renamed
  collection retains its concrete type, and moves must preserve that type.
- Platform category glyphs, the app identity, kind icons in headers, Flow
  Carousel and the extra search/tools controls are deliberate additions.
  Different cover content and persisted pane widths are not regressions.

### Deliberate Comics behavior

- Status marks keep white glyphs where the reference's Covers CSS leaves Wish
  List and For Sale glyphs black.
- Import source logos stay generic icons: the reference's Comic Collector, CLZ
  and CCL logos are proprietary and not in Simple Icons. CovrPrice import is
  left out (see Deliberate improvements).
- The details panel shows a publisher logo only for the publishers whose logo
  is public domain on Wikimedia Commons (`assets/LOGOS.md`); the rest show
  their name. CLZ's own publisher images are never copied.
- Custom Label images come only from the user's files. The reference's list
  is CGC's and CBCS's custom slab labels (about 175, such as "Spawn #1") with
  each label's artwork, which belongs to the grading companies and the
  characters' owners; CGC's Terms of Use allow personal, non-commercial use
  only and forbid copying from its site. Collectarr ships no label images and
  never downloads them: the user loads an image for a label, or many named
  after their labels, and it shows on the slab. The slab's label colours and
  layout are drawn, not copied.

### Platform artwork licensing

For optional local artwork, run
`dart run tool/download_platform_logos.dart <output folder>`, then load the
files from Settings > Appearance > Platform icons. The helper skips files
unless Commons marks them public domain, excludes Windows and Xbox, and
never opens a collection database. Keep downloaded artwork outside the
repository or in the ignored `local-assets/` directory. Public-domain
copyright status does not remove trademark restrictions.

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

## Open differences

### Shared

| Priority | Area | Difference |
| --- | --- | --- |
| P2 | Light skin coverage | CLZ: Default mixes dark toolbars with light content; the separately named Light skin also lightens the chrome (see Games follow-up). Collectarr: Collectarr follows Default through `AppDarkChrome`. Populated Games details, account overview, sidebar and switcher have been checked with light content; a full pale chrome variant and a complete light pass over editors/cards remain open |
| P2 | Named Light skin | CLZ's separate Light skin also lightens toolbars, pane separators and collection strip. Collectarr's light mode still follows the mixed Default skin through `AppDarkChrome`; a full pale chrome variant remains absent |
| P2 | Light popup menus | CLZ Default shows a white View/Layout popup with #333 text and #DDD row hover. Collectarr carries the dark chrome theme into these popups: #444 with white text. Fix the popup palette independently of the dark trigger bar, then check the sort/column/status menus too |
| P2 | Imports | CLZ: Also Music Label, OrangeCD, CDpedia. Collectarr: Not offered: no public schema or sample export exists (see [import/export](import-export.md)); CATraxx XML is imported |
| P3 | Hover shape | CLZ toolbar hover rectangles have square corners. Shared Collectarr toolbar hover surfaces still have a 5 px radius; inspector actions have a 4 px radius |
| P3 | Inspector action density | CLZ's narrow inspector hides Edit/Share/Layout labels and uses 30 × 30 px Edit/Share/More buttons. Collectarr keeps Edit/Share labels at widths where the reference already hides them; align the breakpoint and padding with equivalent pane widths |
| P3 | Editor tab glyphs | Main, Value, Personal, Covers and My Images use the same glyph families. Custom Fields differs (CLZ pen-field, Collectarr pen-square). Use FOSS glyphs or an independently drawn field icon; do not copy the proprietary pen-field asset |
| P3 | Editor density | CLZ tabs are 32 px, inputs paint 34 px and footer buttons are 32 px; its Main dialog is 1200 px wide and starts 10 px down. Collectarr's screenshot has the same width/top offset and painted input height, but Main tab geometry reports 33 px including its border. Flutter's input accessibility boxes are larger than the painted outlines; do not use their 40 px bounds as the input height |
| P3 | List rows | CLZ top-aligns cell text with 2 px padding (and its row controls); Collectarr centers cells vertically, which shows on wrapped rows. CLZ's default widths here were Platform 230, Title 300, Publisher/Developer 150, Genre 225 and dates 110 px; Collectarr starts narrower (Platform 120, Title 260, others 140). Not established whether these CLZ widths are defaults or resized |
| P3 | Light Settings extras | CLZ offers Default, Light, Dark and Blue skins and Light, Dark and Blue details templates; Collectarr offers System, Light and Dark and "Follow application". CLZ's Main Screen Layout select shows an icon |
| P3 | Statistics | CLZ's collection tabs are bordered boxes; the bar charts show y-axis counts and vertical grid lines; card titles use #0082A6. Collectarr uses plain tabs, no y-axis labels, horizontal grid lines and lighter blue titles. CLZ ordered equal platform bars PS5, PS4, PC; Collectarr PC, PS5, PS4 |
| P3 | Loan Manager | CLZ draws the loan toolbar on a #EEE band inside a bordered box and its tabs as bordered boxes; Collectarr's toolbar band is white and its tabs plain. Collectarr adds "Lend / return by barcode" (deliberate) |

CLZ mixed Default skin, previously labelled light, computed styles at 1844 × 945: top bar in the kind accent
(Games `#E23149`); toolbars and pane headers `#383838`; pane draggers
`#262626`; bottom collection tabs `#272323` with inactive tabs `#131313` at
75 % white and the active tab in the accent; light browsing canvas `#F6F6F6` (the list's empty area is white in the Games follow-up); folder
panel `#F9F9F9` with `#333` text; cards white with `#333` text; selected card
and folder `#5EB1DE` with white text; details panel white at 90 % over the
backdrop, title and section headings `#0082A6` (24 px and 18 px bold), field
labels `#777` 15 px bold upper case, values `#333` 15 px; value badge `#0082A6`
over a `#B1D8EA` completeness row; list value pill `#2AA4CC`.

Equal CSS and Flutter weights do not paint identically, and the bundled face is
not Gilroy. Compare text with a user-supplied local font before changing
weights (see [local font loading](architecture/local-font-loading.md)).

### Comics

| Status | Workflow | Reference and validation needed |
| --- | --- | --- |
| Inspected; gaps open | Library and series browsing | Main menu, layout menu and details panel inspected; List columns, sorts and the details panel layout remain open (see below) |
| Inspected; gaps open | Add Comics | Compared live against a seeded local Core on 2026-10-30/31: Series tab with suggestions while typing, the owned-series count, issue grid and list, sort, check-all, the closing "Not found?" block, the confirm sheet and Add/Update from Core Settings match. Open: NCBD (see Open differences) and the publisher logo |
| Inspected; gaps open | Issue editor | Eleven tabs inspected; pick-list contents, save round-trips and visual comparison remain open |
| Inspected; gaps open | Personal collection | Reading, grading, signatures, purchase, value and storage fields inspected; collection actions and loans remain open |
| Pending inspection | Series completeness | Missing issues, variants, collection boundaries and available actions |
| Partially inspected | Bulk and portability | Import sources and Export to CSV/TXT/XML inspected; export columns, XML import and multi-selection remain open |
| Pending inspection | Visual and accessibility checks | Default/dark appearance, narrow windows, keyboard traversal, empty states and invalid input |

| Priority | Area | Difference |
| --- | --- | --- |
| P1 | Comics NCBD | CLZ: Add Comics has an NCBD tab: a week navigator ("This week", "Week 44 \| Oct 25 - Oct 31", previous/next), All / #1's / My Series / Pull List filters, a chart and sort toggle, "Check out all releases in one list" with the week's count, and one card per issue (publisher, series, "#25" badge, "121 variants"). Collectarr: No NCBD tab. Blocked on data, not UI: Core holds no release calendar, so a week's releases would come back nearly empty. It needs a source of upcoming issues with exact release dates fed into Core, ideally an automated, licence-compatible import or scraper run on a schedule; then a Core week query (issues released in the seven days from a date, by series and issue) and the tab in Add. Pull List also needs a per-user series watch list |
| P1 | Missing Comics | It counts only catalog issues already in the library, so one owned issue per series reports nothing; read each series' issues from Core. Hidden series reappear when the dialog reopens |
| P2 | Main screen layout | The details cover is about 95 px wide against the reference's 165 px, the "Cover:" date is missing, and Creators, Characters and Details are not three side-by-side columns |
| P2 | Add Comics Series tab | The reference shows a publisher logo where Collectarr writes the publisher, and a 90 % translucent dialog body |
| P2 | Value tab | CLZ: Signed by is a list of people (Name and Sort Name) added with a + beside the label and Key Category is a multi-value tag field with a list button. Collectarr: Signed by is one text box and Key Category a single pick list; both need a schema migration |
| P3 | Main menu | The reference's Key Info > Update Key Info is only a selection action in Collectarr |
| P3 | Import sources | Comic Collector Live CSV and Comic Collector user-defined fields need sample exports; Comic Collector XML is built from the Collectorz desktop shape and unverified against a real comics export |
| P3 | Export to XML | Decide whether to also write the CLZ layout; Import Comics reads CLZ's file |
| P3 | Vertical Cards | A sort saved before Series then Issue became the default stays |
| P3 | Editor | Full visual comparison of the eleven tabs and the Key selector, every pick list, complete browser save/reload, XML and image import, and end-to-end import and editor validation remain release gates |

### Android Comics

Reference: CLZ Comics 11.3.3 on a Motorola Edge 70, portrait 1220 × 2712 at
480 dpi (about 407 dp wide), with an empty collection. Collectarr was checked
both as installed 1.5.0 and as the current branch's debug build in the separate
`com.example.collectarr_app.qolreview` package, labelled Collectarr Review.
The differences below are present in the branch build. Core search results,
series issues and the selection preview were also inspected read-only in CLZ.
No reference records were created or saved; populated collection density and
runtime font overrides outside the inspected layouts remain unverified. The
installed CLZ 11.3.3 APK embeds static League Spartan ExtraBold (800) and Open
Sans Regular (400). Its compiled card/list layouts assign Spartan to the slab
grade and Open Sans to the grading-company text; the other inspected layouts
do not refer to either bundled face. Collectarr sources the OFL variable
families from [Google Fonts League Spartan](https://github.com/google/fonts/tree/main/ofl/leaguespartan)
and [Open Sans](https://github.com/google/fonts/tree/main/ofl/opensans), with
their licences in `assets/fonts`, and selects weights 800 and 400 respectively.
The CLZ APK's font files were inspected in temporary storage only.
CLZ web's inspected `skins_dark.css` likewise assigns League Spartan to
`.slab .grade span` and Open Sans to `.slab .grading-company`; its general
`body.app` style uses Gilroy. A Chromium preview of Collectarr web loaded both
bundled slab fonts successfully.

| Priority | Area | Difference |
| --- | --- | --- |
| P2 | Add Comics remaining parity | NCBD still depends on a release-calendar source in Core (see Comics NCBD). CLZ has a favourite-series star in the selected-series header; Collectarr needs a series watch-list model before matching it. Validate camera/barcode flows on-device and compare populated results against equivalent Core data, including long issue/variant labels, larger system text, loading and error states |
| P2 | Scanner presentation | The library header camera opens the shared live-camera sheet with manual barcode entry. CLZ overlays the camera directly on the library with scanning corners. Align the native camera presentation while preserving manual entry; real barcode decoding still needs a physical-code check |
| P3 | Library surfaces and empty state | Collectarr retains the desktop canvas gradient and a filled blue onboarding card; CLZ uses a flat dark canvas with centred teal text. Compare the light skin before adapting native surfaces |
| P2 | Populated folder navigation | Compare CLZ's favourite presets and multi-folder bucket navigation against Collectarr with populated collections; the separate bucket chooser has not yet been checked against equivalent data |
| P3 | Android typography | Compare Android system sans-serif text metrics and density with Collectarr's Plus Jakarta Sans on equivalent populated screens; runtime font changes outside the inspected layouts remain unverified |
| P3 | Mobile sort options | Compare the available sort rows, their order and direction defaults with CLZ for every kind using equivalent populated collections; Collectarr also offers Advanced sorting for multi-field rules |
| P2 | Comics mobile Edit controls | Collectarr groups editable year/month/day parts and a calendar in one outlined date control to preserve partial dates; CLZ shows one formatted date string. Compare a populated CLZ Edit record and align the date text, barcode camera, picker and segmented controls without losing partial dates or existing values |
| P3 | Comics mobile Value and Key | Compare populated Value, Key and Images against CLZ Edit. CLZ's CovrPrice and eBay actions depend on external services, while Collectarr currently shows only the editable value; Signed By and Key Category still use single-value controls (see Comics Value differences) |

Still to compare: populated cards/list/covers, series folders and counts, item
details and previous/next navigation, selection and bulk actions, every editor
tab with the keyboard, populated search parity against the same Core data,
camera/barcode flows, landscape, gesture navigation, larger system text and light appearance.

### Games

| Priority | Area | Difference |
| --- | --- | --- |
| P3 | Add Games platform filter | CLZ shows the chosen platform's logo and short name beside the title field (Windows logo, "PC") and remembers it; Collectarr shows "All" with no logo. The CLZ region bar (All, US, EU, AU, JP, Other) is dimmed until a game is chosen; Collectarr's is lit from the start |
| P2 | Platform vocabulary | CLZ offers about 225 platforms with short names (Wii, PSP, SNES, Genesis / Mega Drive, Nintendo Switch 2); Collectarr's Pick Platform uses its 27 built-in names (Nintendo Wii, PlayStation Portable, ...). Renaming them changes stored entry values and needs an ordered migration, so it is an owner decision |
| P2 | Pick lists | CLZ: Audience Rating, Condition, Developer, Format, Genre, Image Type, Loaned To, Location, Owner, Platform, Publisher, Purchase Store, Region, Series, Storage Device, Sub Type, Tag. The unused Age Rating and "Edition / Format" lists were removed (2026-10-23). Collectarr still adds Sold To (its own Sold fields) and has no Image Type list for My Images |
| P3 | Column chooser gaps | Games has no Back Cover image, Description, eBay, Core GameID/MediaID or Toy NFCID columns. Collectarr keeps its Status, Wishlist, Franchise and Box/Manual Only value columns |
| P3 | Details and value | CLZ shows "Find sold listings on eBay" under the value box; Collectarr shows "Search eBay" at the end of the panel. The value itself now reads like CLZ's ("$ 17.58") |

## Not yet compared live

Transfer Field Data, Re-Assign Index, every custom-field subtype editor and
validation state, populated My Images, the Manage Collections/Pick Lists save
flows and Windows native rendering. Pick Lists opens the Artist list directly
instead of an empty selector. Opening a menu does not establish its save
behavior.

- Games: every sort/group combination with populated records, every Personal
  pick-list save path, native file selection in Covers, trailer playback.
- Comics: a comic with every field filled in the details panel, rows for
  unlinked comics in Link Comics, and Submit to Core's wording. The reference
  account has none of these, and producing them means saving there.
- The header account label appears only while signed in to Sync, so it is
  covered by tests rather than the signed-out comparison build.
