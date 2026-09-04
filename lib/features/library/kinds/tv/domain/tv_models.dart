import 'package:flutter/foundation.dart';

@immutable
class TvContributor {
  const TvContributor({
    required this.name,
    this.role,
    this.imageUrl,
  });

  final String name;
  final String? role;
  final String? imageUrl;

  factory TvContributor.fromJson(Map<String, dynamic> json) {
    return TvContributor(
      name: _text(json['name']) ?? '',
      role: _text(json['role']),
      imageUrl: _text(json['image_url']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (role != null) 'role': role,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}

@immutable
class TvCharacterAppearance {
  const TvCharacterAppearance({
    required this.id,
    required this.characterId,
    required this.characterName,
    required this.role,
  });

  final String id;
  final String characterId;
  final String characterName;
  final String role;

  factory TvCharacterAppearance.fromJson(Map<String, dynamic> json) {
    return TvCharacterAppearance(
      id: _text(json['id']) ?? '',
      characterId: _text(json['character_id']) ?? '',
      characterName: _text(json['character_name']) ?? '',
      role: _text(json['role']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'character_id': characterId,
        'character_name': characterName,
        'role': role,
      };
}

@immutable
class TvIdentifier {
  const TvIdentifier({
    required this.id,
    required this.identifierType,
    required this.value,
    this.isPrimary = false,
  });

  final String id;
  final String identifierType;
  final String value;
  final bool isPrimary;

  factory TvIdentifier.fromJson(Map<String, dynamic> json) {
    return TvIdentifier(
      id: _text(json['id']) ?? '',
      identifierType: _text(json['identifier_type'] ?? json['type']) ?? '',
      value: _text(json['value']) ?? '',
      isPrimary: json['is_primary'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'identifier_type': identifierType,
        'value': value,
        'is_primary': isPrimary,
      };
}

@immutable
class TvEpisode {
  const TvEpisode({
    required this.id,
    required this.seriesId,
    required this.seasonId,
    this.seasonNumber,
    this.episodeNumber,
    this.title,
    this.originalTitle,
    this.description,
    this.airDate,
    this.runtimeMinutes,
    this.coverImageUrl,
    this.coverImageKey,
  });

  final String id;
  final String seriesId;
  final String seasonId;
  final int? seasonNumber;
  final double? episodeNumber;
  final String? title;
  final String? originalTitle;
  final String? description;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? coverImageUrl;
  final String? coverImageKey;

  factory TvEpisode.fromJson(Map<String, dynamic> json) {
    return TvEpisode(
      id: _text(json['id']) ?? '',
      seriesId: _text(json['series_id']) ?? '',
      seasonId: _text(json['season_id']) ?? '',
      seasonNumber: _int(json['season_number']),
      episodeNumber: _number(json['episode_number'] ?? json['number']),
      title: _text(json['episode_title'] ?? json['title']),
      originalTitle: _text(json['original_title']),
      description:
          _text(json['description'] ?? json['overview'] ?? json['synopsis']),
      airDate: _date(json['air_date'] ?? json['release_date']),
      runtimeMinutes: _int(json['runtime_minutes']),
      coverImageUrl: _text(json['cover_image_url'] ?? json['still_url']),
      coverImageKey: _text(json['cover_image_key']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'series_id': seriesId,
        'season_id': seasonId,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (title != null) 'title': title,
        if (originalTitle != null) 'original_title': originalTitle,
        if (description != null) 'description': description,
        if (airDate != null) 'air_date': airDate!.toIso8601String(),
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
      };
}

@immutable
class TvSeason {
  const TvSeason({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    this.title,
    this.description,
    this.airDate,
    this.episodeCount,
    this.coverImageUrl,
    this.coverImageKey,
    this.episodes = const [],
  });

  final String id;
  final String seriesId;
  final int? seasonNumber;
  final String? title;
  final String? description;
  final DateTime? airDate;
  final int? episodeCount;
  final String? coverImageUrl;
  final String? coverImageKey;
  final List<TvEpisode> episodes;

  factory TvSeason.fromJson(Map<String, dynamic> json) {
    return TvSeason(
      id: _text(json['id']) ?? '',
      seriesId: _text(json['series_id']) ?? '',
      seasonNumber: _int(json['season_number']),
      title: _text(json['title']) ??
          (_int(json['season_number']) == null
              ? null
              : 'Season ${json['season_number']}'),
      description:
          _text(json['description'] ?? json['overview'] ?? json['synopsis']),
      airDate: _date(json['air_date'] ?? json['release_date']),
      episodeCount: _int(json['episode_count']),
      coverImageUrl: _text(json['cover_image_url'] ?? json['poster_url']),
      coverImageKey: _text(json['cover_image_key']),
      episodes: _maps(json['episodes'])
          .map(TvEpisode.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'series_id': seriesId,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (airDate != null) 'air_date': airDate!.toIso8601String(),
        if (episodeCount != null) 'episode_count': episodeCount,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (episodes.isNotEmpty)
          'episodes': episodes.map((episode) => episode.toJson()).toList(),
      };
}

@immutable
class TvReleaseMedia {
  const TvReleaseMedia({
    required this.id,
    required this.releaseId,
    this.mediaNumber,
    this.mediaType,
    this.title,
    this.episodeCount,
    this.runtimeMinutes,
    this.regionCode,
    this.encoding,
    this.aspectRatio,
    this.color,
    this.audioTracks,
    this.subtitles,
    this.layers,
    this.frameRate,
    this.bitDepth,
    this.resolution,
    this.hdrFormat,
    this.episodes = const [],
  });

  final String id;
  final String releaseId;
  final int? mediaNumber;
  final String? mediaType;
  final String? title;
  final int? episodeCount;
  final int? runtimeMinutes;
  final String? regionCode;
  final String? encoding;
  final String? aspectRatio;
  final String? color;
  final String? audioTracks;
  final String? subtitles;
  final String? layers;
  final String? frameRate;
  final String? bitDepth;
  final String? resolution;
  final String? hdrFormat;
  final List<TvEpisode> episodes;

  factory TvReleaseMedia.fromJson(Map<String, dynamic> json) {
    return TvReleaseMedia(
      id: _text(json['id']) ?? '',
      releaseId: _text(json['release_id']) ?? '',
      mediaNumber: _int(json['media_number'] ?? json['disc_number']),
      mediaType: _text(json['media_type']),
      title: _text(json['title'] ?? json['name']),
      episodeCount: _int(json['episode_count']),
      runtimeMinutes: _int(json['runtime_minutes']),
      regionCode: _text(json['region_code'] ?? json['region']),
      encoding: _text(json['encoding']),
      aspectRatio: _text(json['aspect_ratio']),
      color: _text(json['color']),
      audioTracks: _text(json['audio_tracks']),
      subtitles: _text(json['subtitles']),
      layers: _text(json['layers']),
      frameRate: _text(json['frame_rate']),
      bitDepth: _text(json['bit_depth']),
      resolution: _text(json['resolution']),
      hdrFormat: _text(json['hdr_format']),
      episodes: _maps(json['episodes'])
          .map(TvEpisode.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'release_id': releaseId,
        if (mediaNumber != null) 'media_number': mediaNumber,
        if (mediaType != null) 'media_type': mediaType,
        if (title != null) 'title': title,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (regionCode != null) 'region_code': regionCode,
        if (encoding != null) 'encoding': encoding,
        if (aspectRatio != null) 'aspect_ratio': aspectRatio,
        if (color != null) 'color': color,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (layers != null) 'layers': layers,
        if (frameRate != null) 'frame_rate': frameRate,
        if (bitDepth != null) 'bit_depth': bitDepth,
        if (resolution != null) 'resolution': resolution,
        if (hdrFormat != null) 'hdr_format': hdrFormat,
        if (episodes.isNotEmpty)
          'episodes': episodes.map((episode) => episode.toJson()).toList(),
      };
}

@immutable
class TvReleaseEpisodeMap {
  const TvReleaseEpisodeMap({
    required this.id,
    required this.releaseId,
    required this.mediaId,
    required this.episodeId,
    this.discNumber,
    this.sequenceNumber,
  });

  final String id;
  final String releaseId;
  final String mediaId;
  final String episodeId;
  final int? discNumber;
  final int? sequenceNumber;

  factory TvReleaseEpisodeMap.fromJson(Map<String, dynamic> json) {
    return TvReleaseEpisodeMap(
      id: _text(json['id']) ?? '',
      releaseId: _text(json['release_id']) ?? '',
      mediaId: _text(json['media_id']) ?? '',
      episodeId: _text(json['episode_id']) ?? '',
      discNumber: _int(json['disc_number']),
      sequenceNumber: _int(json['sequence_number']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'release_id': releaseId,
        'media_id': mediaId,
        'episode_id': episodeId,
        if (discNumber != null) 'disc_number': discNumber,
        if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      };
}

@immutable
class TvRelease {
  const TvRelease({
    required this.id,
    required this.seriesId,
    required this.title,
    this.sortTitle,
    this.description,
    this.mediaCount,
    this.format,
    this.regionCode,
    this.releaseDate,
    this.publisher,
    this.sku,
    this.caseType,
    this.episodeCount,
    this.seasonCount,
    this.runtimeMinutes,
    this.languageAudio = const [],
    this.languageSubtitles = const [],
    this.contentRating,
    this.coverImageUrl,
    this.coverImageKey,
    this.media = const [],
    this.episodeMappings = const [],
  });

  final String id;
  final String seriesId;
  final String title;
  final String? sortTitle;
  final String? description;
  final int? mediaCount;
  final String? format;
  final String? regionCode;
  final DateTime? releaseDate;
  final String? publisher;
  final String? sku;
  final String? caseType;
  final int? episodeCount;
  final int? seasonCount;
  final int? runtimeMinutes;
  final List<String> languageAudio;
  final List<String> languageSubtitles;
  final String? contentRating;
  final String? coverImageUrl;
  final String? coverImageKey;
  final List<TvReleaseMedia> media;
  final List<TvReleaseEpisodeMap> episodeMappings;

  factory TvRelease.fromJson(Map<String, dynamic> json) {
    return TvRelease(
      id: _text(json['id']) ?? '',
      seriesId: _text(json['series_id']) ?? '',
      title: _text(json['title']) ?? 'Untitled release',
      sortTitle: _text(json['sort_title']),
      description: _text(json['description'] ?? json['synopsis']),
      mediaCount: _int(json['media_count']),
      format: _text(json['format'] ?? json['format_label']),
      regionCode: _text(json['region_code'] ?? json['region']),
      releaseDate: _date(json['release_date']),
      publisher: _text(json['publisher']),
      sku: _text(json['sku'] ?? json['barcode']),
      caseType: _text(json['case_type']),
      episodeCount: _int(json['episode_count']),
      seasonCount: _int(json['season_count']),
      runtimeMinutes: _int(json['runtime_minutes']),
      languageAudio: _strings(json['language_audio']),
      languageSubtitles: _strings(json['language_subtitles']),
      contentRating: _text(json['content_rating']),
      coverImageUrl: _text(json['cover_image_url']),
      coverImageKey: _text(json['cover_image_key']),
      media: _maps(json['media'])
          .map(TvReleaseMedia.fromJson)
          .toList(growable: false),
      episodeMappings: _maps(json['episode_mappings'] ?? json['episode_maps'])
          .map(TvReleaseEpisodeMap.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'series_id': seriesId,
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (description != null) 'description': description,
        if (mediaCount != null) 'media_count': mediaCount,
        if (format != null) 'format': format,
        if (regionCode != null) 'region_code': regionCode,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (publisher != null) 'publisher': publisher,
        if (sku != null) 'sku': sku,
        if (caseType != null) 'case_type': caseType,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (seasonCount != null) 'season_count': seasonCount,
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (languageAudio.isNotEmpty) 'language_audio': languageAudio,
        if (languageSubtitles.isNotEmpty)
          'language_subtitles': languageSubtitles,
        if (contentRating != null) 'content_rating': contentRating,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (media.isNotEmpty)
          'media': media.map((entry) => entry.toJson()).toList(),
        if (episodeMappings.isNotEmpty)
          'episode_mappings':
              episodeMappings.map((entry) => entry.toJson()).toList(),
      };
}

@immutable
class TvSeries {
  const TvSeries({
    required this.id,
    required this.title,
    this.sortTitle,
    this.description,
    this.endDate,
    this.episodeCount,
    this.network,
    this.originalAirDate,
    this.originalLanguage,
    this.seasonCount,
    this.status,
    this.seasons = const [],
    this.releases = const [],
    this.media = const [],
    this.releaseEpisodeMaps = const [],
    this.contributions = const [],
    this.identifiers = const [],
    this.characterAppearances = const [],
  });

  final String id;
  final String title;
  final String? sortTitle;
  final String? description;
  final DateTime? endDate;
  final int? episodeCount;
  final String? network;
  final DateTime? originalAirDate;
  final String? originalLanguage;
  final int? seasonCount;
  final String? status;
  final List<TvSeason> seasons;
  final List<TvRelease> releases;
  final List<TvReleaseMedia> media;
  final List<TvReleaseEpisodeMap> releaseEpisodeMaps;
  final List<TvContributor> contributions;
  final List<TvIdentifier> identifiers;
  final List<TvCharacterAppearance> characterAppearances;

  factory TvSeries.fromJson(Map<String, dynamic> json) {
    return TvSeries(
      id: _text(json['id']) ?? '',
      title: _text(json['title']) ?? '',
      sortTitle: _text(json['sort_title']),
      description:
          _text(json['description'] ?? json['overview'] ?? json['synopsis']),
      endDate: _date(json['end_date'] ?? json['last_air_date']),
      episodeCount: _int(json['episode_count']),
      network: _text(json['network']),
      originalAirDate:
          _date(json['original_air_date'] ?? json['first_air_date']),
      originalLanguage: _text(json['original_language']),
      seasonCount: _int(json['season_count']),
      status: _text(json['status']),
      seasons:
          _maps(json['seasons']).map(TvSeason.fromJson).toList(growable: false),
      releases: _maps(json['releases'] ?? json['editions'])
          .map(TvRelease.fromJson)
          .toList(growable: false),
      media: _maps(json['media'])
          .map(TvReleaseMedia.fromJson)
          .toList(growable: false),
      releaseEpisodeMaps: _maps(json['episode_mappings'])
          .map(TvReleaseEpisodeMap.fromJson)
          .toList(growable: false),
      contributions: _maps(json['contributions'])
          .map(TvContributor.fromJson)
          .toList(growable: false),
      identifiers: _maps(json['identifiers'])
          .map(TvIdentifier.fromJson)
          .toList(growable: false),
      characterAppearances: _maps(json['character_appearances'])
          .map(TvCharacterAppearance.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': 'tv',
        'title': title,
        if (sortTitle != null) 'sort_title': sortTitle,
        if (description != null) 'description': description,
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        if (episodeCount != null) 'episode_count': episodeCount,
        if (network != null) 'network': network,
        if (originalAirDate != null)
          'original_air_date': originalAirDate!.toIso8601String(),
        if (originalLanguage != null) 'original_language': originalLanguage,
        if (seasonCount != null) 'season_count': seasonCount,
        if (status != null) 'status': status,
        if (seasons.isNotEmpty)
          'seasons': seasons.map((entry) => entry.toJson()).toList(),
        if (releases.isNotEmpty)
          'releases': releases.map((entry) => entry.toJson()).toList(),
        if (media.isNotEmpty)
          'media': media.map((entry) => entry.toJson()).toList(),
        if (releaseEpisodeMaps.isNotEmpty)
          'episode_mappings':
              releaseEpisodeMaps.map((entry) => entry.toJson()).toList(),
        if (contributions.isNotEmpty)
          'contributions':
              contributions.map((entry) => entry.toJson()).toList(),
        if (identifiers.isNotEmpty)
          'identifiers': identifiers.map((entry) => entry.toJson()).toList(),
        if (characterAppearances.isNotEmpty)
          'character_appearances':
              characterAppearances.map((entry) => entry.toJson()).toList(),
      };
}

String? _text(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '');
}

DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');

List<String> _strings(Object? value) {
  if (value is! Iterable) return const <String>[];
  return [
    for (final entry in value)
      if (_text(entry) case final text?) text,
  ];
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return [
    for (final entry in value)
      if (entry is Map) Map<String, dynamic>.from(entry),
  ];
}
