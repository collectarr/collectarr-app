import 'package:collectarr_app/core/api/api_client.dart';
import 'package:collectarr_app/features/library/config/library_facet_module.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_bucket_sidebar.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_group_values.dart';

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

/// Facet caches depend on current metadata as well as shelf membership.
/// Metadata identity is stable within a shelf snapshot and changes on reload.
String libraryFacetContentSignature(
    Iterable<({String id, DateTime updatedAt, Object? metadata})> items) {
  final sorted = items.toList()..sort((a, b) => a.id.compareTo(b.id));
  return '${sorted.length}:${Object.hashAll(sorted.map((item) => (
        item.id,
        item.updatedAt.microsecondsSinceEpoch,
        identityHashCode(item.metadata),
      )))}';
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
    final assignedItemIds = {
      for (final ids in byBucket.values) ...ids,
    };
    final emptyItemIds = validItemIds.difference(assignedItemIds);
    if (emptyItemIds.isNotEmpty) {
      byBucket
          .putIfAbsent(libraryEmptyGroupLabel, () => <String>{})
          .addAll(emptyItemIds);
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
    ]..sort((a, b) {
        if (a.title == libraryEmptyGroupLabel) return -1;
        if (b.title == libraryEmptyGroupLabel) return 1;
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

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
          LibraryFacetRow(name: value, itemIds: [item.target.id]),
    ];
  }
}
