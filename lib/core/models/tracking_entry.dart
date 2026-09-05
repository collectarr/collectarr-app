import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';

const Object _trackingUnset = Object();

class TrackingEntry extends PersonalTrackingBase {
  TrackingEntry({
    required this.id,
    required this.catalogRef,
    this.ownedItemId,
    this.editionId,
    this.variantId,
    this.bundleReleaseId,
    Object? sourceType,
    Object? status,
    int? rating,
    DateTime? startedAt,
    DateTime? finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    String? notes,
    this.seasonNumber,
    this.episodeNumber,
    Map<String, int>? episodeRatings,
    required this.updatedAt,
    this.deletedAt,
  })  : sourceType = trackingSourceTypeFromValue(sourceType),
        episodeRatings = episodeRatings ?? const {},
        super(
          status: status,
          rating: rating,
          startedAt: startedAt,
          completedAt: finishedAt,
          notes: notes,
        );

  final String id;
  final CatalogEntityRef catalogRef;
  final String? ownedItemId;
  final String? editionId;
  final String? variantId;
  final String? bundleReleaseId;
  final TrackingSourceType? sourceType;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;
  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, int> episodeRatings;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DateTime? get finishedAt => completedAt;

  String get itemId => catalogRef.id;

  TrackingSourceType? get trackingSource => sourceType;

  String? get sourceTypeApiValue => sourceType?.apiValue;

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
    Object? ownedItemId = _trackingUnset,
    Object? editionId = _trackingUnset,
    Object? variantId = _trackingUnset,
    Object? bundleReleaseId = _trackingUnset,
    Object? sourceType = _trackingUnset,
    Object? status = _trackingUnset,
    Object? rating = _trackingUnset,
    Object? startedAt = _trackingUnset,
    Object? finishedAt = _trackingUnset,
    Object? progressCurrent = _trackingUnset,
    Object? progressTotal = _trackingUnset,
    Object? timesCompleted = _trackingUnset,
    Object? notes = _trackingUnset,
    Object? seasonNumber = _trackingUnset,
    Object? episodeNumber = _trackingUnset,
    Map<String, int>? episodeRatings,
    DateTime? updatedAt,
    Object? deletedAt = _trackingUnset,
  }) {
    return TrackingEntry(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      ownedItemId: identical(ownedItemId, _trackingUnset)
          ? this.ownedItemId
          : ownedItemId as String?,
      editionId: identical(editionId, _trackingUnset)
          ? this.editionId
          : editionId as String?,
      variantId: identical(variantId, _trackingUnset)
          ? this.variantId
          : variantId as String?,
      bundleReleaseId: identical(bundleReleaseId, _trackingUnset)
          ? this.bundleReleaseId
          : bundleReleaseId as String?,
      sourceType: identical(sourceType, _trackingUnset)
          ? this.sourceType
          : trackingSourceTypeFromValue(sourceType),
      status: identical(status, _trackingUnset)
          ? this.status
          : mediaTrackingStatusFromValue(status),
      rating: identical(rating, _trackingUnset) ? this.rating : rating as int?,
      startedAt: identical(startedAt, _trackingUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, _trackingUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, _trackingUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, _trackingUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, _trackingUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes: identical(notes, _trackingUnset) ? this.notes : notes as String?,
      seasonNumber: identical(seasonNumber, _trackingUnset)
          ? this.seasonNumber
          : seasonNumber as int?,
      episodeNumber: identical(episodeNumber, _trackingUnset)
          ? this.episodeNumber
          : episodeNumber as int?,
      episodeRatings: episodeRatings ?? this.episodeRatings,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, _trackingUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
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
