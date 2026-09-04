import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/game/data/game_repository.dart';
import 'package:collectarr_app/features/library/kinds/game/data/remote/game_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_ids.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_media.dart';
import 'package:collectarr_app/features/library/kinds/game/domain/game_release.dart';
import 'package:collectarr_app/features/library/kinds/game/ownership/game_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late GameRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = GameRepository(db);
  });

  tearDown(() => db.close());

  test('persists and retrieves typed Game media and releases', () async {
    const media = GameMedia(
      id: GameMediaId('game-1'),
      title: 'The Legend of Zelda: Breath of the Wild',
      sortTitle: 'Legend of Zelda: Breath of the Wild, The',
      releases: [
        GameRelease(
          id: 'release-1',
          title: 'Nintendo Switch Edition',
          workId: 'game-1',
          platform: 'Nintendo Switch',
        ),
      ],
    );

    await repository.updateMedia(media);
    final loaded = await repository.getMedia(const GameMediaId('game-1'));

    expect(loaded?.id, media.id);
    expect(loaded?.title, media.title);
    expect(loaded?.sortTitle, media.sortTitle);
    expect(loaded?.releases.single.typedId, const GameReleaseId('release-1'));
    expect(loaded?.releases.single.platform, 'Nintendo Switch');
    expect(
      await repository.getRelease(
        const GameMediaId('game-1'),
        const GameReleaseId('release-1'),
      ),
      isNotNull,
    );
    expect(
      (await repository.releasesFor(const GameMediaId('game-1'))).single.id,
      'release-1',
    );
  });

  test('searches typed Game media deterministically', () async {
    await repository.updateMedia(
      const GameMedia(
        id: GameMediaId('game-2'),
        title: 'Batman: Arkham City',
      ),
    );
    await repository.updateMedia(
      const GameMedia(
        id: GameMediaId('game-1'),
        title: 'Vagabond',
        sortTitle: 'Vagabond',
      ),
    );

    expect(
      (await repository.search()).map((media) => media.id),
      [const GameMediaId('game-2'), const GameMediaId('game-1')],
    );
    expect(
      (await repository.search('gabon')).map((media) => media.title),
      ['Vagabond'],
    );
  });

  test('persists and retrieves Game owned details', () async {
    const details = GameOwnedDetails(
      completeness: 'Complete in box',
      hasBox: true,
      hasManual: true,
      priceChartingId: 'pc-456',
      coreRegion: 'PAL',
      valueIsLocked: false,
    );

    await repository.updateOwnedDetails('owned-1', details);
    final loaded = await repository.getOwnedDetails('owned-1');

    expect(loaded, details);
  });

  test('falls back to the typed remote source on a local miss', () async {
    final remote = _FakeGameRemoteSource(
      (id) async => GameMedia(
        id: id,
        title: 'Fetched Game',
        releases: const [
          GameRelease(id: 'remote-release', title: 'Fetched Release'),
        ],
      ),
    );
    final remoteRepository = GameRepository(db, remote: remote);

    final loaded =
        await remoteRepository.getMedia(const GameMediaId('game-remote'));
    final cached = await repository.getMedia(const GameMediaId('game-remote'));

    expect(loaded?.title, 'Fetched Game');
    expect(cached?.title, 'Fetched Game');
    expect(cached?.releases.single.id, 'remote-release');
    expect(remote.requestedIds, [const GameMediaId('game-remote')]);
  });

  test('returns null for a missing media without a remote source', () async {
    expect(await repository.getMedia(const GameMediaId('missing')), isNull);
    expect(
      () => repository.updateMedia(
        const GameMedia(id: GameMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
  });
}

final class _FakeGameRemoteSource implements GameRemoteSource {
  _FakeGameRemoteSource(this._fetchMedia);

  final Future<GameMedia> Function(GameMediaId id) _fetchMedia;
  final requestedIds = <GameMediaId>[];

  @override
  Future<GameMedia> fetchMedia(GameMediaId id) {
    requestedIds.add(id);
    return _fetchMedia(id);
  }

  @override
  Future<GameRelease> fetchRelease(GameReleaseId id) {
    return Future.value(GameRelease(id: id.value, title: 'Fetched Release'));
  }
}
