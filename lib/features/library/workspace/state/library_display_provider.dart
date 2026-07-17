import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/data/library_workspace_query.dart';
import 'package:collectarr_app/features/library/workspace/data/library_workspace_repository.dart';
import 'library_workspace_key.dart';
import 'library_filter_state.dart';
import 'library_filters_provider.dart';

/// Derives the filtered + sorted list of [LibraryWorkspaceEntry] objects for a
/// given workspace scope, by combining the active [LibraryFilterState] with the
/// [LibraryWorkspaceRepository] stream.
///
/// Re-emits whenever:
///  - the filter/sort/group/column state changes (via [libraryFiltersProvider])
///  - the underlying shelf data changes (via [shelfProvider] invalidation after
///    mutations or sync)
final libraryDisplayListProvider = StreamProvider.autoDispose
    .family<List<LibraryWorkspaceEntry>, LibraryWorkspaceKey>((ref, key) {
  final LibraryFilterState filters = ref.watch(libraryFiltersProvider(key));
  final LibraryWorkspaceRepository repository =
      ref.watch(libraryWorkspaceRepositoryProvider);

  final query = LibraryWorkspaceQuery(
    kind: key.kind,
    collectionId: key.collectionId,
    scopeId: key.scopeId,
    presentationLevelId: filters.presentationLevelId,
    searchQuery: filters.searchQuery,
    facetValues: filters.facetValues,
    sortId: filters.sortId,
    sortAscending: filters.sortAscending,
    groupId: filters.groupId,
    visibleColumnIds: filters.visibleColumnIds,
  );

  return repository.watchEntries(query);
});
