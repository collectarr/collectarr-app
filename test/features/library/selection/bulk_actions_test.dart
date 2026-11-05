import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/library_entry_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/library/entries/repository.dart';
import 'package:collectarr_app/features/library/tracking/storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/unit_storage_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../support/builders/catalog_item_builder.dart';
import '../../../support/builders/workspace_item_builder.dart';
import '../../../support/builders/library_entry_builder.dart';

import 'package:collectarr_app/features/library/selection/bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/bulk_edit_dialog.dart';
import 'package:collectarr_app/features/library/selection/context.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/collection/coordinators/collection_command_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabase db;
  late CollectionEventBus eventBus;
  late CollectionMutationRunner runner;
  late LibraryEntryMutations entryMutations;
  late WishlistMutations wishlistMutations;
  late TrackingMutations trackingMutations;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = LocalDatabase(NativeDatabase.memory());
    await CatalogItemCacheRepository(db).upsert(
      testCatalogItem(id: 'movie-100', kind: 'music', title: 'Movie 100'),
    );
    await CatalogItemCacheRepository(db).upsert(
      testCatalogItem(id: 'movie-200', kind: 'music', title: 'Movie 200'),
    );
    eventBus = CollectionEventBus();
    runner = CollectionMutationRunner(
      database: db,
      events: eventBus,
    );

    final entryRepo = LibraryEntriesRepository(db);
    final wishlistRepo = WishlistItemsCacheRepository(db);
    final trackingRepo = TrackingStorageRepository(
      db,
      codecs: libraryTrackingStorageCodecs,
    );
    final trackingUnitsRepo = TrackingUnitStorageRepository(
      db,
      codecs: libraryTrackingUnitCodecs,
    );
    final watchSessionsRepo = WatchSessionsRepository(
      db,
      codecs: libraryWatchSessionCodecs,
    );
    final syncQueueRepo = SyncQueueRepository(db);

    entryMutations = LibraryEntryMutations(
      libraryEntries: entryRepo,
      wishlist: wishlistRepo,
      catalogSummaries: CatalogDisplaySummaryRepository(db),
      syncQueue: syncQueueRepo,
      mutationRunner: runner,
    );

    wishlistMutations = WishlistMutations(
      wishlist: wishlistRepo,
      syncQueue: syncQueueRepo,
      mutationRunner: runner,
    );

    trackingMutations = TrackingMutations(
      trackingRecords: trackingRepo,
      trackingUnits: trackingUnitsRepo,
      watchSessions: watchSessionsRepo,
      syncQueue: syncQueueRepo,
      mutationRunner: runner,
    );
  });

  tearDown(() async {
    eventBus.dispose();
    await db.close();
  });

  LibraryBulkActions actions() => LibraryBulkActions(
        coordinator: CollectionCommandCoordinator(
            entryMutations: entryMutations,
            trackingMutations: trackingMutations,
            mutationRunner: runner),
        entryMutations: entryMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
        catalogSnapshots: CatalogSnapshotRepository(db),
      );
  test('missing later catalog snapshot leaves all wishlist entries intact',
      () async {
    final first = testCatalogRef('movie-100', kind: 'music');
    final missing = testCatalogRef('missing', kind: 'music');
    await wishlistMutations.addToWishlist(first);
    await wishlistMutations.addToWishlist(missing);
    final wishlist = WishlistItemsCacheRepository(db);
    final entries = [
      testLibraryWorkspaceSource(
          itemId: first.id,
          kind: 'music',
          wishlistItem: await wishlist.findActiveByCatalogRef(first)),
      testLibraryWorkspaceSource(
          itemId: missing.id,
          kind: 'music',
          wishlistItem: await wishlist.findActiveByCatalogRef(missing)),
    ];
    await expectLater(actions().moveSelectedToEntry(entries), throwsStateError);
    expect(await wishlist.findActiveByCatalogRef(first), isNotNull);
    expect(await wishlist.findActiveByCatalogRef(missing), isNotNull);
  });
  test('entry-only commands reject mixed targets before executing a subset',
      () async {
    final entries = [
      testLibraryWorkspaceSource(
          itemId: 'movie-100',
          kind: 'music',
          libraryEntry: testLibraryEntry(kind: 'music', itemId: 'movie-100')),
      testLibraryWorkspaceSource(itemId: 'movie-200', kind: 'music'),
    ];
    final incompatible = isA<StateError>().having((error) => error.message,
        'reason', contains('unavailable for this selection'));
    await expectLater(
        actions().duplicateSelected(entries), throwsA(incompatible));
    await expectLater(
        actions().editSelected(
            entries: entries,
            selection: const LibraryBulkEditSelection(condition: 'Mint')),
        throwsA(incompatible));
    await expectLater(
        actions().moveSelectedToEntry(entries), throwsA(incompatible));
  });
  test('mixed kinds and incomplete snapshots are explicit', () {
    final entries = [
      testLibraryWorkspaceSource(itemId: 'a', kind: 'music'),
      testLibraryWorkspaceSource(itemId: 'b', kind: 'comic')
    ];
    expect(LibrarySelectionContext(entries).homogeneousKind, null);
    expect(
        LibrarySelectionContext(entries, complete: false)
            .every((entry) => true),
        false);
    expect(LibrarySelectionContext([]).every((entry) => true), false);
  });
}
