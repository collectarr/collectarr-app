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
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/models/library_entry.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_watch_session_codecs.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shelfProvider = FutureProvider<ShelfState>((ref) async {
  final ownedSummaries = await ref.watch(collectionSummariesProvider.future);
  // Retained only as an adapter for unchanged Library contributor contracts.
  // Shelf aggregation and UI use the structural summaries below.
  final legacyOwned = await ref.watch(collectionProvider.future);
  final wishlist = await ref.watch(wishlistProvider.future);
  final trackingEntries = await ref.watch(trackingEntriesProvider.future);
  final auth = ref.watch(authControllerProvider);
  final db = ref.watch(localDatabaseProvider);
  final ids = {
    for (final item in ownedSummaries)
      if (item.catalogRef != null) item.catalogRef!.id,
    for (final item in wishlist) item.itemId,
    for (final item in trackingEntries) item.catalogRef.id,
  };
  final catalogSummaries =
      await CatalogDisplaySummaryRepository(db).findByIds(ids);
  // This is a compatibility adapter for Library kind contributors only.
  final legacyCatalogItems = await LibraryCatalogRepository(db).findByIds(ids);
  final locations = await LocationRepository(db).getAll();
  final watchSessions = await WatchSessionsRepository(
    db,
    codecs: collectarrWatchSessionCodecs,
  ).listActiveByItemIds(ids);
  final itemImagesByOwnedItem =
      await ItemImageRepository(db).listForOwnedItemIds(
    ownedSummaries.map((item) => item.ref.id.value),
  );
  return ShelfState.from(
    ownedSummaries: ownedSummaries,
    legacyOwnedItems: legacyOwned,
    wishlistItems: wishlist,
    trackingSummaries:
        trackingEntries.map(TrackingSummary.fromEntry).toList(growable: false),
    legacyTrackingEntries: trackingEntries,
    watchSessions: watchSessions,
    catalogSummaries: catalogSummaries,
    legacyCatalogItems: legacyCatalogItems,
    locations: locations,
    itemImagesByOwnedItem: itemImagesByOwnedItem,
    fallbackOwnerLabel: auth.email,
  );
});

class ShelfState {
  const ShelfState({
    required this.entries,
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
    Map<String, CatalogDisplaySummary>? catalogSummaries,
    Map<String, CatalogItemDto>? catalogItems,
    Map<String, CatalogItemDto>? legacyCatalogItems,
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
    final resolvedCatalogSummaries = catalogSummaries ??
        {
          for (final item in legacyCatalogById.values)
            item.id: _catalogSummaryFromLegacy(item),
        };
    final resolvedOwnedSummaries = ownedSummaries?.toList(growable: false) ??
        [
          for (final item in legacyOwnedList)
            _ownedSummaryFromLegacy(
              item,
              catalogSummary: resolvedCatalogSummaries[item.catalogRef.id],
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
    final ownedByItemId = {
      for (final item in resolvedOwnedSummaries)
        if (!item.isDeleted && item.catalogRef != null) item.itemId: item,
    };
    final wishlistByItemId = {
      for (final item in wishlistItems)
        if (!item.isDeleted) item.itemId: item,
    };
    final trackingByItemId = <String, TrackingSummary>{};
    for (final entry in resolvedTrackingSummaries) {
      if (entry.isDeleted ||
          trackingByItemId.containsKey(entry.catalogRef.id)) {
        continue;
      }
      trackingByItemId[entry.catalogRef.id] = entry;
    }
    final legacyOwnedByItemId = <String, OwnedItem>{};
    for (final item in legacyOwnedList) {
      if (!item.isDeleted) legacyOwnedByItemId[item.catalogRef.id] = item;
    }
    final legacyTrackingByItemId = <String, TrackingEntry>{};
    for (final entry in legacyTrackingList) {
      if (!entry.isDeleted &&
          !legacyTrackingByItemId.containsKey(entry.catalogRef.id)) {
        legacyTrackingByItemId[entry.catalogRef.id] = entry;
      }
    }
    final watchSessionsByItemId = <String, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (session.isDeleted) {
        continue;
      }
      watchSessionsByItemId
          .putIfAbsent(session.itemId, () => <WatchSession>[])
          .add(session);
    }
    for (final sessions in watchSessionsByItemId.values) {
      sessions.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    }
    final ids = {
      ...ownedByItemId.keys,
      ...wishlistByItemId.keys,
      ...trackingByItemId.keys,
    };
    final entries = [
      for (final id in ids)
        ShelfEntry(
          itemId: id,
          catalogSummary: resolvedCatalogSummaries[id],
          ownedSummary: ownedByItemId[id],
          trackingSummary: trackingByItemId[id],
          // Compatibility adapters for unchanged Library contributors.
          catalogItem: legacyCatalogById[id],
          ownedItem: legacyOwnedByItemId[id],
          trackingEntry: legacyTrackingByItemId[id],
          wishlistItem: wishlistByItemId[id],
          locationPath: locationPathsById[ownedByItemId[id]?.locationLabel] ??
              locationPathsById[legacyOwnedByItemId[id]?.locationId],
          watchSessions: watchSessionsByItemId[id] ?? const <WatchSession>[],
          itemImages: itemImagesByOwnedItem[ownedByItemId[id]?.ref.id.value ??
                  legacyOwnedByItemId[id]?.id] ??
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
    final activeOwned = ownedByItemId.values.toList(growable: false);
    final legacyActiveOwned =
        legacyOwnedByItemId.values.toList(growable: false);
    return ShelfState(
      entries: entries,
      ownedCount: ownedByItemId.length,
      missingGradeCount:
          legacyActiveOwned.where((item) => item.grade == null).length,
      wishlistCount: wishlistByItemId.length,
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
        (total, item) =>
            total + (legacyOwnedByItemId[item.itemId]?.quantity ?? 1),
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
      marketValuedCount: legacyActiveOwned
          .where((item) => item.marketValueCents != null)
          .length,
      totalMarketValueCents: hasMixedCurrencies
          ? null
          : legacyActiveOwned
              .where((item) => item.marketValueCents != null)
              .fold<int>(0, (total, item) => total + item.marketValueCents!),
    );
  }

  final List<ShelfEntry> entries;
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

class ShelfEntry extends LibraryEntry {
  const ShelfEntry({
    required super.itemId,
    this.catalogSummary,
    this.ownedSummary,
    this.trackingSummary,
    super.catalogItem,
    super.ownedItem,
    super.trackingEntry,
    super.wishlistItem,
    this.locationPath,
    this.watchSessions = const <WatchSession>[],
    this.itemImages = const <ItemImage>[],
    this.fallbackOwnerLabel,
  });

  final CatalogDisplaySummary? catalogSummary;
  final OwnedItemSummary? ownedSummary;
  final TrackingSummary? trackingSummary;
  final String? locationPath;
  final List<WatchSession> watchSessions;
  final List<ItemImage> itemImages;
  final String? fallbackOwnerLabel;

  @override
  bool get isOwned => ownedSummary != null || ownedItem != null;

  @override
  bool get isTracked => trackingSummary != null || trackingEntry != null;

  @override
  bool get hasNotes =>
      (ownedSummary?.hasNotes ??
          ownedItem?.personalNotes?.trim().isNotEmpty == true) ||
      (wishlistItem?.notes?.trim().isNotEmpty ?? false);

  @override
  DateTime get updatedAt {
    final values = <DateTime>[
      if (ownedSummary?.updatedAt case final value?) value,
      if (trackingSummary?.updatedAt case final value?) value,
      if (wishlistItem?.updatedAt case final value?) value,
      if (ownedItem?.updatedAt case final value?) value,
      if (trackingEntry?.updatedAt case final value?) value,
    ];
    if (values.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    values.sort((a, b) => b.compareTo(a));
    return values.first;
  }

  @override
  DateTime? get addedAt =>
      ownedSummary?.createdAt ??
      ownedItem?.createdAt ??
      wishlistItem?.createdAt;

  @override
  String get title {
    final value = catalogSummary?.title.trim();
    if (value != null && value.isNotEmpty) return value;
    final legacyTitle = catalogItem?.resolvedDisplayTitle.trim();
    if (legacyTitle != null && legacyTitle.isNotEmpty) return legacyTitle;
    final length = itemId.length < 8 ? itemId.length : 8;
    return 'Catalog item ${itemId.substring(0, length)}';
  }

  @override
  String get subtitle {
    if (isOwned && isWishlisted) return 'Owned and wishlisted';
    if (isOwned) return 'Owned';
    if (isTracked) return 'Tracked';
    return 'Wishlist';
  }

  @override
  MediaTracking get tracking =>
      trackingSummary?.tracking ??
      const MediaTracking(status: MediaTrackingStatus.none);

  String? get ownerLabel =>
      ownedSummary?.ownerLabel ?? ownedItem?.ownerLabel ?? fallbackOwnerLabel;
  int get quantity => ownedSummary == null
      ? (ownedItem?.quantity ?? 0)
      : (ownedItem?.quantity ?? 1);

  // Transitional accessors for contributors that still consume the legacy
  // ShelfEntry surface. The mixed Shelf itself is projected from summaries;
  // these will disappear with the remaining kind-specific consumer cutover.
  String? get condition => ownedItem?.condition;
  String? get grade => ownedItem?.grade;
  int? get pricePaidCents =>
      ownedSummary?.pricePaidCents ?? ownedItem?.pricePaidCents;
  int? get marketValueCents => ownedItem?.marketValueCents;
  String? get currency => ownedSummary?.currency ?? ownedItem?.currency;
  String? get purchaseStore =>
      ownedSummary?.purchaseStore ?? ownedItem?.purchaseStore;
  DateTime? get purchaseDate =>
      ownedSummary?.purchaseDate ?? ownedItem?.purchaseDate;
  String? get personalNotes => ownedSummary?.notes ?? ownedItem?.personalNotes;
  String? get tags => ownedItem?.tags;

  List<String> get tagList {
    final raw = tags?.trim();
    if (raw == null || raw.isEmpty) return const <String>[];
    return raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }
}

/// Small mixed-Shelf tracking projection. Kind-specific progress remains in
/// the owning tracking implementation; the Shelf only needs activity status.
final class TrackingSummary {
  const TrackingSummary({
    required this.catalogRef,
    required this.tracking,
    required this.updatedAt,
    this.deletedAt,
  });

  factory TrackingSummary.fromEntry(TrackingEntry entry) {
    return TrackingSummary(
      catalogRef: entry.catalogRef,
      tracking: entry.mediaTracking,
      updatedAt: entry.updatedAt,
      deletedAt: entry.deletedAt,
    );
  }

  final CatalogEntityRef catalogRef;
  final MediaTracking tracking;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;
  String get statusLabel => tracking.statusLabel;
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
    ownerLabel: item.ownerLabel,
    locationLabel: item.locationId,
    notes: item.personalNotes,
    hasNotes: item.personalNotes?.trim().isNotEmpty == true,
  );
}
