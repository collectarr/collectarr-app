import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_codec.dart';
import 'package:drift/drift.dart';

class TrackingUnitsCacheRepository {
  TrackingUnitsCacheRepository(
    this._db, {
    required Iterable<TrackingUnitCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<String, TrackingUnitCodec> _codecs;

  Future<List<TrackingUnit>> listActive() async {
    final rows = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.deletedAt.isNull()))
        .get();
    final coordinates = await _loadCoordinates();
    return _toModels(rows, coordinates);
  }

  Future<List<TrackingUnit>> findActiveByItemIds(
    Iterable<String> itemIds,
  ) async {
    final ids = itemIds
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) {
      return const <TrackingUnit>[];
    }
    final rows = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.deletedAt.isNull() & tbl.itemId.isIn(ids)))
        .get();
    final coordinates = await _loadCoordinates(
      rows.map((row) => row.id),
    );
    return _toModels(rows, coordinates);
  }

  Future<TrackingUnit?> findById(String id) async {
    final row = await (_db.select(_db.trackingUnitsCache)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final coordinates = await _loadCoordinates([row.id]);
    return _toModel(row, coordinates[row.id]);
  }

  Future<void> upsert(TrackingUnit unit) async {
    await _db.transaction(() async {
      await _db.into(_db.trackingUnitsCache).insertOnConflictUpdate(
            _toBaseCompanion(unit),
          );
      await _replaceCoordinates(unit);
    });
  }

  Future<void> upsertAll(Iterable<TrackingUnit> units) async {
    final values = units.toList(growable: false);
    if (values.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.trackingUnitsCache,
          values.map(_toBaseCompanion).toList(growable: false),
        );
      });
      for (final unit in values) {
        await _replaceCoordinates(unit);
      }
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

  TrackingUnitsCacheCompanion _toBaseCompanion(TrackingUnit unit) {
    return TrackingUnitsCacheCompanion(
      id: Value(unit.id),
      itemId: Value(unit.itemId),
      kind: Value(unit.targetRef.kind),
      trackingEntryId: Value(unit.trackingEntryId),
      ownedItemId: Value(unit.ownedItemId),
      editionId: Value(unit.editionId),
      variantId: Value(unit.variantId),
      bundleReleaseId: Value(unit.bundleReleaseId),
      unitType: Value(unit.unitType),
      completedAt: Value(unit.completedAt),
      updatedAt: Value(unit.updatedAt),
      deletedAt: Value(unit.deletedAt),
    );
  }

  Future<void> _replaceCoordinates(TrackingUnit unit) async {
    for (final codec in _codecs.values) {
      await codec.clearCoordinates(_db, unit.id);
    }
    final codec = _codecs[unit.targetRef.kind];
    if (codec == null) {
      throw StateError(
        'No tracking-unit codec is registered for kind '
        '"${unit.targetRef.kind}".',
      );
    }
    await codec.writeCoordinates(_db, unit);
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

  List<TrackingUnit> _toModels(
    List<TrackingUnitsCacheData> rows,
    Map<String, Object?> coordinates,
  ) {
    final models = [
      for (final row in rows) _toModel(row, coordinates[row.id]),
    ];
    models.sort(_compareForDisplay);
    return models;
  }

  TrackingUnit _toModel(
    TrackingUnitsCacheData row,
    Object? coordinates,
  ) {
    final targetRef = CatalogEntityRef(
      kind: row.kind,
      entityType: CatalogEntityType.work,
      id: row.itemId,
    );
    final storageRow = TrackingUnitStorageRow(
      id: row.id,
      targetRef: targetRef,
      trackingEntryId: row.trackingEntryId,
      ownedItemId: row.ownedItemId,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      unitType: row.unitType,
      completedAt: row.completedAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
    final codec = _codecs[row.kind];
    if (codec == null) {
      throw StateError(
        'No tracking-unit codec is registered for kind "${row.kind}".',
      );
    }
    return codec.fromStorageRow(storageRow, coordinates);
  }

  int _compareForDisplay(TrackingUnit a, TrackingUnit b) {
    final itemCompare = a.itemId.compareTo(b.itemId);
    if (itemCompare != 0) return itemCompare;
    final typeCompare = a.unitType.compareTo(b.unitType);
    if (typeCompare != 0) return typeCompare;
    final coordinatesCompare =
        _codecs[a.targetRef.kind]?.compareCoordinates(a, b) ?? 0;
    if (coordinatesCompare != 0) return coordinatesCompare;
    return b.updatedAt.compareTo(a.updatedAt);
  }
}
