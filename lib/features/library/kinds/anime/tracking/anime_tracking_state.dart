import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
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
}

/// Kind-owned coordinate patch used by Anime edit/import flows.
final class AnimeTrackingCoordinatesPatch implements TrackingKindPatch {
  const AnimeTrackingCoordinatesPatch({
    this.seasonNumber,
    this.episodeNumber,
    this.episodeRatings,
    this.setSeasonNumber = false,
    this.setEpisodeNumber = false,
    this.setEpisodeRatings = false,
  });

  @override
  CatalogMediaKind get kind => CatalogMediaKind.anime;

  final int? seasonNumber;
  final double? episodeNumber;
  final Map<String, int>? episodeRatings;
  final bool setSeasonNumber;
  final bool setEpisodeNumber;
  final bool setEpisodeRatings;
}

/// An Anime tracking lifecycle entry with typed Anime-owned coordinates.
final class AnimeTrackingState extends PersonalTrackingBase
    with TrackingStorageRecordBehavior {
  AnimeTrackingState({
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

  final AnimeTrackingCoordinates coordinates;
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
  AnimeTrackingState copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingStorageUnset,
    Object? sourceType = trackingStorageUnset,
    Object? status = trackingStorageUnset,
    Object? rating = trackingStorageUnset,
    Object? startedAt = trackingStorageUnset,
    Object? finishedAt = trackingStorageUnset,
    Object? progressCurrent = trackingStorageUnset,
    Object? progressTotal = trackingStorageUnset,
    Object? timesCompleted = trackingStorageUnset,
    Object? notes = trackingStorageUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingStorageUnset,
  }) {
    return AnimeTrackingState(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      coordinates: coordinates,
      ownedRef: identical(ownedRef, trackingStorageUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingStorageUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingStorageUnset) ? this.status : status,
      rating: identical(rating, trackingStorageUnset)
          ? this.rating
          : rating as int?,
      startedAt: identical(startedAt, trackingStorageUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingStorageUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingStorageUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingStorageUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingStorageUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes: identical(notes, trackingStorageUnset)
          ? this.notes
          : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingStorageUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  AnimeTrackingState copyWithProgress(TrackingProgressSnapshot progress) {
    return copyWith(
      progressCurrent: progress.current,
      progressTotal: progress.total,
      timesCompleted: progress.timesCompleted,
    );
  }

  AnimeTrackingState copyWithCoordinates({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingStorageUnset,
    Object? sourceType = trackingStorageUnset,
    Object? status = trackingStorageUnset,
    Object? rating = trackingStorageUnset,
    Object? startedAt = trackingStorageUnset,
    Object? finishedAt = trackingStorageUnset,
    Object? progressCurrent = trackingStorageUnset,
    Object? progressTotal = trackingStorageUnset,
    Object? timesCompleted = trackingStorageUnset,
    Object? notes = trackingStorageUnset,
    Object? seasonNumber = trackingStorageUnset,
    Object? episodeNumber = trackingStorageUnset,
    Map<String, int>? episodeRatings,
    DateTime? updatedAt,
    Object? deletedAt = trackingStorageUnset,
  }) {
    return AnimeTrackingState(
      id: id ?? this.id,
      catalogRef: catalogRef ?? this.catalogRef,
      coordinates: AnimeTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingStorageUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingStorageUnset)
            ? coordinates.episodeNumber
            : (episodeNumber as num?)?.toDouble(),
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
      ownedRef: identical(ownedRef, trackingStorageUnset)
          ? this.ownedRef
          : ownedRef as OwnedItemRef?,
      sourceType: identical(sourceType, trackingStorageUnset)
          ? this.sourceType
          : sourceType,
      status: identical(status, trackingStorageUnset) ? this.status : status,
      rating: identical(rating, trackingStorageUnset)
          ? this.rating
          : rating as int?,
      startedAt: identical(startedAt, trackingStorageUnset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, trackingStorageUnset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      progressCurrent: identical(progressCurrent, trackingStorageUnset)
          ? this.progressCurrent
          : progressCurrent as int?,
      progressTotal: identical(progressTotal, trackingStorageUnset)
          ? this.progressTotal
          : progressTotal as int?,
      timesCompleted: identical(timesCompleted, trackingStorageUnset)
          ? this.timesCompleted
          : timesCompleted as int?,
      notes: identical(notes, trackingStorageUnset)
          ? this.notes
          : notes as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: identical(deletedAt, trackingStorageUnset)
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }
}

AnimeTrackingCoordinates animeTrackingCoordinatesFor(
    TrackingStorageRecord entry) {
  return switch (entry) {
    AnimeTrackingState typed => typed.coordinates,
    _ => throw StateError('Expected AnimeTrackingState record.'),
  };
}

AnimeTrackingState animeTrackingStateFor(TrackingStorageRecord entry) {
  return switch (entry) {
    AnimeTrackingState typed => typed,
    _ => throw StateError('Expected AnimeTrackingState record.'),
  };
}
