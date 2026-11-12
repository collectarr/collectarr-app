import 'package:collectarr_app/core/utils/natural_text_compare.dart';
import 'package:collectarr_app/features/library/workspace/schema/group_values.dart';
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

  test('ignores leading zeros until the numbers are otherwise equal', () {
    expect(
        sorted(['Vol 010', 'Vol 9', 'Vol 0']), ['Vol 0', 'Vol 9', 'Vol 010']);
    expect(compareNaturalText('Vol 007', 'Vol 7'), isNot(0));
    expect(compareNaturalText('Vol 000', 'Vol 1'), lessThan(0));
    expect(compareNaturalText('7 Up 12', '7 Up 3'), greaterThan(0));
  });

  test('compares digit runs in accented text by value', () {
    expect(sorted(['Été 10', 'Été 9', 'Ete 2']), ['Ete 2', 'Été 9', 'Été 10']);
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
