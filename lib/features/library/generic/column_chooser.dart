import 'package:collectarr_app/features/library/kinds/registry/library_kind_module.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

Future<Set<String>?> showGenericLibraryColumnChooser({
  required BuildContext context,
  required LibraryKindRuntime type,
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
        for (final column in runtime.defaultTableColumns()) column.value,
      },
      columnLabel: (column) => runtime.columnDisplayName(
        runtime.fields.decodeColumnId(column),
      ),
      accent: type.identity.accent,
      columnGroup: (column) => runtime.columnGroup(
        runtime.fields.decodeColumnId(column),
      ),
      groupLabel: runtime.columnGroupLabel,
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
