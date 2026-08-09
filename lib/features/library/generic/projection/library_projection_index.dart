import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'library_search_index.dart';

class LibraryProjectionIndex {
  final LibrarySearchIndex _searchIndex = LibrarySearchIndex();
  final Map<String, Map<String, String>> _itemGroupBucketCache = {};
  int extractorCallCount = 0;

  LibrarySearchDocument getSearchDocument(
    LibraryProjectionItem item,
    String Function() textSupplier,
  ) {
    return _searchIndex.getOrBuild(item, textSupplier);
  }

  String getGroupBucket(
    LibraryProjectionItem item,
    String groupMode,
    String Function(LibraryProjectionItem item, String groupMode) extractor,
  ) {
    final itemCache = _itemGroupBucketCache.putIfAbsent(item.node.id, () => {});
    return itemCache.putIfAbsent(groupMode, () {
      extractorCallCount++;
      return extractor(item, groupMode);
    });
  }

  void clear() {
    _searchIndex.clear();
    _itemGroupBucketCache.clear();
    extractorCallCount = 0;
  }
}
