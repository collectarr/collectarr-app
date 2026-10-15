import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/features/library/workspace/table/library_column_chooser.dart';
import 'package:collectarr_app/features/library/workspace/config/library_column_preset_store.dart';
import 'package:collectarr_app/features/collection/collection_mutations.dart';
import 'package:collectarr_app/features/collection/repositories/shelf_controller.dart';
import 'package:collectarr_app/features/library/config/library_duplicate_presentation.dart';
import 'package:collectarr_app/features/library/config/library_kind_style.dart';
import 'package:collectarr_app/features/library/duplicates/library_duplicate_removal_plan.dart';
import 'package:collectarr_app/features/library/generic/projection_item.dart';
import 'package:collectarr_app/features/library/inspector/library_duplicate_items.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/features/library/ui/library_management_page.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/compact_search_dropdown_form_field.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:collectarr_app/ui/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LibraryFindDuplicatesPage extends ConsumerStatefulWidget {
  const LibraryFindDuplicatesPage({
    super.key,
    required this.type,
    required this.entries,
    required this.accent,
    this.onRemove,
  });

  final LibraryKindRegistration type;
  final List<LibraryWorkspaceContext> entries;
  final Color accent;
  final Future<void> Function(LibraryWorkspaceContext entry)? onRemove;

  @override
  ConsumerState<LibraryFindDuplicatesPage> createState() =>
      _LibraryFindDuplicatesPageState();
}

class _LibraryFindDuplicatesPageState
    extends ConsumerState<LibraryFindDuplicatesPage> {
  LibraryDuplicateCriterion _criterion = LibraryDuplicateCriterion.title;
  List<LibraryDuplicateGroup>? _groups;
  final _removed = <String>{};
  final _kept = <String>{};
  final _collapsed = <String>{};
  late final _workspace = libraryKindWorkspaceForKind(widget.type.kind);
  late final _fields = _workspace.fields;
  late final _columns = _fields.columns;
  late final Set<String> _visibleColumns = {
    for (final column in _fields.defaultVisibleColumns) column.value,
  };
  late final _items = {
    for (final entry in widget.entries.where((entry) => entry.isEntry))
      entry.libraryEntryRef!.key:
          LibraryProjectionItem.fromShelf(entry, widget.type),
  };
  bool _busy = false;
  String? _error;

  String get _columnsKey =>
      'collectarr.find_duplicates.${widget.type.kind.apiValue}.columns';

  @override
  void initState() {
    super.initState();
    unawaited(_loadColumns());
  }

  Future<void> _loadColumns() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_columnsKey);
    if (stored != null && mounted) {
      setState(() {
        _visibleColumns
          ..clear()
          ..addAll(stored.where((id) => _columns.any((c) => c.id.value == id)));
        if (_visibleColumns.isEmpty) {
          _visibleColumns.add(_fields.primaryColumn.value);
        }
      });
    }
  }

  Future<void> _saveColumns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_columnsKey, _visibleColumns.toList());
  }

  void _find() {
    setState(() {
      _groups = findDuplicateShelfGroups(
        widget.entries
            .where((entry) =>
                entry.isEntry && !_removed.contains(entry.libraryEntryRef!.key))
            .toList(),
        criterion: _criterion,
      );
      _kept.clear();
      _collapsed.clear();
      _error = null;
    });
  }

  Future<void> _remove(List<LibraryWorkspaceContext> entries,
      {required bool automatic}) async {
    if (entries.isEmpty || _busy) return;
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: libraryAccentTheme(context, widget.accent),
        child: AccentAlertDialog(
          headerIcon: AppIcons.delete,
          title: Text(automatic ? 'Remove all duplicates' : 'Remove duplicate'),
          content: Text(automatic
              ? 'Keep the oldest entry in each group and remove ${entries.length} '
                  'duplicate entries? Groups marked Keep will be preserved.'
              : 'Remove "${entries.single.title}" from your library?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Remove')),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      for (final entry in entries) {
        if (widget.onRemove case final remove?) {
          await remove(entry);
        } else {
          await ref
              .read(libraryEntryMutationsProvider)
              .removeItem(entry.libraryEntryRef!);
        }
        _removed.add(entry.libraryEntryRef!.key);
      }
    } catch (error) {
      if (mounted) _error = 'Could not remove duplicate: $error';
    } finally {
      ref.invalidate(shelfProvider);
      if (mounted) {
        setState(() {
          _busy = false;
          _groups = findDuplicateShelfGroups(
            widget.entries
                .where((entry) =>
                    entry.isEntry &&
                    !_removed.contains(entry.libraryEntryRef!.key))
                .toList(),
            criterion: _criterion,
          );
        });
      }
    }
  }

  Future<void> _selectColumns() async {
    final store = LibraryColumnPresetStore(widget.type);
    final presets = await store.read();
    if (!mounted) return;
    final available = _columns.map((column) => column.id.value).toSet();
    final result = await showAppDialog<Set<String>>(
      context: context,
      builder: (context) => Theme(
        data: libraryAccentTheme(context, widget.accent),
        child: LibraryColumnChooserDialog(
          availableColumns: available.toList(),
          selectedColumns: _visibleColumns,
          defaultColumns: {
            for (final column in _fields.defaultVisibleColumns) column.value
          },
          primaryColumn: _fields.primaryColumn.value,
          accent: widget.accent,
          columnLabel: (id) =>
              _workspace.columnDisplayName(_fields.decodeColumnId(id)),
          columnGroup: (id) =>
              _workspace.columnGroup(_fields.decodeColumnId(id)),
          groupLabel: _workspace.columnGroupLabel,
          presets: libraryPresentationForKind(widget.type.kind)
              .columnFavorites
              .where((preset) => available.containsAll(preset.columns))
              .toList(),
          savedPresets: presets
              .where((preset) => available.containsAll(preset.columns))
              .toList(),
          onSavePreset: (label, columns) =>
              store.savePreset(label: label, columns: columns),
          onDeletePreset: store.deletePreset,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _visibleColumns
          ..clear()
          ..addAll(result);
      });
      await _saveColumns();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    final removals = planDuplicateRemovals(groups ?? [], keptGroupKeys: _kept);
    return LibraryManagementPage(
      title: 'Find Duplicates',
      icon: AppIcons.duplicates,
      accent: widget.accent,
      bottomBar: groups == null || groups.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  key: const Key('duplicates.remove_all'),
                  onPressed: _busy || removals.isEmpty
                      ? null
                      : () => _remove(removals, automatic: true),
                  child: const Text('Remove all duplicates automatically'),
                ),
              ),
            ),
      child: Builder(builder: (context) {
        final palette = appPalette(context);
        return Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: palette.panel,
                border: Border(bottom: BorderSide(color: palette.divider))),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Find duplicates based on'),
                SizedBox(
                  width: 220,
                  child:
                      CompactSearchDropdownFormField<LibraryDuplicateCriterion>(
                    initialValue: _criterion,
                    items: [
                      for (final criterion in LibraryDuplicateCriterion.values)
                        DropdownMenuItem(
                          value: criterion,
                          child: Text(switch (criterion) {
                            LibraryDuplicateCriterion.title => 'Title',
                            LibraryDuplicateCriterion.titleAndCreator =>
                              'Title & Artist / Creator',
                            LibraryDuplicateCriterion.identifier =>
                              'Barcode / Identifier',
                            LibraryDuplicateCriterion.indexNumber => 'Index',
                            LibraryDuplicateCriterion.automatic =>
                              'Automatic matching',
                          }),
                        ),
                    ],
                    onChanged: _busy
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _criterion = value;
                                _groups = null;
                              });
                            }
                          },
                  ),
                ),
                FilledButton(
                    key: const Key('duplicates.find'),
                    onPressed: _busy ? null : _find,
                    child: const Text('Find Duplicates')),
                if (groups != null)
                  Text('${groups.length} duplicate groups found'),
                IconButton(
                    tooltip: 'Select Column Fields',
                    onPressed: _selectColumns,
                    icon: const Icon(Icons.view_column_outlined)),
              ],
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!,
                    style: TextStyle(color: palette.errorForeground))),
          Expanded(
            child: groups == null
                ? const SizedBox.expand()
                : groups.isEmpty
                    ? const Center(child: Text('No duplicates found.'))
                    : _table(context, groups),
          ),
        ]);
      }),
    );
  }

  Widget _table(BuildContext context, List<LibraryDuplicateGroup> groups) {
    final columns = [
      for (final id in _visibleColumns)
        _columns.firstWhere((column) => column.id.value == id)
    ];
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 38,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 44,
          columnSpacing: 24,
          headingTextStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          columns: [
            const DataColumn(label: Text('Group')),
            for (final column in columns)
              DataColumn(label: Text(column.resolvedDisplayName)),
            const DataColumn(label: Text('')),
          ],
          rows: [
            for (final group in groups) ...[
              DataRow(
                color: WidgetStatePropertyAll(_kept.contains(group.key)
                    ? widget.accent.withValues(alpha: 0.12)
                    : appPalette(context).panelRaised),
                cells: [
                  DataCell(
                      Icon(_collapsed.contains(group.key)
                          ? Icons.chevron_right
                          : Icons.expand_more), onTap: () {
                    setState(() {
                      if (!_collapsed.add(group.key)) {
                        _collapsed.remove(group.key);
                      }
                    });
                  }),
                  for (var index = 0; index < columns.length; index++)
                    DataCell(index == 0
                        ? Text(group.label,
                            style: const TextStyle(fontWeight: FontWeight.w700))
                        : const Text('')),
                  DataCell(OutlinedButton(
                    key: ValueKey('duplicates.keep.${group.key}'),
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              if (!_kept.add(group.key)) {
                                _kept.remove(group.key);
                              }
                            }),
                    child: Text(_kept.contains(group.key)
                        ? 'Keeping ${group.count}'
                        : 'Keep ${group.count}'),
                  )),
                ],
              ),
              if (!_collapsed.contains(group.key))
                for (final entry in group.entries)
                  DataRow(cells: [
                    const DataCell(Text('')),
                    for (final column in columns)
                      DataCell(SizedBox(
                        width: _workspace.defaultTableColumnWidth(column.id,
                            target: entry.target),
                        child: _workspace.buildTableCell(
                            _items[entry.libraryEntryRef!.key]!, column.id),
                      )),
                    DataCell(TextButton(
                      key: ValueKey(
                          'duplicates.remove.${entry.libraryEntryRef!.key}'),
                      onPressed: _busy
                          ? null
                          : () => _remove([entry], automatic: false),
                      child: const Text('Remove'),
                    )),
                  ]),
            ],
          ],
        ),
      ),
    );
  }
}
