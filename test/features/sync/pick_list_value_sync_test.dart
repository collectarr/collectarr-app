import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/collectarr_sync_client.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/sync/data/sync_apply_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;

  setUp(() => db = LocalDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a borrower keeps its sort name and contact details locally', () async {
    final repository = PickListRepository(db);
    await repository.upsertValue(const PickListValue(
      id: 'b1',
      listName: 'borrower',
      value: 'Alex Reference',
      sortName: 'Reference, Alex',
      email: 'alex@example.invalid',
      address: '1 Example Street',
    ));

    final value = (await repository.valuesForList(listName: 'borrower')).single;
    expect(value.sortName, 'Reference, Alex');
    expect(value.email, 'alex@example.invalid');
    expect(value.address, '1 Example Street');
  });

  test('synced pick-list values keep sort name, hidden state and contact',
      () async {
    final service = SyncApplyService(
      client: _PullSyncClient({
        'server_time': '2026-10-16T00:00:00.000Z',
        'entities': [
          {
            'entity_type': 'pick_list_value',
            'entity_id': 'b1',
            'action': 'upsert',
            'client_changed_at': '2026-10-15T00:00:00.000Z',
            'payload': {
              'list_name': 'borrower',
              'value': 'Alex Reference',
              'sort_order': 0,
              'sort_name': 'Reference, Alex',
              'is_hidden': true,
              'email': 'alex@example.invalid',
              'address': '1 Example Street',
            },
          },
        ],
      }),
      db: db,
      queue: SyncQueueRepository(db),
      entryPersistence: CollectarrLibraryEntryPersistence(db),
      trackingRecords: TrackingStorageRepository(db),
      wishlistItems: WishlistItemsCacheRepository(db),
    );

    await service.syncNow('device-1');

    final row = await db.select(db.pickListValuesCache).getSingle();
    expect(row.sortName, 'Reference, Alex');
    expect(row.isHidden, isTrue);
    expect(row.email, 'alex@example.invalid');
    expect(row.address, '1 Example Street');
  });
}

class _PullSyncClient extends CollectarrSyncClient {
  _PullSyncClient(this.response)
      : super(baseUrl: 'http://unused.invalid', syncKey: 'test');

  final Map<String, dynamic> response;

  @override
  Future<Map<String, dynamic>> pull({DateTime? since}) async => response;
}
