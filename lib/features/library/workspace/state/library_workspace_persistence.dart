import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import '../session/library_workspace_session_controller.dart';
import '../session/library_workspace_session_state.dart';
import 'library_workspace_key.dart';
import 'library_filter_state.dart';
import 'library_view_config_state.dart';

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
  final module = libraryKindRuntimeForKind(key.kind);

  final storedSortId = prefs.getString(_k(key, 'sort_id'));
  final sortDefinition = storedSortId == null
      ? null
      : module.fields.findSortDefinition(
          module.fields.decodeSortId(storedSortId),
        );
  final sortId = sortDefinition?.id ?? module.fields.defaultSort;
  final sortAscending = prefs.getBool(_k(key, 'sort_ascending')) ?? true;
  final storedGroupId = prefs.getString(_k(key, 'group_id'));
  final groupDefinition = storedGroupId == null
      ? null
      : module.fields.findGroupDefinition(
          module.fields.decodeGroupId(storedGroupId),
        );
  final groupId = groupDefinition?.id ?? module.fields.defaultGroup;

  final storedColumns = prefs.getStringList(_k(key, 'visible_columns'));
  final decodedColumnIds = <LibraryFieldIdRuntime>{};
  if (storedColumns != null) {
    for (final storedColumn in storedColumns) {
      final definition = module.fields.findColumnDefinition(
        module.fields.decodeColumnId(storedColumn),
      );
      if (definition != null) {
        decodedColumnIds.add(definition.id);
      }
    }
  }
  final visibleColumnIds = decodedColumnIds.isEmpty
      ? module.fields.defaultVisibleColumns
      : decodedColumnIds;

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
  final module = libraryKindRuntimeForKind(key.kind);
  final sortDefinition = state.sortId == null
      ? null
      : module.fields.findSortDefinition(
          state.sortId!,
        );
  if (state.sortId != null) {
    if (sortDefinition != null) {
      await prefs.setString(_k(key, 'sort_id'), sortDefinition.id.value);
    }
  }
  await prefs.setBool(_k(key, 'sort_ascending'), state.sortAscending);
  final groupDefinition = state.groupId == null
      ? null
      : module.fields.findGroupDefinition(
          state.groupId!,
        );
  if (state.groupId != null) {
    if (groupDefinition != null) {
      await prefs.setString(_k(key, 'group_id'), groupDefinition.id.value);
    }
  }
  if (state.visibleColumnIds.isNotEmpty) {
    final visibleColumnIds = state.visibleColumnIds
        .map(
          (columnId) => module.fields.findColumnDefinition(columnId)?.id.value,
        )
        .whereType<String>()
        .toList(growable: false);
    await prefs.setStringList(
      _k(key, 'visible_columns'),
      visibleColumnIds,
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

/// Async provider that loads persisted state for [key] and hydrates
/// [libraryWorkspaceSessionProvider] on first access.
///
/// Widgets should watch this provider and wait for it to be in [AsyncData]
/// before allowing user interactions that depend on persisted defaults.
final libraryWorkspaceHydrationProvider = FutureProvider.autoDispose
    .family<void, LibraryWorkspaceKey>((ref, key) async {
  final filterState = await loadPersistedFilterState(key);
  final viewConfig = await loadPersistedViewConfig(key);

  ref.read(libraryWorkspaceSessionProvider(key).notifier).bulkRestore(
        filters: LibrarySessionFilterState(
          groupId: filterState.groupId,
          sortId: filterState.sortId,
          sortAscending: filterState.sortAscending,
          visibleColumnIds: filterState.visibleColumnIds,
          presentationLevelId: filterState.presentationLevelId,
        ),
        view: LibrarySessionViewState(
          coverSize: viewConfig.coverSize,
          sidebarVisible: viewConfig.isSidebarVisible,
          sidebarWidth: viewConfig.sidebarWidth,
          detailsWidth: viewConfig.detailsWidth,
          detailsHeight: viewConfig.detailsHeight,
        ),
      );
});

/// Debounced auto-save: listens to unified workspace session changes and
/// persists filters and view preferences after a short delay.
final libraryWorkspacePersistenceProvider =
    Provider.autoDispose.family<void, LibraryWorkspaceKey>((ref, key) {
  Timer? debounce;

  ref.listen<LibraryWorkspaceSessionState>(
    libraryWorkspaceSessionProvider(key),
    (prev, next) {
      if (prev?.filters != next.filters || prev?.view != next.view) {
        debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 800), () {
          persistFilterState(
            key,
            LibraryFilterState(
              sortId: next.filters.sortId,
              sortAscending: next.filters.sortAscending,
              groupId: next.filters.groupId,
              visibleColumnIds: next.filters.visibleColumnIds,
              presentationLevelId: next.filters.presentationLevelId,
            ),
          );
          persistViewConfig(
            key,
            LibraryViewConfigState(
              coverSize: next.view.coverSize,
              isSidebarVisible: next.view.sidebarVisible,
              sidebarWidth: next.view.sidebarWidth,
              detailsWidth: next.view.detailsWidth,
              detailsHeight: next.view.detailsHeight,
            ),
          );
        });
      }
    },
  );

  ref.onDispose(() => debounce?.cancel());
});
