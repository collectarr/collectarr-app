import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class ItemImagesCacheRepository {
  const ItemImagesCacheRepository(this._db);

  final LocalDatabase _db;

  /// Upsert an image entry (insert or replace by id).
  Future<void> upsert({
    required String id,
    required LibraryEntryRef libraryEntryRef,
    required String imageType,
    required Uint8List imageData,
    String? caption,
    int sortOrder = 0,
  }) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    await _db.into(_db.itemImagesCache).insertOnConflictUpdate(
          ItemImagesCacheCompanion.insert(
            id: id,
            libraryEntryRefKey: libraryEntryRef.key,
            imageType: Value(imageType),
            imageData: imageData,
            caption: Value(caption),
            sortOrder: Value(sortOrder),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Get all images for a collection item, ordered by sort order.
  Future<List<ItemImagesCacheData>> listByLibraryEntryRef(
      LibraryEntryRef libraryEntryRef) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    return (_db.select(_db.itemImagesCache)
          ..where((row) => row.libraryEntryRefKey.equals(libraryEntryRef.key))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
  }

  /// Get the primary (first) image of a given type for a collection item.
  Future<ItemImagesCacheData?> primaryImageForItem(
    LibraryEntryRef libraryEntryRef, {
    String imageType = 'front_cover',
  }) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    return (_db.select(_db.itemImagesCache)
          ..where((row) =>
              row.libraryEntryRefKey.equals(libraryEntryRef.key) &
              row.imageType.equals(imageType))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get front cover bytes for a collection item (for display).
  Future<Uint8List?> frontCoverBytes(LibraryEntryRef libraryEntryRef) async {
    final row = await primaryImageForItem(libraryEntryRef);
    return row?.imageData;
  }

  /// Delete all images for a collection item.
  Future<void> deleteByLibraryEntryRef(LibraryEntryRef libraryEntryRef) async {
    requireKnownLibraryEntryRef(libraryEntryRef);
    await (_db.delete(_db.itemImagesCache)
          ..where((row) => row.libraryEntryRefKey.equals(libraryEntryRef.key)))
        .go();
  }

  /// Delete a specific image by id.
  Future<void> deleteById(String id) async {
    await (_db.delete(_db.itemImagesCache)..where((row) => row.id.equals(id)))
        .go();
  }
}
