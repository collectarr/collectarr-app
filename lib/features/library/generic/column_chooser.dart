import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/library_accent_scope.dart';
import 'package:collectarr_app/features/library/kind_registry.dart';
import 'package:collectarr_app/features/library/workspace/table/column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/config/column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/config/config.dart';
import 'package:collectarr_app/features/library/workspace/entry/view_state.dart';
import 'package:flutter/material.dart';

Future<Set<String>?> showGenericLibraryColumnChooser({
  required BuildContext context,
  required LibraryKindRegistration type,
  required LibraryWorkspaceViewState viewState,
  bool manageFavorites = false,
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
  final knownColumns = {for (final column in fields.columns) column.id.value};
  final availableColumns = {
    for (final column in fields.columns)
      if (!column.alwaysVisible) column.id.value
  };
  LibraryTableColumnPreset selectablePreset(LibraryTableColumnPreset preset) =>
      LibraryTableColumnPreset(
          id: preset.id,
          label: preset.label,
          columns: preset.columns.where(availableColumns.contains).toSet());
  final labels = {
    for (final column in fields.columns) column.id.value: column.metadata.label
  };
  final presets = libraryPresentationForKind(type.kind)
      .columnFavorites
      .where(
        (preset) => knownColumns.containsAll(preset.columns),
      )
      .map(selectablePreset)
      .toList(growable: false);
  return showAppPageOrDialog<Set<String>>(
    context: context,
    builder: (context) => LibraryColumnChooserDialog(
      showFavorites: manageFavorites,
      availableColumns: [
        for (final def in fields.columns)
          if (!def.alwaysVisible) def.id.value,
      ],
      selectedColumns: {
        for (final column in viewState.visibleColumnIds)
          if (availableColumns.contains(column.value)) column.value,
      },
      defaultColumns: {
        for (final column in fields.defaultVisibleColumns)
          if (availableColumns.contains(column.value)) column.value,
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
