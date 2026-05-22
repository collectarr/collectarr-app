import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation.dart';
import 'package:collectarr_app/features/library/home/library_home_catalog.dart';
import 'package:collectarr_app/features/library/home/library_home_nav_models.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
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

    expect(config.workspace.kind, 'podcast');
    expect(config.singularLabel, 'Podcast');
    expect(config.pluralLabel, 'Podcasts');
    expect(config.defaultMetadataProvider, 'podindex');
    expect(config.presentation, genericLibraryMediaPresentation);
    expect(config.workspace.defaultVisibleColumns,
      genericLibraryMediaPresentation.defaultVisibleColumns);
    expect(config.supportedMetadataProviders.single.id, 'podindex');
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
}
