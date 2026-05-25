import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/settings/tmdb_import_service.dart';
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

    test('matches on exact title and year before falling back', () async {
      final entry = TmdbImportEntry(
        tmdbId: 11,
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

    test('dispatches imports for matches and proposals for unmatched',
        () async {
      final matchedEntry = TmdbImportEntry(
        tmdbId: 603,
        collection: TmdbImportCollection.ratedMovies,
        title: 'The Matrix',
        rawPayload: const <String, dynamic>{'id': 603, 'title': 'The Matrix'},
      );
      final unmatchedEntry = TmdbImportEntry(
        tmdbId: 680,
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
  });
}
