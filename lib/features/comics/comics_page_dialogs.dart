import 'package:collectarr_app/features/barcode/barcode_scan_sheet.dart';
import 'package:collectarr_app/features/comics/add/comics_add_dialog.dart';
import 'package:collectarr_app/features/comics/comics_filters.dart';
import 'package:collectarr_app/features/comics/comics_library_config.dart';
import 'package:collectarr_app/features/comics/shelf/comics_shelf_projection.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_state.dart';
import 'package:collectarr_app/features/comics/workspace/comics_workspace_view_config.dart';
import 'package:collectarr_app/features/library/workspace/library_column_preset_store.dart';
import 'package:collectarr_app/features/library/workspace/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/library_workspace_config.dart';
import 'package:flutter/material.dart';

Future<String?> showComicsBarcodeScanSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const BarcodeScanSheet(),
  );
}

Future<void> showAddComicsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const ComicsAddDialog(),
  );
}

Future<ComicsFilterSelection?> showComicsFiltersDialog(
  BuildContext context, {
  required ComicsFilterSelection initialSelection,
  required ComicsFilterOptions options,
}) {
  return showDialog<ComicsFilterSelection>(
    context: context,
    builder: (context) => ComicsFilterDialog(
      initialSelection: initialSelection,
      seriesOptions: options.series,
      gradeOptions: options.grades,
      conditionOptions: options.conditions,
      publisherOptions: options.publishers,
      releaseYearOptions: options.releaseYears,
    ),
  );
}

Future<Set<LibraryTableColumn>?> showComicsColumnChooserDialog(
  BuildContext context, {
  required ComicsWorkspaceViewState workspaceViewState,
}) async {
  final presetStore = LibraryColumnPresetStore(comicsWorkspaceConfig);
  final savedPresets = await presetStore.read();
  if (!context.mounted) {
    return null;
  }
  return showDialog<Set<LibraryTableColumn>>(
    context: context,
    builder: (context) => LibraryColumnChooserDialog(
      selectedColumns: workspaceViewState.visibleColumns,
      defaultColumns: comicsMediaAdapter.defaultTableColumns(),
      columnLabel: comicsMediaAdapter.columnDisplayName,
      columnDescription: comicTableColumnDescription,
      columnGroup: comicsMediaAdapter.columnGroup,
      groupLabel: comicsMediaAdapter.columnGroupLabel,
      presets: comicsTableColumnPresets,
      savedPresets: savedPresets,
      onSavePreset: (label, columns) => presetStore.savePreset(
        label: label,
        columns: columns,
      ),
      onDeletePreset: presetStore.deletePreset,
    ),
  );
}
