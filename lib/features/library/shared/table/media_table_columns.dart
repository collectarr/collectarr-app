import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_entry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
  if (column == LibraryTableColumn.variant) {
    return type.releaseFields.variantLabel;
  }
  if (column == LibraryTableColumn.barcode) {
    return type.releaseFields.barcodeLabel;
  }
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
  if (column == LibraryTableColumn.variant) {
    return type.releaseFields.variantLabel;
  }
  if (column == LibraryTableColumn.barcode) {
    return type.releaseFields.barcodeLabel;
  }
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
  final sortId = definition.sortId ?? definition.id.value;
  for (final val in LibrarySortColumn.values) {
    final name = val.name;
    final snake = name
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]}_${match[2]}',
        )
        .toLowerCase();
    if (name == sortId ||
        snake == sortId ||
        val.toString() == sortId ||
        val.toString().split('.').last == sortId) {
      return val;
    }
  }
  if (sortId == 'comic.issue' || sortId == 'issue') {
    return LibrarySortColumn.issue;
  }
  if (sortId == 'comic.key_issue' || sortId == 'keyComic' || sortId == 'key_comic') {
    return LibrarySortColumn.keyComic;
  }
  return sortId;
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



LibraryColumnDefinition<LibraryWorkspaceEntry, Object?>?
    _tableColumnDefinition(LibraryTypeConfig type, Object column) {
  final fieldId = type.tableColumnFieldId(column);
  final module = libraryKindModuleForType(type);
  return module.fields.columnDefinitionForId(fieldId);
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
