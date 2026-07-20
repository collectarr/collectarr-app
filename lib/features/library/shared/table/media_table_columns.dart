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
  required Set<String> columns,
  required Map<String, double> customWidths,
}) {
  return libraryTableWidthForColumns(
    columns: columns,
    defaultColumns: libraryKindModuleForType(type).fields.defaultVisibleColumnIds,
    customWidths: customWidths,
    sizing: (column) => plannedMediaTableColumnSizing(type, column as String),
    columnSpacing: kPlannedMediaTableColumnSpacing,
    horizontalMargin: kPlannedMediaTableHorizontalMargin,
  );
}

double plannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  String columnId,
  Map<String, double> customWidths,
) {
  return libraryTableColumnWidth(
    column: columnId,
    customWidths: customWidths,
    sizing: (column) => plannedMediaTableColumnSizing(type, column as String),
  );
}

double defaultPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  if (definition != null && definition.defaultWidth != null) {
    return definition.defaultWidth!;
  }
  return definition?.isNumeric == true ? 88.0 : 140.0;
}

double minPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  return definition?.minWidth ?? 64.0;
}

double maxPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  return definition?.maxWidth ?? 260.0;
}

LibraryTableColumnSizing plannedMediaTableColumnSizing(
  LibraryTypeConfig type,
  String columnId,
) {
  return LibraryTableColumnSizing(
    defaultWidth: defaultPlannedMediaTableColumnWidth(type, columnId),
    minWidth: minPlannedMediaTableColumnWidth(type, columnId),
    maxWidth: maxPlannedMediaTableColumnWidth(type, columnId),
  );
}

double clampPlannedMediaTableColumnWidth(
  LibraryTypeConfig type,
  String columnId,
  double width,
) {
  return clampLibraryTableColumnWidth(
    width,
    plannedMediaTableColumnSizing(type, columnId),
  );
}

String plannedMediaTableColumnLabelForType(
  LibraryTypeConfig type,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  if (definition != null) {
    return definition.label;
  }
  return _fallbackLabel(columnId);
}

String plannedMediaTableColumnDisplayNameForType(
  LibraryTypeConfig type,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  if (definition != null) {
    return definition.resolvedDisplayName;
  }
  return plannedMediaTableColumnLabelForType(type, columnId);
}

LibraryTableColumnGroup plannedMediaTableColumnGroup(
  LibraryTypeConfig type,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
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
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  return definition?.isNumeric ?? false;
}

Object? plannedMediaTableColumnSort(
  LibraryTypeConfig type,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  if (definition == null || !definition.sortable) {
    return null;
  }
  return definition.sortId ?? definition.id.value;
}

Widget plannedMediaTableCell(
  LibraryTypeConfig type,
  LibraryWorkspaceEntry entry,
  String columnId,
) {
  final definition = _tableColumnDefinition(type, columnId);
  if (definition == null) {
    return const LibraryTableCellText('');
  }
  final module = libraryKindModuleForType(type);
  final dto = module.workspaceDtoFactory?.call(entry) ?? entry;
  final builder = definition.cellValue;
  if (builder != null) {
    return builder(dto);
  }
  final value = definition.getValue(dto);
  return LibraryTableCellText(value?.toString());
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
    _tableColumnDefinition(LibraryTypeConfig type, String columnId) {
  final module = libraryKindModuleForType(type);
  return module.fields.columnDefinitionForId(columnId);
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
