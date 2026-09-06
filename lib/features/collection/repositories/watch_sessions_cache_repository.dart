import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';

/// Compatibility facade over kind-owned watch-session tables.
///
/// The shared host only aggregates lifecycle projections. TV/Anime coordinate
/// mapping and persistence are supplied through explicit codecs.
class WatchSessionsCacheRepository {
  WatchSessionsCacheRepository(
    this._db, {
    required Iterable<WatchSessionCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<String, WatchSessionCodec> _codecs;

  Future<List<WatchSession>> listActive() async {
    final sessions = <WatchSession>[];
    for (final codec in _codecs.values) {
      sessions.addAll(await codec.listActive(_db));
    }
    sessions.sort(_compareSessions);
    return sessions;
  }

  Future<List<WatchSession>> listActiveByItemId(String itemId) {
    return listActiveByItemIds([itemId]);
  }

  Future<List<WatchSession>> listActiveByItemIds(
    Iterable<String> itemIds,
  ) async {
    final ids = itemIds
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (ids.isEmpty) return const [];
    final sessions = <WatchSession>[];
    for (final codec in _codecs.values) {
      sessions.addAll(await codec.listActive(_db, itemIds: ids));
    }
    sessions.sort(_compareSessions);
    return sessions;
  }

  Future<WatchSession?> findById(String id) async {
    for (final codec in _codecs.values) {
      final session = await codec.findById(_db, id);
      if (session != null) return session;
    }
    return null;
  }

  Future<void> upsert(WatchSession session) async {
    await _db.transaction(() => _upsert(session));
  }

  Future<void> upsertAll(List<WatchSession> sessions) async {
    if (sessions.isEmpty) return;
    await _db.transaction(() async {
      for (final session in sessions) {
        await _upsert(session);
      }
    });
  }

  Future<void> markDeleted(WatchSession session, DateTime deletedAt) {
    return upsert(session.copyWith(deletedAt: deletedAt, updatedAt: deletedAt));
  }

  Future<void> _upsert(WatchSession session) {
    final codec = _codecs[session.targetRef.kind];
    if (codec == null) {
      throw ArgumentError.value(
        session.targetRef.kind,
        'session.targetRef.kind',
        'No watch-session codec is registered for this kind',
      );
    }
    return codec.upsert(_db, session);
  }

  Map<String, dynamic> toSyncPayload(WatchSession session) {
    final codec = _codecs[session.targetRef.kind];
    if (codec == null) {
      throw StateError(
        'No watch-session codec is registered for kind '
        '"${session.targetRef.kind}".',
      );
    }
    return codec.toSyncPayload(session);
  }

  static int _compareSessions(WatchSession left, WatchSession right) {
    return right.watchedAt.compareTo(left.watchedAt);
  }
}
