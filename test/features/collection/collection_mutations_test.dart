import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/settings/connection_settings.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/features/library/ownership/collection_items_repository.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/collection/commands/collection_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_details_draft.dart';
import 'package:collectarr_app/features/library/kinds/movie/ownership/movie_owned_details_draft.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv_codec.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_collection_item_create_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_collection_item_update_payload.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/book/domain/book_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/book/data/book_owned_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_collection_item.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_owned_repository.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/connection_settings_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import '../../helpers/tracking_state_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('collection mutations enqueue personal sync changes', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(collectionItemMutationsProvider).addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              condition: 'Near Mint',
            ),
            grade: '9.8',
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    final queued = (await db.select(db.syncQueue).get())
        .where((row) => row.entityType == 'collection_item')
        .toList();
    final owned =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');
    expect(owned.catalogRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(owned.catalogRef.id, 'comic-1');
    expect(queued, hasLength(1));
    expect(queued.single.entityType, 'collection_item');
    expect(queued.single.action, 'upsert');
  });

  test('collection add prefers the kind-owned create payload over defaults',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(collectionItemMutationsProvider).addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('comic-typed-payload', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              condition: 'Default condition',
            ),
            details: const ComicOwnedDetailsDraft(),
            typedPayload: ComicCollectionItemCreatePayload(
              catalogRef: testCatalogRef('comic-typed-payload', kind: 'comic'),
              details: const ComicOwnedDetailsDraft(),
              condition: 'Typed condition',
              purchaseStore: 'Typed store',
              collectionStatus: 'Complete',
            ),
          ),
        );

    final owned = await _typedOwnedForCatalog<ComicCollectionItem>(
      db,
      'comic-typed-payload',
    );
    expect(owned.condition, 'Typed condition');
    expect(owned.purchaseStore, 'Typed store');
    expect(owned.collectionStatus, 'Complete');
  });

  test(
      'collection mutations stamp collection item createdAt and owner identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        authControllerProvider.overrideWith(
          () => _CollectionItemAuthController(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(collectionItemMutationsProvider).addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('movie-1', kind: 'movie'),
            common: const LibraryAddCommonDraft(),
            details: const MovieOwnedDetailsDraft(),
          ),
        );

    final owned =
        await _typedOwnedForCatalog<MovieCollectionItem>(db, 'movie-1');
    final queued = await db.select(db.syncQueue).getSingle();

    expect(owned.createdAt, isNotNull);
    expect(owned.ownerUserId, 'user-1');
    expect(owned.ownerLabel, 'owner@example.com');
    expect(queued.payloadJson, contains('"created_at"'));
    expect(queued.payloadJson, contains('"owner_user_id":"user-1"'));
    expect(queued.payloadJson, contains('"owner_label":"owner@example.com"'));
  });

  test('collection mutations request sync scheduler after local changes',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    late _SpySyncController syncController;
    final container = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        connectionSettingsProvider.overrideWith(
          _OnlineFirstConnectionSettingsController.new,
        ),
        syncControllerProvider.overrideWith(
          () => syncController = _SpySyncController(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(collectionItemMutationsProvider).addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(),
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    // The mutation runner schedules online-first sync without awaiting it.
    await Future<void>.delayed(Duration.zero);
    expect(syncController.syncNowRequests, 1);
  });

  test('catalog refresh preserves personal collection data', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'comic-1', kind: 'comic', title: 'Original'),
    ]);
    await container
        .read(collectionCommandCoordinatorProvider)
        .addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              condition: 'Near Mint',
            ),
            tracking: const CollectionItemTrackingDraft(rating: 8),
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    await container.read(catalogTransportMutationsProvider).upsertTransport(
          CatalogSearchCandidate.fromItem(testCatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Updated',
            synopsis: 'Refreshed metadata',
          )).kindCapability.toImportTransport(),
        );

    final owned =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');
    final tracking = await readSingleTrackingState(db);
    final catalog = await CatalogSnapshotRepository(db).findByRef(
      const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'comic-1',
      ),
    );

    expect(owned.condition, 'Near Mint');
    expect(tracking.rating, 8);
    expect(catalog?.title, 'Updated');
  });

  test('collection mutations mirror tracking into tracking entries', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container
        .read(collectionCommandCoordinatorProvider)
        .addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('movie-1', kind: 'movie'),
            common: LibraryAddCommonDraft(),
            tracking: CollectionItemTrackingDraft(
              status: MediaTrackingStatus.completed,
              rating: 8,
              startedAt: DateTime.utc(2026, 5, 10),
              finishedAt: DateTime.utc(2026, 5, 12),
            ),
            details: const MovieOwnedDetailsDraft(),
          ),
        );

    final owned =
        await _typedOwnedForCatalog<MovieCollectionItem>(db, 'movie-1');
    final tracking = await readSingleTrackingState(db);
    final queued = await db.select(db.syncQueue).get();

    expect(
      tracking.catalogRef.id,
      'movie-1',
    );
    expect(
      tracking.collectionItemRef?.key,
      CollectionItemRef.fromKey('movie:${owned.id.value}').key,
    );
    expect(tracking.sourceTypeApiValue, 'physical');
    expect(tracking.statusStorageValue, 'Completed');
    expect(tracking.rating, 8);
    expect(
      queued.where((row) => row.entityType == 'tracking_entry'),
      hasLength(1),
    );
  });

  test('collection mutations infer digital ownership from catalog snapshots',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'movie-digital-1',
        kind: 'movie',
        title: 'Ghost in the Shell',
        physicalFormat: 'digital',
        physicalFormatLabel: 'Digital',
      ),
    ]);

    await container
        .read(collectionCommandCoordinatorProvider)
        .addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('movie-digital-1', kind: 'movie'),
            common: const LibraryAddCommonDraft(isDigital: true),
            tracking: const CollectionItemTrackingDraft(
              status: MediaTrackingStatus.completed,
              rating: 9,
            ),
            details: const MovieOwnedDetailsDraft(),
          ),
        );

    final owned = await _typedOwnedForCatalog<MovieCollectionItem>(
      db,
      'movie-digital-1',
    );
    final tracking = await readSingleTrackingState(db);

    expect(owned.isDigital, isTrue);
    expect(tracking.sourceTypeApiValue, TrackingSourceType.digital.apiValue);
  });

  test('collection mutations can sync owned tracking entries directly',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final owned = await container
        .read(collectionCommandCoordinatorProvider)
        .addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('movie-2', kind: 'movie'),
            common: const LibraryAddCommonDraft(),
            details: const MovieOwnedDetailsDraft(),
          ),
          syncTracking: false,
        );
    await container.read(trackingMutationsProvider).syncOwnedTrackingState(
          owned,
          targetRef: const CatalogEntityRef(
            kind: CatalogMediaKind.movie,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'movie-2',
          ),
          status: MediaTrackingStatus.completed,
          rating: 10,
          startedAt: DateTime.utc(2026, 5, 20),
          finishedAt: DateTime.utc(2026, 5, 21),
        );

    final tracking = await readSingleTrackingState(db);
    final queued = await db.select(db.syncQueue).get();
    final trackingRef = tracking.catalogRef;

    expect(tracking.collectionItemRef?.key, owned.key);
    expect(trackingRef.entityType, CatalogEntityTypeId.catalogItem);
    expect(trackingRef.id, 'movie-2');
    expect(tracking.statusStorageValue, 'Completed');
    expect(tracking.rating, 10);
    expect(
      queued.where((row) => row.entityType == 'tracking_entry'),
      hasLength(1),
    );
  });

  test('collection mutations can create tracking-only entries', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
          id: 'music-1', kind: 'music', title: 'Blessed & Possessed'),
    ]);

    await container.read(trackingMutationsProvider).upsertTrackingState(
          TrackingTarget.catalog(
            const CatalogEntityRef(
              kind: CatalogMediaKind.music,
              entityType: CatalogEntityTypeId('release'),
              id: 'music-1-release',
              rootId: 'music-1',
            ),
          ),
          sourceType: TrackingSourceType.digital,
          status: MediaTrackingStatus.inProgress,
          rating: 7,
          progressCurrent: 6,
          progressTotal: 12,
          notes: 'Streaming copy',
        );

    final tracking = await readSingleTrackingState(db);
    final queued = await db.select(db.syncQueue).get();

    expect(
      tracking.catalogRef.id,
      'music-1-release',
    );
    expect(tracking.collectionItemRef, isNull);
    expect(tracking.sourceTypeApiValue, 'digital');
    expect(tracking.progress.current, 6);
    expect(
      queued.where((row) => row.entityType == 'tracking_entry'),
      hasLength(1),
    );
  });

  test('collection mutations reuse existing tracked-only entries', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'movie-1', kind: 'movie', title: 'Dune'),
    ]);

    final trackingRepository = trackingRecordTestRepository(db);
    await trackingRepository.upsertStorageRecord(
      trackingRepository.create(
        id: 'tracking-existing',
        catalogRef: testCatalogRef('movie-1', kind: 'movie'),
        sourceType: 'digital',
        status: 'Plan to watch',
        updatedAt: DateTime.utc(2026, 5, 23),
      ),
    );

    await container.read(trackingMutationsProvider).upsertTrackingState(
          TrackingTarget.catalog(testCatalogRef('movie-1', kind: 'movie')),
          sourceType: TrackingSourceType.digital,
          status: MediaTrackingStatus.inProgress,
          rating: 9,
        );

    final tracking = await readTrackingStates(db);
    expect(tracking, hasLength(1));
    expect(tracking.single.id, 'tracking-existing');
    expect(tracking.single.statusStorageValue, 'In progress');
    expect(tracking.single.rating, 9);
  });

  test('collection mutations canonicalize tracking source aliases', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(id: 'book-1', kind: 'book', title: 'Project Hail Mary'),
    ]);

    await container.read(trackingMutationsProvider).upsertTrackingState(
          TrackingTarget.catalog(testCatalogRef('book-1', kind: 'book')),
          sourceType: trackingSourceTypeFromValue('kindle'),
          status: mediaTrackingStatusFromValue('Reading'),
        );

    final tracking = await readSingleTrackingState(db);
    expect(tracking.sourceTypeApiValue, TrackingSourceType.digital.apiValue);
  });

  test('collection mutations enqueue catalog snapshots from cache', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Absolute Batman',
        itemNumber: '1',
        coverImageUrl: 'https://cdn.example/absolute.jpg',
        thumbnailImageUrl: 'https://cdn.example/absolute-thumb.jpg',
        publisher: 'DC',
        releaseYear: 2024,
      ),
    ]);

    await container.read(collectionItemMutationsProvider).addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(),
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    final queued = await db.select(db.syncQueue).get();
    final snapshot =
        queued.where((row) => row.entityType == 'catalog_item').single;
    // addCollectionItem enqueues the collection item, a structural catalog reference,
    // and auto-registers the publisher as a pick-list value.
    expect(queued, hasLength(3));
    expect(
      queued.where((row) => row.entityType == 'pick_list_value').length,
      1,
    );
    expect(snapshot.entityId, 'comic-1');
    expect(snapshot.payloadJson, contains('"id":"comic-1"'));
    expect(snapshot.payloadJson, contains('"kind":"comic"'));
    expect(snapshot.payloadJson, isNot(contains('Absolute Batman')));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(syncControllerProvider).pendingCount, 3);
  });

  test('collection updates can clear nullable personal details', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container
        .read(collectionCommandCoordinatorProvider)
        .addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: LibraryAddCommonDraft(
              condition: 'Near Mint',
              purchaseDate: DateTime.utc(2026, 5, 10),
              pricePaidCents: 1299,
              currency: 'USD',
              personalNotes: 'Signed copy',
            ),
            grade: '9.8',
            details: const ComicOwnedDetailsDraft(),
          ),
        );
    final original =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');

    await container
        .read(collectionCommandCoordinatorProvider)
        .updateCollectionItem(
          UpdateCollectionItemCommand(
            collectionItemRef: CollectionItemRef(
              kind: CatalogMediaKind.comic,
              id: CollectionItemId(original.id.value),
            ),
            payload: ComicCollectionItemUpdatePayload.partial(
              condition: const Patch.set('Near Mint'),
              grade: const Patch.set('9.8'),
              purchaseDate: const Patch.clear(),
              pricePaidCents: const Patch.clear(),
              currency: const Patch.clear(),
              personalNotes: const Patch.clear(),
            ),
          ),
        );

    final updated = await _typedOwned<ComicCollectionItem>(
      db,
      CollectionItemRef(
        kind: CatalogMediaKind.comic,
        id: CollectionItemId(original.id.value),
      ),
    );
    expect(updated.purchaseDate, isNull);
    expect(updated.pricePaidCents, isNull);
    expect(updated.currency, isNull);
    expect(updated.personalNotes, isNull);
  });

  test('collection updates can clear an existing location', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container
        .read(collectionCommandCoordinatorProvider)
        .addCollectionItem(
          typedAddCollectionItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const LibraryAddCommonDraft(
              locationId: 'loc-box-6',
            ),
            details: const ComicOwnedDetailsDraft(),
          ),
        );
    final original =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');

    await container
        .read(collectionCommandCoordinatorProvider)
        .updateCollectionItem(
          UpdateCollectionItemCommand(
            collectionItemRef: CollectionItemRef(
              kind: CatalogMediaKind.comic,
              id: CollectionItemId(original.id.value),
            ),
            payload: ComicCollectionItemUpdatePayload.partial(
              locationId: const Patch.clear(),
            ),
          ),
        );

    final updated = await _typedOwned<ComicCollectionItem>(
      db,
      CollectionItemRef(
        kind: CatalogMediaKind.comic,
        id: CollectionItemId(original.id.value),
      ),
    );
    expect(updated.locationId, isNull);
  });

  test('wishlist updates Catalog Item references and notes', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(wishlistMutationsProvider).addToWishlist(
          const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-1'),
        );
    final originalRow = await db.select(db.wishlistItemsCache).getSingle();
    final original = WishlistItem(
      id: originalRow.id,
      catalogRef: CatalogItemRef.fromJson(
        jsonDecode(originalRow.catalogRefJson) as Map<String, Object?>,
      ),
      targetPriceCents: originalRow.targetPriceCents,
      currency: originalRow.currency,
      notes: originalRow.notes,
      createdAt: originalRow.createdAt,
      updatedAt: originalRow.updatedAt,
      deletedAt: originalRow.deletedAt,
    );

    await container.read(wishlistMutationsProvider).updateWishlistItem(
          original,
          catalogRef: const CatalogItemRef(
            kind: CatalogMediaKind.movie,
            id: 'movie-bundle-1',
          ),
          targetPriceCents: 4599,
          currency: 'USD',
          notes: 'Wait for the steelbook bundle.',
        );

    final updated = await db.select(db.wishlistItemsCache).getSingle();
    final queued = await db.select(db.syncQueue).get();

    final updatedRef = CatalogItemRef.fromJson(
      jsonDecode(updated.catalogRefJson) as Map<String, Object?>,
    );
    expect(updatedRef.kind, CatalogMediaKind.movie);
    expect(updatedRef.id, 'movie-bundle-1');
    expect(updated.targetPriceCents, 4599);
    expect(updated.currency, 'USD');
    expect(updated.notes, 'Wait for the steelbook bundle.');
    expect(
        queued.where((row) => row.entityType == 'wishlist_item'), hasLength(1));
  });

  test('wishlist can contain multiple concrete Catalog Items', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final wishlistMutations = container.read(wishlistMutationsProvider);
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-4k'),
    );
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-bluray'),
    );

    final rows = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();

    expect(rows.where((row) => row.deletedAt == null), hasLength(2));
    expect(
      rows
          .where((row) => row.deletedAt == null)
          .map((row) => CatalogItemRef.fromJson(
                jsonDecode(row.catalogRefJson) as Map<String, Object?>,
              ).id)
          .toSet(),
      {'movie-4k', 'movie-bluray'},
    );
    expect(
        queued.where((row) => row.entityType == 'wishlist_item'), hasLength(2));
  });

  test('wishlist removal targets a single Catalog Item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final wishlistMutations = container.read(wishlistMutationsProvider);
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-4k'),
    );
    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.movie, id: 'movie-bluray'),
    );

    await wishlistMutations.removeFromWishlist(
      catalogRef: const CatalogItemRef(
        kind: CatalogMediaKind.movie,
        id: 'movie-4k',
      ),
    );

    final rows = await db.select(db.wishlistItemsCache).get();
    final activeRows = rows.where((row) => row.deletedAt == null).toList();
    final deletedRows = rows.where((row) => row.deletedAt != null).toList();

    expect(activeRows, hasLength(1));
    expect(
      CatalogItemRef.fromJson(
        jsonDecode(activeRows.single.catalogRefJson) as Map<String, Object?>,
      ).id,
      'movie-bluray',
    );
    expect(deletedRows, hasLength(1));
    expect(
      CatalogItemRef.fromJson(
        jsonDecode(deletedRows.single.catalogRefJson) as Map<String, Object?>,
      ).id,
      'movie-4k',
    );
  });

  test('collection import enqueues rows and refreshes pending count once',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          kindOwnedCells: ['9.8'],
          personal: CollectionImportPersonalValues(
            condition: 'Near Mint',
            pricePaidCents: 1299,
            currency: 'USD',
          ),
        ),
        const CollectionImportRow(
          itemId: 'comic-2',
          mediaKind: CatalogMediaKind.comic,
          status: 'wishlist',
        ),
      ],
    );

    final owned = await CollectionItemsRepository(db).listActiveSummaries();
    final typedOwned = await db.select(db.comicCollectionItemsRows).get();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 2);
    expect(owned, hasLength(1));
    expect(typedOwned, hasLength(1));
    expect(typedOwned.single.grade, '9.8');
    expect(wishlist, hasLength(1));
    // Rows without a complete kind-owned catalog projection must not create a
    // generic catalog snapshot as a side effect of importing Owned/Wishlist.
    expect(queued, hasLength(2));
    final ownedChanges =
        queued.where((row) => row.entityType == 'collection_item').toList();
    expect(ownedChanges, hasLength(1));
    final ownedPayload = jsonDecode(ownedChanges.single.payloadJson);
    expect(ownedPayload, isA<Map<String, dynamic>>());
    expect(ownedPayload, contains('catalog_ref'));
    expect(ownedPayload, isNot(contains('id')));
    expect(ownedPayload, isNot(contains('updated_at')));
    expect(container.read(syncControllerProvider).pendingCount, 2);
  });

  test('collection import moves existing wishlist rows to owned in one batch',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final wishlistMutations = container.read(wishlistMutationsProvider);
    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);

    await wishlistMutations.addToWishlist(
      const CatalogItemRef(kind: CatalogMediaKind.comic, id: 'comic-1'),
    );
    await importOrchestrator.importRows([
      const CollectionImportRow(
        itemId: 'comic-1',
        mediaKind: CatalogMediaKind.comic,
        status: 'owned',
      ),
    ]);

    final owned =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = (await db.select(db.syncQueue).get())
        .where((row) =>
            row.entityType == 'collection_item' ||
            row.entityType == 'wishlist_item' ||
            row.entityType == 'catalog_item')
        .toList();

    expect(owned, isNotNull);
    expect(wishlist.single.deletedAt, isNotNull);
    expect(queued, hasLength(3));
    expect(
        queued.where((row) => row.entityType == 'wishlist_item').single.action,
        'delete');
  });

  test('collection import resolves clz rows from local catalog cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '759606047161-52011',
      ),
    ]);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: '',
          status: 'owned',
          title: 'Different title from CSV',
          mediaKind: CatalogMediaKind.comic,
          kindCatalogCells: [
            '',
            'comic',
            'Different title from CSV',
            '520',
            '',
            '',
            '',
            '',
            '',
            '',
            '75960604716152011',
          ],
          kindOwnedCells: ['7.5'],
        ),
      ],
    );

    final owned =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');
    final typedOwned = await db.select(db.comicCollectionItemsRows).get();
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 1);
    expect(owned.itemId, 'comic-1');
    expect(owned.grade, '7.5');
    expect(typedOwned, hasLength(1));
    expect(
      queued.where((row) => row.entityType == 'catalog_item'),
      hasLength(1),
    );
  });

  test('collection import stores media-specific catalog fields from csv',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: 'movie-1',
          mediaKind: CatalogMediaKind.movie,
          status: 'owned',
          title: 'Blade Runner',
          kindCatalogCells: [
            'movie-1',
            'movie',
            'Blade Runner',
            'Final Cut',
            '4K UHD',
            'Final Cut 4K release',
            '4k-uhd',
            '4K UHD',
            '',
            '',
            '883929087129',
          ],
        ),
      ],
    );

    final catalog = await CatalogSnapshotRepository(db).findByRef(
      const CatalogEntityRef(
        kind: CatalogMediaKind.movie,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'movie-1',
      ),
    );
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 1);
    expect(catalog?.kind, 'movie');
    expect(catalog?.editionTitle, 'Final Cut 4K release');
    expect(catalog?.physicalFormat, '4k-uhd');
    expect(catalog?.physicalFormatLabel, '4K UHD');
    expect(
      queued.where((row) => row.entityType == 'catalog_item'),
      hasLength(1),
    );
  });

  test('collection import preserves universal owned fields from csv', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      [
        CollectionImportRow(
          itemId: 'book-owned-fields',
          mediaKind: CatalogMediaKind.book,
          status: 'owned',
          title: 'Imported book',
          kindOwnedCells: ['8.5'],
          personal: CollectionImportPersonalValues(
            condition: 'Very Good',
            purchaseDate: DateTime.utc(2026, 8, 1),
            pricePaidCents: 2599,
            currency: 'EUR',
            notes: 'Imported note',
            locationId: 'shelf-a',
            indexNumber: 12,
            tags: 'gift,read',
            soldAt: DateTime.utc(2026, 8, 15),
            sellPriceCents: 3199,
            soldTo: 'collector@example.test',
          ),
        ),
      ],
    );

    final owned = await _typedOwnedForCatalog<BookCollectionItem>(
      db,
      'book-owned-fields',
    );
    expect(imported, 1);
    expect(owned.itemId, 'book-owned-fields');
    expect(owned.condition, 'Very Good');
    expect(owned.grade, '8.5');
    expect(owned.purchaseDate?.toUtc(), DateTime.utc(2026, 8, 1));
    expect(owned.pricePaidCents, 2599);
    expect(owned.currency, 'EUR');
    expect(owned.personalNotes, 'Imported note');
    expect(owned.locationId, 'shelf-a');
    expect(owned.indexNumber, 12);
    expect(owned.tags, 'gift,read');
    expect(owned.soldAt?.toUtc(), DateTime.utc(2026, 8, 15));
    expect(owned.sellPriceCents, 3199);
    expect(owned.soldTo, 'collector@example.test');
  });

  test('collection import delegates kind-owned csv cells to Comic', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final csv = CollectionCsvCodec(profiles: collectionCsvKindProfiles);
    final ownedFixture = testCollectionItem(
      id: 'owned-comic-details',
      itemId: 'comic-owned-details',
      rawOrSlabbed: 'Slabbed',
      gradingCompany: 'CGC',
      graderNotes: 'Pressing preserved',
      signedBy: 'Artist',
      keyComic: true,
      keyReason: 'First appearance',
      coverPriceCents: 499,
    );
    final rows = csv.parse(
      csv.exportShelf([
        LibraryWorkspaceSource(
          itemId: 'comic-owned-details',
          catalogData: testWorkspaceCatalogData(testCatalogItemWithKindMetadata(
            testCatalogItem(
              id: 'comic-owned-details',
              kind: 'comic',
              title: 'Imported Comic',
            ),
          ).asShelfCatalogItem),
          collectionItemSummary: testCollectionItemSummary(ownedFixture),
          collectionItemDispatch: testComicCollectionItemDispatchFrom(
            testComicCollectionItemFrom(ownedFixture),
          ),
        ),
      ]),
    );

    await container.read(collectionImportOrchestratorProvider).importRows(rows);

    final owned = await _typedOwnedForCatalog<ComicCollectionItem>(
      db,
      'comic-owned-details',
    );
    final details = owned.details;
    expect(details.rawOrSlabbed, 'Slabbed');
    expect(details.gradingCompany, 'CGC');
    expect(details.graderNotes, 'Pressing preserved');
    expect(details.signedBy, 'Artist');
    expect(details.keyComic, isTrue);
    expect(details.keyReason, 'First appearance');
    expect(details.coverPriceCents, 499);
  });

  test('collection import uses media type when matching local catalog cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Dune',
        barcode: '1234567890',
      ),
      testCatalogItem(
        id: 'movie-1',
        kind: 'movie',
        title: 'Dune',
        barcode: '1234567890',
      ),
    ]);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: '',
          mediaKind: CatalogMediaKind.movie,
          status: 'owned',
          title: 'Dune',
          kindCatalogCells: [
            '',
            'movie',
            'Dune',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '1234567890',
          ],
        ),
      ],
    );

    final owned =
        await _typedOwnedForCatalog<MovieCollectionItem>(db, 'movie-1');
    expect(imported, 1);
    expect(owned.itemId, 'movie-1');
  });

  test(
      'collection import does not synthesize catalog metadata without kind cells',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: 'comic-without-projection',
          mediaKind: CatalogMediaKind.comic,
          title: 'Only a structural import row',
          status: 'owned',
        ),
      ],
    );

    expect(
        await CatalogSnapshotRepository(db).findByRef(
          const CatalogEntityRef(
            kind: CatalogMediaKind.comic,
            entityType: CatalogEntityTypeId.catalogItem,
            id: 'comic-without-projection',
          ),
        ),
        isNull);
    expect(
      (await db.select(db.syncQueue).get())
          .where((row) => row.entityType == 'catalog_item'),
      isEmpty,
    );
  });

  test('collection import preview reports matched unresolved and skipped rows',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await CatalogTransportRepository(db).upsertTransportItems([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '75960604716152011',
      ),
    ]);

    final preview = await container
        .read(collectionImportOrchestratorProvider)
        .previewImportRows(
      const [
        CollectionImportRow(
          itemId: '',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          title: 'The Amazing Spider-Man, Vol. 2',
          kindCatalogCells: [
            '',
            'comic',
            'The Amazing Spider-Man, Vol. 2',
            '520',
            '',
            '',
            '',
            '',
            '',
            '',
            '75960604716152011',
          ],
        ),
        CollectionImportRow(
          itemId: '',
          status: 'owned',
          title: 'Unknown Series',
          kindCatalogCells: [
            '',
            '',
            'Unknown Series',
            '1',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          ],
        ),
        CollectionImportRow(itemId: '', status: ''),
      ],
    );

    expect(preview.totalRows, 3);
    expect(preview.resolvedCount, 1);
    expect(preview.unresolvedCount, 1);
    expect(preview.skippedCount, 1);
    expect(preview.resolvedRows.single.itemId, 'comic-1');
  });

  test('collection import preview skips duplicate csv targets', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);
    final preview = await importOrchestrator.previewImportRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          kindOwnedCells: ['9.8'],
        ),
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          kindOwnedCells: ['7.5'],
        ),
      ],
    );

    expect(preview.resolvedCount, 1);
    expect(preview.duplicateCount, 1);
    expect(preview.duplicateRows.single.kindOwnedCells.first, '7.5');
    expect(preview.reviewCount, 1);

    final imported = await importOrchestrator.importRows(preview.resolvedRows);
    final owned = await _typedOwnedForCatalog<ComicCollectionItem>(
      db,
      'comic-1',
    );
    expect(imported, 1);
    expect(owned.grade, '9.8');
  });

  test('collection import routes tracking columns to tracking entries',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      [
        CollectionImportRow(
          itemId: 'comic-tracking-import',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          tracking: CollectionImportTrackingValues(
            rating: 8,
            status: 'Read',
            startedAt: DateTime.utc(2026, 6, 1),
            finishedAt: DateTime.utc(2026, 6, 2),
          ),
        ),
      ],
    );

    final owned = await _typedOwnedForCatalog<ComicCollectionItem>(
      db,
      'comic-tracking-import',
    );
    final tracking = await readSingleTrackingState(db);
    expect(imported, 1);
    expect(
      tracking.collectionItemRef?.key,
      CollectionItemRef.fromKey('comic:${owned.id.value}').key,
    );
    expect(tracking.statusStorageValue, 'Completed');
    expect(tracking.rating, 8);
    expect(tracking.startedAt?.toUtc(), DateTime.utc(2026, 6, 1));
    expect(tracking.finishedAt?.toUtc(), DateTime.utc(2026, 6, 2));
  });

  test('collection import preview reports existing owned conflicts', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);

    await coordinator.addCollectionItem(
      typedAddCollectionItemCommand(
        catalogRef: testCatalogRef('comic-1', kind: 'comic'),
        common: const LibraryAddCommonDraft(),
        grade: '4.0',
        details: const ComicOwnedDetailsDraft(),
      ),
    );

    final preview = await importOrchestrator.previewImportRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          kindOwnedCells: ['7.5'],
        ),
      ],
    );

    expect(preview.resolvedCount, 0);
    expect(preview.conflictCount, 1);
    expect(preview.conflictRows.single.itemId, 'comic-1');
  });

  test('collection import updates existing owned conflict without duplicate',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final coordinator = container.read(collectionCommandCoordinatorProvider);
    final importOrchestrator =
        container.read(collectionImportOrchestratorProvider);

    await coordinator.addCollectionItem(
      typedAddCollectionItemCommand(
        catalogRef: testCatalogRef('comic-1', kind: 'comic'),
        common: const LibraryAddCommonDraft(condition: 'Good'),
        grade: '4.0',
        details: const ComicOwnedDetailsDraft(),
      ),
    );
    final original =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');

    final imported = await importOrchestrator.importRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          kindOwnedCells: ['7.5'],
          personal: CollectionImportPersonalValues(locationId: 'loc-box-6'),
        ),
      ],
    );

    final owned =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');
    expect(imported, 1);
    expect(owned.id, original.id);
    expect(owned.condition, 'Good');
    expect(owned.grade, '7.5');
    expect(owned.locationId, 'loc-box-6');
  });

  test('collection import preserves structured location ids', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportOrchestratorProvider).importRows(
      const [
        CollectionImportRow(
          itemId: 'comic-1',
          mediaKind: CatalogMediaKind.comic,
          status: 'owned',
          personal: CollectionImportPersonalValues(
            locationId: 'loc-short-box-6',
          ),
        ),
      ],
    );

    final owned =
        await _typedOwnedForCatalog<ComicCollectionItem>(db, 'comic-1');
    expect(imported, 1);
    expect(owned.locationId, 'loc-short-box-6');
  });
}

Future<T> _typedOwned<T>(LocalDatabase db, CollectionItemRef ref) async {
  final result = switch (ref.kind) {
    CatalogMediaKind.comic =>
      await ComicOwnedRepository(db).findById(CollectionItemId(ref.id.value)),
    CatalogMediaKind.book =>
      await BookOwnedRepository(db).findById(CollectionItemId(ref.id.value)),
    CatalogMediaKind.movie =>
      await MovieOwnedRepository(db).findById(CollectionItemId(ref.id.value)),
    _ => throw StateError('Unsupported test Owned kind ${ref.kind}'),
  };
  expect(result, isNotNull, reason: 'Missing typed Collection item ${ref.key}');
  return result as T;
}

Future<T> _typedOwnedForCatalog<T>(LocalDatabase db, String itemId) async {
  final summaries = await CollectionItemsRepository(db).listActiveSummaries();
  final summary = summaries.firstWhere(
    (item) => (item.catalogRef?.rootId ?? item.catalogRef?.id) == itemId,
  );
  return _typedOwned<T>(db, summary.ref);
}

class _CollectionItemAuthController extends AuthController {
  _CollectionItemAuthController();

  @override
  AuthState build() => const AuthState(
        token: 'test-token',
        userId: 'user-1',
        email: 'owner@example.com',
      );
}

class _SpySyncController extends SyncController {
  _SpySyncController();

  int syncNowRequests = 0;

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {
    syncNowRequests += 1;
  }
}

class _OnlineFirstConnectionSettingsController
    extends ConnectionSettingsController {
  @override
  ConnectionSettings build() => const ConnectionSettings(
        preferOnlineFirstSync: true,
        syncBaseUrl: 'https://sync.example.test',
        syncKey: 'test-sync-key',
      );
}
