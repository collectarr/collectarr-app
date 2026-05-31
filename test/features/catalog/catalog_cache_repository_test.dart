import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/collection/pick_list/pick_list_options.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late CatalogCacheRepository catalog;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalog = CatalogCacheRepository(db);
  });

  tearDown(() => db.close());

  test('upsertAll captures single-value catalog vocabulary and comic series', () async {
    await catalog.upsertAll([
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'The Department of Truth: Complete Conspiracy',
        physicalFormatLabel: 'Hardcover',
        publisher: 'Image Comics',
        series: const CatalogSeriesDetails(
          seriesId: 'series-1',
          seriesTitle: 'The Department of Truth',
        ),
        publishing: const CatalogPublishingDetails(
          imprint: 'DSTLRY',
          seriesGroup: 'Deluxe Hardcovers',
        ),
      ),
    ]);

    final pickLists = PickListRepository(db);
    final seriesRegistry = SeriesRegistryRepository(db);

    expect(
      await pickLists.getValues(kPublisherPickListName, mediaKind: 'comic'),
      contains('Image Comics'),
    );
    expect(
      await pickLists.getValues(kImprintPickListName, mediaKind: 'comic'),
      contains('DSTLRY'),
    );
    expect(
      await pickLists.getValues(kSeriesGroupPickListName, mediaKind: 'comic'),
      contains('Deluxe Hardcovers'),
    );
    expect(
      await pickLists.getValues(kPhysicalFormatPickListName, mediaKind: 'comic'),
      contains('Hardcover'),
    );

    final series = await seriesRegistry.searchEntries(mediaKind: 'comic');
    expect(series, hasLength(1));
    expect(series.single.title, 'The Department of Truth');
    expect(series.single.coreSeriesId, 'series-1');
    expect(series.single.itemCount, 1);
  });
}