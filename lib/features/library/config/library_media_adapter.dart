import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

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
typedef LibraryTableCellBuilder = Widget Function(
  LibraryWorkspaceEntry entry,
  LibraryTableColumn column,
);
typedef LibraryEntryColumnComparator = int Function(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
);
typedef LibraryEntryFilterValuesBuilder = LibraryEntryFilterValues Function(
  LibraryWorkspaceEntry entry,
);
typedef LibraryEntryLinkedMetadataCandidatesBuilder = Iterable<String> Function(
  LibraryWorkspaceEntry entry,
);
typedef LibraryEntrySubgroupKeyBuilder = String? Function(
  LibraryWorkspaceEntry entry,
  LibraryGroupMode groupMode,
);
typedef LibraryEntrySubgroupKeyComparator = int Function(
  String left,
  String right,
  LibraryGroupMode groupMode,
);

class LibraryEntryFilterValues {
  const LibraryEntryFilterValues({
    this.series,
    this.country,
    this.language,
  });

  final String? series;
  final String? country;
  final String? language;
}

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
    required this.tableCellBuilder,
    required this.compareEntriesByColumn,
    required this.entryFilterValuesBuilder,
    required this.entryLinkedMetadataCandidatesBuilder,
    required this.entrySubgroupKeyBuilder,
    required this.compareSubgroupKeys,
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
  final LibraryTableCellBuilder tableCellBuilder;
  final LibraryEntryColumnComparator compareEntriesByColumn;
  final LibraryEntryFilterValuesBuilder entryFilterValuesBuilder;
  final LibraryEntryLinkedMetadataCandidatesBuilder
      entryLinkedMetadataCandidatesBuilder;
  final LibraryEntrySubgroupKeyBuilder entrySubgroupKeyBuilder;
  final LibraryEntrySubgroupKeyComparator compareSubgroupKeys;

  Set<LibraryTableColumn> defaultTableColumns() {
    return Set.of(type.workspace.defaultVisibleColumns);
  }

  Widget buildTableCell(LibraryWorkspaceEntry entry, LibraryTableColumn column) {
    return tableCellBuilder(entry, column);
  }

  LibraryEntryFilterValues filterValuesForEntry(LibraryWorkspaceEntry entry) {
    return entryFilterValuesBuilder(entry);
  }

  Iterable<String> linkedMetadataCandidatesForEntry(
    LibraryWorkspaceEntry entry,
  ) {
    return entryLinkedMetadataCandidatesBuilder(entry);
  }

  String? subgroupKeyForEntry(
    LibraryWorkspaceEntry entry,
    LibraryGroupMode groupMode,
  ) {
    return entrySubgroupKeyBuilder(entry, groupMode);
  }

  int compareEntriesByRules(
    LibraryWorkspaceEntry left,
    LibraryWorkspaceEntry right,
    Iterable<LibrarySortRule> rules,
  ) {
    for (final rule in rules) {
      final result = compareEntriesByColumn(left, right, rule.column);
      if (result != 0) {
        return rule.ascending ? result : -result;
      }
    }
    return left.resolvedTitle.toLowerCase().compareTo(
          right.resolvedTitle.toLowerCase(),
        );
  }
}

class LibraryMediaAdapterRegistry {
  const LibraryMediaAdapterRegistry(this.adapters);

  final List<LibraryMediaAdapter> adapters;

  LibraryMediaAdapter? byKind(Object? kind) {
    final normalized = catalogMediaKindFromValue(kind);
    for (final adapter in adapters) {
      if (adapter.type.workspace.kind == normalized) {
        return adapter;
      }
    }
    return null;
  }

  List<String> get supportedKinds {
    return {
      for (final adapter in adapters) adapter.type.workspace.kind.apiValue,
    }.toList(growable: false);
  }
}
