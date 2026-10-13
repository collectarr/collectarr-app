/// A page returned by Core's flattened Catalog Item search endpoint.
final class CatalogSearchPage {
  const CatalogSearchPage({
    required this.items,
    required this.nextOffset,
    required this.hasMore,
  });

  final List<Map<String, dynamic>> items;
  final int? nextOffset;
  final bool hasMore;

  factory CatalogSearchPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawNextOffset = json['next_offset'];
    final rawHasMore = json['has_more'];
    if (rawItems is! List ||
        (rawNextOffset != null && rawNextOffset is! int) ||
        rawHasMore is! bool) {
      throw const FormatException('Invalid Catalog Item search page.');
    }
    return CatalogSearchPage(
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
