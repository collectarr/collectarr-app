import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:flutter/foundation.dart';

import 'anime_ids.dart';

@immutable
final class AnimeTracking {
  const AnimeTracking({
    required this.mediaId,
    this.id,
    this.episodeId,
    this.status = '',
    this.sourceType,
    this.rating,
    this.notes,
    this.startedAt,
    this.finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted = 0,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeRatings = const {},
    this.updatedAt,
    this.deletedAt,
  });

  final String? id;
  final AnimeMediaId mediaId;
  final AnimeEpisodeId? episodeId;
  final String status;
  final TrackingSourceType? sourceType;
  final int? rating;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int timesCompleted;
  final int? seasonNumber;
  final double? episodeNumber;
  final Map<String, int> episodeRatings;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'media_id': mediaId.value,
        if (episodeId != null) 'episode_id': episodeId!.value,
        'status': status,
        if (sourceType != null) 'source_type': sourceType!.apiValue,
        if (rating != null) 'rating': rating,
        if (notes != null) 'notes': notes,
        if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
        if (progressCurrent != null) 'progress_current': progressCurrent,
        if (progressTotal != null) 'progress_total': progressTotal,
        'times_completed': timesCompleted,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (episodeRatings.isNotEmpty) 'episode_ratings': episodeRatings,
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };

  factory AnimeTracking.fromJson(Map<String, dynamic> json) {
    return AnimeTracking(
      id: _textValue(json['id']),
      mediaId: AnimeMediaId(
        _textValue(json['media_id'] ?? json['series_id'] ?? json['item_id']) ??
            '',
      ),
      episodeId: _textValue(json['episode_id']) == null
          ? null
          : AnimeEpisodeId(_textValue(json['episode_id'])!),
      status: _textValue(json['status']) ?? '',
      sourceType: trackingSourceTypeFromValue(json['source_type']),
      rating: _intValue(json['rating']),
      notes: _textValue(json['notes']),
      startedAt: _dateValue(json['started_at']),
      finishedAt: _dateValue(json['finished_at']),
      progressCurrent: _intValue(json['progress_current']),
      progressTotal: _intValue(json['progress_total']),
      timesCompleted: _intValue(json['times_completed']) ?? 0,
      seasonNumber: _intValue(json['season_number']),
      episodeNumber: _numberValue(json['episode_number']),
      episodeRatings: _episodeRatings(json['episode_ratings']),
      updatedAt: _dateValue(json['updated_at']),
      deletedAt: _dateValue(json['deleted_at']),
    );
  }
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

Map<String, int> _episodeRatings(Object? value) {
  if (value is! Map) return const <String, int>{};
  return {
    for (final entry in value.entries)
      if (entry.key is String && entry.value is num)
        entry.key as String: (entry.value as num).toInt(),
  };
}
