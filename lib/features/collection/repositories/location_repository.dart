import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class LocationRepository {
  LocationRepository(this._db);

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
    final id = const Uuid().v4();
    final maxSort = await _db.customSelect(
      'SELECT COALESCE(MAX(sort_order), 0) AS m FROM locations_cache',
    ).getSingle();
    final sortOrder = (maxSort.data['m'] as int) + 1;

    await _db.into(_db.locationsCache).insert(LocationsCacheCompanion.insert(
          id: id,
          name: name,
          parentId: Value(parentId),
          description: Value(description),
          sortOrder: Value(sortOrder),
        ));

    return StorageLocation(
      id: id,
      name: name,
      parentId: parentId,
      description: description,
      sortOrder: sortOrder,
    );
  }

  Future<void> update(StorageLocation location) async {
    await (_db.update(_db.locationsCache)
          ..where((t) => t.id.equals(location.id)))
        .write(LocationsCacheCompanion(
      name: Value(location.name),
      parentId: Value(location.parentId),
      description: Value(location.description),
      sortOrder: Value(location.sortOrder),
    ));
  }

  Future<void> delete(String id) async {
    // Unparent children
    await (_db.update(_db.locationsCache)
          ..where((t) => t.parentId.equals(id)))
        .write(const LocationsCacheCompanion(parentId: Value(null)));
    // Clear locationId on owned items
    await (_db.update(_db.ownedItemsCache)
          ..where((t) => t.locationId.equals(id)))
        .write(const OwnedItemsCacheCompanion(locationId: Value(null)));
    // Delete the location
    await (_db.delete(_db.locationsCache)..where((t) => t.id.equals(id))).go();
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
}
