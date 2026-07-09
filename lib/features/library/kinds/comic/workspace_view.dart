import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
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

const comicsWorkspaceViewProfile = LibraryWorkspaceViewProfile(
  config: comicsWorkspaceConfig,
  defaultCoverSize: kComicsDefaultCoverSize,
  minCoverSize: kComicsMinCoverSize,
  maxCoverSize: kComicsMaxCoverSize,
  presetConfig: comicsViewPresetConfig,
  clampColumnWidth: clampComicTableColumnWidth,
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
  defaultTableColumnWidth: defaultComicTableColumnWidth,
  columnLabel: comicTableColumnLabel,
  columnDisplayName: comicTableColumnDisplayName,
  columnGroup: comicTableColumnGroup,
  columnGroupLabel: comicTableColumnGroupLabel,
  columnIsNumeric: comicTableColumnIsNumeric,
  columnSort: comicTableColumnSort,
  tableCellBuilder: (entry, column) =>
      plannedMediaTableCell(entry, column),
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
  LibrarySortColumn column,
) =>
    comparePlannedMediaEntriesByColumn(left, right, column);

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
      LibraryTableColumn.value,
      LibraryTableColumn.location,
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
      LibraryTableColumn.value,
      LibraryTableColumn.barcode,
    },
  ),
  LibraryTableColumnPreset(
    label: 'Images',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.frontCover,
      LibraryTableColumn.backCover,
      LibraryTableColumn.hasFront,
      LibraryTableColumn.hasBack,
      LibraryTableColumn.extraImages,
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
    },
  ),
  LibraryTableColumnPreset(
    label: 'Full',
    columns: {
      LibraryTableColumn.status,
      LibraryTableColumn.cover,
      LibraryTableColumn.frontCover,
      LibraryTableColumn.backCover,
      LibraryTableColumn.hasFront,
      LibraryTableColumn.hasBack,
      LibraryTableColumn.extraImages,
      LibraryTableColumn.title,
      LibraryTableColumn.issue,
      LibraryTableColumn.variant,
      LibraryTableColumn.publisher,
      LibraryTableColumn.releaseDate,
      LibraryTableColumn.barcode,
      LibraryTableColumn.grade,
      LibraryTableColumn.condition,
      LibraryTableColumn.value,
      LibraryTableColumn.price,
      LibraryTableColumn.location,
      LibraryTableColumn.wishlist,
      LibraryTableColumn.updated,
    },
  ),
];

bool comicInitialSortAscending(LibrarySortColumn column) {
  return switch (column) {
    LibrarySortColumn.added => false,
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
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: 150,
        visibleColumns: defaultComicTableColumns(),
      ),
    LibraryWorkspacePreset.list => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.right,
        coverSize: kComicsDefaultCoverSize,
        visibleColumns: {
          LibraryTableColumn.status,
          LibraryTableColumn.title,
          LibraryTableColumn.issue,
          LibraryTableColumn.variant,
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.location,
          LibraryTableColumn.format,
          LibraryTableColumn.added,
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
    columnSpacing: kLibraryTableColumnSpacing,
    horizontalMargin: kLibraryTableHorizontalMargin,
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
    LibraryTableColumn.frontCover => 42.0,
    LibraryTableColumn.backCover => 42.0,
    LibraryTableColumn.hasFront => 78.0,
    LibraryTableColumn.hasBack => 78.0,
    LibraryTableColumn.extraImages => 82.0,
    LibraryTableColumn.author => 160.0,
    LibraryTableColumn.artist => 160.0,
    LibraryTableColumn.album => 260.0,
    LibraryTableColumn.title => 260.0,
    LibraryTableColumn.issue => 64.0,
    LibraryTableColumn.variant => 170.0,
    LibraryTableColumn.format => 118.0,
    LibraryTableColumn.publisher => 140.0,
    LibraryTableColumn.label => 140.0,
    LibraryTableColumn.catalogNumber => 134.0,
    LibraryTableColumn.platform => 118.0,
    LibraryTableColumn.developer => 140.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.releasePlatform => 140.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.discCount => 92.0,
    LibraryTableColumn.trackCount => 92.0,
    LibraryTableColumn.length => 92.0,
    LibraryTableColumn.vinylColor => 118.0,
    LibraryTableColumn.rpm => 78.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.completion => 110.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.value => 92.0,
    LibraryTableColumn.readStatus => 104.0,
    LibraryTableColumn.rating => 84.0,
    LibraryTableColumn.location => 118.0,
    LibraryTableColumn.wishlist => 82.0,
    LibraryTableColumn.added => 98.0,
    LibraryTableColumn.updated => 112.0,
    LibraryTableColumn.country => 100.0,
    LibraryTableColumn.language => 100.0,
    LibraryTableColumn.pageCount => 80.0,
    LibraryTableColumn.ageRating => 100.0,
    LibraryTableColumn.imprint => 140.0,
  };
}

double minComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 44.0,
    LibraryTableColumn.cover => 44.0,
    LibraryTableColumn.frontCover => 44.0,
    LibraryTableColumn.backCover => 44.0,
    LibraryTableColumn.hasFront => 68.0,
    LibraryTableColumn.hasBack => 68.0,
    LibraryTableColumn.extraImages => 70.0,
    LibraryTableColumn.artist => 110.0,
    LibraryTableColumn.album => 160.0,
    LibraryTableColumn.issue => 54.0,
    LibraryTableColumn.price => 78.0,
    LibraryTableColumn.wishlist => 70.0,
    LibraryTableColumn.catalogNumber => 84.0,
    LibraryTableColumn.discCount => 64.0,
    LibraryTableColumn.trackCount => 64.0,
    LibraryTableColumn.length => 72.0,
    LibraryTableColumn.rpm => 60.0,
    _ => 86.0,
  };
}

double maxComicTableColumnWidth(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.title => 520.0,
    LibraryTableColumn.album => 520.0,
    LibraryTableColumn.variant => 420.0,
    LibraryTableColumn.barcode => 260.0,
    LibraryTableColumn.catalogNumber => 240.0,
    LibraryTableColumn.frontCover => 90.0,
    LibraryTableColumn.backCover => 90.0,
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
    LibraryTableColumn.title => 'Series',
    LibraryTableColumn.variant => 'Variant Description',
    LibraryTableColumn.frontCover => 'Front Cover',
    LibraryTableColumn.backCover => 'Back Cover',
    LibraryTableColumn.hasFront => 'Has Front',
    LibraryTableColumn.hasBack => 'Has Back',
    LibraryTableColumn.extraImages => 'Extra Images',
    LibraryTableColumn.location => 'Location',
    LibraryTableColumn.added => 'Added Date',
    LibraryTableColumn.platform => 'Platform',
    LibraryTableColumn.developer => 'Developer',
    LibraryTableColumn.releasePlatform => 'Release Platform',
    LibraryTableColumn.completion => 'Completion',
    LibraryTableColumn.value => 'Value',
    _ => plannedMediaTableColumnLabelForType(comicsLibraryConfig, column),
  };
}

String comicTableColumnDisplayName(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.title => 'Series',
    LibraryTableColumn.variant => 'Variant Description',
    LibraryTableColumn.frontCover => 'Front Cover',
    LibraryTableColumn.backCover => 'Back Cover',
    LibraryTableColumn.hasFront => 'Has Front',
    LibraryTableColumn.hasBack => 'Has Back',
    LibraryTableColumn.extraImages => 'Extra Images',
    LibraryTableColumn.location => 'Location',
    LibraryTableColumn.added => 'Added Date',
    LibraryTableColumn.platform => 'Platform',
    LibraryTableColumn.developer => 'Developer',
    LibraryTableColumn.releasePlatform => 'Release Platform',
    LibraryTableColumn.completion => 'Completion',
    LibraryTableColumn.value => 'Value',
    _ => plannedMediaTableColumnDisplayNameForType(comicsLibraryConfig, column),
  };
}

String comicTableColumnDescription(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status => 'Owned, wishlist, cover, and metadata badges',
    LibraryTableColumn.cover => 'Small cover preview',
    LibraryTableColumn.frontCover => 'Front cover preview',
    LibraryTableColumn.backCover => 'Back cover preview',
    LibraryTableColumn.hasFront => 'Owned copy has a front cover image',
    LibraryTableColumn.hasBack => 'Owned copy has a back cover image',
    LibraryTableColumn.extraImages => 'Owned copy extra image count',
    LibraryTableColumn.author => 'Author or creator name',
    LibraryTableColumn.artist => 'Artist or creator name',
    LibraryTableColumn.album => 'Album or work title',
    LibraryTableColumn.title => 'Series or item title',
    LibraryTableColumn.issue => 'Issue or item number',
    LibraryTableColumn.variant => 'Edition or variant label',
    LibraryTableColumn.format => 'Primary physical format label',
    LibraryTableColumn.publisher => 'Publisher from catalog metadata',
    LibraryTableColumn.label => 'Music label or publisher',
    LibraryTableColumn.catalogNumber => 'Music catalog number',
    LibraryTableColumn.platform => 'Platform or system metadata',
    LibraryTableColumn.developer => 'Developer or creator metadata',
    LibraryTableColumn.releaseDate => 'Known release or store date',
    LibraryTableColumn.releasePlatform => 'Platform for the selected release',
    LibraryTableColumn.barcode => 'UPC or barcode when available',
    LibraryTableColumn.discCount => 'Number of discs or media',
    LibraryTableColumn.trackCount => 'Number of tracks',
    LibraryTableColumn.length => 'Total runtime',
    LibraryTableColumn.vinylColor => 'Vinyl color or media color',
    LibraryTableColumn.rpm => 'Playback speed',
    LibraryTableColumn.grade => 'Personal grade for owned copies',
    LibraryTableColumn.condition => 'Personal condition for owned copies',
    LibraryTableColumn.price => 'Personal purchase price',
    LibraryTableColumn.completion => 'Completion or collection status',
    LibraryTableColumn.value => 'Current or paid value',
    LibraryTableColumn.readStatus => 'Read It',
    LibraryTableColumn.rating => 'Rating',
    LibraryTableColumn.location => 'Assigned location path',
    LibraryTableColumn.wishlist => 'Wishlist status',
    LibraryTableColumn.added => 'Added date for owned or wishlisted items',
    LibraryTableColumn.updated => 'Most recent local update',
    LibraryTableColumn.country => 'Country of publication',
    LibraryTableColumn.language => 'Publication language',
    LibraryTableColumn.pageCount => 'Number of pages',
    LibraryTableColumn.ageRating => 'Content age rating',
    LibraryTableColumn.imprint => 'Publisher imprint',
  };
}

LibraryTableColumnGroup comicTableColumnGroup(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.status ||
    LibraryTableColumn.cover ||
    LibraryTableColumn.frontCover ||
    LibraryTableColumn.backCover ||
    LibraryTableColumn.author ||
    LibraryTableColumn.artist ||
    LibraryTableColumn.album ||
    LibraryTableColumn.title ||
    LibraryTableColumn.issue ||
    LibraryTableColumn.publisher ||
    LibraryTableColumn.label ||
    LibraryTableColumn.catalogNumber ||
    LibraryTableColumn.releaseDate ||
    LibraryTableColumn.discCount ||
    LibraryTableColumn.trackCount ||
    LibraryTableColumn.length ||
    LibraryTableColumn.vinylColor ||
    LibraryTableColumn.rpm ||
    LibraryTableColumn.added ||
    LibraryTableColumn.updated =>
      LibraryTableColumnGroup.main,
    LibraryTableColumn.variant ||
    LibraryTableColumn.format ||
    LibraryTableColumn.barcode ||
    LibraryTableColumn.platform ||
    LibraryTableColumn.developer ||
    LibraryTableColumn.releasePlatform =>
      LibraryTableColumnGroup.edition,
    LibraryTableColumn.grade ||
    LibraryTableColumn.condition ||
    LibraryTableColumn.price ||
    LibraryTableColumn.value =>
      LibraryTableColumnGroup.value,
    LibraryTableColumn.rating => LibraryTableColumnGroup.value,
    LibraryTableColumn.location ||
    LibraryTableColumn.readStatus ||
    LibraryTableColumn.wishlist ||
    LibraryTableColumn.completion ||
    LibraryTableColumn.hasFront ||
    LibraryTableColumn.hasBack ||
    LibraryTableColumn.extraImages =>
      LibraryTableColumnGroup.personal,
    LibraryTableColumn.country ||
    LibraryTableColumn.language ||
    LibraryTableColumn.pageCount ||
    LibraryTableColumn.ageRating ||
    LibraryTableColumn.imprint =>
      LibraryTableColumnGroup.edition,
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
    LibraryTableColumn.issue ||
    LibraryTableColumn.price ||
    LibraryTableColumn.value ||
    LibraryTableColumn.pageCount ||
    LibraryTableColumn.extraImages =>
      true,
    _ => false,
  };
}

LibrarySortColumn? comicTableColumnSort(LibraryTableColumn column) {
  return switch (column) {
    LibraryTableColumn.cover => null,
    LibraryTableColumn.frontCover => null,
    LibraryTableColumn.backCover => null,
    LibraryTableColumn.hasFront => null,
    LibraryTableColumn.hasBack => null,
    LibraryTableColumn.extraImages => null,
    LibraryTableColumn.status => LibrarySortColumn.status,
    LibraryTableColumn.author => null,
    LibraryTableColumn.artist => null,
    LibraryTableColumn.album => LibrarySortColumn.title,
    LibraryTableColumn.title => LibrarySortColumn.title,
    LibraryTableColumn.issue => LibrarySortColumn.issue,
    LibraryTableColumn.variant => LibrarySortColumn.variant,
    LibraryTableColumn.format => LibrarySortColumn.format,
    LibraryTableColumn.publisher => LibrarySortColumn.publisher,
    LibraryTableColumn.label => LibrarySortColumn.publisher,
    LibraryTableColumn.catalogNumber => null,
    LibraryTableColumn.platform => null,
    LibraryTableColumn.developer => null,
    LibraryTableColumn.releaseDate => LibrarySortColumn.releaseDate,
    LibraryTableColumn.releasePlatform => LibrarySortColumn.format,
    LibraryTableColumn.barcode => LibrarySortColumn.barcode,
    LibraryTableColumn.discCount => null,
    LibraryTableColumn.trackCount => null,
    LibraryTableColumn.length => null,
    LibraryTableColumn.vinylColor => null,
    LibraryTableColumn.rpm => null,
    LibraryTableColumn.grade => LibrarySortColumn.grade,
    LibraryTableColumn.condition => LibrarySortColumn.condition,
    LibraryTableColumn.price => LibrarySortColumn.price,
    LibraryTableColumn.value => LibrarySortColumn.price,
    LibraryTableColumn.readStatus => null,
    LibraryTableColumn.rating => null,
    LibraryTableColumn.location => LibrarySortColumn.location,
    LibraryTableColumn.wishlist => LibrarySortColumn.wishlist,
    LibraryTableColumn.completion => LibrarySortColumn.collectionStatus,
    LibraryTableColumn.added => LibrarySortColumn.added,
    LibraryTableColumn.updated => LibrarySortColumn.updated,
    LibraryTableColumn.country => LibrarySortColumn.country,
    LibraryTableColumn.language => LibrarySortColumn.language,
    LibraryTableColumn.pageCount => LibrarySortColumn.pageCount,
    LibraryTableColumn.ageRating => LibrarySortColumn.ageRating,
    LibraryTableColumn.imprint => LibrarySortColumn.imprint,
  };
}
