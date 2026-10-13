import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_change.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_listening_sync_codec.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_listening.dart';
import 'package:collectarr_app/features/library/tracking/library_tracking_registry.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/sync/data/sync_apply_service.dart';
import 'package:collectarr_app/features/sync/data/sync_retry_mapper.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  late LocalDatabase db;
  late MusicListeningRepository repository;
  const codec = MusicListeningSyncCodec();
  const entryRef = LibraryEntryRef(
    kind: CatalogMediaKind.music,
    id: LibraryEntryId('entry-1'),
  );

  setUp(() async {
    db = LocalDatabase(NativeDatabase.memory());
    repository = MusicListeningRepository(db);
    await db.into(db.libraryEntries).insert(
          LibraryEntriesCompanion.insert(
            id: entryRef.id.value,
            kind: entryRef.kind.apiValue,
            payloadJson: '{}',
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        );
  });

  tearDown(() => db.close());

  test('applies Music listening event upserts and deletes from Sync', () async {
    expect(
      libraryKindSyncEntityCodecs.map((codec) => codec.entityType),
      contains('music_listen_event'),
    );
    final upsert = _syncEntity(
      action: 'upsert',
      changedAt: '2026-08-03T00:00:00.000Z',
      payload: {
        'library_entry_ref': entryRef.toJson(),
        'listened_at': '2026-08-02T00:00:00.000Z',
        'notes': 'First pressing',
      },
    );
    await codec.applyPullBatch(db, [upsert]);

    final event = await repository.findById('listen-1');
    expect(event?.libraryEntryRef, entryRef);
    expect(event?.notes, 'First pressing');
    expect(event?.updatedAt?.toUtc(), DateTime.utc(2026, 8, 3));

    await codec.applyPullBatch(db, [
      _syncEntity(
        action: 'delete',
        changedAt: '2026-08-04T00:00:00.000Z',
        payload: {
          'library_entry_ref': entryRef.toJson(),
          'listened_at': '2026-08-02T00:00:00.000Z',
        },
      ),
    ]);

    expect((await repository.findById('listen-1'))?.deletedAt?.toUtc(),
        DateTime.utc(2026, 8, 4));
    expect(await repository.listForLibraryEntry(entryRef), isEmpty);
  });

  test('SyncApplyService dispatches Music event batches through the registry',
      () async {
    final service = SyncApplyService(
      client: _PullSyncClient({
        'server_time': '2026-08-05T00:00:00.000Z',
        'entities': [
          _syncEntity(
            action: 'upsert',
            changedAt: '2026-08-03T00:00:00.000Z',
            payload: {
              'library_entry_ref': entryRef.toJson(),
              'listened_at': '2026-08-02T00:00:00.000Z',
              'notes': 'Applied by shared sync host',
            },
          ),
        ],
      }),
      db: db,
      queue: SyncQueueRepository(db),
      entryPersistence: CollectarrLibraryEntryPersistence(db),
      trackingRecords: TrackingStorageRepository(db),
      wishlistItems: WishlistItemsCacheRepository(db),
    );

    await service.syncNow('device-1');

    final event = await repository.findById('listen-1');
    expect(event?.notes, 'Applied by shared sync host');
    expect(event?.updatedAt?.toUtc(), DateTime.utc(2026, 8, 3));
  });

  test('retries a rejected event from the Music-owned local record', () async {
    await repository.upsert(
      MusicListenEvent(
        id: 'listen-1',
        libraryEntryRef: entryRef,
        listenedAt: DateTime.utc(2026, 8, 2),
        notes: 'Keep local note',
      ),
    );

    final retry = await SyncRetryMapper.localRetryChange(
      const SyncRejectedChange(
        entityType: 'music_listen_event',
        entityId: 'listen-1',
        reason: 'conflict',
      ),
      db: db,
      changedAt: DateTime.utc(2026, 8, 5),
      uuid: const Uuid(),
    );

    expect(retry, isNotNull);
    expect(retry!.entityType, 'music_listen_event');
    expect(retry.entityId, 'listen-1');
    expect(retry.action, 'upsert');
    expect(retry.payload['notes'], 'Keep local note');
    expect(retry.clientChangedAt, DateTime.utc(2026, 8, 5));
  });

  test('does not claim another kind’s rejected sync entity', () async {
    final retry = await codec.retryRejected(
      const SyncRejectedChange(
        entityType: 'tracking_entry',
        entityId: 'entry-1',
        reason: 'conflict',
      ),
      db: db,
      changedAt: DateTime.utc(2026, 8, 5),
      uuid: const Uuid(),
    );

    expect(retry, isNull);
  });
}

Map<String, Object?> _syncEntity({
  required String action,
  required String changedAt,
  required Map<String, Object?> payload,
}) =>
    {
      'entity_type': 'music_listen_event',
      'entity_id': 'listen-1',
      'action': action,
      'client_changed_at': changedAt,
      'payload': payload,
    };

class _PullSyncClient extends CollectarrSyncClient {
  _PullSyncClient(this.response)
      : super(baseUrl: 'http://unused.invalid', syncKey: 'test');

  final Map<String, dynamic> response;

  @override
  Future<Map<String, dynamic>> pull({DateTime? since}) async => response;
}
