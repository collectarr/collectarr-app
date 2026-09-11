import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_search_candidate.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_owned_item_persistence.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_source.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_owned_item_dispatch.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
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
  final ownedRepository = CollectarrOwnedItemPersistence(db);
  final typedOwnedResults = await Future.wait(
    ownedSummaries.map(
      (summary) => ownedRepository.ownedItemForLibraryByRef(summary.ref),
    ),
  );
  final ownedItemDispatchesByRef = <OwnedItemRef, LibraryOwnedItemDispatch>{};
  for (var index = 0; index < typedOwnedResults.length; index++) {
    final result = typedOwnedResults[index];
    if (result != null) {
      ownedItemDispatchesByRef[ownedSummaries[index].ref] = result;
    }
  }
  final catalogRefs = <CatalogEntityRef>{
    for (final item in ownedSummaries)
      if (item.catalogRef != null) _rootCatalogRef(item.catalogRef!),
    for (final item in wishlist) _rootCatalogRef(item.catalogRef),
    for (final item in trackingSummaries) _rootCatalogRef(item.catalogRef),
  };
  final catalogSummaries =
      await CatalogDisplaySummaryRepository(db).findByRefs(catalogRefs);
  // Library kind contributors receive transport snapshots only at this
  // explicit boundary. Joins are keyed by the complete catalog reference so
  // equal IDs across kinds cannot collide.
  final catalogSnapshotsByRef = (await CatalogSnapshotRepository(db)
          .findByRefs(catalogRefs))
      .map((ref, item) => MapEntry(ref, CatalogSearchCandidate.fromItem(item)));
  final locations = await LocationRepository(db).getAll();
  final watchSessions = await WatchSessionsRepository(
    db,
    codecs: collectarrWatchSessionCodecs,
  ).listActiveByCatalogRefs(catalogRefs);
  final itemImagesByOwnedItem = await ItemImageRepository(db).listForOwnedRefs(
    ownedSummaries.map((item) => item.ref),
  );
  return ShelfState.from(
    ownedSummaries: ownedSummaries,
    wishlistItems: wishlist,
    trackingSummaries: trackingSummaries,
    watchSessions: watchSessions,
    catalogSummariesByRef: catalogSummaries,
    catalogSnapshotsByRef: catalogSnapshotsByRef,
    locations: locations,
    itemImagesByOwnedItem: itemImagesByOwnedItem,
    ownedItemDispatchesByRef: ownedItemDispatchesByRef,
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
    this.totalQuantity = 0,
    this.missingMetadataCount = 0,
    this.locationCounts = const {},
    this.soldCount = 0,
    this.totalSellCents,
    this.marketValuedCount = 0,
    this.totalMarketValueCents,
  });

  factory ShelfState.from({
    Iterable<OwnedItemSummary>? ownedSummaries,
    required List<WishlistItem> wishlistItems,
    Iterable<TrackingSummary>? trackingSummaries,
    Map<OwnedItemRef, LibraryOwnedItemDispatch> ownedItemDispatchesByRef =
        const <OwnedItemRef, LibraryOwnedItemDispatch>{},
    List<WatchSession> watchSessions = const [],
    Map<CatalogEntityRef, CatalogDisplaySummary>? catalogSummariesByRef,
    Map<CatalogEntityRef, CatalogSearchCandidate>? catalogSnapshotsByRef,
    List<StorageLocation> locations = const [],
    Map<OwnedItemRef, List<ItemImage>> itemImagesByOwnedItem =
        const <OwnedItemRef, List<ItemImage>>{},
    String? fallbackOwnerLabel,
  }) {
    final catalogByRef = <CatalogEntityRef, CatalogSearchCandidate>{
      ...?catalogSnapshotsByRef,
    };
    final resolvedCatalogSummariesByRef =
        Map<CatalogEntityRef, CatalogDisplaySummary>.unmodifiable(
      catalogSummariesByRef ?? const <CatalogEntityRef, CatalogDisplaySummary>{},
    );
    final resolvedOwnedSummaries =
        ownedSummaries?.toList(growable: false) ?? const <OwnedItemSummary>[];
    final resolvedTrackingSummaries =
        trackingSummaries?.toList(growable: false) ?? const <TrackingSummary>[];
    final locationPathsById = {
      for (final location in locations)
        location.id: location.fullPath(locations),
    };
    final ownedByCatalogRef = <CatalogEntityRef, OwnedItemSummary>{
      for (final item in resolvedOwnedSummaries)
        if (!item.isDeleted && item.catalogRef != null)
          _rootCatalogRef(item.catalogRef!): item,
    };
    final wishlistByCatalogRef = <CatalogEntityRef, WishlistItem>{
      for (final item in wishlistItems)
        if (!item.isDeleted) _rootCatalogRef(item.catalogRef): item,
    };
    final trackingByCatalogRef = <CatalogEntityRef, TrackingSummary>{};
    for (final entry in resolvedTrackingSummaries) {
      final catalogRef = _rootCatalogRef(entry.catalogRef);
      if (entry.isDeleted || trackingByCatalogRef.containsKey(catalogRef)) {
        continue;
      }
      trackingByCatalogRef[catalogRef] = entry;
    }
    final watchSessionsByCatalogRef = <CatalogEntityRef, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (session.isDeleted) {
        continue;
      }
      final catalogRef = CatalogEntityRef(
        kind: session.targetRef.kind,
        entityType: const CatalogEntityTypeId('work'),
        id: session.targetRef.rootId ?? session.targetRef.id,
      );
      watchSessionsByCatalogRef
          .putIfAbsent(catalogRef, () => <WatchSession>[])
          .add(session);
    }
    for (final sessions in watchSessionsByCatalogRef.values) {
      sessions.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    }
    final refs = <CatalogEntityRef>{
      ...ownedByCatalogRef.keys,
      ...wishlistByCatalogRef.keys,
      ...trackingByCatalogRef.keys,
    };
    final entries = [
      for (final ref in refs) ...[
        LibraryWorkspaceSource(
          itemId: ref.id,
          // Mixed/global Shelf rendering is summary-only. The transport
          // snapshot below is retained solely for the owning kind's typed
          // workspace projector.
          catalogSummary: resolvedCatalogSummariesByRef[ref],
          catalogSearchTokens: _catalogSearchTokens(catalogByRef[ref]),
          ownedSummary: ownedByCatalogRef[ref],
          trackingSummary: trackingByCatalogRef[ref],
          // Transport snapshots remain available only to the typed Library
          // contributors that have not yet moved to their domain repository.
          catalogTransport: catalogByRef[ref],
          ownedItemDispatch: ownedByCatalogRef[ref] == null
              ? null
              : ownedItemDispatchesByRef[ownedByCatalogRef[ref]!.ref],
          wishlistItem: wishlistByCatalogRef[ref],
          locationPath:
              locationPathsById[ownedByCatalogRef[ref]?.locationLabel],
          watchSessions:
              watchSessionsByCatalogRef[ref] ?? const <WatchSession>[],
          itemImages: itemImagesByOwnedItem[ownedByCatalogRef[ref]?.ref] ??
              const <ItemImage>[],
          fallbackOwnerLabel: fallbackOwnerLabel,
        ),
      ],
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final pricedOwned = resolvedOwnedSummaries
        .where((item) => item.pricePaidCents != null && item.currency != null)
        .toList(growable: false);
    final currencies = {
      for (final item in pricedOwned) item.currency!,
    };
    final hasMixedCurrencies = currencies.length > 1;
    final activeOwned = ownedByCatalogRef.values.toList(growable: false);
    return ShelfState(
      entries: entries,
      ownedCount: ownedByCatalogRef.length,
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
      totalQuantity: activeOwned.fold<int>(
        0,
        (total, item) => total + item.quantity,
      ),
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
  final int totalQuantity;
  final int missingMetadataCount;
  final Map<String, int> locationCounts;
  final int soldCount;
  final int? totalSellCents;
  final int marketValuedCount;
  final int? totalMarketValueCents;

  static Map<String, int> _counts(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }
}

/// Workspace source carrying the structural summary and the transport
/// snapshot required by the current kind-specific Library projectors.
CatalogEntityRef _rootCatalogRef(CatalogEntityRef ref) {
  final rootId = ref.rootId;
  if (rootId != null && rootId.isNotEmpty) {
    return ref.copyWith(
      id: rootId,
      entityType: const CatalogEntityTypeId('work'),
      rootId: null,
    );
  }
  if (ref.entityType == const CatalogEntityTypeId('owned_copy') ||
      ref.entityType == const CatalogEntityTypeId('copy') ||
      ref.entityType == const CatalogEntityTypeId('tracking_entry')) {
    return ref.copyWith(entityType: const CatalogEntityTypeId('work'));
  }
  return ref;
}

List<String> _catalogSearchTokens(CatalogSearchCandidate? item) {
  if (item == null) {
    return const <String>[];
  }
  return [
    if (item.displayTitle case final value?) value,
    if (item.localizedTitle case final value?) value,
    if (item.originalTitle case final value?) value,
    ...?item.searchAliases,
  ];
}
