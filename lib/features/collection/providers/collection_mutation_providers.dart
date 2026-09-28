import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_transport_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_lookup_repository.dart';
import 'package:collectarr_app/features/collection/coordinators/collection_command_coordinator.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/collection_import_orchestrator.dart';
import 'package:collectarr_app/features/collection/mutations/catalog_transport_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/metadata_override_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/watch_session_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/library/ownership/owned_items_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_storage_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(localDatabaseProvider));
});

final ownedItemsRepositoryProvider = Provider<OwnedItemsRepository>((ref) {
  return OwnedItemsRepository(ref.watch(localDatabaseProvider));
});

final wishlistItemsCacheRepositoryProvider =
    Provider<WishlistItemsCacheRepository>((ref) {
  return WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
});

final catalogTransportRepositoryProvider =
    Provider<CatalogTransportRepository>((ref) {
  return CatalogTransportRepository(ref.watch(localDatabaseProvider));
});

final trackingRecordRepositoryProvider =
    Provider<TrackingStorageRepository>((ref) {
  return TrackingStorageRepository(
    ref.watch(localDatabaseProvider),
    codecs: libraryTrackingStorageCodecs,
  );
});

final trackingUnitStorageRepositoryProvider =
    Provider<TrackingUnitStorageRepository>((ref) {
  return TrackingUnitStorageRepository(
    ref.watch(localDatabaseProvider),
    codecs: libraryTrackingUnitCodecs,
  );
});

final watchSessionRepositoryProvider = Provider<WatchSessionsRepository>((ref) {
  return WatchSessionsRepository(
    ref.watch(localDatabaseProvider),
    codecs: libraryWatchSessionCodecs,
  );
});

final userMetadataOverridesCacheRepositoryProvider =
    Provider<UserMetadataOverridesCacheRepository>((ref) {
  return UserMetadataOverridesCacheRepository(ref.watch(localDatabaseProvider));
});

final collectionEventBusProvider = Provider<CollectionEventBus>((ref) {
  final bus = CollectionEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final collectionMutationRunnerProvider =
    Provider<CollectionMutationRunner>((ref) {
  return CollectionMutationRunner(
    database: ref.watch(localDatabaseProvider),
    events: ref.watch(collectionEventBusProvider),
    projectionInvalidator: () {
      if (!ref.mounted) return;
      ref.invalidate(collectionProvider);
      ref.invalidate(collectionSummariesProvider);
      ref.invalidate(trackingSummariesProvider);
      ref.invalidate(trackingSummariesByCatalogRefProvider);
      ref.invalidate(trackingUnitsProvider);
      ref.invalidate(wishlistRefsProvider);
      ref.invalidate(wishlistProvider);
      ref.invalidate(watchSessionsProvider);
      ref.invalidate(shelfProvider);
    },
    syncScheduler: () {
      if (ref.mounted) {
        ref.read(syncControllerProvider.notifier).syncOnlineFirstIfEnabled();
      }
    },
  );
});

final ownedItemMutationsProvider = Provider<OwnedItemMutations>((ref) {
  final auth = ref.watch(authControllerProvider);
  return OwnedItemMutations(
    ownedItems: ref.watch(ownedItemsRepositoryProvider),
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    catalogSummaries: CatalogDisplaySummaryRepository(
      ref.watch(localDatabaseProvider),
    ),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    userId: auth.userId,
    userEmail: auth.email,
  );
});

final catalogTransportMutationsProvider =
    Provider<CatalogTransportMutations>((ref) {
  return CatalogTransportMutations(
    catalogTransport: ref.watch(catalogTransportRepositoryProvider),
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    trackingRecords: ref.watch(trackingRecordRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final wishlistMutationsProvider = Provider<WishlistMutations>((ref) {
  return WishlistMutations(
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    catalogTransport: ref.watch(catalogTransportRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final trackingMutationsProvider = Provider<TrackingMutations>((ref) {
  return TrackingMutations(
    trackingRecords: ref.watch(trackingRecordRepositoryProvider),
    trackingUnits: ref.watch(trackingUnitStorageRepositoryProvider),
    watchSessions: ref.watch(watchSessionRepositoryProvider),
    ownedItems: ref.watch(ownedItemsRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final watchSessionMutationsProvider = Provider<WatchSessionMutations>((ref) {
  return WatchSessionMutations(
    watchSessions: ref.watch(watchSessionRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final metadataOverrideMutationsProvider =
    Provider<MetadataOverrideMutations>((ref) {
  return MetadataOverrideMutations(
    overrides: ref.watch(userMetadataOverridesCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final collectionImportOrchestratorProvider =
    Provider<CollectionImportOrchestrator>((ref) {
  return CollectionImportOrchestrator(
    ownedItems: ref.watch(ownedItemsRepositoryProvider),
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    catalogTransport: ref.watch(catalogTransportRepositoryProvider),
    catalogSummaries: CatalogDisplaySummaryRepository(
      ref.watch(localDatabaseProvider),
    ),
    catalogLookup: CatalogLookupRepository(
      ref.watch(localDatabaseProvider),
    ),
    csvProfiles: collectionCsvKindProfiles,
    trackingRecords: ref.watch(trackingRecordRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final collectionCommandCoordinatorProvider =
    Provider<CollectionCommandCoordinator>((ref) {
  return CollectionCommandCoordinator(
    ownedMutations: ref.watch(ownedItemMutationsProvider),
    trackingMutations: ref.watch(trackingMutationsProvider),
  );
});
