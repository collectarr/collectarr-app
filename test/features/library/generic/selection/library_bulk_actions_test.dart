import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helpers/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('bulk edit applies structured location ids', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-a',
            name: 'Shelf A',
            sortOrder: const Value(1),
          ),
        );
    await db.into(db.locationsCache).insert(
          LocationsCacheCompanion.insert(
            id: 'loc-b',
            name: 'Shelf B',
            sortOrder: const Value(2),
          ),
        );

    final mutations = container.read(collectionMutationsProvider);
    await mutations.addItem(
      'movie-1',
      locationId: 'loc-a',
    );

    final row = await db.select(db.ownedItemsCache).getSingle();
    final owned = testOwnedItem(
      id: row.id,
      itemId: row.itemId,
      locationId: row.locationId,
      updatedAt: row.updatedAt,
    );
    final actions = LibraryBulkActions(mutations);

    await actions.editSelected(
      entries: [ShelfEntry(itemId: 'movie-1', ownedItem: owned)],
      selection: const LibraryBulkEditSelection(
        applyLocation: true,
        locationId: 'loc-b',
      ),
    );

    final updated = await db.select(db.ownedItemsCache).getSingle();
    expect(updated.locationId, 'loc-b');
  });

  test('moveSelectedToWishlist creates wishlist rows and tombstones owned rows', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final mutations = container.read(collectionMutationsProvider);
    await mutations.addItem('movie-1');

    final row = await db.select(db.ownedItemsCache).getSingle();
    final owned = testOwnedItem(
      id: row.id,
      itemId: row.itemId,
      updatedAt: row.updatedAt,
    );
    final actions = LibraryBulkActions(mutations);

    await actions.moveSelectedToWishlist([
      ShelfEntry(itemId: 'movie-1', ownedItem: owned),
    ]);

    final ownedRows = await db.select(db.ownedItemsCache).get();
    final wishlistRows = await db.select(db.wishlistItemsCache).get();

    expect(ownedRows.single.deletedAt, isNotNull);
    expect(wishlistRows, hasLength(1));
    expect(wishlistRows.single.itemId, 'movie-1');
    expect(wishlistRows.single.deletedAt, isNull);
  });

  test('removeSelected clears owned, wishlist, and tracked-only selections', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final mutations = container.read(collectionMutationsProvider);
    await mutations.addItem('movie-1');
    await mutations.addToWishlist('movie-2');
    await mutations.upsertTrackingEntry(
      'movie-3',
      sourceType: 'streaming',
      status: 'completed',
    );

    final ownedRow = await db.select(db.ownedItemsCache).getSingle();
    final wishlistRow = await db.select(db.wishlistItemsCache).getSingle();
    final trackingRow = await db.select(db.trackingEntriesCache).getSingle();
    final actions = LibraryBulkActions(mutations);

    await actions.removeSelected([
      ShelfEntry(
        itemId: 'movie-1',
        ownedItem: testOwnedItem(
          id: ownedRow.id,
          itemId: ownedRow.itemId,
          updatedAt: ownedRow.updatedAt,
        ),
      ),
      ShelfEntry(
        itemId: 'movie-2',
        wishlistItem: WishlistItem(
          id: wishlistRow.id,
          catalogRef: testCatalogRef(wishlistRow.itemId, kind: 'movie'),
          createdAt: wishlistRow.createdAt,
          updatedAt: wishlistRow.updatedAt,
        ),
      ),
      ShelfEntry(
        itemId: 'movie-3',
        trackingEntry: TrackingEntry(
          id: trackingRow.id,
          catalogRef: testCatalogRef(trackingRow.itemId, kind: 'movie'),
          ownedItemId: trackingRow.ownedItemId,
          editionId: trackingRow.editionId,
          variantId: trackingRow.variantId,
          bundleReleaseId: trackingRow.bundleReleaseId,
          sourceType: trackingRow.sourceType,
          status: trackingRow.status,
          rating: trackingRow.rating,
          startedAt: trackingRow.startedAt,
          finishedAt: trackingRow.finishedAt,
          progressCurrent: trackingRow.progressCurrent,
          progressTotal: trackingRow.progressTotal,
          timesCompleted: trackingRow.timesCompleted,
          notes: trackingRow.notes,
          seasonNumber: trackingRow.seasonNumber,
          episodeNumber: trackingRow.episodeNumber,
          updatedAt: trackingRow.updatedAt,
          deletedAt: trackingRow.deletedAt,
        ),
      ),
    ]);

    final ownedRows = await db.select(db.ownedItemsCache).get();
    final wishlistRows = await db.select(db.wishlistItemsCache).get();
    final trackingRows = await db.select(db.trackingEntriesCache).get();

    expect(ownedRows.single.deletedAt, isNotNull);
    expect(wishlistRows.single.deletedAt, isNotNull);
    expect(trackingRows.single.deletedAt, isNotNull);
  });

  test('moveSelectedToOwned keeps unrelated release wishlists active', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final mutations = container.read(collectionMutationsProvider);
    await mutations.addToWishlist('movie-1', editionId: 'edition-4k');
    await mutations.addToWishlist('movie-1', editionId: 'edition-bluray');

    final rows = await db.select(db.wishlistItemsCache).get();
    final row4k = rows.firstWhere((row) => row.editionId == 'edition-4k');
    final actions = LibraryBulkActions(mutations);

    await actions.moveSelectedToOwned([
      ShelfEntry(
        itemId: 'movie-1',
        wishlistItem: WishlistItem(
          id: row4k.id,
          catalogRef: testCatalogRef(row4k.itemId, kind: 'movie'),
          anchorType: row4k.anchorType,
          editionId: row4k.editionId,
          variantId: row4k.variantId,
          bundleReleaseId: row4k.bundleReleaseId,
          createdAt: row4k.createdAt,
          updatedAt: row4k.updatedAt,
        ),
      ),
    ]);

    final ownedRows = await db.select(db.ownedItemsCache).get();
    final wishlistRows = await db.select(db.wishlistItemsCache).get();
    final activeWishlistRows =
        wishlistRows.where((row) => row.deletedAt == null).toList();

    expect(ownedRows, hasLength(1));
    expect(ownedRows.single.editionId, 'edition-4k');
    expect(activeWishlistRows, hasLength(1));
    expect(activeWishlistRows.single.editionId, 'edition-bluray');
  });
}
