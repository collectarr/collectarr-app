import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const registrationPath =
      'lib/features/library/kinds/registry/library_kind_registration.dart';
  const pagesPath =
      'lib/features/library/kinds/registry/library_kind_pages.dart';
  const compositionRootPath =
      'lib/features/library/kinds/registry/collectarr_kind_modules.dart';
  const registrationsPath =
      'lib/features/library/kinds/registry/library_kind_registrations.dart';
  const productionRoot = 'lib';
  const homePath = 'lib/features/library/home/home_page.dart';

  test('registration interface stays smaller than the runtime aggregate', () {
    final source = File(registrationPath).readAsStringSync();

    expect(source, isNot(contains('LibraryKindRuntime')));
    expect(source, contains('buildLibraryPage'));
    expect(source, contains('buildAdd'));
    expect(source, contains('openMediaEdit'));
    expect(source, contains('openReleaseEdit'));
    expect(source, contains('openOwnedEdit'));
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
    final registrations = File(registrationsPath).readAsStringSync();
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
      expect(registrations, contains(pageType));
    }
    expect(source, contains('library_kind_registrations.dart'));
    expect(registrations, contains('collectarrKindRegistrations'));
    expect(registrations, contains('libraryKindRegistrationForKind'));
  });

  test('home dispatches through registration instead of page type', () {
    final source = File(homePath).readAsStringSync();

    expect(source, contains('registration:'));
    expect(source, contains('libraryKindRegistrationForKind'));
  });

  test('metadata rehydration does not live in the kind registry', () {
    final source = File(compositionRootPath).readAsStringSync();
    expect(source, isNot(contains('typedCatalogItemFrom')));
    expect(source, isNot(contains('decodeLibraryKindMetadata')));

    final productionFiles = Directory(productionRoot)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in productionFiles) {
      final contents = file.readAsStringSync();
      expect(contents, isNot(contains('typedCatalogItemFrom')),
          reason: file.path);
      expect(contents, isNot(contains('decodeLibraryKindMetadata')),
          reason: file.path);
    }
  });
}
