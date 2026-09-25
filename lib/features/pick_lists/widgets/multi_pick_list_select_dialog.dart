import 'dart:math' as math;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_value_editor_dialog.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/adaptive/window_class.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<Set<String>?> showMultiPickListSelectDialog({
  required BuildContext context,
  required String label,
  required List<String> options,
  required Set<String> selectedValues,
  String? listName,
  String? pluralLabel,
  String? mediaKind,
  bool allowUserValues = true,
  LocalDatabase? db,
}) {
  return showDialog<Set<String>>(
    context: context,
    builder: (context) => _MultiPickListSelectDialog(
      label: label,
      options: options,
      selectedValues: selectedValues,
      listName: listName,
      pluralLabel: pluralLabel,
      mediaKind: mediaKind,
      allowUserValues: allowUserValues,
      db: db,
    ),
  );
}

class _MultiPickListSelectDialog extends StatefulWidget {
  const _MultiPickListSelectDialog({
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.listName,
    required this.pluralLabel,
    required this.mediaKind,
    required this.allowUserValues,
    required this.db,
  });

  final String label;
  final List<String> options;
  final Set<String> selectedValues;
  final String? listName;
  final String? pluralLabel;
  final String? mediaKind;
  final bool allowUserValues;
  final LocalDatabase? db;

  @override
  State<_MultiPickListSelectDialog> createState() =>
      _MultiPickListSelectDialogState();
}

class _MultiPickListSelectDialogState
    extends State<_MultiPickListSelectDialog> {
  final _searchController = TextEditingController();
  late final Set<String> _selected = {...widget.selectedValues};
  List<_MultiPickListOption> _options = const [];
  bool _loading = true;

  PickListRepository? get _repository {
    final db = widget.db;
    final listName = widget.listName;
    if (db == null || listName == null || listName.isEmpty) return null;
    return PickListRepository(
      db,
      contributors: defaultPickListDefinitionContributors,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final optionsByValue = <String, _MultiPickListOption>{
      for (final value in widget.options)
        if (value.trim().isNotEmpty)
          normalizePickListValue(value):
              _MultiPickListOption(value: value.trim(), count: 0),
    };
    final repository = _repository;
    final listName = widget.listName;
    if (repository != null && listName != null) {
      final values = await repository.valuesForList(
        listName: listName,
        mediaKind: widget.mediaKind,
      );
      for (final entry in values) {
        optionsByValue[entry.effectiveNormalizedValue] = _MultiPickListOption(
          value: entry.effectiveLabel,
          count: 0,
        );
      }
    }
    for (final value in _selected) {
      optionsByValue.putIfAbsent(
        normalizePickListValue(value),
        () => _MultiPickListOption(value: value, count: 0),
      );
    }
    if (repository != null && listName != null) {
      final counts = await repository.usageCountsByValue(
        listName: listName,
        values: optionsByValue.values.map((option) => option.value),
        mediaKind: widget.mediaKind,
      );
      for (final entry in optionsByValue.entries.toList(growable: false)) {
        optionsByValue[entry.key] = _MultiPickListOption(
          value: entry.value.value,
          count: counts[normalizePickListValue(entry.value.value)] ?? 0,
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _options = optionsByValue.values.toList()
        ..sort((left, right) =>
            left.value.toLowerCase().compareTo(right.value.toLowerCase()));
      _loading = false;
    });
  }

  Future<void> _createValue() async {
    final repository = _repository;
    final listName = widget.listName;
    String? value;
    if (repository != null && listName != null) {
      final created = await showPickListValueEditorDialog(
        context: context,
        listName: listName,
        label: widget.label,
        mediaKind: widget.mediaKind,
        title: 'New ${widget.label}',
        valueFieldLabel: 'Name',
      );
      if (created != null) {
        await repository.upsertValue(created);
        value = created.value;
      }
    } else {
      final controller = TextEditingController();
      value = await showDialog<String>(
        context: context,
        builder: (context) => AccentAlertDialog(
          title: AccentDialogHeader(title: 'New ${widget.label}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      controller.dispose();
    }
    value = value?.trim();
    if (value == null || value.isEmpty || !mounted) return;
    setState(() {
      _selected.add(value!);
      _options = [
        for (final option in _options)
          if (_normalize(option.value) != _normalize(value)) option,
        _MultiPickListOption(value: value, count: 0),
      ]..sort((left, right) =>
          left.value.toLowerCase().compareTo(right.value.toLowerCase()));
    });
  }

  Future<void> _manageValues() async {
    final db = widget.db;
    final listName = widget.listName;
    if (db == null || listName == null) return;
    await showPickListManagerDialog(
      context: context,
      db: db,
      registry: defaultPickListRegistry,
      initialListName: listName,
      initialMediaKind: widget.mediaKind,
      title: 'Manage ${widget.pluralLabel ?? widget.label}',
    );
    if (!mounted) return;
    setState(() => _loading = true);
    await _load();
  }

  void _toggle(String value) {
    setState(() {
      if (!_selected.add(value)) _selected.remove(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visibleOptions = _options
        .where((option) => option.value.toLowerCase().contains(query))
        .toList(growable: false);
    final canManage = _repository != null;
    final palette = appPalette(context);
    final windowClass = AppWindowClass.of(context);
    final rowCount = math.max(visibleOptions.length, 1);
    final rowsHeight = math.min(rowCount * 36.0, 432.0);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.fromLTRB(
        windowClass.isMedium ? 16 : 32,
        8,
        windowClass.isMedium ? 16 : 32,
        16,
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      title: AccentDialogHeader(
        title: 'Select ${widget.pluralLabel ?? widget.label}',
        icon: Icons.list_alt_outlined,
      ),
      content: SizedBox(
        width: 720,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 36, minHeight: 34),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Spacer(),
                if (widget.allowUserValues || canManage) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _createValue,
                    style: _compactActionStyle(),
                    child: Text('New ${widget.label}'),
                  ),
                ],
                if (canManage) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _manageValues,
                    style: _compactActionStyle(
                      backgroundColor: palette.panelRaised,
                      foregroundColor: palette.textPrimary,
                      side: BorderSide(color: palette.divider),
                    ),
                    child: Text('Manage ${widget.pluralLabel ?? widget.label}'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: palette.divider),
                borderRadius: BorderRadius.circular(3),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildTableHeader(context, palette),
                  SizedBox(
                    height: rowsHeight,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : visibleOptions.isEmpty
                            ? const Center(child: Text('No Result'))
                            : ListView.builder(
                                itemCount: visibleOptions.length,
                                itemBuilder: (context, index) =>
                                    _buildOptionRow(
                                  context,
                                  visibleOptions[index],
                                  index,
                                  palette,
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(Set.unmodifiable(_selected)),
          icon: const Icon(Icons.check, size: 18),
          label: Text('Done (${_selected.length})'),
        ),
      ],
    );
  }

  ButtonStyle _compactActionStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    BorderSide? side,
  }) =>
      FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: side,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );

  Widget _buildTableHeader(BuildContext context, AppThemePalette palette) {
    final cellBorder = BorderSide(color: palette.divider);
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: palette.panelRaised,
        border: Border(bottom: cellBorder),
      ),
      child: Row(
        children: [
          Container(
              width: 36,
              decoration: BoxDecoration(border: Border(right: cellBorder))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(border: Border(right: cellBorder)),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text('Name', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_drop_down,
                      size: 18, color: palette.textMuted),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Count',
                    style: Theme.of(context).textTheme.labelLarge),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context,
    _MultiPickListOption option,
    int index,
    AppThemePalette palette,
  ) {
    final selected =
        _selected.any((value) => _normalize(value) == _normalize(option.value));
    final divider = BorderSide(color: palette.divider);
    return Material(
      color: selected
          ? palette.selection.withValues(alpha: 0.32)
          : index.isEven
              ? palette.tableEvenRow
              : palette.tableOddRow,
      child: InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: () => _toggle(option.value),
        child: Container(
          height: 36,
          decoration: BoxDecoration(border: Border(bottom: divider)),
          child: Row(
            children: [
              Container(
                width: 36,
                decoration: BoxDecoration(border: Border(right: divider)),
                alignment: Alignment.center,
                child: Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18,
                  color: selected ? palette.accent : palette.textMuted,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(border: Border(right: divider)),
                  alignment: Alignment.centerLeft,
                  child: Text(option.value, maxLines: 1),
                ),
              ),
              SizedBox(
                width: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('${option.count}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _normalize(String value) => normalizePickListValue(value);

final class _MultiPickListOption {
  const _MultiPickListOption({required this.value, required this.count});

  final String value;
  final int count;
}
