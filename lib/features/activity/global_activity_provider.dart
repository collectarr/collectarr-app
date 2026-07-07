import 'package:collectarr_app/core/models/activity_event.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/tracking_entry.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/core/models/wishlist_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/detail/activity_event_aggregator.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single activity event tagged with the catalog item it belongs to, for the
/// collection-wide activity view.
class GlobalActivityEntry {
  const GlobalActivityEntry({
    required this.event,
    required this.itemId,
    required this.title,
    required this.mediaType,
  });

  final ActivityEvent event;
  final String itemId;
  final String title;
  final String mediaType;
}

/// Aggregates activity across the entire collection (not scoped to one item).
///
/// Reuses [ActivityEventAggregator] per catalog item, then tags each event with
/// the item's title/kind so the global timeline can group and filter by kind,
/// event type, and date.
final globalActivityProvider =
    FutureProvider.autoDispose<List<GlobalActivityEntry>>((ref) async {
  final owned = await ref.watch(collectionProvider.future);
  // Ensure the grouped providers below have resolved data to read.
  await ref.watch(trackingEntriesProvider.future);
  await ref.watch(watchSessionsProvider.future);
  await ref.watch(wishlistProvider.future);

  final trackingByItem = ref.watch(trackingEntriesByCatalogItemProvider);
  final watchByItem = ref.watch(watchSessionsByItemProvider);
  final wishlistByItem = ref.watch(wishlistByCatalogItemProvider);

  final db = ref.watch(localDatabaseProvider);
  final loans = await LoanRepository(db).getAllLoans();

  // owned-item id -> catalog item id, for mapping loans back to catalog items.
  final ownedIdToItemId = <String, String>{
    for (final o in owned) o.id: o.catalogRef.id,
  };
  final loansByItem = <String, List<Loan>>{};
  for (final loan in loans) {
    final itemId = ownedIdToItemId[loan.ownedItemId];
    if (itemId == null) continue;
    loansByItem.putIfAbsent(itemId, () => <Loan>[]).add(loan);
  }

  final ownedByItem = <String, List<OwnedItem>>{};
  for (final o in owned) {
    ownedByItem.putIfAbsent(o.catalogRef.id, () => <OwnedItem>[]).add(o);
  }

  final itemIds = <String>{
    ...ownedByItem.keys,
    ...trackingByItem.keys,
    ...watchByItem.keys,
    ...wishlistByItem.keys,
    ...loansByItem.keys,
  };
  if (itemIds.isEmpty) {
    return const <GlobalActivityEntry>[];
  }

  final catalog = await CatalogCacheRepository(db).findByIds(itemIds);

  final entries = <GlobalActivityEntry>[];
  for (final itemId in itemIds) {
    final events = ActivityEventAggregator.aggregate(
      ownedItems: ownedByItem[itemId] ?? const <OwnedItem>[],
      trackingEntries: trackingByItem[itemId] ?? const <TrackingEntry>[],
      watchSessions: watchByItem[itemId] ?? const <WatchSession>[],
      wishlistItems: wishlistByItem[itemId] ?? const <WishlistItem>[],
      loans: loansByItem[itemId] ?? const <Loan>[],
    );
    final item = catalog[itemId];
    final title = item?.title ?? 'Unknown item';
    final mediaType = item?.mediaKind.apiValue ?? '';
    for (final event in events) {
      entries.add(GlobalActivityEntry(
        event: event,
        itemId: itemId,
        title: title,
        mediaType: mediaType,
      ));
    }
  }

  entries.sort((a, b) => b.event.timestamp.compareTo(a.event.timestamp));
  return entries;
});
