import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_csv/manga_collection_csv_import_profile.dart';
import 'package:collectarr_app/features/library/kinds/manga/integrations/collection_csv/manga_collection_csv_projection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';

void main() {
  test('Manga import profile owns chapter and ISBN aliases', () {
    final profile = const MangaCollectionCsvImportProfile();
    final cells = profile.importCatalogCells(
      header: const [
        'Media Type',
        'Collectarr Item ID',
        'Series',
        'Chapter / Vol.',
        'Edition / Variant / Format',
        'Edition Title',
        'Physical Format',
        'Physical Format Label',
        'Publisher / Studio / Creator',
        'Release Date',
        'Barcode / UPC / ISBN',
      ],
      values: const [
        'Manga',
        'manga-1',
        'Berserk',
        '1',
        'Tankobon',
        'Volume 1',
        'tankobon',
        'Tankobon',
        'Hakusensha',
        '11/01/1990',
        '9784592132043',
      ],
    );

    expect(cells, [
      'manga-1',
      'Manga',
      'Berserk',
      '1',
      'Tankobon',
      'Volume 1',
      'tankobon',
      'Tankobon',
      'Hakusensha',
      '11/01/1990',
      '9784592132043',
    ]);
    expect(
      profile.importEntryCells(
        header: const ['Media Type'],
        values: const ['Manga'],
      ),
      everyElement(isEmpty),
    );
  });

  test('projects Manga catalog cells with volume semantics', () {
    final projection = const MangaCollectionCsvProjection();
    final entry = testLibraryWorkspaceSource(
      itemId: 'manga-1',
      catalogData: testWorkspaceCatalogData(
          testCatalogItemWithKindMetadata(testCatalogItem(
        id: 'manga-1',
        kind: 'manga',
        title: 'Berserk',
        editionTitle: 'Volume 1',
        physicalFormat: 'tankobon',
        physicalFormatLabel: 'Tankobon',
        publisher: 'Hakusensha',
        barcode: '9784592132043',
        payload: const {
          'volume_number': 1,
          'variant_name': 'Tankobon',
          'original_publication_date': '1990-11-01T00:00:00.000Z',
        },
      )).asShelfCatalogItem),
      libraryEntrySummary: testLibraryEntrySummary(testLibraryEntry(
        id: 'entry-1',
        itemId: 'manga-1',
        updatedAt: DateTime.utc(2026, 5, 15),
      )),
    );

    expect(projection.catalogCells(entry), [
      'manga-1',
      'manga',
      'Berserk',
      '1',
      'Tankobon',
      'Volume 1',
      'tankobon',
      'Tankobon',
      'Hakusensha',
      '1990-11-01',
      '9784592132043',
    ]);
    expect(
      projection.entryCellsBeforeLocation(entry, clzFriendly: false),
      isEmpty,
    );
    expect(
      projection.entryCellsAfterIndex(entry, clzFriendly: false),
      everyElement(isEmpty),
    );
  });
}
