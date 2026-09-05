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
}
