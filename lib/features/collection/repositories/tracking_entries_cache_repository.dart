import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/tracking/tracking_entry_codec.dart';
import 'package:drift/drift.dart';

class TrackingEntriesCacheRepository {
  TrackingEntriesCacheRepository(
    this._db, {
    required Iterable<TrackingEntryCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;
  final Map<String, TrackingEntryCodec> _codecs;

  Future<List<TrackingEntry>> listActive() async {
    final rows = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    if (rows.isEmpty) return const [];
    final coordinates = await _loadCoordinates(rows.map((row) => row.id));
    return rows
        .map((r) => _fromCache(r, coordinates[r.id], catalogKind: r.kind))
        .toList(growable: false);
  }

  Future<TrackingEntry?> findById(String id) async {
    final row = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    final coordinates = await _loadCoordinates([row.id]);
    return _fromCache(row, coordinates[row.id], catalogKind: row.kind);
  }

  Future<List<TrackingEntry>> findActiveByItemIds(
      Iterable<String> itemIds) async {
    final values = itemIds.toSet().toList(growable: false);
    if (values.isEmpty) {
      return const [];
    }
    final items = <TrackingEntry>[];
    for (var index = 0; index < values.length; index += _lookupBatchSize) {
      final end = (index + _lookupBatchSize).clamp(0, values.length);
      final batch = values.sublist(index, end);
      final rows = await (_db.select(_db.trackingEntriesCache)
            ..where(
              (row) => row.itemId.isIn(batch) & row.deletedAt.isNull(),
            ))
          .get();
      final coordinates = await _loadCoordinates(rows.map((row) => row.id));
      items.addAll(
        rows.map(
          (r) => _fromCache(r, coordinates[r.id], catalogKind: r.kind),
        ),
      );
    }
    return items;
  }

  Future<void> upsert(TrackingEntry item) async {
    await _db.transaction(() async {
      await _db.into(_db.trackingEntriesCache).insert(
            _toCompanion(item),
            mode: InsertMode.insertOrReplace,
          );
      await _replaceCoordinates(item);
    });
  }

  Future<void> upsertAll(List<TrackingEntry> items) async {
    if (items.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAll(
          _db.trackingEntriesCache,
          items.map(_toCompanion),
          mode: InsertMode.insertOrReplace,
        );
      });
      for (final item in items) {
        await _replaceCoordinates(item);
      }
    });
  }

  Future<void> markDeleted(TrackingEntry item, DateTime deletedAt) {
    return upsert(item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt));
  }

  Map<String, dynamic> toSyncPayload(TrackingEntry entry) {
    return _codecs[entry.catalogRef.kind]?.toSyncPayload(entry) ??
        entry.toSyncPayload();
  }

  TrackingEntry _fromCache(
    TrackingEntriesCacheData row,
    Object? coordinates, {
    String? catalogKind,
  }) {
    final storageRow = TrackingEntryStorageRow(
      id: row.id,
      catalogRef: _catalogRefForRow(row, catalogKind: catalogKind),
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
    return _codecs[row.kind]?.fromStorageRow(storageRow, coordinates) ??
        TrackingEntry(
          id: storageRow.id,
          catalogRef: storageRow.catalogRef,
          ownedItemId: storageRow.ownedItemId,
          editionId: storageRow.editionId,
          variantId: storageRow.variantId,
          bundleReleaseId: storageRow.bundleReleaseId,
          sourceType: storageRow.sourceType,
          status: storageRow.status,
          rating: storageRow.rating,
          startedAt: storageRow.startedAt,
          finishedAt: storageRow.finishedAt,
          progressCurrent: storageRow.progressCurrent,
          progressTotal: storageRow.progressTotal,
          timesCompleted: storageRow.timesCompleted,
          notes: storageRow.notes,
          updatedAt: storageRow.updatedAt,
          deletedAt: storageRow.deletedAt,
        );
  }

  TrackingEntriesCacheCompanion _toCompanion(TrackingEntry item) {
    return TrackingEntriesCacheCompanion.insert(
      id: item.id,
      itemId: item.itemId,
      kind: Value(item.catalogRef.kind),
      ownedItemId: Value(item.ownedItemId),
      editionId: Value(item.editionId),
      variantId: Value(item.variantId),
      bundleReleaseId: Value(item.bundleReleaseId),
      sourceType: Value(item.sourceTypeApiValue),
      status: Value(item.statusStorageValue),
      rating: Value(item.rating),
      startedAt: Value(item.startedAt),
      finishedAt: Value(item.finishedAt),
      progressCurrent: Value(item.progressCurrent),
      progressTotal: Value(item.progressTotal),
      timesCompleted: Value(item.timesCompleted),
      notes: Value(item.notes),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
    );
  }

  Future<void> _replaceCoordinates(TrackingEntry item) async {
    for (final codec in _codecs.values) {
      await codec.clearCoordinates(_db, item.id);
    }
    await _codecs[item.catalogRef.kind]?.writeCoordinates(_db, item);
  }

  Future<Map<String, Object?>> _loadCoordinates([
    Iterable<String>? ids,
  ]) async {
    final coordinates = <String, Object?>{};
    for (final codec in _codecs.values) {
      coordinates.addAll(await codec.loadCoordinates(_db, ids));
    }
    return coordinates;
  }

  CatalogEntityRef _catalogRefForRow(TrackingEntriesCacheData row,
      {String? catalogKind}) {
    final anchor = PersonalItemAnchor.fromRaw(
      anchorType: row.sourceType,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
    );
    final entityType = switch (anchor?.type) {
      PersonalItemAnchorType.bundleRelease => CatalogEntityType.release,
      PersonalItemAnchorType.variant => CatalogEntityType.release,
      PersonalItemAnchorType.edition => CatalogEntityType.edition,
      _ => CatalogEntityType.work,
    };
    return CatalogEntityRef(
      kind: catalogKind ?? 'unknown',
      entityType: entityType,
      id: row.itemId,
    );
  }
}
