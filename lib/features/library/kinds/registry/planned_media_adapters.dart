import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/kinds/boardgame/config.dart';
import 'package:collectarr_app/features/library/kinds/book/config.dart';
import 'package:collectarr_app/features/library/kinds/game/config.dart';
import 'package:collectarr_app/features/library/kinds/movie/config.dart';
import 'package:collectarr_app/features/library/kinds/music/config.dart';
import 'package:collectarr_app/features/library/workspace/library_cover_image.dart';
import 'package:collectarr_app/features/library/workspace/library_item_badges.dart';
import 'package:collectarr_app/features/library/workspace/library_table_cell.dart';
import 'package:collectarr_app/features/library/workspace/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

final booksMediaAdapter = plannedMediaAdapter(booksLibraryConfig);
final gamesMediaAdapter = plannedMediaAdapter(gamesLibraryConfig);
final boardGamesMediaAdapter = plannedMediaAdapter(boardGamesLibraryConfig);
final moviesMediaAdapter = plannedMediaAdapter(moviesLibraryConfig);
final musicMediaAdapter = plannedMediaAdapter(musicLibraryConfig);

final plannedMediaAdapters = LibraryMediaAdapterRegistry([
  booksMediaAdapter,
  gamesMediaAdapter,
  boardGamesMediaAdapter,
  moviesMediaAdapter,
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
    tableCellBuilder: plannedMediaTableCell,
    compareEntriesByColumn: plannedMediaCompareEntriesByColumn,
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
          LibraryTableColumn.publisher,
          LibraryTableColumn.releaseDate,
          LibraryTableColumn.condition,
          LibraryTableColumn.price,
          LibraryTableColumn.location,
          LibraryTableColumn.updated,
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
    LibraryTableColumn.publisher => 150.0,
    LibraryTableColumn.releaseDate => 118.0,
    LibraryTableColumn.barcode => 160.0,
    LibraryTableColumn.grade => 88.0,
    LibraryTableColumn.condition => 124.0,
    LibraryTableColumn.price => 92.0,
    LibraryTableColumn.location => 118.0,
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
    LibraryTableColumn.location => 'Location',
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
    LibraryTableColumn.publisher => LibrarySortColumn.publisher,
    LibraryTableColumn.releaseDate => LibrarySortColumn.releaseDate,
    LibraryTableColumn.barcode => LibrarySortColumn.barcode,
    LibraryTableColumn.grade => LibrarySortColumn.grade,
    LibraryTableColumn.condition => LibrarySortColumn.condition,
    LibraryTableColumn.price => LibrarySortColumn.price,
    LibraryTableColumn.location => LibrarySortColumn.location,
    LibraryTableColumn.wishlist => LibrarySortColumn.wishlist,
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
) {
  return switch (column) {
    LibraryTableColumn.status => LibraryItemStatusIcons(
        isOwned: entry.isOwned,
        isTracked: entry.isTracked,
        isWishlisted: entry.isWishlisted,
        hasMissingCover: entry.hasMissingCover,
        hasMissingMetadata: entry.hasMissingMetadata,
        hasKeyMarker: entry.keyComic,
        hasSlabMarker:
            entry.rawOrSlabbed != null || entry.gradingCompany != null,
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
    LibraryTableColumn.updated => Text(
        formatDate(entry.updatedAt),
        style: const TextStyle(fontSize: 12),
      ),
    LibraryTableColumn.country => LibraryTableCellText(entry.country),
    LibraryTableColumn.language => LibraryTableCellText(entry.language),
    LibraryTableColumn.pageCount =>
      LibraryTableCellText(entry.publishing?.pageCount?.toString()),
    LibraryTableColumn.ageRating => LibraryTableCellText(entry.ageRating),
    LibraryTableColumn.imprint =>
      LibraryTableCellText(entry.publishing?.imprint),
  };
}

int plannedMediaCompareEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) {
  return switch (column) {
    LibrarySortColumn.status => _compareBools(left.isOwned, right.isOwned),
    LibrarySortColumn.title =>
      _compareNullableStrings(left.resolvedTitle, right.resolvedTitle),
    LibrarySortColumn.series =>
      _compareNullableStrings(left.series?.seriesTitle, right.series?.seriesTitle),
    LibrarySortColumn.issue => _compareIssueNumbers(left.itemNumber, right.itemNumber),
    LibrarySortColumn.storyArc => _compareNullableStrings(
        _firstStringValue(left.storyArcs),
        _firstStringValue(right.storyArcs),
      ),
    LibrarySortColumn.variant =>
      _compareNullableStrings(left.variant, right.variant),
    LibrarySortColumn.publisher =>
      _compareNullableStrings(left.publisher, right.publisher),
    LibrarySortColumn.releaseDate =>
      _compareNullableDates(left.releaseDate, right.releaseDate),
    LibrarySortColumn.barcode =>
      _compareNullableStrings(left.barcode, right.barcode),
    LibrarySortColumn.grade => _compareNullableStrings(left.grade, right.grade),
    LibrarySortColumn.rawOrSlabbed =>
      _compareNullableStrings(left.rawOrSlabbed, right.rawOrSlabbed),
    LibrarySortColumn.gradingCompany =>
      _compareNullableStrings(left.gradingCompany, right.gradingCompany),
    LibrarySortColumn.condition =>
      _compareNullableStrings(left.condition, right.condition),
    LibrarySortColumn.price =>
      _compareNullableInts(left.pricePaidCents, right.pricePaidCents),
    LibrarySortColumn.location =>
      _compareNullableStrings(left.locationPath, right.locationPath),
    LibrarySortColumn.collectionStatus =>
      _compareNullableStrings(left.collectionStatus, right.collectionStatus),
    LibrarySortColumn.wishlist => _compareBools(left.isWishlisted, right.isWishlisted),
    LibrarySortColumn.keyComic => _compareBools(left.keyComic, right.keyComic),
    LibrarySortColumn.updated => left.updatedAt.compareTo(right.updatedAt),
    LibrarySortColumn.country =>
      _compareNullableStrings(left.country, right.country),
    LibrarySortColumn.language =>
      _compareNullableStrings(left.language, right.language),
    LibrarySortColumn.pageCount =>
      _compareNullableInts(left.publishing?.pageCount, right.publishing?.pageCount),
    LibrarySortColumn.ageRating =>
      _compareNullableStrings(left.ageRating, right.ageRating),
    LibrarySortColumn.imprint =>
      _compareNullableStrings(left.publishing?.imprint, right.publishing?.imprint),
  };
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
