import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_unit_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_tracking_entry_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_custom_episode_codecs.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionProvider = FutureProvider<List<OwnedItemSummary>>((ref) async {
  final cache = OwnedItemsRepository(ref.watch(localDatabaseProvider));
  return cache.listActiveSummaries();
});

final collectionByCatalogRefProvider =
    Provider<Map<CatalogEntityRef, OwnedItemSummary>>((ref) {
  final collection = ref.watch(collectionSummariesProvider);
  return collection.maybeWhen(
    data: (items) => {
      for (final item in items)
        if (!item.isDeleted && item.catalogRef != null) item.catalogRef!: item,
    },
    orElse: () => const <CatalogEntityRef, OwnedItemSummary>{},
  );
});

final collectionSummariesProvider =
    FutureProvider<List<OwnedItemSummary>>((ref) async {
  final cache = OwnedItemsRepository(ref.watch(localDatabaseProvider));
  return cache.listActiveSummaries();
});

final trackingEntriesProvider =
    FutureProvider<List<TrackingEntry>>((ref) async {
  final cache = TrackingEntriesCacheRepository(
    ref.watch(localDatabaseProvider),
    codecs: collectarrTrackingEntryCodecs,
  );
  return cache.listActive();
});

final trackingEntriesByCatalogRefProvider =
    Provider<Map<CatalogEntityRef, List<TrackingEntry>>>((ref) {
  final tracking = ref.watch(trackingEntriesProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <CatalogEntityRef, List<TrackingEntry>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.catalogRef, () => <TrackingEntry>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <CatalogEntityRef, List<TrackingEntry>>{},
  );
});

final trackingUnitsProvider = FutureProvider<List<TrackingUnit>>((ref) async {
  final cache = TrackingUnitsCacheRepository(
    ref.watch(localDatabaseProvider),
    codecs: collectarrTrackingUnitCodecs,
  );
  return cache.listActive();
});

final trackingUnitsByCatalogRefMapProvider =
    Provider<Map<CatalogEntityRef, List<TrackingUnit>>>((ref) {
  final tracking = ref.watch(trackingUnitsProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <CatalogEntityRef, List<TrackingUnit>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.targetRef, () => <TrackingUnit>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <CatalogEntityRef, List<TrackingUnit>>{},
  );
});

final trackingUnitsByCatalogRefProvider =
    Provider.family<List<TrackingUnit>, CatalogEntityRef>((ref, catalogRef) {
  return ref.watch(trackingUnitsByCatalogRefMapProvider)[catalogRef] ??
      const <TrackingUnit>[];
});

final wishlistByCatalogRefProvider =
    Provider<Map<CatalogEntityRef, List<WishlistItem>>>((ref) {
  final wishlist = ref.watch(wishlistProvider);
  return wishlist.maybeWhen(
    data: (items) {
      final grouped = <CatalogEntityRef, List<WishlistItem>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.catalogRef, () => <WishlistItem>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <CatalogEntityRef, List<WishlistItem>>{},
  );
});

final wishlistRefsProvider = FutureProvider<Set<CatalogEntityRef>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  final items = await cache.listActive();
  return {
    for (final item in items)
      if (!item.isDeleted) item.catalogRef,
  };
});

final watchSessionsProvider = FutureProvider<List<WatchSession>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final repository = WatchSessionsRepository(
    db,
    codecs: collectarrWatchSessionCodecs,
  );
  return repository.listActive();
});

final watchSessionsByCatalogRefProvider =
    Provider.family<List<WatchSession>, CatalogEntityRef>((ref, catalogRef) {
  final sessions = ref.watch(watchSessionsProvider);
  return sessions.maybeWhen(
    data: (items) {
      final rootPrefix = _catalogRefSessionPrefix(catalogRef);
      final matched = items.where((session) {
        final targetId = session.targetRef.id;
        return targetId == catalogRef.id ||
            targetId.startsWith(rootPrefix) ||
            (catalogRef.entityType == CatalogEntityType.work &&
                targetId.startsWith('${catalogRef.id}:release:'));
      }).toList(growable: false);
      matched.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
      return matched;
    },
    orElse: () => const <WatchSession>[],
  );
});

String _catalogRefSessionPrefix(CatalogEntityRef catalogRef) {
  return switch (catalogRef.entityType) {
    CatalogEntityType.work => '${catalogRef.id}:season:',
    CatalogEntityType.season => '${catalogRef.id}:episode:',
    CatalogEntityType.episode => '${catalogRef.id}:',
    CatalogEntityType.release => '${catalogRef.id}:',
    _ => '${catalogRef.id}:',
  };
}

final metadataOverridesProvider =
    FutureProvider<List<UserMetadataOverride>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  return UserMetadataOverridesCacheRepository(db).listActive();
});

final metadataOverridesByItemProvider =
    Provider<Map<CatalogEntityRef, List<UserMetadataOverride>>>((ref) {
  final overrides = ref.watch(metadataOverridesProvider);
  return overrides.maybeWhen(
    data: (items) {
      final grouped = <CatalogEntityRef, List<UserMetadataOverride>>{};
      for (final o in items) {
        if (o.isDeleted) continue;
        grouped.putIfAbsent(o.targetRef, () => <UserMetadataOverride>[]).add(o);
      }
      return grouped;
    },
    orElse: () => const <CatalogEntityRef, List<UserMetadataOverride>>{},
  );
});

final userExternalLinksByItemProvider =
    FutureProvider.family<List<UserExternalLink>, CatalogEntityRef>(
        (ref, catalogRef) async {
  final db = ref.watch(localDatabaseProvider);
  return UserExternalLinksCacheRepository(db).listByCatalogRef(catalogRef);
});

final customEpisodesByCatalogRefProvider =
    FutureProvider.family<Map<int, List<CustomEpisode>>, CatalogEntityRef>(
        (ref, catalogRef) async {
  final db = ref.watch(localDatabaseProvider);
  return CustomEpisodesRepository(
    db,
    codecs: collectarrCustomEpisodeCodecs,
  ).listByCatalogRefGrouped(catalogRef);
});

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});
