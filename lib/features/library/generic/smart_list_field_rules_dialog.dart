import 'package:collectarr_app/core/models/catalog_media_kind.dart';
import 'package:collectarr_app/core/models/smart_list_criteria.dart';
import 'package:collectarr_app/features/library/config/library_kind_field_metadata.dart';
import 'package:collectarr_app/features/library/library_kind_registry.dart';
import 'package:collectarr_app/ui/accent_alert_dialog.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<Map<String, SmartListFieldCriterion>?> showSmartListFieldRulesDialog({
  required BuildContext context,
  required CatalogMediaKind kind,
  required SmartListCriteriaTarget target,
  required Map<String, SmartListFieldCriterion> initial,
  required List<String> kinds,
}) {
  return showDialog<Map<String, SmartListFieldCriterion>>(
    context: context,
    builder: (_) => _SmartListFieldRulesDialog(
      kind: kind,
      target: target,
      initial: initial,
      kinds: kinds,
    ),
  );
}

class _SmartListFieldRulesDialog extends StatefulWidget {
  const _SmartListFieldRulesDialog({
    required this.kind,
    required this.target,
    required this.initial,
    required this.kinds,
  });

  final CatalogMediaKind kind;
  final SmartListCriteriaTarget target;
  final Map<String, SmartListFieldCriterion> initial;
  final List<String> kinds;

  @override
  State<_SmartListFieldRulesDialog> createState() =>
      _SmartListFieldRulesDialogState();
}

class _SmartListFieldRulesDialogState
    extends State<_SmartListFieldRulesDialog> {
  late final List<_FieldOption> _options = _loadOptions();
  late final Set<String> _preservedFieldIds = _unknownInitialIds();
  late final List<_RuleDraft> _rules = _initialRules();
  String? _error;

  List<_FieldOption> _loadOptions() {
    final workspace = libraryKindWorkspaceForKind(widget.kind);
    final registry = widget.target == SmartListCriteriaTarget.catalog
        ? workspace.fields
        : workspace.libraryEntryFields;
    final byId = <String, LibraryKindFieldMetadata>{};
    for (final field in registry.fields) {
      if (_isAvailableForTarget(field.metadata) && field.filterable) {
        byId[field.metadata.id] = field.metadata;
      }
    }
    for (final filter
        in libraryPresentationForKind(widget.kind).filterDefinitions) {
      if (_isAvailableForTarget(filter.metadata) &&
          filter.metadata.filterable) {
        byId[filter.metadata.id] = filter.metadata;
      }
    }
    final options = [
      for (final metadata in byId.values) _FieldOption(metadata),
    ];
    options.sort((left, right) => left.metadata.label.toLowerCase().compareTo(
          right.metadata.label.toLowerCase(),
        ));
    return options;
  }

  bool _isAvailableForTarget(LibraryKindFieldMetadata metadata) =>
      widget.target != SmartListCriteriaTarget.catalog ||
      metadata.source != LibraryFieldSource.libraryEntry;

  Set<String> _unknownInitialIds() {
    return widget.initial.entries
        .where((entry) => !_canEditCriterion(entry.key, entry.value))
        .map((entry) => entry.key)
        .toSet();
  }

  List<_RuleDraft> _initialRules() {
    return [
      for (final entry in widget.initial.entries)
        if (_canEditCriterion(entry.key, entry.value))
          _RuleDraft(
            fieldId: entry.key,
            operator: entry.value.operator,
            value: entry.value.value ?? '',
          ),
    ];
  }

  bool _canEditCriterion(String id, SmartListFieldCriterion criterion) {
    final field = _optionFor(id);
    if (field == null) return false;
    if (criterion.operator == SmartListFieldOperator.contains &&
        field.metadata.valueType != LibraryFieldValueType.text) {
      return false;
    }
    if (criterion.operator == SmartListFieldOperator.isEmpty) return true;
    return _valueIsValid(field.metadata.valueType, criterion.value);
  }

  bool _valueIsValid(LibraryFieldValueType type, String? value) {
    if (value == null) return false;
    return switch (type) {
      LibraryFieldValueType.boolean => value == 'true' || value == 'false',
      LibraryFieldValueType.number => num.tryParse(value) != null,
      _ => value.trim().isNotEmpty,
    };
  }

  _FieldOption? _optionFor(String? id) {
    for (final option in _options) {
      if (option.id == id) return option;
    }
    return null;
  }

  void _addRule() {
    final usedIds = _rules.map((rule) => rule.fieldId).toSet();
    final option = _options.cast<_FieldOption?>().firstWhere(
          (candidate) => candidate != null && !usedIds.contains(candidate.id),
          orElse: () => null,
        );
    if (option == null) return;
    setState(() {
      _rules.add(_RuleDraft(
        fieldId: option.id,
        operator: SmartListFieldOperator.equals,
        value: option.metadata.valueType == LibraryFieldValueType.boolean
            ? 'true'
            : '',
      ));
      _error = null;
    });
  }

  void _save() {
    final result = <String, SmartListFieldCriterion>{};
    for (final id in _preservedFieldIds) {
      final criterion = widget.initial[id];
      if (criterion != null) result[id] = criterion;
    }
    final seen = <String>{};
    for (final rule in _rules) {
      final field = _optionFor(rule.fieldId);
      if (field == null || !seen.add(rule.fieldId)) {
        setState(() => _error = 'Each rule must use a different field.');
        return;
      }
      if (rule.operator == SmartListFieldOperator.contains &&
          field.metadata.valueType != LibraryFieldValueType.text) {
        setState(() => _error = 'Contains is only available for text fields.');
        return;
      }
      if (rule.operator != SmartListFieldOperator.isEmpty &&
          rule.value.trim().isEmpty) {
        setState(() => _error = 'Enter a value for every field rule.');
        return;
      }
      if (rule.operator != SmartListFieldOperator.isEmpty &&
          !_valueIsValid(field.metadata.valueType, rule.value.trim())) {
        setState(
            () => _error = 'Enter a valid value for ${field.metadata.label}.');
        return;
      }
      result[rule.fieldId] = SmartListFieldCriterion(
        operator: rule.operator,
        value: rule.operator == SmartListFieldOperator.isEmpty
            ? null
            : rule.value.trim(),
      );
    }
    Navigator.pop(
        context, Map<String, SmartListFieldCriterion>.unmodifiable(result));
  }

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final otherKinds =
        widget.kinds.where((kind) => kind != widget.kind.apiValue);
    return AccentAlertDialog(
      backgroundColor: palette.panel,
      title: const Text('Edit field rules'),
      content: SizedBox(
        width: 620,
        child: _options.isEmpty
            ? const Text('This kind has no filterable workspace fields.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rules are evaluated against ${widget.kind.apiValue} values. '
                    'For many-valued fields, equals matches any value and '
                    'not equals requires that no value matches.',
                    style: TextStyle(color: palette.textMuted),
                  ),
                  if (otherKinds.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Rules for other kinds remain unchanged: ${otherKinds.join(', ')}.',
                      style: TextStyle(color: palette.textMuted),
                    ),
                  ],
                  if (_preservedFieldIds.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${_preservedFieldIds.length} unavailable field rule(s) are preserved.',
                      style: TextStyle(color: palette.textMuted),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 340),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var index = 0; index < _rules.length; index++)
                            _buildRuleRow(index, palette),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _rules.length == _options.length
                                  ? null
                                  : _addRule,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add field rule'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save rules')),
      ],
    );
  }

  Widget _buildRuleRow(int index, AppThemePalette palette) {
    final rule = _rules[index];
    final field = _optionFor(rule.fieldId);
    final allowedOperators = [
      SmartListFieldOperator.equals,
      SmartListFieldOperator.notEquals,
      if (field?.metadata.valueType == LibraryFieldValueType.text)
        SmartListFieldOperator.contains,
      SmartListFieldOperator.isEmpty,
    ];
    final selectedOperator = allowedOperators.contains(rule.operator)
        ? rule.operator
        : SmartListFieldOperator.equals;
    final usedByOtherRules = _rules
        .where((candidate) => !identical(candidate, rule))
        .map((candidate) => candidate.fieldId)
        .toSet();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: DropdownButtonFormField<String>(
              initialValue: rule.fieldId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Field'),
              items: [
                for (final option in _options)
                  DropdownMenuItem(
                    value: option.id,
                    enabled: !usedByOtherRules.contains(option.id),
                    child: Text(option.metadata.label),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  rule.fieldId = value;
                  rule.operator = SmartListFieldOperator.equals;
                  rule.value = _optionFor(value)?.metadata.valueType ==
                          LibraryFieldValueType.boolean
                      ? 'true'
                      : '';
                  _error = null;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<SmartListFieldOperator>(
              initialValue: selectedOperator,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Operator'),
              items: [
                for (final operator in allowedOperators)
                  DropdownMenuItem(
                    value: operator,
                    child: Text(_operatorLabel(operator)),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  rule.operator = value;
                  _error = null;
                });
              },
            ),
          ),
          if (selectedOperator != SmartListFieldOperator.isEmpty &&
              field?.metadata.valueType == LibraryFieldValueType.boolean) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: DropdownButtonFormField<String>(
                initialValue: rule.value,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Value'),
                items: const [
                  DropdownMenuItem(value: 'true', child: Text('true')),
                  DropdownMenuItem(value: 'false', child: Text('false')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    rule.value = value;
                    _error = null;
                  });
                },
              ),
            ),
          ] else if (selectedOperator != SmartListFieldOperator.isEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: TextFormField(
                key: ValueKey('${rule.fieldId}-${rule.value}-$index'),
                initialValue: rule.value,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: _valueHint(field?.metadata.valueType),
                ),
                onChanged: (value) {
                  rule.value = value;
                  _error = null;
                },
              ),
            ),
          ] else
            const Expanded(flex: 4, child: SizedBox.shrink()),
          IconButton(
            tooltip: 'Remove rule',
            onPressed: () => setState(() {
              _rules.removeAt(index);
              _error = null;
            }),
            icon: Icon(Icons.close, color: palette.textMuted, size: 18),
          ),
        ],
      ),
    );
  }

  String _operatorLabel(SmartListFieldOperator operator) => switch (operator) {
        SmartListFieldOperator.equals => 'equals',
        SmartListFieldOperator.notEquals => 'not equals',
        SmartListFieldOperator.contains => 'contains',
        SmartListFieldOperator.isEmpty => 'is empty',
      };

  String? _valueHint(LibraryFieldValueType? type) => switch (type) {
        LibraryFieldValueType.boolean => 'true or false',
        LibraryFieldValueType.date ||
        LibraryFieldValueType.partialDate =>
          'YYYY or YYYY-MM-DD',
        _ => null,
      };
}

class _FieldOption {
  const _FieldOption(this.metadata);

  final LibraryKindFieldMetadata metadata;
  String get id => metadata.id;
}

class _RuleDraft {
  _RuleDraft({
    required this.fieldId,
    required this.operator,
    this.value = '',
  });

  String fieldId;
  SmartListFieldOperator operator;
  String value;
}
