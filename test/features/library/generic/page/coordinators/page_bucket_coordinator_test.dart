import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/providers/collection_mutation_providers.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/library/generic/filter_dialog.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_bucket_coordinator.dart';
import 'package:collectarr_app/features/library/generic/page/coordinators/page_coordinator_context.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/generic/toolbar_chrome.dart';
import 'package:collectarr_app/features/library/generic/view_preference_store.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/selection/library_selection_state.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renames every matching catalog bucket in one mutation',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final harness = await _pumpHarness(tester, db);
    final type = bookKindModule;
    final firstCatalog = testCatalogItem(
      id: 'book-1',
      kind: 'book',
      payload: {'publisher': 'Old publisher'},
    );
    final secondCatalog = testCatalogItem(
      id: 'book-2',
      kind: 'book',
      payload: {'publisher': 'Old publisher'},
    );
    final projection = _projection(
      type,
      [
        testShelfEntry(
          itemId: firstCatalog.id,
          kind: firstCatalog.kind,
          catalogItem: firstCatalog,
        ),
        testShelfEntry(
          itemId: secondCatalog.id,
          kind: secondCatalog.kind,
          catalogItem: secondCatalog,
        ),
      ],
    );
    final page = harness.contextFor(type);
    harness.selectedBucket = 'Old publisher';

    final affected =
        await LibraryPageBucketCoordinator(page).mutateBucketValues(
      projection,
      'book.publisher',
      'Old publisher',
      replacement: 'New publisher',
    );

    expect(affected, 2);
    expect(harness.selectedBucket, 'New publisher');
    expect(harness.rebuildCount, 1);
    final cached = await LibraryCatalogRepository(db).findByIds(
      [firstCatalog.id, secondCatalog.id],
    );
    expect(cached[firstCatalog.id]?.payload['publisher'], 'New publisher');
    expect(cached[secondCatalog.id]?.payload['publisher'], 'New publisher');
  });

  testWidgets('deletes catalog bucket values and clears selected bucket',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final harness = await _pumpHarness(tester, db);
    final type = bookKindModule;
    final catalog = testCatalogItem(
      id: 'book-delete-1',
      kind: 'book',
      payload: {'publisher': 'Delete me'},
    );
    final page = harness.contextFor(type);
    harness.selectedBucket = 'Delete me';

    final affected =
        await LibraryPageBucketCoordinator(page).mutateBucketValues(
      _projection(
        type,
        [
          testShelfEntry(
            itemId: catalog.id,
            kind: catalog.kind,
            catalogItem: catalog,
          ),
        ],
      ),
      'book.publisher',
      'Delete me',
    );

    expect(affected, 1);
    expect(harness.selectedBucket, isNull);
    expect(harness.rebuildCount, 1);
    final cached = await LibraryCatalogRepository(db).findById(catalog.id);
    expect(cached?.payload['publisher'], isNull);
  });

  testWidgets('persists owned condition changes through the mutation command',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final harness = await _pumpHarness(tester, db);
    final type = musicKindModule;
    final owned = testOwnedItem(
      id: 'owned-music-1',
      itemId: 'music-1',
      kind: 'music',
      condition: 'Very Good',
    );
    final catalog = testCatalogItem(
      id: 'music-1',
      kind: 'music',
      title: 'Test album',
    );
    final ownedRepository = harness.ref.read(
      ownedItemsRepositoryProvider,
    );
    await ownedRepository.upsert(owned);
    harness.selectedBucket = 'Very Good';

    final affected =
        await LibraryPageBucketCoordinator(harness.contextFor(type))
            .mutateBucketValues(
      _projection(
        type,
        [
          testShelfEntry(
            itemId: catalog.id,
            kind: catalog.kind,
            catalogItem: catalog,
            ownedItem: owned,
          ),
        ],
      ),
      'music.condition',
      'Very Good',
      replacement: 'Mint',
    );

    expect(affected, 1);
    expect(harness.selectedBucket, 'Mint');
    final updated = await ownedRepository.findById(owned.id);
    expect(updated?.condition, 'Mint');
  });

  testWidgets('does nothing for unsupported, unknown, or mismatched groups',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final harness = await _pumpHarness(tester, db);
    final type = bookKindModule;
    final catalog = testCatalogItem(
      id: 'book-noop-1',
      kind: 'book',
      payload: {'publisher': 'Publisher'},
    );
    final projection = _projection(
      type,
      [
        testShelfEntry(
          itemId: catalog.id,
          kind: catalog.kind,
          catalogItem: catalog,
        ),
      ],
    );
    final page = harness.contextFor(type);
    final coordinator = LibraryPageBucketCoordinator(page);

    expect(
      await coordinator.mutateBucketValues(
        projection,
        'book.author',
        'Publisher',
        replacement: 'New author',
      ),
      0,
    );
    expect(
      await coordinator.mutateBucketValues(
        projection,
        'book.unknown',
        'Publisher',
        replacement: 'New publisher',
      ),
      0,
    );
    expect(
      await coordinator.mutateBucketValues(
        projection,
        'book.publisher',
        'Different publisher',
        replacement: 'New publisher',
      ),
      0,
    );
    expect(harness.selectedBucket, isNull);
    expect(harness.rebuildCount, 0);
  });
}

LibraryProjection _projection(
  LibraryKindModule type,
  List<ShelfEntry> sources,
) {
  final items = [
    for (final source in sources) LibraryProjectionItem.fromShelf(source, type),
  ];
  return LibraryProjection(
    allItems: items,
    filteredItems: items,
    buckets: const [],
    selectedItem: null,
    counts: const LibraryToolbarCounts(),
  );
}

Future<_CoordinatorHarness> _pumpHarness(
  WidgetTester tester,
  LocalDatabase db,
) async {
  final events = CollectionEventBus();
  addTearDown(events.dispose);
  final mutations = OwnedItemMutations(
    ownedItems: OwnedItemsRepository(db),
    wishlist: WishlistItemsCacheRepository(db),
    catalogCache: LibraryCatalogRepository(db),
    trackingEntries: TrackingEntriesCacheRepository(
      db,
      codecs: collectarrTrackingEntryCodecs,
    ),
    syncQueue: SyncQueueRepository(db),
    mutationRunner: CollectionMutationRunner(
      database: db,
      events: events,
      syncScheduler: () {},
    ),
  );
  final harness = _CoordinatorHarness(mutations);
  await harness.pump(tester);
  return harness;
}

final class _CoordinatorHarness {
  _CoordinatorHarness(this.mutations);

  final OwnedItemMutations mutations;
  late BuildContext buildContext;
  late WidgetRef ref;
  String? selectedBucket;
  int rebuildCount = 0;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localDatabaseProvider.overrideWithValue(
            mutations.mutationRunner.database,
          ),
          ownedItemMutationsProvider.overrideWithValue(mutations),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            buildContext = context;
            this.ref = ref;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  LibraryPageCoordinatorContext contextFor(LibraryKindModule type) {
    return LibraryPageCoordinatorContext(
      context: buildContext,
      ref: ref,
      getType: () => type,
      getAccent: () => type.identity.accent,
      getMounted: () => true,
      getViewPrefs: () => LibraryViewPreferenceStore(type.kind),
      getSearchQuery: () => '',
      setSearchQuery: (_) {},
      getViewState: () => null,
      setViewState: (_) {},
      getSelection: LibrarySelectionState.empty,
      setSelection: (_) {},
      getSelectedId: () => null,
      setSelectedId: (_) {},
      getSelectionAnchorId: () => null,
      setSelectionAnchorId: (_) {},
      getSelectedBucket: () => selectedBucket,
      setSelectedBucket: (value) => selectedBucket = value,
      getSelectedLetter: () => null,
      setSelectedLetter: (_) {},
      getLinkedMetadataFilter: () => null,
      setLinkedMetadataFilter: (_) {},
      getCollectionStatusScope: () => LibraryCollectionStatusScope.all,
      setCollectionStatusScope: (_) {},
      getBucketCompletionScope: () => LibraryBucketCompletionScope.all,
      setBucketCompletionScope: (_) {},
      getQuickView: () => null,
      setQuickView: (_) {},
      getFilterSelection: () => LibraryFilterSelection.none,
      setFilterSelection: (_) {},
      getActiveSmartListId: () => null,
      setActiveSmartListId: (_) {},
      getActiveSmartListName: () => null,
      setActiveSmartListName: (_) {},
      getScopeHistory: () => const [],
      setScopeHistory: (_) {},
      getActiveLoanOwnedItemIds: () => const <String>{},
      getPinnedSortFavoriteIds: () => const <String>{},
      setPinnedSortFavoriteIds: (_) {},
      getPinnedColumnFavoriteKeys: () => const <String>{},
      getSortFavorites: () => const [],
      getActiveSortFavorite: () => null,
      getScopeAvailableSortColumns: () => const <String>[],
      getIsScanningCover: () => false,
      setIsScanningCover: (_) {},
      loadColumnFavoritePresets: () async {},
      loadActiveLoanIds: () async {},
      togglePinnedColumnFavorite: (_) {},
      rebuild: ([fn]) {
        rebuildCount++;
        fn?.call();
      },
      mutateSidebarScope: (_) {},
      updateViewState: (_) {},
      selectItem: (_) {},
      syncRouteState: () {},
      bulkActions: () => throw UnsupportedError('Not used by bucket tests'),
      confirmBulkRemove: (_, {required count, itemLabel = 'items'}) async =>
          false,
      confirmSingleRemove: (_, {required title, required itemLabel}) async =>
          false,
      showBulkEditDialog: (_, {required type, required selectedCount}) async =>
          null,
    );
  }
}
