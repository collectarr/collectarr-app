import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';

const double kComicsMinCoverSize = 104;
const double kComicsDefaultCoverSize = 128;
const double kComicsMaxCoverSize = 188;
const double kLibraryTableColumnSpacing = 10;
const double kLibraryTableHorizontalMargin = 8;
const double kLibraryTableHeaderHeight = 30;
const double kLibraryTableRowHeight = 38;
const double kLibraryTableSelectionRailWidth = 3;

final comicsWorkspaceViewProfile = LibraryWorkspaceViewProfile(
  type: comicsLibraryConfig,
  defaultCoverSize: kComicsDefaultCoverSize,
  minCoverSize: kComicsMinCoverSize,
  maxCoverSize: kComicsMaxCoverSize,
  presetConfig: comicsViewPresetConfig,
  clampColumnWidth: (column, width) =>
      clampPlannedMediaTableColumnWidth(comicsLibraryConfig, column as String, width),
  defaultDetailsWidth: 350,
  defaultDetailsLayout: LibraryDetailsLayout.right,
  hideDetailsWhenSelectionEmpty: false,
  sortAscendingForColumn: comicInitialSortAscending,
);

final comicsMediaAdapter = LibraryMediaAdapter(
  type: comicsLibraryConfig,
  viewProfile: comicsWorkspaceViewProfile,
  orderedTableColumns: orderedComicTableColumns,
  tableWidthForColumns: comicTableWidthForColumns,
  tableColumnWidth: comicTableColumnWidth,
  defaultTableColumnWidth: (column) =>
      defaultPlannedMediaTableColumnWidth(comicsLibraryConfig, column as String),
  columnLabel: (column) =>
      plannedMediaTableColumnLabelForType(comicsLibraryConfig, column as String),
  columnDisplayName: (column) =>
      plannedMediaTableColumnDisplayNameForType(comicsLibraryConfig, column as String),
  columnGroup: (column) =>
      plannedMediaTableColumnGroup(comicsLibraryConfig, column as String),
  columnGroupLabel: plannedMediaTableColumnGroupLabel,
  columnIsNumeric: (column) =>
      plannedMediaTableColumnIsNumeric(comicsLibraryConfig, column as String),
  columnSort: (column) =>
      plannedMediaTableColumnSort(comicsLibraryConfig, column as String),
  tableCellBuilder: (entry, column) =>
      plannedMediaTableCell(comicsLibraryConfig, entry, column as String),
  compareEntriesByColumn: compareComicEntriesByColumn,
  entryFilterValuesBuilder: plannedMediaFilterValuesForEntry,
  entryLinkedMetadataCandidatesBuilder:
      plannedMediaLinkedMetadataCandidatesForEntry,
  entrySubgroupKeyBuilder: plannedMediaSubgroupKeyForEntry,
  compareSubgroupKeys: plannedMediaCompareSubgroupKeys,
);

int compareComicEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  Object column,
) {
  final sortId = comicsLibraryConfig.sortColumnFieldId(column);
  final module = libraryKindModuleForType(comicsLibraryConfig);
  final definition = module.fields.sortDefinitionForId(sortId);
  if (definition != null) {
    return definition.compare(left, right);
  }
  return 0;
}

const comicsTableColumnPresets = [
  LibraryTableColumnPreset(
    label: 'Essential',
    columns: {
      'status',
      'title',
      'issue',
      'publisher',
      'release_date',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Ownership',
    columns: {
      'status',
      'title',
      'issue',
      'grade',
      'condition',
      'value',
      'location',
      'updated',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Value',
    columns: {
      'status',
      'title',
      'issue',
      'variant',
      'grade',
      'condition',
      'price',
      'value',
      'barcode',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Images',
    columns: {
      'status',
      'front_cover',
      'back_cover',
      'has_front',
      'has_back',
      'extra_images',
      'title',
      'issue',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Full',
    columns: {
      'status',
      'cover',
      'front_cover',
      'back_cover',
      'has_front',
      'has_back',
      'extra_images',
      'title',
      'issue',
      'variant',
      'publisher',
      'release_date',
      'barcode',
      'grade',
      'condition',
      'value',
      'price',
      'location',
      'wishlist',
      'updated',
    },
  ),
];

bool comicInitialSortAscending(Object column) {
  final sortId = comicsLibraryConfig.sortColumnFieldId(column);
  final module = libraryKindModuleForType(comicsLibraryConfig);
  final definition = module.fields.sortDefinitionForId(sortId);
  return definition?.defaultAscending ?? true;
}

LibraryWorkspaceViewPresetConfig comicsViewPresetConfig(
  LibraryWorkspacePreset preset,
) {
  return switch (preset) {
    LibraryWorkspacePreset.cover => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: kComicsDefaultCoverSize,
        visibleColumns: defaultComicTableColumns(),
      ),
    LibraryWorkspacePreset.card => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.card,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: 150,
        visibleColumns: defaultComicTableColumns(),
      ),
    LibraryWorkspacePreset.list => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: kComicsDefaultCoverSize,
        visibleColumns: {
          'status',
          'title',
          'issue',
          'variant',
          'publisher',
          'release_date',
          'location',
          'format',
          'added',
        },
      ),
    LibraryWorkspacePreset.details => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: 144,
        visibleColumns: defaultComicTableColumns(),
      ),
  };
}

List<Object> orderedComicTableColumns(
  Set<Object> columns,
) =>
    orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: defaultComicTableColumns(),
    );

Set<Object> defaultComicTableColumns() =>
    Set.of(comicsLibraryConfig.defaultVisibleColumns);

double comicTableWidthForColumns(
  Set<Object> columns,
  Map<Object, double> customWidths,
) {
  return plannedMediaTableWidthForColumns(
    type: comicsLibraryConfig,
    columns: columns.cast<String>().toSet(),
    customWidths: customWidths.cast<String, double>(),
  );
}

double comicTableColumnWidth(
  Object column,
  Map<Object, double> customWidths,
) {
  return plannedMediaTableColumnWidth(
      comicsLibraryConfig, column as String, customWidths.cast<String, double>());
}
