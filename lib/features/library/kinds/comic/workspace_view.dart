import 'package:collectarr_app/features/library/workspace/shared/library_media_adapter_builder.dart';
import 'package:collectarr_app/features/library/kinds/comic/config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_identifier_types.dart';

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
      clampPlannedMediaTableColumnWidth(comicsLibraryConfig, column, width),
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

bool comicInitialSortAscending(LibrarySortIdRuntime sortId) {
  final module = libraryKindRuntimeForType(comicsLibraryConfig);
  final definition = module.fields.findSortDefinition(
    sortId,
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

List<LibraryFieldIdRuntime> orderedComicTableColumns(
  Set<LibraryFieldIdRuntime> columns,
) =>
    orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: defaultComicTableColumns(),
    );

Set<LibraryFieldIdRuntime> defaultComicTableColumns() =>
    Set.of(libraryKindRuntimeForType(comicsLibraryConfig)
        .fields
        .defaultVisibleColumns);

double comicTableWidthForColumns(
  Set<LibraryFieldIdRuntime> columns,
  Map<LibraryFieldIdRuntime, double> customWidths,
) {
  return plannedMediaTableWidthForColumns(
    type: comicsLibraryConfig,
    columns: columns,
    customWidths: customWidths,
  );
}

double comicTableColumnWidth(
  LibraryFieldIdRuntime column,
  Map<LibraryFieldIdRuntime, double> customWidths,
) {
  return plannedMediaTableColumnWidth(
      comicsLibraryConfig, column, customWidths);
}
