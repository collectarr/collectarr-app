import 'package:collectarr_app/features/library/config/library_media_adapter.dart';
import 'package:collectarr_app/features/library/config/library_type_config.dart';
import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

Future<Set<LibraryTableColumn>?> showGenericLibraryColumnChooser({
  required BuildContext context,
  required LibraryTypeConfig type,
  required LibraryMediaAdapter adapter,
  required LibraryWorkspaceViewState viewState,
}) async {
  final store = LibraryColumnPresetStore(type.workspace);
  final savedPresets = await store.read();
  if (!context.mounted) {
    return null;
  }
  return showDialog<Set<LibraryTableColumn>>(
    context: context,
    builder: (context) => LibraryColumnChooserDialog(
      selectedColumns: viewState.visibleColumns,
      defaultColumns: adapter.defaultTableColumns(),
      columnLabel: adapter.columnDisplayName,
      accent: type.workspace.accent,
      columnGroup: adapter.columnGroup,
      groupLabel: adapter.columnGroupLabel,
      savedPresets: savedPresets,
      onSavePreset: (label, columns) => store.savePreset(
        label: label,
        columns: columns,
      ),
      onDeletePreset: store.deletePreset,
    ),
  );
}
