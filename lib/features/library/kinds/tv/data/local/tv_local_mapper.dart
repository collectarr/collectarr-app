import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_models.dart';
import 'package:collectarr_app/features/library/kinds/tv/ownership/tv_owned_details.dart';
import 'package:drift/drift.dart';

final class TvLocalMapper {
  const TvLocalMapper._();

  static TvSeriesRowsCompanion toSeriesRow(TvSeries series) {
    _require(series.id, 'TvSeries');
    return TvSeriesRowsCompanion.insert(
      id: series.id,
      title: series.title,
      sortTitle: Value(series.sortTitle),
      description: Value(series.description),
      endDate: Value(series.endDate),
      episodeCount: Value(series.episodeCount),
      network: Value(series.network),
      originalAirDate: Value(series.originalAirDate),
      originalLanguage: Value(series.originalLanguage),
      seasonCount: Value(series.seasonCount),
      status: Value(series.status),
      contributionsJson: Value(_encode(series.contributions)),
      identifiersJson: Value(_encode(series.identifiers)),
      characterAppearancesJson: Value(_encode(series.characterAppearances)),
      rawPayloadJson: Value(jsonEncode(series.rawPayload)),
    );
  }

  static TvSeries fromSeriesRow(
    TvSeriesRow row, {
    List<TvSeason> seasons = const <TvSeason>[],
    List<TvRelease> releases = const <TvRelease>[],
    List<TvReleaseMedia> media = const <TvReleaseMedia>[],
    List<TvReleaseEpisodeMap> releaseEpisodeMaps =
        const <TvReleaseEpisodeMap>[],
  }) {
    return TvSeries(
      id: row.id,
      title: row.title,
      sortTitle: row.sortTitle,
      description: row.description,
      endDate: row.endDate,
      episodeCount: row.episodeCount,
      network: row.network,
      originalAirDate: row.originalAirDate,
      originalLanguage: row.originalLanguage,
      seasonCount: row.seasonCount,
      status: row.status,
      seasons: seasons,
      releases: releases,
      media: media,
      releaseEpisodeMaps: releaseEpisodeMaps,
      contributions: _decodeMaps(row.contributionsJson)
          .map(TvContributor.fromJson)
          .toList(growable: false),
      identifiers: _decodeMaps(row.identifiersJson)
          .map(TvIdentifier.fromJson)
          .toList(growable: false),
      characterAppearances: _decodeMaps(row.characterAppearancesJson)
          .map(TvCharacterAppearance.fromJson)
          .toList(growable: false),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static TvSeasonRowsCompanion toSeasonRow(
    TvSeriesId seriesId,
    TvSeason season,
  ) {
    _require(seriesId.value, 'TvSeason.seriesId');
    _require(season.id, 'TvSeason');
    return TvSeasonRowsCompanion.insert(
      seriesId: seriesId.value,
      id: season.id,
      seasonNumber: Value(season.seasonNumber),
      title: Value(season.title),
      description: Value(season.description),
      airDate: Value(season.airDate),
      episodeCount: Value(season.episodeCount),
      coverImageUrl: Value(season.coverImageUrl),
      coverImageKey: Value(season.coverImageKey),
      rawPayloadJson: Value(jsonEncode(season.rawPayload)),
    );
  }

  static TvSeason fromSeasonRow(
    TvSeasonRow row, {
    List<TvEpisode> episodes = const <TvEpisode>[],
  }) {
    return TvSeason(
      id: row.id,
      seriesId: row.seriesId,
      seasonNumber: row.seasonNumber,
      title: row.title,
      description: row.description,
      airDate: row.airDate,
      episodeCount: row.episodeCount,
      coverImageUrl: row.coverImageUrl,
      coverImageKey: row.coverImageKey,
      episodes: episodes,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static TvEpisodeRowsCompanion toEpisodeRow(TvEpisode episode) {
    _require(episode.seriesId, 'TvEpisode.seriesId');
    _require(episode.seasonId, 'TvEpisode.seasonId');
    _require(episode.id, 'TvEpisode');
    return TvEpisodeRowsCompanion.insert(
      seriesId: episode.seriesId,
      seasonId: episode.seasonId,
      id: episode.id,
      seasonNumber: Value(episode.seasonNumber),
      episodeNumber: Value(episode.episodeNumber),
      title: Value(episode.title),
      originalTitle: Value(episode.originalTitle),
      description: Value(episode.description),
      airDate: Value(episode.airDate),
      runtimeMinutes: Value(episode.runtimeMinutes),
      coverImageUrl: Value(episode.coverImageUrl),
      coverImageKey: Value(episode.coverImageKey),
      rawPayloadJson: Value(jsonEncode(episode.rawPayload)),
    );
  }

  static TvEpisode fromEpisodeRow(TvEpisodeRow row) {
    return TvEpisode(
      id: row.id,
      seriesId: row.seriesId,
      seasonId: row.seasonId,
      seasonNumber: row.seasonNumber,
      episodeNumber: row.episodeNumber,
      title: row.title,
      originalTitle: row.originalTitle,
      description: row.description,
      airDate: row.airDate,
      runtimeMinutes: row.runtimeMinutes,
      coverImageUrl: row.coverImageUrl,
      coverImageKey: row.coverImageKey,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static TvReleaseRowsCompanion toReleaseRow(
    TvSeriesId seriesId,
    TvRelease release,
  ) {
    _require(seriesId.value, 'TvRelease.seriesId');
    _require(release.id, 'TvRelease');
    return TvReleaseRowsCompanion.insert(
      seriesId: seriesId.value,
      id: release.id,
      title: release.title,
      sortTitle: Value(release.sortTitle),
      description: Value(release.description),
      mediaCount: Value(release.mediaCount),
      format: Value(release.format),
      regionCode: Value(release.regionCode),
      releaseDate: Value(release.releaseDate),
      publisher: Value(release.publisher),
      sku: Value(release.sku),
      caseType: Value(release.caseType),
      episodeCount: Value(release.episodeCount),
      seasonCount: Value(release.seasonCount),
      runtimeMinutes: Value(release.runtimeMinutes),
      languageAudioJson: Value(jsonEncode(release.languageAudio)),
      languageSubtitlesJson: Value(jsonEncode(release.languageSubtitles)),
      contentRating: Value(release.contentRating),
      coverImageUrl: Value(release.coverImageUrl),
      coverImageKey: Value(release.coverImageKey),
      rawPayloadJson: Value(jsonEncode(release.rawPayload)),
    );
  }

  static TvRelease fromReleaseRow(
    TvReleaseRow row, {
    List<TvReleaseMedia> media = const <TvReleaseMedia>[],
    List<TvReleaseEpisodeMap> episodeMappings = const <TvReleaseEpisodeMap>[],
  }) {
    return TvRelease(
      id: row.id,
      seriesId: row.seriesId,
      title: row.title,
      sortTitle: row.sortTitle,
      description: row.description,
      mediaCount: row.mediaCount,
      format: row.format,
      regionCode: row.regionCode,
      releaseDate: row.releaseDate,
      publisher: row.publisher,
      sku: row.sku,
      caseType: row.caseType,
      episodeCount: row.episodeCount,
      seasonCount: row.seasonCount,
      runtimeMinutes: row.runtimeMinutes,
      languageAudio: _decodeStrings(row.languageAudioJson),
      languageSubtitles: _decodeStrings(row.languageSubtitlesJson),
      contentRating: row.contentRating,
      coverImageUrl: row.coverImageUrl,
      coverImageKey: row.coverImageKey,
      media: media,
      episodeMappings: episodeMappings,
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static TvReleaseMediaRowsCompanion toReleaseMediaRow(
    TvReleaseId releaseId,
    TvReleaseMedia media,
  ) {
    _require(releaseId.value, 'TvReleaseMedia.releaseId');
    _require(media.id, 'TvReleaseMedia');
    return TvReleaseMediaRowsCompanion.insert(
      releaseId: releaseId.value,
      id: media.id,
      mediaNumber: Value(media.mediaNumber),
      mediaType: Value(media.mediaType),
      title: Value(media.title),
      episodeCount: Value(media.episodeCount),
      runtimeMinutes: Value(media.runtimeMinutes),
      regionCode: Value(media.regionCode),
      encoding: Value(media.encoding),
      aspectRatio: Value(media.aspectRatio),
      color: Value(media.color),
      audioTracks: Value(media.audioTracks),
      subtitles: Value(media.subtitles),
      layers: Value(media.layers),
      frameRate: Value(media.frameRate),
      bitDepth: Value(media.bitDepth),
      resolution: Value(media.resolution),
      hdrFormat: Value(media.hdrFormat),
      episodesJson: Value(_encode(media.episodes)),
      rawPayloadJson: Value(jsonEncode(media.rawPayload)),
    );
  }

  static TvReleaseMedia fromReleaseMediaRow(TvReleaseMediaRow row) {
    return TvReleaseMedia(
      id: row.id,
      releaseId: row.releaseId,
      mediaNumber: row.mediaNumber,
      mediaType: row.mediaType,
      title: row.title,
      episodeCount: row.episodeCount,
      runtimeMinutes: row.runtimeMinutes,
      regionCode: row.regionCode,
      encoding: row.encoding,
      aspectRatio: row.aspectRatio,
      color: row.color,
      audioTracks: row.audioTracks,
      subtitles: row.subtitles,
      layers: row.layers,
      frameRate: row.frameRate,
      bitDepth: row.bitDepth,
      resolution: row.resolution,
      hdrFormat: row.hdrFormat,
      episodes: _decodeMaps(row.episodesJson)
          .map(TvEpisode.fromJson)
          .toList(growable: false),
      rawPayload: _decodeMap(row.rawPayloadJson),
    );
  }

  static TvReleaseEpisodeMapRowsCompanion toReleaseEpisodeMapRow(
    TvReleaseId releaseId,
    TvReleaseEpisodeMap mapping,
  ) {
    _require(releaseId.value, 'TvReleaseEpisodeMap.releaseId');
    _require(mapping.id, 'TvReleaseEpisodeMap');
    return TvReleaseEpisodeMapRowsCompanion.insert(
      releaseId: releaseId.value,
      id: mapping.id,
      mediaId: mapping.mediaId,
      episodeId: mapping.episodeId,
      discNumber: Value(mapping.discNumber),
      sequenceNumber: Value(mapping.sequenceNumber),
    );
  }

  static TvReleaseEpisodeMap fromReleaseEpisodeMapRow(
    TvReleaseEpisodeMapRow row,
  ) {
    return TvReleaseEpisodeMap(
      id: row.id,
      releaseId: row.releaseId,
      mediaId: row.mediaId,
      episodeId: row.episodeId,
      discNumber: row.discNumber,
      sequenceNumber: row.sequenceNumber,
    );
  }

  static TvOwnedDetailsRowsCompanion toOwnedDetailsRow(
    String ownedItemId,
    TvOwnedDetails details,
  ) {
    _require(ownedItemId, 'TvOwnedDetails.ownedItemId');
    return TvOwnedDetailsRowsCompanion.insert(
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

  static TvOwnedDetails fromOwnedDetailsRow(TvOwnedDetailsRow row) {
    return TvOwnedDetails(
      features: row.features,
      hdrFormats: _decodeStrings(row.hdrFormatsJson),
      boxSetId: row.boxSetId,
      boxSetName: row.boxSetName,
      region: row.region,
      packaging: row.packaging,
      distributor: row.distributor,
    );
  }

  static String _encode(Iterable<Object> values) => jsonEncode(
        values.map(_toJson).toList(growable: false),
      );

  static Map<String, dynamic> _toJson(Object value) {
    return switch (value) {
      TvContributor item => item.toJson(),
      TvIdentifier item => item.toJson(),
      TvCharacterAppearance item => item.toJson(),
      TvEpisode item => item.toJson(),
      _ => throw StateError('Unsupported TV JSON value: ${value.runtimeType}'),
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
        if (value is Map<Object?, Object?>) Map<String, dynamic>.from(value),
    ];
  }

  static List<String> _decodeStrings(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! List) return const <String>[];
    return decoded.whereType<String>().toList(growable: false);
  }

  static Map<String, dynamic> _decodeMap(String raw) {
    final decoded = _decodeJson(raw);
    if (decoded is! Map<Object?, Object?>) return const <String, dynamic>{};
    return Map<String, dynamic>.from(decoded);
  }

  static void _require(String value, String label) {
    if (value.trim().isEmpty) {
      throw StateError('Cannot persist $label without an id');
    }
  }
}
