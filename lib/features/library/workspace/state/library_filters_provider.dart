import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'library_workspace_key.dart';
import 'library_filter_state.dart';

class LibraryFilters extends StateNotifier<LibraryFilterState> {
  LibraryFilters(this.key) : super(const LibraryFilterState()) {
    reset();
  }

  final LibraryWorkspaceKey key;
  Timer? _searchDebounceTimer;

  void updateSearch(String query, {bool? immediate}) {
    state = state.copyWith(searchDraft: query);
    _searchDebounceTimer?.cancel();
    final shouldBeImmediate = immediate ?? query.isEmpty || Platform.environment.containsKey('FLUTTER_TEST');
    if (shouldBeImmediate) {
      state = state.copyWith(searchQuery: query);
    } else {
      _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        state = state.copyWith(searchQuery: query);
      });
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void setFacetValues(String facetId, Set<String> values) {
    final next = Map<String, Set<String>>.from(state.facetValues);

    if (values.isEmpty) {
      next.remove(facetId);
    } else {
      next[facetId] = values;
    }

    state = state.copyWith(facetValues: next);
  }

  void clearFacet(String facetId) {
    final next = Map<String, Set<String>>.from(state.facetValues)
      ..remove(facetId);

    state = state.copyWith(facetValues: next);
  }

  void setGroup(String? groupId) {
    state = state.copyWith(groupId: () => groupId);
  }

  void setSort(String sortId, {bool? ascending}) {
    state = state.copyWith(
      sortId: () => sortId,
      sortAscending: ascending ?? state.sortAscending,
    );
  }

  void setVisibleColumns(Set<String> columnIds) {
    state = state.copyWith(visibleColumnIds: columnIds);
  }

  void reset() {
    final module = libraryKindModuleForKind(key.kind);

    state = LibraryFilterState(
      groupId: module.fields.defaultGroupId,
      sortId: module.fields.defaultSortId,
      visibleColumnIds: module.fields.defaultVisibleColumnIds.toSet(),
      presentationLevelId: key.presentationLevelId,
    );
  }

  /// Bulk-restore from a previously persisted snapshot (used by hydration).
  void restoreFrom(LibraryFilterState saved) {
    state = saved;
  }
}

final libraryFiltersProvider =
    StateNotifierProvider.family<LibraryFilters, LibraryFilterState,
        LibraryWorkspaceKey>((ref, LibraryWorkspaceKey key) {
  return LibraryFilters(key);
});
