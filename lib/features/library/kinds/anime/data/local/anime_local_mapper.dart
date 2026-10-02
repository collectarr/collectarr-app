import 'dart:convert';

import 'package:collectarr_app/core/models/collection_item_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:drift/drift.dart';

final class AnimeLocalMapper {
  const AnimeLocalMapper._();

  static AnimeCollectionItemsRowsCompanion toCollectionItemRow(AnimeCollectionItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.anime) {
      throw StateError('Cannot persist an invalid AnimeCollectionItem');
    }

    final details = item.details;
    return AnimeCollectionItemsRowsCompanion.insert(
      id: item.id.value,
      itemId: item.itemId,
      createdAt: Value(item.createdAt),
      isDigital: Value(item.isDigital),
      condition: Value(item.condition),
      grade: Value(item.grade),
      purchaseDate: Value(item.purchaseDate),
      pricePaidCents: Value(item.pricePaidCents),
      currency: Value(item.currency),
      personalNotes: Value(item.personalNotes),
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
      features: Value(details.features),
      hdrFormatsJson: Value(jsonEncode(details.hdrFormats)),
      boxSetId: Value(details.boxSetId),
      boxSetName: Value(details.boxSetName),
      region: Value(details.region),
      packaging: Value(details.packaging),
      distributor: Value(details.distributor),
    );
  }

  static AnimeCollectionItem fromCollectionItemRow(AnimeCollectionItemsRow row) {
    final catalogRef = CatalogEntityRef(
      kind: CatalogMediaKind.anime,
      entityType: CatalogEntityTypeId.catalogItem,
      id: row.itemId,
    );
    return AnimeCollectionItem(
      id: CollectionItemId(row.id),
      catalogRef: catalogRef,
      createdAt: row.createdAt,
      isDigital: row.isDigital,
      condition: row.condition,
      grade: row.grade,
      purchaseDate: row.purchaseDate,
      pricePaidCents: row.pricePaidCents,
      currency: row.currency,
      personalNotes: row.personalNotes,
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
      details: AnimeOwnedDetails(
        features: row.features,
        hdrFormats: _decodeStrings(row.hdrFormatsJson),
        boxSetId: row.boxSetId,
        boxSetName: row.boxSetName,
        region: row.region,
        packaging: row.packaging,
        distributor: row.distributor,
      ),
    );
  }

  static AnimeTrackingRowsCompanion toTrackingRow(AnimeTracking tracking) {
    final id = tracking.id ?? '${tracking.mediaId.value}:tracking';
    _require(id, 'AnimeTracking');
    return AnimeTrackingRowsCompanion.insert(
      id: id,
      catalogRefJson: jsonEncode(
        CatalogEntityRef(
          kind: CatalogMediaKind.anime,
          entityType: const CatalogEntityTypeId('media'),
          id: tracking.mediaId.value,
        ).toJson(),
      ),
      mediaId: tracking.mediaId.value,
      episodeId: Value(tracking.episodeId?.value),
      status: Value(tracking.status),
      sourceType: Value(tracking.sourceType?.apiValue),
      rating: Value(tracking.rating),
      notes: Value(tracking.notes),
      startedAt: Value(tracking.startedAt),
      finishedAt: Value(tracking.finishedAt),
      progressCurrent: Value(tracking.progressCurrent),
      progressTotal: Value(tracking.progressTotal),
      timesCompleted: Value(tracking.timesCompleted),
      seasonNumber: Value(tracking.seasonNumber),
      episodeNumber: Value(tracking.episodeNumber),
      episodeRatingsJson: Value(jsonEncode(tracking.episodeRatings)),
      updatedAt: Value(tracking.updatedAt),
      deletedAt: Value(tracking.deletedAt),
    );
  }

  static AnimeTracking fromTrackingRow(AnimeTrackingRow row) {
    return AnimeTracking(
      id: row.id,
      mediaId: AnimeMediaId(row.mediaId),
      episodeId: row.episodeId == null ? null : AnimeEpisodeId(row.episodeId!),
      status: row.status,
      sourceType: trackingSourceTypeFromValue(row.sourceType),
      rating: row.rating,
      notes: row.notes,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      progressCurrent: row.progressCurrent,
      progressTotal: row.progressTotal,
      timesCompleted: row.timesCompleted,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      episodeRatings: _decodeIntMap(row.episodeRatingsJson),
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<String> _decodeStrings(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  static Map<String, int> _decodeIntMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map) return const <String, int>{};
    return {
      for (final entry in decoded.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toInt(),
    };
  }

  static void _require(String value, String label) {
    if (value.trim().isEmpty) {
      throw StateError('Cannot persist $label without an id');
    }
  }
}
