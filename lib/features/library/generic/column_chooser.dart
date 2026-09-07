import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

Future<Set<String>?> showGenericLibraryColumnChooser({
  required BuildContext context,
  required LibraryKindModule type,
  required LibraryWorkspaceViewState viewState,
  Set<String> pinnedFavoriteKeys = const {},
  ValueChanged<LibraryTableColumnPreset>? onTogglePinnedFavorite,
}) async {
  final store = LibraryColumnPresetStore(type);
  final savedPresets = await store.read();
  if (!context.mounted) {
    return null;
  }
  final runtime = type;
  final workspace = libraryKindWorkspaceForKind(runtime.kind);
  return showDialog<Set<String>>(
    context: context,
    builder: (context) => LibraryColumnChooserDialog(
      availableColumns: [
        for (final def in runtime.fields.columns) def.id.value,
      ],
      selectedColumns: {
        for (final column in viewState.visibleColumnIds) column.value,
      },
      defaultColumns: {
        for (final column in workspace.defaultTableColumns) column.value,
      },
      columnLabel: (column) => workspace.columnDisplayName(
        runtime.fields.decodeColumnId(column),
      ),
      accent: type.identity.accent,
      columnGroup: (column) => workspace.columnGroup(
        runtime.fields.decodeColumnId(column),
      ),
      groupLabel: workspace.columnGroupLabel,
      savedPresets: savedPresets,
      pinnedFavoriteKeys: pinnedFavoriteKeys,
      onTogglePinnedFavorite: onTogglePinnedFavorite,
      onSavePreset: (label, columns) => store.savePreset(
        label: label,
        columns: columns,
      ),
      onDeletePreset: store.deletePreset,
    ),
  );
}
