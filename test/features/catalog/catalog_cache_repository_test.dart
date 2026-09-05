import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/library/kinds/_shared/serial/authority/serial_authority_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_data_factories.dart';

void main() {
  late LocalDatabase db;
  late CatalogCacheRepository catalog;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalog = CatalogCacheRepository(db);
  });

  tearDown(() => db.close());

  test('upsertAll captures single-value catalog vocabulary and comic series',
      () async {
    await catalog.upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Department of Truth: Complete Conspiracy',
        physicalFormatLabel: 'Hardcover',
        publisher: 'Image Comics',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-1',
          seriesTitle: 'The Department of Truth',
        ),
        publishing: const CatalogPublishingDetailsDto(
          imprint: 'DSTLRY',
          seriesGroup: 'Deluxe Hardcovers',
        ),
      ),
    ]);

    final pickLists = PickListRepository(db);
    final seriesRegistry = SerialAuthorityRepository(db);

    expect(
      await pickLists.getValues(ComicVocabularyIds.publisher.value,
          mediaKind: 'comic'),
      contains('Image Comics'),
    );
    expect(
      await pickLists.getValues(ComicVocabularyIds.imprint.value,
          mediaKind: 'comic'),
      contains('DSTLRY'),
    );
    expect(
      await pickLists.getValues(ComicVocabularyIds.seriesGroup.value,
          mediaKind: 'comic'),
      contains('Deluxe Hardcovers'),
    );
    expect(
      await pickLists.getValues(ComicVocabularyIds.physicalFormat.value,
          mediaKind: 'comic'),
      contains('Hardcover'),
    );
    final listNames = await pickLists.listNames();
    expect(listNames, contains(ComicVocabularyIds.publisher.value));
    expect(listNames, contains(ComicVocabularyIds.imprint.value));
    expect(listNames, contains(ComicVocabularyIds.seriesGroup.value));
    expect(listNames, contains(ComicVocabularyIds.physicalFormat.value));
    expect(listNames, isNot(contains('publishers')));
    expect(listNames, isNot(contains('imprints')));
    expect(listNames, isNot(contains('series_groups')));
    expect(listNames, isNot(contains('physical_formats')));

    final series = await seriesRegistry.searchEntries(mediaKind: 'comic');
    expect(series, hasLength(1));
    expect(series.single.title, 'The Department of Truth');
    expect(series.single.coreSeriesId, 'series-1');
    expect(series.single.itemCount, 1);
  });

  test('upsertMetadataItems captures vocabulary from decoded metadata',
      () async {
    final item = testCatalogItem(
      id: 'comic-decoded-1',
      kind: 'comic',
      publisher: 'Image Comics',
      physicalFormatLabel: 'Hardcover',
    );

    await catalog.upsertMetadataItems([item]);

    final pickLists = PickListRepository(db);
    expect(
      await pickLists.getValues(
        ComicVocabularyIds.publisher.value,
        mediaKind: 'comic',
      ),
      contains('Image Comics'),
    );
    expect(
      await pickLists.getValues(
        ComicVocabularyIds.physicalFormat.value,
        mediaKind: 'comic',
      ),
      contains('Hardcover'),
    );
  });
}
