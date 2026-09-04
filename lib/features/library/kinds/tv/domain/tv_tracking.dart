import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';

import 'tv_ids.dart';

final class TvWatchSession {
  const TvWatchSession({
    required this.id,
    required this.seriesId,
    required this.targetRef,
    required this.watchedAt,
    required this.updatedAt,
    this.episodeId,
    this.trackingEntryId,
    this.seasonNumber,
    this.episodeNumber,
    this.sourceType,
    this.seenWhere,
    this.rating,
    this.notes,
    this.deletedAt,
  });

  final String id;
  final TvSeriesId seriesId;
  final TvEpisodeId? episodeId;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final int? seasonNumber;
  final int? episodeNumber;
  final TrackingSourceType? sourceType;
  final String? seenWhere;
  final DateTime watchedAt;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'series_id': seriesId.value,
        if (episodeId != null) 'episode_id': episodeId!.value,
        'target_ref': targetRef.toJson(),
        if (trackingEntryId != null) 'tracking_entry_id': trackingEntryId,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        if (sourceType != null) 'source_type': sourceType!.apiValue,
        if (seenWhere != null) 'seen_where': seenWhere,
        'watched_at': watchedAt.toUtc().toIso8601String(),
        if (rating != null) 'rating': rating,
        if (notes != null) 'notes': notes,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        if (deletedAt != null)
          'deleted_at': deletedAt!.toUtc().toIso8601String(),
      };

  factory TvWatchSession.fromJson(Map<String, dynamic> json) {
    final targetRef = json['target_ref'];
    if (targetRef is! Map) {
      throw const FormatException('TV watch session is missing target_ref');
    }
    return TvWatchSession(
      id: _text(json['id']) ?? '',
      seriesId: TvSeriesId(_text(json['series_id']) ?? ''),
      episodeId: _text(json['episode_id']) == null
          ? null
          : TvEpisodeId(_text(json['episode_id'])!),
      targetRef:
          CatalogEntityRef.fromJson(Map<String, dynamic>.from(targetRef)),
      trackingEntryId: _text(json['tracking_entry_id']),
      seasonNumber: _int(json['season_number']),
      episodeNumber: _int(json['episode_number']),
      sourceType: trackingSourceTypeFromValue(json['source_type']),
      seenWhere: _text(json['seen_where']),
      watchedAt: DateTime.parse(json['watched_at'] as String),
      rating: _int(json['rating']),
      notes: _text(json['notes']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }
}

final class TvEpisodeProgress {
  const TvEpisodeProgress({
    required this.seriesId,
    required this.seasonId,
    required this.episodeId,
    required this.updatedAt,
    this.seasonNumber,
    this.episodeNumber,
    this.watchedCount = 0,
    this.completed = false,
    this.lastWatchedAt,
    this.rating,
    this.notes,
    this.deletedAt,
    this.rawPayload = const <String, dynamic>{},
  });

  final TvSeriesId seriesId;
  final TvSeasonId seasonId;
  final TvEpisodeId episodeId;
  final int? seasonNumber;
  final double? episodeNumber;
  final int watchedCount;
  final bool completed;
  final DateTime? lastWatchedAt;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<String, dynamic> rawPayload;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        ...rawPayload,
        'series_id': seriesId.value,
        'season_id': seasonId.value,
        'episode_id': episodeId.value,
        if (seasonNumber != null) 'season_number': seasonNumber,
        if (episodeNumber != null) 'episode_number': episodeNumber,
        'watched_count': watchedCount,
        'completed': completed,
        if (lastWatchedAt != null)
          'last_watched_at': lastWatchedAt!.toUtc().toIso8601String(),
        if (rating != null) 'rating': rating,
        if (notes != null) 'notes': notes,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        if (deletedAt != null)
          'deleted_at': deletedAt!.toUtc().toIso8601String(),
      };

  factory TvEpisodeProgress.fromJson(Map<String, dynamic> json) {
    return TvEpisodeProgress(
      seriesId: TvSeriesId(_text(json['series_id']) ?? ''),
      seasonId: TvSeasonId(_text(json['season_id']) ?? ''),
      episodeId: TvEpisodeId(_text(json['episode_id']) ?? ''),
      seasonNumber: _int(json['season_number']),
      episodeNumber: _number(json['episode_number']),
      watchedCount: _int(json['watched_count']) ?? 0,
      completed: json['completed'] == true,
      lastWatchedAt: _date(json['last_watched_at']),
      rating: _int(json['rating']),
      notes: _text(json['notes']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _date(json['deleted_at']),
      rawPayload: Map<String, dynamic>.from(json),
    );
  }
}

final class TvCustomEpisode {
  const TvCustomEpisode({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.updatedAt,
    this.description,
    this.airDate,
    this.runtimeMinutes,
    this.stillImageUrl,
    this.localImagePath,
    this.thumbnailImageUrl,
    this.deletedAt,
  });

  final TvEpisodeId id;
  final TvSeriesId seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final String? description;
  final DateTime? airDate;
  final int? runtimeMinutes;
  final String? stillImageUrl;
  final String? localImagePath;
  final String? thumbnailImageUrl;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'series_id': seriesId.value,
        'season_number': seasonNumber,
        'episode_number': episodeNumber,
        'title': title,
        if (description != null) 'description': description,
        if (airDate != null) 'air_date': airDate!.toUtc().toIso8601String(),
        if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
        if (stillImageUrl != null) 'still_image_url': stillImageUrl,
        if (localImagePath != null) 'local_image_path': localImagePath,
        if (thumbnailImageUrl != null) 'thumbnail_image_url': thumbnailImageUrl,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        if (deletedAt != null)
          'deleted_at': deletedAt!.toUtc().toIso8601String(),
      };

  factory TvCustomEpisode.fromJson(Map<String, dynamic> json) {
    return TvCustomEpisode(
      id: TvEpisodeId(_text(json['id']) ?? ''),
      seriesId: TvSeriesId(_text(json['series_id']) ?? ''),
      seasonNumber: _int(json['season_number']) ?? 0,
      episodeNumber: _int(json['episode_number']) ?? 0,
      title: _text(json['title']) ?? 'Untitled episode',
      description: _text(json['description'] ?? json['overview']),
      airDate: _date(json['air_date']),
      runtimeMinutes: _int(json['runtime_minutes']),
      stillImageUrl: _text(json['still_image_url']),
      localImagePath: _text(json['local_image_path']),
      thumbnailImageUrl: _text(json['thumbnail_image_url']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: _date(json['deleted_at']),
    );
  }
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
