import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music release dto preserves media and tracks', () {
    final dto = MusicReleaseDto.fromJson({
      'id': 'music-1',
      'title': 'The Dark Side of the Moon',
      'subtitle': 'Pink Floyd',
      'release_type': 'album',
      'release_status': 'released',
      'release_date': '1973-03-01',
      'track_count': 1,
      'publisher': 'Harvest Records',
      'studio': 'Abbey Road',
      'catalog_number': 'SHVL 804',
      'barcode': '1234567890123',
      'country_code': 'GB',
      'language': 'en',
      'media': [
        {
          'id': 'media-1',
          'title': 'Disc 1',
          'media_number': 1,
          'media_type': 'album',
          'track_count': 1,
          'packaging': 'digipak',
          'tracks': [
            {
              'id': 'track-1',
              'title': 'Speak to Me',
              'position': '1',
              'duration_ms': 90000,
            }
          ],
        }
      ],
    });

    expect(dto.releaseType, 'album');
    expect(dto.releaseStatus, 'released');
    expect(dto.trackCount, 1);
    expect(dto.media, hasLength(1));
    expect(dto.media.first.tracks.first.title, 'Speak to Me');
  });
}
