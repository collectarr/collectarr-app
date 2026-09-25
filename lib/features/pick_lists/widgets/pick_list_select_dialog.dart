import 'dart:async';
import 'dart:math' as math;

import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/pick_lists/pick_list_repository.dart';
import 'package:collectarr_app/features/pick_lists/models/pick_list_value.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_manager_page.dart';
import 'package:collectarr_app/features/pick_lists/widgets/pick_list_value_editor_dialog.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/accent_dialog_header.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<String?> showPickListSelectDialog({
  required BuildContext context,
  required String label,
  required List<String> options,
  String? selectedValue,
  String? listName,
  String? pluralLabel,
  String? mediaKind,
  bool allowUserValues = false,
  LocalDatabase? db,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _PickListSelectDialog(
      label: label,
      options: options,
      selectedValue: selectedValue,
      listName: listName,
      pluralLabel: pluralLabel,
      mediaKind: mediaKind,
      allowUserValues: allowUserValues,
      db: db,
    ),
  );
}

class _PickListSelectDialog extends StatefulWidget {
  const _PickListSelectDialog({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.listName,
    required this.pluralLabel,
    required this.mediaKind,
    required this.allowUserValues,
    required this.db,
  });

  final String label;
  final List<String> options;
  final String? selectedValue;
  final String? listName;
  final String? pluralLabel;
  final String? mediaKind;
  final bool allowUserValues;
  final LocalDatabase? db;

  @override
  State<_PickListSelectDialog> createState() => _PickListSelectDialogState();
}

class _PickListSelectDialogState extends State<_PickListSelectDialog> {
  final _searchController = TextEditingController();
  List<_PickListOption> _options = const [];
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
    unawaited(_load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final optionsByValue = <String, _PickListOption>{
      for (final value in widget.options)
        if (value.trim().isNotEmpty)
          normalizePickListValue(value): _PickListOption(
            value: value.trim(),
            count: 0,
          ),
    };
    final repository = _repository;
    final listName = widget.listName;
    if (repository != null && listName != null) {
      final values = await repository.valuesForList(
        listName: listName,
        mediaKind: widget.mediaKind,
      );
      for (final entry in values) {
        optionsByValue[entry.effectiveNormalizedValue] = _PickListOption(
          value: entry.effectiveLabel,
          count: 0,
        );
      }
    }
    final selectedValue = widget.selectedValue?.trim();
    if (selectedValue != null && selectedValue.isNotEmpty) {
      optionsByValue.putIfAbsent(
        normalizePickListValue(selectedValue),
        () => _PickListOption(value: selectedValue, count: 0),
      );
    }
    if (repository != null && listName != null) {
      final counts = await repository.usageCountsByValue(
        listName: listName,
        values: optionsByValue.values.map((option) => option.value),
        mediaKind: widget.mediaKind,
      );
      for (final entry in optionsByValue.entries.toList(growable: false)) {
        optionsByValue[entry.key] = _PickListOption(
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
      value = value?.trim();
      if (value?.isEmpty ?? true) value = null;
    }
    if (value == null) return;
    if (!mounted) return;
    final normalized = normalizePickListValue(value);
    setState(() {
      _options = [
        for (final option in _options)
          if (normalizePickListValue(option.value) != normalized) option,
        _PickListOption(value: value!, count: 0),
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
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visibleOptions = _options
        .where((option) => option.value.toLowerCase().contains(query))
        .toList(growable: false);
    final canManage = _repository != null;
    final palette = appPalette(context);
    final rowCount = math.max(visibleOptions.length, 1);
    final rowsHeight = math.min(rowCount * 36.0, 432.0);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      title: AccentDialogHeader(
        title: 'Select ${widget.label}',
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 36,
                        minHeight: 34,
                      ),
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
                        ? _buildStatusRow(
                            const CircularProgressIndicator(),
                            palette,
                          )
                        : visibleOptions.isEmpty
                            ? _buildStatusRow(
                                const Text('No Result'),
                                palette,
                              )
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

  Widget _buildStatusRow(Widget child, AppThemePalette palette) {
    final divider = BorderSide(color: palette.divider);
    return Row(
      children: [
        Container(
          width: 36,
          height: double.infinity,
          decoration: BoxDecoration(border: Border(right: divider)),
        ),
        Expanded(
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(border: Border(right: divider)),
            alignment: Alignment.center,
            child: child,
          ),
        ),
        const SizedBox(width: 64),
      ],
    );
  }

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
            decoration: BoxDecoration(border: Border(right: cellBorder)),
          ),
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
                child: Text(
                  'Count',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context,
    _PickListOption option,
    int index,
    AppThemePalette palette,
  ) {
    final selected = normalizePickListValue(option.value) ==
        normalizePickListValue(widget.selectedValue ?? '');
    final divider = BorderSide(color: palette.divider);
    return Material(
      color: selected
          ? palette.selection.withValues(alpha: 0.32)
          : index.isEven
              ? palette.tableEvenRow
              : palette.tableOddRow,
      child: InkWell(
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: () => Navigator.of(context).pop(option.value),
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
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
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

final class _PickListOption {
  const _PickListOption({required this.value, required this.count});

  final String value;
  final int count;
}
