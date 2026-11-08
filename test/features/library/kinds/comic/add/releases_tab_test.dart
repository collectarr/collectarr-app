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

  test('the week menu reads as the reference writes it', () {
    final periods = comicReleasePeriods(DateTime(2026, 11, 8));
    expect(periods.map((period) => '${period.title}: ${period.range}'), [
      'Earlier: Week 44 | Oct 25 - Oct 31',
      'Last week: Week 45 | Nov 01 - Nov 07',
      'This week: Week 46 | Nov 08 - Nov 14',
      'Next week: Week 47 | Nov 15 - Nov 21',
      'Later: Week 48 | Nov 22 - Nov 28',
      'All weeks: Week 44 | Oct 25 - Jan 09',
    ]);
  });

  test('a week at the end of a year keeps its ISO number', () {
    expect(
        comicReleaseRangeLabel(
            DateTime.utc(2026, 12, 27), DateTime.utc(2027, 1, 2)),
        'Week 53 | Dec 27 - Jan 02');
  });
}
