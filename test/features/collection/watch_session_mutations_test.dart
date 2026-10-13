import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/watch_session_ref.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/watch_session_mutations.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_tracking.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_registry.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase database;
  late CollectionEventBus events;
  late WatchSessionsRepository watchSessions;
  late SyncQueueRepository syncQueue;
  late WatchSessionMutations mutations;

  setUp(() {
    database = LocalDatabase(NativeDatabase.memory());
    events = CollectionEventBus();
    watchSessions = WatchSessionsRepository(
      database,
      codecs: libraryWatchSessionCodecs,
    );
    syncQueue = SyncQueueRepository(database);
    mutations = WatchSessionMutations(
      watchSessions: watchSessions,
      syncQueue: syncQueue,
      mutationRunner: CollectionMutationRunner(
        database: database,
        events: events,
      ),
    );
  });

  tearDown(() async {
    events.dispose();
    await database.close();
  });

  test('persists and syncs a TV-constructed watch session', () async {
    const entryRef = LibraryEntryRef(
      kind: CatalogMediaKind.tv,
      id: LibraryEntryId('tv-entry-1'),
    );
    final updatedAt = DateTime.utc(2026, 10, 9, 12);
    final session = TvWatchSession(
      id: 'tv-watch-1',
      libraryEntryRef: entryRef,
      episodeId: const TvEpisodeId('episode-1'),
      seasonNumber: 2,
      episodeNumber: 4,
      watchedAt: DateTime.utc(2026, 10, 8, 20),
      updatedAt: updatedAt,
      notes: 'Rewatch',
    );

    await mutations.saveWatchSession(session);

    final stored = await watchSessions.findByRef(
      const WatchSessionRef(kind: CatalogMediaKind.tv, id: 'tv-watch-1'),
    );
    expect(stored, isA<TvWatchSession>());
    expect((stored! as TvWatchSession).episodeId?.value, 'episode-1');
    expect(stored.seasonNumber, 2);
    expect(stored.episodeNumber, 4);

    final pending = await syncQueue.listPending();
    expect(pending, hasLength(1));
    expect(pending.single.entityType, 'watch_session');
    expect(pending.single.payload['season_number'], 2);
    expect(pending.single.payload['episode_number'], 4);
    expect(pending.single.payload['episode_id'], 'episode-1');
  });
}
