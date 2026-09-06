import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/sidebar/sidebar_bucket_manager_dialog.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';

class LibraryPageBucketCoordinator {
  const LibraryPageBucketCoordinator(this._page);

  final LibraryPageCoordinatorContext _page;

  Future<void> showBucketManagerFlow(
    LibraryProjection projection, {
    required String mode,
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
      onRenameBucket: (currentLabel, nextLabel) => mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: nextLabel,
      ),
      onMergeBucket: (currentLabel, targetLabel) => mutateBucketValues(
        projection,
        mode,
        currentLabel,
        replacement: targetLabel,
      ),
      onDeleteBucket: (currentLabel) =>
          mutateBucketValues(projection, mode, currentLabel),
    );
  }

  Future<int> mutateBucketValues(
    LibraryProjection projection,
    String mode,
    String currentLabel, {
    String? replacement,
  }) async {
    final runtime = _page.type;
    final groupId = runtime.fields.decodeGroupId(mode);
    final groupDefinition = runtime.fields.findGroupDefinition(groupId);
    if (groupDefinition == null || !groupDefinition.supportsBucketManagement) {
      return 0;
    }

    final catalogUpdates = <String, CatalogItem>{};
    final ownedUpdates = <String, UpdateOwnedItemCommand<OwnedDetailsDraft>>{};
    for (final item in projection.allItems) {
      if (genericBucketForItemGroup(item, _page.type, groupId) !=
          currentLabel.trim()) {
        continue;
      }

      final catalogItem = item.source.catalogItem;
      if (catalogItem != null) {
        final updatedCatalog = groupDefinition.bucketValueMutator?.call(
          catalogItem,
          currentLabel,
          replacement: replacement,
        );
        if (updatedCatalog != null) {
          catalogUpdates[catalogItem.id] = updatedCatalog;
        }
      }

      final ownedItem = item.source.ownedItem;
      if (ownedItem != null) {
        final ownedUpdate = groupDefinition.ownedBucketValueMutator?.call(
          ownedItem,
          currentLabel,
          replacement: replacement,
        );
        if (ownedUpdate != null) {
          ownedUpdates.putIfAbsent(
            ownedUpdate.ownedItemId,
            () => ownedUpdate,
          );
        }
      }
    }

    if (catalogUpdates.isEmpty && ownedUpdates.isEmpty) {
      return 0;
    }
    final mutations = _page.ref.read(ownedItemMutationsProvider);
    if (catalogUpdates.isNotEmpty) {
      await mutations.updateCatalogSnapshots(catalogUpdates.values);
    }
    for (final update in ownedUpdates.values) {
      await mutations.updateOwnedItem(
        _page.type.edit.withTypedUpdatePayload(update),
      );
    }
    if (!_page.mounted) {
      return catalogUpdates.length + ownedUpdates.length;
    }
    _page.rebuild(() {
      if (_page.selectedBucket == currentLabel) {
        final nextBucket = replacement?.trim();
        _page.selectedBucket =
            nextBucket == null || nextBucket.isEmpty ? null : nextBucket;
      }
    });
    return catalogUpdates.length + ownedUpdates.length;
  }
}
