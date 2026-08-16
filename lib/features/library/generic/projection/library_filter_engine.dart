import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/generic/quick_view.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'library_projection_query.dart';
import 'library_search_index.dart';

class LibraryFilterEngine {
  const LibraryFilterEngine();

  bool matches({
    required LibraryProjectionItem item,
    required LibraryProjectionQuery query,
    required LibrarySearchDocument searchDoc,
    required LibraryMediaAdapter adapter,
    Set<String> activeLoanOwnedItemIds = const {},
    Map<String, Map<String, String>> customFieldValuesByDefinitionByItem =
        const {},
  }) {
    final normalizedQuery = query.searchQuery.trim().toLowerCase();
    if (!searchDoc.matches(normalizedQuery)) {
      return false;
    }
    if (query.constrainedItemIds != null &&
        !query.constrainedItemIds!.contains(item.node.id)) {
      return false;
    }
    if (!_matchesStatus(item, query.collectionStatusScope)) {
      return false;
    }
    if (!_matchesQuickView(item, query.quickView)) {
      return false;
    }
    if (!_matchesLinkedMetadata(item, query.linkedMetadataFilter, adapter)) {
      return false;
    }
    return true;
  }

  bool _matchesStatus(
    LibraryProjectionItem item,
    LibraryCollectionStatusScope scope,
  ) {
    return switch (scope) {
      LibraryCollectionStatusScope.all => true,
      LibraryCollectionStatusScope.inCollection => item.source.isOwned,
      LibraryCollectionStatusScope.wishList => item.source.isWishlisted,
      LibraryCollectionStatusScope.forSale ||
      LibraryCollectionStatusScope.onOrder ||
      LibraryCollectionStatusScope.sold ||
      LibraryCollectionStatusScope.notInCollection =>
        true,
    };
  }

  bool _matchesQuickView(
    LibraryProjectionItem item,
    LibraryQuickView? quickView,
  ) {
    if (quickView == null) return true;
    return switch (quickView) {
      LibraryQuickView.owned => item.source.isOwned,
      LibraryQuickView.wishlist => item.source.isWishlisted,
      LibraryQuickView.missingCovers => true,
      LibraryQuickView.missingMetadata => true,
      LibraryQuickView.missingGrade => true,
    };
  }

  bool _matchesLinkedMetadata(
    LibraryProjectionItem item,
    LibraryLinkedMetadataFilter? linkedFilter,
    LibraryMediaAdapter adapter,
  ) {
    if (linkedFilter == null) return true;
    return true;
  }
}
