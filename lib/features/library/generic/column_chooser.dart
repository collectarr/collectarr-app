import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

Future<Set<String>?> showGenericLibraryColumnChooser({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryMediaAdapter adapter,
  required LibraryWorkspaceViewState viewState,
  Set<String> pinnedFavoriteKeys = const {},
  ValueChanged<LibraryTableColumnPreset>? onTogglePinnedFavorite,
}) async {
  final store = LibraryColumnPresetStore(type);
  final savedPresets = await store.read();
  if (!context.mounted) {
    return null;
  }
  return showDialog<Set<String>>(
    context: context,
    builder: (context) => LibraryColumnChooserDialog(
      availableColumns: type.availableTableColumns,
      selectedColumns: viewState.visibleColumns,
      defaultColumns: adapter.defaultTableColumns(),
      columnLabel: adapter.columnDisplayName,
      accent: type.workspace.accent,
      columnGroup: adapter.columnGroup,
      groupLabel: adapter.columnGroupLabel,
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
