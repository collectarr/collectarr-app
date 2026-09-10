import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';

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

  factory AnimeTrackingCoordinates.fromEntry(TrackingLifecycle entry) {
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
    super.progressCurrent,
    super.progressTotal,
    super.timesCompleted,
    super.notes,
    DateTime? updatedAt,
    super.deletedAt,
  }) : super(updatedAt: updatedAt ?? DateTime.now().toUtc());

  final AnimeTrackingCoordinates coordinates;

  factory AnimeTrackingLifecycle.fromEntry(
    TrackingLifecycle entry, {
    AnimeTrackingCoordinates? coordinates,
  }) {
    return AnimeTrackingLifecycle(
      id: entry.id,
      catalogRef: entry.catalogRef,
      coordinates: coordinates ?? AnimeTrackingCoordinates.fromEntry(entry),
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
    return AnimeTrackingLifecycle.fromEntry(copied, coordinates: coordinates);
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
    return AnimeTrackingLifecycle.fromEntry(
      copied,
      coordinates: AnimeTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingLifecycleUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingLifecycleUnset)
            ? coordinates.episodeNumber
            : (episodeNumber as num?)?.toDouble(),
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
    );
  }
}

AnimeTrackingCoordinates animeTrackingCoordinatesFor(TrackingLifecycle entry) {
  return entry is AnimeTrackingLifecycle
      ? entry.coordinates
      : AnimeTrackingCoordinates.fromEntry(entry);
}

AnimeTrackingLifecycle animeTrackingEntryFor(TrackingLifecycle entry) {
  return entry is AnimeTrackingLifecycle
      ? entry
      : AnimeTrackingLifecycle.fromEntry(entry);
}
