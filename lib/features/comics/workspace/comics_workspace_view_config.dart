import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/library/library_media_adapter.dart';
import 'package:collectarr_app/features/library/workspace/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';

const double kComicsMinCoverSize = 104;
const double kComicsDefaultCoverSize = 128;
const double kComicsMaxCoverSize = 188;
const double kComicTableColumnSpacing = 10;
const double kComicTableHorizontalMargin = 8;
const double kComicTableHeaderHeight = 30;
const double kComicTableRowHeight = 38;
const double kComicTableSelectionRailWidth = 3;

const comicsWorkspaceViewProfile = LibraryWorkspaceViewProfile(
  config: comicsWorkspaceConfig,
  defaultCoverSize: kComicsDefaultCoverSize,
  minCoverSize: kComicsMinCoverSize,
  maxCoverSize: kComicsMaxCoverSize,
  presetConfig: comicsViewPresetConfig,
  clampColumnWidth: clampComicTableColumnWidth,
  sortAscendingForColumn: comicInitialSortAscending,
);

final comicsMediaAdapter = LibraryMediaAdapter(
  type: comicsLibraryConfig,
  viewProfile: comicsWorkspaceViewProfile,
  orderedTableColumns: orderedComicTableColumns,
  tableWidthForColumns: comicTableWidthForColumns,
  tableColumnWidth: comicTableColumnWidth,
  defaultTableColumnWidth: defaultComicTableColumnWidth,
  columnLabel: comicTableColumnLabel,
  columnDisplayName: comicTableColumnDisplayName,
  columnGroup: comicTableColumnGroup,
  columnGroupLabel: comicTableColumnGroupLabel,
  columnIsNumeric: comicTableColumnIsNumeric,
  columnSort: comicTableColumnSort,
);

const comicsTableColumnPresets = [
  LibraryTableColumnPreset(
    label: 'Essential',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
      LibraryTableColumn.publisher,
      LibraryTableColumn.releaseDate,
    },
  ),
  LibraryTableColumnPreset(
    label: 'Ownership',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
      LibraryTableColumn.grade,
      LibraryTableColumn.condition,
      LibraryTableColumn.storageBox,
      LibraryTableColumn.updated,
    },
  ),
  LibraryTableColumnPreset(
    label: 'Value',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
      LibraryTableColumn.variant,
      LibraryTableColumn.grade,
      LibraryTableColumn.condition,
      LibraryTableColumn.price,
      LibraryTableColumn.barcode,
    },
  ),
  LibraryTableColumnPreset(
    label: 'Full',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.cover,
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
      LibraryTableColumn.variant,
      LibraryTableColumn.publisher,
      LibraryTableColumn.releaseDate,
      LibraryTableColumn.barcode,
      LibraryTableColumn.grade,
      LibraryTableColumn.condition,
      LibraryTableColumn.price,
      LibraryTableColumn.storageBox,
      LibraryTableColumn.wishlist,
      LibraryTableColumn.updated,
    },
  ),
];

bool comicInitialSortAscending(LibrarySortColumn column) {
  return switch (column) {
    LibrarySortColumn.updated => false,
    _ => true,
  };
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
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 150,
        visibleColumns: defaultComicTableColumns(),
      ),
    LibraryWorkspacePreset.list => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: kComicsDefaultCoverSize,
        visibleColumns: {
          LibraryTableColumn.status,
          LibraryTableColumn.title,
          LibraryTableColumn.issue,
          LibraryTableColumn.variant,
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.grade,
          LibraryTableColumn.condition,
          LibraryTableColumn.price,
          LibraryTableColumn.updated,
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

List<LibraryTableColumn> orderedComicTableColumns(
  Set<LibraryTableColumn> columns,
) =>
    orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: defaultComicTableColumns(),
    );

Set<LibraryTableColumn> defaultComicTableColumns() =>
    Set.of(comicsWorkspaceConfig.defaultVisibleColumns);

double comicTableWidthForColumns(
  Set<LibraryTableColumn> columns,
  Map<LibraryTableColumn, double> customWidths,
) {
  return libraryTableWidthForColumns(
    columns: columns,
    defaultColumns: defaultComicTableColumns(),
    customWidths: customWidths,
    sizing: comicTableColumnSizing,
    columnSpacing: kComicTableColumnSpacing,
    horizontalMargin: kComicTableHorizontalMargin,
  );
}

double comicTableColumnWidth(
  LibraryTableColumn column,
  Map<LibraryTableColumn, double> customWidths,
) {
  return libraryTableColumnWidth(
    column: column,
    customWidths: customWidths,
    sizing: comicTableColumnSizing,
  );
}

double defaultComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 52.0,
    LibraryTableColumn.cover => 42.0,
    LibraryTableColumn.title => 260.0,
    LibraryTableColumn.issue => 64.0,
    LibraryTableColumn.variant => 170.0,
    LibraryTableColumn.publisher => 140.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.storageBox => 118.0,
    LibraryTableColumn.wishlist => 82.0,
    LibraryTableColumn.updated => 112.0,
  };
}

double minComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 44.0,
    LibraryTableColumn.cover => 44.0,
    LibraryTableColumn.issue => 54.0,
    LibraryTableColumn.price => 78.0,
    LibraryTableColumn.wishlist => 70.0,
    _ => 86.0,
  };
}

double maxComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.title => 520.0,
    LibraryTableColumn.variant => 420.0,
    LibraryTableColumn.barcode => 260.0,
    _ => 260.0,
  };
}

LibraryTableColumnSizing comicTableColumnSizing(LibraryTableColumn column) {
  return LibraryTableColumnSizing(
    defaultWidth: defaultComicTableColumnWidth(column),
    minWidth: minComicTableColumnWidth(column),
    maxWidth: maxComicTableColumnWidth(column),
  );
}

double clampComicTableColumnWidth(
  LibraryTableColumn column,
  double width,
) {
  return clampLibraryTableColumnWidth(width, comicTableColumnSizing(column));
}

String comicTableColumnLabel(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => '',
    LibraryTableColumn.cover => '',
    LibraryTableColumn.title => 'Series',
    LibraryTableColumn.issue => 'Issue',
    LibraryTableColumn.variant => 'Variant',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.storageBox => 'Storage Box',
    LibraryTableColumn.wishlist => 'Wishlist',
    LibraryTableColumn.updated => 'Updated',
  };
}

String comicTableColumnDisplayName(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 'Status',
    LibraryTableColumn.cover => 'Cover',
    LibraryTableColumn.title => 'Series',
    LibraryTableColumn.issue => 'Issue',
    LibraryTableColumn.variant => 'Variant',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.storageBox => 'Storage Box',
    LibraryTableColumn.wishlist => 'Wishlist',
    LibraryTableColumn.updated => 'Updated',
  };
}

String comicTableColumnDescription(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 'Owned, wishlist, cover, and metadata badges',
    LibraryTableColumn.cover => 'Small cover preview',
    LibraryTableColumn.title => 'Series or item title',
    LibraryTableColumn.issue => 'Issue or item number',
    LibraryTableColumn.variant => 'Edition or variant label',
    LibraryTableColumn.publisher => 'Publisher from catalog metadata',
    LibraryTableColumn.releaseDate => 'Known release or store date',
    LibraryTableColumn.barcode => 'UPC or barcode when available',
    LibraryTableColumn.grade => 'Personal grade for owned copies',
    LibraryTableColumn.condition => 'Personal condition for owned copies',
    LibraryTableColumn.price => 'Personal purchase price',
    LibraryTableColumn.storageBox => 'Local storage box or shelf',
    LibraryTableColumn.wishlist => 'Wishlist status',
    LibraryTableColumn.updated => 'Most recent local update',
  };
}

LibraryTableColumnGroup comicTableColumnGroup(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status ||
    LibraryTableColumn.cover ||
    LibraryTableColumn.title ||
    LibraryTableColumn.issue ||
    LibraryTableColumn.publisher ||
    LibraryTableColumn.releaseDate ||
    LibraryTableColumn.updated =>
      LibraryTableColumnGroup.main,
    LibraryTableColumn.variant ||
    LibraryTableColumn.barcode =>
      LibraryTableColumnGroup.edition,
    LibraryTableColumn.grade ||
    LibraryTableColumn.condition ||
    LibraryTableColumn.price =>
      LibraryTableColumnGroup.value,
    LibraryTableColumn.storageBox ||
    LibraryTableColumn.wishlist =>
      LibraryTableColumnGroup.personal,
  };
}

String comicTableColumnGroupLabel(LibraryTableColumnGroup group) {
  return switch (group) {
    LibraryTableColumnGroup.main => 'Main',
    LibraryTableColumnGroup.edition => 'Edition',
    LibraryTableColumnGroup.value => 'Value',
    LibraryTableColumnGroup.personal => 'Personal',
  };
}

bool comicTableColumnIsNumeric(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.issue || LibraryTableColumn.price => true,
    _ => false,
  };
}

LibrarySortColumn? comicTableColumnSort(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.cover => null,
    LibraryTableColumn.status => LibrarySortColumn.status,
    LibraryTableColumn.title => LibrarySortColumn.title,
    LibraryTableColumn.issue => LibrarySortColumn.issue,
    LibraryTableColumn.variant => LibrarySortColumn.variant,
    LibraryTableColumn.publisher => LibrarySortColumn.publisher,
    LibraryTableColumn.releaseDate => LibrarySortColumn.releaseDate,
    LibraryTableColumn.barcode => LibrarySortColumn.barcode,
    LibraryTableColumn.grade => LibrarySortColumn.grade,
    LibraryTableColumn.condition => LibrarySortColumn.condition,
    LibraryTableColumn.price => LibrarySortColumn.price,
    LibraryTableColumn.storageBox => LibrarySortColumn.storageBox,
    LibraryTableColumn.wishlist => LibrarySortColumn.wishlist,
    LibraryTableColumn.updated => LibrarySortColumn.updated,
  };
}
