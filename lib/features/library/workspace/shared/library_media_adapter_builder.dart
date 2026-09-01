import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';

export 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';

const double kPlannedMediaMinCoverSize = 96;
const double kPlannedMediaDefaultCoverSize = 128;
const double kPlannedMediaMaxCoverSize = 188;
const double kPlannedMediaTableColumnSpacing = 10;
const double kPlannedMediaTableHorizontalMargin = 8;

LibraryWorkspaceViewProfile plannedMediaWorkspaceViewProfile(
  LibraryKindRuntime type,
) {
  final coverGridHeightFactor = type.uiPolicy.coverAspectRatio;
  return LibraryWorkspaceViewProfile(
    runtimeResolver: () => type,
    defaultCoverSize: kPlannedMediaDefaultCoverSize,
    minCoverSize: kPlannedMediaMinCoverSize,
    maxCoverSize: kPlannedMediaMaxCoverSize,
    coverGridHeightFactor: coverGridHeightFactor,
    presetConfig: (preset) => plannedMediaViewPresetConfig(type, preset),
    clampColumnWidth: (column, width) =>
        clampPlannedMediaTableColumnWidth(type, column, width),
    defaultDetailsLayout: LibraryDetailsLayout.bottom,
    sortAscendingForColumn: (column) =>
        type.fields
            .findSortDefinition(
              column,
            )
            ?.defaultAscending ??
        true,
  );
}

LibraryWorkspaceViewPresetConfig plannedMediaViewPresetConfig(
  LibraryKindRuntime type,
  LibraryWorkspacePreset preset,
) {
  final defaultCols = type.fields.defaultVisibleColumns;
  return switch (preset) {
    LibraryWorkspacePreset.cover => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: kPlannedMediaDefaultCoverSize,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.card => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.card,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 150,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.details => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 144,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.list => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: LibraryDetailsLayout.bottom,
        coverSize: 100,
        visibleColumns: defaultCols,
      ),
  };
}

String? plannedMediaSubgroupKeyForEntry(
  LibraryKindRuntime type,
  LibraryProjectionRuntime item,
  LibraryGroupIdRuntime groupId,
) {
  final definition = type.fields.findGroupDefinition(groupId);
  return definition?.subgroupKey?.call(
    LibraryProjectionContext(
        source: item.source, node: item.node, dto: item.dto),
  );
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
