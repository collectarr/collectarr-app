import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
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

  static MusicOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    MusicOwnedDetails details,
  ) {
    _require(ownedItemId, 'MusicOwnedDetails.ownedItemId');
    return MusicOwnedDetailsRowsCompanion.insert(
      ownedItemId: ownedItemId,
      storageDevice: Value(details.storageDevice),
      storageSlot: Value(details.storageSlot),
      signedBy: Value(details.signedBy),
      lastCleanedDate: Value(details.lastCleanedDate),
      matrixRunoutsJson: Value(
        jsonEncode(details.matrixRunouts.map((item) => item.toJson()).toList()),
      ),
    );
  }

  static MusicOwnedDetails fromOwnedDetailsRow(MusicOwnedDetailsRow row) {
    return MusicOwnedDetails(
      storageDevice: row.storageDevice,
      storageSlot: row.storageSlot,
      signedBy: row.signedBy,
      lastCleanedDate: row.lastCleanedDate,
      matrixRunouts: [
        for (final value in _decodeMaps(row.matrixRunoutsJson))
          MusicMatrixRunout.fromJson(value),
      ],
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
