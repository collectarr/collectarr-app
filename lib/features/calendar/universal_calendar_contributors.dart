import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/library_entry_projection.dart';
import 'package:collectarr_app/core/models/library_entry_ref.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/calendar/calendar_event_contributor.dart';

typedef UniversalCalendarTitleForRef = String Function(LibraryEntryRef ref);
typedef UniversalCalendarKindPredicate = bool Function(CatalogMediaKind kind);

/// Inputs for non-kind calendar contributions.
///
/// The context intentionally contains only universal collection concepts.
/// Kind-specific catalog and tracking semantics are projected by the kind
/// contributor registry instead.
final class UniversalCalendarContext {
  const UniversalCalendarContext({
    required this.libraryEntries,
    required this.loans,
    required this.titleForRef,
    this.watchSessions = const [],
    this.hasKindContributor = _noKindContributor,
  });

  final Iterable<LibraryEntrySummary> libraryEntries;
  final Iterable<Loan> loans;
  final Iterable<WatchSession> watchSessions;
  final UniversalCalendarTitleForRef titleForRef;
  final UniversalCalendarKindPredicate hasKindContributor;
}

final class LibraryEntryCalendarContributor
    implements CalendarEventContributor<UniversalCalendarContext> {
  const LibraryEntryCalendarContributor();

  @override
  Iterable<CalendarEvent> contribute(UniversalCalendarContext context) sync* {
    for (final item in context.libraryEntries) {
      if (item.isDeleted) continue;
      final title = context.titleForRef(item.ref);

      if (item.purchaseDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.purchased,
          date: item.purchaseDate!,
          title: title,
          eventId: 'entry-purchased:${item.ref.id.value}',
          subtitle: item.purchaseStore,
          libraryEntryRef: item.ref,
        );
      }
    }
  }
}

final class LoanCalendarContributor
    implements CalendarEventContributor<UniversalCalendarContext> {
  const LoanCalendarContributor();

  @override
  Iterable<CalendarEvent> contribute(UniversalCalendarContext context) sync* {
    final entryByRef = <LibraryEntryRef, LibraryEntrySummary>{
      for (final item in context.libraryEntries) item.ref: item,
    };

    for (final loan in context.loans) {
      final entry = entryByRef[loan.libraryEntryRef];
      final title = entry == null
          ? 'Unknown item'
          : context.titleForRef(loan.libraryEntryRef);

      if (loan.dueDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.loanDue,
          date: loan.dueDate!,
          title: title,
          eventId: 'loan-due:${loan.id}',
          subtitle: 'Loaned to ${loan.borrowerName}',
          libraryEntryRef: loan.libraryEntryRef,
        );
      }
      if (loan.returnedDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.loanReturn,
          date: loan.returnedDate!,
          title: title,
          eventId: 'loan-return:${loan.id}',
          subtitle: 'Returned by ${loan.borrowerName}',
          libraryEntryRef: loan.libraryEntryRef,
        );
      }
    }
  }
}

/// Projects watch sessions for kinds that have no semantic calendar
/// contributor. It deliberately does not inspect episode or other hierarchy
/// coordinates.
final class GenericWatchCalendarContributor
    implements CalendarEventContributor<UniversalCalendarContext> {
  const GenericWatchCalendarContributor();

  @override
  Iterable<CalendarEvent> contribute(UniversalCalendarContext context) sync* {
    for (final session in context.watchSessions) {
      if (session.isDeleted ||
          context.hasKindContributor(session.libraryEntryRef.kind)) {
        continue;
      }
      yield CalendarEvent(
        kind: CalendarEventKind.watched,
        date: session.watchedAt,
        title: context.titleForRef(session.libraryEntryRef),
        eventId: 'watch:${session.id}',
        libraryEntryRef: session.libraryEntryRef,
      );
    }
  }
}

const universalCalendarContributors =
    <CalendarEventContributor<UniversalCalendarContext>>[
  LibraryEntryCalendarContributor(),
  LoanCalendarContributor(),
  GenericWatchCalendarContributor(),
];

bool _noKindContributor(CatalogMediaKind kind) => false;
