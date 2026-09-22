import 'dart:io';

import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_kind_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const registrationPath =
      'lib/features/library/kinds/registry/library_kind_registration.dart';
  const pagesPath =
      'lib/features/library/kinds/registry/library_kind_pages.dart';
  const compositionRootPath =
      'lib/features/library/kinds/registry/collectarr_kind_registry.dart';
  const registrationsPath =
      'lib/features/library/kinds/registry/collectarr_kind_registry.dart';
  const routerPath = 'lib/core/routing/app_router.dart';
  const productionRoot = 'lib';
  const homePath = 'lib/features/library/home/home_page.dart';

  test('registration boundaries stay smaller than the runtime aggregate', () {
    final source = File(registrationPath).readAsStringSync();

    expect(
        source, contains('abstract interface class LibraryKindRegistration'));
    expect(source, isNot(contains('LibraryKindCapabilityBundle')));
    expect(source, contains('CatalogMediaKind get kind'));
    expect(source, contains('LibraryKindIdentity get identity'));
    expect(source, contains('buildLibraryPage'));
    expect(source, isNot(contains('buildAdd')));
    expect(source, isNot(contains('openMediaEdit')));
    expect(source, isNot(contains('openReleaseEdit')));
    expect(source, isNot(contains('openOwnedEdit')));
  });

  test('page dispatch has no concrete-kind switch or imports', () {
    final source = File(pagesPath).readAsStringSync();

    expect(source, contains('LibraryKindRegistration'));
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
    expect(source, contains('collectarrKindRegistrationsList'));
    expect(registrations, contains('collectarrKindRegistrations'));
    expect(registrations, contains('LibraryKindRegistration'));
    expect(registrations, contains('collectarrKindRoutes'));
    expect(
      registrations,
      contains('Map<CatalogMediaKind, LibraryKindRegistration>'),
    );
    expect(registrations, contains('for (final registration'));
    expect(
      registrations,
      isNot(contains('LibraryKindRegistration get _module')),
      reason: 'registrations must call concrete kind entrypoints directly',
    );
  });

  test('composition roots are explicit and codegen stays mechanical', () {
    final generator =
        File('tool/generate_kind_registries.dart').readAsStringSync();
    expect(generator, isNot(contains('_discoverKinds')));
    expect(generator, isNot(contains('_renderRegistry')));
    expect(generator, isNot(contains('_KindDescriptor')));
    expect(
      generator,
      contains(
          'Drift table composition and development seed contributor lists'),
    );

    const activeKinds = <CatalogMediaKind>{
      CatalogMediaKind.anime,
      CatalogMediaKind.boardgame,
      CatalogMediaKind.book,
      CatalogMediaKind.comic,
      CatalogMediaKind.game,
      CatalogMediaKind.manga,
      CatalogMediaKind.movie,
      CatalogMediaKind.music,
      CatalogMediaKind.tv,
    };
    expect(libraryCalendarContributorsByKind.keys, containsAll(activeKinds));
    expect(libraryBarcodeResolversByKind.keys, containsAll(activeKinds));
    expect(libraryAdminContributorsByKind.keys, containsAll(activeKinds));
    expect(collectionCsvProfilesByKind.keys, containsAll(activeKinds));
    for (final kind in activeKinds) {
      expect(
        libraryAddForKind(kind).search.typedProviderSearchBuilder,
        isNotNull,
        reason: '${kind.apiValue} must use its typed provider search boundary',
      );
    }
    expect(libraryOwnedSummaryReadersByKind.keys, containsAll(activeKinds));
    expect(libraryCatalogTransportCodecs, hasLength(activeKinds.length));
  });

  test(
      'catalog transport registry stores behavior boundaries, not erased values',
      () {
    final catalogRegistrySource =
        File('lib/features/catalog/library_catalog_registry.dart')
            .readAsStringSync();

    expect(
      catalogRegistrySource,
      contains('const List<CatalogKindTransportBoundary>'),
    );
    expect(
      catalogRegistrySource,
      isNot(contains('CatalogKindTransportCodec<Object?>')),
    );
    expect(libraryCatalogTransportCodecs, hasLength(9));
    expect(
      libraryCatalogTransportCodecs,
      everyElement(isNotNull),
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
    for (final entry in registrations.entries) {
      expect(source, contains('${entry.value}(),'));
      expect(source, contains('CatalogMediaKind.${entry.key}'));
    }

    final ownedSource = File(
      'lib/features/library/owned/owned_kind_contributor_registry.dart',
    ).readAsStringSync();
    expect(ownedSource, contains('collectarrOwnedKindContributors'));
    for (final contributor in [
      'animeOwnedContributor',
      'boardGameOwnedContributor',
      'bookOwnedContributor',
      'comicOwnedContributor',
      'gameOwnedContributor',
      'mangaOwnedContributor',
      'movieOwnedContributor',
      'musicOwnedContributor',
      'tvOwnedContributor',
    ]) {
      expect(ownedSource, contains(contributor));
    }
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

  test('tests keep kind dispatch concrete instead of casting dynamic', () {
    final testFiles = Directory('test')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final dynamicProviderMapperCast = RegExp(
      r'TypedLibraryKindProviderMapper\s*<\s*dynamic\s*>',
    );
    final erasedKindDispatch = RegExp(
      r'(?:CatalogMediaKind|LibraryKind)\s*[.?]\s*[^\n;]*\bas\s+Object\b',
    );
    final violations = <String>[];
    for (final file in testFiles) {
      final source = file.readAsStringSync();
      if (dynamicProviderMapperCast.hasMatch(source) ||
          erasedKindDispatch.hasMatch(source)) {
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
