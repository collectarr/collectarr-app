import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_metadata.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_release.dart';
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

  test('stores Comic Catalog Items in the shared cache for offline reads',
      () async {
    const media = ComicMedia(
      id: ComicMediaId('comic-1'),
      title: 'Saga #1',
      sortTitle: 'Saga #001',
      seriesTitle: 'Saga',
      issueNumber: '1',
      barcode: '123456789',
    );

    await repository.updateMedia(media);

    final cached = await CatalogItemCacheRepository(db).find(
      const CatalogItemRef(kind: CatalogMediaKind.comic, id: 'comic-1'),
    );
    final loaded = await repository.getMedia(media.id!);

    expect(cached, isNotNull);
    expect(cached!.title, 'Saga #1');
    expect(loaded?.id, media.id);
    expect(loaded?.issueNumber, '1');
    expect(loaded?.barcode, '123456789');
  });

  test('searches cached items and orders results deterministically', () async {
    await repository.updateMedia(
      const ComicMedia(
        id: ComicMediaId('comic-2'),
        title: 'Batman #2',
        sortTitle: 'Batman #002',
        seriesTitle: 'Batman',
      ),
    );
    await repository.updateMedia(
      const ComicMedia(
        id: ComicMediaId('comic-1'),
        title: 'Saga #1',
        sortTitle: 'Saga #001',
        seriesTitle: 'Saga',
      ),
    );

    expect(
      (await repository.search()).map((item) => item.id?.value),
      ['comic-2', 'comic-1'],
    );
    expect(
      (await repository.search('saga')).map((item) => item.title),
      ['Saga #1'],
    );
  });

  test('updates contained issue details on the catalog item', () async {
    await repository.updateMedia(
      const ComicMedia(id: ComicMediaId('comic-3'), title: 'Saga #3'),
    );

    await repository.updateRelease(
      const ComicMediaId('comic-3'),
      const ComicRelease(id: 'printing-1', title: 'First printing'),
    );

    expect(
      (await repository.getRelease(
        const ComicMediaId('comic-3'),
        const ComicReleaseId('printing-1'),
      ))
          ?.title,
      'First printing',
    );
  });

  test('returns null when a Catalog Item is not cached', () async {
    expect(
      await repository.getMedia(const ComicMediaId('missing')),
      isNull,
    );
    expect(
      () => repository.updateMedia(const ComicMedia(title: 'No id')),
      throwsStateError,
    );
  });

  test('cache transport retains Comic kind identity', () async {
    final dto = CatalogItemDto.fromJson({
      'kind': 'comic',
      'id': 'comic-4',
      'title': 'Daredevil #1',
      'issue_number': '1',
    });
    await CatalogItemCacheRepository(db).upsert(dto);

    expect(
      (await repository.getMedia(const ComicMediaId('comic-4')))?.title,
      'Daredevil #1',
    );
  });
}
