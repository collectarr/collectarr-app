import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
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
        await LibraryCatalogRepository(db).upsertAll([
          typedCatalogItemFromMap({
            'id': 'cat-1',
            'kind': 'comic',
            'title': 'Test Title',
          }),
        ]);
        return 42;
      },
      eventsToEmit: const [OwnedItemAdded('owned-1')],
    );

    expect(result, 42);
    await Future<void>.delayed(Duration.zero);
    expect(eventsReceived, hasLength(1));
    expect((eventsReceived.first as OwnedItemAdded).ownedItemId, 'owned-1');
    expect(syncScheduled, isTrue);

    final items = await LibraryCatalogRepository(db).findAll();
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
          await LibraryCatalogRepository(db).upsertAll([
            typedCatalogItemFromMap({
              'id': 'cat-fail',
              'kind': 'comic',
              'title': 'Should Rollback',
            }),
          ]);
          throw Exception('Simulated write failure');
        },
        eventsToEmit: const [OwnedItemAdded('owned-fail')],
      ),
      throwsA(isA<Exception>()),
    );

    expect(eventsReceived, isEmpty);
    expect(syncScheduled, isFalse);

    final items = await LibraryCatalogRepository(db).findAll();
    expect(items, isEmpty);

    await sub.cancel();
  });

  test('passes mutation origin to the origin handler after commit', () async {
    MutationOrigin? observedOrigin;
    final runner = CollectionMutationRunner(
      database: db,
      events: eventBus,
      mutationOriginHandler: (origin) => observedOrigin = origin,
    );

    await runner.run(
      action: () async {},
      triggerSync: false,
      origin: MutationOrigin.fileImport,
    );

    expect(observedOrigin, MutationOrigin.fileImport);
  });

  test(
      'passes local reference and origin to local mutation handler after commit',
      () async {
    CatalogEntityRef? observedRef;
    MutationOrigin? observedOrigin;
    final runner = CollectionMutationRunner(
      database: db,
      events: eventBus,
      localMutationHandler: (localRef, origin) {
        observedRef = localRef;
        observedOrigin = origin;
      },
    );
    const localRef = CatalogEntityRef(
      id: 'movie-1',
      kind: 'movie',
      entityType: CatalogEntityType.work,
    );

    await runner.run(
      action: () async {
        await LibraryCatalogRepository(db).upsertAll([
          typedCatalogItemFromMap({
            'id': localRef.id,
            'kind': localRef.kind,
            'title': 'Movie',
          }),
        ]);
      },
      triggerSync: false,
      origin: MutationOrigin.user,
      localRef: localRef,
    );

    expect(observedRef, localRef);
    expect(observedOrigin, MutationOrigin.user);
  });
}
