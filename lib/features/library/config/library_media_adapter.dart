import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

typedef LibraryTableColumnOrdering = List<String> Function(
  Set<String> columns,
);
typedef LibraryTableWidthForColumns = double Function(
  Set<String> columns,
  Map<String, double> customWidths,
);
typedef LibraryTableColumnWidthForCustomWidths = double Function(
  String column,
  Map<String, double> customWidths,
);
typedef LibraryTableColumnDefaultWidthFor = double Function(
  String column,
);
typedef LibraryTableColumnLabelFor = String Function(String column);
typedef LibraryTableColumnGroupFor = LibraryTableColumnGroup Function(
  String column,
);
typedef LibraryTableColumnGroupLabelFor = String Function(
  LibraryTableColumnGroup group,
);
typedef LibraryTableColumnNumericFor = bool Function(
  String column,
);
typedef LibraryTableColumnSortFor = String? Function(
  String column,
);
typedef LibraryTableCellBuilder = Widget Function(
  LibraryWorkspaceEntry entry,
  String column,
);
typedef LibraryWorkspaceCardBuilder = Widget Function(
  BuildContext context,
  LibraryWorkspaceEntry entry,
  Widget child,
);
typedef LibraryEntryColumnComparator = int Function(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  String column,
);
typedef LibraryEntryFilterValuesBuilder = LibraryEntryFilterValues Function(
  LibraryWorkspaceEntry entry,
);
typedef LibraryEntryLinkedMetadataCandidatesBuilder = Iterable<String> Function(
  LibraryWorkspaceEntry entry,
);
typedef LibraryEntrySubgroupKeyBuilder = String? Function(
  LibraryWorkspaceEntry entry,
  String groupMode,
);
typedef LibraryEntrySubgroupKeyComparator = int Function(
  String left,
  String right,
  String groupMode,
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
    this.workspaceCardBuilder,
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
  final LibraryWorkspaceCardBuilder? workspaceCardBuilder;

  Set<String> defaultTableColumns() {
    return Set.of(libraryKindModuleForType(type).fields.defaultVisibleColumnIds);
  }

  Widget buildTableCell(LibraryWorkspaceEntry entry, String column) {
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
    String groupMode,
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

  LibraryMediaAdapter? byKind(CatalogMediaKind kind) {
    for (final adapter in adapters) {
      if (adapter.type.workspace.kind == kind) {
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
