import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/config/generic_library_media_presentation.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_enums.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/home/home_catalog.dart';
import 'package:collectarr_app/features/library/home/home_nav_models.dart';
import 'package:collectarr_app/features/library/config/library_type_registry.dart';
import 'package:collectarr_app/features/library/tracking/media_tracking_profile.dart';
import 'package:flutter/material.dart';
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
    expect(split.overflow.map((type) => type.kind), ['game']);
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
      LibraryTypeRegistry([]),
    );

    expect(config.workspace.kind, CatalogMediaKind.unknown);
    expect(config.singularLabel, 'Podcast');
    expect(config.pluralLabel, 'Podcasts');
    expect(config.defaultMetadataProvider, 'podindex');
    expect(config.presentation, genericLibraryMediaPresentation);
    expect(config.defaultVisibleColumns, contains(LibraryTableColumn.title));
    expect(config.workspace.icon, Icons.category_outlined);
    expect(config.workspace.accent, kLibraryFallbackAccent);
    expect(config.trackingProfile.name, readingTrackingProfile.name);
    expect(config.supportedMetadataProviders.single.id, 'podindex');
    expect(
        config.supportedMetadataProviders.single.supportsKind(null), isFalse);
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
      LibraryTypeRegistry([]),
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
          kind: 'movie',
          singularLabel: 'Movie',
          pluralLabel: 'Movies',
          routeSegments: ['movies'],
        ),
      ),
      'Movies',
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

  test('canonical library nav kinds only normalize whitespace and case', () {
    expect(canonicalLibraryNavKind('movie'), 'movie');
    expect(canonicalLibraryNavKind('comic'), 'comic');
    expect(canonicalLibraryNavKind('book'), 'book');
    expect(canonicalLibraryNavKind('  MOVIE  '), 'movie');
    expect(canonicalLibraryNavKind(null), isNull);
  });

  test('library nav groups follow the top-level catalog kinds', () {
    const types = [
      CatalogMediaType(
        kind: 'comic',
        singularLabel: 'Comic',
        pluralLabel: 'Comics',
        routeSegments: ['comics'],
      ),
      CatalogMediaType(
        kind: 'movie',
        singularLabel: 'Movie',
        pluralLabel: 'Movies',
        routeSegments: ['movies'],
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
    expect(groups[0].types.map((type) => type.kind), ['comic']);
    expect(groups[1].types.map((type) => type.kind), ['movie']);
    expect(selectedLibraryNavGroup(groups, 'movie').label, 'Movies');
    expect(selectedLibraryNavGroup(groups, 'comic').containsKind('comic'), isTrue);
  });
}
