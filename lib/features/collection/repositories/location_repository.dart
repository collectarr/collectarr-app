import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class LocationRepository {
  LocationRepository(this._db);

  static const _entityType = 'location';
  static const _uuid = Uuid();

  final LocalDatabase _db;

  Future<List<StorageLocation>> getAll() async {
    final rows = await (_db.select(_db.locationsCache)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows
        .map((r) => StorageLocation(
              id: r.id,
              name: r.name,
              parentId: r.parentId,
              description: r.description,
              sortOrder: r.sortOrder,
            ))
        .toList();
  }

  Future<StorageLocation?> getById(String id) async {
    final row = await (_db.select(_db.locationsCache)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return StorageLocation(
      id: row.id,
      name: row.name,
      parentId: row.parentId,
      description: row.description,
      sortOrder: row.sortOrder,
    );
  }

  Future<StorageLocation> create({
    required String name,
    String? parentId,
    String? description,
  }) async {
    final id = _uuid.v4();
    return _db.transaction(() async {
      final maxSort = await _db.customSelect(
        'SELECT COALESCE(MAX(sort_order), 0) AS m FROM locations_cache',
      ).getSingle();
      final sortOrder = (maxSort.data['m'] as int) + 1;

      final location = StorageLocation(
        id: id,
        name: name,
        parentId: parentId,
        description: description,
        sortOrder: sortOrder,
      );
      await _writeLocation(location);
      await _enqueueLocationChange(location, 'upsert');
      return location;
    });
  }

  Future<void> update(StorageLocation location) async {
    await _db.transaction(() async {
      await _writeLocation(location);
      await _enqueueLocationChange(location, 'upsert');
    });
  }

  Future<void> delete(String id) async {
    final existing = await getById(id);
    await _db.transaction(() async {
      await _deleteLocationRow(id);
      if (existing != null) {
        await _enqueueLocationChange(existing, 'delete');
      }
    });
  }

  Future<void> applySyncedUpsert(StorageLocation location) {
    return _writeLocation(location);
  }

  Future<void> applySyncedDelete(String id) {
    return _deleteLocationRow(id);
  }

  Future<void> assignItemToLocation(
      String ownedItemId, String? locationId) async {
    await (_db.update(_db.ownedItemsCache)
          ..where((t) => t.id.equals(ownedItemId)))
        .write(OwnedItemsCacheCompanion(locationId: Value(locationId)));
  }

  Future<String?> getItemLocationId(String ownedItemId) async {
    final row = await (_db.select(_db.ownedItemsCache)
          ..where((t) => t.id.equals(ownedItemId)))
        .getSingleOrNull();
    return row?.locationId;
  }

  Future<void> _writeLocation(StorageLocation location) {
    return _db.into(_db.locationsCache).insertOnConflictUpdate(
          LocationsCacheCompanion.insert(
            id: location.id,
            name: location.name,
            parentId: Value(location.parentId),
            description: Value(location.description),
            sortOrder: Value(location.sortOrder),
          ),
        );
  }

  Future<void> _deleteLocationRow(String id) async {
    await (_db.update(_db.locationsCache)
          ..where((t) => t.parentId.equals(id)))
        .write(const LocationsCacheCompanion(parentId: Value(null)));
    await (_db.update(_db.ownedItemsCache)
          ..where((t) => t.locationId.equals(id)))
        .write(const OwnedItemsCacheCompanion(locationId: Value(null)));
    await (_db.delete(_db.locationsCache)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _enqueueLocationChange(
    StorageLocation location,
    String action,
  ) {
    return SyncQueueRepository(_db).enqueue(
      SyncChange(
        id: _uuid.v4(),
        entityType: _entityType,
        entityId: location.id,
        action: action,
        payload: location.toSyncPayload(),
        clientChangedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
