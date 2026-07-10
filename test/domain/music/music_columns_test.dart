import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/shared/table/media_table_columns.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music workspace exposes album-specific columns', () {
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, LibraryTableColumn.artist),
      'Artist',
    );
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, LibraryTableColumn.frontCover),
      'Front Cover',
    );
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, LibraryTableColumn.backCover),
      'Back Cover',
    );
    expect(plannedMediaTableColumnLabelForType(musicLibraryConfig, LibraryTableColumn.album), 'Album');
    expect(
      plannedMediaTableColumnLabelForType(musicLibraryConfig, LibraryTableColumn.catalogNumber),
      'Catalog #',
    );
    expect(plannedMediaTableColumnLabelForType(musicLibraryConfig, LibraryTableColumn.discCount), 'Disc Count');
    expect(
      musicLibraryConfig.defaultVisibleColumns,
      containsAll([
        LibraryTableColumn.artist,
        LibraryTableColumn.album,
        LibraryTableColumn.label,
        LibraryTableColumn.catalogNumber,
        LibraryTableColumn.discCount,
        LibraryTableColumn.trackCount,
        LibraryTableColumn.length,
        LibraryTableColumn.vinylColor,
        LibraryTableColumn.rpm,
      ]),
    );
  });
}
