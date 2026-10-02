import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/core/models/loan.dart';
import 'package:collectarr_app/core/models/money.dart';
import 'package:collectarr_app/core/models/collection_item_projection.dart';
import 'package:collectarr_app/core/models/watch_session.dart';
import 'package:collectarr_app/features/calendar/universal_calendar_contributors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('projects owned lifecycle and loan events without kind semantics', () {
    final owned = CollectionItemSummary(
      ref: const CollectionItemRef(
        kind: CatalogMediaKind.book,
        id: CollectionItemId('owned-1'),
      ),
      title: 'book-1',
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-1',
      ),
      purchaseDate: DateTime.utc(2026, 1, 1),
      purchaseStore: 'Seed Store',
      updatedAt: DateTime.utc(2026, 1, 3),
    );
    final loan = Loan(
      id: 'loan-1',
      collectionItemRef: const CollectionItemRef(
        kind: CatalogMediaKind.book,
        id: CollectionItemId('owned-1'),
      ),
      borrowerName: 'Reader',
      lentDate: DateTime.utc(2026, 1, 4),
      dueDate: DateTime.utc(2026, 1, 10),
      returnedDate: DateTime.utc(2026, 1, 12),
    );

    final context = UniversalCalendarContext(
      collectionItems: [owned],
      loans: [loan],
      titleForRef: (ref) => ref.id == 'book-1' ? 'Seed Book' : 'Unknown item',
    );
    final events = [
      ...const CollectionItemCalendarContributor().contribute(context),
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
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-1',
      ),
      watchedAt: DateTime.utc(2026, 1, 5),
      updatedAt: DateTime.utc(2026, 1, 5),
    );
    final context = UniversalCalendarContext(
      collectionItems: const [],
      loans: const [],
      watchSessions: [session],
      titleForRef: (_) => 'Seed Book',
    );

    final events =
        const GenericWatchCalendarContributor().contribute(context).toList();

    expect(events, hasLength(1));
    expect(events.single.kind, CalendarEventKind.watched);
    expect(events.single.title, 'Seed Book');
    expect(events.single.eventId, 'watch:watch-1');
  });

  test('keeps equal owned ids distinct by media kind', () {
    final book = CollectionItemSummary(
      ref: const CollectionItemRef(
        kind: CatalogMediaKind.book,
        id: CollectionItemId('shared-id'),
      ),
      title: 'Book copy',
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.book,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'book-1',
      ),
      updatedAt: DateTime.utc(2026, 1, 3),
    );
    final comic = CollectionItemSummary(
      ref: const CollectionItemRef(
        kind: CatalogMediaKind.comic,
        id: CollectionItemId('shared-id'),
      ),
      title: 'Comic copy',
      catalogRef: const CatalogEntityRef(
        kind: CatalogMediaKind.comic,
        entityType: CatalogEntityTypeId.catalogItem,
        id: 'comic-1',
      ),
      updatedAt: DateTime.utc(2026, 1, 3),
    );
    final context = UniversalCalendarContext(
      collectionItems: [book, comic],
      loans: [
        Loan(
          id: 'book-loan',
          collectionItemRef: book.ref,
          borrowerName: 'Reader',
          lentDate: DateTime.utc(2026, 1, 4),
          dueDate: DateTime.utc(2026, 1, 10),
        ),
        Loan(
          id: 'comic-loan',
          collectionItemRef: comic.ref,
          borrowerName: 'Collector',
          lentDate: DateTime.utc(2026, 1, 4),
          dueDate: DateTime.utc(2026, 1, 11),
        ),
      ],
      titleForRef: (ref) => ref.id,
    );

    final events = const LoanCalendarContributor().contribute(context).toList();

    expect(events, hasLength(2));
    expect(
        events.map((event) => event.title), containsAll(['book-1', 'comic-1']));
  });

  test('does not duplicate a watch handled by a kind contributor', () {
    final context = UniversalCalendarContext(
      collectionItems: const [],
      loans: const [],
      watchSessions: [
        WatchSession(
          id: 'tv-watch-1',
          targetRef: const CatalogEntityRef(
            kind: CatalogMediaKind.tv,
            entityType: CatalogEntityTypeId('episode'),
            id: 'tv-1',
          ),
          watchedAt: DateTime.utc(2026, 1, 5),
          updatedAt: DateTime.utc(2026, 1, 5),
        ),
      ],
      titleForRef: (_) => 'TV item',
      hasKindContributor: (kind) => kind == CatalogMediaKind.tv,
    );

    expect(
      const GenericWatchCalendarContributor().contribute(context),
      isEmpty,
    );
  });
}
