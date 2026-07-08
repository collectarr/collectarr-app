import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';

import 'media_entry_accessors.dart';
import 'package:collectarr_app/features/library/shared/table/media_table_columns.dart';

export 'media_entry_accessors.dart';
export 'package:collectarr_app/features/library/shared/table/media_table_columns.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

LibraryMediaAdapter plannedMediaAdapter(
  LibraryTypeConfig type, {
  PlannedMediaEntryAccessors? entryAccessors,
  LibraryEntryColumnComparator? compareEntriesByColumn,
  LibraryWorkspaceCardBuilder? workspaceCardBuilder,
}) {
  final resolvedEntryAccessors = entryAccessors ?? defaultEntryAccessors;
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
        (left, right, column) => comparePlannedMediaEntriesByColumn(
              left,
              right,
              column,
              resolvedEntryAccessors,
            ),
    entryFilterValuesBuilder: (entry) =>
        plannedMediaFilterValuesForEntry(entry, resolvedEntryAccessors),
    entryLinkedMetadataCandidatesBuilder: (entry) =>
        plannedMediaLinkedMetadataCandidatesForEntry(
            entry, resolvedEntryAccessors),
    entrySubgroupKeyBuilder: plannedMediaSubgroupKeyForEntry,
    compareSubgroupKeys: plannedMediaCompareSubgroupKeys,
    workspaceCardBuilder: workspaceCardBuilder,
  );
}

LibraryMediaAdapter collectarrMediaAdapter(
  LibraryTypeConfig type, {
  PlannedMediaEntryAccessors? entryAccessors,
  LibraryEntryColumnComparator? compareEntriesByColumn,
}) {
  return plannedMediaAdapter(
    type,
    entryAccessors: entryAccessors,
    compareEntriesByColumn: compareEntriesByColumn,
  );
}

LibraryWorkspaceViewProfile plannedMediaWorkspaceViewProfile(
  LibraryWorkspaceConfig config,
) {
  final coverGridHeightFactor = switch (config.kind) {
    CatalogMediaKind.music => 1.0,
    _ => 1.53,
  };
  return LibraryWorkspaceViewProfile(
    config: config,
    defaultCoverSize: kPlannedMediaDefaultCoverSize,
    minCoverSize: kPlannedMediaMinCoverSize,
    maxCoverSize: kPlannedMediaMaxCoverSize,
    coverGridHeightFactor: coverGridHeightFactor,
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

int plannedMediaCompareEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) {
  return comparePlannedMediaEntriesByColumn(
    left,
    right,
    column,
    defaultEntryAccessors,
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
    LibrarySortColumn.issue =>
      _compareIssueNumbers(left.itemNumber, right.itemNumber),
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
    LibrarySortColumn.rawOrSlabbed => _compareNullableStrings(
        accessors.rawOrSlabbed(left), accessors.rawOrSlabbed(right)),
    LibrarySortColumn.gradingCompany => _compareNullableStrings(
        accessors.gradingCompany(left), accessors.gradingCompany(right)),
    LibrarySortColumn.condition =>
      _compareNullableStrings(left.condition, right.condition),
    LibrarySortColumn.price =>
      _compareNullableInts(left.pricePaidCents, right.pricePaidCents),
    LibrarySortColumn.location =>
      _compareNullableStrings(left.locationPath, right.locationPath),
    LibrarySortColumn.collectionStatus =>
      _compareNullableStrings(left.collectionStatus, right.collectionStatus),
    LibrarySortColumn.wishlist =>
      _compareBools(left.isWishlisted, right.isWishlisted),
    LibrarySortColumn.keyComic =>
      _compareBools(accessors.keyComic(left), accessors.keyComic(right)),
    LibrarySortColumn.added =>
      _compareNullableDates(left.addedAt, right.addedAt),
    LibrarySortColumn.updated => left.updatedAt.compareTo(right.updatedAt),
    LibrarySortColumn.country => _compareNullableStrings(
        accessors.country(left), accessors.country(right)),
    LibrarySortColumn.language => _compareNullableStrings(
        accessors.language(left), accessors.language(right)),
    LibrarySortColumn.pageCount => _compareNullableInts(
        accessors.pageCount(left), accessors.pageCount(right)),
    LibrarySortColumn.ageRating => _compareNullableStrings(
        accessors.ageRating(left), accessors.ageRating(right)),
    LibrarySortColumn.imprint => _compareNullableStrings(
        accessors.imprint(left), accessors.imprint(right)),
  };
}

int compareBookEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) =>
    comparePlannedMediaEntriesByColumn(
      left,
      right,
      column,
      bookEntryAccessors,
    );

int compareGameEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) =>
    comparePlannedMediaEntriesByColumn(
      left,
      right,
      column,
      gameEntryAccessors,
    );

int compareBoardGameEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) =>
    comparePlannedMediaEntriesByColumn(
      left,
      right,
      column,
      boardGameEntryAccessors,
    );

int compareMovieEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) =>
    comparePlannedMediaEntriesByColumn(
      left,
      right,
      column,
      movieEntryAccessors,
    );

int compareMusicEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) =>
    comparePlannedMediaEntriesByColumn(
      left,
      right,
      column,
      musicEntryAccessors,
    );

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
