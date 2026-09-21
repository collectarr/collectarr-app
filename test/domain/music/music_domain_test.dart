import 'package:collectarr_app/core/api/generated/collectarr_api.models.dart';
import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/library/kinds/music/music_domain.dart';
import 'package:collectarr_app/features/library/kinds/music/music_kind_components.dart';
import 'package:collectarr_app/features/library/domain/library_entity_scope.dart';
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

  test('Music track JSON preserves artist and structural headers', () {
    final track = MusicTrack(
      id: const MusicTrackId('header-child'),
      mediumId: const MusicMediumId('medium-1'),
      position: '2',
      title: 'Side A',
      artist: 'Pink Floyd',
      isHeader: true,
      indentLevel: 1,
      parentHeaderId: 'header-root',
    );

    final restored = MusicTrack.fromJson(track.toJson());
    expect(restored.artist, 'Pink Floyd');
    expect(restored.isHeader, isTrue);
    expect(restored.indentLevel, 1);
    expect(restored.parentHeaderId, 'header-root');
  });

  test('Music track counts exclude structural headers', () {
    final medium = MusicMedium(
      id: const MusicMediumId('medium-header-count'),
      releaseId: const MusicReleaseId('release-header-count'),
      mediumNumber: 1,
      trackCount: 3,
      tracks: [
        MusicTrack(
          id: const MusicTrackId('header'),
          mediumId: const MusicMediumId('medium-header-count'),
          position: '',
          title: 'Side A',
          isHeader: true,
        ),
        MusicTrack(
          id: const MusicTrackId('track-a'),
          mediumId: const MusicMediumId('medium-header-count'),
          position: 'A1',
          title: 'Track A',
        ),
        MusicTrack(
          id: const MusicTrackId('track-b'),
          mediumId: const MusicMediumId('medium-header-count'),
          position: 'A2',
          title: 'Track B',
        ),
      ],
    );

    expect(medium.effectiveTrackCount, 2);
  });

  test('MusicOwnedDetails supports matrix/runout, signature, and cleaning date',
      () {
    final details = MusicOwnedDetails(
      signedBy: 'David Gilmour',
      lastCleanedDate: DateTime.utc(2026, 7, 10),
      media: const [
        MusicOwnedMediumDetails(
          mediumIndex: 1,
          storageDevice: 'Turntable shelf',
          storageSlot: 'A-01',
          matrixRunouts: [
            MusicMatrixRunout(side: 'A', runoutText: 'SHVL 804 A-2'),
            MusicMatrixRunout(side: 'B', runoutText: 'SHVL 804 B-2'),
          ],
        ),
      ],
    );

    final fromJson = MusicOwnedDetails.fromJson(details.toJson());
    expect(fromJson.signedBy, 'David Gilmour');
    expect(fromJson.lastCleanedDate, DateTime.utc(2026, 7, 10));
    expect(fromJson.media, hasLength(1));
    expect(fromJson.media.single.matrixRunouts, hasLength(2));
    expect(
        fromJson.media.single.matrixRunouts.first.runoutText, 'SHVL 804 A-2');
    expect(fromJson.media.single.matrixRunouts.last.side, 'B');
    expect(fromJson.media.single.storageDevice, 'Turntable shelf');
    expect(fromJson.media.single.storageSlot, 'A-01');
    expect(fromJson, details);
  });

  test('MusicListenEvent and MusicListeningStats derive listening history', () {
    final sessions = [
      MusicListenEvent(
        id: 'session-1',
        releaseRef: const CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: CatalogEntityTypeId('release'),
          id: 'release-1',
          rootId: 'group-1',
        ),
        listenedAt: DateTime.utc(2026, 8, 1, 20),
        location: 'Living Room Hi-Fi',
        notes: 'Listened on turntable with headphones',
      ),
      MusicListenEvent(
        id: 'session-2',
        releaseRef: const CatalogEntityRef(
          kind: CatalogMediaKind.music,
          entityType: CatalogEntityTypeId('release'),
          id: 'release-1',
          rootId: 'group-1',
        ),
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
    expect(
      musicKindEditCapabilities.presentationCapability.editRegistry
          .builderForScope(LibraryEntityScope.release),
      isNotNull,
    );
    expect(const MusicOwnedDetailsCodec(), isA<MusicOwnedDetailsCodec>());
    expect(const MusicOwnedDetailsCodec().defaultDetails(),
        isA<MusicOwnedDetails>());
  });
}
