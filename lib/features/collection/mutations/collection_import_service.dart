import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class CollectionImportService {
  const CollectionImportService({
    required this.ownedItems,
    required this.wishlist,
    required this.catalogCache,
    required this.trackingEntries,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsCacheRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final LibraryCatalogRepository catalogCache;
  final TrackingEntriesCacheRepository trackingEntries;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<int> importRows(
    List<CollectionCsvRow> rows, {
    MutationOrigin origin = MutationOrigin.fileImport,
  }) async {
    if (rows.isEmpty) return 0;

    final preview = await previewImportRows(rows);
    final resolvedRows = [...preview.resolvedRows, ...preview.conflictRows];
    if (resolvedRows.isEmpty) return 0;

    final catalogItems = Map<String, dynamic>.from(await catalogCache.findByIds(
      resolvedRows.map((row) => row.itemId),
    ));
    final importedCatalogItems = <dynamic>[];
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
      for (final item in await wishlist.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        item.itemId: item,
    };
    final existingOwned = {
      for (final item in await ownedItems.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        item.itemId: item,
    };

    final activeWishlistItemIds = existingWishlist.keys.toSet();
    final ownedItemsList = <OwnedItem>[];
    final wishlistDeletes = <WishlistItem>[];
    final wishlistUpserts = <WishlistItem>[];
    final syncChanges = <SyncChange>[];
    final snapshotItemIds = <String>{};
    var imported = 0;

    for (final row in resolvedRows) {
      if (!row.isOwned && !row.isWishlisted) continue;

      imported++;
      final catItem = catalogItems[row.itemId];
      final metadataItem = typedCatalogItemFromUnknown(catItem);
      final catItemId = metadataItem?.id;
      final catItemKind = metadataItem?.kind;
      if (catItemId != null && !snapshotItemIds.contains(catItemId)) {
        snapshotItemIds.add(catItemId);
        syncChanges.add(
          SyncChange(
            id: 'catalog:$catItemId:upsert:${now.millisecondsSinceEpoch}',
            entityType: 'catalog_item',
            entityId: catItemId,
            action: 'upsert',
            payload: {'id': catItemId},
            clientChangedAt: now,
          ),
        );
      }

      final existingWishlistItem = existingWishlist[row.itemId];
      if (row.isOwned) {
        final ownedItem = _ownedItemFromCsvRow(
          row,
          now,
          existing: existingOwned[row.itemId],
        );
        ownedItemsList.add(ownedItem);
        syncChanges.add(
          SyncChange(
            id: 'owned_item:${ownedItem.id}:upsert:${now.millisecondsSinceEpoch}',
            entityType: 'owned_item',
            entityId: ownedItem.id,
            action: 'upsert',
            payload: ownedItem.toSyncPayload(),
            clientChangedAt: now,
          ),
        );

        if (existingWishlistItem != null &&
            activeWishlistItemIds.contains(row.itemId)) {
          final deleted = existingWishlistItem.copyWith(
            updatedAt: now,
            deletedAt: now,
          );
          wishlistDeletes.add(deleted);
          syncChanges.add(
            SyncChange(
              id: 'wishlist:${deleted.id}:delete:${now.millisecondsSinceEpoch}',
              entityType: 'wishlist_item',
              entityId: deleted.id,
              action: 'delete',
              payload: deleted.toSyncPayload(),
              clientChangedAt: now,
            ),
          );
          activeWishlistItemIds.remove(row.itemId);
        }
      }

      if (row.isWishlisted && !activeWishlistItemIds.contains(row.itemId)) {
        final wishlistItem = WishlistItem(
          id: idGenerator(),
          catalogRef: CatalogEntityRef(
            kind: row.kind ?? catItemKind ?? CatalogMediaKind.unknown.apiValue,
            entityType: CatalogEntityType.work,
            id: row.itemId,
          ),
          anchorType: PersonalItemAnchorType.item.apiValue,
          createdAt: now,
          updatedAt: now,
        );
        wishlistUpserts.add(wishlistItem);
        syncChanges.add(
          SyncChange(
            id: 'wishlist:${wishlistItem.id}:upsert:${now.millisecondsSinceEpoch}',
            entityType: 'wishlist_item',
            entityId: wishlistItem.id,
            action: 'upsert',
            payload: wishlistItem.toSyncPayload(),
            clientChangedAt: now,
          ),
        );
        activeWishlistItemIds.add(row.itemId);
      }
    }

    await mutationRunner.run(
      origin: origin,
      action: () async {
        if (importedCatalogItems.isNotEmpty) {
          await catalogCache.upsertAll(importedCatalogItems);
        }
        if (ownedItemsList.isNotEmpty) {
          await ownedItems.upsertAll(ownedItemsList);
        }
        if (wishlistUpserts.isNotEmpty) {
          await wishlist.upsertAll(wishlistUpserts);
        }
        if (wishlistDeletes.isNotEmpty) {
          await wishlist.markDeletedAll(wishlistDeletes, now);
        }
        if (syncChanges.isNotEmpty) {
          await syncQueue.enqueueAll(syncChanges);
        }
      },
      eventsToEmit: [
        for (final item in ownedItemsList) OwnedItemAdded(item.id),
        for (final item in wishlistUpserts) WishlistChanged(item.itemId),
        for (final item in wishlistDeletes) WishlistChanged(item.itemId),
        for (final catItem in importedCatalogItems)
          CatalogItemChanged(
            typedCatalogItemFromUnknown(catItem)?.id ??
                (throw ArgumentError.value(
                  catItem,
                  'item',
                  'Unsupported catalog item type',
                )),
          ),
      ],
    );

    return imported;
  }

  Future<CollectionImportPreview> previewImportRows(
    List<CollectionCsvRow> rows,
  ) async {
    final candidateRows = <CollectionCsvRow>[];
    final unresolvedRows = <CollectionCsvRow>[];
    final skippedRows = <CollectionCsvRow>[];

    for (final r in rows) {
      var row = r;
      if (row.itemId.trim().isEmpty) {
        if (row.barcode != null && row.barcode!.trim().isNotEmpty) {
          final matched = await catalogCache.findByBarcode(
            row.barcode!,
            kind: row.kind,
          );
          if (matched != null) {
            row = row.copyWith(itemId: matched.id);
          }
        }
        if (row.itemId.trim().isEmpty &&
            row.title != null &&
            row.title!.trim().isNotEmpty) {
          final matched = await catalogCache.findByTitleAndIssue(
            title: row.title!,
            itemNumber: row.itemNumber,
            kind: row.kind,
          );
          if (matched != null) {
            row = row.copyWith(itemId: matched.id);
          }
        }
      }
      if (row.itemId.trim().isNotEmpty) {
        candidateRows.add(row);
      } else if ((row.title != null && row.title!.trim().isNotEmpty) ||
          (row.barcode != null && row.barcode!.trim().isNotEmpty) ||
          row.status.trim().isNotEmpty) {
        unresolvedRows.add(row);
      } else {
        skippedRows.add(row);
      }
    }

    final validRows = candidateRows;

    final seenItemIds = <String>{};
    final uniqueRows = <CollectionCsvRow>[];
    final duplicateRows = <CollectionCsvRow>[];

    for (final row in validRows) {
      if (seenItemIds.contains(row.itemId)) {
        duplicateRows.add(row);
      } else {
        seenItemIds.add(row.itemId);
        uniqueRows.add(row);
      }
    }

    final existingOwnedMap = {
      for (final item in await ownedItems.findActiveByItemIds(
        uniqueRows.map((r) => r.itemId),
      ))
        item.itemId: item,
    };

    final resolvedRows = <CollectionCsvRow>[];
    final conflictRows = <CollectionCsvRow>[];

    for (final row in uniqueRows) {
      if (existingOwnedMap.containsKey(row.itemId)) {
        conflictRows.add(row);
      } else {
        resolvedRows.add(row);
      }
    }

    return CollectionImportPreview(
      resolvedRows: resolvedRows,
      conflictRows: conflictRows,
      duplicateRows: duplicateRows,
      skippedRows: skippedRows,
      unresolvedRows: unresolvedRows,
    );
  }

  CatalogItem? _catalogItemFromCsvRow(
    CollectionCsvRow row, {
    dynamic existing,
  }) {
    final existingMetadata = typedCatalogItemFromUnknown(existing);
    if (existingMetadata != null) return existingMetadata;
    return typedCatalogItemFromMap({
      'id': row.itemId,
      'kind': row.kind ?? CatalogMediaKind.unknown.apiValue,
      'title': row.title ?? row.itemId,
      if (row.itemNumber != null) 'item_number': row.itemNumber,
      if (row.variant != null) 'variant': row.variant,
      if (row.editionTitle != null) 'edition_title': row.editionTitle,
      if (row.physicalFormat != null) 'physical_format': row.physicalFormat,
      if (row.physicalFormatLabel != null)
        'physical_format_label': row.physicalFormatLabel,
      if (row.barcode != null) 'barcode': row.barcode,
    });
  }

  OwnedItem _ownedItemFromCsvRow(
    CollectionCsvRow row,
    DateTime now, {
    OwnedItem? existing,
  }) {
    if (existing != null) {
      return existing.copyWith(
        condition: row.condition ?? existing.condition,
        grade: row.grade ?? existing.grade,
        rating: row.rating ?? existing.rating,
        pricePaidCents: row.pricePaidCents ?? existing.pricePaidCents,
        currency: row.currency ?? existing.currency,
        locationId: row.locationId ?? existing.locationId,
        personalNotes: row.notes ?? existing.personalNotes,
        updatedAt: now,
      );
    }
    return OwnedItem(
      id: idGenerator(),
      catalogRef: CatalogEntityRef(
        kind: row.kind ?? CatalogMediaKind.unknown.apiValue,
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      createdAt: now,
      updatedAt: now,
      condition: row.condition,
      grade: row.grade,
      rating: row.rating,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      locationId: row.locationId,
      personalNotes: row.notes,
    );
  }
}

class CollectionImportPreview {
  const CollectionImportPreview({
    required this.resolvedRows,
    required this.conflictRows,
    this.duplicateRows = const [],
    this.skippedRows = const [],
    this.unresolvedRows = const [],
  });

  final List<CollectionCsvRow> resolvedRows;
  final List<CollectionCsvRow> conflictRows;
  final List<CollectionCsvRow> duplicateRows;
  final List<CollectionCsvRow> skippedRows;
  final List<CollectionCsvRow> unresolvedRows;

  int get totalRows =>
      resolvedRows.length +
      conflictRows.length +
      duplicateRows.length +
      skippedRows.length +
      unresolvedRows.length;

  bool get hasImportableRows =>
      resolvedRows.isNotEmpty || conflictRows.isNotEmpty;

  int get resolvedCount => resolvedRows.length;
  int get conflictCount => conflictRows.length;
  int get duplicateCount => duplicateRows.length;
  int get skippedCount => skippedRows.length;
  int get unresolvedCount => unresolvedRows.length;
  int get reviewCount => conflictRows.length + duplicateRows.length;
}
