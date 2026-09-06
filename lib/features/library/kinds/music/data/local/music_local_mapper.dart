import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_owned_item.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/drift.dart';

final class MusicLocalMapper {
  const MusicLocalMapper._();

  static MusicReleaseRowsCompanion toReleaseRow(MusicRelease release) {
    _require(release.id.value, 'MusicRelease');
    return MusicReleaseRowsCompanion.insert(
      id: release.id.value,
      title: release.title,
      artist: Value(release.artist),
      publisher: Value(release.publisher),
      catalogNumber: Value(release.catalogNumber),
      barcode: Value(release.barcode),
      releaseDate: Value(release.releaseDate),
      recordingDate: Value(release.recordingDate),
      releaseStatus: Value(release.releaseStatus),
      releaseType: Value(release.releaseType),
      sortTitle: Value(release.sortTitle),
      subtitle: Value(release.subtitle),
      studio: Value(release.studio),
      countryCode: Value(release.countryCode),
      language: Value(release.language),
      coverImageUrl: Value(release.coverImageUrl),
      genresJson: Value(jsonEncode(release.genres)),
      contributionsJson: Value(jsonEncode(release.contributions)),
      isLive: Value(release.isLive),
      rawPayloadJson: Value(jsonEncode(release.rawPayload)),
    );
  }

  static MusicRelease fromReleaseRow(
    MusicReleaseRow row, {
    List<MusicMedia> media = const <MusicMedia>[],
  }) {
    final tracks = media.expand((item) => item.tracks).toList(growable: false);
    return MusicRelease(
      id: MusicReleaseId(row.id),
      title: row.title,
      artist: row.artist,
      publisher: row.publisher,
      catalogNumber: row.catalogNumber,
      barcode: row.barcode,
      releaseDate: row.releaseDate,
      recordingDate: row.recordingDate,
      releaseStatus: row.releaseStatus,
      releaseType: row.releaseType,
      sortTitle: row.sortTitle,
      subtitle: row.subtitle,
      studio: row.studio,
      countryCode: row.countryCode,
      language: row.language,
      coverImageUrl: row.coverImageUrl,
      genres: _decodeStrings(row.genresJson),
      contributions: _decodeMaps(row.contributionsJson),
      media: media,
      tracks: tracks,
      isLive: row.isLive,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static MusicMediaRowsCompanion toMediaRow(MusicMedia media) {
    _require(media.id.value, 'MusicMedia');
    _require(media.releaseId.value, 'MusicMedia.releaseId');
    return MusicMediaRowsCompanion.insert(
      releaseId: media.releaseId.value,
      id: media.id.value,
      mediaNumber: media.mediaNumber,
      mediaCondition: Value(media.mediaCondition),
      mediaType: Value(media.mediaType),
      packaging: Value(media.packaging),
      rpm: Value(media.rpm),
      soundType: Value(media.soundType),
      spars: Value(media.spars),
      title: Value(media.title),
      trackCount: Value(media.trackCount),
      vinylColor: Value(media.vinylColor),
      vinylWeight: Value(media.vinylWeight),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static MusicMedia fromMediaRow(
    MusicMediaRow row, {
    List<MusicTrack> tracks = const <MusicTrack>[],
  }) {
    return MusicMedia(
      id: MusicMediaId(row.id),
      releaseId: MusicReleaseId(row.releaseId),
      mediaNumber: row.mediaNumber,
      mediaCondition: row.mediaCondition,
      mediaType: row.mediaType,
      packaging: row.packaging,
      rpm: row.rpm,
      soundType: row.soundType,
      spars: row.spars,
      title: row.title,
      trackCount: row.trackCount,
      tracks: tracks,
      vinylColor: row.vinylColor,
      vinylWeight: row.vinylWeight,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static MusicTrackRowsCompanion toTrackRow(MusicTrack track) {
    _require(track.id.value, 'MusicTrack');
    _require(track.mediaId.value, 'MusicTrack.mediaId');
    return MusicTrackRowsCompanion.insert(
      mediaId: track.mediaId.value,
      id: track.id.value,
      position: track.position,
      title: track.title,
      composition: Value(track.composition),
      durationMs: Value(track.durationMs),
      instrument: Value(track.instrument),
      artist: Value(track.artist),
      rawPayloadJson: Value(jsonEncode(track.rawPayload)),
    );
  }

  static MusicTrack fromTrackRow(MusicTrackRow row) {
    return MusicTrack(
      id: MusicTrackId(row.id),
      mediaId: MusicMediaId(row.mediaId),
      position: row.position,
      title: row.title,
      composition: row.composition,
      durationMs: row.durationMs,
      instrument: row.instrument,
      artist: row.artist,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static MusicOwnedItemsRowsCompanion toOwnedItemRow(MusicOwnedItem item) {
    if (item.id.value.isEmpty ||
        item.catalogRef.mediaKind != CatalogMediaKind.music) {
      throw StateError('Cannot persist an invalid MusicOwnedItem');
    }

    final details = item.details;
    return MusicOwnedItemsRowsCompanion.insert(
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
      storageDevice: Value(details.storageDevice),
      storageSlot: Value(details.storageSlot),
      signedBy: Value(details.signedBy),
      lastCleanedDate: Value(details.lastCleanedDate),
      matrixRunoutsJson: Value(
        jsonEncode(details.matrixRunouts.map((item) => item.toJson()).toList()),
      ),
    );
  }

  static MusicOwnedItem fromOwnedItemRow(MusicOwnedItemsRow row) {
    return MusicOwnedItem(
      id: MusicOwnedItemId(row.id),
      catalogRef: CatalogEntityRef(
        kind: 'music',
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
      details: MusicOwnedDetails(
        storageDevice: row.storageDevice,
        storageSlot: row.storageSlot,
        signedBy: row.signedBy,
        lastCleanedDate: row.lastCleanedDate,
        matrixRunouts: [
          for (final value in _decodeMaps(row.matrixRunoutsJson))
            MusicMatrixRunout.fromJson(value),
        ],
      ),
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

  static List<Map<String, dynamic>> _decodeMaps(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <Map<String, dynamic>>[];
    return [
      for (final value in decoded)
        if (value is Map) Map<String, dynamic>.from(value),
    ];
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
