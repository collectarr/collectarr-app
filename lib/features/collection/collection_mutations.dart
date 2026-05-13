import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/collection_csv.dart';
import 'package:collectarr_app/features/collection/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/shelf_controller.dart';
import 'package:collectarr_app/features/collection/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CollectionMutations {
  CollectionMutations(this.ref);

  final Ref ref;
  final Uuid _uuid = const Uuid();

  Future<void> addItem(
    String itemId, {
    String? editionId,
    String? variantId,
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int quantity = 1,
    String? storageBox,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    bool keyComic = false,
    String? keyReason,
    int? rating,
    String? readStatus,
    String? tags,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final ownedItem = OwnedItem(
      id: _uuid.v4(),
      itemId: itemId,
      editionId: editionId,
      variantId: variantId,
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      quantity: quantity,
      storageBox: storageBox,
      indexNumber: indexNumber,
      coverPriceCents: coverPriceCents,
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      graderNotes: graderNotes,
      signedBy: signedBy,
      keyComic: keyComic,
      keyReason: keyReason,
      rating: rating,
      readStatus: readStatus,
      tags: tags,
      updatedAt: now,
    );
    await _ownedCache().upsert(ownedItem);
    await _enqueueOwnedItem(ownedItem, 'upsert', now);
    final wishlistItem = await _wishlistCache().findActiveByItemId(itemId);
    if (wishlistItem != null) {
      await _wishlistCache().markDeleted(wishlistItem, now);
      await _enqueueWishlistItem(
        wishlistItem.copyWith(updatedAt: now, deletedAt: now),
        'delete',
        now,
      );
    }
    if (notify) {
      await _notifyCollectionChanged(wishlistChanged: wishlistItem != null);
    }
  }

  Future<void> updateItem(
    OwnedItem item, {
    String? condition,
    String? grade,
    DateTime? purchaseDate,
    int? pricePaidCents,
    String? currency,
    String? personalNotes,
    int? quantity,
    String? storageBox,
    int? indexNumber,
    int? coverPriceCents,
    String? rawOrSlabbed,
    String? gradingCompany,
    String? graderNotes,
    String? signedBy,
    bool? keyComic,
    String? keyReason,
    int? rating,
    String? readStatus,
    String? tags,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final updated = OwnedItem(
      id: item.id,
      itemId: item.itemId,
      editionId: item.editionId,
      variantId: item.variantId,
      condition: condition,
      grade: grade,
      purchaseDate: purchaseDate,
      pricePaidCents: pricePaidCents,
      currency: currency,
      personalNotes: personalNotes,
      quantity: quantity ?? item.quantity,
      storageBox: storageBox,
      indexNumber: indexNumber,
      coverPriceCents: coverPriceCents,
      rawOrSlabbed: rawOrSlabbed,
      gradingCompany: gradingCompany,
      graderNotes: graderNotes,
      signedBy: signedBy,
      keyComic: keyComic ?? item.keyComic,
      keyReason: keyReason,
      rating: rating,
      readStatus: readStatus,
      tags: tags,
      updatedAt: now,
      deletedAt: item.deletedAt,
    );
    await _ownedCache().upsert(updated);
    await _enqueueOwnedItem(updated, 'upsert', now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> removeItem(OwnedItem item, {bool notify = true}) async {
    final now = DateTime.now().toUtc();
    await _ownedCache().markDeleted(item, now);
    await _enqueueOwnedItem(
        item.copyWith(updatedAt: now, deletedAt: now), 'delete', now);
    if (notify) {
      await _notifyCollectionChanged();
    }
  }

  Future<void> addToWishlist(
    String itemId, {
    String? editionId,
    String? variantId,
    bool notify = true,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing == null) {
      final item = WishlistItem(
        id: _uuid.v4(),
        itemId: itemId,
        editionId: editionId,
        variantId: variantId,
        createdAt: now,
        updatedAt: now,
      );
      await _wishlistCache().upsert(item);
      await _enqueueWishlistItem(item, 'upsert', now);
    }
    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<void> removeFromWishlist(String itemId, {bool notify = true}) async {
    final now = DateTime.now().toUtc();
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing != null) {
      await _wishlistCache().markDeleted(existing, now);
      await _enqueueWishlistItem(
        existing.copyWith(updatedAt: now, deletedAt: now),
        'delete',
        now,
      );
    }
    if (notify) {
      await _notifyWishlistChanged();
    }
  }

  Future<void> toggleWishlist(String itemId) async {
    final existing = await _wishlistCache().findActiveByItemId(itemId);
    if (existing == null) {
      await addToWishlist(itemId);
    } else {
      await removeFromWishlist(itemId);
    }
  }

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
    final wishlistCache = _wishlistCache();
    final syncQueue = _syncQueue();
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
    final activeWishlistItemIds = existingWishlist.keys.toSet();
    final ownedItems = <OwnedItem>[];
    final wishlistDeletes = <WishlistItem>[];
    final wishlistUpserts = <WishlistItem>[];
    final syncChanges = <SyncChange>[];
    var imported = 0;

    for (final row in resolvedRows) {
      if (!row.isOwned && !row.isWishlisted) {
        continue;
      }
      imported++;
      final existingWishlistItem = existingWishlist[row.itemId];
      if (row.isOwned) {
        final ownedItem = _ownedItemFromCsvRow(
          row,
          now,
          existing: existingOwned[row.itemId],
        );
        ownedItems.add(ownedItem);
        syncChanges.add(_syncChangeForOwnedItem(ownedItem, 'upsert', now));
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
          itemId: row.itemId,
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
      await ownedCache.upsertAll(ownedItems);
      await wishlistCache.markDeletedAll(wishlistDeletes, now);
      await wishlistCache.upsertAll(wishlistUpserts);
      await syncQueue.enqueueAll(syncChanges);
    });
    await _notifyCollectionChanged(wishlistChanged: true);
    return imported;
  }

  Future<CollectionImportPreview> previewImportRows(
    List<CollectionCsvRow> rows,
  ) async {
    final catalog = CatalogCacheRepository(ref.read(localDatabaseProvider));
    final resolved = <CollectionCsvRow>[];
    final conflicts = <CollectionCsvRow>[];
    final unresolved = <CollectionCsvRow>[];
    final skipped = <CollectionCsvRow>[];
    final ownedCache = _ownedCache();
    for (final row in rows) {
      if (!row.isOwned && !row.isWishlisted) {
        skipped.add(row);
        continue;
      }
      final resolvedRow = await _resolveCsvRow(row, catalog);
      if (resolvedRow != null) {
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
      final match = await catalog.findByBarcode(barcode);
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
    );
  }

  OwnedItem _ownedItemFromCsvRow(
    CollectionCsvRow row,
    DateTime now, {
    OwnedItem? existing,
  }) {
    return OwnedItem(
      id: existing?.id ?? _uuid.v4(),
      itemId: row.itemId,
      editionId: existing?.editionId,
      variantId: existing?.variantId,
      condition: row.condition ?? existing?.condition,
      grade: row.grade ?? existing?.grade,
      purchaseDate: row.purchaseDate ?? existing?.purchaseDate,
      pricePaidCents: row.pricePaidCents ?? existing?.pricePaidCents,
      currency: row.currency ?? existing?.currency,
      personalNotes: row.notes ?? existing?.personalNotes,
      quantity: row.quantity ?? existing?.quantity ?? 1,
      storageBox: row.storageBox ?? existing?.storageBox,
      indexNumber: row.indexNumber ?? existing?.indexNumber,
      coverPriceCents: row.coverPriceCents ?? existing?.coverPriceCents,
      rawOrSlabbed: row.rawOrSlabbed ?? existing?.rawOrSlabbed,
      gradingCompany: row.gradingCompany ?? existing?.gradingCompany,
      graderNotes: row.graderNotes ?? existing?.graderNotes,
      signedBy: row.signedBy ?? existing?.signedBy,
      keyComic: row.keyComic || (existing?.keyComic ?? false),
      keyReason: row.keyReason ?? existing?.keyReason,
      rating: row.rating ?? existing?.rating,
      readStatus: row.readStatus ?? existing?.readStatus,
      tags: row.tags ?? existing?.tags,
      updatedAt: now,
      deletedAt: existing?.deletedAt,
    );
  }

  SyncChange _syncChangeForOwnedItem(
    OwnedItem item,
    String action,
    DateTime changedAt,
  ) {
    return SyncChange(
      id: _uuid.v4(),
      entityType: 'owned_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: changedAt,
    );
  }

  SyncChange _syncChangeForWishlistItem(
    WishlistItem item,
    String action,
    DateTime changedAt,
  ) {
    return SyncChange(
      id: _uuid.v4(),
      entityType: 'wishlist_item',
      entityId: item.id,
      action: action,
      payload: item.toSyncPayload(),
      clientChangedAt: changedAt,
    );
  }

  Future<void> _notifyCollectionChanged({bool wishlistChanged = false}) async {
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    ref.invalidate(collectionProvider);
    if (wishlistChanged) {
      ref.invalidate(wishlistIdsProvider);
      ref.invalidate(wishlistProvider);
    }
    ref.invalidate(shelfProvider);
  }

  Future<void> _notifyWishlistChanged() async {
    await ref.read(syncControllerProvider.notifier).refreshPendingCount();
    ref.invalidate(wishlistIdsProvider);
    ref.invalidate(wishlistProvider);
    ref.invalidate(shelfProvider);
  }

  OwnedItemsCacheRepository _ownedCache() {
    return OwnedItemsCacheRepository(ref.read(localDatabaseProvider));
  }

  WishlistItemsCacheRepository _wishlistCache() {
    return WishlistItemsCacheRepository(ref.read(localDatabaseProvider));
  }

  SyncQueueRepository _syncQueue() {
    return SyncQueueRepository(ref.read(localDatabaseProvider));
  }

  Future<void> _enqueueOwnedItem(
      OwnedItem item, String action, DateTime changedAt) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'owned_item',
        entityId: item.id,
        action: action,
        payload: item.toSyncPayload(),
        clientChangedAt: changedAt,
      ),
    );
  }

  Future<void> _enqueueWishlistItem(
      WishlistItem item, String action, DateTime changedAt) {
    return _syncQueue().enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: 'wishlist_item',
        entityId: item.id,
        action: action,
        payload: item.toSyncPayload(),
        clientChangedAt: changedAt,
      ),
    );
  }
}

class CollectionImportPreview {
  const CollectionImportPreview({
    required this.totalRows,
    required this.resolvedRows,
    this.conflictRows = const [],
    required this.unresolvedRows,
    required this.skippedRows,
  });

  final int totalRows;
  final List<CollectionCsvRow> resolvedRows;
  final List<CollectionCsvRow> conflictRows;
  final List<CollectionCsvRow> unresolvedRows;
  final List<CollectionCsvRow> skippedRows;

  int get resolvedCount => resolvedRows.length;
  int get conflictCount => conflictRows.length;
  int get unresolvedCount => unresolvedRows.length;
  int get skippedCount => skippedRows.length;
  bool get hasImportableRows => resolvedRows.isNotEmpty;
}

final collectionMutationsProvider = Provider<CollectionMutations>((ref) {
  return CollectionMutations(ref);
});
