import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/core/api/dto/catalog/catalog_item_dto.dart';
import 'package:collectarr_app/features/catalog/library_catalog_repository.dart';
import 'package:collectarr_app/features/collection/repositories/pick_list_repository.dart';
import 'package:collectarr_app/features/library/kinds/comic/vocabulary/comic_vocabularies.dart';
import 'package:collectarr_app/features/catalog/serial/serial_authority_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/data/tv_repository.dart';
import 'package:collectarr_app/features/library/kinds/tv/domain/tv_ids.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_data_factories.dart';

void main() {
  late LocalDatabase db;
  late LibraryCatalogRepository catalog;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    catalog = LibraryCatalogRepository(db);
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

  test('upsertAll preserves the complete typed TV graph payload', () async {
    await catalog.upsertAll([
      testCatalogItem(
        id: 'tv-graph-1',
        kind: 'tv',
        title: 'Typed Graph Fixture',
        payload: {
          'seasons': [
            {
              'id': 'tv-graph-1-season-1',
              'series_id': 'tv-graph-1',
              'season_number': 1,
              'title': 'Season One',
              'episodes': [
                {
                  'id': 'tv-graph-1-episode-1',
                  'series_id': 'tv-graph-1',
                  'season_id': 'tv-graph-1-season-1',
                  'season_number': 1,
                  'episode_number': 1,
                  'episode_title': 'Pilot',
                },
              ],
            },
          ],
        },
      ),
    ]);

    final seasons = await TvRepository(db).seasonsFor(
      const TvSeriesId('tv-graph-1'),
    );
    expect(seasons, hasLength(1));
    expect(seasons.single.id, 'tv-graph-1-season-1');
    expect(seasons.single.episodes, hasLength(1));
    expect(seasons.single.episodes.single.id, 'tv-graph-1-episode-1');
    expect(seasons.single.episodes.single.title, 'Pilot');
  });
}
