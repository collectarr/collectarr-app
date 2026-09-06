import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/calendar/calendar_event_contributor.dart';

typedef UniversalCalendarTitleForItem = String Function(String itemId);
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
    required this.titleForItem,
    this.watchSessions = const [],
    this.hasKindContributor = _noKindContributor,
  });

  final Iterable<OwnedItem> ownedItems;
  final Iterable<Loan> loans;
  final Iterable<WatchSession> watchSessions;
  final UniversalCalendarTitleForItem titleForItem;
  final UniversalCalendarKindPredicate hasKindContributor;
}

final class OwnedItemCalendarContributor
    implements CalendarEventContributor<UniversalCalendarContext> {
  const OwnedItemCalendarContributor();

  @override
  Iterable<CalendarEvent> contribute(UniversalCalendarContext context) sync* {
    for (final item in context.ownedItems) {
      if (item.isDeleted) continue;
      final title = context.titleForItem(item.itemId);

      if (item.purchaseDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.purchased,
          date: item.purchaseDate!,
          title: title,
          eventId: 'owned-purchased:${item.id}',
          subtitle: item.purchaseStore,
          itemId: item.itemId,
          ownedItemId: item.id,
        );
      }
      if (item.startedAt != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.started,
          date: item.startedAt!,
          title: title,
          eventId: 'owned-started:${item.id}',
          itemId: item.itemId,
          ownedItemId: item.id,
        );
      }
      if (item.finishedAt != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.finished,
          date: item.finishedAt!,
          title: title,
          eventId: 'owned-finished:${item.id}',
          itemId: item.itemId,
          ownedItemId: item.id,
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
    final ownedById = <String, OwnedItem>{
      for (final item in context.ownedItems) item.id: item,
    };

    for (final loan in context.loans) {
      final owned = ownedById[loan.ownedRef.id.value];
      final title =
          owned == null ? 'Unknown item' : context.titleForItem(owned.itemId);

      if (loan.dueDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.loanDue,
          date: loan.dueDate!,
          title: title,
          eventId: 'loan-due:${loan.id}',
          subtitle: 'Loaned to ${loan.borrowerName}',
          ownedItemId: loan.ownedRef.id.value,
          itemId: owned?.itemId,
        );
      }
      if (loan.returnedDate != null) {
        yield CalendarEvent(
          kind: CalendarEventKind.loanReturn,
          date: loan.returnedDate!,
          title: title,
          eventId: 'loan-return:${loan.id}',
          subtitle: 'Returned by ${loan.borrowerName}',
          ownedItemId: loan.ownedRef.id.value,
          itemId: owned?.itemId,
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
        title: context.titleForItem(session.itemId),
        eventId: 'watch:${session.id}',
        itemId: session.itemId,
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
