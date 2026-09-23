import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/domain/library_facet_row.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

class FacetBuckets {
  const FacetBuckets({
    required this.shelfSignature,
    required this.buckets,
    required this.itemIdsByBucket,
  });

  final String shelfSignature;
  final List<LibraryBucket> buckets;
  final Map<String, Set<String>> itemIdsByBucket;
}

String libraryShelfSignature(Iterable<String> ids) {
  final sorted = ids.toList()..sort();
  return '${sorted.length}:${Object.hashAll(sorted)}';
}

final class LibraryFacetBucketService {
  const LibraryFacetBucketService();

  Future<FacetBuckets> load({
    required ApiClient api,
    required LibraryFacetModule? facets,
    required LibraryFacetIdRuntime facetId,
    required List<LibraryProjectionView> items,
    required Set<String> itemIds,
    required String signature,
    String? allBucketLabel,
  }) async {
    if (facets == null) {
      return FacetBuckets(
        shelfSignature: signature,
        buckets: const [],
        itemIdsByBucket: const {},
      );
    }
    final loader = facets.loadRows;
    final rows = loader != null
        ? await loader(facetId: facetId, itemIds: itemIds, api: api)
        : _localFacetRows(facets, facetId, items);
    final byBucket = _groupFacetRows(rows, itemIds);
    return _buildFacetBuckets(
      signature: signature,
      byBucket: byBucket,
      allBucketLabel: allBucketLabel,
      totalItemCount: itemIds.length,
    );
  }

  static Map<String, Set<String>> _groupFacetRows(
    List<LibraryFacetRow> rows,
    Set<String> validItemIds,
  ) {
    final byBucket = <String, Set<String>>{};
    for (final row in rows) {
      final name = row.name.trim();
      if (name.isEmpty) continue;
      for (final itemId in row.itemIds) {
        final normalizedItemId = itemId.trim();
        if (normalizedItemId.isEmpty ||
            !validItemIds.contains(normalizedItemId)) {
          continue;
        }
        byBucket.putIfAbsent(name, () => <String>{}).add(normalizedItemId);
      }
    }
    return byBucket;
  }

  static FacetBuckets _buildFacetBuckets({
    required String signature,
    required Map<String, Set<String>> byBucket,
    String? allBucketLabel,
    int? totalItemCount,
  }) {
    final sorted = [
      for (final entry in byBucket.entries)
        LibraryBucket(title: entry.key, count: entry.value.length),
    ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    return FacetBuckets(
      shelfSignature: signature,
      buckets: [
        if (allBucketLabel != null)
          LibraryBucket(
            title: allBucketLabel,
            count: totalItemCount ?? 0,
          ),
        ...sorted,
      ],
      itemIdsByBucket: byBucket,
    );
  }

  static List<LibraryFacetRow> _localFacetRows(
    LibraryFacetModule facets,
    LibraryFacetIdRuntime facetId,
    List<LibraryProjectionView> items,
  ) {
    final getFacetValues = facets.getFacetValues;
    if (getFacetValues == null) {
      throw StateError(
        'Facet "${facetId.value}" has no local extractor or remote loader.',
      );
    }
    return [
      for (final item in items)
        for (final value in getFacetValues(item, facetId))
          LibraryFacetRow(name: value, itemIds: [item.node.id]),
    ];
  }
}
