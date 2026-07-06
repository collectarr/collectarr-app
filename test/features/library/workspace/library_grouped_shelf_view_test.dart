import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_media_presentation_models.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection.dart';
import 'package:collectarr_app/features/library/kinds/tv/presentation.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_shelf_entry.dart';
import 'package:collectarr_app/test/helpers/test_data_factories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tv defaults to series folder grid presentation', () {
    expect(tvDefaultWorkspaceGroupMode, LibraryGroupMode.series);
    expect(tvDefaultWorkspaceGroupPresentation, LibraryGroupPresentation.folderGrid);
    expect(tvDefaultVideoDisplayLevel, VideoDisplayLevel.season);
    expect(tvDefaultVideoGrouping, VideoGroupingDefault.bySeries);
    expect(tvLibraryGroupModes.first, LibraryGroupMode.series);
    expect(
      tvLibraryGroupModeDefinitions
          .firstWhere((definition) => definition.mode == LibraryGroupMode.series)
          .presentation,
      LibraryGroupPresentation.folderGrid,
    );
  });

  test('group shelf entries reuse grouped data for presentation', () {
    final catalog = testCatalogItem(
      id: 'tv-series-1',
      kind: 'tv',
      title: 'Example Show',
      series: const CatalogSeriesDetails(
        seriesTitle: 'Example Show',
      ),
    );
    final first = LibraryProjectionItem.fromShelf(
      testShelfEntry(
        itemId: 'tv-series-1',
        kind: 'tv',
        title: 'Example Show',
        catalogItem: catalog,
      ),
      tvLibraryConfig,
    );
    final second = LibraryProjectionItem.fromShelf(
      testShelfEntry(
        itemId: 'tv-series-2',
        kind: 'tv',
        title: 'Example Show',
        catalogItem: testCatalogItem(
          id: 'tv-series-2',
          kind: 'tv',
          title: 'Example Show',
          series: const CatalogSeriesDetails(seriesTitle: 'Example Show'),
        ),
      ),
      tvLibraryConfig,
    );

    final groups = libraryGroupEntriesForItems(
      [first, second],
      tvLibraryConfig,
      LibraryGroupMode.series,
    );

    expect(groups, hasLength(1));
    expect(groups.first.label, 'Example Show');
    expect(groups.first.presentation, LibraryGroupPresentation.folderGrid);
    expect(groups.first.count, 2);

    final folderEntry = FolderShelfEntry.fromGroup(groups.first);
    expect(folderEntry.bucket, 'Example Show');
    expect(folderEntry.count, 2);
    expect(folderEntry.presentation, LibraryGroupPresentation.folderGrid);
  });
}
