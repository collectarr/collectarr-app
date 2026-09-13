import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

/// Anime-owned watch history session.
///
/// Episode coordinates are intentionally absent from the shared watch model.
/// Anime owns their interpretation and persistence here, alongside its codec.
final class AnimeWatchSession extends WatchSession {
  AnimeWatchSession({
    required super.id,
    required super.targetRef,
    required super.watchedAt,
    required super.updatedAt,
    this.seasonNumber,
    this.episodeNumber,
    super.trackingEntryId,
    super.sourceType,
    super.seenWhere,
    super.rating,
    super.notes,
    super.deletedAt,
  });

  final int? seasonNumber;
  final int? episodeNumber;

  @override
  AnimeWatchSession copyWith({
    String? id,
    CatalogEntityRef? targetRef,
    String? trackingEntryId,
    Object? sourceType,
    String? seenWhere,
    DateTime? watchedAt,
    int? rating,
    String? notes,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AnimeWatchSession(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      watchedAt: watchedAt ?? this.watchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      sourceType: sourceType ?? this.sourceType,
      seenWhere: seenWhere ?? this.seenWhere,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
