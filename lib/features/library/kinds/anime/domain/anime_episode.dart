import 'package:flutter/foundation.dart';

import 'anime_ids.dart';

@immutable
final class AnimeEpisode {
  const AnimeEpisode({
    required this.id,
    required this.seriesId,
    this.episodeNumber,
    this.title,
    this.description,
    this.airDate,
    this.runtimeMinutes,
    this.coverImageUrl,
    this.coverImageKey,
    this.rawPayload = const <String, dynamic>{},
  });

  final AnimeEpisodeId id;
  final AnimeMediaId seriesId;
  final double? episodeNumber;
  final String? title;
  final String? description;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? coverImageUrl;
  final String? coverImageKey;
  final Map<String, dynamic> rawPayload;

  AnimeEpisodeId get typedId => id;

  factory AnimeEpisode.fromJson(Map<String, dynamic> json) {
    return AnimeEpisode(
      id: AnimeEpisodeId(_textValue(json['id']) ?? ''),
      seriesId: AnimeMediaId(
        _textValue(json['series_id'] ?? json['media_id']) ?? '',
      ),
      episodeNumber: _numberValue(json['episode_number'] ?? json['number']),
      title: _textValue(json['episode_title'] ?? json['title']),
      description: _textValue(
        json['description'] ?? json['overview'] ?? json['synopsis'],
      ),
      airDate: _dateValue(json['air_date'] ?? json['release_date']),
      runtimeMinutes: _intValue(json['runtime_minutes']),
      coverImageUrl: _textValue(json['cover_image_url'] ?? json['still_url']),
      coverImageKey: _textValue(json['cover_image_key']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'id': id.value,
        'kind': 'anime',
        'series_id': seriesId.value,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (title != null) 'episode_title': title,
        if (description != null) 'description': description,
        if (airDate != null) 'air_date': airDate!.toIso8601String(),
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
        if (coverImageKey != null) 'cover_image_key': coverImageKey,
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

double? _numberValue(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '');
}

DateTime? _dateValue(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');
