import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_status.dart';
import 'package:collectarr_app/features/collection/sync/provider_local_state_bridge.dart';
import 'package:collectarr_app/features/providers/domain/engine/provider_sync_coordinator.dart';
import 'package:collectarr_app/features/providers/domain/engine/external_state_engine.dart';
import 'package:collectarr_app/features/providers/domain/models/mutation_origin.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_account_store.dart';
import 'package:collectarr_app/features/providers/domain/repositories/provider_link_store.dart';
import 'package:collectarr_app/features/providers/runtime/provider_registry_provider.dart';
import 'package:collectarr_app/core/sync/sync_queue_repository.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/coordinators/collection_command_coordinator.dart';
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
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_custom_episode_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/features/library/kinds/tv/tracking/tv_tracking_unit_mutations.dart';

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(localDatabaseProvider));
});

final ownedItemsCacheRepositoryProvider =
    Provider<OwnedItemsCacheRepository>((ref) {
  return OwnedItemsCacheRepository(ref.watch(localDatabaseProvider));
});

final wishlistItemsCacheRepositoryProvider =
    Provider<WishlistItemsCacheRepository>((ref) {
  return WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
});

final catalogCacheRepositoryProvider =
    Provider<LibraryCatalogRepository>((ref) {
  return LibraryCatalogRepository(ref.watch(localDatabaseProvider));
});

final trackingEntriesCacheRepositoryProvider =
    Provider<TrackingEntriesCacheRepository>((ref) {
  return TrackingEntriesCacheRepository(ref.watch(localDatabaseProvider));
});

final trackingUnitsCacheRepositoryProvider =
    Provider<TrackingUnitsCacheRepository>((ref) {
  return TrackingUnitsCacheRepository(
    ref.watch(localDatabaseProvider),
    codecs: collectarrTrackingUnitCodecs,
  );
});

final watchSessionsCacheRepositoryProvider =
    Provider<WatchSessionsCacheRepository>((ref) {
  return WatchSessionsCacheRepository(
    ref.watch(localDatabaseProvider),
    codecs: collectarrWatchSessionCodecs,
  );
});

final userMetadataOverridesCacheRepositoryProvider =
    Provider<UserMetadataOverridesCacheRepository>((ref) {
  return UserMetadataOverridesCacheRepository(ref.watch(localDatabaseProvider));
});

final customEpisodesCacheRepositoryProvider =
    Provider<CustomEpisodesCacheRepository>((ref) {
  return CustomEpisodesCacheRepository(
    ref.watch(localDatabaseProvider),
    codecs: collectarrCustomEpisodeCodecs,
  );
});

final collectionEventBusProvider = Provider<CollectionEventBus>((ref) {
  final bus = CollectionEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final providerLocalStateBridgeProvider =
    Provider<ProviderLocalStateBridge>((ref) {
  return ProviderLocalStateBridge(
    catalogCache: ref.watch(catalogCacheRepositoryProvider),
    trackingEntries: ref.watch(trackingEntriesCacheRepositoryProvider),
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
  );
});

final providerSyncCoordinatorProvider =
    FutureProvider<ProviderSyncCoordinator>((ref) async {
  final registry = await ref.watch(providerRegistryProvider.future);
  final bridge = ref.watch(providerLocalStateBridgeProvider);
  return ProviderSyncCoordinator(
    engine: const ExternalStateEngine(),
    registry: registry,
    accountStore: ref.watch(providerAccountStoreProvider),
    linkStore: ref.watch(providerLinkStoreProvider),
    localStateReader: bridge.read,
    localStateApplier: (localRef, remoteEntry, origin) =>
        _applyProviderEntry(ref, localRef, remoteEntry, origin),
  );
});

final collectionMutationRunnerProvider =
    Provider<CollectionMutationRunner>((ref) {
  return CollectionMutationRunner(
    database: ref.watch(localDatabaseProvider),
    events: ref.watch(collectionEventBusProvider),
    syncScheduler: () {
      if (ref.mounted) {
        ref.read(syncControllerProvider.notifier).syncNow();
      }
    },
    localMutationHandler: (localRef, origin) async {
      final link =
          await ref.read(providerLinkStoreProvider).getLinkByLocalRef(localRef);
      if (link == null) {
        return;
      }
      final bridge = ref.read(providerLocalStateBridgeProvider);
      final localEntry = await bridge.read(localRef, link: link);
      if (localEntry == null) {
        return;
      }
      final coordinator =
          await ref.read(providerSyncCoordinatorProvider.future);
      await coordinator.handleLocalMutation(
        localRef: localRef,
        localEntry: localEntry,
        origin: origin,
      );
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
  );
});

final trackingMutationsProvider = Provider<TrackingMutations>((ref) {
  return TrackingMutations(
    trackingEntries: ref.watch(trackingEntriesCacheRepositoryProvider),
    trackingUnits: ref.watch(trackingUnitsCacheRepositoryProvider),
    watchSessions: ref.watch(watchSessionsCacheRepositoryProvider),
    catalogCache: ref.watch(catalogCacheRepositoryProvider),
    ownedItems: ref.watch(ownedItemsCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final tvTrackingUnitMutationsProvider =
    Provider<TvTrackingUnitMutations>((ref) {
  return TvTrackingUnitMutations(
    trackingUnits: ref.watch(trackingUnitsCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final watchSessionMutationsProvider = Provider<WatchSessionMutations>((ref) {
  return WatchSessionMutations(
    watchSessions: ref.watch(watchSessionsCacheRepositoryProvider),
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

final customEpisodeMutationsProvider = Provider<CustomEpisodeMutations>((ref) {
  return CustomEpisodeMutations(
    customEpisodes: ref.watch(customEpisodesCacheRepositoryProvider),
    syncQueue: ref.watch(syncQueueRepositoryProvider),
    mutationRunner: ref.watch(collectionMutationRunnerProvider),
  );
});

final collectionImportServiceProvider =
    Provider<CollectionImportService>((ref) {
  return CollectionImportService(
    ownedItems: ref.watch(ownedItemsCacheRepositoryProvider),
    wishlist: ref.watch(wishlistItemsCacheRepositoryProvider),
    catalogCache: ref.watch(catalogCacheRepositoryProvider),
    trackingEntries: ref.watch(trackingEntriesCacheRepositoryProvider),
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

Future<void> _applyProviderEntry(
  Ref ref,
  CatalogEntityRef localRef,
  ProviderPersonalEntry remoteEntry,
  MutationOrigin origin,
) async {
  final bridge = ref.read(providerLocalStateBridgeProvider);
  final trackingEntries =
      await ref.read(trackingEntriesCacheRepositoryProvider).listActive();
  TrackingEntry? localTracking;
  for (final entry in trackingEntries) {
    if (bridge.matches(entry.catalogRef, localRef)) {
      localTracking = entry;
      break;
    }
  }

  final status = _trackingStatusForProvider(remoteEntry);
  final rating = remoteEntry.rating == null
      ? null
      : (remoteEntry.rating! / 10).round().clamp(1, 10);

  if (localTracking != null) {
    await ref.read(trackingMutationsProvider).updateTrackingEntry(
          localTracking.copyWith(
            status: status,
            rating: rating,
            progressCurrent: remoteEntry.progress,
            progressTotal: remoteEntry.totalProgress,
            startedAt: remoteEntry.startedAt,
            finishedAt: remoteEntry.completedAt,
            timesCompleted: remoteEntry.repeatCount,
            notes: remoteEntry.notes,
          ),
          origin: origin,
        );
    return;
  }

  final wishlistItems =
      await ref.read(wishlistItemsCacheRepositoryProvider).listActive();
  var hasWishlistItem = false;
  String? wishlistItemId;
  for (final item in wishlistItems) {
    if (bridge.matches(item.catalogRef, localRef)) {
      hasWishlistItem = true;
      wishlistItemId = item.id;
      break;
    }
  }
  if (!hasWishlistItem || !_hasProviderState(remoteEntry)) {
    return;
  }

  await ref.read(trackingMutationsProvider).upsertTrackingEntry(
        TrackingTarget.catalog(localRef),
        status: status ?? MediaTrackingStatus.planned,
        rating: rating,
        progressCurrent: remoteEntry.progress,
        progressTotal: remoteEntry.totalProgress,
        startedAt: remoteEntry.startedAt,
        finishedAt: remoteEntry.completedAt,
        timesCompleted: remoteEntry.repeatCount,
        notes: remoteEntry.notes,
        origin: origin,
      );
  await ref.read(wishlistMutationsProvider).removeFromWishlist(
        localRef.id,
        wishlistItemId: wishlistItemId,
        origin: origin,
      );
}

MediaTrackingStatus? _trackingStatusForProvider(ProviderPersonalEntry entry) {
  return switch (entry.status) {
    ProviderEntryStatus.planning => MediaTrackingStatus.planned,
    ProviderEntryStatus.current => MediaTrackingStatus.inProgress,
    ProviderEntryStatus.completed => MediaTrackingStatus.completed,
    ProviderEntryStatus.paused => MediaTrackingStatus.paused,
    ProviderEntryStatus.dropped => MediaTrackingStatus.dropped,
    ProviderEntryStatus.repeating => MediaTrackingStatus.repeating,
    null => null,
  };
}

bool _hasProviderState(ProviderPersonalEntry entry) {
  return entry.status != null ||
      entry.rating != null ||
      entry.progress != null ||
      entry.totalProgress != null ||
      entry.startedAt != null ||
      entry.completedAt != null ||
      entry.repeatCount != 0 ||
      entry.notes != null;
}
