import 'dart:async';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';

final class WatchSessionMutations {
  const WatchSessionMutations({
    required this.watchSessions,
    required this.syncQueue,
    required this.mutationRunner,
  });

  final WatchSessionsRepository watchSessions;
  final SyncQueueRepository syncQueue;
  final CollectionMutationRunner mutationRunner;

  Future<WatchSession> saveWatchSession(WatchSession session) async {
    final now = session.updatedAt;
    await mutationRunner.run(
      action: () async {
        await watchSessions.upsert(session);
        await syncQueue
            .enqueue(_syncChangeForWatchSession(session, 'upsert', now));
      },
      eventsToEmit: const [WatchSessionChanged()],
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
      eventsToEmit: const [WatchSessionChanged()],
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
