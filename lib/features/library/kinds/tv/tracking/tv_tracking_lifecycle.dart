import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';

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
    super.progressCurrent,
    super.progressTotal,
    super.timesCompleted,
    super.notes,
    DateTime? updatedAt,
    super.deletedAt,
  }) : super(updatedAt: updatedAt ?? DateTime.now().toUtc());

  final TvTrackingCoordinates coordinates;

  factory TvTrackingLifecycle.fromLifecycle(
    TrackingLifecycle entry, {
    TvTrackingCoordinates? coordinates,
  }) {
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
      progressCurrent: entry.progressCurrent,
      progressTotal: entry.progressTotal,
      timesCompleted: entry.timesCompleted,
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
    final copied = super.copyWith(
      id: id,
      catalogRef: catalogRef,
      ownedRef: ownedRef,
      sourceType: sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: notes,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
    return TvTrackingLifecycle.fromLifecycle(copied, coordinates: coordinates);
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
    final copied = super.copyWith(
      id: id,
      catalogRef: catalogRef,
      ownedRef: ownedRef,
      sourceType: sourceType,
      status: status,
      rating: rating,
      startedAt: startedAt,
      finishedAt: finishedAt,
      progressCurrent: progressCurrent,
      progressTotal: progressTotal,
      timesCompleted: timesCompleted,
      notes: notes,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
    return TvTrackingLifecycle.fromLifecycle(
      copied,
      coordinates: TvTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingLifecycleUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingLifecycleUnset)
            ? coordinates.episodeNumber
            : episodeNumber as int?,
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
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
