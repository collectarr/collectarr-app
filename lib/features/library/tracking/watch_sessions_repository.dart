import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
import 'package:collectarr_app/core/models/structural_ref_validation.dart';

/// Aggregates kind-owned watch-session tables at the tracking boundary.
///
/// The shared host only aggregates lifecycle projections. TV/Anime mapping and
/// persistence are supplied through their explicit codecs.
class WatchSessionsRepository {
  WatchSessionsRepository(
    this._db, {
    required Iterable<WatchSessionCodec> codecs,
  }) : _codecs = {
          for (final codec in codecs) codec.kind: codec,
        };

  final LocalDatabase _db;
  final Map<CatalogMediaKind, WatchSessionCodec> _codecs;

  WatchSession create(WatchSessionCreateRequest request) {
    requireKnownCatalogRef(request.targetRef, 'watchSession.targetRef');
    final codec = _codecs[request.targetRef.mediaKind];
    if (codec == null) {
      throw ArgumentError.value(
        request.targetRef.kind,
        'request.targetRef.kind',
        'No watch-session codec is registered for this kind',
      );
    }
    return codec.create(request);
  }

  Future<List<WatchSession>> listActive() async {
    final sessions = <WatchSession>[];
    for (final codec in _codecs.values) {
      sessions.addAll(await codec.listActive(_db));
    }
    sessions.sort(_compareSessions);
    return sessions;
  }

  Future<List<WatchSession>> listActiveByCatalogRefs(
    Iterable<CatalogEntityRef> catalogRefs,
  ) async {
    final scopes = catalogRefs.toSet();
    if (scopes.isEmpty) return const [];
    for (final scope in scopes) {
      requireKnownCatalogRef(scope, 'watchSession.catalogRef');
    }
    final sessions = <WatchSession>[];
    for (final codec in _codecs.values) {
      final candidates = await codec.listActive(_db);
      sessions.addAll(
        candidates.where(
          (session) => scopes.any(
            (scope) => codec.matchesCatalogScope(session, scope),
          ),
        ),
      );
    }
    sessions.sort(_compareSessions);
    return sessions;
  }

  Future<WatchSession?> findByRef(WatchSessionRef ref) {
    return _codecForKind(ref.kind).findByRef(_db, ref);
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
    requireKnownCatalogRef(session.targetRef, 'watchSession.targetRef');
    return _codecForKind(session.targetRef.mediaKind).upsert(_db, session);
  }

  Map<String, dynamic> toSyncPayload(WatchSession session) {
    return _codecForKind(session.targetRef.mediaKind).toSyncPayload(session);
  }

  WatchSessionCodec _codecForKind(CatalogMediaKind kind) {
    final codec = _codecs[kind];
    if (codec == null) {
      throw StateError(
        'No watch-session codec is registered for kind "${kind.apiValue}".',
      );
    }
    return codec;
  }

  static int _compareSessions(WatchSession left, WatchSession right) {
    return right.watchedAt.compareTo(left.watchedAt);
  }
}
