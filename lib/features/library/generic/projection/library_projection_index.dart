import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'library_search_index.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

class LibraryProjectionIndex {
  final LibrarySearchIndex _searchIndex = LibrarySearchIndex();
  final Map<String, Map<LibraryGroupIdRuntime, String>> _itemGroupBucketCache =
      {};
  int extractorCallCount = 0;

  LibrarySearchDocument getSearchDocument(
    LibraryProjectionItem item, [
    Map<String, List<String>> customFieldValuesByItem = const {},
  ]) {
    return _searchIndex.getOrBuild(item, customFieldValuesByItem);
  }

  String getGroupBucket(
    LibraryProjectionItem item,
    LibraryGroupIdRuntime groupId,
    String Function(LibraryProjectionItem item, LibraryGroupIdRuntime groupId)
        extractor,
  ) {
    final itemCache = _itemGroupBucketCache.putIfAbsent(item.node.id, () => {});
    final existing = itemCache[groupId];
    if (existing != null) return existing;

    extractorCallCount++;
    final calculated = extractor(item, groupId);
    itemCache[groupId] = calculated;
    return calculated;
  }

  void clear() {
    _searchIndex.clear();
    _itemGroupBucketCache.clear();
    extractorCallCount = 0;
  }
}
