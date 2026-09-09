import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/calendar/universal_calendar_contributors.dart';
import 'package:collectarr_app/features/catalog/catalog_display_summary_repository.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides all calendar events aggregated from collection data.
final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final ownedItems = await ref.watch(collectionSummariesProvider.future);
  final watchSessions = await ref.watch(watchSessionsProvider.future);
  final loans = await LoanRepository(db).getAllLoans();

  final catalogRefs = <CatalogEntityRef>{};
  for (final item in ownedItems) {
    if (item.catalogRef case final ref?) {
      catalogRefs.add(_rootCatalogRef(ref));
    }
  }
  for (final session in watchSessions) {
    catalogRefs.add(_rootCatalogRef(session.targetRef));
  }

  final catalogByRef =
      await CatalogDisplaySummaryRepository(db).findByRefs(catalogRefs);
  String titleFor(CatalogEntityRef ref) =>
      catalogByRef[_rootCatalogRef(ref)]?.title ?? 'Unknown item';

  final events = <CalendarEvent>[];

  final calendarContext = LibraryCalendarContext(
    database: db,
    catalogRefs: catalogRefs,
    watchSessions: watchSessions,
    titleForRef: titleFor,
  );
  for (final contributor in libraryCalendarContributors) {
    events.addAll(await contributor.contribute(calendarContext));
  }

  final universalCalendarContext = UniversalCalendarContext(
    ownedItems: ownedItems,
    loans: loans,
    watchSessions: watchSessions,
    titleForRef: titleFor,
    hasKindContributor: (kind) =>
        libraryCalendarContributorForKind(kind) != null,
  );
  for (final contributor in universalCalendarContributors) {
    events.addAll(await contributor.contribute(universalCalendarContext));
  }

  // Resolve owned item → catalog item mapping.
  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});

CatalogEntityRef _rootCatalogRef(CatalogEntityRef ref) {
  final rootId = ref.rootId;
  if (rootId == null || rootId.isEmpty) return ref;
  return ref.copyWith(
    id: rootId,
    entityType: CatalogEntityType.work,
    rootId: null,
  );
}
