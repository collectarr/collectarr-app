part of 'collection_mutations.dart';

extension CollectionMutationsImport on CollectionMutations {
  Future<int> importRows(List<CollectionCsvRow> rows) async {
    if (rows.isEmpty) {
      return 0;
    }
    final preview = await previewImportRows(rows);
    final resolvedRows = [...preview.resolvedRows, ...preview.conflictRows];
    if (resolvedRows.isEmpty) {
      return 0;
    }
    final db = ref.read(localDatabaseProvider);
    final ownedCache = _ownedCache();
    final trackingCache = _trackingCache();
    final wishlistCache = _wishlistCache();
    final catalogCache = _catalogCache();
    final syncQueue = _syncQueue();
    final catalogItems = await catalogCache.findByIds(resolvedRows.map(
      (row) => row.itemId,
    ));
    final importedCatalogItems = <CatalogItem>[];
    for (final row in resolvedRows) {
      final snapshot = _catalogItemFromCsvRow(
        row,
        existing: catalogItems[row.itemId],
      );
      if (snapshot != null) {
        catalogItems[row.itemId] = snapshot;
        importedCatalogItems.add(snapshot);
      }
    }
    final now = DateTime.now().toUtc();
    final existingWishlist = {
      for (final item in await wishlistCache.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        item.itemId: item,
    };
    final existingOwned = {
      for (final item in await ownedCache.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        item.itemId: item,
    };
    final existingTrackingByOwnedItemId = {
      for (final entry in await trackingCache.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        if (entry.ownedItemId != null) entry.ownedItemId!: entry,
    };
    final activeWishlistItemIds = existingWishlist.keys.toSet();
    final ownedItems = <OwnedItem>[];
    final trackingUpserts = <TrackingEntry>[];
    final trackingDeletes = <TrackingEntry>[];
    final wishlistDeletes = <WishlistItem>[];
    final wishlistUpserts = <WishlistItem>[];
    final syncChanges = <SyncChange>[];
    final snapshotItemIds = <String>{};
    var imported = 0;

    for (final row in resolvedRows) {
      if (!row.isOwned && !row.isWishlisted) {
        continue;
      }
      imported++;
      _addCatalogSnapshotChange(
        syncChanges,
        snapshotItemIds,
        catalogItems[row.itemId],
        now,
      );
      final existingWishlistItem = existingWishlist[row.itemId];
      if (row.isOwned) {
        final ownedItem = _ownedItemFromCsvRow(
          row,
          now,
          existing: existingOwned[row.itemId],
        );
        ownedItems.add(ownedItem);
        syncChanges.add(_syncChangeForOwnedItem(ownedItem, 'upsert', now));
        final trackingEntry = _trackingEntryFromOwnedItem(ownedItem, now);
        final existingTracking = existingTrackingByOwnedItemId[ownedItem.id];
        if (trackingEntry != null) {
          trackingUpserts.add(trackingEntry);
          syncChanges.add(
            _syncChangeForTrackingEntry(trackingEntry, 'upsert', now),
          );
        } else if (existingTracking != null) {
          final deleted = _trackingDeletion(existingTracking, now);
          trackingDeletes.add(deleted);
          syncChanges.add(_syncChangeForTrackingEntry(deleted, 'delete', now));
        }
        if (existingWishlistItem != null &&
            activeWishlistItemIds.contains(row.itemId)) {
          final deleted = existingWishlistItem.copyWith(
            updatedAt: now,
            deletedAt: now,
          );
          wishlistDeletes.add(deleted);
          syncChanges.add(_syncChangeForWishlistItem(deleted, 'delete', now));
          activeWishlistItemIds.remove(row.itemId);
        }
      }
      if (row.isWishlisted && !activeWishlistItemIds.contains(row.itemId)) {
        final wishlistItem = WishlistItem(
          id: _uuid.v4(),

          catalogRef: _catalogRefForItem(
            row.itemId,
            catalogItems[row.itemId],
          ),
          anchorType: PersonalItemAnchorType.item.apiValue,
          createdAt: now,
          updatedAt: now,
        );
        wishlistUpserts.add(wishlistItem);
        syncChanges
            .add(_syncChangeForWishlistItem(wishlistItem, 'upsert', now));
        activeWishlistItemIds.add(row.itemId);
      }
    }

    if (imported == 0) {
      return 0;
    }
    await db.transaction(() async {
      await catalogCache.upsertAll(importedCatalogItems);
      await ownedCache.upsertAll(ownedItems);
      await trackingCache.upsertAll(trackingUpserts);
      for (final entry in trackingDeletes) {
        await trackingCache.markDeleted(entry, now);
      }
      await wishlistCache.markDeletedAll(wishlistDeletes, now);
      await wishlistCache.upsertAll(wishlistUpserts);
      await syncQueue.enqueueAll(syncChanges);
    });

    // Save imported custom field values.
    final cfRepo = CustomFieldRepository(db);
    final cfDefs = await cfRepo.listDefinitions();
    final defsByName = {
      for (final def in cfDefs) def.name.toLowerCase(): def,
    };
    final ownedIdByItemId = {
      for (final o in ownedItems) o.itemId: o.id,
    };
    final cfValuesToSave = <CustomFieldValue>[];
    for (final row in resolvedRows) {
      if (row.customFieldValues.isEmpty || !row.isOwned) continue;
      final ownedId = ownedIdByItemId[row.itemId];
      if (ownedId == null) continue;
      for (final entry in row.customFieldValues.entries) {
        final def = defsByName[entry.key.toLowerCase()];
        if (def == null || entry.value == null) continue;
        cfValuesToSave.add(CustomFieldValue(
          id: _uuid.v4(),
          targetId: ownedId,
          targetScope: CustomFieldTargetScope.ownedCopy,
          catalogRef: _catalogRefForItem(
            row.itemId,
            catalogItems[row.itemId],
          ),
          fieldDefinitionId: def.id,
          value: normalizeCustomFieldInputValue(def, entry.value),
          updatedAt: now,
        ));
      }
    }
    if (cfValuesToSave.isNotEmpty) {
      await cfRepo.upsertValues(cfValuesToSave);
    }

    await _notifyCollectionChanged(wishlistChanged: true);
    return imported;
  }

  Future<CollectionImportPreview> previewImportRows(
    List<CollectionCsvRow> rows,
  ) async {
    final catalog = _catalogCache();
    final resolved = <CollectionCsvRow>[];
    final conflicts = <CollectionCsvRow>[];
    final unresolved = <CollectionCsvRow>[];
    final skipped = <CollectionCsvRow>[];
    final duplicates = <CollectionCsvRow>[];
    final seenItemIds = <String>{};
    final ownedCache = _ownedCache();
    for (final row in rows) {
      if (!row.isOwned && !row.isWishlisted) {
        skipped.add(row);
        continue;
      }
      final resolvedRow = await _resolveCsvRow(row, catalog);
      if (resolvedRow != null) {
        if (!seenItemIds.add(resolvedRow.itemId)) {
          duplicates.add(resolvedRow);
          continue;
        }
        final existingOwned =
            await ownedCache.findActiveByItemIds([resolvedRow.itemId]);
        if (resolvedRow.isOwned && existingOwned.isNotEmpty) {
          conflicts.add(resolvedRow);
        } else {
          resolved.add(resolvedRow);
        }
      } else {
        unresolved.add(row);
      }
    }
    return CollectionImportPreview(
      totalRows: rows.length,
      resolvedRows: resolved,
      conflictRows: conflicts,
      unresolvedRows: unresolved,
      skippedRows: skipped,
      duplicateRows: duplicates,
    );
  }

  Future<CollectionCsvRow?> _resolveCsvRow(
    CollectionCsvRow row,
    CatalogCacheRepository catalog,
  ) async {
    if (row.itemId.trim().isNotEmpty) {
      return row;
    }
    final matched = await _matchCsvRowToCatalog(row, catalog);
    return matched == null ? null : row.copyWith(itemId: matched.id);
  }

  Future<CatalogItem?> _matchCsvRowToCatalog(
    CollectionCsvRow row,
    CatalogCacheRepository catalog,
  ) async {
    final barcode = row.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty) {
      final match = await catalog.findByBarcode(barcode, kind: row.kind);
      if (match != null) {
        return match;
      }
    }
    final title = row.title?.trim();
    if (title == null || title.isEmpty) {
      return null;
    }
    return catalog.findByTitleAndIssue(
      title: title,
      itemNumber: row.itemNumber,
      kind: row.kind,
    );
  }

  OwnedItem _ownedItemFromCsvRow(
    CollectionCsvRow row,
    DateTime now, {
    OwnedItem? existing,
  }) {
    final hasLocationId = row.locationId?.trim().isNotEmpty ?? false;
    return OwnedItem(
      id: existing?.id ?? _uuid.v4(),

      catalogRef: existing?.catalogRef ??
          CatalogEntityRef(
            kind: 'unknown',
            entityType: CatalogEntityType.work,
            id: row.itemId,
          ),
      isDigital: _csvOwnedItemIsDigital(row, existing: existing),
      anchorType: existing?.anchorType,
      editionId: existing?.editionId,
      variantId: existing?.variantId,
      bundleReleaseId: existing?.bundleReleaseId,
      condition: row.condition ?? existing?.condition,
      grade: row.grade ?? existing?.grade,
      purchaseDate: row.purchaseDate ?? existing?.purchaseDate,
      pricePaidCents: row.pricePaidCents ?? existing?.pricePaidCents,
      currency: row.currency ?? existing?.currency,
      personalNotes: row.notes ?? existing?.personalNotes,
      quantity: row.quantity ?? existing?.quantity ?? 1,
      locationId: hasLocationId ? row.locationId : existing?.locationId,
      indexNumber: row.indexNumber ?? existing?.indexNumber,
      coverPriceCents: row.coverPriceCents ?? existing?.coverPriceCents,
      rawOrSlabbed: row.rawOrSlabbed ?? existing?.rawOrSlabbed,
      gradingCompany: row.gradingCompany ?? existing?.gradingCompany,
      graderNotes: row.graderNotes ?? existing?.graderNotes,
      signedBy: row.signedBy ?? existing?.signedBy,
      labelType: row.labelType ?? existing?.labelType,
      certificationNumber:
          row.certificationNumber ?? existing?.certificationNumber,
      keyComic: row.keyComic || (existing?.keyComic ?? false),
      keyReason: row.keyReason ?? existing?.keyReason,
      rating: row.rating ?? existing?.rating,
      readStatus: row.readStatus ?? existing?.readStatus,
      startedAt: row.startedAt ?? existing?.startedAt,
      finishedAt: row.finishedAt ?? existing?.finishedAt,
      tags: row.tags ?? existing?.tags,
      updatedAt: now,
      deletedAt: existing?.deletedAt,
      soldAt: row.soldAt ?? existing?.soldAt,
      sellPriceCents: row.sellPriceCents ?? existing?.sellPriceCents,
      soldTo: row.soldTo ?? existing?.soldTo,
    );
  }

}
