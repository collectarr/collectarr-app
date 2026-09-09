import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shelfProvider = FutureProvider<ShelfState>((ref) async {
  final ownedSummaries = await ref.watch(collectionSummariesProvider.future);
  final wishlist = await ref.watch(wishlistProvider.future);
  final trackingEntries = await ref.watch(trackingEntriesProvider.future);
  final auth = ref.watch(authControllerProvider);
  final db = ref.watch(localDatabaseProvider);
  final catalogRefs = <CatalogEntityRef>{
    for (final item in ownedSummaries)
      if (item.catalogRef != null) _rootCatalogRef(item.catalogRef!),
    for (final item in wishlist) _rootCatalogRef(item.catalogRef),
    for (final item in trackingEntries) _rootCatalogRef(item.catalogRef),
  };
  final catalogSummaries =
      await CatalogDisplaySummaryRepository(db).findByRefs(catalogRefs);
  // This is a compatibility adapter for Library kind contributors only. Even
  // while those contributors still consume the transport snapshot, joins are
  // keyed by the complete catalog reference so equal IDs across kinds cannot
  // collide.
  final legacyCatalogItems =
      await CatalogSnapshotRepository(db).findByRefs(catalogRefs);
  final locations = await LocationRepository(db).getAll();
  final watchSessions = await WatchSessionsRepository(
    db,
    codecs: collectarrWatchSessionCodecs,
  ).listActiveByCatalogRefs(catalogRefs);
  final itemImagesByOwnedItem =
      await ItemImageRepository(db).listForOwnedItemIds(
    ownedSummaries.map((item) => item.ref.id.value),
  );
  return ShelfState.from(
    ownedSummaries: ownedSummaries,
    wishlistItems: wishlist,
    trackingSummaries:
        trackingEntries.map(TrackingSummary.fromEntry).toList(growable: false),
    legacyTrackingEntries: trackingEntries,
    watchSessions: watchSessions,
    catalogSummariesByRef: catalogSummaries,
    legacyCatalogItemsByRef: legacyCatalogItems,
    locations: locations,
    itemImagesByOwnedItem: itemImagesByOwnedItem,
    fallbackOwnerLabel: auth.email,
  );
});

class ShelfState {
  const ShelfState({
    required this.entries,
    this.workspaceEntries,
    required this.ownedCount,
    required this.missingGradeCount,
    required this.wishlistCount,
    required this.pricedCount,
    required this.totalPaidCents,
    required this.primaryCurrency,
    required this.hasMixedCurrencies,
    this.totalQuantity = 0,
    this.missingMetadataCount = 0,
    this.gradeCounts = const {},
    this.conditionCounts = const {},
    this.readStatusCounts = const {},
    this.locationCounts = const {},
    this.seriesCounts = const {},
    this.soldCount = 0,
    this.totalSellCents,
    this.marketValuedCount = 0,
    this.totalMarketValueCents,
  });

  factory ShelfState.from({
    Iterable<OwnedItemSummary>? ownedSummaries,
    Iterable<OwnedItem>? ownedItems,
    Iterable<OwnedItem>? legacyOwnedItems,
    required List<WishlistItem> wishlistItems,
    Iterable<TrackingSummary>? trackingSummaries,
    List<TrackingEntry> trackingEntries = const [],
    Iterable<TrackingEntry>? legacyTrackingEntries,
    List<WatchSession> watchSessions = const [],
    Map<CatalogEntityRef, CatalogDisplaySummary>? catalogSummariesByRef,
    Map<String, CatalogDisplaySummary>? catalogSummaries,
    Map<String, CatalogItemDto>? catalogItems,
    Map<String, CatalogItemDto>? legacyCatalogItems,
    Map<CatalogEntityRef, CatalogItemDto>? legacyCatalogItemsByRef,
    List<StorageLocation> locations = const [],
    Map<String, List<ItemImage>> itemImagesByOwnedItem =
        const <String, List<ItemImage>>{},
    String? fallbackOwnerLabel,
  }) {
    final legacyOwnedList = [
      ...?legacyOwnedItems,
      ...?ownedItems,
    ];
    final legacyTrackingList = [
      ...?legacyTrackingEntries,
      ...trackingEntries,
    ];
    final legacyCatalogById = <String, CatalogItemDto>{
      ...?legacyCatalogItems,
      ...?catalogItems,
    };
    final legacyCatalogByRef = <CatalogEntityRef, CatalogItemDto>{
      ...?legacyCatalogItemsByRef,
      for (final item in legacyCatalogById.values) item.catalogRef: item,
    };
    final resolvedCatalogSummaries = catalogSummaries ??
        {
          for (final item in legacyCatalogById.values)
            item.id: _catalogSummaryFromLegacy(item),
        };
    final resolvedCatalogSummariesByRef = catalogSummariesByRef ??
        {
          for (final summary in resolvedCatalogSummaries.values)
            summary.ref: summary,
        };
    final resolvedOwnedSummaries = ownedSummaries?.toList(growable: false) ??
        [
          for (final item in legacyOwnedList)
            _ownedSummaryFromLegacy(
              item,
              catalogSummary: resolvedCatalogSummariesByRef[
                  _rootCatalogRef(item.catalogRef)],
            ),
        ];
    final resolvedTrackingSummaries =
        trackingSummaries?.toList(growable: false) ??
            [
              for (final entry in legacyTrackingList)
                TrackingSummary.fromEntry(entry),
            ];
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
    final legacyOwnedByCatalogRef = <CatalogEntityRef, OwnedItem>{};
    for (final item in legacyOwnedList) {
      if (!item.isDeleted) {
        legacyOwnedByCatalogRef[_rootCatalogRef(item.catalogRef)] = item;
      }
    }
    final legacyTrackingByCatalogRef = <CatalogEntityRef, TrackingEntry>{};
    for (final entry in legacyTrackingList) {
      if (!entry.isDeleted &&
          !legacyTrackingByCatalogRef
              .containsKey(_rootCatalogRef(entry.catalogRef))) {
        legacyTrackingByCatalogRef[_rootCatalogRef(entry.catalogRef)] = entry;
      }
    }
    final watchSessionsByCatalogRef = <CatalogEntityRef, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (session.isDeleted) {
        continue;
      }
      final catalogRef = CatalogEntityRef(
        kind: session.targetRef.kind,
        entityType: CatalogEntityType.work,
        id: session.itemId,
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
    final workspaceEntries = [
      for (final ref in refs) ...[
        ShelfEntry(
          itemId: ref.id,
          catalogSummary: resolvedCatalogSummariesByRef[ref] ??
              resolvedCatalogSummaries[ref.id],
          ownedSummary: ownedByCatalogRef[ref],
          trackingSummary: trackingByCatalogRef[ref],
          // Compatibility adapters for unchanged Library contributors.
          catalogItem: legacyCatalogByRef[ref],
          ownedItem: legacyOwnedByCatalogRef[ref],
          trackingEntry: legacyTrackingByCatalogRef[ref],
          wishlistItem: wishlistByCatalogRef[ref],
          locationPath:
              locationPathsById[ownedByCatalogRef[ref]?.locationLabel] ??
                  locationPathsById[legacyOwnedByCatalogRef[ref]?.locationId],
          watchSessions:
              watchSessionsByCatalogRef[ref] ?? const <WatchSession>[],
          itemImages: itemImagesByOwnedItem[
                  ownedByCatalogRef[ref]?.ref.id.value ??
                      legacyOwnedByCatalogRef[ref]?.id] ??
              const <ItemImage>[],
          fallbackOwnerLabel: fallbackOwnerLabel,
        ),
      ],
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final entries = [
      for (final ref in refs)
        LibraryEntry(
          itemId: ref.id,
          catalogSummary: resolvedCatalogSummariesByRef[ref] ??
              resolvedCatalogSummaries[ref.id],
          ownedSummary: ownedByCatalogRef[ref],
          trackingSummary: trackingByCatalogRef[ref],
          wishlistItem: wishlistByCatalogRef[ref],
          locationPath:
              locationPathsById[ownedByCatalogRef[ref]?.locationLabel],
          watchSessions:
              watchSessionsByCatalogRef[ref] ?? const <WatchSession>[],
          itemImages:
              itemImagesByOwnedItem[ownedByCatalogRef[ref]?.ref.id.value] ??
                  const <ItemImage>[],
          fallbackOwnerLabel: fallbackOwnerLabel,
        ),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final pricedOwned = resolvedOwnedSummaries
        .where((item) => item.pricePaidCents != null && item.currency != null)
        .toList(growable: false);
    final currencies = {
      for (final item in pricedOwned) item.currency!,
    };
    final hasMixedCurrencies = currencies.length > 1;
    final activeOwned = ownedByCatalogRef.values.toList(growable: false);
    final legacyActiveOwned =
        legacyOwnedByCatalogRef.values.toList(growable: false);
    return ShelfState(
      entries: entries,
      workspaceEntries: workspaceEntries,
      ownedCount: ownedByCatalogRef.length,
      missingGradeCount:
          legacyActiveOwned.where((item) => item.grade == null).length,
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
      gradeCounts: _counts(
        legacyActiveOwned.map((item) => item.grade ?? 'Ungraded'),
      ),
      conditionCounts: _counts(
        legacyActiveOwned.map((item) => item.condition ?? 'Unknown'),
      ),
      readStatusCounts: _counts(
        entries.map(
          (entry) => entry.trackingSummary?.statusLabel ?? 'Not tracked',
        ),
      ),
      locationCounts: _counts(
        entries
            .where((entry) => entry.isOwned)
            .map((entry) => entry.locationPath ?? 'No location'),
      ),
      seriesCounts: _counts(
        entries
            .map((entry) => entry.catalogSummary?.title)
            .whereType<String>()
            .where((title) => title.trim().isNotEmpty),
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

  /// Structural mixed/global entries used by Collection and other hosts.
  final List<LibraryEntry> entries;

  /// Full source entries used only after a kind-specific Library workspace is
  /// selected. The fallback keeps existing fixture construction source
  /// compatible while production state supplies this list explicitly.
  final List<ShelfEntry>? workspaceEntries;

  /// Production callers provide the post-dispatch sources explicitly. The
  /// runtime fallback only recognizes concrete [ShelfEntry] values that may
  /// still be supplied by lightweight fixtures; structural [LibraryEntry]
  /// values are never widened back into workspace sources.
  List<ShelfEntry> get resolvedWorkspaceEntries {
    final sources = workspaceEntries;
    if (sources != null) return sources;
    return [
      for (final entry in entries)
        if (entry case final ShelfEntry source) source,
    ];
  }

  ShelfEntry? workspaceEntryFor(String itemId) {
    for (final entry in resolvedWorkspaceEntries) {
      if (entry.itemId == itemId) return entry;
    }
    return null;
  }

  final int ownedCount;

  /// Aggregate projection for the Stats dashboard. Keep kind semantics in
  /// their contributors rather than exposing them as universal Shelf filters.
  final int missingGradeCount;
  final int wishlistCount;
  final int pricedCount;
  final int? totalPaidCents;
  final String? primaryCurrency;
  final bool hasMixedCurrencies;
  final int totalQuantity;
  final int missingMetadataCount;
  final Map<String, int> gradeCounts;
  final Map<String, int> conditionCounts;
  final Map<String, int> readStatusCounts;
  final Map<String, int> locationCounts;
  final Map<String, int> seriesCounts;
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

class ShelfEntry extends LibraryWorkspaceEntry implements LibraryEntry {
  const ShelfEntry({
    required super.itemId,
    super.catalogSummary,
    super.ownedSummary,
    super.trackingSummary,
    super.wishlistItem,
    super.locationPath,
    super.watchSessions = const <WatchSession>[],
    super.itemImages = const <ItemImage>[],
    super.fallbackOwnerLabel,
    super.catalogItem,
    super.ownedItem,
    super.trackingEntry,
  });
}

CatalogEntityRef _rootCatalogRef(CatalogEntityRef ref) {
  final rootId = ref.rootId;
  if (rootId != null && rootId.isNotEmpty) {
    return ref.copyWith(
      id: rootId,
      entityType: CatalogEntityType.work,
      rootId: null,
    );
  }
  if (ref.entityType == CatalogEntityType.ownedCopy ||
      ref.entityType == CatalogEntityType.copy ||
      ref.entityType == CatalogEntityType.trackingEntry) {
    return ref.copyWith(entityType: CatalogEntityType.work);
  }
  return ref;
}

CatalogDisplaySummary _catalogSummaryFromLegacy(CatalogItemDto item) {
  final itemNumber = item.itemNumber?.trim();
  final title = item.resolvedDisplayTitle.trim();
  return CatalogDisplaySummary.work(
    kind: item.mediaKind,
    id: item.id,
    title: itemNumber == null || itemNumber.isEmpty
        ? title
        : '$title #$itemNumber',
    imageUrl: item.displayCoverUrl,
  );
}

OwnedItemSummary _ownedSummaryFromLegacy(
  OwnedItem item, {
  CatalogDisplaySummary? catalogSummary,
}) {
  return OwnedItemSummary(
    ref: item.ref,
    title: catalogSummary?.title ?? item.itemId,
    catalogRef: item.catalogRef,
    createdAt: item.createdAt,
    updatedAt: item.updatedAt,
    deletedAt: item.deletedAt,
    purchaseDate: item.purchaseDate,
    purchaseStore: item.purchaseStore,
    pricePaidCents: item.pricePaidCents,
    currency: item.currency,
    soldAt: item.soldAt,
    soldTo: item.soldTo,
    sellPriceCents: item.sellPriceCents,
    marketValueCents: item.marketValueCents,
    quantity: item.quantity,
    ownerLabel: item.ownerLabel,
    locationLabel: item.locationId,
    notes: item.personalNotes,
    hasNotes: item.personalNotes?.trim().isNotEmpty == true,
  );
}
