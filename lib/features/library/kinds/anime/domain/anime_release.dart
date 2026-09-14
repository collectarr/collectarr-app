import 'package:flutter/foundation.dart';

import 'anime_ids.dart';

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
    this.barcode,
    this.mediaCount,
    this.audioTracks = const [],
    this.subtitles = const [],
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
  final String? barcode;
  final int? mediaCount;
  final List<String> audioTracks;
  final List<String> subtitles;
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
      publisher: _textValue(json['publisher'] ?? json['distributor']),
      barcode: _textValue(json['barcode'] ?? json['sku']),
      mediaCount: _intValue(json['media_count'] ?? json['disc_count']),
      audioTracks: _strings(json['audio_tracks'] ?? json['language_audio']),
      subtitles: _strings(json['subtitles'] ?? json['language_subtitles']),
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
        if (barcode != null) 'barcode': barcode,
        if (mediaCount != null) 'media_count': mediaCount,
        if (audioTracks.isNotEmpty) 'audio_tracks': audioTracks,
        if (subtitles.isNotEmpty) 'subtitles': subtitles,
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
