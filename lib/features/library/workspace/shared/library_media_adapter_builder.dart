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
      columns: columns.cast<String>().toSet(),
      customWidths: customWidths.cast<String, double>(),
    ),
    tableColumnWidth: (column, customWidths) =>
        plannedMediaTableColumnWidth(type, column as String, customWidths.cast<String, double>()),
    defaultTableColumnWidth: (column) =>
        defaultPlannedMediaTableColumnWidth(type, column as String),
    columnLabel: (column) => plannedMediaTableColumnLabelForType(type, column as String),
    columnDisplayName: (column) =>
        plannedMediaTableColumnDisplayNameForType(type, column as String),
    columnGroup: (column) => plannedMediaTableColumnGroup(type, column as String),
    columnGroupLabel: plannedMediaTableColumnGroupLabel,
    columnIsNumeric: (column) => plannedMediaTableColumnIsNumeric(type, column as String),
    columnSort: (column) => plannedMediaTableColumnSort(type, column as String),
    tableCellBuilder: (entry, column) =>
        plannedMediaTableCell(type, entry, column as String),
    compareEntriesByColumn: compareEntriesByColumn ??
        (left, right, column) =>
            libraryKindModuleForType(type).fields.sortDefinitionFor(column.toString()).compare(
                  left,
                  right,
                ),
    entryFilterValuesBuilder: plannedMediaFilterValuesForEntry,
    entryLinkedMetadataCandidatesBuilder: (entry) =>
        plannedMediaLinkedMetadataCandidatesForEntry(type, entry),
    entrySubgroupKeyBuilder: (entry, groupMode) =>
        plannedMediaSubgroupKeyForEntry(type, entry, groupMode),
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
  final coverGridHeightFactor = type.capabilities.prefersSquareCovers ? 1.0 : 1.53;
  return LibraryWorkspaceViewProfile(
    type: type,
    defaultCoverSize: kPlannedMediaDefaultCoverSize,
    minCoverSize: kPlannedMediaMinCoverSize,
    maxCoverSize: kPlannedMediaMaxCoverSize,
    coverGridHeightFactor: coverGridHeightFactor,
    presetConfig: plannedMediaViewPresetConfig,
    clampColumnWidth: (column, width) =>
        clampPlannedMediaTableColumnWidth(type, column as String, width),
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
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
) {
  final registry = libraryKindModuleForType(type).fields;
  return registry.linkedMetadataCandidates(entry);
}

String? plannedMediaSubgroupKeyForEntry(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
  Object groupMode,
) {
  if (groupMode != 'series') {
    return null;
  }
  if (!type.capabilities.supportsSeriesSubgroups) {
    return null;
  }
  if (type.capabilities.contentHierarchy == LibraryContentHierarchy.flat) {
    return null;
  }
  final series = entry.series;
  if (type.capabilities.usesSeasonHierarchy && series?.seasonNumber != null) {
    return 'Season ${series!.seasonNumber}';
  }
  if (type.capabilities.usesVolumeHierarchy) {
    if (series?.volumeName != null && series!.volumeName!.trim().isNotEmpty) {
      return series.volumeName!.trim();
    }
    if (series?.volumeNumber != null) {
      return libraryVolumeLabel(series!.volumeNumber);
    }
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





String? _trimmedOrNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
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
