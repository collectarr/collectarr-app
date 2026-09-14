import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/boardgame_repository.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/data/remote/boardgame_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_edition.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_ids.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/domain/boardgame_media.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('persists media and editions', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGameRepository(db);
    final media = BoardGameMedia(
      id: const BoardGameMediaId('boardgame-1'),
      title: 'Catan',
      sortTitle: 'Catan',
      editions: const [
        BoardGameEdition(
          id: 'edition-1',
          title: 'Catan Standard',
          workId: 'boardgame-1',
        ),
      ],
    );

    await repository.updateMedia(media);
    final restored = await repository.getMedia(media.id);
    final edition = await repository.getEdition(
      media.id,
      const BoardGameEditionId('edition-1'),
    );
    expect(restored?.title, 'Catan');
    expect(restored?.editions.single.title, 'Catan Standard');
    expect(edition?.workId, 'boardgame-1');
  });

  test('searches media in deterministic sort order', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGameRepository(db);

    await repository.updateMedia(
      const BoardGameMedia(
        id: BoardGameMediaId('z'),
        title: 'Zombicide',
        sortTitle: 'Zombicide',
      ),
    );
    await repository.updateMedia(
      const BoardGameMedia(
        id: BoardGameMediaId('a'),
        title: 'Azul',
        sortTitle: 'Azul',
      ),
    );

    final results = await repository.search('');

    expect(results.map((item) => item.id.value), ['a', 'z']);
    expect((await repository.search('zomb')).single.title, 'Zombicide');
  });

  test('falls back to remote media and caches the result', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final remote = _FakeBoardGameRemoteSource(
      BoardGameMedia(
        id: const BoardGameMediaId('remote-1'),
        title: 'Ticket to Ride',
      ),
    );
    final repository = BoardGameRepository(db, remote: remote);

    final restored =
        await repository.getMedia(const BoardGameMediaId('remote-1'));
    final cached =
        await repository.getMedia(const BoardGameMediaId('remote-1'));

    expect(restored?.title, 'Ticket to Ride');
    expect(cached?.title, 'Ticket to Ride');
    expect(remote.mediaFetchCount, 1);
  });

  test('returns null for missing media without a remote source', () async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = BoardGameRepository(db);

    expect(
      await repository.getMedia(const BoardGameMediaId('missing')),
      isNull,
    );
  });
}

final class _FakeBoardGameRemoteSource implements BoardGameRemoteSource {
  _FakeBoardGameRemoteSource(this.media);

  final BoardGameMedia media;
  var mediaFetchCount = 0;

  @override
  Future<BoardGameMedia> fetchMedia(BoardGameMediaId id) async {
    mediaFetchCount++;
    return media;
  }

  @override
  Future<BoardGameEdition> fetchEdition(BoardGameEditionId id) async {
    return BoardGameEdition(id: id.value, title: 'Remote edition');
  }
}
