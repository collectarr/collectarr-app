import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';

import 'package:collectarr_app/features/library/shared/table/media_table_columns.dart';

export 'package:collectarr_app/features/library/shared/table/media_table_columns.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

LibraryMediaAdapter plannedMediaAdapter(
  LibraryTypeConfig type, {
  LibraryEntryColumnComparator? compareEntriesByColumn,
  LibraryWorkspaceCardBuilder? workspaceCardBuilder,
}) {
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
    compareEntriesByColumn:
        compareEntriesByColumn ?? comparePlannedMediaEntriesByColumn,
    entryFilterValuesBuilder: plannedMediaFilterValuesForEntry,
    entryLinkedMetadataCandidatesBuilder:
        plannedMediaLinkedMetadataCandidatesForEntry,
    entrySubgroupKeyBuilder: plannedMediaSubgroupKeyForEntry,
    compareSubgroupKeys: plannedMediaCompareSubgroupKeys,
    workspaceCardBuilder: workspaceCardBuilder,
  );
}

LibraryMediaAdapter collectarrMediaAdapter(
  LibraryTypeConfig type, {
  LibraryEntryColumnComparator? compareEntriesByColumn,
}) {
  return plannedMediaAdapter(
    type,
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
  return comparePlannedMediaEntriesByColumn(left, right, column);
}

LibraryEntryFilterValues plannedMediaFilterValuesForEntry(
  LibraryWorkspaceEntry entry,
) {
  return LibraryEntryFilterValues(
    series: _trimmedOrNull(entry.series?.seriesTitle),
    country: _trimmedOrNull(entry.country),
    language: _trimmedOrNull(entry.language),
  );
}

Iterable<String> plannedMediaLinkedMetadataCandidatesForEntry(
  LibraryWorkspaceEntry entry,
) sync* {
  final filterValues = plannedMediaFilterValuesForEntry(entry);
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
    entry.music?.catalogNumber,
    filterValues.country,
    filterValues.language,
    entry.ageRating,
    entry.music?.vinylColor,
    entry.music?.rpm?.toString(),
  ]);
  yield* _nonEmptyValues(entry.searchAliases);
  if (entry.creators case final creators?) {
    for (final credit in creators) {
      final name = credit['name']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        yield name.trim();
      }
    }
  }
  yield* _nonEmptyValues(entry.characters);
  yield* _nonEmptyValues(entry.storyArcs);
  yield* _nonEmptyValues(entry.genres);
  if (entry.game?.platforms case final platforms?) {
    yield* _nonEmptyValues(platforms);
  } else {
    yield* _nonEmptyValues(entry.rawPlatforms);
  }
}

String? plannedMediaSubgroupKeyForEntry(
  LibraryWorkspaceEntry entry,
  LibraryGroupMode groupMode,
) {
  if (groupMode != LibraryGroupMode.series) {
    return null;
  }
  if (entry.mediaType.trim().toLowerCase() == 'book') {
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
    return libraryVolumeLabel(series!.volumeNumber);
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

int comparePlannedMediaEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) {
  return switch (column) {
    LibrarySortColumn.status => _compareBools(left.isOwned, right.isOwned),
    LibrarySortColumn.title =>
      _compareNullableStrings(left.resolvedTitle, right.resolvedTitle),
    LibrarySortColumn.series => _compareNullableStrings(
        left.series?.seriesTitle,
        right.series?.seriesTitle,
      ),
    LibrarySortColumn.issue =>
      _compareIssueNumbers(left.itemNumber, right.itemNumber),
    LibrarySortColumn.storyArc => _compareNullableStrings(
        _firstStringValue(left.storyArcs),
        _firstStringValue(right.storyArcs),
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
      _compareNullableStrings(left.comic?.rawOrSlabbed, right.comic?.rawOrSlabbed),
    LibrarySortColumn.gradingCompany => _compareNullableStrings(
        left.comic?.gradingCompany,
        right.comic?.gradingCompany,
      ),
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
      _compareBools(left.comic?.keyComic ?? false, right.comic?.keyComic ?? false),
    LibrarySortColumn.added =>
      _compareNullableDates(left.addedAt, right.addedAt),
    LibrarySortColumn.updated => left.updatedAt.compareTo(right.updatedAt),
    LibrarySortColumn.country =>
      _compareNullableStrings(left.country, right.country),
    LibrarySortColumn.language =>
      _compareNullableStrings(left.language, right.language),
    LibrarySortColumn.pageCount => _compareNullableInts(
        left.publishing?.pageCount,
        right.publishing?.pageCount,
      ),
    LibrarySortColumn.ageRating =>
      _compareNullableStrings(left.ageRating, right.ageRating),
    LibrarySortColumn.imprint =>
      _compareNullableStrings(left.publishing?.imprint, right.publishing?.imprint),
  };
}

int compareBookEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  LibrarySortColumn column,
) =>
    comparePlannedMediaEntriesByColumn(left, right, column);

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

String? _trimmedOrNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

Iterable<String> _nonEmptyValues(Iterable<String?>? values) sync* {
  if (values == null) {
    return;
  }
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      yield trimmed;
    }
  }
}

String? _firstStringValue(List<String>? values) {
  if (values == null) {
    return null;
  }
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

int? _extractSubgroupNumber(String? value) {
  if (value == null) {
    return null;
  }
  final match = RegExp(r'(\d+)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}
