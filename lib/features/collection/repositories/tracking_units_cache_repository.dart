import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:drift/drift.dart';

class TrackingUnitsCacheRepository {
  TrackingUnitsCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<TrackingUnit>> listActive() async {
    final rows = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.itemId),
            (tbl) => OrderingTerm.asc(tbl.unitType),
            (tbl) => OrderingTerm.asc(tbl.seasonNumber),
            (tbl) => OrderingTerm.asc(tbl.episodeNumber),
            (tbl) => OrderingTerm.asc(tbl.volumeNumber),
            (tbl) => OrderingTerm.asc(tbl.chapterNumber),
            (tbl) => OrderingTerm.desc(tbl.updatedAt),
          ]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  Future<List<TrackingUnit>> findActiveByItemIds(Iterable<String> itemIds) async {
    final ids = itemIds.where((value) => value.isNotEmpty).toSet().toList(growable: false);
    if (ids.isEmpty) {
      return const <TrackingUnit>[];
    }
    final rows = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.deletedAt.isNull() & tbl.itemId.isIn(ids))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.itemId),
            (tbl) => OrderingTerm.asc(tbl.unitType),
            (tbl) => OrderingTerm.asc(tbl.seasonNumber),
            (tbl) => OrderingTerm.asc(tbl.episodeNumber),
            (tbl) => OrderingTerm.asc(tbl.volumeNumber),
            (tbl) => OrderingTerm.asc(tbl.chapterNumber),
            (tbl) => OrderingTerm.desc(tbl.updatedAt),
          ]))
        .get();
    return rows.map(_toModel).toList(growable: false);
  }

  Future<TrackingUnit?> findById(String id) async {
    final row = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<void> upsert(TrackingUnit unit) async {
    await _db.into(_db.trackingUnitsCache).insertOnConflictUpdate(
          _toCompanion(unit),
        );
  }

  Future<void> upsertAll(Iterable<TrackingUnit> units) async {
    final companions = units.map(_toCompanion).toList(growable: false);
    if (companions.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.trackingUnitsCache, companions);
    });
  }

  Future<void> markDeleted(TrackingUnit unit, DateTime deletedAt) async {
    await (_db.update(_db.trackingUnitsCache)
          ..where((tbl) => tbl.id.equals(unit.id)))
        .write(
      TrackingUnitsCacheCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  Future<void> markDeletedByIds(
    Iterable<String> ids,
    DateTime deletedAt,
  ) async {
    final normalizedIds = ids
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (normalizedIds.isEmpty) {
      return;
    }
    await (_db.update(_db.trackingUnitsCache)
          ..where((tbl) => tbl.id.isIn(normalizedIds) & tbl.deletedAt.isNull()))
        .write(
      TrackingUnitsCacheCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
  }

  TrackingUnitsCacheCompanion _toCompanion(TrackingUnit unit) {
    return TrackingUnitsCacheCompanion(
      id: Value(unit.id),
      itemId: Value(unit.itemId),
      trackingEntryId: Value(unit.trackingEntryId),
      ownedItemId: Value(unit.ownedItemId),
      editionId: Value(unit.editionId),
      variantId: Value(unit.variantId),
      bundleReleaseId: Value(unit.bundleReleaseId),
      unitType: Value(unit.unitType.storageValue),
      seasonNumber: Value(unit.seasonNumber),
      episodeNumber: Value(unit.episodeNumber),
      volumeNumber: Value(unit.volumeNumber),
      chapterNumber: Value(unit.chapterNumber),
      issueNumber: Value(unit.issueNumber),
      completedAt: Value(unit.completedAt),
      updatedAt: Value(unit.updatedAt),
      deletedAt: Value(unit.deletedAt),
    );
  }

  TrackingUnit _toModel(TrackingUnitsCacheData row) {
    return TrackingUnit(
      id: row.id,
      itemId: row.itemId,
      trackingEntryId: row.trackingEntryId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      unitType:
          trackingUnitTypeFromValue(row.unitType) ?? TrackingUnitType.episode,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      volumeNumber: row.volumeNumber,
      chapterNumber: row.chapterNumber,
      issueNumber: row.issueNumber,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }
}