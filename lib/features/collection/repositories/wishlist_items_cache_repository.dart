import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:drift/drift.dart';

class WishlistItemsCacheRepository {
  const WishlistItemsCacheRepository(this._db);

  final LocalDatabase _db;

  Future<List<WishlistItem>> listActive() async {
    final rows = await (_db.select(_db.wishlistItemsCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows.map(_fromCache).toList(growable: false);
  }

  Future<WishlistItem?> findById(String id) async {
    final row = await (_db.select(_db.wishlistItemsCache)
          ..where((row) => row.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromCache(row);
  }

  Future<WishlistItem?> findActiveByItemId(String itemId) async {
    final items = await listActiveByItemId(itemId);
    return items.firstOrNull;
  }

  Future<List<WishlistItem>> listActiveByItemId(String itemId) async {
    final rows = await (_db.select(_db.wishlistItemsCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows
        .map(_fromCache)
        .where((item) => item.itemId == itemId)
        .toList(growable: false);
  }

  Future<WishlistItem?> findActiveByItemAnchorValue(
    String itemId,
    PersonalItemAnchor? anchor,
  ) async {
    final items = await listActiveByItemId(itemId);
    for (final item in items) {
      if (_matchesAnchorValue(item, anchor)) {
        return item;
      }
    }
    return null;
  }

  Future<List<WishlistItem>> findActiveByItemIds(
      Iterable<String> itemIds) async {
    final values = itemIds.toSet().toList(growable: false);
    if (values.isEmpty) {
      return const [];
    }
    final items = <WishlistItem>[];
    final rows = await (_db.select(_db.wishlistItemsCache)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final requested = values.toSet();
    for (final row in rows) {
      final item = _fromCache(row);
      if (requested.contains(item.itemId)) {
        items.add(item);
      }
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
    final rawCatalogRef = jsonDecode(row.catalogRefJson);
    if (rawCatalogRef is! Map) {
      throw FormatException(
        'Wishlist row ${row.id} contains an invalid catalog reference',
      );
    }
    final catalogRef = CatalogEntityRef.fromJson(
      Map<String, dynamic>.from(rawCatalogRef),
    );
    return WishlistItem(
      id: row.id,
      catalogRef: catalogRef,
      anchor: _anchorFromCatalogRef(catalogRef),
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
      catalogRefJson: jsonEncode(item.catalogRef.toJson()),
      targetPriceCents: Value(item.targetPriceCents),
      currency: Value(item.currency),
      notes: Value(item.notes),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
    );
  }

  PersonalItemAnchor? _anchorFromCatalogRef(CatalogEntityRef ref) {
    return switch (ref.entityType) {
      CatalogEntityType.edition => PersonalItemAnchor.fromRaw(
          anchorType: PersonalItemAnchorType.edition.apiValue,
          editionId: ref.id,
        ),
      CatalogEntityType.release => PersonalItemAnchor.fromRaw(
          anchorType: PersonalItemAnchorType.variant.apiValue,
          variantId: ref.id,
        ),
      CatalogEntityType.bundleRelease => PersonalItemAnchor.fromRaw(
          anchorType: PersonalItemAnchorType.bundleRelease.apiValue,
          bundleReleaseId: ref.id,
        ),
      _ => null,
    };
  }

  bool _matchesAnchorValue(
      WishlistItem item, PersonalItemAnchor? candidateAnchor) {
    final itemAnchor = item.anchor;
    if (itemAnchor == null || candidateAnchor == null) {
      return itemAnchor == null && candidateAnchor == null;
    }
    return itemAnchor.apiValue == candidateAnchor.apiValue &&
        itemAnchor.editionId == candidateAnchor.editionId &&
        itemAnchor.variantId == candidateAnchor.variantId &&
        itemAnchor.bundleReleaseId == candidateAnchor.bundleReleaseId;
  }
}
