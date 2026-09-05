import 'package:collectarr_app/core/api/dto/catalog/catalog_variant_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/remote/comic_remote_source.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late ComicRepository repository;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    repository = ComicRepository(db);
  });

  tearDown(() => db.close());

  test('persists and assembles media with embedded releases', () async {
    const mediaId = ComicMediaId('comic-1');
    const release = ComicRelease(
      id: 'release-1',
      title: 'Saga #1',
      variants: [
        CatalogVariantDto(id: 'variant-1', name: 'Regular'),
      ],
    );
    const media = ComicMedia(
      id: mediaId,
      title: 'Saga',
      seriesTitle: 'Saga',
      releases: [release],
    );

    await repository.updateMedia(media);
    final loaded = await repository.getMedia(mediaId);

    expect(loaded?.id, mediaId);
    expect(loaded?.title, 'Saga');
    expect(loaded?.releases.single.id, release.id);
    expect(loaded?.releases.single.variants.single.id, 'variant-1');
  });

  test('searches typed Comic media and orders results deterministically',
      () async {
    await repository.updateMedia(
      const ComicMedia(
        id: ComicMediaId('comic-2'),
        title: 'Batman',
        sortTitle: 'Batman',
      ),
    );
    await repository.updateMedia(
      const ComicMedia(
        id: ComicMediaId('comic-1'),
        title: 'Saga',
        sortTitle: 'Saga',
      ),
    );

    expect(
      (await repository.search()).map((media) => media.id?.value),
      ['comic-2', 'comic-1'],
    );
    expect(
      (await repository.search('aga')).map((media) => media.title),
      ['Saga'],
    );
  });

  test('uses both parts of the composite key for release lookup', () async {
    await repository.updateRelease(
      const ComicMediaId('comic-1'),
      const ComicRelease(id: 'release-1', title: 'Saga #1'),
    );
    await repository.updateRelease(
      const ComicMediaId('comic-2'),
      const ComicRelease(id: 'release-1', title: 'Batman #1'),
    );

    expect(
      (await repository.getRelease(
        const ComicMediaId('comic-1'),
        const ComicReleaseId('release-1'),
      ))
          ?.title,
      'Saga #1',
    );
    expect(
      (await repository.releasesFor(const ComicMediaId('comic-2')))
          .single
          .title,
      'Batman #1',
    );
  });

  test('upserts media and release values without erasing omitted releases',
      () async {
    const mediaId = ComicMediaId('comic-1');
    await repository.updateMedia(
      const ComicMedia(
        id: mediaId,
        title: 'Old title',
        releases: [ComicRelease(id: 'release-1', title: 'Saga #1')],
      ),
    );
    await repository.updateMedia(
      const ComicMedia(id: mediaId, title: 'New title'),
    );

    final loaded = await repository.getMedia(mediaId);
    expect(loaded?.title, 'New title');
    expect(loaded?.releases.single.title, 'Saga #1');
  });

  test('falls back to the typed remote source on a local miss', () async {
    final remote = _FakeComicRemoteSource(
      (id) async => ComicMedia(
        id: id,
        title: 'Fetched Comic',
        releases: const [ComicRelease(id: 'release-1', title: 'Fetched #1')],
      ),
    );
    final remoteRepository = ComicRepository(db, remote: remote);
    const mediaId = ComicMediaId('comic-remote');

    final loaded = await remoteRepository.getMedia(mediaId);
    final cached = await repository.getMedia(mediaId);

    expect(loaded?.title, 'Fetched Comic');
    expect(loaded?.releases.single.id, 'release-1');
    expect(cached?.title, 'Fetched Comic');
    expect(remote.requestedIds, [mediaId]);
  });

  test('returns null for a missing media without a remote source', () async {
    expect(
      await repository.getMedia(const ComicMediaId('missing')),
      isNull,
    );
    expect(
      () => repository.updateMedia(const ComicMedia(title: 'No id')),
      throwsStateError,
    );
  });
}

final class _FakeComicRemoteSource implements ComicRemoteSource {
  _FakeComicRemoteSource(this._fetch);

  final Future<ComicMedia> Function(ComicMediaId id) _fetch;
  final requestedIds = <ComicMediaId>[];

  @override
  Future<ComicMedia> fetchMedia(ComicMediaId id) {
    requestedIds.add(id);
    return _fetch(id);
  }
}
