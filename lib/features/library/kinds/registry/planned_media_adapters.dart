import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/anime/config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/manga/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/kinds/tv/config.dart';
import 'package:collectarr_app/features/library/workspace/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

final mangaMediaAdapter = plannedMediaAdapter(mangaLibraryConfig);
final animeMediaAdapter = plannedMediaAdapter(animeLibraryConfig);
final booksMediaAdapter = plannedMediaAdapter(booksLibraryConfig);
final gamesMediaAdapter = plannedMediaAdapter(gamesLibraryConfig);
final boardGamesMediaAdapter = plannedMediaAdapter(boardGamesLibraryConfig);
final moviesMediaAdapter = plannedMediaAdapter(moviesLibraryConfig);
final tvMediaAdapter = plannedMediaAdapter(tvLibraryConfig);
final musicMediaAdapter = plannedMediaAdapter(musicLibraryConfig);

final plannedMediaAdapters = LibraryMediaAdapterRegistry([
  mangaMediaAdapter,
  animeMediaAdapter,
  booksMediaAdapter,
  gamesMediaAdapter,
  boardGamesMediaAdapter,
  moviesMediaAdapter,
  tvMediaAdapter,
  musicMediaAdapter,
]);

LibraryMediaAdapter plannedMediaAdapter(LibraryTypeConfig type) {
  final viewProfile = plannedMediaWorkspaceViewProfile(type.workspace);
  return LibraryMediaAdapter(
    type: type,
    viewProfile: viewProfile,
    orderedTableColumns: (columns) => orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: type.workspace.defaultVisibleColumns,
    ),
    tableWidthForColumns: (columns, customWidths) =>
        plannedMediaTableWidthForColumns(
      config: type.workspace,
      columns: columns,
      customWidths: customWidths,
    ),
    tableColumnWidth: plannedMediaTableColumnWidth,
    defaultTableColumnWidth: defaultPlannedMediaTableColumnWidth,
    columnLabel: (column) => plannedMediaTableColumnLabelForType(type, column),
    columnDisplayName: (column) =>
        plannedMediaTableColumnDisplayNameForType(type, column),
    columnGroup: plannedMediaTableColumnGroup,
    columnGroupLabel: plannedMediaTableColumnGroupLabel,
    columnIsNumeric: plannedMediaTableColumnIsNumeric,
    columnSort: plannedMediaTableColumnSort,
  );
}

LibraryWorkspaceViewProfile plannedMediaWorkspaceViewProfile(
  LibraryWorkspaceConfig config,
) {
  return LibraryWorkspaceViewProfile(
    config: config,
    defaultCoverSize: kPlannedMediaDefaultCoverSize,
    minCoverSize: kPlannedMediaMinCoverSize,
    maxCoverSize: kPlannedMediaMaxCoverSize,
    presetConfig: plannedMediaViewPresetConfig,
    clampColumnWidth: clampPlannedMediaTableColumnWidth,
    sortAscendingForColumn: plannedMediaInitialSortAscending,
  );
}

bool plannedMediaInitialSortAscending(LibrarySortColumn column) {
  return switch (column) {
    LibrarySortColumn.updated => false,
    _ => true,
  };
}

LibraryWorkspaceViewPresetConfig plannedMediaViewPresetConfig(
  LibraryWorkspacePreset preset,
) {
  return switch (preset) {
    LibraryWorkspacePreset.cover => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: kPlannedMediaDefaultCoverSize,
        visibleColumns: {
          LibraryTableColumn.status,
          LibraryTableColumn.cover,
          LibraryTableColumn.title,
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
        },
      ),
    LibraryWorkspacePreset.card => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.card,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 150,
        visibleColumns: {
          LibraryTableColumn.status,
          LibraryTableColumn.cover,
          LibraryTableColumn.title,
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.condition,
        },
      ),
    LibraryWorkspacePreset.list => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: kPlannedMediaDefaultCoverSize,
        visibleColumns: {
          LibraryTableColumn.status,
          LibraryTableColumn.title,
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.condition,
          LibraryTableColumn.price,
          LibraryTableColumn.storageBox,
          LibraryTableColumn.updated,
        },
      ),
    LibraryWorkspacePreset.details => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: 144,
        visibleColumns: {
          LibraryTableColumn.status,
          LibraryTableColumn.cover,
          LibraryTableColumn.title,
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.barcode,
          LibraryTableColumn.condition,
          LibraryTableColumn.price,
        },
      ),
  };
}

double plannedMediaTableWidthForColumns({
  required LibraryWorkspaceConfig config,
  required Set<LibraryTableColumn> columns,
  required Map<LibraryTableColumn, double> customWidths,
}) {
  return libraryTableWidthForColumns(
    columns: columns,
    defaultColumns: config.defaultVisibleColumns,
    customWidths: customWidths,
    sizing: plannedMediaTableColumnSizing,
    columnSpacing: kPlannedMediaTableColumnSpacing,
    horizontalMargin: kPlannedMediaTableHorizontalMargin,
  );
}

double plannedMediaTableColumnWidth(
  LibraryTableColumn column,
  Map<LibraryTableColumn, double> customWidths,
) {
  return libraryTableColumnWidth(
    column: column,
    customWidths: customWidths,
    sizing: plannedMediaTableColumnSizing,
  );
}

double defaultPlannedMediaTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 52.0,
    LibraryTableColumn.cover => 42.0,
    LibraryTableColumn.title => 280.0,
    LibraryTableColumn.issue => 86.0,
    LibraryTableColumn.variant => 170.0,
    LibraryTableColumn.publisher => 150.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.storageBox => 118.0,
    LibraryTableColumn.wishlist => 82.0,
    LibraryTableColumn.updated => 112.0,
    LibraryTableColumn.country => 100.0,
    LibraryTableColumn.language => 100.0,
    LibraryTableColumn.pageCount => 80.0,
    LibraryTableColumn.ageRating => 100.0,
    LibraryTableColumn.imprint => 140.0,
  };
}

double minPlannedMediaTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 44.0,
    LibraryTableColumn.cover => 44.0,
    LibraryTableColumn.issue => 64.0,
    LibraryTableColumn.price => 78.0,
    LibraryTableColumn.wishlist => 70.0,
    _ => 86.0,
  };
}

double maxPlannedMediaTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.title => 560.0,
    LibraryTableColumn.variant => 420.0,
    LibraryTableColumn.barcode => 260.0,
    _ => 260.0,
  };
}

LibraryTableColumnSizing plannedMediaTableColumnSizing(
  LibraryTableColumn column,
) {
  return LibraryTableColumnSizing(
    defaultWidth: defaultPlannedMediaTableColumnWidth(column),
    minWidth: minPlannedMediaTableColumnWidth(column),
    maxWidth: maxPlannedMediaTableColumnWidth(column),
  );
}

double clampPlannedMediaTableColumnWidth(
  LibraryTableColumn column,
  double width,
) {
  return clampLibraryTableColumnWidth(
    width,
    plannedMediaTableColumnSizing(column),
  );
}

String plannedMediaTableColumnLabel(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => '',
    LibraryTableColumn.cover => '',
    LibraryTableColumn.title => 'Title',
    LibraryTableColumn.issue => 'Number',
    LibraryTableColumn.variant => 'Edition',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.storageBox => 'Location',
    LibraryTableColumn.wishlist => 'Wishlist',
    LibraryTableColumn.updated => 'Updated',
    LibraryTableColumn.country => 'Country',
    LibraryTableColumn.language => 'Language',
    LibraryTableColumn.pageCount => 'Pages',
    LibraryTableColumn.ageRating => 'Age Rating',
    LibraryTableColumn.imprint => 'Imprint',
  };
}

String plannedMediaTableColumnLabelForType(
  LibraryTypeConfig type,
  LibraryTableColumn column,
) {
  return switch (column) {
    LibraryTableColumn.issue => type.mediaFields.numberLabel,
    LibraryTableColumn.variant => type.releaseFields.variantLabel,
    LibraryTableColumn.publisher => type.mediaFields.publisherLabel,
    LibraryTableColumn.barcode => type.releaseFields.barcodeLabel,
    _ => plannedMediaTableColumnLabel(column),
  };
}

String plannedMediaTableColumnDisplayName(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 'Status',
    LibraryTableColumn.cover => 'Cover',
    _ => plannedMediaTableColumnLabel(column),
  };
}

String plannedMediaTableColumnDisplayNameForType(
  LibraryTypeConfig type,
  LibraryTableColumn column,
) {
  return switch (column) {
    LibraryTableColumn.status => 'Status',
    LibraryTableColumn.cover => 'Cover',
    _ => plannedMediaTableColumnLabelForType(type, column),
  };
}

LibraryTableColumnGroup plannedMediaTableColumnGroup(
  LibraryTableColumn column,
) {
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
    LibraryTableColumn.country ||
    LibraryTableColumn.language ||
    LibraryTableColumn.pageCount ||
    LibraryTableColumn.ageRating ||
    LibraryTableColumn.imprint =>
      LibraryTableColumnGroup.edition,
  };
}

String plannedMediaTableColumnGroupLabel(LibraryTableColumnGroup group) {
  return switch (group) {
    LibraryTableColumnGroup.main => 'Main',
    LibraryTableColumnGroup.edition => 'Edition',
    LibraryTableColumnGroup.value => 'Value',
    LibraryTableColumnGroup.personal => 'Personal',
  };
}

bool plannedMediaTableColumnIsNumeric(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.issue ||
    LibraryTableColumn.price ||
    LibraryTableColumn.pageCount =>
      true,
    _ => false,
  };
}

LibrarySortColumn? plannedMediaTableColumnSort(LibraryTableColumn column) {
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
    LibraryTableColumn.country => LibrarySortColumn.country,
    LibraryTableColumn.language => LibrarySortColumn.language,
    LibraryTableColumn.pageCount => LibrarySortColumn.pageCount,
    LibraryTableColumn.ageRating => LibrarySortColumn.ageRating,
    LibraryTableColumn.imprint => LibrarySortColumn.imprint,
  };
}