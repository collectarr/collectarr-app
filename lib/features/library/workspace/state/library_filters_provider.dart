import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../session/library_workspace_session_controller.dart';
import 'library_workspace_key.dart';
import 'library_filter_state.dart';

/// Derived read-only selector for [LibraryFilterState] from the single unified workspace session.
final libraryFiltersProvider =
    Provider.family<LibraryFilterState, LibraryWorkspaceKey>(
  (ref, LibraryWorkspaceKey key) {
    final session = ref.watch(libraryWorkspaceSessionProvider(key));
    return LibraryFilterState(
      searchQuery: session.filters.searchQuery,
      searchDraft: session.filters.searchDraft,
      facetValues: session.filters.facetValues,
      groupId: session.filters.groupId,
      sortId: session.filters.sortId,
      sortAscending: session.filters.sortAscending,
      visibleColumnIds: session.filters.visibleColumnIds,
      presentationLevelId: session.filters.presentationLevelId,
    );
  },
);
