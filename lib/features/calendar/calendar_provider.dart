import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/features/calendar/universal_calendar_contributors.dart';
import 'package:collectarr_app/features/library/entries/library_entry_store.dart';
import 'package:collectarr_app/features/collection/collection_controller.dart';
import 'package:collectarr_app/features/collection/repositories/loan_repository.dart';
import 'package:collectarr_app/features/library/config/library_calendar_contributor.dart';
import 'package:collectarr_app/features/library/kinds/registry/catalog_workspace_data_dispatch.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/state/local_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides all calendar events aggregated from collection data.
final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final db = ref.watch(localDatabaseProvider);
  final libraryEntries = await ref.watch(collectionSummariesProvider.future);
  final watchSessions = await ref.watch(watchSessionsProvider.future);
  final loans = await LoanRepository(db).getAllLoans();

  final libraryEntryRefs = <LibraryEntryRef>{};
  for (final item in libraryEntries) {
    libraryEntryRefs.add(item.ref);
  }
  for (final session in watchSessions) {
    libraryEntryRefs.add(session.libraryEntryRef);
  }

  final records = await LibraryEntryStore(db).list();
  final titleByRef = <LibraryEntryRef, String>{
    for (final record in records)
      LibraryEntryRef(
        kind: record.kind,
        id: LibraryEntryId(record.id),
      ): workspaceKindDataFromKindData(record.kind, record.catalogData)
          .displayLabel,
  };
  String titleFor(LibraryEntryRef ref) => titleByRef[ref] ?? 'Unknown item';

  final events = <CalendarEvent>[];

  final calendarContext = LibraryCalendarContext(
    database: db,
    libraryEntryRefs: libraryEntryRefs,
    watchSessions: watchSessions,
    titleForRef: titleFor,
  );
  for (final contributor in libraryCalendarContributors) {
    events.addAll(await contributor.contribute(calendarContext));
  }

  final universalCalendarContext = UniversalCalendarContext(
    libraryEntries: libraryEntries,
    loans: loans,
    watchSessions: watchSessions,
    titleForRef: titleFor,
    hasKindContributor: (kind) =>
        libraryCalendarContributorForKind(kind) != null,
  );
  for (final contributor in universalCalendarContributors) {
    events.addAll(await contributor.contribute(universalCalendarContext));
  }

  // Resolve collection item → catalog item mapping.
  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
});
