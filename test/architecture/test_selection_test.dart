import 'package:flutter_test/flutter_test.dart';

import '../../tool/testing/test_selection.dart';

void main() {
  const files = [
    'test/architecture/boundaries_test.dart',
    'test/contracts/catalog_test.dart',
    'test/features/library/generic/sidebar_test.dart',
    'test/features/library/kinds/book/domain/book_test.dart',
    'test/features/library/kinds/music/domain/album_test.dart',
  ];
  TestSelection select(
          {String kinds = 'released', Set<String> exclude = const {}}) =>
      TestSelection(
          files: files,
          knownKinds: {'music', 'book'},
          releasedKinds: {'music'},
          kinds: kinds,
          excludedKinds: exclude);

  test('default selection follows released kinds and retains all shared checks',
      () {
    final result = select();
    expect(result.selectedFiles, containsAll(files.take(3)));
    expect(result.excludedFiles, [files[3]]);
    expect(result.selectedFiles, contains(files[4]));
  });
  test('source kind tests can be enabled explicitly', () {
    expect(select(kinds: 'all').excludedFiles, isEmpty);
    expect(select(kinds: 'book').excludedFiles, [files[4]]);
    expect(select(kinds: 'book').selectedFiles, containsAll(files.take(4)));
  });
  test('disabling every kind still selects common correctness', () {
    expect(select(exclude: {'music'}).selectedFiles, files.take(3).toList());
  });
  test('unknown names fail instead of silently excluding tests', () {
    expect(() => select(kinds: 'musci'), throwsArgumentError);
    expect(() => select(exclude: {'musci'}), throwsArgumentError);
  });
  test('compact paths include no excluded subtree', () {
    expect(select(kinds: 'all').paths, ['test']);
    expect(select().paths, contains('test/features/library/kinds/music'));
    expect(select().paths, isNot(contains('test/features/library/kinds/book')));
    expect(select().paths, contains('test/architecture'));
  });
}
