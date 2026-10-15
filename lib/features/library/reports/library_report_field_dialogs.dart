import 'package:collectarr_app/features/library/ui/primitives/library_field_selection.dart';
import 'package:collectarr_app/features/library/generic/library_folder_reorder_row.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<List<String>?> showLibraryReportColumns(
  BuildContext context, {
  required List<({String id, String label})> fields,
  required List<String> selected,
}) async {
  final result = await showDialog<Set<String>>(
      context: context,
      builder: (_) => LibraryColumnChooserDialog(
            availableColumns: [for (final field in fields) field.id],
            selectedColumns: selected.toSet(),
            defaultColumns: selected.toSet(),
            columnLabel: (id) =>
                fields.firstWhere((field) => field.id == id).label,
          ));
  return result?.toList();
}

Future<List<({String id, bool ascending})>?> showLibraryReportSorts(
  BuildContext context, {
  required List<({String id, String label})> fields,
  required List<({String id, bool ascending})> selected,
  bool multiple = true,
}) {
  final chosen = [...selected];
  var query = '';
  return showDialog<List<({String id, bool ascending})>>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => LibraryFieldSelectionDialog(
              title: 'Select Sort Fields',
              icon: AppIcons.sortAlpha,
              accent: appPalette(context).utilityAction,
              onSave: chosen.isEmpty
                  ? null
                  : () => Navigator.of(dialogContext).pop([...chosen]),
              child: LibraryFieldSelectionPanes(
                available: Column(children: [
                  LibraryFieldSelectionSearch(
                      onChanged: (value) =>
                          update(() => query = value.toLowerCase())),
                  const SizedBox(height: 10),
                  Expanded(
                      child: ListView(children: [
                    for (final field in fields)
                      if (field.label.toLowerCase().contains(query))
                        LibraryFieldSelectionCheckbox(
                          label: field.label,
                          selected: chosen.any((sort) => sort.id == field.id),
                          onTap: () => update(() {
                            final index = chosen
                                .indexWhere((sort) => sort.id == field.id);
                            if (index >= 0) {
                              if (chosen.length > 1) chosen.removeAt(index);
                            } else {
                              if (!multiple) chosen.clear();
                              chosen.add((id: field.id, ascending: true));
                            }
                          }),
                        ),
                  ])),
                ]),
                selected: ReorderableListView.builder(
                  padding: const EdgeInsets.all(10),
                  buildDefaultDragHandles: false,
                  proxyDecorator: LibraryFolderReorderRow.dragProxy,
                  itemCount: chosen.length,
                  onReorderItem: (oldIndex, newIndex) => update(() {
                    final field = chosen.removeAt(oldIndex);
                    chosen.insert(newIndex, field);
                  }),
                  itemBuilder: (context, index) => ReorderableDragStartListener(
                    key: ValueKey(chosen[index].id),
                    index: index,
                    child: LibrarySelectedFieldRow(
                      label: fields
                          .firstWhere((field) => field.id == chosen[index].id)
                          .label,
                      direction: chosen[index].ascending ? 'A-Z' : 'Z-A',
                      onToggleDirection: () => update(() => chosen[index] = (
                            id: chosen[index].id,
                            ascending: !chosen[index].ascending
                          )),
                      removeTooltip: 'Remove Sort Field',
                      onRemove: chosen.length <= 1
                          ? null
                          : () => update(() => chosen.removeAt(index)),
                    ),
                  ),
                ),
              ),
            )),
  );
}
