import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/library_add_collection_workflow.dart';
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
    expect(syncRows.map((row) => row.entityType), contains('owned_item'));
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
