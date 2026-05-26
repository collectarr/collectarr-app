import 'package:collectarr_app/core/models/tracking_source.dart';

class WatchSession {
  WatchSession({
    required this.id,
    required this.itemId,
    required this.watchedAt,
    required this.updatedAt,
    this.trackingEntryId,
    this.seasonNumber,
    this.episodeNumber,
    Object? sourceType,
    this.rating,
    this.notes,
    this.deletedAt,
  }) : sourceType = sourceType is TrackingSourceType?
            ? sourceType
            : trackingSourceTypeFromValue(sourceType);

  final String id;
  final String itemId;
  final String? trackingEntryId;
  final int? seasonNumber;
  final int? episodeNumber;
  final TrackingSourceType? sourceType;
  final DateTime watchedAt;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  bool get isEpisodeSession => seasonNumber != null && episodeNumber != null;

  String? get sourceTypeApiValue => sourceType?.apiValue;

  Map<String, dynamic> toSyncPayload() {
    return {
      'item_id': itemId,
      'tracking_entry_id': trackingEntryId,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'source_type': sourceTypeApiValue,
      'watched_at': watchedAt.toUtc().toIso8601String(),
      'rating': rating,
      'notes': notes,
    };
  }

  factory WatchSession.fromJson(Map<String, dynamic> json) {
    return WatchSession(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      trackingEntryId: json['tracking_entry_id'] as String?,
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      sourceType: json['source_type'] as String?,
      watchedAt: DateTime.parse(json['watched_at'] as String),
      rating: json['rating'] as int?,
      notes: json['notes'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  WatchSession copyWith({
    String? id,
    String? itemId,
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
    Object? sourceType,
    DateTime? watchedAt,
    int? rating,
    String? notes,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WatchSession(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      sourceType: sourceType ?? this.sourceType,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
