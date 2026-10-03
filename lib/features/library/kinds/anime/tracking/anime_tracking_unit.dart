import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';

/// Anime-entry season/episode progress unit.
final class AnimeTrackingUnit extends TrackingUnitSummary {
  const AnimeTrackingUnit({
    required super.id,
    required super.libraryEntryRef,
    required super.completedAt,
    required super.updatedAt,
    this.seasonNumber,
    this.episodeNumber,
    super.trackingEntryId,
    super.deletedAt,
  });

  static const type = 'episode';

  final int? seasonNumber;
  final int? episodeNumber;

  @override
  Map<String, dynamic> toSyncPayload() {
    return super.toSyncPayload()
      ..addAll({
        'unit_type': type,
        'season_number': seasonNumber,
        'episode_number': episodeNumber,
      });
  }

  @override
  AnimeTrackingUnit copyWith({
    String? id,
    String? trackingEntryId,
    LibraryEntryRef? libraryEntryRef,
    DateTime? completedAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AnimeTrackingUnit(
      id: id ?? this.id,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
