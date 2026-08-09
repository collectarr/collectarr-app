import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/kinds/comic/workspace/comic_workspace_dto.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
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
  clampColumnWidth: (column, width) => clampPlannedMediaTableColumnWidth(
      comicsLibraryConfig, column as String, width),
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
      defaultPlannedMediaTableColumnWidth(comicsLibraryConfig, column),
  columnLabel: (column) =>
      plannedMediaTableColumnLabelForType(comicsLibraryConfig, column),
  columnDisplayName: (column) =>
      plannedMediaTableColumnDisplayNameForType(comicsLibraryConfig, column),
  columnGroup: (column) =>
      plannedMediaTableColumnGroup(comicsLibraryConfig, column),
  columnGroupLabel: plannedMediaTableColumnGroupLabel,
  columnIsNumeric: (column) =>
      plannedMediaTableColumnIsNumeric(comicsLibraryConfig, column),
  columnSort: (column) =>
      plannedMediaTableColumnSort(comicsLibraryConfig, column),
  tableCellBuilder: (entry, column) =>
      plannedMediaTableCell(comicsLibraryConfig, entry, column),
  compareEntriesByColumn: compareComicEntriesByColumn,
  entryFilterValuesBuilder: plannedMediaFilterValuesForEntry,
  entryLinkedMetadataCandidatesBuilder: (entry) =>
      plannedMediaLinkedMetadataCandidatesForEntry(comicsLibraryConfig, entry),
  entrySubgroupKeyBuilder: (entry, groupMode) =>
      plannedMediaSubgroupKeyForEntry(comicsLibraryConfig, entry, groupMode),
  compareSubgroupKeys: plannedMediaCompareSubgroupKeys,
);

int compareComicEntriesByColumn(
  LibraryProjectionRuntime left,
  LibraryProjectionRuntime right,
  Object column,
) {
  final sortId = column.toString();
  final module = libraryKindModuleForType(comicsLibraryConfig);
  final definition = module.fields.findSortDefinition(sortId);
  if (definition != null) {
    return definition.compareUntyped(left.dto, right.dto);
  }
  return 0;
}

const comicsTableColumnPresets = [
  LibraryTableColumnPreset(
    label: 'Essential',
    columns: {
      'status',
      'comic.title',
      'comic.number',
      'comic.publisher',
      'comic.release_date',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Ownership',
    columns: {
      'status',
      'comic.title',
      'comic.number',
      'comic.condition',
      'comic.location',
      'updated',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Value',
    columns: {
      'status',
      'comic.title',
      'comic.number',
      'comic.condition',
      'comic.price',
      'comic.barcode',
    },
  ),
  LibraryTableColumnPreset(
    label: 'Full',
    columns: {
      'status',
      'cover',
      'comic.title',
      'comic.number',
      'comic.publisher',
      'comic.release_date',
      'comic.barcode',
      'rating',
      'comic.condition',
      'comic.price',
      'comic.location',
      'wishlist',
      'updated',
    },
  ),
];

bool comicInitialSortAscending(Object column) {
  final sortId = column.toString();
  final module = libraryKindModuleForType(comicsLibraryConfig);
  final definition = module.fields.findSortDefinition(sortId);
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
    LibraryWorkspacePreset.list => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: kComicsDefaultCoverSize,
        visibleColumns: defaultComicTableColumns(),
      ),
    LibraryWorkspacePreset.details => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: 144,
        visibleColumns: defaultComicTableColumns(),
      ),
  };
}

List<String> orderedComicTableColumns(
  Set<String> columns,
) =>
    orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: defaultComicTableColumns(),
    );

Set<String> defaultComicTableColumns() =>
    Set.of(libraryKindModuleForType(comicsLibraryConfig)
        .fields
        .defaultVisibleColumnIds);

double comicTableWidthForColumns(
  Set<String> columns,
  Map<String, double> customWidths,
) {
  return plannedMediaTableWidthForColumns(
    type: comicsLibraryConfig,
    columns: columns,
    customWidths: customWidths,
  );
}

double comicTableColumnWidth(
  String column,
  Map<String, double> customWidths,
) {
  return plannedMediaTableColumnWidth(
      comicsLibraryConfig, column, customWidths);
}
