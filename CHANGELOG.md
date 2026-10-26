# Changelog

## Unreleased

### ✨ Features
- Choosing an edition in Add Games opens a compact Confirm your selection sheet with the cover, platform and year, edition and region, as in CLZ.
- Add Games picks the platform from inside the title field through a Pick Platform list grouped by console generation, with starred favorites at the top.
- Add Games lists each game once per platform with its edition count and shows the chosen game's editions as covers beside the list on CLZ's slate background, with region segments above them that filter the editions in place and grey out regions without editions, and a "Not found? Add game manually." row after the results, as in CLZ.
- Game covers can be found online (Find Online) from the Covers tab.
- The Games Value tab links "Find sold listings on eBay" under the value and "Check historical values at PriceCharting.com" under the chart, and "Values by PriceCharting" in the details pane opens the game's PriceCharting page, as in CLZ.
- Game, Hardware and Toy descriptions show their bold, italic and underlined text and line breaks in the details pane, as in CLZ, instead of raw tags.

### 🐛 Fixes
- Saving an entry with an empty title no longer breaks the library; no field is required, as in CLZ.
- Location in Pre-fill Settings uses the same boxed field and list button as the editor.
- The item count reads "1 game" (or "1 album") instead of "1 games".
- Choosing a platform in Add Games narrows the title results instead of returning none.
- The Add dialog fills the window height, 10 px from the top and bottom, instead of stopping at 1200 px.
- Opening Manage from a pick list selector switches straight to the managed list instead of flashing a spinner.
- The Collection Status menu in the editor matches CLZ: dimmed bold group headings, indented statuses, the current and the hovered status shaded alike, and rounded corners with a shadow.
- Hovering buttons in the Group By menu or a searchable dropdown no longer throws a layout error.
- Previous and Next in every editor, Games included, and the first editor opened after a launch, keep a reordered tab strip in its saved order instead of flashing the default one.
- Choices in the Hardware and Toys Value tabs now show the selected option.
- The app icon, taskbar logo and browser tab icon have transparent rounded corners instead of white ones.
- The header brand reads CLR instead of CARR.
- New entries in every library, from Add and imports, take the next free Index, and importing a file without an Index keeps the one already assigned.
- Index and Quantity accept only whole numbers, drop leading zeros and show up/down arrows on hover for quick increments.
- The pick list selector no longer tints selected rows with the library accent, ticks selections with CLZ's white checkbox, draws its column headers and New/Manage buttons bold with Manage in grey, points the Name caret down for A to Z, and keeps its list on screen when returning from Manage.
- The date calendar opens and closes instantly, without a fade or scale animation.
- Dropdown arrows in editor fields use the muted text colour.
- The editor's Collection Status row has no rules above and below it.
- The focused editor field has a thicker blue outline.
- Pick list select buttons in fields use the same icon as Manage Pick Lists in the sidebar groups.
- Text typed into editor fields is a little heavier, closer to the reference.
- Inactive editor tabs and their icons are dimmer than the selected tab instead of pure white.
- The editor's Covers tab looks like CLZ's: dimmed panel labels, a black toolbar with rounded top corners, 14 px actions split by dark dividers with a grey hover, a bordered preview showing the cover across its full width, and a cover-sized placeholder when there is none.
- Imports show a progress window while a file is read, fill its bar as records are imported, and report success in an "Import Successful" box on the page, with a Link button for entries without a catalog match, as in CLZ.
- The CSV / TXT import starts with the Comma field delimiter, as in CLZ.
- Buttons, menus and lists no longer spread a ripple when pressed, as in CLZ, and editor menu options show the pointer cursor.
- Single-value dropdowns in the editor (Platform, Series, Location…) list plain 32 px rows without radio buttons, shade the current and hovered value, attach to the field and open empty when the list has no values, as in CLZ.
- Location no longer offers a "No location" choice in the editor, Add and Pre-fill Settings; clearing the field leaves it empty, as in CLZ.
- Saving an editor or Add with an empty Quantity stores 0 instead of asking for a value, and a quantity of 0 is kept by every library and import, as in CLZ.
- The editor's empty Custom Fields tab reads as in CLZ and points to Customization > Manage Custom Fields in the main menu.
- Settings no longer has a Libraries tab; Manage Pick Lists and the keyboard shortcuts remain in the main menu and Tools.
- The "×" that closes dialogs is centred in its header in the browser too, not a few pixels low.
- Games, Hardware and Toys pick lists (Platform, Genre, Format, Region, Condition, Audience Rating) start empty and list only values your entries use, as in CLZ; Toy Type keeps its fixed choices.
- Pick list values that no entry uses any more are removed automatically when a list is opened, as in CLZ.
- A locked Games value can no longer be typed over until it is unlocked, as in CLZ.
- The Change Columns button in List view sits as close to its separator as the view and sort buttons, without extra space on its left.
- Games and Hardware start sorted by Platform then Title, with that sort as the checked built-in sorting favorite, as in CLZ.
- Manage Sorting Favorites looks like CLZ's: a heading with a blue + button, bordered rows with a drag handle, a dot on the favorite in use, ASC/DESC badges and Edit, sized to its rows.
- Clicking the open collection's own tab in the bottom bar does nothing, instead of flickering the selection and resetting folders and filters, as in CLZ.
- The alphabet bar hides its options button and divider when there is only one field to choose.
- The Tools menu no longer repeats Keyboard Shortcuts, Print / PDF report and Export to CSV / TXT, which are in the main menu, and drops Missing covers, Missing metadata (use folders instead), Download all covers and Tag values.
- A search or filter without results shows CLZ's blue "No results found..." banner with a Reset all filters button.
- The Collection Status filter follows each entry's status, so For Sale and On Order work and a changed status moves the entry at once, and folder counts count only the entries the filter shows, as in CLZ.
- Flow Carousel cards keep the library's cover shape, so covers no longer get black bars above and below.
- Shelves books keep the cover shape too, instead of being a few pixels taller and showing thin bars above and below the cover.
- Choosing Yes or No for Completed in the Games editor's Personal tab now shows the selected option.
- Choice buttons such as Completeness and Completed have CLZ's rounder corners and, in the dark theme, its grey segments with a lighter selected one.
- Tags in the editor and in Add open the same pick list selector as Genre, with New and Manage.
- Dragging editor tabs or collection tabs while the app is zoomed keeps the tab under the pointer and drops it where it shows.
- Settings dropdowns are as tall as CLZ's and show its bold white arrow at the right edge.
- Currency display offers the chosen currency's own options, as in CLZ (for example $, US$ or USD; kr. or DKK), and prices everywhere read like CLZ's, such as "US$ 12.50".

### ♻️ Refactors
- Games no longer have a Core Region field or column: Collectarr never fetches PriceCharting prices, and the PriceCharting ID already names the NTSC or PAL release. Upgrading removes stored Core Region values.

### 📚 Docs
- The CLZ comparison records the Add Games layout, platform picker, editor rechecks and pick list Manage switch, the import progress and success alert, the Covers tab and editor dropdowns, and the platform names still open.

## 1.3.0 - 2026-10-24

### ✨ Features
- **Games, Hardware & Toys Libraries**: Dedicated inventories, editors, Core catalog search, and fixed-type collections for video games, hardware/consoles, and toys/collectibles.
- **CLZ Import & Export**: Guided CLZ XML import, lossless CSV/TXT mapping with custom fields, automatic loan tracking, and XML export.
- **Rich Game Metadata & Media**: Platform logos (PlayStation generations, Steam, Sega, etc.), region filters, completion & storage tracking, front/back covers, and trailer integration.
- **Reference-Grade Workspaces**: Portrait cover cards, customizable folder groups & favorites, right-aligned dates, and dedicated column presets (My List View, My Find Duplicates, My Print/Export).
- **Statistics & Pre-fill**: Collection statistics with platform, value, and completion charts, plus reference Pre-fill Settings for fast cataloging.
- **Shell & Account Overview**: Compact CARR header with platform badges (Web/Desktop/Mobile) and account drawer showing local library summaries and sync status.

### 🐛 Fixes
- Editor tab glyphs keep their natural width with the label 9 px after them, as in the reference.
- Toolbar split buttons join both halves without a divider, as in the reference.
- Manage Favorites in the columns menu opens the column favorites directly, and the column chooser no longer has its own gear button, as in the reference.
- Dialog and panel headers close with the reference's plain "×" instead of an icon.
- Header buttons are 36 px circles with a light hover, as in the reference.
- Loan Manager joins its active tab to a grey toolbar band and shows an empty list as a framed row, as in the reference.
- Statistics and Loan Manager tabs are folder tabs with grey inactive tabs in the light theme, statistics boxes are framed, item titles use the reference blue, and charts show a value axis with grid lines.
- The CSV import page is readable in the light theme, with shared-blue choices and visible source icons.
- Editor Description and Links tabs use the reference's file and globe glyphs.
- Editors line the Collection Status row up with the form above, without extra space after the last section.
- The details toolbar shows Edit, Share and Layout labels only when the details panel is wide, as in the reference.
- Toolbar and details-toolbar hover highlights have square corners, as in the reference.
- In the light theme toolbar menus open as white popups with dark text and grey hover, as in the reference.
- Wrapped list rows start their text and row controls at the top, as the reference does.
- Collection status icons are Font Awesome Free glyphs instead of artwork copied from CLZ.
- The eBay button and import sources use licensed logos instead of artwork copied from CLZ or without a known license.
- Cover views show the complete image, and unselected vertical cards keep readable text in the light theme.
- List rows use a fuller bundled font while preserving the weight of user-supplied local fonts.
- XML export explains when a library is empty and only saves after Download is confirmed.
- View and Layout controls use shared-blue selection, matching window icons, and a visible Layout hover and dropdown arrow at compact sizes.
- Folder rows fade their hover and selection colors as the reference does.
- The selected list row shows its text in white in the light theme too.
- Settings opened or reloaded from a link show the options of that link's library instead of Music's.
- Light Settings boxes, selects and buttons use the reference's white and grey, with its box spacing, Sorting placement and eBay "Automatic" hint.
- Find Duplicates shows its options on the reference's dark bar with a white select.
- Page headers (Back and the page title) use the reference's dark bar and 16 px bold title in both themes.
- In the light theme the main menu and account sidebar stay dark, as in the reference.
- List headings of numeric columns align right over their values.
- In the light theme the folder search sits in a dark strip, search fields are white, and folder hover and counts use the reference grey.
- Light lists match the reference: white headings with readable sorted columns, light column rules, first-row stripes and a grey row hover.
- The eBay button on the details toolbar stays visible in the light theme.
- Ctrl + mouse wheel zooms the web app in and out again, as it does on desktop.
- The column favorites menu lists the favorites under a Favorites heading, as the reference does.
- The header hides Sync until a personal sync service is configured and balances Sync and Account icons with the library switcher.
- Sign in uses the app logo, current light/dark themes and the installed version, with a layout that fits narrow screens and the on-screen keyboard.
- Library and appearance sliders keep the Windows accessibility tree valid during startup and navigation, preserving keyboard and screen-reader controls.
- The light theme applies at startup and uses consistent content areas, editor fields, toolbars and collection tabs.
- The library switcher reaches the right edge with its arrow aligned to the icon in both themes.
- List views use the reference's gray canvas in dark mode and white canvas in light mode instead of the cover-grid background.
- Pick-list fields preserve spaces when typing a new value.
- Horizontal cards keep labels and value/status badges readable at compact widths and in the light theme.
- The sorting favorites button remains readable in the light theme.
- List headers of narrow icon columns stay empty instead of showing clipped labels.

### ♻️ Refactors
- Standalone TV and Manga kinds are removed; future television and manga support belongs in Movies and Comics.
- Personal tags are stored as lists so tags can contain commas; existing entries and pending Sync changes upgrade together in one migration from the released schema.
- Manual Add footers, Add choice menus and front/back image controls share behavior across libraries.
- Statistics charts, legends and ranked lists are shared components, ready for libraries other than Music.

### 📚 Docs
- The README presents Collectarr as a Music and Games app, with Hardware and Toys libraries and CLZ Games import.
- The living CLZ comparison records Games, Hardware and Toys workflows, deliberate differences and remaining gaps, including control sizes, hover states, editor icons, Statistics, Pre-fill, pick lists and menus.

### 🧰 CI & Build
- The library column manager test exercises column favorites directly, keeping test suites in sync with the column dialog.
- The library add integration test looks up the app shell element directly, keeping native flows passing with the CARR header.

## 1.2.0 - 2026-10-18

### ✨ Features
- The search box accepts regular expressions after "matches:" (for example `matches: ^the\s`), ignoring letter case, as the old Music Collector did; matching tracks are highlighted, and an invalid expression outlines the box in red with the reason on hover.
- Automatic backups: the desktop and mobile apps copy the whole database once a day at startup and before every restore or clear, keep the copies for a chosen period (one week to forever), and restore any of them from Settings > Data.
- Folders are ordered by Sort Name while still showing the real name, so an artist named "Akira Yamaoka" with Sort Name "Yamaoka, Akira" sits among the Ys; a Sort Name set in Manage Pick Lists orders any folder, and the Settings option to ignore sort names turns this off.
- Manage Pick Lists fills a value's Sort Name from its Name as you type ("The End Records" gives "End Records, The"), as the album editor does for Sort Title, until you type a Sort Name of your own.
- Settings has an Updates tab to check for, download and install new versions on the Stable, Beta or Nightly channel; when a newer version is found at startup, a download button appears in the header right of Sync.
- Add Albums has a Catalog No. tab that searches Core by catalog number, and the Barcode field has the scan button from the main search bar.
- Add/Update from Core Settings is a dialog with Add from Core and Update from Core tabs: choose per non-personal field whether Add downloads it and whether Update skips, fills or replaces it.

### 🐛 Fixes
- Sidebar entries now show the hand cursor on hover.
- Collection tabs switch colour instantly and no longer show a press ripple, hover highlight or drag shadow.
- On Windows the library and its backups now live in `%APPDATA%\Collectarr` instead of a doubled `Collectarr\Collectarr` folder. Existing data is not moved: before starting this version, close Collectarr and move `collectarr-library.sqlite` (with any `-wal` and `-shm` files) and the `backups` folder from `%APPDATA%\Collectarr\Collectarr` up into `%APPDATA%\Collectarr`.
- Dragging a collection in Manage Collections no longer shows a shadow around the row.
- Collection tabs keep their new order while a move is being saved instead of flashing the old one.
- The collections button is transparent with a dark hover and a lighter 16 px icon, and the active collection has a check mark in the menu.
- Folders and Music's Title, Artist, Format and Genre sorts ignore letter case and accents, as the reference does, and put numbers in natural order (Raft 2 before Raft 10, where the reference puts Raft 10 first).
- Horizontal Cards no longer overflow at small cover sizes, and the Cover Size slider keeps enlarging them across its whole range instead of stopping partway.
- Item Spacing in Horizontal Cards only changes the gap between cards, like Covers; the margin to the window edges stays fixed.
- The cover size and spacing sliders can be grabbed anywhere on the round handle, including at the minimum and maximum, instead of only at its centre.
- A manual album can be added and edited with an empty title, as in the reference.
- The Covers tab of the album editor shows the same compact disc icon when the front or back cover is missing.
- Entries without a cover show a dark tile with their kind's icon (compact disc for albums, book, film, TV, gamepad, dice) instead of a coloured title card.
- Artist, Signed By and other name lists pick several names in one dialog with square check boxes and a Save button, instead of closing after each pick; the + , × and search icons use the reference's softer colours.
- Previous/Next in the edit dialog swaps to the next item in place, with no flash of the page behind it.
- Link Albums follows the reference: a centered 960 px page with a tinted header (progress bar attached to Find matches, unlinked count, match-score counts, bulk link button) and 92 px covers in the table.
- Drawer sections open and close over 350 ms with the reference's ease curve, and drawer headers have no hover highlight and no click ripple.
- Dialogs slide down a quarter of their height while fading in and slide back up while fading out, like the reference's modals.
- A card or list row clicked with the mouse still over it turns blue at once instead of black until the pointer leaves.
- Cards show each entry's Collection Status (In Collection, For Sale, On Wish List, On Order, Sold, Not in Collection) with its icon, colour and tooltip, and follow changes made in the edit dialog, instead of always showing In Collection.
- The sort fields in the CSV/TXT and PDF export settings show ASC for ascending fields instead of always DESC.
- Add/Update from Core Settings lists every field and list Core describes for the kind, under the names Core gives them, with Tracks and disc Credits indented under Discs; kinds Core has no catalog for say so instead of showing an empty table.
- Horizontal cards are exactly as tall as their cover plus 4 px padding at any cover size, with no empty bands above or below.
- Add Albums tabs share one colour with unselected ones at half opacity, and Add Manually has no hover highlight, as in the reference.
- Add Albums no longer has Advanced fields, and a search shows a spinner over "Searching..." like the reference.
- XML, CSV/TXT and PDF exports show a progress window while generating; Download file sits under Generate at the same width, and the PDF page no longer has a Print / Open button.
- Covers and vertical cards drop the extra border, padding and heavy shadow and use the reference's thin black shadow.
- Horizontal cards keep the cover's aspect ratio and fill the card height like the reference, with no empty bands around the image.
- Field lists in Re-Assign Index Values, Sort and the column chooser follow the reference: outlined and filled checkboxes, a tri-state checkbox per group, groups that collapse with an animation, an ASC/DESC switch that slides, a smaller remove cross, a larger search icon with a white caret and a white clear disc.
- The navigation drawer uses regular entries under bold section titles instead of heavy entries under thin titles.
- Bold text with local Gilroy is as heavy as in the reference instead of about 19 % lighter; restart the app after updating.
- Editor field names are white at 70% (about #C4C4C4) and fieldset titles are grey, as in the reference.
- The selection toolbar is the shared blue with icon-only Cancel, Edit and Remove, a divider before the more menu (Print to PDF moved into it) and an "N of M" counter, as in the reference.
- Loan opens the Loan Album page under the Loan Manager header, for one item or a selection, instead of a dialog.
- Field lists in Re-Assign Index Values, Sort and column dialogs have no click ripple.
- Close buttons in dialog headers and panels have no hover, press or ripple effect, as in the reference.
- The folder list on the left no longer shows a click ripple, as in the reference.
- Keyboard Shortcuts shows each combination as key caps with arrow glyphs, and its Close button matches the other dialog buttons.
- Settings tabs (Appearance, Connection and the rest) are centered.
- Selects in Settings and Manage Pick Lists open a compact #444 list with 25 px rows like the reference.
- Grey buttons (Cancel, Previous, Next) lighten slightly on hover like the reference.
- The Alphabet Options button sits behind a thin divider after the letters, as in the reference.
- A clicked cover in Covers and Shelves fills with the selection blue instead of staying black until another item is selected.
- The Settings button is gone from the top right; Settings stays in the navigation drawer, as in the reference.
- Edit and the other toolbar buttons react as soon as you press them, even if the mouse moves afterwards.
- Clicking a cover, card or list row with the mouse selects it on press, not on release, so it no longer looks unselected while the button is held.
- Horizontal and vertical cards follow the reference: link-blue titles, regular details, plain length under the track count, a collection status chip, an inset cover and muted artist and year.
- Editor field labels are 13 px bold like the reference instead of about 10 px.
- Covers, cards, Card Flow and List use the #131313 background in dark mode; Shelves keeps the shelf style's own background.

### ♻️ Refactors
- Kinds now declare their own extra Add search tab, such as Music's Catalog No., instead of the shared Add dialog knowing about catalog numbers.

### 🧰 CI & Build
- Code generation and the architecture checks use analyzer 14.5 with build_runner 2.16.2.
- The generated macOS plugin registrant no longer shows up as modified on Windows.
- The generated kind registries and field-entry list no longer show up as modified on Windows.
- The generated Drift database code and the Linux and Windows plugin registrants no longer show up as modified on Windows.
- `dart run tool/ci_check.dart` runs the same checks as CI before a push, stage by stage.
- CI runs checks, unit tests and the Linux integration flows as parallel jobs, so one run shows every failure.
- A release is one run of the Release workflow: it picks the version from the commits, moves these changelog entries under it, tags, publishes the notes and builds the downloads.
- Pull requests with several commits are merged with "Rebase and merge", so every change reaches main and the release notes.
- The architecture check no longer reports the edit dialog's cover slot as a new field leak after the edit widgets were split into separate files.
- Test fixtures keep LF line endings on Windows checkouts, so the import tests pass there as on CI.
- `tool/update_core_contracts.ps1` syncs the v1 catalog contracts Core publishes instead of failing on missing v2 files.

### 🧪 Tests
- The Loan Album page test runs inside a provider scope, as the app does, so the generated cover renders there.

## 1.1.0 - 2026-10-16

### ✨ Features
- Settings gains Sorting (sort titles and sort names), Auto Capitalization (when adding from Core, as you type, method and exceptions) and Localization (currency, currency display, number format, date display and entry order).
- Albums get automatic sort titles ("Wall, The") on Add, Edit and import; Core derives them for new catalog items.
- Libraries open on the In Collection status filter, and the header shows the signed-in Sync account.
- Music sorting adds Has Back, Has Front, Format and Genre, and the list can show a Back Cover column.
- Borrowers have a sort name, email and address; Loan opens a lend form with a loaner picker and a due date two weeks out.
- Music adds a Core ID column and sort; Settings can open Add/Update from Core settings.
- Music imports CATraxx XML exports with discs, vinyl sides, tracks, credits, ratings and purchase details.
- Export to XML asks for confirmation like the reference and saves complete albums, from the menu and from a selection.
- The search field, its suggestions (cover, “Artist - Title”, year, View all results) and the search scope menu follow the reference; the barcode button looks like a scanner.
- Random pick scrolls the chosen album into view and only picks among the albums shown.
- The Add dialog follows the reference: one column with Artist & Title and Barcode tabs, Add Manually, compact results with checkboxes and a “Confirm your selection” sheet.

### 🐛 Fixes
- Albums without covers no longer show another entry's Core cover in Covers/Shelves.
- The details backdrop no longer flashes while resizing, and details covers keep their size.
- Release Year exports, statistics and date sorting now work for year-only dates.
- Find Duplicates, Loan Manager, the toolbar count and filter pills, the Personal tab and the navigation drawer follow the reference layout.
- Music folders now default to Artist instead of the first available group (Has Back).
- “Wrap column content” wraps long list values instead of cutting them after one line.
- The details panel keeps the last selected album after returning from a tool page and otherwise shows the first album.
- Generated cover placeholders no longer split words or show “front cover” in the title.
- Album totals in the details header use hours (1:07:22), matching the Length column.
- The Played History date field no longer clips the year and month.
- Utility actions and links on Custom Fields, Find Duplicates and Statistics use the shared blue.
- Cancelling an untouched album editor no longer asks to discard changes.
- Wrapped Artist and Title cells in the list grow their rows instead of being cut off.
- The details track list, field tables, header and section columns, the album editor's fields and the Add button follow the reference sizes and colours.
- App chrome uses the flat kind accent instead of a gradient; kind icons stay.
- Settings > Appearance is laid out like the reference page, and Settings opens on it.
- Statistics, the alphabet bar, cover columns, the editor rating and Played History, and the details Personal section follow the reference; a "Report data error" link opens the editor for Core albums.
- The folder panel keeps its width when the window narrows, menus open instantly, and a click beside the navigation drawer closes it.
- Date pickers, the Loan Manager, My Images and Statistics prices follow the reference; icons are Font Awesome throughout.
- Synced pick-list values keep their sort name and hidden state.
- The Covers and Shelves icons in the View menu match the reference.
- Edit buttons open the editor even if the pointer moves while the button is pressed.
- Ctrl + mouse wheel zooms wherever the pointer is, also over lists and panels.

### 📚 Docs
- Replaced dated audit, plan and QA reports with one living [CLZ parity report](docs/clz-parity.md) and a concise architecture status.
- Removed scripts that reset or seeded the real database, and the obsolete Collectarr Sans font tooling.
- The CLZ parity report records the search, Add dialog and Export to XML comparison.
- The Game field ledger maps every CLZ Games editor field (Games, Hardware and Toys) and lists the gaps to close before Game is released.
- The CLZ parity report lists matching the light theme as the next open difference.


## 1.0.0 - 2026-10-13

### ✨ Features
- Added the collection activity page with filters and a broader timeline for collection-level actions.
- Added the folder-tree sidebar mode plus folder shelf entry support for folder-style browsing.
- Added the loans manager tab so lent items can be tracked from the app.
- Added collection calendar export to `.ics` so key dates can be shared outside the app.
- Added typed custom fields and kind-aware session history for read, watch, listen, and play flows.
- Expanded typed TV, movie, music, book, boardgame, and comic flows with dedicated inspectors, release/media handling, episode editing, and fractional volume support.
- Added admin proposal tools, stats, health checks, barcode lookup, and contract drift gating.

### 🐛 Fixes
- Stabilized cover loading and cache widths so grid and detail views stay consistent.
- Stabilized grouped workspace layout, navigation chrome, and sync connection handling.
- Fixed TV, video, and comic editor regressions, removed legacy item-season lookups, and cleared analyzer leftovers.

### ♻️ Refactors
- Aligned generic library, inspector, and edit-dialog flows with typed metadata and shared field primitives.
- Consolidated shared add-dialog, inspector, and edit-field scaffolding.
- Reworked library chrome, grouping, and tab routing through the shared shells.
- Split TV, movie, music, book, boardgame, and comic workspace paths into cleaner kind-specific builders.
- Continued kind-switch and editor-flow cleanups across the library surfaces.

### 🧰 CI & Build
- Tightened analyzer/lint follow-up and release/build housekeeping.

### 📚 Docs
- Refreshed release notes and editor guidance.

### 🧪 Tests
- Added and updated coverage for TV routes, contract drift, and editor regressions.

**Full Changelog**: https://github.com/collectarr/collectarr-app/compare/v0.1.4...v0.2.0
