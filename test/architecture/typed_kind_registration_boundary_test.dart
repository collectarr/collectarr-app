import 'dart:io';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const registrationPath =
      'lib/features/library/kinds/registry/library_kind_registration.dart';
  const pagesPath =
      'lib/features/library/kinds/registry/library_kind_pages.dart';
  const compositionRootPath =
      'lib/features/library/kinds/registry/collectarr_kind_modules.dart';
  const registrationsPath =
      'lib/features/library/kinds/registry/collectarr_kind_registry.g.dart';
  const routerPath = 'lib/core/routing/app_router.dart';
  const productionRoot = 'lib';
  const homePath = 'lib/features/library/home/home_page.dart';

  test('registration interface stays smaller than the runtime aggregate', () {
    final source = File(registrationPath).readAsStringSync();

    expect(source, isNot(contains('LibraryKindModule')));
    expect(source, contains('buildLibraryPage'));
    expect(source, contains('buildAdd'));
    expect(source, contains('openMediaEdit'));
    expect(source, contains('openReleaseEdit'));
    expect(source, contains('openOwnedEdit'));
  });

  test('page dispatch has no concrete-kind switch or imports', () {
    final source = File(pagesPath).readAsStringSync();

    expect(source, isNot(contains('LibraryKindModule')));
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
    expect(registrations, contains('collectarrKindRoutes'));
    expect(
      registrations,
      contains('Map<CatalogMediaKind, LibraryKindRegistration>'),
    );
    expect(registrations, isNot(contains('for (final registration')));
    expect(
      registrations,
      isNot(contains('LibraryKindModule get _module')),
      reason: 'registrations must call concrete kind entrypoints directly',
    );
  });

  test('generated registrations dispatch through concrete kind types', () {
    final source = File(registrationsPath).readAsStringSync();
    const registrations = <String, String>{
      'anime': 'AnimeRegistration',
      'boardgame': 'BoardgameRegistration',
      'book': 'BookRegistration',
      'comic': 'ComicRegistration',
      'game': 'GameRegistration',
      'manga': 'MangaRegistration',
      'movie': 'MovieRegistration',
      'music': 'MusicRegistration',
      'tv': 'TvRegistration',
    };
    const ownedTypes = <String, String>{
      'anime': 'AnimeOwnedItem',
      'boardgame': 'BoardGameOwnedItem',
      'book': 'BookOwnedItem',
      'comic': 'ComicOwnedItem',
      'game': 'GameOwnedItem',
      'manga': 'MangaOwnedItem',
      'movie': 'MovieOwnedItem',
      'music': 'MusicOwnedItem',
      'tv': 'TvOwnedItem',
    };

    for (final entry in registrations.entries) {
      expect(source, contains('${entry.value}(),'));
      expect(source, contains('CatalogMediaKind.${entry.key}'));
    }

    final refSection = _sourceSection(
      source,
      'OwnedItemRef collectarrTypedOwnedItemRef',
      'Map<String, dynamic> collectarrTypedOwnedItemJson',
    );
    final jsonSection = _sourceSection(
      source,
      'Map<String, dynamic> collectarrTypedOwnedItemJson',
      'bool? collectarrTypedOwnedItemIsDigital',
    );
    final digitalSection = _sourceSection(
      source,
      'bool? collectarrTypedOwnedItemIsDigital',
      'final collectarrTypedOwnedItemSyncSerializers',
    );
    final syncDecoderSection = _sourceSection(
      source,
      'final collectarrTypedOwnedItemSyncDeserializers',
      'const List<CatalogKindRepositoryCodec>',
    );

    for (final entry in ownedTypes.entries) {
      expect(refSection, contains('if (item is ${entry.value})'));
      expect(jsonSection, contains('if (item is ${entry.value})'));
      expect(digitalSection, contains('if (item is ${entry.value})'));
      expect(
        syncDecoderSection,
        contains('CatalogMediaKind.${entry.key}: ${entry.value}.fromJson'),
      );
    }
    expect(refSection, isNot(contains('CatalogItemDto')));
    expect(jsonSection, isNot(contains('CatalogItemDto')));
    expect(jsonSection, isNot(contains('OwnedItemProjection')));
    expect(digitalSection, isNot(contains('CatalogItemDto')));
  });

  test('application router consumes generated kind routes', () {
    final source = File(routerPath).readAsStringSync();

    expect(source, contains('collectarr_kind_routes.dart'));
    expect(source, contains('...collectarrKindRoutes'));
    expect(source, isNot(contains('comic_series_detail_page.dart')));
    expect(source, isNot(contains("AppRoutes.comicSeries")));
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
    expect(source, isNot(contains('compareEntriesByRules')));
    expect(source, isNot(contains('groupModeSupportsCompletion')));
    expect(source, isNot(contains('orderedTableColumns')));

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

  test('production code does not recover erased workspace through a property',
      () {
    final productionFiles = Directory(productionRoot)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final erasedWorkspaceFiles = <String>[];
    final workspaceProperty = RegExp(r'\.\s*workspace\b');
    for (final file in productionFiles) {
      if (workspaceProperty.hasMatch(file.readAsStringSync())) {
        erasedWorkspaceFiles.add(file.path);
      }
    }
    expect(erasedWorkspaceFiles, isEmpty);
  });

  test('tests keep kind dispatch typed instead of switching or casting dynamic',
      () {
    final testFiles = Directory('test')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final kindSwitch = RegExp(
      r'switch\s*\([^)]*(CatalogMediaKind|LibraryKind|mediaKind)',
    );
    final dynamicProviderMapperCast = RegExp(
      r'TypedLibraryKindProviderMapper\s*<\s*dynamic\s*>',
    );
    final violations = <String>[];
    for (final file in testFiles) {
      final source = file.readAsStringSync();
      if (kindSwitch.hasMatch(source) ||
          dynamicProviderMapperCast.hasMatch(source)) {
        violations.add(file.path);
      }
    }
    expect(violations, isEmpty);
  });

  test('generated registrations are keyed by their concrete kind', () {
    expect(collectarrKindRegistrations, hasLength(9));
    expect(
      collectarrKindRegistrations.keys,
      containsAll(<CatalogMediaKind>[
        CatalogMediaKind.anime,
        CatalogMediaKind.boardgame,
        CatalogMediaKind.book,
        CatalogMediaKind.comic,
        CatalogMediaKind.game,
        CatalogMediaKind.manga,
        CatalogMediaKind.movie,
        CatalogMediaKind.music,
        CatalogMediaKind.tv,
      ]),
    );
    for (final entry in collectarrKindRegistrations.entries) {
      expect(entry.value.kind, entry.key);
    }
  });
}

String _sourceSection(String source, String start, String end) {
  final startIndex = source.indexOf(start);
  final endIndex = source.indexOf(end, startIndex + start.length);
  if (startIndex < 0 || endIndex < 0) {
    throw StateError('Unable to locate generated section $start');
  }
  return source.substring(startIndex, endIndex);
}
