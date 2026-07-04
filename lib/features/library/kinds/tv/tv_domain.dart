import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';

final class TvEpisode {
  const TvEpisode({
    required this.id,
    required this.seriesId,
    required this.seasonId,
    required this.seasonNumber,
    required this.episodeNumber,
    this.title,
    this.originalTitle,
    this.overview,
    this.airDate,
    this.runtimeMinutes,
    this.stillUrl,
    this.productionCode,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String seriesId;
  final String seasonId;
  final int seasonNumber;
  final int episodeNumber;
  final String? title;
  final String? originalTitle;
  final String? overview;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? stillUrl;
  final String? productionCode;
  final Map<String, dynamic> metadata;

  factory TvEpisode.fromJson(Map<String, dynamic> json) {
    return TvEpisode(
      id: _stringOrEmpty(json['id']),
      seriesId: _stringOrEmpty(json['series_id'] ?? json['seriesId']),
      seasonId: _stringOrEmpty(json['season_id'] ?? json['seasonId']),
      seasonNumber: _intOrZero(json['season_number'] ?? json['seasonNumber']),
      episodeNumber:
          _intOrZero(json['episode_number'] ?? json['episodeNumber']),
      title: _stringOrNull(json['title']),
      originalTitle: _stringOrNull(json['original_title'] ?? json['originalTitle']),
      overview: _stringOrNull(json['overview']),
      airDate: _dateOrNull(json['air_date'] ?? json['airDate']),
      runtimeMinutes: _intOrNull(json['runtime_minutes'] ?? json['runtimeMinutes']),
      stillUrl: _stringOrNull(json['still_url'] ?? json['stillUrl']),
      productionCode:
          _stringOrNull(json['production_code'] ?? json['productionCode']),
      metadata: _metadataMap(json),
    );
  }

  factory TvEpisode.fromDto(TvEpisodeDto dto) {
    return TvEpisode(
      id: dto.id,
      seriesId: _stringOrEmpty(
        dto.raw['series_id'] ?? dto.raw['seriesId'] ?? dto.raw['series_id'],
      ),
      seasonId: dto.seasonId,
      seasonNumber: _intOrZero(
        dto.raw['season_number'] ?? dto.raw['seasonNumber'],
      ),
      episodeNumber: _intOrZero(dto.episodeNumber),
      title: _stringOrNull(dto.episodeTitle),
      originalTitle:
          _stringOrNull(dto.raw['original_title'] ?? dto.raw['originalTitle']),
      overview: _stringOrNull(dto.description),
      airDate: dto.releaseDate,
      runtimeMinutes: dto.runtimeMinutes,
      stillUrl: _stringOrNull(dto.coverImageUrl),
      productionCode:
          _stringOrNull(dto.raw['production_code'] ?? dto.raw['productionCode']),
      metadata: _metadataMap(dto.raw),
    );
  }
}

final class TvSeason {
  const TvSeason({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    this.title,
    this.originalTitle,
    this.overview,
    this.airDate,
    this.episodeCount,
    this.posterUrl,
    this.episodes = const <TvEpisode>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String seriesId;
  final int seasonNumber;
  final String? title;
  final String? originalTitle;
  final String? overview;
  final DateTime? airDate;
  final int? episodeCount;
  final String? posterUrl;
  final List<TvEpisode> episodes;
  final Map<String, dynamic> metadata;

  factory TvSeason.fromJson(Map<String, dynamic> json) {
    final seasonId = _stringOrEmpty(
      json['id'] ?? json['season_id'] ?? json['seasonId'],
    );
    final seriesId = _stringOrEmpty(
      json['series_id'] ?? json['seriesId'] ?? json['tv_series_id'],
    );
    return TvSeason(
      id: seasonId,
      seriesId: seriesId,
      seasonNumber: _intOrZero(json['season_number'] ?? json['seasonNumber']),
      title: _stringOrNull(json['title']),
      originalTitle:
          _stringOrNull(json['original_title'] ?? json['originalTitle']),
      overview: _stringOrNull(json['overview']),
      airDate: _dateOrNull(json['air_date'] ?? json['airDate']),
      episodeCount:
          _intOrNull(json['episode_count'] ?? json['episodeCount']),
      posterUrl: _stringOrNull(json['poster_url'] ?? json['posterUrl']),
      episodes: [
        for (final entry in _mapList(json['episodes']))
          TvEpisode.fromJson(entry),
      ],
      metadata: _metadataMap(json),
    );
  }

  factory TvSeason.fromDto(TvSeasonDto dto) {
    return TvSeason(
      id: dto.id,
      seriesId: dto.seriesId,
      seasonNumber: dto.seasonNumber ?? 0,
      title: _stringOrNull(dto.raw['title']) ?? dto.title,
      originalTitle:
          _stringOrNull(dto.raw['original_title'] ?? dto.raw['originalTitle']),
      overview: _stringOrNull(dto.description),
      airDate: dto.releaseDate,
      episodeCount: dto.episodeCount,
      posterUrl: _stringOrNull(dto.coverImageUrl),
      episodes: [
        for (final episode in dto.episodes) TvEpisode.fromDto(episode),
      ],
      metadata: _metadataMap(dto.raw),
    );
  }
}

final class TvReleaseMedia {
  const TvReleaseMedia({
    required this.id,
    required this.releaseId,
    this.title,
    this.formatLabel,
    this.discNumber,
    this.sequenceNumber,
    this.features = const <String>[],
    this.episodes = const <TvEpisode>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String releaseId;
  final String? title;
  final String? formatLabel;
  final int? discNumber;
  final int? sequenceNumber;
  final List<String> features;
  final List<TvEpisode> episodes;
  final Map<String, dynamic> metadata;

  factory TvReleaseMedia.fromJson(Map<String, dynamic> json) {
    return TvReleaseMedia(
      id: _stringOrEmpty(json['id']),
      releaseId: _stringOrEmpty(json['release_id'] ?? json['releaseId']),
      title: _stringOrNull(json['title']),
      formatLabel: _stringOrNull(json['format_label'] ?? json['formatLabel']),
      discNumber: _intOrNull(json['disc_number'] ?? json['discNumber']),
      sequenceNumber:
          _intOrNull(json['sequence_number'] ?? json['sequenceNumber']),
      features: _stringList(json['features']),
      episodes: [
        for (final entry in _mapList(json['episodes']))
          TvEpisode.fromJson(entry),
      ],
      metadata: _metadataMap(json),
    );
  }

  factory TvReleaseMedia.fromDto(TvReleaseMediaDto dto) {
    return TvReleaseMedia(
      id: dto.id,
      releaseId: dto.releaseId,
      title: _stringOrNull(dto.title),
      formatLabel: _stringOrNull(dto.mediaType) ?? _stringOrNull(dto.title),
      discNumber:
          _intOrNull(dto.raw['disc_number'] ?? dto.raw['discNumber'] ?? dto.mediaNumber),
      sequenceNumber: _intOrNull(
        dto.raw['sequence_number'] ?? dto.raw['sequenceNumber'] ?? dto.mediaNumber,
      ),
      features: _stringList(dto.raw['features']),
      episodes: [
        for (final entry in _mapList(dto.raw['episodes'])) TvEpisode.fromJson(entry),
      ],
      metadata: _metadataMap(dto.raw),
    );
  }
}

final class TvReleaseEpisodeMap {
  const TvReleaseEpisodeMap({
    required this.id,
    required this.releaseId,
    required this.mediaId,
    required this.episodeId,
    this.discNumber,
    this.sequenceNumber,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String releaseId;
  final String mediaId;
  final String episodeId;
  final int? discNumber;
  final int? sequenceNumber;
  final Map<String, dynamic> metadata;

  factory TvReleaseEpisodeMap.fromJson(Map<String, dynamic> json) {
    return TvReleaseEpisodeMap(
      id: _stringOrEmpty(json['id']),
      releaseId: _stringOrEmpty(json['release_id'] ?? json['releaseId']),
      mediaId: _stringOrEmpty(json['media_id'] ?? json['mediaId']),
      episodeId: _stringOrEmpty(json['episode_id'] ?? json['episodeId']),
      discNumber: _intOrNull(json['disc_number'] ?? json['discNumber']),
      sequenceNumber:
          _intOrNull(json['sequence_number'] ?? json['sequenceNumber']),
      metadata: _metadataMap(json),
    );
  }

  factory TvReleaseEpisodeMap.fromDto(TvReleaseEpisodeMapDto dto) {
    return TvReleaseEpisodeMap(
      id: dto.id,
      releaseId: dto.releaseId,
      mediaId: dto.mediaId,
      episodeId: dto.episodeId,
      discNumber: dto.discNumber,
      sequenceNumber: dto.sequenceNumber,
      metadata: _metadataMap(dto.raw),
    );
  }
}

final class TvRelease {
  const TvRelease({
    required this.id,
    required this.seriesId,
    this.title,
    this.releaseDate,
    this.country,
    this.language,
    this.media = const <TvReleaseMedia>[],
    this.episodeMappings = const <TvReleaseEpisodeMap>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String seriesId;
  final String? title;
  final DateTime? releaseDate;
  final String? country;
  final String? language;
  final List<TvReleaseMedia> media;
  final List<TvReleaseEpisodeMap> episodeMappings;
  final Map<String, dynamic> metadata;

  factory TvRelease.fromJson(Map<String, dynamic> json) {
    return TvRelease(
      id: _stringOrEmpty(json['id']),
      seriesId: _stringOrEmpty(json['series_id'] ?? json['seriesId']),
      title: _stringOrNull(json['title']),
      releaseDate: _dateOrNull(json['release_date'] ?? json['releaseDate']),
      country: _stringOrNull(json['country']),
      language: _stringOrNull(json['language']),
      media: [
        for (final entry in _mapList(json['media']))
          TvReleaseMedia.fromJson(entry),
      ],
      episodeMappings: [
        for (final entry in _mapList(
          json['episode_mappings'] ?? json['episodeMappings'],
        ))
          TvReleaseEpisodeMap.fromJson(entry),
      ],
      metadata: _metadataMap(json),
    );
  }

  factory TvRelease.fromDto(TvReleaseDto dto) {
    return TvRelease(
      id: dto.id,
      seriesId: dto.seriesId,
      title: _stringOrNull(dto.title),
      releaseDate: dto.releaseDate,
      country: _stringOrNull(dto.raw['country'] ?? dto.regionCode),
      language: _stringOrNull(dto.raw['language']) ??
          _firstStringOrNull(dto.languageAudio),
      media: [
        for (final media in dto.media) TvReleaseMedia.fromDto(media),
      ],
      episodeMappings: [
        for (final mapping in dto.episodeMappings)
          TvReleaseEpisodeMap.fromDto(mapping),
      ],
      metadata: _metadataMap(dto.raw),
    );
  }
}

final class TvSeries {
  const TvSeries({
    required this.id,
    required this.title,
    this.originalTitle,
    this.overview,
    this.firstAirDate,
    this.lastAirDate,
    this.status,
    this.type,
    this.network,
    this.originalLanguage,
    this.country,
    this.runtimeMinutes,
    this.seasonCount,
    this.episodeCount,
    this.posterUrl,
    this.backdropUrl,
    this.seasons = const <TvSeason>[],
    this.media = const <TvReleaseMedia>[],
    this.releaseEpisodeMaps = const <TvReleaseEpisodeMap>[],
    this.contributions = const <Map<String, dynamic>>[],
    this.identifiers = const <Map<String, dynamic>>[],
    this.characterAppearances = const <Map<String, dynamic>>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final String? status;
  final String? type;
  final String? network;
  final String? originalLanguage;
  final String? country;
  final int? runtimeMinutes;
  final int? seasonCount;
  final int? episodeCount;
  final String? posterUrl;
  final String? backdropUrl;
  final List<TvSeason> seasons;
  final List<TvReleaseMedia> media;
  final List<TvReleaseEpisodeMap> releaseEpisodeMaps;
  final List<Map<String, dynamic>> contributions;
  final List<Map<String, dynamic>> identifiers;
  final List<Map<String, dynamic>> characterAppearances;
  final Map<String, dynamic> metadata;

  factory TvSeries.fromDto(TvSeriesDto dto) {
    return TvSeries(
      id: dto.id,
      title: dto.title,
      originalTitle:
          _stringOrNull(dto.raw['original_title'] ?? dto.raw['originalTitle']),
      overview: dto.description,
      firstAirDate: dto.releaseDate,
      lastAirDate: _dateOrNull(dto.raw['end_date'] ?? dto.raw['last_air_date']),
      status: dto.status,
      type: _stringOrNull(dto.raw['type']),
      network: dto.network,
      originalLanguage: _stringOrNull(dto.raw['original_language']),
      country: _stringOrNull(dto.raw['country']),
      runtimeMinutes: _intOrNull(dto.raw['runtime_minutes']),
      seasonCount: dto.seasonCount,
      episodeCount: dto.episodeCount,
      posterUrl: _stringOrNull(dto.raw['poster_url'] ?? dto.raw['posterUrl']),
      backdropUrl:
          _stringOrNull(dto.raw['backdrop_url'] ?? dto.raw['backdropUrl']),
      seasons: [
        for (final season in dto.seasons) TvSeason.fromDto(season),
      ],
      media: [
        for (final releaseMedia in dto.media)
          TvReleaseMedia.fromDto(releaseMedia),
      ],
      releaseEpisodeMaps: [
        for (final entry in _mapList(dto.raw['episode_mappings']))
          TvReleaseEpisodeMap.fromJson(entry),
      ],
      contributions: _mapList(dto.raw['contributions']),
      identifiers: _mapList(dto.raw['identifiers']),
      characterAppearances: _mapList(dto.raw['character_appearances']),
      metadata: _metadataMap(dto.raw),
    );
  }
}

final class TvPersonalOverlay {
  const TvPersonalOverlay({
    this.ownedItem,
    this.trackingEntry,
    this.wishlistItem,
    this.locationPath,
    this.updatedAt,
    this.isOwnedOverride = false,
    this.isTrackedOverride = false,
    this.isWishlistedOverride = false,
  });

  final OwnedItem? ownedItem;
  final TrackingEntry? trackingEntry;
  final WishlistItem? wishlistItem;
  final String? locationPath;
  final DateTime? updatedAt;
  final bool isOwnedOverride;
  final bool isTrackedOverride;
  final bool isWishlistedOverride;

  bool get isOwned => ownedItem != null || isOwnedOverride;
  bool get isTracked => trackingEntry != null || isTrackedOverride;
  bool get isWishlisted => wishlistItem != null || isWishlistedOverride;
}

enum TvWorkspaceNodeType {
  series,
  season,
  episode,
  release,
  releaseMedia,
}

final class TvWorkspaceNode {
  const TvWorkspaceNode({
    required this.id,
    required this.title,
    required this.nodeType,
    this.parentId,
    this.seasonNumber,
    this.episodeNumber,
    this.releaseDate,
    this.formatLabel,
  });

  final String id;
  final String title;
  final TvWorkspaceNodeType nodeType;
  final String? parentId;
  final int? seasonNumber;
  final int? episodeNumber;
  final DateTime? releaseDate;
  final String? formatLabel;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
  ];
}

Map<String, dynamic> _metadataMap(Map<String, dynamic> json) {
  final metadata = json['metadata_json'];
  if (metadata is Map<String, dynamic>) {
    return Map<String, dynamic>.from(metadata);
  }
  return const <String, dynamic>{};
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  final result = <String>[];
  final seen = <String>{};
  for (final entry in value) {
    final text = entry?.toString().trim();
    if (text == null || text.isEmpty) {
      continue;
    }
    final marker = text.toLowerCase();
    if (seen.add(marker)) {
      result.add(text);
    }
  }
  return result;
}

String? _firstStringOrNull(List<String> values) {
  for (final value in values) {
    final text = value.trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

String _stringOrEmpty(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? '' : text;
}

String? _stringOrNull(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _intOrNull(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

int _intOrZero(Object? value) => _intOrNull(value) ?? 0;

DateTime? _dateOrNull(Object? value) {
  final text = _stringOrNull(value);
  return text == null ? null : DateTime.tryParse(text);
}
