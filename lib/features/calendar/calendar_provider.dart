import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/features/calendar/universal_calendar_contributors.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides all calendar events aggregated from collection data.
final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final ownedItems = await ref.watch(collectionProvider.future);
  final watchSessions = await ref.watch(watchSessionsProvider.future);
  final loans = await LoanRepository(db).getAllLoans();
  final catalogRepo = LibraryCatalogRepository(db);

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

  final calendarContext = LibraryCalendarContext(
    catalogItems: catalogById.values,
    watchSessions: watchSessions,
    titleForItem: titleFor,
  );
  for (final contributor in libraryCalendarContributors) {
    events.addAll(contributor.contribute(calendarContext));
  }

  final universalCalendarContext = UniversalCalendarContext(
    ownedItems: ownedItems,
    loans: loans,
    watchSessions: watchSessions,
    titleForItem: titleFor,
    hasKindContributor: (kind) =>
        libraryCalendarContributorForKind(kind) != null,
  );
  for (final contributor in universalCalendarContributors) {
    events.addAll(contributor.contribute(universalCalendarContext));
  }

  // Resolve owned item → catalog item mapping.
  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});
