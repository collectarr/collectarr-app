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
  // Duplicates are always local entries, so personal columns such as Added
  // Date are available alongside catalog ones.
  late final _fields = _workspace.libraryEntryFields;
  late final _columns = _fields.columns;
  late final List<String> _defaultColumns = [
    for (final id
        in libraryPresentationForKind(widget.type.kind).duplicateColumns ??
            [for (final column in _fields.defaultVisibleColumns) column.value])
      if (_columns.any((column) => column.id.value == id)) id,
  ];
  late final Set<String> _visibleColumns = {..._defaultColumns};
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
          defaultColumns: {..._defaultColumns},
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
    final duplicateCount = groups?.fold<int>(
            0, (total, group) => total + group.entries.length - 1) ??
        0;
    return LibraryManagementPage(
      title: 'Find Duplicates',
      icon: AppIcons.duplicates,
      accent: widget.accent,
      maxWidth: double.infinity,
      bottomBar: groups == null || groups.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Align(
                heightFactor: 1,
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: const Key('duplicates.remove_all'),
                  style: _actionStyle(appPalette(context).utilityAction,
                      height: 32),
                  onPressed: _busy || removals.isEmpty
                      ? null
                      : () => _remove(removals, automatic: true),
                  child: const Text('Remove all duplicates automatically'),
                ),
              ),
            ),
      child: Builder(builder: (context) {
        final palette = appPalette(context);
        final criterionField = SizedBox(
          width: 160,
          child: CompactSearchDropdownFormField<LibraryDuplicateCriterion>(
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
                    LibraryDuplicateCriterion.automatic => 'Automatic matching',
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
        );
        final findButton = FilledButton(
            key: const Key('duplicates.find'),
            style: _actionStyle(palette.utilityAction, height: 30, bold: true),
            onPressed: _busy ? null : _find,
            child: const Text('Find Duplicates'));
        return Column(children: [
          LayoutBuilder(builder: (context, constraints) {
            final count = groups == null
                ? null
                : Text(
                    groups.isEmpty
                        ? 'No duplicates found.'
                        : '$duplicateCount duplicates found:',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700));
            final controls = <Widget>[
              const Text('Find duplicates based on'),
              criterionField,
              findButton,
            ];
            final columnsButton = IconButton(
                tooltip: 'Select Column Fields',
                onPressed: _selectColumns,
                icon: const Icon(AppIcons.columns, size: 18));
            // Narrow pages wrap the controls instead of overflowing.
            if (constraints.maxWidth < 900) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: appManagementPanelColor(context),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...controls,
                    if (count != null) count,
                    columnsButton
                  ],
                ),
              );
            }
            return Container(
              width: double.infinity,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: appManagementPanelColor(context),
              child: Row(children: [
                controls[0],
                const SizedBox(width: 6),
                controls[1],
                const SizedBox(width: 10),
                controls[2],
                Expanded(child: count ?? const SizedBox.shrink()),
                columnsButton,
              ]),
            );
          }),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!,
                    style: TextStyle(color: palette.errorForeground))),
          Expanded(
            child: groups == null || groups.isEmpty
                ? const SizedBox.expand()
                : _table(context, groups),
          ),
        ]);
      }),
    );
  }

  // Colors and sizes measured on the reference results table.
  static const _tableColor = Color(0xFF464646);
  static const _groupHeaderColor = Color(0xFF848484);
  static const _rowDividerColor = Color(0xFFA9A9A9);
  static const _keepColor = Color(0xFF68BEEF);
  static const _removeColor = Color(0xFFD44D4D);
  static const _chevronWidth = 54.0;
  static const _actionWidth = 91.0;
  static const _sideMargin = 39.0;

  ButtonStyle _actionStyle(Color color,
          {double height = 24, double? width, bool bold = false}) =>
      FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: Size(width ?? 0, height),
        fixedSize: width == null ? null : Size(width, height),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: TextStyle(
            fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w400),
      );

  Widget _table(BuildContext context, List<LibraryDuplicateGroup> groups) {
    final columns = [
      for (final id in _visibleColumns)
        _columns.firstWhere((column) => column.id.value == id)
    ];
    return LayoutBuilder(builder: (context, constraints) {
      // Columns keep their natural widths and stretch to fill a wide page.
      final available =
          constraints.maxWidth - 2 * _sideMargin - _chevronWidth - _actionWidth;
      final natural = [
        for (final column in columns)
          _workspace.defaultTableColumnWidth(column.id,
              target: groups.first.entries.first.target)
      ];
      final naturalTotal = natural.fold<double>(0, (a, b) => a + b);
      final scale = naturalTotal <= 0 || naturalTotal >= available
          ? 1.0
          : available / naturalTotal;
      final widths = [for (final width in natural) width * scale];
      final tableWidth = _chevronWidth +
          widths.fold<double>(0, (a, b) => a + b) +
          _actionWidth;

      Widget cell(Widget child, double width) => SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: DefaultTextStyle.merge(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  child: child),
            ),
          );

      final header = Container(
        height: 37,
        color: _tableColor,
        child: Row(children: [
          const SizedBox(width: _chevronWidth),
          for (var index = 0; index < columns.length; index++)
            cell(
                Text(columns[index].resolvedDisplayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                widths[index]),
          const SizedBox(width: _actionWidth),
        ]),
      );

      Widget actionSlot(Widget button) =>
          SizedBox(width: _actionWidth, child: Center(child: button));

      Widget groupBlock(LibraryDuplicateGroup group) {
        final collapsed = _collapsed.contains(group.key);
        final kept = _kept.contains(group.key);
        return Container(
          color: _tableColor,
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(children: [
            Container(
              height: 42,
              color: _groupHeaderColor,
              child: Row(children: [
                SizedBox(
                  width: _chevronWidth,
                  child: IconButton(
                    tooltip: collapsed ? 'Expand' : 'Collapse',
                    icon: Icon(
                        collapsed ? Icons.chevron_right : Icons.expand_more,
                        size: 20,
                        color: Colors.white),
                    onPressed: () => setState(() {
                      if (!_collapsed.add(group.key)) {
                        _collapsed.remove(group.key);
                      }
                    }),
                  ),
                ),
                Expanded(
                  child: Text(group.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900)),
                ),
                actionSlot(FilledButton(
                  key: ValueKey('duplicates.keep.${group.key}'),
                  style: _actionStyle(_keepColor, width: 75),
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            if (!_kept.add(group.key)) {
                              _kept.remove(group.key);
                            }
                          }),
                  child: Text(
                      kept ? 'Keeping ${group.count}' : 'Keep ${group.count}'),
                )),
              ]),
            ),
            if (!collapsed)
              for (final entry in group.entries)
                Container(
                  constraints: const BoxConstraints(minHeight: 41),
                  decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: _rowDividerColor))),
                  child: Row(children: [
                    const SizedBox(width: _chevronWidth),
                    for (var index = 0; index < columns.length; index++)
                      cell(
                          _workspace.buildTableCell(
                              _items[entry.libraryEntryRef!.key]!,
                              columns[index].id),
                          widths[index]),
                    actionSlot(FilledButton(
                      key: ValueKey(
                          'duplicates.remove.${entry.libraryEntryRef!.key}'),
                      style: _actionStyle(_removeColor, width: 75),
                      onPressed: _busy
                          ? null
                          : () => _remove([entry], automatic: false),
                      child: const Text('Remove'),
                    )),
                  ]),
                ),
          ]),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _sideMargin),
        child: SizedBox(
          width: tableWidth,
          child: Column(children: [
            header,
            Expanded(
              child: ListView(
                children: [for (final group in groups) groupBlock(group)],
              ),
            ),
          ]),
        ),
      );
    });
  }
}
