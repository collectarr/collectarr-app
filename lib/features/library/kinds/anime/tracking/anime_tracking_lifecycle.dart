import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';

/// Anime-owned hierarchy coordinates for a tracking entry.
///
/// Anime episodes may use fractional episode numbers, so this typed model
/// deliberately does not narrow them to the common entry's integer fallback.
final class AnimeTrackingCoordinates {
  AnimeTrackingCoordinates({
    this.seasonNumber,
    this.episodeNumber,
    Map<String, int>? episodeRatings,
  }) : episodeRatings = Map.unmodifiable(episodeRatings ?? const {});

  final int? seasonNumber;
  final double? episodeNumber;
  final Map<String, int> episodeRatings;

  bool get hasEpisodeCoordinates =>
      seasonNumber != null || episodeNumber != null;

  factory AnimeTrackingCoordinates.fromLifecycle(TrackingLifecycle entry) {
    return entry is AnimeTrackingLifecycle
        ? entry.coordinates
        : AnimeTrackingCoordinates();
  }
}

/// An Anime tracking lifecycle entry with typed Anime-owned coordinates.
final class AnimeTrackingLifecycle extends TrackingLifecycle {
  AnimeTrackingLifecycle({
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

  final AnimeTrackingCoordinates coordinates;
  final int? progressCurrent;
  final int? progressTotal;
  final int? timesCompleted;

  @override
  TrackingProgressSnapshot get progress => TrackingProgressSnapshot(
        current: progressCurrent,
        total: progressTotal,
        timesCompleted: timesCompleted,
      );

  factory AnimeTrackingLifecycle.fromLifecycle(
    TrackingLifecycle entry, {
    AnimeTrackingCoordinates? coordinates,
    TrackingProgressSnapshot? progress,
  }) {
    final resolvedProgress = progress ?? entry.progress;
    return AnimeTrackingLifecycle(
      id: entry.id,
      catalogRef: entry.catalogRef,
      coordinates: coordinates ?? AnimeTrackingCoordinates.fromLifecycle(entry),
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
  AnimeTrackingLifecycle copyWith({
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
    return AnimeTrackingLifecycle(
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
  AnimeTrackingLifecycle copyWithProgress(TrackingProgressSnapshot progress) {
    return copyWith(
      progressCurrent: progress.current,
      progressTotal: progress.total,
      timesCompleted: progress.timesCompleted,
    );
  }

  AnimeTrackingLifecycle copyWithCoordinates({
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
    return AnimeTrackingLifecycle(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      coordinates: AnimeTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingLifecycleUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingLifecycleUnset)
            ? coordinates.episodeNumber
            : (episodeNumber as num?)?.toDouble(),
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

AnimeTrackingCoordinates animeTrackingCoordinatesFor(TrackingLifecycle entry) {
  return entry is AnimeTrackingLifecycle
      ? entry.coordinates
      : AnimeTrackingCoordinates.fromLifecycle(entry);
}

AnimeTrackingLifecycle animeTrackingLifecycleFor(TrackingLifecycle entry) {
  return entry is AnimeTrackingLifecycle
      ? entry
      : AnimeTrackingLifecycle.fromLifecycle(entry);
}
