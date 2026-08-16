import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'library_search_index.dart';

class LibraryProjectionIndex {
  final LibrarySearchIndex _searchIndex = LibrarySearchIndex();
  final Map<String, Map<String, String>> _itemGroupBucketCache = {};
  int extractorCallCount = 0;

  LibrarySearchDocument getSearchDocument(
    LibraryProjectionItem item, [
    Map<String, List<String>> customFieldValuesByItem = const {},
  ]) {
    return _searchIndex.getOrBuild(item, customFieldValuesByItem);
  }

  String getGroupBucket(
    LibraryProjectionItem item,
    String groupMode,
    String Function(LibraryProjectionItem item, String groupMode) extractor,
  ) {
    final itemCache = _itemGroupBucketCache.putIfAbsent(item.node.id, () => {});
    final existing = itemCache[groupMode];
    if (existing != null) return existing;

    extractorCallCount++;
    final calculated = extractor(item, groupMode);
    itemCache[groupMode] = calculated;
    return calculated;
  }

  void clear() {
    _searchIndex.clear();
    _itemGroupBucketCache.clear();
    extractorCallCount = 0;
  }
}
