# Maintenance dialogs reference audit ? 2026-10-15

CLZ was inspected through its authenticated Opera browser, using screenshots,
accessibility snapshots and computed geometry. No reference data was saved.
Collectarr was exercised with Playwright Chromium and isolated browser storage.
User-local fonts were used for screenshots; no font files or reference assets
were added to the repository.

## Changes

- Reassign uses Library Entry sort definitions rather than the catalog-only
  registry. Personal, Value, Loan and Activity fields are available alongside
  catalog fields. Declared groups such as Recording retain their names.
- Reassign has no Sorting Favorites control, uses OK, and displays the
  reassignment description without a second sort-summary heading.
- Shared panel actions use 100 ? 32 buttons, a 5 px gap, 14 px regular text,
  neutral Cancel (`#494949` in dark mode), and the blue utility action.
  The shared footer is 53 px high with 10 px outer spacing.
- Shared modal surfaces have a 6 px corner radius and no outer border.
  Alert, field selection, pick-list and library dialog surfaces share this shape;
  location and loan dialogs no longer override it with a 16 px radius.
- Transfer uses a 600 px panel anchored 30 px from the top. Item scope precedes
  source and destination cards, side by side on desktop and stacked on narrow
  windows. Field selection uses a searchable nested picker. Destination selection
  is disabled until a source is chosen; empty scopes are disabled.
- Transfer defaults to copying. Clearing the source is explicit. Destination
  replacement and text append remain available; otherwise existing data is kept.
  Counts, a transfer summary and Reset reflect the chosen scope and fields.
  The transaction and final sync payload remain atomic.

## Checks

- Correctness: `dart run tool/run_tests.dart`; focused maintenance/footer checks also passed.
- Analyzer: `flutter analyze --no-pub`.
- Widget coverage: Reassign categories, search and no favorites; normal sort
  favorites/reorder/direction/cancel; transfer copy/move and final sync attachments;
  narrow transfer layout; shared footer geometry and loading state.
- Browser: initial/selected/reset Transfer, nested field picker, 390 px viewport,
  close without saving; Reassign categories, Recording search and Cancel.
- Domain differences are intentional: no Classical/People legacy groups or
  automatic sorting of many-valued disc/credit fields were introduced.
