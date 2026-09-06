import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/workspace/schema/library_field_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_layout.dart';
import 'package:collectarr_app/features/library/workspace/table/library_table_cell.dart';
import 'package:flutter/material.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

double plannedMediaTableWidthForColumns({
  required LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  required Set<LibraryFieldIdRuntime> columns,
  required Map<LibraryFieldIdRuntime, double> customWidths,
}) {
  return libraryTableWidthForColumns(
    columns: columns,
    defaultColumns: fields.defaultVisibleColumns,
    customWidths: customWidths,
    sizing: (column) => plannedMediaTableColumnSizing(fields, column),
    columnSpacing: kPlannedMediaTableColumnSpacing,
    horizontalMargin: kPlannedMediaTableHorizontalMargin,
  );
}

double plannedMediaTableColumnWidth(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
  Map<LibraryFieldIdRuntime, double> customWidths,
) {
  return libraryTableColumnWidth(
    column: columnId,
    customWidths: customWidths,
    sizing: (column) => plannedMediaTableColumnSizing(fields, column),
  );
}

double defaultPlannedMediaTableColumnWidth(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
  if (definition != null && definition.defaultWidth != null) {
    return definition.defaultWidth!;
  }
  return definition?.isNumeric == true ? 88.0 : 140.0;
}

double minPlannedMediaTableColumnWidth(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
  return definition?.minWidth ?? 64.0;
}

double maxPlannedMediaTableColumnWidth(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
  return definition?.maxWidth ?? 260.0;
}

LibraryTableColumnSizing plannedMediaTableColumnSizing(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  return LibraryTableColumnSizing(
    defaultWidth: defaultPlannedMediaTableColumnWidth(fields, columnId),
    minWidth: minPlannedMediaTableColumnWidth(fields, columnId),
    maxWidth: maxPlannedMediaTableColumnWidth(fields, columnId),
  );
}

double clampPlannedMediaTableColumnWidth(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
  double width,
) {
  return clampLibraryTableColumnWidth(
    width,
    plannedMediaTableColumnSizing(fields, columnId),
  );
}

String plannedMediaTableColumnLabelForType(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
  if (definition != null) {
    return definition.label;
  }
  return _fallbackLabel(columnId.value);
}

String plannedMediaTableColumnDisplayNameForType(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
  if (definition != null) {
    return definition.resolvedDisplayName;
  }
  return plannedMediaTableColumnLabelForType(fields, columnId);
}

LibraryTableColumnGroup plannedMediaTableColumnGroup(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
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
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
  return definition?.isNumeric ?? false;
}

LibrarySortIdRuntime? plannedMediaTableColumnSort(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  final definition = _tableColumnDefinition(fields, columnId);
  if (definition == null || !definition.sortable) {
    return null;
  }
  final explicitSortId = definition.sortId;
  if (explicitSortId != null) {
    return explicitSortId;
  }
  return fields.sortIdForColumn(definition.id);
}

Widget plannedMediaTableCellTyped<TDto extends LibraryWorkspaceDto>(
  LibraryFieldRegistry<TDto> fields,
  LibraryProjectionRuntime item,
  LibraryFieldIdRuntime columnId,
) {
  final definition = fields.findColumnDefinition(columnId);
  if (definition == null) {
    return const LibraryTableCellText('');
  }
  final context = LibraryProjectionContext<TDto>(
    source: item.source,
    node: item.node,
    dto: item.dto as TDto,
  );
  final builder = definition.cellValue;
  if (builder != null) {
    return builder(context);
  }
  final value = definition.getValue(context);
  return LibraryTableCellText(value?.toString());
}

int plannedMediaCompareSubgroupKeys(
  String left,
  String right,
) {
  final leftNumber = _extractSubgroupNumber(left);
  final rightNumber = _extractSubgroupNumber(right);
  if (leftNumber != null && rightNumber != null) {
    return leftNumber.compareTo(rightNumber);
  }
  return left.compareTo(right);
}

LibraryColumnDefinition<dynamic, LibraryWorkspaceDto, Object?>?
    _tableColumnDefinition(
  LibraryFieldRegistry<LibraryWorkspaceDto> fields,
  LibraryFieldIdRuntime columnId,
) {
  return fields.findColumnDefinition(columnId);
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
  final cleaned = id.replaceAll('_', ' ');
  final tokens = cleaned
      .split('.')
      .map((segment) => segment.replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match[1]} ${match[2]}',
          ))
      .join(' ');
  if (tokens.isEmpty) return id;
  return tokens.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
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
