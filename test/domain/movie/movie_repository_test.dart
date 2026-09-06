import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/movie_repository.dart';
import 'package:collectarr_app/features/library/kinds/movie/data/remote/movie_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_ids.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_media.dart';
import 'package:collectarr_app/features/library/kinds/movie/domain/movie_release.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late MovieRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = MovieRepository(db);
  });

  tearDown(() => db.close());

  test('persists and retrieves typed Movie media and releases', () async {
    final media = MovieMedia(
      id: const MovieMediaId('movie-1'),
      title: 'The Matrix',
      sortTitle: 'Matrix, The',
      releases: const [
        MovieRelease(
          id: MovieReleaseId('release-1'),
          title: '4K Edition',
          workId: 'movie-1',
          format: '4K UHD',
          media: [
            MovieReleaseMedia(
              id: MovieReleaseMediaId('media-1'),
              releaseId: 'release-1',
              audioTracks: 'Dolby Atmos',
            ),
          ],
        ),
      ],
    );

    await repository.updateMedia(media);
    final loaded = await repository.getMedia(media.id);
    final release = await repository.getRelease(
      media.id,
      const MovieReleaseId('release-1'),
    );
    expect(loaded?.id, media.id);
    expect(loaded?.title, media.title);
    expect(loaded?.releases.single.title, '4K Edition');
    expect(loaded?.releases.single.media.single.audioTracks, 'Dolby Atmos');
    expect(release?.typedWorkId, media.id);
  });

  test('searches typed Movie media in deterministic order', () async {
    await repository.updateMedia(
      const MovieMedia(
        id: MovieMediaId('movie-2'),
        title: 'Zodiac',
        sortTitle: 'Zodiac',
      ),
    );
    await repository.updateMedia(
      const MovieMedia(
        id: MovieMediaId('movie-1'),
        title: 'The Matrix',
        sortTitle: 'Matrix, The',
      ),
    );

    expect(
      (await repository.search()).map((media) => media.id),
      [const MovieMediaId('movie-1'), const MovieMediaId('movie-2')],
    );
    expect((await repository.search('matrix')).single.title, 'The Matrix');
  });

  test('falls back to the typed remote source and caches the result', () async {
    final remote = _FakeMovieRemoteSource(
      (id) async => MovieMedia(id: id, title: 'Fetched Movie'),
    );
    final remoteRepository = MovieRepository(db, remote: remote);

    final loaded =
        await remoteRepository.getMedia(const MovieMediaId('movie-remote'));
    final cached =
        await repository.getMedia(const MovieMediaId('movie-remote'));

    expect(loaded?.title, 'Fetched Movie');
    expect(cached?.title, 'Fetched Movie');
    expect(remote.requestedIds, [const MovieMediaId('movie-remote')]);
  });

  test('returns null for a missing Movie without a remote source', () async {
    expect(await repository.getMedia(const MovieMediaId('missing')), isNull);
    expect(
      () => repository.updateMedia(
        const MovieMedia(id: MovieMediaId(''), title: 'Draft'),
      ),
      throwsStateError,
    );
  });
}

final class _FakeMovieRemoteSource implements MovieRemoteSource {
  _FakeMovieRemoteSource(this._fetch);

  final Future<MovieMedia> Function(MovieMediaId id) _fetch;
  final requestedIds = <MovieMediaId>[];

  @override
  Future<MovieMedia> fetchMedia(MovieMediaId id) {
    requestedIds.add(id);
    return _fetch(id);
  }
}
