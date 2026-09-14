import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('canonical Core Music graph preserves release-group ownership', () {
    final group = MusicCoreMapper.fromReleaseGroupDto(
      MusicReleaseGroupDto.fromJson({
        'id': 'group-1',
        'kind': 'music',
        'title': 'The Wall',
        'artist': 'Pink Floyd',
        'genres': ['Rock'],
        'releases': [
          {
            'id': 'release-1',
            'release_group_id': 'group-1',
            'title': 'The Wall - First Pressing',
            'release_date': '1979-11-30',
          },
        ],
      }),
    );
    final release = MusicCoreMapper.fromReleaseDto(
      MusicReleaseDto.fromJson({
        'id': 'release-1',
        'kind': 'music',
        'release_group_id': 'group-1',
        'title': 'The Wall - First Pressing',
        'mediums': [
          {
            'id': 'medium-1',
            'release_id': 'release-1',
            'medium_number': 1,
            'medium_type': 'Vinyl',
            'tracks': [
              {
                'id': 'track-1',
                'medium_id': 'medium-1',
                'position': 'A1',
                'title': 'In the Flesh?',
              },
            ],
          },
        ],
      }),
    );

    expect(group.id.value, 'group-1');
    expect(group.artist, 'Pink Floyd');
    expect(group.primaryRelease!.id.value, 'release-1');
    expect(release.releaseGroupId, group.id);
    expect(release.mediums.single.releaseId, release.id);
    expect(release.mediums.single.tracks.single.mediumId,
        release.mediums.single.id);
  });

  test('MusicOwnedDetails supports matrix/runout, signature, and cleaning date',
      () {
    final details = MusicOwnedDetails(
      signedBy: 'David Gilmour',
      lastCleanedDate: DateTime.utc(2026, 7, 10),
      matrixRunouts: const [
        MusicMatrixRunout(
          mediumIndex: 1,
          side: 'A',
          runoutText: 'SHVL 804 A-2',
        ),
        MusicMatrixRunout(
          mediumIndex: 1,
          side: 'B',
          runoutText: 'SHVL 804 B-2',
        ),
      ],
    );

    final fromJson = MusicOwnedDetails.fromJson(details.toJson());
    expect(fromJson.signedBy, 'David Gilmour');
    expect(fromJson.lastCleanedDate, DateTime.utc(2026, 7, 10));
    expect(fromJson.matrixRunouts, hasLength(2));
    expect(fromJson.matrixRunouts.first.runoutText, 'SHVL 804 A-2');
    expect(fromJson.matrixRunouts.last.side, 'B');
    expect(fromJson, details);
  });

  test('ListeningSession and MusicListeningStats derive listening history', () {
    final sessions = [
      ListeningSession(
        id: 'session-1',
        releaseGroupId: 'group-1',
        releaseId: 'release-1',
        listenedAt: DateTime.utc(2026, 8, 1, 20),
        location: 'Living Room Hi-Fi',
        notes: 'Listened on turntable with headphones',
      ),
      ListeningSession(
        id: 'session-2',
        releaseGroupId: 'group-1',
        releaseId: 'release-1',
        listenedAt: DateTime.utc(2026, 8, 15, 21, 30),
      ),
    ];

    final stats = MusicListeningStats.fromSessions(sessions);
    expect(stats.listenCount, 2);
    expect(stats.lastListened, DateTime.utc(2026, 8, 15, 21, 30));
    expect(stats.history, hasLength(2));
    expect(stats.history.first.listenedAt, DateTime.utc(2026, 8, 15, 21, 30));
  });

  test('musicKindRegistration registers dedicated Music capabilities', () {
    expect(musicKindIdentity.kind, CatalogMediaKind.music);
    expect(musicKindAdd.kind, CatalogMediaKind.music);
    expect(musicKindAdd.createInitialDraft(), isA<MusicAddDraft>());
    expect(const MusicOwnedDetailsCodec(), isA<MusicOwnedDetailsCodec>());
    expect(const MusicOwnedDetailsCodec().defaultDetails(),
        isA<MusicOwnedDetails>());
  });
}
