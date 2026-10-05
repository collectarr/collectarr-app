import 'pick_list_chrome.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/library/kinds/registry/collectarr_pick_list_contributors.dart';
import '../models/pick_list_value.dart';
import '../pick_list_repository.dart';
import 'pick_list_manager_page.dart';
import 'pick_list_value_editor_dialog.dart';
import 'pick_list_values_table.dart';

/// Single and multiple selection use the same table and option composition.
class PickListSelectionDialog extends StatefulWidget {
  const PickListSelectionDialog(
      {super.key,
      required this.label,
      required this.options,
      required this.selectedValues,
      required this.multiple,
      this.listName,
      this.pluralLabel,
      this.mediaKind,
      this.allowUserValues = false,
      this.db});
  final String label;
  final List<String> options;
  final List<String> selectedValues;
  final bool multiple;
  final String? listName;
  final String? pluralLabel;
  final String? mediaKind;
  final bool allowUserValues;
  final LocalDatabase? db;
  @override
  State<PickListSelectionDialog> createState() =>
      _PickListSelectionDialogState();
}

class _PickListSelectionDialogState extends State<PickListSelectionDialog> {
  final _search = TextEditingController();
  late Set<String> _selected =
      widget.selectedValues.map(normalizePickListValue).toSet();
  final _changes = PickListManagerChanges();
  List<PickListValue> _values = [];
  Map<String, int> _counts = {};
  bool _busy = true;
  bool _managing = false;
  String? _error;
  String _labelFor(String value) {
    final definition = defaultPickListRegistry
        .definitionsForKind(widget.mediaKind)
        .where((definition) => definition.listName == widget.listName)
        .firstOrNull;
    return definition?.optionLabel?.call(value) ?? value;
  }

  PickListRepository? get _repository =>
      widget.db == null || widget.listName == null
          ? null
          : PickListRepository(widget.db!,
              contributors: defaultPickListDefinitionContributors);
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repository = _repository;
      final listName = widget.listName;
      final values = <String, PickListValue>{};
      void add(String value) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return;
        values.putIfAbsent(
            normalizePickListValue(trimmed),
            () => PickListValue(
                id: normalizePickListValue(trimmed),
                listName: listName ?? '',
                value: trimmed,
                displayLabel: _labelFor(trimmed)));
      }

      for (final option in widget.options) {
        final value = _changes.apply(listName ?? '', option);
        if (value != null) add(value);
      }
      if (repository != null && listName != null) {
        for (final value in await repository.entryOptions(listName,
            mediaKind: widget.mediaKind)) {
          add(value);
        }
        final hidden = await repository.hiddenValues(listName,
            mediaKind: widget.mediaKind);
        values.removeWhere((key, _) => hidden.contains(key));
        for (final row in await repository.valuesForList(
            listName: listName, mediaKind: widget.mediaKind)) {
          values[row.effectiveNormalizedValue] = PickListValue(
              id: row.effectiveNormalizedValue,
              listName: listName,
              value: row.value,
              displayLabel: _labelFor(row.value),
              sortName: row.sortName,
              mediaKind: row.mediaKind);
        }
      }
      // Preserve unsaved selections unless explicitly removed through Manage.
      for (final initial in widget.selectedValues) {
        final value = _changes.apply(listName ?? '', initial);
        if (value != null &&
            _selected.contains(normalizePickListValue(value))) {
          add(value);
        }
      }
      final counts = repository == null || listName == null
          ? <String, int>{}
          : await repository.usageCountsByValue(
              listName: listName,
              mediaKind: widget.mediaKind,
              values: values.values.map((value) => value.value));
      if (!mounted) return;
      setState(() {
        _values = values.values.toList();
        _counts = counts;
        _busy = false;
        _error = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _create() async {
    if (_busy || !widget.allowUserValues) return;
    final created = await showPickListValueEditorDialog(
        context: context,
        listName: widget.listName ?? '',
        label: widget.label,
        mediaKind: widget.mediaKind,
        title: 'New ${widget.label}');
    if (created == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = _repository;
      if (repository != null) await repository.upsertValue(created);
      final key = created.effectiveNormalizedValue;
      if (!mounted) return;
      setState(() {
        _values = [
          ..._values.where((value) => value.effectiveNormalizedValue != key),
          PickListValue(
              id: key,
              listName: created.listName,
              value: created.value,
              sortName: created.sortName)
        ];
        if (widget.multiple) _selected.add(key);
        _busy = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  void _manage() {
    if (widget.db == null || widget.listName == null || _busy) return;
    setState(() => _managing = true);
  }

  Future<void> _backFromManage(PickListManagerChanges changes) async {
    final listName = widget.listName!;
    _changes.replacements.addAll(changes.replacements);
    _selected = {
      for (final selected in _selected)
        if (changes.apply(listName, selected) case final value?)
          normalizePickListValue(value)
    };
    setState(() {
      _managing = false;
      _busy = true;
    });
    await _load();
  }

  void _select(PickListValue value) {
    if (!widget.multiple) {
      Navigator.pop(context, value.value);
      return;
    }
    setState(() {
      if (!_selected.add(value.id)) _selected.remove(value.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_managing) {
      return PickListDialog(
          child: PickListManagerPage(
              db: widget.db!,
              registry: defaultPickListRegistry,
              initialListName: widget.listName,
              initialMediaKind: widget.mediaKind,
              onBack: _backFromManage,
              onClose: (_) => Navigator.pop(context)));
    }
    final query = normalizePickListValue(_search.text);
    final visible = _values
        .where((value) =>
            normalizePickListValue(value.effectiveLabel).contains(query) ||
            normalizePickListValue(value.effectiveSortName).contains(query))
        .toList();
    return PickListDialog(
        child: Material(
            color: pickListSurface(context),
            child: DefaultTextStyle.merge(
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PickListHeader(
                          title: 'Select ${widget.label}',
                          onClose: () => Navigator.pop(context)),
                      PickListToolbar(
                          search: TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: pickListInputDecoration(context,
                                  hintText: 'Search...',
                                  suffixIcon: IconButton(
                                      style: IconButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          disabledBackgroundColor:
                                              Colors.transparent,
                                          side: BorderSide.none),
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      icon: Icon(query.isEmpty
                                          ? Icons.search
                                          : Icons.close),
                                      onPressed: () =>
                                          setState(() => _search.clear())))),
                          trailing: Wrap(spacing: 5, runSpacing: 6, children: [
                            if (widget.allowUserValues)
                              FilledButton(
                                  onPressed: _busy ? null : _create,
                                  style: pickListButtonStyle(context),
                                  child: Text('New ${widget.label}')),
                            if (_repository != null)
                              FilledButton(
                                  onPressed: _busy ? null : _manage,
                                  style: pickListButtonStyle(context,
                                      primary: false),
                                  child: Text(
                                      'Manage ${widget.pluralLabel ?? pickListPluralLabel(widget.label)}')),
                          ])),
                      if (_error != null)
                        MaterialBanner(content: Text(_error!), actions: [
                          TextButton(
                              onPressed: _load, child: const Text('Retry'))
                        ]),
                      Flexible(
                          fit: FlexFit.loose,
                          child: SizedBox(
                              height: math.max(visible.length, 1) * 48.0 + 48,
                              child: _busy
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : PickListValuesTable(
                                      values: visible,
                                      usageCounts: _counts,
                                      selectedIds: _selected,
                                      mode: widget.multiple
                                          ? PickListTableMode.multiSelect
                                          : PickListTableMode.singleSelect,
                                      onSelect: _select))),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (widget.multiple)
                                  FilledButton(
                                      style: pickListButtonStyle(context,
                                          footer: true),
                                      onPressed: _busy
                                          ? null
                                          : () => Navigator.pop(context, {
                                                for (final value in _values)
                                                  if (_selected
                                                      .contains(value.id))
                                                    value.value
                                              }),
                                      child: const Text('Save')),
                              ])),
                    ]))));
  }
}
