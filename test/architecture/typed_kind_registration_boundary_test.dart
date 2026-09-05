import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const registrationPath =
      'lib/features/library/kinds/registry/library_kind_registration.dart';
  const pagesPath =
      'lib/features/library/kinds/registry/library_kind_pages.dart';
  const compositionRootPath =
      'lib/features/library/kinds/registry/collectarr_kind_modules.dart';
  const homePath = 'lib/features/library/home/home_page.dart';

  test('registration interface stays smaller than the runtime aggregate', () {
    final source = File(registrationPath).readAsStringSync();

    expect(source, isNot(contains('LibraryKindRuntime')));
    expect(source, contains('buildLibraryPage'));
    expect(source, contains('buildAdd'));
    expect(source, contains('openMediaEdit'));
    expect(source, contains('openReleaseEdit'));
  });

  test('page dispatch has no concrete-kind switch or imports', () {
    final source = File(pagesPath).readAsStringSync();

    expect(source, isNot(contains('LibraryKindRuntime')));
    expect(source, isNot(contains('CatalogMediaKind')));
    expect(source, isNot(contains('kinds/anime/page.dart')));
    expect(source, isNot(contains('kinds/movie/page.dart')));
    expect(source, isNot(contains('GenericLibraryPage')));
    expect(source, contains('registration.buildLibraryPage'));
  });

  test('composition root registers every active kind page', () {
    final source = File(compositionRootPath).readAsStringSync();
    for (final pageType in [
      'ComicLibraryPage',
      'MangaLibraryPage',
      'BookLibraryPage',
      'GameLibraryPage',
      'BoardGameLibraryPage',
      'MovieLibraryPage',
      'TvLibraryPage',
      'AnimeLibraryPage',
      'MusicLibraryPage',
    ]) {
      expect(source, contains(pageType));
    }
    expect(source, contains('collectarrKindRegistrations'));
    expect(source, contains('libraryKindRegistrationForRuntime'));
  });

  test('home dispatches through registration instead of page type', () {
    final source = File(homePath).readAsStringSync();

    expect(source, contains('registration:'));
    expect(source, contains('libraryKindRegistrationForRuntime'));
  });
}
