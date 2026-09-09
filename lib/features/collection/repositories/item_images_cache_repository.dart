import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:drift/drift.dart';

class ItemImagesCacheRepository {
  const ItemImagesCacheRepository(this._db);

  final LocalDatabase _db;

  /// Upsert an image entry (insert or replace by id).
  Future<void> upsert({
    required String id,
    required OwnedItemRef ownedRef,
    required String imageType,
    required Uint8List imageData,
    String? caption,
    int sortOrder = 0,
  }) async {
    await _db.into(_db.itemImagesCache).insertOnConflictUpdate(
          ItemImagesCacheCompanion.insert(
            id: id,
            ownedItemId: ownedRef.key,
            imageType: Value(imageType),
            imageData: imageData,
            caption: Value(caption),
            sortOrder: Value(sortOrder),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Get all images for an owned item, ordered by sort order.
  Future<List<ItemImagesCacheData>> listByOwnedRef(
      OwnedItemRef ownedRef) async {
    return (_db.select(_db.itemImagesCache)
          ..where((row) => row.ownedItemId.equals(ownedRef.key))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
  }

  /// Get the primary (first) image of a given type for an owned item.
  Future<ItemImagesCacheData?> primaryImageForItem(
    OwnedItemRef ownedRef, {
    String imageType = 'front_cover',
  }) async {
    return (_db.select(_db.itemImagesCache)
          ..where((row) =>
              row.ownedItemId.equals(ownedRef.key) &
              row.imageType.equals(imageType))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get front cover bytes for an owned item (for display).
  Future<Uint8List?> frontCoverBytes(OwnedItemRef ownedRef) async {
    final row = await primaryImageForItem(ownedRef);
    return row?.imageData;
  }

  /// Delete all images for an owned item.
  Future<void> deleteByOwnedRef(OwnedItemRef ownedRef) async {
    await (_db.delete(_db.itemImagesCache)
          ..where((row) => row.ownedItemId.equals(ownedRef.key)))
        .go();
  }

  /// Delete a specific image by id.
  Future<void> deleteById(String id) async {
    await (_db.delete(_db.itemImagesCache)..where((row) => row.id.equals(id)))
        .go();
  }
}
