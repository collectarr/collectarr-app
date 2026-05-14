import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';

class LibraryTableColumnSizing {
  const LibraryTableColumnSizing({
    required this.defaultWidth,
    required this.minWidth,
    required this.maxWidth,
  });

  final double defaultWidth;
  final double minWidth;
  final double maxWidth;
}

List<LibraryTableColumn> orderedLibraryTableColumns({
  required Set<LibraryTableColumn> columns,
  required Set<LibraryTableColumn> defaultColumns,
}) {
  final effective = columns.isEmpty ? defaultColumns : columns;
  return [
    for (final column in effective) column,
  ];
}

List<LibraryTableColumn> reorderLibraryTableColumns({
  required Iterable<LibraryTableColumn> columns,
  required LibraryTableColumn column,
  required LibraryTableColumn? beforeColumn,
}) {
  final ordered = columns.toList(growable: true);
  final currentIndex = ordered.indexOf(column);
  if (currentIndex == -1) {
    return ordered;
  }
  if (beforeColumn != null && beforeColumn == column) {
    return ordered;
  }
  final targetIndex =
      beforeColumn == null ? ordered.length : ordered.indexOf(beforeColumn);
  if (targetIndex == -1) {
    return ordered;
  }

  final movingColumn = ordered.removeAt(currentIndex);
  final insertIndex =
      beforeColumn == null ? ordered.length : ordered.indexOf(beforeColumn);
  ordered.insert(insertIndex, movingColumn);
  return ordered;
}

double libraryTableColumnWidth({
  required LibraryTableColumn column,
  required Map<LibraryTableColumn, double> customWidths,
  required LibraryTableColumnSizing Function(LibraryTableColumn column) sizing,
}) {
  final size = sizing(column);
  final customWidth = customWidths[column];
  if (customWidth != null) {
    return clampLibraryTableColumnWidth(customWidth, size);
  }
  return size.defaultWidth;
}

double clampLibraryTableColumnWidth(
  double width,
  LibraryTableColumnSizing sizing,
) {
  return width.clamp(sizing.minWidth, sizing.maxWidth).toDouble();
}

double libraryTableWidthForColumns({
  required Set<LibraryTableColumn> columns,
  required Set<LibraryTableColumn> defaultColumns,
  required Map<LibraryTableColumn, double> customWidths,
  required LibraryTableColumnSizing Function(LibraryTableColumn column) sizing,
  required double columnSpacing,
  required double horizontalMargin,
}) {
  final orderedColumns = orderedLibraryTableColumns(
    columns: columns,
    defaultColumns: defaultColumns,
  );
  final contentWidth = orderedColumns
      .map(
        (column) => libraryTableColumnWidth(
          column: column,
          customWidths: customWidths,
          sizing: sizing,
        ),
      )
      .fold<double>(0, (total, width) => total + width);
  final spacing = orderedColumns.isEmpty
      ? 0.0
      : (orderedColumns.length - 1) * columnSpacing;
  return contentWidth + spacing + (horizontalMargin * 2);
}
