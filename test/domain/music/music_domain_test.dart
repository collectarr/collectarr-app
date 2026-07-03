import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/api/mappers/music_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music release dto maps to domain snapshot with media and tracks', () {
    final dto = MusicReleaseDto.fromJson({
      'id': 'music-1',
      'title': 'The Wall',
      'subtitle': 'Pink Floyd',
      'publisher': 'Harvest',
      'release_date': '1979-11-30T00:00:00Z',
      'recording_date': '1979-01-01T00:00:00Z',
      'release_status': 'released',
      'release_type': 'album',
      'sort_title': 'Wall, The',
      'studio': 'Abbey Road',
      'track_count': 2,
      'barcode': '1234567890',
      'cover_image_url': 'https://example.com/cover.jpg',
      'language': 'en',
      'country_code': 'GB',
      'extras': 'catalog-42',
      'genres': ['rock'],
      'contributions': [
        {'name': 'Pink Floyd', 'role': 'artist'},
      ],
      'media': [
        {
          'id': 'media-1',
          'title': 'Disc 1',
          'media_number': 1,
          'track_count': 2,
          'tracks': [
            {
              'id': 'track-1',
              'media_id': 'media-1',
              'position': '1',
              'title': 'Speak to Me',
              'duration_ms': 90000,
            },
          ],
        },
      ],
    });

    final release = musicReleaseFromDto(dto);

    expect(release.title, 'The Wall');
    expect(release.artist, 'Pink Floyd');
    expect(release.catalogNumber, 'catalog-42');
    expect(release.genres, ['rock']);
    expect(release.media, hasLength(1));
    expect(release.discs, hasLength(1));
    expect(release.tracks, hasLength(1));
    expect(release.tracks.first.title, 'Speak to Me');
  });
}
