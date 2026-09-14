import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';

class WatchSession {
  WatchSession({
    required this.id,
    required this.targetRef,
    required this.watchedAt,
    required this.updatedAt,
    this.trackingEntryId,
    Object? sourceType,
    this.seenWhere,
    this.rating,
    this.notes,
    this.deletedAt,
  }) : sourceType = sourceType is TrackingSourceType?
            ? sourceType
            : trackingSourceTypeFromValue(sourceType);

  final String id;
  final CatalogEntityRef targetRef;
  final String? trackingEntryId;
  final TrackingSourceType? sourceType;
  final String? seenWhere;
  final DateTime watchedAt;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  WatchSessionRef get ref => WatchSessionRef(
        kind: targetRef.mediaKind,
        id: id,
      );

  String? get sourceTypeApiValue => sourceType?.apiValue;

  Map<String, dynamic> toSyncPayload() {
    // Hierarchy coordinates are owned by TV/Anime watch-session codecs. This
    // common fallback intentionally carries only lifecycle fields so an
    // unregistered kind cannot leak video semantics through the host.
    return {
      'catalog_ref': targetRef.toJson(),
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
    return WatchSession(
      id: id ?? this.id,
      targetRef: targetRef ?? this.targetRef,
      trackingEntryId: trackingEntryId ?? this.trackingEntryId,
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
