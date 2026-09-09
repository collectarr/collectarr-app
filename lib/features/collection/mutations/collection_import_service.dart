import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
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
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class CollectionImportService {
  const CollectionImportService({
    required this.ownedItems,
    required this.wishlist,
    required this.catalogCache,
    required this.catalogSummaries,
    required this.catalogLookup,
    required this.trackingEntries,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final CatalogTransportRepository catalogCache;
  final CatalogDisplaySummaryRepository catalogSummaries;
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

    // Mixed import orchestration only needs to know whether a catalog target
    // already exists and which kind owns it. Do not rehydrate full catalog
    // DTO graphs here; the kind CSV profile creates a transport snapshot only
    // for genuinely new catalog identities below.
    final rowRefs = [
      for (final row in resolvedRows)
        if (_catalogRefForRow(row) case final ref?) ref,
    ];
    final existingCatalogSummaries = await catalogSummaries.findByRefs(rowRefs);
    final importedCatalogSnapshots = <CatalogImportSnapshot>[];
    final importedCatalogSnapshotsByRef =
        <CatalogEntityRef, CatalogImportSnapshot>{};
    for (final row in resolvedRows) {
      final rowRef = _catalogRefForRow(row);
      if (rowRef == null) continue;
      // An existing catalog item is already authoritative local state. Only
      // a kind-owned CSV projection may create a new catalog snapshot for an
      // import row; Collection must not re-persist existing metadata or
      // synthesize a generic semantic fallback.
      if (existingCatalogSummaries.containsKey(rowRef)) continue;
      final snapshot = _catalogSnapshotFromCsvRow(row);
      if (snapshot == null) continue;
      importedCatalogSnapshotsByRef[rowRef] = snapshot;
      importedCatalogSnapshots.add(snapshot);
    }

    final now = DateTime.now().toUtc();
    final existingWishlist = {
      for (final item in await wishlist.findActiveByCatalogRefs(rowRefs))
        item.catalogRef: item,
    };
    final existingOwned = {
      for (final item in await ownedItems.listActiveSummaries().then(
            (items) => items.where(
              (item) =>
                  item.catalogRef != null && rowRefs.contains(item.catalogRef),
            ),
          ))
        if (item.catalogRef != null) item.catalogRef!: item,
    };
    final existingTracking = {
      for (final entry
          in await trackingEntries.findActiveByCatalogRefs(rowRefs))
        entry.catalogRef: entry,
    };

    final activeWishlistRefs = existingWishlist.keys.toSet();
    final ownedItemRefs = <OwnedItemRef>[];
    final typedOwnedItems = <(CatalogMediaKind kind, Object item)>[];
    final trackingEntriesList = <TrackingEntry>[];
    final wishlistDeletes = <WishlistItem>[];
    final wishlistUpserts = <WishlistItem>[];
    final syncChanges = <SyncChange>[];
    final snapshotRefs = <CatalogEntityRef>{};
    var imported = 0;

    for (final row in resolvedRows) {
      if (!row.isOwned && !row.isWishlisted) continue;
      final rowRef = _catalogRefForRow(row);
      if (rowRef == null) continue;

      imported++;
      final importedCatalogSnapshot = importedCatalogSnapshotsByRef[rowRef];
      final existingCatalogSummary = existingCatalogSummaries[rowRef];
      final catalogKind = importedCatalogSnapshot?.kind.apiValue ??
          existingCatalogSummary?.kind.apiValue ??
          row.kind;
      final catalogId = importedCatalogSnapshot?.id ?? row.itemId;
      if ((importedCatalogSnapshot != null || existingCatalogSummary != null) &&
          snapshotRefs.add(rowRef)) {
        syncChanges.add(
          SyncChange(
            id: 'catalog:$catalogId:upsert:${now.millisecondsSinceEpoch}',
            entityType: 'catalog_item',
            entityId: catalogId,
            action: 'upsert',
            payload: {'id': catalogId},
            clientChangedAt: now,
          ),
        );
      }

      final existingWishlistItem = existingWishlist[rowRef];
      if (row.isOwned) {
        final existingOwnedSummary = existingOwned[rowRef];
        final existingTypedOwned = existingOwnedSummary == null
            ? null
            : await ownedItems.findTypedByRef(existingOwnedSummary.ref);
        final typedImport = _typedOwnedItemFromCsvRow(
          row,
          now,
          existingSummary: existingOwnedSummary,
          existingTyped: existingTypedOwned,
          catalogKind: catalogKind,
        );
        final mediaKind = typedImport.kind;
        final typedOwnedItem = typedImport.item;
        typedOwnedItems.add((mediaKind, typedOwnedItem));
        final ownedRef = collectarrTypedOwnedItemRef(typedOwnedItem);
        ownedItemRefs.add(ownedRef);
        syncChanges.add(
          ownedItems.syncChangeForTyped(
            mediaKind,
            typedOwnedItem,
            id: ownedRef.id.value,
            action: 'upsert',
            changedAt: now,
          ),
        );

        final trackingEntry = _trackingEntryFromCsvRow(
          row,
          ownedRef: ownedRef,
          catalogRef: typedImport.catalogRef,
          now: now,
          existing: existingTracking[typedImport.catalogRef],
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
            activeWishlistRefs.contains(rowRef)) {
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
          activeWishlistRefs.remove(rowRef);
        }
      }

      if (row.isWishlisted && !activeWishlistRefs.contains(rowRef)) {
        final wishlistItem = WishlistItem(
          id: idGenerator(),
          catalogRef: CatalogEntityRef(
            kind: catalogMediaKindFromApiValue(row.kind ?? catalogKind),
            entityType: const CatalogEntityTypeId('work'),
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
        activeWishlistRefs.add(rowRef);
      }
    }

    await mutationRunner.run(
      origin: origin,
      action: () async {
        if (importedCatalogSnapshots.isNotEmpty) {
          await catalogCache.upsertImportSnapshots(importedCatalogSnapshots);
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
        for (final item in ownedItemRefs) OwnedItemAdded(item),
        for (final _ in trackingEntriesList) const TrackingChanged(),
        for (final item in wishlistUpserts) WishlistChanged(item.catalogRef),
        for (final item in wishlistDeletes) WishlistChanged(item.catalogRef),
        for (final snapshot in importedCatalogSnapshots)
          CatalogItemChanged(snapshot.catalogRef),
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
      final lookup = _importLookupValues(row);
      if (row.itemId.trim().isEmpty) {
        final barcode = lookup.barcode;
        if (barcode != null && barcode.isNotEmpty) {
          final matched = await catalogLookup.resolve(
            CatalogLookupQuery(value: barcode),
            kind: row.kind,
          );
          if (matched != null) {
            row = row.copyWith(itemId: matched.ref.id);
          }
        }
        if (row.itemId.trim().isEmpty &&
            row.title != null &&
            row.title!.trim().isNotEmpty) {
          final matched = await catalogLookup.resolve(
            CatalogLookupQuery(
              title: row.title!,
              value: lookup.primary,
            ),
            kind: row.kind,
          );
          if (matched != null) {
            row = row.copyWith(itemId: matched.ref.id);
          }
        }
      }
      if (row.itemId.trim().isNotEmpty && _catalogRefForRow(row) != null) {
        candidateRows.add(row);
      } else if ((row.title != null && row.title!.trim().isNotEmpty) ||
          lookup.barcode != null ||
          row.status.trim().isNotEmpty) {
        unresolvedRows.add(row);
      } else {
        skippedRows.add(row);
      }
    }

    final validRows = candidateRows;

    final seenRefs = <CatalogEntityRef>{};
    final uniqueRows = <CollectionCsvRow>[];
    final duplicateRows = <CollectionCsvRow>[];

    for (final row in validRows) {
      final ref = _catalogRefForRow(row);
      if (ref == null) {
        unresolvedRows.add(row);
        continue;
      }
      if (seenRefs.contains(ref)) {
        duplicateRows.add(row);
      } else {
        seenRefs.add(ref);
        uniqueRows.add(row);
      }
    }

    final uniqueRefs =
        uniqueRows.map(_catalogRefForRow).whereType<CatalogEntityRef>().toSet();
    final existingOwnedMap = {
      for (final item
          in await ownedItems.listActiveSummaries().then((items) => items.where(
                (item) =>
                    item.catalogRef != null &&
                    uniqueRefs.contains(item.catalogRef),
              )))
        if (item.catalogRef != null) item.catalogRef!: item,
    };

    final resolvedRows = <CollectionCsvRow>[];
    final conflictRows = <CollectionCsvRow>[];

    for (final row in uniqueRows) {
      final rowRef = _catalogRefForRow(row);
      if (rowRef != null && existingOwnedMap.containsKey(rowRef)) {
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

  CatalogEntityRef? _catalogRefForRow(CollectionCsvRow row) {
    final kind = row.kind?.trim();
    if (kind == null || kind.isEmpty || row.itemId.trim().isEmpty) {
      return null;
    }
    return CatalogEntityRef(
      kind: catalogMediaKindFromApiValue(kind),
      entityType: const CatalogEntityTypeId('work'),
      id: row.itemId,
    );
  }

  /// Lets the owning CSV projection create the catalog snapshot.
  ///
  /// Collection only normalizes the structural identity cell needed by the
  /// serialization boundary. It must not reconstruct a rich
  /// when the row did not come from a complete kind-owned catalog projection.
  CatalogImportSnapshot? _catalogSnapshotFromCsvRow(CollectionCsvRow row) {
    final projection = libraryCollectionCsvProjectionForKind(
      catalogMediaKindFromValue(row.kind),
    );
    final cells = _catalogImportCells(row);
    if (projection == null || cells == null) {
      return null;
    }
    return projection.catalogItemFromImportCells(cells);
  }

  List<String>? _catalogImportCells(CollectionCsvRow row) {
    if (row.itemId.trim().isEmpty ||
        row.kindCatalogCells.length != libraryCollectionCsvCatalogCellCount) {
      return null;
    }

    final cells = [...row.kindCatalogCells];
    if (cells[0].trim().isEmpty) cells[0] = row.itemId;
    return cells;
  }

  ({String? barcode, String? primary}) _importLookupValues(
    CollectionCsvRow row,
  ) {
    final projection = libraryCollectionCsvProjectionForKind(
      catalogMediaKindFromValue(row.kind),
    );
    if (projection == null ||
        row.kindCatalogCells.length != libraryCollectionCsvCatalogCellCount) {
      return (barcode: null, primary: null);
    }
    return (
      barcode: projection.importBarcode(row.kindCatalogCells),
      primary: projection.importPrimaryLookupValue(row.kindCatalogCells),
    );
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
          kind: catalogMediaKindFromApiValue(resolvedKind),
          entityType: const CatalogEntityTypeId('work'),
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
        ownedRef: ownedRef,
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
      ownedRef: ownedRef,
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
