import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/config/library_workspace_config.dart';
import 'package:collectarr_app/features/library/workspace/entry/library_workspace_view_state.dart';
import 'package:flutter/material.dart';

Future<Set<String>?> showGenericLibraryColumnChooser({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LibraryWorkspaceViewState viewState,
  Set<String> pinnedFavoriteKeys = const {},
  ValueChanged<LibraryTableColumnPreset>? onTogglePinnedFavorite,
}) async {
  final accent = LibraryAccentScope.accentOf(context);
  final store = LibraryColumnPresetStore(type);
  final savedPresets = await store.read();
  if (!context.mounted) {
    return null;
  }
  final workspace = libraryKindWorkspaceForKind(type.kind);
  final fields = workspace.workspaceFields;
  final availableColumns = {
    for (final column in fields.columns) column.id.value
  };
  final labels = {
    for (final column in fields.columns) column.id.value: column.metadata.label
  };
  final presets = libraryPresentationForKind(type.kind)
      .columnFavorites
      .where(
        (preset) => availableColumns.containsAll(preset.columns),
      )
      .toList(growable: false);
  return showDialog<Set<String>>(
    context: context,
    builder: (context) => LibraryColumnChooserDialog(
      availableColumns: [
        for (final def in fields.columns) def.id.value,
      ],
      selectedColumns: {
        for (final column in viewState.visibleColumnIds) column.value,
      },
      defaultColumns: {
        for (final column in fields.defaultVisibleColumns) column.value,
      },
      primaryColumn: null,
      presets: presets,
      columnLabel: (column) {
        final label = fields
                .findColumnDefinition(fields.decodeColumnId(column))
                ?.displayName ??
            labels[column] ??
            column;
        return label.trim().isEmpty ? labels[column] ?? column : label;
      },
      accent: accent,
      columnGroup: (column) {
        final group = fields
            .findColumnDefinition(fields.decodeColumnId(column))
            ?.group
            .toLowerCase();
        return LibraryTableColumnGroup.values.firstWhere(
            (value) => value.name.toLowerCase() == group,
            orElse: () => LibraryTableColumnGroup.main);
      },
      groupLabel: workspace.columnGroupLabel,
      savedPresets: savedPresets
          .where((preset) => availableColumns.containsAll(preset.columns))
          .toList(growable: false),
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
