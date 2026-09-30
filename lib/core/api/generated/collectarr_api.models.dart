import 'package:flutter/foundation.dart';

import 'collectarr_api.enums.dart';

@immutable
abstract class TypedMetadataResponse {
  const TypedMetadataResponse(this.raw);

  final Map<String, dynamic> raw;

  String get id;
  String get title;
  String? get kind;
  CollectarrItemKind? get mediaKind => CollectarrItemKind.fromApiValue(kind);
  DateTime? get releaseDate;
  String? get coverImageUrl;
  String? get thumbnailImageUrl;
  String? get barcode;

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

String _stringValue(dynamic value, {String fallback = ''}) =>
    value?.toString() ?? fallback;

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _nullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _nullableDate(dynamic value) {
  final text = _nullableString(value);
  return text == null ? null : DateTime.tryParse(text);
}

/// A typed boundary for catalog responses whose kind-specific DTO is owned by
/// the kind module. Shared API consumers can inspect common fields and retain
/// the complete response without introducing another kind-specific model.
@immutable
final class RawTypedMetadataResponse extends TypedMetadataResponse {
  const RawTypedMetadataResponse._(
    super.raw, {
    required this.id,
    required this.title,
    required this.kind,
  });

  factory RawTypedMetadataResponse.fromJson(Map<String, dynamic> json) {
    final id = _nullableString(json['id']);
    final title = _nullableString(json['title']);
    if (id == null || title == null) {
      throw const FormatException('Catalog response requires id and title.');
    }
    return RawTypedMetadataResponse._(
      Map<String, dynamic>.from(json),
      id: id,
      title: title,
      kind: _nullableString(json['kind']),
    );
  }

  @override
  final String id;

  @override
  final String title;

  @override
  final String? kind;

  @override
  DateTime? get releaseDate =>
      _nullableDate(raw['release_date'] ?? raw['original_release_date']);

  @override
  String? get coverImageUrl => _nullableString(raw['cover_image_url']);

  @override
  String? get thumbnailImageUrl =>
      _nullableString(raw['thumbnail_image_url']) ?? coverImageUrl;

  @override
  String? get barcode => _nullableString(raw['barcode']);
}

List<dynamic> _dynamicList(dynamic value) {
  if (value is List) {
    return List<dynamic>.from(value);
  }
  return const <dynamic>[];
}

List<String> _stringList(dynamic value) {
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

class TvEpisodeDto extends TypedMetadataResponse {
  const TvEpisodeDto._(
    super.raw, {
    required this.id,
    required this.seasonId,
    required this.episodeNumber,
    required this.episodeTitle,
    required this.airDateValue,
    required this.description,
    required this.coverImageUrlValue,
    required this.coverImageKey,
    required this.runtimeMinutes,
  });

  @override
  final String id;
  final String seasonId;
  final double? episodeNumber;
  final String? episodeTitle;
  final DateTime? airDateValue;
  final String? description;
  final String? coverImageUrlValue;
  final String? coverImageKey;
  final int? runtimeMinutes;
  @override
  String get title => episodeTitle ?? 'Episode';
  @override
  String? get kind => CollectarrItemKind.tv.apiValue;
  @override
  DateTime? get releaseDate => airDateValue;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrlValue;
  @override
  String? get barcode => null;

  factory TvEpisodeDto.fromJson(Map<String, dynamic> json) {
    return TvEpisodeDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      seasonId: _stringValue(json['season_id']),
      episodeNumber: _nullableInt(json['episode_number'])?.toDouble(),
      episodeTitle: _nullableString(json['episode_title']),
      airDateValue: _nullableDate(json['air_date']),
      description: _nullableString(json['description']),
      coverImageUrlValue: _nullableString(json['cover_image_url']),
      coverImageKey: _nullableString(json['cover_image_key']),
      runtimeMinutes: _nullableInt(json['runtime_minutes']),
    );
  }
}

class TvSeasonDto extends TypedMetadataResponse {
  const TvSeasonDto._(
    super.raw, {
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.airDateValue,
    required this.episodeCount,
    required this.description,
    required this.coverImageUrlValue,
    required this.coverImageKey,
    required this.episodes,
  });

  @override
  final String id;
  final String seriesId;
  final int? seasonNumber;
  final DateTime? airDateValue;
  final int? episodeCount;
  final String? description;
  final String? coverImageUrlValue;
  final String? coverImageKey;
  final List<TvEpisodeDto> episodes;
  @override
  String get title => 'Season ${seasonNumber ?? ''}'.trim();
  @override
  String? get kind => CollectarrItemKind.tv.apiValue;
  @override
  DateTime? get releaseDate => airDateValue;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrlValue;
  @override
  String? get barcode => null;

  factory TvSeasonDto.fromJson(Map<String, dynamic> json) {
    return TvSeasonDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      seriesId: _stringValue(json['series_id']),
      seasonNumber: _nullableInt(json['season_number']),
      airDateValue: _nullableDate(json['air_date']),
      episodeCount: _nullableInt(json['episode_count']),
      description: _nullableString(json['description']),
      coverImageUrlValue: _nullableString(json['cover_image_url']),
      coverImageKey: _nullableString(json['cover_image_key']),
      episodes: [
        for (final entry in _mapList(json['episodes']))
          TvEpisodeDto.fromJson(entry),
      ],
    );
  }
}

class TvReleaseMediaDto extends TypedMetadataResponse {
  const TvReleaseMediaDto._(
    super.raw, {
    required this.id,
    required this.releaseId,
    required this.mediaNumber,
    required this.mediaType,
    required this.titleValue,
    required this.episodeCount,
    required this.runtimeMinutes,
    required this.regionCode,
    required this.encoding,
    required this.aspectRatio,
    required this.color,
    required this.audioTracks,
    required this.subtitles,
    required this.layers,
    required this.frameRate,
    required this.bitDepth,
    required this.resolution,
    required this.hdrFormat,
  });

  @override
  final String id;
  final String releaseId;
  final int? mediaNumber;
  final String? mediaType;
  final String? titleValue;
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
  @override
  String get title => titleValue ?? 'Media';
  @override
  String? get kind => CollectarrItemKind.tv.apiValue;
  @override
  DateTime? get releaseDate => null;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory TvReleaseMediaDto.fromJson(Map<String, dynamic> json) {
    return TvReleaseMediaDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      releaseId: _stringValue(json['release_id']),
      mediaNumber: _nullableInt(json['media_number']),
      mediaType: _nullableString(json['media_type']),
      titleValue: _nullableString(json['title']),
      episodeCount: _nullableInt(json['episode_count']),
      runtimeMinutes: _nullableInt(json['runtime_minutes']),
      regionCode: _nullableString(json['region_code']),
      encoding: _nullableString(json['encoding']),
      aspectRatio: _nullableString(json['aspect_ratio']),
      color: _nullableString(json['color']),
      audioTracks: _nullableString(json['audio_tracks']),
      subtitles: _nullableString(json['subtitles']),
      layers: _nullableString(json['layers']),
      frameRate: _nullableString(json['frame_rate']),
      bitDepth: _nullableString(json['bit_depth']),
      resolution: _nullableString(json['resolution']),
      hdrFormat: _nullableString(json['hdr_format']),
    );
  }
}

class TvReleaseEpisodeMapDto extends TypedMetadataResponse {
  const TvReleaseEpisodeMapDto._(
    super.raw, {
    required this.id,
    required this.releaseId,
    required this.mediaId,
    required this.episodeId,
    required this.discNumber,
    required this.sequenceNumber,
  });

  @override
  final String id;
  final String releaseId;
  final String mediaId;
  final String episodeId;
  final int? discNumber;
  final int? sequenceNumber;
  @override
  String get title => 'Episode map';
  @override
  String? get kind => CollectarrItemKind.tv.apiValue;
  @override
  DateTime? get releaseDate => null;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory TvReleaseEpisodeMapDto.fromJson(Map<String, dynamic> json) {
    return TvReleaseEpisodeMapDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      releaseId: _stringValue(json['release_id']),
      mediaId: _stringValue(json['media_id']),
      episodeId: _stringValue(json['episode_id']),
      discNumber: _nullableInt(json['disc_number']),
      sequenceNumber: _nullableInt(json['sequence_number']),
    );
  }
}

class TvReleaseDto extends TypedMetadataResponse {
  const TvReleaseDto._(
    super.raw, {
    required this.id,
    required this.seriesId,
    required this.titleValue,
    required this.sortTitle,
    required this.description,
    required this.mediaCount,
    required this.format,
    required this.regionCode,
    required this.releaseDateValue,
    required this.publisher,
    required this.sku,
    required this.caseType,
    required this.episodeCount,
    required this.seasonCount,
    required this.runtimeMinutes,
    required this.languageAudio,
    required this.languageSubtitles,
    required this.contentRating,
    required this.coverImageUrlValue,
    required this.coverImageKey,
    required this.media,
    required this.episodeMappings,
  });

  @override
  final String id;
  final String seriesId;
  final String titleValue;
  final String? sortTitle;
  final String? description;
  final int? mediaCount;
  final String? format;
  final String? regionCode;
  final DateTime? releaseDateValue;
  final String? publisher;
  final String? sku;
  final String? caseType;
  final int? episodeCount;
  final int? seasonCount;
  final int? runtimeMinutes;
  final List<String> languageAudio;
  final List<String> languageSubtitles;
  final String? contentRating;
  final String? coverImageUrlValue;
  final String? coverImageKey;
  final List<TvReleaseMediaDto> media;
  final List<TvReleaseEpisodeMapDto> episodeMappings;
  @override
  String get title => titleValue;
  @override
  String? get kind => CollectarrItemKind.tv.apiValue;
  @override
  DateTime? get releaseDate => releaseDateValue;
  @override
  String? get coverImageUrl => coverImageUrlValue;
  @override
  String? get thumbnailImageUrl => coverImageUrlValue;
  @override
  String? get barcode => sku;

  factory TvReleaseDto.fromJson(Map<String, dynamic> json) {
    return TvReleaseDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      seriesId: _stringValue(json['series_id']),
      titleValue: _stringValue(json['title'], fallback: 'Untitled item'),
      sortTitle: _nullableString(json['sort_title']),
      description: _nullableString(json['description']),
      mediaCount: _nullableInt(json['media_count']),
      format: _nullableString(json['format']),
      regionCode: _nullableString(json['region_code']),
      releaseDateValue: _nullableDate(json['release_date']),
      publisher: _nullableString(json['publisher']),
      sku: _nullableString(json['sku']),
      caseType: _nullableString(json['case_type']),
      episodeCount: _nullableInt(json['episode_count']),
      seasonCount: _nullableInt(json['season_count']),
      runtimeMinutes: _nullableInt(json['runtime_minutes']),
      languageAudio: _stringList(json['language_audio']),
      languageSubtitles: _stringList(json['language_subtitles']),
      contentRating: _nullableString(json['content_rating']),
      coverImageUrlValue: _nullableString(json['cover_image_url']),
      coverImageKey: _nullableString(json['cover_image_key']),
      media: [
        for (final entry in _mapList(json['media']))
          TvReleaseMediaDto.fromJson(entry),
      ],
      episodeMappings: [
        for (final entry in _mapList(json['episode_mappings']))
          TvReleaseEpisodeMapDto.fromJson(entry),
      ],
    );
  }
}

class ComicWorkDto extends TypedMetadataResponse {
  const ComicWorkDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.contributors,
    required this.description,
    required this.firstPublicationDate,
    required this.originalLanguage,
    required this.sortTitle,
    required this.subtitle,
    required this.issues,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<dynamic> contributors;
  final String? description;
  final DateTime? firstPublicationDate;
  final String? originalLanguage;
  final String? sortTitle;
  final String? subtitle;
  final List<dynamic> issues;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => firstPublicationDate;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory ComicWorkDto.fromJson(Map<String, dynamic> json) {
    return ComicWorkDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      contributors: _dynamicList(json['contributors']),
      description: _nullableString(json['description']),
      firstPublicationDate: _nullableDate(json['first_publication_date']),
      originalLanguage: _nullableString(json['original_language']),
      sortTitle: _nullableString(json['sort_title']),
      subtitle: _nullableString(json['subtitle']),
      issues: _dynamicList(json['issues']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.comic.apiValue,
    );
  }
}

class TvSeriesDto extends TypedMetadataResponse {
  const TvSeriesDto._(
    super.raw, {
    required this.id,
    required this.title,
    required this.characterAppearances,
    required this.contributions,
    required this.description,
    required this.endDate,
    required this.episodeCount,
    required this.identifiers,
    required this.media,
    required this.network,
    required this.originalAirDate,
    required this.originalLanguage,
    required this.seasonCount,
    required this.seasons,
    required this.sortTitle,
    required this.status,
    required this.kind,
  });

  @override
  final String id;
  @override
  final String title;
  final List<dynamic> characterAppearances;
  final List<dynamic> contributions;
  final String? description;
  final DateTime? endDate;
  final int? episodeCount;
  final List<dynamic> identifiers;
  final List<dynamic> media;
  final String? network;
  final DateTime? originalAirDate;
  final String? originalLanguage;
  final int? seasonCount;
  final List<dynamic> seasons;
  final String? sortTitle;
  final String? status;
  @override
  final String? kind;
  @override
  DateTime? get releaseDate => originalAirDate;
  @override
  String? get coverImageUrl => null;
  @override
  String? get thumbnailImageUrl => null;
  @override
  String? get barcode => null;

  factory TvSeriesDto.fromJson(Map<String, dynamic> json) {
    return TvSeriesDto._(
      Map<String, dynamic>.from(json),
      id: _stringValue(json['id']),
      title: _stringValue(json['title'], fallback: 'Untitled item'),
      characterAppearances: _dynamicList(json['character_appearances']),
      contributions: _dynamicList(json['contributions']),
      description: _nullableString(json['description']),
      endDate: _nullableDate(json['end_date']),
      episodeCount: _nullableInt(json['episode_count']),
      identifiers: _dynamicList(json['identifiers']),
      media: _dynamicList(json['media']),
      network: _nullableString(json['network']),
      originalAirDate: _nullableDate(json['original_air_date']),
      originalLanguage: _nullableString(json['original_language']),
      seasonCount: _nullableInt(json['season_count']),
      seasons: _dynamicList(json['seasons']),
      sortTitle: _nullableString(json['sort_title']),
      status: _nullableString(json['status']),
      kind: _nullableString(json['kind']) ?? CollectarrItemKind.tv.apiValue,
    );
  }
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return [
    for (final entry in value)
      if (entry is Map<String, dynamic>) Map<String, dynamic>.from(entry),
  ];
}
