import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:drift/drift.dart';

class TrackingEntriesCacheRepository {
  const TrackingEntriesCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<List<TrackingEntry>> listActive() async {
    final rows = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows.map(_fromCache).toList(growable: false);
  }

  Future<TrackingEntry?> findById(String id) async {
    final row = await (_db.select(_db.trackingEntriesCache)
          ..where((row) => row.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromCache(row);
  }

  Future<List<TrackingEntry>> findActiveByItemIds(Iterable<String> itemIds) async {
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
      items.addAll(rows.map(_fromCache));
    }
    return items;
  }

  Future<void> upsert(TrackingEntry item) {
    return _db.into(_db.trackingEntriesCache).insert(
          _toCompanion(item),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> upsertAll(List<TrackingEntry> items) async {
    if (items.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.trackingEntriesCache,
        items.map(_toCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(TrackingEntry item, DateTime deletedAt) {
    return _db.into(_db.trackingEntriesCache).insert(
          _toCompanion(
            item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  TrackingEntry _fromCache(TrackingEntriesCacheData row) {
    return TrackingEntry(
      id: row.id,
      itemId: row.itemId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      sourceType: row.sourceType,
      status: row.status,
      rating: row.rating,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      notes: row.notes,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  TrackingEntriesCacheCompanion _toCompanion(TrackingEntry item) {
    return TrackingEntriesCacheCompanion.insert(
      id: item.id,
      itemId: item.itemId,
      ownedItemId: Value(item.ownedItemId),
      editionId: Value(item.editionId),
      variantId: Value(item.variantId),
      sourceType: Value(item.sourceTypeApiValue),
      status: Value(item.statusStorageValue),
      rating: Value(item.rating),
      startedAt: Value(item.startedAt),
      finishedAt: Value(item.finishedAt),
      progressCurrent: Value(item.progressCurrent),
      progressTotal: Value(item.progressTotal),
      timesCompleted: Value(item.timesCompleted),
      notes: Value(item.notes),
      seasonNumber: Value(item.seasonNumber),
      episodeNumber: Value(item.episodeNumber),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
    );
  }
}