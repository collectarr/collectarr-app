part of '../generic_library_page.dart';

abstract final class _LibraryProjectionControllerOps {
  static LibraryProjection projectionForShelf(
    GenericLibraryPageState state,
    ShelfState shelf,
    LibraryWorkspaceViewState viewState,
  ) {
    final collections = state.ref
            .watch(libraryCollectionsProvider(state.widget.type.kind.apiValue))
            .asData
            ?.value ??
        const <LibraryCollectionSummary>[];
    final activeId = activeLibraryCollectionId(collections);
    final members =
        collections.where((c) => c.id == activeId).firstOrNull?.entryIds ??
            const <String>{};
    final mode = state._activeGroupMode;
    final facetBuckets = state._facetBucketsForMode(mode, shelf);
    final constrainedItemIds = (state._usesExternalFacetBuckets(mode) &&
            state._session.facets.selectedBucket != null)
        ? facetBuckets?.itemIdsByBucket[state._session.facets.selectedBucket!]
        : null;
    final searchState = state._searchControllerOps.state;
    final searchPinnedItemIds = searchState.pinnedItemId == null
        ? null
        : <String>{searchState.pinnedItemId!};
    final effectiveConstrainedItemIds = _mergeConstrainedItemIds(
      constrainedItemIds,
      searchPinnedItemIds,
    );
    final bucketScopeFilters = state._sidebarBucketScopeFilters;
    // Collection membership scopes both results and sidebar counts.
    final overrideBuckets = facetBuckets == null
        ? null
        : [
            for (final bucket in facetBuckets.buckets)
              if (bucket.title == genericAllBucketLabel(state.widget.type) ||
                  (facetBuckets.itemIdsByBucket[bucket.title] ??
                          const <String>{})
                      .any(members.contains))
                LibraryBucket(
                  title: bucket.title,
                  count:
                      bucket.title == genericAllBucketLabel(state.widget.type)
                          ? members.length
                          : (facetBuckets.itemIdsByBucket[bucket.title] ??
                                  const <String>{})
                              .where(members.contains)
                              .length,
                  coverUrl: bucket.coverUrl,
                  startYear: bucket.startYear,
                  missingNumbers: bucket.missingNumbers,
                ),
          ];
    final linkedMetadataFilter = state._session.facets.linkedMetadataFilter;
    final selectedBucket = state._usesExternalFacetBuckets(mode)
        ? null
        : state._session.facets.selectedBucket;
    final selectedItemId = state._session.selection.selectedId;
    final quickView = state._session.facets.quickView;
    final collectionStatusScope = state._session.facets.collectionStatusScope;
    final filterSelection = state._session.selection.filterSelection;
    final projectionCache = state.ref.watch(
      libraryCustomFieldCacheProvider(state.widget.type.kind.apiValue),
    );
    final customFieldValues = projectionCache.asData?.value.valuesByItem ??
        const <String, List<String>>{};
    final customFieldValuesByDefinition =
        projectionCache.asData?.value.valuesByDefinitionByItem ??
            const <String, Map<String, String>>{};
    final customFieldDefinitions =
        projectionCache.asData?.value.definitions ?? const [];
    final activeLoanLibraryEntryIds = state._activeLoanLibraryEntryIds;
    final query = searchState.query;
    final searchTarget = state._effectiveSearchTarget;
    return state.ref.watch(
      libraryProjectionProvider(
        LibraryProjectionRequest(
          shelf: shelf,
          type: state.widget.type,
          viewState: viewState,
          query: query,
          linkedMetadataFilter: linkedMetadataFilter,
          selectedBucket: selectedBucket,
          selectedItemId: selectedItemId,
          quickView: quickView,
          collectionStatusScope: collectionStatusScope,
          groupMode: mode,
          bucketScopeFilters: bucketScopeFilters,
          overrideBuckets: overrideBuckets,
          constrainedItemIds: effectiveConstrainedItemIds,
          collectionEntryIds: members,
          filterSelection: filterSelection,
          customFieldValuesByItem: customFieldValues,
          customFieldValuesByDefinitionByItem: customFieldValuesByDefinition,
          customFieldDefinitions: customFieldDefinitions,
          activeLoanLibraryEntryIds: activeLoanLibraryEntryIds,
          searchTarget: searchTarget,
        ),
      ),
    );
  }

  static Set<String>? _mergeConstrainedItemIds(
    Set<String>? left,
    Set<String>? right,
  ) {
    if (left == null) {
      return right;
    }
    if (right == null) {
      return left;
    }
    return left.intersection(right);
  }
}
