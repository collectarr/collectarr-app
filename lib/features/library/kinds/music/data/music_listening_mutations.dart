import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';

/// Persists Music listening activity and its personal Sync change atomically.
final class MusicListeningMutations {
  MusicListeningMutations(this._db)
      : _repository = MusicListeningRepository(_db),
        _syncQueue = SyncQueueRepository(_db);

  final LocalDatabase _db;
  final MusicListeningRepository _repository;
  final SyncQueueRepository _syncQueue;

  Future<void> upsert(MusicListenEvent event) async {
    await _db.transaction(() async {
      await _repository.upsert(event);
      await _syncQueue.enqueue(_changeFor(event));
    });
  }

  Future<void> markDeleted(MusicListenEvent event, DateTime deletedAt) async {
    final deleted = MusicListenEvent(
      id: event.id,
      libraryEntryRef: event.libraryEntryRef,
      listenedAt: event.listenedAt,
      startedAt: event.startedAt,
      finishedAt: event.finishedAt,
      location: event.location,
      notes: event.notes,
      createdAt: event.createdAt,
      updatedAt: deletedAt,
      deletedAt: deletedAt,
    );
    await _db.transaction(() async {
      await _repository.upsert(deleted);
      await _syncQueue.enqueue(_changeFor(deleted));
    });
  }

  SyncChange _changeFor(MusicListenEvent event) {
    final updatedAt = (event.updatedAt ?? event.listenedAt).toUtc();
    final action = event.isDeleted ? 'delete' : 'upsert';
    return SyncChange(
      id: 'music_listen_event:${event.id}:$action:${updatedAt.microsecondsSinceEpoch}',
      entityType: 'music_listen_event',
      entityId: event.id,
      action: action,
      payload: event.toSyncPayload(),
      clientChangedAt: updatedAt,
    );
  }
}
