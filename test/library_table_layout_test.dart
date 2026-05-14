import 'package:collectarr_app/features/library/workspace/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaults = {
    LibraryTableColumn.title,
    LibraryTableColumn.issue,
  };

  LibraryTableColumnSizing sizing(LibraryTableColumn column) {
    return switch (column) {
      LibraryTableColumn.title => const LibraryTableColumnSizing(
          defaultWidth: 200, minWidth: 100, maxWidth: 300),
      LibraryTableColumn.issue => const LibraryTableColumnSizing(
          defaultWidth: 80, minWidth: 50, maxWidth: 120),
      _ => const LibraryTableColumnSizing(
          defaultWidth: 60, minWidth: 40, maxWidth: 100),
    };
  }

  test('orders table columns with default fallback', () {
    expect(
      orderedLibraryTableColumns(columns: const {}, defaultColumns: defaults),
      [LibraryTableColumn.title, LibraryTableColumn.issue],
    );
  });

  test('reorders table columns before a target column', () {
    expect(
      reorderLibraryTableColumns(
        columns: const [
          LibraryTableColumn.title,
          LibraryTableColumn.issue,
          LibraryTableColumn.grade,
        ],
        column: LibraryTableColumn.grade,
        beforeColumn: LibraryTableColumn.issue,
      ),
      [
        LibraryTableColumn.title,
        LibraryTableColumn.grade,
        LibraryTableColumn.issue,
      ],
    );
  });

  test('reorders table columns to the end', () {
    expect(
      reorderLibraryTableColumns(
        columns: const [
          LibraryTableColumn.title,
          LibraryTableColumn.issue,
          LibraryTableColumn.grade,
        ],
        column: LibraryTableColumn.title,
        beforeColumn: null,
      ),
      [
        LibraryTableColumn.issue,
        LibraryTableColumn.grade,
        LibraryTableColumn.title,
      ],
    );
  });

  test('clamps custom table column widths', () {
    expect(
      libraryTableColumnWidth(
        column: LibraryTableColumn.title,
        customWidths: const {LibraryTableColumn.title: 500},
        sizing: sizing,
      ),
      300,
    );
  });

  test('computes table width with spacing and margins', () {
    final width = libraryTableWidthForColumns(
      columns: defaults,
      defaultColumns: defaults,
      customWidths: const {},
      sizing: sizing,
      columnSpacing: 10,
      horizontalMargin: 12,
    );

    expect(width, 314);
  });
}
