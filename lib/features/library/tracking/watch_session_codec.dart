import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/watch_session.dart';

/// Kind-owned persistence contract for watch-session projections.
///
/// The shared host knows only lifecycle fields needed to aggregate and order
/// sessions. Episode coordinates and table mappings remain in the owner.
abstract interface class WatchSessionCodec {
  String get kind;

  Future<List<WatchSession>> listActive(
    LocalDatabase db, {
    Iterable<String>? itemIds,
  });

  Future<WatchSession?> findById(LocalDatabase db, String id);

  Future<void> upsert(LocalDatabase db, WatchSession session);

  /// Serializes a watch session for the provider sync boundary.
  ///
  /// The host supplies lifecycle and transport plumbing; the owning kind
  /// decides whether the payload contains hierarchy coordinates.
  Map<String, dynamic> toSyncPayload(WatchSession session);

  /// Reconstructs a session received from the provider sync boundary.
  WatchSession fromSyncPayload({
    required Map<String, dynamic> payload,
    required String id,
    required DateTime updatedAt,
    DateTime? deletedAt,
  });
}
