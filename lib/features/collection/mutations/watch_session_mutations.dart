import 'dart:async';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:uuid/uuid.dart';

typedef IdGenerator = String Function();
String _defaultIdGenerator() => const Uuid().v4();

final class WatchSessionMutations {
  const WatchSessionMutations({
    required this.watchSessions,
    required this.syncQueue,
    required this.mutationRunner,
    this.idGenerator = _defaultIdGenerator,
  });

  final WatchSessionsCacheRepository watchSessions;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;
  final IdGenerator idGenerator;

  Future<WatchSession> addWatchSession(
    CatalogEntityRef targetRef, {
    String? id,
    String? trackingEntryId,
    int? seasonNumber,
    int? episodeNumber,
    Object? sourceType,
    DateTime? watchedAt,
    String? seenWhere,
    int? rating,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final session = WatchSession(
      id: id ?? idGenerator(),
      targetRef: targetRef,
      trackingEntryId: trackingEntryId,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      sourceType: sourceType,
      watchedAt: watchedAt ?? now,
      seenWhere: seenWhere,
      rating: rating,
      notes: notes,
      updatedAt: now,
    );

    await mutationRunner.run(
      action: () async {
        await watchSessions.upsert(session);
        await syncQueue
            .enqueue(_syncChangeForWatchSession(session, 'upsert', now));
      },
      eventsToEmit: [WatchSessionChanged(session.id)],
    );

    return session;
  }

  Future<void> removeWatchSession(WatchSession session) async {
    final now = DateTime.now().toUtc();
    final deleted = session.copyWith(deletedAt: now, updatedAt: now);

    await mutationRunner.run(
      action: () async {
        await watchSessions.markDeleted(session, now);
        await syncQueue
            .enqueue(_syncChangeForWatchSession(deleted, 'delete', now));
      },
      eventsToEmit: [WatchSessionChanged(session.id)],
    );
  }

  SyncChange _syncChangeForWatchSession(
    WatchSession session,
    String action,
    DateTime now,
  ) {
    return SyncChange(
      id: 'watch_session:${session.id}:$action:${now.millisecondsSinceEpoch}',
      entityType: 'watch_session',
      entityId: session.id,
      action: action,
      payload: watchSessions.toSyncPayload(session),
      clientChangedAt: now,
    );
  }
}
