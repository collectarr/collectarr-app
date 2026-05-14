import 'package:collectarr_app/features/library/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';

typedef LibraryTableColumnOrdering = List<LibraryTableColumn> Function(
  Set<LibraryTableColumn> columns,
);
typedef LibraryTableWidthForColumns = double Function(
  Set<LibraryTableColumn> columns,
  Map<LibraryTableColumn, double> customWidths,
);
typedef LibraryTableColumnWidthForCustomWidths = double Function(
  LibraryTableColumn column,
  Map<LibraryTableColumn, double> customWidths,
);
typedef LibraryTableColumnDefaultWidthFor = double Function(
  LibraryTableColumn column,
);
typedef LibraryTableColumnLabelFor = String Function(LibraryTableColumn column);
typedef LibraryTableColumnGroupFor = LibraryTableColumnGroup Function(
  LibraryTableColumn column,
);
typedef LibraryTableColumnGroupLabelFor = String Function(
  LibraryTableColumnGroup group,
);
typedef LibraryTableColumnNumericFor = bool Function(
  LibraryTableColumn column,
);
typedef LibraryTableColumnSortFor = LibrarySortColumn? Function(
  LibraryTableColumn column,
);

class LibraryMediaAdapter {
  const LibraryMediaAdapter({
    required this.type,
    required this.viewProfile,
    required this.orderedTableColumns,
    required this.tableWidthForColumns,
    required this.tableColumnWidth,
    required this.defaultTableColumnWidth,
    required this.columnLabel,
    required this.columnDisplayName,
    required this.columnGroup,
    required this.columnGroupLabel,
    required this.columnIsNumeric,
    required this.columnSort,
  });

  final LibraryTypeConfig type;
  final LibraryWorkspaceViewProfile viewProfile;
  final LibraryTableColumnOrdering orderedTableColumns;
  final LibraryTableWidthForColumns tableWidthForColumns;
  final LibraryTableColumnWidthForCustomWidths tableColumnWidth;
  final LibraryTableColumnDefaultWidthFor defaultTableColumnWidth;
  final LibraryTableColumnLabelFor columnLabel;
  final LibraryTableColumnLabelFor columnDisplayName;
  final LibraryTableColumnGroupFor columnGroup;
  final LibraryTableColumnGroupLabelFor columnGroupLabel;
  final LibraryTableColumnNumericFor columnIsNumeric;
  final LibraryTableColumnSortFor columnSort;

  Set<LibraryTableColumn> defaultTableColumns() {
    return Set.of(type.workspace.defaultVisibleColumns);
  }
}
