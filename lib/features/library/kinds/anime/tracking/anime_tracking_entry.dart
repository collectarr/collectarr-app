import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';

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

  factory AnimeTrackingCoordinates.fromLegacy(TrackingEntry entry) {
    return entry is AnimeTrackingEntry
        ? entry.coordinates
        : AnimeTrackingCoordinates();
  }
}

/// An Anime tracking lifecycle entry with typed Anime-owned coordinates.
final class AnimeTrackingEntry extends TrackingEntry {
  AnimeTrackingEntry({
    required super.id,
    required super.catalogRef,
    required this.coordinates,
    super.ownedItemId,
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

  factory AnimeTrackingEntry.fromEntry(
    TrackingEntry entry, {
    AnimeTrackingCoordinates? coordinates,
  }) {
    return AnimeTrackingEntry(
      id: entry.id,
      catalogRef: entry.catalogRef,
      coordinates: coordinates ?? AnimeTrackingCoordinates.fromLegacy(entry),
      ownedItemId: entry.ownedItemId,
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
  AnimeTrackingEntry copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedItemId = trackingEntryUnset,
    Object? sourceType = trackingEntryUnset,
    Object? status = trackingEntryUnset,
    Object? rating = trackingEntryUnset,
    Object? startedAt = trackingEntryUnset,
    Object? finishedAt = trackingEntryUnset,
    Object? progressCurrent = trackingEntryUnset,
    Object? progressTotal = trackingEntryUnset,
    Object? timesCompleted = trackingEntryUnset,
    Object? notes = trackingEntryUnset,
    Object? seasonNumber = trackingEntryUnset,
    Object? episodeNumber = trackingEntryUnset,
    Map<String, int>? episodeRatings,
    DateTime? updatedAt,
    Object? deletedAt = trackingEntryUnset,
  }) {
    final copied = super.copyWith(
      id: id,
      catalogRef: catalogRef,
      ownedItemId: ownedItemId,
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
    return AnimeTrackingEntry.fromEntry(
      copied,
      coordinates: AnimeTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingEntryUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingEntryUnset)
            ? coordinates.episodeNumber
            : (episodeNumber as num?)?.toDouble(),
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
    );
  }
}

AnimeTrackingCoordinates animeTrackingCoordinatesFor(TrackingEntry entry) {
  return entry is AnimeTrackingEntry
      ? entry.coordinates
      : AnimeTrackingCoordinates.fromLegacy(entry);
}

AnimeTrackingEntry animeTrackingEntryFor(TrackingEntry entry) {
  return entry is AnimeTrackingEntry
      ? entry
      : AnimeTrackingEntry.fromEntry(entry);
}
