import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_kind_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_node_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movie work dto maps rich metadata into movie domain', () {
    final dto = CatalogItemDto.fromJson({
      'id': 'movie-1',
      'title': 'The Matrix',
      'search_aliases': ['Matrix 1'],
      'genres': ['sci-fi', 'action'],
      'first_publication_date': '1999-03-31T00:00:00Z',
      'original_publication_date': '1999-03-31T00:00:00Z',
      'original_language': 'en',
      'sort_title': 'Matrix, The',
      'subtitle': 'The One',
      'description':
          'A computer hacker learns about the true nature of reality.',
      'cover_image_url': 'https://example.com/matrix.jpg',
      'thumbnail_image_url': 'https://example.com/matrix-thumb.jpg',
      'publisher': 'Warner Bros.',
      'cover_date': '1999-03-31T00:00:00Z',
      'release_date': '1999-03-31T00:00:00Z',
      'release_year': 1999,
      'barcode': '0883929317585',
      'variant': '4K UHD Collector',
      'crossover': 'Matrix Franchise',
      'plot_summary': 'Hacker learns reality is a simulation.',
      'plot_description': 'Neo is chosen to free humanity.',
      'creators': [
        {'name': 'Wachowskis', 'role': 'director'},
      ],
      'characters': ['Neo', 'Morpheus', 'Trinity'],
      'story_arcs': ['Matrix Trilogy'],
      'country': 'US',
      'language': 'en',
      'age_rating': 'R',
      'audience_rating': 'R',
      'physical_format_label': '4K UHD',
      'video': {
        'runtime_minutes': 136,
        'color': 'Color',
        'screen_ratio': '2.39:1',
        'audio_tracks': 'Dolby Atmos, DTS-HD MA 5.1',
        'subtitles': 'English, Spanish',
        'hdr': 'HDR10, Dolby Vision',
        'age_rating': 'R',
        'audience_rating': 'R',
        'directors': ['Wachowskis'],
      },
      'trailer_urls': [
        {
          'id': 'tr-1',
          'url': 'https://youtube.com/watch?v=vKQi3bBA1y8',
          'title': 'Official Trailer',
        },
      ],
      'editions': [
        {
          'id': 'movie-edition-1',
          'work_id': 'movie-1',
          'display_title': '4K UHD Collector',
          'format': '4k',
          'publisher': 'Warner Bros.',
          'upc': '0883929317585',
          'publication_date': '1999-03-31T00:00:00Z',
          'language': 'en',
          'discs': [
            {
              'id': 'disc-1',
              'disc_number': 1,
              'sequence_number': 1,
              'format_label': '4K UHD',
              'features': ['HDR10'],
              'hdr': ['HDR10'],
            },
          ],
        },
      ],
      'kind': 'movie',
    });

    final work = MovieCatalogItem.fromDto(dto);

    expect(work.title, 'The Matrix');
    expect(work.releases, hasLength(1));
    expect(work.releases.single.media, hasLength(1));
    expect(work.videoDetails.audioTracks, 'Dolby Atmos, DTS-HD MA 5.1');
    expect(work.releases.single.videoDetails?.nrDiscs, 1);
    expect(work.videoDetails.runtimeMinutes, 136);
    expect(work.trailerUrls, hasLength(1));
  });

  test('MovieKindSchema fields return non-null values from MovieWorkspaceDto',
      () {
    final dto = CatalogItemDto.fromJson({
      'id': 'movie-1',
      'title': 'The Matrix',
      'genres': ['Sci-Fi', 'Action'],
      'release_date': '1999-03-31T00:00:00Z',
      'video': {
        'runtime_minutes': 136,
        'audio_tracks': 'Dolby Atmos',
      },
      'editions': [
        {
          'id': 'ed-1',
          'title': '4K SteelBook',
          'display_title': '4K SteelBook',
          'release_date': '1999-03-31T00:00:00Z',
        },
      ],
      'kind': 'movie',
    });

    final source = ShelfEntry(
      itemId: 'movie-1',
      catalogItem: dto,
    );

    final workspaceDto = const MovieWorkspaceProjector().projectTitle(
      source: source,
      node: const LibraryTitleNodeRef(titleItemId: 'movie-1'),
    );

    final ctx = LibraryProjectionContext<MovieWorkspaceDto>(
      source: source,
      dto: workspaceDto,
      node: const LibraryTitleNodeRef(titleItemId: 'movie-1'),
    );

    expect(MovieKindSchema.runtimeMinutes.getValue(ctx), 136);
    expect(MovieKindSchema.genre.getValue(ctx), 'Sci-Fi, Action');
    expect(MovieKindSchema.movieOrTvSeries.getValue(ctx), 'Movie');
    expect(MovieKindSchema.edition.getValue(ctx), '4K SteelBook');
    expect(MovieKindSchema.audioTracks.getValue(ctx), 'Dolby Atmos');
    expect(MovieKindSchema.editionReleaseDate.getValue(ctx),
        DateTime.utc(1999, 3, 31));
  });

  test('MovieCatalogMetadata and MovieReleaseMetadata roundtrip', () {
    final meta = MovieCatalogMetadata(
      title: 'The Matrix',
      originalTitle: 'The Matrix',
      sortTitle: 'Matrix, The',
      runtimeMinutes: 136,
      genres: const ['Sci-Fi', 'Action'],
      studio: 'Warner Bros.',
      country: 'US',
      originalLanguage: 'en',
      releaseDate: DateTime.utc(1999, 3, 31),
      directors: const [
        MoviePersonCredit(name: 'Lana Wachowski', role: 'Director'),
      ],
      cast: const [
        MoviePersonCredit(name: 'Keanu Reeves', character: 'Neo'),
      ],
    );

    final json = meta.toJson();
    final fromJson = MovieCatalogMetadata.fromJson(json);

    expect(fromJson.title, 'The Matrix');
    expect(fromJson.runtimeMinutes, 136);
    expect(fromJson.directors.first.name, 'Lana Wachowski');
    expect(fromJson.cast.first.character, 'Neo');

    final release = MovieReleaseMetadata(
      id: 'rel-1',
      title: '4K Collector Edition',
      physicalFormat: '4K UHD',
      region: 'Region Free',
      distributor: 'Warner Home Video',
      packaging: 'SteelBook',
      discCount: 2,
      edition: 'Special Edition',
      hdrFormats: const ['HDR10', 'Dolby Vision'],
      subtitles: const ['English', 'Spanish'],
      audioTracks: const ['Dolby Atmos'],
      releaseDate: DateTime.utc(2018, 5, 22),
    );

    final relJson = release.toJson();
    final relFromJson = MovieReleaseMetadata.fromJson(relJson);

    expect(relFromJson.title, '4K Collector Edition');
    expect(relFromJson.packaging, 'SteelBook');
    expect(relFromJson.hdrFormats, contains('Dolby Vision'));
    expect(relFromJson.discCount, 2);
  });

  test('MovieKindModule uses Movie-owned capabilities', () {
    expect(movieKindModule.kind, CatalogMediaKind.movie);
    expect(movieKindModule.add.kind, CatalogMediaKind.movie);
    expect(movieKindModule.add.createInitialDraft(), isA<MovieAddDraft>());
    expect(const MovieOwnedDetailsCodec(), isA<MovieOwnedDetailsCodec>());
    expect(const MovieOwnedDetailsCodec().defaultDetails(),
        isA<MovieOwnedDetails>());
  });
}
