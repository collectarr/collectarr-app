import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_module.dart';
import 'package:collectarr_app/features/library/kinds/movie/workspace/movie_workspace_projector.dart';
import 'package:collectarr_app/features/library/kinds/movie/catalog/movie_catalog_item.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_entity_ref.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Movie Catalog Item maps flat catalog fields and contained media', () {
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
      'runtime_minutes': 136,
      'audio_tracks': 'Dolby Atmos, DTS-HD MA 5.1',
      'trailer_urls': [
        {
          'id': 'tr-1',
          'url': 'https://youtube.com/watch?v=vKQi3bBA1y8',
          'title': 'Official Trailer',
        },
      ],
      'media': [
        {
          'id': 'disc-1',
          'media_number': 1,
          'media_type': '4K UHD',
          'num_discs': 1,
          'audio_tracks': 'Dolby Atmos',
          'subtitles': 'English, Spanish',
        },
      ],
      'kind': 'movie',
    });

    final item = MovieCatalogItem.fromDto(dto);

    expect(item.id, 'movie-1');
    expect(item.title, 'The Matrix');
    expect(item.barcode, '0883929317585');
    expect(item.physicalFormat, '4K UHD');
    expect(item.runtimeMinutes, 136);
    expect(item.audioTracks, 'Dolby Atmos, DTS-HD MA 5.1');
    expect(item.media, hasLength(1));
    expect(item.media.single.mediaNumber, 1);
    expect(item.media.single.formatLabel, '4K UHD');
    expect(item.media.single.numDiscs, 1);
    expect(item.trailerUrls, hasLength(1));
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

    final source = LibraryWorkspaceSource(
      itemId: 'movie-1',
      catalogData: testWorkspaceCatalogData(dto.asShelfCatalogItem),
    );

    final workspaceDto = const MovieWorkspaceProjector().project(
      source: source,
      entity: const LibraryCatalogItemNodeRef(catalogItemId: 'movie-1'),
    );

    final ctx = LibraryProjectionContext<MovieWorkspaceDto>(
      source: source,
      dto: workspaceDto,
      node: const LibraryCatalogItemNodeRef(catalogItemId: 'movie-1'),
    );

    expect(
        MovieCatalogIdentityWorkspaceFields.runtimeMinutes.getValue(ctx), 136);
    expect(MovieCatalogIdentityWorkspaceFields.genre.getValue(ctx),
        'Sci-Fi, Action');
    expect(MovieCatalogIdentityWorkspaceFields.movieOrTvSeries.getValue(ctx),
        'Movie');
    expect(MovieCatalogEditionWorkspaceFields.edition.getValue(ctx), isNull);
    expect(
        MovieCatalogEditionWorkspaceFields.audioTracks.getValue(ctx), isNull);
    expect(MovieCatalogEditionWorkspaceFields.editionReleaseDate.getValue(ctx),
        isNull);
  });

  test('MovieCatalogMetadata roundtrips concrete edition details', () {
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
      physicalFormat: '4K UHD',
      physicalFormatLabel: '4K UHD',
      region: 'Region Free',
      distributor: 'Warner Home Video',
      packaging: 'SteelBook',
      hdr: 'HDR10, Dolby Vision',
      nrDiscs: 2,
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
    expect(fromJson.physicalFormat, '4K UHD');
    expect(fromJson.region, 'Region Free');
    expect(fromJson.distributor, 'Warner Home Video');
    expect(fromJson.packaging, 'SteelBook');
    expect(fromJson.hdr, 'HDR10, Dolby Vision');
    expect(fromJson.nrDiscs, 2);
  });

  test('MovieKindRegistration uses Movie-entry capabilities', () {
    expect(movieKindIdentity.kind, CatalogMediaKind.movie);
    expect(movieKindAdd.kind, CatalogMediaKind.movie);
    expect(movieKindAdd.createInitialDraft(), isA<MovieAddDraft>());
    expect(const MovieEntryDetailsCodec(), isA<MovieEntryDetailsCodec>());
    expect(const MovieEntryDetailsCodec().defaultDetails(),
        isA<MovieEntryDetails>());
  });
}
