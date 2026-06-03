import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
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
    return rows.map(_fromCache).toList(growable: false);
  }

  Future<OwnedItem?> findById(String id) async {
    final row = await (_db.select(_db.ownedItemsCache)
          ..where((row) => row.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _fromCache(row);
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
      items.addAll(rows.map(_fromCache));
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

  OwnedItem _fromCache(OwnedItemsCacheData row) {
    return OwnedItem(
      id: row.id,
      itemId: row.itemId,
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
      coverPriceCents: row.coverPriceCents,
      rawOrSlabbed: row.rawOrSlabbed,
      gradingCompany: row.gradingCompany,
      graderNotes: row.graderNotes,
      signedBy: row.signedBy,
      labelType: row.labelType,
      customLabel: row.customLabel,
      pageQuality: row.pageQuality,
      certificationNumber: row.certificationNumber,
      keyComic: row.keyComic,
      keyReason: row.keyReason,
      keyCategory: row.keyCategory,
      keySeverity: row.keySeverity,
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
      features: row.features,
      hdrFormats: _decodeStringList(row.hdrFormatsJson) ?? const <String>[],
      purchaseStore: row.purchaseStore,
      boxSetId: row.boxSetId,
      boxSetName: row.boxSetName,
      storageDevice: row.storageDevice,
      storageSlot: row.storageSlot,
      region: row.region,
      packaging: row.packaging,
      distributor: row.distributor,
      collectionStatus: row.collectionStatus,
      lastBagBoardDate: row.lastBagBoardDate,
      marketValueCents: row.marketValueCents,
      gameCompleteness: row.gameCompleteness,
      gameHasBox: row.gameHasBox,
      gameHasManual: row.gameHasManual,
      gamePriceChartingId: row.gamePriceChartingId,
      gameCoreRegion: row.gameCoreRegion,
      gameValueIsLocked: row.gameValueIsLocked,
    );
  }

  OwnedItemsCacheCompanion _toCompanion(OwnedItem item) {
    return OwnedItemsCacheCompanion.insert(
      id: item.id,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      anchorType: Value(item.anchorType),
      editionId: Value(item.editionId),
      variantId: Value(item.variantId),
      bundleReleaseId: Value(item.bundleReleaseId),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
      quantity: Value(item.quantity),
      indexNumber: Value(item.indexNumber),
      coverPriceCents: Value(item.coverPriceCents),
      rawOrSlabbed: Value(item.rawOrSlabbed),
      gradingCompany: Value(item.gradingCompany),
      graderNotes: Value(item.graderNotes),
      signedBy: Value(item.signedBy),
      labelType: Value(item.labelType),
      customLabel: Value(item.customLabel),
      pageQuality: Value(item.pageQuality),
      certificationNumber: Value(item.certificationNumber),
      keyComic: Value(item.keyComic),
      keyReason: Value(item.keyReason),
      keyCategory: Value(item.keyCategory),
      keySeverity: Value(item.keySeverity),
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
      features: Value(item.features),
      hdrFormatsJson: Value(
        item.hdrFormats.isNotEmpty ? jsonEncode(item.hdrFormats) : null,
      ),
      purchaseStore: Value(item.purchaseStore),
      boxSetId: Value(item.boxSetId),
      boxSetName: Value(item.boxSetName),
      storageDevice: Value(item.storageDevice),
      storageSlot: Value(item.storageSlot),
      region: Value(item.region),
      packaging: Value(item.packaging),
      distributor: Value(item.distributor),
      collectionStatus: Value(item.collectionStatus),
      lastBagBoardDate: Value(item.lastBagBoardDate),
      marketValueCents: Value(item.marketValueCents),
      gameCompleteness: Value(item.gameCompleteness),
      gameHasBox: Value(item.gameHasBox),
      gameHasManual: Value(item.gameHasManual),
      gamePriceChartingId: Value(item.gamePriceChartingId),
      gameCoreRegion: Value(item.gameCoreRegion),
      gameValueIsLocked: Value(item.gameValueIsLocked),
    );
  }

  static List<String>? _decodeStringList(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      return null;
    }
    return decoded.cast<String>().toList(growable: false);
  }
}
