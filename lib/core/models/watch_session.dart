import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';

class WatchSession {
  WatchSession({
    required this.id,
    required this.targetRef,
    required this.watchedAt,
    required this.updatedAt,
    this.trackingEntryId,
    this.seasonNumber,
    this.episodeNumber,
    Object? sourceType,
    this.seenWhere,
    this.rating,
    this.notes,
    this.deletedAt,
  }) : sourceType = sourceType is TrackingSourceType?
            ? sourceType
            : trackingSourceTypeFromValue(sourceType);

  final String id;
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

  String get itemId => targetRef.id;

  bool get isDeleted => deletedAt != null;

  bool get isEpisodeSession => seasonNumber != null && episodeNumber != null;

  String? get sourceTypeApiValue => sourceType?.apiValue;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': targetRef.toJson(),
      'tracking_entry_id': trackingEntryId,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      'source_type': sourceTypeApiValue,
      'watched_at': watchedAt.toUtc().toIso8601String(),
      'seen_where': seenWhere,
      'rating': rating,
      'notes': notes,
    };
  }

  factory WatchSession.fromJson(Map<String, dynamic> json) {
    final targetRefJson = json['target_ref'] ?? json['catalog_ref'];
    // Legacy read fallback only; writes now always use catalog_ref.
    final fallbackItemId = json['item_id'] as String? ?? '';
    return WatchSession(
      id: json['id'] as String,
      targetRef: targetRefJson is Map<String, dynamic>
          ? CatalogEntityRef.fromJson(targetRefJson)
          : CatalogEntityRef(
              kind: 'unknown',
              entityType: CatalogEntityType.work,
              id: fallbackItemId,
            ),
      trackingEntryId: json['tracking_entry_id'] as String?,
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      sourceType: json['source_type'] as String?,
      seenWhere: json['seen_where'] as String?,
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
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
    Object? sourceType,
    String? seenWhere,
    DateTime? watchedAt,
    int? rating,
    String? notes,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WatchSession(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      sourceType: sourceType ?? this.sourceType,
      seenWhere: seenWhere ?? this.seenWhere,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
