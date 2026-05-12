import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:drift/drift.dart';

class WishlistItemsCacheRepository {
  const WishlistItemsCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<List<WishlistItem>> listActive() async {
    final rows = await (_db.select(_db.wishlistItemsCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows.map(_fromCache).toList(growable: false);
  }

  Future<WishlistItem?> findActiveByItemId(String itemId) async {
    final rows = await (_db.select(_db.wishlistItemsCache)
          ..where((row) => row.itemId.equals(itemId) & row.deletedAt.isNull())
          ..limit(1))
        .get();
    if (rows.isEmpty) {
      return null;
    }
    return _fromCache(rows.first);
  }

  Future<List<WishlistItem>> findActiveByItemIds(
      Iterable<String> itemIds) async {
    final values = itemIds.toSet().toList(growable: false);
    if (values.isEmpty) {
      return const [];
    }
    final items = <WishlistItem>[];
    for (var index = 0; index < values.length; index += _lookupBatchSize) {
      final end = (index + _lookupBatchSize).clamp(0, values.length);
      final batch = values.sublist(index, end);
      final rows = await (_db.select(_db.wishlistItemsCache)
            ..where(
              (row) => row.itemId.isIn(batch) & row.deletedAt.isNull(),
            ))
          .get();
      items.addAll(rows.map(_fromCache));
    }
    return items;
  }

  Future<void> upsert(WishlistItem item) {
    return _db.into(_db.wishlistItemsCache).insert(
          _toCompanion(item),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> upsertAll(List<WishlistItem> items) async {
    if (items.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.wishlistItemsCache,
        items.map(_toCompanion),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> markDeleted(WishlistItem item, DateTime deletedAt) {
    return _db.into(_db.wishlistItemsCache).insert(
          _toCompanion(
              item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt)),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> markDeletedAll(
      List<WishlistItem> items, DateTime deletedAt) async {
    if (items.isEmpty) {
      return;
    }
    await _db.batch((batch) {
      batch.insertAll(
        _db.wishlistItemsCache,
        items.map(
          (item) => _toCompanion(
            item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  WishlistItem _fromCache(WishlistItemsCacheData row) {
    return WishlistItem(
      id: row.id,
      itemId: row.itemId,
      editionId: row.editionId,
      variantId: row.variantId,
      targetPriceCents: row.targetPriceCents,
      currency: row.currency,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  WishlistItemsCacheCompanion _toCompanion(WishlistItem item) {
    return WishlistItemsCacheCompanion.insert(
      id: item.id,
      itemId: item.itemId,
      editionId: Value(item.editionId),
      variantId: Value(item.variantId),
      targetPriceCents: Value(item.targetPriceCents),
      currency: Value(item.currency),
      notes: Value(item.notes),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
    );
  }
}
