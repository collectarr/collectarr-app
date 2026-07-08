import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';

class LibraryPageBucketCoordinator {
  const LibraryPageBucketCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  Future<void> showBucketManagerFlow(
    LibraryProjection projection, {
    required LibraryGroupMode mode,
  }) async {
    final allBucketLabel = genericAllBucketLabel(_page.type);
    final entries = [
      for (final bucket in projection.buckets)
        if (bucket.title != allBucketLabel)
        LibraryBucketManagerEntry(
          label: bucket.title,
          count: bucket.count,
        ),
    ];
    if (entries.isEmpty) {
      return;
    }
    await showLibraryBucketManagerDialog(
      context: _page.context,
      type: _page.type,
      groupMode: mode,
      accent: _page.accent,
      entries: entries,
      onRenameBucket: (currentLabel, nextLabel) => _mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: nextLabel,
      ),
      onMergeBucket: (currentLabel, targetLabel) => _mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: targetLabel,
      ),
      onDeleteBucket: (currentLabel) =>
          _mutateBucketValues(projection, mode, currentLabel),
    );
  }

  Future<int> _mutateBucketValues(
    LibraryProjection projection,
    LibraryGroupMode mode,
    String currentLabel, {
    String? replacement,
  }) async {
    final updates = <CatalogItem>[];
    for (final item in projection.allItems) {
      final catalogItem = item.source.catalogItem;
      if (catalogItem == null ||
          genericBucketForItemMode(item, _page.type, mode) != currentLabel) {
        continue;
      }
      final updated = replacement == null
          ? deleteLibraryGroupBucketValue(catalogItem, mode, currentLabel)
          : renameLibraryGroupBucketValue(
              catalogItem,
              mode,
              currentLabel,
              replacement,
            );
      if (updated != null) {
        updates.add(updated);
      }
    }
    if (updates.isEmpty) {
      return 0;
    }
    final mutations = _page.ref.read(collectionMutationsProvider);
    await mutations.updateCatalogSnapshots(updates);
    if (!_page.mounted) {
      return updates.length;
    }
    _page.rebuild(() {
      if (_page.selectedBucket == currentLabel) {
        final nextBucket = replacement?.trim();
        _page.selectedBucket =
            nextBucket == null || nextBucket.isEmpty ? null : nextBucket;
      }
    });
    return updates.length;
  }
}
