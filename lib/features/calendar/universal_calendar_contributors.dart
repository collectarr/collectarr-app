import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/calendar/calendar_event_contributor.dart';

typedef UniversalCalendarTitleForRef = String Function(CatalogEntityRef ref);
typedef UniversalCalendarKindPredicate = bool Function(CatalogMediaKind kind);

/// Inputs for non-kind calendar contributions.
///
/// The context intentionally contains only universal collection concepts.
/// Kind-specific catalog and tracking semantics are projected by the kind
/// contributor registry instead.
final class UniversalCalendarContext {
  const UniversalCalendarContext({
    required this.ownedItems,
    required this.loans,
    required this.titleForRef,
    this.watchSessions = const [],
    this.hasKindContributor = _noKindContributor,
  });

  final Iterable<OwnedItemSummary> ownedItems;
  final Iterable<Loan> loans;
  final Iterable<WatchSession> watchSessions;
  final UniversalCalendarTitleForRef titleForRef;
  final UniversalCalendarKindPredicate hasKindContributor;
}

final class OwnedItemCalendarContributor
    implements CalendarEventContributor<UniversalCalendarContext> {
  const OwnedItemCalendarContributor();

  @override
  Iterable<CalendarEvent> contribute(UniversalCalendarContext context) sync* {
    for (final item in context.ownedItems) {
      if (item.isDeleted) continue;
      final catalogRef = item.catalogRef;
      if (catalogRef == null) continue;
      final title = context.titleForRef(catalogRef);

      if (item.purchaseDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.purchased,
          date: item.purchaseDate!,
          title: title,
          eventId: 'owned-purchased:${item.ref.id.value}',
          subtitle: item.purchaseStore,
          catalogRef: catalogRef,
          ownedRef: item.ref,
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
    final ownedByRef = <OwnedItemRef, OwnedItemSummary>{
      for (final item in context.ownedItems) item.ref: item,
    };

    for (final loan in context.loans) {
      final owned = ownedByRef[loan.ownedRef];
      final catalogRef = owned?.catalogRef;
      final title =
          catalogRef == null ? 'Unknown item' : context.titleForRef(catalogRef);

      if (loan.dueDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.loanDue,
          date: loan.dueDate!,
          title: title,
          eventId: 'loan-due:${loan.id}',
          subtitle: 'Loaned to ${loan.borrowerName}',
          ownedRef: loan.ownedRef,
          catalogRef: catalogRef,
        );
      }
      if (loan.returnedDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.loanReturn,
          date: loan.returnedDate!,
          title: title,
          eventId: 'loan-return:${loan.id}',
          subtitle: 'Returned by ${loan.borrowerName}',
          ownedRef: loan.ownedRef,
          catalogRef: catalogRef,
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
          context.hasKindContributor(session.targetRef.mediaKind)) {
        continue;
      }
      yield CalendarEvent(
        kind: CalendarEventKind.watched,
        date: session.watchedAt,
        title: context.titleForRef(session.targetRef),
        eventId: 'watch:${session.id}',
        catalogRef: session.targetRef,
      );
    }
  }
}

const universalCalendarContributors =
    <CalendarEventContributor<UniversalCalendarContext>>[
  OwnedItemCalendarContributor(),
  LoanCalendarContributor(),
  GenericWatchCalendarContributor(),
];

bool _noKindContributor(CatalogMediaKind kind) => false;
