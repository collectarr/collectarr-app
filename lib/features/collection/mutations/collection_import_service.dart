import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_lookup_repository.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
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
    required this.catalogLookup,
    required this.trackingEntries,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final LibraryCatalogRepository catalogCache;
  final CatalogLookupRepository catalogLookup;
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

    final catalogItems =
        Map<String, CatalogItemDto>.from(await catalogCache.findByIds(
      resolvedRows.map((row) => row.itemId),
    ));
    final importedCatalogItems = <CatalogItemDto>[];
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
      for (final item in await ownedItems.listActiveSummaries().then(
            (items) => items.where(
              (item) => resolvedRows.any(
                (row) => row.itemId == item.itemId,
              ),
            ),
          ))
        item.itemId: item,
    };
    final existingTracking = {
      for (final entry in await trackingEntries.findActiveByItemIds(
        resolvedRows.map((row) => row.itemId),
      ))
        entry.ownedItemId ?? entry.itemId: entry,
    };

    final activeWishlistItemIds = existingWishlist.keys.toSet();
    final ownedItemRefs = <OwnedItemRef>[];
    final typedOwnedItems = <(CatalogMediaKind kind, Object item)>[];
    final trackingEntriesList = <TrackingEntry>[];
    final wishlistDeletes = <WishlistItem>[];
    final wishlistUpserts = <WishlistItem>[];
    final syncChanges = <SyncChange>[];
    final snapshotItemIds = <String>{};
    var imported = 0;

    for (final row in resolvedRows) {
      if (!row.isOwned && !row.isWishlisted) continue;

      imported++;
      final catItem = catalogItems[row.itemId];
      final metadataItem = catItem;
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
        final existingOwnedSummary = existingOwned[row.itemId];
        final existingTypedOwned = existingOwnedSummary == null
            ? null
            : await ownedItems.findTypedById(
                existingOwnedSummary.ref.id.value,
              );
        final typedImport = _typedOwnedItemFromCsvRow(
          row,
          now,
          existingSummary: existingOwnedSummary,
          existingTyped: existingTypedOwned,
          catalogKind: catItemKind,
        );
        final mediaKind = typedImport.kind;
        final typedOwnedItem = typedImport.item;
        typedOwnedItems.add((mediaKind, typedOwnedItem));
        final ownedRef = collectarrTypedOwnedItemRef(typedOwnedItem);
        ownedItemRefs.add(ownedRef);
        final serializedOwned = ownedItems.syncPayloadForTyped(
          mediaKind,
          typedOwnedItem,
        );
        syncChanges.add(
          SyncChange(
            id: 'owned_item:${ownedRef.id.value}:upsert:${now.millisecondsSinceEpoch}',
            entityType: 'owned_item',
            entityId: ownedRef.id.value,
            action: 'upsert',
            payload: serializedOwned.payload,
            clientChangedAt: now,
          ),
        );

        final trackingEntry = _trackingEntryFromCsvRow(
          row,
          ownedRef: ownedRef,
          catalogRef: typedImport.catalogRef,
          now: now,
          existing: existingTracking[ownedRef.id.value] ??
              existingTracking[typedImport.catalogRef.id],
        );
        if (trackingEntry != null) {
          trackingEntriesList.add(trackingEntry);
          syncChanges.add(
            SyncChange(
              id: 'tracking_entry:${trackingEntry.id}:upsert:${now.millisecondsSinceEpoch}',
              entityType: 'tracking_entry',
              entityId: trackingEntry.id,
              action: 'upsert',
              payload: trackingEntries.toSyncPayload(trackingEntry),
              clientChangedAt: now,
            ),
          );
        }

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
        for (final typedOwned in typedOwnedItems) {
          await ownedItems.upsertTyped(
            typedOwned.$1,
            typedOwned.$2,
          );
        }
        if (trackingEntriesList.isNotEmpty) {
          await trackingEntries.upsertAll(trackingEntriesList);
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
        for (final item in ownedItemRefs) OwnedItemAdded(item.id.value),
        for (final entry in trackingEntriesList) TrackingChanged(entry.id),
        for (final item in wishlistUpserts) WishlistChanged(item.itemId),
        for (final item in wishlistDeletes) WishlistChanged(item.itemId),
        for (final catItem in importedCatalogItems)
          CatalogItemChanged(catItem.id),
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
          final matched = await catalogLookup.findByBarcode(
            row.barcode!,
            kind: row.kind,
          );
          if (matched != null) {
            row = row.copyWith(itemId: matched.ref.id);
          }
        }
        if (row.itemId.trim().isEmpty &&
            row.title != null &&
            row.title!.trim().isNotEmpty) {
          final matched = await catalogLookup.findByTitleAndItemNumber(
            title: row.title!,
            itemNumber: row.itemNumber,
            kind: row.kind,
          );
          if (matched != null) {
            row = row.copyWith(itemId: matched.ref.id);
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

    final uniqueItemIds = uniqueRows.map((row) => row.itemId).toSet();
    final existingOwnedMap = {
      for (final item
          in await ownedItems.listActiveSummaries().then((items) => items.where(
                (item) => uniqueItemIds.contains(item.itemId),
              )))
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

  CatalogItemDto? _catalogItemFromCsvRow(
    CollectionCsvRow row, {
    CatalogItemDto? existing,
  }) {
    if (existing != null) {
      return existing;
    }
    final projection = libraryCollectionCsvProjectionForKind(
      catalogMediaKindFromValue(row.kind),
    );
    if (projection != null &&
        row.kindCatalogCells.length == libraryCollectionCsvCatalogCellCount) {
      final imported =
          projection.catalogItemFromImportCells(row.kindCatalogCells);
      if (imported != null) {
        return imported;
      }
    }
    return CatalogItemDto.fromJson({
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

  _TypedOwnedImport _typedOwnedItemFromCsvRow(
    CollectionCsvRow row,
    DateTime now, {
    OwnedItemSummary? existingSummary,
    (CatalogMediaKind kind, Object item)? existingTyped,
    String? catalogKind,
  }) {
    final resolvedKind = row.kind ??
        existingSummary?.ref.kind.apiValue ??
        existingTyped?.$1.apiValue ??
        catalogKind;
    final kind = catalogMediaKindFromApiValue(resolvedKind);
    final catalogRef = existingSummary?.catalogRef ??
        CatalogEntityRef(
          kind: resolvedKind ?? CatalogMediaKind.unknown.apiValue,
          entityType: CatalogEntityType.work,
          id: row.itemId,
        );
    final payload = existingTyped == null
        ? <String, dynamic>{
            'id': idGenerator(),
            'catalog_ref': catalogRef.toJson(),
            'created_at': now.toUtc().toIso8601String(),
            'quantity': row.quantity ?? 1,
          }
        : collectarrTypedOwnedItemJson(existingTyped.$2);

    payload['catalog_ref'] = catalogRef.toJson();
    payload['updated_at'] = now.toUtc().toIso8601String();
    if (row.condition != null) payload['condition'] = row.condition;
    if (row.grade != null) payload['grade'] = row.grade;
    if (row.purchaseDate != null) {
      payload['purchase_date'] = row.purchaseDate!.toUtc().toIso8601String();
    }
    if (row.pricePaidCents != null) {
      payload['price_paid_cents'] = row.pricePaidCents;
    }
    if (row.currency != null) payload['currency'] = row.currency;
    if (row.notes != null) payload['personal_notes'] = row.notes;
    if (row.quantity != null) payload['quantity'] = row.quantity;
    if (row.locationId != null) payload['location_id'] = row.locationId;
    if (row.indexNumber != null) payload['index_number'] = row.indexNumber;
    if (row.tags != null) payload['tags'] = row.tags;
    if (row.soldAt != null) {
      payload['sold_at'] = row.soldAt!.toUtc().toIso8601String();
    }
    if (row.sellPriceCents != null) {
      payload['sell_price_cents'] = row.sellPriceCents;
    }
    if (row.soldTo != null) payload['sold_to'] = row.soldTo;

    final importedDetails = _ownedDetailsFromCsvRow(
      row,
      kind: kind,
    );
    if (importedDetails != null) payload.addAll(importedDetails);

    final deserializer = collectarrTypedOwnedItemSyncDeserializers[kind];
    if (deserializer == null) {
      throw StateError(
        'Collection import cannot resolve typed Owned model for '
        '${kind.apiValue}',
      );
    }
    final item = deserializer(payload);
    return (
      kind: kind,
      item: item,
      catalogRef: catalogRef,
    );
  }

  Map<String, dynamic>? _ownedDetailsFromCsvRow(
    CollectionCsvRow row, {
    required CatalogMediaKind kind,
  }) {
    if (row.kindOwnedCells.length != libraryCollectionCsvOwnedCellCount) {
      return null;
    }
    final projection = libraryCollectionCsvProjectionForKind(
      kind,
    );
    if (projection case final LibraryCollectionCsvOwnedDetailsDecoder decoder) {
      return decoder.decodeOwnedDetails(row.kindOwnedCells)?.toJson();
    }
    return null;
  }

  TrackingEntry? _trackingEntryFromCsvRow(
    CollectionCsvRow row, {
    required OwnedItemRef ownedRef,
    required CatalogEntityRef catalogRef,
    required DateTime now,
    TrackingEntry? existing,
  }) {
    final hasTrackingValues = row.rating != null ||
        row.readStatus != null ||
        row.startedAt != null ||
        row.finishedAt != null;
    if (!hasTrackingValues) {
      return null;
    }

    final status = mediaTrackingStatusFromValue(row.readStatus);
    if (existing != null) {
      return existing.copyWith(
        catalogRef: catalogRef,
        ownedItemId: ownedRef.id.value,
        status: status ?? existing.status,
        rating: row.rating ?? existing.rating,
        startedAt: row.startedAt ?? existing.startedAt,
        finishedAt: row.finishedAt ?? existing.finishedAt,
        updatedAt: now,
      );
    }

    return TrackingEntry(
      id: idGenerator(),
      catalogRef: catalogRef,
      ownedItemId: ownedRef.id.value,
      status: status ?? MediaTrackingStatus.planned,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      updatedAt: now,
    );
  }
}

typedef _TypedOwnedImport = ({
  CatalogMediaKind kind,
  Object item,
  CatalogEntityRef catalogRef,
});

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
