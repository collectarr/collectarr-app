import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:flutter/foundation.dart';

import 'music_ids.dart';

/// Music-specific tracking state, including album/media/track scope.
@immutable
final class MusicTracking {
  const MusicTracking({
    required this.releaseId,
    this.id,
    this.mediaId,
    this.trackId,
    this.status = '',
    this.sourceType,
    this.rating,
    this.notes,
    this.startedAt,
    this.finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted = 0,
    this.playCount = 0,
    this.lastListenedAt,
    this.updatedAt,
    this.deletedAt,
  });

  final MusicReleaseId releaseId;
  final String? id;
  final MusicMediaId? mediaId;
  final MusicTrackId? trackId;
  final String status;
  final TrackingSourceType? sourceType;
  final int? rating;
  final String? notes;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int timesCompleted;
  final int playCount;
  final DateTime? lastListenedAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'release_id': releaseId.value,
        if (mediaId != null) 'media_id': mediaId!.value,
        if (trackId != null) 'track_id': trackId!.value,
        'status': status,
        if (sourceType != null) 'source_type': sourceType!.apiValue,
        if (rating != null) 'rating': rating,
        if (notes != null) 'notes': notes,
        if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
        if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
        if (progressCurrent != null) 'progress_current': progressCurrent,
        if (progressTotal != null) 'progress_total': progressTotal,
        'times_completed': timesCompleted,
        'play_count': playCount,
        if (lastListenedAt != null)
          'last_listened_at': lastListenedAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };

  factory MusicTracking.fromJson(Map<String, dynamic> json) {
    return MusicTracking(
      releaseId: MusicReleaseId(
        _text(json['release_id'] ?? json['item_id']) ?? '',
      ),
      id: _text(json['id']),
      mediaId: _id<MusicMediaId>(json['media_id'], MusicMediaId.new),
      trackId: _id<MusicTrackId>(json['track_id'], MusicTrackId.new),
      status: _text(json['status']) ?? '',
      sourceType: trackingSourceTypeFromValue(json['source_type']),
      rating: _int(json['rating']),
      notes: _text(json['notes']),
      startedAt: _date(json['started_at']),
      finishedAt: _date(json['finished_at']),
      progressCurrent: _int(json['progress_current']),
      progressTotal: _int(json['progress_total']),
      timesCompleted: _int(json['times_completed']) ?? 0,
      playCount: _int(json['play_count'] ?? json['listen_count']) ?? 0,
      lastListenedAt: _date(json['last_listened_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _date(json['deleted_at']),
    );
  }
}

T? _id<T>(Object? value, T Function(String) builder) {
  final text = _text(value);
  return text == null ? null : builder(text);
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

DateTime? _date(Object? value) =>
    DateTime.tryParse(value?.toString().trim() ?? '');
