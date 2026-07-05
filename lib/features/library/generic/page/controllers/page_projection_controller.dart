part of '../../page.dart';

abstract final class _LibraryProjectionControllerOps {
  static LibraryProjection projectionForShelf(
    GenericLibraryPageState state,
    ShelfState shelf,
    LibraryWorkspaceViewState viewState,
  ) {
    final mode = state._activeGroupMode;
    final facetBuckets = state._facetBucketsForMode(mode, shelf);
    final constrainedItemIds =
        (state._usesExternalFacetBuckets(mode) && state._selectedBucket != null)
            ? facetBuckets?.itemIdsByBucket[state._selectedBucket!]
            : null;
    final searchState = _LibraryPageSearchControllerOps.thisState(state);
    final searchPinnedItemIds = searchState.pinnedItemId == null
        ? null
        : <String>{searchState.pinnedItemId!};
    final effectiveConstrainedItemIds = _mergeConstrainedItemIds(
      constrainedItemIds,
      searchPinnedItemIds,
    );
    final bucketScopeFilters = state._sidebarBucketScopeFilters;
    final overrideBuckets = facetBuckets?.buckets;
    final linkedMetadataFilter = state._linkedMetadataFilter;
    final selectedBucket =
        state._usesExternalFacetBuckets(mode) ? null : state._selectedBucket;
    final selectedItemId = state._selectedId;
    final quickView = state._quickView;
    final collectionStatusScope = state._collectionStatusScope;
    final filterSelection = state._filterSelection;
    final projectionCache = state.ref.watch(
      libraryProjectionCacheProvider(state.widget.type.workspace.kind.apiValue),
    );
    final customFieldValues =
        projectionCache.asData?.value.valuesByItem ?? const <String, List<String>>{};
    final customFieldValuesByDefinition =
        projectionCache.asData?.value.valuesByDefinitionByItem ??
            const <String, Map<String, String>>{};
    final customFieldDefinitions =
        projectionCache.asData?.value.definitions ?? const [];
    final activeLoanOwnedItemIds = state._activeLoanOwnedItemIds;
    final query = searchState.query;
    final searchTarget = state._effectiveSearchTarget;
    final browserMode = state._activeBrowserMode;
    final releaseFolderTitleItemId = state.activeReleaseFolderTitleItemId;
    return state.ref.watch(
      libraryProjectionProvider(
        LibraryProjectionRequest(
          shelf: shelf,
          type: state.widget.type,
          adapter: state._adapter,
          viewState: viewState,
          browserMode: browserMode,
          releaseFolderTitleItemId: releaseFolderTitleItemId,
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
          filterSelection: filterSelection,
          customFieldValuesByItem: customFieldValues,
          customFieldValuesByDefinitionByItem: customFieldValuesByDefinition,
          customFieldDefinitions: customFieldDefinitions,
          activeLoanOwnedItemIds: activeLoanOwnedItemIds,
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
