part of '../../page.dart';

@immutable
class LibraryProjectionRequest {
  const LibraryProjectionRequest({
    required this.signature,
    required this.shelf,
    required this.type,
    required this.adapter,
    required this.viewState,
    required this.browserMode,
    required this.releaseFolderTitleItemId,
    required this.query,
    required this.linkedMetadataFilter,
    required this.selectedBucket,
    required this.selectedItemId,
    required this.quickView,
    required this.collectionStatusScope,
    required this.groupMode,
    required this.bucketScopeFilters,
    required this.overrideBuckets,
    required this.constrainedItemIds,
    required this.filterSelection,
    required this.customFieldValuesByItem,
    required this.customFieldValuesByDefinitionByItem,
    required this.activeLoanOwnedItemIds,
    required this.searchTarget,
  });

  final String signature;
  final ShelfState shelf;
  final LibraryTypeConfig type;
  final LibraryMediaAdapter adapter;
  final LibraryWorkspaceViewState viewState;
  final LibraryWorkspaceBrowserMode browserMode;
  final String? releaseFolderTitleItemId;
  final String query;
  final LibraryLinkedMetadataFilter? linkedMetadataFilter;
  final String? selectedBucket;
  final String? selectedItemId;
  final LibraryQuickView? quickView;
  final LibraryCollectionStatusScope collectionStatusScope;
  final LibraryGroupMode groupMode;
  final List<LibraryBucketScopeFilter> bucketScopeFilters;
  final List<LibrarySeriesBucket>? overrideBuckets;
  final Set<String>? constrainedItemIds;
  final LibraryFilterSelection filterSelection;
  final Map<String, List<String>> customFieldValuesByItem;
  final Map<String, Map<String, String>> customFieldValuesByDefinitionByItem;
  final Set<String> activeLoanOwnedItemIds;
  final LibrarySearchTarget searchTarget;

  @override
  bool operator ==(Object other) {
    return other is LibraryProjectionRequest &&
        signature == other.signature;
  }

  @override
  int get hashCode => signature.hashCode;
}

final libraryProjectionProvider = Provider.autoDispose.family<
    LibraryProjection, LibraryProjectionRequest>((ref, request) {
  return LibraryProjection.fromShelf(
    shelf: request.shelf,
    type: request.type,
    adapter: request.adapter,
    viewState: request.viewState,
    browserMode: request.browserMode,
    releaseFolderTitleItemId: request.releaseFolderTitleItemId,
    query: request.query,
    linkedMetadataFilter: request.linkedMetadataFilter,
    selectedBucket: request.selectedBucket,
    selectedItemId: request.selectedItemId,
    quickView: request.quickView,
    collectionStatusScope: request.collectionStatusScope,
    groupMode: request.groupMode,
    bucketScopeFilters: request.bucketScopeFilters,
    overrideBuckets: request.overrideBuckets,
    constrainedItemIds: request.constrainedItemIds,
    filterSelection: request.filterSelection,
    customFieldValuesByItem: request.customFieldValuesByItem,
    customFieldValuesByDefinitionByItem:
        request.customFieldValuesByDefinitionByItem,
    activeLoanOwnedItemIds: request.activeLoanOwnedItemIds,
    searchTarget: request.searchTarget,
  );
});
