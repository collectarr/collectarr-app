import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_snapshot_repository.dart';
import 'package:collectarr_app/features/catalog/transport/library_add_catalog_item.dart';
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
  // Library kind contributors receive transport snapshots only at this
  // explicit boundary. Joins are keyed by the complete catalog reference so
  // equal IDs across kinds cannot collide.
  final catalogSnapshotsByRef = (await CatalogSnapshotRepository(db)
          .findByRefs(catalogRefs))
      .map((ref, item) => MapEntry(ref, LibraryAddCatalogItem.fromItem(item)));
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
    trackingSummaries:
        trackingEntries.map(TrackingSummary.fromEntry).toList(growable: false),
    watchSessions: watchSessions,
    catalogSummariesByRef: catalogSummaries,
    catalogSnapshotsByRef: catalogSnapshotsByRef,
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
    required List<WishlistItem> wishlistItems,
    Iterable<TrackingSummary>? trackingSummaries,
    List<WatchSession> watchSessions = const [],
    Map<CatalogEntityRef, CatalogDisplaySummary>? catalogSummariesByRef,
    Map<CatalogEntityRef, LibraryAddCatalogItem>? catalogSnapshotsByRef,
    List<StorageLocation> locations = const [],
    Map<OwnedItemRef, List<ItemImage>> itemImagesByOwnedItem =
        const <OwnedItemRef, List<ItemImage>>{},
    String? fallbackOwnerLabel,
  }) {
    final catalogByRef = <CatalogEntityRef, LibraryAddCatalogItem>{
      ...?catalogSnapshotsByRef,
    };
    final resolvedCatalogSummariesByRef =
        <CatalogEntityRef, CatalogDisplaySummary>{
      ...?catalogSummariesByRef,
      for (final item in catalogByRef.values)
        item.catalogRef: _catalogSummaryFromSnapshot(item),
    };
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
    final workspaceEntries = [
      for (final ref in refs) ...[
        ShelfEntry(
          itemId: ref.id,
          catalogSummary: resolvedCatalogSummariesByRef[ref],
          ownedSummary: ownedByCatalogRef[ref],
          trackingSummary: trackingByCatalogRef[ref],
          // Transport snapshots remain available only to the typed Library
          // contributors that have not yet moved to their domain repository.
          catalogItem: catalogByRef[ref],
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
    final entries = [
      for (final ref in refs)
        LibraryEntry(
          itemId: ref.id,
          catalogSummary: resolvedCatalogSummariesByRef[ref],
          ownedSummary: ownedByCatalogRef[ref],
          trackingSummary: trackingByCatalogRef[ref],
          wishlistItem: wishlistByCatalogRef[ref],
          locationPath:
              locationPathsById[ownedByCatalogRef[ref]?.locationLabel],
          watchSessions:
              watchSessionsByCatalogRef[ref] ?? const <WatchSession>[],
          itemImages: itemImagesByOwnedItem[ownedByCatalogRef[ref]?.ref] ??
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
    return ShelfState(
      entries: entries,
      workspaceEntries: workspaceEntries,
      ownedCount: ownedByCatalogRef.length,
      missingGradeCount: 0,
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
        const <String>[],
      ),
      conditionCounts: _counts(
        const <String>[],
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

/// Workspace source carrying the transport snapshot required by the current
/// kind-specific Library projectors. Mixed Shelf state remains represented by
/// [LibraryEntry]; this source is only created after the workspace selects a
/// concrete library kind.
class ShelfEntry extends LibraryWorkspaceSource implements LibraryEntry {
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
    this.catalogItem,
    this.ownedItem,
  });

  final LibraryAddCatalogItem? catalogItem;

  final OwnedItem? ownedItem;

  @override
  CatalogEntityRef? get catalogRef =>
      super.catalogRef ?? catalogItem?.catalogRef ?? ownedItem?.catalogRef;

  @override
  CatalogMediaKind get mediaKind =>
      catalogSummary?.kind ??
      catalogItem?.mediaKind ??
      CatalogMediaKind.unknown;

  @override
  OwnedItemRef? get ownedRef => super.ownedRef ?? ownedItem?.ref;

  @override
  bool get isOwned => super.isOwned || ownedItem != null;

  @override
  bool get hasNotes =>
      super.hasNotes || (ownedItem?.personalNotes?.trim().isNotEmpty ?? false);

  @override
  DateTime get updatedAt {
    final base = super.updatedAt;
    final owned = ownedItem?.updatedAt;
    if (owned == null || owned.isBefore(base)) return base;
    return owned;
  }

  @override
  DateTime? get addedAt => super.addedAt ?? ownedItem?.createdAt;

  @override
  String get title {
    final base = super.title;
    if (!base.startsWith('Catalog item ')) return base;
    final snapshotTitle = catalogItem?.resolvedDisplayTitle.trim();
    return snapshotTitle == null || snapshotTitle.isEmpty
        ? base
        : snapshotTitle;
  }

  @override
  String? get ownerLabel =>
      ownedSummary?.ownerLabel ?? ownedItem?.ownerLabel ?? fallbackOwnerLabel;

  @override
  int get quantity => ownedSummary?.quantity ?? ownedItem?.quantity ?? 0;

  Object? get kindMetadata => catalogItem?.kindMetadata;

  String? get condition => ownedItem?.condition;
  String? get grade => ownedItem?.grade;
  int? get pricePaidCents =>
      ownedSummary?.pricePaidCents ?? ownedItem?.pricePaidCents;
  int? get sellPriceCents =>
      ownedSummary?.sellPriceCents ?? ownedItem?.sellPriceCents;
  int? get marketValueCents =>
      ownedSummary?.marketValueCents ?? ownedItem?.marketValueCents;
  String? get soldTo => ownedSummary?.soldTo ?? ownedItem?.soldTo;
  String? get currency => ownedSummary?.currency ?? ownedItem?.currency;
  String? get purchaseStore =>
      ownedSummary?.purchaseStore ?? ownedItem?.purchaseStore;
  DateTime? get purchaseDate =>
      ownedSummary?.purchaseDate ?? ownedItem?.purchaseDate;
  DateTime? get soldAt => ownedSummary?.soldAt ?? ownedItem?.soldAt;
  int? get indexNumber => ownedItem?.indexNumber;
  String? get personalNotes => ownedSummary?.notes ?? ownedItem?.personalNotes;
  String? get tags => ownedItem?.tags;
  String? get collectionStatus => ownedItem?.collectionStatus;

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

CatalogDisplaySummary _catalogSummaryFromSnapshot(LibraryAddCatalogItem item) {
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
