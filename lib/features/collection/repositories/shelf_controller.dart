import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_collection_item_persistence.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_catalog_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
export 'package:collectarr_app/core/models/tracking_summary.dart';

final shelfProvider = FutureProvider<ShelfState>((ref) async {
  final ownedSummaries = await ref.watch(collectionSummariesProvider.future);
  final wishlist = await ref.watch(wishlistProvider.future);
  final trackingSummaries = await ref.watch(trackingSummariesProvider.future);
  final auth = ref.watch(authControllerProvider);
  final db = ref.watch(localDatabaseProvider);
  final ownedRepository = CollectarrCollectionItemPersistence(db);
  final typedOwnedResults = await Future.wait(
    ownedSummaries.map(
      (summary) => ownedRepository.collectionItemForLibraryByRef(summary.ref),
    ),
  );
  final collectionItemDispatchesByRef = <CollectionItemRef, LibraryCollectionItemDispatch>{};
  for (var index = 0; index < typedOwnedResults.length; index++) {
    final result = typedOwnedResults[index];
    if (result != null) {
      collectionItemDispatchesByRef[ownedSummaries[index].ref] = result;
    }
  }
  final catalogRefs = <CatalogEntityRef>{
    for (final item in ownedSummaries)
      if (item.catalogRef != null) item.catalogRef!.rootScope,
    for (final item in wishlist)
      CatalogEntityRef(
        kind: item.catalogRef.kind,
        entityType: CatalogEntityTypeId.catalogItem,
        id: item.catalogRef.id,
      ),
    for (final item in trackingSummaries) item.catalogRef.rootScope,
  };
  final catalogSummaries =
      await CatalogDisplaySummaryRepository(db).findByRefs(catalogRefs);
  // Read transport only at the repository boundary, then immediately
  // dispatch into structural kind-owned workspace data. Shelf never carries
  // a generic catalog snapshot.
  final catalogDataByRef =
      await CatalogWorkspaceDataRepository(db).findByRefs(catalogRefs);
  final locations = await LocationRepository(db).getAll();
  final watchSessions = await WatchSessionsRepository(
    db,
    codecs: libraryWatchSessionCodecs,
  ).listActiveByCatalogRefs(catalogRefs);
  final itemImagesByCollectionItem = await ItemImageRepository(db).listForCollectionItemRefs(
    ownedSummaries.map((item) => item.ref),
  );
  return ShelfState.from(
    ownedSummaries: ownedSummaries,
    wishlistItems: wishlist,
    trackingSummaries: trackingSummaries,
    watchSessions: watchSessions,
    catalogSummariesByRef: catalogSummaries,
    catalogDataByRef: catalogDataByRef,
    locations: locations,
    itemImagesByCollectionItem: itemImagesByCollectionItem,
    collectionItemDispatchesByRef: collectionItemDispatchesByRef,
    fallbackOwnerLabel: auth.email,
  );
});

class ShelfState {
  const ShelfState({
    required this.entries,
    required this.ownedCount,
    required this.wishlistCount,
    required this.pricedCount,
    required this.totalPaidCents,
    required this.primaryCurrency,
    required this.hasMixedCurrencies,
    this.wishlistItemCountByKind = const <String, int>{},
    this.missingMetadataCount = 0,
    this.locationCounts = const {},
    this.soldCount = 0,
    this.totalSellCents,
    this.marketValuedCount = 0,
    this.totalMarketValueCents,
    this.collectionItemCountByKind = const <String, int>{},
  });

  factory ShelfState.from({
    Iterable<CollectionItemSummary>? ownedSummaries,
    required List<WishlistItem> wishlistItems,
    Iterable<TrackingSummary>? trackingSummaries,
    Map<CollectionItemRef, LibraryCollectionItemDispatch> collectionItemDispatchesByRef =
        const <CollectionItemRef, LibraryCollectionItemDispatch>{},
    List<WatchSession> watchSessions = const [],
    Map<CatalogEntityRef, CatalogDisplaySummary>? catalogSummariesByRef,
    Map<CatalogEntityRef, LibraryWorkspaceCatalogData>? catalogDataByRef,
    List<StorageLocation> locations = const [],
    Map<CollectionItemRef, List<ItemImage>> itemImagesByCollectionItem =
        const <CollectionItemRef, List<ItemImage>>{},
    String? fallbackOwnerLabel,
  }) {
    final workspaceCatalogByRef =
        <CatalogEntityRef, LibraryWorkspaceCatalogData>{
      ...?catalogDataByRef,
    };
    final resolvedCatalogSummariesByRef =
        Map<CatalogEntityRef, CatalogDisplaySummary>.unmodifiable(
      catalogSummariesByRef ??
          const <CatalogEntityRef, CatalogDisplaySummary>{},
    );
    final resolvedOwnedSummaries =
        ownedSummaries?.toList(growable: false) ?? const <CollectionItemSummary>[];
    final resolvedTrackingSummaries =
        trackingSummaries?.toList(growable: false) ?? const <TrackingSummary>[];
    final locationPathsById = {
      for (final location in locations)
        location.id: location.fullPath(locations),
    };
    final ownedCatalogRefs = <CatalogEntityRef>{
      for (final item in resolvedOwnedSummaries)
        if (!item.isDeleted && item.catalogRef != null)
          item.catalogRef!.rootScope,
    };
    final wishlistByCatalogRef = <CatalogEntityRef, WishlistItem>{
      for (final item in wishlistItems)
        if (!item.isDeleted)
          CatalogEntityRef(
            kind: item.catalogRef.kind,
            entityType: CatalogEntityTypeId.catalogItem,
            id: item.catalogRef.id,
          ): item,
    };
    final trackingByCatalogRef = <CatalogEntityRef, List<TrackingSummary>>{};
    for (final entry in resolvedTrackingSummaries) {
      final catalogRef = entry.catalogRef.rootScope;
      if (entry.isDeleted) {
        continue;
      }
      trackingByCatalogRef
          .putIfAbsent(catalogRef, () => <TrackingSummary>[])
          .add(entry);
    }
    for (final entries in trackingByCatalogRef.values) {
      entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    final watchSessionsByCatalogRef = <CatalogEntityRef, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (session.isDeleted) {
        continue;
      }
      final catalogRef = session.targetRef.rootScope;
      watchSessionsByCatalogRef
          .putIfAbsent(catalogRef, () => <WatchSession>[])
          .add(session);
    }
    for (final sessions in watchSessionsByCatalogRef.values) {
      sessions.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    }
    final refs = <CatalogEntityRef>{
      ...ownedCatalogRefs,
      ...wishlistByCatalogRef.keys,
      ...trackingByCatalogRef.keys,
    };
    LibraryWorkspaceSource buildEntry(
      CatalogEntityRef ref, {
      CollectionItemSummary? owned,
    }) =>
        LibraryWorkspaceSource(
          itemId: ref.id,
          // Each owned row is a distinct collection entry. Catalog metadata
          // and catalog-level activity can be shared, while personal state
          // and image overrides stay attached to this one copy.
          catalogSummary: resolvedCatalogSummariesByRef[ref],
          catalogSearchTokens: [
            if (resolvedCatalogSummariesByRef[ref]?.primaryLabel
                case final title?)
              title,
          ],
          collectionItemSummary: owned,
          trackingSummary: trackingByCatalogRef[ref]?.firstOrNull,
          trackingSummaries:
              trackingByCatalogRef[ref] ?? const <TrackingSummary>[],
          catalogData: workspaceCatalogByRef[ref],
          collectionItemDispatch:
              owned == null ? null : collectionItemDispatchesByRef[owned.ref],
          wishlistItem: wishlistByCatalogRef[ref],
          locationPath: locationPathsById[owned?.locationId],
          watchSessions:
              watchSessionsByCatalogRef[ref] ?? const <WatchSession>[],
          itemImages: owned == null
              ? const <ItemImage>[]
              : itemImagesByCollectionItem[owned.ref] ?? const <ItemImage>[],
          fallbackOwnerLabel: fallbackOwnerLabel,
        );
    final entries = <LibraryWorkspaceSource>[
      for (final owned in resolvedOwnedSummaries)
        if (!owned.isDeleted && owned.catalogRef != null)
          buildEntry(owned.catalogRef!.rootScope, owned: owned),
      for (final ref in refs)
        if (!ownedCatalogRefs.contains(ref)) buildEntry(ref),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final pricedOwned = resolvedOwnedSummaries
        .where((item) => item.pricePaidCents != null && item.currency != null)
        .toList(growable: false);
    final currencies = {
      for (final item in pricedOwned) item.currency!,
    };
    final hasMixedCurrencies = currencies.length > 1;
    final activeOwned = resolvedOwnedSummaries
        .where((item) => !item.isDeleted && item.catalogRef != null)
        .toList(growable: false);
    final collectionItemCountByKind = <String, int>{};
    for (final item in resolvedOwnedSummaries) {
      if (item.isDeleted || item.catalogRef == null) continue;
      final kind = item.catalogRef!.mediaKind.apiValue;
      collectionItemCountByKind[kind] = (collectionItemCountByKind[kind] ?? 0) + 1;
    }
    final wishlistItemCountByKind = <String, int>{};
    for (final item in wishlistByCatalogRef.values) {
      final kind = item.catalogRef.kind.apiValue;
      wishlistItemCountByKind[kind] = (wishlistItemCountByKind[kind] ?? 0) + 1;
    }
    return ShelfState(
      entries: entries,
      ownedCount: activeOwned.length,
      wishlistCount: wishlistByCatalogRef.length,
      pricedCount: pricedOwned.length,
      totalPaidCents: hasMixedCurrencies
          ? null
          : pricedOwned.fold<int>(
              0,
              (total, item) => total + (item.pricePaidCents ?? 0),
            ),
      primaryCurrency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: hasMixedCurrencies,
      wishlistItemCountByKind: wishlistItemCountByKind,
      missingMetadataCount:
          entries.where((entry) => entry.catalogSummary == null).length,
      locationCounts: _counts(
        entries
            .where((entry) => entry.isOwned)
            .map((entry) => entry.locationPath ?? 'No location'),
      ),
      soldCount: activeOwned.where((item) => item.soldAt != null).length,
      totalSellCents: hasMixedCurrencies
          ? null
          : activeOwned
              .where((item) => item.sellPriceCents != null)
              .fold<int>(0, (total, item) => total + item.sellPriceCents!),
      marketValuedCount:
          activeOwned.where((item) => item.marketValueCents != null).length,
      totalMarketValueCents: hasMixedCurrencies
          ? null
          : activeOwned
              .where((item) => item.marketValueCents != null)
              .fold<int>(0, (total, item) => total + item.marketValueCents!),
      collectionItemCountByKind: collectionItemCountByKind,
    );
  }

  final int ownedCount;

  /// Structural workspace sources used by mixed Shelf hosts and by the
  /// kind-specific Library projection pipeline.
  final List<LibraryWorkspaceSource> entries;

  /// Aggregate projection for the Stats dashboard. Keep kind semantics in
  /// their contributors rather than exposing them as universal Shelf filters.
  final int wishlistCount;
  final int pricedCount;
  final int? totalPaidCents;
  final String? primaryCurrency;
  final bool hasMixedCurrencies;
  final Map<String, int> wishlistItemCountByKind;
  final int missingMetadataCount;
  final Map<String, int> locationCounts;
  final int soldCount;
  final int? totalSellCents;
  final int marketValuedCount;
  final int? totalMarketValueCents;
  final Map<String, int> collectionItemCountByKind;

  static Map<String, int> _counts(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }
}
