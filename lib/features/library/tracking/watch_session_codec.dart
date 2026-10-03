import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';

final class WatchSessionCreateRequest {
  const WatchSessionCreateRequest({
    required this.id,
    required this.libraryEntryRef,
    required this.updatedAt,
    this.trackingEntryId,
    this.sourceType,
    this.watchedAt,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeId,
    this.seenWhere,
    this.rating,
    this.notes,
  });

  final String id;
  final LibraryEntryRef libraryEntryRef;
  final String? trackingEntryId;
  final Object? sourceType;
  final DateTime? watchedAt;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeId;
  final String? seenWhere;
  final int? rating;
  final String? notes;
  final DateTime updatedAt;
}

/// Kind-entry persistence contract for watch-session projections.
///
/// The shared host knows only lifecycle fields needed to aggregate and order
/// sessions. Episode coordinates and table mappings remain in the owner.
abstract interface class WatchSessionCodec {
  CatalogMediaKind get kind;

  /// Creates the kind-entry session from the owning local library entry.
  WatchSession create(WatchSessionCreateRequest request);

  Future<List<WatchSession>> listActive(LocalDatabase db);

  Future<WatchSession?> findByRef(LocalDatabase db, WatchSessionRef ref);

  Future<void> upsert(LocalDatabase db, WatchSession session);

  /// Serializes a watch session for the personal Sync protocol.
  ///
  /// The host supplies lifecycle and transport plumbing; the owning kind
  /// decides whether the payload contains hierarchy coordinates.
  JsonMap toSyncPayload(WatchSession session);

  /// Reconstructs a session received through the personal Sync protocol.
  WatchSession fromSyncPayload({
    required JsonMap payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });
}
