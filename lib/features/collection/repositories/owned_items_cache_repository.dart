import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
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
    if (rows.isEmpty) return const [];
    final itemIds = rows.map((r) => r.itemId).toSet();
    final catalogRows = await (_db.select(_db.catalogCache)
          ..where((c) => c.id.isIn(itemIds)))
        .get();
    final kindByItemId = {for (final c in catalogRows) c.id: c.kind};
    return rows
        .map((r) => _fromCache(r, catalogKind: kindByItemId[r.itemId]))
        .toList(growable: false);
  }

  Future<OwnedItem?> findById(String id) async {
    final row = await (_db.select(_db.ownedItemsCache)
          ..where((row) => row.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    final catalogRow = await (_db.select(_db.catalogCache)
          ..where((c) => c.id.equals(row.itemId))
          ..limit(1))
        .getSingleOrNull();
    return _fromCache(row, catalogKind: catalogRow?.kind);
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
      final batchItemIds = rows.map((r) => r.itemId).toSet();
      final catalogRows = await (_db.select(_db.catalogCache)
            ..where((c) => c.id.isIn(batchItemIds)))
          .get();
      final kindByItemId = {for (final c in catalogRows) c.id: c.kind};
      items.addAll(
        rows.map((r) => _fromCache(r, catalogKind: kindByItemId[r.itemId])),
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
    OwnedItemDetails details;
    switch (catalogRef.kind) {
      case 'comic':
        details = ComicOwnedDetails(
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
          coverPriceCents: row.coverPriceCents,
          lastBagBoardDate: row.lastBagBoardDate,
        );
      case 'manga':
        details = MangaOwnedDetails(
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
          coverPriceCents: row.coverPriceCents,
          lastBagBoardDate: row.lastBagBoardDate,
        );
      case 'movie':
        details = MovieOwnedDetails(
          features: row.features,
          hdrFormats: _decodeStringList(row.hdrFormatsJson) ?? const <String>[],
          boxSetId: row.boxSetId,
          boxSetName: row.boxSetName,
          region: row.region,
          packaging: row.packaging,
          distributor: row.distributor,
        );
      case 'tv':
        details = TvOwnedDetails(
          features: row.features,
          hdrFormats: _decodeStringList(row.hdrFormatsJson) ?? const <String>[],
          boxSetId: row.boxSetId,
          boxSetName: row.boxSetName,
          region: row.region,
          packaging: row.packaging,
          distributor: row.distributor,
        );
      case 'anime':
        details = AnimeOwnedDetails(
          features: row.features,
          hdrFormats: _decodeStringList(row.hdrFormatsJson) ?? const <String>[],
          boxSetId: row.boxSetId,
          boxSetName: row.boxSetName,
          region: row.region,
          packaging: row.packaging,
          distributor: row.distributor,
        );
      case 'game':
        details = GameOwnedDetails(
          completeness: row.gameCompleteness,
          hasBox: row.gameHasBox,
          hasManual: row.gameHasManual,
          priceChartingId: row.gamePriceChartingId,
          coreRegion: row.gameCoreRegion,
          valueIsLocked: row.gameValueIsLocked,
        );
      case 'music':
        details = MusicOwnedDetails(
          storageDevice: row.storageDevice,
          storageSlot: row.storageSlot,
        );
      case 'book':
        details = const BookOwnedDetails();
      case 'boardgame':
        details = const BoardgameOwnedDetails();
      default:
        details = OwnedItemDetails.defaultForKind(
          catalogMediaKindFromApiValue(catalogRef.kind),
        );
    }

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

  OwnedItemsCacheCompanion _toCompanion(OwnedItem item) {
    final details = item.details;
    final comic = details is ComicOwnedDetails ? details : null;
    final video = details is VideoOwnedDetails ? details : null;
    final game = details is GameOwnedDetails ? details : null;
    final music = details is MusicOwnedDetails ? details : null;

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
      coverPriceCents: Value(comic?.coverPriceCents),
      rawOrSlabbed: Value(comic?.rawOrSlabbed),
      gradingCompany: Value(comic?.gradingCompany),
      graderNotes: Value(comic?.graderNotes),
      signedBy: Value(comic?.signedBy),
      labelType: Value(comic?.labelType),
      customLabel: Value(comic?.customLabel),
      pageQuality: Value(comic?.pageQuality),
      certificationNumber: Value(comic?.certificationNumber),
      keyComic: Value(comic?.keyComic ?? false),
      keyReason: Value(comic?.keyReason),
      keyCategory: Value(comic?.keyCategory),
      keySeverity: Value(comic?.keySeverity),
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
      features: Value(video?.features),
      hdrFormatsJson: Value(
        video != null && video.hdrFormats.isNotEmpty
            ? jsonEncode(video.hdrFormats)
            : null,
      ),
      purchaseStore: Value(item.purchaseStore),
      boxSetId: Value(video?.boxSetId),
      boxSetName: Value(video?.boxSetName),
      storageDevice: Value(music?.storageDevice),
      storageSlot: Value(music?.storageSlot),
      region: Value(video?.region),
      packaging: Value(video?.packaging),
      distributor: Value(video?.distributor),
      collectionStatus: Value(item.collectionStatus),
      lastBagBoardDate: Value(comic?.lastBagBoardDate),
      marketValueCents: Value(item.marketValueCents),
      gameCompleteness: Value(game?.completeness),
      gameHasBox: Value(game?.hasBox),
      gameHasManual: Value(game?.hasManual),
      gamePriceChartingId: Value(game?.priceChartingId),
      gameCoreRegion: Value(game?.coreRegion),
      gameValueIsLocked: Value(game?.valueIsLocked),
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
    String kind = 'unknown';
    if (row.gradingCompany != null ||
        row.rawOrSlabbed != null ||
        row.keyComic ||
        row.signedBy != null ||
        row.graderNotes != null ||
        row.labelType != null ||
        row.customLabel != null ||
        row.certificationNumber != null) {
      kind = 'comic';
    } else if (row.features != null ||
        row.hdrFormatsJson != null ||
        row.boxSetId != null ||
        row.region != null ||
        row.packaging != null ||
        row.distributor != null) {
      kind = 'movie';
    } else if (row.gameCompleteness != null ||
        row.gameHasBox != null ||
        row.gameHasManual != null ||
        row.gamePriceChartingId != null ||
        row.gameCoreRegion != null) {
      kind = 'game';
    } else if (row.storageDevice != null || row.storageSlot != null) {
      kind = 'music';
    }
    return CatalogEntityRef(
      kind: kind,
      entityType: CatalogEntityType.unknown,
      id: row.itemId,
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
