import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:drift/drift.dart';

final class GameLocalMapper {
  const GameLocalMapper._();

  static GameMediaRowsCompanion toMediaRow(GameMedia media) {
    if (media.id.value.isEmpty) {
      throw StateError('Cannot persist GameMedia without an id');
    }

    return GameMediaRowsCompanion.insert(
      id: media.id.value,
      title: media.title,
      sortTitle: Value(media.sortTitle),
      description: Value(media.description),
      releaseDate: Value(media.releaseDate),
      originalLanguage: Value(media.originalLanguage),
      publisher: Value(media.publisher),
      subtitle: Value(media.subtitle),
      platformsJson: Value(_encodeList(media.platforms)),
      identifiersJson: Value(_encodeList(media.identifiers)),
      companyRolesJson: Value(_encodeList(media.companyRoles)),
      ageRatingsJson: Value(_encodeList(media.ageRatings)),
      genresJson: Value(_encodeList(media.genres)),
      searchAliasesJson: Value(_encodeList(media.searchAliases)),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static GameMedia fromMediaRow(
    GameMediaRow row, {
    List<GameRelease> releases = const <GameRelease>[],
  }) {
    return GameMedia(
      id: GameMediaId(row.id),
      title: row.title,
      sortTitle: row.sortTitle,
      description: row.description,
      releaseDate: row.releaseDate,
      originalLanguage: row.originalLanguage,
      publisher: row.publisher,
      subtitle: row.subtitle,
      platforms: _decodeStringList(row.platformsJson),
      identifiers: _decodeStringList(row.identifiersJson),
      companyRoles: _decodeStringList(row.companyRolesJson),
      ageRatings: _decodeStringList(row.ageRatingsJson),
      genres: _decodeStringList(row.genresJson),
      searchAliases: _decodeStringList(row.searchAliasesJson),
      releases: releases,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static GameReleaseRowsCompanion toReleaseRow(
    GameMediaId mediaId,
    GameRelease release,
  ) {
    if (mediaId.value.isEmpty || release.id.isEmpty) {
      throw StateError('Cannot persist GameRelease without an id');
    }

    return GameReleaseRowsCompanion.insert(
      mediaId: mediaId.value,
      id: release.id,
      title: release.title,
      workId: Value(release.workId),
      platform: Value(release.platform),
      releaseDate: Value(release.releaseDate),
      regionCode: Value(release.regionCode),
      format: Value(release.format),
      publisher: Value(release.publisher),
      catalogNumber: Value(release.catalogNumber),
      releaseStatus: Value(release.releaseStatus),
      language: Value(release.language),
      barcode: Value(release.barcode),
      coverImageUrl: Value(release.coverImageUrl),
      rawPayloadJson: Value(jsonEncode(release.rawPayload)),
    );
  }

  static GameRelease fromReleaseRow(GameReleaseRow row) {
    return GameRelease(
      id: row.id,
      title: row.title,
      workId: row.workId,
      platform: row.platform,
      releaseDate: row.releaseDate,
      regionCode: row.regionCode,
      format: row.format,
      publisher: row.publisher,
      catalogNumber: row.catalogNumber,
      releaseStatus: row.releaseStatus,
      language: row.language,
      barcode: row.barcode,
      coverImageUrl: row.coverImageUrl,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static GameOwnedItemsRowsCompanion toOwnedItemRow(GameOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.game) {
      throw StateError('Cannot persist an invalid GameOwnedItem');
    }

    final details = item.details;
    return GameOwnedItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
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
      completeness: Value(details.completeness),
      hasBox: Value(details.hasBox),
      hasManual: Value(details.hasManual),
      priceChartingId: Value(details.priceChartingId),
      coreRegion: Value(details.coreRegion),
      valueIsLocked: Value(details.valueIsLocked),
    );
  }

  static GameOwnedItem fromOwnedItemRow(GameOwnedItemsRow row) {
    return GameOwnedItem(
      id: GameOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'game',
        entityType: CatalogEntityType.work,
        id: row.itemId,
      ),
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      anchor: PersonalItemAnchor.fromRaw(
        anchorType: row.anchorType,
        editionId: row.editionId,
        variantId: row.variantId,
        bundleReleaseId: row.bundleReleaseId,
      ),
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
      quantity: row.quantity,
      indexNumber: row.indexNumber,
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
      details: GameOwnedDetails(
        completeness: row.completeness,
        hasBox: row.hasBox,
        hasManual: row.hasManual,
        priceChartingId: row.priceChartingId,
        coreRegion: row.coreRegion,
        valueIsLocked: row.valueIsLocked,
      ),
    );
  }

  static String _encodeList(Iterable<dynamic> values) =>
      jsonEncode(values.toList(growable: false));

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<String> _decodeStringList(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map<Object?, Object?>) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }
}
