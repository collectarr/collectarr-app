import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';

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
  final module = libraryKindRuntimeForType(comicsLibraryConfig);
  final definition = module.fields.findSortDefinition(
    module.fields.decodeSortId(sortId),
  );
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
    Set.of(libraryKindRuntimeForType(comicsLibraryConfig)
        .fields
        .defaultVisibleColumns
        .map((column) => column.value)
        .toSet());

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
