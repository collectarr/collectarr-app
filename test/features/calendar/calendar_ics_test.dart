import 'package:collectarr_app/core/models/calendar_event.dart';
import 'package:collectarr_app/features/calendar/calendar_ics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 6, 24, 19, 5, 30);

  test('wraps events in a VCALENDAR with required headers', () {
    final ics = buildCalendarIcs(
      [
        CalendarEvent(
          kind: CalendarEventKind.releaseDate,
          date: DateTime(2026, 5, 14),
          title: 'Absolute Batman',
          itemId: 'comic-1',
        ),
      ],
      now: fixedNow,
    );

    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(ics, contains('VERSION:2.0\r\n'));
    expect(ics, contains('PRODID:-//Collectarr//Collection Calendar//EN\r\n'));
    expect(ics.trimRight(), endsWith('END:VCALENDAR'));
  });

  test('emits an all-day VEVENT with summary, stamp and date', () {
    final ics = buildCalendarIcs(
      [
        CalendarEvent(
          kind: CalendarEventKind.finished,
          date: DateTime(2026, 5, 14),
          title: 'Dune',
          itemId: 'movie-9',
        ),
      ],
      now: fixedNow,
    );

    expect(ics, contains('BEGIN:VEVENT\r\n'));
    expect(ics, contains('END:VEVENT\r\n'));
    expect(ics, contains('DTSTART;VALUE=DATE:20260514\r\n'));
    expect(ics, contains('DTSTAMP:20260624T190530Z\r\n'));
    expect(ics, contains('SUMMARY:Finished: Dune\r\n'));
    expect(ics, contains('UID:finished-20260514-movie-9-dune@collectarr\r\n'));
  });

  test('escapes special characters and includes the subtitle', () {
    final ics = buildCalendarIcs(
      [
        CalendarEvent(
          kind: CalendarEventKind.loanDue,
          date: DateTime(2026, 7, 1),
          title: 'Saga, Vol. 1; Deluxe',
          subtitle: 'Loaned to Bob',
          ownedItemId: 'owned-3',
        ),
      ],
      now: fixedNow,
    );

    expect(ics, contains('SUMMARY:Loan due: Saga\\, Vol. 1\\; Deluxe\r\n'));
    expect(ics, contains('DESCRIPTION:Loaned to Bob\r\n'));
  });

  test('produces one VEVENT per event', () {
    final ics = buildCalendarIcs(
      [
        CalendarEvent(
          kind: CalendarEventKind.purchased,
          date: DateTime(2026, 1, 2),
          title: 'A',
          itemId: 'a',
        ),
        CalendarEvent(
          kind: CalendarEventKind.watched,
          date: DateTime(2026, 1, 3),
          title: 'B',
          itemId: 'b',
        ),
      ],
      now: fixedNow,
    );

    expect('BEGIN:VEVENT'.allMatches(ics).length, 2);
    expect('END:VEVENT'.allMatches(ics).length, 2);
  });

  test('folds content lines longer than 75 octets', () {
    final longTitle = 'X' * 200;
    final ics = buildCalendarIcs(
      [
        CalendarEvent(
          kind: CalendarEventKind.releaseDate,
          date: DateTime(2026, 1, 2),
          title: longTitle,
          itemId: 'long',
        ),
      ],
      now: fixedNow,
    );

    for (final line in ics.split('\r\n')) {
      expect(line.length, lessThanOrEqualTo(75));
    }
  });

  test('handles an empty event list', () {
    final ics = buildCalendarIcs(const [], now: fixedNow);
    expect(ics, contains('BEGIN:VCALENDAR'));
    expect(ics, isNot(contains('BEGIN:VEVENT')));
  });
}
