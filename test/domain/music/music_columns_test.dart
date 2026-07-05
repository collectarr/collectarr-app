import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/registry/planned_media_adapters.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('music workspace exposes album-specific columns', () {
    expect(
      plannedMediaTableColumnLabel(LibraryTableColumn.artist),
      'Artist',
    );
    expect(plannedMediaTableColumnLabel(LibraryTableColumn.album), 'Album');
    expect(
      plannedMediaTableColumnLabel(LibraryTableColumn.catalogNumber),
      'Catalog #',
    );
    expect(plannedMediaTableColumnLabel(LibraryTableColumn.discCount), 'Disc Count');
    expect(
      musicWorkspaceConfig.defaultVisibleColumns,
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
