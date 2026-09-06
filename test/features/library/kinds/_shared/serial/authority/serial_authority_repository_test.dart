import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_contributor.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase db;
  late LibraryCatalogRepository catalog;
  late SerialAuthorityRepository registry;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalog = LibraryCatalogRepository(db);
    registry = SerialAuthorityRepository(db);
  });

  tearDown(() => db.close());

  test('renameEntry updates matching catalog cache rows', () async {
    await catalog.upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Issue 1',
        series: const CatalogSeriesDetailsDto(
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
    final seriesMap = updated?.payload['series'] as Map?;
    expect(seriesMap?['series_title'], 'Renamed Series');
  });

  test(
      'mergeEntries moves catalog rows onto the target series and removes the source entry',
      () async {
    await catalog.upsertAll([
      testCatalogItem(
        id: 'comic-1',
        kind: 'comic',
        title: 'Issue 1',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-a',
          seriesTitle: 'Series A',
        ),
      ),
      testCatalogItem(
        id: 'comic-2',
        kind: 'comic',
        title: 'Issue 2',
        series: const CatalogSeriesDetailsDto(
          seriesId: 'series-b',
          seriesTitle: 'Series B',
        ),
      ),
    ]);

    final entries = await registry.searchEntries(mediaKind: 'comic');
    final target =
        entries.firstWhere((entry) => entry.coreSeriesId == 'series-a');
    final source =
        entries.firstWhere((entry) => entry.coreSeriesId == 'series-b');

    await registry.mergeEntries(
      targetEntryId: target.id,
      sourceEntryIds: [source.id],
    );

    final updated = await catalog.findById('comic-2');
    final updatedSeriesMap = updated?.payload['series'] as Map?;
    expect(updatedSeriesMap?['series_id'], 'series-a');
    expect(updatedSeriesMap?['series_title'], 'Series A');

    final refreshedEntries = await registry.searchEntries(mediaKind: 'comic');
    expect(
      refreshedEntries.where((entry) => entry.coreSeriesId == 'series-b'),
      isEmpty,
    );
  });

  test('stores kind-projected serial candidates without reading catalog maps',
      () async {
    await registry.captureCandidatesWithoutTransaction([
      const SerialAuthorityCandidate(
        mediaKind: CatalogMediaKind.comic,
        title: 'Batman',
      ),
    ]);

    final comicEntries = await registry.searchEntries(mediaKind: 'comic');
    final bookEntries = await registry.searchEntries(mediaKind: 'book');

    expect(comicEntries.single.title, 'Batman');
    expect(bookEntries, isEmpty);
  });
}
