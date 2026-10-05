import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/personal_tracking_base.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_record.dart';
import 'package:collectarr_app/core/models/tracking_progress_snapshot.dart';

/// TV-entry hierarchy coordinates for a tracking entry.
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

/// Kind-entry coordinate patch used by TV edit/import flows.
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

/// A TV tracking lifecycle entry with typed TV-entry coordinates.
final class TvTrackingState extends PersonalTrackingBase
    with TrackingStorageRecordBehavior {
  TvTrackingState({
    required this.id,
    required this.coordinates,
    required this.libraryEntryRef,
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
  final LibraryEntryRef libraryEntryRef;
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
  TvTrackingState copyWith({
    String? id,
    Object? libraryEntryRef = trackingStorageUnset,
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
    return TvTrackingState(
      id: id ?? this.id,
      coordinates: coordinates,
      libraryEntryRef: identical(libraryEntryRef, trackingStorageUnset)
          ? this.libraryEntryRef
          : libraryEntryRef as LibraryEntryRef,
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
  TvTrackingState copyWithProgress(TrackingProgressSnapshot progress) {
    return copyWith(
      progressCurrent: progress.current,
      progressTotal: progress.total,
      timesCompleted: progress.timesCompleted,
    );
  }

  TvTrackingState copyWithCoordinates({
    String? id,
    Object? libraryEntryRef = trackingStorageUnset,
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
    return TvTrackingState(
      id: id ?? this.id,
      coordinates: TvTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingStorageUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingStorageUnset)
            ? coordinates.episodeNumber
            : episodeNumber as int?,
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
      libraryEntryRef: identical(libraryEntryRef, trackingStorageUnset)
          ? this.libraryEntryRef
          : libraryEntryRef as LibraryEntryRef,
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

TvTrackingCoordinates tvTrackingCoordinatesFor(TrackingStorageRecord entry) {
  return switch (entry) {
    TvTrackingState typed => typed.coordinates,
    _ => throw StateError('Expected TvTrackingState record.'),
  };
}

TvTrackingState tvTrackingStateFor(TrackingStorageRecord entry) {
  return switch (entry) {
    TvTrackingState typed => typed,
    _ => throw StateError('Expected TvTrackingState record.'),
  };
}
