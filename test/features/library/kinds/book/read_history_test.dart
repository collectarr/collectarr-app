import 'package:collectarr_app/features/library/kinds/book/domain/book_read_event.dart';
import 'package:collectarr_app/features/library/kinds/book/edit/read_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the last read event sets the reading status, dates and progress', () {
    final draft = BookReadingDraft(null,
        events: [
          BookReadEvent(
              status: 'Read',
              startDate: DateTime(2024, 5, 1),
              endDate: DateTime(2024, 5, 2),
              reader: 'Ana',
              pagesRead: 300),
        ],
        pageCount: 300);
    addTearDown(draft.dispose);
    expect(draft.hasChanges, isFalse);

    draft.rows.add(BookReadEventRow(
        BookReadEvent(status: 'Reading', startDate: DateTime(2025, 1, 3))));
    draft.rows.add(BookReadEventRow(const BookReadEvent()));

    expect(draft.hasChanges, isTrue);
    expect(draft.events, hasLength(2));
    final selection = draft.selection;
    expect(selection.readStatus, 'Reading');
    expect(selection.startedAt, DateTime(2025, 1, 3));
    expect(selection.finishedAt, isNull);
    expect(selection.progressTotal, 300);
    expect(selection.timesCompleted, 1);
    expect(draft.eventsJson.first, {
      'status': 'Read',
      'start_date': '2024-05-01',
      'end_date': '2024-05-02',
      'reader': 'Ana',
      'pages_read': 300,
    });
  });

  test('read events survive a JSON round trip', () {
    final event = BookReadEvent(
        status: 'Dropped', endDate: DateTime(2023, 12, 31), pagesRead: 12);
    expect(BookReadEvent.listFromJson([event.toJson()]), [event]);
    expect(BookReadEvent.listFromJson(null), isEmpty);
  });
}
