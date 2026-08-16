import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/library/kinds/movie/movie_domain.dart';
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

    final work = VideoCatalogItem.fromDto(dto);

    expect(work.title, 'The Matrix');
    expect(work.releases, hasLength(1));
    expect(work.releases.single.media, hasLength(1));
    expect(work.videoDetails.audioTracks, 'Dolby Atmos, DTS-HD MA 5.1');
    expect(work.releases.single.videoDetails?.nrDiscs, 1);
    expect(work.videoDetails.runtimeMinutes, 136);
    expect(work.trailerUrls, hasLength(1));
  });
}
