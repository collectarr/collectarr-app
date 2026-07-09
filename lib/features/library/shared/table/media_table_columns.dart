import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:flutter/material.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

double plannedMediaTableWidthForColumns({
  required LibraryTypeConfig type,
  required Set<Object> columns,
  required Map<Object, double> customWidths,
}) {
  return libraryTableWidthForColumns(
    columns: columns,
    defaultColumns: type.defaultVisibleColumns,
    customWidths: customWidths,
    sizing: (column) => plannedMediaTableColumnSizing(type, column),
    columnSpacing: kPlannedMediaTableColumnSpacing,
    horizontalMargin: kPlannedMediaTableHorizontalMargin,
  );
}

double plannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  Object column,
  Map<Object, double> customWidths,
) {
  return libraryTableColumnWidth(
    column: column,
    customWidths: customWidths,
    sizing: (column) => plannedMediaTableColumnSizing(type, column),
  );
}

double defaultPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  if (definition != null && definition.defaultWidth != null) {
    return definition.defaultWidth!;
  }
  return definition?.isNumeric == true ? 88.0 : 140.0;
}

double minPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  return definition?.minWidth ?? 64.0;
}

double maxPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  return definition?.maxWidth ?? 260.0;
}

LibraryTableColumnSizing plannedMediaTableColumnSizing(
  LibraryTypeConfig type,
  Object column,
) {
  return LibraryTableColumnSizing(
    defaultWidth: defaultPlannedMediaTableColumnWidth(type, column),
    minWidth: minPlannedMediaTableColumnWidth(type, column),
    maxWidth: maxPlannedMediaTableColumnWidth(type, column),
  );
}

double clampPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  Object column,
  double width,
) {
  return clampLibraryTableColumnWidth(
    width,
    plannedMediaTableColumnSizing(type, column),
  );
}

String plannedMediaTableColumnLabelForType(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  if (definition != null) {
    return definition.label;
  }
  return _fallbackLabel(type.tableColumnFieldId(column));
}

String plannedMediaTableColumnDisplayNameForType(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  if (definition != null) {
    return definition.resolvedDisplayName;
  }
  return plannedMediaTableColumnLabelForType(type, column);
}

LibraryTableColumnGroup plannedMediaTableColumnGroup(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  return _tableColumnGroupFor(definition?.group);
}

String plannedMediaTableColumnGroupLabel(LibraryTableColumnGroup group) {
  return switch (group) {
    LibraryTableColumnGroup.main => 'Main',
    LibraryTableColumnGroup.edition => 'Edition',
    LibraryTableColumnGroup.value => 'Value',
    LibraryTableColumnGroup.personal => 'Personal',
  };
}

bool plannedMediaTableColumnIsNumeric(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  return definition?.isNumeric ?? false;
}

Object? plannedMediaTableColumnSort(
  LibraryTypeConfig type,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  if (definition == null || !definition.sortable) {
    return null;
  }
  return definition.sortId ?? definition.id.value;
}

Widget plannedMediaTableCell(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
  Object column,
) {
  final definition = _tableColumnDefinition(type, column);
  if (definition == null) {
    return const LibraryTableCellText('');
  }
  final builder = definition.cellValue;
  if (builder != null) {
    return builder(entry);
  }
  final value = definition.getValue(entry);
  return LibraryTableCellText(value?.toString());
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
    'title' => _compareNullableStrings(left.resolvedTitle, right.resolvedTitle),
    'series' => _compareNullableStrings(
        left.series?.seriesTitle,
        right.series?.seriesTitle,
      ),
    'issue' => _compareIssueNumbers(left.itemNumber, right.itemNumber),
    'storyArc' => _compareNullableStrings(
        _firstDisplayValue(left.storyArcs),
        _firstDisplayValue(right.storyArcs),
      ),
    'variant' => _compareNullableStrings(left.variant, right.variant),
    'format' => _compareNullableStrings(
        left.referenceFormatLabel,
        right.referenceFormatLabel,
      ),
    'publisher' => _compareNullableStrings(left.publisher, right.publisher),
    'releaseDate' => _compareNullableDates(left.releaseDate, right.releaseDate),
    'barcode' => _compareNullableStrings(left.barcode, right.barcode),
    'grade' => _compareNullableStrings(left.grade, right.grade),
    'rawOrSlabbed' => _compareNullableStrings(
        left.comic?.rawOrSlabbed,
        right.comic?.rawOrSlabbed,
      ),
    'gradingCompany' => _compareNullableStrings(
        left.comic?.gradingCompany,
        right.comic?.gradingCompany,
      ),
    'condition' => _compareNullableStrings(left.condition, right.condition),
    'price' => _compareNullableInts(left.pricePaidCents, right.pricePaidCents),
    'location' => _compareNullableStrings(left.locationPath, right.locationPath),
    'collectionStatus' =>
      _compareNullableStrings(left.collectionStatus, right.collectionStatus),
    'wishlist' => _compareBools(left.isWishlisted, right.isWishlisted),
    'keyComic' => _compareBools(
        left.comic?.keyComic ?? false,
        right.comic?.keyComic ?? false,
      ),
    'added' => _compareNullableDates(left.addedAt, right.addedAt),
    'updated' => left.updatedAt.compareTo(right.updatedAt),
    'country' => _compareNullableStrings(left.country, right.country),
    'language' => _compareNullableStrings(left.language, right.language),
    'pageCount' => _compareNullableInts(
        left.publishing?.pageCount,
        right.publishing?.pageCount,
      ),
    'ageRating' => _compareNullableStrings(left.ageRating, right.ageRating),
    'imprint' => _compareNullableStrings(
        left.publishing?.imprint,
        right.publishing?.imprint,
      ),
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

LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>?
    _tableColumnDefinition(LibraryTypeConfig type, Object column) {
  final fieldId = type.tableColumnFieldId(column);
  return type.presentation.columnDefinitionForId(fieldId);
}

LibraryTableColumnGroup _tableColumnGroupFor(String? group) {
  final normalized = group?.trim().toLowerCase();
  return switch (normalized) {
    'edition' => LibraryTableColumnGroup.edition,
    'value' => LibraryTableColumnGroup.value,
    'personal' => LibraryTableColumnGroup.personal,
    _ => LibraryTableColumnGroup.main,
  };
}

String _fallbackLabel(String id) {
  final tokens = id
      .split('.')
      .map((segment) => segment.replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match[1]} ${match[2]}',
          ))
      .join(' ');
  return tokens.isEmpty
      ? id
      : tokens[0].toUpperCase() + tokens.substring(1);
}

String? _firstDisplayValue(List<String>? values) {
  if (values == null) return null;
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
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
