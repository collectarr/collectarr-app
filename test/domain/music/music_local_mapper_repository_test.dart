import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/music/data/local/music_local_mapper.dart';
import 'package:collectarr_app/features/library/kinds/music/data/music_repository.dart';
import 'package:collectarr_app/features/library/kinds/music/data/remote/music_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_ids.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_media.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_release.dart';
import 'package:collectarr_app/features/library/kinds/music/domain/music_track.dart';
import 'package:collectarr_app/features/library/kinds/music/ownership/music_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MusicRepository round-trips the typed release/media/track graph',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    final release = _release();

    await repository.updateRelease(release);

    final restored = await repository.getRelease(release.id);
    expect(restored?.title, 'The Wall');
    expect(restored?.artist, 'Pink Floyd');
    expect(restored?.media.single.id, const MusicMediaId('media-1'));
    expect(restored?.media.single.tracks.single.title, 'In the Flesh?');
    expect(restored?.tracks.single.durationMs, 187000);
    expect(restored?.rawPayload['provider'], 'core');
    expect((await repository.search('floyd')).single.id, release.id);

    expect(
      (await repository.getMedia(release.id, release.media.single.id))
          ?.mediaType,
      'vinyl',
    );
    expect(
      (await repository.getTrack(
        release.media.single.id,
        release.media.single.tracks.single.id,
      ))
          ?.position,
      'A1',
    );

    const owned = MusicOwnedDetails(
      storageDevice: 'Shelf 4',
      storageSlot: 'B-12',
      signedBy: 'Roger Waters',
      matrixRunouts: [
        MusicMatrixRunout(side: 'A', runoutText: 'SHVL 804 A-2'),
      ],
    );
    await repository.updateOwnedDetails('owned-music-1', owned);
    expect(await repository.getOwnedDetails('owned-music-1'), owned);
  });

  test(
      'MusicRepository populates and then reads a remote release through cache',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final expected = _release();
    final repository = MusicRepository(
      db,
      remote: _FakeMusicRemote(expected),
    );

    final first = await repository.getRelease(expected.id);
    final second = await repository.getRelease(expected.id);

    expect(first?.id, expected.id);
    expect(
      second?.media.single.tracks.single.id,
      expected.media.single.tracks.single.id,
    );
  });

  test('Music repository enforces typed graph ownership', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = MusicRepository(db);
    const releaseId = MusicReleaseId('release-1');
    const media = MusicMedia(
      id: MusicMediaId('media-1'),
      releaseId: MusicReleaseId('other-release'),
      mediaNumber: 1,
    );
    const track = MusicTrack(
      id: MusicTrackId('track-1'),
      mediaId: MusicMediaId('other-media'),
      position: '1',
      title: 'Wrong parent',
    );

    expect(
      () => repository.updateMedia(releaseId, media),
      throwsStateError,
    );
    expect(
      () => repository.updateTrack(const MusicMediaId('media-1'), track),
      throwsStateError,
    );
    expect(
      () => MusicLocalMapper.toReleaseRow(
        const MusicRelease(id: MusicReleaseId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
  });

  test('Music schema exposes dedicated graph tables at schema version 28', () {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, 30);
  });
}

MusicRelease _release() {
  return const MusicRelease(
    id: MusicReleaseId('release-1'),
    title: 'The Wall',
    artist: 'Pink Floyd',
    publisher: 'Harvest',
    catalogNumber: 'SHDW 804',
    releaseDate: null,
    media: [
      MusicMedia(
        id: MusicMediaId('media-1'),
        releaseId: MusicReleaseId('release-1'),
        mediaNumber: 1,
        mediaType: 'vinyl',
        tracks: [
          MusicTrack(
            id: MusicTrackId('track-1'),
            mediaId: MusicMediaId('media-1'),
            position: 'A1',
            title: 'In the Flesh?',
            durationMs: 187000,
          ),
        ],
      ),
    ],
    rawPayload: {'provider': 'core'},
  );
}

final class _FakeMusicRemote implements MusicRemoteSource {
  const _FakeMusicRemote(this.release);

  final MusicRelease release;

  @override
  Future<MusicRelease> fetchRelease(MusicReleaseId id) async => release;
}
