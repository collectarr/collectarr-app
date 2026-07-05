import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/missing_comics_report.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats comic issue ranges compactly', () {
    expect(formatComicIssueRanges([1, 2, 3, 5, 7, 8]), '#1-#3, #5, #7-#8');
  });

  test('builds missing comic series reports with variant grouping', () {
    final series = CatalogSeriesDetails(
      seriesId: 'series-1',
      seriesTitle: 'Amazing Spider-Man',
    );

    final owned = LibraryProjectionItem.fromShelf(
      testShelfEntry(
        itemId: 'issue-1',
        title: 'Amazing Spider-Man',
        catalogItem: testCatalogItem(
          id: 'issue-1',
          kind: 'comic',
          title: 'Amazing Spider-Man',
          itemNumber: '1',
          series: series,
        ),
        ownedItem: testOwnedItem(itemId: 'issue-1'),
      ),
      comicsLibraryConfig,
    );
    final variantA = LibraryProjectionItem.fromShelf(
      testShelfEntry(
        itemId: 'issue-2a',
        title: 'Amazing Spider-Man',
        catalogItem: testCatalogItem(
          id: 'issue-2a',
          kind: 'comic',
          title: 'Amazing Spider-Man',
          itemNumber: '2',
          variant: 'Variant A',
          series: series,
        ),
      ),
      comicsLibraryConfig,
    );
    final variantB = LibraryProjectionItem.fromShelf(
      testShelfEntry(
        itemId: 'issue-2b',
        title: 'Amazing Spider-Man',
        catalogItem: testCatalogItem(
          id: 'issue-2b',
          kind: 'comic',
          title: 'Amazing Spider-Man',
          itemNumber: '2',
          variant: 'Variant B',
          series: series,
        ),
      ),
      comicsLibraryConfig,
    );
    final unreleased = LibraryProjectionItem.fromShelf(
      testShelfEntry(
        itemId: 'issue-3',
        title: 'Amazing Spider-Man',
        catalogItem: testCatalogItem(
          id: 'issue-3',
          kind: 'comic',
          title: 'Amazing Spider-Man',
          itemNumber: '3',
          series: series,
          releaseDate: DateTime.utc(2027, 1, 1),
        ),
      ),
      comicsLibraryConfig,
    );

    final reports = buildMissingComicSeriesReports(
      [owned, variantA, variantB, unreleased],
      options: const MissingComicReportOptions(includeVariants: true),
      now: DateTime.utc(2026, 1, 1),
    );

    expect(reports, hasLength(1));
    expect(reports.single.seriesTitle, 'Amazing Spider-Man');
    expect(reports.single.missingIssueCount, 1);
    expect(reports.single.issueGroups.single.issueNumber, 2);
    expect(reports.single.issueGroups.single.variants, hasLength(2));
  });
}
