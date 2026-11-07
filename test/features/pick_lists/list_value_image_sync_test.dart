import 'dart:convert';
import 'dart:typed_data';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/list_value_image_sync.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/pick_lists/list_value_images.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late ListValueImages images;
  final bytes = Uint8List.fromList([1, 2, 3]);

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    images = ListValueImages(db);
  });
  tearDown(() => db.close());

  test('the same value has the same Sync id on every device', () {
    expect(listValueImageSyncId('labels', 'spawn #1'),
        listValueImageSyncId('labels', 'spawn #1'));
    expect(listValueImageSyncId('labels', 'spawn #1'),
        isNot(listValueImageSyncId('icons', 'spawn #1')));
  });

  test('saving and removing an image queue Sync changes', () async {
    await images.save('labels', ' Spawn #1 ', bytes);
    final queue = SyncQueueRepository(db);
    final saved = (await queue.listPending()).single;
    expect(saved.action, 'upsert');
    expect(saved.entityType, listValueImageEntityType);
    expect(saved.entityId, listValueImageSyncId('labels', 'spawn #1'));
    expect(saved.payload, {
      'list_key': 'labels',
      'value': 'Spawn #1',
      'image': base64Encode(bytes)
    });

    // The queue keeps an entity's latest change.
    await images.remove('labels', 'Spawn #1');
    final removed = (await queue.listPending()).single;
    expect(removed.action, 'delete');
    expect(removed.entityId, saved.entityId);
  });

  test('images from Sync are stored without queueing them back', () async {
    await images.applySyncedUpsert(
        'labels', 'Spawn #1', bytes, DateTime.utc(2026, 11, 7));
    expect(await images.watch('labels', 'spawn #1').first, bytes);

    await images.applySyncedDelete(listValueImageSyncId('labels', 'spawn #1'));
    expect(await images.watch('labels', 'spawn #1').first, isNull);
    expect(await SyncQueueRepository(db).listPending(), isEmpty);
  });

  test('images above the Sync limit are refused', () async {
    final tooLarge = Uint8List(maxSyncedListValueImageBytes + 1);
    await expectLater(validateListValueImage(tooLarge), throwsFormatException);
  });
}
