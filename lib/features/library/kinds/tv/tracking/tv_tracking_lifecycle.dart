import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
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

  factory TvTrackingCoordinates.fromLifecycle(TrackingLifecycle entry) {
    return entry is TvTrackingLifecycle
        ? entry.coordinates
        : TvTrackingCoordinates();
  }
}

/// A TV tracking lifecycle entry with typed TV-owned coordinates.
///
/// The class is assignable to the common [TrackingLifecycle] lifecycle contract,
/// while TV code reads episode data only through [coordinates].
final class TvTrackingLifecycle extends TrackingLifecycle {
  TvTrackingLifecycle({
    required super.id,
    required super.catalogRef,
    required this.coordinates,
    super.ownedRef,
    super.sourceType,
    super.status,
    super.rating,
    super.startedAt,
    super.finishedAt,
    this.progressCurrent,
    this.progressTotal,
    this.timesCompleted,
    super.notes,
    DateTime? updatedAt,
    super.deletedAt,
  }) : super(updatedAt: updatedAt ?? DateTime.now().toUtc());

  final TvTrackingCoordinates coordinates;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;

  @override
  TrackingProgressSnapshot get progress => TrackingProgressSnapshot(
        current: progressCurrent,
        total: progressTotal,
        timesCompleted: timesCompleted,
      );

  factory TvTrackingLifecycle.fromLifecycle(
    TrackingLifecycle entry, {
    TvTrackingCoordinates? coordinates,
    TrackingProgressSnapshot? progress,
  }) {
    final resolvedProgress = progress ?? entry.progress;
    return TvTrackingLifecycle(
      id: entry.id,
      catalogRef: entry.catalogRef,
      coordinates: coordinates ?? TvTrackingCoordinates.fromLifecycle(entry),
      ownedRef: entry.ownedRef,
      sourceType: entry.sourceType,
      status: entry.status,
      rating: entry.rating,
      startedAt: entry.startedAt,
      finishedAt: entry.finishedAt,
      progressCurrent: resolvedProgress.current,
      progressTotal: resolvedProgress.total,
      timesCompleted: resolvedProgress.timesCompleted,
      notes: entry.notes,
      updatedAt: entry.updatedAt,
      deletedAt: entry.deletedAt,
    );
  }

  @override
  TvTrackingLifecycle copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingLifecycleUnset,
    Object? sourceType = trackingLifecycleUnset,
    Object? status = trackingLifecycleUnset,
    Object? rating = trackingLifecycleUnset,
    Object? startedAt = trackingLifecycleUnset,
    Object? finishedAt = trackingLifecycleUnset,
    Object? progressCurrent = trackingLifecycleUnset,
    Object? progressTotal = trackingLifecycleUnset,
    Object? timesCompleted = trackingLifecycleUnset,
    Object? notes = trackingLifecycleUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingLifecycleUnset,
  }) {
    return TvTrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      coordinates: coordinates,
      ownedRef: identical(ownedRef, trackingLifecycleUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingLifecycleUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingLifecycleUnset) ? this.status : status,
      rating: identical(rating, trackingLifecycleUnset)
          ? this.rating
          : rating as int?,
      startedAt: identical(startedAt, trackingLifecycleUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingLifecycleUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingLifecycleUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingLifecycleUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingLifecycleUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes: identical(notes, trackingLifecycleUnset)
          ? this.notes
          : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingLifecycleUnset)
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
    Object? ownedRef = trackingLifecycleUnset,
    Object? sourceType = trackingLifecycleUnset,
    Object? status = trackingLifecycleUnset,
    Object? rating = trackingLifecycleUnset,
    Object? startedAt = trackingLifecycleUnset,
    Object? finishedAt = trackingLifecycleUnset,
    Object? progressCurrent = trackingLifecycleUnset,
    Object? progressTotal = trackingLifecycleUnset,
    Object? timesCompleted = trackingLifecycleUnset,
    Object? notes = trackingLifecycleUnset,
    Object? seasonNumber = trackingLifecycleUnset,
    Object? episodeNumber = trackingLifecycleUnset,
    Map<String, int>? episodeRatings,
    DateTime? updatedAt,
    Object? deletedAt = trackingLifecycleUnset,
  }) {
    return TvTrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      coordinates: TvTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingLifecycleUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingLifecycleUnset)
            ? coordinates.episodeNumber
            : episodeNumber as int?,
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
      ownedRef: identical(ownedRef, trackingLifecycleUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingLifecycleUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingLifecycleUnset) ? this.status : status,
      rating: identical(rating, trackingLifecycleUnset)
          ? this.rating
          : rating as int?,
      startedAt: identical(startedAt, trackingLifecycleUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingLifecycleUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingLifecycleUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingLifecycleUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingLifecycleUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes: identical(notes, trackingLifecycleUnset)
          ? this.notes
          : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingLifecycleUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

TvTrackingCoordinates tvTrackingCoordinatesFor(TrackingLifecycle entry) {
  return entry is TvTrackingLifecycle
      ? entry.coordinates
      : TvTrackingCoordinates.fromLifecycle(entry);
}

TvTrackingLifecycle tvTrackingLifecycleFor(TrackingLifecycle entry) {
  return entry is TvTrackingLifecycle
      ? entry
      : TvTrackingLifecycle.fromLifecycle(entry);
}
