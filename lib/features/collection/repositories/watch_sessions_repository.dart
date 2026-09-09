import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';

/// Aggregates kind-owned watch-session tables at the collection boundary.
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
    final refsByKind = <CatalogMediaKind, Set<CatalogEntityRef>>{};
    for (final ref in catalogRefs) {
      final rootRef = _rootCatalogRef(ref);
      refsByKind
          .putIfAbsent(rootRef.mediaKind, () => <CatalogEntityRef>{})
          .add(rootRef);
    }
    if (refsByKind.isEmpty) return const [];
    final sessions = <WatchSession>[];
    for (final entry in refsByKind.entries) {
      final codec = _codecs[entry.key];
      if (codec == null) continue;
      for (final catalogRef in entry.value) {
        sessions.addAll(
          await codec.listActive(_db, catalogRef: catalogRef),
        );
      }
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
    final codec = _codecs[session.targetRef.mediaKind];
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
    final codec = _codecs[session.targetRef.mediaKind];
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

  static CatalogEntityRef _rootCatalogRef(CatalogEntityRef ref) {
    final rootId = ref.rootId;
    if (rootId != null && rootId.isNotEmpty) {
      return ref.copyWith(
        id: rootId,
        entityType: const CatalogEntityTypeId('work'),
        rootId: null,
      );
    }
    if (ref.entityType == const CatalogEntityTypeId('owned_copy') ||
        ref.entityType == const CatalogEntityTypeId('copy') ||
        ref.entityType == const CatalogEntityTypeId('tracking_entry')) {
      return ref.copyWith(entityType: const CatalogEntityTypeId('work'));
    }
    return ref;
  }
}
