import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_lifecycle_ref.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_item_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_actions.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:collectarr_app/features/library/selection/library_bulk_edit_dialog.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../helpers/test_data_factories.dart';
import '../../../../helpers/tracking_lifecycle_test_helpers.dart';

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

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final wishlistMutations = container.read(wishlistMutationsProvider);
    final trackingMutations = container.read(trackingMutationsProvider);
    LibraryBulkActions buildActions() => LibraryBulkActions(
          coordinator: coordinator,
          ownedMutations: container.read(ownedItemMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
        );

    await coordinator.addOwnedItem(
      typedAddOwnedItemCommand(
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        common: const LibraryAddCommonDraft(locationId: 'loc-a'),
        details: const MovieOwnedDetailsDraft(),
      ),
    );

    final row = (await MovieOwnedRepository(db).listActive()).single;
    final actions = buildActions();

    await actions.editSelected(
      entries: [
        ShelfEntry(
          itemId: 'movie-1',
          ownedSummary: MovieOwnedItemProjection.toSummary(row),
          typedOwnedItem: row,
        ),
      ],
      selection: const LibraryBulkEditSelection(
        applyLocation: true,
        locationId: 'loc-b',
      ),
    );

    final updated = (await MovieOwnedRepository(db).listActive()).single;
    expect(updated.locationId, 'loc-b');
  });

  test('moveSelectedToWishlist creates wishlist rows and tombstones owned rows',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final wishlistMutations = container.read(wishlistMutationsProvider);
    final trackingMutations = container.read(trackingMutationsProvider);
    LibraryBulkActions buildActions() => LibraryBulkActions(
          coordinator: coordinator,
          ownedMutations: container.read(ownedItemMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
        );

    await coordinator.addOwnedItem(
      typedAddOwnedItemCommand(
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        common: const LibraryAddCommonDraft(),
        details: const MovieOwnedDetailsDraft(),
      ),
    );

    final row = (await MovieOwnedRepository(db).listActive()).single;
    final actions = buildActions();

    await actions.moveSelectedToWishlist([
      ShelfEntry(
        itemId: 'movie-1',
        ownedSummary: MovieOwnedItemProjection.toSummary(row),
        typedOwnedItem: row,
      ),
    ]);

    final deletedOwned =
        await MovieOwnedRepository(db).findById(MovieOwnedItemId(row.id.value));
    final wishlistRows = await db.select(db.wishlistItemsCache).get();

    expect(deletedOwned?.deletedAt, isNotNull);
    expect(wishlistRows, hasLength(1));
    expect(
      CatalogEntityRef.fromJson(
        jsonDecode(wishlistRows.single.catalogRefJson) as Map<String, dynamic>,
      ).id,
      'movie-1',
    );
    expect(wishlistRows.single.deletedAt, isNull);
  });

  test('removeSelected clears owned, wishlist, and tracked-only selections',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final wishlistMutations = container.read(wishlistMutationsProvider);
    final trackingMutations = container.read(trackingMutationsProvider);
    LibraryBulkActions buildActions() => LibraryBulkActions(
          coordinator: coordinator,
          ownedMutations: container.read(ownedItemMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
        );

    await coordinator.addOwnedItem(
      typedAddOwnedItemCommand(
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        common: const LibraryAddCommonDraft(),
        details: const MovieOwnedDetailsDraft(),
      ),
    );
    await wishlistMutations.addToWishlist(
      testCatalogRef('movie-2', kind: 'movie'),
    );
    await trackingMutations.upsertTrackingLifecycle(
      TrackingTarget.catalog(testCatalogRef('movie-3', kind: 'movie')),
      sourceType: TrackingSourceType.streaming,
      status: MediaTrackingStatus.completed,
    );

    final ownedRow = (await MovieOwnedRepository(db).listActive()).single;
    final wishlistRow = await db.select(db.wishlistItemsCache).getSingle();
    final trackingRow = (await readTrackingLifecycles(db))
        .firstWhere((row) => row.catalogRef.id == 'movie-3');
    final actions = buildActions();

    await actions.removeSelected([
      ShelfEntry(
        itemId: 'movie-1',
        ownedSummary: MovieOwnedItemProjection.toSummary(ownedRow),
        typedOwnedItem: ownedRow,
      ),
      ShelfEntry(
        itemId: 'movie-2',
        wishlistItem: WishlistItem(
          id: wishlistRow.id,
          catalogRef: CatalogEntityRef.fromJson(
            jsonDecode(wishlistRow.catalogRefJson) as Map<String, dynamic>,
          ),
          createdAt: wishlistRow.createdAt,
          updatedAt: wishlistRow.updatedAt,
        ),
      ),
      ShelfEntry(
        itemId: 'movie-3',
        trackingSummary: TrackingSummary(
          id: trackingRow.id,
          catalogRef: trackingRow.catalogRef,
          ownedRef: trackingRow.ownedRef,
          sourceType:
              trackingSourceTypeFromValue(trackingRow.sourceTypeApiValue),
          status:
              mediaTrackingStatusFromValue(trackingRow.statusStorageValue) ??
                  MediaTrackingStatus.none,
          rating: trackingRow.rating,
          startedAt: trackingRow.startedAt,
          completedAt: trackingRow.finishedAt,
          notes: trackingRow.notes,
          updatedAt: trackingRow.updatedAt,
          deletedAt: trackingRow.deletedAt,
        ),
      ),
    ]);

    final deletedOwned = await MovieOwnedRepository(db)
        .findById(MovieOwnedItemId(ownedRow.id.value));
    final wishlistRows = await db.select(db.wishlistItemsCache).get();
    final deletedTracking = await trackingLifecycleTestRepository(db).findByRef(
      TrackingLifecycleRef(kind: CatalogMediaKind.movie, id: trackingRow.id),
    );

    expect(deletedOwned?.deletedAt, isNotNull);
    expect(wishlistRows.single.deletedAt, isNotNull);
    expect(
      deletedTracking?.deletedAt,
      isNotNull,
    );
  });

  test('moveSelectedToOwned keeps unrelated release wishlists active',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final wishlistMutations = container.read(wishlistMutationsProvider);
    final trackingMutations = container.read(trackingMutationsProvider);
    LibraryBulkActions buildActions() => LibraryBulkActions(
          coordinator: coordinator,
          ownedMutations: container.read(ownedItemMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
        );

    await wishlistMutations.addToWishlist(
      const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: const CatalogEntityTypeId('edition'),
        id: 'edition-4k',
        rootId: 'movie-1',
      ),
    );
    await wishlistMutations.addToWishlist(
      const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: const CatalogEntityTypeId('edition'),
        id: 'edition-bluray',
        rootId: 'movie-1',
      ),
    );

    final rows = await db.select(db.wishlistItemsCache).get();
    final row4k = rows.firstWhere(
      (row) =>
          CatalogEntityRef.fromJson(
            jsonDecode(row.catalogRefJson) as Map<String, dynamic>,
          ).id ==
          'edition-4k',
    );
    final actions = buildActions();

    await actions.moveSelectedToOwned([
      ShelfEntry(
        itemId: 'movie-1',
        catalogItem:
            testCatalogItem(id: 'movie-1', kind: 'movie').asShelfCatalogItem,
        wishlistItem: WishlistItem(
          id: row4k.id,
          catalogRef: CatalogEntityRef.fromJson(
            jsonDecode(row4k.catalogRefJson) as Map<String, dynamic>,
          ),
          createdAt: row4k.createdAt,
          updatedAt: row4k.updatedAt,
        ),
      ),
    ]);

    final ownedRows = await MovieOwnedRepository(db).listActive();
    final wishlistRows = await db.select(db.wishlistItemsCache).get();
    final activeWishlistRows =
        wishlistRows.where((row) => row.deletedAt == null).toList();

    expect(ownedRows, hasLength(1));
    expect(ownedRows.single.targetRef?.id, 'edition-4k');
    expect(activeWishlistRows, hasLength(1));
    expect(
      CatalogEntityRef.fromJson(
        jsonDecode(activeWishlistRows.single.catalogRefJson)
            as Map<String, dynamic>,
      ).id,
      'edition-bluray',
    );
  });
}
