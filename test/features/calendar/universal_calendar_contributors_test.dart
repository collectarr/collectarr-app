import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/owned_item.dart';
import 'package:collectarr_app/core/models/owned_item_projection.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/library/kinds/generic/ownership/generic_owned_details.dart';
import 'package:collectarr_app/features/calendar/universal_calendar_contributors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects owned lifecycle and loan events without kind semantics', () {
    final owned = OwnedItem<JsonEncodable>(
      id: 'owned-1',
      catalogRef: const CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-1',
      ),
      details: const GenericOwnedDetails(),
      purchaseDate: DateTime.utc(2026, 1, 1),
      purchaseStore: 'Seed Store',
      updatedAt: DateTime.utc(2026, 1, 3),
    );
    final loan = Loan(
      id: 'loan-1',
      ownedRef: const OwnedItemRef(
        kind: CatalogMediaKind.book,
        id: OwnedItemId('owned-1'),
      ),
      borrowerName: 'Reader',
      lentDate: DateTime.utc(2026, 1, 4),
      dueDate: DateTime.utc(2026, 1, 10),
      returnedDate: DateTime.utc(2026, 1, 12),
    );

    final context = UniversalCalendarContext(
      ownedItems: [owned],
      loans: [loan],
      titleForItem: (id) => id == 'book-1' ? 'Seed Book' : 'Unknown item',
    );
    final events = [
      ...const OwnedItemCalendarContributor().contribute(context),
      ...const LoanCalendarContributor().contribute(context),
    ];

    expect(events, hasLength(3));
    expect(
      events.map((event) => event.kind),
      containsAll(<CalendarEventKind>[
        CalendarEventKind.purchased,
        CalendarEventKind.loanDue,
        CalendarEventKind.loanReturn,
      ]),
    );
    expect(events.every((event) => event.title == 'Seed Book'), isTrue);
    expect(events.map((event) => event.eventId), contains('loan-due:loan-1'));
  });

  test('projects generic watches without inspecting hierarchy coordinates', () {
    final session = WatchSession(
      id: 'watch-1',
      targetRef: const CatalogEntityRef(
        kind: 'book',
        entityType: CatalogEntityType.work,
        id: 'book-1',
      ),
      watchedAt: DateTime.utc(2026, 1, 5),
      updatedAt: DateTime.utc(2026, 1, 5),
      seasonNumber: 9,
      episodeNumber: 9,
    );
    final context = UniversalCalendarContext(
      ownedItems: const [],
      loans: const [],
      watchSessions: [session],
      titleForItem: (_) => 'Seed Book',
    );

    final events =
        const GenericWatchCalendarContributor().contribute(context).toList();

    expect(events, hasLength(1));
    expect(events.single.kind, CalendarEventKind.watched);
    expect(events.single.title, 'Seed Book');
    expect(events.single.eventId, 'watch:watch-1');
  });

  test('does not duplicate a watch handled by a kind contributor', () {
    final context = UniversalCalendarContext(
      ownedItems: const [],
      loans: const [],
      watchSessions: [
        WatchSession(
          id: 'tv-watch-1',
          targetRef: const CatalogEntityRef(
            kind: 'tv',
            entityType: CatalogEntityType.episode,
            id: 'tv-1',
          ),
          watchedAt: DateTime.utc(2026, 1, 5),
          updatedAt: DateTime.utc(2026, 1, 5),
        ),
      ],
      titleForItem: (_) => 'TV item',
      hasKindContributor: (kind) => kind == CatalogMediaKind.tv,
    );

    expect(
      const GenericWatchCalendarContributor().contribute(context),
      isEmpty,
    );
  });
}
