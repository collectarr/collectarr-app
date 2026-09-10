import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';

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

  factory TvTrackingCoordinates.fromEntry(TrackingEntry entry) {
    return entry is TvTrackingEntry
        ? entry.coordinates
        : TvTrackingCoordinates();
  }
}

/// A TV tracking lifecycle entry with typed TV-owned coordinates.
///
/// The class is assignable to the common [TrackingEntry] lifecycle contract,
/// while TV code reads episode data only through [coordinates].
final class TvTrackingEntry extends TrackingEntry {
  TvTrackingEntry({
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

  factory TvTrackingEntry.fromEntry(
    TrackingEntry entry, {
    TvTrackingCoordinates? coordinates,
  }) {
    return TvTrackingEntry(
      id: entry.id,
      catalogRef: entry.catalogRef,
      coordinates: coordinates ?? TvTrackingCoordinates.fromEntry(entry),
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
  TvTrackingEntry copyWith({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingEntryUnset,
    Object? sourceType = trackingEntryUnset,
    Object? status = trackingEntryUnset,
    Object? rating = trackingEntryUnset,
    Object? startedAt = trackingEntryUnset,
    Object? finishedAt = trackingEntryUnset,
    Object? progressCurrent = trackingEntryUnset,
    Object? progressTotal = trackingEntryUnset,
    Object? timesCompleted = trackingEntryUnset,
    Object? notes = trackingEntryUnset,
    DateTime? updatedAt,
    Object? deletedAt = trackingEntryUnset,
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
    return TvTrackingEntry.fromEntry(copied, coordinates: coordinates);
  }

  TvTrackingEntry copyWithCoordinates({
    String? id,
    CatalogEntityRef? catalogRef,
    Object? ownedRef = trackingEntryUnset,
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
    return TvTrackingEntry.fromEntry(
      copied,
      coordinates: TvTrackingCoordinates(
        seasonNumber: identical(seasonNumber, trackingEntryUnset)
            ? coordinates.seasonNumber
            : seasonNumber as int?,
        episodeNumber: identical(episodeNumber, trackingEntryUnset)
            ? coordinates.episodeNumber
            : episodeNumber as int?,
        episodeRatings: episodeRatings ?? coordinates.episodeRatings,
      ),
    );
  }
}

TvTrackingCoordinates tvTrackingCoordinatesFor(TrackingEntry entry) {
  return entry is TvTrackingEntry
      ? entry.coordinates
      : TvTrackingCoordinates.fromEntry(entry);
}

TvTrackingEntry tvTrackingEntryFor(TrackingEntry entry) {
  return entry is TvTrackingEntry ? entry : TvTrackingEntry.fromEntry(entry);
}
