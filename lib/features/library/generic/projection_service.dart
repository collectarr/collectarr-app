part of 'projection.dart';

class LibraryProjectionService {
  const LibraryProjectionService();

  LibraryProjection build({
    required ShelfState shelf,
    required LibraryKindRegistration type,
    required LibraryWorkspaceViewState viewState,
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
    Set<String>? collectionEntryIds,
    LibraryFilterSelection filterSelection = LibraryFilterSelection.none,
    List<CustomFieldDefinition> customFieldDefinitions = const [],
    Map<String, List<String>> customFieldValuesByItem = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
    Set<LibraryEntryRef> activeLoanLibraryEntryIds = const {},
    LibrarySearchTarget searchTarget = LibrarySearchTarget.all,
  }) {
    final workspace = libraryKindWorkspaceForKind(type.kind);
    final fields = workspace.fields;
    final projectionQuery = LibraryProjectionQuery(
      searchQuery: query,
      groupId: fields.decodeGroupId(groupMode),
      selectedBucket: selectedBucket,
      selectedItemId: selectedItemId,
      quickView: quickView,
      collectionStatusScope: collectionStatusScope,
      bucketScopeFilters: bucketScopeFilters,
      filterSelection: filterSelection,
      linkedMetadataFilter: linkedMetadataFilter,
      constrainedItemIds: constrainedItemIds,
      collectionEntryIds: collectionEntryIds,
    );

    final engine = LibraryProjectionEngine();
    return engine.execute(
      shelf: shelf,
      type: type,
      viewState: viewState,
      query: projectionQuery,
      overrideBuckets: overrideBuckets,
      customFieldDefinitions: customFieldDefinitions,
      customFieldValuesByItem: customFieldValuesByItem,
      customFieldValuesByDefinitionByItem: customFieldValuesByDefinitionByItem,
      activeLoanLibraryEntryIds: activeLoanLibraryEntryIds,
      searchTarget: searchTarget,
    );
  }
}
