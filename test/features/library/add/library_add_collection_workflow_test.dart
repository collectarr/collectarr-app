import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
import 'package:collectarr_app/features/library/add/library_add_reference_type.dart';
import 'package:collectarr_app/features/library/add/library_add_target.dart';
import 'package:collectarr_app/features/library/models/library_metadata_item.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds metadata results to owned collection with default details',
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
      mutations: fixture.mutations,
      items: [_comic('comic-1')],
      target: LibraryAddTarget.owned,
      defaults: LibraryAddDefaults(
        condition: 'Very Fine',
        grade: '9.2',
        purchaseDate: DateTime.utc(2024, 5, 1),
        locationId: 'loc-1',
        readStatus: 'read',
        tags: 'favorite,dc',
      ),
    );

    final catalogRows = await fixture.db.select(fixture.db.catalogCache).get();
    final ownedRows = await fixture.db.select(fixture.db.ownedItemsCache).get();
    final trackingRows =
      await fixture.db.select(fixture.db.trackingEntriesCache).get();
    final syncRows = await fixture.db.select(fixture.db.syncQueue).get();

    expect(catalogRows.single.id, 'comic-1');
    expect(ownedRows.single.itemId, 'comic-1');
    expect(ownedRows.single.condition, 'Very Fine');
    expect(ownedRows.single.grade, '9.2');
    expect(ownedRows.single.purchaseDate?.toUtc(), DateTime.utc(2024, 5, 1));
    expect(ownedRows.single.locationId, 'loc-1');
    expect(ownedRows.single.readStatus, 'read');
    expect(ownedRows.single.tags, 'favorite,dc');
    expect(ownedRows.single.storageBox, isNull);
    expect(trackingRows.single.itemId, 'comic-1');
    expect(trackingRows.single.status, 'read');
    expect(syncRows.map((row) => row.entityType), contains('owned_item'));
    expect(syncRows.map((row) => row.entityType), contains('tracking_entry'));
    expect(
      syncRows.map((row) => row.entityType),
      contains('library_item_snapshot'),
    );
  });

  test('adds metadata results to wishlist without owned defaults', () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      mutations: fixture.mutations,
      items: [_comic('comic-2')],
      target: LibraryAddTarget.wishlist,
      defaults: const LibraryAddDefaults(
        condition: 'Near Mint',
        grade: 'Ungraded',
        locationId: 'loc-ignored',
      ),
    );

    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();
    final ownedRows = await fixture.db.select(fixture.db.ownedItemsCache).get();
    final syncRows = await fixture.db.select(fixture.db.syncQueue).get();

    expect(wishlistRows.single.itemId, 'comic-2');
    expect(ownedRows, isEmpty);
    expect(syncRows.map((row) => row.entityType), contains('wishlist_item'));
    expect(
      syncRows.map((row) => row.entityType),
      contains('library_item_snapshot'),
    );
  });

  test('adds digital owned items without physical-only defaults', () async {
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
      mutations: fixture.mutations,
      items: [_digitalMovie('movie-digital-1')],
      target: LibraryAddTarget.owned,
      defaults: LibraryAddDefaults(
        condition: 'Mint',
        grade: '10.0',
        locationId: 'loc-digital',
        readStatus: 'watched',
      ),
    );

    final ownedRows = await fixture.db.select(fixture.db.ownedItemsCache).get();

    expect(ownedRows.single.itemId, 'movie-digital-1');
    expect(ownedRows.single.isDigital, isTrue);
    expect(ownedRows.single.condition, isNull);
    expect(ownedRows.single.grade, isNull);
    expect(ownedRows.single.locationId, isNull);
    expect(ownedRows.single.readStatus, 'watched');
  });

  test('adds release-referenced owned item using the selected edition without forcing a physical release',
      () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      mutations: fixture.mutations,
      items: [_comicWithRelease('comic-release-1')],
      target: LibraryAddTarget.owned,
      referenceType: LibraryAddReferenceType.release,
    );

    final ownedRows = await fixture.db.select(fixture.db.ownedItemsCache).get();

    expect(ownedRows.single.itemId, 'comic-release-1');
    expect(
      ownedRows.single.anchorType,
      PersonalItemAnchorType.edition.apiValue,
    );
    expect(ownedRows.single.editionId, 'edition-1');
    expect(ownedRows.single.variantId, isNull);
  });

  test('adds release-referenced wishlist item using an explicit edition variant',
      () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      mutations: fixture.mutations,
      items: [_comicWithMultipleReleases('comic-release-2')],
      target: LibraryAddTarget.wishlist,
      referenceType: LibraryAddReferenceType.release,
      releaseSelectionsByItemId: const {
        'comic-release-2': LibraryAddReleaseSelection(
          editionId: 'edition-2',
          variantId: 'variant-2b',
        ),
      },
    );

    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();

    expect(
      wishlistRows.single.anchorType,
      PersonalItemAnchorType.variant.apiValue,
    );
    expect(wishlistRows.single.editionId, 'edition-2');
    expect(wishlistRows.single.variantId, 'variant-2b');
  });

  test('adds wishlist item against a bundle release anchor', () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      mutations: fixture.mutations,
      items: [_comic('comic-bundle-1')],
      target: LibraryAddTarget.wishlist,
      referenceType: LibraryAddReferenceType.bundleRelease,
      bundleReleaseIdsByItemId: const {'comic-bundle-1': 'bundle-1'},
    );

    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();

    expect(
      wishlistRows.single.anchorType,
      PersonalItemAnchorType.bundleRelease.apiValue,
    );
    expect(wishlistRows.single.bundleReleaseId, 'bundle-1');
  });

  test('adds tracking-only entry when target is track', () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      mutations: fixture.mutations,
      items: [_comic('comic-track-1')],
      target: LibraryAddTarget.track,
      defaults: const LibraryAddDefaults(readStatus: 'reading'),
      referenceType: LibraryAddReferenceType.bundleRelease,
      bundleReleaseIdsByItemId: const {'comic-track-1': 'bundle-ignored'},
    );

    final ownedRows = await fixture.db.select(fixture.db.ownedItemsCache).get();
    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();
    final trackingRows =
        await fixture.db.select(fixture.db.trackingEntriesCache).get();

    expect(ownedRows, isEmpty);
    expect(wishlistRows, isEmpty);
    expect(trackingRows.single.itemId, 'comic-track-1');
    expect(trackingRows.single.status, 'reading');
  });

  test('adds tracking-only entry when target is track without status', () async {
    final fixture = _WorkflowFixture();
    addTearDown(fixture.dispose);

    await addLibraryItemsToTarget(
      catalog: fixture.catalog,
      mutations: fixture.mutations,
      items: [_comic('comic-track-empty-1')],
      target: LibraryAddTarget.track,
      defaults: const LibraryAddDefaults(),
    );

    final ownedRows = await fixture.db.select(fixture.db.ownedItemsCache).get();
    final wishlistRows =
        await fixture.db.select(fixture.db.wishlistItemsCache).get();
    final trackingRows =
        await fixture.db.select(fixture.db.trackingEntriesCache).get();

    expect(ownedRows, isEmpty);
    expect(wishlistRows, isEmpty);
    expect(trackingRows.single.itemId, 'comic-track-empty-1');
    expect(trackingRows.single.status, isNull);
  });
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

  CatalogCacheRepository get catalog => CatalogCacheRepository(db);

  CollectionMutations get mutations => container.read(
        collectionMutationsProvider,
      );

  void dispose() {
    container.dispose();
    db.close();
  }
}

LibraryMetadataItem _comic(String id) {
  return LibraryMetadataItem.fromCatalogItem(
    CatalogItem(
      id: id,
      kind: 'comic',
      title: 'Superman, Vol. 4',
      itemNumber: '8A',
      publisher: 'DC',
      releaseYear: 2016,
      barcode: '76194134192700811',
    ),
  );
}

LibraryMetadataItem _comicWithRelease(String id) {
  return LibraryMetadataItem.fromCatalogItem(
    CatalogItem(
      id: id,
      kind: 'comic',
      title: 'Batman #1',
      itemNumber: '1',
      publisher: 'DC',
      editions: const [
        CatalogEdition(
          id: 'edition-1',
          title: 'Direct Edition',
          physicalFormat: 'single_issue',
          physicalFormatLabel: 'Single Issue',
          variants: [
            CatalogVariant(
              id: 'variant-1',
              name: 'Cover A',
              variantType: 'cover',
              isPrimary: true,
            ),
          ],
        ),
      ],
    ),
  );
}

LibraryMetadataItem _digitalMovie(String id) {
  return LibraryMetadataItem.fromCatalogItem(
    CatalogItem(
      id: id,
      kind: 'movie',
      title: 'Akira',
      publisher: 'GKIDS',
      physicalFormat: 'digital',
      physicalFormatLabel: 'Digital',
    ),
  );
}

LibraryMetadataItem _comicWithMultipleReleases(String id) {
  return LibraryMetadataItem.fromCatalogItem(
    CatalogItem(
      id: id,
      kind: 'comic',
      title: 'Detective Comics #27',
      itemNumber: '27',
      publisher: 'DC',
      editions: const [
        CatalogEdition(
          id: 'edition-1',
          title: 'Standard Edition',
          physicalFormat: 'single_issue',
          physicalFormatLabel: 'Single Issue',
          variants: [
            CatalogVariant(
              id: 'variant-1',
              name: 'Cover A',
              variantType: 'cover',
              isPrimary: true,
            ),
          ],
        ),
        CatalogEdition(
          id: 'edition-2',
          title: 'Collector Edition',
          physicalFormat: 'single_issue',
          physicalFormatLabel: 'Collector Issue',
          variants: [
            CatalogVariant(
              id: 'variant-2a',
              name: 'Foil Cover',
              variantType: 'foil',
            ),
            CatalogVariant(
              id: 'variant-2b',
              name: 'Sketch Cover',
              variantType: 'sketch',
              isPrimary: true,
            ),
          ],
        ),
      ],
    ),
  );
}
