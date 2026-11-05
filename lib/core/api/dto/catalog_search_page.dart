/// A page returned by Core's flattened Catalog Item search endpoint.
final class CatalogSearchPage {
  const CatalogSearchPage({
    required this.items,
    required this.nextOffset,
    required this.hasMore,
    this.total,
  });

  final List<Map<String, dynamic>> items;
  final int? nextOffset;
  final bool hasMore;

  /// Every match, when the search asked for it.
  final int? total;

  factory CatalogSearchPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawNextOffset = json['next_offset'];
    final rawHasMore = json['has_more'];
    final rawTotal = json['total'];
    if (rawItems is! List ||
        (rawNextOffset != null && rawNextOffset is! int) ||
        rawHasMore is! bool ||
        (rawTotal != null && rawTotal is! int)) {
      throw const FormatException('Invalid Catalog Item search page.');
    }
    return CatalogSearchPage(
      total: rawTotal as int?,
      items: [
        for (final item in rawItems)
          if (item is Map<String, dynamic>)
            item
          else if (item is Map)
            Map<String, dynamic>.from(item)
          else
            throw const FormatException(
              'Catalog Item search page contains an invalid item.',
            ),
      ],
      nextOffset: rawNextOffset as int?,
      hasMore: rawHasMore,
    );
  }
}
