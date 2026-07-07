part of 'collection_mutations.dart';

extension CollectionMutationsWishlist on CollectionMutations {
  Future<void> addToWishlist(
    String itemId, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final catalogItem = await _catalogCache().findById(itemId);
    final existing = await _wishlistCache().findActiveByItemAnchor(
      itemId,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (existing == null) {
      final normalizedAnchorType = _normalizedPersonalAnchorType(
        anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
      final item = WishlistItem(
        id: _uuid.v4(),
        catalogRef: _catalogRefForItem(
          itemId,
          catalogItem,
          anchorType: normalizedAnchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
        ),
        anchorType: normalizedAnchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
        createdAt: now,
        updatedAt: now,
      );
      await _wishlistCache().upsert(item);
      await _enqueueWishlistItem(item, 'upsert', now);
      await _enqueueCatalogSnapshotForItemId(itemId, now);
    }
    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<void> addLocalOnlyWishlistItem(
    CatalogItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    await _catalogCache().upsertAll([item]);
    final existing = await _wishlistCache().findActiveByItemAnchor(
      item.id,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (existing == null) {
      final normalizedAnchorType = _normalizedPersonalAnchorType(
        anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
      await _wishlistCache().upsert(
        WishlistItem(
          id: _uuid.v4(),
          catalogRef: _catalogRefForItem(
            item.id,
            item,
            anchorType: normalizedAnchorType,
            editionId: editionId,
            variantId: variantId,
            bundleReleaseId: bundleReleaseId,
          ),
          anchorType: normalizedAnchorType,
          editionId: editionId,
          variantId: variantId,
          bundleReleaseId: bundleReleaseId,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<int> promoteLocalOnlyItemToCatalog(
    String localItemId,
    CatalogItem item, {
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final localTrackingEntries =
        await _trackingCache().findActiveByItemIds([localItemId]);
    final localWishlistItems =
        await _wishlistCache().findActiveByItemIds([localItemId]);
    final localTrackingUnits =
        await _trackingUnitsCache().findActiveByItemIds([localItemId]);
    if (localTrackingEntries.isEmpty &&
        localWishlistItems.isEmpty &&
        localTrackingUnits.isEmpty) {
      return 0;
    }

    final targetTrackingEntries =
        await _trackingCache().findActiveByItemIds([item.id]);
    final targetWishlistItems =
        await _wishlistCache().findActiveByItemIds([item.id]);
    final trackingUpserts = <TrackingEntry>[];
    final trackingDeletes = <TrackingEntry>[];
    final wishlistUpserts = <WishlistItem>[];
    final wishlistDeletes = <WishlistItem>[];
    final syncChanges = <SyncChange>[];

    for (final localEntry
        in localTrackingEntries.where((entry) => entry.ownedItemId == null)) {
      TrackingEntry? targetEntry;
      for (final candidate in targetTrackingEntries) {
        if (candidate.ownedItemId != null) {
          continue;
        }
        if (candidate.sourceTypeApiValue == localEntry.sourceTypeApiValue) {
          targetEntry = candidate;
          break;
        }
      }
      if (targetEntry != null) {
        final merged = _mergeTrackingEntryForPromotion(
          targetEntry,
          localEntry,
          itemId: item.id,
          changedAt: now,
        );
        trackingUpserts.add(merged);
        syncChanges.add(_syncChangeForTrackingEntry(merged, 'upsert', now));
        trackingDeletes.add(_trackingDeletion(localEntry, now));
      } else {
        final promoted = localEntry.copyWith(
            catalogRef: _catalogRefForItem(item.id, item),
          updatedAt: now,
          deletedAt: null,
        );
        trackingUpserts.add(promoted);
        syncChanges.add(_syncChangeForTrackingEntry(promoted, 'upsert', now));
      }
    }

    for (final localWishlist in localWishlistItems) {
      final targetWishlistItem = _findMatchingWishlistItem(
        targetWishlistItems,
        localWishlist,
      );
      if (targetWishlistItem != null) {
        final merged = _mergeWishlistItemForPromotion(
          targetWishlistItem,
          localWishlist,
          itemId: item.id,
          changedAt: now,
        );
        wishlistUpserts.add(merged);
        syncChanges.add(_syncChangeForWishlistItem(merged, 'upsert', now));
        wishlistDeletes
            .add(localWishlist.copyWith(updatedAt: now, deletedAt: now));
      } else {
        final promoted = localWishlist.copyWith(
          catalogRef: _catalogRefForItem(item.id, item),
          updatedAt: now,
          deletedAt: null,
        );
        wishlistUpserts.add(promoted);
        syncChanges.add(_syncChangeForWishlistItem(promoted, 'upsert', now));
      }
    }

    final trackingUnitUpserts = <TrackingUnit>[];
    final trackingUnitDeletes = <TrackingUnit>[];
    for (final localUnit in localTrackingUnits) {
      final newUnitId = _trackingUnitIdForEpisode(
        item.id,
        seasonNumber: localUnit.seasonNumber ?? 0,
        episodeNumber: localUnit.episodeNumber ?? 0,
      );
      final targetRef = localUnit.unitType == TrackingUnitType.episode
          ? _episodeTrackingRef(
              CatalogEntityRef(kind: item.kind, entityType: CatalogEntityType.work, id: item.id),
              seasonNumber: localUnit.seasonNumber ?? 0,
              episodeNumber: localUnit.episodeNumber ?? 0,
            )
          : CatalogEntityRef(
              kind: item.kind,
              entityType: CatalogEntityType.work,
              id: item.id,
            );
      trackingUnitUpserts.add(TrackingUnit(
        id: newUnitId,
        targetRef: targetRef,
        trackingEntryId: localUnit.trackingEntryId,
        ownedItemId: localUnit.ownedItemId,
        editionId: localUnit.editionId,
        variantId: localUnit.variantId,
        bundleReleaseId: localUnit.bundleReleaseId,
        unitType: localUnit.unitType,
        seasonNumber: localUnit.seasonNumber,
        episodeNumber: localUnit.episodeNumber,
        completedAt: localUnit.completedAt,
        updatedAt: now,
      ));
      trackingUnitDeletes.add(localUnit);
    }

    await _catalogCache().upsertAll([item]);
    _addCatalogSnapshotChange(syncChanges, <String>{}, item, now);
    await _trackingCache().upsertAll(trackingUpserts);
    for (final deleted in trackingDeletes) {
      await _trackingCache().markDeleted(deleted, now);
    }
    await _wishlistCache().upsertAll(wishlistUpserts);
    await _wishlistCache().markDeletedAll(wishlistDeletes, now);
    await _trackingUnitsCache().upsertAll(trackingUnitUpserts);
    for (final deleted in trackingUnitDeletes) {
      await _trackingUnitsCache().markDeleted(deleted, now);
    }
    await _syncQueue().enqueueAll(syncChanges);
    if (notify) {
      await _notifyCollectionChanged(
          wishlistChanged: localWishlistItems.isNotEmpty);
    }
    return localTrackingEntries.length +
        localWishlistItems.length +
        localTrackingUnits.length;
  }

  Future<WishlistItem> updateWishlistItem(
    WishlistItem item, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    int? targetPriceCents,
    String? currency,
    String? notes,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final normalizedAnchorType = _normalizedPersonalAnchorType(
      anchorType ?? item.anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      fallbackEditionId: item.editionId,
      fallbackVariantId: item.variantId,
      fallbackBundleReleaseId: item.bundleReleaseId,
    );
    final updated = WishlistItem(
      id: item.id,
      catalogRef: item.catalogRef,
      anchorType: normalizedAnchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
      targetPriceCents: targetPriceCents,
      currency: currency,
      notes: notes,
      createdAt: item.createdAt,
      updatedAt: now,
      deletedAt: item.deletedAt,
    );
    await _wishlistCache().upsert(updated);
    await _enqueueWishlistItem(updated, 'upsert', now);
    await _enqueueCatalogSnapshotForItemId(item.itemId, now);
    if (notify) {
      await _notifyWishlistChanged();
    }
    return updated;
  }

  Future<void> removeFromWishlist(
    String itemId, {
    String? wishlistItemId,
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistItemsForMutation(
      itemId,
      wishlistItemId: wishlistItemId,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    for (final item in existing) {
      await _wishlistCache().markDeleted(item, now);
      await _enqueueWishlistItem(
        item.copyWith(updatedAt: now, deletedAt: now),
        'delete',
        now,
      );
    }
    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<void> toggleWishlist(
    String itemId, {
    String? anchorType,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
  }) async {
    final existing = await _wishlistCache().findActiveByItemAnchor(
      itemId,
      anchorType: anchorType,
      editionId: editionId,
      variantId: variantId,
      bundleReleaseId: bundleReleaseId,
    );
    if (existing == null) {
      await addToWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    } else {
      await removeFromWishlist(
        itemId,
        anchorType: anchorType,
        editionId: editionId,
        variantId: variantId,
        bundleReleaseId: bundleReleaseId,
      );
    }
  }

}
