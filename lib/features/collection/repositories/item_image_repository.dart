import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';
import 'package:drift/drift.dart';

class ItemImageRepository {
  const ItemImageRepository(this._db);

  final LocalDatabase _db;

  Future<List<ItemImage>> listForCollectionItemRef(CollectionItemRef collectionItemRef) async {
    requireKnownCollectionItemRef(collectionItemRef);
    final rows = await (_db.select(_db.itemImagesCache)
          ..where((row) => row.collectionItemRefKey.equals(collectionItemRef.key))
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<Map<CollectionItemRef, List<ItemImage>>> listForCollectionItemRefs(
    Iterable<CollectionItemRef> collectionItemRefs,
  ) async {
    final refs = collectionItemRefs.toSet().toList(growable: false);
    for (final ref in refs) {
      requireKnownCollectionItemRef(ref);
    }
    if (refs.isEmpty) {
      return const <CollectionItemRef, List<ItemImage>>{};
    }
    final keys = refs.map((ref) => ref.key).toList(growable: false);
    final rows = await (_db.select(_db.itemImagesCache)
          ..where((row) => row.collectionItemRefKey.isIn(keys))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    final grouped = <CollectionItemRef, List<ItemImage>>{};
    for (final row in rows) {
      final ref = CollectionItemRef.fromKey(row.collectionItemRefKey);
      grouped.putIfAbsent(ref, () => <ItemImage>[]).add(_fromRow(row));
    }
    return grouped;
  }

  Future<void> add(ItemImage image) {
    requireKnownCollectionItemRef(image.collectionItemRef);
    return _db.into(_db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: image.id,
            collectionItemRefKey: image.collectionItemRef.key,
            imageType: Value(image.imageType),
            imageData: image.imageData,
            caption: Value(image.caption),
            sortOrder: Value(image.sortOrder),
            createdAt: image.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  static const Object _unset = Object();

  Future<void> updateMetadata(
    String id, {
    Object? caption = _unset,
    String? imageType,
    int? sortOrder,
  }) async {
    await (_db.update(_db.itemImagesCache)..where((row) => row.id.equals(id)))
        .write(
      ItemImagesCacheCompanion(
        caption: identical(caption, _unset)
            ? const Value.absent()
            : Value(caption as String?),
        imageType: imageType == null ? const Value.absent() : Value(imageType),
        sortOrder: sortOrder == null ? const Value.absent() : Value(sortOrder),
      ),
    );
  }

  Future<void> updateCaption(String id, String? caption) {
    return updateMetadata(id, caption: caption);
  }

  Future<void> delete(String id) {
    return (_db.delete(_db.itemImagesCache)..where((row) => row.id.equals(id)))
        .go();
  }

  Future<void> deleteAllForCollectionItemRef(CollectionItemRef collectionItemRef) {
    requireKnownCollectionItemRef(collectionItemRef);
    return (_db.delete(_db.itemImagesCache)
          ..where((row) => row.collectionItemRefKey.equals(collectionItemRef.key)))
        .go();
  }

  Future<int> countForCollectionItemRef(CollectionItemRef collectionItemRef) async {
    requireKnownCollectionItemRef(collectionItemRef);
    final count = _db.itemImagesCache.id.count();
    final query = _db.selectOnly(_db.itemImagesCache)
      ..addColumns([count])
      ..where(_db.itemImagesCache.collectionItemRefKey.equals(collectionItemRef.key));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  ItemImage _fromRow(ItemImagesCacheData row) {
    return ItemImage(
      id: row.id,
      collectionItemRef: CollectionItemRef.fromKey(row.collectionItemRefKey),
      imageType: row.imageType,
      imageData: row.imageData,
      caption: row.caption,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
    );
  }
}
