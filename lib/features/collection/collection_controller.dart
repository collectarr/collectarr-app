import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/custom_episode.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/tracking_unit.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/collection/repositories/owned_items_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_entries_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/tracking_units_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/custom_episodes_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionProvider = FutureProvider<List<OwnedItem>>((ref) async {
  final cache = OwnedItemsCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});

final collectionByCatalogItemProvider = Provider<Map<String, OwnedItem>>((ref) {
  final collection = ref.watch(collectionProvider);
  return collection.maybeWhen(
    data: (items) => {
      for (final item in items)
        if (!item.isDeleted) item.catalogRef.id: item,
    },
    orElse: () => const {},
  );
});

final trackingEntriesProvider = FutureProvider<List<TrackingEntry>>((ref) async {
  final cache = TrackingEntriesCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});

final trackingEntriesByCatalogItemProvider =
    Provider<Map<String, List<TrackingEntry>>>((ref) {
  final tracking = ref.watch(trackingEntriesProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <String, List<TrackingEntry>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.catalogRef.id, () => <TrackingEntry>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <String, List<TrackingEntry>>{},
  );
});

final trackingUnitsProvider = FutureProvider<List<TrackingUnit>>((ref) async {
  final cache = TrackingUnitsCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});

final trackingUnitsByCatalogItemProvider =
    Provider<Map<String, List<TrackingUnit>>>((ref) {
  final tracking = ref.watch(trackingUnitsProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <String, List<TrackingUnit>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.targetRef.id, () => <TrackingUnit>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) {
          final seasonCompare =
              (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0);
          if (seasonCompare != 0) {
            return seasonCompare;
          }
          final episodeCompare =
              (a.episodeNumber ?? 0).compareTo(b.episodeNumber ?? 0);
          if (episodeCompare != 0) {
            return episodeCompare;
          }
          final volumeCompare =
              (a.volumeNumber ?? 0).compareTo(b.volumeNumber ?? 0);
          if (volumeCompare != 0) {
            return volumeCompare;
          }
          final chapterCompare =
              (a.chapterNumber ?? 0).compareTo(b.chapterNumber ?? 0);
          if (chapterCompare != 0) {
            return chapterCompare;
          }
          return a.updatedAt.compareTo(b.updatedAt);
        });
      }
      return grouped;
    },
    orElse: () => const <String, List<TrackingUnit>>{},
  );
});

final trackingUnitsByCatalogRefProvider =
    Provider.family<List<TrackingUnit>, CatalogEntityRef>((ref, catalogRef) {
  return ref.watch(trackingUnitsByCatalogItemProvider)[catalogRef.id] ??
      const <TrackingUnit>[];
});

final wishlistByCatalogItemProvider =
    Provider<Map<String, List<WishlistItem>>>((ref) {
  final wishlist = ref.watch(wishlistProvider);
  return wishlist.maybeWhen(
    data: (items) {
      final grouped = <String, List<WishlistItem>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped.putIfAbsent(item.catalogRef.id, () => <WishlistItem>[]).add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <String, List<WishlistItem>>{},
  );
});

final wishlistIdsProvider = FutureProvider<Set<String>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  final items = await cache.listActive();
  return {
    for (final item in items)
      if (!item.isDeleted) item.catalogRef.id,
  };
});

final watchSessionsProvider = FutureProvider<List<WatchSession>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final cache = WatchSessionsCacheRepository(db);
  return cache.listActive();
});

final watchSessionsByItemProvider =
    Provider<Map<String, List<WatchSession>>>((ref) {
  final sessions = ref.watch(watchSessionsProvider);
  return sessions.maybeWhen(
    data: (items) {
      final grouped = <String, List<WatchSession>>{};
      for (final session in items) {
        if (session.isDeleted) continue;
        grouped.putIfAbsent(session.targetRef.id, () => <WatchSession>[]).add(session);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
      }
      return grouped;
    },
    orElse: () => const <String, List<WatchSession>>{},
  );
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
    Provider<Map<String, List<UserMetadataOverride>>>((ref) {
  final overrides = ref.watch(metadataOverridesProvider);
  return overrides.maybeWhen(
    data: (items) {
      final grouped = <String, List<UserMetadataOverride>>{};
      for (final o in items) {
        if (o.isDeleted) continue;
        grouped.putIfAbsent(o.itemId, () => <UserMetadataOverride>[]).add(o);
      }
      return grouped;
    },
    orElse: () => const <String, List<UserMetadataOverride>>{},
  );
});

final userExternalLinksByItemProvider =
  FutureProvider.family<List<UserExternalLink>, String>((ref, itemId) async {
final db = ref.watch(localDatabaseProvider);
return UserExternalLinksCacheRepository(db).listByItemId(itemId);
});

final customEpisodesByItemProvider =
  FutureProvider.family<Map<int, List<CustomEpisode>>, String>(
      (ref, itemId) async {
  final db = ref.watch(localDatabaseProvider);
  return CustomEpisodesCacheRepository(db).listByItemIdGrouped(itemId);
});

final customEpisodesByCatalogRefProvider = FutureProvider.family<
    Map<int, List<CustomEpisode>>,
    CatalogEntityRef>((ref, catalogRef) async {
  final db = ref.watch(localDatabaseProvider);
  return CustomEpisodesCacheRepository(db).listByItemIdGrouped(catalogRef.id);
});

/// Groups owned items by box set name for summary display.
final boxSetGroupsProvider =
    Provider<Map<String, List<OwnedItem>>>((ref) {
  final collection = ref.watch(collectionProvider);
  return collection.maybeWhen(
    data: (items) {
      final grouped = <String, List<OwnedItem>>{};
      for (final item in items) {
        if (item.isDeleted) continue;
        final name = item.boxSetName;
        if (name != null && name.isNotEmpty) {
          grouped.putIfAbsent(name, () => <OwnedItem>[]).add(item);
        }
      }
      return grouped;
    },
    orElse: () => const <String, List<OwnedItem>>{},
  );
});

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});
