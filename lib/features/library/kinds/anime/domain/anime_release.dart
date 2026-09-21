import 'package:flutter/foundation.dart';

import 'anime_ids.dart';

@immutable
final class AnimeReleaseMedia {
  const AnimeReleaseMedia({
    required this.id,
    required this.releaseId,
    required this.mediaNumber,
    required this.mediaType,
    this.title,
    this.episodeCount,
    this.runtimeMinutes,
    this.regionCode,
    this.encoding,
    this.aspectRatio,
    this.audioTracks,
    this.subtitles,
    this.resolution,
    this.hdrFormat,
  });

  final String id;
  final String releaseId;
  final int mediaNumber;
  final String mediaType;
  final String? title;
  final int? episodeCount;
  final int? runtimeMinutes;
  final String? regionCode;
  final String? encoding;
  final String? aspectRatio;
  final String? audioTracks;
  final String? subtitles;
  final String? resolution;
  final String? hdrFormat;

  factory AnimeReleaseMedia.fromJson(Map<String, dynamic> json) {
    return AnimeReleaseMedia(
      id: _textValue(json['id']) ?? '',
      releaseId: _textValue(json['release_id']) ?? '',
      mediaNumber: _intValue(json['media_number']) ?? 0,
      mediaType: _textValue(json['media_type']) ?? 'unknown',
      title: _textValue(json['title']),
      episodeCount: _intValue(json['episode_count']),
      runtimeMinutes: _intValue(json['runtime_minutes']),
      regionCode: _textValue(json['region_code']),
      encoding: _textValue(json['encoding']),
      aspectRatio: _textValue(json['aspect_ratio']),
      audioTracks: _textValue(json['audio_tracks']),
      subtitles: _textValue(json['subtitles']),
      resolution: _textValue(json['resolution']),
      hdrFormat: _textValue(json['hdr_format']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'release_id': releaseId,
        'media_number': mediaNumber,
        'media_type': mediaType,
        if (title != null) 'title': title,
        if (episodeCount != null) 'episode_count': episodeCount,
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (regionCode != null) 'region_code': regionCode,
        if (encoding != null) 'encoding': encoding,
        if (aspectRatio != null) 'aspect_ratio': aspectRatio,
        if (audioTracks != null) 'audio_tracks': audioTracks,
        if (subtitles != null) 'subtitles': subtitles,
        if (resolution != null) 'resolution': resolution,
        if (hdrFormat != null) 'hdr_format': hdrFormat,
      };
}

@immutable
final class AnimeReleaseEpisodeMapping {
  const AnimeReleaseEpisodeMapping({
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

  factory AnimeReleaseEpisodeMapping.fromJson(Map<String, dynamic> json) {
    return AnimeReleaseEpisodeMapping(
      id: _textValue(json['id']) ?? '',
      releaseId: _textValue(json['release_id']) ?? '',
      mediaId: _textValue(json['media_id']) ?? '',
      episodeId: _textValue(json['episode_id']) ?? '',
      discNumber: _intValue(json['disc_number']),
      sequenceNumber: _intValue(json['sequence_number']),
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
final class AnimeRelease {
  const AnimeRelease({
    required this.id,
    required this.title,
    this.seriesId,
    this.coverImageKey,
    this.coverImageUrl,
    this.description,
    this.format,
    this.language,
    this.regionCode,
    this.releaseDate,
    this.publisher,
    this.distributor,
    this.barcode,
    this.mediaCount,
    this.audioTracks = const [],
    this.subtitles = const [],
    this.media = const [],
    this.episodeMappings = const [],
    this.rawPayload = const <String, dynamic>{},
  });

  final AnimeReleaseId id;
  final String title;
  final AnimeMediaId? seriesId;
  final String? coverImageKey;
  final String? coverImageUrl;
  final String? description;
  final String? format;
  final String? language;
  final String? regionCode;
  final DateTime? releaseDate;
  final String? publisher;
  final String? distributor;
  final String? barcode;
  final int? mediaCount;
  final List<String> audioTracks;
  final List<String> subtitles;
  final List<AnimeReleaseMedia> media;
  final List<AnimeReleaseEpisodeMapping> episodeMappings;
  final Map<String, dynamic> rawPayload;

  AnimeReleaseId get typedId => id;

  factory AnimeRelease.fromJson(Map<String, dynamic> json) {
    return AnimeRelease(
      id: AnimeReleaseId(_textValue(json['id']) ?? ''),
      title: _textValue(json['release_title'] ?? json['title']) ??
          'Untitled release',
      seriesId: _textValue(json['series_id'] ?? json['work_id']) == null
          ? null
          : AnimeMediaId(
              _textValue(json['series_id'] ?? json['work_id'])!,
            ),
      coverImageKey: _textValue(json['cover_image_key']),
      coverImageUrl: _textValue(json['cover_image_url']),
      description: _textValue(json['description'] ?? json['synopsis']),
      format: _textValue(json['format'] ?? json['format_label']),
      language: _textValue(json['language']),
      regionCode: _textValue(json['region_code'] ?? json['region']),
      releaseDate: _dateValue(json['release_date']),
      publisher: _textValue(json['publisher']),
      distributor: _textValue(json['distributor']),
      barcode: _textValue(json['barcode'] ?? json['sku']),
      mediaCount: _intValue(json['media_count'] ?? json['disc_count']),
      audioTracks: _strings(json['audio_tracks'] ?? json['language_audio']),
      subtitles: _strings(json['subtitles'] ?? json['language_subtitles']),
      media: _maps(json['media'])
          .map(AnimeReleaseMedia.fromJson)
          .toList(growable: false),
      episodeMappings: _maps(json['episode_mappings'])
          .map(AnimeReleaseEpisodeMapping.fromJson)
          .toList(growable: false),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': 'anime',
        if (seriesId != null) 'series_id': seriesId!.value,
        'release_title': title,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (description != null) 'description': description,
        if (format != null) 'format': format,
        if (language != null) 'language': language,
        if (regionCode != null) 'region_code': regionCode,
        if (releaseDate != null) 'release_date': releaseDate!.toIso8601String(),
        if (publisher != null) 'publisher': publisher,
        if (distributor != null) 'distributor': distributor,
        if (barcode != null) 'barcode': barcode,
        if (mediaCount != null) 'media_count': mediaCount,
        if (audioTracks.isNotEmpty) 'audio_tracks': audioTracks,
        if (subtitles.isNotEmpty) 'subtitles': subtitles,
        if (media.isNotEmpty)
          'media': media.map((entry) => entry.toJson()).toList(),
        if (episodeMappings.isNotEmpty)
          'episode_mappings':
              episodeMappings.map((entry) => entry.toJson()).toList(),
      };
}

String? _textValue(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

DateTime? _dateValue(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');

List<String> _strings(Object? value) {
  if (value is! Iterable) return const <String>[];
  return [
    for (final entry in value)
      if (_textValue(entry) case final text?) text,
  ];
}

List<Map<String, dynamic>> _maps(Object? value) {
  if (value is! Iterable) return const <Map<String, dynamic>>[];
  return [
    for (final entry in value)
      if (entry is Map) Map<String, dynamic>.from(entry),
  ];
}
