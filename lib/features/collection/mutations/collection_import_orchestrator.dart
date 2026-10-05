import 'dart:async';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/custom_field.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_import_transport.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_lookup_repository.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_kind_profile.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_models.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/library/entries/library_entries_repository.dart';
import 'package:collectarr_app/features/library/entries/entry_import_transport.dart';
import 'package:collectarr_app/features/library/entries/library_entry_record.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/config/library_entry_mutation_result.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_import.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class CollectionImportOrchestrator {
  CollectionImportOrchestrator({
    required this.libraryEntries,
    required this.wishlist,
    required this.catalogTransport,
    required this.catalogSummaries,
    required this.catalogLookup,
    required Iterable<CollectionCsvKindProfile> csvProfiles,
    required this.trackingRecords,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  }) : _csvProfiles = {
          for (final profile in csvProfiles) profile.kind: profile,
        };

  final LibraryEntriesRepository libraryEntries;
  final WishlistItemsCacheRepository wishlist;
  final CatalogTransportRepository catalogTransport;
  final CatalogDisplaySummaryRepository catalogSummaries;
  final CatalogLookupRepository catalogLookup;
  final Map<CatalogMediaKind, CollectionCsvKindProfile> _csvProfiles;
  final TrackingStorageRepository trackingRecords;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<int> importRows(List<CollectionImportRow> rows) async {
    if (rows.isEmpty) return 0;

    final preview = await previewImportRows(rows);
    final resolvedRows = [...preview.resolvedRows, ...preview.conflictRows];
    if (resolvedRows.isEmpty) return 0;

    // Mixed import orchestration only needs to know whether a catalog target
    // already exists and which kind owns it. Do not rehydrate full catalog
    // DTO graphs here; the kind CSV profile creates a transport item only
    // for genuinely new catalog identities below.
    final rowRefs = [
      for (final row in resolvedRows)
        if (_catalogRefForRow(row) case final ref?) ref,
    ];
    final existingCatalogSummaries = await catalogSummaries.findByRefs(rowRefs);
    final importedCatalogItems = <CatalogImportTransport>[];
    final importedCatalogItemsByRef =
        <CatalogItemRef, CatalogImportTransport>{};
    for (final row in resolvedRows) {
      final rowRef = _catalogRefForRow(row);
      if (rowRef == null) continue;
      // An existing catalog item is already authoritative local state. Only
      // a kind-entry CSV projection may create a new catalog snapshot for an
      // import row; Collection must not re-persist existing metadata or
      // synthesize a generic semantic fallback.
      if (existingCatalogSummaries.containsKey(rowRef)) continue;
      // A complete library-entry envelope already contains its own catalog
      // facts. Do not create a second catalog record from its CSV projection.
      if (row.fullEntryPayload != null) continue;
      final item = _catalogTransportFromCsvRow(row);
      if (item == null) continue;
      importedCatalogItemsByRef[rowRef] = item;
      importedCatalogItems.add(item);
    }

    final now = DateTime.now().toUtc();
    final existingWishlist = {
      for (final item in await wishlist.findActiveByCatalogRefs(
        rowRefs.map((ref) => ref),
      ))
        item.catalogRef: item,
    };
    final existingEntry = _entrySummariesByTarget(
      await libraryEntries.listActiveSummaries(),
      rowRefs,
      includeRootScope: false,
    );
    final activeWishlistRefs = existingWishlist.keys.toSet();
    final libraryEntryRefs = <LibraryEntryRef>[];
    final entryWrites = <Future<LibraryEntryMutationResult> Function()>[];
    final trackingImports = <TrackingStorageImport>[];
    final wishlistDeletes = <WishlistItem>[];
    final wishlistUpserts = <WishlistItem>[];
    final syncChanges = <SyncChange>[];
    var imported = 0;

    for (final row in resolvedRows) {
      if (!row.isEntry && !row.isWishlisted) continue;
      final rowRef = _catalogRefForRow(row);
      if (rowRef == null) continue;
      final wishlistCatalogRef = _wishlistCatalogRefForRow(row) ?? rowRef;
      final wishlistRef = wishlistCatalogRef;

      imported++;
      final catalogKind = importedCatalogItemsByRef[rowRef]?.ref.kind ??
          existingCatalogSummaries[rowRef]?.kind ??
          row.mediaKind;

      final existingWishlistItem = existingWishlist[wishlistRef];
      if (row.isEntry) {
        final existingLibraryEntrySummary = existingEntry[rowRef];
        final existingEntryPayload = existingLibraryEntrySummary == null
            ? null
            : await libraryEntries
                .payloadByRef(existingLibraryEntrySummary.ref);
        final entryCatalogData = await _catalogDataForEntryImport(
          row,
          rowRef,
          importedCatalogItemsByRef,
        );
        final entryImport = await _libraryEntryImportFromCsvRow(
          row,
          now,
          catalogData: entryCatalogData,
          existingSummary: existingLibraryEntrySummary,
          existingPayload: existingEntryPayload,
          catalogKind: catalogKind,
        );
        final libraryEntryRef = entryImport.ref;
        entryWrites.add(() async {
          final persisted =
              await libraryEntries.replaceFromTransport(entryImport.transport);
          await _writeCsvCustomFields(row, persisted.ref, now);
          return persisted;
        });
        libraryEntryRefs.add(libraryEntryRef);

        if (!row.tracking.isEmpty) {
          trackingImports.add(
            TrackingStorageImport(
              entryId: idGenerator(),
              libraryEntryRef: libraryEntryRef,
              now: now,
              rating: row.tracking.rating,
              status: row.tracking.status,
              startedAt: row.tracking.startedAt,
              finishedAt: row.tracking.finishedAt,
            ),
          );
        }

        if (existingWishlistItem != null &&
            activeWishlistRefs.contains(wishlistRef)) {
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
          activeWishlistRefs.remove(wishlistRef);
        }
      }

      if (row.isWishlisted && !activeWishlistRefs.contains(wishlistRef)) {
        final wishlistItem = WishlistItem(
          id: idGenerator(),
          catalogRef: wishlistRef,
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
        activeWishlistRefs.add(wishlistRef);
      }
    }

    await mutationRunner.run(
      action: () async {
        if (importedCatalogItems.isNotEmpty) {
          await catalogTransport.upsertTransports(importedCatalogItems);
        }
        for (final write in entryWrites) {
          final persisted = await write();
          syncChanges.add(
            await libraryEntries.syncChangeForCurrentEntry(
              persisted.ref,
              action: 'upsert',
              changedAt: now,
            ),
          );
        }
        if (trackingImports.isNotEmpty) {
          final trackingResults =
              await trackingRecords.upsertImportedAll(trackingImports);
          syncChanges.addAll([
            for (final result in trackingResults)
              SyncChange(
                id: 'tracking_entry:${result.ref.id}:upsert:${now.millisecondsSinceEpoch}',
                entityType: 'tracking_entry',
                entityId: result.ref.id,
                action: 'upsert',
                payload: result.payload,
                clientChangedAt: now,
              ),
          ]);
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
        for (final item in libraryEntryRefs) LibraryEntryAdded(item),
        for (final _ in trackingImports) const TrackingChanged(),
        for (final item in wishlistUpserts) WishlistChanged(item.catalogRef),
        for (final item in wishlistDeletes) WishlistChanged(item.catalogRef),
        for (final item in importedCatalogItems) CatalogItemChanged(item.ref),
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
            row = row.copyWith(
              itemId: matched.ref.id,
              catalogItemRef: matched.ref,
              mediaKind: matched.kind,
              title: matched.title,
              kindDisplayTitle: matched.title,
              kindDisplaySubtitle: matched.subtitle,
            );
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
            row = row.copyWith(
              itemId: matched.ref.id,
              catalogItemRef: matched.ref,
              mediaKind: matched.kind,
              title: matched.title,
              kindDisplayTitle: matched.title,
              kindDisplaySubtitle: matched.subtitle,
            );
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

    final seenRefs = <CatalogItemRef>{};
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
        uniqueRows.map(_catalogRefForRow).whereType<CatalogItemRef>().toSet();
    final existingEntryMap = _entrySummariesByTarget(
      await libraryEntries.listActiveSummaries(),
      uniqueRefs,
      includeRootScope: true,
    );

    final resolvedRows = <CollectionImportRow>[];
    final conflictRows = <CollectionImportRow>[];

    for (final row in uniqueRows) {
      final rowRef = _catalogRefForRow(row);
      if (rowRef != null && existingEntryMap.containsKey(rowRef)) {
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

  CatalogItemRef? _catalogRefForRow(CollectionImportRow row) {
    final completeEntry = row.fullEntryPayload;
    if (completeEntry != null) {
      final id = completeEntry['id'];
      if (id is! String || id.trim().isEmpty || row.mediaKind.isUnknown) {
        return null;
      }
      return CatalogItemRef(
        kind: row.mediaKind,
        id: id,
      );
    }
    final importedRef = row.catalogItemRef;
    if (importedRef != null) {
      return CatalogItemRef(
        kind: importedRef.kind,
        id: importedRef.id,
      );
    }
    if (row.mediaKind.isUnknown || row.itemId.trim().isEmpty) {
      return null;
    }
    return CatalogItemRef(
      kind: row.mediaKind,
      id: row.itemId,
    );
  }

  /// Entry envelopes use their local ID for entry matching. Wishlist state is
  /// a separate Catalog Item relationship, so recover it from the explicit
  /// CSV reference or Core provenance instead of reusing the local entry ID.
  CatalogItemRef? _wishlistCatalogRefForRow(CollectionImportRow row) {
    final explicitRef = row.catalogItemRef;
    if (explicitRef != null) {
      return CatalogItemRef(
        kind: explicitRef.kind,
        id: explicitRef.id,
      );
    }
    final rawSource = row.fullEntryPayload?['source_catalog_ref'];
    if (rawSource is! Map) return null;
    final source =
        CatalogItemRef.fromJson(Map<String, Object?>.from(rawSource));
    return CatalogItemRef(
      kind: source.kind,
      id: source.id,
    );
  }

  /// Lets the owning CSV projection create the catalog transport item.
  ///
  /// Collection only normalizes the structural identity cell needed by the
  /// serialization boundary. It must not reconstruct a rich
  /// when the row did not come from a complete kind-entry catalog projection.
  CatalogImportTransport? _catalogTransportFromCsvRow(
    CollectionImportRow row,
  ) {
    final projection = _profileForKind(row.mediaKind);
    final cells = _catalogImportCells(row);
    if (projection == null || cells == null) {
      return null;
    }
    return projection.catalogTransportFromImportCells(cells);
  }

  List<String>? _catalogImportCells(CollectionImportRow row) {
    if (row.itemId.trim().isEmpty ||
        row.kindCatalogCells.length != collectionCsvV1CatalogCellCount) {
      return null;
    }

    final cells = [...row.kindCatalogCells];
    if (cells[0].trim().isEmpty) cells[0] = row.itemId;
    return cells;
  }

  ({String? barcode, String? primary}) _importLookupValues(
    CollectionImportRow row,
  ) {
    final projection = _profileForKind(row.mediaKind);
    if (projection == null ||
        row.kindCatalogCells.length != collectionCsvV1CatalogCellCount) {
      return (barcode: null, primary: null);
    }
    return (
      barcode: projection.importBarcode(row.kindCatalogCells),
      primary: projection.importPrimaryLookupValue(row.kindCatalogCells),
    );
  }

  Future<_EntryImport> _libraryEntryImportFromCsvRow(
    CollectionImportRow row,
    DateTime now, {
    required JsonMap catalogData,
    LibraryEntrySummary? existingSummary,
    JsonMap? existingPayload,
    CatalogMediaKind? catalogKind,
  }) async {
    final kind = existingSummary?.ref.kind ?? catalogKind ?? row.mediaKind;
    if (row.fullEntryPayload case final fullPayload?) {
      final incoming = LibraryEntryRecord.fromJson(fullPayload);
      if (incoming.kind != kind) {
        throw FormatException(
          'CSV entry kind ${incoming.kind.apiValue} does not match ${kind.apiValue}.',
        );
      }
      final incomingRef = LibraryEntryRef(
        kind: incoming.kind,
        id: LibraryEntryId(incoming.id),
      );
      final existingById = await libraryEntries.payloadByRef(incomingRef);
      final useExistingIdentity = existingSummary?.ref == incomingRef;
      final id = existingById == null || useExistingIdentity
          ? incoming.id
          : idGenerator();
      final personalData = Map<String, dynamic>.from(incoming.personalData);
      if (row.personal.quantity != null) {
        personalData['quantity'] = row.personal.quantity;
      }
      final importedRecord = LibraryEntryRecord(
        id: id,
        kind: kind,
        catalogData: incoming.catalogData,
        personalData: personalData,
        sourceCatalogRef: incoming.sourceCatalogRef,
        updatedAt: now,
      );
      final ref = LibraryEntryRef(kind: kind, id: LibraryEntryId(id));
      // This transport target is the entry itself. The optional Core identity
      // is carried only by source_catalog_ref inside the full record.
      return (
        ref: ref,
        transport: EntryImportTransport(
          ref: ref,
          payload: JsonMap.from(importedRecord.toJson()),
        ),
      );
    }
    final personal = row.personal;
    final projection = _profileForKind(kind);
    if (projection != null) {
      final libraryEntryRef = existingSummary?.ref ??
          LibraryEntryRef(
            kind: kind,
            id: LibraryEntryId(idGenerator()),
          );
      final transport = projection.libraryEntryImportTransport(
        CollectionCsvEntryImport(
          id: libraryEntryRef.id.value,
          kind: kind,
          sourceCatalogItemRef: row.catalogItemRef,
          now: now,
          existingPayload: existingPayload,
          condition: personal.condition,
          purchaseDate: personal.purchaseDate,
          pricePaidCents: personal.pricePaidCents,
          currency: personal.currency,
          personalNotes: personal.notes,
          locationId: personal.locationId,
          indexNumber: personal.indexNumber,
          tags: personal.tags,
          soldAt: personal.soldAt,
          sellPriceCents: personal.sellPriceCents,
          soldTo: personal.soldTo,
          quantity: personal.quantity,
          kindEntryCells: row.kindEntryCells,
          catalogData: catalogData,
        ),
      );
      return (
        ref: libraryEntryRef,
        transport: transport,
      );
    }
    throw StateError('No CSV projection registered for ${kind.apiValue}.');
  }

  Future<JsonMap> _catalogDataForEntryImport(
    CollectionImportRow row,
    CatalogItemRef ref,
    Map<CatalogItemRef, CatalogImportTransport> imported,
  ) async {
    final complete = row.fullEntryPayload?['catalog_data'];
    if (complete is Map) return Map<String, dynamic>.from(complete);
    final importedTransport = imported[ref];
    if (importedTransport != null) {
      return importedTransport.decodeItem().kindData;
    }
    final existing = await catalogTransport.findCatalogItem(ref);
    if (existing != null) return existing.kindData;
    return {if (row.title?.trim().isNotEmpty ?? false) 'title': row.title};
  }

  Future<void> _writeCsvCustomFields(
    CollectionImportRow row,
    LibraryEntryRef ref,
    DateTime now,
  ) async {
    if (row.fullEntryPayload != null || row.customFieldValues.isEmpty) return;
    final repository = CustomFieldRepository(libraryEntries.database);
    final definitions = await repository.listDefinitions(
      mediaKind: ref.kind.apiValue,
      targetScope: CustomFieldTargetScope.libraryEntry,
    );
    final definitionsByName = {
      for (final definition in definitions)
        definition.name.trim().toLowerCase(): definition,
    };
    final values = <CustomFieldValue>[];
    for (final cell in row.customFieldValues.entries) {
      final value = cell.value?.trim();
      if (value == null || value.isEmpty) continue;
      final key = cell.key.trim().toLowerCase();
      var definition = definitionsByName[key];
      if (definition == null) {
        definition = CustomFieldDefinition(
          id: idGenerator(),
          name: cell.key,
          fieldType: CustomFieldValueType.text.apiValue,
          mediaKind: ref.kind.apiValue,
          editScope: CustomFieldTargetScope.libraryEntry.apiValue,
          createdAt: now,
        );
        await repository.upsertDefinition(definition);
        definitionsByName[key] = definition;
      }
      values.add(
        CustomFieldValue(
          id: idGenerator(),
          targetId: ref.key,
          targetScope: CustomFieldTargetScope.libraryEntry,
          fieldDefinitionId: definition.id,
          value: value,
          updatedAt: now,
        ),
      );
    }
    await repository.upsertValues(values);
  }

  CollectionCsvKindProfile? _profileForKind(CatalogMediaKind kind) =>
      _csvProfiles[kind];

  Map<CatalogItemRef, LibraryEntrySummary> _entrySummariesByTarget(
      Iterable<LibraryEntrySummary> summaries,
      Iterable<CatalogItemRef> targets,
      {required bool includeRootScope}) {
    final targetSet = targets.toSet();
    final targetRoots = {for (final target in targetSet) target};
    final result = <CatalogItemRef, LibraryEntrySummary>{};
    for (final summary in summaries) {
      final localRef = CatalogItemRef(
        kind: summary.ref.kind,
        id: summary.ref.id.value,
      );
      final sourceRef = summary.sourceCatalogRef == null
          ? null
          : CatalogItemRef(
              kind: summary.sourceCatalogRef!.kind,
              id: summary.sourceCatalogRef!.id,
            );
      final candidates = [localRef, if (sourceRef != null) sourceRef];
      for (final candidate in candidates) {
        if (!targetSet.contains(candidate) &&
            !targetRoots.contains(candidate)) {
          continue;
        }
        // CSV may identify a local record by either its local identity or its
        // Core provenance. Both resolve to the same independently editable
        // entry, while persistence continues to store provenance separately.
        result[localRef] = summary;
        result[candidate] = summary;
        if (includeRootScope) {
          result[localRef] = summary;
          result[candidate] = summary;
        }
      }
    }
    return result;
  }
}

typedef _EntryImport = ({
  LibraryEntryRef ref,
  EntryImportTransport transport,
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
