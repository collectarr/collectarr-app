import 'package:collectarr_app/features/library/add/models/library_add_tracking_draft.dart';
import 'package:collectarr_app/features/library/edit/draft/library_edit_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime.utc(2024, 2, 3);
  final add = LibraryAddTrackingDraft(
    rating: 4,
    readStatus: 'planned',
    startedAt: date,
    finishedAt: date,
    notes: 'Notes',
  );
  final edit = LibraryTrackingEditSelection(
    rating: 4,
    readStatus: 'planned',
    progressCurrent: 2,
    progressTotal: 10,
    timesCompleted: 1,
    startedAt: date,
    finishedAt: date,
    notes: 'Notes',
  );

  List<Object?> addValues(LibraryAddTrackingDraft value) => [
        value.rating,
        value.readStatus,
        value.startedAt,
        value.finishedAt,
        value.notes,
      ];
  List<Object?> editValues(LibraryTrackingEditSelection value) => [
        value.rating,
        value.readStatus,
        value.progressCurrent,
        value.progressTotal,
        value.timesCompleted,
        value.startedAt,
        value.finishedAt,
        value.notes,
      ];

  test('omitted Add tracking fields retain their values', () {
    expect(addValues(add.copyWith()), addValues(add));
    final changed = add.copyWith(notes: null, rating: 0);
    expect(changed.notes, isNull);
    expect(changed.rating, 0);
    expect(changed.readStatus, add.readStatus);
    expect(changed.startedAt, date);
    expect(changed.finishedAt, date);
  });

  test('all nullable Add tracking fields can be cleared explicitly', () {
    expect(
        addValues(add.copyWith(
            rating: null,
            readStatus: null,
            startedAt: null,
            finishedAt: null,
            notes: null)),
        everyElement(isNull));
    expect(addValues(add), [4, 'planned', date, date, 'Notes']);
  });

  test('omitted Edit tracking fields retain their values', () {
    expect(editValues(edit.copyWith()), editValues(edit));
    final changed = edit.copyWith(finishedAt: null, progressCurrent: 0);
    expect(changed.finishedAt, isNull);
    expect(changed.progressCurrent, 0);
    expect(changed.startedAt, date);
    expect(changed.progressTotal, 10);
    expect(changed.notes, 'Notes');
  });

  test('all nullable Edit tracking fields can be cleared explicitly', () {
    expect(
        editValues(edit.copyWith(
            rating: null,
            readStatus: null,
            progressCurrent: null,
            progressTotal: null,
            timesCompleted: null,
            startedAt: null,
            finishedAt: null,
            notes: null)),
        everyElement(isNull));
    expect(editValues(edit), [4, 'planned', 2, 10, 1, date, date, 'Notes']);
  });
}
