import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaults = {
    'title',
    'issue',
  };

  LibraryTableColumnSizing sizing(Object column) {
    if (column is! String) {
      return const LibraryTableColumnSizing(
          defaultWidth: 60, minWidth: 40, maxWidth: 100);
    }
    return switch (column) {
      'title' => const LibraryTableColumnSizing(
          defaultWidth: 200, minWidth: 100, maxWidth: 300),
      'issue' => const LibraryTableColumnSizing(
          defaultWidth: 80, minWidth: 50, maxWidth: 120),
      _ => const LibraryTableColumnSizing(
          defaultWidth: 60, minWidth: 40, maxWidth: 100),
    };
  }

  test('orders table columns with default fallback', () {
    expect(
      orderedLibraryTableColumns(columns: const {}, defaultColumns: defaults),
      ['title', 'issue'],
    );
  });

  test('reorders table columns before a target column', () {
    expect(
      reorderLibraryTableColumns(
        columns: const [
          'title',
          'issue',
          'grade',
        ],
        column: 'grade',
        beforeColumn: 'issue',
      ),
      [
        'title',
        'grade',
        'issue',
      ],
    );
  });

  test('reorders table columns to the end', () {
    expect(
      reorderLibraryTableColumns(
        columns: const [
          'title',
          'issue',
          'grade',
        ],
        column: 'title',
        beforeColumn: null,
      ),
      [
        'issue',
        'grade',
        'title',
      ],
    );
  });

  test('clamps custom table column widths', () {
    expect(
      libraryTableColumnWidth(
        column: 'title',
        customWidths: const {'title': 500},
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
