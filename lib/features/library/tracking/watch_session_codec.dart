import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/json_encodable.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';

/// Kind-entry persistence contract for watch-session projections.
///
/// The shared host knows only lifecycle fields needed to aggregate and order
/// sessions. Episode coordinates and table mappings remain in the owner.
abstract interface class WatchSessionCodec {
  CatalogMediaKind get kind;

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
