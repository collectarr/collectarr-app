import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides all calendar events aggregated from collection data.
final calendarEventsProvider =
    FutureProvider<List<CalendarEvent>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final ownedItems = await ref.watch(collectionProvider.future);
  final watchSessions = await ref.watch(watchSessionsProvider.future);
  final loans = await LoanRepository(db).getAllLoans();
  final catalogRepo = CatalogCacheRepository(db);

  // Collect all item IDs we need titles for.
  final itemIds = <String>{};
  for (final item in ownedItems) {
    itemIds.add(item.itemId);
  }
  for (final session in watchSessions) {
    itemIds.add(session.itemId);
  }

  // Resolve titles.
  final catalogById = await catalogRepo.findByIds(itemIds);
  String titleFor(String itemId) =>
      catalogById[itemId]?.title ?? 'Unknown item';

  final events = <CalendarEvent>[];

  // --- Release dates from catalog ---
  for (final entry in catalogById.entries) {
    final item = entry.value;
    if (item.releaseDate != null) {
      events.add(CalendarEvent(
        kind: CalendarEventKind.releaseDate,
        date: item.releaseDate!,
        title: item.title,
        itemId: entry.key,
      ));
    }
  }

  // --- Owned item events ---
  for (final item in ownedItems) {
    if (item.isDeleted) continue;
    final title = titleFor(item.itemId);

    if (item.purchaseDate != null) {
      events.add(CalendarEvent(
        kind: CalendarEventKind.purchased,
        date: item.purchaseDate!,
        title: title,
        subtitle: item.purchaseStore,
        itemId: item.itemId,
        ownedItemId: item.id,
      ));
    }
    if (item.startedAt != null) {
      events.add(CalendarEvent(
        kind: CalendarEventKind.started,
        date: item.startedAt!,
        title: title,
        itemId: item.itemId,
        ownedItemId: item.id,
      ));
    }
    if (item.finishedAt != null) {
      events.add(CalendarEvent(
        kind: CalendarEventKind.finished,
        date: item.finishedAt!,
        title: title,
        itemId: item.itemId,
        ownedItemId: item.id,
      ));
    }
  }

  // --- Watch sessions ---
  for (final session in watchSessions) {
    if (session.isDeleted) continue;
    final title = titleFor(session.itemId);
    final epStr = session.isEpisodeSession
        ? ' S${session.seasonNumber}E${session.episodeNumber}'
        : '';
    events.add(CalendarEvent(
      kind: CalendarEventKind.watched,
      date: session.watchedAt,
      title: '$title$epStr',
      itemId: session.itemId,
    ));
  }

  // --- Loans ---
  // Resolve owned item → catalog item mapping.
  final ownedById = <String, OwnedItem>{
    for (final item in ownedItems) item.id: item,
  };

  for (final loan in loans) {
    final owned = ownedById[loan.ownedItemId];
    final title = owned != null
        ? titleFor(owned.itemId)
        : 'Unknown item';

    if (loan.dueDate != null) {
      events.add(CalendarEvent(
        kind: CalendarEventKind.loanDue,
        date: loan.dueDate!,
        title: title,
        subtitle: 'Loaned to ${loan.borrowerName}',
        ownedItemId: loan.ownedItemId,
        itemId: owned?.itemId,
      ));
    }
    if (loan.returnedDate != null) {
      events.add(CalendarEvent(
        kind: CalendarEventKind.loanReturn,
        date: loan.returnedDate!,
        title: title,
        subtitle: 'Returned by ${loan.borrowerName}',
        ownedItemId: loan.ownedItemId,
        itemId: owned?.itemId,
      ));
    }
  }

  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});
