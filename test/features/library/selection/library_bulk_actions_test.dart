import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
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
      storageBox: 'Legacy shelf',
      locationId: 'loc-a',
    );

    final row = await db.select(db.ownedItemsCache).getSingle();
    final owned = OwnedItem(
      id: row.id,
      itemId: row.itemId,
      storageBox: row.storageBox,
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
    expect(updated.storageBox, isNull);
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
    final owned = OwnedItem(
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

  test('removeSelected clears both owned and wishlist selections', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final mutations = container.read(collectionMutationsProvider);
    await mutations.addItem('movie-1');
    await mutations.addToWishlist('movie-2');

    final ownedRow = await db.select(db.ownedItemsCache).getSingle();
    final wishlistRow = await db.select(db.wishlistItemsCache).getSingle();
    final actions = LibraryBulkActions(mutations);

    await actions.removeSelected([
      ShelfEntry(
        itemId: 'movie-1',
        ownedItem: OwnedItem(
          id: ownedRow.id,
          itemId: ownedRow.itemId,
          updatedAt: ownedRow.updatedAt,
        ),
      ),
      ShelfEntry(
        itemId: 'movie-2',
        wishlistItem: WishlistItem(
          id: wishlistRow.id,
          itemId: wishlistRow.itemId,
          createdAt: wishlistRow.createdAt,
          updatedAt: wishlistRow.updatedAt,
        ),
      ),
    ]);

    final ownedRows = await db.select(db.ownedItemsCache).get();
    final wishlistRows = await db.select(db.wishlistItemsCache).get();

    expect(ownedRows.single.deletedAt, isNotNull);
    expect(wishlistRows.single.deletedAt, isNotNull);
  });
}