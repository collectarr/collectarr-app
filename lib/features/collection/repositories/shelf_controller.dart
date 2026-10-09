import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/storage_location.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/item_image.dart';
import 'package:collectarr_app/core/models/tracking_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/core/models/user_external_link.dart';
import 'package:collectarr_app/core/models/user_folder.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/location_repository.dart';
import 'package:collectarr_app/features/collection/repositories/item_image_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_external_links_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/collection/repositories/user_folder_repository.dart';
import 'package:collectarr_app/features/collection/repositories/reading_queue_repository.dart';
import 'package:collectarr_app/features/library/tracking/watch_sessions_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_library_entry_persistence.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
import 'package:collectarr_app/features/library/workspace/entry/personal_overlay.dart';
import 'package:collectarr_app/features/library/workspace/entry/workspace_item.dart';
import 'package:collectarr_app/features/library/domain/library_target_ref.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_kind_data.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_repository.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:collectarr_app/state/auth_provider.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:collectarr_app/features/library/workspace/entry/library_workspace_context.dart';
export 'package:collectarr_app/core/models/tracking_summary.dart';

final shelfProvider = FutureProvider<ShelfState>((ref) async {
  final entrySummaries = await ref.watch(collectionSummariesProvider.future);
  final wishlist = await ref.watch(wishlistProvider.future);
  final trackingSummaries = await ref.watch(trackingSummariesProvider.future);
  final auth = ref.watch(authControllerProvider);
  final db = ref.watch(localDatabaseProvider);
  final entryRepository = CollectarrLibraryEntryPersistence(db);
  final typedEntryResults = await entryRepository.listActiveDispatches();
  final libraryEntryDispatchesByRef = <LibraryEntryRef, LibraryEntryDispatch>{};
  for (final result in typedEntryResults) {
    libraryEntryDispatchesByRef[result.ref] = result;
  }
  final entryRefs = entrySummaries.map((entry) => entry.ref).toSet();
  final imageTypesByEntry =
      await ItemImageRepository(db).typesForLibraryEntryRefs(entryRefs);
  final catalogRefs = <CatalogItemRef>{
    for (final entry in entrySummaries)
      if (entry.sourceCatalogRef case final ref?) ref,
    for (final item in wishlist) item.catalogRef,
  };
  final catalogSummaries =
      await CatalogDisplaySummaryRepository(db).findByRefs(catalogRefs);
  final dataRepository = CatalogWorkspaceDataRepository(db);
  final kindPresentationByEntryRef =
      await dataRepository.findEntries(entryRefs);
  final catalogPresentationByRef = await dataRepository.findCatalogItems(
    wishlist.map((item) => item.catalogRef),
  );
  // Read transport only at the repository boundary, then immediately
  // dispatch into structural kind-entry workspace data. Shelf never carries
  // a generic catalog snapshot.
  final locations = await LocationRepository(db).getAll();
  final userExternalLinksByEntry =
      await UserExternalLinksCacheRepository(db).listGroupedByEntry(
    entrySummaries.map((entry) => entry.ref),
  );
  final loanRepository = LoanRepository(db);
  final loansByEntry = <LibraryEntryRef, List<Loan>>{};
  for (final loan in await loanRepository.getAllLoans()) {
    loansByEntry.putIfAbsent(loan.libraryEntryRef, () => []).add(loan);
  }
  final folderRepository = UserFolderRepository(db);
  final folderMembershipsByEntry =
      <LibraryEntryRef, List<({String folderId, int sortOrder})>>{};
  for (final entry in entrySummaries) {
    folderMembershipsByEntry[entry.ref] =
        await folderRepository.getMembershipSnapshotForItem(entry.ref);
  }
  final folderDefinitions = await folderRepository.getAll();
  final readingQueue = await ReadingQueueRepository(db).getQueue();
  final readingQueuePositionByEntry = <LibraryEntryRef, int>{
    for (var index = 0; index < readingQueue.length; index++)
      readingQueue[index]: index,
  };
  final watchSessions = await WatchSessionsRepository(
    db,
    codecs: libraryWatchSessionCodecs,
  ).listActiveByLibraryEntryRefs(
    entrySummaries.map((entry) => entry.ref),
  );
  return ShelfState.from(
    entrySummaries: entrySummaries,
    wishlistItems: wishlist,
    trackingSummaries: trackingSummaries,
    watchSessions: watchSessions,
    catalogSummariesByRef: catalogSummaries,
    kindPresentationByEntryRef: kindPresentationByEntryRef,
    catalogPresentationByRef: catalogPresentationByRef,
    locations: locations,
    imageTypesByLibraryEntry: imageTypesByEntry,
    userExternalLinksByEntry: userExternalLinksByEntry,
    loansByEntry: loansByEntry,
    folderMembershipsByEntry: folderMembershipsByEntry,
    folderDefinitions: folderDefinitions,
    readingQueuePositionByEntry: readingQueuePositionByEntry,
    libraryEntryDispatchesByRef: libraryEntryDispatchesByRef,
    fallbackOwnerLabel: auth.email,
  );
});

class ShelfState {
  const ShelfState({
    required this.entries,
    required this.entryCount,
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
    this.libraryEntryCountByKind = const <String, int>{},
  });

  factory ShelfState.from({
    Iterable<LibraryEntrySummary>? entrySummaries,
    required List<WishlistItem> wishlistItems,
    Iterable<TrackingSummary>? trackingSummaries,
    Map<LibraryEntryRef, LibraryEntryDispatch> libraryEntryDispatchesByRef =
        const <LibraryEntryRef, LibraryEntryDispatch>{},
    List<WatchSession> watchSessions = const [],
    Map<CatalogItemRef, CatalogDisplaySummary>? catalogSummariesByRef,
    Map<LibraryEntryRef, LibraryWorkspaceKindData> kindPresentationByEntryRef =
        const <LibraryEntryRef, LibraryWorkspaceKindData>{},
    Map<CatalogItemRef, LibraryWorkspaceKindData> catalogPresentationByRef =
        const <CatalogItemRef, LibraryWorkspaceKindData>{},
    List<StorageLocation> locations = const [],
    Map<LibraryEntryRef, List<ItemImage>> itemImagesByLibraryEntry =
        const <LibraryEntryRef, List<ItemImage>>{},
    Map<LibraryEntryRef, Set<String>> imageTypesByLibraryEntry = const {},
    Map<LibraryEntryRef, List<UserExternalLink>> userExternalLinksByEntry =
        const <LibraryEntryRef, List<UserExternalLink>>{},
    Map<LibraryEntryRef, List<Loan>> loansByEntry =
        const <LibraryEntryRef, List<Loan>>{},
    Map<LibraryEntryRef, List<({String folderId, int sortOrder})>> folderMembershipsByEntry =
        const <LibraryEntryRef, List<({String folderId, int sortOrder})>>{},
    List<UserFolder> folderDefinitions = const <UserFolder>[],
    Map<LibraryEntryRef, int> readingQueuePositionByEntry =
        const <LibraryEntryRef, int>{},
    String? fallbackOwnerLabel,
  }) {
    final resolvedCatalogSummariesByRef =
        Map<CatalogItemRef, CatalogDisplaySummary>.unmodifiable(
      catalogSummariesByRef ?? const <CatalogItemRef, CatalogDisplaySummary>{},
    );
    final resolvedEntrySummaries = entrySummaries?.toList(growable: false) ??
        const <LibraryEntrySummary>[];
    final resolvedTrackingSummaries =
        trackingSummaries?.toList(growable: false) ?? const <TrackingSummary>[];
    final locationPathsById = {
      for (final location in locations)
        location.id: location.fullPath(locations),
    };
    final wishlistByCatalogRef = <CatalogItemRef, WishlistItem>{
      for (final item in wishlistItems)
        if (!item.isDeleted) item.catalogRef: item,
    };
    final trackingByEntryRef = <LibraryEntryRef, List<TrackingSummary>>{};
    for (final entry in resolvedTrackingSummaries) {
      if (entry.isDeleted) {
        continue;
      }
      trackingByEntryRef
          .putIfAbsent(entry.libraryEntryRef, () => <TrackingSummary>[])
          .add(entry);
    }
    for (final entries in trackingByEntryRef.values) {
      entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    final watchSessionsByEntryRef = <LibraryEntryRef, List<WatchSession>>{};
    for (final session in watchSessions) {
      if (session.isDeleted) {
        continue;
      }
      watchSessionsByEntryRef
          .putIfAbsent(session.libraryEntryRef, () => <WatchSession>[])
          .add(session);
    }
    for (final sessions in watchSessionsByEntryRef.values) {
      sessions.sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    }
    LibraryWorkspaceContext buildLibraryEntry(LibraryEntrySummary entry) {
      final sourceRef = entry.sourceCatalogRef;
      final catalogSummary =
          sourceRef == null ? null : resolvedCatalogSummariesByRef[sourceRef];
      return LibraryWorkspaceContext(
        item: WorkspaceItem(
          target: EntryTargetRef(entry.ref),
          presentation: catalogSummary,
          entrySummary: entry,
          libraryEntryDispatch: libraryEntryDispatchesByRef[entry.ref],
          searchTokens: [
            if (catalogSummary?.primaryLabel case final title?) title,
          ],
          kindPresentationData: kindPresentationByEntryRef[entry.ref],
        ),
        personal: PersonalOverlay(
          tracking: trackingByEntryRef[entry.ref]?.firstOrNull,
          trackingSummaries:
              trackingByEntryRef[entry.ref] ?? const <TrackingSummary>[],
          wishlist: sourceRef == null ? null : wishlistByCatalogRef[sourceRef],
          locationPath: locationPathsById[entry.locationId],
          images: itemImagesByLibraryEntry[entry.ref] ?? const <ItemImage>[],
          imageTypes: imageTypesByLibraryEntry[entry.ref] ?? const {},
          externalLinks:
              userExternalLinksByEntry[entry.ref] ?? const <UserExternalLink>[],
          loans: loansByEntry[entry.ref] ?? const <Loan>[],
          folderMemberships: folderMembershipsByEntry[entry.ref] ??
              const <({String folderId, int sortOrder})>[],
          folderDefinitions: folderDefinitions,
          readingQueuePosition: readingQueuePositionByEntry[entry.ref],
          watchSessions:
              watchSessionsByEntryRef[entry.ref] ?? const <WatchSession>[],
          fallbackOwnerLabel: fallbackOwnerLabel,
        ),
      );
    }

    LibraryWorkspaceContext buildWishlistItem(CatalogItemRef ref) =>
        LibraryWorkspaceContext(
          item: WorkspaceItem(
            target: CatalogTargetRef(ref),
            presentation: resolvedCatalogSummariesByRef[ref],
            searchTokens: [
              if (resolvedCatalogSummariesByRef[ref]?.primaryLabel
                  case final title?)
                title,
            ],
            kindPresentationData: catalogPresentationByRef[ref],
          ),
          personal: PersonalOverlay(
            wishlist: wishlistByCatalogRef[ref],
            folderDefinitions: folderDefinitions,
            fallbackOwnerLabel: fallbackOwnerLabel,
          ),
        );

    final entries = <LibraryWorkspaceContext>[
      for (final entry in resolvedEntrySummaries)
        if (!entry.isDeleted) buildLibraryEntry(entry),
      for (final ref in wishlistByCatalogRef.keys)
        if (!resolvedEntrySummaries.any(
          (entry) => !entry.isDeleted && entry.sourceCatalogRef == ref,
        ))
          buildWishlistItem(ref),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final pricedEntry = resolvedEntrySummaries
        .where((item) => item.pricePaidCents != null && item.currency != null)
        .toList(growable: false);
    final currencies = {
      for (final item in pricedEntry) item.currency!,
    };
    final hasMixedCurrencies = currencies.length > 1;
    final activeEntry = resolvedEntrySummaries
        .where((item) => !item.isDeleted)
        .toList(growable: false);
    final libraryEntryCountByKind = <String, int>{};
    for (final item in resolvedEntrySummaries) {
      if (item.isDeleted) continue;
      final kind = item.ref.kind.apiValue;
      libraryEntryCountByKind[kind] = (libraryEntryCountByKind[kind] ?? 0) + 1;
    }
    final wishlistItemCountByKind = <String, int>{};
    for (final item in wishlistByCatalogRef.values) {
      final kind = item.catalogRef.kind.apiValue;
      wishlistItemCountByKind[kind] = (wishlistItemCountByKind[kind] ?? 0) + 1;
    }
    return ShelfState(
      entries: entries,
      entryCount: activeEntry.length,
      wishlistCount: wishlistByCatalogRef.length,
      pricedCount: pricedEntry.length,
      totalPaidCents: hasMixedCurrencies
          ? null
          : pricedEntry.fold<int>(
              0,
              (total, item) => total + (item.pricePaidCents ?? 0),
            ),
      primaryCurrency: currencies.length == 1 ? currencies.single : null,
      hasMixedCurrencies: hasMixedCurrencies,
      wishlistItemCountByKind: wishlistItemCountByKind,
      missingMetadataCount:
          entries.where((entry) => entry.kindPresentationData == null).length,
      locationCounts: _counts(
        entries
            .where((entry) => entry.isEntry)
            .map((entry) => entry.locationPath ?? 'No location'),
      ),
      soldCount: activeEntry.where((item) => item.soldAt != null).length,
      totalSellCents: hasMixedCurrencies
          ? null
          : activeEntry
              .where((item) => item.sellPriceCents != null)
              .fold<int>(0, (total, item) => total + item.sellPriceCents!),
      marketValuedCount:
          activeEntry.where((item) => item.marketValueCents != null).length,
      totalMarketValueCents: hasMixedCurrencies
          ? null
          : activeEntry
              .where((item) => item.marketValueCents != null)
              .fold<int>(0, (total, item) => total + item.marketValueCents!),
      libraryEntryCountByKind: libraryEntryCountByKind,
    );
  }

  final int entryCount;

  /// Structural workspace sources used by mixed Shelf hosts and by the
  /// kind-specific Library projection pipeline.
  final List<LibraryWorkspaceContext> entries;

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
  final Map<String, int> libraryEntryCountByKind;

  static Map<String, int> _counts(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts;
  }
}
