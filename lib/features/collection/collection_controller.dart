import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/tracking_unit_summary.dart';
import 'package:collectarr_app/core/models/user_metadata_override.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/features/library/ownership/owned_items_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_summary_repository.dart';
import 'package:collectarr_app/features/library/tracking/tracking_unit_storage_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_metadata_overrides_cache_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/collection/repositories/wishlist_items_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/features/library/tracking/watch_session_codec.dart';
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

/// Structural tracking projection for mixed/global consumers.
///
/// Collection/Shelf/Activity must not carry the full tracking aggregate.
final trackingSummariesProvider =
    FutureProvider<List<TrackingSummary>>((ref) async {
  return TrackingSummaryRepository(ref.watch(localDatabaseProvider))
      .listActive();
});

final trackingSummariesByCatalogRefProvider =
    Provider<Map<CatalogEntityRef, List<TrackingSummary>>>((ref) {
  final tracking = ref.watch(trackingSummariesProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <CatalogEntityRef, List<TrackingSummary>>{};
      for (final item in items) {
        if (item.isDeleted) continue;
        grouped
            .putIfAbsent(item.catalogRef, () => <TrackingSummary>[])
            .add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <CatalogEntityRef, List<TrackingSummary>>{},
  );
});

final trackingUnitsProvider =
    FutureProvider<List<TrackingUnitSummary>>((ref) async {
  final cache = TrackingUnitStorageRepository(
    ref.watch(localDatabaseProvider),
    codecs: libraryTrackingUnitCodecs,
  );
  return cache.listActive();
});

final trackingUnitsByCatalogRefMapProvider =
    Provider<Map<CatalogEntityRef, List<TrackingUnitSummary>>>((ref) {
  final tracking = ref.watch(trackingUnitsProvider);
  return tracking.maybeWhen(
    data: (items) {
      final grouped = <CatalogEntityRef, List<TrackingUnitSummary>>{};
      for (final item in items) {
        if (item.isDeleted) {
          continue;
        }
        grouped
            .putIfAbsent(item.targetRef, () => <TrackingUnitSummary>[])
            .add(item);
      }
      for (final entries in grouped.values) {
        entries.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      }
      return grouped;
    },
    orElse: () => const <CatalogEntityRef, List<TrackingUnitSummary>>{},
  );
});

final trackingUnitsByCatalogRefProvider =
    Provider.family<List<TrackingUnitSummary>, CatalogEntityRef>(
        (ref, catalogRef) {
  return ref.watch(trackingUnitsByCatalogRefMapProvider)[catalogRef] ??
      const <TrackingUnitSummary>[];
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
    codecs: libraryWatchSessionCodecs,
  );
  return repository.listActive();
});

final watchSessionsByCatalogRefProvider =
    Provider.family<List<WatchSession>, CatalogEntityRef>((ref, catalogRef) {
  final sessions = ref.watch(watchSessionsProvider);
  return sessions.maybeWhen(
    data: (items) {
      final codec = _watchSessionCodecFor(catalogRef.mediaKind);
      final matched = items.where((session) {
        return codec?.matchesCatalogScope(session, catalogRef) ?? false;
      }).toList(growable: false);
      matched.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
      return matched;
    },
    orElse: () => const <WatchSession>[],
  );
});

WatchSessionCodec? _watchSessionCodecFor(CatalogMediaKind kind) {
  for (final codec in libraryWatchSessionCodecs) {
    if (codec.kind == kind) return codec;
  }
  return null;
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

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final cache = WishlistItemsCacheRepository(ref.watch(localDatabaseProvider));
  return cache.listActive();
});
