import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/manga_repository.dart';
import 'package:collectarr_app/features/library/kinds/manga/data/remote/manga_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/manga/domain/manga_media.dart';
import 'package:collectarr_app/features/library/kinds/manga/ownership/manga_owned_details.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late MangaRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = MangaRepository(db);
  });

  tearDown(() => db.close());

  test('persists and retrieves typed Manga media', () async {
    const media = MangaMedia(
      id: 'manga-1',
      title: 'Vagabond',
      sortTitle: 'Vagabond',
    );

    await repository.updateMedia(media);
    final loaded = await repository.getMedia('manga-1');

    expect(loaded?.id, media.id);
    expect(loaded?.title, media.title);
    expect(loaded?.sortTitle, media.sortTitle);
  });

  test('searches typed Manga media deterministically', () async {
    await repository.updateMedia(
      const MangaMedia(id: 'manga-2', title: 'Batman: Manga Edition'),
    );
    await repository.updateMedia(
      const MangaMedia(
        id: 'manga-1',
        title: 'Vagabond',
        sortTitle: 'Vagabond',
      ),
    );

    expect(
      (await repository.search()).map((media) => media.id),
      ['manga-2', 'manga-1'],
    );
    expect(
      (await repository.search('gabon')).map((media) => media.title),
      ['Vagabond'],
    );
  });

  test('persists and retrieves Manga owned details', () async {
    const details = MangaOwnedDetails(
      obiStripPresent: true,
      localizedEdition: 'VIZ Media',
    );

    await repository.updateOwnedDetails('owned-1', details);
    final loaded = await repository.getOwnedDetails('owned-1');

    expect(loaded, details);
  });

  test('falls back to the typed remote source on a local miss', () async {
    final remote = _FakeMangaRemoteSource(
      (id) async => MangaMedia(id: id, title: 'Fetched Manga'),
    );
    final remoteRepository = MangaRepository(db, remote: remote);

    final loaded = await remoteRepository.getMedia('manga-remote');
    final cached = await repository.getMedia('manga-remote');

    expect(loaded?.title, 'Fetched Manga');
    expect(cached?.title, 'Fetched Manga');
    expect(remote.requestedIds, ['manga-remote']);
  });

  test('returns null for a missing media without a remote source', () async {
    expect(await repository.getMedia('missing'), isNull);
    expect(
      () => repository.updateMedia(const MangaMedia(id: '', title: 'Draft')),
      throwsStateError,
    );
  });
}

final class _FakeMangaRemoteSource implements MangaRemoteSource {
  _FakeMangaRemoteSource(this._fetch);

  final Future<MangaMedia> Function(String id) _fetch;
  final requestedIds = <String>[];

  @override
  Future<MangaMedia> fetchMedia(String id) {
    requestedIds.add(id);
    return _fetch(id);
  }
}
