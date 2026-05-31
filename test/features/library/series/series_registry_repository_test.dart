import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/catalog/catalog_cache_repository.dart';
import 'package:collectarr_app/features/library/series/series_registry_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late CatalogCacheRepository catalog;
  late SeriesRegistryRepository registry;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalog = CatalogCacheRepository(db);
    registry = SeriesRegistryRepository(db);
  });

  tearDown(() => db.close());

  test('renameEntry updates matching catalog cache rows', () async {
    await catalog.upsertAll([
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Issue 1',
        series: const CatalogSeriesDetails(
          seriesId: 'series-1',
          seriesTitle: 'Original Series',
        ),
      ),
    ]);

    final entry = (await registry.searchEntries(mediaKind: 'comic')).single;
    await registry.renameEntry(
      entryId: entry.id,
      title: 'Renamed Series',
      sortTitle: 'Renamed Series',
    );

    final updated = await catalog.findById('comic-1');
    expect(updated?.series?.seriesTitle, 'Renamed Series');
  });

  test('mergeEntries moves catalog rows onto the target series and removes the source entry', () async {
    await catalog.upsertAll([
      CatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Issue 1',
        series: const CatalogSeriesDetails(
          seriesId: 'series-a',
          seriesTitle: 'Series A',
        ),
      ),
      CatalogItem(
        id: 'comic-2',
        kind: 'comic',
        title: 'Issue 2',
        series: const CatalogSeriesDetails(
          seriesId: 'series-b',
          seriesTitle: 'Series B',
        ),
      ),
    ]);

    final entries = await registry.searchEntries(mediaKind: 'comic');
    final target = entries.firstWhere((entry) => entry.coreSeriesId == 'series-a');
    final source = entries.firstWhere((entry) => entry.coreSeriesId == 'series-b');

    await registry.mergeEntries(
      targetEntryId: target.id,
      sourceEntryIds: [source.id],
    );

    final updated = await catalog.findById('comic-2');
    expect(updated?.series?.seriesId, 'series-a');
    expect(updated?.series?.seriesTitle, 'Series A');

    final refreshedEntries = await registry.searchEntries(mediaKind: 'comic');
    expect(
      refreshedEntries.where((entry) => entry.coreSeriesId == 'series-b'),
      isEmpty,
    );
  });

  test('captureCatalogItems uses config-driven title fallback for kinds that treat title as series', () async {
    await registry.captureCatalogItemsWithoutTransaction([
      CatalogItem(
        id: 'comic-untitled-series',
        kind: 'comic',
        title: 'Batman',
      ),
      CatalogItem(
        id: 'book-no-series',
        kind: 'book',
        title: 'The Hobbit',
      ),
    ]);

    final comicEntries = await registry.searchEntries(mediaKind: 'comic');
    final bookEntries = await registry.searchEntries(mediaKind: 'book');

    expect(comicEntries.single.title, 'Batman');
    expect(bookEntries, isEmpty);
  });
}