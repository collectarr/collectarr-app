import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabase db;
  late CollectionEventBus eventBus;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    eventBus = CollectionEventBus();
  });

  tearDown(() async {
    eventBus.dispose();
    await db.close();
  });

  test(
      'successful transaction commits write, emits event, and calls sync scheduler',
      () async {
    var syncScheduled = false;
    final runner = CollectionMutationRunner(
      database: db,
      events: eventBus,
      syncScheduler: () => syncScheduled = true,
    );

    final eventsReceived = <CollectionEvent>[];
    final sub = eventBus.stream.listen(eventsReceived.add);

    final result = await runner.run(
      action: () async {
        await db.into(db.catalogCache).insert(
              CatalogCacheCompanion.insert(
                id: 'cat-1',
                kind: 'comic',
                title: 'Test Title',
                cachedAt: DateTime.now(),
              ),
            );
        return 42;
      },
      eventsToEmit: const [OwnedItemAdded('owned-1')],
    );

    expect(result, 42);
    await Future<void>.delayed(Duration.zero);
    expect(eventsReceived, hasLength(1));
    expect((eventsReceived.first as OwnedItemAdded).ownedItemId, 'owned-1');
    expect(syncScheduled, isTrue);

    final items = await db.select(db.catalogCache).get();
    expect(items, hasLength(1));
    await sub.cancel();
  });

  test('action failure rolls back transaction and emits no events or sync',
      () async {
    var syncScheduled = false;
    final runner = CollectionMutationRunner(
      database: db,
      events: eventBus,
      syncScheduler: () => syncScheduled = true,
    );

    final eventsReceived = <CollectionEvent>[];
    final sub = eventBus.stream.listen(eventsReceived.add);

    expect(
      () => runner.run(
        action: () async {
          await db.into(db.catalogCache).insert(
                CatalogCacheCompanion.insert(
                  id: 'cat-fail',
                  kind: 'comic',
                  title: 'Should Rollback',
                  cachedAt: DateTime.now(),
                ),
              );
          throw Exception('Simulated write failure');
        },
        eventsToEmit: const [OwnedItemAdded('owned-fail')],
      ),
      throwsA(isA<Exception>()),
    );

    expect(eventsReceived, isEmpty);
    expect(syncScheduled, isFalse);

    final items = await db.select(db.catalogCache).get();
    expect(items, isEmpty);

    await sub.cancel();
  });
}
