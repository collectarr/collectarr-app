import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_projection_context.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';

export 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

LibraryMediaAdapter plannedMediaAdapter(
  LibraryTypeConfig type, {
  LibraryEntryColumnComparator? compareEntriesByColumn,
  LibraryWorkspaceCardBuilder? workspaceCardBuilder,
}) {
  final viewProfile = plannedMediaWorkspaceViewProfile(type);
  return LibraryMediaAdapter(
    type: type,
    viewProfile: viewProfile,
    orderedTableColumns: (columns) => orderedLibraryTableColumns(
      columns: columns,
      defaultColumns:
          libraryKindRuntimeForType(type).fields.defaultVisibleColumnIds,
    ),
    tableWidthForColumns: (columns, customWidths) =>
        plannedMediaTableWidthForColumns(
      type: type,
      columns: columns,
      customWidths: customWidths,
    ),
    tableColumnWidth: (column, customWidths) =>
        plannedMediaTableColumnWidth(type, column, customWidths),
    defaultTableColumnWidth: (column) =>
        defaultPlannedMediaTableColumnWidth(type, column),
    columnLabel: (column) => plannedMediaTableColumnLabelForType(type, column),
    columnDisplayName: (column) =>
        plannedMediaTableColumnDisplayNameForType(type, column),
    columnGroup: (column) => plannedMediaTableColumnGroup(type, column),
    columnGroupLabel: plannedMediaTableColumnGroupLabel,
    columnIsNumeric: (column) => plannedMediaTableColumnIsNumeric(type, column),
    columnSort: (column) => plannedMediaTableColumnSort(type, column),
    tableCellBuilder: (item, column) =>
        plannedMediaTableCell(type, item, column),
    compareEntriesByColumn: compareEntriesByColumn ??
        (left, right, column) => libraryKindRuntimeForType(type)
            .fields
            .sortDefinitionFor(column)
            .compare(
              LibraryProjectionContext(
                  source: left.source, node: left.node, dto: left.dto),
              LibraryProjectionContext(
                  source: right.source, node: right.node, dto: right.dto),
            ),
    entryFilterValuesBuilder: plannedMediaFilterValuesForEntry,
    entryLinkedMetadataCandidatesBuilder: (source) =>
        plannedMediaLinkedMetadataCandidatesForEntry(type, source),
    entrySubgroupKeyBuilder: (item, groupMode) =>
        plannedMediaSubgroupKeyForEntry(type, item, groupMode),
    compareSubgroupKeys: plannedMediaCompareSubgroupKeys,
    workspaceCardBuilder: workspaceCardBuilder,
  );
}

LibraryMediaAdapter collectarrMediaAdapter(
  LibraryTypeConfig type, {
  LibraryEntryColumnComparator? compareEntriesByColumn,
}) {
  return plannedMediaAdapter(
    type,
    compareEntriesByColumn: compareEntriesByColumn,
  );
}

LibraryWorkspaceViewProfile plannedMediaWorkspaceViewProfile(
  LibraryTypeConfig type,
) {
  final coverGridHeightFactor =
      type.capabilities.prefersSquareCovers ? 1.0 : 1.53;
  return LibraryWorkspaceViewProfile(
    type: type,
    defaultCoverSize: kPlannedMediaDefaultCoverSize,
    minCoverSize: kPlannedMediaMinCoverSize,
    maxCoverSize: kPlannedMediaMaxCoverSize,
    coverGridHeightFactor: coverGridHeightFactor,
    presetConfig: (preset) => plannedMediaViewPresetConfig(type, preset),
    clampColumnWidth: (column, width) =>
        clampPlannedMediaTableColumnWidth(type, column as String, width),
    defaultDetailsLayout: LibraryDetailsLayout.bottom,
    sortAscendingForColumn: (column) =>
        libraryKindRuntimeForType(type)
            .fields
            .findSortDefinition(column.toString())
            ?.defaultAscending ??
        true,
  );
}

LibraryWorkspaceViewPresetConfig plannedMediaViewPresetConfig(
  LibraryTypeConfig type,
  LibraryWorkspacePreset preset,
) {
  final defaultCols =
      Set.of(libraryKindRuntimeForType(type).fields.defaultVisibleColumnIds);
  return switch (preset) {
    LibraryWorkspacePreset.cover => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: kPlannedMediaDefaultCoverSize,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.card => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.card,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 150,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.details => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 144,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.list => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 100,
        visibleColumns: defaultCols,
      ),
  };
}

LibraryEntryFilterValues plannedMediaFilterValuesForEntry(
  ShelfEntry source,
) {
  final item = source.catalogItem;
  return LibraryEntryFilterValues(
    series: _trimmedOrNull(item?.series?.seriesTitle),
    country: _trimmedOrNull(item?.country),
    language: _trimmedOrNull(item?.language),
  );
}

Iterable<String> plannedMediaLinkedMetadataCandidatesForEntry(
  LibraryTypeConfig type,
  ShelfEntry source,
) {
  final registry = libraryKindRuntimeForType(type).fields;
  return registry.linkedMetadataCandidates(source);
}

String? plannedMediaSubgroupKeyForEntry(
  LibraryTypeConfig type,
  LibraryProjectionRuntime item,
  Object groupMode,
) {
  final registry = libraryKindRuntimeForType(type).fields;
  final definition = registry.findGroupDefinition(groupMode.toString());
  return definition?.subgroupKey?.call(
    LibraryProjectionContext(
        source: item.source, node: item.node, dto: item.dto),
  );
}

int plannedMediaCompareSubgroupKeys(
  String left,
  String right,
  Object groupMode,
) {
  if (groupMode != 'series') {
    return left.compareTo(right);
  }
  final leftNumber = _extractSubgroupNumber(left);
  final rightNumber = _extractSubgroupNumber(right);
  if (leftNumber != null && rightNumber != null) {
    return leftNumber.compareTo(rightNumber);
  }
  return left.compareTo(right);
}

String? _trimmedOrNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

int? _extractSubgroupNumber(String? value) {
  if (value == null) {
    return null;
  }
  final match = RegExp(r'(\d+)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}
