import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

class TrackingEntry {
  TrackingEntry({
    required this.id,
    required this.catalogRef,
    this.ownedItemId,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
    Object? sourceType,
    Object? status,
    this.rating,
    this.startedAt,
    this.finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    this.notes,
    this.seasonNumber,
    this.episodeNumber,
    Map<String, int>? episodeRatings,
    required this.updatedAt,
    this.deletedAt,
  })  : sourceType = trackingSourceTypeFromValue(sourceType),
        status = mediaTrackingStatusFromValue(status),
        episodeRatings = episodeRatings ?? const {};

  final String id;
  final CatalogEntityRef catalogRef;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final TrackingSourceType? sourceType;
  final MediaTrackingStatus? status;
  final int? rating;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final String? notes;
  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, int> episodeRatings;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  String get itemId => catalogRef.id;

  TrackingSourceType? get trackingSource => sourceType;

  String? get sourceTypeApiValue => sourceType?.apiValue;

  String? get statusStorageValue => mediaTrackingStatusToStorageValue(status);

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toSyncPayload() {
    return {
      'catalog_ref': catalogRef.toJson(),
      'owned_item_id': ownedItemId,
      'edition_id': editionId,
      'variant_id': variantId,
      'bundle_release_id': bundleReleaseId,
      'source_type': sourceTypeApiValue,
      'status': statusStorageValue,
      'rating': rating,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'finished_at': finishedAt?.toUtc().toIso8601String(),
      'progress_current': progressCurrent,
      'progress_total': progressTotal,
      'times_completed': timesCompleted,
      'notes': notes,
      'season_number': seasonNumber,
      'episode_number': episodeNumber,
      if (episodeRatings.isNotEmpty) 'episode_ratings': episodeRatings,
    };
  }

  factory TrackingEntry.fromJson(Map<String, dynamic> json) {
    final catalogRefJson = json['catalog_ref'] as Map<String, dynamic>;
    return TrackingEntry(
      id: json['id'] as String,
      catalogRef: CatalogEntityRef.fromJson(catalogRefJson),
      ownedItemId: json['owned_item_id'] as String?,
      editionId: json['edition_id'] as String?,
      variantId: json['variant_id'] as String?,
      bundleReleaseId: json['bundle_release_id'] as String?,
      sourceType: json['source_type'] as String?,
      status: json['status'] as String?,
      rating: json['rating'] as int?,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
      progressCurrent: json['progress_current'] as int?,
      progressTotal: json['progress_total'] as int?,
      timesCompleted: json['times_completed'] as int?,
      notes: json['notes'] as String?,
      seasonNumber: json['season_number'] as int?,
      episodeNumber: json['episode_number'] as int?,
      episodeRatings: _parseEpisodeRatings(json['episode_ratings']),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  TrackingEntry copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    String? ownedItemId,
    String? editionId,
    String? variantId,
    String? bundleReleaseId,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? progressCurrent,
    int? progressTotal,
    int? timesCompleted,
    String? notes,
    int? seasonNumber,
    int? episodeNumber,
    Map<String, int>? episodeRatings,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TrackingEntry(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedItemId: ownedItemId ?? this.ownedItemId,
      editionId: editionId ?? this.editionId,
      variantId: variantId ?? this.variantId,
      bundleReleaseId: bundleReleaseId ?? this.bundleReleaseId,
      sourceType: trackingSourceTypeFromValue(sourceType) ?? this.sourceType,
      status: mediaTrackingStatusFromValue(status) ?? this.status,
      rating: rating ?? this.rating,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      progressCurrent: progressCurrent ?? this.progressCurrent,
      progressTotal: progressTotal ?? this.progressTotal,
      timesCompleted: timesCompleted ?? this.timesCompleted,
      notes: notes ?? this.notes,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      episodeRatings: episodeRatings ?? this.episodeRatings,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

Map<String, int> _parseEpisodeRatings(Object? raw) {
  if (raw is Map) {
    return {
      for (final entry in raw.entries)
        if (entry.key is String && entry.value is int)
          entry.key as String: entry.value as int
        else if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toInt(),
    };
  }
  return const {};
}
