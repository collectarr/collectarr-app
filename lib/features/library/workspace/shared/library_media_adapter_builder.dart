import 'package:collectarr_app/core/models/catalog_item.dart';
import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
  final viewProfile = plannedMediaWorkspaceViewProfile(type);
  return LibraryMediaAdapter(
    type: type,
    viewProfile: viewProfile,
    orderedTableColumns: (columns) => orderedLibraryTableColumns(
      columns: columns,
      defaultColumns: type.defaultVisibleColumns,
    ),
    tableWidthForColumns: (columns, customWidths) =>
        plannedMediaTableWidthForColumns(
      type: type,
      columns: columns,
      customWidths: customWidths,
    ),
    tableColumnWidth: (column, customWidths) =>
        plannedMediaTableColumnWidth(type, column, customWidths),
    defaultTableColumnWidth: (column) =>
        defaultPlannedMediaTableColumnWidth(type, column),
    columnLabel: (column) => plannedMediaTableColumnLabelForType(type, column),
    columnDisplayName: (column) =>
        plannedMediaTableColumnDisplayNameForType(type, column),
    columnGroup: (column) => plannedMediaTableColumnGroup(type, column),
    columnGroupLabel: plannedMediaTableColumnGroupLabel,
    columnIsNumeric: (column) => plannedMediaTableColumnIsNumeric(type, column),
    columnSort: (column) => plannedMediaTableColumnSort(type, column),
    tableCellBuilder: (entry, column) =>
        plannedMediaTableCell(type, entry, column),
    compareEntriesByColumn: compareEntriesByColumn ??
        (left, right, column) =>
            libraryKindModuleForType(type).fields.sortDefinitionFor(column.toString()).compare(
                  left,
                  right,
                ),
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
  LibraryTypeConfig type,
) {
  final coverGridHeightFactor = switch (type.workspace.kind) {
    CatalogMediaKind.music => 1.0,
    _ => 1.53,
  };
  return LibraryWorkspaceViewProfile(
    type: type,
    defaultCoverSize: kPlannedMediaDefaultCoverSize,
    minCoverSize: kPlannedMediaMinCoverSize,
    maxCoverSize: kPlannedMediaMaxCoverSize,
    coverGridHeightFactor: coverGridHeightFactor,
    presetConfig: plannedMediaViewPresetConfig,
    clampColumnWidth: (column, width) =>
        clampPlannedMediaTableColumnWidth(type, column, width),
    defaultDetailsLayout: LibraryDetailsLayout.bottom,
    sortAscendingForColumn: (column) =>
        libraryKindModuleForType(type).fields.sortDefinitionFor(column.toString()).defaultAscending,
  );
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
          'status',
          'cover',
          'title',
          'publisher',
          'releaseDate',
        },
      ),
    LibraryWorkspacePreset.card => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.card,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 150,
        visibleColumns: {
          'status',
          'cover',
          'title',
          'publisher',
          'releaseDate',
          'condition',
        },
      ),
    LibraryWorkspacePreset.list => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: kPlannedMediaDefaultCoverSize,
        visibleColumns: {
          'status',
          'title',
          'format',
          'publisher',
          'releaseDate',
          'condition',
          'price',
          'location',
          'added',
        },
      ),
    LibraryWorkspacePreset.details => const LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 144,
        visibleColumns: {
          'status',
          'cover',
          'title',
          'publisher',
          'releaseDate',
          'barcode',
          'condition',
          'price',
        },
      ),
  };
}

int plannedMediaCompareEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  Object column,
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
  Object groupMode,
) {
  if (groupMode != 'series') {
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
  Object groupMode,
) {
  if (groupMode != 'series') {
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
  Object column,
) {
  return switch (column.toString()) {
    'status' => _compareBools(left.isOwned, right.isOwned),
    'title' =>
      _compareNullableStrings(left.resolvedTitle, right.resolvedTitle),
    'series' => _compareNullableStrings(
        left.series?.seriesTitle,
        right.series?.seriesTitle,
      ),
    'issue' =>
      _compareIssueNumbers(left.itemNumber, right.itemNumber),
    'storyArc' => _compareNullableStrings(
        _firstStringValue(left.storyArcs),
        _firstStringValue(right.storyArcs),
      ),
    'variant' =>
      _compareNullableStrings(left.variant, right.variant),
    'format' => _compareNullableStrings(
        left.referenceFormatLabel,
        right.referenceFormatLabel,
      ),
    'publisher' =>
      _compareNullableStrings(left.publisher, right.publisher),
    'releaseDate' =>
      _compareNullableDates(left.releaseDate, right.releaseDate),
    'barcode' =>
      _compareNullableStrings(left.barcode, right.barcode),
    'grade' => _compareNullableStrings(left.grade, right.grade),
    'rawOrSlabbed' =>
      _compareNullableStrings(left.comic?.rawOrSlabbed, right.comic?.rawOrSlabbed),
    'gradingCompany' => _compareNullableStrings(
        left.comic?.gradingCompany,
        right.comic?.gradingCompany,
      ),
    'condition' =>
      _compareNullableStrings(left.condition, right.condition),
    'price' =>
      _compareNullableInts(left.pricePaidCents, right.pricePaidCents),
    'location' =>
      _compareNullableStrings(left.locationPath, right.locationPath),
    'collectionStatus' =>
      _compareNullableStrings(left.collectionStatus, right.collectionStatus),
    'wishlist' =>
      _compareBools(left.isWishlisted, right.isWishlisted),
    'keyComic' =>
      _compareBools(left.comic?.keyComic ?? false, right.comic?.keyComic ?? false),
    'added' =>
      _compareNullableDates(left.addedAt, right.addedAt),
    'updated' => left.updatedAt.compareTo(right.updatedAt),
    'country' =>
      _compareNullableStrings(left.country, right.country),
    'language' =>
      _compareNullableStrings(left.language, right.language),
    'pageCount' => _compareNullableInts(
        left.publishing?.pageCount,
        right.publishing?.pageCount,
      ),
    'ageRating' =>
      _compareNullableStrings(left.ageRating, right.ageRating),
    'imprint' =>
      _compareNullableStrings(left.publishing?.imprint, right.publishing?.imprint),
    String() => left.resolvedTitle.toLowerCase().compareTo(
        right.resolvedTitle.toLowerCase(),
      ),
  };
}

int compareBookEntriesByColumn(
  LibraryWorkspaceEntry left,
  LibraryWorkspaceEntry right,
  Object column,
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
