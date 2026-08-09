import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/events/collection_event_bus.dart';
import 'package:collectarr_app/features/collection/mutations/collection_import_service.dart';
import 'package:collectarr_app/features/collection/mutations/custom_episode_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/metadata_override_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/owned_item_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/tracking_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/watch_session_mutations.dart';
import 'package:collectarr_app/features/collection/mutations/wishlist_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/runner/collection_mutation_runner.dart';
import 'package:collectarr_app/features/sync/state/sync_controller.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(localDatabaseProvider));
});

final ownedItemsCacheRepositoryProvider = Provider<OwnedItemsCacheRepository>((ref) {
  return OwnedItemsCacheRepository(ref.watch(localDatabaseProvider));
});

final wishlistItemsCacheRepositoryProvider = Provider<WishlistItemsCacheRepository>((ref) {
  return WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
});

final catalogCacheRepositoryProvider = Provider<CatalogCacheRepository>((ref) {
  return CatalogCacheRepository(ref.watch(localDatabaseProvider));
});

final trackingEntriesCacheRepositoryProvider = Provider<TrackingEntriesCacheRepository>((ref) {
  return TrackingEntriesCacheRepository(ref.watch(localDatabaseProvider));
});

final trackingUnitsCacheRepositoryProvider = Provider<TrackingUnitsCacheRepository>((ref) {
  return TrackingUnitsCacheRepository(ref.watch(localDatabaseProvider));
});

final watchSessionsCacheRepositoryProvider = Provider<WatchSessionsCacheRepository>((ref) {
  return WatchSessionsCacheRepository(ref.watch(localDatabaseProvider));
});

final userMetadataOverridesCacheRepositoryProvider = Provider<UserMetadataOverridesCacheRepository>((ref) {
  return UserMetadataOverridesCacheRepository(ref.watch(localDatabaseProvider));
});

final customEpisodesCacheRepositoryProvider = Provider<CustomEpisodesCacheRepository>((ref) {
  return CustomEpisodesCacheRepository(ref.watch(localDatabaseProvider));
});

final collectionEventBusProvider = Provider<CollectionEventBus>((ref) {
  final bus = CollectionEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final collectionMutationRunnerProvider = Provider<CollectionMutationRunner>((ref) {
  return CollectionMutationRunner(
    database: ref.watch(localDatabaseProvider),
    events: ref.watch(collectionEventBusProvider),
    syncScheduler: () {
      if (ref.mounted) {
        ref.read(syncControllerProvider.notifier).syncNow();
      }
    },
  );
});

final ownedItemMutationsProvider = Provider<OwnedItemMutations>((ref) {
  final auth = ref.watch(authControllerProvider);
  return OwnedItemMutations(
    ownedItems: ref.watch(ownedItemsCacheRepositoryProvider),
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    catalogCache: ref.watch(catalogCacheRepositoryProvider),
    trackingEntries: ref.watch(trackingEntriesCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    events: ref.watch(collectionEventBusProvider),
    userId: auth.userId,
    userEmail: auth.email,
  );
});

final wishlistMutationsProvider = Provider<WishlistMutations>((ref) {
  return WishlistMutations(
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    catalogCache: ref.watch(catalogCacheRepositoryProvider),
    trackingEntries: ref.watch(trackingEntriesCacheRepositoryProvider),
    trackingUnits: ref.watch(trackingUnitsCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    events: ref.watch(collectionEventBusProvider),
  );
});

final trackingMutationsProvider = Provider<TrackingMutations>((ref) {
  return TrackingMutations(
    trackingEntries: ref.watch(trackingEntriesCacheRepositoryProvider),
    trackingUnits: ref.watch(trackingUnitsCacheRepositoryProvider),
    watchSessions: ref.watch(watchSessionsCacheRepositoryProvider),
    catalogCache: ref.watch(catalogCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    events: ref.watch(collectionEventBusProvider),
  );
});

final watchSessionMutationsProvider = Provider<WatchSessionMutations>((ref) {
  return WatchSessionMutations(
    watchSessions: ref.watch(watchSessionsCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    events: ref.watch(collectionEventBusProvider),
  );
});

final metadataOverrideMutationsProvider = Provider<MetadataOverrideMutations>((ref) {
  return MetadataOverrideMutations(
    overrides: ref.watch(userMetadataOverridesCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    events: ref.watch(collectionEventBusProvider),
  );
});

final customEpisodeMutationsProvider = Provider<CustomEpisodeMutations>((ref) {
  return CustomEpisodeMutations(
    customEpisodes: ref.watch(customEpisodesCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    events: ref.watch(collectionEventBusProvider),
  );
});

final collectionImportServiceProvider = Provider<CollectionImportService>((ref) {
  return CollectionImportService(
    ownedItems: ref.watch(ownedItemsCacheRepositoryProvider),
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    catalogCache: ref.watch(catalogCacheRepositoryProvider),
    trackingEntries: ref.watch(trackingEntriesCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
    events: ref.watch(collectionEventBusProvider),
  );
});
