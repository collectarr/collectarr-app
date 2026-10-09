import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/config/library_typed_field_definition.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:collectarr_app/features/library/workspace/layout/library_pane_widths.dart';
import 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';

export 'package:collectarr_app/features/library/workspace/table/media_table_columns.dart';

LibraryWorkspaceViewProfile standardMediaWorkspaceViewProfile(
  CatalogMediaKind kind,
  LibraryUiPolicy uiPolicy, {
  LibraryDetailsLayout defaultDetailsLayout = LibraryDetailsLayout.bottom,
  double? defaultDetailsWidth,
}) {
  final coverGridHeightFactor = uiPolicy.coverAspectRatio;
  return LibraryWorkspaceViewProfile(
    registrationResolver: () => libraryKindRegistrationForKind(kind),
    defaultCoverSize: kStandardMediaDefaultCoverSize,
    minCoverSize: kStandardMediaMinCoverSize,
    maxCoverSize: kStandardMediaMaxCoverSize,
    coverGridHeightFactor: coverGridHeightFactor,
    cardLayout: uiPolicy.coverAspectRatio == 1.0
        ? LibraryWorkspaceCardLayout.coverFocused
        : LibraryWorkspaceCardLayout.standard,
    presetConfig: (preset) => standardMediaViewPresetConfig(
      kind,
      preset,
      detailsLayout: defaultDetailsLayout,
    ),
    clampColumnWidth: (column, width) => clampPlannedMediaTableColumnWidth(
      libraryKindWorkspaceForKind(kind).fields,
      column,
      width,
    ),
    defaultDetailsWidth: defaultDetailsWidth ?? kLibraryDetailsDefaultWidth,
    defaultDetailsLayout: defaultDetailsLayout,
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

LibraryWorkspaceViewPresetConfig standardMediaViewPresetConfig(
  CatalogMediaKind kind,
  LibraryWorkspacePreset preset, {
  LibraryDetailsLayout detailsLayout = LibraryDetailsLayout.bottom,
}) {
  final defaultCols =
      libraryKindWorkspaceForKind(kind).fields.defaultVisibleColumns;
  return switch (preset) {
    LibraryWorkspacePreset.cover => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: detailsLayout,
        coverSize: kStandardMediaDefaultCoverSize,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.card => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.card,
        detailsLayout: detailsLayout,
        coverSize: 150,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.details => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.grid,
        detailsLayout: detailsLayout,
        coverSize: 144,
        visibleColumns: defaultCols,
      ),
    LibraryWorkspacePreset.list => LibraryWorkspaceViewPresetConfig(
        viewMode: LibraryViewMode.list,
        detailsLayout: detailsLayout,
        coverSize: 100,
        visibleColumns: defaultCols,
      ),
  };
}

String? standardMediaSubgroupKeyForEntry(
  LibraryKindRegistration type,
  LibraryProjectionView item,
  LibraryGroupIdRuntime groupId,
) {
  return libraryKindWorkspaceForKind(type.kind)
      .subgroupKeyForEntry(item, groupId);
}

int standardMediaCompareSubgroupKeys(
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
