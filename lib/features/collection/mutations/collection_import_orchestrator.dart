import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_snapshot.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_lookup_repository.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_lifecycle_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/config/owned_item_mutation_result.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/config/library_collection_csv_projection.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class CollectionImportOrchestrator {
  const CollectionImportOrchestrator({
    required this.ownedItems,
    required this.wishlist,
    required this.catalogTransport,
    required this.catalogSummaries,
    required this.catalogLookup,
    required this.trackingLifecycles,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  });

  final OwnedItemsRepository ownedItems;
  final WishlistItemsCacheRepository wishlist;
  final CatalogTransportRepository catalogTransport;
  final CatalogDisplaySummaryRepository catalogSummaries;
  final CatalogLookupRepository catalogLookup;
  final TrackingLifecycleRepository trackingLifecycles;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<int> importRows(
    List<CollectionImportRow> rows, {
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
    final existingLifecycles = {
      for (final entry
          in await this.trackingLifecycles.findActiveByCatalogRefs(rowRefs))
        entry.catalogRef: entry,
    };

    final activeWishlistRefs = existingWishlist.keys.toSet();
    final ownedItemRefs = <OwnedItemRef>[];
    final ownedWrites = <Future<OwnedItemMutationResult> Function()>[];
    final trackingLifecycles = <TrackingLifecycle>[];
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
      final catalogKind = importedCatalogSnapshot?.kind ??
          existingCatalogSummary?.kind ??
          row.mediaKind;
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
        final existingOwnedPayload = existingOwnedSummary == null
            ? null
            : await ownedItems.payloadByRef(existingOwnedSummary.ref);
        final ownedImport = _ownedItemImportFromCsvRow(
          row,
          now,
          existingSummary: existingOwnedSummary,
          existingPayload: existingOwnedPayload,
          catalogKind: catalogKind,
        );
        final mediaKind = ownedImport.kind;
        final ownedRef = ownedImport.ref;
        ownedWrites.add(
          () => ownedItems.replaceFromPayload(
            mediaKind,
            ownedImport.payload,
          ),
        );
        ownedItemRefs.add(ownedRef);

        final trackingLifecycle = row.tracking.isEmpty
            ? null
            : libraryCollectionCsvProjectionForKind(mediaKind)
                ?.trackingLifecycleFromImport(
                entryId: idGenerator(),
                catalogRef: ownedImport.catalogRef,
                ownedRef: ownedRef,
                now: now,
                rating: row.tracking.rating,
                status: row.tracking.status,
                startedAt: row.tracking.startedAt,
                finishedAt: row.tracking.finishedAt,
                existing: existingLifecycles[ownedImport.catalogRef],
              );
        if (trackingLifecycle != null) {
          trackingLifecycles.add(trackingLifecycle);
          syncChanges.add(
            SyncChange(
              id: 'tracking_entry:${trackingLifecycle.id}:upsert:${now.millisecondsSinceEpoch}',
              entityType: 'tracking_entry',
              entityId: trackingLifecycle.id,
              action: 'upsert',
              payload: this.trackingLifecycles.toSyncPayload(trackingLifecycle),
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
            kind: catalogKind,
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
          await catalogTransport
              .upsertImportSnapshots(importedCatalogSnapshots);
        }
        for (final write in ownedWrites) {
          final persisted = await write();
          syncChanges.add(
            ownedItems.syncChangeForMutation(
              persisted,
              action: 'upsert',
              changedAt: now,
            ),
          );
        }
        if (trackingLifecycles.isNotEmpty) {
          await this.trackingLifecycles.upsertAll(trackingLifecycles);
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
        for (final _ in trackingLifecycles) const TrackingChanged(),
        for (final item in wishlistUpserts) WishlistChanged(item.catalogRef),
        for (final item in wishlistDeletes) WishlistChanged(item.catalogRef),
        for (final snapshot in importedCatalogSnapshots)
          CatalogItemChanged(snapshot.catalogRef),
      ],
    );

    return imported;
  }

  Future<CollectionImportPreview> previewImportRows(
    List<CollectionImportRow> rows,
  ) async {
    final candidateRows = <CollectionImportRow>[];
    final unresolvedRows = <CollectionImportRow>[];
    final skippedRows = <CollectionImportRow>[];

    for (final r in rows) {
      var row = r;
      final lookup = _importLookupValues(row);
      if (row.itemId.trim().isEmpty) {
        final barcode = lookup.barcode;
        if (barcode != null && barcode.isNotEmpty) {
          final matched = await catalogLookup.resolve(
            CatalogLookupQuery(value: barcode),
            kind: row.mediaKind,
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
            kind: row.mediaKind,
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
    final uniqueRows = <CollectionImportRow>[];
    final duplicateRows = <CollectionImportRow>[];

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

    final resolvedRows = <CollectionImportRow>[];
    final conflictRows = <CollectionImportRow>[];

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

  CatalogEntityRef? _catalogRefForRow(CollectionImportRow row) {
    if (row.mediaKind.isUnknown || row.itemId.trim().isEmpty) {
      return null;
    }
    return CatalogEntityRef(
      kind: row.mediaKind,
      entityType: const CatalogEntityTypeId('work'),
      id: row.itemId,
    );
  }

  /// Lets the owning CSV projection create the catalog snapshot.
  ///
  /// Collection only normalizes the structural identity cell needed by the
  /// serialization boundary. It must not reconstruct a rich
  /// when the row did not come from a complete kind-owned catalog projection.
  CatalogImportSnapshot? _catalogSnapshotFromCsvRow(CollectionImportRow row) {
    final projection = libraryCollectionCsvProjectionForKind(
      row.mediaKind,
    );
    final cells = _catalogImportCells(row);
    if (projection == null || cells == null) {
      return null;
    }
    return projection.catalogItemFromImportCells(cells);
  }

  List<String>? _catalogImportCells(CollectionImportRow row) {
    if (row.itemId.trim().isEmpty ||
        row.kindCatalogCells.length != libraryCollectionCsvCatalogCellCount) {
      return null;
    }

    final cells = [...row.kindCatalogCells];
    if (cells[0].trim().isEmpty) cells[0] = row.itemId;
    return cells;
  }

  ({String? barcode, String? primary}) _importLookupValues(
    CollectionImportRow row,
  ) {
    final projection = libraryCollectionCsvProjectionForKind(
      row.mediaKind,
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

  _OwnedImport _ownedItemImportFromCsvRow(
    CollectionImportRow row,
    DateTime now, {
    OwnedItemSummary? existingSummary,
    JsonMap? existingPayload,
    CatalogMediaKind? catalogKind,
  }) {
    final kind = existingSummary?.ref.kind ?? catalogKind ?? row.mediaKind;
    final catalogRef = existingSummary?.catalogRef ??
        CatalogEntityRef(
          kind: kind,
          entityType: const CatalogEntityTypeId('work'),
          id: row.itemId,
        );
    final personal = row.personal;
    final projection = libraryCollectionCsvProjectionForKind(kind);
    if (projection != null) {
      final ownedRef = existingSummary?.ref ??
          OwnedItemRef(kind: kind, id: OwnedItemId(idGenerator()));
      final payload = projection.ownedItemImportPayload(
        LibraryCollectionCsvOwnedImport(
          id: ownedRef.id.value,
          catalogRef: catalogRef,
          now: now,
          existingPayload: existingPayload,
          condition: personal.condition,
          purchaseDate: personal.purchaseDate,
          pricePaidCents: personal.pricePaidCents,
          currency: personal.currency,
          personalNotes: personal.notes,
          quantity: personal.quantity ?? 1,
          locationId: personal.locationId,
          indexNumber: personal.indexNumber,
          tags: personal.tags,
          soldAt: personal.soldAt,
          sellPriceCents: personal.sellPriceCents,
          soldTo: personal.soldTo,
          kindOwnedCells: row.kindOwnedCells,
        ),
      );
      return (
        kind: kind,
        ref: ownedRef,
        catalogRef: catalogRef,
        payload: payload,
      );
    }
    throw StateError('No CSV projection registered for ${kind.apiValue}.');
  }
}

typedef _OwnedImport = ({
  CatalogMediaKind kind,
  OwnedItemRef ref,
  CatalogEntityRef catalogRef,
  JsonMap payload,
});

class CollectionImportPreview {
  const CollectionImportPreview({
    required this.resolvedRows,
    required this.conflictRows,
    this.duplicateRows = const [],
    this.skippedRows = const [],
    this.unresolvedRows = const [],
  });

  final List<CollectionImportRow> resolvedRows;
  final List<CollectionImportRow> conflictRows;
  final List<CollectionImportRow> duplicateRows;
  final List<CollectionImportRow> skippedRows;
  final List<CollectionImportRow> unresolvedRows;

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
