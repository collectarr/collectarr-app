import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/state/sync_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collection mutations enqueue personal sync changes', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container
        .read(collectionMutationsProvider)
        .addItem('comic-1', condition: 'Near Mint', grade: '9.8');

    final queued = await db.select(db.syncQueue).get();
    expect(queued, hasLength(1));
    expect(queued.single.entityType, 'owned_item');
    expect(queued.single.action, 'upsert');
    expect(container.read(syncControllerProvider).pendingCount, 1);
  });
}
