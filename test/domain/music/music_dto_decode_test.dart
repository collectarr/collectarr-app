import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Music Core DTOs preserve release, medium, and track fields', () {
    final dto = MusicReleaseDto.fromJson({
      'id': 'release-1',
      'release_group_id': 'group-1',
      'kind': 'music',
      'title': 'The Dark Side of the Moon',
      'release_type': 'Album',
      'release_status': 'Official',
      'release_date': '1973-03-01',
      'publisher': 'Harvest Records',
      'catalog_number': 'SHVL 804',
      'barcode': '1234567890123',
      'country_code': 'GB',
      'language': 'en',
      'mediums': [
        {
          'id': 'medium-1',
          'release_id': 'release-1',
          'medium_number': 1,
          'medium_type': 'Vinyl',
          'track_count': 1,
          'tracks': [
            {
              'id': 'track-1',
              'medium_id': 'medium-1',
              'position': '1',
              'title': 'Speak to Me',
              'duration_ms': 90000,
            },
          ],
        },
      ],
    });

    expect(dto.releaseGroupId, 'group-1');
    expect(dto.releaseType, 'Album');
    expect(dto.releaseStatus, 'Official');
    expect(dto.mediums, hasLength(1));
    expect(dto.mediums.single.releaseId, 'release-1');
    expect(dto.mediums.single.mediumType, 'Vinyl');
    expect(dto.mediums.single.trackCount, 1);
    expect(dto.mediums.single.tracks.single.mediumId, 'medium-1');
    expect(dto.mediums.single.tracks.single.title, 'Speak to Me');
    expect(dto.mediums.single.tracks.single.durationMs, 90000);
  });

  test('Music release-group DTO contains only group-level fields', () {
    final dto = MusicReleaseGroupDto.fromJson({
      'id': 'group-1',
      'kind': 'music',
      'title': 'The Dark Side of the Moon',
      'artist': 'Pink Floyd',
      'original_release_date': '1973-03-01',
      'genres': ['Rock'],
      'releases': <Map<String, dynamic>>[],
    });

    expect(dto.id, 'group-1');
    expect(dto.artist, 'Pink Floyd');
    expect(dto.releaseDate, DateTime(1973, 3, 1));
    expect(dto.releases, isEmpty);
  });
}
