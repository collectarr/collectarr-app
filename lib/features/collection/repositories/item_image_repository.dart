import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:drift/drift.dart';

class ItemImageRepository {
  const ItemImageRepository(this._db);

  final LocalDatabase _db;

  Future<List<ItemImage>> listForItem(String ownedItemId) async {
    final rows = await (_db.select(_db.itemImagesCache)
          ..where((row) => row.ownedItemId.equals(ownedItemId))
          ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<Map<String, List<ItemImage>>> listForOwnedItemIds(
    Iterable<String> ownedItemIds,
  ) async {
    final ids = ownedItemIds.where((value) => value.isNotEmpty).toSet().toList(
          growable: false,
        );
    if (ids.isEmpty) {
      return const <String, List<ItemImage>>{};
    }
    final rows = await (_db.select(_db.itemImagesCache)
          ..where((row) => row.ownedItemId.isIn(ids))
          ..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
    final grouped = <String, List<ItemImage>>{};
    for (final row in rows) {
      grouped
          .putIfAbsent(row.ownedItemId, () => <ItemImage>[])
          .add(_fromRow(row));
    }
    return grouped;
  }

  Future<void> add(ItemImage image) {
    return _db.into(_db.itemImagesCache).insert(
          ItemImagesCacheCompanion.insert(
            id: image.id,
            ownedItemId: image.ownedItemId,
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

  Future<void> deleteAllForItem(String ownedItemId) {
    return (_db.delete(_db.itemImagesCache)
          ..where((row) => row.ownedItemId.equals(ownedItemId)))
        .go();
  }

  Future<int> countForItem(String ownedItemId) async {
    final count = _db.itemImagesCache.id.count();
    final query = _db.selectOnly(_db.itemImagesCache)
      ..addColumns([count])
      ..where(_db.itemImagesCache.ownedItemId.equals(ownedItemId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  ItemImage _fromRow(ItemImagesCacheData row) {
    return ItemImage(
      id: row.id,
      ownedItemId: row.ownedItemId,
      imageType: row.imageType,
      imageData: row.imageData,
      caption: row.caption,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
    );
  }
}
