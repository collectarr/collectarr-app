import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/library/add/models/library_add_target.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_kind_draft.dart';
import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/add/comic_add_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_entry_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helpers/tracking_state_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('adds metadata results to entry collection with default details',
      () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await fixture.db.into(fixture.db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-1',
            name: 'Short Box 1',
            sortOrder: const Value(1),
          ),
        );

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      entryMutations: fixture.entryMutations,
      wishlistMutations: fixture.wishlistMutations,
      trackingMutations: fixture.trackingMutations,
      items: [_comic('comic-1')],
      target: LibraryAddTarget.entry,
      defaults: LibraryAddDefaults(
        condition: 'Very Fine',
        purchaseDate: DateTime.utc(2024, 5, 1),
        locationId: 'loc-1',
        readStatus: 'read',
        tags: 'favorite,dc',
      ),
      kindDraftsByCatalogRef: {
        CatalogEntityRef(
          kind: CatalogMediaKind.comic,
          entityType: CatalogEntityTypeId.catalogItem,
          id: 'comic-1',
        ): ComicAddDraft(grade: '9.2'),
      },
    );

    final catalogRows = await CatalogSnapshotRepository(fixture.db).findAll();
    final entryRows = await ComicEntryRepository(fixture.db).listActive();
    final trackingRows = await readTrackingStates(fixture.db);
    final syncRows = await fixture.db.select(fixture.db.syncQueue).get();

    expect(catalogRows.single.id, 'comic-1');
    expect(entryRows.single.itemId, 'comic-1');
    expect(entryRows.single.condition, 'Very Fine');
    expect(entryRows.single.grade, '9.2');
    expect(entryRows.single.purchaseDate?.toUtc(), DateTime.utc(2024, 5, 1));
    expect(entryRows.single.locationId, 'loc-1');
    expect(entryRows.single.tags, 'favorite,dc');
    expect(trackingRows.single.catalogRef.id, 'comic-1');
    expect(trackingRows.single.statusStorageValue, 'Completed');
    expect(syncRows.map((row) => row.entityType), contains('library_entry'));
    expect(syncRows.map((row) => row.entityType), contains('tracking_entry'));
    expect(
      syncRows.map((row) => row.entityType),
      contains('catalog_item'),
    );
  });

  test('adds metadata results to wishlist without entry defaults', () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      entryMutations: fixture.entryMutations,
      wishlistMutations: fixture.wishlistMutations,
      trackingMutations: fixture.trackingMutations,
      items: [_comic('comic-2')],
      target: LibraryAddTarget.wishlist,
      defaults: const LibraryAddDefaults(
        condition: 'Near Mint',
        locationId: 'loc-ignored',
      ),
    );

    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();
    final entryRows = await ComicEntryRepository(fixture.db).listActive();
    final syncRows = await fixture.db.select(fixture.db.syncQueue).get();

    expect(
      CatalogEntityRef.fromJson(
        jsonDecode(wishlistRows.single.catalogRefJson) as Map<String, dynamic>,
      ).id,
      'comic-2',
    );
    expect(entryRows, isEmpty);
    expect(syncRows.map((row) => row.entityType), contains('wishlist_item'));
    expect(
      syncRows.map((row) => row.entityType),
      contains('catalog_item'),
    );
  });

  test('adds digital collection items without physical-only defaults', () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await fixture.db.into(fixture.db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-digital',
            name: 'Cloud Shelf',
            sortOrder: const Value(1),
          ),
        );

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      entryMutations: fixture.entryMutations,
      wishlistMutations: fixture.wishlistMutations,
      trackingMutations: fixture.trackingMutations,
      items: [_digitalMovie('movie-digital-1')],
      target: LibraryAddTarget.entry,
      defaults: LibraryAddDefaults(
        condition: 'Mint',
        locationId: 'loc-digital',
        readStatus: 'watched',
      ),
    );

    final entryRows = await MovieEntryRepository(fixture.db).listActive();

    expect(entryRows.single.itemId, 'movie-digital-1');
    expect(entryRows.single.isDigital, isTrue);
    expect(entryRows.single.condition, isNull);
    expect(entryRows.single.grade, isNull);
    expect(entryRows.single.locationId, isNull);
  });

  test('adds tracking-only entry when target is track', () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      entryMutations: fixture.entryMutations,
      wishlistMutations: fixture.wishlistMutations,
      trackingMutations: fixture.trackingMutations,
      items: [_comic('comic-track-1')],
      target: LibraryAddTarget.track,
      defaults: const LibraryAddDefaults(readStatus: 'reading'),
    );

    final entryRows = await ComicEntryRepository(fixture.db).listActive();
    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();
    final trackingRows = await readTrackingStates(fixture.db);

    expect(entryRows, isEmpty);
    expect(wishlistRows, isEmpty);
    expect(trackingRows.single.catalogRef.id, 'comic-track-1');
    expect(trackingRows.single.statusStorageValue, 'In progress');
  });

  test('adds tracking-only entry when target is track without status',
      () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      entryMutations: fixture.entryMutations,
      wishlistMutations: fixture.wishlistMutations,
      trackingMutations: fixture.trackingMutations,
      items: [_comic('comic-track-empty-1')],
      target: LibraryAddTarget.track,
      defaults: const LibraryAddDefaults(),
    );

    final entryRows = await ComicEntryRepository(fixture.db).listActive();
    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();
    final trackingRows = await readTrackingStates(fixture.db);

    expect(entryRows, isEmpty);
    expect(wishlistRows, isEmpty);
    expect(trackingRows.single.catalogRef.id, 'comic-track-empty-1');
    expect(trackingRows.single.statusStorageValue, isNull);
  });
}

Future<void> addLibraryItemsToTarget({
  required CatalogTransportRepository catalog,
  required LibraryEntryMutations entryMutations,
  required WishlistMutations wishlistMutations,
  required TrackingMutations trackingMutations,
  required Iterable<CatalogSearchCandidate> items,
  required LibraryAddTarget target,
  LibraryAddDefaults defaults = const LibraryAddDefaults(),
  LibraryAddCommonDraft? commonDraft,
  LibraryAddTrackingDraft? trackingDraft,
  Map<CatalogEntityRef, LibraryAddKindDraft> kindDraftsByCatalogRef = const {},
}) {
  return const LibraryAddCoordinator().add(
    LibraryAddBatchRequest(
      dependencies: LibraryAddMutationDependencies(
        catalog: catalog,
        entryMutations: entryMutations,
        wishlistMutations: wishlistMutations,
        trackingMutations: trackingMutations,
      ),
      items: items,
      target: target,
      defaults: defaults,
      commonDraft: commonDraft,
      trackingDraft: trackingDraft,
      kindDraftsByCatalogRef: kindDraftsByCatalogRef,
    ),
  );
}

class _WorkflowFixture {
  _WorkflowFixture() {
    db = LocalDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
  }

  late final LocalDatabase db;
  late final ProviderContainer container;

  CatalogTransportRepository get catalog => CatalogTransportRepository(db);

  LibraryEntryMutations get entryMutations => container.read(
        libraryEntryMutationsProvider,
      );

  WishlistMutations get wishlistMutations => container.read(
        wishlistMutationsProvider,
      );

  TrackingMutations get trackingMutations => container.read(
        trackingMutationsProvider,
      );

  void dispose() {
    container.dispose();
    db.close();
  }
}

CatalogSearchCandidate _comic(String id) {
  return CatalogSearchCandidate.fromItem(
    testCatalogItemWithKindMetadata(
      testCatalogItem(
        id: id,
        kind: 'comic',
        title: 'Superman, Vol. 4',
        itemNumber: '8A',
        publisher: 'DC',
        releaseYear: 2016,
        barcode: '76194134192700811',
      ),
    ),
  );
}

CatalogSearchCandidate _digitalMovie(String id) {
  return CatalogSearchCandidate.fromItem(
    testCatalogItemWithKindMetadata(
      testCatalogItem(
        id: id,
        kind: 'movie',
        title: 'Akira',
        publisher: 'GKIDS',
        physicalFormat: 'digital',
        physicalFormatLabel: 'Digital',
      ),
    ),
  );
}

