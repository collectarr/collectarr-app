import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:drift/drift.dart';

class OwnedItemsCacheRepository {
  const OwnedItemsCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<OwnedItem>> listActive() async {
    final rows = await (_db.select(_db.ownedItemsCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows.map(_fromCache).toList(growable: false);
  }

  Future<void> replaceAll(List<OwnedItem> items) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.ownedItemsCache);
      if (items.isNotEmpty) {
        batch.insertAll(
          _db.ownedItemsCache,
          items.map(_toCompanion),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> upsertAll(List<OwnedItem> items) async {
    if (items.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.ownedItemsCache,
        items.map(_toCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> upsert(OwnedItem item) {
    return _db.into(_db.ownedItemsCache).insert(
          _toCompanion(item),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> markDeleted(OwnedItem item, DateTime deletedAt) {
    return _db.into(_db.ownedItemsCache).insert(
          _toCompanion(
              item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt)),
          mode: InsertMode.insertOrReplace,
        );
  }

  OwnedItem _fromCache(OwnedItemsCacheData row) {
    return OwnedItem(
      id: row.id,
      itemId: row.itemId,
      editionId: row.editionId,
      variantId: row.variantId,
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      storageBox: row.storageBox,
      indexNumber: row.indexNumber,
      coverPriceCents: row.coverPriceCents,
      rawOrSlabbed: row.rawOrSlabbed,
      gradingCompany: row.gradingCompany,
      graderNotes: row.graderNotes,
      signedBy: row.signedBy,
      keyComic: row.keyComic,
      keyReason: row.keyReason,
      rating: row.rating,
      readStatus: row.readStatus,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  OwnedItemsCacheCompanion _toCompanion(OwnedItem item) {
    return OwnedItemsCacheCompanion.insert(
      id: item.id,
      itemId: item.itemId,
      editionId: Value(item.editionId),
      variantId: Value(item.variantId),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      quantity: Value(item.quantity),
      storageBox: Value(item.storageBox),
      indexNumber: Value(item.indexNumber),
      coverPriceCents: Value(item.coverPriceCents),
      rawOrSlabbed: Value(item.rawOrSlabbed),
      gradingCompany: Value(item.gradingCompany),
      graderNotes: Value(item.graderNotes),
      signedBy: Value(item.signedBy),
      keyComic: Value(item.keyComic),
      keyReason: Value(item.keyReason),
      rating: Value(item.rating),
      readStatus: Value(item.readStatus),
      tags: Value(item.tags),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
    );
  }
}
