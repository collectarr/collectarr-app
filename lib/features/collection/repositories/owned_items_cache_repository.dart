import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:drift/drift.dart';

class OwnedItemsCacheRepository {
  const OwnedItemsCacheRepository(this._db);

  static const _lookupBatchSize = 500;

  final LocalDatabase _db;

  Future<List<OwnedItem>> listActive() async {
    final rows = await (_db.select(_db.ownedItemsCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    if (rows.isEmpty) return const [];
    return rows
        .map((r) => _fromCache(r, catalogKind: r.kind))
        .toList(growable: false);
  }

  /// Returns the deliberately small cross-kind projection used by global
  /// hosts such as Loans. Semantic copy fields stay in the owning kind and
  /// are not reconstructed for this read path.
  Future<List<OwnedItemSummary>> listActiveSummaries() async {
    final rows = await (_db.select(_db.ownedItemsCache)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]))
        .get();
    return rows.map(_summaryFromCache).toList(growable: false);
  }

  Future<OwnedItem?> findById(String id) async {
    final row = await (_db.select(_db.ownedItemsCache)
          ..where((row) => row.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _fromCache(row, catalogKind: row.kind);
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

  Future<List<OwnedItem>> findActiveByItemIds(Iterable<String> itemIds) async {
    final values = itemIds.toSet().toList(growable: false);
    if (values.isEmpty) {
      return const [];
    }
    final items = <OwnedItem>[];
    for (var index = 0; index < values.length; index += _lookupBatchSize) {
      final end = (index + _lookupBatchSize).clamp(0, values.length);
      final batch = values.sublist(index, end);
      final rows = await (_db.select(_db.ownedItemsCache)
            ..where(
              (row) => row.itemId.isIn(batch) & row.deletedAt.isNull(),
            ))
          .get();
      items.addAll(
        rows.map((r) => _fromCache(r, catalogKind: r.kind)),
      );
    }
    return items;
  }

  Future<void> markDeleted(OwnedItem item, DateTime deletedAt) {
    return _db.into(_db.ownedItemsCache).insert(
          _toCompanion(
              item.copyWith(updatedAt: deletedAt, deletedAt: deletedAt)),
          mode: InsertMode.insertOrReplace,
        );
  }

  OwnedItem _fromCache(OwnedItemsCacheData row, {String? catalogKind}) {
    final catalogRef = _catalogRefFromRow(row, catalogKind: catalogKind);
    final decodedDetails = _decodeDetails(row.detailsJson);
    final kind = catalogMediaKindFromApiValue(catalogRef.kind);
    final details = _parseDetails(kind, decodedDetails);

    return OwnedItem(
      id: row.id,
      catalogRef: catalogRef,
      details: details,
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      anchorType: row.anchorType,
      editionId: row.editionId,
      variantId: row.variantId,
      bundleReleaseId: row.bundleReleaseId,
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      indexNumber: row.indexNumber,
      rating: row.rating,
      readStatus: row.readStatus,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      tags: row.tags,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      soldAt: row.soldAt,
      sellPriceCents: row.sellPriceCents,
      soldTo: row.soldTo,
      ownerUserId: row.ownerUserId,
      ownerLabel: row.ownerLabel,
      locationId: row.locationId,
      purchaseStore: row.purchaseStore,
      collectionStatus: row.collectionStatus,
      marketValueCents: row.marketValueCents,
    );
  }

  OwnedItemSummary _summaryFromCache(OwnedItemsCacheData row) {
    final catalogRef = _catalogRefFromRow(row, catalogKind: row.kind);
    final kind = catalogMediaKindFromApiValue(catalogRef.kind);
    return OwnedItemSummary(
      ref: OwnedItemRef(kind: kind, id: OwnedItemId(row.id)),
      catalogRef: catalogRef,
      title: row.itemId,
      ownerLabel: row.ownerLabel,
      locationLabel: row.locationId,
    );
  }

  OwnedItemsCacheCompanion _toCompanion(OwnedItem item) {
    return OwnedItemsCacheCompanion.insert(
      id: item.id,
      itemId: item.itemId,
      kind: Value(item.catalogRef.kind),
      detailsJson: Value(jsonEncode(item.details.toJson())),
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      anchorType: Value(item.anchor?.apiValue),
      editionId: Value(item.anchor?.editionId),
      variantId: Value(item.anchor?.variantId),
      bundleReleaseId: Value(item.anchor?.bundleReleaseId),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      quantity: Value(item.quantity),
      indexNumber: Value(item.indexNumber),
      rating: Value(item.rating),
      readStatus: Value(item.readStatus),
      startedAt: Value(item.startedAt),
      finishedAt: Value(item.finishedAt),
      tags: Value(item.tags),
      updatedAt: item.updatedAt,
      deletedAt: Value(item.deletedAt),
      soldAt: Value(item.soldAt),
      sellPriceCents: Value(item.sellPriceCents),
      soldTo: Value(item.soldTo),
      ownerUserId: Value(item.ownerUserId),
      ownerLabel: Value(item.ownerLabel),
      locationId: Value(item.locationId),
      purchaseStore: Value(item.purchaseStore),
      collectionStatus: Value(item.collectionStatus),
      marketValueCents: Value(item.marketValueCents),
    );
  }

  CatalogEntityRef _catalogRefFromRow(OwnedItemsCacheData row,
      {String? catalogKind}) {
    if (catalogKind != null &&
        catalogKind.isNotEmpty &&
        catalogKind != 'unknown') {
      return CatalogEntityRef(
        kind: catalogKind,
        entityType: CatalogEntityType.work,
        id: row.itemId,
      );
    }
    return CatalogEntityRef(
      kind: row.kind,
      entityType: CatalogEntityType.unknown,
      id: row.itemId,
    );
  }

  static Map<String, dynamic> _decodeDetails(String? json) {
    if (json == null || json.isEmpty) {
      return const {};
    }
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } on Object {
      return const {};
    }
    return const {};
  }

  static OwnedItemDetails _parseDetails(
    CatalogMediaKind kind,
    Map<String, dynamic> json,
  ) {
    try {
      return libraryKindRuntimeForKind(kind).decodeOwnedDetails(json);
    } on Object {
      return libraryKindRuntimeForKind(kind).defaultOwnedDetails();
    }
  }
}
