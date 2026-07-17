import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'library_workspace_key.dart';
import 'library_filter_state.dart';
import 'library_filters_provider.dart';
import 'library_view_config_state.dart';
import 'library_view_config_provider.dart';

// ─── Key helpers ──────────────────────────────────────────────────────────────

String _k(LibraryWorkspaceKey key, String field) =>
    'workspace.${key.kind.apiValue}.$field';

// ─── Read ─────────────────────────────────────────────────────────────────────

/// Loads the persisted [LibraryFilterState] for [key] from SharedPreferences.
///
/// Returns the module's defaults when no data is stored yet — so the first
/// load always yields a valid state.
Future<LibraryFilterState> loadPersistedFilterState(
  LibraryWorkspaceKey key,
) async {
  final prefs = await SharedPreferences.getInstance();
  final module = libraryKindModuleForKind(key.kind);

  final sortId = prefs.getString(_k(key, 'sort_id')) ?? module.fields.defaultSortId;
  final sortAscending = prefs.getBool(_k(key, 'sort_ascending')) ?? true;
  final groupId = prefs.getString(_k(key, 'group_id')) ?? module.fields.defaultGroupId;

  final storedColumns = prefs.getStringList(_k(key, 'visible_columns'));
  final visibleColumnIds = storedColumns != null
      ? Set<String>.from(storedColumns)
      : module.fields.defaultVisibleColumnIds.toSet();

  return LibraryFilterState(
    sortId: sortId,
    sortAscending: sortAscending,
    groupId: groupId,
    visibleColumnIds: visibleColumnIds,
    presentationLevelId: key.presentationLevelId,
    // searchQuery and facetValues are intentionally not persisted —
    // they are transient session state.
  );
}

/// Loads the persisted [LibraryViewConfigState] for [key].
Future<LibraryViewConfigState> loadPersistedViewConfig(
  LibraryWorkspaceKey key,
) async {
  final prefs = await SharedPreferences.getInstance();

  return LibraryViewConfigState(
    coverSize: prefs.getDouble(_k(key, 'cover_size')) ?? 128.0,
    isSidebarVisible: prefs.getBool(_k(key, 'sidebar_visible')) ?? true,
    sidebarWidth: prefs.getDouble(_k(key, 'sidebar_width')) ?? 240.0,
    detailsWidth: prefs.getDouble(_k(key, 'details_width')) ?? 320.0,
    detailsHeight: prefs.getDouble(_k(key, 'details_height')) ?? 280.0,
  );
}

// ─── Write ────────────────────────────────────────────────────────────────────

/// Persists [state] for [key] to SharedPreferences.
Future<void> persistFilterState(
  LibraryWorkspaceKey key,
  LibraryFilterState state,
) async {
  final prefs = await SharedPreferences.getInstance();
  if (state.sortId != null) {
    await prefs.setString(_k(key, 'sort_id'), state.sortId!);
  }
  await prefs.setBool(_k(key, 'sort_ascending'), state.sortAscending);
  if (state.groupId != null) {
    await prefs.setString(_k(key, 'group_id'), state.groupId!);
  }
  if (state.visibleColumnIds.isNotEmpty) {
    await prefs.setStringList(
      _k(key, 'visible_columns'),
      state.visibleColumnIds.toList(growable: false),
    );
  }
}

/// Persists [config] for [key] to SharedPreferences.
Future<void> persistViewConfig(
  LibraryWorkspaceKey key,
  LibraryViewConfigState config,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(_k(key, 'cover_size'), config.coverSize);
  await prefs.setBool(_k(key, 'sidebar_visible'), config.isSidebarVisible);
  await prefs.setDouble(_k(key, 'sidebar_width'), config.sidebarWidth);
  await prefs.setDouble(_k(key, 'details_width'), config.detailsWidth);
  await prefs.setDouble(_k(key, 'details_height'), config.detailsHeight);
}

// ─── Riverpod bridge ──────────────────────────────────────────────────────────

/// Async provider that loads persisted state for [key] and hydrates both
/// [libraryFiltersProvider] and [libraryViewConfigProvider] on first access.
///
/// Widgets should watch this provider and wait for it to be in [AsyncData]
/// before allowing user interactions that depend on persisted defaults.
final libraryWorkspaceHydrationProvider =
    FutureProvider.autoDispose.family<void, LibraryWorkspaceKey>((ref, key) async {
  final filterState = await loadPersistedFilterState(key);
  final viewConfig = await loadPersistedViewConfig(key);

  // Restore both notifiers from persisted state.
  ref.read(libraryFiltersProvider(key).notifier).restoreFrom(filterState);
  ref.read(libraryViewConfigProvider(key).notifier).restoreFrom(viewConfig);
});

/// Debounced auto-save: listens to filter and view config changes and persists
/// them after a short delay to avoid excessive disk writes during rapid changes
/// (e.g. dragging a slider).
///
/// Activate by watching this provider in the workspace root widget:
/// ```dart
/// ref.watch(libraryWorkspacePersistenceProvider(key));
/// ```
final libraryWorkspacePersistenceProvider =
    Provider.autoDispose.family<void, LibraryWorkspaceKey>((ref, key) {
  Timer? debounce;

  ref.listen<LibraryFilterState>(
    libraryFiltersProvider(key),
    (_, next) {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 800), () {
        persistFilterState(key, next);
      });
    },
  );

  ref.listen<LibraryViewConfigState>(
    libraryViewConfigProvider(key),
    (_, next) {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 800), () {
        persistViewConfig(key, next);
      });
    },
  );

  ref.onDispose(() => debounce?.cancel());
});
