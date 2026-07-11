part of 'projection.dart';

class LibraryProjectionService {
  const LibraryProjectionService();

  LibraryProjection build({
    required ShelfState shelf,
    required LibraryTypeConfig type,
    required LibraryMediaAdapter adapter,
    required LibraryWorkspaceViewState viewState,
    LibraryWorkspaceBrowserMode browserMode = LibraryWorkspaceBrowserMode.media,
    String? releaseFolderTitleItemId,
    required String query,
    LibraryLinkedMetadataFilter? linkedMetadataFilter,
    required String? selectedBucket,
    required String? selectedItemId,
    required LibraryQuickView? quickView,
    LibraryCollectionStatusScope collectionStatusScope =
        LibraryCollectionStatusScope.all,
    required String groupMode,
    List<LibraryBucketScopeFilter> bucketScopeFilters = const [],
    List<LibrarySeriesBucket>? overrideBuckets,
    Set<String>? constrainedItemIds,
    LibraryFilterSelection filterSelection = LibraryFilterSelection.none,
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<String>> customFieldValuesByItem = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
    Set<String> activeLoanOwnedItemIds = const {},
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    final allItems = libraryItemsForShelf(
      shelf,
      type,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByDefinitionByItem:
          customFieldValuesByDefinitionByItem,
      customFieldValuesByItem: customFieldValuesByItem,
      browserMode: browserMode,
      releaseFolderTitleItemId: releaseFolderTitleItemId,
    );
    final scopedBucketItems = [
      for (final item in allItems)
        if (_matchesBucketScopeFilters(item, type, bucketScopeFilters) &&
            _matchesConstrainedItemIds(item, constrainedItemIds))
          item,
    ];
    final normalizedQuery = query.trim().toLowerCase();
    final filteredItems = [
      for (final item in allItems)
        if (_matchesBucketScopeFilters(item, type, bucketScopeFilters) &&
            _matchesBucket(item, type, groupMode, selectedBucket) &&
            _matchesConstrainedItemIds(item, constrainedItemIds) &&
            _matchesCollectionStatusScope(item, collectionStatusScope) &&
            _matchesQuickView(item, quickView) &&
            _matchesFilter(
              item,
              filterSelection,
              adapter,
              activeLoanOwnedItemIds,
              customFieldValuesByDefinitionByItem,
            ) &&
            _matchesLinkedMetadataFilter(item, linkedMetadataFilter, adapter) &&
            _matchesQuery(
              item,
              normalizedQuery,
              customFieldValuesByItem,
              searchTarget,
            ))
          item,
    ]..sort((a, b) => adapter.compareEntriesByRules(
          a.entry,
          b.entry,
          viewState.sortRules,
        ));
    final counts = _toolbarCountsForItems(
      allItems: allItems,
      shown: filteredItems.length,
    );
    return LibraryProjection(
      allItems: allItems,
      filteredItems: filteredItems,
      buckets: overrideBuckets ??
          libraryBucketsForItems(scopedBucketItems, type, groupMode),
      selectedItem: librarySelectedItem(filteredItems, selectedItemId),
      counts: counts,
    );
  }
}
