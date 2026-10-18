import 'package:collectarr_app/core/utils/natural_text_compare.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_group_values.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> sorted(List<String> values) =>
    [...values]..sort(compareNaturalText);

void main() {
  test('ignores letter case', () {
    expect(sorted(['Zappa', 'abba', 'Beatles']), ['abba', 'Beatles', 'Zappa']);
  });

  test('compares digit runs by value', () {
    expect(sorted(['Raft 10', 'Raft 2', 'Raft 1']),
        ['Raft 1', 'Raft 2', 'Raft 10']);
    expect(sorted(['Disc 02', 'Disc 1']), ['Disc 1', 'Disc 02']);
  });

  test('sorts accented letters with their base letter', () {
    expect(sorted(['Zappa', 'Édith Piaf', 'Eagles', 'Fauré']),
        ['Eagles', 'Édith Piaf', 'Fauré', 'Zappa']);
    expect(foldForSort('Straße Æon Œuvre'), 'strasse aeon oeuvre');
  });

  test('keeps a stable order for text that differs only in case', () {
    expect(compareNaturalText('abc', 'ABC'), isNot(0));
    expect(compareNaturalText('abc', 'abc'), 0);
  });

  test('folder buckets use it and keep [None] first', () {
    final buckets = ['Zappa', '[None]', 'Raft 10', 'abba', 'Raft 2', 'Édith']
      ..sort(compareLibraryGroupBuckets);
    expect(buckets, ['[None]', 'abba', 'Édith', 'Raft 2', 'Raft 10', 'Zappa']);
  });
}
