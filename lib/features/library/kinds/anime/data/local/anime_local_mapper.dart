import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_episode.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_ids.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_media.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_release.dart';
import 'package:collectarr_app/features/library/kinds/anime/domain/anime_tracking.dart';
import 'package:collectarr_app/features/library/kinds/anime/ownership/anime_owned_details.dart';
import 'package:drift/drift.dart';

final class AnimeLocalMapper {
  const AnimeLocalMapper._();

  static AnimeMediaRowsCompanion toMediaRow(AnimeMedia media) {
    _require(media.id.value, 'AnimeMedia');
    return AnimeMediaRowsCompanion.insert(
      id: media.id.value,
      title: media.title,
      animeType: Value(media.animeType),
      sortTitle: Value(media.sortTitle),
      description: Value(media.description),
      endDate: Value(media.endDate),
      episodeCount: Value(media.episodeCount),
      originalAirDate: Value(media.originalAirDate),
      originalLanguage: Value(media.originalLanguage),
      status: Value(media.status),
      contributionsJson: Value(_encode(media.contributions)),
      identifiersJson: Value(_encode(media.identifiers)),
      characterAppearancesJson: Value(_encode(media.characterAppearances)),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static AnimeMedia fromMediaRow(
    AnimeMediaRow row, {
    List<AnimeEpisode> episodes = const <AnimeEpisode>[],
    List<AnimeRelease> releases = const <AnimeRelease>[],
  }) {
    return AnimeMedia(
      id: AnimeMediaId(row.id),
      title: row.title,
      animeType: row.animeType,
      sortTitle: row.sortTitle,
      description: row.description,
      endDate: row.endDate,
      episodeCount: row.episodeCount,
      originalAirDate: row.originalAirDate,
      originalLanguage: row.originalLanguage,
      status: row.status,
      episodes: episodes,
      releases: releases,
      contributions: _decodeMaps(row.contributionsJson)
          .map(AnimeContributor.fromJson)
          .toList(growable: false),
      identifiers: _decodeMaps(row.identifiersJson)
          .map(AnimeIdentifier.fromJson)
          .toList(growable: false),
      characterAppearances: _decodeMaps(row.characterAppearancesJson)
          .map(AnimeCharacterAppearance.fromJson)
          .toList(growable: false),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static AnimeEpisodeRowsCompanion toEpisodeRow(AnimeEpisode episode) {
    _require(episode.id.value, 'AnimeEpisode');
    _require(episode.seriesId.value, 'AnimeEpisode.seriesId');
    return AnimeEpisodeRowsCompanion.insert(
      seriesId: episode.seriesId.value,
      id: episode.id.value,
      episodeNumber: Value(episode.episodeNumber),
      title: Value(episode.title),
      description: Value(episode.description),
      airDate: Value(episode.airDate),
      runtimeMinutes: Value(episode.runtimeMinutes),
      coverImageUrl: Value(episode.coverImageUrl),
      coverImageKey: Value(episode.coverImageKey),
      rawPayloadJson: Value(jsonEncode(episode.rawPayload)),
    );
  }

  static AnimeEpisode fromEpisodeRow(AnimeEpisodeRow row) {
    return AnimeEpisode(
      id: AnimeEpisodeId(row.id),
      seriesId: AnimeMediaId(row.seriesId),
      episodeNumber: row.episodeNumber,
      title: row.title,
      description: row.description,
      airDate: row.airDate,
      runtimeMinutes: row.runtimeMinutes,
      coverImageUrl: row.coverImageUrl,
      coverImageKey: row.coverImageKey,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static AnimeReleaseRowsCompanion toReleaseRow(
    AnimeMediaId seriesId,
    AnimeRelease release,
  ) {
    _require(seriesId.value, 'AnimeRelease.seriesId');
    _require(release.id.value, 'AnimeRelease');
    return AnimeReleaseRowsCompanion.insert(
      seriesId: seriesId.value,
      id: release.id.value,
      title: release.title,
      coverImageKey: Value(release.coverImageKey),
      coverImageUrl: Value(release.coverImageUrl),
      description: Value(release.description),
      format: Value(release.format),
      language: Value(release.language),
      regionCode: Value(release.regionCode),
      releaseDate: Value(release.releaseDate),
      publisher: Value(release.publisher),
      barcode: Value(release.barcode),
      mediaCount: Value(release.mediaCount),
      audioTracksJson: Value(jsonEncode(release.audioTracks)),
      subtitlesJson: Value(jsonEncode(release.subtitles)),
      rawPayloadJson: Value(jsonEncode(release.rawPayload)),
    );
  }

  static AnimeRelease fromReleaseRow(AnimeReleaseRow row) {
    return AnimeRelease(
      id: AnimeReleaseId(row.id),
      title: row.title,
      seriesId: AnimeMediaId(row.seriesId),
      coverImageKey: row.coverImageKey,
      coverImageUrl: row.coverImageUrl,
      description: row.description,
      format: row.format,
      language: row.language,
      regionCode: row.regionCode,
      releaseDate: row.releaseDate,
      publisher: row.publisher,
      barcode: row.barcode,
      mediaCount: row.mediaCount,
      audioTracks: _decodeStrings(row.audioTracksJson),
      subtitles: _decodeStrings(row.subtitlesJson),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static AnimeOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    AnimeOwnedDetails details,
  ) {
    _require(ownedItemId, 'AnimeOwnedDetails.ownedItemId');
    return AnimeOwnedDetailsRowsCompanion.insert(
      ownedItemId: ownedItemId,
      features: Value(details.features),
      hdrFormatsJson: Value(jsonEncode(details.hdrFormats)),
      boxSetId: Value(details.boxSetId),
      boxSetName: Value(details.boxSetName),
      region: Value(details.region),
      packaging: Value(details.packaging),
      distributor: Value(details.distributor),
    );
  }

  static AnimeOwnedDetails fromOwnedDetailsRow(AnimeOwnedDetailsRow row) {
    return AnimeOwnedDetails(
      features: row.features,
      hdrFormats: _decodeStrings(row.hdrFormatsJson),
      boxSetId: row.boxSetId,
      boxSetName: row.boxSetName,
      region: row.region,
      packaging: row.packaging,
      distributor: row.distributor,
    );
  }

  static AnimeOwnedItemsRowsCompanion toOwnedItemRow(AnimeOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.anime) {
      throw StateError('Cannot persist an invalid AnimeOwnedItem');
    }

    final details = item.details;
    return AnimeOwnedItemsRowsCompanion.insert(
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
      features: Value(details.features),
      hdrFormatsJson: Value(jsonEncode(details.hdrFormats)),
      boxSetId: Value(details.boxSetId),
      boxSetName: Value(details.boxSetName),
      region: Value(details.region),
      packaging: Value(details.packaging),
      distributor: Value(details.distributor),
    );
  }

  static AnimeOwnedItem fromOwnedItemRow(AnimeOwnedItemsRow row) {
    return AnimeOwnedItem(
      id: AnimeOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'anime',
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

  static String _encode(Iterable<Object> values) => jsonEncode(
        values.map(_toJson).toList(growable: false),
      );

  static Map<String, dynamic> _toJson(Object value) {
    return switch (value) {
      AnimeContributor item => item.toJson(),
      AnimeIdentifier item => item.toJson(),
      AnimeCharacterAppearance item => item.toJson(),
      _ =>
        throw StateError('Unsupported Anime JSON value: ${value.runtimeType}'),
    };
  }

  static dynamic _decodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  static List<Map<String, dynamic>> _decodeMaps(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return [
      for (final value in decoded)
        if (value is Map) Map<String, dynamic>.from(value),
    ];
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

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  static void _require(String value, String label) {
    if (value.trim().isEmpty) {
      throw StateError('Cannot persist $label without an id');
    }
  }
}
