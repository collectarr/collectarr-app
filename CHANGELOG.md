# Changelog

## Unreleased

### 🐛 Fixes
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

### 🧰 CI & Build
- `dart run tool/ci_check.dart` runs the same checks as CI before a push, stage by stage.
- CI runs checks, unit tests and the Linux integration flows as parallel jobs, so one run shows every failure.
- A release is one run of the Release workflow: it picks the version from the commits, moves these changelog entries under it, tags, publishes the notes and builds the downloads.
- Pull requests with several commits are merged with "Rebase and merge", so every change reaches main and the release notes.
- Test fixtures keep LF line endings on Windows checkouts, so the import tests pass there as on CI.

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
