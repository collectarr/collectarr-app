import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

/// Anime-entry watch history session.
///
/// Episode coordinates are intentionally absent from the shared watch model.
/// Anime owns their interpretation and persistence here, alongside its codec.
final class AnimeWatchSession extends WatchSession {
  AnimeWatchSession({
    required super.id,
    required super.libraryEntryRef,
    required super.watchedAt,
    required super.updatedAt,
    super.seasonNumber,
    super.episodeNumber,
    super.trackingEntryId,
    super.sourceType,
    super.seenWhere,
    super.rating,
    super.notes,
    super.deletedAt,
  });

  @override
  AnimeWatchSession copyWith({
    String? id,
    LibraryEntryRef? libraryEntryRef,
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
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
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      watchedAt: watchedAt ?? this.watchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      sourceType: sourceType ?? this.sourceType,
      seenWhere: seenWhere ?? this.seenWhere,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
