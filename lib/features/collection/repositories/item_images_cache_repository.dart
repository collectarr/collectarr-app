import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class ItemImagesCacheRepository {
  const ItemImagesCacheRepository(this._db);

  final LocalDatabase _db;

  /// Upsert an image entry (insert or replace by id).
  Future<void> upsert({
    required String id,
    required CollectionItemRef collectionItemRef,
    required String imageType,
    required Uint8List imageData,
    String? caption,
    int sortOrder = 0,
  }) async {
    requireKnownCollectionItemRef(collectionItemRef);
    await _db.into(_db.itemImagesCache).insertOnConflictUpdate(
          ItemImagesCacheCompanion.insert(
            id: id,
            collectionItemRefKey: collectionItemRef.key,
            imageType: Value(imageType),
            imageData: imageData,
            caption: Value(caption),
            sortOrder: Value(sortOrder),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Get all images for a collection item, ordered by sort order.
  Future<List<ItemImagesCacheData>> listByCollectionItemRef(
      CollectionItemRef collectionItemRef) async {
    requireKnownCollectionItemRef(collectionItemRef);
    return (_db.select(_db.itemImagesCache)
          ..where((row) => row.collectionItemRefKey.equals(collectionItemRef.key))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
  }

  /// Get the primary (first) image of a given type for a collection item.
  Future<ItemImagesCacheData?> primaryImageForItem(
    CollectionItemRef collectionItemRef, {
    String imageType = 'front_cover',
  }) async {
    requireKnownCollectionItemRef(collectionItemRef);
    return (_db.select(_db.itemImagesCache)
          ..where((row) =>
              row.collectionItemRefKey.equals(collectionItemRef.key) &
              row.imageType.equals(imageType))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get front cover bytes for a collection item (for display).
  Future<Uint8List?> frontCoverBytes(CollectionItemRef collectionItemRef) async {
    final row = await primaryImageForItem(collectionItemRef);
    return row?.imageData;
  }

  /// Delete all images for a collection item.
  Future<void> deleteByCollectionItemRef(CollectionItemRef collectionItemRef) async {
    requireKnownCollectionItemRef(collectionItemRef);
    await (_db.delete(_db.itemImagesCache)
          ..where((row) => row.collectionItemRefKey.equals(collectionItemRef.key)))
        .go();
  }

  /// Delete a specific image by id.
  Future<void> deleteById(String id) async {
    await (_db.delete(_db.itemImagesCache)..where((row) => row.id.equals(id)))
        .go();
  }
}
