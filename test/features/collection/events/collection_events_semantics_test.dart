import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/collection/events/collection_event.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabase db;
  late CollectionEventBus eventBus;
  late CollectionMutationRunner runner;
  late OwnedItemMutations ownedMutations;
  late WishlistMutations wishlistMutations;
  late TrackingMutations trackingMutations;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = LocalDatabase(NativeDatabase.memory());
    eventBus = CollectionEventBus();
    runner = CollectionMutationRunner(
      database: db,
      events: eventBus,
    );

    final ownedRepo = OwnedItemsCacheRepository(db);
    final wishlistRepo = WishlistItemsCacheRepository(db);
    final catalogRepo = LibraryCatalogRepository(db);
    final trackingRepo = TrackingEntriesCacheRepository(db);
    final trackingUnitsRepo = TrackingUnitsCacheRepository(
      db,
      codecs: collectarrTrackingUnitCodecs,
    );
    final watchSessionsRepo = WatchSessionsCacheRepository(
      db,
      codecs: collectarrWatchSessionCodecs,
    );
    final syncQueueRepo = SyncQueueRepository(db);

    ownedMutations = OwnedItemMutations(
      ownedItems: ownedRepo,
      wishlist: wishlistRepo,
      catalogCache: catalogRepo,
      trackingEntries: trackingRepo,
      syncQueue: syncQueueRepo,
      mutationRunner: runner,
    );

    wishlistMutations = WishlistMutations(
      wishlist: wishlistRepo,
      catalogCache: catalogRepo,
      trackingEntries: trackingRepo,
      trackingUnits: trackingUnitsRepo,
      syncQueue: syncQueueRepo,
      mutationRunner: runner,
    );

    trackingMutations = TrackingMutations(
      trackingEntries: trackingRepo,
      trackingUnits: trackingUnitsRepo,
      watchSessions: watchSessionsRepo,
      catalogCache: catalogRepo,
      syncQueue: syncQueueRepo,
      mutationRunner: runner,
    );
  });

  tearDown(() async {
    eventBus.dispose();
    await db.close();
  });

  test('add owned item without wishlist emits OwnedItemAdded only', () async {
    final events = <CollectionEvent>[];
    final sub = eventBus.stream.listen(events.add);

    final item = await ownedMutations.addOwnedItem(
      AddOwnedItemCommand(
        catalogRef: testCatalogRef('movie-100', kind: 'movie'),
        common: const OwnedItemCommonDraft(),
        details: const MovieOwnedDetailsDraft(),
      ),
    );

    await Future<void>.delayed(Duration.zero);
    expect(events, [OwnedItemAdded(item.id)]);
    await sub.cancel();
  });

  test(
      'add owned item with matching wishlist entry emits OwnedItemAdded and WishlistChanged',
      () async {
    await wishlistMutations.addToWishlist('movie-200', fallbackKind: 'movie');

    final events = <CollectionEvent>[];
    final sub = eventBus.stream.listen(events.add);

    final item = await ownedMutations.addOwnedItem(
      AddOwnedItemCommand(
        catalogRef: testCatalogRef('movie-200', kind: 'movie'),
        common: const OwnedItemCommonDraft(),
        details: const MovieOwnedDetailsDraft(),
      ),
    );

    await Future<void>.delayed(Duration.zero);
    expect(events, [
      OwnedItemAdded(item.id),
      const WishlistChanged('movie-200'),
    ]);
    await sub.cancel();
  });

  test('failed transaction emits no events', () async {
    final events = <CollectionEvent>[];
    final sub = eventBus.stream.listen(events.add);

    expect(
      () => runner.run(
        action: () async {
          throw Exception('Database mutation failed');
        },
        eventsToEmit: const [
          OwnedItemAdded('should-not-emit'),
          WishlistChanged('should-not-emit'),
        ],
      ),
      throwsA(isA<Exception>()),
    );

    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
    await sub.cancel();
  });

  test('remove tracking emits TrackingChanged only', () async {
    await trackingMutations.upsertTrackingEntry(
      TrackingTarget.catalog(testCatalogRef('book-300', kind: 'book')),
      sourceType: TrackingSourceType.digital,
      status: MediaTrackingStatus.inProgress,
    );

    final entries = await TrackingEntriesCacheRepository(db)
        .findActiveByItemIds(['book-300']);
    final trackingEntry = entries.single;

    final events = <CollectionEvent>[];
    final sub = eventBus.stream.listen(events.add);

    await trackingMutations.removeTrackingEntry(trackingEntry);

    await Future<void>.delayed(Duration.zero);
    expect(events, [TrackingChanged(trackingEntry.id)]);
    await sub.cancel();
  });
}
