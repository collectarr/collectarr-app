import 'dart:convert';

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/tracking_source.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/core/models/personal_item_anchor.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/collection/csv/collection_csv.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_modules.dart';
import 'package:collectarr_app/features/library/kinds/comic/ownership/comic_owned_item_create_payload.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

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

    await container.read(ownedItemMutationsProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            anchor: PersonalItemAnchor.fromRaw(
              anchorType: PersonalItemAnchorType.variant.apiValue,
              editionId: 'edition-1',
              variantId: 'variant-1',
            ),
            common: const OwnedItemCommonDraft(
              condition: 'Near Mint',
              grade: '9.8',
            ),
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    final queued = (await db.select(db.syncQueue).get())
        .where((row) => row.entityType == 'owned_item')
        .toList();
    final owned = await db.select(db.ownedItemsCache).getSingle();
    expect(owned.editionId, 'edition-1');
    expect(owned.variantId, 'variant-1');
    expect(queued, hasLength(1));
    expect(queued.single.entityType, 'owned_item');
    expect(queued.single.action, 'upsert');
  });

  test(
      'collection add prefers the kind-owned create payload over legacy common fields',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(ownedItemMutationsProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('comic-typed-payload', kind: 'comic'),
            common: const OwnedItemCommonDraft(
              condition: 'Legacy condition',
              quantity: 1,
            ),
            details: const ComicOwnedDetailsDraft(),
            typedPayload: ComicOwnedItemCreatePayload(
              catalogRef: testCatalogRef('comic-typed-payload', kind: 'comic'),
              details: const ComicOwnedDetailsDraft(),
              condition: 'Typed condition',
              quantity: 3,
              purchaseStore: 'Typed store',
              collectionStatus: 'Complete',
            ),
          ),
        );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    expect(owned.condition, 'Typed condition');
    expect(owned.quantity, 3);
    expect(owned.purchaseStore, 'Typed store');
    expect(owned.collectionStatus, 'Complete');
  });

  test('collection mutations stamp owned item createdAt and owner identity',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        authControllerProvider.overrideWith(
          (ref) => _OwnedItemAuthController(ref),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(ownedItemMutationsProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('movie-1', kind: 'movie'),
            common: const OwnedItemCommonDraft(),
            details: const MovieOwnedDetailsDraft(),
          ),
        );

    final owned = await db.select(db.ownedItemsCache).getSingle();
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
        syncControllerProvider.overrideWith(
          (ref) => syncController = _SpySyncController(ref),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(ownedItemMutationsProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const OwnedItemCommonDraft(),
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    expect(syncController.syncNowRequests, 1);
  });

  test('catalog refresh preserves personal collection data', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItem(id: 'comic-1', kind: 'comic', title: 'Original'),
    ]);
    await container.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const OwnedItemCommonDraft(
              condition: 'Near Mint',
            ),
            tracking: const OwnedItemTrackingDraft(rating: 8),
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    await container.read(ownedItemMutationsProvider).updateCatalogSnapshot(
          testCatalogItem(
            id: 'comic-1',
            kind: 'comic',
            title: 'Updated',
            synopsis: 'Refreshed metadata',
          ),
        );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final tracking = await db.select(db.trackingEntriesCache).getSingle();
    final catalog = await LibraryCatalogRepository(db).findById('comic-1');

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

    await container.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('movie-1', kind: 'movie'),
            common: OwnedItemCommonDraft(),
            tracking: OwnedItemTrackingDraft(
              status: MediaTrackingStatus.completed,
              rating: 8,
              startedAt: DateTime.utc(2026, 5, 10),
              finishedAt: DateTime.utc(2026, 5, 12),
            ),
            details: const MovieOwnedDetailsDraft(),
          ),
        );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final tracking = await db.select(db.trackingEntriesCache).getSingle();
    final queued = await db.select(db.syncQueue).get();

    expect(tracking.itemId, 'movie-1');
    expect(tracking.ownedItemId, owned.id);
    expect(tracking.sourceType, 'physical');
    expect(tracking.status, 'Completed');
    expect(tracking.rating, 8);
    expect(owned.rating, isNull);
    expect(owned.readStatus, isNull);
    expect(owned.startedAt, isNull);
    expect(owned.finishedAt, isNull);
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

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItem(
        id: 'movie-digital-1',
        kind: 'movie',
        title: 'Ghost in the Shell',
        physicalFormat: 'digital',
        physicalFormatLabel: 'Digital',
      ),
    ]);

    await container.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('movie-digital-1', kind: 'movie'),
            common: const OwnedItemCommonDraft(),
            tracking: const OwnedItemTrackingDraft(
              status: MediaTrackingStatus.completed,
              rating: 9,
            ),
            details: const MovieOwnedDetailsDraft(),
          ),
        );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final tracking = await db.select(db.trackingEntriesCache).getSingle();

    expect(owned.isDigital, isTrue);
    expect(tracking.sourceType, TrackingSourceType.digital.apiValue);
  });

  test('collection mutations can sync owned tracking entries directly',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final owned =
        await container.read(collectionCommandCoordinatorProvider).addOwnedItem(
              AddOwnedItemCommand(
                catalogRef: testCatalogRef('movie-2', kind: 'movie'),
                anchor: PersonalItemAnchor.fromRaw(
                  anchorType: PersonalItemAnchorType.variant.apiValue,
                  editionId: 'edition-legacy',
                  variantId: 'variant-legacy',
                ),
                common: const OwnedItemCommonDraft(),
                details: const MovieOwnedDetailsDraft(),
              ),
              syncTracking: false,
            );
    await container.read(trackingMutationsProvider).syncOwnedTrackingEntry(
          owned,
          anchor: PersonalItemAnchor.fromRaw(
            anchorType: PersonalItemAnchorType.variant.apiValue,
            editionId: 'edition-steelbook',
            variantId: 'variant-4k',
          ),
          status: MediaTrackingStatus.completed,
          rating: 10,
          startedAt: DateTime.utc(2026, 5, 20),
          finishedAt: DateTime.utc(2026, 5, 21),
        );

    final tracking = await db.select(db.trackingEntriesCache).getSingle();
    final queued = await db.select(db.syncQueue).get();

    expect(tracking.ownedItemId, owned.id);
    expect(tracking.editionId, 'edition-steelbook');
    expect(tracking.variantId, 'variant-4k');
    expect(tracking.status, 'Completed');
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

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItem(
          id: 'music-1', kind: 'music', title: 'Blessed & Possessed'),
    ]);

    await container.read(trackingMutationsProvider).upsertTrackingEntry(
          TrackingTarget.catalog(testCatalogRef('music-1', kind: 'music')),
          sourceType: TrackingSourceType.digital,
          status: MediaTrackingStatus.inProgress,
          rating: 7,
          progressCurrent: 6,
          progressTotal: 12,
          notes: 'Streaming copy',
        );

    final tracking = await db.select(db.trackingEntriesCache).getSingle();
    final queued = await db.select(db.syncQueue).get();

    expect(tracking.itemId, 'music-1');
    expect(tracking.ownedItemId, isNull);
    expect(tracking.sourceType, 'digital');
    expect(tracking.progressCurrent, 6);
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

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItem(id: 'movie-1', kind: 'movie', title: 'Dune'),
    ]);

    await db.into(db.trackingEntriesCache).insert(
          TrackingEntriesCacheCompanion.insert(
            id: 'tracking-existing',
            itemId: 'movie-1',
            sourceType: const Value('digital'),
            status: const Value('Plan to watch'),
            updatedAt: DateTime.utc(2026, 5, 23),
          ),
        );

    await container.read(trackingMutationsProvider).upsertTrackingEntry(
          TrackingTarget.catalog(testCatalogRef('movie-1', kind: 'movie')),
          sourceType: TrackingSourceType.digital,
          status: MediaTrackingStatus.inProgress,
          rating: 9,
        );

    final tracking = await db.select(db.trackingEntriesCache).get();
    expect(tracking, hasLength(1));
    expect(tracking.single.id, 'tracking-existing');
    expect(tracking.single.status, 'In progress');
    expect(tracking.single.rating, 9);
  });

  test('collection mutations canonicalize tracking source aliases', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItem(id: 'book-1', kind: 'book', title: 'Project Hail Mary'),
    ]);

    await container.read(trackingMutationsProvider).upsertTrackingEntry(
          TrackingTarget.catalog(testCatalogRef('book-1', kind: 'book')),
          sourceType: trackingSourceTypeFromValue('kindle'),
          status: mediaTrackingStatusFromValue('Reading'),
        );

    final tracking = await db.select(db.trackingEntriesCache).getSingle();
    expect(tracking.sourceType, TrackingSourceType.digital.apiValue);
  });

  test('collection mutations enqueue catalog snapshots from cache', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await LibraryCatalogRepository(db).upsertAll([
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

    await container.read(ownedItemMutationsProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const OwnedItemCommonDraft(),
            details: const ComicOwnedDetailsDraft(),
          ),
        );

    final queued = await db.select(db.syncQueue).get();
    final snapshot =
        queued.where((row) => row.entityType == 'catalog_item').single;
    // addOwnedItem enqueues the owned item, the catalog snapshot, and auto-registers
    // the publisher as a pick-list value.
    expect(queued, hasLength(3));
    expect(
      queued.where((row) => row.entityType == 'pick_list_value').length,
      1,
    );
    expect(snapshot.entityId, 'comic-1');
    expect(snapshot.payloadJson, contains('Absolute Batman'));
    expect(snapshot.payloadJson, contains('https://cdn.example/absolute.jpg'));
    expect(snapshot.payloadJson,
        contains('https://cdn.example/absolute-thumb.jpg'));
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

    await container.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: OwnedItemCommonDraft(
              condition: 'Near Mint',
              grade: '9.8',
              purchaseDate: DateTime.utc(2026, 5, 10),
              pricePaidCents: 1299,
              currency: 'USD',
              personalNotes: 'Signed copy',
            ),
            details: const ComicOwnedDetailsDraft(),
          ),
        );
    final original = await db.select(db.ownedItemsCache).getSingle();

    await container.read(collectionCommandCoordinatorProvider).updateOwnedItem(
          UpdateOwnedItemCommand(
            ownedItemId: original.id,
            condition: const Patch.set('Near Mint'),
            grade: const Patch.set('9.8'),
            purchaseDate: const Patch.clear(),
            pricePaidCents: const Patch.clear(),
            currency: const Patch.clear(),
            personalNotes: const Patch.clear(),
          ),
        );

    final updated = await db.select(db.ownedItemsCache).getSingle();
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

    await container.read(collectionCommandCoordinatorProvider).addOwnedItem(
          AddOwnedItemCommand(
            catalogRef: testCatalogRef('comic-1', kind: 'comic'),
            common: const OwnedItemCommonDraft(
              locationId: 'loc-box-6',
            ),
            details: const ComicOwnedDetailsDraft(),
          ),
        );
    final original = await db.select(db.ownedItemsCache).getSingle();

    await container.read(collectionCommandCoordinatorProvider).updateOwnedItem(
          UpdateOwnedItemCommand(
            ownedItemId: original.id,
            locationId: const Patch.clear(),
          ),
        );

    final updated = await db.select(db.ownedItemsCache).getSingle();
    expect(updated.locationId, isNull);
  });

  test('wishlist updates persist bundle anchors and notes', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container
        .read(wishlistMutationsProvider)
        .addToWishlist('movie-1', fallbackKind: 'movie');
    final originalRow = await db.select(db.wishlistItemsCache).getSingle();
    final original = WishlistItem(
      id: originalRow.id,
      catalogRef: testCatalogRef(originalRow.itemId, kind: 'movie'),
      anchorType: originalRow.anchorType,
      editionId: originalRow.editionId,
      variantId: originalRow.variantId,
      bundleReleaseId: originalRow.bundleReleaseId,
      targetPriceCents: originalRow.targetPriceCents,
      currency: originalRow.currency,
      notes: originalRow.notes,
      createdAt: originalRow.createdAt,
      updatedAt: originalRow.updatedAt,
      deletedAt: originalRow.deletedAt,
    );

    await container.read(wishlistMutationsProvider).updateWishlistItem(
          original,
          anchor: PersonalItemAnchor.fromRaw(
            anchorType: PersonalItemAnchorType.bundleRelease.apiValue,
            bundleReleaseId: 'bundle-1',
          ),
          targetPriceCents: 4599,
          currency: 'USD',
          notes: 'Wait for the steelbook bundle.',
        );

    final updated = await db.select(db.wishlistItemsCache).getSingle();
    final queued = await db.select(db.syncQueue).get();

    expect(updated.anchorType, 'bundle_release');
    expect(updated.bundleReleaseId, 'bundle-1');
    expect(updated.targetPriceCents, 4599);
    expect(updated.currency, 'USD');
    expect(updated.notes, 'Wait for the steelbook bundle.');
    expect(
        queued.where((row) => row.entityType == 'wishlist_item'), hasLength(1));
  });

  test('wishlist allows multiple release anchors for the same item', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final wishlistMutations = container.read(wishlistMutationsProvider);
    await wishlistMutations.addToWishlist(
      'movie-1',
      fallbackKind: 'movie',
      anchor: PersonalItemAnchor.fromRaw(editionId: 'edition-4k'),
    );
    await wishlistMutations.addToWishlist(
      'movie-1',
      fallbackKind: 'movie',
      anchor: PersonalItemAnchor.fromRaw(editionId: 'edition-bluray'),
    );

    final rows = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();

    expect(rows.where((row) => row.deletedAt == null), hasLength(2));
    expect(
      rows
          .where((row) => row.deletedAt == null)
          .map((row) => row.editionId)
          .toSet(),
      {'edition-4k', 'edition-bluray'},
    );
    expect(
        queued.where((row) => row.entityType == 'wishlist_item'), hasLength(2));
  });

  test('wishlist removal can target a single release anchor', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final wishlistMutations = container.read(wishlistMutationsProvider);
    await wishlistMutations.addToWishlist(
      'movie-1',
      fallbackKind: 'movie',
      anchor: PersonalItemAnchor.fromRaw(editionId: 'edition-4k'),
    );
    await wishlistMutations.addToWishlist(
      'movie-1',
      fallbackKind: 'movie',
      anchor: PersonalItemAnchor.fromRaw(editionId: 'edition-bluray'),
    );

    await wishlistMutations.removeFromWishlist(
      'movie-1',
      anchor: PersonalItemAnchor.fromRaw(editionId: 'edition-4k'),
    );

    final rows = await db.select(db.wishlistItemsCache).get();
    final activeRows = rows.where((row) => row.deletedAt == null).toList();
    final deletedRows = rows.where((row) => row.deletedAt != null).toList();

    expect(activeRows, hasLength(1));
    expect(activeRows.single.editionId, 'edition-bluray');
    expect(deletedRows, hasLength(1));
    expect(deletedRows.single.editionId, 'edition-4k');
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
        await container.read(collectionImportServiceProvider).importRows(
      [
        CollectionCsvRow(
          itemId: 'comic-1',
          kind: 'comic',
          status: 'owned',
          condition: 'Near Mint',
          grade: '9.8',
          pricePaidCents: 1299,
          currency: 'USD',
        ),
        const CollectionCsvRow(itemId: 'comic-2', status: 'wishlist'),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).get();
    final typedOwned = await db.select(db.comicOwnedItemsRows).get();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();
    expect(imported, 2);
    expect(owned, hasLength(1));
    expect(typedOwned, hasLength(1));
    expect(typedOwned.single.grade, '9.8');
    expect(wishlist, hasLength(1));
    expect(queued, hasLength(4));
    expect(container.read(syncControllerProvider).pendingCount, 4);
  });

  test('collection import propagates file import origin', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    MutationOrigin? observedOrigin;
    final runner = CollectionMutationRunner(
      database: db,
      events: CollectionEventBus(),
      mutationOriginHandler: (origin) => observedOrigin = origin,
    );
    final container = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        collectionMutationRunnerProvider.overrideWithValue(runner),
      ],
    );
    addTearDown(container.dispose);

    await container.read(collectionImportServiceProvider).importRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-import-1',
          kind: 'comic',
          status: 'owned',
        ),
      ],
    );

    expect(observedOrigin, MutationOrigin.fileImport);
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
    final importService = container.read(collectionImportServiceProvider);

    await wishlistMutations.addToWishlist('comic-1', fallbackKind: 'comic');
    await importService.importRows([
      const CollectionCsvRow(
        itemId: 'comic-1',
        kind: 'comic',
        status: 'owned',
      ),
    ]);

    final owned = await db.select(db.ownedItemsCache).get();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = (await db.select(db.syncQueue).get())
        .where((row) =>
            row.entityType == 'owned_item' ||
            row.entityType == 'wishlist_item' ||
            row.entityType == 'catalog_item')
        .toList();

    expect(owned, hasLength(1));
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

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '759606047161-52011',
      ),
    ]);

    final imported =
        await container.read(collectionImportServiceProvider).importRows(
      const [
        CollectionCsvRow(
          itemId: '',
          status: 'owned',
          title: 'Different title from CSV',
          itemNumber: '520',
          barcode: '75960604716152011',
          grade: '7.5',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final typedOwned = await db.select(db.comicOwnedItemsRows).get();
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
        await container.read(collectionImportServiceProvider).importRows(
      const [
        CollectionCsvRow(
          itemId: 'movie-1',
          kind: 'movie',
          status: 'owned',
          title: 'Blade Runner',
          itemNumber: 'Final Cut',
          variant: '4K UHD',
          editionTitle: 'Final Cut 4K release',
          physicalFormat: '4k-uhd',
          physicalFormatLabel: '4K UHD',
          barcode: '883929087129',
        ),
      ],
    );

    final catalog = await LibraryCatalogRepository(db).findById('movie-1');
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
        await container.read(collectionImportServiceProvider).importRows(
      [
        CollectionCsvRow(
          itemId: 'book-owned-fields',
          kind: 'book',
          status: 'owned',
          title: 'Imported book',
          condition: 'Very Good',
          grade: '8.5',
          purchaseDate: DateTime.utc(2026, 8, 1),
          pricePaidCents: 2599,
          currency: 'EUR',
          notes: 'Imported note',
          quantity: 3,
          locationId: 'shelf-a',
          indexNumber: 12,
          tags: 'gift,read',
          soldAt: DateTime.utc(2026, 8, 15),
          sellPriceCents: 3199,
          soldTo: 'collector@example.test',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    expect(imported, 1);
    expect(owned.itemId, 'book-owned-fields');
    expect(owned.condition, 'Very Good');
    expect(owned.grade, '8.5');
    expect(owned.purchaseDate?.toUtc(), DateTime.utc(2026, 8, 1));
    expect(owned.pricePaidCents, 2599);
    expect(owned.currency, 'EUR');
    expect(owned.personalNotes, 'Imported note');
    expect(owned.quantity, 3);
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

    final csv = CollectionCsv();
    final rows = csv.parse(
      csv.exportShelf([
        ShelfEntry(
          itemId: 'comic-owned-details',
          catalogItem: typedCatalogItemFromCatalogItem(
            testCatalogItem(
              id: 'comic-owned-details',
              kind: 'comic',
              title: 'Imported Comic',
            ),
          ),
          ownedItem: testOwnedItem(
            id: 'owned-comic-details',
            itemId: 'comic-owned-details',
            rawOrSlabbed: 'Slabbed',
            gradingCompany: 'CGC',
            graderNotes: 'Pressing preserved',
            signedBy: 'Artist',
            keyComic: true,
            keyReason: 'First appearance',
            coverPriceCents: 499,
          ),
        ),
      ]),
    );

    await container.read(collectionImportServiceProvider).importRows(rows);

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final details = ComicOwnedDetails.fromJson(
      jsonDecode(owned.detailsJson!) as Map<String, dynamic>,
    );
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

    await LibraryCatalogRepository(db).upsertAll([
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
        await container.read(collectionImportServiceProvider).importRows(
      const [
        CollectionCsvRow(
          itemId: '',
          kind: 'movie',
          status: 'owned',
          title: 'Dune',
          barcode: '1234567890',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    expect(imported, 1);
    expect(owned.itemId, 'movie-1');
  });

  test('collection import preview reports matched unresolved and skipped rows',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await LibraryCatalogRepository(db).upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Amazing Spider-Man, Vol. 2',
        itemNumber: '520',
        barcode: '75960604716152011',
      ),
    ]);

    final preview =
        await container.read(collectionImportServiceProvider).previewImportRows(
      const [
        CollectionCsvRow(
          itemId: '',
          kind: 'comic',
          status: 'owned',
          title: 'The Amazing Spider-Man, Vol. 2',
          itemNumber: '520',
        ),
        CollectionCsvRow(
          itemId: '',
          status: 'owned',
          title: 'Unknown Series',
          itemNumber: '1',
        ),
        CollectionCsvRow(itemId: '', status: ''),
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

    final importService = container.read(collectionImportServiceProvider);
    final preview = await importService.previewImportRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '9.8',
        ),
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '7.5',
        ),
      ],
    );

    expect(preview.resolvedCount, 1);
    expect(preview.duplicateCount, 1);
    expect(preview.duplicateRows.single.grade, '7.5');
    expect(preview.reviewCount, 1);

    final imported = await importService.importRows(preview.resolvedRows);
    final owned = await db.select(db.ownedItemsCache).get();
    expect(imported, 1);
    expect(owned, hasLength(1));
    expect(owned.single.grade, '9.8');
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
        await container.read(collectionImportServiceProvider).importRows(
      [
        CollectionCsvRow(
          itemId: 'comic-tracking-import',
          kind: 'comic',
          status: 'owned',
          rating: 8,
          readStatus: 'Read',
          startedAt: DateTime.utc(2026, 6, 1),
          finishedAt: DateTime.utc(2026, 6, 2),
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).getSingle();
    final tracking = await db.select(db.trackingEntriesCache).getSingle();
    expect(imported, 1);
    expect(owned.rating, isNull);
    expect(owned.readStatus, isNull);
    expect(tracking.ownedItemId, owned.id);
    expect(tracking.status, 'Completed');
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
    final importService = container.read(collectionImportServiceProvider);

    await coordinator.addOwnedItem(
      AddOwnedItemCommand(
        catalogRef: testCatalogRef('comic-1', kind: 'comic'),
        common: const OwnedItemCommonDraft(grade: '4.0'),
        details: const ComicOwnedDetailsDraft(),
      ),
    );

    final preview = await importService.previewImportRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '7.5',
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
    final importService = container.read(collectionImportServiceProvider);

    await coordinator.addOwnedItem(
      AddOwnedItemCommand(
        catalogRef: testCatalogRef('comic-1', kind: 'comic'),
        common: const OwnedItemCommonDraft(condition: 'Good', grade: '4.0'),
        details: const ComicOwnedDetailsDraft(),
      ),
    );
    final original = await db.select(db.ownedItemsCache).getSingle();

    final imported = await importService.importRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          grade: '7.5',
          locationId: 'loc-box-6',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).get();
    expect(imported, 1);
    expect(owned, hasLength(1));
    expect(owned.single.id, original.id);
    expect(owned.single.condition, 'Good');
    expect(owned.single.grade, '7.5');
    expect(owned.single.locationId, 'loc-box-6');
  });

  test('collection import preserves structured location ids', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final imported =
        await container.read(collectionImportServiceProvider).importRows(
      const [
        CollectionCsvRow(
          itemId: 'comic-1',
          status: 'owned',
          locationId: 'loc-short-box-6',
        ),
      ],
    );

    final owned = await db.select(db.ownedItemsCache).get();
    expect(imported, 1);
    expect(owned.single.locationId, 'loc-short-box-6');
  });

  test('collection mutations can keep unmatched tmdb items local-only',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final snapshot = testCatalogItem(
      id: 'tmdb-local:movie:603',
      kind: 'movie',
      title: 'The Matrix',
      releaseYear: 1999,
    );

    await container.read(trackingMutationsProvider).addLocalOnlyTrackingEntry(
          snapshot,
          sourceType: TrackingSourceType.streaming,
          status: MediaTrackingStatus.completed,
          rating: 9,
          timesCompleted: 1,
        );
    await container.read(wishlistMutationsProvider).addLocalOnlyWishlistItem(
          snapshot,
        );

    final catalog = await LibraryCatalogRepository(db).findAll();
    final tracking = await db.select(db.trackingEntriesCache).get();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();

    expect(catalog.single.id, 'tmdb-local:movie:603');
    expect(tracking.single.itemId, 'tmdb-local:movie:603');
    expect(wishlist.single.itemId, 'tmdb-local:movie:603');
    expect(queued, isEmpty);
  });

  test('collection mutations can promote local-only tmdb items to core ids',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [localDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final trackingMutations = container.read(trackingMutationsProvider);
    final wishlistMutations = container.read(wishlistMutationsProvider);
    final ownedMutations = container.read(ownedItemMutationsProvider);

    final localSnapshot = testCatalogItem(
      id: 'tmdb-local:movie:603',
      kind: 'movie',
      title: 'The Matrix',
      releaseYear: 1999,
    );
    await trackingMutations.addLocalOnlyTrackingEntry(
      localSnapshot,
      sourceType: TrackingSourceType.streaming,
      status: MediaTrackingStatus.completed,
      rating: 9,
      timesCompleted: 1,
    );
    await wishlistMutations.addLocalOnlyWishlistItem(localSnapshot);

    final promotedCount = await ownedMutations.promoteLocalOnlyItemToCatalog(
      'tmdb-local:movie:603',
      testCatalogItem(
        id: 'movie-603',
        kind: 'movie',
        title: 'The Matrix',
        releaseYear: 1999,
      ),
    );

    final tracking = await db.select(db.trackingEntriesCache).get();
    final wishlist = await db.select(db.wishlistItemsCache).get();
    final queued = await db.select(db.syncQueue).get();

    expect(promotedCount, 2);
    expect(
      tracking.where((row) => row.deletedAt == null).single.itemId,
      'movie-603',
    );
    expect(
      wishlist.where((row) => row.deletedAt == null).single.itemId,
      'movie-603',
    );
    expect(
      queued.where((row) => row.entityType == 'tracking_entry'),
      hasLength(1),
    );
    expect(
      queued.where((row) => row.entityType == 'wishlist_item'),
      hasLength(1),
    );
    expect(
      queued.where((row) => row.entityType == 'library_item_snapshot'),
      hasLength(1),
    );
  });
}

class _OwnedItemAuthController extends AuthController {
  _OwnedItemAuthController(super.ref) {
    state = const AuthState(
      token: 'test-token',
      userId: 'user-1',
      email: 'owner@example.com',
    );
  }
}

class _SpySyncController extends SyncController {
  _SpySyncController(super.ref);

  int syncNowRequests = 0;

  @override
  Future<void> refreshPendingCount() async {}

  @override
  Future<void> syncNow() async {
    syncNowRequests += 1;
  }
}
