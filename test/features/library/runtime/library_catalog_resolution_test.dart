import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/runtime/library_catalog_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog resolution normalizes known catalog display labels', () {
    final resolvedMusic = musicLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'music',
        singularLabel: 'Album',
        pluralLabel: 'Albums',
        routeSegments: ['music'],
        defaultProvider: 'musicbrainz',
        providers: ['musicbrainz'],
      ),
    ]);
    final resolvedMovies = moviesLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'movie',
        singularLabel: 'Film',
        pluralLabel: 'Films',
        routeSegments: ['movies'],
        defaultProvider: 'tmdb',
        providers: ['tmdb'],
      ),
    ]);

    expect(resolvedMusic.singularLabel, 'Music');
    expect(resolvedMusic.pluralLabel, 'Music');
    expect(resolvedMovies.singularLabel, 'Film');
    expect(resolvedMovies.pluralLabel, 'Films');
  });

  test('catalog resolution titleizes unknown provider ids', () {
    final resolvedBooks = booksLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'book',
        singularLabel: 'Book',
        pluralLabel: 'Books',
        routeSegments: ['books'],
        defaultProvider: 'custom-provider',
        providers: ['custom-provider'],
      ),
    ]);

    expect(resolvedBooks.supportedMetadataProviders.single.id,
        'custom-provider');
    expect(resolvedBooks.supportedMetadataProviders.single.label,
        'Custom Provider');
  });
}