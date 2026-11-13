import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'search_index.dart';
import 'package:collectarr_app/features/library/workspace/schema/identifier_types.dart';

class LibraryProjectionIndex {
  final LibrarySearchIndex _searchIndex = LibrarySearchIndex();
  final Map<String, Map<LibraryGroupIdRuntime, String>> _itemGroupBucketCache =
      {};
  final Map<String, Map<LibraryGroupIdRuntime, List<String>>>
      _itemGroupBucketsCache = {};
  int extractorCallCount = 0;

  List<String> getGroupBuckets(
      LibraryProjectionItem item,
      LibraryGroupIdRuntime groupId,
      List<String> Function(LibraryProjectionItem, LibraryGroupIdRuntime)
          extractor) {
    final cache = _itemGroupBucketsCache.putIfAbsent(item.target.id, () => {});
    return cache.putIfAbsent(groupId, () {
      extractorCallCount++;
      return extractor(item, groupId);
    });
  }

  LibrarySearchDocument? existingSearchDocument(
    LibraryProjectionItem item,
    Map<String, List<String>> customFieldValuesByItem,
  ) =>
      _searchIndex.existing(item, customFieldValuesByItem);

  LibrarySearchDocument getSearchDocument(
    LibraryProjectionItem item, [
    Map<String, List<String>> customFieldValuesByItem = const {},
    Iterable<String> searchFieldValues = const [],
    Iterable<String> containedSearchValues = const [],
  ]) {
    return _searchIndex.getOrBuild(
      item,
      customFieldValuesByItem,
      searchFieldValues,
      containedSearchValues,
    );
  }

  String getGroupBucket(
    LibraryProjectionItem item,
    LibraryGroupIdRuntime groupId,
    String Function(LibraryProjectionItem item, LibraryGroupIdRuntime groupId)
        extractor,
  ) {
    final itemCache =
        _itemGroupBucketCache.putIfAbsent(item.target.id, () => {});
    final existing = itemCache[groupId];
    if (existing != null) return existing;

    extractorCallCount++;
    final calculated = extractor(item, groupId);
    itemCache[groupId] = calculated;
    return calculated;
  }

  void clear() {
    _itemGroupBucketCache.clear();
    _itemGroupBucketsCache.clear();
    extractorCallCount = 0;
  }
}
