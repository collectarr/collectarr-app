import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TmdbImportService', () {
    final service = TmdbImportService();

    test('parses TMDB object payload results', () {
      final entries = service.parseCollectionPayload(
        '''
        {
          "page": 1,
          "results": [
            {
              "id": 603,
              "title": "The Matrix",
              "original_title": "The Matrix",
              "overview": "Wake up, Neo.",
              "poster_path": "/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg",
              "release_date": "1999-03-30",
              "rating": 9
            }
          ]
        }
        ''',
        collection: TmdbImportCollection.ratedMovies,
      );

      expect(entries, hasLength(1));
      expect(entries.single.tmdbId, 603);
      expect(entries.single.title, 'The Matrix');
      expect(entries.single.releaseYear, 1999);
      expect(
        entries.single.posterUrl,
        'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      );
    });

    test('builds local synthetic items with display and original titles', () {
      final entry = TmdbImportEntry(
        tmdbId: 603,
        mediaType: TmdbMediaType.movie,
        collection: TmdbImportCollection.ratedMovies,
        title: 'The Matrix',
        originalTitle: 'The Matrix',
        posterPath: '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
        rawPayload: const <String, dynamic>{'id': 603, 'title': 'The Matrix'},
      );

      final item = service.localSyntheticCatalogItem(entry);

      expect(item.displayTitle, 'The Matrix');
      expect(item.localizedTitle, 'The Matrix');
      expect(item.originalTitle, 'The Matrix');
      expect(item.searchAliases, contains('The Matrix'));
      expect(item.displayCoverUrl, isNotNull);
    });

    test('matches on exact title and year before falling back', () async {
      final entry = TmdbImportEntry(
        tmdbId: 11,
        mediaType: TmdbMediaType.movie,
        collection: TmdbImportCollection.ratedMovies,
        title: 'Dune',
        releaseDate: DateTime.utc(2021, 10, 22),
        rawPayload: const <String, dynamic>{'id': 11, 'title': 'Dune'},
      );

      final preview = await service.previewImport(
        collection: TmdbImportCollection.ratedMovies,
        entries: [entry],
        searchCatalog: (_) async => [
          CatalogItem(
              id: 'movie-1984',
              kind: 'movie',
              title: 'Dune',
              releaseYear: 1984),
          CatalogItem(
              id: 'movie-2021',
              kind: 'movie',
              title: 'Dune',
              releaseYear: 2021),
        ],
      );

      expect(preview.matched, hasLength(1));
      expect(preview.matched.single.catalogItem?.id, 'movie-2021');
      expect(
        preview.matched.single.quality,
        TmdbImportMatchQuality.exactTitleAndYear,
      );
    });

    test('parses TMDB CSV exports with common header aliases', () {
      final entries = service.parseCollectionPayload(
        '''
tmdb_id,title,release_date,rating,overview,poster_url
603,The Matrix,1999-03-30,9,Wake up Neo,https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg
''',
        collection: TmdbImportCollection.ratedMovies,
      );

      expect(entries, hasLength(1));
      expect(entries.single.tmdbId, 603);
      expect(entries.single.title, 'The Matrix');
      expect(entries.single.releaseYear, 1999);
      expect(entries.single.rating, 9);
      expect(entries.single.posterPath, '/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg');
    });

    test('skips malformed TMDB CSV rows when valid rows exist', () {
      final entries = service.parseCollectionPayload(
        '''
tmdb_id,title,release_date,rating
,Missing id,2020-01-01,7
603,The Matrix,1999-03-30,9
''',
        collection: TmdbImportCollection.ratedMovies,
      );

      expect(entries, hasLength(1));
      expect(entries.single.tmdbId, 603);
      expect(entries.single.title, 'The Matrix');
    });

    test('parses TMDB exported ratings CSV and prefers Your Rating', () {
      final entries = service.parseCollectionPayload(
        '''
TMDb ID,IMDb ID,Type,Name,Release Date,Season Number,Episode Number,Rating,Your Rating,Date Rated
453395,tt9419884,movie,Doctor Strange in the Multiverse of Madness,2022-05-04T00:00:00Z,,,7.229,7.0,2022-09-20T00:00:00Z
92749,tt10234724,tv,Moon Knight,2022-03-30T00:00:00Z,,,7.647,6.0,2022-09-20T00:00:00Z
''',
        collection: TmdbImportCollection.ratedMovies,
      );

      expect(entries, hasLength(2));
      expect(entries[0].tmdbId, 453395);
      expect(entries[0].title, 'Doctor Strange in the Multiverse of Madness');
      expect(entries[0].rating, 7.0);
      expect(entries[0].releaseYear, 2022);
      expect(entries[0].mediaType, TmdbMediaType.movie);
      expect(entries[1].tmdbId, 92749);
      expect(entries[1].title, 'Moon Knight');
      expect(entries[1].mediaType, TmdbMediaType.tv);
      expect(entries[1].collection, TmdbImportCollection.ratedTv);
    });

    test('parses TMDB watchlist export from zip archives', () {
      final csvBytes = Uint8List.fromList(
        utf8.encode(
          '''
TMDb ID,IMDb ID,Type,Name,Release Date,Season Number,Episode Number,Rating,Your Rating,Date Rated
438695,tt6467266,movie,Sing 2,2021-12-01T00:00:00Z,,,7.833,,2022-02-22T16:22:35Z
63174,tt4052886,tv,Lucifer,2016-01-25T00:00:00Z,,,8.434,,2022-02-22T16:17:56Z
''',
        ),
      );
      final archive = Archive()
        ..addFile(
          ArchiveFile(
            '618d1cf4d768fe00677dfdaf_watchlist_2026.05.25.csv',
            csvBytes.length,
            csvBytes,
          ),
        );
      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));

      final entries = service.parseCollectionFileBytes(
        zipBytes,
        fileName: 'tmdb-watchlist-export.zip',
        collection: TmdbImportCollection.watchlistMovies,
      );

      expect(entries, hasLength(2));
      expect(entries[0].tmdbId, 438695);
      expect(entries[0].title, 'Sing 2');
      expect(entries[0].releaseYear, 2021);
      expect(entries[0].mediaType, TmdbMediaType.movie);
      expect(entries[1].tmdbId, 63174);
      expect(entries[1].title, 'Lucifer');
      expect(entries[1].mediaType, TmdbMediaType.tv);
      expect(entries[1].collection, TmdbImportCollection.watchlistTv);
    });

    test('dispatches imports for matches and proposals for unmatched',
        () async {
      final matchedEntry = TmdbImportEntry(
        tmdbId: 603,
        mediaType: TmdbMediaType.movie,
        collection: TmdbImportCollection.ratedMovies,
        title: 'The Matrix',
        rawPayload: const <String, dynamic>{'id': 603, 'title': 'The Matrix'},
      );
      final unmatchedEntry = TmdbImportEntry(
        tmdbId: 680,
        mediaType: TmdbMediaType.movie,
        collection: TmdbImportCollection.watchlistMovies,
        title: 'Pulp Fiction',
        rawPayload: const <String, dynamic>{'id': 680, 'title': 'Pulp Fiction'},
      );

      final preview = await service.previewImport(
        collection: TmdbImportCollection.ratedMovies,
        entries: [matchedEntry, unmatchedEntry],
        searchCatalog: (entry) async {
          if (entry.tmdbId == 603) {
            return [
              CatalogItem(id: 'movie-603', kind: 'movie', title: 'The Matrix'),
            ];
          }
          return const <CatalogItem>[];
        },
      );

      final imported = <String>[];
      final proposed = <int>[];
      final result = await service.importPreview(
        preview: preview,
        importMatch: (item, entry) async {
          imported.add('${item.id}:${entry.tmdbId}');
        },
        proposeUnmatched: (entry) async {
          proposed.add(entry.tmdbId);
        },
      );

      expect(imported, ['movie-603:603']);
      expect(proposed, [680]);
      expect(result.importedCount, 1);
      expect(result.proposedCount, 1);
    });

    test('enriches unmatched entries with TMDB movie details', () async {
      final dio = Dio(
        BaseOptions(baseUrl: 'https://api.themoviedb.org'),
      )..httpClientAdapter = _FakeHttpClientAdapter((options) async {
          expect(options.path, '/3/movie/680');
          expect(options.queryParameters['api_key'], 'tmdb-key');
          return ResponseBody.fromString(
            jsonEncode({
              'id': 680,
              'title': 'Pulp Fiction',
              'original_title': 'Pulp Fiction',
              'overview': 'A burger-loving hitman, his partner, and more.',
              'poster_path': '/vQWk5YBFWF4bZaofAbv0tShwBvQ.jpg',
              'release_date': '1994-09-10',
              'credits': {
                'cast': [
                  {'name': 'John Travolta'},
                ],
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });
      final enrichedService = TmdbImportService(dio: dio);
      final entry = TmdbImportEntry(
        tmdbId: 680,
        mediaType: TmdbMediaType.movie,
        collection: TmdbImportCollection.ratedMovies,
        title: 'Pulp Fiction',
        rating: 8,
        rawPayload: const <String, dynamic>{
          'id': 680,
          'title': 'Pulp Fiction',
        },
      );

      final enriched = await enrichedService.enrichEntry(
        apiKey: 'tmdb-key',
        entry: entry,
      );

      expect(enriched.overview, contains('burger-loving hitman'));
      expect(enriched.releaseYear, 1994);
      expect(enriched.posterPath, '/vQWk5YBFWF4bZaofAbv0tShwBvQ.jpg');
      expect(
        enriched.rawPayload['tmdb_import'],
        containsPair('user_rating', 8),
      );
      expect(enriched.rawPayload['source_export_payload'], entry.rawPayload);
      expect(
        (enriched.rawPayload['credits'] as Map<String, dynamic>)['cast'],
        isNotEmpty,
      );
    });

    test('merges matched catalog items with richer TMDB details', () {
      final item = CatalogItem(
        id: 'movie-680',
        kind: 'movie',
        title: 'Pulp Fiction',
        displayTitle: 'Pulp Fiction',
      );
      final entry = TmdbImportEntry(
        tmdbId: 680,
        mediaType: TmdbMediaType.movie,
        collection: TmdbImportCollection.ratedMovies,
        title: 'Pulp Fiction',
        originalTitle: 'Pulp Fiction',
        overview: 'A burger-loving hitman, his partner, and more.',
        posterPath: '/vQWk5YBFWF4bZaofAbv0tShwBvQ.jpg',
        releaseDate: DateTime.utc(1994, 9, 10),
        rawPayload: const <String, dynamic>{
          'runtime': 154,
          'genres': [
            {'name': 'Crime'},
            {'name': 'Drama'},
          ],
          'production_companies': [
            {'name': 'Miramax'},
          ],
          'production_countries': [
            {'name': 'United States of America'},
          ],
          'spoken_languages': [
            {'name': 'English'},
          ],
        },
      );

      final merged = service.mergeMatchedCatalogItem(item, entry);

      expect(merged.coverImageUrl, entry.posterUrl);
      expect(merged.thumbnailImageUrl, entry.posterUrl);
      expect(merged.publisher, 'Miramax');
      expect(merged.synopsis, contains('burger-loving hitman'));
      expect(merged.releaseDate, DateTime.utc(1994, 9, 10));
      expect(merged.releaseYear, 1994);
      expect(merged.video?.runtimeMinutes, 154);
      expect(merged.genres, containsAll(['Crime', 'Drama']));
      expect(merged.country, 'United States of America');
      expect(merged.language, 'English');
    });
  });
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) {
    return _handler(options);
  }
}
