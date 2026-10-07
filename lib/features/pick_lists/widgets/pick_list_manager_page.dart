import 'pick_list_chrome.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:collectarr_app/core/db/local_database.dart';
import 'package:collectarr_app/features/collection/repositories/custom_field_repository.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/app_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import '../models/pick_list_definition.dart';
import '../models/pick_list_scope.dart';
import '../models/pick_list_value.dart';
import '../pick_list_registry.dart';
import '../pick_list_repository.dart';
import '../pick_list_merge_service.dart';
import 'pick_list_value_editor_dialog.dart';
import 'pick_list_values_table.dart';

String pickListPluralLabel(String label) => switch (label) {
      'Country' => 'Countries',
      'Chorus' => 'Choruses',
      'Extra' => 'Extras',
      'SPARS' => 'SPARS',
      'Packaging' => 'Packaging',
      'Collection status' => 'Collection Statuses',
      'Sold to' => 'Sold To',
      'Loaned To' => 'Loaned To',
      'Package/Sleeve Condition' => 'Package/Sleeve Conditions',
      _ => label.endsWith('s') ? label : '${label}s',
    };

final class PickListManagerChanges {
  final Map<String, String?> replacements = {};
  String? apply(String listName, String value) {
    var current = value;
    final seen = <String>{};
    while (seen.add(normalizePickListValue(current))) {
      final normalized = '$listName:${normalizePickListValue(current)}';
      if (!replacements.containsKey(normalized)) return current;
      final replacement = replacements[normalized];
      if (replacement == null) return null;
      current = replacement;
    }
    return current;
  }
}

Future<PickListManagerChanges?> showPickListManagerDialog(
        {required BuildContext context,
        required LocalDatabase db,
        required PickListRegistry registry,
        String? initialListName,
        String? initialMediaKind}) =>
    showAppDialog<PickListManagerChanges>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PickListDialog(
          child: PickListManagerPage(
              db: db,
              registry: registry,
              initialListName: initialListName,
              initialMediaKind: initialMediaKind)),
    );

class PickListManagerPage extends StatefulWidget {
  const PickListManagerPage(
      {super.key,
      required this.db,
      required this.registry,
      this.initialListName,
      this.initialMediaKind,
      this.onBack,
      this.onClose});
  final LocalDatabase db;
  final PickListRegistry registry;
  final String? initialListName;
  final String? initialMediaKind;

  /// When entered from a selector, CLZ hides the list switcher and offers Back.
  final ValueChanged<PickListManagerChanges>? onBack;
  final ValueChanged<PickListManagerChanges>? onClose;
  @override
  State<PickListManagerPage> createState() => _PickListManagerPageState();
}

class _PickListManagerPageState extends State<PickListManagerPage> {
  final _search = TextEditingController();
  final _changes = PickListManagerChanges();
  late final _repo =
      PickListRepository(widget.db, contributors: widget.registry.contributors);
  late final _merger = PickListMergeService(widget.db,
      repository: _repo, contributors: widget.registry.contributors);
  List<PickListDefinition> _definitions = [];
  List<PickListValue> _values = [];
  Map<String, int> _counts = {};
  String? _selectedListName;
  bool _loading = true;
  bool _busy = false;
  bool _mergeMode = false;
  final Set<String> _selected = {};
  String? _error;
  int _generation = 0;
  PickListDefinition? get _definition => _definitions
      .where((item) => item.listName == _selectedListName)
      .firstOrNull;
  String? get _scopeKind => _selectedListName == 'locations'
      ? null
      : _definition?.mediaKind ?? widget.initialMediaKind;

  @override
  void initState() {
    super.initState();
    _selectedListName = widget.initialListName;
    unawaited(_load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final definitions = [
        ...widget.registry.definitionsForKind(widget.initialMediaKind)
      ];
      for (final field in await CustomFieldRepository(widget.db)
          .listDefinitions(mediaKind: widget.initialMediaKind)) {
        if (!field.supportsOptions) continue;
        definitions.add(PickListDefinition(
            id: 'customField:${field.id}',
            listName: 'customField:${field.id}',
            label: field.name,
            mediaKind: field.mediaKind,
            scope: PickListScope.customField,
            valueMode: field.valueType.isMultiValue
                ? PickListValueMode.multi
                : PickListValueMode.single,
            builtInValues: field.optionValues));
      }
      definitions.removeWhere(
          (definition) => definition.listName == 'collection_status');
      definitions.sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
      final definition = definitions
              .where((item) => item.listName == _selectedListName)
              .firstOrNull ??
          definitions.firstOrNull;
      final kind = definition?.listName == 'locations'
          ? null
          : definition?.mediaKind ?? widget.initialMediaKind;
      final stored = definition == null
          ? <PickListValue>[]
          : await _repo.valuesForList(
              listName: definition.listName, mediaKind: kind);
      final hidden = definition == null
          ? <String>{}
          : await _repo.hiddenValues(definition.listName, mediaKind: kind);
      final options = <String, PickListValue>{
        for (final value in stored)
          value.effectiveNormalizedValue: PickListValue(
              id: value.id,
              listName: value.listName,
              mediaKind: value.mediaKind,
              value: value.value,
              sortName: value.sortName,
              sortOrder: value.sortOrder,
              isSystem: value.isSystem,
              displayLabel: definition?.optionLabel?.call(value.value))
      };
      if (definition != null) {
        final derived =
            await _repo.entryOptions(definition.listName, mediaKind: kind);
        for (final value in [...definition.builtInValues, ...derived]) {
          final normalized = normalizePickListValue(value);
          if (normalized.isEmpty || hidden.contains(normalized)) continue;
          options.putIfAbsent(
              normalized,
              () => PickListValue(
                  id: 'option:${definition.listName}:$normalized',
                  listName: definition.listName,
                  mediaKind: kind,
                  value: value.trim(),
                  displayLabel: definition.optionLabel?.call(value.trim()),
                  isSystem: definition.builtInValues.contains(value)));
        }
      }
      final counts = definition == null
          ? <String, int>{}
          : await _repo.usageCountsByValue(
              listName: definition.listName,
              mediaKind: kind,
              values: options.values.map((value) => value.value));
      if (!mounted || generation != _generation) return;
      setState(() {
        _definitions = definitions;
        _selectedListName = definition?.listName;
        _values = options.values.toList();
        _counts = {
          for (final value in _values)
            value.id: counts[value.effectiveNormalizedValue] ?? 0
        };
        _selected.removeWhere((id) => !_values.any((value) => value.id == id));
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation();
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
          context: context,
          builder: (context) => AccentAlertDialog(
                  title: Text(title),
                  headerOnClose: () => Navigator.pop(context, false),
                  content: SizedBox(width: 440, child: Text(message)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(action)),
                  ])) ??
      false;

  Future<void> _edit(PickListValue value) async {
    final definition = _definition;
    if (definition == null || _busy) return;
    final edited = await showPickListValueEditorDialog(
        context: context,
        listName: definition.listName,
        label: definition.label,
        existing: value,
        mediaKind: _scopeKind);
    if (edited == null || !mounted) return;
    final result = PickListValue(
        id: value.mediaKind == _scopeKind && !value.id.startsWith('option:')
            ? value.id
            : const Uuid().v4(),
        listName: value.listName,
        mediaKind: _scopeKind,
        value: edited.value,
        sortName: edited.sortName,
        sortOrder: value.sortOrder);
    await _run(() async {
      await _merger.rename(value, result, mediaKind: _scopeKind);
      _changes.replacements[
          '${value.listName}:${value.effectiveNormalizedValue}'] = result.value;
    });
  }

  Future<void> _delete(PickListValue value) async {
    final count = _counts[value.id] ?? 0;
    final confirmed = await _confirm(
        'Remove ${value.effectiveLabel}',
        'Remove this value from the list${count == 0 ? '?' : ' and clear it from $count local entries?'}'
            '${value.listName.endsWith('.image_type') ? '\nImages will be kept; their type will be cleared.' : ''}',
        'Remove');
    if (!confirmed || !mounted) return;
    await _run(() async {
      await _merger.remove(value, mediaKind: _scopeKind);
      _changes.replacements[
          '${value.listName}:${value.effectiveNormalizedValue}'] = null;
    });
  }

  Future<void> _mergeInto(PickListValue target) async {
    final definition = _definition;
    if (definition == null) return;
    final sources =
        _values.where((value) => _selected.contains(value.id)).toList();
    await _run(() async {
      final preview = await _merger.previewMerge(
          listName: definition.listName,
          mediaKind: _scopeKind,
          sourceValues: sources.map((value) => value.value).toList(),
          targetValue: target.value);
      if (!mounted) return;
      final confirmed = await _confirm(
          'Merge ${pickListPluralLabel(definition.label)}',
          'Merge ${sources.length} selected values into ${target.effectiveLabel}?\n'
              'This updates ${preview.affectedCount} local entries and removes the other values.',
          'Merge');
      if (!confirmed) return;
      await _merger.applyMerge(preview);
      for (final source in sources) {
        _changes.replacements[
                '${source.listName}:${source.effectiveNormalizedValue}'] =
            target.value;
      }
      if (mounted) {
        setState(() {
          _mergeMode = false;
          _selected.clear();
        });
      }
    });
  }

  void _close() {
    if (_busy) return;
    final close = widget.onClose;
    if (close != null) {
      close(_changes);
    } else {
      Navigator.pop(context, _changes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final definition = _definition;
    final label = definition?.label ?? 'Pick List';
    final query = normalizePickListValue(_search.text);
    final visible = _values
        .where((value) =>
            normalizePickListValue(value.effectiveLabel).contains(query) ||
            normalizePickListValue(value.effectiveSortName).contains(query))
        .toList();
    final palette = appPalette(context);
    final fromSelection = widget.onBack != null;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _close();
        },
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
                          title: 'Manage ${pickListPluralLabel(label)}',
                          onClose: _busy ? null : _close),
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
                          middle: fromSelection
                              ? null
                              : PickListCount(
                                  count: visible.length,
                                  label: pickListPluralLabel(label)),
                          trailing: fromSelection
                              ? null
                              : SizedBox(
                                  width: 200,
                                  height: 32,
                                  child: DropdownButtonFormField<String>(
                                      initialValue: _selectedListName,
                                      isExpanded: true,
                                      isDense: true,
                                      decoration:
                                          pickListInputDecoration(context),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: palette.textPrimary),
                                      items: [
                                        for (final item in _definitions)
                                          DropdownMenuItem(
                                              value: item.listName,
                                              child: Text('${item.label} list',
                                                  overflow:
                                                      TextOverflow.ellipsis))
                                      ],
                                      onChanged: _busy
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _selectedListName = value;
                                                _loading = true;
                                                _mergeMode = false;
                                                _selected.clear();
                                                _search.clear();
                                              });
                                              unawaited(_load());
                                            }))),
                      if (_busy) const LinearProgressIndicator(minHeight: 2),
                      if (_error != null)
                        MaterialBanner(content: Text(_error!), actions: [
                          TextButton(
                              onPressed: _busy ? null : _load,
                              child: const Text('Retry'))
                        ]),
                      if (_mergeMode)
                        Container(
                            height: 45,
                            color: pickListToolbar(context),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                                'Checkbox the ${pickListPluralLabel(label)} you want to merge:',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700))),
                      Flexible(
                          fit: FlexFit.loose,
                          child: SizedBox(
                              height: math.max(1, visible.length) * 48.0 + 48,
                              child: _loading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : PickListValuesTable(
                                      key: ValueKey(_selectedListName),
                                      values: visible,
                                      usageCounts: _counts,
                                      mode: _mergeMode
                                          ? PickListTableMode.merge
                                          : PickListTableMode.manage,
                                      selectedIds: _selected,
                                      enabled: !_busy,
                                      onSelect: (value) => setState(() {
                                            if (!_selected.add(value.id)) {
                                              _selected.remove(value.id);
                                            }
                                          }),
                                      onEdit: _edit,
                                      onDelete: _delete))),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(children: [
                            if (_mergeMode)
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 26),
                                      child: Text(
                                          '${_selected.length} selected',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700))))
                            else ...[
                              if (fromSelection)
                                FilledButton(
                                    style: pickListButtonStyle(context,
                                        primary: false, footer: true),
                                    onPressed: _busy
                                        ? null
                                        : () => widget.onBack!(_changes),
                                    child: const Text('Back')),
                              const Spacer(),
                            ],
                            if (_mergeMode) ...[
                              FilledButton(
                                  style: pickListButtonStyle(context,
                                      primary: false, footer: true),
                                  onPressed: _busy
                                      ? null
                                      : () => setState(() {
                                            _mergeMode = false;
                                            _selected.clear();
                                          }),
                                  child: const Text('Cancel')),
                              const SizedBox(width: 5),
                              _mergeButton(context),
                            ] else
                              FilledButton(
                                  onPressed: _busy ||
                                          definition?.allowMerge != true
                                      ? null
                                      : () => setState(() => _mergeMode = true),
                                  style: pickListButtonStyle(context,
                                      footer: true),
                                  child: const Text('Merge Mode')),
                          ])),
                    ]))));
  }

  Widget _mergeButton(BuildContext context) {
    final enabled = !_busy && _selected.length > 1;
    final palette = appPalette(context);
    return PopupMenuButton<PickListValue>(
        enabled: enabled,
        tooltip: 'Choose destination',
        position: PopupMenuPosition.over,
        offset: Offset(0, -34.0 * _selected.length),
        menuPadding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
        onSelected: _mergeInto,
        itemBuilder: (_) => [
              for (final value
                  in _values.where((v) => _selected.contains(v.id)))
                PopupMenuItem(
                    value: value, height: 34, child: Text(value.effectiveLabel))
            ],
        child: Semantics(
            button: true,
            enabled: enabled,
            child: Container(
                constraints: const BoxConstraints(minWidth: 100),
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    color: enabled ? palette.accent : palette.surface,
                    borderRadius: BorderRadius.circular(4)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Merge to',
                      style: TextStyle(
                          fontSize: 14,
                          color: enabled
                              ? Theme.of(context).colorScheme.onPrimary
                              : palette.textMuted)),
                  Icon(Icons.arrow_drop_down,
                      size: 18,
                      color: enabled
                          ? Theme.of(context).colorScheme.onPrimary
                          : palette.textMuted),
                ]))));
  }
}
