import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';

class WatchSession {
  WatchSession({
    required this.id,
    required this.libraryEntryRef,
    required this.watchedAt,
    required this.updatedAt,
    this.trackingEntryId,
    this.seasonNumber,
    this.episodeNumber,
    Object? sourceType,
    this.seenWhere,
    this.rating,
    this.notes,
    this.deletedAt,
  }) : sourceType = sourceType is TrackingSourceType?
            ? sourceType
            : trackingSourceTypeFromValue(sourceType);

  final String id;

  /// The local library entry that owns this activity record.
  final LibraryEntryRef libraryEntryRef;
  final String? trackingEntryId;
  final int? seasonNumber;
  final int? episodeNumber;
  final TrackingSourceType? sourceType;
  final String? seenWhere;
  final DateTime watchedAt;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  WatchSessionRef get ref => WatchSessionRef(
        kind: libraryEntryRef.kind,
        id: id,
      );

  String? get sourceTypeApiValue => sourceType?.apiValue;

  Map<String, dynamic> toSyncPayload() {
    // Hierarchy coordinates are entry by TV/Anime watch-session codecs. This
    // common fallback intentionally carries only lifecycle fields so an
    // unregistered kind cannot leak video semantics through the host.
    return {
      'library_entry_ref': libraryEntryRef.toJson(),
      'tracking_entry_id': trackingEntryId,
      'source_type': sourceTypeApiValue,
      'watched_at': watchedAt.toUtc().toIso8601String(),
      'seen_where': seenWhere,
      'rating': rating,
      'notes': notes,
    };
  }

  WatchSession copyWith({
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
    return WatchSession(
      id: id ?? this.id,
      libraryEntryRef: libraryEntryRef ?? this.libraryEntryRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      sourceType: sourceType ?? this.sourceType,
      seenWhere: seenWhere ?? this.seenWhere,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
