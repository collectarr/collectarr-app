# Copilot Instructions for collectarr-app

## Communication

- Raspunde in romana, concis si practic.
- Nu inventa comportamente; verifica in cod, teste sau documentatie locala.

## Project Context

- **collectarr-app** is a Flutter 3.44+ / Dart 3.12+ offline-first desktop + mobile app for managing physical media collections.
- The current in-app library registry ships 9 active kinds: `comic`, `manga`, `anime`, `book`, `game`, `boardgame`, `movie`, `tv`, `music`.
- Entry point: `lib/main.dart`.
- App code lives in `lib/`; tests live in `test/`.
- State management: **Riverpod** (`flutter_riverpod`).
- Local DB: **Drift** (SQLite) — schema in `lib/core/db/local_database.dart`, generated code in `local_database.g.dart`.
- Backend: **collectarr-core** (Python FastAPI at `../collectarr-core`), synced via REST API and local sync queue.
- Companion sync service: **collectarr-sync** at `../collectarr-sync`.

## Architecture

### Library Type System
- `LibraryTypeConfig` in `lib/features/library/config/library_type_config.dart` defines per-type configuration.
- The active registry lives in `lib/features/library/kinds/registry/collectarr_library_types.dart`.
- Per-kind configs and builders live under `lib/features/library/kinds/<kind>/`.
- Shared library workspace flow is centered on `lib/features/library/generic/page.dart`, `body.dart`, `toolbar.dart`, `sidebar.dart`, and `projection.dart`.
- Add-dialog builders are registered through `lib/features/library/kinds/registry/library_add_registry.dart` and `registerLibraryAddBuilders()`.
- Comic-specific behavior is still kind-owned, but now lives under `lib/features/library/kinds/comic/` instead of a separate legacy feature tree.

### Shared Selection / Bulk Operations
- `LibrarySelectionControls` — generic toolbar widget (`lib/features/library/selection/library_selection_controls.dart`).
- `LibraryBulkEditDialog` — generic bulk edit dialog (`lib/features/library/selection/library_bulk_edit_dialog.dart`).
- `LibraryBulkActions` — generic bulk action logic (`lib/features/library/selection/library_bulk_actions.dart`).

### Workspace / Inspector Surfaces
- Shared workspace widgets live under `lib/features/library/workspace/`.
- Shared inspector and detail surfaces live under `lib/features/library/inspector/` and `lib/features/library/detail/`.
- Kind-specific presentation hooks compose into those shared shells through `LibraryMediaPresentation`, `LibraryEditPresentation`, and `LibraryTypeConfig` builders.

### Workspace group presentation (main panel)
- The main grid panel supports a **user toggle** between `folderGrid` (hierarchical folder tiles that
  navigate on tap) and `inlineHeaders` (collapsible sections that expand/collapse in place). Both follow
  the active group mode. Enum: `LibraryGroupPresentation` (`library_media_presentation_models.dart`).
- Toggle UI: `LibraryGroupPresentationToggle` (SegmentedButton) in the toolbar, shown only when grouping
  is active. The user override is stored per-preset via `LibraryViewPreferenceStore.writeGroupPresentationOverride`
  and applied through `libraryGroupEntriesForItems(presentationOverride: ...)`.
- `inlineHeaders` groups are collapsible: `_GroupHeader` chevron `onToggleExpanded` (expand in place) is
  separate from `onOpenDetails` (open the group). Collapsed buckets persist per-preset
  (`read/writeCollapsedGroupBuckets`). Bulk "Expand all / Collapse all" is driven by
  `onSetCollapsedGroupBuckets` (one state mutation + one write), threaded body → workspace → shelf view.

### Edit dialogs
- **Two dialog families.** Most kinds use the shared shell renderer `LibraryEditRenderer`
  (`lib/features/library/edit/shell/library_edit_dialog.dart`), which routes tabs **by tab id** via
  `_tabViewFor(tab.id)` (its `default:` case throws — only known ids render). Book and music use fully
  bespoke dialogs (`buildBookLibraryEditDialog`, `buildMusicLibraryEditDialog`); movie/tv render their
  media tab through `VideoEditMediaTab` (video edit path).
- **Edit scope.** `LibraryEditScope { media, release, all }`. `LibraryEditDialogRequest.scope` defaults
  to `media`; owned/tracking/wishlist items resolve to `all`. `builderForScope` picks the kind's
  media / release / combined (all-scope) `LibraryEditPresentation` builder. Field visibility:
  `_canShowMediaFields` (media|all), `_canShowReleaseFields` (release|all), `_showsReleaseSection`.
- **Tab ordering.** `LibraryEditSectionRegistry.orderTabs` sorts tabs by category using
  `sectionCategoryById`. Any **new sectionId must be registered** there or its tab sorts last.
- **Media/release field separation.** Release-identity fields (edition title/variant/barcode/physical
  format) live in `LibraryReleaseIdentityFields` and must not share the Main tab with media/work fields.
  To separate for a shell-renderer kind: add a `release` tab (`sectionIds: ['release_identity']`) to the
  kind's **combined (all-scope) builder only** (keep media/release builders clean); the renderer's
  `_releaseTab()`/`_hasReleaseTab` then move the section off Main and show a placeholder when no release
  anchor applies. Done for **game, boardgame**. Movie (`edition` tab) and tv (`Edition Details` tab)
  already separate. **Comic is intentionally excluded** — its edit dialog is kind-owned
  (`_ownedComicMainTab`, ownership-anchor edition handling) and the generic tab breaks its tests.

### Shared edit field primitives (use these — do NOT reimplement)
Canonical widgets in `lib/features/library/edit/fields/edit_dialog_widgets.dart` (+ `library_edit_field_groups.dart`).
New edit UI must reuse them instead of declaring private `_field`/layout helpers:
- `LibraryEditTextField` — labelled `TextFormField` (label/hint/validator). Replaces every ad-hoc `_field`.
- `LibraryEditResponsiveRow` — responsive 1↔2 column row (breakpoint 620), equal `Expanded` columns.
- `LibraryEditDenseFields` — `Wrap`-based dense grid; density is configurable per kind via
  `wideColumns`/`ultraWideColumns` + `wideBreakpoint`/`ultraWideBreakpoint` (book 1/2/3 @560/780,
  music 1/2/4 @620/900, video 2 @600). Prefer this over bespoke `Wrap`/`Row`-of-`Row`s grids.
- `LibraryDateFieldButton` — **canonical date field**: inline YYYY/MM/DD entry + a calendar picker button.
  Do **not** add modal single-field date pickers (`showLibraryDateEntryDialog` is legacy for this use).
- `SingleValuePickField` — canonical single-value pick/vocabulary field (with manage/pick-list actions).
- `EditSection` (section wrapper — note: its `title` is decorative/not rendered, so tests should assert on
  field labels, not section titles), `EditTabShell` (scrollable tab body), `EditTab` (icon+label tab).
- Tab views are **lazy** (only the active tab is mounted). In tests, open all-scope dialogs with
  `scope: LibraryEditScope.all`; tab labels are found via `find.text(label)`.

## Database (Drift)

- DB file: `collectarr.sqlite` in `getApplicationDocumentsDirectory()` (Documents folder on Windows).
- Schema version is in `LocalDatabase.schemaVersion` (`lib/core/db/local_database.dart`).
- Migration strategy is **destructive** (drop all + recreate) — this is a cache DB, not the source of truth; the backend is.
- **When changing DB schema**: bump `schemaVersion` so `onUpgrade` fires for existing installs. The destructive migration will handle the rest.
- Tables: `CatalogCache`, `OwnedItemsCache`, `WishlistItemsCache`, `SyncQueue`, `CustomFieldDefinitionsCache`, `CustomFieldValuesCache`, `ItemImagesCache`.
- Generated code: run `dart run build_runner build --delete-conflicting-outputs` after schema changes.

### DB Reset Script
- `scripts/reset_and_run.ps1` — kills dart processes, deletes local DB, optionally cleans build and re-runs the app.
- Usage: `.\scripts\reset_and_run.ps1 -Run` or `.\scripts\reset_and_run.ps1 -Run -Clean`.

## Git and Releases

- Use conventional commits (`feat:`, `fix:`, `test:`, `chore:`, `refactor:`).
- semantic-release reads `.releaserc.json`.
- Tech-debt work goes on `fix/tech-debt` branch.
- Do not manually edit generated release artifacts.

## Flutter and Style

- Target SDK: `>=3.5.0 <4.0.0`.
- 9 active library kinds: comic, manga, anime, book, game, boardgame, movie, tv, music.
- Comics still have kind-owned add/edit/presentation code, but they participate in the shared config-driven library system under `lib/features/library/`.
- `LibrarySeriesBucket` and `LibrarySeriesSidebar` are shared by both comics and generic libraries.
- Cover images: `LibraryCoverImage` (local base64 → CachedNetworkImage → placeholder).
- Add dialogs have resizable panes: `_resultsPaneWidth`, `_clampedResultsPaneWidth()`, `_resizeResultsPane()`.
- Prefer `flutter_riverpod` for state; do not introduce other state management.
- Keep type annotations on public APIs.
- **Reuse shared edit field primitives** (`LibraryEditTextField`, `LibraryEditResponsiveRow`,
  `LibraryEditDenseFields`, `LibraryDateFieldButton`, `SingleValuePickField`) — see the "Shared edit
  field primitives" section. Do not add private `_field`/date/grid helpers per kind.
- Avoid broad `catch` except at UI boundaries where errors are logged.
- Use `SingleChildScrollView` to wrap long dialog content (prevents overflow in tests with small screen sizes).
- **Analyzer is strict** (`strict-casts`, `strict-inference`, `strict-raw-types` in `analysis_options.yaml`).
  New code must pass `flutter analyze` with no new issues.
- **Splitting large files**: big dialogs/state classes are split with `part`/`part of` + private
  `extension _Name on _StateClass { ... }` in a sibling file. `setState` is protected inside extensions —
  mutate through the existing wrappers (`_rebuild` / `_updateState` / `_mutateDialogState`), not `setState`
  directly. Files are CRLF.

## Testing

- Tests use `flutter test`. CI runs on Flutter 3.44+.
- **Known Windows issue**: `sqlite3.dll` race condition (`PathExistsException`) when running tests. Fix: kill dart processes (`Get-Process -Name dart | Stop-Process -Force`), delete `build/` and `.dart_tool/`, then retry.
- Test patterns:
  - `ProviderScope` + `overrides` for Riverpod providers.
  - `pumpWidget` + `pumpAndSettle` for widget tests.
  - Use `find.textContaining(...)` for partial text matches (e.g., dialog titles with item counts).
  - Tooltip text is `'Select items'` (not type-specific).
  - Tracking status label is `'Tracking status'` (not `'Read status'`).

## Docker / Backend

- collectarr-core runs via Docker in WSL2: `wsl -d Ubuntu -- docker compose -f /path/to/docker-compose.yml up -d`.
- API is at `http://{WSL2_IP}:8000` — get IP with `wsl hostname -I` (changes on restart).
- `localhost` does NOT work from Windows to WSL2 — must use the WSL2 VM IP directly.
- App connects via `lib/core/api/api_client.dart` (Dio-based).
- Connection settings in SharedPreferences: `C:\Users\andrvoicu\AppData\Roaming\Collectarr\Collectarr\shared_preferences.json`.

## Common Operations

| Task | Command |
|------|---------|
| Get dependencies | `flutter pub get` |
| Generate Drift code | `dart run build_runner build --delete-conflicting-outputs` |
| Run tests | `flutter test` |
| Run analyzer | `flutter analyze` |
| Build Windows debug | `flutter build windows --debug` |
| Run on Windows | `flutter run -d windows` |
| Reset local DB | `.\scripts\reset_and_run.ps1` |
| Reset + run | `.\scripts\reset_and_run.ps1 -Run` |
| Full clean + run | `.\scripts\reset_and_run.ps1 -Run -Clean` |
