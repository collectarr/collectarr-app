import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';

/// TV-owned hierarchy coordinates for a tracking entry.
///
/// This is the typed home for TV season/episode data.
final class TvTrackingCoordinates {
  TvTrackingCoordinates({
    this.seasonNumber,
    this.episodeNumber,
    Map<String, int>? episodeRatings,
  }) : episodeRatings = Map.unmodifiable(episodeRatings ?? const {});

  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, int> episodeRatings;

  bool get hasEpisodeCoordinates =>
      seasonNumber != null || episodeNumber != null;
}

/// Kind-owned coordinate patch used by TV edit/import flows.
final class TvTrackingCoordinatesPatch implements TrackingKindPatch {
  const TvTrackingCoordinatesPatch({
    this.seasonNumber,
    this.episodeNumber,
    this.episodeRatings,
    this.setSeasonNumber = false,
    this.setEpisodeNumber = false,
    this.setEpisodeRatings = false,
  });

  @override
  CatalogMediaKind get kind => CatalogMediaKind.tv;

  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, int>? episodeRatings;
  final bool setSeasonNumber;
  final bool setEpisodeNumber;
  final bool setEpisodeRatings;
}

/// A TV tracking lifecycle entry with typed TV-owned coordinates.
final class TvTrackingLifecycle extends PersonalTrackingBase
    with TrackingLifecycleBehavior {
  TvTrackingLifecycle({
    required this.id,
    required this.catalogRef,
    required this.coordinates,
    this.ownedRef,
    Object? sourceType,
    super.status,
    super.rating,
    super.startedAt,
    DateTime? finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    super.notes,
    DateTime? updatedAt,
    this.deletedAt,
  })  : sourceType = trackingSourceTypeFromValue(sourceType),
        updatedAt = updatedAt ?? DateTime.now().toUtc(),
        super(completedAt: finishedAt);

  final TvTrackingCoordinates coordinates;
  @override
  final String id;
  @override
  final CatalogEntityRef catalogRef;
  @override
  final OwnedItemRef? ownedRef;
  @override
  final TrackingSourceType? sourceType;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;

  @override
  TrackingProgressSnapshot get progress => TrackingProgressSnapshot(
        current: progressCurrent,
        total: progressTotal,
        timesCompleted: timesCompleted,
      );

  @override
  TvTrackingLifecycle copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingRecordUnset,
    Object? sourceType = trackingRecordUnset,
    Object? status = trackingRecordUnset,
    Object? rating = trackingRecordUnset,
    Object? startedAt = trackingRecordUnset,
    Object? finishedAt = trackingRecordUnset,
    Object? progressCurrent = trackingRecordUnset,
    Object? progressTotal = trackingRecordUnset,
    Object? timesCompleted = trackingRecordUnset,
    Object? notes = trackingRecordUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingRecordUnset,
  }) {
    return TvTrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      coordinates: coordinates,
      ownedRef: identical(ownedRef, trackingRecordUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingRecordUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingRecordUnset) ? this.status : status,
      rating:
          identical(rating, trackingRecordUnset) ? this.rating : rating as int?,
      startedAt: identical(startedAt, trackingRecordUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingRecordUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingRecordUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingRecordUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingRecordUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes:
          identical(notes, trackingRecordUnset) ? this.notes : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingRecordUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  TvTrackingLifecycle copyWithProgress(TrackingProgressSnapshot progress) {
    return copyWith(
      progressCurrent: progress.current,
      progressTotal: progress.total,
      timesCompleted: progress.timesCompleted,
    );
  }

  TvTrackingLifecycle copyWithCoordinates({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingRecordUnset,
    Object? sourceType = trackingRecordUnset,
    Object? status = trackingRecordUnset,
    Object? rating = trackingRecordUnset,
    Object? startedAt = trackingRecordUnset,
    Object? finishedAt = trackingRecordUnset,
    Object? progressCurrent = trackingRecordUnset,
    Object? progressTotal = trackingRecordUnset,
    Object? timesCompleted = trackingRecordUnset,
    Object? notes = trackingRecordUnset,
    Object? seasonNumber = trackingRecordUnset,
    Object? episodeNumber = trackingRecordUnset,
    Map<String, int>? episodeRatings,
    DateTime? updatedAt,
    Object? deletedAt = trackingRecordUnset,
  }) {
    return TvTrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      coordinates: TvTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingRecordUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingRecordUnset)
            ? coordinates.episodeNumber
            : episodeNumber as int?,
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
      ownedRef: identical(ownedRef, trackingRecordUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingRecordUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingRecordUnset) ? this.status : status,
      rating:
          identical(rating, trackingRecordUnset) ? this.rating : rating as int?,
      startedAt: identical(startedAt, trackingRecordUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingRecordUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingRecordUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingRecordUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingRecordUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes:
          identical(notes, trackingRecordUnset) ? this.notes : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingRecordUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

TvTrackingCoordinates tvTrackingCoordinatesFor(TrackingStorageRecord entry) {
  return switch (entry) {
    TvTrackingLifecycle typed => typed.coordinates,
    _ => throw StateError('Expected TvTrackingLifecycle record.'),
  };
}

TvTrackingLifecycle tvTrackingLifecycleFor(TrackingStorageRecord entry) {
  return switch (entry) {
    TvTrackingLifecycle typed => typed,
    _ => throw StateError('Expected TvTrackingLifecycle record.'),
  };
}
