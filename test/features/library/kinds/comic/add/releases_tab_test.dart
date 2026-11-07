import 'package:collectarr_app/features/library/kinds/comic/add/releases_tab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a release week starts on the Sunday before any day in it', () {
    final sunday = DateTime.utc(2026, 10, 18);
    for (var offset = 0; offset < 7; offset++) {
      expect(comicReleaseWeekStart(sunday.add(Duration(days: offset))), sunday);
    }
    expect(comicReleaseWeekStart(DateTime(2026, 10, 25, 23, 59)),
        DateTime.utc(2026, 10, 25));
  });

  test('the week reads as the reference writes it', () {
    expect(comicReleaseWeekLabel(DateTime.utc(2026, 10, 18)),
        'Week 43 | Oct 18 - Oct 24');
    expect(comicReleaseWeekLabel(DateTime.utc(2026, 12, 27)),
        'Week 53 | Dec 27 - Jan 02');
  });
}
