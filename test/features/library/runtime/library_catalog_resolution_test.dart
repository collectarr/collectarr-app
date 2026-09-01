import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/models/media_catalog.dart';
import 'package:collectarr_app/features/library/kinds/anime/anime_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/book/book_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/manga/manga_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/tv/tv_kind_module.dart';
import 'package:collectarr_app/features/library/runtime/library_catalog_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog resolution normalizes known catalog display labels', () {
    final resolvedMusic = musicKindModule.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'music',
        singularLabel: 'Album',
        pluralLabel: 'Albums',
        routeSegments: ['music'],
        defaultProvider: 'musicbrainz',
        providers: ['musicbrainz'],
      ),
    ]);
    final resolvedMovies = movieKindModule.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'movie',
        singularLabel: 'Film',
        pluralLabel: 'Films',
        routeSegments: ['movies'],
        defaultProvider: 'tmdb',
        providers: ['tmdb'],
      ),
    ]);

    expect(resolvedMusic.identity.singularLabel, 'Music');
    expect(resolvedMusic.identity.pluralLabel, 'Music');
    expect(resolvedMovies.identity.singularLabel, 'Film');
    expect(resolvedMovies.identity.pluralLabel, 'Films');
  });

  test('catalog resolution titleizes unknown provider ids', () {
    final resolvedBooks = bookKindModule.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'book',
        singularLabel: 'Book',
        pluralLabel: 'Books',
        routeSegments: ['books'],
        defaultProvider: 'custom-provider',
        providers: ['custom-provider'],
      ),
    ]);

    expect(resolvedBooks.metadata.providers.single.id, 'custom-provider');
    expect(resolvedBooks.metadata.providers.single.label, 'Custom Provider');
  });

  test('catalog resolution preserves first-class manga, tv, and anime kinds',
      () {
    final resolvedManga = mangaKindModule.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'manga',
        singularLabel: 'Manga',
        pluralLabel: 'Manga',
        routeSegments: ['manga'],
        defaultProvider: 'mangadex',
        providers: ['mangadex', 'anilist'],
      ),
    ]);
    final resolvedTv = tvKindModule.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'tv',
        singularLabel: 'TV Show',
        pluralLabel: 'TV Shows',
        routeSegments: ['tv'],
        defaultProvider: 'tmdb',
        providers: ['tmdb'],
      ),
    ]);
    final resolvedAnime = animeKindModule.resolveWithCatalog(const [
      CatalogMediaType(
        kind: 'anime',
        singularLabel: 'Anime',
        pluralLabel: 'Anime',
        routeSegments: ['anime'],
        defaultProvider: 'anilist',
        providers: ['anilist', 'tmdb'],
      ),
    ]);

    expect(resolvedManga.kind, CatalogMediaKind.manga);
    expect(
      resolvedManga.metadata.defaultSupportedOption(resolvedManga.kind)?.id,
      'mangadex',
    );
    expect(resolvedTv.kind, CatalogMediaKind.tv);
    expect(
      resolvedTv.metadata.defaultSupportedOption(resolvedTv.kind)?.id,
      'tmdb',
    );
    expect(resolvedAnime.kind, CatalogMediaKind.anime);
    expect(
      resolvedAnime.metadata.defaultSupportedOption(resolvedAnime.kind)?.id,
      'anilist',
    );
  });
}
