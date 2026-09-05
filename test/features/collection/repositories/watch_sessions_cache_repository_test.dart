import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TV codec owns episode coordinates in sync payloads', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = WatchSessionsCacheRepository(
      db,
      codecs: collectarrWatchSessionCodecs,
    );
    final session = WatchSession(
      id: 'tv-session-1',
      targetRef: const CatalogEntityRef(
        kind: 'tv',
        entityType: CatalogEntityType.episode,
        id: 'tv-1:s1:e2',
      ),
      seasonNumber: 1,
      episodeNumber: 2,
      watchedAt: DateTime.utc(2026, 9, 6, 18),
      updatedAt: DateTime.utc(2026, 9, 6, 18),
    );

    expect(
      repository.toSyncPayload(session),
      containsPair('season_number', 1),
    );
    expect(
      repository.toSyncPayload(session),
      containsPair('episode_number', 2),
    );

    final codec = collectarrWatchSessionCodecs.singleWhere(
      (candidate) => candidate.kind == 'tv',
    );
    final decoded = codec.fromSyncPayload(
      payload: repository.toSyncPayload(session),
      id: session.id,
      updatedAt: session.updatedAt,
    );
    expect(decoded.targetRef.toJson(), session.targetRef.toJson());
    expect(decoded.seasonNumber, 1);
    expect(decoded.episodeNumber, 2);
  });

  test('common fallback does not serialize coordinates for unregistered kind',
      () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = WatchSessionsCacheRepository(
      db,
      codecs: collectarrWatchSessionCodecs,
    );
    final session = WatchSession(
      id: 'movie-session-1',
      targetRef: const CatalogEntityRef(
        kind: 'movie',
        entityType: CatalogEntityType.work,
        id: 'movie-1',
      ),
      seasonNumber: 99,
      episodeNumber: 1,
      watchedAt: DateTime.utc(2026, 9, 6, 18),
      updatedAt: DateTime.utc(2026, 9, 6, 18),
    );

    final payload = repository.toSyncPayload(session);
    expect(payload, isNot(contains('season_number')));
    expect(payload, isNot(contains('episode_number')));
  });
}
