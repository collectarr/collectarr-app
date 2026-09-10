import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_display_summary.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/tracking_activity_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/detail/activity_event_aggregator.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single activity event tagged with the catalog item it belongs to, for the
/// collection-wide activity view.
class GlobalActivityEntry {
  const GlobalActivityEntry({
    required this.event,
    required this.itemRef,
    required this.title,
    required this.mediaType,
  });

  final ActivityEvent event;
  final CatalogEntityRef itemRef;
  final String title;
  final String mediaType;

  String get itemId => itemRef.id;
}

/// Aggregates activity across the entire collection (not scoped to one item).
///
/// Reuses [ActivityEventAggregator] per catalog item, then tags each event with
/// the item's title/kind so the global timeline can group and filter by kind,
/// event type, and date.
final globalActivityProvider =
    FutureProvider.autoDispose<List<GlobalActivityEntry>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final owned = await ref.watch(collectionSummariesProvider.future);
  // Ensure the grouped providers below have resolved data to read.
  await ref.watch(trackingSummariesProvider.future);
  await ref.watch(watchSessionsProvider.future);
  await ref.watch(wishlistProvider.future);

  final trackingSummaries = await ref.watch(trackingSummariesProvider.future);
  final watchSessions = await ref.watch(watchSessionsProvider.future);
  final wishlistItems = await ref.watch(wishlistProvider.future);

  final loans = await LoanRepository(db).getAllLoans();

  final ownedByCatalogRef = <CatalogEntityRef, List<OwnedItemSummary>>{};
  for (final item in owned) {
    final catalogRef = item.catalogRef;
    if (catalogRef == null) continue;
    ownedByCatalogRef
        .putIfAbsent(_rootCatalogRef(catalogRef), () => <OwnedItemSummary>[])
        .add(item);
  }
  final ownedByRef = <OwnedItemRef, OwnedItemSummary>{
    for (final item in owned)
      if (item.catalogRef != null) item.ref: item,
  };
  final loansByRef = <CatalogEntityRef, List<Loan>>{};
  for (final loan in loans) {
    final ownedItem = ownedByRef[loan.ownedRef];
    final catalogRef = ownedItem?.catalogRef;
    if (catalogRef == null) continue;
    loansByRef
        .putIfAbsent(_rootCatalogRef(catalogRef), () => <Loan>[])
        .add(loan);
  }

  final trackingByRef = <CatalogEntityRef, List<TrackingActivitySummary>>{};
  for (final entry in trackingSummaries) {
    if (entry.isDeleted) continue;
    trackingByRef
        .putIfAbsent(
          _rootCatalogRef(entry.catalogRef),
          () => <TrackingActivitySummary>[],
        )
        .add(TrackingActivitySummary.fromSummary(entry));
  }
  final watchByRef = <CatalogEntityRef, List<WatchSession>>{};
  for (final session in watchSessions) {
    if (session.isDeleted) continue;
    watchByRef
        .putIfAbsent(_rootCatalogRef(session.targetRef), () => <WatchSession>[])
        .add(session);
  }
  final wishlistByRef = <CatalogEntityRef, List<WishlistItem>>{};
  for (final item in wishlistItems) {
    if (item.isDeleted) continue;
    wishlistByRef
        .putIfAbsent(_rootCatalogRef(item.catalogRef), () => <WishlistItem>[])
        .add(item);
  }
  final refs = <CatalogEntityRef>{
    ...ownedByCatalogRef.keys,
    ...trackingByRef.keys,
    ...watchByRef.keys,
    ...wishlistByRef.keys,
    ...loansByRef.keys,
  };
  if (refs.isEmpty) {
    return const <GlobalActivityEntry>[];
  }

  final catalog = await CatalogDisplaySummaryRepository(db).findByRefs(refs);

  final entries = <GlobalActivityEntry>[];
  for (final itemRef in refs) {
    final events = ActivityEventAggregator.aggregate(
      ownedItems: ownedByCatalogRef[itemRef] ?? const <OwnedItemSummary>[],
      trackingEntries:
          trackingByRef[itemRef] ?? const <TrackingActivitySummary>[],
      wishlistItems: wishlistByRef[itemRef] ?? const <WishlistItem>[],
      loans: loansByRef[itemRef] ?? const <Loan>[],
      watchSessions: watchByRef[itemRef] ?? const <WatchSession>[],
      hasKindContributor: (kind) =>
          libraryActivityContributorForKind(kind) != null,
    );
    final CatalogDisplaySummary? item = catalog[itemRef];
    final title = item?.title ?? 'Unknown item';
    final mediaType = item?.kind.apiValue ?? '';
    for (final event in events) {
      entries.add(GlobalActivityEntry(
        event: event,
        itemRef: itemRef,
        title: title,
        mediaType: mediaType,
      ));
    }
  }

  entries.sort((a, b) => b.event.timestamp.compareTo(a.event.timestamp));
  return entries;
});

CatalogEntityRef _rootCatalogRef(CatalogEntityRef ref) {
  final rootId = ref.rootId;
  if (rootId == null || rootId.isEmpty) return ref;
  return ref.copyWith(
    id: rootId,
    entityType: const CatalogEntityTypeId('work'),
    rootId: null,
  );
}
