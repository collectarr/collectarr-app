import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/commands/owned_item_commands.dart';
import 'package:collectarr_app/features/library/add/models/library_add_common_draft.dart';
import 'package:collectarr_app/features/library/kinds/registry/owned_details_exports.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late LibraryCatalogRepository catalogCache;
  late WishlistItemsCacheRepository wishlistRepo;
  late SyncQueueRepository syncQueue;
  late WishlistMutations wishlistMutations;
  late OwnedItemMutations ownedMutations;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalogCache = LibraryCatalogRepository(db);
    wishlistRepo = WishlistItemsCacheRepository(db);
    syncQueue = SyncQueueRepository(db);
    final runner = CollectionMutationRunner(
      database: db,
      events: CollectionEventBus(),
    );

    wishlistMutations = WishlistMutations(
      wishlist: wishlistRepo,
      catalogCache: catalogCache,
      trackingEntries: TrackingEntriesCacheRepository(
        db,
        codecs: collectarrTrackingEntryCodecs,
      ),
      trackingUnits: TrackingUnitsCacheRepository(
        db,
        codecs: collectarrTrackingUnitCodecs,
      ),
      syncQueue: syncQueue,
      mutationRunner: runner,
    );

    ownedMutations = OwnedItemMutations(
      ownedItems: OwnedItemsRepository(db),
      catalogCache: catalogCache,
      wishlist: wishlistRepo,
      trackingEntries: TrackingEntriesCacheRepository(
        db,
        codecs: collectarrTrackingEntryCodecs,
      ),
      syncQueue: syncQueue,
      mutationRunner: runner,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Catalog Reference Identity Resolution Tests', () {
    test(
        'resolved catalog item in cache retains its own kind on wishlist mutation',
        () async {
      await catalogCache.upsertAll([
        testCatalogItem(
          id: 'movie-100',
          kind: 'movie',
          title: 'The Matrix',
        ),
      ]);

      await wishlistMutations.addToWishlist(
        testCatalogRef('movie-100', kind: 'movie'),
      );

      final changes = await syncQueue.listPending();
      final wishlistChange = changes.firstWhere(
        (c) => c.entityType == 'wishlist_item' && c.action == 'upsert',
      );
      final catalogRef = wishlistChange.payload['catalog_ref'] as Map?;
      expect(catalogRef, isNotNull);
      expect(catalogRef!['kind'], 'movie');
      expect(catalogRef['kind'], isNot('comic'));
    });

    test(
        'explicit catalog reference resolves an item absent from catalog cache',
        () async {
      await wishlistMutations.addToWishlist(
        testCatalogRef('game-500', kind: 'game'),
      );

      final changes = await syncQueue.listPending();
      final wishlistChange = changes.firstWhere(
        (c) => c.entityType == 'wishlist_item' && c.action == 'upsert',
      );
      final catalogRef = wishlistChange.payload['catalog_ref'] as Map?;
      expect(catalogRef, isNotNull);
      expect(catalogRef!['kind'], 'game');
      expect(catalogRef['kind'], isNot('comic'));
    });

    test(
        'missing catalog item with an unknown reference kind throws StateError',
        () async {
      expect(
        () => wishlistMutations.addToWishlist(
          testCatalogRef('unknown-unseeded-item'),
        ),
        throwsStateError,
      );
    });

    test(
        'addOwnedItem with missing catalog cache item uses command catalogRef kind and never defaults to comic',
        () async {
      final owned = await ownedMutations.addOwnedItem(
        typedAddOwnedItemCommand(
          catalogRef: CatalogEntityRef(
            kind: 'music',
            entityType: CatalogEntityType.work,
            id: 'music-album-1',
          ),
          common: LibraryAddCommonDraft(),
          details: MusicOwnedDetailsDraft(),
        ),
      );

      expect(owned.catalogRef.kind, 'music');
      expect(owned.catalogRef.kind, isNot('comic'));
    });
  });
}
