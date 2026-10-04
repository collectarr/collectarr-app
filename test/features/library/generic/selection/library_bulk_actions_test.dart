import 'dart:convert';

import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/tracking_state_ref.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/entries/movie_entry_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_entry_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_library_entry_projection.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
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
import '../../../../helpers/tracking_state_test_helpers.dart';

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
          entryMutations: container.read(libraryEntryMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          catalogSnapshots: CatalogSnapshotRepository(db),
        );

    await coordinator.addLibraryEntry(
      typedAddLibraryEntryCommand(
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        common: const LibraryAddCommonDraft(locationId: 'loc-a'),
        details: const MovieEntryDetailsDraft(),
      ),
    );

    final row = (await MovieEntryRepository(db).listActive()).single;
    final actions = buildActions();

    await actions.editSelected(
      entries: [
        LibraryWorkspaceSource(
          itemId: 'movie-1',
          libraryEntrySummary: MovieLibraryEntryProjection.toSummary(row),
          libraryEntryDispatch: testMovieLibraryEntryDispatchFrom(row),
        ),
      ],
      selection: const LibraryBulkEditSelection(
        applyLocation: true,
        locationId: 'loc-b',
      ),
    );

    final updated = (await MovieEntryRepository(db).listActive()).single;
    expect(updated.locationId, 'loc-b');
  });

  test('moveSelectedToWishlist creates wishlist rows and tombstones entry rows',
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
          entryMutations: container.read(libraryEntryMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          catalogSnapshots: CatalogSnapshotRepository(db),
        );

    await coordinator.addLibraryEntry(
      typedAddLibraryEntryCommand(
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        common: const LibraryAddCommonDraft(),
        details: const MovieEntryDetailsDraft(),
      ),
    );

    final row = (await MovieEntryRepository(db).listActive()).single;
    final actions = buildActions();

    await actions.moveSelectedToWishlist([
      LibraryWorkspaceSource(
        itemId: 'movie-1',
        libraryEntrySummary: MovieLibraryEntryProjection.toSummary(row),
        libraryEntryDispatch: testMovieLibraryEntryDispatchFrom(row),
      ),
    ]);

    final deletedEntry =
        await MovieEntryRepository(db).findById(LibraryEntryId(row.id.value));
    final wishlistRows = await db.select(db.wishlistItemsCache).get();

    expect(deletedEntry?.deletedAt, isNotNull);
    expect(wishlistRows, hasLength(1));
    expect(
      CatalogEntityRef.fromJson(
        jsonDecode(wishlistRows.single.catalogRefJson) as Map<String, dynamic>,
      ).id,
      'movie-1',
    );
    expect(wishlistRows.single.deletedAt, isNull);
  });

  test('removeSelected clears entry, wishlist, and tracked-only selections',
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
          entryMutations: container.read(libraryEntryMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          catalogSnapshots: CatalogSnapshotRepository(db),
        );

    await coordinator.addLibraryEntry(
      typedAddLibraryEntryCommand(
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        common: const LibraryAddCommonDraft(),
        details: const MovieEntryDetailsDraft(),
      ),
    );
    await wishlistMutations.addToWishlist(
      testCatalogRef('movie-2', kind: 'movie'),
    );
    await trackingMutations.upsertTrackingState(
      TrackingTarget.catalog(testCatalogRef('movie-3', kind: 'movie')),
      sourceType: TrackingSourceType.streaming,
      status: MediaTrackingStatus.completed,
    );

    final entryRow = (await MovieEntryRepository(db).listActive()).single;
    final wishlistRow = await db.select(db.wishlistItemsCache).getSingle();
    final trackingRow = (await readTrackingStates(db))
        .firstWhere((row) => row.catalogRef.id == 'movie-3');
    final actions = buildActions();

    await actions.removeSelected([
      LibraryWorkspaceSource(
        itemId: 'movie-1',
        libraryEntrySummary: MovieLibraryEntryProjection.toSummary(entryRow),
        libraryEntryDispatch: testMovieLibraryEntryDispatchFrom(entryRow),
      ),
      LibraryWorkspaceSource(
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
      LibraryWorkspaceSource(
        itemId: 'movie-3',
        trackingSummary: TrackingSummary(
          id: trackingRow.id,
          catalogRef: trackingRow.catalogRef,
          libraryEntryRef: trackingRow.libraryEntryRef,
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

    final deletedEntry = await MovieEntryRepository(db)
        .findById(LibraryEntryId(entryRow.id.value));
    final wishlistRows = await db.select(db.wishlistItemsCache).get();
    final deletedTracking =
        await trackingRecordTestRepository(db).findStorageRecordByRef(
      TrackingStateRef(kind: CatalogMediaKind.movie, id: trackingRow.id),
    );

    expect(deletedEntry?.deletedAt, isNotNull);
    expect(wishlistRows.single.deletedAt, isNotNull);
    expect(
      deletedTracking?.deletedAt,
      isNotNull,
    );
  });

  test('moveSelectedToEntry keeps unrelated release wishlists active',
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
          entryMutations: container.read(libraryEntryMutationsProvider),
          wishlistMutations: wishlistMutations,
          trackingMutations: trackingMutations,
          catalogSnapshots: CatalogSnapshotRepository(db),
        );

    await wishlistMutations.addToWishlist(
      const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId('edition'),
        id: 'edition-4k',
        rootId: 'movie-1',
      ),
    );
    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'movie-1', kind: 'movie'),
    ]);
    await wishlistMutations.addToWishlist(
      const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId('edition'),
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

    await actions.moveSelectedToEntry([
      LibraryWorkspaceSource(
        itemId: 'movie-1',
        catalogData: testWorkspaceCatalogData(
            testCatalogItem(id: 'movie-1', kind: 'movie').asShelfCatalogItem),
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

    final entryRows = await MovieEntryRepository(db).listActive();
    final wishlistRows = await db.select(db.wishlistItemsCache).get();
    final activeWishlistRows =
        wishlistRows.where((row) => row.deletedAt == null).toList();

    expect(entryRows, hasLength(1));
    expect(entryRows.single.targetRef?.id, 'edition-4k');
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
