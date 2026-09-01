part of 'projection.dart';

class LibraryProjectionService {
  const LibraryProjectionService();

  LibraryProjection build({
    required ShelfState shelf,
    required LibraryTypeConfig type,
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
    List<LibraryBucket>? overrideBuckets,
    Set<String>? constrainedItemIds,
    LibraryFilterSelection filterSelection = LibraryFilterSelection.none,
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<String>> customFieldValuesByItem = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
    Set<String> activeLoanOwnedItemIds = const {},
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    final runtime = libraryKindRuntimeForType(type);
    final projectionQuery = LibraryProjectionQuery(
      searchQuery: query,
      groupId: runtime.fields.decodeGroupId(groupMode),
      selectedBucket: selectedBucket,
      selectedItemId: selectedItemId,
      quickView: quickView,
      collectionStatusScope: collectionStatusScope,
      bucketScopeFilters: bucketScopeFilters,
      filterSelection: filterSelection,
      linkedMetadataFilter: linkedMetadataFilter,
      constrainedItemIds: constrainedItemIds,
    );

    final engine = LibraryProjectionEngine();
    return engine.execute(
      shelf: shelf,
      type: type,
      viewState: viewState,
      query: projectionQuery,
      browserMode: browserMode,
      releaseFolderTitleItemId: releaseFolderTitleItemId,
      overrideBuckets: overrideBuckets,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinitionByItem,
      activeLoanOwnedItemIds: activeLoanOwnedItemIds,
      searchTarget: searchTarget,
    );
  }
}
