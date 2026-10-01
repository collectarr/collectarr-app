import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item_ref.dart';
import 'package:collectarr_app/features/catalog/transport/catalog_item_cache_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/comic_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_ids.dart';
import 'package:collectarr_app/features/library/kinds/comic/domain/comic_catalog_item.dart';
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
    const media = ComicCatalogItem(
      id: ComicCatalogItemId('comic-1'),
      title: 'Saga #1',
      sortTitle: 'Saga #001',
      seriesTitle: 'Saga',
      issueNumber: '1',
      barcode: '123456789',
    );

    await repository.updateCatalogItem(media);

    final cached = await CatalogItemCacheRepository(db).find(
      const CatalogItemRef(kind: CatalogMediaKind.comic, id: 'comic-1'),
    );
    final loaded = await repository.getCatalogItem(media.id!);

    expect(cached, isNotNull);
    expect(cached!.title, 'Saga #1');
    expect(loaded?.id, media.id);
    expect(loaded?.issueNumber, '1');
    expect(loaded?.barcode, '123456789');
  });

  test('searches cached items and orders results deterministically', () async {
    await repository.updateCatalogItem(
      const ComicCatalogItem(
        id: ComicCatalogItemId('comic-2'),
        title: 'Batman #2',
        sortTitle: 'Batman #002',
        seriesTitle: 'Batman',
      ),
    );
    await repository.updateCatalogItem(
      const ComicCatalogItem(
        id: ComicCatalogItemId('comic-1'),
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

  test('returns null when a Catalog Item is not cached', () async {
    expect(
      await repository.getCatalogItem(const ComicCatalogItemId('missing')),
      isNull,
    );
    expect(
      () => repository.updateCatalogItem(const ComicCatalogItem(title: 'No id')),
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
      (await repository.getCatalogItem(const ComicCatalogItemId('comic-4')))?.title,
      'Daredevil #1',
    );
  });
}
