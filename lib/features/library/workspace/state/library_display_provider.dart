import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/data/library_workspace_query.dart';
import 'package:collectarr_app/features/library/workspace/data/library_workspace_repository.dart';
import 'library_search_debounce_provider.dart';
import 'library_workspace_key.dart';
import 'library_filter_state.dart';
import 'library_filters_provider.dart';

/// Provides a debounced version of the search query from filters to avoid
/// querying the database on every keystroke.
///
/// The debounce duration is controlled by [librarySearchDebounceDurationProvider]
/// so tests can override it with [Duration.zero] without any platform detection.
final libraryDebouncedSearchProvider = StreamProvider.autoDispose
    .family<String, LibraryWorkspaceKey>((ref, key) {
  final filters = ref.watch(libraryFiltersProvider(key));
  final searchQuery = filters.searchQuery;

  if (searchQuery.isEmpty) {
    return Stream.value(searchQuery);
  }

  final duration = ref.watch(librarySearchDebounceDurationProvider);

  if (duration == Duration.zero) {
    return Stream.value(searchQuery);
  }

  final controller = StreamController<String>();
  final timer = Timer(duration, () {
    if (!controller.isClosed) {
      controller.add(searchQuery);
    }
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

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
  final filters = ref.watch(libraryFiltersProvider(key));
  final repository = ref.watch(libraryWorkspaceRepositoryProvider);

  final searchAsync = ref.watch(libraryDebouncedSearchProvider(key));
  final searchQuery = searchAsync.value ?? '';

  final query = LibraryWorkspaceQuery(
    kind: key.kind,
    collectionId: key.collectionId,
    scopeId: key.scopeId,
    presentationLevelId: filters.presentationLevelId,
    searchQuery: searchQuery,
    facetValues: filters.facetValues,
    sortId: filters.sortId,
    sortAscending: filters.sortAscending,
    groupId: filters.groupId,
    visibleColumnIds: filters.visibleColumnIds,
  );

  return repository.watchEntries(query);
});
