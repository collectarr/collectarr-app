import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/tiles/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

final booksMediaAdapter = plannedMediaAdapter(
  booksLibraryConfig,
  entryAccessors: plannedBookEntryAccessors,
  compareEntriesByColumn: compareBookEntriesByColumn,
);
final gamesMediaAdapter = plannedMediaAdapter(
  gamesLibraryConfig,
  entryAccessors: plannedGameEntryAccessors,
  compareEntriesByColumn: compareGameEntriesByColumn,
);
final boardGamesMediaAdapter = plannedMediaAdapter(
  boardGamesLibraryConfig,
  entryAccessors: plannedBoardGameEntryAccessors,
  compareEntriesByColumn: compareBoardGameEntriesByColumn,
);
final moviesMediaAdapter = plannedMediaAdapter(
  moviesLibraryConfig,
  entryAccessors: plannedMovieEntryAccessors,
  compareEntriesByColumn: compareMovieEntriesByColumn,
);
final musicMediaAdapter = plannedMediaAdapter(
  musicLibraryConfig,
  entryAccessors: plannedMusicEntryAccessors,
  compareEntriesByColumn: compareMusicEntriesByColumn,
);

final plannedMediaAdapters = LibraryMediaAdapterRegistry([
  booksMediaAdapter,
  gamesMediaAdapter,
  boardGamesMediaAdapter,
  moviesMediaAdapter,
  musicMediaAdapter,
]);

LibraryMediaAdapter plannedMediaAdapter(
  LibraryTypeConfig type, {
  PlannedMediaEntryAccessors? entryAccessors,
  LibraryEntryColumnComparator? compareEntriesByColumn,
}) {
  final resolvedEntryAccessors = entryAccessors ?? plannedDefaultEntryAccessors;
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
    tableCellBuilder: (entry, column) =>
      plannedMediaTableCell(entry, column, resolvedEntryAccessors),
    compareEntriesByColumn: compareEntriesByColumn ??
        (left, right, column) =>
            comparePlannedMediaEntriesByColumn(
              left,
              right,
              column,
          resolvedEntryAccessors,
            ),
    entryFilterValuesBuilder: (entry) =>
      plannedMediaFilterValuesForEntry(entry, resolvedEntryAccessors),
    entryLinkedMetadataCandidatesBuilder: (entry) =>
      plannedMediaLinkedMetadataCandidatesForEntry(entry, resolvedEntryAccessors),
    entrySubgroupKeyBuilder: plannedMediaSubgroupKeyForEntry,
    compareSubgroupKeys: plannedMediaCompareSubgroupKeys,
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
    defaultDetailsLayout: LibraryDetailsLayout.bottom,
    sortAscendingForColumn: plannedMediaInitialSortAscending,
  );
}

bool plannedMediaInitialSortAscending(LibrarySortColumn column) {
  return switch (column) {
    LibrarySortColumn.added => false,
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
        detailsLayout: LibraryDetailsLayout.bottom,
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
          LibraryTableColumn.format,
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.condition,
          LibraryTableColumn.price,
          LibraryTableColumn.location,
          LibraryTableColumn.added,
        },
      ),
    LibraryWorkspacePreset.details => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.bottom,
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
    LibraryTableColumn.format => 116.0,
    LibraryTableColumn.publisher => 150.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.location => 118.0,
    LibraryTableColumn.wishlist => 82.0,
    LibraryTableColumn.added => 112.0,
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
    LibraryTableColumn.format => 'Format',
    LibraryTableColumn.publisher => 'Publisher',
    LibraryTableColumn.releaseDate => 'Release Date',
    LibraryTableColumn.barcode => 'Barcode',
    LibraryTableColumn.grade => 'Grade',
    LibraryTableColumn.condition => 'Condition',
    LibraryTableColumn.price => 'Price',
    LibraryTableColumn.location => 'Location',
    LibraryTableColumn.wishlist => 'Wishlist',
    LibraryTableColumn.added => 'Added Date',
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
    LibraryTableColumn.added ||
    LibraryTableColumn.updated =>
      LibraryTableColumnGroup.main,
    LibraryTableColumn.variant ||
    LibraryTableColumn.format ||
    LibraryTableColumn.barcode =>
      LibraryTableColumnGroup.edition,
    LibraryTableColumn.grade ||
    LibraryTableColumn.condition ||
    LibraryTableColumn.price =>
      LibraryTableColumnGroup.value,
    LibraryTableColumn.location ||
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
    LibraryTableColumn.format => LibrarySortColumn.format,
    LibraryTableColumn.publisher => LibrarySortColumn.publisher,
    LibraryTableColumn.releaseDate => LibrarySortColumn.releaseDate,
    LibraryTableColumn.barcode => LibrarySortColumn.barcode,
    LibraryTableColumn.grade => LibrarySortColumn.grade,
    LibraryTableColumn.condition => LibrarySortColumn.condition,
    LibraryTableColumn.price => LibrarySortColumn.price,
    LibraryTableColumn.location => LibrarySortColumn.location,
    LibraryTableColumn.wishlist => LibrarySortColumn.wishlist,
    LibraryTableColumn.added => LibrarySortColumn.added,
    LibraryTableColumn.updated => LibrarySortColumn.updated,
    LibraryTableColumn.country => LibrarySortColumn.country,
    LibraryTableColumn.language => LibrarySortColumn.language,
    LibraryTableColumn.pageCount => LibrarySortColumn.pageCount,
    LibraryTableColumn.ageRating => LibrarySortColumn.ageRating,
    LibraryTableColumn.imprint => LibrarySortColumn.imprint,
  };
}

Widget plannedMediaTableCell(
  LibraryWorkspaceEntry entry,
  LibraryTableColumn column,
  PlannedMediaEntryAccessors accessors,
) {
  return switch (column) {
    LibraryTableColumn.status => LibraryItemStatusIcons(
        isOwned: entry.isOwned,
        isTracked: entry.isTracked,
        isWishlisted: entry.isWishlisted,
        hasMissingCover: entry.hasMissingCover,
        hasMissingMetadata: entry.hasMissingMetadata,
        hasKeyMarker: accessors.keyComic(entry),
        hasSlabMarker:
          accessors.rawOrSlabbed(entry) != null ||
          accessors.gradingCompany(entry) != null,
        hasNotesMarker: entry.notes != null && entry.notes!.trim().isNotEmpty,
      ),
    LibraryTableColumn.cover => SizedBox(
        width: 24,
        height: 32,
        child: LibraryCoverImage(
          title: entry.resolvedTitle,
          itemNumber: entry.itemNumber,
          imageUrl: entry.displayCoverUrl,
          ownedItemId: entry.ownedItemId,
        ),
      ),
    LibraryTableColumn.title => Text(
        entry.resolvedTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    LibraryTableColumn.issue => LibraryTableCellText(entry.itemNumber),
    LibraryTableColumn.variant => LibraryTableCellText(
        [
          if (entry.variant != null && entry.variant!.trim().isNotEmpty)
            entry.variant,
          if (entry.referenceScopeLabel != null)
            'Scope: ${entry.referenceScopeLabel!}',
          if (entry.referenceFormatLabel != null)
            'Format: ${entry.referenceFormatLabel!}',
        ].join('  ·  '),
      ),
    LibraryTableColumn.format =>
      LibraryTableCellText(entry.referenceFormatLabel),
    LibraryTableColumn.publisher => LibraryTableCellText(entry.publisher),
    LibraryTableColumn.releaseDate =>
      LibraryTableCellText(formatNullableDate(entry.releaseDate)),
    LibraryTableColumn.barcode => LibraryTableCellText(entry.barcode),
    LibraryTableColumn.grade => LibraryTableCellText(entry.grade),
    LibraryTableColumn.condition => LibraryTableCellText(entry.condition),
    LibraryTableColumn.price =>
      Text(formatMoney(entry.pricePaidCents, entry.currency)),
    LibraryTableColumn.location => LibraryTableCellText(entry.locationPath),
    LibraryTableColumn.wishlist =>
      entry.isWishlisted ? const Icon(Icons.star, size: 18) : const Text(''),
    LibraryTableColumn.added => Text(
        formatDate(entry.addedAt ?? entry.updatedAt),
        style: const TextStyle(fontSize: 12),
      ),
    LibraryTableColumn.updated => Text(
        formatDate(entry.updatedAt),
        style: const TextStyle(fontSize: 12),
      ),
    LibraryTableColumn.country => LibraryTableCellText(accessors.country(entry)),
    LibraryTableColumn.language => LibraryTableCellText(accessors.language(entry)),
    LibraryTableColumn.pageCount =>
      LibraryTableCellText(entry.publishing?.pageCount?.toString()),
    LibraryTableColumn.ageRating => LibraryTableCellText(accessors.ageRating(entry)),
    LibraryTableColumn.imprint =>
      LibraryTableCellText(entry.publishing?.imprint),
  };
}

int plannedMediaCompareEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) {
  return comparePlannedMediaEntriesByColumn(
    left,
    right,
    column,
    plannedDefaultEntryAccessors,
  );
}

int comparePlannedMediaEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
  PlannedMediaEntryAccessors accessors,
) {
  return switch (column) {
    LibrarySortColumn.status => _compareBools(left.isOwned, right.isOwned),
    LibrarySortColumn.title =>
      _compareNullableStrings(left.resolvedTitle, right.resolvedTitle),
    LibrarySortColumn.series =>
      _compareNullableStrings(accessors.series(left), accessors.series(right)),
    LibrarySortColumn.issue => _compareIssueNumbers(left.itemNumber, right.itemNumber),
    LibrarySortColumn.storyArc => _compareNullableStrings(
        accessors.storyArc(left),
        accessors.storyArc(right),
      ),
    LibrarySortColumn.variant =>
      _compareNullableStrings(left.variant, right.variant),
    LibrarySortColumn.format => _compareNullableStrings(
        left.referenceFormatLabel,
        right.referenceFormatLabel,
      ),
    LibrarySortColumn.publisher =>
      _compareNullableStrings(left.publisher, right.publisher),
    LibrarySortColumn.releaseDate =>
      _compareNullableDates(left.releaseDate, right.releaseDate),
    LibrarySortColumn.barcode =>
      _compareNullableStrings(left.barcode, right.barcode),
    LibrarySortColumn.grade => _compareNullableStrings(left.grade, right.grade),
    LibrarySortColumn.rawOrSlabbed =>
      _compareNullableStrings(accessors.rawOrSlabbed(left), accessors.rawOrSlabbed(right)),
    LibrarySortColumn.gradingCompany =>
      _compareNullableStrings(accessors.gradingCompany(left), accessors.gradingCompany(right)),
    LibrarySortColumn.condition =>
      _compareNullableStrings(left.condition, right.condition),
    LibrarySortColumn.price =>
      _compareNullableInts(left.pricePaidCents, right.pricePaidCents),
    LibrarySortColumn.location =>
      _compareNullableStrings(left.locationPath, right.locationPath),
    LibrarySortColumn.collectionStatus =>
      _compareNullableStrings(left.collectionStatus, right.collectionStatus),
    LibrarySortColumn.wishlist => _compareBools(left.isWishlisted, right.isWishlisted),
    LibrarySortColumn.keyComic => _compareBools(accessors.keyComic(left), accessors.keyComic(right)),
    LibrarySortColumn.added =>
      _compareNullableDates(left.addedAt, right.addedAt),
    LibrarySortColumn.updated => left.updatedAt.compareTo(right.updatedAt),
    LibrarySortColumn.country =>
      _compareNullableStrings(accessors.country(left), accessors.country(right)),
    LibrarySortColumn.language =>
      _compareNullableStrings(accessors.language(left), accessors.language(right)),
    LibrarySortColumn.pageCount =>
      _compareNullableInts(accessors.pageCount(left), accessors.pageCount(right)),
    LibrarySortColumn.ageRating =>
      _compareNullableStrings(accessors.ageRating(left), accessors.ageRating(right)),
    LibrarySortColumn.imprint =>
      _compareNullableStrings(accessors.imprint(left), accessors.imprint(right)),
  };
}

int compareBookEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) => comparePlannedMediaEntriesByColumn(
  left,
  right,
  column,
  plannedBookEntryAccessors,
);

int compareGameEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) => comparePlannedMediaEntriesByColumn(
  left,
  right,
  column,
  plannedGameEntryAccessors,
);

int compareBoardGameEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) => comparePlannedMediaEntriesByColumn(
  left,
  right,
  column,
  plannedBoardGameEntryAccessors,
);

int compareMovieEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) => comparePlannedMediaEntriesByColumn(
  left,
  right,
  column,
  plannedMovieEntryAccessors,
);

int compareMusicEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) => comparePlannedMediaEntriesByColumn(
  left,
  right,
  column,
  plannedMusicEntryAccessors,
);

class PlannedMediaEntryAccessors {
  const PlannedMediaEntryAccessors({
    required this.series,
    required this.storyArc,
    required this.country,
    required this.language,
    required this.pageCount,
    required this.ageRating,
    required this.imprint,
    required this.creators,
    required this.characters,
    required this.storyArcs,
    required this.genres,
    required this.rawPlatforms,
    required this.keyComic,
    required this.rawOrSlabbed,
    required this.gradingCompany,
  });

  final String? Function(LibraryWorkspaceEntry entry) series;
  final String? Function(LibraryWorkspaceEntry entry) storyArc;
  final String? Function(LibraryWorkspaceEntry entry) country;
  final String? Function(LibraryWorkspaceEntry entry) language;
  final int? Function(LibraryWorkspaceEntry entry) pageCount;
  final String? Function(LibraryWorkspaceEntry entry) ageRating;
  final String? Function(LibraryWorkspaceEntry entry) imprint;
  final List<Map<String, dynamic>>? Function(LibraryWorkspaceEntry entry) creators;
  final List<String>? Function(LibraryWorkspaceEntry entry) characters;
  final List<String>? Function(LibraryWorkspaceEntry entry) storyArcs;
  final List<String>? Function(LibraryWorkspaceEntry entry) genres;
  final List<String>? Function(LibraryWorkspaceEntry entry) rawPlatforms;
  final bool Function(LibraryWorkspaceEntry entry) keyComic;
  final String? Function(LibraryWorkspaceEntry entry) rawOrSlabbed;
  final String? Function(LibraryWorkspaceEntry entry) gradingCompany;
}

final plannedDefaultEntryAccessors = PlannedMediaEntryAccessors(
  series: (entry) => entry.series?.seriesTitle,
  storyArc: (entry) => _firstStringValue(libraryEntryStoryArcs(entry)),
  country: libraryEntryCountry,
  language: libraryEntryLanguage,
  pageCount: (entry) => entry.publishing?.pageCount,
  ageRating: libraryEntryAgeRating,
  imprint: (entry) => entry.publishing?.imprint,
  creators: libraryEntryCreators,
  characters: libraryEntryCharacters,
  storyArcs: libraryEntryStoryArcs,
  genres: libraryEntryGenres,
  rawPlatforms: libraryEntryRawPlatforms,
  keyComic: (_) => false,
  rawOrSlabbed: (_) => null,
  gradingCompany: (_) => null,
);

final plannedComicEntryAccessors = PlannedMediaEntryAccessors(
  series: (entry) => entry.series?.seriesTitle,
  storyArc: (entry) => _firstStringValue(libraryEntryStoryArcs(entry)),
  country: libraryEntryCountry,
  language: libraryEntryLanguage,
  pageCount: (entry) => entry.publishing?.pageCount,
  ageRating: libraryEntryAgeRating,
  imprint: (entry) => entry.publishing?.imprint,
  creators: libraryEntryCreators,
  characters: libraryEntryCharacters,
  storyArcs: libraryEntryStoryArcs,
  genres: libraryEntryGenres,
  rawPlatforms: libraryEntryRawPlatforms,
  keyComic: (entry) => entry.comic?.keyComic ?? false,
  rawOrSlabbed: (entry) => entry.comic?.rawOrSlabbed,
  gradingCompany: (entry) => entry.comic?.gradingCompany,
);

final plannedBookEntryAccessors = plannedDefaultEntryAccessors;
final plannedGameEntryAccessors = plannedDefaultEntryAccessors;
final plannedBoardGameEntryAccessors = plannedDefaultEntryAccessors;
final plannedMovieEntryAccessors = plannedDefaultEntryAccessors;
final plannedMusicEntryAccessors = plannedDefaultEntryAccessors;

LibraryEntryFilterValues plannedMediaFilterValuesForEntry(
  LibraryWorkspaceEntry entry,
  PlannedMediaEntryAccessors accessors,
) {
  return LibraryEntryFilterValues(
    series: _trimmedOrNull(entry.series?.seriesTitle),
    country: _trimmedOrNull(accessors.country(entry)),
    language: _trimmedOrNull(accessors.language(entry)),
  );
}

Iterable<String> plannedMediaLinkedMetadataCandidatesForEntry(
  LibraryWorkspaceEntry entry,
  PlannedMediaEntryAccessors accessors,
) sync* {
  final filterValues = plannedMediaFilterValuesForEntry(entry, accessors);
  final publishing = entry.publishing;
  yield* _nonEmptyValues([
    entry.resolvedTitle,
    entry.title,
    entry.localizedTitle,
    entry.originalTitle,
    filterValues.series,
    entry.itemNumber,
    entry.publisher,
    entry.variant,
    publishing?.imprint,
    publishing?.seriesGroup,
    filterValues.country,
    filterValues.language,
    accessors.ageRating(entry),
  ]);
  yield* _nonEmptyValues(entry.searchAliases);
  if (accessors.creators(entry) case final creators?) {
    for (final credit in creators) {
      final name = credit['name']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        yield name.trim();
      }
    }
  }
  yield* _nonEmptyValues(accessors.characters(entry));
  yield* _nonEmptyValues(accessors.storyArcs(entry));
  yield* _nonEmptyValues(accessors.genres(entry));
  if (accessors.rawPlatforms(entry) case final platforms?) {
    yield* _nonEmptyValues(platforms);
  }
}

String? plannedMediaSubgroupKeyForEntry(
  LibraryWorkspaceEntry entry,
  LibraryGroupMode groupMode,
) {
  if (groupMode != LibraryGroupMode.series) {
    return null;
  }
  final series = entry.series;
  if (series?.seasonNumber != null) {
    return 'Season ${series!.seasonNumber}';
  }
  if (series?.volumeName != null && series!.volumeName!.trim().isNotEmpty) {
    return series.volumeName!.trim();
  }
  if (series?.volumeNumber != null) {
    return 'Vol. ${series!.volumeNumber}';
  }
  return null;
}

int plannedMediaCompareSubgroupKeys(
  String left,
  String right,
  LibraryGroupMode groupMode,
) {
  if (groupMode != LibraryGroupMode.series) {
    return left.compareTo(right);
  }
  final leftNumber = _extractSubgroupNumber(left);
  final rightNumber = _extractSubgroupNumber(right);
  if (leftNumber != null && rightNumber != null) {
    return leftNumber.compareTo(rightNumber);
  }
  return left.compareTo(right);
}

int _compareIssueNumbers(String? left, String? right) {
  final leftNumber = _numericPrefixSortValue(left);
  final rightNumber = _numericPrefixSortValue(right);
  if (leftNumber != null && rightNumber != null) {
    final numeric = leftNumber.compareTo(rightNumber);
    if (numeric != 0) {
      return numeric;
    }
  }
  if (leftNumber != null) {
    return -1;
  }
  if (rightNumber != null) {
    return 1;
  }
  return _compareNullableStrings(left, right);
}

double? _numericPrefixSortValue(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final match = RegExp(r'^\s*(\d+(?:\.\d+)?)').firstMatch(value);
  return match == null ? null : double.tryParse(match.group(1)!);
}

String? _firstStringValue(List<String>? values) {
  if (values == null) {
    return null;
  }
  for (final value in values) {
    final normalized = value.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }
  return null;
}

int _compareNullableStrings(String? left, String? right) {
  final leftValue = left?.toLowerCase() ?? '';
  final rightValue = right?.toLowerCase() ?? '';
  if (leftValue.isEmpty && rightValue.isNotEmpty) {
    return 1;
  }
  if (leftValue.isNotEmpty && rightValue.isEmpty) {
    return -1;
  }
  return leftValue.compareTo(rightValue);
}

int _compareNullableInts(int? left, int? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? 0).compareTo(right ?? 0);
}

int _compareNullableDates(DateTime? left, DateTime? right) {
  if (left == null && right != null) {
    return 1;
  }
  if (left != null && right == null) {
    return -1;
  }
  return (left ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
    right ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

int _compareBools(bool left, bool right) {
  if (left == right) {
    return 0;
  }
  return left ? -1 : 1;
}

String? _trimmedOrNull(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

Iterable<String> _nonEmptyValues(Iterable<String?>? values) sync* {
  if (values == null) {
    return;
  }
  for (final value in values) {
    final trimmed = _trimmedOrNull(value);
    if (trimmed != null) {
      yield trimmed;
    }
  }
}

int? _extractSubgroupNumber(String value) {
  final match = RegExp(r'(\d+)').firstMatch(value);
  return match == null ? null : int.tryParse(match.group(1)!);
}
