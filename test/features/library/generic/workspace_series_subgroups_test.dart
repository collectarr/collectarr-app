import 'package:collectarr_app/features/library/generic/workspace.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('series subgroups are disabled for tv and comics', () {
    expect(libraryShouldUseSeriesSubgroups(tvLibraryConfig), isFalse);
    expect(libraryShouldUseSeriesSubgroups(comicsLibraryConfig), isFalse);
  });

  test('series subgroups remain enabled for book-like kinds', () {
    expect(libraryShouldUseSeriesSubgroups(booksLibraryConfig), isTrue);
  });
}
