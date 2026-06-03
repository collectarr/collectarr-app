import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
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

  test('catalog resolution preserves first-class manga, tv, and anime kinds', () {
    final resolvedManga = mangaLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'manga',
        singularLabel: 'Manga',
        pluralLabel: 'Manga',
        routeSegments: ['manga'],
        defaultProvider: 'mangadex',
        providers: ['mangadex', 'anilist'],
      ),
    ]);
    final resolvedTv = tvLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'tv',
        singularLabel: 'TV Show',
        pluralLabel: 'TV Shows',
        routeSegments: ['tv'],
        defaultProvider: 'tmdb',
        providers: ['tmdb'],
      ),
    ]);
    final resolvedAnime = animeLibraryConfig.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'anime',
        singularLabel: 'Anime',
        pluralLabel: 'Anime',
        routeSegments: ['anime'],
        defaultProvider: 'anilist',
        providers: ['anilist', 'tmdb'],
      ),
    ]);

    expect(resolvedManga.workspace.kind, CatalogMediaKind.manga);
    expect(resolvedManga.defaultSupportedMetadataProvider, 'mangadex');
    expect(resolvedTv.workspace.kind, CatalogMediaKind.tv);
    expect(resolvedTv.defaultSupportedMetadataProvider, 'tmdb');
    expect(resolvedAnime.workspace.kind, CatalogMediaKind.anime);
    expect(resolvedAnime.defaultSupportedMetadataProvider, 'anilist');
  });
}