import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/kinds/generic/presentation.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('top navigation keeps the selected library visible on narrow widths',
      () {
    const types = [
      CatalogMediaType(
        kind: 'comic',
        singularLabel: 'Comic',
        pluralLabel: 'Comics',
        routeSegments: ['comics'],
      ),
      CatalogMediaType(
        kind: 'manga',
        singularLabel: 'Manga',
        pluralLabel: 'Manga',
        routeSegments: ['manga'],
      ),
      CatalogMediaType(
        kind: 'game',
        singularLabel: 'Game',
        pluralLabel: 'Games',
        routeSegments: ['games'],
      ),
      CatalogMediaType(
        kind: 'movie',
        singularLabel: 'Movie',
        pluralLabel: 'Movies',
        routeSegments: ['movies'],
      ),
    ];

    final split = splitLibraryNavTypes(types, 'movie', 2);

    expect(split.visible.map((type) => type.kind), ['comic', 'movie']);
    expect(split.overflow.map((type) => type.kind), ['manga', 'game']);
  });

  test('catalog-defined config carries unknown provider and fallback labels',
      () {
    const type = CatalogMediaType(
      kind: 'podcast',
      singularLabel: '',
      pluralLabel: '',
      routeSegments: ['podcasts'],
      defaultProvider: 'podindex',
      providers: ['podindex'],
    );

    final config = libraryConfigForCatalogType(
      type,
      const LibraryTypeRegistry([]),
    );

    expect(config.workspace.kind, CatalogMediaKind.unknown);
    expect(config.singularLabel, 'Podcast');
    expect(config.pluralLabel, 'Podcasts');
    expect(config.defaultMetadataProvider, 'podindex');
    expect(config.presentation, genericLibraryMediaPresentation);
    expect(config.workspace.defaultVisibleColumns,
      genericLibraryMediaPresentation.defaultVisibleColumns);
    expect(config.trackingProfile.name, readingTrackingProfile.name);
    expect(config.supportedMetadataProviders.single.id, 'podindex');
    expect(config.supportedMetadataProviders.single.supportsKind(null), isFalse);
    expect(config.supportedMetadataProviders.single.supportsKind('podcast'),
        isTrue);
  });

  test('catalog-defined config expands registered providers to new kinds', () {
    const type = CatalogMediaType(
      kind: 'podcast',
      singularLabel: '',
      pluralLabel: '',
      routeSegments: ['podcasts'],
      defaultProvider: 'openlibrary',
      providers: ['openlibrary'],
    );

    final config = libraryConfigForCatalogType(
      type,
      const LibraryTypeRegistry([]),
    );

    expect(config.defaultMetadataProvider, 'openlibrary');
    expect(config.supportedMetadataProviders.single.id, 'openlibrary');
    expect(config.supportedMetadataProviders.single.label, 'Open Library');
    expect(config.supportedMetadataProviders.single.supportsKind('podcast'),
        isTrue);
  });

  test('library nav labels use catalog kind defaults', () {
    expect(
      libraryNavLabel(
        const CatalogMediaType(
          kind: 'tv',
          singularLabel: 'Show',
          pluralLabel: 'Shows',
          routeSegments: ['tv'],
        ),
      ),
      'TV Shows',
    );
    expect(
      libraryNavLabel(
        const CatalogMediaType(
          kind: 'boardgame',
          singularLabel: 'Boardgame',
          pluralLabel: 'Boardgame',
          routeSegments: ['boardgames'],
        ),
      ),
      'Board Games',
    );
    expect(
      libraryNavLabel(
        const CatalogMediaType(
          kind: 'podcast',
          singularLabel: 'Podcast',
          pluralLabel: 'Podcasts',
          routeSegments: ['podcasts'],
        ),
      ),
      'Podcasts',
    );
  });

  test('canonical library nav kinds collapse legacy grouped children', () {
    expect(canonicalLibraryNavKind('manga'), 'comic');
    expect(canonicalLibraryNavKind('tv'), 'movie');
    expect(canonicalLibraryNavKind('anime'), 'movie');
    expect(canonicalLibraryNavKind('movie'), 'movie');
    expect(canonicalLibraryNavKind('comic'), 'comic');
    expect(canonicalLibraryNavKind('book'), 'book');
    expect(canonicalLibraryNavKind('  TV  '), 'movie');
    expect(canonicalLibraryNavKind(null), isNull);
  });

  test('library nav groups collapse comics and movies families', () {
    const types = [
      CatalogMediaType(
        kind: 'comic',
        singularLabel: 'Comic',
        pluralLabel: 'Comics',
        routeSegments: ['comics'],
      ),
      CatalogMediaType(
        kind: 'manga',
        singularLabel: 'Manga',
        pluralLabel: 'Manga',
        routeSegments: ['manga'],
      ),
      CatalogMediaType(
        kind: 'movie',
        singularLabel: 'Movie',
        pluralLabel: 'Movies',
        routeSegments: ['movies'],
      ),
      CatalogMediaType(
        kind: 'tv',
        singularLabel: 'Show',
        pluralLabel: 'Shows',
        routeSegments: ['tv'],
      ),
      CatalogMediaType(
        kind: 'anime',
        singularLabel: 'Anime',
        pluralLabel: 'Anime',
        routeSegments: ['anime'],
      ),
      CatalogMediaType(
        kind: 'book',
        singularLabel: 'Book',
        pluralLabel: 'Books',
        routeSegments: ['books'],
      ),
    ];

    final groups = buildLibraryNavGroups(types);

    expect(groups.map((group) => group.label), ['Comics', 'Movies', 'Books']);
    expect(groups[0].types.map((type) => type.kind), ['comic', 'manga']);
    expect(groups[1].types.map((type) => type.kind), ['movie', 'tv', 'anime']);
    expect(selectedLibraryNavGroup(groups, 'anime').label, 'Movies');
    expect(selectedLibraryNavGroup(groups, 'manga').containsKind('manga'), isTrue);
  });
}
