import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/tracking_activity_summary.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/catalog/catalog_transport_summary_registry.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/library/detail/activity_event_aggregator.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single activity event tagged with its local entry or wishlist target.
class GlobalActivityEntry {
  const GlobalActivityEntry({
    required this.event,
    required this.title,
    required this.mediaType,
    this.libraryEntryRef,
    this.catalogItemRef,
  }) : assert((libraryEntryRef == null) != (catalogItemRef == null));

  final ActivityEvent event;
  final String title;
  final String mediaType;
  final LibraryEntryRef? libraryEntryRef;
  final CatalogItemRef? catalogItemRef;

  String get itemId => switch ((libraryEntryRef, catalogItemRef)) {
        (final ref?, null) => ref.id.value,
        (null, final ref?) => ref.id,
        _ => throw StateError('Activity entry must have exactly one target.'),
      };
}

/// Aggregates activity across the entire collection (not scoped to one item).
///
/// Reuses [ActivityEventAggregator] per local entry. Wishlist-only events keep
/// their canonical Catalog Item reference because no local entry exists yet.
final globalActivityProvider =
    FutureProvider.autoDispose<List<GlobalActivityEntry>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final entry = await ref.watch(collectionSummariesProvider.future);
  // Ensure the grouped providers below have resolved data to read.
  await ref.watch(trackingSummariesProvider.future);
  await ref.watch(watchSessionsProvider.future);
  await ref.watch(wishlistProvider.future);

  final trackingSummaries = await ref.watch(trackingSummariesProvider.future);
  final watchSessions = await ref.watch(watchSessionsProvider.future);
  final wishlistItems = await ref.watch(wishlistProvider.future);

  final loans = await LoanRepository(db).getAllLoans();
  final records = await LibraryEntryStore(db).list(includeDeleted: true);
  final titleByEntry = <LibraryEntryRef, String>{
    for (final record in records)
      LibraryEntryRef(
        kind: record.kind,
        id: LibraryEntryId(record.id),
      ): summarizeCatalogTransportPayload(record.catalogItem).primaryLabel,
  };

  final sourceEntryByCatalogRef = <CatalogItemRef, LibraryEntryRef>{};
  for (final item in entry) {
    final source = item.sourceCatalogRef;
    if (!item.isDeleted && source != null) {
      sourceEntryByCatalogRef.putIfAbsent(source, () => item.ref);
    }
  }
  final wishlistsByEntry = <LibraryEntryRef, List<WishlistItem>>{};
  final unmatchedWishlistItems = <WishlistItem>[];
  for (final wishlist in wishlistItems) {
    if (wishlist.isDeleted) continue;
    final entryRef = sourceEntryByCatalogRef[wishlist.catalogRef];
    if (entryRef == null) {
      unmatchedWishlistItems.add(wishlist);
    } else {
      wishlistsByEntry
          .putIfAbsent(entryRef, () => <WishlistItem>[])
          .add(wishlist);
    }
  }

  final entries = <GlobalActivityEntry>[];
  final trackingByEntry = <LibraryEntryRef, List<TrackingActivitySummary>>{};
  for (final record in trackingSummaries) {
    if (record.isDeleted) continue;
    trackingByEntry
        .putIfAbsent(record.libraryEntryRef, () => <TrackingActivitySummary>[])
        .add(TrackingActivitySummary.fromSummary(record));
  }
  final watchByEntry = <LibraryEntryRef, List<WatchSession>>{};
  for (final session in watchSessions) {
    if (session.isDeleted) continue;
    watchByEntry
        .putIfAbsent(session.libraryEntryRef, () => <WatchSession>[])
        .add(session);
  }
  final loansByEntry = <LibraryEntryRef, List<Loan>>{};
  for (final loan in loans) {
    loansByEntry.putIfAbsent(loan.libraryEntryRef, () => <Loan>[]).add(loan);
  }

  for (final item in entry) {
    final events = ActivityEventAggregator.aggregate(
      libraryEntries: [item],
      trackingRecords:
          trackingByEntry[item.ref] ?? const <TrackingActivitySummary>[],
      wishlistItems: wishlistsByEntry[item.ref] ?? const <WishlistItem>[],
      loans: loansByEntry[item.ref] ?? const <Loan>[],
      watchSessions: watchByEntry[item.ref] ?? const <WatchSession>[],
      hasKindContributor: (kind) =>
          libraryActivityContributorForKind(kind) != null,
    );
    for (final event in events) {
      entries.add(GlobalActivityEntry(
        event: event,
        libraryEntryRef: item.ref,
        title: titleByEntry[item.ref] ?? 'Unknown item',
        mediaType: item.ref.kind.apiValue,
      ));
    }
  }

  final wishlistCatalog = CatalogItemCacheRepository(db);
  for (final wishlist in unmatchedWishlistItems) {
    final events = ActivityEventAggregator.aggregate(
      libraryEntries: const <LibraryEntrySummary>[],
      trackingRecords: const <TrackingActivitySummary>[],
      wishlistItems: [wishlist],
      loans: const <Loan>[],
      watchSessions: const <WatchSession>[],
    );
    final item = await wishlistCatalog.find(wishlist.catalogRef);
    for (final event in events) {
      entries.add(GlobalActivityEntry(
        event: event,
        catalogItemRef: wishlist.catalogRef,
        title: item == null
            ? 'Unknown item'
            : summarizeCatalogTransportPayload(item).primaryLabel,
        mediaType: wishlist.catalogRef.kind.apiValue,
      ));
    }
  }

  entries.sort((a, b) => b.event.timestamp.compareTo(a.event.timestamp));
  return entries;
});
