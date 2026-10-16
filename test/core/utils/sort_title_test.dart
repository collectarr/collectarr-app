import 'package:collectarr_app/core/utils/sort_title.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a leading article moves to the end of the sort title', () {
    expect(automaticSortTitle('The Wall'), 'Wall, The');
    expect(automaticSortTitle('A Night at the Opera'), 'Night at the Opera, A');
    expect(automaticSortTitle('An Awesome Wave'), 'Awesome Wave, An');
    expect(automaticSortTitle('Theatre of Tragedy'), 'Theatre of Tragedy');
    expect(automaticSortTitle('Anastasis'), 'Anastasis');
    expect(automaticSortTitle('The'), 'The');
  });

  test('explicit sort titles win and automatic ones follow the title', () {
    expect(resolveSortTitle('The Wall', null), 'Wall, The');
    expect(resolveSortTitle('The Wall', ''), 'Wall, The');
    expect(resolveSortTitle('The Wall', 'Pink Floyd Wall'), 'Pink Floyd Wall');
    expect(followTitleChange('The Wal', 'The Wall', 'Wal, The'), 'Wall, The');
    expect(followTitleChange('The Wal', 'The Wall', null), 'Wall, The');
    expect(followTitleChange('The Wal', 'The Wall', 'Custom'), 'Custom');
  });
}
