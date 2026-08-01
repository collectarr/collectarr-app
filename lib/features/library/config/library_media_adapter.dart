import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
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
  LibraryProjectionRuntime item,
  String column,
);
typedef LibraryWorkspaceCardBuilder = Widget Function(
  BuildContext context,
  LibraryProjectionRuntime item,
  Widget child,
);
typedef LibraryEntryColumnComparator = int Function(
  LibraryProjectionRuntime left,
  LibraryProjectionRuntime right,
  String column,
);
typedef LibraryEntryFilterValuesBuilder = LibraryEntryFilterValues Function(
  ShelfEntry source,
);
typedef LibraryEntryLinkedMetadataCandidatesBuilder = Iterable<String> Function(
  ShelfEntry source,
);
typedef LibraryEntrySubgroupKeyBuilder = String? Function(
  LibraryProjectionRuntime item,
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

  Widget buildTableCell(LibraryProjectionRuntime item, String column) {
    return tableCellBuilder(item, column);
  }

  LibraryEntryFilterValues filterValuesForEntry(ShelfEntry source) {
    return entryFilterValuesBuilder(source);
  }

  Iterable<String> linkedMetadataCandidatesForEntry(
    ShelfEntry source,
  ) {
    return entryLinkedMetadataCandidatesBuilder(source);
  }

  String? subgroupKeyForEntry(
    LibraryProjectionRuntime item,
    String groupMode,
  ) {
    return entrySubgroupKeyBuilder(item, groupMode);
  }

  int compareEntriesByRules(
    LibraryProjectionRuntime left,
    LibraryProjectionRuntime right,
    Iterable<LibrarySortRule> rules,
  ) {
    for (final rule in rules) {
      final result = compareEntriesByColumn(left, right, rule.column);
      if (result != 0) {
        return rule.ascending ? result : -result;
      }
    }
    return left.dto.title.toLowerCase().compareTo(
          right.dto.title.toLowerCase(),
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
