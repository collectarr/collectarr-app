import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/mappers/movie_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('movie dto maps release graph into movie domain', () {
    final dto = MovieWorkDto.fromJson({
      'id': 'movie-1',
      'title': 'The Matrix',
      'description': 'A hacker discovers reality is a simulation.',
      'release_date': '1999-03-31T00:00:00Z',
      'runtime_minutes': 136,
      'age_rating': 'R',
      'audience_rating': '4.8',
      'original_language': 'en',
      'subtitle': 'Ultimate Edition',
      'cover_image_url': 'https://example.com/movie.jpg',
      'thumbnail_image_url': 'https://example.com/movie-thumb.jpg',
      'contributions': [
        {'name': 'Lana Wachowski', 'role': 'Director'},
      ],
      'character_appearances': [
        {'name': 'Neo'},
      ],
      'identifiers': [
        {'type': 'imdb', 'value': 'tt0133093'},
      ],
      'external_links': [
        {'url': 'https://www.imdb.com/title/tt0133093/'},
      ],
      'trailer_urls': [
        {'url': 'https://example.com/trailer.mp4', 'title': 'Trailer'},
      ],
      'releases': [
        {
          'id': 'release-1',
          'work_id': 'movie-1',
          'title': '4K UHD',
          'release_date': '2024-01-01T00:00:00Z',
          'country': 'US',
          'language': 'en',
          'barcode': '1234567890123',
          'format_label': '4K UHD',
          'publisher': 'Warner Bros.',
          'media': [
            {
              'id': 'media-1',
              'release_id': 'release-1',
              'title': 'Disc 1',
              'disc_number': 1,
              'sequence_number': 1,
              'format_label': '4K UHD',
              'features': ['HDR10'],
              'hdr': ['HDR10'],
              'audio_tracks': ['Dolby Atmos'],
              'subtitles': ['EN'],
              'screen_ratios': ['2.39:1'],
              'regions': ['A'],
            },
          ],
        },
      ],
      'kind': 'movie',
    });

    final work = movieWorkFromDto(dto);

    expect(work.title, 'The Matrix');
    expect(work.releases, hasLength(1));
    expect(work.releases.single.media, hasLength(1));
    expect(work.releases.single.media.single.audioTracks, ['Dolby Atmos']);
    expect(work.releases.single.videoDetails?.nrDiscs, 1);
    expect(work.videoDetails?.runtimeMinutes, 136);
    expect(work.trailerUrls, hasLength(1));
  });
}
