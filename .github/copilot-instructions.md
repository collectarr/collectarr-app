# Copilot Instructions for collectarr-app

## Communication

- Raspunde in romana, concis si practic.
- Nu inventa comportamente; verifica in cod, teste sau documentatie locala.

## Project Context

- **collectarr-app** is a Flutter 3.41.9 / Dart 3.11.5 offline-first desktop + mobile app for managing physical media collections (comics, vinyl, VHS, books, etc.).
- Entry point: `lib/main.dart`.
- App code lives in `lib/`; tests live in `test/`.
- State management: **Riverpod** (`flutter_riverpod`).
- Local DB: **Drift** (SQLite) — schema in `lib/core/db/local_database.dart`, generated code in `local_database.g.dart`.
- Backend: **collectarr-core** (Python FastAPI at `../collectarr-core`), synced via REST API and local sync queue.
- Companion sync service: **collectarr-sync** at `../collectarr-sync`.

## Architecture

### Library Type System
- `LibraryTypeConfig` in `lib/features/library/library_type_config.dart` defines per-type configuration (conditions, grades, defaultCondition, defaultGrade, icons, labels).
- Comics has its own config in `lib/features/comics/comics_library_config.dart`.
- Generic library types (vinyl, VHS, books, etc.) use `GenericLibraryPage` in `lib/features/library/generic_library_page.dart`.
- Comics uses its own `ComicsPage` in `lib/features/comics/comics_page.dart`.

### Shared Selection / Bulk Operations
- `LibrarySelectionControls` — generic toolbar widget (`lib/features/library/selection/library_selection_controls.dart`).
- `LibraryBulkEditDialog` — generic bulk edit dialog (`lib/features/library/selection/library_bulk_edit_dialog.dart`).
- `LibraryBulkActions` — generic bulk action logic (`lib/features/library/selection/library_bulk_actions.dart`).
- Comics page wraps these via `lib/features/comics/comics_page_bulk_actions.dart`.

### Workspace Controls (Comics)
- `ComicsWorkspaceControls` — control strip with selection, view-table, filters.
- `ComicsWorkspaceControlState` / `ComicsWorkspaceControlCallbacks` — state/callback models.
- Uses `LibrarySelectionCallbacks` record type: `({void Function(bool) onSelectionModeChanged, VoidCallback onSelectAll, VoidCallback onDeselectAll})`.

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
- Prefer `flutter_riverpod` for state; do not introduce other state management.
- Keep type annotations on public APIs.
- Avoid broad `catch` except at UI boundaries where errors are logged.
- Use `SingleChildScrollView` to wrap long dialog content (prevents overflow in tests with small screen sizes).

## Testing

- Tests use `flutter test`. CI runs on Flutter 3.41.9.
- **Known Windows issue**: `sqlite3.dll` race condition (`PathExistsException`) when running tests. Fix: kill dart processes (`Get-Process -Name dart | Stop-Process -Force`), delete `build/` and `.dart_tool/`, then retry.
- Test patterns:
  - `ProviderScope` + `overrides` for Riverpod providers.
  - `pumpWidget` + `pumpAndSettle` for widget tests.
  - Use `find.textContaining(...)` for partial text matches (e.g., dialog titles with item counts).
  - Tooltip text is `'Select items'` (not type-specific).
  - Tracking status label is `'Tracking status'` (not `'Read status'`).

## Docker / Backend

- collectarr-core runs via Docker: `wsl -e bash -c "cd /path && docker compose up -d"`.
- API is at `localhost:8010`.
- App connects via `lib/core/api/` client classes.

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
