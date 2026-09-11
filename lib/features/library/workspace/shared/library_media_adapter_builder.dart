import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
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
  CatalogMediaKind kind,
  LibraryUiPolicy uiPolicy,
) {
  final coverGridHeightFactor = uiPolicy.coverAspectRatio;
  return LibraryWorkspaceViewProfile(
    kindModuleResolver: () => libraryKindRegistrationForKind(kind),
    defaultCoverSize: kPlannedMediaDefaultCoverSize,
    minCoverSize: kPlannedMediaMinCoverSize,
    maxCoverSize: kPlannedMediaMaxCoverSize,
    coverGridHeightFactor: coverGridHeightFactor,
    presetConfig: (preset) => plannedMediaViewPresetConfig(kind, preset),
    clampColumnWidth: (column, width) => clampPlannedMediaTableColumnWidth(
      libraryKindWorkspaceForKind(kind).fields,
      column,
      width,
    ),
    defaultDetailsLayout: LibraryDetailsLayout.bottom,
    sortAscendingForColumn: (column) =>
        libraryKindWorkspaceForKind(kind)
            .fields
            .findSortDefinition(
              column,
            )
            ?.defaultAscending ??
        true,
  );
}

LibraryWorkspaceViewPresetConfig plannedMediaViewPresetConfig(
  CatalogMediaKind kind,
  LibraryWorkspacePreset preset,
) {
  final defaultCols =
      libraryKindWorkspaceForKind(kind).fields.defaultVisibleColumns;
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
  LibraryKindRegistration type,
  LibraryProjectionView item,
  LibraryGroupIdRuntime groupId,
) {
  return libraryKindWorkspaceForKind(type.kind)
      .subgroupKeyForEntry(item, groupId);
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
